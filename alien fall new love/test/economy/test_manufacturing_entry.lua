--- Test suite for ManufacturingEntry class
-- @module test.economy.test_manufacturing_entry

local test_framework = require("test.framework.test_framework")
local ManufacturingEntry = require("src.economy.ManufacturingEntry")

local TestManufacturingEntry = {}

function TestManufacturingEntry.test_creation()
    local manufacturing_data = {
        id = "laser_rifle",
        name = "Laser Rifle",
        category = "weapons",
        description = "Advanced energy weapon",
        baseCost = 500,
        baseTime = 3,
        requiredMaterials = {
            { materialId = "laser_components", quantity = 2 },
            { materialId = "energy_cells", quantity = 1 }
        },
        requiredFacilities = { "workshop" },
        producedQuantity = 1,
        skillRequirements = {
            { skill = "engineering", level = 2 }
        }
    }

    local entry = ManufacturingEntry(manufacturing_data)

    test_framework.assert_equal(entry.id, "laser_rifle", "Entry ID should match")
    test_framework.assert_equal(entry.name, "Laser Rifle", "Entry name should match")
    test_framework.assert_equal(entry.category, "weapons", "Category should match")
    test_framework.assert_equal(entry.baseCost, 500, "Base cost should match")
    test_framework.assert_equal(entry.baseTime, 3, "Base time should match")
    test_framework.assert_equal(#entry.requiredMaterials, 2, "Should have 2 required materials")
    test_framework.assert_equal(#entry.requiredFacilities, 1, "Should have 1 required facility")
end

function TestManufacturingEntry.test_material_requirements_check()
    local manufacturing_data = {
        id = "test_item",
        name = "Test Item",
        requiredMaterials = {
            { materialId = "material_a", quantity = 2 },
            { materialId = "material_b", quantity = 1 }
        }
    }

    local entry = ManufacturingEntry(manufacturing_data)

    -- Test with insufficient materials
    local availableMaterials = {
        material_a = 1,
        material_b = 0
    }
    local canManufacture = entry:canManufacture(availableMaterials, {}, {})
    test_framework.assert_false(canManufacture, "Should not be able to manufacture with insufficient materials")

    -- Test with sufficient materials
    availableMaterials = {
        material_a = 3,
        material_b = 2
    }
    canManufacture = entry:canManufacture(availableMaterials, {}, {})
    test_framework.assert_true(canManufacture, "Should be able to manufacture with sufficient materials")
end

function TestManufacturingEntry.test_facility_requirements_check()
    local manufacturing_data = {
        id = "test_item",
        name = "Test Item",
        requiredFacilities = { "workshop", "laboratory" }
    }

    local entry = ManufacturingEntry(manufacturing_data)

    -- Test with missing facilities
    local availableFacilities = { workshop = true }
    local canManufacture = entry:canManufacture({}, availableFacilities, {})
    test_framework.assert_false(canManufacture, "Should not be able to manufacture without required facilities")

    -- Test with all facilities
    availableFacilities = { workshop = true, laboratory = true }
    canManufacture = entry:canManufacture({}, availableFacilities, {})
    test_framework.assert_true(canManufacture, "Should be able to manufacture with all required facilities")
end

function TestManufacturingEntry.test_skill_requirements_check()
    local manufacturing_data = {
        id = "test_item",
        name = "Test Item",
        skillRequirements = {
            { skill = "engineering", level = 3 },
            { skill = "physics", level = 2 }
        }
    }

    local entry = ManufacturingEntry(manufacturing_data)

    -- Test with insufficient skills
    local availableSkills = {
        engineering = 2,
        physics = 1
    }
    local canManufacture = entry:canManufacture({}, {}, availableSkills)
    test_framework.assert_false(canManufacture, "Should not be able to manufacture with insufficient skills")

    -- Test with sufficient skills
    availableSkills = {
        engineering = 4,
        physics = 3
    }
    canManufacture = entry:canManufacture({}, {}, availableSkills)
    test_framework.assert_true(canManufacture, "Should be able to manufacture with sufficient skills")
end

function TestManufacturingEntry.test_cost_calculation()
    local manufacturing_data = {
        id = "test_item",
        name = "Test Item",
        baseCost = 100,
        requiredMaterials = {
            { materialId = "material_a", quantity = 2, cost = 10 },
            { materialId = "material_b", quantity = 1, cost = 20 }
        }
    }

    local entry = ManufacturingEntry(manufacturing_data)

    -- Test base cost calculation
    local totalCost = entry:calculateTotalCost({}, {})
    -- Base cost 100 + material costs (2*10 + 1*20) = 140
    test_framework.assert_equal(totalCost, 140, "Total cost should include base and material costs")

    -- Test with modifiers
    local modifiers = {
        globalMultiplier = 1.2,
        categoryMultipliers = { weapons = 0.9 }
    }
    totalCost = entry:calculateTotalCost(modifiers, {})
    -- 140 * 1.2 * 0.9 = 151.2
    test_framework.assert_equal(totalCost, 151, "Modified cost should be correct")
end

function TestManufacturingEntry.test_time_calculation()
    local manufacturing_data = {
        id = "test_item",
        name = "Test Item",
        baseTime = 5,
        complexity = 2
    }

    local entry = ManufacturingEntry(manufacturing_data)

    -- Test base time calculation
    local time = entry:calculateProductionTime(1, {})  -- 1 workshop
    -- Base time 5 * complexity 2 / workshops 1 = 10 days
    test_framework.assert_equal(time, 10, "Production time should be correct")

    -- Test with modifiers
    local modifiers = { timeMultiplier = 0.8 }
    time = entry:calculateProductionTime(2, modifiers)  -- 2 workshops
    -- (5 * 2 * 0.8) / 2 = 8 / 2 = 4 days
    test_framework.assert_equal(time, 4, "Modified production time should be correct")
end

function TestManufacturingEntry.test_batch_production()
    local manufacturing_data = {
        id = "test_item",
        name = "Test Item",
        baseCost = 100,
        baseTime = 5,
        producedQuantity = 1
    }

    local entry = ManufacturingEntry(manufacturing_data)

    -- Test batch cost calculation
    local batchCost = entry:calculateBatchCost(3, {}, {})
    -- 100 * 3 = 300
    test_framework.assert_equal(batchCost, 300, "Batch cost should be correct")

    -- Test batch time calculation
    local batchTime = entry:calculateBatchTime(3, 1, {})
    -- 5 * 3 / 1 = 15 days
    test_framework.assert_equal(batchTime, 15, "Batch time should be correct")
end

function TestManufacturingEntry.test_efficiency_bonuses()
    local manufacturing_data = {
        id = "test_item",
        name = "Test Item",
        baseCost = 100,
        baseTime = 5
    }

    local entry = ManufacturingEntry(manufacturing_data)

    -- Test with efficiency bonuses
    local bonuses = {
        costReduction = 0.2,  -- 20% cost reduction
        timeReduction = 0.3   -- 30% time reduction
    }

    local cost = entry:calculateTotalCost({}, bonuses)
    test_framework.assert_equal(cost, 80, "Cost should be reduced by bonus")

    local time = entry:calculateProductionTime(1, bonuses)
    test_framework.assert_equal(time, 4, "Time should be reduced by bonus")  -- 5 * 0.7 = 3.5, rounds to 4?
end

function TestManufacturingEntry.test_production_requirements_summary()
    local manufacturing_data = {
        id = "complex_item",
        name = "Complex Item",
        requiredMaterials = {
            { materialId = "material_a", quantity = 2 },
            { materialId = "material_b", quantity = 3 }
        },
        requiredFacilities = { "workshop", "laboratory" },
        skillRequirements = {
            { skill = "engineering", level = 3 }
        }
    }

    local entry = ManufacturingEntry(manufacturing_data)

    local requirements = entry:getProductionRequirements()
    test_framework.assert_equal(#requirements.materials, 2, "Should have 2 material requirements")
    test_framework.assert_equal(#requirements.facilities, 2, "Should have 2 facility requirements")
    test_framework.assert_equal(#requirements.skills, 1, "Should have 1 skill requirement")
end

function TestManufacturingEntry.test_manufacturing_summary()
    local manufacturing_data = {
        id = "summary_test",
        name = "Summary Test",
        category = "test",
        baseCost = 200,
        baseTime = 4,
        producedQuantity = 1
    }

    local entry = ManufacturingEntry(manufacturing_data)

    local summary = entry:getManufacturingSummary()
    test_framework.assert_equal(summary.id, "summary_test", "Summary ID should match")
    test_framework.assert_equal(summary.name, "Summary Test", "Summary name should match")
    test_framework.assert_equal(summary.category, "test", "Summary category should match")
    test_framework.assert_equal(summary.baseCost, 200, "Summary base cost should match")
    test_framework.assert_equal(summary.baseTime, 4, "Summary base time should match")
end

return TestManufacturingEntry