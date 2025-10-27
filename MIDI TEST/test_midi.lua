-- Test script to verify MIDI file parsing
-- Include midi_player code directly
local love = require("love")

local MidiPlayer = {
    isPlaying = false,
    currentNoteIndex = 1,
    startTime = 0,
    notes = {}, -- Simple note sequence: {time, note, duration, velocity}
    activeSources = {} -- Currently playing audio sources
}

-- Note frequencies (A4 = 440Hz)
local noteFrequencies = {
    [60] = 261.63,  -- C4 (Middle C)
    [61] = 277.18,  -- C#4
    [62] = 293.66,  -- D4
    [63] = 311.13,  -- D#4
    [64] = 329.63,  -- E4
    [65] = 349.23,  -- F4
    [66] = 369.99,  -- F#4
    [67] = 392.00,  -- G4
    [68] = 415.30,  -- G#4
    [69] = 440.00,  -- A4
    [70] = 466.16,  -- A#4
    [71] = 493.88,  -- B4
    [72] = 523.25,  -- C5
}

-- Generate a simple sine wave tone
local function generateTone(frequency, duration, sampleRate)
    sampleRate = sampleRate or 44100
    local samples = math.floor(duration * sampleRate)
    local data = love.sound.newSoundData(samples, sampleRate, 16, 1)

    for i = 0, samples - 1 do
        local t = i / sampleRate
        local sample = math.sin(2 * math.pi * frequency * t) * 0.3 -- 30% volume
        data:setSample(i, sample)
    end

    return data
end

