# Basescape System

> **Status**: Design Document
> **Last Updated**: 2025-10-28
> **Related Systems**: Geoscape.md, Economy.md, Units.md, Crafts.md

## Table of Contents

- [Overview](#overview)
  - [System Architecture](#system-architecture)
- [Base Construction & Sizing](#base-construction--sizing)
  - [Overview](#overview)
- [Facility Grid System](#facility-grid-system)
- [Facilities & Services System](#facilities--services-system)
- [Unit Recruitment & Personnel](#unit-recruitment--personnel)
- [Equipment & Crafts Management](#equipment--crafts-management)
- [Base Maintenance & Economics](#base-maintenance--economics)
- [Base Defense & Interception](#base-defense--interception)
- [Adjacency Bonus System](#adjacency-bonus-system)
- [Power Management System](#power-management-system)
- [Base Integration & Feedback Loops](#base-integration--feedback-loops)
- [Base Radar Coverage](#base-radar-coverage)
- [Base Reports & Analytics](#base-reports--analytics)
- [Examples](#examples)
- [Balance Parameters](#balance-parameters)
- [Difficulty Scaling](#difficulty-scaling)
- [Testing Scenarios](#testing-scenarios)
- [Related Features](#related-features)
- [Implementation Notes](#implementation-notes)
- [Review Checklist](#review-checklist)

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

## COMPREHENSIVE BASESCAPE SPECIFICATIONS (A6, A7, B4/R1, C4, R8)

### A6: FACILITY UPGRADES SYSTEM

**Overview**: Facility upgrades allow in-place enhancement of existing facilities without relocation, creating meaningful investment decisions.

**Upgrade Mechanics**:
- **Same-Location Upgrade**: Facility remains in grid position, upgrades in-place over time
- **Construction Time**: 14-30 days depending on upgrade complexity
- **Cost**: 50-150K credits per upgrade (varies by facility type)
- **No Destruction**: Original facility is preserved; upgrade adds capabilities

**Upgrade Categories**:

| Facility | Base Level | Upgrade 1 | Upgrade 2 | Notes |
|----------|-----------|----------|----------|-------|
| **Lab (S)** | 10 man-days | +50% output (15 man-days) | +2 research queue | Increased scientist productivity |
| **Workshop (S)** | 10 man-days | +50% output (15 man-days) | +2 manufacturing queue | Efficiency improvements |
| **Hospital** | +2 HP/week | +5 beds capacity | +1 sanity/week bonus | Medical tech advancement |
| **Academy** | +1 XP/week | +10 trainee capacity | +2 XP/week bonus | Training infrastructure |
| **Barracks (S)** | 8 capacity | Upgrade to 2×2 equivalent (20) | N/A | Structural expansion |
| **Storage (S)** | 100 items | Upgrade to M equivalent (400) | Upgrade to L equivalent (800) | Capacity scaling |
| **Hangar (M)** | 4 craft | Upgrade to L equivalent (8) | N/A | Additional craft slots |
| **Power Plant** | 50 power | +50 additional power | N/A | Enhanced generation |
| **Radar (S)** | 500km range | Upgrade to L range (800km) | N/A | Extended detection range |
| **Turret (M)** | 50 defense | +75 defense points | N/A | Weapon augmentation |

**Upgrade Economy**:
- Upgrades cost 50-150K credits (typically 20% of facility construction cost)
- Upgrade provides 30-50% efficiency boost (less than rebuilding but cheaper)
- Net calculation: Upgrade cost < (Original facility cost × 0.3) makes upgrades economical

**Strategic Implications**: Upgrades allow specialization without expansion, enabling focused base strategies (research-only, production-only, defense-only).

---

### A7: PRISONER SYSTEM

**Overview**: Prisoners are captured enemy units that provide research opportunities, interrogation intelligence, and potential conversion to player forces.

**Prisoner Mechanics**:

**Capture Process**:
- Units with HP > 0 in Battlescape at mission end (not rescued by enemies) become prisoners
- Prisoners transported to Prison facility automatically
- Capacity limit: Prison 3×3 = 10 prisoners maximum
- Overflow prisoners are executed (cannot exceed capacity)

**Prisoner Lifetime**:
```
Lifetime (days) = 30 + (Unit Max HP × 2)
```

**Examples**:
- Low-tier alien (6 HP max): 30 + 12 = 42 days lifetime
- High-tier alien (20 HP max): 30 + 40 = 70 days lifetime
- Unique VIP (25 HP max): 30 + 50 = 80 days lifetime

**Meaning**: Stronger prisoners survive longer in captivity, providing extended research window.

**Prisoner Options** (Player Decision):

| Option | Effect | Karma | Research | Duration | Cost |
|--------|--------|-------|----------|----------|------|
| **Execute** | Prisoner removed immediately | −5 | 0 | Immediate | 0 |
| **Interrogate** | Extract military intelligence | +0 | +30 man-days | 1 week | 5K |
| **Experiment** | Medical/biological research | −3 | +60 man-days | 2 weeks | 0 |
| **Exchange** | Trade to friendly faction | +3 | 0 | 1 week | 0 |
| **Convert** | Attempt to recruit as unit | ±0 | 0 | 4 weeks | 50K |
| **Release** | Free prisoner, gain relations | +5 | 0 | Immediate | 0 |

**Interrogation System**:
- Interrogation: +30 man-days to "Alien Behavior" or "Alien Biology" research
- Multiple interrogations possible (per prisoner once/week)
- Success rate: 100% (automatic)
- Prisoner remains alive after interrogation (lifetime continues)

**Experimentation**:
- Experimentation: +60 man-days (double interrogation) but prisoner dies after 2 weeks regardless
- Costs no credits but kills prisoner regardless of lifetime
- Ethically controversial: −3 karma (affects ending)

**Prisoner Conversion**:
- Attempt to convert prisoner to player forces (unit recruitment)
- Success rate: 60% + (Diplomat Advisor bonus) − (Enemy faction bonus)
- Cost: 50K credits + 4 weeks conversion time
- Result: Prisoner becomes loyal unit OR is executed upon failure
- Strategy: Valuable for capturing high-stat aliens

**Exchange Diplomacy**:
- Trade prisoners to friendly factions for diplomatic favor
- +3 relations with recipient faction
- +3 karma (humanitarian approach)
- Prisoner released peacefully

**Release Option**:
- Free prisoner without interrogation
- +5 karma (humanitarian choice)
- +1 relations with enemy faction (slight mercy bonus)
- Prisoner leaves with knowledge of player base

**Prison Facility Management**:
- Prisoners consume 1 "maintenance" per 2 prisoners per day
- Storage: 10 maximum prisoners (3×3 facility size)
- Each prisoner requires active cell (cannot stack)
- Escape chance: 1% per prisoner per day (very low)

**Prisoner Death Mechanics**:
- Prisoners die naturally when lifetime expires
- Prisoners can be executed at any time
- Failed conversion attempt results in execution
- Escaped prisoners: 1% per day chance per prisoner

---

### B4/R1: POWER MANAGEMENT SYSTEM (COMPREHENSIVE)

**Overview**: Power is the critical resource that enables base operations. This comprehensive specification consolidates all power mechanics.

**Power Generation**:

| Facility | Power Output | Maintenance | Efficiency | Notes |
|----------|-------------|-------------|-----------|-------|
| **Power Plant** | +50 power | 10 power (self-consume) | 100% | Base power generation |
| **Multiple Plants** | Additive | 10 per plant | 100% each | +100 for 2 plants, +150 for 3 |
| **Enhanced Plant** (upgrade) | +100 power | 15 power | 100% | Double output variant |

**Power Consumption** (by facility size/type):

| Facility | Size | Power Cost | Notes |
|----------|------|-----------|-------|
| **Corridor** | 1×1 | 2 | Minimal |
| **Power Plant (self)** | 1×1 | 10 | Consumption of own power generation |
| **Barracks (S)** | 1×1 | 5 | Unit housing |
| **Barracks (L)** | 2×2 | 10 | Expanded housing |
| **Storage (S)** | 1×1 | 2 | Climate control |
| **Storage (M)** | 2×2 | 5 | Expanded storage |
| **Storage (L)** | 3×3 | 8 | Massive capacity |
| **Lab (S)** | 2×2 | 15 | Research equipment |
| **Lab (L)** | 3×3 | 30 | Advanced labs |
| **Workshop (S)** | 2×2 | 15 | Manufacturing |
| **Workshop (L)** | 3×3 | 30 | Advanced production |
| **Hospital** | 2×2 | 10 | Medical systems |
| **Academy** | 2×2 | 8 | Training systems |
| **Garage** | 2×2 | 12 | Craft repair tools |
| **Hangar (M)** | 2×2 | 15 | Bay systems |
| **Hangar (L)** | 3×3 | 30 | Large facility |
| **Radar (S)** | 2×2 | 8 | Detection systems |
| **Radar (L)** | 2×2 | 12 | Enhanced radar |
| **Turret (M)** | 2×2 | 15 | Weapon systems |
| **Turret (L)** | 3×3 | 35 | Advanced weapons |
| **Prison** | 3×3 | 12 | Cell systems, life support |
| **Temple** | 2×2 | 8 | Spiritual systems |

**Power Status Calculation**:
```
Available Power = Sum of all Power Plant outputs
Consumed Power = Sum of all operational facility costs
Shortage = max(0, Consumed - Available)
Surplus = max(0, Available - Consumed)
Utilization Ratio = Consumed / Available (0.0 to 1.0+)
Is Powered = (Shortage == 0)
```

**Priority Hierarchy (Shortage Resolution)**:

When power shortage occurs, facilities go offline in reverse priority order (lowest priority first):

| Priority | Level | Facilities | Purpose |
|----------|-------|-----------|---------|
| **100** | Critical | Power Plants (ALL) | Maintain generation capability |
| **90** | Essential | Headquarters | Command operations |
| **80** | Medical | Hospital, Temple | Unit recovery |
| **70** | Military | Barracks (all), Academy | Unit housing, training |
| **60** | Logistics | Hangar (all), Garage | Craft storage, repair |
| **50** | Production | Lab, Workshop (priority: Research > Manufacturing) | Knowledge/equipment creation |
| **40** | Storage | All Storage facilities | Item preservation |
| **30** | Defense | Radar, Turret | Detection, defense |
| **20** | Support | Corridor, extra Barracks | Connectivity |
| **10** | Low | Prison | Containment |

**Shortage Resolution Algorithm**:

```
Input: Available power, Consumed power, Facility list
Output: Online/Offline status for each facility

shortage = consumed - available
if shortage <= 0:
    return All facilities ONLINE

offline_list = {}
facilities_by_priority = SORT(facilities, priority DESC)

for facility in facilities_by_priority:
    if facility == PowerPlant:
        continue (always online)

    power_freed = facility.power_cost
    offline_list.add(facility)
    shortage -= power_freed

    if shortage <= 0:
        break

return Set offline_list to OFFLINE, rest ONLINE
```

**Manual Control**:
- Player can manually toggle facilities offline via UI
- Prevents facility operation even if power available
- Useful: reduce maintenance, emergency power conservation
- Remains offline until player re-enables

**Emergency Power-Down**:
- Command: Offline all non-critical facilities
- Keeps online: Power Plants, Headquarters, Hospital, Barracks (1 only)
- Use: Severe power crisis, maximize survival
- Automatic recovery when power available

**Damaged Facility Impact**:
- Damaged facilities: 50-90% efficiency (based on damage %)
- Damaged facility still consumes FULL power
- Result: Lower output/production, same power drain

**Power Notifications**:
- Shortage Alert: First power deficit detected
- Offline Alert: Facilities going offline (list shown)
- Critical Alert: Power now 0 (emergency conditions)
- Restoration Alert: Power shortage resolved

---

### C4: FACILITY DAMAGE & REPAIR

**Overview**: Facilities can be damaged during base defense missions, reducing efficiency and requiring repair.

**Damage Mechanics**:

**Damage Sources**:
- UFO attack during base defense mission
- Sabotage from enemy infiltration
- Friendly fire/accident during combat training
- Environmental hazard (theoretical future expansion)

**Facility Armor**:

| Facility | Armor Rating | Purpose |
|----------|-------------|---------|
| **Corridor** | 5 | Easily destroyed |
| **Barracks, Storage, Academy, Temple** | 10 | Standard construction |
| **Lab, Workshop, Hospital, Garage** | 15 | Reinforced, sensitive equipment |
| **Hangar, Prison** | 20 | Heavy construction |
| **Radar, Turret** | 25 | Military hardening |
| **Power Plant** | 30 | Critical infrastructure |

**Damage Formula**:
```
Damage Taken = Incoming Damage × (1 − Armor / (Armor + 10))
```

**Examples**:
- 20 incoming damage vs Corridor (5 armor): 20 × (1 − 5/15) = 20 × 0.67 = 13.4 → 13 damage
- 20 incoming damage vs Power Plant (30 armor): 20 × (1 − 30/40) = 20 × 0.25 = 5 damage

**Facility HP**:

| Facility | Max HP | Damage Threshold (for reduction) |
|----------|--------|----------------------------------|
| **1×1** | 50 | 25 damage = 50% health |
| **2×2** | 100 | 50 damage = 50% health |
| **3×3** | 150 | 75 damage = 50% health |

**Damage States**:

| State | HP Range | Production | Power Cost | Maintenance | Effect |
|-------|----------|-----------|-----------|------------|--------|
| **Healthy** | 100-76% | 100% | 100% | 100% | Normal operation |
| **Damaged** | 75-51% | 75% | 100% | 150% | Reduced output |
| **Heavily Damaged** | 50-26% | 50% | 100% | 200% | Severe impairment |
| **Critical** | 25-1% | 25% | 100% | 250% | Near-destroyed |
| **Destroyed** | 0% | 0% | 0% | 0% | Non-operational |

**Repair System**:

**Repair Method**: Facilities repair slowly over time during normal operations (passive healing).

**Repair Rate**:
```
Repair per Week = 10 HP per week (baseline) + Garage bonus
Garage Facility: +50 HP/week facility repair (stacked with building repairs)
```

**Repair Acceleration**:
- Repair technicians (units): +1 HP/week per technician assigned
- Maximum technicians: 3 per facility
- Maximum repair rate: 10 + 50 (Garage) + 3 (technicians) = 63 HP/week

**Repair Timeline Example**:
- 3×3 facility with 150 max HP, currently at 50 HP (100 HP damage)
- Baseline repair: 10 HP/week = 10 weeks
- With Garage: 10 + 50 = 60 HP/week = 1.67 weeks (≈ 12 days)
- With Garage + 3 technicians: 10 + 50 + 3 = 63 HP/week = 1.6 weeks (≈ 11 days)

**Destruction Management**:
- If facility reaches 0 HP during base defense, facility becomes destroyed
- Destroyed facility: Cannot function, requires rebuild
- Rebuild cost: 70-90% of original construction cost
- Rebuild time: 50% of original construction time

---

### R8: HANGAR STORAGE CAPACITY

**Overview**: Hangars determine craft storage capacity; insufficient hangars blocks craft acquisition.

**Hangar Types**:

| Hangar | Size | Capacity | Power | Maintenance | Cost | Purpose |
|--------|------|----------|-------|------------|------|---------|
| **Hangar M** | 2×2 | 4 craft | 15 power | 15K | 80K | Standard hangars |
| **Hangar L** | 3×3 | 8 craft | 30 power | 35K | 150K | Large complex |

**Craft Size Categories**:

| Craft Type | Size | Slots Used | Examples |
|-----------|------|-----------|----------|
| **Fighter** | Small | 1 slot | Interceptor, Scout |
| **Bomber** | Medium | 2 slots | Transport, Bomber |
| **Capital** | Large | 4 slots | Carrier, Mothership |

**Storage Calculation**:
```
Total Hangar Capacity = Sum of all hangar slots available
Current Craft Used = Sum of craft sizes
Available Capacity = Total - Current Used
Can Add Craft = (Craft Size <= Available Capacity)
```

**Examples**:
1. **1x Hangar M + 0x Hangar L**: 4 slots total
   - 4 fighters (4×1 = 4 slots): Full, cannot add more
   - 2 bombers (2×2 = 4 slots): Full, cannot add more
   - 1 capital (1×4 = 4 slots): Full, cannot add more

2. **2x Hangar M + 1x Hangar L**: 4 + 4 + 8 = 16 slots total
   - 2 capitals (8 slots) + 4 fighters (4 slots) = 12/16 used
   - Can add: 4 more fighters OR 1 more capital + 2 fighters OR 2 bombers, etc.

**Capacity Overflow**:
- Cannot exceed total hangar capacity (purchase blocked)
- Player notified: "Insufficient hangar space, upgrade required"
- Overflow craft: Cannot be deployed (stranded at base)

**Hangar Upgrade Path**:
- Hangar M → Hangar L: Upgrade in-place (+4 capacity, 14-30 day construction)
- Additional Hangars: Build new hangars in available grid slots
- Maximum hangars per base: Limited by base size (4×4 = ~3 max, 7×7 = ~8 max)

**Strategic Implications**: Hangar space gates craft acquisition, preventing early craft hoarding. Players must decide: focus on quality (few craft) vs. quantity (many craft).

---

### S1: STRENGTH TRAINING FACILITY

**Overview**: The Strength Training Facility provides specialized physical conditioning equipment and programs to increase unit Strength stat over time. This facility enables deliberate unit progression beyond natural growth, creating strategic decisions about physical development investment.

**Facility Specifications**:
- **Size**: 2×2 grid footprint
- **Build Cost**: 500K credits
- **Build Time**: 21 days
- **Power Consumption**: 12 power units
- **Maintenance Cost**: 100K credits per week
- **Capacity**: 1 unit per week maximum
- **Training Effect**: +1 Strength per trained unit per week

**Training Mechanics**:
- **Unit Selection**: Player assigns units to training queue (maximum 1 per week)
- **Training Duration**: 1 week per training session
- **Strength Increase**: +1 Strength stat per session (permanent increase)
- **Maximum Sessions**: No hard limit (units can train indefinitely)
- **Stat Cap**: Respects Strength stat maximum (18 for humans, varies by race)
- **Cost per Session**: Included in facility maintenance (no per-unit cost)

**Training Requirements**:
- **Unit Eligibility**: Any unit can train (no stat prerequisites)
- **Facility Status**: Must be operational (not damaged/offline)
- **Unit Availability**: Unit must be in base (not deployed on mission)
- **Queue Management**: First-in-first-out queue system

**Strategic Implications**:
- **Early Game**: Expensive investment for marginal benefit (500K build + 100K/week maintenance)
- **Mid Game**: Valuable for creating elite assault units (+1 STR enables better armor/weapons)
- **Late Game**: Essential for maxing out unit potential (multiple sessions needed for max STR)
- **Resource Trade-off**: High maintenance cost vs. permanent stat improvement
- **Unit Specialization**: Enables "tank" builds with maximum carry capacity and melee damage

**Training Queue Management**:
```
Training Queue = FIFO queue with 1 slot per week
Available Slots = min(1, Operational Facilities)
Training Cost = 0 per unit (covered by facility maintenance)
Completion Time = 7 days per training session
```

**Facility Integration**:
- **Adjacency Bonuses**: +10% training speed when adjacent to Hospital (+1.1 STR/week) or Academy (+10% XP gain during training)
- **Power Failure**: Training pauses during power shortages
- **Facility Damage**: Training efficiency reduced by damage percentage
- **Unit Recovery**: Units recover HP/Sanity normally during training (can stack with Hospital)

**Balance Considerations**:
- **Cost vs. Benefit**: 500K build + 100K/week vs. +1 STR permanent increase
- **Time Investment**: 1 week per point (slow progression encourages planning)
- **Capacity Limit**: 1 unit/week prevents spam training of entire army
- **Maintenance Burden**: High weekly cost creates meaningful economic decision

**Implementation Notes**:
- Training sessions are interruptible (unit can be deployed mid-training, progress lost)
- Strength increases are permanent (survive unit death/respawn)
- Multiple facilities allow parallel training (2 facilities = 2 units/week)
- No race restrictions (aliens can train, subject to their stat caps)

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

## Barracks Unit Management

**Overview**
Barracks facilities serve as the primary interface for unit management, providing access to demotion and respecialization mechanics. These functions allow players to adapt their squad composition to changing strategic needs, with appropriate costs and consequences.

**Demotion System**
- **Purpose**: Correct specialization mistakes or adapt to new tactical requirements
- **Requirements**: Unit must be in base (not deployed), barracks facility operational
- **Cost**: 10,000 credits per demotion
- **Time**: 3 days processing time
- **Effects**:
  - Unit rank decreases by 1 level (Sergeant → Corporal, etc.)
  - All stats decrease by 10% (permanent reduction)
  - XP resets to 0 (fresh start for new specialization)
  - Perks and specializations reset (unit becomes basic soldier)
  - Unit retains equipment but may need reassignment
- **Strategic Use**: Early-game correction of poor specialization choices, tactical adaptation

**Respecialization System**
- **Purpose**: Change unit specialization without rank penalty for strategic flexibility
- **Requirements**: Unit must be in base, barracks facility operational, unit rank ≥ Corporal
- **Cost**: 15,000 credits per respecialization
- **Time**: 1 week training time
- **Limits**: Maximum 2 respecializations per unit lifetime
- **Effects**:
  - Unit specialization changes to new type (Gunner/Medic/Sniper/Assault)
  - Unit rank and XP preserved (no demotion penalty)
  - Base stats adjusted according to new specialization
  - Perks reset and reassigned based on new specialization
  - Equipment automatically adjusted if incompatible
- **Strategic Use**: Mid-to-late game specialization changes, adapting to new threats or playstyles

**Barracks Interface Functions**

| Function | Requirements | Cost | Time | Effects |
|----------|-------------|------|------|---------|
| **Demote Unit** | Unit in base, barracks operational | 10K credits | 3 days | Rank -1, stats -10%, XP reset, perks reset |
| **Respecialize Unit** | Unit in base, rank ≥ Corporal, <2 lifetime uses | 15K credits | 1 week | Specialization change, rank/XP preserved, perks reset |
| **View Unit History** | Unit in base | 0 | Instant | Shows demotion/respec history, remaining uses |
| **Equipment Reassignment** | Unit in base | 0 | Instant | Transfer equipment between units in barracks |

**Unit Management UI Flow**
1. **Select Barracks**: Click on barracks facility to access unit management
2. **Select Unit**: Choose from list of units currently in base
3. **Choose Action**: Demote, Respecialize, or View History options
4. **Confirm Changes**: Review costs/consequences, confirm action
5. **Processing**: Unit unavailable during processing time
6. **Completion**: Unit returns with new specialization/stats

**Economic Impact**
- **Demotion Cost**: 10K credits (affordable early-game correction)
- **Respecialization Cost**: 15K credits (significant but worthwhile investment)
- **Time Cost**: 3 days (demotion) vs 1 week (respecialization) creates urgency decisions
- **Strategic Trade-off**: Demotion cheaper/faster but harsher penalties vs respecialization expensive/slower but preserves investment

**Balance Considerations**
- **Demotion Frequency**: No limits, but stat penalties accumulate with multiple uses
- **Respecialization Limits**: 2 lifetime uses prevents infinite specialization changes
- **Cost Scaling**: Credits required scale with campaign progression
- **Time Investment**: Processing times prevent spam changes during critical missions
- **Consequence Clarity**: Players understand permanent vs temporary changes

**Integration with Other Systems**
- **Academy Training**: Respecialized units can immediately enter training queues
- **Hospital Recovery**: Units unavailable during processing (cannot be healed/deployed)
- **Equipment System**: Automatic equipment reassignment prevents invalid loadouts
- **Mission Planning**: Processing times affect deployment availability

**Testing Scenarios**
- [ ] **Demotion Test**: Demote specialized unit, verify stat reduction and perk reset
- [ ] **Respecialization Test**: Change sniper to medic, verify preserved rank and new perks
- [ ] **Limit Test**: Attempt 3rd respecialization, verify rejection
- [ ] **Cost Test**: Verify credit deduction and time requirements
- [ ] **Integration Test**: Respecialized unit enters academy training immediately after completion

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
| **Layout Maintenance** | (Base Size)² × 10K | 160K-490K (4×4 to 7×7) |
| **Facility Maintenance** | Per facility × individual cost | 2-15K per facility |
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

## Power Management System

**Overview**
The Power Management System handles facility power distribution and shortage resolution. Power is a critical resource - insufficient power triggers an alert system where the game randomly oflines facilities to rebalance supply and demand. The player can manually enable/disable facilities to manage shortages strategically.

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

The power system returns the following status information:
- **Available**: Total power generated by all power plants
- **Consumed**: Total power consumed by all active facilities
- **Shortage**: Amount of power deficit (0 if surplus exists)
- **Ratio**: Percentage utilization of power (0.0-1.0+, >1.0 = shortage)
- **Powered**: Boolean flag indicating if base has sufficient power
- **Surplus**: Amount of excess power above consumption (0 if shortage)

**Power Shortage Alert System** (No Priority Tiers)

When power shortage occurs:

1. **Alert Notification**: Game displays "⚠️ Power shortage: Base needs X more power units"
   - Similar to Europa Universalis alert system (visible notification, not popup spam)
   - Player can read and dismiss alert

2. **Automatic Random Shutdown**: Game randomly selects facilities to offline
   - Which facilities go offline is **random** (not priority-based)
   - Enough facilities offline until power generation ≥ power consumption
   - Creates tension/unpredictability (player doesn't know which will die)

3. **Manual Player Control**: Player can toggle facilities on/off manually
   - Enable/disable specific facilities manually
   - Facility remains offline until manually re-enabled or power crisis resolves
   - Strategic decision: Which facilities can afford to be offline?

**Shortage Resolution Examples**

**Example 1: Minor Shortage**

Base Power State:
- Power Plants generating: 100 units
- Laboratories consuming: 40 units
- Manufacturing consuming: 35 units
- Barracks consuming: 15 units
- Hospital consuming: 20 units
- Total consumption: 110 units (10 unit shortage!)

System Action:
1. Display alert: "⚠️ Power shortage: Base needs 10 more power units"
2. Randomly offline 1-2 facilities (could be Lab, Manufacturing, Hospital, or Barracks)
3. Assume Manufacturing (35 power) goes offline
4. New balance: 100 generated, 75 consumed = 25 surplus

Player Options:
- Option A: Manually re-enable Manufacturing (force shortage again until resolved)
- Option B: Build Power Plant expansion (long-term fix)
- Option C: Disable multiple low-priority facilities manually
- Option D: Wait for alert to clear if production isn't urgent

**Example 2: Severe Shortage**

Base Power State:
- Power Plants generating: 80 units
- Multiple facilities consuming: 150 total units (70 unit shortage!)

System Action:
1. Display alert: "⚠️ CRITICAL: Base power shortage of 70 units!"
2. Randomly offline facilities until balanced
3. Assume: Lab, Workshop, Academy, Hospital all go offline (80 power freed)
4. New balance: 80 generated, 70 consumed = 10 surplus

Strategic Impact:
- Research halts (Lab offline)
- Manufacturing halts (Workshop offline)
- Unit training halts (Academy offline)
- No healing available (Hospital offline)
- Base operations severely hampered
- Player must act quickly to restore power or rebuild critically

**Manual Facility Control** (Player Strategy)

**Toggling Facilities**:
- `toggleFacilityPower(base, x, y)` - Player can manually disable facility
- Returns: `{bool success, string message}`
- Facility remains offline until player re-enables or power shortage auto-resolves

**Strategic Reasons to Disable Facilities**:
1. **Reduce Consumption**: Disable non-critical facilities during shortage
2. **Maintenance**: Offline facility during repair to reduce power drain
3. **Cost Optimization**: Temporarily disable expensive facilities during low-income periods
4. **Priority Shift**: Disable manufacturing to preserve research during crisis
5. **Experimentation**: Test which facilities are truly necessary for current campaign

**Emergency Power-Down** (Optional Feature)
- `emergencyPowerdown(base)` - Offline all non-critical systems
- Approach: Offline all except Power Plants and Headquarters
- Use case: Severe crisis during multiple facility outages
- Recovery: Manual re-enable facilities once crisis passes

**Power Management Design Philosophy**

**No Priority Tiers**:
- Original system had 10-tier priority (wrong approach)
- New system: Random facility shutdown creates tension and uncertainty
- Encourages player strategic planning (build more power capacity)
- Forces meaningful decisions (which facilities matter most?)

**Player Agency**:
- Alerts inform player of problems (like EU4 notifications)
- Player chooses which facilities to disable/preserve
- Experimentation encouraged (toggle facilities to see what breaks)
- Failure meaningful (bad decisions have consequences)

**Strategic Tension**:
- Shortage creates economic pressure (upgrade power plants?)
- Random shutdown feels organic (not rigid tier system)
- Player learns base balance over time (what's sustainable?)
- Late game: Upgraded power plants prevent shortages entirely

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

## Examples

### Scenario 1: Base Expansion Decision
**Setup**: Player has Small base (4×4), 150K credits saved, researched Medium base tech
**Action**: Choose to expand to Medium base
**Result**: Base transforms to 5×5 grid, 25 tiles available, gains 7-8 new facility slots

### Scenario 2: Power Shortage Crisis
**Setup**: Base has 50 power available, 120 power needed
**Action**: Power management system activates priority shutdown
**Result**: Labs and Workshops go offline, hospitals and barracks remain operational

### Scenario 3: Adjacency Bonus Planning
**Setup**: Player placing new Lab near existing Workshop
**Action**: Position Lab adjacent to Workshop
**Result**: Both facilities gain +10% efficiency, research/manufacturing speed increases

## Balance Parameters

| Parameter | Value | Range | Reasoning | Difficulty Scaling |
|-----------|-------|-------|-----------|-------------------|
| Base Construction Cost | 150-600K | 100-1000K | Capital gate | ±50K on difficulty |
| Monthly Maintenance | 80-2000K | 50-3000K | Economic pressure | ±20% on difficulty |
| Facility Power Consumption | 2-35 power | 1-50 | Resource balance | ±5 on Hard |
| Adjacency Bonus | +10% | ±5% | Production synergy | ±2% on difficulty |
| Unit Salary | 5K/month | 3-10K | Personnel cost | ±2K on difficulty |

## Difficulty Scaling

### Easy Mode
- Lower facility costs (-30%)
- Reduced maintenance (-40%)
- Higher adjacency bonuses (+15%)
- Better power plant efficiency (+20%)
- Faster construction times (-25%)

### Normal Mode
- Standard costs and maintenance
- Balanced facility economics
- Normal adjacency bonuses
- Standard build times

### Hard Mode
- Higher facility costs (+30%)
- Increased maintenance (+40%)
- Reduced adjacency bonuses (-5%)
- Lower power plant efficiency (-10%)
- Slower construction times (+25%)

### Impossible Mode
- Maximum facility costs (+50%)
- Severe maintenance penalties (+60%)
- Minimal adjacency bonuses (-10%)
- Poor power efficiency (-20%)
- Maximum construction times (+50%)

## Testing Scenarios

- [ ] **Base Construction Test**: Build new Small base
  - **Setup**: Player at base with 200K credits
  - **Action**: Initiate base construction in new province
  - **Expected**: Base appears in 30 days at Small size, costs 150K
  - **Verify**: Base properties (grid, capacity, costs) match specification

- [ ] **Expansion Test**: Expand from Small to Medium
  - **Setup**: Small base with available expansion research
  - **Action**: Queue expansion with 250K credits
  - **Expected**: Base expands to Medium (5×5) in 45 days, facilities preserved
  - **Verify**: New facilities added, total capacity increases

- [ ] **Power Management Test**: Trigger power shortage
  - **Setup**: Base with 50 available power, 120 needed
  - **Action**: Allow power deficit detection
  - **Expected**: Lower-priority facilities offline automatically
  - **Verify**: Labs/Workshops offline, hospitals/barracks remain operational

- [ ] **Adjacency Bonus Test**: Place adjacent facilities
  - **Setup**: Lab and Workshop in separate base clusters
  - **Action**: Position Lab adjacent to Workshop
  - **Expected**: Both facilities gain +10% bonus
  - **Verify**: Efficiency calculations show 10% increase

- [ ] **Unit Recruitment Test**: Recruit soldiers into barracks
  - **Setup**: Barracks with 20 capacity, 5 units present
  - **Action**: Recruit 10 new soldiers
  - **Expected**: 15 units total, monthly salary increases to 75K
  - **Verify**: Recruitment queue updates, costs calculated correctly

- [ ] **Facility Damage Test**: Base suffers UFO attack damage
  - **Setup**: Base with operational facilities, UFO attack
  - **Action**: Attack damages random facilities
  - **Expected**: Facilities show damage (50-80% severity)
  - **Verify**: Repair queue created, production reduced

## Related Features

- **[Geoscape System]**: Mission generation and resource collection (Geoscape.md)
- **[Economy System]**: Base funding and resource management (Economy.md)
- **[Units System]**: Personnel recruitment and management (Units.md)
- **[Crafts System]**: Vehicle storage and deployment (Crafts.md)
- **[Items System]**: Equipment and resource storage (Items.md)
- **[Battlescape System]**: Combat context driving salvage production (Battlescape.md)

## Implementation Notes

- Square grid (40×60) for facility placement
- Four-directional adjacency for bonus calculation
- Power priority system with 10 tiers
- Monthly reconciliation for economic reporting
- Multiplicative efficiency bonuses (not additive)
- Integration with all other game systems

## Review Checklist

- [ ] Base construction mechanics fully specified
- [ ] Facility grid system defined
- [ ] Power management system documented
- [ ] Adjacency bonus system balanced
- [ ] Unit recruitment requirements clear
- [ ] Equipment/craft management specified
- [ ] Maintenance economics calculated
- [ ] Defense and repair mechanics complete
- [ ] Radar coverage mechanics defined
- [ ] Monthly reporting system designed
- [ ] All difficulty scaling parameters set
- [ ] Integration points documented
- [ ] Testing scenarios comprehensive
- [ ] Related features properly linked
