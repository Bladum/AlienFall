--- Base Builder Class
-- Handles construction of new satellite bases with phased development, risk management, and resource allocation
--
-- @classmod basescape.BaseBuilder

local class = require 'lib.Middleclass'

BaseBuilder = class('BaseBuilder')

--- Construction phases
BaseBuilder.PHASE_PLANNING = "planning"
BaseBuilder.PHASE_FOUNDATION = "foundation"
BaseBuilder.PHASE_DEVELOPMENT = "development"
BaseBuilder.PHASE_OPERATIONAL = "operational"

--- Risk levels
BaseBuilder.RISK_LOW = "low"
BaseBuilder.RISK_MEDIUM = "medium"
BaseBuilder.RISK_HIGH = "high"

--- Base size templates
BaseBuilder.SIZE_SMALL = "small"     -- 3x3 grid, reconnaissance focus
BaseBuilder.SIZE_MEDIUM = "medium"   -- 5x5 grid, balanced capabilities
BaseBuilder.SIZE_LARGE = "large"     -- 7x7 grid, regional command

--- Create a new base builder instance
-- @param registry Service registry for accessing other systems
-- @return BaseBuilder New base builder instance
function BaseBuilder:initialize(registry)
    self.registry = registry
    self.logger = registry and registry:logger() or nil
    self.event_bus = registry and registry:eventBus() or nil

    -- Active construction projects
    self.construction_projects = {} -- project_id -> project_data

    -- Base size templates
    self.size_templates = {
        [BaseBuilder.SIZE_SMALL] = {
            grid_width = 3,
            grid_height = 3,
            base_cost = 150000,
            construction_days = 14,
            risk_modifier = 0.8,
            description = "Reconnaissance outpost"
        },
        [BaseBuilder.SIZE_MEDIUM] = {
            grid_width = 5,
            grid_height = 5,
            base_cost = 450000,
            construction_days = 28,
            risk_modifier = 1.0,
            description = "Interception hub"
        },
        [BaseBuilder.SIZE_LARGE] = {
            grid_width = 7,
            grid_height = 7,
            base_cost = 900000,
            construction_days = 42,
            risk_modifier = 1.2,
            description = "Regional command center"
        }
    }

    -- Construction queues per base
    self.construction_queues = {} -- base_id -> {facility_constructions}

    if self.logger then
        self.logger:info("BaseBuilder", "Base builder initialized")
    end
end

--- Start construction of a new base
-- @param province_id Province where to build the base
-- @param size Base size template (small/medium/large)
-- @param initial_facilities List of initial facilities to build
-- @return string Project ID if successful
-- @return string Error message if failed
function BaseBuilder:startBaseConstruction(province_id, size, initial_facilities)
    -- Validate province control
    if not self:_validateProvinceControl(province_id) then
        return nil, "Province not under player control"
    end

    -- Validate size template
    if not self.size_templates[size] then
        return nil, "Invalid base size template"
    end

    -- Calculate total cost and time
    local template = self.size_templates[size]
    local total_cost = template.base_cost
    local total_days = template.construction_days

    -- Add facility costs
    for _, facility_type in ipairs(initial_facilities or {}) do
        local facility_cost = self:_getFacilityCost(facility_type)
        total_cost = total_cost + facility_cost
        total_days = total_days + self:_getFacilityBuildTime(facility_type)
    end

    -- Check funding availability
    if not self:_checkFunding(total_cost) then
        return nil, string.format("Insufficient funding: %d credits required", total_cost)
    end

    -- Create construction project
    local project_id = string.format("base_%s_%d", province_id, os.time())
    local project = {
        id = project_id,
        province_id = province_id,
        size = size,
        phase = BaseBuilder.PHASE_PLANNING,
        progress = 0,
        total_cost = total_cost,
        paid_cost = 0,
        estimated_days = total_days,
        actual_days = 0,
        risk_level = self:_calculateRiskLevel(province_id, size),
        initial_facilities = initial_facilities or {},
        start_date = os.time(),
        last_update = os.time(),
        status = "active",
        events = {} -- Construction events/risks
    }

    self.construction_projects[project_id] = project

    -- Reserve funding
    self:_reserveFunding(total_cost)

    -- Publish event
    if self.event_bus then
        self.event_bus:publish("base:construction_started", {
            project_id = project_id,
            province_id = province_id,
            size = size,
            cost = total_cost,
            duration = total_days
        })
    end

    if self.logger then
        self.logger:info("BaseBuilder", string.format("Started base construction project %s in province %s (%s size, %d credits, %d days)",
            project_id, province_id, size, total_cost, total_days))
    end

    return project_id
