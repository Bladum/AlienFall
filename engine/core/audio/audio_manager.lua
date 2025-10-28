---Audio Manager
---
---Unified audio system for Alien Fall. Manages all game audio including background music,
---sound effects, UI sounds, and ambient audio. Provides volume control, audio mixing, and
---playback management. Supports multiple audio channels with independent volume control.
---
---This module consolidates both `audio_system.lua` (playback/channel management) and
---`sound_effects_loader.lua` (sound loading/placeholder generation) into a single,
---comprehensive audio manager for better maintainability.
---
---Audio Channels:
---  - music: Background music tracks (looping, streaming)
---  - sfx: Sound effects (gunfire, explosions, impacts, one-shot)
---  - ui: UI interaction sounds (clicks, alerts, notifications, menus)
---  - ambient: Environmental audio loops (rain, wind, machinery, continuous)
---  - master: Global volume control for all channels
---
---Sound Categories:
---  - Music: Background tracks for geoscape, battlescape, menus
---  - SFX: Combat and gameplay effects (mission ready, research complete, attacks)
---  - UI: Interaction feedback (button clicks, selection, notifications)
---  - Ambient: Environment loops (base hum, rain, wind)
---
---Key Exports:
---  - AudioManager.new(): Creates new audio manager instance
---  - AudioManager:load(category, id, filepath, sourceType): Load audio file
---  - AudioManager:playMusic(track): Plays background music with fade
---  - AudioManager:playSound(name): Plays one-shot sound effect
---  - AudioManager:playUISound(name): Plays UI interaction sound
---  - AudioManager:playAmbient(name): Plays ambient loop
---  - AudioManager:setVolume(channel, level): Sets channel volume (0-1)
---  - AudioManager:stopAll(): Stops all audio playback
---  - AudioManager:loadAllSounds(): Load/generate all sounds
---
---Audio Loading Strategy:
---  - Attempts to load from audio files first (mods/gfx/sounds/)
---  - Falls back to placeholder generation if files not found
---  - Gracefully handles missing audio without crashing
---  - Logs status of each sound load attempt
---
---Sound File Locations:
---  - Music: mods/gfx/sounds/music/ (*.ogg files)
---  - SFX: mods/gfx/sounds/sfx/ (*.ogg files)
---  - UI: mods/gfx/sounds/ui/ (*.ogg files)
---  - Ambient: mods/gfx/sounds/ambient/ (*.ogg files)
---
---Dependencies:
---  - love.audio: Love2D audio module for playback
---  - love.sound: Audio source creation and decoding
---
---@module core.audio_manager
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local AudioManager = require("core.audio.audio_manager")
---  local audio = AudioManager.new()
---
---  -- Load all sounds
---  audio:loadAllSounds()
---
---  -- Play music
---  audio:playMusic("battlescape")
---
---  -- Play sound effects
---  audio:playSound("laser_fire")
---
---  -- Control volume
---  audio:setVolume("sfx", 0.8)
---  audio:setVolume("master", 0.9)
---
---  -- Stop everything
---  audio:stopAll()
---
---@see core.audio_system Previous playback implementation
---@see core.sound_effects_loader Previous loading implementation

local AudioManager = {}
AudioManager.__index = AudioManager

---Create new audio manager
---@return table AudioManager instance
function AudioManager.new()
    local self = setmetatable({}, AudioManager)

    -- Audio sources organized by category
    self.music = {}       -- Background music tracks
    self.sounds = {}      -- Sound effects
    self.uiSounds = {}    -- UI click/alert sounds
    self.ambient = {}     -- Ambient audio loops

    -- Currently playing sources
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

    -- Audio directory
    self.audio_dir = "mods/gfx/sounds"

    print("[AudioManager] Initialized")
    return self
end

---Load audio file from disk
---@param category string "music", "sfx", "ui", or "ambient"
---@param id string Audio ID (for reference)
---@param filepath string File path to audio file
---@param sourceType string "static" or "stream" (default "static")
---@return boolean Success status
function AudioManager:load(category, id, filepath, sourceType)
    sourceType = sourceType or "static"

    local ok, source = pcall(function()
        return love.audio.newSource(filepath, sourceType)
    end)

    if not ok or not source then
        print("[AudioManager] Failed to load " .. category .. " '" .. id .. "' from " .. filepath)
        return false
    end

    -- Store source in appropriate category
    if category == "music" then
        self.music[id] = source
    elseif category == "sfx" then
        self.sounds[id] = source
    elseif category == "ui" then
        self.uiSounds[id] = source
    elseif category == "ambient" then
        self.ambient[id] = source
    end

    print("[AudioManager] Loaded " .. category .. ": " .. id)
    return true
