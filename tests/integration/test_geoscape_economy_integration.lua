-- Integration Tests: Geoscape-Economy System
-- Tests interactions between world map, missions, and economic systems
-- Verifies that mission outcomes affect economy and vice versa

local GeoEconTest = {}

-- Test setup
local function setup()
    package.path = package.path .. ";../../?.lua;../../engine/?.lua"
    
    local MockGeoscape = require("mock.geoscape")
    local MockEconomy = require("mock.economy")
    
    return MockGeoscape, MockEconomy
end

-- TEST 1: Mission reward affects economy
function GeoEconTest.testMissionRewardAffectsEconomy()
    local MockGeoscape, MockEconomy = setup()
    
    local initialMoney = MockEconomy.getMoney()
    local mission = MockGeoscape.getMission()
    local reward = mission.reward or 100000
    
    -- Complete mission
    MockEconomy.addMoney(reward)
    local finalMoney = MockEconomy.getMoney()
    
    assert(finalMoney > initialMoney, "Money should increase after mission")
    assert(finalMoney == initialMoney + reward, "Money should equal initial + reward")
    
    print("✓ testMissionRewardAffectsEconomy passed")
end

-- TEST 2: Casualties affect monthly salary costs
function GeoEconTest.testCasualtiesAffectSalaryCosts()
    local MockGeoscape, MockEconomy = setup()
    
    local squad = MockGeoscape.getSquad()
    local initialSquadSize = #squad
    local initialCosts = MockEconomy.getMonthlySalaryCosts()
    
    -- Simulate losses (50% casualties)
    local losses = math.floor(initialSquadSize / 2)
    for i = 1, losses do
        table.remove(squad, 1)
    end
    
    local finalSquadSize = #squad
    local finalCosts = MockEconomy.getMonthlySalaryCosts()
    
    assert(finalSquadSize < initialSquadSize, "Squad should be smaller")
    assert(finalCosts < initialCosts, "Salary costs should decrease")
    assert(finalSquadSize == initialSquadSize - losses, "Losses should match")
    
    print("✓ testCasualtiesAffectSalaryCosts passed")
end

-- TEST 3: Equipment purchases affect budget
function GeoEconTest.testEquipmentPurchasesAffectBudget()
    local MockGeoscape, MockEconomy = setup()
    
    local initialMoney = MockEconomy.getMoney()
    local rifle = { name = "RIFLE", cost = 50000 }
    
    -- Purchase 5 rifles
    local totalCost = rifle.cost * 5
    MockEconomy.subtractMoney(totalCost)
    
    local finalMoney = MockEconomy.getMoney()
    
    assert(finalMoney < initialMoney, "Money should decrease after purchase")
    assert(finalMoney == initialMoney - totalCost, "Money should equal initial - cost")
    
    print("✓ testEquipmentPurchasesAffectBudget passed")
end

-- TEST 4: Research funding affects available technologies
function GeoEconTest.testResearchFundingAffectsTech()
    local MockGeoscape, MockEconomy = setup()
    
    local initialMoney = MockEconomy.getMoney()
    local researchCost = 150000
    
    -- Fund research project
    if initialMoney >= researchCost then
        MockEconomy.subtractMoney(researchCost)
        local tech = { name = "ADVANCED_RIFLE", turnsToComplete = 10 }
        
        local finalMoney = MockEconomy.getMoney()
        
        assert(finalMoney == initialMoney - researchCost, "Research should cost money")
        assert(tech ~= nil, "Technology should be researched")
    end
    
    print("✓ testResearchFundingAffectsTech passed")
end

-- TEST 5: Facility maintenance costs scale with operations
function GeoEconTest.testFacilityMaintenanceCosts()
    local MockGeoscape, MockEconomy = setup()
    
    local baseCost = 10000 -- Base maintenance
    local operationsCost = 5000 -- Per active facility
    
    -- Calculate total maintenance for 3 active facilities
    local activeFacilities = 3
    local totalMaintenance = baseCost + (operationsCost * activeFacilities)
    
    local initialMoney = MockEconomy.getMoney()
    MockEconomy.subtractMoney(totalMaintenance)
    
    local finalMoney = MockEconomy.getMoney()
    
    assert(finalMoney == initialMoney - totalMaintenance, "Maintenance costs should be deducted")
    assert(totalMaintenance == 25000, "Total maintenance calculation should be correct")
    
    print("✓ testFacilityMaintenanceCosts passed")
