# Procedural Generation Diagrams

**Created:** October 21, 2025  
**Purpose:** Visual representation of procedural content generation pipelines

---

## 1. Map Generation Pipeline

### Diagram: From Biome to Playable Battlefield

```
┌─────────────────────────────────────────────────────────────────────┐
│              MAP GENERATION PIPELINE (Geoscape → Battle)             │
└─────────────────────────────────────────────────────────────────────┘

INPUT: Mission Deployment
├─ Mission location (province hex)
├─ Mission type (recon, crash site, base defense, etc.)
├─ Difficulty level (1-5 stars)
├─ Enemy faction type
└─ Campaign context (month/season)

STAGE 1: BIOME SELECTION
┌────────────────────────────────────┐
│ Province → Biome Mapping           │
│                                    │
│ World contains biome distribution: │
│ • Desert, Jungle, Mountain         │
│ • Urban, Forest, Tundra            │
│ • Underground, Ocean               │
│                                    │
│ Province hex → Select biome        │
│ (or random from region options)    │
└────────┬───────────────────────────┘
         │
         └─→ Random Seed = hash(mission_id)
             (ensures repeatability)

STAGE 2: TERRAIN GENERATION
┌────────────────────────────────────┐
│ Biome → Terrain Type Selection     │
│                                    │
│ Forest biome options:              │
│ • Dense trees                      │
│ • Sparse clearing                  │
│ • Rocky outcrops                   │
│ • Water features                   │
│                                    │
│ Desert biome options:              │
│ • Flat sandy plains                │
│ • Sand dunes                       │
│ • Rocky plateaus                   │
│ • Canyon features                  │
│                                    │
│ Terrain selected based on:         │
│ • Biome type                       │
│ • Difficulty level                 │
│ • Mission type                     │
│ • Random variation                 │
└────────┬───────────────────────────┘
         │
         └─→ Terrain rules engine

STAGE 3: MAPSCRIPT SELECTION
┌────────────────────────────────────┐
│ Terrain → MapScript Rules          │
│                                    │
│ MapScript = procedural script that │
│ defines map generation rules       │
│                                    │
│ Each terrain type has associated   │
│ scripts (e.g., "dense_forest.lua")│
│                                    │
│ Script contains:                   │
│ • Tile placement patterns          │
│ • Obstacle distributions           │
│ • Cover element placement          │
│ • Spawn point locations            │
│ • Mission objective placement      │
│                                    │
│ Selected script based on:          │
│ • Terrain selection                │
│ • Difficulty scaling               │
│ • Mission requirements             │
└────────┬───────────────────────────┘
         │
         └─→ Apply procedural rules

STAGE 4: MAPBLOCK ASSEMBLY
┌────────────────────────────────────┐
│ MapScript Rules → MapBlock Grid    │
│                                    │
│ Generate 4×4 to 7×7 grid of:      │
│ • Tile types (grass, rock, water) │
│ • Terrain features (trees, walls) │
│ • Cover elements (rocks, rubble)  │
│                                    │
│ For each cell:                     │
│ ├─ Place terrain tile             │
│ ├─ Add vegetation/obstacles       │
│ ├─ Calculate cover values         │
│ └─ Mark walkability               │
│                                    │
│ Grid dimensions based on:          │
│ • Difficulty (harder = larger)    │
│ • Mission type                     │
│ • Random variation                 │
└────────┬───────────────────────────┘
         │
         └─→ MapBlock data structure

STAGE 5: MAPBLOCK TRANSFORMATIONS
┌────────────────────────────────────┐
│ Apply Random Transformations       │
│                                    │
│ Each MapBlock can be:              │
│ • Rotated (0°, 90°, 180°, 270°)   │
│ • Mirrored (H, V, both)           │
│ • Scaled (1x, 1.5x, 2x)           │
│                                    │
│ This creates variation while       │
│ reusing MapBlock definitions       │
│                                    │
│ Transformations selected by:       │
│ • Random seed                      │
│ • Difficulty requirements          │
│ • Mission objective constraints    │
└────────┬───────────────────────────┘
         │
         └─→ Transformed MapBlock

STAGE 6: ENTITY PLACEMENT
┌────────────────────────────────────┐
│ Place Units, Items, Objectives    │
│                                    │
│ Unit Placement:                    │
│ ├─ Player spawn area (start zone) │
│ ├─ Enemy spawn areas (varied)     │
│ ├─ Civilian positions (if needed) │
│ └─ Reinforcement spawn points     │
│                                    │
│ Item Placement:                    │
│ ├─ Weapons/ammo caches           │
│ ├─ Medical supplies              │
│ ├─ Intel/artifacts               │
│ └─ Environmental hazards         │
│                                    │
│ Objective Placement:               │
│ ├─ Primary objective location     │
│ ├─ Secondary objective locations │
│ └─ Victory point definitions      │
└────────┬───────────────────────────┘
         │
         └─→ Populated battlefield

STAGE 7: VALIDATION & FINALIZATION
┌────────────────────────────────────┐
│ Verify Playable Map                │
│                                    │
│ Validation checks:                 │
│ ├─ Is map connected? (no islands) │
│ ├─ Valid spawn areas? (no walls)  │
│ ├─ Balanced player/enemy starts?  │
│ ├─ Objectives accessible?         │
│ └─ Performance acceptable? (<30MB)│
│                                    │
│ If validation fails:               │
│ └─→ Regenerate with new seed      │
│                                    │
│ If validation passes:              │
│ └─→ Ready for battle              │
└────────┬───────────────────────────┘
         │
         ▼
OUTPUT: Playable Battlescape Map
├─ Tile grid with terrain data
├─ Obstacle/cover definitions
├─ Unit spawn locations
├─ Objective markers
└─ Performance metrics


EXAMPLE TRANSFORMATION SEQUENCE:
┌────────────────────────────────────────────────────┐
│ Forest Dense MapBlock (4×4)                        │
├────────────────────────────────────────────────────┤
│                                                    │
│ Original:        Rotation 90°:    Rotation 180°:  │
│ T T T T          T W T T          R T T R         │
│ T T W T    →     T T T W    →     T W T T         │
│ T W T T          T T T T          T T T W         │
│ T T T W          W T T T          T T T T         │
│                                                    │
│ Then mirror horizontally, creating 8 variants    │
│ from single MapBlock definition                   │
│                                                    │
│ T = Tree, W = Water, R = Rock                    │
└────────────────────────────────────────────────────┘
```

