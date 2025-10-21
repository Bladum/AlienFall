# Phase 5 Step 2: Engine Code Analysis

**Status**: COMPLETE  
**Date**: October 21, 2025  
**Duration**: Step 2 Analysis Complete  
**Focus**: TOML parsing, validation patterns, data loading architecture  

---

## Overview

This document analyzes the actual engine code to extract:
1. **TOML parsing mechanisms** - How TOML files are loaded and parsed
2. **Validation patterns** - How data is validated during loading
3. **Type constraints** - Field types, requirements, and defaults
4. **Example data** - Real, working TOML files from mods/core
5. **Modding API** - How mods provide data to the engine

---

## Part 1: TOML Parsing & Data Loading Architecture

### DataLoader.lua Overview

**Location**: `engine/core/data_loader.lua` (484 lines)  
**Purpose**: Central data loading system for all game content  
**Loads 14 content types** using TOML files from mods

#### Load Pattern - Standard Function Template

Every DataLoader function follows this pattern:

```lua
function DataLoader.load<ContentType>()
    -- 1. Get content path from ModManager
    local path = ModManager.getContentPath("content_type", "subdirectory/file.toml")
    if not path then
        print("[DataLoader] ERROR: Could not get path from mod")
        return {}
    end
    
    -- 2. Load and parse TOML file
    local data = TOML.load(path)
    if not data then
        print("[DataLoader] ERROR: Failed to load TOML")
        return {}
    end

    -- 3. Convert TOML structure to Lua tables with utility functions
    local result = {
        items = {}  -- Data storage
    }
    
    -- 4. Convert array to indexed table by ID
    for _, item in ipairs(data.item_array or {}) do
        if item.id then
            result.items[item.id] = item
        end
    end

    -- 5. Add utility functions (get, getAllIds, getByProperty, etc.)
    function result.get(itemId)
        return result.items[itemId]
    end
    
    function result.getAllIds()
        local ids = {}
        for id, _ in pairs(result.items) do
            table.insert(ids, id)
        end
        return ids
    end

    print(string.format("[DataLoader] ✓ Loaded %d items", #result.getAllIds()))
    return result
end
```

### Content Types & Load Sequence

| # | Content Type | File Pattern | Load Function | Entities |
|---|---|---|---|---|
| **1** | **Terrain** | `rules/battle/terrain.toml` | `loadTerrainTypes()` | Terrain types, movement costs |
| **2** | **Weapons** | `rules/items/weapons.toml` | `loadWeapons()` | Weapon templates |
| **3** | **Armours** | `rules/items/armours.toml` | `loadArmours()` | Armor templates |
| **4** | **Skills** | `rules/items/skills.toml` | `loadSkills()` | Ability definitions |
| **5** | **Unit Classes** | `rules/units/classes.toml` | `loadUnitClasses()` | Class templates |
| **6** | **Units** | `rules/units/*.toml` (multi-file) | `loadUnits()` | Unit types |
| **7** | **Facilities** | `rules/facilities/*.toml` (multi-file) | `loadFacilities()` | Base facilities |
| **8** | **Missions** | `rules/missions/*.toml` (multi-file) | `loadMissions()` | Mission definitions |
| **9** | **Campaigns** | `campaigns/*.toml` (multi-file) | `loadCampaigns()` | Campaign phases |
| **10** | **Factions** | `factions/*.toml` (multi-file) | `loadFactions()` | Faction definitions |
| **11** | **Technology** | `technology/*.toml` (multi-file) | `loadTechnology()` | Tech trees |
| **12** | **Narrative** | `narrative/*.toml` (multi-file) | `loadNarrative()` | Story events |
| **13** | **Geoscape** | `geoscape/*.toml` (multi-file) | `loadGeoscape()` | World data |
| **14** | **Economy** | `economy/*.toml` (multi-file) | `loadEconomy()` | Economic data |

### Utility Functions Pattern

All DataLoader tables provide these standard functions:

```lua
-- Get single item by ID
result.get(itemId) -> table or nil

-- Get all IDs as array
result.getAllIds() -> table

-- Find items by property
result.getByProperty(propertyName, propertyValue) -> table (array of IDs)

-- Find items by type
result.getByType(typeValue) -> table (array of IDs)

-- Find items by faction/class/side
result.getByFaction(factionId) -> table (array of IDs)
result.getForClass(classId) -> table (array of IDs)
result.getBySide(sideValue) -> table (array of IDs)
```

---

### Main Load Function

