# 🔊 Audio Systems & Implementation Best Practices

**Domain:** Audio & Sound  
**Focus:** Sound effects, music, audio management, mixing, spatial audio  
**Version:** 1.0  
**Date:** October 2025

## Overview

This guide covers implementing audio systems, managing sound effects and music, and creating immersive soundscapes.

## Audio Architecture

### ✅ DO: Implement Audio Manager

```lua
-- audio_manager.lua
AudioManager = {
    master_volume = 1.0,
    music_volume = 0.7,
    sfx_volume = 0.8,
    current_music = nil,
    active_sounds = {}
}

function AudioManager:setMasterVolume(volume)
    self.master_volume = math.max(0, math.min(1, volume))
    self:updateAllVolumes()
end

function AudioManager:playSFX(soundName)
    local source = love.audio.newSource("assets/sounds/sfx/" .. soundName .. ".ogg", "static")
    source:setVolume(self.sfx_volume * self.master_volume)
    source:play()
    
    table.insert(self.active_sounds, source)
    return source
end

function AudioManager:playMusic(musicName, fadeTime)
    fadeTime = fadeTime or 1.0
    
    -- Fade out current music
    if self.current_music then
        self:fadeOutMusic(fadeTime)
    end
    
    -- Load new music
    local source = love.audio.newSource("assets/music/" .. musicName .. ".ogg", "stream")
    source:setVolume(self.music_volume * self.master_volume)
    source:play()
    
    self.current_music = source
end

function AudioManager:fadeOutMusic(duration)
    -- Implementation for fade out
end

function AudioManager:update(dt)
    -- Remove finished sounds
    for i = #self.active_sounds, 1, -1 do
        if not self.active_sounds[i]:isPlaying() then
            table.remove(self.active_sounds, i)
        end
    end
end
```

---

### ✅ DO: Manage Audio Context

```lua
function AudioManager:pauseAll()
    if self.current_music then
        self.current_music:pause()
    end
    
    for _, sound in ipairs(self.active_sounds) do
        sound:pause()
    end
end

function AudioManager:resumeAll()
    if self.current_music then
        self.current_music:resume()
    end
    
    for _, sound in ipairs(self.active_sounds) do
        sound:resume()
    end
end

function AudioManager:stopAll()
    if self.current_music then
        self.current_music:stop()
        self.current_music = nil
    end
    
    for _, sound in ipairs(self.active_sounds) do
        sound:stop()
    end
    
    self.active_sounds = {}
end

-- Hook into game state changes
function onGamePaused()
    AudioManager:pauseAll()
end

function onGameResumed()
    AudioManager:resumeAll()
end
```

---

## Sound Effect Design

### ✅ DO: Create Sound Effect Pools

```lua
SOUND_EFFECTS = {
    weapons = {
        rifle = "assets/sounds/sfx/weapon_rifle.ogg",
        sniper = "assets/sounds/sfx/weapon_sniper.ogg",
        shotgun = "assets/sounds/sfx/weapon_shotgun.ogg"
    },
    hits = {
        hit_armor = "assets/sounds/sfx/hit_armor.ogg",
        hit_flesh = "assets/sounds/sfx/hit_flesh.ogg"
    },
    ui = {
        button_click = "assets/sounds/sfx/ui_click.ogg",
        notification = "assets/sounds/sfx/ui_notify.ogg"
    }
}

function playSoundEffect(category, sound)
    local path = SOUND_EFFECTS[category][sound]
    if path then
        AudioManager:playSFX(path)
    end
end

-- Usage in gameplay
function fireWeapon(weapon)
    playSoundEffect("weapons", weapon.type)
    -- Visual effects...
end

function onUnitHit(attacker, defender)
    playSoundEffect("hits", "hit_" .. defender.armor_type)
    -- Damage calculation...
end
```

---

### ✅ DO: Implement Spatial Audio

```lua
function playSoundAtPosition(soundName, x, y)
    local source = love.audio.newSource("assets/sounds/" .. soundName, "static")
    
    -- Calculate panning based on x position
    local screenWidth = love.graphics.getWidth()
    local pan = ((x / screenWidth) - 0.5) * 2  -- Range: -1 to 1
    
    -- Calculate volume based on distance from screen center
    local screenHeight = love.graphics.getHeight()
    local distance = math.sqrt((x - screenWidth/2)^2 + (y - screenHeight/2)^2)
    local maxDistance = math.sqrt((screenWidth/2)^2 + (screenHeight/2)^2)
    local volume = 1 - (distance / maxDistance) * 0.5
    
    source:setVolume(volume * AudioManager.sfx_volume)
    
    -- Love2D supports stereo panning via effects (Love 11+)
    source:play()
    return source
end

-- Usage
function explosionAt(x, y)
    playSoundAtPosition("explosion.ogg", x, y)
end
```