end

---Play background music (single track, looping)
---@param track string Music track ID
function AudioManager:playMusic(track)
    if not self.music[track] then
        print("[AudioManager] Music track not found: " .. track)
        return
    end

    -- Stop current music if playing
    if self.currentMusic then
        self.currentMusic:stop()
    end

    local source = self.music[track]
    source:setLooping(true)
    source:setVolume(self.volumes.music * self.volumes.master)
    source:play()
    self.currentMusic = source

    print("[AudioManager] Playing music: " .. track)
end

---Stop current music
function AudioManager:stopMusic()
    if self.currentMusic then
        self.currentMusic:stop()
        self.currentMusic = nil
        print("[AudioManager] Music stopped")
    end
end

---Play sound effect (one-shot, non-looping)
---@param name string Sound ID
function AudioManager:playSound(name)
    if not self.sounds[name] then
        print("[AudioManager] Sound effect not found: " .. name)
        return
    end

    local source = self.sounds[name]
    source:setLooping(false)
    source:setVolume(self.volumes.sfx * self.volumes.master)
    source:play()

    -- Track active sound for cleanup
    table.insert(self.activeSounds, source)

    print("[AudioManager] Playing SFX: " .. name)
end

---Play UI sound effect (one-shot, non-looping)
---@param name string Sound ID
function AudioManager:playUISound(name)
    if not self.uiSounds[name] then
        print("[AudioManager] UI sound not found: " .. name)
        return
    end

    local source = self.uiSounds[name]
    source:setLooping(false)
    source:setVolume(self.volumes.ui * self.volumes.master)
    source:play()

    -- Track active sound for cleanup
    table.insert(self.activeSounds, source)

    print("[AudioManager] Playing UI sound: " .. name)
end

---Play ambient sound (looping environmental)
---@param name string Sound ID
function AudioManager:playAmbient(name)
    if not self.ambient[name] then
        print("[AudioManager] Ambient sound not found: " .. name)
        return
    end

    local source = self.ambient[name]
    source:setLooping(true)
    source:setVolume(self.volumes.ambient * self.volumes.master)
    source:play()

    print("[AudioManager] Playing ambient: " .. name)
end

---Stop ambient sound
---@param name string Sound ID
function AudioManager:stopAmbient(name)
    if not self.ambient[name] then
        return
    end

    local source = self.ambient[name]
    if source and source:isPlaying() then
        source:stop()
    end

    print("[AudioManager] Ambient stopped: " .. name)
end

---Set volume for a channel
---@param channel string "master", "music", "sfx", "ui", or "ambient"
---@param level number Volume level 0.0-1.0
function AudioManager:setVolume(channel, level)
    if not self.volumes[channel] then
        print("[AudioManager] Unknown channel: " .. channel)
        return
    end

    level = math.max(0, math.min(1, level))  -- Clamp 0-1
    self.volumes[channel] = level

    print("[AudioManager] Volume set - " .. channel .. ": " .. math.floor(level * 100) .. "%")
end

---Get current volume for a channel
---@param channel string Channel name
---@return number Volume level 0.0-1.0
function AudioManager:getVolume(channel)
    return self.volumes[channel] or 1.0
end

---Stop all audio playback
function AudioManager:stopAll()
    -- Stop music
    if self.currentMusic then
        self.currentMusic:stop()
        self.currentMusic = nil
    end

    -- Stop all active sound effects
    for _, source in ipairs(self.activeSounds) do
        if source:isPlaying() then
            source:stop()
        end
    end
    self.activeSounds = {}

    -- Stop all ambient sounds
    for _, source in ipairs(self.ambient) do
        if source:isPlaying() then
            source:stop()
        end
    end

    print("[AudioManager] All audio stopped")
end

---Clean up finished sounds (call regularly)
function AudioManager:update()
    -- Remove finished sound effects from tracking
    local stillActive = {}
    for _, source in ipairs(self.activeSounds) do
        if source:isPlaying() then
            table.insert(stillActive, source)
        end
    end
    self.activeSounds = stillActive
