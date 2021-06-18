library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.graphics_pkg.all;
use work.touch_pkg.all;
use work.state_pkg.all;
use work.tile_state_pkg.all;
use work.maps_pkg.all;
use work.levels_pkg.all;

entity top is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           MISO : in STD_LOGIC;
           MOSI : out STD_LOGIC;
           SCK : out STD_LOGIC; 
           CS : out STD_LOGIC;           
           GND : out STD_LOGIC;
           BL_EN : out STD_LOGIC;
           R : out STD_LOGIC_VECTOR (7 downto 0);
           G : out STD_LOGIC_VECTOR (5 downto 0);
           B_LOW : out STD_LOGIC_VECTOR (1 downto 0);
           B_HIGH : out STD_LOGIC_VECTOR (3 downto 0);
           DE : out STD_LOGIC;
           VSYNC : out STD_LOGIC;
           PIX_CK : out STD_LOGIC;
           HSYNC : out STD_LOGIC);
end top;

architecture Behavioral of top is

component vga_controller is
    Port ( CLK : in std_logic;
           PIX_CE : in std_logic;
           PRE_CE : in STD_LOGIC;
           HSYNC : out std_logic;
           VSYNC : out std_logic;           
           DE : out std_logic;           
           RASTER_POS : out point;
           RASTER_PIXEL : out integer range 0 to (SCREEN_WIDTH * SCREEN_HEIGHT - 1);
           TOUCH_UPDATE : out std_logic;
           LOGIC_UPDATE : out std_logic;
           STATE_UPDATE : out std_logic);
end component;

component pixel_clk_gen is
    Port ( CLK : in STD_LOGIC;
           PIX_CE : out STD_LOGIC;
           PRE_CE : out STD_LOGIC;
           PIX_CK : out STD_LOGIC);
end component;

component ppu is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           PIX_CE : in STD_LOGIC;           
           RASTER_POS : in point;
           RASTER_PIXEL : in integer range 0 to (SCREEN_HEIGHT*SCREEN_WIDTH - 1);
           RGB_PIXEL : out rgb_pixel_type;
           GAME_STATE : in state_vector;
           TILE_STATE : in tile_state_vector;
           DRAW_TILE_COORD : out tile_point);
end component;

component touch_controller is
    Port ( CLK : in std_logic;
           START : in std_logic;
           MISO : in std_logic;
           MOSI : out std_logic;
           SCK : out std_logic;
           CS : out std_logic;
           BUTTON : out button_state);
end component;

component game_logic is
    Port ( BUTTON : in button_state;
           GAME_STATE : in state_vector;
           NEXT_GAME_STATE : out state_vector);
end component;

component tiled_logic is
    Port ( CLK : in std_logic;
           LOGIC_UPDATE : in std_logic;
           BUTTON : in button_state;
           GAME_STATE : in state_vector;                                      
           NEXT_GAME_STATE : out state_vector;
           TILE_STATE : in tile_state_vector;           
           OUT_TILE_STATE : out tile_state_vector;
           READ_TILE_ADDR : out tile_address;
           WRITE_TILE_ADDR : out tile_address;
           WRITE_TILE_STATE : out boolean;
           LOGIC_COMPLETE : out boolean);
end component;

component tile_state_map_ram is    
    Port ( CLK : in STD_LOGIC;
           ADDR : in tile_address;
           CE : in STD_LOGIC;
           WE : in STD_LOGIC;
           IN_STATE : in tile_state_vector;
           OUT_STATE : out tile_state_vector); 
end component;

component tile_state_map_rom is
    Port ( CLK : in STD_LOGIC;
           ADDR : in tile_address;
           CE : in STD_LOGIC;
           OUT_TILE_STATE : out tile_state_vector);
end component;

type UPDATE_STATE_TYPE is (idle, main_update, tile_update);
signal UPDATE_STATE : UPDATE_STATE_TYPE;
signal NEXT_UPDATE_STATE : UPDATE_STATE_TYPE;
signal STATE_UPDATE_COMPLETE : boolean := false;
signal TILE_LOGIC_COMPLETE : boolean := false;
type game_status_type is (loading, in_level, finished);
signal GAME_STATUS : game_status_type := loading;
signal NEXT_GAME_STATUS : game_status_type := loading;

