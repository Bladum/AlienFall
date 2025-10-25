-- Unit Tests for Audio System
-- Tests audio loading, playback, volume control, and category management

local AudioSystemTest = {}

-- Test audio system creation
function AudioSystemTest.testCreate()
    local AudioSystem = require("core.audio.audio_system")
    
    local audio = AudioSystem.new()
    
    assert(audio ~= nil, "Audio system not created")
    assert(audio.sounds ~= nil, "Sounds table missing")
    assert(audio.music ~= nil, "Music table missing")
    assert(audio.volumes ~= nil, "Volumes table missing")
    
    print("✓ testCreate passed")
end

-- Test volume settings
function AudioSystemTest.testVolume()
    local AudioSystem = require("core.audio.audio_system")
    
    local audio = AudioSystem.new()
    
    -- Test setting volume
    audio:setVolume("master", 0.8)
    assert(audio:getVolume("master") == 0.8, "Master volume not set")
    
    audio:setVolume("music", 0.6)
    assert(audio:getVolume("music") == 0.6, "Music volume not set")
    
    audio:setVolume("sfx", 0.5)
    assert(audio:getVolume("sfx") == 0.5, "SFX volume not set")
    
    -- Test volume limits
    audio:setVolume("master", 1.5)
    assert(audio:getVolume("master") <= 1.0, "Volume not clamped to max")
    
    audio:setVolume("master", -0.5)
    assert(audio:getVolume("master") >= 0.0, "Volume not clamped to min")
    
    print("✓ testVolume passed")
end

-- Test volume categories
function AudioSystemTest.testCategories()
    local AudioSystem = require("core.audio.audio_system")
    
    local audio = AudioSystem.new()
    
    -- Check all categories exist
    local categories = {"master", "music", "sfx", "ui", "ambient"}
    
    for _, category in ipairs(categories) do
        local volume = audio:getVolume(category)
        assert(volume ~= nil, "Category " .. category .. " missing")
        assert(type(volume) == "number", "Volume not a number")
    end
    
    print("✓ testCategories passed")
end

-- Test muting
function AudioSystemTest.testMute()
    local AudioSystem = require("core.audio.audio_system")
    
    local audio = AudioSystem.new()
    
    -- Set initial volume
    audio:setVolume("sfx", 0.8)
    
    -- Mute
    audio:setVolume("sfx", 0.0)
    assert(audio:getVolume("sfx") == 0.0, "Not muted")
    
    -- Unmute
    audio:setVolume("sfx", 0.8)
    assert(audio:getVolume("sfx") == 0.8, "Not unmuted")
    
    print("✓ testMute passed")
end

-- Test update function
function AudioSystemTest.testUpdate()
    local AudioSystem = require("core.audio.audio_system")
    
    local audio = AudioSystem.new()
    
    -- Should not crash
    local success, err = pcall(function()
        audio:update(0.016)
        audio:update(1.0)
        audio:update(0.0)
    end)
    
    assert(success, "Update failed: " .. tostring(err))
    
    print("✓ testUpdate passed")
end

-- Test invalid category handling
function AudioSystemTest.testInvalidCategory()
    local AudioSystem = require("core.audio.audio_system")
    
    local audio = AudioSystem.new()
    
    -- Setting invalid category should not crash
    local success = pcall(function()
        audio:setVolume("invalid_category", 0.5)
    end)
    
    assert(success, "Should handle invalid category gracefully")
    
    print("✓ testInvalidCategory passed")
end

-- Test volume mixing
function AudioSystemTest.testVolumeMixing()
    local AudioSystem = require("core.audio.audio_system")
    
    local audio = AudioSystem.new()
    
    -- Set master and category volumes
    audio:setVolume("master", 0.5)
    audio:setVolume("sfx", 0.8)
    
    -- Effective volume should be product of both
    local effectiveVolume = audio:getVolume("master") * audio:getVolume("sfx")
    assert(effectiveVolume == 0.4, "Volume mixing incorrect")
    
    print("✓ testVolumeMixing passed")
end

-- Run all tests
function AudioSystemTest.runAll()
    print("\n=== Audio System Tests ===")
    
    AudioSystemTest.testCreate()
    AudioSystemTest.testVolume()
    AudioSystemTest.testCategories()
    AudioSystemTest.testMute()
    AudioSystemTest.testUpdate()
    AudioSystemTest.testInvalidCategory()
    AudioSystemTest.testVolumeMixing()
    
    print("✓ All Audio System tests passed!\n")
end

return AudioSystemTest




