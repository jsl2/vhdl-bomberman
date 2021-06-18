library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.graphics_pkg.all;
use work.state_pkg.all;
use work.bombs_pkg.all;
use work.tile_state_pkg.all;
use work.maps_pkg.all;
use work.levels_pkg.all;
use work.touch_pkg.all;
use work.enemies_pkg.all;

entity tiled_logic is
    Port ( CLK : in std_logic;
           LOGIC_UPDATE : in std_logic;
           BUTTON : in button_state;
           GAME_STATE : in state_vector;                                      
           NEXT_GAME_STATE : out state_vector := initial_state;
           TILE_STATE : in tile_state_vector;           
           OUT_TILE_STATE : out tile_state_vector;
           READ_TILE_ADDR : out tile_address;
           WRITE_TILE_ADDR : out tile_address;
           WRITE_TILE_STATE : out boolean;
           LOGIC_COMPLETE : out boolean);
end tiled_logic;

architecture Behavioral of tiled_logic is
    type TILE_LOGIC_STATES is (idle, init, tile_loop, 
                               explosion_up, explosion_right, explosion_down, explosion_left, explosion_orig, 
                               explosion_up_start, explosion_right_start, explosion_down_start, explosion_left_start, complete);
    signal EXPLOSION_COUNTER : integer range 0 to 31;
    
    signal STATE : TILE_LOGIC_STATES;
    signal NEXT_STATE : TILE_LOGIC_STATES;
    signal NEXT_GAME_STATE_INT : state_vector;
    signal WRITE_TILE_STATE_INT : boolean;
    
    signal READ_COORD : tile_point := (0,0);
    signal WRITE_COORD : tile_point := (0,0);      
begin

-- bomb process
process(TILE_STATE.BOMB, WRITE_COORD, BUTTON, GAME_STATE, NEXT_GAME_STATE_INT.BOMBERMAN.TILE_COORD) is
begin         
    OUT_TILE_STATE.BOMB <= TILE_STATE.BOMB;
    
    if TILE_STATE.BOMB.ACTIVE then
        -- is animation over?
        if (TILE_STATE.BOMB.FRAME = 9  and TILE_STATE.BOMB.COUNTER = 23) or TILE_STATE.EXPLOSION.ACTIVE then                
            OUT_TILE_STATE.BOMB <= INITIAL_BOMB_STATE;                
        elsif TILE_STATE.BOMB.COUNTER = 23 then
            OUT_TILE_STATE.BOMB.COUNTER <= 0;
            OUT_TILE_STATE.BOMB.FRAME <= TILE_STATE.BOMB.FRAME + 1;
        else
            OUT_TILE_STATE.BOMB.COUNTER <= TILE_STATE.BOMB.COUNTER + 1;
        end if;        
    elsif BUTTON = bomb and (not GAME_STATE.BOMBERMAN.DYING) and GAME_STATE.BOMB_COUNT < GAME_STATE.POWERUPS.BOMB_LIMIT then        
        if WRITE_COORD = NEXT_GAME_STATE_INT.BOMBERMAN.TILE_COORD then
            OUT_TILE_STATE.BOMB.ACTIVE <= true;
        end if;
    end if;            
end process;

-- powerup process
process(TILE_STATE.POWERUP) is
begin
    OUT_TILE_STATE.POWERUP <= TILE_STATE.POWERUP;
    if TILE_STATE.POWERUP.ACTIVE and WRITE_COORD = NEXT_GAME_STATE_INT.BOMBERMAN.TILE_COORD then
        OUT_TILE_STATE.POWERUP.ACTIVE <= false;
    end if;
end process;

