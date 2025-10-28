# Basescape API Reference

**System:** Strategic Layer (Base Management & Operations)
**Module:** `engine/basescape/`
**Latest Update:** October 22, 2025
**Status:** ✅ Complete

---

## Overview

The Basescape system manages player base construction, facility placement, grid layout, capacity management, personnel administration, and resource logistics. It's a 2D grid-based system similar to Civilization city management for strategic operational control. Bases are operational hubs located in provinces where players construct facilities to research technology, manufacture equipment, recruit units, and store resources.

**Key Responsibilities:**
- Base configuration and facility management
- Grid-based facility placement with adjacency bonuses
- Personnel administration and morale tracking
- Manufacturing and research queue management
- Storage management and logistics
- Base upgrades and expansions
- Power generation and distribution
- Economic management and resource allocation

**Integration Points:**
- Geoscape: Province location, territorial control
- Economy: Resource storage, credit availability, maintenance costs
- Personnel: Unit recruitment, assignment, specialization
- Research: Facility unlocks, technology requirements
- Analytics: Base statistics, performance tracking

---

## Implementation Status

### ✅ Implemented (in engine/basescape/)
- Base manager with grid system (`base_manager.lua`)
- Facility system with 5×5 grid (`facilities/facility_system.lua`)
- Construction queue and progress tracking
- Personnel assignment and management
- Storage capacity tracking
- Power generation and consumption
- Manufacturing and research queues

### 🚧 Partially Implemented
- Adjacency bonus calculations (documented in FACILITIES.md)
- Base defense during attacks
- Advanced facility upgrades
- Multi-level bases

### 📋 Planned (in design/)
- Dynamic base expansion beyond initial grid
- Underground levels
- Base interconnection system
- Advanced automation systems

---

## Architecture

### System Components

1. **Base Manager** - Handles base initialization and configuration
2. **Facility Manager** - Manages facility operations and specialization
3. **Personnel Manager** - Handles unit assignment and morale
4. **Power System** - Manages power generation and distribution
5. **Grid System** - Manages facility placement and adjacency
6. **Queue Manager** - Manages manufacturing and research queues
7. **Storage Manager** - Tracks inventory limits and usage
8. **Expansion Engine** - Handles base upgrades and improvements

### Data Flow Diagram

```
┌──────────────────────────────────────────────────────────┐
│           BASESCAPE SYSTEM ARCHITECTURE                  │
├──────────────────────────────────────────────────────────┤
│                                                            │
│  Base Templates ──┐                                        │
│  Layout Data ─────├──> Base Loader ──> Basescape Display  │
│  Facilities ──────┤                                        │
│                   └──> Facility Manager ──> Operations     │
│                                                            │
│  Personnel Pool ─> Personnel Mgr ──> Assignment System    │
│  Morale Factors ─> Morale Calc ──> Efficiency Mods        │
│  Experience ────> Specialization ──> Bonus Application    │
│                                                            │
│  Manufacturing Queue -> Production Mgr ──> Status Display │
│  Research Queue ────-> Research Mgr ──> Progress Track    │
│  Storage Limits ────-> Inventory Mgr ──> Space Calc       │
│                                                            │
│  Budget Tracking -> Finance Mgr ──> Economic Status       │
│  Power System ───> Distribution Mgr ──> Connection Check  │
│  Upgrades Queue ──> Expansion Engine ──> Growth Calc      │
│                                                            │
└──────────────────────────────────────────────────────────┘
```

---

## Core Entities

### Entity: Base

Main container for base infrastructure, personnel, and inventory. Represents an operational hub.

**Properties:**
```lua
Base = {
  id = string,                    -- "base_001", "main_base"
  name = string,                  -- "North American HQ"
  province_id = string,           -- Location province

  -- Base Layout
  size = string,                  -- "small", "medium", "large", "huge"
  grid_width = number,            -- 4-7 (size-dependent)
  grid_height = number,           -- 4-7 (size-dependent)
  total_tiles = number,           -- grid_width × grid_height

  -- Facilities
  facilities = Facility[],        -- All facilities in base
  facility_grid = Facility[][],   -- 2D grid representation

  -- Personnel & Units
  assigned_units = Unit[],        -- Units at base
  max_units = number,             -- Personnel capacity
  garrison_units = Unit[],        -- Defensive units
  morale = number,                -- 0-100, average personnel morale

  -- Resources
  storage_capacity = number,      -- Max items/resources (units)
  stored_items = ItemStack[],     -- Inventory
  inventory = ResourcePool,       -- Storage by resource type

  -- Operations
  status = string,                -- "operational", "damaged", "under_construction"
  production_queue = ProductionJob[],
  construction_queue = ConstructionOrder[],

  -- Power System
  power_generated = number,       -- Generated power
  power_required = number,        -- Consumed power
  power_current = number,         -- Net available power

  -- Economics
  monthly_cost = number,          -- Facility maintenance
  monthly_income = number,        -- From storages/trade
  credits = number,               -- Current cash on hand

  -- Defense
  defense_level = number,         -- 0-100
  radar_coverage = number,        -- Detection range (hexes)

  -- History
  founded_turn = number,
  construction_turn = number,
}
```

