# Mod Structure Improvement Plan
**Actionable Plan for Restructuring Mod System**

**Date:** 2025-10-27  
**Status:** Implementation Ready  
**Priority:** HIGH

---

## Executive Summary

Based on REST API best practices analysis, this document provides a **concrete action plan** to restructure the mod system for better maintainability, validation, and developer experience.

---

## Problem Statement

### Current Issues

```
mods/core/
├── mod.toml                    ❌ Minimal metadata
├── rules/                      ⚠️ Inconsistent organization
│   ├── units/                  ✅ OK
│   │   └── soldiers.toml       ❌ No validation metadata
│   ├── items/                  ✅ OK
│   │   └── weapons.toml        ❌ No validation metadata
│   ├── battle/                 ⚠️ Different naming
│   │   └── terrain.toml        ❌ No validation metadata
│   └── unit/                   ⚠️ Singular vs plural inconsistency
│       └── perks.toml          ❌ No validation metadata
└── assets/                     ✅ OK
```

**Problems:**
1. ❌ No content type declaration in TOML files
2. ❌ No API version tracking per file
3. ❌ Inconsistent directory naming (units/ vs unit/, battle/ vs combat/)
4. ❌ No manifest of what content mod provides
5. ❌ No dependency declaration
6. ❌ No validation at load time

---

## Proposed Structure

### New Canonical Mod Structure

```
mods/my_mod/
├── mod.toml                    ✅ Enhanced manifest
├── README.md                   ✅ Human documentation
├── CHANGELOG.md                ✅ Version history
│
├── content/                    ✅ All game data
│   ├── units/                  ✅ Standardized naming (plural)
│   │   ├── README.md
│   │   ├── soldiers.toml       ✅ With metadata header
│   │   ├── aliens.toml
│   │   └── civilians.toml
│   │
│   ├── items/                  ✅ All equipment
│   │   ├── README.md
│   │   ├── weapons.toml
│   │   ├── armor.toml
│   │   ├── ammo.toml
│   │   └── equipment.toml
│   │
│   ├── facilities/             ✅ Base facilities
│   │   ├── README.md
│   │   ├── base_facilities.toml
│   │   ├── research_facilities.toml
│   │   └── defense_facilities.toml
│   │
│   ├── missions/               ✅ Mission definitions
│   │   ├── README.md
│   │   ├── mission_types.toml
│   │   └── objectives.toml
│   │
│   ├── research/               ✅ Tech tree
│   │   ├── README.md
│   │   ├── tech_tree.toml
│   │   └── research_projects.toml
│   │
│   ├── crafts/                 ✅ Aircraft
│   │   ├── README.md
│   │   ├── craft_types.toml
│   │   └── craft_weapons.toml
│   │
│   ├── geoscape/               ✅ World map
│   │   ├── README.md
│   │   ├── regions.toml
│   │   └── countries.toml
│   │
│   └── battlescape/            ✅ Tactical data
│       ├── README.md
│       ├── terrain.toml
│       └── battlescape_config.toml
│
├── assets/                     ✅ Binary resources
│   ├── images/
│   │   ├── units/
│   │   ├── items/
│   │   └── ui/
│   ├── sounds/
│   │   ├── weapons/
│   │   └── ambient/
│   └── fonts/
│
├── mapblocks/                  ✅ Map pieces
│   └── *.toml
│
├── mapscripts/                 ✅ Map generation
│   └── *.toml
│
├── tilesets/                   ✅ Terrain tilesets
│   └── *.toml
│
└── scripts/                    ✅ Optional Lua hooks
    ├── init.lua
    └── hooks/
```

**Key Principles:**
- ✅ Plural directory names (`units/` not `unit/`)
- ✅ Content grouped by domain (`content/units/`, `content/items/`)
- ✅ Consistent nesting depth
- ✅ README.md in each directory
- ✅ Metadata in each TOML file

---

## Enhanced mod.toml Specification

### Full Example

