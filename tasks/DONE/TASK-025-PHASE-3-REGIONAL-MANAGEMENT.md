# TASK-025 Phase 3: Regional Management

**Status:** ✅ COMPLETE
**Estimated:** 15 hours
**Start Date:** October 24, 2025
**Completion Date:** October 24, 2025

---

## Overview

Build the regional control system to manage countries, territories, and factions. Implement region controllers, control tracking, infrastructure management, and faction relations. All regions created in Phase 2 will be elevated from passive data to active systems.

**Deliverables:**
- `engine/geoscape/regions/region.lua` (150 lines)
- `engine/geoscape/regions/region_controller.lua` (180 lines)
- `engine/geoscape/regions/control_tracker.lua` (120 lines)
- `engine/geoscape/regions/infrastructure.lua` (100 lines)
- `engine/geoscape/regions/faction_relations.lua` (140 lines)
- Performance: <50ms per-turn update
- Test suite: 15+ tests covering all systems

---

## Requirements

### Functional Requirements

1. **Region Management**
   - Load regions from Phase 2 generation
   - Track region properties (name, control, stability)
   - Per-turn region updates
   - Support for player bases within regions

2. **Control Tracking**
   - Three control states: player, alien, neutral
   - Track control percentage per region
   - Control transfer mechanics
   - Terror/mission effects on control

3. **Infrastructure System**
   - Development level (0-1 scale)
   - Population management
   - Economy per region (income/expenditure)
   - Facility presence tracking
   - Recovery/degradation mechanics

4. **Faction Relations**
   - Relations matrix between regions (-1.0 to 1.0)
   - Diplomacy modifiers
   - Alliance/enemy tracking
   - Relation changes from events

### Technical Requirements

- Integration with Phase 2 world (location data)
- Efficient per-turn updates (<50ms)
- Persistent state for save/load
- Deterministic for replays
- Support for 15-20 simultaneous regions

---

## Detailed Plan

### Phase 3.1: Region Class (3 hours)

**Region class** - Core region entity

```lua
-- engine/geoscape/regions/region.lua

Region = {
    id = 1,
    name = "North America",
    capital_x = 40,
    capital_y = 20,
    faction = "player",  -- or faction name

    -- Control & stability
    control = "player",
    control_pct = 0.8,
    stability = 0.7,      -- 0-1, affects income
    terror_level = 0.2,   -- 0-1, affects control

    -- Population & infrastructure
    population = 50000000,
    population_morale = 0.6,  -- 0-1

    infrastructure = {
        development = 0.6,    -- 0-1
        military_strength = 0.4,  -- 0-1
        tech_level = 0.5,     -- 0-1
    },

    -- Economy
    economy = {
        income = 1000,        -- Credits per turn
        expenditure = 800,    -- Maintenance
        balance = 200,        -- Net
    },

    -- Facilities/bases
    bases = {},   -- List of base IDs in region

    -- Relations with other regions
    relations = {}  -- {region_id -> (-1.0 to 1.0)}
}

function Region.new(id, name, faction)
    -- Initialize region with default values
end

function Region:update(turn)
    -- Per-turn updates:
    -- • Calculate income
    -- • Apply recovery/degradation
    -- • Update stability from events
    -- • Process population changes
end

function Region:applyDamage(damage_type, severity)
    -- terror_attack, bombardment, infestation
    -- Reduce population/infrastructure/control
end

function Region:getStrategicValue()
    -- Return 0-100 value score for AI targeting
end
```

**Deliverables:**
- Region class with full property system
- Per-turn update mechanics
- Damage application system
- Value calculation for AI

### Phase 3.2: Region Controller (4 hours)

**RegionController class** - Manager for all regions

```lua
-- engine/geoscape/regions/region_controller.lua

RegionController = {}

function RegionController.new(world, location_system)
    -- Initialize from world regions
    -- Create Region instances for each generated region
end

function RegionController:getRegion(id)
    -- Return Region object
end

function RegionController:getAllRegions()
    -- Return all Region objects
end

function RegionController:getRegionAt(x, y)
    -- Return Region containing province (x, y)
end

function RegionController:getRegionsByFaction(faction)
    -- Return all regions controlled by faction
end

function RegionController:update(turn)
    -- Update all regions
    -- Calculate turn income
    -- Apply standing effects
end

function RegionController:transferControl(region_id, from_faction, to_faction)
    -- Handle control change
    -- Adjust control_pct, stability, population_morale
end

function RegionController:addBase(region_id, base_id)
    -- Register player base in region
end

function RegionController:getEconomicSummary()
    -- Return total income/expenditure across all regions
end
```

**Deliverables:**
- RegionController orchestrator
- Region initialization from Phase 2
- Faction queries
- Economic summary system
- Base registration

### Phase 3.3: Control Tracking (3 hours)

**ControlTracker class** - Track control transitions

```lua
-- engine/geoscape/regions/control_tracker.lua

ControlTracker = {}

function ControlTracker.new(region_controller)
    return {
        regions = region_controller,
        control_history = {},  -- Track changes
    }
end

function ControlTracker:setControl(region_id, faction, reason)
    -- Change region control
    -- Record history entry
    -- Trigger events
end

function ControlTracker:getControl(region_id)
    -- Return current faction controlling region
end

function ControlTracker:getControlPercentage(region_id, faction)
    -- Return control % for faction (0-1)
end

function ControlTracker:updateControlPercentage(region_id, faction, delta)
    -- Adjust control by amount
    -- Rebalance if exceeds 100%
end

function ControlTracker:getControlHistory(region_id, turns)
    -- Return control changes over past N turns
end

function ControlTracker:getHistory()
    -- Return all control changes
end
```

