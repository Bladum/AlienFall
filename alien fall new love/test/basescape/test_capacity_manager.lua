--- Test suite for basescape.CapacityManager class
-- @module test.basescape.test_capacity_manager

local test_framework = require "test.framework.test_framework"
local CapacityManager = require 'basescape.CapacityManager'

local test_capacity_manager = {}

--- Run all CapacityManager tests
function test_capacity_manager.run()
    test_framework.run_suite("CapacityManager", {
        test_capacity_manager_creation = test_capacity_manager.test_capacity_manager_creation,
        test_capacity_allocation = test_capacity_manager.test_capacity_allocation,
        test_capacity_overflow_policies = test_capacity_manager.test_capacity_overflow_policies,
        test_capacity_reservations = test_capacity_manager.test_capacity_reservations,
        test_facility_capacity_contributions = test_capacity_manager.test_facility_capacity_contributions,
        test_capacity_utilization = test_capacity_manager.test_capacity_utilization,
        test_capacity_checking = test_capacity_manager.test_capacity_checking,
        test_capacity_types = test_capacity_manager.test_capacity_types
    })
end

--- Setup function run before each test
function test_capacity_manager.setup()
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

--- Test capacity manager creation and default capacities
function test_capacity_manager.test_capacity_manager_creation()
    local capacity_manager = CapacityManager:new(_G.mock_registry, "test_base")

    test_framework.assert_equal(capacity_manager.base_id, "test_base", "Capacity manager should have correct base ID")

    -- Check default capacities are initialized
    local capacities = capacity_manager:getCapacityInfo()
    test_framework.assert_not_nil(capacities.item_storage, "Item storage capacity should be initialized")
    test_framework.assert_not_nil(capacities.personnel_quarters, "Personnel quarters capacity should be initialized")
    test_framework.assert_not_nil(capacities.manufacturing_hours, "Manufacturing hours capacity should be initialized")
    test_framework.assert_not_nil(capacities.power_generation, "Power generation capacity should be initialized")
end

--- Test capacity allocation and release
function test_capacity_manager.test_capacity_allocation()
    local capacity_manager = CapacityManager:new(_G.mock_registry, "test_base")

    -- Add custom capacity for testing
    capacity_manager:addCapacity("test_storage", CapacityManager.TYPE_STORAGE, 100, CapacityManager.OVERFLOW_BLOCK)

    -- Allocate capacity
    local success, error_msg, reservation = capacity_manager:allocateCapacity("test_storage", 50, "test_consumer")
    assert(success, "Capacity allocation should succeed")
    assert(reservation, "Should return reservation info")

    -- Check usage
    local info = capacity_manager:getCapacityInfo("test_storage")
    assert(info.used == 50, "Used capacity should be 50")
    assert(info.available == 50, "Available capacity should be 50")

    -- Release capacity
    local released = capacity_manager:releaseCapacity("test_storage", 50, "test_consumer")
    assert(released, "Capacity release should succeed")

    info = capacity_manager:getCapacityInfo("test_storage")
    assert(info.used == 0, "Used capacity should be 0 after release")
    assert(info.available == 100, "Available capacity should be 100 after release")
end

--- Test capacity overflow policies
function test_capacity_manager.test_capacity_overflow_policies()
    local capacity_manager = CapacityManager:new(_G.mock_registry, "test_base")

    -- Test BLOCK policy
    capacity_manager:addCapacity("block_storage", CapacityManager.TYPE_STORAGE, 50, CapacityManager.OVERFLOW_BLOCK)

    -- Allocate up to limit
    local success1 = capacity_manager:allocateCapacity("block_storage", 50, "consumer1")
    assert(success1, "Should allocate up to capacity limit")

    -- Try to exceed limit
    local success2 = capacity_manager:allocateCapacity("block_storage", 10, "consumer2")
    assert(not success2, "Should block allocation exceeding capacity")

    -- Test QUEUE policy (simplified - would need queue implementation)
    capacity_manager:addCapacity("queue_manufacturing", CapacityManager.TYPE_THROUGHPUT, 100, CapacityManager.OVERFLOW_QUEUE)

    -- This would test queue behavior in full implementation
    -- For now, just verify the policy is set
    local info = capacity_manager:getCapacityInfo("queue_manufacturing")
    assert(info.overflow_policy == CapacityManager.OVERFLOW_QUEUE, "Queue policy should be set")
end

--- Test capacity reservations
function test_capacity_manager.test_capacity_reservations()
    local capacity_manager = CapacityManager:new(_G.mock_registry, "test_base")

    capacity_manager:addCapacity("reservable_storage", CapacityManager.TYPE_STORAGE, 100, CapacityManager.OVERFLOW_BLOCK)

    -- Reserve capacity
    local reserved = capacity_manager:reserveCapacity("reservable_storage", 30, "reservation_1")
    assert(reserved, "Capacity reservation should succeed")

    -- Check that reservation reduces available capacity
    local info = capacity_manager:getCapacityInfo("reservable_storage")
    assert(info.available == 70, "Available capacity should be reduced by reservation")
    assert(info.reserved == 30, "Reserved capacity should be tracked")

    -- Release reservation
    local released = capacity_manager:releaseReservation("reservable_storage", "reservation_1")
    assert(released, "Reservation release should succeed")

    info = capacity_manager:getCapacityInfo("reservable_storage")
    assert(info.available == 100, "Available capacity should be restored after reservation release")
    assert(info.reserved == 0, "Reserved capacity should be 0 after release")
end

