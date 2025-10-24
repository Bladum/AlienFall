---
-- Mission Outcome Processor
-- @module engine.geoscape.mission_outcome_processor
-- @author Copilot
-- @license MIT
--
-- Processes battlescape mission outcomes and updates campaign state.
-- Handles victory/defeat/retreat status recording, combat results processing,
-- casualty handling, and campaign data synchronization.
--
-- Key exports:
-- - processMissionOutcome() - Main entry point for outcome processing
-- - recordMissionResults() - Store results in campaign manager
-- - calculateVictoryRewards() - Determine rewards based on performance
-- - processUnitCasualties() - Handle unit deaths and injuries
-- - processCraftDamage() - Record craft damage from mission

local MissionOutcomeProcessor = {}

---
-- Process a complete mission outcome from battlescape
-- @param mission table Mission data with objectives, type, difficulty
-- @param battleResult table Battlescape exit data (outcome, units, casualties, combat_log)
-- @return table Complete outcome summary with rewards and updates
function MissionOutcomeProcessor.processMissionOutcome(mission, battleResult)
    if not mission or not battleResult then
        print("[MissionOutcomeProcessor] ERROR: Missing mission or battleResult")
        return nil
    end

    local outcome = {
        missionId = mission.id,
        timestamp = os.time(),
        status = battleResult.outcome or "retreat",  -- victory, defeat, retreat
        objectives_completed = battleResult.objectives_completed or {},
        enemies_killed = battleResult.enemies_killed or 0,
        casualties = battleResult.casualties or {},
        wounded = battleResult.wounded or {},
        items_collected = battleResult.items_collected or {},
        crafts_damaged = battleResult.crafts_damaged or {},
        rewards = {},
        campaign_updates = {}
    }

    print(string.format("[MissionOutcomeProcessor] Processing mission %s: %s", mission.id, outcome.status))

    -- Record mission results
    MissionOutcomeProcessor._recordMissionResults(mission, outcome)

    -- Process unit casualties
    MissionOutcomeProcessor._processUnitCasualties(mission, outcome)

    -- Process craft damage
    MissionOutcomeProcessor._processCraftDamage(mission, outcome)

    -- Calculate rewards based on victory/defeat
    outcome.rewards = MissionOutcomeProcessor._calculateVictoryRewards(mission, outcome)

    -- Generate campaign updates
    outcome.campaign_updates = MissionOutcomeProcessor._generateCampaignUpdates(mission, outcome)

    print(string.format("[MissionOutcomeProcessor] Mission outcome processed: %d killed, %d casualties",
        outcome.enemies_killed, #outcome.casualties))

    return outcome
end

---
-- Record mission results in campaign manager
-- @param mission table Mission data
-- @param outcome table Outcome data being processed
function MissionOutcomeProcessor._recordMissionResults(mission, outcome)
    -- TODO: Integrate with CampaignManager
    -- campaignManager:recordMissionResult(outcome)

    local missionData = {
        id = mission.id,
        type = mission.type,
        location = mission.location,
        completed_at = outcome.timestamp,
        status = outcome.status,
        objectives_completed = outcome.objectives_completed,
        enemies_killed = outcome.enemies_killed,
        casualties_count = #outcome.casualties,
        wounded_count = #outcome.wounded
    }

    print(string.format("[MissionOutcomeProcessor] Mission %s recorded: status=%s, killed=%d",
        missionData.id, missionData.status, missionData.enemies_killed))
end

---
-- Process unit casualties and deaths
-- @param mission table Mission data
-- @param outcome table Outcome being processed
function MissionOutcomeProcessor._processUnitCasualties(mission, outcome)
    local totalCasualties = 0

    for unitId, casualtyData in pairs(outcome.casualties) do
        print(string.format("[MissionOutcomeProcessor] Unit %s: %s", unitId, casualtyData.cause or "unknown"))
        totalCasualties = totalCasualties + 1

        -- TODO: Mark unit as dead in campaign
        -- Remove from active roster, move to memorial
        -- campaignManager:recordUnitDeath(unitId, casualtyData)
    end

    -- Process wounded units with injuries/wounds
    for unitId, woundData in pairs(outcome.wounded) do
        print(string.format("[MissionOutcomeProcessor] Unit %s: %d HP remaining (injured)",
            unitId, woundData.hp_remaining or 0))

        -- TODO: Record injuries in unit record
        -- woundData structure: {hp_remaining, wounds_list[], sanity_damage, status_effects[]}
        -- campaignManager:recordUnitInjury(unitId, woundData)
    end

    print(string.format("[MissionOutcomeProcessor] Processed %d casualties, %d wounded",
        totalCasualties, countTable(outcome.wounded)))
end

---
-- Process craft damage from mission
-- @param mission table Mission data (contains craft_id, equipment_used)
-- @param outcome table Outcome data
function MissionOutcomeProcessor._processCraftDamage(mission, outcome)
    if not mission.craft_id then
        print("[MissionOutcomeProcessor] No craft used in this mission")
        return
    end

    local craftDamage = outcome.crafts_damaged[mission.craft_id] or {}

    local damage = {
        craft_id = mission.craft_id,
        hull_damage = craftDamage.hull_damage or 0,
        engine_damage = craftDamage.engine_damage or 0,
        weapon_damage = craftDamage.weapon_damage or 0,
        systems_damage = craftDamage.systems_damage or 0,
        fuel_consumed = craftDamage.fuel_consumed or 0,
        pilot_tired = craftDamage.pilot_tired or false,
        needs_repair = (craftDamage.hull_damage or 0) > 0
    }

    print(string.format("[MissionOutcomeProcessor] Craft %s damage: hull=%d, engine=%d, weapons=%d, fuel=%d",
        mission.craft_id, damage.hull_damage, damage.engine_damage,
        damage.weapon_damage, damage.fuel_consumed))

    -- TODO: Record craft damage and schedule repairs
    -- campaignManager:recordCraftDamage(damage)
end

---
-- Calculate victory rewards based on mission performance
-- @param mission table Mission data
-- @param outcome table Outcome data
-- @return table Rewards including credits, items, research points, reputation
function MissionOutcomeProcessor._calculateVictoryRewards(mission, outcome)
    local rewards = {
        credits = 0,
        research_points = 0,
        items = {},
        reputation_gain = 0,
        threat_reduction = 0
    }

    -- Base rewards depend on mission status
    if outcome.status == "victory" then
        -- Victory rewards: full credits + bonus
        rewards.credits = (mission.reward_credits or 1000) + (outcome.enemies_killed * 50)
        rewards.research_points = outcome.enemies_killed * 10  -- Per alien killed
        rewards.reputation_gain = 50  -- Mission success bonus
        rewards.threat_reduction = 5  -- Successful mission reduces threat

        print(string.format("[MissionOutcomeProcessor] Victory rewards: %d credits, %d RP, rep +%d",
            rewards.credits, rewards.research_points, rewards.reputation_gain))

    elseif outcome.status == "defeat" then
        -- Defeat penalties: minimal rewards
        rewards.credits = (mission.reward_credits or 1000) * 0.25  -- 25% of base
        rewards.reputation_gain = -30  -- Mission failure penalty
        rewards.threat_reduction = -10  -- Failed mission increases threat

        print(string.format("[MissionOutcomeProcessor] Defeat penalties: %d credits, rep %d, threat -10",
            rewards.credits, rewards.reputation_gain))

    elseif outcome.status == "retreat" then
        -- Retreat: emergency evacuation
        rewards.credits = (mission.reward_credits or 1000) * 0.5  -- 50% partial reward
        rewards.reputation_gain = -10  -- Mild penalty
        rewards.threat_reduction = -5  -- Retreat increases threat slightly

        print(string.format("[MissionOutcomeProcessor] Retreat: %d credits (partial), rep -10",
            rewards.credits))
    end

    -- Objective completion bonus
    for _, objective in ipairs(outcome.objectives_completed or {}) do
        rewards.research_points = rewards.research_points + 50  -- Per objective
    end

    -- Casualty penalties
    if #outcome.casualties > 0 then
        rewards.reputation_gain = rewards.reputation_gain - (#outcome.casualties * 20)
    end

    rewards.total_credits = math.floor(rewards.credits)
    return rewards
end

---
-- Generate campaign updates based on mission outcome
-- @param mission table Mission data
-- @param outcome table Outcome data
-- @return table List of campaign updates to apply
function MissionOutcomeProcessor._generateCampaignUpdates(mission, outcome)
    local updates = {}

    -- Update threat level
    table.insert(updates, {
        type = "threat_adjustment",
        value = outcome.rewards.threat_reduction,
        reason = "mission_" .. outcome.status
    })

    -- Update funding
    table.insert(updates, {
        type = "funding",
        amount = outcome.rewards.total_credits,
        source = "mission_reward",
        mission_id = mission.id
    })

    -- Update research progress
    if outcome.rewards.research_points > 0 then
        table.insert(updates, {
            type = "research_progress",
            points = outcome.rewards.research_points,
            mission_id = mission.id
        })
    end

    -- Update reputation
    if outcome.rewards.reputation_gain ~= 0 then
        table.insert(updates, {
            type = "reputation",
            change = outcome.rewards.reputation_gain,
            mission_id = mission.id
        })
    end

    -- Mark mission as completed in campaign
    table.insert(updates, {
        type = "mission_complete",
        mission_id = mission.id,
        status = outcome.status,
        completed_at = outcome.timestamp
    })

    print(string.format("[MissionOutcomeProcessor] Generated %d campaign updates", #updates))
    return updates
end

---
-- Helper: Count table entries
-- @param tbl table Table to count
-- @return number Number of entries
function countTable(tbl)
    local count = 0
    for _ in pairs(tbl or {}) do
        count = count + 1
    end
    return count
end

return MissionOutcomeProcessor