```toml
# ============================================================================
# MOD MANIFEST
# ============================================================================

[mod]
# Core identification
id = "core"                              # Unique ID (lowercase, no spaces)
name = "Core Game Content"               # Display name
version = "1.0.0"                        # Semantic versioning (MAJOR.MINOR.PATCH)
format_version = 2                       # Mod format version (for migration)

# Metadata
description = "Base game content including units, items, and facilities"
author = "AlienFall Team"
license = "MIT"
homepage = "https://github.com/alienfall/core"
repository = "https://github.com/alienfall/core"

# Dates
created = "2025-01-01"
updated = "2025-10-27"

# ============================================================================
# COMPATIBILITY
# ============================================================================

[compatibility]
# Engine version requirement (semantic versioning range)
engine_version = ">= 1.0.0, < 2.0.0"

# API schema version
api_version = "1.0.0"

# Game version (optional, for total conversions)
game_version = ">= 1.0.0"

# ============================================================================
# DEPENDENCIES
# ============================================================================

[dependencies]
# Required mods (must be loaded before this mod)
required = []
# Example: required = ["base_game >= 1.0.0", "engine_core >= 1.5.0"]

# Optional mods (enhanced features if present)
optional = []
# Example: optional = ["extra_weapons >= 1.0.0", "new_aliens >= 2.0.0"]

# Conflicting mods (incompatible)
conflicts = []
# Example: conflicts = ["old_unit_system < 3.0.0"]

# Load order priority (lower = earlier)
load_priority = 1

# ============================================================================
# DIRECTORY STRUCTURE
# ============================================================================

[paths]
# Content directories (relative to mod root)
content = "content"
assets = "assets"
mapblocks = "mapblocks"
mapscripts = "mapscripts"
tilesets = "tilesets"
scripts = "scripts"

# ============================================================================
# CONTENT MANIFEST
# ============================================================================

[content]
# What entities this mod provides
# Format: content_type = ["id1", "id2", ...]

# Units
provides_units = [
    "soldier_rookie",
    "soldier_squaddie",
    "soldier_sergeant",
    "alien_sectoid",
    "alien_muton",
    "civilian_male",
    "civilian_female"
]

# Items
provides_items = [
    "rifle",
    "pistol",
    "shotgun",
    "sniper_rifle",
    "combat_armor",
    "power_armor",
    "medkit",
    "grenade"
]

# Facilities
provides_facilities = [
    "command_center",
    "barracks",
    "laboratory",
    "workshop",
    "hangar",
    "storage"
]

# Missions
provides_missions = [
    "terror_mission",
    "abduction",
    "ufo_recovery",
    "base_defense"
]

# Research
provides_research = [
    "laser_weapons",
    "plasma_weapons",
    "alien_alloys",
    "elerium_115"
]

# Crafts
provides_crafts = [
    "skyranger",
    "interceptor",
    "firestorm"
]

# What this mod overrides (replaces content from other mods)
overrides = []
# Example: overrides = ["base_game:soldier_rookie", "core:rifle"]

# What systems this mod extends
extends = []
# Example: extends = ["research_tree", "tech_progression", "economy"]

# ============================================================================
# FEATURES
# ============================================================================

[features]
# What features this mod enables/disables
enables = []
# Example: enables = ["psionics", "base_defense_missions"]

disables = []
# Example: disables = ["automatic_weapons", "night_missions"]

# Configuration flags
[features.config]
# Example configuration options
# enable_permadeath = true
# starting_money = 1000000
# difficulty_multiplier = 1.5

# ============================================================================
# HOOKS (Optional, for advanced mods)
# ============================================================================

[hooks]
# Lua script hooks (executed at specific points)
on_init = "scripts/init.lua"              # When mod loads
on_game_start = "scripts/on_game_start.lua"  # New game
on_save = "scripts/on_save.lua"           # Before save
on_load = "scripts/on_load.lua"           # After load
on_battle_start = "scripts/on_battle.lua" # Battle begins

# ============================================================================
# SETTINGS (Optional, user-configurable)
# ============================================================================

[settings]
# Settings that players can configure

[[settings.option]]
id = "difficulty"
name = "Difficulty Level"
type = "enum"
values = ["easy", "normal", "hard", "impossible"]
default = "normal"

[[settings.option]]
id = "permadeath"
name = "Enable Permadeath"
type = "boolean"
default = true

[[settings.option]]
id = "starting_funds"
name = "Starting Funds"
type = "integer"
min = 100000
max = 10000000
default = 1000000

# ============================================================================
# METADATA (For mod browsers/managers)
# ============================================================================

[metadata]
# Tags for categorization
tags = ["gameplay", "units", "items", "facilities", "core"]

# Screenshots (for mod showcase)
screenshots = [
    "assets/screenshots/screenshot1.png",
    "assets/screenshots/screenshot2.png"
]

# Icon (for mod list)
icon = "assets/icon.png"

# Language support
languages = ["en", "pl", "de", "fr", "es"]

# Community links
discord = "https://discord.gg/alienfall"
forum = "https://forum.alienfall.com/mods/core"
wiki = "https://wiki.alienfall.com/mods/core"
```

