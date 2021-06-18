library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.graphics_pkg.all;
use work.bombs_pkg.all;
use work.state_pkg.all;
use work.enemies_pkg.all;


entity enemies is
    Port ( CLK : in STD_LOGIC;
           CE : in STD_LOGIC;
           DRAW_POS : in point;
           ENEMIES : in enemy_states;
           PVALID : out boolean;           
           PIXEL : out pixel_type;
           FLASH : out boolean );
end enemies;

architecture Behavioral of enemies is
component enemies_rom is
    Port ( CLK : in STD_LOGIC;
           ADDR : in integer range 0 to (2**13 - 1);  -- 64 (35 used) tiles of 16*16 each
           PIX_CE : in STD_LOGIC;
           PIXEL : out pixel_type);
end component;

signal ADDR : integer range 0 to (2**13 - 1);

begin

rom : enemies_rom
port map (
    CLK => CLK,
    ADDR => ADDR,
    PIX_CE => '1',
    PIXEL => PIXEL   
);

draw: process(ENEMIES, DRAW_POS)
    variable actual_frame : integer range 0 to 4;    
    variable addr_temp : std_logic_vector(12 downto 0);
    variable counter_temp : std_logic_vector(4 downto 0);
    variable offset_x : integer range 0 to 15;
    variable offset_y : integer range 0 to 31;
begin    
    PVALID <= false;
    addr_temp := "0" & X"000";  
    flash <= false;
    for i in 0 to MAX_ENEMIES-1 loop        
        if (draw_pos.x >= ENEMIES(i).COORD.x and draw_pos.x < (ENEMIES(i).COORD.x + 16)) and (draw_pos.y >= ENEMIES(i).COORD.y and draw_pos.y < (ENEMIES(i).COORD.y + 32)) then
            PVALID <= true;
            offset_x := draw_pos.x - ENEMIES(i).COORD.x;        
            offset_y := draw_pos.y - ENEMIES(i).COORD.y;
            if ENEMIES(i).ALIVE then
                PVALID <= true;                
                case ENEMIES(i).FRAME is
                    when 0 =>
                        actual_frame := 0;
                    when 1=>
                        actual_frame := 1;
                    when 2 =>
                        actual_frame := 2;
                    when 3 =>
                        actual_frame := 1;
                end case;
            
                case ENEMIES(i).DIR is                    
                    when down =>
                        addr_temp := std_logic_vector(to_unsigned(actual_frame,4)) & std_logic_vector(to_unsigned(offset_y, 5)) & std_logic_vector(to_unsigned(offset_x, 4));
                    when left =>
                        addr_temp := std_logic_vector(to_unsigned(3+actual_frame,4)) & std_logic_vector(to_unsigned(offset_y, 5)) & std_logic_vector(to_unsigned(offset_x, 4));
                    when up =>
                        addr_temp := std_logic_vector(to_unsigned(6+actual_frame,4)) & std_logic_vector(to_unsigned(offset_y, 5)) & std_logic_vector(to_unsigned(offset_x, 4));
                    when right =>
                        addr_temp := std_logic_vector(to_unsigned(9+actual_frame,4)) & std_logic_vector(to_unsigned(offset_y, 5)) & std_logic_vector(to_unsigned(15-offset_x, 4));
                end case;                
            elsif ENEMIES(i).DYING then
                PVALID <= true;
                addr_temp := std_logic_vector(to_unsigned(12,4)) & std_logic_vector(to_unsigned(offset_y, 5)) & std_logic_vector(to_unsigned(offset_x, 4));
                counter_temp := std_logic_vector(to_unsigned(ENEMIES(i).COUNTER,5));
                flash <= counter_temp(1) = '1';                 
            end if;
        end if;
    end loop;
    ADDR <= to_integer(unsigned(addr_temp));
end process;

end Behavioral;
