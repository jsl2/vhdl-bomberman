library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.graphics_pkg.all;
use work.levels_pkg.all;
use work.touch_pkg.all;
use work.state_pkg.all;
use work.tile_state_pkg.all;
use work.bombs_pkg.all;

entity ppu is
    Port ( CLK : in STD_LOGIC;
           RST : in STD_LOGIC;
           PIX_CE : in STD_LOGIC;
           RASTER_POS : in point;           
           RASTER_PIXEL : in integer range 0 to (SCREEN_HEIGHT*SCREEN_WIDTH - 1);
           RGB_PIXEL : out rgb_pixel_type;
           GAME_STATE : in state_vector;
           TILE_STATE : in tile_state_vector;
           DRAW_TILE_COORD : out tile_point);
end ppu;

architecture Behavioral of ppu is

component ui_bg is
    Port ( CLK : in STD_LOGIC;         
           ADDR : in integer range 0 to (2**17 - 1);
           PIX_CE : in STD_LOGIC;
           PIXEL : out pixel_type);
end component;    

component bomberman is
    Port ( CLK : in STD_LOGIC;           
           DRAW_POS : in point;
           COORD : in point;
           DIR : in direction;
           FRAME : in integer range 0 to 31;
           DYING : in boolean;
           PVALID : out boolean;           
           PIXEL : out pixel_type);
end component;

component background_map is
    Port ( CLK : in STD_LOGIC;
           PIX_CE : in STD_LOGIC;
           TILE_COORD : in tile_point;
           OFFSET : in bitmap_offset;
           LEVEL : in integer range 0 to LEVELS_COUNT;
           PVALID : out boolean;
           PIXEL : out pixel_type);
end component;

component bombs is
    Port ( CLK : in STD_LOGIC;
           TILE_COORD : in tile_point;
           OFFSET : in bitmap_offset;
           BOMB : in bomb_state_vector;
           PVALID : out boolean;           
           PIXEL : out pixel_type);
end component;

component explosions is
    Port ( CLK : in STD_LOGIC;
           CE : in STD_LOGIC;
           TILE_COORD : in tile_point;
           OFFSET : in bitmap_offset;
           EXPLOSION : in explosion_state_vector;
           PVALID : out boolean;           
           PIXEL : out pixel_type);
end component;

component walls is
    Port ( CLK : in STD_LOGIC;
           CE : in STD_LOGIC;
           TILE_COORD : in tile_point;
           OFFSET : in bitmap_offset;
           WALL : in wall_state_vector;
           PVALID : out boolean;           
           PIXEL : out pixel_type);
end component;

component enemies is
    Port ( CLK : in STD_LOGIC;
           CE : in STD_LOGIC;
           DRAW_POS : in point;
           ENEMIES : in enemy_states;
           PVALID : out boolean;
           FLASH : out boolean;           
           PIXEL : out pixel_type);
end component;

component scoreboard is
    Port ( DRAW_POS : in point;
           POWERUPS : in powerups_state;
           PVALID : out boolean;           
           PIXEL : out pixel_type);
end component;

component powerup is
    Port ( CLK : in STD_LOGIC;
           CE : in STD_LOGIC;
           TILE_COORD : in tile_point;
           OFFSET : in bitmap_offset;
           POWERUP_STATE : in powerup_state_vector;
           PVALID : out boolean;           
           PIXEL : out pixel_type);
end component;


signal BG_PIXEL : pixel_type;
signal PIXEL : pixel_type;
signal VP_RASTER_POS : point;
signal SCORE_RASTER_POS : point;
signal DRAW_POS : point;
signal TILE_COORD : tile_point;
signal OFFSET : bitmap_offset;

signal TILE_STATE_CE : std_logic;

