# Strategic Layer System Diagrams

**Visual reference for understanding system relationships and data flow**

---

## System Overview Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         GEOSCAPE STRATEGIC LAYER                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌────────────────┐        ┌──────────────────┐                   │
│  │   RELATIONS    │◄──────►│ MISSION CAMPAIGN │                   │
│  │    SYSTEM      │        │   & DETECTION    │                   │
│  │  (TASK-026)    │        │   (TASK-027)     │                   │
│  └────────────────┘        └──────────────────┘                   │
│         │                           │                              │
│         │ affects                   │ provides                     │
│         │                           │                              │
│         ▼                           ▼                              │
│  ┌────────────────┐        ┌──────────────────┐                   │
│  │    FUNDING     │        │   INTERCEPTION   │                   │
│  │  MARKETPLACE   │        │     SCREEN       │                   │
│  │   MISSIONS     │        │   (TASK-028)     │                   │
│  └────────────────┘        └──────────────────┘                   │
│                                     │                              │
│                                     │ transitions                  │
│                                     ▼                              │
│                            ┌──────────────────┐                    │
│                            │   BATTLESCAPE    │                    │
│                            │  (Ground Combat) │                    │
│                            └──────────────────┘                    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Relations System Data Flow (TASK-026)

```
┌────────────────────────────────────────────────────────┐
│                  RELATIONS MANAGER                     │
│                                                        │
│  countryRelations:  {USA: 45, China: -20, ...}       │
│  supplierRelations: {WeaponsCorp: 60, ...}           │
│  factionRelations:  {Sectoids: -30, Mutons: -50}     │
└─────┬──────────────────────┬──────────────────┬───────┘
      │                      │                  │
      │ affects              │ affects          │ affects
      ▼                      ▼                  ▼
┌──────────┐          ┌──────────┐       ┌──────────┐
│ COUNTRY  │          │ SUPPLIER │       │ FACTION  │
│ FUNDING  │          │  PRICES  │       │ MISSIONS │
└──────────┘          └──────────┘       └──────────┘
      │                      │                  │
      │ changes              │ changes          │ generates
      ▼                      ▼                  ▼
┌──────────┐          ┌──────────┐       ┌──────────┐
│ Player   │          │ Market   │       │ Mission  │
│ Budget   │          │ Costs    │       │ Spawning │
└──────────┘          └──────────┘       └──────────┘

FEEDBACK LOOP:
Mission Success ──► Country +Relations ──► More Funding ──► Better Equipment
      ▲                                                            │
      └────────────────────────────────────────────────────────────┘

Mission Success ──► Faction -Relations ──► Fewer Missions ──► Easier Campaign
```

---

## Mission Detection Flow (TASK-027)

```
TIMELINE: Weekly Mission Generation
═══════════════════════════════════════════════════════════════

Week 1, Monday:
┌──────────────────────────────────────────────────────┐
│ CAMPAIGN MANAGER: Generate Missions                 │
│                                                      │
│ ┌──────────┐  ┌──────────┐  ┌──────────┐          │
│ │ Mission1 │  │ Mission2 │  │ Mission3 │          │
│ │ Cover:100│  │ Cover:100│  │ Cover:100│          │
│ │ Hidden   │  │ Hidden   │  │ Hidden   │          │
│ └──────────┘  └──────────┘  └──────────┘          │
└──────────────────────────────────────────────────────┘

Daily Turn Processing:
┌──────────────────────────────────────────────────────┐
│ DETECTION MANAGER: Perform Radar Scans              │
│                                                      │
│ ┌────────┐                                          │
│ │ Base   │──► Radar Power: 50, Range: 10 provinces │
│ │ Alpha  │    Scans all missions in range          │
│ └────────┘                                          │
│                                                      │
│ ┌────────┐                                          │
│ │ Craft  │──► Radar Power: 25, Range: 7 provinces  │
│ │ Delta  │    Scans all missions in range          │
│ └────────┘                                          │
└──────────────────────────────────────────────────────┘

Scan Resolution:
┌────────────────────────────────────────────────────────┐
│ Mission1: Distance 5 from Base                         │
│   Effectiveness: 1.0 - (5/10) = 0.5                   │
│   Cover Reduction: 50 × 0.5 = 25                       │
│   New Cover: 100 - 25 = 75                             │
│                                                        │
│ Mission2: Distance 3 from Craft                        │
│   Effectiveness: 1.0 - (3/7) = 0.57                   │
│   Cover Reduction: 25 × 0.57 = 14                      │
│   New Cover: 100 - 14 = 86                             │
│                                                        │
│ Mission3: Out of range                                 │
│   No scan, Cover Regen: +5                             │
│   New Cover: 100 + 5 = 105                             │
└────────────────────────────────────────────────────────┘

Detection Moment:
┌────────────────────────────────────────────────────────┐
│ After 4 Days of Scanning:                              │
│                                                        │
│ Mission1: Cover 0 ──► DETECTED! Shows on map          │
│ Mission2: Cover 35 ──► Still hidden                    │
│ Mission3: Cover 120 ──► Well hidden (far from bases)  │
└────────────────────────────────────────────────────────┘
```

