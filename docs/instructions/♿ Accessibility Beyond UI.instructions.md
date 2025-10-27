# ♿ Accessibility Beyond UI Best Practices

**Domain:** Accessibility & Inclusivity  
**Focus:** Colorblind modes, audio accessibility, motor accessibility, cognitive accessibility  
**Version:** 1.0  
**Date:** October 2025

## Overview

This guide covers implementing accessibility features beyond basic UI, ensuring games are playable for all.

## Visual Accessibility

### ✅ DO: Implement Colorblind Modes

```lua
COLORBLIND_MODES = {
    normal = {
        red = {1, 0, 0},
        green = {0, 1, 0},
        blue = {0, 0, 1}
    },
    deuteranopia = {  -- Red-green colorblindness
        red = {1, 0.6, 0},
        green = {0.6, 0.8, 1},
        blue = {0, 0, 1}
    },
    protanopia = {  -- Another red-green type
        red = {0.6, 0.3, 0},
        green = {0.9, 0.9, 0},
        blue = {0, 0, 1}
    },
    tritanopia = {  -- Blue-yellow colorblindness
        red = {0.95, 0.6, 0},
        green = {0, 0.8, 0.9},
        blue = {0.8, 0, 0.9}
    }
}

function getColorForMode(colorName, mode)
    mode = mode or "normal"
    return COLORBLIND_MODES[mode][colorName]
end

-- Usage in gameplay
function drawUnit(unit)
    local red = getColorForMode("red", ACCESSIBILITY.colorblind_mode)
    love.graphics.setColor(red)
    love.graphics.circle("fill", unit.x, unit.y, 10)
end
```

---

### ✅ DO: Support Pattern-Based Indicators

```lua
PATTERNS = {
    solid = {},
    striped = {0.1, 0.2, 0.1, 0.2},
    dotted = {0.05, 0.1, 0.05, 0.1},
    cross = {0.15, 0.15, 0.15, 0.15}
}

function drawUnitWithPattern(unit, color, pattern)
    -- Draw base color
    love.graphics.setColor(color)
    love.graphics.circle("fill", unit.x, unit.y, 10)
    
    -- Overlay pattern for additional info
    if pattern then
        love.graphics.setColor(0, 0, 0, 0.3)
        local time = love.timer.getTime()
        
        if pattern == "striped" then
            for i = 0, 20, 2 do
                love.graphics.line(
                    unit.x - 10 + i, unit.y - 10,
                    unit.x - 10 + i, unit.y + 10
                )
            end
        elseif pattern == "dotted" then
            for x = -8, 8, 4 do
                for y = -8, 8, 4 do
                    love.graphics.circle("fill", unit.x + x, unit.y + y, 1)
                end
            end
        end
    end
end
```

---

## Audio Accessibility

### ✅ DO: Provide Audio Cues with Visual Feedback

```lua
function playAudioCueWithVisual(soundName, x, y)
    -- Play audio
    love.audio.play(SOUNDS[soundName])
    
    -- Add visual feedback
    table.insert(VISUAL_FEEDBACK, {
        type = "audio_cue",
        sound = soundName,
        x = x, y = y,
        time = love.timer.getTime(),
        duration = 0.5
    })
end

-- Visual feedback for audio events
function drawAudioCueIndicators()
    for _, indicator in ipairs(VISUAL_FEEDBACK) do
        if indicator.type == "audio_cue" then
            local age = love.timer.getTime() - indicator.time
            
            -- Fade out over time
            local alpha = 1 - (age / indicator.duration)
            love.graphics.setColor(1, 1, 0, alpha)
            
            -- Draw expanding circle
            local radius = 10 + (age / indicator.duration) * 20
            love.graphics.circle("line", indicator.x, indicator.y, radius)
        end
    end
end
```

---

### ✅ DO: Provide Captions and Transcripts

```lua
CAPTIONS = {
    mission_briefing = "Commander, we have a situation...",
    unit_death = "Soldier down!",
    alien_attack = "Enemy contact!"
}

function playCinematicWithCaptions(cinematicName)
    local caption = CAPTIONS[cinematicName]
    
    if ACCESSIBILITY.captions_enabled and caption then
        -- Display caption at bottom of screen
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 700, 960, 20)
        
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf(caption, 0, 705, 960, "center")
    end
end
```

---

## Motor Accessibility

### ✅ DO: Support Alternative Input Methods

```lua
-- Map various inputs to same action
INPUT_MAPPING = {
    move_up = {"up", "w", "kp8"},
    move_down = {"down", "s", "kp2"},
    move_left = {"left", "a", "kp4"},
    move_right = {"right", "d", "kp6"},
    select = {"return", "space", "kp5"},
    cancel = {"escape", "backspace"}
}

function handleInput(key)
    for action, keys in pairs(INPUT_MAPPING) do
        for _, k in ipairs(keys) do
            if key == k then
                return executeAction(action)
            end
        end
    end
end

-- Support gamepad
function love.gamepadpressed(joystick, button)
    -- Remap gamepad to same action system
    if button == "dpad_up" or button == "a" then
        executeAction("select")
    elseif button == "b" then
        executeAction("cancel")
    end
end
```

