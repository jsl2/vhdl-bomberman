library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.maps_pkg.all;
use work.tile_state_pkg.all;

entity collision_map_ram is
    Port ( CLK : in STD_LOGIC;
           ADDR : in tile_address; --32x32 = 1024  
           CE : in STD_LOGIC;
           WE : in STD_LOGIC;
           IN_STATE : in std_logic;
           OUT_STATE : out std_logic);
end collision_map_ram;

architecture Behavioral of collision_map_ram is
signal ram : collision_map_ram_type := LEVEL0_COLLISION_INITIAL; 
signal state_internal : std_logic;
    
begin
--Insert the following in the architecture after the begin keyword
process(CLK)
begin
    if(CLK'event and CLK = '1') then
        if(CE = '1') then
            if(WE = '1') then
                ram(to_integer(unsigned(ADDR))) <= IN_STATE;
            else
                state_internal <= ram(to_integer(unsigned(ADDR)));
            end if;
        end if;
    end if;
end process;

OUT_STATE <= state_internal;

end Behavioral;