--- Test suite for CraftService
-- Tests high-level craft service operations

-- GROK: CraftService tests validate service layer functionality
-- GROK: Tests craft creation, equipment, missions, and service integration
-- GROK: Key test areas: service operations, data loading, event handling

local test_framework = require 'test.test_framework'
local CraftService = require 'crafts.CraftService'
local CraftManager = require 'crafts.CraftManager'
local Craft = require 'crafts.Craft'
local CraftClass = require 'crafts.CraftClass'
local CraftItem = require 'crafts.CraftItem'

local test_craft_service = {}

--- Test service initialization
function test_craft_service.test_initialization()
    local service = CraftService:new()

    -- Check service structure
    test_framework.assert_not_nil(service.manager, "Craft manager should exist")
    test_framework.assert_not_nil(service.craftClasses, "Craft classes should exist")
    test_framework.assert_not_nil(service.craftItems, "Craft items should exist")
    test_framework.assert_not_nil(service.craftLevels, "Craft levels should exist")
end

--- Test craft creation through service
function test_craft_service.test_craft_creation()
    local service = CraftService:new()

    -- Create craft through service
    local craft = service:createCraft("test_interceptor", "Test Craft", "base_1")

    test_framework.assert_not_nil(craft, "Craft should be created")
    test_framework.assert_equal(craft.name, "Test Craft", "Craft name should match")
    test_framework.assert_equal(craft.classId, "test_interceptor", "Craft class should match")
end

--- Test equipment operations
function test_craft_service.test_equipment()
    local service = CraftService:new()

    -- Create craft
    local craft = service:createCraft("test_interceptor", "Test Craft", "base_1")

    -- Equip weapon
    local success = service:equipItemOnCraft(craft.id, "cannon", "weapon")
    test_framework.assert_true(success, "Weapon should be equipped")

    -- Check equipment
    test_framework.assert_equal(craft.equipment.weapon, "cannon", "Weapon should be equipped")

    -- Try to equip incompatible item
    success = service:equipItemOnCraft(craft.id, "armor_plating", "weapon")
    test_framework.assert_false(success, "Incompatible item should not be equipped")
end

--- Test experience and leveling
function test_craft_service.test_experience()
    local service = CraftService:new()

    -- Create craft
    local craft = service:createCraft("test_interceptor", "Test Craft", "base_1")

    -- Gain experience
    service:addExperienceToCraft(craft.id, 100)

    -- Check level progression
    test_framework.assert_true(craft.experience >= 100, "Experience should be gained")
    test_framework.assert_true(craft.level >= 1, "Level should increase")
end

--- Test mission assignment
function test_craft_service.test_mission_assignment()
    local service = CraftService:new()

    -- Create craft
    local craft = service:createCraft("test_interceptor", "Test Craft", "base_1")

    -- Assign to mission
    local success = service:assignCraftToMission(craft.id, "test_mission", 8)
    test_framework.assert_true(success, "Craft should be assigned to mission")

    -- Check mission state
    test_framework.assert_equal(craft.status, "en_route", "Craft status should be en_route")
    test_framework.assert_equal(craft.currentMission, "test_mission", "Mission should be assigned")
end

--- Test mission completion
function test_craft_service.test_mission_completion()
    local service = CraftService:new()

    -- Create and assign craft
    local craft = service:createCraft("test_interceptor", "Test Craft", "base_1")
    service:assignCraftToMission(craft.id, "test_mission", 8)

    -- Complete mission
    local success = service:completeCraftMission(craft.id, true, 50)
    test_framework.assert_true(success, "Mission should complete")

    -- Check post-mission state
    test_framework.assert_equal(craft.status, "hangar", "Craft should return to hangar")
    test_framework.assert_nil(craft.currentMission, "Mission should be cleared")
    test_framework.assert_true(craft.experience >= 50, "Experience should be gained")
end

--- Test damage and repair
function test_craft_service.test_damage_repair()
    local service = CraftService:new()

    -- Create craft
    local craft = service:createCraft("test_interceptor", "Test Craft", "base_1")

    -- Apply damage
    service:damageCraft(craft.id, 30)
    test_framework.assert_equal(craft.condition, 70, "Craft should take damage")

    -- Repair craft
    service:repairCraft(craft.id, 20)
    test_framework.assert_equal(craft.condition, 90, "Craft should be repaired")
end

