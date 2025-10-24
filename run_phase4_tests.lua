#!/usr/bin/env lua
-- Quick test runner for Phase 4

package.path = package.path .. ";?/init.lua"
package.path = package.path .. ";engine/?.lua;engine/?/init.lua"
package.path = package.path .. ";tests/?.lua"

-- Simple mock for missing Love2D functions
if not love then
  love = {}
  love.filesystem = {
    getSaveDirectory = function() return "." end,
    getWorkingDirectory = function() return "." end,
  }
  love.graphics = {
    print = function() end,
  }
  love.timer = {
    getTime = function() return 0 end,
  }
end

-- Load and run tests
local test_results = require("test_phase4_faction_mission_system")

-- Print summary
if test_results.failed == 0 then
  print("\n✅ ALL TESTS PASSED!")
else
  print("\n❌ SOME TESTS FAILED")
end

os.exit(test_results.failed == 0 and 0 or 1)
