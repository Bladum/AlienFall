---Campaign Manager - Core Campaign Game Loop
---
---Manages the strategic game loop: time progression, mission generation, and
---mission lifecycle. Coordinates calendar, campaigns, and missions for dynamic
---strategic gameplay. Heart of the geoscape layer.
---
---Core Responsibilities:
---  - Track game time (day, week, month, year, quarter)
---  - Generate missions weekly (every Monday)
---  - Update mission states daily (cover, movement, expiration)
---  - Clean up expired/completed missions
---  - Provide mission queries and filtering
---  - Coordinate with detection system
---
---Turn System:
---  - 1 turn = 1 day
---  - Missions generated on Mondays (day 1, 8, 15, 22, 29)
---  - 30 days per month (simplified)
---  - 360 days per year (12 months × 30 days)
---
---Mission Lifecycle:
---  1. Campaign spawns mission (weekly/monthly)
---  2. Mission starts hidden with cover value
---  3. Radar reduces cover daily
---  4. Mission detected when cover reaches 0
---  5. Player can engage detected missions
---  6. Mission expires or completes
---
---Key Exports:
---  - CampaignManager:init(): Initializes campaign manager
---  - CampaignManager:advanceDay(): Progresses time by one day
---  - CampaignManager:generateMissions(): Spawns weekly missions
---  - CampaignManager:updateMissions(): Updates all active missions
---  - CampaignManager:getMissions(provinceId): Queries missions
---  - CampaignManager:getCurrentDay(): Returns game time
---
---Dependencies:
---  - lore.calendar: Time tracking system
---  - lore.campaign.campaign_system: Campaign definitions
---  - lore.missions.mission_system: Mission management
---  - lore.factions: Faction data
---  - geoscape.systems.detection_manager: Radar detection
---
---@module lore.campaign.campaign_manager
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local CampaignManager = require("lore.campaign.campaign_manager")
---  CampaignManager:init()
---  CampaignManager:advanceDay()  -- Progress one day
---  local missions = CampaignManager:getMissions("province_23")
---
---@see lore.calendar For time system
---@see lore.campaign.campaign_system For campaigns
---@see geoscape.world.world_state For world state

local Mission = require("lore.missions.mission")

local CampaignManager = {}

--[[
    Initialize campaign manager
    Sets up starting conditions and time tracking
]]
function CampaignManager:init()
    print("[Campaign] Initializing Campaign Manager...")

    -- Time tracking
    self.currentDay = 1
    self.currentWeek = 1
    self.currentMonth = 1
    self.currentYear = 1

    -- Mission tracking
    self.activeMissions = {}  -- Missions currently active (hidden or detected)
    self.completedMissions = {}  -- Successfully completed missions
    self.expiredMissions = {}  -- Expired missions (not intercepted)

    -- Statistics
    self.totalMissionsGenerated = 0
    self.totalMissionsCompleted = 0
    self.totalMissionsExpired = 0

    -- Configuration
    self.missionGenerationEnabled = true
    self.debugMode = false

    print("[Campaign] Campaign started on Day 1, Week 1, Month 1, Year 1")
end

