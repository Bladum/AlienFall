#!/usr/bin/env lua
--- Main Test Runner for Alien Fall
--
-- Runs all test suites and provides a summary.
-- Usage: love . --test (from Love2D) or lua test_runner_main.lua (standalone)
--
-- @module test.test_runner_main

local test_runner = require "test.test_runner"

-- Run all tests
local success = test_runner.run_all()

-- Print final summary
print("\n" .. string.rep("=", 50))
if success then
    print("ALL TESTS PASSED")
else
    print("SOME TESTS FAILED")
    print("Check the output above for failure details.")
end
print(string.rep("=", 50))

-- Exit with appropriate code for CI/CD
if success then
    os.exit(0)
else
    os.exit(1)
end