library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pixel_clk_gen is
    Port ( CLK : in std_logic;
           PIX_CE : out std_logic;
           PRE_CE : out std_logic;
           PIX_CK : out std_logic);
end pixel_clk_gen;

architecture Behavioral of pixel_clk_gen is    
begin

process (CLK)
    variable count : integer range 0 to 8 := 0;
begin

    if CLK'event and CLK = '1' then
        if count = 0 then
            PIX_CE <= '1';
        else
            PIX_CE <= '0';
        end if;
    
        if count < 4 then
            PIX_CK <= '1';
        else
            PIX_CK <= '0';
        end if;
        
        if count = 6 then
            PRE_CE <= '1';
        else
            PRE_CE <= '0';
        end if;
        count := count + 1;
        if count = 8 then 
            count := 0;
        end if;
    end if;
    
end process;
    
end Behavioral;
