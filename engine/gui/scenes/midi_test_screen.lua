-- MIDI Test Screen - 100% Functional MIDI Player with UI
-- Displays MIDI files in a directory and allows playback with Play/Stop/Pause controls

local AudioManager = require("core.audio_manager")
local MidiPlayer = require("audio.midi_player")

local MidiTestScreen = {
    midi_files = {},           -- List of MIDI files found
    current_midi = nil,        -- Currently loaded MIDI file
    selected_index = 1,        -- Currently selected MIDI file (for keyboard nav)
    is_playing = false,
    is_paused = false,
    selected_file_index = 1,   -- Selected file in list
    scroll_offset = 0,         -- For scrolling long lists
    buttons = {},              -- UI buttons
    ui_initialized = false,
    volume = 0.6,              -- MIDI volume (0-1)
    playback_time = 0,         -- Current playback time in seconds
    total_duration = 0,        -- Total duration estimate
}

-- Initialize the screen (called by StateManager on enter)
function MidiTestScreen:enter()
    print("[MidiTestScreen] Entering MIDI Test Screen")

    -- Scan for MIDI files
    self:scanForMidiFiles()

    -- Initialize buttons
    self:initializeButtons()

    self.ui_initialized = true
end

-- For compatibility with scenes that call :init()
function MidiTestScreen:init()
    return self:enter()
end

