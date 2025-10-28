# Data Models & Entity Relationships

**System:** Data Structures & Models  
**Date:** 2025-10-27  
**Status:** Complete

---

## Overview

Core data models defining entities, relationships, and data structures used throughout the game.

---

## Content Data Models

### Unit Data Model

```mermaid
erDiagram
    UNIT_TYPE {
        string id PK
        string name
        string type
        string unit_class
        int base_hp
        int base_will
        int base_aim
        int base_defense
        int base_mobility
        string sprite_sheet
        table stats
        table skills
        table perks
    }
    
    UNIT_INSTANCE {
        string instance_id PK
        string unit_id FK
        string soldier_name
        string rank
        int current_hp
        int max_hp
        int experience
        int missions_completed
        int kills
        string status
        table equipment
        table learned_perks
    }
    
    WEAPON {
        string id PK
        string name
        string type
        int damage_min
        int damage_max
        int accuracy
        int range
        int ammo_capacity
        string ammo_type FK
        string damage_type
        table special_effects
    }
    
    ARMOR {
        string id PK
        string name
        int armor_value
        int mobility_penalty
        table resistances
        table special_abilities
    }
    
    PERK {
        string id PK
        string name
        string description
        int rank_required
        string specialization
        table effects
        table prerequisites
    }
    
    UNIT_TYPE ||--o{ UNIT_INSTANCE : "template"
    UNIT_INSTANCE ||--o{ WEAPON : "equipped"
    UNIT_INSTANCE ||--o{ ARMOR : "wearing"
    UNIT_INSTANCE ||--o{ PERK : "learned"
```

---

## Facility Data Model

```mermaid
erDiagram
    FACILITY_TYPE {
        string id PK
        string name
        int construction_cost
        int construction_days
        int maintenance_cost
        int power_consumption
        int power_generation
        table requirements
        table bonuses
    }
    
    FACILITY_INSTANCE {
        string instance_id PK
        string facility_id FK
        string base_id FK
        int grid_x
        int grid_y
        string status
        int construction_progress
        int efficiency
        table assigned_personnel
    }
    
    BASE {
        string id PK
        string name
        int location_x
        int location_y
        string region_id FK
        int grid_width
        int grid_height
        table facilities
        table personnel
        table crafts
    }
    
    REGION {
        string id PK
        string name
        string continent
        table countries
        int radar_range
    }
    
    FACILITY_TYPE ||--o{ FACILITY_INSTANCE : "template"
    BASE ||--o{ FACILITY_INSTANCE : "contains"
    REGION ||--o{ BASE : "located_in"
```

---

## Mission Data Model

```mermaid
erDiagram
    MISSION_TYPE {
        string id PK
        string name
        string objective_type
        table enemy_pool
        table biome_weights
        int difficulty_min
        int difficulty_max
        string mapscript_id FK
        table rewards
    }
    
    MISSION_INSTANCE {
        string instance_id PK
        string mission_type_id FK
        int location_x
        int location_y
        string biome
        int difficulty
        int turns_limit
        string status
        int expiration_turns
        table deployed_squad
    }
    
    MAPSCRIPT {
        string id PK
        string name
        int width
        int height
        table block_pools
        table placement_rules
        table spawn_zones
    }
    
    MAPBLOCK {
        string id PK
        string name
        int width
        int height
        string biome
        table tiles
        table spawn_points
    }
    
    MISSION_TYPE ||--o{ MISSION_INSTANCE : "template"
    MISSION_TYPE ||--|| MAPSCRIPT : "uses"
    MAPSCRIPT ||--o{ MAPBLOCK : "references"
```

---

## Research Data Model

