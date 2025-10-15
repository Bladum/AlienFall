-- Run Tileset System Test
-- Simple runner for tileset tests

print("[Test Runner] Starting Tileset System Tests...")
print("Working directory: " .. love.filesystem.getWorkingDirectory())
print("Save directory: " .. love.filesystem.getSaveDirectory())

-- Load test
local testModule = require("tests.battlescape.test_tileset_system")

print("\n[Test Runner] Tests completed successfully!")






















