-- MIDI Test Screen - FIXED VERSION
-- 100% Functional MIDI Player with Working UI

local AudioManager = require("core.audio_manager")
local MidiPlayer = require("audio.midi_player")

local MidiTestScreen = {
    midi_files = {},
    selected_file_index = 1,
    is_playing = false,
    volume = 0.6,
    last_status = "stopped",
}

function MidiTestScreen:enter()
    print("[MidiTestScreen] ========== ENTERING MIDI TEST SCREEN ==========")
    self.midi_files = {}
    self.selected_file_index = 1
    self.is_playing = false

    -- Scan for MIDI files
    self:scan_midi_files()

    -- Set initial volume
    AudioManager:setMIDIVolume(self.volume)

    print("[MidiTestScreen] Initialization complete. Found " .. #self.midi_files .. " MIDI files.")
end

function MidiTestScreen:scan_midi_files()
    print("[MidiTestScreen] Scanning for MIDI files...")
    self.midi_files = {}

    -- Scan the integrated MIDI directory in engine assets
    local midi_dir = "assets/music/midi"
    print("[MidiTestScreen] Checking directory: " .. midi_dir)

    local files = love.filesystem.getDirectoryItems(midi_dir)
    for _, filename in ipairs(files) do
        if filename:match("%.mid$") or filename:match("%.midi$") then
            local path = midi_dir .. "/" .. filename
            print("[MidiTestScreen]   ✓ FOUND: " .. path)
            table.insert(self.midi_files, {
                name = filename,
                path = path
            })
        end
    end

    print("[MidiTestScreen] Total MIDI files found: " .. #self.midi_files)
end

function MidiTestScreen:update(dt)
    local midi_status = MidiPlayer:getIsPlaying()
    if midi_status ~= self.last_status then
        print("[MidiTestScreen] Status changed: " .. tostring(self.last_status) .. " -> " .. tostring(midi_status))
        self.last_status = midi_status
    end

    self.is_playing = midi_status
    AudioManager:update(dt)
end

function MidiTestScreen:draw()
    -- Background
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Title
    love.graphics.setColor(1, 1, 0)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf("MIDI TEST PLAYER", 0, 20, love.graphics.getWidth(), "center")

    -- Subtitle
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.printf("Files found: " .. #self.midi_files, 0, 60, love.graphics.getWidth(), "center")

    -- File list
    self:draw_file_list()

    -- Buttons
    self:draw_buttons()

    -- Status
    self:draw_status()
end

function MidiTestScreen:draw_file_list()
    local x = 50
    local y = 120
    local w = 500
    local h = 150

    -- Background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", x, y, w, h)

    -- Border
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("line", x, y, w, h)

    -- Title
    love.graphics.setColor(1, 1, 0)
    love.graphics.print("MIDI Files:", x + 10, y + 10)

    -- Files
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(12))
    for i, file_info in ipairs(self.midi_files) do
        if i <= 4 then  -- Show max 4 files
            local color_r, color_g, color_b = 0.7, 0.7, 0.7
            if i == self.selected_file_index then
                color_r, color_g, color_b = 1, 1, 0
            end
            love.graphics.setColor(color_r, color_g, color_b)
            love.graphics.print(i .. ". " .. file_info.name, x + 15, y + 35 + (i - 1) * 25)
        end
    end
end

function MidiTestScreen:draw_buttons()
    local buttons = {
        {x = 50, y = 300, w = 120, h = 40, text = "PLAY", key = "1"},
        {x = 180, y = 300, w = 120, h = 40, text = "PAUSE", key = "2"},
        {x = 310, y = 300, w = 120, h = 40, text = "STOP", key = "3"},
        {x = 50, y = 360, w = 120, h = 40, text = "VOL -", key = "-"},
        {x = 180, y = 360, w = 120, h = 40, text = "VOL +", key = "+"},
    }

    for _, btn in ipairs(buttons) do
        -- Button background
        love.graphics.setColor(0.3, 0.6, 0.3)
        love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.h)

        -- Button border
        love.graphics.setColor(0.5, 1, 0.5)
        love.graphics.rectangle("line", btn.x, btn.y, btn.w, btn.h)

        -- Button text
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(14))
        love.graphics.printf(btn.text, btn.x, btn.y + 10, btn.w, "center")
    end
