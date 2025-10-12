--- Unit System
--- Manages unit entities, stats, equipment, and combat state.
---
--- This module provides the Unit class representing characters in combat.
--- Units have stats loaded from TOML definitions, equipment that modifies
--- stats, and combat state including health, energy, and action points.
---
--- Example usage:
---   local Unit = require("systems.unit")
---   local soldier = Unit.new("soldier", "player", 5, 10)
---   soldier:takeDamage(20)
---   print(soldier.health)

local DataLoader = require("systems.data_loader")

--- Unit entity representing a character in combat.
---
--- Units have stats, equipment, position, and combat state.
--- They can move, attack, and use items during tactical battles.
---
--- @class Unit
--- @field id number Unique identifier (set by battlefield)
--- @field classId string Unit class ("soldier", "alien", etc.)
--- @field name string Display name
--- @field x number Grid X position
--- @field y number Grid Y position
--- @field health number Current hit points
--- @field maxHealth number Maximum hit points
--- @field energy number Current energy points
--- @field maxEnergy number Maximum energy points
--- @field team string Team identifier
--- @field stats table Current stats (base + equipment modifiers)
--- @field baseStats table Base stats from class definition
--- @field weapon1 string|nil Primary weapon ID
--- @field weapon2 string|nil Secondary weapon ID
--- @field armour string|nil Armor ID
--- @field statusEffects table Active status effects
--- @field facing number Direction unit is facing (0-7)
--- @field killed boolean Whether unit is dead
--- @field unconscious boolean Whether unit is unconscious
--- @field sprite table|nil Unit sprite image (Love2D Image object)
local Unit = {}
Unit.__index = Unit

--- Create a new Unit instance.
---
--- Initializes a unit with the given class and position.
--- Loads stats from DataLoader and applies equipment modifiers.
--- Returns nil if the class definition is not found.
---
--- @param classId string Unit class identifier (e.g., "soldier", "alien")
--- @param team string Team identifier
--- @param x number Grid X position (default: 1)
--- @param y number Grid Y position (default: 1)
--- @return Unit|nil New unit instance or nil if class not found
--- @usage
---   local unit = Unit.new("soldier", "player", 5, 10)
---   if unit then print(unit.name) end
function Unit.new(classId, team, x, y)
    local self = setmetatable({}, Unit)

    -- Basic properties
    self.id = nil  -- Set by battlefield when added
    self.classId = classId
    self.name = ""
    self.team = team
    self.x = x or 1
    self.y = y or 1
    self.alive = true
    
    -- Animation properties
    self.animX = x or 1
    self.animY = y or 1
    
    -- Performance optimization: dirty flag for visibility recalculation
    self.visibilityDirty = true  -- Needs LOS recalculation

    -- Load class definition from DataLoader
    local classDef = DataLoader.unitClasses.get(classId)
    if not classDef then
        print("[ERROR] Unit class not found: " .. classId)
        return nil
    end

    -- Initialize stats from class
    self.baseStats = {}
    for stat, value in pairs(classDef.baseStats) do
        self.baseStats[stat] = value
    end

    -- Equipment
    self.weapon1 = classDef.defaultWeapon1
    self.weapon2 = classDef.defaultWeapon2
    self.armour = classDef.defaultArmour

    -- Current stats (base + equipment modifiers)
    self.stats = {}
    self:updateStats()

    -- Action system
    self.actionPointsLeft = 4  -- Fixed AP per turn
    self.movementPoints = self:calculateMP()
    self.hasActed = false

    -- Combat state
    self.health = self.stats.health
    self.maxHealth = self.stats.health
    self.energy = self.stats.energy
    self.maxEnergy = self.stats.energy

    -- Status effects
    self.statusEffects = {}

    -- Generate name
    self.name = self:generateName()

    return self
end

--- Update current stats based on base stats plus equipment modifiers.
---
--- Recalculates stats from baseStats, then applies weapon and armour
--- modifiers. Enforces minimum values for speed, health, sight, sense.
--- Should be called after changing equipment.
---
--- @return nil
function Unit:updateStats()
    -- Start with base stats
    for stat, value in pairs(self.baseStats) do
        self.stats[stat] = value
    end

    -- Apply weapon modifiers
    if self.weapon1 then
        local weapon = DataLoader.weapons.get(self.weapon1)
        if weapon and weapon.statMods then
            for stat, mod in pairs(weapon.statMods) do
                self.stats[stat] = (self.stats[stat] or 0) + mod
            end
        end
    end

    if self.weapon2 then
        local weapon = DataLoader.weapons.get(self.weapon2)
        if weapon and weapon.statMods then
            for stat, mod in pairs(weapon.statMods) do
                self.stats[stat] = (self.stats[stat] or 0) + mod
            end
        end
    end

    -- Apply armour modifiers
    if self.armour then
        local armour = DataLoader.armours.get(self.armour)
        if armour then
            -- Armour value
            self.stats.armour = (self.stats.armour or 0) + armour.armourValue

            -- Mobility penalty
            if armour.mobilityPenalty and armour.mobilityPenalty > 0 then
                self.stats.speed = math.max(1, self.stats.speed - armour.mobilityPenalty)
            end

            -- Other stat mods
            if armour.statMods then
                for stat, mod in pairs(armour.statMods) do
                    self.stats[stat] = (self.stats[stat] or 0) + mod
                end
            end
        end
    end

    -- Ensure minimum values
    self.stats.speed = math.max(1, self.stats.speed)
    self.stats.health = math.max(1, self.stats.health)
    self.stats.sight = math.max(1, self.stats.sight)
    self.stats.sense = math.max(0, self.stats.sense)
