--- Economy Service
-- Unified service coordinating all economic systems
-- Manages manufacturing, research, transfers, marketplace, and resource allocation
--
-- @classmod economy.EconomyService

-- GROK: EconomyService is the central coordinator for all economic game systems
-- GROK: Integrates Manufacturing, Research, Transfers, Marketplace, and Suppliers
-- GROK: Key methods: processTimeTick(), getEconomicState(), allocateResources()
-- GROK: Handles time-based progression for all economic activities

local class = require 'lib.Middleclass'

--- EconomyService class
-- @type EconomyService
EconomyService = class('EconomyService')

--- Create a new EconomyService instance
-- @param registry Service registry for accessing other systems
-- @return EconomyService instance
function EconomyService:initialize(registry)
    self.registry = registry
    self.logger = registry and registry:logger() or nil
    self.eventBus = registry and registry:eventBus() or nil
    self.telemetry = registry and registry:telemetry() or nil
    
    -- Initialize sub-services (lazy loaded)
    self.manufacturingService = nil
    self.researchService = nil
    self.transferService = nil
    self.marketplaceService = nil
    self.supplierService = nil
    self.blackMarketService = nil
    
    -- Economic state
    self.lastUpdateTime = 0
    self.economicCycle = 0  -- Tracks economic cycles (monthly, quarterly, etc)
    
    -- Resource tracking
    self.globalResources = {
        money = 1000000,  -- Starting funds
        materials = 0,
        alloys = 0,
        electronics = 0,
        energy = 0
    }
    
    -- Statistics
    self.stats = {
        totalProduced = 0,
        totalResearched = 0,
        totalTransferred = 0,
        totalRevenue = 0,
        totalExpenses = 0
    }
    
    -- Subscribe to time events
    if self.eventBus then
        self.eventBus:subscribe("time:day_passed", function(payload)
            self:onDayPassed(payload)
        end)
        
        self.eventBus:subscribe("time:week_passed", function(payload)
            self:onWeekPassed(payload)
        end)
        
        self.eventBus:subscribe("time:month_passed", function(payload)
            self:onMonthPassed(payload)
        end)
    end
    
    if self.logger then
        self.logger:info("EconomyService initialized")
    end
    
    -- Register with service registry
    if registry then
        registry:registerService('economyService', self)
    end
end

--- Get or lazy-load manufacturing service
-- @return ManufacturingService instance
function EconomyService:getManufacturingService()
    if not self.manufacturingService then
        self.manufacturingService = self.registry and self.registry:getService('manufacturingService')
    end
    return self.manufacturingService
end

--- Get or lazy-load research service
-- @return ResearchService instance
function EconomyService:getResearchService()
    if not self.researchService then
        self.researchService = self.registry and self.registry:getService('researchService')
    end
    return self.researchService
end

--- Get or lazy-load transfer service
-- @return TransferService instance
function EconomyService:getTransferService()
    if not self.transferService then
        self.transferService = self.registry and self.registry:getService('transferService')
    end
    return self.transferService
end

--- Get or lazy-load marketplace service
-- @return MarketplaceService instance
function EconomyService:getMarketplaceService()
    if not self.marketplaceService then
        self.marketplaceService = self.registry and self.registry:getService('marketplaceService')
    end
    return self.marketplaceService
end

--- Get or lazy-load supplier service
-- @return SupplierService instance
function EconomyService:getSupplierService()
    if not self.supplierService then
        self.supplierService = self.registry and self.registry:getService('supplierService')
    end
    return self.supplierService
end

