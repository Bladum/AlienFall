---Mission Generation System
---
---Allows players to purchase custom missions through the Black Market that spawn on the Geoscape.
---Provides 7 mission types ranging from assassination to smuggling, with varying costs, karma penalties,
---and profit potential. Purchased missions appear on the world map after 3-7 days.
---
---Key Features:
---  - 7 mission types available for purchase
---  - Dynamic cost based on difficulty and target region
---  - Karma penalties per mission type (-10 to -40)
---  - Mission spawns on Geoscape after 3-7 day delay
---  - Profit potential: 150-300% of purchase cost
---  - Discovery risk: 8% per purchased mission
---  - Failure consequences: -50 relations with target country
---
---Mission Types:
---  - Assassination (50K, -30 karma): Kill target VIP
---  - Sabotage (40K, -20 karma): Destroy infrastructure
---  - Heist (30K, -15 karma): Steal valuable items
---  - Kidnapping (35K, -25 karma): Capture target alive
---  - False Flag (60K, -40 karma): Frame rival faction
---  - Data Theft (25K, -10 karma): Steal intelligence
---  - Smuggling (20K, -5 karma): Transport contraband
---
---Key Exports:
---  - MissionGeneration.purchaseMission(type, region, payment): Buy mission
---  - MissionGeneration.getAvailableMissions(karma): Get purchasable missions
---  - MissionGeneration.spawnMission(missionData): Spawn on Geoscape
---  - MissionGeneration.calculateReward(type, cost): Calculate profit
---
---Dependencies:
---  - geoscape.mission_system: Mission spawning
---  - economy.marketplace.black_market_system: Purchase channel
---  - politics.karma_system: Karma penalties
---
---@module economy.mission_generation
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local MissionGeneration = {}

-- Configuration
MissionGeneration.CONFIG = {
    -- Mission type definitions
    MISSIONS = {
        assassination = {
            id = "assassination",
            name = "Assassination Contract",
            description = "Eliminate high-value target",
            base_cost = 50000,
            karma_penalty = -30,
            difficulty = "hard",
            spawn_delay_min = 3,
            spawn_delay_max = 7,
            profit_multiplier_min = 2.0,
            profit_multiplier_max = 3.0,
            discovery_chance = 0.12,
            failure_relation_penalty = -50,
        },
        sabotage = {
            id = "sabotage",
            name = "Sabotage Operation",
            description = "Destroy enemy infrastructure",
            base_cost = 40000,
            karma_penalty = -20,
            difficulty = "moderate",
            spawn_delay_min = 3,
            spawn_delay_max = 7,
            profit_multiplier_min = 1.8,
            profit_multiplier_max = 2.5,
            discovery_chance = 0.10,
            failure_relation_penalty = -40,
        },
        heist = {
            id = "heist",
            name = "Heist Mission",
            description = "Steal valuable items or technology",
            base_cost = 30000,
            karma_penalty = -15,
            difficulty = "moderate",
            spawn_delay_min = 4,
            spawn_delay_max = 6,
            profit_multiplier_min = 2.0,
            profit_multiplier_max = 3.0,
            discovery_chance = 0.08,
            failure_relation_penalty = -30,
        },
        kidnapping = {
            id = "kidnapping",
            name = "Kidnapping Operation",
            description = "Capture target alive for ransom",
            base_cost = 35000,
            karma_penalty = -25,
            difficulty = "hard",
            spawn_delay_min = 3,
            spawn_delay_max = 7,
            profit_multiplier_min = 2.2,
            profit_multiplier_max = 2.8,
            discovery_chance = 0.11,
            failure_relation_penalty = -45,
        },
        false_flag = {
            id = "false_flag",
            name = "False Flag Operation",
            description = "Attack disguised as rival faction",
            base_cost = 60000,
            karma_penalty = -40,
            difficulty = "horror",
            spawn_delay_min = 5,
            spawn_delay_max = 7,
            profit_multiplier_min = 1.5,
            profit_multiplier_max = 2.5,
            discovery_chance = 0.15,
            failure_relation_penalty = -70,
        },
        data_theft = {
            id = "data_theft",
            name = "Data Theft",
            description = "Steal classified intelligence",
            base_cost = 25000,
            karma_penalty = -10,
            difficulty = "moderate",
            spawn_delay_min = 3,
            spawn_delay_max = 5,
            profit_multiplier_min = 1.8,
            profit_multiplier_max = 2.3,
            discovery_chance = 0.07,
            failure_relation_penalty = -25,
        },
        smuggling = {
            id = "smuggling",
            name = "Smuggling Run",
            description = "Transport illegal contraband",
            base_cost = 20000,
            karma_penalty = -5,
            difficulty = "standard",
            spawn_delay_min = 2,
            spawn_delay_max = 5,
            profit_multiplier_min = 1.5,
            profit_multiplier_max = 2.0,
            discovery_chance = 0.05,
            failure_relation_penalty = -20,
        },
    },
}

