---Audio System
---
---Manages all game audio including background music, sound effects, UI sounds, and
---ambient audio. Provides volume control, audio mixing, and playback management.
---Supports multiple audio channels with independent volume control.
---
---Audio Channels:
---  - music: Background music tracks (looping)
---  - sfx: Sound effects (gunfire, explosions, impacts)
---  - ui: UI interaction sounds (clicks, alerts, menus)
---  - ambient: Environmental audio loops (rain, wind, machinery)
---  - master: Global volume control for all channels
---
---Key Exports:
---  - AudioSystem.new(): Creates new audio system instance
---  - playMusic(track): Plays background music with fade
---  - playSound(name): Plays one-shot sound effect
---  - playUISound(name): Plays UI interaction sound
---  - setVolume(channel, level): Sets channel volume (0-1)
---  - stopAll(): Stops all audio playback
---
---Dependencies:
---  - love.audio: Love2D audio module for playback
---  - love.sound: Audio source creation and decoding
---
---@module core.audio_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local AudioSystem = require("core.audio_system")
---  local audio = AudioSystem.new()
---  audio:playMusic("mission_theme")
---  audio:playSound("laser_fire")
---  audio:setVolume("sfx", 0.8)
---
---@see core.assets For loading audio files
---@see battlescape.effects For combat sound effects

local AudioSystem = {}
AudioSystem.__index = AudioSystem

--- Create new audio system
function AudioSystem.new()
    local self = setmetatable({}, AudioSystem)
    
    -- Audio sources
    self.music = {}       -- Background music tracks
    self.sounds = {}      -- Sound effects
    self.uiSounds = {}    -- UI click/alert sounds
    self.ambient = {}     -- Ambient audio loops
    
    -- Currently playing
    self.currentMusic = nil
    self.activeSounds = {}
    
    -- Volume settings (0-1)
    self.volumes = {
        master = 1.0,
        music = 0.7,
        sfx = 0.8,
        ui = 0.6,
        ambient = 0.5,
    }
    
    print("[AudioSystem] Initialized")
    return self
end

--- Load audio file
---@param category string "music", "sfx", "ui", or "ambient"
---@param id string Audio ID
---@param filepath string File path
---@param sourceType string "static" or "stream" (default "static")
function AudioSystem:load(category, id, filepath, sourceType)
    sourceType = sourceType or "static"
    
    local source = love.audio.newSource(filepath, sourceType)
    
    if not source then
        print("[AudioSystem] Failed to load: " .. filepath)
        return false
    end
    
    if category == "music" then
        self.music[id] = source
        source:setLooping(true)  -- Music loops
    elseif category == "sfx" then
        self.sounds[id] = source
    elseif category == "ui" then
        self.uiSounds[id] = source
    elseif category == "ambient" then
        self.ambient[id] = source
        source:setLooping(true)  -- Ambient loops
    end
    
    print("[AudioSystem] Loaded " .. category .. ": " .. id)
    return true
end

--- Play music
---@param musicId string Music ID
---@param fadeIn number Optional fade-in duration (seconds)
function AudioSystem:playMusic(musicId, fadeIn)
    local music = self.music[musicId]
    if not music then
        print("[AudioSystem] Music not found: " .. musicId)
        return
    end
    
    -- Stop current music
    if self.currentMusic then
        self.currentMusic:stop()
    end
    
    -- Play new music
    music:setVolume(self.volumes.music * self.volumes.master)
    music:play()
    self.currentMusic = music
    
    print("[AudioSystem] Playing music: " .. musicId)
end

--- Stop music
---@param fadeOut number Optional fade-out duration (seconds)
function AudioSystem:stopMusic(fadeOut)
    if self.currentMusic then
        self.currentMusic:stop()
        self.currentMusic = nil
        print("[AudioSystem] Music stopped")
    end
end

--- Play sound effect
---@param soundId string Sound ID
---@param volume number|nil Optional volume override (0-1)
function AudioSystem:playSFX(soundId, volume)
    local sound = self.sounds[soundId]
    if not sound then
        print("[AudioSystem] Sound not found: " .. soundId)
        return
    end
    
    -- Clone source for multiple simultaneous plays
    local instance = sound:clone()
    volume = volume or 1.0
    instance:setVolume(volume * self.volumes.sfx * self.volumes.master)
    instance:play()
    
    -- Track active sound
    table.insert(self.activeSounds, instance)
end

--- Play UI sound
---@param uiSoundId string UI sound ID
function AudioSystem:playUI(uiSoundId)
    local sound = self.uiSounds[uiSoundId]
    if not sound then return end
    
    local instance = sound:clone()
    instance:setVolume(self.volumes.ui * self.volumes.master)
    instance:play()
end

--- Play ambient audio
---@param ambientId string Ambient ID
function AudioSystem:playAmbient(ambientId)
    local ambient = self.ambient[ambientId]
    if not ambient then return end
    
    ambient:setVolume(self.volumes.ambient * self.volumes.master)
    ambient:play()
end

--- Stop ambient audio
---@param ambientId string Ambient ID
function AudioSystem:stopAmbient(ambientId)
    local ambient = self.ambient[ambientId]
    if ambient then
        ambient:stop()
    end
end

--- Set volume for category
---@param category string "master", "music", "sfx", "ui", or "ambient"
---@param volume number Volume (0-1)
function AudioSystem:setVolume(category, volume)
    volume = math.max(0, math.min(1, volume))
    self.volumes[category] = volume
    
    -- Update playing audio
    if category == "music" or category == "master" then
        if self.currentMusic then
            self.currentMusic:setVolume(self.volumes.music * self.volumes.master)
        end
    end
    
    print(string.format("[AudioSystem] %s volume: %.2f", category, volume))
end

--- Get volume for category
---@param category string Category
---@return number Volume (0-1)
function AudioSystem:getVolume(category)
    return self.volumes[category] or 1.0
end

--- Update audio system (called per frame)
---@param dt number Delta time
function AudioSystem:update(dt)
    -- Clean up finished sounds
    for i = #self.activeSounds, 1, -1 do
        if not self.activeSounds[i]:isPlaying() then
            table.remove(self.activeSounds, i)
        end
    end
end

--- Stop all audio
function AudioSystem:stopAll()
    -- Stop music
    if self.currentMusic then
        self.currentMusic:stop()
        self.currentMusic = nil
    end
    
    -- Stop all sounds
    for _, sound in ipairs(self.activeSounds) do
        sound:stop()
    end
    self.activeSounds = {}
    
    -- Stop all ambient
    for _, ambient in pairs(self.ambient) do
        ambient:stop()
    end
    
    print("[AudioSystem] All audio stopped")
end

--- Common game sounds (helper methods)
function AudioSystem:playShot()
    self:playSFX("gunshot")
end

function AudioSystem:playExplosion()
    self:playSFX("explosion", 1.2)  -- Louder
end

function AudioSystem:playButtonClick()
    self:playUI("click")
end

function AudioSystem:playAlert()
    self:playUI("alert")
end

--- Save settings
---@return table Settings
function AudioSystem:saveSettings()
    return {volumes = self.volumes}
end

--- Load settings
---@param settings table Saved settings
function AudioSystem:loadSettings(settings)
    if settings.volumes then
        self.volumes = settings.volumes
    end
    print("[AudioSystem] Settings loaded")
end

return AudioSystem

























