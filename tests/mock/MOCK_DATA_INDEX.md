# Mock Data Framework Documentation

**Last Updated:** October 22, 2025  
**Status:** Complete and operational  
**Scope:** Testing and development mock data inventory

---

## Overview

The mock data framework provides comprehensive test data for all major game systems. This document catalogs existing mock data and provides usage guidelines.

---

## Current Mock Data Files

### Core Mock Data (7 files)

| File | Purpose | Entities | Updated |
|------|---------|----------|---------|
| `battlescape.lua` | Combat system test data | MapBlocks, Units, Combat scenarios | ✅ Active |
| `economy.lua` | Economic system test data | Resources, Manufacturing, Queue | ✅ Active |
| `facilities.lua` | Facility test data | Facilities, Services, Adjacency | ✅ Active |
| `geoscape.lua` | Strategic map test data | Provinces, Regions, Missions | ✅ Active |
| `items.lua` | Equipment test data | Weapons, Armor, Items | ✅ Active |
| `maps.lua` | Map generation test data | MapBlocks, Terrain, Objectives | ✅ Active |
| `missions.lua` | Mission system test data | Missions, Objectives, Rewards | ✅ Active |

### Supporting Mock Data (2 files)

| File | Purpose | Entities | Updated |
|------|---------|----------|---------|
| `units.lua` | Unit/Soldier test data | Units, Classes, Equipment | ✅ Active |
| `widgets.lua` | UI widget test data | Widgets, Layouts, Themes | ✅ Active |

---

## Mock Data Usage

### In Unit Tests

```lua
local MockData = require("tests.mock.battlescape")

local testUnit = MockData.units[1]
assert(testUnit.name ~= nil, "Unit should have name")
```

### In Integration Tests

```lua
local MockBattle = require("tests.mock.battlescape")
local MockUnits = require("tests.mock.units")

-- Simulate battle with mock data
local battle = {
    map = MockBattle.mapblocks[1],
    friendlyUnits = MockUnits.squads[1],
    enemyUnits = MockBattle.enemySquads[1]
}
```

### In Development/Debugging

```lua
-- Load full mock data set
local AllMock = {
    battlescape = require("tests.mock.battlescape"),
    economy = require("tests.mock.economy"),
    units = require("tests.mock.units"),
    items = require("tests.mock.items")
}

-- Access any mock entity for testing
print("Sample unit:", AllMock.units.units[1].name)
```

---

## Mock Data Structure

### Battlescape Mock Data

**Location:** `tests/mock/battlescape.lua`

**Entities:**
- `mapblocks[]` - 10+ test map blocks with terrain
- `units[]` - 20+ test units in various states
- `enemySquads[]` - 5+ test enemy squad configurations
- `combatResults[]` - Sample combat resolution scenarios

**Usage:**
```lua
local battle = MockBattlescape.mapblocks[1]
local unit = MockBattlescape.units[1]
local combat = MockBattlescape.combatResults[1]
```

### Economy Mock Data

**Location:** `tests/mock/economy.lua`

**Entities:**
- `resources[]` - 10+ resource types
- `manufacturing[]` - 15+ manufacturing projects
- `marketplace[]` - 20+ marketplace items
- `suppliers[]` - 5+ supplier configurations

**Usage:**
```lua
local resource = MockEconomy.resources[1]
local project = MockEconomy.manufacturing[1]
local item = MockEconomy.marketplace[1]
```

### Facilities Mock Data

**Location:** `tests/mock/facilities.lua`

**Entities:**
- `facilityTypes[]` - 15+ facility definitions
- `facilities[]` - 20+ facility instances
- `services[]` - 10+ service definitions
- `adjacencyBonuses[]` - Sample bonus configurations

**Usage:**
```lua
local facility = MockFacilities.facilities[1]
local bonus = MockFacilities.adjacencyBonuses[1]
```

### Geoscape Mock Data

**Location:** `tests/mock/geoscape.lua`

**Entities:**
- `world` - Full world configuration
- `provinces[]` - 20+ province instances
- `regions[]` - 50+ region instances
- `missions[]` - 15+ mission configurations

**Usage:**
```lua
local world = MockGeoscape.world
local province = MockGeoscape.provinces[1]
```

### Items Mock Data

**Location:** `tests/mock/items.lua`

