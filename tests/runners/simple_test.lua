-- Simple test
print("=== Simple Test ===")
print("Testing Love2D Lua environment...")

-- Test package path
package.path = package.path .. ";engine/?.lua;engine/?/init.lua"
print("Package path updated")

-- Test require
local success, result = pcall(require, "battlescape.data.tilesets")
if success then
    print("Tilesets module loaded successfully")
    local count = result.loadAll("mods/core")
    print("Loaded " .. count .. " tilesets")
else
    print("Error loading tilesets: " .. tostring(result))
end

print("=== Test Complete ===")





















