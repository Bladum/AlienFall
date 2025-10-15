--- Main test entry point
--- This file is loaded by Love2D to run all tests

-- Modify package.path to include parent directory
package.path = package.path .. ";../?.lua;../?/init.lua"

-- Load the test runner
require("tests.run_tests")






















