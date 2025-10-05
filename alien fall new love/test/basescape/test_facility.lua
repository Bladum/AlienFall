--- Test suite for basescape.Facility class
-- @module test.basescape.test_facility

local test_framework = require "test.framework.test_framework"
local Facility = require 'basescape.Facility'

local test_facility = {}

--- Run all Facility tests
function test_facility.run()
    test_framework.run_suite("Facility", {
        test_facility_creation = test_facility.test_facility_creation,
        test_facility_damage_system = test_facility.test_facility_damage_system,
        test_facility_repair_system = test_facility.test_facility_repair_system,
        test_facility_operational_states = test_facility.test_facility_operational_states,
        test_facility_capacity_contributions = test_facility.test_facility_capacity_contributions,
        test_facility_service_contributions = test_facility.test_facility_service_contributions,
        test_facility_serialization = test_facility.test_facility_serialization
    })
end

--- Setup function run before each test
function test_facility.setup()
    -- Create a mock registry for testing
    _G.mock_registry = {
        logger = function() return {
            info = function() end,
            debug = function() end,
            warn = function() end,
            error = function() end
        } end,
        eventBus = function() return {
            publish = function() end
        } end
    }
end

--- Test facility creation
function test_facility.test_facility_creation()
    local facility = Facility:new("test_lab", "Test Laboratory", 2, 2, {
        research_points = 15,
        scientist_capacity = 5
    }, {
        "research",
        "power_supply"
    })

    test_framework.assert_equal(facility.id, "test_lab", "Facility ID should be set correctly")
    test_framework.assert_equal(facility.name, "Test Laboratory", "Facility name should be set correctly")
    test_framework.assert_equal(facility.width, 2, "Facility width should be set correctly")
    test_framework.assert_equal(facility.height, 2, "Facility height should be set correctly")
    test_framework.assert_equal(facility.capacities.research_points, 15, "Facility capacities should be set correctly")
    test_framework.assert_equal(facility.services[1], "research", "Facility services should be set correctly")
    test_framework.assert_equal(facility.status, Facility.STATUS_CONSTRUCTING, "Facility should start in constructing status")
    test_framework.assert_equal(facility.health, 100, "Facility should start with full health")
end

--- Test facility operational status
function test_facility.test_facility_operational_status()
    local facility = Facility:new(_G.mock_registry, "test_facility", {x = 1, y = 1})

    -- Initially operational
    test_framework.assert_true(facility:isOperational(), "New facility should be operational")

    -- Complete construction
    facility:completeConstruction()
    assert(facility.status == Facility.STATUS_OPERATIONAL, "Facility should be operational after construction")

    -- Test connectivity requirements
    facility.power_connected = true
    facility.access_connected = true
    assert(facility:isOperational(), "Facility should be operational with power and access")

    facility.power_connected = false
    assert(not facility:isOperational(), "Facility should not be operational without power")

    facility.power_connected = true
    facility.access_connected = false
    assert(not facility:isOperational(), "Facility should not be operational without access")
end

--- Test facility damage system
function test_facility.test_facility_damage_system()
    local facility = Facility:new("test_facility", "Test Facility", 1, 1)
    facility:completeConstruction()

    local initial_health = facility.health

    -- Apply damage
    local damage_dealt = facility:takeDamage(25, "combat", {attacker = "alien"})
    assert(damage_dealt == 25, "Damage should be applied correctly")
    assert(facility.health == initial_health - 25, "Health should be reduced by damage amount")

    -- Check damage log
    assert(#facility.damage_log == 1, "Damage should be logged")
    assert(facility.damage_log[1].damage_taken == 25, "Damage amount should be logged")
    assert(facility.damage_log[1].damage_type == "combat", "Damage type should be logged")

    -- Test armor reduction
    facility.armor = 10
    local armored_damage = facility:takeDamage(20, "combat")
    assert(armored_damage == 10, "Armor should reduce damage (20-10=10)")
    assert(facility.health == initial_health - 35, "Health should reflect armored damage")
end

--- Test facility repair system
function test_facility.test_facility_repair_system()
    local facility = Facility:new("test_facility", "Test Facility", 1, 1)
    facility:completeConstruction()

    -- Damage facility
    facility:takeDamage(50)
    local damaged_health = facility.health

    -- Repair facility
    local repair_amount = facility:repair(25, "maintenance")
    assert(repair_amount == 25, "Repair should restore health")
    assert(facility.health == damaged_health + 25, "Health should increase by repair amount")

    -- Check repair log
    assert(#facility.damage_log == 2, "Repair should be logged")
    assert(facility.damage_log[2].damage_taken == -25, "Repair should be logged as negative damage")
end

--- Test facility capacity contributions
function test_facility.test_facility_capacity_contributions()
    local facility = Facility:new("test_facility", "Test Facility", 1, 1, {
        research_points = 20,
        item_storage = 100
    })

    -- Not operational - no capacity contribution
    local capacities = facility:getEffectiveCapacities()
    assert(next(capacities) == nil, "Non-operational facility should contribute no capacity")

    -- Complete construction and connect
    facility:completeConstruction()
    facility.power_connected = true
    facility.access_connected = true

    capacities = facility:getEffectiveCapacities()
    assert(capacities.research_points == 20, "Operational facility should contribute full capacity")
    assert(capacities.item_storage == 100, "Operational facility should contribute all capacities")

    -- Damage facility - reduced capacity
    facility:takeDamage(50) -- 50% health
    capacities = facility:getEffectiveCapacities()
    assert(capacities.research_points == 10, "Damaged facility should contribute reduced capacity (50%)")
    assert(capacities.item_storage == 50, "Damaged facility should contribute reduced capacity for all types")
end

--- Test facility serialization
function test_facility.test_facility_serialization()
    local facility = Facility:new("test_facility", "Test Facility", 2, 3, {
        research_points = 15
    }, {"research"})

    facility.x = 5
    facility.y = 10
    facility.base_id = "test_base"
    facility:takeDamage(25)

    -- Serialize
    local serialized = facility:serialize()
    assert(serialized.id == "test_facility", "Serialized data should contain facility ID")
    assert(serialized.health == 75, "Serialized data should contain current health")
    assert(serialized.damage_log and #serialized.damage_log == 1, "Serialized data should contain damage log")

    -- Deserialize
    local deserialized = Facility.deserialize(serialized)
    assert(deserialized.id == "test_facility", "Deserialized facility should have correct ID")
    assert(deserialized.health == 75, "Deserialized facility should have correct health")
    assert(deserialized.x == 5, "Deserialized facility should have correct position")
    assert(deserialized.y == 10, "Deserialized facility should have correct position")
end

--- Test facility status information
function test_facility.test_facility_status()
    local facility = Facility:new("test_facility", "Test Facility", 2, 2, {
        research_points = 15
    }, {"research"})

    facility:completeConstruction()
    facility.power_connected = true
    facility.access_connected = true
    facility.x = 3
    facility.y = 4
    facility.base_id = "test_base"

    local status = facility:getStatus()
    assert(status.id == "test_facility", "Status should contain facility ID")
    assert(status.operational == true, "Status should indicate operational state")
    assert(status.health == 100, "Status should contain current health")
    assert(status.position.x == 3, "Status should contain position")
    assert(status.position.y == 4, "Status should contain position")
    assert(status.capacities.research_points == 15, "Status should contain effective capacities")
end

return test_facility