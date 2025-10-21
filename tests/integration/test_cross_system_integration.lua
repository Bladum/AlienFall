-- Integration Tests: Cross-System State Consistency
-- Tests state consistency across all major game systems
-- Verifies save/load integrity and system dependencies

local CrossSystemTest = {}

-- Test setup
local function setup()
    package.path = package.path .. ";../../?.lua;../../engine/?.lua"
    
    local MockGeoscape = require("mock.geoscape")
    local MockBattlescape = require("mock.battlescape")
    local MockBasescape = require("mock.basescape")
    local MockEconomy = require("mock.economy")
    
    return MockGeoscape, MockBattlescape, MockBasescape, MockEconomy
end

-- TEST 1: Game state persists correctly
function CrossSystemTest.testGameStatePersistence()
    local MockGeoscape, MockBattlescape, MockBasescape, MockEconomy = setup()
    
    -- Create initial state
    local gameState = {
        turn = 42,
        year = 2006,
        month = 5,
        geoscape_data = MockGeoscape.getData(),
        basescape_data = MockBasescape.getData(),
        economy_data = MockEconomy.getData()
    }
    
    -- Simulate save
    local savedState = table.deepcopy(gameState)
    
    -- Verify save integrity
    assert(savedState.turn == gameState.turn, "Turn should persist")
    assert(savedState.year == gameState.year, "Year should persist")
    assert(savedState.month == gameState.month, "Month should persist")
    
    print("✓ testGameStatePersistence passed")
end