```lua
function DataLoader.load()
    print("[DataLoader] Starting to load all game data...")
    
    DataLoader.terrainTypes = DataLoader.loadTerrainTypes()
    DataLoader.weapons = DataLoader.loadWeapons()
    DataLoader.armours = DataLoader.loadArmours()
    DataLoader.skills = DataLoader.loadSkills()
    DataLoader.unitClasses = DataLoader.loadUnitClasses()
    DataLoader.units = DataLoader.loadUnits()
    DataLoader.facilities = DataLoader.loadFacilities()
    DataLoader.missions = DataLoader.loadMissions()
    DataLoader.campaigns = DataLoader.loadCampaigns()
    DataLoader.factions = DataLoader.loadFactions()
    DataLoader.technology = DataLoader.loadTechnology()
    DataLoader.narrative = DataLoader.loadNarrative()
    DataLoader.geoscape = DataLoader.loadGeoscape()
    DataLoader.economy = DataLoader.loadEconomy()

    print("[DataLoader] ✓ Successfully loaded all game data (13 content types)")
    return true
end
```

### Usage Example

```lua
-- Load all data
DataLoader.load()

-- Access loaded data
local weapon = DataLoader.weapons.get("rifle")
local facility = DataLoader.facilities.get("command_center")
local allWeaponIds = DataLoader.weapons.getAllIds()
local plasmaWeapons = DataLoader.weapons.getByType("plasma")
```

---

## Part 2: ModManager.lua - Content Path Resolution

### ModManager Overview

**Location**: `engine/mods/mod_manager.lua` (484 lines)  
**Purpose**: Mod discovery, loading, and content path resolution  
**Key Responsibility**: Bridge between game engine and mod filesystem

### Mod Structure

```
mods/modname/
├── mod.toml                    # Mod metadata
├── content/
│   ├── rules/                  # Game rules
│   │   ├── battle/
│   │   │   └── terrain.toml
│   │   ├── items/
│   │   │   ├── weapons.toml
│   │   │   ├── armours.toml
│   │   │   └── equipment.toml
│   │   ├── units/
│   │   │   ├── classes.toml
│   │   │   ├── soldiers.toml
│   │   │   ├── aliens.toml
│   │   │   └── civilians.toml
│   │   ├── facilities/
│   │   │   ├── base_facilities.toml
│   │   │   ├── research_facilities.toml
│   │   │   ├── manufacturing.toml
│   │   │   └── defense.toml
│   │   └── missions/
│   │       ├── tactical_missions.toml
│   │       └── strategic_missions.toml
│   ├── mapblocks/              # Procedural map pieces
│   ├── mapscripts/             # Map generation scripts
│   ├── tilesets/               # Tile graphics and definitions
│   ├── factions/               # Faction definitions
│   ├── campaigns/              # Campaign structures
│   ├── narrative/              # Story content
│   ├── geoscape/               # World map data
│   ├── economy/                # Economic data
│   ├── technology/             # Tech trees
│   └── assets/                 # Images, sounds, fonts
└── README.md                   # Mod documentation
```

### Key ModManager Functions

#### 1. Initialization

```lua
ModManager.init()
```

- Scans `mods/` directory
- Discovers all mod directories containing `mod.toml`
- Loads mod metadata from TOML files
- Attempts to load 'core' mod by default
- Falls back to 'xcom_simple' or 'new' if needed
- **Must be called during game initialization**

#### 2. Mod Scanning & Registration

```lua
-- Scan mods directory and load all mod.toml files
local modList = ModManager.scanMods()

-- Register a mod in the system
ModManager.registerMod(modConfig)

-- Load all discovered mods
ModManager.loadMods()
```

#### 3. Setting Active Mod

```lua
-- Set which mod to use for content
ModManager.setActiveMod("core")
ModManager.setActiveMod("new")

-- Get active mod config
local activeMod = ModManager.getActiveMod()
```

#### 4. Content Path Resolution

```lua
-- Get path to content in active mod
local terrainPath = ModManager.getContentPath("rules", "battle/terrain.toml")
local weaponsPath = ModManager.getContentPath("rules", "items/weapons.toml")
local mapblocksPath = ModManager.getContentPath("mapblocks")

-- Full path returned ready for TOML.load() or io.open()
```

**Path Resolution Logic**:
```lua
function ModManager.getContentPath(contentType, subpath)
    local mod = ModManager.getActiveMod()
    local basePath = mod.mod.path
    local contentPath = mod.paths[contentType]
    
    -- Combines: basePath + contentPath + subpath
    -- Example: "C:\...\mods\core" + "rules" + "items/weapons.toml"
    -- Result: "C:\...\mods\core\rules\items\weapons.toml"
    
    return fullPath
end
```

