---Settings Screen
---
---Configure game preferences including difficulty, game speed, volume levels,
---display settings, and gameplay options. All settings persist across sessions.
---
---Key Exports:
---  - SettingsScreen:enter(): Initialize settings UI
---  - SettingsScreen:draw(): Render settings menu
---  - SettingsScreen:keypressed(key): Handle input
---  - SettingsScreen:mousepressed(x, y, button): Handle mouse clicks
---
---Settings Categories:
---  - Audio: Master, Music, SFX, Ambient volume
---  - Gameplay: Game speed, difficulty presets
---  - Display: Resolution, fullscreen, UI scale
---  - Advanced: Auto-save interval, notifications
---
---@module scenes.settings_screen
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local StateManager = require("core.state_manager")

local SettingsScreen = {}

--- Initialize settings screen
function SettingsScreen:enter()
    print("[SettingsScreen] Entering settings screen")

    -- Load saved preferences
    self:_loadPreferences()

    -- Current tab
    self.current_tab = 1
    self.tabs = {"AUDIO", "GAMEPLAY", "DISPLAY", "ADVANCED"}

    -- UI elements
    self.buttons = {}
    self.sliders = {}
    self.toggles = {}
    self:_createUI()
end

--- Load preferences from file
function SettingsScreen:_loadPreferences()
    self.preferences = {
        -- Audio
        master_volume = 0.8,
        music_volume = 0.7,
        sfx_volume = 0.8,
        ambient_volume = 0.5,

        -- Gameplay
        game_speed = 1.0,
        difficulty = 1,  -- 0=Easy, 1=Normal, 2=Hard

        -- Display
        resolution_index = 1,  -- 0=1280x720, 1=1440x810, 2=1920x1080
        fullscreen = false,
        ui_scale = 1.0,

        -- Advanced
        auto_save_interval = 5,  -- minutes
        pause_on_notification = true,
        debug_mode = false,
    }

    -- Try to load from file
    local ok, prefs = pcall(function()
        local content = love.filesystem.read("preferences.json") or "{}"
        return require("dkjson").decode(content)
    end)

    if ok and prefs then
        for key, value in pairs(prefs) do
            self.preferences[key] = value
        end
    end

    print("[SettingsScreen] Preferences loaded")
end

--- Create UI elements
function SettingsScreen:_createUI()
    self.buttons = {}
    self.sliders = {}
    self.toggles = {}

    -- Create buttons
    local button_width = 8 * 24
    local button_height = 2 * 24
    local button_x = 16 * 24
    local start_y = 26 * 24
    local spacing = 3 * 24

    -- Apply button
    table.insert(self.buttons, {
        x = button_x,
        y = start_y,
        width = button_width / 2 - 12,
        height = button_height,
        label = "APPLY",
        onClick = function() self:_savePreferences() end
    })

    -- Back button
    table.insert(self.buttons, {
        x = button_x + button_width / 2 + 12,
        y = start_y,
        width = button_width / 2 - 12,
        height = button_height,
        label = "BACK",
        onClick = function() StateManager.switch("menu") end
    })
end

--- Save preferences to file
function SettingsScreen:_savePreferences()
    print("[SettingsScreen] Saving preferences...")

    local json = require("dkjson")
    local content = json.encode(self.preferences)

    local ok = pcall(function()
        love.filesystem.write("preferences.json", content)
    end)

    if ok then
        print("[SettingsScreen] Preferences saved successfully")
    else
        print("[SettingsScreen] Failed to save preferences")
    end
end

--- Update settings screen
function SettingsScreen:update(dt)
    -- No continuous updates
end

--- Draw settings screen
function SettingsScreen:draw()
    love.graphics.clear(0.05, 0.05, 0.1)

    -- Title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.getFont())
    love.graphics.printf("SETTINGS", 0, 2 * 24, 40 * 24, "center")

    -- Tab selector
    self:_drawTabs()

    -- Tab content
    if self.current_tab == 1 then
        self:_drawAudioSettings()
    elseif self.current_tab == 2 then
        self:_drawGameplaySettings()
    elseif self.current_tab == 3 then
        self:_drawDisplaySettings()
    elseif self.current_tab == 4 then
        self:_drawAdvancedSettings()
    end

    -- Draw buttons
    self:_drawButtons()
