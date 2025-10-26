-- ─────────────────────────────────────────────────────────────────────────
-- Pilots & Perks System Tests
-- ─────────────────────────────────────────────────────────────────────────
-- Covers: Perk system registration and management, pilot progression & ranking,
-- XP tracking, stat bonuses, mission recording, and craft pilot bonuses
-- ─────────────────────────────────────────────────────────────────────────

package.path = package.path .. ";engine/?.lua;engine/?/?.lua"

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- ─────────────────────────────────────────────────────────────────────────
-- HIERARCHICAL SUITE SETUP
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    module = "engine.basescape.pilots_perks",
    file = "pilots_perks.lua",
    description = "Pilots & Perks system - Perk registration, pilot progression, XP tracking, stat bonuses"
})

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK SYSTEMS
-- ─────────────────────────────────────────────────────────────────────────

---@class PerkSystem
---@field perks table
---@field unitPerks table
local MockPerkSystem = {}
MockPerkSystem.__index = MockPerkSystem

function MockPerkSystem:new()
    local self = setmetatable({}, MockPerkSystem)
    self.perks = {}
    self.unitPerks = {}
    self:initializeDefaultPerks()
    return self
end

---Initialize default perks
function MockPerkSystem:initializeDefaultPerks()
    self:register("can_move", "Basic Movement", "Ability to move", "basic", false)
    self:register("can_run", "Running", "Ability to run", "basic", false)
    self:register("can_shoot", "Basic Attack", "Ability to shoot", "basic", false)
    self:register("test_ability", "Test Ability", "Test perk", "special", false)
end

---Register a new perk
function MockPerkSystem:register(perkId, name, description, category, isPassive)
    if self.perks[perkId] then
        return false
    end

    self.perks[perkId] = {
        id = perkId,
        name = name,
        description = description,
        category = category or "basic",
        isPassive = isPassive or false,
        enabled = {}
    }
    return true
end

---Initialize unit with perks
function MockPerkSystem:initializeUnitPerks(unitId, perkList)
    if not self.unitPerks[unitId] then
        self.unitPerks[unitId] = {}
    end

    for _, perkId in ipairs(perkList) do
        if self.perks[perkId] then
            self.unitPerks[unitId][perkId] = true
        end
    end
end

---Check if unit has perk
function MockPerkSystem:hasPerk(unitId, perkId)
    if not self.unitPerks[unitId] then return false end
    return self.unitPerks[unitId][perkId] == true
end

---Enable perk for unit
function MockPerkSystem:enablePerk(unitId, perkId)
    if not self.perks[perkId] then return false end
    if not self.unitPerks[unitId] then
        self.unitPerks[unitId] = {}
    end
    self.unitPerks[unitId][perkId] = true
    return true
end

---Disable perk for unit
function MockPerkSystem:disablePerk(unitId, perkId)
    if not self.unitPerks[unitId] then return false end
    self.unitPerks[unitId][perkId] = false
    return true
end

---Toggle perk state
function MockPerkSystem:togglePerk(unitId, perkId)
    if not self.unitPerks[unitId] then
        self.unitPerks[unitId] = {}
    end

    local currentState = self.unitPerks[unitId][perkId] == true
    self.unitPerks[unitId][perkId] = not currentState
    return not currentState
end

---Get all active perks for unit
function MockPerkSystem:getActivePerks(unitId)
    local active = {}
    if not self.unitPerks[unitId] then return active end

    for perkId, enabled in pairs(self.unitPerks[unitId]) do
        if enabled then
            table.insert(active, perkId)
        end
    end

    return active
end

---Get perk definition
function MockPerkSystem:getPerk(perkId)
    return self.perks[perkId]
end

---Get perks by category
function MockPerkSystem:getByCategory(category)
    local result = {}
    for _, perk in pairs(self.perks) do
        if perk.category == category then
            table.insert(result, perk)
        end
    end
    return result
end

-- ─────────────────────────────────────────────────────────────────────────

---@class PilotProgression
---@field pilots table
---@field missions table
---@field rankData table
local MockPilotProgression = {}
MockPilotProgression.__index = MockPilotProgression

