--- Test suite for CraftManager
-- Tests craft collection management and base operations

-- GROK: CraftManager tests validate craft collection and base management
-- GROK: Tests creation, assignment, transfer, and maintenance operations
-- GROK: Key test areas: craft lifecycle, base capacity, transfers, statistics

local test_framework = require 'test.test_framework'
local CraftManager = require 'crafts.CraftManager'
local Craft = require 'crafts.Craft'
local CraftClass = require 'crafts.CraftClass'

local test_craft_manager = {}

--- Test craft manager initialization
function test_craft_manager.test_initialization()
    local manager = CraftManager:new()

    -- Check initial state
    test_framework.assert_not_nil(manager.crafts, "Crafts collection should exist")
    test_framework.assert_not_nil(manager.baseAssignments, "Base assignments should exist")
    test_framework.assert_not_nil(manager.stats, "Statistics should exist")

    -- Check default config
    test_framework.assert_equal(manager.maxCraftsPerBase, 20, "Default max crafts per base should be 20")
end

--- Test craft creation
function test_craft_manager.test_craft_creation()
    local manager = CraftManager:new()

    -- Create mock craft class
    local craftClass = CraftClass:new({
        id = "test_interceptor",
        name = "Test Interceptor",
        type = "air",
        capabilities = { speed = 2, armor = 1 },
        stats = { fuel_capacity = 100 }
    })

    -- Create craft
    local craftData = {
        id = "test_craft_001",
        name = "Test Craft"
    }
    local craft = manager:createCraft(craftData, craftClass, "base_1")

    test_framework.assert_not_nil(craft, "Craft should be created")
    test_framework.assert_equal(craft.id, "test_craft_001", "Craft ID should match")
    test_framework.assert_equal(manager.stats.totalCrafts, 1, "Total crafts should be 1")
end

