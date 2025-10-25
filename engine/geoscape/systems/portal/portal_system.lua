---Portal/Multi-World System - Inter-dimensional Travel
---
---Enables travel between multiple worlds through dimensional portals. Provides advanced
---late-game mechanic for campaign expansion and world-hopping gameplay. Integrates with
---craft system, travel mechanics, and geoscape infrastructure.
---
---Portal System Architecture:
---  - Portal entities placed on world map (limited number, high strategic value)
---  - Portal activation requires tech prerequisite + energy expenditure
---  - Portal travel takes time and fuel (like normal travel)
---  - Destination portals must be discovered first
---  - Multi-world state management (separate worlds, persistent data)
---  - Cross-world interaction limited (trade, diplomacy, missions)
---
---Portal Mechanics:
---  1. Discovery: Portal discovered during exploration or anomaly event
---  2. Activation: Requires Dimensional Technology + 1000 energy credit (high cost)
---  3. Travel: 2-3 days travel time, 20 fuel cost (expensive)
---  4. Arrival: Random location on destination world (1-2 tile variation)
---  5. Return: Automatic portal back to origin (one-time per journey)
---
---Portal Features:
---  - Limited portals per world (typically 2-4)
---  - Portal pairs are bidirectional but separate instances
---  - Stable portals can be used repeatedly after discovery
---  - Unstable portals have 20% chance to fail mid-transit
---  - Portal network visualization shows connected worlds
---
---Key Exports:
---  - PortalSystem.new(): Create portal management instance
---  - createPortal(x, y, world, targetWorld): Create portal entity
---  - activatePortal(portal, craft): Enable portal for travel
---  - travelThroughPortal(craft, portal, callback): Execute cross-world travel
---  - getDiscoveredPortals(world): Get all portals in world
---
---Gameplay Integration:
---  - Ultra-late game content (100+ hours)
---  - Provides fresh strategic challenges
---  - Enables post-game exploration
---  - Allows for hidden late-game missions
---
---Dependencies:
---  - geoscape.world: World system
---  - geoscape.travel: Craft travel mechanics
---  - economy.economy_system: Energy cost deduction
---  - research: Tech prerequisites
---
---@module geoscape.systems.portal_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local PortalSystem = require("geoscape.systems.portal_system")
---  local portals = PortalSystem.new()
---  portals:createPortal(45, 23, worldA, worldB)
---  portals:activatePortal(portal, gameState)
---

local PortalSystem = {}
PortalSystem.__index = PortalSystem

--- Portal stability types
local PORTAL_TYPES = {
    stable = {
        name = "Stable Portal",
        description = "Reliable passage to destination world",
        failureChance = 0,
        travelTime = 2,  -- days
        energyCost = 1000,
        fuelCost = 20
    },
    unstable = {
        name = "Unstable Portal",
        description = "Dangerous transit with possible failures",
        failureChance = 0.20,  -- 20%
        travelTime = 3,  -- days
        energyCost = 800,  -- cheaper due to risk
        fuelCost = 15
    },
    temporary = {
        name = "Temporary Portal",
        description = "One-time use portal, closes after transit",
        failureChance = 0.10,  -- 10%
        travelTime = 1,  -- days
        energyCost = 500,  -- cheapest
        fuelCost = 10
    }
}

--- Portal discovery states
local DISCOVERY_STATE = {
    unknown = 0,      -- Not discovered
    discovered = 1,   -- Found but not activated
    activated = 2,    -- Ready for use
    locked = 3        -- Locked (hidden, requires conditions)
}

--- Initialize portal system
-- @return table Portal system instance
function PortalSystem.new()
    local self = setmetatable({}, PortalSystem)
    self.portals = {}          -- All portals: {id = portalData}
    self.worldConnections = {} -- Portal pairs: {worldA_id = {worldB_id = portal_pair}}
    self.travelHistory = {}    -- Travel records for persistence
    self.activeTransits = {}   -- Crafts currently in transit
    return self
end

