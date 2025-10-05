--- Facility Base Class
-- Template class for all base facilities with health, position, and operational status
--
-- @classmod basescape.Facility

local class = require 'lib.Middleclass'

Facility = class('Facility')

--- Facility status constants
Facility.STATUS_CONSTRUCTING = "constructing"
Facility.STATUS_OPERATIONAL = "operational"
Facility.STATUS_DAMAGED = "damaged"
Facility.STATUS_DESTROYED = "destroyed"
Facility.STATUS_OFFLINE = "offline"

--- Create a new facility instance
-- @param id Unique facility identifier
-- @param name Display name
-- @param width Grid width in tiles
-- @param height Grid height in tiles
-- @param capacities Capacity contributions (optional)
-- @param services Service tags provided (optional)
-- @return Facility New facility instance
function Facility:initialize(id, name, width, height, capacities, services)
    -- Identity
    self.id = id
    self.name = name
    self.type = id -- Default type to id, can be overridden

    -- Physical properties
    self.width = width or 1
    self.height = height or 1

    -- Position in base (set when placed)
    self.x = nil
    self.y = nil
    self.base_id = nil

    -- Health and damage system
    self.max_health = 100
    self.health = 100
    self.armor = 0 -- Damage reduction

    -- Operational status
    self.status = Facility.STATUS_CONSTRUCTING
    self.construction_progress = 0
    self.construction_target = 100

    -- Connectivity requirements
    self.power_connected = false
    self.access_connected = false

    -- Capacity contributions
    self.capacities = capacities or {}

    -- Service tags
    self.services = services or {}

    -- Operational properties
    self.power_consumption = 0
    self.monthly_cost = 0
    self.staffing_requirements = {}

    -- Tactical integration
    self.tactical_blocks = {} -- Map blocks for battlescape integration

    -- Construction properties
    self.construction_cost = 0
    self.construction_days = 1
    self.construction_requirements = {}

    -- Damage tracking
    self.damage_log = {}
end

--- Update facility state
-- @param dt Time delta in seconds
function Facility:update(dt)
    -- Update construction progress if building
    if self.status == Facility.STATUS_CONSTRUCTING then
        -- Construction logic would be handled by construction system
        -- This is a placeholder for facility-specific updates
    end

    -- Update operational status based on connectivity
    if self.status ~= Facility.STATUS_CONSTRUCTING and self.status ~= Facility.STATUS_DESTROYED then
        if self.health <= 0 then
            self.status = Facility.STATUS_DESTROYED
        elseif self.health < 50 then
            self.status = Facility.STATUS_DAMAGED
        elseif self.power_connected and self.access_connected then
            self.status = Facility.STATUS_OPERATIONAL
        else
            self.status = Facility.STATUS_OFFLINE
        end
    end
end

--- Apply damage to facility
-- @param damage_amount Raw damage amount
-- @param damage_type Type of damage (optional)
-- @param attacker_info Information about attacker (optional)
-- @return number Actual damage applied
function Facility:takeDamage(damage_amount, damage_type, attacker_info)
    -- Apply armor reduction
    local actual_damage = math.max(0, damage_amount - self.armor)

    -- Apply damage
    local old_health = self.health
    self.health = math.max(0, self.health - actual_damage)

    -- Log damage
    table.insert(self.damage_log, {
        timestamp = os.time(),
        damage_taken = actual_damage,
        damage_type = damage_type or "unknown",
        attacker_info = attacker_info,
        health_before = old_health,
        health_after = self.health
    })

    -- Update status
    self:update(0)

    return actual_damage
end

--- Repair facility damage
-- @param repair_amount Amount of health to restore
-- @param repair_type Type of repair (optional)
-- @return number Actual repair amount
function Facility:repair(repair_amount, repair_type)
    local old_health = self.health
    local actual_repair = math.min(repair_amount, self.max_health - self.health)

    self.health = self.health + actual_repair

    -- Log repair
    table.insert(self.damage_log, {
        timestamp = os.time(),
        damage_taken = -actual_repair, -- Negative for repair
        damage_type = repair_type or "repair",
        health_before = old_health,
        health_after = self.health
    })

    -- Update status
    self:update(0)

    return actual_repair