--- Test base assignment
function test_craft_manager.test_base_assignment()
    local manager = CraftManager:new()

    -- Create and assign craft
    local craftClass = CraftClass:new({
        id = "test_craft",
        type = "air",
        capabilities = { speed = 1, armor = 1 },
        stats = { fuel_capacity = 100 }
    })
    local craft = manager:createCraft({ id = "test_craft" }, craftClass, "base_1")

    -- Check assignment
    test_framework.assert_not_nil(manager.craftAssignments["test_craft"], "Craft should be assigned")
    test_framework.assert_equal(manager.craftAssignments["test_craft"], "base_1", "Craft should be assigned to base_1")

    -- Check base crafts
    local baseCrafts = manager:getCraftsAtBase("base_1")
    test_framework.assert_equal(#baseCrafts, 1, "Base should have 1 craft")
    test_framework.assert_equal(baseCrafts[1], craft, "Base should contain the craft")
end

--- Test base capacity limits
function test_craft_manager.test_base_capacity()
    local manager = CraftManager:new({ maxCraftsPerBase = 2 })

    local craftClass = CraftClass:new({
        id = "test_craft",
        type = "air",
        capabilities = { speed = 1, armor = 1 },
        stats = { fuel_capacity = 100 }
    })

    -- Create crafts up to limit
    local craft1 = manager:createCraft({ id = "craft_1" }, craftClass, "base_1")
    local craft2 = manager:createCraft({ id = "craft_2" }, craftClass, "base_1")

    test_framework.assert_not_nil(craft1, "First craft should be created")
    test_framework.assert_not_nil(craft2, "Second craft should be created")

    -- Try to exceed limit
    local craft3 = manager:createCraft({ id = "craft_3" }, craftClass, "base_1")
    test_framework.assert_nil(craft3, "Third craft should not be created due to capacity limit")
end

--- Test craft transfer between bases
function test_craft_manager.test_craft_transfer()
    local manager = CraftManager:new()

    -- Create craft at base_1
    local craftClass = CraftClass:new({
        id = "test_craft",
        type = "air",
        capabilities = { speed = 1, armor = 1 },
        stats = { fuel_capacity = 100 }
    })
    local craft = manager:createCraft({ id = "test_craft" }, craftClass, "base_1")

    -- Transfer to base_2
    local success = manager:transferCraft("test_craft", "base_2", 6)
    test_framework.assert_true(success, "Transfer should be initiated")

    -- Check transfer state
    test_framework.assert_equal(craft.status, "transferring", "Craft status should be transferring")
    test_framework.assert_equal(craft.transferDestination, "base_2", "Transfer destination should be set")
    test_framework.assert_equal(craft.transferETA, 6, "Transfer ETA should be set")

    -- Complete transfer
    success = manager:completeTransfer("test_craft")
    test_framework.assert_true(success, "Transfer should complete")

    -- Check final assignment
    test_framework.assert_equal(manager.craftAssignments["test_craft"], "base_2", "Craft should be assigned to base_2")
    test_framework.assert_equal(craft.status, "hangar", "Craft status should be hangar")
    test_framework.assert_nil(craft.transferDestination, "Transfer destination should be cleared")
end

--- Test operational crafts filtering
function test_craft_manager.test_operational_crafts()
    local manager = CraftManager:new()

    local craftClass = CraftClass:new({
        id = "test_craft",
        type = "air",
        capabilities = { speed = 1, armor = 1 },
        stats = { fuel_capacity = 100 }
    })

    -- Create operational craft
    local craft1 = manager:createCraft({ id = "craft_1" }, craftClass, "base_1")

    -- Create damaged craft
    local craft2 = manager:createCraft({ id = "craft_2" }, craftClass, "base_1")
    craft2.condition = 20 -- Below operational threshold

    -- Create out-of-fuel craft
    local craft3 = manager:createCraft({ id = "craft_3" }, craftClass, "base_1")
    craft3.fuel = 0

    -- Get operational crafts
    local operational = manager:getOperationalCraftsAtBase("base_1")
    test_framework.assert_equal(#operational, 1, "Should have 1 operational craft")
    test_framework.assert_equal(operational[1], craft1, "Should return the operational craft")
end

--- Test craft destruction
function test_craft_manager.test_craft_destruction()
    local manager = CraftManager:new()

    -- Create craft
    local craftClass = CraftClass:new({
        id = "test_craft",
        type = "air",
        capabilities = { speed = 1, armor = 1 },
        stats = { fuel_capacity = 100 }
    })
    manager:createCraft({ id = "test_craft" }, craftClass, "base_1")

    -- Destroy craft
    local success = manager:destroyCraft("test_craft")
    test_framework.assert_true(success, "Craft should be destroyed")

    -- Check removal
    test_framework.assert_nil(manager.crafts["test_craft"], "Craft should be removed from collection")
    test_framework.assert_nil(manager.craftAssignments["test_craft"], "Craft assignment should be removed")
    test_framework.assert_equal(manager.stats.totalCrafts, 0, "Total crafts should be 0")
end

--- Test maintenance updates
function test_craft_manager.test_maintenance()
    local manager = CraftManager:new({ repairRate = 10 })

    -- Create damaged craft
    local craftClass = CraftClass:new({
        id = "test_craft",
        type = "air",
        capabilities = { speed = 1, armor = 1 },
        stats = { fuel_capacity = 100 }
    })
    local craft = manager:createCraft({ id = "test_craft" }, craftClass, "base_1")
    craft.condition = 50

    -- Run maintenance
    manager:updateMaintenance(2) -- 2 hours

    -- Check repair
    test_framework.assert_equal(craft.condition, 70, "Craft should be repaired (50 + 10*2)")
end

--- Test statistics tracking
function test_craft_manager.test_statistics()
    local manager = CraftManager:new()

    local craftClass = CraftClass:new({
        id = "test_craft",
        type = "air",
        capabilities = { speed = 1, armor = 1 },
        stats = { fuel_capacity = 100 }
    })

    -- Create operational craft
    manager:createCraft({ id = "craft_1" }, craftClass, "base_1")

    -- Create damaged craft
    local craft2 = manager:createCraft({ id = "craft_2" }, craftClass, "base_1")
    craft2.condition = 50

    -- Create destroyed craft
    local craft3 = manager:createCraft({ id = "craft_3" }, craftClass, "base_1")
    craft3.condition = 0

    -- Update stats
    manager:_updateStats()

    -- Check statistics
    test_framework.assert_equal(manager.stats.totalCrafts, 3, "Total crafts should be 3")
    test_framework.assert_equal(manager.stats.operationalCrafts, 1, "Operational crafts should be 1")
    test_framework.assert_equal(manager.stats.damagedCrafts, 1, "Damaged crafts should be 1")
    test_framework.assert_equal(manager.stats.destroyedCrafts, 1, "Destroyed crafts should be 1")
end

--- Test mission availability
function test_craft_manager.test_mission_availability()
    local manager = CraftManager:new()

    local craftClass = CraftClass:new({
        id = "test_interceptor",
        type = "air",
        capabilities = { speed = 2, armor = 1, air_to_air = true },
        stats = { fuel_capacity = 100 }
    })

    -- Create available craft
    manager:createCraft({ id = "craft_1" }, craftClass, "base_1")

    -- Create busy craft
    local craft2 = manager:createCraft({ id = "craft_2" }, craftClass, "base_1")
    craft2.status = "en_route"

    -- Get available crafts for interception mission
    local available = manager:getAvailableCraftsForMission("base_1", "interception")
    test_framework.assert_equal(#available, 1, "Should have 1 available craft")
    test_framework.assert_equal(available[1].id, "craft_1", "Should return the available craft")
end

--- Run all craft manager tests
function test_craft_manager.run()
    test_framework.run_suite("Craft Manager", {
        test_initialization = test_craft_manager.test_initialization,
        test_craft_creation = test_craft_manager.test_craft_creation,
        test_base_assignment = test_craft_manager.test_base_assignment,
        test_base_capacity = test_craft_manager.test_base_capacity,
        test_craft_transfer = test_craft_manager.test_craft_transfer,
        test_operational_crafts = test_craft_manager.test_operational_crafts,
        test_craft_destruction = test_craft_manager.test_craft_destruction,
        test_maintenance = test_craft_manager.test_maintenance,
        test_statistics = test_craft_manager.test_statistics,
        test_mission_availability = test_craft_manager.test_mission_availability
    })
end

return test_craft_manager