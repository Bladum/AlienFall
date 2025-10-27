-- Create a random song MIDI file with drums and piano
local function create_random_midi()
    -- MIDI file data will be built as a string of bytes
    local midi_data = {}

    -- Helper function to add bytes
    local function add_byte(byte)
        table.insert(midi_data, string.char(byte))
    end

    -- Helper function to add multiple bytes
    local function add_bytes(...)
        for _, byte in ipairs({...}) do
            add_byte(byte)
        end
    end

    -- Helper function for variable length quantities
    local function write_var_len(value)
        local buffer = {}
        local continue = true
        while continue do
            local byte = bit.band(value, 0x7F)
            value = bit.rshift(value, 7)
            if value > 0 then
                byte = bit.bor(byte, 0x80)
            end
            table.insert(buffer, 1, byte)
            continue = value > 0
        end
        for _, byte in ipairs(buffer) do
            add_byte(byte)
        end
    end

    -- MThd header
    add_bytes(0x4D, 0x54, 0x68, 0x64)  -- 'MThd'
    add_bytes(0x00, 0x00, 0x00, 0x06)  -- Header length
    add_bytes(0x00, 0x01)              -- Format 1 (multiple tracks)
    add_bytes(0x00, 0x03)              -- 3 tracks (tempo, piano, drums)
    add_bytes(0x00, 0x60)              -- 96 PPQ

    -- Track 1: Tempo track
    add_bytes(0x4D, 0x54, 0x72, 0x6B)  -- 'MTrk'
    local tempo_track_start = #midi_data + 1
    add_bytes(0x00, 0x00, 0x00, 0x00)  -- Placeholder for track length

    -- Tempo meta event (120 BPM = 500,000 microseconds per quarter)
    add_byte(0x00)                     -- Delta time
    add_bytes(0xFF, 0x51, 0x03)        -- Tempo meta event
    add_bytes(0x07, 0xA1, 0x20)        -- 500,000 us per quarter

    -- Time signature (4/4)
    add_byte(0x00)                     -- Delta time
    add_bytes(0xFF, 0x58, 0x04)        -- Time signature meta event
    add_bytes(0x04, 0x02, 0x18, 0x08)  -- 4/4, 24 clocks per quarter, 8 32nds per quarter

    -- End of track
    add_byte(0x00)                     -- Delta time
    add_bytes(0xFF, 0x2F, 0x00)        -- End of track

    -- Calculate and set track length
    local tempo_track_end = #midi_data
    local tempo_track_length = tempo_track_end - tempo_track_start - 3  -- Subtract 4 bytes for length field, but we added 4 placeholder bytes
    midi_data[tempo_track_start] = string.char(bit.band(bit.rshift(tempo_track_length, 24), 0xFF))
    midi_data[tempo_track_start + 1] = string.char(bit.band(bit.rshift(tempo_track_length, 16), 0xFF))
    midi_data[tempo_track_start + 2] = string.char(bit.band(bit.rshift(tempo_track_length, 8), 0xFF))
    midi_data[tempo_track_start + 3] = string.char(bit.band(tempo_track_length, 0xFF))

    -- Track 2: Piano melody
    add_bytes(0x4D, 0x54, 0x72, 0x6B)  -- 'MTrk'
    local piano_track_start = #midi_data + 1
    add_bytes(0x00, 0x00, 0x00, 0x00)  -- Placeholder for track length

    -- Program change to piano (channel 0)
    add_byte(0x00)                     -- Delta time
    add_bytes(0xC0, 0x00)              -- Program change channel 0, piano

    -- Generate random piano melody (4 bars, 4 beats per bar)
    local piano_notes = {60, 62, 64, 65, 67, 69, 71, 72}  -- C major scale
    local current_time = 0

    for bar = 1, 4 do
        for beat = 1, 4 do
            -- Random note from scale
            local note = piano_notes[math.random(#piano_notes)]
            local velocity = 64 + math.random(32)  -- 64-95
            local duration = 24 * (math.random(2) + 1)  -- 24 or 48 ticks (eighth or quarter note)

            -- Note on
            write_var_len(current_time)
            add_bytes(0x90, note, velocity)  -- Note on channel 0

            -- Note off
            write_var_len(duration)
            add_bytes(0x80, note, 0x40)     -- Note off channel 0

            current_time = 0  -- Reset for next note
        end
    end

    -- End of track
    add_byte(0x00)                     -- Delta time
    add_bytes(0xFF, 0x2F, 0x00)        -- End of track

    -- Calculate and set track length
    local piano_track_end = #midi_data
    local piano_track_length = piano_track_end - piano_track_start - 3
    midi_data[piano_track_start] = string.char(bit.band(bit.rshift(piano_track_length, 24), 0xFF))
    midi_data[piano_track_start + 1] = string.char(bit.band(bit.rshift(piano_track_length, 16), 0xFF))
    midi_data[piano_track_start + 2] = string.char(bit.band(bit.rshift(piano_track_length, 8), 0xFF))
    midi_data[piano_track_start + 3] = string.char(bit.band(piano_track_length, 0xFF))

    -- Track 3: Drum track
    add_bytes(0x4D, 0x54, 0x72, 0x6B)  -- 'MTrk'
    local drum_track_start = #midi_data + 1
    add_bytes(0x00, 0x00, 0x00, 0x00)  -- Placeholder for track length

    -- Generate drum pattern (4 bars, 16th notes)
    local drum_patterns = {
        {note = 36, prob = 0.8},  -- Bass drum
        {note = 38, prob = 0.3},  -- Snare
        {note = 42, prob = 0.2},  -- Closed hi-hat
        {note = 46, prob = 0.1},  -- Open hi-hat
    }

    current_time = 0
    for bar = 1, 4 do
        for beat = 1, 4 do
            for sixteenth = 1, 4 do
                -- Check each drum for this 16th note
                for _, drum in ipairs(drum_patterns) do
                    if math.random() < drum.prob then
                        -- Play drum hit
                        write_var_len(current_time)
                        add_bytes(0x99, drum.note, 100 + math.random(27))  -- Note on channel 9 (drums)

                        -- Note off (short duration)
                        add_byte(0x06)  -- 6 ticks later
                        add_bytes(0x89, drum.note, 0x40)  -- Note off channel 9
                        current_time = 0
                    end
                end
                current_time = 6  -- 6 ticks per 16th note (96 PPQ / 16 = 6)
            end
        end
    end

    -- End of track
    add_byte(0x00)                     -- Delta time
    add_bytes(0xFF, 0x2F, 0x00)        -- End of track

    -- Calculate and set track length
    local drum_track_end = #midi_data
    local drum_track_length = drum_track_end - drum_track_start - 3
    midi_data[drum_track_start] = string.char(bit.band(bit.rshift(drum_track_length, 24), 0xFF))
    midi_data[drum_track_start + 1] = string.char(bit.band(bit.rshift(drum_track_length, 16), 0xFF))
    midi_data[drum_track_start + 2] = string.char(bit.band(bit.rshift(drum_track_length, 8), 0xFF))
    midi_data[drum_track_start + 3] = string.char(bit.band(drum_track_length, 0xFF))

    -- Write to file
    local file = io.open("MIDI TEST/random_song.mid", "wb")
    if file then
        file:write(table.concat(midi_data))
        file:close()
        print("Created random MIDI song: MIDI TEST/random_song.mid")
        print(string.format("File size: %d bytes", #midi_data))
        return true
    else
        print("Error: Could not create MIDI file")
        return false
    end
end

-- Run the function
math.randomseed(os.time())
create_random_midi()
