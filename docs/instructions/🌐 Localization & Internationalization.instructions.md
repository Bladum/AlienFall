# 🌐 Localization & Internationalization Best Practices

**Domain:** Localization & Global Support  
**Focus:** Multi-language support, text management, cultural adaptation, locale-specific content  
**Version:** 1.0  
**Date:** October 2025

## Overview

This guide covers implementing localization systems, managing translations, and supporting multiple languages.

## Localization Architecture

### ✅ DO: Implement String Key System

```lua
-- localization/strings.lua
STRINGS = {
    en = {
        ui = {
            main_menu = "Main Menu",
            new_game = "New Game",
            load_game = "Load Game",
            settings = "Settings",
            quit = "Quit"
        },
        battle = {
            move_unit = "Move Unit",
            end_turn = "End Turn",
            unit_killed = "%s killed %s"
        }
    },
    es = {
        ui = {
            main_menu = "Menú Principal",
            new_game = "Nuevo Juego",
            load_game = "Cargar Juego",
            settings = "Configuración",
            quit = "Salir"
        },
        battle = {
            move_unit = "Mover Unidad",
            end_turn = "Fin de Turno",
            unit_killed = "%s mató a %s"
        }
    }
}

function getString(key, lang)
    lang = lang or LOCALIZATION.current_language
    local keys = key:split(".")
    local str = STRINGS[lang]
    
    for _, k in ipairs(keys) do
        str = str[k]
        if not str then return key end  -- Fallback to key
    end
    
    return str
end

-- Usage
print(getString("ui.main_menu"))  -- "Main Menu" or "Menú Principal"
```

---

### ✅ DO: Support Formatting and Pluralization

```lua
function getString(key, lang, args)
    lang = lang or LOCALIZATION.current_language
    local str = getStringRaw(key, lang)
    
    if not str then return key end
    
    -- Handle pluralization
    if args and args.count then
        if args.count ~= 1 then
            -- Use plural form if available
            local pluralKey = key .. "_plural"
            str = getStringRaw(pluralKey, lang) or str
        end
    end
    
    -- Replace parameters
    if args then
        for k, v in pairs(args) do
            str = str:gsub("%%{" .. k .. "}", v)
            str = str:gsub("%%" .. k, v)
        end
    end
    
    return str
end

-- Usage with parameters
print(getString("battle.unit_killed", nil, {killer = "Soldier", victim = "Alien"}))
-- Output: "Soldier killed Alien" or "Soldado mató a Alien"

-- Usage with pluralization
print(getString("items.ammo", nil, {count = 5}))
-- Uses "ammo_plural" form for languages that need it
```

---

## Locale-Specific Content

### ✅ DO: Handle Regional Formatting

```lua
-- dates, times, numbers vary by locale
LOCALE_FORMATS = {
    en = {
        date = "MM/DD/YYYY",      -- American
        time = "12-hour",
        decimal = ".",
        thousands = ","
    },
    es = {
        date = "DD/MM/YYYY",      -- European
        time = "24-hour",
        decimal = ",",
        thousands = "."
    },
    ja = {
        date = "YYYY/MM/DD",      -- Japanese
        time = "24-hour",
        decimal = ".",
        thousands = ","
    }
}

function formatNumber(value, decimals)
    local locale = LOCALE_FORMATS[LOCALIZATION.current_language]
    local format = "%." .. (decimals or 0) .. "f"
    local str = string.format(format, value)
    
    -- Replace decimal separator
    str = str:gsub("%.", locale.decimal)
    
    -- Add thousands separator
    str = str:gsub("(%d)(%d%d%d)", "%1" .. locale.thousands .. "%2")
    
    return str
end

function formatDate(timestamp)
    local locale = LOCALE_FORMATS[LOCALIZATION.current_language]
    local date = os.date("*t", timestamp)
    
    if locale.date == "MM/DD/YYYY" then
        return date.month .. "/" .. date.day .. "/" .. date.year
    elseif locale.date == "DD/MM/YYYY" then
        return date.day .. "/" .. date.month .. "/" .. date.year
    elseif locale.date == "YYYY/MM/DD" then
        return date.year .. "/" .. date.month .. "/" .. date.day
    end
end
```

