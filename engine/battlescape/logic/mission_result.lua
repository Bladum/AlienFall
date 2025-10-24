---MissionResult - Post-battle mission outcome data
---
---Tracks mission results:
---  - Victory/defeat status
---  - Unit casualties
---  - Enemy losses
---  - Objectives completed
---  - Scoring and rewards
---  - Property damage and destruction tracking
---
---@module battlescape.logic.mission_result
---@author AlienFall Development Team

local MissionResult = {}

---Create a new mission result
---@param data table Mission result data {missionId, victory}
---@return table MissionResult instance
function MissionResult.new(data)
    return {
        missionId = data.missionId or "mission_unknown",
        victory = data.victory or false,

        -- Units
        unitsDeployed = data.unitsDeployed or 0,
        unitsKilled = data.unitsKilled or 0,
        unitsSurvived = data.unitsSurvived or 0,
        unitsLost = data.unitsLost or 0,  -- Lost outside landing zones on defeat

        -- Enemies
        enemiesKilled = data.enemiesKilled or 0,
        enemiesCaptured = data.enemiesCaptured or 0,
        enemiesEscaped = data.enemiesEscaped or 0,

        -- Civilians/Neutrals
        civiliansKilled = data.civiliansKilled or 0,
        civiliansRescued = data.civiliansRescued or 0,
        neutralsKilled = data.neutralsKilled or 0,

        -- Objectives
        objectivesTotal = data.objectivesTotal or 0,
        objectivesCompleted = data.objectivesCompleted or 0,

        -- Performance
        turnsElapsed = data.turnsElapsed or 0,
        accuracyPercent = data.accuracyPercent or 0,
        damageDealt = data.damageDealt or 0,
        damageTaken = data.damageTaken or 0,

        -- TASK-13.3: Destroyed object/property damage tracking for battle results
        -- Property destruction tracking
        structuresDestroyed = data.structuresDestroyed or 0,
        structuresDamaged = data.structuresDamaged or 0,
        vehiclesDestroyed = data.vehiclesDestroyed or 0,
        vehiclesDamaged = data.vehiclesDamaged or 0,
        totalPropertyDamage = data.totalPropertyDamage or 0,  -- Monetary value

        -- Scoring
        baseScore = 0,
        objectiveBonus = 0,
        speedBonus = 0,
        casualtyBonus = 0,
        civiliaPenalty = 0,
        propertyPenalty = 0,
        totalScore = 0,

        -- Salvage
        salvageItems = {},  -- Items collected: {item_id, quantity}
        salvageMoney = 0,
    }
end

---Calculate mission score
---@param result table The mission result
function MissionResult.calculateScore(result)
    result.baseScore = result.victory and 1000 or 0

    -- Objective bonus (250 per completed objective)
    result.objectiveBonus = result.objectivesCompleted * 250

    -- Speed bonus (5 points per turn saved)
    local baselineTurns = 30
    result.speedBonus = math.max(0, (baselineTurns - result.turnsElapsed) * 5)

    -- Casualty bonus (low casualties = bonus)
    local casualtyRate = result.unitsKilled / math.max(1, result.unitsDeployed)
    if casualtyRate < 0.1 then
        result.casualtyBonus = 200
    elseif casualtyRate < 0.25 then
        result.casualtyBonus = 100
    else
        result.casualtyBonus = 0
    end

    -- Civilian penalty
    result.civiliaPenalty = -(result.civiliansKilled * 100)

    -- TASK-13.3: Property damage tracking and penalty calculation
    -- Property penalty: -50 per damaged structure, -200 per destroyed structure
    local propertyDamageCost = (result.structuresDamaged * 50) + (result.structuresDestroyed * 200)
    local vehicleDamageCost = (result.vehiclesDamaged * 75) + (result.vehiclesDestroyed * 300)
    result.propertyPenalty = -(propertyDamageCost + vehicleDamageCost)

    -- Combine total property damage for tracking
    result.totalPropertyDamage = propertyDamageCost + vehicleDamageCost

    result.totalScore = result.baseScore + result.objectiveBonus +
                        result.speedBonus + result.casualtyBonus +
                        result.civiliaPenalty + result.propertyPenalty

    result.totalScore = math.max(0, result.totalScore)  -- Never negative

    print(string.format("[MissionResult] Score: Base=%d, Objectives=%d, Speed=%d, Casualties=%d, Civilians=%d, Property=%d, Total=%d",
        result.baseScore, result.objectiveBonus, result.speedBonus, result.casualtyBonus,
        result.civiliaPenalty, result.propertyPenalty, result.totalScore))
end

---Add salvage item
---@param result table The mission result
---@param itemId string Item ID
---@param quantity number Quantity collected
function MissionResult.addSalvageItem(result, itemId, quantity)
    local found = false
    for _, item in ipairs(result.salvageItems) do
        if item.id == itemId then
            item.quantity = item.quantity + quantity
            found = true
            break
        end
    end

    if not found then
        table.insert(result.salvageItems, {id = itemId, quantity = quantity})
    end
end

---Add salvage money
---@param result table The mission result
---@param amount number Credits collected
function MissionResult.addSalvageMoney(result, amount)
    result.salvageMoney = result.salvageMoney + amount
end

---Get victory status string
---@param result table The mission result
---@return string status Human-readable status
function MissionResult.getStatus(result)
    if result.victory then
        return "VICTORY"
    else
        return "DEFEAT"
    end
end

---Print mission result summary
---@param result table The mission result
function MissionResult.printSummary(result)
    result:calculateScore()

    print("\n[MissionResult] Mission " .. result.missionId)
    print("====================================")
    print("STATUS: " .. MissionResult.getStatus(result))
    print(string.format("Units: %d deployed, %d survived, %d killed",
        result.unitsDeployed, result.unitsSurvived, result.unitsKilled))
    print(string.format("Enemies: %d killed, %d captured, %d escaped",
        result.enemiesKilled, result.enemiesCaptured, result.enemiesEscaped))
    print(string.format("Objectives: %d/%d completed",
        result.objectivesCompleted, result.objectivesTotal))
    print(string.format("Performance: %d turns, %.0f%% accuracy",
        result.turnsElapsed, result.accuracyPercent))
    print("------------------------------------")
    print(string.format("Score Breakdown:"))
    print(string.format("  Base: %d", result.baseScore))
    print(string.format("  Objectives: +%d", result.objectiveBonus))
    print(string.format("  Speed: +%d", result.speedBonus))
    print(string.format("  Casualties: +%d", result.casualtyBonus))
    print(string.format("  Civilian Penalty: %d", result.civiliaPenalty))
    print(string.format("  TOTAL: %d", result.totalScore))
    print(string.format("Salvage: %d items, %d credits",
        #result.salvageItems, result.salvageMoney))
    print("====================================\n")
end

return MissionResult
