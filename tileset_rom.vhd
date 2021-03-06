library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.tileset_pkg.all;
use work.graphics_pkg.all;
use work.background_pkg.all;

entity tileset_rom is
    Port ( CLK : in STD_LOGIC;
           ADDR : in integer range 0 to (2**15 - 1);  -- 128 tiles of 16*16 each
           PIX_CE : in STD_LOGIC;
           PIXEL : out pixel_type);
end tileset_rom;

architecture Behavioral of tileset_rom is

signal pix : pixel_type;
signal tileset : tileset_rom_type := CASTLE_TILESET; 
    
begin

pix <= tileset(ADDR);

draw: process(CLK)
begin
    if CLK'event and CLK = '1' then        
        if PIX_CE = '1' then 
            PIXEL <= pix;
        end if;
    end if;
end process;


end Behavioral;