-- wall & explosion process
process(TILE_STATE.BOMB, TILE_STATE.EXPLOSION, WRITE_COORD, BUTTON, GAME_STATE, STATE, EXPLOSION_COUNTER) is
begin
    OUT_TILE_STATE.WALL <= TILE_STATE.WALL;
    OUT_TILE_STATE.EXPLOSION <= TILE_STATE.EXPLOSION;
    
    
    if TILE_STATE.WALL.CRUMBLING then
        -- animate crumbling
        if TILE_STATE.WALL.FRAME = 5 and TILE_STATE.WALL.COUNTER = 7 then
            OUT_TILE_STATE.WALL.CRUMBLING <= false;
        elsif TILE_STATE.WALL.COUNTER = 7 then
            OUT_TILE_STATE.WALL.FRAME <= TILE_STATE.WALL.FRAME + 1;
            OUT_TILE_STATE.WALL.COUNTER <= 0;
        else
            OUT_TILE_STATE.WALL.COUNTER <= TILE_STATE.WALL.COUNTER + 1;                        
        end if;
    end if;
    if TILE_STATE.EXPLOSION.ACTIVE <= true then
        if TILE_STATE.EXPLOSION.FRAME = 12 and TILE_STATE.EXPLOSION.GOTO_NEXT_FRAME then
            OUT_TILE_STATE.EXPLOSION.ACTIVE <= false;
        elsif TILE_STATE.EXPLOSION.GOTO_NEXT_FRAME then
            OUT_TILE_STATE.EXPLOSION.FRAME <= TILE_STATE.EXPLOSION.FRAME + 1;
            OUT_TILE_STATE.EXPLOSION.GOTO_NEXT_FRAME <= false;
        else
            OUT_TILE_STATE.EXPLOSION.GOTO_NEXT_FRAME <= true;
        end if;
    end if; 
    
    if TILE_STATE.BOMB.ACTIVE then
        if (TILE_STATE.BOMB.FRAME = 9 and TILE_STATE.BOMB.COUNTER = 23) or TILE_STATE.EXPLOSION.ACTIVE then
            OUT_TILE_STATE.EXPLOSION.ACTIVE <= true;
            OUT_TILE_STATE.EXPLOSION.ORIG <= true;
            OUT_TILE_STATE.EXPLOSION.FRAME <= 0;
            OUT_TILE_STATE.EXPLOSION.GOTO_NEXT_FRAME <= false;
        end if;
    end if;
    if STATE = explosion_up or STATE = explosion_down or STATE = explosion_right or STATE = explosion_left then        
        if GAME_STATE.COLLISION_MAP(WRITE_COORD.y,WRITE_COORD.x) = 1 and (not TILE_STATE.BOMB.ACTIVE) then
            if  not TILE_STATE.EXPLOSION.ACTIVE then
                OUT_TILE_STATE.EXPLOSION <= INITIAL_EXPLOSION_STATE;
                if TILE_STATE.WALL.ACTIVE then                
                    OUT_TILE_STATE.WALL.CRUMBLING <= true;                
                end if;
                OUT_TILE_STATE.WALL.ACTIVE <= false;
            end if;                
        else
            OUT_TILE_STATE.WALL.ACTIVE <= false;
            if not TILE_STATE.EXPLOSION.ACTIVE then                           
                OUT_TILE_STATE.EXPLOSION.ACTIVE <= true;
                OUT_TILE_STATE.EXPLOSION.ORIG <= false;
                OUT_TILE_STATE.EXPLOSION.FRAME <= 0;
                OUT_TILE_STATE.EXPLOSION.GOTO_NEXT_FRAME <= false;
                
                OUT_TILE_STATE.EXPLOSION.EDGE <= EXPLOSION_COUNTER = GAME_STATE.POWERUPS.BLAST_RADIUS;
        
                if STATE = explosion_up then
                    OUT_TILE_STATE.EXPLOSION.DIR <= up;
                elsif STATE = explosion_down then
                    OUT_TILE_STATE.EXPLOSION.DIR <= down;
                elsif STATE = explosion_left then
                    OUT_TILE_STATE.EXPLOSION.DIR <= left;
                elsif STATE = explosion_right then
                    OUT_TILE_STATE.EXPLOSION.DIR <= right;
                end if;
            else
                OUT_TILE_STATE.EXPLOSION.EDGE <= false;
            end if;    
        end if;
    end if;
end process;



-- tile logic fsm
tile_state_proc: 
process(CLK) is
begin
if CLK'event and CLK='1' then
    STATE <= NEXT_STATE;    
end if;
end process;

