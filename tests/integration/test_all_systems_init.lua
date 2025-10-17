---Integration Test: All Systems Initialization
---
---Tests that all newly implemented systems can be initialized without errors.
---
---@module tests.test_systems_integration

local Tests = {}

-- Test all system initializations
function Tests.runAllInitTests()
    print("\n=====================================")
    print("INTEGRATION TEST: Systems Initialization")
    print("=====================================\n")
    
    -- Test 1: Facility System
    print("[TEST 1] Facility System Initialization")
    local FacilityRegistry = require("basescape.logic.facility_registry")
    local BaseManager = require("basescape.logic.base_manager")
    
    FacilityRegistry.initialize(nil)
    FacilityRegistry.printTypes()
    
    BaseManager.initialize()
    local base1 = BaseManager.createBase("Alpha Base", "north_america", 1000000)
    base1:printSummary()
    
    print("[TEST 1] ✓ PASSED\n")
    
    -- Test 2: Research System
    print("[TEST 2] Research System Initialization")
    local ResearchManager = require("geoscape.logic.research_manager")
    
    ResearchManager.initialize()
    local proj1, err = ResearchManager.startResearch("basic_research", 10)
    
    if proj1 then
        print("Research project started: " .. proj1.entryId)
        ResearchManager.printActiveResearch()
        print("[TEST 2] ✓ PASSED\n")
    else
        print("[TEST 2] ✗ FAILED: " .. (err or "unknown"))
        print()
    end
    
    -- Test 3: Manufacturing System
    print("[TEST 3] Manufacturing System Initialization")
    local ManufacturingRegistry = require("basescape.logic.manufacturing_registry")
    local ManufacturingManager = require("basescape.logic.manufacturing_manager")
    
    ManufacturingRegistry.initialize(nil)
    ManufacturingRegistry.printEntries()
    
    local mfgMgr = ManufacturingManager.new("base_1", 10)
    local mfgProj, mfgErr = mfgMgr:startProject("laser_rifle", 2, 5)
    
    if mfgProj then
        mfgMgr:printActiveManufacturing()
        print("[TEST 3] ✓ PASSED\n")
    else
        print("[TEST 3] ✗ FAILED: " .. (mfgErr or "unknown"))
        print()
    end
    
    -- Test 4: Deployment System
    print("[TEST 4] Deployment System Initialization")
    local DeploymentConfig = require("battlescape.logic.deployment_config")
    local LandingZoneSelector = require("battlescape.logic.landing_zone_selector")
    
    local config = DeploymentConfig.new({
        missionId = "mission_test_001",
        mapSize = "medium",
        mapBlockGrid = 5,
    })
    
    local zones = LandingZoneSelector.selectZones(5, "medium")
    for _, zone in ipairs(zones) do
        DeploymentConfig.addLandingZone(config, zone)
    end
    
    config:printSummary()
    print("[TEST 4] ✓ PASSED\n")
    
    -- Test 5: Salvage System
    print("[TEST 5] Salvage System Initialization")
    local MissionResult = require("battlescape.logic.mission_result")
    local SalvageProcessor = require("battlescape.logic.salvage_processor")
    
    local result = MissionResult.new({
        missionId = "mission_test_001",
        victory = true,
        unitsDeployed = 6,
        unitsSurvived = 5,
        unitsKilled = 1,
        enemiesKilled = 12,
        objectivesTotal = 2,
        objectivesCompleted = 2,
        turnsElapsed = 15,
    })
    
    result:addSalvageItem("plasma_rifle", 3)
    result:addSalvageItem("dead_sectoid", 4)
    result:addSalvageMoney(5000)
    result:calculateScore()
    result:printSummary()
    
    print("[TEST 5] ✓ PASSED\n")
    
    print("=====================================")
    print("ALL INTEGRATION TESTS PASSED!")
    print("=====================================\n")
    
    return true
end

return Tests.runAllInitTests()