**Functions:**
```lua
-- Creation
Base.createBase(name: string, province: Province, size: string) → Base
Base.getBase(base_id: string) → Base | nil
Base.getBasesByProvince(province: Province) → Base[]
BaseSystem.createBase(name: string, province: Province, size: string) → Base, error
BaseSystem.getBase(id: string) → Base | nil
BaseSystem.getAllBases() → Base[]

-- Base info
base:getName() → string
base:getProvince() → Province
base:getSize() → string
base:getGridSize() → (width: number, height: number)
base:getGridWidth() → number
base:getGridHeight() → number
base:getStatus() → string

-- Expansion
base:canExpand(target_size: string) → (bool, reason: string)
base:expand(target_size: string) → number (turns until complete)
base:getCurrentSize() → string
base:expandBase(newSize: string) → (bool, error)

-- Facilities
base:addFacility(facility: Facility, x: number, y: number) → boolean
base:removeFacility(facility_id: string) → void
base:placeFacility(x: number, y: number, facility: Facility) → (Facility, error)
base:getFacilities() → Facility[]
base:getFacilitiesByType(type: string) → Facility[]
base:getGridTile(x: number, y: number) → Facility | nil
base:setGridTile(x: number, y: number, facility: Facility) → boolean
base:getFacilitiesAt(x: number, y: number) → Facility | nil
base:getConnectedFacilities(facility: Facility) → Facility[]

-- Capacity management
base:getTotalCapacity(type: string) → number
base:getUsedCapacity(type: string) → number
base:getAvailableCapacity(type: string) → number
base:canAddCapacity(type: string, amount: number) → bool

-- Personnel
base:addUnit(unit: Unit) → boolean
base:removeUnit(unit_id: string) → void
base:getAssignedUnits() → Unit[]
base:getUnits() → Unit[]
base:getUnitCount() → number
base:getUnitCapacity() → number
base:canAddUnit(unit: Unit) → bool
base:getMorale() → number
base:setMorale(level: number) → void

-- Garrison
base:assignGarrison(units: Unit[]) → void
base:getGarrison() → Unit[]
base:getGarrisonStrength() → number (0-100)

-- Inventory
base:addResources(resourceId: string, amount: number) → bool
base:removeResources(resourceId: string, amount: number) → bool
base:getInventory() → ResourcePool
base:getStorageUsage() → number (kg used)
base:getStorageCapacity() → number (max kg)
base:addItem(item: ItemStack) → boolean
base:removeItem(item_id: string, quantity: number) → number (actually removed)

-- Power management
base:getPowerGenerated() → number
base:getPowerRequired() → number
base:getPowerSurplus() → number
base:hasSufficientPower() → bool
base:addPowerGenerator(amount: number) → void
base:addPowerConsumer(amount: number) → void
base:calculatePowerNeeds() → number
base:calculatePowerAvailable() → number
base:updatePowerDistribution() → void

-- Defense
base:calculateDefense() → number
base:getDefensePower() → number
base:getMonthlyUpkeep() → number

-- Status
base:isOperational() → boolean
base:getMaintenance Cost() → number
base:updateStatus() → table
base:getEfficiencyModifier() → number (0.5-1.5)
```

---

### Entity: Facility

Individual base structure with specialized function and adjacency bonuses.

**Properties:**
```lua
Facility = {
  id = string,                    -- "facility_001"
  type = string,                  -- "power", "storage", "barracks", "lab", "workshop"
  name = string,                  -- Display name
  base_id = string,               -- Parent base

  -- Grid Placement
  grid_x = number,                -- X coordinate
  grid_y = number,                -- Y coordinate
  width = number,                 -- 1, 2, or 3 tiles
  height = number,                -- 1, 2, or 3 tiles
  hex_q = number,                 -- Hex Q coordinate (alt system)
  hex_r = number,                 -- Hex R coordinate (alt system)

  -- Status
  status = string,                -- "operational", "damaged", "under_construction"
  hp = number,                    -- Current health
  max_hp = number,                -- Full health
  is_powered = boolean,           -- Currently receiving power

  -- Function
  functions = string[],           -- Primary functions

  -- Power & Resources
  power_consumption = number,     -- Energy per turn
  power_provided = number,        -- Generated power (if generator)
  power_balance = number,         -- Net power

  -- Production/Effect
  production_rate = number,       -- Items/points per turn
  capacity = number,              -- Storage, personnel, or research slots

  -- Adjacency Bonuses
  adjacency_bonus = number,       -- Bonus from nearby facilities (%)
  adjacency_multiplier = number,  -- Applied multiplier
  required_adjacency = string,    -- Specific adjacent facility type
  adjacent_facilities = Facility[], -- 6 neighbors

  -- Upgrades
  upgrade_level = number,         -- 0-3 (improved versions)
  is_upgraded = boolean,

  -- Construction
  construction_progress = number, -- 0-100
  construction_turns_remaining = number,

  -- Specialization
  specialization = string,        -- "weapons", "armor", "medkits", etc.
  specialization_bonus = number,  -- +X% efficiency
}
```

