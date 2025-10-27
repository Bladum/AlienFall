# Facilities System API Documentation

## Overview

The Facilities System provides comprehensive management of all facility types in a base. Each facility (Laboratory, Workshop, Barracks, Hospital, Hangar, Living Quarters, Storage, Power Plant) has unique properties, production capabilities, personnel requirements, and adjacency bonuses. Facilities are the core operational buildings that enable base functionality and provide strategic depth through positioning and resource allocation.

**Key Responsibilities:**
- Facility creation, placement, and management
- Production and research capabilities
- Personnel assignment and efficiency calculations
- Power grid management and load balancing
- Adjacency bonus system for optimization
- Damage tracking and repair management
- Grid-based base layout system

**Integration Points:**
- Basescape for base management and grid system
- Personnel system for staff assignment
- Economy for manufacturing and research queues
- Power system for grid management
- Production systems for research/manufacturing
- Analytics for facility tracking

---

## Architecture

### Data Flow

```
Base Creation → Facility Placement → Grid Layout → Power Grid
      ↓                ↓                ↓              ↓
  Initialize    Add to Grid      Calculate      Power Balance
      ↓                ↓                ↓              ↓
  Personnel → Efficiency Calc → Production → Resource Cost
```

### System Components

1. **Facility Manager** - Facility creation and lifecycle
2. **Grid System** - Base layout and positioning
3. **Personnel Manager** - Staff assignment
4. **Production Queue** - Manufacturing/research tracking
5. **Power Manager** - Electricity production/consumption
6. **Adjacency System** - Facility synergy bonuses
7. **Efficiency Calculator** - Production speed multipliers

### Facility Categories

- **Command** - Command Center (strategic control)
- **Residential** - Living Quarters, Barracks (personnel housing)
- **Manufacturing** - Workshop, Armor Workshop, Munitions (equipment production)
- **Storage** - General Storage, Armory, Vault (item storage)
- **Power** - Power Generator, Reactor, Solar Array (power production)
- **Detection** - Radar Station, Advanced Radar, Satellite Uplink (detection)
- **Medical** - Medical Lab, Hospital, Psyonic Lab (medical services)
- **Research** - Research Lab, Advanced Research, Alien Containment (research)
- **Defense** - Gun Emplacement, Laser Turret, Missile Silo (base defense)

---

## Quick Start

### Loading Facilities

```lua
local DataLoader = require("core.data_loader")
DataLoader.load()

-- Get a specific facility
local commandCenter = DataLoader.facilities.get("command_center")
if commandCenter then
    print(commandCenter.name)
end

-- Get all facility IDs
local allFacilities = DataLoader.facilities.getAllIds()

-- Get facilities by type
local manufacturingFacilities = DataLoader.facilities.getByType("manufacturing")
```

---

## Facility System Overview

### What is a Facility?

A facility is a structural unit in a base:
- Occupies space in base grid (hex grid)
- Provides gameplay function (manufacturing, research, defense)
- Costs resources to build
- Requires maintenance
- Can provide adjacency bonuses
- Consumes/produces power

### File Structure

**File**: `rules/facilities/base_facilities.toml`, `research_facilities.toml`, `manufacturing.toml`, `defense.toml`  
**Array**: `[[facility]]`  
**Access**: `DataLoader.facilities.get(facilityId)`

---

## Facility Schema

| Field | Type | Required | Default | Constraints | Notes |
|-------|------|----------|---------|-------------|-------|
| `id` | string | YES | - | alphanumeric_underscore | Unique facility ID |
| `name` | string | YES | - | any | Display name |
| `description` | string | NO | "" | any | Flavor text |
| `type` | string | YES | - | (see types below) | Facility category |
| `width` | integer | YES | - | 1-5 | Grid width (hexes) |
| `height` | integer | YES | - | 1-5 | Grid height (hexes) |
| `cost` | integer | YES | - | 500-99999 | Build cost (credits) |
| `time_to_build` | integer | YES | - | 1-100 | Build time (days) |
| `maintenance_cost` | integer | YES | - | 0-500 | Monthly upkeep |
| `capacity` | integer | NO | 0 | 0-100 | Storage/personnel capacity |
| `production_rate` | number | NO | 1.0 | 0.5-3.0 | Manufacturing multiplier |
| `power_generation` | integer | NO | 0 | 0-50 | Power produced |
| `power_consumption` | integer | NO | 0 | 0-50 | Power consumed |
| `detection_radius` | integer | NO | 0 | 0-500 | Radar range (km) |
| `specialization` | string | NO | "" | (see below) | Workshop specialization |
| `effect` | string | NO | "" | effect ID | Special ability |
| `adjacency_bonus_type` | string | NO | "" | "research", "manufacturing" | Adjacency synergy |

