local love = require("love")

local MidiPlayer = {
    isPlaying = false,
    currentNoteIndex = 1,
    startTime = 0,
    notes = {}, -- Simple note sequence: {time, note, duration, velocity}
    activeSources = {}, -- Currently playing audio sources
    sampler = nil -- Hexpress-style sampler for sample-based playback
}

-- Note frequencies (A4 = 440Hz) - keeping for fallback
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

-- Hexpress-style sampler (simplified version)
local sampler = {}
sampler.__index = sampler

function sampler.new(settings)
    local self = setmetatable({}, sampler)
    self.synths = {} -- collection of sources in an array
    self.masterVolume = settings.masterVolume or 1
    self.envelope = settings.envelope or {
        attack  = 0.01,  -- quick attack
        decay   = 0.1,   -- short decay
        sustain = 0.8,   -- sustain level
        release = 0.2    -- release time
    }
    local synthCount = settings.synthCount or 16 -- More synths for MIDI

    self.samples = {}
    if settings.samples then
        for i, sample in ipairs(settings.samples) do
            table.insert(self.samples, {
                path = sample.path,
                soundData = sample.soundData,
                note = sample.note or 60,
                velocity = sample.velocity or 0.8
            })
        end
    end

    -- initialize synths
    for i = 1, synthCount do
        self.synths[i] = {
            source = nil,
            volume = 0,
            active = false,
            duration = math.huge,
            enveloped = 0,
            note = 0,
            channel = 0
        }
    end
    return self
end

function sampler:playNote(note, velocity, channel)
    -- find available synth
    local selected = nil
    local maxDuration = -100
    for i, synth in ipairs(self.synths) do
        if synth.duration > maxDuration then
            maxDuration = synth.duration
            selected = i
        end
    end

    local synth = self.synths[selected]

    -- stop current source if playing
    if synth.source then
        synth.source:stop()
    end

    -- find best sample
    local sample = self:assignSample(note, velocity)
    if sample then
        synth.source = love.audio.newSource(sample.soundData)
        synth.source:setVolume(0) -- envelope will control this
        synth.source:setLooping(false)
        synth.source:play()

        synth.active = true
        synth.duration = 0
        synth.enveloped = 0
        synth.note = note
        synth.channel = channel
        synth.velocity = velocity

        return synth
    end
    return nil
end

function sampler:stopNote(note, channel)
    -- find synth playing this note
    for i, synth in ipairs(self.synths) do
        if synth.active and synth.note == note and synth.channel == channel then
            synth.active = false
            break
        end
    end
end

function sampler:assignSample(note, velocity)
    if #self.samples == 0 then return nil end

    -- find closest sample by note
    local bestFitness = math.huge
    local selected = nil
    for i, sample in ipairs(self.samples) do
        local fitness = math.abs(sample.note - note)
        if fitness < bestFitness then
            selected = i
            bestFitness = fitness
        end
    end
    return self.samples[selected]
end

function sampler:update(dt)
    for i, synth in ipairs(self.synths) do
        if synth.source then
            synth.enveloped = self:applyEnvelope(dt, synth.enveloped, synth.active, synth.duration)
            local volume = synth.enveloped * self.masterVolume * synth.velocity
            synth.source:setVolume(volume)
            synth.duration = synth.duration + dt

            -- remove finished sources
            if not synth.active and synth.enveloped <= 0.01 then
                if synth.source:isPlaying() then
                    synth.source:stop()
                end
                synth.source = nil
            end
        end
    end
end

function sampler:applyEnvelope(dt, vol, active, duration)
    -- ADSR envelope
    if active then
        if duration < self.envelope.attack then                       -- attack
            return vol + 1 / self.envelope.attack * dt
        elseif duration < self.envelope.attack + self.envelope.decay then -- decay
            return vol - (1 - self.envelope.sustain) / self.envelope.decay * dt
        else                                                              -- sustain
            return vol
        end
    else                                                                -- release
        return math.max(0, vol - self.envelope.sustain / self.envelope.release * dt)
    end
end

function sampler:setVolume(volume)
    self.masterVolume = volume
end

