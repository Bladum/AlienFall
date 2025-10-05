# Alien Fall Architecture Diagrams

**Version:** 1.0  
**Last Updated:** September 30, 2025  
**Format:** Mermaid Diagrams (viewable in GitHub, VS Code, and compatible tools)

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Service Dependencies](#service-dependencies)
3. [Game State Machine](#game-state-machine)
4. [Data Flow Diagrams](#data-flow-diagrams)
5. [Class Hierarchies](#class-hierarchies)
6. [Combat System Flow](#combat-system-flow)
7. [Mod Loading Pipeline](#mod-loading-pipeline)

---

## System Overview

### High-Level Architecture

```mermaid
graph TB
    subgraph "Presentation Layer"
        UI[UI Screens]
        Widgets[Widgets]
        Renderer[Renderer]
    end
    
    subgraph "Game Logic Layer"
        GameState[Game State Manager]
        Geoscape[Geoscape System]
        Battlescape[Battlescape System]
        Basescape[Basescape System]
        Economy[Economy System]
    end
    
    subgraph "Service Layer"
        EventBus[Event Bus]
        Logger[Logger]
        RNG[RNG Service]
        AssetCache[Asset Cache]
        SaveLoad[Save/Load]
        Telemetry[Telemetry]
    end
    
    subgraph "Data Layer"
        DataRegistry[Data Registry]
        ModLoader[Mod Loader]
        Config[Configuration]
        TOML[TOML Files]
    end
    
    subgraph "Engine Layer"
        Love2D[Love2D Framework]
    end
    
    UI --> GameState
    Widgets --> EventBus
    Renderer --> AssetCache
    
    GameState --> Geoscape
    GameState --> Battlescape
    GameState --> Basescape
    
    Geoscape --> Economy
    Battlescape --> RNG
    Basescape --> Economy
    
    Economy --> DataRegistry
    RNG --> Logger
    AssetCache --> Love2D
    
    DataRegistry --> ModLoader
    ModLoader --> TOML
    Config --> TOML
    
    SaveLoad --> DataRegistry
    Telemetry --> Logger
```

---

## Service Dependencies

### Service Registry and Dependencies

```mermaid
graph LR
    ServiceRegistry[Service Registry] --> EventBus[Event Bus]
    ServiceRegistry --> Logger[Logger]
    ServiceRegistry --> Telemetry[Telemetry]
    ServiceRegistry --> RNG[RNG Service]
    ServiceRegistry --> AssetCache[Asset Cache]
    ServiceRegistry --> SaveLoad[Save/Load Service]
    
    RNG --> Logger
    AssetCache --> Logger
    AssetCache --> Telemetry
    SaveLoad --> Logger
    SaveLoad --> EventBus
    Telemetry --> Logger
    
    style ServiceRegistry fill:#ff9
    style Logger fill:#9f9
    style EventBus fill:#9ff
```

### Core Service Flow

```mermaid
sequenceDiagram
    participant Main
    participant ServiceRegistry
    participant EventBus
    participant Logger
    participant RNG
    
    Main->>ServiceRegistry: initialize(config)
    ServiceRegistry->>Logger: new(config)
    ServiceRegistry->>EventBus: new()
    ServiceRegistry->>RNG: new(config)
    
    RNG->>Logger: info("RNG initialized")
    
    Main->>ServiceRegistry: get("rng")
    ServiceRegistry-->>Main: RNG instance
    
    Main->>EventBus: publish("game:started")
    EventBus->>Logger: debug("Event published")
```

---

## Game State Machine

### Main Game States

```mermaid
stateDiagram-v2
    [*] --> MainMenu
    
    MainMenu --> NewGame: Start New
    MainMenu --> LoadGame: Load Save
    MainMenu --> Options: Settings
    MainMenu --> [*]: Quit
    
    NewGame --> Geoscape: Initialize
    LoadGame --> Geoscape: Load State
    
    Geoscape --> Basescape: Manage Base
    Geoscape --> Battlescape: Launch Mission
    Geoscape --> Research: View Tech
    Geoscape --> Interception: Intercept UFO
    
    Basescape --> Geoscape: Return
    Battlescape --> Geoscape: Mission End
    Research --> Geoscape: Return
    Interception --> Battlescape: Engage
    Interception --> Geoscape: Abort
    
    Battlescape --> MissionDebriefing: Complete
    MissionDebriefing --> Geoscape: Continue
    
    Geoscape --> PauseMenu: Pause
    PauseMenu --> Geoscape: Resume
    PauseMenu --> SaveGame: Save
    PauseMenu --> MainMenu: Quit to Menu
    
    SaveGame --> PauseMenu: Done
```

### Screen State Lifecycle

```mermaid
sequenceDiagram
    participant GameState
    participant OldScreen
    participant NewScreen
    participant EventBus
    
    GameState->>OldScreen: leave()
    OldScreen->>EventBus: unsubscribeAll(self)
    OldScreen->>OldScreen: cleanup()
    
    GameState->>NewScreen: enter(params)
    NewScreen->>EventBus: subscribe("events", callback, self)
    NewScreen->>NewScreen: initialize()
    
    loop Game Loop
        GameState->>NewScreen: update(dt)
        GameState->>NewScreen: draw()
    end
    
    GameState->>NewScreen: keypressed(key)
    NewScreen->>EventBus: publish("action:triggered")
```

---

## Data Flow Diagrams

### Mod Loading Pipeline

```mermaid
flowchart TD
    Start([Game Start]) --> ScanMods[Scan mods/ Directory]
    ScanMods --> ValidateStructure{Validate Each Mod Structure}
    
    ValidateStructure -->|Invalid| LogError[Log Error]
    ValidateStructure -->|Valid| ParseManifest[Parse main.toml]
    
    LogError --> Skip[Skip Mod]
    
    ParseManifest --> CheckDeps{Check Dependencies}
    CheckDeps -->|Missing| LogDepError[Log Dependency Error]
    CheckDeps -->|OK| AddToList[Add to Mod List]
    
    LogDepError --> Skip
    
    AddToList --> AllModsScanned{All Mods Scanned?}
    AllModsScanned -->|No| ScanMods
    AllModsScanned -->|Yes| ResolveDeps[Resolve Dependencies]
    
    ResolveDeps --> SortMods[Topological Sort]
    SortMods --> LoadContent[Load Content Files]
    
    LoadContent --> RegisterData[Register in Data Registry]
    RegisterData --> LoadHooks[Load Lua Hooks]
    LoadHooks --> Complete([Mods Loaded])
    
    Skip --> AllModsScanned
```

### Combat Damage Calculation

```mermaid
flowchart LR
    Start([Attack Action]) --> GetWeapon[Get Weapon Stats]
    GetWeapon --> GetTarget[Get Target Stats]
    
    GetTarget --> RollAccuracy{Accuracy Roll}
    RollAccuracy -->|Miss| ApplyMiss[Apply Miss]
    RollAccuracy -->|Hit| CalcBaseDamage[Calculate Base Damage]
    
    CalcBaseDamage --> ApplyModifiers[Apply Modifiers]
    ApplyModifiers --> ApplyArmor[Apply Armor Reduction]
    ApplyArmor --> ApplyCover[Apply Cover Reduction]
    ApplyCover --> ApplyResistance[Apply Damage Resistance]
    
    ApplyResistance --> Hooks{Mod Hooks?}
    Hooks -->|Yes| RunHooks[Run damage_calculated Hooks]
    Hooks -->|No| FinalDamage[Final Damage]
    
    RunHooks --> FinalDamage
    FinalDamage --> ApplyDamage[Apply to Target HP]
    ApplyDamage --> CheckDeath{HP <= 0?}
    
    CheckDeath -->|Yes| TriggerDeath[Trigger unit:died Event]
    CheckDeath -->|No| UpdateUI[Update UI]
    
    TriggerDeath --> UpdateUI
    ApplyMiss --> UpdateUI
    UpdateUI --> End([Complete])
```

### Save/Load Flow

```mermaid
flowchart TD
    Save([Save Game]) --> GatherState[Gather Game State]
    Load([Load Game]) --> SelectSlot[Select Save Slot]
    
    GatherState --> SerializeUnits[Serialize Units]
    SerializeUnits --> SerializeBases[Serialize Bases]
    SerializeBases --> SerializeWorld[Serialize World State]
    SerializeWorld --> SerializeRNG[Serialize RNG State]
    SerializeRNG --> SerializeEconomy[Serialize Economy]
    
    SerializeEconomy --> WriteFiles[Write TOML Files]
    WriteFiles --> Compress{Compress?}
    Compress -->|Yes| CompressData[Compress to ZIP]
    Compress -->|No| SaveComplete([Save Complete])
    CompressData --> SaveComplete
    
    SelectSlot --> ValidateFiles{Files Valid?}
    ValidateFiles -->|No| ShowError[Show Error Message]
    ValidateFiles -->|Yes| ReadFiles[Read TOML Files]
    
    ReadFiles --> CheckVersion{Version Compatible?}
    CheckVersion -->|No| RunMigration[Run Migration]
    CheckVersion -->|Yes| DeserializeData[Deserialize Data]
    
    RunMigration --> DeserializeData
    DeserializeData --> RestoreState[Restore Game State]
    RestoreState --> ValidateState{State Valid?}
    
    ValidateState -->|No| ShowError
    ValidateState -->|Yes| LoadComplete([Load Complete])
    
    ShowError --> End([Cancelled])
```

---

## Class Hierarchies

### Widget Inheritance

```mermaid
classDiagram
    class Widget {
        <<abstract>>
        +number x
        +number y
        +number width
        +number height
        +boolean visible
        +boolean enabled
        +update(dt)
        +draw()
        +mousepressed(mx, my, button)
        +mousereleased(mx, my, button)
        +mousemoved(mx, my)
    }
    
    class Button {
        +string text
        +function callback
        +boolean hovered
        +boolean pressed
        +click()
    }
    
    class Checkbox {
        +string label
        +boolean checked
        +function onChange
        +toggle()
    }
    
    class Table {
        +array columns
        +array data
        +number sortColumn
        +number scrollOffset
        +setData(data)
        +sort(column)
        +scroll(delta)
    }
    
    class ComboBox {
        +array options
        +number selectedIndex
        +boolean expanded
        +select(index)
        +expand()
        +collapse()
    }
    
    class Tooltip {
        +string text
        +number fadeTime
        +show(text, x, y)
        +hide()
    }
    
    Widget <|-- Button
    Widget <|-- Checkbox
    Widget <|-- Table
    Widget <|-- ComboBox
    Widget <|-- Tooltip
```

### Entity Component System

```mermaid
classDiagram
    class Entity {
        +number id
        +table components
        +addComponent(component)
        +getComponent(type)
        +hasComponent(type)
        +removeComponent(type)
    }
    
    class Component {
        <<interface>>
        +string type
    }
    
    class PositionComponent {
        +number x
        +number y
        +number z
    }
    
    class StatsComponent {
        +number health
        +number maxHealth
        +number timeUnits
        +number accuracy
        +number strength
    }
    
    class InventoryComponent {
        +array items
        +addItem(item)
        +removeItem(item)
        +getItem(slot)
    }
    
    class AIComponent {
        +string behavior
        +table state
        +update(dt)
    }
    
    class RenderComponent {
        +Image sprite
        +string animation
        +number rotation
    }
    
    Entity --> Component
    Component <|-- PositionComponent
    Component <|-- StatsComponent
    Component <|-- InventoryComponent
    Component <|-- AIComponent
    Component <|-- RenderComponent
```

---

## Combat System Flow

### Turn-Based Combat Loop

```mermaid
sequenceDiagram
    participant Player
    participant BattleState
    participant Unit
    participant ActionSystem
    participant PathFinding
    participant CombatResolver
    
    Player->>BattleState: Start Turn
    BattleState->>Unit: Restore Action Points
    
    loop Until Turn End
        Player->>BattleState: Select Unit
        BattleState->>Unit: Activate
        
        Player->>ActionSystem: Move Command
        ActionSystem->>PathFinding: findPath(start, goal)
        PathFinding-->>ActionSystem: path
        ActionSystem->>Unit: Move Along Path
        Unit->>Unit: Consume AP
        
        Player->>ActionSystem: Attack Command
        ActionSystem->>CombatResolver: resolveAttack(attacker, target)
        CombatResolver->>CombatResolver: Calculate Hit Chance
        CombatResolver->>CombatResolver: Calculate Damage
        CombatResolver->>Unit: Apply Damage
        Unit-->>CombatResolver: Result
        CombatResolver-->>ActionSystem: Attack Result
        ActionSystem-->>Player: Display Result
        
        Player->>BattleState: End Turn
    end
    
    BattleState->>BattleState: Check Victory Conditions
    alt Mission Complete
        BattleState->>Player: Show Debriefing
    else Continue
        BattleState->>BattleState: Start Enemy Turn
    end
```

### AI Decision Making

```mermaid
flowchart TD
    Start([AI Turn Start]) --> GetUnits[Get AI Units]
    GetUnits --> NextUnit{More Units?}
    
    NextUnit -->|No| EndTurn([End AI Turn])
    NextUnit -->|Yes| SelectUnit[Select Next Unit]
    
    SelectUnit --> HasAP{Has AP?}
    HasAP -->|No| NextUnit
    HasAP -->|Yes| ScanEnv[Scan Environment]
    
    ScanEnv --> EnemyVisible{Enemy Visible?}
    
    EnemyVisible -->|Yes| InRange{In Attack Range?}
    InRange -->|Yes| Attack[Execute Attack]
    InRange -->|No| MoveCloser[Move Toward Enemy]
    
    EnemyVisible -->|No| InCover{In Cover?}
    InCover -->|Yes| Overwatch[Overwatch]
    InCover -->|No| FindCover[Find Cover]
    
    Attack --> ConsumeAP[Consume Action Points]
    MoveCloser --> ConsumeAP
    Overwatch --> ConsumeAP
    FindCover --> ConsumeAP
    
    ConsumeAP --> HasAP
```

---

## Performance Cache Architecture

### Cache System Structure

```mermaid
graph TB
    subgraph "Performance Cache"
        PathCache[Path Cache<br/>TTL: 5 turns]
        LOSCache[LOS Cache<br/>TTL: 3 turns]
        DetectionCache[Detection Cache<br/>TTL: 1 day]
    end
    
    subgraph "Systems"
        Pathfinding[Pathfinding System]
        LOS[Line of Sight System]
        Detection[Detection System]
    end
    
    subgraph "Cache Operations"
        LRU[LRU Eviction]
        Stats[Statistics Tracking]
        Invalidation[Cache Invalidation]
    end
    
    Pathfinding --> PathCache
    LOS --> LOSCache
    Detection --> DetectionCache
    
    PathCache --> LRU
    LOSCache --> LRU
    DetectionCache --> LRU
    
    PathCache --> Stats
    LOSCache --> Stats
    DetectionCache --> Stats
    
    PathCache --> Invalidation
    LOSCache --> Invalidation
    DetectionCache --> Invalidation
    
    style PathCache fill:#f9f
    style LOSCache fill:#9ff
    style DetectionCache fill:#ff9
```

### Cache Lifecycle

```mermaid
sequenceDiagram
    participant System
    participant Cache
    participant LRU
    
    System->>Cache: Request Data (key)
    Cache->>Cache: Check if exists
    
    alt Cache Hit
        Cache->>Cache: Check TTL
        alt Not Expired
            Cache->>Cache: Update Access Time
            Cache-->>System: Return Cached Data
        else Expired
            Cache->>Cache: Invalidate Entry
            Cache-->>System: Return nil (miss)
        end
    else Cache Miss
        Cache-->>System: Return nil
        System->>System: Calculate Data
        System->>Cache: Store Data (key, value)
        
        alt Cache Full
            Cache->>LRU: Evict Oldest
            LRU->>Cache: Entry Removed
        end
        
        Cache->>Cache: Store New Entry
    end
```

---

## Event System Architecture

### Publish-Subscribe Pattern

```mermaid
graph LR
    subgraph "Publishers"
        Combat[Combat System]
        Geoscape[Geoscape System]
        Economy[Economy System]
    end
    
    subgraph "Event Bus"
        EventBus[Event Bus<br/>Central Dispatcher]
    end
    
    subgraph "Subscribers"
        UI[UI System]
        Logger[Logger]
        Telemetry[Telemetry]
        Mods[Mod Hooks]
    end
    
    Combat -->|unit:damaged| EventBus
    Combat -->|turn:ended| EventBus
    Geoscape -->|mission:detected| EventBus
    Economy -->|research:completed| EventBus
    
    EventBus -->|Subscribe| UI
    EventBus -->|Subscribe| Logger
    EventBus -->|Subscribe| Telemetry
    EventBus -->|Subscribe| Mods
    
    style EventBus fill:#ff9
```

---

## Rendering Pipeline

### Frame Rendering Flow

```mermaid
flowchart LR
    Start([love.draw]) --> ClearScreen[Clear Screen]
    ClearScreen --> PushCanvas[Push Canvas]
    
    PushCanvas --> RenderGame[Render Game at 800x600]
    RenderGame --> RenderBG[Render Background]
    RenderBG --> RenderEntities[Render Entities]
    RenderEntities --> RenderUI[Render UI Widgets]
    RenderUI --> RenderTooltips[Render Tooltips]
    
    RenderTooltips --> PopCanvas[Pop Canvas]
    PopCanvas --> ScaleCanvas[Scale Canvas to Window]
    ScaleCanvas --> DrawCanvas[Draw Scaled Canvas]
    
    DrawCanvas --> End([Frame Complete])
```

---

## Data Registry System

### Content Registration

```mermaid
flowchart TD
    Start([Mod Loaded]) --> ParseContent[Parse Content Files]
    ParseContent --> ValidateSchema{Valid Schema?}
    
    ValidateSchema -->|No| LogError[Log Validation Error]
    ValidateSchema -->|Yes| CheckID{ID Unique?}
    
    CheckID -->|No| HandleConflict{Resolution Strategy}
    CheckID -->|Yes| RegisterContent[Register in Registry]
    
    HandleConflict -->|Override| RegisterContent
    HandleConflict -->|Merge| MergeContent[Merge with Existing]
    HandleConflict -->|Error| LogError
    
    MergeContent --> RegisterContent
    RegisterContent --> IndexContent[Build Lookup Indices]
    IndexContent --> Complete([Content Registered])
    
    LogError --> Skip[Skip Content]
    Skip --> Complete
```

---

## Using These Diagrams

### Viewing in VS Code

1. Install **Markdown Preview Mermaid Support** extension
2. Open this file in VS Code
3. Open preview (Ctrl+Shift+V)

### Viewing on GitHub

GitHub natively renders Mermaid diagrams in markdown files.

### Exporting Diagrams

Use online tools like [Mermaid Live Editor](https://mermaid.live/) to export to PNG/SVG.

---

## Maintenance

These diagrams should be updated when:
- Major architectural changes occur
- New systems are added
- Service dependencies change
- Data flow significantly changes

---

**Document Version:** 1.0  
**Last Updated:** September 30, 2025  
**Format:** Mermaid.js Diagrams
