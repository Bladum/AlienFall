--- Main application module for AlienFall.
--
-- This module serves as the entry point for the Love2D application, managing
-- the service registry, state stack, window scaling, and Love2D callbacks.
-- It coordinates between different game states and provides debug functionality.
--
-- @module main
-- @see ServiceRegistry
-- @see StateStack

---@diagnostic disable: duplicate-set-field

local ServiceRegistry = require "core.services.registry"
local StateStack = require "screens.state_stack"

local StateModules = {
    main_menu = require "screens.main_menu_state",
    geoscape = require "screens.geoscape_state",
    basescape = require "screens.basescape_state",
    interception = require "screens.interception_state",
    briefing = require "screens.briefing_state",
    battlescape = require "screens.battlescape_state",
    debriefing = require "screens.debriefing_state",
    load = require "screens.load_state",
    options = require "screens.options_state",
    credits = require "screens.credits_state",
    manufacturing = require "screens.manufacturing_state",
    research = require "screens.research_state",
    new_game = require "screens.new_game_state",
    test = require "screens.test_state"
}

--- Main application object managing the game lifecycle.
-- Handles Love2D callbacks, state management, scaling, and debug features.
-- @type App
local App = {
    registry = nil,
    stack = nil,
    internalWidth = 800,
    internalHeight = 600,
    scale = 1,
    offsetX = 0,
    offsetY = 0,
    -- Debug state
    debugEnabled = false,
    showGrid = false,
    fps = 0,
    frameTime = 0,
    fpsUpdateTimer = 0,
    -- Fixed timestep for deterministic physics
    fixedTimestep = 1/60,  -- 60 Hz physics update rate
    accumulator = 0,
    maxAccumulator = 0.25,  -- Maximum accumulation to prevent spiral of death
    interpolationAlpha = 0
}

--- Registers all game states with the state stack.
--
-- @param stack The StateStack instance to register states with
local function registerStates(stack)
    for name, module in pairs(StateModules) do
        stack:register(name, function(registry)
            return module.new(registry)
        end)
    end
end