---

## Enhanced Content File Format

### Standard TOML Header

**Every content TOML file should start with:**

```toml
# ============================================================================
# METADATA
# ============================================================================

[_metadata]
# Content type (must match API schema)
content_type = "units"

# API version this content is designed for
api_version = "1.0.0"

# File description
description = "Soldier unit definitions"

# Author information
author = "AlienFall Team"
created = "2025-01-01"
updated = "2025-10-27"

# Validation settings (optional)
[_metadata.validation]
strict_mode = true                  # Fail on unknown fields
warn_on_deprecated = true           # Warn if using deprecated fields

# ============================================================================
# CONTENT
# ============================================================================

# Entities defined below...
[[unit]]
id = "soldier_rookie"
# ... rest of definition
```

### Benefits of Metadata Header

1. ✅ **Content Type Declaration** - Validators know what schema to use
2. ✅ **API Version Tracking** - Detect version mismatches
3. ✅ **Self-Documenting** - Each file explains its purpose
4. ✅ **Audit Trail** - Know who created/updated when
5. ✅ **Validation Control** - Configure validation per file

---

## Implementation Steps

### Step 1: Update Core Mod Structure

**Action:** Migrate `mods/core/` to new structure

**Script:**
```bash
# Run migration tool
lovec tools/migration/migrate_mod_structure.lua mods/core/
```

**Manual Changes:**
1. Rename directories:
   - `rules/` → `content/`
   - `rules/unit/` → `content/units/`
   - `rules/battle/` → `content/battlescape/`

2. Add metadata to each TOML file:
   ```bash
   lovec tools/migration/add_metadata_headers.lua mods/core/content/
   ```

3. Update `mod.toml` with new sections:
   ```bash
   lovec tools/migration/upgrade_mod_toml.lua mods/core/mod.toml
   ```

4. Generate content manifest:
   ```bash
   lovec tools/migration/generate_manifest.lua mods/core/
   ```

---

### Step 2: Update ModManager

**File:** `engine/mods/mod_manager.lua` and `engine/core/mod_manager.lua`

**Changes:**

