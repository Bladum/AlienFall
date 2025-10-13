# Map Generation System - Visual Flow Diagrams

**Created:** October 13, 2025  
**Purpose:** Visual representation of map generation pipeline

---

## Complete Generation Pipeline

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        GEOSCAPE: Mission Selection                      │
│                                                                         │
│  Player selects mission in province:                                   │
│    - Province: "Central Europe"                                        │
│    - Biome: "urban"                                                    │
│    - Mission Type: "ufo_crash"                                         │
│    - Mission Size: "medium" (5×5 grid)                                 │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                    STEP 1: Terrain Selection                            │
│                                                                         │
│  BiomeSystem.selectTerrain(biome="urban", override="ufo_crash")        │
│                                                                         │
│  Urban Biome Weights:           Mission Override:                      │
│    - urban_downtown    (40%)  → FORCED: "ufo_crash_urban"             │
│    - urban_residential (30%)    (UFO crash forces specific terrain)    │
│    - urban_industrial  (20%)                                           │
│    - urban_park        (10%)                                           │
│                                                                         │
│  RESULT: terrain = "ufo_crash_urban"                                   │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                 STEP 2: MapBlock Pool Filtering                         │
│                                                                         │
│  MapBlockFilter.byTerrain(allBlocks, terrain="ufo_crash_urban")        │
│                                                                         │
│  Total MapBlocks: 120                                                  │
│  ↓ Filter by tags: ["ufo", "crash", "urban"]                          │
│  Eligible: 18 blocks                                                   │
│  ↓ Filter by difficulty: 1-3                                           │
│  Eligible: 15 blocks                                                   │
│                                                                         │
│  RESULT: mapBlockPool = 15 eligible MapBlocks                          │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                 STEP 3: MapScript Selection                             │
│                                                                         │
│  TerrainSystem.selectMapScript(terrain="ufo_crash_urban")              │
│                                                                         │
│  Available MapScripts for "ufo_crash_urban":                           │
│    - ufo_crash_city_center  (40%) ← SELECTED (random weighted)        │
│    - ufo_crash_industrial   (30%)                                      │
│    - ufo_crash_residential  (20%)                                      │
│    - ufo_crash_park         (10%)                                      │
│                                                                         │
│  RESULT: mapScript = "ufo_crash_city_center"                           │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────┐
│              STEP 4: MapScript Execution - Build Grid                   │
│                                                                         │
│  MapScriptEngine.execute(mapScript, mapBlockPool)                      │
│                                                                         │
│  MapScript "ufo_crash_city_center" defines 5×5 grid:                   │
│                                                                         │
│    Grid Layout (5×5 MapBlocks):                                        │
│    ┌────────┬────────┬────────┬────────┬────────┐                     │
│    │ Bldg-1 │ Road-1 │ Crash-1│ Road-2 │ Bldg-2 │  Priority 1: Crash  │
│    ├────────┼────────┼────────┼────────┼────────┤  Priority 2: Roads  │
│    │ Bldg-3 │ Debris │ UFO ★  │ Debris │ Bldg-4 │  Priority 3: Debris │
│    ├────────┼────────┼────────┼────────┼────────┤  Priority 4: Bldgs  │
│    │ Road-3 │ Debris │ Fire-1 │ Debris │ Road-4 │  Priority 5: Filler │
│    ├────────┼────────┼────────┼────────┼────────┤                     │
│    │ Bldg-5 │ Park-1 │ Road-5 │ Park-2 │ Bldg-6 │  ★ = UFO MapBlock   │
│    ├────────┼────────┼────────┼────────┼────────┤  LZ = Landing Zone  │
│    │ LZ-1   │ Road-6 │ Bldg-7 │ Road-7 │ LZ-2   │                     │
│    └────────┴────────┴────────┴────────┴────────┘                     │
│                                                                         │
│  Landing Zones: (1,5), (5,5)                                           │
│  Objectives: (3,2) = UFO, (3,3) = Fire                                 │
│  AI Priority: (3,2)=10, (2,2)=7, (4,2)=7                               │
│                                                                         │
│  RESULT: mapBlockGrid = 5×5 array of MapBlock references               │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────┐
│            STEP 5: MapBlock Transformations (Random)                    │
│                                                                         │
│  For each MapBlock in grid (50% chance):                               │
│    - Rotate 90°, 180°, or 270°                                         │
│    - Mirror Horizontal or Vertical                                     │
│                                                                         │
│  Example: Bldg-1 (top-left) → Rotated 90° clockwise                   │
│           Road-1 → Mirrored horizontally                               │
│           UFO → No transformation (always original orientation)        │
│                                                                         │
│  RESULT: Transformed MapBlocks in grid                                 │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────┐
│              STEP 6: Battlefield Assembly - Copy Tiles                  │
│                                                                         │
│  BattlefieldAssembler.assemble(mapBlockGrid)                           │
│                                                                         │
│  Grid: 5×5 MapBlocks = 5 × 15 tiles = 75×75 battlefield               │
│                                                                         │
│  For each MapBlock at grid position (bx, by):                          │
│    startX = (bx - 1) × 15 + 1                                          │
│    startY = (by - 1) × 15 + 1                                          │
│    Copy 15×15 tiles from MapBlock to battlefield[startY..][startX..]  │
│                                                                         │
│  Example: UFO MapBlock at grid (3, 2)                                  │
│    startX = (3-1) × 15 + 1 = 31                                        │
│    startY = (2-1) × 15 + 1 = 16                                        │
│    Copy UFO tiles to battlefield[16-30][31-45]                         │
│                                                                         │
│  RESULT: battlefield = 75×75 tile array + sector tracking              │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                STEP 7: Object Placement from MapBlocks                  │
│                                                                         │
│  ObjectPlacer.placeAll(battlefield, mapBlockGrid)                      │
│                                                                         │
│  UFO MapBlock defines objects:                                         │
│    - (7, 7): "elerium_115_canister" (green item)                      │
│    - (8, 8): "alien_alloys_fragment" (metal debris)                   │
│    - (5, 10): "plasma_rifle" (weapon on ground)                       │
│                                                                         │
│  World Position Calculation:                                           │
│    UFO at grid (3, 2) → world offset (31, 16)                         │
│    Object at local (7, 7) → world (31+7-1, 16+7-1) = (37, 22)        │
│                                                                         │
│  RESULT: battlefield.objects = array of placed objects                 │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────┐
│               STEP 8: Team Creation & Assignment                        │
│                                                                         │
│  Battlefield.initializeTeams(missionConfig)                            │
│                                                                         │
│  Create Teams:                                                         │
│    Team 1: "XCOM Squad" (PLAYER side, GREEN color)                    │
│    Team 2: "Sectoids" (ENEMY side, RED color)                         │
│    Team 3: "Floaters" (ENEMY side, YELLOW color)                      │
│    Team 4: "Civilians" (NEUTRAL side, WHITE color)                    │
│                                                                         │
│  Assign Units:                                                         │
│    XCOM Squad: 8 soldiers from mission config                         │
│    Sectoids: 6 aliens (small UFO crew)                                │
│    Floaters: 4 aliens (crash survivors)                               │
│    Civilians: 12 NPCs (city population)                               │
│                                                                         │
│  RESULT: 4 BattleTeams with assigned units                             │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                  STEP 9: Unit Placement on Battlefield                  │
│                                                                         │
│  UnitPlacer.placePlayerUnits(battlefield, xcomUnits, landingZones)     │
│  UnitPlacer.placeEnemyUnits(battlefield, alienUnits, aiPriority)       │
│                                                                         │
│  Player Units (XCOM):                                                  │
│    Landing Zone 1 (grid 1,5) → world (1, 61)                          │
│      - 4 soldiers in bottom-left MapBlock                             │
│    Landing Zone 2 (grid 5,5) → world (61, 61)                         │
│      - 4 soldiers in bottom-right MapBlock                            │
│                                                                         │
│  Enemy Units (Sectoids):                                               │
│    UFO MapBlock (grid 3,2) → world (31, 16)                           │
│      - 6 sectoids inside/near UFO                                      │
│                                                                         │
│  Enemy Units (Floaters):                                               │
│    Debris MapBlock (grid 2,2) → world (16, 16)                        │
│      - 4 floaters in debris field                                      │
│                                                                         │
│  Neutral Units (Civilians):                                            │
│    Buildings (scattered) → Random positions in building MapBlocks      │
│      - 12 civilians hiding in buildings                                │
│                                                                         │
│  RESULT: All units positioned on battlefield                           │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                STEP 10: Fog of War Initialization                       │
│                                                                         │
│  FogOfWarManager.initialize(battlefield, teams)                        │
│                                                                         │
│  For each team:                                                        │
│    Calculate visible tiles based on unit sight range                  │
│    Initialize fog state: HIDDEN, EXPLORED, VISIBLE                    │
│                                                                         │
│  Team 1 (XCOM - GREEN):                                                │
│    Fog State: All tiles HIDDEN except landing zones                   │
│    Visible: 15×15 around each landing zone                            │
│                                                                         │
│  Team 2 (Sectoids - RED):                                              │
│    Fog State: All tiles HIDDEN except UFO area                        │
│    Visible: 20×20 around UFO (higher sight range)                     │
│                                                                         │
│  Team 3 (Floaters - YELLOW):                                           │
│    Fog State: All tiles HIDDEN except debris area                     │
│    Visible: 18×18 around debris field                                 │
│                                                                         │
│  Team 4 (Civilians - WHITE):                                           │
│    Fog State: Limited visibility (civilians have poor sight)          │
│    Visible: 8×8 around each civilian                                  │
│                                                                         │
│  RESULT: 4 independent fog of war states                               │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────┐
│            STEP 11: Environmental Effects (Crash Mission)               │
│                                                                         │
│  EnvironmentalEffects.applyCrashDamage(battlefield, crashSite)         │
│                                                                         │
│  Crash Site: UFO MapBlock at (31-45, 16-30)                           │
│                                                                         │
│  Damage Effects:                                                       │
│    - 15 random tiles: Terrain destroyed (walls → rubble)              │
│    - 8 fire tiles: Active fires near UFO                              │
│    - 5 smoke clouds: Obscuring vision                                 │
│    - 3 craters: Large explosions                                      │
│                                                                         │
│  RESULT: battlefield with environmental hazards                         │
└─────────────────────────────────┬───────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────────┐
│                      FINAL: Complete Battlefield                        │
│                                                                         │
│  Battlefield Ready for Battlescape:                                    │
│    - Size: 75×75 tiles (5×5 MapBlock grid)                            │
│    - Tiles: All terrain copied and assembled                          │
│    - Objects: 23 items placed (weapons, debris, artifacts)            │
│    - Teams: 4 teams (PLAYER, ENEMY×2, NEUTRAL)                        │
│    - Units: 30 units (8 XCOM + 10 aliens + 12 civilians)              │
│    - Fog: 4 independent fog of war states                             │
│    - Effects: Fire, smoke, crash damage                               │
│    - Sectors: Tracked for landing zone detection                      │
│    - Objectives: UFO capture, civilian rescue                         │
│                                                                         │
│  Ready to transition to:                                               │
│    1. Deployment Planning Screen (TASK-029)                           │
│    2. Battlescape Combat (existing)                                   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Team System Structure