tile_state_transition: 
process(STATE, LOGIC_UPDATE, GAME_STATE, WRITE_COORD, TILE_STATE, EXPLOSION_COUNTER) is
begin
case STATE is
    when idle =>
        if LOGIC_UPDATE = '1' then
            NEXT_STATE <= init;
        else
            NEXT_STATE <= idle;
        end if;
    when init =>
        NEXT_STATE <= tile_loop;
    when tile_loop =>
        if (WRITE_COORD.x = LEVEL_DATA(GAME_STATE.LEVEL).MAP_SIZE.WIDTH - 1) and
           (WRITE_COORD.y = LEVEL_DATA(GAME_STATE.LEVEL).MAP_SIZE.HEIGHT - 1) then
            NEXT_STATE <= complete;
        elsif (TILE_STATE.BOMB.ACTIVE and TILE_STATE.BOMB.FRAME = 9 and TILE_STATE.BOMB.COUNTER = 23) or
              (TILE_STATE.BOMB.ACTIVE and TILE_STATE.EXPLOSION.ACTIVE) then
            NEXT_STATE <= explosion_orig;
        else
            NEXT_STATE <= tile_loop;
        end if;
        -- if start explosion => go to start explosion state!
    when explosion_orig =>
        NEXT_STATE <= explosion_up_start;
    when explosion_up_start =>
        NEXT_STATE <= explosion_up;
    when explosion_up =>
        if WRITE_COORD.y = 0 or
           (GAME_STATE.COLLISION_MAP(WRITE_COORD.y, WRITE_COORD.x) = 1 and WRITE_TILE_STATE_INT) or 
           EXPLOSION_COUNTER = GAME_STATE.POWERUPS.BLAST_RADIUS then
            NEXT_STATE <= explosion_right_start;
        else
            NEXT_STATE <= explosion_up;
        end if;
    when explosion_right_start =>
        NEXT_STATE <= explosion_right;
    when explosion_right =>
        if WRITE_COORD.x = LEVEL_DATA(GAME_STATE.LEVEL).MAP_SIZE.WIDTH - 1 or 
           (GAME_STATE.COLLISION_MAP(WRITE_COORD.y, WRITE_COORD.x) = 1 and WRITE_TILE_STATE_INT) or
           EXPLOSION_COUNTER = GAME_STATE.POWERUPS.BLAST_RADIUS then
            NEXT_STATE <= explosion_down_start;
        else
            NEXT_STATE <= explosion_right;
        end if;
    when explosion_down_start =>
        NEXT_STATE <= explosion_down;
    when explosion_down =>
        if WRITE_COORD.y >= LEVEL_DATA(GAME_STATE.LEVEL).MAP_SIZE.HEIGHT - 1 or 
           (GAME_STATE.COLLISION_MAP(WRITE_COORD.y, WRITE_COORD.x) = 1 and WRITE_TILE_STATE_INT) or
           EXPLOSION_COUNTER = GAME_STATE.POWERUPS.BLAST_RADIUS then
            NEXT_STATE <= explosion_left_start;
        else
            NEXT_STATE <= explosion_down;
        end if;
    when explosion_left_start =>
        NEXT_STATE <= explosion_left;
    when explosion_left =>
        if WRITE_COORD.x = 0 or 
           (GAME_STATE.COLLISION_MAP(WRITE_COORD.y, WRITE_COORD.x) = 1 and WRITE_TILE_STATE_INT) or
           EXPLOSION_COUNTER = GAME_STATE.POWERUPS.BLAST_RADIUS then
            NEXT_STATE <= complete;
        else
            NEXT_STATE <= explosion_left;
        end if;   
    when complete =>
        NEXT_STATE <= idle;
    when others =>
        NEXT_STATE <= idle;            
end case;
if LOGIC_UPDATE = '1' then
    NEXT_STATE <= init;
end if;
end process;

-- game_state process
process(CLK) is
    variable bomb_count : integer range 0 to MAX_BOMBS-1;