-- Parse simple MIDI file (just extract note events)
function MidiPlayer:parseSimpleMIDI(filePath)
    local file = io.open(filePath, "rb")
    if not file then
        print("[ERROR] Cannot open MIDI file: " .. filePath)
        return false
    end

    local data = file:read("*all")
    file:close()

    print("[DEBUG] MIDI file size: " .. #data .. " bytes")

    -- Check MThd header
    if #data < 14 then
        print("[ERROR] MIDI file too small")
        return false
    end

    -- Read header bytes
    local pos = 1
    local header = {}
    for i = 1, 14 do
        header[i] = string.byte(data, i)
    end

    print(string.format("[DEBUG] Header bytes: %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X %02X",
        header[1], header[2], header[3], header[4], header[5], header[6], header[7], header[8],
        header[9], header[10], header[11], header[12], header[13], header[14]))

    -- Check for MThd
    if header[1] ~= 0x4D or header[2] ~= 0x54 or header[3] ~= 0x68 or header[4] ~= 0x64 then
        print("[ERROR] Invalid MIDI header")
        return false
    end

    -- Get format and number of tracks
    local format = header[9] * 256 + header[10]
    local numTracks = header[11] * 256 + header[12]
    local ppq = header[13] * 256 + header[14]

    print(string.format("[DEBUG] Format: %d, Tracks: %d, PPQ: %d", format, numTracks, ppq))

    pos = 15 -- Move past header

    local notes = {}
    local tempo = 120 -- Default BPM
    local microsecondsPerQuarter = 500000 -- Default tempo

    -- Parse tracks
    for trackNum = 1, numTracks do
        print(string.format("[DEBUG] Parsing track %d", trackNum))

        if pos + 8 > #data then
            print("[ERROR] Unexpected end of file in track header")
            break
        end

        -- Check for MTrk
        local trackHeader = {}
        for i = 1, 8 do
            trackHeader[i] = string.byte(data, pos + i - 1)
        end

        print(string.format("[DEBUG] Track header bytes: %02X %02X %02X %02X %02X %02X %02X %02X",
            trackHeader[1], trackHeader[2], trackHeader[3], trackHeader[4],
            trackHeader[5], trackHeader[6], trackHeader[7], trackHeader[8]))

        if trackHeader[1] ~= 0x4D or trackHeader[2] ~= 0x54 or trackHeader[3] ~= 0x72 or trackHeader[4] ~= 0x6B then
            print(string.format("[ERROR] Invalid track header for track %d", trackNum))
            break
        end

        -- Get track length
        local trackLength = trackHeader[5] * 0x1000000 + trackHeader[6] * 0x10000 + trackHeader[7] * 0x100 + trackHeader[8]
        print(string.format("[DEBUG] Track %d length: %d bytes", trackNum, trackLength))

        pos = pos + 8 -- Move past track header
        local trackEnd = pos + trackLength - 1

        local currentTime = 0
        local lastStatus = 0

        while pos <= trackEnd do
            -- Read variable length delta time
            local deltaTime = 0
            local byte
            repeat
                byte = string.byte(data, pos)
                pos = pos + 1
                deltaTime = bit.lshift(deltaTime, 7) + bit.band(byte, 0x7F)
            until bit.band(byte, 0x80) == 0

            currentTime = currentTime + deltaTime

            -- Read status byte
            local status = string.byte(data, pos)
            pos = pos + 1

            -- Handle running status
            if bit.band(status, 0x80) == 0 then
                status = lastStatus
                pos = pos - 1 -- Put back the data byte
            end

            lastStatus = status

            local eventType = bit.band(status, 0xF0)
            local channel = bit.band(status, 0x0F)

            if eventType == 0x90 or eventType == 0x80 then -- Note on/off
                local note = string.byte(data, pos)
                pos = pos + 1
                local velocity = string.byte(data, pos)
                pos = pos + 1

                if eventType == 0x90 and velocity > 0 then -- Note on
                    table.insert(notes, {
                        time = currentTime / ppq * 60 / (tempo / 60), -- Convert to seconds
                        pitch = note,
                        velocity = velocity,
                        duration = 0.5, -- Default duration, will be updated on note off
                        channel = channel
                    })
                    print(string.format("[DEBUG] Note on: pitch=%d, velocity=%d, time=%d ticks, channel=%d",
                        note, velocity, currentTime, channel))
                elseif eventType == 0x80 or (eventType == 0x90 and velocity == 0) then -- Note off
                    -- Find the corresponding note on and update duration
                    for i = #notes, 1, -1 do
                        if notes[i].pitch == note and notes[i].channel == channel and notes[i].duration == 0.5 then
                            notes[i].duration = (currentTime - (notes[i].time * ppq * tempo / 60)) / ppq * 60 / (tempo / 60)
                            break
                        end
                    end
                end
            elseif status == 0xFF then -- Meta event
                local metaType = string.byte(data, pos)
                pos = pos + 1
                local length = string.byte(data, pos)
                pos = pos + 1

                if metaType == 0x51 and length == 3 then -- Tempo
                    microsecondsPerQuarter = string.byte(data, pos) * 0x10000 +
                                            string.byte(data, pos + 1) * 0x100 +
                                            string.byte(data, pos + 2)
                    tempo = 60000000 / microsecondsPerQuarter
                    print(string.format("[DEBUG] Tempo change: %d BPM", tempo))
                end

                pos = pos + length
            elseif eventType == 0xC0 then -- Program change
                local program = string.byte(data, pos)
                pos = pos + 1
                print(string.format("[DEBUG] Program change: channel=%d, program=%d", channel, program))
            else
                -- Skip unknown events
                if eventType >= 0x80 and eventType < 0xF0 then
                    -- Channel events have 1 or 2 data bytes
                    if eventType ~= 0xC0 and eventType ~= 0xD0 then
                        pos = pos + 1 -- Skip data byte
                    end
                end
            end

            if pos > trackEnd then
                break
            end
        end
    end

    print(string.format("[DEBUG] Found %d notes total", #notes))

    return {
        notes = notes,
        tempo = tempo,
        duration = #notes > 0 and (notes[#notes].time + notes[#notes].duration) * 60 / (tempo * 96) or 0
    }
end

function love.load()
    print("Testing MIDI file parsing...")

    -- Test parsing the random song
    local midi_data = MidiPlayer:parseSimpleMIDI("random_song.mid")
    if midi_data then
        print(string.format("Successfully parsed MIDI file with %d notes", #midi_data.notes))
        print(string.format("Tempo: %d BPM", midi_data.tempo or 120))
        print(string.format("Total duration: %.2f seconds", midi_data.duration or 0))

        -- Print first few notes
        for i = 1, math.min(10, #midi_data.notes) do
            local note = midi_data.notes[i]
            local time_seconds = note.time / (96 * 120 / 60) -- Convert ticks to seconds
            local duration_seconds = note.duration / (96 * 120 / 60)
            print(string.format("Note %d: pitch=%d, velocity=%d, time=%.3f, duration=%.3f, channel=%d",
                i, note.pitch, note.velocity, time_seconds, duration_seconds, note.channel))
        end
    else
        print("Failed to parse MIDI file")
    end

    love.event.quit()
end
