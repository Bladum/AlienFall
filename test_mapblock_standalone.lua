-- Standalone Map Block Loader Test (no Love2D required)
-- Tests TOML parsing and Map Block loading

print("=== Map Block Loader v2 Test (Standalone) ===\n")

-- Mock love.filesystem for testing
_G.love = {
    filesystem = {
        getDirectoryItems = function(path)
            -- Return mock files
            return {"urban_small_01.toml", "farm_field_01.toml", "ufo_scout_landing.toml"}
        end
    }
}

-- Add engine to package path
package.path = package.path .. ";engine/?.lua;engine/?/init.lua"

-- Test 1: Parse TOML file
print("[Test 1] Parse TOML file")
local function testParseTOML()
    local file = io.open("mods/core/mapblocks/urban_small_01.toml", "r")
    if not file then
        print("✗ Cannot open urban_small_01.toml")
        return false
    end
    
    local content = file:read("*all")
    file:close()
    
    print(string.format("✓ Read %d bytes from file", #content))
    
    -- Simple validation
    if content:find("%[metadata%]") and content:find("%[tiles%]") then
        print("✓ Found [metadata] and [tiles] sections")
        
        if content:find('id%s*=%s*"urban_small_01"') then
            print("✓ Found ID field")
        end
        
        if content:find('width%s*=%s*15') then
            print("✓ Found width field")
        end
        
        if content:find('"0_0"%s*=%s*"ROAD_ASPHALT"') then
            print("✓ Found tile coordinate")
        end
        
        return true
    else
        print("✗ Missing required sections")
        return false
    end
end

local success = testParseTOML()

-- Test 2: Validate TOML structure
print("\n[Test 2] Validate all Map Block TOML files")
local files = {
    "mods/core/mapblocks/urban_small_01.toml",
    "mods/core/mapblocks/farm_field_01.toml",
    "mods/core/mapblocks/ufo_scout_landing.toml"
}

for _, filepath in ipairs(files) do
    local file = io.open(filepath, "r")
    if file then
        local content = file:read("*all")
        file:close()
        
        local hasMetadata = content:find("%[metadata%]") ~= nil
        local hasTiles = content:find("%[tiles%]") ~= nil
        local hasID = content:find('id%s*=') ~= nil
        local hasWidth = content:find('width%s*=') ~= nil
        local hasHeight = content:find('height%s*=') ~= nil
        local hasGroup = content:find('group%s*=') ~= nil
        
        local valid = hasMetadata and hasTiles and hasID and hasWidth and hasHeight and hasGroup
        
        if valid then
            print(string.format("✓ %s - Valid structure", filepath))
        else
            print(string.format("✗ %s - Invalid structure", filepath))
            if not hasMetadata then print("  Missing [metadata]") end
            if not hasTiles then print("  Missing [tiles]") end
            if not hasID then print("  Missing id") end
            if not hasWidth then print("  Missing width") end
            if not hasHeight then print("  Missing height") end
            if not hasGroup then print("  Missing group") end
        end
    else
        print(string.format("✗ Cannot open %s", filepath))
    end
end

-- Test 3: Count tiles in each block
print("\n[Test 3] Count tiles in each Map Block")
for _, filepath in ipairs(files) do
    local file = io.open(filepath, "r")
    if file then
        local content = file:read("*all")
        file:close()
        
        local tileCount = 0
        for coord in content:gmatch('"(%d+_%d+)"%s*=%s*"[%w_]+"') do
            tileCount = tileCount + 1
        end
        
        print(string.format("✓ %s - %d tiles", filepath:match("([^/]+)%.toml$"), tileCount))
    end
end

-- Test 4: Validate Map Tile KEY format
print("\n[Test 4] Validate Map Tile KEY format")
local invalidKeys = {}

for _, filepath in ipairs(files) do
    local file = io.open(filepath, "r")
    if file then
        local content = file:read("*all")
        file:close()
        
        for coord, key in content:gmatch('"(%d+_%d+)"%s*=%s*"([%w_]+)"') do
            -- Check KEY format: UPPER_SNAKE_CASE
            if not key:match("^[A-Z][A-Z0-9_]*$") then
                table.insert(invalidKeys, {file = filepath, coord = coord, key = key})
            end
        end
    end
end

if #invalidKeys == 0 then
    print("✓ All Map Tile KEYs use UPPER_SNAKE_CASE format")
else
    print(string.format("✗ Found %d invalid KEYs:", #invalidKeys))
    for _, entry in ipairs(invalidKeys) do
        print(string.format("  %s at %s in %s", entry.key, entry.coord, entry.file))
    end
end

-- Test 5: Check for common Map Tile KEYs
print("\n[Test 5] Check for common Map Tile KEYs")
local commonKeys = {
    "GRASS", "ROAD_ASPHALT", "SIDEWALK_CONCRETE", "WALL_BRICK",
    "DOOR_WOOD", "WINDOW_GLASS", "FLOOR_TILE", "FENCE_WOOD",
    "TREE_PINE", "HAY_BALE", "WELL", "WALL_ALIEN_HULL",
    "FLOOR_ALIEN_ALLOY", "DOOR_ALIEN", "SCORCH_MARK"
}

local keysFound = {}
for _, filepath in ipairs(files) do
    local file = io.open(filepath, "r")
    if file then
        local content = file:read("*all")
        file:close()
        
        for _, expectedKey in ipairs(commonKeys) do
            if content:find('"' .. expectedKey .. '"') then
                keysFound[expectedKey] = true
            end
        end
    end
end

print(string.format("✓ Found %d/%d expected Map Tile KEYs:", 
    #(function() local t = {} for k in pairs(keysFound) do table.insert(t, k) end return t end)(),
    #commonKeys))
for _, key in ipairs(commonKeys) do
    if keysFound[key] then
        print(string.format("  ✓ %s", key))
    end
end

print("\n=== All tests complete! ===")
print("\nTo fully test the Map Block loader, run the game with:")
print("  lovec engine")
print("And use the test files in engine/battlescape/tests/")
