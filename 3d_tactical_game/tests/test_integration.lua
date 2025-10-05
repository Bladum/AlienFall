--- Integration test for complete game scenario
--- Tests full game flow from initialization to gameplay

local MapLoader = require("systems.MapLoader")
local Team = require("classes.Team")
local Unit = require("classes.Unit")
local VisibilitySystem = require("systems.VisibilitySystem")
local Constants = require("config.constants")

local TestIntegration = {}

function TestIntegration.testFullGameSetup()
    print("Testing full game setup...")
    
    -- Create map
    local map, spawnPoints = MapLoader.generateTestMap(40, 40)
    assert(map, "Map should be created")
    
    -- Create teams
    local teams = {}
    teams[Constants.TEAM.PLAYER] = Team.new(Constants.TEAM.PLAYER, "Player")
    teams[Constants.TEAM.ENEMY] = Team.new(Constants.TEAM.ENEMY, "Enemy")
    
    -- Add units
    for i = 1, 5 do
        local playerUnit = Unit.new(5 + i, 5, Constants.TEAM.PLAYER)
        teams[Constants.TEAM.PLAYER]:addUnit(playerUnit)
        
        local enemyUnit = Unit.new(35 - i, 35, Constants.TEAM.ENEMY)
        teams[Constants.TEAM.ENEMY]:addUnit(enemyUnit)
    end
    
    assert(teams[Constants.TEAM.PLAYER]:getUnitCount() == 5, "Player should have 5 units")
    assert(teams[Constants.TEAM.ENEMY]:getUnitCount() == 5, "Enemy should have 5 units")
    
    -- Calculate visibility
    VisibilitySystem.updateAllTeams(teams, map.tiles, map.width, map.height, true)
    
    -- Verify visibility was calculated
    local playerVisibleCount = 0
    for y = 1, map.height do
        for x = 1, map.width do
            if map.tiles[y][x]:isVisibleTo(Constants.TEAM.PLAYER) then
                playerVisibleCount = playerVisibleCount + 1
            end
        end
    end
    
    assert(playerVisibleCount > 0, "Player should see some tiles")
    
    print("  ✓ Full game setup works")
end

function TestIntegration.testGameLoop()
    print("Testing game loop simulation...")
    
    local map = MapLoader.generateTestMap(30, 30)
    local teams = {}
    teams[Constants.TEAM.PLAYER] = Team.new(Constants.TEAM.PLAYER, "Player")
    
    local unit = Unit.new(15, 15, Constants.TEAM.PLAYER)
    teams[Constants.TEAM.PLAYER]:addUnit(unit)
    
    -- Simulate 10 frames
    for frame = 1, 10 do
        local dt = 0.016  -- ~60 FPS
        
        -- Update teams
        for _, team in pairs(teams) do
            team:update(dt)
        end
        
        -- Update tiles
        for y = 1, map.height do
            for x = 1, map.width do
                map.tiles[y][x]:update(dt)
            end
        end
        
        -- Update visibility every 5 frames
        if frame % 5 == 0 then
            VisibilitySystem.updateAllTeams(teams, map.tiles, map.width, map.height, true)
        end
    end
    
    assert(unit:isAlive(), "Unit should survive game loop")
    
    print("  ✓ Game loop simulation works")
end

function TestIntegration.testCombatScenario()
    print("Testing combat scenario...")
    
    local map = MapLoader.generateTestMap(20, 20)
    
    local playerUnit = Unit.new(5, 5, Constants.TEAM.PLAYER)
    local enemyUnit = Unit.new(6, 6, Constants.TEAM.ENEMY)
    
    -- Test if units can see each other
    local canSee = VisibilitySystem.canSeeUnit(playerUnit, enemyUnit, map.tiles)
    print(string.format("  Player can see enemy: %s", tostring(canSee)))
    
    -- Simulate damage
    local initialHealth = enemyUnit.health
    enemyUnit:takeDamage(30)
    assert(enemyUnit.health < initialHealth, "Enemy should take damage")
    
    -- Check if enemy is still alive
    if enemyUnit:isAlive() then
        print("  Enemy survived attack")
    else
        print("  Enemy was eliminated")
    end
    
    print("  ✓ Combat scenario works")
end

function TestIntegration.testMultiTeamVisibility()
    print("Testing multi-team visibility...")
    
    local map = MapLoader.generateTestMap(50, 50)
    local teams = {}
    
    -- Create 3 teams in different corners
    teams[Constants.TEAM.PLAYER] = Team.new(Constants.TEAM.PLAYER, "Player")
    teams[Constants.TEAM.ENEMY] = Team.new(Constants.TEAM.ENEMY, "Enemy")
    teams[Constants.TEAM.ALLY] = Team.new(Constants.TEAM.ALLY, "Ally")
    
    teams[Constants.TEAM.PLAYER]:addUnit(Unit.new(5, 5, Constants.TEAM.PLAYER))
    teams[Constants.TEAM.ENEMY]:addUnit(Unit.new(45, 45, Constants.TEAM.ENEMY))
    teams[Constants.TEAM.ALLY]:addUnit(Unit.new(5, 45, Constants.TEAM.ALLY))
    
    -- Calculate visibility for all teams
    VisibilitySystem.updateAllTeams(teams, map.tiles, map.width, map.height, true)
    
    -- Check that each team has different visibility
    local playerVisible = 0
    local enemyVisible = 0
    local allyVisible = 0
    
    for y = 1, map.height do
        for x = 1, map.width do
            if map.tiles[y][x]:isVisibleTo(Constants.TEAM.PLAYER) then
                playerVisible = playerVisible + 1
            end
            if map.tiles[y][x]:isVisibleTo(Constants.TEAM.ENEMY) then
                enemyVisible = enemyVisible + 1
            end
            if map.tiles[y][x]:isVisibleTo(Constants.TEAM.ALLY) then
                allyVisible = allyVisible + 1
            end
        end
    end
    
    assert(playerVisible > 0, "Player should see tiles")
    assert(enemyVisible > 0, "Enemy should see tiles")
    assert(allyVisible > 0, "Ally should see tiles")
    
    print(string.format("  Player sees: %d tiles", playerVisible))
    print(string.format("  Enemy sees: %d tiles", enemyVisible))
    print(string.format("  Ally sees: %d tiles", allyVisible))
    
    print("  ✓ Multi-team visibility works")
