--- Test suite for Logger
--
-- Tests the Logger functionality for different log levels and message formatting.
--
-- @module test.engine.test_logger

local test_framework = require "test.framework.test_framework"
local Logger = require "engine.logger"

local test_logger = {}

--- Run all Logger tests
function test_logger.run()
    test_framework.run_suite("Logger", {
        test_initialization = test_logger.test_initialization,
        test_log_levels = test_logger.test_log_levels,
        test_message_formatting = test_logger.test_message_formatting,
        test_level_filtering = test_logger.test_level_filtering
    })
end

--- Test Logger initialization
function test_logger.test_initialization()
    local logger = Logger.new()

    test_framework.assert_not_nil(logger)
    test_framework.assert_not_nil(logger.level)
    test_framework.assert_nil(logger.telemetry)
end

--- Test different log levels
function test_logger.test_log_levels()
    local logger = Logger.new({level = "trace"}) -- Set to lowest level to see all logs

    -- Test that all log methods exist
    test_framework.assert_equal(type(logger.trace), "function")
    test_framework.assert_equal(type(logger.debug), "function")
    test_framework.assert_equal(type(logger.info), "function")
    test_framework.assert_equal(type(logger.warn), "function")
    test_framework.assert_equal(type(logger.error), "function")
end

--- Test message formatting
function test_logger.test_message_formatting()
    local logger = Logger.new({level = "trace"})

    -- Test basic message formatting (we can't easily capture print output,
    -- but we can test that the methods don't crash)
    logger:info("Test message")
    logger:warn("Warning message", "test_context")
    logger:error("Error message")

    -- Test with context
    logger:debug("Debug with context", "module_name")

    test_framework.assert_true(true) -- If we get here, no crashes occurred
end

--- Test level filtering
function test_logger.test_level_filtering()
    local logger = Logger.new({level = "warn"}) -- Only warn and above

    -- Test level setting
    test_framework.assert_not_nil(logger.level)

    -- Test setLevel method
    logger:setLevel("error")
    test_framework.assert_not_nil(logger.level)

    logger:setLevel("info")
    test_framework.assert_not_nil(logger.level)

    -- Test invalid level (should keep current level)
    local originalLevel = logger.level
    logger:setLevel("invalid")
    test_framework.assert_equal(logger.level, originalLevel)
end

return test_logger