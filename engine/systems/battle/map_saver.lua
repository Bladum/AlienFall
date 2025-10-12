-- Map Saver Module
-- Saves battlefield maps as PNG images (1 pixel = 1 tile)

local MapSaver = {}

-- Terrain type to color mapping
local TERRAIN_COLORS = {
    floor = {128, 128, 128},      -- Gray
    road = {180, 140, 100},       -- Brown
    rough = {100, 80, 60},        -- Dark brown
    slope = {150, 150, 120},      -- Tan
    wall = {50, 50, 50},          -- Dark gray
    wood_wall = {139, 90, 43},    -- Wood brown
    low_wall = {80, 80, 80},      -- Medium gray
    window = {150, 200, 255},     -- Light blue
    door = {160, 120, 80},        -- Light brown
    bushes = {50, 150, 50},       -- Green
    trees = {0, 100, 0},          -- Dark green
    tree = {34, 139, 34},         -- Forest green
    water = {0, 100, 200},        -- Blue
    fire = {255, 100, 0},         -- Orange
    smoke = {200, 200, 200},      -- Light gray
}

-- Save battlefield to PNG file
function MapSaver.saveMapToPNG(battlefield, filename)
    if not battlefield or not battlefield.map then
        print("[MapSaver] ERROR: Invalid battlefield")
        return false
    end
    
    local width = battlefield.width
    local height = battlefield.height
    
    print(string.format("[MapSaver] Saving %dx%d battlefield to PNG...", width, height))
    
    -- Create image data
    local success, imageData = pcall(love.image.newImageData, width, height)
    if not success then
        print(string.format("[MapSaver] ERROR: Failed to create image data: %s", tostring(imageData)))
        return false
    end
    
    -- Set pixel colors based on terrain
    for y = 1, height do
        for x = 1, width do
            local tile = battlefield.map[y] and battlefield.map[y][x]
            if tile then
                local terrainId = tile.terrain and tile.terrain.id or "floor"
                local color = TERRAIN_COLORS[terrainId] or {255, 0, 255}  -- Magenta for unknown
                
                -- Love2D uses 0-1 range, convert from 0-255
                local pixelSuccess = pcall(function()
                    imageData:setPixel(x - 1, y - 1, color[1]/255, color[2]/255, color[3]/255, 1)
                end)
                
                if not pixelSuccess then
                    print(string.format("[MapSaver] WARNING: Failed to set pixel at (%d, %d)", x, y))
                end
            end
        end
    end
    
    -- Get temp directory
    local tempDir = os.getenv("TEMP") or os.getenv("TMP")
    if not tempDir then
        print("[MapSaver] ERROR: Cannot access TEMP directory")
        return false
    end
    
    local filepath = tempDir .. "\\" .. filename
    print(string.format("[MapSaver] Saving to: %s", filepath))
    
    -- Save to file
    local encodeSuccess, encodeError = pcall(function()
        imageData:encode("png", filepath)
    end)
    
    if encodeSuccess then
        print(string.format("[MapSaver] SUCCESS: Map saved to: %s", filepath))
        return true, filepath
    else
        print(string.format("[MapSaver] ERROR: Failed to encode/save PNG: %s", tostring(encodeError)))
        return false
    end
end

-- Load map from PNG file
function MapSaver.loadMapFromPNG(filename)
    local tempDir = os.getenv("TEMP") or os.getenv("TMP") or "."
    local filepath = tempDir .. "\\" .. filename
    
    local success, imageData = pcall(love.image.newImageData, filepath)
    
    if not success then
        print(string.format("[MapSaver] ERROR: Could not load %s", filepath))
        return nil
    end
    
    local width = imageData:getWidth()
    local height = imageData:getHeight()
    
    print(string.format("[MapSaver] Loaded map: %dx%d", width, height))
    
    -- Return map data structure
    return {
        width = width,
        height = height,
        imageData = imageData
    }
end

-- Get terrain type from pixel color
function MapSaver.getTerrainFromColor(r, g, b)
    -- Convert 0-1 to 0-255
    local r255 = math.floor(r * 255)
    local g255 = math.floor(g * 255)
    local b255 = math.floor(b * 255)
    
    -- Find closest matching terrain
    local minDist = math.huge
    local bestTerrain = "floor"
    
    for terrainId, color in pairs(TERRAIN_COLORS) do
        local dist = math.abs(r255 - color[1]) + math.abs(g255 - color[2]) + math.abs(b255 - color[3])
        if dist < minDist then
            minDist = dist
            bestTerrain = terrainId
        end
    end
    
    return bestTerrain
end

return MapSaver
