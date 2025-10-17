# Facilities System

> **Implementation**: `../../../engine/basescape/facilities/`, `../../../engine/basescape/`
> **Tests**: `../../../tests/` (facilities tests)
> **Related**: `docs/basescape/README.md`, `docs/content/crafts.md`

The Facilities System manages all construction and management of base facilities. Players build and maintain a 5×5 grid of facilities to expand their base capabilities, including research, manufacturing, storage, and defense functions.

---

## Overview

The facility system manages:
- **Grid-Based Base Layout**: 5×5 grid with 24 buildable positions
- **Facility Construction**: Build facilities over multiple days
- **Capacity Management**: Track storage, personnel, research, manufacturing capacity
- **Services**: Radar, medical, training, power distribution
- **Maintenance Costs**: Monthly operational expenses
- **Damage & Repair**: Facilities take damage during base defense

---

## Base Architecture

### Grid Layout

Bases use a 5×5 grid system (25 total positions):

```
 0 1 2 3 4
0 [ ][ ][ ][ ][ ]
1 [ ][ ][ ][ ][ ]
2 [ ][ ][H][ ][ ]  (H = Headquarters at center)
3 [ ][ ][ ][ ][ ]
4 [ ][ ][ ][ ][ ]
```

**Grid Rules:**
- **Total Positions**: 25 (5×5 grid)
- **Headquarters**: Fixed at center (2,2)
- **Buildable Positions**: 24 (all except HQ)
- **One Facility Per Position**: Each grid slot holds one facility or is empty
- **No Diagonal Adjacency**: Only orthogonal neighbors count (up/down/left/right)

### Grid Coordinates
- **X-Axis**: 0-4 (left to right)
- **Y-Axis**: 0-4 (top to bottom)
- **Headquarters Position**: (2,2)
- **Distance Calculation**: Manhattan distance (|x1-x2| + |y1-y2|)

---

## Facility Lifecycle

Facilities go through distinct states:

### 1. EMPTY
- No facility present
- Buildable if connected to power and other requirements
- Free grid slot

### 2. CONSTRUCTION
- Building in progress
- Takes multiple days (facility-dependent)
- Cannot be used until complete
- Can be canceled (loses resources)

### 3. OPERATIONAL
- Fully functional
- Provides full capacity
- Active services enabled
- Subject to maintenance costs

### 4. DAMAGED
- Reduced functionality
- Damaged during base defense missions
- Capacity reduced by damage percentage
- Can be repaired at base facilities

### 5. DESTROYED
- Non-functional (0% health)
- Must be completely rebuilt
- Cannot be repaired, only rebuilt

---

## Facility Types

### Mandatory Facilities

#### Headquarters
- **Location**: Fixed at center (2,2)
- **Build Time**: Instant (0 days)
- **Build Cost**: Free
- **Health**: 200 HP
- **Armor**: 20 (high durability)
- **Capacities**:
  - Units: 10 (personnel capacity)
  - Items: 100 (storage slots)
  - Crafts: 1 (parking slots)
- **Services**: Power generation, command center
- **Maintenance**: 10,000 credits/month
- **Special**: Cannot be destroyed, always present

### Storage & Accommodation

#### Living Quarters
- **Build Time**: 14 days
- **Build Cost**: 100,000 credits
- **Health**: 100 HP
- **Armor**: 5
- **Capacities**:
  - Units: +20 (personnel capacity)
- **Services**: Personnel housing, morale bonuses
- **Maintenance**: 5,000 credits/month
- **Requirements**: Power

#### Storage Warehouse
- **Build Time**: 10 days
- **Build Cost**: 75,000 credits
- **Health**: 80 HP
- **Armor**: 3
- **Capacities**:
  - Items: +200 (storage slots)
- **Services**: General storage
- **Maintenance**: 2,000 credits/month
- **Requirements**: None

#### Hangar
- **Build Time**: 21 days
- **Build Cost**: 200,000 credits
- **Health**: 150 HP
- **Armor**: 10
- **Capacities**:
  - Crafts: +2 (parking slots)
  - Repair capacity: +1 (repair bays)
- **Services**: Craft storage, repair, refueling
- **Maintenance**: 15,000 credits/month
- **Requirements**: Power, fuel

### Research & Science

#### Laboratory
- **Build Time**: 21 days
- **Build Cost**: 150,000 credits
- **Health**: 100 HP
- **Armor**: 5
- **Capacities**:
  - Research Projects: +2 (concurrent research)
  - Units: +10 (scientist capacity)
