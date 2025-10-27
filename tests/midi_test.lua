#!/usr/bin/env lua

-- Simple test script to verify MIDI playback functionality
-- Run with: love "tests" or lovec "tests"

local MidiPlayer = require("audio.midi_player")

function love.load()
    print("=== MIDI Playback Test ===")

    -- Test parsing the MIDI file
    print("Testing MIDI file parsing...")
    local midiPath = "MIDI TEST/Queen - Bohemian Rhapsody.mid"
    print("Looking for MIDI file at: " .. midiPath)

    -- Check if file exists
    local file = io.open(midiPath, "rb")
    if not file then
        print("ERROR: MIDI file not found at " .. midiPath)
        return
    end
    file:close()
    print("MIDI file found!")

    -- Test playing the MIDI file
    print("Testing MIDI playback...")
    if MidiPlayer:play(midiPath) then
        print("SUCCESS: MIDI playback started!")
    else
        print("ERROR: Failed to start MIDI playback")
    end

    -- Set up a timer to stop after 30 seconds (for Bohemian Rhapsody)
    love.timer.sleep(30)
    MidiPlayer:stop()
    print("Test completed - MIDI playback stopped")
    love.event.quit()
end

function love.update(dt)
    -- Update MIDI player
    MidiPlayer:update(dt)
end

function love.draw()
    love.graphics.print("MIDI Test Running...", 10, 10)
    love.graphics.print("Playing: Queen - Bohemian Rhapsody.mid", 10, 30)
    love.graphics.print("Check console output for details", 10, 50)
end
