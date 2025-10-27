-- Audio Manager for AlienFall
-- Handles sound effects, music, and MIDI playback

-- Try to load native MIDI player first (requires midi.dll)
local MidiPlayerNative = require("audio.midi_player_native")
local MidiPlayer = require("audio.midi_player")

-- Choose which MIDI player to use
local activeMidiPlayer = nil
if MidiPlayerNative.available then
    activeMidiPlayer = MidiPlayerNative
    print("[AudioManager] Using native MIDI player (with real audio)")
else
    activeMidiPlayer = MidiPlayer
    print("[AudioManager] Using fallback MIDI player (parser only - no audio)")
end

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
    activeMidiPlayer:setVolume(volume * self.master_volume)
end

-- Update all volumes
function AudioManager:updateAllVolumes()
    self:updateSFXVolumes()
    if self.current_music then
        self.current_music:setVolume(self.music_volume * self.master_volume)
    end
    activeMidiPlayer:setVolume(self.midi_volume * self.master_volume)
end

-- Update SFX volumes
function AudioManager:updateSFXVolumes()
    for i = #self.active_sounds, 1, -1 do
        local source = self.active_sounds[i]
        if source and type(source) == "userdata" then
            if source:isPlaying() then
                -- Note: Volume is set when playing, but we could update here if needed
            end
        elseif not source or type(source) ~= "userdata" then
            print("[WARN] Removing invalid item from active_sounds in updateSFXVolumes: " .. type(source) .. " = " .. tostring(source))
            table.remove(self.active_sounds, i)
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

    -- Handle both full paths and relative paths
    local path
    if midiName:match("%.mid$") or midiName:match("%.midi$") then
        -- Check if it's already a full path
        if midiName:match("^assets/music/midi/") then
            path = midiName
        else
            -- Just a filename with extension, prepend path
            path = "assets/music/midi/" .. midiName
        end
    else
        -- Add .mid extension and path
        path = "assets/music/midi/" .. midiName .. ".mid"
    end

    print("[AudioManager] Attempting to play MIDI: " .. path)

    if activeMidiPlayer:play(path) then
        self.current_midi = midiName
        activeMidiPlayer:setVolume(self.midi_volume * self.master_volume)
        print("[AudioManager] Playing MIDI: " .. midiName)
        return true
    else
        print("[ERROR] Failed to play MIDI: " .. path)
        return false
    end
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
    activeMidiPlayer:stop()
    self.current_midi = nil
end

-- Pause MIDI
function AudioManager:pauseMIDI()
    activeMidiPlayer:pause()
end

-- Resume MIDI
function AudioManager:resumeMIDI()
    activeMidiPlayer:resume()
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
    activeMidiPlayer:pause()
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
    -- Remove finished sounds
    for i = #self.active_sounds, 1, -1 do
        local source = self.active_sounds[i]
        if source and type(source) == "userdata" and not source:isPlaying() then
            table.remove(self.active_sounds, i)
        elseif not source or type(source) ~= "userdata" then
            print("[WARN] Removing invalid item from active_sounds: " .. type(source) .. " = " .. tostring(source))
            table.remove(self.active_sounds, i)
        end
    end

    -- Update MIDI player for real-time playback
    activeMidiPlayer:update(dt)

    -- Handle MIDI looping if needed
    local midi_playing = activeMidiPlayer:getIsPlaying()
    if self.current_midi and not midi_playing then
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
    return activeMidiPlayer:getIsPlaying() and "playing" or "stopped"
end

return AudioManager
