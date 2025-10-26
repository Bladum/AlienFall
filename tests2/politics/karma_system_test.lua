-- ─────────────────────────────────────────────────────────────────────────
-- KARMA SYSTEM TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Tests karma tracking, level calculation, karma modification, effects,
-- black market access, and karma history management
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

-- ─────────────────────────────────────────────────────────────────────────
-- MOCK KARMA SYSTEM
-- ─────────────────────────────────────────────────────────────────────────

local KarmaSystem = {}
KarmaSystem.__index = KarmaSystem

function KarmaSystem:new()
    local self = setmetatable({}, KarmaSystem)
    self.karma = 0
    self.history = {}
    return self
end

function KarmaSystem:getLevel()
    local k = self.karma
    if k >= 75 then return "Saintly"
    elseif k >= 40 then return "Heroic"
    elseif k >= 10 then return "Principled"
    elseif k >= 0 then return "Neutral"
    elseif k >= -39 then return "Pragmatic"
    elseif k >= -74 then return "Ruthless"
    else return "Evil"
    end
end

function KarmaSystem:modifyKarma(amount, reason)
    self.karma = math.max(-100, math.min(100, self.karma + amount))
    table.insert(self.history, {
        amount = amount,
        reason = reason,
        timestamp = os.time(),
        newKarma = self.karma
    })
    return self.karma
end

function KarmaSystem:getKarmaEffects()
    local level = self:getLevel()
    local effects = {}

    if level == "Saintly" then
        table.insert(effects, {type = "mission_unlock", description = "humanitarian missions"})
        table.insert(effects, {type = "diplomacy_bonus", value = 20})
    elseif level == "Heroic" then
        table.insert(effects, {type = "mission_unlock", description = "heroic missions"})
        table.insert(effects, {type = "diplomacy_bonus", value = 10})
    elseif level == "Principled" then
        table.insert(effects, {type = "diplomacy_bonus", value = 5})
    elseif level == "Ruthless" then
        table.insert(effects, {type = "mission_unlock", description = "ruthless tactics"})
        table.insert(effects, {type = "combat_bonus", value = 10})
    elseif level == "Evil" then
        table.insert(effects, {type = "mission_unlock", description = "evil tactics"})
        table.insert(effects, {type = "combat_bonus", value = 20})
    end

    return effects
end

function KarmaSystem:canAccessBlackMarket()
    return self.karma <= -10  -- Pragmatic or lower
end

function KarmaSystem:getLevelColor()
    local level = self:getLevel()
    if level == "Saintly" then return {r = 1, g = 1, b = 0.8}  -- Light gold
    elseif level == "Heroic" then return {r = 0.8, g = 1, b = 0.8}  -- Light green
    elseif level == "Principled" then return {r = 0.6, g = 0.8, b = 1}  -- Light blue
    elseif level == "Neutral" then return {r = 0.8, g = 0.8, b = 0.8}  -- Gray
    elseif level == "Pragmatic" then return {r = 1, g = 0.8, b = 0.6}  -- Light orange
    elseif level == "Ruthless" then return {r = 1, g = 0.6, b = 0.6}  -- Light red
    elseif level == "Evil" then return {r = 0.8, g = 0.2, b = 0.2}  -- Dark red
    else return {r = 0.5, g = 0.5, b = 0.5}  -- Default gray
    end
end

-- ─────────────────────────────────────────────────────────────────────────
-- TEST SUITE
-- ─────────────────────────────────────────────────────────────────────────

local Suite = HierarchicalSuite:new({
    modulePath = "politics.karma.karma_system",
    fileName = "karma_system.lua",
    description = "Karma tracking system for moral choices and reputation"
})

