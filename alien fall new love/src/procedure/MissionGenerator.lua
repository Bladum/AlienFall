--- Mission Generator
-- Generates procedural missions with objectives, rewards, and parameters
--
-- @module procedure.MissionGenerator

local class = require 'lib.Middleclass'

--- Mission Generator
-- @type MissionGenerator
MissionGenerator = class('MissionGenerator')

--- Mission types available for generation
MissionGenerator.MISSION_TYPES = {
    'recon', 'assault', 'rescue', 'defend', 'sabotage', 'escort', 'hunt', 'research'
}

--- Difficulty modifiers
MissionGenerator.DIFFICULTY_MODIFIERS = {
    [1] = { enemyCount = 0.5, enemyStrength = 0.7, timeLimit = 1.5 },
    [2] = { enemyCount = 0.7, enemyStrength = 0.8, timeLimit = 1.2 },
    [3] = { enemyCount = 1.0, enemyStrength = 1.0, timeLimit = 1.0 },
    [4] = { enemyCount = 1.3, enemyStrength = 1.2, timeLimit = 0.8 },
    [5] = { enemyCount = 1.6, enemyStrength = 1.4, timeLimit = 0.6 }
}

--- Initialize mission generator
-- @param rng Random number generator
function MissionGenerator:initialize(rng)
    self.rng = rng
end

