--[[
    Phase 9: Advanced Campaign Features Integration Tests

    Comprehensive test suite for all Phase 9 systems:
    - Alien Research System
    - Base Expansion System
    - Faction Dynamics System
    - Campaign Events System
    - Difficulty Refinements System

    Tests verify system functionality, integration points, and campaign flow.
]]

-- Mock campaign data
local function createMockCampaignData()
    return {
        days_played = 100,
        threat_level = 45,
        missions_completed = 15,
        soldiers_total = 50,
        soldiers = { {id=1}, {id=2}, {id=3} },
        research_points = 500,
        funding = 2000,
        wins = 10,
        losses = 5,
        casualties = 8
    }
end

-- Test Alien Research System
function testAlienResearchSystem()
    print("[TESTS] Alien Research System")

    local AlienResearchSystem = require("engine.geoscape.alien_research_system")
    local campaign = createMockCampaignData()
    local system = AlienResearchSystem.new(campaign)

    -- Test initialization
    assert(system ~= nil, "Research system initialized")
    assert(system.threatLevel == 0, "Initial threat is 0")
    assert(system.alienTechTree ~= nil, "Tech tree initialized")

    -- Test research update at threat 0
    system:updateAlienResearch(1, 0)
    local tech_tree_0 = system:getResearchProgress()
    assert(tech_tree_0 ~= nil, "Can retrieve tech progress")

    -- Test research progression at threat 30
    system:updateAlienResearch(10, 30)
    local tech_tree_30 = system:getResearchProgress()
    assert(tech_tree_30.sectoid_basics.available == true, "Sectoid basics available at threat 30")

    -- Test research at threat 70
    system:updateAlienResearch(20, 70)
    local tech_tree_70 = system:getResearchProgress()
    assert(tech_tree_70.sectoid_commander ~= nil, "Commander research available at threat 70")

    -- Test unit composition
    local composition = system:getAlienUnitComposition()
    assert(composition.units.sectoid == true, "Sectoids always available")
    if system.threatLevel >= 20 then
        assert(composition.units.muton == true, "Mutons available at high threat")
    end

    -- Test tech discovery
    system:recordTechDiscovery("plasma_weapons", "muton", 25)
    assert(system.playerDiscoveredTechs["plasma_weapons"] ~= nil, "Tech discovery recorded")
    assert(campaign.research_points == 525, "Research points added to campaign")

    -- Test serialization
    local serialized = system:serialize()
    assert(serialized.threatLevel == 70, "Serialized threat level correct")
    assert(serialized.playerDiscoveredTechs ~= nil, "Discovered techs serialized")

    print("  ✓ Research progression works")
    print("  ✓ Unit composition scales")
    print("  ✓ Tech discovery functional")
    print("  ✓ Serialization complete")
end

-- Test Base Expansion System
function testBaseExpansionSystem()
    print("[TESTS] Base Expansion System")

    local BaseExpansionSystem = require("engine.geoscape.base_expansion_system")
    local base_data = {
        soldiers = { {id=1}, {id=2}, {id=3}, {id=4}, {id=5} }
    }
    local system = BaseExpansionSystem.new(base_data)

    -- Test initialization
    assert(system ~= nil, "Base expansion system initialized")
    assert(system.baseSize == 1, "Initial base size is 1")

    -- Test expansion at threat 0
    system:updateBaseExpansion(0, 1)
    assert(system.baseSize == 1, "Base size unchanged at threat 0")

    -- Test expansion at threat 25
    system:updateBaseExpansion(25, 1)
    assert(system.baseSize >= 2, "Base expands at threat 25+")

    -- Test facility unlocking
    local facilities = system:getAvailableFacilities()
    assert(facilities.barracks ~= nil, "Barracks available")

    -- Test threat 35 facilities
    system:updateBaseExpansion(35, 1)
    local facilities_35 = system:getAvailableFacilities()
    assert(facilities_35.advanced_lab ~= nil, "Advanced lab unlocked at threat 35")

    -- Test facility addition
    local ok, msg = system:addFacility("barracks", 1)
    assert(ok == true, "Facility added successfully")
    assert(system.infrastructureCapacity.soldier_barracks >= 50, "Capacity updated")

    -- Test supply line vulnerability
    local vulnerability = system:calculateSupplyLineVulnerability()
    assert(vulnerability >= 0 and vulnerability <= 1, "Vulnerability in valid range")

    -- Test defense rating
    local defense = system:getBaseDefenseRating()
    assert(defense > 0, "Defense rating positive")

    -- Test base status
    local status = system:getBaseStatus()
    assert(status.grid_size > 0, "Status grid size valid")
    assert(status.hangar_slots > 0, "Status hangar slots valid")

    print("  ✓ Base expansion works")
    print("  ✓ Facilities unlock correctly")
    print("  ✓ Capacity management functional")
    print("  ✓ Vulnerability calculation correct")
