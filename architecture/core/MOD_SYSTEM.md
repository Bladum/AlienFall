# Mod System Architecture

**System:** Mod Loading and Content Management  
**Date:** 2025-10-27  
**Status:** Complete

---

## Overview

The mod system provides content loading, validation, and override mechanisms for all game data.

---

## Mod Loading Pipeline

```mermaid
graph TB
    Start[Game Boot] --> Scan[Scan mods/ Directory]
    
    Scan --> Parse[Parse mod.toml Files]
    
    Parse --> Validate{Validate Each Mod}
    
    Validate -->|Invalid| LogError[Log Error & Skip]
    Validate -->|Valid| CheckDeps[Check Dependencies]
    
    CheckDeps -->|Missing| LogError
    CheckDeps -->|Conflict| LogError
    CheckDeps -->|OK| AddQueue[Add to Load Queue]
    
    AddQueue --> MoreMods{More Mods?}
    MoreMods -->|Yes| Parse
    MoreMods -->|No| Sort[Sort by Priority]
    
    Sort --> LoadContent[Load Content Files]
    
    LoadContent --> ValidateSchema{Schema Valid?}
    
    ValidateSchema -->|Invalid| StrictCheck{Strict Mode?}
    ValidateSchema -->|Valid| Register[Register in DataLoader]
    
    StrictCheck -->|Yes| Abort[Abort Game]
    StrictCheck -->|No| Register
    
    Register --> LoadAssets[Load Binary Assets]
    LoadAssets --> RunHooks[Run on_init Hooks]
    
    RunHooks --> NextMod{More Mods?}
    NextMod -->|Yes| LoadContent
    NextMod -->|No| Complete[Mods Loaded]
    
    style Start fill:#90EE90
    style Complete fill:#87CEEB
    style LogError fill:#FF6B6B
    style Abort fill:#FF0000
    style ValidateSchema fill:#FFD700
```

---

## Mod Manifest Structure

```mermaid
graph TD
    ModToml[mod.toml] --> Metadata[Metadata Section]
    ModToml --> Dependencies[Dependencies]
    ModToml --> Content[Content Paths]
    ModToml --> Assets[Asset Paths]
    ModToml --> Hooks[Hook Scripts]
    
    Metadata --> ID[id = 'my_mod']
    Metadata --> Version[version = '1.0.0']
    Metadata --> Name[name = 'My Mod']
    Metadata --> Author[author = 'Developer']
    Metadata --> Priority[load_order = 10]
    
    Dependencies --> Required[required = ['core']]
    Dependencies --> Optional[optional = ['dlc_1']]
    Dependencies --> Conflicts[conflicts = ['old_mod']]
    
    Content --> Units[units = 'rules/units/']
    Content --> Items[items = 'rules/items/']
    Content --> Missions[missions = 'rules/missions/']
    
    Assets --> Images[images = 'assets/images/']
    Assets --> Audio[sounds = 'assets/sounds/']
    
    Hooks --> OnInit[on_init = 'scripts/init.lua']
    Hooks --> OnLoad[on_load = 'scripts/load.lua']
    
    style ModToml fill:#FFD700
```

---

## Content Override System

```mermaid
sequenceDiagram
    participant Core as Core Mod (Priority 1)
    participant Custom as Custom Mod (Priority 10)
    participant Loader as Data Loader
    participant Registry as Content Registry
    
    Core->>Loader: Load units/soldier.toml
    Loader->>Loader: Parse TOML
    Loader->>Registry: register('soldier_rookie', data_v1)
    Registry->>Registry: Store: soldier_rookie → data_v1
    
    Custom->>Loader: Load units/soldier_custom.toml
    Loader->>Loader: Parse TOML (soldier_rookie override)
    Loader->>Registry: register('soldier_rookie', data_v2)
    
    Registry->>Registry: Check existing 'soldier_rookie'
    Registry->>Registry: Replace: soldier_rookie → data_v2
    
    Note over Registry: Final: soldier_rookie uses Custom Mod version
    
    activate Registry
    Registry-->>Loader: Override successful
    deactivate Registry
```

---

## Mod Directory Structure (v2)

```
mods/
├── core/                           # Core game content (Priority 1)
│   ├── mod.toml                   # Manifest
│   ├── rules/                     # TOML content
│   │   ├── units/
│   │   │   ├── soldiers.toml
│   │   │   ├── aliens.toml
│   │   │   └── civilians.toml
│   │   ├── items/
│   │   │   ├── weapons.toml
│   │   │   ├── armor.toml
│   │   │   └── equipment.toml
│   │   ├── facilities/
│   │   │   └── base_facilities.toml
│   │   ├── research/
│   │   │   └── tech_tree.toml
│   │   ├── missions/
│   │   │   └── mission_types.toml
│   │   └── geoscape/
│   │       ├── regions.toml
│   │       └── countries.toml
│   ├── assets/                    # Binary assets
│   │   ├── images/
│   │   └── sounds/
│   ├── mapblocks/                 # Map pieces
│   └── tilesets/                  # Terrain graphics
│
└── custom_mod/                    # User mod (Priority 10+)
    ├── mod.toml
    ├── rules/
    │   └── units/
    │       └── custom_soldiers.toml
    └── assets/
        └── images/
```