---

## 2. Mission Generation Flow

### Diagram: From Campaign Context to Mission Spawning

```
MISSION GENERATION SYSTEM

INPUT: Campaign State (Daily)
├─ Current calendar date
├─ Active alien activity levels
├─ Country/faction relationships
├─ Difficulty level
├─ Campaign progress percentage
└─ Random seed (from date)

┌─────────────────────────────────────┐
│ STAGE 1: MISSION TYPE SELECTION     │
├─────────────────────────────────────┤
│ Possible mission types:             │
│ 1. Site Investigation               │
│ 2. UFO Crash Recovery               │
│ 3. Alien Base Assault               │
│ 4. Base Defense                     │
│ 5. Hostage Rescue                   │
│ 6. Bombing Run                      │
│ 7. Escort Mission                   │
│ 8. Artifact Recovery                │
│                                     │
│ Selection based on:                 │
│ • Campaign month (8% chance each)   │
│ • Alien activity (escalates types) │
│ • Country politics (influences)    │
│ • Available intelligence           │
│ • Random variation                 │
└────────┬────────────────────────────┘
         │
         ▼

┌─────────────────────────────────────┐
│ STAGE 2: LOCATION SELECTION         │
├─────────────────────────────────────┤
│ Select mission location (province)  │
│ on the Geoscape hexagonal grid      │
│                                     │
│ Selection algorithm:                │
│ ├─ Filter by faction territory      │
│ ├─ Weight by threat level           │
│ ├─ Prefer unexplored areas (7%)    │
│ ├─ Prefer allied territory (15%)   │
│ ├─ Prefer neutral areas (30%)      │
│ └─ Prefer hostile territory (48%)  │
│                                     │
│ Result: 1 province hex selected    │
│ (mission destination on Geoscape)  │
└────────┬────────────────────────────┘
         │
         ▼

┌─────────────────────────────────────┐
│ STAGE 3: DIFFICULTY SCALING         │
├─────────────────────────────────────┤
│ Calculate mission difficulty (1-10) │
│                                     │
│ Based on:                           │
│ • Campaign month (escalates over    │
│   time: month 1 = avg 3, month 12=7│
│ • Location threat level            │
│ • Player org level (higher = harder)│
│ • Player resources (affects scaling)│
│ • Previous mission outcomes         │
│                                     │
│ Result: Difficulty = 1-10 rating   │
│ Used for:                           │
│ • Enemy count/strength              │
│ • Map size/complexity               │
│ • Rewards/reputation               │
└────────┬────────────────────────────┘
         │
         ▼

┌─────────────────────────────────────┐
│ STAGE 4: ENEMY FORCE COMPOSITION    │
├─────────────────────────────────────┤
│ Determine enemy units for mission   │
│                                     │
│ Algorithm:                          │
│ ├─ Base unit count = difficulty × 2│
│ ├─ Add elite units if mission_type │
│ │  is alien_base or ufo_crash      │
│ ├─ Select unit types (sectoid,     │
│ │  muton, ethereal, etc.) based on │
│ │  campaign progression            │
│ ├─ Assign weapons/armor by type    │
│ ├─ Calculate team morale/abilities │
│ └─ Set behavior mode (aggressive,  │
│    defensive, etc.)                │
│                                     │
│ Result: Enemy force definition      │
└────────┬────────────────────────────┘
         │
         ▼

┌─────────────────────────────────────┐
│ STAGE 5: REWARD CALCULATION         │
├─────────────────────────────────────┤
│ Calculate mission rewards           │
│                                     │
│ Reward types:                       │
│ • Base credits (difficulty × 100)  │
│ • Research intel points            │
│ • Artifact chance (20% + difficulty│
│ • Alien remains (autopsy value)    │
│ • Reputation gain (country relations
│                                     │
│ Multipliers:                        │
│ • Campaign progress (scales up)    │
│ • Relations modifier (0.5x to 2x)  │
│ • Difficulty bonus (1x to 3x)      │
│                                     │
│ Result: Reward tier assigned        │
└────────┬────────────────────────────┘
         │
         ▼

┌─────────────────────────────────────┐
│ STAGE 6: MISSION PARAMETERS         │
├─────────────────────────────────────┤
│ Final mission definition            │
│                                     │
│ Contains:                           │
│ • Mission ID (unique hash)         │
│ • Type (site investigation, etc.)  │
│ • Location (province hex)          │
│ • Duration (minutes to complete)   │
│ • Difficulty rating (1-10)         │
│ • Enemy force composition          │
│ • Rewards (credits, intel, etc.)  │
│ • Expiration time (turns remaining)│
│ • Status (available/expired/failed)│
│ • Biome/terrain type               │
│ • Random seed (for map generation) │
│                                     │
│ Result: Mission record created     │
└────────┬────────────────────────────┘
         │
         ▼

OUTPUT: Mission Added to Active List
├─ Appears in Geoscape mission list
├─ Can be selected and deployed to
├─ Generates map when deployed
├─ Expires after N turns
└─ Records outcome for campaign


MISSION EXPIRATION RULES:
┌─────────────────────────────┐
│ Mission expires if:         │
│ • Time limit reached        │
│ • Objective completed       │
│ • Location evacuated        │
│ • Superseded by new threat  │
│                             │
│ Upon expiration:            │
│ • Mission removed from list │
│ • Campaign consequences     │
│   (country relations shift)│
│ • Resources claimed by     │
│   aliens (salvage lost)    │
└─────────────────────────────┘


SAMPLE MISSION PARAMETERS:
┌──────────────────────────────────────────┐
│ Mission: UFO_CRASH_001                   │
│ Type: UFO Crash Recovery                 │
│ Location: [45, 23] (Province hex)        │
│ Duration: 120 minutes                    │
│ Difficulty: 6/10                         │
│ Enemies: 8 Sectoid + 2 Muton            │
│ Rewards: 2000 credits + Intel points    │
│ Expiration: 5 turns remaining            │
│ Biome: Forest                            │
│ Seed: 0x4a3f2b1c                        │
└──────────────────────────────────────────┘
```

