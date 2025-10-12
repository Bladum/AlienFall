-- Alien Fall - Main Entry Point
-- A simplified turn-based strategy game inspired by UFO: Enemy Unknown

-- Load mod manager FIRST (required for all content loading)
local ModManager = require("systems.mod_manager")

-- Load state manager
local StateManager = require("systems.state_manager")

-- Load game modules
print("[Main] Loading Menu...")
local Menu = require("modules.menu")
print("[Main] Loading Geoscape...")
local Geoscape = require("modules.geoscape.init")

print("[Main] Loading Battlescape...")
local Battlescape
local success, err = pcall(function()
    Battlescape = require("modules.battlescape.init")
end)
if not success then
    print("[ERROR] Failed to load Battlescape: " .. tostring(err))
    Battlescape = nil
else
    print("[Main] Battlescape loaded successfully")
end

print("[Main] Loading Basescape...")
local Basescape = require("modules.basescape")

print("[Main] Loading Tests Menu...")
local TestsMenu = require("modules.tests_menu")

print("[Main] Loading Widget Showcase...")
local WidgetShowcase = require("modules.widget_showcase")

print("[Main] Loading Map Editor...")
local MapEditor = require("modules.map_editor")

-- Load widgets system
local Widgets = require("widgets.init")

-- Load asset system
local Assets = require("systems.assets")

-- Load data loader system
local DataLoader = require("systems.data_loader")

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
        minwidth = 960,    -- Minimum 960×720 for GUI to fit
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
            -- Switch to windowed mode (960×720)
            love.window.setMode(960, 720, {
                fullscreen = false,
                borderless = false,
                resizable = true,
                minwidth = 960,
                minheight = 720,
                vsync = 1,
                msaa = 4
            })
            print("[Main] Switched to windowed mode (960×720)")
        else
            -- Switch to fullscreen mode (native desktop resolution)
            local desktopWidth, desktopHeight = love.window.getDesktopDimensions()
            love.window.setMode(desktopWidth, desktopHeight, {
                fullscreen = true,
                fullscreentype = "desktop",
                vsync = 1,
                msaa = 4
            })
            print(string.format("[Main] Switched to fullscreen (%d×%d)", desktopWidth, desktopHeight))
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
    print(string.format("[Main] Window resized to %d×%d", w, h))
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
