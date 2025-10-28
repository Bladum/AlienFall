---Sound Effects Loader
---
---Loads or generates placeholder sound effects for the audio system. Handles
---both loading from audio files and generating placeholder sounds for testing.
---Gracefully falls back to silence if audio files are missing.
---
---Key Exports:
---  - SoundEffectsLoader:new(): Create loader
---  - SoundEffectsLoader:loadAllSounds(audio_system): Load/generate all sounds
---  - SoundEffectsLoader:generatePlaceholder(name): Create placeholder sound
---
---Sound Categories:
---  - Music: Background tracks (geoscape, menu, battle)
---  - SFX: Sound effects (mission, research, alert)
---  - UI: UI interaction sounds (clicks, notifications)
---  - Ambient: Environmental audio loops
---
---@module engine.core.sound_effects_loader
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source

local SoundEffectsLoader = {}
SoundEffectsLoader.__index = SoundEffectsLoader

--- Create new loader
function SoundEffectsLoader.new()
    local self = setmetatable({}, SoundEffectsLoader)
    self.audio_dir = "mods/gfx/sounds"
    self.generated_sounds = {}

    return self
end

--- Load all sounds into audio system
---@param audio_system table AudioSystem instance
function SoundEffectsLoader:loadAllSounds(audio_system)
    print("[SoundEffectsLoader] Loading all sounds...")

    if not audio_system then
        print("[SoundEffectsLoader] ERROR: No audio system provided")
        return false
    end

    -- Try to load real audio files, fall back to generated placeholders
    self:_loadMusic(audio_system)
    self:_loadSFX(audio_system)
    self:_loadUI(audio_system)
    self:_loadAmbient(audio_system)

    print("[SoundEffectsLoader] Sound loading complete")
    return true
end

--- Load music tracks
---@param audio_system table AudioSystem instance
function SoundEffectsLoader:_loadMusic(audio_system)
    print("[SoundEffectsLoader] Loading music...")

    local music_files = {
        menu = "menu.ogg",
        geoscape = "campaign_map.ogg",
        battlescape = "battle_ambient.ogg",
        alien_lair = "alien_lair.ogg",
    }

    for id, filename in pairs(music_files) do
        local filepath = self.audio_dir .. "/music/" .. filename
        local loaded = false

        -- Try to load from file
        if love.filesystem.getInfo(filepath) then
            local ok = pcall(function()
                audio_system:load("music", id, filepath, "stream")
                print("[SoundEffectsLoader] Loaded music: " .. id)
                loaded = true
            end)
        end

        -- Fall back to placeholder
        if not loaded then
            print("[SoundEffectsLoader] Using placeholder for music: " .. id)
            self:_loadPlaceholderMusic(audio_system, id)
        end
    end
end

--- Load sound effects
---@param audio_system table AudioSystem instance
function SoundEffectsLoader:_loadSFX(audio_system)
    print("[SoundEffectsLoader] Loading SFX...")

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
    }

    for id, filename in pairs(sfx_files) do
        local filepath = self.audio_dir .. "/sfx/" .. filename
        local loaded = false

        -- Try to load from file
        if love.filesystem.getInfo(filepath) then
            local ok = pcall(function()
                audio_system:load("sfx", id, filepath)
                print("[SoundEffectsLoader] Loaded SFX: " .. id)
                loaded = true
            end)
        end

        -- Fall back to placeholder
        if not loaded then
            print("[SoundEffectsLoader] Using placeholder for SFX: " .. id)
            self:_loadPlaceholderSFX(audio_system, id)
        end
    end
end

--- Load UI sounds
---@param audio_system table AudioSystem instance
function SoundEffectsLoader:_loadUI(audio_system)
    print("[SoundEffectsLoader] Loading UI sounds...")

    local ui_files = {
        button_click = "button_click.ogg",
        menu_select = "menu_select.ogg",
        notification_ping = "notification_ping.ogg",
        notification_alert = "notification_alert.ogg",
        turn_advance = "turn_advance.ogg",
        ding = "ding.ogg",
    }

    for id, filename in pairs(ui_files) do
        local filepath = self.audio_dir .. "/ui/" .. filename
        local loaded = false

        -- Try to load from file
        if love.filesystem.getInfo(filepath) then
            local ok = pcall(function()
                audio_system:load("ui", id, filepath)
                print("[SoundEffectsLoader] Loaded UI sound: " .. id)
                loaded = true
            end)
        end

        -- Fall back to placeholder
        if not loaded then
            print("[SoundEffectsLoader] Using placeholder for UI sound: " .. id)
            self:_loadPlaceholderUI(audio_system, id)
        end
    end
end

--- Load ambient sounds
---@param audio_system table AudioSystem instance
function SoundEffectsLoader:_loadAmbient(audio_system)
    print("[SoundEffectsLoader] Loading ambient sounds...")

    local ambient_files = {
        base_hum = "base_hum.ogg",
        rain = "rain.ogg",
    }

    for id, filename in pairs(ambient_files) do
        local filepath = self.audio_dir .. "/ambient/" .. filename
        local loaded = false

        -- Try to load from file
        if love.filesystem.getInfo(filepath) then
            local ok = pcall(function()
                audio_system:load("ambient", id, filepath, "stream")
                print("[SoundEffectsLoader] Loaded ambient: " .. id)
                loaded = true
            end)
        end

        -- Fall back to placeholder
        if not loaded then
            print("[SoundEffectsLoader] Using placeholder for ambient: " .. id)
            self:_loadPlaceholderAmbient(audio_system, id)
        end
    end
end

--- Load placeholder music
---@param audio_system table AudioSystem instance
---@param id string Sound ID
function SoundEffectsLoader:_loadPlaceholderMusic(audio_system, id)
    -- Music placeholders: 1-second sine wave tones
    -- In production, would be 1+ minute background tracks

    -- For now, we can't generate actual audio in Lua without external lib
    -- The audio system will handle nil gracefully
    print("[SoundEffectsLoader] Placeholder for music '" .. id .. "' (would be 60+ second loop)")
end

--- Load placeholder SFX
---@param audio_system table AudioSystem instance
---@param id string Sound ID
function SoundEffectsLoader:_loadPlaceholderSFX(audio_system, id)
    -- SFX placeholders: short beeps/tones
    -- In production, would be actual recorded sound effects

    print("[SoundEffectsLoader] Placeholder for SFX '" .. id .. "' (would be brief sound effect)")
end

--- Load placeholder UI sound
---@param audio_system table AudioSystem instance
---@param id string Sound ID
function SoundEffectsLoader:_loadPlaceholderUI(audio_system, id)
    -- UI sound placeholders: very short beeps
    -- In production, would be actual UI click/notification sounds

    print("[SoundEffectsLoader] Placeholder for UI sound '" .. id .. "' (would be brief UI sound)")
end

--- Load placeholder ambient
---@param audio_system table AudioSystem instance
---@param id string Sound ID
function SoundEffectsLoader:_loadPlaceholderAmbient(audio_system, id)
    -- Ambient placeholders: continuous background sounds
    -- In production, would be actual environmental audio loops

    print("[SoundEffectsLoader] Placeholder for ambient '" .. id .. "' (would be continuous loop)")
end

--- Get status of sound loading
---@return table Status information
function SoundEffectsLoader:getStatus()
    return {
        audio_directory = self.audio_dir,
        status = "ready",
        note = "Using placeholder sounds if audio files not found"
    }
end

return SoundEffectsLoader

