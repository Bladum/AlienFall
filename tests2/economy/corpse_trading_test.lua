---Corpse Trading Tests
---Tests for corpse creation, valuation, and trading

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local suite = HierarchicalSuite.new("CorpseTrading", "tests2/economy/corpse_trading_test.lua")

local CorpseTrading

suite:beforeAll(function()
    CorpseTrading = require("engine.economy.corpse_trading")
end)

-- Corpse Creation Tests
suite:testMethod("CorpseTrading.createCorpse", {
    description = "Creates corpse item from dead unit",
    testCase = "create_corpse",
    type = "functional"
}, function()
    local deadUnit = {
        id = "soldier_1",
        name = "John Doe",
        type = "human",
        faction = "player"
    }

    local corpse = CorpseTrading.createCorpse(deadUnit, "bullet")

    suite:assert(corpse ~= nil, "Corpse should be created")
    suite:assert(corpse.unit_id == "soldier_1", "Should track original unit ID")
    suite:assert(corpse.unit_name == "John Doe", "Should track unit name")
    suite:assert(corpse.type == "human_soldier", "Should be human_soldier type")
    suite:assert(corpse.is_human == true, "Should mark as human")
    suite:assert(corpse.condition == "normal", "Normal death should be normal condition")
end)

suite:testMethod("CorpseTrading.createCorpse", {
    description = "Marks corpse as damaged from explosions",
    testCase = "create_damaged_corpse",
    type = "functional"
}, function()
    local deadUnit = {id = "soldier_2", name = "Test", type = "human"}
    local corpse = CorpseTrading.createCorpse(deadUnit, "explosion")

    suite:assert(corpse.condition == "damaged", "Explosion should damage corpse")
end)

-- Corpse Value Tests
suite:testMethod("CorpseTrading.getCorpseValue", {
    description = "Calculates correct base values for corpse types",
    testCase = "corpse_base_values",
    type = "functional"
}, function()
    -- Human soldier: 5K
    local human = {type = "human_soldier", condition = "normal", death_date = os.time()}
    suite:assert(CorpseTrading.getCorpseValue(human) == 5000, "Human should be 5K")

    -- Alien common: 15K
    local alienCommon = {type = "alien_common", condition = "normal", death_date = os.time()}
    suite:assert(CorpseTrading.getCorpseValue(alienCommon) == 15000, "Alien common should be 15K")

    -- Alien rare: 50K
    local alienRare = {type = "alien_rare", condition = "normal", death_date = os.time()}
    suite:assert(CorpseTrading.getCorpseValue(alienRare) == 50000, "Alien rare should be 50K")

    -- VIP: 100K
    local vip = {type = "vip_hero", condition = "normal", death_date = os.time()}
    suite:assert(CorpseTrading.getCorpseValue(vip) == 100000, "VIP should be 100K")

    -- Mechanical: 8K
    local mechanical = {type = "mechanical", condition = "normal", death_date = os.time()}
    suite:assert(CorpseTrading.getCorpseValue(mechanical) == 8000, "Mechanical should be 8K")
end)

suite:testMethod("CorpseTrading.getCorpseValue", {
    description = "Applies fresh bonus (+50%) for recent deaths",
    testCase = "fresh_bonus",
    type = "functional"
}, function()
    local corpse = {
        type = "human_soldier",
        condition = "normal",
        death_date = os.time(),  -- Just died
        preserved = false
    }

    local value = CorpseTrading.getCorpseValue(corpse)
    -- 5000 * 1.5 = 7500
    suite:assert(value == 7500, "Fresh corpse should have +50% value")
end)

suite:testMethod("CorpseTrading.getCorpseValue", {
    description = "Applies preserved bonus (+100%) for cryogenic storage",
    testCase = "preserved_bonus",
    type = "functional"
}, function()
    local corpse = {
        type = "human_soldier",
        condition = "normal",
        death_date = os.time() - (30 * 86400),  -- 30 days ago
        preserved = true
    }

    local value = CorpseTrading.getCorpseValue(corpse)
    -- 5000 * 2.0 = 10000
    suite:assert(value == 10000, "Preserved corpse should have +100% value")
end)