signal PIX_CE : STD_LOGIC;
signal PRE_CE : STD_LOGIC;
signal RASTER_POS : point;
signal RASTER_PIXEL : integer range 0 to (SCREEN_WIDTH * SCREEN_HEIGHT - 1);
signal BG_PIXEL : pixel_type;
signal PIXEL : pixel_type;
signal RGB_PIXEL : rgb_pixel_type;
signal BG_ADDR : STD_LOGIC_VECTOR(17 downto 0);
signal TOUCH_UPDATE : STD_LOGIC;
signal LOGIC_UPDATE : STD_LOGIC;
signal STATE_UPDATE : STD_LOGIC;
signal BUTTON : button_state;


signal GAME_STATE : state_vector := INITIAL_STATE;
signal GAME_STATE_INT : state_vector := INITIAL_STATE;
signal NEXT_GAME_STATE : state_vector := INITIAL_STATE;

signal DRAW_TILE_COORD : tile_point;
signal TILE_STATE_ADDR : tile_address;
signal NEXT_TILE_STATE_ADDR : tile_address;
signal LOGIC_UPDATING : boolean := false;
signal STATE_UPDATING : boolean := false;
signal DRAWING : std_logic;

signal WRITE_TILE_STATE : boolean := false;

signal TILE_STATE : tile_state_vector;
signal NEW_TILE_STATE : tile_state_vector;
signal TILE_STATE_INT : tile_state_vector;
signal TILE_STATE_INT2 : tile_state_vector;
signal TILE_STATE_LEVEL0 : tile_state_vector;
signal READ_TILE_ADDR : tile_address;
signal WRITE_TILE_ADDR : tile_address;


signal TILE_CE : std_logic := '0';
signal NEXT_TILE_CE : std_logic := '0';
signal TILE_WE : std_logic := '0';
signal NEXT_TILE_WE : std_logic := '0';


signal update_tile_state_addr : integer range 0 to (MAX_MAP_SIZE.HEIGHT * MAX_MAP_SIZE.WIDTH)-1;
signal next_update_tile_state_addr : integer range 0 to (MAX_MAP_SIZE.HEIGHT * MAX_MAP_SIZE.WIDTH)-1;
signal tile_coord : tile_point := (0,0);
signal LOGIC_UPDATE_COUNTER : integer range 0 to 255 := 0;
signal TILE_STATE_OFFSET : tile_offset;
signal LAST_TILE_STATE_OFFSET : tile_offset;
signal state_valid : boolean := false;

begin

p1 : pixel_clk_gen
port map (
    CLK => CLK,
    PIX_CE => PIX_CE,
    PRE_CE => PRE_CE,
    PIX_CK => PIX_CK
    );
    
vga1 : vga_controller
port map (
    CLK => CLK,
    PIX_CE => PIX_CE,
    PRE_CE => PRE_CE,
    HSYNC => HSYNC,
    VSYNC => VSYNC,
    DE => DRAWING,
    RASTER_POS => RASTER_POS,
    RASTER_PIXEL => RASTER_PIXEL,
    TOUCH_UPDATE => TOUCH_UPDATE,
    LOGIC_UPDATE => LOGIC_UPDATE,
    STATE_UPDATE => STATE_UPDATE
    );

DE <= DRAWING;

ppu1 : ppu
port map (
    CLK => CLK,
    RST => RST,    
    PIX_CE => PIX_CE,
    RASTER_POS => RASTER_POS,
    RASTER_PIXEL => RASTER_PIXEL,    
    RGB_PIXEL => RGB_PIXEL,
    GAME_STATE => GAME_STATE,
    TILE_STATE => TILE_STATE,
    DRAW_TILE_COORD => DRAW_TILE_COORD
    );

tc1 : touch_controller
port map (
    CLK => CLK,
    START => TOUCH_UPDATE,
    MISO => MISO,
    MOSI => MOSI,
    SCK => SCK,
    CS => CS,
    BUTTON => BUTTON);

gl : game_logic
port map (
    BUTTON => BUTTON,
    GAME_STATE => GAME_STATE,
    NEXT_GAME_STATE => GAME_STATE_INT);