end

--- Draw tab selector
function SettingsScreen:_drawTabs()
    local tab_y = 5 * 24
    local tab_width = 10 * 24

    for i, tab_name in ipairs(self.tabs) do
        local tab_x = 2 * 24 + (i - 1) * (tab_width + 12)

        if i == self.current_tab then
            love.graphics.setColor(0, 0.7, 0, 1)
        else
            love.graphics.setColor(0.3, 0.3, 0.35, 1)
        end

        love.graphics.rectangle("fill", tab_x, tab_y, tab_width, 2 * 24)
        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        love.graphics.rectangle("line", tab_x, tab_y, tab_width, 2 * 24)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(tab_name, tab_x, tab_y + 6, tab_width, "center")
    end
end

--- Draw audio settings
function SettingsScreen:_drawAudioSettings()
    local y = 8 * 24
    local line_height = 2.5 * 24

    love.graphics.setColor(1, 1, 0.7, 1)
    love.graphics.printf("Audio Controls", 4 * 24, y, 32 * 24, "left")
    y = y + line_height

    love.graphics.setColor(1, 1, 1, 1)
    y = self:_drawVolumeSlider("Master Volume", "master_volume", y)
    y = self:_drawVolumeSlider("Music Volume", "music_volume", y)
    y = self:_drawVolumeSlider("SFX Volume", "sfx_volume", y)
    y = self:_drawVolumeSlider("Ambient Volume", "ambient_volume", y)
end

--- Draw gameplay settings
function SettingsScreen:_drawGameplaySettings()
    local y = 8 * 24
    local line_height = 2.5 * 24

    love.graphics.setColor(1, 1, 0.7, 1)
    love.graphics.printf("Gameplay Settings", 4 * 24, y, 32 * 24, "left")
    y = y + line_height

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Game Speed:", 4 * 24, y, 20 * 24, "left")
    love.graphics.printf("1x", 24 * 24, y, 3 * 24, "left")
    love.graphics.printf("2x", 28 * 24, y, 3 * 24, "left")
    love.graphics.printf("4x", 32 * 24, y, 3 * 24, "left")
    y = y + line_height

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Difficulty:", 4 * 24, y, 20 * 24, "left")
    love.graphics.printf("Easy", 24 * 24, y, 5 * 24, "left")
    love.graphics.printf("Normal", 28 * 24, y, 5 * 24, "left")
    love.graphics.printf("Hard", 32 * 24, y, 5 * 24, "left")
end

--- Draw display settings
function SettingsScreen:_drawDisplaySettings()
    local y = 8 * 24
    local line_height = 2.5 * 24

    love.graphics.setColor(1, 1, 0.7, 1)
    love.graphics.printf("Display Settings", 4 * 24, y, 32 * 24, "left")
    y = y + line_height

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Resolution:", 4 * 24, y, 20 * 24, "left")
    love.graphics.printf("1280x720", 24 * 24, y, 12 * 24, "left")
    y = y + line_height

    love.graphics.printf("Fullscreen:", 4 * 24, y, 20 * 24, "left")
    local fullscreen_text = self.preferences.fullscreen and "ON" or "OFF"
    love.graphics.printf(fullscreen_text, 24 * 24, y, 12 * 24, "left")
    y = y + line_height

    love.graphics.printf("UI Scale:", 4 * 24, y, 20 * 24, "left")
    love.graphics.printf(string.format("%.1fx", self.preferences.ui_scale), 24 * 24, y, 12 * 24, "left")
end

