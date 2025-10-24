---Base Defense Tower System
---
---Automated defensive structures that protect base facilities from attacks.
---Towers operate autonomously during missions and support interception events.
---
---Tower Types:
---  - LASER: Precision weapon, high accuracy, moderate damage
---  - MISSILE: Area damage, targets multiple enemies, high damage
---  - PLASMA: High tech weapon, scaling damage with research level
---
---Mechanics:
---  - Autonomous targeting and firing during battles
---  - Power system integration (requires facility power)
---  - Research unlocks and damage scaling
---  - Cooldown between shots (3-5 turns based on type)
---  - Line of sight and range validation
---  - Coordinate with base defensive position
---
---Tower Stats by Type:
---  LASER:   HP=50, Damage=15-20, Range=12hex, Accuracy=85%, AP=6, Cooldown=3
---  MISSILE: HP=40, Damage=30, Range=15hex, Accuracy=70%, AP=8, Cooldown=5
---  PLASMA:  HP=60, Damage=25-35, Range=14hex, Accuracy=80%, AP=7, Cooldown=4
---
---Key Exports:
---  - TowerSystem.new(): Creates tower system
---  - createTower(type, position, baseId): Creates tower
---  - addTowerToBase(baseId, tower): Adds to base
---  - processDefenseFire(turn, targets): Auto-firing
---  - getTowerStats(towerId): Gets tower stats
---  - upgradeTower(towerId, researchLevel): Scales damage
---
---Dependencies:
---  - basescape.systems.facility_system: Base integration
---  - battlescape.systems.combat_system: Damage calculation
---  - basescape.finance.finance_system: Power costs
---
---@module basescape.systems.tower_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local TowerSystem = require("engine.basescape.systems.tower_system")
---  local system = TowerSystem.new()
---  local tower = system:createTower("LASER", {x=2, y=2}, "base_1")
---  system:addTowerToBase("base_1", tower)
---  system:processDefenseFire(currentTurn, enemyUnits)

local TowerSystem = {}
TowerSystem.__index = TowerSystem

--- Tower type definitions
local TOWER_TYPES = {
    LASER = {
        name = "Laser Tower",
        description = "Precision defensive system",
        damage = {min = 15, max = 20},
        range = 12,
        accuracy = 85,
        ap = 6,
        cooldown = 3,
        hp = 50,
        maxHp = 50,
        armor = 10,
        researchScaling = 1.0,  -- 1.0× at basic, increases with research
        areaOfEffect = 0,  -- Single target
        powerCost = 2,
        cost = 5000,  -- Credits to build
    },

    MISSILE = {
        name = "Missile Tower",
        description = "Area damage defensive system",
        damage = {min = 25, max = 35},
        range = 15,
        accuracy = 70,
        ap = 8,
        cooldown = 5,
        hp = 40,
        maxHp = 40,
        armor = 5,
        researchScaling = 1.1,  -- Gains 10% per research level
        areaOfEffect = 2,  -- 2 hex radius
        powerCost = 3,
        cost = 8000,
    },

    PLASMA = {
        name = "Plasma Tower",
        description = "Advanced defensive system",
        damage = {min = 20, max = 30},
        range = 14,
        accuracy = 80,
        ap = 7,
        cooldown = 4,
        hp = 60,
        maxHp = 60,
        armor = 15,
        researchScaling = 1.2,  -- 20% per research level
        areaOfEffect = 1,  -- 1 hex radius
        powerCost = 4,
        cost = 12000,
    },
}

--- Create new tower system
-- @return table New TowerSystem instance
function TowerSystem.new()
    local self = setmetatable({}, TowerSystem)

    self.towers = {}           -- All towers: towerId -> tower
    self.baseTowers = {}       -- Tower assignments: baseId -> {towerIds}
    self.towerCooldowns = {}   -- Cooldown tracking: towerId -> cooldown remaining
    self.towerTargets = {}     -- Last targets: towerId -> targetId

    print("[TowerSystem] Initialized base defense tower system")

    return self
