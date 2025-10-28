---
-- Campaign Difficulty Escalation System
-- @module engine.geoscape.logic.difficulty_escalation
-- @author Copilot
-- @license MIT
--
-- Implements adaptive difficulty scaling based on player performance.
-- Adjusts alien activity, mission frequency, enemy composition, and UFO behavior.
-- Creates challenging gameplay that responds to player success and failure.
--
-- Key exports:
-- - updateDifficultyAfterMission() - Adjust difficulty based on outcome
-- - calculateThreatLevel() - Determine current threat severity
-- - scaleMissionDifficulty() - Apply difficulty to mission generation
-- - getEnemyComposition() - Get alien unit types for mission
-- - adjustUFOActivity() - Modify UFO frequency and behavior

local DifficultyEscalation = {}

---
-- Update campaign difficulty after mission completion
-- @param mission table Mission data including difficulty, objectives
-- @param outcome table Mission outcome (victory/defeat/retreat, enemies_killed)
-- @param campaignData table Campaign state (wins, losses, threat_level)
-- @return table Updated threat data
function DifficultyEscalation.updateDifficultyAfterMission(mission, outcome, campaignData)
    if not mission or not outcome or not campaignData then
        print("[DifficultyEscalation] ERROR: Missing required data")
        return nil
    end

    campaignData = campaignData or {
        wins = 0,
        losses = 0,
        retreats = 0,
        threat_level = 50,
        mission_frequency = 2,  -- 2 missions per month
        enemy_difficulty = "normal"
    }

    local threatUpdate = {
        previous_threat = campaignData.threat_level,
        threat_change = 0,
        outcome = outcome.status,
        winning_streak = 0,
        threat_factors = {}
    }

    print(string.format("[DifficultyEscalation] Updating difficulty after %s (threat: %d)",
        outcome.status, campaignData.threat_level))

    -- Mission outcome impact
    if outcome.status == "victory" then
        campaignData.wins = campaignData.wins + 1
        threatUpdate.threat_change = -5  -- Victory reduces threat
        table.insert(threatUpdate.threat_factors, "victory: -5")

        -- Check for winning streak (3+ consecutive wins)
        if campaignData.wins >= 3 then
            threatUpdate.threat_change = threatUpdate.threat_change + 10  -- Escalate
            table.insert(threatUpdate.threat_factors, "winning_streak_x3: +10")
            print("[DifficultyEscalation] Winning streak detected - escalating threat")
        end

    elseif outcome.status == "defeat" then
        campaignData.wins = 0  -- Reset streak
        campaignData.losses = campaignData.losses + 1
        threatUpdate.threat_change = 15  -- Defeat increases threat significantly
        table.insert(threatUpdate.threat_factors, "defeat: +15")

    elseif outcome.status == "retreat" then
        campaignData.retreats = campaignData.retreats + 1
        threatUpdate.threat_change = 8  -- Retreat slightly increases threat
        table.insert(threatUpdate.threat_factors, "retreat: +8")
    end

    -- Mission difficulty impact
    local difficultyModifier = {
        easy = -5,
        normal = 0,
        hard = 5,
        impossible = 10
    }
    threatUpdate.threat_change = threatUpdate.threat_change +
        (difficultyModifier[mission.difficulty] or 0)
    table.insert(threatUpdate.threat_factors, "difficulty_" .. (mission.difficulty or "normal"))

    -- Enemy composition impact (aliens killed)
    if outcome.enemies_killed and outcome.enemies_killed > 20 then
        threatUpdate.threat_change = threatUpdate.threat_change + 5  -- Many kills = escalate
        table.insert(threatUpdate.threat_factors, "high_kill_count: +5")
    elseif outcome.enemies_killed and outcome.enemies_killed < 5 then
        threatUpdate.threat_change = threatUpdate.threat_change - 3  -- Few kills = reduce
        table.insert(threatUpdate.threat_factors, "low_kill_count: -3")
    end

    -- Player loss impact (casualties matter)
    if outcome.casualties and #outcome.casualties > 5 then
        threatUpdate.threat_change = threatUpdate.threat_change - 8  -- High losses reduce threat
        table.insert(threatUpdate.threat_factors, "high_casualties: -8")
    end

    -- Apply threat change with bounds
    campaignData.threat_level = math.max(0, math.min(100,
        campaignData.threat_level + threatUpdate.threat_change))

    threatUpdate.new_threat = campaignData.threat_level

    -- Update mission frequency based on threat
    campaignData.mission_frequency = DifficultyEscalation._calculateMissionFrequency(
        campaignData.threat_level)

    -- Update enemy difficulty
    campaignData.enemy_difficulty = DifficultyEscalation._calculateEnemyDifficulty(
        campaignData.threat_level)

    print(string.format("[DifficultyEscalation] Threat updated: %d → %d (change: %+d)",
        threatUpdate.previous_threat, threatUpdate.new_threat, threatUpdate.threat_change))
    print(string.format("[DifficultyEscalation] Mission frequency: %d/month, Enemy difficulty: %s",
        campaignData.mission_frequency, campaignData.enemy_difficulty))

    return threatUpdate
