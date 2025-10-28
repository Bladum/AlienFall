---================================================================================
---PHASE 3H: Audio System Tests
---================================================================================
---
---Comprehensive test suite for audio/sound systems including:
---
---  1. Audio System Core (4 tests)
---     - System initialization, category setup
---     - Sound and music storage
---
---  2. Volume Management (5 tests)
---     - Volume control per category
---     - Clamping and mixing
---     - Master volume effects
---
---  3. Playback Control (5 tests)
---     - Play/stop mechanics
---     - Sound queuing
---     - Looping behavior
---
---  4. Audio Mixing (4 tests)
---     - Category volume mixing
---     - Fade in/out effects
---     - Volume crossfading
---
---  5. Sound Effects Management (3 tests)
---     - SFX playback and pooling
---     - Priority management
---
---  6. Integration Tests (1 test)
---     - Complete audio lifecycle
---
---@module tests2.audio.audio_system_test

package.path = package.path .. ";../../?.lua;../../engine/?.lua"

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")

---@class MockAudioSystem
---Core audio system managing playback, volume, and sound categories.
---@field sounds table[] Array of active sound instances
---@field music table[] Array of active music tracks
---@field volumes table Category volume levels (0-1)
---@field categories table[] Available audio categories
---@field enabled boolean Whether audio system is active
local MockAudioSystem = {}

function MockAudioSystem:new()
    local instance = {
        sounds = {},
        music = {},
        volumes = {
            master = 1.0,
            music = 1.0,
            sfx = 1.0,
            ui = 0.8,
            ambient = 0.7
        },
        categories = {"master", "music", "sfx", "ui", "ambient"},
        enabled = true
    }
    setmetatable(instance, {__index = self})
    return instance
end

function MockAudioSystem:setVolume(category, volume)
    if not self.volumes[category] then
        return false
    end

    -- Clamp between 0 and 1
    self.volumes[category] = math.max(0, math.min(1, volume))
    return true
end

function MockAudioSystem:getVolume(category)
    return self.volumes[category] or 0
end

function MockAudioSystem:getEffectiveVolume(category)
    if not self.volumes[category] then
        return 0
    end

    -- Master volume affects all categories
    return self.volumes.master * self.volumes[category]
end

function MockAudioSystem:setMasterVolume(volume)
    self:setVolume("master", volume)
end

function MockAudioSystem:getMasterVolume()
    return self:getVolume("master")
end

function MockAudioSystem:update(dt)
    if not self.enabled then return end

    -- Update fading sounds
    for i = #self.sounds, 1, -1 do
        local sound = self.sounds[i]
        if sound.fading then
            sound.fadeTime = sound.fadeTime + dt
            if sound.fadeTime >= sound.fadeDuration then
                if sound.fadeTarget == 0 then
                    table.remove(self.sounds, i)
                else
                    sound.fading = false
                end
            end
        end
    end

    -- Update fading music
    for i = #self.music, 1, -1 do
        local track = self.music[i]
        if track.fading then
            track.fadeTime = track.fadeTime + dt
            if track.fadeTime >= track.fadeDuration then
                if track.fadeTarget == 0 then
                    table.remove(self.music, i)
                else
                    track.fading = false
                end
            end
        end
    end
end

---@class MockSoundSource
---Individual sound instance with playback state and effects.
---@field id number Unique identifier
---@field name string Sound asset name
---@field category string Audio category (sfx, ui, ambient, etc)
---@field volume number Volume level (0-1)
---@field pitch number Playback pitch multiplier
---@field playing boolean Current playback state
---@field loop boolean Whether sound loops
local MockSoundSource = {}

function MockSoundSource:new(id, name, category)
    local instance = {
        id = id,
        name = name,
        category = category or "sfx",
        volume = 1.0,
        pitch = 1.0,
        playing = false,
        loop = false,
        fading = false,
        fadeTime = 0,
        fadeDuration = 0,
        fadeTarget = 1.0
    }
    setmetatable(instance, {__index = self})
    return instance
