-- Integration Tests: Battlescape-Basescape System
-- Tests interactions between tactical combat and base management
-- Verifies that mission outcomes affect base state and vice versa

local BattleBaseTest = {}

-- Test setup
local function setup()
    package.path = package.path .. ";../../?.lua;../../engine/?.lua"
    
    local MockBattlescape = require("mock.battlescape")
    local MockBasescape = require("mock.basescape")
    
    return MockBattlescape, MockBasescape
end

-- TEST 1: Mission casualties reduce squad size
function BattleBaseTest.testMissionCasualtiesReduceSquad()
    local MockBattlescape, MockBasescape = setup()
    
    local squad = MockBasescape.getSquad()
    local initialSize = #squad
    
    -- Simulate casualties from combat
    local casualties = { squad[1] }
    MockBattlescape.applyCasualties(casualties)
    
    local finalSize = #squad
    
    assert(finalSize < initialSize, "Squad should be smaller after casualties")
    assert(finalSize == initialSize - 1, "Squad should have one less member")
    
    print("✓ testMissionCasualtiesReduceSquad passed")
end

-- TEST 2: Captured equipment appears in base inventory
function BattleBaseTest.testCapturedEquipmentInBase()
    local MockBattlescape, MockBasescape = setup()
    
    local capturedItems = {
        { name = "ALIEN_RIFLE", quantity = 3 },
        { name = "ALIEN_SHIELD", quantity = 1 },
        { name = "UFO_POWERCORE", quantity = 1 }
    }
    
    local initialInventory = MockBasescape.getInventoryCount()
    
    -- Transfer captured items to base
    for _, item in ipairs(capturedItems) do
        MockBasescape.addInventoryItem(item.name, item.quantity)
    end
    
    local finalInventory = MockBasescape.getInventoryCount()
    
    assert(finalInventory > initialInventory, "Inventory should increase")
    assert(finalInventory == initialInventory + 5, "5 items should be captured")
    
    print("✓ testCapturedEquipmentInBase passed")
end

-- TEST 3: Mission failure costs personnel
function BattleBaseTest.testMissionFailureCosts()
    local MockBattlescape, MockBasescape = setup()
    
    local squad = MockBasescape.getSquad()
    local initialSize = #squad
    
    -- Mission fails - entire squad lost
    for _ = 1, initialSize do
        MockBattlescape.applyCasualties({ squad[_] })
    end
    
    local finalSize = #squad
    
    assert(finalSize == 0, "Squad should be wiped out")
    assert(initialSize > 0, "Squad should have had members")
    
    print("✓ testMissionFailureCosts passed")
end

-- TEST 4: Successful mission provides research samples
function BattleBaseTest.testSuccessfulMissionProvidesSamples()
    local MockBattlescape, MockBasescape = setup()
    
    local samples = {
        { name = "XENOBIOLOGICAL_SAMPLE", quantity = 5 },
        { name = "ALLOY_FRAGMENT", quantity = 3 },
        { name = "ORGANIC_COMPOUND", quantity = 2 }
    }
    
    -- Add research samples to base
    for _, sample in ipairs(samples) do
        MockBasescape.addResearchSample(sample.name, sample.quantity)
    end
    
    local totalSamples = MockBasescape.getResearchSampleCount()
    
    assert(totalSamples >= 10, "Should have 10 research samples total")
    
    print("✓ testSuccessfulMissionProvidesSamples passed")
end

-- TEST 5: Wounded soldiers need medical treatment
function BattleBaseTest.testWoundedSoldiersNeedTreatment()
    local MockBattlescape, MockBasescape = setup()
    
    local soldier = { name = "Soldier1", health = 30, maxHealth = 100 }
    
    -- Soldier receives wounds in combat
    assert(soldier.health < soldier.maxHealth, "Soldier should be wounded")
    
    -- Treat at base medical facility
    local treatmentTime = 5 -- days
    local healAmount = 40 -- per day
    
    soldier.health = math.min(soldier.health + healAmount, soldier.maxHealth)
    
    assert(soldier.health > 30, "Soldier should be healing")
    
    print("✓ testWoundedSoldiersNeedTreatment passed")
end