**Functions:**
```lua
-- Creation
Facility.createFacility(type: string, name: string) → Facility
FacilitySystem.createFacility(type: string) → Facility
FacilitySystem.getFacility(id: string) → Facility | nil
FacilitySystem.getFacilitiesByType(base: Base, type: string) → Facility[]

-- Grid
facility:getType() → string
facility:getName() → string
facility:getGridPosition() → (x: number, y: number)
facility:getGridFootprint() → (width: number, height: number)
facility:getPosition() → {q, r}
facility:isConnected(base: Base) → boolean (to power/core)

-- Status
facility:getStatus() → string
facility:setStatus(status: string) → void
facility:isOperational() → bool
facility:isUnderConstruction() → bool
facility:isDamaged() → bool
facility:needsRepair() → bool

-- Construction
facility:startConstruction() → bool
facility:advanceConstruction() → void
facility:getConstructionProgress() → number (0-100)
facility:getTurnsToCompletion() → number

-- Health
facility:getHP() → number
facility:getMaxHP() → number
facility:takeDamage(amount: number) → void
facility:repairDamage(amount: number) → void

-- Power
facility:getPowerStatus() → (is_powered: boolean, power_available: number)
facility:getPowerProvided() → number
facility:getPowerRequired() → number
facility:getPowerBalance() → number
facility:isPowered() → bool

-- Adjacency bonuses
facility:getAdjacentFacilities() → Facility[]
facility:calculateAdjacencyBonuses() → table
facility:getAdjacencyBonus() → number (%)
facility:getAdjacencyMultiplier() → number
facility:updateAdjacency() → void

-- Capacity
facility:getCapacity() → number
facility:getCapacity(type: string) → number
facility:getUsedCapacity(type: string) → number
facility:getAvailableCapacity(type: string) → number
facility:getProductionRate() → number

-- Upgrades
facility:canUpgrade() → boolean
facility:upgrade() → void
facility:getUpgradeLevel() → number
facility:upgradeFacility() → void
```

---

### Entity: ProductionJob

Manufacturing or research task queued at facility.

**Properties:**
```lua
ProductionJob = {
  id = string,                    -- "job_001"
  type = string,                  -- "manufacturing" | "research"

  -- Target
  target_item = string,           -- Item type to produce
  target_tech = string,           -- Tech to research
  quantity = number,              -- How many to produce

  -- Progress
  progress_percent = number,      -- 0-100
  turns_remaining = number,       -- Estimated completion
  is_complete = boolean,

  -- Priority
  priority = number,              -- 1-10 (affects queue order)

  -- Costs
  cost_credits = number,          -- Total credit cost
  cost_resources = table,         -- {resource_id: amount}
}
```

**Functions:**
```lua
ProductionQueue.addJob(base: Base, job: ProductionJob) → void
ProductionQueue.removeJob(base: Base, job_id: string) → void
ProductionQueue.getQueue(base: Base) → ProductionJob[]
ProductionQueue.setPriority(job: ProductionJob, new_priority: number) → void
ProductionQueue.processProduction(facility: Facility, delta_turns: number) → void
ProductionQueue.completeJob(base: Base, job: ProductionJob) → ItemStack[] (results)
ProductionQueue.estimateCompletion(job: ProductionJob) → number (turns)
ProductionQueue.getActiveJob(facility: Facility) → ProductionJob | nil
ProductionQueue.getQueuedJobs(base: Base) → ProductionJob[]
```

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



## Facility Grid System

**Overview**
Base facilities exist on a **square grid**, creating a two-dimensional strategic layout. The square grid creates a simple, predictable topology where each facility touches up to 4 neighbors (cardinal directions), enabling straightforward placement strategies and predictable spatial planning.

**Grid Architecture**
- **Grid Type**: Orthogonal Square (x-axis horizontal, y-axis vertical)
- **Rendering Viewport**: 40 tiles wide × 60 tiles tall (camera view for rendering)
- **Playable Base Grids**: 4×4 to 7×7 (actual facility placement space)
- **Neighbor Topology**: Each facility connects to 4 adjacent squares (North, South, East, West) or 8 including diagonals (N, NE, E, SE, S, SW, W, NW)
- **Layout Pattern**: Creates rectangular base perimeter with predictable geometry
- **Coordinate System**: (X, Y) where X=0-39 (horizontal), Y=0-59 (vertical) for rendering viewport; facility grid uses local coordinates within base size
- **Rotation**: Facilities are **not rotatable** (fixed orientation on grid)
- **Visual Clarity**: Square grid prevents ambiguous positioning; all placement clear and unambiguous

**Grid Scale Reference**
- **Playable Base Dimensions by Size** (actual facility grid):
  - Small (4×4): 16 tiles total
  - Medium (5×5): 25 tiles total
  - Large (6×6): 36 tiles total
  - Huge (7×7): 49 tiles total
- **Rendering Context**: All bases rendered within 40×60 tile viewport
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

## Base Size System

### Size Progression