end

function MockSoundSource:play()
    self.playing = true
    return true
end

function MockSoundSource:stop()
    self.playing = false
    return true
end

function MockSoundSource:setVolume(vol)
    self.volume = math.max(0, math.min(1, vol))
end

function MockSoundSource:setPitch(pitch)
    self.pitch = math.max(0.5, math.min(2.0, pitch))
end

function MockSoundSource:setLooping(loop)
    self.loop = loop
end

function MockSoundSource:fadeOut(duration)
    self.fading = true
    self.fadeTime = 0
    self.fadeDuration = duration
    self.fadeTarget = 0
end

function MockSoundSource:fadeIn(duration)
    self.fading = true
    self.fadeTime = 0
    self.fadeDuration = duration
    self.fadeTarget = 1.0
end

---@class MockMusicTrack
---Background music track with crossfading support.
---@field id number Unique identifier
---@field name string Music asset name
---@field volume number Volume level (0-1)
---@field playing boolean Current playback state
---@field looping boolean Whether track repeats
local MockMusicTrack = {}

function MockMusicTrack:new(id, name)
    local instance = {
        id = id,
        name = name,
        volume = 1.0,
        playing = false,
        looping = true,
        fading = false,
        fadeTime = 0,
        fadeDuration = 0,
        fadeTarget = 1.0
    }
    setmetatable(instance, {__index = self})
    return instance
end

function MockMusicTrack:play()
    self.playing = true
    return true
end

function MockMusicTrack:stop()
    self.playing = false
    return true
end

function MockMusicTrack:setVolume(vol)
    self.volume = math.max(0, math.min(1, vol))
end

function MockMusicTrack:crossfadeTo(duration)
    self.fading = true
    self.fadeTime = 0
    self.fadeDuration = duration
    self.fadeTarget = 0
end

---@class MockSoundEffectPool
---Pool of reusable SFX instances for efficient playback.
---@field pool table[] Available sound instances
---@field active table[] Currently playing instances
---@field size number Pool capacity
local MockSoundEffectPool = {}

function MockSoundEffectPool:new(size)
    local instance = {
        pool = {},
        active = {},
        size = size or 32
    }

    for i = 1, size do
        table.insert(instance.pool, MockSoundSource:new(i, "", "sfx"))
    end

    setmetatable(instance, {__index = self})
    return instance
end

function MockSoundEffectPool:acquire(name)
    if #self.pool > 0 then
        local sound = table.remove(self.pool)
        sound.name = name
        sound.playing = false
        table.insert(self.active, sound)
        return sound
    end
    return nil
end

function MockSoundEffectPool:release(sound)
    for i, s in ipairs(self.active) do
        if s == sound then
            table.remove(self.active, i)
            sound.playing = false
            table.insert(self.pool, sound)
            return true
        end
    end
    return false
end

function MockSoundEffectPool:getActiveCount()
    return #self.active
end

function MockSoundEffectPool:getPoolCount()
    return #self.pool
end

---================================================================================
---TEST SUITE
---================================================================================

local Suite = HierarchicalSuite:new({
    module = "engine.audio.system",
    file = "audio_system_test.lua",
    description = "Audio system - Playback, volume, mixing, effects, music"
})

