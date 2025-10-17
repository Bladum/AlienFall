# Craft System

> **Implementation**: `../../../engine/core/crafts/craft.lua`, `../../../engine/geoscape/`
> **Tests**: `../../../tests/` (craft-related tests)
> **Related**: `docs/geoscape/missions.md`, `docs/battlescape/weapons.md`

Crafts are the primary means by which players respond to threats and deploy forces across the geoscape. Each craft represents a vehicle (interceptor, transport, scout) with its own operational capabilities, crew, and equipment.

---

## Overview

The craft system manages:
- **Craft Types**: Interceptor, Transport, Scout variants with distinct roles
- **Movement**: Geoscape travel between provinces with fuel consumption
- **Crew Management**: Personnel assignment and load-outs
- **Equipment**: Weapons, armor, and cargo management
- **Status Tracking**: Fuel, damage, availability, and maintenance

---

## Craft Architecture

### Core Components

#### Craft Data Model
```lua
Craft = {
    id = "craft_1",              -- Unique identifier
    name = "Skyranger-1",        -- Display name
    type = "transport",          -- Craft type (transport, interceptor, scout)
    
    -- Location
    provinceId = "province_23",  -- Current province
    baseId = "base_1",           -- Home base
    
    -- Travel
    isDeployed = false,          -- Currently traveling
    path = {},                   -- Planned path
    pathIndex = 0,               -- Current position
    travelTime = 0,              -- Days to next province
    
    -- Capabilities
    speed = 1,                   -- Provinces per day
    range = 10,                  -- Max travel distance
    fuelCapacity = 100,          -- Maximum fuel
    currentFuel = 100,           -- Current fuel
    fuelConsumption = 1,         -- Fuel per province
    
    -- Loadout
    soldiers = {},               -- Assigned crew
    items = {}                   -- Equipment and cargo
}
```

#### Craft Types
Each craft type has distinct characteristics suited to different mission types:

**Transport (Skyranger)**
- **Role**: Troop deployment, cargo transport
- **Speed**: Slow (0.5 provinces/day)
- **Capacity**: 14-20 soldiers
- **Range**: 20+ provinces
- **Weapons**: Limited defensive armament
- **Best For**: Large-scale ground operations, supply missions

**Interceptor (Firestorm)**
- **Role**: UFO interception, combat
- **Speed**: Fast (2+ provinces/day)
- **Capacity**: 2-4 pilots/crew
- **Range**: 30+ provinces
- **Weapons**: Primary weapon slots (heavy cannons, missile pods)
- **Best For**: Air-to-air combat, rapid response

**Scout (Avenger)**
- **Role**: Reconnaissance, fast response
- **Speed**: Medium (1.5 provinces/day)
- **Capacity**: 6-8 soldiers
- **Range**: 25+ provinces
- **Weapons**: Light armament
- **Best For**: Quick response, scouting missions

---

## Core Systems

### Movement System

#### Deployment
Crafts deploy along a planned path from their current location to a target province.

```lua
-- Deploy craft to target
local path = {"province_1", "province_5", "province_12"}
local deployed = craft:deploy(path)

-- If deployed successfully:
-- - Fuel is reserved for the journey
-- - Travel time is calculated
-- - Craft becomes unavailable until arrival
```

**Fuel Calculation:**
```
fuelRequired = (pathLength - 1) × fuelConsumption
```

**Travel Time:**
```
travelTime = 1 / speed   -- Repeats for each province
```

#### Travel Phases
1. **Pre-Deployment**: Craft at base, crew assigned, ready
2. **En Route**: Traveling between provinces, fuel consuming
3. **Arrival**: Reached destination, becomes available for missions
4. **Return**: Optional travel back to base for refueling

### Crew Management

#### Crew Assignment
Soldiers are assigned to crafts for deployment on missions.

**Assignment Rules:**
- Crew capacity varies by craft type
- Only healthy, trained soldiers can be assigned
- Assignment persists until craft returns to base
- Crew members take part in resulting battlescape mission

**Personnel Roles:**
- **Pilot**: Flies the craft (1-2 per craft)
- **Soldiers**: Combat personnel (varies by mission)
- **Specialists**: Scientists, engineers for special missions
- **Medics**: Provide healing support during missions

#### Crew Experience
- Soldiers gain experience from combat missions
- Experience improves stats and unlock abilities
- Veteran crews have better morale and performance

