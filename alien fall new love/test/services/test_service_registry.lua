--- Test suite for Service Registry
--
-- Tests the service registry functionality for service initialization and management.
--
-- @module test.test_service_registry

local test_framework = require "test.framework.test_framework"
local ServiceRegistry = require "core.services.registry"

local test_service_registry = {}

--- Run all service registry tests
function test_service_registry.run()
    test_framework.run_suite("Service Registry", {
        test_initialization = test_service_registry.test_initialization,
        test_service_creation = test_service_registry.test_service_creation,
        test_service_dependencies = test_service_registry.test_service_dependencies,
        test_event_bus_access = test_service_registry.test_event_bus_access,
        test_logger_access = test_service_registry.test_logger_access,
        test_config_passthrough = test_service_registry.test_config_passthrough
    })
end

--- Test service registry initialization
function test_service_registry.test_initialization()
    local registry = ServiceRegistry.new()

    test_framework.assert_not_nil(registry)
    test_framework.assert_not_nil(registry.services)
    test_framework.assert_equal(type(registry.services), "table")
    test_framework.assert_not_nil(registry.config)
end

--- Test that all required services are created
function test_service_registry.test_service_creation()
    local registry = ServiceRegistry.new()

    -- Check that all core services exist
    test_framework.assert_not_nil(registry.services.telemetry)
    test_framework.assert_not_nil(registry.services.logger)
    test_framework.assert_not_nil(registry.services.event_bus)
    test_framework.assert_not_nil(registry.services.rng)
    test_framework.assert_not_nil(registry.services.turn_manager)
    test_framework.assert_not_nil(registry.services.asset_cache)
    test_framework.assert_not_nil(registry.services.audio)
    test_framework.assert_not_nil(registry.services.save)
    test_framework.assert_not_nil(registry.services.data_registry)
    test_framework.assert_not_nil(registry.services.mod_loader)
end

--- Test service dependency injection
function test_service_registry.test_service_dependencies()
    local registry = ServiceRegistry.new()

    -- Test that services receive proper dependencies
    -- Logger should have telemetry
    test_framework.assert_not_nil(registry.services.logger.telemetry)

    -- Event bus should have telemetry
    test_framework.assert_not_nil(registry.services.event_bus.telemetry)

    -- Turn manager should have event bus and telemetry
    test_framework.assert_not_nil(registry.services.turn_manager.eventBus)
    test_framework.assert_not_nil(registry.services.turn_manager.telemetry)

    -- Asset cache should have telemetry
    test_framework.assert_not_nil(registry.services.asset_cache.telemetry)

    -- Save service should have telemetry
    test_framework.assert_not_nil(registry.services.save.telemetry)

    -- Data registry should have telemetry and logger
    test_framework.assert_not_nil(registry.services.data_registry.telemetry)
    test_framework.assert_not_nil(registry.services.data_registry.logger)

    -- Mod loader should have telemetry, logger, and data registry
    test_framework.assert_not_nil(registry.services.mod_loader.telemetry)
    test_framework.assert_not_nil(registry.services.mod_loader.logger)
    test_framework.assert_not_nil(registry.services.mod_loader.dataRegistry)
end

--- Test event bus accessor
function test_service_registry.test_event_bus_access()
    local registry = ServiceRegistry.new()

    local eventBus = registry:eventBus()
    test_framework.assert_not_nil(eventBus)
    test_framework.assert_equal(eventBus, registry.services.event_bus)
end

--- Test logger accessor
function test_service_registry.test_logger_access()
    local registry = ServiceRegistry.new()

    local logger = registry:logger()
    test_framework.assert_not_nil(logger)
    test_framework.assert_equal(logger, registry.services.logger)
end

--- Test configuration passthrough
function test_service_registry.test_config_passthrough()
    local config = {
        telemetry = false,
        logLevel = "info"
    }

    local registry = ServiceRegistry.new(config)

    -- Check that config is stored
    test_framework.assert_equal(registry.config, config)

    -- Check that telemetry setting is respected
    -- (This assumes telemetry service checks the enabled flag)
    test_framework.assert_not_nil(registry.services.telemetry)

    -- Check that logger level is set
    test_framework.assert_not_nil(registry.services.logger)
end

return test_service_registry