--- Initializes the application and sets up core systems.
--
-- Configures Love2D settings, creates the service registry and state stack,
-- loads core mods, and pushes the initial main menu state.
function App:bootstrap()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("AlienFall Prototype")

    -- Check for test mode (set by command line arguments)
    if _G.TEST_MODE then
        self.testMode = true
        self.testWatch = _G.TEST_WATCH or false
        self.testFile = _G.TEST_FILE

        -- Run in minimal window mode for testing (Love2D doesn't support invisible windows)
        love.window.setMode(1, 1, {
            resizable = false,
            vsync = false,
            fullscreen = false
        })
        self:runTests()
        return
    end

    love.window.setMode(self.internalWidth, self.internalHeight, { resizable = true, vsync = true })

    self.registry = ServiceRegistry.new({ logLevel = "debug", telemetry = true })
    self.stack = StateStack.new({ registry = self.registry, logger = self.registry:logger() })
    registerStates(self.stack)

    self.registry:loadMods({ "example_mod" })
    self.stack:push("main_menu", {})
    
    -- Initialize debug console
    local Console = require "dev.Console"
    local ConsoleCommands = require "dev.ConsoleCommands"
    self.console = Console:new(self.registry)
    ConsoleCommands.register(self.console, self.registry)
    
    -- Initialize profiler
    local Profiler = require "dev.Profiler"
    local ProfilerUI = require "dev.ProfilerUI"
    self.profiler = Profiler:new()
    self.profilerUI = ProfilerUI:new(self.profiler)
    
    -- Initialize debug draw
    local DebugDraw = require "dev.DebugDraw"
    self.debugDraw = DebugDraw:new()
    
    -- Make App globally accessible for console commands
    _G.App = self
end

--- Runs the test suite and exits
function App:runTests()
    print("Alien Fall - Running Tests")
    print("==========================")

    -- Add src and test directories to package.path
    package.path = package.path .. ";./src/?.lua;./src/?/?.lua;./src/?/?/?.lua"
    package.path = package.path .. ";./test/?.lua;./test/?/?.lua;./test/framework/?.lua"

    local test_runner = require "test.framework.test_runner"
    local test_framework = require "test.framework.test_framework"
    
    -- Make test_framework globally available for test modules
    _G.test_framework = test_framework

    if self.testFile then
        -- Run specific test file
        print("Running specific test file: " .. self.testFile)
        local success, module = pcall(require, self.testFile)
        if success and module and module.run then
            module.run()
            test_framework.print_summary()
            success = test_framework.results.failed == 0
        elseif success and module and type(module) == "function" then
            module()
            test_framework.print_summary()
            success = test_framework.results.failed == 0
        elseif success then
            -- Module loaded successfully (tests may have run on load)
            test_framework.print_summary()
            success = test_framework.results.failed == 0
        else
            print("Failed to load test file: " .. self.testFile)
            if not success then
                print("Error: " .. tostring(module))
            else
                print("Module loaded but no run function found")
            end
            success = false
        end
    else
        -- Run all tests
        success = test_runner.run_all()
    end

    -- Exit with appropriate code
    if success then
        print("\nAll tests passed!")
        os.exit(0)
    else
        print("\nSome tests failed!")
        os.exit(1)
    end
end

--- Updates the display scaling based on window dimensions.
--
-- Calculates the appropriate scale factor to maintain aspect ratio and
-- centers the internal resolution within the window.
--
-- @param windowWidth The current window width (optional, uses current if not provided)
-- @param windowHeight The current window height (optional, uses current if not provided)
function App:updateScale(windowWidth, windowHeight)
    if not windowWidth or not windowHeight then
        windowWidth, windowHeight = love.graphics.getDimensions()
    end
    local scaleX = windowWidth / self.internalWidth
    local scaleY = windowHeight / self.internalHeight
    self.scale = math.min(scaleX, scaleY)
    if self.scale <= 0 then
        self.scale = 1
    end
    self.offsetX = (windowWidth - self.internalWidth * self.scale) / 2
    self.offsetY = (windowHeight - self.internalHeight * self.scale) / 2
end

--- Draws a debug grid overlay showing tile coordinates.
--
-- Renders a grid every 20 pixels with coordinate labels every 100 pixels
-- to help with UI layout and positioning.
function App:drawDebugGrid()
    love.graphics.setColor(0.3, 0.3, 0.3, 0.5)
    love.graphics.setLineWidth(1)
    
    -- Draw grid lines every 20 pixels
    for x = 0, self.internalWidth, 20 do
        love.graphics.line(x, 0, x, self.internalHeight)
    end
    for y = 0, self.internalHeight, 20 do
        love.graphics.line(0, y, self.internalWidth, y)
    end
    
    -- Draw tile coordinates every 5 tiles (100 pixels)
    love.graphics.setColor(0.8, 0.8, 0.8, 0.8)
    love.graphics.setFont(love.graphics.newFont(12))
    for tileX = 0, self.internalWidth / 100 - 1 do
        for tileY = 0, self.internalHeight / 100 - 1 do
            local x = tileX * 100 + 10
            local y = tileY * 100 + 10
            love.graphics.print((tileX * 5) .. "," .. (tileY * 5), x, y)
        end
    end
end

--- Draws debug information including FPS and frame time.
--
-- Displays performance metrics and debug state in the top-left corner.
function App:drawDebugInfo()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 5, 5, 200, 60)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("FPS: " .. self.fps, 10, 10)
    love.graphics.print(string.format("Frame Time: %.2f ms", self.frameTime), 10, 30)
    love.graphics.print("Debug: " .. (self.debugEnabled and "ON" or "OFF"), 10, 50)
end

--- Converts screen coordinates to internal coordinates.
--
-- Transforms mouse/screen coordinates to the internal resolution coordinate system,
-- accounting for scaling and offset.
--
-- @param x The screen x coordinate
-- @param y The screen y coordinate
-- @return number, number The internal x and y coordinates
function App:toInternal(x, y)
    local internalX = (x - self.offsetX) / self.scale
    local internalY = (y - self.offsetY) / self.scale
    return internalX, internalY
end

--- Gets the interpolation alpha for smooth rendering between physics steps.
--
-- Use this value to interpolate positions between previous and current physics state
-- for smooth visual output independent of physics update rate.
--
-- @return number Alpha value between 0 and 1 for interpolation
function App:getInterpolationAlpha()
    return self.interpolationAlpha
end

--- Gets the fixed timestep value used for physics updates.
--
-- @return number The fixed timestep in seconds (default: 1/60)
function App:getFixedTimestep()
    return self.fixedTimestep
end

function love.load()
    -- Check command line arguments for test mode (skip arg[0] and arg[1] which are love.exe and game dir)
    if arg then
        for i = 2, #arg do
            local argument = arg[i]
            if argument == "--test" then
                _G.TEST_MODE = true
                break
            elseif argument == "--test-watch" then
                _G.TEST_MODE = true
                _G.TEST_WATCH = true
                break
            elseif argument:match("^--test%-file=") then
                _G.TEST_MODE = true
                _G.TEST_FILE = argument:match("^--test%-file=(.+)")
                break
            end
        end
    end

    App:bootstrap()
    App:updateScale()
end

function love.resize(width, height)
    App:updateScale(width, height)
end

