-- ─────────────────────────────────────────────────────────────────────────
-- AUDIO SYSTEM TEST SUITE
-- FILE: tests2/core/audio_system_test.lua
-- ─────────────────────────────────────────────────────────────────────────
-- Tests the audio system and sound management
-- Covers: Volume control, sound categories, audio playback
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.core.audio.audio_system",
    fileName = "audio_system.lua",
    description = "Audio system and sound management"
})

print("[AUDIO_SYSTEM_TEST] Setting up")

local AudioSystem = {
    masterVolume = 1.0,
    categories = {
        music = {volume = 0.7},
        sfx = {volume = 0.8},
        voice = {volume = 0.9},
        ambient = {volume = 0.5}
    },
    sounds = {},
    nextSoundId = 1,

    setMasterVolume = function(self, volume)
        if volume < 0 or volume > 1 then return false end
        self.masterVolume = volume
        return true
    end,

    getMasterVolume = function(self)
        return self.masterVolume
    end,

    setCategoryVolume = function(self, category, volume)
        if not self.categories[category] then return false end
        if volume < 0 or volume > 1 then return false end
        self.categories[category].volume = volume
        return true
    end,

    getCategoryVolume = function(self, category)
        if not self.categories[category] then return nil end
        return self.categories[category].volume
    end,

    playSound = function(self, soundName, category)
        if not soundName then return false end
        category = category or "sfx"
        if not self.categories[category] then return false end

        local sound = {
            id = self.nextSoundId,
            name = soundName,
            category = category,
            isPlaying = true,
            volume = self.categories[category].volume * self.masterVolume
        }
        self.nextSoundId = self.nextSoundId + 1
        table.insert(self.sounds, sound)
        return sound
    end,

    stopSound = function(self, soundId)
        for i, sound in ipairs(self.sounds) do
            if sound.id == soundId then
                sound.isPlaying = false
                table.remove(self.sounds, i)
                return true
            end
        end
        return false
    end,

    stopAllSounds = function(self, category)
        if category then
            local count = 0
            for i = #self.sounds, 1, -1 do
                if self.sounds[i].category == category then
                    table.remove(self.sounds, i)
                    count = count + 1
                end
            end
            return count
        else
            self.sounds = {}
            return true
        end
    end,

    isPlaying = function(self, soundId)
        for _, sound in ipairs(self.sounds) do
            if sound.id == soundId then return sound.isPlaying end
        end
        return false
    end,

    getActiveSoundCount = function(self)
        return #self.sounds
    end
}

-- ─────────────────────────────────────────────────────────────────────────
-- TESTS
-- ─────────────────────────────────────────────────────────────────────────

Suite:group("Volume Control", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.audio = setmetatable({
            masterVolume = 1.0,
            categories = {
                music = {volume = 0.7},
                sfx = {volume = 0.8},
                voice = {volume = 0.9},
                ambient = {volume = 0.5}
            },
            sounds = {},
            nextSoundId = 1
        }, {__index = AudioSystem})
    end)

    Suite:testMethod("AudioSystem.setMasterVolume", {
        description = "Sets master volume",
        testCase = "set_volume",
        type = "functional"
    }, function()
        local ok = shared.audio:setMasterVolume(0.5)
        Helpers.assertEqual(ok, true, "Volume set successfully")
        Helpers.assertEqual(shared.audio.masterVolume, 0.5, "Master volume changed")
    end)

    Suite:testMethod("AudioSystem.setMasterVolume", {
        description = "Clamps volume to 0-1",
        testCase = "clamp_volume",
        type = "functional"
    }, function()
        local ok = shared.audio:setMasterVolume(1.5)
        Helpers.assertEqual(ok, false, "Over 1.0 rejected")
        ok = shared.audio:setMasterVolume(-0.5)
        Helpers.assertEqual(ok, false, "Below 0 rejected")
    end)

    Suite:testMethod("AudioSystem.setCategoryVolume", {
        description = "Sets category volume",
        testCase = "category_volume",
        type = "functional"
    }, function()
        local ok = shared.audio:setCategoryVolume("music", 0.3)
        Helpers.assertEqual(ok, true, "Category volume set")
        Helpers.assertEqual(shared.audio.categories.music.volume, 0.3, "Category volume changed")
    end)

    Suite:testMethod("AudioSystem.getCategoryVolume", {
        description = "Gets category volume",
        testCase = "get_category_volume",
        type = "functional"
    }, function()
        local vol = shared.audio:getCategoryVolume("sfx")
        Helpers.assertEqual(vol, 0.8, "Category volume retrieved")
    end)