t1 : tiled_logic
port map (
    CLK => CLK,
    LOGIC_UPDATE => LOGIC_UPDATE,
    BUTTON => BUTTON,
    GAME_STATE => GAME_STATE_INT,
    NEXT_GAME_STATE => NEXT_GAME_STATE,
    TILE_STATE => TILE_STATE,    
    OUT_TILE_STATE => NEW_TILE_STATE,
    READ_TILE_ADDR => READ_TILE_ADDR,
    WRITE_TILE_ADDR => WRITE_TILE_ADDR,
    WRITE_TILE_STATE => WRITE_TILE_STATE,
    LOGIC_COMPLETE => TILE_LOGIC_COMPLETE
);

current_tile_state_map : tile_state_map_ram
port map (
    CLK => CLK,
    ADDR => TILE_STATE_ADDR,
    CE => TILE_CE,
    WE => TILE_WE,
    IN_STATE => TILE_STATE_INT2,
    OUT_STATE => TILE_STATE);

next_tile_state_map : tile_state_map_ram
port map (
    CLK => CLK,
    ADDR => NEXT_TILE_STATE_ADDR,
    CE => TILE_CE,
    WE => NEXT_TILE_WE,
    IN_STATE => NEW_TILE_STATE,
    OUT_STATE => TILE_STATE_INT);
--component tile_state_map_rom is
--        Port ( CLK : in STD_LOGIC;
--               ADDR : in tile_address;
--               CE : in STD_LOGIC;
--               OUT_TILE_STATE : out tile_state_vector);
--    end component;
level0_map_rom : tile_state_map_rom
port map (
    CLK => CLK,
    ADDR => NEXT_TILE_STATE_ADDR,
    CE => TILE_CE,
    OUT_TILE_STATE => TILE_STATE_LEVEL0);
    
GND <= '0';
BL_EN <= '1';              
R <= RGB_PIXEL(23 downto 16);
G <= RGB_PIXEL(15 downto 10);
B_HIGH <= RGB_PIXEL(7 downto 4);
B_LOW <= RGB_PIXEL(1 downto 0);

-- get tile_state_address, tile_state will take 1 clock to be read
process(TILE_COORD, DRAW_TILE_COORD, LOGIC_UPDATING, STATE_UPDATING, DRAWING, WRITE_TILE_STATE,
        WRITE_TILE_ADDR, READ_TILE_ADDR,
        next_update_tile_state_addr, update_tile_state_addr)
variable temp_x : std_logic_vector(4 downto 0);
variable temp_y : std_logic_vector(4 downto 0);
variable temp_addr : tile_address;
begin        
    if LOGIC_UPDATING or STATE_UPDATING or DRAWING = '1' then
        TILE_CE <= '1';        
    else
        TILE_CE <= '0';
    end if;            
   
    if STATE_UPDATING then
        NEXT_TILE_WE <= '0';
        TILE_WE <= '1';
    elsif WRITE_TILE_STATE then
        NEXT_TILE_WE <= '1';        
        TILE_WE <= '0';
    else
        NEXT_TILE_WE <= '0';
        TILE_WE <= '0';
    end if;
               
    if STATE_UPDATING then    
        NEXT_TILE_STATE_ADDR <= std_logic_vector(to_unsigned(next_update_tile_state_addr,10));
    elsif LOGIC_UPDATING then
        NEXT_TILE_STATE_ADDR <= WRITE_TILE_ADDR;         
    else
        NEXT_TILE_STATE_ADDR <= (others => '0');
    end if;
    
    if STATE_UPDATING then        
        TILE_STATE_ADDR <= std_logic_vector(to_unsigned(update_tile_state_addr,10));
    elsif DRAWING='1' then -- drawing
        temp_x := std_logic_vector(to_unsigned(DRAW_TILE_COORD.x, 5));
        temp_y := std_logic_vector(to_unsigned(DRAW_TILE_COORD.y, 5));
        temp_addr := temp_y & temp_x;
        TILE_STATE_ADDR <= temp_addr;            
    elsif LOGIC_UPDATING then
        TILE_STATE_ADDR <= READ_TILE_ADDR;
    else
        TILE_STATE_ADDR <= (others => '0');
    end if;
