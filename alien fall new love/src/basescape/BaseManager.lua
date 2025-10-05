--- Base Manager Class
-- Manages individual bases with grid layout, facilities, capacities, and operations
--
-- @classmod basescape.BaseManager

local class = require 'lib.Middleclass'

BaseManager = class('BaseManager')

--- Status constants for base operational states
BaseManager.STATUS_PLANNING = "planning"
BaseManager.STATUS_CONSTRUCTING = "constructing"
BaseManager.STATUS_OPERATIONAL = "operational"
BaseManager.STATUS_DESTROYED = "destroyed"

--- Create a new base manager instance
-- @param registry Service registry for accessing other systems
-- @param base_id Unique identifier for this base
-- @param province_id Province where the base is located
-- @param grid_width Width of the base grid (default 20)
-- @param grid_height Height of the base grid (default 20)
-- @return BaseManager New base manager instance
function BaseManager:initialize(registry, base_id, province_id, grid_width, grid_height)
    self.registry = registry
    self.logger = registry and registry:logger() or nil
    self.event_bus = registry and registry:eventBus() or nil

    -- Base identity
    self.base_id = base_id
    self.province_id = province_id
    self.name = "Base " .. base_id

    -- Grid system (20x20 logical tiles)
    self.grid_width = grid_width or 20
    self.grid_height = grid_height or 20
    self.grid = {} -- 2D array of grid cells

    -- Base status and lifecycle
    self.status = BaseManager.STATUS_PLANNING
    self.construction_progress = 0
    self.construction_target = 100

    -- Facilities and layout
    self.facilities = {} -- Map of facility_id -> facility_instance
    self.facility_grid = {} -- 2D array tracking facility placement

    -- Capacities (aggregated from facilities)
    self.capacity_manager = nil -- Will be set later

    -- Services (managed by ServiceManager)
    self.service_manager = nil -- Will be set later

    -- Operational data
    self.power_grid = {} -- Power connectivity tracking
    self.corridor_network = {} -- Access corridor tracking

    -- Personnel and staffing
    self.personnel = {} -- Assigned personnel
    self.staffing_requirements = {} -- Required staffing by role

    -- Financial tracking
    self.monthly_costs = 0
    self.construction_costs = 0

    -- Initialize grid
    self:_initializeGrid()

    if self.logger then
        self.logger:info("BaseManager", string.format("Created base %s in province %s (%dx%d grid)",
            self.base_id, self.province_id, self.grid_width, self.grid_height))
    end
end

--- Initialize the base grid system
function BaseManager:_initializeGrid()
    -- Initialize empty grid
    for x = 1, self.grid_width do
        self.grid[x] = {}
        self.facility_grid[x] = {}
        for y = 1, self.grid_height do
            self.grid[x][y] = {
                terrain = "empty",
                facility_id = nil,
                power_connected = false,
                access_connected = false,
                blocked = false
            }
            self.facility_grid[x][y] = nil
        end
    end

    -- Initialize power and corridor networks
    for x = 1, self.grid_width do
        self.power_grid[x] = {}
        self.corridor_network[x] = {}
        for y = 1, self.grid_height do
            self.power_grid[x][y] = false
            self.corridor_network[x][y] = false
        end
    end
end

--- Set the capacity manager for this base
-- @param capacity_manager CapacityManager instance
function BaseManager:setCapacityManager(capacity_manager)
    self.capacity_manager = capacity_manager
end

--- Set the service manager for this base
-- @param service_manager ServiceManager instance
function BaseManager:setServiceManager(service_manager)
    self.service_manager = service_manager
end