**Deliverables:**
- ControlTracker class
- Control state management
- History recording
- Faction queries

### Phase 3.4: Infrastructure System (3 hours)

**Infrastructure class** - Manage region development

```lua
-- engine/geoscape/regions/infrastructure.lua

Infrastructure = {}

function Infrastructure.new(initial_development)
    return {
        development = initial_development,  -- 0-1
        military_strength = initial_development * 0.8,
        tech_level = initial_development * 0.6,
    }
end

function Infrastructure:update(region_stability, player_investment)
    -- Per-turn changes:
    -- • Growth rate based on stability
    -- • Player investment acceleration
    -- • Damage recovery mechanics
end

function Infrastructure:applyDamage(damage_type, severity)
    -- Reduce development based on damage type
end

function Infrastructure:getIncomeModifier()
    -- Return income multiplier based on development
end

function Infrastructure:getMilitaryModifier()
    -- Return military strength multiplier
end

function Infrastructure:getTechModifier()
    -- Return tech level for research
end
```

**Deliverables:**
- Infrastructure class
- Development progression system
- Damage mechanics
- Modifier calculations

### Phase 3.5: Faction Relations (2 hours)

**FactionRelations class** - Diplomacy system

```lua
-- engine/geoscape/regions/faction_relations.lua

FactionRelations = {}

function FactionRelations.new(regions)
    -- Initialize empty relations matrix
    -- All start at 0 (neutral)
end

function FactionRelations:setRelation(region1, region2, relation)
    -- Set relation (-1.0 to 1.0)
    -- Negative = hostile, Positive = ally
end

function FactionRelations:getRelation(region1, region2)
    -- Return current relation
end

function FactionRelations:modifyRelation(region1, region2, delta)
    -- Adjust relation by amount (clamped -1 to 1)
    -- Triggered by events
end

function FactionRelations:getAllyRegions(region_id)
    -- Return regions allied (relation > 0.5)
end

function FactionRelations:getEnemyRegions(region_id)
    -- Return regions hostile (relation < -0.5)
end

function FactionRelations:getDiplomaticValue(region_id)
    -- Return 0-100 diplomacy score
end
```

**Deliverables:**
- FactionRelations class
- Relation tracking
- Ally/enemy queries
- Diplomacy modifiers

---

## Implementation Checklist

- [ ] **Region class** - Core entity with all properties
  - [ ] `new()` - Initialize from region data
  - [ ] `update(turn)` - Per-turn calculations
  - [ ] `applyDamage()` - Damage handling
  - [ ] `getStrategicValue()` - AI targeting

- [ ] **RegionController class** - Manager
  - [ ] `new()` - Initialize from Phase 2 regions
  - [ ] `getRegion()` / `getAllRegions()`
  - [ ] `getRegionsByFaction()` - Faction queries
  - [ ] `update()` - Orchestrate all updates
  - [ ] `transferControl()` - Control changes
  - [ ] `addBase()` - Player base tracking

- [ ] **ControlTracker class** - Control state
  - [ ] `setControl()` - Change control
  - [ ] `getControl()` / `getControlPercentage()`
  - [ ] `updateControlPercentage()` - Adjust %
  - [ ] History recording

- [ ] **Infrastructure class** - Development
  - [ ] `new()` - Initialize
  - [ ] `update()` - Per-turn progression
  - [ ] `applyDamage()` - Damage handling
  - [ ] Modifier calculations

- [ ] **FactionRelations class** - Diplomacy
  - [ ] `setRelation()` / `getRelation()`
  - [ ] `modifyRelation()` - Dynamic changes
  - [ ] `getAllyRegions()` / `getEnemyRegions()`
  - [ ] Diplomacy scoring

- [ ] **Integration**
  - [ ] Load regions from Phase 2 world
  - [ ] Connect to player base system
  - [ ] Connect to turn system
  - [ ] Connect to economy system

- [ ] **Tests** (15+ tests)
  - [ ] Region initialization (3 tests)
  - [ ] RegionController (3 tests)
  - [ ] Control tracking (3 tests)
  - [ ] Infrastructure (3 tests)
  - [ ] FactionRelations (3 tests)

---

## Success Criteria

✅ Regions initialize from Phase 2 data
✅ Control tracking system functional
✅ Infrastructure system with progression
✅ Faction relations tracking
✅ <50ms per-turn update time
✅ All 15+ tests passing
✅ No lint errors
✅ Exit Code 0

---

## Integration Points

**Input:** Phase 2 world data (regions, locations, provinces)
**Output:** Region state for Phase 4 (Faction & Mission System)

**Dependencies:**
- Phase 2 world generation (complete)
- Time system (from Phase 2)
- Economy system (exists)
- Base system (exists)

**Next Phase:**
Phase 4 (Faction & Mission System) - 20 hours
- Alien faction activity
- UFO tracking and interception
- Terror missions and events
- Mission generation

---

**Created:** October 24, 2025
**Phase Start:** October 24, 2025
