---Mission Entity
---
---Represents a mission on the geoscape with cover mechanics for detection.
---Missions spawn from campaigns, move between provinces, and can be detected by
---player radar systems. Core entity for strategic gameplay.
---
---Mission Types:
---  - site: Alien site (land-based facility, terror site)
---  - ufo: UFO (airborne or landed craft)
---  - base: Alien base (underground or underwater installation)
---
---Mission States:
---  - hidden: Not yet detected, cover > 0
---  - detected: Detected by radar, cover <= 0
---  - active: Player engaged/intercepted
---  - completed: Successfully finished by player
---  - expired: Mission expired without player action
---
---Cover Mechanics:
---  - Initial cover value (e.g., 100 for hidden site)
---  - Decreases daily based on player radar coverage
---  - When cover reaches 0, mission becomes detected
---  - UFOs have lower cover (easier to detect)
---  - Bases have high cover (hard to find)
---
---Key Exports:
---  - Mission.new(data): Creates mission instance
---  - updateCover(radarStrength): Reduces cover by radar
---  - moveTo(provinceId): Moves mission to new location
---  - expire(): Marks mission as expired
---  - complete(): Marks mission as completed
---  - isDetected(): Checks if mission is visible to player
---
---Dependencies:
---  - geoscape.geography.province: Province definitions
---  - lore.factions: Faction ownership
---  - lore.campaign: Campaign spawning
---  - geoscape.systems.detection_manager: Radar detection
---
---@module lore.missions.mission
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Mission = require("lore.missions.mission")
---  local mission = Mission.new({
---    type = "ufo",
---    provinceId = "province_23",
---    cover = 50
---  })
---  mission:updateCover(radarStrength)
---  if mission:isDetected() then
---    print("UFO detected!")
---  end
---
---@see lore.missions.mission_system For mission generation
---@see geoscape.systems.detection_manager For radar detection

local Mission = {}
Mission.__index = Mission

-- Module reference for ID generation
local missionIdCounter = 1

--[[
    Create a new mission instance
    
    @param config table Configuration with following fields:
        - id: Unique mission ID (auto-generated if nil)
        - type: Mission type ("site", "ufo", "base")
        - faction: Faction object/ID
        - name: Mission name (auto-generated if nil)
        - province: Province where mission is located
        - position: {x, y} coordinates
        - biome: Biome string
        - difficulty: Mission difficulty (1+)
        - power: Mission strength/power
        - rewards: Reward table
        - duration: Days until expiration
        - coverValue: Initial cover (0-100)
        - coverMax: Maximum cover
        - coverRegen: Cover regeneration per day
        - altitude: "air", "land", "underground", "underwater"
        - speed: Movement speed (for UFOs)
        - isMoving: Whether mission is moving
        - health: Mission health
        - maxHealth: Maximum health
        - weapons: Weapon list
        - inventory: Inventory items
        - spawnDay: Day mission was spawned
    
    @return Mission instance
]]
function Mission:new(config)
    local self = setmetatable({}, Mission)
    
    -- Identity
    self.id = config.id or self:generateId()
    self.type = config.type or "site"
    self.faction = config.faction
    self.name = config.name or self:generateName()
    
    -- Location
    self.province = config.province
    self.position = config.position or {x = 0, y = 0}
    self.biome = config.biome or "plains"
    
    -- Mission properties
    self.difficulty = config.difficulty or 1
    self.power = config.power or 100
    self.rewards = config.rewards or {}
    self.duration = config.duration or 14  -- Days until expiration
    
    -- Cover mechanics (detection)
    self.coverValue = config.coverValue or 100  -- 0-100, mission hidden if > 0
    self.coverMax = config.coverMax or 100
    self.coverRegen = config.coverRegen or 5  -- Points per day
    
    -- State tracking
    self.state = "hidden"  -- "hidden", "detected", "active", "completed", "expired"
    self.detected = false
    self.daysActive = 0
    self.spawnDay = config.spawnDay or 0
    self.detectedDay = nil
    self.completedDay = nil
    self.expiredDay = nil
    
    -- Interception properties (for UFOs and combat)
    self.altitude = config.altitude or "land"
    self.speed = config.speed or 0
    self.isMoving = config.isMoving or false
    
    -- Combat properties (for interception screen)
    self.health = config.health or 100
    self.maxHealth = config.maxHealth or 100
    self.weapons = config.weapons or {}
    self.inventory = config.inventory or {}
    self.ap = 4  -- Action points (like crafts/bases)
    self.energy = 100
    self.maxEnergy = 100
    
    print(string.format("[Mission] Created mission %s (ID: %s, Type: %s, Difficulty: %d)", 
        self.name, self.id, self.type, self.difficulty))
    
    return self
end

--[[
    Generate unique mission ID
    @return string Mission ID
]]
function Mission:generateId()
    local id = string.format("MISSION_%04d", missionIdCounter)
    missionIdCounter = missionIdCounter + 1
    return id
end