--- Add a facility to the base at specified position
-- @param facility Facility instance to add
-- @param x X coordinate (1-based)
-- @param y Y coordinate (1-based)
-- @return boolean Success status
-- @return string Error message if failed
function BaseManager:addFacility(facility, x, y)
    -- Validate position
    if not self:_isValidPosition(x, y, facility.width, facility.height) then
        return false, "Invalid position or facility overlaps with existing structures"
    end

    -- Check if facility can be placed (power, access requirements)
    if not self:_canPlaceFacility(facility, x, y) then
        return false, "Facility placement requirements not met (power/access)"
    end

    -- Place facility on grid
    facility.x = x
    facility.y = y
    facility.base_id = self.base_id

    -- Mark grid cells as occupied
    for fx = 0, facility.width - 1 do
        for fy = 0, facility.height - 1 do
            self.facility_grid[x + fx][y + fy] = facility.id
            self.grid[x + fx][y + fy].facility_id = facility.id
            self.grid[x + fx][y + fy].blocked = true
        end
    end

    -- Add to facilities map
    self.facilities[facility.id] = facility

    -- Update networks
    self:_updateNetworks()

    -- Update capacities
    if self.capacity_manager then
        self.capacity_manager:updateFacilityCapacities(facility, "add")
    end

    -- Register services provided by this facility
    if self.service_manager and facility.services then
        for _, service_id in ipairs(facility.services) do
            self.service_manager:registerProvider(facility.id, service_id, {
                capacity = 100, -- Default capacity contribution
                efficiency = facility.health / 100
            })
        end
    end

    -- Publish event
    if self.event_bus then
        self.event_bus:publish("base:facility_added", {
            base_id = self.base_id,
            facility_id = facility.id,
            facility_type = facility.type,
            position = {x = x, y = y}
        })
    end

    if self.logger then
        self.logger:info("BaseManager", string.format("Added facility %s to base %s at (%d,%d)",
            facility.id, self.base_id, x, y))
    end

    return true
end

--- Remove a facility from the base
-- @param facility_id ID of facility to remove
-- @return boolean Success status
function BaseManager:removeFacility(facility_id)
    local facility = self.facilities[facility_id]
    if not facility then
        return false
    end

    -- Clear grid cells
    for fx = 0, facility.width - 1 do
        for fy = 0, facility.height - 1 do
            local gx, gy = facility.x + fx, facility.y + fy
            self.facility_grid[gx][gy] = nil
            self.grid[gx][gy].facility_id = nil
            self.grid[gx][gy].blocked = false
        end
    end

    -- Remove from facilities map
    self.facilities[facility_id] = nil

    -- Update networks
    self:_updateNetworks()

    -- Update capacities
    if self.capacity_manager then
        self.capacity_manager:updateFacilityCapacities(facility, "remove")
    end

    -- Unregister services provided by this facility
    if self.service_manager and facility.services then
        for _, service_id in ipairs(facility.services) do
            self.service_manager:unregisterProvider(facility.id, service_id)
        end
    end

    -- Publish event
    if self.event_bus then
        self.event_bus:publish("base:facility_removed", {
            base_id = self.base_id,
            facility_id = facility_id,
            facility_type = facility.type
        })
    end

    if self.logger then
        self.logger:info("BaseManager", string.format("Removed facility %s from base %s",
            facility_id, self.base_id))
    end

    return true
end

--- Check if a position is valid for facility placement
-- @param x X coordinate
-- @param y Y coordinate
-- @param width Facility width
-- @param height Facility height
-- @return boolean Valid position
function BaseManager:_isValidPosition(x, y, width, height)
    -- Check bounds
    if x < 1 or y < 1 or x + width - 1 > self.grid_width or y + height - 1 > self.grid_height then
        return false
    end

    -- Check for overlaps
    for fx = 0, width - 1 do
        for fy = 0, height - 1 do
            if self.grid[x + fx][y + fy].blocked then
                return false
            end
        end
    end

    return true
end

--- Check if facility can be placed at position (power/access requirements)
-- @param facility Facility instance
-- @param x X coordinate
-- @param y Y coordinate
-- @return boolean Can place
function BaseManager:_canPlaceFacility(facility, x, y)
    -- Check adjacency to access corridors
    local has_access = false
    for fx = 0, facility.width - 1 do
        for fy = 0, facility.height - 1 do
            local gx, gy = x + fx, y + fy
            -- Check adjacent cells for access corridors
            local adjacent_positions = {
                {gx - 1, gy}, {gx + 1, gy}, {gx, gy - 1}, {gx, gy + 1}
            }
            for _, pos in ipairs(adjacent_positions) do
                local ax, ay = pos[1], pos[2]
                if ax >= 1 and ax <= self.grid_width and ay >= 1 and ay <= self.grid_height then
                    if self.corridor_network[ax][ay] then
                        has_access = true
                        break
                    end
                end
            end
            if has_access then break end
        end
        if has_access then break end
    end

    -- For now, require access adjacency (power requirements can be added later)
    return has_access