| Size | Grid | Tiles | Cost | Time | Capacity | Strategic Use |
|------|------|-------|------|------|----------|---------------|
| Small | 4×4 | 16 | 150K | 30 days | 8-10 | Forward bases |
| Medium | 5×5 | 25 | 250K | 45 days | 15-18 | Standard ops |
| Large | 6×6 | 36 | 400K | 60 days | 24-28 | Hubs |
| Huge | 7×7 | 49 | 600K | 90 days | 35-40 | Strongholds |

### Expansion System

**Overview**
The Basescape Expansion System provides complete lifecycle management for base upgrades. Bases can expand sequentially through size progression (Small → Medium → Large → Huge), preserving all existing facilities while adding new slots.

**Expansion Implementation** (`engine/basescape/systems/expansion_system.lua`)

**Key Functions:**
```lua
-- Get current base size designation
getCurrentSize(base) → string ("small", "medium", "large", "huge")

-- Verify expansion prerequisites and return success/error
canExpand(base, targetSize, gameState) → (success: bool, reason: string)

-- Execute expansion, preserve facilities, add new slots
expandBase(base, targetSize, callback) → void

-- Full validation against all requirements
validateExpansionPrerequisites(base, targetSize, gameState) → (valid: bool, errors: string[])

-- Get expansion status: current size, target size, remaining time, cost
getExpansionInfo(base) → {
  current_size: string,
  target_size: string | nil,
  remaining_time: number,
  cost: number,
  is_expanding: bool
}
```

**Expansion Costs & Time:**
- **Small (4×4)**: Starting size, no expansion needed
- **Medium (5×5)**: 250K cost, 45 days build time
- **Large (6×6)**: 400K cost, 60 days build time
- **Huge (7×7)**: 600K cost, 90 days build time

**Expansion Prerequisites:**
Each size requires specific gates to prevent early dominance:
- **Technology**: Facilities available for size level (gate by research)
- **Relations**: Must maintain positive relations with country
- **Economy**: Credits available for expansion cost
- **Current Size**: Must follow sequential progression (cannot skip sizes)
- **Facility Preservation**: All existing facilities preserved and remain operational after expansion

**Strategic Implications:**
- Expansion provides new facility slots without requiring relocation
- Costs and times scale to prevent rapid expansion across multiple bases simultaneously
- Expansion blocks base from deployment during construction phase
- Relation gates on Large/Huge ensure diplomatic cost to expansion
- Sequential progression creates meaningful long-term planning requirement

**Facility Preservation During Expansion:**
When expanding, all existing facilities maintain their:
- Position and function
- Upgrade levels
- Personnel assignments
- Production queues
- Power connections
- Storage contents
New grid space becomes available adjacent to existing layout

### Construction Gate Mechanics

Base construction and size are gated by multiple factors, preventing early continental dominance:

| Factor | Impact | Requirement |
|--------|--------|------------|
| **Technology** | Determines facility types available | Base Tech, Grid Foundation |
| **Country Relations** | Allows base in territory | +0 minimum relations |
| **Biome** | Affects build cost, build time, terrain | Biome-appropriate structures |
| **Organization Level** | Gates base count | Level 1: 1 base, Level 5: 5 bases, Level 10: 10 bases |
| **Province Ownership** | Cannot build in enemy-controlled territory | Must have established control |
| **Relation Bonus** | Large/Huge bases require allied status | Relation >50 for Large, >75 for Huge |

### Construction Penalties by Biome

| Biome | Penalty | Reasoning |
|-------|---------|-----------|
| Ocean | +250% | Engineering difficulty |
| Mountain | +40% | Terrain challenges |
| Arctic | +35% | Extreme conditions |
| Urban | +25% | Infrastructure integration |
| Desert | +20% | Supply logistics |
| Forest/Grassland | Baseline | No penalty |

**Build Time Factors:**
```
Actual Build Time = Base Time × (1 + Biome Penalty) × (1 - Engineer Bonus) × (1 - Tech Bonus)
Engineer Bonus: Chief Engineer advisor provides -15% time reduction
Tech Bonus: Advanced construction research provides -10% to -20% time reduction
```

**Relocation Mechanics:**
- Bases cannot be moved (destroy and rebuild only)
- Destroying base: Instant destruction, 0% refund on construction costs
- Rebuilding: Full cost and time required; region left vulnerable during rebuild
- Strategic implication: Base placement is permanent decision

---

## Facility Types

### Core Facilities

**Power Plant**
- Provides electrical power to other facilities
- Consumption: 0 | Output: 100+ (varies by type)
- Size: 2×2
- Adjacency: +5% efficiency per neighboring power plant

**Barracks**
- Recruits and houses combat units
- Personnel capacity: 20+
- Size: 2×2
- Adjacency: +2 morale nearby units

**Research Laboratory**
- Conducts technological research
- Research capacity: 3+ projects
- Size: 2×2
- Adjacency: +10% research speed per adjacent lab

**Manufacturing Workshop**
- Manufactures equipment and weapons
- Manufacturing capacity: 2+ queue slots
- Size: 2×2
- Adjacency: +15% production speed

