-- Lua MIDI Parser Library
-- Based on the MIDI file format specification
-- This is a basic parser for reading MIDI files

local MIDI = {}

-- MIDI file format constants
MIDI.FORMAT_SINGLE_TRACK = 0
MIDI.FORMAT_MULTI_TRACK = 1
MIDI.FORMAT_SEQUENTIAL = 2

-- MIDI event types
MIDI.EVENT_NOTE_OFF = 0x80
MIDI.EVENT_NOTE_ON = 0x90
MIDI.EVENT_POLYPHONIC_PRESSURE = 0xA0
MIDI.EVENT_CONTROLLER = 0xB0
MIDI.EVENT_PROGRAM_CHANGE = 0xC0
MIDI.EVENT_CHANNEL_PRESSURE = 0xD0
MIDI.EVENT_PITCH_BEND = 0xE0
MIDI.EVENT_SYSTEM_EXCLUSIVE = 0xF0
MIDI.EVENT_META = 0xFF

-- Meta event types
MIDI.META_SEQUENCE_NUMBER = 0x00
MIDI.META_TEXT = 0x01
MIDI.META_COPYRIGHT = 0x02
MIDI.META_TRACK_NAME = 0x03
MIDI.META_INSTRUMENT_NAME = 0x04
MIDI.META_LYRIC = 0x05
MIDI.META_MARKER = 0x06
MIDI.META_CUE_POINT = 0x07
MIDI.META_CHANNEL_PREFIX = 0x20
MIDI.META_END_OF_TRACK = 0x2F
MIDI.META_SET_TEMPO = 0x51
MIDI.META_SMPTE_OFFSET = 0x54
MIDI.META_TIME_SIGNATURE = 0x58
MIDI.META_KEY_SIGNATURE = 0x59
MIDI.META_SEQUENCER_SPECIFIC = 0x7F

-- Utility functions
local function read_u16_be(data, pos)
    return bit.lshift(data:byte(pos), 8) + data:byte(pos + 1)
end

local function read_u32_be(data, pos)
    return bit.lshift(read_u16_be(data, pos), 16) + read_u16_be(data, pos + 2)
end

local function read_variable_length(data, pos)
    local value = 0
    local byte
    repeat
        byte = data:byte(pos)
        pos = pos + 1
        value = bit.lshift(value, 7) + bit.band(byte, 0x7F)
    until byte < 0x80
    return value, pos
end

-- Parse MIDI file
function MIDI.parse(data)
    local midi = {
        format = nil,
        tracks = {},
        division = nil
    }

    local pos = 1

    -- Check header
    if data:sub(pos, pos + 3) ~= "MThd" then
        error("Invalid MIDI file: missing MThd")
    end
    pos = pos + 4

    local header_length = read_u32_be(data, pos)
    pos = pos + 4

    midi.format = read_u16_be(data, pos)
    pos = pos + 2

    local num_tracks = read_u16_be(data, pos)
    pos = pos + 2

    midi.division = read_u16_be(data, pos)
    pos = pos + 2

    -- Parse tracks
    for track_idx = 1, num_tracks do
        if data:sub(pos, pos + 3) ~= "MTrk" then
            error("Invalid MIDI file: missing MTrk at track " .. track_idx)
        end
        pos = pos + 4

        local track_length = read_u32_be(data, pos)
        pos = pos + 4

        local track_end = pos + track_length - 1
        local track = {
            events = {}
        }

        local last_status = 0

        while pos <= track_end do
            local delta_time, new_pos = read_variable_length(data, pos)
            pos = new_pos

            local status = data:byte(pos)
            pos = pos + 1

            if status < 0x80 then
                -- Running status
                status = last_status
                pos = pos - 1  -- Put back the data byte
            end

            last_status = status

            local event = {
                delta_time = delta_time,
                type = bit.band(status, 0xF0),
                channel = bit.band(status, 0x0F)
            }

            if event.type == MIDI.EVENT_NOTE_OFF or event.type == MIDI.EVENT_NOTE_ON or
               event.type == MIDI.EVENT_POLYPHONIC_PRESSURE or event.type == MIDI.EVENT_CONTROLLER or
               event.type == MIDI.EVENT_PITCH_BEND then
                event.note = data:byte(pos)
                pos = pos + 1
                event.velocity = data:byte(pos)
                pos = pos + 1
            elseif event.type == MIDI.EVENT_PROGRAM_CHANGE or event.type == MIDI.EVENT_CHANNEL_PRESSURE then
                event.value = data:byte(pos)
                pos = pos + 1
            elseif status == MIDI.EVENT_SYSTEM_EXCLUSIVE then
                -- System exclusive (simplified)
                event.data = {}
                while data:byte(pos) ~= 0xF7 do
                    table.insert(event.data, data:byte(pos))
                    pos = pos + 1
                end
                pos = pos + 1  -- Skip F7
            elseif status == MIDI.EVENT_META then
                event.meta_type = data:byte(pos)
                pos = pos + 1
                local length, new_pos = read_variable_length(data, pos)
                pos = new_pos
                event.data = data:sub(pos, pos + length - 1)
                pos = pos + length
            end

            table.insert(track.events, event)

            if event.type == MIDI.EVENT_META and event.meta_type == MIDI.META_END_OF_TRACK then
                break
            end
        end

        table.insert(midi.tracks, track)
    end

    return midi
end

-- Load MIDI file from path
function MIDI.load(filename)
    local file = io.open(filename, "rb")
    if not file then
        error("Could not open MIDI file: " .. filename)
    end
    local data = file:read("*all")
    file:close()
    return MIDI.parse(data)
end

-- Get track names
function MIDI.get_track_names(midi)
    local names = {}
    for _, track in ipairs(midi.tracks) do
        for _, event in ipairs(track.events) do
            if event.type == MIDI.EVENT_META and event.meta_type == MIDI.META_TRACK_NAME then
                table.insert(names, event.data)
                break
            end
        end
    end
    return names
end

-- Get tempo events
function MIDI.get_tempo_events(midi)
    local tempos = {}
    for track_idx, track in ipairs(midi.tracks) do
        local time = 0
        for _, event in ipairs(track.events) do
            time = time + event.delta_time
            if event.type == MIDI.EVENT_META and event.meta_type == MIDI.META_SET_TEMPO then
                local tempo = (event.data:byte(1) * 65536) + (event.data:byte(2) * 256) + event.data:byte(3)
                table.insert(tempos, {time = time, tempo = tempo, track = track_idx})
            end
        end
    end
    return tempos
end

return MIDI