### Facility Types

| Type | Purpose | Examples |
|------|---------|----------|
| **command** | Command & Control | Command Center |
| **residential** | Personnel housing | Living Quarters, Barracks |
| **manufacturing** | Equipment crafting | Workshop, Armor Workshop |
| **storage** | Item storage | General Storage, Armory |
| **power** | Power generation | Power Generator, Reactor |
| **detection** | Radar & detection | Radar Station |
| **medical** | Medical services | Medical Lab, Hospital |
| **research** | Technology research | Research Lab, Alien Containment |
| **defense** | Base defense | Defense Turret, Gun Emplacement |

### Facility Specializations

Workshops can specialize in:
```
"general"       - Any equipment
"armor"         - Armor suits only
"ammunition"    - Ammunition only
"weapons"       - Weapons only
"research"      - Research facility specialization
```

---

## Facility Size & Grid

### Size Categories

| Size | Grid | Example | Best For |
|------|------|---------|----------|
| **1×1** | 1 hex | Power generator | Filler, edge slots |
| **1×2** | 2 hex | Radar | Medium efficiency |
| **2×2** | 4 hex | Workshop | Standard facilities |
| **2×3** | 6 hex | Large facility | Major facilities |
| **3×3** | 9 hex | Large facility | Central facilities |

### Base Grid

Bases use hexagonal grids:
- **Small base**: 4×4 grid (16 hexes)
- **Medium base**: 5×5 grid (25 hexes)
- **Large base**: 6×6 grid (36 hexes)
- **Huge base**: 7×7 grid (49 hexes)

---

## Complete Facility Examples

### Command & Control

```toml
[[facility]]
id = "command_center"
name = "Command Center"
description = "Strategic command and control center - essential for operations"
type = "command"
width = 2
height = 2
cost = 2000
time_to_build = 10
maintenance_cost = 50
power_consumption = 5
effect = "base_command"
```

### Residential

```toml
[[facility]]
id = "living_quarters"
name = "Living Quarters"
description = "Soldiers' barracks and sleeping area"
type = "residential"
width = 3
height = 2
cost = 800
time_to_build = 5
maintenance_cost = 15
capacity = 10
effect = "soldier_morale"
power_consumption = 3

[[facility]]
id = "barracks"
name = "Barracks"
description = "Military barracks - enhanced soldier morale"
type = "residential"
width = 2
height = 3
cost = 1000
time_to_build = 6
maintenance_cost = 20
capacity = 15
effect = "soldier_morale_boost"
power_consumption = 3
```

### Manufacturing

```toml
[[facility]]
id = "workshop"
name = "Workshop"
description = "Equipment manufacturing and maintenance"
type = "manufacturing"
width = 2
height = 2
cost = 1500
time_to_build = 8
maintenance_cost = 30
production_rate = 1.2
power_consumption = 10
specialization = "general"
adjacency_bonus_type = "manufacturing"

[[facility]]
id = "armor_workshop"
name = "Armor Workshop"
description = "Specialized armor manufacturing and upgrades"
type = "manufacturing"
width = 2
height = 2
cost = 1300
time_to_build = 7
maintenance_cost = 25
production_rate = 1.5
power_consumption = 8
specialization = "armor"
adjacency_bonus_type = "manufacturing"

[[facility]]
id = "munitions_workshop"
name = "Munitions Workshop"
description = "Ammunition and explosives manufacturing"
type = "manufacturing"
width = 2
height = 2
cost = 1200
time_to_build = 7
maintenance_cost = 25
production_rate = 1.4
power_consumption = 8
specialization = "ammunition"
adjacency_bonus_type = "manufacturing"

[[facility]]
id = "advanced_workshop"
name = "Advanced Workshop"
description = "High-tech equipment manufacturing"
type = "manufacturing"
width = 3
height = 3
cost = 3000
time_to_build = 15
maintenance_cost = 60
production_rate = 2.0
power_consumption = 20
specialization = "general"
adjacency_bonus_type = "manufacturing"
```