end

--- Create new tower
-- @param towerType string Type of tower (LASER, MISSILE, PLASMA)
-- @param position table Position {x, y} on base grid
-- @param baseId string Base ID
-- @return table New tower unit
function TowerSystem:createTower(towerType, position, baseId)
    local typeData = TOWER_TYPES[towerType]

    if not typeData then
        print(string.format("[TowerSystem] ERROR: Unknown tower type: %s", towerType))
        return nil
    end

    local tower = {
        id = "tower_" .. baseId .. "_" .. os.time(),
        type = towerType,
        name = typeData.name,
        baseId = baseId,
        position = {x = position.x, y = position.y},

        -- Stats
        hp = typeData.hp,
        maxHp = typeData.maxHp,
        armor = typeData.armor,

        -- Combat
        damage = typeData.damage,
        range = typeData.range,
        accuracy = typeData.accuracy,
        ap = typeData.ap,
        cooldown = typeData.cooldown,
        currentCooldown = 0,

        -- Capabilities
        areaOfEffect = typeData.areaOfEffect,
        researchScaling = typeData.researchScaling,
        researchLevel = 0,

        -- System
        powerCost = typeData.powerCost,
        hasPower = true,
        active = true,
        isDead = false,

        -- Targeting
        targetingMode = "CLOSEST",  -- CLOSEST, WEAKEST, MOST_DANGEROUS
        canTargetFlying = false,

        -- Stats tracking
        shotsfired = 0,
        hitsScored = 0,
        totalDamage = 0,
    }

    self.towers[tower.id] = tower
    self.towerCooldowns[tower.id] = 0

    print(string.format("[TowerSystem] Created tower '%s' at base %s (position: %d,%d)",
          typeData.name, baseId, position.x, position.y))

    return tower
end

--- Add tower to base
-- @param baseId string Base ID
-- @param tower table Tower entity
-- @return boolean Success
function TowerSystem:addTowerToBase(baseId, tower)
    if not tower then
        return false
    end

    if not self.baseTowers[baseId] then
        self.baseTowers[baseId] = {}
    end

    table.insert(self.baseTowers[baseId], tower.id)
    tower.baseId = baseId

    print(string.format("[TowerSystem] Added tower %s to base %s", tower.id, baseId))

    return true
end

--- Get all towers for a base
-- @param baseId string Base ID
-- @return table Array of tower units
function TowerSystem:getBaseTowers(baseId)
    local towerIds = self.baseTowers[baseId] or {}
    local towers = {}

    for _, towerId in ipairs(towerIds) do
        local tower = self.towers[towerId]
        if tower and not tower.isDead then
            table.insert(towers, tower)
        end
    end

    return towers
end

--- Process automatic defense firing
-- @param turn number Current turn number
-- @param targetUnits table Array of enemy units
-- @return table Firing results
function TowerSystem:processDefenseFire(turn, targetUnits)
    local results = {totalShots = 0, totalHits = 0, totalDamage = 0}

    -- Process each tower
    for towerId, tower in pairs(self.towers) do
        if tower and not tower.isDead and tower.active and tower.hasPower then
            -- Reduce cooldown
            if self.towerCooldowns[towerId] and self.towerCooldowns[towerId] > 0 then
                self.towerCooldowns[towerId] = self.towerCooldowns[towerId] - 1
            end

            -- Try to acquire and fire at target
            if self.towerCooldowns[towerId] <= 0 then
                local target = self:selectTarget(tower, targetUnits)

                if target then
                    local result = self:fireAtTarget(tower, target)

                    if result then
                        results.totalShots = results.totalShots + 1
                        if result.hit then
                            results.totalHits = results.totalHits + 1
                        end
                        if result.damage then
                            results.totalDamage = results.totalDamage + result.damage
                        end

                        -- Reset cooldown
                        self.towerCooldowns[towerId] = tower.cooldown
                    end
                end
            end
        end
    end

    return results
