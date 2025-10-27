# Save & Load System Architecture

**System:** Game Persistence  
**Date:** 2025-10-27  
**Status:** Complete

---

## Overview

The save/load system provides campaign persistence across 12 save slots with auto-save, data validation, and version compatibility.

---

## Save System Architecture

```mermaid
graph TB
    subgraph "Save System"
        SaveMgr[Save Manager]
        
        subgraph "Data Collection"
            Campaign[Campaign State]
            Geoscape[Geoscape State]
            Basescape[Basescape State]
            Units[Unit Roster]
            Progress[Progress Data]
        end
        
        subgraph "Serialization"
            Serialize[Serializer]
            Compress[Compressor]
            Encrypt[Encryption]
        end
        
        subgraph "Storage"
            Slots[12 Save Slots]
            AutoSave[Auto-Save]
            Metadata[Save Metadata]
        end
    end
    
    SaveMgr --> Campaign
    SaveMgr --> Geoscape
    SaveMgr --> Basescape
    SaveMgr --> Units
    SaveMgr --> Progress
    
    Campaign --> Serialize
    Geoscape --> Serialize
    Basescape --> Serialize
    Units --> Serialize
    Progress --> Serialize
    
    Serialize --> Compress
    Compress --> Encrypt
    
    Encrypt --> Slots
    Encrypt --> AutoSave
    Slots --> Metadata
    
    style SaveMgr fill:#FFD700
    style Serialize fill:#87CEEB
    style Slots fill:#90EE90
```

---

## Save Game Data Structure

```mermaid
erDiagram
    SAVE_FILE {
        string save_id PK
        int slot_number
        string campaign_name
        date save_timestamp
        string game_version
        int checksum
        blob data
    }
    
    CAMPAIGN_DATA {
        string campaign_id PK
        int difficulty
        date campaign_start
        int current_turn
        int current_phase
        float campaign_progress
        int score
    }
    
    GEOSCAPE_DATA {
        string id PK
        string campaign_id FK
        table active_missions
        table ufo_tracking
        table craft_positions
        table nation_relations
    }
    
    BASESCAPE_DATA {
        string id PK
        string campaign_id FK
        table bases
        table facilities
        table personnel
        table inventory
    }
    
    RESEARCH_DATA {
        string id PK
        string campaign_id FK
        table completed_research
        table active_projects
        table available_tech
    }
    
    SAVE_FILE ||--|| CAMPAIGN_DATA : "contains"
    CAMPAIGN_DATA ||--|| GEOSCAPE_DATA : "includes"
    CAMPAIGN_DATA ||--|| BASESCAPE_DATA : "includes"
    CAMPAIGN_DATA ||--|| RESEARCH_DATA : "includes"
```

---

## Save Flow

```mermaid
sequenceDiagram
    participant Player
    participant UI
    participant SaveMgr as Save Manager
    participant Collector as Data Collector
    participant Validator
    participant FileSystem
    
    Player->>UI: Request Save
    UI->>SaveMgr: save(slot_number)
    
    SaveMgr->>Collector: collectAllData()
    
    Collector->>Collector: Collect Campaign State
    Collector->>Collector: Collect Geoscape State
    Collector->>Collector: Collect Basescape State
    Collector->>Collector: Collect Unit Roster
    Collector->>Collector: Collect Progress Data
    
    Collector-->>SaveMgr: state_data
    
    SaveMgr->>SaveMgr: Add Metadata<br/>(timestamp, version, checksum)
    
    SaveMgr->>SaveMgr: Serialize to JSON
    
    SaveMgr->>SaveMgr: Compress Data (optional)
    
    SaveMgr->>Validator: Validate Structure
    
    alt Valid
        Validator-->>SaveMgr: Valid
        SaveMgr->>FileSystem: Write to slot
        FileSystem-->>SaveMgr: Success
        SaveMgr->>UI: Save Complete
        UI-->>Player: Show Confirmation
    else Invalid
        Validator-->>SaveMgr: Invalid
        SaveMgr->>UI: Show Error
        UI-->>Player: Save Failed
    end
```

---

## Load Flow