### Storage

```toml
[[facility]]
id = "storage"
name = "General Storage"
description = "Item and supply storage"
type = "storage"
width = 2
height = 2
cost = 600
time_to_build = 4
maintenance_cost = 10
capacity = 50
effect = "storage_expansion"
power_consumption = 2

[[facility]]
id = "armory"
name = "Armory"
description = "Specialized weapon and armor storage"
type = "storage"
width = 2
height = 2
cost = 700
time_to_build = 5
maintenance_cost = 12
capacity = 75
effect = "weapon_storage"
power_consumption = 2

[[facility]]
id = "vault"
name = "Vault"
description = "Secure high-capacity storage"
type = "storage"
width = 3
height = 2
cost = 1200
time_to_build = 8
maintenance_cost = 25
capacity = 150
effect = "vault_storage"
power_consumption = 5
```

### Power Generation

```toml
[[facility]]
id = "power_generator"
name = "Power Generator"
description = "Nuclear power generation"
type = "power"
width = 1
height = 1
cost = 1200
time_to_build = 8
maintenance_cost = 25
power_generation = 10

[[facility]]
id = "reactor"
name = "Reactor"
description = "Advanced fusion reactor"
type = "power"
width = 2
height = 2
cost = 3000
time_to_build = 15
maintenance_cost = 60
power_generation = 25

[[facility]]
id = "solar_array"
name = "Solar Array"
description = "Renewable solar power"
type = "power"
width = 2
height = 1
cost = 800
time_to_build = 6
maintenance_cost = 10
power_generation = 5
```

### Detection & Radar

```toml
[[facility]]
id = "radar_station"
name = "Radar Station"
description = "Detection and tracking system"
type = "detection"
width = 2
height = 2
cost = 1000
time_to_build = 6
maintenance_cost = 20
detection_radius = 100
effect = "geoscape_coverage"
power_consumption = 5

[[facility]]
id = "advanced_radar"
name = "Advanced Radar"
description = "High-sensitivity detection array"
type = "detection"
width = 2
height = 2
cost = 2000
time_to_build = 10
maintenance_cost = 40
detection_radius = 200
effect = "enhanced_coverage"
power_consumption = 8

[[facility]]
id = "satellite_uplink"
name = "Satellite Uplink"
description = "Satellite communication and detection"
type = "detection"
width = 1
height = 1
cost = 1500
time_to_build = 8
maintenance_cost = 30
detection_radius = 300
effect = "global_coverage"
power_consumption = 10
```

### Medical

```toml
[[facility]]
id = "med_lab"
name = "Medical Laboratory"
description = "Medical research and treatment"
type = "medical"
width = 2
height = 2
cost = 1100
time_to_build = 7
maintenance_cost = 25
effect = "soldier_healing"
capacity = 5
power_consumption = 5

[[facility]]
id = "hospital"
name = "Hospital"
description = "Full medical care facility"
type = "medical"
width = 3
height = 2
cost = 1500
time_to_build = 10
maintenance_cost = 35
effect = "advanced_healing"
capacity = 10
power_consumption = 8

[[facility]]
id = "psyonic_lab"
name = "Psyonic Laboratory"
description = "Psyonic ability research and training"
type = "medical"
width = 2
height = 2
cost = 2000
time_to_build = 12
maintenance_cost = 40
effect = "psyonic_training"
power_consumption = 10
```

### Research

