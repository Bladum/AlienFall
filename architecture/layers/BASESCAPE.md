# Basescape Architecture - Vertical Axial Hex Grid

**Layer:** Base Management Layer  
**Date:** 2025-10-28  
**Status:** Complete  
**Coordinate System:** Vertical Axial (Flat-Top Hexagons)

---

## Overview

The Basescape layer provides facility management, research, manufacturing, and personnel systems for base operations. **Base layout uses vertical axial hex grid for facility placement.**

### Base Grid Coordinate System

**Base facilities are placed on hex grid:**
- **Grid Size:** Configurable (typical: 20×20 hexes)
- **Position Format:** `{q, r}` (axial coordinates)
- **Facility Size:** 1-7 hexes (single hex or hex ring pattern)
- **Adjacent Check:** `HexMath.getNeighbors(q, r)` for connections
- **Distance:** `HexMath.distance(q1, r1, q2, r2)` for facility range

**Design Reference:** `design/mechanics/hex_vertical_axial_system.md`  
**Core Module:** `engine/battlescape/battle_ecs/hex_math.lua` (shared across all layers)

**Facility Patterns:**
- **1-hex:** Single building (generator, storage)
- **7-hex:** Ring pattern (large facility, hangar)
- **Custom:** Multi-hex irregular shapes

---

## Base Management Overview

```mermaid
graph TB
    subgraph "Basescape Layer - Vertical Axial Hex Grid"
        Base[Base Manager]
        HexMath[HexMath Module<br/>Universal Hex Mathematics]
        
        subgraph "Core Systems"
            Facilities[Facility System<br/>Hex Placement]
            Research[Research System]
            Manufacturing[Manufacturing System]
            Personnel[Personnel Manager]
        end
        
        subgraph "Economy"
            Inventory[Inventory Manager]
            Market[Marketplace]
            Finance[Finance Tracker]
        end
        
        subgraph "UI"
            Grid[Base Grid UI<br/>Hex Grid Rendering]
            Panels[Management Panels]
            Reports[Reports & Stats]
        end
    end
    
    Base --> Facilities
    Base --> Research
    Base --> Manufacturing
    Base --> Personnel
    HexMath -.-> Facilities
    HexMath -.-> Grid
    
    Facilities --> Finance
    Research --> Personnel
    Manufacturing --> Inventory
    
    Inventory --> Market
    
    Grid --> Facilities
    Panels --> Research
    Panels --> Manufacturing
    Reports --> Finance
    
    style Base fill:#FFD700
    style Facilities fill:#90EE90
    style Research fill:#87CEEB
    style Manufacturing fill:#E0BBE4
```

---

## Facility Construction

```mermaid
stateDiagram-v2
    [*] --> EmptySlot: Base Grid
    
    EmptySlot --> SelectFacility: Player Clicks
    
    state SelectFacility {
        [*] --> ShowAvailable
        ShowAvailable --> CheckPrereqs: Select Type
        
        CheckPrereqs --> Available: All Met
        CheckPrereqs --> Locked: Missing Tech
        
        Available --> ConfirmBuild
        Locked --> ShowAvailable
    }
    
    SelectFacility --> CheckFunds: Confirm
    
    CheckFunds --> InsufficientFunds: Not Enough
    CheckFunds --> StartConstruction: Deduct Cost
    
    InsufficientFunds --> SelectFacility
    
    state StartConstruction {
        [*] --> AddToQueue
        AddToQueue --> DailyProgress
        
        DailyProgress --> UpdateProgress: Each Day
        UpdateProgress --> CheckComplete: Progress++
        
        CheckComplete --> DailyProgress: Not Done
        CheckComplete --> [*]: Complete
    }
    
    StartConstruction --> FacilityComplete
    
    FacilityComplete --> UpdateBase: Add to Grid
    UpdateBase --> RecalcBonuses: Update Adjacency
    RecalcBonuses --> [*]
```