begin
if CLK'event and CLK='1' then
    case STATE is
        when init =>
            NEXT_GAME_STATE_INT <= GAME_STATE;
            bomb_count := 0;
        when tile_loop =>
            if TILE_STATE.WALL.ACTIVE or TILE_STATE.BOMB.ACTIVE then                        
                NEXT_GAME_STATE_INT.COLLISION_MAP(WRITE_COORD.y, WRITE_COORD.x) <= 1;                                      
            else
                if GAME_STATE.ENEMY_COUNT = 0 and (WRITE_COORD = (12,3) or WRITE_COORD = (13,3)) then
                    NEXT_GAME_STATE_INT.COLLISION_MAP(WRITE_COORD.y, WRITE_COORD.x) <= 0;
                else    
                    NEXT_GAME_STATE_INT.COLLISION_MAP(WRITE_COORD.y, WRITE_COORD.x) <= LEVEL0_COLLISION_INITIAL(WRITE_COORD.y, WRITE_COORD.x);
                end if;               
            end if;
            
            if TILE_STATE.BOMB.ACTIVE then
                bomb_count := bomb_count + 1;
            end if;            
            
            for i in  0 to MAX_ENEMIES -1 loop                
                if TILE_STATE.EXPLOSION.ACTIVE and WRITE_COORD = GAME_STATE.ENEMIES(i).TILE_COORD then -- have we killed enemy?
                    if GAME_STATE.ENEMIES(i).ALIVE then
                        NEXT_GAME_STATE_INT.ENEMIES(i).ALIVE <= false;
                        NEXT_GAME_STATE_INT.ENEMIES(i).DYING <= true;
                        NEXT_GAME_STATE_INT.ENEMIES(i).COUNTER <= 0;
                        NEXT_GAME_STATE_INT.ENEMIES(i).FRAME <= 0;    
                        NEXT_GAME_STATE_INT.ENEMY_COUNT <= NEXT_GAME_STATE_INT.ENEMY_COUNT - 1;                    
                    end if;
                end if;
            end loop;
            
            if TILE_STATE.EXPLOSION.ACTIVE and WRITE_COORD = NEXT_GAME_STATE_INT.BOMBERMAN.TILE_COORD then           
                NEXT_GAME_STATE_INT.BOMBERMAN.DYING <= true;
                NEXT_GAME_STATE_INT.COUNTER <= 0;
                NEXT_GAME_STATE_INT.BOMBERMAN.FRAME <= 0;
            end if;
            
            if TILE_STATE.POWERUP.ACTIVE and WRITE_COORD = NEXT_GAME_STATE_INT.BOMBERMAN.TILE_COORD then
                case TILE_STATE.POWERUP.POWERUP_TYPE is
                    when bomb =>    
                        if GAME_STATE.POWERUPS.BOMB_LIMIT < MAX_BOMBS then                             
                            NEXT_GAME_STATE_INT.POWERUPS.BOMB_LIMIT <= GAME_STATE.POWERUPS.BOMB_LIMIT + 1;
                        end if;
                    when blast =>
                        if GAME_STATE.POWERUPS.BLAST_RADIUS < MAX_BLAST_RADIUS then
                            NEXT_GAME_STATE_INT.POWERUPS.BLAST_RADIUS <= GAME_STATE.POWERUPS.BLAST_RADIUS + 1;
                        end if;
                    when others =>
                end case;
            end if;
        when complete =>
            NEXT_GAME_STATE_INT.BOMB_COUNT <= bomb_count;
        when others =>
            
    end case;
end if;
end process;

-- fsm output
process(CLK) is
    variable read_loop_coord : tile_point := (0,0);
    variable prev_write_loop_coord : tile_point := (0,0);
    variable write_loop_coord : tile_point := (0,0);
    variable read_explosion_loop_coord : tile_point := (0,0);
    variable write_explosion_loop_coord :tile_point := (0,0);
    variable read_latency_count : integer range 0 to 2 := 0;