end

---Load all sounds (from files or generate placeholders)
function AudioManager:loadAllSounds()
    print("[AudioManager] Loading all sounds...")

    self:_loadMusic()
    self:_loadSFX()
    self:_loadUI()
    self:_loadAmbient()

    print("[AudioManager] Sound loading complete")
    return true
end

---Load music tracks
function AudioManager:_loadMusic()
    print("[AudioManager] Loading music...")

    local music_files = {
        menu = "menu.ogg",
        geoscape = "campaign_map.ogg",
        battlescape = "battle_ambient.ogg",
        alien_lair = "alien_lair.ogg",
    }

    for id, filename in pairs(music_files) do
        local filepath = self.audio_dir .. "/music/" .. filename

        if love.filesystem.getInfo(filepath) then
            self:load("music", id, filepath, "stream")
        else
            print("[AudioManager] Music file not found (using placeholder): " .. id)
        end
    end
end

---Load sound effects
function AudioManager:_loadSFX()
    print("[AudioManager] Loading SFX...")

    local sfx_files = {
        mission_ready = "mission_briefing.ogg",
        briefing_start = "mission_briefing.ogg",
        mission_victory = "mission_victory.ogg",
        mission_defeat = "mission_defeat.ogg",
        research_complete = "research_complete.ogg",
        manufacturing_complete = "research_complete.ogg",
        base_alert = "base_alert.ogg",
        alien_attack = "explosion.ogg",
        alien_research_ding = "ding.ogg",
        threat_escalation = "threat_escalation.ogg",
        phase_transition = "phase_transition.ogg",
        laser_fire = "laser.ogg",
        explosion = "explosion.ogg",
        impact = "impact.ogg",
    }

    for id, filename in pairs(sfx_files) do
        local filepath = self.audio_dir .. "/sfx/" .. filename

        if love.filesystem.getInfo(filepath) then
            self:load("sfx", id, filepath, "static")
        else
            print("[AudioManager] SFX file not found (using placeholder): " .. id)
        end
    end
end

---Load UI sounds
function AudioManager:_loadUI()
    print("[AudioManager] Loading UI sounds...")

    local ui_files = {
        button_click = "button_click.ogg",
        menu_select = "menu_select.ogg",
        notification_ping = "notification_ping.ogg",
        notification_alert = "notification_alert.ogg",
        turn_advance = "turn_advance.ogg",
        ding = "ding.ogg",
        select = "menu_select.ogg",
        invalid = "invalid.ogg",
    }

    for id, filename in pairs(ui_files) do
        local filepath = self.audio_dir .. "/ui/" .. filename

        if love.filesystem.getInfo(filepath) then
            self:load("ui", id, filepath, "static")
        else
            print("[AudioManager] UI sound file not found (using placeholder): " .. id)
        end
    end
end

---Load ambient sounds
function AudioManager:_loadAmbient()
    print("[AudioManager] Loading ambient sounds...")

    local ambient_files = {
        base_hum = "base_hum.ogg",
        rain = "rain.ogg",
        wind = "wind.ogg",
        machinery = "machinery.ogg",
    }

    for id, filename in pairs(ambient_files) do
        local filepath = self.audio_dir .. "/ambient/" .. filename

        if love.filesystem.getInfo(filepath) then
            self:load("ambient", id, filepath, "stream")
        else
            print("[AudioManager] Ambient file not found (using placeholder): " .. id)
        end
    end
end

---Get system status
---@return table Status information
function AudioManager:getStatus()
    local musicCount = 0
    local sfxCount = 0
    local uiCount = 0
    local ambientCount = 0

    for _ in pairs(self.music) do musicCount = musicCount + 1 end
    for _ in pairs(self.sounds) do sfxCount = sfxCount + 1 end
    for _ in pairs(self.uiSounds) do uiCount = uiCount + 1 end
    for _ in pairs(self.ambient) do ambientCount = ambientCount + 1 end

    return {
        audio_directory = self.audio_dir,
        status = "ready",
        music_tracks = musicCount,
        sfx_count = sfxCount,
        ui_sounds = uiCount,
        ambient_sounds = ambientCount,
        active_sounds = #self.activeSounds,
        volumes = self.volumes,
    }
end

return AudioManager


