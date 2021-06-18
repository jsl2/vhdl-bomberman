library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.graphics_pkg.all;
use work.background_pkg.all;

entity ui_bg is
    Port ( CLK : in STD_LOGIC;         
           ADDR : in integer range 0 to (2**17 - 1);
           PIX_CE : in STD_LOGIC;
           PIXEL : out pixel_type);
end ui_bg;

architecture Behavioral of ui_bg is

signal pix : pixel_type;
signal bg : bg_rom_type := BG_PIC; 
    
begin

pix <= bg(ADDR);

draw: process(CLK)
begin
    if CLK'event and CLK = '1' then        
        if PIX_CE = '1' then 
            PIXEL <= pix;
        end if;
    end if;
end process;

end Behavioral;
