-- This is a binary MIDI file, but since we can't create binary files directly,
-- we'll create a Lua script that generates the MIDI file

local midi_data = string.char(
    -- MThd
    0x4D, 0x54, 0x68, 0x64,
    -- Header length: 6
    0x00, 0x00, 0x00, 0x06,
    -- Format: 0 (single track)
    0x00, 0x00,
    -- Tracks: 1
    0x00, 0x01,
    -- Division: 96 PPQ
    0x00, 0x60,
    -- MTrk
    0x4D, 0x54, 0x72, 0x6B,
    -- Track length: 21
    0x00, 0x00, 0x00, 0x15,
    -- Delta 0, Tempo meta event: FF 51 03 + 07 A1 20 (500000 us = 120 BPM)
    0x00, 0xFF, 0x51, 0x03, 0x07, 0xA1, 0x20,
    -- Delta 0, Note on channel 0: 90 3C 64 (C4 velocity 100)
    0x00, 0x90, 0x3C, 0x64,
    -- Delta 5760 (30 seconds at 120 BPM), Note off: 80 3C 64
    0x80, 0x2D, 0x80, 0x3C, 0x64,
    -- Delta 0, End of track: FF 2F 00
    0x00, 0xFF, 0x2F, 0x00
)

-- Write to file
local file = io.open("MIDI TEST/sample.mid", "wb")
if file then
    file:write(midi_data)
    file:close()
    print("Sample MIDI file created: MIDI TEST/sample.mid")
else
    print("Error: Could not create MIDI file")
end