- **Services**: Technology research unlocks, alien artifact analysis
- **Maintenance**: 10,000 credits/month
- **Requirements**: Power

**Research Capacity:**
- Each laboratory slot runs one independent research project
- Multiple labs enable parallel research
- Research speed affected by scientist count and lab quality

### Manufacturing

#### Workshop
- **Build Time**: 21 days
- **Build Cost**: 150,000 credits
- **Health**: 100 HP
- **Armor**: 5
- **Capacities**:
  - Manufacturing Projects: +2 (concurrent production)
  - Units: +5 (worker capacity)
- **Services**: Equipment manufacturing, craft upgrades
- **Maintenance**: 10,000 credits/month
- **Requirements**: Power, materials

**Manufacturing Capacity:**
- Each workshop slot runs one production queue
- Production speed affected by worker count and facility quality
- Requires raw materials and manufacturing time

### Defense Systems

#### Radar System
- **Build Time**: 14 days
- **Build Cost**: 200,000 credits
- **Health**: 80 HP
- **Armor**: 15 (hardened)
- **Services**: UFO detection, continent-wide radar
- **Maintenance**: 8,000 credits/month
- **Requirements**: Power
- **Detection Range**: Continental scope
- **Update Frequency**: Real-time

#### Defense Turret
- **Build Time**: 10 days
- **Build Cost**: 75,000 credits
- **Health**: 60 HP
- **Armor**: 8
- **Services**: Base defense, point defense
- **Maintenance**: 3,000 credits/month
- **Requirements**: Power, ammo
- **Weapon Type**: Medium-caliber anti-air/ground
- **Coverage**: Adjacent grid cells (crossfire pattern)

#### Missile Battery
- **Build Time**: 21 days
- **Build Cost**: 250,000 credits
- **Health**: 100 HP
- **Armor**: 10
- **Services**: Area defense, long-range interception
- **Maintenance**: 12,000 credits/month
- **Requirements**: Power, ammunition
- **Weapon Type**: Heavy missiles
- **Coverage**: Extended area (0-2 grid cells)
- **Magazine**: 12 missiles

### Utility Facilities

#### Power Generator
- **Build Time**: 14 days
- **Build Cost**: 180,000 credits
- **Health**: 80 HP
- **Armor**: 10
- **Services**: Power generation
- **Maintenance**: 6,000 credits/month
- **Requirements**: Fuel
- **Power Output**: Supports 8 adjacent facilities
- **Fuel Consumption**: 1 fuel/day operational

#### Medical Bay
- **Build Time**: 14 days
- **Build Cost**: 120,000 credits
- **Health**: 100 HP
- **Armor**: 5
- **Services**: Healing, wound treatment, resurrection
- **Maintenance**: 8,000 credits/month
- **Requirements**: Power
- **Healing Rate**: +20% per day per occupant
- **Beds**: 10 casualties

#### Training Room
- **Build Time**: 10 days
- **Build Cost**: 90,000 credits
- **Health**: 80 HP
- **Armor**: 3
- **Services**: Soldier training, stat improvement
- **Maintenance**: 4,000 credits/month
- **Requirements**: Power
- **Training Capacity**: +2 soldiers concurrent
- **Skill Improvement**: +5% per training cycle

---

## Capacity Systems

### Capacity Types

#### Personnel Capacity
Determines how many soldiers and support staff can be accommodated.

**Sources:**
- Headquarters: 10 (base)
- Living Quarters: +20 each
- Laboratory: +10 (scientists)
- Workshop: +5 (workers)

**Total Calculation:**
```
totalPersonnel = 10 + (livingQuarters × 20) + (laboratories × 10) + (workshops × 5)
```

#### Storage Capacity
Determines inventory space for items and equipment.

**Sources:**
- Headquarters: 100 (base)
- Storage: +200 each
- Hangar: +50 (craft equipment)

**Total Calculation:**
```
totalStorage = 100 + (warehouses × 200) + (hangars × 50)
```

#### Research Capacity
Concurrent research projects running simultaneously.

**Sources:**
- Laboratory: +2 projects each

**Total Calculation:**
```
researchCapacity = laboratories × 2
```

#### Manufacturing Capacity
Concurrent manufacturing/production queues.

**Sources:**
- Workshop: +2 projects each

**Total Calculation:**
```
manufacturingCapacity = workshops × 2
```

#### Craft Capacity
Hangar slots for storing and maintaining aircraft.

**Sources:**
- Headquarters: 1 (base)
- Hangar: +2 each