--[[
    Advance game time by one day
    Updates missions, generates new missions on Monday, cleans up old missions

    @return table Events that occurred (mission spawns, expirations, etc.)
]]
function CampaignManager:advanceDay()
    self.currentDay = self.currentDay + 1

    -- Update week/month/year counters
    self.currentWeek = math.floor((self.currentDay - 1) / 7) + 1
    self.currentMonth = math.floor((self.currentDay - 1) / 30) + 1
    self.currentYear = math.floor((self.currentDay - 1) / 365) + 1

    print(string.format("[Campaign] === Day %d (Week %d, Month %d, Year %d) ===",
        self.currentDay, self.currentWeek, self.currentMonth, self.currentYear))

    local events = {}

    -- Update all active missions
    local missionsExpired = 0
    for _, mission in ipairs(self.activeMissions) do
        mission:update(1)

        if mission.state == "expired" then
            missionsExpired = missionsExpired + 1
            table.insert(events, {type = "mission_expired", mission = mission})
        end
    end

    if missionsExpired > 0 then
        print(string.format("[Campaign] %d mission(s) expired", missionsExpired))
    end

    -- Generate weekly missions on Monday
    if self:isMonday() and self.missionGenerationEnabled then
        local newMissions = self:generateWeeklyMissions()
        for _, mission in ipairs(newMissions) do
            table.insert(events, {type = "mission_spawned", mission = mission})
        end
    end

    -- Clean up completed/expired missions
    self:cleanupMissions()

    -- Print daily status
    if self.debugMode then
        print(string.format("[Campaign] Active missions: %d, Completed: %d, Expired: %d",
            #self.activeMissions, #self.completedMissions, #self.expiredMissions))
    end

    return events
end

--[[
    Check if current day is Monday (mission generation day)

    @return boolean True if today is Monday
]]
function CampaignManager:isMonday()
    -- Day 1 is Monday, then every 7 days
    return (self.currentDay - 1) % 7 == 0
end

--[[
    Generate weekly missions for all active factions
    Called every Monday. Mission count and faction selection based on relations.

    @return table List of newly created missions
]]
function CampaignManager:generateWeeklyMissions()
    print(string.format("[Campaign] Generating missions for Week %d...", self.currentWeek))

    local newMissions = {}

    -- Get mission count based on faction relations
    -- Worse relations = more missions
    local missionCount = self:calculateMissionCountByRelations()

    -- Generate missions for each active faction based on their relations
    local factions = self:getActiveFactions()

    if #factions == 0 then
        -- Fallback: generate generic missions if no factions loaded
        missionCount = math.random(2, 4)
        for i = 1, missionCount do
            local mission = self:createRandomMission()
            table.insert(self.activeMissions, mission)
            table.insert(newMissions, mission)
            self.totalMissionsGenerated = self.totalMissionsGenerated + 1
        end
    else
        -- Generate faction-specific missions
        local missionsPerFaction = math.max(1, math.floor(missionCount / #factions))

        for _, factionId in ipairs(factions) do
            for i = 1, missionsPerFaction do
                local mission = self:createFactionMission(factionId)
                table.insert(self.activeMissions, mission)
                table.insert(newMissions, mission)
                self.totalMissionsGenerated = self.totalMissionsGenerated + 1
            end
        end
    end

    print(string.format("[Campaign] Generated %d new missions for %d faction(s) (Total: %d active)",
        #newMissions, #factions, #self.activeMissions))

    return newMissions
end

--[[
    Create a faction-specific mission based on faction relations
    Mission difficulty and type affected by player relations with faction

    @param factionId string Faction to create mission for
    @return Mission New mission instance
]]
function CampaignManager:createFactionMission(factionId)
    local faction = self:getFactionData(factionId)
    if not faction then
        return self:createRandomMission()
    end

    -- Get faction relations to determine mission intensity
    local relations = self:getFactionRelations(factionId)
    local relationIntensity = self:getRelationIntensity(relations)

    -- Mission type probabilities vary by faction
    local roll = math.random()
    local missionType

    -- Some factions prefer certain mission types
    if faction.preferredMissionType then
        if roll < 0.4 then
            missionType = faction.preferredMissionType
        elseif roll < 0.7 then
            missionType = "site"
        else
            missionType = "ufo"
        end
    else
        if roll < 0.5 then
            missionType = "site"
        elseif roll < 0.85 then
            missionType = "ufo"
        else
            missionType = "base"
        end
    end

    -- Difficulty increases based on:
    -- 1. Campaign week (escalation over time)
    -- 2. Faction relation intensity (worse = harder)
    -- 3. Faction power level
    local difficultyBase = 1
    local difficultyIncrease = math.floor(self.currentWeek / 4)  -- +1 every 4 weeks
    local relationDifficulty = math.floor(relationIntensity * 3)  -- Up to +3 from relations
    local difficulty = difficultyBase + difficultyIncrease + relationDifficulty + math.random(0, 1)

    -- Calculate power based on difficulty and faction strength
    local factionPower = faction.basePower or 100
    local power = (factionPower * difficulty) + math.random(-20, 20)

    -- Mission-specific properties
    local altitude, coverRegen, duration

    if missionType == "ufo" then
        altitude = math.random() < 0.5 and "air" or "land"
        coverRegen = altitude == "air" and 3 or 5
        duration = 7
    elseif missionType == "base" then
        altitude = math.random() < 0.5 and "underground" or "underwater"
        coverRegen = 10
        duration = 30
    else  -- site
        altitude = "land"
        coverRegen = 5
        duration = 14
    end

    -- Create faction-specific mission
    local mission = Mission:new({
        type = missionType,
        faction = factionId,
        factionName = faction.name or "Unknown",
        province = self:selectProvinceByRelations(factionId),
        biome = self:selectRandomBiome(),
        difficulty = difficulty,
        power = power,
        spawnDay = self.currentDay,

        -- Cover mechanics
        coverValue = 100,
        coverMax = 100,
        coverRegen = coverRegen,

        -- Duration
        duration = duration,

        -- Type-specific properties
        altitude = altitude,
        health = power * 10,
        maxHealth = power * 10,
    })

    if self.debugMode then
        print(string.format("[Campaign] Faction %s: difficulty %d, power %.0f, relations %.1f",
            factionId, difficulty, power, relations))
    end

    return mission
end

--[[
    Create a random mission (fallback when faction data unavailable)

    @return Mission New mission instance
]]
function CampaignManager:createRandomMission()
    -- Mission type probabilities
    local roll = math.random()
    local missionType

    if roll < 0.5 then
        missionType = "site"  -- 50%: Alien site
    elseif roll < 0.85 then
        missionType = "ufo"   -- 35%: UFO
    else
        missionType = "base"  -- 15%: Alien base
    end

    -- Random difficulty (increases over time)
    local difficultyBase = 1
    local difficultyIncrease = math.floor(self.currentWeek / 4)  -- +1 every 4 weeks
    local difficulty = difficultyBase + difficultyIncrease + math.random(0, 2)

    -- Calculate power based on difficulty
    local power = 100 * difficulty + math.random(-20, 20)

    -- Mission-specific properties
    local altitude, coverRegen, duration

    if missionType == "ufo" then
        altitude = math.random() < 0.5 and "air" or "land"
        coverRegen = altitude == "air" and 3 or 5  -- Flying UFOs easier to detect
        duration = 7  -- 1 week
    elseif missionType == "base" then
        altitude = math.random() < 0.5 and "underground" or "underwater"
        coverRegen = 10  -- Bases are well-hidden
        duration = 30  -- 1 month
    else  -- site
        altitude = "land"
        coverRegen = 5
        duration = 14  -- 2 weeks
    end

    -- Create mission (hardcoded faction as fallback)
    local mission = Mission:new({
        type = missionType,
        faction = "aliens",
        factionName = "Aliens",
        province = nil,
        biome = self:selectRandomBiome(),
        difficulty = difficulty,
        power = power,
        spawnDay = self.currentDay,

        -- Cover mechanics
        coverValue = 100,
        coverMax = 100,
        coverRegen = coverRegen,

        -- Duration
        duration = duration,

        -- Type-specific properties
        altitude = altitude,
        health = power * 10,
        maxHealth = power * 10,
    })

    return mission
end

--[[
    Select random biome for mission
    TASK-12.1: Faction-based mission generation - province selection integration

    @return string Biome name
]]
function CampaignManager:selectRandomBiome()
    local biomes = {
        "forest", "urban", "plains", "desert", "mountains",
        "arctic", "coastal", "industrial", "rural", "water"
    }
    return biomes[math.random(1, #biomes)]
end

--[[
    Clean up missions that are completed or expired
    Moves them from activeMissions to appropriate lists
]]
function CampaignManager:cleanupMissions()
    local activeMissions = {}

    for _, mission in ipairs(self.activeMissions) do
        if mission.state == "expired" then
            table.insert(self.expiredMissions, mission)
            self.totalMissionsExpired = self.totalMissionsExpired + 1
        elseif mission.state == "completed" then
            table.insert(self.completedMissions, mission)
            self.totalMissionsCompleted = self.totalMissionsCompleted + 1
        else
            -- Still active (hidden, detected, or active)
            table.insert(activeMissions, mission)
        end
    end

    self.activeMissions = activeMissions
end

--[[
    Get mission by ID

    @param missionId string Mission ID to find
    @return Mission|nil Mission instance or nil if not found
]]
function CampaignManager:getMission(missionId)
    for _, mission in ipairs(self.activeMissions) do
        if mission.id == missionId then
            return mission
        end
    end
    return nil
end

--[[
    Get all active missions

    @return table List of all active missions (hidden + detected + active)
]]
function CampaignManager:getActiveMissions()
    return self.activeMissions
end

--[[
    Get only detected missions (visible on Geoscape)

    @return table List of detected missions
]]
function CampaignManager:getDetectedMissions()
    local detected = {}
    for _, mission in ipairs(self.activeMissions) do
        if mission.detected then
            table.insert(detected, mission)
        end
    end
    return detected
end

--[[
    Get hidden missions (not yet detected)

    @return table List of hidden missions
]]
function CampaignManager:getHiddenMissions()
    local hidden = {}
    for _, mission in ipairs(self.activeMissions) do
        if not mission.detected then
            table.insert(hidden, mission)
        end
    end
    return hidden
end

--[[
    Get campaign statistics

    @return table Statistics with keys: day, week, month, year, activeMissions, etc.
]]
function CampaignManager:getStatistics()
    return {
        currentDay = self.currentDay,
        currentWeek = self.currentWeek,
        currentMonth = self.currentMonth,
        currentYear = self.currentYear,
        activeMissions = #self.activeMissions,
        completedMissions = #self.completedMissions,
        expiredMissions = #self.expiredMissions,
        totalGenerated = self.totalMissionsGenerated,
        totalCompleted = self.totalMissionsCompleted,
        totalExpired = self.totalMissionsExpired,
    }
end

--[[
    Print campaign status to console
]]
function CampaignManager:printStatus()
    local stats = self:getStatistics()

    print(string.format("[Campaign] === Campaign Status ==="))
    print(string.format("[Campaign] Time: Day %d (Week %d, Month %d, Year %d)",
        stats.currentDay, stats.currentWeek, stats.currentMonth, stats.currentYear))
    print(string.format("[Campaign] Missions: %d active, %d completed, %d expired",
        stats.activeMissions, stats.completedMissions, stats.expiredMissions))
    print(string.format("[Campaign] Total generated: %d", stats.totalGenerated))

    -- List detected missions
    local detected = self:getDetectedMissions()
    if #detected > 0 then
        print(string.format("[Campaign] Detected missions:"))
        for _, mission in ipairs(detected) do
            print(string.format("  - %s (%s, Difficulty %d, Days active: %d)",
                mission.name, mission.type, mission.difficulty, mission.daysActive))
        end
    end
end

--[[
    Serialize campaign state for saving

    @return table Serialized campaign data
]]
function CampaignManager:serialize()
    local data = {
        currentDay = self.currentDay,
        currentWeek = self.currentWeek,
        currentMonth = self.currentMonth,
        currentYear = self.currentYear,
        totalMissionsGenerated = self.totalMissionsGenerated,
        totalMissionsCompleted = self.totalMissionsCompleted,
        totalMissionsExpired = self.totalMissionsExpired,
        activeMissions = {},
        completedMissions = {},
        expiredMissions = {},
    }

    -- Serialize missions
    for _, mission in ipairs(self.activeMissions) do
        table.insert(data.activeMissions, mission:serialize())
    end
    for _, mission in ipairs(self.completedMissions) do
        table.insert(data.completedMissions, mission:serialize())
    end
    for _, mission in ipairs(self.expiredMissions) do
        table.insert(data.expiredMissions, mission:serialize())
    end

    return data
end

--[[
    Deserialize campaign state from save data

    @param data table Serialized campaign data
]]
function CampaignManager:deserialize(data)
    self.currentDay = data.currentDay
    self.currentWeek = data.currentWeek
    self.currentMonth = data.currentMonth
    self.currentYear = data.currentYear
    self.totalMissionsGenerated = data.totalMissionsGenerated
    self.totalMissionsCompleted = data.totalMissionsCompleted
    self.totalMissionsExpired = data.totalMissionsExpired

    -- Deserialize missions
    self.activeMissions = {}
    for _, missionData in ipairs(data.activeMissions) do
        table.insert(self.activeMissions, Mission.deserialize(missionData))
    end

    self.completedMissions = {}
    for _, missionData in ipairs(data.completedMissions) do
        table.insert(self.completedMissions, Mission.deserialize(missionData))
    end

    self.expiredMissions = {}
    for _, missionData in ipairs(data.expiredMissions) do
        table.insert(self.expiredMissions, Mission.deserialize(missionData))
    end

    print(string.format("[Campaign] Loaded campaign: Day %d, %d active missions",
        self.currentDay, #self.activeMissions))
end

--[[
    Calculate mission count based on faction relations
    Worse relations = more missions (offensive)
    Better relations = fewer missions (defensive)

    @return number Mission count for this week
]]
function CampaignManager:calculateMissionCountByRelations()
    local avgRelations = self:getAverageFactionRelations()

    -- Base: 2-3 missions per week
    -- If relations very bad: 4-6 missions/week
    -- If relations very good: 1-2 missions/week
    local base = 2 + math.random(0, 1)

    if avgRelations < -50 then
        return 4 + math.random(0, 2)  -- Aggressive
    elseif avgRelations < -25 then
        return 3 + math.random(0, 1)  -- Moderately aggressive
    elseif avgRelations > 50 then
        return 1 + math.random(0, 1)  -- Defensive
    elseif avgRelations > 25 then
        return 2 + math.random(0, 1)  -- Moderate
    else
        return base  -- Neutral
    end
end

--[[
    Get average faction relations across all active factions
    Used to determine overall campaign intensity

    @return number Average relation value (-100 to 100)
]]
function CampaignManager:getAverageFactionRelations()
    local factions = self:getActiveFactions()

    if #factions == 0 then
        return 0  -- Neutral if no factions
    end

    local total = 0
    for _, factionId in ipairs(factions) do
        total = total + (self:getFactionRelations(factionId) or 0)
    end

    return total / #factions
end

--[[
    Get list of active factions
    Loads from FactionManager if available, otherwise uses hardcoded list

    @return table List of faction IDs
]]
function CampaignManager:getActiveFactions()
    -- Try to get from FactionManager
    local FactionManager = require("geoscape.faction_system")
    if FactionManager and FactionManager.activeFactions then
        return FactionManager.activeFactions or {"aliens"}
    end

    -- Fallback: hardcoded factions
    return {"aliens"}
end

--[[
    Get faction data (name, properties, etc)

    @param factionId string Faction identifier
    @return table Faction data or nil
]]
function CampaignManager:getFactionData(factionId)
    local FactionManager = require("geoscape.faction_system")
    if FactionManager and FactionManager.factions then
        return FactionManager.factions[factionId]
    end

    -- Fallback faction data
    if factionId == "aliens" then
        return {
            id = "aliens",
            name = "Alien Forces",
            basePower = 100,
            preferredMissionType = "ufo",
        }
    end

    return nil
end

--[[
    Get relations value for a faction

    @param factionId string Faction identifier
    @return number Relation value (-100 to 100) or 0 if unavailable
]]
function CampaignManager:getFactionRelations(factionId)
    -- Try to get from RelationsManager
    local RelationsManager = require("geoscape.systems.relations_manager")
    if RelationsManager and RelationsManager.factionRelations then
        local relation = RelationsManager.factionRelations[factionId]
        if relation then
            return relation.value or 0
        end
    end

    -- Fallback: neutral relations
    return 0
end

--[[
    Convert relation value to intensity (0-1)
    Used to scale mission difficulty

    @param relations number Relation value (-100 to 100)
    @return number Intensity (0-1), where 1 = maximum hostility
]]
function CampaignManager:getRelationIntensity(relations)
    if relations >= 0 then
        return 0  -- Positive relations = no intensity bonus
    else
        -- Negative relations scale from 0 at 0 to 1 at -100
        return math.min(1.0, math.abs(relations) / 100.0)
    end
end

--[[
    Select province based on faction relations and activity
    Returns province where faction is most active or historically active
    TASK-12.2: Province selection in missions from world system

    @param factionId string Faction identifier
    @return table Province coordinates {x, y} or nil
]]
function CampaignManager:selectProvinceByRelations(factionId)
    -- TASK-12.2: Province graph pathfinding for UFO movement
    -- When world system available, query for province with faction activity

    -- Attempt to use world system if available
    if self.worldSystem then
        -- Get provinces controlled or active by faction
        local factionProvinces = self.worldSystem:getProvincesByFaction(factionId)

        if factionProvinces and #factionProvinces > 0 then
            -- Select random province from faction's active area
            local selectedProvince = factionProvinces[math.random(1, #factionProvinces)]
            print(string.format("[Campaign] Selected province %s for faction %s mission",
                selectedProvince.id or "unknown", factionId))
            return selectedProvince
        end
    end

    -- Fallback: Random province selection when world system not yet integrated
    -- Generate random valid coordinates (0-59 for 60x60 world)
    local provinceX = math.random(0, 59)
    local provinceY = math.random(0, 59)

    return {
        x = provinceX,
        y = provinceY,
        id = "province_" .. provinceX .. "_" .. provinceY,
        factionActive = factionId
    }
end

return CampaignManager

