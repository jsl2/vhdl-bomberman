--use work.state_pkg.all;
use work.graphics_pkg.all;

package levels_pkg is
    constant LEVELS_COUNT : integer := 2;

    type level_info is record
        MAP_SIZE : tile_size_t;
        MAP_SIZE_PIX : size_t;
        VIEWPORT_START_POS : point;
        VIEWPORT_FIXED_X : boolean;
        VIEWPORT_FIXED_Y : boolean;        
    end record;
    
    type levels_info is array(0 to LEVELS_COUNT-1) of level_info;
    --type levels_states is array(0 to LEVELS_COUNT-1) of state_vector;
   
    constant LEVEL_DATA : levels_info :=
        (
            (MAP_SIZE => (17,13),
             MAP_SIZE_PIX => (256,200),
             VIEWPORT_START_POS => (7,7),
             VIEWPORT_FIXED_X => true,
             VIEWPORT_FIXED_Y => true),
            (MAP_SIZE => (32,20),
             MAP_SIZE_PIX => (512,320),
             VIEWPORT_START_POS => (0, 0),
             VIEWPORT_FIXED_X => false,
             VIEWPORT_FIXED_Y => false)
         );
    --constant INITIAL_LEVEL_STATES : levels_states :=
      --   (others => INITIAL_STATE);
end package;