---

### ✅ DO: Provide Aim Assist for Motor Impairments

```lua
function updateAimAssist()
    if not ACCESSIBILITY.aim_assist then return end
    
    local player = getPlayer()
    local mouseX, mouseY = love.mouse.getPosition()
    
    -- Snap to nearby targets
    local nearestTarget, nearestDist = nil, 200
    
    for _, unit in ipairs(getEnemyUnits()) do
        local dist = math.sqrt((unit.x - mouseX)^2 + (unit.y - mouseY)^2)
        if dist < nearestDist then
            nearestTarget = unit
            nearestDist = dist
        end
    end
    
    if nearestTarget then
        -- Adjust aim slightly toward target
        local targetAngle = math.atan2(nearestTarget.y - player.y, nearestTarget.x - player.x)
        player.aim_angle = interpolate(player.aim_angle, targetAngle, 0.1)
    end
end
```

---

## Cognitive Accessibility

### ✅ DO: Provide Help and Tooltips

```lua
TOOLTIPS = {
    end_turn_button = "End your turn and let the enemy move",
    save_button = "Save your game progress",
    difficulty_hard = "Enemies are stronger and more intelligent"
}

function drawTooltips()
    local mouseX, mouseY = love.mouse.getPosition()
    
    for element, tooltip in pairs(TOOLTIPS) do
        local bounds = getElementBounds(element)
        
        if mouseInBounds(mouseX, mouseY, bounds) then
            if ACCESSIBILITY.show_tooltips then
                drawTooltipBox(tooltip, mouseX + 10, mouseY + 10)
            end
        end
    end
end

function drawTooltipBox(text, x, y)
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", x - 5, y - 5, 200, 60)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(text, x, y, 190, "left")
end
```

---

### ✅ DO: Support Difficulty Customization

```lua
DIFFICULTY_OPTIONS = {
    enemy_health_multiplier = 0.5,
    enemy_accuracy = 0.4,
    player_health_multiplier = 2.0,
    time_per_turn = 60  -- seconds
}

function applyDifficultyModifiers()
    for modifier, value in pairs(ACCESSIBILITY.difficulty_modifiers) do
        if DIFFICULTY_OPTIONS[modifier] then
            DIFFICULTY_OPTIONS[modifier] = value
        end
    end
end

-- Allow granular difficulty customization
function customizeDifficulty()
    return {
        enemy_health_multiplier = 0.75,  -- 25% easier
        enemy_accuracy = 0.8,
        player_damage_multiplier = 1.2,  -- 20% stronger
        turn_time_limit = 120  -- More time
    }
end
```

---

### ❌ DON'T: Use Color Alone as Information

```lua
-- BAD: Only color indicates status
function drawUnitStatusBad(unit)
    if unit.status == "injured" then
        love.graphics.setColor(1, 0, 0)  -- Red only
    end
    love.graphics.circle("fill", unit.x, unit.y, 10)
end

-- GOOD: Color plus symbol/pattern
function drawUnitStatusGood(unit)
    if unit.status == "injured" then
        love.graphics.setColor(1, 0, 0)
        love.graphics.circle("fill", unit.x, unit.y, 10)
        
        -- Add symbol
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("!", unit.x - 3, unit.y - 5)
    end
end
```

---

### ❌ DON'T: Require Precision or Speed

```lua
-- BAD: Timed QTE with tiny hit box
function drawQTEBad()
    -- Player has 1 second to click 10x10 pixel area
    love.graphics.rectangle("fill", 475, 355, 10, 10)
end

-- GOOD: Generous timing and hit box
function drawQTEGood()
    if ACCESSIBILITY.reduced_precision then
        -- 5 second window, 50x50 hit box
        local scale = 50 / 10
        love.graphics.rectangle("fill", 455, 335, 50, 50)
    end
end
```

---

## Common Patterns & Checklist

- [x] Implement colorblind modes (multiple types)
- [x] Use patterns/symbols alongside colors
- [x] Provide audio cues with visual feedback
- [x] Include captions and transcripts
- [x] Support multiple input methods
- [x] Implement aim assist for motor issues
- [x] Provide helpful tooltips
- [x] Allow difficulty customization
- [x] Don't rely on color alone
- [x] Don't require precision/speed

---

## References

- Web Content Accessibility Guidelines: https://www.w3.org/WAI/WCAG21/quickref/
- Game Accessibility: https://game-accessibility.org/
- Colorblind Palettes: https://www.color-blindness.com/

