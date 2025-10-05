# Geoscape Overview

> **Purpose:** Describe AlienFall’s strategic campaign layer and give engineers the hooks needed to implement it in Love2D.

## Role in AlienFall
- Advance in-game time, spawn missions, and coordinate UFO/craft movements.
- Track province ownership, panic, and funding contributions.
- Serve as the hub for base building, interception launches, and strategic decisions.

## Player / Design Goals
- **Readable map:** Provinces, missions, and radar coverage are easy to parse on the 20×20 grid.
- **Deterministic time flow:** Pausing, fast-forwarding, and scheduled events always produce the same outcomes per seed.
- **Meaningful choices:** Mission prioritisation, base placement, and radar network design matter.

## System Boundaries
- Encompasses world generation, provinces, regions, biomes, time progression, mission scheduling, and craft routing.
- Interfaces with basescape (bases, services), economy (funding), interception (combat handoff), finance (score), and organization (reputation/politics).

---

## Geoscape System Diagrams

### Time Flow & Mission Lifecycle

```mermaid
graph TB
    START[Game Start] --> TIME[Time Service<br/>5-min ticks]
    
    TIME --> SCHED{Scheduler Check}
    SCHED -->|Mission Template| GEN[Mission Generator]
    SCHED -->|Research Done| RESEARCH[Complete Research]
    SCHED -->|Transfer Arrived| TRANSFER[Deliver Transfer]
    SCHED -->|Month End| FINANCE[Monthly Report]
    
    GEN --> DET{Detection Check}
    DET -->|Radar Coverage| DETECT[Mission Detected]
    DET -->|No Coverage| MISS[Mission Missed]
    
    DETECT --> ALERT[Mission Alert UI]
    ALERT -->|Player Choice| DISPATCH{Dispatch Craft?}
    
    DISPATCH -->|Yes| INTER[Interception Layer]
    DISPATCH -->|No| EXPIRE[Mission Timer Expires]
    
    INTER -->|Craft Win| DEPLOY[Deploy to Battlescape]
    INTER -->|Craft Loss| RETREAT[Craft Destroyed/Retreat]
    
    DEPLOY --> BATTLE[Tactical Mission]
    BATTLE --> RESULT[Mission Results]
    RESULT --> REWARD[Salvage & XP]
    REWARD --> TIME
    
    EXPIRE --> PANIC[Increase Panic]
    MISS --> PANIC
    PANIC --> TIME
    
    FINANCE --> SCORE[Update Score]
    SCORE --> TIME
    
    style TIME fill:#4a90e2
    style BATTLE fill:#e24a4a
    style DETECT fill:#50c878
    style PANIC fill:#ff6b6b
```

### Province & Region System

```mermaid
graph LR
    subgraph "World Layer"
        WORLD[World Map<br/>800x600 viewport]
        PROV[Provinces<br/>Hex-based graph]
        REG[Regions<br/>Funding groups]
    end
    
    subgraph "Province Data"
        COORD[Coordinates<br/>20x20 logical]
        BIOME[Biome Type<br/>Urban/Rural/Coastal]
        ECON[Economy Value<br/>Funding weight]
        POP[Population<br/>Panic multiplier]
        OWN[Ownership<br/>Player/Alien/Neutral]
        ADJ[Adjacency List<br/>Connected provinces]
    end
    
    subgraph "Dynamic State"
        PANIC[Panic Level<br/>0-100]
        MISSION[Active Missions<br/>Timed events]
        RADAR[Radar Coverage<br/>Detection radius]
        PORT[Portal Status<br/>Alien activity]
    end
    
    WORLD --> PROV
    PROV --> REG
    
    PROV --> COORD
    PROV --> BIOME
    PROV --> ECON
    PROV --> POP
    PROV --> OWN
    PROV --> ADJ
    
    PROV --> PANIC
    PROV --> MISSION
    PROV --> RADAR
    PROV --> PORT
    
    style WORLD fill:#4a90e2
    style PANIC fill:#ff6b6b
    style RADAR fill:#50c878
    style PORT fill:#9013fe
```