```
┌────────────────────────────────────────────────────────────────────────┐
│                           BATTLE SIDES (4)                             │
└────────────────────────────────────────────────────────────────────────┘

┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│ PLAYER       │  │ ALLY         │  │ ENEMY        │  │ NEUTRAL      │
│              │  │              │  │              │  │              │
│ Hostile to:  │  │ Hostile to:  │  │ Hostile to:  │  │ Hostile to:  │
│   - ENEMY    │  │   - ENEMY    │  │   - PLAYER   │  │   (none)     │
│   - NEUTRAL* │  │   - NEUTRAL* │  │   - ALLY     │  │              │
│              │  │              │  │   - NEUTRAL* │  │              │
└──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘
      │                  │                  │                  │
      │                  │                  │                  │
      ↓                  ↓                  ↓                  ↓
┌────────────────────────────────────────────────────────────────────────┐
│                           TEAM COLORS (8)                              │
└────────────────────────────────────────────────────────────────────────┘

┌─────────┬─────────┬─────────┬─────────┬─────────┬─────────┬─────────┬─────────┐
│  RED    │ GREEN   │  BLUE   │ YELLOW  │  CYAN   │ VIOLET  │  WHITE  │  GRAY   │
│ #FF0000 │ #00FF00 │ #0064FF │ #FFFF00 │ #00FFFF │ #C800FF │ #FFFFFF │ #808080 │
└─────────┴─────────┴─────────┴─────────┴─────────┴─────────┴─────────┴─────────┘

EXAMPLE MISSION TEAMS:

Team 1: "XCOM Squad Alpha"
  Side: PLAYER
  Color: GREEN
  Units: 8 soldiers

Team 2: "Sectoid Scout Party"
  Side: ENEMY
  Color: RED
  Units: 6 sectoids

Team 3: "Floater Patrol"
  Side: ENEMY
  Color: YELLOW
  Units: 4 floaters

Team 4: "Local Civilians"
  Side: NEUTRAL
  Color: WHITE
  Units: 12 civilians

(*) NEUTRAL hostile only if mission specifies (e.g., panicked civilians)
```

