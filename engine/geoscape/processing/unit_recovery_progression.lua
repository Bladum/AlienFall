---
-- Unit Recovery & Progression System
-- @module engine.geoscape.unit_recovery_progression
-- @author Copilot
-- @license MIT
--
-- Manages unit recovery from injuries, wound healing, medical facility bonuses,
-- experience/rank progression from missions, kill tracking, promotions, and veteran status.
-- Integrates with battlescape unit data to process mission outcomes.
--
-- Key exports:
-- - processUnitRecovery() - Apply recovery to injured units
-- - processUnitProgression() - Award XP and handle promotions
-- - recordUnitKills() - Track unit kill counts
-- - getUnitStatus() - Retrieve recovery/progression status
-- - calculatePromotionThreshold() - Determine rank advancement requirements

local UnitRecoveryProgression = {}

---
-- Process recovery for a unit returning from mission
-- @param unitId string Unit identifier
-- @param injuryData table Damage taken (hp_remaining, wounds_count, sanity_damage)
-- @param medicalFacility table Available medical facility (optional, provides bonuses)
-- @return table Recovery schedule and status
function UnitRecoveryProgression.processUnitRecovery(unitId, injuryData, medicalFacility)
    if not unitId then
        print("[UnitRecoveryProgression] ERROR: Missing unitId")
        return nil
    end

    injuryData = injuryData or {}
    medicalFacility = medicalFacility or {}

    local recovery = {
        unit_id = unitId,
        processed_at = os.time(),
        status = "active",  -- active, wounded, incapacitated, dead
        health = {
            hp_remaining = injuryData.hp_remaining or 100,
            hp_max = 100,
            recovery_per_day = 5,
            days_to_recover = 0
        },
        wounds = {
            count = injuryData.wounds_count or 0,
            types = injuryData.wounds_list or {},
            bleeding_damage = 0,
            healing_time = 0
        },
        sanity = {
            damage = injuryData.sanity_damage or 0,
            recovery_per_day = 3,
            days_to_recover = 0
        },
        available_deployment = true,
        medical_bonus_applied = false
    }

    print(string.format("[UnitRecoveryProgression] Processing recovery for unit %s: hp=%d, wounds=%d, sanity_dmg=%d",
        unitId, recovery.health.hp_remaining, recovery.wounds.count, recovery.sanity.damage))

    -- Calculate HP recovery time
    if recovery.health.hp_remaining < 100 then
        local hpNeeded = 100 - recovery.health.hp_remaining
        recovery.health.recovery_per_day = UnitRecoveryProgression._calculateHPRecoveryRate(
            recovery.health.recovery_per_day,
            medicalFacility.healing_bonus or 0,
            recovery.wounds.count
        )
        recovery.health.days_to_recover = math.ceil(hpNeeded / recovery.health.recovery_per_day)
    end

    -- Calculate wound healing time
    if recovery.wounds.count > 0 then
        -- 3-5 days per wound, reduced by medical facility
        local daysPerWound = math.max(1, 3 - (medicalFacility.wound_speed_bonus or 0))
        recovery.wounds.healing_time = recovery.wounds.count * daysPerWound
        recovery.wounds.bleeding_damage = recovery.wounds.count  -- 1 HP per wound per turn
        recovery.available_deployment = false  -- Wounded units unavailable
        print(string.format("[UnitRecoveryProgression] Unit %s wounds: %d wounds, %d days to heal",
            unitId, recovery.wounds.count, recovery.wounds.healing_time))
    end

    -- Calculate sanity recovery time
    if recovery.sanity.damage > 0 then
        recovery.sanity.recovery_per_day = UnitRecoveryProgression._calculateSanityRecoveryRate(
            recovery.sanity.recovery_per_day,
            medicalFacility.psych_bonus or 0
        )
        recovery.sanity.days_to_recover = math.ceil(recovery.sanity.damage / recovery.sanity.recovery_per_day)
        print(string.format("[UnitRecoveryProgression] Unit %s sanity: damage=%d, recovery_rate=%d/day",
            unitId, recovery.sanity.damage, recovery.sanity.recovery_per_day))
    end

    -- Apply medical facility bonuses
    if medicalFacility.available then
        recovery.medical_bonus_applied = true
        recovery.health.recovery_per_day = recovery.health.recovery_per_day * (medicalFacility.healing_bonus or 1.0)
        print("[UnitRecoveryProgression] Medical facility bonus applied")
    end

    -- Determine overall recovery status
    if recovery.health.hp_remaining <= 0 then
        recovery.status = "dead"
        recovery.available_deployment = false
    elseif recovery.wounds.count > 3 then
        recovery.status = "incapacitated"
        recovery.available_deployment = false
    elseif recovery.wounds.count > 0 or recovery.sanity.damage > 0 then
        recovery.status = "wounded"
        recovery.available_deployment = false
    else
        recovery.status = "active"
        recovery.available_deployment = true
    end

    local totalRecoveryDays = math.max(
        recovery.health.days_to_recover,
        recovery.wounds.healing_time,
        recovery.sanity.days_to_recover
    )

    print(string.format("[UnitRecoveryProgression] Unit %s recovery: status=%s, total_time=%d days, available=%s",
        unitId, recovery.status, totalRecoveryDays, tostring(recovery.available_deployment)))

    return recovery