---

## Content Validation Flow

```mermaid
graph LR
    Content[TOML Content] --> Parse[Parse TOML]
    
    Parse --> TypeCheck{Type Valid?}
    
    TypeCheck -->|Invalid| Error1[Type Error]
    TypeCheck -->|Valid| RangeCheck{Values in Range?}
    
    RangeCheck -->|Invalid| Error2[Range Error]
    RangeCheck -->|Valid| RefCheck{References Valid?}
    
    RefCheck -->|Invalid| Error3[Reference Error]
    RefCheck -->|Valid| UniqueCheck{ID Unique?}
    
    UniqueCheck -->|Duplicate| Warning[Override Warning]
    UniqueCheck -->|Unique| Success[Validation Success]
    
    Warning --> Success
    
    Error1 --> Log[Log to Console]
    Error2 --> Log
    Error3 --> Log
    
    Log --> StrictMode{Strict Mode?}
    StrictMode -->|Yes| Abort[Abort Loading]
    StrictMode -->|No| Skip[Skip Entry]
    
    Success --> Register[Register Content]
    Skip --> Register
    
    style Success fill:#90EE90
    style Error1 fill:#FF6B6B
    style Error2 fill:#FF6B6B
    style Error3 fill:#FF6B6B
    style Abort fill:#FF0000
```

---

## Mod Load Order

| Priority | Mod Type | Purpose | Example |
|----------|----------|---------|---------|
| **1** | Core | Base game content | `mods/core/` |
| **10** | Balance | Stat adjustments | `mods/balance_patch/` |
| **20** | Content | New units/items | `mods/new_weapons/` |
| **30** | Overhaul | Major changes | `mods/total_conversion/` |
| **50** | Cosmetic | Graphics/sounds | `mods/hd_textures/` |
| **100** | Debug | Dev tools | `mods/debug_mode/` |

---

## Content Registry

```mermaid
graph TD
    Registry[Content Registry] --> Units[Units Registry]
    Registry --> Items[Items Registry]
    Registry --> Facilities[Facilities Registry]
    Registry --> Research[Research Registry]
    Registry --> Missions[Missions Registry]
    
    Units --> UnitData1[soldier_rookie]
    Units --> UnitData2[alien_sectoid]
    
    Items --> ItemData1[rifle]
    Items --> ItemData2[laser_rifle]
    
    Facilities --> FacilData1[power_generator]
    Facilities --> FacilData2[workshop]
    
    Research --> ResearchData1[laser_weapons]
    Research --> ResearchData2[alien_alloys]
    
    Missions --> MissionData1[crash_site]
    Missions --> MissionData2[terror_mission]
    
    style Registry fill:#FFD700
    style Units fill:#E0BBE4
    style Items fill:#87CEEB
    style Facilities fill:#90EE90
    style Research fill:#FFB6C1
    style Missions fill:#FFA500
```

---

## Asset Loading

```mermaid
sequenceDiagram
    participant Mod as Mod System
    participant Asset as Asset Manager
    participant Cache as Asset Cache
    participant Disk
    
    Mod->>Asset: loadImage('units/soldier.png')
    
    Asset->>Cache: check('units/soldier.png')
    
    alt In Cache
        Cache-->>Asset: Return cached image
        Asset-->>Mod: Image data
    else Not in Cache
        Asset->>Disk: Read file
        Disk-->>Asset: Raw data
        
        Asset->>Asset: Decode PNG
        Asset->>Asset: Create texture
        
        Asset->>Cache: store('units/soldier.png', texture)
        
        Asset-->>Mod: Image data
    end
```

---

## Mod Configuration Example

```toml
# mod.toml
[metadata]
id = "custom_soldiers"
name = "Custom Soldier Pack"
version = "1.0.0"
author = "ModAuthor"
description = "Adds new soldier classes"
format_version = 2
engine_version = "1.0.0"

[load_order]
priority = 20

[dependencies]
required = ["core"]
optional = ["balance_mod"]
conflicts = ["old_soldiers"]

[content]
units = "rules/units/"
items = "rules/items/"

[assets]
images = "assets/images/"
sounds = "assets/sounds/"

[hooks]
on_init = "scripts/init.lua"
```

---

## Error Handling

| Error Type | Severity | Action | Example |
|------------|----------|--------|---------|
| **Parse Error** | Critical | Skip mod | Invalid TOML syntax |
| **Type Error** | Critical | Skip entry | String where int expected |
| **Range Error** | Warning | Use default | HP = -10 |
| **Reference Error** | Warning | Skip entry | Unknown weapon_id |
| **Duplicate ID** | Info | Override | soldier_rookie redefined |
| **Missing Dependency** | Critical | Skip mod | Required mod not found |

---

**End of Mod System Architecture**