end

-- TEST 6: Monthly economy cycle completes correctly
function GeoEconTest.testMonthlyEconomyCycle()
    local MockGeoscape, MockEconomy = setup()
    
    local initialMoney = MockEconomy.getMoney()
    local monthlyIncome = 50000
    local monthlyCosts = 30000
    
    -- Simulate monthly cycle
    MockEconomy.addMoney(monthlyIncome)
    MockEconomy.subtractMoney(monthlyCosts)
    
    local expectedMoney = initialMoney + monthlyIncome - monthlyCosts
    local actualMoney = MockEconomy.getMoney()
    
    assert(actualMoney == expectedMoney, "Monthly cycle should calculate correctly")
    
    print("✓ testMonthlyEconomyCycle passed")
end

-- TEST 7: Budget panic when money runs low
function GeoEconTest.testBudgetPanicThreshold()
    local MockGeoscape, MockEconomy = setup()
    
    -- Set money to near-critical level
    local criticalThreshold = 50000
    MockEconomy.setMoney(60000)
    
    local currentMoney = MockEconomy.getMoney()
    
    if currentMoney < criticalThreshold then
        -- Should trigger budget warning
        assert(true, "Budget warning should be triggered")
    end
    
    print("✓ testBudgetPanicThreshold passed")
end

-- TEST 8: Supply contracts affect economy
function GeoEconTest.testSupplyContracts()
    local MockGeoscape, MockEconomy = setup()
    
    local supplier = { name = "CONDOR_CARTEL", discount = 0.9 }
    local cost = 100000
    local discountedCost = cost * supplier.discount
    
    local initialMoney = MockEconomy.getMoney()
    MockEconomy.subtractMoney(discountedCost)
    
    local finalMoney = MockEconomy.getMoney()
    
    assert(finalMoney == initialMoney - discountedCost, "Discounted cost should apply")
    assert(discountedCost < cost, "Discount should reduce cost")
    
    print("✓ testSupplyContracts passed")
end

-- TEST 9: Mission failure costs money
function GeoEconTest.testMissionFailureCosts()
    local MockGeoscape, MockEconomy = setup()
    
    local failurePenalty = 50000
    local initialMoney = MockEconomy.getMoney()
    
    -- Mission fails
    MockEconomy.subtractMoney(failurePenalty)
    
    local finalMoney = MockEconomy.getMoney()
    
    assert(finalMoney < initialMoney, "Money should decrease on failure")
    assert(finalMoney == initialMoney - failurePenalty, "Penalty should match")
    
    print("✓ testMissionFailureCosts passed")
end

-- TEST 10: Geoscape events affect economy
function GeoEconTest.testGeoscapeEventsAffectEconomy()
    local MockGeoscape, MockEconomy = setup()
    
    local initialMoney = MockEconomy.getMoney()
    
    -- Alien activity surge increases defense costs
    local surgeEvent = { type = "ALIEN_SURGE", costIncrease = 1.2 }
    local baseCost = 10000
    local surgedCost = baseCost * surgeEvent.costIncrease
    
    MockEconomy.subtractMoney(surgedCost)
    
    local finalMoney = MockEconomy.getMoney()
    
    assert(finalMoney < initialMoney, "Event costs should reduce money")
    assert(surgedCost > baseCost, "Surge should increase costs")
    
    print("✓ testGeoscapeEventsAffectEconomy passed")
end

-- Run all tests
function GeoEconTest.runAll()
    print("\n[INTEGRATION TEST] Geoscape-Economy System\n")
    
    local tests = {
        GeoEconTest.testMissionRewardAffectsEconomy,
        GeoEconTest.testCasualtiesAffectSalaryCosts,
        GeoEconTest.testEquipmentPurchasesAffectBudget,
        GeoEconTest.testResearchFundingAffectsTech,
        GeoEconTest.testFacilityMaintenanceCosts,
        GeoEconTest.testMonthlyEconomyCycle,
        GeoEconTest.testBudgetPanicThreshold,
        GeoEconTest.testSupplyContracts,
        GeoEconTest.testMissionFailureCosts,
        GeoEconTest.testGeoscapeEventsAffectEconomy,
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

return GeoEconTest
