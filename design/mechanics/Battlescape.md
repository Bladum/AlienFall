# Battlescape System

> **Status**: Design Document
> **Last Updated**: 2025-10-28
> **Related Systems**: Units.md, Items.md, ai_systems.md, 3D.md, hex_vertical_axial_system.md

## Table of Contents
- [Overview](#overview)
- [Coordinate System](#coordinate-system)
- [Core Systems](#core-systems)
- [Map Generation](#map-generation)
- [Battle Setup & Deployment](#battle-setup--deployment)
- [Environmental Systems](#environmental-systems)
- [Combat Mechanics](#combat-mechanics)
- [Unit Turn Flow & Initiative](#unit-turn-flow--initiative)
- [Combat Statistics & Unit Stats](#combat-statistics--unit-stats)
- [Reactions & Interrupt System](#reactions--interrupt-system)
- [Turn-Based Combat Pace & Round Timings](#turn-based-combat-pace--round-timings)
- [Unit Resource Management](#unit-resource-management)
- [Unit Actions](#unit-actions)
- [Status Effects & Morale](#status-effects--morale)
- [Unit Abilities & Special Systems](#unit-abilities--special-systems)
- [Concealment & Stealth (Advanced)](#concealment--stealth-advanced)
- [Future Enhancements](#future-enhancements)
- [Advanced Mechanics & Tactical Depth](#advanced-mechanics--tactical-depth)
- [Victory & Defeat](#victory--defeat)
- [Conclusion](#conclusion)
- [Examples](#examples)
- [Balance Parameters](#balance-parameters)
- [Difficulty Scaling](#difficulty-scaling)
- [Testing Scenarios](#testing-scenarios)
- [Related Features](#related-features)
- [Implementation Notes](#implementation-notes)
- [Review Checklist](#review-checklist)

---

## Overview

The Battlescape is the tactical combat layer of AlienFall—a turn-based, hex-grid tactical system inspired by X-COM. All combat is turn-based with no real-time elements, emphasizing strategic planning, resource management, and tactical decision-making.

### Combat Paradigm
- **Hex Grid:** Vertical axial coordinate system with flat-top hexagons
- **Hexagon Scale:** Each hex represents 2-3 meters of game world space
- **Turn Duration:** 30 seconds of in-game time per turn
- **Time to Action:** Approximately 1 second per tile of movement
- **Neighbor System:** Each hex has 6 adjacent neighbors (standard hex topology)

---

## Coordinate System

**UNIVERSAL HEX SYSTEM:** Battlescape uses the **vertical axial coordinate system** - the same system used by Geoscape, Basescape, and all other game layers. This ensures consistency and eliminates coordinate conversion errors.

### Axial Coordinates (q, r)
All hex positions use two coordinates:
- **q:** Column coordinate (horizontal axis)
- **r:** Row coordinate (vertical axis, with offset)

### Direction System (6 Directions)
```
Direction 0 (E):  q+1, r+0  -- East (right)
Direction 1 (SE): q+0, r+1  -- Southeast (down-right)
Direction 2 (SW): q-1, r+1  -- Southwest (down-left)
Direction 3 (W):  q-1, r+0  -- West (left)
Direction 4 (NW): q+0, r-1  -- Northwest (up-left)
Direction 5 (NE): q+1, r-1  -- Northeast (up-right)
```

### Visual Characteristics
Due to the vertical axial system:
- Maps appear "skewed" or "diamond-shaped"
- Rectangular buildings look tilted on the hex grid
- Odd columns (q=1, 3, 5...) are shifted down by 0.5 hex height
- This is **intentional and correct** - see `design/mechanics/hex_vertical_axial_system.md`

### Distance Calculation
Convert to cube coordinates for accurate distance:
```
x = q
z = r
y = -x - z
distance = (|x1-x2| + |y1-y2| + |z1-z2|) / 2
```

**Complete Specification:** See `design/mechanics/hex_vertical_axial_system.md` for full details on the coordinate system, pixel conversion formulas, and implementation guidelines.

---

## Core Systems

### Map Structure Hierarchy

The battlescape organizes spatial information in a four-level hierarchy:

#### 1. **Battle Tile** (Smallest Unit)
The fundamental unit of the tactical battlefield. A battle tile represents:
- A single hex on the tactical map where combat occurs
- The visual terrain/floor beneath any units
- One unit (if occupied)
- Up to 5 objects lying on the ground
- Environmental effects (smoke, fire, gas)
- Line-of-sight obstructions
- Fog of war status

**Formula**: Battle Tile = Map Tile + Unit + Ground Objects + Environmental Effects + Fog of War

#### 2. **Map Block** (Tile Cluster)
A 2D array of map tiles that forms a cohesive environmental region:
- Contains exactly 15 hexes arranged in a specific pattern
- Represents 30–45 meters of space
- Generated from tileset data with potential transformations
- Examples: A dense forest zone, a building interior, open terrain
- Can be rotated (0°, 90°, 180°, 270°) or mirrored

#### 3. **Map Grid** (Battle Area)
A 2D array of map blocks that defines the overall battle layout:
- Generated procedurally using map scripts
- Determines battlefield size and structure
- All enemy squads deploy within this grid
- Fixed relationship between map blocks (no random gaps)

#### 4. **Battlefield** (Combat Arena)
The final, unified 2D array of battle tiles where all combat occurs:
- Map Grid × 15 = Battlefield dimensions (each map block = 15 tiles)
- All entities (units, objects, effects) exist on the battlefield
- Environment, placement, and initial effects finalized at this stage

---

### Battle Sides & Teams

#### Four Sides (Fixed Diplomatic Relations)
1. **Player**: Controlled by the human player
2. **Ally**: Permanently allied with the player
3. **Enemy**: Permanently hostile to the player
4. **Neutral**: Non-combatant or environmental effects (smoke, fire)

#### Teams (Tactical Groupings)
- A side may contain **one or multiple teams**
- The **player always has exactly one team**
- Teams are the primary unit of control and coordination
- All units within a team share line-of-sight information
- Teams pursue mission objectives independently

#### Coordination Levels
1. **Team Level**: Strategic coordination of multiple squads toward mission goals
2. **Squad Level**: Tactical grouping of units deployed to a specific map block
3. **Unit Level**: Individual unit actions and combat behavior

---

### Difficulty Scaling

Difficulty affects enemy squad composition, AI aggression, and reinforcement mechanics:

| Difficulty | Squad Size | AI Intelligence | Reinforcements |
|---|---|---|---|
| **Easy** | 75% | 50% | None |
| **Normal** | 100% | 100% | None |
| **Hard** | 125% | 200% | 1 reinforcement wave |
| **Impossible** | 150% | 300% | 2–3 reinforcement waves |

---

## Map Generation

### Generation Pipeline

#### Step 1: Biome & Terrain Selection
1. Select a biome (urban, forest, desert, etc.)
2. Choose a terrain type from that biome (weighted randomly or forced for mission type)
3. **Example**: Biome "Desert" → Terrain "Sand Dunes" or "Ruins"

#### Step 2: Map Block & Script Assignment
1. Retrieve the list of available map blocks for the selected terrain
2. Load the corresponding **map script** for that terrain
3. Map scripts define procedural generation rules

#### Step 3: Map Script Execution
A map script is a series of steps that build the map grid procedurally:

- **Step Components**:
  - Select map blocks of group X (e.g., "forest blocks") or specific size
  - Place K instances at specified locations
  - Draw terrain features (roads, rivers) between blocks
  - Execute conditional logic (if step X completed, then perform step Z)
  - Fill remaining space with default map blocks

- **Step Properties**:
  - Probability of completion (e.g., 70% chance to place a road)
  - Dependency conditions on prior steps
  - Weighted randomization for block selection

- **Output**: A Map Grid—a 2D array of map blocks in a procedural arrangement

#### Step 4: Map Grid Transformations
Once the map grid is generated, apply transformations to increase variety:
- **Rotation**: 90°, 180°, 270°
- **Mirroring**: Horizontal or vertical flip
- **Inversion**: Swap terrain types (forest ↔ clearings)
- **Replacement**: Swap specific block types for others

#### Step 5: Battlefield Construction
Convert the map grid into the final battlefield:
1. Iterate through each map block in the grid
2. Apply any transformations (rotation, mirroring) to that block
3. Place each map tile from the block into the unified battlefield array
4. Track map block boundaries for squad deployment

#### Step 6: Deployment & Population
1. Plan enemy squad deployment (see [Deployment](#deployment-process) section)
2. Place all units on battle tiles
3. Place neutral units (inhabitants, objects) on unoccupied tiles

#### Step 7: Environmental Effects
1. Apply initial environmental effects (fires, explosions, smoke)
2. Generate fog of war based on line-of-sight rules
3. Mark all tiles within player line-of-sight as initially revealed

#### Step 8: Level Details (Ambient Objects)
Add immersive, interactive details:
- Shop items (apples, bread) that units can pick up
- Destroyed machinery or tools
- Environmental objects for cover and atmosphere
- These don't affect mechanics but increase tactical variety

#### Final State
The battlefield is now ready for tactical combat with all entities, effects, and visibility states initialized.

---

## Battle Setup & Deployment

### Pre-Battle: Landing Zone Selection

Before combat begins, the player sees a **mini-map** of the battle area without detailed tactical information. They select from available landing zones:

- **Landing Zone Rules**:
  - One dedicated map block per landing zone
  - Free of enemy units and obstacles
  - Number of zones scales with map size (see below)
  - Player can only deploy to selected zone(s)
  - All player units deploy to selected zone(s) at battle start

#### Map Size & Landing Zones

| Map Size | Grid Dimensions | Total Blocks | Landing Zones |
|---|---|---|---|
| **Small** | 4×4 | 16 | 1 |
| **Medium** | 5×5 | 25 | 2 |
| **Large** | 6×6 | 36 | 3 |
| **Huge** | 7×7 | 49 | 4 |

**Important Note**: The player does not have vehicles (e.g., transport craft) on the battlefield like in XCOM. Units are pure ground forces.

---

### Deployment Process

#### Phase 1: Enemy Squad Building

Construct enemy teams based on mission parameters:

1. **Squad Composition**:
   - Determine total unit count (100% of standard, scaled by difficulty)
   - Distribute units into multiple squads (1–N units per squad)
   - Squad structure depends on mission type (see below)

2. **Mission-Specific Deployment**:
   - **UFO Crash Missions**: ~50% of units guard the UFO (1 squad), ~50% split into 2–4 patrol squads across the map
   - **Base Defense**: Units spawn inside base facilities; additional reinforcements arrive from edges
   - **Rescue Missions**: Enemy units distributed to control objective areas
   - Custom deployment scripts for unique scenarios

3. **Output**: Enemy squads with allocated experience points for unit promotion

#### Phase 2: Enemy Auto Unit Promotion

Prepare individual enemy units with gear and experience:

1. **Experience Budget Allocation**:
   - Each squad receives an experience pool (based on difficulty and unit count)
   - Promote units using a promotion tree (similar to Battle for Wesnoth)

2. **Promotion Process**:
   - Iterate through units, spending experience points on promotions
   - Each promotion increases unit rank and unlocks new abilities/equipment
   - Continue until experience budget is exhausted
   - Remaining budget unused if insufficient for next promotion

3. **Inventory Assignment**:
   - Each unit class has a default loadout
   - Promoted units may unlock better weapons, armor, or special items
   - Finalize each squad with appropriate equipment

4. **Output**: Fully equipped, promoted squads ready for deployment

#### Phase 3: Map Grid Priority Assignment

Assign strategic value to each map block for each enemy team:

1. **Priority Calculation**:
   - Consider mission objectives and their locations
   - Identify key terrain (chokepoints, sightlines, cover)
   - Rank each map block by strategic importance for each enemy team
   - Higher priority blocks get squads first

2. **Squad Placement Rules**:
   - Only one squad per map block
   - Multiple enemy teams may occupy adjacent blocks (normal)
   - Prioritize blocks that best counter player objectives

3. **Output**: Squad → Map Block assignments for each enemy team

#### Phase 4: Squad Deployment to Map Blocks

Deploy each squad to its assigned map block:
- Squads occupy designated map blocks on the map grid
- Internal squad positioning (placement within the block) determined in next phase

#### Phase 5: Unit Deployment to Battle Tiles

Place individual units from each squad:

1. **Placement Method**:
   - Randomly select unoccupied battle tiles within the assigned map block
   - Respect landing zone restrictions (no enemy units there)
   - Space units out to avoid clustering

2. **Deployment Constraints**:
   - No unit can spawn on a player-owned landing zone
   - Units avoid overlapping (max 1 unit per tile)
   - Respects terrain restrictions (units don't spawn in walls)

#### Phase 6: Neutral Unit Deployment

Place non-combatant NPCs, animals, or inactive units:

1. **Neutral Unit Rules**:
   - Randomly distributed across available map tiles
   - Can spawn adjacent to enemy, player, or allied units (normal behavior)
   - Do not occupy player landing zones

2. **Facility Personnel** (e.g., Base Defense):
   - Workshop inhabitants that defend their location
   - Automatically spawn in facility map blocks
   - Treated as neutral units unless attacked

3. **Player Defensive Units** (e.g., Base Defense):
   - Stationary emplacements (turrets, gun nests) in defensive missions
   - Treat as player-owned, non-mobile units

#### Phase 7: Environmental Effects & Fog of War

Finalize environmental state:

1. **Initial Environmental Effects**:
   - Apply pre-battle explosions or fires (simulating pre-battle activity)
   - Deploy smoke clouds from destroyed vehicles
   - Place environmental hazards (toxic gas, radiation zones)

2. **Fog of War Initialization**:
   - Calculate line-of-sight from all player units
   - Mark all visible tiles as revealed
   - Mark tiles within sight range as visible but potentially containing hidden units
   - Unexplored tiles remain shrouded

3. **Neutral Effect Deployment**:
   - Ensure smoke, fire, and gas effects respect all unit types
   - Effects apply equally to all sides

---

### Entity Types

Each tile can contain specific types of entities with different interactions:

#### Floor (Walkable Terrain)
- Default walkable surface
- Does not block movement or line of fire
- May impose movement costs (swamp, sand, etc.)
- Exception: Water typically blocks movement (unless flying)
- Cost of sight: 1

#### Wall (Blocked Terrain)
- Blocks all unit movement
- Blocks or partially blocks line of sight
- Blocks line of fire
- May be destructible (see [Terrain Destruction](#terrain-destruction))
- Cost of sight: Infinite (complete obstruction)

#### Object (Ground Items)
- Up to 5 objects per tile
- Includes weapons, armor, grenades, supplies, and corpses
- Objects can be picked up, used, or thrown
- Dead units become corpse objects (no longer units)
- Cost of sight: 0–6 (depends on object size/opacity)

#### Roof (3D Visual Element)
- In a 3D Battlescape variant, roofs represent ceiling/overhead cover
- In the 2D Battlescape, roofs are visual only and don't affect mechanics
- Future expansion for verticality mechanics

#### Unit (Combat Entity)
- Occupies exactly one tile
- Cannot be walked through (blocks movement)
- Partially blocks line of fire (1–3 sight cost depending on size)
- Can be targeted for attacks
- Each unit tracks health, morale, energy, and status effects

#### Smoke (Environmental Hazard)
- Occupies one or more tiles
- Two intensity levels: small (1 stun damage per turn) or large (1 stun damage per turn)
- Reduces visibility (costs 2–4 sight per tile depending on size)
- Interferes with accuracy (costs 1 fire per tile = 5% accuracy reduction)
- Slowly disperses to adjacent empty tiles
- Generated by fire or explosions

#### Fire (Environmental Hazard)
- Occupies one or more tiles
- Two intensity levels: small or large (0–1 stun damage per turn)
- Damages units that enter (+1–2 HP damage, morale damage)
- Movement cost to enter: +5
- Spreads to adjacent flammable tiles
- Self-extinguishes after several turns
- Generates smoke as it burns

---

## Environmental Systems

### Day vs. Night Missions

#### Visibility Changes
- **No dynamic lighting**: The game uses a fog-of-war system rather than realistic lighting
- **Day sight vs. Night sight**: Units have separate sight range statistics for day and night
- **Item modifiers**: Special items like flashlights extend night vision
- **Night vision penalty**: Reduced sight range during night missions
- **Visual effect**: Night missions apply a blue screen tint for atmosphere

#### Determination
- **Province-based**: Most missions inherit day/night from the map province
- **Forced conditions**: Underground or interior locations force night conditions
- **Mission type**: Certain mission types always occur at night (infiltration, raids)

---

### Weather Systems

Weather conditions affect visibility, movement, and combat accuracy. Weather is optional and scales difficulty dynamically.

#### Weather Types

| Weather | Effect | Sight Cost | Fire Cost | Move Cost |
|---|---|---|---|---|
| **Normal** | Clear conditions | Baseline | Baseline | Baseline |
| **Rain** | Reduced visibility, wet terrain | +1 per tile | −1 per tile | +1 per tile |
| **Snow** | Heavy precipitation, slippery terrain | +2 per tile | −2 per tile | +2 per tile |
| **Blizzard** | Extreme reduction, dangerous movement | +3 per tile | −3 per tile | +3 per tile |
| **Sandstorm** | Dust clouds, abrasive conditions | +2 per tile | ±0 per tile | +2 per tile |
| **Heavy Fog** | Near-total visibility loss | +3 per tile | ±0 per tile | +1 per tile |

**Application**: Weather modifies all cost calculations (sight, fire, movement) globally for the duration of the battle.

---

### Special Conditions

#### Night Missions
- Extremely short sight range
- Blue screen tint effect
- Some enemies may have natural night vision

#### Underground Missions
- Forced night conditions
- No weather effects (underground is sheltered)
- Claustrophobic, linear map designs
- Echo/acoustics effects on audio

#### Facility Missions (Base Defense)
- Limited map area
- Neutral NPCs in facility areas (workshop, barracks, etc.)
- Stationary defensive emplacements for player units
- Reinforcements arrive from specific entrances

---

## Combat Mechanics

### Line of Sight (LOS)

#### Core Concept
Line of sight determines what a unit can see and target. All visibility is calculated from the unit's position using a raycasting algorithm on the hex grid.

#### Sight Range
- **Day sight**: Unit class statistic (typically 8–12 hexes)
- **Night sight**: Unit class statistic (typically 3–6 hexes)
- **Modified by**: Equipment (nightvision goggles, scopes), traits, status effects

#### Sight Cost Calculation
Calculate sight through terrain by raycasting from the unit to each hex in range:

**Sight Cost Per Hex** (cumulative along the ray):
- **Clear terrain**: 1
- **Smoke (small)**: 2
- **Smoke (large)**: 4
- **Fire (small)**: 0
- **Fire (large)**: 1
- **Units (small)**: 1
- **Units (medium)**: 2
- **Units (large)**: 3
- **Walls/Obstacles**: 1–6 (varies by type; bushes = 4, rocks = 3, trees = 5)

**Special Rules**:
- Walls completely block line of sight **unless** the wall itself is the target (always visible)
- Once total sight cost exceeds the unit's sight range, tiles beyond become hidden
- Day/night sight stats apply directly (e.g., 10 day sight = can see through 10 cost of sight)

#### Line of Sense (Special Ability)
- Some units have a special "sense" skill that bypasses sight cost calculation
- Sensed units appear on-screen even if they're outside normal line of sight
- Useful for psychic or thermal detection abilities
- No equipment modifiers (pure unit ability)

---

### Line of Fire (LOF)

#### Definition
A straight line from the shooter to the target on the hex grid. Determines if shooting is geometrically possible.

#### Fire Cost Calculation
Fire cost represents obstruction or difficulty hitting through cover:

**Fire Cost Per Hex** (only solid objects count):
- **Clear terrain**: 0
- **Obstacles/Walls**: 1–6 (depending on type)
- **Bushes**: 3
- **Rocks**: 2
- **Trees**: 4
- **Smoke**: 0 (transparent to fire)
- **Fire**: 0 (transparent to fire)
- **Units**: Not counted (fire passes through allies in this calculation)

**Application**:
- Each point of fire cost = 5% accuracy reduction
- Maximum cumulative cost applied to final accuracy calculation (see [Ranged Accuracy](#ranged-accuracy))

---

### Ranged Accuracy

#### Calculation Process

**Step 1: Base Accuracy (Unit Aim + Weapon Bonus)**

```
Base_Accuracy = Unit_Aim_Stat × (1 + Weapon_Aim_Bonus)

Example:
- Unit Aim stat: 70
- Weapon bonus: +10% (weapon accuracy enhancement)
- Base = 70 × 1.10 = 77
```

**Step 2: Range Modifier (MULTIPLICATIVE)**

Weapon has max effective range (typically 15-20 hexes). Distance determines multiplier:

```
0-75% of range (0-15 hexes for 20-hex weapon):
  Range_Mod = 1.0 (100%, no penalty)

75-100% of range (15-20 hexes):
  Range_Mod = 0.5 (50%, linear drop from 1.0 to 0.5)

100%+ of range (20+ hexes):
  Range_Mod = 0.0 (0%, impossible shot)
```

**Step 3: Weapon Mode Modifier (MULTIPLICATIVE)**

Weapon firing mode provides accuracy multiplier:

```
Base (Standard aim):           Mode_Mod = 1.0
Snap Shot (quick):            Mode_Mod = 0.95
Semi-Auto (deliberate):       Mode_Mod = 1.0
Burst (less controlled):       Mode_Mod = 0.85
Auto (least controlled):       Mode_Mod = 0.75
Aimed Shot (careful):         Mode_Mod = 1.15
Careful Aim (very careful):   Mode_Mod = 1.30
```

**Step 4: Cover Modifier (MULTIPLICATIVE - NOT ADDITIVE)**

Count ALL cover points (obstacles) between shooter and target. Each point = 5% accuracy loss:

```
Total_Cover = sum of all cover obstacles
Cover_Mod = 1.0 - (0.05 × Total_Cover)

Examples:
- 1 cover point: Cover_Mod = 0.95 (5% loss)
- 5 cover points: Cover_Mod = 0.75 (25% loss)
- 10 cover points: Cover_Mod = 0.50 (50% loss)
```

**Step 5: Line of Sight Modifier (MULTIPLICATIVE)**

```
Target visible: LOS_Mod = 1.0 (100%)
Target hidden/obscured: LOS_Mod = 0.5 (50%)
```

**Step 6: Final Calculation (ALL MULTIPLICATIVE)**

```
Final_Accuracy = Base × Range_Mod × Mode_Mod × Cover_Mod × LOS_Mod

Clamp to: 5% minimum, 95% maximum
(Never guaranteed hits, never impossible shots)
```

**Complete Example**:

```
Scenario:
- Unit Aim: 70, Weapon bonus +10% → Base = 77
- Distance: 12 hexes (60% of 20-hex range) → Range_Mod = 1.0
- Using Burst mode → Mode_Mod = 0.85
- Target behind 3 cover points → Cover_Mod = 1.0 - (0.05 × 3) = 0.85
- Target visible → LOS_Mod = 1.0

Calculation:
77 × 1.0 × 0.85 × 0.85 × 1.0 = 55.6%

Clamp to 5-95%: FINAL ACCURACY = 55.6%
```

---

### Range and Accuracy

Accuracy degrades as distance increases from the weapon's effective range:

| Range | Accuracy | Effect |
|---|---|---|
| **0–75% of max** | 100% modifier | Full accuracy, no penalty |
| **75–100% of max** | 50-100% modifier | Linear drop from full to half |
| **100%+ of max** | 0% modifier | Beyond effective range, impossible |

Weapon-specific ranges (examples):
- Pistol: 10 hexes max
- Rifle: 20 hexes max
- Sniper rifle: 30 hexes max (but often longer-range penalties)

#### Minimum Range Penalties (Close-Range Issues)

Some weapons have minimum range where they're less accurate at very close distances:

```
Sniper rifles: −50% accuracy within 3 hexes (scope doesn't work at close range)
Shotguns: No minimum range penalty (effective at all distances)
Pistols: No minimum range penalty
```

---

### Cover System

#### Cover Definition
Cover represents obstacles that reduce attacker accuracy by blocking clear line of fire.

#### Cover Values (Per Obstacle)

| Obstacle Type | Cover Value | Accuracy Effect |
|---|---|---|
| **Smoke (small)** | 2 | −10% accuracy |
| **Smoke (large)** | 4 | −20% accuracy |
| **Fire (small)** | 1 | −5% accuracy |
| **Fire (large)** | 2 | −10% accuracy |
| **Small object** | 1 | −5% accuracy |
| **Medium object** | 2 | −10% accuracy |
| **Large object** | 4 | −20% accuracy |
| **Unit (small)** | 1 | −5% accuracy |
| **Unit (medium)** | 2 | −10% accuracy |
| **Unit (large)** | 3 | −15% accuracy |

#### Cumulative Cover
All obstacles between shooter and target apply cover cumulatively:
- Example: Path through 2 bushes (cover 2 each) + 1 large smoke (cover 4) = 8 total cover
- Cover_Mod = 1.0 - (0.05 × 8) = 0.60 (40% accuracy penalty)

---

### Projectile Deviation (Miss Handling)

When a shot misses, the projectile deviates to a random location:

#### Deviation Calculation

1. **Deviation Angle**: Random direction (0°–360°)
2. **Deviation Distance**:
   - Base: Distance from shooter to target
   - Multiplier: Weapon accuracy modifier (lower accuracy = wider spread)
   - Formula: `deviation_distance = target_distance × (final_accuracy / 100)`
   - Minimum: Always at least 1 hex away from target

3. **Projectile Path**: Travels from shooter through deviation point and beyond
4. **Collision Detection**: Check all hexes along the path for solid obstacles

#### Projectile Interaction

**Can Hit**: Only solid, opaque entities
- Walls
- Rocks/bushes
- Static obstacles (NOT smoke or fire)

**Cannot Hit**: Transparent/gaseous entities
- Smoke clouds
- Fire
- Empty air

**Hit Chance on Obstacles**:
- Each hex with fire cost = 5% chance to hit that obstacle instead of continuing
- Example: Path through bushes with cover 3 = 15% chance to hit the bush
- If obstacle is hit, projectile stops (doesn't reach target)

**Important**: If the projectile eventually hits the **target tile**, it treats it as a hit regardless of obstacles (accuracy already accounted for).

---

### Cover System

#### Cover Definition
Cover represents obstacles that protect a unit from incoming fire by reducing the attacker's accuracy.

#### Cover Values (Per Obstacle)

| Obstacle Type | Cost of Sight | Cover Value | Effect |
|---|---|---|---|
| **Smoke (small)** | 2 | 2 | −10% accuracy |
| **Smoke (large)** | 4 | 4 | −20% accuracy |
| **Fire (small)** | 0 | 0 | No cover |
| **Fire (large)** | 1 | 1 | −5% accuracy |
| **Small object** | 1 | 1 | −5% accuracy |
| **Medium object** | 2 | 2 | −10% accuracy |
| **Large object** | 4 | 4 | −20% accuracy |
| **Unit (small)** | 1 | 1 | −5% accuracy |
| **Unit (medium)** | 2 | 2 | −10% accuracy |
| **Unit (large)** | 3 | 3 | −15% accuracy |

#### Cumulative Cover
All obstacles between shooter and target apply cover bonuses cumulatively:
- Example: Path through 2 bushes (cover 2 each) + 1 large smoke (cover 4) = −40% accuracy

#### Cover and Visibility
Cover also increases sight cost (see [Line of Sight](#line-of-sight)), creating a dual penalty for shooting through obstructed terrain.

---

### Terrain Destruction

#### Destructible Environment

Each terrain tile has an armor value representing its structural integrity:

| Terrain Type | Armor |
|---|---|
| **Flower/plant** | 3 |
| **Wooden wall** | 6 |
| **Brick wall** | 8 |
| **Stone wall** | 10 |
| **Metal wall** | 12 |
| **Rubble/debris** | 8–12 (varies) |

#### Damage Resolution

**Step 1: Damage vs. Armor Check**
- If incoming damage < tile armor: No effect (tile is undamaged)
- If incoming damage ≥ tile armor: Tile transitions to DAMAGED state

**Step 2: Damaged Terrain**
- Damaged tiles have reduced armor (~⅓ less than original, or custom value)
- Damaged tiles visually change to indicate their state
- Example: Brick wall (8 armor) → Damaged brick wall (5 armor)

**Step 3: Destruction**
- If damaged tile takes further damage ≥ its armor: Tile becomes RUBBLE
- Rubble is a floor tile visually showing destruction
- Rubble has higher armor (~150% of original wall) but no longer blocks movement
- Example: Brick rubble (12 armor) is just floor with destruction graphics

**Step 4: Complete Destruction**
- If rubble takes damage ≥ its armor: Tile becomes bare ground (no visual destruction)
- Bare ground has no special properties

#### Material Resistance

Terrain types have material properties that interact with damage types:

| Material | Resistant To | Vulnerable To |
|---|---|---|
| **Wood** | Kinetic, fire | Explosion |
| **Plant** | Water | Fire, chemical |
| **Stone** | Explosion, kinetic | Energy, chemical |
| **Metal** | Kinetic, explosion | Energy, corrosion |

**Application**: Material resistance modifies damage taken before armor calculation:
- Resistant: −20% damage
- Vulnerable: +20% damage

---

### Damage Classification

Weapons use three damage class categories that define how damage spreads:

#### Point Damage (POINT)
- Attacks only the target hex
- Used for: Single-target weapons, melee attacks, precision shots
- Example: Rifles, pistols, melee weapons

#### Area Damage (AREA)
- Radiates damage outward from epicenter with dropoff
- Used for: Explosives, grenades, missile launchers
- Example: Grenade launcher, explosives
- See [Explosion System](#explosion-system)

#### Beam Damage (BEAM)
- Travels in a line from shooter to target
- Damages all hexes along the line of fire
- Used for: Energy weapons, beam attacks
- Example: Laser rifles, particle cannons

---

### Damage Types & Armor Resistance

#### Damage Types
Weapons and effects inflict one of these damage types:

| Type | Source | Effect |
|---|---|---|
| **Kinetic** | Bullets, melee | Direct physical trauma |
| **Explosion** | Grenades, rockets | Area damage with knockback |
| **Energy** | Lasers, plasma | Burns and energy-based trauma |
| **Chemical** | Gas, acid | Corrosive effects over time |
| **Biological** | Toxins, viruses | Infection, disease |
| **Psionic** | Psychic attacks | Mental damage, mind control |
| **Melee** | Hand-to-hand combat | Physical trauma (special) |
| **Fire** | Incendiary weapons | Burning, heat damage |
| **Smoke** | Smoke generation | Stun/suffocation |
| **Stun** | Taser, shock weapons | Temporary incapacity |
| **Warp** | Exotic sci-fi effects | Teleportation, dimensional effects |

#### Armor Resistance
Units and terrain have resistance/vulnerability to each damage type:

- **Resistance**: −20% damage from that type (damage modifier)
- **Vulnerability**: +20% damage from that type
- **Neutral**: No modifier

**Example**: Heavy armor has +50% kinetic resistance but −30% energy vulnerability.

---

### Explosion System

Explosions create expanding waves of damage that spread through hexes, potentially destroying terrain and damaging units.

#### Explosion Parameters

- **Epicenter**: The hex where explosion originates
- **Initial Force**: Base damage value (e.g., 10)
- **Dropoff Rate**: Damage reduction per hex distance (e.g., dropoff = 3)

#### Damage Propagation

**Hex 0 (Epicenter)**: Force = 10

**Hex 1 (6 adjacent hexes)**: Force = 10 − 3 = 7
- Each hex has 6 neighbors

**Hex 2 (remaining neighbors)**: Force = 7 − 3 = 4
- Each hex in ring has 3 new neighbors (direction-dependent)

**Hex 3 and beyond**: Force = 4 − 3 = 1
- Continues until force ≤ 0

#### Damage Application

For each hex receiving blast force:

1. **Check occupants**:
   - If a unit occupies hex: Deals damage
   - If a solid obstacle occupies hex: Deals damage to terrain

2. **Armor vs. Force**:
   - If obstacle armor > force: Obstacle blocks wave, wave stops
   - If obstacle armor ≤ force: Obstacle takes damage, wave continues (reduced by armor)

3. **Wave Continuation**:
   - Remaining force = initial force − armor of obstacles hit
   - Wave spreads to next ring of hexes

#### Example Explosion
Grenade with 10 force, dropoff 3:
- Epicenter hex: All units take 10 damage, terrain takes 10 damage
- Ring 1 (6 hexes): All units take 7 damage
- Ring 2: All units take 4 damage
- Ring 3: All units take 1 damage
- Stone wall (10 armor) in Ring 1: Blocks the 7-force wave, wave stops in that direction

---

### Weapon Modes

Weapons have multiple firing modes that modify their characteristics. Modes are defined globally but activate per weapon per use.

#### Mode Properties

Each weapon mode modifies:
- **AP Cost**: Action points to fire (typically 1–2)
- **EP Cost**: Energy points consumed (varies by weapon)
- **Accuracy**: Bonus/penalty to hit chance
- **Range**: Effective firing distance
- **Damage**: Base damage output

#### Standard Weapon Modes

| Mode | AP Cost | Accuracy | Effect | Use Case |
|---|---|---|---|---|
| **Snap** | 1 | −5% | Quick, inaccurate shot | Suppressive fire |
| **Auto** | 2 | −10% | Burst of fire | Area suppression |
| **Burst** | 2 | ±0% | Controlled burst | Balanced damage |
| **Aim** | 2 | +15% | Careful, precise shot | Critical targets |
| **Melee** | 1 | ±0% | Hand-to-hand attack | Close combat |
| **Thrown** | 2 | ±0% | Launch object | Grenades, items |
| **Far** | 1 | −15% | Long-range shot | Distant targets |
| **Fast** | 1 | ±0% | Reduced AP cost | Efficiency |
| **Strong** | 2 | ±0% | Increased damage | High damage output |
| **Critical** | 2 | +25% | Increased crit chance | Finishing blow |

#### Technology & Mode Availability
Technologies can unlock weapon modes globally:
- Example: Laser technology unlocks "Overcharge" mode on all energy weapons
- Modes remain disabled until technology is researched

---

### Weapon Range vs. Accuracy

Weapon range is the maximum distance a unit can target. Range should be a multiple of 4 for balance.

#### Range Accuracy Curve

Assuming weapon with **max range = 12 hexes**:

**Close Range (0–75% = 0–9 hexes)**:
- Accuracy: 100% at 0%, declining linearly to 50% at 75%
- Formula: `accuracy = 100 − (50 × distance / 9)`

**Medium Range (75–100% = 9–12 hexes)**:
- Accuracy: 50% at 75%, declining linearly to 0% at 100%
- Formula: `accuracy = 50 − (50 × (distance − 9) / 3)`

**Long Range (100–125% = 12–15 hexes)**:
- Accuracy: 0% at 100%, declining to −100% at 125%
- Only possible with exceptional circumstances (sniper scope, etc.)

#### Minimum Range

Some weapons have minimum range penalties (e.g., sniper rifles):

**Minimum Range Example (Sniper Rifle)**:
- Minimum effective range: 3 hexes
- 0–25% of max range (0–3 hexes): −50% accuracy
- Example: At 2 hexes, accuracy is further reduced by 50%

**Close-Range Weapons**:
- Shotguns: No minimum range penalty
- Effective at all ranges

---

### Melee Combat

Melee combat represents close-range hand-to-hand combat, specialized weapons, and tactical grappling. Unlike ranged combat that can occur at distance, melee requires units to be adjacent (within 1 hex).

#### Melee Combat Prerequisites

**Engagement Range**:
- Target must be in an adjacent hex (6 possible adjacent tiles)
- Line-of-sight NOT required (melee attack goes through obstacles)
- Unit must have ≥ 1 AP available

**Weapon Types**:
- Melee weapons: Sword, axe, club, stunstick, vibroblade, etc.
- Unarmed combat: Fists/claws (always available)
- No ranged weapon equipped: Unit can punch unarmed (1 base damage)

#### Melee Attack Resolution

**Attack Sequence**:

**Step 1: Determine Attacker Stats**
- **Melee Skill Stat**: Unit's MEL stat (6–12 range)
- **Strength Bonus**: Unit's STR stat (adds to damage, not accuracy)
- **Weapon Bonus**: Melee weapon accuracy modifier (−5% to +10%)
- **Stance Bonus**: Unit's defensive stance may apply morale modifier

**Step 2: Calculate Base Accuracy**
```
base_accuracy = (MEL / 2) + weapon_bonus
base_accuracy_percent = base_accuracy × 5% + 50%
```
- Example: MEL 8, weapon +0 bonus = 4 + 50% = 70% base accuracy

**Step 3: Apply Modifiers**

| Modifier | Effect | Condition |
|----------|--------|-----------|
| **Flanked** | −20% accuracy | Attacker outnumbered by ≥2 enemies |
| **Outnumbering** | +10% accuracy per extra ally | Attacker has more allies than enemies within 3 hexes |
| **Defensive stance** | −15% attacker accuracy | Defender chose "Cover" action this turn |
| **Wound penalty** | −5% per wound | Attacker is wounded |
| **Surprise** | +30% accuracy | Defender was unaware of attacker |

**Step 4: Clamp Final Accuracy**
- Minimum: 5% (always possible chance to hit)
- Maximum: 95% (never guaranteed hit)
- Result: `final_accuracy = clamp(base_accuracy, 5%, 95%)`

**Step 5: Accuracy Test**
- Roll against `final_accuracy` percentage
- Success: Proceed to damage calculation
- Failure: Attack misses, no damage dealt, attack ends

#### Melee Damage Calculation

**Step 1: Base Damage**
```
base_damage = (MEL / 2) + (STR / 2) + weapon_damage
```
- Example: MEL 8, STR 10, weapon +2 damage = 4 + 5 + 2 = 11 base damage

**Step 2: Apply Damage Type**
- Weapon defines damage type (kinetic, energy, fire, acid, etc.)
- Damage type references **DamageTypes.md** for armor resistance
- Example: Vibroblade = Energy damage (90% shield resistant, 60% heavy armor resistant)

**Step 3: Armor Reduction**
- Target's armor applies resistance based on damage type
- Final damage = base_damage × (1 − armor_resistance)
- Example: Target with 60% energy resistance takes: 11 × (1 − 0.6) = 4.4 damage → 4 HP

**Step 4: Wound Chance**
- Critical hit: Inflicts 1 wound (critical chance = 5% + weapon bonus %)
- Wounds persist until healed (4-week recovery per wound)
- Example: 12% crit chance on vibroblade; successful hit may also inflict wound

**Step 5: Apply Damage**
- Reduce target HP by calculated damage
- If HP reaches 0: Unit dies immediately
- If HP > 0: Unit survives

#### Melee Dodge/Counter

**Defender Reaction (Passive)**:
- Defender does NOT spend AP to dodge
- Dodge is an automatic roll when attacked
- Success: Attack misses or damage reduced

**Dodge Calculation**:
```
dodge_chance = (REA / 2) + (MEL / 2) + defensive_stance_bonus
dodge_chance_percent = dodge_chance × 5% + 30%
```
- Example: REA 8, MEL 7 = 4 + 3.5 + 30% = 50.5% dodge chance
- Clamp: 10%–90% (never certain dodge, never guaranteed hit)

**Dodge Outcomes**:
- Success (roll ≤ dodge_chance): Attack reduced by 50% (defender successfully parries)
- Failure (roll > dodge_chance): Attack hits full damage

**Counter-Attack (Optional)**:
- Defender may spend 1 AP to perform counter-melee attack
- Counter uses reduced accuracy (−15% attacker accuracy)
- Resolves as separate melee attack before damage is applied

#### Melee Engagement Duration

**Locked in Combat**:
- Once melee combat starts, units are "locked in engagement"
- Units cannot move away without breaking engagement
- Leaving engagement hexes triggers Opportunity Attacks

**Opportunity Attack (Break Engagement)**:
- If locked unit tries to move away: Defender gets automatic reaction melee attack
- Opportunity attack uses reduced accuracy (−20%)
- Costs no AP for defender
- If opportunity attack hits, moving unit is stopped (cannot move away)
- If opportunity attack misses: Moving unit breaks engagement and can move

**Breaking Engagement Permanently**:
- Unit must succeed at escaping opportunity attacks to break engagement
- Can move back into adjacent hex (re-engage)
- Can spend 3 AP to "disengage" (guaranteed safe withdrawal)

#### Special Melee Abilities

**Knockback**:
- Some weapons inflict knockback on hit
- Target moves 1–2 hexes away from attacker
- Can't be knocked into walls (collision stops knockback)
- Knockback ends engagement (no opportunity attack)

**Disarm**:
- Special melee action (2 AP, requires weapon equipped)
- Target roll: MEL vs attacker MEL (contested)
- Success: Target drops equipped weapon to adjacent hex
- Weapon can be picked up (2 AP) or left

**Grapple**:
- Special melee action (2 AP)
- On success: Both units locked in place
- Locked units can only:
  - Use melee attacks (no ranged)
  - Break grapple (2 AP + successful dodge roll)
- Grapple ends if either unit moves away

#### Melee Combat Examples

**Example 1: Basic Melee Exchange**
- Soldier (MEL 8, STR 10) attacks alien (REA 7, MEL 6) with sword
- Base accuracy: (8/2) + 0 + 50% = 70%
- Attack roll: 65% (HIT)
- Damage: (8/2) + (10/2) + 3 = 11 base damage
- Alien armor (medium, 30% kinetic resistance): 11 × (1 − 0.3) = 7.7 HP damage
- Alien dodge roll: (7/2) + (6/2) + 30% = 40%
- Dodge roll: 55% (FAIL, hit confirmed)
- Alien takes 7 HP damage

**Example 2: Counter-Attack**
- Alien counter-attacks soldier from above
- Alien MEL 7, STR 9 with alien blade
- Base accuracy: (7/2) + 1 = 4.5 + 50% = 72.5%
- Soldier decides to spend 1 AP for counter
- Counter rolls: MEL 8, dodge chance = 50%, opposed to accuracy 72.5% − 15% = 57.5%
- Counter dodge: 45% (SUCCESS, soldier parries incoming attack)
- Soldier counter-damage: (8/2) + (10/2) + 3 = 11 base damage
- Alien takes damage from counter

**Example 3: Disengagement Attempt**
- Soldier locked in melee with alien
- Soldier attempts to move 2 hexes away
- Alien gets opportunity attack (auto-triggered)
- Alien attack accuracy: 72.5% − 20% = 52.5% (reduced)
- Opportunity roll: 40% (HIT)
- Soldier takes damage from opportunity attack
- Soldier cannot move away (stopped by hit)
- Soldier must use "disengage" action next turn (3 AP cost) to break engagement

#### Melee AP Cost Summary

| Action | AP Cost | When Available |
|--------|---------|-----------------|
| **Melee attack** | 1 | Any time, adjacent enemy |
| **Counter-attack** | 1 | When attacked by melee |
| **Disarm** | 2 | Holding weapon, adjacent enemy |
| **Grapple** | 2 | Any time, adjacent enemy |
| **Break grapple** | 2 | Locked in grapple |
| **Disengage** | 3 | Locked in melee combat |
| **Unarmed punch** | 1 | Anytime (no weapon required) |

#### Melee Balancing Notes

- Melee is higher damage than ranged but requires proximity
- Dodge provides defensive option (passive, no AP cost)
- Engagement lockdown prevents easy escape (requires commitment)
- Counter-attacks add complexity and mutual threat
- Opportunity attacks punish attempted disengagement
- Disarm/grapple add tactical options beyond damage

---

### Projectile Behavior

#### Projectile System
When a unit fires a weapon:

1. **Trajectory Calculation**: Direct line from shooter to target
2. **Intersection Testing**: Check all hexes the projectile passes through
3. **Hit Resolution**: Determine if projectile hits target or deviates
4. **Collision**: Projectile stops if it hits solid obstacle with sufficient armor

#### Collision Effects
- **Hit solid obstacle**: Projectile stops, applies area damage if explosion type
- **Pass through smoke/fire**: Projectile continues (transparent)
- **Hit unit**: Projectile stops (unit is solid)
- **Reach target**: Projectile applies damage and additional effects

#### Ricochet (Optional Future Expansion)
- Projectiles could ricochet off angled surfaces
- Reduced damage on ricochet
- Adds advanced tactical layer

---

## Unit Resource Management

### Health Point System (HP)

#### Base Health
- Unit class base health: 6–12 HP (varies by class)
- Represents damage unit can sustain before incapacity

#### Health Damage
- **Permanent damage**: Reduces current and maximum HP
- **Healing**: Medikit or special abilities restore HP
- **Natural regeneration**: None during battle (requires end-of-battle healing)

#### Health-Based AP Penalty

As a unit takes damage, it becomes less capable:

| Health Status | AP Reduction |
|---|---|
| **100%–51%** | No penalty |
| **50%–26%** | −1 AP |
| **25%–1%** | −2 AP |
| **0%** | Unit dies, becomes corpse |

#### Death & Incapacitation
- When HP reaches 0: Unit dies, immediately converts to corpse object
- Corpses can be carried, dropped, or looted
- Dead units do not participate in combat or provide line-of-sight

---

### Stun Point System

Stun is temporary incapacity damage that accumulates but decays automatically each turn. Unlike HP damage, stun naturally recovers.

#### Stun Mechanics

- **Base Stun**: 0 at battle start
- **Accumulation**: Various sources inflict stun (smoke clouds, stun weapons, melee impacts, etc.)
- **Multiple Sources**: Each stun source tracked independently
- **Natural Decay**: −1 stun per source automatically at END OF TURN
- **Incapacitation**: When total stun ≥ current max HP, unit becomes unconscious (fainted)

#### Decay Timing (CLARIFIED)
- **When**: End of unit's action phase (after all actions resolve)
- **Automatic**: Decay applies automatically, no action required
- **All Sources**: Each stun source decays independently (−1 per source per turn)
- **Applies to Fainted Units**: Stun continues decaying even if unit is unconscious
- **Minimum**: Stun cannot go below 0 (locked at 0)

Example:
```
Unit has 8 total stun from multiple sources:
- 5 stun from smoke
- 3 stun from stun weapon

End of turn automatic decay:
- Smoke: 5 → 4 (−1)
- Stun weapon: 3 → 2 (−1)
- Total remaining: 6 stun

If unit was fainted (total stun ≥ max HP):
- Still recovers 2 stun points
- May become active again if total drops below max HP
```

#### Unconscious State (Fainted)
- Triggered: When total stun ≥ current max HP
- **AP available**: 0 (cannot act)
- **Visibility**: Still visible to all units
- **Line of Sight**: Unit cannot shoot or target (incapacitated)
- **Recovery**: Automatic via stun decay (−1/turn per source)
- **Medikit Recovery**: Stimulant item restores −5 stun instantly (single use)
- **Duration**: Unit remains fainted until total stun < max HP

#### Rest Action (In-Battle Recovery)
- **AP Cost**: 2 AP
- **Effect**: Does NOT affect stun decay (decay always −1 regardless)
- **Purpose**: Recover AP next turn, not stun recovery
- **Note**: Rest is for action recovery, not stun recovery; stun only recovers via automatic decay

---

### Energy Point System (EP)

Energy represents stamina, ammunition, power cells, and magical reserves. All actions that consume EP draw from this pool.

#### Base Energy
- Unit class base energy: 6–12 EP (varies by class)
- Represents maximum reserve per battle turn

#### Energy Regeneration
- **Rate**: 30% of base energy per turn (automatically)
- **Example**: 10 base energy → 3 EP regenerated per turn
- **Effective for**: Sustained actions across multiple turns

#### Energy Consumption

| Action | EP Cost |
|---|---|
| **Fire weapon** | Weapon-dependent (1–3) |
| **Reload** | 1 EP |
| **Run action** | 1 EP per AP spent on running |
| **Fly/Jetpack** | 2 EP per AP on movement |
| **Special ability** | Ability-dependent (1–5) |

#### No Energy, No Action
- Without sufficient EP, unit cannot perform most actions
- Can still move normally (walking costs no EP)
- Some special actions may be blocked entirely

#### Energy Transfer
- One unit can transfer energy to an adjacent ally
- Requires special transfer equipment or class ability
- Strategic for sustaining allies during prolonged combat

---

### Movement Point System (MP)

Movement is the primary action in combat. Movement points represent a unit's speed and movement capability.

#### Movement Calculation
- **Base**: 1 MP = 1 available AP × unit speed stat
- **Unit Speed**: Class-dependent (1–2 typically)
- **Example**: 4 AP available × speed 1 = 4 MP for turn

#### Terrain Movement Costs

| Terrain Type | Cost |
|---|---|
| **Clear ground** | 1 MP |
| **Road/path** | 1 MP (easier) |
| **Difficult (sand, mud)** | 2 MP |
| **Very difficult (marsh, rubble)** | 3 MP |
| **Extreme (dense forest, steep)** | 4–5 MP |
| **Wall/impassable** | 99 (blocked) |

#### Elevation Changes
- **Low → High terrain**: +8 MP (steep climb)
- **High → Low**: No penalty (descent)
- **Same level**: No elevation cost

#### Turning
- **Rotation**: 1 MP per 60° turn (standard hex grid)
- **Facing direction**: Determines which hexes unit can see (future enhancement)

#### Special Movement Types

**Running**:
- Cost: 50% MP (terrain costs × 0.5)
- AP Cost: 1 AP per hex moved
- EP Cost: 1 EP per AP spent
- Sight Penalty: −3 sight range while running
- Cannot fire while running

**Sneaking**:
- Cost: 200% MP (terrain costs × 2)
- AP Cost: 1 AP per hex (moves slowly)
- Cover Bonus: +3 cover bonus
- Sight Bonus: +3 sight range (better observation while careful)
- Cannot fire while sneaking

**Flying/Jetpack**:
- Cost: Ignores terrain cost (all terrain = 1 MP)
- AP Cost: 1 AP per hex
- EP Cost: 2 EP per AP spent (fuel consumption)
- Advantages: Bypasses walls and difficult terrain
- Restrictions: Heavy armor may disable flight; limited flight range per turn

---

## Unit Actions

**Note**: Unit classes and specialization are documented in `units.md`.

Units have 4 AP per turn that resets every turn. Each action consumes AP. Unused AP does not carry over to the next turn.

### Base Actions

#### Move
- **AP Cost**: 1 AP per 2 hexes moved (varies by terrain)
- **EP Cost**: 0
- **Description**: Standard walking movement
- **Result**: Unit moves to new position, facing updated as needed

#### Run
- **AP Cost**: 1 AP per hex (at 50% movement speed)
- **EP Cost**: 1 EP per AP
- **Sight Penalty**: −3
- **Description**: Fast sprint across battlefield
- **Result**: Unit runs to destination, movement is faster but less controlled

#### Sneak
- **AP Cost**: 1 AP per hex (at 200% movement cost)
- **EP Cost**: 0
- **Cover Bonus**: +3
- **Sight Bonus**: +3
- **Description**: Careful, concealed movement
- **Result**: Unit moves slowly and cautiously, harder to spot

#### Fire (Ranged Attack)
- **AP Cost**: 1–2 (weapon-dependent)
- **EP Cost**: 1–3 (weapon-dependent)
- **Description**: Attack with equipped weapon
- **Result**: Accuracy test, projectile fired, target takes damage if hit
- **Can perform**: Once per turn if AP available (but usually not optimal)

#### Overwatch
- **AP Cost**: 2
- **EP Cost**: 0
- **Description**: Ready to fire on approaching enemies
- **Activation**: Triggered automatically when enemy enters line-of-sight during their turn
- **Reaction Fire**: If triggered, make one immediate ranged attack
- **Result**: Unit takes reaction shot, consumes remaining AP/EP, overwatch ends

#### Cover
- **AP Cost**: 2 per level
- **EP Cost**: 0
- **Max Cover**: Tile-dependent (concrete = 2, sand = 4, bushes = 6)
- **Per Level**: −5% attacker accuracy, +3 sight cost from attackers
- **Description**: Take defensive position behind cover
- **Result**: Unit gains cover bonus for incoming attacks until action changes

#### Suppress Enemy
- **AP Cost**: 1–2
- **EP Cost**: 1–2 (like firing weapon)
- **Description**: Fire at enemy to reduce their combat capability
- **Accuracy**: Standard ranged accuracy calculation
- **Result if successful**: Target loses 1 AP next turn (cannot take as many actions)
- **Result if failed**: Ammunition wasted, no effect
- **Tactical use**: Lock down enemy without killing

#### Rest
- **AP Cost**: 2–4 (action pool spend)
- **EP Cost**: 0
- **Options**:
  - 2 AP → +1 morale
  - 3 AP → −1 stun
  - 4 AP → Full energy regeneration
- **Description**: Unit recovers during turn
- **Result**: Stat improvement, useful for recovery between heavy combat

#### Throw
- **AP Cost**: 2
- **EP Cost**: 0
- **Range**: Based on unit strength ÷ item weight
- **Accuracy**: Unit aim stat (like ranged accuracy)
- **Description**: Pick up object and throw it
- **Result**: Object travels to destination, applies effects (grenade detonates, etc.)

---

### Special Actions (Future Enhancement)

#### Psionic Abilities
- **AP Cost**: 2–3
- **EP Cost**: 1–5 (ability-dependent)
- **Skill Roll**: Uses psi stat instead of aim
- **Defensive Roll**: Target rolls bravery to resist
- **Range**: May or may not require line-of-sight
- **Effects**: Telekinesis, mind control, damage, healing, revelation, etc.

**Psionic Damage Types**: Physical damage inflicted by psychic means
- Bypasses conventional armor in some cases
- Special resistance/vulnerability possible

---

## Unit Turn Flow & Initiative

**Note**: Equipment, items, weapons, and armor are documented in `items.md`.

### Turn Order System

Battles follow a team-based turn order where sides alternate actions:

#### Turn Sequence
1. **Player Team Turn**: Player controls all units
2. **Allied Team Turn**: Allied AI controls units
3. **Enemy Team Turn (1)**: First enemy squad acts
4. **Enemy Team Turn (2+)**: Additional enemy squads act (if multiple teams)
5. **Neutral Effects**: Environmental effects apply (smoke spread, fire damage, etc.)
6. **Round End**: Check mission objectives, trigger reinforcements if applicable

#### Initiative (Within Team)
- **No Individual Initiative**: All units on team act during team's turn
- **Player Control**: Choose order of unit actions (tactical ordering)
- **AI Control**: AI determines order based on strategic assessment

#### Action Priority

Units within a team can act in any order during their turn:

1. **Player Directed**: Player manually selects which unit acts first (strategic flexibility)
2. **Action Efficiency**: Units are typically ordered by AP availability (4 AP units before 2 AP units)
3. **Tactical Ordering**: Player can deliberately order units (e.g., medic first, then soldiers)

#### AP Refreshment
- **Turn Start**: All units regain 4 AP (minus penalties)
- **Status Effects**: Morale penalties reduce AP available
- **No Carryover**: Unused AP is lost at end of turn

#### Reinforcement Trigger
- **Specific Turns**: Reinforcements may arrive at designated turns (turn 5, turn 10, etc.)
- **Trigger**: New squad appears at designated map block
- **Integration**: Reinforcement squad acts on their first turn (included in turn order)

---

## Combat Statistics & Unit Stats

*For complete unit stat definitions, ranges, formulas, and examples, see [MASTER_STAT_TABLE.md](../MASTER_STAT_TABLE.md).*

### Unit Stats Reference

Each unit has distinct stats that scale with class and promotion:

#### Primary Stats

| Stat | Abbreviation | Purpose | Range |
|---|---|---|---|
| **Health Points** | HP | Damage capacity | 12–28 |
| **Action Points** | AP | Actions per turn | 2–5 |
| **Accuracy** | ACC | Ranged weapon chance-to-hit | 50%–95% |
| **Reaction** | REA | Initiative, dodge chance | 6–12 |
| **Strength** | STR | Carry capacity, melee damage | 6–12 |
| **Melee** | MEL | Melee attack & dodge effectiveness | 6–12 |
| **Bravery** | BRA | Morale buffer during battle | 6–12 |
| **Psi Skill** | PSI | Psionic ability effectiveness & defense | 0–20 |

#### Secondary Stats (Derived)

| Stat | Formula | Purpose |
|---|---|---|
| **Carry Capacity** | STR × 2 | Inventory slots available |
| **Melee Damage** | (MEL ÷ 2) + (STR ÷ 2) + Weapon Bonus | Damage from melee attacks |
| **Melee Dodge** | (MEL ÷ 2) + Weapon Bonus | Defense against melee attacks |
| **Psionic Attack** | (PSI × 5%) + Modifiers | Effectiveness of psionic attacks (requires class) |
| **Psionic Defense** | (PSI ÷ 2) + Modifiers | Resistance to psionic attacks |
| **Morale** | BRAVERY (6-12 base during battle) | Psychological state buffer |
| **Sanity** | 6-12 (separate from morale) | Psychological stability buffer |
| **Experience Points** | Combat Kills + Objectives | Accumulates toward promotion |

### Stat Gain Progression

| Promotion | HP Gain | ACC Gain | STR Gain | General Pattern |
|---|---|---|---|---|
| **Rank 0→1** | +2 | +5% | +1 | Class baseline |
| **Rank 1→3** | +1 | +3% | +0 | Slowing growth |
| **Rank 3→6** | +1 | +2% | +0 | Plateau |
| **Rank 6→10** | +0–1 | +1% | +0 | Minimal gains |

**Late Game**: By rank 10, stat gains plateau and units reach near-maximum effectiveness. Further advancement comes through equipment and specialization.

---

## Reactions & Interrupt System

### Reaction Fire

Reaction fire allows units to attack enemies during enemy turns (not their turn).

#### Triggering Reaction Fire

**Overwatch Mode**:
- **Activation**: 2 AP (standing unit can enter overwatch)
- **Duration**: Until unit's next turn or until reaction triggered
- **Visibility**: If overwatch is active and enemy enters line-of-sight, automatic trigger

**Reaction Opportunities**:
- Enemy moves within line-of-sight: +Suppress or fire reaction
- Enemy performs attack action: +Counter-attack opportunity
- Enemy approaches adjacent hex: +Melee intercept (if ready)

#### Reaction Limitations

- **One per Turn**: Unit can only perform 1 reaction per enemy turn
- **AP Cost**: Reaction uses remaining AP from last turn (not replenished)
- **Action Type**: Only ranged attacks or melee counterattacks available
- **Movement**: Unit does not move during reaction (fired from current position)

#### Reaction Modifiers

```
Reaction Accuracy = Base Accuracy × 0.9 (−10% for hasty shot)
Reaction Range = Weapon Range × 0.75 (−25% range for hasty targeting)
```

#### Failed Reaction

If unit lacks AP to perform reaction, can still move away (opportunity action). This ends enemy's turn movement phase.

---

## Turn-Based Combat Pace & Round Timings

### In-Game Time Progression

**Turn Duration**: Each turn represents 30 seconds of game time

**Turn Count to Time**:
- 1 turn = 30 seconds
- 10 turns = 5 minutes
- 20 turns = 10 minutes
- 40 turns = 20 minutes (typical mission length)

**Movement Equivalence**:
- 1 hex = 1 second (approximately 1 tile/second)
- 1 map block (15 hexes) = 15 seconds to cross
- Full battlefield crossing: 30–90 seconds depending on size

### Mission Duration Typical

**Short Missions** (Easy difficulty):
- Duration: 10–15 turns
- Real time: 5–7 minutes per turn × 12–15 turns = ~1–2 hours

**Standard Missions** (Normal difficulty):
- Duration: 20–30 turns
- Real time: 10–15 minutes per turn × 25 turns = ~5 hours

**Long Missions** (Hard/Impossible difficulty):
- Duration: 30–50+ turns
- Real time: 15–25 minutes per turn × 40 turns = ~10 hours

**Playstyle Impact**: Slow, methodical play extends mission time. Fast tactical play completes missions faster.

---

## Status Effects & Morale

**For Complete Morale/Bravery/Sanity Mechanics**: See [MoraleBraverySanity.md](./MoraleBraverySanity.md)

### Combat Integration

**Morale Effects in Combat**:
- Morale affects unit accuracy and action points during battle
- Low morale units have reduced combat effectiveness
- Panic state (morale = 0) disables unit actions completely
- Morale recovers through Rest actions or leader rallies

**Sanity Effects in Combat**:
- Sanity has NO direct effects on combat performance
- Sanity only affects deployment eligibility between missions
- Units with 0 sanity cannot be deployed on missions

**Key Integration Points**:
- Morale penalties stack with other accuracy modifiers (cover, range, etc.)
- Leader units can rally nearby allies to restore morale
- Rest actions (2 AP) restore +1 morale per use
- Morale resets to bravery value at mission end

---

## Unit Abilities & Special Systems

### Auras (Leader Effects)

Certain unit classes can project passive auras that affect nearby allied units.

#### Aura Rules
- **Range**: Fixed distance from unit (typically 3–6 hexes)
- **Line-of-sight**: Not required (auras pass through walls)
- **Affected units**: All allies within range
- **Stacking**: Multiple aura sources stack bonuses

#### Standard Aura Effects

| Aura | Range | Effect |
|---|---|---|
| **Morale Boost** | 5 hexes | +1 morale to nearby allies |
| **Accuracy Boost** | 4 hexes | +20% accuracy to nearby allies |
| **Sight Boost** | 6 hexes | +3 sight range to nearby allies |
| **Fear Aura** (enemy) | 5 hexes | −1 morale to nearby enemies |
| **Stun Aura** (enemy) | 3 hexes | +1 stun per turn to nearby enemies |

#### Negative Auras
- Some units project negative auras affecting enemies
- Example: Terror aura (horror movie alien) inflicts morale penalties
- Auras can be targeted by suppression/silence abilities

---

### Weapon Accuracy System (Revisited)

#### Complete Accuracy Formula (ALL MULTIPLICATIVE)

**Core Principle**: ALL accuracy modifiers are multiplicative, NOT additive or subtractive.

```
Final Accuracy = Base_Aim × Range_Mod × Weapon_Bonus_Mod × Weapon_Mode_Mod × Cover_Mod × LOS_Mod

Where each modifier is a multiplier (0.0 to 2.0+ range):
- Base_Aim = Unit's Accuracy stat (expressed as decimal, e.g., 0.70 = 70%)
- Range_Mod = 0.0 to 1.0 (penalty for distance)
- Weapon_Bonus_Mod = 0.9 to 1.1 (±10% weapon bonus)
- Weapon_Mode_Mod = 0.75 to 1.30 (mode-based penalty/bonus)
- Cover_Mod = 0.5 to 1.0 (cover penalty as multiplier)
- LOS_Mod = 0.5 or 1.0 (visibility penalty or normal)

Result = clamp(0.05, Final Accuracy, 0.95)  [Minimum 5%, maximum 95%]
```

#### Range Accuracy Modifier

Based on distance as percentage of weapon max range:

```
Weapon max range = 20 hexes (example)

Distance 0-15 hexes (0-75% of range):
  Range_Mod = 1.0 (100%, no reduction)

Distance 15-20 hexes (75-100% of range):
  Range_Mod = linear drop from 1.0 to 0.5
  (for each hex beyond 75%, reduce by ~3.3% per hex)

Distance 20+ hexes (100%+ beyond max):
  Range_Mod = 0.0 (impossible shot, beyond effective range)
```

#### Cover Accuracy Modifier

Cover is multiplicative penalty (each cover point reduces effectiveness):

```
Cover_Mod = 1.0 - (0.05 × total_cover_points)

Example:
- 0 cover: Cover_Mod = 1.0 (no penalty)
- 1 cover point: Cover_Mod = 0.95 (multiply accuracy by 0.95)
- 5 cover points: Cover_Mod = 0.75 (multiply accuracy by 0.75)
- 10 cover points: Cover_Mod = 0.50 (multiply accuracy by 0.50, half effectiveness)
- 20+ cover points: Cover_Mod = 0.0 (impossible shot, blocked completely)
```

#### Line of Sight Modifier

```
If target is visible: LOS_Mod = 1.0 (100%, no penalty)
If target is hidden/obscured: LOS_Mod = 0.5 (50%, multiply accuracy by 0.5)
```

#### Weapon Mode Modifier

Weapon modes provide base 1.0 modifier, adjusted per mode:

```
Standard modes:
- Snap Shot: Mode_Mod = 0.95 (5% reduction, ×0.95)
- Semi-Auto: Mode_Mod = 1.0 (100%, ×1.0)
- Burst: Mode_Mod = 0.85 (15% reduction, ×0.85)
- Auto: Mode_Mod = 0.75 (25% reduction, ×0.75)
- Aim: Mode_Mod = 1.15 (15% bonus, ×1.15)
- Careful Aim: Mode_Mod = 1.30 (30% bonus, ×1.30)
```

#### Weapon Bonus Modifier

Weapon inherent bonus:

```
Weapon bonus range: -10% to +10%
- Poor accuracy weapon: Weapon_Bonus_Mod = 0.90 (×0.90)
- Standard weapon: Weapon_Bonus_Mod = 1.0 (×1.0)
- Accurate weapon: Weapon_Bonus_Mod = 1.10 (×1.10)
```

#### Complete Example

```
Scenario:
- Unit has Accuracy stat = 70% (0.70)
- Weapon bonus = +5% (Weapon_Bonus_Mod = 1.05)
- Range: 12 hexes out of 20-hex max (60% of range, Range_Mod = 1.0)
- 3 cover points between units (Cover_Mod = 1.0 - 0.15 = 0.85)
- Target is visible (LOS_Mod = 1.0)
- Using Burst mode (Mode_Mod = 0.85)

Calculation:
Final_Accuracy = 0.70 × 1.0 × 1.05 × 0.85 × 0.85 × 1.0
Final_Accuracy = 0.70 × 1.05 × 0.85 × 0.85
Final_Accuracy = 0.526 = 52.6% (clamped between 5%-95%, so 52.6%)

Result: Unit has 52.6% chance to hit (morale may further affect this)
```

#### Accuracy Modifiers (Summary)
- **Unit Accuracy**: 60–80% base (by class)
- **Weapon Bonus**: ±10% bonus (×0.9 to ×1.1)
- **Weapon Mode**: −25% to +30% (×0.75 to ×1.30)
- **Range**: 0% to 100% (scales with distance)
- **Cover**: −5% per cover point (×0.95 per point, min 0%)
- **Line-of-Sight**: −50% if hidden (×0.5), or no penalty if visible (×1.0)
- **Equipment Synergy**: ±15% (class matching/mismatching, ×0.85 to ×1.15)

**Equipment Synergy in Combat:**
- **Matched Classes**: Light armor + Light weapon = +10% accuracy, Heavy armor + Heavy weapon = -10% accuracy
- **Mismatched Classes**: Light armor + Heavy weapon = -15% accuracy, Heavy armor + Light weapon = -5% accuracy
- **Medium Classes**: Medium armor + Medium weapon = 0% modifier (balanced baseline)
- **Specialized Classes**: Varies by equipment type (see Items.md for specialized synergy rules)

---

### Pathfinding

### Pathfinding

#### Algorithm
- Hex grid uses **A\* pathfinding algorithm**
- Considers terrain movement costs
- Avoids obstacles (walls, units)
- Calculates shortest AP-cost path

#### Strategic Implications
- Units take optimal routes automatically
- Terrain cost affects path priority (shorter terrain vs. faster terrain)
- Obstacles force path recalculation in real-time

---

## Victory & Defeat

### Victory Conditions

#### Mission Objectives

Each battle defines one primary objective for each side. Objectives are measured in percentage completion:

#### Objective Types

##### Eliminate All Enemies
- **Completion**: All enemy units dead or surrendered
- **Progress**: 100% ÷ (number of enemy units) per unit eliminated
- **Example**: 4-unit squad → 25% per enemy killed

##### Capture Unit
- **Target**: Specific enemy unit (VIP, commander, etc.)
- **Completion**: Target unit captured and extracted
- **Progress**: 0% until captured, then 100%

##### Defend Objective
- **Target**: Hold specific map block or tile for N turns
- **Completion**: N turns completed without objective being captured by enemy
- **Progress**: (current_turn ÷ required_turns) × 100%
- **Example**: Defend for 20 turns → 5% per turn

##### Reach Objective
- **Target**: Move player unit to specific tile/map block
- **Completion**: Any player unit reaches destination
- **Progress**: 0% until reached, then 100%

##### Rescue Unit
- **Target**: Extract specific allied unit from map
- **Completion**: Unit extracted (moved to landing zone or evacuation point)
- **Progress**: 0% until rescued, then 100%

##### Secure Items
- **Target**: Collect N items and extract
- **Completion**: All items secured and extracted
- **Progress**: (items_collected ÷ total_items) × 100%

##### Kill VIP Unit
- **Target**: Eliminate specific high-value target
- **Completion**: Target unit dead or captured
- **Progress**: 0% until achieved, then 100%

##### Protect Allied VIP
- **Target**: Keep specific allied unit alive
- **Completion**: Unit survives to mission end
- **Progress**: 0% if unit is dead/captured, 100% if alive

##### Area Control
- **Target**: Control 3+ specific map blocks
- **Completion**: Hold required blocks for N turns
- **Progress**: (controlled_blocks ÷ required_blocks) × 100% × (time_held ÷ required_time)

##### Survive N Turns
- **Target**: Just stay alive for N turns
- **Completion**: N turns pass without player team elimination
- **Progress**: (current_turn ÷ required_turns) × 100%

#### Objective Completion
- **Completion Threshold**: 100% = Mission success for that side
- **Multiple Objectives** (future): Some missions may track multiple goals; completion of any = win

#### Mission Writing Notes
- Objectives are written from the player perspective
- If player objective is "defend area," enemy objective is implicitly "capture area"
- No need to design redundant inverse objectives; one perspective is sufficient

---

### Defeat Conditions

A side is defeated when **all of the following occur**:

1. **No active units**: All units on that side are:
   - Dead (HP = 0) **OR**
   - Unconscious (stun ≥ max HP) **OR**
   - Panicked (morale = 0 and AP = 0) **OR**
   - Extracted/retreated from battlefield

2. **No active teams**: All teams on that side have been eliminated

3. **Reinforcement failure**: If reinforcements are scheduled, side is defeated if they fail to arrive (destroyed before arrival, schedule missed)

**Immediate Surrender**: If all teams representing a side are eliminated, that side immediately surrenders (mission ends in loss for that side).

### Retreat Mechanic

The player can retreat from battle under specific conditions:

#### Retreat Process
1. **Initiation**: Player presses ESC or selects retreat action
2. **Extraction**: All player units immediately return to their landing zone
3. **Destination**: Units reach their insertion craft and extract

#### Retreat Penalties & Rewards
- **Experience**: Units gain experience for battle actions up to retreat
- **No medals**: Retreat disqualifies units from earning commendations
- **No salvage**: Enemy equipment and items left on map (not collected)
- **No prisoners**: Enemy units cannot be captured during retreat

#### Strategic Use
- Retreat is useful when outnumbered or objective unachievable
- Better to retreat with survivors than lose entire squad
- Lost progress on mission objective, but units survive

---

### Reinforcements

#### Reinforcement System

Some battles include reinforcement mechanics where additional enemy squads arrive during combat.

#### Reinforcement Parameters
- **Timing**: Turn N (e.g., turn 5, turn 10)
- **Squad Size**: Number of units (variable)
- **Squad Experience**: Available experience for auto-promotion
- **Entry Point**: Map block where reinforcements spawn

#### Battle Script
Reinforcements are controlled by a **battle script**—a handwritten set of rules defining:
- When reinforcements arrive (turn-based)
- What units compose reinforcements (faction, class distribution)
- Where they enter the map
- How many waves of reinforcements occur

#### Reinforcement Tactics
- Used to increase difficulty dynamically
- Simulates enemy reserves or escape options
- Creates time-pressure gameplay

---

### Salvage & Post-Mission

#### Automatic Salvage

After player victory, all loot is automatically collected:

##### Unit Salvage
- **All player units**: Gain experience points
- **All player units**: Earn medals for exceptional performance
- **All player units**: Take sanity damage (post-mission penalty)
- **Enemy units (alive)**: Become prisoners (interrogate for intel)
- **Enemy units (dead)**: Become corpse objects (not salvageable as units)

##### Item Salvage
- **Equipment on dead units**: Collected as items
- **Equipment on tiles**: Collected as items
- **Grenades & ammo**: Collected and stashed in inventory
- **Crafting resources**: Collected for manufacturing

##### Resource Salvage
- **Crafting materials**: Tiles containing resources become item salvage
- **Tech artifacts**: Found on map or enemy units
- **Research data**: Extracted from enemy installations

#### Recovery & Healing

**Post-Mission Recovery Times**:
- **1 HP damage** = 1 week in med-bay
- **1 wound** = 4 weeks in med-bay
- **Accumulated stun/morale damage**: Heals naturally with rest (no time cost)

**Examples**:
- Unit with 3 HP damage and 1 wound = 7 weeks recovery (3 + 4)
- Unit with 0 HP but alive (extracted unconscious) = 0 damage, no recovery time

---

## Concealment & Stealth (Advanced)

### Stealth Budget System

Some missions feature a concealment mechanic where the player has a limited "stealth budget."

#### Budget Mechanics
- **Starting budget**: Mission-dependent (typically 0–100 points)
- **Exceeding budget**: If exceeded

---

## Examples

### Scenario 1: Tactical Positioning
**Setup**: Squad deployed in urban environment with mixed cover
**Action**: Position units to maximize cover bonuses while maintaining fields of fire
**Result**: Reduced damage taken, improved accuracy, successful mission completion

### Scenario 2: Resource Management
**Setup**: Prolonged engagement with limited time units
**Action**: Balance movement, shooting, and overwatch actions across squad
**Result**: Efficient use of action points, all objectives completed within time limit

### Scenario 3: Environmental Tactics
**Setup**: Night mission with low visibility and alien night vision advantage
**Action**: Use smoke grenades and positioning to neutralize visibility advantages
**Result**: Equalized combat conditions, successful extraction despite environmental challenges

### Scenario 4: Morale Management
**Setup**: Squad under heavy fire with mounting casualties
**Action**: Position leader unit for morale bonuses, manage unit positioning
**Result**: Maintained squad cohesion, prevented panic despite heavy losses

---

## Balance Parameters

| Parameter | Value | Range | Reasoning | Difficulty Scaling |
|-----------|-------|-------|-----------|-------------------|
| Action Points | 4 per turn | 3-6 | Tactical complexity | No scaling |
| Movement Range | 4 hexes | 3-6 | Map scale balance | ×1.2 on Easy |
| Accuracy Base | 50% | 30-70% | Hit probability | +10% on Easy |
| Damage Base | 3-5 | 2-8 | Combat lethality | ×0.8 on Easy |
| Cover Bonus | +20% defense | 10-30% | Positioning importance | ×1.5 on Hard |
| Time Units | 20 per turn | 15-30 | Pace control | +5 on Easy |
| Morale Threshold | 50% | 30-70% | Panic prevention | +10% on Easy |

---

## Testing Scenarios

- [ ] **Hex Coordinate System**: Verify coordinate calculations work correctly
  - **Setup**: Create test battle map with known hex positions
  - **Action**: Calculate distances and paths between units
  - **Expected**: Accurate hex-based calculations
  - **Verify**: Movement ranges and line-of-sight calculations

- [ ] **Combat Resolution**: Test hit probability and damage calculations
  - **Setup**: Units with known stats in combat scenario
  - **Action**: Execute multiple combat rounds
  - **Expected**: Results match statistical expectations
  - **Verify**: Hit rates and damage distributions

- [ ] **Action Point Economy**: Verify action point spending and turn management
  - **Setup**: Unit with full action points in complex scenario
  - **Action**: Execute various action combinations
  - **Expected**: Correct action point costs and turn progression
  - **Verify**: Action availability and turn completion

- [ ] **Morale System**: Test morale effects on unit performance
  - **Setup**: Units under various morale conditions
  - **Action**: Subject to combat stress and casualties
  - **Expected**: Morale affects accuracy and behavior
  - **Verify**: Performance changes under morale pressure

- [ ] **Environmental Effects**: Verify weather and terrain affect combat
  - **Setup**: Battle in different environmental conditions
  - **Action**: Execute combat actions in varied terrain
  - **Expected**: Environmental modifiers apply correctly
  - **Verify**: Accuracy and movement modifications

---

## Related Features

- **[Units System]**: Unit statistics and combat capabilities (Units.md)
- **[Items System]**: Weapons and equipment mechanics (Items.md)
- **[AI System]**: Enemy behavior and tactics (AI.md)
- **[3D System]**: Visual rendering and effects (3D.md)
- **[Hex System]**: Coordinate system and pathfinding (HexSystem.md)
- **[Morale System]**: Unit psychology and combat effectiveness (MoraleBraverySanity.md)

---

## Implementation Notes

**Priority Systems**:
1. Hex grid coordinate system and pathfinding
2. Core combat mechanics (accuracy, damage, hit chance)
3. Unit action system and turn management
4. Map generation and environmental effects
5. AI behavior and enemy tactics

**Balance Considerations**:
- Combat should reward tactical positioning and planning
- Action point economy creates meaningful decisions
- Environmental effects add strategic depth
- Morale system prevents optimal playstyles
- Difficulty scaling maintains challenge progression

**Testing Focus**:
- Coordinate system accuracy
- Combat probability distributions
- Action point balance
- Environmental modifier effects
- AI tactical behavior

---

## Review Checklist

- [ ] Coordinate system clearly defined and consistent
- [ ] Core combat mechanics specified with formulas
- [ ] Unit turn flow and initiative system documented
- [ ] Combat statistics balanced and testable
- [ ] Environmental systems integrated
- [ ] Status effects and morale mechanics defined
- [ ] Unit abilities and special systems specified
- [ ] Concealment and stealth mechanics balanced
- [ ] Victory and defeat conditions clear
- [ ] Balance parameters quantified with reasoning
- [ ] Difficulty scaling implemented
- [ ] Testing scenarios comprehensive
- [ ] Related systems properly linked
- [ ] No undefined terminology
- [ ] Implementation feasible