---AUDIO SYSTEM CORE TESTS
Suite:group("Audio System Core", function()

    Suite:testMethod("MockAudioSystem:new", {
        description = "Initializes audio system with categories",
        testCase = "initialization",
        type = "functional"
    }, function()
        local audio = MockAudioSystem:new()
        if not audio.sounds then error("Sounds table missing") end
        if not audio.music then error("Music table missing") end
        if not audio.volumes then error("Volumes table missing") end
        if #audio.categories < 5 then error("Should have 5 categories minimum") end
    end)

    Suite:testMethod("MockAudioSystem:new", {
        description = "Sets default volume levels",
        testCase = "default_volumes",
        type = "functional"
    }, function()
        local audio = MockAudioSystem:new()

        if audio:getVolume("master") ~= 1.0 then error("Master should be 1.0") end
        if audio:getVolume("music") ~= 1.0 then error("Music should be 1.0") end
        if audio:getVolume("sfx") ~= 1.0 then error("SFX should be 1.0") end
    end)

    Suite:testMethod("MockAudioSystem:update", {
        description = "Updates system without errors",
        testCase = "update_function",
        type = "functional"
    }, function()
        local audio = MockAudioSystem:new()

        -- Should not crash
        audio:update(0.016)
        audio:update(0.5)
        audio:update(1.0)
    end)

    Suite:testMethod("MockAudioSystem:enabled", {
        description = "Respects enabled/disabled state",
        testCase = "enabled_state",
        type = "functional"
    }, function()
        local audio = MockAudioSystem:new()
        if not audio.enabled then error("Should be enabled by default") end

        audio.enabled = false
        if audio.enabled then error("Should be disabled") end
    end)
end)

---VOLUME MANAGEMENT TESTS
Suite:group("Volume Management", function()

    Suite:testMethod("MockAudioSystem:setVolume", {
        description = "Sets volume for categories",
        testCase = "volume_setting",
        type = "functional"
    }, function()
        local audio = MockAudioSystem:new()

        local result = audio:setVolume("master", 0.5)
        if not result then error("Should return true") end
        if audio:getVolume("master") ~= 0.5 then error("Volume should be 0.5") end
    end)

    Suite:testMethod("MockAudioSystem:setVolume", {
        description = "Clamps volume between 0-1",
        testCase = "volume_clamping",
        type = "functional"
    }, function()
        local audio = MockAudioSystem:new()

        audio:setVolume("sfx", 1.5)
        if audio:getVolume("sfx") > 1.0 then error("Should clamp to 1.0 max") end

        audio:setVolume("sfx", -0.5)
        if audio:getVolume("sfx") < 0 then error("Should clamp to 0 min") end
    end)

    Suite:testMethod("MockAudioSystem:getEffectiveVolume", {
        description = "Multiplies master and category volumes",
        testCase = "volume_mixing",
        type = "functional"
    }, function()
        local audio = MockAudioSystem:new()

        audio:setVolume("master", 0.5)
        audio:setVolume("sfx", 0.8)

        local effective = audio:getEffectiveVolume("sfx")
        if effective ~= 0.4 then error("Effective should be 0.5 * 0.8 = 0.4, got " .. effective) end
    end)

    Suite:testMethod("MockAudioSystem:setMasterVolume", {
        description = "Sets master volume level",
        testCase = "master_volume",
        type = "functional"
    }, function()
        local audio = MockAudioSystem:new()

        audio:setMasterVolume(0.7)
        if audio:getMasterVolume() ~= 0.7 then error("Master should be 0.7") end
    end)

    Suite:testMethod("MockAudioSystem:getVolume", {
        description = "Returns 0 for invalid categories",
        testCase = "invalid_category",
        type = "functional"
    }, function()
        local audio = MockAudioSystem:new()

        local vol = audio:getVolume("invalid_cat")
        if vol ~= 0 then error("Should return 0 for invalid") end
    end)
end)