---

## Music Management

### ✅ DO: Implement Dynamic Music System

```lua
MUSIC_TRACKS = {
    menu = "assets/music/menu.ogg",
    exploration = "assets/music/exploration.ogg",
    combat_tense = "assets/music/combat_tense.ogg",
    combat_intense = "assets/music/combat_intense.ogg",
    victory = "assets/music/victory.ogg"
}

function updateMusicForState()
    local state = getGameState()
    
    if state == "menu" then
        AudioManager:playMusic("menu")
    elseif state == "exploration" then
        AudioManager:playMusic("exploration")
    elseif state == "battle" then
        local intensity = calculateBattleIntensity()
        
        if intensity < 0.5 then
            AudioManager:playMusic("combat_tense")
        else
            AudioManager:playMusic("combat_intense")
        end
    elseif state == "victory" then
        AudioManager:playMusic("victory")
    end
end

function calculateBattleIntensity()
    local playerHealth = getPlayerAverageHealth()
    local enemyCount = countLivingEnemies()
    local playerCount = countLiveAllies()
    
    return (1 - playerHealth / 100) + (enemyCount / playerCount)
end
```

---

## Practical Implementation

### ✅ DO: Handle Audio Format Compatibility

```lua
function loadAudioFile(name, type)
    type = type or "static"
    
    -- Try multiple formats
    local formats = {"ogg", "mp3", "wav"}
    
    for _, format in ipairs(formats) do
        local path = "assets/audio/" .. name .. "." .. format
        
        if love.filesystem.getInfo(path) then
            local success, source = pcall(love.audio.newSource, path, type)
            if success then
                return source
            end
        end
    end
    
    print("[ERROR] Could not load audio: " .. name)
    return nil
end
```

---

### ✅ DO: Create Audio Settings UI

```lua
function drawAudioSettingsPanel()
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 100, 100, 300, 200)
    
    -- Master volume slider
    drawVolumeSlider("Master", AudioManager.master_volume, 120, 120, function(v)
        AudioManager:setMasterVolume(v)
    end)
    
    -- Music volume slider
    drawVolumeSlider("Music", AudioManager.music_volume, 120, 160, function(v)
        AudioManager.music_volume = v
        if AudioManager.current_music then
            AudioManager.current_music:setVolume(v * AudioManager.master_volume)
        end
    end)
    
    -- SFX volume slider
    drawVolumeSlider("SFX", AudioManager.sfx_volume, 120, 200, function(v)
        AudioManager.sfx_volume = v
    end)
end

function drawVolumeSlider(label, value, x, y, callback)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(label .. ": " .. math.floor(value * 100) .. "%", x, y)
    
    -- Draw slider bar
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.rectangle("fill", x, y + 20, 200, 10)
    
    -- Draw slider handle
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.rectangle("fill", x + value * 200 - 5, y + 15, 10, 20)
end
```

---

### ❌ DON'T: Play Unlimited Sound Effects

```lua
-- BAD: No sound limit, causes audio chaos
function onBulletHitBad(bullet)
    love.audio.play(SOUNDS.impact)  -- Every bullet creates new source
    love.audio.play(SOUNDS.impact)
    love.audio.play(SOUNDS.impact)
    -- After 100 bullets: audio is distorted garbage
end

-- GOOD: Reuse sources and limit count
function onBulletHitGood(bullet)
    if #AudioManager.active_sounds < 32 then  -- Limit concurrent sounds
        AudioManager:playSFX("impact")
    end
end
```

---

### ❌ DON'T: Load Audio During Gameplay

```lua
-- BAD: Causes frame drops
function fireWeaponBad(weapon)
    local sound = love.audio.newSource("assets/weapons/" .. weapon.type .. ".ogg")
    sound:play()
end

-- GOOD: Preload audio
function fireWeaponGood(weapon)
    AudioManager:playSFX("weapon_" .. weapon.type)
end
```

---

## Common Patterns & Checklist

- [x] Implement centralized audio manager
- [x] Manage master/music/SFX volumes
- [x] Create sound effect pools
- [x] Implement spatial audio
- [x] Support dynamic music
- [x] Handle pause/resume states
- [x] Support audio format variety
- [x] Create audio settings UI
- [x] Limit concurrent sounds
- [x] Preload audio assets

---

## References

- Love2D Audio: https://love2d.org/wiki/Audio
- Spatial Audio: https://en.wikipedia.org/wiki/Spatial_audio
- Interactive Music: https://www.wwise.com/

