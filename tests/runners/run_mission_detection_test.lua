--[[
    Test Runner for Mission Detection System
    Run with: lovec "engine" run_mission_detection_test.lua
]]

-- Set up module paths
local enginePath = arg[1] or "engine"
package.path = enginePath .. "/?.lua;" .. enginePath .. "/?/init.lua;" .. package.path

-- Run the tests
require("tests.geoscape.test_mission_detection")






