end

---
-- Calculate current threat level (0-100)
-- @param wins number Mission victories
-- @param losses number Mission defeats
-- @param retreats number Mission retreats
-- @param daysElapsed number Campaign days elapsed
-- @return number Threat level 0-100
function DifficultyEscalation.calculateThreatLevel(wins, losses, retreats, daysElapsed)
    local threatLevel = 50  -- Start at neutral

    -- Win/loss ratio impact
    local totalMissions = wins + losses + retreats
    if totalMissions > 0 then
        local winRate = wins / totalMissions
        threatLevel = threatLevel + ((winRate - 0.5) * 40)  -- ±40 from win rate
    end

    -- Time-based escalation (aliens getting stronger over time)
    local monthsElapsed = (daysElapsed or 0) / 30
    local timeEscalation = monthsElapsed * 2  -- +2 per month (120 in year)
    threatLevel = threatLevel + timeEscalation

    -- Bounds
    threatLevel = math.max(0, math.min(100, threatLevel))

    print(string.format("[DifficultyEscalation] Threat calculation: base=50, win_ratio=%+d, time=%+d, final=%d",
        math.floor(((winRate or 0) - 0.5) * 40),
        math.floor(timeEscalation),
        threatLevel))

    return threatLevel
end

---
-- Scale mission difficulty based on threat level
-- @param mission table Mission to modify
-- @param threatLevel number Current threat 0-100
-- @return table Mission with adjusted difficulty
function DifficultyEscalation.scaleMissionDifficulty(mission, threatLevel)
    mission = mission or {}
    threatLevel = threatLevel or 50

    -- Map threat to difficulty
    local difficultyMap = {
        [1] = "easy",      -- Threat 0-20
        [2] = "normal",    -- Threat 21-50
        [3] = "hard",      -- Threat 51-80
        [4] = "impossible" -- Threat 81-100
    }

    local threatBucket = math.ceil(threatLevel / 25)
    local scaledDifficulty = difficultyMap[threatBucket] or "normal"

    mission.scaled_difficulty = scaledDifficulty
    mission.original_difficulty = mission.difficulty or "normal"

    -- Scale enemy stats by difficulty
    local difficultyMultipliers = {
        easy = 0.7,
        normal = 1.0,
        hard = 1.4,
        impossible = 2.0
    }

    mission.enemy_stat_multiplier = difficultyMultipliers[scaledDifficulty] or 1.0
    mission.enemy_count_multiplier = difficultyMultipliers[scaledDifficulty] or 1.0

    print(string.format("[DifficultyEscalation] Mission %s scaled from %s to %s (threat %d)",
        mission.id, mission.original_difficulty, scaledDifficulty, threatLevel))

    return mission
end