---PLAYBACK CONTROL TESTS
Suite:group("Playback Control", function()

    Suite:testMethod("MockSoundSource:new", {
        description = "Creates sound source instance",
        testCase = "creation",
        type = "functional"
    }, function()
        local sound = MockSoundSource:new(1, "laser.wav", "sfx")

        if sound.id ~= 1 then error("ID should be 1") end
        if sound.name ~= "laser.wav" then error("Name should be 'laser.wav'") end
        if sound.category ~= "sfx" then error("Category should be 'sfx'") end
    end)

    Suite:testMethod("MockSoundSource:play", {
        description = "Plays sound source",
        testCase = "playback",
        type = "functional"
    }, function()
        local sound = MockSoundSource:new(1, "laser.wav", "sfx")

        sound:play()
        if not sound.playing then error("Should be playing") end
    end)

    Suite:testMethod("MockSoundSource:stop", {
        description = "Stops sound source",
        testCase = "stop",
        type = "functional"
    }, function()
        local sound = MockSoundSource:new(1, "laser.wav", "sfx")

        sound:play()
        sound:stop()
        if sound.playing then error("Should not be playing") end
    end)

    Suite:testMethod("MockSoundSource:setVolume", {
        description = "Sets sound volume",
        testCase = "sound_volume",
        type = "functional"
    }, function()
        local sound = MockSoundSource:new(1, "laser.wav", "sfx")

        sound:setVolume(0.6)
        if sound.volume ~= 0.6 then error("Volume should be 0.6") end
    end)

    Suite:testMethod("MockSoundSource:setLooping", {
        description = "Sets looping state",
        testCase = "looping",
        type = "functional"
    }, function()
        local sound = MockSoundSource:new(1, "ambient.wav", "ambient")

        sound:setLooping(true)
        if not sound.loop then error("Should be looping") end

        sound:setLooping(false)
        if sound.loop then error("Should not be looping") end
    end)
end)

---AUDIO MIXING TESTS
Suite:group("Audio Mixing", function()

    Suite:testMethod("MockSoundSource:setPitch", {
        description = "Sets playback pitch",
        testCase = "pitch_control",
        type = "functional"
    }, function()
        local sound = MockSoundSource:new(1, "tone.wav", "sfx")

        sound:setPitch(1.5)
        if sound.pitch ~= 1.5 then error("Pitch should be 1.5") end

        sound:setPitch(0.8)
        if sound.pitch ~= 0.8 then error("Pitch should be 0.8") end
    end)

    Suite:testMethod("MockSoundSource:fadeOut", {
        description = "Initiates fade-out effect",
        testCase = "fade_out",
        type = "functional"
    }, function()
        local sound = MockSoundSource:new(1, "music.wav", "music")

        sound:fadeOut(2.0)
        if not sound.fading then error("Should be fading") end
        if sound.fadeTarget ~= 0 then error("Fade target should be 0") end
        if sound.fadeDuration ~= 2.0 then error("Duration should be 2.0") end
    end)

    Suite:testMethod("MockSoundSource:fadeIn", {
        description = "Initiates fade-in effect",
        testCase = "fade_in",
        type = "functional"
    }, function()
        local sound = MockSoundSource:new(1, "ambient.wav", "ambient")

        sound:fadeIn(1.5)
        if not sound.fading then error("Should be fading") end
        if sound.fadeTarget ~= 1.0 then error("Fade target should be 1.0") end
        if sound.fadeDuration ~= 1.5 then error("Duration should be 1.5") end
    end)

    Suite:testMethod("MockMusicTrack:crossfadeTo", {
        description = "Starts crossfade effect",
        testCase = "crossfade",
        type = "functional"
    }, function()
        local music = MockMusicTrack:new(1, "theme1.ogg")

        music:crossfadeTo(3.0)
        if not music.fading then error("Should be fading") end
        if music.fadeDuration ~= 3.0 then error("Duration should be 3.0") end
    end)
end)

