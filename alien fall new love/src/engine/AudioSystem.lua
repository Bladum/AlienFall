--- Audio System
-- Manages music tracks, sound effects, and volume controls
--
-- @classmod engine.AudioSystem

-- GROK: AudioSystem manages game audio with music and sound effect playback
-- GROK: Handles volume controls, music tracks, sound effects, and audio state
-- GROK: Key methods: playMusic(), playSound(), setMusicVolume(), setSoundVolume()
-- GROK: Integrates with Love2D audio system and supports mod audio files

local class = require 'lib.Middleclass'

--- AudioSystem class
-- @type AudioSystem
local AudioSystem = class('AudioSystem')

--- Create a new AudioSystem
-- @param registry Service registry
-- @return AudioSystem instance
function AudioSystem:initialize(registry)
    self.registry = registry
    self.logger = registry and registry:logger() or nil
    
    -- Audio state
    self.musicVolume = 0.7
    self.soundVolume = 0.8
    self.masterVolume = 1.0
    
    self.currentMusic = nil
    self.musicFading = false
    self.fadeTarget = nil
    self.fadeSpeed = 1.0
    
    -- Audio caches
    self.musicCache = {} -- Track name -> Source
    self.soundCache = {} -- Sound name -> Source
    
    -- Active sounds
    self.activeSounds = {}
    
    -- Music playlist
    self.musicPlaylist = {}
    self.playlistIndex = 1
    self.playlistLoop = true
    
    -- Register with service registry
    if registry then
        registry:registerService('audioSystem', self)
    end
end

--- Load and cache music track
-- @param trackName Track name/ID
-- @param filepath Path to audio file
-- @return love.audio.Source|nil Music source or nil on error
function AudioSystem:loadMusic(trackName, filepath)
    if self.musicCache[trackName] then
        return self.musicCache[trackName]
    end
    
    -- Try to load audio file
    local success, source = pcall(function()
        return love.audio.newSource(filepath, "stream")
    end)
    
    if not success then
        if self.logger then
            self.logger:warn("Failed to load music track: " .. trackName .. " from " .. filepath)
        end
        return nil
    end
    
    source:setVolume(self.musicVolume * self.masterVolume)
    source:setLooping(false) -- We'll handle looping manually for playlists
    
    self.musicCache[trackName] = source
    return source
end

--- Load and cache sound effect
-- @param soundName Sound name/ID
-- @param filepath Path to audio file
-- @return love.audio.Source|nil Sound source or nil on error
function AudioSystem:loadSound(soundName, filepath)
    if self.soundCache[soundName] then
        return self.soundCache[soundName]:clone()
    end
    
    -- Try to load audio file
    local success, source = pcall(function()
        return love.audio.newSource(filepath, "static")
    end)
    
    if not success then
        if self.logger then
            self.logger:warn("Failed to load sound effect: " .. soundName .. " from " .. filepath)
        end
        return nil
    end
    
    source:setVolume(self.soundVolume * self.masterVolume)
    
    self.soundCache[soundName] = source
    return source:clone()
end

--- Play music track
-- @param trackName Track name/ID
-- @param loop Whether to loop the track
-- @param fadeIn Fade in duration in seconds (optional)
function AudioSystem:playMusic(trackName, loop, fadeIn)
    loop = loop ~= false -- Default true
    
    local source = self.musicCache[trackName]
    if not source then
        if self.logger then
            self.logger:warn("Music track not loaded: " .. trackName)
        end
        return
    end
    
    -- Stop current music
    if self.currentMusic and self.currentMusic:isPlaying() then
        if fadeIn then
            self:fadeOutMusic(fadeIn)
        else
            self.currentMusic:stop()
        end
    end
    
    -- Play new music
    source:setLooping(loop)
    
    if fadeIn then
        source:setVolume(0)
        self:fadeInMusic(trackName, fadeIn)
    else
        source:setVolume(self.musicVolume * self.masterVolume)
    end
    
    source:play()
    self.currentMusic = source
    self.currentMusicName = trackName
end

