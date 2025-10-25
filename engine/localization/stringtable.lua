---String Table - String translation management
---
---Manages all game strings and their translations. Provides centralized
---string lookup with fallback to default language if translation missing.
---
---@module stringtable
---@author AlienFall Development Team
---@license Open Source

local StringTable = {}
StringTable.__index = StringTable

function StringTable.new()
    local self = setmetatable({}, StringTable)

    self.strings = {}
    self.currentLanguage = "en"
    self.defaultLanguage = "en"

    print("[StringTable] String table initialized")
    return self
end

---Register a string entry
---
---@param key string String identifier
---@param defaultText string Default English text
function StringTable:registerString(key, defaultText)
    self.strings[key] = {
        [self.defaultLanguage] = defaultText,
    }
end

---Get a translated string
---
---@param key string String identifier
---@return string The translated string, or key if not found
function StringTable:get(key)
    if self.strings[key] then
        if self.strings[key][self.currentLanguage] then
            return self.strings[key][self.currentLanguage]
        elseif self.strings[key][self.defaultLanguage] then
            return self.strings[key][self.defaultLanguage]
        end
    end
    return key
end

---Set translation for a string
---
---@param key string String identifier
---@param language string Language code
---@param translation string Translated text
function StringTable:setTranslation(key, language, translation)
    if not self.strings[key] then
        self.strings[key] = {}
    end
    self.strings[key][language] = translation
end

---Set current language
---
---@param language string Language code
function StringTable:setLanguage(language)
    self.currentLanguage = language
    print("[StringTable] Language set to: " .. language)
end

return StringTable
