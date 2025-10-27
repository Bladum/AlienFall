# Modding System Architecture

**System:** Modding Framework & Tools  
**Date:** 2025-10-27  
**Status:** Complete

---

## Overview

Comprehensive modding system allowing custom content, overrides, and extensions through TOML files and Lua scripts.

---

## Modding Architecture

```mermaid
graph TB
    subgraph "Modding System"
        ModAPI[Mod API]
        
        subgraph "Content Types"
            Units[Units Mods]
            Items[Items Mods]
            Missions[Missions Mods]
            Research[Research Mods]
            Graphics[Graphics Mods]
            Scripts[Script Mods]
        end
        
        subgraph "Mod Tools"
            Validator[Mod Validator]
            Editor[Mod Editor]
            Packager[Mod Packager]
            Workshop[Workshop Integration]
        end
        
        subgraph "Loading"
            Scanner[Mod Scanner]
            Loader[Mod Loader]
            Override[Override System]
        end
    end
    
    ModAPI --> Units
    ModAPI --> Items
    ModAPI --> Missions
    ModAPI --> Research
    ModAPI --> Graphics
    ModAPI --> Scripts
    
    Validator --> Scanner
    Scanner --> Loader
    Loader --> Override
    
    Editor --> Packager
    Packager --> Workshop
    
    style ModAPI fill:#FFD700
    style Loader fill:#87CEEB
    style Workshop fill:#90EE90
```

---

## Mod Structure (v2)

```mermaid
graph TD
    Mod[Mod Directory] --> Manifest[mod.toml]
    Mod --> Content[content/]
    Mod --> Assets[assets/]
    Mod --> Scripts[scripts/]
    Mod --> Docs[README.md]
    
    Manifest --> Metadata[Metadata Section]
    Manifest --> Deps[Dependencies]
    Manifest --> Paths[Content Paths]
    
    Content --> Units[units/]
    Content --> Items[items/]
    Content --> Missions[missions/]
    Content --> Research[research/]
    
    Assets --> Images[images/]
    Assets --> Sounds[sounds/]
    Assets --> Tilesets[tilesets/]
    
    Scripts --> Hooks[hooks/]
    Scripts --> Custom[custom/]
    
    style Mod fill:#FFD700
    style Manifest fill:#87CEEB
```

---

## Mod Manifest (mod.toml)

```toml
# Mod Manifest Example

[metadata]
id = "awesome_weapons_mod"
name = "Awesome Weapons Pack"
version = "1.2.0"
author = "ModAuthor"
description = "Adds 20 new futuristic weapons"
format_version = 2
engine_version = "1.0.0"
homepage = "https://example.com/mod"
tags = ["weapons", "balance", "content"]

[load_order]
priority = 25
load_after = ["core"]
load_before = ["balance_mod"]

[dependencies]
required = ["core@1.0.0"]
optional = ["advanced_armors@2.0.0"]
conflicts = ["old_weapons_mod"]

[content]
units = "content/units/"
items = "content/items/"
weapons = "content/weapons/"

[assets]
images = "assets/images/"
sounds = "assets/sounds/"

[hooks]
on_init = "scripts/init.lua"
on_load = "scripts/load.lua"
on_save = "scripts/save.lua"

[compatibility]
min_game_version = "1.0.0"
max_game_version = "1.9.9"
```

---

## Mod Loading Pipeline

```mermaid
sequenceDiagram
    participant Game
    participant ModMgr as Mod Manager
    participant Scanner
    participant Validator
    participant Loader
    participant Content as Content Registry
    
    Game->>ModMgr: Initialize Mods
    ModMgr->>Scanner: Scan mods/ directory
    
    Scanner->>Scanner: Find all mod.toml files
    Scanner-->>ModMgr: Return mod list
    
    loop For Each Mod
        ModMgr->>Validator: Validate mod
        
        alt Valid
            Validator-->>ModMgr: Valid
            ModMgr->>ModMgr: Add to load queue
        else Invalid
            Validator-->>ModMgr: Errors
            ModMgr->>ModMgr: Log errors & skip
        end
    end
    
    ModMgr->>ModMgr: Sort by priority
    ModMgr->>ModMgr: Resolve dependencies
    
    loop For Each Mod (sorted)
        ModMgr->>Loader: Load mod content
        Loader->>Loader: Parse TOML files
        Loader->>Content: Register content
        
        alt Overrides Existing
            Content->>Content: Replace content
        else New Content
            Content->>Content: Add content
        end
        
        Loader->>Loader: Load assets
        Loader->>Loader: Run on_init hooks
    end
    
    ModMgr-->>Game: Mods Loaded
```

---

## Content Override System

