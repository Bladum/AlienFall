--- Test suite for basescape.ServiceManager class
-- @module test.basescape.test_service_manager

local test_framework = require "test.framework.test_framework"
local ServiceManager = require 'basescape.ServiceManager'

local test_service_manager = {}

--- Run all ServiceManager tests
function test_service_manager.run()
    test_framework.run_suite("ServiceManager", {
        test_service_manager_creation = test_service_manager.test_service_manager_creation,
        test_provider_registration = test_service_manager.test_provider_registration,
        test_service_dependencies = test_service_manager.test_service_dependencies,
        test_cascading_failures = test_service_manager.test_cascading_failures,
        test_service_restoration = test_service_manager.test_service_restoration,
        test_service_utilization = test_service_manager.test_service_utilization,
        test_service_state_changes = test_service_manager.test_service_state_changes,
        test_service_summary = test_service_manager.test_service_summary
    })
end

--- Setup function run before each test
function test_service_manager.setup()
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

--- Test service manager creation and default services
function test_service_manager.test_service_manager_creation()
    local service_manager = ServiceManager:new(_G.mock_registry, "test_base")

    test_framework.assert_equal(service_manager.base_id, "test_base", "Service manager should have correct base ID")
    test_framework.assert_not_nil(service_manager.providers, "Providers table should be initialized")
    test_framework.assert_not_nil(service_manager.consumers, "Consumers table should be initialized")
    test_framework.assert_not_nil(service_manager.services, "Services table should be initialized")
end

--- Test service provider registration
function test_service_manager.test_service_provider_registration()
    local service_manager = ServiceManager:new(_G.mock_registry, "test_base")

    -- Register a facility as power provider
    local success = service_manager:registerProvider("fusion_reactor", "power_supply", {
        capacity = 200,
        efficiency = 100
    })

    test_framework.assert_true(success, "Provider registration should succeed")
    assert(service_manager.providers.power_supply.fusion_reactor, "Provider should be registered")

    -- Check service availability
    local available, state = service_manager:isServiceAvailable("power_supply")
    assert(available, "Power supply should be available with provider")
    assert(state == ServiceManager.STATE_ONLINE, "Power supply should be online")
end

--- Test service consumer registration
function test_service_manager.test_service_consumer_registration()
    local service_manager = ServiceManager:new(_G.mock_registry, "test_base")

    -- Register a consumer
    local success = service_manager:registerConsumer("laboratory", "power_supply", {
        required_capacity = 50
    })

    assert(success, "Consumer registration should succeed")
    assert(service_manager.consumers.power_supply.laboratory, "Consumer should be registered")
end

--- Test service dependency chains
function test_service_manager.test_service_dependencies()
    local service_manager = ServiceManager:new(_G.mock_registry, "test_base")

    -- Add a custom dependency
    local success = service_manager:addDependency("research", "power_supply", {
        critical = true
    })

    assert(success, "Dependency addition should succeed")
    assert(service_manager.dependency_graph.research.power_supply, "Dependency should be recorded")
    assert(service_manager.reverse_dependencies.power_supply.research, "Reverse dependency should be recorded")
end

--- Test cascading service failures
function test_service_manager.test_cascading_failures()
    local service_manager = ServiceManager:new(_G.mock_registry, "test_base")

    -- Set up dependency chain: research -> power_supply
    service_manager:addDependency("research", "power_supply", {critical = true})

    -- Register providers
    service_manager:registerProvider("fusion_reactor", "power_supply", {capacity = 100})
    service_manager:registerProvider("lab_1", "research", {capacity = 50})

    -- Initially both should be online
    assert(service_manager:isServiceAvailable("power_supply"), "Power supply should be available")
    assert(service_manager:isServiceAvailable("research"), "Research should be available")

    -- Remove power provider - should cause cascading failure
    service_manager:unregisterProvider("fusion_reactor", "power_supply")

    -- Power should go offline
    local power_available = service_manager:isServiceAvailable("power_supply")
    assert(not power_available, "Power supply should be offline without provider")

    -- Research should also go offline due to dependency
    local research_available = service_manager:isServiceAvailable("research")
    assert(not research_available, "Research should cascade offline when power fails")
end

--- Test service restoration
function test_service_manager.test_service_restoration()
    local service_manager = ServiceManager:new(_G.mock_registry, "test_base")

    -- Set up dependency
    service_manager:addDependency("research", "power_supply", {critical = true})

    -- Start with research offline due to missing power
    service_manager:registerProvider("lab_1", "research", {capacity = 50})

    -- Research should be offline
    assert(not service_manager:isServiceAvailable("research"), "Research should be offline without power")

    -- Add power provider
    service_manager:registerProvider("fusion_reactor", "power_supply", {capacity = 100})

    -- Both should now be online
    assert(service_manager:isServiceAvailable("power_supply"), "Power supply should be online")
    assert(service_manager:isServiceAvailable("research"), "Research should be restored when power is restored")
end

--- Test service utilization tracking
function test_service_manager.test_service_utilization()
    local service_manager = ServiceManager:new(_G.mock_registry, "test_base")

    -- Register provider
    service_manager:registerProvider("workshop", "manufacture", {capacity = 100})

    -- Service should start with 0 utilization
    local info = service_manager:getServiceInfo("manufacture")
    assert(info.utilization == 0, "Service should start with 0 utilization")

    -- Note: Actual utilization tracking would be implemented in consumer allocation
    -- This is a placeholder for future implementation
end

--- Test service state changes
function test_service_manager.test_service_state_changes()
    local service_manager = ServiceManager:new(_G.mock_registry, "test_base")

    -- Start with no providers - service offline
    local available, state = service_manager:isServiceAvailable("power_supply")
    assert(not available, "Service should be offline without providers")
    assert(state == ServiceManager.STATE_OFFLINE, "Service state should be offline")

    -- Add provider - service becomes online
    service_manager:registerProvider("fusion_reactor", "power_supply", {capacity = 100})
    available, state = service_manager:isServiceAvailable("power_supply")
    assert(available, "Service should be online with provider")
    assert(state == ServiceManager.STATE_ONLINE, "Service state should be online")
end

--- Test service summary statistics
function test_service_manager.test_service_summary()
    local service_manager = ServiceManager:new(_G.mock_registry, "test_base")

    -- Add some providers
    service_manager:registerProvider("reactor1", "power_supply", {capacity = 100})
    service_manager:registerProvider("reactor2", "power_supply", {capacity = 100})
    service_manager:registerProvider("workshop", "manufacture", {capacity = 50})

    local summary = service_manager:getServiceSummary()
    test_framework.assert_true(summary.total_services > 0, "Should have services")
    test_framework.assert_true(summary.online_services >= 1, "Should have at least power_supply online")
    test_framework.assert_true(summary.total_providers >= 3, "Should count providers")
end

return test_service_manager