**Total Calculation:**
```
craftCapacity = 1 + (hangars × 2)
```

---

## Services System

Facilities provide and require services through power connections:

### Services Provided
- **Power**: Enables all dependent facilities
- **Command**: Base operational capacity
- **Radar**: Detection and monitoring
- **Medical**: Healing and treatment
- **Training**: Soldier improvement
- **Research**: Technology advancement
- **Manufacturing**: Equipment production

### Service Requirements

#### Power Requirements
Most facilities require continuous power:
- **No Requirement**: Storage, some defenses
- **Requires Power**: HQ, Living Quarters, Laboratory, Workshop, Radar, Turrets, Medical, Training

#### Connection System
- Facilities must be connected to power sources through adjacent facilities
- Power flows orthogonally (up/down/left/right)
- Disconnected facilities cannot operate
- Power generators produce local power

**Power Flow Example:**
```
[Gen] - [HQ] - [Lab]  (all connected to power)
       [Store]        (connected)
       [Broken]       (no power - needs reconnection)
```

---

## Adjacency & Bonuses

### Adjacency Detection
Facilities can provide bonuses to adjacent facilities based on orthogonal neighbors.

**Adjacent Positions:**
- Up: (x, y-1)
- Down: (x, y+1)
- Left: (x-1, y)
- Right: (x+1, y)
- (Diagonals do NOT count)

### Adjacency Bonuses

#### Laboratory Adjacency
- Storage Warehouse (adjacent): +10% research speed
- Hangar (adjacent): +5% research speed
- Each adjacent facility: +2% stacking bonus

#### Manufacturing Adjacency
- Storage Warehouse (adjacent): +10% production speed
- Power Generator (adjacent): +5% production speed
- Each adjacent facility: +2% stacking bonus

#### Defense Adjacency
- Defense Turrets (adjacent): +15% damage, overlapping fields
- Radar Systems (adjacent): +20% detection range
- Overlapping coverage creates defensive zone

#### Morale Adjacency
- Medical Bay (adjacent): +10% morale
- Training Room (adjacent): +5% training speed

---

## Construction System

### Starting Construction

**Requirements:**
- Empty grid position
- Available building capacity
- Sufficient credits
- Satisfy facility prerequisites (tech research, etc.)

**Construction Process:**
1. Select facility type and grid position
2. Pay construction cost upfront
3. Progress daily until complete
4. Facility becomes operational

**Construction Times:**
| Facility | Days | Cost |
|----------|------|------|
| Living Quarters | 14 | 100k |
| Storage | 10 | 75k |
| Hangar | 21 | 200k |
| Laboratory | 21 | 150k |
| Workshop | 21 | 150k |
| Radar | 14 | 200k |
| Defense Turret | 10 | 75k |
| Missile Battery | 21 | 250k |
| Power Generator | 14 | 180k |
| Medical Bay | 14 | 120k |
| Training Room | 10 | 90k |

### Daily Construction Progress

Construction advances 1 day per game day:

```lua
function Base:processDailyConstruction()
    for order in self.constructionQueue do
        order.progress = order.progress + 1
        if order.progress >= order.buildTime then
            self:completeConstruction(order)
        end
    end
end
```

### Construction Cancellation

- Can cancel construction at any time
- Resources are NOT refunded (sunk cost)
- Grid position becomes empty
- Construction facility removed

---

## Damage & Repair System

### Taking Damage
Facilities take damage during base defense missions.

**Damage Sources:**
- Enemy attacks in base defense battlescape
- UFO base penetration damage
- Catastrophic facility failures

**Damage Formula:**
```
damageDealt = (weaponDamage - facilityArmor) × (1 + criticalMultiplier)
healthRemaining = currentHealth - damageDealt
```

### Damage States

| Health | State | Functionality |
|--------|-------|-----------------|
| 100% | Operational | 100% capacity |
| 76-99% | Lightly Damaged | 95% capacity |
| 51-75% | Moderately Damaged | 75% capacity |
| 26-50% | Heavily Damaged | 50% capacity |
| 1-25% | Critical | 25% capacity |
| 0% | Destroyed | 0% capacity |

### Repair Mechanics

**Auto-Repair at Base:**
- Facilities damaged in base defense stay at base
- Automatically repair when stationary
- Repair rate: +10% per day
- Can assign dedicated repair crews for +50% bonus

**Repair Speed:**
```
repairPerDay = 10%  (baseline)
withCrewBonus = 15% (with repair crew)
```