end

--- Check if facility is operational
-- @return boolean Is operational
function Facility:isOperational()
    return self.status == Facility.STATUS_OPERATIONAL and
           self.power_connected and
           self.access_connected and
           self.health > 0
end

--- Get effective capacity contributions (modified by health)
-- @return table Effective capacities
function Facility:getEffectiveCapacities()
    if not self:isOperational() then
        return {} -- No capacity contribution if not operational
    end

    local effective = {}
    local health_modifier = self.health / self.max_health

    for capacity_name, amount in pairs(self.capacities) do
        effective[capacity_name] = amount * health_modifier
    end

    return effective
end

--- Get facility status information
-- @return table Status information
function Facility:getStatus()
    return {
        id = self.id,
        name = self.name,
        type = self.type,
        status = self.status,
        health = self.health,
        max_health = self.max_health,
        armor = self.armor,
        power_connected = self.power_connected,
        access_connected = self.access_connected,
        operational = self:isOperational(),
        position = {x = self.x, y = self.y},
        base_id = self.base_id,
        construction_progress = self.construction_progress,
        construction_target = self.construction_target,
        size = string.format("%dx%d", self.width, self.height),
        capacities = self:getEffectiveCapacities(),
        services = self.services
    }
end

--- Get construction requirements
-- @return table Construction requirements
function Facility:getConstructionRequirements()
    return {
        cost = self.construction_cost,
        days = self.construction_days,
        requirements = self.construction_requirements,
        size = {width = self.width, height = self.height}
    }
end

--- Get operational costs
-- @return table Monthly costs and requirements
function Facility:getOperationalCosts()
    return {
        monthly_cost = self.monthly_cost,
        power_consumption = self.power_consumption,
        staffing_requirements = self.staffing_requirements
    }
end

--- Complete construction
function Facility:completeConstruction()
    self.status = Facility.STATUS_OPERATIONAL
    self.construction_progress = self.construction_target
end

--- Serialize facility data for saving
-- @return table Serialized data
function Facility:serialize()
    return {
        id = self.id,
        name = self.name,
        type = self.type,
        width = self.width,
        height = self.height,
        x = self.x,
        y = self.y,
        base_id = self.base_id,
        health = self.health,
        max_health = self.max_health,
        armor = self.armor,
        status = self.status,
        construction_progress = self.construction_progress,
        construction_target = self.construction_target,
        power_connected = self.power_connected,
        access_connected = self.access_connected,
        capacities = self.capacities,
        services = self.services,
        power_consumption = self.power_consumption,
        monthly_cost = self.monthly_cost,
        staffing_requirements = self.staffing_requirements,
        construction_cost = self.construction_cost,
        construction_days = self.construction_days,
        construction_requirements = self.construction_requirements,
        damage_log = self.damage_log
    }
end

--- Deserialize facility data from save
-- @param data Serialized facility data
-- @return Facility Deserialized facility
function Facility.deserialize(data)
    local facility = Facility:new(
        data.id,
        data.name,
        data.width,
        data.height,
        data.capacities,
        data.services
    )

    -- Restore state
    facility.type = data.type
    facility.x = data.x
    facility.y = data.y
    facility.base_id = data.base_id
    facility.health = data.health
    facility.max_health = data.max_health
    facility.armor = data.armor
    facility.status = data.status
    facility.construction_progress = data.construction_progress
    facility.construction_target = data.construction_target
    facility.power_connected = data.power_connected
    facility.access_connected = data.access_connected
    facility.power_consumption = data.power_consumption
    facility.monthly_cost = data.monthly_cost
    facility.staffing_requirements = data.staffing_requirements
    facility.construction_cost = data.construction_cost
    facility.construction_days = data.construction_days
    facility.construction_requirements = data.construction_requirements
    facility.damage_log = data.damage_log or {}

    return facility
end

return Facility
