local love = require("love")
local MIDI = require("audio.midi_parser")

local MidiPlayer = {
    currentSource = nil,
    isPlaying = false,
    midiData = nil,
    currentEventIndex = 1,
    startTime = 0,
    tempo = 120, -- BPM
    ppq = 96, -- pulses per quarter note
    noteSources = {}, -- Cache for note sources
    activeNotes = {} -- Currently playing notes
}

-- Note frequencies (A4 = 440Hz)
local noteFrequencies = {
    [0] = 8.1758,   -- C-1
    [1] = 8.66196,  -- C#-1
    [2] = 9.17702,  -- D-1
    [3] = 9.72272,  -- D#-1
    [4] = 10.3009,  -- E-1
    [5] = 10.9134,  -- F-1
    [6] = 11.5623,  -- F#-1
    [7] = 12.2499,  -- G-1
    [8] = 12.9783,  -- G#-1
    [9] = 13.75,    -- A-1
    [10] = 14.5676, -- A#-1
    [11] = 15.4339, -- B-1
    [12] = 16.3516, -- C0
    [13] = 17.3239, -- C#0
    [14] = 18.354,  -- D0
    [15] = 19.4454, -- D#0
    [16] = 20.6017, -- E0
    [17] = 21.8268, -- F0
    [18] = 23.1247, -- F#0
    [19] = 24.4997, -- G0
    [20] = 25.9565, -- G#0
    [21] = 27.5,    -- A0
    [22] = 29.1352, -- A#0
    [23] = 30.8677, -- B0
    [24] = 32.7032, -- C1
    [25] = 34.6478, -- C#1
    [26] = 36.7081, -- D1
    [27] = 38.8909, -- D#1
    [28] = 41.2034, -- E1
    [29] = 43.6535, -- F1
    [30] = 46.2493, -- F#1
    [31] = 48.9994, -- G1
    [32] = 51.9131, -- G#1
    [33] = 55.0,    -- A1
    [34] = 58.2705, -- A#1
    [35] = 61.7354, -- B1
    [36] = 65.4064, -- C2
    [37] = 69.2957, -- C#2
    [38] = 73.4162, -- D2
    [39] = 77.7817, -- D#2
    [40] = 82.4069, -- E2
    [41] = 87.3071, -- F2
    [42] = 92.4986, -- F#2
    [43] = 97.9989, -- G2
    [44] = 103.826, -- G#2
    [45] = 110.0,   -- A2
    [46] = 116.541, -- A#2
    [47] = 123.471, -- B2
    [48] = 130.813, -- C3
    [49] = 138.591, -- C#3
    [50] = 146.832, -- D3
    [51] = 155.563, -- D#3
    [52] = 164.814, -- E3
    [53] = 174.614, -- F3
    [54] = 184.997, -- F#3
    [55] = 195.998, -- G3
    [56] = 207.652, -- G#3
    [57] = 220.0,   -- A3
    [58] = 233.082, -- A#3
    [59] = 246.942, -- B3
    [60] = 261.626, -- C4 (Middle C)
    [61] = 277.183, -- C#4
    [62] = 293.665, -- D4
    [63] = 311.127, -- D#4
    [64] = 329.628, -- E4
    [65] = 349.228, -- F4
    [66] = 369.994, -- F#4
    [67] = 391.995, -- G4
    [68] = 415.305, -- G#4
    [69] = 440.0,   -- A4
    [70] = 466.164, -- A#4
    [71] = 493.883, -- B4
    [72] = 523.251, -- C5
    [73] = 554.365, -- C#5
    [74] = 587.33,  -- D5
    [75] = 622.254, -- D#5
    [76] = 659.255, -- E5
    [77] = 698.456, -- F5
    [78] = 739.989, -- F#5
    [79] = 783.991, -- G5
    [80] = 830.609, -- G#5
    [81] = 880.0,   -- A5
    [82] = 932.328, -- A#5
    [83] = 987.767, -- B5
    [84] = 1046.5,  -- C6
    [85] = 1108.73, -- C#6
    [86] = 1174.66, -- D6
    [87] = 1244.51, -- D#6
    [88] = 1318.51, -- E6
    [89] = 1396.91, -- F6
    [90] = 1479.98, -- F#6
    [91] = 1567.98, -- G6
    [92] = 1661.22, -- G#6
    [93] = 1760.0,  -- A6
    [94] = 1864.66, -- A#6
    [95] = 1975.53, -- B6
    [96] = 2093.0,  -- C7
    [97] = 2217.46, -- C#7
    [98] = 2349.32, -- D7
    [99] = 2489.02, -- D#7
    [100] = 2637.02, -- E7
    [101] = 2793.83, -- F7
    [102] = 2959.96, -- F#7
    [103] = 3135.96, -- G7
    [104] = 3322.44, -- G#7
    [105] = 3520.0,  -- A7
    [106] = 3729.31, -- A#7
    [107] = 3951.07, -- B7
    [108] = 4186.01, -- C8
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

-- Convert MIDI ticks to seconds
function MidiPlayer:ticksToSeconds(ticks)
    -- Tempo is in microseconds per quarter note
    local secondsPerQuarter = self.tempo / 1000000.0
    local secondsPerTick = secondsPerQuarter / self.ppq
    return ticks * secondsPerTick
end

function MidiPlayer:play(filePath)
    -- Stop any currently playing MIDI
    self:stop()

    -- Convert relative path to absolute if needed
    if not filePath:match("^%a:") then
        ---@diagnostic disable-next-line
        filePath = love.filesystem.getSource() .. "/" .. filePath
    end

    -- Parse MIDI file
    self.midiData = MIDI.load(filePath)
    if not self.midiData then
        print("[ERROR] Failed to parse MIDI file: " .. filePath)
        return false
    end

    -- Extract tempo and timing info
    self.ppq = self.midiData.header.ppq or 96
    self.tempo = 500000 -- Default 120 BPM (500,000 microseconds per quarter note)

    -- Find tempo events
    for _, track in ipairs(self.midiData.tracks) do
        for _, event in ipairs(track.events) do
            if event.type == "meta" and event.metaType == 0x51 then -- Tempo change
                self.tempo = MIDI.readVariableLength(event.data, 1)
            end
        end
    end

    self.isPlaying = true
    self.currentEventIndex = 1
    self.startTime = love.timer.getTime()

    print("[MIDI] Started playing: " .. filePath .. " (in-game)")
    return true
end

function MidiPlayer:stop()
    if self.isPlaying then
        -- Stop all active notes
        for note, source in pairs(self.activeNotes) do
            if source:isPlaying() then
                source:stop()
            end
        end
        self.activeNotes = {}
        self.isPlaying = false
        print("[MIDI] Stopped playback")
    end
end

function MidiPlayer:update(dt)
    if not self.isPlaying or not self.midiData then return end

    local currentTime = love.timer.getTime() - self.startTime

    -- Process MIDI events
    for _, track in ipairs(self.midiData.tracks) do
        for i = self.currentEventIndex, #track.events do
            local event = track.events[i]
            local eventTime = self:ticksToSeconds(event.deltaTime or 0)

            if currentTime >= eventTime then
                self:processEvent(event)
                self.currentEventIndex = i + 1
            else
                break
            end
        end
    end

    -- Check if we've reached the end
    local hasMoreEvents = false
    for _, track in ipairs(self.midiData.tracks) do
        if self.currentEventIndex <= #track.events then
            hasMoreEvents = true
            break
        end
    end

    if not hasMoreEvents then
        self:stop()
    end
end

function MidiPlayer:processEvent(event)
    if event.type == "midi" then
        if event.status >= 0x80 and event.status <= 0x8F then -- Note off
            local note = event.data1
            if self.activeNotes[note] then
                self.activeNotes[note]:stop()
                self.activeNotes[note] = nil
            end
        elseif event.status >= 0x90 and event.status <= 0x9F then -- Note on
            local note = event.data1
            local velocity = event.data2

            if velocity > 0 then
                -- Note on
                local frequency = noteFrequencies[note] or 440
                if frequency then
                    -- Generate and play tone
                    local toneData = generateTone(frequency, 1.0) -- 1 second duration
                    local source = love.audio.newSource(toneData)
                    source:setLooping(true) -- Will be stopped by note off
                    source:play()
                    self.activeNotes[note] = source
                end
            else
                -- Note off (velocity 0)
                if self.activeNotes[note] then
                    self.activeNotes[note]:stop()
                    self.activeNotes[note] = nil
                end
            end
        end
    end
end

function MidiPlayer:isPlaying()
    return self.isPlaying
end

function MidiPlayer:setVolume(volume)
    -- Set volume for all active notes
    for _, source in pairs(self.activeNotes) do
        source:setVolume(volume)
    end
end

return MidiPlayer
