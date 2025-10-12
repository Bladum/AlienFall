-- Asset Verification System
-- Scans TOML files for entity definitions and checks for corresponding images
-- Creates placeholder images for missing assets

local TOML = require("libs.toml")
local ModManager = require("systems.mod_manager")

local AssetVerifier = {}

-- Results storage
AssetVerifier.results = {
    terrainTypes = {},
    unitClasses = {},
    missingAssets = {},
    verifiedAssets = {},
    placeholdersCreated = {}
}

--[[
    Verify all terrain type assets
]]
function AssetVerifier.verifyTerrainAssets()
    print("[AssetVerifier] Verifying terrain assets...")
    
    -- Load terrain definitions
    local path = ModManager.getContentPath("rules", "battle/terrain.toml")
    if not path then
        print("[AssetVerifier] ERROR: Could not get terrain path")
        return false
    end
    
    local data = TOML.load(path)
    if not data or not data.terrain then
        print("[AssetVerifier] ERROR: Could not load terrain data")
        return false
    end
    
    -- Check each terrain type
    for terrainId, terrainData in pairs(data.terrain) do
        print(string.format("[AssetVerifier] Checking terrain: %s", terrainId))
        
        local imagePath = terrainData.image or ("terrain/" .. terrainId .. ".png")
        local fullPath = ModManager.getContentPath("assets", imagePath)
        
        if fullPath then
            local fileInfo = love.filesystem.getInfo(fullPath)
            if fileInfo then
                table.insert(AssetVerifier.results.verifiedAssets, {
                    type = "terrain",
                    id = terrainId,
                    path = imagePath,
                    status = "found"
                })
                print(string.format("[AssetVerifier] ✓ Found: %s", imagePath))
            else
                table.insert(AssetVerifier.results.missingAssets, {
                    type = "terrain",
                    id = terrainId,
                    expectedPath = imagePath
                })
                print(string.format("[AssetVerifier] ✗ Missing: %s", imagePath))
            end
        end
        
        table.insert(AssetVerifier.results.terrainTypes, terrainId)
    end
    
    return true
end

--[[
    Verify all unit class assets
]]
function AssetVerifier.verifyUnitAssets()
    print("[AssetVerifier] Verifying unit assets...")
    
    -- Load unit class definitions
    local path = ModManager.getContentPath("rules", "unit/classes.toml")
    if not path then
        print("[AssetVerifier] ERROR: Could not get unit classes path")
        return false
    end
    
    local data = TOML.load(path)
    if not data or not data.classes then
        print("[AssetVerifier] ERROR: Could not load unit class data")
        return false
    end
    
    -- Check each unit class
    for unitId, unitData in pairs(data.classes) do
        print(string.format("[AssetVerifier] Checking unit: %s", unitId))
        
        local imagePath = unitData.image or ("units/" .. unitId .. ".png")
        local fullPath = ModManager.getContentPath("assets", imagePath)
        
        if fullPath then
            local fileInfo = love.filesystem.getInfo(fullPath)
            if fileInfo then
                table.insert(AssetVerifier.results.verifiedAssets, {
                    type = "unit",
                    id = unitId,
                    path = imagePath,
                    status = "found"
                })
                print(string.format("[AssetVerifier] ✓ Found: %s", imagePath))
            else
                table.insert(AssetVerifier.results.missingAssets, {
                    type = "unit",
                    id = unitId,
                    expectedPath = imagePath
                })
                print(string.format("[AssetVerifier] ✗ Missing: %s", imagePath))
            end
        end
        
        table.insert(AssetVerifier.results.unitClasses, unitId)
    end
    
    return true
end

