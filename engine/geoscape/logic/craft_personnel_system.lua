---Craft Personnel System
---
---Manages personnel assignment to craft roles: pilot, gunner, engineer, interceptor.
---Each role has skill requirements and affects craft performance.
---
---Roles:
---  - PILOT: Navigation, evasion, fuel efficiency. Affects turning speed and fuel consumption.
---  - GUNNER: Targeting, accuracy, ROF. Affects accuracy and damage of craft weapons.
---  - ENGINEER: Repairs, armor, HP. Affects craft durability and self-healing capability.
---  - INTERCEPTOR: Combat pilot for dogfighting crafts (Interceptor only).
---
---Features:
---  - Multi-crew crafts support up to 3 personnel
---  - Skill requirements (min ranks, experience)
---  - Performance modifiers based on crew quality
---  - Fatigue system (effects on crew availability)
---
---@module geoscape.logic.craft_personnel_system
---@author AlienFall Development Team

local CraftPersonnel = {}
CraftPersonnel.__index = CraftPersonnel

---Personnel role definitions
CraftPersonnel.ROLES = {
    PILOT = {
        name = "Pilot",
        min_rank = 1,
        skills = {"navigation", "evasion"},
        performance_stats = {"speed", "fuel_efficiency"},
        max_per_craft = 1
    },
    GUNNER = {
        name = "Gunner",
        min_rank = 2,
        skills = {"targeting", "fire_control"},
        performance_stats = {"accuracy", "damage"},
        max_per_craft = 2
    },
    ENGINEER = {
        name = "Engineer",
        min_rank = 1,
        skills = {"repairs", "armor", "systems"},
        performance_stats = {"armor", "hp_regeneration"},
        max_per_craft = 1
    },
    INTERCEPTOR = {
        name = "Interceptor Pilot",
        min_rank = 3,
        skills = {"dogfighting", "evasion", "targeting"},
        performance_stats = {"acceleration", "maneuverability"},
        max_per_craft = 1,
        craft_types = {"interceptor"}  -- Only for specific craft types
    }
}

---Create personnel manager for craft
---@param craftId string Craft identifier
---@return table manager Personnel manager instance
function CraftPersonnel.new(craftId)
    local self = setmetatable({}, CraftPersonnel)
    self.craftId = craftId
    self.crew = {}  -- {PILOT={unitId, rank}, GUNNER=[...], ENGINEER={...}, INTERCEPTOR={...}}
    self.crew_performance = {}  -- Performance modifiers from crew quality
    self.fatigue_tracking = {}  -- unitId -> {fatigue, last_mission}
    return self
end

---Assign unit to craft role
---@param unitId string Unit identifier
---@param role string Role (PILOT, GUNNER, ENGINEER, INTERCEPTOR)
---@param unit_data table Unit data with rank and skills
---@return boolean success
---@return string|nil error Error message if failed
function CraftPersonnel:assignToCraft(unitId, role, unit_data)
    local role_def = self.ROLES[role]

    if not role_def then
        return false, string.format("Unknown role: %s", role)
    end

    if not unit_data then
        return false, "Unit data required"
    end

    -- Check rank requirement
    if (unit_data.rank or 0) < role_def.min_rank then
        return false, string.format("Insufficient rank (need %d, have %d)",
              role_def.min_rank, unit_data.rank or 0)
    end

    -- Check skill requirements
    for _, skill in ipairs(role_def.skills) do
        if not unit_data.skills or not unit_data.skills[skill] then
            return false, string.format("Missing required skill: %s", skill)
        end
    end

    -- Check fatigue
    local fatigue = self:getUnitFatigue(unitId)
    if fatigue >= 80 then
        return false, "Unit too fatigued for assignment"
    end

    -- Initialize crew if needed
    if not self.crew[role] then
        self.crew[role] = {}
    end

    -- Check capacity
    if role_def.max_per_craft and #self.crew[role] >= role_def.max_per_craft then
        return false, string.format("Already have maximum crew for %s", role)
    end

    -- Add to crew
    table.insert(self.crew[role], {
        unitId = unitId,
        rank = unit_data.rank,
        skills = unit_data.skills,
        assigned_at = os.time()
    })

    -- Recalculate performance
    self:recalculatePerformance()

    print(string.format("[CraftPersonnel] Assigned unit %s to %s on craft %s",
          unitId, role, self.craftId))

    return true, nil