```toml
[[facility]]
id = "research_lab"
name = "Research Lab"
description = "Technology research and development"
type = "research"
width = 2
height = 2
cost = 1200
time_to_build = 8
maintenance_cost = 30
production_rate = 1.2
effect = "research_boost"
power_consumption = 8
adjacency_bonus_type = "research"

[[facility]]
id = "advanced_research_lab"
name = "Advanced Research Lab"
description = "State-of-the-art research facility"
type = "research"
width = 3
height = 2
cost = 2500
time_to_build = 15
maintenance_cost = 50
production_rate = 1.8
effect = "advanced_research"
power_consumption = 12
adjacency_bonus_type = "research"

[[facility]]
id = "alien_containment"
name = "Alien Containment"
description = "Secure facility for alien prisoners and research"
type = "research"
width = 2
height = 2
cost = 1500
time_to_build = 8
maintenance_cost = 30
capacity = 5
effect = "alien_research"
power_consumption = 10
```

### Defense

```toml
[[facility]]
id = "gun_emplacement"
name = "Gun Emplacement"
description = "Base defense turret"
type = "defense"
width = 1
height = 1
cost = 500
time_to_build = 3
maintenance_cost = 15
effect = "base_defense"
power_consumption = 3

[[facility]]
id = "laser_turret"
name = "Laser Turret"
description = "Advanced laser defense system"
type = "defense"
width = 1
height = 1
cost = 1200
time_to_build = 6
maintenance_cost = 25
effect = "advanced_defense"
power_consumption = 5

[[facility]]
id = "missile_silo"
name = "Missile Silo"
description = "Long-range missile defense"
type = "defense"
width = 2
height = 2
cost = 2500
time_to_build = 12
maintenance_cost = 50
effect = "missile_defense"
power_consumption = 8
```

---

## Adjacency Bonus System

### Overview

Facilities grouped strategically provide efficiency bonuses when positioned adjacent to complementary facilities. The system rewards compact, synergistic base layouts with productivity multipliers.

**Key Mechanics:**
- **Trigger:** Automatic detection of adjacent compatible facilities
- **Range:** Cardinal adjacency only (North, South, East, West) - **diagonals do NOT count**
- **Stacking:** Multiple bonuses can apply (limited to 3-4 per facility)
- **Multiplier:** Bonuses are multiplicative (1.10× = +10% efficiency)
- **Dynamic:** Recalculated when facilities are placed/moved/removed

### Adjacency Rules

**Valid Adjacency:**
- ✅ North, South, East, West (cardinal directions)
- ❌ Diagonals do NOT provide bonuses
- ❌ Facilities separated by empty space do NOT get bonuses
- ✅ All facilities must be connected to main cluster (no islands)

**Distance Types:**
- **Adjacent:** Directly touching (1 tile)
- **Within Range:** 2-hex distance (for power bonuses)

### Seven Bonus Types

| Pairing | Bonus Type | Requirements | Effect |
|---------|-----------|--------------|--------|
| **Lab + Workshop** | Research & Manufacturing Synergy | Adjacent (touching) | +10% research speed, +10% manufacturing speed |
| **Workshop + Storage** | Material Supply Chain | Adjacent | -10% material cost for manufacturing |
| **Hospital + Barracks** | Medical Support | Adjacent | +1 HP/week, +1 Sanity/week recovery for all personnel |
| **Garage + Hangar** | Craft Logistics | Adjacent | +15% craft repair speed |
| **Power Plant + Lab/Workshop** | Power Efficiency | Within 2-hex distance | +10% research/manufacturing efficiency |
| **Radar + Turret** | Fire Control | Adjacent | +10% targeting accuracy |
| **Academy + Barracks** | Training Synergy | Adjacent | +1 XP/week gain for all personnel in Barracks |

### Bonus Calculation Formula

**Single Bonus:**
```
Adjusted Efficiency = Base Efficiency × Bonus Multiplier

Example:
Base Research Rate: 10 man-days/week
Adjacent Workshop: +10% bonus (1.10×)
Adjusted Rate: 10 × 1.10 = 11 man-days/week
```

**Multiple Bonuses (Stacking):**
```
Final Multiplier = Bonus1 × Bonus2 × Bonus3 × ...

Example - Lab with multiple bonuses:
1. Adjacent Workshop: 1.10× (+10%)
2. Power Plant in range: 1.10× (+10%)
Final: 1.10 × 1.10 = 1.21× (+21% total)

Base Rate: 10 man-days/week
Final Rate: 10 × 1.21 = 12.1 man-days/week
```