end

--- Update construction progress
-- @param dt Time delta in seconds
function BaseBuilder:update(dt)
    local current_time = os.time()

    for project_id, project in pairs(self.construction_projects) do
        if project.status == "active" then
            -- Update progress based on time
            local time_elapsed = current_time - project.last_update
            local progress_gain = (time_elapsed / (project.estimated_days * 24 * 3600)) * 100

            project.progress = math.min(100, project.progress + progress_gain)
            project.actual_days = project.actual_days + (time_elapsed / (24 * 3600))
            project.last_update = current_time

            -- Check for phase transitions
            self:_updateConstructionPhase(project)

            -- Check for random events
            self:_checkForEvents(project)

            -- Check completion
            if project.progress >= 100 then
                self:_completeConstruction(project)
            end
        end
    end
end

--- Update construction phase based on progress
-- @param project Construction project
function BaseBuilder:_updateConstructionPhase(project)
    local old_phase = project.phase

    if project.progress < 25 then
        project.phase = BaseBuilder.PHASE_PLANNING
    elseif project.progress < 50 then
        project.phase = BaseBuilder.PHASE_FOUNDATION
    elseif project.progress < 100 then
        project.phase = BaseBuilder.PHASE_DEVELOPMENT
    else
        project.phase = BaseBuilder.PHASE_OPERATIONAL
    end

    if old_phase ~= project.phase then
        if self.logger then
            self.logger:info("BaseBuilder", string.format("Project %s entered %s phase", project.id, project.phase))
        end

        if self.event_bus then
            self.event_bus:publish("base:construction_phase_changed", {
                project_id = project.id,
                old_phase = old_phase,
                new_phase = project.phase,
                progress = project.progress
            })
        end
    end
end

