library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.graphics_pkg.all;
use work.bomberman_pkg.all;
use work.touch_pkg.all;

entity bomberman is
    Port ( CLK : in STD_LOGIC;
           DRAW_POS : in point;
           COORD : in point;
           DIR : in direction;
           DYING : in boolean;
           FRAME : in integer range 0 to 31;
           PVALID : out boolean;           
           PIXEL : out pixel_type);
end bomberman;

architecture Behavioral of bomberman is  

component bomberman_rom is
    Port ( CLK : in STD_LOGIC;
           ADDR : in integer range 0 to (2**14 - 1);  -- 64 (35 used) tiles of 16*16 each
           PIX_CE : in STD_LOGIC;
           PIXEL : out pixel_type);
end component;

signal ADDR : integer range 0 to (2**14 - 1);

begin

rom : bomberman_rom
port map (
    CLK => CLK,
    ADDR => ADDR,
    PIX_CE => '1',
    PIXEL => PIXEL   
);

draw: process(FRAME, DRAW_POS, COORD, DIR)
    variable offset_x : integer range 0 to BOMBERMAN_WIDTH - 1;
    variable offset_y : integer range 0 to BOMBERMAN_HEIGHT - 1;
    variable actual_frame : integer range 0 to 31;
    
    variable addr_temp : std_logic_vector(13 downto 0);
begin
    addr_temp := "00" & X"000";
    
    if (draw_pos.x >= COORD.x and draw_pos.x < (COORD.x + BOMBERMAN_WIDTH)) and (draw_pos.y >= COORD.y and draw_pos.y < (COORD.y + BOMBERMAN_HEIGHT)) then        
        PVALID <= true;
        offset_x := draw_pos.x - COORD.x;        
        offset_y := draw_pos.y - COORD.y;
        
        if DYING then
            case frame is
                when 0|4|8|12 =>
                    actual_frame := 12;
                when 1|5|9|13 =>
                    actual_frame := 13;
                when 2|6|10|14 =>
                    actual_frame := 14;
                when 3|7|11|15 =>
                    actual_frame := 15;
                when 16 =>
                    actual_frame := 16;
                when 17 =>
                    actual_frame := 17;
                when 18 =>
                    actual_frame := 18;
                when 19|22|25 =>
                    actual_frame := 18;                  
                when 20|23|26 =>
                    actual_frame := 19;                   
                when 21|24|27 => 
                    actual_frame := 20;
                when others =>
                    actual_frame := 20;
            end case;
            addr_temp := std_logic_vector(to_unsigned(actual_frame,5)) & std_logic_vector(to_unsigned(offset_y,5)) & std_logic_vector(to_unsigned(offset_x,4)); 
        else
            -- walking frame 0,1,2,3 => 0,1,0,2
            actual_frame := frame;
            if frame = 2 then
                actual_frame := 0;
            elsif frame = 3 then
                actual_frame := 2;
            end if;
            case DIR is
                when up =>
                    addr_temp := std_logic_vector(to_unsigned(actual_frame,5)) & std_logic_vector(to_unsigned(offset_y,5)) & std_logic_vector(to_unsigned(offset_x,4));               
                when down =>
                    addr_temp := std_logic_vector(to_unsigned(6+actual_frame,5)) & std_logic_vector(to_unsigned(offset_y,5)) & std_logic_vector(to_unsigned(offset_x,4));
                when left =>
                    addr_temp := std_logic_vector(to_unsigned(9+actual_frame,5)) & std_logic_vector(to_unsigned(offset_y,5)) & std_logic_vector(to_unsigned(offset_x,4));
                when right =>
                    addr_temp := std_logic_vector(to_unsigned(3+actual_frame,5)) & std_logic_vector(to_unsigned(offset_y,5)) & std_logic_vector(to_unsigned(offset_x,4));
            end case;
        end if;
    else
        PVALID <= false;
    end if;
    ADDR <= to_integer(unsigned(addr_temp));
end process;

end Behavioral;