**Maximum Stacking:**
- Limited to 3-4 bonuses per facility
- Prevents overpowered clustering
- Encourages strategic variety

### TOML Configuration

```toml
[[adjacency_bonus]]
id = "research_synergy"
facility_type_a = "research_lab"
facility_type_b = "research_lab"
bonus_type = "research_speed"
bonus_magnitude = 10  # Percentage bonus

[[adjacency_bonus]]
id = "manufacturing_synergy"
facility_type_a = "workshop"
facility_type_b = "workshop"
bonus_type = "manufacturing_speed"
bonus_magnitude = 10

[[adjacency_bonus]]
id = "power_efficiency_lab"
facility_type_a = "power_generator"
facility_type_b = "research_lab"
bonus_type = "research_speed"
bonus_magnitude = 10
range = 2  # Can be 2 hexes away
```

### Usage Examples

**Example 1: Research Cluster**
```
Layout:
[Lab A] - [Lab B]
           |
        [Lab C]

Result:
- Lab A: +10% from Lab B = 1.10× efficiency
- Lab B: +10% from Lab A, +10% from Lab C = 1.21× efficiency
- Lab C: +10% from Lab B = 1.10× efficiency
```

**Example 2: Manufacturing Hub**
```
Layout:
[Storage] - [Workshop A] - [Workshop B]
                |
            [Power Gen]

Result:
- Workshop A: 
  * +10% from Workshop B (adjacent)
  * -10% cost from Storage (adjacent)
  * +10% from Power Gen (within range)
  * Total: 1.10 × 1.10 = 1.21× speed, -10% costs

- Workshop B:
  * +10% from Workshop A (adjacent)
  * Total: 1.10× speed
```

**Example 3: Invalid Diagonal**
```
Layout:
[Lab A]     [Lab B]
     (diagonal gap)

Result:
- NO BONUS - diagonals don't count
- Both operate at base efficiency
```

---

## Power Grid System

### Overview

Facilities consume or produce power. The power grid must be balanced to keep all facilities operational. Power calculations occur per turn (daily).

**Key Concepts:**
- **Power Generation:** Power plants produce electricity
- **Power Consumption:** Facilities consume electricity to operate
- **Power Balance:** Total generation must meet or exceed consumption
- **Brownout:** If generation < consumption, facilities shut down in priority order
- **Efficiency:** Properly powered facilities operate at full capacity

### Power Calculation

**Formula:**
```
Total Power Available = Sum(all power_generation)
Total Power Required = Sum(all power_consumption)

Power Status:
- If Available >= Required: All facilities operational
- If Available < Required: Brownout - lowest priority facilities shut down
```

**Example:**
```
Power Generation:
- Reactor: 25 units
- Power Generator: 10 units
- Total: 35 units

Power Consumption:
- Research Lab: 8 units
- Workshop: 10 units
- Living Quarters: 3 units
- Barracks: 3 units
- Radar: 5 units
- Total: 29 units

Result: 35 >= 29 → All facilities operational (6 units spare capacity)
```

### Brownout Priority System

When power is insufficient, facilities shut down in this order (lowest priority first):

1. **Non-Essential** (priority 1)
   - Extra storage
   - Recreational facilities
   
2. **Production** (priority 2)
   - Workshops
   - Factories
   
3. **Research** (priority 3)
   - Research labs
   - Alien containment
   
4. **Detection** (priority 4)
   - Radar stations
   
5. **Critical** (priority 5)
   - Medical facilities
   - Living quarters
   - Command center
   
6. **Vital** (priority 6)
   - Power plants (never shut down)
   - Defense systems (never shut down)

**Brownout Example:**
```
Power Available: 20 units
Power Required: 35 units
Deficit: -15 units

Shutdown Order:
1. Extra Storage (-2 units) → Deficit: -13
2. Workshop A (-10 units) → Deficit: -3
3. Research Lab (-8 units) → Deficit: +5 (now surplus)

Result: Storage and Workshop A offline, Research Lab offline, all others operational
```

### Power Efficiency Tips