end

function MidiTestScreen:draw_status()
    local y = love.graphics.getHeight() - 100

    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.setFont(love.graphics.newFont(12))

    love.graphics.print("Status: ", 50, y)
    if self.is_playing then
        love.graphics.setColor(0, 1, 0)
        love.graphics.print("▶ PLAYING", 150, y)
    else
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.print("⏹ STOPPED", 150, y)
    end

    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("Volume: " .. string.format("%.0f%%", self.volume * 100), 50, y + 25)

    love.graphics.print("Keyboard: UP/DOWN=Select, ENTER=Play, SPC=Toggle, ESC=Stop, +/-=Volume", 50, y + 50)
end

function MidiTestScreen:keypressed(key, scancode, isrepeat)
    if key == "up" then
        self.selected_file_index = math.max(1, self.selected_file_index - 1)
        print("[MidiTestScreen] Selected file " .. self.selected_file_index)

    elseif key == "down" then
        self.selected_file_index = math.min(#self.midi_files, self.selected_file_index + 1)
        print("[MidiTestScreen] Selected file " .. self.selected_file_index)

    elseif key == "return" or key == "1" then
        self:play_midi()

    elseif key == "space" or key == "2" then
        if self.is_playing then
            self:pause_midi()
        else
            self:play_midi()
        end

    elseif key == "escape" or key == "3" then
        self:stop_midi()

    elseif key == "+" or key == "=" then
        self.volume = math.min(1.0, self.volume + 0.1)
        AudioManager:setMIDIVolume(self.volume)
        print("[MidiTestScreen] Volume: " .. string.format("%.0f%%", self.volume * 100))

    elseif key == "-" then
        self.volume = math.max(0, self.volume - 0.1)
        AudioManager:setMIDIVolume(self.volume)
        print("[MidiTestScreen] Volume: " .. string.format("%.0f%%", self.volume * 100))
    end
end

function MidiTestScreen:mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        -- Check button clicks
        if x >= 50 and x <= 170 and y >= 300 and y <= 340 then  -- PLAY
            self:play_midi()
        elseif x >= 180 and x <= 300 and y >= 300 and y <= 340 then  -- PAUSE
            self:pause_midi()
        elseif x >= 310 and x <= 430 and y >= 300 and y <= 340 then  -- STOP
            self:stop_midi()
        elseif x >= 50 and x <= 170 and y >= 360 and y <= 400 then  -- VOL -
            self.volume = math.max(0, self.volume - 0.1)
            AudioManager:setMIDIVolume(self.volume)
        elseif x >= 180 and x <= 300 and y >= 360 and y <= 400 then  -- VOL +
            self.volume = math.min(1.0, self.volume + 0.1)
            AudioManager:setMIDIVolume(self.volume)
        end
    end
end

function MidiTestScreen:play_midi()
    if self.selected_file_index < 1 or self.selected_file_index > #self.midi_files then
        print("[MidiTestScreen] No file selected")
        return
    end

    local file_info = self.midi_files[self.selected_file_index]
    print("[MidiTestScreen] Playing: " .. file_info.path)

    local success = AudioManager:playMIDI(file_info.path)
    if success then
        print("[MidiTestScreen] Playback started")
    else
        print("[MidiTestScreen] Playback failed")
    end
end

function MidiTestScreen:pause_midi()
    print("[MidiTestScreen] Pausing")
    AudioManager:pauseMIDI()
end

function MidiTestScreen:stop_midi()
    print("[MidiTestScreen] Stopping")
    AudioManager:stopMIDI()
end

function MidiTestScreen:mousereleased(x, y, button, istouch, presses) end
function MidiTestScreen:mousemoved(x, y, dx, dy, istouch) end
function MidiTestScreen:wheelmoved(x, y) end

return MidiTestScreen