--- Create portal entity
-- @param x number Portal X coordinate
-- @param y number Portal Y coordinate
-- @param originWorld table Origin world data
-- @param destinationWorld table Destination world data
-- @param portalType string Portal type (stable, unstable, temporary)
-- @return table Portal entity
-- @return string Error message if failed
function PortalSystem:createPortal(x, y, originWorld, destinationWorld, portalType)
    portalType = portalType or "stable"
    
    if not PORTAL_TYPES[portalType] then
        return nil, "Unknown portal type: " .. portalType
    end
    
    if not originWorld or not destinationWorld then
        return nil, "Invalid world data"
    end
    
    local portalData = PORTAL_TYPES[portalType]
    
    local portal = {
        id = "portal_" .. os.time() .. "_" .. math.random(10000),
        type = portalType,
        
        -- Location
        x = x,
        y = y,
        world = originWorld.id,
        
        -- Connection
        destinationWorld = destinationWorld.id,
        destinationX = math.random(0, destinationWorld.width - 1),
        destinationY = math.random(0, destinationWorld.height - 1),
        
        -- State
        discovered = false,
        activated = false,
        lastUsed = nil,
        usageCount = 0,
        
        -- Portal properties
        stability = portalData.failureChance,
        travelTime = portalData.travelTime,
        energyCost = portalData.energyCost,
        fuelCost = portalData.fuelCost,
        
        -- Type-specific
        isTemporary = (portalType == "temporary"),
        isUsed = false,  -- For temporary portals
        
        -- Visualization
        visible = false,
        glowIntensity = 0
    }
    
    self.portals[portal.id] = portal
    
    print("[PortalSystem] Portal created: " .. portal.id .. " (" .. portalType .. ")")
    return portal, nil
end

--- Discover portal (reveal to player)
-- @param portal table Portal entity
-- @param gameState table Game state
-- @return boolean Success
function PortalSystem:discoverPortal(portal, gameState)
    if not portal then
        return false
    end
    
    if portal.discovered then
        return true  -- Already discovered
    end
    
    portal.discovered = true
    portal.visible = true
    
    print("[PortalSystem] Portal discovered: " .. portal.id)
    
    -- Possible callback to research or notification system
    if gameState and gameState.research then
        -- Award discovery bonus
        if gameState.research.addBonus then
            gameState.research:addBonus("dimensional_research", 50)
        end
    end
    
    return true
end

--- Activate portal for use
-- @param portal table Portal entity
-- @param gameState table Game state (karma, economy, research)
-- @return boolean Success
-- @return string Error message if failed
function PortalSystem:activatePortal(portal, gameState)
    if not portal then
        return false, "Invalid portal"
    end
    
    if portal.activated then
        return true, "Portal already activated"
    end
    
    if not portal.discovered then
        return false, "Portal not discovered yet"
    end
    
    -- Check prerequisites
    if not gameState or not gameState.research then
        return false, "Invalid game state"
    end
    
    -- Check for dimensional technology (simplified check)
    if not gameState.research.hasDimensionalTech then
        return false, "Dimensional Technology required"
    end
    
    -- Deduct energy cost
    if gameState.economy and gameState.economy.hasCredits then
        if not gameState.economy:hasCredits(portal.energyCost) then
            return false, "Insufficient energy: need " .. portal.energyCost
        end
        gameState.economy:spendCredits(portal.energyCost)
    end
    
    portal.activated = true
    portal.glowIntensity = 1.0
    
    print("[PortalSystem] Portal activated: " .. portal.id .. " (Cost: " .. 
          portal.energyCost .. " energy)")
    
    return true, "Portal activated successfully"
end

--- Travel through portal
-- @param craft table Craft entity
-- @param portal table Portal entity
-- @param gameState table Game state
-- @param callback function Async callback(success, result)
-- @return boolean Success
-- @return string Error/status message
function PortalSystem:travelThroughPortal(craft, portal, gameState, callback)
    if not craft then
        return false, "Invalid craft"
    end
    
    if not portal or not portal.activated then
        return false, "Portal not activated"
    end
    
    if portal.isTemporary and portal.isUsed then
        return false, "Temporary portal already used (one-time only)"
    end
    
    -- Check fuel
    if craft.fuel < portal.fuelCost then
        return false, "Insufficient fuel: need " .. portal.fuelCost .. " (have " .. craft.fuel .. ")"
    end
    
    -- Consume fuel immediately
    craft.fuel = craft.fuel - portal.fuelCost
    
    -- Check for portal failure
    if math.random() < portal.stability then
        -- Transit failure
        print("[PortalSystem] Portal transit FAILED for " .. craft.id)
        
        -- Craft damaged
        if craft.armor then
            craft.armor = math.max(0, craft.armor - 20)
        end
        
        if callback then
            callback(false, {
                status = "failed",
                damage = 20,
                fuel = -portal.fuelCost,
                message = "Portal transit failed - craft damaged!"
            })
        end
        
        return false, "Portal transit failed!"
    end
    
    -- Successful transit
    print("[PortalSystem] Transit started: " .. craft.id .. " → " .. 
          portal.destinationWorld)
    
    -- Record active transit
    local transit = {
        craft = craft,
        portal = portal,
        startTime = os.time(),
        travelDays = portal.travelTime,
        destinationWorld = portal.destinationWorld,
        destinationX = portal.destinationX,
        destinationY = portal.destinationY
    }
    table.insert(self.activeTransits, transit)
    
    -- Mark temporary portal as used
    if portal.isTemporary then
        portal.isUsed = true
    end
    
    -- Update usage count
    portal.usageCount = portal.usageCount + 1
    portal.lastUsed = os.time()
    
    -- Record in travel history
    table.insert(self.travelHistory, {
        craft = craft.id,
        portalId = portal.id,
        timestamp = os.time(),
        destinationWorld = portal.destinationWorld,
        success = true
    })
    
    if callback then
        callback(true, {
            status = "transit_started",
            travelDays = portal.travelTime,
            destinationWorld = portal.destinationWorld,
            fuel = -portal.fuelCost,
            message = "Portal transit in progress (" .. portal.travelTime .. " days)"
        })
    end
    
    return true, "Transit started successfully"
