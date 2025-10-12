--[[
    Theme System for Widget Styling
    
    Centralized styling system for all widgets.
    All colors, fonts, and spacing values defined here.
]]

local Theme = {}

-- Color definitions (RGBA)
Theme.colors = {
    -- Primary colors
    primary = {r = 100/255, g = 100/255, b = 200/255, a = 1},
    secondary = {r = 80/255, g = 80/255, b = 160/255, a = 1},
    
    -- Background colors
    background = {r = 20/255, g = 20/255, b = 30/255, a = 1},
    backgroundLight = {r = 30/255, g = 30/255, b = 45/255, a = 1},
    backgroundDark = {r = 10/255, g = 10/255, b = 15/255, a = 1},
    
    -- Text colors
    text = {r = 220/255, g = 220/255, b = 220/255, a = 1},
    textDark = {r = 140/255, g = 140/255, b = 140/255, a = 1},
    textLight = {r = 1, g = 1, b = 1, a = 1},
    
    -- Border colors
    border = {r = 150/255, g = 150/255, b = 150/255, a = 1},
    borderLight = {r = 180/255, g = 180/255, b = 180/255, a = 1},
    borderDark = {r = 100/255, g = 100/255, b = 100/255, a = 1},
    
    -- State colors
    hover = {r = 120/255, g = 120/255, b = 220/255, a = 1},
    active = {r = 140/255, g = 140/255, b = 240/255, a = 1},
    disabled = {r = 80/255, g = 80/255, b = 80/255, a = 1},
    focus = {r = 100/255, g = 150/255, b = 255/255, a = 1},
    
    -- Semantic colors
    success = {r = 50/255, g = 200/255, b = 50/255, a = 1},
    warning = {r = 255/255, g = 200/255, b = 50/255, a = 1},
    error = {r = 220/255, g = 50/255, b = 50/255, a = 1},
    info = {r = 50/255, g = 150/255, b = 220/255, a = 1},
    
    -- Special colors
    transparent = {r = 0, g = 0, b = 0, a = 0},
    shadow = {r = 0, g = 0, b = 0, a = 0.5},
    
    -- Health bar colors
    healthFull = {r = 50/255, g = 200/255, b = 50/255, a = 1},
    healthHalf = {r = 255/255, g = 200/255, b = 50/255, a = 1},
    healthLow = {r = 220/255, g = 50/255, b = 50/255, a = 1},
}

-- Fonts (loaded on init)
Theme.fonts = {
    default = nil,
    small = nil,
    large = nil,
    title = nil,
}

-- Spacing and layout
Theme.spacing = 24  -- Grid cell size
Theme.padding = 4
Theme.margin = 8
Theme.borderWidth = 2
Theme.cornerRadius = 0  -- For future rounded corners

-- Widget-specific sizes
Theme.sizes = {
    buttonHeight = 48,  -- 2 grid cells
    inputHeight = 24,   -- 1 grid cell
    scrollbarWidth = 24, -- 1 grid cell
    titleBarHeight = 24, -- 1 grid cell
}

