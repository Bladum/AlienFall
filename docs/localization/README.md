# Localization & Internationalization (i18n)

> **Implementation**: `../../../engine/localization/` (Future: Placeholder structure exists)
> **Configuration**: `mods/core/localization/`
> **Tests**: `../../../tests/` (localization tests)

The Localization System provides multi-language support for AlienFall, enabling gameplay in multiple languages with proper string management, cultural adaptation, and international character support.

---

## Overview

The localization system manages:
- **String Management**: Text storage and retrieval for UI and game content
- **Language Support**: Multiple languages with fallback to English
- **Cultural Adaptation**: Language-specific formatting and conventions
- **Character Support**: UTF-8 for international characters
- **Dynamic Translation**: Runtime string replacement
- **Translator Workflow**: Contributing translations

---

## Architecture

### Localization Structure

```
engine/localization/
├── README.md (status)
└── (Future implementation)

mods/core/localization/
├── README.md
├── languages/
│   ├── en.toml      (English - default)
│   ├── es.toml      (Spanish)
│   ├── fr.toml      (French)
│   ├── de.toml      (German)
│   ├── ru.toml      (Russian)
│   ├── zh.toml      (Chinese Simplified)
│   ├── ja.toml      (Japanese)
│   ├── pt.toml      (Portuguese)
│   ├── it.toml      (Italian)
│   └── pl.toml      (Polish)
└── localization.md  (translator guide)
```

### Language Files Format (TOML)

Each language uses TOML with hierarchical keys:

**Example: en.toml**
```toml
# UI General
[ui.main_menu]
title = "AlienFall"
new_game = "New Game"
load_game = "Load Game"
quit = "Quit Game"

[ui.buttons]
ok = "OK"
cancel = "Cancel"
confirm = "Confirm"
back = "Back"

# Game Strings
[game.messages]
mission_start = "Mission begins!"
soldiers_deployed = "Soldiers deployed: {count}"
insufficient_funds = "Insufficient funds!"

# Unit Names
[units.names]
soldier = "Soldier"
sniper = "Sniper"
heavy = "Heavy Weapons Specialist"

# Facility Names
[facilities.names]
headquarters = "Headquarters"
laboratory = "Laboratory"
workshop = "Workshop"
```

### Language System Architecture

```lua
-- Core Internationalization Module
LocalizationSystem = {
    currentLanguage = "en",
    languages = {},
    strings = {},
    fallback = "en"
}

-- Get translated string
function LocalizationSystem:getString(key, params)
    -- key format: "ui.buttons.ok"
    -- params for substitution: {count = 5}
    -- Returns: translated string with substitutions
end

-- Set active language
function LocalizationSystem:setLanguage(languageCode)
    -- Load language file
    -- Update all UI strings
end

-- Get all available languages
function LocalizationSystem:getAvailableLanguages()
    -- Returns: list of language codes
end
```

---

## Supported Languages

### Primary Languages

| Language | Code | Status | Coverage |
|----------|------|--------|----------|
| English | en | Core | 100% |
| Spanish | es | Planned | - |
| French | fr | Planned | - |
| German | de | Planned | - |
| Russian | ru | Planned | - |
| Chinese (Simplified) | zh | Planned | - |
| Japanese | ja | Planned | - |
| Portuguese | pt | Planned | - |
| Italian | it | Planned | - |
| Polish | pl | Planned | - |

### Language Codes
- Uses standard ISO 639-1 language codes (2 letters)
- Examples: en, es, fr, de, ja, zh, ru

---

## String Management

### String Key Hierarchy

Strings are organized in hierarchical keys for organization:

```
[section.subsection.key]
string_value = "The actual text"
```

**Sections:**
- `ui.*` - User interface strings
- `game.*` - Gameplay messages
- `units.*` - Unit/soldier names and descriptions
- `facilities.*` - Facility names and descriptions
- `items.*` - Equipment and item names
- `weapons.*` - Weapon names and descriptions
- `missions.*` - Mission names and objectives
- `campaigns.*` - Campaign names and lore
- `errors.*` - Error messages
- `tooltips.*` - Helpful hints and explanations

### String Categories

#### UI Strings
- Menu buttons and labels
- Dialog boxes and confirmations
- Status displays
- Navigation text

#### Game Messages
- Mission start/end
- Combat notifications
- Resource changes
- Status updates

#### Content Names
- Units and soldiers
- Facilities and buildings
- Equipment and weapons
- Missions and campaigns

---

## Variable Substitution

### Parameter Substitution

Strings can include placeholders for dynamic values:

