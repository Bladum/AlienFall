#!/usr/bin/env lua
--- Standalone Test Runner for Alien Fall
--
-- Runs Lua tests without Love2D dependencies.
-- Usage: lua run_tests.lua

-- Set up package paths to include src and test directories
package.path = package.path .. ";../src/?.lua;../src/?/init.lua;../test/?.lua;../test/?/init.lua"

-- Import the test runner
local test_runner = require "test_runner"

-- Run all tests
test_runner.run_from_command_line()