**Storage Facility**
- Stores equipment and resources
- Storage capacity: 5000 units
- Size: 2×2
- Adjacency: +20% storage capacity

**Hangar**
- Aircraft storage and maintenance
- Craft capacity: 5+
- Size: 3×3
- Adjacency: Reduces maintenance costs

---

## TOML Configuration

### Base Sizes

```toml
[[base_sizes]]
id = "small"
name = "Small Outpost"
grid_width = 4
grid_height = 4
construction_cost = 150000
construction_time = 30
max_facilities = 8
storage_capacity = 5000
defense_level = 20

[[base_sizes]]
id = "medium"
name = "Standard Base"
grid_width = 5
grid_height = 5
construction_cost = 250000
construction_time = 45
max_facilities = 15
storage_capacity = 10000
defense_level = 40

[[base_sizes]]
id = "large"
name = "Regional Hub"
grid_width = 6
grid_height = 6
construction_cost = 400000
construction_time = 60
max_facilities = 24
storage_capacity = 20000
defense_level = 60

[[base_sizes]]
id = "huge"
name = "Strategic Stronghold"
grid_width = 7
grid_height = 7
construction_cost = 600000
construction_time = 90
max_facilities = 35
storage_capacity = 35000
defense_level = 80
```

### Facility Types

```toml
[[facility_types]]
id = "power_plant"
name = "Power Plant"
type = "power"
width = 2
height = 2
build_cost = 50000
build_time = 20
power_output = 50
power_consumption = 5
required_research = "base_construction"

[[facility_types]]
id = "barracks"
name = "Barracks"
type = "personnel"
width = 2
height = 2
build_cost = 30000
build_time = 15
power_consumption = 10
capacity = 20
required_research = "base_construction"

[[facility_types]]
id = "workshop"
name = "Workshop"
type = "manufacturing"
width = 2
height = 2
build_cost = 40000
build_time = 25
power_consumption = 15
production_rate = 1
required_research = "manufacturing"
required_adjacency = "power_plant"
adjacency_bonus = 0.10  # +10% with adjacent research lab

[[facility_types]]
id = "research_lab"
name = "Research Laboratory"
type = "research"
width = 2
height = 2
build_cost = 60000
build_time = 30
power_consumption = 20
production_rate = 1
required_research = "research_division"
required_adjacency = "power_plant"

[[facility_types]]
id = "storage"
name = "Storage Facility"
type = "storage"
width = 2
height = 2
build_cost = 25000
build_time = 15
power_consumption = 5
capacity = 5000
required_research = "base_construction"

[[facility_types]]
id = "hangar"
name = "Hangar"
type = "hangar"
width = 3
height = 3
build_cost = 150000
build_time = 40
power_consumption = 30
craft_capacity = 5
storage_capacity = 10000
```

---

## Working Examples

### Example 1: Create Base and Place Facilities

```lua
-- Create base
local base = BaseSystem.createBase("North American HQ", north_america_province, "medium")
print("Base created: " .. base:getName())

-- Create power plant
local power = FacilitySystem.createFacility("power_plant")
base:placeFacility(1, 1, power)
print("Power plant added at (1,1)")

-- Create workshop adjacent to power
local workshop = FacilitySystem.createFacility("workshop")
base:placeFacility(3, 1, workshop)
print("Workshop connected")

-- Check power
print("Power: " .. base:getPowerGenerated() .. "/" .. base:getPowerRequired())
```

### Example 2: Queue Production

```lua
local job = ProductionJob.new()
job.type = "manufacturing"
job.target_item = "rifle"
job.quantity = 50
job.priority = 5

ProductionQueue.addJob(base, job)
local turns = ProductionQueue.estimateCompletion(job)
print("Production job queued, ETA: " .. turns .. " turns")
```

### Example 3: Manage Personnel

```lua
-- Assign units to barracks
local units = Player.getAvailableUnits()

for i = 1, math.min(10, #units) do
  if base:addUnit(units[i]) then
    print("Assigned " .. units[i]:getName())
  end
end

print("Base morale: " .. base:getMorale() .. "/100")
```

### Example 4: Handle Expansion

```lua
if base:canExpand("large") then
  local turns = base:expand("large")
  print("Expanding to large base, " .. turns .. " turns")
else
  print("Cannot expand - check prerequisites")
end
```

---

## Integration Points

**Inputs from:**
- Geoscape: Province location, territory control
- Economy: Resource storage, credit availability
- Personnel: Unit recruitment, specialization
- Research: Facility unlocks, technology requirements

**Outputs to:**
- Economy: Production output, maintenance costs
- Personnel: Unit training capacity, recruitment
- Inventory: Equipment storage
- Geoscape: Base presence, territorial control

---

## Error Handling

