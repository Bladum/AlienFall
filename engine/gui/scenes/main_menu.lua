---Main Menu Screen
---
---Primary game entry screen with navigation to all major game modes. Provides
---options to start new campaign, load saved games, access settings, run tests,
---view widget showcase, and quit. Implements the menu game state.
---
---Key Exports:
---  - Menu:enter(): Initializes menu with title and buttons
---  - Menu:draw(): Renders menu screen with background and widgets
---  - Menu:keypressed(key): Handles keyboard input (Escape to quit)
---  - Menu:update(dt): Updates button states and animations
---
---Menu Options:
---  - New Game: Start fresh campaign in geoscape
---  - Load Game: Load saved campaign (future feature)
---  - Settings: Game configuration (future feature)
---  - Tests: Run unit and integration tests
---  - Widget Showcase: View all UI widgets
---  - Quit: Exit game
---
---Dependencies:
---  - core.state_manager: For switching to other game states
---  - widgets.init: For button widgets and UI elements
---  - love.graphics: For rendering title and background
---
---@module scenes.main_menu
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  -- Registered automatically in main.lua
---  StateManager.register("menu", Menu)
---  StateManager.switch("menu")
---
---@see core.state_manager For state management
---@see scenes.geoscape_screen For strategic layer
---@see scenes.battlescape_screen For tactical combat

local StateManager = require("core.state.state_manager")
local Widgets = require("gui.widgets.init")
local AudioManager = require("core.audio_manager")

local Menu = {}

