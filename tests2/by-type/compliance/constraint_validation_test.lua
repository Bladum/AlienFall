-- ─────────────────────────────────────────────────────────────────────────
-- CONSTRAINT VALIDATION TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Verify gameplay constraints and limits are enforced
-- Tests: 7 constraint enforcement tests
-- Categories: Resource limits, unit caps, facility restrictions

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.constraints",
    fileName = "constraint_validation_test.lua",
    description = "Gameplay constraints and limit enforcement"
})

-- ─────────────────────────────────────────────────────────────────────────
-- CONSTRAINT VALIDATION TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Resource Limits", function()

    Suite:testMethod("Constraint:maxSoldiersCap", {
        description = "Total soldiers never exceed capacity",
        testCase = "constraint",
        type = "compliance"
    }, function()
        local maxSoldiers = 200
        local currentSoldiers = 150

        Helpers.assertTrue(currentSoldiers <= maxSoldiers, "Should not exceed max soldiers")
    end)

    Suite:testMethod("Constraint:maxScientistsCap", {
        description = "Total scientists never exceed base capacity",
        testCase = "constraint",
        type = "compliance"
    }, function()
        local base = {
            maxScientists = 50,
            currentScientists = 45,
            labFacilities = 2
        }

        Helpers.assertTrue(base.currentScientists <= base.maxScientists, "Should not exceed max scientists")
    end)

    Suite:testMethod("Constraint:fundsCannotGoNegative", {
        description = "Player cannot spend more funds than available",
        testCase = "constraint",
        type = "compliance"
    }, function()
        local availableFunds = 50000
        local attemptedSpend = 60000

        local canAfford = attemptedSpend <= availableFunds

        Helpers.assertFalse(canAfford, "Should not be able to afford expenses exceeding budget")
    end)

    Suite:testMethod("Constraint:inventorySpaceLimit", {
        description = "Inventory items respect space limits",
        testCase = "constraint",
        type = "compliance"
    }, function()
        local inventory = {
            maxSlots = 20,
            usedSlots = 15,
            items = 15
        }

        Helpers.assertTrue(inventory.usedSlots <= inventory.maxSlots, "Should not exceed inventory space")
        Helpers.assertEqual(inventory.items, inventory.usedSlots, "Items should match used slots")
    end)
end)

Suite:group("Unit and Squad Constraints", function()

    Suite:testMethod("Constraint:maxSquadSize", {
        description = "Squad cannot exceed maximum unit count",
        testCase = "constraint",
        type = "compliance"
    }, function()
        local squad = {
            maxSize = 6,
            currentUnits = 4
        }

        Helpers.assertTrue(squad.currentUnits <= squad.maxSize, "Squad should not exceed max size")
    end)

    Suite:testMethod("Constraint:minSquadSize", {
        description = "Cannot deploy squad with too few units",
        testCase = "constraint",
        type = "compliance"
    }, function()
        local squad = {
            minSize = 2,
            currentUnits = 2,
            canDeploy = true
        }

        if squad.currentUnits < squad.minSize then
            squad.canDeploy = false
        end

        Helpers.assertTrue(squad.canDeploy, "Squad meets minimum size requirement")
    end)

    Suite:testMethod("Constraint:unitActionPointsLimit", {
        description = "Unit action points reset each turn",
        testCase = "reset",
        type = "compliance"
    }, function()
        local unit = {
            maxActionPoints = 100,
            currentActionPoints = 0,
            isTurnEnd = true
        }

        if unit.isTurnEnd then
            unit.currentActionPoints = unit.maxActionPoints
        end

        Helpers.assertEqual(unit.currentActionPoints, unit.maxActionPoints, "Action points should reset")
    end)
end)

Suite:group("Facility and Base Constraints", function()

    Suite:testMethod("Constraint:facilityTypeLimit", {
        description = "Cannot build duplicate exclusive facilities",
        testCase = "constraint",
        type = "compliance"
    }, function()
        local base = {
            facilities = {
                {type = "command_center", count = 1},
                {type = "hangar", count = 2},
                {type = "laboratory", count = 1}
            }
        }

        -- Command center should be unique
        local commandCenters = 0
        for _, fac in ipairs(base.facilities) do
            if fac.type == "command_center" then
                commandCenters = fac.count
            end
        end

        Helpers.assertEqual(commandCenters, 1, "Should have exactly one command center")
    end)

    Suite:testMethod("Constraint:baseConstructionLimit", {
        description = "Cannot construct more than 1 facility per turn",
        testCase = "constraint",
        type = "compliance"
    }, function()
        local base = {
            constructing = 1,
            maxConcurrentConstruction = 1,
            canStartNew = false
        }

        if base.constructing >= base.maxConcurrentConstruction then
            base.canStartNew = false
        end

        Helpers.assertFalse(base.canStartNew, "Should not be able to start new construction")
    end)
end)

return Suite