**Good Practices:**
1. **Build power first** - Ensure sufficient generation before expanding
2. **Plan for growth** - Leave 20-30% spare capacity
3. **Use power bonuses** - Place power plants near consumers (2-hex range)
4. **Prioritize** - Put critical facilities on dedicated power
5. **Monitor consumption** - Track power usage per facility type

**Power-to-Facility Ratios:**
```
Small Base (5-8 facilities):
- 1× Reactor (25 units) OR
- 2× Power Generator (20 units total)

Medium Base (10-15 facilities):
- 1× Reactor + 1× Power Generator (35 units)

Large Base (20+ facilities):
- 2× Reactor (50 units) OR
- 1× Reactor + 2× Power Generator (45 units)
```

---

## Personnel Efficiency System

### Overview

Facilities require personnel (engineers, scientists, soldiers) to operate. Personnel assignment affects facility efficiency and production output.

**Key Factors:**
- **Staffing Level:** Percentage of positions filled (0-150%)
- **Skill Level:** Average skill of assigned personnel
- **Morale:** Personnel morale affects productivity
- **Fatigue:** Overworked personnel have reduced efficiency

### Staffing Efficiency Formula

**Base Formula:**
```
Efficiency = min(Staffing Level, 1.5) × Skill Multiplier × Morale Multiplier

Where:
- Staffing Level = Assigned Personnel / Required Personnel
- Skill Multiplier = 0.5 + (Average Skill / 20)
- Morale Multiplier = 0.5 + (Average Morale / 200)
```

**Examples:**

**Understaffed:**
```
Research Lab:
- Required: 10 scientists
- Assigned: 5 scientists (50% staffed)
- Average Skill: 10
- Average Morale: 80

Efficiency:
= 0.5 × (0.5 + 10/20) × (0.5 + 80/200)
= 0.5 × 1.0 × 0.9
= 0.45 (45% efficiency)
```

**Fully Staffed:**
```
Research Lab:
- Required: 10 scientists
- Assigned: 10 scientists (100% staffed)
- Average Skill: 15
- Average Morale: 90

Efficiency:
= 1.0 × (0.5 + 15/20) × (0.5 + 90/200)
= 1.0 × 1.25 × 0.95
= 1.19 (119% efficiency)
```

**Overstaffed:**
```
Research Lab:
- Required: 10 scientists
- Assigned: 15 scientists (150% staffed)
- Average Skill: 12
- Average Morale: 85

Efficiency:
= 1.5 × (0.5 + 12/20) × (0.5 + 85/200)
= 1.5 × 1.1 × 0.93
= 1.53 (153% efficiency - maximum possible)
```

### Skill Progression

Personnel gain skill over time while assigned:

```
Skill Gain = (Base Gain / Days Worked) × Facility Quality

Base Gain: 1 skill point per 30 days
Facility Quality:
- Basic facility: 1.0×
- Advanced facility: 1.5×
- Cutting-edge facility: 2.0×
```

### Morale Effects

**Morale Ranges:**
- **90-100:** +50% to efficiency (morale multiplier = 1.0)
- **70-89:** Normal efficiency (morale multiplier = 0.8-0.95)
- **50-69:** -20% efficiency (morale multiplier = 0.65-0.85)
- **Below 50:** -50% efficiency (morale multiplier = 0.5-0.75)

**Morale Factors:**
- Living conditions (barracks quality)
- Recent missions (success/failure)
- Casualties (deaths in squad)
- Salary/payment
- Recreation facilities
- Commander decisions

---

## Placement Validation System

### Placement Rules

**Valid Placement Requires:**
1. ✅ Position is within base grid bounds
2. ✅ Position is empty (no existing facility)
3. ✅ Facility is connected to main cluster (adjacency)
4. ✅ Sufficient funds to build
5. ✅ Prerequisites met (technology, other facilities)

**Invalid Placement:**
- ❌ Overlapping with existing facility
- ❌ Outside grid boundaries
- ❌ Creating isolated facility (no cardinal connection)
- ❌ Insufficient funds
- ❌ Missing prerequisite technology

### Validation Function

