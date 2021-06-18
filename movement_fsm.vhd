library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.touch_pkg.all;
use work.graphics_pkg.all;

entity movement_fsm is
Port ( BUTTON : in button_state;
       COORD : in point;       
       COORD_NEW : out point;
       DIRECTION : out direction);
end movement_fsm;

architecture Behavioral of movement_fsm is
   type state is (idle,left,right,up,down); -- wait is for push_a
   signal current_state, next_state : state := idle;
begin

output: process(current_state,BUTTON,COORD)
begin
    COORD_NEW.x <= COORD.x;
    COORD_NEW.y <= COORD.y;
    DIRECTION <= none;
    
    if BUTTON = left then
        COORD_NEW.x <= COORD.x-1;
        COORD_NEW.y <= COORD.y;
        DIRECTION <= left;
    elsif BUTTON = right then
        COORD_NEW.x <= COORD.x+1;
        COORD_NEW.y <= COORD.y;
        DIRECTION <= right;
    elsif BUTTON <= up then
        COORD_NEW.x <= COORD.x;
        COORD_NEW.y <= COORD.y-1;
        DIRECTION <= up;
    elsif BUTTON <= down then
        COORD_NEW.x <= COORD.x;
        COORD_NEW.y <= COORD.y+1;
        DIRECTION <= down;            
    end if;        
end process;

end Behavioral;
