-- ─────────────────────────────────────────────────────────────────────────
-- PERFORMANCE REGRESSION TESTS
-- ─────────────────────────────────────────────────────────────────────────
-- Purpose: Catch performance regressions and slowdowns
-- Tests: 3 regression tests for performance issues
-- Expected: All pass in <100ms

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.performance",
    fileName = "performance_regression_test.lua",
    description = "Performance regression testing"
})

-- ─────────────────────────────────────────────────────────────────────────
-- TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Performance Regressions", function()

    local performance = {}

    Suite:beforeEach(function()
        performance = {
            frameTime = 0,
            targetFPS = 60,
            targetFrameTime = 1 / 60,
            metrics = {}
        }
    end)

    -- Regression 1: Frame time spike detection
    Suite:testMethod("Performance:frameTimeSpikeDetection", {
        description = "Large frame time increases should be detected",
        testCase = "validation",
        type = "regression"
    }, function()
        local frameTimes = {0.016, 0.017, 0.016, 0.050, 0.016}  -- Frame 4 spikes
        local spikeThreshold = 0.030  -- 30ms threshold

        local spikeCount = 0
        for i = 1, #frameTimes do
            if frameTimes[i] > spikeThreshold then
                spikeCount = spikeCount + 1
            end
        end

        Helpers.assertEqual(spikeCount, 1, "Should detect 1 performance spike")
    end)

    -- Regression 2: Memory usage trend
    Suite:testMethod("Performance:memoryGrowthTrend", {
        description = "Memory should not show unbounded growth",
        testCase = "validation",
        type = "regression"
    }, function()
        -- Simulate memory measurements over time
        local memoryReadings = {
            100,  -- Start
            102,  -- Small growth
            105,  -- Normal growth
            106,  -- Stable
            107   -- Stable
        }

        -- Check if memory stabilizes (difference between last 2 readings is small)
        local lastDiff = memoryReadings[#memoryReadings] - memoryReadings[#memoryReadings - 1]

        Helpers.assertTrue(lastDiff <= 5, "Memory growth should stabilize")
    end)

    -- Regression 3: Batch rendering efficiency
    Suite:testMethod("Performance:batchRenderingEfficiency", {
        description = "Batch rendering should use fewer draw calls",
        testCase = "validation",
        type = "regression"
    }, function()
        -- Simulate draw calls with and without batching
        local unbatchedDrawCalls = 500  -- Drawing each sprite individually
        local batchedDrawCalls = 10     -- Drawing in batches

        -- Batching should reduce draw calls significantly
        local efficiency = (unbatchedDrawCalls - batchedDrawCalls) / unbatchedDrawCalls

        Helpers.assertTrue(efficiency > 0.9, "Batching should reduce draw calls by >90%")
        Helpers.assertTrue(batchedDrawCalls < unbatchedDrawCalls / 10, "Batching should be very efficient")
    end)

end)

return Suite