**Complete Repair Time:**
- Standard: 10 days from 1% to 100%
- With repair crew: 6-7 days
- Destruction requires rebuild (not repair)

---

## Maintenance System

### Monthly Maintenance Costs

Each operational facility costs credits per month:

| Facility | Monthly Cost |
|----------|--------------|
| Headquarters | 10,000 |
| Living Quarters | 5,000 |
| Storage | 2,000 |
| Hangar | 15,000 |
| Laboratory | 10,000 |
| Workshop | 10,000 |
| Radar | 8,000 |
| Defense Turret | 3,000 |
| Missile Battery | 12,000 |
| Power Generator | 6,000 |
| Medical Bay | 8,000 |
| Training Room | 4,000 |

### Total Base Maintenance

```
totalMaintenance = Σ(operationalFacilities × monthlyMaintenance)
```

**Budget Impact:**
- Deducted from treasury monthly
- Cannot exceed available funds without debt
- Unpaid maintenance reduces facility effectiveness

---

## Strategic Considerations

### Base Design Patterns

#### Balanced Base
- 1-2 Laboratories + 1-2 Workshops (research & production)
- 2-3 Living Quarters (personnel)
- 2 Storage Warehouses (inventory)
- 1-2 Hangars (craft capability)
- 1 Radar (detection)
- 1-2 Defense (base protection)

#### Focused Research Base
- 3-4 Laboratories (max research)
- 2 Storage (supporting labs)
- 1-2 Living Quarters (scientists)
- Basic defense (turrets)

#### Industrial Production Base
- 3-4 Workshops (max manufacturing)
- 2-3 Storage (input/output)
- Power generators for stability
- Minimal research (lab)

#### Fortress Base
- Heavy defensive emphasis
- Missile batteries + turrets
- Radar systems
- Medical bays for repairs
- Minimal research/manufacturing

### Expansion Strategy

**Early Game (Months 1-3):**
- Build 1 Living Quarters (personnel)
- Build 1 Laboratory (tech unlock)
- Build Hangar (craft capacity)
- Build Radar (essential detection)

**Mid Game (Months 4-8):**
- Add 1-2 more Living Quarters
- Add Laboratory or Workshop (choose priority)
- Add Storage (manage inventory)
- Add Defense (base protection)

**Late Game (Months 9+):**
- Maximize research & manufacturing
- Multiple bases with specialization
- Heavy defense infrastructure
- Redundancy for important facilities

---

## Capacity Scaling Example

**Base Progression:**

| Stage | Personnel | Storage | Research | Manufacturing | Craft |
|-------|-----------|---------|----------|----------------|-------|
| Start | 10 | 100 | 0 | 0 | 1 |
| +2LQ, +1Lab | 50 | 100 | 2 | 0 | 1 |
| +Store, +Workshop | 50 | 300 | 2 | 2 | 1 |
| +Hangar, +More | 70 | 500 | 4 | 4 | 5 |
| Full Base | 130 | 900 | 6 | 6 | 9 |

---

## Integration Points

### Basescape Integration
- Facilities define base capabilities
- Storage limits inventory management
- Personnel limits unit recruitment
- Manufacturing produces equipment
- Research unlocks technology

### Economy Integration
- Construction costs resources
- Maintenance consumes credits monthly
- Damaged facilities reduce efficiency
- Facility upgrades improve production

### Battlescape Integration
- Base facilities appear in base defense missions
- Facility positions on base map
- Destructible during interception
- Player defense positions around facilities

---

## Configuration & Modding

### Creating Custom Facilities

Define facilities in `mods/core/content/facilities/*.toml`:

```toml
[facility]
id = "advanced_laboratory"
name = "Advanced Laboratory"
build_time = 21
build_cost = 200000
health = 120
armor = 8

[facility.capacities]
research_projects = 3
units = 15

[facility.services]
provides = ["research"]
requires = ["power"]

maintenance = 12000
```

### Facility Upgrades

Define upgrades in `mods/core/content/upgrades/*.toml`:

```toml
[upgrade]
id = "lab_efficiency_1"
name = "Laboratory Efficiency Upgrade"
facility_type = "laboratory"
bonus_type = "research_speed"
bonus_value = 1.25  # 25% faster
cost = 50000
```

---

## See Also

- `docs/basescape/README.md` - Basescape overview
- `docs/economy/marketplace.md` - Resource management
- `docs/content/crafts.md` - Craft system and hangars
- `wiki/API.md` - Full Facilities API reference