end

---
-- Process unit progression (XP, kills, ranks)
-- @param unitId string Unit identifier
-- @param missionData table Mission info (difficulty, type)
-- @param combatData table Combat performance (kills, hits, objectives)
-- @return table Progression update with XP, rank changes, medals
function UnitRecoveryProgression.processUnitProgression(unitId, missionData, combatData)
    if not unitId then
        print("[UnitRecoveryProgression] ERROR: Missing unitId")
        return nil
    end

    missionData = missionData or {}
    combatData = combatData or {}

    local progression = {
        unit_id = unitId,
        processed_at = os.time(),
        xp_earned = 0,
        kill_count = combatData.kills or 0,
        new_rank = nil,
        rank_advanced = false,
        medals_earned = {},
        achievements = {}
    }

    print(string.format("[UnitRecoveryProgression] Processing progression for unit %s", unitId))

    -- Calculate XP earned
    progression.xp_earned = UnitRecoveryProgression._calculateXPEarned(missionData, combatData)
    progression.kill_count = combatData.kills or 0

    print(string.format("[UnitRecoveryProgression] Unit %s earned: %d XP, %d kills",
        unitId, progression.xp_earned, progression.kill_count))

    -- Check for medals and achievements
    progression.medals_earned = UnitRecoveryProgression._checkMedals(unitId, combatData, missionData)
    progression.achievements = UnitRecoveryProgression._checkAchievements(unitId, combatData)

    -- Check for rank advancement
    local newRank = UnitRecoveryProgression._checkRankAdvance(unitId, progression.xp_earned)
    if newRank then
        progression.new_rank = newRank
        progression.rank_advanced = true
        print(string.format("[UnitRecoveryProgression] Unit %s PROMOTED to %s", unitId, newRank))
    end

    -- Record kill count
    UnitRecoveryProgression._recordUnitKills(unitId, progression.kill_count)

    return progression
end

---
-- Calculate XP earned from mission
-- @param missionData table Mission info (difficulty, type)
-- @param combatData table Combat data (kills, hits, objectives)
-- @return number XP earned
function UnitRecoveryProgression._calculateXPEarned(missionData, combatData)
    local xp = 50  -- Base XP for participation

    -- Mission difficulty bonus
    local difficultyXP = {
        easy = 0,
        normal = 25,
        hard = 50,
        impossible = 100
    }
    xp = xp + (difficultyXP[missionData.difficulty or "normal"] or 25)

    -- Kill bonus: 30 XP per kill
    xp = xp + ((combatData.kills or 0) * 30)

    -- Accuracy bonus: 1 XP per 5% accuracy
    local accuracyBonus = math.floor((combatData.hit_accuracy or 0) / 5)
    xp = xp + accuracyBonus

    -- Objective bonus: 20 XP per objective
    xp = xp + ((combatData.objectives_completed or 0) * 20)

    print(string.format("[UnitRecoveryProgression] XP calculation: base=50, difficulty=%d, kills=%d, objectives=%d, total=%d",
        difficultyXP[missionData.difficulty or "normal"] or 25,
        (combatData.kills or 0) * 30,
        (combatData.objectives_completed or 0) * 20,
        xp))

    return xp
end

---
-- Record unit kill count
-- @param unitId string Unit identifier
-- @param killCount number Kills in this mission
function UnitRecoveryProgression._recordUnitKills(unitId, killCount)
    -- TODO: Integrate with unit data storage
    -- campaignManager:addUnitKills(unitId, killCount)

    print(string.format("[UnitRecoveryProgression] Unit %s recorded %d kills", unitId, killCount))
end

