---Item Durability & Condition System for Assets
---
---Manages item durability degradation, condition tracking, repair mechanics,
---and effectiveness penalties based on wear. Integrates with combat system to
---apply durability loss during missions.
---
---Features:
---  - Durability tracking (0-100 scale, clamped)
---  - Condition tiers (Pristine, Worn, Damaged, Critical, Destroyed)
---  - Degradation rates by item type and action
---  - Repair mechanics with time and cost
---  - Effectiveness penalties by condition
---  - Post-mission degradation processing
---  - Integration with combat damage resolution
---
---Degradation Rates:
---  - Weapons: -5 per mission, -2 per critical hit, -1 per normal hit
---  - Armor: -3 per hit taken, -1 per close call
---  - Equipment: -2 per mission, -1 per use
---
---Condition Tiers:
---  - Pristine (100-75%): No penalties
---  - Worn (74-50%): -5% accuracy/defense
---  - Damaged (49-25%): -10% accuracy/defense, reduced effectiveness
---  - Critical (24-1%): -30% accuracy/defense, high risk of failure
---  - Destroyed (0%): Non-functional, requires replacement
---
---Repair System:
---  - Cost: 1% of base item cost per durability point
---  - Time: 1 day per 10 durability points (minimum 1 day)
---  - Location: Base workshop/laboratory
---
---@module engine.assets.systems.durability_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local DurabilitySystem = {}
DurabilitySystem.__index = DurabilitySystem

---Configuration for durability mechanics
local CONFIG = {
    -- Maximum durability points
    maxDurability = 100,
    
    -- Degradation rates per mission/action
    degradation = {
        weapons = 5,           -- Weapons lose 5 per mission
        armor = 3,             -- Armor loses 3 per hit taken
        equipment = 2,         -- Equipment loses 2 per mission
        criticalHit = 2,       -- Additional loss for critical hits
        normalHit = 1,         -- Loss per normal hit (armor only)
        closeCall = 1,         -- Loss when target is narrowly missed
    },
    
    -- Condition tier thresholds
    conditions = {
        pristine = {min = 75, max = 100, penalty = 0.00},
        worn = {min = 50, max = 74, penalty = 0.05},
        damaged = {min = 25, max = 49, penalty = 0.10},
        critical = {min = 1, max = 24, penalty = 0.30},
        destroyed = {min = 0, max = 0, penalty = 1.00}
    },
    
    -- Repair mechanics
    repair = {
        costPerPoint = 0.01,   -- 1% of base cost per durability point
        timePerTenPoints = 1,  -- 1 day per 10 points (minimum 1 day)
    },
    
    -- Item type categories for degradation
    itemTypes = {
        WEAPON = "weapon",
        ARMOR = "armor",
        EQUIPMENT = "equipment"
    }
}

---Create new durability system instance
---@param battleSystem table Battle system reference for damage events
---@return table New DurabilitySystem instance
function DurabilitySystem.new(battleSystem)
    local self = setmetatable({}, DurabilitySystem)
    
    self.battleSystem = battleSystem
    
    -- Item durability tracking: {itemId: durability_value}
    self.itemDurability = {}
    
    -- Item damage history: {itemId: {damageEvents}}
    self.damageHistory = {}
    
    -- Items in repair: {itemId: {repairDays, repairProgress}}
    self.itemsInRepair = {}
    
    -- Item configuration cache
    self.itemConfig = {}
    
    print("[DurabilitySystem] Initialized with max durability: " .. CONFIG.maxDurability)
    
    return self
end

---Register an item for durability tracking
---@param itemId string Unique item identifier
---@param itemType string Item type (weapon/armor/equipment)
---@param baseCost number Base cost for repair calculations
---@return boolean Success
function DurabilitySystem:registerItem(itemId, itemType, baseCost)
    if not itemId then
        print("[DurabilitySystem] ERROR: itemId required for registerItem")
        return false
    end
    
    self.itemDurability[itemId] = CONFIG.maxDurability
    self.itemConfig[itemId] = {
        type = itemType or CONFIG.itemTypes.EQUIPMENT,
        baseCost = baseCost or 1000,
        registeredAt = love.timer.getTime()
    }
    
    print("[DurabilitySystem] Registered item: " .. itemId .. " (type: " .. (itemType or "unknown") .. ")")
    return true