--[[
    Generate mission name based on type and properties
    @return string Mission name
]]
function Mission:generateName()
    local prefixes = {
        site = {"Site", "Outpost", "Base", "Camp", "Installation"},
        ufo = {"UFO", "Craft", "Scout", "Fighter", "Battleship"},
        base = {"Base", "Facility", "Complex", "Stronghold", "Fortress"}
    }
    
    local prefix = prefixes[self.type] or prefixes.site
    local name = prefix[math.random(1, #prefix)] .. " " .. string.format("%03d", math.random(1, 999))
    
    return name
end

--[[
    Update mission state for elapsed days
    
    @param daysPassed number Days that have passed
]]
function Mission:update(daysPassed)
    self.daysActive = self.daysActive + daysPassed
    
    -- Regenerate cover if not detected
    if self.state == "hidden" then
        self.coverValue = math.min(self.coverMax, self.coverValue + (self.coverRegen * daysPassed))
    end
    
    -- Expire mission if too old
    if self.daysActive >= self.duration then
        self:expire()
    end
end

--[[
    Reduce mission cover by radar scanning
    
    @param radarPower number Power of radar scan
]]
function Mission:reduceCover(radarPower)
    if self.state ~= "hidden" then
        return  -- Only hidden missions have cover
    end
    
    self.coverValue = math.max(0, self.coverValue - radarPower)
    
    -- Detect mission if cover depleted
    if self.coverValue <= 0 and not self.detected then
        self:onDetected()
    end
end

--[[
    Called when mission is detected
    
    @param currentDay number Current game day (optional)
]]
function Mission:onDetected(currentDay)
    self.detected = true
    self.state = "detected"
    self.detectedDay = currentDay or self.spawnDay + self.daysActive
    
    print(string.format("[Mission] %s DETECTED! Type: %s, Difficulty: %d, Power: %d", 
        self.name, self.type, self.difficulty, self.power))
end

--[[
    Mark mission as active (player engaged)
    
    @param currentDay number Current game day (optional)
]]
function Mission:activate(currentDay)
    self.state = "active"
    print(string.format("[Mission] %s activated by player", self.name))
end

--[[
    Mark mission as completed
    
    @param currentDay number Current game day (optional)
]]
function Mission:complete(currentDay)
    self.state = "completed"
    self.completedDay = currentDay or self.spawnDay + self.daysActive
    print(string.format("[Mission] %s completed after %d days", self.name, self.daysActive))
end

--[[
    Mark mission as expired
    
    @param currentDay number Current game day (optional)
]]
function Mission:expire(currentDay)
    self.state = "expired"
    self.expiredDay = currentDay or self.spawnDay + self.daysActive
    print(string.format("[Mission] %s expired after %d days (not intercepted)", 
        self.name, self.daysActive))
end

--[[
    Get appropriate icon name for mission display
    
    @return string Icon name
]]
function Mission:getIcon()
    if self.type == "ufo" then
        if self.altitude == "air" then
            return "ufo_air"
        else
            return "ufo_landed"
        end
    elseif self.type == "site" then
        return "alien_site"
    elseif self.type == "base" then
        if self.altitude == "underground" then
            return "alien_base_underground"
        else
            return "alien_base_underwater"
        end
    end
    return "mission_unknown"
end

--[[
    Get mission info for display/tooltip
    
    @return table Info with keys: type, name, difficulty, power, state, daysActive, biome
]]
function Mission:getInfo()
    return {
        type = self.type,
        name = self.name,
        difficulty = self.difficulty,
        power = self.power,
        state = self.state,
        daysActive = self.daysActive,
        biome = self.biome,
        altitude = self.altitude,
        coverValue = self.coverValue,
        detected = self.detected,
        position = self.position,
    }
end

--[[
    Check if mission is valid and active
    
    @return boolean True if mission is in valid state
]]
function Mission:isValid()
    return self.state == "hidden" or self.state == "detected" or self.state == "active"
end

--[[
    Serialize mission to saveable table
    
    @return table Serialized mission data
]]
function Mission:serialize()
    return {
        id = self.id,
        type = self.type,
        faction = self.faction,
        name = self.name,
        province = self.province,
        position = self.position,
        biome = self.biome,
        difficulty = self.difficulty,
        power = self.power,
        rewards = self.rewards,
        duration = self.duration,
        coverValue = self.coverValue,
        coverMax = self.coverMax,
        coverRegen = self.coverRegen,
        state = self.state,
        detected = self.detected,
        daysActive = self.daysActive,
        spawnDay = self.spawnDay,
        detectedDay = self.detectedDay,
        completedDay = self.completedDay,
        expiredDay = self.expiredDay,
        altitude = self.altitude,
        speed = self.speed,
        isMoving = self.isMoving,
        health = self.health,
        maxHealth = self.maxHealth,
        weapons = self.weapons,
        inventory = self.inventory,
        ap = self.ap,
        energy = self.energy,
        maxEnergy = self.maxEnergy,
    }
end

--[[
    Deserialize mission from saved data
    
    @param data table Serialized mission data
    @return Mission Restored mission instance
]]
function Mission.deserialize(data)
    local mission = Mission:new(data)
    
    -- Restore state fields
    mission.state = data.state
    mission.detected = data.detected
    mission.daysActive = data.daysActive
    mission.detectedDay = data.detectedDay
    mission.completedDay = data.completedDay
    mission.expiredDay = data.expiredDay
    
    return mission
end

return Mission


