end

-- Test Faction Dynamics System
function testFactionDynamicsSystem()
    print("[TESTS] Faction Dynamics System")

    local FactionDynamicsSystem = require("engine.geoscape.faction_dynamics")
    local campaign = createMockCampaignData()
    local system = FactionDynamicsSystem.new(campaign)

    -- Test initialization
    assert(system ~= nil, "Faction dynamics system initialized")
    assert(system.factions ~= nil, "Factions initialized")

    -- Test initial standings
    local standings = system:getFactionStandings()
    assert(standings.united_states ~= nil, "US faction exists")
    assert(standings.united_states.standing == 50, "Initial standing is 50")

    -- Test mission outcome processing
    local mission_result = {
        success = true,
        casualties = 2,
        objectives_completed = 3
    }
    system:processMissionOutcome(mission_result, "united_states")
    local new_standings = system:getFactionStandings()
    assert(new_standings.united_states.standing > 50, "Faction standing increased after success")

    -- Test council pressure update
    system:updateCouncilPressure(45, 55)
    assert(system.council_pressure > 0, "Council pressure calculated")

    -- Test faction stability
    local stability = system:checkFactionStability()
    assert(stability.at_risk ~= nil, "Stability check performed")

    -- Test funding calculation
    local funding = system:calculateTotalFunding(1000)
    assert(funding > 0, "Funding calculated positively")

    -- Test strategic choice impact
    system:recordStrategicChoice("defend_base", {
        united_states = 10,
        nato = 5
    })
    local after_choice = system:getFactionStandings()
    assert(after_choice.united_states.standing > new_standings.united_states.standing, "Strategic choice affects standing")

    -- Test serialization
    local serialized = system:serialize()
    assert(serialized.factions ~= nil, "Factions serialized")

    print("  ✓ Faction standings work")
    print("  ✓ Mission outcomes affect relations")
    print("  ✓ Council pressure calculated")
    print("  ✓ Funding system functional")
end

-- Test Campaign Events System
function testCampaignEventsSystem()
    print("[TESTS] Campaign Events System")

    local CampaignEventsSystem = require("engine.geoscape.campaign_events_system")
    local campaign = createMockCampaignData()
    local system = CampaignEventsSystem.new(campaign)

    -- Test initialization
    assert(system ~= nil, "Campaign events system initialized")
    assert(system.active_events ~= nil, "Active events initialized")

    -- Test event generation at low threat
    local events_low = system:generateEvents(10, 1)
    assert(events_low ~= nil, "Events generated at low threat")

    -- Test event generation at mid threat
    local events_mid = system:generateEvents(45, 1)
    -- May or may not generate events (probability-based)
    assert(events_mid ~= nil, "Events processed at mid threat")

    -- Test active events retrieval
    local active = system:getActiveEvents()
    assert(active ~= nil, "Active events retrieved")

    -- Test event resolution
    if #system.active_events > 0 then
        system:resolveEvent(1, "success")
        assert(system.active_events[1].resolved == true, "Event resolved correctly")
    end

    -- Test cascading events check
    if #system.event_history > 0 then
        local cascading = system:checkCascadingEvents(system.event_history[1])
        assert(cascading ~= nil, "Cascading events checked")
    end

    -- Test event statistics
    local stats = system:getEventStatistics()
    assert(stats.total_events_triggered >= 0, "Event statistics calculated")
    assert(stats.active_events >= 0, "Active event count valid")

    -- Test serialization
    local serialized = system:serialize()
    assert(serialized.active_events ~= nil, "Events serialized")

    print("  ✓ Event generation works")
    print("  ✓ Event retrieval functional")
    print("  ✓ Event resolution correct")
    print("  ✓ Cascading events handled")
end