end

function TestIntegration.testUnitMovementScenario()
    print("Testing unit movement scenario...")
    
    local map = MapLoader.generateTestMap(25, 25)
    local unit = Unit.new(12, 12, Constants.TEAM.PLAYER)
    unit.tileX = 12
    unit.tileY = 12
    unit.facing = 0
    
    -- Mark initial tile as occupied
    map.tiles[12][12]:setOccupant(unit)
    
    local initialX = unit.gridX
    local initialY = unit.gridY
    
    -- Simulate movement over multiple frames
    for i = 1, 10 do
        -- Move unit slightly
        local moveX = 0.1
        local moveY = 0.1
        
        -- Check if target tile is walkable
        local targetX = math.floor(unit.gridX + moveX + 0.5)
        local targetY = math.floor(unit.gridY + moveY + 0.5)
        
        if targetX >= 1 and targetX <= map.width and
           targetY >= 1 and targetY <= map.height then
            local targetTile = map.tiles[targetY][targetX]
            
            if targetTile:isTraversable() and not targetTile:isOccupied() then
                -- Clear old tile
                map.tiles[unit.tileY][unit.tileX]:setOccupant(nil)
                
                -- Update position
                unit.gridX = unit.gridX + moveX
                unit.gridY = unit.gridY + moveY
                unit.tileX = targetX
                unit.tileY = targetY
                
                -- Set new tile
                map.tiles[targetY][targetX]:setOccupant(unit)
            end
        end
    end
    
    print(string.format("  Unit moved from (%.1f, %.1f) to (%.1f, %.1f)",
                       initialX, initialY, unit.gridX, unit.gridY))
    
    print("  ✓ Unit movement scenario works")
end

function TestIntegration.testTeamElimination()
    print("Testing team elimination...")
    
    local team = Team.new(Constants.TEAM.ENEMY, "Doomed")
    
    for i = 1, 3 do
        team:addUnit(Unit.new(i, i, Constants.TEAM.ENEMY))
    end
    
    assert(team:getUnitCount() == 3, "Should have 3 units")
    assert(#team:getAliveUnits() == 3, "All should be alive")
    
    -- Eliminate all units
    for _, unit in ipairs(team:getUnits()) do
        unit:takeDamage(unit.maxHealth)
    end
    
    assert(#team:getAliveUnits() == 0, "All units should be dead")
    
    print("  ✓ Team elimination works")
end

function TestIntegration.testFogOfWar()
    print("Testing fog of war...")
    
    local map = MapLoader.generateTestMap(40, 40)
    local team = Team.new(Constants.TEAM.PLAYER, "Player")
    local unit = Unit.new(20, 20, Constants.TEAM.PLAYER)
    team:addUnit(unit)
    
    -- First visibility calculation
    VisibilitySystem.calculateTeamVisibility(team, map.tiles, map.width, map.height)
    
    -- Count visible tiles
    local visibleCount = 0
    local exploredCount = 0
    for y = 1, map.height do
        for x = 1, map.width do
            local vis = map.tiles[y][x]:getVisibility(Constants.TEAM.PLAYER)
            if vis == Constants.VISIBILITY.VISIBLE then
                visibleCount = visibleCount + 1
            elseif vis == Constants.VISIBILITY.EXPLORED then
                exploredCount = exploredCount + 1
            end
        end
    end
    
    print(string.format("  Visible: %d, Explored: %d", visibleCount, exploredCount))
    
    -- Move unit to different location
    unit.gridX = 10
    unit.gridY = 10
    
    -- Recalculate visibility
    VisibilitySystem.calculateTeamVisibility(team, map.tiles, map.width, map.height)
    
    -- Old area should now be explored (fog of war)
    local tile_20_20 = map.tiles[20][20]
    assert(tile_20_20:getVisibility(Constants.TEAM.PLAYER) == Constants.VISIBILITY.EXPLORED,
           "Old area should be explored")
    
    -- New area should be visible
    local tile_10_10 = map.tiles[10][10]
    assert(tile_10_10:getVisibility(Constants.TEAM.PLAYER) == Constants.VISIBILITY.VISIBLE,
           "New area should be visible")
    
    print("  ✓ Fog of war works correctly")
end

function TestIntegration.runAll()
    print("\n=== Running Integration Tests ===")
    
    TestIntegration.testFullGameSetup()
    TestIntegration.testGameLoop()
    TestIntegration.testCombatScenario()
    TestIntegration.testMultiTeamVisibility()
    TestIntegration.testUnitMovementScenario()
    TestIntegration.testTeamElimination()
    TestIntegration.testFogOfWar()
    
    print("=== All Integration Tests Passed ✓ ===\n")
end

return TestIntegration
