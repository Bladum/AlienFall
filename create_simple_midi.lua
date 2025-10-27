-- Create a simple MIDI file for testing
-- Updated to use integrated MIDI location
local file = io.open("engine/assets/music/midi/simple.mid", "wb")
if not file then
    print("Could not create MIDI file")
    print("Make sure engine/assets/music/midi/ directory exists")
    return
end

-- MIDI file header (MThd)
file:write(string.char(
    0x4D, 0x54, 0x68, 0x64,  -- 'MThd'
    0x00, 0x00, 0x00, 0x06,  -- Header length (6)
    0x00, 0x00,              -- Format 0
    0x00, 0x01,              -- 1 track
    0x00, 0x60               -- 96 PPQ
))

-- Track header (MTrk)
file:write(string.char(
    0x4D, 0x54, 0x72, 0x6B,  -- 'MTrk'
    0x00, 0x00, 0x00, 0x0C   -- Track length (12 bytes)
))

-- Note on event: delta time 0, note on channel 0, note 60 (C4), velocity 64
file:write(string.char(
    0x00,  -- Delta time
    0x90,  -- Note on, channel 0
    0x3C,  -- Note C4 (60)
    0x40   -- Velocity 64
))

-- Note off event: delta time 96 (1 quarter note), note off channel 0, note 60, velocity 64
file:write(string.char(
    0x60,  -- Delta time (96)
    0x80,  -- Note off, channel 0
    0x3C,  -- Note C4 (60)
    0x40   -- Velocity 64
))

-- End of track: delta time 0, meta event FF 2F 00
file:write(string.char(
    0x00,     -- Delta time
    0xFF, 0x2F, 0x00  -- End of track
))

file:close()
print("Created simple MIDI file: engine/assets/music/midi/simple.mid")