---

## Base Grid System

```mermaid
graph TD
    Grid[Base Grid 7x6] --> Layout[Grid Layout]
    
    Layout --> Access[Access Lift<br/>Row 0, Col 0<br/>Fixed]
    
    Layout --> Available[Available Slots<br/>41 Slots]
    
    Available --> Build[Build Facility]
    
    Build --> Type{Facility Type}
    
    Type --> Generator[Power Generator<br/>+Power]
    Type --> Workshop[Workshop<br/>Manufacturing]
    Type --> Lab[Laboratory<br/>Research]
    Type --> Barracks[Barracks<br/>Personnel]
    Type --> Hangar[Hangar<br/>Craft Storage]
    Type --> Storage[Storage<br/>Inventory]
    
    Generator --> CheckAdjacent[Check Adjacent]
    Workshop --> CheckAdjacent
    Lab --> CheckAdjacent
    
    CheckAdjacent --> Bonus{Same Type?}
    
    Bonus -->|Yes| ApplyBonus[+10% Efficiency]
    Bonus -->|No| CheckSynergy{Synergy?}
    
    CheckSynergy -->|Lab+Workshop| SynergyBonus[+5% Both]
    CheckSynergy -->|Generator+Any| FreeConnection[Free Power]
    
    style Grid fill:#FFD700
    style ApplyBonus fill:#90EE90
    style SynergyBonus fill:#87CEEB
```

### Facility Types Table

| Facility | Cost | Build Time | Power | Effect |
|----------|------|------------|-------|--------|
| **Power Generator** | $400k | 15 days | +20 | Provides power |
| **Workshop** | $800k | 20 days | -5 | Manufacturing capacity |
| **Laboratory** | $750k | 20 days | -5 | Research capacity |
| **Barracks** | $200k | 10 days | -2 | Houses 25 personnel |
| **Hangar** | $300k | 15 days | -3 | Stores 1 craft |
| **Storage** | $150k | 10 days | -1 | +50 storage capacity |
| **Hospital** | $500k | 18 days | -4 | Heals wounded soldiers |
| **Alien Containment** | $400k | 18 days | -3 | Stores live aliens |

---

## Research System

```mermaid
graph TD
    Available[Available Projects] --> Select[Player Selects]
    
    Select --> CheckPrereqs{Prerequisites Met?}
    
    CheckPrereqs -->|No| Locked[Show Locked]
    CheckPrereqs -->|Yes| Assign[Assign Scientists]
    
    Assign --> Calculate[Calculate Daily Progress]
    
    Calculate --> Formula[Progress = Scientists × Lab Efficiency]
    
    Formula --> DailyTick[Daily Update]
    
    DailyTick --> UpdateProgress[Add Progress Points]
    
    UpdateProgress --> CheckComplete{Progress >= Cost?}
    
    CheckComplete -->|No| DailyTick
    CheckComplete -->|Yes| Complete[Research Complete]
    
    Complete --> Unlocks[Grant Unlocks]
    
    Unlocks --> UnlockTech[Technologies]
    Unlocks --> UnlockItems[Items]
    Unlocks --> UnlockFacilities[Facilities]
    Unlocks --> UnlockResearch[Follow-up Research]
    
    UnlockResearch --> Available
    
    style Available fill:#90EE90
    style Complete fill:#87CEEB
    style Unlocks fill:#FFD700
```

### Tech Tree Example

