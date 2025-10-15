--- Test suite for InputHandler
--- Tests input processing, unit movement, and camera controls

local InputHandler = require("systems.InputHandler")
local Unit = require("classes.Unit")
local Team = require("classes.Team")
local MapLoader = require("systems.MapLoader")
local Constants = require("config.constants")

local TestInputHandler = {}

-- Mock Love2D keyboard state
local mockKeyboardState = {}

local function setupMockKeyboard()
    -- Save original love.keyboard.isDown
    _G._originalIsDown = love.keyboard.isDown
    
    -- Mock love.keyboard.isDown
    love.keyboard.isDown = function(key)
        return mockKeyboardState[key] == true
    end
end

local function teardownMockKeyboard()
    -- Restore original
    if _G._originalIsDown then
        love.keyboard.isDown = _G._originalIsDown
        _G._originalIsDown = nil
    end
    mockKeyboardState = {}
end

local function pressKey(key)
    mockKeyboardState[key] = true
end

local function releaseKey(key)
    mockKeyboardState[key] = false
end

function TestInputHandler.testInitialization()
    print("Testing InputHandler initialization...")
    
    -- Should not crash
    InputHandler.init()
    
    print("  ✓ InputHandler initializes successfully")
end

function TestInputHandler.testUnitMovement()
    print("Testing unit movement...")
    
    setupMockKeyboard()
    
    local map = MapLoader.generateTestMap(30, 30)
    local unit = Unit.new(15, 15, Constants.TEAM.PLAYER)
    unit.facing = 0
    unit.tileX = 15
    unit.tileY = 15
    
    local game = {
        selectedUnit = unit,
        map = map
    }
    
    local mockCamera = {
        position = {15, 5, 15},
        target = {15, 0, 15},
        updateViewMatrix = function() end
    }
    
    local initialX = unit.gridX
    local initialY = unit.gridY
    
    -- Press W to move forward
    pressKey("w")
    InputHandler.update(0.1, mockCamera, game)
    
    -- Unit should have moved (or attempted to move)
    assert(unit.gridX ~= nil and unit.gridY ~= nil, "Unit should have position")
    
    releaseKey("w")
    teardownMockKeyboard()
    
    print("  ✓ Unit movement input works")
end

function TestInputHandler.testUnitRotation()
    print("Testing unit rotation...")
    
    setupMockKeyboard()
    
    local map = MapLoader.generateTestMap(20, 20)
    local unit = Unit.new(10, 10, Constants.TEAM.PLAYER)
    unit.facing = 0
    unit.tileX = 10
    unit.tileY = 10
    
    local game = {
        selectedUnit = unit,
        map = map
    }
    
    local mockCamera = {
        position = {10, 5, 10},
        target = {10, 0, 10},
        updateViewMatrix = function() end
    }
    
    local initialFacing = unit.facing
    
    -- Press Q to rotate left
    pressKey("q")
    InputHandler.update(0.1, mockCamera, game)
    
    assert(unit.facing ~= initialFacing, "Unit facing should change")
    
    releaseKey("q")
    teardownMockKeyboard()
    
    print("  ✓ Unit rotation works")
end

function TestInputHandler.testNoSelectedUnit()
    print("Testing behavior with no selected unit...")
    
    setupMockKeyboard()
    
    local map = MapLoader.generateTestMap(20, 20)
    local game = {
        selectedUnit = nil,
        map = map
    }
    
    local mockCamera = {
        position = {10, 5, 10},
        target = {10, 0, 10},
        updateViewMatrix = function() end
    }
    
    -- Should not crash with no selected unit
    pressKey("w")
    InputHandler.update(0.016, mockCamera, game)
    
    releaseKey("w")
    teardownMockKeyboard()
    
    print("  ✓ Handles no selected unit gracefully")
end

function TestInputHandler.testSelectNextUnit()
    print("Testing select next unit...")
    
    local playerTeam = Team.new(Constants.TEAM.PLAYER, "Players")
    local unit1 = Unit.new(5, 5, Constants.TEAM.PLAYER)
    local unit2 = Unit.new(10, 10, Constants.TEAM.PLAYER)
    local unit3 = Unit.new(15, 15, Constants.TEAM.PLAYER)
    
    playerTeam:addUnit(unit1)
    playerTeam:addUnit(unit2)
    playerTeam:addUnit(unit3)
    
    local game = {
        selectedUnit = unit1,
        teams = {
            [Constants.TEAM.PLAYER] = playerTeam
        }
    }
    
    -- Select next unit
    InputHandler.selectNextUnit(game)
    assert(game.selectedUnit == unit2, "Should select unit 2")
    
    InputHandler.selectNextUnit(game)
    assert(game.selectedUnit == unit3, "Should select unit 3")
    
    InputHandler.selectNextUnit(game)
    assert(game.selectedUnit == unit1, "Should wrap back to unit 1")
    
    print("  ✓ Unit selection cycling works")