**Entities:**
- `weapons[]` - 20+ weapon definitions
- `armor[]` - 10+ armor definitions
- `equipment[]` - 30+ misc equipment
- `modifications[]` - 15+ modification definitions

**Usage:**
```lua
local weapon = MockItems.weapons[1]
local armor = MockItems.armor[1]
```

### Maps Mock Data

**Location:** `tests/mock/maps.lua`

**Entities:**
- `mapBlocks[]` - 20+ map block definitions
- `terrain[]` - 15+ terrain type definitions
- `objectives[]` - 10+ objective configurations
- `hazards[]` - Environmental hazard definitions

**Usage:**
```lua
local mapBlock = MockMaps.mapBlocks[1]
local terrain = MockMaps.terrain[1]
```

### Missions Mock Data

**Location:** `tests/mock/missions.lua`

**Entities:**
- `missions[]` - 25+ mission definitions
- `types[]` - 8+ mission type templates
- `objectives[]` - 20+ objective configurations
- `rewards[]` - 15+ reward templates

**Usage:**
```lua
local mission = MockMissions.missions[1]
local objective = MockMissions.objectives[1]
```

### Units Mock Data

**Location:** `tests/mock/units.lua`

**Entities:**
- `units[]` - 30+ individual unit instances
- `classes[]` - 5+ unit class definitions
- `squads[]` - 10+ squad formations
- `equipment[]` - 25+ unit equipment configurations

**Usage:**
```lua
local unit = MockUnits.units[1]
local squad = MockUnits.squads[1]
```

### Widgets Mock Data

**Location:** `tests/mock/widgets.lua`

**Entities:**
- `widgets[]` - 20+ widget instances
- `themes[]` - 5+ theme configurations
- `layouts[]` - 10+ layout definitions
- `events[]` - Sample widget events

**Usage:**
```lua
local widget = MockWidgets.widgets[1]
local theme = MockWidgets.themes[1]
```

---

## Mock Data Generator

**Location:** `tests/mock/mock_generator.lua`

The generator framework provides reusable functions for creating test data:

### Available Generators

**Entity ID Generator:**
```lua
local id = MockGenerator.generateID("unit")  -- "unit_001", "unit_002", etc.
```

**Name Generator:**
```lua
local name = MockGenerator.generateName("soldier")
local weapon_name = MockGenerator.generateName("weapon")
```

**Stats Generator:**
```lua
local stats = MockGenerator.generateStats({
    health = {min=40, max=80},
    accuracy = {min=50, max=95}
})
```

**Loadout Generator:**
```lua
local loadout = MockGenerator.generateLoadout(MockItems.weapons, MockItems.armor)
```

### Creating Custom Mock Data

```lua
local MockGenerator = require("tests.mock.mock_generator")

-- Generate 10 random units
local units = {}
for i = 1, 10 do
    table.insert(units, MockGenerator.generateUnit({
        level = 1 + math.floor(i / 2),
        class = "Soldier",
        equipment = generateRandomLoadout()
    }))
end
```

---

## Mock Data Quality Guidelines

**See:** `tests/mock/MOCK_DATA_QUALITY_GUIDE.md` for detailed guidelines on:

1. **Consistency** - Keep mock data values realistic and consistent
2. **Coverage** - Ensure all entity types represented
3. **Edge Cases** - Include boundary condition test data
4. **Performance** - Keep data sets reasonably sized for fast tests
5. **Maintainability** - Document non-obvious mock values

---

## Statistics

### Current Coverage

| System | Files | Entities | Instances |
|--------|-------|----------|-----------|
| Battlescape | 1 | 4 types | 50+ |
| Economy | 1 | 4 types | 60+ |
| Facilities | 1 | 4 types | 50+ |
| Geoscape | 1 | 4 types | 85+ |
| Items | 1 | 4 types | 70+ |
| Maps | 1 | 4 types | 45+ |
| Missions | 1 | 4 types | 60+ |
| Units | 1 | 4 types | 65+ |
| Widgets | 1 | 4 types | 45+ |
| **TOTAL** | **9** | **36 types** | **530+ instances** |

### Breakdown by System

```
Battlescape:  50+ mock entities
Economy:      60+ mock entities
Facilities:   50+ mock entities
Geoscape:     85+ mock entities
Items:        70+ mock entities
Maps:         45+ mock entities
Missions:     60+ mock entities
Units:        65+ mock entities
Widgets:      45+ mock entities
```