```mermaid
graph LR
    Core[Core Mod<br/>Priority: 1] --> Content1[soldier_rookie v1.0]
    
    Mod1[Balance Mod<br/>Priority: 10] --> Content2[soldier_rookie v1.1<br/>Override]
    
    Mod2[Custom Mod<br/>Priority: 20] --> Content3[soldier_rookie v2.0<br/>Override]
    
    Content1 --> Registry[Content Registry]
    Content2 -.->|Replaces| Content1
    Content3 -.->|Replaces| Content2
    
    Registry --> FinalContent[soldier_rookie v2.0<br/>FINAL]
    
    FinalContent --> Game[Game Uses This]
    
    style Core fill:#90EE90
    style Mod1 fill:#FFD700
    style Mod2 fill:#E0BBE4
    style FinalContent fill:#87CEEB
```

---

## Mod Categories

```mermaid
graph TD
    Mods[Mod Types] --> ContentMods[Content Mods]
    Mods --> BalanceMods[Balance Mods]
    Mods --> GraphicMods[Graphics Mods]
    Mods --> OverhaulMods[Overhaul Mods]
    Mods --> QoLMods[QoL Mods]
    
    ContentMods --> NewUnits[New Units]
    ContentMods --> NewWeapons[New Weapons]
    ContentMods --> NewMissions[New Missions]
    
    BalanceMods --> StatTweaks[Stat Adjustments]
    BalanceMods --> EconomyTweak[Economy Changes]
    
    GraphicMods --> HDTextures[HD Textures]
    GraphicMods --> NewSprites[New Sprites]
    
    OverhaulMods --> TotalConversion[Total Conversion]
    OverhaulMods --> MajorRework[Major Rework]
    
    QoLMods --> UIEnhancements[UI Enhancements]
    QoLMods --> Shortcuts[Keyboard Shortcuts]
    
    style Mods fill:#FFD700
    style ContentMods fill:#90EE90
    style GraphicMods fill:#87CEEB
    style OverhaulMods fill:#FF6B6B
```

---

## Script Hooks

```mermaid
graph LR
    Hooks[Mod Hooks] --> OnInit[on_init<br/>First Load]
    Hooks --> OnLoad[on_load<br/>Save Load]
    Hooks --> OnSave[on_save<br/>Before Save]
    Hooks --> OnMission[on_mission_start<br/>Mission Start]
    Hooks --> OnCombat[on_combat_turn<br/>Each Turn]
    Hooks --> OnMonth[on_month_end<br/>Monthly]
    
    OnInit --> Custom1[Custom Initialization]
    OnLoad --> Custom2[Load Extra Data]
    OnSave --> Custom3[Save Custom State]
    OnMission --> Custom4[Mission Setup]
    OnCombat --> Custom5[Custom AI]
    OnMonth --> Custom6[Custom Events]
    
    style Hooks fill:#FFD700
    style Custom1 fill:#87CEEB
```

### Hook Example

```lua
-- scripts/init.lua

local mod = {
    name = "Awesome Weapons Mod",
    version = "1.2.0"
}

function mod.on_init()
    print("[" .. mod.name .. "] Initializing...")
    
    -- Register custom event listeners
    EventBus:registerListener("unit.created", mod.on_unit_created)
    
    -- Add custom data
    GameData.custom_weapons = mod.load_weapons()
    
    print("[" .. mod.name .. "] Loaded " .. #GameData.custom_weapons .. " weapons")
end

function mod.on_unit_created(event)
    local unit = event.unit
    -- Custom logic when unit is created
    if unit.type == "soldier" then
        unit:addPerk("weapon_specialist")
    end
end

function mod.load_weapons()
    -- Load custom weapon data
    return {
        {id = "plasma_rifle_mk2", damage = 60, ...},
        {id = "graviton_beam", damage = 80, ...}
    }
end

return mod
```

---

## Mod Validation

```mermaid
graph TD
    Validate[Validate Mod] --> CheckManifest{mod.toml Valid?}
    
    CheckManifest -->|No| Error1[Invalid Manifest]
    CheckManifest -->|Yes| CheckVersion{Engine Version?}
    
    CheckVersion -->|Incompatible| Error2[Version Mismatch]
    CheckVersion -->|Compatible| CheckDeps{Dependencies?}
    
    CheckDeps -->|Missing| Error3[Missing Dependencies]
    CheckDeps -->|Conflicts| Error4[Mod Conflicts]
    CheckDeps -->|OK| CheckContent{Content Valid?}
    
    CheckContent -->|No| Error5[Invalid Content]
    CheckContent -->|Yes| CheckAssets{Assets Valid?}
    
    CheckAssets -->|No| Warning1[Missing Assets]
    CheckAssets -->|Yes| Success[Mod Valid]
    
    Error1 --> Report[Error Report]
    Error2 --> Report
    Error3 --> Report
    Error4 --> Report
    Error5 --> Report
    Warning1 --> Success
    
    Report --> Log[Log to Console]
    Success --> LoadMod[Load Mod]
    
    style Validate fill:#90EE90
    style Success fill:#87CEEB
    style Error1 fill:#FF6B6B
```