---
-- Check if unit qualifies for medals
-- @param unitId string Unit identifier
-- @param combatData table Combat performance
-- @param missionData table Mission info
-- @return table List of medals earned
function UnitRecoveryProgression._checkMedals(unitId, combatData, missionData)
    local medals = {}

    -- Medal criteria
    if combatData.kills and combatData.kills >= 10 then
        table.insert(medals, "hero_medal")
        print("[UnitRecoveryProgression] Hero Medal earned (10+ kills)")
    end

    if combatData.objectives_completed and combatData.objectives_completed >= 5 then
        table.insert(medals, "star_gold")
        print("[UnitRecoveryProgression] Gold Star earned (5+ objectives)")
    end

    if missionData.difficulty == "impossible" then
        table.insert(medals, "legend_cross")
        print("[UnitRecoveryProgression] Legend Cross earned (Impossible difficulty)")
    end

    if combatData.survived_critical_damage then
        table.insert(medals, "commendation")
        print("[UnitRecoveryProgression] Commendation earned (Survived critical damage)")
    end

    return medals
end

---
-- Check if unit qualifies for achievements
-- @param unitId string Unit identifier
-- @param combatData table Combat performance
-- @return table List of achievements earned
function UnitRecoveryProgression._checkAchievements(unitId, combatData)
    local achievements = {}

    -- Achievement criteria
    if combatData.kills and combatData.kills >= 25 then
        table.insert(achievements, "sharpshooter")
    end

    if combatData.distance_kill and combatData.distance_kill > 10 then
        table.insert(achievements, "long_range_expert")
    end

    if combatData.headshot_count and combatData.headshot_count >= 3 then
        table.insert(achievements, "precision_shooter")
    end

    return achievements
end

---
-- Check if unit qualifies for rank advancement
-- @param unitId string Unit identifier
-- @param xpEarned number XP from this mission
-- @return string|nil New rank if promoted, nil otherwise
function UnitRecoveryProgression._checkRankAdvance(unitId, xpEarned)
    -- Rank progression thresholds
    local ranks = {
        "Rookie",           -- 0 XP
        "Soldier",          -- 100 XP
        "Sergeant",         -- 250 XP
        "Lieutenant",       -- 500 XP
        "Captain",          -- 1000 XP
        "Major",            -- 2000 XP
        "Colonel"           -- 4000 XP
    }

    -- TODO: Get unit current XP and rank from campaign manager
    local currentXP = 0  -- Would be fetched from unit data
    local currentRank = 1  -- Rookie

    local newXP = currentXP + xpEarned

    -- Check for rank thresholds
    local rankThresholds = {100, 250, 500, 1000, 2000, 4000}
    for rankLevel = currentRank + 1, #ranks do
        if newXP >= rankThresholds[rankLevel - 1] then
            return ranks[rankLevel]
        end
    end

    return nil
end

---
-- Calculate HP recovery rate with modifiers
-- @param baseRate number Base recovery rate
-- @param medicalBonus number Medical facility bonus multiplier
-- @param woundCount number Number of active wounds
-- @return number Adjusted recovery rate
function UnitRecoveryProgression._calculateHPRecoveryRate(baseRate, medicalBonus, woundCount)
    local rate = baseRate * (1.0 + medicalBonus)

    -- Wounds slow recovery: -20% per wound
    if woundCount > 0 then
        rate = rate * (1.0 - (woundCount * 0.2))
    end

    return math.max(1, rate)
end

---
-- Calculate sanity recovery rate (updated to match MoraleBraverySanity.md design)
-- Base recovery: +1 per week (+0.14 per day)
-- Temple bonus: +1 per week (+0.14 per day) if Temple facility exists at base
-- @param baseRate number Base recovery rate (default 0.14 per day = 1 per week)
-- @param psychBonus number Psychological support bonus (0 or 0.14 for Temple)
-- @param hasTemple boolean Whether base has operational Temple facility
-- @return number Adjusted recovery rate per day
function UnitRecoveryProgression._calculateSanityRecoveryRate(baseRate, psychBonus, hasTemple)
    -- Base recovery: 1 per week = ~0.14 per day (1/7)
    local rate = baseRate or (1.0 / 7.0)

    -- Temple bonus: +1 per week = +0.14 per day
    if hasTemple then
        rate = rate + (1.0 / 7.0)
        print("[UnitRecoveryProgression] Temple facility detected: +1 sanity/week bonus applied")
    end

    -- Legacy psych bonus support (if provided)
    if psychBonus and psychBonus > 0 then
        rate = rate * (1.0 + psychBonus)
    end

    return rate
end

