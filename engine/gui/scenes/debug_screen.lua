-- Debug Screen for Testing File Discovery and Button Clicks

local AudioManager = require("core.audio_manager")

local DebugScreen = {
    midi_files = {},
    messages = {},
    buttons = {},
}

function DebugScreen:enter()
    print("[DebugScreen] ENTERING DEBUG SCREEN")
    self:addMessage("=== DEBUG SCREEN ===")
    self:addMessage("Testing file discovery and button clicks")

    -- Scan for files
    self:scanForMidiFiles()

    -- Initialize buttons
    self:initializeButtons()
end

function DebugScreen:addMessage(msg)
    table.insert(self.messages, msg)
    print("[DebugScreen] " .. msg)
end

function DebugScreen:scanForMidiFiles()
    self.midi_files = {}
    self:addMessage("Scanning for MIDI files...")

    -- List all Love2D search paths
    self:addMessage("Love2D source dir: " .. love.filesystem.getSource())

    local dirs = {"assets/music/midi"}
    for _, dir in ipairs(dirs) do
        local success, items = pcall(love.filesystem.getDirectoryItems, dir)
        if success then
            self:addMessage("✓ " .. dir .. " (" .. #items .. " items)")
            for _, file in ipairs(items) do
                if file:match("%.mid$") or file:match("%.MID$") then
                    self.midi_files[#self.midi_files + 1] = dir .. "/" .. file
                    self:addMessage("  FOUND: " .. file)
                end
            end
        else
            self:addMessage("✗ Cannot read: " .. dir)
        end
    end

    self:addMessage("Total MIDI files found: " .. #self.midi_files)
end

function DebugScreen:initializeButtons()
    self.buttons = {
        {x = 50, y = 400, w = 100, h = 40, label = "TEST PLAY", action = function()
            self:addMessage("BUTTON CLICKED: TEST PLAY")
            if #self.midi_files > 0 then
                self:addMessage("Attempting to play: " .. self.midi_files[1])
                AudioManager:playMIDI(self.midi_files[1])
                self:addMessage("Play command sent")
            else
                self:addMessage("No MIDI files found!")
            end
        end},
        {x = 160, y = 400, w = 100, h = 40, label = "TEST STOP", action = function()
            self:addMessage("BUTTON CLICKED: TEST STOP")
            AudioManager:stopMIDI()
        end},
        {x = 270, y = 400, w = 100, h = 40, label = "CLEAR LOG", action = function()
            self.messages = {}
            self:addMessage("Log cleared")
        end},
    }
end

function DebugScreen:update(dt)
    if self.ui_initialized == nil then
        self.ui_initialized = true
        print("[DebugScreen] First update call")
    end
    AudioManager:update(dt)
end

function DebugScreen:draw()
    love.graphics.clear(0.05, 0.05, 0.1)

    -- Draw title
    love.graphics.setColor(1, 1, 0)
    love.graphics.printf("DEBUG SCREEN - MIDI File Discovery", 0, 20, love.graphics.getWidth(), "center")

    -- Draw messages
    love.graphics.setColor(0.7, 1, 0.7)
    local y = 80
    for i, msg in ipairs(self.messages) do
        if i > 20 then break end  -- Limit displayed messages
        love.graphics.print(msg, 50, y)
        y = y + 20
    end

    -- Draw buttons
    for _, btn in ipairs(self.buttons) do
        love.graphics.setColor(0.3, 0.6, 0.3)
        love.graphics.rectangle("fill", btn.x, btn.y, btn.w, btn.h)
        love.graphics.setColor(0.5, 1, 0.5)
        love.graphics.rectangle("line", btn.x, btn.y, btn.w, btn.h)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(btn.label, btn.x, btn.y + 10, btn.w, "center")
    end

    -- Draw status
    love.graphics.setColor(0.7, 0.7, 1)
    local status = AudioManager:getMIDIStatus()
    love.graphics.print("MIDI Status: " .. status, 50, love.graphics.getHeight() - 30)
end

function DebugScreen:keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "space" then
        self:addMessage("SPACE PRESSED")
        if #self.midi_files > 0 then
            AudioManager:playMIDI(self.midi_files[1])
            self:addMessage("Started playback")
        end
    end
end

function DebugScreen:mousepressed(x, y, button)
    if button == 1 then
        for _, btn in ipairs(self.buttons) do
            if x >= btn.x and x <= btn.x + btn.w and
               y >= btn.y and y <= btn.y + btn.h then
                btn.action()
                return
            end
        end
        self:addMessage("Click at " .. x .. ", " .. y)
    end
end

function DebugScreen:mousereleased(x, y, button) end
function DebugScreen:mousemoved(x, y, dx, dy) end
function DebugScreen:wheelmoved(x, y) end

return DebugScreen