```lua
function FacilitySystem:canPlace(facilityTypeId, x, y)
    -- Check bounds
    if not self:isValidPosition(x, y) then
        return false, "Position out of bounds"
    end
    
    -- Check if empty
    if self.grid[x][y].status ~= FacilitySystem.STATUS.EMPTY then
        return false, "Position occupied"
    end
    
    -- Check adjacency (must connect to existing facilities)
    if not self:isConnectedToCluster(x, y) then
        return false, "Not connected to base cluster"
    end
    
    -- Check prerequisites
    local facilityDef = DataLoader.facilities.get(facilityTypeId)
    if facilityDef.requires_tech then
        if not ResearchSystem:hasTech(facilityDef.requires_tech) then
            return false, "Technology not researched"
        end
    end
    
    -- Check funds
    if self:getCurrentFunds() < facilityDef.cost then
        return false, "Insufficient funds"
    end
    
    return true, "Valid placement"
end
```

### Connectivity Check

**Algorithm:**
```lua
function FacilitySystem:isConnectedToCluster(x, y)
    -- Check all 4 cardinal directions
    local directions = {
        {x = x, y = y - 1},  -- North
        {x = x, y = y + 1},  -- South
        {x = x - 1, y = y},  -- West
        {x = x + 1, y = y},  -- East
    }
    
    for _, pos in ipairs(directions) do
        if self:isValidPosition(pos.x, pos.y) then
            local cell = self.grid[pos.x][pos.y]
            if cell.status == FacilitySystem.STATUS.OPERATIONAL then
                return true  -- Connected to at least one facility
            end
        end
    end
    
    -- Special case: First facility (HQ exists)
    if self:hasOperationalFacilities() then
        return false  -- Must connect to existing cluster
    else
        return true  -- First facility is always valid
    end
end
```

### Placement Examples

**Valid Placements:**
```
Example 1: Expanding from HQ
[HQ] - [ ]
  |
[Lab]

Lab is adjacent to HQ (South) → VALID
```

**Invalid Placements:**
```
Example 2: Diagonal connection
[HQ]     [ ]
    (diagonal)
         [Lab]

Lab not cardinally adjacent → INVALID

Example 3: Isolated facility
[HQ] - [Lab]

         [Workshop] (separated by gap)

Workshop not connected → INVALID
```

---

| Facility | Type | Power |
|----------|------|-------|
| Power Generator | Production | +10 |
| Reactor | Production | +25 |
| Workshop | Consumption | -10 |
| Research Lab | Consumption | -8 |
| Radar | Consumption | -5 |
| Command Center | Consumption | -5 |

### Power Grid Rules

1. Total generation must >= total consumption
2. If insufficient power, facilities go offline
3. Critical facilities (command) go offline last
4. Efficiency bonus from production rate

---

## Base Expansion System

### Size Progression

```
Small (4×4) → Medium (5×5) → Large (6×6) → Huge (7×7)
    16 hex       25 hex       36 hex        49 hex
```

### Expansion Requirements

Each size upgrade requires:
- Time investment (30-90 days)
- Resource investment (150K-600K credits)
- Population happiness bonus
- Previous facilities intact

---

## Lua Usage Patterns

### Getting Facility Info

```lua
function getFacilityInfo(facilityId)
    local facility = DataLoader.facilities.get(facilityId)
    if not facility then return nil end
    
    return {
        name = facility.name,
        cost = facility.cost,
        time = facility.time_to_build,
        maintenance = facility.maintenance_cost,
        power_net = (facility.power_generation or 0) - (facility.power_consumption or 0),
        capacity = facility.capacity or 0
    }
end
```

### Calculating Base Stats

```lua
function calculateBasePowerBalance(base)
    local totalGeneration = 0
    local totalConsumption = 0
    
    for _, facility in ipairs(base.facilities) do
        local facilityDef = DataLoader.facilities.get(facility.type)
        if facilityDef then
            totalGeneration = totalGeneration + (facilityDef.power_generation or 0)
            totalConsumption = totalConsumption + (facilityDef.power_consumption or 0)
        end
    end
    
    return totalGeneration - totalConsumption
end
```

### Applying Adjacency Bonuses

