# Localization & Internationalization (i18n)# Localization System (Future Feature)



**Status:** Core Implementation Complete  **Status:** Placeholder - Not Yet Implemented  

**Priority:** Medium  **Priority:** Medium  

**Version:** 1.0 (October 16, 2025)**Planned For:** Phase 4 Development



------



## Overview## Overview



Multi-language support system for AlienFall providing translation management, string substitution, cultural formatting, and dynamic language switching. Supports 10 languages with fallback to English.Multi-language support for international players.



------



## Implemented Features## Planned Features



### Localization System (`localization_system.lua`)### Supported Languages

- **Multiple Languages**: 10 supported languages (English, Spanish, French, German, Russian, Chinese, Japanese, Portuguese, Italian, Polish)- English (default)

- **String Management**: Hierarchical key-based string access (e.g., "ui.buttons.ok")- Spanish

- **Parameter Substitution**: Dynamic string values with {placeholder} replacement- French

- **Language Switching**: Runtime language switching with fallback handling- German

- **Format Localization**: Number and date formatting by language- Russian

- **Fallback System**: Automatic fallback to English if translation missing- Chinese (Simplified)

- **String Override**: Runtime string modification and addition- Japanese

- Portuguese

---- Italian

- Polish

## API Reference

### Localization Features

### Localization System- String table system

- Dynamic text replacement

```lua- Locale-specific formatting (dates, numbers)

local Localization = require("engine.localization.localization_system")- Font support for non-Latin scripts

local i18n = Localization:new()- Audio localization (voiceovers)



-- Initialization & Language Management---

i18n:loadLanguage(languageCode)                -- Load language from file

i18n:setLanguage(languageCode)                 -- Switch current language## Implementation Plan

i18n:getCurrentLanguage()                      -- Get current language code

i18n:getCurrentLanguageName()                  -- Get current language name### Files to Create

i18n:getSupportedLanguages()                   -- Get all supported languages- `localization/i18n.lua` - Internationalization system

i18n:getLoadedLanguages()                      -- Get loaded languages- `localization/languages/en.lua` - English strings

- `localization/languages/es.lua` - Spanish strings

-- String Retrieval- `localization/languages/fr.lua` - French strings

i18n:getString(key)                            -- Get translated string- (etc.)

i18n:getString(key, params)                    -- Get string with parameters

i18n:getStringFromLanguage(key, language)      -- Get from specific language---

i18n:setString(key, value)                     -- Set string in current language

**Note:** This is a placeholder for future internationalization support.

-- Formatting
i18n:formatNumber(number)                      -- Format number by language
i18n:formatDate(day, month, year)              -- Format date by language

-- Queries
i18n:getStatus()                               -- Get localization status
i18n:countSupportedLanguages()                 -- Count supported languages
```

---

## Usage Examples

### Basic String Retrieval

```lua
local i18n = Localization:new()
i18n:loadLanguage("en")

-- Get simple string
local okText = i18n:getString("ui.buttons.ok")
print(okText)  -- "OK"

-- Get string with parameters
local message = i18n:getString("game.messages.units_deployed", {count = 5})
print(message)  -- "Deployed 5 soldiers"
```

### Language Switching

```lua
-- Switch to Spanish
i18n:setLanguage("es")
local okText = i18n:getString("ui.buttons.ok")  -- Spanish version

-- Switch to German
i18n:setLanguage("de")
local okText = i18n:getString("ui.buttons.ok")  -- German version

-- Get current language info
print(i18n:getCurrentLanguageName())  -- "Deutsch"
```

### Number & Date Formatting

```lua
-- Number formatting varies by language
i18n:setLanguage("en")
print(i18n:formatNumber(1000000))  -- "1,000,000"

i18n:setLanguage("de")
print(i18n:formatNumber(1000000))  -- "1.000.000"

-- Date formatting
i18n:setLanguage("en")
print(i18n:formatDate(15, 3, 2025))  -- "3/15/2025" (MM/DD/YYYY)

i18n:setLanguage("de")
print(i18n:formatDate(15, 3, 2025))  -- "15/3/2025" (DD/MM/YYYY)
```

### Parameter Substitution

```lua
-- String in language file: "Mission: {mission} | Soldiers: {count}"

local params = {
    mission = "Crash Site Recovery",
    count = 8
}

local text = i18n:getString("game.mission_briefing", params)
-- Result: "Mission: Crash Site Recovery | Soldiers: 8"
```