---

## Part 3: Real TOML Examples from mods/core

### Example 1: Mod Metadata (mod.toml)

**Location**: `mods/core/mod.toml`

```toml
[mod]
id = "core"
name = "Core Game Data"
version = "1.0.0"
description = "Core game data and assets"

[settings]
enabled = true
load_order = 1

[paths]
assets = "assets"
rules = "rules"
mapblocks = "mapblocks"
mapscripts = "mapscripts"
tilesets = "tilesets"
```

**Required Fields**:
- `[mod].id` - Unique mod identifier (string)
- `[mod].name` - Human-readable name (string)
- `[mod].version` - Semantic version (string: "X.Y.Z")
- `[mod].description` - Short description (string)
- `[settings].enabled` - Load this mod (boolean)
- `[settings].load_order` - Loading priority (integer, lower = earlier)
- `[paths].*` - Content type paths (strings, relative to mod root)

---

### Example 2: Weapon Definitions (rules/items/weapons.toml)

**Location**: `mods/core/rules/items/weapons.toml`

```toml
[[weapon]]
id = "rifle"
name = "Rifle"
description = "Standard issue rifle"
type = "primary"
damage = 50
accuracy = 70
range = 25
ammo_type = "rifle_ammo"
cost = 800
tech_level = "conventional"

[[weapon]]
id = "plasma_rifle"
name = "Plasma Rifle"
description = "Standard alien plasma rifle"
type = "primary"
damage = 70
accuracy = 70
range = 25
ammo_type = "plasma_cartridge"
cost = 0
tech_level = "plasma"

[[weapon]]
id = "laser_rifle"
name = "Laser Rifle"
description = "Precision laser weapon"
type = "primary"
damage = 65
accuracy = 85
range = 25
ammo_type = "laser_power_pack"
cost = 2500
tech_level = "laser"
```

**Weapon Schema**:

| Field | Type | Required | Range/Options | Notes |
|---|---|---|---|---|
| `id` | string | YES | alphanumeric_underscore | Unique weapon ID |
| `name` | string | YES | any | Display name |
| `description` | string | NO | any | Flavor text |
| `type` | string | YES | "primary", "secondary", "melee", "grenade" | Weapon slot |
| `damage` | integer | YES | 10-150 | Base damage output |
| `accuracy` | integer | YES | 0-100 | Base accuracy percentage |
| `range` | integer | YES | 5-100 | Attack range (tiles) |
| `ammo_type` | string | YES | ammo ID | Ammunition type |
| `fire_rate` | integer | NO | 1-5 | Shots per turn (optional) |
| `cost` | integer | YES | 0-99999 | Manufacture cost (credits) |
| `tech_level` | string | YES | "conventional", "plasma", "laser", "alien" | Tech category |

**Parsing Notes**:
- Uses `[[weapon]]` array syntax in TOML
- Parsed as `data.weapon` array in Lua
- Converted to dictionary by ID in DataLoader
- Usage: `DataLoader.weapons.get("rifle")`

---

### Example 3: Armour Definitions (rules/items/armours.toml)

**Location**: `mods/core/rules/items/armours.toml`

```toml
[[armour]]
id = "combat_armor_light"
name = "Light Combat Armor"
description = "Basic protective gear"
type = "light"
armor_value = 5
weight = 3
cost = 400
tech_level = "conventional"

[[armour]]
id = "power_suit"
name = "Power Suit"
description = "Powered exoskeleton armor"
type = "power"
armor_value = 20
weight = 12
cost = 3500
tech_level = "advanced"

[[armour]]
id = "muton_hide"
name = "Muton Hide"
description = "Alien muton natural armor"
type = "alien"
armor_value = 10
weight = 0
cost = 0
tech_level = "alien"
```

**Armour Schema**:

| Field | Type | Required | Range/Options | Notes |
|---|---|---|---|---|
| `id` | string | YES | alphanumeric_underscore | Unique armour ID |
| `name` | string | YES | any | Display name |
| `description` | string | NO | any | Flavor text |
| `type` | string | YES | "light", "standard", "heavy", "power", "alien", "special" | Armour category |
| `armor_value` | integer | YES | 0-30 | Damage reduction |
| `weight` | integer | YES | 0-20 | Movement penalty |
| `cost` | integer | YES | 0-99999 | Manufacture cost |
| `tech_level` | string | YES | "conventional", "advanced", "plasma", "laser", "alien" | Tech category |