```mermaid
erDiagram
    RESEARCH_PROJECT {
        string id PK
        string name
        string description
        int research_cost
        int research_days
        table prerequisites
        table unlocks
        string phase
    }
    
    RESEARCH_INSTANCE {
        string instance_id PK
        string project_id FK
        string campaign_id FK
        int progress
        int assigned_scientists
        string status
        string started_date
    }
    
    TECHNOLOGY {
        string id PK
        string name
        string description
        table effects
        table enables
    }
    
    MANUFACTURING_PROJECT {
        string id PK
        string name
        string item_id FK
        int production_cost
        int production_days
        table resources_required
        table tech_requirements
    }
    
    RESEARCH_PROJECT ||--o{ RESEARCH_INSTANCE : "template"
    RESEARCH_PROJECT ||--o{ TECHNOLOGY : "unlocks"
    TECHNOLOGY ||--o{ MANUFACTURING_PROJECT : "enables"
```

---

## Craft Data Model

```mermaid
erDiagram
    CRAFT_TYPE {
        string id PK
        string name
        int max_speed
        int armor
        int max_hp
        int fuel_capacity
        int weapon_slots
        table weapon_types
    }
    
    CRAFT_INSTANCE {
        string instance_id PK
        string craft_type_id FK
        string base_id FK
        int current_hp
        int current_fuel
        string status
        table equipped_weapons
        table crew
    }
    
    CRAFT_WEAPON {
        string id PK
        string name
        int damage_min
        int damage_max
        int range
        int accuracy
        int ammo_capacity
        string damage_type
    }
    
    UFO_TYPE {
        string id PK
        string name
        int max_speed
        int armor
        int max_hp
        table weapons
        int altitude_min
        int altitude_max
    }
    
    CRAFT_TYPE ||--o{ CRAFT_INSTANCE : "template"
    CRAFT_INSTANCE ||--o{ CRAFT_WEAPON : "equipped"
    UFO_TYPE ||--|| CRAFT_TYPE : "comparable"
```

---

## Item Data Model

```mermaid
erDiagram
    ITEM_TYPE {
        string id PK
        string name
        string category
        int weight
        int value
        string description
        table properties
    }
    
    INVENTORY {
        string id PK
        string owner_id FK
        string owner_type
        table items
        int capacity
        int used_capacity
    }
    
    ITEM_INSTANCE {
        string instance_id PK
        string item_type_id FK
        string inventory_id FK
        int quantity
        string condition
    }
    
    WEAPON_ITEM {
        string id PK
        string item_id FK
        int damage
        int accuracy
        int ammo
        string ammo_type
    }
    
    ARMOR_ITEM {
        string id PK
        string item_id FK
        int armor_value
        int mobility
        table resistances
    }
    
    ITEM_TYPE ||--o{ ITEM_INSTANCE : "template"
    INVENTORY ||--o{ ITEM_INSTANCE : "contains"
    ITEM_TYPE ||--o| WEAPON_ITEM : "weapon_data"
    ITEM_TYPE ||--o| ARMOR_ITEM : "armor_data"
```

---

## Campaign Data Model

```mermaid
erDiagram
    CAMPAIGN {
        string id PK
        string name
        string difficulty
        date start_date
        int current_turn
        int current_phase
        float progress
        int score
    }
    
    GEOSCAPE_STATE {
        string id PK
        string campaign_id FK
        table active_missions
        table ufo_activity
        table craft_positions
    }
    
    BASESCAPE_STATE {
        string id PK
        string campaign_id FK
        table bases
        table research
        table manufacturing
    }
    
    NATION {
        string id PK
        string name
        string continent
        int funding
        int panic_level
        string status
    }
    
    STATISTICS {
        string id PK
        string campaign_id FK
        int missions_total
        int missions_won
        int missions_lost
        int total_kills
        int total_deaths
    }
    
    CAMPAIGN ||--|| GEOSCAPE_STATE : "has"
    CAMPAIGN ||--|| BASESCAPE_STATE : "has"
    CAMPAIGN ||--o{ NATION : "interacts_with"
    CAMPAIGN ||--|| STATISTICS : "tracks"
```

---

## Data Flow Patterns

### Content Loading Pattern

