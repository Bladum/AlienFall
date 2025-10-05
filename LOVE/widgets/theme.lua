--[[
widgets/theme.lua
Unified theming system for the widget library


Comprehensive theming system providing centralized theme definitions, runtime theme switching,
and smooth transitions for consistent UI styling across all widgets in tactical strategy games.
Essential for maintaining visual consistency and supporting accessibility in OpenXCOM-style interfaces.

PURPOSE:
- Provide centralized theme management for all UI widgets
- Support multiple visual themes for different user preferences
- Enable runtime theme switching with smooth transitions
- Ensure consistent styling across the entire widget library
- Support accessibility features like high contrast and large text modes

KEY FEATURES:
- Predefined themes: default, dark, highContrast with comprehensive color palettes
- Runtime theme switching with instant or smooth transitions
- Custom theme creation and registration system
- Color interpolation for smooth theme transitions
- Accessibility support: high contrast mode, large text mode
- Comprehensive color system covering all UI states and components
- Integration with core.theme for widget styling
- Performance optimized with efficient color lookups

@see widgets.common.core.Base
@see widgets.common.button
@see widgets.common.label
@see widgets.common.panel
]]

local core = require("widgets.core")
local theme = {}

-- Predefined themes
theme.themes = {
    default = {
        primary = { 0.7, 0.7, 0.7, 1 },
        primaryHover = { 0.8, 0.8, 0.8, 1 },
        primaryPressed = { 0.5, 0.5, 0.5, 1 },
        primaryDisabled = { 0.4, 0.4, 0.4, 1 },
        secondary = { 0.9, 0.9, 0.9, 1 },
        secondaryHover = { 0.95, 0.95, 0.95, 1 },
        accent = { 0.2, 0.8, 0.2, 1 },
        accentHover = { 0.3, 0.9, 0.3, 1 },
        text = { 0, 0, 0, 1 },
        textSecondary = { 0.3, 0.3, 0.3, 1 },
        textDisabled = { 0.6, 0.6, 0.6, 1 },
        textInverse = { 1, 1, 1, 1 },
        border = { 0, 0, 0, 1 },
        borderFocus = { 0.2, 0.6, 1, 1 },
        background = { 1, 1, 1, 1 },
        backgroundDark = { 0.1, 0.1, 0.1, 1 },
        error = { 1, 0.2, 0.2, 1 },
        warning = { 1, 0.8, 0.2, 1 },
        success = { 0.2, 0.8, 0.2, 1 },
        info = { 0.2, 0.6, 1, 1 },
        selection = { 0.3, 0.6, 1, 0.3 },
        tooltip = { 0.1, 0.1, 0.1, 0.9 }
    },

    dark = {
        primary = { 0.3, 0.3, 0.3, 1 },
        primaryHover = { 0.4, 0.4, 0.4, 1 },
        primaryPressed = { 0.2, 0.2, 0.2, 1 },
        primaryDisabled = { 0.15, 0.15, 0.15, 1 },
        secondary = { 0.2, 0.2, 0.2, 1 },
        secondaryHover = { 0.25, 0.25, 0.25, 1 },
        accent = { 0.4, 0.8, 0.4, 1 },
        accentHover = { 0.5, 0.9, 0.5, 1 },
        text = { 1, 1, 1, 1 },
        textSecondary = { 0.7, 0.7, 0.7, 1 },
        textDisabled = { 0.4, 0.4, 0.4, 1 },
        textInverse = { 0, 0, 0, 1 },
        border = { 0.3, 0.3, 0.3, 1 },
        borderFocus = { 0.4, 0.8, 1, 1 },
        background = { 0.1, 0.1, 0.1, 1 },
        backgroundDark = { 0.05, 0.05, 0.05, 1 },
        error = { 1, 0.3, 0.3, 1 },
        warning = { 1, 0.7, 0.3, 1 },
        success = { 0.3, 1, 0.3, 1 },
        info = { 0.3, 0.7, 1, 1 },
        selection = { 0.4, 0.7, 1, 0.3 },
        tooltip = { 0.9, 0.9, 0.9, 0.9 }
    },

    highContrast = {
        primary = { 1, 1, 1, 1 },
        primaryHover = { 1, 1, 0, 1 },
        primaryPressed = { 0.8, 0.8, 0.8, 1 },
        primaryDisabled = { 0.5, 0.5, 0.5, 1 },
        secondary = { 0.8, 0.8, 0.8, 1 },
        secondaryHover = { 1, 1, 0, 1 },
        accent = { 1, 0, 1, 1 },
        accentHover = { 1, 0.5, 1, 1 },
        text = { 0, 0, 0, 1 },
        textSecondary = { 0, 0, 0, 1 },
        textDisabled = { 0.5, 0.5, 0.5, 1 },
        textInverse = { 1, 1, 1, 1 },
        border = { 0, 0, 0, 1 },
        borderFocus = { 1, 0, 0, 1 },
        background = { 1, 1, 1, 1 },
        backgroundDark = { 0, 0, 0, 1 },
        error = { 1, 0, 0, 1 },
        warning = { 1, 0.5, 0, 1 },
        success = { 0, 1, 0, 1 },
        info = { 0, 0, 1, 1 },
        selection = { 1, 1, 0, 0.5 },
        tooltip = { 0, 0, 0, 0.9 }
    }
}