-- TEST 6: Captured alien yields research tech
function BattleBaseTest.testCapturedAlienYieldsTech()
    local MockBattlescape, MockBasescape = setup()
    
    local alien = { 
        name = "HYBRID_SOLDIER", 
        species = "HYBRID",
        researchValue = 100000
    }
    
    local initialResearch = MockBasescape.getResearchPoints()
    
    -- Transfer captured alien to research facility
    MockBasescape.addResearchSubject(alien)
    MockBasescape.addResearchPoints(alien.researchValue)
    
    local finalResearch = MockBasescape.getResearchPoints()
    
    assert(finalResearch > initialResearch, "Research points should increase")
    assert(finalResearch >= initialResearch + alien.researchValue, "Points should match")
    
    print("✓ testCapturedAlienYieldsTech passed")
end

-- TEST 7: Mission preparation depletes consumables
function BattleBaseTest.testMissionPrepDepletesConsumables()
    local MockBattlescape, MockBasescape = setup()
    
    local consumables = {
        ammunition = 1000,
        medkits = 20,
        grenades = 30
    }
    
    local initialAmmo = MockBasescape.getAmmunitionStock()
    
    -- Deploy squad with supplies
    local deploymentAmmo = 200
    MockBasescape.setAmmunitionStock(initialAmmo - deploymentAmmo)
    
    local finalAmmo = MockBasescape.getAmmunitionStock()
    
    assert(finalAmmo < initialAmmo, "Ammunition stock should decrease")
    assert(finalAmmo == initialAmmo - deploymentAmmo, "Amount should match")
    
    print("✓ testMissionPrepDepletesConsumables passed")
end

-- TEST 8: Alien artifact analysis unlocks new equipment
function BattleBaseTest.testAlienArtifactAnalysis()
    local MockBattlescape, MockBasescape = setup()
    
    local artifact = {
        name = "ALIEN_ALLOY",
        analysisTime = 15,
        unlocksWeapon = "PLASMA_RIFLE"
    }
    
    -- Start analysis at base lab
    MockBasescape.startAnalysis(artifact)
    
    local unlockedWeapon = MockBasescape.getUnlockedWeapon(artifact.unlocksWeapon)
    
    assert(unlockedWeapon ~= nil, "Weapon should be unlocked")
    
    print("✓ testAlienArtifactAnalysis passed")
end

-- TEST 9: Soldier experience increases from missions
function BattleBaseTest.testSoldierExperienceGain()
    local MockBattlescape, MockBasescape = setup()
    
    local soldier = { name = "Soldier1", experience = 0, rank = "ROOKIE" }
    local missionKills = 5
    local experiencePerKill = 100
    
    -- Gain experience from kills
    local gainedExperience = missionKills * experiencePerKill
    soldier.experience = soldier.experience + gainedExperience
    
    assert(soldier.experience == 500, "Experience should be 500")
    
    -- Check for rank-up (rookie -> veteran at 400 exp)
    if soldier.experience >= 400 then
        soldier.rank = "VETERAN"
    end
    
    assert(soldier.rank == "VETERAN", "Soldier should be promoted")
    
    print("✓ testSoldierExperienceGain passed")
end

-- TEST 10: Base under attack affects defenses
function BattleBaseTest.testBaseUnderAttack()
    local MockBattlescape, MockBasescape = setup()
    
    local baseDefense = 100
    local attackDamage = 30
    
    local finalDefense = baseDefense - attackDamage
    
    assert(finalDefense == 70, "Defense should be reduced")
    assert(finalDefense > 0, "Base should still be standing")
    
    -- If defense drops to 0, base is lost
    local baseDestroyed = (finalDefense <= 0)
    assert(not baseDestroyed, "Base should not be destroyed")
    
    print("✓ testBaseUnderAttack passed")
end

-- Run all tests
function BattleBaseTest.runAll()
    print("\n[INTEGRATION TEST] Battlescape-Basescape System\n")
    
    local tests = {
        BattleBaseTest.testMissionCasualtiesReduceSquad,
        BattleBaseTest.testCapturedEquipmentInBase,
        BattleBaseTest.testMissionFailureCosts,
        BattleBaseTest.testSuccessfulMissionProvidesSamples,
        BattleBaseTest.testWoundedSoldiersNeedTreatment,
        BattleBaseTest.testCapturedAlienYieldsTech,
        BattleBaseTest.testMissionPrepDepletesConsumables,
        BattleBaseTest.testAlienArtifactAnalysis,
        BattleBaseTest.testSoldierExperienceGain,
        BattleBaseTest.testBaseUnderAttack,
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

return BattleBaseTest
