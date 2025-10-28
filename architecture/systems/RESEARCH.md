# Research System Architecture

**System:** Research & Technology  
**Date:** 2025-10-27  
**Status:** Complete

---

## Overview

The research system manages technology progression, tech trees, and unlockable content throughout the campaign.

---

## Research Flow

```mermaid
graph TB
    Start[Campaign Start] --> Available[Available Research]
    
    Available --> Select[Player Selects Project]
    
    Select --> CheckPrereqs{Prerequisites?}
    
    CheckPrereqs -->|Not Met| Locked[Show Locked]
    CheckPrereqs -->|Met| Assign[Assign Scientists]
    
    Locked -.->|Unlock via other research| Available
    
    Assign --> Progress[Daily Progress]
    
    Progress --> Calculate[Progress = Scientists × Lab Efficiency]
    
    Calculate --> Add[Add to Project Progress]
    
    Add --> Check{Complete?}
    
    Check -->|No| Progress
    Check -->|Yes| Complete[Research Complete]
    
    Complete --> Unlock[Grant Unlocks]
    
    Unlock --> Items[Unlock Items]
    Unlock --> Facilities[Unlock Facilities]
    Unlock --> Tech[Unlock Technologies]
    Unlock --> Research[Unlock Research]
    
    Research --> Available
    
    style Start fill:#90EE90
    style Complete fill:#87CEEB
    style Unlock fill:#FFD700
```

---

## Tech Tree Structure

```mermaid
graph TD
    subgraph "Phase 0: Early Game"
        Start[Game Start] --> BasicWeapons[Basic Weapons]
        Start --> BasicArmor[Basic Armor]
        Start --> BasicFacilities[Basic Facilities]
    end
    
    subgraph "Phase 1: Alien Analysis"
        BasicWeapons --> AlienWeapon[Alien Weapon Analysis]
        BasicArmor --> AlienMaterials[Alien Materials]
        
        AlienWeapon --> LaserTech[Laser Technology]
        AlienWeapon --> PlasmaTech[Plasma Technology]
        
        AlienMaterials --> AlienAlloys[Alien Alloys]
        AlienAlloys --> AdvArmor[Advanced Armor]
    end
    
    subgraph "Phase 2: Advanced Tech"
        LaserTech --> LaserWeapons[Laser Weapons]
        PlasmaTech --> PlasmaWeapons[Plasma Weapons]
        
        AdvArmor --> PowerArmor[Power Armor]
        
        AlienWeapon --> Psionics[Psionic Research]
        Psionics --> PsiLab[Psionic Laboratory]
    end
    
    subgraph "Phase 3: End Game"
        PlasmaWeapons --> AlienNav[Alien Navigation]
        AlienNav --> HyperWave[Hyper-Wave Decoder]
        
        HyperWave --> AlienBase[Locate Alien Base]
        AlienBase --> FinalMission[Final Mission Tech]
    end
    
    style Start fill:#90EE90
    style AlienWeapon fill:#FFD700
    style Psionics fill:#E0BBE4
    style FinalMission fill:#FF6B6B
```

---

## Research Project Data

```mermaid
erDiagram
    RESEARCH_PROJECT {
        string id PK
        string name
        string description
        int research_cost
        int research_days_estimate
        table prerequisites
        table unlocks
        string phase
        boolean repeatable
    }
    
    RESEARCH_INSTANCE {
        string instance_id PK
        string project_id FK
        string campaign_id FK
        int progress
        int assigned_scientists
        string status
        date started_date
        date completed_date
    }
    
    TECHNOLOGY {
        string id PK
        string name
        string description
        table effects
        table enables_items
        table enables_facilities
        table enables_research
    }
    
    PREREQUISITE {
        string research_id PK
        string requires_research_id FK
        string requires_item_id FK
        boolean optional
    }
    
    RESEARCH_PROJECT ||--o{ RESEARCH_INSTANCE : "instantiates"
    RESEARCH_PROJECT ||--o{ TECHNOLOGY : "unlocks"
    RESEARCH_PROJECT ||--o{ PREREQUISITE : "has"
```