--- Process time tick (called every game hour/day)
-- @param deltaTime Time elapsed in game hours
function EconomyService:processTimeTick(deltaTime)
    -- Update manufacturing progress
    local manufacturing = self:getManufacturingService()
    if manufacturing and manufacturing.updateProduction then
        local completed = manufacturing:updateProduction(deltaTime)
        if completed > 0 then
            self.stats.totalProduced = self.stats.totalProduced + completed
        end
    end
    
    -- Update research progress
    local research = self:getResearchService()
    if research and research.updateProgress then
        local breakthroughs = research:updateProgress(deltaTime)
        if breakthroughs > 0 then
            self.stats.totalResearched = self.stats.totalResearched + breakthroughs
        end
    end
    
    -- Update transfers
    local transfer = self:getTransferService()
    if transfer and transfer.updateTransfers then
        local arrivals = transfer:updateTransfers(deltaTime)
        if arrivals > 0 then
            self.stats.totalTransferred = self.stats.totalTransferred + arrivals
        end
    end
    
    -- Update tracking
    self.lastUpdateTime = self.lastUpdateTime + deltaTime
    
    if self.telemetry then
        self.telemetry:increment("economy.ticks_processed")
    end
end

--- Handle day passed event
-- @param payload Event payload with date information
function EconomyService:onDayPassed(payload)
    if self.logger then
        self.logger:debug("EconomyService: Day passed - " .. (payload.day or "unknown"))
    end
    
    -- Process daily economic activities
    self:processTimeTick(24)  -- 24 game hours
    
    -- Emit daily economic update event
    if self.eventBus then
        self.eventBus:emit("economy:daily_update", {
            resources = self.globalResources,
            stats = self.stats
        })
    end
end

--- Handle week passed event
-- @param payload Event payload with date information
function EconomyService:onWeekPassed(payload)
    if self.logger then
        self.logger:debug("EconomyService: Week passed")
    end
    
    -- Process weekly activities (supplier refreshes, market updates)
    local marketplace = self:getMarketplaceService()
    if marketplace and marketplace.refreshMarket then
        marketplace:refreshMarket()
    end
    
    local supplier = self:getSupplierService()
    if supplier and supplier.refreshInventory then
        supplier:refreshInventory()
    end
    
    -- Emit weekly economic report
    if self.eventBus then
        self.eventBus:emit("economy:weekly_report", self:getWeeklyReport())
    end
end

--- Handle month passed event
-- @param payload Event payload with date information
function EconomyService:onMonthPassed(payload)
    if self.logger then
        self.logger:info("EconomyService: Month passed - generating monthly report")
    end
    
    self.economicCycle = self.economicCycle + 1
    
    -- Process monthly activities (funding, expenses, maintenance)
    self:processMonthlyFinances()
    
    -- Emit monthly economic report
    if self.eventBus then
        self.eventBus:emit("economy:monthly_report", self:getMonthlyReport())
    end
    
    -- Reset monthly stats
    self:resetMonthlyStats()
end

--- Process monthly financial operations
function EconomyService:processMonthlyFinances()
    -- Calculate maintenance costs
    local maintenanceCost = self:calculateMaintenanceCosts()
    self.globalResources.money = self.globalResources.money - maintenanceCost
    self.stats.totalExpenses = self.stats.totalExpenses + maintenanceCost
    
    -- Process funding income
    local funding = self:calculateMonthlyFunding()
    self.globalResources.money = self.globalResources.money + funding
    self.stats.totalRevenue = self.stats.totalRevenue + funding
    
    if self.logger then
        self.logger:info(string.format("Monthly finances: -$%d maintenance, +$%d funding",
                                      maintenanceCost, funding))
    end
end

--- Calculate maintenance costs for all facilities and operations
-- @return number: Total monthly maintenance cost
function EconomyService:calculateMaintenanceCosts()
    local totalCost = 0
    
    -- This would integrate with base management, craft maintenance, etc
    -- Placeholder for now
    totalCost = 50000  -- Base operating cost
    
    return totalCost
end

--- Calculate monthly funding from sponsors/governments
-- @return number: Total monthly funding
function EconomyService:calculateMonthlyFunding()
    local baseFunding = 200000  -- Base monthly allowance
    
    -- This would integrate with organization/country relationships
    -- Placeholder for now
    
    return baseFunding
end

