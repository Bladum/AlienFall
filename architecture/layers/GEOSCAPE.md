# Geoscape Architecture

**Layer:** Strategic Layer  
**Date:** 2025-10-27  
**Status:** Complete

---

## Overview

The Geoscape is the strategic world management layer where commanders track global operations, manage missions, and oversee organizational resources.

---

## Layer Architecture

```mermaid
graph TB
    subgraph "Geoscape Layer"
        Screen[Geoscape Screen]
        
        subgraph "Systems"
            WorldMap[World Map System]
            Detection[Detection Manager]
            Calendar[Calendar System]
            Relations[Relations Manager]
            CraftMgmt[Craft Management]
        end
        
        subgraph "Rendering"
            Globe[Globe Renderer]
            UI[Geoscape UI]
            Markers[Mission Markers]
        end
        
        subgraph "Data"
            WorldData[World Geography]
            Nations[Nation Data]
            Bases[Base Locations]
            Missions[Active Missions]
        end
    end
    
    Screen --> WorldMap
    Screen --> Detection
    Screen --> Calendar
    Screen --> Relations
    Screen --> CraftMgmt
    
    WorldMap --> Globe
    WorldMap --> Markers
    Screen --> UI
    
    WorldData --> WorldMap
    Nations --> Relations
    Bases --> CraftMgmt
    Missions --> Markers
    
    style Screen fill:#FFD700
    style WorldMap fill:#87CEEB
    style Detection fill:#90EE90
```

---

## Time Management

```mermaid
stateDiagram-v2
    [*] --> Paused: Init
    
    Paused --> Running: Play Button
    Running --> Paused: Pause Button
    
    state Running {
        [*] --> Normal: Speed x1
        Normal --> Fast: Speed x5
        Normal --> Faster: Speed x30
        Fast --> Normal
        Fast --> Faster
        Faster --> Normal
        Faster --> Fast
    }
    
    Running --> Paused: Mission Alert
    Running --> Paused: Event Triggered
    
    Paused --> [*]: Exit
```

### Time Scale Table

| Speed | Real Time | Game Time | Use Case |
|-------|-----------|-----------|----------|
| **Paused** | 0s | 0 | Mission planning, base management |
| **Normal (x1)** | 1s | 5 seconds | Careful observation |
| **Fast (x5)** | 1s | 25 seconds | Normal play |
| **Faster (x30)** | 1s | 2.5 minutes | Waiting for events |

---

## Mission Detection Flow

```mermaid
graph TD
    DailyUpdate[Daily Update Tick] --> RadarScan[Radar Scan]
    
    RadarScan --> CheckCoverage{In Radar Range?}
    
    CheckCoverage -->|No| NoDetection[No Detection]
    CheckCoverage -->|Yes| RollDetection[Roll Detection Chance]
    
    RollDetection --> Detected{Detected?}
    
    Detected -->|No| PartialInfo[Partial Information]
    Detected -->|Yes| FullInfo[Full Mission Data]
    
    PartialInfo --> UpdateMap[Update Map Marker]
    FullInfo --> UpdateMap
    
    UpdateMap --> NotifyPlayer[Notify Player]
    
    NotifyPlayer --> Alert{Critical Mission?}
    
    Alert -->|Yes| PauseGame[Pause Game]
    Alert -->|No| Continue[Continue Time]
    
    NoDetection --> Continue
    
    style DailyUpdate fill:#90EE90
    style Detected fill:#FFD700
    style PauseGame fill:#FF6B6B
```

---

## World Geography

```mermaid
erDiagram
    WORLD {
        int width
        int height
        table provinces
    }
    
    REGION {
        string id PK
        string name
        string continent
        table countries
    }
    
    COUNTRY {
        string id PK
        string name
        int funding
        int panic_level
        string status
    }
    
    PROVINCE {
        string id PK
        int x
        int y
        string region_id FK
        string biome
        int population
    }
    
    BASE {
        string id PK
        string name
        string province_id FK
        int radar_range
        table facilities
    }
    
    MISSION {
        string id PK
        string type
        string province_id FK
        int expiration_turns
        string status
    }
    
    WORLD ||--o{ REGION : "contains"
    REGION ||--o{ COUNTRY : "contains"
    REGION ||--o{ PROVINCE : "contains"
    PROVINCE ||--o{ BASE : "hosts"
    PROVINCE ||--o{ MISSION : "spawns"
```

---

## Craft Management

```mermaid
sequenceDiagram
    participant Player
    participant Geo as Geoscape
    participant Craft
    participant Mission
    
    Player->>Geo: Select Mission
    Geo->>Geo: Show Available Crafts
    
    Player->>Geo: Select Craft
    Geo->>Craft: Check Status
    
    Craft-->>Geo: Status: Ready, Fuel: 100%
    
    Player->>Geo: Deploy Craft
    Geo->>Craft: Set Destination
    
    Craft->>Craft: Calculate Travel Time
    Craft->>Craft: Deduct Fuel
    
    loop Travel
        Craft->>Craft: Move Toward Destination
        Craft->>Geo: Update Position
    end
    
    Craft->>Mission: Arrive at Mission
    Mission-->>Geo: Ready to Start
    
    Geo->>Player: Show Mission Briefing
```

