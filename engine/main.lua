-- luacheck: ignore
---@diagnostic disable = undefined-global
---@diagnostic disable = inject-field
---@diagnostic disable = param-type-mismatch
---@diagnostic disable = assign-type-mismatch
---@diagnostic disable = duplicate-set-field
---Alien Fall - Main Entry Point
---
---Main game initialization and Love2D callback routing for Alien Fall, a turn-based
---strategy game inspired by UFO: Enemy Unknown (X-COM). This module loads all game
---systems, registers game states, and routes Love2D callbacks to the active state.
---
---Key Exports:
---  - love.load(): Initializes engine, loads assets, registers states
---  - love.update(dt): Updates active game state every frame
---  - love.draw(): Renders active state and debug overlays
---  - love.keypressed(): Routes keyboard input (Esc=quit, F9=grid, F12=fullscreen)
---  - love.mousepressed/released/moved(): Routes mouse input to active state
---  - love.wheelmoved(): Routes mouse wheel input to active state
---  - love.resize(): Handles window resizing and viewport recalculation
---  - love.errorhandler(): Custom error screen with stack trace
---
---Game States:
---  - menu: Main menu and navigation
---  - geoscape: Strategic world map (missions, UFO tracking)
---  - battlescape: Tactical combat (turn-based squad combat)
---  - basescape: Base management (facilities, research, manufacturing)
---  - tests_menu: Unit and integration test runner
---  - widget_showcase: UI component demonstration
---  - map_editor: Tactical map creation tool
---
---Dependencies:
---  - mods.mod_manager: Content loading and mod system (loaded FIRST)
---  - core.state_manager: Game state/screen management
---  - core.assets: Graphics, audio, and data asset loading
---  - core.data_loader: TOML configuration file loading
---  - widgets.init: UI widget system with 24×24 grid
---  - utils.viewport: Dynamic resolution and fullscreen support
---  - scenes.*: All game screen implementations
---
---@module main
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  -- Run game with Love2D console enabled:
---  lovec engine
---  
---  -- Global hotkeys:
---  -- Escape: Quit game
---  -- F9: Toggle grid overlay
---  -- F12: Toggle fullscreen
---
---@see core.state_manager For state management system
---@see widgets.init For UI widget framework
---@see mods.mod_manager For content loading

-- Load mod manager FIRST (required for all content loading)
local ModManager = require("mods.mod_manager")

-- Load state manager
local StateManager = require("core.state_manager")

-- Load game modules
print("[Main] Loading Menu...")
local Menu = require("gui.scenes.main_menu")
print("[Main] Loading Geoscape...")
local Geoscape = require("gui.scenes.geoscape_screen")

print("[Main] Loading Battlescape...")
local Battlescape
local success, err = pcall(function()
    Battlescape = require("gui.scenes.battlescape_screen")
end)
if not success then
    print("[ERROR] Failed to load Battlescape: " .. tostring(err))
    Battlescape = nil
else
    print("[Main] Battlescape loaded successfully")
end

print("[Main] Loading Basescape...")
local Basescape = require("gui.scenes.basescape_screen")

print("[Main] Loading Tests Menu...")
local TestsMenu = require("gui.scenes.tests_menu")

print("[Main] Loading Widget Showcase...")
local WidgetShowcase = require("gui.scenes.widget_showcase")

print("[Main] Loading Map Editor...")
local MapEditor = require("battlescape.ui.map_editor")

-- Load widgets system
local Widgets = require("gui.widgets.init")

-- Load asset system
local Assets = require("core.assets")

-- Load data loader system
local DataLoader = require("core.data_loader")

-- Load viewport system for dynamic resolution
local Viewport = require("utils.viewport")

-- Game initialization
function love.load()
    print("===========================================")
    print("Alien Fall - Starting Up")
    print("Love2D Version: " .. love.getVersion())
    print("===========================================")
    
    -- Set up resizable window
    love.window.setMode(960, 720, {
        fullscreen = false,
        borderless = false,
        resizable = true,  -- Enable dynamic resolution
        minwidth = 960,    -- Minimum 960�720 for GUI to fit
        minheight = 720,
        vsync = 1,
        msaa = 4
    })
    
    -- Print viewport information
    Viewport.printInfo()
    
    -- Set default font
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setFont(love.graphics.newFont(14))
    
    -- Set window properties
    love.window.setTitle("Alien Fall")
    
    -- Set window icon (icon must be ImageData format)
    local success, icon = pcall(function()
        return love.image.newImageData("icon.png")
    end)
    
    if success and icon then
        love.window.setIcon(icon)
        print("[Main] Window icon set successfully")
    else
        print("[Main] Warning: Could not load icon.png")
    end
    
    -- Initialize widgets system
    Widgets.init()
    
    -- Initialize mod system and set active mod
    ModManager.init()
    
    -- Load assets
    Assets.load()
    
    -- Load game data from TOML files
    DataLoader.load()
    
    -- Register all game states
    StateManager.register("menu", Menu)
    StateManager.register("geoscape", Geoscape)
    StateManager.register("battlescape", Battlescape)
    StateManager.register("basescape", Basescape)
    StateManager.register("tests_menu", TestsMenu)
    StateManager.register("widget_showcase", WidgetShowcase)
    StateManager.register("map_editor", MapEditor)
    
    -- Start with menu
    StateManager.switch("menu")
    
    print("[Main] Game initialized successfully")