--- Get current economic state
-- @return table: Complete economic state snapshot
function EconomyService:getEconomicState()
    return {
        resources = self.globalResources,
        stats = self.stats,
        cycle = self.economicCycle,
        lastUpdate = self.lastUpdateTime,
        
        -- Sub-service states
        manufacturing = self:getManufacturingState(),
        research = self:getResearchState(),
        transfers = self:getTransferState(),
        marketplace = self:getMarketplaceState()
    }
end

--- Get manufacturing state summary
-- @return table: Manufacturing state
function EconomyService:getManufacturingState()
    local manufacturing = self:getManufacturingService()
    if manufacturing and manufacturing.getState then
        return manufacturing:getState()
    end
    return {active = 0, queued = 0, capacity = 0}
end

--- Get research state summary
-- @return table: Research state
function EconomyService:getResearchState()
    local research = self:getResearchService()
    if research and research.getState then
        return research:getState()
    end
    return {active = 0, completed = 0, available = 0}
end

--- Get transfer state summary
-- @return table: Transfer state
function EconomyService:getTransferState()
    local transfer = self:getTransferService()
    if transfer and transfer.getState then
        return transfer:getState()
    end
    return {pending = 0, enRoute = 0}
end

--- Get marketplace state summary
-- @return table: Marketplace state
function EconomyService:getMarketplaceState()
    local marketplace = self:getMarketplaceService()
    if marketplace and marketplace.getState then
        return marketplace:getState()
    end
    return {listings = 0, volume = 0}
end

--- Get weekly economic report
-- @return table: Weekly report data
function EconomyService:getWeeklyReport()
    return {
        period = "week",
        cycle = self.economicCycle,
        produced = self.stats.totalProduced,
        researched = self.stats.totalResearched,
        transferred = self.stats.totalTransferred,
        resources = self.globalResources
    }
end

--- Get monthly economic report
-- @return table: Monthly report data
function EconomyService:getMonthlyReport()
    return {
        period = "month",
        cycle = self.economicCycle,
        revenue = self.stats.totalRevenue,
        expenses = self.stats.totalExpenses,
        netIncome = self.stats.totalRevenue - self.stats.totalExpenses,
        produced = self.stats.totalProduced,
        researched = self.stats.totalResearched,
        transferred = self.stats.totalTransferred,
        resources = self.globalResources,
        manufacturing = self:getManufacturingState(),
        research = self:getResearchState()
    }
end

--- Reset monthly statistics
function EconomyService:resetMonthlyStats()
    -- Note: We keep cumulative stats, just track monthly separately if needed
    -- For now, stats are cumulative across the campaign
end

--- Allocate resources to a project
-- @param resourceType string: Resource type (money, materials, etc)
-- @param amount number: Amount to allocate
-- @return boolean: Whether allocation succeeded
function EconomyService:allocateResources(resourceType, amount)
    if not self.globalResources[resourceType] then
        if self.logger then
            self.logger:warn("Unknown resource type: " .. resourceType)
        end
        return false
    end
    
    if self.globalResources[resourceType] < amount then
        if self.logger then
            self.logger:warn(string.format("Insufficient %s: need %d, have %d",
                                          resourceType, amount, self.globalResources[resourceType]))
        end
        return false
    end
    
    self.globalResources[resourceType] = self.globalResources[resourceType] - amount
    return true
end

--- Add resources to global pool
-- @param resourceType string: Resource type
-- @param amount number: Amount to add
function EconomyService:addResources(resourceType, amount)
    if not self.globalResources[resourceType] then
        self.globalResources[resourceType] = 0
    end
    
    self.globalResources[resourceType] = self.globalResources[resourceType] + amount
    
    if self.telemetry then
        self.telemetry:recordEvent({
            type = "resource_gained",
            resource = resourceType,
            amount = amount
        })
    end
end

--- Get available resources
-- @param resourceType string: Optional resource type filter
-- @return number|table: Resource amount or all resources
function EconomyService:getResources(resourceType)
    if resourceType then
        return self.globalResources[resourceType] or 0
    end
    return self.globalResources
end

--- Get economic statistics
-- @return table: Economic statistics
function EconomyService:getStatistics()
    return self.stats
end

return EconomyService
