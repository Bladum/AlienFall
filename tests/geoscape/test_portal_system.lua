---Test Suite: Portal/Multi-World System
---
---Comprehensive tests for portal mechanics, multi-world travel, and related features.
---Tests portal creation, discovery, activation, and cross-world travel.
---

local TEST_API = require("tests.TEST_API_FOR_AI")
local PortalSystem = require("engine.geoscape.systems.portal_system")

local testSuite = {}

--- Test 1: Portal System Initialization
function testSuite.test_portal_system_init()
    local portals = PortalSystem.new()
    
    TEST_API.assertEqual(portals ~= nil, true, "Portal system created")
    TEST_API.assertEqual(#portals.portals, 0, "No portals initially")
    TEST_API.assertEqual(#portals.activeTransits, 0, "No active transits initially")
    
    print("[TEST] Portal system initialization: PASS")
    return true
end

--- Test 2: Portal Creation
function testSuite.test_portal_creation()
    local portals = PortalSystem.new()
    
    local worldA = { id = "world_a", width = 90, height = 45 }
    local worldB = { id = "world_b", width = 90, height = 45 }
    
    local portal, err = portals:createPortal(45, 23, worldA, worldB, "stable")
    
    TEST_API.assertEqual(portal ~= nil, true, "Portal created successfully")
    TEST_API.assertEqual(err, nil, "No error on creation")
    if portal then
        TEST_API.assertEqual(portal.type, "stable", "Portal type is stable")
        TEST_API.assertEqual(portal.world, "world_a", "Portal world is correct")
        TEST_API.assertEqual(portal.destinationWorld, "world_b", "Destination world correct")
        TEST_API.assertEqual(portal.discovered, false, "Portal not discovered initially")
        TEST_API.assertEqual(portal.activated, false, "Portal not activated initially")
    end
    
    print("[TEST] Portal creation: PASS")
    return true
end

--- Test 3: Portal Types (Stable, Unstable, Temporary)
function testSuite.test_portal_types()
    local portals = PortalSystem.new()
    
    local worldA = { id = "world_a", width = 90, height = 45 }
    local worldB = { id = "world_b", width = 90, height = 45 }
    
    -- Stable portal
    local stable = portals:createPortal(10, 10, worldA, worldB, "stable")
    if stable then
        TEST_API.assertEqual(stable.stability, 0, "Stable portal: 0% failure")
        TEST_API.assertEqual(stable.energyCost, 1000, "Stable portal: 1000 energy cost")
        TEST_API.assertEqual(stable.travelTime, 2, "Stable portal: 2 days travel")
    end
    
    -- Unstable portal
    local unstable = portals:createPortal(20, 20, worldA, worldB, "unstable")
    if unstable then
        TEST_API.assertEqual(unstable.stability, 0.20, "Unstable portal: 20% failure")
        TEST_API.assertEqual(unstable.energyCost, 800, "Unstable portal: 800 energy cost")
        TEST_API.assertEqual(unstable.travelTime, 3, "Unstable portal: 3 days travel")
    end
    
    -- Temporary portal
    local temp = portals:createPortal(30, 30, worldA, worldB, "temporary")
    if temp then
        TEST_API.assertEqual(temp.isTemporary, true, "Temporary portal flag set")
        TEST_API.assertEqual(temp.energyCost, 500, "Temporary portal: 500 energy cost")
        TEST_API.assertEqual(temp.travelTime, 1, "Temporary portal: 1 day travel")
    end
    
    print("[TEST] Portal types: PASS")
    return true
end

--- Test 4: Invalid Portal Creation
function testSuite.test_invalid_portal_creation()
    local portals = PortalSystem.new()
    
    local worldA = { id = "world_a", width = 90, height = 45 }
    local worldB = { id = "world_b", width = 90, height = 45 }
    
    -- Invalid type
    local portal, err = portals:createPortal(10, 10, worldA, worldB, "invalid_type")
    TEST_API.assertEqual(portal, nil, "Portal creation fails with invalid type")
    TEST_API.assertNotEqual(err, nil, "Error message provided")
    
    -- Missing world
    local portal2, err2 = portals:createPortal(10, 10, nil, worldB, "stable")
    TEST_API.assertEqual(portal2, nil, "Portal creation fails without origin world")
    
    print("[TEST] Invalid portal creation: PASS")
    return true
end

--- Test 5: Portal Discovery
function testSuite.test_portal_discovery()
    local portals = PortalSystem.new()
    
    local worldA = { id = "world_a", width = 90, height = 45 }
    local worldB = { id = "world_b", width = 90, height = 45 }
    
    local portal = portals:createPortal(45, 23, worldA, worldB, "stable")
    
    if portal then
        TEST_API.assertEqual(portal.discovered, false, "Portal not discovered initially")
        
        local gameState = { research = { addBonus = function() end } }
        portals:discoverPortal(portal, gameState)
        
        TEST_API.assertEqual(portal.discovered, true, "Portal discovered after call")
        TEST_API.assertEqual(portal.visible, true, "Portal visible after discovery")
    end
    
    print("[TEST] Portal discovery: PASS")
    return true
end

--- Test 6: Portal Activation (Success)
function testSuite.test_portal_activation_success()
    local portals = PortalSystem.new()
    
    local worldA = { id = "world_a", width = 90, height = 45 }
    local worldB = { id = "world_b", width = 90, height = 45 }
    
    local portal = portals:createPortal(45, 23, worldA, worldB, "stable")
    
    local gameState = {
        research = { 
            hasDimensionalTech = true,
            addBonus = function() end
        },
        economy = {
            credits = 5000,
            hasCredits = function(self, cost) return self.credits >= cost end,
            spendCredits = function(self, cost) self.credits = self.credits - cost end
        }
    }
    
    -- Discover first
    portals:discoverPortal(portal, gameState)
    
    -- Then activate
    local ok, msg = portals:activatePortal(portal, gameState)
    
    TEST_API.assertEqual(ok, true, "Portal activation succeeded")
    if portal then
        TEST_API.assertEqual(portal.activated, true, "Portal is activated")
    end
    TEST_API.assertEqual(gameState.economy.credits, 4000, "Energy cost deducted correctly")
    
    print("[TEST] Portal activation (success): PASS")
    return true
end

--- Test 7: Portal Activation (Prerequisites)
function testSuite.test_portal_activation_prerequisites()
    local portals = PortalSystem.new()
    
    local worldA = { id = "world_a", width = 90, height = 45 }
    local worldB = { id = "world_b", width = 90, height = 45 }
    
    local portal = portals:createPortal(45, 23, worldA, worldB, "stable")
    
    -- Game state missing dimensional tech
    local gameState = {
        research = { hasDimensionalTech = false },
        economy = { credits = 5000 }
    }
    
    portals:discoverPortal(portal, gameState)
    
    local ok, msg = portals:activatePortal(portal, gameState)
    
    TEST_API.assertEqual(ok, false, "Activation fails without tech")
    TEST_API.assertNotEqual(msg:find("Dimensional"), nil, "Error message mentions tech")
    
    print("[TEST] Portal activation (prerequisites): PASS")
    return true
end

--- Test 8: Portal Transit (Success)
function testSuite.test_portal_transit_success()
    local portals = PortalSystem.new()
    
    local worldA = { id = "world_a", width = 90, height = 45 }
    local worldB = { id = "world_b", width = 90, height = 45 }
    
    local portal = portals:createPortal(45, 23, worldA, worldB, "stable")
    
    local craft = {
        id = "craft_1",
        fuel = 100,
        armor = 50
    }
    
    local gameState = {
        research = { hasDimensionalTech = true },
        economy = { credits = 5000 }
    }
    
    -- Setup
    portals:discoverPortal(portal, gameState)
    portals:activatePortal(portal, gameState)
    
    -- Transit
    local callbackCalled = false
    local callbackResult = nil
    
    local ok, msg = portals:travelThroughPortal(craft, portal, gameState, function(success, result)
        callbackCalled = true
        callbackResult = result
    end)
    
    TEST_API.assertEqual(ok, true, "Transit initiated successfully")
    TEST_API.assertEqual(callbackCalled, true, "Callback was called")
    if callbackResult then
        TEST_API.assertEqual(callbackResult.status, "transit_started", "Transit status correct")
    end
    TEST_API.assertEqual(craft.fuel, 80, "Fuel consumed (20 units)")
    TEST_API.assertEqual(#portals.activeTransits, 1, "Transit recorded as active")
    
    print("[TEST] Portal transit (success): PASS")
    return true
end

--- Test 9: Portal Transit (Insufficient Resources)
function testSuite.test_portal_transit_insufficient()
    local portals = PortalSystem.new()
    
    local worldA = { id = "world_a", width = 90, height = 45 }
    local worldB = { id = "world_b", width = 90, height = 45 }
    
    local portal = portals:createPortal(45, 23, worldA, worldB, "stable")
    
    local craft = {
        id = "craft_1",
        fuel = 5,  -- Not enough (needs 20)
        armor = 50
    }
    
    local gameState = {
        research = { hasDimensionalTech = true },
        economy = { credits = 5000 }
    }
    
    portals:discoverPortal(portal, gameState)
    portals:activatePortal(portal, gameState)
    
    local ok, msg = portals:travelThroughPortal(craft, portal, gameState, nil)
    
    TEST_API.assertEqual(ok, false, "Transit fails with insufficient fuel")
    TEST_API.assertNotEqual(msg:find("fuel"), nil, "Error mentions fuel", true)
    
    print("[TEST] Portal transit (insufficient resources): PASS")
    return true
end

--- Test 10: Temporary Portal One-Time Use
function testSuite.test_temporary_portal_one_time()
    local portals = PortalSystem.new()
    
    local worldA = { id = "world_a", width = 90, height = 45 }
    local worldB = { id = "world_b", width = 90, height = 45 }
    
    local portal = portals:createPortal(45, 23, worldA, worldB, "temporary")
    
    local craft = {
        id = "craft_1",
        fuel = 100,
        armor = 50
    }
    
    local gameState = {
        research = { hasDimensionalTech = true },
        economy = { credits = 5000 }
    }
    
    portals:discoverPortal(portal, gameState)
    portals:activatePortal(portal, gameState)
    
    -- First use - should succeed
    local ok1 = portals:travelThroughPortal(craft, portal, gameState, nil)
    TEST_API.assertEqual(ok1, true, "First use succeeds")
    if portal then
        TEST_API.assertEqual(portal.isUsed, true, "Portal marked as used")
    end
    
    -- Second use - should fail
    craft.fuel = 100  -- Reset fuel
    local ok2 = portals:travelThroughPortal(craft, portal, gameState, nil)
    TEST_API.assertEqual(ok2, false, "Second use fails")
    
    print("[TEST] Temporary portal (one-time use): PASS")
    return true
end

--- Test 11: Get Discovered Portals
function testSuite.test_get_discovered_portals()
    local portals = PortalSystem.new()
    
    local worldA = { id = "world_a", width = 90, height = 45 }
    local worldB = { id = "world_b", width = 90, height = 45 }
    
    -- Create multiple portals
    local p1 = portals:createPortal(10, 10, worldA, worldB, "stable")
    local p2 = portals:createPortal(20, 20, worldA, worldB, "unstable")
    local p3 = portals:createPortal(30, 30, worldB, worldA, "temporary")
    
    -- Discover some
    portals:discoverPortal(p1, {})
    portals:discoverPortal(p3, {})
    
    local gameState = { research = { addBonus = function() end } }
    
    -- Get discovered in world A
    local worldA_portals = portals:getDiscoveredPortals(worldA)
    TEST_API.assertEqual(#worldA_portals, 1, "World A has 1 discovered portal")
    
    -- Get discovered in world B
    local worldB_portals = portals:getDiscoveredPortals(worldB)
    TEST_API.assertEqual(#worldB_portals, 1, "World B has 1 discovered portal")
    
    print("[TEST] Get discovered portals: PASS")
    return true
end

--- Test 12: Transit Completion
function testSuite.test_transit_completion()
    local portals = PortalSystem.new()
    
    local worldA = { id = "world_a", width = 90, height = 45 }
    local worldB = { id = "world_b", width = 90, height = 45 }
    
    local portal = portals:createPortal(45, 23, worldA, worldB, "stable")
    
    local craft = {
        id = "craft_1",
        fuel = 100,
        armor = 50
    }
    
    local gameState = {
        research = { hasDimensionalTech = true },
        economy = { credits = 5000 }
    }
    
    portals:discoverPortal(portal, gameState)
    portals:activatePortal(portal, gameState)
    portals:travelThroughPortal(craft, portal, gameState, nil)
    
    TEST_API.assertEqual(#portals.activeTransits, 1, "Transit active")
    
    -- Update for 2 days
    local completed1 = portals:updateTransits()
    TEST_API.assertEqual(#completed1, 0, "Transit not complete after 1 update")
    TEST_API.assertEqual(#portals.activeTransits, 1, "Transit still active")
    
    local completed2 = portals:updateTransits()
    TEST_API.assertEqual(#completed2, 1, "Transit complete after 2 updates")
    TEST_API.assertEqual(#portals.activeTransits, 0, "No active transits")
    
    print("[TEST] Transit completion: PASS")
    return true
end

--- Test 13: World Network Map
function testSuite.test_world_network_map()
    local portals = PortalSystem.new()
    
    local worldA = { id = "world_a", width = 90, height = 45 }
    local worldB = { id = "world_b", width = 90, height = 45 }
    local worldC = { id = "world_c", width = 90, height = 45 }
    
    local p1 = portals:createPortal(10, 10, worldA, worldB, "stable")
    local p2 = portals:createPortal(20, 20, worldB, worldC, "stable")
    
    portals:discoverPortal(p1, {})
    portals:discoverPortal(p2, {})
    
    local network = portals:getWorldNetwork()
    
    TEST_API.assertEqual(network.world_a ~= nil, true, "World A in network")
    TEST_API.assertEqual(network.world_b ~= nil, true, "World B in network")
    TEST_API.assertEqual(network.world_c, nil, "World C not connected (no outgoing)")
    TEST_API.assertEqual(#network.world_a, 1, "World A has 1 outgoing connection")
    TEST_API.assertEqual(#network.world_b, 1, "World B has 1 outgoing connection")
    
    print("[TEST] World network map: PASS")
    return true
end

--- Test 14: Portal Statistics
function testSuite.test_portal_statistics()
    local portals = PortalSystem.new()
    
    local worldA = { id = "world_a", width = 90, height = 45 }
    local worldB = { id = "world_b", width = 90, height = 45 }
    
    local p1 = portals:createPortal(10, 10, worldA, worldB, "stable")
    local p2 = portals:createPortal(20, 20, worldA, worldB, "unstable")
    
    portals:discoverPortal(p1, {})
    
    local gameState = {
        research = { hasDimensionalTech = true },
        economy = { credits = 5000 }
    }
    
    portals:activatePortal(p1, gameState)
    
    local stats = portals:getStats()
    
    TEST_API.assertEqual(stats.totalPortals, 2, "Total portals: 2")
    TEST_API.assertEqual(stats.discovered, 1, "Discovered: 1")
    TEST_API.assertEqual(stats.activated, 1, "Activated: 1")
    TEST_API.assertEqual(stats.completed, 0, "Completed transits: 0")
    TEST_API.assertEqual(stats.activeTransits, 0, "Active transits: 0")
    
    print("[TEST] Portal statistics: PASS")
    return true
end

--- Test 15: Portal Information
function testSuite.test_portal_information()
    local portals = PortalSystem.new()
    
    local worldA = { id = "world_a", width = 90, height = 45 }
    local worldB = { id = "world_b", width = 90, height = 45 }
    
    local portal = portals:createPortal(45, 23, worldA, worldB, "stable")
    
    local info = portals:getPortalInfo(portal)
    
    if info and portal then
        TEST_API.assertEqual(info.id, portal.id, "Info ID matches")
        TEST_API.assertEqual(info.type, "stable", "Info type matches")
        TEST_API.assertEqual(info.discovered, false, "Info discovered correct")
        TEST_API.assertEqual(info.energyCost, 1000, "Info energy cost correct")
        TEST_API.assertEqual(info.travelTime, 2, "Info travel time correct")
    end
    
    print("[TEST] Portal information: PASS")
    return true
end

--- Run all tests
function testSuite.runAll()
    print("\n" .. string.rep("=", 60))
    print("TEST SUITE: Portal/Multi-World System")
    print(string.rep("=", 60) .. "\n")
    
    local tests = {
        testSuite.test_portal_system_init,
        testSuite.test_portal_creation,
        testSuite.test_portal_types,
        testSuite.test_invalid_portal_creation,
        testSuite.test_portal_discovery,
        testSuite.test_portal_activation_success,
        testSuite.test_portal_activation_prerequisites,
        testSuite.test_portal_transit_success,
        testSuite.test_portal_transit_insufficient,
        testSuite.test_temporary_portal_one_time,
        testSuite.test_get_discovered_portals,
        testSuite.test_transit_completion,
        testSuite.test_world_network_map,
        testSuite.test_portal_statistics,
        testSuite.test_portal_information
    }
    
    local passed = 0
    local failed = 0
    
    for _, test in ipairs(tests) do
        local ok, err = pcall(test)
        if ok then
            passed = passed + 1
        else
            failed = failed + 1
            print("[FAILED] " .. (err or "Unknown error"))
        end
    end
    
    print("\n" .. string.rep("=", 60))
    print(string.format("RESULTS: %d passed, %d failed (total: %d)", passed, failed, passed + failed))
    print(string.rep("=", 60) .. "\n")
    
    return failed == 0
end

return testSuite



