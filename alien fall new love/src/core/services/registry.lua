local Telemetry = require "engine.telemetry"
local Logger = require "engine.logger"
local EventBus = require "engine.event_bus"
local RngService = require "engine.rng"
local TurnManager = require "engine.turn_manager"
local AssetCache = require "engine.asset_cache"
local AudioStub = require "engine.audio_stub"
local SaveService = require "engine.save"
local DataLoader = require "engine.data_loader"
local DataCatalog = require "engine.data_catalog"
local DataRegistry = require "core.services.data_registry"
local BaseManager = require "services.BaseManager"
local ModLoader = require "mods.loader"
local AIDirector = require "ai.AIDirector"
local InterceptionService = require "interception.InterceptionService"
local ItemService = require "services.ItemService"
local PediaService = require "services.PediaService"
local OrganizationService = require "services.OrganizationService"
local FinanceService = require "finance.FinanceService"



local ServiceRegistry = {}
ServiceRegistry.__index = ServiceRegistry

--- Creates a new service registry instance
-- @param config table Configuration options
-- @param config.telemetry boolean Whether telemetry is enabled (default: true)
-- @param config.logLevel string Log level for logger (default: "debug")
-- @return ServiceRegistry New service registry instance
function ServiceRegistry.new(config)
    local self = setmetatable({}, ServiceRegistry)
    config = config or {}
    self.config = config
    self.services = {}

    self.services.telemetry = Telemetry.new({ enabled = config.telemetry ~= false })
    self.services.logger = Logger.new({ level = config.logLevel or "debug", telemetry = self.services.telemetry })
    self.services.event_bus = EventBus.new({ telemetry = self.services.telemetry })
    self.services.rng = RngService.new({ telemetry = self.services.telemetry })
    self.services.turn_manager = TurnManager.new({
        eventBus = self.services.event_bus,
        telemetry = self.services.telemetry
    })
    self.services.asset_cache = AssetCache.new({ telemetry = self.services.telemetry })
    self.services.audio = AudioStub.new()
    self.services.save = SaveService.new({ telemetry = self.services.telemetry })
    
    -- Initialize Data Loader (must be before mod_loader)
    self.services.data_loader = DataLoader.new({
        telemetry = self.services.telemetry,
        logger = self.services.logger
    })
    
    -- Initialize Data Catalog
    self.services.data_catalog = DataCatalog.new({
        telemetry = self.services.telemetry,
        logger = self.services.logger
    })
    
    self.services.data_registry = DataRegistry.new({
        telemetry = self.services.telemetry,
        logger = self.services.logger
    })
    self.services.base_manager = BaseManager.new({
        telemetry = self.services.telemetry,
        logger = self.services.logger
    })
    self.services.mod_loader = ModLoader.new({
        telemetry = self.services.telemetry,
        logger = self.services.logger,
        dataRegistry = self.services.data_registry,
        dataLoader = self.services.data_loader
    })

    -- Initialize AI Director with campaign seed (will be set when game starts)
    self.services.ai_director = nil

    -- Initialize Interception Service
    self.services.interception_service = InterceptionService:new(self)

    -- Initialize Finance Service
    self.services.finance_service = FinanceService:new(self)

    -- Initialize Item Service
    self.services.item_service = ItemService:new(self)

    -- Initialize Pedia Service
    self.services.pedia_service = PediaService:new(self)

    -- Initialize Organization Service
    self.services.organization_service = OrganizationService:new(self)

    return self
end

function ServiceRegistry:eventBus()
    return self.services.event_bus
end

function ServiceRegistry:logger()
    return self.services.logger
end

function ServiceRegistry:telemetry()
    return self.services.telemetry
end

function ServiceRegistry:dataLoader()
    return self.services.data_loader
end

function ServiceRegistry:dataCatalog()
    return self.services.data_catalog
end

function ServiceRegistry:resolve(name)
    return self.services[name]
end

function ServiceRegistry:loadMods(modSet)
    local loader = self.services.mod_loader
    if not loader then
        return {}
    end
    return loader:loadModset(modSet)
end

function ServiceRegistry:update(dt)
    -- placeholder for services requiring updates in future
    if self.services.audio and self.services.audio.update then
        self.services.audio:update(dt)
    end

    -- Update AI Director if initialized
    if self.services.ai_director then
        self.services.ai_director:update(dt)
    end
end

--- Shutdown all services and cleanup resources
-- Calls shutdown() on all services that support it
function ServiceRegistry:shutdown()
    local logger = self.services.logger
    if logger then
        logger:info("Shutting down service registry...")
    end
    
    -- Shutdown services in reverse order of initialization
    local shutdownOrder = {
        "organization_service",
        "pedia_service", 
        "item_service",
        "finance_service",
        "interception_service",
        "ai_director",
        "mod_loader",
        "base_manager",
        "data_registry",
        "data_catalog",
        "data_loader",
        "save",
        "audio",
        "asset_cache",
        "turn_manager",
        "rng",
        "event_bus",
        "logger",
        "telemetry"
    }
    
    for _, serviceName in ipairs(shutdownOrder) do
        local service = self.services[serviceName]
        if service then
            if type(service.shutdown) == "function" then
                local ok, err = pcall(service.shutdown, service)
                if not ok and logger then
                    logger:error("Error shutting down " .. serviceName .. ": " .. tostring(err))
                end
            elseif type(service.clear) == "function" then
                -- Fallback for services with clear() method
                local ok, err = pcall(service.clear, service)
                if not ok and logger then
                    logger:error("Error clearing " .. serviceName .. ": " .. tostring(err))
                end
            elseif type(service.flush) == "function" then
                -- Fallback for services with flush() method
                local ok, err = pcall(service.flush, service)
                if not ok and logger then
                    logger:error("Error flushing " .. serviceName .. ": " .. tostring(err))
                end
            end
        end
    end
    
    -- Clear services table
    self.services = {}
    
    if logger then
        logger:info("Service registry shutdown complete")
    end
end

function ServiceRegistry:initializeAIDirector(campaignSeed)
    if not self.services.ai_director then
        self.services.ai_director = AIDirector:new(campaignSeed)
        self.services.logger:info("AI Director initialized with campaign seed: " .. campaignSeed)
    end
    return self.services.ai_director
end

return ServiceRegistry