---
-- Apply weekly sanity recovery to all units at base
-- Called by base management system once per week
-- @param baseId string Base identifier
-- @param units table Array of unit IDs at base
-- @return table Recovery summary
function UnitRecoveryProgression.applyWeeklySanityRecovery(baseId, units)
    if not baseId or not units then
        print("[UnitRecoveryProgression] ERROR: Missing baseId or units")
        return nil
    end

    -- Check if base has Temple facility
    local hasTemple = false
    -- TODO: Integrate with base facility system
    -- local base = baseManager:getBase(baseId)
    -- hasTemple = base:hasFacility("temple") and base:getFacility("temple").operational

    local MoraleSystem = require("engine.battlescape.systems.morale_system")
    local recoveredUnits = 0
    local totalRecovery = 0

    for _, unitId in ipairs(units) do
        -- Base recovery: +1 per week
        MoraleSystem.weeklyBaseRecovery(unitId)
        recoveredUnits = recoveredUnits + 1
        totalRecovery = totalRecovery + 1

        -- Temple bonus: +1 per week
        if hasTemple then
            MoraleSystem.weeklyTempleRecovery(unitId)
            totalRecovery = totalRecovery + 1
        end
    end

    print(string.format("[UnitRecoveryProgression] Weekly sanity recovery: %d units, +%d total sanity (Temple: %s)",
        recoveredUnits, totalRecovery, tostring(hasTemple)))

    return {
        base_id = baseId,
        units_recovered = recoveredUnits,
        total_recovery = totalRecovery,
        temple_bonus_applied = hasTemple
    }
end

---
-- Apply medical treatment for immediate sanity recovery
-- Cost: 10,000 credits, Effect: +3 sanity
-- @param unitId string Unit identifier
-- @param treasury table Treasury system for payment
-- @return boolean success
-- @return string|nil error message
function UnitRecoveryProgression.applyMedicalTreatment(unitId, treasury)
    local TREATMENT_COST = 10000
    local TREATMENT_RECOVERY = 3

    if not unitId then
        return false, "Missing unitId"
    end

    -- Check funds
    if treasury and treasury:getBalance() < TREATMENT_COST then
        return false, "Insufficient funds (need 10,000 credits)"
    end

    -- Deduct payment
    if treasury then
        treasury:deduct(TREATMENT_COST, "Medical treatment: " .. unitId)
    end

    -- Apply recovery
    local MoraleSystem = require("engine.battlescape.systems.morale_system")
    MoraleSystem.medicalTreatment(unitId)

    print(string.format("[UnitRecoveryProgression] Medical treatment applied: %s (+3 sanity, -10,000 credits)", unitId))
    return true
end

---
-- Apply leave/vacation for extended sanity recovery
-- Cost: 5,000 credits, Effect: +5 sanity over 2 weeks, unit unavailable
-- @param unitId string Unit identifier
-- @param treasury table Treasury system for payment
-- @return boolean success
-- @return string|nil error message
function UnitRecoveryProgression.applyLeaveVacation(unitId, treasury)
    local LEAVE_COST = 5000
    local LEAVE_RECOVERY = 5
    local LEAVE_DURATION = 14  -- days

    if not unitId then
        return false, "Missing unitId"
    end

    -- Check funds
    if treasury and treasury:getBalance() < LEAVE_COST then
        return false, "Insufficient funds (need 5,000 credits)"
    end

    -- Deduct payment
    if treasury then
        treasury:deduct(LEAVE_COST, "Leave/vacation: " .. unitId)
    end

    -- Apply recovery (immediate for now, TODO: schedule over 2 weeks)
    local MoraleSystem = require("engine.battlescape.systems.morale_system")
    MoraleSystem.leaveVacation(unitId)

    -- TODO: Mark unit as unavailable for 2 weeks

    print(string.format("[UnitRecoveryProgression] Leave/vacation applied: %s (+5 sanity, -5,000 credits, 2 weeks unavailable)", unitId))
    return true
end

---
-- Get unit recovery/progression status
-- @param unitId string Unit identifier
-- @return table Current recovery and progression status
function UnitRecoveryProgression.getUnitStatus(unitId)
    -- TODO: Integrate with campaign unit data
    -- local unit = campaignManager:getUnit(unitId)

    local status = {
        unit_id = unitId,
        recovery_status = "active",
        wounds = 0,
        sanity_damage = 0,
        days_to_recover = 0,
        current_rank = "Soldier",
        total_xp = 0,
        kills = 0,
        missions_completed = 0,
        available_for_deployment = true
    }

    print(string.format("[UnitRecoveryProgression] Unit %s status: %s, available: %s",
        unitId, status.recovery_status, tostring(status.available_for_deployment)))

    return status
end

---
-- Calculate XP needed for next rank
-- @param currentRank string Current rank name
-- @return number XP threshold for next rank
function UnitRecoveryProgression.calculatePromotionThreshold(currentRank)
    local thresholds = {
        ["Rookie"] = 100,
        ["Soldier"] = 250,
        ["Sergeant"] = 500,
        ["Lieutenant"] = 1000,
        ["Captain"] = 2000,
        ["Major"] = 4000,
        ["Colonel"] = 99999  -- Max rank
    }

    return thresholds[currentRank] or 0
end

return UnitRecoveryProgression

