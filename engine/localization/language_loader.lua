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
        self.currentLanguage = languageCode
        -- TODO: Parse TOML file and load translations
        return true
    else
        print("[LanguageLoader] ERROR: Language file not found: " .. path)
        return false
    end
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

return LanguageLoader