```mermaid
sequenceDiagram
    participant Player
    participant UI
    participant LoadMgr as Load Manager
    participant FileSystem
    participant Validator
    participant Game
    
    Player->>UI: Select Save Slot
    UI->>LoadMgr: load(slot_number)
    
    LoadMgr->>FileSystem: Read save file
    FileSystem-->>LoadMgr: raw_data
    
    LoadMgr->>LoadMgr: Verify Checksum
    
    alt Checksum Valid
        LoadMgr->>LoadMgr: Decompress (if needed)
        LoadMgr->>LoadMgr: Deserialize JSON
        
        LoadMgr->>Validator: Validate Content
        
        alt Content Valid
            Validator-->>LoadMgr: Valid
            
            LoadMgr->>Game: Restore Campaign State
            LoadMgr->>Game: Restore Geoscape State
            LoadMgr->>Game: Restore Basescape State
            LoadMgr->>Game: Restore Unit Roster
            
            Game->>Game: Initialize Systems
            Game->>Game: Switch to Geoscape
            
            Game-->>UI: Load Complete
            UI-->>Player: Enter Game
            
        else Content Invalid
            Validator-->>LoadMgr: Validation Errors
            LoadMgr->>UI: Show Errors
            UI-->>Player: Cannot Load
        end
        
    else Checksum Invalid
        LoadMgr->>UI: Corrupted Save
        UI-->>Player: File Corrupted
    end
```

---

## Save Slots UI

```mermaid
graph TD
    SaveMenu[Save/Load Menu] --> Slots[12 Save Slots]
    
    Slots --> Slot1[Slot 1: Campaign Alpha<br/>Date: 2020-05-15<br/>Turn: 145]
    Slots --> Slot2[Slot 2: Empty]
    Slots --> Slot3[Slot 3: Campaign Beta<br/>Date: 2020-08-22<br/>Turn: 234]
    Slots --> AutoSlot[Auto-Save<br/>Latest: 2020-09-01<br/>Turn: 178]
    
    Slot1 --> Actions1[Load / Overwrite / Delete]
    Slot2 --> Actions2[Save Here]
    Slot3 --> Actions3[Load / Overwrite / Delete]
    AutoSlot --> Actions4[Load Only]
    
    style SaveMenu fill:#FFD700
    style Slot1 fill:#90EE90
    style Slot2 fill:#E0E0E0
    style Slot3 fill:#90EE90
    style AutoSlot fill:#87CEEB
```

---

## Auto-Save System

```mermaid
stateDiagram-v2
    [*] --> Monitoring: Game Running
    
    Monitoring --> TriggerCheck: Check Triggers
    
    state TriggerCheck {
        [*] --> TimeInterval: Every 5 Minutes
        [*] --> MissionComplete: Mission End
        [*] --> MonthEnd: Month End
        [*] --> ManualSave: Manual Save
    }
    
    TriggerCheck --> AutoSave: Trigger Fired
    
    state AutoSave {
        [*] --> CollectData
        CollectData --> Serialize
        Serialize --> WriteFile
        WriteFile --> [*]
    }
    
    AutoSave --> Monitoring: Continue
    
    Monitoring --> [*]: Exit Game
```

---

## Data Validation

```mermaid
graph TD
    Validate[Validate Save Data] --> CheckVersion{Version Compatible?}
    
    CheckVersion -->|No| VersionError[Version Mismatch Error]
    CheckVersion -->|Yes| CheckStructure{Structure Valid?}
    
    CheckStructure -->|No| StructureError[Structure Error]
    CheckStructure -->|Yes| CheckRefs{References Valid?}
    
    CheckRefs -->|No| RefError[Reference Error]
    CheckRefs -->|Yes| CheckIntegrity{Data Integrity OK?}
    
    CheckIntegrity -->|No| IntegrityError[Integrity Error]
    CheckIntegrity -->|Yes| Valid[Validation Success]
    
    VersionError --> Report[Generate Error Report]
    StructureError --> Report
    RefError --> Report
    IntegrityError --> Report
    
    Report --> User[Show to User]
    
    Valid --> Proceed[Proceed with Load]
    
    style Validate fill:#90EE90
    style Valid fill:#87CEEB
    style VersionError fill:#FF6B6B
```

---

## Save File Format