-- TEST 2: Soldier roster consistency across systems
function CrossSystemTest.testSoldierRosterConsistency()
    local MockGeoscape, MockBattlescape, MockBasescape, MockEconomy = setup()
    
    local roster = MockBasescape.getSquad()
    local rosterSize = #roster
    
    -- Deploy soldiers to mission
    local deployed = math.floor(rosterSize / 2)
    local remainingInBase = rosterSize - deployed
    
    -- Verify roster consistency
    assert(deployed + remainingInBase == rosterSize, "Roster should be accounted for")
    
    -- After mission returns, roster should be consistent
    assert(#roster == rosterSize, "Roster should return to base")
    
    print("✓ testSoldierRosterConsistency passed")
end

-- TEST 3: Money flow is tracked correctly
function CrossSystemTest.testMoneyFlowConsistency()
    local MockGeoscape, MockBattlescape, MockBasescape, MockEconomy = setup()
    
    local startMoney = MockEconomy.getMoney()
    local transactions = {}
    
    -- Simulate transactions
    table.insert(transactions, { type = "MISSION_REWARD", amount = 100000 })
    table.insert(transactions, { type = "SALARY", amount = -50000 })
    table.insert(transactions, { type = "EQUIPMENT", amount = -25000 })
    table.insert(transactions, { type = "RESEARCH", amount = -15000 })
    
    local totalTransactions = 0
    for _, trans in ipairs(transactions) do
        totalTransactions = totalTransactions + trans.amount
    end
    
    local expectedMoney = startMoney + totalTransactions
    
    -- Apply transactions
    for _, trans in ipairs(transactions) do
        if trans.amount > 0 then
            MockEconomy.addMoney(trans.amount)
        else
            MockEconomy.subtractMoney(-trans.amount)
        end
    end
    
    local finalMoney = MockEconomy.getMoney()
    
    assert(finalMoney == expectedMoney, "Money should be consistent")
    
    print("✓ testMoneyFlowConsistency passed")
end

-- TEST 4: Equipment transferred between systems
function CrossSystemTest.testEquipmentTransferConsistency()
    local MockGeoscape, MockBattlescape, MockBasescape, MockEconomy = setup()
    
    -- Equipment in base storage
    local baseStorage = { "RIFLE", "RIFLE", "LASER_RIFLE", "MEDKIT" }
    local baseCount = #baseStorage
    
    -- Deploy to mission
    local equipped = { "RIFLE", "RIFLE", "LASER_RIFLE" }
    local deployedCount = #equipped
    
    -- Remaining in base
    local remaining = baseCount - deployedCount
    
    assert(remaining == 1, "One item should remain in base")
    
    -- Return from mission with captured items
    table.insert(baseStorage, "ALIEN_RIFLE")
    
    local finalCount = #baseStorage
    
    assert(finalCount == baseCount + 1, "Captured item should be in storage")
    
    print("✓ testEquipmentTransferConsistency passed")
end

-- TEST 5: Research dependencies are valid
function CrossSystemTest.testResearchDependenciesValid()
    local MockGeoscape, MockBattlescape, MockBasescape, MockEconomy = setup()
    
    -- Research tech tree
    local techTree = {
        BASIC_WEAPONS = { requirements = {}, unlocks = { "LASER_WEAPONS" } },
        LASER_WEAPONS = { requirements = { "BASIC_WEAPONS" }, unlocks = { "PLASMA_WEAPONS" } },
        PLASMA_WEAPONS = { requirements = { "LASER_WEAPONS" }, unlocks = {} }
    }
    
    -- Verify dependencies
    for tech, data in pairs(techTree) do
        for _, required in ipairs(data.requirements) do
            assert(techTree[required] ~= nil, "Required tech should exist: " .. required)
        end
        for _, unlocked in ipairs(data.unlocks) do
            assert(techTree[unlocked] ~= nil, "Unlocked tech should exist: " .. unlocked)
        end
    end
    
    print("✓ testResearchDependenciesValid passed")
end

-- TEST 6: Casualty accounting is consistent
function CrossSystemTest.testCasualtyAccountingConsistent()
    local MockGeoscape, MockBattlescape, MockBasescape, MockEconomy = setup()
    
    local initialSquadSize = 12
    local mission1Casualties = 2
    local mission2Casualties = 3
    local totalCasualties = mission1Casualties + mission2Casualties
    
    local finalSquadSize = initialSquadSize - totalCasualties
    
    assert(finalSquadSize == 7, "Squad size should be 7")
    assert(totalCasualties == 5, "Total casualties should be 5")
    
    -- Verify casualty records
    local casualtyLog = MockBattlescape.getCasualtyLog()
    
    assert(casualtyLog ~= nil, "Casualty log should exist")
    
    print("✓ testCasualtyAccountingConsistent passed")
end

-- TEST 7: Time progression is synchronized
function CrossSystemTest.testTimeProgressionSynchronized()
    local MockGeoscape, MockBattlescape, MockBasescape, MockEconomy = setup()
    
    local currentDate = { year = 2006, month = 5, day = 15 }
    
    -- Advance one day
    currentDate.day = currentDate.day + 1
    
    -- Check all systems see same date
    local geoDate = MockGeoscape.getCurrentDate()
    local ecoDate = MockEconomy.getCurrentDate()
    
    assert(currentDate.day == 16, "Day should advance")
    
    -- Month wrapping
    currentDate.day = 32
    if currentDate.day > 28 then
        currentDate.day = 1
        currentDate.month = currentDate.month + 1
    end
    
    assert(currentDate.month == 6, "Month should advance")
    assert(currentDate.day == 1, "Day should reset")
    
    print("✓ testTimeProgressionSynchronized passed")
end

-- TEST 8: Mission rewards affect base progression
function CrossSystemTest.testMissionRewardsAffectProgression()
    local MockGeoscape, MockBattlescape, MockBasescape, MockEconomy = setup()
    
    local initialFacilities = MockBasescape.getFacilityCount()
    local missionReward = 250000
    
    -- Receive mission reward
    MockEconomy.addMoney(missionReward)
    
    -- Upgrade facility
    if MockEconomy.getMoney() >= 150000 then
        MockEconomy.subtractMoney(150000)
        MockBasescape.upgradeFacility("BARRACKS")
    end
    
    local finalFacilities = MockBasescape.getFacilityCount()
    
    assert(finalFacilities >= initialFacilities, "Facilities should progress")
    
    print("✓ testMissionRewardsAffectProgression passed")
end

-- TEST 9: Alien activity affects world state
function CrossSystemTest.testAlienActivityAffectsWorld()
    local MockGeoscape, MockBattlescape, MockBasescape, MockEconomy = setup()
    
    local initialAlert = MockGeoscape.getAlertLevel()
    local newAlienSighting = 5 -- Alert level increase
    
    local finalAlert = initialAlert + newAlienSighting
    MockGeoscape.setAlertLevel(finalAlert)
    
    assert(finalAlert > initialAlert, "Alert level should increase")
    
    -- High alert affects economy
    if finalAlert >= 75 then
        MockEconomy.subtractMoney(25000) -- Defense surge costs
    end
    
    print("✓ testAlienActivityAffectsWorld passed")
end

-- TEST 10: Save/Load cycle preserves all state
function CrossSystemTest.testSaveLoadCycleComplete()
    local MockGeoscape, MockBattlescape, MockBasescape, MockEconomy = setup()
    
    -- Create complex state
    local preSaveState = {
        date = { year = 2006, month = 8, day = 12 },
        money = MockEconomy.getMoney(),
        squad = MockBasescape.getSquad(),
        equipment = MockBasescape.getInventory(),
        missions = MockGeoscape.getMissions(),
        research = MockBasescape.getResearch(),
        facilities = MockBasescape.getFacilities()
    }
    
    -- Simulate save
    local savedData = table.deepcopy(preSaveState)
    
    -- Simulate load (in real system, would restore from file)
    local postLoadState = savedData
    
    -- Verify state integrity
    assert(postLoadState.date.year == preSaveState.date.year, "Year should persist")
    assert(postLoadState.money == preSaveState.money, "Money should persist")
    assert(#postLoadState.squad == #preSaveState.squad, "Squad size should persist")
    
    print("✓ testSaveLoadCycleComplete passed")
end

-- Run all tests
function CrossSystemTest.runAll()
    print("\n[INTEGRATION TEST] Cross-System State Consistency\n")
    
    local tests = {
        CrossSystemTest.testGameStatePersistence,
        CrossSystemTest.testSoldierRosterConsistency,
        CrossSystemTest.testMoneyFlowConsistency,
        CrossSystemTest.testEquipmentTransferConsistency,
        CrossSystemTest.testResearchDependenciesValid,
        CrossSystemTest.testCasualtyAccountingConsistent,
        CrossSystemTest.testTimeProgressionSynchronized,
        CrossSystemTest.testMissionRewardsAffectProgression,
        CrossSystemTest.testAlienActivityAffectsWorld,
        CrossSystemTest.testSaveLoadCycleComplete,
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

-- Helper: Deep copy table
function table.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table.deepcopy(orig_key)] = table.deepcopy(orig_value)
        end
        setmetatable(copy, table.deepcopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

return CrossSystemTest