suite:testMethod("CorpseTrading.getCorpseValue", {
    description = "Applies damaged penalty (-50%) for explosions",
    testCase = "damaged_penalty",
    type = "functional"
}, function()
    local corpse = {
        type = "human_soldier",
        condition = "damaged",
        death_date = os.time(),
        preserved = false
    }

    local value = CorpseTrading.getCorpseValue(corpse)
    -- 5000 * 0.5 = 2500
    suite:assert(value == 2500, "Damaged corpse should have -50% value")
end)

-- Alternative Uses Tests
suite:testMethod("CorpseTrading.getAlternativeUses", {
    description = "Provides ethical alternatives to selling",
    testCase = "alternative_uses",
    type = "functional"
}, function()
    local corpse = {type = "human_soldier", is_human = true}
    local alternatives = CorpseTrading.getAlternativeUses(corpse)

    suite:assert(#alternatives >= 3, "Should have at least 3 alternatives")

    local actions = {}
    for _, alt in ipairs(alternatives) do
        actions[alt.action] = true
        suite:assert(alt.karma == 0, "Alternatives should have 0 karma penalty")
    end

    suite:assert(actions.research, "Should include research option")
    suite:assert(actions.burial, "Should include burial option")
    suite:assert(actions.return_family, "Should include return to family for humans")
end)

suite:testMethod("CorpseTrading.getAlternativeUses", {
    description = "Alien corpses have ransom instead of return family",
    testCase = "alien_alternatives",
    type = "functional"
}, function()
    local corpse = {type = "alien_common", is_human = false}
    local alternatives = CorpseTrading.getAlternativeUses(corpse)

    local actions = {}
    for _, alt in ipairs(alternatives) do
        actions[alt.action] = true
    end

    suite:assert(actions.ransom, "Aliens should have ransom option")
    suite:assert(not actions.return_family, "Aliens should not have return family")
end)

-- Corpse Preservation Test
suite:testMethod("CorpseTrading.preserveCorpse", {
    description = "Marks corpse as preserved for +100% value",
    testCase = "preserve_corpse",
    type = "functional"
}, function()
    local corpse = {
        type = "alien_rare",
        condition = "normal",
        death_date = os.time() - (30 * 86400),
        preserved = false
    }

    -- Before preservation: old corpse has base value
    local beforeValue = CorpseTrading.getCorpseValue(corpse)
    suite:assert(beforeValue == 50000, "Old unpre served should be base value")

    -- Preserve
    CorpseTrading.preserveCorpse(corpse)

    -- After preservation: +100% value
    local afterValue = CorpseTrading.getCorpseValue(corpse)
    suite:assert(afterValue == 100000, "Preserved should be double value")
end)

-- Karma Penalty Tests
suite:testMethod("CorpseTrading.CONFIG.KARMA_PENALTIES", {
    description = "Correct karma penalties defined for each type",
    testCase = "karma_penalties",
    type = "functional"
}, function()
    local cfg = CorpseTrading.CONFIG.KARMA_PENALTIES

    suite:assert(cfg.human_soldier == -10, "Human should be -10 karma")
    suite:assert(cfg.alien_common == -15, "Alien common should be -15 karma")
    suite:assert(cfg.alien_rare == -25, "Alien rare should be -25 karma")
    suite:assert(cfg.vip_hero == -30, "VIP should be -30 karma")
    suite:assert(cfg.mechanical == -5, "Mechanical should be -5 karma")
end)

-- Discovery Risk Tests
suite:testMethod("CorpseTrading.CONFIG", {
    description = "Discovery risk configured correctly",
    testCase = "discovery_risk",
    type = "functional"
}, function()
    local cfg = CorpseTrading.CONFIG

    suite:assert(cfg.DISCOVERY_CHANCE == 0.05, "Base discovery should be 5%")
    suite:assert(cfg.DISCOVERY_CHANCE_HUMAN == 0.03, "Human bonus should be +3%")
end)

return suite

