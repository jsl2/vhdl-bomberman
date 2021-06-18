library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.graphics_pkg.all;
use work.bombs_pkg.all;
use work.state_pkg.all;
use work.explosions_pkg.all;
use work.tile_state_pkg.all;

entity explosions is
    Port ( CLK : in STD_LOGIC;
           CE : in STD_LOGIC;
           TILE_COORD : in tile_point;
           OFFSET : in bitmap_offset;
           EXPLOSION : in explosion_state_vector;
           PVALID : out boolean;           
           PIXEL : out pixel_type);
end explosions;

architecture Behavioral of explosions is
component explosions_rom is
    Port ( CLK : in STD_LOGIC;
           ADDR : in integer range 0 to (2**14 - 1);  -- 64 (35 used) tiles of 16*16 each
           PIX_CE : in STD_LOGIC;
           PIXEL : out pixel_type);
end component;

signal ADDR : integer range 0 to (2**14 - 1);

begin

rom : explosions_rom
port map (
    CLK => CLK,
    ADDR => ADDR,
    PIX_CE => '1',
    PIXEL => PIXEL   
);

draw: process(EXPLOSION, TILE_COORD, OFFSET)
    variable frame_idx : integer range 0 to 4;
    variable tile_idx : integer range 0 to 34;
    variable actual_frame : integer range 0 to 15;
    variable addr_temp : std_logic_vector(13 downto 0);
begin    
    PVALID <= false;
    addr_temp := "00" & X"000";
    
    if EXPLOSION.ACTIVE then
        PVALID <= true;
        case EXPLOSION.FRAME is
            when 0|12 =>
                frame_idx := 0;
            when 1|11 =>
                frame_idx := 1;
            when 2|10 =>
                frame_idx := 2;
            when 3|5|7|9 =>
                frame_idx := 3;
            when 4|6|8 =>
                frame_idx := 4;
            when others =>
                frame_idx := 0;
        end case;
    
        if EXPLOSION.ORIG then
            addr_temp := std_logic_vector(to_unsigned(30+frame_idx,6)) & std_logic_vector(to_unsigned(OFFSET.x, 4)) & std_logic_vector(to_unsigned(OFFSET.y, 4));                
        elsif EXPLOSION.DIR = DOWN then
            addr_temp := std_logic_vector(to_unsigned(25+frame_idx,6)) & std_logic_vector(to_unsigned(OFFSET.x, 4)) & std_logic_vector(to_unsigned(OFFSET.y, 4));
            if EXPLOSION.EDGE then -- right most extent
                addr_temp := std_logic_vector(to_unsigned(15+frame_idx,6)) & std_logic_vector(to_unsigned(OFFSET.x, 4)) & std_logic_vector(to_unsigned(OFFSET.y, 4));
            end if;
        elsif  EXPLOSION.DIR = UP then                                        
            addr_temp := std_logic_vector(to_unsigned(25+frame_idx,6)) & std_logic_vector(to_unsigned(OFFSET.x, 4)) & std_logic_vector(to_unsigned(OFFSET.y, 4));
            if EXPLOSION.EDGE then -- left most extent
                addr_temp := std_logic_vector(to_unsigned(10+frame_idx,6)) & std_logic_vector(to_unsigned(OFFSET.x, 4)) & std_logic_vector(to_unsigned(OFFSET.y, 4));
            end if;             
        elsif EXPLOSION.DIR = RIGHT then                
            addr_temp := std_logic_vector(to_unsigned(20+frame_idx,6)) & std_logic_vector(to_unsigned(OFFSET.x, 4)) & std_logic_vector(to_unsigned(OFFSET.y, 4));
            if EXPLOSION.EDGE then -- bottom most extent
                addr_temp := std_logic_vector(to_unsigned(5+frame_idx,6)) & std_logic_vector(to_unsigned(OFFSET.x, 4)) & std_logic_vector(to_unsigned(OFFSET.y, 4));
            end if;
        elsif EXPLOSION.DIR = LEFT then                    
            addr_temp := std_logic_vector(to_unsigned(20+frame_idx,6)) & std_logic_vector(to_unsigned(OFFSET.x, 4)) & std_logic_vector(to_unsigned(OFFSET.y, 4));
            if EXPLOSION.EDGE then -- top most extent
                addr_temp := std_logic_vector(to_unsigned(frame_idx,6)) & std_logic_vector(to_unsigned(OFFSET.x, 4)) & std_logic_vector(to_unsigned(OFFSET.y, 4));
            end if;
        end if;               
    end if;
    
    ADDR <= to_integer(unsigned(addr_temp));
end process;

end Behavioral;
