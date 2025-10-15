---@class Colors
-- Color definitions for teams, terrain, and effects
-- All colors in RGBA format (0-1 range)

local Colors = {}

-- Team Colors (for units and UI)
Colors.TEAM = {
    [1] = {0.2, 0.4, 1.0, 1.0},  -- Player: Blue
    [2] = {0.2, 0.8, 0.2, 1.0},  -- Ally: Green
    [3] = {1.0, 0.2, 0.2, 1.0},  -- Enemy: Red
    [4] = {0.5, 0.5, 0.5, 1.0}   -- Neutral: Gray
}

-- Terrain Colors (for map PNG loading)
Colors.TERRAIN_MAP = {
    -- Floor types
    GRASS = {0, 0.5, 0},           -- Dark green
    STONE_FLOOR = {0.7, 0.7, 0.7}, -- Light gray
    PATH = {0.6, 0.3, 0},          -- Brown
    
    -- Wall types
    STONE_WALL = {0, 0, 0},        -- Black
    WOOD_WALL = {0.6, 0.4, 0.2},   -- Light brown
    
    -- Door types
    WOOD_DOOR = {1, 0, 0},         -- Red
    
    -- Special markers
    PLAYER_START = {1, 1, 0}       -- Yellow
}

-- UI Colors
Colors.UI = {
    SELECTION = {1.0, 1.0, 0.0, 0.8},  -- Yellow selection highlight
    HOVER = {1.0, 1.0, 1.0, 0.5},      -- White hover highlight
    BACKGROUND = {0.1, 0.1, 0.1, 0.8}, -- Dark background
    TEXT = {1.0, 1.0, 1.0, 1.0},       -- White text
    TEXT_SHADOW = {0.0, 0.0, 0.0, 0.8} -- Black text shadow
}

-- Effect Colors
Colors.EFFECTS = {
    FIRE = {1.0, 0.5, 0.0, 1.0},     -- Orange fire
    SMOKE = {0.3, 0.3, 0.3, 0.7},    -- Gray smoke
    EXPLOSION = {1.0, 0.8, 0.0, 1.0}, -- Yellow explosion
    MUZZLE_FLASH = {1.0, 1.0, 0.8, 1.0} -- Bright flash
}

-- Minimap Colors
Colors.MINIMAP = {
    HIDDEN = {0.0, 0.0, 0.0, 1.0},      -- Black for unexplored
    EXPLORED = {0.2, 0.2, 0.2, 1.0},    -- Dark gray for explored
    VISIBLE_FLOOR = {0.5, 0.5, 0.5, 1.0}, -- Light gray for visible floors
    VISIBLE_WALL = {0.8, 0.8, 0.8, 1.0},  -- Almost white for walls
    CURRENT_UNIT = {0.0, 1.0, 1.0, 1.0}   -- Cyan for selected unit
}

-- Utility function: Convert color table to individual RGBA values
function Colors.unpack(color)
    return color[1], color[2], color[3], color[4]
end

-- Utility function: Blend two colors
function Colors.blend(color1, color2, t)
    return {
        color1[1] * (1-t) + color2[1] * t,
        color1[2] * (1-t) + color2[2] * t,
        color1[3] * (1-t) + color2[3] * t,
        color1[4] * (1-t) + color2[4] * t
    }
end

-- Utility function: Darken color by factor
function Colors.darken(color, factor)
    return {
        color[1] * factor,
        color[2] * factor,
        color[3] * factor,
        color[4]
    }
end

-- Utility function: Check if two RGB colors match (within tolerance)
function Colors.matches(r1, g1, b1, r2, g2, b2, tolerance)
    tolerance = tolerance or 0.1
    return math.abs(r1 - r2) < tolerance and
           math.abs(g1 - g2) < tolerance and
           math.abs(b1 - b2) < tolerance
end

return Colors






