---

## MapBlock Transformation Examples

```
ORIGINAL MAPBLOCK (15×15):
┌───────────────┐
│ ###########   │  # = Wall
│ #         #   │  . = Floor
│ #  ROOM   #   │  D = Door
│ #         #   │  T = Table
│ #    T    #   │
│ #         #   │
│ D         D   │
│ #         #   │
│ #         #   │
│ ###########   │
│               │
│               │
│               │
│               │
│               │
└───────────────┘

ROTATE 90° CLOCKWISE:
┌───────────────┐
│         #####D│
│         #   ##│
│         #   # │
│         #   # │
│         # T # │
│         #   # │
│         #   # │
│         #   # │
│         D   # │
│         #   # │
│         #####D│
│               │
│               │
│               │
│               │
└───────────────┘

MIRROR HORIZONTAL:
┌───────────────┐
│   ###########│
│   #         #│
│   #   ROOM  #│
│   #         #│
│   #    T    #│
│   #         #│
│   D         D│
│   #         #│
│   #         #│
│   ###########│
│              │
│              │
│              │
│              │
│              │
└───────────────┘

ROTATE 180°:
┌───────────────┐
│              │
│              │
│              │
│              │
│              │
│   ###########│
│   #         #│
│   #         D│
│   #         #│
│   #    T    #│
│   #         #│
│   #   ROOM  #│
│   #         #│
│   ###########│
│              │
└───────────────┘
```

