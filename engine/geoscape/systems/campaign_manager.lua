--[[
    Campaign Manager
    Manages the core campaign game loop: time progression, mission generation, and mission lifecycle.
    
    Core Responsibilities:
    - Track game time (day, week, month, year)
    - Generate missions weekly (every Monday)
    - Update mission states daily
    - Clean up expired/completed missions
    - Provide mission queries
    
    Turn System:
    - 1 turn = 1 day
    - 1 week = 7 days (Monday = day 1, 8, 15, ...)
    - 1 month = 30 days (simplified)
    - 1 year = 365 days
    
    Mission Generation:
    - Happens every Monday (day % 7 == 1)
    - Number of missions based on faction relations
    - Mission types: site (50%), UFO (35%), base (15%)
    - Missions have cover mechanics for detection
]]

local Mission = require("geoscape.logic.mission")

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
    Called every Monday
    
    @return table List of newly created missions
]]
function CampaignManager:generateWeeklyMissions()
    print(string.format("[Campaign] Generating missions for Week %d...", self.currentWeek))
    
    local newMissions = {}
    
    -- For now, generate 2-4 missions per week
    -- TODO: Base this on faction relations when FactionManager/RelationsManager exist
    local missionCount = math.random(2, 4)
    
    for i = 1, missionCount do
        local mission = self:createRandomMission()
        table.insert(self.activeMissions, mission)
        table.insert(newMissions, mission)
        self.totalMissionsGenerated = self.totalMissionsGenerated + 1
    end
    
    print(string.format("[Campaign] Generated %d new missions (Total: %d active)", 
        #newMissions, #self.activeMissions))
    
    return newMissions
end

--[[
    Create a random mission
    TODO: Replace with faction-based generation when FactionManager exists
    
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
    
    -- Create mission
    local mission = Mission:new({
        type = missionType,
        faction = "aliens",  -- TODO: Use actual faction when FactionManager exists
        province = nil,  -- TODO: Select province when World system exists
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
    TODO: Base this on province when World system exists
    
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

return CampaignManager
