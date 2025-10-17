---SalvageProcessor - Process post-battle salvage collection
---
---Handles salvage from battles:
---  - Corpse generation from killed units
---  - Item collection from dead units and battlefield
---  - Money calculation from salvage
---  - Victory vs defeat consequences
---  - Landing zone survival on defeat
---
---@module battlescape.logic.salvage_processor
---@author AlienFall Development Team

local MissionResult = require("battlescape.logic.mission_result")

local SalvageProcessor = {}

---Process victory salvage
---@param missionId string Mission ID
---@param killedUnits table Array of killed unit data {id, type, level, equipment}
---@param aliveEnemies table Array of alive enemy data
---@param fieldItems table Array of items on battlefield
---@return table result MissionResult with salvage
function SalvageProcessor.processVictorySalvage(missionId, killedUnits, aliveEnemies, fieldItems)
    local result = MissionResult.new({
        missionId = missionId,
        victory = true,
        enemiesKilled = #killedUnits,
        enemiesCaptured = #aliveEnemies,
    })
    
    -- Process killed enemy units -> corpses + equipment
    for _, unit in ipairs(killedUnits) do
        -- Generate corpse item (e.g., "dead_sectoid")
        local corpseId = "dead_" .. (unit.type or "alien")
        result:addSalvageItem(corpseId, 1)
        
        -- Collect equipment
        if unit.equipment then
            for _, item in ipairs(unit.equipment) do
                result:addSalvageItem(item.id, item.quantity or 1)
            end
        end
    end
    
    -- Process alive enemies (captured)
    for _, unit in ipairs(aliveEnemies) do
        if unit.equipment then
            for _, item in ipairs(unit.equipment) do
                result:addSalvageItem(item.id, item.quantity or 1)
            end
        end
    end
    
    -- Collect battlefield items
    for _, item in ipairs(fieldItems) do
        result:addSalvageItem(item.id, item.quantity or 1)
        
        -- Items have a resale value
        result:addSalvageMoney(item.value or 100)
    end
    
    return result
end

---Process defeat salvage
---@param missionId string Mission ID
---@param unitsLost table Array of units lost outside landing zones
---@param unitsSurvived number Units that escaped to landing zones
---@return table result MissionResult with no salvage
function SalvageProcessor.processDefeatSalvage(missionId, unitsLost, unitsSurvived)
    local result = MissionResult.new({
        missionId = missionId,
        victory = false,
        unitsKilled = unitsLost,
        unitsSurvived = unitsSurvived,
    })
    
    -- On defeat: no salvage, units lost
    -- (salvageItems and salvageMoney remain empty/0)
    
    return result
end

---Generate corpse from unit
---@param unitType string Unit type (sectoid, floater, etc.)
---@param unitRank string Unit rank (rookie, veteran, commander)
---@return table corpseData Corpse item data {id, value, research_value}
function SalvageProcessor.generateCorpse(unitType, unitRank)
    local baseValue = 500
    local rankMultiplier = 1.0
    
    if unitRank == "commander" then
        rankMultiplier = 2.0
    elseif unitRank == "soldier" then
        rankMultiplier = 1.5
    end
    
    return {
        id = "dead_" .. unitType,
        name = "Dead " .. string.upper(unitType),
        value = math.floor(baseValue * rankMultiplier),
        researchValue = 100,  -- Points towards research
    }
end

---Check if units are in landing zones
---@param unitPositions table Array of unit positions {unit_id, x, y}
---@param landingZones table Array of landing zones {gridPosition, spawnPoints}
---@return table inZone Array of unit IDs in landing zones
---@return table outside Array of unit IDs outside landing zones
function SalvageProcessor.filterByLandingZone(unitPositions, landingZones)
    local inZone = {}
    local outside = {}
    
    for _, unitPos in ipairs(unitPositions) do
        local isInZone = false
        
        for _, zone in ipairs(landingZones) do
            -- Simple distance check: within zone area
            for _, spawnPoint in ipairs(zone.spawnPoints) do
                local dist = math.abs(unitPos.x - spawnPoint.x) + 
                            math.abs(unitPos.y - spawnPoint.y)
                
                if dist < 5 then  -- 5 tiles = "in landing zone"
                    isInZone = true
                    break
                end
            end
            
            if isInZone then break end
        end
        
        if isInZone then
            table.insert(inZone, unitPos.unit_id)
        else
            table.insert(outside, unitPos.unit_id)
        end
    end
    
    return inZone, outside
end

---Apply salvage rewards to player
---@param result table MissionResult with salvage
---@param playerBase table Player base instance (for inventory)
---@return boolean success True if applied
function SalvageProcessor.applyRewards(result, playerBase)
    -- Add items to base inventory
    for _, item in ipairs(result.salvageItems) do
        -- TODO: Add to base inventory
        -- playerBase.inventory.add(item.id, item.quantity)
        print(string.format("[SalvageProcessor] Added %d x %s", item.quantity, item.id))
    end
    
    -- Add money to base
    playerBase.credits = playerBase.credits + result.salvageMoney
    print(string.format("[SalvageProcessor] Added %d credits", result.salvageMoney))
    
    return true
end

---Print salvage summary
---@param result table MissionResult with salvage
function SalvageProcessor.printSalvageSummary(result)
    print("\n[SalvageProcessor] Salvage Summary")
    print("====================================")
    
    if result.victory then
        print("STATUS: VICTORY - Collecting Salvage")
        print(string.format("Enemies Killed: %d", result.enemiesKilled))
        print(string.format("Enemies Captured: %d", result.enemiesCaptured))
        print(string.format("Items Collected: %d", #result.salvageItems))
        
        for _, item in ipairs(result.salvageItems) do
            print(string.format("  + %d x %s", item.quantity, item.id))
        end
        
        print(string.format("Credits: %d", result.salvageMoney))
    else
        print("STATUS: DEFEAT - No Salvage")
        print(string.format("Units Lost: %d", result.unitsKilled))
        print(string.format("Units Escaped: %d", result.unitsSurvived))
    end
    
    print("====================================\n")
end

return SalvageProcessor