---

## MapScript Layout Examples

### 1. Urban Crossroads (5×5)

```
MAPSCRIPT: urban_crossroads
SIZE: 5×5 MapBlocks (75×75 tiles)

┌────────┬────────┬────────┬────────┬────────┐
│ Bldg-A │ Bldg-B │ Road-N │ Bldg-C │ Bldg-D │
│  LZ-1  │        │   │    │        │  Obj-1 │
├────────┼────────┼────────┼────────┼────────┤
│ Bldg-E │ Park-1 │ Road-N │ Park-2 │ Bldg-F │
│        │        │   │    │        │        │
├────────┼────────┼────────┼────────┼────────┤
│ Road-W │ Road-W │ INTERSN│ Road-E │ Road-E │
│────────│────────│───┼────│────────│────────│
│        │        │   │    │        │        │
├────────┼────────┼────────┼────────┼────────┤
│ Bldg-G │ Shop-1 │ Road-S │ Shop-2 │ Bldg-H │
│        │        │   │    │        │        │
├────────┼────────┼────────┼────────┼────────┤
│ Bldg-I │ Bldg-J │ Road-S │ Bldg-K │ Bldg-L │
│  Obj-2 │        │   │    │        │  LZ-2  │
└────────┴────────┴────────┴────────┴────────┘

KEY:
  Bldg = Building MapBlock (urban_building_*)
  Road = Road MapBlock (urban_road_*)
  INTERSN = Intersection MapBlock (urban_intersection_01)
  Park = Park MapBlock (urban_park_*)
  Shop = Shop MapBlock (urban_shop_*)
  LZ = Landing Zone (player spawns)
  Obj = Objective (defend/capture)

FEATURES:
  - North-South road spine (column 3)
  - East-West road spine (row 3)
  - Central intersection (3,3) = high-value position
  - Buildings on corners = cover and flanking routes
  - 2 landing zones for medium map size
  - 2 objective buildings
```

