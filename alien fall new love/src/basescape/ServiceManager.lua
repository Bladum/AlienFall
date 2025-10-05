--- Service Manager Class
-- Manages base service dependencies, availability, and cascading effects between facilities
--
-- @classmod basescape.ServiceManager

local class = require 'lib.Middleclass'

ServiceManager = class('ServiceManager')

--- Service type categories
ServiceManager.CATEGORY_CORE = "core"           -- Essential for base survival (power_supply, connectivity, personnel_capacity)
ServiceManager.CATEGORY_OPERATIONAL = "operational" -- Enable primary functions (research, manufacture, craft_repair)
ServiceManager.CATEGORY_SUPPORT = "support"     -- Enhance efficiency and quality (radar_service, medical_support, training_facility)
ServiceManager.CATEGORY_DEFENSIVE = "defensive" -- Provide protection and security (base_defense_emplacement, monitoring_system)

--- Service operational states
ServiceManager.STATE_ONLINE = "online"         -- Service fully available at peak effectiveness
ServiceManager.STATE_DEGRADED = "degraded"     -- Service available but at reduced capacity/efficiency
ServiceManager.STATE_OFFLINE = "offline"       -- Service completely unavailable
ServiceManager.STATE_MAINTENANCE = "maintenance" -- Service temporarily unavailable for upkeep

--- Create a new service manager instance
-- @param registry Service registry for accessing other systems
-- @param base_id ID of the base this manager serves
-- @return ServiceManager New service manager instance
function ServiceManager:initialize(registry, base_id)
    self.registry = registry
    self.logger = registry and registry:logger() or nil
    self.event_bus = registry and registry:eventBus() or nil

    self.base_id = base_id

    -- Service definitions: service_id -> service_info
    self.services = {}

    -- Service providers: service_id -> {facility_id -> contribution_info}
    self.providers = {}

    -- Service consumers: service_id -> {consumer_id -> requirement_info}
    self.consumers = {}

    -- Service status: service_id -> current_state
    self.service_states = {}

    -- Dependency graph: service_id -> {dependent_service_id -> dependency_info}
    self.dependency_graph = {}

    -- Reverse dependency graph: service_id -> {services_that_depend_on_this}
    self.reverse_dependencies = {}

    -- Service utilization: service_id -> current_utilization
    self.utilization = {}

    -- Initialize default services
    self:_initializeDefaultServices()

    if self.logger then
        self.logger:info("ServiceManager", string.format("Created service manager for base %s", base_id))
    end
end

--- Initialize default base services
function ServiceManager:_initializeDefaultServices()
    -- Core services
    self:addService("power_supply", ServiceManager.CATEGORY_CORE, {
        description = "Electrical power distribution",
        required_for = {"research", "manufacture", "medical", "radar"},
        fallback_behavior = "shutdown_dependents"
    })

    self:addService("connectivity", ServiceManager.CATEGORY_CORE, {
        description = "Base corridor network access",
        required_for = {"all_facilities"},
        fallback_behavior = "isolate_facilities"
    })

    self:addService("personnel_capacity", ServiceManager.CATEGORY_CORE, {
        description = "Living quarters and personnel support",
        required_for = {"research", "manufacture", "medical"},
        fallback_behavior = "reduce_efficiency"
    })

    -- Operational services
    self:addService("research", ServiceManager.CATEGORY_OPERATIONAL, {
        description = "Scientific research and analysis",
        required_for = {"technology_development"},
        fallback_behavior = "suspend_projects"
    })

    self:addService("manufacture", ServiceManager.CATEGORY_OPERATIONAL, {
        description = "Equipment and craft production",
        required_for = {"item_production", "craft_repair"},
        fallback_behavior = "queue_production"
    })

    self:addService("craft_repair", ServiceManager.CATEGORY_OPERATIONAL, {
        description = "Aircraft maintenance and repair",
        required_for = {"interception_operations"},
        fallback_behavior = "ground_craft"
    })

    -- Support services
    self:addService("radar_service", ServiceManager.CATEGORY_SUPPORT, {
        description = "Detection and tracking coverage",
        required_for = {"geoscape_awareness"},
        fallback_behavior = "reduce_detection"
    })

    self:addService("medical_support", ServiceManager.CATEGORY_SUPPORT, {
        description = "Health care and recovery",
        required_for = {"unit_healing", "personnel_morale"},
        fallback_behavior = "slow_recovery"
    })

    self:addService("training_facility", ServiceManager.CATEGORY_SUPPORT, {
        description = "Soldier training and development",
        required_for = {"unit_progression"},
        fallback_behavior = "halt_training"
    })

    -- Defensive services
    self:addService("base_defense", ServiceManager.CATEGORY_DEFENSIVE, {
        description = "Base defense and security",
        required_for = {"tactical_defense"},
        fallback_behavior = "reduce_defense"
    })

    self:addService("monitoring_system", ServiceManager.CATEGORY_DEFENSIVE, {
        description = "Security monitoring and alerts",
        required_for = {"intrusion_detection"},
        fallback_behavior = "blind_security"
    })