---Purchase mission from Black Market
---@param missionType string Mission type ID (assassination, sabotage, etc.)
---@param targetRegion string Target region/country ID
---@param blackMarket table Black Market system
---@param karmaSystem table Karma system
---@param treasury table Treasury system
---@return boolean success
---@return string|nil reason
---@return table|nil result {mission_id, spawn_date, expected_reward}
function MissionGeneration.purchaseMission(missionType, targetRegion, blackMarket, karmaSystem, treasury)
    local cfg = MissionGeneration.CONFIG

    -- Validate mission type
    local missionDef = cfg.MISSIONS[missionType]
    if not missionDef then
        return false, "Unknown mission type: " .. missionType
    end

    -- Check funds
    if treasury and treasury:getBalance() < missionDef.base_cost then
        return false, "Insufficient funds (need " .. missionDef.base_cost .. " credits)"
    end

    -- Deduct payment
    if treasury then
        treasury:deduct(missionDef.base_cost, "Black Market mission: " .. missionDef.name)
    end

    -- Apply karma penalty
    if karmaSystem then
        karmaSystem:modify(missionDef.karma_penalty, "Purchased mission: " .. missionDef.name)
    end

    -- Calculate spawn date (3-7 days from now)
    local spawnDelay = math.random(missionDef.spawn_delay_min, missionDef.spawn_delay_max)
    local spawnDate = os.time() + (spawnDelay * 86400)  -- days to seconds

    -- Calculate expected reward
    local profitMultiplier = missionDef.profit_multiplier_min +
        math.random() * (missionDef.profit_multiplier_max - missionDef.profit_multiplier_min)
    local expectedReward = math.floor(missionDef.base_cost * profitMultiplier)

    -- Create mission data
    local missionData = {
        id = "bm_" .. missionType .. "_" .. os.time(),
        type = missionType,
        definition = missionDef,
        target_region = targetRegion,
        purchase_date = os.time(),
        spawn_date = spawnDate,
        spawn_delay_days = spawnDelay,
        expected_reward = expectedReward,
        purchased_through_black_market = true,
        discovery_chance = missionDef.discovery_chance,
    }

    -- Schedule mission spawn
    MissionGeneration._scheduleMissionSpawn(missionData)

    print(string.format("[MissionGeneration] Mission purchased: %s", missionDef.name))
    print(string.format("  Cost: %d credits", missionDef.base_cost))
    print(string.format("  Karma: %d", missionDef.karma_penalty))
    print(string.format("  Spawns in: %d days", spawnDelay))
    print(string.format("  Expected reward: %d credits (%.1fx profit)",
        expectedReward, profitMultiplier))

    return true, nil, {
        mission_id = missionData.id,
        spawn_date = spawnDate,
        spawn_delay_days = spawnDelay,
        expected_reward = expectedReward,
        profit_multiplier = profitMultiplier,
    }
end

