--- Unit System
--- Manages unit entities, stats, equipment, and combat state.
---
--- This module provides the Unit class representing characters in combat.
--- Units have stats loaded from TOML definitions, equipment that modifies
--- stats, and combat state including health, energy, and action points.
---
--- Example usage:
---   local Unit = require("battlescape.combat.unit")
---   local soldier = Unit.new("soldier", "player", 5, 10)
---   soldier:takeDamage(20)
---   print(soldier.health)

local DataLoader = require("core.data_loader")

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
--- @field left_weapon string|nil Left hand weapon ID
--- @field right_weapon string|nil Right hand weapon ID
--- @field armour string|nil Armor ID
--- @field skill string|nil Skill ID
--- @field energy_regen_rate number Energy regeneration per turn
--- @field weapon_cooldowns table Weapon cooldown tracking
--- @field statusEffects table Active status effects
--- @field facing number Direction unit is facing (0-7)
--- @field killed boolean Whether unit is dead
--- @field unconscious boolean Whether unit is unconscious
--- @field actionPoints number Total action points per turn
--- @field actionPointsLeft number Remaining action points this turn
--- @field movementPoints number Total movement points per turn
--- @field movementPointsLeft number Remaining movement points this turn
--- @field sprite table|nil Unit sprite image (Love2D Image object)
--- @field psiEnergy number Current psi energy points (for psionic abilities)
--- @field maxPsiEnergy number Maximum psi energy points
--- @field psiEnergyRegen number Psi energy regeneration per turn
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
    print(string.format("[Unit] Creating unit %s", classId))
    local self = setmetatable({}, Unit)
    print("[Unit] Metatable set")
    
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

    -- Facing direction (0-7, starting north)
    self.facing = 0

    -- Load class definition from DataLoader
    local classDef = DataLoader.unitClasses.get(classId)
    if not classDef then
        print("[ERROR] Unit class not found: " .. classId)
        return nil
    end
    print("[Unit] Class definition loaded")

    -- Initialize stats from class
    self.baseStats = {}
    for stat, value in pairs(classDef.baseStats) do
        self.baseStats[stat] = value
    end

    -- Equipment
    self.left_weapon = classDef.defaultWeapon1
    self.right_weapon = classDef.defaultWeapon2
    self.armour = classDef.defaultArmour
    self.skill = nil  -- No default skill
    
    -- Energy system
    self.energy_regen_rate = 5  -- Energy per turn
    
    -- Weapon cooldown tracking
    self.weapon_cooldowns = {}

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
    
    -- Psi energy system
    -- Psi energy is used for psionic abilities and regenerates 5 points per turn
    -- Based on psi skill: units with psi skill > 0 get psi energy pool
    local psiSkill = self.stats.psi or 0
    if psiSkill > 0 then
        self.psiEnergy = 100  -- Start at full psi energy
        self.maxPsiEnergy = 100  -- Standard max for all psionic units
        print(string.format("[Unit] %s initialized with psi energy: %d (psi skill: %d)", 
            self.name or "Unknown", self.maxPsiEnergy, psiSkill))
    else
        self.psiEnergy = 0
        self.maxPsiEnergy = 0
    end
    self.psiEnergyRegen = 5  -- Regeneration per turn

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
    if self.left_weapon then
        local weapon = DataLoader.weapons.get(self.left_weapon)
        print(string.format("[Unit] weapon1 %s found: %s", self.left_weapon, weapon ~= nil))
        if weapon then
            print(string.format("[Unit] weapon statMods: %s", tostring(weapon.statMods)))
        end
        if weapon and weapon.statMods then
            if type(weapon.statMods) == "table" then
                for stat, mod in pairs(weapon.statMods) do
                    self.stats[stat] = (self.stats[stat] or 0) + mod
                end
            elseif type(weapon.statMods) == "string" and weapon.statMods == "{}" then
                -- Empty statMods, skip
            else
                print(string.format("[Unit] WARNING: Unexpected statMods type %s for weapon %s", type(weapon.statMods), self.left_weapon))
            end
        end
    end

    if self.right_weapon then
        local weapon = DataLoader.weapons.get(self.right_weapon)
        if weapon and weapon.statMods then
            if type(weapon.statMods) == "table" then
                for stat, mod in pairs(weapon.statMods) do
                    self.stats[stat] = (self.stats[stat] or 0) + mod
                end
            elseif type(weapon.statMods) == "string" and weapon.statMods == "{}" then
                -- Empty statMods, skip
            else
                print(string.format("[Unit] WARNING: Unexpected statMods type %s for weapon %s", type(weapon.statMods), self.right_weapon))
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
                if type(armour.statMods) == "table" then
                    for stat, mod in pairs(armour.statMods) do
                        self.stats[stat] = (self.stats[stat] or 0) + mod
                    end
                elseif type(armour.statMods) == "string" and armour.statMods == "{}" then
                    -- Empty statMods, skip
                else
                    print(string.format("[Unit] WARNING: Unexpected armour statMods type %s for armour %s", type(armour.statMods), self.armour))
                end
            end
        end
    end

    -- Apply skill modifiers
    if self.skill then
        local skill = DataLoader.skills.get(self.skill)
        if skill and skill.statMods then
            if type(skill.statMods) == "table" then
                for stat, mod in pairs(skill.statMods) do
                    self.stats[stat] = (self.stats[stat] or 0) + mod
                end
            elseif type(skill.statMods) == "string" and skill.statMods == "{}" then
                -- Empty statMods, skip
            else
                print(string.format("[Unit] WARNING: Unexpected skill statMods type %s for skill %s", type(skill.statMods), self.skill))
            end
        end
    end

    -- Ensure minimum values
    self.stats.speed = math.max(1, self.stats.speed)
    self.stats.health = math.max(1, self.stats.health)
    self.stats.sight = math.max(1, self.stats.sight)
    self.stats.sense = math.max(0, self.stats.sense)

    print(string.format("[Unit] Unit creation completed for %s", classId))
    return self
