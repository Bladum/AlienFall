-- Unit System
-- Manages unit entities, stats, and equipment

local DataLoader = require("systems.data_loader")

local Unit = {}
Unit.__index = Unit

-- Create a new unit
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

-- Update current stats based on base stats + equipment
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

-- Calculate movement points from action points
function Unit:calculateMP()
    return self.actionPointsLeft * self.stats.speed
end

-- Spend movement points (updates action points)
function Unit:spendMP(amount)
    self.movementPoints = math.max(0, self.movementPoints - amount)
    self.actionPointsLeft = math.floor(self.movementPoints / self.stats.speed)
end

-- Spend action points directly (updates movement points)
function Unit:spendAP(amount)
    self.actionPointsLeft = math.max(0, self.actionPointsLeft - amount)
    self.movementPoints = self:calculateMP()
end

-- Reset unit for new turn
function Unit:resetForTurn()
    self.actionPointsLeft = 4
    self.movementPoints = self:calculateMP()
    self.hasActed = false
end

-- Check if unit occupies a specific tile
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

-- Get all tiles occupied by this unit
function Unit:getOccupiedTiles()
    local tiles = {}
    for oy = 0, self.stats.size - 1 do
        for ox = 0, self.stats.size - 1 do
            table.insert(tiles, {x = self.x + ox, y = self.y + oy})
        end
    end
    return tiles
end

-- Move unit to new position
function Unit:moveTo(x, y)
    self.x = x
    self.y = y
    -- Update animation position to match
    self.animX = x
    self.animY = y
    -- Mark unit as needing visibility recalculation
    self.visibilityDirty = true
end

-- Take damage
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

-- Heal unit
function Unit:heal(amount)
    self.health = math.min(self.maxHealth, self.health + amount)
    print(string.format("[Unit] %s healed %d HP", self.name, amount))
end

-- Generate a name for the unit
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

-- Get weapon info
function Unit:getWeapon1()
    return self.weapon1 and DataLoader.weapons.get(self.weapon1)
end

function Unit:getWeapon2()
    return self.weapon2 and DataLoader.weapons.get(self.weapon2)
end

function Unit:getArmour()
    return self.armour and DataLoader.armours.get(self.armour)
end

-- Debug info
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

-- Rotation methods
function Unit:rotateLeft()
    self.facing = (self.facing - 1) % 8
end

function Unit:rotateRight()
    self.facing = (self.facing + 1) % 8
end

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

function Unit:getFacingName()
    for name, value in pairs(Unit.DIRECTIONS) do
        if value == self.facing then
            return name
        end
    end
    return "UNKNOWN"
end

return Unit