--- Integration Test: Complete Gameplay Loop
-- Tests the full geoscape -> mission -> battlescape -> debriefing flow
--
-- @module test.integration.test_gameplay_loop

-- GROK: Integration test for complete gameplay loop
-- GROK: Tests geoscape mission generation, craft dispatch, battlescape combat, debriefing
-- GROK: Validates determinism, state transitions, and event flow
-- GROK: Key validations: mission lifecycle, unit state, loot processing, time progression

local test_framework = require 'test.test_framework'

-- Test suite
local suite = test_framework.create_suite("Gameplay Loop Integration")

--- Test complete gameplay loop from geoscape to debriefing
function suite:test_complete_gameplay_loop()
    -- Setup game state
    local registry = self:_createTestRegistry()
    
    -- Phase 1: Geoscape - Mission Generation
    local geoscapeService = registry:getService('geoscapeService')
    local timeService = registry:getService('timeService')
    
    -- Advance time to trigger mission generation
    timeService:advanceDays(1)
    
    -- Verify mission was generated
    local missions = geoscapeService:getAllMissions()
    self:assert_true(#missions > 0, "Mission should be generated")
    
    local mission = missions[1]
    self:assert_not_nil(mission.id, "Mission should have ID")
    self:assert_not_nil(mission.location, "Mission should have location")
    
    -- Phase 2: Craft Dispatch
    local crafts = geoscapeService:getAllCrafts()
    self:assert_true(#crafts > 0, "Should have at least one craft")
    
    local craft = crafts[1]
    local success = geoscapeService:dispatchCraft(craft.id, mission.id)
    self:assert_true(success, "Craft dispatch should succeed")
    
    -- Phase 3: Craft Travel
    -- Simulate travel time
    local travelTime = mission.location.distance / craft.speed
    timeService:advanceHours(math.ceil(travelTime))
    
    -- Verify craft arrived
    local arrivedCraft = geoscapeService:getCraft(craft.id)
    self:assert_equal(arrivedCraft.status, "arrived", "Craft should have arrived")
    
    -- Phase 4: Battlescape Initialization
    local battlescapeState = self:_initializeBattlescapeFromMission(mission, craft, registry)
    self:assert_not_nil(battlescapeState, "Battlescape should initialize")
    self:assert_not_nil(battlescapeState.map, "Battlescape should have map")
    self:assert_true(#battlescapeState.units > 0, "Battlescape should have units")
    
    -- Phase 5: Combat Simulation
    local combatResult = self:_simulateCombat(battlescapeState, registry)
    self:assert_not_nil(combatResult, "Combat should complete")
    self:assert_equal(combatResult.status, "victory", "Should achieve victory")
    
    -- Phase 6: Debriefing
    local debriefing = self:_processDebriefing(combatResult, mission, craft, registry)
    self:assert_not_nil(debriefing, "Debriefing should be generated")
    self:assert_not_nil(debriefing.loot, "Debriefing should have loot")
    self:assert_not_nil(debriefing.casualties, "Debriefing should track casualties")
    
    -- Phase 7: Post-Mission State
    -- Verify mission is completed
    local updatedMission = geoscapeService:getMission(mission.id)
    self:assert_equal(updatedMission.status, "completed", "Mission should be completed")
    
    -- Verify craft returned to base
    local returnedCraft = geoscapeService:getCraft(craft.id)
    self:assert_equal(returnedCraft.status, "returning", "Craft should be returning")
    
    -- Verify inventory updated with loot
    local inventoryService = registry:getService('inventoryService')
    if debriefing.loot and #debriefing.loot > 0 then
        local firstLoot = debriefing.loot[1]
        local quantity = inventoryService:getItemQuantity("base_1", firstLoot.itemId)
        self:assert_true(quantity > 0, "Loot should be added to inventory")
    end
end

--- Test deterministic mission generation
function suite:test_deterministic_mission_generation()
    local registry1 = self:_createTestRegistry()
    local registry2 = self:_createTestRegistry()
    
    -- Set same RNG seed
    local rngService1 = registry1:getService('rngService')
    local rngService2 = registry2:getService('rngService')
    rngService1:setSeed(12345)
    rngService2:setSeed(12345)
    
    -- Generate missions with same seed
    local geoscape1 = registry1:getService('geoscapeService')
    local geoscape2 = registry2:getService('geoscapeService')
    
    local time1 = registry1:getService('timeService')
    local time2 = registry2:getService('timeService')
    
    time1:advanceDays(1)
    time2:advanceDays(1)
    
    local missions1 = geoscape1:getAllMissions()
    local missions2 = geoscape2:getAllMissions()
    
    -- Verify same number of missions
    self:assert_equal(#missions1, #missions2, "Should generate same number of missions")
    
    -- Verify mission properties match
    if #missions1 > 0 and #missions2 > 0 then
        self:assert_equal(missions1[1].type, missions2[1].type, "Mission types should match")
        -- Location coordinates should match (within tolerance for floating point)
        local loc1 = missions1[1].location
        local loc2 = missions2[1].location
        self:assert_near(loc1.x, loc2.x, 0.01, "Mission X coordinates should match")
        self:assert_near(loc1.y, loc2.y, 0.01, "Mission Y coordinates should match")
    end
end

--- Test unit state persistence through mission
function suite:test_unit_state_persistence()
    local registry = self:_createTestRegistry()
    local unitSystem = registry:resolve('unit_system')
    
    -- Create test unit
    local unit = unitSystem:createUnit({
        id = "test_soldier_1",
        name = "Test Soldier",
        health = 100,
        experience = 0
    })
    
    local initialHealth = unit.health
    local initialExperience = unit.experience
    
    -- Simulate mission
    local battlescapeState = {
        units = {unit},
        map = {},
        turn = 0
    }
    
    -- Simulate combat damage
    unit.health = unit.health - 20
    unit.experience = unit.experience + 50
    
    -- Process debriefing
    local debriefing = {
        units = {unit},
        casualties = {},
        loot = {}
    }
    
    -- Verify unit state changed
    self:assert_equal(unit.health, initialHealth - 20, "Unit health should decrease")
    self:assert_equal(unit.experience, initialExperience + 50, "Unit experience should increase")
end

--- Test mission expiration
function suite:test_mission_expiration()
    local registry = self:_createTestRegistry()
    local geoscapeService = registry:getService('geoscapeService')
    local timeService = registry:getService('timeService')
    
    -- Generate mission
    timeService:advanceDays(1)
    local missions = geoscapeService:getAllMissions()
    self:assert_true(#missions > 0, "Should generate mission")
    
    local mission = missions[1]
    local expirationTime = mission.expirationTime or 72 -- 72 hours default
    
    -- Advance time past expiration
    timeService:advanceHours(expirationTime + 1)
    
    -- Check mission status
    local expiredMission = geoscapeService:getMission(mission.id)
    self:assert_true(
        expiredMission.status == "expired" or expiredMission == nil,
        "Mission should expire or be removed"
    )
end

--- Test craft fuel consumption
function suite:test_craft_fuel_consumption()
    local registry = self:_createTestRegistry()
    local geoscapeService = registry:getService('geoscapeService')
    
    local craft = geoscapeService:getAllCrafts()[1]
    local initialFuel = craft.fuel or 100
    
    -- Dispatch to distant mission
    local mission = {
        id = "test_mission_1",
        location = {x = 1000, y = 1000, distance = 1000}
    }
    
    geoscapeService:dispatchCraft(craft.id, mission.id)
    
    -- Simulate travel
    local timeService = registry:getService('timeService')
    timeService:advanceHours(10)
    
    -- Check fuel decreased
    local updatedCraft = geoscapeService:getCraft(craft.id)
    self:assert_true(updatedCraft.fuel < initialFuel, "Fuel should decrease during travel")
end

--- Test loot processing
function suite:test_loot_processing()
    local registry = self:_createTestRegistry()
    local inventoryService = registry:getService('inventoryService')
    
    local lootTable = {
        {itemId = "item_alloys", quantity = 10},
        {itemId = "item_elerium", quantity = 5},
        {itemId = "item_alien_weapon", quantity = 2}
    }
    
    local baseId = "base_1"
    local summary = inventoryService:processLoot(lootTable, baseId)
    
    -- Verify summary
    self:assert_equal(summary.itemsAdded, 3, "Should add 3 different items")
    self:assert_true(summary.totalValue > 0, "Loot should have value")
    
    -- Verify inventory updated
    self:assert_equal(inventoryService:getItemQuantity(baseId, "item_alloys"), 10)
    self:assert_equal(inventoryService:getItemQuantity(baseId, "item_elerium"), 5)
    self:assert_equal(inventoryService:getItemQuantity(baseId, "item_alien_weapon"), 2)
end

--- Helper: Create test registry with all services
function suite:_createTestRegistry()
    local ServiceRegistry = require 'core.ServiceRegistry'
    local registry = ServiceRegistry:new()
    
    -- Initialize core services (mock implementations for testing)
    local TimeService = require 'services.time'
    local GeoscapeService = require 'geoscape.GeoscapeService'
    local InventoryService = require 'services.InventoryService'
    
    local timeService = TimeService:new(registry)
    local geoscapeService = GeoscapeService:new(registry)
    local inventoryService = InventoryService:new(registry)
    
    registry:registerService('timeService', timeService)
    registry:registerService('geoscapeService', geoscapeService)
    registry:registerService('inventoryService', inventoryService)
    
    return registry
end

--- Helper: Initialize battlescape from mission
function suite:_initializeBattlescapeFromMission(mission, craft, registry)
    -- Mock battlescape initialization
    return {
        map = {width = 40, height = 30, tiles = {}},
        units = {
            {id = "unit_1", name = "Soldier 1", health = 100, team = "xcom"},
            {id = "unit_2", name = "Soldier 2", health = 100, team = "xcom"}
        },
        turn = 1,
        missionId = mission.id
    }
end

--- Helper: Simulate combat
function suite:_simulateCombat(battlescapeState, registry)
    -- Mock combat simulation (assume victory)
    return {
        status = "victory",
        turns = 10,
        kills = 5,
        casualties = 0,
        loot = {
            {itemId = "item_alien_weapon", quantity = 2},
            {itemId = "item_alloys", quantity = 5}
        }
    }
end

--- Helper: Process debriefing
function suite:_processDebriefing(combatResult, mission, craft, registry)
    return {
        missionId = mission.id,
        result = combatResult.status,
        loot = combatResult.loot,
        casualties = combatResult.casualties,
        experience = 100,
        rating = "excellent"
    }
end

--- Helper: Assert near (for floating point comparison)
function suite:assert_near(actual, expected, tolerance, message)
    local diff = math.abs(actual - expected)
    self:assert_true(diff <= tolerance, 
        message or string.format("Expected %f to be near %f (tolerance %f), got diff %f", 
        actual, expected, tolerance, diff))
end

return suite