--- Draw advanced settings
function SettingsScreen:_drawAdvancedSettings()
    local y = 8 * 24
    local line_height = 2.5 * 24

    love.graphics.setColor(1, 1, 0.7, 1)
    love.graphics.printf("Advanced Settings", 4 * 24, y, 32 * 24, "left")
    y = y + line_height

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Auto-save Interval:", 4 * 24, y, 20 * 24, "left")
    love.graphics.printf(self.preferences.auto_save_interval .. " min", 24 * 24, y, 12 * 24, "left")
    y = y + line_height

    love.graphics.printf("Pause on Notification:", 4 * 24, y, 20 * 24, "left")
    local pause_text = self.preferences.pause_on_notification and "ON" or "OFF"
    love.graphics.printf(pause_text, 24 * 24, y, 12 * 24, "left")
    y = y + line_height

    love.graphics.printf("Debug Mode:", 4 * 24, y, 20 * 24, "left")
    local debug_text = self.preferences.debug_mode and "ON" or "OFF"
    love.graphics.printf(debug_text, 24 * 24, y, 12 * 24, "left")
end

--- Draw volume slider
function SettingsScreen:_drawVolumeSlider(label, key, y)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(label .. ":", 4 * 24, y, 20 * 24, "left")

    local slider_x = 24 * 24
    local slider_width = 10 * 24
    local slider_height = 12

    -- Background
    love.graphics.setColor(0.2, 0.2, 0.25, 1)
    love.graphics.rectangle("fill", slider_x, y + 6, slider_width, slider_height)

    -- Border
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.rectangle("line", slider_x, y + 6, slider_width, slider_height)

    -- Fill
    local volume = self.preferences[key]
    love.graphics.setColor(0, 0.7, 0, 1)
    love.graphics.rectangle("fill", slider_x, y + 6, slider_width * volume, slider_height)

    -- Percentage
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(string.format("%.0f%%", volume * 100), slider_x + slider_width + 24, y, 3 * 24, "left")

    return y + 2.5 * 24
end

--- Draw buttons
function SettingsScreen:_drawButtons()
    for _, button in ipairs(self.buttons) do
        love.graphics.setColor(0.3, 0.3, 0.35, 1)
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)

        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        love.graphics.rectangle("line", button.x, button.y, button.width, button.height)

        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(button.label, button.x, button.y + 6, button.width, "center")
    end
end

--- Handle keyboard input
function SettingsScreen:keypressed(key, scancode, isrepeat)
    if key == "escape" then
        StateManager.switch("menu")
    elseif key == "left" then
        self.current_tab = math.max(1, self.current_tab - 1)
    elseif key == "right" then
        self.current_tab = math.min(#self.tabs, self.current_tab + 1)
    elseif key == "up" then
        -- Increase volume in current tab
        if self.current_tab == 1 then
            self.preferences.master_volume = math.min(1.0, self.preferences.master_volume + 0.1)
        end
    elseif key == "down" then
        -- Decrease volume in current tab
        if self.current_tab == 1 then
            self.preferences.master_volume = math.max(0, self.preferences.master_volume - 0.1)
        end
    end
end

--- Handle mouse press
function SettingsScreen:mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        -- Tab clicks
        local tab_y = 5 * 24
        local tab_width = 10 * 24

        for i, _ in ipairs(self.tabs) do
            local tab_x = 2 * 24 + (i - 1) * (tab_width + 12)
            if x >= tab_x and x < tab_x + tab_width and y >= tab_y and y < tab_y + 2 * 24 then
                self.current_tab = i
            end
        end

        -- Button clicks
        for _, btn in ipairs(self.buttons) do
            if x >= btn.x and x < btn.x + btn.width and y >= btn.y and y < btn.y + btn.height then
                btn:onClick()
            end
        end

        -- Slider clicks (for audio settings)
        if self.current_tab == 1 then
            local slider_x = 24 * 24
            local slider_width = 10 * 24

            if x >= slider_x and x < slider_x + slider_width then
                local ratio = (x - slider_x) / slider_width
                self.preferences.master_volume = math.max(0, math.min(1, ratio))
            end
        end
    end
end

return SettingsScreen

