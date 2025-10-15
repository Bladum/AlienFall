--- VisibilitySystem
--- Handles team-based line-of-sight and visibility calculations
--- Uses ray-casting to determine what each team can see

local Constants = require("config.constants")

--- @class VisibilitySystem
local VisibilitySystem = {}

--- Calculate line-of-sight from one point to another using Bresenham's line algorithm
--- Returns true if there is a clear line of sight, false if blocked by walls
--- @param map table 2D array of Tile objects [y][x]
--- @param x1 number Start X coordinate
--- @param y1 number Start Y coordinate
--- @param x2 number Target X coordinate
--- @param y2 number Target Y coordinate
--- @return boolean hasLOS True if line of sight exists
--- @return table tiles Array of {x, y} coordinates along the line
function VisibilitySystem.calculateLOS(map, x1, y1, x2, y2)
    -- Bresenham's line algorithm
    local tiles = {}
    
    local dx = math.abs(x2 - x1)
    local dy = math.abs(y2 - y1)
    local sx = x1 < x2 and 1 or -1
    local sy = y1 < y2 and 1 or -1
    local err = dx - dy
    
    local x, y = x1, y1
    
    while true do
        -- Add current tile to path
        table.insert(tiles, {x = x, y = y})
        
        -- Check if this tile blocks LOS (but not the starting tile)
        if not (x == x1 and y == y1) then
            if not map[y] or not map[y][x] then
                -- Out of bounds blocks LOS
                return false, tiles
            end
            
            if map[y][x]:blocksLOS() then
                -- Hit a wall, LOS is blocked
                return false, tiles
            end
        end
        
        -- Check if we've reached the target
        if x == x2 and y == y2 then
            return true, tiles
        end
        
        -- Bresenham step
        local e2 = 2 * err
        if e2 > -dy then
            err = err - dy
            x = x + sx
        end
        if e2 < dx then
            err = err + dx
            y = y + sy
        end
    end
end

--- Calculate visibility for a single unit
--- Marks all tiles within LOS range as visible for the unit's team
--- @param unit table Unit object with gridX, gridY, losRange, teamId
--- @param map table 2D array of Tile objects [y][x]
--- @param gridWidth number Map width
--- @param gridHeight number Map height
--- @return number visibleCount Number of tiles made visible
function VisibilitySystem.calculateUnitVisibility(unit, map, gridWidth, gridHeight)
    local ux = unit.gridX
    local uy = unit.gridY
    local range = unit.losRange or Constants.LOS_RANGE
    local teamId = unit.teamId
    
    local visibleCount = 0
    
    -- Always see the tile we're standing on
    if map[uy] and map[uy][ux] then
        map[uy][ux]:setVisibility(teamId, Constants.VISIBILITY.VISIBLE)
        visibleCount = visibleCount + 1
    end
    
    -- Check all tiles within range
    local rangeSquared = range * range
    
    for y = 1, gridHeight do
        for x = 1, gridWidth do
            -- Skip the unit's own tile (already processed)
            if not (x == ux and y == uy) then
                -- Check if tile is within range (using distance squared for efficiency)
                local dx = x - ux
                local dy = y - uy
                local distSquared = dx * dx + dy * dy
                
                if distSquared <= rangeSquared then
                    -- Tile is in range, check LOS
                    local hasLOS = VisibilitySystem.calculateLOS(map, ux, uy, x, y)
                    
                    if hasLOS then
                        -- Mark as visible for this team
                        map[y][x]:setVisibility(teamId, Constants.VISIBILITY.VISIBLE)
                        visibleCount = visibleCount + 1
                    end
                end
            end
        end
    end
    
    return visibleCount
end

--- Calculate visibility for an entire team
--- Combines LOS from all units on the team
--- Any tile seen by any unit is visible to the whole team
--- @param team table Team object with getUnits() method
--- @param map table 2D array of Tile objects [y][x]
--- @param gridWidth number Map width
--- @param gridHeight number Map height
--- @return number visibleCount Total unique tiles visible to team
function VisibilitySystem.calculateTeamVisibility(team, map, gridWidth, gridHeight)
    local teamId = team.id
    local units = team:getUnits()
    
    -- First pass: Mark all previously visible tiles as explored
    for y = 1, gridHeight do
        for x = 1, gridWidth do
            if map[y] and map[y][x] then
                local currentVis = map[y][x]:getVisibility(teamId)
                if currentVis == Constants.VISIBILITY.VISIBLE then
                    -- Was visible, now just explored (will be re-marked if still visible)
                    map[y][x]:setVisibility(teamId, Constants.VISIBILITY.EXPLORED)
                end
            end
        end
    end
    
    -- Second pass: Calculate visibility from each unit
    local totalVisible = 0
    for _, unit in ipairs(units) do
        if unit:isAlive() then
            local unitVisible = VisibilitySystem.calculateUnitVisibility(
                unit, map, gridWidth, gridHeight
            )
            totalVisible = totalVisible + unitVisible
        end
    end
    
    return totalVisible
end

