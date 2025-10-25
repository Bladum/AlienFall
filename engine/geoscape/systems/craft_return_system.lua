---
-- Craft Return & Damage System
-- @module engine.geoscape.systems.craft_return_system
-- @author Copilot
-- @license MIT
--
-- Manages craft return mechanics after missions including damage tracking,
-- fuel consumption, repair scheduling, maintenance costs, and availability updates.
-- Ensures crafts show damage status and require repairs before next deployment.
--
-- Key exports:
-- - processCraftReturn() - Process craft returning from mission
-- - getCraftStatus() - Get current damage/repair status
-- - scheduleCraftRepair() - Add craft to repair queue
-- - calculateRepairCost() - Estimate repair costs
-- - updateCraftAvailability() - Mark craft available/unavailable

local CraftReturnSystem = {}

---
-- Process craft returning from mission
-- @param craftId string Unique craft identifier
-- @param missionId string Mission ID
-- @param damageData table Damage taken (hull, engine, weapons, systems, fuel_consumed)
-- @param pilotTired boolean Whether pilot needs rest
-- @return table Craft status after return processing
function CraftReturnSystem.processCraftReturn(craftId, missionId, damageData, pilotTired)
    if not craftId or not missionId then
        print("[CraftReturnSystem] ERROR: Missing craftId or missionId")
        return nil
    end

    damageData = damageData or {}

    local craftStatus = {
        craft_id = craftId,
        mission_id = missionId,
        returned_at = os.time(),
        damage = {
            hull = math.max(0, damageData.hull_damage or 0),
            engine = math.max(0, damageData.engine_damage or 0),
            weapons = math.max(0, damageData.weapon_damage or 0),
            systems = math.max(0, damageData.systems_damage or 0)
        },
        fuel_consumed = damageData.fuel_consumed or 0,
        pilot_tired = pilotTired or false,
        condition = "operational",  -- operational, damaged, critical, destroyed
        needs_repair = false,
        repair_queue_position = nil
    }

    print(string.format("[CraftReturnSystem] Craft %s returning from mission %s", craftId, missionId))

    -- Determine craft condition
    local totalDamage = craftStatus.damage.hull + craftStatus.damage.engine +
                        craftStatus.damage.weapons + craftStatus.damage.systems

    if totalDamage > 75 then
        craftStatus.condition = "destroyed"
    elseif totalDamage > 50 then
        craftStatus.condition = "critical"
    elseif totalDamage > 0 then
        craftStatus.condition = "damaged"
    end

    -- Check if repair is needed
    if totalDamage > 0 then
        craftStatus.needs_repair = true
        craftStatus.repair_queue_position = CraftReturnSystem._scheduleRepair(craftId, craftStatus)
        print(string.format("[CraftReturnSystem] Craft %s needs repair (total damage: %d%%, queue pos: %d)",
            craftId, totalDamage, craftStatus.repair_queue_position))
    end

    -- Calculate and record repair costs
    craftStatus.repair_cost = CraftReturnSystem._calculateRepairCost(craftStatus)
    craftStatus.days_to_repair = CraftReturnSystem._calculateRepairTime(craftStatus)

    print(string.format("[CraftReturnSystem] Repair cost: %d credits, estimated time: %d days",
        craftStatus.repair_cost, craftStatus.days_to_repair))

    -- Update fuel status
    craftStatus.fuel_remaining = math.max(0, (damageData.fuel_remaining or 100) - craftStatus.fuel_consumed)
    if craftStatus.fuel_remaining < 20 then
        print(string.format("[CraftReturnSystem] Craft %s low on fuel: %d%%", craftId, craftStatus.fuel_remaining))
    end

    -- Update availability
    if craftStatus.condition == "destroyed" then
        craftStatus.available = false
    elseif craftStatus.needs_repair then
        craftStatus.available = false  -- Cannot deploy while repairing
    else
        craftStatus.available = true
    end

    print(string.format("[CraftReturnSystem] Craft condition: %s, available: %s",
        craftStatus.condition, tostring(craftStatus.available)))

    return craftStatus
end

---
-- Get current damage and repair status of a craft
-- @param craftId string Craft identifier
-- @return table Current status including damage percentages and repair info
function CraftReturnSystem.getCraftStatus(craftId)
    -- TODO: Integrate with CampaignManager craft data
    -- local craft = campaignManager:getCraft(craftId)

    local status = {
        craft_id = craftId,
        condition = "operational",
        damage_percent = 0,
        needs_repair = false,
        repair_time_remaining = 0,
        fuel_percent = 100,
        pilot_fatigued = false,
        available_for_deployment = true
    }

    print(string.format("[CraftReturnSystem] Craft %s status: %s, available: %s",
        craftId, status.condition, tostring(status.available_for_deployment)))

    return status
end

---
-- Schedule craft for repair, add to repair queue
-- @param craftId string Craft identifier
-- @param craftStatus table Craft status with damage info
-- @return number Position in repair queue
function CraftReturnSystem._scheduleRepair(craftId, craftStatus)
    -- TODO: Integrate with BaseManager repair queue system
    -- baseManager:addRepairQueueItem({craft_id = craftId, damage = craftStatus.damage})

    local queuePosition = 1  -- Would be determined by actual queue length

    local repairRequest = {
        craft_id = craftId,
        requested_at = os.time(),
        damage_levels = craftStatus.damage,
        total_damage = craftStatus.damage.hull + craftStatus.damage.engine +
                      craftStatus.damage.weapons + craftStatus.damage.systems,
        estimated_completion = os.time() + (CraftReturnSystem._calculateRepairTime(craftStatus) * 86400),
        status = "queued"
    }

    print(string.format("[CraftReturnSystem] Repair scheduled for craft %s at position %d",
        craftId, queuePosition))

    return queuePosition
