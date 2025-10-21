#!/usr/bin/env lua
---verify_modules.lua - Verify all TASK-029 modules load correctly
---
---Quick verification that all deployment system modules can be loaded
---and don't have syntax errors or missing dependencies
---
---Run from project root: lua verify_modules.lua

package.path = package.path .. ";engine/?.lua;engine/?/?.lua"

print("\n" .. string.rep("=", 60))
print("TASK-029 MODULE VERIFICATION")
print(string.rep("=", 60) .. "\n")

-- Test data for counting keys
function table.countKeys(t)
    if not t then return 0 end
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

-- Mock Love2D if needed
if not love then
    love = {graphics = {}, audio = {}}
end

local modules = {
    {name = "deployment_config", path = "battlescape.logic.deployment_config"},
    {name = "landing_zone", path = "battlescape.logic.landing_zone"},
    {name = "mapblock_metadata", path = "battlescape.map.mapblock_metadata"},
    {name = "landing_zone_selector", path = "battlescape.logic.landing_zone_selector"},
    {name = "deployment_validator", path = "battlescape.logic.deployment_validator"},
    {name = "deployment_scene", path = "battlescape.scenes.deployment_scene"},
}

local passed = 0
local failed = 0

for i, module in ipairs(modules) do
    local status = "✓"
    local success = true
    local error_msg = nil
    
    -- Try to load the module
    local result, err = pcall(function()
        require(module.path)
    end)
    
    if not result then
        status = "✗"
        success = false
        error_msg = err or "Unknown error"
        failed = failed + 1
    else
        passed = passed + 1
    end
    
    print(string.format("%s %2d. %-30s", status, i, module.name))
    
    if not success then
        print(string.format("      Error: %s", tostring(error_msg or "Unknown")))
    end
end

print("\n" .. string.rep("=", 60))
print(string.format("Results: %d passed, %d failed", passed, failed))
print(string.rep("=", 60) .. "\n")

if failed == 0 then
    print("✓ ALL MODULES VERIFIED - Ready for use!")
    os.exit(0)
else
    print("✗ VERIFICATION FAILED - Check errors above")
    os.exit(1)
end