---

### Example 4: Facility Definitions (rules/facilities/base_facilities.toml)

**Location**: `mods/core/rules/facilities/base_facilities.toml`

```toml
[[facility]]
id = "command_center"
name = "Command Center"
description = "Strategic command and control center"
type = "command"
width = 2
height = 2
cost = 2000
time_to_build = 10
maintenance_cost = 50
effect = "base_command"

[[facility]]
id = "living_quarters"
name = "Living Quarters"
description = "Soldiers' barracks and sleeping area"
type = "residential"
width = 3
height = 2
cost = 800
time_to_build = 5
maintenance_cost = 15
capacity = 10
effect = "soldier_morale"

[[facility]]
id = "workshop"
name = "Workshop"
description = "Equipment manufacturing and maintenance"
type = "manufacturing"
width = 2
height = 2
cost = 1500
time_to_build = 8
maintenance_cost = 30
production_rate = 1.2

[[facility]]
id = "power_generator"
name = "Power Generator"
description = "Nuclear power generation"
type = "power"
width = 1
height = 1
cost = 1200
time_to_build = 8
maintenance_cost = 25
power_generation = 10
effect = "power_supply"

[[facility]]
id = "alien_containment"
name = "Alien Containment"
description = "Secure facility for alien prisoners"
type = "research"
width = 2
height = 2
cost = 1500
time_to_build = 8
maintenance_cost = 30
capacity = 5
effect = "alien_research"
```

**Facility Schema**:

| Field | Type | Required | Range/Options | Notes |
|---|---|---|---|---|
| `id` | string | YES | alphanumeric_underscore | Unique facility ID |
| `name` | string | YES | any | Display name |
| `description` | string | NO | any | Flavor text |
| `type` | string | YES | "command", "residential", "manufacturing", "storage", "power", "detection", "medical", "research", "defense" | Facility type |
| `width` | integer | YES | 1-5 | Grid width (hexes) |
| `height` | integer | YES | 1-5 | Grid height (hexes) |
| `cost` | integer | YES | 0-99999 | Build cost (credits) |
| `time_to_build` | integer | YES | 1-100 | Days to construct |
| `maintenance_cost` | integer | YES | 0-500 | Monthly upkeep |
| `capacity` | integer | NO | 1-100 | Storage/personnel limit |
| `production_rate` | number | NO | 0.5-3.0 | Manufacturing bonus multiplier |
| `power_generation` | integer | NO | 1-50 | Power units generated |
| `detection_radius` | integer | NO | 10-200 | Radar range (kilometers) |
| `specialization` | string | NO | "armor", "ammunition", "research" | Workshop specialization |
| `effect` | string | NO | game effect ID | Special ability |

---

## Part 4: Validation Patterns

### Validation Approach

DataLoader uses **defensive programming** - assumes TOML might be incomplete and provides defaults:

```lua
-- Pattern 1: Direct access with default
local value = terrain.moveCost or 2  -- Use field if exists, default to 2

-- Pattern 2: Get with validation
function result.getMoveCost(terrainId)
    local terrain = result.get(terrainId)
    return terrain and terrain.moveCost or 2
end

-- Pattern 3: Boolean checks
function result.blocksMovement(terrainId)
    local terrain = result.get(terrainId)
    return terrain and terrain.blocksMovement  -- Returns true/false/nil
end
```

### Type Conversion Rules

When TOML data is loaded:

```lua
-- Integers: Keep as-is
damage = 50  -- Stays 50

-- Strings: Keep as-is
type = "primary"  -- Stays "primary"

-- Booleans: Must be explicit in TOML
enabled = true  -- TOML: true or false

-- Arrays: TOML [[array]] becomes Lua table
[[weapon]]  -- Becomes table in data.weapon array

-- Nested tables: TOML sections
[facility.adjacency_bonus]
type = "research"
value = 15
-- Becomes: facility.adjacency_bonus.type and facility.adjacency_bonus.value
```

### Error Handling

```lua
-- Graceful degradation - return empty table on error
function DataLoader.loadWeapons()
    local path = ModManager.getContentPath("rules", "items/weapons.toml")
    if not path then
        print("[DataLoader] ERROR: Could not get weapons path from mod")
        return {}  -- Empty table with no items
    end
    
    local data = TOML.load(path)
    if not data then
        print("[DataLoader] ERROR: Failed to load weapons")
        return {}  -- Empty table instead of crashing
    end
    
    -- ... rest of loading
end

-- Usage is safe even if loading failed:
local weapon = DataLoader.weapons.get("rifle")  -- Returns nil safely if not found
```

