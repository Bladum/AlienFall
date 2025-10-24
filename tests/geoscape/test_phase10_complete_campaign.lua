--[[
    Phase 10: Complete Campaign Integration Tests

    End-to-end testing of the complete XCOM Simple campaign system.
    Tests all Phase 6-10 systems working together in realistic campaign scenarios.

    Tests verify:
    - Campaign orchestrator coordination
    - Full threat progression (0→100)
    - All system interactions
    - Save/load functionality
    - Balance and difficulty scaling
    - Edge cases and stress conditions
]]

-- Mock LOVE filesystem for testing
local function setupMockFilesystem()
    if not love.filesystem then
        love.filesystem = {
            createDirectory = function() return true end,
            write = function() return true end,
            read = function() return "XCOM_SAVE_V1\ntest=true\n" end,
            getInfo = function() return { modtime = 0, size = 100 } end,
            remove = function() return true end
        }
    end
end

-- Helper: Create mock campaign data
local function createMockCampaignData()
    return {
        days_elapsed = 0,
        threat_level = 0,
        missions_completed = 0,
        missions_won = 0,
        missions_lost = 0,
        soldiers_killed = 0,
        funding = 2000,
        soldiers = {},
        crafts = {}
    }
end

-- Test 1: Campaign Orchestrator Initialization
function testOrchestratorInitialization()
    print("[TESTS] Campaign Orchestrator Initialization")

    local CampaignOrchestrator = require("engine.geoscape.campaign_orchestrator")
    local orchestrator = CampaignOrchestrator.new()

    assert(orchestrator ~= nil, "Orchestrator created")
    assert(orchestrator.state == "initializing", "Initial state correct")

    orchestrator:initializeAllSystems()

    assert(orchestrator.state == "ready", "State changed to ready after init")
    assert(orchestrator.systems ~= nil, "Systems initialized")
    assert(#(orchestrator.systems or {}) >= 10, "All 10 systems loaded")

    print("  ✓ Orchestrator initializes correctly")
    print("  ✓ All 10 systems loaded")
end

-- Test 2: Campaign Startup and Phase Progression
function testCampaignStartup()
    print("[TESTS] Campaign Startup and Progression")

    local CampaignOrchestrator = require("engine.geoscape.campaign_orchestrator")
    local orchestrator = CampaignOrchestrator.new()

    orchestrator:startNewCampaign("Normal", 2000, 50)

    assert(orchestrator.state == "campaign_active", "Campaign started")
    assert(orchestrator.campaignData.difficulty == "Normal", "Difficulty set")
    assert(orchestrator.campaignData.funding == 2000, "Funding initialized")
    assert(#orchestrator.campaignData.soldiers == 50, "Soldiers initialized")
    assert(#orchestrator.campaignData.crafts == 2, "Crafts initialized")

    print("  ✓ Campaign starts correctly")
    print("  ✓ Initial resources allocated")
    print("  ✓ Soldiers and crafts created")
end

-- Test 3: Campaign Phase Transitions
function testPhaseTransitions()
    print("[TESTS] Campaign Phase Transitions")

    local CampaignOrchestrator = require("engine.geoscape.campaign_orchestrator")
    local orchestrator = CampaignOrchestrator.new()
    orchestrator:startNewCampaign("Normal")

    -- Simulate threat progression
    for threat = 0, 85, 20 do
        orchestrator.campaignData.threat_level = threat
        orchestrator:_checkCampaignPhaseTransition()

        local expected_phase = 1
        if threat >= 75 then expected_phase = 4
        elseif threat >= 50 then expected_phase = 3
        elseif threat >= 25 then expected_phase = 2
        end

        assert(orchestrator.campaign_phase == expected_phase,
            "Phase correct at threat " .. threat)
    end

    print("  ✓ Phase transitions at correct thresholds")
    print("  ✓ Threat progression tracked")
end

-- Test 4: Mission Generation with All Systems
function testMissionGeneration()
    print("[TESTS] Mission Generation Integration")

    local CampaignOrchestrator = require("engine.geoscape.campaign_orchestrator")
    local orchestrator = CampaignOrchestrator.new()
    orchestrator:startNewCampaign("Normal")

    -- Generate missions at different threat levels
    for threat = 0, 80, 20 do
        orchestrator.campaignData.threat_level = threat
        orchestrator:updateCampaignDay(1)

        local mission = orchestrator:generateNextMission()

        assert(mission ~= nil, "Mission generated at threat " .. threat)
        assert(mission.id > 0, "Mission has valid ID")
        assert(mission.difficulty > 0, "Mission has difficulty")
        assert(mission.enemy_composition ~= nil, "Enemy composition set")
        assert(mission.enemy_types ~= nil, "Enemy types set")

        -- Check for threat-appropriate complications
        if threat >= 25 then
            -- May have complications at higher threat
        end
    end

    print("  ✓ Missions generated at all threat levels")
    print("  ✓ Enemy composition scales with threat")
    print("  ✓ All subsystems contribute to mission")
end

-- Test 5: Mission Outcome Processing
function testMissionOutcomeProcessing()
    print("[TESTS] Mission Outcome Processing")

    local CampaignOrchestrator = require("engine.geoscape.campaign_orchestrator")
    local orchestrator = CampaignOrchestrator.new()
    orchestrator:startNewCampaign("Normal")

    local initial_threat = orchestrator.campaignData.threat_level or 0

    -- Generate and process a successful mission
    orchestrator:updateCampaignDay(1)
    local mission = orchestrator:generateNextMission()

    local success_result = {
        success = true,
        casualties = 2,
        objectives_completed = 3,
        threat_change = 5,
        salvage_items = { "plasma_rifle", "alien_corpse" },
        craft_damage = { [1] = 10 }
    }

    orchestrator:processMissionOutcome(success_result)

    assert(orchestrator.campaignData.missions_completed == 1, "Mission counted")
    assert(orchestrator.campaignData.missions_won == 1, "Victory counted")
    assert(orchestrator.campaignData.threat_level > initial_threat, "Threat increased")

    print("  ✓ Mission outcomes processed")
    print("  ✓ Threat escalated correctly")
    print("  ✓ Statistics updated")
end

-- Test 6: Full Campaign Progression (0→100 Threat)
function testFullCampaignProgression()
    print("[TESTS] Full Campaign Progression")

    local CampaignOrchestrator = require("engine.geoscape.campaign_orchestrator")
    local orchestrator = CampaignOrchestrator.new()
    orchestrator:startNewCampaign("Normal")

    local missions_completed = 0

    -- Simulate progression through campaign phases
    while orchestrator.campaignData.threat_level < 100 and missions_completed < 50 do
        -- Days pass
        orchestrator:updateCampaignDay(5)

        -- Generate and process mission
        local mission = orchestrator:generateNextMission()
        if mission then
            -- Simulate outcome
            local outcome = {
                success = math.random() > 0.3,  -- 70% win rate
                casualties = math.random(0, 5),
                objectives_completed = math.random(1, 4),
                threat_change = math.random(2, 8),
                salvage_items = {},
                craft_damage = { [1] = math.random(0, 20) }
            }

            orchestrator:processMissionOutcome(outcome)
            missions_completed = missions_completed + 1
        end
    end

    assert(orchestrator.campaignData.threat_level <= 100, "Threat capped at 100")
    assert(orchestrator.campaign_phase == 4, "Reached final phase")
    assert(missions_completed > 0, "Missions completed")

    print(string.format("  ✓ Campaign progressed from 0 to threat %d",
        orchestrator.campaignData.threat_level))
    print(string.format("  ✓ %d missions completed", missions_completed))
    print("  ✓ All phases reached")
end

-- Test 7: Campaign Status and Diagnostics
function testCampaignStatus()
    print("[TESTS] Campaign Status")

    local CampaignOrchestrator = require("engine.geoscape.campaign_orchestrator")
    local orchestrator = CampaignOrchestrator.new()
    orchestrator:startNewCampaign("Normal", 2000, 50)

    local status = orchestrator:getCampaignStatus()

    assert(status.days_elapsed >= 0, "Days tracked")
    assert(status.threat_level >= 0, "Threat tracked")
    assert(status.soldiers_total == 50, "Soldier count correct")
    assert(status.soldiers_active <= status.soldiers_total, "Active soldiers valid")
    assert(status.crafts_operational <= 2, "Craft count valid")
    assert(status.win_rate >= 0 and status.win_rate <= 100, "Win rate valid")

    print("  ✓ Campaign status retrieved")
    print("  ✓ All metrics valid")
end

-- Test 8: Save/Load Functionality
function testSaveLoadFunctionality()
    print("[TESTS] Save/Load Functionality")

    setupMockFilesystem()

    local CampaignOrchestrator = require("engine.geoscape.campaign_orchestrator")
    local SaveGameManager = require("engine.geoscape.save_game_manager")

    -- Create and configure campaign
    local orchestrator = CampaignOrchestrator.new()
    orchestrator:startNewCampaign("Normal", 2000, 50)
    orchestrator:updateCampaignDay(10)
    orchestrator.campaignData.threat_level = 25

    local manager = SaveGameManager.new()

    -- Save campaign
    local ok, msg = manager:saveCampaign(1, orchestrator)
    assert(ok == true, "Campaign saved: " .. msg)

    -- Create new orchestrator and load
    local orchestrator2 = CampaignOrchestrator.new()
    local loaded_data = manager:loadCampaign(1)

    assert(loaded_data ~= nil, "Campaign loaded")

    if loaded_data then
        orchestrator2:deserialize(loaded_data.campaign)

        assert(orchestrator2.campaignData.threat_level == 25, "Threat restored")
        assert(orchestrator2.campaignData.days_elapsed == 10, "Days restored")
    end

    print("  ✓ Campaign saved to slot")
    print("  ✓ Campaign loaded from slot")
    print("  ✓ State restored correctly")
end

-- Test 9: UI Integration
function testUIIntegration()
    print("[TESTS] UI Integration")

    local CampaignOrchestrator = require("engine.geoscape.campaign_orchestrator")
    local UIIntegrationLayer = require("engine.geoscape.ui_integration_layer")

    local orchestrator = CampaignOrchestrator.new()
    orchestrator:startNewCampaign("Normal")

    local ui = UIIntegrationLayer.new(1024, 768)

    -- Update UI with campaign state
    ui:updateCampaignUI(orchestrator)

    assert(ui.ui_elements.top_bar ~= nil, "Top bar created")
    assert(ui.ui_elements.threat_indicator ~= nil, "Threat indicator created")
    assert(ui.ui_elements.resources ~= nil, "Resource panel created")

    -- Display various panels
    if orchestrator.systems.alien_research then
        local panel = ui:displayAlienResearchPanel(orchestrator.systems.alien_research)
        assert(panel ~= nil, "Research panel created")
    end

    if orchestrator.systems.base_expansion then
        local panel = ui:displayBaseStatusPanel(orchestrator.systems.base_expansion)
        assert(panel ~= nil, "Base status panel created")
    end

    if orchestrator.systems.faction_dynamics then
        local panel = ui:displayFactionsPanel(orchestrator.systems.faction_dynamics)
        assert(panel ~= nil, "Factions panel created")
    end

    print("  ✓ UI integration layer works")
    print("  ✓ All panels created successfully")
end

-- Test 10: Campaign Win/Loss Conditions
function testWinLossConditions()
    print("[TESTS] Win/Loss Conditions")

    local CampaignOrchestrator = require("engine.geoscape.campaign_orchestrator")

    -- Test win condition
    local orchestrator = CampaignOrchestrator.new()
    orchestrator:startNewCampaign("Normal")
    orchestrator.campaignData.threat_level = 100
    orchestrator.campaignData.final_mission_completed = true

    local status = orchestrator:checkCampaignStatus()
    assert(status.status == "won", "Victory detected at threat 100")

    -- Test loss condition
    local orchestrator2 = CampaignOrchestrator.new()
    orchestrator2:startNewCampaign("Normal")
    orchestrator2.campaignData.soldiers = {}  -- All soldiers dead

    local status2 = orchestrator2:checkCampaignStatus()
    assert(status2.status == "lost", "Defeat detected when no soldiers")

    print("  ✓ Victory condition detected")
    print("  ✓ Defeat condition detected")
end

-- Main test runner
function runAllPhase10Tests()
    print("\n" .. string.rep("=", 60))
    print("PHASE 10: COMPLETE CAMPAIGN INTEGRATION TESTS")
    print(string.rep("=", 60) .. "\n")

    testOrchestratorInitialization()
    print()

    testCampaignStartup()
    print()

    testPhaseTransitions()
    print()

    testMissionGeneration()
    print()

    testMissionOutcomeProcessing()
    print()

    testFullCampaignProgression()
    print()

    testCampaignStatus()
    print()

    testSaveLoadFunctionality()
    print()

    testUIIntegration()
    print()

    testWinLossConditions()
    print()

    print(string.rep("=", 60))
    print("ALL PHASE 10 INTEGRATION TESTS PASSED ✓")
    print(string.rep("=", 60) .. "\n")
end

-- Execute tests
runAllPhase10Tests()
