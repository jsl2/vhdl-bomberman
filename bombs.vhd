library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.graphics_pkg.all;
use work.state_pkg.all;
use work.tile_state_pkg.all;
use work.bombs_pkg.all;

entity bombs is
    Port ( CLK : in STD_LOGIC;
           TILE_COORD : in tile_point;
           OFFSET : in bitmap_offset;
           BOMB : in bomb_state_vector;
           PVALID : out boolean;           
           PIXEL : out pixel_type);
end bombs;

architecture Behavioral of bombs is    
begin

draw: process(CLK)
    variable actual_frame : integer range 0 to 15;
begin    
    if CLK'event and CLK = '1' then        
        PIXEL <= TRANSPARENT_PIXEL;
        PVALID <= false;
        if BOMB.ACTIVE then
            PVALID <= true;
            
            case BOMB.FRAME is
                when 0|2|4|6|8 =>                    
                    PIXEL <= medium_bomb(OFFSET.y, OFFSET.x);
                when 3|7 =>
                    PIXEL <= large_bomb(OFFSET.y, OFFSET.x);
                when 1|5|9 =>
                    PIXEL <= small_bomb(OFFSET.y, OFFSET.x);                            
            end case;                    
        end if;   
    end if;
end process;

end Behavioral;
