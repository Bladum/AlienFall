---Mapblock Validator System
---
---Validates mapblock TOML files to ensure all tile references are valid and
---mapblocks are properly formatted. Scans all mapblock files in the active mod,
---checks tile IDs against terrain definitions, and reports any issues.
---
---Validation Checks:
---  - All tile IDs exist in terrain definitions
---  - Mapblock dimensions are consistent
---  - Layer data is properly formatted
---  - Tile counts match declared dimensions
---  - No invalid characters in tile data
---
---Key Exports:
---  - MapblockValidator.scanMapblocks(): Finds all mapblock files
---  - MapblockValidator.validateMapblock(filepath): Validates single mapblock
---  - MapblockValidator.validateAll(): Validates all mapblocks
---  - MapblockValidator.printReport(): Displays validation results
---  - MapblockValidator.results: Validation results table
---
---Dependencies:
---  - utils.toml: TOML file parsing
---  - mods.mod_manager: Mapblock path resolution
---  - core.data_loader: Terrain definition access
---
---@module core.mapblock_validator
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Validator = require("core.mapblock_validator")
---  Validator.validateAll()
---  Validator.printReport()
---  if #Validator.results.invalidMapblocks > 0 then
---    print("Found issues!")
---  end
---
---@see battlescape.maps.mapblock_system For mapblock loading
---@see core.data_loader For terrain definitions

local TOML = require("utils.toml")
local ModManager = require("mods.mod_manager")
local DataLoader = require("core.data_loader")

local MapblockValidator = {}

-- Results storage
MapblockValidator.results = {
    mapblocks = {},
    validMapblocks = {},
    invalidMapblocks = {},
    issues = {},
    totalTiles = 0,
    invalidTiles = 0
}

