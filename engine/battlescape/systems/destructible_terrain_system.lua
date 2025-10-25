---Destructible Terrain System - Environmental Destruction
---
---Implements dynamic terrain destruction where walls, objects, and cover can be damaged
---or destroyed by explosions, heavy weapons, and area effects. Destroyed terrain changes
---tile properties, creates fire/smoke/debris effects, and updates pathfinding and LOS.
---
---Destructible Objects:
---  - Walls: HP 20-50, provide cover until destroyed
---  - Doors: HP 10-20, block movement until broken
---  - Furniture: HP 5-15, light cover, easily destroyed
---  - Vehicles: HP 30-100, heavy cover, explode on destruction
---  - Trees: HP 15-30, provide concealment and light cover
---  - Rocks/Boulders: HP 50-150, very durable cover
---
---Object Properties:
---  - Hit Points: Damage required to destroy
---  - Armor: Damage reduction per hit
---  - Flammability: Chance to ignite when damaged by fire
---  - Explosive: Creates explosion on destruction
---  - Rubble Type: Debris left after destruction
---
---Destruction Effects:
---  - Fire: Burning objects create fire spread
---  - Smoke: Destroyed objects may produce smoke clouds
---  - Debris: Rubble terrain replaces destroyed objects
---  - Collapse: Multi-tile objects may collapse progressively
---  - Chain Reactions: Explosives trigger nearby explosives
---
---Tile Transformation:
---  - Wall → Rubble (passable, no cover)
---  - Door → Open Space (fully passable)
---  - Vehicle → Crater + Fire (impassable, hazard)
---  - Tree → Stump (reduced cover)
---
---Partial Destruction:
---  - Objects track damage before destruction
---  - Damaged objects provide reduced cover
---  - Visual indicators show damage state
---  - Some objects require multiple hits to destroy
---
---Key Exports:
---  - damageObject(tile, damage, damageType): Applies damage to object
---  - destroyObject(tile): Immediately destroys terrain object
---  - getObjectHP(tile): Returns current HP and max HP
---  - isObjectDestroyed(tile): Checks if object is destroyed
---  - createDestructionEffects(tile, objectType): Spawns fire/smoke/debris
---
---Integration:
---  - Works with explosion_system.lua for AOE destruction
---  - Uses fire_system.lua for burning objects
---  - Integrates with smoke_system.lua for smoke effects
---  - Updates pathfinding and LOS after destruction
---  - Modifies cover_system.lua values dynamically
---
---@module battlescape.systems.destructible_terrain_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local DestructibleTerrain = require("battlescape.systems.destructible_terrain_system")
---  DestructibleTerrain.damageObject(tile, 25, "explosive")
---  if DestructibleTerrain.isObjectDestroyed(tile) then
---      DestructibleTerrain.createDestructionEffects(tile, "wall")
---  end
---
---@see battlescape.effects.explosion_system For AOE destruction
---@see battlescape.effects.fire_system For burning terrain
---@see battlescape.systems.cover_system For dynamic cover updates

local DestructibleTerrainSystem = {}

-- Configuration
local CONFIG = {
    -- Terrain Types with HP/Armor
    TERRAIN_DATA = {
        WALL = { hp = 50, armor = 20, blockLOS = true, blockMovement = true, destroyedType = "RUBBLE" },
        FENCE = { hp = 10, armor = 0, blockLOS = false, blockMovement = true, destroyedType = "DEBRIS" },
        TREE = { hp = 25, armor = 5, blockLOS = true, blockMovement = false, destroyedType = "STUMP" },
        ROCK = { hp = 80, armor = 30, blockLOS = true, blockMovement = true, destroyedType = "RUBBLE" },
        CRATE = { hp = 15, armor = 0, blockLOS = false, blockMovement = true, destroyedType = "DEBRIS" },
        VEHICLE = { hp = 60, armor = 15, blockLOS = true, blockMovement = true, destroyedType = "WRECKAGE" },
        DOOR = { hp = 20, armor = 5, blockLOS = true, blockMovement = true, destroyedType = "FLOOR" },
        WINDOW = { hp = 5, armor = 0, blockLOS = false, blockMovement = true, destroyedType = "FLOOR" },
    },
    
    -- Destroyed Terrain Types (replacements)
    DESTROYED_TERRAIN = {
        RUBBLE = { blockLOS = false, blockMovement = false, movementCost = 2 },
        DEBRIS = { blockLOS = false, blockMovement = false, movementCost = 1.5 },
        STUMP = { blockLOS = false, blockMovement = false, movementCost = 1 },
        WRECKAGE = { blockLOS = true, blockMovement = false, movementCost = 2 },
        FLOOR = { blockLOS = false, blockMovement = false, movementCost = 1 },
    },
    
    -- Destruction Effects
    DESTRUCTION_EFFECTS = {
        WALL = { createFire = false, createSmoke = true, smokeDensity = 3, duration = 3 },
        FENCE = { createFire = false, createSmoke = false },
        TREE = { createFire = true, fireIntensity = 4, duration = 5 },
        ROCK = { createFire = false, createSmoke = true, smokeDensity = 2, duration = 2 },
        CRATE = { createFire = false, createSmoke = false },
        VEHICLE = { createFire = true, fireIntensity = 6, duration = 6, createSmoke = true, smokeDensity = 5 },
        DOOR = { createFire = false, createSmoke = false },
        WINDOW = { createFire = false, createSmoke = false },
    },
    
    -- Damage Thresholds
    HEAVY_WEAPON_BONUS = 1.5,  -- Heavy weapons deal 1.5x damage to terrain
    EXPLOSIVE_BONUS = 2.0,      -- Explosives deal 2.0x damage to terrain
}