-- Current theme
theme.current = "default"

-- Theme transition system
theme.transition = {
    active = false,
    fromTheme = nil,
    toTheme = nil,
    progress = 0,
    duration = 0.5,
    easing = function(t) return t * t * (3 - 2 * t) end -- Smooth step
}

--- Sets the current theme for the widget system.
---
---@param themeName string The name of the theme to set.
---@return boolean True if the theme was set successfully, false otherwise.
function theme.setTheme(themeName)
    if theme.themes[themeName] then
        theme.current = themeName
        core.theme = theme.themes[themeName]

        if core.config.enableAccessibility then
            core.announce("Theme changed to " .. themeName)
        end

        return true
    end
    return false
end

--- Starts a smooth transition to a new theme.
---
---@param themeName string The name of the theme to transition to.
---@param duration? number The duration of the transition in seconds (default: 0.5).
---@return boolean True if the transition was started successfully, false otherwise.
function theme.transitionToTheme(themeName, duration)
    if not theme.themes[themeName] then return false end

    theme.transition.active = true
    theme.transition.fromTheme = theme.current
    theme.transition.toTheme = themeName
    theme.transition.progress = 0
    theme.transition.duration = duration or 0.5

    return true
end

--- Updates the theme transition system.
---
---@param dt number Delta time since the last update.
function theme.update(dt)
    if theme.transition.active then
        theme.transition.progress = theme.transition.progress + dt

        if theme.transition.progress >= theme.transition.duration then
            theme.transition.active = false
            theme.setTheme(theme.transition.toTheme)
        else
            local t = theme.transition.progress / theme.transition.duration
            t = theme.transition.easing(t)

            local fromTheme = theme.themes[theme.transition.fromTheme]
            local toTheme = theme.themes[theme.transition.toTheme]

            -- Interpolate theme colors
            for key, toColor in pairs(toTheme) do
                local fromColor = fromTheme[key]
                if fromColor and #fromColor == 4 and #toColor == 4 then
                    core.theme[key] = {
                        core.lerp(fromColor[1], toColor[1], t),
                        core.lerp(fromColor[2], toColor[2], t),
                        core.lerp(fromColor[3], toColor[3], t),
                        core.lerp(fromColor[4], toColor[4], t)
                    }
                end
            end
        end
    end
end

--- Gets a color from the current theme.
---
---@param colorKey string The key of the color to retrieve.
---@param alpha? number Optional alpha value to override the theme's alpha.
---@return table The color as a table {r, g, b, a}.
function theme.getColor(colorKey, alpha)
    local color = core.theme[colorKey] or core.theme.primary
    if alpha then
        return { color[1], color[2], color[3], alpha }
    end
    return color
end

--- Sets a color in the current theme.
---
---@param colorKey string The key of the color to set.
---@param r? number Red component (0-1, default: 1).
---@param g? number Green component (0-1, default: 1).
---@param b? number Blue component (0-1, default: 1).
---@param a? number Alpha component (0-1, default: 1).
function theme.setColor(colorKey, r, g, b, a)
    core.theme[colorKey] = { r or 1, g or 1, b or 1, a or 1 }
end

--- Creates a custom theme based on an existing theme with overrides.
---
---@param baseTheme string The name of the base theme to extend.
---@param overrides table Table of color overrides {colorKey = {r, g, b, a}, ...}.
---@return table The custom theme table.
function theme.createCustomTheme(baseTheme, overrides)
    local customTheme = {}

    -- Copy base theme
    for k, v in pairs(theme.themes[baseTheme] or theme.themes.default) do
        customTheme[k] = { unpack(v) }
    end

    -- Apply overrides
    for k, v in pairs(overrides) do
        if type(v) == "table" and #v >= 3 then
            customTheme[k] = { unpack(v) }
        end
    end

    return customTheme
end

--- Registers a new theme in the theme system.
---
---@param name string The name of the theme.
---@param themeData table The theme data table with color definitions.
function theme.registerTheme(name, themeData)
    theme.themes[name] = themeData
end

--- Gets a list of all available theme names.
---
---@return table Array of available theme names.
function theme.getAvailableThemes()
    local themes = {}
    for name, _ in pairs(theme.themes) do
        table.insert(themes, name)
    end
    return themes
end

-- High contrast mode

--- Enables or disables high contrast mode.
---
---@param enabled boolean Whether to enable high contrast mode.
function theme.setHighContrastMode(enabled)
    core.accessibility.highContrastMode = enabled
    if enabled then
        theme.setTheme("highContrast")
    else
        theme.setTheme("default")
    end
end

-- Large text mode

--- Enables or disables large text mode for accessibility.
---
---@param enabled boolean Whether to enable large text mode.
function theme.setLargeTextMode(enabled)
    core.accessibility.largeTextMode = enabled
    -- This would require font scaling implementation
    if core.config.enableAccessibility then
        core.announce(enabled and "Large text mode enabled" or "Large text mode disabled")
    end
end

return theme