--- Stop current music
-- @param fadeOut Fade out duration in seconds (optional)
function AudioSystem:stopMusic(fadeOut)
    if not self.currentMusic then return end
    
    if fadeOut then
        self:fadeOutMusic(fadeOut)
    else
        self.currentMusic:stop()
        self.currentMusic = nil
        self.currentMusicName = nil
    end
end

--- Pause current music
function AudioSystem:pauseMusic()
    if self.currentMusic and self.currentMusic:isPlaying() then
        self.currentMusic:pause()
    end
end

--- Resume paused music
function AudioSystem:resumeMusic()
    if self.currentMusic and not self.currentMusic:isPlaying() then
        self.currentMusic:play()
    end
end

--- Fade in music
-- @param trackName Track name
-- @param duration Fade duration in seconds
function AudioSystem:fadeInMusic(trackName, duration)
    self.musicFading = true
    self.fadeTarget = self.musicVolume * self.masterVolume
    self.fadeSpeed = self.fadeTarget / duration
    self.fadingIn = true
end

--- Fade out music
-- @param duration Fade duration in seconds
function AudioSystem:fadeOutMusic(duration)
    if not self.currentMusic then return end
    
    self.musicFading = true
    self.fadeTarget = 0
    self.fadeSpeed = self.currentMusic:getVolume() / duration
    self.fadingIn = false
end

--- Play sound effect
-- @param soundName Sound name/ID
-- @param volume Volume multiplier (0-1, optional)
-- @param pitch Pitch multiplier (0.5-2.0, optional)
-- @return love.audio.Source|nil Playing sound source or nil
function AudioSystem:playSound(soundName, volume, pitch)
    local source = self.soundCache[soundName]
    if not source then
        if self.logger then
            self.logger:warn("Sound effect not loaded: " .. soundName)
        end
        return nil
    end
    
    -- Clone the source for simultaneous playback
    local playingSource = source:clone()
    
    -- Set volume
    local finalVolume = self.soundVolume * self.masterVolume
    if volume then
        finalVolume = finalVolume * volume
    end
    playingSource:setVolume(finalVolume)
    
    -- Set pitch
    if pitch then
        playingSource:setPitch(pitch)
    end
    
    -- Play
    playingSource:play()
    
    -- Track active sound
    table.insert(self.activeSounds, {
        source = playingSource,
        name = soundName,
        startTime = love.timer.getTime()
    })
    
    return playingSource
end

--- Stop all playing sounds
function AudioSystem:stopAllSounds()
    for _, soundData in ipairs(self.activeSounds) do
        if soundData.source:isPlaying() then
            soundData.source:stop()
        end
    end
    self.activeSounds = {}
end

--- Set master volume
-- @param volume Volume (0-1)
function AudioSystem:setMasterVolume(volume)
    self.masterVolume = math.max(0, math.min(1, volume))
    self:_updateVolumes()
end

--- Set music volume
-- @param volume Volume (0-1)
function AudioSystem:setMusicVolume(volume)
    self.musicVolume = math.max(0, math.min(1, volume))
    
    if self.currentMusic then
        self.currentMusic:setVolume(self.musicVolume * self.masterVolume)
    end
end

--- Set sound effects volume
-- @param volume Volume (0-1)
function AudioSystem:setSoundVolume(volume)
    self.soundVolume = math.max(0, math.min(1, volume))
end

--- Get master volume
-- @return number Volume (0-1)
function AudioSystem:getMasterVolume()
    return self.masterVolume
end

--- Get music volume
-- @return number Volume (0-1)
function AudioSystem:getMusicVolume()
    return self.musicVolume
end

--- Get sound effects volume
-- @return number Volume (0-1)
function AudioSystem:getSoundVolume()
    return self.soundVolume
end

--- Update volumes for all cached sources
function AudioSystem:_updateVolumes()
    -- Update current music
    if self.currentMusic then
        self.currentMusic:setVolume(self.musicVolume * self.masterVolume)
    end
    
    -- Update active sounds
    for _, soundData in ipairs(self.activeSounds) do
        if soundData.source:isPlaying() then
            soundData.source:setVolume(self.soundVolume * self.masterVolume)
        end
    end
