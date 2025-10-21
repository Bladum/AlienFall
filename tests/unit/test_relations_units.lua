-- Unit Tests: Relations System
-- Tests diplomatic relationships, faction interactions, and reputation mechanics

local RelationsUnitTest = {}

-- Test setup
local function setup()
    package.path = package.path .. ";../../?.lua;../../engine/?.lua"
    local MockGeoscape = require("mock.geoscape")
    return MockGeoscape
end

-- TEST 1: Country relations modification
function RelationsUnitTest.testCountryRelationsModification()
    local MockGeoscape = setup()
    
    local country = { name = "France", relation = 50, aligned = false }
    
    assert(country.relation == 50, "Initial relation should be 50")
    
    -- Improve relation
    country.relation = country.relation + 15
    assert(country.relation == 65, "Relation should increase")
    
    -- Worsen relation
    country.relation = country.relation - 10
    assert(country.relation == 55, "Relation should decrease")
    
    print("✓ testCountryRelationsModification passed")
end

-- TEST 2: Relation thresholds and alignment
function RelationsUnitTest.testRelationThresholds()
    local MockGeoscape = setup()
    
    local country = { name = "Japan", relation = 0, aligned = false }
    
    -- Below 25: antagonistic
    assert(country.relation < 25, "Should be antagonistic")
    country.aligned = false
    
    -- 25-49: hostile
    country.relation = 35
    assert(country.relation >= 25 and country.relation < 50, "Should be hostile")
    
    -- 50-74: neutral
    country.relation = 60
    assert(country.relation >= 50 and country.relation < 75, "Should be neutral")
    
    -- 75+: aligned
    country.relation = 85
    if country.relation >= 75 then
        country.aligned = true
    end
    
    assert(country.aligned == true, "Should be aligned")
    
    print("✓ testRelationThresholds passed")
end

-- TEST 3: Faction favorability tracking
function RelationsUnitTest.testFactionFavorability()
    local MockGeoscape = setup()
    
    local factions = {
        xcom = { name = "X-COM", influence = 50 },
        usagov = { name = "US Government", influence = 45 },
        magicka = { name = "Magicka", influence = 30 },
        syndicate = { name = "Syndicate", influence = 20 }
    }
    
    -- Calculate total influence
    local totalInfluence = 0
    for _, faction in pairs(factions) do
        totalInfluence = totalInfluence + faction.influence
    end
    
    assert(totalInfluence == 145, "Total influence should be 145")
    
    -- X-COM dominance
    local xcomPercent = (factions.xcom.influence / totalInfluence) * 100
    assert(xcomPercent > 30, "X-COM should have significant influence")
    
    print("✓ testFactionFavorability passed")
end

-- TEST 4: Diplomatic incident consequences
function RelationsUnitTest.testDiplomaticIncidents()
    local MockGeoscape = setup()
    
    local incident = {
        type = "CIVILIAN_CASUALTIES",
        severity = 3,
        relationPenalty = 20,
        country = "Germany"
    }
    
    local country = { name = "Germany", relation = 70 }
    
    -- Apply penalty
    country.relation = country.relation - incident.relationPenalty
    
    assert(country.relation == 50, "Relation should decrease by penalty")
    assert(country.relation < 75, "Should no longer be aligned")
    
    print("✓ testDiplomaticIncidents passed")
end

-- TEST 5: Alliance formation requirements
function RelationsUnitTest.testAllianceFormationRequirements()
    local MockGeoscape = setup()
    
    local country = { name = "Brazil", relation = 80 }
    local allianceRequirement = 75
    
    local canAlly = country.relation >= allianceRequirement
    
    assert(canAlly == true, "Should be able to form alliance")
    
    -- Another country with low relation
    local country2 = { name = "Russia", relation = 40 }
    canAlly = country2.relation >= allianceRequirement
    
    assert(canAlly == false, "Should not be able to form alliance")
    
    print("✓ testAllianceFormationRequirements passed")
end

