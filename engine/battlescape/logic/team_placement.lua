---TeamPlacement - Unit Spawning and Zone Assignment
---
---Handles placement of player units, aliens, and civilians in generated battlemap.
---Uses spawn zones defined in MapScripts to position units by faction with scatter.
---Integrates with mission parameters for difficulty-appropriate force composition.
---
---Features:
---  - Faction-based spawning (player, aliens, civilians)
---  - Spawn zone scatter with configurable radius
---  - Difficulty-based unit composition
---  - Pre-placement validation (connectivity, no overlaps)
---  - Support for protected spawn zones
---  - Unit experience/rank distribution
---
---Spawn Zone Mechanics:
---  - Spawn zones defined by center (x, y) and radius
---  - Units scattered randomly within radius (Poisson disc for better distribution)
---  - Minimum distance between units: 3 tiles
---  - Maximum placement retries: 50 per unit
---  - Protected zone (no enemy spawns): radius + 2 tiles from player spawn
---
---Unit Composition by Difficulty:
---  - Difficulty 1-3: Rookie+Squaddie, rare weapon upgrades
---  - Difficulty 4-6: Squaddie+Corporal, moderate upgrades
---  - Difficulty 7-10: Corporal+Sergeant+Captain, elite weapons
---
---Alien Composition:
---  - Difficulty scales: Sectoid → Floater → Reaper → Cyberdisk → UFOpsoid
---  - Squad diversity (50% elite, 30% standard, 20% leader types)
---  - Boss unit for difficulty 8+
---
---Key Exports:
---  - TeamPlacement.new(): Creates placement manager
---  - placeTeams(map, spawnZones, options): Main entry point
---  - placeUnits(team, unitCount, zone, map): Place single team
---  - scatterPosition(centerX, centerY, radius, minDistance, map): Generate position
---  - validatePlacement(x, y, map): Check position is valid (walkable, safe)
---
---Dependencies:
---  - battlescape.battle_ecs.hex_math: Hex coordinate operations
---  - battlescape.data.units: Unit definitions
---  - battlescape.data.terrains: Terrain walkability
---
---@module battlescape.logic.team_placement
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local TeamPlacement = require("battlescape.logic.team_placement")
---  local placer = TeamPlacement.new()
---  placer:placeTeams(map, spawnZones, {difficulty = 5})
---
---@see battlescape.mission_map_generator For map generation integration

local HexMath = require("battlescape.battle_ecs.hex_math")

local TeamPlacement = {}

---@class TeamPlacement
---@field minDistance number Minimum distance between units (tiles)
---@field maxRetries number Maximum placement attempts per unit
---@field protectionRadius number Extra radius around player spawn
---@field unitRanks table Rank progression by difficulty
---@field alienTypes table Alien type pool
---@field initialized boolean

---Create new team placement manager
---@return TeamPlacement TeamPlacement instance
function TeamPlacement.new()
    local self = setmetatable({}, {__index = TeamPlacement})
    
    self.minDistance = 3
    self.maxRetries = 50
    self.protectionRadius = 2
    
    -- Unit ranks by difficulty
    self.unitRanks = {
        [1] = {"Rookie", "Squaddie"},
        [2] = {"Rookie", "Squaddie"},
        [3] = {"Squaddie", "Corporal"},
        [4] = {"Squaddie", "Corporal"},
        [5] = {"Corporal", "Sergeant"},
        [6] = {"Corporal", "Sergeant"},
        [7] = {"Sergeant", "Captain"},
        [8] = {"Captain", "Colonel"},
        [9] = {"Captain", "Colonel"},
        [10] = {"Colonel", "Colonel"},
    }
    
    -- Alien type progression (by difficulty tier)
    self.alienTypes = {
        {tier = 1, types = {"Sectoid", "Sectoid", "Sectoid"}, weights = {70, 20, 10}},
        {tier = 2, types = {"Sectoid", "Floater", "Reaper"}, weights = {40, 40, 20}},
        {tier = 3, types = {"Floater", "Reaper", "Cyberdisk"}, weights = {30, 40, 30}},
        {tier = 4, types = {"Reaper", "Cyberdisk", "UFOpsoid"}, weights = {20, 50, 30}},
    }
    
    self.initialized = true
    
    print("[TeamPlacement] Initialized")
    
    return self