end

-- Update game logic
function love.update(dt)
    -- Limit to 30 FPS (33.33ms per frame)
    local minFrameTime = 1/30
    if dt < minFrameTime then
        love.timer.sleep(minFrameTime - dt)
        dt = minFrameTime
    end
    
    StateManager.update(dt)
end

-- Draw game graphics
function love.draw()
    -- Draw game state (each state handles its own rendering)
    StateManager.draw()
    
    -- Draw widget debug overlay (grid, etc.)
    Widgets.drawDebug()
end

-- Keyboard input
function love.keypressed(key, scancode, isrepeat)
    -- Global quit handler
    if key == "escape" then
        love.event.quit()
    end
    
    -- F9: Toggle grid overlay (global)
    if key == "f9" then
        Widgets.keypressed(key)
        return
    end
    
    -- Toggle fullscreen with F12
    if key == "f12" then
        local isFullscreen = love.window.getFullscreen()
        if isFullscreen then
            -- Switch to windowed mode (960�720)
            love.window.setMode(960, 720, {
                fullscreen = false,
                borderless = false,
                resizable = true,
                minwidth = 960,
                minheight = 720,
                vsync = 1,
                msaa = 4
            })
            print("[Main] Switched to windowed mode (960�720)")
        else
            -- Switch to fullscreen mode (native desktop resolution)
            local desktopWidth, desktopHeight = love.window.getDesktopDimensions()
            love.window.setMode(desktopWidth, desktopHeight, {
                fullscreen = true,
                fullscreentype = "desktop",
                vsync = 1,
                msaa = 4
            })
            print(string.format("[Main] Switched to fullscreen (%d�%d)", desktopWidth, desktopHeight))
        end
        Viewport.printInfo()
    end
    
    StateManager.keypressed(key, scancode, isrepeat)
end

-- Mouse press
function love.mousepressed(x, y, button, istouch, presses)
    -- Mouse coordinates are already in correct space, states handle their own coordinate translation
    StateManager.mousepressed(x, y, button, istouch, presses)
end

-- Mouse release
function love.mousereleased(x, y, button, istouch, presses)
    -- Mouse coordinates are already in correct space, states handle their own coordinate translation
    StateManager.mousereleased(x, y, button, istouch, presses)
end

-- Mouse move
function love.mousemoved(x, y, dx, dy, istouch)
    -- Mouse coordinates are already in correct space, states handle their own coordinate translation
    StateManager.mousemoved(x, y, dx, dy, istouch)
end

-- Mouse wheel
function love.wheelmoved(x, y)
    StateManager.wheelmoved(x, y)
end

-- Window resize handler
function love.resize(w, h)
    print(string.format("[Main] Window resized to %d�%d", w, h))
    Viewport.printInfo()
end

-- Quit handler
function love.quit()
    print("[Main] Game shutting down")
    print("===========================================")
    return false -- Allow quit
end

-- Error handler
function love.errorhandler(msg)
    print("[ERROR] " .. msg)
    print(debug.traceback())
    
    -- Show error screen
    if not love.window or not love.graphics or not love.event then
        return
    end
    
    love.graphics.reset()
    local font = love.graphics.setNewFont(14)
    
    love.graphics.setBackgroundColor(0.1, 0, 0)
    
    local trace = debug.traceback()
    
    love.graphics.origin()
    
    local function draw()
        love.graphics.clear(0.1, 0, 0)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(
            "An error has occurred:\n\n" .. msg .. "\n\n" .. trace,
            70,
            70,
            love.graphics.getWidth() - 140
        )
        love.graphics.printf(
            "Press Escape to quit",
            0,
            love.graphics.getHeight() - 30,
            love.graphics.getWidth(),
            "center"
        )
    end
    
    return function()
        love.event.pump()
        
        for e, a, b, c in love.event.poll() do
            if e == "quit" then
                return 1
            elseif e == "keypressed" and a == "escape" then
                return 1
            end
        end
        
        draw()
        
        love.graphics.present()
        love.timer.sleep(0.1)
    end
end

























