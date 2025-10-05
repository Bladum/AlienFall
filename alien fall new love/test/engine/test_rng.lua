--- Test suite for RNG Service
--
-- Tests the RngService functionality for seeded randomness and deterministic behavior.
--
-- @module test.engine.test_rng

local test_framework = require "test.framework.test_framework"
local RngService = require "engine.rng"

local test_rng = {}

--- Run all RNG tests
function test_rng.run()
    test_framework.run_suite("RNG Service", {
        test_initialization = test_rng.test_initialization,
        test_seeding = test_rng.test_seeding,
        test_scope_creation = test_rng.test_scope_creation,
        test_deterministic_behavior = test_rng.test_deterministic_behavior,
        test_random_methods = test_rng.test_random_methods,
        test_shuffle_functionality = test_rng.test_shuffle_functionality,
        test_scope_reset = test_rng.test_scope_reset,
        test_custom_seed_override = test_rng.test_custom_seed_override,
        test_context_scopes = test_rng.test_context_scopes,
        test_telemetry_integration = test_rng.test_telemetry_integration
    })
end

--- Test RngService initialization
function test_rng.test_initialization()
    local rng = RngService.new()

    test_framework.assert_not_nil(rng)
    test_framework.assert_not_nil(rng.scopes)
    test_framework.assert_equal(type(rng.scopes), "table")
    test_framework.assert_equal(rng.baseSeed, 1337) -- DEFAULT_SEED
    test_framework.assert_nil(rng.telemetry)

    -- Test with telemetry
    local mockTelemetry = {}
    local rngWithTelemetry = RngService.new({telemetry = mockTelemetry})
    test_framework.assert_equal(rngWithTelemetry.telemetry, mockTelemetry)
end

--- Test seeding functionality
function test_rng.test_seeding()
    local rng = RngService.new()

    -- Test initial seed
    test_framework.assert_equal(rng.baseSeed, 1337)

    -- Test setting new seed
    rng:seed(42)
    test_framework.assert_equal(rng.baseSeed, 42)

    -- Test that scopes are cleared on reseed
    local scope1 = rng:requestScope("test")
    test_framework.assert_not_nil(scope1)

    rng:seed(123)
    test_framework.assert_equal(rng.baseSeed, 123)
    -- Scopes should be cleared
    test_framework.assert_equal(type(rng.scopes), "table")
end

--- Test scope creation and retrieval
function test_rng.test_scope_creation()
    local rng = RngService.new()

    -- Test creating a new scope
    local scope1 = rng:requestScope("combat")
    test_framework.assert_not_nil(scope1)
    test_framework.assert_equal(type(scope1), "table")
    test_framework.assert_equal(type(scope1.random), "function")

    -- Test retrieving existing scope
    local scope2 = rng:requestScope("combat")
    test_framework.assert_equal(scope1, scope2)

    -- Test different scopes are separate
    local scope3 = rng:requestScope("worldgen")
    test_framework.assert_not_equal(scope1, scope3)
end

--- Test deterministic behavior with same seeds
function test_rng.test_deterministic_behavior()
    local rng1 = RngService.new()
    rng1:seed(12345)

    local rng2 = RngService.new()
    rng2:seed(12345)

    -- Both should produce same sequence
    local scope1 = rng1:requestScope("test")
    local scope2 = rng2:requestScope("test")

    local val1a = scope1:random()
    local val2a = scope2:random()
    test_framework.assert_equal(val1a, val2a)

    local val1b = scope1:random(1, 10)
    local val2b = scope2:random(1, 10)
    test_framework.assert_equal(val1b, val2b)

    local val1c = scope1:randomFloat()
    local val2c = scope2:randomFloat()
    test_framework.assert_equal(val1c, val2c)
end

--- Test random number generation methods
function test_rng.test_random_methods()
    local rng = RngService.new()
    rng:seed(999)
    local scope = rng:requestScope("test")

    -- Test random() with no args (0-1)
    local val1 = scope:random()
    test_framework.assert_true(val1 >= 0 and val1 < 1)

    -- Test random(max) (1-max)
    local val2 = scope:random(10)
    test_framework.assert_true(val2 >= 1 and val2 <= 10)
    test_framework.assert_equal(math.floor(val2), val2) -- Should be integer

    -- Test random(min, max)
    local val3 = scope:random(5, 15)
    test_framework.assert_true(val3 >= 5 and val3 <= 15)
    test_framework.assert_equal(math.floor(val3), val3) -- Should be integer

    -- Test randomFloat() (0-1)
    local val4 = scope:randomFloat()
    test_framework.assert_true(val4 >= 0 and val4 < 1)

    -- Test randomRange(min, max) - float range
    local val5 = scope:randomRange(10.5, 20.7)
    test_framework.assert_true(val5 >= 10.5 and val5 <= 20.7)