begin
if CLK'event and CLK='1' then
    case STATE is
        when init|idle =>
            read_loop_coord := (0,0);
            write_loop_coord := (0,0);
            READ_COORD <= (0,0);
            WRITE_COORD <= (0,0);
            WRITE_TILE_STATE_INT <= false;
            LOGIC_COMPLETE <= false;
        when tile_loop =>
            WRITE_TILE_STATE_INT <= false; 
            prev_write_loop_coord := write_loop_coord;                                                          
            if read_loop_coord.y /= 0  or read_loop_coord.x >= 2 then
                WRITE_TILE_STATE_INT <= true; 
                if write_loop_coord.x = LEVEL_DATA(GAME_STATE.LEVEL).MAP_SIZE.WIDTH - 1 then
                    if write_loop_coord.y < LEVEL_DATA(GAME_STATE.LEVEL).MAP_SIZE.WIDTH - 1 then
                        write_loop_coord.x := 0;
                        write_loop_coord.y := write_loop_coord.y + 1;
                    end if;
                else
                    write_loop_coord.x := write_loop_coord.x + 1;
                end if;
            end if;   
            
            if read_loop_coord.x = LEVEL_DATA(GAME_STATE.LEVEL).MAP_SIZE.WIDTH - 1 then                 
                if read_loop_coord.y < LEVEL_DATA(GAME_STATE.LEVEL).MAP_SIZE.HEIGHT - 1 then
                    read_loop_coord.x := 0;
                    read_loop_coord.y := read_loop_coord.y + 1;
                end if;
            else
                read_loop_coord.x := read_loop_coord.x + 1;
            end if;                                    
            READ_COORD <= read_loop_coord;
            WRITE_COORD <= write_loop_coord;
        when explosion_orig =>
            WRITE_TILE_STATE_INT <= false;
            write_loop_coord := prev_write_loop_coord; -- rollback
            WRITE_COORD <= prev_write_loop_coord;        
        when explosion_up_start | explosion_down_start | explosion_right_start | explosion_left_start =>
            WRITE_TILE_STATE_INT <= false;            
            read_latency_count := 0;      
            write_explosion_loop_coord := write_loop_coord;      
            read_explosion_loop_coord := write_loop_coord;
            WRITE_COORD <= write_loop_coord;
            EXPLOSION_COUNTER <= 0;
        when explosion_up =>
            WRITE_TILE_STATE_INT <= false;
            if read_latency_count = 2 and write_explosion_loop_coord.y > 0 then
                WRITE_TILE_STATE_INT <= true;
                write_explosion_loop_coord.y := write_explosion_loop_coord.y - 1;                
                EXPLOSION_COUNTER <= EXPLOSION_COUNTER + 1;
            end if;
            if read_explosion_loop_coord.y > 0 then
                read_explosion_loop_coord.y := read_explosion_loop_coord.y - 1;
                if read_latency_count < 2 then
                    read_latency_count := read_latency_count + 1;
                end if;
            end if;
            READ_COORD <= read_explosion_loop_coord;
            WRITE_COORD <= write_explosion_loop_coord;
        when explosion_down =>
            WRITE_TILE_STATE_INT <= false;
            if read_latency_count = 2 and write_explosion_loop_coord.y < LEVEL_DATA(GAME_STATE.LEVEL).MAP_SIZE.HEIGHT - 1 then
                WRITE_TILE_STATE_INT <= true;                
                write_explosion_loop_coord.y := write_explosion_loop_coord.y + 1;                
                EXPLOSION_COUNTER <= EXPLOSION_COUNTER + 1;
            end if;
            if read_explosion_loop_coord.y < LEVEL_DATA(GAME_STATE.LEVEL).MAP_SIZE.HEIGHT - 1 then
                read_explosion_loop_coord.y := read_explosion_loop_coord.y + 1;
                if read_latency_count < 2 then
                    read_latency_count := read_latency_count + 1;
                end if;
            elsif read_latency_count < 2 then
                EXPLOSION_COUNTER <= GAME_STATE.POWERUPS.BLAST_RADIUS; -- quick exit
            end if;
            READ_COORD <= read_explosion_loop_coord;
            WRITE_COORD <= write_explosion_loop_coord;
        when explosion_right =>
            WRITE_TILE_STATE_INT <= false;
            if read_latency_count = 2 and write_explosion_loop_coord.x < LEVEL_DATA(GAME_STATE.LEVEL).MAP_SIZE.WIDTH - 1 then
                WRITE_TILE_STATE_INT <= true;                
                write_explosion_loop_coord.x := write_explosion_loop_coord.x + 1;                
                EXPLOSION_COUNTER <= EXPLOSION_COUNTER + 1;
            end if;
            if read_explosion_loop_coord.y < LEVEL_DATA(GAME_STATE.LEVEL).MAP_SIZE.HEIGHT - 1 then
                read_explosion_loop_coord.x := read_explosion_loop_coord.x + 1;
                if read_latency_count < 2 then
                    read_latency_count := read_latency_count + 1;
                end if;
            end if;
            READ_COORD <= read_explosion_loop_coord;
            WRITE_COORD <= write_explosion_loop_coord;
        when explosion_left =>
            WRITE_TILE_STATE_INT <= false;
            if read_latency_count = 2 and write_explosion_loop_coord.x > 0 then
                WRITE_TILE_STATE_INT <= true;                
                write_explosion_loop_coord.x := write_explosion_loop_coord.x - 1;                
                EXPLOSION_COUNTER <= EXPLOSION_COUNTER + 1;
            end if;
            if read_explosion_loop_coord.x > 0 then
                read_explosion_loop_coord.x := read_explosion_loop_coord.x - 1;
                if read_latency_count < 2 then
                    read_latency_count := read_latency_count + 1;
                end if;
            end if;
            READ_COORD <= read_explosion_loop_coord;
            WRITE_COORD <= write_explosion_loop_coord;
        when complete => 
            WRITE_TILE_STATE_INT <= false;           
            LOGIC_COMPLETE <= true;    
    end case;
end if;
end process;

READ_TILE_ADDR <= std_logic_vector(to_unsigned(READ_COORD.y,5)) & std_logic_vector(to_unsigned(READ_COORD.x,5));
WRITE_TILE_ADDR <= std_logic_vector(to_unsigned(WRITE_COORD.y,5)) & std_logic_vector(to_unsigned(WRITE_COORD.x,5));

WRITE_TILE_STATE <= WRITE_TILE_STATE_INT;
NEXT_GAME_STATE <= NEXT_GAME_STATE_INT;

end Behavioral;