signal BOMBERMAN_PVALID : boolean;
signal BOMBERMAN_PIXEL : pixel_type;
signal MAP_PVALID : boolean;
signal MAP_PIXEL : pixel_type;
signal BOMBS_PVALID : boolean;
signal BOMBS_PIXEL : pixel_type;
signal EXPLOSIONS_PVALID : boolean;
signal EXPLOSIONS_PIXEL : pixel_type;
signal WALLS_PVALID : boolean;
signal WALLS_PIXEL : pixel_type;
signal ENEMIES_PVALID : boolean;
signal ENEMIES_PIXEL : pixel_type;
signal ENEMIES_FLASH : boolean;
signal SCOREBOARD_PVALID : boolean;
signal SCOREBOARD_PIXEL : pixel_type;
signal POWERUP_PVALID : boolean;
signal POWERUP_PIXEL : pixel_type;

begin

ui1 : ui_bg
port map (
    CLK => CLK,
    PIX_CE => PIX_CE,
    ADDR => RASTER_PIXEL,
    PIXEL => BG_PIXEL);
    
bomberman1 : bomberman
port map (
    CLK => CLK,
    DRAW_POS => DRAW_POS,
    COORD => GAME_STATE.BOMBERMAN.COORD,
    DYING => GAME_STATE.BOMBERMAN.DYING,
    DIR => GAME_STATE.BOMBERMAN.DIR,
    FRAME => GAME_STATE.BOMBERMAN.FRAME,
    PVALID => BOMBERMAN_PVALID,
    PIXEL => BOMBERMAN_PIXEL);

map1 : background_map
port map (
    CLK => CLK,        
    PIX_CE => PIX_CE,                                       
    TILE_COORD => TILE_COORD,
    OFFSET => OFFSET,   
    LEVEL => GAME_STATE.LEVEL,
    PVALID => MAP_PVALID,
    PIXEL => MAP_PIXEL); 
bombs1 : bombs
port map (
    CLK => CLK,
    TILE_COORD => TILE_COORD,
    OFFSET => OFFSET,
    BOMB => TILE_STATE.BOMB,
    PVALID => BOMBS_PVALID,
    PIXEL => BOMBS_PIXEL);
explosion1 : explosions
port map (
    CLK => CLK,
    CE => PIX_CE,
    TILE_COORD => TILE_COORD,
    OFFSET => OFFSET,
    EXPLOSION => TILE_STATE.EXPLOSION,
    PVALID => EXPLOSIONS_PVALID,
    PIXEL => EXPLOSIONS_PIXEL);  
wall1 : walls
port map (
    CLK => CLK,
    CE => PIX_CE,
    TILE_COORD => TILE_COORD,
    OFFSET => OFFSET,
    WALL => TILE_STATE.WALL,
    PVALID => WALLS_PVALID,
    PIXEL => WALLS_PIXEL);  
enemy1 : enemies
port map (
    CLK => CLK,
    CE => PIX_CE,
    DRAW_POS => DRAW_POS,
    ENEMIES => GAME_STATE.ENEMIES,
    PVALID => ENEMIES_PVALID,
    FLASH => ENEMIES_FLASH,
    PIXEL => ENEMIES_PIXEL);
scoreboard1 : scoreboard
port map (
    DRAW_POS => SCORE_RASTER_POS,
    POWERUPS => GAME_STATE.POWERUPS,
    PVALID => SCOREBOARD_PVALID,
    PIXEL => SCOREBOARD_PIXEL);
powerup1 : powerup
port map (
    CLK => CLK,
    CE => PIX_CE,
    TILE_COORD => TILE_COORD,
    OFFSET => OFFSET,
    POWERUP_STATE => TILE_STATE.POWERUP,
    PVALID => POWERUP_PVALID,
    PIXEL => POWERUP_PIXEL);  
        
process (RASTER_POS) is
begin
    if is_viewport(RASTER_POS) then
        VP_RASTER_POS <= raster_pos_to_viewport_raster_pos(RASTER_POS);
    else
        VP_RASTER_POS <= (x => COORDINATE_VALUE_MAX, y => COORDINATE_VALUE_MAX);
    end if;
end process;

process (RASTER_POS) is
begin
    if is_scoreboard(RASTER_POS) then
        SCORE_RASTER_POS <= raster_pos_to_scoreboard_raster_pos(RASTER_POS);
    else
        SCORE_RASTER_POS <= (x => COORDINATE_VALUE_MAX, y => COORDINATE_VALUE_MAX);
    end if;
end process;

