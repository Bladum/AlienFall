--- Phase 7 Campaign-Geoscape Integration Tests
-- Comprehensive tests for mission data flow, selection, deployment, and transitions
-- Tests the complete flow: Mission Loading → Selection → Deployment → Transition
--
-- Run with: lovec tests/geoscape
-- @module test_phase7_campaign_integration
-- @author AlienFall Team

local test_summary = {total = 0, passed = 0, failed = 0}

-- Mock dependencies
local MockCampaignManager = {}
function MockCampaignManager:new()
    return {
        missions = {
            {id = "M1", name = "Destroy Base", threat_level = 7, turns_remaining = 5},
            {id = "M2", name = "Rescue Team", threat_level = 4, turns_remaining = 3},
        },
        bases = {
            {id = "B1", units = {
                {id = "U1", name = "Soldier", status = "READY"},
                {id = "U2", name = "Medic", status = "READY"},
            }, crafts = {
                {id = "C1", name = "Skyranger", fuel = 100, max_fuel = 100},
            }}
        },
        ufos = {
            {id = "UFO1", name = "Scout", position = {x = 10, y = 10}},
        },
        getActiveMissions = function(self) return self.missions end,
        getPlayerBases = function(self) return self.bases end,
        getDetectedUFOs = function(self) return self.ufos end,
        startMission = function(self, id) return true end,
        getMission = function(self, id)
            for _, m in ipairs(self.missions) do
                if m.id == id then return m end
            end
            return nil
        end,
        declineMission = function(self, id) return true end,
        completeMission = function(self, id, outcome) return true end,
    }
end

--- Test 1: Integration module initialization
local function test_integration_init()
    print("\n[TEST 1] Integration module initialization")

    local CampaignGeoscapeIntegration = require("engine.geoscape.campaign_geoscape_integration")
    local integration = CampaignGeoscapeIntegration:initialize(
        MockCampaignManager:new(),
        {}, -- geoscape_state mock
        {getTurnNumber = function() return 1 end}, -- calendar mock
        {}  -- turn_advancer mock
    )

    assert(integration, "Integration module initialized")
    assert(integration.campaign_manager, "Campaign manager attached")
    print("✓ Integration module initialized successfully")
    test_summary.passed = test_summary.passed + 1
end

