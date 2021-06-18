library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.graphics_pkg.all;

entity vga_controller is
    Port ( CLK : in std_logic;
           PIX_CE : in std_logic;
           PRE_CE : in std_logic;
           HSYNC : out std_logic;
           VSYNC : out std_logic;           
           DE : out std_logic;           
           RASTER_POS : out point;
           RASTER_PIXEL : out integer range 0 to (SCREEN_WIDTH * SCREEN_HEIGHT - 1);
           TOUCH_UPDATE : out std_logic;
           LOGIC_UPDATE : out std_logic;
           STATE_UPDATE : out std_logic);
end vga_controller;

architecture Behavioral of vga_controller is 
    constant THP : integer := 41;                   -- horizontal pulse period (in pixel CLKS = 1/12.5MHz)
    constant THB : integer := 2;                    -- horizontal back porch period
    constant THD : integer := 480;                  -- horizontal display period 
    constant THF : integer := 78;                   -- horizontal front porch period
    constant TH : integer := THP + THB + THD + THF; -- total HSYNC period
    
    constant TVP : integer := 10;                   -- vertical pulse period (in TH) 
    constant TVB : integer := 2;                    -- vertical back porch period
    constant TVD : integer := 272;                  -- vertical display period
    constant TVF : integer := 62;                   -- vertical front porch period
    constant TV : integer := TVP + TVB + TVD + TVF; -- total VYSNC period     
    
    constant THD_START : integer := THP + THB;      -- count when horizontal valid pixels start
    constant THD_END : integer := THD_START + THD;  -- count after horizontal valid pixels
    
    constant TVD_START : integer := TVP + TVB;      -- count when vertical valid pixels start
    constant TVD_END : integer := TVD_START + TVD;  -- count after vertical valid pixels end
begin

process (CLK)
    variable hcount : integer range 0 to TH := 0;   -- horizontal counter = x pixel coordinate whilst in visible area
    variable vcount : integer range 0 to TV := 0;   -- vertical counter = y pixel coordinate whilst in visible area
    variable pixel_count : integer range 0 to SCREEN_WIDTH * SCREEN_HEIGHT := 0;
begin
    
    if CLK'event and CLK='1' then
        if PRE_CE = '1' then
            if (hcount >= THD_START and hcount < THD_END) and (vcount >= TVD_START and vcount < TVD_END) then
                RASTER_POS.x <= hcount - THD_START;
                RASTER_POS.y <= vcount - TVD_START;                                
            else
                RASTER_POS.x <= THD;
                RASTER_POS.y <= TVD;
            end if;
            
            if (hcount >= THD_START and hcount < THD_END) and (vcount >= TVD_START and vcount < TVD_END) then
                pixel_count := pixel_count + 1;
            elsif vcount >= TVD_END then
                pixel_count := 0;
            end if;
            
            -- vcount and hcount counters
            hcount := hcount + 1;            
            if hcount = TH then
                hcount := 0;
                vcount := vcount + 1;
                if vcount = TV then
                    vcount := 0;
                    pixel_count := 0;
                end if;
            end if;   
        elsif PIX_CE = '1' then
            RASTER_PIXEL <= pixel_count;
            -- Are we in visible area            
            if (hcount >= THD_START and hcount < THD_END) and (vcount >= TVD_START and vcount < TVD_END) then
                DE <= '1';                             
            else
                DE <= '0';
            end if;
            
            -- Check HSYNC
            if hcount < THP then
                HSYNC <= '0';
            else
                HSYNC <= '1';
            end if;
            
            -- Check VSYNC
            if vcount < TVP then
                VSYNC <= '0';
            else
                VSYNC <= '1';
            end if;
            
            if vcount = TVD_END and hcount = 1 then
                STATE_UPDATE <= '1';
            else
                STATE_UPDATE <= '0';
            end if;
            -- state update takes ~1.1k clks
            -- one vsync is 6k clks
            
            -- logic update after touch acquisition time
            if vcount = TVD_END+1 and hcount = 1 then
                TOUCH_UPDATE <= '1';
            else
                TOUCH_UPDATE <= '0';
            end if;
            
            if vcount = TVD_END+3 and hcount = 1 then
                LOGIC_UPDATE <= '1';
            else
                LOGIC_UPDATE <= '0';
            end if;                            
        else
            LOGIC_UPDATE <= '0'; -- these signals should only be one clock long
            TOUCH_UPDATE <= '0'; 
            STATE_UPDATE <= '0';
        end if;
    end if;
    
end process;

end Behavioral;
