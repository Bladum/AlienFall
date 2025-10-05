--- CraftOperations.lua
-- Craft operations service for Alien Fall geoscape system
-- Handles craft assignment, movement, fuel consumption, and operational constraints

local class = require 'lib.Middleclass'

CraftOperations = class('CraftOperations')

--- Initialize a new CraftOperations instance
-- @param registry Service registry for accessing other systems
-- @return CraftOperations instance
function CraftOperations:initialize(registry)
    self.registry = registry

    -- Craft operations data
    self.craft_operations = {}

    -- Active craft assignments
    self.active_assignments = {}  -- craft_id -> assignment_data

    -- Craft status tracking
    self.craft_status = {}  -- craft_id -> status_data

    -- Daily operation limits
    self.daily_limits = {}  -- craft_id -> operations_today

    -- Load operations data
    self:_loadCraftOperationsData()

    -- Register time hooks
    self:_registerTimeHooks()

    -- Register with service registry
    if registry then
        registry:registerService('craftOperations', self)
    end
end

--- Load craft operations data from TOML
function CraftOperations:_loadCraftOperationsData()
    local dataRegistry = self.registry:getService('dataRegistry')
    if not dataRegistry then return end

    local operations_data = dataRegistry:getData('geoscape/craft_operations')
    if operations_data then
        self.craft_operations = operations_data
    end
end

--- Register time-based hooks
function CraftOperations:_registerTimeHooks()
    local timeService = self.registry:getService('timeService')
    if not timeService then return end

    -- Daily reset of operation limits
    timeService:registerHook('day_tick', 'craft_operations_daily_reset', function()
        self:_resetDailyLimits()
    end, 50)

    -- Process craft movement and recovery
    timeService:registerHook('day_tick', 'craft_operations_movement', function()
        self:_processCraftMovement()
    end, 40)
end

--- Reset daily operation limits
function CraftOperations:_resetDailyLimits()
    self.daily_limits = {}

    -- Reset daily mission counts for all crafts
    for craft_id in pairs(self.craft_status) do
        self.daily_limits[craft_id] = 0
    end
end

--- Process craft movement and status updates
function CraftOperations:_processCraftMovement()
    -- Update craft positions, fuel, and status
    for craft_id, assignment in pairs(self.active_assignments) do
        self:_updateCraftAssignment(craft_id, assignment)
    end
end

--- Get craft operations data for a craft type
-- @param craft_type Type of craft
-- @return Operations data or default values
function CraftOperations:getCraftOperations(craft_type)
    return self.craft_operations[craft_type] or {
        max_range_km = 1000,
        fuel_consumption_per_km = 1.0,
        speed_kmh = 500,
        daily_mission_limit = 3,
        terrain_modifiers = { land = 1.0, water = 1.0, mountain = 1.2, urban = 1.1 },
        min_fuel_reserve = 10,
        recovery_time_hours = 2,
        maintenance_interval_days = 5,
        can_intercept = true,
        can_transport = false,
        can_land = true,
        night_operations = true
    }
end

--- Check if craft can be assigned to mission
-- @param craft_data Craft data
-- @param mission_data Mission data
-- @param base_province Province where craft is based
-- @return Can assign, reason if cannot
function CraftOperations:canAssignCraftToMission(craft_data, mission_data, base_province)
    -- Get operations data
    local operations = self:getCraftOperations(craft_data.type)

    -- Check daily limit
    local operations_today = self.daily_limits[craft_data.id] or 0
    if operations_today >= operations.daily_mission_limit then
        return false, "Daily mission limit reached"
    end

    -- Check if craft is already assigned
    if self.active_assignments[craft_data.id] then
        return false, "Craft already assigned to mission"
    end

    -- Check craft status
    local status = self.craft_status[craft_data.id]
    if status and status.state ~= "ready" then
        return false, "Craft not ready (" .. status.state .. ")"
    end

    -- Get mission province
    local worldModel = self.registry:getService('worldModel')
    if not worldModel then return false, "World model not available" end

    local mission_province = worldModel:getProvince(mission_data.province_id)
    if not mission_province then return false, "Mission province not found" end

    -- Check range
    local distance = worldModel:getDistanceBetweenProvinces(base_province, mission_province)
    if not distance then return false, "Cannot calculate distance" end

    local pixel_to_km = 25  -- Default conversion, should get from world
    local distance_km = distance / pixel_to_km

    if distance_km > operations.max_range_km then
        return false, "Mission out of range"
    end

    -- Check fuel availability
    local fuel_cost = distance_km * operations.fuel_consumption_per_km
    if craft_data.fuel < fuel_cost + operations.min_fuel_reserve then
        return false, "Insufficient fuel"
    end

    -- Check terrain compatibility
    if not self:_checkTerrainCompatibility(craft_data, mission_province, operations) then
        return false, "Incompatible terrain"
    end

    -- Check interception capability
    if mission_data.type == "interception" and not operations.can_intercept then
        return false, "Craft cannot perform interception"
    end

    -- Check night operations
    if not operations.night_operations and self:_isNightTime() then
        return false, "Craft cannot operate at night"
    end

    return true, "Assignment possible"
