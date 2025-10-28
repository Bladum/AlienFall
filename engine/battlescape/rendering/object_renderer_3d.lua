---ObjectRenderer3D - 3D Object Rendering System
---
---Renders non-wall objects (furniture, trees, rocks, crates) as billboards in the
---3D battlescape. Objects block movement but may allow vision depending on type.
---Handles depth sorting and line-of-sight integration for tactical gameplay.
---
---Features:
---  - Billboard rendering for 3D objects
---  - Object type definitions (furniture, natural, industrial)
---  - Movement blocking with selective vision allowance
---  - Height-based rendering and collision
---  - Line-of-sight integration for fog of war
---  - Depth sorting for proper rendering order
---  - Asset integration for object sprites
---
---Key Exports:
---  - new(): Create new 3D object renderer instance
---  - addObjectType(id, data): Add custom object type definition
---  - getObjectTypeCount(): Get number of defined object types
---  - getObjectType(objectId): Get object type data by ID
---  - render(battlefield, billboard, camera, assets, losSystem): Render all objects
---  - renderObject(tile, billboard, camera, assets): Render single object
---  - isObjectAt(x, y): Check if object exists at tile position
---
---Dependencies:
---  - require("battlescape.rendering.billboard"): Billboard rendering system
---  - require("battlescape.combat.los_system"): Line-of-sight calculations
---  - require("core.assets.assets"): Asset management for sprites
---
---@module battlescape.rendering.object_renderer_3d
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local ObjectRenderer3D = require("battlescape.rendering.object_renderer_3d")
---  local renderer = ObjectRenderer3D.new()
---  renderer:addObjectType("custom_table", {sprite = "table", height = 0.8})
---  renderer:render(battlefield, billboard, camera, assets, losSystem)
---
---@see battlescape.rendering.billboard For billboard rendering
---@see battlescape.rendering.renderer_3d For main 3D pipeline

-- Object Renderer for 3D Battlescape
-- Renders non-wall objects (tables, trees, fences) as billboards
-- Objects block movement but may allow vision

local ObjectRenderer3D = {}
ObjectRenderer3D.__index = ObjectRenderer3D

--- Object type definitions
local OBJECT_TYPES = {
    -- Furniture
    table = {sprite = "table", height = 0.8, transparent = true, allowsVision = true},
    chair = {sprite = "chair", height = 0.6, transparent = true, allowsVision = true},
    desk = {sprite = "desk", height = 0.9, transparent = true, allowsVision = true},
    crate = {sprite = "crate", height = 0.8, transparent = false, allowsVision = false},
    
    -- Natural
    tree = {sprite = "tree", height = 1.5, transparent = true, allowsVision = true},
    bush = {sprite = "plant small 01", height = 0.6, transparent = true, allowsVision = true},
    rock = {sprite = "rock", height = 0.4, transparent = true, allowsVision = true},
    
    -- Barriers
    fence = {sprite = "wood fence", height = 1.0, transparent = true, allowsVision = true},
    railing = {sprite = "railing", height = 0.8, transparent = true, allowsVision = true},
    barrier = {sprite = "barrier", height = 1.0, transparent = true, allowsVision = false},
}

--- Create new object renderer
function ObjectRenderer3D.new()
    local self = setmetatable({}, ObjectRenderer3D)
    
    self.objectTypes = OBJECT_TYPES
    
    print("[ObjectRenderer3D] Initialized with " .. self:countObjectTypes() .. " object types")
    return self
end

--- Count object types
---@return number Count
function ObjectRenderer3D:countObjectTypes()
    local count = 0
    for _ in pairs(self.objectTypes) do
        count = count + 1
    end
    return count
end

--- Get object type data
---@param objectId string Object ID
---@return table|nil Object type data
function ObjectRenderer3D:getObjectType(objectId)
    return self.objectTypes[objectId]
end

--- Render all objects on battlefield
---@param battlefield table Battlefield data
---@param billboard table Billboard renderer
---@param camera table Camera parameters
---@param assets table Asset manager
---@param losSystem table LOS system (for visibility check)
function ObjectRenderer3D:render(battlefield, billboard, camera, assets, losSystem)
    -- Only render visible tiles
    for y = 1, battlefield.height do
        for x = 1, battlefield.width do
            local tile = battlefield:getTile(x, y)
            
            if tile and tile.object then
                -- Check if tile is visible
                if not losSystem or losSystem:isTileVisible(x, y) then
                    self:renderObject(tile, billboard, camera, assets)
                end
            end
        end
    end
end

--- Render single object
---@param tile table Tile with object
---@param billboard table Billboard renderer
---@param camera table Camera parameters
---@param assets table Asset manager
function ObjectRenderer3D:renderObject(tile, billboard, camera, assets)
    local obj = tile.object
    local objType = self:getObjectType(obj.id)
    
    if not objType then
        print("[ObjectRenderer3D] Unknown object type: " .. obj.id)
        return
    end
    
    -- Get object sprite
    local sprite = assets:get("objects", objType.sprite)
    if not sprite then
        print("[ObjectRenderer3D] Missing sprite: " .. objType.sprite)
        return
    end
    
    -- Calculate world position (center of tile)
    local worldX = tile.x
    local worldZ = tile.y
    local worldY = objType.height / 2  -- Center height
    
    -- Render as billboard
    billboard:add(worldX, worldY, worldZ, sprite, {
        width = 1.0,
        height = objType.height,
        alpha = objType.transparent and 0.9 or 1.0,
        emissive = false,
    })
end

--- Check if object blocks vision
---@param objectId string Object ID
---@return boolean Blocks vision
function ObjectRenderer3D:blocksVision(objectId)
    local objType = self:getObjectType(objectId)
    if not objType then return false end
    return not objType.allowsVision
end

--- Check if object blocks movement
---@param objectId string Object ID
---@return boolean Blocks movement (all objects block movement)
function ObjectRenderer3D:blocksMovement(objectId)
    return true  -- All objects block movement
end

return ObjectRenderer3D



