end

--- Calculate total movement points from remaining action points.
---
--- Movement points = actionPointsLeft × speed stat.
--- Used to determine how far a unit can move in their remaining turn.
---
--- @return number Total movement points available
function Unit:calculateMP()
    print(string.format("[Unit] calculateMP called on unit with speed %s", tostring(self.stats.speed)))
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

--- Get left weapon definition from DataLoader.
---
--- @return table|nil Weapon data table or nil if no weapon equipped
function Unit:getLeftWeapon()
    return self.left_weapon and DataLoader.weapons.get(self.left_weapon)
end

--- Get right weapon definition from DataLoader.
---
--- @return table|nil Weapon data table or nil if no weapon equipped
function Unit:getRightWeapon()
    return self.right_weapon and DataLoader.weapons.get(self.right_weapon)
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
    if self.left_weapon then info = info .. string.format("  Left: %s\n", DataLoader.weapons.get(self.left_weapon).name) end
    if self.right_weapon then info = info .. string.format("  Right: %s\n", DataLoader.weapons.get(self.right_weapon).name) end
    if self.armour then info = info .. string.format("  Armour: %s\n", DataLoader.armours.get(self.armour).name) end
    if self.skill then info = info .. string.format("  Skill: %s\n", self.skill) end

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

--- Regenerate energy at the start of turn.
---
--- Adds energy_regen_rate to current energy, capped at max_energy.
---
--- @return nil
function Unit:regenerateEnergy()
    self.energy = math.min(self.maxEnergy, self.energy + self.energy_regen_rate)
    print(string.format("[Unit] Regenerated %d energy for %s, now at %d/%d", 
        self.energy_regen_rate, self.name, self.energy, self.maxEnergy))
end

--- Consume energy for weapon use.
---
--- Reduces energy by amount. Returns true if successful, false if insufficient energy.
---
--- @param amount number Energy to consume
--- @return boolean True if energy was consumed, false if insufficient
function Unit:consumeEnergy(amount)
    if self.energy >= amount then
        self.energy = self.energy - amount
        print(string.format("[Unit] Consumed %d energy for %s, remaining %d/%d", 
            amount, self.name, self.energy, self.maxEnergy))
        return true
    else
        print(string.format("[Unit] Insufficient energy for %s: need %d, have %d", 
            self.name, amount, self.energy))
        return false
    end
end

--- Check if weapon is on cooldown.
---
--- @param weaponId string Weapon identifier
--- @return boolean True if weapon is on cooldown
function Unit:isWeaponOnCooldown(weaponId)
    return (self.weapon_cooldowns[weaponId] or 0) > 0
end

--- Set weapon cooldown.
---
--- @param weaponId string Weapon identifier
--- @param turns number Number of turns to cooldown (0 = no cooldown)
--- @return nil
function Unit:setWeaponCooldown(weaponId, turns)
    self.weapon_cooldowns[weaponId] = turns
    if turns > 0 then
        print(string.format("[Unit] Set cooldown for %s on %s: %d turns", 
            weaponId, self.name, turns))
    end
end

--- Reduce all weapon cooldowns by 1 turn.
---
--- Called at the end of each turn. Cooldowns cannot go below 0.
---
--- @return nil
function Unit:reduceWeaponCooldowns()
    for weaponId, cooldown in pairs(self.weapon_cooldowns) do
        if cooldown > 0 then
            self.weapon_cooldowns[weaponId] = cooldown - 1
            print(string.format("[Unit] Reduced cooldown for %s on %s: %d turns remaining", 
                weaponId, self.name, self.weapon_cooldowns[weaponId]))
        end
    end
end

--- Get weapon AP cost.
---
--- Returns weapon's AP cost or default of 1 if not specified.
---
--- @param weaponId string Weapon identifier
--- @return number AP cost to use weapon
function Unit:getWeaponApCost(weaponId)
    local WeaponSystem = require("battlescape.combat.weapon_system")
    return WeaponSystem.getApCost(weaponId)
end

--- Get weapon EP cost.
---
--- Returns weapon's EP cost or default of 1 if not specified.
---
--- @param weaponId string Weapon identifier
--- @return number EP cost to use weapon
function Unit:getWeaponEpCost(weaponId)
    local WeaponSystem = require("battlescape.combat.weapon_system")
    return WeaponSystem.getEpCost(weaponId)
end

--- Get weapon range.
---
--- Returns weapon's range or 0 if not specified.
---
--- @param weaponId string Weapon identifier
--- @return number Weapon range in tiles
function Unit:getWeaponRange(weaponId)
    local WeaponSystem = require("battlescape.combat.weapon_system")
    return WeaponSystem.getMaxRange(weaponId)
end

--- Get weapon base accuracy.
---
--- Returns weapon's base accuracy or 0 if not specified.
---
--- @param weaponId string Weapon identifier
--- @return number Base accuracy percentage (0-100)
function Unit:getWeaponBaseAccuracy(weaponId)
    local WeaponSystem = require("battlescape.combat.weapon_system")
    return WeaponSystem.getBaseAccuracy(weaponId)
end

--- Get weapon cooldown.
---
--- Returns weapon's cooldown in turns or 0 if not specified.
---
--- @param weaponId string Weapon identifier
--- @return number Cooldown in turns
function Unit:getWeaponCooldown(weaponId)
    local WeaponSystem = require("battlescape.combat.weapon_system")
    return WeaponSystem.getCooldown(weaponId)
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






