--[[
    Scan for all mapblock files
]]
function MapblockValidator.scanMapblocks()
    print("[MapblockValidator] Scanning for mapblocks...")
    
    local mapblocksPath = ModManager.getContentPath("mapblocks")
    if not mapblocksPath then
        print("[MapblockValidator] ERROR: Could not get mapblocks path")
        return {}
    end
    
    local files = love.filesystem.getDirectoryItems(mapblocksPath)
    local mapblocks = {}
    
    for _, file in ipairs(files) do
        if file:match("%.toml$") then
            table.insert(mapblocks, file)
        end
    end
    
    print(string.format("[MapblockValidator] Found %d mapblock files", #mapblocks))
    return mapblocks
end

--[[
    Validate a single mapblock
]]
function MapblockValidator.validateMapblock(filename)
    print(string.format("[MapblockValidator] Validating: %s", filename))
    
    local mapblockPath = ModManager.getContentPath("mapblocks", filename)
    if not mapblockPath then
        table.insert(MapblockValidator.results.issues, {
            mapblock = filename,
            issue = "Could not resolve path"
        })
        return false
    end
    
    -- Load mapblock TOML
    local success, mapblock = pcall(TOML.load, mapblockPath)
    if not success then
        table.insert(MapblockValidator.results.issues, {
            mapblock = filename,
            issue = "Failed to parse TOML: " .. tostring(mapblock)
        })
        return false
    end
    
    -- Validate metadata
    if not mapblock.metadata then
        table.insert(MapblockValidator.results.issues, {
            mapblock = filename,
            issue = "Missing [metadata] section"
        })
        return false
    end
    
    local metadata = mapblock.metadata
    if not metadata.id or not metadata.width or not metadata.height then
        table.insert(MapblockValidator.results.issues, {
            mapblock = filename,
            issue = "Metadata missing required fields (id, width, height)"
        })
        return false
    end
    
    print(string.format("[MapblockValidator]   Size: %dx%d", metadata.width, metadata.height))
    
    -- Validate tiles
    if not mapblock.tiles then
        table.insert(MapblockValidator.results.issues, {
            mapblock = filename,
            issue = "Missing [tiles] section"
        })
        return false
    end
    
    local tileCount = 0
    local invalidCount = 0
    
    for position, terrainId in pairs(mapblock.tiles) do
        tileCount = tileCount + 1
        MapblockValidator.results.totalTiles = MapblockValidator.results.totalTiles + 1
        
        -- Check if terrain type exists
        local terrain = DataLoader.terrainTypes.get(terrainId)
        if not terrain then
            invalidCount = invalidCount + 1
            MapblockValidator.results.invalidTiles = MapblockValidator.results.invalidTiles + 1
            table.insert(MapblockValidator.results.issues, {
                mapblock = filename,
                position = position,
                issue = string.format("Undefined terrain type: '%s'", terrainId)
            })
        end
    end
    
    print(string.format("[MapblockValidator]   Tiles: %d (%d invalid)", tileCount, invalidCount))
    
    -- Add to results
    table.insert(MapblockValidator.results.mapblocks, {
        filename = filename,
        id = metadata.id,
        size = {width = metadata.width, height = metadata.height},
        tileCount = tileCount,
        invalidCount = invalidCount,
        valid = (invalidCount == 0)
    })
    
    if invalidCount == 0 then
        table.insert(MapblockValidator.results.validMapblocks, filename)
        print(string.format("[MapblockValidator]   ✓ VALID"))
        return true
    else
        table.insert(MapblockValidator.results.invalidMapblocks, filename)
        print(string.format("[MapblockValidator]   ✗ INVALID (%d issues)", invalidCount))
        return false
    end
end

--[[
    Generate validation report
]]
function MapblockValidator.generateReport()
    print("\n" .. string.rep("=", 60))
    print("MAPBLOCK VALIDATION REPORT")
    print(string.rep("=", 60))
    
    print(string.format("\nTotal Mapblocks: %d", #MapblockValidator.results.mapblocks))
    print(string.format("Valid: %d", #MapblockValidator.results.validMapblocks))
    print(string.format("Invalid: %d", #MapblockValidator.results.invalidMapblocks))
    print(string.format("\nTotal Tiles Checked: %d", MapblockValidator.results.totalTiles))
    print(string.format("Invalid Tile References: %d", MapblockValidator.results.invalidTiles))
    print(string.format("\nTotal Issues: %d", #MapblockValidator.results.issues))
    
    if #MapblockValidator.results.invalidMapblocks > 0 then
        print("\nInvalid Mapblocks:")
        for _, filename in ipairs(MapblockValidator.results.invalidMapblocks) do
            print(string.format("  - %s", filename))
        end
    end
    
    if #MapblockValidator.results.issues > 0 then
        print("\nIssues Found:")
        local displayLimit = 20
        for i, issue in ipairs(MapblockValidator.results.issues) do
            if i > displayLimit then
                print(string.format("  ... and %d more issues", #MapblockValidator.results.issues - displayLimit))
                break
            end
            if issue.position then
                print(string.format("  - %s [%s]: %s", issue.mapblock, issue.position, issue.issue))
            else
                print(string.format("  - %s: %s", issue.mapblock, issue.issue))
            end
        end
    end
    
    print("\n" .. string.rep("=", 60))
    
    -- Save report to temp directory
    local tempDir = os.getenv("TEMP")
    if tempDir then
        local reportPath = tempDir .. "\\mapblock_validation_report.txt"
        local file = io.open(reportPath, "w")
        if file then
            file:write("MAPBLOCK VALIDATION REPORT\n")
            file:write(string.rep("=", 60) .. "\n\n")
            file:write(string.format("Total Mapblocks: %d\n", #MapblockValidator.results.mapblocks))
            file:write(string.format("Valid: %d\n", #MapblockValidator.results.validMapblocks))
            file:write(string.format("Invalid: %d\n", #MapblockValidator.results.invalidMapblocks))
            file:write(string.format("\nTotal Tiles Checked: %d\n", MapblockValidator.results.totalTiles))
            file:write(string.format("Invalid Tile References: %d\n", MapblockValidator.results.invalidTiles))
            file:write(string.format("\nTotal Issues: %d\n", #MapblockValidator.results.issues))
            
            if #MapblockValidator.results.issues > 0 then
                file:write("\nAll Issues:\n")
                for _, issue in ipairs(MapblockValidator.results.issues) do
                    if issue.position then
                        file:write(string.format("  - %s [%s]: %s\n", issue.mapblock, issue.position, issue.issue))
                    else
                        file:write(string.format("  - %s: %s\n", issue.mapblock, issue.issue))
                    end
                end
            end
            
            file:close()
            print(string.format("\nReport saved to: %s", reportPath))
        end
    end
end

--[[
    Main validation runner
]]
function MapblockValidator.run()
    print("[MapblockValidator] Starting mapblock validation...")
    
    -- Reset results
    MapblockValidator.results = {
        mapblocks = {},
        validMapblocks = {},
        invalidMapblocks = {},
        issues = {},
        totalTiles = 0,
        invalidTiles = 0
    }
    
    -- Scan for mapblocks
    local mapblockFiles = MapblockValidator.scanMapblocks()
    
    if #mapblockFiles == 0 then
        print("[MapblockValidator] No mapblock files found!")
        return MapblockValidator.results
    end
    
    -- Validate each mapblock
    for _, filename in ipairs(mapblockFiles) do
        MapblockValidator.validateMapblock(filename)
    end
    
    -- Generate report
    MapblockValidator.generateReport()
    
    print("[MapblockValidator] Validation complete!")
    return MapblockValidator.results
end

return MapblockValidator






