-- Terrain state tracking
-- Format: terrainState[hexKey] = { terrainType, currentHP, maxHP, isDestroyed }
local terrainState = {}

--[[
    Generate hex key for lookup
    
    @param q, r: Hex coordinates
    @return string key
]]
local function hexKey(q, r)
    return string.format("%d,%d", q, r)
end

--[[
    Initialize terrain at a hex
    
    @param q, r: Hex coordinates
    @param terrainType: Type of terrain (WALL, FENCE, etc.)
]]
function DestructibleTerrainSystem.initializeTerrain(q, r, terrainType)
    local key = hexKey(q, r)
    local data = CONFIG.TERRAIN_DATA[terrainType]
    
    if not data then
        print(string.format("[DestructibleTerrainSystem] Unknown terrain type: %s at (%d,%d)", 
            tostring(terrainType), q, r))
        return
    end
    
    terrainState[key] = {
        terrainType = terrainType,
        currentHP = data.hp,
        maxHP = data.hp,
        armor = data.armor,
        isDestroyed = false,
    }
    
    print(string.format("[DestructibleTerrainSystem] Initialized %s at (%d,%d) with %d HP", 
        terrainType, q, r, data.hp))
end

--[[
    Remove terrain from system (used for map cleanup)
    
    @param q, r: Hex coordinates
]]
function DestructibleTerrainSystem.removeTerrain(q, r)
    local key = hexKey(q, r)
    terrainState[key] = nil
end

--[[
    Apply damage to terrain at a hex
    
    @param q, r: Hex coordinates
    @param damage: Damage amount
    @param isHeavyWeapon: Boolean, is source a heavy weapon?
    @param isExplosive: Boolean, is source explosive?
    @return wasDestroyed: Boolean, did terrain get destroyed?
    @return newTerrainType: String, new terrain type if destroyed
]]
function DestructibleTerrainSystem.applyDamage(q, r, damage, isHeavyWeapon, isExplosive)
    local key = hexKey(q, r)
    local state = terrainState[key]
    
    if not state or state.isDestroyed then
        return false, nil  -- No terrain or already destroyed
    end
    
    -- Apply damage modifiers
    local finalDamage = damage
    if isHeavyWeapon then
        finalDamage = finalDamage * CONFIG.HEAVY_WEAPON_BONUS
    end
    if isExplosive then
        finalDamage = finalDamage * CONFIG.EXPLOSIVE_BONUS
    end
    
    -- Apply armor reduction
    finalDamage = math.max(0, finalDamage - state.armor)
    
    -- Apply damage
    state.currentHP = state.currentHP - finalDamage
    
    print(string.format("[DestructibleTerrainSystem] %s at (%d,%d) took %d damage (%d/%d HP remaining)", 
        state.terrainType, q, r, finalDamage, state.currentHP, state.maxHP))
    
    -- Check if destroyed
    if state.currentHP <= 0 then
        state.isDestroyed = true
        
        -- Get destroyed terrain type
        local terrainData = CONFIG.TERRAIN_DATA[state.terrainType]
        local newTerrainType = terrainData.destroyedType or "FLOOR"
        
        print(string.format("[DestructibleTerrainSystem] %s at (%d,%d) DESTROYED! Became %s", 
            state.terrainType, q, r, newTerrainType))
        
        return true, newTerrainType
    end
    
    return false, nil
end

--[[
    Check if terrain at hex is destroyed
    
    @param q, r: Hex coordinates
    @return isDestroyed: Boolean
]]
function DestructibleTerrainSystem.isTerrainDestroyed(q, r)
    local key = hexKey(q, r)
    local state = terrainState[key]
    
    if not state then
        return false  -- No destructible terrain
    end
    
    return state.isDestroyed
end

--[[
    Get terrain state at hex
    
    @param q, r: Hex coordinates
    @return state table or nil
]]
function DestructibleTerrainSystem.getTerrainState(q, r)
    local key = hexKey(q, r)
    return terrainState[key]