end

--- Select target based on targeting mode
-- @param tower table Tower entity
-- @param targets table Array of potential targets
-- @return table Target or nil
function TowerSystem:selectTarget(tower, targets)
    if not targets or #targets == 0 then
        return nil
    end

    local validTargets = {}

    -- Filter targets by range
    for _, target in ipairs(targets) do
        if self:isInRange(tower, target) then
            table.insert(validTargets, target)
        end
    end

    if #validTargets == 0 then
        return nil
    end

    -- Select based on targeting mode
    if tower.targetingMode == "WEAKEST" then
        local weakest = validTargets[1]
        for _, target in ipairs(validTargets) do
            if target.hp < weakest.hp then
                weakest = target
            end
        end
        return weakest
    elseif tower.targetingMode == "MOST_DANGEROUS" then
        local dangerous = validTargets[1]
        for _, target in ipairs(validTargets) do
            if target.damage > dangerous.damage then
                dangerous = target
            end
        end
        return dangerous
    else  -- CLOSEST (default)
        local closest = validTargets[1]
        local minDist = self:calculateDistance(tower.position, closest.position)

        for _, target in ipairs(validTargets) do
            local dist = self:calculateDistance(tower.position, target.position)
            if dist < minDist then
                closest = target
                minDist = dist
            end
        end
        return closest
    end
end

--- Check if target is in range
-- @param tower table Tower entity
-- @param target table Target unit
-- @return boolean In range
function TowerSystem:isInRange(tower, target)
    if not tower or not target then
        return false
    end

    local distance = self:calculateDistance(tower.position, target.position)

    return distance <= tower.range
end

--- Calculate distance between two positions
-- @param pos1 table Position {x, y}
-- @param pos2 table Position {x, y}
-- @return number Distance
function TowerSystem:calculateDistance(pos1, pos2)
    local dx = (pos2.x or pos2.q or 0) - (pos1.x or pos1.q or 0)
    local dy = (pos2.y or pos2.r or 0) - (pos1.y or pos1.r or 0)

    return math.sqrt(dx * dx + dy * dy)
end

--- Fire tower at target
-- @param tower table Tower entity
-- @param target table Target unit
-- @return table Result {hit=bool, damage=num} or nil
function TowerSystem:fireAtTarget(tower, target)
    if not tower or not target then
        return nil
    end

    tower.shotsfired = tower.shotsfired + 1

    -- Roll for hit
    local hitChance = tower.accuracy
    local roll = math.random(1, 100)
    local hit = roll <= hitChance

    if not hit then
        print(string.format("[TowerSystem] Tower %s MISS (roll %d > %d)", tower.id, roll, hitChance))
        return {hit = false, damage = 0}
    end

    tower.hitsScored = tower.hitsScored + 1

    -- Calculate damage
    local baseDamage = math.random(tower.damage.min, tower.damage.max)

    -- Apply research scaling
    local scaleFactor = 1.0 + (tower.researchLevel * (tower.researchScaling - 1.0))
    local totalDamage = math.floor(baseDamage * scaleFactor)

    -- Apply target armor
    local armorReduction = math.floor((target.armor or 0) * 0.5)
    totalDamage = math.max(1, totalDamage - armorReduction)

    -- Apply damage
    target.hp = math.max(0, (target.hp or 0) - totalDamage)
    tower.totalDamage = tower.totalDamage + totalDamage

    -- Area of effect damage
    if tower.areaOfEffect > 0 then
        print(string.format("[TowerSystem] Tower %s HIT with area effect radius %d (damage %d)",
              tower.id, tower.areaOfEffect, totalDamage))
    else
        print(string.format("[TowerSystem] Tower %s HIT (damage %d)", tower.id, totalDamage))
    end

    return {hit = true, damage = totalDamage}
end

