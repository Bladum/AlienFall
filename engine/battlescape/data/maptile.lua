---MapTile - Single Hex Tile Definition
---
---Represents a single hex cell tile with KEY-based identification. Defines visual
---appearance, passability, line of sight blocking, cover level, and tactical properties.
---Core data structure for all battlefield tiles.
---
---Features:
---  - KEY-based unique identification (UPPER_SNAKE_CASE)
---  - Visual properties (image, height)
---  - Passability and LOS blocking
---  - Cover levels (none/light/heavy/full)
---  - Destructibility and health
---  - Flammability for fire system
---
---Tile Properties:
---  - key: Unique identifier (e.g., "WALL_BRICK_01")
---  - name: Display name (e.g., "Brick Wall")
---  - tileset: Parent tileset folder name
---  - image: PNG filename relative to tileset
---  - passable: Can units walk through? (boolean)
---  - blocksLOS: Blocks line of sight? (boolean)
---  - cover: Cover level ("none", "light", "heavy", "full")
---  - height: Vertical offset in pixels (for stacking)
---  - destructible: Can be destroyed? (boolean)
---  - health: Hit points if destructible
---  - flammable: Can catch fire? (boolean)
---
---Cover Levels:
---  - "none": No protection (0%)
---  - "light": 25% hit penalty to attacker
---  - "heavy": 40% hit penalty to attacker
---  - "full": 60% hit penalty to attacker
---
---Key Exports:
---  - MapTile.new(params): Creates new MapTile
---  - MapTile.validate(tile): Validates tile data
---  - MapTile.clone(tile): Deep copy of tile
---  - MapTile.serialize(tile): Converts to saveable format
---
---Dependencies:
---  - None (pure data structure)
---
---@module battlescape.data.maptile
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MapTile = require("battlescape.data.maptile")
---  local wall = MapTile.new({
---      key = "WALL_BRICK_01",
---      name = "Brick Wall",
---      passable = false,
---      blocksLOS = true,
---      cover = "full"
---  })
---
---@see battlescape.data.tilesets For tileset management

-- Map Tile Definition
-- Represents a single hex cell tile with KEY-based identification

---@class MapTile
---@field key string Unique identifier (UPPER_SNAKE_CASE)
---@field name string Display name
---@field tileset string Parent tileset folder name
---@field image string PNG filename relative to tileset folder
---@field passable boolean Can units walk through this tile?
---@field blocksLOS boolean Blocks line of sight?
---@field cover string Cover level: "none", "light", "heavy", "full"
---@field height number Vertical offset in pixels
---@field destructible boolean Can be destroyed?
---@field health number Hit points (if destructible)
---@field flammable boolean Can catch fire?
---@field multiTileMode string? Multi-tile mode: "random_variant", "animation", "autotile", "occupy", "damage_states"
---@field variantCount number? Number of variants (for random_variant mode)
---@field frameCount number? Number of animation frames (for animation mode)
---@field frameDelay number? Milliseconds per frame (for animation mode)
---@field looping boolean? Loop animation? (for animation mode)
---@field pingpong boolean? Reverse at end? (for animation mode)
---@field autotileType string? Autotile algorithm: "blob", "16tile", "47tile"
---@field cellWidth number? Cells wide (for occupy mode)
---@field cellHeight number? Cells tall (for occupy mode)
---@field anchorPoint table? Origin cell [x, y] (for occupy mode)
---@field blockAllCells boolean? All cells block movement? (for occupy mode)
---@field damageStates number? Number of damage states
---@field damageThresholds table? Array of {minHealth, maxHealth, frame}
---@field validate fun(self): boolean, string? Validate tile definition

local MapTile = {}
MapTile.__index = MapTile

---Create a new Map Tile from definition table
---@param def table Tile definition from TOML
---@return MapTile
function MapTile.new(def)
    local self = setmetatable({}, MapTile)
    
    -- Required properties
    self.key = def.key or error("MapTile requires a key")
    self.name = def.name or self.key
    self.tileset = def.tileset or error("MapTile requires a tileset")
    self.image = def.image or error("MapTile requires an image")
    
    -- Basic properties with defaults
    self.passable = def.passable ~= false  -- Default true
    self.blocksLOS = def.blocksLOS or false
    self.cover = def.cover or "none"
    self.height = def.height or 0
    self.destructible = def.destructible or false
    self.health = def.health or 0
    self.flammable = def.flammable or false
    
    -- Multi-tile properties
    self.multiTileMode = def.multiTileMode
    
    -- Variant mode
    self.variantCount = def.variantCount
    
    -- Animation mode
    self.frameCount = def.frameCount
    self.frameDelay = def.frameDelay or 200
    self.looping = def.looping ~= false  -- Default true
    self.pingpong = def.pingpong or false
    
    -- Autotile mode
    self.autotileType = def.autotileType
    
    -- Occupy mode
    self.cellWidth = def.cellWidth
    self.cellHeight = def.cellHeight
    self.anchorPoint = def.anchorPoint or {0, 0}
    self.blockAllCells = def.blockAllCells ~= false  -- Default true
    
    -- Damage states mode
    self.damageStates = def.damageStates
    self.damageThresholds = def.damageThresholds
    
    return self