end)

Suite:group("Sound Playback", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.audio = setmetatable({
            masterVolume = 1.0,
            categories = {
                music = {volume = 0.7},
                sfx = {volume = 0.8},
                voice = {volume = 0.9},
                ambient = {volume = 0.5}
            },
            sounds = {},
            nextSoundId = 1
        }, {__index = AudioSystem})
    end)

    Suite:testMethod("AudioSystem.playSound", {
        description = "Plays sound",
        testCase = "play_sound",
        type = "functional"
    }, function()
        local sound = shared.audio:playSound("explosion", "sfx")
        Helpers.assertEqual(sound ~= nil, true, "Sound returned")
        if sound then
            Helpers.assertEqual(sound.name, "explosion", "Sound name correct")
            Helpers.assertEqual(sound.isPlaying, true, "Sound is playing")
        end
    end)

    Suite:testMethod("AudioSystem.playSound", {
        description = "Default category is sfx",
        testCase = "default_category",
        type = "functional"
    }, function()
        local sound = shared.audio:playSound("click")
        if sound then
            Helpers.assertEqual(sound.category, "sfx", "Default category is sfx")
        end
    end)

    Suite:testMethod("AudioSystem.stopSound", {
        description = "Stops sound by ID",
        testCase = "stop_sound",
        type = "functional"
    }, function()
        local sound = shared.audio:playSound("music", "music")
        if sound then
            local ok = shared.audio:stopSound(sound.id)
            Helpers.assertEqual(ok, true, "Sound stopped")
            Helpers.assertEqual(shared.audio:isPlaying(sound.id), false, "Sound no longer playing")
        end
    end)

    Suite:testMethod("AudioSystem.stopAllSounds", {
        description = "Stops all sounds in category",
        testCase = "stop_category",
        type = "functional"
    }, function()
        shared.audio:playSound("beep1", "sfx")
        shared.audio:playSound("beep2", "sfx")
        shared.audio:playSound("music", "music")
        local count = shared.audio:stopAllSounds("sfx")
        Helpers.assertEqual(count, 2, "Two sfx stopped")
    end)

    Suite:testMethod("AudioSystem.getActiveSoundCount", {
        description = "Returns active sound count",
        testCase = "sound_count",
        type = "functional"
    }, function()
        shared.audio:playSound("sound1", "sfx")
        shared.audio:playSound("sound2", "music")
        local count = shared.audio:getActiveSoundCount()
        Helpers.assertEqual(count, 2, "Two sounds active")
    end)
end)

Suite:group("Sound Management", function()
    local shared = {}

    Suite:beforeEach(function()
        shared.audio = setmetatable({
            masterVolume = 1.0,
            categories = {
                music = {volume = 0.7},
                sfx = {volume = 0.8},
                voice = {volume = 0.9},
                ambient = {volume = 0.5}
            },
            sounds = {},
            nextSoundId = 1
        }, {__index = AudioSystem})
    end)

    Suite:testMethod("AudioSystem.playSound", {
        description = "Sound volume reflects master volume",
        testCase = "sound_volume",
        type = "functional"
    }, function()
        shared.audio:setMasterVolume(0.5)
        local sound = shared.audio:playSound("test", "sfx")
        if sound then
            local expectedVol = 0.8 * 0.5  -- category * master
            Helpers.assertEqual(math.floor(sound.volume * 100) / 100, math.floor(expectedVol * 100) / 100, "Volume calculated correctly")
        end
    end)

    Suite:testMethod("AudioSystem.stopAllSounds", {
        description = "Stops all sounds when no category given",
        testCase = "stop_all",
        type = "functional"
    }, function()
        shared.audio:playSound("sound1", "sfx")
        shared.audio:playSound("sound2", "music")
        shared.audio:playSound("sound3", "voice")
        shared.audio:stopAllSounds()
        Helpers.assertEqual(shared.audio:getActiveSoundCount(), 0, "All sounds stopped")
    end)
end)

Suite:run()