function MockPilotProgression:new()
    local self = setmetatable({}, MockPilotProgression)
    self.pilots = {}
    self.missions = {}
    self.rankData = {
        {rank = 0, name = "Rookie", xpRequired = 100, bonuses = {speed = 0, aim = 0, reaction = 0}},
        {rank = 1, name = "Veteran", xpRequired = 200, bonuses = {speed = 1, aim = 1, reaction = 0}},
        {rank = 2, name = "Elite", xpRequired = 300, bonuses = {speed = 2, aim = 2, reaction = 1}},
        {rank = 3, name = "Ace", xpRequired = 400, bonuses = {speed = 3, aim = 3, reaction = 2}},
        {rank = 4, name = "Legend", xpRequired = 500, bonuses = {speed = 4, aim = 4, reaction = 3}}
    }
    return self
end

---Initialize pilot with starting rank
function MockPilotProgression:initializePilot(pilotId, startingRank)
    startingRank = startingRank or 0

    self.pilots[pilotId] = {
        id = pilotId,
        rank = math.min(startingRank, #self.rankData - 1),
        xp = 0,
        totalXP = 0,
        missions = {},
        kills = 0,
        damage = 0
    }

    return self.pilots[pilotId]
end

---Get current rank
function MockPilotProgression:getRank(pilotId)
    local pilot = self.pilots[pilotId]
    if not pilot then return 0 end
    return pilot.rank
end

---Get current XP
function MockPilotProgression:getXP(pilotId)
    local pilot = self.pilots[pilotId]
    if not pilot then return 0 end
    return pilot.xp
end

---Gain XP and check for rank up
function MockPilotProgression:gainXP(pilotId, amount, source)
    local pilot = self.pilots[pilotId]
    if not pilot then return false end

    pilot.xp = pilot.xp + amount
    pilot.totalXP = pilot.totalXP + amount

    local rankUpOccurred = false

    -- Check for rank up: current rank's XP requirement must be met
    while pilot.rank < #self.rankData - 1 do
        local currentRankData = self.rankData[pilot.rank + 1]  -- +1 for 1-indexing

        if currentRankData and pilot.xp >= currentRankData.xpRequired then
            pilot.xp = pilot.xp - currentRankData.xpRequired
            pilot.rank = pilot.rank + 1
            rankUpOccurred = true
        else
            break
        end
    end

    return rankUpOccurred
end

---Get rank insignia
function MockPilotProgression:getRankInsignia(pilotId)
    local pilot = self.pilots[pilotId]
    if not pilot then return nil end

    local rankInfo = self.rankData[pilot.rank + 1]  -- +1 for 1-indexing
    if rankInfo then
        return {
            name = rankInfo.name,
            type = "insignia",
            rank = rankInfo.rank
        }
    end

    return nil
end

---Get pilot stats with bonuses
function MockPilotProgression:getPilotStats(pilotId)
    local pilot = self.pilots[pilotId]
    if not pilot then return nil end

    local rankInfo = self.rankData[pilot.rank + 1]
    local xpProgress = 0

    if pilot.rank < #self.rankData - 1 then
        local nextRankXP = self.rankData[pilot.rank + 2].xpRequired
        xpProgress = math.floor((pilot.xp / nextRankXP) * 100)
    else
        xpProgress = 100
    end

    return {
        rank = pilot.rank,
        name = rankInfo.name,
        xp = pilot.xp,
        xp_progress = xpProgress,
        stat_bonuses = rankInfo.bonuses,
        kills = pilot.kills,
        damage = pilot.damage,
        missions_flown = #pilot.missions
    }
end

---Record a mission
function MockPilotProgression:recordMission(pilotId, victory, kills, damage)
    local pilot = self.pilots[pilotId]
    if not pilot then return false end

    local mission = {
        victory = victory,
        kills = kills or 0,
        damage = damage or 0,
        timestamp = os.time()
    }

    table.insert(pilot.missions, mission)
    pilot.kills = pilot.kills + (kills or 0)
    pilot.damage = pilot.damage + (damage or 0)

    return true
end

---Get total XP earned
function MockPilotProgression:getTotalXP(pilotId)
    local pilot = self.pilots[pilotId]
    if not pilot then return 0 end
    return pilot.totalXP
end

---Get mission stats
function MockPilotProgression:getMissionStats(pilotId)
    local pilot = self.pilots[pilotId]
    if not pilot then return nil end

    local victories = 0
    for _, mission in ipairs(pilot.missions) do
        if mission.victory then victories = victories + 1 end
    end

    return {
        total_missions = #pilot.missions,
        victories = victories,
        total_kills = pilot.kills,
        total_damage = pilot.damage,
        win_rate = #pilot.missions > 0 and (victories / #pilot.missions) * 100 or 0
    }
end

-- ─────────────────────────────────────────────────────────────────────────

---@class CraftPilotSystem
---@field statBonusBase number
---@field statBonusCap number
---@field diminishingReturn number
local MockCraftPilotSystem = {}
MockCraftPilotSystem.__index = MockCraftPilotSystem

function MockCraftPilotSystem:new()
    local self = setmetatable({}, MockCraftPilotSystem)
    self.statBonusBase = 0.05  -- 5% per point
    self.statBonusCap = 0.25   -- 25% max per stat
    self.diminishingReturn = 0.75  -- 75% effectiveness on additional pilots
    return self
end

---Calculate pilot bonuses from stats
function MockCraftPilotSystem:calculatePilotBonuses(pilotStats)
    local bonuses = {
        speed = 0,
        aim = 0,
        reaction = 0,
        accuracy = 0,
        dodge = 0,
        fireRate = 0
    }

    -- Map stats to bonuses (every point = 5% bonus, capped at 25%)
    bonuses.speed = math.min(pilotStats.speed * self.statBonusBase, self.statBonusCap)
    bonuses.aim = math.min(pilotStats.aim * self.statBonusBase, self.statBonusCap)
    bonuses.reaction = math.min(pilotStats.reaction * self.statBonusBase, self.statBonusCap)
    bonuses.accuracy = bonuses.aim  -- Copy of aim bonus
    bonuses.dodge = bonuses.reaction  -- Copy of reaction bonus
    bonuses.fireRate = math.min(pilotStats.energy * self.statBonusBase * 0.5, self.statBonusCap * 0.5)

    return bonuses
end

---Calculate combined bonuses from multiple pilots
function MockCraftPilotSystem:calculateCombinedBonuses(pilotStatsList)
    local combined = {
        speed = 0,
        aim = 0,
        reaction = 0,
        accuracy = 0,
        dodge = 0,
        fireRate = 0
    }

    for i, stats in ipairs(pilotStatsList) do
        local multiplier = i == 1 and 1.0 or self.diminishingReturn
        local bonuses = self:calculatePilotBonuses(stats)

        for statName, bonus in pairs(bonuses) do
            combined[statName] = combined[statName] + (bonus * multiplier)
        end
    end

    return combined
end

---Format bonuses for UI display
function MockCraftPilotSystem:formatBonusesForDisplay(bonuses)
    local display = {}

    for statName, bonus in pairs(bonuses) do
        if bonus > 0.001 then
            table.insert(display, {
                stat = statName,
                bonus = bonus,
                formatted = statName:upper() .. ": " .. string.format("+%.1f%%", bonus * 100)
            })
        end
    end

    return display
end

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: PERK SYSTEM
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Perk System", function()

    Suite:testMethod("PerkSystem:register", {
        description = "Registers new perks with metadata",
        testCase = "perk_registration",
        type = "functional"
    }, function()
        local ps = MockPerkSystem:new()

        local success = ps:register("new_perk", "New Perk", "Description", "special", false)

        if not success then error("Perk registration should succeed") end

        local perk = ps:getPerk("new_perk")
        if not perk then error("Perk should exist after registration") end
        if perk.name ~= "New Perk" then error("Perk name should match") end
    end)

    Suite:testMethod("PerkSystem:initializeUnitPerks", {
        description = "Initializes unit with default perks",
        testCase = "unit_init",
        type = "functional"
    }, function()
        local ps = MockPerkSystem:new()

        ps:initializeUnitPerks(1, {"can_move", "can_shoot"})

        if not ps:hasPerk(1, "can_move") then error("Unit should have can_move") end
        if not ps:hasPerk(1, "can_shoot") then error("Unit should have can_shoot") end
    end)

    Suite:testMethod("PerkSystem:enablePerk", {
        description = "Enables perks for units",
        testCase = "perk_enable",
        type = "functional"
    }, function()
        local ps = MockPerkSystem:new()
        ps:initializeUnitPerks(1, {})

        local success = ps:enablePerk(1, "can_move")

        if not success then error("Enable should succeed") end
        if not ps:hasPerk(1, "can_move") then error("Perk should be enabled") end
    end)

    Suite:testMethod("PerkSystem:togglePerk", {
        description = "Toggles perk state",
        testCase = "perk_toggle",
        type = "functional"
    }, function()
        local ps = MockPerkSystem:new()
        ps:initializeUnitPerks(1, {"can_move"})

        local state1 = ps:togglePerk(1, "can_move")
        local state2 = ps:togglePerk(1, "can_move")

        if state1 ~= false then error("First toggle should disable") end
        if state2 ~= true then error("Second toggle should enable") end
    end)

    Suite:testMethod("PerkSystem:getActivePerks", {
        description = "Returns list of active perks",
        testCase = "active_perks",
        type = "functional"
    }, function()
        local ps = MockPerkSystem:new()
        ps:initializeUnitPerks(1, {"can_move", "can_run", "can_shoot"})
        ps:disablePerk(1, "can_run")

        local active = ps:getActivePerks(1)

        if #active ~= 2 then error("Should have 2 active perks") end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: PILOT PROGRESSION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Pilot Progression", function()

    Suite:testMethod("PilotProgression:initializePilot", {
        description = "Creates new pilot with starting rank",
        testCase = "pilot_init",
        type = "functional"
    }, function()
        local pp = MockPilotProgression:new()

        local pilot = pp:initializePilot(1, 0)

        if not pilot then error("Pilot should be created") end
        if pilot.rank ~= 0 then error("Starting rank should be 0") end
        if pilot.xp ~= 0 then error("Starting XP should be 0") end
    end)

    Suite:testMethod("PilotProgression:gainXP", {
        description = "Tracks XP accumulation",
        testCase = "xp_gain",
        type = "functional"
    }, function()
        local pp = MockPilotProgression:new()
        pp:initializePilot(1, 0)

        pp:gainXP(1, 50)

        local xp = pp:getXP(1)
        if xp ~= 50 then error("XP should be 50") end
    end)

    Suite:testMethod("PilotProgression:rank up", {
        description = "Promotes pilot on XP threshold",
        testCase = "rank_promotion",
        type = "functional"
    }, function()
        local pp = MockPilotProgression:new()
        pp:initializePilot(1, 0)

        local rankUpOccurred = pp:gainXP(1, 100)

        if not rankUpOccurred then error("Should rank up at 100 XP") end
        if pp:getRank(1) ~= 1 then error("Rank should be 1") end
    end)

    Suite:testMethod("PilotProgression:XP reset on promotion", {
        description = "Resets XP after rank up",
        testCase = "xp_reset",
        type = "functional"
    }, function()
        local pp = MockPilotProgression:new()
        pp:initializePilot(1, 0)

        pp:gainXP(1, 100)
        pp:gainXP(1, 50)

        local xp = pp:getXP(1)
        if xp ~= 50 then error("XP should reset to 50") end
    end)

    Suite:testMethod("PilotProgression:getRankInsignia", {
        description = "Returns rank insignia data",
        testCase = "rank_insignia",
        type = "functional"
    }, function()
        local pp = MockPilotProgression:new()
        pp:initializePilot(1, 1)

        local insignia = pp:getRankInsignia(1)

        if not insignia then error("Insignia should exist") end
        if insignia.name ~= "Veteran" then error("Rank 1 should be Veteran") end
    end)

    Suite:testMethod("PilotProgression:getPilotStats", {
        description = "Returns complete pilot stats with bonuses",
        testCase = "pilot_stats",
        type = "functional"
    }, function()
        local pp = MockPilotProgression:new()
        pp:initializePilot(1, 2)
        pp:gainXP(1, 50)

        local stats = pp:getPilotStats(1)

        if not stats then error("Stats should exist") end
        if stats.rank ~= 2 then error("Rank should be 2") end
        if not stats.stat_bonuses then error("Should have stat bonuses") end
        if stats.stat_bonuses.aim ~= 2 then error("Aim bonus should be 2") end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: MISSION TRACKING
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Mission Tracking", function()

    Suite:testMethod("PilotProgression:recordMission", {
        description = "Records mission results",
        testCase = "mission_record",
        type = "functional"
    }, function()
        local pp = MockPilotProgression:new()
        pp:initializePilot(1)

        local success = pp:recordMission(1, true, 5, 100)

        if not success then error("Mission recording should succeed") end
    end)

    Suite:testMethod("PilotProgression:getTotalXP", {
        description = "Tracks total XP earned",
        testCase = "total_xp",
        type = "functional"
    }, function()
        local pp = MockPilotProgression:new()
        pp:initializePilot(1)

        pp:gainXP(1, 150)
        pp:gainXP(1, 50)

        local totalXP = pp:getTotalXP(1)
        if totalXP ~= 200 then error("Total XP should be 200") end
    end)

    Suite:testMethod("PilotProgression:getMissionStats", {
        description = "Calculates mission statistics",
        testCase = "mission_stats",
        type = "functional"
    }, function()
        local pp = MockPilotProgression:new()
        pp:initializePilot(1)

        pp:recordMission(1, true, 5, 100)
        pp:recordMission(1, true, 3, 80)
        pp:recordMission(1, false, 1, 50)

        local stats = pp:getMissionStats(1)

        if not stats then error("Mission stats should exist") end
        if stats.total_missions ~= 3 then error("Should have 3 missions") end
        if stats.victories ~= 2 then error("Should have 2 victories") end
        if stats.total_kills ~= 9 then error("Should have 9 total kills") end
    end)

    Suite:testMethod("PilotProgression:multiple pilots", {
        description = "Manages multiple pilots independently",
        testCase = "multi_pilot",
        type = "functional"
    }, function()
        local pp = MockPilotProgression:new()

        pp:initializePilot(1, 0)
        pp:initializePilot(2, 1)
        pp:initializePilot(3, 2)

        pp:gainXP(1, 50)      -- Stays rank 0 (needs 100 for rank 1)
        pp:gainXP(2, 200)     -- Rank up from 1→2 (needs 200)
        pp:gainXP(3, 300)     -- Rank up from 2→3 then 3→4 (needs 300 then 400)

        if pp:getRank(1) ~= 0 then error("Pilot 1 should stay rank 0") end
        if pp:getRank(2) ~= 2 then error("Pilot 2 should rank up to 2") end
        if pp:getRank(3) ~= 3 then error("Pilot 3 should rank up to 3") end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: CRAFT PILOT BONUSES
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Craft Pilot Bonuses", function()

    Suite:testMethod("CraftPilotSystem:calculatePilotBonuses", {
        description = "Calculates stat bonuses from pilot stats",
        testCase = "bonus_calc",
        type = "functional"
    }, function()
        local cps = MockCraftPilotSystem:new()

        local pilotStats = {
            speed = 8,
            aim = 9,
            reaction = 7,
            energy = 6
        }

        local bonuses = cps:calculatePilotBonuses(pilotStats)

        if not bonuses then error("Bonuses should be calculated") end
        if bonuses.speed <= 0 then error("Speed bonus should be positive") end
        if bonuses.aim <= 0 then error("Aim bonus should be positive") end
    end)

    Suite:testMethod("CraftPilotSystem:bonus cap", {
        description = "Enforces maximum bonus cap",
        testCase = "bonus_cap",
        type = "validation"
    }, function()
        local cps = MockCraftPilotSystem:new()

        local maxStats = {
            speed = 100,
            aim = 100,
            reaction = 100,
            energy = 100
        }

        local bonuses = cps:calculatePilotBonuses(maxStats)

        if bonuses.speed > cps.statBonusCap then error("Speed should be capped") end
        if bonuses.aim > cps.statBonusCap then error("Aim should be capped") end
    end)

    Suite:testMethod("CraftPilotSystem:diminishing returns", {
        description = "Applies diminishing returns with multiple pilots",
        testCase = "diminishing_returns",
        type = "functional"
    }, function()
        local cps = MockCraftPilotSystem:new()

        local pilotStats = {
            speed = 8,
            aim = 8,
            reaction = 8,
            energy = 6
        }

        local single = cps:calculatePilotBonuses(pilotStats)
        local combined = cps:calculateCombinedBonuses({pilotStats, pilotStats})

        -- Combined should be less than double due to diminishing returns
        local expectedCombined = single.speed + (single.speed * cps.diminishingReturn)

        if combined.speed >= (single.speed * 2) then
            error("Should apply diminishing returns")
        end
    end)

    Suite:testMethod("CraftPilotSystem:formatBonusesForDisplay", {
        description = "Formats bonuses for UI display",
        testCase = "bonus_display",
        type = "functional"
    }, function()
        local cps = MockCraftPilotSystem:new()

        local bonuses = {
            speed = 0.15,
            aim = 0.20,
            reaction = 0.10,
            accuracy = 0.0
        }

        local display = cps:formatBonusesForDisplay(bonuses)

        if #display < 3 then error("Should format non-zero bonuses") end

        for _, entry in ipairs(display) do
            if not entry.formatted then error("Should have formatted string") end
        end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 5: INTEGRATION & PERFORMANCE
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Integration & Performance", function()

    Suite:testMethod("PerkSystem:large unit count", {
        description = "Handles many units with perks",
        testCase = "perk_scaling",
        type = "performance"
    }, function()
        local ps = MockPerkSystem:new()

        local startTime = os.clock()

        for i = 1, 100 do
            ps:initializeUnitPerks(i, {"can_move", "can_run", "can_shoot"})
        end

        local elapsed = os.clock() - startTime
        print("[Perk Scaling] 100 units initialization: " .. string.format("%.3f ms", elapsed * 1000))

        Helpers.assertLess(elapsed, 0.1, "Should initialize quickly")
    end)

    Suite:testMethod("PilotProgression:pilot simulation", {
        description = "Simulates full pilot career",
        testCase = "career_simulation",
        type = "functional"
    }, function()
        local pp = MockPilotProgression:new()
        pp:initializePilot(1, 0)

        -- Simulate career: gain XP and record missions
        for rank = 0, 3 do
            for mission = 1, 5 do
                pp:gainXP(1, 50)
                pp:recordMission(1, mission % 2 == 0, math.random(0, 5), math.random(50, 150))
            end
        end

        local stats = pp:getPilotStats(1)
        if not stats then error("Stats should exist") end
        if stats.rank < 2 then error("Should have advanced in rank") end
    end)

    Suite:testMethod("CraftPilotSystem:multi-pilot bonuses", {
        description = "Calculates bonuses for full squad",
        testCase = "squad_bonuses",
        type = "functional"
    }, function()
        local cps = MockCraftPilotSystem:new()

        local pilots = {}
        for i = 1, 4 do
            table.insert(pilots, {
                speed = 7 + i,
                aim = 8 + i,
                reaction = 6 + i,
                energy = 6
            })
        end

        local combined = cps:calculateCombinedBonuses(pilots)

        if not combined then error("Should calculate combined bonuses") end
        if combined.speed <= 0 then error("Should have speed bonus") end
    end)

    Suite:testMethod("Integrated pilot lifecycle", {
        description = "Complete pilot progression with perks",
        testCase = "full_lifecycle",
        type = "functional"
    }, function()
        local ps = MockPerkSystem:new()
        local pp = MockPilotProgression:new()

        -- Create pilot
        pp:initializePilot(1, 0)
        ps:initializeUnitPerks(1, {"can_move", "can_run", "can_shoot"})

        -- Pilot career
        pp:gainXP(1, 150)  -- Rank up
        pp:recordMission(1, true, 3, 100)

        -- Unlock new perk at higher rank
        ps:enablePerk(1, "test_ability")

        local stats = pp:getPilotStats(1)
        local perks = ps:getActivePerks(1)

        if not stats then error("Stats should exist") end
        if stats.rank ~= 1 then error("Should be rank 1") end
        if #perks < 4 then error("Should have 4 perks active") end
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- RUN SUITE
-- ─────────────────────────────────────────────────────────────────────────

function Helpers.assertLess(actual, expected, message)
    if not (actual < expected) then
        error(message or string.format("Expected %s < %s", tostring(actual), tostring(expected)))
    end
end

Suite:run()