end

--- Add a new service definition
-- @param service_id Unique service identifier
-- @param category Service category
-- @param config Service configuration table
function ServiceManager:addService(service_id, category, config)
    self.services[service_id] = {
        id = service_id,
        category = category,
        description = config.description or "",
        required_for = config.required_for or {},
        fallback_behavior = config.fallback_behavior or "degrade",
        max_utilization = config.max_utilization or 100,
        staffing_requirement = config.staffing_requirement or 0,
        maintenance_schedule = config.maintenance_schedule or 30 -- days
    }

    self.providers[service_id] = {}
    self.consumers[service_id] = {}
    self.service_states[service_id] = ServiceManager.STATE_OFFLINE
    self.utilization[service_id] = 0
    self.dependency_graph[service_id] = {}
    self.reverse_dependencies[service_id] = {}

    if self.logger then
        self.logger:debug("ServiceManager", string.format("Added service %s (%s category)", service_id, category))
    end
end

--- Register a facility as a service provider
-- @param facility_id ID of the providing facility
-- @param service_id ID of the service provided
-- @param contribution Service contribution details
function ServiceManager:registerProvider(facility_id, service_id, contribution)
    if not self.services[service_id] then
        if self.logger then
            self.logger:warn("ServiceManager", string.format("Unknown service %s", service_id))
        end
        return false
    end

    self.providers[service_id][facility_id] = {
        facility_id = facility_id,
        contribution = contribution or {},
        operational = true,
        last_update = os.time()
    }

    -- Update service availability
    self:_updateServiceAvailability(service_id)

    if self.logger then
        self.logger:debug("ServiceManager", string.format("Facility %s registered as provider for %s", facility_id, service_id))
    end

    return true
end

--- Unregister a facility as a service provider
-- @param facility_id ID of the providing facility
-- @param service_id ID of the service provided
function ServiceManager:unregisterProvider(facility_id, service_id)
    if self.providers[service_id] and self.providers[service_id][facility_id] then
        self.providers[service_id][facility_id] = nil

        -- Update service availability
        self:_updateServiceAvailability(service_id)

        if self.logger then
            self.logger:debug("ServiceManager", string.format("Facility %s unregistered as provider for %s", facility_id, service_id))
        end
    end
end

--- Register a service consumer
-- @param consumer_id ID of the consuming entity
-- @param service_id ID of the required service
-- @param requirement Service requirement details
function ServiceManager:registerConsumer(consumer_id, service_id, requirement)
    if not self.services[service_id] then
        if self.logger then
            self.logger:warn("ServiceManager", string.format("Unknown service %s", service_id))
        end
        return false
    end

    self.consumers[service_id][consumer_id] = {
        consumer_id = consumer_id,
        requirement = requirement or {},
        satisfied = false,
        last_check = os.time()
    }

    if self.logger then
        self.logger:debug("ServiceManager", string.format("Consumer %s registered for service %s", consumer_id, service_id))
    end

    return true
end

--- Unregister a service consumer
-- @param consumer_id ID of the consuming entity
-- @param service_id ID of the required service
function ServiceManager:unregisterConsumer(consumer_id, service_id)
    if self.consumers[service_id] and self.consumers[service_id][consumer_id] then
        self.consumers[service_id][consumer_id] = nil

        if self.logger then
            self.logger:debug("ServiceManager", string.format("Consumer %s unregistered for service %s", consumer_id, service_id))
        end
    end
end

--- Add a service dependency
-- @param dependent_service Service that depends on another
-- @param required_service Service that is required
-- @param dependency_info Dependency details
function ServiceManager:addDependency(dependent_service, required_service, dependency_info)
    if not self.services[dependent_service] or not self.services[required_service] then
        return false
    end

    self.dependency_graph[dependent_service][required_service] = dependency_info or {}
    self.reverse_dependencies[required_service][dependent_service] = true

    if self.logger then
        self.logger:debug("ServiceManager", string.format("Added dependency: %s requires %s", dependent_service, required_service))
    end

    return true
