#!/usr/bin/env lua

-- Direct MIDI test for Queen - Bohemian Rhapsody
-- Run with: love "tests" or lovec "tests"

local MidiPlayer = require("audio.midi_player")

function love.load()
    print("=== Testing Queen - Bohemian Rhapsody MIDI ===")

    -- Path to the uploaded MIDI file
    local midiPath = "MIDI TEST/Queen - Bohemian Rhapsody.mid"
    print("Playing: " .. midiPath)

    -- Check if file exists
    local file = io.open(midiPath, "rb")
    if not file then
        print("ERROR: MIDI file not found at " .. midiPath)
        print("Available files in MIDI TEST:")
        local dir = "MIDI TEST"
        for name, _ in pairs(love.filesystem.getDirectoryItems(dir)) do
            print("  - " .. name)
        end
        return
    end
    file:close()
    print("MIDI file found!")

    -- Start playing
    print("Starting MIDI playback...")
    if MidiPlayer:play(midiPath) then
        print("SUCCESS: Queen - Bohemian Rhapsody started!")
    else
        print("ERROR: Failed to start MIDI playback")
    end

    -- Let it play for 60 seconds (full song length)
    print("Playing for 60 seconds...")
end

function love.update(dt)
    -- Update MIDI player
    MidiPlayer:update(dt)
end

function love.draw()
    love.graphics.print("Playing: Queen - Bohemian Rhapsody", 10, 10)
    love.graphics.print("Check console output for details", 10, 30)
    love.graphics.print("Press ESC to stop", 10, 50)
end

function love.keypressed(key)
    if key == "escape" then
        print("Stopping MIDI playback...")
        MidiPlayer:stop()
        love.event.quit()
    end
end
