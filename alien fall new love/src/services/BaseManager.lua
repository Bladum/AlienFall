--- Base Manager Service
-- Manages player bases, facilities, and radar detection capabilities
--
-- @classmod services.BaseManager

local BaseManager = {}
BaseManager.__index = BaseManager

--- Create a new BaseManager instance
-- @param config Configuration options
-- @return BaseManager instance
function BaseManager.new(config)
    local self = setmetatable({}, BaseManager)
    config = config or {}

    -- Base storage: base_id -> base_data
    self.bases = {}

    -- Facility storage: base_id -> {facility_id -> facility_data}
    self.facilities = {}

    -- Dependencies
    self.telemetry = config.telemetry
    self.logger = config.logger

    return self
end

--- Add or update a base
-- @param base_id Unique base identifier
-- @param base_data Base configuration data
function BaseManager:addBase(base_id, base_data)
    self.bases[base_id] = base_data
    self.facilities[base_id] = self.facilities[base_id] or {}

    if self.logger then
        self.logger:debug("Added base: " .. base_id)
    end
end

--- Remove a base
-- @param base_id Base identifier to remove
function BaseManager:removeBase(base_id)
    self.bases[base_id] = nil
    self.facilities[base_id] = nil

    if self.logger then
        self.logger:debug("Removed base: " .. base_id)
    end
end

--- Get base data
-- @param base_id Base identifier
-- @return Base data or nil if not found
function BaseManager:getBase(base_id)
    return self.bases[base_id]
end

--- Get all bases
-- @return Table of all bases {base_id -> base_data}
function BaseManager:getAllBases()
    return self.bases
end

--- Add facility to a base
-- @param base_id Base identifier
-- @param facility_id Facility identifier
-- @param facility_data Facility configuration data
function BaseManager:addFacility(base_id, facility_id, facility_data)
    if not self.facilities[base_id] then
        self.facilities[base_id] = {}
    end

    self.facilities[base_id][facility_id] = facility_data

    if self.logger then
        self.logger:debug(string.format("Added facility %s to base %s", facility_id, base_id))
    end
end

--- Remove facility from a base
-- @param base_id Base identifier
-- @param facility_id Facility identifier
function BaseManager:removeFacility(base_id, facility_id)
    if self.facilities[base_id] then
        self.facilities[base_id][facility_id] = nil

        if self.logger then
            self.logger:debug(string.format("Removed facility %s from base %s", facility_id, base_id))
        end
    end
end

--- Get facilities for a base
-- @param base_id Base identifier
-- @return Table of facilities {facility_id -> facility_data} or empty table
function BaseManager:getFacilities(base_id)
    return self.facilities[base_id] or {}
end

--- Get specific facility from a base
-- @param base_id Base identifier
-- @param facility_id Facility identifier
-- @return Facility data or nil if not found
function BaseManager:getFacility(base_id, facility_id)
    local base_facilities = self.facilities[base_id]
    return base_facilities and base_facilities[facility_id]
end

--- Check if base has a specific facility
-- @param base_id Base identifier
-- @param facility_id Facility identifier
-- @return boolean Whether facility exists
function BaseManager:hasFacility(base_id, facility_id)
    return self:getFacility(base_id, facility_id) ~= nil
end

--- Get total radar detection power for all bases
-- @return number Total detection power from all radar facilities
function BaseManager:getTotalRadarPower()
    local total_power = 0

    for base_id, facilities in pairs(self.facilities) do
        for facility_id, facility in pairs(facilities) do
            if facility.type == "radar" and facility.detection_power then
                total_power = total_power + facility.detection_power
            end
        end
    end

    return total_power
end

--- Get radar facilities with their detection ranges
-- @return Table of radar facilities {base_id -> {facility_id -> {power, range, position}}}
function BaseManager:getRadarFacilities()
    local radars = {}

    for base_id, facilities in pairs(self.facilities) do
        for facility_id, facility in pairs(facilities) do
            if facility.type == "radar" then
                if not radars[base_id] then
                    radars[base_id] = {}
                end

                radars[base_id][facility_id] = {
                    power = facility.detection_power or 0,
                    range = facility.detection_range or 0,
                    position = facility.position or {x = 0, y = 0}
                }
            end
        end
    end

    return radars
end

--- Check if base has capacity for items
-- @param base_id Base identifier
-- @param unit_capacity Required unit capacity
-- @param volume_capacity Required volume capacity
-- @return boolean Whether base has sufficient capacity
function BaseManager:hasCapacity(base_id, unit_capacity, volume_capacity)
    local base = self.bases[base_id]
    if not base then return false end

    -- Check unit capacity
    if unit_capacity and base.unit_capacity then
        if base.used_unit_capacity + unit_capacity > base.unit_capacity then
            return false
        end
    end

    -- Check volume capacity
    if volume_capacity and base.volume_capacity then
        if base.used_volume_capacity + volume_capacity > base.volume_capacity then
            return false
        end
    end

    return true
end

--- Reserve capacity in a base
-- @param base_id Base identifier
-- @param unit_capacity Unit capacity to reserve
-- @param volume_capacity Volume capacity to reserve
function BaseManager:reserveCapacity(base_id, unit_capacity, volume_capacity)
    local base = self.bases[base_id]
    if not base then return end

    if unit_capacity then
        base.used_unit_capacity = (base.used_unit_capacity or 0) + unit_capacity
    end

    if volume_capacity then
        base.used_volume_capacity = (base.used_volume_capacity or 0) + volume_capacity
    end
end

--- Check if base has sufficient quantity of an item
-- @param base_id Base identifier
-- @param item_id Item identifier
-- @param quantity Required quantity
-- @return boolean Whether base has sufficient quantity
function BaseManager:hasItem(base_id, item_id, quantity)
    local base = self.bases[base_id]
    if not base or not base.inventory then return false end

    local current_quantity = base.inventory[item_id] or 0
    return current_quantity >= quantity
end

--- Add item to base inventory
-- @param base_id Base identifier
-- @param item_id Item identifier
-- @param quantity Quantity to add
function BaseManager:addItem(base_id, item_id, quantity)
    local base = self.bases[base_id]
    if not base then return end

    base.inventory = base.inventory or {}
    base.inventory[item_id] = (base.inventory[item_id] or 0) + quantity
end

--- Remove item from base inventory
-- @param base_id Base identifier
-- @param item_id Item identifier
-- @param quantity Quantity to remove
function BaseManager:removeItem(base_id, item_id, quantity)
    local base = self.bases[base_id]
    if not base or not base.inventory then return end

    local current_quantity = base.inventory[item_id] or 0
    base.inventory[item_id] = math.max(0, current_quantity - quantity)
end

--- Reserve item in base inventory
-- @param base_id Base identifier
-- @param item_id Item identifier
-- @param quantity Quantity to reserve
function BaseManager:reserveItem(base_id, item_id, quantity)
    -- For now, just remove the item (simplified reservation system)
    self:removeItem(base_id, item_id, quantity)
end

--- Get base inventory
-- @param base_id Base identifier
-- @return Table of inventory {item_id -> quantity}
function BaseManager:getInventory(base_id)
    local base = self.bases[base_id]
    return base and base.inventory or {}
end

return BaseManager
