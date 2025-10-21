--- Localization System - Multi-language support
---
--- Manages translation strings, language switching, and localization features.
--- Supports multiple languages with fallback to default (English), string
--- substitution, and cultural formatting.
---
--- Supported Languages:
--- - en: English (default)
--- - es: Spanish
--- - fr: French
--- - de: German
--- - ru: Russian
--- - zh: Chinese (Simplified)
--- - ja: Japanese
--- - pt: Portuguese
--- - it: Italian
--- - pl: Polish
---
--- Usage:
---   local Localization = require("engine.localization.localization_system")
---   local i18n = Localization:new()
---   i18n:loadLanguage("en")
---   local text = i18n:getString("ui.buttons.ok")
---   local formatted = i18n:getString("game.messages.units_deployed", {count = 5})
---
--- String Key Format:
---   "category.subcategory.key" (e.g., "ui.buttons.ok", "game.messages.error")
---
--- String Substitution:
---   Keys in strings: {placeholder}
---   Example: "Deployed {count} soldiers"
---   Call: i18n:getString(key, {count = 5})
---   Result: "Deployed 5 soldiers"
---
--- @module engine.localization.localization_system
--- @author AlienFall Development Team

local Localization = {}
Localization.__index = Localization

-- Supported languages
local SUPPORTED_LANGUAGES = {
    en = "English",
    es = "Español",
    fr = "Français",
    de = "Deutsch",
    ru = "Русский",
    zh = "中文",
    ja = "日本語",
    pt = "Português",
    it = "Italiano",
    pl = "Polski"
}

--- Initialize Localization System
---@param defaultLanguage string? Default language code (default: "en")
---@return table Localization instance
function Localization:new(defaultLanguage)
    local self = setmetatable({}, Localization)
    
    self.defaultLanguage = defaultLanguage or "en"
    self.currentLanguage = self.defaultLanguage
    self.strings = {}  -- {language = {keys and strings}}
    self.loadedLanguages = {}
    
    print("[Localization] Initialized with default language: " .. self.defaultLanguage)
    
    return self
end

--- Load language from TOML file
---@param languageCode string Language code (e.g., "en", "es")
---@return boolean Success
function Localization:loadLanguage(languageCode)
    if not SUPPORTED_LANGUAGES[languageCode] then
        print("[Localization] ERROR: Unsupported language: " .. languageCode)
        return false
    end
    
    -- Try to load from mods/core/localization/languages/
    local filePath = "mods/core/localization/languages/" .. languageCode .. ".toml"
    
    -- Check if file exists
    local file = io.open(filePath, "r")
    if not file then
        print("[Localization] WARNING: Language file not found: " .. filePath)
        if languageCode ~= self.defaultLanguage then
            print("[Localization] Falling back to default language")
            return false
        end
    else
        file:close()
    end
    
    -- For now, initialize with empty table (would load TOML in real implementation)
    self.strings[languageCode] = {}
    self.loadedLanguages[languageCode] = true
    
    print("[Localization] Loaded language: " .. SUPPORTED_LANGUAGES[languageCode])
    
    return true
end

--- Set current language
---@param languageCode string Language code
---@return boolean Success
function Localization:setLanguage(languageCode)
    if not SUPPORTED_LANGUAGES[languageCode] then
        print("[Localization] ERROR: Unsupported language: " .. languageCode)
        return false
    end
    
    -- Load language if not already loaded
    if not self.loadedLanguages[languageCode] then
        if not self:loadLanguage(languageCode) then
            print("[Localization] Could not load language, using default")
            languageCode = self.defaultLanguage
        end
    end
    
    self.currentLanguage = languageCode
    print("[Localization] Language switched to: " .. SUPPORTED_LANGUAGES[languageCode])
    
    return true
end

--- Get translated string
---@param key string String key (e.g., "ui.buttons.ok")
---@param params table? Parameters for substitution (e.g., {count = 5})
---@return string Translated string (or key if not found)
function Localization:getString(key, params)
    -- Try to get from current language
    local text = self:getStringFromLanguage(key, self.currentLanguage)
    
    -- Fall back to default language if not found
    if not text and self.currentLanguage ~= self.defaultLanguage then
        text = self:getStringFromLanguage(key, self.defaultLanguage)
    end
    
    -- If still not found, return key
    if not text then
        print(string.format("[Localization] WARNING: String not found: %s (%s)",
            key, self.currentLanguage))
        text = key
    end
    
    -- Perform parameter substitution
    if params then
        text = self:substituteParameters(text, params)
    end
    
    return text
end

