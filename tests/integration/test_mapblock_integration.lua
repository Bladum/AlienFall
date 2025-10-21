-- Test MapBlock and GridMap Integration
-- Run with: lovec engine from project root

print("=== MapBlock Integration Test ===")

-- Test 1: Load TOML parser
print("\n[TEST 1] Loading TOML parser...")
local success, TOML = pcall(require, "utils.libs.toml")
if not success then
    print("❌ FAILED: " .. tostring(TOML))
    return
end
print("✅ PASSED: TOML parser loaded")

-- Test 2: Load MapBlock class
print("\n[TEST 2] Loading MapBlock class...")
local success, MapBlock = pcall(require, "battlescape.battle.map_block")
if not success then
    print("❌ FAILED: " .. tostring(MapBlock))
    return
end
print("✅ PASSED: MapBlock class loaded")

-- Test 3: Load GridMap class
print("\n[TEST 3] Loading GridMap class...")
local success, GridMap = pcall(require, "battlescape.battle.grid_map")
if not success then
    print("❌ FAILED: " .. tostring(GridMap))
    return
end
print("✅ PASSED: GridMap class loaded")

-- Test 4: Load MapBlocks from directory
print("\n[TEST 4] Loading MapBlock templates...")
local success, blockPool = pcall(MapBlock.loadAll, "mods/core/mapblocks")
if not success then
    print("❌ FAILED: " .. tostring(blockPool))
    return
end
print(string.format("✅ PASSED: Loaded %d MapBlock templates", #blockPool))

-- List loaded blocks
for i, block in ipairs(blockPool) do
    print(string.format("   %d. %s (%s) - %dx%d tiles", 
        i, block.metadata.name or "Unnamed", 
        block.metadata.biome or "unknown",
        block.width, block.height))
end

-- Test 5: Create GridMap
print("\n[TEST 5] Creating GridMap (5x5)...")
local success, gridMap = pcall(GridMap.new, 5, 5)
if not success then
    print("❌ FAILED: " .. tostring(gridMap))
    return
end
print(string.format("✅ PASSED: Created %dx%d GridMap", gridMap.gridWidth, gridMap.gridHeight))
print(string.format("   World size: %dx%d tiles", gridMap.worldWidth, gridMap.worldHeight))

-- Test 6: Generate themed battlefield
print("\n[TEST 6] Generating themed battlefield...")
local success, err = pcall(function()
    gridMap:generateThemed(blockPool, {
        urban = 0.3,
        forest = 0.25,
        industrial = 0.2,
        water = 0.1,
        rural = 0.1,
        mixed = 0.05
    })
end)
if not success then
    print("❌ FAILED: " .. tostring(err))
    return
end
print("✅ PASSED: Generated themed battlefield")

-- Show statistics
local stats = gridMap:getStats()
print("\nStatistics:")
print(string.format("   Blocks placed: %d/%d", stats.blocksPlaced, stats.totalSlots))
print(string.format("   Empty slots: %d", stats.emptySlots))
print("\nBiome distribution:")
for biome, count in pairs(stats.biomes) do
    print(string.format("   %s: %d blocks", biome, count))
end

-- Test 7: Convert to Battlefield
print("\n[TEST 7] Converting to Battlefield...")
local success, battlefield = pcall(gridMap.toBattlefield, gridMap)
if not success then
    print("❌ FAILED: " .. tostring(battlefield))
    return
end
print(string.format("✅ PASSED: Created Battlefield %dx%d", battlefield.width, battlefield.height))

-- Verify some tiles
print("\nSample tiles:")
for i = 1, 5 do
    local x = math.random(1, battlefield.width)
    local y = math.random(1, battlefield.height)
    local tile = battlefield.map[y] and battlefield.map[y][x]
    if tile then
        print(string.format("   (%d,%d): %s", x, y, tile.terrainId or "nil"))
    end
end

-- Test 8: ASCII visualization
print("\n[TEST 8] ASCII visualization (first 20x20 tiles)...")
local ascii = gridMap:toASCII()
local lines = {}
for line in ascii:gmatch("[^\n]+") do
    table.insert(lines, line)
end
for i = 1, math.min(20, #lines) do
    print("   " .. lines[i]:sub(1, 60))  -- First 60 chars
end

print("\n=== All Tests PASSED ===")
print("\nIntegration is ready for battlescape!")

