process (CLK) is
begin
if CLK'event and CLK='1' then
    DRAW_POS <= VP_RASTER_POS + GAME_STATE.VIEWPORT_COORD;
end if;
end process;

process (VP_RASTER_POS, GAME_STATE.VIEWPORT_COORD, TILE_COORD) is
    variable draw_pos : point;
    variable x_temp : std_logic_vector(COORDINATE_BITS-1 downto 0);
    variable y_temp : std_logic_vector(COORDINATE_BITS-1 downto 0);
begin
    draw_pos := VP_RASTER_POS + GAME_STATE.VIEWPORT_COORD;
    x_temp := std_logic_vector(to_unsigned(draw_pos.x,COORDINATE_BITS));    
    y_temp := std_logic_vector(to_unsigned(draw_pos.y,COORDINATE_BITS));
    TILE_COORD.x <= to_integer(unsigned(x_temp(11 downto 4)));
    TILE_COORD.y <= to_integer(unsigned(y_temp(11 downto 4)));
    OFFSET.x <= to_integer(unsigned(x_temp(3 downto 0)));
    OFFSET.y <= to_integer(unsigned(y_temp(3 downto 0)));
    DRAW_TILE_COORD <= TILE_COORD;
end process;

process (CLK) is
    variable state_valid : boolean;
begin
    if CLK'event and CLK='1' then
        if PIX_CE = '1' then
            TILE_STATE_CE <= '0';
            state_valid := false;
        elsif state_valid = false then
            TILE_STATE_CE <= '1';
            state_valid := true;
        else                
            TILE_STATE_CE <= '0';
        end if;
    end if;
end process;
            
process (CLK) is
begin
    if CLK'event and CLK='1' then
        if is_viewport(RASTER_POS) then
            if BOMBERMAN_PVALID and BOMBERMAN_PIXEL /= TRANSPARENT_PIXEL then
                PIXEL <= BOMBERMAN_PIXEL; 
            elsif BOMBS_PVALID and BOMBS_PIXEL /= TRANSPARENT_PIXEL then
                PIXEL <= BOMBS_PIXEL;            
            elsif ENEMIES_PVALID and ENEMIES_PIXEL /= TRANSPARENT_PIXEL then
                if ENEMIES_FLASH then   
                    PIXEL <= WHITE_PIXEL;
                else
                    PIXEL <= ENEMIES_PIXEL;
                end if;
            elsif EXPLOSIONS_PVALID and EXPLOSIONS_PIXEL /= TRANSPARENT_PIXEL then
                PIXEL <= EXPLOSIONS_PIXEL;
            elsif WALLS_PVALID then
                PIXEL <= WALLS_PIXEL; 
            elsif POWERUP_PVALID then
                PIXEL <= POWERUP_PIXEL;                            
            elsif MAP_PVALID then
                PIXEL <= MAP_PIXEL;
            else
                PIXEL <= TRANSPARENT_PIXEL;
            end if;
        elsif is_scoreboard(RASTER_POS) then
            if SCOREBOARD_PVALID and SCOREBOARD_PIXEL /= TRANSPARENT_PIXEL then
                PIXEL <= SCOREBOARD_PIXEL;
            else
                PIXEL <= BG_PIXEL;
            end if;
        else  
        --if BG_PIXEL /= TRANSPARENT_PIXEL then               
            PIXEL <= BG_PIXEL;                
        end if;
    end if;
end process;    