--- Test facility capacity contributions
function test_capacity_manager.test_facility_capacity_contributions()
    local capacity_manager = CapacityManager:new(_G.mock_registry, "test_base")

    -- Add the engineer capacity first
    capacity_manager:addCapacity("engineer_capacity", CapacityManager.TYPE_SLOTS, 0, CapacityManager.OVERFLOW_BLOCK)

    -- Simulate facility addition
    local mock_facility = {
        id = "test_workshop",
        capacities = {
            manufacturing_hours = 25,
            engineer_capacity = 3
        },
        health = 100, -- Add health property
        isOperational = function() return true end
    }

    capacity_manager:updateFacilityCapacities(mock_facility, "add")

    -- Check that capacities were added
    local manufacturing_info = capacity_manager:getCapacityInfo("manufacturing_hours")
    local engineer_info = capacity_manager:getCapacityInfo("engineer_capacity")

    test_framework.assert_true(manufacturing_info.total >= 25, "Manufacturing capacity should be increased")
    test_framework.assert_true(engineer_info.total >= 3, "Engineer capacity should be increased")

    -- Simulate facility removal
    capacity_manager:updateFacilityCapacities(mock_facility, "remove")

    manufacturing_info = capacity_manager:getCapacityInfo("manufacturing_hours")
    engineer_info = capacity_manager:getCapacityInfo("engineer_capacity")

    test_framework.assert_true(manufacturing_info.total < 25, "Manufacturing capacity should be decreased")
    test_framework.assert_true(engineer_info.total < 3, "Engineer capacity should be decreased")
end

--- Test capacity utilization calculations
function test_capacity_manager.test_capacity_utilization()
    local capacity_manager = CapacityManager:new(_G.mock_registry, "test_base")

    capacity_manager:addCapacity("test_capacity", CapacityManager.TYPE_STORAGE, 200, CapacityManager.OVERFLOW_BLOCK)

    -- Allocate some capacity
    capacity_manager:allocateCapacity("test_capacity", 60, "consumer1")
    capacity_manager:allocateCapacity("test_capacity", 40, "consumer2")

    local info = capacity_manager:getCapacityInfo("test_capacity")
    test_framework.assert_equal(info.used, 100, "Used capacity should be 100")
    test_framework.assert_equal(info.utilization_percent, 50, "Utilization should be 50%")

    -- Test summary - should only include numeric capacities
    local summary = capacity_manager:getCapacitySummary()
    test_framework.assert_true(summary.total_capacities >= 1, "Should have at least the test capacity")
    test_framework.assert_true(summary.average_utilization >= 0, "Should calculate average utilization")
    -- Average should be based on numeric capacities only (not services)
    test_framework.assert_true(summary.average_utilization <= 100, "Average utilization should be valid percentage")
end

--- Test capacity checking
function test_capacity_manager.test_capacity_checking()
    local capacity_manager = CapacityManager:new(_G.mock_registry, "test_base")

    capacity_manager:addCapacity("check_capacity", CapacityManager.TYPE_SLOTS, 10, CapacityManager.OVERFLOW_BLOCK)

    -- Check available capacity
    local available, available_amount, policy = capacity_manager:checkCapacity("check_capacity", 5)
    test_framework.assert_true(available, "Should have capacity available")
    test_framework.assert_equal(available_amount, 10, "Should have full capacity available initially")
    test_framework.assert_equal(policy, nil, "Should not return overflow policy when available")

    -- Allocate some capacity
    capacity_manager:allocateCapacity("check_capacity", 7, "consumer")

    -- Check remaining capacity
    available, available_amount, policy = capacity_manager:checkCapacity("check_capacity", 5)
    test_framework.assert_false(available, "Should not have enough capacity remaining")
    test_framework.assert_equal(available_amount, 3, "Should show remaining available capacity")
    test_framework.assert_equal(policy, CapacityManager.OVERFLOW_BLOCK, "Should return overflow policy when exceeded")
end

--- Test different capacity types
function test_capacity_manager.test_capacity_types()
    local capacity_manager = CapacityManager:new(_G.mock_registry, "test_base")

    -- Test storage type
    capacity_manager:addCapacity("storage_test", CapacityManager.TYPE_STORAGE, 1000, CapacityManager.OVERFLOW_AUTO_SELL)
    local storage_info = capacity_manager:getCapacityInfo("storage_test")
    assert(storage_info.type == CapacityManager.TYPE_STORAGE, "Should identify storage type")

    -- Test slots type
    capacity_manager:addCapacity("slots_test", CapacityManager.TYPE_SLOTS, 50, CapacityManager.OVERFLOW_BLOCK)
    local slots_info = capacity_manager:getCapacityInfo("slots_test")
    assert(slots_info.type == CapacityManager.TYPE_SLOTS, "Should identify slots type")

    -- Test throughput type
    capacity_manager:addCapacity("throughput_test", CapacityManager.TYPE_THROUGHPUT, 200, CapacityManager.OVERFLOW_QUEUE)
    local throughput_info = capacity_manager:getCapacityInfo("throughput_test")
    assert(throughput_info.type == CapacityManager.TYPE_THROUGHPUT, "Should identify throughput type")

    -- Test service type
    capacity_manager:addCapacity("service_test", CapacityManager.TYPE_SERVICE, false, CapacityManager.OVERFLOW_BLOCK)
    local service_info = capacity_manager:getCapacityInfo("service_test")
    assert(service_info.type == CapacityManager.TYPE_SERVICE, "Should identify service type")
end

return test_capacity_manager