-- Generate a simple sine wave tone (fallback)
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
    print("[DEBUG] Parsing MIDI file: " .. filePath)

    -- Use Love2D filesystem API
    local success, data = pcall(love.filesystem.read, filePath)

    if not success or not data then
        -- Try with .mid extension if not present
        if not filePath:match("%.mid$") then
            local altPath = filePath .. ".mid"
            success, data = pcall(love.filesystem.read, altPath)
            if success and data then
                filePath = altPath
                print("[DEBUG] Found file with .mid extension")
            end
        end
    end

    if not success or not data then
        print("[ERROR] Cannot open MIDI file: " .. filePath)
        print("[DEBUG] Attempted: " .. filePath)
        if not filePath:match("%.mid$") then
            print("[DEBUG] Also attempted: " .. filePath .. ".mid")
        end
        return false
    end

    print("[DEBUG] MIDI file size: " .. #data .. " bytes")

    -- Check MThd header
    if #data < 14 then
        print("[ERROR] MIDI file too small")
        return false
    end

    -- Read header bytes
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

    self.notes = {}
    local pos = 15 -- Move past header

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
            print(string.format("[ERROR] Invalid track header for track %d, skipping track", trackNum))
            -- Try to find next MTrk
            local foundNext = false
            while pos + 4 <= #data and not foundNext do
                if string.byte(data, pos) == 0x4D and string.byte(data, pos + 1) == 0x54 and
                   string.byte(data, pos + 2) == 0x72 and string.byte(data, pos + 3) == 0x6B then
                    foundNext = true
                    print(string.format("[DEBUG] Found next track at position %d", pos))
                else
                    pos = pos + 1
                end
            end
            if not foundNext then
                print("[ERROR] No more valid tracks found")
                break
            end
            -- Re-read the track header
            for i = 1, 8 do
                trackHeader[i] = string.byte(data, pos + i - 1)
            end
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
                if pos > trackEnd then break end
                byte = string.byte(data, pos)
                pos = pos + 1
                deltaTime = bit.lshift(deltaTime, 7) + bit.band(byte, 0x7F)
            until bit.band(byte, 0x80) == 0

            currentTime = currentTime + deltaTime

            -- Read status byte
            if pos > trackEnd then break end
            local status = string.byte(data, pos)
            pos = pos + 1

            -- Handle running status
            if bit.band(status, 0x80) == 0 then
                status = lastStatus
                pos = pos - 1 -- Put back the data byte
            else
                lastStatus = status
            end

            local eventType = bit.band(status, 0xF0)
            local channel = bit.band(status, 0x0F)

            if status == 0xFF then -- Meta event
                if pos > trackEnd then break end
                local metaType = string.byte(data, pos)
                pos = pos + 1

                -- Read variable length for meta event length
                local length = 0
                repeat
                    if pos > trackEnd then break end
                    byte = string.byte(data, pos)
                    pos = pos + 1
                    length = bit.lshift(length, 7) + bit.band(byte, 0x7F)
                until bit.band(byte, 0x80) == 0

                if metaType == 0x2F then -- End of track
                    print(string.format("[DEBUG] End of track %d", trackNum))
                    break
                elseif metaType == 0x51 then -- Tempo
                    -- Skip tempo data (3 bytes)
                    pos = pos + length
                    print("[DEBUG] Tempo meta event")
                else
                    -- Skip other meta events
                    pos = pos + length
                end
            elseif eventType == 0x90 or eventType == 0x80 then -- Note on/off
                if pos + 1 > trackEnd then break end
                local note = string.byte(data, pos)
                pos = pos + 1
                local velocity = string.byte(data, pos)
                pos = pos + 1

                if eventType == 0x90 and velocity > 0 then -- Note on
                    table.insert(self.notes, {
                        time = currentTime,
                        note = note,
                        duration = 96, -- Default duration, will be updated on note off
                        velocity = velocity,
                        channel = channel,
                        type = "on",
                        note_id = note .. "_" .. channel .. "_" .. currentTime -- Unique ID for matching
                    })
                    print(string.format("[DEBUG] Note on: pitch=%d, velocity=%d, time=%d ticks, channel=%d",
                        note, velocity, currentTime, channel))
                elseif eventType == 0x80 or (eventType == 0x90 and velocity == 0) then -- Note off
                    -- Find the corresponding note on and update duration
                    for i = #self.notes, 1, -1 do
                        if self.notes[i].note == note and self.notes[i].channel == channel and self.notes[i].type == "on" and self.notes[i].duration == 96 then
                            self.notes[i].duration = currentTime - self.notes[i].time
                            if self.notes[i].duration <= 0 then self.notes[i].duration = 24 end -- Minimum duration
                            print(string.format("[DEBUG] Note off matched: pitch=%d, duration=%d ticks", note, self.notes[i].duration))
                            break
                        end
                    end
                end
            elseif eventType == 0xC0 then -- Program change
                if pos > trackEnd then break end
                local program = string.byte(data, pos)
                pos = pos + 1
                print(string.format("[DEBUG] Program change: channel=%d, program=%d", channel, program))
            elseif eventType == 0xB0 then -- Control change
                if pos + 1 > trackEnd then break end
                local controller = string.byte(data, pos)
                pos = pos + 1
                local value = string.byte(data, pos)
                pos = pos + 1
                -- Skip control changes for now
            else
                -- Skip unknown events - try to determine data length
                if eventType >= 0x80 and eventType < 0xF0 then
                    -- Channel events have 1 or 2 data bytes
                    if eventType == 0xC0 or eventType == 0xD0 then
                        pos = pos + 1 -- 1 data byte
                    else
                        pos = pos + 2 -- 2 data bytes
                    end
                end
            end

            if pos > trackEnd then
                break
            end
        end
    end

    print(string.format("[DEBUG] Found %d notes total", #self.notes))
    return true
end

function MidiPlayer:play(filePath)
    -- Stop any currently playing MIDI
    self:stop()

    -- Convert relative path to absolute if needed
    if not filePath:match("^%a:") then
        ---@diagnostic disable-next-line
        filePath = love.filesystem.getSource() .. "/" .. filePath
    end

    print("[MidiPlayer] Attempting to play: " .. filePath)

    -- Parse MIDI file
    if not self:parseSimpleMIDI(filePath) then
        print("[ERROR] Failed to parse MIDI file: " .. filePath)
        return false
    end

    -- Initialize sampler if we have samples, otherwise use tone generation
    if not self.sampler then
        -- Try to load samples from a samples directory
        self:loadSamples()
    end

    self.isPlaying = true
    self.currentNoteIndex = 1
    self.startTime = love.timer.getTime()

    print("[MidiPlayer] Started playing: " .. filePath .. " (" .. #self.notes .. " notes)")
    return true
end

function MidiPlayer:loadSamples()
    -- Try to load samples from engine/audio/samples/ directory
    -- Expected structure: samples/note_60.wav, samples/note_61.wav, etc.
    -- Or samples/piano/note_60.wav, samples/drums/note_36.wav, etc.

    local samples = {}
    local loadedCount = 0

    -- Check for samples directory
    local sampleDirs = {"engine/audio/samples", "samples"}

    for _, baseDir in ipairs(sampleDirs) do
        -- Try loading individual note samples
        for note = 0, 127 do
            local samplePath = baseDir .. "/note_" .. note .. ".wav"
            local samplePathOgg = baseDir .. "/note_" .. note .. ".ogg"
            local samplePathMp3 = baseDir .. "/note_" .. note .. ".mp3"

            local actualPath = nil
            if love.filesystem.getInfo(samplePath) then
                actualPath = samplePath
            elseif love.filesystem.getInfo(samplePathOgg) then
                actualPath = samplePathOgg
            elseif love.filesystem.getInfo(samplePathMp3) then
                actualPath = samplePathMp3
            end

            if actualPath then
                local success, decoder = pcall(love.sound.newDecoder, actualPath)
                if success then
                    local soundData = love.sound.newSoundData(decoder)
                    table.insert(samples, {
                        path = actualPath,
                        soundData = soundData,
                        note = note,
                        velocity = 0.8
                    })
                    loadedCount = loadedCount + 1
                end
            end
        end

        -- If we found samples, break
        if #samples > 0 then
            print(string.format("[MidiPlayer] Loaded %d samples from %s", loadedCount, baseDir))
            break
        end
    end

    if #samples > 0 then
        self.sampler = sampler.new({
            samples = samples,
            synthCount = 16,
            masterVolume = 1.0,
            envelope = {
                attack = 0.01,
                decay = 0.1,
                sustain = 0.8,
                release = 0.2
            }
        })
    else
        print("[MidiPlayer] No sample directory found, using tone synthesis fallback")
        print("[MidiPlayer] To use samples, create engine/audio/samples/ with note_60.wav, note_61.wav, etc.")
        self.sampler = nil -- Use tone synthesis instead
    end
end

function MidiPlayer:stop()
    if self.isPlaying then
        -- Stop all active notes
        for _, source in pairs(self.activeSources) do
            if source:isPlaying() then
                source:stop()
            end
        end
        self.activeSources = {}
        self.isPlaying = false
        print("[MIDI] Stopped playback")
    end
end

function MidiPlayer:pause()
    if self.isPlaying then
        -- Pause all active notes
        for _, source in pairs(self.activeSources) do
            if source:isPlaying() then
                source:pause()
            end
        end
        if self.sampler and self.sampler.synths then
            for _, synth in ipairs(self.sampler.synths) do
                if synth.source and synth.source:isPlaying() then
                    synth.source:pause()
                end
            end
        end
        self.isPaused = true
        print("[MIDI] Paused playback")
    end
end

function MidiPlayer:resume()
    if self.isPlaying and self.isPaused then
        -- Resume all paused notes
        for _, source in pairs(self.activeSources) do
            if not source:isPlaying() then
                source:resume()
            end
        end
        if self.sampler and self.sampler.synths then
            for _, synth in ipairs(self.sampler.synths) do
                if synth.source and not synth.source:isPlaying() then
                    synth.source:resume()
                end
            end
        end
        self.isPaused = false
        print("[MIDI] Resumed playback")
    end
end

function MidiPlayer:update(dt)
    if not self.isPlaying or not self.notes then return end

    local currentTime = love.timer.getTime() - self.startTime

    -- Convert time to MIDI ticks (96 PPQ, 120 BPM)
    -- ticks_per_second = PPQ * BPM / 60 = 96 * 120 / 60 = 192
    local ticksPerSecond = 192
    local currentTicks = currentTime * ticksPerSecond

    -- Play notes that should start now
    while self.currentNoteIndex <= #self.notes do
        local note = self.notes[self.currentNoteIndex]

        if currentTicks >= note.time then
            if note.type == "on" then
                local frequency = noteFrequencies[note.note] or 440
                if frequency then
                    if self.sampler then
                        -- Use sample-based playback
                        self.sampler:playNote(note.note, note.velocity / 127, note.channel)
                        print(string.format("[MidiPlayer] Playing sampled note: pitch=%d, velocity=%d, channel=%d",
                            note.note, note.velocity, note.channel))
                    else
                        -- Fallback to tone synthesis
                        local duration = note.duration / ticksPerSecond -- Convert ticks to seconds
                        if duration <= 0 then duration = 0.1 end -- Minimum duration
                        local toneData = generateTone(frequency, duration, 44100)
                        local source = love.audio.newSource(toneData)
                        source:setVolume((note.velocity / 127) * 0.5) -- Scale velocity to volume
                        source:play()
                        self.activeSources[note.note .. "_" .. note.channel] = source
                        print(string.format("[MidiPlayer] Playing tone: pitch=%d, freq=%.1f, time=%.3f, duration=%.3f",
                            note.note, frequency, currentTime, duration))
                    end
                end
            end
            self.currentNoteIndex = self.currentNoteIndex + 1
        else
            break
        end
    end

    -- Update sampler if available
    if self.sampler then
        self.sampler:update(dt)
    end

    -- Check if we've reached the end
    if self.currentNoteIndex > #self.notes then
        print("[MidiPlayer] Finished playing all notes")
        self:stop()
    end

    -- Clean up finished sources (for tone synthesis fallback)
    for key, source in pairs(self.activeSources) do
        if not source:isPlaying() then
            self.activeSources[key] = nil
        end
    end
end

function MidiPlayer:getIsPlaying()
    return self.isPlaying
end

function MidiPlayer:setVolume(volume)
    -- Set volume for sampler if available
    if self.sampler then
        self.sampler:setVolume(volume)
    else
        -- Set volume for all active sources (tone synthesis)
        for _, source in pairs(self.activeSources) do
            source:setVolume(volume)
        end
    end
end

return MidiPlayer
