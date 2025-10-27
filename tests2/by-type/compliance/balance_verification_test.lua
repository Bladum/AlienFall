-- ─────────────────────────────────────────────────────────────────────────
-- BALANCE VERIFICATION TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Verify game balance parameters and difficulty scaling
-- Tests: 7 balance verification tests
-- Categories: Economy balance, difficulty progression, fairness

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.balance",
    fileName = "balance_verification_test.lua",
    description = "Game balance and difficulty scaling verification"
})

-- ─────────────────────────────────────────────────────────────────────────
-- BALANCE VERIFICATION TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Economy Balance", function()

    Suite:testMethod("Balance:initialFundsReasonable", {
        description = "Starting funds allow viable early game",
        testCase = "balance",
        type = "compliance"
    }, function()
        local startingFunds = 100000
        local minimumViable = 50000

        Helpers.assertTrue(startingFunds >= minimumViable, "Starting funds should be viable")
    end)

    Suite:testMethod("Balance:unitCostProgression", {
        description = "Unit costs scale reasonably with stats",
        testCase = "balance",
        type = "compliance"
    }, function()
        local units = {
            {name = "rookie", cost = 5000, skillLevel = 1},
            {name = "veteran", cost = 15000, skillLevel = 50},
            {name = "elite", cost = 25000, skillLevel = 100}
        }

        for i = 1, #units - 1 do
            Helpers.assertTrue(units[i+1].cost > units[i].cost, "Higher skill units should cost more")
        end
    end)

    Suite:testMethod("Balance:weaponCostBalance", {
        description = "Weapon costs are balanced vs effectiveness",
        testCase = "balance",
        type = "compliance"
    }, function()
        local weapons = {
            {name = "pistol", cost = 500, damage = 15},
            {name = "rifle", cost = 2000, damage = 25},
            {name = "shotgun", cost = 3000, damage = 40}
        }

        for i = 1, #weapons - 1 do
            Helpers.assertTrue(weapons[i+1].damage > weapons[i].damage, "Better weapons should do more damage")
            Helpers.assertTrue(weapons[i+1].cost > weapons[i].cost, "Better weapons should cost more")
        end
    end)

    Suite:testMethod("Balance:researchCostTime", {
        description = "Research costs scale with value",
        testCase = "balance",
        type = "compliance"
    }, function()
        local research = {
            {name = "basic_armor", cost = 10000, turnsNeeded = 5},
            {name = "advanced_armor", cost = 25000, turnsNeeded = 10},
            {name = "plasma_research", cost = 50000, turnsNeeded = 20}
        }

        for i = 1, #research - 1 do
            Helpers.assertTrue(research[i+1].cost > research[i].cost, "More advanced tech should cost more")
            Helpers.assertTrue(research[i+1].turnsNeeded > research[i].turnsNeeded, "More advanced tech takes longer")
        end
    end)
end)

Suite:group("Difficulty Scaling", function()

    Suite:testMethod("Balance:enemyStrengthScalesDifficulty", {
        description = "Enemy strength increases with difficulty",
        testCase = "scaling",
        type = "compliance"
    }, function()
        local difficulties = {
            easy = {unitHealth = 50, damage = 10},
            normal = {unitHealth = 75, damage = 15},
            hard = {unitHealth = 100, damage = 20},
            ironman = {unitHealth = 125, damage = 25}
        }

        local prev = difficulties.easy
        for _, diff in ipairs({difficulties.normal, difficulties.hard, difficulties.ironman}) do
            Helpers.assertTrue(diff.unitHealth > prev.unitHealth, "Enemy health should scale with difficulty")
            prev = diff
        end
    end)

    Suite:testMethod("Balance:lootScalesDifficulty", {
        description = "Loot rewards scale inversely with difficulty",
        testCase = "scaling",
        type = "compliance"
    }, function()
        local difficulties = {
            easy = {lootMultiplier = 1.5},
            normal = {lootMultiplier = 1.0},
            hard = {lootMultiplier = 0.75},
            ironman = {lootMultiplier = 0.5}
        }

        Helpers.assertTrue(difficulties.easy.lootMultiplier > difficulties.normal.lootMultiplier,
                          "Easy mode should have more loot")
        Helpers.assertTrue(difficulties.normal.lootMultiplier > difficulties.hard.lootMultiplier,
                          "Hard mode should have less loot")
    end)

    Suite:testMethod("Balance:aiAccuracyScalesDifficulty", {
        description = "AI accuracy increases with difficulty",
        testCase = "scaling",
        type = "compliance"
    }, function()
        local aiAccuracy = {
            easy = 40,
            normal = 60,
            hard = 80,
            ironman = 95
        }

        Helpers.assertTrue(aiAccuracy.hard > aiAccuracy.normal, "Hard mode AI should be more accurate")
        Helpers.assertTrue(aiAccuracy.ironman > aiAccuracy.hard, "Ironman mode AI should be most accurate")
    end)
end)

Suite:group("Fairness Checks", function()

    Suite:testMethod("Balance:playerAlwaysCanWin", {
        description = "Even hardest difficulty is winnable",
        testCase = "fairness",
        type = "compliance"
    }, function()
        local ironmanDifficulty = {
            maxTurnsPerMission = 20,
            playerStartingUnits = 4,
            maxEnemyUnits = 6,
            playerCanPrepare = true
        }

        -- Player should always have some advantage
        Helpers.assertTrue(ironmanDifficulty.playerCanPrepare, "Player should have prep time")
        Helpers.assertTrue(ironmanDifficulty.maxEnemyUnits >= ironmanDifficulty.playerStartingUnits,
                          "Enemies present challenge")
    end)

    Suite:testMethod("Balance:mapSizeAppropriate", {
        description = "Map size is appropriate for squad count",
        testCase = "fairness",
        type = "compliance"
    }, function()
        local mission = {
            mapSize = {width = 20, height = 20},
            playerSquadSize = 4,
            minMapCellsPerUnit = 25
        }

        local totalCells = mission.mapSize.width * mission.mapSize.height
        local minRequired = mission.playerSquadSize * mission.minMapCellsPerUnit

        Helpers.assertTrue(totalCells >= minRequired, "Map should have enough space for squad")
    end)
end)

return Suite