end

--- Update service availability based on providers
-- @param service_id ID of the service to update
function ServiceManager:_updateServiceAvailability(service_id)
    local providers = self.providers[service_id]
    if not providers then return end

    -- Check if any providers are operational
    local has_provider = false
    local total_contribution = 0

    for facility_id, provider_info in pairs(providers) do
        if provider_info.operational then
            has_provider = true
            -- Calculate contribution (could be based on facility health, staffing, etc.)
            total_contribution = total_contribution + (provider_info.contribution.capacity or 1)
        end
    end

    -- Check if all dependencies are satisfied
    local deps_satisfied = true
    for required_service, _ in pairs(self.dependency_graph[service_id]) do
        if self.service_states[required_service] == ServiceManager.STATE_OFFLINE then
            deps_satisfied = false
            break
        end
    end

    -- Update service state
    local old_state = self.service_states[service_id]

    if has_provider and deps_satisfied then
        if total_contribution >= (self.services[service_id].max_utilization or 100) then
            self.service_states[service_id] = ServiceManager.STATE_ONLINE
        else
            self.service_states[service_id] = ServiceManager.STATE_DEGRADED
        end
    else
        self.service_states[service_id] = ServiceManager.STATE_OFFLINE
    end

    -- Check for state changes and cascading effects
    if old_state ~= self.service_states[service_id] then
        self:_handleServiceStateChange(service_id, old_state, self.service_states[service_id])
    end
end

--- Handle service state changes and cascading effects
-- @param service_id ID of the service that changed
-- @param old_state Previous state
-- @param new_state New state
function ServiceManager:_handleServiceStateChange(service_id, old_state, new_state)
    if self.logger then
        self.logger:info("ServiceManager", string.format("Service %s changed from %s to %s", service_id, old_state, new_state))
    end

    -- Publish event
    if self.event_bus then
        self.event_bus:publish("basescape:service_changed", {
            base_id = self.base_id,
            service_id = service_id,
            old_state = old_state,
            new_state = new_state,
            timestamp = os.time()
        })
    end

    -- Handle cascading effects for dependent services
    for dependent_service, _ in pairs(self.reverse_dependencies[service_id]) do
        if new_state == ServiceManager.STATE_OFFLINE then
            -- Required service went offline, may affect dependent
            self:_handleDependencyFailure(dependent_service, service_id)
        elseif new_state == ServiceManager.STATE_ONLINE then
            -- Required service came online, may restore dependent
            self:_handleDependencyRestoration(dependent_service, service_id)
        end
    end

    -- Update consumer satisfaction
    self:_updateConsumerSatisfaction(service_id)
end

--- Handle dependency failure
-- @param dependent_service Service affected by dependency failure
-- @param failed_service Service that failed
function ServiceManager:_handleDependencyFailure(dependent_service, failed_service)
    local service_config = self.services[dependent_service]
    if not service_config then return end

    -- Apply fallback behavior
    local fallback = service_config.fallback_behavior

    if fallback == "shutdown_dependents" then
        self.service_states[dependent_service] = ServiceManager.STATE_OFFLINE
        if self.logger then
            self.logger:warn("ServiceManager", string.format("Service %s shut down due to %s failure", dependent_service, failed_service))
        end
    elseif fallback == "suspend_projects" then
        self.service_states[dependent_service] = ServiceManager.STATE_OFFLINE
        if self.logger then
            self.logger:warn("ServiceManager", string.format("Service %s suspended due to %s failure", dependent_service, failed_service))
        end
    elseif fallback == "reduce_efficiency" then
        if self.service_states[dependent_service] == ServiceManager.STATE_ONLINE then
            self.service_states[dependent_service] = ServiceManager.STATE_DEGRADED
            if self.logger then
                self.logger:warn("ServiceManager", string.format("Service %s efficiency reduced due to %s failure", dependent_service, failed_service))
            end
        end
    end

    -- Recursively handle cascading failures
    for cascading_dependent, _ in pairs(self.reverse_dependencies[dependent_service]) do
        self:_handleDependencyFailure(cascading_dependent, dependent_service)
    end
end