--- Generate a mission
-- @param missionType Type of mission or 'random'
-- @param difficulty Difficulty level (1-5)
-- @return Mission data table
function MissionGenerator:generate(missionType, difficulty)
    missionType = missionType or 'random'
    difficulty = math.max(1, math.min(5, difficulty or 3))

    if missionType == 'random' then
        missionType = self.MISSION_TYPES[self.rng:random(#self.MISSION_TYPES)]
    end

    local mission = {
        id = self:generateId(),
        type = missionType,
        difficulty = difficulty,
        title = self:generateTitle(missionType),
        description = self:generateDescription(missionType),
        objectives = self:generateObjectives(missionType, difficulty),
        rewards = self:generateRewards(difficulty),
        timeLimit = self:calculateTimeLimit(missionType, difficulty),
        mapType = self:selectMapType(missionType),
        size = self:calculateMapSize(difficulty),
        unitRequirements = self:generateUnitRequirements(missionType, difficulty),
        itemRequirements = self:generateItemRequirements(missionType, difficulty),
        eventTriggers = self:generateEventTriggers(missionType, difficulty)
    }

    return mission
end

--- Generate unique mission ID
-- @return Mission ID string
function MissionGenerator:generateId()
    return string.format("mission_%d_%d", self.rng:random(10000, 99999), os.time())
end

--- Generate mission title
-- @param missionType Type of mission
-- @return Mission title string
function MissionGenerator:generateTitle(missionType)
    local titles = {
        recon = { "Reconnaissance Mission", "Scouting Operation", "Intelligence Gathering" },
        assault = { "Assault Operation", "Direct Action", "Hostile Engagement" },
        rescue = { "Rescue Operation", "Extraction Mission", "Recovery Operation" },
        defend = { "Defense Mission", "Hold Position", "Fortification Duty" },
        sabotage = { "Sabotage Mission", "Disruption Operation", "Destruction Objective" },
        escort = { "Escort Mission", "Convoy Protection", "Safe Passage" },
        hunt = { "Hunt Operation", "Elimination Mission", "Target Acquisition" },
        research = { "Research Expedition", "Scientific Investigation", "Data Collection" }
    }

    local typeTitles = titles[missionType] or { "Special Operation" }
    return typeTitles[self.rng:random(#typeTitles)]
end

--- Generate mission description
-- @param missionType Type of mission
-- @return Mission description string
function MissionGenerator:generateDescription(missionType)
    local descriptions = {
        recon = "Gather intelligence on enemy positions and activities in the designated area.",
        assault = "Eliminate enemy forces and secure the objective location.",
        rescue = "Locate and extract friendly personnel from hostile territory.",
        defend = "Hold defensive positions against enemy attacks for the specified duration.",
        sabotage = "Destroy or disable enemy equipment and infrastructure.",
        escort = "Protect valuable assets during transport through dangerous territory.",
        hunt = "Track down and eliminate high-value enemy targets.",
        research = "Collect scientific data and samples from the designated research site."
    }

    return descriptions[missionType] or "Complete the assigned mission objectives."
end

--- Generate mission objectives
-- @param missionType Type of mission
-- @param difficulty Difficulty level
-- @return Array of objective tables
function MissionGenerator:generateObjectives(missionType, difficulty)
    local objectives = {}

    -- Primary objective based on mission type
    if missionType == 'recon' then
        table.insert(objectives, {
            type = 'scan',
            description = 'Scan enemy positions and gather intelligence',
            required = true,
            progress = 0,
            target = 80 + difficulty * 5
        })
    elseif missionType == 'assault' then
        table.insert(objectives, {
            type = 'eliminate',
            description = 'Eliminate all enemy forces in the area',
            required = true,
            progress = 0,
            target = 100
        })
    elseif missionType == 'rescue' then
        table.insert(objectives, {
            type = 'rescue',
            description = 'Locate and rescue friendly personnel',
            required = true,
            progress = 0,
            target = 1
        })
    elseif missionType == 'defend' then
        table.insert(objectives, {
            type = 'survive',
            description = 'Survive enemy attacks for ' .. (10 + difficulty * 2) .. ' turns',
            required = true,
            progress = 0,
            target = 10 + difficulty * 2
        })
    elseif missionType == 'sabotage' then
        table.insert(objectives, {
            type = 'destroy',
            description = 'Destroy enemy equipment and structures',
            required = true,
            progress = 0,
            target = 2 + difficulty
        })
    elseif missionType == 'escort' then
        table.insert(objectives, {
            type = 'protect',
            description = 'Escort VIP to extraction point',
            required = true,
            progress = 0,
            target = 1
        })
    elseif missionType == 'hunt' then
        table.insert(objectives, {
            type = 'eliminate',
            description = 'Eliminate high-value target',
            required = true,
            progress = 0,
            target = 1
        })
    elseif missionType == 'research' then
        table.insert(objectives, {
            type = 'collect',
            description = 'Collect research samples',
            required = true,
            progress = 0,
            target = 3 + difficulty
        })
    end

    -- Secondary objectives
    if self.rng:random() < 0.6 then
        local secondaryTypes = { 'bonus_elimination', 'time_bonus', 'stealth_bonus', 'collection' }
        local secondaryType = secondaryTypes[self.rng:random(#secondaryTypes)]

        if secondaryType == 'bonus_elimination' then
            table.insert(objectives, {
                type = 'bonus',
                description = 'Eliminate additional enemy forces',
                required = false,
                progress = 0,
                target = 5 + difficulty * 2,
                reward = 'experience'
            })
        elseif secondaryType == 'time_bonus' then
            table.insert(objectives, {
                type = 'bonus',
                description = 'Complete mission quickly',
                required = false,
                progress = 0,
                target = 1,
                reward = 'resources'
            })
        elseif secondaryType == 'stealth_bonus' then
            table.insert(objectives, {
                type = 'bonus',
                description = 'Complete mission without being detected',
                required = false,
                progress = 0,
                target = 1,
                reward = 'reputation'
            })
        elseif secondaryType == 'collection' then
            table.insert(objectives, {
                type = 'bonus',
                description = 'Collect enemy technology',
                required = false,
                progress = 0,
                target = 2 + difficulty,
                reward = 'research'
            })
        end
    end

    return objectives
end

--- Generate mission rewards
-- @param difficulty Difficulty level
-- @return Rewards table
function MissionGenerator:generateRewards(difficulty)
    local baseReward = difficulty * 100
    local experienceReward = difficulty * 50

    return {
        credits = baseReward + self.rng:random(-20, 20),
        experience = experienceReward + self.rng:random(-10, 10),
        research = self.rng:random(0, difficulty * 10),
        reputation = difficulty + self.rng:random(-1, 1)
    }
end

--- Calculate time limit for mission
-- @param missionType Type of mission
-- @param difficulty Difficulty level
-- @return Time limit in turns
function MissionGenerator:calculateTimeLimit(missionType, difficulty)
    local baseLimits = {
        recon = 15,
        assault = 20,
        rescue = 18,
        defend = 25,
        sabotage = 16,
        escort = 22,
        hunt = 14,
        research = 12
    }

    local baseLimit = baseLimits[missionType] or 18
    local modifier = self.DIFFICULTY_MODIFIERS[difficulty].timeLimit

    return math.floor(baseLimit * modifier)
end

--- Select appropriate map type for mission
-- @param missionType Type of mission
-- @return Map type string
function MissionGenerator:selectMapType(missionType)
    local mapTypes = {
        recon = { 'urban', 'rural', 'forest' },
        assault = { 'urban', 'industrial', 'military' },
        rescue = { 'urban', 'underground', 'research' },
        defend = { 'outpost', 'base', 'fortress' },
        sabotage = { 'industrial', 'research', 'military' },
        escort = { 'urban', 'rural', 'highway' },
        hunt = { 'forest', 'mountain', 'desert' },
        research = { 'research', 'underground', 'alien' }
    }

    local availableTypes = mapTypes[missionType] or { 'urban', 'rural', 'forest' }
    return availableTypes[self.rng:random(#availableTypes)]
end

--- Calculate map size based on difficulty
-- @param difficulty Difficulty level
-- @return Map size table {width, height}
function MissionGenerator:calculateMapSize(difficulty)
    local baseSize = 20
    local sizeIncrease = (difficulty - 3) * 5

    return {
        width = baseSize + sizeIncrease + self.rng:random(-2, 2),
        height = baseSize + sizeIncrease + self.rng:random(-2, 2)
    }
end

--- Generate unit requirements for mission
-- @param missionType Type of mission
-- @param difficulty Difficulty level
-- @return Unit requirements table
function MissionGenerator:generateUnitRequirements(missionType, difficulty)
    local modifier = self.DIFFICULTY_MODIFIERS[difficulty]

    return {
        playerUnits = 4, -- Always 4 squad members
        enemyCount = math.floor((8 + difficulty * 3) * modifier.enemyCount),
        enemyTypes = self:getEnemyTypesForMission(missionType),
        bossChance = difficulty >= 4 and self.rng:random() < 0.3
    }
end

--- Get enemy types appropriate for mission type
-- @param missionType Type of mission
-- @return Array of enemy type strings
function MissionGenerator:getEnemyTypesForMission(missionType)
    local enemyTypes = {
        recon = { 'scout', 'drone', 'sectoid' },
        assault = { 'sectoid', 'muton', 'cyberdisc' },
        rescue = { 'sectoid', 'floater', 'chryssalid' },
        defend = { 'sectoid', 'muton', 'berserker' },
        sabotage = { 'sectoid', 'cyberdisc', 'mechtoid' },
        escort = { 'sectoid', 'floater', 'drone' },
        hunt = { 'sectoid', 'muton', 'elite' },
        research = { 'sectoid', 'cyberdisc', 'ethereal' }
    }

    return enemyTypes[missionType] or { 'sectoid', 'muton' }
end

--- Generate item requirements for mission
-- @param missionType Type of mission
-- @param difficulty Difficulty level
-- @return Item requirements table
function MissionGenerator:generateItemRequirements(missionType, difficulty)
    return {
        weapons = 2 + math.floor(difficulty / 2),
        armor = 1 + math.floor(difficulty / 3),
        grenades = difficulty,
        medkits = 1 + math.floor(difficulty / 2)
    }
end

--- Generate event triggers for mission
-- @param missionType Type of mission
-- @param difficulty Difficulty level
-- @return Array of event trigger strings
function MissionGenerator:generateEventTriggers(missionType, difficulty)
    local triggers = { 'enemy_reinforcements', 'environmental_hazard' }

    if difficulty >= 3 then
        table.insert(triggers, 'enemy_ambush')
    end

    if difficulty >= 4 then
        table.insert(triggers, 'boss_encounter')
    end

    if missionType == 'research' then
        table.insert(triggers, 'scientific_discovery')
    end

    return triggers
end

return MissionGenerator