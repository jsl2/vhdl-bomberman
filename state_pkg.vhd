library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.graphics_pkg.all;
use work.touch_pkg.all;
use work.tileset_pkg.all;
use work.levels_pkg.all;
use work.maps_pkg.all;
use work.bombs_pkg.all;
use work.explosions_pkg.all;
use work.enemies_pkg.all;

package state_pkg is        
    type enemy_state is record
        ALIVE : boolean;
        DYING : boolean;
        COORD : point;
        TILE_COORD : tile_point;
        DIR : direction;
        --KIND : enemy_types;
        --SIZE : size_t; (size can be inferred from kind)
        COUNTER : integer range 0 to 15;        
        FRAME : integer range 0 to 3;
    end record;
    
    type enemy_states is array (0 to MAX_ENEMIES-1) of enemy_state; -- max 16 enemies.
    
    constant initial_enemy_array : enemy_states :=
        ((ALIVE => true,
        DYING => false,
        DIR => right,
        TILE_COORD => (3,2),
        COORD => (48,32),
        COUNTER => 0,
        FRAME => 0),
        (ALIVE => true,
        DYING => false,
        DIR => right,
        TILE_COORD => (4,8),
        COORD => (64,128),
        COUNTER => 0,
        FRAME => 0),
        (ALIVE => true,
        DYING => false,
        DIR => right,
        TILE_COORD => (13,8),
        COORD => (208,128),
        COUNTER => 0,
        FRAME => 0),
        (ALIVE => false,
        DYING => false,
        DIR => right,
        TILE_COORD => (3,2),
        COORD => (48,32),
        COUNTER => 0,
        FRAME => 0));
    
    type bomberman_state is record
        DYING : boolean;
        COORD : point;
        TILE_COORD : tile_point;
        DIR : direction;
        FRAME : integer range 0 to 31;      
    end record;          
    
    type powerups_state is record
        BOMB_LIMIT : integer range 1 to MAX_BOMBS;
        BLAST_RADIUS : integer range 1 to MAX_BLAST_RADIUS;
    end record;
    
    type state_vector is record        
        VIEWPORT_COORD : point;
        BOMBERMAN : bomberman_state;
        POWERUPS : powerups_state;
        COLLISION_MAP : collision_map_type;
        ENEMIES : enemy_states;
        ENEMY_COUNT : integer range 0 to MAX_ENEMIES-1;
        BOMB_COUNT : integer range 0 to MAX_BOMBS-1;       
        LEVEL : integer range 0 to 15;
        COUNTER : integer range 0 to 59; -- general purpose counter from 0 to 60 ~ 1sec
        LOAD_LEVEL : boolean; -- load the level specified by GAME_STATE.LEVEL
    end record;        
    
    constant INITIAL_STATE : state_vector := 
        (VIEWPORT_COORD => LEVEL_DATA(0).VIEWPORT_START_POS,
         LEVEL => 0,
         BOMBERMAN => (DYING => false, COORD => (8*16, 8*16), TILE_COORD => (8,8), DIR => down, FRAME => 0),
         COLLISION_MAP => LEVEL0_COLLISION_INITIAL,
         POWERUPS => (BOMB_LIMIT => 1, BLAST_RADIUS => 1),
         ENEMIES => INITIAL_ENEMY_ARRAY,
         ENEMY_COUNT => 3,
         BOMB_COUNT => 0,
         COUNTER => 0,
         LOAD_LEVEL => false);             
end package;