---

## Research Progress Calculation

```mermaid
graph LR
    Daily[Daily Update] --> Count[Count Scientists]
    
    Count --> Labs[Check Lab Capacity]
    
    Labs --> Efficiency[Calculate Efficiency]
    
    Efficiency --> Base[Base: 100%]
    Efficiency --> Adjacency[Adjacency Bonus: +0-20%]
    Efficiency --> Facilities[Facility Bonus: +0-30%]
    
    Base --> Total[Total Efficiency]
    Adjacency --> Total
    Facilities --> Total
    
    Total --> Formula[Progress = Scientists × Efficiency]
    
    Formula --> Add[Add to Project]
    
    Add --> Check{Progress >= Cost?}
    
    Check -->|No| Continue[Continue Next Day]
    Check -->|Yes| Complete[Complete Research]
    
    style Daily fill:#90EE90
    style Complete fill:#87CEEB
    style Formula fill:#FFD700
```

### Research Speed Formula

| Factor | Base Value | Modifiers | Impact |
|--------|-----------|-----------|---------|
| **Scientists** | 1-20 per project | Skill level: +0-20% | Direct multiplier |
| **Lab Efficiency** | 100% | Adjacent labs: +10% each | Efficiency boost |
| **Facility Type** | Standard lab: 100% | Advanced lab: +25% | Speed increase |
| **Campaign Phase** | Phase 0: Normal | Late game: -20% cost | Balance tuning |

---

## Prerequisite System

```mermaid
graph TD
    Check[Check Prerequisites] --> Tech{Tech Unlocked?}
    
    Tech -->|No| TechLocked[Tech Locked]
    Tech -->|Yes| Item{Item Available?}
    
    Item -->|No| ItemLocked[Item Locked]
    Item -->|Yes| Research{Prior Research?}
    
    Research -->|No| ResearchLocked[Research Locked]
    Research -->|Yes| AllMet[All Prerequisites Met]
    
    AllMet --> Available[Research Available]
    
    TechLocked --> Display[Show Requirements]
    ItemLocked --> Display
    ResearchLocked --> Display
    
    Display --> Player[Player Can't Select]
    
    style Check fill:#90EE90
    style AllMet fill:#87CEEB
    style TechLocked fill:#FF6B6B
```

---

## Research Queue Management

```mermaid
sequenceDiagram
    participant Player
    participant UI
    participant Research as Research System
    participant Labs
    
    Player->>UI: View Available Research
    UI->>Research: Get Available Projects
    Research-->>UI: Return List
    
    Player->>UI: Select Project
    UI->>Research: Check Prerequisites
    
    alt Prerequisites Not Met
        Research-->>UI: Error: Requirements
        UI-->>Player: Show Missing Requirements
    else Prerequisites Met
        Research->>Research: Add to Active Projects
        
        Player->>UI: Assign Scientists
        UI->>Labs: Check Lab Capacity
        
        alt Over Capacity
            Labs-->>UI: Warning: Overcrowded
        else Within Capacity
            Labs->>Research: Assign Scientists
            Research->>Research: Start Daily Progress
        end
    end
    
    loop Daily Updates
        Research->>Research: Calculate Progress
        Research->>Research: Update Project
        
        alt Research Complete
            Research->>Research: Grant Unlocks
            Research->>UI: Notify Player
            UI-->>Player: Research Complete!
        end
    end
```

---

## Tech Unlock Effects