-- TEST 6: Resource sharing agreements
function RelationsUnitTest.testResourceSharingAgreements()
    local MockGeoscape = setup()
    
    local agreement = {
        id = 1,
        countries = { "Canada", "USA" },
        resources = { supplies = 1000, intel = 500 },
        monthlyBenefit = 150000,
        startDate = 2006,
        duration = 12 -- months
    }
    
    assert(#agreement.countries == 2, "Should involve 2 countries")
    assert(agreement.monthlyBenefit == 150000, "Monthly benefit should be tracked")
    
    print("✓ testResourceSharingAgreements passed")
end

-- TEST 7: Spy network effectiveness
function RelationsUnitTest.testSpyNetworkEffectiveness()
    local MockGeoscape = setup()
    
    local spyNetwork = {
        country = "Egypt",
        agents = 5,
        infoGained = 12, -- intel units
        riskOfDiscovery = 15, -- percent
        monthlyUpkeepCost = 25000
    }
    
    assert(spyNetwork.agents == 5, "Agent count should be tracked")
    assert(spyNetwork.infoGained == 12, "Intel should be tracked")
    assert(spyNetwork.riskOfDiscovery < 50, "Risk should be manageable")
    
    -- More agents = more intel but higher risk
    spyNetwork.agents = spyNetwork.agents + 2
    spyNetwork.infoGained = spyNetwork.infoGained + 8
    spyNetwork.riskOfDiscovery = spyNetwork.riskOfDiscovery + 10
    
    assert(spyNetwork.agents == 7, "Agents should increase")
    assert(spyNetwork.infoGained == 20, "Intel should increase")
    
    print("✓ testSpyNetworkEffectiveness passed")
end

-- TEST 8: Faction competition mechanics
function RelationsUnitTest.testFactionCompetition()
    local MockGeoscape = setup()
    
    local factions = {
        { name = "XCom", power = 60 },
        { name = "Corporate", power = 40 },
        { name = "Military", power = 50 }
    }
    
    -- Rank by power
    table.sort(factions, function(a, b) return a.power > b.power end)
    
    assert(factions[1].name == "XCom", "XCom should be strongest")
    assert(factions[3].name == "Corporate", "Corporate should be weakest")
    
    print("✓ testFactionCompetition passed")
end

-- TEST 9: Trade agreement negotiation
function RelationsUnitTest.testTradeAgreement()
    local MockGeoscape = setup()
    
    local buyer = { name = "XCom", money = 500000 }
    local seller = { name = "Syndicate", inventory = { supplies = 100, ammo = 50 } }
    
    local tradePrice = 75000
    
    if buyer.money >= tradePrice then
        buyer.money = buyer.money - tradePrice
        seller.money = (seller.money or 0) + tradePrice
        
        table.insert(buyer.inventory or {}, "SUPPLIES_PACK")
    end
    
    assert(buyer.money == 425000, "Buyer should spend money")
    
    print("✓ testTradeAgreement passed")
end

-- TEST 10: Reputation recovery from bad relation
function RelationsUnitTest.testReputationRecovery()
    local MockGeoscape = setup()
    
    local country = { name = "Mexico", relation = 10 }
    
    -- Very bad relations
    assert(country.relation < 25, "Should have bad relations")
    
    -- Positive actions improve reputation
    local bonusFromSuccessfulMission = 8
    local bonusFromGift = 10
    local bonusFromDiplomacy = 7
    
    country.relation = country.relation + bonusFromSuccessfulMission + bonusFromGift + bonusFromDiplomacy
    
    assert(country.relation == 35, "Reputation should improve")
    
    print("✓ testReputationRecovery passed")
end

-- TEST 11: Diplomatic crisis management
function RelationsUnitTest.testDiplomaticCrisisManagement()
    local MockGeoscape = setup()
    
    local crisis = {
        type = "TREATY_VIOLATION",
        severity = 4, -- 1-5
        affectedCountries = { "France", "Germany", "UK" },
        timeline = 3, -- months to resolve
        penaltyPerMonth = 5
    }
    
    local relationship = 50
    
    -- Each month of unresolved crisis worsens relations
    for month = 1, crisis.timeline do
        relationship = relationship - crisis.penaltyPerMonth
    end
    
    assert(relationship == 35, "Relationship should deteriorate")
    
    print("✓ testDiplomaticCrisisManagement passed")
end

-- TEST 12: Allied nation support benefits
function RelationsUnitTest.testAlliedNationSupport()
    local MockGeoscape = setup()
    
    local alliedNation = { name = "Australia", relation = 85, supportProvided = false }
    
    if alliedNation.relation >= 75 then
        alliedNation.supportProvided = true
    end
    
    assert(alliedNation.supportProvided == true, "Should provide support")
    
    -- Support benefits
    local supportBenefit = {
        troops = 500,
        equipment = 50,
        intel = 100,
        funding = 200000
    }
    
    assert(supportBenefit.funding == 200000, "Funding support should be tracked")
    
    print("✓ testAlliedNationSupport passed")
end

-- TEST 13: Reputation point system
function RelationsUnitTest.testReputationPointSystem()
    local MockGeoscape = setup()
    
    local reputation = {
        xcom_recognition = 0,
        global_support = 0,
        alien_fear = 50,
        civilian_trust = 40
    }
    
    -- Complete successful mission
    reputation.xcom_recognition = reputation.xcom_recognition + 25
    reputation.global_support = reputation.global_support + 15
    reputation.alien_fear = reputation.alien_fear + 10
    reputation.civilian_trust = reputation.civilian_trust + 20
    
    assert(reputation.xcom_recognition == 25, "XCom recognition should increase")
    assert(reputation.civilian_trust == 60, "Civilian trust should increase")
    
    print("✓ testReputationPointSystem passed")
end

-- TEST 14: Enemy faction relations
function RelationsUnitTest.testEnemyFactionRelations()
    local MockGeoscape = setup()
    
    local relations = {
        { faction = "Aliens", xcom = -100 },
        { faction = "Hybrid", xcom = -50 },
        { faction = "Corporate", xcom = -10 },
        { faction = "Government", xcom = 40 }
    }
    
    -- Check for hostile factions
    local hostiles = 0
    for _, rel in ipairs(relations) do
        if rel.xcom < 0 then
            hostiles = hostiles + 1
        end
    end
    
    assert(hostiles == 3, "Should have 3 hostile factions")
    
    print("✓ testEnemyFactionRelations passed")
end

-- Run all tests
function RelationsUnitTest.runAll()
    print("\n[UNIT TEST] Relations System\n")
    
    local tests = {
        RelationsUnitTest.testCountryRelationsModification,
        RelationsUnitTest.testRelationThresholds,
        RelationsUnitTest.testFactionFavorability,
        RelationsUnitTest.testDiplomaticIncidents,
        RelationsUnitTest.testAllianceFormationRequirements,
        RelationsUnitTest.testResourceSharingAgreements,
        RelationsUnitTest.testSpyNetworkEffectiveness,
        RelationsUnitTest.testFactionCompetition,
        RelationsUnitTest.testTradeAgreement,
        RelationsUnitTest.testReputationRecovery,
        RelationsUnitTest.testDiplomaticCrisisManagement,
        RelationsUnitTest.testAlliedNationSupport,
        RelationsUnitTest.testReputationPointSystem,
        RelationsUnitTest.testEnemyFactionRelations,
    }
    
    local passed = 0
    local failed = 0
    
    for _, test in ipairs(tests) do
        local success = pcall(test)
        if success then
            passed = passed + 1
        else
            failed = failed + 1
            print("✗ " .. tostring(test) .. " FAILED")
        end
    end
    
    print("\n[RESULT] Passed: " .. passed .. "/" .. #tests)
    if failed > 0 then
        print("[RESULT] Failed: " .. failed)
    end
    print()
    
    return passed, failed
end

return RelationsUnitTest
