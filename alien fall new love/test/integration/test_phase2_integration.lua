--- Test suite for Phase 2 Core Integration
-- Tests Economy Service, Time Progression, and system integration
--
-- @module test.integration.test_phase2_integration

local test_framework = require "test.framework.test_framework"
local EconomyService = require "economy.EconomyService"
local TurnManager = require "engine.turn_manager"

local TestPhase2Integration = {}

--- Run all Phase 2 integration tests
function TestPhase2Integration.run()
    test_framework.run_suite("Phase 2 Integration", {
        test_economy_service_initialization = TestPhase2Integration.test_economy_service_initialization,
        test_time_progression_events = TestPhase2Integration.test_time_progression_events,
        test_economy_time_integration = TestPhase2Integration.test_economy_time_integration,
        test_resource_allocation = TestPhase2Integration.test_resource_allocation,
        test_monthly_finances = TestPhase2Integration.test_monthly_finances,
        test_economic_state = TestPhase2Integration.test_economic_state
    })
end

-- Mock registry for testing
local function createMockRegistry()
    local eventBus = {
        subscriptions = {},
        subscribe = function(self, topic, callback)
            if not self.subscriptions[topic] then
                self.subscriptions[topic] = {}
            end
            table.insert(self.subscriptions[topic], callback)
        end,
        publish = function(self, topic, payload)
            if self.subscriptions[topic] then
                for _, callback in ipairs(self.subscriptions[topic]) do
                    callback(payload)
                end
            end
        end,
        emit = function(self, topic, payload)
            self:publish(topic, payload)
        end
    }
    
    return {
        logger = function() return nil end,
        eventBus = function() return eventBus end,
        telemetry = function() return nil end,
        getService = function(self, name) return nil end,
        registerService = function(self, name, service) end
    }
end

-- Test: EconomyService initialization
function TestPhase2Integration.test_economy_service_initialization()
    local registry = createMockRegistry()
    local economy = EconomyService:new(registry)
    
    assert(economy ~= nil, "Should create EconomyService")
    assert(economy.globalResources ~= nil, "Should initialize resources")
    assert(economy.globalResources.money == 1000000, "Should have starting funds")
    assert(economy.stats ~= nil, "Should initialize stats")
    
    return true
end

-- Test: Time progression event emission
function TestPhase2Integration.test_time_progression_events()
    local registry = createMockRegistry()
    local eventBus = registry:eventBus()
    
    -- Track events
    local daysPassed = 0
    local weeksPassed = 0
    local monthsPassed = 0
    
    eventBus:subscribe("time:day_passed", function(payload)
        daysPassed = daysPassed + 1
    end)
    
    eventBus:subscribe("time:week_passed", function(payload)
        weeksPassed = weeksPassed + 1
    end)
    
    eventBus:subscribe("time:month_passed", function(payload)
        monthsPassed = monthsPassed + 1
    end)
    
    -- Create TurnManager
    local turnManager = TurnManager.new({eventBus = eventBus})
    
    -- Advance 1 day
    turnManager:advance(1)
    assert(daysPassed == 1, "Should emit day_passed event")
    
    -- Advance 6 days (complete week)
    turnManager:advance(6)
    assert(daysPassed == 7, "Should emit 7 day_passed events")
    assert(weeksPassed == 1, "Should emit 1 week_passed event")
    
    -- Advance to month (30 days total)
    turnManager:advance(23)
    assert(monthsPassed == 1, "Should emit month_passed event")
    
    return true
end

-- Test: Economy service integration with time
function TestPhase2Integration.test_economy_time_integration()
    local registry = createMockRegistry()
    local eventBus = registry:eventBus()
    
    -- Create economy service
    local economy = EconomyService:new(registry)
    
    -- Track economic events
    local dailyUpdates = 0
    local weeklyReports = 0
    local monthlyReports = 0
    
    eventBus:subscribe("economy:daily_update", function(payload)
        dailyUpdates = dailyUpdates + 1
    end)
    
    eventBus:subscribe("economy:weekly_report", function(payload)
        weeklyReports = weeklyReports + 1
    end)
    
    eventBus:subscribe("economy:monthly_report", function(payload)
        monthlyReports = monthlyReports + 1
    end)
    
    -- Trigger time events
    eventBus:publish("time:day_passed", {day = 1})
    assert(dailyUpdates == 1, "Should process daily update")
    
    eventBus:publish("time:week_passed", {week = 1})
    assert(weeklyReports == 1, "Should generate weekly report")
    
    eventBus:publish("time:month_passed", {month = 1})
    assert(monthlyReports == 1, "Should generate monthly report")
    
    return true
end

-- Test: Resource allocation
function TestPhase2Integration.test_resource_allocation()
    local registry = createMockRegistry()
    local economy = EconomyService:new(registry)
    
    -- Check initial resources
    assert(economy:getResources("money") == 1000000, "Should have starting money")
    
    -- Allocate resources
    local success = economy:allocateResources("money", 100000)
    assert(success == true, "Should allocate available resources")
    assert(economy:getResources("money") == 900000, "Should deduct allocated resources")
    
    -- Try to allocate more than available
    success = economy:allocateResources("money", 2000000)
    assert(success == false, "Should reject insufficient resources")
    assert(economy:getResources("money") == 900000, "Should not deduct on failed allocation")
    
    -- Add resources
    economy:addResources("alloys", 500)
    assert(economy:getResources("alloys") == 500, "Should add new resources")
    
    economy:addResources("alloys", 300)
    assert(economy:getResources("alloys") == 800, "Should accumulate resources")
    
    return true
end

-- Test: Monthly finances processing
function TestPhase2Integration.test_monthly_finances()
    local registry = createMockRegistry()
    local economy = EconomyService:new(registry)
    
    local initialMoney = economy:getResources("money")
    local initialCycle = economy.economicCycle
    
    -- Process month
    economy:onMonthPassed({month = 2})
    
    -- Check cycle increment
    assert(economy.economicCycle == initialCycle + 1, "Should increment economic cycle")
    
    -- Check finances (should have funding income and maintenance costs)
    local finalMoney = economy:getResources("money")
    -- Net should be positive (funding > maintenance in default config)
    assert(finalMoney > initialMoney, "Should have positive cash flow")
    
    -- Check stats
    assert(economy.stats.totalRevenue > 0, "Should track revenue")
    assert(economy.stats.totalExpenses > 0, "Should track expenses")
    
    return true
end

-- Test: Complete economic state
function TestPhase2Integration.test_economic_state()
    local registry = createMockRegistry()
    local economy = EconomyService:new(registry)
    
    -- Get economic state
    local state = economy:getEconomicState()
    
    assert(state.resources ~= nil, "Should include resources")
    assert(state.stats ~= nil, "Should include stats")
    assert(state.cycle ~= nil, "Should include cycle")
    assert(state.lastUpdate ~= nil, "Should include last update time")
    assert(state.manufacturing ~= nil, "Should include manufacturing state")
    assert(state.research ~= nil, "Should include research state")
    assert(state.transfers ~= nil, "Should include transfer state")
    assert(state.marketplace ~= nil, "Should include marketplace state")
    
    -- Check resource structure
    assert(state.resources.money ~= nil, "Should have money")
    assert(state.resources.materials ~= nil, "Should have materials")
    assert(state.resources.alloys ~= nil, "Should have alloys")
    
    return true
end

return TestPhase2Integration
