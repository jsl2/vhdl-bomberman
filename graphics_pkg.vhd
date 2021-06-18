library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package graphics_pkg is    
    constant COORDINATE_VALUE_MAX: integer := 511;
    constant TILE_COORDINATE_VALUE_MAX: integer := 31;
    constant COORDINATE_BITS: integer := 12;
    constant SCREEN_WIDTH: integer := 480;
    constant SCREEN_HEIGHT: integer := 272;
    
    constant VIEWPORT_BORDER_X : integer := 96;
    constant VIEWPORT_BORDER_Y : integer := 72;
    constant VIEWPORT_WIDTH: integer := 256;
    constant VIEWPORT_HEIGHT: integer := 200;
  
    constant SCOREBOARD_WIDTH: integer := 256;
    constant SCOREBOARD_HEIGHT: integer := 8;
  
    subtype pixel_type is std_logic_vector(7 downto 0);
    subtype rgb_pixel_type is std_logic_vector(23 downto 0);
    
    constant TRANSPARENT_PIXEL : pixel_type := X"01";
    constant WHITE_PIXEL : pixel_type := X"2E";
    
    type bitmap_type is array (0 to 15, 0 to 15) of pixel_type;
    
    type tile_point is record
        x, y: integer range 0 to TILE_COORDINATE_VALUE_MAX;
    end record;    
    
    type point is record
        x, y: integer range 0 to COORDINATE_VALUE_MAX;
    end record;
    
    type bitmap_offset is record
        x, y: integer range 0 to 15;
    end record;
    
    type tile_size_t is record
        width, height: integer range 1 to TILE_COORDINATE_VALUE_MAX+1;
    end record;
    
    type size_t is record
        width, height: integer range 1 to COORDINATE_VALUE_MAX+1;
    end record;
    
    type velocity is record
        x, y: integer range -15 to 15;
    end record;
    
    type direction is (right, up, left, down);
    
    constant TOP_LEFT_VIEWPORT: point := (x => 153, y => 263);
    constant TOP_LEFT_SCOREBOARD : point := (x => 137, y => 263); 
    
    type fullscreen_bitmap is array(SCREEN_HEIGHT-1 downto 0, SCREEN_WIDTH-1 downto 0) of pixel_type;
    
    function raster_pos_to_viewport_raster_pos (RASTER_POS : in point) return point;
    function raster_pos_to_scoreboard_raster_pos (RASTER_POS : in point) return point;
    function is_viewport (RASTER_POS : in point) return boolean;
    function is_scoreboard (RASTER_POS : in point) return boolean;
    function "+" (lhs, rhs: point) return point;
    function "+" (lhs: point; rhs: velocity) return point;
end;

package body graphics_pkg is
    function raster_pos_to_viewport_raster_pos (RASTER_POS : in point) return point is
        variable ret : point;
    begin
        ret.x := TOP_LEFT_VIEWPORT.y - RASTER_POS.y;
        ret.y := RASTER_POS.x - TOP_LEFT_VIEWPORT.x;
        return ret;
    end;
    
    function raster_pos_to_scoreboard_raster_pos (RASTER_POS : in point) return point is
        variable ret : point;
    begin
        ret.x := TOP_LEFT_SCOREBOARD.y - RASTER_POS.y;
        ret.y := RASTER_POS.x - TOP_LEFT_SCOREBOARD.x;
        return ret;
    end;
    
    function is_viewport (RASTER_POS : in point) return boolean is
    begin
        return (RASTER_POS.x > TOP_LEFT_VIEWPORT.x and RASTER_POS.x <= TOP_LEFT_VIEWPORT.x + VIEWPORT_HEIGHT) and
               (RASTER_POS.y > TOP_LEFT_VIEWPORT.y - VIEWPORT_WIDTH and RASTER_POS.y <= TOP_LEFT_VIEWPORT.y);
    end;
    
    function is_scoreboard (RASTER_POS : in point) return boolean is
    begin
        return (RASTER_POS.x > TOP_LEFT_SCOREBOARD.x and RASTER_POS.x <= TOP_LEFT_SCOREBOARD.x + SCOREBOARD_HEIGHT) and
               (RASTER_POS.y > TOP_LEFT_SCOREBOARD.y - SCOREBOARD_WIDTH and RASTER_POS.y <= TOP_LEFT_SCOREBOARD.y);
    end;
    
    -- Add two points by summing each axis' coordinates
    function "+" (lhs, rhs: point) return point is begin
        return (lhs.x + rhs.x, lhs.y + rhs.y);
    end;
    
    function "+" (lhs: point; rhs: velocity) return point is begin
        return (lhs.x + rhs.x, lhs.y + rhs.y);
    end;
end;