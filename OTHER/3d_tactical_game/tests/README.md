# 3D Tactical Game - Test Suite

Comprehensive test suite for the 3D tactical combat game built with Love2D.

## Test Structure

### Unit Tests

Individual component tests for isolated functionality:

- **`test_tile.lua`** - Tests for Tile class
  - Tile creation and properties
  - Terrain types (floor, wall, door)
  - Visibility states per team
  - Occupancy tracking
  - LOS blocking
  - Brightness calculation

- **`test_unit.lua`** - Tests for Unit class
  - Unit creation and initialization
  - Health system (damage, healing, death)
  - Position tracking
  - Action points (if implemented)
  - Team assignment
  - LOS range
  - Update loop

- **`test_team.lua`** - Tests for Team class
  - Team creation
  - Adding/removing units
  - Getting units list
  - Filtering alive units
  - Team colors
  - Multiple teams
  - Update loop

- **`test_visibility.lua`** - Tests for VisibilitySystem
  - Line-of-sight (LOS) calculation
  - Bresenham's algorithm
  - Wall blocking
  - Unit visibility calculation
  - Team visibility aggregation
  - Fog of war states (visible, explored, hidden)
  - Brightness calculation
  - Multi-team visibility

- **`test_maploader.lua`** - Tests for MapLoader
  - Test map generation
  - Map dimensions
  - Tile placement
  - Spawn points
  - PNG loading (if file exists)
  - Color to terrain mapping
  - Border walls
  - Map connectivity

- **`test_inputhandler.lua`** - Tests for InputHandler
  - Input initialization
  - Unit movement controls (WASD)
  - Unit rotation (Q/E)
  - Unit selection cycling (SPACE)
  - Camera following unit
  - Collision detection
  - Keyboard state mocking
  - Mouse tracking

### Integration Tests

- **`test_integration.lua`** - End-to-end scenarios
  - Full game setup (map + teams + units)
  - Game loop simulation
  - Combat scenario
  - Multi-team visibility
  - Unit movement over multiple frames
  - Team elimination
  - Fog of war transitions

## Running Tests

### Method 1: Run All Tests (Recommended)

```bash
# From project root
cd tests
lovec .
```

This will:
1. Load `tests/main.lua` as entry point
2. Execute all test suites
3. Print detailed results
4. Exit with status code (0 = success, 1 = failure)

### Method 2: Run Individual Test Suite

From the Love2D console or by modifying `tests/main.lua`:

```lua
local TestTile = require("tests.test_tile")
TestTile.runAll()
```

### Method 3: Run Specific Test

```lua
local TestTile = require("tests.test_tile")
TestTile.testTileCreation()
TestTile.testWallBlocking()
```

## Test Output

### Successful Run

```
================================================================================
3D TACTICAL GAME - TEST SUITE
================================================================================

### Running Tile Tests ###
Testing Tile creation...
  ✓ Tile creation successful
Testing floor traversability...
  ✓ Floor is traversable and doesn't block LOS
...
=== All Tile Tests Passed ✓ ===

### Running Unit Tests ###
...

================================================================================
TEST SUMMARY
================================================================================

Test Suite Results:
  Tile Tests: PASSED ✓
  Unit Tests: PASSED ✓
  Team Tests: PASSED ✓
  Visibility System Tests: PASSED ✓
  MapLoader Tests: PASSED ✓
  InputHandler Tests: PASSED ✓

Total Test Suites: 6
Passed: 6
Failed: 0
Skipped: 0

🎉 ALL TESTS PASSED! 🎉
================================================================================
```

### Failed Run

```
### Running Tile Tests ###
Testing Tile creation...
  ✓ Tile creation successful
Testing floor traversability...
### Tile Tests: FAILED ✗ ###
Error: tests/test_tile.lua:27: Floor should be traversable

...

TEST SUMMARY
Total Test Suites: 6
Passed: 5
Failed: 1

⚠️  SOME TESTS FAILED ⚠️
```