---

## Interception Screen Layout (TASK-028)

```
SCREEN: 960×720 pixels (40×30 grid cells at 24px each)
═══════════════════════════════════════════════════════

┌────────────────────────────────────────────────────────┐
│ Turn: 3  │  Time: 15 min  │  PLAYER PHASE            │ 0-24px
├─────────────────────┬──────────────────────────────────┤
│                     │                                  │
│   AIR LAYER         │                                  │
│   (0-240px Y)       │                                  │ 24-264px
│                     │                                  │
│  ┌──────┐          │                     ┌──────┐    │
│  │Craft │          │                     │ UFO  │    │
│  │AP:4  │          │                     │AP:3  │    │
│  │HP:150│          │                     │HP:85 │    │
│  └──────┘          │                     └──────┘    │
│                     │                                  │
├─────────────────────┼──────────────────────────────────┤
│                     │                                  │
│  LAND/WATER LAYER   │                                  │
│  (240-480px Y)      │                                  │ 264-504px
│                     │                                  │
│  ┌──────┐          │                     ┌──────┐    │
│  │Base  │          │                     │Site  │    │
│  │AP:4  │          │                     │AP:4  │    │
│  │HP:1000│         │                     │HP:200│    │
│  └──────┘          │                     └──────┘    │
│                     │                                  │
├─────────────────────┼──────────────────────────────────┤
│                     │                                  │
│  UNDERGROUND LAYER  │                                  │
│  (480-720px Y)      │                                  │ 504-720px
│                     │                                  │
│                     │                     ┌──────┐    │
│                     │                     │A.Base│    │
│                     │                     │AP:4  │    │
│                     │                     │HP:2000│   │
│                     │                     └──────┘    │
│                     │                                  │
├─────────────────────┴──────────────────────────────────┤
│ COMBAT LOG:                                           │
│ > Player-Craft used Cannon on Enemy-UFO (-30 HP)     │
│ > Enemy-UFO used Plasma on Player-Craft (-45 HP)     │
│                                                        │
│              [END TURN]           [RETREAT]           │
└────────────────────────────────────────────────────────┘

PLAYER ZONE          DIVIDER     ENEMY ZONE
(X: 48-432)         (X: 480)    (X: 528-912)
```

---

## Weapon Targeting Matrix (TASK-028)

```
ALTITUDE TARGETING RESTRICTIONS
═══════════════════════════════════════════════════════

         TARGET →
         AIR    LAND   UNDER
FROM  ┌──────┬──────┬──────┐
      │      │      │      │
AIR   │  ✓   │  ✓   │  ✗   │  AIR-to-AIR: Dogfighting
      │      │      │      │  AIR-to-LAND: Bombing
      ├──────┼──────┼──────┤
      │      │      │      │
LAND  │  ✓   │  ✓   │  ✗   │  LAND-to-AIR: Anti-Aircraft
      │      │      │      │  LAND-to-LAND: Ground Combat
      ├──────┼──────┼──────┤
      │      │      │      │
UNDER │  ✗   │  ✗   │  ✓   │  Special weapons only
      │      │      │      │
      └──────┴──────┴──────┘

EXAMPLE WEAPONS:
┌────────────────────────────────────────────────────┐
│ Cannon        [AIR] → [AIR]     30 DMG, 2 AP      │
│ Missile       [AIR] → [AIR]     80 DMG, 3 AP      │
│ Bomb          [AIR] → [LAND]    100 DMG, 3 AP     │
│ Base Laser    [LAND] → [AIR]    50 DMG, 2 AP      │
│ Artillery     [LAND] → [LAND]   70 DMG, 3 AP      │
│ Drill         [ANY] → [UNDER]   60 DMG, 4 AP      │
└────────────────────────────────────────────────────┘
```

---

## Turn Order & Phase Flow (TASK-028)