end

---Remove unit from craft role
---@param unitId string Unit identifier
---@param role string Role to remove from
---@return boolean success
function CraftPersonnel:removeFromCraft(unitId, role)
    if not self.crew[role] then
        return false
    end

    for i, member in ipairs(self.crew[role]) do
        if member.unitId == unitId then
            table.remove(self.crew[role], i)
            self:recalculatePerformance()
            print(string.format("[CraftPersonnel] Removed unit %s from %s", unitId, role))
            return true
        end
    end

    return false
end

---Recalculate performance modifiers from crew quality
function CraftPersonnel:recalculatePerformance()
    self.crew_performance = {
        pilot_skill = 1.0,
        gunner_accuracy = 1.0,
        gunner_damage = 1.0,
        engineer_armor = 1.0,
        engineer_repair = 1.0,
        interceptor_speed = 1.0
    }

    -- Pilot performance
    if self.crew.PILOT and #self.crew.PILOT > 0 then
        local pilot = self.crew.PILOT[1]
        -- Skill modifier: 5% per rank above minimum
        self.crew_performance.pilot_skill = 1.0 + ((pilot.rank - 1) * 0.05)
    end

    -- Gunner performance (average of all gunners)
    if self.crew.GUNNER and #self.crew.GUNNER > 0 then
        local total_rank = 0
        for _, gunner in ipairs(self.crew.GUNNER) do
            total_rank = total_rank + gunner.rank
        end
        local avg_rank = total_rank / #self.crew.GUNNER

        -- Accuracy: +5% per rank, +10% bonus for multiple gunners
        self.crew_performance.gunner_accuracy = 1.0 + ((avg_rank - 2) * 0.05)
        if #self.crew.GUNNER > 1 then
            self.crew_performance.gunner_accuracy = self.crew_performance.gunner_accuracy + 0.10
        end

        -- Damage: +3% per rank
        self.crew_performance.gunner_damage = 1.0 + ((avg_rank - 2) * 0.03)
    end

    -- Engineer performance
    if self.crew.ENGINEER and #self.crew.ENGINEER > 0 then
        local engineer = self.crew.ENGINEER[1]

        -- Armor bonus: +5% per rank
        self.crew_performance.engineer_armor = 1.0 + ((engineer.rank - 1) * 0.05)

        -- Repair rate: +10% per rank (for regeneration)
        self.crew_performance.engineer_repair = 1.0 + ((engineer.rank - 1) * 0.10)
    end

    -- Interceptor performance (for dogfighting craft)
    if self.crew.INTERCEPTOR and #self.crew.INTERCEPTOR > 0 then
        local interceptor = self.crew.INTERCEPTOR[1]

        -- Speed bonus: +8% per rank
        self.crew_performance.interceptor_speed = 1.0 + ((interceptor.rank - 3) * 0.08)
    end

    print(string.format("[CraftPersonnel] Craft %s performance recalculated", self.craftId))
end

---Get performance modifier for stat
---@param stat_name string Stat name (pilot_skill, gunner_accuracy, etc.)
---@return number modifier Performance modifier (1.0 = no change)
function CraftPersonnel:getPerformanceModifier(stat_name)
    return self.crew_performance[stat_name] or 1.0
end

