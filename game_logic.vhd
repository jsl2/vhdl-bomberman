library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.bomberman_pkg.all;
use work.graphics_pkg.all;
use work.bombs_pkg.all;
use work.levels_pkg.all;
use work.state_pkg.all;
use work.touch_pkg.all;
use work.tileset_pkg.all;
use work.explosions_pkg.all;
use work.maps_pkg.all;
use work.enemies_pkg.all;

entity game_logic is
    Port ( BUTTON : in button_state;
           GAME_STATE : in state_vector;
           NEXT_GAME_STATE : out state_vector := initial_state);
end game_logic;

architecture Behavioral of game_logic is
    signal bomberman_tile_coord : tile_point;       
begin

process(GAME_STATE) is
    variable enemy_x_logic_vector : std_logic_vector(11 downto 0);
    variable enemy_y_logic_vector : std_logic_vector(11 downto 0);
    variable on_grid_x : boolean;
    variable on_grid_y : boolean;
    variable enemy_velocity : velocity;
begin

for i in 0 to MAX_ENEMIES - 1 loop
    NEXT_GAME_STATE.ENEMIES(i) <= GAME_STATE.ENEMIES(i);
    if GAME_STATE.ENEMIES(i).ALIVE then
        enemy_x_logic_vector := std_logic_vector(to_unsigned(GAME_STATE.ENEMIES(i).COORD.x,COORDINATE_BITS));
        enemy_y_logic_vector := std_logic_vector(to_unsigned(GAME_STATE.ENEMIES(i).COORD.y,COORDINATE_BITS));
        on_grid_x := enemy_x_logic_vector(3 downto 0) = X"0";
        on_grid_y := enemy_y_logic_vector(3 downto 0) = X"0";
        enemy_velocity := (0, 0);
        -- movement
        case GAME_STATE.ENEMIES(i).DIR is
            when left =>
                enemy_velocity := (-1, 0);            
                if on_grid_x and GAME_STATE.COLLISION_MAP(GAME_STATE.ENEMIES(i).TILE_COORD.y,GAME_STATE.ENEMIES(i).TILE_COORD.x-1) = 1 then
                    NEXT_GAME_STATE.ENEMIES(i).DIR <= right;
                end if;            
            when right =>
                enemy_velocity := (1, 0);            
                if on_grid_x and GAME_STATE.COLLISION_MAP(GAME_STATE.ENEMIES(i).TILE_COORD.y,GAME_STATE.ENEMIES(i).TILE_COORD.x+1) = 1 then
                    NEXT_GAME_STATE.ENEMIES(i).DIR <= left;
                end if;
            when up =>
                enemy_velocity := (0, -1);            
                if on_grid_y and GAME_STATE.COLLISION_MAP(GAME_STATE.ENEMIES(i).TILE_COORD.y-1,GAME_STATE.ENEMIES(i).TILE_COORD.x) = 1 then
                    NEXT_GAME_STATE.ENEMIES(i).DIR <= up;
                end if;
            when down =>
                enemy_velocity := (0, 1);            
                if on_grid_y and GAME_STATE.COLLISION_MAP(GAME_STATE.ENEMIES(i).TILE_COORD.y+1,GAME_STATE.ENEMIES(i).TILE_COORD.x) = 1 then
                    NEXT_GAME_STATE.ENEMIES(i).DIR <= down;
                end if;
        end case;
        
        NEXT_GAME_STATE.ENEMIES(i).COORD <= GAME_STATE.ENEMIES(i).COORD + enemy_velocity;
        enemy_x_logic_vector := std_logic_vector(to_unsigned(GAME_STATE.ENEMIES(i).COORD.x + enemy_velocity.x,COORDINATE_BITS));
        enemy_y_logic_vector := std_logic_vector(to_unsigned(GAME_STATE.ENEMIES(i).COORD.y + enemy_velocity.y,COORDINATE_BITS));
        NEXT_GAME_STATE.ENEMIES(i).TILE_COORD <= (to_integer(unsigned(enemy_x_logic_vector(11 downto 4))), to_integer(unsigned(enemy_y_logic_vector(11 downto 4)))+1);
        
        --animation    
        -- animate at 4Hz
        if GAME_STATE.ENEMIES(i).COUNTER = 14 then
            NEXT_GAME_STATE.ENEMIES(i).COUNTER <= 0;
            if GAME_STATE.ENEMIES(i).FRAME = 3 then 
                NEXT_GAME_STATE.ENEMIES(i).FRAME <= 0;
            else
                NEXT_GAME_STATE.ENEMIES(i).FRAME <= GAME_STATE.ENEMIES(i).FRAME + 1;
            end if;
        else
            NEXT_GAME_STATE.ENEMIES(i).COUNTER <= GAME_STATE.ENEMIES(i).COUNTER + 1;
        end if;        
    elsif GAME_STATE.ENEMIES(i).DYING then
        if GAME_STATE.ENEMIES(i).COUNTER = 15 then
            if GAME_STATE.ENEMIES(i).FRAME = 3 then                                
                NEXT_GAME_STATE.ENEMIES(i).DYING <= false;
            else
                NEXT_GAME_STATE.ENEMIES(i).FRAME <= GAME_STATE.ENEMIES(i).FRAME + 1;
            end if;
        else
            NEXT_GAME_STATE.ENEMIES(i).COUNTER <= GAME_STATE.ENEMIES(i).COUNTER + 1;
        end if;
    end if;
