---Mission Salvage and Resolution System
---
---Handles post-battle rewards, unit losses, scoring, and mission outcomes. Processes
---victory/defeat conditions, collects salvage (corpses, items, equipment), calculates
---mission scores, and determines unit casualties. Critical for campaign progression.
---
---Victory Conditions:
---  - All objectives completed
---  - All enemies eliminated
---  - Extraction successful
---
---Defeat Conditions:
---  - All units lost
---  - Mission timer expired
---  - Critical objectives failed
---
---Salvage Collection:
---  - Victory: Collect all corpses, items, and special salvage
---  - Defeat: Lose all units outside landing zones and all loot
---  - Partial: Varies by extraction success
---
---Scoring System:
---  - Enemy kills (by type and difficulty)
---  - Objectives completed
---  - Civilians saved
---  - Units survived
---  - Time bonuses
---  - Equipment recovered
---
---Key Exports:
---  - SalvageSystem.new(): Creates salvage system
---  - processMissionEnd(battlefield, result): Calculates salvage
---  - collectCorpses(battlefield): Gathers alien corpses
---  - collectItems(battlefield): Gathers dropped items
---  - calculateScore(salvage): Computes mission score
---  - processUnitLosses(units, inLandingZone): Determines casualties
---
---Dependencies:
---  - battlescape.battlefield: Battlefield state for salvage
---  - shared.units.units: Unit status and equipment
---  - shared.items: Item definitions
---  - lore.missions: Mission objectives and scoring
---
---@module economy.marketplace.salvage_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local SalvageSystem = require("economy.marketplace.salvage_system")
---  local salvage = SalvageSystem.new()
---  local result = salvage:processMissionEnd(battlefield, {victory = true})
---  print("Collected: " .. #result.corpses .. " corpses")
---  print("Score: " .. result.score)
---
---@see battlescape.battlefield For battlefield state
---@see scenes.battlescape_screen For combat system

local SalvageSystem = {}
SalvageSystem.__index = SalvageSystem

---@class SalvageResult
---@field victory boolean Mission success
---@field corpses table Array of collected corpses
---@field items table Array of collected items
---@field specialSalvage table Special items (UFO components, etc.)
---@field unitLosses table Units lost
---@field unitSurvivors table Units that survived
---@field score number Mission score
---@field scoreBreakdown table Detailed score calculation

--- Create new salvage system
function SalvageSystem.new()
    local self = setmetatable({}, SalvageSystem)

    -- Score weights
    self.scoreWeights = {
        missionSuccess = 1000,
        missionFailure = -500,
        objectiveComplete = 200,
        enemyKilled = 50,
        allyLost = -100,
        civilianKilled = -200,
        turnBonus = 5,  -- Bonus per turn under par
        propertyDamage = -10,  -- Per destroyed object
    }

    print("[SalvageSystem] Initialized")
    return self
end

--- Process mission end (victory)
---@param battlefield table Battlefield data
---@param playerUnits table Array of player units
---@param enemyUnits table Array of enemy units
---@param objectives table Mission objectives
---@return SalvageResult Salvage data
function SalvageSystem:processMissionVictory(battlefield, playerUnits, enemyUnits, objectives)
    print("[SalvageSystem] Processing victory salvage")

    local result = {
        victory = true,
        corpses = {},
        items = {},
        specialSalvage = {},
        unitLosses = {},
        unitSurvivors = {},
        score = 0,
        scoreBreakdown = {},
    }

    -- Collect all enemy corpses
    for _, enemy in ipairs(enemyUnits) do
        if enemy.isDead then
            self:collectCorpse(enemy, result)
            self:collectUnitEquipment(enemy, result)
        elseif enemy.isStunned or enemy.isCaptured then
            -- Captured units: take all equipment
            self:collectUnitEquipment(enemy, result)
        end
    end

    -- Collect items from battlefield
    self:collectBattlefieldItems(battlefield, result)

    -- Collect special salvage (UFO parts, etc.)
    self:collectSpecialSalvage(battlefield, result)

    -- Process ally units
    for _, ally in ipairs(playerUnits) do
        if ally.isDead then
            -- Dead allies become corpses
            self:collectCorpse(ally, result)
            self:collectUnitEquipment(ally, result)
            table.insert(result.unitLosses, ally)
        else
            -- Survivors gain experience
            table.insert(result.unitSurvivors, ally)
        end
    end

    -- Calculate score
    self:calculateScore(result, battlefield, objectives)

    print("[SalvageSystem] Victory: " .. #result.corpses .. " corpses, " ..
          #result.items .. " items, score: " .. result.score)

    return result
end

--- Process mission end (defeat)
---@param battlefield table Battlefield data
---@param playerUnits table Array of player units
---@param landingZones table Array of landing zone positions
---@return SalvageResult Salvage data
function SalvageSystem:processMissionDefeat(battlefield, playerUnits, landingZones)
    print("[SalvageSystem] Processing defeat")

    local result = {
        victory = false,
        corpses = {},
        items = {},
        specialSalvage = {},
        unitLosses = {},
        unitSurvivors = {},
        score = 0,
        scoreBreakdown = {},
    }

    -- Check which units are in landing zones
    for _, unit in ipairs(playerUnits) do
        if self:isInLandingZone(unit, landingZones) then
            -- Unit survives
            table.insert(result.unitSurvivors, unit)
            print("[SalvageSystem] " .. unit.name .. " survived (in landing zone)")
        else
            -- Unit lost permanently
            table.insert(result.unitLosses, unit)
            print("[SalvageSystem] " .. unit.name .. " lost (outside landing zone)")
        end
    end

    -- No items/corpses collected on defeat
    -- Calculate score (negative)
    result.scoreBreakdown.missionFailure = self.scoreWeights.missionFailure
    result.scoreBreakdown.unitsLost = -#result.unitLosses * self.scoreWeights.allyLost
    result.score = result.scoreBreakdown.missionFailure + result.scoreBreakdown.unitsLost

    print("[SalvageSystem] Defeat: " .. #result.unitLosses .. " units lost, " ..
          #result.unitSurvivors .. " survivors, score: " .. result.score)

    return result
end

--- Collect corpse from killed unit
---@param unit table Killed unit
---@param result SalvageResult Salvage result
function SalvageSystem:collectCorpse(unit, result)
    local corpseName = "Dead " .. (unit.race or "Unknown")

    local corpse = {
        id = "corpse_" .. unit.race,
        name = corpseName,
        race = unit.race,
        team = unit.team,
        researchValue = unit.researchValue or 0,
    }

    table.insert(result.corpses, corpse)
    print("[SalvageSystem] Collected corpse: " .. corpseName)
end

--- Collect equipment from unit
---@param unit table Unit with equipment
---@param result SalvageResult Salvage result
function SalvageSystem:collectUnitEquipment(unit, result)
    if unit.weapon then
        table.insert(result.items, unit.weapon)
        print("[SalvageSystem] Collected weapon: " .. unit.weapon.name)
    end

    if unit.inventory then
        for _, item in ipairs(unit.inventory) do
            table.insert(result.items, item)
            print("[SalvageSystem] Collected item: " .. item.name)
        end
    end
end

--- Collect items from battlefield
---@param battlefield table Battlefield data
---@param result SalvageResult Salvage result
function SalvageSystem:collectBattlefieldItems(battlefield, result)
    -- Collect all dropped items
    for y = 1, battlefield.height do
        for x = 1, battlefield.width do
            local tile = battlefield:getTile(x, y)
            if tile and tile.items then
                for _, item in ipairs(tile.items) do
                    table.insert(result.items, item)
                    print("[SalvageSystem] Collected battlefield item: " .. item.name)
                end
            end
        end
    end
end

--- Collect special salvage (UFO parts, elerium, etc.)
---@param battlefield table Battlefield data
---@param result SalvageResult Salvage result
function SalvageSystem:collectSpecialSalvage(battlefield, result)
    -- Check for special destructible objects
    for y = 1, battlefield.height do
        for x = 1, battlefield.width do
            local tile = battlefield:getTile(x, y)
            if tile and tile.specialObject then
                local obj = tile.specialObject

                if obj.salvageable and not obj.destroyed then
                    table.insert(result.specialSalvage, {
                        id = obj.salvageId,
                        name = obj.salvageName,
                        quantity = obj.salvageQuantity or 1,
                    })
                    print("[SalvageSystem] Collected special salvage: " .. obj.salvageName)
                end
            end
        end
    end
end

--- Calculate mission score
---@param result SalvageResult Salvage result
---@param battlefield table Battlefield data
---@param objectives table Mission objectives
function SalvageSystem:calculateScore(result, battlefield, objectives)
    local breakdown = {}

    -- Base mission success
    breakdown.missionSuccess = self.scoreWeights.missionSuccess

    -- Objectives completed
    local objectivesCompleted = 0
    for _, objective in ipairs(objectives or {}) do
        if objective.completed then
            objectivesCompleted = objectivesCompleted + 1
        end
    end
    breakdown.objectives = objectivesCompleted * self.scoreWeights.objectiveComplete

    -- Enemies killed
    breakdown.enemiesKilled = #result.corpses * self.scoreWeights.enemyKilled

    -- Allies lost
    breakdown.alliesLost = #result.unitLosses * self.scoreWeights.allyLost

    -- Civilians killed (tracked by battlefield)
    local civiliansKilled = battlefield.civiliansKilled or 0
    breakdown.civilians = civiliansKilled * self.scoreWeights.civilianKilled

    -- Turn bonus (if completed faster than par)
    if battlefield.turnsPassed and battlefield.parTime then
        local turnDiff = battlefield.parTime - battlefield.turnsPassed
        if turnDiff > 0 then
            breakdown.turnBonus = turnDiff * self.scoreWeights.turnBonus
        end
    end

    -- Property damage
    local propertyDamage = battlefield.objectsDestroyed or 0
    breakdown.propertyDamage = propertyDamage * self.scoreWeights.propertyDamage

    -- Calculate total
    result.scoreBreakdown = breakdown
    result.score = 0
    for _, value in pairs(breakdown) do
        result.score = result.score + value
    end
end

--- Check if unit is in landing zone
---@param unit table Unit to check
---@param landingZones table Array of landing zone positions
---@return boolean In landing zone
function SalvageSystem:isInLandingZone(unit, landingZones)
    for _, zone in ipairs(landingZones) do
        local dist = math.sqrt((unit.x - zone.x)^2 + (unit.y - zone.y)^2)
        if dist <= (zone.radius or 3) then
            return true
        end
    end
    return false
end

--- Transfer salvage to base inventory
---@param result SalvageResult Salvage result
---@param base table Base to receive salvage
function SalvageSystem:transferToBase(result, base)
    print("[SalvageSystem] Transferring salvage to base")

    local Inventory = require("engine.basescape.inventory.inventory_system")
    local baseId = base.id or "main_base"

    -- Add corpses to storage
    for _, corpse in ipairs(result.corpses) do
        if Inventory and Inventory.addItem then
            Inventory.addItem(baseId, corpse.id, 1)
        else
            base:addToInventory(corpse)
        end
        print(string.format("[SalvageSystem] Added corpse: %s", corpse.name))
    end

    -- Add items to storage
    for _, item in ipairs(result.items) do
        if Inventory and Inventory.addItem then
            Inventory.addItem(baseId, item.id, item.quantity or 1)
        else
            base:addToInventory(item)
        end
        print(string.format("[SalvageSystem] Added item: %s", item.name))
    end

    -- Add special salvage
    for _, salvage in ipairs(result.specialSalvage) do
        if Inventory and Inventory.addItem then
            Inventory.addItem(baseId, salvage.id, salvage.quantity or 1)
        else
            base:addToInventory(salvage)
        end
        print(string.format("[SalvageSystem] Added salvage: %s", salvage.name))
    end

    print("[SalvageSystem] Transfer complete")
end

return SalvageSystem

