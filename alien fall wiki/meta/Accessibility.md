# Accessibility

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
- [Examples](#examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Accessibility system provides inclusive design features ensuring Alien Fall remains playable for diverse player abilities through colorblind modes, control remapping, difficulty adjustments, text scaling, audio cues, and UI customization options that remove barriers while maintaining tactical depth and strategic challenge across all game modes.  
**Related Systems:** UI, Settings, Input, Graphics

---

## Purpose

This document defines comprehensive accessibility features for Alien Fall, ensuring the game is playable and enjoyable for players with diverse needs. Accessibility is a core design principle, not an afterthought.

---

## Table of Contents

1. [Design Philosophy](#design-philosophy)
2. [Visual Accessibility](#visual-accessibility)
3. [Audio Accessibility](#audio-accessibility)
4. [Motor Accessibility](#motor-accessibility)
5. [Cognitive Accessibility](#cognitive-accessibility)
6. [UI Scaling and Text](#ui-scaling-and-text)
7. [Control Customization](#control-customization)
8. [Implementation Guidelines](#implementation-guidelines)

---

## Design Philosophy

### Core Principles

1. **Universal Design**: Features benefit all players, not just those with specific needs
2. **Player Choice**: Extensive customization without judgment
3. **Clear Feedback**: Multiple sensory channels for critical information
4. **Forgiving Gameplay**: Options to adjust difficulty and timing
5. **Documentation**: Clear, accessible instructions for all features

### WCAG Compliance

Alien Fall aims for **WCAG 2.1 Level AA** compliance where applicable to games:
- Perceivable: Information presented in multiple ways
- Operable: Interface navigable via multiple input methods
- Understandable: Clear instructions and predictable behavior
- Robust: Compatible with assistive technologies

---

## Visual Accessibility

### Colorblind Modes

**Supported Types:**
```lua
colorblind_modes = {
    none = {
        name = "Standard Colors",
        description = "Default game colors"
    },
    
    protanopia = {
        name = "Protanopia (Red-Blind)",
        description = "Difficulty distinguishing red from green",
        affected_colors = {"red", "green", "orange", "brown"}
    },
    
    deuteranopia = {
        name = "Deuteranopia (Green-Blind)",
        description = "Difficulty distinguishing red from green",
        affected_colors = {"red", "green", "orange", "brown"}
    },
    
    tritanopia = {
        name = "Tritanopia (Blue-Blind)",
        description = "Difficulty distinguishing blue from yellow",
        affected_colors = {"blue", "yellow", "purple", "green"}
    },
    
    achromatopsia = {
        name = "Achromatopsia (Total Color Blindness)",
        description = "No color perception",
        affected_colors = "all"
    }
}
```

**Color Palette Adjustments:**
```lua
-- Standard palette
standard_colors = {
    enemy = {255, 0, 0},        -- Red
    friendly = {0, 255, 0},      -- Green
    neutral = {255, 255, 0},     -- Yellow
    cover = {0, 0, 255},         -- Blue
    flanked = {255, 128, 0}      -- Orange
}

-- Protanopia/Deuteranopia palette (red-green blindness)
protanopia_colors = {
    enemy = {0, 100, 255},       -- Blue (was red)
    friendly = {255, 200, 0},    -- Yellow (was green)
    neutral = {255, 255, 100},   -- Light yellow
    cover = {0, 180, 255},       -- Cyan
    flanked = {255, 100, 0}      -- Orange (distinct)
}

-- Tritanopia palette (blue-yellow blindness)
tritanopia_colors = {
    enemy = {255, 0, 100},       -- Magenta (was red)
    friendly = {0, 255, 150},    -- Cyan-green (was green)
    neutral = {200, 200, 200},   -- Gray (was yellow)
    cover = {255, 0, 200},       -- Purple (was blue)
    flanked = {255, 128, 0}      -- Orange
}

-- Achromatopsia palette (total color blindness)
achromatopsia_colors = {
    enemy = {255, 255, 255},     -- White + pattern
    friendly = {180, 180, 180},  -- Light gray + pattern
    neutral = {120, 120, 120},   -- Medium gray + pattern
    cover = {80, 80, 80},        -- Dark gray + pattern
    flanked = {200, 200, 200}    -- Light gray + different pattern
}

function applyColorblindMode(mode)
    if mode == "protanopia" or mode == "deuteranopia" then
        game.colors = protanopia_colors
    elseif mode == "tritanopia" then
        game.colors = tritanopia_colors
    elseif mode == "achromatopsia" then
        game.colors = achromatopsia_colors
    else
        game.colors = standard_colors
    end
    
    -- Reload UI elements with new colors
    reloadUIColors()
end
```

### Pattern and Symbol Support

**Icon Overlays:**
```lua
-- Additional visual indicators beyond color
accessibility_icons = {
    enemy = {
        color_indicator = true,
        pattern = "diagonal_stripes",
        symbol = "X",
        border = "thick_red"
    },
    
    friendly = {
        color_indicator = true,
        pattern = "solid",
        symbol = "✓",
        border = "thick_green"
    },
    
    neutral = {
        color_indicator = true,
        pattern = "dots",
        symbol = "?",
        border = "dashed"
    },
    
    cover = {
        color_indicator = true,
        pattern = "horizontal_lines",
        symbol = "■",
        border = "none"
    }
}

function drawAccessibleUnit(unit, x, y)
    -- Draw base sprite
    love.graphics.draw(unit.sprite, x, y)
    
    -- Add pattern overlay if enabled
    if game.settings.pattern_overlays then
        local pattern = accessibility_icons[unit.faction].pattern
        drawPattern(pattern, x, y, unit.sprite:getWidth(), unit.sprite:getHeight())
    end
    
    -- Add symbol if enabled
    if game.settings.symbol_markers then
        local symbol = accessibility_icons[unit.faction].symbol
        love.graphics.print(symbol, x + 2, y + 2)
    end
    
    -- Add border if enabled
    if game.settings.bordered_units then
        local border = accessibility_icons[unit.faction].border
        drawBorder(border, x, y, unit.sprite:getWidth(), unit.sprite:getHeight())
    end
end
```

### High Contrast Mode

**UI Contrast Settings:**
```lua
contrast_modes = {
    standard = {
        background = {30, 30, 40},
        foreground = {220, 220, 230},
        contrast_ratio = 4.5  -- WCAG AA minimum
    },
    
    high = {
        background = {0, 0, 0},
        foreground = {255, 255, 255},
        contrast_ratio = 21.0  -- Maximum contrast
    },
    
    custom = {
        background = {0, 0, 0},  -- User configurable
        foreground = {255, 255, 255},
        contrast_ratio = 21.0
    }
}

function applyContrastMode(mode)
    local colors = contrast_modes[mode]
    
    -- Update UI colors
    UI.background_color = colors.background
    UI.text_color = colors.foreground
    
    -- Update button states
    UI.button_normal = lighten(colors.background, 20)
    UI.button_hover = lighten(colors.background, 40)
    UI.button_pressed = darken(colors.background, 20)
    
    -- Update borders
    UI.border_color = colors.foreground
    UI.border_width = (mode == "high") and 2 or 1
    
    -- Reload all UI elements
    reloadUITheme()
end
```

### Screen Reader Support

**Text-to-Speech Integration:**
```lua
-- Screen reader functionality
ScreenReader = {}

function ScreenReader:new()
    return {
        enabled = false,
        speech_rate = 1.0,
        speech_volume = 1.0,
        announce_queue = {},
        focus_element = nil
    }
end

function ScreenReader:announce(text, priority)
    if not self.enabled then return end
    
    local announcement = {
        text = text,
        priority = priority or "normal",
        timestamp = love.timer.getTime()
    }
    
    -- High priority interrupts current speech
    if priority == "high" then
        self:clearQueue()
    end
    
    table.insert(self.announce_queue, announcement)
    self:processQueue()
end

function ScreenReader:describeElement(element)
    local description = element.label or element.type
    
    -- Add state information
    if element.disabled then
        description = description .. " (disabled)"
    elseif element.selected then
        description = description .. " (selected)"
    end
    
    -- Add value for interactive elements
    if element.value then
        description = description .. ": " .. tostring(element.value)
    end
    
    -- Add position context
    if element.position_in_list then
        description = description .. 
            string.format(" (%d of %d)", element.position_in_list, element.list_total)
    end
    
    return description
end

function ScreenReader:announceGameEvent(event_type, data)
    local announcements = {
        unit_killed = function(d) 
            return string.format("%s has been killed", d.unit_name)
        end,
        
        mission_complete = function(d)
            return string.format("Mission complete. %s", d.result)
        end,
        
        enemy_spotted = function(d)
            return string.format("Enemy spotted: %s at %s", 
                d.enemy_type, d.location)
        end,
        
        turn_start = function(d)
            return string.format("Turn %d. %d units remaining. %d AP available",
                d.turn_number, d.units_alive, d.total_ap)
        end,
        
        low_ammo = function(d)
            return string.format("Warning: %s low on ammunition", d.unit_name)
        end
    }
    
    local announcement_func = announcements[event_type]
    if announcement_func then
        self:announce(announcement_func(data), "normal")
    end
end
```

### Visual Cue Options

**Animation and Motion:**
```lua
motion_settings = {
    -- Reduce motion for motion sensitivity
    reduce_motion = {
        enabled = false,
        options = {
            disable_camera_shake = true,
            disable_screen_flash = true,
            slow_transitions = true,
            disable_particle_effects = false,
            disable_background_animation = false
        }
    },
    
    -- Flash warning
    photosensitivity = {
        enabled = false,
        options = {
            disable_bright_flashes = true,
            disable_rapid_flashing = true,
            flash_frequency_limit = 3  -- Max flashes per second
        }
    }
}

function shouldPlayAnimation(animation_type)
    if not motion_settings.reduce_motion.enabled then
        return true
    end
    
    local restricted = {
        camera_shake = motion_settings.reduce_motion.options.disable_camera_shake,
        screen_flash = motion_settings.reduce_motion.options.disable_screen_flash,
        particles = motion_settings.reduce_motion.options.disable_particle_effects
    }
    
    return not restricted[animation_type]
end
```

---

## Audio Accessibility

### Volume Controls

**Independent Volume Channels:**
```lua
audio_settings = {
    master_volume = 1.0,
    
    channels = {
        music = {
            volume = 0.7,
            mute = false,
            description = "Background music"
        },
        
        sfx = {
            volume = 0.8,
            mute = false,
            description = "Sound effects (weapons, explosions)"
        },
        
        ui = {
            volume = 0.6,
            mute = false,
            description = "UI sounds (clicks, notifications)"
        },
        
        voice = {
            volume = 1.0,
            mute = false,
            description = "Voice announcements"
        },
        
        ambient = {
            volume = 0.5,
            mute = false,
            description = "Ambient background sounds"
        }
    }
}

function playSound(sound, channel)
    local ch = audio_settings.channels[channel]
    if ch.mute then return end
    
    local volume = audio_settings.master_volume * ch.volume
    sound:setVolume(volume)
    sound:play()
end
```

### Visual Audio Indicators

**Subtitle System:**
```lua
subtitle_settings = {
    enabled = true,
    font_size = "medium",  -- small, medium, large, extra_large
    background_opacity = 0.75,
    position = "bottom",   -- top, bottom, custom
    color = {255, 255, 255},
    background_color = {0, 0, 0},
    display_speaker = true,
    show_sound_effects = true
}

function displaySubtitle(text, speaker, duration)
    if not subtitle_settings.enabled then return end
    
    local subtitle = {
        text = text,
        speaker = speaker,
        start_time = love.timer.getTime(),
        duration = duration or 3.0,
        font_size = subtitle_settings.font_size
    }
    
    -- Add to subtitle queue
    table.insert(game.active_subtitles, subtitle)
end

function drawSubtitles()
    local y_offset = (subtitle_settings.position == "bottom") and 
        (SCREEN_HEIGHT - 100) or 50
    
    for i, sub in ipairs(game.active_subtitles) do
        local elapsed = love.timer.getTime() - sub.start_time
        if elapsed < sub.duration then
            -- Draw background
            local text_width = getTextWidth(sub.text, sub.font_size)
            local bg_color = subtitle_settings.background_color
            love.graphics.setColor(bg_color[1], bg_color[2], bg_color[3], 
                subtitle_settings.background_opacity)
            love.graphics.rectangle("fill", 
                (SCREEN_WIDTH - text_width) / 2 - 10, 
                y_offset - 5, 
                text_width + 20, 
                30)
            
            -- Draw speaker name
            if subtitle_settings.display_speaker and sub.speaker then
                love.graphics.setColor(200, 200, 100)
                love.graphics.print(sub.speaker .. ": ", 
                    (SCREEN_WIDTH - text_width) / 2, y_offset)
            end
            
            -- Draw subtitle text
            love.graphics.setColor(subtitle_settings.color)
            love.graphics.print(sub.text, 
                (SCREEN_WIDTH - text_width) / 2, y_offset)
            
            y_offset = y_offset + 40
        end
    end
end
```

**Sound Effect Visualizer:**
```lua
sound_visualizer = {
    enabled = false,  -- Show visual indicators for important sounds
    indicators = {}
}

function visualizeSoundEffect(sound_type, source_position)
    if not sound_visualizer.enabled then return end
    
    local indicator = {
        type = sound_type,
        position = source_position,
        start_time = love.timer.getTime(),
        duration = 1.0,
        icon = getSoundIcon(sound_type),
        color = getSoundColor(sound_type)
    }
    
    table.insert(sound_visualizer.indicators, indicator)
end

function getSoundIcon(sound_type)
    local icons = {
        gunshot = "💥",
        explosion = "💣",
        footsteps = "👣",
        door = "🚪",
        alarm = "🔔",
        voice = "💬"
    }
    return icons[sound_type] or "🔊"
end

function drawSoundIndicators()
    for i, indicator in ipairs(sound_visualizer.indicators) do
        local elapsed = love.timer.getTime() - indicator.start_time
        if elapsed < indicator.duration then
            -- Draw indicator at sound source
            local screen_pos = worldToScreen(indicator.position)
            
            -- Fade out over time
            local alpha = 1.0 - (elapsed / indicator.duration)
            love.graphics.setColor(indicator.color[1], indicator.color[2], 
                indicator.color[3], alpha)
            
            -- Draw icon
            love.graphics.print(indicator.icon, screen_pos.x, screen_pos.y)
            
            -- Draw direction indicator if off-screen
            if isOffScreen(screen_pos) then
                drawOffScreenIndicator(indicator)
            end
        end
    end
end
```

---

## Motor Accessibility

### Input Remapping

**Complete Control Customization:**
```lua
input_mapping = {
    -- Movement
    move_up = {"w", "up"},
    move_down = {"s", "down"},
    move_left = {"a", "left"},
    move_right = {"d", "right"},
    
    -- Actions
    fire_weapon = {"space", "mouse1"},
    reload = {"r"},
    use_item = {"e"},
    next_unit = {"tab"},
    prev_unit = {"shift+tab"},
    
    -- UI
    confirm = {"return", "mouse1"},
    cancel = {"escape", "mouse2"},
    menu = {"escape"},
    inventory = {"i"},
    
    -- Camera
    camera_up = {"numpad8", "pageup"},
    camera_down = {"numpad2", "pagedown"},
    camera_left = {"numpad4"},
    camera_right = {"numpad6"},
    zoom_in = {"=", "wheelup"},
    zoom_out = {"-", "wheeldown"},
    
    -- Tactical
    overwatch = {"y"},
    hunker_down = {"h"},
    end_turn = {"backspace"}
}

function remapControl(action, new_keys)
    -- Validate no conflicts
    for other_action, keys in pairs(input_mapping) do
        if other_action ~= action then
            for _, key in ipairs(new_keys) do
                if tableContains(keys, key) then
                    return false, string.format(
                        "Key '%s' already bound to '%s'", 
                        key, other_action)
                end
            end
        end
    end
    
    -- Apply new mapping
    input_mapping[action] = new_keys
    saveInputSettings()
    return true
end
```

### Mouse Assistance

**Click Assistance:**
```lua
mouse_assistance = {
    -- Larger click targets
    enlarged_targets = {
        enabled = false,
        multiplier = 1.5  -- 50% larger hitboxes
    },
    
    -- Click and hold instead of precise clicks
    hold_to_confirm = {
        enabled = false,
        duration = 0.5  -- Hold for 500ms
    },
    
    -- Auto-aim assistance
    snap_to_target = {
        enabled = false,
        range = 50  -- Snap within 50 pixels
    }
}

function checkButtonClick(button, mouse_x, mouse_y)
    local hitbox = button.hitbox
    
    -- Enlarge hitbox if enabled
    if mouse_assistance.enlarged_targets.enabled then
        local mult = mouse_assistance.enlarged_targets.multiplier
        hitbox = {
            x = button.x - (button.width * (mult - 1) / 2),
            y = button.y - (button.height * (mult - 1) / 2),
            width = button.width * mult,
            height = button.height * mult
        }
    end
    
    return pointInRect(mouse_x, mouse_y, hitbox)
end

function updateHoldToConfirm(button, dt)
    if not mouse_assistance.hold_to_confirm.enabled then
        return button.clicked
    end
    
    if button.hovered and love.mouse.isDown(1) then
        button.hold_time = (button.hold_time or 0) + dt
        
        if button.hold_time >= mouse_assistance.hold_to_confirm.duration then
            button.hold_time = 0
            return true  -- Confirmed
        end
    else
        button.hold_time = 0
    end
    
    return false
end
```

### Turn-Based Advantage

**Generous Timing:**
```lua
timing_options = {
    -- No time limits on turns (already turn-based, but reinforces)
    unlimited_turn_time = true,
    
    -- Undo last action
    allow_undo = {
        enabled = false,  -- Can be enabled for accessibility
        max_undo = 1      -- Can only undo last action
    },
    
    -- Confirm important actions
    confirm_destructive_actions = true,
    confirm_end_turn = false
}

function performAction(action)
    -- Check if confirmation needed
    if timing_options.confirm_destructive_actions then
        if action.is_destructive and not action.confirmed then
            showConfirmationDialog(action)
            return false
        end
    end
    
    -- Execute action
    local success = executeAction(action)
    
    -- Store for undo if enabled
    if success and timing_options.allow_undo.enabled then
        storeUndoAction(action)
    end
    
    return success
end

function undoLastAction()
    if not timing_options.allow_undo.enabled then return false end
    if #game.undo_stack == 0 then return false end
    
    local action = table.remove(game.undo_stack)
    revertAction(action)
    return true
end
```

---

## Cognitive Accessibility

### Tutorial and Guidance

**Progressive Complexity:**
```lua
tutorial_settings = {
    -- Step-by-step guidance
    tutorial_mode = {
        enabled = true,
        current_step = 1,
        skip_allowed = true
    },
    
    -- Tooltips
    tooltips = {
        enabled = true,
        delay = 0.5,  -- Show after hovering 0.5 seconds
        detailed = true  -- Show detailed information
    },
    
    -- Hint system
    hints = {
        enabled = true,
        frequency = "normal",  -- off, minimal, normal, frequent
        adaptive = true  -- Adjust based on player performance
    }
}

function showContextualHint(context)
    if not tutorial_settings.hints.enabled then return end
    
    local hints = {
        low_health = "Your unit has low health. Consider using cover or retreating.",
        flanked = "You're flanked! The enemy has a critical hit bonus.",
        out_of_ammo = "Out of ammo! Press R to reload.",
        good_position = "Excellent position! You have height advantage and cover.",
        mission_objective = "Remember: Complete the objective to win the mission."
    }
    
    local hint_text = hints[context]
    if hint_text then
        displayHint(hint_text)
    end
end
```

### Information Clarity

**Clear Stat Display:**
```lua
stats_display = {
    -- Show exact numbers instead of bars
    show_numeric_values = true,
    
    -- Color code values (good/bad)
    color_coded_stats = true,
    
    -- Show change indicators
    show_stat_changes = true,
    
    -- Simplified descriptions
    use_plain_language = true
}

function formatStatDisplay(stat_name, value, max_value)
    local display = {}
    
    -- Numeric value
    if stats_display.show_numeric_values then
        display.text = string.format("%s: %d / %d", stat_name, value, max_value)
    else
        display.text = stat_name
    end
    
    -- Color coding
    if stats_display.color_coded_stats then
        local percentage = value / max_value
        if percentage > 0.66 then
            display.color = {0, 255, 0}  -- Green (good)
        elseif percentage > 0.33 then
            display.color = {255, 255, 0}  -- Yellow (warning)
        else
            display.color = {255, 0, 0}  -- Red (critical)
        end
    end
    
    -- Visual bar
    display.bar_width = (value / max_value) * 100
    
    return display
end
```

### Memory Aids

**Quick Reference:**
```lua
reference_system = {
    -- Quick stats overlay
    quick_stats = {
        enabled = true,
        always_visible = false,
        toggle_key = "f1"
    },
    
    -- Unit roster
    roster_overlay = {
        enabled = true,
        show_health = true,
        show_ammo = true,
        show_abilities = true
    },
    
    -- Mission objectives reminder
    objective_reminder = {
        enabled = true,
        position = "top_right",
        always_visible = true
    }
}

function drawQuickReference()
    if not reference_system.quick_stats.enabled then return end
    if not (reference_system.quick_stats.always_visible or 
            isKeyDown(reference_system.quick_stats.toggle_key)) then
        return
    end
    
    local y = 100
    
    -- Current unit stats
    if game.selected_unit then
        local unit = game.selected_unit
        love.graphics.print(string.format("HP: %d/%d", 
            unit.health, unit.max_health), 10, y)
        y = y + 20
        love.graphics.print(string.format("AP: %d/%d", 
            unit.action_points, unit.max_action_points), 10, y)
        y = y + 20
        love.graphics.print(string.format("Ammo: %d/%d", 
            unit.ammo, unit.max_ammo), 10, y)
        y = y + 30
    end
    
    -- Mission objective
    if reference_system.objective_reminder.enabled then
        love.graphics.print("Objective: " .. game.mission.objective, 10, y)
    end
end
```

---

## UI Scaling and Text

### Dynamic Scaling

**Resolution-Independent UI:**
```lua
ui_scale_settings = {
    -- Base resolution: 800x600
    base_width = 800,
    base_height = 600,
    
    -- UI scale multiplier
    ui_scale = 1.0,  -- 0.75, 1.0, 1.25, 1.5, 2.0
    
    -- Text scale (can be different from UI scale)
    text_scale = 1.0,
    
    -- Minimum touch target size (for accessibility)
    min_button_size = 44  -- 44x44 pixels minimum (iOS guidelines)
}

function scaleUI(base_size)
    return base_size * ui_scale_settings.ui_scale
end

function scaleText(base_size)
    return base_size * ui_scale_settings.text_scale
end

function createAccessibleButton(label, x, y, width, height)
    -- Ensure minimum size
    local min_size = ui_scale_settings.min_button_size
    width = math.max(width, min_size)
    height = math.max(height, min_size)
    
    return {
        label = label,
        x = scaleUI(x),
        y = scaleUI(y),
        width = scaleUI(width),
        height = scaleUI(height),
        font_size = scaleText(14)
    }
end
```

### Font Options

**Font Settings:**
```lua
font_settings = {
    -- Font family
    font_family = "default",  -- default, dyslexic, mono
    
    -- Font sizes
    sizes = {
        small = 10,
        medium = 14,
        large = 18,
        extra_large = 24
    },
    
    -- Text rendering
    antialiasing = true,
    letter_spacing = 0,  -- Extra spacing between letters
    line_height = 1.2,   -- Multiplier for line spacing
    
    -- Dyslexia-friendly options
    dyslexic_font = false,
    increased_spacing = false,
    no_italics = false
}

function loadFont(size_name)
    local size = font_settings.sizes[size_name] or font_settings.sizes.medium
    size = size * ui_scale_settings.text_scale
    
    local font_file = "assets/fonts/"
    if font_settings.dyslexic_font then
        font_file = font_file .. "OpenDyslexic.ttf"
    elseif font_settings.font_family == "mono" then
        font_file = font_file .. "SourceCodePro.ttf"
    else
        font_file = font_file .. "Roboto.ttf"
    end
    
    return love.graphics.newFont(font_file, size)
end

function drawAccessibleText(text, x, y, size_name)
    local font = loadFont(size_name)
    love.graphics.setFont(font)
    
    -- Apply letter spacing if enabled
    if font_settings.increased_spacing then
        drawTextWithSpacing(text, x, y, font_settings.letter_spacing)
    else
        love.graphics.print(text, x, y)
    end
end
```

---

## Control Customization

### Input Methods

**Supported Input Devices:**
```lua
input_methods = {
    keyboard_mouse = {
        enabled = true,
        primary = true
    },
    
    gamepad = {
        enabled = true,
        type = "xbox",  -- xbox, playstation, generic
        vibration = true
    },
    
    keyboard_only = {
        enabled = true,
        tab_navigation = true,
        enter_to_select = true
    },
    
    mouse_only = {
        enabled = true,
        context_menus = true,
        drag_to_pan = true
    }
}

function setupInputMethod(method)
    if method == "keyboard_only" then
        -- Enable tab navigation through all UI elements
        UI.tab_navigation = true
        UI.focus_visible = true
        
        -- All actions must be keyboard accessible
        ensureKeyboardShortcuts()
    elseif method == "gamepad" then
        -- Map gamepad controls
        setupGamepadMapping()
        
        -- Show gamepad button icons instead of keyboard keys
        UI.show_gamepad_icons = true
    end
end
```

### Macro System

**Custom Action Macros:**
```lua
macro_system = {
    enabled = true,
    macros = {}
}

function createMacro(name, actions)
    local macro = {
        name = name,
        actions = actions,
        hotkey = nil
    }
    
    macro_system.macros[name] = macro
    return macro
end

-- Example: "Defensive Position" macro
defensive_position_macro = createMacro("Defensive Position", {
    {action = "find_cover", priority = "high"},
    {action = "overwatch"},
    {action = "end_turn"}
})

function executeMacro(macro_name)
    local macro = macro_system.macros[macro_name]
    if not macro then return false end
    
    for _, action in ipairs(macro.actions) do
        if not canPerformAction(action) then
            return false  -- Macro failed
        end
        performAction(action)
    end
    
    return true  -- Macro succeeded
end
```

---

## Implementation Guidelines

### Testing Checklist

**Accessibility Testing:**
```lua
accessibility_tests = {
    -- Visual
    {
        name = "Colorblind Mode Test",
        test = function()
            -- Verify all colorblind modes display correctly
            for mode, _ in pairs(colorblind_modes) do
                applyColorblindMode(mode)
                assert(verifyUIContrast(), "Insufficient contrast in " .. mode)
            end
        end
    },
    
    -- Audio
    {
        name = "Audio Independence Test",
        test = function()
            -- Verify game is playable with audio off
            audio_settings.master_volume = 0
            assert(canCompleteBasicTask(), "Game requires audio")
        end
    },
    
    -- Motor
    {
        name = "Keyboard-Only Test",
        test = function()
            -- Verify all functions accessible via keyboard
            setupInputMethod("keyboard_only")
            assert(canNavigateAllMenus(), "Some menus not keyboard accessible")
        end
    },
    
    -- Cognitive
    {
        name = "Tutorial Clarity Test",
        test = function()
            -- Verify tutorials are clear and helpful
            assert(tutorialCompletionRate() > 0.8, "Tutorial too confusing")
        end
    }
}

function runAccessibilityTests()
    local results = {}
    for _, test in ipairs(accessibility_tests) do
        local success, error = pcall(test.test)
        table.insert(results, {
            name = test.name,
            passed = success,
            error = error
        })
    end
    return results
end
```

### User Settings Persistence

**Save/Load Settings:**
```lua
function saveAccessibilitySettings()
    local settings = {
        colorblind_mode = game.settings.colorblind_mode,
        high_contrast = game.settings.high_contrast,
        screen_reader = game.settings.screen_reader,
        reduce_motion = motion_settings.reduce_motion.enabled,
        subtitle_settings = subtitle_settings,
        font_settings = font_settings,
        ui_scale = ui_scale_settings.ui_scale,
        text_scale = ui_scale_settings.text_scale,
        input_mapping = input_mapping,
        audio_settings = audio_settings
    }
    
    local serialized = serialize(settings)
    love.filesystem.write("accessibility_settings.lua", serialized)
end

function loadAccessibilitySettings()
    if love.filesystem.getInfo("accessibility_settings.lua") then
        local settings = love.filesystem.load("accessibility_settings.lua")()
        
        -- Apply each setting
        applyColorblindMode(settings.colorblind_mode)
        applyContrastMode(settings.high_contrast and "high" or "standard")
        game.screen_reader.enabled = settings.screen_reader
        
        -- ... apply all other settings
    end
end
```

### Performance Considerations

**Optimization:**
```lua
-- Cache scaled values to avoid repeated calculations
local scaled_values_cache = {}

function getScaledValue(base_value, scale_type)
    local cache_key = base_value .. "_" .. scale_type
    
    if not scaled_values_cache[cache_key] then
        if scale_type == "ui" then
            scaled_values_cache[cache_key] = scaleUI(base_value)
        elseif scale_type == "text" then
            scaled_values_cache[cache_key] = scaleText(base_value)
        end
    end
    
    return scaled_values_cache[cache_key]
end

-- Clear cache when settings change
function onAccessibilitySettingsChanged()
    scaled_values_cache = {}
    reloadUIElements()
end
```

---

## Cross-References

### Related Documents
- [UI Design System](../GUI/UI_Design_System.md) - UI component library
- [Audio Design](Audio.md) - Sound and music implementation
- [Tutorial System](Tutorial.md) - Player onboarding
- [Input System](../technical/Input_System.md) - Control handling

### Related Systems
- **Settings System** - Persistence of accessibility options
- **UI System** - Rendering of accessible interfaces
- **Audio System** - Sound and subtitle management
- **Input System** - Control remapping and assistance

---

## Additional Resources

### External Guidelines
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Game Accessibility Guidelines](http://gameaccessibilityguidelines.com/)
- [AbleGamers Resources](https://accessible.games/)
- [Microsoft Inclusive Design](https://www.microsoft.com/design/inclusive/)

### Recommended Fonts
- **OpenDyslexic**: Free dyslexia-friendly font
- **Atkinson Hyperlegible**: Optimized for low vision readers
- **Roboto**: Clean, highly legible sans-serif
- **Source Code Pro**: Monospace font with clear character distinction

---

**Document Status:** Complete  
**Implementation Priority:** High (Player inclusivity)  
**Testing Requirements:** Comprehensive accessibility testing, user feedback  
**Last Reviewed:** September 30, 2025