--- Update visibility for all teams
--- Call this when units move or at the start of each turn
--- @param teams table Array of Team objects
--- @param map table 2D array of Tile objects [y][x]
--- @param gridWidth number Map width
--- @param gridHeight number Map height
--- @param silent boolean Optional: if true, suppress debug output
function VisibilitySystem.updateAllTeams(teams, map, gridWidth, gridHeight, silent)
    for _, team in pairs(teams) do
        if team and team:hasActiveUnits() then
            local visible = VisibilitySystem.calculateTeamVisibility(
                team, map, gridWidth, gridHeight
            )
            -- Debug output (optional)
            if not silent and team.name then
                print(string.format("Team %s can see %d tiles", team.name, visible))
            end
        end
    end
end

--- Check if a tile is visible to a specific team
--- @param map table 2D array of Tile objects
--- @param x number Grid X coordinate
--- @param y number Grid Y coordinate
--- @param teamId number Team ID to check
--- @return boolean isVisible True if team can see this tile
function VisibilitySystem.isVisibleToTeam(map, x, y, teamId)
    if not map[y] or not map[y][x] then
        return false
    end
    
    local visibility = map[y][x]:getVisibility(teamId)
    return visibility == Constants.VISIBILITY.VISIBLE
end

--- Check if a tile has been explored by a team (seen before but not currently visible)
--- @param map table 2D array of Tile objects
--- @param x number Grid X coordinate
--- @param y number Grid Y coordinate
--- @param teamId number Team ID to check
--- @return boolean isExplored True if team has explored this tile
function VisibilitySystem.isExploredByTeam(map, x, y, teamId)
    if not map[y] or not map[y][x] then
        return false
    end
    
    local visibility = map[y][x]:getVisibility(teamId)
    return visibility == Constants.VISIBILITY.EXPLORED
end

--- Get brightness modifier for rendering based on visibility state
--- @param tile table Tile object
--- @param teamId number Team ID viewing the tile
--- @return number brightness Multiplier for rendering (0.0 to 1.0)
function VisibilitySystem.getBrightness(tile, teamId)
    -- TEMP: Make all tiles visible for debugging
    return 1.0
    
    -- local visibility = tile:getVisibility(teamId)
    
    -- if visibility == Constants.VISIBILITY.VISIBLE then
    --     return 1.0  -- Full brightness
    -- elseif visibility == Constants.VISIBILITY.EXPLORED then
    --     return 0.3  -- Dimmed (fog of war)
    -- else -- HIDDEN
    --     return 0.0  -- Completely dark
    -- end
end

--- Check if a unit can see another unit
--- @param observer table Observer unit
--- @param target table Target unit
--- @param map table 2D array of Tile objects
--- @return boolean canSee True if observer has LOS to target
function VisibilitySystem.canSeeUnit(observer, target, map)
    if not observer:isAlive() or not target:isAlive() then
        return false
    end
    
    -- Check distance first (optimization)
    local dx = target.gridX - observer.gridX
    local dy = target.gridY - observer.gridY
    local distSquared = dx * dx + dy * dy
    local rangeSquared = (observer.losRange or Constants.LOS_RANGE) ^ 2
    
    if distSquared > rangeSquared then
        return false
    end
    
    -- Check LOS
    local hasLOS = VisibilitySystem.calculateLOS(
        map,
        observer.gridX, observer.gridY,
        target.gridX, target.gridY
    )
    
    return hasLOS
end

--- Get all visible enemies for a unit
--- @param unit table Observer unit
--- @param teams table Array of all teams
--- @param map table 2D array of Tile objects
--- @return table visibleEnemies Array of enemy units that can be seen
function VisibilitySystem.getVisibleEnemies(unit, teams, map)
    local visibleEnemies = {}
    
    for _, team in pairs(teams) do
        -- Check if this is an enemy team
        if team.id ~= unit.teamId then
            for _, enemy in ipairs(team:getUnits()) do
                if enemy:isAlive() and VisibilitySystem.canSeeUnit(unit, enemy, map) then
                    table.insert(visibleEnemies, enemy)
                end
            end
        end
    end
    
    return visibleEnemies
end

--- Cast a ray and return all tiles along the path until blocked or max range
--- Useful for projectile paths, smoke effects, etc.
--- @param map table 2D array of Tile objects
--- @param x1 number Start X
--- @param y1 number Start Y
--- @param dirX number Direction X (-1, 0, or 1)
--- @param dirY number Direction Y (-1, 0, or 1)
--- @param maxRange number Maximum distance to cast
--- @return table tiles Array of {x, y} coordinates along ray
--- @return boolean blocked True if ray was blocked by wall
function VisibilitySystem.castRay(map, x1, y1, dirX, dirY, maxRange)
    local tiles = {}
    local blocked = false
    
    -- Normalize direction
    local length = math.sqrt(dirX * dirX + dirY * dirY)
    if length > 0 then
        dirX = dirX / length
        dirY = dirY / length
    end
    
    -- Cast ray by stepping along direction
    for i = 0, maxRange do
        local x = math.floor(x1 + dirX * i + 0.5)
        local y = math.floor(y1 + dirY * i + 0.5)
        
        table.insert(tiles, {x = x, y = y})
        
        -- Check if blocked
        if map[y] and map[y][x] then
            if map[y][x]:blocksLOS() then
                blocked = true
                break
            end
        else
            -- Out of bounds
            blocked = true
            break
        end
    end
    
    return tiles, blocked
end

return VisibilitySystem






















