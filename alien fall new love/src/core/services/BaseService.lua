--- Base Service Class
--- Provides common functionality for all game services including initialization,
--- shutdown lifecycle, and registry access patterns.
---
--- @module core.services.BaseService
--- @author AlienFall Development Team
--- @copyright 2025

local class = require('lib.middleclass')

--- BaseService class that all services should inherit from
--- Provides standardized initialization, shutdown, and registry access
---
--- @class BaseService
local BaseService = class('BaseService')

--- Initialize a new service instance
--- Override this in subclasses to add custom initialization
---
--- @param registry table The service registry instance
function BaseService:initialize(registry)
    self.registry = registry
    self.initialized = false
    self.shutdown_called = false
end

--- Get the service registry
--- Provides access to other services
---
--- @return table The service registry
function BaseService:getRegistry()
    return self.registry
end

--- Get another service from the registry
--- Convenience method for service dependencies
---
--- @param service_name string Name of the service to retrieve
--- @return any The requested service instance
function BaseService:getService(service_name)
    if not self.registry then
        error("Service registry not available - was initialize() called?")
    end
    return self.registry:get(service_name)
end

--- Check if a service is available in the registry
--- Useful for optional dependencies
---
--- @param service_name string Name of the service to check
--- @return boolean True if service exists
function BaseService:hasService(service_name)
    if not self.registry then
        return false
    end
    return self.registry:has(service_name)
end

--- Initialize the service
--- Override this in subclasses to perform actual initialization
--- Always call BaseService.init(self) first in overrides
---
--- @return boolean Success status
function BaseService:init()
    if self.initialized then
        print(string.format("Warning: %s already initialized", self.class.name))
        return true
    end
    
    self.initialized = true
    return true
end

--- Shutdown the service and release resources
--- Override this in subclasses to perform actual cleanup
--- Always call BaseService.shutdown(self) last in overrides
---
--- @return boolean Success status
function BaseService:shutdown()
    if self.shutdown_called then
        print(string.format("Warning: %s shutdown already called", self.class.name))
        return true
    end
    
    self.shutdown_called = true
    self.initialized = false
    return true
end

--- Check if service is initialized
---
--- @return boolean True if service is initialized
function BaseService:isInitialized()
    return self.initialized == true
end

--- Check if service has been shutdown
---
--- @return boolean True if service has been shutdown
function BaseService:isShutdown()
    return self.shutdown_called == true
end

--- Ensure service is initialized before use
--- Throws an error if service is not initialized
--- Use this in methods that require initialization
---
--- @throws error if service not initialized
function BaseService:requireInitialized()
    if not self.initialized then
        error(string.format("%s must be initialized before use - call init() first", self.class.name))
    end
end

--- Ensure service is not shutdown
--- Throws an error if service has been shutdown
---
--- @throws error if service is shutdown
function BaseService:requireNotShutdown()
    if self.shutdown_called then
        error(string.format("%s has been shutdown and cannot be used", self.class.name))
    end
end

--- Get service name
--- Returns the class name by default
---
--- @return string Service name
function BaseService:getName()
    return self.class.name
end

--- Flush any cached data or pending operations
--- Override this in subclasses that maintain caches
--- Called during shutdown by default
function BaseService:flush()
    -- Default implementation does nothing
    -- Override in subclasses that need flushing
end

--- Update method for services that need periodic updates
--- Override this in subclasses that need to be updated every frame
---
--- @param dt number Delta time since last update
function BaseService:update(dt)
    -- Default implementation does nothing
    -- Override in subclasses that need updates
end

--- Get debug information about the service
--- Override this in subclasses to provide detailed debug info
---
--- @return table Debug information
function BaseService:getDebugInfo()
    return {
        name = self:getName(),
        initialized = self.initialized,
        shutdown = self.shutdown_called
    }
end

return BaseService