### Equipment System

#### Weapon Mounts
Crafts have weapon hardpoints for armament.

**Interceptor Weapons:**
- Primary cannons (2-4 heavy weapons)
- Missile pods (additional firepower)
- Targeting systems (accuracy bonuses)
- Armor upgrades

**Transport Weapons:**
- Defensive turrets (1-2 light weapons)
- Limited offensive capability
- Focus on durability

**Scout Weapons:**
- Medium weapons (1-2 slots)
- Balanced offense/defense
- Speed over firepower

#### Cargo Management
Transports and scouts can carry cargo/supplies.

**Cargo Types:**
- **Equipment**: Weapons, armor for soldiers
- **Supplies**: Medical kits, ammo, resources
- **Modules**: Research items, alien artifacts
- **Personnel**: Scientists, specialists

**Cargo Capacity:**
```
cargoSlots = craftCapacity - crewCount
```

### Fuel & Range System

#### Fuel Mechanics
- Crafts consume fuel during travel
- Range limited by fuel capacity and consumption rate
- Out-of-fuel = stranded in province
- Refueling at bases only

**Fuel Calculations:**
```
rangeInProvinces = fuelCapacity / fuelConsumption
travelCost = distanceInProvinces × fuelConsumption
```

#### Refueling
- Automatic at home base after return
- Can refuel at allied bases (if available)
- Refueling takes 1 day per 50 fuel
- Out of fuel requires extraction

### Status & Maintenance

#### Craft Damage
- Taken during combat and interception
- Reduces stats (speed, accuracy, capacity)
- Requires repair at base

**Damage States:**
- **Operational**: 100% health, full capability
- **Damaged**: 50-99% health, reduced performance
- **Critical**: 10-49% health, minimal capability
- **Destroyed**: 0% health, craft lost

#### Repair System
- Damaged crafts repair automatically at base
- Repair costs resources and time
- Faster repair with better facilities
- Can assign dedicated repair crews

**Repair Rate:**
```
healthPerDay = baseRepairRate + crewBonus
```

---

## Craft Capabilities

### Operational Range
Maximum distance craft can travel.

| Craft Type | Unupgraded | Upgraded | Special |
|-----------|-----------|-----------|---------|
| **Transport** | 20 | 30 | Can carry supplies |
| **Interceptor** | 30 | 50 | Fastest craft |
| **Scout** | 25 | 40 | Stealth modules |

### Speed Ratings
Travel speed in provinces per day.

| Craft Type | Base | With Upgrades |
|-----------|------|---------------|
| **Transport** | 0.5 | 0.75 |
| **Interceptor** | 2.0 | 2.5+ |
| **Scout** | 1.5 | 2.0 |

### Capacity Metrics

| Metric | Transport | Interceptor | Scout |
|--------|-----------|-------------|-------|
| **Crew Slots** | 14-20 | 2-4 | 6-8 |
| **Cargo Slots** | 10-15 | 0-2 | 4-6 |
| **Weapon Slots** | 1-2 | 3-4 | 2-3 |
| **Health** | 150-200 | 80-120 | 100-150 |

---

## Craft Progression

### Tech Tree
Crafts improve through research and manufacturing.

**Phase Progression:**
- **Phase 0**: Ballistic weapons, basic frames
- **Phase 1**: Laser cannons, armor upgrades
- **Phase 2**: Plasma weapons, advanced electronics
- **Phase 3**: Particle beams, dimensional armor

### Upgrades
- **Speed Upgrades**: Reduce travel time
- **Armor Upgrades**: Increase health
- **Fuel Upgrades**: Extend range
- **Weapon Upgrades**: Improve firepower
- **Module Upgrades**: Add special capabilities

### Experience & Veterancy
- Pilots and crews gain experience
- Increases crew effectiveness and loyalty
- Veteran crews have stat bonuses
- Transfer knowledge to new recruits

---

## Craft Roles & Tactics

### Transport Role
**Primary Mission**: Deploying forces for ground combat

**Tactical Use:**
- Deploy full squads (10-14 soldiers)
- Slow but reliable
- Can carry supplies and equipment
- Primary means of intervention

**Best Scenarios:**
- Ground-based terror missions
- Base defense
- Large UFO crash sites
- Supply delivery

### Interceptor Role
**Primary Mission**: UFO interception and air combat

**Tactical Use:**
- Rapid response to UFO activity
- 1v1 or small group combat
- Heavy firepower
- Limited deployment capability

