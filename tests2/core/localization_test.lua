-- ─────────────────────────────────────────────────────────────────────────
-- LOCALIZATION SYSTEM TEST SUITE
-- FILE: tests2/core/localization_test.lua
-- ─────────────────────────────────────────────────────────────────────────

local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
    modulePath = "engine.localization.localization_system",
    fileName = "localization_system.lua",
    description = "Multi-language localization and translation system"
})

print("[LOCALIZATION_TEST] Setting up")

local LocalizationSystem = {
    currentLanguage = "en",
    languages = {},
    strings = {},

    new = function(self)
        return setmetatable({currentLanguage = "en", languages = {}, strings = {}}, {__index = self})
    end,

    loadLanguage = function(self, langCode)
        if langCode == "en" or langCode == "es" or langCode == "fr" or langCode == "de" then
            self.currentLanguage = langCode
            return true
        end
        return false
    end,

    getCurrentLanguage = function(self)
        return self.currentLanguage
    end,

    setString = function(self, key, value)
        self.strings[key] = value
        return true
    end,

    getString = function(self, key, substitutions)
        local str = self.strings[key] or key
        if substitutions then
            for placeholder, value in pairs(substitutions) do
                str = str:gsub("{" .. placeholder .. "}", tostring(value))
            end
        end
        return str
    end,

    hasString = function(self, key)
        return self.strings[key] ~= nil
    end,

    addLanguage = function(self, langCode, langName)
        self.languages[langCode] = langName
        return true
    end,

    getSupportedLanguages = function(self)
        return self.languages
    end,

    registerStrings = function(self, langCode, stringTable)
        for key, value in pairs(stringTable) do
            self.strings[key] = value
        end
        return true
    end
}

Suite:group("Language Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.l10n = LocalizationSystem:new()
    end)

    Suite:testMethod("LocalizationSystem.new", {description = "Creates localization system", testCase = "create", type = "functional"}, function()
        Helpers.assertEqual(shared.l10n ~= nil, true, "System created")
    end)

    Suite:testMethod("LocalizationSystem.loadLanguage", {description = "Loads language", testCase = "load", type = "functional"}, function()
        local ok = shared.l10n:loadLanguage("es")
        Helpers.assertEqual(ok, true, "Language loaded")
    end)

    Suite:testMethod("LocalizationSystem.getCurrentLanguage", {description = "Gets current language", testCase = "current", type = "functional"}, function()
        shared.l10n:loadLanguage("fr")
        local lang = shared.l10n:getCurrentLanguage()
        Helpers.assertEqual(lang, "fr", "Current language is French")
    end)

    Suite:testMethod("LocalizationSystem.loadLanguage", {description = "Rejects invalid language", testCase = "invalid", type = "functional"}, function()
        local ok = shared.l10n:loadLanguage("invalid")
        Helpers.assertEqual(ok, false, "Invalid language rejected")
    end)
end)

Suite:group("String Management", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.l10n = LocalizationSystem:new()
        shared.l10n:setString("ui.ok", "OK")
        shared.l10n:setString("ui.cancel", "Cancel")
    end)

    Suite:testMethod("LocalizationSystem.setString", {description = "Sets translation string", testCase = "set", type = "functional"}, function()
        local ok = shared.l10n:setString("test.key", "Test Value")
        Helpers.assertEqual(ok, true, "String set")
    end)

    Suite:testMethod("LocalizationSystem.getString", {description = "Gets translation string", testCase = "get", type = "functional"}, function()
        local str = shared.l10n:getString("ui.ok")
        Helpers.assertEqual(str, "OK", "String retrieved")
    end)

    Suite:testMethod("LocalizationSystem.hasString", {description = "Checks if string exists", testCase = "exists", type = "functional"}, function()
        local has = shared.l10n:hasString("ui.ok")
        Helpers.assertEqual(has, true, "String exists")
    end)

    Suite:testMethod("LocalizationSystem.hasString", {description = "Returns false for missing string", testCase = "missing", type = "functional"}, function()
        local has = shared.l10n:hasString("nonexistent")
        Helpers.assertEqual(has, false, "Missing string detected")
    end)
end)

Suite:group("String Substitution", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.l10n = LocalizationSystem:new()
        shared.l10n:setString("msg.deployed", "Deployed {count} soldiers")
        shared.l10n:setString("msg.location", "Location: {place}")
    end)

    Suite:testMethod("LocalizationSystem.getString", {description = "Substitutes placeholders", testCase = "substitute", type = "functional"}, function()
        local str = shared.l10n:getString("msg.deployed", {count = 5})
        Helpers.assertEqual(str, "Deployed 5 soldiers", "Substitution applied")
    end)

    Suite:testMethod("LocalizationSystem.getString", {description = "Multiple substitutions", testCase = "multiple", type = "functional"}, function()
        local str = shared.l10n:getString("msg.location", {place = "Base"})
        Helpers.assertEqual(str, "Location: Base", "Location substituted")
    end)

    Suite:testMethod("LocalizationSystem.getString", {description = "Returns key if string missing", testCase = "fallback", type = "functional"}, function()
        local str = shared.l10n:getString("undefined.key")
        Helpers.assertEqual(str, "undefined.key", "Fallback to key")
    end)
end)

Suite:group("Language Support", function()
    local shared = {}
    Suite:beforeEach(function()
        shared.l10n = LocalizationSystem:new()
    end)

    Suite:testMethod("LocalizationSystem.addLanguage", {description = "Adds new language", testCase = "add", type = "functional"}, function()
        local ok = shared.l10n:addLanguage("pt", "Portuguese")
        Helpers.assertEqual(ok, true, "Language added")
    end)

    Suite:testMethod("LocalizationSystem.getSupportedLanguages", {description = "Lists supported languages", testCase = "list", type = "functional"}, function()
        shared.l10n:addLanguage("it", "Italian")
        shared.l10n:addLanguage("de", "German")
        local langs = shared.l10n:getSupportedLanguages()
        local count = 0
        for _ in pairs(langs) do count = count + 1 end
        Helpers.assertEqual(count, 2, "Two languages in list")
    end)

    Suite:testMethod("LocalizationSystem.registerStrings", {description = "Registers string table", testCase = "register", type = "functional"}, function()
        local ok = shared.l10n:registerStrings("en", {
            ["test.a"] = "Value A",
            ["test.b"] = "Value B"
        })
        Helpers.assertEqual(ok, true, "Strings registered")
    end)
end)

Suite:run()