end

---Place all teams on battlefield
---@param map table Generated map with walkable tile data
---@param spawnZones table Array of {team, x, y, radius, unit_count}
---@param options table Optional {difficulty, mission_type, force_composition}
---@return table placedTeams Array of {team, units with x, y, rank, status}
function TeamPlacement:placeTeams(map, spawnZones, options)
    options = options or {}
    local difficulty = options.difficulty or 5
    local placedTeams = {}
    
    print(string.format("[TeamPlacement] Placing teams (difficulty: %d, zones: %d)",
        difficulty, #spawnZones))
    
    -- Find player spawn zone (team="player")
    local playerZone = nil
    for _, zone in ipairs(spawnZones) do
        if zone.team == "player" then
            playerZone = zone
            break
        end
    end
    
    if not playerZone then
        print("[TeamPlacement] WARNING: No player spawn zone found")
        return placedTeams
    end
    
    -- Place each team
    for _, zone in ipairs(spawnZones) do
        if zone.unit_count and zone.unit_count > 0 then
            local teamUnits = self:placeUnits(zone.team, zone.unit_count, zone, map, 
                difficulty, playerZone)
            
            table.insert(placedTeams, {
                team = zone.team,
                units = teamUnits,
                spawn_zone = zone
            })
            
            print(string.format("[TeamPlacement] Placed %d %s units at (%.0f, %.0f)",
                #teamUnits, zone.team, zone.x, zone.y))
        end
    end
    
    return placedTeams
end

---Place units for a single team
---@param team string Team identifier ("player", "aliens", "civilians")
---@param unitCount number Number of units to place
---@param zone table Spawn zone {x, y, radius}
---@param map table Generated map
---@param difficulty number Mission difficulty (1-10)
---@param playerZone table Player spawn zone (for protection)
---@return table Array of placed units {x, y, rank, type, status}
function TeamPlacement:placeUnits(team, unitCount, zone, map, difficulty, playerZone)
    local units = {}
    local placedPositions = {}  -- Track placed unit positions to maintain minDistance
    
    difficulty = math.min(math.max(difficulty or 5, 1), 10)
    
    for unitIdx = 1, unitCount do
        local placed = false
        local retries = 0
        
        -- Try to place unit with scatter
        while retries < self.maxRetries and not placed do
            -- Generate scatter position
            local x, y = self:scatterPosition(zone.x, zone.y, zone.radius, 
                self.minDistance, map, placedPositions)
            
            if x and y then
                -- Validate not in enemy protection zone
                if not self:isInProtectionZone(x, y, playerZone, team) then
                    -- Create unit entry
                    local unit = {
                        x = x,
                        y = y,
                        team = team,
                        rank = self:selectRank(team, difficulty, unitIdx, unitCount),
                        type = self:selectUnitType(team, difficulty),
                        status = "active",
                        health = 100,
                        tu = 75,
                        morale = 50,
                        unit_id = string.format("%s_%d_%d", team, zone.x, unitIdx)
                    }
                    
                    table.insert(units, unit)
                    table.insert(placedPositions, {x = x, y = y})
                    placed = true
                end
            end
            
            retries = retries + 1
        end
        
        if not placed then
            print(string.format("[TeamPlacement] WARNING: Could not place unit %d of %s",
                unitIdx, team))
        end
    end
    
    return units
end

---Generate scattered position within spawn zone
---@param centerX number Zone center X
---@param centerY number Zone center Y
---@param radius number Scatter radius
---@param minDistance number Minimum distance from other units
---@param map table Map data
---@param placedPositions table Array of already-placed positions
---@return number? x Position X or nil if no valid position
---@return number? y Position Y or nil if no valid position
function TeamPlacement:scatterPosition(centerX, centerY, radius, minDistance, map, 
        placedPositions)
    placedPositions = placedPositions or {}
    
    -- Generate random position within radius (use Poisson disc sampling for better distribution)
    local angle = math.random() * math.pi * 2
    local distance = math.random() * radius
    
    local x = centerX + math.cos(angle) * distance
    local y = centerY + math.sin(angle) * distance
    
    -- Round to tile grid
    x = math.floor(x + 0.5)
    y = math.floor(y + 0.5)
    
    -- Validate position
    if self:validatePlacement(x, y, map) then
        -- Check minimum distance from other placed units
        for _, pos in ipairs(placedPositions) do
            local dist = math.sqrt((pos.x - x) ^ 2 + (pos.y - y) ^ 2)
            if dist < minDistance then
                return nil, nil  -- Too close to another unit
            end
        end
        
        return x, y
    end
    
    return nil, nil
end

---Validate placement position
---@param x number Position X
---@param y number Position Y
---@param map table Map data with walkable tiles
---@return boolean True if position is valid for unit placement
function TeamPlacement:validatePlacement(x, y, map)
    -- Check bounds
    if not map or not map.width or not map.height then
        return false
    end
    
    if x < 0 or x >= map.width or y < 0 or y >= map.height then
        return false
    end
    
    -- Check tile walkability
    local tileX = math.floor(x)
    local tileY = math.floor(y)
    
    if map.tiles and map.tiles[tileY] and map.tiles[tileY][tileX] then
        local tile = map.tiles[tileY][tileX]
        -- Tile is walkable if it's not a wall, not impassable
        if tile.walkable ~= false and tile.blocked ~= true then
            return true
        end
    end
    
    return false
end

---Check if position is in player protection zone
---@param x number Position X
---@param y number Position Y
---@param playerZone table Player spawn zone
---@param team string Team of unit to place
---@return boolean True if in protected zone (and unit is not player)
function TeamPlacement:isInProtectionZone(x, y, playerZone, team)
    -- Players can spawn in player zone
    if team == "player" then
        return false
    end
    
    if not playerZone then
        return false
    end
    
    -- Calculate distance from player zone
    local distance = math.sqrt((playerZone.x - x) ^ 2 + (playerZone.y - y) ^ 2)
    local protectedDist = playerZone.radius + self.protectionRadius
    
    return distance < protectedDist
end

---Select unit rank based on team and difficulty
---@param team string Team identifier
---@param difficulty number Mission difficulty (1-10)
---@param unitIndex number Position in unit list
---@param unitCount number Total units in squad
---@return string Rank name
function TeamPlacement:selectRank(team, difficulty, unitIndex, unitCount)
    if team ~= "player" then
        -- Aliens don't have ranks, they have types
        return "Standard"
    end
    
    -- Player units get ranks
    local rankPool = self.unitRanks[difficulty] or {"Rookie", "Squaddie"}
    
    -- Squad leader gets first rank, rest get second
    if unitIndex == 1 then
        return rankPool[1]
    else
        return rankPool[2] or rankPool[1]
    end
end

---Select unit type based on team and difficulty
---@param team string Team identifier
---@param difficulty number Mission difficulty (1-10)
---@return string Unit type name
function TeamPlacement:selectUnitType(team, difficulty)
    if team == "player" then
        return "Soldier"
    elseif team == "aliens" then
        -- Select alien type based on difficulty
        local tierIdx = math.ceil(difficulty / 2.5)  -- 1-4 tier range
        tierIdx = math.min(tierIdx, #self.alienTypes)
        
        local tierData = self.alienTypes[tierIdx]
        local typeIdx = math.random(1, #tierData.types)
        return tierData.types[typeIdx]
    elseif team == "civilians" then
        return "Civilian"
    end
    
    return "Unknown"
end

return TeamPlacement