**Template:**
```toml
mission_complete_with_reward = "Mission complete! Earned {reward} credits and {experience} XP."
soldiers_deployed = "{count} soldiers deployed to {location}."
```

**Usage in Code:**
```lua
local str = i18n:getString("game.messages.mission_complete_with_reward", {
    reward = 5000,
    experience = 250
})
-- Result: "Mission complete! Earned 5000 credits and 250 XP."
```

### Plural Forms

Some languages require different forms based on quantity:

**English Simple:**
```toml
[game.messages]
one_soldier = "1 soldier"
many_soldiers = "{count} soldiers"
```

**Usage:**
```lua
local count = 5
local key = (count == 1) and "one_soldier" or "many_soldiers"
local str = i18n:getString(key, {count = count})
```

---

## Formatting Standards

### Date/Time Formatting

Different locales have different date conventions:

**English:** MM/DD/YYYY  
**European:** DD/MM/YYYY  
**ISO:** YYYY-MM-DD

**Implementation:**
```lua
function i18n:formatDate(date)
    -- date format varies by language
    -- Returns: locale-specific date string
end

function i18n:formatNumber(num)
    -- thousands separator varies
    -- en: 1,000,000 | fr: 1 000 000 | de: 1.000.000
end
```

### Number Formatting

Thousands separators and decimal points vary:

| Language | Format |
|----------|--------|
| English | 1,000.50 (comma separator, period decimal) |
| French | 1 000,50 (space separator, comma decimal) |
| German | 1.000,50 (period separator, comma decimal) |
| Russian | 1 000,50 (space separator, comma decimal) |

---

## Translation Workflow

### For Translators

#### Step 1: Get Base English File
```
mods/core/localization/languages/en.toml
```

This contains all English strings that need translation.

#### Step 2: Create Translation File
```
mods/core/localization/languages/[LANG_CODE].toml
```

Copy the English file and replace strings with translations:

**Template:**
```toml
# Copy the structure from en.toml
[ui.main_menu]
title = "AlienFall"  # TRANSLATE THIS
new_game = "New Game"  # TRANSLATE THIS

# Keep structure identical, only change values
```

#### Step 3: Translation Guidelines

**Quality Standards:**
- Maintain consistent terminology across translations
- Preserve meaning and intent, not word-for-word translation
- Adapt cultural references appropriately
- Keep string length reasonable (UI space constraints)
- Follow language conventions and grammar rules
- Check for placeholders ({variable} format)

**Common Issues to Avoid:**
- ❌ Literal translation losing meaning
- ❌ Strings too long for UI elements
- ❌ Inconsistent terminology
- ❌ Missing placeholders or wrong formatting
- ❌ Untranslated developer comments

#### Step 4: Testing

Test translations in-game:
1. Place `.toml` file in `mods/core/localization/languages/`
2. Launch game and select language
3. Verify strings display correctly:
   - No overlapping text
   - Characters render properly
   - Placeholders substitute correctly
4. Check for untranslated strings (fallback to English)

#### Step 5: Submit Translation

Contributions welcome! Submit:
- Language file (`[lang_code].toml`)
- Any special font requirements
- Notes on cultural adaptations
- Testing verification

### For Developers

#### Adding New Strings

When adding new features:

1. **Add to English file first:**
```toml
[section.subsection]
new_feature_name = "New Feature Text"
```

2. **Update all language files** with placeholders:
```toml
[section.subsection]
new_feature_name = "[TRANSLATE] New Feature Text"
```

3. **Document the string** for translators

4. **Use in code:**
```lua
local text = i18n:getString("section.subsection.new_feature_name")
```

#### Code Integration

**In UI Elements:**
```lua
-- Before (hardcoded)
local button = Button.new({text = "Start Mission"})

-- After (localized)
local button = Button.new({text = i18n:getString("ui.buttons.start_mission")})
```

**In Game Logic:**
```lua
-- Display localized message
print(i18n:getString("game.messages.mission_start"))

-- With parameters
print(i18n:getString("game.messages.soldiers_deployed", {count = 12}))
```

---

## Character Set Support

### UTF-8 Encoding

All language files use UTF-8 encoding for international character support:

**File Header (for editors):**
```
# UTF-8 encoded
```

**Supported Characters:**
- Latin alphabet (a-z, A-Z)
- Diacritics (á, é, ñ, ü, etc.)
- Cyrillic (а-я, А-Я)
- CJK (Chinese, Japanese, Korean characters)
- Greek, Arabic, etc.

### Font Support

Different languages may require different fonts:

**Latin-based:** Standard fonts work
**Cyrillic:** Needs Cyrillic font support
**CJK:** Needs large character set font
**RTL:** Right-to-left support (Arabic, Hebrew)

---

## Pluralization & Gender

### Plural Forms

English has simple plural logic, but other languages vary:

**English:** singular vs plural (1 vs many)

**Russian:** singular, 2-4, 5+ forms

**French:** mostly singular vs plural

**Handling:**
```lua
function i18n:getPluralKey(count, baseKey)
    if language == "ru" then
        if count % 10 == 1 and count % 100 ~= 11 then
            return baseKey .. "_1"
        elseif count % 10 >= 2 and count % 10 <= 4 then
            return baseKey .. "_2_4"
        else
            return baseKey .. "_5plus"
        end
    else
        return (count == 1) and baseKey .. "_1" or baseKey .. "_many"
    end
end
```

### Gender-Specific Text

Some languages require gender agreement:

```toml
[game.messages]
soldier_selected_male = "Selected soldier"
soldier_selected_female = "Selected soldier (female)"  # if applicable
```

---

## Quality Assurance

### Translation Testing

**Checklist:**
- [ ] All strings visible without overlap
- [ ] Characters render correctly (no "????")
- [ ] Placeholders substitute properly
- [ ] Numbers and dates format correctly
- [ ] Grammar and spelling correct
- [ ] Terminology consistent
- [ ] Cultural references appropriate
- [ ] Text length reasonable for UI

### Automated Validation

**Checks:**
- String count matches English
- No missing placeholders
- Valid TOML syntax
- Valid UTF-8 encoding
- Placeholder variable names match English

**Example Validation:**
```bash
./validate_translation.lua mods/core/localization/languages/fr.toml
# Output: 5 warnings, 0 errors
```

---

## Language Selection

### Runtime Language Switching

```lua
-- Get current language
local current = i18n:getCurrentLanguage()  -- "en"

-- Get available languages
local available = i18n:getAvailableLanguages()  -- {"en", "es", "fr", ...}

-- Change language
i18n:setLanguage("es")  -- Switch to Spanish

-- All UI text updates automatically
```

### Settings Persistence

Language selection stored in player settings:
```
config/user_settings.toml
[localization]
language = "es"
```

---

## Integration Points

### UI System Integration
- All UI text uses localization system
- Runtime string updates on language change
- Automatic layout adjustments for text length

### Game Logic Integration
- Mission descriptions localized
- Narrative hooks use localized text
- Combat messages localized
- Notifications localized

### Content Modding
- Mods can include translations
- Community translations supported
- Easy to extend with new languages

---

## Creating Translations

### Translator Contribution Template

When creating a new translation:

1. **Language Code:** es (Spanish)
2. **File:** `mods/core/localization/languages/es.toml`
3. **Completeness:** 100% of keys translated
4. **Verification:** Tested in-game

**TOML Template:**
```toml
# AlienFall Spanish Translation (Español)
# Translator: [Your Name]
# Date: 2025-10-16
# Status: Complete / In Progress

[ui.main_menu]
title = "AlienFall"
new_game = "Nuevo Juego"
load_game = "Cargar Juego"
quit = "Salir"

# ... (all sections translated)
```

---

## Known Limitations & Future

### Current Limitations
- Localization system is planned (not yet implemented)
- Engine currently hardcoded to English
- No RTL (right-to-left) support for Arabic/Hebrew
- Limited font support for CJK languages

### Future Enhancements
- [ ] Full localization engine implementation
- [ ] Dynamic language switching
- [ ] Community translation portal
- [ ] Professional translator support
- [ ] Audio localization (voiceovers)
- [ ] Font fallback system
- [ ] RTL language support
- [ ] Keyboard layout support

---

## Modding Localization

### Adding Localization to Mods

Mods can include their own localized strings:

**Mod Structure:**
```
mods/my_mod/
├── localization/
│   ├── en.toml
│   ├── es.toml
│   └── fr.toml
└── content/
```

**Loading in Mod:**
```lua
local modI18n = i18n:loadModTranslations("my_mod")
local text = modI18n:getString("my_mod.some_key")
```

---

## See Also

- `docs/localization/translator_guide.md` - Detailed translator instructions
- `docs/modding/localization.md` - Modding localization support
- `mods/core/localization/languages/en.toml` - English base translation
- `wiki/API.md` - Localization API reference

---

## Contact & Support

For translation questions:
- GitHub Issues: Use `localization` label
- Community Forum: Translation section
- Email: (contact info)

**Thank you to all translators contributing to AlienFall!**