```lua
-- Add format version detection
function ModManager.loadMod(modPath)
    local modConfig = parseModToml(modPath .. "/mod.toml")
    
    -- Check format version
    local formatVersion = modConfig.mod.format_version or 1
    
    if formatVersion >= 2 then
        -- New format with validation
        return ModManager.loadModV2(modPath, modConfig)
    else
        -- Legacy format
        print("[WARNING] Mod '" .. modConfig.mod.name .. "' uses legacy format")
        print("[WARNING] Please upgrade to format version 2")
        return ModManager.loadModV1(modPath, modConfig)
    end
end

-- New loader with validation
function ModManager.loadModV2(modPath, modConfig)
    print("[ModManager] Loading mod (v2 format): " .. modConfig.mod.name)
    
    -- Validate mod structure
    local structureValid, structureErrors = ModManager.validateStructure(modPath, modConfig)
    if not structureValid then
        error("[ModManager] Mod structure validation failed:\n" .. 
              table.concat(structureErrors, "\n"))
    end
    
    -- Check compatibility
    ModManager.checkCompatibility(modConfig)
    
    -- Check dependencies
    ModManager.checkDependencies(modConfig)
    
    -- Register mod
    ModManager.registerMod(modConfig)
    
    print("[ModManager] ✓ Mod loaded successfully: " .. modConfig.mod.name)
end

-- Validate directory structure
function ModManager.validateStructure(modPath, modConfig)
    local errors = {}
    
    -- Check declared paths exist
    for pathType, relativePath in pairs(modConfig.paths or {}) do
        local fullPath = modPath .. "/" .. relativePath
        if not directoryExists(fullPath) then
            table.insert(errors, string.format(
                "Declared path '%s' not found: %s",
                pathType, fullPath
            ))
        end
    end
    
    -- Validate content directory structure
    local contentPath = modPath .. "/" .. (modConfig.paths.content or "content")
    if directoryExists(contentPath) then
        -- Check for standard subdirectories
        local expectedDirs = {"units", "items", "facilities", "missions"}
        for _, dir in ipairs(expectedDirs) do
            local dirPath = contentPath .. "/" .. dir
            if not directoryExists(dirPath) then
                -- Warning, not error (not all mods need all content types)
                print(string.format("[WARNING] Standard directory not found: %s", dirPath))
            end
        end
    end
    
    return #errors == 0, errors
end

-- Check version compatibility
function ModManager.checkCompatibility(modConfig)
    if not modConfig.compatibility then return end
    
    local engineVersion = getEngineVersion()  -- e.g., "1.5.0"
    local requiredVersion = modConfig.compatibility.engine_version
    
    if requiredVersion then
        if not isVersionCompatible(engineVersion, requiredVersion) then
            error(string.format(
                "[ModManager] Engine version mismatch!\n" ..
                "Mod '%s' requires: %s\n" ..
                "Engine version: %s",
                modConfig.mod.name,
                requiredVersion,
                engineVersion
            ))
        end
    end
end

-- Check dependencies
function ModManager.checkDependencies(modConfig)
    if not modConfig.dependencies then return end
    
    -- Check required dependencies
    for _, dep in ipairs(modConfig.dependencies.required or {}) do
        local depId, depVersion = parseDependency(dep)  -- "core >= 1.0.0"
        
        if not ModManager.isModLoaded(depId) then
            error(string.format(
                "[ModManager] Missing required dependency: %s",
                dep
            ))
        end
        
        local loadedMod = ModManager.getMod(depId)
        if not isVersionCompatible(loadedMod.version, depVersion) then
            error(string.format(
                "[ModManager] Dependency version mismatch!\n" ..
                "Required: %s\n" ..
                "Loaded: %s %s",
                dep,
                depId,
                loadedMod.version
            ))
        end
    end
    
    -- Check conflicts
    for _, conflict in ipairs(modConfig.dependencies.conflicts or {}) do
        local conflictId, conflictVersion = parseDependency(conflict)
        
        if ModManager.isModLoaded(conflictId) then
            local loadedMod = ModManager.getMod(conflictId)
            if isVersionCompatible(loadedMod.version, conflictVersion) then
                error(string.format(
                    "[ModManager] Mod conflict detected!\n" ..
                    "Mod '%s' conflicts with: %s %s",
                    modConfig.mod.name,
                    conflictId,
                    loadedMod.version
                ))
            end
        end
    end
end
```

---

### Step 3: Update DataLoader

**File:** `engine/core/data/data_loader.lua`

**Changes:**