end

--- Calculate total movement points from remaining action points.
---
--- Movement points = actionPointsLeft × speed stat.
--- Used to determine how far a unit can move in their remaining turn.
---
--- @return number Total movement points available
function Unit:calculateMP()
    return self.actionPointsLeft * self.stats.speed
end

--- Spend movement points and update action points accordingly.
---
--- Reduces movementPoints by amount, then recalculates actionPointsLeft
--- based on speed. Use this when moving on the map.
---
--- @param amount number Movement points to spend
--- @return nil
function Unit:spendMP(amount)
    self.movementPoints = math.max(0, self.movementPoints - amount)
    self.actionPointsLeft = math.floor(self.movementPoints / self.stats.speed)
end

--- Spend action points directly and update movement points.
---
--- Reduces actionPointsLeft by amount, then recalculates movementPoints
--- based on speed. Use this for actions like shooting or using items.
---
--- @param amount number Action points to spend
--- @return nil
function Unit:spendAP(amount)
    self.actionPointsLeft = math.max(0, self.actionPointsLeft - amount)
    self.movementPoints = self:calculateMP()
end

--- Reset unit resources at start of turn.
---
--- Sets actionPointsLeft to 4, recalculates movementPoints,
--- and clears hasActed flag. Called by turn manager.
---
--- @return nil
function Unit:resetForTurn()
    self.actionPointsLeft = 4
    self.movementPoints = self:calculateMP()
    self.hasActed = false
end

--- Check if unit occupies a specific tile.
---
--- Handles multi-tile units (size > 1). A unit occupies all tiles
--- from (x, y) to (x + size-1, y + size-1).
---
--- @param x number Tile X coordinate
--- @param y number Tile Y coordinate
--- @return boolean True if unit occupies this tile
function Unit:occupiesTile(x, y)
    for oy = 0, self.stats.size - 1 do
        for ox = 0, self.stats.size - 1 do
            if self.x + ox == x and self.y + oy == y then
                return true
            end
        end
    end
    return false
end

--- Get list of all tiles occupied by this unit.
---
--- Returns array of {x, y} tables for each tile the unit occupies.
--- Useful for pathfinding and collision detection.
---
--- @return table Array of {x=number, y=number} tables
function Unit:getOccupiedTiles()
    local tiles = {}
    for oy = 0, self.stats.size - 1 do
        for ox = 0, self.stats.size - 1 do
            table.insert(tiles, {x = self.x + ox, y = self.y + oy})
        end
    end
    return tiles
end

--- Move unit to new position on the map.
---
--- Updates x, y coordinates and animation position. Marks unit visibility
--- as dirty to trigger LOS recalculation. Does not check for obstacles
--- or spend action points - caller must validate move first.
---
--- @param x number New grid X position
--- @param y number New grid Y position
--- @return nil
function Unit:moveTo(x, y)
    self.x = x
    self.y = y
    -- Update animation position to match
    self.animX = x
    self.animY = y
    -- Mark unit as needing visibility recalculation
    self.visibilityDirty = true
end

--- Apply damage to unit, accounting for armour.
---
--- Calculates actual damage as max(0, amount - armour stat).
--- Reduces health and sets alive=false if health reaches 0.
--- Prints damage messages to console for debugging.
---
--- @param amount number Raw damage before armour reduction
--- @return number Actual damage dealt after armour
function Unit:takeDamage(amount)
    local actualDamage = math.max(0, amount - self.stats.armour)
    self.health = math.max(0, self.health - actualDamage)

    if self.health <= 0 then
        self.alive = false
        print(string.format("[Unit] %s died", self.name))
    else
        print(string.format("[Unit] %s took %d damage (%d actual)", self.name, amount, actualDamage))
    end

    return actualDamage
end

--- Restore hit points to unit.
---
--- Increases health by amount, capped at maxHealth.
--- Prints heal message to console for debugging.
---
--- @param amount number Hit points to restore
--- @return nil
function Unit:heal(amount)
    self.health = math.min(self.maxHealth, self.health + amount)
    print(string.format("[Unit] %s healed %d HP", self.name, amount))