end

---Get current durability of an item
---@param itemId string Unique item identifier
---@return number|nil Durability value (0-100) or nil if not tracked
function DurabilitySystem:getDurability(itemId)
    return self.itemDurability[itemId]
end

---Get durability as percentage
---@param itemId string Unique item identifier
---@return number|nil Percentage (0-100) or nil if not tracked
function DurabilitySystem:getDurabilityPercent(itemId)
    local durability = self.itemDurability[itemId]
    if durability then
        return math.max(0, math.min(100, durability))
    end
    return nil
end

---Get condition tier for an item
---@param itemId string Unique item identifier
---@return string|nil Condition name ("pristine", "worn", "damaged", "critical", "destroyed") or nil
function DurabilitySystem:getCondition(itemId)
    local durability = self:getDurability(itemId)
    
    if not durability then
        return nil
    end
    
    if durability >= CONFIG.conditions.pristine.min then
        return "pristine"
    elseif durability >= CONFIG.conditions.worn.min then
        return "worn"
    elseif durability >= CONFIG.conditions.damaged.min then
        return "damaged"
    elseif durability >= CONFIG.conditions.critical.min then
        return "critical"
    else
        return "destroyed"
    end
end

---Get condition tier for an item
---@param itemId string Unique item identifier
---@return table|nil Condition details {name, durability, percentage, penalty, thresholds} or nil
function DurabilitySystem:getConditionDetails(itemId)
    local durability = self:getDurability(itemId)
    local condition = self:getCondition(itemId)
    
    if not condition then
        return nil
    end
    
    local conditionConfig = CONFIG.conditions[condition]
    
    return {
        name = condition,
        durability = durability,
        percentage = self:getDurabilityPercent(itemId),
        penalty = conditionConfig.penalty,
        minThreshold = conditionConfig.min,
        maxThreshold = conditionConfig.max,
        description = self:_getConditionDescription(condition)
    }
end

---Get effectiveness penalty percentage for an item
---@param itemId string Unique item identifier
---@return number Penalty multiplier (0.0 to 1.0) where 0 = no penalty, 1 = complete failure
function DurabilitySystem:getEffectivenessPenalty(itemId)
    local condition = self:getCondition(itemId)
    
    if not condition or condition == "destroyed" then
        return 1.0  -- Complete failure
    end
    
    return CONFIG.conditions[condition].penalty
end

---Check if an item is functional
---@param itemId string Unique item identifier
---@return boolean True if item can be used, false if destroyed or critical
function DurabilitySystem:isFunctional(itemId)
    local durability = self:getDurability(itemId)
    
    if not durability then
        return false
    end
    
    -- Critical condition has 30% failure rate; destroyed cannot function
    return durability > 0
end

---Apply damage to an item's durability
---@param itemId string Unique item identifier
---@param damageAmount number Amount of durability to lose
---@param damageType string Type of damage ("hit", "critical", "use", "environmental") or nil
---@return boolean Success
---@return number|nil New durability value
function DurabilitySystem:applyDamage(itemId, damageAmount, damageType)
    local currentDurability = self:getDurability(itemId)
    
    if not currentDurability then
        print("[DurabilitySystem] WARNING: Item " .. itemId .. " not tracked")
        return false, nil
    end
    
    damageAmount = math.max(0, damageAmount or 1)
    damageType = damageType or "use"
    
    local newDurability = math.max(0, currentDurability - damageAmount)
    self.itemDurability[itemId] = newDurability
    
    -- Track damage history
    if not self.damageHistory[itemId] then
        self.damageHistory[itemId] = {}
    end
    
    table.insert(self.damageHistory[itemId], {
        timestamp = love.timer.getTime(),
        damageAmount = damageAmount,
        damageType = damageType,
        conditionBefore = self:getCondition(itemId),
        conditionAfter = self:getCondition(itemId)
    })
    
    local conditionBefore = CONFIG.conditions[self:getCondition(itemId)].penalty
    local conditionAfter = CONFIG.conditions[self:getCondition(itemId)].penalty
    
    if conditionBefore ~= conditionAfter then
        print("[DurabilitySystem] Item " .. itemId .. " condition changed: " .. 
              tostring(self:getCondition(itemId)) .. " (durability: " .. newDurability .. "/100)")
    end
    
    return true, newDurability