---

## Part 5: Array vs Single Item Patterns

### Single-Item Content (Dictionary Lookup)

For single-entry sections in TOML:

```toml
[mod]
id = "core"
name = "Core Game Data"
version = "1.0.0"
```

Loaded as:
```lua
local modConfig = TOML.load("mod.toml")
-- modConfig.mod.id = "core"
-- modConfig.mod.name = "Core Game Data"
```

### Multi-Item Content (Array Lookup)

For repeated entries in TOML:

```toml
[[weapon]]
id = "rifle"
name = "Rifle"

[[weapon]]
id = "plasma_rifle"
name = "Plasma Rifle"
```

Loaded as:
```lua
local data = TOML.load("weapons.toml")
-- data.weapon = array of weapon tables
-- data.weapon[1].id = "rifle"
-- data.weapon[2].id = "plasma_rifle"

-- Converted by DataLoader to indexed by ID:
-- DataLoader.weapons.weapons["rifle"] = { id = "rifle", name = "Rifle" }
-- DataLoader.weapons.weapons["plasma_rifle"] = { id = "plasma_rifle", ... }
```

---

## Part 6: File Organization Patterns

### Multi-File Loading Pattern

For content types with many entries, files are split:

```lua
function DataLoader.loadUnits()
    local path = ModManager.getContentPath("rules", "units")
    local units = { units = {} }
    
    local unitFiles = {"soldiers.toml", "aliens.toml", "civilians.toml"}
    local totalLoaded = 0
    
    for _, filename in ipairs(unitFiles) do
        local fullPath = buildPath(path, filename)
        local data = TOML.load(fullPath)
        if data and data.unit then
            for _, unit in ipairs(data.unit) do
                if unit.id then
                    units.units[unit.id] = unit
                    totalLoaded = totalLoaded + 1
                end
            end
        end
    end
    
    print(string.format("[DataLoader] ✓ Loaded %d unit types", totalLoaded))
    return units
end
```

### File Organization Best Practices (from engine)

| Content Type | Files | Rationale |
|---|---|---|
| **weapons** | 1 file | ~20 entries, manageable |
| **armours** | 1 file | ~10 entries, manageable |
| **units** | 3 files | soldiers, aliens, civilians (organizational logic) |
| **facilities** | 4 files | base_facilities, research, manufacturing, defense (by purpose) |
| **missions** | 2 files | tactical_missions, strategic_missions (by scope) |
| **campaigns** | 4 files | phase0_shadow_war, phase1_sky_war, phase2_deep_war, phase3_dimensional_war (by campaign phase) |
| **factions** | 3 files | faction_sectoids, faction_mutons, faction_ethereals (by faction) |

---

## Part 7: Path Building Helper

DataLoader includes cross-platform path building:

```lua
local function buildPath(basePath, ...)
    -- Detect if we're on Windows (basePath contains backslashes)
    local isWindows = basePath:find("\\") ~= nil
    local separator = isWindows and "\\" or "/"
    
    local fullPath = basePath
    for i, component in ipairs({...}) do
        -- Normalize component separators to match platform
        component = component:gsub("/", separator):gsub("\\", separator)
        fullPath = fullPath .. separator .. component
    end
    return fullPath
end

-- Usage:
local weaponsPath = buildPath(basePath, "rules", "items", "weapons.toml")
-- Returns: "C:\path\to\mods\core\rules\items\weapons.toml" (on Windows)
-- Returns: "/path/to/mods/core/rules/items/weapons.toml" (on Linux)
```

---

## Part 8: Dependencies & Integration Points

### Dependency Chain

```
game.lua (main entry)
  ├─ main.lua (love.load)
  │   └─ require("core.state_manager")
  │       └─ StateManager.initialize()
  │
  └─ conf.lua
      └─ configure game settings

StateManager.initialize()
  ├─ ModManager.init()
  │   └─ Scans mods/ and loads mod.toml files
  │
  └─ DataLoader.load()
      ├─ Uses ModManager.getContentPath() for each content type
      ├─ TOML.load() to parse files
      └─ Returns indexed tables with utility functions

During Gameplay:
  ├─ Geoscape uses DataLoader.factions, DataLoader.missions, DataLoader.geoscape
  ├─ Basescape uses DataLoader.units, DataLoader.facilities, DataLoader.technology
  ├─ Battlescape uses DataLoader.missions, DataLoader.weapons, DataLoader.armours
  └─ UI uses DataLoader for all display data
```