end

--- Update power and corridor networks
function BaseManager:_updateNetworks()
    -- Reset networks
    for x = 1, self.grid_width do
        for y = 1, self.grid_height do
            self.power_grid[x][y] = false
            self.corridor_network[x][y] = false
        end
    end

    -- Mark corridors and power sources
    for _, facility in pairs(self.facilities) do
        if facility.type == "corridor" then
            for fx = 0, facility.width - 1 do
                for fy = 0, facility.height - 1 do
                    self.corridor_network[facility.x + fx][facility.y + fy] = true
                end
            end
        elseif facility.type == "power" then
            -- Power facilities provide power to adjacent cells
            for fx = -1, facility.width do
                for fy = -1, facility.height do
                    local px, py = facility.x + fx, facility.y + fy
                    if px >= 1 and px <= self.grid_width and py >= 1 and py <= self.grid_height then
                        self.power_grid[px][py] = true
                    end
                end
            end
        end
    end

    -- Update facility connectivity status
    for _, facility in pairs(self.facilities) do
        facility.power_connected = false
        facility.access_connected = false

        -- Check if any cell of facility has power/access
        for fx = 0, facility.width - 1 do
            for fy = 0, facility.height - 1 do
                local gx, gy = facility.x + fx, facility.y + fy
                if self.power_grid[gx][gy] then
                    facility.power_connected = true
                end
                if self.corridor_network[gx][gy] then
                    facility.access_connected = true
                end
            end
        end
    end
end

--- Get operational facilities (powered and accessible)
-- @return table List of operational facility instances
function BaseManager:getOperationalFacilities()
    local operational = {}
    for _, facility in pairs(self.facilities) do
        if facility.power_connected and facility.access_connected and facility.health > 0 then
            table.insert(operational, facility)
        end
    end
    return operational
end

--- Calculate monthly costs for the base
-- @return number Total monthly costs
function BaseManager:calculateMonthlyCosts()
    local total_costs = 0

    -- Sum facility maintenance costs
    for _, facility in pairs(self.facilities) do
        total_costs = total_costs + (facility.monthly_cost or 0)
    end

    -- Add base overhead
    total_costs = total_costs + 1000 -- Base overhead cost

    self.monthly_costs = total_costs
    return total_costs
end

--- Update base status and operations
-- @param dt Time delta in seconds
function BaseManager:update(dt)
    -- Update facilities
    for _, facility in pairs(self.facilities) do
        if facility.update then
            facility:update(dt)
        end
    end

    -- Update service manager
    if self.service_manager then
        self.service_manager:update(dt)
    end

    -- Update capacity manager
    if self.capacity_manager then
        self.capacity_manager:update(dt)
    end

    -- Update construction progress if building
    if self.status == BaseManager.STATUS_CONSTRUCTING then
        -- Construction logic would go here
        -- For now, just mark as operational when complete
        if self.construction_progress >= self.construction_target then
            self.status = BaseManager.STATUS_OPERATIONAL
            if self.event_bus then
                self.event_bus:publish("base:construction_complete", {
                    base_id = self.base_id
                })
            end
        end
    end
end

--- Get base status information
-- @return table Status information
function BaseManager:getStatus()
    return {
        base_id = self.base_id,
        province_id = self.province_id,
        name = self.name,
        status = self.status,
        construction_progress = self.construction_progress,
        construction_target = self.construction_target,
        facility_count = #self.facilities,
        operational_facilities = #self:getOperationalFacilities(),
        monthly_costs = self.monthly_costs,
        grid_size = string.format("%dx%d", self.grid_width, self.grid_height)
    }
end

return BaseManager