```mermaid
graph LR
    Start[Game Start] --> Basic[Basic Weapons]
    
    Basic --> Alien1[Alien Weapon Analysis]
    
    Alien1 --> Laser[Laser Technology]
    Alien1 --> Plasma[Plasma Technology]
    
    Laser --> LaserWeapons[Laser Weapons]
    Laser --> LaserDefense[Laser Defenses]
    
    Plasma --> PlasmaWeapons[Plasma Weapons]
    Plasma --> PlasmaArmor[Plasma Armor]
    
    Basic --> Alloys[Alien Alloys]
    Alloys --> AdvArmor[Advanced Armor]
    Alloys --> PowerArmor[Power Armor]
    
    Alien1 --> Psionics[Psionic Research]
    Psionics --> PsiLab[Psionic Lab]
    Psionics --> PsiAmp[Psi-Amp]
    
    style Start fill:#90EE90
    style Laser fill:#87CEEB
    style Plasma fill:#FF6B6B
    style Psionics fill:#E0BBE4
```

---

## Manufacturing System

```mermaid
sequenceDiagram
    participant Player
    participant UI
    participant Mfg as Manufacturing System
    participant Inventory
    participant Economy
    
    Player->>UI: Select Item to Produce
    UI->>Mfg: Check Requirements
    
    Mfg->>Mfg: Check Tech Unlocked
    Mfg->>Mfg: Check Resources Available
    Mfg->>Mfg: Check Workshop Available
    
    alt Requirements Not Met
        Mfg-->>UI: Show Error
        UI-->>Player: Display Error
    else Requirements Met
        Mfg->>Economy: Check Funds
        
        alt Insufficient Funds
            Economy-->>Mfg: Not Enough
            Mfg-->>UI: Show Error
        else Sufficient Funds
            Economy->>Economy: Deduct Upfront Cost
            Mfg->>Mfg: Add to Production Queue
            
            loop Daily Production
                Mfg->>Mfg: Engineers × Workshop Efficiency
                Mfg->>Mfg: Add Progress Points
                
                alt Progress >= Cost
                    Mfg->>Mfg: Item Complete
                    Mfg->>Inventory: Add Item
                    Mfg-->>UI: Notify Complete
                end
            end
        end
    end
```

---

## Personnel Management

```mermaid
graph TD
    Personnel[Personnel Manager] --> Soldiers[Soldiers]
    Personnel --> Engineers[Engineers]
    Personnel --> Scientists[Scientists]
    
    Soldiers --> Roster[Soldier Roster]
    Soldiers --> Training[Training Queue]
    Soldiers --> Hospital[Hospital Ward]
    
    Roster --> Deploy[Deploy to Mission]
    Roster --> Dismiss[Dismiss Soldier]
    
    Training --> Promote[Rank Promotion]
    Training --> Specialize[Specialization]
    
    Hospital --> Heal[Healing Progress]
    Heal --> Recovered[Return to Roster]
    
    Engineers --> Workshop[Assign to Workshop]
    Scientists --> Lab[Assign to Lab]
    
    Workshop --> Production[Manufacturing Speed]
    Lab --> Research[Research Speed]
    
    style Personnel fill:#FFD700
    style Soldiers fill:#90EE90
    style Engineers fill:#E0BBE4
    style Scientists fill:#87CEEB
```

### Personnel Costs

| Type | Monthly Salary | Capacity | Hiring Cost |
|------|---------------|----------|-------------|
| **Soldier (Rookie)** | $40k | Barracks | $20k |
| **Soldier (Veteran)** | $60k | Barracks | $50k |
| **Engineer** | $50k | Workshop | $30k |
| **Scientist** | $60k | Laboratory | $40k |
| **Pilot** | $50k | Hangar | $35k |

---

## Inventory System

```mermaid
graph LR
    Inventory[Inventory Manager] --> Weapons[Weapons]
    Inventory --> Armor[Armor]
    Inventory --> Items[Items]
    Inventory --> Resources[Resources]
    
    Weapons --> Equipped[Equipped by Units]
    Armor --> Equipped
    Items --> Equipped
    
    Weapons --> Available[Available Pool]
    Armor --> Available
    Items --> Available
    
    Resources --> Manufacturing[Manufacturing Input]
    Resources --> Research[Research Material]
    
    Available --> Sell[Sell to Market]
    
    Sell --> Revenue[Generate Revenue]
    
    style Inventory fill:#FFD700
    style Available fill:#90EE90
    style Revenue fill:#87CEEB
```

