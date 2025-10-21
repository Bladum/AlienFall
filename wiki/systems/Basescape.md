# Basescape

## Table of Contents

- [Overview](#overview)
- [Base Construction & Sizing](#base-construction--sizing)
- [Facility Grid System](#facility-grid-system)
- [Facilities & Services System](#facilities--services-system)
- [Unit Recruitment & Personnel](#unit-recruitment--personnel)
- [Equipment & Crafts Management](#equipment--crafts-management)
- [Base Maintenance & Economics](#base-maintenance--economics)
- [Base Defense & Interception](#base-defense--interception)
- [Base Integration & Feedback Loops](#base-integration--feedback-loops)
- [Base Radar Coverage](#base-radar-coverage)
- [Base Reports & Analytics](#base-reports--analytics)

---

## Overview

### System Architecture

Basescape is the tactical base management layer where players construct and maintain operational hubs. Each base is a grid-based facility complex that provides housing, research capability, manufacturing capacity, resource storage, and defensive capabilities. Bases serve as the economic and operational backbone of the player organization, converting battlefield salvage into research, equipped units, and long-term strategic advantage.

**Design Philosophy**

Basescape emphasizes spatial planning, resource optimization, and interconnected systems. Facilities provide diverse functions but require careful positioning to maximize efficiency bonuses. The system creates meaningful strategic decisions: size affects cost and defensive capacity; facility placement determines adjacency bonuses; maintenance costs scale with complexity. Multiple playstyles are supported: research-focused bases, manufacturing-focused factories, defense-oriented strongholds, or balanced facilities.

**Core Principle**: One base per province (exclusive territorial occupation).

---

## Base Construction & Sizing

### Overview
Base construction is a capital-intensive decision that gates player expansion. Base size directly affects initial cost, construction time, facility capacity, and defensive potential. Larger bases provide more slots but require greater resources and longer construction periods.

**Base Size Progression**

| Size | Grid | Tiles | Cost | Build Time | Relation Bonus | Capacity Slots | Strategic Use |
|------|------|-------|------|------------|---|---|---|
| Small | 4×4 | 16 | 150K | 30 days | +1 | 8-10 | Scout bases, forward positions |
| Medium | 5×5 | 25 | 250K | 45 days | +1 | 15-18 | Standard operational bases |
| Large | 6×6 | 36 | 400K | 60 days | +2 | 24-28 | Regional hubs, manufacturing centers |
| Huge | 7×7 | 49 | 600K | 90 days | +3 (if allied) | 35-40 | Strategic strongholds, capitols |

**Base Expansion System**

Bases can expand to larger sizes following a strict progression path. Each base starts at a selected size and can expand sequentially through the size progression (Small → Medium → Large → Huge). Expansions preserve all existing facilities while adding new available slots.

**Expansion Implementation**
The Basescape Expansion System (`engine/basescape/systems/expansion_system.lua`) provides complete expansion lifecycle management:

**Key Functions**:
- `getCurrentSize(base)` - Get current base size designation
- `canExpand(base, targetSize, gameState)` - Verify expansion prerequisites and return success/error
- `expandBase(base, targetSize, callback)` - Execute expansion, preserve facilities, add new slots
- `validateExpansionPrerequisites(base, targetSize, gameState)` - Full validation against all requirements
- `getExpansionInfo(base)` - Get status: current size, target size, remaining time, cost

**Expansion Costs & Time**
- **Small (4×4)**: Starting size, no expansion needed
- **Medium (5×5)**: 250K cost, 45 days build time
- **Large (6×6)**: 400K cost, 60 days build time  
- **Huge (7×7)**: 600K cost, 90 days build time

**Expansion Prerequisites**
Each size requires specific gates to prevent early dominance:
- **Technology**: Facilities available for size level
- **Relations**: Must maintain positive relations with country (see size requirements in table above)
- **Economy**: Credits available for expansion cost
- **Current Size**: Must follow sequential progression (cannot skip sizes)
- **Facility Preservation**: All existing facilities preserved and remain operational after expansion

**Strategic Implications**
- Expansion provides new facility slots without requiring relocation
- Costs and times scale to prevent rapid expansion across multiple bases simultaneously
- Expansion blocks base from deployment during construction phase
- Relation gates on Large/Huge ensure diplomatic cost to expansion
- Sequential progression creates meaningful long-term planning requirement

**Construction Gate Mechanics**
Base construction and size are gated by multiple factors, preventing early continental dominance:

| Factor | Impact | Requirement |
|--------|--------|------------|
| **Technology** | Determines facility types available | Base Tech, Grid Foundation |
| **Country Relations** | Allows base in territory | +0 minimum relations |
| **Biome** | Affects build cost, build time, terrain | Biome-appropriate structures |
| **Organization Level** | Gates base count | Level 1: 1 base, Level 5: 5 bases, Level 10: 10 bases |
| **Province Ownership** | Cannot build in enemy-controlled territory | Must have established control |
| **Relation Bonus** | Large/Huge bases require allied status | Relation >50 for Large, >75 for Huge |

**Construction Penalties by Biome**
- **Ocean**: +250% cost and time (engineering difficulty)
- **Mountain**: +40% cost and time (terrain challenges)
- **Arctic**: +35% cost and time (extreme conditions)
- **Urban**: +25% cost (infrastructure integration)
- **Desert**: +20% cost and time (supply logistics)
- **Forest/Grassland**: Baseline (no penalty)

**Build Time Factors**
```
Actual Build Time = Base Time × (1 + Biome Penalty) × (1 - Engineer Bonus) × (1 - Tech Bonus)
Engineer Bonus: Chief Engineer advisor provides -15% time reduction
Tech Bonus: Advanced construction research provides -10% to -20% time reduction
```

**Relocation Mechanics**
- Bases cannot be moved (destroy and rebuild only)
- Destroying base: Instant destruction, 0% refund on construction costs
- Rebuilding: Full cost and time required; region left vulnerable during rebuild
- Strategic implication: Base placement is permanent decision

---

## Facility Grid System

**Overview**
Base facilities exist on a **square grid**, creating a two-dimensional strategic layout. The square grid creates a simple, predictable topology where each facility touches up to 4 neighbors (cardinal directions), enabling straightforward placement strategies and predictable spatial planning. This grid system provides clear positioning logic and ensures all facility placement is unambiguous.

**Grid Architecture**
- **Grid Type**: Orthogonal Square (x-axis horizontal, y-axis vertical)
- **Base Grid Dimensions**: 40 tiles wide × 60 tiles tall (typical base maximum size)
- **Neighbor Topology**: Each facility connects to 4 adjacent squares (North, South, East, West) or 8 including diagonals (N, NE, E, SE, S, SW, W, NW)
- **Layout Pattern**: Creates rectangular base perimeter with predictable geometry
- **Coordinate System**: (X, Y) where X=0-39 (horizontal), Y=0-59 (vertical), origin at top-left
- **Rotation**: Facilities are **not rotatable** (fixed orientation on grid)
- **Visual Clarity**: Square grid prevents ambiguous positioning; all placement clear and unambiguous

**Grid Scale Reference**
- **Base Dimensions by Size**:
  - Small (4×4): 16 tiles (centered in 40×60 grid)
  - Medium (5×5): 25 tiles (centered in 40×60 grid)
  - Large (6×6): 36 tiles (centered in 40×60 grid)
  - Huge (7×7): 49 tiles (centered in 40×60 grid)
- **Tile Visual Size**: In-game rendering uses 24×24 pixel squares (scaled from 12×12 base sprites)
- **Base Viewport**: Full 40×60 grid displays as 960×1440 pixels unscaled (would be 960×720 with 2× downscale)

**Facility Dimensions**

| Size | Footprint | Grid Cells | Typical Facilities |
|------|-----------|-----------|---|
| 1×1 | Single square | 1 tile | Power Plant, Barracks (small), Storage (small) |
| 2×2 | 2×2 square | 4 tiles | Lab, Workshop, Academy, Hospital, Garage, Radar, Turret |
| 3×3 | 3×3 square | 9 tiles | Hangar (large), Prison, Temple |

**Placement Grid Coordinates (Example)**
```
Base Grid (40×60 typical, example showing 8×8 visible section):

  0 1 2 3 4 5 6 7
0 . . . . . . . .
1 . . P P . . . .    P = Power Plant (2×2 at coords 1,1)
2 . . P P . . . .
3 . . . . L L . .    L = Lab (2×2 at coords 4,3)
4 . . . . L L . .
5 . B B . . . . .    B = Barracks (2×2 at coords 1,5)
6 . B B . . . . .
7 . . . . . . . .

Facility placement uses top-left corner for origin:
- Power Plant: top-left at (1,1), occupies (1,1), (2,1), (1,2), (2,2)
- Lab: top-left at (4,3), occupies (4,3), (5,3), (4,4), (5,4)
- Barracks: top-left at (1,5), occupies (1,5), (2,5), (1,6), (2,6)
```

**Placement Restrictions**
- Facilities must be placed within base grid bounds (0,0 to base_width-1, 0 to base_height-1)
- Overlapping facility footprints are strictly prohibited
- **All facilities must be orthogonally adjacent** (touching on cardinal edges: N, S, E, W) to the main base cluster to be active
- Some facilities require specific neighboring facilities via adjacency (power-dependent facilities need Power Plant adjacent or connected via Corridor)
- **No diagonal adjacency counts** - only cardinal (4-directional) connections are recognized for adjacency bonuses

**Connection Requirements**
- **Mandatory Adjacency**: All facilities must be connected to the main cluster via orthogonal adjacency (4-directional only)
- **Isolated Facilities**: Any facility not orthogonally connected to power/core facilities is offline
- **Power Chain**: Power Plant must have unbroken orthogonal connection to all power-consuming facilities
- **Corridor Bridges**: Corridors (1×1) can bridge disconnected sections by acting as connecting intermediaries
- **Example Valid Connection**:
  ```
  Power Plant → Corridor → Lab
  (adjacent)   (adjacent) (adjacent to corridor)
  All connected and operational
  ```
- **Example Invalid Connection**:
  ```
  Power Plant . Lab
  (diagonal connection - NOT VALID)
  Lab will be offline despite proximity
  ```

**Strategic Grid Implications**
- **Compact Layouts**: 4-directional connectivity rewards tight clustering for efficiency bonuses but reduces overall facility count
- **Linear Chains**: Can create long chains of facilities (power → corridor → lab → workshop) but maximum reach before requiring additional power plants
- **Rectangular Patterns**: Square grid naturally encourages rectangular/grid-aligned facility arrangements
- **Expansion Planning**: Must plan for future facility additions while maintaining orthogonal connectivity
- **Diagonal Gap Problem**: Diagonally-separated facilities do NOT benefit from adjacency bonuses and are treated as offline
- **Corridor Efficiency**: Corridors are cheap (1×1) and provide essential connectivity but occupy valuable grid space
- **Power Distribution**: Multiple Power Plants may be needed for large bases to avoid long connection chains that consume grid space

---

## Facilities & Services System

**Overview**
Facilities are modular buildings that provide services, generate capacity, and consume resources. Each facility serves one primary function but may provide secondary benefits. Services are simple binary flags (service exists or doesn't); there are no service levels.

**Services Mechanic**
- **Service Types**: Power, Research Capability, Manufacturing Capacity, Psi Education, Radar Coverage, Defense
- **Binary Model**: Service either provided or not (no partial services)
- **Consumption**: Facilities and technologies consume services
- **Production Priority**: Power > Manufacturing > Research > Support (determines priority when supply constrained)

**Core Facilities Reference**

| Facility | Size | Production | Consumption | Maintenance | Capacity | Functions |
|----------|------|-----------|-------------|------------|----------|-----------|
| **Power Plant** | 1×1 | +50 power | 10 power (self) | 10K | N/A | Supplies all facilities |
| **Barracks (S)** | 1×1 | Housing | 5 power | 5K | 8 units | Soldier recruitment, housing |
| **Barracks (L)** | 2×2 | Housing | 10 power | 15K | 20 units | Large unit capacity |
| **Storage (S)** | 1×1 | Item storage | 2 power | 3K | 100 items | Basic storage |
| **Storage (M)** | 2×2 | Item storage | 5 power | 10K | 400 items | Expanded storage |
| **Storage (L)** | 3×3 | Item storage | 8 power | 20K | 800 items | Massive storage |
| **Lab (S)** | 2×2 | 10 man-days | 15 power | 15K | Research queue (1) | Basic research |
| **Lab (L)** | 3×3 | 30 man-days | 30 power | 40K | Research queue (2) | Advanced research, +20% scientists |
| **Workshop (S)** | 2×2 | 10 man-days | 15 power | 20K | Manufacturing queue (1) | Basic manufacturing |
| **Workshop (L)** | 3×3 | 30 man-days | 30 power | 50K | Manufacturing queue (2) | Advanced manufacturing, +20% engineers |
| **Hospital** | 2×2 | +2 HP/week, +1 Sanity/week | 10 power | 12K | 20 beds | Healing, mental recovery |
| **Academy** | 2×2 | +1 XP/unit/week | 8 power | 15K | 15 trainees | Unit training, experience gain |
| **Garage** | 2×2 | +50 HP/week repair | 12 power | 10K | 1 craft | Craft repair and maintenance |
| **Hangar (M)** | 2×2 | Storage | 15 power | 15K | 4 craft | Craft storage, small hangars |
| **Hangar (L)** | 3×3 | Storage | 30 power | 35K | 8 craft | Large craft storage |
| **Radar (S)** | 2×2 | +3 detection | 8 power | 8K | 500km range | Mission detection, Geoscape scan |
| **Radar (L)** | 2×2 | +5 detection | 12 power | 15K | 800km range | Enhanced detection, early warning |
| **Turret (M)** | 2×2 | 50 defense points | 15 power | 12K | Single weapon | Base defense, interception |
| **Turret (L)** | 3×3 | 150 defense points | 35 power | 30K | Multiple weapons | Advanced defense, area coverage |
| **Prison** | 3×3 | Prisoner storage | 12 power | 25K | 10 prisoners | Interrogation, research subjects |
| **Temple** | 2×2 | +1 Sanity/week (all units) | 8 power | 12K | Psi Education service | Mental health, morale boost |
| **Corridor** | 1×1 | Connection only | 2 power | 2K | N/A | Facility connector, defense position |

**Facility Lifecycle States**

| State | Production | Maintenance | Notes | Transition |
|-------|-----------|-------------|-------|-----------|
| **Operational** | 100% | Full | Normal operation | Active by default |
| **Construction** | 0% | 0% | Under construction | During build phase |
| **Offline (Player)** | 0% | 50% | Intentionally disabled | Player choice |
| **Offline (Power)** | 0% | 100% | Insufficient power | Automatic when power low |
| **Damaged** | 50-90% | 100% | Partial capability | After combat damage |
| **Destroyed** | 0% | 0% | Non-functional, requires rebuild | After reaching 0 HP |

**Adjacency Bonuses**
Horizontal/vertical connections provide efficiency bonuses:

| Pairing | Bonus | Requirements |
|--------|-------|---|
| Lab + Workshop | +10% research & manufacturing speed | Adjacent (1-hex touching) |
| Workshop + Storage | -10% material cost | Adjacent |
| Hospital + Barracks | +1 HP/week & +1 Sanity/week (all units) | Adjacent |
| Garage + Hangar | +15% craft repair speed | Adjacent |
| Power Plant + Lab/Workshop | +10% efficiency | Within 2-hex distance |
| Radar + Turret | +10% targeting accuracy | Adjacent |
| Academy + Barracks | +1 XP/week (training speed) | Adjacent |

**Stacking Limits**: Maximum 3-4 bonuses per facility (prevents overpowered clustering).

---

## Unit Recruitment & Personnel

**Overview**
Units are the only living personnel in bases. There are no separate scientists or engineers; all work is performed by units allocated to facilities. Units provide housing, training capacity, and combat effectiveness.

**Unit Recruitment Sources**

| Source | Cost | Quality Range | Time | Requirements |
|--------|------|---|---|---|
| **Country Recruitment** | 20-50K | 6-12 stats | Immediate | +0 relations minimum |
| **Faction Recruitment** | 30-75K | 8-14 stats (specialized) | 1 week | +2 relations with faction |
| **Advisor Recruitment** | -15% cost | +1 quality tier | Immediate | Chief Recruitment Officer advisor |
| **Retraining** | 0K | Randomized stats | 1 week | Existing unit pool |
| **Marketplace Purchase** | 40-100K | Variable | Immediate | Credits available |

**Barracks Capacity & Housing**
- **1×1 Barracks**: 8 unit capacity
- **2×2 Barracks**: 20 unit capacity
- **Plus Org Level Bonus**: +1-5 additional slots per level (total range 16-128)
- **Mandatory Salary**: 5K credits per unit per month (base cost)
- **Morale Impact**: Overcrowding (-50% morale if above capacity)

**Unit Stat Progression**

| Stat | Base Range | Growth per Promotion | Max Value | Purpose |
|------|---|---|---|---|
| HP | 15-25 | +1 per promotion | 50+ | Health points |
| Accuracy | 50-100% | +10% per promotion | 150%+ | Weapon effectiveness |
| Reaction | 6-12 | +1 per 2 promotions | 20+ | Initiative, action priority |
| Strength | 6-12 | +1 per promotion | 18+ | Carry capacity, inventory slots |
| Morale | 10+ | -1 per casualty, +1/week rest | 20+ | Psychological resilience |
| Sanity | 6-12 | -5 per failed psi save, +1/week hospital | 12 | Mental health, psi vulnerability |
| XP | 0-1000 | +5-10 per combat mission | 1000 (promotion) | Experience accumulation |

**Unit Specialization System**
- **Promotion Requirements**: 100 XP to unlock specialization
- **Specialization Types**:
  - **Gunner**: +2 damage, -5% accuracy (aggressive)
  - **Medic**: Can heal allies, -10% damage (support)
  - **Sniper**: +20% accuracy, -1 reaction (tactical)
  - **Assault**: +1 HP, +1 reaction (balanced)
- **Respec Option**: Retrain to change specialization (costs 5K, 1 week time)

**Health Recovery System**
- **Base Recovery**: +1 HP per week (passive)
- **Hospital Bonus**: +2 HP per week (capacity limited)
- **Medic Specialty**: +0.5 HP per medic per unit per week (stacks with hospital)
- **Over-Healing**: Cannot exceed max HP value

**Sanity System**
- **Base Recovery**: +1 Sanity per week (passive)
- **Hospital Bonus**: +1 Sanity per week (stacks)
- **Temple Bonus**: +1 Sanity per week (religious morale)
- **Psi Exposure**: -5 Sanity per failed psi-defense save
- **Breakdown**: At 0 Sanity, unit becomes unreliable (-50% accuracy, -10% morale)
- **Treatment Time**: Hospital recovery 2-4 weeks to restore full sanity

**Equipment System**
- **Weapon Slots**: 2 per unit (primary + secondary)
- **Armor Slot**: 1 per unit (body armor)
- **Inventory Limit**: Strength stat determines carry capacity
- **Equipment Transfer**: Instant transfer between units in base
- **Equipment Selling**: Can sell equipment at 50% purchase price

**Prisoner System**
- **Prison Facility**: Provides capacity for captured alien units
- **Prisoner Lifetime**: 30-60 days (varies by race)
- **Interrogation**: Prisoners provide research opportunity (+30 man-days to Alien Interrogation research)
- **Disposal Options**:
  - Execute: -5 karma, -2000 credits (body disposal)
  - Experiment: -3 karma, +50 man-days research (unethical)
  - Release: +5 karma, risk of enemy intelligence leak
  - Exchange: Trade for diplomatic favor (+5 relations with recipient)

---

## Equipment & Crafts Management

**Overview**
Items and crafts represent player equipment inventory and transport capabilities. All items have weight and space; crafts occupy dedicated slots in hangars and garages. Strategic management of equipment directly impacts field effectiveness.

**Item System**
- **Weight Property**: All items have weight stat (ranges 0.5-10 units)
- **Storage Space**: Each item occupies 1-5 grid spaces based on SIZE stat
- **Storage Limits**: Storage facilities have maximum capacity (100-800 items by size)
- **Overflow Handling**: Cannot exceed storage (purchase blocked if inventory full)
- **Selling**: Marketplace resale at 50% of purchase price
- **Transfers**: Transfer between bases via transfer system (1-14 day delivery)
- **Inventory Management**: Stack items by type to save space

**Craft System**
- **Hangar Slots**: Each hangar space holds 1 craft
- **Vehicle Sizes**:
  - Small craft: 1 slot (fighter, scout)
  - Medium craft: 2 slots (bomber, transport)
  - Large craft: 4 slots (capital ship)
- **Marketplace Purchase**: Buy additional craft at 40-150K credits each
- **Craft Weapons**: Each craft has armed hardpoints (varies by craft type)
- **Craft Armor**: Craft have armor class and HP (separate from health)
- **Crew Requirements**: 3-20 personnel depending on craft size
- **Fuel System**: Requires fuel item (costs 5% of tank capacity per travel)
- **Repair System**: Craft repair facility provides +50 HP/week repair

**Craft Maintenance**
- **Rearm**: Automatic at base (no separate rearm phase)
- **Energy Recovery**: Craft energy regenerates after every travel (100% recovery)
- **Repair Queue**: Damaged craft enter repair queue (automatic)
- **Repair Time**: 10% HP per week repair time + facility bonuses

---

## Base Maintenance & Economics

**Overview**
Bases are capital-intensive and require continuous resource investment. Maintenance costs scale with base complexity and scale non-linearly with size, creating economic pressure to optimize efficiency.

**Base Maintenance Costs**

| Cost Category | Calculation | Monthly Cost |
|---|---|---|
| **Layout Maintenance** | (Base Size)² × 5K | 80-2000K (4×4 to 7×7) |
| **Facility Maintenance** | Per facility × individual cost | 5-50K per facility |
| **Inactive Facility Tax** | 50% of active maintenance | 2-25K per disabled facility |
| **Unit Salaries** | 5K per unit per month | Variable (100-1000K+) |
| **Craft Maintenance** | 2K per craft per month | Variable (4K-100K) |
| **Labor Costs** | Man-days × 1K per day | Variable (research/manufacturing) |
| **Facility Damage Repairs** | HP needed × 1K per point | Variable (0-500K) |

**Total Base Cost Formula**
```
Monthly Cost = Layout + (Operational Facilities × Facility Cost) + (Disabled Facilities × 0.5 Facility Cost) + (Units × 5K) + (Crafts × 2K) + Labor + Repairs
Monthly Income = (Country Funding × Base Multiplier) + (Manufacturing Profit) + (Research Milestone Bonus) + (Equipment Sales)
Net Monthly Budget = Monthly Income - Monthly Cost
```

**Economic Management Strategies**
- **Efficient Layout**: Clusters reduce average adjacency distance but increases positioning complexity
- **Selective Operations**: Disable facilities to reduce costs during resource shortage
- **Specialization**: Focus on 2-3 facility types to maximize bonuses
- **Scaling**: Large bases require substantial monthly income; plan growth carefully
- **Overflow Handling**: Excess income per month accumulates as credits

---

## Base Defense & Interception

**Overview**
Bases are vulnerable to alien interception attacks. Defense is primarily passive (turrets, defensive facilities, HP values) supplemented by player active defense through Battlescape engagement.

**Defense Mechanics**
- **Passive Defense**: Turrets, radars, defensive facilities provide defense points
- **Active Defense**: Player can engage UFO in Battlescape (additional interception attempt)
- **Defense Rating**: Sum of all defense facility points (typical 50-300 points for established bases)

**Defense Resolution**
```
If Defense Points > UFO Attack Power: UFO defeated, base saved
If 50 < Defense Points < UFO Attack Power: UFO damages random facility (50% damage)
If Defense Points < 50: UFO succeeds, multiple facility damage (80% damage each)
```

**Facility Damage System**
- **HP Tracking**: Each facility has separate HP value (not armor, pure HP)
- **Random Targeting**: UFO attack targets 1-3 random facilities
- **Damage Application**: Each facility takes independent damage roll (10-50 points typical)
- **Facility States**:
  - 100% HP: Operational
  - 50-99% HP: Damaged (50-90% production)
  - 10-49% HP: Severely Damaged (25-50% production)
  - 0% HP: Destroyed (non-operational, rebuild required)

**Repair Mechanics**
```
Repair Time = (Damage Taken / Max HP) × (Facility Build Time) + (Facility Type Modifier)
Repair Cost = (Damage Taken / Max HP) × (50% of Build Cost)
```
- Example: Workshop with 50 max HP takes 30 damage, 2×2 size
  - Build time: 30 days
  - Repair time: (30/50) × 30 = 18 days
  - Repair cost: (30/50) × (50% of 250K) = 75K

**Battlescape Defense Integration**
- If player engages UFO in Battlescape, outcome determines facility damage
- Player victory: UFO destroyed, no facility damage
- Player defeat: UFO deals damage based on Battlescape outcome
- Draw: Partial damage (UFO escapes, inflicts 50% damage)

**Defense Building Strategy**
- **Early Game**: Vulnerable (1-2 turrets)
- **Mid Game**: Established defense (4-6 turrets, radar coverage)
- **Late Game**: Heavy defense (8+ turrets, multiple radars, defensive layout)
- **Specialization**: Can prioritize offense or defense based on playstyle

---

## Adjacency Bonus System

**Overview**
Facilities grouped strategically provide efficiency bonuses when positioned adjacent to complementary facilities. The Adjacency Bonus System (`engine/basescape/systems/adjacency_bonus_system.lua`) calculates and applies these bonuses automatically, rewarding compact, synergistic base layouts.

**Bonus Mechanics**
- **Trigger**: Facilities detect adjacent facilities of complementary types
- **Range**: Cardinal adjacency only (North, South, East, West) - diagonals do NOT count
- **Stacking**: Multiple bonuses can apply to same facility (limited to 3-4 per facility to prevent overpowered clustering)
- **Efficiency Multiplier**: Bonuses apply multiplicative efficiency increases (ranges 1.0x to 2.0x) rather than flat additions
- **Dynamic Recalculation**: Bonuses update whenever facility is placed, moved, or removed

**Seven Bonus Types**

| Pairing | Bonus Type | Requirements | Effect |
|--------|-----------|---|---|
| **Lab + Workshop** | Research & Manufacturing Synergy | Adjacent (1 tile touching) | +10% research speed, +10% manufacturing speed |
| **Workshop + Storage** | Material Supply Chain | Adjacent | -10% material cost for manufacturing |
| **Hospital + Barracks** | Medical Support | Adjacent | All personnel in Barracks: +1 HP/week, +1 Sanity/week recovery |
| **Garage + Hangar** | Craft Logistics | Adjacent | +15% craft repair speed |
| **Power Plant + Lab/Workshop** | Power Efficiency | Within 2-hex distance | +10% research/manufacturing efficiency (longer range) |
| **Radar + Turret** | Fire Control | Adjacent | +10% targeting accuracy (+10% hit chance) |
| **Academy + Barracks** | Training Synergy | Adjacent | +1 XP/week gain for all personnel in Barracks |

**Bonus Calculation System**
```
Adjusted Efficiency = Base Efficiency × Bonus Multiplier

Example - Lab with Research + Manufacturing Synergy:
Base Research Rate: 10 man-days/week
Adjacent Workshop Bonus: 1.10× (10% increase)
Adjusted Rate: 10 × 1.10 = 11 man-days/week

Multiple Bonuses Stack:
Lab + Workshop (+10%) AND Power Plant within range (+10%):
Final Multiplier: 1.10 × 1.10 = 1.21× (21% total bonus)
```

**Adjacency Display Information**
- `getAdjacencyInfo(base, facilityType, x, y)` - Returns human-readable summary
- **Bonus Summary**: Which bonuses apply to position
- **Missing Bonuses**: Which complementary facilities nearby would enable additional bonuses
- **Placement Recommendations**: Optimal adjacent facility suggestions

**Strategic Adjacency Patterns**

**Research-Focused Layout**:
```
Lab ← Lab (2×2) ← Storage
  ↓       ↓
Power - Workshop (2×2)
Plant    ↓
       Storage
```
- Lab + Workshop (+10% research & manufacturing)
- Workshop + Storage (-10% material cost)
- Power Plant ± Lab (-+ efficiency) 
- Result: Efficient research & manufacturing hub

**Defense-Focused Layout**:
```
Radar (2×2) - Turret (2×2)
                  ↓
             Turret (2×2)
```
- Radar + Turret (+10% accuracy)
- Multiple turrets clustered
- Result: Concentrated defensive firepower

**Personnel-Focused Layout**:
```
Academy (2×2) - Barracks (2×2)
     ↓                ↓
   Temple        Hospital (2×2)
```
- Academy + Barracks (+1 XP/week)
- Hospital + Barracks (+1 HP/week, +1 Sanity/week)
- Temple provides additional +1 Sanity/week (stacks)
- Result: Elite personnel development

---

## Power Management System

**Overview**
The Power Management System (`engine/basescape/systems/power_management_system.lua`) handles facility power distribution, shortage resolution, and emergency power-down procedures. Power is a critical resource; insufficient power cascades facility offline according to priority hierarchy.

**Power Generation & Consumption**

**Power Generation** - Power Plants provide power supply:
- **Power Plant (Standard)**: +50 power per plant
- **Multiple Plants**: Additive (+100 power for 2 plants, +150 for 3, etc.)

**Power Consumption** - Facilities consume power when operational:
- **1×1 Facilities**: 2-5 power each (Corridor: 2, Radar: 8-12, Power Plant: 10 self)
- **2×2 Facilities**: 5-15 power each (Lab: 15, Workshop: 15, Hospital: 10, Academy: 8, Garage: 12, Hangar: 15, Radar: 8-12, Turret: 15)
- **3×3 Facilities**: 8-35 power each (Prison: 12, Temple: 8, Hangar Large: 30, Lab Large: 30, Workshop Large: 30, Turret Large: 35)
- **Barracks**: 5 power (1×1) to 10 power (2×2)
- **Storage**: 2 power (1×1) to 8 power (3×3)

**Power Status Calculation**
```lua
local status = powerSystem:getPowerStatus(base)
-- Returns table with:
status.available      -- Total power generated
status.consumed       -- Total power consumed  
status.shortage       -- Amount of power deficit (0 if surplus)
status.ratio          -- Percentage utilization (0.0-1.0+)
status.isPowered      -- Boolean, true if sufficient power
status.surplus        -- Amount of power above minimum (0 if shortage)
```

**Power Priority Distribution**

When power shortage occurs, facilities go offline according to priority hierarchy (highest priority stays on):

| Priority | Level | Facilities | Notes |
|----------|-------|-----------|-------|
| **100** | Critical | Power Plants | Always maintain power generation capability |
| **90** | Essential | Headquarters | Command center operations |
| **80** | Medical | Hospital, Temple | Personnel recovery critical |
| **70** | Military | Barracks, Academy | Unit housing and training |
| **60** | Logistics | Hangar, Garage | Craft operations and repair |
| **50** | Production | Workshop, Lab | Research and manufacturing (priority order) |
| **40** | Storage | Storage facilities | Item preservation (low priority) |
| **30** | Defense | Radar, Turret | Detection and defense (online if possible) |
| **20** | Support | Corridor, Barracks | Structural connectivity |
| **5** | Minimum | Prison | Prisoner containment (very low priority) |

**Shortage Resolution Logic**
```lua
-- When power deficit occurs:
local shortage = consumedPower - generatedPower

-- System takes offline lower-priority facilities until:
-- (available power) >= (remaining consumption)

-- Example: 50 power available, 120 power needed, 70 shortage
-- 1. Keep Power Plants (priority 100): -10 power
-- 2. Keep Headquarters (priority 90): -5 power
-- 3. Keep Hospital (priority 80): -10 power
-- 4. Keep Barracks (priority 70): -10 power
-- 5. Keep Hangar (priority 60): -15 power
-- 6. Offline Lab (priority 50): -20 power (still short 10 power)
-- 7. Offline Workshop (priority 50): -30 power (now balanced)
-- Result: Lab and Workshop offline, others operational
```

**Manual Facility Control**
- `toggleFacilityPower(base, x, y)` - Player can manually disable facility
- Returns: `{bool success, string message}` 
- Rationale: Player optimization during shortage or to reduce maintenance cost
- Facility remains offline until player re-enables or power restored

**Emergency Power-Down**
- `emergencyPowerdown(base)` - Offline all non-critical systems
- Keeps online: Power Plants, Headquarters, Hospital, Barracks
- Puts offline: Everything else
- Use case: Severe crisis, maximize personnel survival

**Efficiency Calculation**
- Offline facilities: 0% efficiency
- Manual disable: 0% efficiency  
- Damaged facilities: 50-90% efficiency (based on damage)
- Online healthy: 100% efficiency (with adjacency bonuses applied)
- Method: `getFacilityEfficiency(base, facility)` returns 0.0-1.0 efficiency ratio

**Power Event Notifications**
- **Shortage Alert**: When first shortfall detected
- **Offline Notification**: When facilities go offline
- **Restoration Alert**: When power deficit resolved
- **Manual Disable**: Confirmation when player toggles facility

---

## Base Integration & Feedback Loops

**Overview**
Basescape integrates with Geoscape, Battlescape, and economy systems through vertical and horizontal feedback loops creating emergent gameplay and strategic depth.

**Vertical Integration** (Cascading Effects)
- **Geoscape Salvage** → Storage → Manufacturing → Equipped Units
- **Research Breakthrough** → Unlocks new manufacturing options → Equipment availability → Combat effectiveness
- **Battlescape XP** → Academy training → Promotions → Unit specializations → Improved field performance
- **Craft Damage** → Garage repair → Restored interception capability → Mission prevention

**Horizontal Integration** (Playstyle Support)

**Research-Focused Strategy**:
- Prioritize Lab, Academy, Prison facilities
- Invest in scientist recruitment and research capacity
- Early tech advantage enables late-game equipment
- Playstyle: Technology drives military superiority

**Manufacturing-Focused Strategy**:
- Prioritize Workshop, Storage, Garage facilities
- Maximize production queues and efficiency
- Convert salvage to profit margin efficiently
- Playstyle: Economic dominance through production

**Defense-Focused Strategy**:
- Prioritize Turret, Radar, Hangar facilities
- Invest in craft procurement and interception capability
- Prevent UFO missions through superior defense
- Playstyle: Military hardening and interception

**Support-Focused Strategy**:
- Prioritize Hospital, Academy, Barracks, Temple facilities
- Maximize unit recruitment and training
- Develop elite units through extended training
- Playstyle: Personnel quality over quantity

**Feedback Loops**
- **Victory Loop**: Mission Victory → Salvage → Manufacturing → Equipped Units → Better Mission Success (positive reinforcement)
- **Research Loop**: Research Completion → Manufacturing Unlock → Production → Income → More Research (exponential growth)
- **Recovery Loop**: Combat Damage → Hospital/Repair → Ready Units/Craft → Deployment (damage mitigation)
- **Specialization Multiplier**: Facility Synergy Bonus → Production Efficiency → Surplus Equipment → Transfer to Other Bases → Multiplicative strategic advantage

**Monthly Reconciliation Report**
- Research/manufacturing progress summary
- Personnel status (total/recovering/ready)
- Facility status (operational/damaged/offline)
- Inventory summary (items, crafts, capacity usage)
- Financial summary (income, costs, net profit/loss)
- Alerts (power shortage, storage overflow, unrest, structural damage)
- Strategic recommendations (capacity expansion, facility repair priorities, economic adjustments)

---

## Base Radar Coverage

**Overview**
Radar facilities provide Geoscape mission detection and early warning. Higher radar coverage increases mission visibility range, directly impacting player ability to intercept threats before they complete objectives.

**Radar Mechanics**
- **Detection Range**: 500-1000km per radar facility (based on facility size)
- **Stacking**: Multiple radars increase total detection area (coverage circles overlap)
- **Detection Bonus**: +3-5 per radar facility
- **Detection Formula**: Range × (1 + Bonuses × 0.1) = Total effective detection radius
- **Passive Scanning**: Automatic Geoscape scan every day cycle
- **Mission Visibility**: Missions within detection radius appear on map

**Detection Success Factors**
- Radar range and quantity
- Enemy unit stealth properties
- Electronic warfare countermeasures (from upgrades)
- UFO type (larger craft more visible)
- Atmospheric conditions (weather events affect radar)

**Hiding Mechanics**
- **Stealth Facilities**: Specialized facilities reduce base radar signature (-50% detection range)
- **Cloaking Technology**: Research unlock reduces visibility (-75% detection)
- **Underground Construction**: Biome bonus (volcanic/mountain bases naturally stealthier)

---

## Base Reports & Analytics

**Overview**
Monthly base reports provide comprehensive overview of base status, enabling informed strategic decisions and identifying optimization opportunities.

**Report Contents**
- **Production Summary**: Research progress, manufacturing queue, completion dates
- **Personnel Status**: Total units, recovering/ready count, morale average, sanity levels
- **Facility Status**: Operational count, damaged facilities, offline facilities, efficiency rating
- **Inventory Status**: Item count, storage capacity percentage, valuable items, low-stock alerts
- **Craft Status**: Total craft, ready/damaged/repairing count, fuel reserves, crew status
- **Financial Summary**: Monthly income, monthly costs, net profit/loss, bank balance, trend analysis
- **Defense Status**: Total defense points, turret status, radar coverage, vulnerability zones
- **Alerts & Warnings**:
  - Power shortage (suggest Power Plant expansion)
  - Storage overflow (suggest Storage expansion)
  - Personnel unrest (suggest morale improvement)
  - Structural damage (suggest repair priority)
  - Economic deficit (suggest cost reduction or income increase)
  - Capacity inefficiency (suggest facility reorganization)

**Strategic Insights**
- Suggested facility additions based on current bottlenecks
- Efficiency rating (utilization percentage across all facilities)
- Comparative analysis (base vs. other bases)
- Trend indicators (improving/declining efficiency over months)
- Optimization recommendations (adjacency bonus opportunities, power efficiency, etc.)
	


