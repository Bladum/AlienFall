--- Mission Management System - Mission tracking and coordination
---
--- Manages mission lifecycle including creation, active tracking, objectives,
--- completion, and reward distribution. Coordinates mission assignments with
--- craft deployment and combat operations.
---
--- Mission Types:
--- - site: Alien crash site investigation
--- - ufo_crash: UFO crash with enemy presence
--- - base_defense: Protect XCOM base from attack
--- - terror_site: Alien terror attack on city
--- - supply_raid: Supply cache recovery
--- - alien_base: Assault on alien facility
---
--- Mission States:
--- - pending: Assigned but not started
--- - active: Currently in progress
--- - completed: Successfully completed
--- - failed: Mission failed
--- - aborted: Player aborted mission
---
--- Usage:
---   local MissionManager = require("engine.geoscape.managers.mission_manager")
---   local manager = MissionManager:new()
---   local mission = manager:createMission(missionData)
---   manager:activateMission("mission_1")
---   manager:completeMission("mission_1", rewards)
---
--- @module engine.geoscape.managers.mission_manager
--- @author AlienFall Development Team

local MissionManager = {}
MissionManager.__index = MissionManager

-- Mission type constants
local MISSION_TYPES = {
    site = "crash_site",
    ufo_crash = "ufo_crash",
    base_defense = "base_defense",
    terror_site = "terror_site",
    supply_raid = "supply_raid",
    alien_base = "alien_base"
}

-- Mission state constants
local MISSION_STATES = {
    pending = "pending",
    active = "active",
    completed = "completed",
    failed = "failed",
    aborted = "aborted"
}

--- Initialize Mission Manager
---@return table MissionManager instance
function MissionManager:new()
    local self = setmetatable({}, MissionManager)
    
    self.missions = {}  -- {id = Mission}
    self.nextId = 1
    self.activeMissions = {}  -- Currently active missions
    self.completedMissions = {}  -- Historical completed missions
    self.totalMissionsCompleted = 0
    self.totalMissionsFailed = 0
    self.totalRewardsEarned = 0
    
    -- Mission events
    self.missionEvents = {}  -- {eventName = {callback, ...}}
    
    print("[MissionManager] Initialized")
    
    return self
end

--- Create new mission
---@param missionData table Mission data
---@return table Mission instance
function MissionManager:createMission(missionData)
    local mission = {
        id = "mission_" .. self.nextId,
        name = missionData.name or "Unknown Mission",
        type = missionData.type or "site",
        province = missionData.province,
        state = MISSION_STATES.pending,
        
        -- Details
        description = missionData.description or "",
        difficulty = missionData.difficulty or 1,
        enemyCount = missionData.enemyCount or 3,
        turnLimit = missionData.turnLimit or 100,
        
        -- Objectives
        objectives = missionData.objectives or {},
        primaryObjective = missionData.primaryObjective or "Eliminate all threats",
        objectivesCompleted = 0,
        
        -- Rewards
        rewards = {
            credits = missionData.credits or 50000,
            experience = missionData.experience or 100,
            items = missionData.items or {},
            technology = missionData.technology or nil
        },
        
        -- Combat data
        assignedCrafts = {},
        assignedSquad = {},
        battlefieldSeed = missionData.battlefieldSeed or math.random(1, 999999),
        battleMapSize = missionData.battleMapSize or 5,
        
        -- Tracking
        createdDate = os.time(),
        startedDate = nil,
        completedDate = nil,
        turnsTaken = 0,
        casualtiesOwn = 0,
        casualtiesEnemy = 0,
        status = "Pending",
        success = false
    }
    
    self.nextId = self.nextId + 1
    self.missions[mission.id] = mission
    
    print(string.format("[MissionManager] Created mission: %s (%s) - ID: %s",
        mission.name, mission.type, mission.id))
    
    return mission
end

--- Get mission by ID
---@param missionId string Mission ID
---@return table? Mission or nil
function MissionManager:getMission(missionId)
    return self.missions[missionId]
end

--- Get all missions
---@return table List of all missions
function MissionManager:getAllMissions()
    local all = {}
    for _, mission in pairs(self.missions) do
        table.insert(all, mission)
    end
    return all
end

--- Get pending missions
---@return table List of pending missions
function MissionManager:getPendingMissions()
    local pending = {}
    for _, mission in pairs(self.missions) do
        if mission.state == MISSION_STATES.pending then
            table.insert(pending, mission)
        end
    end
    return pending
end

--- Get active missions
---@return table List of active missions
function MissionManager:getActiveMissions()
    local active = {}
    for _, mission in pairs(self.missions) do
        if mission.state == MISSION_STATES.active then
            table.insert(active, mission)
        end
    end
    return active
end

--- Get missions by type
---@param missionType string Mission type
---@return table List of missions
function MissionManager:getMissionsByType(missionType)
    local result = {}
    for _, mission in pairs(self.missions) do
        if mission.type == missionType then
            table.insert(result, mission)
        end
    end
    return result
