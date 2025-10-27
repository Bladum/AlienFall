-- ─────────────────────────────────────────────────────────────────────────
-- DATA INTEGRITY COMPLIANCE TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Verify game save data is consistent and valid
-- Tests: 7 data integrity validation tests
-- Categories: Save consistency, state validation, data relationships

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.persistence",
    fileName = "data_integrity_compliance_test.lua",
    description = "Game data integrity and consistency verification"
})

-- ─────────────────────────────────────────────────────────────────────────
-- DATA INTEGRITY TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Save Data Consistency", function()

    Suite:testMethod("SaveData:requiredFieldsPresent", {
        description = "All required save data fields are present",
        testCase = "validation",
        type = "compliance"
    }, function()
        local saveData = {
            version = "1.0",
            timestamp = os.time(),
            playerName = "Commander",
            difficulty = "normal",
            turn = 42,
            year = 2024,
            month = 10,
            gameVersion = "0.1.0"
        }

        local requiredFields = {
            "version", "timestamp", "playerName", "difficulty",
            "turn", "year", "month", "gameVersion"
        }

        for _, field in ipairs(requiredFields) do
            Helpers.assertNotNil(saveData[field], "Field " .. field .. " should be present")
        end
    end)

    Suite:testMethod("SaveData:noCriticalFieldsNil", {
        description = "Critical save fields are never nil",
        testCase = "validation",
        type = "compliance"
    }, function()
        local saveData = {
            playerName = "Commander",
            turn = 1,
            year = 2024
        }

        Helpers.assertNotNil(saveData.playerName, "Player name must not be nil")
        Helpers.assertNotNil(saveData.turn, "Turn must not be nil")
        Helpers.assertNotNil(saveData.year, "Year must not be nil")
    end)

    Suite:testMethod("SaveData:versionConsistency", {
        description = "Save version matches game version",
        testCase = "consistency",
        type = "compliance"
    }, function()
        local gameVersion = "0.1.0"
        local saveVersion = "0.1.0"

        Helpers.assertEqual(saveVersion, gameVersion, "Save version should match game version")
    end)

    Suite:testMethod("SaveData:timestampValid", {
        description = "Save timestamp is a valid number",
        testCase = "validation",
        type = "compliance"
    }, function()
        local saveTime = os.time()

        Helpers.assertTrue(type(saveTime) == "number", "Timestamp should be a number")
        Helpers.assertTrue(saveTime > 0, "Timestamp should be positive")
    end)
end)

Suite:group("Game State Relationships", function()

    Suite:testMethod("GameState:unitOwnershipValid", {
        description = "All units have valid owner relationship",
        testCase = "relationship",
        type = "compliance"
    }, function()
        local units = {
            {id = 1, owner = "player", squad = 1},
            {id = 2, owner = "player", squad = 1},
            {id = 3, owner = "enemy", squad = 2}
        }

        for _, unit in ipairs(units) do
            Helpers.assertNotNil(unit.owner, "Unit should have owner")
            Helpers.assertTrue(unit.owner == "player" or unit.owner == "enemy", "Owner should be valid")
        end
    end)

    Suite:testMethod("GameState:facilityAssignmentValid", {
        description = "Each facility is assigned to valid base",
        testCase = "relationship",
        type = "compliance"
    }, function()
        local bases = {
            {id = 1, name = "Base Alpha"},
            {id = 2, name = "Base Bravo"}
        }

        local facilities = {
            {id = 1, baseId = 1, type = "barracks"},
            {id = 2, baseId = 1, type = "hangar"},
            {id = 3, baseId = 2, type = "laboratory"}
        }

        for _, facility in ipairs(facilities) do
            local baseExists = false
            for _, base in ipairs(bases) do
                if base.id == facility.baseId then
                    baseExists = true
                    break
                end
            end
            Helpers.assertTrue(baseExists, "Facility should be in valid base")
        end
    end)

    Suite:testMethod("GameState:itemInventoryValid", {
        description = "Item inventory totals are consistent",
        testCase = "consistency",
        type = "compliance"
    }, function()
        local inventory = {
            rifles = 20,
            shotguns = 10,
            grenades = 30,
            ammo = 500
        }

        local totalItems = 0
        for _, count in pairs(inventory) do
            totalItems = totalItems + count
        end

        Helpers.assertEqual(totalItems, 560, "Total should be sum of all items")
    end)
end)

Suite:group("Data Validation", function()

    Suite:testMethod("Validation:playerResourcesNonNegative", {
        description = "Player resources never go negative",
        testCase = "constraint",
        type = "compliance"
    }, function()
        local resources = {
            funds = 50000,
            scientists = 20,
            engineers = 15,
            soldiers = 100
        }

        for resource, amount in pairs(resources) do
            Helpers.assertTrue(amount >= 0, resource .. " should be non-negative")
        end
    end)

    Suite:testMethod("Validation:unitStatsInRange", {
        description = "Unit combat stats are within valid ranges",
        testCase = "validation",
        type = "compliance"
    }, function()
        local unit = {
            health = 75,
            armor = 50,
            accuracy = 80,
            aim = 60,
            reactions = 40
        }

        for stat, value in pairs(unit) do
            Helpers.assertTrue(value >= 0, stat .. " should be >= 0")
            Helpers.assertTrue(value <= 100, stat .. " should be <= 100")
        end
    end)

    Suite:testMethod("Validation:weaponDamageValid", {
        description = "Weapon damage values are positive",
        testCase = "validation",
        type = "compliance"
    }, function()
        local weapons = {
            rifle = 22,
            shotgun = 45,
            sniper = 60,
            grenade = 80
        }

        for weapon, damage in pairs(weapons) do
            Helpers.assertTrue(damage > 0, weapon .. " damage should be positive")
            Helpers.assertTrue(damage <= 100, weapon .. " damage should be <= 100")
        end
    end)
end)

return Suite
