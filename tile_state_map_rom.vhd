library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.tile_state_pkg.all;
use work.graphics_pkg.all;
use work.levels_pkg.all;

entity tile_state_map_rom is
    Port ( CLK : in STD_LOGIC;
           ADDR : in tile_address;  -- 8 tiles (7 used) of 16*16 each
           CE : in STD_LOGIC;
           OUT_TILE_STATE : out tile_state_vector);
end tile_state_map_rom;

architecture Behavioral of tile_state_map_rom is

signal tile_state : tile_state_vector;
signal rom : tile_state_ram := LEVEL0_STATE_RAM;
signal rom_out : tile_state_slv;
    
begin

draw: process(CLK)
begin
    if CLK'event and CLK = '1' then        
        if CE = '1' then
            rom_out <= rom(to_integer(unsigned(ADDR))); 
        end if;
    end if;
end process;

process(CLK)
begin
    if(CLK'event and CLK = '1') then
        if(CE = '1') then
            tile_state <= unpack_tile_state(rom_out);
        end if;
    end if;
end process;

OUT_TILE_STATE <= tile_state;
end Behavioral;