```lua
-- Add metadata validation
function DataLoader.loadContent(contentType, filePath)
    print(string.format("[DataLoader] Loading %s from %s", contentType, filePath))
    
    local data = TOML.load(filePath)
    if not data then
        error(string.format("[DataLoader] Failed to load: %s", filePath))
    end
    
    -- Check for metadata section
    if data._metadata then
        -- Validate metadata
        local expectedContentType = data._metadata.content_type
        if expectedContentType ~= contentType then
            print(string.format(
                "[WARNING] Content type mismatch in %s\n" ..
                "Expected: %s, Found: %s",
                filePath,
                contentType,
                expectedContentType
            ))
        end
        
        -- Check API version
        local apiVersion = data._metadata.api_version
        if apiVersion then
            local currentAPIVersion = SchemaValidator.getAPIVersion()
            if not isVersionCompatible(apiVersion, currentAPIVersion) then
                print(string.format(
                    "[WARNING] API version mismatch in %s\n" ..
                    "Content uses: %s, Engine uses: %s",
                    filePath,
                    apiVersion,
                    currentAPIVersion
                ))
            end
        end
    else
        -- No metadata - legacy format
        print(string.format(
            "[WARNING] No metadata section in %s\n" ..
            "Please add [_metadata] section with content_type and api_version",
            filePath
        ))
    end
    
    -- Validate against schema
    if SchemaValidator.isEnabled() then
        local schema = SchemaValidator.getSchema(contentType)
        local valid, errors = SchemaValidator.validate(data, schema)
        
        if not valid then
            error(string.format(
                "[DataLoader] Validation failed for %s:\n%s",
                filePath,
                formatValidationErrors(errors)
            ))
        end
    end
    
    return data
end

-- Updated loaders use new function
function DataLoader.loadWeapons()
    local path = ModManager.getContentPath("content", "items/weapons.toml")
    if not path then
        error("[DataLoader] Could not get weapons path from mod")
    end
    
    local data = DataLoader.loadContent("weapons", path)
    
    -- Process data...
    local weapons = {}
    for _, weapon in ipairs(data.weapon or {}) do
        if weapon.id then
            weapons[weapon.id] = weapon
        end
    end
    
    return DataLoader.wrapWithUtilities(weapons, "weapons")
end
```

---

### Step 4: Create Migration Tools

#### Tool 1: Migrate Mod Structure

**File:** `tools/migration/migrate_mod_structure.lua`

```lua
local Migration = {}

function Migration.migrateModStructure(modPath)
    print("[Migration] Migrating mod structure: " .. modPath)
    
    -- 1. Rename directories
    if directoryExists(modPath .. "/rules") then
        print("[Migration] Renaming rules/ → content/")
        renameDirectory(modPath .. "/rules", modPath .. "/content")
    end
    
    -- 2. Standardize subdirectory names (plural)
    local renames = {
        ["content/unit"] = "content/units",
        ["content/item"] = "content/items",
        ["content/facility"] = "content/facilities",
        ["content/mission"] = "content/missions",
        ["content/battle"] = "content/battlescape",
    }
    
    for old, new in pairs(renames) do
        local oldPath = modPath .. "/" .. old
        local newPath = modPath .. "/" .. new
        if directoryExists(oldPath) then
            print(string.format("[Migration] Renaming %s → %s", old, new))
            renameDirectory(oldPath, newPath)
        end
    end
    
    -- 3. Add README.md files
    Migration.addReadmeFiles(modPath)
    
    print("[Migration] ✓ Structure migration complete")
end

function Migration.addReadmeFiles(modPath)
    local directories = {
        "content",
        "content/units",
        "content/items",
        "content/facilities",
        "content/missions",
        "content/research",
        "content/crafts",
        "content/geoscape",
        "content/battlescape",
    }
    
    for _, dir in ipairs(directories) do
        local dirPath = modPath .. "/" .. dir
        if directoryExists(dirPath) then
            local readmePath = dirPath .. "/README.md"
            if not fileExists(readmePath) then
                local readme = Migration.generateReadme(dir)
                writeFile(readmePath, readme)
                print("[Migration] Created: " .. readmePath)
            end
        end
    end
end

function Migration.generateReadme(directory)
    local name = directory:match("([^/]+)$")
    return string.format([[
# %s

Content for %s definitions.

## Files

- *.toml - TOML definition files

## Format

See `api/GAME_API.toml` for schema definition.
]], name:upper(), name)
end

return Migration
```

#### Tool 2: Add Metadata Headers

**File:** `tools/migration/add_metadata_headers.lua`

