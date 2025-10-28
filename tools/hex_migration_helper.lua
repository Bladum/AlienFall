-- hex_migration_helper.lua
-- Helper script to assist with migrating files to vertical axial system

local HexMigrationHelper = {}

---Generate standard HexMath import statement
function HexMigrationHelper.generateImport()
    return 'local HexMath = require("engine.battlescape.battle_ecs.hex_math")'
end

---Generate standard header documentation for vertical axial
function HexMigrationHelper.generateHeaderDocs()
    return [[
---COORDINATE SYSTEM: Vertical Axial (Flat-Top Hexagons)
---  - All positions use axial coordinates {q, r}
---  - Distance: HexMath.distance(q1, r1, q2, r2)
---  - Neighbors: HexMath.getNeighbors(q, r) - returns 6 adjacent hexes
---  - Directions: E, SE, SW, W, NW, NE (HexMath.DIRECTIONS)
---  - Line-of-sight: HexMath.hexLine(q1, r1, q2, r2)
---  - Range query: HexMath.hexesInRange(q, r, range)
---
---DESIGN REFERENCE: design/mechanics/hex_vertical_axial_system.md
---
---@see engine.battlescape.battle_ecs.hex_math For hex mathematics]]
end

---List of common patterns to replace
HexMigrationHelper.replacementPatterns = {
    -- Function parameters
    {
        old = "function.*%(.-x%s*,%s*y",
        new = "function (q, r",
        description = "Replace x, y parameters with q, r"
    },

    -- Distance calculations
    {
        old = "math%.abs%(x1%s*-%s*x2%)%s*%+%s*math%.abs%(y1%s*-%s*y2%)",
        new = "HexMath.distance(q1, r1, q2, r2)",
        description = "Replace Manhattan distance with hex distance"
    },

    -- Neighbor iteration (square grid)
    {
        old = "for%s+dx%s*=%s*%-1%s*,%s*1%s+do.-for%s+dy%s*=%s*%-1%s*,%s*1%s+do",
        new = "local neighbors = HexMath.getNeighbors(q, r)\nfor _, neighbor in ipairs(neighbors) do\n    local nq, nr = neighbor.q, neighbor.r",
        description = "Replace square grid iteration with hex neighbors"
    },
}

---Check if file needs migration
---@param filepath string Path to file
---@return boolean, string[] needsMigration, List of issues found
function HexMigrationHelper.analyzeFile(filepath)
    local file = io.open(filepath, "r")
    if not file then
        return false, {"Could not open file"}
    end

    local content = file:read("*all")
    file:close()

    local issues = {}

    -- Check for HexMath import
    if not content:match('require%s*%(%s*["\']engine%.battlescape%.battle_ecs%.hex_math["\']%s*%)') then
        if content:match('hex') or content:match('distance') or content:match('neighbor') then
            table.insert(issues, "Missing HexMath import but file deals with hex operations")
        end
    end

    -- Check for old coordinate variable names
    if content:match('startX') or content:match('startY') then
        table.insert(issues, "Uses offset coordinates (x, y) instead of axial (q, r)")
    end

    -- Check for custom direction tables
    if content:match('local%s+directions%s*=%s*{') then
        table.insert(issues, "Has custom direction table - should use HexMath.DIRECTIONS")
    end

    -- Check for Manhattan distance
    if content:match('math%.abs.*%+.*math%.abs') then
        table.insert(issues, "Uses Manhattan distance - should use HexMath.distance()")
    end

    -- Check for square grid iteration
    if content:match('for%s+.-%s*=%s*%-1%s*,%s*1') then
        table.insert(issues, "May be using square grid neighbor iteration")
    end

    return #issues > 0, issues
end

---Generate migration report for directory
---@param dirpath string Directory to scan
---@return table Report of files needing migration
function HexMigrationHelper.scanDirectory(dirpath)
    local report = {
        total = 0,
        needsMigration = 0,
        files = {}
    }

    -- This would need actual directory scanning implementation
    -- For now, return template

    return report
end

---Print migration instructions for a file
---@param filepath string File to analyze
function HexMigrationHelper.printInstructions(filepath)
    local needs, issues = HexMigrationHelper.analyzeFile(filepath)

    if not needs then
        print(string.format("[✓] %s: Already migrated or no issues found", filepath))
        return
    end

    print(string.format("[!] %s: Needs migration", filepath))
    print("Issues found:")
    for i, issue in ipairs(issues) do
        print(string.format("  %d. %s", i, issue))
    end

    print("\nMigration steps:")
    print("  1. Add HexMath import at top:")
    print("     " .. HexMigrationHelper.generateImport())
    print("  2. Update function signatures: x,y -> q,r")
    print("  3. Replace distance calculations with HexMath.distance()")
    print("  4. Replace neighbor iterations with HexMath.getNeighbors()")
    print("  5. Add header documentation")
    print("  6. Test the file")
    print()
end

return HexMigrationHelper

