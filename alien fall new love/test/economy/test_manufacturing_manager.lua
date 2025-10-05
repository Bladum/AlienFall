--- Test suite for ManufacturingManager class
-- @module test.economy.test_manufacturing_manager

local test_framework = require("test.framework.test_framework")
local ManufacturingManager = require("src.economy.ManufacturingManager")

local TestManufacturingManager = {}

function TestManufacturingManager.test_creation()
    local manager = ManufacturingManager()

    test_framework.assert_not_nil(manager.activeProjects, "Should have active projects table")
    test_framework.assert_not_nil(manager.completedProjects, "Should have completed projects table")
    test_framework.assert_not_nil(manager.projectQueue, "Should have project queue")
    test_framework.assert_equal(#manager.activeProjects, 0, "Should start with no active projects")
    test_framework.assert_equal(#manager.projectQueue, 0, "Should start with empty queue")
end

function TestManufacturingManager.test_project_queueing()
    local manager = ManufacturingManager()

    -- Create mock project data
    local projectData1 = {
        id = "project_1",
        name = "Project 1",
        itemId = "item_1",
        quantity = 2,
        priority = "normal"
    }

    local projectData2 = {
        id = "project_2",
        name = "Project 2",
        itemId = "item_2",
        quantity = 1,
        priority = "high"
    }

    -- Queue projects
    local queued1 = manager:queueProject(projectData1)
    local queued2 = manager:queueProject(projectData2)

    test_framework.assert_true(queued1, "First project should be queued")
    test_framework.assert_true(queued2, "Second project should be queued")
    test_framework.assert_equal(#manager.projectQueue, 2, "Should have 2 projects in queue")

    -- Check priority ordering (high priority should come first)
    test_framework.assert_equal(manager.projectQueue[1].id, "project_2", "High priority project should be first")
    test_framework.assert_equal(manager.projectQueue[2].id, "project_1", "Normal priority project should be second")
end

function TestManufacturingManager.test_project_activation()
    local manager = ManufacturingManager()

    -- Mock manufacturing entry
    local mockEntry = {
        canManufacture = function() return true end,
        calculateTotalCost = function() return 100 end,
        calculateProductionTime = function() return 5 end,
        requiredMaterials = { material_a = 1 }
    }

    -- Mock dependencies
    manager.getManufacturingEntry = function() return mockEntry end

    -- Queue and start project
    local projectData = {
        id = "test_project",
        name = "Test Project",
        itemId = "test_item",
        quantity = 1
    }

    manager:queueProject(projectData)

    local availableMaterials = { material_a = 5 }
    local availableFacilities = { workshop = true }
    local availableSkills = { engineering = 3 }

    local started = manager:startNextProject(availableMaterials, availableFacilities, availableSkills)
    test_framework.assert_true(started, "Project should start successfully")
    test_framework.assert_equal(#manager.activeProjects, 1, "Should have 1 active project")
    test_framework.assert_equal(#manager.projectQueue, 0, "Queue should be empty")
end

function TestManufacturingManager.test_capacity_management()
    local manager = ManufacturingManager()

    -- Set capacity limits
    manager.maxConcurrentProjects = 2
    manager.maxFacilities = { workshop = 2, laboratory = 1 }

    -- Mock projects that use facilities
    local mockProject1 = {
        id = "project_1",
        allocatedFacilities = { workshop = true },
        isActive = true,
        isCompleted = function() return false end
    }

    local mockProject2 = {
        id = "project_2",
        allocatedFacilities = { workshop = true, laboratory = true },
        isActive = true,
        isCompleted = function() return false end
    }

    manager.activeProjects = { mockProject1, mockProject2 }

    -- Test capacity checks
    local hasCapacity = manager:hasCapacityForProject({ workshop = true })
    test_framework.assert_false(hasCapacity, "Should not have capacity for workshop")

    hasCapacity = manager:hasCapacityForProject({ assembly = true })
    test_framework.assert_true(hasCapacity, "Should have capacity for unused facility")
end

function TestManufacturingManager.test_project_progress_update()
    local manager = ManufacturingManager()

    -- Mock active project
    local mockProject = {
        id = "progress_test",
        updateProgress = function(self, time, facilities) self.progress = (self.progress or 0) + 20 end,
        isCompleted = function(self) return (self.progress or 0) >= 100 end,
        completeProject = function(self, inventory) self.isCompleted = true; inventory.test_item = (inventory.test_item or 0) + 1 end,
        progress = 0,
        itemId = "test_item",
        quantity = 1
    }

    manager.activeProjects = { mockProject }

    -- Update progress
    local inventory = {}
    manager:updateProjectProgress(1, { workshop = 1 }, inventory)

    test_framework.assert_equal(mockProject.progress, 20, "Project progress should be updated")

    -- Update again to complete
    manager:updateProjectProgress(2, { workshop = 1 }, inventory)
    test_framework.assert_equal(mockProject.progress, 40, "Project progress should be updated again")

    -- Complete project
    mockProject.progress = 100
    manager:updateProjectProgress(3, { workshop = 1 }, inventory)
    test_framework.assert_equal(#manager.activeProjects, 0, "Completed project should be removed")
    test_framework.assert_equal(#manager.completedProjects, 1, "Should have 1 completed project")
    test_framework.assert_equal(inventory.test_item, 1, "Item should be added to inventory")
end

function TestManufacturingManager.test_resource_management()
    local manager = ManufacturingManager()

    -- Test resource reservation
    local availableMaterials = { material_a = 10, material_b = 5 }
    local requiredMaterials = { material_a = 3, material_b = 2 }

    local reserved = manager:reserveResources(availableMaterials, requiredMaterials)
    test_framework.assert_true(reserved, "Resources should be reserved")
    test_framework.assert_equal(availableMaterials.material_a, 7, "Material A should be reduced")
    test_framework.assert_equal(availableMaterials.material_b, 3, "Material B should be reduced")

    -- Test resource release
    manager:releaseResources(availableMaterials, requiredMaterials)
    test_framework.assert_equal(availableMaterials.material_a, 10, "Material A should be restored")
    test_framework.assert_equal(availableMaterials.material_b, 5, "Material B should be restored")
end

function TestManufacturingManager.test_project_prioritization()
    local manager = ManufacturingManager()

    -- Queue projects with different priorities
    local projects = {
        { id = "low_1", priority = "low" },
        { id = "high_1", priority = "high" },
        { id = "normal_1", priority = "normal" },
        { id = "high_2", priority = "high" }
    }

    for _, projectData in ipairs(projects) do
        manager:queueProject(projectData)
    end

    -- Check ordering: high priorities first, then normal, then low
    test_framework.assert_equal(manager.projectQueue[1].id, "high_1", "First should be high priority")
    test_framework.assert_equal(manager.projectQueue[2].id, "high_2", "Second should be high priority")
    test_framework.assert_equal(manager.projectQueue[3].id, "normal_1", "Third should be normal priority")
    test_framework.assert_equal(manager.projectQueue[4].id, "low_1", "Fourth should be low priority")
end

function TestManufacturingManager.test_efficiency_optimization()
    local manager = ManufacturingManager()

    -- Mock projects with different efficiencies
    local mockProject1 = {
        id = "efficient",
        getEfficiencyRating = function() return 0.9 end,
        allocatedFacilities = { workshop = true },
        isActive = true,
        isCompleted = function() return false end
    }

    local mockProject2 = {
        id = "inefficient",
        getEfficiencyRating = function() return 0.6 end,
        allocatedFacilities = { workshop = true },
        isActive = true,
        isCompleted = function() return false end
    }

    manager.activeProjects = { mockProject1, mockProject2 }

    -- Test efficiency optimization
    manager:optimizeProjectAllocation()

    -- Should prioritize more efficient projects
    -- (This would require more complex logic in the actual implementation)
    test_framework.assert_equal(#manager.activeProjects, 2, "Should still have 2 active projects")
end

function TestManufacturingManager.test_project_cancellation()
    local manager = ManufacturingManager()

    -- Mock active project
    local mockProject = {
        id = "cancel_test",
        cancelProject = function(self) self.isCancelled = true; return true end,
        isCancelled = false
    }

    manager.activeProjects = { mockProject }

    -- Cancel project
    local cancelled = manager:cancelProject("cancel_test")
    test_framework.assert_true(cancelled, "Project should be cancelled")
    test_framework.assert_true(mockProject.isCancelled, "Project should be marked cancelled")
    test_framework.assert_equal(#manager.activeProjects, 0, "Cancelled project should be removed")
end

function TestManufacturingManager.test_production_statistics()
    local manager = ManufacturingManager()

    -- Mock completed projects
    manager.completedProjects = {
        {
            id = "completed_1",
            itemId = "item_a",
            quantity = 2,
            totalCost = 100,
            actualTime = 5,
            completionTime = 10
        },
        {
            id = "completed_2",
            itemId = "item_b",
            quantity = 1,
            totalCost = 50,
            actualTime = 3,
            completionTime = 15
        }
    }

    -- Test statistics calculation
    local stats = manager:getProductionStatistics()

    test_framework.assert_equal(stats.totalItemsProduced, 3, "Should have produced 3 total items")
    test_framework.assert_equal(stats.totalCostSpent, 150, "Should have spent 150 total cost")
    test_framework.assert_equal(stats.averageProductionTime, 4, "Average production time should be 4 days")
    test_framework.assert_not_nil(stats.itemsByType, "Should have items by type statistics")
end

function TestManufacturingManager.test_manager_summary()
    local manager = ManufacturingManager()

    -- Set up some mock data
    manager.activeProjects = {
        { id = "active_1", progress = 50 },
        { id = "active_2", progress = 75 }
    }

    manager.projectQueue = {
        { id = "queued_1", priority = "high" },
        { id = "queued_2", priority = "normal" }
    }

    manager.completedProjects = {
        { id = "completed_1" },
        { id = "completed_2" },
        { id = "completed_3" }
    }

    local summary = manager:getSummary()
    test_framework.assert_equal(summary.activeProjectsCount, 2, "Should have 2 active projects")
    test_framework.assert_equal(summary.queuedProjectsCount, 2, "Should have 2 queued projects")
    test_framework.assert_equal(summary.completedProjectsCount, 3, "Should have 3 completed projects")
    test_framework.assert_not_nil(summary.capacityUtilization, "Should have capacity utilization data")
end

return TestManufacturingManager