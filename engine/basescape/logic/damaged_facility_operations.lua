---Damaged Facility Operations System
---
---Manages damaged facilities operating at reduced capacity. Facilities take
---damage from combat, accidents, or explosions, reducing output until repaired.
---
---Features:
---  - Damage tracking (0-100%)
---  - Capacity reduction: -1% effectiveness per 1% damage
---  - Repair queue and resource costs
---  - Progressive damage effects (50% damaged = 50% penalty, etc.)
---  - Critical damage (>75%) disables facility
---
---@module basescape.logic.damaged_facility_operations
---@author AlienFall Development Team

local DamagedFacilityOps = {}
DamagedFacilityOps.__index = DamagedFacilityOps

---Create facility operations manager
---@param baseId string Base identifier
---@return table manager Facility operations manager
function DamagedFacilityOps.new(baseId)
    local self = setmetatable({}, DamagedFacilityOps)
    self.baseId = baseId
    self.facility_damage = {}  -- facilityId -> {damage, last_damaged, repair_progress}
    self.repair_queue = {}     -- Array of {facilityId, priority, repair_cost}
    return self
end

---Register facility damage
---@param facilityId string Facility identifier
---@param damage_amount number Damage to apply (0-100)
---@param source string Damage source (explosion, combat, accident)
function DamagedFacilityOps:damageFactory(facilityId, damage_amount, source)
    if not self.facility_damage[facilityId] then
        self.facility_damage[facilityId] = {
            damage = 0,
            max_damage = 100,
            last_damaged = 0,
            repair_progress = 0,
            damage_sources = {}
        }
    end

    local fac_damage = self.facility_damage[facilityId]

    -- Apply damage (max 100%)
    fac_damage.damage = math.min(100, fac_damage.damage + damage_amount)
    fac_damage.last_damaged = os.time()

    -- Track damage sources
    if not fac_damage.damage_sources[source] then
        fac_damage.damage_sources[source] = 0
    end
    fac_damage.damage_sources[source] = fac_damage.damage_sources[source] + damage_amount

    -- Log damage
    local damage_state = "DAMAGED"
    if fac_damage.damage >= 75 then
        damage_state = "CRITICAL"
    elseif fac_damage.damage >= 50 then
        damage_state = "SEVERELY DAMAGED"
    end

    print(string.format("[FacilityOps] %s (%s): damage +%.0f%% = %.0f%% total (%s)",
          facilityId, source, damage_amount, fac_damage.damage, damage_state))
end

---Get facility damage percentage
---@param facilityId string Facility identifier
---@return number damage Damage percentage (0-100)
function DamagedFacilityOps:getFacilityDamage(facilityId)
    if not self.facility_damage[facilityId] then
        return 0
    end
    return self.facility_damage[facilityId].damage
end

---Get facility effectiveness percentage
---Reduces effectiveness based on damage level
---@param facilityId string Facility identifier
---@return number effectiveness Effectiveness multiplier (0-1)
function DamagedFacilityOps:getFacilityEffectiveness(facilityId)
    local damage = self:getFacilityDamage(facilityId)

    -- Critical damage (>75%) = facility offline
    if damage >= 75 then
        return 0.0
    end

    -- Severe damage (50-75%) = 25-50% effectiveness
    if damage >= 50 then
        return 0.25 + ((75 - damage) / 25) * 0.25
    end

    -- Moderate damage (25-50%) = 50-75% effectiveness
    if damage >= 25 then
        return 0.5 + ((50 - damage) / 25) * 0.25
    end

    -- Light damage (0-25%) = 75-100% effectiveness
    if damage > 0 then
        return 0.75 + ((25 - damage) / 25) * 0.25
    end

    return 1.0  -- No damage = full effectiveness
end

---Get facility status description
---@param facilityId string Facility identifier
---@return string status Status description (OPERATIONAL, DAMAGED, CRITICAL, etc.)
function DamagedFacilityOps:getFacilityStatus(facilityId)
    local damage = self:getFacilityDamage(facilityId)

    if damage >= 75 then
        return "CRITICAL"
    elseif damage >= 50 then
        return "SEVERELY_DAMAGED"
    elseif damage >= 25 then
        return "DAMAGED"
    elseif damage > 0 then
        return "LIGHTLY_DAMAGED"
    else
        return "OPERATIONAL"
    end
end

---Queue facility for repair
---@param facilityId string Facility identifier
---@param priority number Priority (1-10, higher = more urgent)
---@return boolean success
function DamagedFacilityOps:queueForRepair(facilityId, priority)
    priority = priority or 5

    if not self.facility_damage[facilityId] then
        print(string.format("[FacilityOps] ERROR: Facility %s not tracked", facilityId))
        return false
    end

    -- Check if already queued
    for _, repair in ipairs(self.repair_queue) do
        if repair.facilityId == facilityId then
            print(string.format("[FacilityOps] Facility %s already queued", facilityId))
            return false
        end
    end

    -- Calculate repair cost: $500 base + $50 per 1% damage
    local damage = self.facility_damage[facilityId].damage
    local repair_cost = math.floor(500 + (damage * 50))

    table.insert(self.repair_queue, {
        facilityId = facilityId,
        priority = priority,
        repair_cost = repair_cost,
        queued_at = os.time()
    })

    print(string.format("[FacilityOps] Facility %s queued for repair (cost: $%d, priority: %d)",
          facilityId, repair_cost, priority))

    return true
end