---

## Language Files (TOML Format)

Language files located in: `mods/core/localization/languages/`

### Example: en.toml

```toml
[ui.buttons]
ok = "OK"
cancel = "Cancel"
confirm = "Confirm"
back = "Back"

[ui.menus]
main_menu = "Main Menu"
new_game = "New Game"
load_game = "Load Game"
options = "Options"

[game.messages]
mission_start = "Mission begins!"
soldiers_deployed = "Soldiers deployed: {count}"
insufficient_funds = "Insufficient funds!"
unit_killed = "{unit_name} was killed in action"

[units.names]
soldier = "Soldier"
sniper = "Sniper"
heavy = "Heavy Weapons Specialist"
medic = "Medic"

[facilities.names]
headquarters = "Headquarters"
barracks = "Barracks"
laboratory = "Laboratory"
workshop = "Workshop"
```

### Example: es.toml (Spanish)

```toml
[ui.buttons]
ok = "Aceptar"
cancel = "Cancelar"
confirm = "Confirmar"
back = "Atrás"

[game.messages]
mission_start = "¡La misión comienza!"
soldiers_deployed = "Soldados desplegados: {count}"
```

---

## Supported Languages

| Code | Language | Native Name |
|------|----------|-------------|
| en | English | English |
| es | Spanish | Español |
| fr | French | Français |
| de | German | Deutsch |
| ru | Russian | Русский |
| zh | Chinese (Simplified) | 中文 |
| ja | Japanese | 日本語 |
| pt | Portuguese | Português |
| it | Italian | Italiano |
| pl | Polish | Polski |

---

## Key Naming Convention

String keys follow hierarchical naming:
- **Format**: `category.subcategory.key`
- **Examples**:
  - `ui.buttons.ok` - UI button "OK"
  - `game.messages.error` - Game error message
  - `units.names.soldier` - Unit type name
  - `missions.objectives.primary` - Mission objective text

---

## Integration Points

### UI Systems
```lua
-- Get translated UI text
local buttonText = i18n:getString("ui.buttons.ok")
local menuTitle = i18n:getString("ui.menus.main_menu")
```

### Game Messages
```lua
-- Get gameplay messages with parameters
local unitName = "John Smith"
local message = i18n:getString("game.messages.unit_killed", {unit_name = unitName})
```

### Content Names
```lua
-- Get unit/facility/item names translated
local unitType = i18n:getString("units.names.sniper")
local facilityName = i18n:getString("facilities.names.laboratory")
```

---

## Technical Details

### String Key Lookup
1. Check current language for key
2. If not found, check default language (English)
3. If still not found, return key itself (for debugging)
4. Apply parameter substitution if provided

### Language Loading
- Language files are TOML format
- Located in: `mods/core/localization/languages/`
- Loaded on demand when `loadLanguage()` called
- Cached after loading

### Number Formatting by Language
- **English (en)**: 1,000,000 (commas)
- **German (de)**: 1.000.000 (periods)
- **French (fr)**: 1.000.000 (periods)
- **Others (default)**: 1,000,000 (commas)

### Date Formatting by Language
- **English (en)**: MM/DD/YYYY
- **Others**: DD/MM/YYYY

---

## Performance

- **String Retrieval**: O(n) where n = depth of key hierarchy (typically 2-4)
- **Language Switching**: O(1)
- **Parameter Substitution**: O(m) where m = number of parameters
- **Number Formatting**: O(k) where k = number of digits

---

## Future Enhancements

- **Pluralization Rules**: "1 soldier" vs "5 soldiers"
- **Gender-Specific Text**: "He" vs "She" translations
- **Context-Specific Strings**: Same word, different contexts
- **Right-to-Left (RTL) Support**: Arabic, Hebrew support
- **Translation Hot-Loading**: Update translations without restart
- **Translation Coverage Report**: Show translation progress
- **Font Management**: Language-specific font selection
- **Text Expansion**: Account for text length variation between languages

---

## Files

- `localization_system.lua` - Core localization engine (380 lines)
- `README.md` - This documentation

---

## Related Documentation

- `docs/localization/README.md` - Game design documentation
- `mods/core/localization/` - Language file location
- `docs/modding/` - How to add localized content