end

---Repair an item (add durability back)
---@param itemId string Unique item identifier
---@param repairAmount number Amount of durability to restore
---@param repairCost number Cost in credits to repair
---@return boolean Success
---@return number|nil New durability value
---@return table|nil Repair details {daysRequired, creditsRequired, conditionBefore, conditionAfter}
function DurabilitySystem:repairItem(itemId, repairAmount, repairCost)
    local currentDurability = self:getDurability(itemId)
    
    if not currentDurability then
        print("[DurabilitySystem] ERROR: Item " .. itemId .. " not tracked")
        return false, nil, nil
    end
    
    if currentDurability >= CONFIG.maxDurability then
        print("[DurabilitySystem] Item " .. itemId .. " already at max durability")
        return false, currentDurability, nil
    end
    
    repairAmount = repairAmount or (CONFIG.maxDurability - currentDurability)
    repairAmount = math.min(repairAmount, CONFIG.maxDurability - currentDurability)
    
    -- Calculate repair cost if not provided
    if not repairCost then
        local itemConfig = self.itemConfig[itemId]
        repairCost = math.ceil((itemConfig.baseCost or 1000) * CONFIG.repair.costPerPoint * repairAmount)
    end
    
    -- Calculate repair time in days
    local repairDays = math.ceil(repairAmount / 10)
    repairDays = math.max(1, repairDays)
    
    local conditionBefore = self:getCondition(itemId)
    local newDurability = math.min(CONFIG.maxDurability, currentDurability + repairAmount)
    self.itemDurability[itemId] = newDurability
    local conditionAfter = self:getCondition(itemId)
    
    print("[DurabilitySystem] Repaired item " .. itemId .. ": +" .. repairAmount .. 
          " durability (now " .. newDurability .. "/100), " .. repairDays .. " days, " .. 
          repairCost .. " credits")
    
    return true, newDurability, {
        repairAmount = repairAmount,
        daysRequired = repairDays,
        creditsRequired = repairCost,
        conditionBefore = conditionBefore,
        conditionAfter = conditionAfter
    }
end

---Start a repair job (queued in workshop)
---@param itemId string Unique item identifier
---@param repairAmount number Amount of durability to restore
---@return boolean Success
---@return table|nil Repair job details {jobId, daysRemaining, durabilityTarget}
function DurabilitySystem:startRepairJob(itemId, repairAmount)
    local currentDurability = self:getDurability(itemId)
    
    if not currentDurability then
        return false, nil
    end
    
    repairAmount = repairAmount or (CONFIG.maxDurability - currentDurability)
    local daysRequired = math.max(1, math.ceil(repairAmount / 10))
    
    local jobId = itemId .. "_repair_" .. tostring(love.timer.getTime())
    
    self.itemsInRepair[jobId] = {
        itemId = itemId,
        durabilityBefore = currentDurability,
        durabilityTarget = math.min(CONFIG.maxDurability, currentDurability + repairAmount),
        daysRemaining = daysRequired,
        daysTotal = daysRequired,
        startTime = love.timer.getTime()
    }
    
    print("[DurabilitySystem] Repair job started: " .. jobId .. " (" .. daysRequired .. " days)")
    
    return true, {
        jobId = jobId,
        daysRemaining = daysRequired,
        daysTotal = daysRequired,
        durabilityTarget = self.itemsInRepair[jobId].durabilityTarget
    }
end

