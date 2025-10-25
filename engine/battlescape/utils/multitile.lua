---MultiTile Utility - Multi-Tile Mode Handler
---
---Handles all multi-tile modes for map tiles including variants, animations, autotiles,
---multi-cell objects, and damage states. Provides unified interface for complex tile
---behaviors and visual variations.
---
---Features:
---  - Tile variants (random visual variations)
---  - Tile animations (animated tiles like water)
---  - Autotiling (context-aware borders and corners)
---  - Multi-cell objects (objects spanning multiple tiles)
---  - Damage states (visual damage progression)
---  - Mode validation and detection
---
---Multi-Tile Modes:
---  - Variants: Random visual variations (e.g., 4 grass sprites)
---  - Animation: Frame-based animation (e.g., water flowing)
---  - Autotile: Context-aware tiling (e.g., wall corners)
---  - Multi-cell: Objects spanning multiple tiles (e.g., tanks)
---  - Damage: Progressive damage states (e.g., wall destruction)
---
---Mode Properties:
---  - multiTileMode: Mode type identifier
---  - frameCount: Number of frames/variants
---  - frameDelay: Animation speed
---  - tileWidth/Height: Size for multi-cell
---  - damageStages: Number of damage levels
---
---Key Exports:
---  - MultiTile.isMultiTile(tile): Checks if tile is multi-tile
---  - MultiTile.getMode(tile): Returns mode type
---  - MultiTile.getCurrentFrame(tile): Gets current frame/variant
---  - MultiTile.updateAnimation(tile, dt): Updates animated tiles
---  - MultiTile.getAutotileIndex(tile, neighbors): Calculates autotile index
---  - MultiTile.setDamageState(tile, stage): Sets damage level
---  - MultiTile.isMultiCell(tile): Checks if spans multiple tiles
---
---Dependencies:
---  - None (standalone utility)
---
---@module battlescape.utils.multitile
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MultiTile = require("battlescape.utils.multitile")
---  if MultiTile.isMultiTile(tile) then
---    local frame = MultiTile.getCurrentFrame(tile)
---    MultiTile.updateAnimation(tile, dt)
---  end
---
---@see battlescape.combat.battle_tile For tile structure

-- Multi-Tile Utility
-- Handles all multi-tile modes: variants, animations, autotiles, multi-cell, damage states

local MultiTile = {}

---Check if a Map Tile is a multi-tile
---@param tile MapTile The tile to check
---@return boolean
function MultiTile.isMultiTile(tile)
    return tile.multiTileMode ~= nil
end

---Get the mode of a multi-tile
---@param tile MapTile The tile
---@return string? mode Mode name or nil
function MultiTile.getMode(tile)
    return tile.multiTileMode
end

-- ============================================================================
-- VARIANT MODE: Random selection from multiple sprite variants
-- ============================================================================

---Select a random variant index for a tile
---@param tile MapTile The tile with random_variant mode
---@param seed number? Optional seed for deterministic selection
---@return number variantIndex 0-based variant index
function MultiTile.selectVariant(tile, seed)
    if tile.multiTileMode ~= "random_variant" then
        return 0
    end
    
    local count = tile.variantCount or 1
    if count <= 1 then
        return 0
    end
    
    if seed then
        math.randomseed(seed)
        local variant = math.random(0, count - 1)
        math.randomseed(os.time())  -- Reset to time-based
        return variant
    else
        return math.random(0, count - 1)
    end
end

---Get the variant count for a tile
---@param tile MapTile The tile
---@return number count Number of variants (1 if not variant mode)
function MultiTile.getVariantCount(tile)
    if tile.multiTileMode == "random_variant" then
        return tile.variantCount or 1
    end
    return 1
end

-- ============================================================================
-- ANIMATION MODE: Sprite cycling through frames
-- ============================================================================

---Get the current animation frame for a tile
---@param tile MapTile The tile with animation mode
---@param elapsedTime number Time elapsed in milliseconds
---@return number frameIndex 0-based frame index
function MultiTile.getAnimationFrame(tile, elapsedTime)
    if tile.multiTileMode ~= "animation" then
        return 0
    end
    
    local frameCount = tile.frameCount or 1
    if frameCount <= 1 then
        return 0
    end
    
    local frameDelay = tile.frameDelay or 200
    local totalDuration = frameCount * frameDelay
    
    if tile.looping then
        -- Loop animation
        elapsedTime = elapsedTime % totalDuration
    elseif tile.pingpong then
        -- Ping-pong animation (forward then reverse)
        local cycleTime = totalDuration * 2
        elapsedTime = elapsedTime % cycleTime
        if elapsedTime >= totalDuration then
            -- Reverse
            elapsedTime = cycleTime - elapsedTime
        end
    else
        -- Play once and stop
        if elapsedTime >= totalDuration then
            return frameCount - 1  -- Last frame
        end
    end
    
    local frame = math.floor(elapsedTime / frameDelay)
    return math.min(frame, frameCount - 1)