```mermaid
graph TD
    Complete[Research Complete] --> Process[Process Unlocks]
    
    Process --> Items[Unlock Items]
    Process --> Facilities[Unlock Facilities]
    Process --> Mfg[Unlock Manufacturing]
    Process --> Follow[Unlock Research]
    
    Items --> ItemsDB[Items Database]
    ItemsDB --> Market[Available in Market]
    ItemsDB --> Equipment[Equip on Units]
    
    Facilities --> FacilityDB[Facilities Database]
    FacilityDB --> Build[Available to Build]
    
    Mfg --> MfgDB[Manufacturing Database]
    MfgDB --> Production[Can Produce]
    
    Follow --> ResearchDB[Research Database]
    ResearchDB --> NewProjects[New Projects Available]
    
    style Complete fill:#90EE90
    style Process fill:#FFD700
    style NewProjects fill:#87CEEB
```

---

## Research Phases

```mermaid
stateDiagram-v2
    [*] --> Phase0: Campaign Start
    
    state Phase0 {
        [*] --> BasicTech
        BasicTech --> AlienCapture: Capture Alien
        AlienCapture --> [*]
    }
    
    Phase0 --> Phase1: Alien Analysis
    
    state Phase1 {
        [*] --> AlienWeapons
        AlienWeapons --> AlienMaterials
        AlienMaterials --> [*]
    }
    
    Phase1 --> Phase2: Advanced Research
    
    state Phase2 {
        [*] --> LaserTech
        LaserTech --> PlasmaTech
        PlasmaTech --> Psionics
        Psionics --> [*]
    }
    
    Phase2 --> Phase3: End Game
    
    state Phase3 {
        [*] --> AlienNavigation
        AlienNavigation --> HyperWave
        HyperWave --> AlienBaseLocation
        AlienBaseLocation --> [*]
    }
    
    Phase3 --> [*]: Campaign End
```

---

## Research Project Template

```lua
-- Example Research Project
{
    id = "laser_weapons",
    name = "Laser Weapons",
    description = "Develop laser-based weaponry from alien technology",
    
    -- Requirements
    prerequisites = {
        research = {"alien_weapon_analysis"},
        items = {"alien_power_source"},
        tech = {"laser_technology"}
    },
    
    -- Cost
    research_cost = 150,  -- Research points needed
    estimated_days = 20,   -- With 1 scientist
    
    -- Phase
    phase = 1,
    repeatable = false,
    
    -- Unlocks
    unlocks = {
        items = {"laser_rifle", "laser_pistol", "laser_cannon"},
        manufacturing = {"laser_rifle", "laser_pistol"},
        research = {"heavy_laser", "laser_defense_system"},
        technologies = {"laser_weapons_tech"}
    },
    
    -- Rewards
    rewards = {
        experience = 500,
        credits = 10000
    }
}
```

---

## Research Priority AI

```mermaid
graph TD
    AI[Research AI Advisor] --> Analyze[Analyze Campaign State]
    
    Analyze --> Threats[Assess Threats]
    Analyze --> Resources[Check Resources]
    Analyze --> Phase[Current Phase]
    
    Threats --> Priority{Priority Level}
    
    Priority -->|High| Combat[Combat Tech]
    Priority -->|Medium| Balance[Balanced Tech]
    Priority -->|Low| Economic[Economic Tech]
    
    Combat --> Weapons[Weapon Research]
    Combat --> Armor[Armor Research]
    
    Balance --> Mixed[Mix of All Types]
    
    Economic --> Production[Manufacturing]
    Economic --> Facilities[Facility Upgrades]
    
    Weapons --> Suggest[Suggest to Player]
    Armor --> Suggest
    Mixed --> Suggest
    Production --> Suggest
    Facilities --> Suggest
    
    style AI fill:#FFD700
    style Suggest fill:#87CEEB
```

---

## Performance Optimization

| Component | Optimization | Impact |
|-----------|-------------|--------|
| **Daily Updates** | Batch processing | All research updated once |
| **Prerequisite Check** | Cached dependencies | Fast validation |
| **Tech Tree** | Graph traversal cache | Quick unlocks |
| **UI Updates** | Event-driven | Only update on change |

---

**End of Research System Architecture**

