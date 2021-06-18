use work.graphics_pkg.all;
use work.tileset_pkg.all;
use work.levels_pkg.all;

package maps_pkg is
    constant MAX_MAP_SIZE : size_t := (WIDTH => TILE_COORDINATE_VALUE_MAX+1, HEIGHT => TILE_COORDINATE_VALUE_MAX+1);
    type level0_bg_type is array(0 to LEVEL_DATA(0).MAP_SIZE.HEIGHT - 1, 0 to LEVEL_DATA(0).MAP_SIZE.WIDTH - 1) of tile_type;
    
    type tile_offset is record
        x : integer range -(TILE_COORDINATE_VALUE_MAX) to TILE_COORDINATE_VALUE_MAX;
        y : integer range -(TILE_COORDINATE_VALUE_MAX) to TILE_COORDINATE_VALUE_MAX;
    end record;
    type collision_map_type is array(0 to MAX_MAP_SIZE.HEIGHT - 1, 0 to MAX_MAP_SIZE.WIDTH - 1) of integer range 0 to 1;    
    type soft_wall_map_type is array(0 to MAX_MAP_SIZE.HEIGHT - 1, 0 to MAX_MAP_SIZE.WIDTH - 1) of integer range 0 to 7; -- walls = 1 + animation frames
    type power_up_map_type is array(0 to MAX_MAP_SIZE.HEIGHT - 1, 0 to MAX_MAP_SIZE.WIDTH - 1) of integer range 0 to 15; -- different power ups
    constant LEVEL0_BG : level0_bg_type := 
        (( 19, 20,  6,  6,  6,  6,  6,  6,  6,  6,  6, 51, 52, 53,  6, 57, 58),
         ( 34, 35, 21, 21, 21, 21, 21, 21, 21, 21, 21, 66, 67, 68, 21, 72, 73),
         ( 49, 50,  1,  0,  2,  0,  2,  0,  2,  0,  2, 81, 82, 83,  2, 87, 88),
         ( 64, 50,  1,  2,  1,  2,  1,  2,  1,  2,  1, 96, 97, 98,  1, 87,102),
         (  6, 50,  1,  0,  1,  0,  1,  0,  1,  0,  1,  0,  1,  0,  1, 87, 46),
         (  6, 50,  1,  2,  1,  2,  1,  2,  1,  2,  1,  2,  1,  2,  1, 87, 62),
         (  6, 31, 63, 76, 77, 78, 63, 63, 63, 63, 63, 76, 77, 78, 63, 38,  6),
         ( 46, 75, 16,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2, 18, 23,  6),
         ( 62, 90, 60,  0,  1,  0,  1,  0,  1,  0,  1,  0,  1,  0,  8, 93,  6),
         ( 46, 27, 60,  2,  1,  2,  1,  2,  1,  2,  1,  2,  1,  2,  8, 27, 46),
         ( 62, 32, 48,  0,  1,  0,  1,  0,  1,  0,  1,  0,  1,  0, 80, 99, 62),
         (  4, 94,  1,  2,  1,  2,  1,  2,  1,  2,  1,  2,  1,  2,  1, 95,  5),
         ( 57, 20, 36,  3, 36,  3, 36,  3, 36,  3, 36,  3, 36,  3, 36, 57, 58));


    constant LEVEL0_COLLISION_INITIAL : collision_map_type :=
          ((others=>1),
           (others=>1),                           
           (1,1,0,1,0,1,0,1,0,1,0,1,1,1,0,1,1, others=>1),
           (1,1,0,0,0,0,0,0,0,0,0,1,1,1,0,1,1, others=>1),
           (1,1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,1, others=>1),
           (1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1, others=>1),
           (1,1,1,1,0,1,1,1,1,1,1,1,0,1,1,1,1, others=>1),
           (1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1, others=>1),
           (1,1,1,1,0,1,0,1,0,1,0,1,0,1,1,1,1, others=>1),
           (1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1, others=>1),
           (1,1,1,1,0,1,0,1,0,1,0,1,0,1,1,1,1, others=>1),
           (1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1, others=>1),                                            
           (others=>1),
           others=>(others=>1));
           
    function get_tile(level : in integer range 0 to LEVELS_COUNT; tile_coord : tile_point) return tile_type;
end package;

package body maps_pkg is
    function get_tile(level : in integer range 0 to LEVELS_COUNT; tile_coord : tile_point) return tile_type is
    begin
        case level is
            when 0 =>
                return LEVEL0_BG(tile_coord.y, tile_coord.x);
            when others =>
                return 0;
        end case;
    end;
end;