### 2. Forest Clearing (5×5)

```
MAPSCRIPT: forest_clearing
SIZE: 5×5 MapBlocks (75×75 tiles)

┌────────┬────────┬────────┬────────┬────────┐
│ Dense  │ Dense  │ Dense  │ Dense  │ Dense  │
│ Forest │ Forest │ Forest │ Forest │ Forest │
│  LZ-1  │        │        │        │        │
├────────┼────────┼────────┼────────┼────────┤
│ Dense  │ Light  │ Clear  │ Light  │ Dense  │
│ Forest │ Forest │   ░    │ Forest │ Forest │
│        │        │        │        │        │
├────────┼────────┼────────┼────────┼────────┤
│ Dense  │ Clear  │ River  │ Clear  │ Dense  │
│ Forest │   ░    │ ~~~~~  │   ░    │ Forest │
│        │        │  Obj-1 │        │        │
├────────┼────────┼────────┼────────┼────────┤
│ Dense  │ Light  │ Clear  │ Light  │ Dense  │
│ Forest │ Forest │   ░    │ Forest │ Forest │
│        │        │        │        │        │
├────────┼────────┼────────┼────────┼────────┤
│ Dense  │ Dense  │ Dense  │ Dense  │ Dense  │
│ Forest │ Forest │ Forest │ Forest │ Forest │
│        │        │        │  LZ-2  │        │
└────────┴────────┴────────┴────────┴────────┘

KEY:
  Dense Forest = Heavily wooded (forest_dense_*)
  Light Forest = Sparse trees (forest_light_*)
  Clear = Open grass (forest_clearing_*)
  River = Water feature (forest_river_*)
  ░ = Clearing visual indicator
  ~~~~~ = Water visual indicator

FEATURES:
  - Dense forest perimeter (edges)
  - Central clearing with river
  - Light forest transition zones
  - River as tactical obstacle
  - 2 landing zones in dense forest
  - River crossing = objective
```

### 3. UFO Crash Site (5×5)

```
MAPSCRIPT: ufo_crash_urban
SIZE: 5×5 MapBlocks (75×75 tiles)

┌────────┬────────┬────────┬────────┬────────┐
│ Bldg   │ Debris │  UFO   │ Debris │ Bldg   │
│ Intact │ Field  │  Nose  │ Field  │ Intact │
│        │  Fire  │   ☼    │  Fire  │        │
├────────┼────────┼────────┼────────┼────────┤
│ Debris │ Crater │  UFO   │ Crater │ Debris │
│ Field  │   ○    │ Center │   ○    │ Field  │
│  Fire  │        │  ★★★   │        │  Fire  │
├────────┼────────┼────────┼────────┼────────┤
│ Road   │  UFO   │  UFO   │  UFO   │ Road   │
│Damaged │ Tail-L │ Center │ Tail-R │Damaged │
│        │        │  ★★★   │        │        │
├────────┼────────┼────────┼────────┼────────┤
│ Bldg   │ Debris │ Crater │ Debris │ Bldg   │
│Damaged │ Field  │   ○    │ Field  │Damaged │
│        │ Smoke  │        │ Smoke  │        │
├────────┼────────┼────────┼────────┼────────┤
│ Bldg   │ Road   │ Bldg   │ Road   │ Bldg   │
│ Intact │Damaged │Damaged │Damaged │ Intact │
│  LZ-1  │        │        │        │  LZ-2  │
└────────┴────────┴────────┴────────┴────────┘

KEY:
  UFO = UFO section MapBlocks (ufo_small_*)
  Debris = Crash debris (debris_field_*)
  Crater = Explosion crater (crater_large_*)
  Fire = Active fires (☼)
  Smoke = Smoke clouds
  ★★★ = UFO center (aliens spawn here)
  ○ = Crater
  Bldg Intact = Undamaged building
  Bldg Damaged = Destroyed building

FEATURES:
  - 9-block UFO (nose + center + tail + parts)
  - Debris field around UFO
  - Multiple craters from crash
  - Fire and smoke hazards
  - Damaged buildings from impact
  - 2 landing zones in intact buildings
  - UFO center = primary objective
```