---

## Radar Coverage System

```mermaid
graph TD
    Base1[Base 1<br/>Radar Range: 1500km] --> Coverage1[Coverage Area 1]
    Base2[Base 2<br/>Radar Range: 2000km] --> Coverage2[Coverage Area 2]
    Satellite[Satellite<br/>Global Coverage] --> CoverageGlobal[Global Area]
    
    Coverage1 --> Union[Union of All Coverage]
    Coverage2 --> Union
    CoverageGlobal --> Union
    
    Union --> DetectionMap[Detection Map]
    
    Mission1[Mission in Range] -.->|Detected| DetectionMap
    Mission2[Mission Out of Range] -.->|Hidden| DetectionMap
    
    style Base1 fill:#90EE90
    style Base2 fill:#90EE90
    style Satellite fill:#87CEEB
    style Mission1 fill:#FFD700
    style Mission2 fill:#FF6B6B
```

---

## Nation Relations

```mermaid
graph LR
    Events[Game Events] --> Positive[Positive Events]
    Events --> Negative[Negative Events]
    
    Positive --> Success[Mission Success<br/>+15 Approval]
    Positive --> Defend[Defend Territory<br/>+10 Approval]
    
    Negative --> UFO[UFO Activity<br/>-5 Approval]
    Negative --> Terror[Terror Mission<br/>-20 Approval]
    Negative --> Fail[Mission Failure<br/>-10 Approval]
    
    Success --> UpdateRelations[Update Nation Relations]
    Defend --> UpdateRelations
    UFO --> UpdateRelations
    Terror --> UpdateRelations
    Fail --> UpdateRelations
    
    UpdateRelations --> CheckLevel{Panic Level}
    
    CheckLevel -->|0-20| Green[Green: Satisfied<br/>Funding: 100%]
    CheckLevel -->|21-50| Yellow[Yellow: Concerned<br/>Funding: 80%]
    CheckLevel -->|51-80| Orange[Orange: Alarmed<br/>Funding: 60%]
    CheckLevel -->|81-99| Red[Red: Critical<br/>Funding: 40%]
    CheckLevel -->|100| Defect[Nation Defects<br/>Funding: 0%]
    
    style Success fill:#90EE90
    style Terror fill:#FF6B6B
    style Green fill:#90EE90
    style Yellow fill:#FFD700
    style Orange fill:#FFA500
    style Red fill:#FF6B6B
    style Defect fill:#000000
```

---

## Monthly Funding Cycle

```mermaid
sequenceDiagram
    participant Calendar
    participant Nations
    participant Treasury
    participant Player
    
    Note over Calendar: Month End Reached
    
    Calendar->>Nations: Process Monthly Update
    
    loop For Each Nation
        Nations->>Nations: Calculate Funding
        Nations->>Nations: funding × (1 - panic_penalty)
        Nations->>Nations: Reduce Panic by 5
        Nations->>Treasury: Transfer Funds
    end
    
    Nations-->>Calendar: Funding Complete
    
    Calendar->>Treasury: Deduct Monthly Costs
    Treasury->>Treasury: -Base Maintenance
    Treasury->>Treasury: -Personnel Salaries
    Treasury->>Treasury: -Craft Upkeep
    
    Calendar->>Player: Show Monthly Report
    
    Player->>Player: Review Finances
    Player->>Player: Review Nation Status
```

---

## UI Layout

```mermaid
graph TD
    subgraph "Geoscape UI"
        TopBar[Top Bar<br/>Date, Time, Funds]
        
        MainView[Main View<br/>Globe/Map]
        
        LeftPanel[Left Panel<br/>Mission List<br/>Base List<br/>Craft Status]
        
        RightPanel[Right Panel<br/>Selected Info<br/>Actions<br/>Alerts]
        
        BottomBar[Bottom Bar<br/>Time Controls<br/>Menu Buttons]
    end
    
    TopBar --- MainView
    MainView --- LeftPanel
    MainView --- RightPanel
    MainView --- BottomBar
    
    style TopBar fill:#E0BBE4
    style MainView fill:#87CEEB
    style LeftPanel fill:#90EE90
    style RightPanel fill:#FFD700
    style BottomBar fill:#FFB6C1
```

---

## Performance Optimization

| Component | Optimization | Impact |
|-----------|-------------|--------|
| **Globe Rendering** | Level-of-detail (LOD) mesh | High FPS improvement |
| **Mission Markers** | Batch rendering | Medium FPS improvement |
| **Daily Updates** | Incremental processing | Smooth time passage |
| **Radar Scanning** | Spatial partitioning | Fast detection |
| **UI Updates** | Dirty flag pattern | Reduced CPU usage |

---

**End of Geoscape Architecture**

