-- Audio Manager for AlienFall
-- Handles sound effects, music, and MIDI playback

local MidiPlayer = require("audio.midi_player")

AudioManager = {
    master_volume = 1.0,
    music_volume = 0.7,
    sfx_volume = 0.8,
    midi_volume = 0.6,
    current_music = nil,
    current_midi = nil,
    active_sounds = {},
    loaded_sources = {}  -- Cache for loaded audio sources
}

-- Initialize the audio manager
function AudioManager:init()
    print("[AudioManager] Initialized")
end

-- Set master volume (0-1)
function AudioManager:setMasterVolume(volume)
    self.master_volume = math.max(0, math.min(1, volume))
    self:updateAllVolumes()
end

-- Set music volume (0-1)
function AudioManager:setMusicVolume(volume)
    self.music_volume = math.max(0, math.min(1, volume))
    if self.current_music then
        self.current_music:setVolume(volume * self.master_volume)
    end
end

-- Set SFX volume (0-1)
function AudioManager:setSFXVolume(volume)
    self.sfx_volume = math.max(0, math.min(1, volume))
    self:updateSFXVolumes()
end

-- Set MIDI volume (0-1)
function AudioManager:setMIDIVolume(volume)
    self.midi_volume = math.max(0, math.min(1, volume))
    MidiPlayer:setVolume(volume * self.master_volume * 1000)  -- MCI uses 0-1000
end

-- Update all volumes
function AudioManager:updateAllVolumes()
    self:updateSFXVolumes()
    if self.current_music then
        self.current_music:setVolume(self.music_volume * self.master_volume)
    end
    MidiPlayer:setVolume(self.midi_volume * self.master_volume * 1000)
end

-- Update SFX volumes
function AudioManager:updateSFXVolumes()
    for _, source in ipairs(self.active_sounds) do
        if source:isPlaying() then
            -- Note: Volume is set when playing, but we could update here if needed
        end
    end
end

-- Load and cache an audio source
function AudioManager:loadSource(path, type)
    type = type or "static"
    if self.loaded_sources[path] then
        return self.loaded_sources[path]
    end

    local source = love.audio.newSource(path, type)
    if source then
        self.loaded_sources[path] = source
        print("[AudioManager] Loaded audio: " .. path)
    else
        print("[ERROR] Failed to load audio: " .. path)
    end
    return source
end

-- Play a sound effect
function AudioManager:playSFX(soundName, volume)
    volume = volume or 1.0

    -- Limit concurrent sounds to prevent audio chaos
    if #self.active_sounds >= 32 then
        return nil
    end

    local path = "engine/assets/sounds/sfx/" .. soundName .. ".ogg"
    local source = self:loadSource(path, "static")
    if not source then
        return nil
    end

    source:setVolume(volume * self.sfx_volume * self.master_volume)
    source:play()

    table.insert(self.active_sounds, source)
    return source
end

-- Play music (OGG/MP3)
function AudioManager:playMusic(musicName, fadeTime, loop)
    fadeTime = fadeTime or 1.0
    loop = loop ~= false  -- Default to true

    -- Stop current music
    self:stopMusic()

    local path = "engine/assets/music/" .. musicName .. ".ogg"
    local source = self:loadSource(path, "stream")
    if not source then
        return false
    end

    source:setVolume(self.music_volume * self.master_volume)
    if loop then
        source:setLooping(true)
    end
    source:play()

    self.current_music = source
    print("[AudioManager] Playing music: " .. musicName)
    return true
end

-- Play MIDI music
function AudioManager:playMIDI(midiName, loop)
    loop = loop ~= false

    -- Stop current MIDI
    self:stopMIDI()

    -- For testing, use the MIDI TEST folder (absolute path)
    local projectRoot = love.filesystem.getSource():gsub("engine$", "")
    local path = projectRoot .. "MIDI TEST/sample.mid"
    if MidiPlayer:play(path) then
        self.current_midi = midiName
        MidiPlayer:setVolume(self.midi_volume * self.master_volume * 1000)
        print("[AudioManager] Playing MIDI: " .. midiName)
        return true
    end
    return false
end

-- Stop music
function AudioManager:stopMusic()
    if self.current_music then
        self.current_music:stop()
        self.current_music = nil
    end
end

-- Stop MIDI
function AudioManager:stopMIDI()
    MidiPlayer:stop()
    self.current_midi = nil
end

-- Stop all audio
function AudioManager:stopAll()
    self:stopMusic()
    self:stopMIDI()
    for _, source in ipairs(self.active_sounds) do
        source:stop()
    end
    self.active_sounds = {}
end

-- Pause all audio
function AudioManager:pauseAll()
    if self.current_music then
        self.current_music:pause()
    end
    MidiPlayer:stop()  -- MCI doesn't have pause, so stop
    for _, source in ipairs(self.active_sounds) do
        source:pause()
    end
end

-- Resume all audio
function AudioManager:resumeAll()
    if self.current_music then
        self.current_music:resume()
    end
    if self.current_midi then
        self:playMIDI(self.current_midi)  -- Restart MIDI
    end
    for _, source in ipairs(self.active_sounds) do
        source:resume()
    end
end

-- Update (call this in love.update)
function AudioManager:update(dt)
    -- Update all buttons
    for _, button in ipairs(self.buttons) do
        button:update(dt)
    end

    -- Update version label
    self.versionLabel:update(dt)
end

-- Update (call this in love.update)
function AudioManager:update(dt)
    -- Remove finished sounds
    for i = #self.active_sounds, 1, -1 do
        if not self.active_sounds[i]:isPlaying() then
            table.remove(self.active_sounds, i)
        end
    end

    -- Update MIDI player for real-time playback
    MidiPlayer:update(dt)

    -- Handle MIDI looping if needed (MCI doesn't loop automatically)
    if self.current_midi and not MidiPlayer:isPlaying() then
        -- Could implement looping here if desired
    end
end

-- Get current music status
function AudioManager:getMusicStatus()
    if self.current_music then
        return self.current_music:isPlaying() and "playing" or "stopped"
    end
    return "none"
end

-- Get current MIDI status
function AudioManager:getMIDIStatus()
    return MidiPlayer:isPlaying() and "playing" or "stopped"
end

return AudioManager