end

---Check if animation is complete (for non-looping animations)
---@param tile MapTile The tile with animation mode
---@param elapsedTime number Time elapsed in milliseconds
---@return boolean complete True if animation finished
function MultiTile.isAnimationComplete(tile, elapsedTime)
    if tile.multiTileMode ~= "animation" then
        return true
    end
    
    if tile.looping or tile.pingpong then
        return false  -- Looping animations never complete
    end
    
    local frameCount = tile.frameCount or 1
    local frameDelay = tile.frameDelay or 200
    local totalDuration = frameCount * frameDelay
    
    return elapsedTime >= totalDuration
end

-- ============================================================================
-- AUTOTILE MODE: Sprite selection based on neighbor pattern
-- ============================================================================

---Get autotile frame based on neighbor configuration
---@param tile MapTile The tile with autotile mode
---@param neighbors table Array of 8 booleans [N, NE, E, SE, S, SW, W, NW]
---@return number frameIndex 0-based frame index
function MultiTile.getAutotileFrame(tile, neighbors)
    if tile.multiTileMode ~= "autotile" then
        return 0
    end
    
    local autotileType = tile.autotileType or "blob"
    
    if autotileType == "blob" then
        return MultiTile._blobAutotile(neighbors)
    elseif autotileType == "16tile" then
        return MultiTile._16tileAutotile(neighbors)
    elseif autotileType == "47tile" then
        return MultiTile._47tileAutotile(neighbors)
    end
    
    return 0
end

---Blob autotile (4-directional, 2×2 template = 4 frames)
---@param neighbors table [N, NE, E, SE, S, SW, W, NW]
---@return number frameIndex
function MultiTile._blobAutotile(neighbors)
    -- Blob autotile only considers cardinal directions (N, E, S, W)
    local n = neighbors[1] or false
    local e = neighbors[3] or false
    local s = neighbors[5] or false
    local w = neighbors[7] or false
    
    -- Pattern: 0=isolated, 1=horizontal, 2=vertical, 3=cross
    if not n and not e and not s and not w then
        return 0  -- Isolated
    elseif (e or w) and not n and not s then
        return 1  -- Horizontal
    elseif (n or s) and not e and not w then
        return 2  -- Vertical
    else
        return 3  -- Cross/connected
    end
end

---16-tile autotile (8-directional, 4×4 template = 16 frames)
---@param neighbors table [N, NE, E, SE, S, SW, W, NW]
---@return number frameIndex
function MultiTile._16tileAutotile(neighbors)
    -- 16-tile autotile considers all 8 directions
    -- Bitfield: N=1, E=2, S=4, W=8
    local n = neighbors[1] or false
    local e = neighbors[3] or false
    local s = neighbors[5] or false
    local w = neighbors[7] or false
    
    local bits = 0
    if n then bits = bits + 1 end
    if e then bits = bits + 2 end
    if s then bits = bits + 4 end
    if w then bits = bits + 8 end
    
    return bits
end

---47-tile autotile (8-directional with corners, 7×7 template = 47 frames)
---@param neighbors table [N, NE, E, SE, S, SW, W, NW]
---@return number frameIndex
function MultiTile._47tileAutotile(neighbors)
    -- Full 47-tile autotile (Wang tiles style)
    -- This is complex - simplified version here
    -- In production, use lookup table based on all 8 neighbor combinations
    
    local n = neighbors[1] or false
    local ne = neighbors[2] or false
    local e = neighbors[3] or false
    local se = neighbors[4] or false
    local s = neighbors[5] or false
    local sw = neighbors[6] or false
    local w = neighbors[7] or false
    local nw = neighbors[8] or false
    
    -- Convert to bitfield (8 bits for 8 directions)
    local bits = 0
    if n then bits = bits + 1 end
    if ne then bits = bits + 2 end
    if e then bits = bits + 4 end
    if se then bits = bits + 8 end
    if s then bits = bits + 16 end
    if sw then bits = bits + 32 end
    if w then bits = bits + 64 end
    if nw then bits = bits + 128 end
    
    -- Lookup table would map bits -> frame index
    -- For now, use simplified mapping based on cardinal directions
    return MultiTile._16tileAutotile(neighbors)
end

-- ============================================================================
-- OCCUPY MODE: Multi-cell tiles that span multiple hex cells
-- ============================================================================

---Get the cell dimensions of a tile
---@param tile MapTile The tile
---@return number width, number height Cell dimensions
function MultiTile.getCellDimensions(tile)
    if tile.multiTileMode == "occupy" then
        return tile.cellWidth or 1, tile.cellHeight or 1
    end
    return 1, 1