end

---
-- Calculate repair cost in credits
-- @param craftStatus table Status with damage breakdown
-- @return number Total repair cost
function CraftReturnSystem._calculateRepairCost(craftStatus)
    -- Cost per damage point: varies by system
    -- Hull: 50 cr/point, Engine: 100 cr/point, Weapons: 75 cr/point, Systems: 80 cr/point
    local costs = {
        hull = 50,
        engine = 100,
        weapons = 75,
        systems = 80
    }

    local totalCost = 0
    for system, damage in pairs(craftStatus.damage) do
        local cost = (costs[system] or 50) * damage
        totalCost = totalCost + cost
    end

    -- Add base repair fee (overhead, parts, labor)
    totalCost = totalCost + 500

    return math.floor(totalCost)
end

---
-- Calculate estimated repair time in days
-- @param craftStatus table Status with damage breakdown
-- @return number Estimated days to repair
function CraftReturnSystem._calculateRepairTime(craftStatus)
    -- Days per damage point: 0.5 days per point (8 hours per point)
    local damagePerDay = 2  -- 2% damage per day = 50 days full repair

    local totalDamage = craftStatus.damage.hull + craftStatus.damage.engine +
                        craftStatus.damage.weapons + craftStatus.damage.systems

    -- Minimum repair time: 1 day (quick field repairs)
    -- Maximum: 50 days (full rebuild)
    local daysNeeded = math.ceil(totalDamage / damagePerDay)
    return math.max(1, math.min(50, daysNeeded))
end

---
-- Calculate repair cost for damage amounts
-- @param damage table Damage breakdown (hull, engine, weapons, systems)
-- @return number Cost in credits
function CraftReturnSystem.calculateRepairCost(damage)
    local costs = {
        hull = 50,
        engine = 100,
        weapons = 75,
        systems = 80
    }

    local totalCost = 500  -- Base fee
    for system, dmg in pairs(damage or {}) do
        totalCost = totalCost + ((costs[system] or 50) * dmg)
    end

    return math.floor(totalCost)
end

---
-- Schedule and track maintenance costs
-- @param craftId string Craft identifier
-- @param maintenanceType string Type of maintenance (refuel, rearm, inspection, upgrade)
-- @param cost number Cost in credits
-- @return table Maintenance record
function CraftReturnSystem._recordMaintenance(craftId, maintenanceType, cost)
    local maintenance = {
        craft_id = craftId,
        type = maintenanceType,
        cost = cost,
        scheduled_at = os.time(),
        status = "pending",
        completed_at = nil
    }

    print(string.format("[CraftReturnSystem] Maintenance scheduled: %s for craft %s (cost: %d)",
        maintenanceType, craftId, cost))

    return maintenance
end

---
-- Update craft availability status
-- @param craftId string Craft identifier
-- @param available boolean Whether craft can be deployed
-- @param reason string Reason for status change
function CraftReturnSystem.updateCraftAvailability(craftId, available, reason)
    reason = reason or "status_update"

    local statusRecord = {
        craft_id = craftId,
        available = available,
        updated_at = os.time(),
        reason = reason
    }

    if available then
        print(string.format("[CraftReturnSystem] Craft %s is now AVAILABLE (%s)", craftId, reason))
    else
        print(string.format("[CraftReturnSystem] Craft %s is now UNAVAILABLE (%s)", craftId, reason))
    end

    return statusRecord
end

---
-- Process fuel consumption and refueling
-- @param craftId string Craft identifier
-- @param fuelConsumed number Fuel consumed (percentage or units)
-- @param baseHasFuel number Fuel available at base
-- @return table Fuel status after processing
function CraftReturnSystem._processFuel(craftId, fuelConsumed, baseHasFuel)
    local fuelStatus = {
        craft_id = craftId,
        fuel_consumed = fuelConsumed,
        fuel_available_at_base = baseHasFuel or 100,
        needs_refuel = fuelConsumed > 20,  -- Less than 80% remaining
        refuel_cost = (fuelConsumed * 10),  -- 10 credits per % point
        refuel_time = math.ceil(fuelConsumed / 5)  -- 5% per hour
    }

    print(string.format("[CraftReturnSystem] Craft %s fuel: consumed %d%%, base supply: %d%%",
        craftId, fuelConsumed, baseHasFuel))

    return fuelStatus
end

---
-- Record pilot fatigue and rest requirements
-- @param craftId string Craft identifier
-- @param pilotId string Pilot identifier
-- @param missionDuration number Hours on mission
-- @return table Fatigue record
function CraftReturnSystem._recordPilotFatigue(craftId, pilotId, missionDuration)
    -- Pilot needs 8 hours rest per 12 hours flight
    local restNeeded = math.ceil(missionDuration / 12 * 8)

    local fatigueRecord = {
        craft_id = craftId,
        pilot_id = pilotId,
        mission_duration_hours = missionDuration,
        rest_needed_hours = restNeeded,
        available_after = os.time() + (restNeeded * 3600)
    }

    print(string.format("[CraftReturnSystem] Pilot %s fatigued: needs %d hours rest", pilotId, restNeeded))

    return fatigueRecord
end

return CraftReturnSystem


