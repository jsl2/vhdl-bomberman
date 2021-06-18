library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.graphics_pkg.all;
use work.bombs_pkg.all;
use work.state_pkg.all;
use work.explosions_pkg.all;
use work.tile_state_pkg.all;

entity walls is
    Port ( CLK : in STD_LOGIC;
           CE : in STD_LOGIC;
           TILE_COORD : in tile_point;
           OFFSET : in bitmap_offset;
           WALL : in wall_state_vector;
           PVALID : out boolean;           
           PIXEL : out pixel_type);
end walls;

architecture Behavioral of walls is
component walls_rom is
    Port ( CLK : in STD_LOGIC;
           ADDR : in integer range 0 to (2**11 - 1);
           PIX_CE : in STD_LOGIC;
           PIXEL : out pixel_type);
end component;

signal ADDR : integer range 0 to (2**11 - 1);

begin

rom : walls_rom
port map (
    CLK => CLK,
    ADDR => ADDR,
    PIX_CE => '1',
    PIXEL => PIXEL   
);

draw: process(WALL, TILE_COORD, OFFSET)
    variable addr_temp : std_logic_vector(10 downto 0);
begin    
    PVALID <= false;
    addr_temp :=  "000" & X"00";
    
    if WALL.ACTIVE then
        PVALID <= true;
        addr_temp := std_logic_vector(to_unsigned(0,3)) & std_logic_vector(to_unsigned(OFFSET.y, 4)) & std_logic_vector(to_unsigned(OFFSET.x, 4));
    elsif WALL.CRUMBLING then
        PVALID <= true;
        addr_temp := std_logic_vector(to_unsigned(WALL.FRAME + 1,3)) & std_logic_vector(to_unsigned(OFFSET.y, 4)) & std_logic_vector(to_unsigned(OFFSET.x, 4));
    end if;
    
    ADDR <= to_integer(unsigned(addr_temp));
end process;

end Behavioral;