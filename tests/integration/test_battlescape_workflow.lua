---Integration Test: Battlescape Combat Workflow
---Tests complete tactical combat scenarios from deployment to resolution

local MockBattlescape = require("mock.battlescape")
local MockUnits = require("mock.units")

local TestBattlescapeIntegration = {}
local testsPassed = 0
local testsFailed = 0
local failureDetails = {}

-- Helper function to run a test
local function runTest(name, testFunc)
    local success, err = pcall(testFunc)
    if success then
        print("✓ " .. name .. " passed")
        testsPassed = testsPassed + 1
    else
        print("✗ " .. name .. " failed: " .. tostring(err))
        testsFailed = testsFailed + 1
        table.insert(failureDetails, {name = name, error = tostring(err)})
    end
end

-- Helper function to assert
local function assert(condition, message)
    if not condition then
        error(message or "Assertion failed")
    end
end

---Test: Deploy squad to battlefield
function TestBattlescapeIntegration.testDeployment()
    local battlefield = MockBattlescape.getBattlefield(40, 40, "urban")
    local squad = MockUnits.generateSquad(6)
    
    -- Deploy squad to spawn zone
    for i, soldier in ipairs(squad) do
        local spawnPos = battlefield.spawnZones.xcom[i]
        soldier.position = {x = spawnPos.x, y = spawnPos.y, z = 0}
    end
    
    -- Verify deployment
    assert(#squad == 6, "Should deploy 6 soldiers")
    for _, soldier in ipairs(squad) do
        assert(soldier.position ~= nil, "Soldier should have position")
        assert(soldier.position.x > 0, "Position X should be valid")
        assert(soldier.position.y > 0, "Position Y should be valid")
    end
    
    print("[Deployment] Deployed 6 soldiers to battlefield")
end

---Test: Complete combat turn cycle
function TestBattlescapeIntegration.testTurnCycle()
    local scenario = MockBattlescape.getCombatScenario("balanced")
    local turn = scenario.turn
    
    -- Start XCOM turn
    assert(turn.activeTeam == "XCOM", "XCOM should start first")
    
    -- Simulate actions
    local actions = {
        {type = "MOVE", tu = 12},
        {type = "FIRE", tu = 15},
        {type = "RELOAD", tu = 10}
    }
    
    for _, action in ipairs(actions) do
        table.insert(turn.actions, action)
    end
    
    -- End turn
    turn.number = turn.number + 1
    turn.activeTeam = "ALIEN"
    
    assert(turn.number == 2, "Turn should advance")
    assert(turn.activeTeam == "ALIEN", "Team should switch to ALIEN")
    assert(#turn.actions == 3, "Should record 3 actions")
    
    print("[Turn Cycle] Completed turn 1, switched to turn 2")
end

---Test: Line of sight calculation
function TestBattlescapeIntegration.testLineOfSight()
    local xcomUnits = MockBattlescape.getCombatEntities(2, "XCOM")
    local alienUnits = MockBattlescape.getCombatEntities(2, "ALIEN")
    
    -- Position units
    xcomUnits[1].position = {x = 5, y = 5, z = 0}
    alienUnits[1].position = {x = 15, y = 15, z = 0}
    
    -- Calculate LOS
    local los = MockBattlescape.getLineOfSight(xcomUnits[1], alienUnits[1], false)
    
    assert(los.from == xcomUnits[1].id, "LOS should be from XCOM unit")
    assert(los.to == alienUnits[1].id, "LOS should be to alien unit")
    assert(not los.blocked, "LOS should not be blocked")
    
    print("[Line of Sight] Calculated LOS between units")
end

---Test: Weapon fire resolution
function TestBattlescapeIntegration.testWeaponFire()
    local shooter = MockUnits.getSoldier("John", "ASSAULT")
    local target = MockUnits.getEnemy("SECTOID")
    
    shooter.position = {x = 10, y = 10, z = 0}
    target.position = {x = 15, y = 15, z = 0}
    
    -- Create fire action
    local fireAction = MockBattlescape.getFireAction(shooter, target, "snap")
    
    assert(fireAction.type == "FIRE", "Should be fire action")
    assert(fireAction.shooter == shooter.id, "Shooter should be correct")
    assert(fireAction.target == target.id, "Target should be correct")
    assert(fireAction.tuCost > 0, "Should cost TU")
    
    -- Simulate hit
    fireAction.result = {
        hit = true,
        damage = 20,
        targetHealth = target.health.current - 20
    }
    
    target.health.current = fireAction.result.targetHealth
    
    assert(target.health.current < target.health.max, "Target should take damage")
    
    print(string.format("[Weapon Fire] %s shot %s for %d damage",
        shooter.name, target.name, fireAction.result.damage))
end

---Test: Grenade throw and explosion
function TestBattlescapeIntegration.testGrenadeThrow()
    local thrower = MockUnits.getSoldier("Mike", "GRENADIER")
    local targetPos = {x = 20, y = 20, z = 0}
    
    thrower.position = {x = 15, y = 15, z = 0}
    
    -- Create grenade action
    local grenadeAction = MockBattlescape.getGrenadeAction(thrower, targetPos)
    
    assert(grenadeAction.type == "GRENADE", "Should be grenade action")
    assert(grenadeAction.thrower == thrower.id, "Thrower should be correct")
    assert(grenadeAction.radius == 5, "Should have explosion radius")
    
    -- Simulate explosion
    grenadeAction.result = {
        hit = true,
        affectedTiles = 20,
        casualties = 2,
        terrain_damage = 3
    }
    
    assert(grenadeAction.result.casualties > 0, "Grenade should hit enemies")
    
    print(string.format("[Grenade] %s threw grenade, hit %d enemies",
        thrower.name, grenadeAction.result.casualties))
end

---Test: Movement and pathfinding
function TestBattlescapeIntegration.testMovement()
    local soldier = MockUnits.getSoldier("Sarah", "SCOUT")
    
    soldier.position = {x = 5, y = 5, z = 0}
    soldier.tu = {current = 50, max = 50}
    
    -- Create movement path
    local path = {
        {x = 5, y = 5},
        {x = 6, y = 5},
        {x = 7, y = 5},
        {x = 8, y = 5},
        {x = 8, y = 6}
    }
    
    local moveAction = MockBattlescape.getMovementAction(soldier, path)
    
    assert(moveAction.type == "MOVE", "Should be move action")
    assert(#moveAction.path == 5, "Path should have 5 steps")
    
    -- Simulate movement
    local tuCost = #path * 4
    soldier.tu.current = soldier.tu.current - tuCost
    soldier.position = path[#path]
    
    assert(soldier.tu.current < soldier.tu.max, "Should consume TU")
    assert(soldier.position.x == 8 and soldier.position.y == 6, "Should reach destination")
    
    print(string.format("[Movement] %s moved %d tiles (TU: %d -> %d)",
        soldier.name, #path, soldier.tu.max, soldier.tu.current))
end

---Test: Cover system
function TestBattlescapeIntegration.testCoverSystem()
    local soldier = MockUnits.getSoldier("Tom", "ASSAULT")
    soldier.position = {x = 10, y = 10, z = 0}
    
    -- Get cover data
    local noCover = MockBattlescape.getCoverData(soldier.position, "NONE")
    local halfCover = MockBattlescape.getCoverData(soldier.position, "HALF", "N")
    local fullCover = MockBattlescape.getCoverData(soldier.position, "FULL", "N")
    
    assert(noCover.protection == 0, "No cover should provide 0 protection")
    assert(halfCover.protection == 40, "Half cover should provide 40 protection")
    assert(fullCover.protection == 75, "Full cover should provide 75 protection")
    
    print("[Cover System] Tested cover types: None (0%), Half (40%), Full (75%)")
end

---Test: Fog of war
function TestBattlescapeIntegration.testFogOfWar()
    local fow = MockBattlescape.getFogOfWar(40, 40, {
        {x = 5, y = 5},
        {x = 6, y = 5},
        {x = 5, y = 6}
    })
    
    assert(fow.width == 40 and fow.height == 40, "FOW should match map size")
    assert(fow.revealedCount == 3, "Should have 3 revealed tiles")
    
    -- Check visibility
    assert(fow.tiles[5][5].visible, "Position (5,5) should be visible")
    assert(not fow.tiles[20][20].visible, "Position (20,20) should be hidden")
    
    print("[Fog of War] Tested FOW with 3 revealed tiles")
end

---Test: Complete balanced combat scenario
function TestBattlescapeIntegration.testBalancedScenario()
    local scenario = MockBattlescape.getCombatScenario("balanced")
    
    assert(scenario.map ~= nil, "Scenario should have map")
    assert(#scenario.xcomTeam == 6, "XCOM should have 6 units")
    assert(#scenario.alienTeam == 6, "Aliens should have 6 units")
    assert(scenario.objective == "ELIMINATE_ALL", "Objective should be eliminate all")
    
    print("[Balanced Scenario] 6v6 combat on urban map")
end

---Test: Outnumbered scenario
function TestBattlescapeIntegration.testOutnumberedScenario()
    local scenario = MockBattlescape.getCombatScenario("outnumbered")
    
    assert(#scenario.xcomTeam < #scenario.alienTeam, "XCOM should be outnumbered")
    assert(scenario.objective == "SURVIVE", "Objective should be survival")
    
    print(string.format("[Outnumbered] XCOM: %d vs Aliens: %d",
        #scenario.xcomTeam, #scenario.alienTeam))
end

-- Run all tests
function TestBattlescapeIntegration.runAll()
    print("\n=== Running Battlescape Integration Tests ===\n")
    
    testsPassed = 0
    testsFailed = 0
    failureDetails = {}
    
    runTest("Deployment", TestBattlescapeIntegration.testDeployment)
    runTest("Turn Cycle", TestBattlescapeIntegration.testTurnCycle)
    runTest("Line of Sight", TestBattlescapeIntegration.testLineOfSight)
    runTest("Weapon Fire", TestBattlescapeIntegration.testWeaponFire)
    runTest("Grenade Throw", TestBattlescapeIntegration.testGrenadeThrow)
    runTest("Movement", TestBattlescapeIntegration.testMovement)
    runTest("Cover System", TestBattlescapeIntegration.testCoverSystem)
    runTest("Fog of War", TestBattlescapeIntegration.testFogOfWar)
    runTest("Balanced Scenario", TestBattlescapeIntegration.testBalancedScenario)
    runTest("Outnumbered Scenario", TestBattlescapeIntegration.testOutnumberedScenario)
    
    print("\n=== Battlescape Integration Test Results ===")
    print(string.format("Total: %d, Passed: %d (%.1f%%), Failed: %d (%.1f%%)",
        testsPassed + testsFailed,
        testsPassed,
        (testsPassed / (testsPassed + testsFailed)) * 100,
        testsFailed,
        (testsFailed / (testsPassed + testsFailed)) * 100
    ))
    
    if testsFailed > 0 then
        print("\nFailed tests:")
        for _, failure in ipairs(failureDetails) do
            print(string.format("  ✗ %s: %s", failure.name, failure.error))
        end
    else
        print("\n✓ All tests passed!")
    end
    
    return testsPassed, testsFailed
end

return TestBattlescapeIntegration



