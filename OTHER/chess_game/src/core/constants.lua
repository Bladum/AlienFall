-- Constants for Tactical Chess Game
local Constants = {}

-- Display settings
Constants.WINDOW_WIDTH = 1280
Constants.WINDOW_HEIGHT = 720
Constants.TILE_SIZE = 60 -- pixels per tile

-- Board settings
Constants.DEFAULT_BOARD_WIDTH = 8
Constants.DEFAULT_BOARD_HEIGHT = 8
Constants.MIN_BOARD_SIZE = 6
Constants.MAX_BOARD_SIZE = 16
Constants.OBSTACLE_PERCENTAGE = 0.1 -- 10% of board
Constants.MAX_OBSTACLE_PERCENTAGE = 0.15 -- 15% hard cap

-- Map generation options
Constants.ALLOW_DIAGONAL_MOVEMENT = true
Constants.EXACT_OBSTACLE_COUNT = true -- if true, generator will enforce exact obstacle count (floor(total * percentage))
Constants.DEFAULT_MAP_SEED = nil -- set to a number to get deterministic maps (nil = random)


-- Game rules
Constants.STARTING_RESOURCES = 30
Constants.DEFAULT_TU_PER_TURN = 5
Constants.MAX_PLAYERS = 8

-- Piece types
Constants.PIECE_TYPES = {
    PAWN = "pawn",
    ROOK = "rook",
    BISHOP = "bishop",
    KNIGHT = "knight",
    QUEEN = "queen",
    KING = "king"
}

-- Piece default costs
Constants.PIECE_COSTS = {
    pawn = 1,
    rook = 3,
    bishop = 3,
    knight = 3,
    queen = 5,
    king = 0 -- King is mandatory, not purchased
}

-- Piece TU costs
Constants.PIECE_TU_COSTS = {
    pawn = 1,
    rook = 2,
    bishop = 2,
    knight = 2,
    queen = 3,
    king = 1
}

-- Piece default stats
Constants.PIECE_STATS = {
    pawn = { hp = 1, attack = 1, vision = 2 },
    rook = { hp = 1, attack = 1, vision = 3 },
    bishop = { hp = 1, attack = 1, vision = 3 },
    knight = { hp = 1, attack = 1, vision = 3 },
    queen = { hp = 1, attack = 1, vision = 3 },
    king = { hp = 3, attack = 0, vision = 4 }
}

-- Piece movement ranges
Constants.PIECE_RANGES = {
    pawn = 1,
    rook = 4,
    bishop = 4,
    knight = 1, -- Knight jumps, doesn't have range
    queen = 4,
    king = 1
}

-- Player colors (RPG standard)
Constants.PLAYER_COLORS = {
    { r = 0.2, g = 0.4, b = 1.0, name = "Blue" },    -- Player 1
    { r = 1.0, g = 0.2, b = 0.2, name = "Red" },     -- Enemy 1
    { r = 0.2, g = 1.0, b = 0.2, name = "Green" },   -- Ally 1
    { r = 1.0, g = 1.0, b = 0.2, name = "Yellow" },  -- Neutral 1
    { r = 0.8, g = 0.2, b = 1.0, name = "Purple" },  -- Enemy 2
    { r = 1.0, g = 0.6, b = 0.2, name = "Orange" },  -- Ally 2
    { r = 0.2, g = 1.0, b = 1.0, name = "Cyan" },    -- Neutral 2
    { r = 1.0, g = 0.4, b = 0.8, name = "Pink" }     -- Enemy 3
}

-- UI colors
Constants.UI_COLORS = {
    BACKGROUND = { r = 0.1, g = 0.1, b = 0.1 },
    GRID = { r = 0.3, g = 0.3, b = 0.3 },
    TILE_LIGHT = { r = 0.9, g = 0.9, b = 0.8 },
    TILE_DARK = { r = 0.6, g = 0.6, b = 0.5 },
    -- Single uniform tile color (used when checkerboard is disabled)
    TILE = { r = 0.8, g = 0.8, b = 0.75 },
    SIDEBAR_BG = { r = 0.06, g = 0.06, b = 0.06 },
    SIDEBAR_BORDER = { r = 0.2, g = 0.2, b = 0.2 },
    OBSTACLE = { r = 0.3, g = 0.2, b = 0.2 },
    CONTROL_POINT = { r = 1.0, g = 0.8, b = 0.0 },
    SELECTED = { r = 1.0, g = 1.0, b = 0.0, a = 0.5 },
    VALID_MOVE = { r = 0.0, g = 1.0, b = 0.0, a = 0.3 },
    ATTACK_MOVE = { r = 1.0, g = 0.0, b = 0.0, a = 0.3 },
    FOG = { r = 0.0, g = 0.0, b = 0.0, a = 0.7 }
}

-- Visual tunables
Constants.VISUALS = {
    selection_alpha = 0.45,
    dot_size_factor = 0.12, -- fraction of tile size
    dot_offset = 4,
    fog_update_delay = 0.0 -- seconds (0 = immediate after animation completes)
}

-- Path preview visuals
Constants.VISUALS.path_preview_color = { r = 0.0, g = 0.6, b = 1.0, a = 0.35 }
Constants.VISUALS.path_preview_tile_alpha = 0.35

-- Animated unit shadow
Constants.VISUALS.shadow_color = { r = 0, g = 0, b = 0, a = 0.35 }
Constants.VISUALS.shadow_scale = 0.7 -- fraction of tile width

-- Animation settings
Constants.ANIM = {
    segment_duration = 0.12,
    shrink_duration = 0.25
}

-- Game modes
Constants.GAME_MODES = {
    DEATHMATCH = "deathmatch",
    CAPTURE_FLAG = "capture_flag",
    DOMINATION = "domination",
    ASSAULT = "assault",
    DEFENSE = "defense",
    KILL_KING = "kill_king"
}

-- Tile types
Constants.TILE_TYPES = {
    NORMAL = "normal",
    OBSTACLE = "obstacle",
    CONTROL_POINT = "control_point"
}

-- Camera settings
Constants.CAMERA_MIN_ZOOM = 0.5
Constants.CAMERA_MAX_ZOOM = 2.0
Constants.CAMERA_ZOOM_SPEED = 0.1
Constants.CAMERA_PAN_SPEED = 500

-- Fog of War
Constants.FOW_VISIBLE = "visible"
Constants.FOW_EXPLORED = "explored"
Constants.FOW_HIDDEN = "hidden"

return Constants