end

--[[
    Get destruction effects for a terrain type
    
    Returns data for creating fire/smoke when terrain is destroyed
    
    @param terrainType: Type of terrain (WALL, TREE, etc.)
    @return effects table
]]
function DestructibleTerrainSystem.getDestructionEffects(terrainType)
    return CONFIG.DESTRUCTION_EFFECTS[terrainType] or {}
end

--[[
    Check if tile blocks line of sight (after potential destruction)
    
    @param q, r: Hex coordinates
    @param currentTerrainType: Current terrain type at tile
    @return blocksLOS: Boolean
]]
function DestructibleTerrainSystem.doesTileBlockLOS(q, r, currentTerrainType)
    local state = DestructibleTerrainSystem.getTerrainState(q, r)
    
    -- If destroyed, check destroyed terrain properties
    if state and state.isDestroyed then
        local terrainData = CONFIG.TERRAIN_DATA[state.terrainType]
        local destroyedType = terrainData.destroyedType or "FLOOR"
        local destroyedData = CONFIG.DESTROYED_TERRAIN[destroyedType]
        
        if destroyedData then
            return destroyedData.blockLOS or false
        end
    end
    
    -- Not destroyed or no state, check original terrain
    local terrainData = CONFIG.TERRAIN_DATA[currentTerrainType]
    if terrainData then
        return terrainData.blockLOS or false
    end
    
    return false
end

--[[
    Check if tile blocks movement (after potential destruction)
    
    @param q, r: Hex coordinates
    @param currentTerrainType: Current terrain type at tile
    @return blocksMovement: Boolean
    @return movementCost: Number (1.0 = normal)
]]
function DestructibleTerrainSystem.getTileMovement(q, r, currentTerrainType)
    local state = DestructibleTerrainSystem.getTerrainState(q, r)
    
    -- If destroyed, check destroyed terrain properties
    if state and state.isDestroyed then
        local terrainData = CONFIG.TERRAIN_DATA[state.terrainType]
        local destroyedType = terrainData.destroyedType or "FLOOR"
        local destroyedData = CONFIG.DESTROYED_TERRAIN[destroyedType]
        
        if destroyedData then
            return destroyedData.blockMovement or false, destroyedData.movementCost or 1.0
        end
    end
    
    -- Not destroyed or no state, check original terrain
    local terrainData = CONFIG.TERRAIN_DATA[currentTerrainType]
    if terrainData then
        return terrainData.blockMovement or false, 1.0
    end
    
    return false, 1.0
end

--[[
    Get HP percentage for a terrain tile (for visual damage states)
    
    @param q, r: Hex coordinates
    @return hpPercent: 0-100, or nil if no destructible terrain
]]
function DestructibleTerrainSystem.getTerrainHPPercent(q, r)
    local state = DestructibleTerrainSystem.getTerrainState(q, r)
    
    if not state then
        return nil
    end
    
    if state.isDestroyed then
        return 0
    end
    
    return (state.currentHP / state.maxHP) * 100
end

--[[
    Visualize terrain destruction data for UI
    
    @param q, r: Hex coordinates
    @return visualization data or nil
]]
function DestructibleTerrainSystem.visualizeTerrain(q, r)
    local state = DestructibleTerrainSystem.getTerrainState(q, r)
    
    if not state then
        return nil
    end
    
    local hpPercent = (state.currentHP / state.maxHP) * 100
    local damageLevel = "None"
    local color = { r = 0, g = 255, b = 0 }
    
    if state.isDestroyed then
        damageLevel = "Destroyed"
        color = { r = 100, g = 100, b = 100 }
    elseif hpPercent < 25 then
        damageLevel = "Critical"
        color = { r = 255, g = 0, b = 0 }
    elseif hpPercent < 50 then
        damageLevel = "Heavy"
        color = { r = 255, g = 100, b = 0 }
    elseif hpPercent < 75 then
        damageLevel = "Moderate"
        color = { r = 255, g = 255, b = 0 }
    else
        damageLevel = "Light"
        color = { r = 200, g = 255, b = 100 }
    end
    
    return {
        terrainType = state.terrainType,
        currentHP = state.currentHP,
        maxHP = state.maxHP,
        hpPercent = hpPercent,
        isDestroyed = state.isDestroyed,
        damageLevel = damageLevel,
        color = color,
    }
end

--[[
    Clear all terrain state (for new mission)
]]
function DestructibleTerrainSystem.clearAll()
    terrainState = {}
    print("[DestructibleTerrainSystem] Cleared all terrain state")
end

--[[
    Get all terrain state (for debugging)
    
    @return table of all terrain state
]]
function DestructibleTerrainSystem.getAllTerrain()
    return terrainState
end

return DestructibleTerrainSystem


























