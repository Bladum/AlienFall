---@diagnostic disable: lowercase-global
-- 3D Tactical Combat Game - Main Entry Point
-- A modular, class-based tactical game with team visibility and physics

-- Load G3D library (copy from old project)
local g3d = require("g3d.g3d")

-- Load configuration
local Constants = require("config.constants")
local Colors = require("config.colors")

-- Load core classes
local Tile = require("classes.Tile")
local Team = require("classes.Team")
local Unit = require("classes.Unit")

-- Load systems
local MapLoader = require("systems.MapLoader")
local VisibilitySystem = require("systems.VisibilitySystem")
local Renderer3D = require("systems.Renderer3D")
local InputHandler = require("systems.InputHandler")
local Minimap = require("systems.Minimap")

-- Game state
local game = {
    initialized = false,
    map = nil,
    teams = {},
    currentTeam = nil,
    camera = nil,
    dt = 0,
    time = 0,
    selectedUnit = nil,
    showMinimap = true,
    minimapScale = 1.0
}

function love.load()
    print("=== 3D Tactical Combat Game ===")
    print("Initializing...")
    
    -- Set up graphics
    love.window.setMode(1280, 720, {resizable=true, vsync=true, depth=true})
    love.window.setTitle("3D Tactical Combat Game")
    love.graphics.setDepthMode("lequal", true)
    
    -- Initialize G3D camera - will be positioned by InputHandler for first-person view
    g3d.camera.position = {0, 1.7, 0}  -- Start at origin, eye level
    g3d.camera.target = {0, 1.7, 1}    -- Look forward
    g3d.camera.up = {0, 1, 0}
    g3d.camera:updateViewMatrix()
    g3d.camera.fov = Constants.CAMERA_FOV
    g3d.camera.nearClip = Constants.CAMERA_NEAR
    g3d.camera.farClip = Constants.CAMERA_FAR
    
    -- Create teams
    game.teams[Constants.TEAM.PLAYER] = Team.new(Constants.TEAM.PLAYER, "Player")
    game.teams[Constants.TEAM.ALLY] = Team.new(Constants.TEAM.ALLY, "Ally")
    game.teams[Constants.TEAM.ENEMY] = Team.new(Constants.TEAM.ENEMY, "Enemy")
    game.teams[Constants.TEAM.NEUTRAL] = Team.new(Constants.TEAM.NEUTRAL, "Neutral")
    
    game.currentTeam = game.teams[Constants.TEAM.PLAYER]
    
    -- Load map from PNG or generate test map
    print("Loading map...")
    local mapFilename = "assets/maps/maze_map.png"
    local playerStarts
    
    game.map, playerStarts = MapLoader.loadFromPNG(
        mapFilename,
        Constants.GRID_SIZE,
        Constants.GRID_SIZE
    )
    
    if not game.map then
        print("Failed to load PNG, generating test map...")
        game.map, playerStarts = MapLoader.generateTestMap(
            Constants.GRID_SIZE,
            Constants.GRID_SIZE
        )
    end
    
    -- Spawn units at designated positions
    print("Spawning units...")
    -- Always create 10 player and 10 enemy units in grid patterns
    print("Creating 10 player and 10 enemy units...")
    
    -- Player units in bottom-left area
    for i = 1, 10 do
        local x = 10 + (i % 5) * 3  -- 5 columns
        local y = 10 + math.floor((i-1) / 5) * 3  -- 2 rows
        local unit = Unit.new(x, y, Constants.TEAM.PLAYER)
        unit.tileX = x  -- Track current tile
        unit.tileY = y
        unit.facing = 0  -- Initialize facing direction
        game.teams[Constants.TEAM.PLAYER]:addUnit(unit)
        if game.map.tiles[y] and game.map.tiles[y][x] then
            game.map.tiles[y][x]:setOccupant(unit)
        end
    end
    
    -- Enemy units in top-right area
    for i = 1, 10 do
        local x = 40 + (i % 5) * 3  -- 5 columns
        local y = 40 + math.floor((i-1) / 5) * 3  -- 2 rows
        local unit = Unit.new(x, y, Constants.TEAM.ENEMY)
        unit.tileX = x  -- Track current tile
        unit.tileY = y
        unit.facing = math.pi  -- Face opposite direction
        game.teams[Constants.TEAM.ENEMY]:addUnit(unit)
        if game.map.tiles[y] and game.map.tiles[y][x] then
            game.map.tiles[y][x]:setOccupant(unit)
        end
    end
    
    print(string.format("Created %d teams with units:", #game.teams))
    for _, team in pairs(game.teams) do
        print(string.format("  %s: %d units", team.name, team:getUnitCount()))
        -- Debug: list unit positions
        for i, unit in ipairs(team.units) do
            print(string.format("    Unit %d: (%d, %d)", i, unit.gridX, unit.gridY))
        end
    end
    
    -- Calculate initial visibility for all teams
    print("Calculating initial visibility...")
    VisibilitySystem.updateAllTeams(
        game.teams,
        game.map.tiles,
        game.map.width,
        game.map.height,
        false  -- Show debug output
    )
    
    -- Initialize input handler and minimap
    InputHandler.init()
    Minimap.init(game.map.width, game.map.height)
    
    -- Select first unit
    local playerTeam = game.teams[Constants.TEAM.PLAYER]
    if playerTeam and #playerTeam.units > 0 then
        game.selectedUnit = playerTeam.units[1]
    end
    
    -- Initialize renderer (loads textures and creates models)
    Renderer3D.init()
    
    game.initialized = true
    print("=== Initialization Complete ===")
    print("\nControls:")
    print("  WASD/Arrows - Move selected unit")
    print("  Q/E - Rotate selected unit")
    print("  SPACE - Switch to next unit")
    print("  M - Toggle minimap")
    print("  ESC - Quit")
end

function love.update(dt)
    if not game.initialized then return end
    
    game.dt = dt
    game.time = game.time + dt
    
    -- Update input handler (handles unit movement and camera)
    InputHandler.update(dt, g3d.camera, game)
    
    -- Update all teams
    for _, team in pairs(game.teams) do
        team:update(dt)
    end
    
    -- Update all tiles
    for y = 1, game.map.height do
        for x = 1, game.map.width do
            game.map.tiles[y][x]:update(dt)
        end
    end
    
    -- Recalculate visibility (optimized - only update periodically)
    if game.time < 0.1 or (game.time % 0.5 < dt) then  -- Update on first frame and twice per second
        VisibilitySystem.updateAllTeams(
            game.teams,
            game.map.tiles,
            game.map.width,
            game.map.height,
            game.time > 0.1  -- Silent mode after first update
        )
    end
end

function love.draw()
    if not game.initialized then
        love.graphics.print("Loading...", 10, 10)
        return
    end
    
    -- Render sky
    Renderer3D.renderSky()
    
    -- Render 3D world
    Renderer3D.render(
        game.map,
        game.teams,
        Constants.TEAM.PLAYER,  -- Player team for visibility
        game.map.width,
        game.map.height
    )
    
    -- Render 2D UI overlay
    Renderer3D.renderUI(game.selectedUnit, game.teams[Constants.TEAM.PLAYER])
    
    -- Render minimap
    Minimap.render(game)
end

function love.keypressed(key)
    InputHandler.keypressed(key, game)
end

function love.mousepressed(x, y, button)
    InputHandler.mousepressed(x, y, button, game)
end

function love.mousereleased(x, y, button)
    InputHandler.mousereleased(x, y, button, game)
end

function love.mousemoved(x, y, dx, dy)
    InputHandler.mousemoved(x, y, dx, dy, g3d.camera)
end

function love.wheelmoved(x, y)
    InputHandler.wheelmoved(x, y, g3d.camera)
end

function love.resize(w, h)
    -- Update camera projection
    g3d.camera.aspectRatio = w / h
    g3d.camera:updateProjectionMatrix()
end