---Update repair jobs (process daily decay)
---@param daysElapsed number Number of days to process
---@return table Completed repair jobs {jobId: repairDetails}
function DurabilitySystem:updateRepairJobs(daysElapsed)
    daysElapsed = daysElapsed or 1
    local completedJobs = {}
    
    for jobId, job in pairs(self.itemsInRepair) do
        job.daysRemaining = job.daysRemaining - daysElapsed
        
        if job.daysRemaining <= 0 then
            -- Complete the repair
            self.itemDurability[job.itemId] = job.durabilityTarget
            
            completedJobs[jobId] = {
                itemId = job.itemId,
                durabilityRestored = job.durabilityTarget - job.durabilityBefore,
                finalDurability = job.durabilityTarget
            }
            
            self.itemsInRepair[jobId] = nil
            
            print("[DurabilitySystem] Repair job completed: " .. jobId)
        end
    end
    
    return completedJobs
end

---Process post-mission degradation for all equipped items
---@param equippedItems table Array of item IDs that were equipped during mission
---@param missionIntensity string Difficulty level ("easy", "normal", "hard", "impossible")
---@return table Degradation results {itemId: damageApplied}
function DurabilitySystem:processPostMissionDegradation(equippedItems, missionIntensity)
    equippedItems = equippedItems or {}
    missionIntensity = missionIntensity or "normal"
    
    local intensityMultiplier = {
        easy = 0.75,
        normal = 1.0,
        hard = 1.5,
        impossible = 2.0
    }
    
    local multiplier = intensityMultiplier[missionIntensity] or 1.0
    local results = {}
    
    for _, itemId in ipairs(equippedItems) do
        if not self.itemDurability[itemId] then
            goto continue
        end
        
        local itemConfig = self.itemConfig[itemId]
        local itemType = itemConfig.type or CONFIG.itemTypes.EQUIPMENT
        
        local degradationAmount = 0
        
        if itemType == CONFIG.itemTypes.WEAPON then
            degradationAmount = math.ceil(CONFIG.degradation.weapons * multiplier)
        elseif itemType == CONFIG.itemTypes.ARMOR then
            degradationAmount = math.ceil(CONFIG.degradation.armor * multiplier * 0.5)  -- Less wear on armor per mission
        else  -- EQUIPMENT
            degradationAmount = math.ceil(CONFIG.degradation.equipment * multiplier)
        end
        
        local success, newDurability = self:applyDamage(itemId, degradationAmount, "mission_wear")
        
        results[itemId] = {
            damageApplied = degradationAmount,
            newDurability = newDurability,
            condition = self:getCondition(itemId)
        }
        
        ::continue::
    end
    
    print("[DurabilitySystem] Post-mission degradation processed: " .. 
          tostring(#equippedItems) .. " items, intensity: " .. missionIntensity)
    
    return results
end

---Get durability report for all tracked items
---@return table Report {items: {itemId: details}, summary: {total, pristine, worn, damaged, critical, destroyed}}
function DurabilitySystem:getDurabilityReport()
    local report = {
        items = {},
        summary = {
            total = 0,
            pristine = 0,
            worn = 0,
            damaged = 0,
            critical = 0,
            destroyed = 0
        }
    }
    
    for itemId, durability in pairs(self.itemDurability) do
        local condition = self:getCondition(itemId)
        
        if condition then
            report.items[itemId] = {
                durability = durability,
                percentage = self:getDurabilityPercent(itemId),
                condition = condition,
                penalty = CONFIG.conditions[condition].penalty,
                functional = self:isFunctional(itemId)
            }
            
            report.summary.total = report.summary.total + 1
            if report.summary[condition] then
                report.summary[condition] = report.summary[condition] + 1
            end
        end
    end
    
    return report
end

---Private helper: Get condition description
---@param condition string Condition name
---@return string Human-readable description
function DurabilitySystem:_getConditionDescription(condition)
    local descriptions = {
        pristine = "In perfect condition, performs at maximum effectiveness",
        worn = "Showing wear, slight reduction in performance",
        damaged = "Noticeably damaged, significant reduction in effectiveness",
        critical = "Severely damaged, high risk of malfunction or failure",
        destroyed = "Destroyed and non-functional, requires replacement"
    }
    return descriptions[condition] or "Unknown condition"
end

return DurabilitySystem