---Get available missions for purchase based on karma level
---@param karma number Current karma level (-100 to +100)
---@return table missions Array of available mission definitions
function MissionGeneration.getAvailableMissions(karma)
    local cfg = MissionGeneration.CONFIG
    local available = {}

    -- Determine access based on karma
    -- Higher karma = fewer dark missions available
    for missionType, missionDef in pairs(cfg.MISSIONS) do
        local karmaRequired = missionDef.karma_penalty * -1  -- Convert penalty to requirement

        -- Mission available if player karma is low enough
        if karma <= karmaRequired then
            table.insert(available, missionDef)
        end
    end

    -- Sort by cost (ascending)
    table.sort(available, function(a, b) return a.base_cost < b.base_cost end)

    print(string.format("[MissionGeneration] %d missions available at karma %d",
        #available, karma))

    return available
end

---Schedule mission to spawn on Geoscape after delay
---@param missionData table Mission data with spawn_date
function MissionGeneration._scheduleMissionSpawn(missionData)
    -- TODO: Integrate with Geoscape time system to schedule spawn
    -- For now, store in pending missions table

    if not MissionGeneration._pendingMissions then
        MissionGeneration._pendingMissions = {}
    end

    table.insert(MissionGeneration._pendingMissions, missionData)

    print(string.format("[MissionGeneration] Mission scheduled: %s (spawns at %d)",
        missionData.id, missionData.spawn_date))
end

---Check and spawn pending missions (called by time system)
---@param currentTime number Current game time (timestamp)
---@return number spawned Number of missions spawned
function MissionGeneration.updatePendingMissions(currentTime)
    if not MissionGeneration._pendingMissions then
        return 0
    end

    local spawned = 0
    local remaining = {}

    for _, missionData in ipairs(MissionGeneration._pendingMissions) do
        if currentTime >= missionData.spawn_date then
            -- Spawn mission
            local success = MissionGeneration.spawnMission(missionData)
            if success then
                spawned = spawned + 1
            else
                -- Failed to spawn, keep in pending
                table.insert(remaining, missionData)
            end
        else
            -- Not yet time to spawn
            table.insert(remaining, missionData)
        end
    end

    MissionGeneration._pendingMissions = remaining

    if spawned > 0 then
        print(string.format("[MissionGeneration] Spawned %d pending missions", spawned))
    end

    return spawned
end

---Spawn mission on Geoscape
---@param missionData table Mission data
---@return boolean success
function MissionGeneration.spawnMission(missionData)
    if not missionData then
        return false
    end

    -- TODO: Integrate with Geoscape mission system
    -- geoscapeSystem:spawnMission(missionData)

    print(string.format("[MissionGeneration] Mission spawned on Geoscape: %s",
        missionData.definition.name))
    print(string.format("  Type: %s", missionData.type))
    print(string.format("  Region: %s", missionData.target_region))
    print(string.format("  Difficulty: %s", missionData.definition.difficulty))
    print(string.format("  Expected reward: %d credits", missionData.expected_reward))

    return true
end

---Calculate mission reward (called when mission completes)
---@param missionType string Mission type
---@param baseCost number Original purchase cost
---@param performance table Mission performance {success, objectives_complete, time_bonus}
---@return number reward Final reward in credits
function MissionGeneration.calculateReward(missionType, baseCost, performance)
    local cfg = MissionGeneration.CONFIG
    local missionDef = cfg.MISSIONS[missionType]

    if not missionDef then
        return 0
    end

    -- Base reward (profit multiplier)
    local profitMultiplier = missionDef.profit_multiplier_min +
        math.random() * (missionDef.profit_multiplier_max - missionDef.profit_multiplier_min)
    local baseReward = baseCost * profitMultiplier

    -- Performance modifiers
    local modifier = 1.0

    if performance then
        -- Success bonus
        if performance.success then
            modifier = modifier + 0.2  -- +20% for success
        end

        -- Objectives bonus
        if performance.objectives_complete then
            modifier = modifier + (performance.objectives_complete * 0.1)  -- +10% per objective
        end

        -- Time bonus
        if performance.time_bonus then
            modifier = modifier + performance.time_bonus  -- Variable time bonus
        end

        -- Failure penalty
        if not performance.success then
            modifier = 0.0  -- No reward on failure
        end
    end

    local finalReward = math.floor(baseReward * modifier)

    print(string.format("[MissionGeneration] Mission reward calculated: %d credits (%.1fx multiplier)",
        finalReward, modifier))

    return finalReward
end

---Handle mission failure consequences
---@param missionData table Mission data
---@param relationSystem table Relations system
function MissionGeneration.handleMissionFailure(missionData, relationSystem)
    if not missionData then return end

    local missionDef = missionData.definition

    print(string.format("[MissionGeneration] Mission failed: %s", missionDef.name))

    -- Apply relation penalty with target country/region
    if relationSystem and missionData.target_region then
        local penalty = missionDef.failure_relation_penalty
        -- TODO: Apply to target country
        -- relationSystem:modify(missionData.target_region, penalty, "Failed black market mission")
        print(string.format("  Relations penalty: %d with %s", penalty, missionData.target_region))
    end

    -- Roll for discovery (mission traced back to player)
    local discovered = (math.random() < missionDef.discovery_chance)
    if discovered then
        print("[MissionGeneration] WARNING: Mission traced back to player organization!")
        -- TODO: Apply fame and karma penalties
        -- fameSystem:modify(-30, "Failed black market mission discovered")
        -- karmaSystem:modify(-10, "Failed mission traced back")
    end
end

---Get mission type definition
---@param missionType string Mission type ID
---@return table|nil definition Mission definition or nil
function MissionGeneration.getMissionDefinition(missionType)
    return MissionGeneration.CONFIG.MISSIONS[missionType]
end

---Get all mission types
---@return table missions Array of all mission definitions
function MissionGeneration.getAllMissionTypes()
    local missions = {}
    for _, def in pairs(MissionGeneration.CONFIG.MISSIONS) do
        table.insert(missions, def)
    end

    -- Sort by cost
    table.sort(missions, function(a, b) return a.base_cost < b.base_cost end)

    return missions
end

return MissionGeneration