```lua
-- Facility placement
if not base:addFacility(facility, x, y) then
  print("Cannot place - space occupied or out of bounds")
end

-- Power deficiency
if base:getPowerSurplus() < 0 then
  print("Power deficit - add power plants")
end

-- Storage full
if base:getStorageUsage() >= base:getStorageCapacity() then
  print("Storage full")
end

-- Expansion prerequisites
local can_expand, reason = base:canExpand("large")
if not can_expand then
  print("Cannot expand: " .. reason)
end

-- Personnel capacity
if not base:addUnit(unit) then
  print("Base at capacity")
end
```

---

## Inter-Base Transfer System

Complex logistics connect multiple bases, enabling resource redistribution, personnel transfers, craft relocation, and supply line management across distributed operational bases.

### Entity: TransferRoute

**Properties:**
```lua
TransferRoute = {
  id = "route_001_alpha_to_beta",
  name = "Alpha → Beta Supply Route",

  -- Endpoints
  origin_base_id = "base_alpha",
  destination_base_id = "base_beta",
  distance_km = 3500,
  travel_time_hours = 24,

  -- Logistics
  cargo_capacity = 5000,                      -- Units of cargo
  transport_craft_id = "transport_001",       -- Assigned transport
  condition = 0.9,                            -- Route integrity (0-1)

  -- Route Status
  is_active = true,
  is_sabotaged = false,
  is_intercepted = false,
  security_level = 2,                         -- 1-5, higher = more secure

  -- Scheduling
  schedule_type = "regular",                  -- regular, emergency, scheduled
  dispatch_frequency_days = 7,                -- Regular interval
  last_dispatch = calendar.getCurrentDate(),
  next_dispatch = calendar.addDays(calendar.getCurrentDate(), 7),

  -- Resources In Transit
  current_cargo = {                           -- Cargo on this route
    credits = 0,
    supplies = 500,
    alloy = 250,
    weapons = 50
  },

  -- History
  total_transfers = 42,
  successful_transfers = 40,
  failed_transfers = 2,
  interception_attempts = 3
}
```

### Transfer Planning & Logistics

**Route Calculation:**
```lua
function findOptimalTransferRoute(origin_base, destination_base, available_crafts)
  -- Find shortest path with available transport
  local distance = calculateDistance(
    origin_base.location,
    destination_base.location
  )

  -- Evaluate each transport craft
  local route_options = {}
  for _, craft in ipairs(available_crafts) do
    if craft.can_carry_cargo and craft.status == "ready" then
      local travel_time = calculateTravelTime(distance, craft.speed_cruise)
      local fuel_needed = calculateFuelNeeded(distance, craft.fuel_consumption_cruise)

      if fuel_needed <= craft.fuel_capacity then
        table.insert(route_options, {
          craft_id = craft.id,
          distance = distance,
          travel_time = travel_time,
          fuel_needed = fuel_needed,
          cost = fuel_needed * FUEL_PRICE_PER_UNIT
        })
      end
    end
  end

  -- Select best (cheapest valid) route
  table.sort(route_options, function(a,b) return a.cost < b.cost end)
  return route_options[1]
end
```

**Cargo Calculation:**
```lua
function calculateTransferCapacity(transport_craft, distance)
  -- Fuel consumption reduces available capacity
  local fuel_needed = calculateFuelNeeded(distance, transport_craft.fuel_consumption_cruise)
  local fuel_weight = fuel_needed * FUEL_WEIGHT_PER_UNIT

  -- Total available cargo = capacity - fuel weight
  local cargo_available = transport_craft.cargo_capacity - fuel_weight

  return math.max(0, cargo_available)  -- Can't go negative
end

function planTransferCargo(origin_base, destination_base, cargo_manifest)
  -- Check origin has requested items
  local available_cargo = origin_base.inventory
  local transfer_cargo = {}

  for item_id, quantity_requested in pairs(cargo_manifest) do
    local quantity_available = available_cargo[item_id] or 0
    local quantity_transfer = math.min(quantity_requested, quantity_available)

    if quantity_transfer > 0 then
      transfer_cargo[item_id] = quantity_transfer
    end
  end

  return transfer_cargo
end
```

### Supply Line Management

**Supply Line Definition:**
```lua
SupplyLine = {
  id = "supply_line_primary",
  name = "Primary Supply Network",

  -- Network Structure
  hub_base_id = "base_command",               -- Central logistics hub
  connected_bases = {"base_alpha", "base_beta", "base_gamma"},
  routes = {                                  -- Links between bases
    {from = "command", to = "alpha"},
    {from = "command", to = "beta"},
    {from = "alpha", to = "gamma"}
  },

  -- Efficiency Metrics
  efficiency = 0.85,                          -- 85% delivery rate
  average_delivery_time = 48,                 -- Hours
  interruption_resistance = 0.9,              -- Resilience to interception

  -- Cost & Resources
  maintenance_cost_per_turn = 500,
  fuel_allocation_per_turn = 2000,
  personnel_assigned = 15
}
```