end

--- Create music playlist
-- @param tracks Array of track names
-- @param loop Whether to loop playlist
function AudioSystem:createPlaylist(tracks, loop)
    self.musicPlaylist = tracks
    self.playlistIndex = 1
    self.playlistLoop = loop ~= false
end

--- Play next track in playlist
function AudioSystem:playNextTrack()
    if #self.musicPlaylist == 0 then return end
    
    self.playlistIndex = self.playlistIndex + 1
    
    if self.playlistIndex > #self.musicPlaylist then
        if self.playlistLoop then
            self.playlistIndex = 1
        else
            return -- End of playlist
        end
    end
    
    local trackName = self.musicPlaylist[self.playlistIndex]
    self:playMusic(trackName, false, 1.0) -- Fade between tracks
end

--- Update audio system
-- @param dt Delta time
function AudioSystem:update(dt)
    -- Handle music fading
    if self.musicFading and self.currentMusic then
        local currentVolume = self.currentMusic:getVolume()
        
        if self.fadingIn then
            currentVolume = currentVolume + (self.fadeSpeed * dt)
            if currentVolume >= self.fadeTarget then
                currentVolume = self.fadeTarget
                self.musicFading = false
            end
        else
            currentVolume = currentVolume - (self.fadeSpeed * dt)
            if currentVolume <= self.fadeTarget then
                currentVolume = self.fadeTarget
                self.musicFading = false
                if self.fadeTarget == 0 then
                    self.currentMusic:stop()
                    self.currentMusic = nil
                    self.currentMusicName = nil
                end
            end
        end
        
        self.currentMusic:setVolume(currentVolume)
    end
    
    -- Check if music finished (for playlist)
    if self.currentMusic and not self.currentMusic:isPlaying() and #self.musicPlaylist > 0 then
        self:playNextTrack()
    end
    
    -- Clean up finished sounds
    local i = 1
    while i <= #self.activeSounds do
        local soundData = self.activeSounds[i]
        if not soundData.source:isPlaying() then
            table.remove(self.activeSounds, i)
        else
            i = i + 1
        end
    end
end

--- Preload audio assets from data registry
function AudioSystem:preloadAssets()
    local dataRegistry = self.registry and self.registry:resolve("data_registry")
    if not dataRegistry then return end
    
    -- Load music tracks
    local musicData = dataRegistry:get("music_track")
    if musicData then
        for trackId, track in pairs(musicData) do
            if track.filepath then
                self:loadMusic(trackId, track.filepath)
            end
        end
    end
    
    -- Load sound effects
    local soundData = dataRegistry:get("sound_effect")
    if soundData then
        for soundId, sound in pairs(soundData) do
            if sound.filepath then
                self:loadSound(soundId, sound.filepath)
            end
        end
    end
end

--- Clear all cached audio
function AudioSystem:clearCache()
    -- Stop everything
    self:stopMusic()
    self:stopAllSounds()
    
    -- Clear caches
    for _, source in pairs(self.musicCache) do
        source:release()
    end
    self.musicCache = {}
    
    for _, source in pairs(self.soundCache) do
        source:release()
    end
    self.soundCache = {}
end

--- Serialize audio state for saving
-- @return table Serialized state
function AudioSystem:serialize()
    return {
        musicVolume = self.musicVolume,
        soundVolume = self.soundVolume,
        masterVolume = self.masterVolume,
        currentMusicName = self.currentMusicName
    }
end

--- Deserialize audio state from save
-- @param data Saved state
function AudioSystem:deserialize(data)
    if not data then return end
    
    self.musicVolume = data.musicVolume or 0.7
    self.soundVolume = data.soundVolume or 0.8
    self.masterVolume = data.masterVolume or 1.0
    
    -- Resume music if needed
    if data.currentMusicName and self.musicCache[data.currentMusicName] then
        self:playMusic(data.currentMusicName, true)
    end
end

return AudioSystem