--- Check for random construction events
-- @param project Construction project
function BaseBuilder:_checkForEvents(project)
    -- Simple random event system (would be more sophisticated in full implementation)
    local event_chance = 0.01 * project.risk_level -- 1% base chance, modified by risk

    if math.random() < event_chance then
        local events = {
            {type = "supply_delay", description = "Supply shipment delayed", impact = 5},
            {type = "weather_event", description = "Severe weather slows construction", impact = 3},
            {type = "material_shortage", description = "Construction materials delayed", impact = 7},
            {type = "alien_sighting", description = "Alien activity delays work", impact = 10}
        }

        local event = events[math.random(#events)]

        -- Apply impact (delay construction)
        project.progress = math.max(0, project.progress - event.impact)
        project.estimated_days = project.estimated_days + (event.impact / 10) -- Add days

        table.insert(project.events, {
            type = event.type,
            description = event.description,
            impact = event.impact,
            timestamp = os.time()
        })

        if self.logger then
            self.logger:warn("BaseBuilder", string.format("Construction event in project %s: %s (-%d%% progress)",
                project.id, event.description, event.impact))
        end

        if self.event_bus then
            self.event_bus:publish("base:construction_event", {
                project_id = project.id,
                event_type = event.type,
                description = event.description,
                impact = event.impact
            })
        end
    end
end

--- Complete construction project
-- @param project Construction project
function BaseBuilder:_completeConstruction(project)
    project.status = "completed"
    project.completion_date = os.time()

    -- Create the actual base
    local base_manager = self:_createBaseFromProject(project)

    -- Release reserved funding (construction costs are now spent)
    self:_spendFunding(project.total_cost)

    if self.logger then
        self.logger:info("BaseBuilder", string.format("Completed base construction project %s", project.id))
    end

    if self.event_bus then
        self.event_bus:publish("base:construction_completed", {
            project_id = project.id,
            base_id = base_manager.base_id,
            province_id = project.province_id,
            size = project.size
        })
    end
end

--- Create actual base from completed project
-- @param project Construction project
-- @return BaseManager The created base manager
function BaseBuilder:_createBaseFromProject(project)
    -- Import BaseManager
    local BaseManager = require "basescape.BaseManager"

    -- Create base manager
    local template = self.size_templates[project.size]
    local base_manager = BaseManager:new(self.registry, project.id, project.province_id,
                                       template.grid_width, template.grid_height)

    -- Set construction as complete
    base_manager.status = BaseManager.STATUS_OPERATIONAL
    base_manager.construction_progress = 100

    -- Add initial facilities (would be implemented based on project.initial_facilities)
    -- For now, just add basic access lift
    local Facility = require "basescape.Facility"
    local access_lift = Facility:new("access_lift", "Access Lift", 1, 1, {
        power_generation = 10,  -- Provides basic power
        personnel_quarters = 4   -- Basic crew quarters
    })
    base_manager:addFacility(access_lift, 2, 2) -- Center of base

    return base_manager
end

--- Cancel construction project
-- @param project_id ID of project to cancel
-- @return boolean Success
function BaseBuilder:cancelConstruction(project_id)
    local project = self.construction_projects[project_id]
    if not project or project.status ~= "active" then
        return false
    end

    -- Refund partial costs
    local refund_amount = math.floor(project.paid_cost * 0.7) -- 70% refund
    self:_refundFunding(refund_amount)

    project.status = "cancelled"

    if self.logger then
        self.logger:info("BaseBuilder", string.format("Cancelled construction project %s, refunded %d credits",
            project_id, refund_amount))
    end

    if self.event_bus then
        self.event_bus:publish("base:construction_cancelled", {
            project_id = project_id,
            refund_amount = refund_amount
        })
    end

    return true
end

--- Get construction project status
-- @param project_id Project ID
-- @return table Project status or nil if not found
function BaseBuilder:getProjectStatus(project_id)
    local project = self.construction_projects[project_id]
    if not project then
        return nil
    end

    return {
        id = project.id,
        province_id = project.province_id,
        size = project.size,
        phase = project.phase,
        progress = project.progress,
        total_cost = project.total_cost,
        paid_cost = project.paid_cost,
        estimated_days = project.estimated_days,
        actual_days = project.actual_days,
        risk_level = project.risk_level,
        status = project.status,
        events = project.events,
        start_date = project.start_date
    }
end

--- Get all active construction projects
-- @return table List of active projects
function BaseBuilder:getActiveProjects()
    local active = {}
    for _, project in pairs(self.construction_projects) do
        if project.status == "active" then
            table.insert(active, self:getProjectStatus(project.id))
        end
    end
    return active
end

--- Calculate risk level for construction
-- @param province_id Province ID
-- @param size Base size
-- @return number Risk multiplier (0.5-2.0)
function BaseBuilder:_calculateRiskLevel(province_id, size)
    -- Base risk from size
    local size_risk = self.size_templates[size].risk_modifier

    -- Province-specific risk (simplified - would check alien activity, terrain, etc.)
    local province_risk = 1.0

    -- Random factor
    local random_factor = 0.8 + math.random() * 0.4 -- 0.8-1.2

    return size_risk * province_risk * random_factor
end

--- Validate province control
-- @param province_id Province ID
-- @return boolean Is controlled
function BaseBuilder:_validateProvinceControl(province_id)
    -- Simplified - would check geoscape control
    return true -- Assume controlled for now
end

--- Check funding availability
-- @param amount Amount needed
-- @return boolean Available
function BaseBuilder:_checkFunding(amount)
    -- Simplified - would check finance system
    return true -- Assume funded for now
end

--- Reserve funding for construction
-- @param amount Amount to reserve
function BaseBuilder:_reserveFunding(amount)
    -- Would integrate with finance system
    if self.logger then
        self.logger:debug("BaseBuilder", string.format("Reserved %d credits for construction", amount))
    end
end

--- Spend reserved funding
-- @param amount Amount to spend
function BaseBuilder:_spendFunding(amount)
    -- Would integrate with finance system
    if self.logger then
        self.logger:debug("BaseBuilder", string.format("Spent %d credits on construction", amount))
    end
end

--- Refund cancelled construction costs
-- @param amount Amount to refund
function BaseBuilder:_refundFunding(amount)
    -- Would integrate with finance system
    if self.logger then
        self.logger:debug("BaseBuilder", string.format("Refunded %d credits from cancelled construction", amount))
    end
end

--- Get facility construction cost
-- @param facility_type Type of facility
-- @return number Cost in credits
function BaseBuilder:_getFacilityCost(facility_type)
    -- Simplified costs - would be data-driven
    local costs = {
        access_lift = 50000,
        power_plant = 75000,
        living_quarters = 25000,
        laboratory = 100000,
        workshop = 80000,
        hangar = 150000,
        radar = 60000
    }
    return costs[facility_type] or 50000
end

--- Get facility build time
-- @param facility_type Type of facility
-- @return number Build time in days
function BaseBuilder:_getFacilityBuildTime(facility_type)
    -- Simplified times - would be data-driven
    local times = {
        access_lift = 3,
        power_plant = 5,
        living_quarters = 2,
        laboratory = 7,
        workshop = 6,
        hangar = 10,
        radar = 4
    }
    return times[facility_type] or 5
end

return BaseBuilder