**Supply Demand Calculation:**
```lua
function calculateSupplyNeeds(base)
  -- Estimate what base needs
  local needs = {
    supplies = base.personnel_count * 10,     -- Per capita consumption
    fuel = 0,
    ammunition = 0,
    repairs = base.damage_total * 100
  }

  -- Add craft fuel needs
  for _, craft in ipairs(base.crafts) do
    local fuel_deficit = craft.fuel_capacity - craft.fuel_current
    needs.fuel = needs.fuel + fuel_deficit
  end

  -- Add manufacturing needs
  for _, order in ipairs(base.manufacturing_queue) do
    needs[order.primary_material] = (needs[order.primary_material] or 0) + order.quantity
  end

  return needs
end

function calculateSuppliesAvailable(hub_base)
  -- What the hub can actually provide
  local available = {}

  for resource_id, quantity in pairs(hub_base.inventory) do
    -- Reserve some for hub's own needs (10% safety buffer)
    available[resource_id] = quantity * 0.9
  end

  return available
end

function distributeSupplies(hub_base, connected_bases)
  -- Distribute hub supplies to connected bases
  local available = calculateSuppliesAvailable(hub_base)

  for _, base_id in ipairs(connected_bases) do
    local base = BaseSystem.getBase(base_id)
    local needs = calculateSupplyNeeds(base)

    -- Prioritize critical needs
    for resource_id, needed_amount in pairs(needs) do
      local available_amount = available[resource_id] or 0
      local transfer_amount = math.min(needed_amount, available_amount)

      if transfer_amount > 0 then
        hub_base.inventory[resource_id] = hub_base.inventory[resource_id] - transfer_amount
        base.inventory[resource_id] = (base.inventory[resource_id] or 0) + transfer_amount
        available[resource_id] = available[resource_id] - transfer_amount
      end
    end
  end
end
```

### Transfer Costs & Economics

**Transfer Cost Calculation:**
```lua
function calculateTransferCost(cargo_manifest, distance, transport_craft)
  -- Fuel cost
  local fuel_needed = calculateFuelNeeded(distance, transport_craft.fuel_consumption_cruise)
  local fuel_cost = fuel_needed * FUEL_PRICE_PER_UNIT

  -- Transport cost (maintenance + crew)
  local transport_cost = (distance / 1000) * TRANSPORT_COST_PER_1000KM

  -- Insurance cost (for valuable cargo)
  local cargo_value = calculateCargoValue(cargo_manifest)
  local insurance_cost = cargo_value * TRANSFER_INSURANCE_RATE

  -- Total cost
  local total_cost = fuel_cost + transport_cost + insurance_cost

  return {
    fuel_cost = fuel_cost,
    transport_cost = transport_cost,
    insurance_cost = insurance_cost,
    total = total_cost
  }
end

function calculateCargoValue(cargo_manifest)
  local total_value = 0

  for item_id, quantity in pairs(cargo_manifest) do
    local item = ItemSystem.getItem(item_id)
    total_value = total_value + (item.value * quantity)
  end

  return total_value
end
```

**Resource Transfer Tax:**
```lua
function calculateTransferTax(origin_country, destination_country, cargo_value)
  -- Tax depends on country relations and faction
  local base_tax_rate = 0.05  -- 5% base tax

  -- Reduce tax if countries are allies
  local relations = getRelations(origin_country, destination_country)
  if relations > 0.7 then
    base_tax_rate = base_tax_rate * 0.5  -- 50% tax reduction for allies
  elseif relations < 0.3 then
    base_tax_rate = base_tax_rate * 2.0  -- 100% tax increase for enemies
  end

  -- Check for trade agreements
  if hasTradeAgreement(origin_country, destination_country) then
    base_tax_rate = base_tax_rate * 0.1  -- 90% reduction with trade agreement
  end

  local tax_amount = cargo_value * base_tax_rate

  return tax_amount
end
```

### Interception & Security

**Interception Risk:**
```lua
function calculateInterceptionRisk(route, security_level, route_publicity)
  local base_risk = 0.15  -- 15% base interception risk

  -- Security level reduces risk (1-5 scale)
  local security_multiplier = 1.0 / security_level  -- 1.0x at level 1, 0.2x at level 5

  -- Route publicity increases risk (hidden routes safer)
  local publicity_factor = 1.0 + (route_publicity * 0.5)  -- Up to 1.5x multiplier

  -- Enemy presence increases risk
  local enemy_territory_penalty = 0.0
  for _, province in ipairs(route.provinces_crossed) do
    if isEnemyTerritoryOrHostile(province) then
      enemy_territory_penalty = enemy_territory_penalty + 0.1
    end
  end

  local total_risk = (base_risk * security_multiplier * publicity_factor) + enemy_territory_penalty

  return math.clamp(total_risk, 0, 1)
end

function handleInterception(route, intercepting_force)
  -- When cargo is intercepted
  local loss_percentage = 0.5  -- Default 50% loss

  -- Escort craft can reduce loss
  if route.escort_craft_count > 0 then
    loss_percentage = loss_percentage * (1.0 - (route.escort_craft_count * 0.15))  -- 15% reduction per escort
  end

  -- Update route stats
  route.interception_attempts = route.interception_attempts + 1
  route.condition = route.condition - 0.1  -- Route damaged by interception

  -- Calculate actual loss
  local cargo_lost = {}
  for item_id, quantity in pairs(route.current_cargo) do
    cargo_lost[item_id] = math.floor(quantity * loss_percentage)
  end

  return cargo_lost
end
```