--- Initialize the menu state.
--- Sets up the main menu interface with title, buttons, and navigation options.
---
--- @return nil
function Menu:enter()
    print("[Menu] Entering menu state")

    -- Window dimensions
    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    -- Title
    self.title = "ALIEN FALL"
    self.subtitle = "A Tactical Strategy Game"

    -- Create buttons (grid-aligned: 8x2 cells for buttons, positioned at grid coordinates)
    local buttonWidth = 8 * 24   -- 8 grid cells = 192 pixels
    local buttonHeight = 2 * 24  -- 2 grid cells = 48 pixels
    local buttonX = 16 * 24      -- Center horizontally: (40 - 8) / 2 * 24 = 16 * 24 = 384
    local startY = 13 * 24       -- Center vertically: 360 - 48 = 312, 312/24 = 13
    local spacing = 3 * 24       -- 3 grid cells = 72 pixels

    self.buttons = {}

    -- New Campaign button
    table.insert(self.buttons, Widgets.Button.new(
        buttonX,
        startY,
        buttonWidth,
        buttonHeight,
        "NEW CAMPAIGN"
    ))
    self.buttons[#self.buttons].onClick = function()
        StateManager.switch("new_campaign_wizard")
    end

    -- Load Game button
    table.insert(self.buttons, Widgets.Button.new(
        buttonX,
        startY + spacing,
        buttonWidth,
        buttonHeight,
        "LOAD GAME"
    ))
    self.buttons[#self.buttons].onClick = function()
        StateManager.switch("load_game")
    end

    -- Basescape button
    table.insert(self.buttons, Widgets.Button.new(
        buttonX,
        startY + spacing * 2,
        buttonWidth,
        buttonHeight,
        "CAMPAIGN STATS"
    ))
    self.buttons[#self.buttons].onClick = function()
        StateManager.switch("campaign_stats")
    end

    -- Settings button
    table.insert(self.buttons, Widgets.Button.new(
        buttonX,
        startY + spacing * 3,
        buttonWidth,
        buttonHeight,
        "SETTINGS"
    ))
    self.buttons[#self.buttons].onClick = function()
        StateManager.switch("settings")
    end

    -- Tests button
    table.insert(self.buttons, Widgets.Button.new(
        buttonX,
        startY + spacing * 4,
        buttonWidth,
        buttonHeight,
        "DEMO MODES"
    ))
    self.buttons[#self.buttons].onClick = function()
        StateManager.switch("tests_menu")
    end

    -- MIDI Test button
    table.insert(self.buttons, Widgets.Button.new(
        buttonX,
        startY + spacing * 5,
        buttonWidth,
        buttonHeight,
        "TEST MIDI"
    ))
    self.buttons[#self.buttons].onClick = function()
        print("[Menu] Testing MIDI playback...")
        -- Try playing the uploaded MIDI file
        if not AudioManager:playMIDI("MIDI TEST/Queen - Bohemian Rhapsody") then
            print("[Menu] MIDI parsing failed, trying random_song.mid...")
            if not AudioManager:playMIDI("MIDI TEST/random_song") then
                print("[Menu] MIDI parsing failed, generating test tone...")
                -- Generate a simple test tone as fallback
                local toneData = love.sound.newSoundData(44100 * 2, 44100, 16, 1) -- 2 seconds
                for i = 0, 44100 * 2 - 1 do
                    local t = i / 44100
                    local sample = math.sin(2 * math.pi * 440 * t) * 0.3 -- 440Hz sine wave
                    toneData:setSample(i, sample)
                end
                local source = love.audio.newSource(toneData)
                source:play()
                print("[Menu] Test tone played (440Hz for 2 seconds)")
            end
        end
    end

    -- Quit button
    table.insert(self.buttons, Widgets.Button.new(
        buttonX,
        startY + spacing * 6,
        buttonWidth,
        buttonHeight,
        "QUIT"
    ))
    self.buttons[#self.buttons].onClick = function()
        love.event.quit()
    end

    -- Version label (positioned at bottom-right, grid-aligned)
    self.versionLabel = Widgets.Label.new(
        36 * 24,  -- 36 grid cells = 864 pixels (leave some margin)
        28 * 24,  -- 28 grid cells = 672 pixels
        4 * 24,   -- 4 grid cells = 96 pixels width
        1 * 24,   -- 1 grid cell = 24 pixels height
        "v0.1.0"
    )
    self.versionLabel:setAlign("right")
    self.versionLabel:setVerticalAlign("bottom")
end

--- Clean up the menu state.
--- Removes all widgets and frees resources when leaving the menu.
---
--- @return nil
function Menu:exit()
    print("[Menu] Exiting menu state")
end

--- Update the menu state.
--- Handles button animations and widget updates each frame.
---
--- @param dt number Delta time since last update in seconds
--- @return nil
function Menu:update(dt)
    -- Update all buttons
    for _, button in ipairs(self.buttons) do
        button:update(dt)
    end

    -- Update version label
    self.versionLabel:update(dt)

    -- Auto-test MIDI after 2 seconds (for testing purposes)
    if not self.autoTested then
        self.autoTestTime = (self.autoTestTime or 0) + dt
        if self.autoTestTime >= 2 then
            print("[Menu] Auto-testing MIDI playback...")
            self.autoTested = true
            -- Simulate clicking the TEST MIDI button
            if self.buttons[6] and self.buttons[6].text == "TEST MIDI" then
                self.buttons[6].onClick()
            end
        end
    end
end

--- Render the menu screen.
--- Draws the background, title, subtitle, buttons, and UI elements.
---
--- @return nil
function Menu:draw()
    -- Clear background
    love.graphics.clear(0.05, 0.05, 0.1)

    local windowWidth = love.graphics.getWidth()
    local windowHeight = love.graphics.getHeight()

    -- Draw title
    love.graphics.setColor(0.2, 0.6, 0.9)
    local titleFont = love.graphics.newFont(48)
    love.graphics.setFont(titleFont)
    local titleWidth = titleFont:getWidth(self.title)
    love.graphics.print(self.title, (windowWidth - titleWidth) / 2, 100)

    -- Draw subtitle
    love.graphics.setColor(0.7, 0.7, 0.8)
    local subtitleFont = love.graphics.newFont(20)
    love.graphics.setFont(subtitleFont)
    local subtitleWidth = subtitleFont:getWidth(self.subtitle)
    love.graphics.print(self.subtitle, (windowWidth - subtitleWidth) / 2, 160)

    -- Reset to default font for buttons
    love.graphics.setFont(love.graphics.newFont(18))

    -- Draw all buttons
    for _, button in ipairs(self.buttons) do
        button:draw()
    end

    -- Draw version label
    self.versionLabel:draw()

    -- Draw instructions
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("Use mouse to click buttons | ESC to return to menu", 10, windowHeight - 30)
end

--- Handle keyboard input.
--- Processes key presses for navigation shortcuts and menu control.
---
--- @param key string The key that was pressed
--- @param scancode string The scancode of the key
--- @param isrepeat boolean Whether this is a key repeat event
--- @return nil
function Menu:keypressed(key, scancode, isrepeat)
    if key == "b" then
        print("[Menu] Switching to battlescape via keypress")
        StateManager.switch("battlescape")
    elseif key == "g" then
        print("[Menu] Switching to geoscape via keypress")
        StateManager.switch("geoscape")
    elseif key == "s" then
        print("[Menu] Switching to basescape via keypress")
        StateManager.switch("basescape")
    elseif key == "escape" then
        love.event.quit()
    end
end

--- Handle mouse button press events.
--- Forwards mouse events to interactive buttons.
---
--- @param x number Mouse X coordinate
--- @param y number Mouse Y coordinate
--- @param button number Mouse button number (1=left, 2=right, etc.)
--- @param istouch boolean Whether this is a touch event
--- @param presses number Number of presses in sequence
--- @return boolean|nil True if event was handled, nil otherwise
function Menu:mousepressed(x, y, button, istouch, presses)
    -- Forward to all buttons
    for _, btn in ipairs(self.buttons) do
        if btn:mousepressed(x, y, button) then
            return true
        end
    end
    return false
end

--- Handle mouse button release events.
--- Forwards mouse release events to interactive buttons.
---
--- @param x number Mouse X coordinate
--- @param y number Mouse Y coordinate
--- @param button number Mouse button number (1=left, 2=right, etc.)
--- @param istouch boolean Whether this is a touch event
--- @param presses number Number of presses in sequence
--- @return boolean False (event not handled by menu)
function Menu:mousereleased(x, y, button, istouch, presses)
    -- Forward to all buttons
    for _, btn in ipairs(self.buttons) do
        if btn:mousereleased(x, y, button) then
            return true
        end
    end
    return false
end

return Menu