end

--- Assign craft to mission
-- @param craft_data Craft data
-- @param mission_data Mission data
-- @param base_province Province where craft is based
-- @return Success, assignment data or error message
function CraftOperations:assignCraftToMission(craft_data, mission_data, base_province)
    -- Check if assignment is possible
    local can_assign, reason = self:canAssignCraftToMission(craft_data, mission_data, base_province)
    if not can_assign then
        return false, reason
    end

    -- Get mission province
    local worldModel = self.registry:getService('worldModel')
    local mission_province = worldModel:getProvince(mission_data.province_id)

    -- Calculate travel details
    local operations = self:getCraftOperations(craft_data.type)
    local distance = worldModel:getDistanceBetweenProvinces(base_province, mission_province)
    local pixel_to_km = 25  -- Should get from world config
    local distance_km = distance / pixel_to_km

    local fuel_cost = distance_km * operations.fuel_consumption_per_km
    local travel_time_hours = distance_km / operations.speed_kmh

    -- Create assignment
    local assignment = {
        craft_id = craft_data.id,
        mission_id = mission_data.id,
        start_province_id = base_province.id,
        target_province_id = mission_data.province_id,
        start_time = self:_getCurrentTime(),
        fuel_cost = fuel_cost,
        travel_time_hours = travel_time_hours,
        state = "traveling",
        progress = 0
    }

    -- Update craft status
    self.craft_status[craft_data.id] = {
        state = "en_route",
        assignment = assignment,
        last_update = self:_getCurrentTime()
    }

    -- Record assignment
    self.active_assignments[craft_data.id] = assignment

    -- Increment daily operations
    self.daily_limits[craft_data.id] = (self.daily_limits[craft_data.id] or 0) + 1

    -- Deduct fuel immediately
    craft_data.fuel = craft_data.fuel - fuel_cost

    -- Emit event
    local eventBus = self.registry:getService('event_bus')
    if eventBus then
        eventBus:emit('geoscape:craft_assigned', {
            craft = craft_data,
            mission = mission_data,
            assignment = assignment
        })
    end

    return true, assignment
end

--- Update craft assignment progress
-- @param craft_id Craft identifier
-- @param assignment Assignment data
function CraftOperations:_updateCraftAssignment(craft_id, assignment)
    local current_time = self:_getCurrentTime()
    local elapsed_time = current_time - assignment.start_time
    local progress = elapsed_time / (assignment.travel_time_hours * 3600)  -- Convert to seconds

    assignment.progress = math.min(1.0, progress)

    if progress >= 1.0 then
        -- Craft has arrived
        self:_completeCraftAssignment(craft_id, assignment)
    end
end

--- Complete craft assignment (craft arrives at destination)
-- @param craft_id Craft identifier
-- @param assignment Assignment data
function CraftOperations:_completeCraftAssignment(craft_id, assignment)
    -- Update assignment state
    assignment.state = "arrived"
    assignment.arrival_time = self:_getCurrentTime()

    -- Update craft status
    self.craft_status[craft_id] = {
        state = "at_mission",
        assignment = assignment,
        last_update = self:_getCurrentTime()
    }

    -- Emit event
    local eventBus = self.registry:getService('event_bus')
    if eventBus then
        eventBus:emit('geoscape:craft_arrived', {
            craft_id = craft_id,
            assignment = assignment
        })
    end

    -- Transition to interception/battlescape would happen here
    -- For now, we'll simulate mission completion
    self:_simulateMissionCompletion(craft_id, assignment)
end

--- Simulate mission completion (for testing)
-- @param craft_id Craft identifier
-- @param assignment Assignment data
function CraftOperations:_simulateMissionCompletion(craft_id, assignment)
    -- Simulate some delay for mission execution
    local mission_time = math.random(2, 8) * 3600  -- 2-8 hours
    assignment.mission_completion_time = assignment.arrival_time + mission_time
    assignment.state = "on_mission"