--- Handle dependency restoration
-- @param dependent_service Service that may be restored
-- @param restored_service Service that was restored
function ServiceManager:_handleDependencyRestoration(dependent_service, restored_service)
    -- Check if all dependencies are now satisfied
    local all_deps_satisfied = true

    for required_service, _ in pairs(self.dependency_graph[dependent_service]) do
        if self.service_states[required_service] == ServiceManager.STATE_OFFLINE then
            all_deps_satisfied = false
            break
        end
    end

    if all_deps_satisfied and self.service_states[dependent_service] == ServiceManager.STATE_OFFLINE then
        -- Try to restore service
        self:_updateServiceAvailability(dependent_service)
        if self.logger then
            self.logger:info("ServiceManager", string.format("Service %s restored due to %s restoration", dependent_service, restored_service))
        end
    end
end

--- Update consumer satisfaction for a service
-- @param service_id ID of the service
function ServiceManager:_updateConsumerSatisfaction(service_id)
    local consumers = self.consumers[service_id]
    if not consumers then return end

    local service_state = self.service_states[service_id]

    for consumer_id, consumer_info in pairs(consumers) do
        local was_satisfied = consumer_info.satisfied
        consumer_info.satisfied = (service_state == ServiceManager.STATE_ONLINE or service_state == ServiceManager.STATE_DEGRADED)
        consumer_info.last_check = os.time()

        -- Notify consumer of change
        if was_satisfied ~= consumer_info.satisfied then
            if self.event_bus then
                self.event_bus:publish("basescape:service_consumer_update", {
                    base_id = self.base_id,
                    service_id = service_id,
                    consumer_id = consumer_id,
                    satisfied = consumer_info.satisfied,
                    service_state = service_state
                })
            end
        end
    end
end

--- Check if a service is available
-- @param service_id ID of the service to check
-- @return boolean Is available
-- @return string Current state
function ServiceManager:isServiceAvailable(service_id)
    local state = self.service_states[service_id]
    if not state then return false, "unknown" end

    local available = (state == ServiceManager.STATE_ONLINE or state == ServiceManager.STATE_DEGRADED)
    return available, state
end

--- Get service utilization information
-- @param service_id ID of the service (optional, returns all if nil)
-- @return table Service information
function ServiceManager:getServiceInfo(service_id)
    if service_id then
        if not self.services[service_id] then
            return nil
        end

        local provider_count = 0
        for _ in pairs(self.providers[service_id]) do
            provider_count = provider_count + 1
        end

        local consumer_count = 0
        for _ in pairs(self.consumers[service_id]) do
            consumer_count = consumer_count + 1
        end

        return {
            id = service_id,
            category = self.services[service_id].category,
            description = self.services[service_id].description,
            state = self.service_states[service_id],
            utilization = self.utilization[service_id],
            max_utilization = self.services[service_id].max_utilization,
            provider_count = provider_count,
            consumer_count = consumer_count,
            required_for = self.services[service_id].required_for,
            fallback_behavior = self.services[service_id].fallback_behavior
        }
    else
        -- Return all services
        local all_info = {}
        for svc_id, _ in pairs(self.services) do
            all_info[svc_id] = self:getServiceInfo(svc_id)
        end
        return all_info
    end
end

--- Update service manager (called each frame)
-- @param dt Time delta
function ServiceManager:update(dt)
    -- Service updates would go here (maintenance scheduling, utilization tracking, etc.)
    -- For now, this is a placeholder
end

--- Get service status summary
-- @return table Summary statistics
function ServiceManager:getServiceSummary()
    local summary = {
        total_services = 0,
        online_services = 0,
        degraded_services = 0,
        offline_services = 0,
        maintenance_services = 0,
        total_providers = 0,
        total_consumers = 0
    }

    for service_id, service_info in pairs(self.services) do
        summary.total_services = summary.total_services + 1

        local state = self.service_states[service_id]
        if state == ServiceManager.STATE_ONLINE then
            summary.online_services = summary.online_services + 1
        elseif state == ServiceManager.STATE_DEGRADED then
            summary.degraded_services = summary.degraded_services + 1
        elseif state == ServiceManager.STATE_OFFLINE then
            summary.offline_services = summary.offline_services + 1
        elseif state == ServiceManager.STATE_MAINTENANCE then
            summary.maintenance_services = summary.maintenance_services + 1
        end

        -- Count providers and consumers
        for _ in pairs(self.providers[service_id]) do
            summary.total_providers = summary.total_providers + 1
        end

        for _ in pairs(self.consumers[service_id]) do
            summary.total_consumers = summary.total_consumers + 1
        end
    end

    return summary
end

return ServiceManager