**Best Scenarios:**
- UFO interception
- Craft-to-craft combat
- Rapid response to critical threats
- UFO hunts

### Scout Role
**Primary Mission**: Reconnaissance and quick response

**Tactical Use:**
- Fast medium-capacity deployment
- Balanced offense and defense
- Can scout terrain
- Secondary interception capability

**Best Scenarios:**
- Fast response missions
- Scouting operations
- Medium-scale deployments
- Supply runs

---

## Integration Points

### Geoscape Integration
- Craft availability affects mission response time
- Multiple crafts enable simultaneous operations
- Craft movement visualized on world map
- UFO interception triggered by craft proximity

### Battlescape Integration
- Craft determines squad composition
- Equipment loadout carried into battle
- Crew experience carries over
- Return to craft for extraction

### Economy Integration
- Craft maintenance costs resources
- Fuel consumption affects operational costs
- Upgrades require research and manufacturing
- Damaged crafts reduce capacity

### Interception Integration
- Craft engages UFOs detected on geoscape
- Interception determines battlescape deployment
- Craft damage carries over between battles
- Victory/defeat affects operational capability

---

## Examples

### Example 1: Basic Transport Deployment
```lua
-- Create transport craft
local transport = Craft.new({
    id = "transport_1",
    name = "Skyranger-1",
    type = "transport",
    provinceId = "base_province",
    speed = 0.5,
    range = 20,
    fuelCapacity = 100,
    currentFuel = 100,
    fuelConsumption = 1
})

-- Assign squad
local squad = {soldier1, soldier2, soldier3, ...}
transport:assignCrew(squad)

-- Deploy to mission location
local path = {"prov_1", "prov_5", "prov_12"}
transport:deploy(path)
-- Takes 2 days to arrive (3 provinces - 1)
```

### Example 2: Interceptor Pursuit
```lua
-- Create interceptor
local interceptor = Craft.new({
    id = "interceptor_1",
    name = "Firestorm-1",
    type = "interceptor",
    speed = 2.0,
    range = 30,
    fuelCapacity = 150
})

-- Pursue UFO
local path = {"prov_15", "prov_18", "prov_21"}
interceptor:deploy(path)
-- Arrives in 1.5 days (much faster)
```

### Example 3: Fuel Management
```lua
-- Check if mission is achievable
local distance = #pathProvinces - 1
local fuelNeeded = distance * craft.fuelConsumption

if fuelNeeded > craft.currentFuel then
    -- Insufficient fuel - refuel first
    craft:refuel()
    craft:deploy(path)
else
    -- Enough fuel - deploy
    craft:deploy(path)
end

-- After mission
craft.currentFuel = craft.currentFuel - fuelNeeded
```

---

## Configuration & Modding

### Creating Custom Crafts
Define crafts in `mods/core/content/crafts/*.toml`:

```toml
[craft]
id = "custom_transport"
name = "Heavy Transport"
type = "transport"
speed = 0.6
range = 25
fuel_capacity = 120
crew_capacity = 20
cargo_slots = 12
weapons_slots = 2
health = 200
```

### Craft Upgrades
Upgrades defined in `mods/core/content/upgrades/*.toml`:

```toml
[upgrade]
id = "transport_speed_1"
name = "Advanced Engines"
craft_type = "transport"
effect = "speed_boost"
bonus = 1.2  -- 20% speed increase
```

---

## Performance Considerations

- **Movement Calculations**: O(1) per craft per day
- **Crew Management**: O(n) where n = crew count
- **Pathfinding**: Uses simple path (not dynamic routing)
- **Fuel Tracking**: Simple per-province consumption

---

## Known Limitations & Future Enhancements

- **Current**: Simple linear paths, no dynamic routing
- **Future**: Realistic flight paths considering geography
- **Current**: No fuel stops or intermediate bases
- **Future**: Emergency landings and rescue mechanics
- **Current**: Basic crew assignment
- **Future**: Crew rotation and morale tracking
- **Current**: No craft customization UI
- **Future**: Advanced loadout configuration

---

## See Also

- `docs/geoscape/missions.md` - Mission system integration
- `docs/geoscape/world.md` - World map and movement
- `docs/battlescape/weapons.md` - Weapon systems
- `docs/economy/marketplace.md` - Craft procurement
- `wiki/API.md` - Full Craft API reference