--- Get string from specific language
---@param key string String key
---@param language string Language code
---@return string? Translated string or nil
function Localization:getStringFromLanguage(key, language)
    if not self.strings[language] then
        return nil
    end
    
    -- Split key into parts (e.g., "ui.buttons.ok" -> ["ui", "buttons", "ok"])
    local parts = {}
    for part in key:gmatch("[^.]+") do
        table.insert(parts, part)
    end
    
    -- Navigate through nested tables
    local current = self.strings[language]
    for _, part in ipairs(parts) do
        current = current[part]
        if not current then
            return nil
        end
    end
    
    if type(current) == "string" then
        return current
    end
    
    return nil
end

--- Substitute parameters in string
---@param text string Text with {placeholders}
---@param params table Parameters {key = value, ...}
---@return string Substituted text
function Localization:substituteParameters(text, params)
    for key, value in pairs(params) do
        local placeholder = "{" .. key .. "}"
        text = text:gsub(placeholder, tostring(value))
    end
    return text
end

--- Format number according to current language
---@param number number Number to format
---@return string Formatted number
function Localization:formatNumber(number)
    -- Different languages use different number formats
    -- Example: 1000000 -> "1,000,000" (en) or "1.000.000" (de)
    
    local formatted = tostring(math.floor(number))
    
    if self.currentLanguage == "de" or self.currentLanguage == "fr" then
        -- European format with dots for thousands
        local result = formatted:reverse():gsub("(%d%d%d)", "%1."):reverse()
        result = result:gsub("^%.", "")
        return result
    else
        -- English format with commas
        local result = formatted:reverse():gsub("(%d%d%d)", "%1,"):reverse()
        result = result:gsub("^,", "")
        return result
    end
end

--- Format date according to current language
---@param day number Day
---@param month number Month
---@param year number Year
---@return string Formatted date
function Localization:formatDate(day, month, year)
    if self.currentLanguage == "en" then
        return string.format("%d/%d/%d", month, day, year)  -- MM/DD/YYYY
    else
        return string.format("%d/%d/%d", day, month, year)  -- DD/MM/YYYY
    end
end

--- Add or override string in current language
---@param key string String key
---@param value string String value
function Localization:setString(key, value)
    if not self.strings[self.currentLanguage] then
        self.strings[self.currentLanguage] = {}
    end
    
    -- Navigate and create nested tables as needed
    local parts = {}
    for part in key:gmatch("[^.]+") do
        table.insert(parts, part)
    end
    
    local current = self.strings[self.currentLanguage]
    for i = 1, #parts - 1 do
        local part = parts[i]
        if not current[part] then
            current[part] = {}
        end
        current = current[part]
    end
    
    current[parts[#parts]] = value
end

--- Get current language code
---@return string Language code
function Localization:getCurrentLanguage()
    return self.currentLanguage
end

--- Get current language name
---@return string Language name
function Localization:getCurrentLanguageName()
    return SUPPORTED_LANGUAGES[self.currentLanguage] or self.currentLanguage
end

--- Get list of supported languages
---@return table {code = name, ...}
function Localization:getSupportedLanguages()
    return SUPPORTED_LANGUAGES
end

--- Get list of loaded languages
---@return table List of loaded language codes
function Localization:getLoadedLanguages()
    local loaded = {}
    for lang, _ in pairs(self.loadedLanguages) do
        table.insert(loaded, lang)
    end
    return loaded
end

--- Get localization status
---@return string Status report
function Localization:getStatus()
    local status = string.format(
        "Localization Status:\n" ..
        "  Current Language: %s (%s)\n" ..
        "  Default Language: %s\n" ..
        "  Loaded Languages: %d\n" ..
        "  Total Supported: %d",
        self.currentLanguage,
        SUPPORTED_LANGUAGES[self.currentLanguage],
        self.defaultLanguage,
        #self:getLoadedLanguages(),
        self:countSupportedLanguages()
    )
    
    return status
end

--- Count supported languages
---@return number Count
function Localization:countSupportedLanguages()
    local count = 0
    for _ in pairs(SUPPORTED_LANGUAGES) do
        count = count + 1
    end
    return count
end

--- Serialize for save/load
---@return table Serialized data
function Localization:serialize()
    return {
        currentLanguage = self.currentLanguage,
        defaultLanguage = self.defaultLanguage,
        loadedLanguages = self.loadedLanguages
    }
end

--- Deserialize from save/load
---@param data table Serialized data
function Localization:deserialize(data)
    self.currentLanguage = data.currentLanguage
    self.defaultLanguage = data.defaultLanguage
    self.loadedLanguages = data.loadedLanguages
    print("[Localization] Deserialized from save")
end

return Localization