### Craft Operations Flow

```mermaid
stateDiagram-v2
    [*] --> Ready: Craft at Base
    Ready --> Dispatched: Mission Alert
    
    Dispatched --> Traveling: Route to Province
    Traveling --> Engaged: Arrived at Mission
    
    Engaged --> Interception: UFO Encounter
    Engaged --> DirectDeploy: Ground Mission
    
    Interception --> Victory: UFO Destroyed
    Interception --> Defeat: Craft Damaged
    Interception --> Abort: Player Retreat
    
    Victory --> DirectDeploy
    DirectDeploy --> Battlescape: Deploy Squad
    
    Battlescape --> Returning: Mission Complete
    Defeat --> Returning: Emergency Return
    Abort --> Returning: Manual Abort
    
    Returning --> Maintenance: Arrived at Base
    Maintenance --> Ready: Repairs Complete
    
    Defeat --> Destroyed: Critical Damage
    Destroyed --> [*]
```

---

## Mechanics / Implementation
### World & Provinces
- World map uses a hex-derived province graph anchored to 20×20 logical coordinates (800×600 viewport).
- Each province stores: coordinates, biome, economy value, population, ownership, tags, adjacency list.
- Regions group provinces for funding, mission weighting, and diplomacy.

### Time & Scheduling
- Time advances in deterministic ticks (5-minute increments). Player can run at 1×, 5×, or 30× speed.
- Scheduler queues missions, research completions, transfers, and monthly finance events.
- Seeds: `campaign:<id>:time:<tick>` to replay mission creation exactly.

### Mission Lifecycle
- Mission templates pull from weighted decks keyed to province tags (`urban`, `coastal`, `portal`).
- Detection checks run against active radar coverage and surveillance services.
- Successful detection unlocks interception or direct deployment (for base raids).

### Craft Operations
- Craft dispatch checks province hop distance, fuel reserves, and daily sortie limits.
- Movement is instantaneous in UI but consumes deterministic time (recorded for AI scheduling).
- Returns initiate recovery timers for fuel and repairs.

### Portals & Multi-World Support
- Portals mark alien entry points; they escalate activity until neutralised.
- Future multi-world campaigns share the same scheduler and mission pipeline.

### Grid & Visual Standards
- Viewport: 800×600 pixels (40×30 logical tiles). UI overlays snap to grid.
- Province markers: 20×20 clickable areas with 10×10 icons scaled ×2 at centre.
- Mission timers and tooltips align to tile edges to avoid cursor offset bugs.

## Data & Events
- **Primary Catalogs:** `data/geoscape/worlds.toml`, `provinces.toml`, `regions.toml`, `missions.toml`, `portals.toml`, `craft_operations.toml`.
- **Services:** `geoscape/world_model.lua`, `geoscape/mission_scheduler.lua`, `geoscape/detection_system.lua`, `services/time.lua`, `services/event_bus.lua`.
- **Events:** `geoscape:tick`, `geoscape:mission_spawned`, `geoscape:mission_expired`, `geoscape:province_changed`, `geoscape:portal_escalated`.

## Integration Hooks
- **Love2D State:** Geoscape state owns the main update loop when strategic view is active. Time controls map to keybinds defined in the GUI spec.
- **Data Tables:** `data/geoscape/*.toml` entries map to deterministic mission scheduling and craft routing.
- **Event Bus:** Emits mission lifecycle and time progression events consumed by Interception, Basescape, Economy, and Finance systems.
- **Rendering:** Map drawn using 10×10 province sprites scaled ×2, snapped to 20×20 logical positions.

## Related Reading
- [Basescape README](../basescape/README.md)
- [Interception README](../interception/README.md)
- [Economy README](../economy/README.md)
- [Finance README](../finance/README.md)
- [Organization README](../organization/README.md)

## Tags
`#geoscape` `#missions` `#time` `#grid20x20` `#love2d`