end

--- Return craft from mission
-- @param craft_id Craft identifier
-- @param success True if mission was successful
function CraftOperations:returnCraftFromMission(craft_id, success)
    local assignment = self.active_assignments[craft_id]
    if not assignment then return end

    -- Calculate return trip
    local return_distance = assignment.fuel_cost / self:getCraftOperations("interceptor").fuel_consumption_per_km  -- Reverse calculation
    local return_time_hours = return_distance / 500  -- Assume 500 km/h return speed

    -- Update assignment for return
    assignment.state = "returning"
    assignment.return_start_time = self:_getCurrentTime()
    assignment.return_time_hours = return_time_hours
    assignment.mission_success = success

    -- Update craft status
    self.craft_status[craft_id] = {
        state = "returning",
        assignment = assignment,
        last_update = self:_getCurrentTime()
    }

    -- Emit event
    local eventBus = self.registry:getService('event_bus')
    if eventBus then
        eventBus:emit('geoscape:craft_returning', {
            craft_id = craft_id,
            assignment = assignment,
            success = success
        })
    end
end

--- Complete craft return (craft arrives back at base)
-- @param craft_id Craft identifier
function CraftOperations:completeCraftReturn(craft_id)
    local assignment = self.active_assignments[craft_id]
    if not assignment then return end

    -- Remove assignment
    self.active_assignments[craft_id] = nil

    -- Update craft status
    self.craft_status[craft_id] = {
        state = "ready",
        last_update = self:_getCurrentTime()
    }

    -- Start recovery timer
    local operations = self:getCraftOperations("interceptor")  -- Should get from craft data
    self.craft_status[craft_id].recovery_time = self:_getCurrentTime() + (operations.recovery_time_hours * 3600)

    -- Emit event
    local eventBus = self.registry:getService('event_bus')
    if eventBus then
        eventBus:emit('geoscape:craft_returned', {
            craft_id = craft_id,
            assignment = assignment
        })
    end
end

--- Check terrain compatibility for craft and province
-- @param craft_data Craft data
-- @param province Province instance
-- @param operations Craft operations data
-- @return True if compatible
function CraftOperations:_checkTerrainCompatibility(craft_data, province, operations)
    if province.is_water then
        return operations.can_land  -- Naval crafts can operate over water
    else
        return operations.can_land  -- Land crafts need landing capability
    end
end

--- Check if it's night time
-- @return True if night time
function CraftOperations:_isNightTime()
    -- Simplified: random chance
    -- In full implementation, would check world illumination
    return math.random() < 0.5
end

--- Get current time in seconds
-- @return Current time
function CraftOperations:_getCurrentTime()
    local timeService = self.registry:getService('timeService')
    if timeService then
        return timeService:getCurrentTime().turn * 86400
    end
    return 0
end

--- Get active assignments
-- @return Table of craft_id -> assignment_data
function CraftOperations:getActiveAssignments()
    return self.active_assignments
end

--- Get craft status
-- @param craft_id Craft identifier
-- @return Status data or nil
function CraftOperations:getCraftStatus(craft_id)
    return self.craft_status[craft_id]
end

--- Get all craft statuses
-- @return Table of craft_id -> status_data
function CraftOperations:getAllCraftStatuses()
    return self.craft_status
end

--- Calculate fuel cost for mission
-- @param craft_data Craft data
-- @param mission_data Mission data
-- @param base_province Base province
-- @return Fuel cost or nil if cannot calculate
function CraftOperations:calculateFuelCost(craft_data, mission_data, base_province)
    local worldModel = self.registry:getService('worldModel')
    if not worldModel then return nil end

    local mission_province = worldModel:getProvince(mission_data.province_id)
    if not mission_province then return nil end

    local distance = worldModel:getDistanceBetweenProvinces(base_province, mission_province)
    if not distance then return nil end

    local pixel_to_km = 25  -- Should get from world
    local distance_km = distance / pixel_to_km

    local operations = self:getCraftOperations(craft_data.type)
    return distance_km * operations.fuel_consumption_per_km
end

--- Get available crafts for mission
-- @param mission_data Mission data
-- @param base_province Base province
-- @return Table of available craft data
function CraftOperations:getAvailableCraftsForMission(mission_data, base_province)
    -- This would integrate with the craft service to get available crafts
    -- For now, return mock data
    return {
        {
            id = "craft_001",
            type = "interceptor",
            name = "F-17 Interceptor",
            fuel = 100,
            base_province_id = base_province.id
        }
    }
end

return CraftOperations