```
TURN STRUCTURE
═══════════════════════════════════════════════════════

Turn N:
┌───────────────────────────────────────────────────┐
│ 1. START TURN                                     │
│    • Reset all units: AP = 4                      │
│    • Regenerate energy: +10-20                    │
│    • Reduce cooldowns: -1 turn                    │
│    • Game time: +5 minutes                        │
└───────────────────────────────────────────────────┘
         │
         ▼
┌───────────────────────────────────────────────────┐
│ 2. PLAYER PHASE                                   │
│    • Select unit (craft/base)                     │
│    • Choose weapon (press 1-5)                    │
│    • Select target (click enemy)                  │
│    • Repeat until AP exhausted or pass            │
│    • Press [End Turn] when done                   │
└───────────────────────────────────────────────────┘
         │
         ▼
┌───────────────────────────────────────────────────┐
│ 3. ENEMY PHASE                                    │
│    • AI controls enemy units                      │
│    • For each enemy unit:                         │
│      - Find valid targets                         │
│      - Select highest damage weapon               │
│      - Attack random target                       │
│    • Automatic, no player input                   │
└───────────────────────────────────────────────────┘
         │
         ▼
┌───────────────────────────────────────────────────┐
│ 4. RESOLUTION PHASE                               │
│    • Check win conditions:                        │
│      - All enemies dead? → Victory!               │
│      - All player units dead? → Defeat            │
│    • If neither:                                  │
│      - Continue to next turn                      │
└───────────────────────────────────────────────────┘
         │
         ▼
      Turn N+1

PLAYER OPTIONS AT ANY TIME:
• [Retreat] → Exit to Geoscape (keep current damage)
```

---

## Complete Game Flow Integration

```
FULL GAMEPLAY CYCLE
═══════════════════════════════════════════════════════

1. GEOSCAPE - WEEK START (Monday)
   ┌─────────────────────────────────────────┐
   │ Campaign Manager:                       │
   │ • Generate 2-7 missions (based on       │
   │   faction relations)                    │
   │ • Missions spawn with 100 cover         │
   │ • All missions hidden                   │
   └─────────────────────────────────────────┘
             │
             ▼
2. GEOSCAPE - DAILY TURNS
   ┌─────────────────────────────────────────┐
   │ Detection Manager:                      │
   │ • Scan from all bases                   │
   │ • Scan from all crafts                  │
   │ • Reduce mission cover values           │
   │                                         │
   │ Time Manager:                           │
   │ • Advance calendar 1 day                │
   │ • Process base operations               │
   │ • Update craft movements                │
   │ • Decay relations (TASK-026)            │
   └─────────────────────────────────────────┘
             │
             ▼
3. GEOSCAPE - MISSION DETECTED
   ┌─────────────────────────────────────────┐
   │ Mission cover ≤ 0:                      │
   │ • Icon appears on map                   │
   │ • Player can click for info             │
   │ • Countdown timer shows days remaining  │
   └─────────────────────────────────────────┘
             │
             ▼
4. PLAYER DECISION
   ┌─────────────────────────────────────────┐
   │ Options:                                │
   │ A) Deploy craft → Interception          │
   │ B) Ignore mission → Eventually expires  │
   │ C) Direct assault → Battlescape         │
   └─────────────────────────────────────────┘
             │
             ▼ (Option A chosen)
5. INTERCEPTION SCREEN (TASK-028)
   ┌─────────────────────────────────────────┐
   │ • Player crafts vs. mission units       │
   │ • Turn-based combat                     │
   │ • AP/Energy management                  │
   │ • Altitude-based tactics                │
   │                                         │
   │ Result:                                 │
   │ A) Victory → Choice: Battlescape or End │
   │ B) Defeat → Return to Geoscape          │
   │ C) Retreat → Return to Geoscape         │
   └─────────────────────────────────────────┘
             │
             ▼ (Option A → Battlescape chosen)
6. BATTLESCAPE
   ┌─────────────────────────────────────────┐
   │ • Ground tactical combat                │
   │ • Mission objective completion          │
   │                                         │
   │ Result:                                 │
   │ • Success → Rewards + Relations up      │
   │ • Failure → Penalties + Relations down  │
   └─────────────────────────────────────────┘
             │
             ▼
7. RELATIONS UPDATE (TASK-026)
   ┌─────────────────────────────────────────┐
   │ Mission Success:                        │
   │ • Country relations +5 to +15           │
   │ • Faction relations -5 to -15           │
   │ • Unlock funding increases              │
   │ • Trigger mission count decrease        │
   │                                         │
   │ Mission Failure:                        │
   │ • Country relations -3 to -10           │
   │ • Faction relations +3 to +10           │
   │ • Funding decreases                     │
   │ • Trigger more missions                 │
   └─────────────────────────────────────────┘
             │
             ▼
8. RETURN TO GEOSCAPE
   ┌─────────────────────────────────────────┐
   │ • Mission removed from map              │
   │ • Rewards/penalties applied             │
   │ • Continue daily turn cycle             │
   │ • Wait for next Monday for new missions │
   └─────────────────────────────────────────┘
             │
             └──► Back to step 2 (Daily Turns)

PARALLEL SYSTEMS:
• Relations decay daily
• Funding calculated monthly
• Supplier prices update with relations
• New missions spawn weekly
• Multiple missions can be active
• Player chooses which to pursue
```