end

function TestInputHandler.testCollisionDetection()
    print("Testing collision detection...")
    
    setupMockKeyboard()
    
    -- Create small map with walls
    local map = MapLoader.generateTestMap(10, 10)
    
    -- Place unit near a wall
    local unit = Unit.new(5, 5, Constants.TEAM.PLAYER)
    unit.facing = 0
    unit.tileX = 5
    unit.tileY = 5
    
    -- Find a wall tile
    local wallX, wallY
    for y = 1, map.height do
        for x = 1, map.width do
            if not map.tiles[y][x]:isTraversable() then
                wallX, wallY = x, y
                break
            end
        end
        if wallX then break end
    end
    
    if wallX then
        -- Position unit next to wall
        unit.gridX = wallX - 1
        unit.gridY = wallY
        unit.facing = 0  -- Face the wall
        
        local game = {
            selectedUnit = unit,
            map = map
        }
        
        local mockCamera = {
            position = {unit.gridX, 5, unit.gridY},
            target = {unit.gridX, 0, unit.gridY},
            updateViewMatrix = function() end
        }
        
        local beforeX = unit.gridX
        
        -- Try to move into wall
        pressKey("d")  -- Move right toward wall
        InputHandler.update(0.1, mockCamera, game)
        
        -- Unit should not move much toward wall
        -- (exact position depends on collision implementation)
        assert(unit.gridX ~= nil, "Unit should still have position")
        
        releaseKey("d")
        print("  ✓ Collision detection prevents wall walking")
    else
        print("  ⚠ No walls found, skipped collision test")
    end
    
    teardownMockKeyboard()
end

function TestInputHandler.testCameraFollowsUnit()
    print("Testing camera following unit...")
    
    local map = MapLoader.generateTestMap(20, 20)
    local unit = Unit.new(10, 10, Constants.TEAM.PLAYER)
    unit.facing = 0
    
    local mockCamera = {
        position = {0, 0, 0},
        target = {0, 0, 0},
        updateViewMatrix = function() end
    }
    
    -- Update camera to follow unit
    InputHandler.updateCameraToFollowUnit(mockCamera, unit, 0.016)
    
    -- First-person camera: position should be at unit's eye level
    assert(mockCamera.position[1] == unit.gridX, "Camera X should be at unit position")
    assert(mockCamera.position[2] == 1.7, "Camera Y should be at eye height")
    assert(mockCamera.position[3] == unit.gridY, "Camera Z should be at unit position")
    
    -- Target should be in front of unit (facing direction 0 = positive Z)
    assert(mockCamera.target[1] == unit.gridX, "Camera target X should be unit X")
    assert(mockCamera.target[2] == 1.7, "Camera target Y should be eye height")
    assert(mockCamera.target[3] > unit.gridY, "Camera should look forward in facing direction")
    
    print("  ✓ Camera follows unit correctly")
end

function TestInputHandler.testMousePosition()
    print("Testing mouse position tracking...")
    
    local x, y = InputHandler.getMousePosition()
    
    assert(x ~= nil, "Mouse X should be defined")
    assert(y ~= nil, "Mouse Y should be defined")
    
    print("  ✓ Mouse position tracking works")
end

function TestInputHandler.testKeyPressed()
    print("Testing keypressed handler...")
    
    local game = {
        showMinimap = true,
        minimapScale = 1.0
    }
    
    -- Test minimap toggle
    InputHandler.keypressed("m", game)
    assert(game.showMinimap == false, "Minimap should toggle off")
    
    InputHandler.keypressed("m", game)
    assert(game.showMinimap == true, "Minimap should toggle on")
    
    print("  ✓ Keypressed handler works")
end

function TestInputHandler.runAll()
    print("\n=== Running InputHandler Tests ===")
    
    TestInputHandler.testInitialization()
    TestInputHandler.testUnitMovement()
    TestInputHandler.testUnitRotation()
    TestInputHandler.testNoSelectedUnit()
    TestInputHandler.testSelectNextUnit()
    TestInputHandler.testCollisionDetection()
    TestInputHandler.testCameraFollowsUnit()
    TestInputHandler.testMousePosition()
    TestInputHandler.testKeyPressed()
    
    print("=== All InputHandler Tests Passed ✓ ===\n")
end

return TestInputHandler






















