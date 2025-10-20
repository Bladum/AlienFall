# Battlescape: Tactical Combat System

## Table of Contents
- [Overview](#overview)
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

---

## Overview

The Battlescape is the tactical combat layer of AlienFall—a turn-based, hex-grid tactical system inspired by X-COM. All combat is turn-based with no real-time elements, emphasizing strategic planning, resource management, and tactical decision-making.

### Combat Paradigm
- **Hex Grid**: Q-axis horizontal, R-axis diagonal coordinate system
- **Hexagon Scale**: Each hex represents 2-3 meters of game world space
- **Turn Duration**: 30 seconds of in-game time per turn
- **Time to Action**: Approximately 1 second per tile of movement
- **Neighbor System**: Each hex has 6 adjacent neighbors (standard hex topology)

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
- **Night vision penalty**: Sanity damage (-1) during night missions
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
- Sanity penalty: −1
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
- **Modified by**: Equipment (nightvision goggles, scopes), traits, morale, status effects

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

**Step 1: Base Accuracy Calculation**
Start with unit and weapon base accuracy:
- Base unit class accuracy (typically 60–80%)
- Weapon base accuracy modifier (−10% to +10%)
- Weapon mode modifier (snap: −5%, aim: +15%, etc.)

**Step 2: Range Modifier**
Apply penalty/bonus based on distance to target:

**Range Tiers** (assuming max range = 12 hexes):
- **0–75% of max range (0–9 hexes)**: 100% accuracy, linear decline to 50% at 75% range
- **75–100% of max range (9–12 hexes)**: 50% accuracy, linear decline to 0% at 100% range
- **100–125% of max range (12–15 hexes)**: 0% accuracy, linear decline to −100% (automatic miss)

**Minimum Range Modifier** (some weapons):
- **0–25% of max range**: Penalties apply (difficult to aim at close range)
- Sniper rifles: −50% accuracy within 3 hexes
- Shotguns: No penalty (effective at close range)

**Step 3: Cover Modifiers**
- **Target cover**: Look at all obstacles between shooter and target
- **Per hex of fire cost**: Each point = −5% accuracy
- **Maximum cover bonus**: Typically capped at −50% (always 5% minimum chance)

**Step 4: Line of Sight Modifier**
- **Target visible**: No modifier
- **Target not visible**: −50% accuracy penalty
- Shots at blind targets are last-resort actions

**Step 5: Cumulative Clamping**
- Clamp all modifiers to a **5%–95% range**
- Ensures no guaranteed hits or misses (except critical rules)

#### Final Accuracy Test

Roll against final accuracy percentage:
- **Success**: Bullet travels directly to target tile
- **Failure**: Bullet deviates (see [Projectile Deviation](#projectile-deviation))

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

*Note: Melee mechanics are marked as TODO in the original design. The following represents suggested implementation:*

#### Melee Attack Resolution

**Stats Used**:
- Attacker: Strength stat (instead of Aim/Accuracy)
- Defender: Reaction stat (for dodge/parry)

**AP Cost**: 1 AP per melee attack

**Energy Cost**: Can draw from unit's Energy Point pool (different from ranged)

**Accuracy Calculation**:
- Base: Unit strength + weapon melee bonus
- Modified by: Target cover, target defensive stance, unit morale
- Clamped: 5%–95% like ranged attacks

**Defense Reaction**:
- Defender can attempt to dodge/parry (costs no AP, passive)
- Roll against defender's reaction stat
- Success reduces damage or negates hit

**Damage**: Weapon-dependent; typically higher than ranged but more risky

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

Stun is temporary damage that accumulates but naturally decays. Unlike HP, stun represents fatigue and disorientation.

#### Stun Mechanics

- **Base Stun**: 0 at battle start
- **Accumulation**: Various effects inflict stun (smoke, stun weapons, etc.)
- **Natural Decay**: −1 stun per turn automatically
- **Incapacitation**: When stun ≥ current max HP, unit becomes unconscious

#### Unconscious State
- Unit has 0 AP available
- Cannot perform actions
- Cannot participate in line-of-sight calculations
- Remains on battlefield until stun drops below max HP
- Other units can revive with medikit or wait for stun decay

#### Rest Action
- Costs 3 AP
- Removes −1 stun (faster than natural decay)
- Useful for recovering from stun damage

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
- **Status Effects**: Morale/sanity penalties reduce AP available
- **No Carryover**: Unused AP is lost at end of turn

#### Reinforcement Trigger
- **Specific Turns**: Reinforcements may arrive at designated turns (turn 5, turn 10, etc.)
- **Trigger**: New squad appears at designated map block
- **Integration**: Reinforcement squad acts on their first turn (included in turn order)

---

## Combat Statistics & Unit Stats

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

### Morale System

Morale represents unit confidence during battle. It is derived from Bravery stat and acts as a buffer during combat.

#### Morale Baseline
- **Starting morale**: Equals BRAVERY stat (6-12 range) at start of battle
- **Minimum morale**: 0 (triggers panic mode - unit becomes inactive)
- **Maximum morale**: Equal to BRAVERY stat (cannot exceed it)

#### Morale Loss Events

Units lose 1 morale when under stress:
- Witnessing ally death nearby (within 5 hexes)
- Taking critical damage (critical hit received)
- Seeing enemy in superior numbers
- Other tactical stress events

#### Morale Thresholds & Effects

| Morale | Effect |
|---|---|
| **6-12 (BRAVERY range)** | Normal capability, full AP available |
| **3-5** | Stressed but functional, full AP |
| **2** | AP modifier: −1 AP per turn |
| **1** | AP modifier: −2 AP per turn |
| **0** | **PANIC MODE** - Unit becomes inactive (cannot act) |

#### Morale Recovery
- **Rest action**: 2 AP → +1 morale per turn
- **Leader aura**: +1 morale to nearby allies per turn (requires leader trait)
- **Rally action**: 4 AP → +2 morale to self or nearby ally
- **Post-mission**: Morale resets to base BRAVERY value

---

### Sanity System

Sanity represents psychological stability. It is a separate buffer from morale that degrades over time and intense experiences. Range: 6-12 (similar to other core stats).

#### Sanity Baseline
- **Starting sanity**: 6-12 (based on unit class/specialization)
- **Minimum sanity**: 0 (triggers panic mode - unit becomes inactive)
- **Maximum sanity**: Starting value for that unit
- **Recovery**: +1 sanity per week in base (passive)

#### Sanity Loss During Missions

After a mission concludes, units lose sanity based on mission difficulty:

| Difficulty | Sanity Loss |
|---|---|
| **Standard** | 0 |
| **Moderate** | −1 |
| **Hard** | −2 |
| **Horror** | −3 |

**Additional Penalties**:
- **Night missions**: −1 sanity (atmospheric horror)
- **Heavy casualties**: −1 per ally KIA
- **Witnessing horror**: −1 per special event (specific to mission)

#### Sanity Thresholds & Effects

| Sanity | Effect |
|---|---|
| **6-12 (starting range)** | Normal psychological state, full AP available |
| **3-5** | Psychological stress, full AP available |
| **2** | AP modifier: −1 AP per turn |
| **1** | AP modifier: −2 AP per turn |
| **0** | **PANIC MODE** - Unit becomes inactive (cannot act), will break formation |

#### Sanity Recovery
- **Base recovery**: +1 sanity per week (automatic, passive)
- **Hospital facility**: +1 additional sanity per week
- **Temple facility**: +1 additional sanity per week (religious morale)
- **Rest/downtime**: Accelerated recovery during leave periods

#### Sanity Recovery
- **Rest & recreation** (post-mission): +1 sanity per week
- **Psychological counseling**: +2 sanity (special facility)
- **Rotation out of service**: Full recovery with time
- **Performing well in combat**: No penalty, builds confidence

#### Panic State
- When morale = 0 **or** sanity = 0: Unit enters panic mode
- Panicked unit becomes inactive (0 AP, cannot perform actions)
- Remains panicked until morale **and** sanity both recover above 0

---

### Bravery System

Bravery is a core stat (6-12 range) that serves as the foundation for morale during battle. It determines psychological resilience and panic resistance.

#### Bravery Role
- **Morale Buffer**: BRAVERY stat determines max morale for that unit during battle
- **Stat Definition**: Core unit stat (6-12 range like STR, React, etc.)
- **Class-Based**: Some classes have higher/lower bravery ranges
- **Permanent**: Does not change during mission (unlike morale/sanity)

#### Bravery & Morale Connection
- **At battle start**: Morale = BRAVERY value
- **As battle progresses**: Morale can decrease from stress events
- **Cannot exceed**: Morale cannot go above BRAVERY stat
- **Represents**: How quickly unit recovers from stress

#### Bravery Modifiers
- **Unit traits**: "Brave" (+2 bravery), "Timid" (-2 bravery)
- **Experience**: Veterans have higher bravery (+1 per rank)
- **Equipment**: Ceremonial/officer gear can grant +1 bravery
- **Morale boost**: Leaders can temporarily enhance nearby unit confidence (+1 morale, not bravery)

#### Strategic Importance
- Higher bravery = larger morale pool (better panic resistance)
- Low bravery units panic more easily
- Affects squad composition (high/low bravery units balance each other)
- Units with 12 bravery rarely panic even under stress

---

### Wounds System

Wounds are persistent injuries that continue damaging a unit until healed.

#### Wound Mechanics
- **Infliction**: Critical hits always inflict 1 wound (see [Critical Hits](#critical-hits))
- **Duration**: Wounds persist after mission (don't heal automatically)
- **Damage**: Each wounded body part deals 1 HP damage per turn
- **Stacking**: Multiple wounds deal cumulative damage

#### Wound Healing
- **Medikit use**: Each medikit use heals 1 wound
- **Recovery time**: 4 weeks per wound (in base time units)
- **Healing facility**: Can reduce recovery time with specialized medical care

#### Wound Effects
- As wounds accumulate, unit effectiveness decreases
- A heavily wounded unit is nearly combat-ineffective
- Strategic decision: Keep wounded unit in service for reduced capability, or rotate them out for healing

---

### Critical Hits

#### Triggering Critical Hits

**Chance to Crit**:
- Base weapon critical chance: 5%–15% (weapon-dependent)
- Unit stat modifier: Aim or strength-based
- Weapon mode modifier: Some modes increase crit chance (e.g., "critical" mode +25%)
- Cumulative: All modifiers stack

#### Critical Hit Effects
- **Guaranteed wound**: Target automatically receives 1 wound
- **No damage bonus**: Crit doesn't increase damage, only inflicts wound
- **Optional additional effect**: Some weapons may add secondary effect (stun, knockback)

#### Strategic Importance
- Crits are primarily for wound infliction
- Low crit chance means wounds are rare, requiring deliberate targeting
- Special units/weapons designed for wound infliction have higher crit rates

---

### Status Effect System

#### Effect Types

##### Smoke Damage
- **Type**: Stun (temporary)
- **Source**: Smoke clouds
- **Damage**: Small = 0/turn, Large = 1/turn
- **Duration**: Automatic decay
- **Stacking**: Multiple smoke clouds apply multiple stuns
- **Visibility**: −3 sight per smoke intensity

##### Fire Damage
- **Type**: HP damage + morale
- **Source**: Entering fire tile
- **Damage**: 1–2 HP + −1 morale
- **Movement penalty**: +5 MP cost to enter fire
- **Duration**: Persistent until unit leaves or fire extinguishes

##### Gas Damage
- **Type**: Variable (depends on gas type)
- **Source**: Toxic gas clouds
- **Damage**: 1–2 HP per turn (varies by gas)
- **Duration**: Persists like smoke
- **Special**: Can inflict various status effects (poison, confusion, etc.)

##### Bleeding (From Wounds)
- **Type**: HP damage
- **Source**: Wounds
- **Damage**: 1 HP per turn per wound
- **Duration**: Until healed
- **Can be critical**: Heavy bleeding immobilizes unit

##### Stun Effects
- **Type**: Temporary incapacity
- **Stacking**: Multiple stun sources add together
- **Recovery**: 1 per turn naturally, or rest action
- **Threshold**: Stun ≥ max HP causes unconsciousness

##### Suppression
- **Type**: Action point reduction
- **Source**: Suppress enemy action
- **Effect**: −1 AP next turn
- **Duration**: Next turn only
- **Stacking**: Multiple suppressions don't stack (capped at −1 AP)

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

#### Complete Accuracy Formula

```
base_accuracy = unit_accuracy + weapon_bonus + weapon_mode_bonus
range_accuracy = base_accuracy × range_modifier (0–100%)
cover_accuracy = range_accuracy − (cover_value × 5%)
los_accuracy = cover_accuracy − (visible ? 0% : 50%)
final_accuracy = clamp(los_accuracy, 5%, 95%)
```

#### Accuracy Modifiers (Summary)
- **Unit class**: 60–80% base
- **Weapon**: ±10% bonus
- **Weapon mode**: −5% to +25%
- **Range**: Variable, can reach 0%
- **Cover**: −5% per cover point
- **Line-of-sight**: −50% if not visible

---

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
- **Exceeding budget**: If exceeded, mission is marked as "failed concealment" (tactical loss)
- **Budget reset**: Each new mission has independent budget

#### Budget Consumption

| Action | Cost |
|---|---|
| **Heavy weapon fire** | 5–10 points |
| **Grenade/explosive** | 10–20 points |
| **Large explosion** | 20–50 points |
| **Enemy death (observed)** | 5–10 points |
| **Enemy death (unobserved)** | 0 points |
| **Melee kill** | 0 points |
| **Light weapon** | 0–2 points |
| **Terrain destruction** | 5–10 points |
| **Alarm trigger** | Instant loss |

#### Budget Recovery
- No natural recovery (budget only depletes)
- Completing objective silently ends mission (remaining budget unused)
- Failed concealment carries story/narrative penalties

#### Standard Missions
- Most missions have very large budgets (effectively unlimited)
- Budget system only matters for specialized stealth missions
- Designed for advanced players seeking challenge variants

---

## Future Enhancements

### Directional Sight (Unit Facing)

**Planned Feature**: Units have a facing direction that determines what they can see.

#### Facing Mechanics
- **Facing direction**: 0°–360° (or 6 directions on hex grid)
- **Sight cone**: 120° forward arc from unit facing
- **Behind units**: Cannot be seen if outside arc
- **Flanking**: Attacking from behind unit grants bonus

**Impact on Combat**:
- Adds depth to positioning tactics
- Requires tactical awareness of unit facing
- Enables surprise attacks from stealth

### 3D Battlescape (Alternative View)

**Planned Expansion**: First-person or 2.5D perspective for alternate battlescape mode.

#### Concept
- Inspired by Wolfenstein 3D but fully turn-based
- Single-unit control in first-person view
- Squad-level coordination in strategic view
- Blends tactical squad gameplay with immersive first-person perspective

#### Integration
- Alternative battlescape system (not replacing hex grid)
- Available for specific mission types or playstyles
- Distinct artwork and design language

---

## Advanced Mechanics & Tactical Depth

### Unit Stance System

Units can adopt different stances that modify their combat capabilities and movement:

#### Stance Types

**Standing**:
- Movement: Normal cost
- Accuracy: Normal
- Defense: Normal
- AP Cost: 0 (default)
- Usage: General combat

**Kneeling**:
- Movement: −50% movement speed (cannot run)
- Accuracy: +15% (stability bonus)
- Defense: +2 cover (small additional cover)
- AP Cost: 1 to adopt, 1 to return to standing
- Usage: Defensive positioning, sniper fire

**Prone**:
- Movement: Crawl only (−80% movement speed)
- Accuracy: +25% (extreme stability)
- Defense: +5 cover (significant cover bonus)
- AP Cost: 2 to adopt, 2 to return to standing
- Usage: Heavy defense, long-range precision

**Climbing**:
- Movement: Climb vertical obstacles (cost +100%)
- Accuracy: −50% (unstable)
- Defense: −2 cover (exposed)
- AP Cost: 1 to initiate, continuous cost per hex
- Usage: Traversal only, not combat

### Squad Tactics & Coordination

#### Fire Support Network

Units can coordinate attacks for improved effectiveness:

**Supporting Fire**:
- **Effect**: When attacking same target as adjacent ally, gain +10% accuracy per supporting ally
- **Maximum Bonus**: +30% (3 allies supporting)
- **Requirement**: Line-of-sight to target from all participants
- **Strategic Use**: Gang up on priority targets

**Suppressive Fire**:
- **Effect**: Multiple units firing at same enemy costs that enemy −1 AP per attacker (max −2)
- **Requirement**: At least 2 units firing
- **Stacking**: Does not stack beyond −2 AP penalty

#### Retreat Coordination

Units can cover allies' retreat:

**Covering Fire**:
- **Cost**: 2 AP per unit covering
- **Effect**: Retreating ally gains +20% defense; covering unit gains +50% reaction fire chance if enemy pursues
- **Range**: 5-hex distance from ally
- **Duration**: One movement action by covered ally

### Line-of-Sight Team Sharing

All units in the same team share line-of-sight information:

- **Detection Sharing**: If one unit sees enemy, all team members know enemy location
- **Tactical Advantage**: Team-wide visibility creates information advantage
- **Strategic Implication**: Scouts increase team awareness; hiding from one unit still reveals to team
- **Limitation**: Fog-of-war still applies (unexplored tiles remain hidden)

### Damage Mitigation & Risk-Reward

#### Cover Positioning Strategy

**Cover Levels**:
- **No Cover**: 0% defense bonus
- **Half-Cover**: +10% defense (partially behind obstacle)
- **Full Cover**: +20% defense (completely behind obstacle)
- **Elevated Cover**: +25% defense (height advantage)

**Cover Breakage**:
- Weak obstacles (bushes, crates): Destroyed by area damage, exposing unit
- Medium obstacles (walls): Slowly destroyed by concentrated fire (4–6 hits)
- Strong obstacles (bunkers): Highly resistant, cannot be destroyed (permanent cover)

#### Risk vs. Reward

**Aggressive Positioning**:
- No cover (exposed): +0% defense, +100% accuracy for attacks
- Usage: Offensive units, when overwhelming enemy

**Defensive Positioning**:
- Full cover: +20% defense, −30% accuracy for attacks
- Usage: Holding position against superior force

**Balanced Positioning**:
- Half-cover: +10% defense, ±0% accuracy
- Usage: Standard tactical play

### Advanced Positioning & Flanking

#### Flanking Mechanics

Attacking from behind an enemy grants tactical bonuses:

**Flanked Status**:
- Triggered when attacker is outside target's forward facing arc (120°, future mechanic)
- **Effect**: Attacker gains +20% accuracy, −50% target defense
- **Defense**: Target can only defend with reaction, not with cover bonuses
- **Strategic Use**: Rewards tactical positioning and unit coordination

#### Elevation Advantage

Attacking from higher elevation grants bonuses:

**High-Ground Status**:
- Triggered when attacker is on higher terrain than target
- **Effect**: Attacker gains +15% accuracy, +1 range
- **Target Effect**: Attacker gains +2 sight range against target
- **Strategic Use**: Hill control, building capture

### Environmental Destruction & Adaptive Tactics

#### Destructible Cover

Enemies can destroy cover units are hiding behind:

**Blast Damage to Cover**:
- Grenades and explosives damage cover obstacles
- After taking cumulative damage, cover is destroyed
- Example: Wooden crate (20 HP) destroyed by single grenade (15 damage)

**Rebuilding Cover**:
- Some cover can be partially rebuilt (sandbags, barricades)
- Cost: 2 AP, target must have materials in inventory
- Partial cover provides 50% defense of destroyed version

#### Lighting & Visibility

Dark areas reduce visibility:

**Shadows**:
- Units in shadow areas gain +3 sight cost for detection
- Attacking into shadow: −20% accuracy
- Strategic Use: Night missions, interior combat

**Light Sources**:
- Flashlights, fires, explosions create light sources
- Light extends visibility +3–5 hexes
- Can be destroyed to create darkness

### Morale Cascade & Squad Breaks

#### Morale Contagion

Low morale spreads through squads:

**Squad Morale Penalty**:
- If one unit in squad drops below morale 3, nearby allies −1 morale
- Range: 3-hex radius
- Effect: Creates cascading panic in trapped squads
- Counter: Leaders (high morale units) provide +1 morale aura

#### Squad Break Condition

When squad loses morale cohesion:

**Broken Squad**:
- When 50%+ of squad is at morale 0 (panicked)
- Effect: Remaining units −20% accuracy, +2 morale loss per turn
- Result: Squad often retreats or surrenders
- Recovery: Leader rallying or mission success can restore morale

### Resource Scarcity & Tension

#### Ammo Scarcity

Limited ammunition creates tactical tension:

**Ammo Count Tracking**:
- Each weapon has current ammo vs. max magazine size
- Low ammo warning: Red indicator at 25% magazine
- Empty magazine: Weapon disabled until reload

**Resupply Points**:
- Some missions include supply caches on map
- Caches contain: Ammo, medkits, grenades, specialistic items
- Limited supply: Typically 2–4 caches per mission

**Rationing Mechanic**:
- Player must manage resource consumption
- Wasting ammo on low-priority targets depletes reserves
- Forces economical decision-making

#### Power/Energy Scarcity

Powered weapons and equipment have energy limits:

**Energy-Dependent Weapons**:
- Laser rifles, plasma weapons, psi items
- Draw from unit's EP pool directly
- Depletion: Unit cannot use energy weapons until EP regenerates

**Strategic Choices**:
- Use lethal but expensive energy weapons
- Or conserve EP for critical moments
- Energy regeneration limits (30% per turn)

---

## Conclusion

The Battlescape is the core tactical layer of AlienFall, emphasizing turn-based strategy, resource management, and tactical positioning. With its hex-grid foundation, detailed combat mechanics, and environmental interactivity, the Battlescape provides a rich, engaging tactical experience inspired by X-COM and refined for modern game design principles.

All systems—from movement and accuracy to morale and salvage—interconnect to create emergent gameplay where player decisions have meaningful consequences. Unit classes, equipment, psionic abilities, and advanced positioning mechanics combine to enable diverse playstyles and strategic approaches, ensuring replayability and depth across multiple playthroughs.
