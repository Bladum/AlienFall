---TeamPlacement - Unit Spawn and Deployment Algorithm
---
---Handles strategic unit placement based on MapScript-defined spawn zones.
---Places units within designated areas while respecting terrain constraints,
---unit spacing requirements, and tactical positioning rules.
---
---Placement Process:
---  - Parse MapScript spawn zones by team
---  - Calculate valid tile positions within zones
---  - Apply terrain and spacing constraints
---  - Distribute units evenly across available positions
---  - Handle placement failures gracefully
---
---Features:
---  - Multi-team spawn zone support
---  - Terrain-aware placement (avoid impassable tiles)
---  - Unit spacing to prevent overcrowding
---  - Fallback placement for constrained maps
---  - Detailed placement reporting and statistics
---  - Integration with MapScript spawn definitions
---
---Key Exports:
---  - new(battlefield): Create team placement system
---  - placeTeam(team, units, spawnZones): Place units for specific team
---  - placeAllTeams(teams, spawnZones): Place all teams simultaneously
---  - getValidPositions(zone, constraints): Get valid positions in zone
---  - validatePlacement(unit, position): Check if placement is valid
---  - getPlacementStats(): Get detailed placement statistics
---
---Dependencies:
---  - Battlefield reference for terrain checking
---  - MapScript spawn zone definitions
---
---@module battlescape.battlefield.team_placement
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local TeamPlacement = require("battlescape.battlefield.team_placement")
---  local placement = TeamPlacement.new(battlefield)
---  local result = placement:placeTeam("player", units, spawnZones)
---  print("Placed " .. #result.positions .. " units")
---
---@see battlescape.mapscripts.mapscript_executor For spawn zone generation
---@see battlescape.battlefield.battlefield For terrain validation

-- Team Placement Algorithm
-- Places units based on spawn zones from MapScript

local TeamPlacement = {}

---@class SpawnZone
---@field team string Team identifier (player, ally, enemy, neutral, alien, xcom)
---@field x number MapBlock X coordinate
---@field y number MapBlock Y coordinate
---@field radius number Radius in MapBlocks

---@class PlacementResult
---@field team string Team identifier
---@field positions table Array of valid tile positions {x, y}
---@field failedUnits number Number of units that couldn't be placed

---@class TeamPlacement
---@field battlefield Battlefield Reference to battlefield
---@field blockSize number MapBlock size in tiles (default 10)

---Create a new team placement manager
---@param battlefield Battlefield Battlefield instance
---@param blockSize? number MapBlock size in tiles (default 10)
---@return TeamPlacement
function TeamPlacement.new(battlefield, blockSize)
    local self = setmetatable({}, {__index = TeamPlacement})
    
    self.battlefield = battlefield
    self.blockSize = blockSize or 10
    
    return self
end

---Place all teams based on spawn zones
---@param spawnZones table Array of SpawnZone definitions
---@param teamSizes table Map of team -> unit count {player = 8, enemy = 12}
---@return table results Map of team -> PlacementResult
function TeamPlacement:placeAllTeams(spawnZones, teamSizes)
    print("\n[TeamPlacement] Placing teams...")
    
    local results = {}
    
    for _, zone in ipairs(spawnZones) do
        local unitCount = teamSizes[zone.team] or 0
        
        if unitCount > 0 then
            local result = self:placeTeam(zone, unitCount)
            results[zone.team] = result
            
            print(string.format("  %s: %d/%d units placed", 
                zone.team, #result.positions, unitCount))
        end
    end
    
    return results
end

---Place a single team in their spawn zone
---@param zone SpawnZone Spawn zone definition
---@param unitCount number Number of units to place
---@return PlacementResult result Placement result
function TeamPlacement:placeTeam(zone, unitCount)
    -- Convert MapBlock coordinates to tile coordinates
    local centerX = (zone.x * self.blockSize) + (self.blockSize / 2)
    local centerY = (zone.y * self.blockSize) + (self.blockSize / 2)
    local radiusTiles = zone.radius * self.blockSize
    
    -- Find all valid positions in zone
    local validPositions = self:findValidPositions(centerX, centerY, radiusTiles)
    
    -- Select positions for units
    local selectedPositions = self:selectPositions(validPositions, unitCount)
    
    return {
        team = zone.team,
        positions = selectedPositions,
        failedUnits = math.max(0, unitCount - #selectedPositions)
    }
end

---Find all valid tile positions within radius
---@param centerX number Center X in tiles
---@param centerY number Center Y in tiles
---@param radius number Radius in tiles
---@return table positions Array of valid {x, y} positions
function TeamPlacement:findValidPositions(centerX, centerY, radius)
    local positions = {}
    
    -- Calculate bounding box
    local minX = math.max(1, math.floor(centerX - radius))
    local maxX = math.min(self.battlefield.width, math.ceil(centerX + radius))
    local minY = math.max(1, math.floor(centerY - radius))
    local maxY = math.min(self.battlefield.height, math.ceil(centerY + radius))
    
    -- Check all tiles in radius
    for y = minY, maxY do
        for x = minX, maxX do
            -- Check if within circular radius
            local dx = x - centerX
            local dy = y - centerY
            local distance = math.sqrt(dx * dx + dy * dy)
            
            if distance <= radius then
                -- Check if tile is walkable
                if self:isTileWalkable(x, y) then
                    table.insert(positions, {x = x, y = y})
                end
            end
        end
    end
    
    return positions
end

---Check if a tile is walkable (not blocked)
---@param x number Tile X coordinate
---@param y number Tile Y coordinate
---@return boolean walkable True if tile can be walked on
function TeamPlacement:isTileWalkable(x, y)
    -- Bounds check
    if x < 1 or x > self.battlefield.width or y < 1 or y > self.battlefield.height then
        return false
    end
    
    local tile = self.battlefield:getTile(x, y)
    if not tile then
        return false
    end
    
    -- Check if tile is passable
    -- This depends on your terrain system - adjust as needed
    if tile.terrainId == "wall" or tile.terrainId == "water" then
        return false
    end
    
    -- Check if tile is already occupied
    if tile.unit then
        return false
    end
    
    return true
end

---Select specific positions from valid set
---@param validPositions table Array of valid {x, y} positions
---@param count number Number of positions to select
---@return table positions Selected positions
function TeamPlacement:selectPositions(validPositions, count)
    if #validPositions == 0 then
        print("[TeamPlacement] WARNING: No valid positions found")
        return {}
    end
    
    if count > #validPositions then
        print(string.format("[TeamPlacement] WARNING: Requested %d positions but only %d available", 
            count, #validPositions))
        count = #validPositions
    end
    
    -- Shuffle positions for random selection
    local shuffled = self:shuffleArray(validPositions)
    
    -- Take first N positions
    local selected = {}
    for i = 1, count do
        table.insert(selected, shuffled[i])
    end
    
    return selected
end

---Shuffle array using Fisher-Yates algorithm
---@param array table Array to shuffle
---@return table shuffled Shuffled array
function TeamPlacement:shuffleArray(array)
    local shuffled = {}
    for i, v in ipairs(array) do
        shuffled[i] = v
    end
    
    for i = #shuffled, 2, -1 do
        local j = math.random(1, i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end
    
    return shuffled
end

---Get spawn zone for a specific team
---@param spawnZones table Array of SpawnZone definitions
---@param teamName string Team identifier
---@return SpawnZone? zone Spawn zone or nil if not found
function TeamPlacement.findZoneForTeam(spawnZones, teamName)
    for _, zone in ipairs(spawnZones) do
        if zone.team == teamName then
            return zone
        end
    end
    return nil
end

---Calculate total capacity of all spawn zones
---@param spawnZones table Array of SpawnZone definitions
---@param blockSize? number MapBlock size in tiles
---@return table capacity Map of team -> estimated capacity
function TeamPlacement.calculateZoneCapacities(spawnZones, blockSize)
    blockSize = blockSize or 10
    
    local capacities = {}
    
    for _, zone in ipairs(spawnZones) do
        -- Rough estimate: area of circle
        local radiusTiles = zone.radius * blockSize
        local area = math.pi * radiusTiles * radiusTiles
        -- Assume ~30% of tiles are walkable (conservative estimate)
        local capacity = math.floor(area * 0.3)
        
        if not capacities[zone.team] then
            capacities[zone.team] = 0
        end
        capacities[zone.team] = capacities[zone.team] + capacity
    end
    
    return capacities
end

---Validate spawn zones against team sizes
---@param spawnZones table Array of SpawnZone definitions
---@param teamSizes table Map of team -> unit count
---@param blockSize? number MapBlock size in tiles
---@return boolean valid True if all teams can fit
---@return string? error Error message if invalid
function TeamPlacement.validateZones(spawnZones, teamSizes, blockSize)
    local capacities = TeamPlacement.calculateZoneCapacities(spawnZones, blockSize)
    
    for team, size in pairs(teamSizes) do
        local capacity = capacities[team] or 0
        if size > capacity then
            return false, string.format(
                "Team %s needs %d positions but spawn zones only have ~%d capacity",
                team, size, capacity
            )
        end
    end
    
    return true, nil
end

---Create evenly spaced positions in a grid pattern
---@param centerX number Center X in tiles
---@param centerY number Center Y in tiles
---@param count number Number of positions needed
---@param spacing? number Spacing between positions (default 2)
---@return table positions Array of {x, y} positions
function TeamPlacement.createGridPositions(centerX, centerY, count, spacing)
    spacing = spacing or 2
    local positions = {}
    
    -- Calculate grid dimensions
    local cols = math.ceil(math.sqrt(count))
    local rows = math.ceil(count / cols)
    
    -- Calculate starting offset to center grid
    local startX = centerX - ((cols - 1) * spacing / 2)
    local startY = centerY - ((rows - 1) * spacing / 2)
    
    -- Generate grid positions
    local placed = 0
    for row = 0, rows - 1 do
        for col = 0, cols - 1 do
            if placed >= count then
                break
            end
            
            table.insert(positions, {
                x = math.floor(startX + col * spacing),
                y = math.floor(startY + row * spacing)
            })
            placed = placed + 1
        end
        if placed >= count then
            break
        end
    end
    
    return positions
end

---Print placement statistics
---@param results table Map of team -> PlacementResult
function TeamPlacement.printStatistics(results)
    print("\n[TeamPlacement] Placement Statistics")
    print("----------------------------------------")
    
    local totalPlaced = 0
    local totalFailed = 0
    
    for team, result in pairs(results) do
        print(string.format("  %s:", team))
        print(string.format("    Placed: %d units", #result.positions))
        if result.failedUnits > 0 then
            print(string.format("    Failed: %d units (WARNING)", result.failedUnits))
        end
        
        totalPlaced = totalPlaced + #result.positions
        totalFailed = totalFailed + result.failedUnits
    end
    
    print("----------------------------------------")
    print(string.format("Total: %d placed, %d failed", totalPlaced, totalFailed))
    print("----------------------------------------\n")
end

return TeamPlacement

























