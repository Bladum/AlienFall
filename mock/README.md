# Mock Data

Mock data generators for testing XCOM Simple systems.

## Purpose

This folder contains reusable mock data generators for all test suites. Instead of creating test data inline in each test file, use these centralized mock generators for consistency and maintainability.

## Files

### `mock_data.lua`
Original widget mock data generator (moved from `engine/widgets/core/`).
- Generates mock data for UI widget testing
- List items, grid items, form fields, etc.

### `units.lua`
Mock unit/soldier data for combat and roster tests.
- `getSoldier(name, class)` - Individual soldier
- `generateSquad(count)` - Full squad
- `getEnemy(type)` - Enemy unit
- `generateEnemyGroup(count, types)` - Enemy squad
- `getWoundedSoldier(woundLevel)` - Wounded unit
- `getVeteran()` - High-stat veteran

### `items.lua`
Mock equipment and inventory data.
- `getWeapon(type)` - Weapons (PISTOL, RIFLE, SNIPER, etc.)
- `getArmor(type)` - Armor types
- `getGrenade(type)` - Grenades (FRAG, SMOKE, INCENDIARY)
- `getMedkit()` - Medical kit
- `generateLoadout(class)` - Class-specific loadout
- `generateInventory(count)` - Random items

### `missions.lua`
Mock mission and campaign data.
- `getMission(type)` - Missions (SITE, UFO, BASE)
- `generateMissions(count)` - Multiple missions
- `getCampaign()` - Campaign data
- `getObjectives(missionType)` - Mission objectives
- `getBriefing(missionType)` - Complete briefing data

### `maps.lua`
Mock map and battlescape data.
- `getMapConfig(size, biome)` - Map configuration
- `getMapBlock()` - MapBlock data
- `generateTiles(width, height)` - Tile grid
- `getLandingZones(count)` - Landing zones
- `getTileset(biome)` - Tileset data
- `generateTestMap(size)` - Complete test map
- `getGenerationParams()` - Map generation parameters

## Usage Examples

### In Test Runners

```lua
-- tests/runners/run_combat_test.lua
package.path = package.path .. ";../../?.lua"

local MockUnits = require("mock.units")
local MockItems = require("mock.items")
local CombatSystem = require("engine.battlescape.systems.combat_system")

function love.load()
    print("=== Combat System Test ===")
    
    -- Create test units
    local attacker = MockUnits.getSoldier("Attacker", "ASSAULT")
    local target = MockUnits.getEnemy("SECTOID")
    
    -- Equip weapon
    attacker.weapon = MockItems.getWeapon("RIFLE")
    
    -- Run combat test
    local result = CombatSystem.attack(attacker, target)
    assert(result, "Attack failed")
    
    print("✓ Combat test passed!")
    love.event.quit(0)
end
```

### In Unit Tests

```lua
-- tests/unit/test_inventory.lua
local MockItems = require("mock.items")

local TestSuite = {}

function TestSuite.testLoadout()
    local loadout = MockItems.generateLoadout("ASSAULT")
    assert(loadout.primary, "Missing primary weapon")
    assert(loadout.armor, "Missing armor")
    print("✓ Loadout test passed")
end

function TestSuite.runAll()
    print("Running inventory tests...")
    TestSuite.testLoadout()
    print("✓ All tests passed!")
end

return TestSuite
```

### In Integration Tests

```lua
-- tests/integration/test_mission_flow.lua
local MockMissions = require("mock.missions")
local MockUnits = require("mock.units")

function love.load()
    -- Setup mission
    local mission = MockMissions.getMission("UFO")
    local squad = MockUnits.generateSquad(8)
    
    -- Test mission flow
    MissionSystem.start(mission, squad)
    -- ... test mission mechanics
    
    print("✓ Mission flow test passed!")
end
```

## Mock Data Guidelines

### When to Use Mock Data

✅ **DO use mock data for:**
- Unit tests that need soldiers, enemies, equipment
- Integration tests that need complete missions
- UI tests that need sample data
- Performance tests that need large datasets

❌ **DON'T use mock data for:**
- Production game data
- Save game data
- Mod content
- Final game balance testing

### Creating New Mock Data

If you need new mock data types:

1. Create a new file in `mock/` (e.g., `mock/buildings.lua`)
2. Follow the existing pattern:
   - Export a table
   - Provide `get*()` functions for individual items
   - Provide `generate*()` functions for collections
   - Include sensible defaults
3. Add documentation to this README
4. Use in tests via `require("mock.building_name")`

### Mock Data Principles

1. **Realistic but Simple** - Data should be realistic enough to test properly, but simple enough to understand quickly
2. **Consistent** - Use consistent naming, structure, and defaults
3. **Documented** - Include comments explaining what each function returns
4. **Reusable** - Make generators flexible with optional parameters
5. **Fast** - Mock data should generate quickly (no file I/O, no complex algorithms)

## Migration Notes

**October 14, 2025:** Mock data consolidated from:
- `engine/widgets/core/mock_data.lua` → `mock/mock_data.lua`
- New organized mock files created for units, items, missions, maps

All test files should now reference `mock/` instead of creating inline test data.

## Examples of Mock Data Output

### Soldier
```lua
{
    id = 1234,
    name = "Test Soldier",
    class = "ASSAULT",
    rank = "ROOKIE",
    hp = 100,
    maxHp = 100,
    stats = {strength = 50, accuracy = 60, ...}
}
```

### Weapon
```lua
{
    name = "Assault Rifle",
    category = "WEAPON",
    damage = 30,
    accuracy = 70,
    range = 25,
    ammo = 30
}
```

### Mission
```lua
{
    id = 5678,
    name = "Terror Site",
    type = "SITE",
    difficulty = "MEDIUM",
    objectives = {...},
    rewards = {money = 5000, intel = 50}
}
```

## See Also

- `tests/README.md` - Test organization and running tests
- `wiki/DEVELOPMENT.md` - Development guidelines
- `wiki/TESTING.md` - Testing best practices