end

--- Get missions by province
---@param province string Province ID
---@return table List of missions
function MissionManager:getMissionsByProvince(province)
    local result = {}
    for _, mission in pairs(self.missions) do
        if mission.province == province then
            table.insert(result, mission)
        end
    end
    return result
end

--- Activate mission (start)
---@param missionId string Mission ID
---@param crafts table Assigned craft IDs
---@param squad table Assigned unit IDs
---@return boolean Success
function MissionManager:activateMission(missionId, crafts, squad)
    local mission = self:getMission(missionId)
    if not mission then
        print("[MissionManager] ERROR: Mission not found: " .. missionId)
        return false
    end
    
    if mission.state ~= MISSION_STATES.pending then
        print("[MissionManager] ERROR: Mission not pending: " .. mission.name)
        return false
    end
    
    mission.state = MISSION_STATES.active
    mission.startedDate = os.time()
    mission.assignedCrafts = crafts or {}
    mission.assignedSquad = squad or {}
    mission.status = "Active"
    
    table.insert(self.activeMissions, mission.id)
    
    print(string.format("[MissionManager] Activated mission: %s with %d craft(s) and %d unit(s)",
        mission.name, #mission.assignedCrafts, #mission.assignedSquad))
    
    self:triggerEvent("mission_activated", mission)
    
    return true
end

--- Complete mission successfully
---@param missionId string Mission ID
---@param stats table Battle statistics
---@return boolean Success
function MissionManager:completeMission(missionId, stats)
    local mission = self:getMission(missionId)
    if not mission then
        return false
    end
    
    if mission.state ~= MISSION_STATES.active then
        print("[MissionManager] ERROR: Mission not active")
        return false
    end
    
    mission.state = MISSION_STATES.completed
    mission.completedDate = os.time()
    mission.success = true
    mission.status = "Completed"
    
    -- Apply statistics
    if stats then
        mission.turnsTaken = stats.turnsTaken or 0
        mission.casualtiesOwn = stats.casualtiesOwn or 0
        mission.casualtiesEnemy = stats.casualtiesEnemy or 0
    end
    
    -- Remove from active
    for i, id in ipairs(self.activeMissions) do
        if id == missionId then
            table.remove(self.activeMissions, i)
            break
        end
    end
    
    table.insert(self.completedMissions, mission)
    self.totalMissionsCompleted = self.totalMissionsCompleted + 1
    self.totalRewardsEarned = self.totalRewardsEarned + mission.rewards.credits
    
    print(string.format("[MissionManager] Completed mission: %s | Rewards: $%d + %d XP",
        mission.name, mission.rewards.credits, mission.rewards.experience))
    
    self:triggerEvent("mission_completed", mission)
    
    return true
end

--- Fail mission
---@param missionId string Mission ID
---@param reason string? Failure reason
---@return boolean Success
function MissionManager:failMission(missionId, reason)
    local mission = self:getMission(missionId)
    if not mission then
        return false
    end
    
    if mission.state ~= MISSION_STATES.active then
        return false
    end
    
    mission.state = MISSION_STATES.failed
    mission.completedDate = os.time()
    mission.success = false
    mission.status = "Failed: " .. (reason or "Unknown")
    
    -- Remove from active
    for i, id in ipairs(self.activeMissions) do
        if id == missionId then
            table.remove(self.activeMissions, i)
            break
        end
    end
    
    self.totalMissionsFailed = self.totalMissionsFailed + 1
    
    print(string.format("[MissionManager] Mission failed: %s | Reason: %s",
        mission.name, reason or "Unknown"))
    
    self:triggerEvent("mission_failed", mission)
    
    return true
end

--- Abort mission
---@param missionId string Mission ID
---@return boolean Success
function MissionManager:abortMission(missionId)
    local mission = self:getMission(missionId)
    if not mission then
        return false
    end
    
    if mission.state == MISSION_STATES.completed or mission.state == MISSION_STATES.failed then
        return false
    end
    
    mission.state = MISSION_STATES.aborted
    mission.status = "Aborted"
    
    -- Remove from active if present
    for i, id in ipairs(self.activeMissions) do
        if id == missionId then
            table.remove(self.activeMissions, i)
            break
        end
    end
    
    print("[MissionManager] Aborted mission: " .. mission.name)
    
    self:triggerEvent("mission_aborted", mission)
    
    return true
end

--- Add objective to mission
---@param missionId string Mission ID
---@param objective table Objective data
---@return boolean Success
function MissionManager:addObjective(missionId, objective)
    local mission = self:getMission(missionId)
    if not mission then
        return false
    end
    
    objective.id = "obj_" .. #mission.objectives + 1
    objective.completed = false
    
    table.insert(mission.objectives, objective)
    
    print(string.format("[MissionManager] Added objective to %s: %s",
        mission.name, objective.description))
    
    return true
end

--- Complete objective
---@param missionId string Mission ID
---@param objectiveId string Objective ID
---@return boolean Success
function MissionManager:completeObjective(missionId, objectiveId)
    local mission = self:getMission(missionId)
    if not mission then
        return false
    end
    
    for _, obj in ipairs(mission.objectives) do
        if obj.id == objectiveId then
            obj.completed = true
            mission.objectivesCompleted = mission.objectivesCompleted + 1
            
            print(string.format("[MissionManager] Objective completed: %s",
                obj.description))
            
            return true
        end
    end
    
    return false
end

--- Assign craft to mission
---@param missionId string Mission ID
---@param craftId string Craft ID
---@return boolean Success
function MissionManager:assignCraft(missionId, craftId)
    local mission = self:getMission(missionId)
    if not mission then
        return false
    end
    
    table.insert(mission.assignedCrafts, craftId)
    
    print(string.format("[MissionManager] Assigned craft to %s", mission.name))
    
    return true
end

--- Assign unit to mission
---@param missionId string Mission ID
---@param unitId string Unit ID
---@return boolean Success
function MissionManager:assignUnit(missionId, unitId)
    local mission = self:getMission(missionId)
    if not mission then
        return false
    end
    
    table.insert(mission.assignedSquad, unitId)
    
    print(string.format("[MissionManager] Assigned unit to %s", mission.name))
    
    return true
end

--- Get mission summary
---@param missionId string Mission ID
---@return table Mission summary
function MissionManager:getMissionSummary(missionId)
    local mission = self:getMission(missionId)
    if not mission then
        return {status = "not_found"}
    end
    
    return {
        id = mission.id,
        name = mission.name,
        type = mission.type,
        province = mission.province,
        state = mission.state,
        difficulty = mission.difficulty,
        status = mission.status,
        success = mission.success,
        objectives = #mission.objectives,
        objectivesCompleted = mission.objectivesCompleted,
        crafts = #mission.assignedCrafts,
        squad = #mission.assignedSquad,
        enemies = mission.enemyCount,
        rewards = mission.rewards
    }
end

--- Get campaign statistics
---@return table Statistics
function MissionManager:getStatistics()
    return {
        totalMissions = self:countMissions(),
        activeMissions = #self.activeMissions,
        completedMissions = self.totalMissionsCompleted,
        failedMissions = self.totalMissionsFailed,
        totalRewards = self.totalRewardsEarned,
        completionRate = self:calculateCompletionRate()
    }
end

--- Count missions
---@return number Count
function MissionManager:countMissions()
    local count = 0
    for _ in pairs(self.missions) do
        count = count + 1
    end
    return count
end

--- Calculate completion rate
---@return number Rate (0-1)
function MissionManager:calculateCompletionRate()
    local total = self.totalMissionsCompleted + self.totalMissionsFailed
    if total == 0 then
        return 0
    end
    return self.totalMissionsCompleted / total
end

--- Get mission status report
---@return string Status report
function MissionManager:getStatus()
    local stats = self:getStatistics()
    
    local report = string.format(
        "Mission Status:\n" ..
        "  Total: %d | Active: %d | Completed: %d | Failed: %d\n" ..
        "  Completion Rate: %.1f%%\n" ..
        "  Total Rewards: $%d",
        stats.totalMissions,
        stats.activeMissions,
        stats.completedMissions,
        stats.failedMissions,
        stats.completionRate * 100,
        stats.totalRewards
    )
    
    return report
end

--- Register for mission events
---@param eventName string Event name
---@param callback function Callback function
function MissionManager:onMissionEvent(eventName, callback)
    if not self.missionEvents[eventName] then
        self.missionEvents[eventName] = {}
    end
    table.insert(self.missionEvents[eventName], callback)
end

--- Trigger mission event
---@param eventName string Event name
---@param data any Event data
function MissionManager:triggerEvent(eventName, data)
    if self.missionEvents[eventName] then
        for _, callback in ipairs(self.missionEvents[eventName]) do
            callback(data)
        end
    end
end

--- Serialize for save/load
---@return table Serialized data
function MissionManager:serialize()
    return {
        missions = self.missions,
        nextId = self.nextId,
        activeMissions = self.activeMissions,
        completedMissions = self.completedMissions,
        totalMissionsCompleted = self.totalMissionsCompleted,
        totalMissionsFailed = self.totalMissionsFailed,
        totalRewardsEarned = self.totalRewardsEarned
    }
end

--- Deserialize from save/load
---@param data table Serialized data
function MissionManager:deserialize(data)
    self.missions = data.missions
    self.nextId = data.nextId
    self.activeMissions = data.activeMissions
    self.completedMissions = data.completedMissions
    self.totalMissionsCompleted = data.totalMissionsCompleted
    self.totalMissionsFailed = data.totalMissionsFailed
    self.totalRewardsEarned = data.totalRewardsEarned
    print("[MissionManager] Deserialized from save")
end

return MissionManager