-- Global Widget Styles
-- Centralized styling for all widgets - NO PER-WIDGET OVERRIDES ALLOWED
Theme.widgetStyles = {
    -- Button styles
    button = {
        backgroundColor = "primary",
        hoverColor = "hover",
        activeColor = "active",
        disabledColor = "disabled",
        borderColor = "border",
        textColor = "text",
        disabledTextColor = "textDark",
        font = "default",
        borderWidth = 2,
    },
    
    -- Label styles
    label = {
        textColor = "text",
        backgroundColor = nil,  -- Transparent by default
        font = "default",
        align = "left",
        valign = "top",
    },
    
    -- TextInput styles
    textinput = {
        backgroundColor = "backgroundLight",
        borderColor = "border",
        textColor = "text",
        placeholderColor = "textDark",
        focusColor = "focus",
        disabledColor = "disabled",
        font = "default",
        borderWidth = 2,
        padding = 4,
    },
    
    -- Panel styles
    panel = {
        backgroundColor = "backgroundLight",
        borderColor = "border",
        borderWidth = 2,
    },
    
    -- Checkbox styles
    checkbox = {
        backgroundColor = "backgroundLight",
        borderColor = "border",
        checkColor = "primary",
        disabledColor = "disabled",
        size = 24,  -- 1 grid cell
        borderWidth = 2,
    },
    
    -- ProgressBar styles
    progressbar = {
        backgroundColor = "backgroundDark",
        fillColor = "primary",
        borderColor = "border",
        borderWidth = 2,
    },
    
    -- HealthBar styles
    healthbar = {
        backgroundColor = "backgroundDark",
        borderColor = "border",
        borderWidth = 2,
        -- Colors are dynamic based on health percentage
    },
    
    -- ListBox styles
    listbox = {
        backgroundColor = "backgroundLight",
        borderColor = "border",
        selectedColor = "primary",
        hoverColor = "hover",
        textColor = "text",
        font = "default",
        borderWidth = 2,
        itemHeight = 24,
    },
    
    -- Dropdown styles
    dropdown = {
        buttonBackgroundColor = "primary",
        buttonHoverColor = "hover",
        buttonBorderColor = "border",
        listBackgroundColor = "backgroundLight",
        listBorderColor = "border",
        textColor = "text",
        font = "default",
        borderWidth = 2,
    },
    
    -- Window/Dialog styles
    window = {
        backgroundColor = "background",
        borderColor = "border",
        titleBarColor = "primary",
        titleTextColor = "text",
        borderWidth = 2,
        titleBarHeight = 24,
    },
    
    -- Tooltip styles
    tooltip = {
        backgroundColor = "backgroundDark",
        borderColor = "border",
        textColor = "text",
        font = "small",
        borderWidth = 1,
        padding = 4,
    },
    
    -- TabWidget styles
    tabwidget = {
        tabBackgroundColor = "backgroundLight",
        tabActiveColor = "primary",
        tabHoverColor = "hover",
        tabTextColor = "text",
        contentBackgroundColor = "background",
        borderColor = "border",
        borderWidth = 2,
    },
    
    -- ScrollBox styles
    scrollbox = {
        backgroundColor = "background",
        borderColor = "border",
        scrollbarColor = "backgroundLight",
        scrollbarHoverColor = "hover",
        borderWidth = 2,
        scrollbarWidth = 24,
    },
    
    -- FrameBox styles
    framebox = {
        backgroundColor = "backgroundLight",
        borderColor = "border",
        borderWidth = 2,
    },
    
    -- RadioButton styles
    radiobutton = {
        backgroundColor = "backgroundLight",
        borderColor = "border",
        selectedColor = "primary",
        disabledColor = "disabled",
        size = 24,
        borderWidth = 2,
    },
    
    -- Spinner styles
    spinner = {
        buttonBackgroundColor = "primary",
        buttonHoverColor = "hover",
        buttonBorderColor = "border",
        textBackgroundColor = "backgroundLight",
        textBorderColor = "border",
        textColor = "text",
        font = "default",
        borderWidth = 2,
    },
    
    -- ComboBox styles
    combobox = {
        buttonBackgroundColor = "primary",
        buttonHoverColor = "hover",
        buttonBorderColor = "border",
        listBackgroundColor = "backgroundLight",
        listBorderColor = "border",
        textColor = "text",
        font = "default",
        borderWidth = 2,
    },
    
    -- Autocomplete styles
    autocomplete = {
        inputBackgroundColor = "backgroundLight",
        inputBorderColor = "border",
        inputFocusColor = "focus",
        listBackgroundColor = "backgroundLight",
        listBorderColor = "border",
        textColor = "text",
        selectedColor = "primary",
        font = "default",
        borderWidth = 2,
    },
    
    -- Table styles
    table = {
        backgroundColor = "backgroundLight",
        borderColor = "border",
        headerBackgroundColor = "primary",
        headerTextColor = "text",
        rowHoverColor = "hover",
        rowSelectedColor = "active",
        textColor = "text",
        font = "default",
        borderWidth = 1,
        rowHeight = 24,
    },
    
    -- TextArea styles
    textarea = {
        backgroundColor = "backgroundLight",
        borderColor = "border",
        textColor = "text",
        focusColor = "focus",
        disabledColor = "disabled",
        font = "default",
        borderWidth = 2,
        padding = 4,
    },
}

--[[
    Initialize theme fonts
    Should be called after Love2D is initialized
]]
function Theme.init()
    -- Try to load custom fonts from active mod
    local ModManager = require("systems.mod_manager")
    local fontPath = ModManager.getContentPath("assets", "fonts/default.ttf")
    
    local success, font = false, nil
    if fontPath then
        success, font = pcall(love.graphics.newFont, fontPath, 12)
    end
    
    if success then
        Theme.fonts.default = font
        print("[Theme] Loaded custom font from mod")
    else
        Theme.fonts.default = love.graphics.newFont(12)
        print("[Theme] Using default Love2D font")
    end
    
    Theme.fonts.small = love.graphics.newFont(10)
    Theme.fonts.large = love.graphics.newFont(16)
    Theme.fonts.title = love.graphics.newFont(18)
    
    print("[Theme] Theme initialized with fonts")
