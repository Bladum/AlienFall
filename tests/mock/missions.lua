-- Mock Mission Data
-- Provides test data for mission and campaign tests

local MockMissions = {}

--- Get a mock mission
-- @param type string Mission type (default: "SITE")
-- @return table Mock mission data
function MockMissions.getMission(type)
    type = type or "SITE"
    
    local missions = {
        SITE = {
            id = math.random(1000, 9999),
            name = "Terror Site",
            type = "SITE",
            difficulty = "MEDIUM",
            biome = "URBAN",
            size = "MEDIUM",
            objectives = {
                {type = "PRIMARY", description = "Eliminate all hostiles", complete = false},
                {type = "SECONDARY", description = "Rescue civilians", complete = false}
            },
            enemies = 8,
            civilians = 12,
            turnLimit = 30,
            rewards = {
                money = 5000,
                intel = 50,
                items = {"Alien Corpse", "Plasma Weapon"}
            }
        },
        UFO = {
            id = math.random(1000, 9999),
            name = "UFO Landing",
            type = "UFO",
            difficulty = "HARD",
            biome = "FOREST",
            size = "LARGE",
            objectives = {
                {type = "PRIMARY", description = "Investigate UFO", complete = false},
                {type = "PRIMARY", description = "Eliminate crew", complete = false}
            },
            enemies = 12,
            turnLimit = 40,
            rewards = {
                money = 8000,
                intel = 100,
                items = {"UFO Navigation", "Alien Alloys", "Power Source"}
            }
        },
        BASE = {
            id = math.random(1000, 9999),
            name = "Alien Base Assault",
            type = "BASE",
            difficulty = "EXTREME",
            biome = "INDUSTRIAL",
            size = "HUGE",
            objectives = {
                {type = "PRIMARY", description = "Destroy alien base", complete = false},
                {type = "PRIMARY", description = "Eliminate commander", complete = false},
                {type = "SECONDARY", description = "Recover artifacts", complete = false}
            },
            enemies = 20,
            turnLimit = 60,
            rewards = {
                money = 15000,
                intel = 200,
                items = {"Alien Commander Corpse", "Base Components", "Research Data"}
            }
        }
    }
    
    return missions[type] or missions.SITE
end

