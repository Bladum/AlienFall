-- Mission Generator System
-- Procedurally generates missions with variations from templates

local ContentDatabase = require("engine.content.content_database")

local MissionGenerator = {}

---Generate a mission from a template with difficulty modifications
function MissionGenerator.generateMission(templateId, baseDifficulty)
    baseDifficulty = baseDifficulty or 3

    local template = ContentDatabase.getMission(templateId)
    if not template then
        error("Mission template not found: " .. templateId)
    end

    -- Create instance from template
    local mission = {
        id = templateId .. "_" .. math.random(10000, 99999),
        template_id = templateId,
        name = template.name,
        description = template.description,
        base_difficulty = baseDifficulty,
        objectives = {},
        enemies = {},
        rewards = {},
        map_seed = math.random(1, 1000000),
        status = "pending"
    }

    -- Apply difficulty scaling (-2 to +2)
    local difficultyMod = math.random(-2, 2)
    mission.difficulty = baseDifficulty + difficultyMod
    mission.difficulty = math.max(1, math.min(10, mission.difficulty))

    -- Generate objectives
    if template.objectives then
        for _, objTemplate in ipairs(template.objectives) do
            local objective = {
                type = objTemplate.type,
                description = objTemplate.description,
                target_count = objTemplate.target_count or 1,
                completed = false
            }
            table.insert(mission.objectives, objective)
        end
    end

    -- Generate enemy composition
    mission.enemies = MissionGenerator.generateEnemyComposition(
        template.enemy_count_range or {6, 12},
        mission.difficulty,
        template.faction_id
    )

    -- Scale rewards based on difficulty
    if template.rewards then
        mission.rewards.science = template.rewards.science or 100
        mission.rewards.money = template.rewards.money or 200
        mission.rewards.artifacts = template.rewards.artifacts or 1

        -- Scale by difficulty
        local rewardMultiplier = 0.8 + (mission.difficulty * 0.2)
        mission.rewards.science = math.floor(mission.rewards.science * rewardMultiplier)
        mission.rewards.money = math.floor(mission.rewards.money * rewardMultiplier)
    end

    return mission
end

---Generate random enemy composition
function MissionGenerator.generateEnemyComposition(countRange, difficulty, factionId)
    local minCount = countRange[1] or 6
    local maxCount = countRange[2] or 12

    -- Scale count by difficulty
    local baseCount = math.floor((minCount + maxCount) / 2)
    local scaledCount = baseCount + (difficulty - 3) * 2
    scaledCount = math.max(minCount, math.min(maxCount + 4, scaledCount))

    -- Vary slightly
    local finalCount = scaledCount + math.random(-1, 1)

    local enemies = {}

    -- Create enemy units
    for i = 1, finalCount do
        local enemy = {
            id = "enemy_" .. i,
            rank = "soldier",
            equipment = {},
            hp = 100,
            alive = true
        }

        -- Occasionally add higher rank units at higher difficulty
        if difficulty > 5 and math.random() < 0.2 then
            enemy.rank = "sergeant"
            enemy.hp = 130
        end

        if difficulty > 7 and math.random() < 0.1 then
            enemy.rank = "commander"
            enemy.hp = 160
        end

        table.insert(enemies, enemy)
    end

    return enemies
end

---Generate a random mission
function MissionGenerator.generateRandomMission(difficulty)
    difficulty = difficulty or 3

    -- Get all mission templates
    local allMissions = ContentDatabase.getAllMissions()
    if not allMissions or table.countKeys(allMissions) == 0 then
        error("No mission templates available")
    end

    -- Pick random template
    local templates = {}
    for id, _ in pairs(allMissions) do
        table.insert(templates, id)
    end

    local randomId = templates[math.random(1, #templates)]

    return MissionGenerator.generateMission(randomId, difficulty)
end

---Generate mission variant (same template, different variation)
function MissionGenerator.generateMissionVariant(mission)
    if not mission.template_id then
        error("Mission must have template_id")
    end

    -- Generate new instance with slightly different difficulty
    local difficulty = mission.base_difficulty + math.random(-1, 1)

    return MissionGenerator.generateMission(mission.template_id, difficulty)
end

---Get mission difficulty description
function MissionGenerator.getDifficultyDescription(difficulty)
    if difficulty <= 2 then
        return "Easy"
    elseif difficulty <= 4 then
        return "Normal"
    elseif difficulty <= 6 then
        return "Hard"
    elseif difficulty <= 8 then
        return "Brutal"
    else
        return "Impossible"
    end
end

---Calculate mission success probability
function MissionGenerator.getSuccessProbability(playerRating, missionDifficulty)
    -- Simple probability calculation
    -- playerRating: 1-10 (player skill/equipment level)
    -- missionDifficulty: 1-10 (mission difficulty)

    local diff = playerRating - missionDifficulty

    -- Formula: 50% base, +/- 5% per difficulty point
    local probability = 0.5 + (diff * 0.05)

    return math.max(0.05, math.min(0.95, probability))
end

---Generate mission reward estimate
function MissionGenerator.getRewardEstimate(mission)
    if not mission or not mission.rewards then
        return {science = 0, money = 0, artifacts = 0}
    end

    return {
        science = mission.rewards.science or 0,
        money = mission.rewards.money or 0,
        artifacts = mission.rewards.artifacts or 0
    }
end

---Check if mission is completable
function MissionGenerator.isMissionValid(mission)
    if not mission.name or not mission.objectives or not mission.enemies then
        return false
    end

    if #mission.objectives == 0 or #mission.enemies == 0 then
        return false
    end

    return true
end

---Print mission details
function MissionGenerator.printMission(mission)
    print("\n" .. string.rep("=", 60))
    print("MISSION: " .. mission.name)
    print(string.rep("=", 60))
    print("ID: " .. mission.id)
    print("Template: " .. mission.template_id)
    print("Difficulty: " .. mission.difficulty .. " (" .. MissionGenerator.getDifficultyDescription(mission.difficulty) .. ")")
    print("Status: " .. mission.status)
    print("Map Seed: " .. mission.map_seed)

    print("\nOBJECTIVES:")
    for i, obj in ipairs(mission.objectives) do
        print("  " .. i .. ". " .. obj.type .. ": " .. obj.description)
    end

    print("\nENEMIES: " .. #mission.enemies .. " total")
    local rankCounts = {}
    for _, enemy in ipairs(mission.enemies) do
        rankCounts[enemy.rank] = (rankCounts[enemy.rank] or 0) + 1
    end
    for rank, count in pairs(rankCounts) do
        print("  " .. rank .. ": " .. count)
    end

    print("\nREWARDS:")
    if mission.rewards then
        print("  Science: " .. (mission.rewards.science or 0))
        print("  Money: " .. (mission.rewards.money or 0))
        print("  Artifacts: " .. (mission.rewards.artifacts or 0))
    end

    print(string.rep("=", 60) .. "\n")
end

-- Helper function (should be in table lib)
function table.countKeys(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

return MissionGenerator