---
-- Get alien unit composition for mission
-- @param threatLevel number Current threat level
-- @param missionType string Type of mission (site/ufo/base)
-- @return table Enemy unit roster
function DifficultyEscalation.getEnemyComposition(threatLevel, missionType)
    missionType = missionType or "site"

    -- Unit types by threat level
    local unitRoster = {
        low = {"sectoid", "sectoid"},  -- 2 basic aliens
        medium = {"sectoid", "sectoid", "sectoid", "muton"},  -- 3 Sectoids, 1 Muton
        high = {"sectoid", "muton", "muton", "ethereal"},  -- 2 Mutons, 1 Ethereal
        critical = {"muton", "ethereal", "ethereal", "muton"}  -- 2 Mutons, 2 Ethereals
    }

    local threatBracket
    if threatLevel < 20 then
        threatBracket = "low"
    elseif threatLevel < 50 then
        threatBracket = "medium"
    elseif threatLevel < 80 then
        threatBracket = "high"
    else
        threatBracket = "critical"
    end

    -- Mission type modifiers
    local missionModifiers = {
        site = 1.0,           -- Standard
        ufo = 1.3,            -- More units
        base = 0.8            -- Fewer units (defend)
    }

    local roster = unitRoster[threatBracket] or unitRoster.medium
    local modifier = missionModifiers[missionType] or 1.0

    -- Scale roster size
    local scaledRoster = {}
    local targetCount = math.ceil(#roster * modifier)
    for i = 1, targetCount do
        table.insert(scaledRoster, roster[(i % #roster) + 1])
    end

    print(string.format("[DifficultyEscalation] Enemy composition: threat=%d, type=%s, roster_size=%d",
        threatLevel, missionType, #scaledRoster))

    return scaledRoster
end

---
-- Adjust UFO activity based on threat level
-- @param threatLevel number Current threat 0-100
-- @return table UFO activity parameters
function DifficultyEscalation.adjustUFOActivity(threatLevel)
    local activity = {
        threat_level = threatLevel,
        ufo_spawn_rate = 0,      -- UFOs per month
        ufo_patrol_frequency = 0, -- Patrol updates per month
        intercept_probability = 0, -- % chance of interception when UFO detected
        base_assault_probability = 0 -- % chance of base attack
    }

    if threatLevel < 20 then
        activity.ufo_spawn_rate = 1
        activity.ufo_patrol_frequency = 2
        activity.intercept_probability = 30
        activity.base_assault_probability = 5
    elseif threatLevel < 50 then
        activity.ufo_spawn_rate = 2
        activity.ufo_patrol_frequency = 4
        activity.intercept_probability = 50
        activity.base_assault_probability = 15
    elseif threatLevel < 80 then
        activity.ufo_spawn_rate = 4
        activity.ufo_patrol_frequency = 6
        activity.intercept_probability = 70
        activity.base_assault_probability = 35
    else
        activity.ufo_spawn_rate = 6
        activity.ufo_patrol_frequency = 8
        activity.intercept_probability = 90
        activity.base_assault_probability = 60
    end

    print(string.format("[DifficultyEscalation] UFO activity: spawn=%d/month, patrol_freq=%d, intercept=%d%%",
        activity.ufo_spawn_rate, activity.ufo_patrol_frequency, activity.intercept_probability))

    return activity
end

---
-- Calculate mission frequency based on threat level
-- @param threatLevel number Current threat 0-100
-- @return number Missions per month
function DifficultyEscalation._calculateMissionFrequency(threatLevel)
    if threatLevel < 20 then
        return 1  -- 1 mission/month
    elseif threatLevel < 50 then
        return 2  -- 2 missions/month
    elseif threatLevel < 80 then
        return 4  -- 4 missions/month
    else
        return 6  -- 6 missions/month
    end
end

---
-- Calculate enemy difficulty based on threat
-- @param threatLevel number Current threat 0-100
-- @return string Difficulty name
function DifficultyEscalation._calculateEnemyDifficulty(threatLevel)
    if threatLevel < 20 then
        return "easy"
    elseif threatLevel < 50 then
        return "normal"
    elseif threatLevel < 80 then
        return "hard"
    else
        return "impossible"
    end
end

return DifficultyEscalation