end

--- Get all discovered portals
-- @param world table World data
-- @return table Array of portal entities
function PortalSystem:getDiscoveredPortals(world)
    local result = {}
    
    for _, portal in pairs(self.portals) do
        if portal.world == world.id and portal.discovered then
            table.insert(result, portal)
        end
    end
    
    return result
end

--- Get all portals in world
-- @param world table World data
-- @return table Array of portal entities
function PortalSystem:getPortalsInWorld(world)
    local result = {}
    
    for _, portal in pairs(self.portals) do
        if portal.world == world.id then
            table.insert(result, portal)
        end
    end
    
    return result
end

--- Get portal information
-- @param portal table Portal entity
-- @return table Portal info {type, destination, distance, cost, status}
function PortalSystem:getPortalInfo(portal)
    if not portal then
        return nil
    end
    
    return {
        id = portal.id,
        type = portal.type,
        discovered = portal.discovered,
        activated = portal.activated,
        destinationWorld = portal.destinationWorld,
        destinationX = portal.destinationX,
        destinationY = portal.destinationY,
        travelTime = portal.travelTime,
        energyCost = portal.energyCost,
        fuelCost = portal.fuelCost,
        stability = portal.stability,
        usageCount = portal.usageCount,
        lastUsed = portal.lastUsed,
        isTemporary = portal.isTemporary,
        isUsed = portal.isUsed
    }
end

--- Update transit progress (called once per day in-game)
-- @return table Array of completed transits
function PortalSystem:updateTransits()
    local completed = {}
    local toRemove = {}
    
    for i, transit in ipairs(self.activeTransits) do
        transit.travelDays = transit.travelDays - 1
        
        if transit.travelDays <= 0 then
            table.insert(completed, transit)
            table.insert(toRemove, i)
        end
    end
    
    -- Remove completed transits (in reverse order to preserve indices)
    for i = #toRemove, 1, -1 do
        table.remove(self.activeTransits, toRemove[i])
    end
    
    return completed
end

--- Get world network map (which worlds connect to which)
-- @return table Network structure
function PortalSystem:getWorldNetwork()
    local network = {}
    
    for _, portal in pairs(self.portals) do
        if portal.discovered then
            local from = portal.world
            local to = portal.destinationWorld
            
            if not network[from] then
                network[from] = {}
            end
            
            table.insert(network[from], {
                to = to,
                portalId = portal.id,
                type = portal.type,
                cost = portal.energyCost
            })
        end
    end
    
    return network
end

--- Get statistics
-- @return table Stats {totalPortals, discovered, activated, completed, totalDistance}
function PortalSystem:getStats()
    local totalPortals = 0
    local discovered = 0
    local activated = 0
    
    for _, portal in pairs(self.portals) do
        totalPortals = totalPortals + 1
        if portal.discovered then discovered = discovered + 1 end
        if portal.activated then activated = activated + 1 end
    end
    
    local completed = #self.travelHistory
    
    return {
        totalPortals = totalPortals,
        discovered = discovered,
        activated = activated,
        completed = completed,
        activeTransits = #self.activeTransits,
        lastTravel = self.travelHistory[#self.travelHistory]
    }
end

return PortalSystem




