library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.touch_pkg.all;
--
-- The Unisim Library is used to define Xilinx primitives. It is also used during
-- simulation. The source can be viewed at %XILINX%\vhdl\src\unisims\unisim_VCOMP.vhd
--  
--library unisim;
--use unisim.vcomponents.all;
--
--
entity touch_controller is
    Port ( CLK : in std_logic;
           START : in std_logic;
           MISO : in std_logic;
           MOSI : out std_logic;
           SCK : out std_logic;
           CS : out std_logic;           
           BUTTON : out button_state);
end touch_controller;

--
architecture Behavioural of touch_controller is

--
-------------------------------------------------------------------------------------------
-- Signals
-------------------------------------------------------------------------------------------
--

--
-- Signals for connection of KCPSM6 and Program Memory.
--

signal         address : std_logic_vector(11 downto 0);
signal     instruction : std_logic_vector(17 downto 0);
signal     bram_enable : std_logic;
signal         in_port : std_logic_vector(7 downto 0);
signal        out_port : std_logic_vector(7 downto 0);
signal         port_id : std_logic_vector(7 downto 0);
signal    write_strobe : std_logic;
signal  k_write_strobe : std_logic;
signal     read_strobe : std_logic;
signal       interrupt : std_logic;
signal   interrupt_ack : std_logic;
signal               x : integer range 0 to 255 := 0;
signal               y : integer range 0 to 255 := 0;
signal      button_int : button_state := none;
signal     button_prev : button_state := none;
signal    button_prev2 : button_state := none;
signal measure_complete : std_logic;
signal last_measure_complete : std_logic;
signal      measure_ce : std_logic;

--
-------------------------------------------------------------------------------------------
-- Components
-------------------------------------------------------------------------------------------
--
component kcpsm6 
generic(                 hwbuild : std_logic_vector(7 downto 0) := X"00";
                interrupt_vector : std_logic_vector(11 downto 0) := X"3FF";
         scratch_pad_memory_size : integer := 64);
port (                   address : out std_logic_vector(11 downto 0);
                     instruction : in std_logic_vector(17 downto 0);
                     bram_enable : out std_logic;
                         in_port : in std_logic_vector(7 downto 0);
                        out_port : out std_logic_vector(7 downto 0);
                         port_id : out std_logic_vector(7 downto 0);
                    write_strobe : out std_logic;
                  k_write_strobe : out std_logic;
                     read_strobe : out std_logic;
                       interrupt : in std_logic;
                   interrupt_ack : out std_logic;
                           sleep : in std_logic;
                           reset : in std_logic;
                             clk : in std_logic);
end component;

component picoblaze_prog_mem                             
Port (      address : in std_logic_vector(11 downto 0);
        instruction : out std_logic_vector(17 downto 0);
             enable : in std_logic;                 
                clk : in std_logic);
end component;

begin

processor: kcpsm6
    generic map (                 hwbuild => X"00", 
                         interrupt_vector => X"3FF",
                  scratch_pad_memory_size => 64)
    port map(      address => address,
               instruction => instruction,
               bram_enable => bram_enable,
                   port_id => port_id,
              write_strobe => write_strobe,
            k_write_strobe => k_write_strobe,
                  out_port => out_port,
               read_strobe => read_strobe,
                   in_port => in_port,
                 interrupt => interrupt,
             interrupt_ack => interrupt_ack,
                     sleep => '0',
                     reset => '0',
                       clk => clk);

program_rom: picoblaze_prog_mem
    port map(      address => address,      
               instruction => instruction,
                    enable => bram_enable,
                       clk => clk);

in_port <= "0000000" & miso;

output_ports: process(clk)
begin
    if clk'event and clk = '1' then        
        -- 'write_strobe' is used to qualify all writes to general output ports.
        if write_strobe = '1' then
            -- Write to output_port_w at port address 01 hex
            if port_id(0) = '1' then -- spi outputs
                mosi <= out_port(7);
                sck <= out_port(6);
                cs <= out_port(5);            
            end if;
    
            -- Write to output_port_x at port address 04 hex
            if port_id(2) = '1' then
              x <= to_integer(unsigned(out_port));
            end if;
    
            -- Write to output_port_y at port address 08 hex
            if port_id(3) = '1' then
              y <= to_integer(unsigned(out_port));
              measure_complete <= '1';
              -- generate measurement complete clock enable
            else
              measure_complete <= '0';
            end if;
        end if;
    end if; 
end process output_ports;

measure_clock_enable : process(CLK)
begin
    if CLK'event and CLK='1' then
        if measure_complete = '1' and last_measure_complete = '0' then
            measure_ce <= '1';
        else
            measure_ce <= '0';
        end if;
        last_measure_complete <= measure_complete;
    end if;
end process;

button_state: process(x,y)
begin
    if y = 0 then
        button_int <= none;
    else
        if (x >= 30 and x < 78) and (y >= 204 and y < 230) then -- left        
            button_int <= left;
        elsif (x >= 92 and x < 132) and (y >= 176 and y < 198) then -- center
            button_int <= up;
        elsif (x >= 92 and x < 132) and (y >= 200 and y < 220) then
            button_int <= bomb;
        elsif (x >= 92 and x < 132) and (y >= 224 and y < 246) then
            button_int <= down;            
        elsif (x >= 144 and x < 194) and (y >= 204 and y < 230) then -- right
            button_int <= right;
        else
            button_int <= none;
        end if;
    end if;
end process button_state;


debounce_button: process(clk)   
begin
    if clk'event and clk='1' then
        if measure_ce = '1' then --CE
            if button_int = button_prev and button_int = button_prev2 then
                BUTTON <= button_int;
            end if;
            button_prev <= button_int;
            button_prev2 <= button_prev;
        end if;
    end if;
end process debounce_button;

interrupt_control: process(clk)
begin
if clk'event and clk='1' then
    if interrupt_ack = '1' then
        interrupt <= '0';
    else
        if START = '1' then
            interrupt <= '1';
        else
            interrupt <= interrupt;
        end if;
    end if;
end if; 
end process interrupt_control;

end Behavioural;
