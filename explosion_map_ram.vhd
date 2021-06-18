library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.tile_state_pkg.all;
use work.graphics_pkg.all;

entity tile_state_map_ram is
    Port ( CLK : in STD_LOGIC;
           ADDR : in tile_address;
           CE : in STD_LOGIC;
           WE : in STD_LOGIC;
           IN_STATE : in tile_state_vector;
           OUT_STATE : out tile_state_vector); 
end tile_state_map_ram;

architecture Behavioral of tile_state_map_ram is
signal ram : tile_state_ram := (others=>(others=>'0'));
signal ram_out : tile_state_slv;
signal ram_out_reg : tile_state_vector := INITIAL_TILE_STATE;   
begin

process(CLK)
begin
    if(CLK'event and CLK = '1') then
        if(CE = '1') then
            if(WE = '1') then
                ram(to_integer(unsigned(ADDR))) <= pack_tile_state(IN_STATE);
            else
                ram_out <= ram(to_integer(unsigned(ADDR)));
            end if;
        end if;
    end if;
end process;

process(CLK)
begin
    if(CLK'event and CLK = '1') then
        if(CE = '1') then
            ram_out_reg <= unpack_tile_state(ram_out);
        end if;
    end if;
end process;

-- 2 clk after read
OUT_STATE <= ram_out_reg;

end Behavioral;