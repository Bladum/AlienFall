--- Test suite for ManufacturingProject class
-- @module test.economy.test_manufacturing_project

local test_framework = require("test.framework.test_framework")
local ManufacturingProject = require("src.economy.ManufacturingProject")

local TestManufacturingProject = {}

function TestManufacturingProject.test_creation()
    local manufacturing_data = {
        id = "laser_rifle_project",
        name = "Laser Rifle Production",
        itemId = "laser_rifle",
        quantity = 5,
        priority = "normal"
    }

    local project = ManufacturingProject(manufacturing_data)

    test_framework.assert_equal(project.id, "laser_rifle_project", "Project ID should match")
    test_framework.assert_equal(project.name, "Laser Rifle Production", "Project name should match")
    test_framework.assert_equal(project.itemId, "laser_rifle", "Item ID should match")
    test_framework.assert_equal(project.quantity, 5, "Quantity should match")
    test_framework.assert_equal(project.priority, "normal", "Priority should match")
    test_framework.assert_equal(project.progress, 0, "Initial progress should be 0")
    test_framework.assert_false(project.isActive, "Should not be active initially")
end

function TestManufacturingProject.test_project_initialization()
    local manufacturing_data = {
        id = "test_project",
        name = "Test Project",
        itemId = "test_item",
        quantity = 3
    }

    local project = ManufacturingProject(manufacturing_data)

    -- Test with manufacturing entry data
    local entryData = {
        baseCost = 100,
        baseTime = 2,
        requiredMaterials = {
            { materialId = "material_a", quantity = 1 },
            { materialId = "material_b", quantity = 2 }
        }
    }

    project:initializeFromEntry(entryData)

    test_framework.assert_equal(project.totalCost, 300, "Total cost should be 100 * 3")
    test_framework.assert_equal(project.estimatedTime, 6, "Estimated time should be 2 * 3")
    test_framework.assert_equal(project.requiredMaterials.material_a, 3, "Material A requirement should be scaled")
    test_framework.assert_equal(project.requiredMaterials.material_b, 6, "Material B requirement should be scaled")
end

function TestManufacturingProject.test_project_start()
    local manufacturing_data = {
        id = "start_test",
        name = "Start Test",
        itemId = "test_item",
        quantity = 2
    }

    local project = ManufacturingProject(manufacturing_data)

    -- Initialize project
    local entryData = {
        baseCost = 50,
        baseTime = 3,
        requiredMaterials = {
            { materialId = "material_a", quantity = 1 }
        }
    }
    project:initializeFromEntry(entryData)

    -- Test starting project
    local availableMaterials = { material_a = 5 }
    local availableFacilities = { workshop = true }
    local availableSkills = { engineering = 3 }

    local started = project:startProject(1, availableMaterials, availableFacilities, availableSkills)
    test_framework.assert_true(started, "Should start successfully")
    test_framework.assert_true(project.isActive, "Should be active")
    test_framework.assert_equal(project.startTime, 1, "Start time should be set")
    test_framework.assert_equal(availableMaterials.material_a, 3, "Materials should be consumed")
end

function TestManufacturingProject.test_progress_update()
    local manufacturing_data = {
        id = "progress_test",
        name = "Progress Test",
        itemId = "test_item",
        quantity = 1
    }

    local project = ManufacturingProject(manufacturing_data)

    -- Initialize and start project
    local entryData = {
        baseCost = 100,
        baseTime = 5
    }
    project:initializeFromEntry(entryData)

    local availableMaterials = {}
    local availableFacilities = { workshop = true }
    local availableSkills = {}

    project:startProject(1, availableMaterials, availableFacilities, availableSkills)

    -- Update progress for 3 days
    project:updateProgress(4, 1)  -- Current time = 4, 1 workshop

    -- Expected progress: (3 days / 5 days) * 100 = 60%
    test_framework.assert_equal(project.progress, 60, "Progress should be 60%")
    test_framework.assert_false(project:isCompleted(), "Should not be completed yet")

    -- Update for 2 more days (total 5 days)
    project:updateProgress(6, 1)
    test_framework.assert_equal(project.progress, 100, "Progress should be 100%")
    test_framework.assert_true(project:isCompleted(), "Should be completed")
    test_framework.assert_equal(project.completionTime, 6, "Completion time should be set")
end

function TestManufacturingProject.test_resource_allocation()
    local manufacturing_data = {
        id = "allocation_test",
        name = "Allocation Test",
        itemId = "test_item",
        quantity = 1
    }

    local project = ManufacturingProject(manufacturing_data)

    -- Initialize project
    local entryData = {
        baseCost = 100,
        baseTime = 10
    }
    project:initializeFromEntry(entryData)
    project:startProject(1, {}, { workshop = true }, {})

    -- Test facility allocation
    project:allocateFacilities({ workshop = true, laboratory = true })
    test_framework.assert_equal(project.allocatedFacilities.workshop, true, "Workshop should be allocated")
    test_framework.assert_equal(project.allocatedFacilities.laboratory, true, "Laboratory should be allocated")

    -- Test efficiency recalculation
    project:recalculateEfficiency()
    -- With 2 facilities instead of 1, time should be halved
    test_framework.assert_equal(project.estimatedTime, 5, "Estimated time should be reduced")