--[[
    Create placeholder image for missing asset
]]
function AssetVerifier.createPlaceholder(entityType, entityId)
    print(string.format("[AssetVerifier] Creating placeholder for %s: %s", entityType, entityId))
    
    -- Create 32x32 pink placeholder with text
    local imageData = love.image.newImageData(32, 32)
    
    -- Fill with pink
    for y = 0, 31 do
        for x = 0, 31 do
            imageData:setPixel(x, y, 1, 0, 1, 1)  -- Magenta/Pink
        end
    end
    
    -- Add border
    for x = 0, 31 do
        imageData:setPixel(x, 0, 0, 0, 0, 1)  -- Black border
        imageData:setPixel(x, 31, 0, 0, 0, 1)
    end
    for y = 0, 31 do
        imageData:setPixel(0, y, 0, 0, 0, 1)
        imageData:setPixel(31, y, 0, 0, 0, 1)
    end
    
    -- Determine save path
    local savePath
    if entityType == "terrain" then
        savePath = "terrain/" .. entityId .. ".png"
    elseif entityType == "unit" then
        savePath = "units/" .. entityId .. ".png"
    else
        print(string.format("[AssetVerifier] Unknown entity type: %s", entityType))
        return false
    end
    
    -- Save to mod assets folder
    local fullPath = ModManager.getContentPath("assets", savePath)
    if fullPath then
        -- Convert to absolute path for saving
        local saveInfo = love.filesystem.getInfo(fullPath)
        if not saveInfo then
            -- Create directory if needed
            local dir = fullPath:match("(.+)/[^/]+$")
            if dir then
                love.filesystem.createDirectory(dir)
            end
        end
        
        -- Encode and save
        local success = imageData:encode("png", fullPath)
        if success then
            print(string.format("[AssetVerifier] ✓ Created placeholder: %s", savePath))
            table.insert(AssetVerifier.results.placeholdersCreated, {
                type = entityType,
                id = entityId,
                path = savePath
            })
            return true
        else
            print(string.format("[AssetVerifier] ✗ Failed to save: %s", savePath))
        end
    end
    
    return false
end

--[[
    Generate verification report
]]
function AssetVerifier.generateReport()
    print("\n" .. string.rep("=", 60))
    print("ASSET VERIFICATION REPORT")
    print(string.rep("=", 60))
    
    print(string.format("\nTerrain Types: %d", #AssetVerifier.results.terrainTypes))
    print(string.format("Unit Classes: %d", #AssetVerifier.results.unitClasses))
    print(string.format("\nAssets Found: %d", #AssetVerifier.results.verifiedAssets))
    print(string.format("Assets Missing: %d", #AssetVerifier.results.missingAssets))
    print(string.format("Placeholders Created: %d", #AssetVerifier.results.placeholdersCreated))
    
    if #AssetVerifier.results.missingAssets > 0 then
        print("\nMissing Assets:")
        for _, asset in ipairs(AssetVerifier.results.missingAssets) do
            print(string.format("  - %s: %s (expected: %s)", asset.type, asset.id, asset.expectedPath))
        end
    end
    
    if #AssetVerifier.results.placeholdersCreated > 0 then
        print("\nPlaceholders Created:")
        for _, placeholder in ipairs(AssetVerifier.results.placeholdersCreated) do
            print(string.format("  - %s: %s → %s", placeholder.type, placeholder.id, placeholder.path))
        end
    end
    
    print("\n" .. string.rep("=", 60))
    
    -- Save report to temp directory
    local tempDir = os.getenv("TEMP")
    if tempDir then
        local reportPath = tempDir .. "\\asset_verification_report.txt"
        local file = io.open(reportPath, "w")
        if file then
            file:write("ASSET VERIFICATION REPORT\n")
            file:write(string.rep("=", 60) .. "\n\n")
            file:write(string.format("Terrain Types: %d\n", #AssetVerifier.results.terrainTypes))
            file:write(string.format("Unit Classes: %d\n", #AssetVerifier.results.unitClasses))
            file:write(string.format("\nAssets Found: %d\n", #AssetVerifier.results.verifiedAssets))
            file:write(string.format("Assets Missing: %d\n", #AssetVerifier.results.missingAssets))
            file:write(string.format("Placeholders Created: %d\n", #AssetVerifier.results.placeholdersCreated))
            
            if #AssetVerifier.results.missingAssets > 0 then
                file:write("\nMissing Assets:\n")
                for _, asset in ipairs(AssetVerifier.results.missingAssets) do
                    file:write(string.format("  - %s: %s (expected: %s)\n", asset.type, asset.id, asset.expectedPath))
                end
            end
            
            file:close()
            print(string.format("\nReport saved to: %s", reportPath))
        end
    end
end

--[[
    Main verification runner
]]
function AssetVerifier.run(createPlaceholders)
    print("[AssetVerifier] Starting asset verification...")
    
    -- Verify terrain assets
    AssetVerifier.verifyTerrainAssets()
    
    -- Verify unit assets
    AssetVerifier.verifyUnitAssets()
    
    -- Create placeholders if requested
    if createPlaceholders and #AssetVerifier.results.missingAssets > 0 then
        print("\n[AssetVerifier] Creating placeholders for missing assets...")
        for _, asset in ipairs(AssetVerifier.results.missingAssets) do
            AssetVerifier.createPlaceholder(asset.type, asset.id)
        end
    end
    
    -- Generate report
    AssetVerifier.generateReport()
    
    print("[AssetVerifier] Verification complete!")
    return AssetVerifier.results
end

return AssetVerifier