---

## Practical Implementation

### ✅ DO: Manage String Files Externally

```lua
-- Create separate files for each language
-- localization/en.lua
return {
    ui = {
        main_menu = "Main Menu",
        new_game = "New Game"
    }
}

-- localization/es.lua
return {
    ui = {
        main_menu = "Menú Principal",
        new_game = "Nuevo Juego"
    }
}

-- Load dynamically
function loadLanguage(lang)
    local path = "localization/" .. lang .. ".lua"
    if love.filesystem.getInfo(path) then
        return require("localization." .. lang)
    end
    return require("localization.en")  -- Fallback to English
end
```

---

### ✅ DO: Support Text Direction (RTL)

```lua
LANGUAGE_PROPERTIES = {
    en = {text_direction = "LTR", font_family = "Arial"},
    ar = {text_direction = "RTL", font_family = "Arial"},
    he = {text_direction = "RTL", font_family = "Arial"},
    ja = {text_direction = "LTR", font_family = "NotoSans"}
}

function drawText(text, x, y)
    local direction = LANGUAGE_PROPERTIES[LOCALIZATION.current_language].text_direction
    
    if direction == "RTL" then
        -- Right-align text
        love.graphics.printf(text, x - love.graphics.getFont():getWidth(text), y, x, "left")
    else
        -- Left-align text
        love.graphics.print(text, x, y)
    end
end
```

---

### ✅ DO: Validate Translations

```lua
function validateTranslations()
    local englishStrings = loadLanguage("en")
    local languages = {"es", "fr", "de", "ja"}
    
    for _, lang in ipairs(languages) do
        local translatedStrings = loadLanguage(lang)
        
        -- Check all English keys are translated
        validateLanguageCompleteness(englishStrings, translatedStrings, lang)
    end
end

function validateLanguageCompleteness(english, translated, lang)
    local missingKeys = {}
    
    for key, value in pairs(english) do
        if not translated[key] then
            table.insert(missingKeys, key)
        elseif type(value) == "table" then
            validateLanguageCompleteness(value, translated[key], lang)
        end
    end
    
    if #missingKeys > 0 then
        print("[LOCALIZATION] Missing keys in " .. lang .. ": " .. table.concat(missingKeys, ", "))
    end
end
```

---

### ❌ DON'T: Hardcode Strings

```lua
-- BAD: Hardcoded strings
function renderMainMenu()
    love.graphics.print("Main Menu", 100, 50)
    drawButton("New Game", 100, 100)
    drawButton("Settings", 100, 150)
end

-- GOOD: Use localization system
function renderMainMenu()
    love.graphics.print(getString("ui.main_menu"), 100, 50)
    drawButton(getString("ui.new_game"), 100, 100)
    drawButton(getString("ui.settings"), 100, 150)
end
```

---

### ❌ DON'T: Ignore Text Width Variations

```lua
-- BAD: Fixed width UI
function drawButtonBad(text)
    love.graphics.rectangle("fill", 100, 100, 100, 40)
    love.graphics.print(text, 120, 115)
end

-- GOOD: Dynamic width
function drawButtonGood(text)
    local textWidth = love.graphics.getFont():getWidth(text)
    local buttonWidth = textWidth + 40
    
    love.graphics.rectangle("fill", 100, 100, buttonWidth, 40)
    love.graphics.print(text, 120, 115)
end
```

---

## Common Patterns & Checklist

- [x] Use string key system (ui.main_menu, etc.)
- [x] Externalize all text to language files
- [x] Support parameter substitution
- [x] Handle pluralization rules
- [x] Format numbers/dates per locale
- [x] Support RTL languages
- [x] Use dynamic text layout
- [x] Validate translation completeness
- [x] Test with all supported languages
- [x] Document translation guidelines

---

## References

- Unicode Standard: https://unicode.org/
- Language Tags: https://tools.ietf.org/html/bcp47
- Crowdin: https://crowdin.com/ (translation platform)

