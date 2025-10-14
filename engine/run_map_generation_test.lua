-- Test Runner for Map Generation Pipeline
-- Run this with: lovec engine -test map_generation

-- Add engine to package path
package.path = package.path .. ";engine/?.lua"

-- Load test module
local TestMapGeneration = require("battlescape.tests.test_map_generation")

-- Run tests
print("\n")
print(string.rep("=", 50))
print("MAP GENERATION PIPELINE TEST RUNNER")
print(string.rep("=", 50))
print("\n")

local success = TestMapGeneration.runAll()

if success then
    print("\n✓ All tests passed!")
    os.exit(0)
else
    print("\n✗ Some tests failed")
    os.exit(1)
end