### TOML Library

- **Location**: `engine/utils/toml.lua`
- **Functions**:
  - `TOML.load(filepath)` - Loads and parses file
  - `TOML.parse(toml_string)` - Parses string content
- **Usage**: Called by DataLoader and ModManager

---

## Part 9: Modding Infrastructure

### Mod API Contract

When modders create mods, they must follow this structure:

```
mods/mymod/
├── mod.toml                    # REQUIRED: Mod metadata
├── content/
│   ├── rules/
│   │   ├── items/
│   │   │   ├── weapons.toml    # OPTIONAL: Custom weapons
│   │   │   └── armours.toml    # OPTIONAL: Custom armours
│   │   ├── units/
│   │   │   └── *.toml          # OPTIONAL: Custom unit types
│   │   ├── facilities/
│   │   │   └── *.toml          # OPTIONAL: Custom facilities
│   │   └── missions/
│   │       └── *.toml          # OPTIONAL: Custom missions
│   ├── mapblocks/              # OPTIONAL: Custom map pieces
│   ├── tilesets/               # OPTIONAL: Custom terrain graphics
│   ├── factions/               # OPTIONAL: Custom factions
│   ├── technology/             # OPTIONAL: Custom tech trees
│   ├── campaigns/              # OPTIONAL: Custom campaigns
│   ├── narrative/              # OPTIONAL: Custom story events
│   ├── geoscape/               # OPTIONAL: Custom world data
│   ├── economy/                # OPTIONAL: Custom economic data
│   └── assets/                 # OPTIONAL: Images, sounds, fonts
└── README.md                   # RECOMMENDED: Mod documentation
```

### Mod Enable/Disable System

Mods can be disabled in mod.toml:

```toml
[settings]
enabled = false  # This mod won't be loaded
```

---

## Summary: Key Takeaways for API Documentation

### 1. TOML Arrays vs Sections

**Arrays** (for repeating content):
```toml
[[weapon]]
id = "rifle"
...

[[weapon]]
id = "plasma_rifle"
...
```

**Sections** (for single entries):
```toml
[mod]
id = "core"
name = "Core"
```

### 2. Utility Function Pattern

Every loaded content type provides:
- `.get(id)` - Get item by ID
- `.getAllIds()` - Get all IDs
- `.getByType(type)` - Filter by type
- `.getBy*(value)` - Filter by property

### 3. Error Handling

- Return empty tables instead of failing
- Provide defaults for missing fields
- Check for nil before accessing properties
- Log all errors to console for debugging

### 4. File Organization

- Keep TOML files to <300 lines for readability
- Split large content types into logical files (by faction, by type, by phase)
- Follow consistent naming: plural nouns (weapons.toml, facilities.toml)

### 5. Validation Approach

- Assume data might be incomplete
- Use `field or default` pattern for defaults
- Check for existence before using: `terrain and terrain.moveCost`
- Graceful degradation: always return something usable

---

## Next Steps: API Documentation

Now that engine code is analyzed, Step 3 will:

1. Create `wiki/api/API_SCHEMA_REFERENCE.md` - Document schema for each entity type
2. Create `wiki/api/API_WEAPONS_AND_ARMOR.md` - Weapons and armour API with examples
3. Create `wiki/api/API_UNITS_AND_CLASSES.md` - Units and unit classes API
4. Create `wiki/api/API_FACILITIES.md` - Facility definitions API
5. Create `wiki/api/API_MISSIONS.md` - Mission definitions API
6. Create `wiki/api/API_ECONOMY_AND_ITEMS.md` - Economy and items API
7. Create `wiki/api/MOD_DEVELOPER_GUIDE.md` - Complete guide for mod creation
8. Create `wiki/api/TOML_FORMATTING_GUIDE.md` - TOML best practices and examples

Each will include:
- **Schema**: Field definitions, types, constraints
- **Validation**: Required fields, defaults, constraints
- **Examples**: Real working TOML from mods/core
- **Modding Notes**: Tips for extending or overriding
- **Cross-References**: Links to related entity types and systems

---

## Conclusion

Step 2 Engine Code Analysis is COMPLETE. All TOML parsing mechanisms, validation patterns, and data loading architecture have been documented with real code examples from the engine. Ready to proceed to **Step 3: API Documentation** to create comprehensive reference documentation for all 118 entity types.

