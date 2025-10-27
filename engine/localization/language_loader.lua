---Language Loader - Load and switch game languages
---
---Manages language files, translations, and language switching.
---Supports multiple languages and character encodings.
---
---@module language_loader
---@author AlienFall Development Team
---@license Open Source

local LanguageLoader = {}
LanguageLoader.__index = LanguageLoader

function LanguageLoader.new()
    local self = setmetatable({}, LanguageLoader)

    self.languages = {
        "en", "es", "fr", "de", "ja", "zh", "ru", "pt", "it", "ko"
    }
    self.currentLanguage = "en"
    self.translations = {}

    print("[LanguageLoader] Language loader initialized")
    return self
end

---Load a language file
---
---@param languageCode string Language code (e.g., "en", "es", "fr")
---@return boolean Success or failure
function LanguageLoader:loadLanguage(languageCode)
    local path = "localization/languages/" .. languageCode .. ".toml"

    if love.filesystem.getInfo(path) then
        print("[LanguageLoader] Loading language: " .. languageCode)

        -- Load TOML parser
        local TOML = require("engine.utils.toml")

        -- Parse TOML file and load translations
        local success, translations = pcall(function()
            return TOML.load(path)
        end)

        if success and translations then
            self.translations[languageCode] = translations
            self.currentLanguage = languageCode
            print(string.format("[LanguageLoader] Successfully loaded %d translation keys for %s",
                self:_countKeys(translations), languageCode))
            return true
        else
            print("[LanguageLoader] ERROR: Failed to parse TOML file: " .. path)
            if translations then
                print("[LanguageLoader] Parse error: " .. tostring(translations))
            end
            return false
        end
    else
        print("[LanguageLoader] ERROR: Language file not found: " .. path)
        return false
    end
end

---Count total translation keys (internal helper)
---
---@param tbl table Table to count keys from
---@param count number? Running count (for recursion)
---@return number Total key count
function LanguageLoader:_countKeys(tbl, count)
    count = count or 0
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            count = self:_countKeys(v, count)
        else
            count = count + 1
        end
    end
    return count
end

---Get available languages
---
---@return table Array of language codes
function LanguageLoader:getAvailableLanguages()
    return self.languages
end

---Get current language
---
---@return string Current language code
function LanguageLoader:getCurrentLanguage()
    return self.currentLanguage
end

---Switch to a language
---
---@param languageCode string Language code to switch to
---@return boolean Success or failure
function LanguageLoader:switchLanguage(languageCode)
    if table.concat(self.languages, ","):find(languageCode) then
        return self:loadLanguage(languageCode)
    else
        print("[LanguageLoader] ERROR: Unsupported language: " .. languageCode)
        return false
    end
end

---Get translation by key
---
---@param key string Translation key (e.g., "ui.buttons.ok" or "game.messages.error")
---@param languageCode string? Language code (defaults to current language)
---@return string? Translation string or nil if not found
function LanguageLoader:getTranslation(key, languageCode)
    languageCode = languageCode or self.currentLanguage

    local translations = self.translations[languageCode]
    if not translations then
        print(string.format("[LanguageLoader] WARNING: No translations loaded for language: %s", languageCode))
        return nil
    end

    -- Split key by dots for nested access
    local parts = {}
    for part in key:gmatch("[^%.]+") do
        table.insert(parts, part)
    end

    -- Navigate nested table
    local value = translations
    for _, part in ipairs(parts) do
        if type(value) ~= "table" then
            return nil
        end
        value = value[part]
        if not value then
            return nil
        end
    end

    return value
end

---Check if translation exists
---
---@param key string Translation key
---@param languageCode string? Language code (defaults to current language)
---@return boolean True if translation exists
function LanguageLoader:hasTranslation(key, languageCode)
    return self:getTranslation(key, languageCode) ~= nil
end

return LanguageLoader