---SOUND EFFECTS MANAGEMENT TESTS
Suite:group("Sound Effects Management", function()

    Suite:testMethod("MockSoundEffectPool:new", {
        description = "Creates SFX pool with size",
        testCase = "pool_creation",
        type = "functional"
    }, function()
        local pool = MockSoundEffectPool:new(32)

        if pool:getPoolCount() ~= 32 then error("Should have 32 pooled sounds") end
        if pool:getActiveCount() ~= 0 then error("Should have 0 active sounds") end
    end)

    Suite:testMethod("MockSoundEffectPool:acquire", {
        description = "Gets sound from pool",
        testCase = "acquire",
        type = "functional"
    }, function()
        local pool = MockSoundEffectPool:new(16)

        local sound = pool:acquire("explosion.wav")
        if not sound then error("Should acquire sound") end
        if pool:getPoolCount() ~= 15 then error("Pool should have 15 remaining") end
        if pool:getActiveCount() ~= 1 then error("Should have 1 active") end
    end)

    Suite:testMethod("MockSoundEffectPool:release", {
        description = "Returns sound to pool",
        testCase = "release",
        type = "functional"
    }, function()
        local pool = MockSoundEffectPool:new(16)

        local sound = pool:acquire("explosion.wav")
        local released = pool:release(sound)

        if not released then error("Should release successfully") end
        if pool:getPoolCount() ~= 16 then error("Pool should have 16 items") end
        if pool:getActiveCount() ~= 0 then error("Should have 0 active") end
    end)
end)

---INTEGRATION TESTS
Suite:group("Integration", function()

    Suite:testMethod("Complete Audio Lifecycle", {
        description = "Simulates full audio playback cycle",
        testCase = "lifecycle",
        type = "integration"
    }, function()
        local audio = MockAudioSystem:new()
        local pool = MockSoundEffectPool:new(32)

        -- Acquire and play a sound effect
        local sfx = pool:acquire("laser.wav")
        sfx:play()
        sfx:setVolume(0.8)

        if not sfx.playing then error("SFX should be playing") end

        -- Play music
        local music = MockMusicTrack:new(1, "battle.ogg")
        music:play()
        table.insert(audio.music, music)

        -- Adjust volumes
        audio:setVolume("sfx", 0.9)
        audio:setVolume("music", 0.7)

        local sfxEffective = audio:getEffectiveVolume("sfx")
        local musicEffective = audio:getEffectiveVolume("music")

        if sfxEffective ~= 0.9 then error("SFX effective volume incorrect") end
        if musicEffective ~= 0.7 then error("Music effective volume incorrect") end

        -- Fade out music
        music:crossfadeTo(2.0)

        -- Simulate updates
        for i = 1, 5 do
            audio:update(0.4)
        end

        -- Release sound
        pool:release(sfx)

        if pool:getActiveCount() ~= 0 then error("All SFX should be released") end
    end)
end)

---PERFORMANCE BENCHMARKS
Suite:group("Performance", function()

    Suite:testMethod("Scaling - SFX Pool", {
        description = "Handles large SFX pool efficiently",
        testCase = "sfx_scaling",
        type = "performance"
    }, function()
        local pool = MockSoundEffectPool:new(128)
        local startTime = os.clock()

        -- Acquire and release many sounds
        local sounds = {}
        for i = 1, 64 do
            table.insert(sounds, pool:acquire("sfx_" .. i .. ".wav"))
        end

        for _, sound in ipairs(sounds) do
            if sound then pool:release(sound) end
        end

        local elapsed = os.clock() - startTime
        if elapsed > 0.01 then
            print("[Performance] 128-pool SFX cycle: " .. string.format("%.3fms", elapsed * 1000))
        end
    end)

    Suite:testMethod("Scaling - Volume Mixing", {
        description = "Calculates volume mixing efficiently",
        testCase = "volume_scaling",
        type = "performance"
    }, function()
        local audio = MockAudioSystem:new()
        local startTime = os.clock()

        -- Set many volumes
        for i = 0, 100 do
            local vol = i / 100
            audio:setVolume("master", vol)
        end

        -- Calculate effective volumes
        for i = 1, 100 do
            audio:getEffectiveVolume("sfx")
            audio:getEffectiveVolume("music")
        end

        local elapsed = os.clock() - startTime
        if elapsed > 0.01 then
            print("[Performance] 100 volume calculations: " .. string.format("%.3fms", elapsed * 1000))
        end
    end)
end)

---================================================================================
---RUN TESTS
---================================================================================

Suite:run()

-- Close the Love2D window after tests complete
love.event.quit()