--- Test 2: Load active missions from campaign
local function test_load_missions()
    print("\n[TEST 2] Load active missions from campaign")

    local CampaignGeoscapeIntegration = require("engine.geoscape.campaign_geoscape_integration")
    local integration = CampaignGeoscapeIntegration:initialize(
        MockCampaignManager:new(),
        {}, {getTurnNumber = function() return 1 end}, {}
    )

    local missions = integration:loadActiveMissions()

    assert(missions, "Missions loaded")
    assert(#missions == 2, "Correct number of missions")
    assert(missions[1].name == "Destroy Base", "Mission name correct")
    assert(missions[1].threat_level == 7, "Threat level correct")
    print("✓ Active missions loaded successfully")
    test_summary.passed = test_summary.passed + 1
end

--- Test 3: Load player crafts
local function test_load_crafts()
    print("\n[TEST 3] Load player crafts from bases")

    local CampaignGeoscapeIntegration = require("engine.geoscape.campaign_geoscape_integration")
    local integration = CampaignGeoscapeIntegration:initialize(
        MockCampaignManager:new(),
        {}, {getTurnNumber = function() return 1 end}, {}
    )

    local crafts = integration:loadPlayerCrafts()

    assert(crafts, "Crafts loaded")
    assert(#crafts == 1, "Correct number of crafts")
    assert(crafts[1].name == "Skyranger", "Craft name correct")
    print("✓ Player crafts loaded successfully")
    test_summary.passed = test_summary.passed + 1
end

--- Test 4: Load detected UFOs
local function test_load_ufos()
    print("\n[TEST 4] Load detected UFOs")

    local CampaignGeoscapeIntegration = require("engine.geoscape.campaign_geoscape_integration")
    local integration = CampaignGeoscapeIntegration:initialize(
        MockCampaignManager:new(),
        {}, {getTurnNumber = function() return 1 end}, {}
    )

    local ufos = integration:loadDetectedUFOs()

    assert(ufos, "UFOs loaded")
    assert(#ufos == 1, "Correct number of UFOs")
    assert(ufos[1].name == "Scout", "UFO name correct")
    print("✓ Detected UFOs loaded successfully")
    test_summary.passed = test_summary.passed + 1
end

--- Test 5: Mission selection and acceptance
local function test_mission_selection()
    print("\n[TEST 5] Mission selection and acceptance")

    local CampaignGeoscapeIntegration = require("engine.geoscape.campaign_geoscape_integration")
    local integration = CampaignGeoscapeIntegration:initialize(
        MockCampaignManager:new(),
        {}, {getTurnNumber = function() return 1 end}, {}
    )

    local success = integration:acceptMission("M1")

    assert(success, "Mission accepted")
    print("✓ Mission selection and acceptance working")
    test_summary.passed = test_summary.passed + 1
end

--- Test 6: Mission decline
local function test_mission_decline()
    print("\n[TEST 6] Mission decline")

    local CampaignGeoscapeIntegration = require("engine.geoscape.campaign_geoscape_integration")
    local integration = CampaignGeoscapeIntegration:initialize(
        MockCampaignManager:new(),
        {}, {getTurnNumber = function() return 1 end}, {}
    )

    local success = integration:declineMission("M1")

    assert(success, "Mission declined")
    print("✓ Mission decline working")
    test_summary.passed = test_summary.passed + 1
end

--- Test 7: Deployment integration initialization
local function test_deployment_init()
    print("\n[TEST 7] Deployment integration initialization")

    local DeploymentIntegration = require("engine.geoscape.deployment_integration")
    local deployment = DeploymentIntegration:initialize(
        MockCampaignManager:new(),
        {} -- integration mock
    )

    assert(deployment, "Deployment module initialized")
    assert(deployment.campaign_manager, "Campaign manager attached")
    print("✓ Deployment integration initialized successfully")
    test_summary.passed = test_summary.passed + 1
end

--- Test 8: Load available units for deployment
local function test_load_available_units()
    print("\n[TEST 8] Load available units for deployment")

    local DeploymentIntegration = require("engine.geoscape.deployment_integration")
    local deployment = DeploymentIntegration:initialize(
        MockCampaignManager:new(),
        {}
    )

    local units = deployment:getAvailableUnits()

    assert(units, "Units loaded")
    assert(#units == 2, "Correct number of units")
    assert(units[1].name == "Soldier", "Unit name correct")
    print("✓ Available units loaded successfully")
    test_summary.passed = test_summary.passed + 1
end

--- Test 9: Unit selection for squad
local function test_unit_selection()
    print("\n[TEST 9] Unit selection for squad")

    local DeploymentIntegration = require("engine.geoscape.deployment_integration")
    local deployment = DeploymentIntegration:initialize(
        MockCampaignManager:new(),
        {}
    )

    local success = deployment:selectUnit("U1")
    assert(success, "Unit selected")

    local squad = deployment:getSelectedSquad()
    assert(#squad == 1, "Squad size correct")
    assert(squad[1] == "U1", "Correct unit in squad")
    print("✓ Unit selection working")
    test_summary.passed = test_summary.passed + 1
end

--- Test 10: Squad capacity validation
local function test_squad_capacity()
    print("\n[TEST 10] Squad capacity validation")

    local DeploymentIntegration = require("engine.geoscape.deployment_integration")
    local deployment = DeploymentIntegration:initialize(
        MockCampaignManager:new(),
        {}
    )

    -- Select first unit
    deployment:selectUnit("U1")

    -- Check capacity
    local capacity = deployment:getSquadCapacity()
    assert(capacity.current == 1, "Current capacity correct")
    assert(capacity.max == 12, "Max capacity correct")
    print("✓ Squad capacity tracking working")
    test_summary.passed = test_summary.passed + 1
end

--- Test 11: Craft selection
local function test_craft_selection()
    print("\n[TEST 11] Craft selection for mission")

    local DeploymentIntegration = require("engine.geoscape.deployment_integration")
    local deployment = DeploymentIntegration:initialize(
        MockCampaignManager:new(),
        {}
    )

    local success = deployment:selectCraft("C1")
    assert(success, "Craft selected")

    local craft = deployment:getSelectedCraft()
    assert(craft == "C1", "Correct craft selected")
    print("✓ Craft selection working")
    test_summary.passed = test_summary.passed + 1
end

--- Test 12: Deployment validation
local function test_deployment_validation()
    print("\n[TEST 12] Deployment validation")

    local DeploymentIntegration = require("engine.geoscape.deployment_integration")
    local deployment = DeploymentIntegration:initialize(
        MockCampaignManager:new(),
        {}
    )

    -- Empty squad should fail
    local is_valid, error_msg = deployment:validateDeployment()
    assert(not is_valid, "Empty squad fails validation")

    -- Add unit and craft
    deployment:selectUnit("U1")
    deployment:selectCraft("C1")

    -- Still no mission
    is_valid, error_msg = deployment:validateDeployment()
    assert(not is_valid, "No mission fails validation")
    print("✓ Deployment validation working")
    test_summary.passed = test_summary.passed + 1
end

--- Test 13: Mission handler initialization
local function test_mission_handler_init()
    print("\n[TEST 13] Mission handler initialization")

    local MissionHandler = require("engine.geoscape.ui.geoscape_mission_handler")
    local handler = MissionHandler:initialize({}, {})

    assert(handler, "Mission handler initialized")
    assert(not handler.is_visible, "Handler not visible initially")
    print("✓ Mission handler initialized successfully")
    test_summary.passed = test_summary.passed + 1
end

--- Test 14: Transition system initialization
local function test_transition_init()
    print("\n[TEST 14] Transition system initialization")

    local Transition = require("engine.geoscape.geoscape_battlescape_transition")
    local transition = Transition:initialize({}, {})

    assert(transition, "Transition module initialized")
    assert(not transition:isMissionActive(), "No mission active initially")
    print("✓ Transition system initialized successfully")
    test_summary.passed = test_summary.passed + 1
end

--- Test 15: Campaign data serialization
local function test_serialization()
    print("\n[TEST 15] Campaign integration data serialization")

    local CampaignGeoscapeIntegration = require("engine.geoscape.campaign_geoscape_integration")
    local integration = CampaignGeoscapeIntegration:initialize(
        MockCampaignManager:new(),
        {}, {getTurnNumber = function() return 1 end}, {}
    )

    integration:acceptMission("M1")

    local serialized = integration:serialize()
    assert(serialized, "Data serialized")
    assert(serialized.selected_mission_id == "M1", "Mission ID preserved")

    local integration2 = CampaignGeoscapeIntegration:initialize(
        MockCampaignManager:new(),
        {}, {getTurnNumber = function() return 1 end}, {}
    )
    integration2:deserialize(serialized)

    assert(integration2.selected_mission_id == "M1", "Mission ID restored")
    print("✓ Serialization working correctly")
    test_summary.passed = test_summary.passed + 1
end

--- Test 16: Integration test - Full mission to deployment flow
local function test_full_flow()
    print("\n[TEST 16] Full mission to deployment flow")

    local CampaignGeoscapeIntegration = require("engine.geoscape.campaign_geoscape_integration")
    local integration = CampaignGeoscapeIntegration:initialize(
        MockCampaignManager:new(),
        {}, {getTurnNumber = function() return 1 end}, {}
    )

    local DeploymentIntegration = require("engine.geoscape.deployment_integration")
    local deployment = DeploymentIntegration:initialize(
        MockCampaignManager:new(),
        integration
    )

    -- Load and select mission
    local missions = integration:loadActiveMissions()
    assert(#missions > 0, "Missions available")

    integration:acceptMission(missions[1].id)

    -- Load and select units
    local units = deployment:getAvailableUnits()
    deployment:selectUnit(units[1].id)

    -- Load and select craft
    local crafts = deployment:getAvailableCrafts()
    if #crafts > 0 then
        deployment:selectCraft(crafts[1].id)
    end

    print("✓ Full mission to deployment flow completed")
    test_summary.passed = test_summary.passed + 1
end

--- Test 17: Performance test - Mission loading performance
local function test_performance_mission_loading()
    print("\n[TEST 17] Performance test - Mission loading")

    local CampaignGeoscapeIntegration = require("engine.geoscape.campaign_geoscape_integration")

    local start_time = os.clock()

    for i = 1, 10 do
        local integration = CampaignGeoscapeIntegration:initialize(
            MockCampaignManager:new(),
            {}, {getTurnNumber = function() return 1 end}, {}
        )
        integration:loadActiveMissions()
    end

    local elapsed = (os.clock() - start_time) * 1000  -- Convert to ms

    print("   Load time (10 iterations): " .. string.format("%.2f", elapsed) .. " ms")
    assert(elapsed < 100, "Mission loading performance acceptable")
    print("✓ Performance test passed")
    test_summary.passed = test_summary.passed + 1
end

--- Run all tests
function runAllTests()
    print("====================================")
    print("PHASE 7 CAMPAIGN INTEGRATION TESTS")
    print("====================================")

    local tests = {
        test_integration_init,
        test_load_missions,
        test_load_crafts,
        test_load_ufos,
        test_mission_selection,
        test_mission_decline,
        test_deployment_init,
        test_load_available_units,
        test_unit_selection,
        test_squad_capacity,
        test_craft_selection,
        test_deployment_validation,
        test_mission_handler_init,
        test_transition_init,
        test_serialization,
        test_full_flow,
        test_performance_mission_loading,
    }

    for _, test in ipairs(tests) do
        test_summary.total = test_summary.total + 1
        local success, error = pcall(test)
        if not success then
            print("✗ TEST FAILED: " .. error)
            test_summary.failed = test_summary.failed + 1
        end
    end

    print("\n====================================")
    print("TEST SUMMARY")
    print("====================================")
    print("Total:  " .. test_summary.total)
    print("Passed: " .. test_summary.passed)
    print("Failed: " .. test_summary.failed)

    if test_summary.failed == 0 then
        print("\n✓ ALL TESTS PASSED!")
    else
        print("\n✗ Some tests failed")
    end

    return test_summary.failed == 0
end

-- Export for external testing
return {
    runAllTests = runAllTests,
    test_summary = test_summary,
}