end

---Check if this is a multi-tile
---@return boolean
function MapTile:isMultiTile()
    return self.multiTileMode ~= nil
end

---Get the dimensions in pixels (width, height)
---@return number, number
function MapTile:getPixelDimensions()
    if self.multiTileMode == "occupy" and self.cellWidth and self.cellHeight then
        return self.cellWidth * 24, self.cellHeight * 24
    end
    return 24, 24
end

---Get the dimensions in cells (width, height)
---@return number, number
function MapTile:getCellDimensions()
    if self.multiTileMode == "occupy" then
        return self.cellWidth or 1, self.cellHeight or 1
    end
    return 1, 1
end

---Check if tile is passable
---@return boolean
function MapTile:isPassable()
    return self.passable
end

---Check if tile blocks line of sight
---@return boolean
function MapTile:blocksLineOfSight()
    return self.blocksLOS
end

---Get cover value
---@return string "none", "light", "heavy", or "full"
function MapTile:getCover()
    return self.cover
end

---Check if tile is destructible
---@return boolean
function MapTile:isDestructible()
    return self.destructible
end

---Get maximum health
---@return number
function MapTile:getMaxHealth()
    return self.health
end

---Check if tile is flammable
---@return boolean
function MapTile:isFlammable()
    return self.flammable
end

---Get damage state frame for given health percentage
---@param healthPercent number 0-100
---@return number Frame index (0-based)
function MapTile:getDamageStateFrame(healthPercent)
    if not self.damageThresholds then
        return 0
    end
    
    for _, threshold in ipairs(self.damageThresholds) do
        if healthPercent >= threshold.minHealth and healthPercent <= threshold.maxHealth then
            return threshold.frame
        end
    end
    
    return 0
end

---Get full image path
---@return string
function MapTile:getImagePath()
    return string.format("mods/core/tilesets/%s/%s", self.tileset, self.image)
end

---Validate tile definition
---@return boolean success
---@return string? errorMessage
function MapTile:validate()
    -- Check key format
    if not self.key:match("^[A-Z_]+$") then
        return false, string.format("Invalid key format: %s (must be UPPER_SNAKE_CASE)", self.key)
    end
    
    -- Check cover value
    local validCover = {none = true, light = true, heavy = true, full = true}
    if not validCover[self.cover] then
        return false, string.format("Invalid cover value: %s", self.cover)
    end
    
    -- Check multi-tile mode
    if self.multiTileMode then
        local validModes = {
            random_variant = true,
            animation = true,
            autotile = true,
            occupy = true,
            damage_states = true
        }
        if not validModes[self.multiTileMode] then
            return false, string.format("Invalid multiTileMode: %s", self.multiTileMode)
        end
    end
    
    -- Check autotile type
    if self.autotileType then
        local validTypes = {blob = true, ["16tile"] = true, ["47tile"] = true}
        if not validTypes[self.autotileType] then
            return false, string.format("Invalid autotileType: %s", self.autotileType)
        end
    end
    
    return true
end

---Validate tile definition
---@return boolean valid
---@return string? error_message
function MapTile:validate()
    -- Check required fields
    if not self.key or self.key == "" then
        return false, "Missing or empty key"
    end
    
    if not self.name or self.name == "" then
        return false, "Missing or empty name"
    end
    
    if not self.tileset or self.tileset == "" then
        return false, "Missing or empty tileset"
    end
    
    if not self.image or self.image == "" then
        return false, "Missing or empty image"
    end
    
    -- Validate cover values
    if self.cover and not (self.cover == "none" or self.cover == "light" or self.cover == "heavy" or self.cover == "full") then
        return false, "Invalid cover value: " .. tostring(self.cover)
    end
    
    -- Validate multi-tile mode specific fields
    if self.multiTileMode then
        if self.multiTileMode == "random_variant" and not self.variantCount then
            return false, "random_variant mode requires variantCount"
        elseif self.multiTileMode == "animation" and not self.frameCount then
            return false, "animation mode requires frameCount"
        elseif self.multiTileMode == "autotile" and not self.autotileType then
            return false, "autotile mode requires autotileType"
        elseif self.multiTileMode == "occupy" and (not self.cellWidth or not self.cellHeight) then
            return false, "occupy mode requires cellWidth and cellHeight"
        elseif self.multiTileMode == "damage_states" and not self.damageStates then
            return false, "damage_states mode requires damageStates"
        end
    end
    
    return true, nil
end

---Create a string representation
---@return string
function MapTile:__tostring()
    return string.format("MapTile[%s] (%s/%s)", self.key, self.tileset, self.image)
end

return MapTile


