end

---Get the pixel dimensions of a tile
---@param tile MapTile The tile
---@return number width, number height Pixel dimensions
function MultiTile.getPixelDimensions(tile)
    local cellW, cellH = MultiTile.getCellDimensions(tile)
    return cellW * 24, cellH * 24
end

---Get the anchor point (origin cell) of a multi-cell tile
---@param tile MapTile The tile
---@return number x, number y Anchor point
function MultiTile.getAnchorPoint(tile)
    if tile.multiTileMode == "occupy" and tile.anchorPoint then
        return tile.anchorPoint[1], tile.anchorPoint[2]
    end
    return 0, 0
end

---Get all cells occupied by a tile placed at (x, y)
---@param tile MapTile The tile
---@param x number Origin X coordinate
---@param y number Origin Y coordinate
---@return table Array of {x, y} cell coordinates
function MultiTile.getOccupiedCells(tile, x, y)
    local cells = {}
    local width, height = MultiTile.getCellDimensions(tile)
    
    for dy = 0, height - 1 do
        for dx = 0, width - 1 do
            table.insert(cells, {x = x + dx, y = y + dy})
        end
    end
    
    return cells
end

---Check if all cells are blocked for a multi-cell tile
---@param tile MapTile The tile
---@return boolean blocked True if all cells block movement
function MultiTile.blockAllCells(tile)
    if tile.multiTileMode == "occupy" then
        return tile.blockAllCells ~= false  -- Default true
    end
    return tile.passable == false
end

-- ============================================================================
-- DAMAGE STATES MODE: Sprite changes based on health
-- ============================================================================

---Get damage state frame based on health percentage
---@param tile MapTile The tile with damage_states mode
---@param healthPercent number Current health as percentage (0-100)
---@return number frameIndex 0-based frame index
function MultiTile.getDamageStateFrame(tile, healthPercent)
    if tile.multiTileMode ~= "damage_states" then
        return 0
    end
    
    if not tile.damageThresholds then
        -- No thresholds defined, use simple division
        local states = tile.damageStates or 1
        local statePercent = 100 / states
        return math.floor((100 - healthPercent) / statePercent)
    end
    
    -- Use defined thresholds
    for _, threshold in ipairs(tile.damageThresholds) do
        if healthPercent >= threshold.minHealth and healthPercent <= threshold.maxHealth then
            return threshold.frame
        end
    end
    
    return 0
end

---Get the number of damage states
---@param tile MapTile The tile
---@return number states Number of damage states (1 if not damage_states mode)
function MultiTile.getDamageStateCount(tile)
    if tile.multiTileMode == "damage_states" then
        return tile.damageStates or 1
    end
    return 1
end

-- ============================================================================
-- GENERAL UTILITIES
-- ============================================================================

---Get the total frame count for a multi-tile (for texture loading)
---@param tile MapTile The tile
---@return number frameCount Total number of frames
function MultiTile.getTotalFrameCount(tile)
    if not MultiTile.isMultiTile(tile) then
        return 1
    end
    
    if tile.multiTileMode == "random_variant" then
        return tile.variantCount or 1
    elseif tile.multiTileMode == "animation" then
        return tile.frameCount or 1
    elseif tile.multiTileMode == "damage_states" then
        return tile.damageStates or 1
    elseif tile.multiTileMode == "autotile" then
        -- Return frame count based on autotile type
        if tile.autotileType == "blob" then
            return 4
        elseif tile.autotileType == "16tile" then
            return 16
        elseif tile.autotileType == "47tile" then
            return 47
        end
    end
    
    return 1
end

---Get the expected PNG dimensions for a multi-tile
---@param tile MapTile The tile
---@return number width, number height Expected PNG dimensions in pixels
function MultiTile.getExpectedPNGDimensions(tile)
    local frameCount = MultiTile.getTotalFrameCount(tile)
    
    if tile.multiTileMode == "occupy" then
        -- Multi-cell tiles have larger base size
        local cellW, cellH = MultiTile.getCellDimensions(tile)
        return cellW * 24, cellH * 24 * frameCount
    elseif tile.multiTileMode == "random_variant" or 
           tile.multiTileMode == "animation" or 
           tile.multiTileMode == "damage_states" then
        -- Variants/animations/damage states are stacked vertically
        return 24, 24 * frameCount
    elseif tile.multiTileMode == "autotile" then
        -- Autotiles have specific template sizes
        if tile.autotileType == "blob" then
            return 48, 48  -- 2×2
        elseif tile.autotileType == "16tile" then
            return 96, 96  -- 4×4
        elseif tile.autotileType == "47tile" then
            return 168, 168  -- 7×7
        end
    end
    
    return 24, 24
end

return MultiTile


