```lua
-- Example Save File Structure (JSON)
{
    header = {
        save_id = "save_001",
        slot_number = 1,
        game_version = "1.0.0",
        save_date = "2025-10-27T15:30:00Z",
        campaign_name = "Operation Vigilant Storm",
        checksum = "a1b2c3d4e5f6"
    },
    
    campaign = {
        campaign_id = "campaign_001",
        difficulty = "commander",
        start_date = "2020-01-01",
        current_turn = 145,
        current_phase = 2,
        score = 8500
    },
    
    geoscape = {
        active_missions = {
            {mission_id = "mission_045", type = "crash_site", ...},
            {mission_id = "mission_046", type = "terror", ...}
        },
        craft_positions = {
            {craft_id = "interceptor_1", x = 120, y = 45},
            {craft_id = "transport_1", x = 200, y = 100}
        },
        nation_relations = {
            {nation_id = "usa", panic = 15, funding = 800000},
            {nation_id = "china", panic = 25, funding = 600000}
        }
    },
    
    basescape = {
        bases = {
            {
                base_id = "base_1",
                name = "HQ",
                location = {x = 100, y = 50},
                facilities = {...},
                personnel = {...}
            }
        },
        inventory = {
            {item_id = "rifle", quantity = 15},
            {item_id = "laser_rifle", quantity = 5}
        }
    },
    
    research = {
        completed = {"basic_weapons", "alien_alloys"},
        active = {
            {project_id = "laser_weapons", progress = 87}
        }
    },
    
    statistics = {
        missions_completed = 42,
        missions_won = 35,
        missions_lost = 3,
        total_kills = 234,
        total_deaths = 12
    }
}
```

---

## Compression & Optimization

```mermaid
graph LR
    RawData[Raw Save Data<br/>~5 MB] --> Compress{Compress?}
    
    Compress -->|Yes| Algorithm[Compression Algorithm]
    Compress -->|No| Write[Write to Disk]
    
    Algorithm --> LZ4[LZ4: Fast, ~3 MB]
    Algorithm --> ZLIB[ZLIB: Balanced, ~2 MB]
    Algorithm --> LZMA[LZMA: Best, ~1.5 MB]
    
    LZ4 --> Compressed[Compressed Data]
    ZLIB --> Compressed
    LZMA --> Compressed
    
    Compressed --> Write
    
    Write --> Disk[Save File on Disk]
    
    style RawData fill:#FF6B6B
    style Compressed fill:#90EE90
    style Disk fill:#87CEEB
```

---

## Version Compatibility

| Save Version | Game Version | Compatible? | Migration |
|--------------|-------------|-------------|-----------|
| **1.0.x** | 1.0.x | ✅ Full | None needed |
| **1.0.x** | 1.1.x | ✅ Forward | Auto-migrate |
| **1.1.x** | 1.0.x | ⚠️ Partial | Some features lost |
| **1.x.x** | 2.x.x | ❌ No | Manual conversion required |

---

## Error Handling

```mermaid
stateDiagram-v2
    [*] --> LoadAttempt: Load Save
    
    LoadAttempt --> CheckFile: File Exists?
    
    CheckFile --> FileNotFound: No
    CheckFile --> ReadFile: Yes
    
    FileNotFound --> Error1[Show Error:<br/>Save file not found]
    
    ReadFile --> CheckChecksum: Verify Checksum
    
    CheckChecksum --> ChecksumFail: Invalid
    CheckChecksum --> Deserialize: Valid
    
    ChecksumFail --> Error2[Show Error:<br/>File corrupted]
    
    Deserialize --> CheckVersion: Parse JSON
    
    CheckVersion --> VersionMismatch: Incompatible
    CheckVersion --> Validate: Compatible
    
    VersionMismatch --> Error3[Show Error:<br/>Version mismatch]
    
    Validate --> ValidationFail: Invalid Data
    Validate --> LoadSuccess: Valid
    
    ValidationFail --> Error4[Show Error:<br/>Invalid save data]
    
    Error1 --> [*]
    Error2 --> [*]
    Error3 --> [*]
    Error4 --> [*]
    LoadSuccess --> [*]: Game Loaded
```

---

## Performance Metrics

| Operation | Target Time | Typical Time | Notes |
|-----------|------------|--------------|-------|
| **Save Game** | < 2s | ~1.5s | Including compression |
| **Load Game** | < 5s | ~3s | Including decompression |
| **Auto-Save** | < 1s | ~0.8s | Background operation |
| **Validate** | < 1s | ~0.5s | Quick checks |

---

**End of Save & Load System Architecture**