```lua
local MetadataAdder = {}

function MetadataAdder.addMetadataToFile(filePath, contentType)
    print("[Metadata] Processing: " .. filePath)
    
    -- Read existing file
    local content = readFile(filePath)
    
    -- Check if already has metadata
    if content:match("%[_metadata%]") then
        print("[Metadata] ⏭ Already has metadata, skipping")
        return
    end
    
    -- Generate metadata header
    local header = string.format([[
# ============================================================================
# METADATA
# ============================================================================

[_metadata]
content_type = "%s"
api_version = "1.0.0"
description = "Auto-generated metadata"
author = "AlienFall Team"
created = "%s"
updated = "%s"

# ============================================================================
# CONTENT
# ============================================================================

]], contentType, os.date("%Y-%m-%d"), os.date("%Y-%m-%d"))
    
    -- Prepend header to existing content
    local newContent = header .. content
    
    -- Write back
    writeFile(filePath, newContent)
    print("[Metadata] ✓ Added metadata header")
end

function MetadataAdder.processDirectory(dirPath, contentType)
    local files = listFiles(dirPath, "*.toml")
    
    for _, file in ipairs(files) do
        MetadataAdder.addMetadataToFile(file, contentType)
    end
end

return MetadataAdder
```

#### Tool 3: Upgrade mod.toml

**File:** `tools/migration/upgrade_mod_toml.lua`

```lua
local ModTomlUpgrader = {}

function ModTomlUpgrader.upgrade(modTomlPath)
    print("[Upgrade] Upgrading mod.toml: " .. modTomlPath)
    
    -- Load existing
    local config = TOML.load(modTomlPath)
    
    -- Add format_version if missing
    if not config.mod.format_version then
        config.mod.format_version = 2
    end
    
    -- Add compatibility section if missing
    if not config.compatibility then
        config.compatibility = {
            engine_version = ">= 1.0.0",
            api_version = "1.0.0"
        }
    end
    
    -- Add dependencies section if missing
    if not config.dependencies then
        config.dependencies = {
            required = {},
            optional = {},
            conflicts = {}
        }
    end
    
    -- Add paths section if missing
    if not config.paths then
        config.paths = {
            content = "content",
            assets = "assets",
            mapblocks = "mapblocks",
            mapscripts = "mapscripts",
            tilesets = "tilesets"
        }
    end
    
    -- Add content manifest placeholder
    if not config.content then
        config.content = {
            provides_units = {},
            provides_items = {},
            provides_facilities = {},
            provides_missions = {},
            provides_research = {},
            provides_crafts = {}
        }
        
        print("[Upgrade] ⚠ Added empty content manifest")
        print("[Upgrade] ⚠ Run generate_manifest.lua to populate it")
    end
    
    -- Save upgraded config
    TOML.save(modTomlPath, config)
    
    print("[Upgrade] ✓ mod.toml upgraded to format version 2")
end

return ModTomlUpgrader
```

#### Tool 4: Generate Content Manifest

**File:** `tools/migration/generate_manifest.lua`