--- Test fuel management
function test_craft_service.test_fuel_management()
    local service = CraftService:new()

    -- Create craft
    local craft = service:createCraft("test_interceptor", "Test Craft", "base_1")

    -- Test fuel status
    local fuelStatus = service:getCraftFuelStatus(craft.id)
    test_framework.assert_not_nil(fuelStatus, "Fuel status should be available")
    test_framework.assert_equal(fuelStatus.current_fuel, 100, "Initial fuel should be 100")
    test_framework.assert_equal(fuelStatus.max_fuel, 100, "Max fuel should be 100")

    -- Test fuel consumption calculation
    local fuelNeeded = craft:calculateFuelConsumption(50, 1)
    test_framework.assert_true(fuelNeeded > 0, "Fuel consumption should be calculated")

    -- Test range checking
    local canTravel, fuelRequired = craft:canTravelDistance(50, 1)
    test_framework.assert_true(canTravel, "Craft should be able to travel distance")
    test_framework.assert_equal(fuelRequired, fuelNeeded, "Fuel required should match calculation")

    -- Consume fuel for movement
    local fuelConsumed, success = craft:consumeFuelForMovement(50, 1)
    test_framework.assert_true(success, "Fuel consumption should succeed")
    test_framework.assert_true(craft.fuel < 100, "Fuel should be reduced")

    -- Test operational range
    local operationalRange = craft:getOperationalRange(1)
    test_framework.assert_true(operationalRange > 0, "Operational range should be calculated")

    -- Test refueling
    local success, fuelAdded, cost = service:refuelCraft(craft.id)
    test_framework.assert_true(success, "Refueling should succeed")
    test_framework.assert_equal(craft.fuel, 100, "Craft should be fully refueled")
    test_framework.assert_true(cost > 0, "Refueling should have a cost")
end

--- Test craft status queries
function test_craft_service.test_status_queries()
    local service = CraftService:new()

    -- Create crafts with different states
    local craft1 = service:createCraft("test_interceptor", "Craft 1", "base_1")
    local craft2 = service:createCraft("test_fighter", "Craft 2", "base_1")
    craft2.condition = 50 -- Damaged

    -- Get status
    local status = service:getCraftStatus(craft1.id)
    test_framework.assert_equal(status.operational, true, "Craft 1 should be operational")

    status = service:getCraftStatus(craft2.id)
    test_framework.assert_equal(status.operational, false, "Craft 2 should not be operational")
    test_framework.assert_equal(status.damaged, true, "Craft 2 should be damaged")
end

--- Test base operations
function test_craft_service.test_base_operations()
    local service = CraftService:new()

    -- Create crafts at different bases
    service:createCraft("test_interceptor", "Craft 1", "base_1")
    service:createCraft("test_fighter", "Craft 2", "base_2")

    -- Get crafts at base
    local baseCrafts = service:getCraftsAtBase("base_1")
    test_framework.assert_equal(#baseCrafts, 1, "Base 1 should have 1 craft")

    -- Transfer craft
    local success = service:transferCraft("craft_1", "base_2", 6)
    test_framework.assert_true(success, "Transfer should be initiated")
end

--- Test craft destruction
function test_craft_service.test_craft_destruction()
    local service = CraftService:new()

    -- Create craft
    local craft = service:createCraft("test_interceptor", "Test Craft", "base_1")

    -- Destroy craft
    local success = service:destroyCraft(craft.id)
    test_framework.assert_true(success, "Craft should be destroyed")

    -- Check removal
    local status = service:getCraftStatus(craft.id)
    test_framework.assert_nil(status, "Craft status should not exist after destruction")
end

--- Test service statistics
function test_craft_service.test_statistics()
    local service = CraftService:new()

    -- Create crafts
    service:createCraft("test_interceptor", "Craft 1", "base_1")
    service:createCraft("test_fighter", "Craft 2", "base_1")

    -- Get statistics
    local stats = service:getCraftStatistics()
    test_framework.assert_equal(stats.totalCrafts, 2, "Total crafts should be 2")
    test_framework.assert_true(stats.operationalCrafts >= 1, "Should have operational crafts")
end

--- Test mission availability
function test_craft_service.test_mission_availability()
    local service = CraftService:new()

    -- Create craft
    service:createCraft("test_interceptor", "Test Craft", "base_1")

    -- Get available crafts for mission
    local available = service:getAvailableCraftsForMission("base_1", "interception")
    test_framework.assert_equal(#available, 1, "Should have 1 available craft")
end

--- Test data loading
function test_craft_service.test_data_loading()
    local service = CraftService:new()

    -- Check that data was loaded
    test_framework.assert_not_nil(service.craftClasses["interceptor"], "Interceptor class should be loaded")
    test_framework.assert_not_nil(service.craftItems["cannon"], "Cannon item should be loaded")
    test_framework.assert_not_nil(service.craftLevels[1], "Level 1 should be loaded")
end

--- Run all craft service tests
function test_craft_service.run()
    test_framework.run_suite("Craft Service", {
        test_initialization = test_craft_service.test_initialization,
        test_craft_creation = test_craft_service.test_craft_creation,
        test_equipment = test_craft_service.test_equipment,
        test_experience = test_craft_service.test_experience,
        test_mission_assignment = test_craft_service.test_mission_assignment,
        test_mission_completion = test_craft_service.test_mission_completion,
        test_damage_repair = test_craft_service.test_damage_repair,
        test_fuel_management = test_craft_service.test_fuel_management,
        test_status_queries = test_craft_service.test_status_queries,
        test_base_operations = test_craft_service.test_base_operations,
        test_craft_destruction = test_craft_service.test_craft_destruction,
        test_statistics = test_craft_service.test_statistics,
        test_mission_availability = test_craft_service.test_mission_availability,
        test_data_loading = test_craft_service.test_data_loading
    })
end

return test_craft_service