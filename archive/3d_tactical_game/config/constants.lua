---@class Constants
-- Game configuration constants
-- Centralized configuration for easy tuning

local Constants = {}

-- Grid and Map Settings
Constants.GRID_SIZE = 60  -- Map is 60x60 tiles
Constants.TILE_SIZE = 1.0  -- Each tile is 1x1 unit in 3D space

-- Team Definitions
Constants.TEAM = {
    PLAYER = 1,   -- Blue team
    ALLY = 2,     -- Green team
    ENEMY = 3,    -- Red team
    NEUTRAL = 4   -- Gray team
}

-- Terrain Types
Constants.TERRAIN = {
    FLOOR = 1,
    WALL = 2,
    DOOR = 3
}

-- Visibility States
Constants.VISIBILITY = {
    HIDDEN = 0,     -- Never seen, completely dark
    EXPLORED = 1,   -- Previously seen, dimly lit
    VISIBLE = 2     -- Currently visible, fully lit
}

-- Unit Settings
Constants.UNIT_LOS_RANGE = 10  -- Line of sight range in tiles
Constants.UNIT_SENSE_RANGE = 3  -- Detection range for nearby units
Constants.UNIT_HEIGHT = 0.5     -- Height of unit sprites above ground
Constants.UNIT_SCALE = 1.0      -- Base scale for unit sprites

-- Camera Settings
Constants.CAMERA_HEIGHT = 0.5   -- Camera height above ground
Constants.CAMERA_FOV = math.pi / 3  -- 60 degrees field of view
Constants.CAMERA_NEAR = 0.01
Constants.CAMERA_FAR = 10000

-- Lighting Settings
Constants.LIGHT_VISIBLE = 1.0       -- Brightness for visible tiles
Constants.LIGHT_EXPLORED = 0.3      -- Brightness for explored tiles
Constants.LIGHT_HIDDEN = 0.0        -- Brightness for hidden tiles

-- Day/Night Cycle
Constants.DAY_SKY_COLOR = {0.2, 0.4, 0.7, 1.0}    -- Navy blue sky
Constants.NIGHT_SKY_COLOR = {0.05, 0.1, 0.2, 1.0}  -- Dark navy sky
Constants.DAY_LENGTH = 120  -- Seconds for full day/night cycle

-- Physics Settings
Constants.PHYSICS_SCALE = 32  -- Pixels per meter for Box2D
Constants.BULLET_SPEED = 20   -- Meters per second
Constants.BULLET_LIFETIME = 5 -- Seconds before bullet despawns

-- Performance Settings
Constants.MAX_PARTICLES = 1000  -- Maximum particle count for effects
Constants.UPDATE_VISIBILITY_EVERY = 0.1  -- Seconds between visibility updates

-- Input Settings
Constants.MOVE_DELAY = 0.15  -- Delay between movement inputs
Constants.TURN_DELAY = 0.15  -- Delay between rotation inputs

-- UI Settings
Constants.MINIMAP_SIZE = 200  -- Minimap width/height in pixels
Constants.MINIMAP_SCALE = 2   -- Pixels per tile on minimap
Constants.HUD_PADDING = 10    -- Padding for UI elements

return Constants






