---

## Mod Manager UI

```mermaid
stateDiagram-v2
    [*] --> ModList: Open Mod Manager
    
    ModList --> ViewDetails: Select Mod
    
    state ViewDetails {
        [*] --> ShowInfo
        ShowInfo --> ShowContent
        ShowContent --> ShowDeps
        ShowDeps --> [*]
    }
    
    ViewDetails --> ModList: Back
    
    ModList --> Enable: Enable Mod
    ModList --> Disable: Disable Mod
    ModList --> Uninstall: Uninstall Mod
    ModList --> Browse: Browse Workshop
    
    Enable --> ModList: Enabled
    Disable --> ModList: Disabled
    Uninstall --> ModList: Removed
    
    Browse --> Workshop: Open Workshop
    Workshop --> Download: Download Mod
    Download --> Install: Install
    Install --> ModList: Installed
```

---

## Workshop Integration

```mermaid
sequenceDiagram
    participant User
    participant Game
    participant Workshop
    participant ModMgr as Mod Manager
    
    User->>Game: Browse Workshop
    Game->>Workshop: Request mod list
    Workshop-->>Game: Return available mods
    
    Game->>User: Display mods
    User->>Game: Select mod
    
    Game->>Workshop: Download mod
    Workshop-->>Game: Mod package
    
    Game->>ModMgr: Install mod
    ModMgr->>ModMgr: Extract package
    ModMgr->>ModMgr: Validate mod
    
    alt Valid
        ModMgr->>ModMgr: Register mod
        ModMgr-->>Game: Install success
        Game->>User: Mod installed!
    else Invalid
        ModMgr-->>Game: Validation failed
        Game->>User: Installation failed
    end
```

---

## Mod Creation Workflow

```mermaid
graph TD
    Start[Create Mod] --> Structure[Create Directory Structure]
    
    Structure --> CreateManifest[Create mod.toml]
    CreateManifest --> AddContent[Add Content Files]
    
    AddContent --> Units[Add Units TOML]
    AddContent --> Items[Add Items TOML]
    AddContent --> Assets[Add Assets]
    
    Units --> Validate[Validate Mod]
    Items --> Validate
    Assets --> Validate
    
    Validate --> Test[Test in Game]
    
    Test --> Issues{Issues Found?}
    
    Issues -->|Yes| Fix[Fix Issues]
    Issues -->|No| Package[Package Mod]
    
    Fix --> Validate
    
    Package --> Distribute[Distribute]
    
    Distribute --> Workshop[Upload to Workshop]
    Distribute --> Manual[Manual Distribution]
    
    style Start fill:#90EE90
    style Package fill:#87CEEB
    style Workshop fill:#FFD700
```

---

## Mod Compatibility

| Aspect | Strategy | Example |
|--------|----------|---------|
| **Version** | Semantic versioning | 1.2.3 |
| **Dependencies** | Explicit declaration | required = ["core@1.0.0"] |
| **Conflicts** | Conflict detection | conflicts = ["old_mod"] |
| **Overrides** | Priority-based | priority = 25 |
| **API** | Stable mod API | ModAPI v1.0 |

---

## Best Practices

```mermaid
graph LR
    BestPractices[Mod Best Practices] --> Documentation[Good Documentation]
    BestPractices --> Testing[Thorough Testing]
    BestPractices --> Compatibility[Compatibility]
    BestPractices --> Performance[Performance]
    
    Documentation --> README[README.md]
    Documentation --> Changelog[CHANGELOG.md]
    Documentation --> Examples[Example Files]
    
    Testing --> UnitTests[Unit Tests]
    Testing --> Integration[Integration Tests]
    Testing --> Playtest[Playtesting]
    
    Compatibility --> VersionCheck[Version Checking]
    Compatibility --> DepManagement[Dependency Management]
    Compatibility --> Backwards[Backwards Compatible]
    
    Performance --> Optimize[Optimized Assets]
    Performance --> LazyLoad[Lazy Loading]
    Performance --> Cache[Caching]
    
    style BestPractices fill:#FFD700
```

---

## Mod API Reference

### Content Registration

```lua
-- Register custom unit
ModAPI.registerUnit({
    id = "custom_soldier",
    name = "Elite Soldier",
    hp = 35,
    -- ...more properties
})

-- Register custom weapon
ModAPI.registerWeapon({
    id = "plasma_cannon",
    name = "Plasma Cannon",
    damage = 60,
    -- ...more properties
})

-- Register custom mission
ModAPI.registerMission({
    id = "custom_terror",
    name = "Urban Terror",
    type = "terror",
    -- ...more properties
})
```

### Event Listeners

```lua
-- Listen to game events
ModAPI.on("unit.killed", function(event)
    print("Unit killed: " .. event.unit_id)
end)

ModAPI.on("mission.complete", function(event)
    print("Mission result: " .. event.result)
end)
```

---

**End of Modding System Architecture**

