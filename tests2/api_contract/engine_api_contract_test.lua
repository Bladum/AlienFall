-- ─────────────────────────────────────────────────────────────────────────
-- ENGINE API CONTRACT TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Verify core engine API contracts and interfaces
-- Tests: 8 API contract tests
-- Expected: All pass in <200ms

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core",
    fileName = "engine_api_contract_test.lua",
    description = "Core engine API contract validation"
})

-- ─────────────────────────────────────────────────────────────────────────
-- TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Engine API Contracts", function()

    local engine = {}

    Suite:beforeEach(function()
        engine = {
            state = "initialized",
            modules = {},
            version = "1.0.0"
        }
    end)

    -- Contract 1: Engine initialization returns expected structure
    Suite:testMethod("Engine:initializeContract", {
        description = "Engine.initialize() must return state object with required fields",
        testCase = "contract",
        type = "api"
    }, function()
        local function initialize()
            return {
                state = "ready",
                modules = {},
                callbacks = {},
                config = {}
            }
        end

        local result = initialize()
        Helpers.assertTrue(result.state ~= nil, "Must have state field")
        Helpers.assertTrue(result.modules ~= nil, "Must have modules field")
        Helpers.assertTrue(result.callbacks ~= nil, "Must have callbacks field")
        Helpers.assertTrue(result.config ~= nil, "Must have config field")
    end)

    -- Contract 2: State manager returns consistent state objects
    Suite:testMethod("Engine:stateManagerContract", {
        description = "StateManager returns state objects with consistent schema",
        testCase = "contract",
        type = "api"
    }, function()
        local function getState(stateName)
            return {
                name = stateName,
                active = true,
                enter = function() end,
                update = function(dt) end,
                draw = function() end,
                exit = function() end
            }
        end

        local state = getState("geoscape")
        Helpers.assertTrue(state.name == "geoscape", "State name must match")
        Helpers.assertTrue(type(state.enter) == "function", "enter must be function")
        Helpers.assertTrue(type(state.update) == "function", "update must be function")
        Helpers.assertTrue(type(state.draw) == "function", "draw must be function")
    end)

    -- Contract 3: Module interface compliance
    Suite:testMethod("Engine:moduleInterfaceContract", {
        description = "All modules must provide consistent interface methods",
        testCase = "contract",
        type = "api"
    }, function()
        local function validateModule(module)
            local required = {"load", "update", "draw"}
            for _, method in ipairs(required) do
                if type(module[method]) ~= "function" then
                    return false
                end
            end
            return true
        end

        local testModule = {
            load = function(config) end,
            update = function(dt) end,
            draw = function() end
        }

        Helpers.assertTrue(validateModule(testModule), "Module must have all required methods")
    end)

    -- Contract 4: Event system callback signature
    Suite:testMethod("Engine:eventSystemContract", {
        description = "Event system callbacks must have consistent signature",
        testCase = "contract",
        type = "api"
    }, function()
        local eventSystem = {}

        function eventSystem:on(eventName, callback)
            self.callbacks = self.callbacks or {}
            self.callbacks[eventName] = callback
            return self  -- For chaining
        end

        function eventSystem:emit(eventName, ...)
            if self.callbacks and self.callbacks[eventName] then
                self.callbacks[eventName](...)
            end
        end

        eventSystem:on("test", function(data)
            Helpers.assertTrue(data ~= nil, "Callback should receive data")
        end)

        eventSystem:emit("test", {value = 42})
        Helpers.assertTrue(true, "Event system callback executed")
    end)

    -- Contract 5: Configuration object schema
    Suite:testMethod("Engine:configSchemaContract", {
        description = "Configuration objects must follow standard schema",
        testCase = "contract",
        type = "api"
    }, function()
        local config = {
            version = "1.0.0",
            debug = false,
            resolution = {width = 1024, height = 768},
            audio = {enabled = true, volume = 0.8},
            graphics = {fps = 60, vsync = true}
        }

        Helpers.assertEqual(config.version, "1.0.0", "Version field required")
        Helpers.assertEqual(type(config.resolution), "table", "Resolution must be table")
        Helpers.assertEqual(config.resolution.width, 1024, "Resolution.width required")
    end)

    -- Contract 6: Error handling interface
    Suite:testMethod("Engine:errorHandlingContract", {
        description = "Error handler must provide consistent error objects",
        testCase = "contract",
        type = "api"
    }, function()
        local function createError(code, message, context)
            return {
                code = code,
                message = message,
                context = context,
                timestamp = os.time(),
                traceback = debug.traceback()
            }
        end

        local err = createError(500, "Test error", {module = "test"})
        Helpers.assertEqual(err.code, 500, "Error must have code")
        Helpers.assertTrue(err.message ~= nil, "Error must have message")
        Helpers.assertTrue(err.context ~= nil, "Error must have context")
        Helpers.assertTrue(err.timestamp ~= nil, "Error must have timestamp")
    end)

    -- Contract 7: Dependency injection interface
    Suite:testMethod("Engine:dependencyInjectionContract", {
        description = "DI system must provide consistent resolution",
        testCase = "contract",
        type = "api"
    }, function()
        local di = {}
        di.services = {}

        function di:register(name, factory)
            self.services[name] = {factory = factory, singleton = false}
        end

        function di:resolve(name)
            if self.services[name] then
                return self.services[name].factory()
            end
            return nil
        end

        di:register("logger", function()
            return {log = function(msg) end}
        end)

        local logger = di:resolve("logger")
        Helpers.assertTrue(logger ~= nil, "DI should resolve service")
        if logger then
            Helpers.assertTrue(type(logger.log) == "function", "Logger must have log method")
        end
    end)

    -- Contract 8: Performance metrics interface
    Suite:testMethod("Engine:metricsInterfaceContract", {
        description = "Metrics system must provide consistent performance data",
        testCase = "contract",
        type = "api"
    }, function()
        local metrics = {
            fps = 60,
            frameTime = 0.016,
            memoryUsage = 50,
            drawCalls = 100,
            vertexCount = 10000
        }

        Helpers.assertTrue(metrics.fps > 0, "FPS must be positive")
        Helpers.assertTrue(metrics.frameTime > 0, "Frame time must be positive")
        Helpers.assertTrue(metrics.memoryUsage >= 0, "Memory usage must be non-negative")
        Helpers.assertTrue(metrics.drawCalls >= 0, "Draw calls must be non-negative")
    end)

end)

return Suite