end

--- Generate display name for unit based on class and team.
---
--- Uses class definition name from DataLoader. Adds team indicator
--- for non-standard teams. Called during construction.
---
--- @return string Generated display name
function Unit:generateName()
    local classDef = DataLoader.unitClasses.get(self.classId)
    if not classDef then return "Unknown" end

    local baseName = classDef.name

    -- Add team indicator
    if self.team == "player" then
        return baseName
    elseif self.team == "enemy" then
        return baseName
    else
        return baseName .. " (" .. self.team .. ")"
    end
end

--- Get primary weapon definition from DataLoader.
---
--- @return table|nil Weapon data table or nil if no weapon equipped
function Unit:getWeapon1()
    return self.weapon1 and DataLoader.weapons.get(self.weapon1)
end

--- Get secondary weapon definition from DataLoader.
---
--- @return table|nil Weapon data table or nil if no weapon equipped
function Unit:getWeapon2()
    return self.weapon2 and DataLoader.weapons.get(self.weapon2)
end

--- Get armour definition from DataLoader.
---
--- @return table|nil Armour data table or nil if no armour equipped
function Unit:getArmour()
    return self.armour and DataLoader.armours.get(self.armour)
end

--- Generate debug information string for unit.
---
--- Returns multi-line string with position, facing, health, AP, MP,
--- all stats, and equipped items. Useful for debugging and dev tools.
---
--- @return string Multi-line debug info string
function Unit:getDebugInfo()
    local info = string.format("Unit: %s (%s)\n", self.name, self.classId)
    info = info .. string.format("Position: (%d, %d), Facing: %d\n", self.x, self.y, self.facing)
    info = info .. string.format("Health: %d/%d, AP: %d, MP: %d\n", self.health, self.maxHealth, self.actionPointsLeft, self.movementPoints)
    info = info .. "Stats:\n"

    local statOrder = {"strength", "health", "energy", "armour", "aim", "react", "speed", "will", "morale", "sanity", "psi", "sight", "sense", "cover", "size"}
    for _, stat in ipairs(statOrder) do
        if self.stats[stat] then
            info = info .. string.format("  %s: %d\n", stat, self.stats[stat])
        end
    end

    info = info .. "Equipment:\n"
    if self.weapon1 then info = info .. string.format("  Primary: %s\n", DataLoader.weapons.get(self.weapon1).name) end
    if self.weapon2 then info = info .. string.format("  Secondary: %s\n", DataLoader.weapons.get(self.weapon2).name) end
    if self.armour then info = info .. string.format("  Armour: %s\n", DataLoader.armours.get(self.armour).name) end

    return info
end

--- Rotate unit facing 45 degrees counter-clockwise.
---
--- Decrements facing value (0-7) and wraps around using modulo.
---
--- @return nil
function Unit:rotateLeft()
    self.facing = (self.facing - 1) % 8
end

--- Rotate unit facing 45 degrees clockwise.
---
--- Increments facing value (0-7) and wraps around using modulo.
---
--- @return nil
function Unit:rotateRight()
    self.facing = (self.facing + 1) % 8
end

--- Set unit facing to specific direction.
---
--- Accepts either numeric direction (0-7) or string direction name
--- ("NORTH", "SOUTH", etc.). Returns true on success, false if
--- invalid direction string.
---
--- @param direction number|string Direction value 0-7 or name
--- @return boolean True if direction was set successfully
function Unit:setFacing(direction)
    if type(direction) == "number" and direction >= 0 and direction <= 7 then
        self.facing = direction
    elseif type(direction) == "string" then
        for dirName, dirValue in pairs(Unit.DIRECTIONS) do
            if dirName == direction:upper() then
                self.facing = dirValue
                return true
            end
        end
        return false
    end
    return true
end

--- Get facing direction as string name.
---
--- Returns direction name from Unit.DIRECTIONS constant table
--- ("NORTH", "NORTHEAST", etc.). Returns "UNKNOWN" if facing
--- value is invalid.
---
--- @return string Direction name
function Unit:getFacingName()
    for name, value in pairs(Unit.DIRECTIONS) do
        if value == self.facing then
            return name
        end
    end
    return "UNKNOWN"
end


--- Direction constants mapping names to numeric values (0-7).
--- Used for unit facing in 8-direction movement system.
---
--- Directions:
---   0 = NORTH, 1 = NORTHEAST, 2 = EAST, 3 = SOUTHEAST,
---   4 = SOUTH, 5 = SOUTHWEST, 6 = WEST, 7 = NORTHWEST
Unit.DIRECTIONS = {
    NORTH = 0,
    NORTHEAST = 1,
    EAST = 2,
    SOUTHEAST = 3,
    SOUTH = 4,
    SOUTHWEST = 5,
    WEST = 6,
    NORTHWEST = 7
}

return Unit