---

## Data Flow Summary

```
INPUTS (from Geoscape):
├─ Mission Config
│  ├─ provinceId → biome
│  ├─ missionType → terrain override
│  ├─ missionSize → grid size (4-7)
│  ├─ playerUnits → soldier list
│  └─ enemyUnits → alien list
│
PROCESSING (Map Generation):
├─ 1. Biome → Terrain Selection (weighted)
├─ 2. Terrain → MapBlock Pool (filtered)
├─ 3. Terrain → MapScript Selection (weighted)
├─ 4. MapScript → MapBlock Grid (structured)
├─ 5. MapBlocks → Transformations (rotate/mirror)
├─ 6. Grid → Battlefield Assembly (tile copy)
├─ 7. MapBlocks → Object Placement (items)
├─ 8. Mission → Team Creation (4 sides, 8 colors)
├─ 9. Teams → Unit Placement (landing zones, AI)
├─ 10. Teams → Fog of War (per-team visibility)
└─ 11. Mission → Environmental Effects (optional)
│
OUTPUTS (to Battlescape):
├─ Battlefield
│  ├─ tiles[y][x] → BattleTile
│  ├─ sectors[y][x] → MapBlock index
│  ├─ objects[] → BattlefieldObject
│  ├─ teams[] → BattleTeam
│  ├─ units[] → Unit (positioned)
│  ├─ fogOfWar[] → per-team FogState
│  ├─ landingZones[] → LandingZone
│  └─ objectives[] → ObjectiveMarker
│
TRANSITIONS:
├─ → Deployment Planning (TASK-029)
│    Player assigns units to landing zones
│
└─ → Battlescape Combat
     Tactical turn-based battle begins
```

---

## Performance Targets

```
OPERATION                    | TARGET TIME | NOTES
─────────────────────────────┼─────────────┼──────────────────────────
Biome → Terrain Selection    | <1ms        | Simple weighted random
MapBlock Pool Filtering      | <10ms       | 100+ blocks, tag matching
MapScript Selection          | <1ms        | Weighted random
MapScript Execution          | <100ms      | 5×5 = 25 block selections
MapBlock Transformations     | <50ms       | 25 blocks × 2ms each
Battlefield Tile Copy        | <500ms      | 75×75 = 5625 tiles
Object Placement             | <50ms       | 20-50 objects
Team Creation                | <10ms       | 4-8 teams
Unit Placement               | <100ms      | 30-50 units
Fog of War Initialization    | <200ms      | 4 teams × 5625 tiles
Environmental Effects        | <100ms      | Optional, 20-30 effects
─────────────────────────────┼─────────────┼──────────────────────────
TOTAL GENERATION TIME        | <1100ms     | Under 3 seconds target
                            | (1.1 sec)   | 7×7 map = worst case
```

---

## Conclusion

This visual reference shows:
1. **Complete pipeline** from mission selection to final battlefield
2. **Team system structure** with 4 sides and 8 colors
3. **MapBlock transformations** creating variety
4. **MapScript layouts** for different scenarios
5. **Data flow** through all systems
6. **Performance targets** for optimization

Use this document alongside **TASK-031** task document and **MAP-GENERATION-ANALYSIS** for complete understanding of the system.