```lua
local ManifestGenerator = {}

function ManifestGenerator.generate(modPath)
    print("[Manifest] Scanning mod content: " .. modPath)
    
    local manifest = {
        provides_units = {},
        provides_items = {},
        provides_facilities = {},
        provides_missions = {},
        provides_research = {},
        provides_crafts = {}
    }
    
    -- Scan each content type
    local contentPath = modPath .. "/content"
    
    -- Units
    manifest.provides_units = ManifestGenerator.scanIds(
        contentPath .. "/units",
        "unit"
    )
    
    -- Items
    manifest.provides_items = ManifestGenerator.scanIds(
        contentPath .. "/items",
        "weapon", "armor", "item", "equipment"
    )
    
    -- Facilities
    manifest.provides_facilities = ManifestGenerator.scanIds(
        contentPath .. "/facilities",
        "facility"
    )
    
    -- Missions
    manifest.provides_missions = ManifestGenerator.scanIds(
        contentPath .. "/missions",
        "mission"
    )
    
    -- Research
    manifest.provides_research = ManifestGenerator.scanIds(
        contentPath .. "/research",
        "research", "technology"
    )
    
    -- Crafts
    manifest.provides_crafts = ManifestGenerator.scanIds(
        contentPath .. "/crafts",
        "craft"
    )
    
    -- Update mod.toml
    local modTomlPath = modPath .. "/mod.toml"
    local config = TOML.load(modTomlPath)
    config.content = manifest
    TOML.save(modTomlPath, config)
    
    print("[Manifest] ✓ Generated manifest:")
    print(string.format("  - Units: %d", #manifest.provides_units))
    print(string.format("  - Items: %d", #manifest.provides_items))
    print(string.format("  - Facilities: %d", #manifest.provides_facilities))
    print(string.format("  - Missions: %d", #manifest.provides_missions))
    print(string.format("  - Research: %d", #manifest.provides_research))
    print(string.format("  - Crafts: %d", #manifest.provides_crafts))
end

function ManifestGenerator.scanIds(directory, ...)
    local entityTypes = {...}
    local ids = {}
    
    if not directoryExists(directory) then
        return ids
    end
    
    local files = listFiles(directory, "*.toml")
    
    for _, file in ipairs(files) do
        local data = TOML.load(file)
        
        for _, entityType in ipairs(entityTypes) do
            if data[entityType] then
                -- Array of entities
                for _, entity in ipairs(data[entityType]) do
                    if entity.id then
                        table.insert(ids, entity.id)
                    end
                end
            end
        end
    end
    
    return ids
end

return ManifestGenerator
```

---

## Validation Integration

### Runtime Validation

**Enable validation during content loading:**

```lua
-- engine/conf.lua
function love.conf(t)
    -- Enable content validation in debug mode
    t.content_validation = true
    t.strict_validation = false  -- Set to true for development
end

-- engine/core/data/data_loader.lua
function DataLoader.load()
    local config = love.conf
    
    if config.content_validation then
        print("[DataLoader] Content validation ENABLED")
        SchemaValidator.setEnabled(true)
        
        if config.strict_validation then
            print("[DataLoader] STRICT validation mode")
            SchemaValidator.setStrictMode(true)
        end
    end
    
    -- Load all content with validation
    DataLoader.terrainTypes = DataLoader.loadTerrainTypes()
    DataLoader.weapons = DataLoader.loadWeapons()
    -- ... etc
end
```

---

## Documentation Updates

### Files to Update

1. **api/MODDING_GUIDE.md** - Update with new structure
2. **mods/README.md** - Update with new format
3. **mods/core/README.md** - Document core mod structure
4. **docs/MIGRATION_GUIDE.md** - Create migration guide

### New Documentation Files

1. **MOD_FORMAT_V2_SPECIFICATION.md** - Full specification
2. **MOD_CREATION_TUTORIAL.md** - Step-by-step tutorial
3. **MOD_VALIDATION_GUIDE.md** - How to validate mods

---

## Timeline

### Week 1: Foundation
- ✅ Create migration tools
- ✅ Test tools on small mod
- ✅ Document new format

### Week 2: Core Mod Migration
- ✅ Migrate mods/core/ to new structure
- ✅ Add metadata headers
- ✅ Generate manifest
- ✅ Test game with migrated mod

### Week 3: Engine Updates
- ✅ Update ModManager with v2 support
- ✅ Update DataLoader with validation
- ✅ Add backward compatibility

### Week 4: Validation & Testing
- ✅ Integrate schema validation
- ✅ Test all content loads correctly
- ✅ Fix any validation errors

### Week 5: Documentation
- ✅ Update all documentation
- ✅ Create migration guide
- ✅ Create tutorial

---

## Success Criteria

- ✅ Core mod uses new structure
- ✅ All content has metadata headers
- ✅ mod.toml includes manifest
- ✅ Validation runs at load time
- ✅ No breaking changes for existing saves
- ✅ Documentation complete
- ✅ Migration tools available

---

## Next Steps

1. **Review this plan** with team
2. **Create migration tools** (Tools directory)
3. **Test on small mod** first
4. **Migrate core mod**
5. **Update engine**
6. **Document everything**

---

**End of Plan**