---Apply fatigue to unit after mission
---@param unitId string Unit identifier
---@param mission_duration number Duration in turns
---@param difficulty number Difficulty multiplier
function CraftPersonnel:applyMissionFatigue(unitId, mission_duration, difficulty)
    if not self.fatigue_tracking[unitId] then
        self.fatigue_tracking[unitId] = {fatigue = 0, last_mission = 0, missions_count = 0}
    end

    local fatigue_data = self.fatigue_tracking[unitId]

    -- Fatigue calculation: 5 base + 1 per turn + difficulty multiplier
    local fatigue_gained = 5 + (mission_duration * 1) + (difficulty * 10)

    fatigue_data.fatigue = math.min(100, fatigue_data.fatigue + fatigue_gained)
    fatigue_data.last_mission = os.time()
    fatigue_data.missions_count = fatigue_data.missions_count + 1

    print(string.format("[CraftPersonnel] Applied %.0f fatigue to unit %s (total: %.0f)",
          fatigue_gained, unitId, fatigue_data.fatigue))
end

---Get unit fatigue level (0-100)
---@param unitId string Unit identifier
---@return number fatigue Fatigue level
function CraftPersonnel:getUnitFatigue(unitId)
    if not self.fatigue_tracking[unitId] then
        return 0
    end
    return self.fatigue_tracking[unitId].fatigue
end

---Process weekly fatigue recovery
---@param recovery_rate number Recovery per week (default 15)
function CraftPersonnel:processWeeklyFatigueRecovery(recovery_rate)
    recovery_rate = recovery_rate or 15

    for unitId, fatigue_data in pairs(self.fatigue_tracking) do
        if fatigue_data.fatigue > 0 then
            fatigue_data.fatigue = math.max(0, fatigue_data.fatigue - recovery_rate)
        end
    end

    print("[CraftPersonnel] Weekly fatigue recovery processed")
end

---Check if unit can perform role (not fatigued, not wounded, not recovering)
---@param unitId string Unit identifier
---@param role string Role to check
---@param unit_status table Unit status with health, sanity, etc.
---@return boolean can_perform
---@return string|nil reason
function CraftPersonnel:canUnitPerformRole(unitId, role, unit_status)
    -- Check fatigue
    local fatigue = self:getUnitFatigue(unitId)
    if fatigue >= 80 then
        return false, "Unit too fatigued"
    end

    -- Check health
    if unit_status and unit_status.hp and unit_status.hp <= 0 then
        return false, "Unit incapacitated"
    end

    -- Check sanity
    if unit_status and unit_status.sanity and unit_status.sanity < 30 then
        return false, "Sanity too low"
    end

    -- Check wounds
    if unit_status and unit_status.wounds and #unit_status.wounds > 2 then
        return false, "Too many wounds"
    end

    return true, nil
end

---Get crew roster for craft
---@return table roster {PILOT={...}, GUNNER={...}, ENGINEER={...}, INTERCEPTOR={...}}
function CraftPersonnel:getCrewRoster()
    return self.crew
end

---Get crew summary
---@return string summary Multi-line crew information
function CraftPersonnel:getCrewSummary()
    local lines = {}

    table.insert(lines, string.format("=== CRAFT %s CREW ===", self.craftId))

    for role_name, members in pairs(self.crew) do
        if #members > 0 then
            table.insert(lines, string.format("%s: %d/X", role_name, #members))
            for _, member in ipairs(members) do
                table.insert(lines, string.format("  - %s (Rank %d, Fatigue %.0f)",
                      member.unitId, member.rank, self:getUnitFatigue(member.unitId)))
            end
        end
    end

    table.insert(lines, "")
    table.insert(lines, "Performance Modifiers:")
    for stat, modifier in pairs(self.crew_performance) do
        table.insert(lines, string.format("  %s: %.1f%%", stat, (modifier - 1) * 100))
    end

    return table.concat(lines, "\n")
end

---Get crew availability for roles
---@return table available {PILOT=available_count, GUNNER=available_count, ...}
function CraftPersonnel:getCrewAvailability()
    return {
        PILOT = 1 - (#self.crew.PILOT or 0),
        GUNNER = 2 - (#self.crew.GUNNER or 0),
        ENGINEER = 1 - (#self.crew.ENGINEER or 0),
        INTERCEPTOR = 1 - (#self.crew.INTERCEPTOR or 0)
    }
end

return CraftPersonnel