end

function TestManufacturingProject.test_project_pause_resume()
    local manufacturing_data = {
        id = "pause_test",
        name = "Pause Test",
        itemId = "test_item",
        quantity = 1
    }

    local project = ManufacturingProject(manufacturing_data)

    -- Initialize and start project
    local entryData = { baseCost = 100, baseTime = 5 }
    project:initializeFromEntry(entryData)
    project:startProject(1, {}, { workshop = true }, {})

    -- Pause project
    project:pauseProject()
    test_framework.assert_false(project.isActive, "Should be paused")
    test_framework.assert_true(project.isPaused, "Should be marked as paused")

    -- Resume project
    project:resumeProject()
    test_framework.assert_true(project.isActive, "Should be active again")
    test_framework.assert_false(project.isPaused, "Should not be paused")
end

function TestManufacturingProject.test_project_cancellation()
    local manufacturing_data = {
        id = "cancel_test",
        name = "Cancel Test",
        itemId = "test_item",
        quantity = 1
    }

    local project = ManufacturingProject(manufacturing_data)

    -- Initialize and start project
    local entryData = { baseCost = 100, baseTime = 5 }
    project:initializeFromEntry(entryData)
    project:startProject(1, { material_a = 5 }, { workshop = true }, {})

    project:updateProgress(3)  -- Some progress made

    -- Cancel project
    local cancelled = project:cancelProject()
    test_framework.assert_true(cancelled, "Should cancel successfully")
    test_framework.assert_false(project.isActive, "Should not be active")
    test_framework.assert_false(project.isPaused, "Should not be paused")
    test_framework.assert_equal(project.progress, 0, "Progress should reset to 0")
end

function TestManufacturingProject.test_cost_tracking()
    local manufacturing_data = {
        id = "cost_test",
        name = "Cost Test",
        itemId = "test_item",
        quantity = 2
    }

    local project = ManufacturingProject(manufacturing_data)

    -- Initialize project
    local entryData = { baseCost = 50, baseTime = 5 }
    project:initializeFromEntry(entryData)
    project:startProject(1, {}, { workshop = true }, {})

    -- Test daily cost calculation
    local dailyCost = project:getDailyCost()
    -- 2 items * 50 cost / 5 days = 20 credits per day
    test_framework.assert_equal(dailyCost, 20, "Daily cost should be correct")

    -- Test total cost spent
    project:updateProgress(3)  -- 2 days elapsed
    local totalSpent = project:getTotalCostSpent()
    test_framework.assert_equal(totalSpent, 40, "Total cost spent should be correct")
end

function TestManufacturingProject.test_priority_system()
    local manufacturing_data = {
        id = "priority_test",
        name = "Priority Test",
        itemId = "test_item",
        quantity = 1,
        priority = "high"
    }

    local project = ManufacturingProject(manufacturing_data)

    -- Test priority multipliers
    local timeMultiplier = project:getPriorityTimeMultiplier()
    test_framework.assert_equal(timeMultiplier, 0.7, "High priority should reduce time")

    local costMultiplier = project:getPriorityCostMultiplier()
    test_framework.assert_equal(costMultiplier, 1.5, "High priority should increase cost")

    -- Test changing priority
    project:setPriority("low")
    timeMultiplier = project:getPriorityTimeMultiplier()
    test_framework.assert_equal(timeMultiplier, 1.3, "Low priority should increase time")
end

function TestManufacturingProject.test_completion_and_delivery()
    local manufacturing_data = {
        id = "completion_test",
        name = "Completion Test",
        itemId = "test_item",
        quantity = 2
    }

    local project = ManufacturingProject(manufacturing_data)

    -- Initialize and complete project
    local entryData = { baseCost = 100, baseTime = 5 }
    project:initializeFromEntry(entryData)
    project:startProject(1, {}, { workshop = true }, {})

    -- Mock inventory
    local inventory = {}

    -- Complete project
    project:updateProgress(6, 1)  -- Complete the project
    local completed = project:completeProject(inventory)

    test_framework.assert_true(completed, "Should complete successfully")
    test_framework.assert_true(project.isCompleted, "Should be marked completed")
    test_framework.assert_equal(inventory.test_item, 2, "Items should be added to inventory")
end

function TestManufacturingProject.test_project_summary()
    local manufacturing_data = {
        id = "summary_test",
        name = "Summary Test",
        itemId = "test_item",
        quantity = 3,
        priority = "normal"
    }

    local project = ManufacturingProject(manufacturing_data)

    -- Initialize and start project
    local entryData = { baseCost = 50, baseTime = 5 }
    project:initializeFromEntry(entryData)
    project:startProject(1, {}, { workshop = true }, {})
    project:updateProgress(3)

    local summary = project:getSummary()
    test_framework.assert_equal(summary.id, "summary_test", "Summary ID should match")
    test_framework.assert_equal(summary.itemId, "test_item", "Summary item ID should match")
    test_framework.assert_equal(summary.quantity, 3, "Summary quantity should match")
    test_framework.assert_equal(summary.progress, 40, "Summary progress should be correct")  -- 2 days / 5 days * 100 = 40%
    test_framework.assert_true(summary.isActive, "Summary should show active status")
end

return TestManufacturingProject