--- Generate multiple random missions
-- @param count number Number of missions
-- @return table Array of missions
function MockMissions.generateMissions(count)
    count = count or 3
    local missions = {}
    local types = {"SITE", "UFO", "BASE"}
    
    for i = 1, count do
        local type = types[math.random(1, #types)]
        table.insert(missions, MockMissions.getMission(type))
    end
    
    return missions
end

--- Get a mock campaign
-- @return table Mock campaign data
function MockMissions.getCampaign()
    return {
        id = 1,
        name = "First Contact",
        faction = "ALIENS",
        phase = 1,
        progress = 0,
        missionsCompleted = 0,
        missionsTotal = 10,
        active = true,
        description = "Initial alien invasion wave"
    }
end

--- Get mission objectives by type
-- @param missionType string Mission type
-- @return table Array of objectives
function MockMissions.getObjectives(missionType)
    missionType = missionType or "SITE"
    
    local objectives = {
        SITE = {
            {id = 1, type = "PRIMARY", description = "Eliminate all hostiles", status = "ACTIVE"},
            {id = 2, type = "SECONDARY", description = "Rescue civilians", status = "ACTIVE"}
        },
        UFO = {
            {id = 1, type = "PRIMARY", description = "Investigate UFO", status = "ACTIVE"},
            {id = 2, type = "PRIMARY", description = "Recover technology", status = "ACTIVE"}
        },
        BASE = {
            {id = 1, type = "PRIMARY", description = "Destroy alien base", status = "ACTIVE"},
            {id = 2, type = "SECONDARY", description = "Capture commander alive", status = "ACTIVE"}
        },
        TIMED = {
            {id = 1, type = "PRIMARY", description = "Defuse bomb", status = "ACTIVE", timeLimit = 15},
            {id = 2, type = "SECONDARY", description = "Evacuate area", status = "PENDING"}
        },
        ESCORT = {
            {id = 1, type = "PRIMARY", description = "Protect VIP", status = "ACTIVE"},
            {id = 2, type = "PRIMARY", description = "Reach extraction", status = "PENDING"}
        }
    }
    
    return objectives[missionType] or objectives.SITE
end

--- Get mission briefing data
-- @param missionType string Mission type
-- @return table Briefing data
function MockMissions.getBriefing(missionType)
    missionType = missionType or "SITE"
    
    return {
        title = "Mission Briefing",
        mission = MockMissions.getMission(missionType),
        objectives = MockMissions.getObjectives(missionType),
        enemyIntel = {
            faction = "ALIENS",
            threatLevel = "HIGH",
            estimatedForces = "8-12 hostiles",
            knownTypes = {"Sectoid", "Muton"}
        },
        mapInfo = {
            biome = "URBAN",
            terrain = "City streets and buildings",
            size = "Medium (5x5 blocks)"
        },
        rewards = {
            money = 5000,
            intel = 50,
            relations = {country = "USA", amount = 10}
        },
        penalties = {
            death = "Loss of soldier, -20 relations",
            failure = "-50 relations, funding cuts"
        }
    }
end

--- Validate mock mission
-- @param mission table Mission to validate
-- @return boolean isValid True if valid
-- @return string? error Error message if invalid
function MockMissions.validateMission(mission)
    if not mission then
        return false, "Mission is nil"
    end
    
    if not mission.id then
        return false, "Mission missing id"
    end
    
    if not mission.type then
        return false, "Mission missing type"
    end
    
    if not mission.name then
        return false, "Mission missing name"
    end
    
    if not mission.difficulty then
        return false, "Mission missing difficulty"
    end
    
    if not mission.biome then
        return false, "Mission missing biome"
    end
    
    if not mission.size then
        return false, "Mission missing size"
    end
    
    if mission.difficulty ~= "EASY" and mission.difficulty ~= "MEDIUM" and mission.difficulty ~= "HARD" then
        return false, "Invalid difficulty level"
    end
    
    if mission.enemies and mission.enemies < 0 then
        return false, "Enemies cannot be negative"
    end
    
    if mission.turnLimit and mission.turnLimit <= 0 then
        return false, "Turn limit must be positive"
    end
    
    return true, nil
end

--- Generate validated missions
-- @param count number Number of missions to generate
-- @param type string Mission type filter
-- @return table Array of validated missions
function MockMissions.generateValidatedMissions(count, type)
    count = count or 5
    
    local missions = {}
    for i = 1, count do
        local mission = MockMissions.getMission(type)
        local isValid, error = MockMissions.validateMission(mission)
        if isValid then
            table.insert(missions, mission)
        else
            print("[MockMissions] Generated invalid mission: " .. error)
        end
    end
    
    return missions
end

--- Get mission objectives templates
-- @return table Array of objective templates
function MockMissions.getObjectiveTemplates()
    return {
        PRIMARY = {
            {type = "PRIMARY", description = "Eliminate all hostiles", complete = false},
            {type = "PRIMARY", description = "Investigate UFO", complete = false},
            {type = "PRIMARY", description = "Rescue civilians", complete = false},
            {type = "PRIMARY", description = "Destroy target", complete = false}
        },
        SECONDARY = {
            {type = "SECONDARY", description = "Minimize civilian casualties", complete = false},
            {type = "SECONDARY", description = "Recover alien technology", complete = false},
            {type = "SECONDARY", description = "Extract survivors", complete = false}
        }
    }
end

--- Generate mission rewards based on difficulty
-- @param difficulty string Mission difficulty
-- @return table Reward structure
function MockMissions.generateRewards(difficulty)
    difficulty = difficulty or "MEDIUM"
    
    local rewardMultipliers = {
        EASY = 0.7,
        MEDIUM = 1.0,
        HARD = 1.5
    }
    
    local multiplier = rewardMultipliers[difficulty] or 1.0
    
    return {
        money = math.floor(5000 * multiplier),
        intel = math.floor(50 * multiplier),
        items = {"Alien Corpse", "Plasma Weapon"},
        research = math.random() > 0.5 and "Alien Materials" or nil
    }
end

return MockMissions

