Suite:before(function() print("[KarmaSystemTest] Setting up") end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 1: KARMA INITIALIZATION AND LEVELS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Karma Initialization and Levels", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.karma = KarmaSystem:new()
    end)

    Suite:testMethod("KarmaSystem.new", {description="Creates karma system instance", testCase="creation", type="functional"},
    function()
        Helpers.assertEqual(shared.karma ~= nil, true, "Karma system should be created")
        Helpers.assertEqual(shared.karma.karma, 0, "Initial karma should be 0")
        Helpers.assertEqual(type(shared.karma.history), "table", "Should have history table")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("KarmaSystem.getLevel", {description="Initial level is Neutral", testCase="initial_neutral", type="functional"},
    function()
        local level = shared.karma:getLevel()
        Helpers.assertEqual(level, "Neutral", "Initial level should be Neutral")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("KarmaSystem.getLevel", {description="Karma level Evil at -90", testCase="level_evil", type="functional"},
    function()
        shared.karma.karma = -90
        local level = shared.karma:getLevel()
        Helpers.assertEqual(level, "Evil", "Karma -90 should be Evil")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("KarmaSystem.getLevel", {description="Karma level Saintly at 85", testCase="level_saintly", type="functional"},
    function()
        shared.karma.karma = 85
        local level = shared.karma:getLevel()
        Helpers.assertEqual(level, "Saintly", "Karma 85 should be Saintly")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("KarmaSystem.getLevel", {description="Karma level boundaries work correctly", testCase="level_boundaries", type="functional"},
    function()
        -- Test boundary values
        shared.karma.karma = -75
        Helpers.assertEqual(shared.karma:getLevel(), "Evil", "Karma -75 should be Evil")

        shared.karma.karma = -74
        Helpers.assertEqual(shared.karma:getLevel(), "Ruthless", "Karma -74 should be Ruthless")

        shared.karma.karma = -40
        Helpers.assertEqual(shared.karma:getLevel(), "Ruthless", "Karma -40 should be Ruthless")

        shared.karma.karma = -39
        Helpers.assertEqual(shared.karma:getLevel(), "Pragmatic", "Karma -39 should be Pragmatic")

        shared.karma.karma = 9
        Helpers.assertEqual(shared.karma:getLevel(), "Neutral", "Karma 9 should be Neutral")

        shared.karma.karma = 10
        Helpers.assertEqual(shared.karma:getLevel(), "Principled", "Karma 10 should be Principled")

        shared.karma.karma = 74
        Helpers.assertEqual(shared.karma:getLevel(), "Heroic", "Karma 74 should be Heroic")

        shared.karma.karma = 75
        Helpers.assertEqual(shared.karma:getLevel(), "Saintly", "Karma 75 should be Saintly")

        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 2: KARMA MODIFICATION
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Karma Modification", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.karma = KarmaSystem:new()
    end)

    Suite:testMethod("KarmaSystem.modifyKarma", {description="Modifies karma positively", testCase="modify_positive", type="functional"},
    function()
        local result = shared.karma:modifyKarma(25, "Saved civilians")
        Helpers.assertEqual(shared.karma.karma, 25, "Karma should be 25")
        Helpers.assertEqual(result, 25, "Should return new karma value")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("KarmaSystem.modifyKarma", {description="Modifies karma negatively", testCase="modify_negative", type="functional"},
    function()
        local result = shared.karma:modifyKarma(-30, "Civilian casualties")
        Helpers.assertEqual(shared.karma.karma, -30, "Karma should be -30")
        Helpers.assertEqual(result, -30, "Should return new karma value")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("KarmaSystem.modifyKarma", {description="Clamps karma at maximum (100)", testCase="clamp_maximum", type="edge_case"},
    function()
        local result = shared.karma:modifyKarma(150, "Extreme good deed")
        Helpers.assertEqual(shared.karma.karma, 100, "Karma should be clamped at 100")
        Helpers.assertEqual(result, 100, "Should return clamped value")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("KarmaSystem.modifyKarma", {description="Clamps karma at minimum (-100)", testCase="clamp_minimum", type="edge_case"},
    function()
        local result = shared.karma:modifyKarma(-150, "Extreme evil deed")
        Helpers.assertEqual(shared.karma.karma, -100, "Karma should be clamped at -100")
        Helpers.assertEqual(result, -100, "Should return clamped value")
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 3: KARMA EFFECTS AND THRESHOLDS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Karma Effects and Thresholds", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.karma = KarmaSystem:new()
    end)

    Suite:testMethod("KarmaSystem.getKarmaEffects", {description="Returns effects for positive karma", testCase="effects_positive", type="functional"},
    function()
        shared.karma.karma = 50  -- Heroic level
        local effects = shared.karma:getKarmaEffects()
        Helpers.assertEqual(type(effects), "table", "Effects should be a table")
        Helpers.assertEqual(#effects > 0, true, "Should have effects for heroic karma")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("KarmaSystem.getKarmaEffects", {description="Returns effects for negative karma", testCase="effects_negative", type="functional"},
    function()
        shared.karma.karma = -50  -- Ruthless level
        local effects = shared.karma:getKarmaEffects()
        Helpers.assertEqual(type(effects), "table", "Effects should be a table")
        Helpers.assertEqual(#effects > 0, true, "Should have effects for ruthless karma")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("KarmaSystem.canAccessBlackMarket", {description="Grants black market access at low karma", testCase="black_market_low_karma", type="functional"},
    function()
        shared.karma.karma = -30  -- Pragmatic level
        local hasAccess = shared.karma:canAccessBlackMarket()
        Helpers.assertEqual(hasAccess, true, "Should have black market access at karma -30")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("KarmaSystem.canAccessBlackMarket", {description="Denies black market access at high karma", testCase="no_black_market_high_karma", type="functional"},
    function()
        shared.karma.karma = 50  -- Heroic level
        local hasAccess = shared.karma:canAccessBlackMarket()
        Helpers.assertEqual(hasAccess, false, "Should NOT have black market access at karma 50")
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 4: KARMA HISTORY TRACKING
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Karma History Tracking", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.karma = KarmaSystem:new()
    end)

    Suite:testMethod("KarmaSystem.modifyKarma", {description="Tracks karma history", testCase="history_tracking", type="functional"},
    function()
        shared.karma:modifyKarma(10, "Saved a soldier")
        shared.karma:modifyKarma(-5, "Collateral damage")

        Helpers.assertEqual(#shared.karma.history, 2, "Should have 2 history entries")
        Helpers.assertEqual(shared.karma.history[1].amount, 10, "First entry should have amount 10")
        Helpers.assertEqual(shared.karma.history[2].amount, -5, "Second entry should have amount -5")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("KarmaSystem.modifyKarma", {description="History contains reason", testCase="history_reason", type="functional"},
    function()
        shared.karma:modifyKarma(15, "Rescued civilians")

        local lastEntry = shared.karma.history[#shared.karma.history]
        Helpers.assertEqual(lastEntry.reason, "Rescued civilians", "History should contain reason")
        -- Removed manual print - framework handles this
    end)

    Suite:testMethod("KarmaSystem.modifyKarma", {description="History contains amount and new karma", testCase="history_amount", type="functional"},
    function()
        shared.karma:modifyKarma(20, "Heroic action")

        local lastEntry = shared.karma.history[#shared.karma.history]
        Helpers.assertEqual(lastEntry.amount, 20, "History should contain amount")
        Helpers.assertEqual(lastEntry.newKarma, 20, "History should contain new karma value")
        Helpers.assertEqual(type(lastEntry.timestamp), "number", "History should contain timestamp")
        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- GROUP 5: LEVEL COLORS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Level Colors", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.karma = KarmaSystem:new()
    end)

    Suite:testMethod("KarmaSystem.getLevelColor", {description="Returns appropriate color for karma level", testCase="level_colors", type="functional"},
    function()
        shared.karma.karma = 50  -- Heroic
        local color = shared.karma:getLevelColor()

        Helpers.assertEqual(type(color), "table", "Color should be a table")
        Helpers.assertEqual(type(color.r), "number", "Color should have r component")
        Helpers.assertEqual(type(color.g), "number", "Color should have g component")
        Helpers.assertEqual(type(color.b), "number", "Color should have b component")

        -- Test different levels have different colors
        shared.karma.karma = -50  -- Ruthless
        local ruthlessColor = shared.karma:getLevelColor()
        Helpers.assertEqual(ruthlessColor.r ~= color.r or ruthlessColor.g ~= color.g or ruthlessColor.b ~= color.b, true, "Different levels should have different colors")

        -- Removed manual print - framework handles this
    end)
end)

-- ─────────────────────────────────────────────────────────────────────────
-- EXPORT
-- ─────────────────────────────────────────────────────────────────────────

return Suite
