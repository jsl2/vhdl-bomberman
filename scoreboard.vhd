library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


use work.state_pkg.all;
use work.graphics_pkg.all;
use work.numbers_pkg.all;

entity scoreboard is
    Port ( DRAW_POS : in point;
           POWERUPS : in powerups_state;
           PVALID : out boolean;           
           PIXEL : out pixel_type);
end scoreboard;

architecture Behavioral of scoreboard is
begin

process (POWERUPS, DRAW_POS) is
    variable offset_x : integer range 0 to 63;
    variable temp : std_logic_vector(6 downto 0);
begin
    PVALID <= false;
    PIXEL <= TRANSPARENT_PIXEL;
    if DRAW_POS.x >= 216 and DRAW_POS.x < 224 then
        PVALID <= true;
        offset_x := DRAW_POS.x - 216;
        -- number of bombs
        temp := std_logic_vector(to_unsigned(POWERUPS.BOMB_LIMIT,4)) & "000";        
        if NUMBERS_PIXELS(DRAW_POS.y-1,offset_x + to_integer(unsigned(temp))) = 1 then
            PIXEL <= WHITE_PIXEL;
        end if;  
    elsif DRAW_POS.x >= 240 and DRAW_POS.x < 248 then
        PVALID <= true;
        -- blast radius
        offset_x := DRAW_POS.x - 240;
        temp := std_logic_vector(to_unsigned(POWERUPS.BLAST_RADIUS,4)) & "000";
        if NUMBERS_PIXELS(DRAW_POS.y-1,offset_x + to_integer(unsigned(temp))) = 1 then
            PIXEL <= WHITE_PIXEL;
        end if;    
    end if;
end process;
end;