function love.update(dt)
    -- Begin profiling frame
    if App.profiler then
        App.profiler:beginFrame()
    end
    
    -- Update FPS counter
    App.fpsUpdateTimer = App.fpsUpdateTimer + dt
    if App.fpsUpdateTimer >= 0.1 then  -- Update every 100ms
        App.fps = love.timer.getFPS()
        App.frameTime = dt * 1000  -- Convert to milliseconds
        App.fpsUpdateTimer = 0
    end
    
    -- Update console
    if App.console then
        App.console:update(dt)
    end
    
    -- Fixed timestep physics update for deterministic behavior
    App.accumulator = App.accumulator + dt
    
    -- Clamp accumulator to prevent spiral of death
    if App.accumulator > App.maxAccumulator then
        App.accumulator = App.maxAccumulator
    end
    
    -- Update physics at fixed intervals
    while App.accumulator >= App.fixedTimestep do
        if App.registry then
            App.registry:update(App.fixedTimestep)
        end
        if App.stack then
            App.stack:update(App.fixedTimestep)
        end
        
        App.accumulator = App.accumulator - App.fixedTimestep
    end
    
    -- Calculate interpolation alpha for smooth rendering
    App.interpolationAlpha = App.accumulator / App.fixedTimestep
    
    -- End profiling frame
    if App.profiler then
        App.profiler:endFrame()
    end
end

function love.draw()
    love.graphics.clear(0.02, 0.02, 0.03, 1)
    love.graphics.push()
    love.graphics.translate(App.offsetX, App.offsetY)
    love.graphics.scale(App.scale, App.scale)
    if App.stack then
        App.stack:draw()
    end
    
    -- Draw grid overlay if enabled
    if App.showGrid then
        App:drawDebugGrid()
    end
    
    -- Draw console (inside scaled area)
    if App.console then
        App.console:draw()
    end
    
    -- Draw debug visualizations (inside scaled area)
    if App.debugDraw then
        App.debugDraw:draw()
    end
    
    -- Draw profiler UI (inside scaled area)
    if App.profilerUI then
        App.profilerUI:draw()
    end
    
    love.graphics.pop()
    
    -- Draw FPS/debug info if enabled (outside of scaling)
    if App.debugEnabled then
        App:drawDebugInfo()
    end
end

function love.keypressed(key, scancode, isrepeat)
    -- Console toggle key (~)
    if key == "`" or key == "~" then
        if App.console then
            App.console:toggle()
            return
        end
    end
    
    -- Console handles input when visible
    if App.console and App.console:isVisible() then
        if App.console:keypressed(key) then
            return
        end
    end
    
    -- Profiler UI handles input when visible
    if App.profilerUI and App.profilerUI:isVisible() then
        if App.profilerUI:keypressed(key) then
            return
        end
    end
    
    -- Debug keys - separate controls
    if key == "f9" then
        if App.profilerUI then
            App.profilerUI:toggle()
            print("Profiler: " .. (App.profilerUI:isVisible() and "ON" or "OFF"))
        end
    elseif key == "f10" then
        App.debugEnabled = not App.debugEnabled
        print("Debug mode (FPS/CPU): " .. (App.debugEnabled and "ON" or "OFF"))
    elseif key == "f11" then
        App.showGrid = not App.showGrid
        print("Grid overlay: " .. (App.showGrid and "ON" or "OFF"))
    elseif key == "f12" then
        -- Toggle fullscreen
        local isFullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not isFullscreen)
        print("Fullscreen: " .. (not isFullscreen and "ON" or "OFF"))
    end
    
    -- Pass to state stack if not handled
    if App.stack then
        App.stack:keypressed(key, scancode, isrepeat)
    end
end

function love.mousepressed(x, y, button)
    if not App.stack then return end
    local ix, iy = App:toInternal(x, y)
    App.stack:mousepressed(ix, iy, button)
end

function love.mousereleased(x, y, button)
    if not App.stack then return end
    local ix, iy = App:toInternal(x, y)
    App.stack:mousereleased(ix, iy, button)
end

function love.mousemoved(x, y, dx, dy, istouch)
    if not App.stack then return end
    local ix, iy = App:toInternal(x, y)
    App.stack:mousemoved(ix, iy, dx / App.scale, dy / App.scale, istouch)
end

function love.textinput(text)
    if App.console and App.console:isVisible() then
        App.console:textinput(text)
        return
    end
end

function love.wheelmoved(x, y)
    if App.console and App.console:isVisible() then
        if App.console:wheelmoved(x, y) then
            return
        end
    end
    
    if App.stack then
        App.stack:wheelmoved(x, y)
    end
end

function love.quit()
    if App.registry then
        App.registry:shutdown()
    end
end