end process;

-- logic update process
-- game logic handles global state chanes
-- tiled logic handles individual tile state changes
-- => 'tile rams' for different state_vectors (e.g. explosion, collision, walls e.t.c)
-- => counter to iterate through tiles for each logic update
-- => state update copies NEXT_TILE_STATE (rams) to TILE_STATE rams

-- logic update counters
process(CLK) is
begin
    if CLK'event and CLK='1' then        
        if LOGIC_UPDATE='1' then            
            LOGIC_UPDATING <= true;
        elsif LOGIC_UPDATING then
            if TILE_LOGIC_COMPLETE then
                LOGIC_UPDATING <= false;
            end if;
        end if;
    end if;
end process;

update_state_proc: 
process(CLK) is
begin
    if CLK'event and CLK='1' then
        UPDATE_STATE <= NEXT_UPDATE_STATE;    
    end if;
end process;

update_state_transition: 
process (UPDATE_STATE, STATE_UPDATE, update_tile_state_addr) is
begin
    case UPDATE_STATE is
        when idle =>
            if STATE_UPDATE='1' then
                NEXT_UPDATE_STATE <= main_update;
            else
                NEXT_UPDATE_STATE <= idle;
            end if;
        when main_update =>
            NEXT_UPDATE_STATE <= tile_update;
        when tile_update =>
            if update_tile_state_addr = (MAX_MAP_SIZE.HEIGHT * MAX_MAP_SIZE.WIDTH)-1 then                
                NEXT_UPDATE_STATE <= idle;
            else
                NEXT_UPDATE_STATE <= tile_update;
            end if;
        when others =>
            NEXT_UPDATE_STATE <= idle;
    end case;
end process;

process(GAME_STATUS) is
begin
    if GAME_STATUS = loading then
        -- can add check for GAME_STATE.LEVEL                
        TILE_STATE_INT2 <= TILE_STATE_LEVEL0;
    else
        TILE_STATE_INT2 <= TILE_STATE_INT;
    end if;
end process;

process (CLK) is
begin
if CLK'event and CLK='1' then
    case UPDATE_STATE is
        when idle =>
            STATE_UPDATING <= false;
            update_tile_state_addr <= 0;
            next_update_tile_state_addr <= 0;
        when main_update =>
            STATE_UPDATING <= true;
            if GAME_STATUS = loading then
                GAME_STATE <= INITIAL_STATE;
                GAME_STATE.POWERUPS <= NEXT_GAME_STATE.POWERUPS; -- powerups persist after loading
            else
                GAME_STATE <= NEXT_GAME_STATE;
            end if;
        when tile_update =>            
            --re ad from next_tile_state_ram : 2 clk latency
            --write to tile_state_ram (i.e. copy next state to current state).            
            if next_update_tile_state_addr < (MAX_MAP_SIZE.HEIGHT * MAX_MAP_SIZE.WIDTH)-1 then
                next_update_tile_state_addr <= next_update_tile_state_addr + 1;
            end if;
            if next_update_tile_state_addr >= 2 and update_tile_state_addr < (MAX_MAP_SIZE.HEIGHT * MAX_MAP_SIZE.WIDTH)-1 then       
                update_tile_state_addr <= update_tile_state_addr + 1;
            end if;            
        when others =>
            STATE_UPDATING <= false;
            update_tile_state_addr <= 0;
            next_update_tile_state_addr <= 0;
    end case;
end if;
end process;

-- game status = load new level, in game or finished level
process (GAME_STATUS) is
begin
    case GAME_STATUS is
        when loading =>
            NEXT_GAME_STATUS <= in_level;
        when in_level =>
            if GAME_STATE.LOAD_LEVEL then
                NEXT_GAME_STATUS <= loading;
            else
                NEXT_GAME_STATUS <= in_level;
            end if;
        when finished =>
            NEXT_GAME_STATUS <= loading;
    end case;
end process;

process (CLK) is
begin
if CLK'event and CLK='1' then
    if TILE_LOGIC_COMPLETE then
        GAME_STATUS <= NEXT_GAME_STATUS;
    end if;                
end if;
end process;

end Behavioral;