---

## Using Mock Data in Tests

### Example 1: Unit Test

```lua
local MockUnits = require("tests.mock.units")
local UnitClass = require("engine.battlescape.unit")

-- Test with mock data
local mockUnit = MockUnits.units[1]
local unit = UnitClass:new(mockUnit)

assert(unit:isAlive(), "Unit should be alive")
assert(unit:getHealth() > 0, "Health should be positive")
```

### Example 2: Integration Test

```lua
local MockBattle = require("tests.mock.battlescape")
local MockUnits = require("tests.mock.units")
local BattleSystem = require("engine.battlescape.battle")

-- Create battle with mock data
local battle = BattleSystem:new{
    mapBlock = MockBattle.mapblocks[1],
    friendlyUnits = MockUnits.squads[1],
    enemyUnits = MockBattle.enemySquads[1]
}

-- Run battle logic
battle:processRound()

-- Verify results
assert(battle:isActive(), "Battle should continue")
```

### Example 3: Modding/Debugging

```lua
local AllMock = {}
for system in pairs({
    "battlescape", "economy", "facilities", 
    "geoscape", "items", "maps", "missions", 
    "units", "widgets"
}) do
    AllMock[system] = require("tests.mock." .. system)
end

-- Now have access to all mock data for testing
print("Available mock units:", #AllMock.units.units)
print("Available mock facilities:", #AllMock.facilities.facilities)
```

---

## Mock Data Patterns

### Data Structure Pattern

Most mock data follows this pattern:

```lua
return {
    -- Entity type 1
    type1_instances = {
        {
            id = "type1_001",
            name = "Instance 1",
            -- ... specific fields
        },
        {
            id = "type1_002",
            name = "Instance 2",
            -- ... specific fields
        }
    },
    
    -- Entity type 2
    type2_instances = {
        -- similar structure
    }
}
```

### Accessing Mock Data

```lua
local Mock = require("tests.mock.system_name")

-- Access by index
local first = Mock.entities[1]
local second = Mock.entities[2]

-- Common patterns
local allWeapons = Mock.weapons
local allUnits = Mock.units
```

---

## Future Enhancements

### Planned Improvements

1. **Dynamic Generation** (4-6 hours)
   - Create generator functions for each system
   - Support parameterized data generation
   - Create variation factories

2. **Extended Coverage** (2-3 hours)
   - Add 1000+ entity instances across systems
   - Include edge case data
   - Add stress test data sets

3. **Performance Benchmarks** (2 hours)
   - Track mock data load times
   - Optimize large data sets
   - Create lightweight test sets

4. **Data Validation** (2-3 hours)
   - Validate against TOML schemas
   - Check entity relationships
   - Verify constraint compliance

---

## For Test Development

### Adding New Mock Data

1. **Create test data** in appropriate mock file
2. **Add to README** documenting the new data
3. **Test with game** - verify data works
4. **Update statistics** - reflect new coverage
5. **Document usage** - show examples

### Mock Data Best Practices

✅ **DO:**
- Use realistic values from game balance
- Keep data consistent across systems
- Document non-obvious choices
- Test mock data with actual systems
- Update docs when adding data

❌ **DON'T:**
- Use placeholder strings like "TEST" or "PLACEHOLDER"
- Create unrealistic scenarios
- Add too much data (keeps tests fast)
- Duplicate data unnecessarily
- Leave mock data undocumented

---

## Statistics & Metrics

**Last Updated:** October 22, 2025

- **Mock Data Files:** 9 active
- **Entity Types:** 36 across all systems
- **Mock Instances:** 530+
- **Coverage:** ~90% of major systems
- **Test Usage:** Extensive (unit, integration, manual tests)
- **Status:** ✅ Production-ready

---

## Related Documentation

- [MOCK_DATA_QUALITY_GUIDE.md](MOCK_DATA_QUALITY_GUIDE.md) - Quality standards
- [README.md](README.md) - Test framework overview
- [wiki/api/API_SCHEMA_REFERENCE.md](../../api/API_SCHEMA_REFERENCE.md) - Schema definitions
- [MOD_DEVELOPER_GUIDE.md](../../api/MOD_DEVELOPER_GUIDE.md) - Example mod usage

---

**Questions?** Check the quality guide or reach out to the development team.