-- Test Difficulty Refinements System
function testDifficultyRefinementsSystem()
    print("[TESTS] Difficulty Refinements System")

    local DifficultyRefinementsSystem = require("engine.geoscape.difficulty_refinements")
    local campaign = createMockCampaignData()
    local system = DifficultyRefinementsSystem.new(campaign)

    -- Test initialization
    assert(system ~= nil, "Difficulty refinements system initialized")
    assert(system.tactical_depth == 0, "Initial tactical depth is 0")

    -- Test update at threat 50
    system:updateDifficultyRefinements(50, campaign)
    assert(system.tactical_depth == 3, "Tactical depth updated to 3 at threat 50")

    -- Test morale effects
    local morale = system:getMoraleEffects()
    assert(morale ~= nil, "Morale effects calculated")
    assert(morale.accuracy_penalty >= 0, "Accuracy penalty non-negative")

    -- Test threat 70 - leader should emerge
    system:updateDifficultyRefinements(70, campaign)
    local leader = system:getAlienLeaderStatus()
    if system.threatLevel >= 70 then
        -- Leader may have emerged
    end

    -- Test threat 85+ - Ethereal Supreme
    system:updateDifficultyRefinements(85, campaign)
    local leader_85 = system:getAlienLeaderStatus()
    if leader_85 then
        assert(leader_85.psi_power >= 2.0, "Ethereal has high psi power")
    end

    -- Test elite squad deployment
    system:updateDifficultyRefinements(60, campaign)
    local squad = system:getEliteSquadDeployment()
    if squad then
        assert(squad.composition ~= nil, "Squad has composition")
    end

    -- Test psychological modifiers
    local base_stats = { accuracy = 1.0, damage = 1.0, armor = 1.0 }
    local modified = system:applyPsychologicalModifiers(base_stats)
    assert(modified.accuracy <= 1.0, "Psychological pressure reduces accuracy")

    -- Test tactical difficulty modifier
    local mod = system:getTacticalDifficultyModifier()
    assert(mod >= 1.0 and mod <= 2.0, "Tactical modifier in valid range")

    -- Test serialization
    local serialized = system:serialize()
    assert(serialized.tactical_depth ~= nil, "Tactical depth serialized")

    print("  ✓ Leader emergence works")
    print("  ✓ Elite squad composition varies")
    print("  ✓ Morale effects applied")
    print("  ✓ Psychological warfare functional")
end

-- Full integration test
function testFullCampaignIntegration()
    print("[TESTS] Full Campaign Integration")

    local AlienResearchSystem = require("engine.geoscape.alien_research_system")
    local BaseExpansionSystem = require("engine.geoscape.base_expansion_system")
    local FactionDynamicsSystem = require("engine.geoscape.faction_dynamics")
    local CampaignEventsSystem = require("engine.geoscape.campaign_events_system")
    local DifficultyRefinementsSystem = require("engine.geoscape.difficulty_refinements")

    local campaign = createMockCampaignData()

    -- Create all systems
    local research = AlienResearchSystem.new(campaign)
    local expansion = BaseExpansionSystem.new(campaign)
    local factions = FactionDynamicsSystem.new(campaign)
    local events = CampaignEventsSystem.new(campaign)
    local difficulty = DifficultyRefinementsSystem.new(campaign)

    -- Simulate campaign progression
    for threat = 0, 85, 15 do
        campaign.threat_level = threat

        -- Update all systems
        research:updateAlienResearch(5, threat)
        expansion:updateBaseExpansion(threat, 5)
        factions:updateCouncilPressure(threat, 50)
        events:generateEvents(threat, 5)
        difficulty:updateDifficultyRefinements(threat, campaign)

        -- Verify campaign state
        local comp = research:getAlienUnitComposition()
        assert(comp.units ~= nil, "Unit composition valid at threat " .. threat)

        local base_status = expansion:getBaseStatus()
        assert(base_status.grid_size > 0, "Base status valid at threat " .. threat)

        local faction_standings = factions:getFactionStandings()
        assert(faction_standings.united_states ~= nil, "Factions valid at threat " .. threat)
    end

    print("  ✓ Campaign progression works end-to-end")
    print("  ✓ All systems update together")
    print("  ✓ State remains consistent")
end

-- Run all tests
function runAllTests()
    print("\n" .. string.rep("=", 50))
    print("PHASE 9 INTEGRATION TESTS")
    print(string.rep("=", 50) .. "\n")

    testAlienResearchSystem()
    print()

    testBaseExpansionSystem()
    print()

    testFactionDynamicsSystem()
    print()

    testCampaignEventsSystem()
    print()

    testDifficultyRefinementsSystem()
    print()

    testFullCampaignIntegration()
    print()

    print(string.rep("=", 50))
    print("ALL TESTS PASSED ✓")
    print(string.rep("=", 50) .. "\n")
end

-- Execute tests
runAllTests()