---

## 3. Entity Generation System

### Diagram: Unit and Item Generation

```
┌────────────────────────────────────────────────────┐
│  ENTITY GENERATION (Units, Items, Upgrades)        │
└────────────────────────────────────────────────────┘

PLAYER UNIT GENERATION (From Basescape)
├─ Input: Squad size (1-12 units max)
│
├─ For each unit slot:
│  ├─ Use existing unit from barracks
│  ├─ Or hire new soldier (0 XP, base stats)
│  ├─ Load equipped items from inventory
│  ├─ Calculate unit stats (XP → accuracy bonus)
│  └─ Assign squad role/specialty
│
└─ Output: Player squad ready for battle

ENEMY UNIT GENERATION (From Campaign)
├─ Input: Mission difficulty, location
│
├─ Determine enemy type:
│  ├─ Sectoid (basic humanoid)
│  ├─ Muton (heavy fighter)
│  ├─ Ethereal (psion)
│  ├─ Reaper (creature)
│  └─ Cyberdisc (mechanical)
│
├─ Assign rank:
│  ├─ Rank 0: Grunt
│  ├─ Rank 1: Warrior
│  ├─ Rank 2: Elite
│  └─ Rank 3: Commander
│
├─ Calculate stats:
│  ├─ Health (rank modifier + random ±20%)
│  ├─ Accuracy (rank * 15 + base)
│  ├─ Armor (rank * 2 points)
│  └─ Special abilities (based on rank)
│
├─ Assign equipment:
│  ├─ Primary weapon (based on rank)
│  ├─ Secondary weapon (30% chance)
│  ├─ Armor (based on rank)
│  ├─ Grenade/equipment (varies)
│  └─ Ammo (full magazines)
│
└─ Output: Enemy unit ready for battle

ITEM GENERATION FOR MISSIONS
├─ Cached items:
│  ├─ Ammunition boxes
│  ├─ Medical supplies
│  ├─ Grenades
│  ├─ Equipment
│  └─ Artifacts
│
├─ Spawn item:
│  ├─ Select item (weighted by type)
│  ├─ Place on map (random accessibility)
│  ├─ Mark as searchable/pickable
│  └─ Add to objective rewards
│
└─ Output: Items scattered across battlefield

TECHNOLOGY RESEARCH TREES
├─ Research path structure:
│  ├─ Tier 1: Basic tech (weapons, armor, 5 items)
│  ├─ Tier 2: Intermediate (better weapons, new tactics)
│  ├─ Tier 3: Advanced (laser, plasma, heavy armor)
│  ├─ Tier 4: Exotic (alien tech, psionics, robotics)
│  └─ Tier 5: Ultimate (late-game game-changers)
│
├─ Research progression:
│  ├─ Each research takes 7-30 days
│  ├─ Requires scientists (assigned to research labs)
│  ├─ Can be accelerated with funding
│  ├─ Prerequisites must be completed
│  └─ Unlocks manufacturing
│
└─ Output: Unlocked tech → Available for manufacturing

MANUFACTURING GENERATION
├─ Manufacturing queue:
│  ├─ Add item to queue
│  ├─ Requires research completion
│  ├─ Takes time (base + size modifier)
│  ├─ Requires engineers and resources
│  └─ Can be accelerated with funding
│
├─ Production pipeline:
│  ├─ Day 1: 25% complete
│  ├─ Day 2: 50% complete
│  ├─ Day 3: 75% complete
│  └─ Day 4: 100% - Item completed, added to inventory
│
└─ Output: Manufactured items in inventory


PROGRESSION CURVES (Examples)

UNIT STATS BY RANK:
┌────────┬────────┬────────┬────────┬────────┐
│ Rank   │ Health │ Armor  │ Acc % │ Ammo  │
├────────┼────────┼────────┼────────┼────────┤
│ Grunt  │ 50     │ 0      │ 60%   │ 60    │
│ Warrior│ 65     │ 3      │ 75%   │ 90    │
│ Elite  │ 80     │ 6      │ 85%   │ 120   │
│ Commander│100  │ 10     │ 95%   │ 180   │
└────────┴────────┴────────┴────────┴────────┘

RESEARCH DURATION BY TIER:
┌────────┬──────────────┬──────────────────┐
│ Tier   │ Base Days    │ With Full Lab    │
├────────┼──────────────┼──────────────────┤
│ Tier 1 │ 7-10 days    │ 3-5 days         │
│ Tier 2 │ 10-15 days   │ 5-8 days         │
│ Tier 3 │ 15-20 days   │ 8-12 days        │
│ Tier 4 │ 20-30 days   │ 12-15 days       │
│ Tier 5 │ 30-40 days   │ 15-20 days       │
└────────┴──────────────┴──────────────────┘
```

---

## Summary

The procedural generation systems create dynamic, replayable content:

1. **Map Generation:** Biome → Terrain → MapScript → MapBlocks → Placement
2. **Mission Generation:** Context → Type → Location → Difficulty → Rewards
3. **Entity Generation:** Units, items, tech unlocks based on campaign state
4. **Progression Curves:** Consistent scaling from early to late game

These pipelines ensure:
- Replayability (each playthrough is different)
- Balance (difficulty scales with campaign progression)
- Variety (multiple systems provide content variation)
- Performance (efficient regeneration of content)

---

**Related Documentation:**
- `wiki/systems/Geoscape.md` - Mission system details
- `wiki/systems/Battlescape.md` - Map generation details
- `engine/battlescape/mission_map_generator.lua` - Implementation
- `engine/geoscape/mission_manager.lua` - Mission system implementation