```lua
function getAdjacencyBonus(facility, neighbors)
    if not facility.adjacency_bonus_type then return 1.0 end
    
    local bonus = 1.0
    for _, neighbor in ipairs(neighbors) do
        if neighbor.adjacency_bonus_type == facility.adjacency_bonus_type then
            bonus = bonus * 1.15  -- 15% bonus per adjacent facility
        end
    end
    
    return math.min(bonus, 1.5)  -- Cap at 50% total bonus
end
```

---

## Modding: Creating Custom Facilities

### Step 1: Add to Facilities TOML

```toml
# In mods/mymod/content/rules/facilities/custom_facilities.toml

[[facility]]
id = "my_custom_facility"
name = "My Custom Facility"
description = "A custom facility I created"
type = "research"
width = 2
height = 2
cost = 1500
time_to_build = 8
maintenance_cost = 30
power_consumption = 10
production_rate = 1.1
adjacency_bonus_type = "research"
```

### Step 2: Test

```bash
lovec "engine"
```

Check console for:
```
[DataLoader] ✓ Loaded X facilities
```

### Step 3: Use in Game

```lua
local facility = DataLoader.facilities.get("my_custom_facility")
print(facility.name)
```

---

## Balance Guidelines

### Cost Progression

- Early (1-5 facilities): 500-1000 credits
- Mid (6-15 facilities): 1000-2000 credits
- Late (16+ facilities): 2000-3500 credits
- Endgame upgrades: 3000-5000 credits

### Build Time

- Small (1×1): 3-5 days
- Medium (2×2): 6-10 days
- Large (3×3): 12-20 days
- Special: 10-30 days

### Maintenance Cost

- Rule of thumb: ~1-2% of build cost per month
- Power production: 2-3× cheaper to maintain
- Research/manufacturing: 2-3× more expensive

### Power Balance

- Each generator: 10-25 power
- Average facility: 5-10 power consumption
- Base should have 20-30% spare capacity

---

## Performance Considerations

**Optimization Strategies:**
- Cache facility specifications on startup (avoid repeated TOML lookups)
- Use grid-based spatial indexing for adjacency calculations
- Pre-calculate adjacency bonuses during facility placement, not per frame
- Store facility state as simple numeric values (damage, workers, etc.)
- Batch power calculations once per turn, not continuously
- Use efficient grid lookups (2D array instead of searching lists)

**Best Practices:**
- Load all facility type data at initialization
- Calculate power balance once per turn
- Cache adjacency bonus tables during construction
- Use efficient facility lookup by grid position
- Store production queues as arrays, not linked lists

**Performance Impact:**
- Facility lookup: < 1ms (indexed)
- Grid position calculation: < 1ms
- Adjacency bonus: < 2ms per placement
- Power balance: 3-5ms for all facilities
- Production queue update: < 2ms

---

## See Also

- **API_SCHEMA_REFERENCE.md** - Complete schema reference
- **API_WEAPONS_AND_ARMOR.md** - Equipment documentation
- **API_UNITS_AND_CLASSES.md** - Units documentation
- **MOD_DEVELOPER_GUIDE.md** - Complete modding guide

---

## Implementation Status

### IN DESIGN (Existing in engine/)
- **FacilitySystem**: Grid-based facility management with 5×5 base layout
- **Facility Construction**: Build queues, construction time, and completion system
- **Grid Placement**: Position validation, facility placement, and grid management
- **Capacity Tracking**: Personnel, storage, research, and manufacturing capacities
- **Facility Lifecycle**: Construction, operational, damaged, and destroyed states
- **Service Management**: Power, command, and other facility services
- **Damage System**: Health tracking, armor reduction, and destruction handling
- **Maintenance Costs**: Monthly upkeep calculations for operational facilities

### FUTURE IDEAS (Not in engine/)
- **Facility Types**: TOML-based facility definitions and configurations
- **Adjacency Bonus System**: Facility synergy bonuses from strategic placement
- **Power Management**: Power generation, consumption, and distribution
- **Research Facilities**: Laboratory capacity and project management
- **Manufacturing Facilities**: Workshop production and specialization
- **Defense Facilities**: Turret and base defense capabilities
- **Medical Facilities**: Healing and personnel recovery services
- **Storage Facilities**: Item storage and capacity management