end

--- Test shuffle functionality
function test_rng.test_shuffle_functionality()
    local rng = RngService.new()
    rng:seed(777)
    local scope = rng:requestScope("shuffle_test")

    -- Test shuffle with array
    local original = {1, 2, 3, 4, 5}
    local shuffled = {1, 2, 3, 4, 5}
    scope:shuffle(shuffled)

    -- Check that all elements are present
    test_framework.assert_equal(#shuffled, 5)
    for i = 1, 5 do
        local found = false
        for j = 1, 5 do
            if shuffled[j] == i then
                found = true
                break
            end
        end
        test_framework.assert_true(found, "Element " .. i .. " should be present")
    end

    -- Test deterministic shuffle
    local rng2 = RngService.new()
    rng2:seed(777)
    local scope2 = rng2:requestScope("shuffle_test")
    local shuffled2 = {1, 2, 3, 4, 5}
    scope2:shuffle(shuffled2)

    -- Should produce same shuffle
    for i = 1, 5 do
        test_framework.assert_equal(shuffled[i], shuffled2[i])
    end
end

--- Test scope reset functionality
function test_rng.test_scope_reset()
    local rng = RngService.new()
    rng:seed(555)

    -- Create scope and generate some values
    local scope1 = rng:requestScope("reset_test")
    local val1 = scope1:random()

    -- Request same scope again (should be same)
    local scope2 = rng:requestScope("reset_test")
    local val2 = scope2:random()
    test_framework.assert_not_equal(val1, val2) -- Different values from same sequence

    -- Reset scope
    local scope3 = rng:requestScope("reset_test", {reset = true})
    local val3 = scope3:random()
    test_framework.assert_equal(val1, val3) -- Should restart sequence
end

--- Test custom seed override
function test_rng.test_custom_seed_override()
    local rng = RngService.new()
    rng:seed(1000)

    -- Create scope with custom seed
    local scope1 = rng:requestScope("custom_seed", {seed = 42})
    local val1 = scope1:random()

    -- Create another scope with same custom seed
    local scope2 = rng:requestScope("custom_seed2", {seed = 42})
    local val2 = scope2:random()

    -- Should produce same value
    test_framework.assert_equal(val1, val2)

    -- Check that custom seed is returned by getSeed
    local seed1 = rng:getSeed("custom_seed")
    test_framework.assert_equal(seed1, 42)
end

--- Test context scopes
function test_rng.test_context_scopes()
    local rng = RngService.new()
    rng:seed(2000)

    -- Test scopes with different contexts are separate
    local scope1 = rng:requestScope("battle", {context = "player1"})
    local scope2 = rng:requestScope("battle", {context = "player2"})
    local scope3 = rng:requestScope("battle") -- No context

    local val1 = scope1:random()
    local val2 = scope2:random()
    local val3 = scope3:random()

    -- All should be different
    test_framework.assert_not_equal(val1, val2)
    test_framework.assert_not_equal(val1, val3)
    test_framework.assert_not_equal(val2, val3)

    -- Test getSeed with context
    local seed1 = rng:getSeed("battle", {context = "player1"})
    local seed2 = rng:getSeed("battle", {context = "player2"})
    test_framework.assert_not_nil(seed1)
    test_framework.assert_not_nil(seed2)
    test_framework.assert_not_equal(seed1, seed2)
end

--- Test telemetry integration
function test_rng.test_telemetry_integration()
    local events = {}
    local mockTelemetry = {
        recordEvent = function(self, event)
            table.insert(events, event)
        end
    }

    local rng = RngService.new({telemetry = mockTelemetry})
    rng:seed(3000)

    -- Clear any seeding events
    events = {}

    -- Test scope creation records event
    local scope = rng:requestScope("telemetry_test")
    test_framework.assert_true(#events >= 1)
    local scopeEvent = events[#events]
    test_framework.assert_equal(scopeEvent.type, "rng-scope")
    test_framework.assert_equal(scopeEvent.scope, "telemetry_test")

    -- Clear events
    events = {}

    -- Test random calls record events
    scope:random()
    test_framework.assert_equal(#events, 1)
    test_framework.assert_equal(events[1].type, "rng")
    test_framework.assert_equal(events[1].scope, "telemetry_test")

    -- Test shuffle records event
    events = {}
    scope:shuffle({1, 2, 3})
    test_framework.assert_equal(#events, 1)
    test_framework.assert_equal(events[1].type, "rng-shuffle")
    test_framework.assert_equal(events[1].scope, "telemetry_test")
    test_framework.assert_equal(events[1].size, 3)
end

return test_rng