--- Upgrade tower with research
-- @param towerId string Tower ID
-- @param researchLevel number Research level (0-5)
function TowerSystem:upgradeTower(towerId, researchLevel)
    local tower = self.towers[towerId]

    if not tower then
        return
    end

    tower.researchLevel = math.max(0, researchLevel or 0)

    -- Recalculate scaling
    local typeData = TOWER_TYPES[tower.type]
    if typeData then
        -- Damage scaling: multiply max damage by scaling factor
        local scale = 1.0 + (tower.researchLevel * (typeData.researchScaling - 1.0))
        tower.damage = {
            min = math.floor(typeData.damage.min * scale),
            max = math.floor(typeData.damage.max * scale),
        }
    end

    print(string.format("[TowerSystem] Upgraded tower %s to research level %d (damage: %d-%d)",
          towerId, researchLevel, tower.damage.min, tower.damage.max))
end

--- Apply damage to tower
-- @param towerId string Tower ID
-- @param damage number Damage amount
-- @return boolean Tower destroyed
function TowerSystem:damageTower(towerId, damage)
    local tower = self.towers[towerId]

    if not tower or tower.isDead then
        return true
    end

    -- Apply armor
    local actualDamage = math.max(1, damage - math.floor(tower.armor * 0.5))

    tower.hp = math.max(0, tower.hp - actualDamage)

    if tower.hp <= 0 then
        tower.isDead = true
        print(string.format("[TowerSystem] Tower %s destroyed", towerId))
        return true
    end

    return false
end

--- Toggle tower power
-- @param towerId string Tower ID
-- @param hasPower boolean Power state
function TowerSystem:setPower(towerId, hasPower)
    local tower = self.towers[towerId]

    if tower then
        tower.hasPower = hasPower
        print(string.format("[TowerSystem] Tower %s power: %s", towerId, hasPower and "ON" or "OFF"))
    end
end

--- Get tower statistics
-- @param towerId string Tower ID
-- @return table Tower stats
function TowerSystem:getTowerStats(towerId)
    local tower = self.towers[towerId]

    if not tower then
        return nil
    end

    return {
        id = tower.id,
        type = tower.type,
        name = tower.name,
        position = tower.position,
        hp = tower.hp,
        maxHp = tower.maxHp,
        armor = tower.armor,
        damage = tower.damage,
        range = tower.range,
        accuracy = tower.accuracy,
        cooldown = tower.cooldown,
        currentCooldown = self.towerCooldowns[tower.id] or 0,
        active = tower.active,
        hasPower = tower.hasPower,
        researchLevel = tower.researchLevel,
        stats = {
            shotsfired = tower.shotsfired,
            hitsScored = tower.hitsScored,
            hitRate = tower.shotsfired > 0 and math.floor((tower.hitsScored / tower.shotsfired) * 100) or 0,
            totalDamage = tower.totalDamage,
        }
    }
end

--- Repair tower
-- @param towerId string Tower ID
-- @param repairAmount number HP to restore
-- @return number HP remaining
function TowerSystem:repairTower(towerId, repairAmount)
    local tower = self.towers[towerId]

    if not tower or tower.isDead then
        return 0
    end

    tower.hp = math.min(tower.maxHp, tower.hp + repairAmount)

    print(string.format("[TowerSystem] Repaired tower %s (HP now: %d/%d)",
          towerId, tower.hp, tower.maxHp))

    return tower.hp
end

--- Get tower cost summary
-- @param baseId string Base ID
-- @return table {totalCost, totalPowerUsage, towerCount}
function TowerSystem:getBaseTowerCosts(baseId)
    local towers = self:getBaseTowers(baseId)
    local totalCost = 0
    local totalPowerUsage = 0

    for _, tower in ipairs(towers) do
        local typeData = TOWER_TYPES[tower.type]
        if typeData then
            totalCost = totalCost + typeData.cost
            totalPowerUsage = totalPowerUsage + typeData.powerCost
        end
    end

    return {
        totalCost = totalCost,
        totalPowerUsage = totalPowerUsage,
        towerCount = #towers,
    }
end

return TowerSystem
