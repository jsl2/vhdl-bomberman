library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.maps_pkg.all;
use work.graphics_pkg.all;
use work.tileset_pkg.all;
use work.levels_pkg.all;

entity background_map is
    Port ( CLK : in STD_LOGIC;
           PIX_CE : in STD_LOGIC;
           TILE_COORD : in tile_point;
           OFFSET : in bitmap_offset;
           LEVEL : in integer range 0 to LEVELS_COUNT;
           PVALID : out boolean;
           PIXEL : out pixel_type);
end background_map;

architecture Behavioral of background_map is

component tileset_rom is
    Port ( CLK : in STD_LOGIC;
           ADDR : in integer range 0 to (2**15 - 1);  -- 256 tiles of 16*16 each
           PIX_CE : in STD_LOGIC;
           PIXEL : out pixel_type);
end component;

signal ADDR : integer range 0 to (2**15 - 1);

begin

rom : tileset_rom
port map (
    CLK => CLK,
    ADDR => ADDR,
    PIX_CE => PIX_CE,
    PIXEL => PIXEL);

process (TILE_COORD, OFFSET, LEVEL)
variable addr_temp : std_logic_vector(14 downto 0);
begin        
    if TILE_COORD.x < LEVEL_DATA(LEVEL).MAP_SIZE.WIDTH and TILE_COORD.y < LEVEL_DATA(LEVEL).MAP_SIZE.HEIGHT then
        addr_temp := std_logic_vector(to_unsigned(get_tile(LEVEL, TILE_COORD),7)) & std_logic_vector(to_unsigned(OFFSET.y,4)) & std_logic_vector(to_unsigned(OFFSET.x,4));
        ADDR <= to_integer(unsigned(addr_temp));
        PVALID <= true;
    else
        ADDR <= 0;         
        PVALID <= false;
    end if;
end process;


end Behavioral;