### Personnel Transfer

**Unit Transfer Mechanics:**
```lua
function transferPersonnel(origin_base, destination_base, unit_ids)
  -- Check destination has capacity
  local destination_capacity = destination_base:getPersonnelCapacity()
  local destination_current = #destination_base.personnel

  if destination_current + #unit_ids > destination_capacity then
    return {success = false, reason = "Destination at capacity"}
  end

  -- Process transfer
  for _, unit_id in ipairs(unit_ids) do
    local unit = origin_base:getUnit(unit_id)

    if unit then
      -- Remove from origin
      origin_base:removeUnit(unit_id)

      -- Add to destination
      destination_base:addUnit(unit)

      -- Record in unit history
      unit.transfer_history = unit.transfer_history or {}
      table.insert(unit.transfer_history, {
        from_base = origin_base.id,
        to_base = destination_base.id,
        date = calendar.getCurrentDate()
      })
    end
  end

  return {success = true, units_transferred = #unit_ids}
end
```

### Craft Transfer

**Craft Relocation:**
```lua
function transferCraft(origin_base, destination_base, craft_ids)
  -- Check fuel for travel
  local distance = calculateDistance(origin_base.location, destination_base.location)

  for _, craft_id in ipairs(craft_ids) do
    local craft = origin_base:getCraft(craft_id)

    if craft then
      local fuel_needed = calculateFuelNeeded(distance, craft.speed_cruise)

      if craft.fuel_current < fuel_needed then
        -- Not enough fuel - need intermediate base
        return {success = false, reason = "Insufficient fuel for direct transfer"}
      end

      -- Transfer craft
      craft.fuel_current = craft.fuel_current - fuel_needed

      origin_base:removeCraft(craft_id)
      destination_base:addCraft(craft)
    end
  end

  return {success = true, crafts_transferred = #craft_ids}
end
```

### TOML Configuration

```toml
[transfer_system]
enabled = true

[transfer_system.routes]
max_concurrent_routes = 10
route_maintenance_cost = 500  # Credits per turn
route_condition_decay = 0.02  # Condition loss per turn

[transfer_system.cargo]
base_transfer_tax_rate = 0.05
tax_reduction_allies = 0.5
tax_increase_enemies = 2.0
trade_agreement_multiplier = 0.1

[transfer_system.costs]
fuel_price_per_unit = 10
transport_cost_per_1000km = 100
insurance_rate = 0.02

[transfer_system.interception]
base_interception_risk = 0.15
interception_multiplier_per_security_level = 0.2  # 1.0/security_level
escort_loss_reduction_per_craft = 0.15
route_publicity_interception_bonus = 0.5
enemy_territory_risk_per_province = 0.1

[transfer_system.personnel]
transfer_morale_penalty = 0.1  # Units lose 10% morale on transfer
transfer_training_retention = 0.95  # Retain 95% of training
transfer_cooldown_days = 7  # Can't re-transfer within 7 days

[transfer_system.crafts]
fuel_consumption_transfer = 1.5  # 1.5x normal consumption when not in active use
transfer_damage_risk = 0.05  # 5% chance of damage during transfer
```

### Supply Line Examples

**Minimal Supply Network:**
```toml
[supply_network.minimal]
hub_base = "base_command"
connected_bases = ["base_alpha"]
supply_frequency = 7  # Days between shipments
route_security = 2

[supply_network.minimal.scheduled_supplies]
# Send these items on each supply run
supplies = 1000
fuel = 2000
ammunition = 500
```

**Advanced Supply Network:**
```toml
[supply_network.advanced]
hub_base = "base_command"
connected_bases = ["base_alpha", "base_beta", "base_gamma", "base_delta"]
route_security = 4
escort_craft_minimum = 1

# Regional supply hubs for distribution
[[supply_network.advanced.regional_hubs]]
base_id = "base_alpha"
serves = ["base_gamma"]
supply_frequency = 3

[[supply_network.advanced.regional_hubs]]
base_id = "base_beta"
serves = ["base_delta"]
supply_frequency = 5

# Reserve supplies at hub for emergencies
[supply_network.advanced.emergency_reserves]
supplies = 5000
fuel = 10000
ammunition = 3000
```

---

## Performance Considerations

- Cache base status calculations and update per turn only
- Use indexed lookup for facilities by ID
- Precalculate facility adjacency bonuses during placement
- Batch personnel efficiency calculations once per turn
- Use flags for facility status instead of string comparisons
- Batch power distribution calculations

---

## See Also

- **API_FACILITIES.md** - Detailed facility specifications
- **API_RESEARCH_AND_MANUFACTURING.md** - Production system
- **API_ECONOMY.md** - Financial management
- **API_UNITS.md** - Personnel details
- **API_GEOSCAPE.md** - Territory and province system

---

**Last Updated:** October 22, 2025
**API Status:** ✅ COMPLETE
**Coverage:** 100% (All entities, functions, TOML, examples documented)
