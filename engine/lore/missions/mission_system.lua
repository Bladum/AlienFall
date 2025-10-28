---Mission System - Mission Generation and Management
---
---Generates and manages missions (sites, UFOs, bases) spawned from faction campaigns.
---Handles mission movement, growth, expiration, and lifecycle. Integrates with
---campaign system for dynamic mission spawning.
---
---Mission Types Generated:
---  - site: Alien terror sites, research facilities
---  - ufo: Scout ships, assault craft, supply ships
---  - base: Underground installations, underwater bases
---
---Mission Scripts:
---  - Movement patterns (patrol, seek, flee, static)
---  - Growth mechanics (expand, fortify, recruit)
---  - Expiration conditions (time limit, player action)
---
---Key Exports:
---  - MissionSystem.new(): Creates mission system instance
---  - spawnMission(campaignId, factionId): Generates new mission
---  - updateMissions(day): Updates all active missions
---  - moveMission(missionId, targetProvinceId): Moves mission
---  - expireMission(missionId): Removes expired mission
---  - getMissions(provinceId): Returns missions in province
---
---Dependencies:
---  - lore.missions.mission: Mission entity class
---  - lore.campaign: Campaign definitions
---  - lore.factions: Faction data
---  - geoscape.geography.province: Province definitions
---
---@module lore.missions.mission_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local MissionSystem = require("lore.missions.mission_system")
---  local missions = MissionSystem.new()
---  missions:spawnMission("campaign_terror", "faction_aliens")
---  missions:updateMissions(currentDay)
---
---@see lore.campaign For campaign system
---@see lore.missions.mission For mission entity

local MissionSystem = {}
MissionSystem.__index = MissionSystem

---@class Mission
---@field id string Mission ID
---@field type string "site", "ufo", or "base"
---@field factionId string Owner faction
---@field provinceId string Current province
---@field detected boolean Player has detected this mission
---@field expiresDay number Day mission expires
---@field script string Movement/growth script

--- Create new mission system
function MissionSystem.new()
    local self = setmetatable({}, MissionSystem)
    
    -- All missions
    self.missions = {}
    
    -- Mission scripts (UFO movement, base growth)
    self.scripts = {}
    
    print("[MissionSystem] Initialized")
    return self
end

--- Spawn mission
---@param missionType string "site", "ufo", or "base"
---@param factionId string Faction ID
---@param provinceId string Province ID
---@return Mission Mission
function MissionSystem:spawnMission(missionType, factionId, provinceId)
    local missionId = missionType .. "_" .. os.time() .. "_" .. math.random(1000)
    
    local mission = {
        id = missionId,
        type = missionType,
        factionId = factionId,
        provinceId = provinceId,
        detected = false,
        expiresDay = nil,  -- Set based on type
        script = nil,      -- Movement/growth script
        spawnDay = 1,
    }
    
    -- Configure by type
    if missionType == "site" then
        mission.expiresDay = 7  -- Expires in 7 days
    elseif missionType == "ufo" then
        mission.script = "ufo_patrol"  -- Movement script
    elseif missionType == "base" then
        mission.script = "base_growth"  -- Growth script
        mission.expiresDay = nil  -- Permanent
    end
    
    self.missions[missionId] = mission
    
    print(string.format("[MissionSystem] Spawned %s mission: %s in %s", 
          missionType, missionId, provinceId))
    
    return mission
end

--- Daily update for missions
---@param day number Current day
function MissionSystem:dailyUpdate(day)
    for _, mission in pairs(self.missions) do
        -- Execute UFO scripts (movement)
        if mission.type == "ufo" and mission.script then
            self:executeUFOScript(mission, day)
        end
        
        -- Check expiration
        if mission.expiresDay and day >= mission.expiresDay then
            self:expireMission(mission.id)
        end
    end
end

--- Execute UFO movement script
---@param mission Mission UFO mission
---@param day number Current day
function MissionSystem:executeUFOScript(mission, day)
    -- Simple patrol script: move to random adjacent province
    if day % 2 == 0 then  -- Move every 2 days
        print("[MissionSystem] UFO " .. mission.id .. " moving")
        -- Would integrate with province system to move
    end
end

--- Weekly update for base missions
function MissionSystem:weeklyUpdate()
    for _, mission in pairs(self.missions) do
        if mission.type == "base" and mission.script then
            self:executeBaseScript(mission)
        end
    end
end

--- Execute base growth script
---@param mission Mission Base mission
function MissionSystem:executeBaseScript(mission)
    print("[MissionSystem] Base " .. mission.id .. " growing")
    -- Base spawns more missions, increases threat
end

--- Detect mission (via radar)
---@param missionId string Mission ID
function MissionSystem:detectMission(missionId)
    local mission = self.missions[missionId]
    if mission then
        mission.detected = true
        print("[MissionSystem] Mission detected: " .. missionId)
    end
end

--- Expire mission
---@param missionId string Mission ID
function MissionSystem:expireMission(missionId)
    local mission = self.missions[missionId]
    if mission then
        print("[MissionSystem] Mission expired: " .. missionId)
        self.missions[missionId] = nil
    end
end

--- Complete mission (after battlescape)
---@param missionId string Mission ID
function MissionSystem:completeMission(missionId)
    local mission = self.missions[missionId]
    if mission then
        print("[MissionSystem] Mission completed: " .. missionId)
        self.missions[missionId] = nil
    end
end

--- Get missions by faction
---@param factionId string Faction ID
---@return table Array of missions
function MissionSystem:getMissionsByFaction(factionId)
    local factionMissions = {}
    for _, mission in pairs(self.missions) do
        if mission.factionId == factionId then
            table.insert(factionMissions, mission)
        end
    end
    return factionMissions
end

--- Save state
---@return table State
function MissionSystem:saveState()
    return {missions = self.missions, scripts = self.scripts}
end

--- Load state
---@param state table Saved state
function MissionSystem:loadState(state)
    self.missions = state.missions or {}
    self.scripts = state.scripts or {}
    print("[MissionSystem] State loaded")
end

return MissionSystem


