---Process weekly repairs from repair queue
---Allocates engineers to repair damaged facilities
---@param available_engineers number Number of engineers available
---@param credits number Available credits for repair
---@return table results {repaired, still_queued}
function DamagedFacilityOps:processWeeklyRepairs(available_engineers, credits)
    local results = {
        repaired = {},
        still_queued = {},
        engineers_used = 0,
        credits_spent = 0
    }

    available_engineers = available_engineers or 5
    credits = credits or 10000

    -- Sort queue by priority (highest first)
    table.sort(self.repair_queue, function(a, b)
        return a.priority > b.priority
    end)

    local engineers_remaining = available_engineers
    local credits_remaining = credits

    for i, repair in ipairs(self.repair_queue) do
        -- Check resources
        if engineers_remaining <= 0 or credits_remaining < repair.repair_cost then
            -- Move to still queued
            table.insert(results.still_queued, repair)
        else
            -- Perform repair
            local fac_data = self.facility_damage[repair.facilityId]

            -- Repair rate: 15% per engineer per week
            local repair_amount = 15 * (1 + fac_data.repair_progress * 0.1)
            fac_data.damage = math.max(0, fac_data.damage - repair_amount)
            fac_data.repair_progress = fac_data.repair_progress + 1

            -- Deduct resources
            engineers_remaining = engineers_remaining - 1
            credits_remaining = credits_remaining - repair.repair_cost
            results.engineers_used = results.engineers_used + 1
            results.credits_spent = results.credits_spent + repair.repair_cost

            -- Check if fully repaired
            if fac_data.damage <= 0 then
                fac_data.damage = 0
                fac_data.repair_progress = 0
                table.insert(results.repaired, {
                    facilityId = repair.facilityId,
                    repair_cost = repair.repair_cost,
                    fully_repaired = true
                })
                print(string.format("[FacilityOps] Facility %s fully repaired", repair.facilityId))
            else
                -- Still damaged after week
                repair.priority = repair.priority + 1  -- Increase priority
                table.insert(results.still_queued, repair)
                table.insert(results.repaired, {
                    facilityId = repair.facilityId,
                    repair_cost = repair.repair_cost,
                    fully_repaired = false,
                    damage_remaining = fac_data.damage
                })
                print(string.format("[FacilityOps] Facility %s partially repaired (%.0f%% damage remaining)",
                      repair.facilityId, fac_data.damage))
            end
        end
    end

    -- Update queue
    self.repair_queue = results.still_queued

    print(string.format("[FacilityOps] Weekly repairs: %d facilities, %d engineers, $%d cost",
          #results.repaired, results.engineers_used, results.credits_spent))

    return results
end

---Get facility output reduction due to damage
---Used to reduce production, research, storage, etc.
---@param facilityId string Facility identifier
---@return number reduction Output reduction (0-1, where 1 = 100% reduced)
function DamagedFacilityOps:getOutputReduction(facilityId)
    return 1.0 - self:getFacilityEffectiveness(facilityId)
end

---Apply damage to facility in base
---@param base table Base object
---@param facilityId string Facility identifier
---@param damage number Damage amount
---@param source string Damage source
function DamagedFacilityOps:damageBaseFacility(base, facilityId, damage, source)
    if not base or not base.grid then
        return false
    end

    -- Find facility in grid
    local facility = nil
    for _, fac in ipairs(base.grid:getAllFacilities()) do
        if fac.id == facilityId then
            facility = fac
            break
        end
    end

    if not facility then
        print(string.format("[FacilityOps] Facility %s not found in base", facilityId))
        return false
    end

    -- Apply damage
    self:damageFactory(facilityId, damage, source)

    -- Update facility health if applicable
    if facility.health then
        facility.health = math.max(0, facility.health - (damage * facility.maxHealth / 100))
    end

    return true
end

---Get repair queue summary
---@return table summary {total_queued, total_cost, avg_priority}
function DamagedFacilityOps:getRepairQueueSummary()
    local summary = {
        total_queued = #self.repair_queue,
        total_cost = 0,
        avg_priority = 0,
        total_damage = 0
    }

    for _, repair in ipairs(self.repair_queue) do
        summary.total_cost = summary.total_cost + repair.repair_cost
        summary.avg_priority = summary.avg_priority + repair.priority

        if self.facility_damage[repair.facilityId] then
            summary.total_damage = summary.total_damage + self.facility_damage[repair.facilityId].damage
        end
    end

    if #self.repair_queue > 0 then
        summary.avg_priority = math.floor(summary.avg_priority / #self.repair_queue)
    end

    return summary
end

---Get all damaged facilities
---@return table facilities Array of {facilityId, damage, status, effectiveness}
function DamagedFacilityOps:getDamagedFacilities()
    local damaged = {}

    for facilityId, fac_data in pairs(self.facility_damage) do
        if fac_data.damage > 0 then
            table.insert(damaged, {
                facilityId = facilityId,
                damage = fac_data.damage,
                status = self:getFacilityStatus(facilityId),
                effectiveness = self:getFacilityEffectiveness(facilityId),
                repair_progress = fac_data.repair_progress
            })
        end
    end

    return damaged
end

---Emergency facility repair (costs more credits, faster)
---@param facilityId string Facility identifier
---@param credits number Credits available
---@return boolean success
function DamagedFacilityOps:emergencyRepair(facilityId, credits)
    if not self.facility_damage[facilityId] then
        return false
    end

    local fac_data = self.facility_damage[facilityId]

    -- Emergency repair: 50% per 1000 credits (normal is 15% per week + engineer cost)
    local repair_amount = (credits / 1000) * 50

    if repair_amount <= 0 then
        return false
    end

    fac_data.damage = math.max(0, fac_data.damage - repair_amount)

    print(string.format("[FacilityOps] Emergency repair on %s: %.0f%% restored (cost: $%d)",
          facilityId, repair_amount, credits))

    return true
end

return DamagedFacilityOps

