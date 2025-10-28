---Black Market Expansion Tests
---Tests for mission generation, event purchasing, access tiers

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local suite = HierarchicalSuite.new("BlackMarketExpansion", "tests2/economy/black_market_expansion_test.lua")

local MissionGeneration, EventPurchasing, BlackMarketSystem

suite:beforeAll(function()
    MissionGeneration = require("engine.economy.mission_generation")
    EventPurchasing = require("engine.economy.event_purchasing")
    BlackMarketSystem = require("engine.economy.marketplace.black_market_system")
end)

-- Mission Generation Tests
suite:testMethod("MissionGeneration.getAllMissionTypes", {
    description = "Returns all 7 mission types",
    testCase = "all_mission_types",
    type = "functional"
}, function()
    local missions = MissionGeneration.getAllMissionTypes()
    suite:assert(#missions == 7, "Should have 7 mission types")

    local types = {}
    for _, mission in ipairs(missions) do
        types[mission.id] = true
    end

    suite:assert(types.assassination, "Should include assassination")
    suite:assert(types.sabotage, "Should include sabotage")
    suite:assert(types.heist, "Should include heist")
    suite:assert(types.kidnapping, "Should include kidnapping")
    suite:assert(types.false_flag, "Should include false_flag")
    suite:assert(types.data_theft, "Should include data_theft")
    suite:assert(types.smuggling, "Should include smuggling")
end)

suite:testMethod("MissionGeneration.getMissionDefinition", {
    description = "Returns correct mission definition",
    testCase = "mission_definition",
    type = "functional"
}, function()
    local assassination = MissionGeneration.getMissionDefinition("assassination")
    suite:assert(assassination ~= nil, "Should return assassination mission")
    suite:assert(assassination.base_cost == 50000, "Cost should be 50K")
    suite:assert(assassination.karma_penalty == -30, "Karma penalty should be -30")
end)

suite:testMethod("MissionGeneration.getAvailableMissions", {
    description = "Filters missions by karma level",
    testCase = "available_missions_karma",
    type = "functional"
}, function()
    -- High karma: few missions
    local highKarma = MissionGeneration.getAvailableMissions(50)
    suite:assert(#highKarma == 0, "No missions at high karma")

    -- Medium karma: some missions
    local mediumKarma = MissionGeneration.getAvailableMissions(-10)
    suite:assert(#mediumKarma >= 2, "Should have light missions")

    -- Low karma: all missions
    local lowKarma = MissionGeneration.getAvailableMissions(-100)
    suite:assert(#lowKarma == 7, "Should have all missions at low karma")
end)

-- Event Purchasing Tests
suite:testMethod("EventPurchasing.getAllEventTypes", {
    description = "Returns all 8 event types",
    testCase = "all_event_types",
    type = "functional"
}, function()
    local events = EventPurchasing.getAllEventTypes()
    suite:assert(#events == 8, "Should have 8 event types")

    local types = {}
    for _, event in ipairs(events) do
        types[event.id] = true
    end

    suite:assert(types.improve_relations, "Should include improve_relations")
    suite:assert(types.sabotage_economy, "Should include sabotage_economy")
    suite:assert(types.incite_rebellion, "Should include incite_rebellion")
    suite:assert(types.spread_propaganda, "Should include spread_propaganda")
    suite:assert(types.frame_rival, "Should include frame_rival")
    suite:assert(types.bribe_officials, "Should include bribe_officials")
    suite:assert(types.crash_market, "Should include crash_market")
    suite:assert(types.false_intelligence, "Should include false_intelligence")
end)

suite:testMethod("EventPurchasing.getEventDefinition", {
    description = "Returns correct event definition",
    testCase = "event_definition",
    type = "functional"
}, function()
    local sabotage = EventPurchasing.getEventDefinition("sabotage_economy")
    suite:assert(sabotage ~= nil, "Should return sabotage event")
    suite:assert(sabotage.base_cost == 50000, "Cost should be 50K")
    suite:assert(sabotage.karma_penalty == -25, "Karma penalty should be -25")
    suite:assert(sabotage.target_type == "province", "Should target province")
end)

suite:testMethod("EventPurchasing.getAvailableEvents", {
    description = "Filters events by karma and fame",
    testCase = "available_events_filtering",
    type = "functional"
}, function()
    -- High karma, low fame: no events
    local none = EventPurchasing.getAvailableEvents(50, 10)
    suite:assert(#none == 0, "No events at high karma")

    -- Low karma, low fame: some events
    local some = EventPurchasing.getAvailableEvents(-50, 30)
    suite:assert(#some > 0, "Should have some events")

    -- Low karma, high fame: all events
    local all = EventPurchasing.getAvailableEvents(-100, 100)
    suite:assert(#all == 8, "Should have all events")
end)

-- Access Tier Tests
suite:testMethod("BlackMarketSystem.getAccessLevel", {
    description = "Returns correct access tier based on karma/fame",
    testCase = "access_tiers",
    type = "functional"
}, function()
    local bm = BlackMarketSystem.new()

    -- Too high karma: no access
    suite:assert(bm:getAccessLevel(50, 50) == "none", "Should be none at high karma")

    -- Restricted: karma 10-40, fame 25+
    suite:assert(bm:getAccessLevel(20, 30) == "restricted", "Should be restricted")

    -- Standard: karma -39 to 9, fame 25+
    suite:assert(bm:getAccessLevel(-20, 40) == "standard", "Should be standard")

    -- Enhanced: karma -74 to -40, fame 60+
    suite:assert(bm:getAccessLevel(-60, 70) == "enhanced", "Should be enhanced")

    -- Complete: karma -100 to -75, fame 75+
    suite:assert(bm:getAccessLevel(-90, 80) == "complete", "Should be complete")
end)

suite:testMethod("BlackMarketSystem.canAccessService", {
    description = "Checks if player can access specific services",
    testCase = "service_access",
    type = "functional"
}, function()
    local bm = BlackMarketSystem.new()

    -- Restricted level: only items and corpses
    local canItems = bm:canAccessService("items", 20, 30)
    suite:assert(canItems == true, "Should access items at restricted")

    local canUnits = bm:canAccessService("units", 20, 30)
    suite:assert(canUnits == false, "Should not access units at restricted")

    -- Standard level: items, corpses, units, missions
    local canMissions = bm:canAccessService("missions", -20, 40)
    suite:assert(canMissions == true, "Should access missions at standard")

    local canEvents = bm:canAccessService("events", -20, 40)
    suite:assert(canEvents == false, "Should not access events at standard")

    -- Enhanced level: all except extreme
    local canCraft = bm:canAccessService("craft", -60, 70)
    suite:assert(canCraft == true, "Should access craft at enhanced")

    -- Complete level: everything
    local canExtreme = bm:canAccessService("extreme_operations", -90, 80)
    suite:assert(canExtreme == true, "Should access extreme at complete")
end)

suite:testMethod("BlackMarketSystem.getAvailableServices", {
    description = "Lists available services for access level",
    testCase = "available_services",
    type = "functional"
}, function()
    local bm = BlackMarketSystem.new()

    -- Restricted: 2 services
    local restricted = bm:getAvailableServices(20, 30)
    suite:assert(#restricted == 2, "Should have 2 services at restricted")

    -- Standard: 4 services
    local standard = bm:getAvailableServices(-20, 40)
    suite:assert(#standard == 4, "Should have 4 services at standard")

    -- Enhanced: 6 services
    local enhanced = bm:getAvailableServices(-60, 70)
    suite:assert(#enhanced == 6, "Should have 6 services at enhanced")

    -- Complete: 7 services
    local complete = bm:getAvailableServices(-90, 80)
    suite:assert(#complete == 7, "Should have 7 services at complete")
end)

-- Discovery Risk Tests
suite:testMethod("BlackMarketSystem.getCumulativeDiscoveryRisk", {
    description = "Discovery risk increases with transaction count",
    testCase = "cumulative_risk",
    type = "functional"
}, function()
    local bm = BlackMarketSystem.new()

    -- Low transactions: base risk
    suite:assert(bm:getCumulativeDiscoveryRisk() == 0.05, "Base risk should be 5%")

    -- Simulate 10 purchases
    for i = 1, 10 do
        table.insert(bm.purchaseHistory, {entryId = "test_" .. i, timestamp = os.time()})
    end
    suite:assert(bm:getCumulativeDiscoveryRisk() == 0.10, "Risk should be 10% at 10 purchases")

    -- Simulate 25 purchases
    for i = 11, 25 do
        table.insert(bm.purchaseHistory, {entryId = "test_" .. i, timestamp = os.time()})
    end
    suite:assert(bm:getCumulativeDiscoveryRisk() == 0.15, "Risk should be 15% at 25 purchases")

    -- Simulate 35 purchases
    for i = 26, 35 do
        table.insert(bm.purchaseHistory, {entryId = "test_" .. i, timestamp = os.time()})
    end
    suite:assert(bm:getCumulativeDiscoveryRisk() == 0.20, "Risk should be 20% at 35+ purchases")
end)

-- Status Summary Test
suite:testMethod("BlackMarketSystem.getStatusSummary", {
    description = "Returns comprehensive status summary",
    testCase = "status_summary",
    type = "functional"
}, function()
    local bm = BlackMarketSystem.new()

    local summary = bm:getStatusSummary(-60, 70)

    suite:assert(summary.access_level == "enhanced", "Should report enhanced access")
    suite:assert(#summary.available_services == 6, "Should report 6 services")
    suite:assert(summary.transaction_count >= 0, "Should report transaction count")
    suite:assert(summary.discovery_risk >= 0, "Should report discovery risk")
    suite:assert(summary.market_level ~= nil, "Should report market level")
end)

return suite

