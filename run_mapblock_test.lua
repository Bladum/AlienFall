-- Test Map Block Loader v2 with TOML and Map Tile KEYs

-- Add engine to package path
package.path = package.path .. ";engine/?.lua;engine/?/init.lua"

print("=== Map Block Loader v2 Test ===\n")

-- Load dependencies
print("[1/4] Loading dependencies...")
local Tilesets = require("battlescape.data.tilesets")
local MapBlockLoader = require("battlescape.map.mapblock_loader_v2")

-- Load tilesets first (required for KEY validation)
print("\n[2/4] Loading tilesets...")
local tilesetCount = Tilesets.loadAll("mods/core")
print(string.format("Loaded %d tilesets", tilesetCount))

-- Load Map Blocks
print("\n[3/4] Loading Map Blocks...")
local blockCount = MapBlockLoader.loadAll("mods/core/mapblocks")
print(string.format("Loaded %d Map Blocks", blockCount))

-- Test functionality
print("\n[4/4] Running tests...\n")

-- Test 1: Get block by ID
print("Test 1: Get block by ID")
local urbanBlock = MapBlockLoader.get("urban_small_01")
if urbanBlock then
    print(string.format("✓ Found block: %s (%s)", urbanBlock.id, urbanBlock.name))
    print(string.format("  Dimensions: %dx%d", urbanBlock.width, urbanBlock.height))
    print(string.format("  Group: %d", urbanBlock.group))
    print(string.format("  Tags: %s", urbanBlock.tags))
    print(string.format("  Tiles: %d occupied", MapBlockLoader.getTileCount(urbanBlock)))
else
    print("✗ Block 'urban_small_01' not found")
end

-- Test 2: Get blocks by group
print("\nTest 2: Get blocks by group")
local group1Blocks = MapBlockLoader.getByGroup(1)
print(string.format("✓ Found %d blocks in group 1:", #group1Blocks))
for _, block in ipairs(group1Blocks) do
    print(string.format("  - %s (%s)", block.id, block.name))
end

local group2Blocks = MapBlockLoader.getByGroup(2)
print(string.format("✓ Found %d blocks in group 2:", #group2Blocks))
for _, block in ipairs(group2Blocks) do
    print(string.format("  - %s (%s)", block.id, block.name))
end

local group10Blocks = MapBlockLoader.getByGroup(10)
print(string.format("✓ Found %d blocks in group 10:", #group10Blocks))
for _, block in ipairs(group10Blocks) do
    print(string.format("  - %s (%s)", block.id, block.name))
end

-- Test 3: Get blocks by tags
print("\nTest 3: Get blocks by tags")
local urbanBlocks = MapBlockLoader.getByTags({"urban"})
print(string.format("✓ Found %d blocks with 'urban' tag:", #urbanBlocks))
for _, block in ipairs(urbanBlocks) do
    print(string.format("  - %s (%s)", block.id, block.name))
end

local ruralBlocks = MapBlockLoader.getByTags({"rural", "farmland"})
print(string.format("✓ Found %d blocks with 'rural' or 'farmland' tags:", #ruralBlocks))
for _, block in ipairs(ruralBlocks) do
    print(string.format("  - %s (%s)", block.id, block.name))
end

-- Test 4: Get blocks by size
print("\nTest 4: Get blocks by size")
local size15x15 = MapBlockLoader.getBySize(15, 15)
print(string.format("✓ Found %d blocks with size 15x15:", #size15x15))
for _, block in ipairs(size15x15) do
    print(string.format("  - %s (%dx%d)", block.id, block.width, block.height))
end

local size30x30 = MapBlockLoader.getBySize(30, 30)
print(string.format("✓ Found %d blocks with size 30x30:", #size30x30))
for _, block in ipairs(size30x30) do
    print(string.format("  - %s (%dx%d)", block.id, block.width, block.height))
end

-- Test 5: Get tile at coordinate
print("\nTest 5: Get tile at coordinate")
if urbanBlock then
    local tile1 = MapBlockLoader.getTileAt(urbanBlock, 6, 2)
    print(string.format("✓ Tile at (6, 2): %s (door)", tile1 or "empty"))
    
    local tile2 = MapBlockLoader.getTileAt(urbanBlock, 4, 4)
    print(string.format("✓ Tile at (4, 4): %s (window)", tile2 or "empty"))
    
    local tile3 = MapBlockLoader.getTileAt(urbanBlock, 0, 0)
    print(string.format("✓ Tile at (0, 0): %s (road)", tile3 or "empty"))
end

-- Test 6: Validate Map Tile KEYs
print("\nTest 6: Validate Map Tile KEYs")
local farmBlock = MapBlockLoader.get("farm_field_01")
if farmBlock then
    local validCount = 0
    local invalidCount = 0
    
    for coord, key in pairs(farmBlock.tiles) do
        local tile = Tilesets.getTile(key)
        if tile then
            validCount = validCount + 1
        else
            invalidCount = invalidCount + 1
            print(string.format("  ✗ Invalid KEY: %s at %s", key, coord))
        end
    end
    
    print(string.format("✓ Validated %d tiles in '%s'", validCount, farmBlock.id))
    if invalidCount > 0 then
        print(string.format("  ✗ Found %d invalid KEYs", invalidCount))
    else
        print("  ✓ All KEYs valid")
    end
end

-- Test 7: Statistics
print("\nTest 7: Statistics")
local stats = MapBlockLoader.getStats()
print(string.format("✓ Total blocks: %d", stats.total))
print("✓ Blocks by group:")
for group, count in pairs(stats.byGroup) do
    print(string.format("  Group %d: %d blocks", group, count))
end
print("✓ Blocks by dimensions:")
for dim, count in pairs(stats.dimensions) do
    print(string.format("  %s: %d blocks", dim, count))
end
print("✓ Blocks by tag:")
for tag, count in pairs(stats.byTags) do
    print(string.format("  '%s': %d blocks", tag, count))
end

-- Test 8: Export to TOML
print("\nTest 8: Export to TOML")
if urbanBlock then
    local toml = MapBlockLoader.exportToTOML(urbanBlock)
    print(string.format("✓ Exported '%s' to TOML (%d bytes)", urbanBlock.id, #toml))
    print("First 200 characters:")
    print(toml:sub(1, 200) .. "...")
end

print("\n=== All tests complete! ===")
