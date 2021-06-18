library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.enemies_pkg.all;
use work.graphics_pkg.all;
use work.background_pkg.all;

entity enemies_rom is
    Port ( CLK : in STD_LOGIC;
           ADDR : in integer range 0 to (2**13 - 1);  -- 8 tiles (7 used) of 16*16 each
           PIX_CE : in STD_LOGIC;
           PIXEL : out pixel_type);
end enemies_rom;

architecture Behavioral of enemies_rom is

signal pix : pixel_type;
signal rom : enemies_rom_type := PUFFPUFF_FRAMES; 
    
begin

pix <= rom(ADDR);

draw: process(CLK)
begin
    if CLK'event and CLK = '1' then        
        if PIX_CE = '1' then 
            PIXEL <= pix;
        end if;
    end if;
end process;


end Behavioral;