```mermaid
graph LR
    TOML[TOML Files] --> Parser[TOML Parser]
    
    Parser --> Validator[Schema Validator]
    
    Validator -->|Valid| Registry[Content Registry]
    Validator -->|Invalid| Error[Log Error]
    
    Registry --> Cache[Content Cache]
    
    Cache --> GameSystems[Game Systems]
    
    GameSystems --> Battle[Battle System]
    GameSystems --> Geo[Geoscape System]
    GameSystems --> Base[Basescape System]
    
    style TOML fill:#90EE90
    style Registry fill:#FFD700
    style Cache fill:#87CEEB
```

---

### Save/Load Data Flow

```mermaid
graph TD
    GameState[Game State] --> Collector[Data Collector]
    
    Collector --> Campaign[Campaign Data]
    Collector --> Geoscape[Geoscape Data]
    Collector --> Basescape[Basescape Data]
    Collector --> Units[Unit Data]
    
    Campaign --> Serializer[Serializer]
    Geoscape --> Serializer
    Basescape --> Serializer
    Units --> Serializer
    
    Serializer --> JSON[JSON Format]
    JSON --> Compress[Compress]
    Compress --> File[Save File]
    
    File -.->|Load| Decompress[Decompress]
    Decompress --> Parse[Parse JSON]
    Parse --> Validate[Validate]
    Validate --> Restore[Restore State]
    
    Restore --> GameState
    
    style GameState fill:#FFD700
    style File fill:#87CEEB
```

---

### Event Data Flow

```mermaid
graph LR
    Event[Game Event] --> Bus[Event Bus]
    
    Bus --> Filter[Event Filter]
    
    Filter --> Sub1[Subscriber 1:<br/>UI System]
    Filter --> Sub2[Subscriber 2:<br/>Analytics]
    Filter --> Sub3[Subscriber 3:<br/>Audio]
    Filter --> Sub4[Subscriber 4:<br/>Save System]
    
    Sub1 --> Action1[Update UI]
    Sub2 --> Action2[Log Metric]
    Sub3 --> Action3[Play Sound]
    Sub4 --> Action4[Mark Dirty]
    
    style Event fill:#90EE90
    style Bus fill:#FFD700
    style Filter fill:#87CEEB
```

---

## Data Relationships Table

| Entity | Related To | Relationship | Cardinality |
|--------|-----------|--------------|-------------|
| **Unit Type** | Unit Instance | Template | 1:N |
| **Unit Instance** | Weapon | Equips | 1:N |
| **Unit Instance** | Armor | Wears | 1:1 |
| **Base** | Facility | Contains | 1:N |
| **Base** | Craft | Houses | 1:N |
| **Mission Type** | Mission Instance | Generates | 1:N |
| **Research Project** | Technology | Unlocks | 1:N |
| **Technology** | Items | Enables | 1:N |
| **Campaign** | Nations | Interacts | 1:N |
| **Mapscript** | Mapblocks | Uses | 1:N |

---

## Data Validation Rules

| Entity | Required Fields | Validation Rules | Example |
|--------|----------------|------------------|---------|
| **Unit** | id, name, hp | hp > 0, unique id | id="soldier_rookie" |
| **Weapon** | id, damage, range | damage > 0, range > 0 | damage=20-30 |
| **Facility** | id, cost, days | cost >= 0, days > 0 | cost=50000 |
| **Mission** | id, type, difficulty | difficulty 1-5 | difficulty=3 |
| **Research** | id, cost | cost > 0 | cost=150 |

---

## Performance Considerations

| Data Type | Storage | Access Pattern | Optimization |
|-----------|---------|---------------|--------------|
| **Units** | Hash map | By ID | O(1) lookup |
| **Facilities** | Grid array | By position | O(1) access |
| **Missions** | List | Sequential | Linear scan |
| **Items** | Hash map | By ID | O(1) lookup |
| **Save Data** | Compressed file | Full load | Lazy deserialize |

---

**End of Data Models & Entity Relationships**