end loop;
end process;

process(GAME_STATE, BUTTON) is
    variable bomberman_x_logic_vector : std_logic_vector(11 downto 0);
    variable bomberman_y_logic_vector : std_logic_vector(11 downto 0);
    variable tile_coord : tile_point;
    variable x_offset : integer range 0 to 15;
    variable y_offset : integer range 0 to 15;
    variable x_on_grid : boolean;
    variable y_on_grid : boolean;
    variable animate : boolean;
    variable bomberman_velocity : velocity;
    variable viewport_velocity : velocity;
    variable end_count : integer range 0 to 31;
    variable has_died : boolean;
begin
    bomberman_x_logic_vector := std_logic_vector(to_unsigned(GAME_STATE.BOMBERMAN.COORD.x, COORDINATE_BITS));
    bomberman_y_logic_vector := std_logic_vector(to_unsigned(GAME_STATE.BOMBERMAN.COORD.y, COORDINATE_BITS));
    x_on_grid := bomberman_x_logic_vector(3 downto 0) = X"0";
    y_on_grid := bomberman_y_logic_vector(3 downto 0) = X"0";
    y_offset := to_integer(unsigned(bomberman_y_logic_vector(3 downto 0)));
    x_offset := to_integer(unsigned(bomberman_x_logic_vector(3 downto 0)));
    tile_coord.x := to_integer(unsigned(bomberman_x_logic_vector(11 downto 4)));
    tile_coord.y := to_integer(unsigned(bomberman_y_logic_vector(11 downto 4))) + 1;
    bomberman_velocity := (0, 0);
    viewport_velocity := (0, 0);
    animate := false;
    has_died := false;
    
    NEXT_GAME_STATE.BOMBERMAN.FRAME <= GAME_STATE.BOMBERMAN.FRAME;
    NEXT_GAME_STATE.BOMBERMAN.DIR <= GAME_STATE.BOMBERMAN.DIR;
    NEXT_GAME_STATE.BOMBERMAN.DYING <= GAME_STATE.BOMBERMAN.DYING;
    NEXT_GAME_STATE.LOAD_LEVEL <= false;
    NEXT_GAME_STATE.COUNTER <= GAME_STATE.COUNTER;
    
    if GAME_STATE.BOMBERMAN.TILE_COORD = (12,3) or GAME_STATE.BOMBERMAN.TILE_COORD = (13,3) then
        NEXT_GAME_STATE.LOAD_LEVEL <= true;
    end if;
    -- did bomberman collide with enemy?
    for i in 0 to MAX_ENEMIES - 1 loop    
        if GAME_STATE.BOMBERMAN.DYING = false and 
            (GAME_STATE.ENEMIES(i).TILE_COORD = GAME_STATE.BOMBERMAN.TILE_COORD or 
             GAME_STATE.ENEMIES(i).TILE_COORD = (GAME_STATE.BOMBERMAN.TILE_COORD.x,GAME_STATE.BOMBERMAN.TILE_COORD.y+1)) and
             GAME_STATE.ENEMIES(i).ALIVE then
            NEXT_GAME_STATE.BOMBERMAN.DYING <= true;            
        end if;
    end loop;        
    
    if not GAME_STATE.BOMBERMAN.DYING then
        if BUTTON = bomb or BUTTON = none then
            NEXT_GAME_STATE.BOMBERMAN.FRAME <= 0;
        end if;    
        
        if BUTTON = left then
            if GAME_STATE.BOMBERMAN.DIR /= left then
                -- start at frae 1
                NEXT_GAME_STATE.BOMBERMAN.FRAME <= 1;
            else
                animate := true;
            end if;
             
            NEXT_GAME_STATE.BOMBERMAN.DIR <= left;
            
            if ((x_on_grid and y_on_grid) and
               (GAME_STATE.COLLISION_MAP(tile_coord.y, tile_coord.x - 1) = 0)) or
               (not x_on_grid and y_on_grid) then
                bomberman_velocity := (-1, 0);
            elsif (x_on_grid and not y_on_grid) then
                if GAME_STATE.COLLISION_MAP(tile_coord.y, tile_coord.x - 1) = 0 then
                    bomberman_velocity := (0, -1);                
                elsif y_offset > 3 and GAME_STATE.COLLISION_MAP(tile_coord.y + 1, tile_coord.x - 1) = 0 then
                    bomberman_velocity := (0, 1);
                end if;
            end if;                       
        elsif BUTTON = up then
            if GAME_STATE.BOMBERMAN.DIR /= up then
                NEXT_GAME_STATE.BOMBERMAN.FRAME <= 1;
            else
                animate := true;
            end if;
            
            NEXT_GAME_STATE.BOMBERMAN.DIR <= up;
            
           if ((x_on_grid and y_on_grid) and
               (GAME_STATE.COLLISION_MAP(tile_coord.y - 1, tile_coord.x) = 0)) or
               (x_on_grid and not y_on_grid) then
                bomberman_velocity := (0, -1);
            elsif (not x_on_grid and y_on_grid) then
                if GAME_STATE.COLLISION_MAP(tile_coord.y - 1, tile_coord.x) = 0 then
                    bomberman_velocity := (-1, 0);                
                elsif x_offset > 3 and GAME_STATE.COLLISION_MAP(tile_coord.y - 1, tile_coord.x + 1) = 0 then
                    bomberman_velocity := (1, 0);
                end if;
            end if;
        elsif BUTTON = right then
            if GAME_STATE.BOMBERMAN.DIR /= right then
                NEXT_GAME_STATE.BOMBERMAN.FRAME <= 1;
            else
                animate := true;
            end if;
            
            NEXT_GAME_STATE.BOMBERMAN.DIR <= right;
        
            if ((x_on_grid and y_on_grid) and
               (GAME_STATE.COLLISION_MAP(tile_coord.y, tile_coord.x + 1) = 0)) or
               (not x_on_grid and y_on_grid) then
               bomberman_velocity := (1, 0);
            elsif (x_on_grid and not y_on_grid) then
                if GAME_STATE.COLLISION_MAP(tile_coord.y, tile_coord.x + 1) = 0 then
                    bomberman_velocity := (0, -1);                
                elsif y_offset > 3 and GAME_STATE.COLLISION_MAP(tile_coord.y+1, tile_coord.x+1) = 0 then
                    bomberman_velocity := (0, 1);
                end if;
            end if;       
        elsif BUTTON = down then
            if GAME_STATE.BOMBERMAN.DIR /= down then
                NEXT_GAME_STATE.BOMBERMAN.FRAME <= 1;
            else
                animate := true;
            end if;
            NEXT_GAME_STATE.BOMBERMAN.DIR <= down;
            
            if ((x_on_grid and y_on_grid) and
               (GAME_STATE.COLLISION_MAP(tile_coord.y + 1, tile_coord.x) = 0)) or
               (x_on_grid and not y_on_grid) then
                bomberman_velocity := (0, 1);
            elsif (not x_on_grid and y_on_grid) then
                if GAME_STATE.COLLISION_MAP(tile_coord.y + 1, tile_coord.x) = 0 then
                    bomberman_velocity := (-1, 0);                
                elsif x_offset > 3 and GAME_STATE.COLLISION_MAP(tile_coord.y + 1, tile_coord.x + 1) = 0 then
                    bomberman_velocity := (1, 0);
                end if;
            end if;
        end if;        
        
        if not LEVEL_DATA(GAME_STATE.LEVEL).VIEWPORT_FIXED_X then
            if (GAME_STATE.BOMBERMAN.COORD.x <= GAME_STATE.VIEWPORT_COORD.x + VIEWPORT_BORDER_X) and
               (GAME_STATE.VIEWPORT_COORD.x > 0) and not LEVEL_DATA(GAME_STATE.LEVEL).VIEWPORT_FIXED_X then
                viewport_velocity := (-1, 0);
            elsif (GAME_STATE.BOMBERMAN.COORD.x >= GAME_STATE.VIEWPORT_COORD.x + VIEWPORT_WIDTH - BOMBERMAN_WIDTH - VIEWPORT_BORDER_X) and
               (GAME_STATE.VIEWPORT_COORD.x < LEVEL_DATA(GAME_STATE.LEVEL).MAP_SIZE_PIX.WIDTH - VIEWPORT_WIDTH - 1) and
               not LEVEL_DATA(GAME_STATE.LEVEL).VIEWPORT_FIXED_X then
                viewport_velocity := (1, 0);
            end if;
        end if;
        if not LEVEL_DATA(GAME_STATE.LEVEL).VIEWPORT_FIXED_Y then
            if (GAME_STATE.BOMBERMAN.COORD.y <= GAME_STATE.VIEWPORT_COORD.y + VIEWPORT_BORDER_Y) and
               (GAME_STATE.VIEWPORT_COORD.y > 0) then
               viewport_velocity := (0, -1);
            elsif (GAME_STATE.BOMBERMAN.COORD.y >= GAME_STATE.VIEWPORT_COORD.y + VIEWPORT_HEIGHT - BOMBERMAN_HEIGHT - VIEWPORT_BORDER_Y) and
              (GAME_STATE.VIEWPORT_COORD.y < LEVEL_DATA(GAME_STATE.LEVEL).MAP_SIZE_PIX.HEIGHT - VIEWPORT_HEIGHT - 1) then
               viewport_velocity := (0, 1);
           end if;
        end if;    
        if animate then
            -- animate at 4Hz
            if GAME_STATE.COUNTER = 14 then
                NEXT_GAME_STATE.COUNTER <= 0;
                if GAME_STATE.BOMBERMAN.FRAME = 3 then 
                    NEXT_GAME_STATE.BOMBERMAN.FRAME <= 0;
                else
                    NEXT_GAME_STATE.BOMBERMAN.FRAME <= GAME_STATE.BOMBERMAN.FRAME + 1;
                end if;
            else
                NEXT_GAME_STATE.COUNTER <= GAME_STATE.COUNTER + 1;
            end if;
        end if;
    else
         -- 24816 . 30 , 15, 15 
        if GAME_STATE.BOMBERMAN.FRAME < 4 then
            end_count := 2;
        elsif GAME_STATE.BOMBERMAN.FRAME >= 4 and GAME_STATE.BOMBERMAN.FRAME < 8 then
            end_count := 4;
        elsif GAME_STATE.BOMBERMAN.FRAME >= 8 and GAME_STATE.BOMBERMAN.FRAME < 12 then
            end_count := 8;
        elsif GAME_STATE.BOMBERMAN.FRAME >= 12 and GAME_STATE.BOMBERMAN.FRAME < 16 then
            end_count := 16;
        elsif GAME_STATE.BOMBERMAN.FRAME = 16 then
            end_count := 30;
        else
            end_count := 15;
        end if;
        if GAME_STATE.COUNTER = end_count then
            NEXT_GAME_STATE.COUNTER <= 0;
            if GAME_STATE.BOMBERMAN.FRAME < 28 then
                NEXT_GAME_STATE.BOMBERMAN.FRAME <= GAME_STATE.BOMBERMAN.FRAME + 1;
            else
                NEXT_GAME_STATE.LOAD_LEVEL <= true;
            end if;
        else
            NEXT_GAME_STATE.COUNTER <= GAME_STATE.COUNTER + 1;
        end if;
    end if;
    NEXT_GAME_STATE.BOMBERMAN.COORD <= GAME_STATE.BOMBERMAN.COORD + bomberman_velocity;
    bomberman_x_logic_vector := std_logic_vector(to_unsigned(GAME_STATE.BOMBERMAN.COORD.x + bomberman_velocity.x,COORDINATE_BITS));
    bomberman_y_logic_vector := std_logic_vector(to_unsigned(GAME_STATE.BOMBERMAN.COORD.y + bomberman_velocity.y,COORDINATE_BITS));
    NEXT_GAME_STATE.BOMBERMAN.TILE_COORD <= (to_integer(unsigned(bomberman_x_logic_vector(11 downto 4))), to_integer(unsigned(bomberman_y_logic_vector(11 downto 4)))+1);
    NEXT_GAME_STATE.VIEWPORT_COORD <= GAME_STATE.VIEWPORT_COORD + viewport_velocity;
end process;

-- 
NEXT_GAME_STATE.COLLISION_MAP <= GAME_STATE.COLLISION_MAP;
NEXT_GAME_STATE.LEVEL <= GAME_STATE.LEVEL;
NEXT_GAME_STATE.POWERUPS <= GAME_STATE.POWERUPS;
NEXT_GAME_STATE.BOMB_COUNT <= GAME_STATE.BOMB_COUNT;
NEXT_GAME_STATE.ENEMY_COUNT <= GAME_STATE.ENEMY_COUNT;
--NEXT_GAME_STATE.ENEMIES <= GAME_STATE.ENEMIES;

end Behavioral;

