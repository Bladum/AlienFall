--- Test suite for basescape.BaseManager class
-- @module test.basescape.test_base_manager

local test_framework = require "test.framework.test_framework"
local BaseManager = require 'basescape.BaseManager'

local test_base_manager = {}

--- Run all BaseManager tests
function test_base_manager.run()
    test_framework.run_suite("BaseManager", {
        test_base_manager_creation = test_base_manager.test_base_manager_creation,
        test_facility_placement = test_base_manager.test_facility_placement,
        test_facility_removal = test_base_manager.test_facility_removal,
        test_base_operations = test_base_manager.test_base_operations
    })
end

--- Setup function run before each test
function test_base_manager.setup()
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

--- Test base manager creation and initialization
function test_base_manager.test_base_manager_creation()
    local base_manager = BaseManager:new(_G.mock_registry, "test_base", "test_province", 10, 10)

    test_framework.assert_equal(base_manager.base_id, "test_base", "Base manager should have correct base ID")
    test_framework.assert_equal(base_manager.province_id, "test_province", "Base manager should have correct province ID")
    test_framework.assert_equal(base_manager.grid_width, 10, "Base manager should have correct grid width")
    test_framework.assert_equal(base_manager.grid_height, 10, "Base manager should have correct grid height")
    test_framework.assert_not_nil(base_manager.facilities, "Base manager should have facilities table")
    test_framework.assert_not_nil(base_manager.facility_grid, "Base manager should have facility grid")
end

--- Test facility placement and grid management
function test_base_manager.test_facility_placement()
    local base_manager = BaseManager:new(_G.mock_registry, "test_base", "test_province", 10, 10)

    -- Mock the access check to always return true for testing
    base_manager._canPlaceFacility = function() return true end

    -- Create a mock facility
    local mock_facility = {
        id = "test_workshop",
        name = "Test Workshop",
        width = 2,
        height = 2,
        services = {"manufacturing"},
        health = 100
    }

    -- Place facility
    local success, error_msg = base_manager:addFacility(mock_facility, 1, 1)
    test_framework.assert_true(success, "Facility placement should succeed: " .. (error_msg or ""))

    -- Check facility is in grid
    test_framework.assert_equal(base_manager.facility_grid[1][1], "test_workshop", "Facility should be placed in grid")
    test_framework.assert_equal(base_manager.facilities["test_workshop"], mock_facility, "Facility should be tracked in facilities table")
end

--- Test facility removal
function test_base_manager.test_facility_removal()
    local base_manager = BaseManager:new(_G.mock_registry, "test_base", "test_province", 10, 10)

    -- Mock the access check
    base_manager._canPlaceFacility = function() return true end

    -- Place a facility first
    local mock_facility = {
        id = "test_workshop",
        name = "Test Workshop",
        width = 2,
        height = 2,
        services = {"manufacturing"},
        health = 100
    }

    base_manager:addFacility(mock_facility, 1, 1)

    -- Remove facility
    local success = base_manager:removeFacility("test_workshop")
    test_framework.assert_true(success, "Facility removal should succeed")

    -- Check facility is no longer in grid
    test_framework.assert_nil(base_manager.facility_grid[1][1], "Facility should be removed from grid")

    -- Check facility is no longer tracked
    test_framework.assert_nil(base_manager.facilities["test_workshop"], "Facility should be removed from facilities table")
end

--- Test base operations and monthly processing
function test_base_manager.test_base_operations()
    local base_manager = BaseManager:new(_G.mock_registry, "test_base", "test_province", 10, 10)

    -- Mock the access check
    base_manager._canPlaceFacility = function() return true end

    -- Add some facilities
    local workshop = {
        id = "workshop_1",
        name = "Workshop",
        width = 2,
        height = 2,
        services = {"manufacturing"},
        health = 100
    }

    base_manager:addFacility(workshop, 1, 1)

    -- Check that facility was added
    test_framework.assert_not_nil(base_manager.facilities["workshop_1"], "Facility should be added")
    test_framework.assert_equal(base_manager.facility_grid[1][1], "workshop_1", "Facility should be in grid")
end

return test_base_manager