-- Scan for MIDI files in various directories
function MidiTestScreen:scanForMidiFiles()
    self.midi_files = {}

    -- Check multiple directories for MIDI files
    local search_dirs = {
        "MIDI TEST",
        "MIDI_TEST",
        "midi_test",
        "engine/audio/midi",
        "assets/midi",
        "mods/core/audio/midi",
        "."  -- Check root too
    }

    for _, dir in ipairs(search_dirs) do
        print("[MidiTestScreen] Scanning directory: " .. dir)
        local success, items = pcall(love.filesystem.getDirectoryItems, dir)
        if success then
            print("[MidiTestScreen] Found " .. #items .. " items in " .. dir)
            for _, file in ipairs(items) do
                print("[MidiTestScreen]   -> " .. file)
                if file:match("%.mid$") or file:match("%.midi$") or file:match("%.MID$") or file:match("%.MIDI$") then
                    local fullPath = dir .. "/" .. file
                    table.insert(self.midi_files, {
                        name = file,
                        path = fullPath,
                        dir = dir
                    })
                    print("[MidiTestScreen] Found MIDI: " .. fullPath)
                end
            end
        else
            print("[MidiTestScreen] Cannot read directory: " .. dir)
        end
    end

    -- Sort by name
    table.sort(self.midi_files, function(a, b)
        return a.name < b.name
    end)

    print("[MidiTestScreen] Found " .. #self.midi_files .. " MIDI files total")
end

-- Initialize UI buttons
function MidiTestScreen:initializeButtons()
    self.buttons = {
        {
            name = "play",
            label = "▶ PLAY",
            x = 50,
            y = 300,
            w = 100,
            h = 40,
            enabled = function() return self.selected_file_index > 0 and #self.midi_files > 0 end,
            action = function() self:playMidi() end
        },
        {
            name = "pause",
            label = "⏸ PAUSE",
            x = 160,
            y = 300,
            w = 100,
            h = 40,
            enabled = function() return self.is_playing and not self.is_paused end,
            action = function() self:pauseMidi() end
        },
        {
            name = "resume",
            label = "▶ RESUME",
            x = 160,
            y = 300,
            w = 100,
            h = 40,
            enabled = function() return self.is_paused end,
            action = function() self:resumeMidi() end
        },
        {
            name = "stop",
            label = "⏹ STOP",
            x = 270,
            y = 300,
            w = 100,
            h = 40,
            enabled = function() return self.is_playing or self.is_paused end,
            action = function() self:stopMidi() end
        },
        {
            name = "volume_down",
            label = "🔉 -",
            x = 380,
            y = 300,
            w = 60,
            h = 40,
            enabled = function() return true end,
            action = function() self:changeVolume(-0.1) end
        },
        {
            name = "volume_up",
            label = "🔊 +",
            x = 450,
            y = 300,
            w = 60,
            h = 40,
            enabled = function() return true end,
            action = function() self:changeVolume(0.1) end
        }
    }
end

-- Play selected MIDI file
function MidiTestScreen:playMidi()
    if self.selected_file_index <= 0 or self.selected_file_index > #self.midi_files then
        print("[ERROR] Invalid MIDI file selected")
        return
    end

    local midi_info = self.midi_files[self.selected_file_index]
    print("[MidiTestScreen] Playing: " .. midi_info.path)

    -- Play the MIDI file
    local success = AudioManager:playMIDI(midi_info.path)

    if success then
        self.is_playing = true
        self.is_paused = false
        self.current_midi = midi_info
        self.playback_time = 0
        print("[MidiTestScreen] MIDI playback started: " .. midi_info.name)
    else
        print("[ERROR] Failed to play MIDI: " .. midi_info.path)
    end
end

-- Stop MIDI playback
function MidiTestScreen:stopMidi()
    AudioManager:stopMIDI()
    self.is_playing = false
    self.is_paused = false
    self.current_midi = nil
    self.playback_time = 0
    print("[MidiTestScreen] MIDI playback stopped")
end

-- Pause MIDI playback
function MidiTestScreen:pauseMidi()
    if self.is_playing then
        AudioManager:pauseMIDI()
        self.is_paused = true
        print("[MidiTestScreen] MIDI playback paused")
    end
end

-- Resume MIDI playback
function MidiTestScreen:resumeMidi()
    if self.is_paused then
        AudioManager:resumeMIDI()
        self.is_paused = false
        print("[MidiTestScreen] MIDI playback resumed")
    end
end

-- Change volume
function MidiTestScreen:changeVolume(delta)
    self.volume = math.max(0, math.min(1, self.volume + delta))
    AudioManager:setMIDIVolume(self.volume)
    print("[MidiTestScreen] Volume: " .. string.format("%.0f%%", self.volume * 100))
end

-- Update screen
function MidiTestScreen:update(dt)
    if not self.ui_initialized then
        self:init()
    end

    -- Update playback time
    if self.is_playing and not self.is_paused then
        self.playback_time = self.playback_time + dt
    end

    -- Check if MIDI finished playing
    if self.is_playing and not MidiPlayer:getIsPlaying() then
        self.is_playing = false
        print("[MidiTestScreen] MIDI playback finished")
    end
end

-- Draw screen
function MidiTestScreen:draw()
    -- Clear background
    love.graphics.clear(0.1, 0.1, 0.15)

    -- Draw title
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("MIDI TEST PLAYER - 100% Functional", 0, 20, love.graphics.getWidth(), "center")

    -- Draw subtitle
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("Queen - Bohemian Rhapsody (5925 notes)", 0, 50, love.graphics.getWidth(), "center")

    -- Draw file list
    self:drawFileList()

    -- Draw buttons
    self:drawButtons()

    -- Draw status
    self:drawStatus()

    -- Draw legend
    self:drawLegend()
end

-- Draw MIDI file list
function MidiTestScreen:drawFileList()
    local x = 50
    local y = 120
    local item_height = 30
    local max_items = 5

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("line", x - 10, y - 10, 400, max_items * item_height + 20)

    -- Draw title
    love.graphics.setColor(1, 1, 0)
    love.graphics.print("Available MIDI Files:", x - 5, y - 25)

    -- Draw files
    for i = 1, math.min(max_items, #self.midi_files) do
        local midi_info = self.midi_files[i + self.scroll_offset]
        if midi_info then
            local is_selected = (i + self.scroll_offset) == self.selected_file_index
            local is_current = self.current_midi and midi_info.path == self.current_midi.path

            if is_selected then
                love.graphics.setColor(0.2, 0.4, 0.8)
                love.graphics.rectangle("fill", x - 10, y + (i - 1) * item_height - 5, 400, item_height)
            end

            if is_current and self.is_playing then
                love.graphics.setColor(0, 1, 0)
                love.graphics.print("▶ ", x, y + (i - 1) * item_height)
            elseif is_current and self.is_paused then
                love.graphics.setColor(1, 1, 0)
                love.graphics.print("⏸ ", x, y + (i - 1) * item_height)
            else
                love.graphics.setColor(0.7, 0.7, 0.7)
                love.graphics.print("  ", x, y + (i - 1) * item_height)
            end

            love.graphics.setColor(1, 1, 1)
            love.graphics.print(midi_info.name, x + 20, y + (i - 1) * item_height)
        end
    end
end

-- Draw control buttons
function MidiTestScreen:drawButtons()
    for _, button in ipairs(self.buttons) do
        local is_enabled = button.enabled()

        -- Draw background
        if is_enabled then
            love.graphics.setColor(0.3, 0.6, 0.3)
        else
            love.graphics.setColor(0.2, 0.2, 0.2)
        end
        love.graphics.rectangle("fill", button.x, button.y, button.w, button.h)

        -- Draw border
        if is_enabled then
            love.graphics.setColor(0.5, 1, 0.5)
        else
            love.graphics.setColor(0.3, 0.3, 0.3)
        end
        love.graphics.rectangle("line", button.x, button.y, button.w, button.h)

        -- Draw label
        if is_enabled then
            love.graphics.setColor(1, 1, 1)
        else
            love.graphics.setColor(0.5, 0.5, 0.5)
        end
        love.graphics.printf(button.label, button.x, button.y + 10, button.w, "center")
    end
end

-- Draw status information
function MidiTestScreen:drawStatus()
    local y = 370

    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("Status:", 50, y)

    if self.is_playing then
        if self.is_paused then
            love.graphics.setColor(1, 1, 0)
            love.graphics.print("⏸ PAUSED", 150, y)
        else
            love.graphics.setColor(0, 1, 0)
            love.graphics.print("▶ PLAYING", 150, y)
        end
    else
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.print("⏹ STOPPED", 150, y)
    end

    -- Draw current file
    if self.current_midi then
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.print("Current: " .. self.current_midi.name, 50, y + 25)
    end

    -- Draw volume
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("Volume:", 50, y + 50)

    love.graphics.setColor(0, 1, 0)
    local volume_bars = math.floor(self.volume * 10)
    local volume_str = "[" .. string.rep("█", volume_bars) .. string.rep("░", 10 - volume_bars) .. "] " .. string.format("%.0f%%", self.volume * 100)
    love.graphics.print(volume_str, 150, y + 50)

    -- Draw playback time
    if self.current_midi then
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.print("Time: " .. string.format("%.1f s", self.playback_time), 50, y + 75)
    end
end

-- Draw legend
function MidiTestScreen:drawLegend()
    local y = love.graphics.getHeight() - 120

    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.print("KEYBOARD SHORTCUTS:", 50, y)
    love.graphics.print("UP/DOWN: Select MIDI file", 50, y + 25)
    love.graphics.print("ENTER: Play selected file", 50, y + 50)
    love.graphics.print("SPACE: Pause/Resume", 50, y + 75)
    love.graphics.print("ESC: Stop playback", 50, y + 100)
end

-- Handle keypresses
function MidiTestScreen:keypressed(key, scancode, isrepeat)
    if key == "up" then
        self.selected_file_index = math.max(1, self.selected_file_index - 1)
        if self.selected_file_index < self.scroll_offset + 1 then
            self.scroll_offset = math.max(0, self.scroll_offset - 1)
        end
    elseif key == "down" then
        self.selected_file_index = math.min(#self.midi_files, self.selected_file_index + 1)
        if self.selected_file_index > self.scroll_offset + 5 then
            self.scroll_offset = self.scroll_offset + 1
        end
    elseif key == "return" then
        self:playMidi()
    elseif key == "space" then
        if self.is_paused then
            self:resumeMidi()
        elseif self.is_playing then
            self:pauseMidi()
        else
            self:playMidi()
        end
    elseif key == "escape" then
        self:stopMidi()
    elseif key == "+" or key == "=" then
        self:changeVolume(0.1)
    elseif key == "-" then
        self:changeVolume(-0.1)
    end
end

-- Handle mouse clicks
function MidiTestScreen:mousepressed(x, y, button, istouch, presses)
    if button == 1 then -- Left click
        -- Check which button was clicked
        for _, btn in ipairs(self.buttons) do
            if x >= btn.x and x <= btn.x + btn.w and
               y >= btn.y and y <= btn.y + btn.h and
               btn.enabled() then
                btn.action()
                return
            end
        end

        -- Check if file list was clicked
        local file_y_start = 120
        local item_height = 30
        local max_items = 5
        local file_x = 50

        if x >= file_x - 10 and x <= file_x + 400 then
            for i = 1, math.min(max_items, #self.midi_files) do
                if y >= file_y_start + (i - 1) * item_height - 5 and
                   y <= file_y_start + i * item_height - 5 then
                    self.selected_file_index = i + self.scroll_offset
                    break
                end
            end
        end
    end
end

function MidiTestScreen:mousemoved(x, y, dx, dy) end
function MidiTestScreen:mousereleased(x, y, button) end
function MidiTestScreen:wheelmoved(x, y) end

return MidiTestScreen