---

## Marketplace

```mermaid
stateDiagram-v2
    [*] --> MarketOpen: Open Market
    
    state MarketOpen {
        [*] --> BrowseItems
        
        BrowseItems --> SelectItem: Choose Item
        
        SelectItem --> BuyItem: Purchase
        SelectItem --> SellItem: Sell
        
        state BuyItem {
            [*] --> CheckFunds
            CheckFunds --> DeductFunds: Funds OK
            CheckFunds --> Error: Insufficient
            DeductFunds --> AddInventory
            AddInventory --> [*]
        }
        
        state SellItem {
            [*] --> CheckItem
            CheckItem --> RemoveItem: Item Available
            CheckItem --> Error: Not Found
            RemoveItem --> AddFunds
            AddFunds --> [*]
        }
        
        Error --> BrowseItems
    }
    
    MarketOpen --> [*]: Close
```

---

## Monthly Base Report

```mermaid
graph TD
    MonthEnd[Month End] --> GenerateReport[Generate Report]
    
    GenerateReport --> Income[Calculate Income]
    GenerateReport --> Expenses[Calculate Expenses]
    GenerateReport --> Progress[Calculate Progress]
    
    Income --> Funding[Nation Funding]
    Income --> Sales[Item Sales]
    
    Expenses --> Maintenance[Base Maintenance]
    Expenses --> Salaries[Personnel Salaries]
    Expenses --> Construction[Construction Costs]
    
    Progress --> ResearchDone[Research Completed]
    Progress --> ItemsProduced[Items Produced]
    Progress --> MissionsRun[Missions Completed]
    
    Funding --> TotalIncome[Total Income]
    Sales --> TotalIncome
    
    Maintenance --> TotalExpenses[Total Expenses]
    Salaries --> TotalExpenses
    Construction --> TotalExpenses
    
    TotalIncome --> NetBalance[Net Balance]
    TotalExpenses --> NetBalance
    
    NetBalance --> Display[Display Report to Player]
    ResearchDone --> Display
    ItemsProduced --> Display
    MissionsRun --> Display
    
    style MonthEnd fill:#90EE90
    style Display fill:#87CEEB
    style NetBalance fill:#FFD700
```

---

## Base Defense

```mermaid
sequenceDiagram
    participant Alert as Base Defense Alert
    participant Geo as Geoscape
    participant Base as Base Manager
    participant Battle as Battlescape
    
    Alert->>Geo: Base Under Attack!
    Geo->>Geo: Pause Time
    Geo->>Base: Get Base Data
    
    Base-->>Geo: Facilities, Personnel, Defenses
    
    Geo->>Geo: Show Alert Dialog
    
    alt Player Defends
        Geo->>Battle: Start Base Defense Mission
        Battle->>Battle: Generate Base Map
        Battle->>Battle: Place Defenders
        Battle->>Battle: Spawn Attackers
        
        Battle->>Battle: Combat Resolution
        
        alt Victory
            Battle-->>Geo: Mission Success
            Geo->>Base: Minor Damage to Facilities
        else Defeat
            Battle-->>Geo: Mission Failure
            Geo->>Base: Major Damage/Destruction
        end
    else Player Evacuates
        Geo->>Base: Lose Base
        Geo->>Geo: Remove Base from Map
    end
```

---

## Performance Considerations

| System | Optimization | Impact |
|--------|-------------|--------|
| **Grid Rendering** | Dirty flag updates | Only redraw on change |
| **Research/Mfg** | Daily batch updates | Efficient time advancement |
| **Inventory** | Hash map lookups | O(1) item access |
| **Facility Adjacency** | Cache bonus values | Fast recalculation |
| **UI Panels** | Lazy loading | Faster screen transitions |

---

**End of Basescape Architecture**