with PIXEL select
    RGB_PIXEL <= X"000000" when X"00",
               X"FF00FF" when X"01",
               X"A80018" when X"02",
               X"0060F8" when X"03",
               X"9850C0" when X"04",
               X"000050" when X"05",
               X"0000A0" when X"06",
               X"B89200" when X"07",
               X"A04060" when X"08",
               X"A8E8F8" when X"09",
               X"406038" when X"0A",
               X"300808" when X"0B",
               X"98C0E8" when X"0C",
               X"286088" when X"0D",
               X"A78863" when X"0E",
               X"4F8040" when X"0F",
               X"A86818" when X"10",
               X"E080A0" when X"11",
               X"697997" when X"12",
               X"600000" when X"13",
               X"40A8F8" when X"14",
               X"088860" when X"15",
               X"988070" when X"16",
               X"301030" when X"17",
               X"A0E890" when X"18",
               X"1870B8" when X"19",
               X"203898" when X"1A",
               X"181818" when X"1B",
               X"AA4500" when X"1C",
               X"285800" when X"1D",
               X"F88E06" when X"1E",
               X"F8DA43" when X"1F",
               X"609080" when X"20",
               X"E0E0E0" when X"21",
               X"F85800" when X"22",
               X"405258" when X"23",
               X"E8D890" when X"24",
               X"60C8A8" when X"25",
               X"C8A0D8" when X"26",
               X"1165F4" when X"27",
               X"003880" when X"28",
               X"8A2002" when X"29",
               X"F8C800" when X"2A",
               X"B02840" when X"2B",
               X"702890" when X"2C",
               X"A8A8A8" when X"2D",
               X"F8F8F8" when X"2E",
               X"082060" when X"2F",
               X"E0F8E0" when X"30",
               X"F8B890" when X"31",
               X"68E0F8" when X"32",
               X"383838" when X"33",
               X"688830" when X"34",
               X"906850" when X"35",
               X"5060D8" when X"36",
               X"D87098" when X"37",
               X"E80800" when X"38",
               X"F89860" when X"39",
               X"005828" when X"3A",
               X"282828" when X"3B",
               X"080808" when X"3C",
               X"28A888" when X"3D",
               X"B88828" when X"3E",
               X"386078" when X"3F",
               X"C06080" when X"40",
               X"67A758" when X"41",
               X"4078C0" when X"42",
               X"407868" when X"43",
               X"C05820" when X"44",
               X"C8B8A0" when X"45",
               X"F67820" when X"46",
               X"603020" when X"47",
               X"F7282D" when X"48",
               X"E0B078" when X"49",
               X"F0A830" when X"4A",
               X"55B9EE" when X"4B",
               X"989898" when X"4C",
               X"1898D8" when X"4D",
               X"CF3700" when X"4E",
               X"F7C72D" when X"4F",
               X"705030" when X"50",
               X"288028" when X"51",
               X"F0B0C8" when X"52",
               X"183040" when X"53",
               X"401860" when X"54",
               X"7F0000" when X"55",
               X"483000" when X"56",
               X"F8D878" when X"57",
               X"201038" when X"58",
               X"907838" when X"59",
               X"C84088" when X"5A",
               X"E8D0B0" when X"5B",
               X"B0B010" when X"5C",
               X"104008" when X"5D",
               X"F8C8E0" when X"5E",
               X"5890C0" when X"5F",
               X"785080" when X"60",
               X"284050" when X"61",
               X"369F5B" when X"62",
               X"787878" when X"63",
               X"E00050" when X"64",
               X"D00800" when X"65",
               X"803E06" when X"66",
               X"781018" when X"67",
               X"D0B0F8" when X"68",
               X"888888" when X"69",
               X"606060" when X"6A",
               X"F8D800" when X"6B",
               X"F0B800" when X"6C",
               X"603080" when X"6D",
               X"B08000" when X"6E",
               X"F82800" when X"6F",
               X"F04870" when X"70",
               X"0000F0" when X"71",
               X"E88008" when X"72",
               X"40B8E8" when X"73",
               X"505050" when X"74",
               X"175097" when X"75",
               X"B83020" when X"76",
               X"083858" when X"77",
               X"E0C050" when X"78",
               X"104068" when X"79",
               X"000010" when X"7A",
               X"58C8F8" when X"7B",
               X"8040B8" when X"7C",
               X"101010" when X"7D",
               X"490000" when X"7E",
               X"102828" when X"7F",
               X"8BD2EA" when X"80",
               X"A88060" when X"81",
               X"F05840" when X"82",
               X"402010" when X"83",
               X"404040" when X"84",
               X"F7D8B0" when X"85",
               X"655500" when X"86",
               X"E89838" when X"87",
               X"882820" when X"88",
               X"C090E0" when X"89",
               X"F8F858" when X"8A",
               X"F5181A" when X"8B",
               X"789080" when X"8C",
               X"E8C088" when X"8D",
               X"A8D070" when X"8E",
               X"F8E8A0" when X"8F",
               X"A068D8" when X"90",
               X"F8C810" when X"91",
               X"8860A0" when X"92",
               X"605048" when X"93",
               X"B80000" when X"94",
               X"900020" when X"95",
               X"481008" when X"96",
               X"E08810" when X"97",
               X"402858" when X"98",
               X"F8B000" when X"99",
               X"C7C7C8" when X"9A",
               X"C86808" when X"9B",
               X"884020" when X"9C",
               X"F88898" when X"9D",
               X"506880" when X"9E",
               X"D8B810" when X"9F",
               X"60B8F8" when X"A0",
               X"408018" when X"A1",
               X"F87800" when X"A2",
               X"503010" when X"A3",
               X"F8E8D0" when X"A4",
               X"B0B0B0" when X"A5",
               X"07284F" when X"A6",
               X"6E91EC" when X"A7",
               X"F8F088" when X"A8",
               X"608040" when X"A9",
               X"3050A0" when X"AA",
               X"001028" when X"AB",
               X"C09868" when X"AC",
               X"381818" when X"AD",
               X"F07840" when X"AE",
               X"C02018" when X"AF",
               X"584832" when X"B0",
               X"88A090" when X"B1",
               X"0000B8" when X"B2",
               X"B02860" when X"B3",
               X"501000" when X"B4",
               X"683800" when X"B5",
               X"505858" when X"B6",
               X"F89078" when X"B7",
               X"F84700" when X"B8",
               X"F0A000" when X"B9",
               X"384858" when X"BA",
               X"D89000" when X"BB",
               X"2090E8" when X"BC",
               X"800800" when X"BD",
               X"D0F800" when X"BE",
               X"287898" when X"BF",
               X"D7B092" when X"C0",
               X"D07000" when X"C1",
               X"B03030" when X"C2",
               X"B070C8" when X"C3",
               X"902018" when X"C4",
               X"481808" when X"C5",
               X"203838" when X"C6",
               X"CCD0D0" when X"C7",
               X"485028" when X"C8",
               X"F8F038" when X"C9",
               X"B84800" when X"CA",
               X"6F0206" when X"CB",
               X"F0E8E0" when X"CC",
               X"183020" when X"CD",
               X"905000" when X"CE",
               X"00F800" when X"CF",
               X"608828" when X"D0",
               X"F8C858" when X"D1",
               X"F80000" when X"D2",
               X"000060" when X"D3",
               X"C0A038" when X"D4",
               X"E0C505" when X"D5",
               X"80E8F8" when X"D6",
               X"F86800" when X"D7",
               X"0070F8" when X"D8",
               X"E890A8" when X"D9",
               X"F8C8A0" when X"DA",
               X"A07020" when X"DB",
               X"DDAD35" when X"DC",
               X"484848" when X"DD",
               X"F8F890" when X"DE",
               X"F8E880" when X"DF",
               X"D05820" when X"E0",
               X"F8D018" when X"E1",
               X"583512" when X"E2",
               X"F8E807" when X"E3",
               X"181020" when X"E4",
               X"F8F7E0" when X"E5",
               X"880000" when X"E6",
               X"184018" when X"E7",
               X"583000" when X"E8",
               X"40D8F0" when X"E9",
               X"2870C0" when X"EA",
               X"D01000" when X"EB",
               X"C8F0F8" when X"EC",
               X"102850" when X"ED",
               X"B8B8B8" when X"EE",
               X"585850" when X"EF",
               X"203878" when X"F0",
               X"C8A878" when X"F1",
               X"703000" when X"F2",
               X"F84028" when X"F3",
               X"F8A828" when X"F4",
               X"48A850" when X"F5",
               X"481860" when X"F6",
               X"90A0A8" when X"F7",
               X"88E0F8" when X"F8",
               X"F8F87E" when X"F9",
               X"E8D000" when X"FA",
               X"F8C030" when X"FB",
               X"2890D8" when X"FC",
               X"A87820" when X"FD",
               X"C00000" when X"FE",
               X"F8E870" when X"FF",
               X"FF00FF" when others;

end Behavioral;