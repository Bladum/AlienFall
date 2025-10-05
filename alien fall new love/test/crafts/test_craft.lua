--- Test suite for Craft entity
-- Tests individual craft instance functionality

-- GROK: Craft entity tests validate individual craft behavior
-- GROK: Tests equipment, experience, damage, and operational status
-- GROK: Key test areas: creation, equipment management, combat, experience

local test_framework = require 'test.test_framework'
local Craft = require 'crafts.Craft'
local CraftClass = require 'crafts.CraftClass'

local test_craft = {}

--- Test craft creation and initialization
function test_craft.test_creation()
    -- Create a mock craft class
    local craftClassData = {
        id = "test_interceptor",
        name = "Test Interceptor",
        type = "air",
        category = "fighter",
        capabilities = { speed = 2, armor = 1 },
        stats = { fuel_capacity = 100, max_range = 1500 }
    }
    local craftClass = CraftClass:new(craftClassData)

    -- Create craft instance
    local craftData = {
        id = "test_craft_001",
        name = "Test Craft",
        baseId = "base_1"
    }
    local craft = Craft:new(craftData, craftClass)

    -- Verify basic properties
    test_framework.assert_equal(craft.id, "test_craft_001", "Craft ID should match")
    test_framework.assert_equal(craft.name, "Test Craft", "Craft name should match")
    test_framework.assert_equal(craft.craftClass, craftClass, "Craft class should match")
    test_framework.assert_equal(craft.status, "hangar", "Default status should be hangar")
    test_framework.assert_equal(craft.condition, 100, "Default condition should be 100")
    test_framework.assert_equal(craft.fuel, 100, "Fuel should match class capacity")
end

--- Test craft equipment management
function test_craft.test_equipment()
    -- Create test craft
    local craftClass = CraftClass:new({
        id = "test_fighter",
        name = "Test Fighter",
        type = "air",
        capabilities = { speed = 2, armor = 1 },
        stats = { fuel_capacity = 100, weapon_slots = 2, addon_slots = 1 }
    })
    local craft = Craft:new({ id = "test_craft" }, craftClass)

    -- Test equipping weapon
    local success, error = craft:equipItem("test_weapon", "weapons", 1)
    test_framework.assert_true(success, "Should equip weapon successfully")
    test_framework.assert_equal(craft.equipment.weapons[1], "test_weapon", "Weapon should be equipped")

    -- Test unequipping weapon
    local unequipped = craft:unequipItem("weapons", 1)
    test_framework.assert_equal(unequipped, "test_weapon", "Should return unequipped weapon")
    test_framework.assert_nil(craft.equipment.weapons[1], "Weapon slot should be empty")
end

--- Test craft experience and leveling
function test_craft.test_experience()
    -- Create test craft
    local craftClass = CraftClass:new({
        id = "test_craft",
        type = "air",
        capabilities = { speed = 1, armor = 1 },
        stats = { fuel_capacity = 100 }
    })
    local craft = Craft:new({ id = "test_craft" }, craftClass)

    -- Initial state
    test_framework.assert_equal(craft.experience, 0, "Initial experience should be 0")
    test_framework.assert_equal(craft.level, 1, "Initial level should be 1")

    -- Gain experience
    craft:gainExperience(25, true)
    test_framework.assert_equal(craft.experience, 25, "Experience should increase")
    test_framework.assert_equal(craft.missions_completed, 1, "Mission count should increase")
    test_framework.assert_equal(craft.successful_missions, 1, "Successful mission count should increase")
end

--- Test craft damage and repair
function test_craft.test_damage_repair()
    -- Create test craft
    local craftClass = CraftClass:new({
        id = "test_craft",
        type = "air",
        capabilities = { speed = 1, armor = 1 },
        stats = { fuel_capacity = 100 }
    })
    local craft = Craft:new({ id = "test_craft" }, craftClass)

    -- Initial state
    test_framework.assert_equal(craft.condition, 100, "Initial condition should be 100")
    test_framework.assert_true(craft:isOperational(), "Craft should be operational")

    -- Take damage
    craft:takeDamage(30)
    test_framework.assert_equal(craft.condition, 70, "Condition should decrease by damage amount")

    -- Repair
    craft:repair(20)
    test_framework.assert_equal(craft.condition, 90, "Condition should increase by repair amount")
end

--- Test craft fuel management
function test_craft.test_fuel_management()
    -- Create test craft
    local craftClass = CraftClass:new({
        id = "test_craft",
        type = "air",
        capabilities = { speed = 1, armor = 1 },
        stats = { fuel_capacity = 100, fuel_efficiency = 0.5 }
    })
    local craft = Craft:new({ id = "test_craft" }, craftClass)

    -- Initial fuel
    test_framework.assert_equal(craft.fuel, 100, "Initial fuel should be at capacity")

    -- Consume fuel
    local success = craft:consumeFuel(50)
    test_framework.assert_true(success, "Should consume fuel successfully")
    test_framework.assert_equal(craft.fuel, 75, "Fuel should decrease")

    -- Try to consume more fuel than available
    success = craft:consumeFuel(100)
    test_framework.assert_false(success, "Should fail when not enough fuel")
    test_framework.assert_equal(craft.fuel, 75, "Fuel should not change")

    -- Refuel
    craft:refuel()
    test_framework.assert_equal(craft.fuel, 100, "Fuel should be at capacity after refuel")
end

--- Test craft mission assignment
function test_craft.test_mission_assignment()
    -- Create test craft
    local craftClass = CraftClass:new({
        id = "test_craft",
        type = "air",
        capabilities = { speed = 1, armor = 1 },
        stats = { fuel_capacity = 100 }
    })
    local craft = Craft:new({ id = "test_craft" }, craftClass)

    -- Assign to mission
    local destination = { x = 100, y = 200 }
    craft:assignToMission("mission_001", destination)

    test_framework.assert_equal(craft.currentMission, "mission_001", "Mission should be assigned")
    test_framework.assert_equal(craft.status, "en_route", "Status should be en_route")
    test_framework.assert_not_nil(craft.eta, "ETA should be calculated")

    -- Complete mission
    craft:completeMission(true)
    test_framework.assert_nil(craft.currentMission, "Mission should be cleared")
    test_framework.assert_equal(craft.status, "returning", "Status should be returning")
end

--- Test craft operational status
function test_craft.test_operational_status()
    -- Create test craft
    local craftClass = CraftClass:new({
        id = "test_craft",
        type = "air",
        capabilities = { speed = 1, armor = 1 },
        stats = { fuel_capacity = 100 }
    })
    local craft = Craft:new({ id = "test_craft" }, craftClass)

    -- Fully operational
    test_framework.assert_true(craft:isOperational(), "Craft should be operational")

    -- Low condition
    craft.condition = 20
    test_framework.assert_false(craft:isOperational(), "Craft should not be operational with low condition")

    -- Reset condition, deplete fuel
    craft.condition = 100
    craft.fuel = 0
    test_framework.assert_false(craft:isOperational(), "Craft should not be operational without fuel")

    -- Destroyed
    craft.condition = 0
    test_framework.assert_false(craft:isOperational(), "Destroyed craft should not be operational")
end

--- Run all craft tests
function test_craft.run()
    test_framework.run_suite("Craft Entity", {
        test_creation = test_craft.test_creation,
        test_equipment = test_craft.test_equipment,
        test_experience = test_craft.test_experience,
        test_damage_repair = test_craft.test_damage_repair,
        test_fuel_management = test_craft.test_fuel_management,
        test_mission_assignment = test_craft.test_mission_assignment,
        test_operational_status = test_craft.test_operational_status
    })
end

return test_craft