end

--[[
    Set a color from the theme
    @param colorName string - Name of the color from Theme.colors
]]
function Theme.setColor(colorName)
    local color = Theme.colors[colorName]
    if color then
        love.graphics.setColor(color.r, color.g, color.b, color.a)
    else
        print("[Theme] Warning: Unknown color '" .. tostring(colorName) .. "'")
        love.graphics.setColor(1, 1, 1, 1)
    end
end

--[[
    Get a color as a table
    @param colorName string - Name of the color
    @return table - Color table with r, g, b, a
]]
function Theme.getColor(colorName)
    return Theme.colors[colorName] or Theme.colors.text
end

--[[
    Set a font from the theme
    @param fontName string - Name of the font from Theme.fonts
]]
function Theme.setFont(fontName)
    local font = Theme.fonts[fontName]
    if font then
        love.graphics.setFont(font)
    else
        print("[Theme] Warning: Unknown font '" .. tostring(fontName) .. "'")
    end
end

--[[
    Get a font from the theme
    @param fontName string - Name of the font
    @return Font - Love2D font object
]]
function Theme.getFont(fontName)
    return Theme.fonts[fontName] or Theme.fonts.default
end

--[[
    Draw a rectangle with theme border
    @param mode string - "fill" or "line"
    @param x number - X position
    @param y number - Y position
    @param width number - Width
    @param height number - Height
    @param colorName string - Color name from theme
]]
function Theme.rectangle(mode, x, y, width, height, colorName)
    Theme.setColor(colorName)
    love.graphics.rectangle(mode, x, y, width, height)
end

--[[
    Apply a theme variant (for future theme switching)
    @param variantName string - Name of the theme variant
]]
function Theme.applyVariant(variantName)
    -- Placeholder for future theme variants (dark, light, etc.)
    print("[Theme] Theme variant '" .. variantName .. "' applied")
end

--[[
    Get color interpolated between two colors based on value
    Useful for health bars, progress bars
    @param value number - Value between 0 and 1
    @param color1 table - Start color
    @param color2 table - End color
    @return table - Interpolated color
]]
function Theme.lerpColor(value, color1, color2)
    value = math.max(0, math.min(1, value))
    return {
        r = color1.r + (color2.r - color1.r) * value,
        g = color1.g + (color2.g - color1.g) * value,
        b = color1.b + (color2.b - color1.b) * value,
        a = color1.a + (color2.a - color1.a) * value,
    }
end

--[[
    Get health bar color based on health percentage
    @param percent number - Health percentage (0-1)
    @return table - Color for health bar
]]
function Theme.getHealthColor(percent)
    if percent > 0.66 then
        return Theme.colors.healthFull
    elseif percent > 0.33 then
        return Theme.colors.healthHalf
    else
        return Theme.colors.healthLow
    end
end

--[[
    Get widget style configuration
    This is the ONLY way to access widget styles - no direct access allowed
    @param widgetType string - Type of widget (e.g., "button", "label")
    @return table - Style configuration table (READ-ONLY)
]]
function Theme.getWidgetStyle(widgetType)
    local style = Theme.widgetStyles[widgetType]
    if not style then
        print("[Theme] Warning: Unknown widget type '" .. tostring(widgetType) .. "', using default")
        return Theme.widgetStyles.button  -- Fallback
    end
    
    -- Return a read-only proxy to prevent modification
    return setmetatable({}, {
        __index = style,
        __newindex = function(t, k, v)
            error("[Theme] ERROR: Widget styles are read-only! Modify Theme.widgetStyles." .. widgetType .. " in theme.lua instead", 2)
        end,
        __metatable = false
    })
end

--[[
    Apply widget style to a widget instance
    This ensures all widgets use consistent global styling
    @param widget table - Widget instance
    @param widgetType string - Type of widget
]]
function Theme.applyWidgetStyle(widget, widgetType)
    local style = Theme.widgetStyles[widgetType]  -- Use original table, not proxy
    
    if not style then
        print("[Theme] Warning: Unknown widget type '" .. tostring(widgetType) .. "', using button style")
        style = Theme.widgetStyles.button
    end
    
    -- Apply style properties to widget (but don't allow overrides)
    for key, value in pairs(style) do
        if not widget._styleLocked then
            widget[key] = value
        end
    end
    
    -- Lock the style to prevent future changes
    widget._styleLocked = true
    
    -- Add style validation
    widget._originalStyle = style
    widget._widgetType = widgetType
end

print("[Theme] Theme system loaded")

return Theme