---

## Data Structures

### Relations Manager State
```lua
RelationsManager = {
    -- Relations storage
    countryRelations = {
        ["USA"] = 45,
        ["China"] = -20,
        ["EU"] = 30,
        -- ... more countries
    },
    
    supplierRelations = {
        ["WeaponsCorp"] = 60,
        ["TechIndustries"] = 25,
        -- ... more suppliers
    },
    
    factionRelations = {
        ["Sectoids"] = -30,
        ["Mutons"] = -50,
        ["Floaters"] = -15,
        -- ... more factions
    },
    
    -- Configuration
    config = {
        country = { decayRate = 0.05 },
        supplier = { decayRate = 0.1 },
        faction = { decayRate = 0.15 }
    }
}
```

### Mission Entity State
```lua
Mission = {
    id = "mission_001",
    name = "Scout UFO Alpha",
    type = "ufo",              -- "site", "ufo", "base"
    faction = FactionRef,
    
    -- Location
    province = ProvinceRef,
    position = {x = 1200, y = 800},
    biome = "desert",
    
    -- Detection
    coverValue = 85,           -- 0-100
    coverMax = 100,
    coverRegen = 3,            -- per day
    detected = false,
    state = "hidden",          -- "hidden", "detected", "active"
    
    -- Lifecycle
    spawnDay = 1,
    daysActive = 5,
    duration = 7,              -- expires after 7 days
    
    -- Combat (for interception)
    altitude = "air",          -- "air", "land", "underground", "underwater"
    health = 100,
    maxHealth = 100,
    armor = 5,
    weapons = {
        {name="Plasma", damage=40, apCost=2, energyCost=10}
    },
    ap = 4,
    energy = 80
}
```

### Interception Unit State
```lua
InterceptionUnit = {
    id = "craft_interceptor_1",
    name = "Interceptor Alpha",
    type = "craft",            -- "craft", "base", "ufo", "site", "alien_base"
    side = "player",           -- "player", "enemy"
    
    -- Position
    altitude = "air",
    position = 1,              -- for multi-unit display
    
    -- Combat stats
    health = 150,
    maxHealth = 150,
    armor = 10,
    shields = 50,
    maxShields = 50,
    
    -- Action system
    ap = 4,
    maxAP = 4,
    energy = 100,
    maxEnergy = 100,
    energyRegen = 10,
    
    -- Equipment
    weapons = {
        {id="cannon", name="Cannon", damage=30, apCost=2, energyCost=10, cooldown=0},
        {id="missile", name="Missile", damage=80, apCost=3, energyCost=25, cooldown=2}
    },
    
    -- Cooldown tracking
    cooldowns = {
        ["missile"] = 0        -- turns remaining
    },
    
    -- State
    isDestroyed = false,
    canAct = true,
    
    -- Reference to source entity
    sourceEntity = CraftRef
}
```

---

## Performance Optimization Notes

### Relations System
- O(1) lookups using hash tables
- Batch updates (all relations) once per turn
- No per-frame calculations

### Mission Detection
- O(n×m) where n=scanners, m=missions
- Typical: 5 bases × 10 missions = 50 checks/turn
- Spatial partitioning possible if >100 missions

### Interception Screen
- Maximum ~10 units on screen
- Simple rendering (sprites + UI)
- Turn-based: no per-frame logic updates
- AI runs once per enemy phase

---

**Last Updated:** October 13, 2025  
**Related Tasks:** TASK-026, TASK-027, TASK-028  
**See Also:** STRATEGIC_LAYER_IMPLEMENTATION_PLAN.md, STRATEGIC_LAYER_QUICK_REFERENCE.md