## Writing New Tests

### Test Module Template

```lua
local TestMyFeature = {}

function TestMyFeature.testSomething()
    print("Testing something...")
    
    -- Arrange
    local obj = MyClass.new()
    
    -- Act
    local result = obj:doSomething()
    
    -- Assert
    assert(result == expected, "Result should match expected")
    
    print("  ✓ Something works")
end

function TestMyFeature.runAll()
    print("\n=== Running MyFeature Tests ===")
    
    TestMyFeature.testSomething()
    -- Add more tests here
    
    print("=== All MyFeature Tests Passed ✓ ===\n")
end

return TestMyFeature
```

### Adding Test to Runner

Edit `tests/run_tests.lua`:

```lua
local TestMyFeature = require("tests.test_myfeature")

-- In main execution
runTestSuite("MyFeature Tests", TestMyFeature)
```

## Test Coverage

### Current Coverage

- ✅ Core Classes (Tile, Unit, Team)
- ✅ Visibility System (LOS, fog of war)
- ✅ Map Loading (generation and PNG)
- ✅ Input Handling (keyboard, unit control)
- ✅ Integration (full game scenarios)

### Not Yet Covered

- ⚠️ Renderer3D (3D graphics rendering)
- ⚠️ Minimap (2D overlay)
- ⚠️ Combat system (damage calculation, attacks)
- ⚠️ AI behavior
- ⚠️ Save/Load system
- ⚠️ Audio system

## Mocking

### Keyboard Input

Tests use a mock keyboard system to simulate key presses:

```lua
local mockKeyboard = {}
love.keyboard.isDown = function(key)
    return mockKeyboard[key] == true
end

mockKeyboard["w"] = true  -- Simulate W key pressed
```

### Camera

Tests use a mock camera object:

```lua
local mockCamera = {
    position = {0, 0, 0},
    target = {0, 0, 0},
    updateViewMatrix = function() end
}
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Love2D
        run: sudo apt-get install -y love
      - name: Run Tests
        run: cd tests && love .
```

### Exit Codes

- `0` - All tests passed
- `1` - One or more tests failed

## Debugging Failed Tests

1. **Run individual test suite** to isolate the problem
2. **Check error message** for assertion failure details
3. **Add print statements** to see intermediate values
4. **Use Love2D console** (lovec) for full output
5. **Verify dependencies** are loaded correctly

## Test Utilities

### Helper Functions

Tests include helper functions for common tasks:

```lua
-- Create test map with specific walls
local function createTestMap(width, height, wallPositions)
    -- Returns map with walls at specified positions
end

-- Mock keyboard state
local function pressKey(key)
    mockKeyboardState[key] = true
end
```

## Performance

Tests run quickly:
- **Unit tests**: ~1-2 seconds total
- **Integration tests**: ~2-3 seconds
- **Full suite**: ~3-5 seconds

## Continuous Improvement

To add coverage:
1. Identify untested code paths
2. Write test cases
3. Add to appropriate test module
4. Update `run_tests.lua` if new module
5. Verify all tests pass

## Troubleshooting

### Common Issues

**Problem**: Tests crash on startup
- **Solution**: Check `package.path` is set correctly in `tests/main.lua`

**Problem**: Module not found errors
- **Solution**: Verify file paths match project structure

**Problem**: Love2D APIs not available
- **Solution**: Use `lovec` (console version) or mock Love2D functions

**Problem**: Tests pass but game doesn't work
- **Solution**: Add integration tests that match real game usage

## Contributing

When adding new features:
1. Write tests first (TDD approach)
2. Ensure all existing tests still pass
3. Aim for >80% code coverage
4. Document test purpose and expected behavior

## Resources

- [Love2D Documentation](https://love2d.org/wiki/Main_Page)
- [Lua Testing Best Practices](https://www.lua.org/gems/sample.pdf)
- [Test-Driven Development Guide](https://www.agilealliance.org/glossary/tdd/)
