# AlienFall Copilot Instructions

**Project:** AlienFall - Turn-based strategy game inspired by X-COM, built with Love2D
**Framework:** Love2D 12.0 + Lua
**Architecture:** Three-layer (Geoscape/Basescape/Battlescape) + modding system
**Status:** Production-ready with comprehensive test suite (2,493+ tests)

---

## 🎯 Big Picture Architecture

### Three-Layer Game Architecture

**Geoscape (Strategic Layer)**
- World hex-grid map (90×45 hexes, ~500km per hex across Earth/Moon/Mars)
- UFO detection via radar networks, interception craft management
- Squad deployment to mission sites, campaign threat progression
- Location: `engine/geoscape/`, `gui/scenes/geoscape_screen.lua`

**Basescape (Operational/Management Layer)**
- Multiple bases across planets with facility grids (40×60 orthogonal squares)
- 20+ facility types (Lab, Hospital, Academy, Power Plant, Prison, Hangar, etc.)
- Research tree with 5 branches (Weapons, Armor, Alien Tech, Facilities, Support)
- Equipment manufacturing, unit recruitment, pilot training
- Power management with 10-tier priority system (handles shortages intelligently)
- Location: `engine/basescape/`, `gui/scenes/basescape_screen.lua`

**Battlescape (Tactical Layer)**
- Procedurally generated hex-based combat maps (vertical axial coordinate system)
- Squad-level turn-based combat (squads up to 12 units, vs aliens/humans)
- Line of sight, line of fire, cover system, terrain destruction
- 8 damage types (Kinetic, Explosive, Energy, Psi, Stun, Acid, Fire, Frost)
- Status effects (smoke, fire, gas, bleeding, suppression, stun with decay)
- Morale/Sanity/Bravery psychology system
- Location: `engine/battlescape/`, `gui/scenes/battlescape_screen.lua`

### Critical Data Flow

```
Mods (TOML content)
  ↓ (loaded FIRST)
ModManager (engine/mods/mod_manager.lua)
  ↓ (validates & registers)
DataLoader (engine/core/data/data_loader.lua)
  ↓ (provides to game)
StateManager → Active Game Layer (Geoscape/Basescape/Battlescape)
  ↓ (saves to)
SaveGame (JSON in love.filesystem)
```

**Why This Matters for AI Agents:**
- Always load ModManager before any game logic (done in main.lua line 35)
- Content is data-driven (edit TOML, not Lua engine code)
- State transitions are explicit (use StateManager.switch(), not direct state manipulation)
- All mods loaded at startup (no live reloading currently)

---

## 📁 Essential Project Structure

### Engine Code (`engine/`)
```
engine/
├── main.lua              # Entry point (loads ModManager FIRST)
├── conf.lua              # Love2D config (960×720 = 40×30 grid cells @ 24px)
├── core/
│   ├── state/state_manager.lua      # Game state machine (menu/geo/base/battle)
│   ├── data/data_loader.lua         # Loads TOML configs from mods
│   └── assets.lua                   # Graphics/audio/font loading
├── mods/mod_manager.lua             # Content loading & validation (runs FIRST)
├── gui/scenes/
│   ├── main_menu.lua
│   ├── geoscape_screen.lua          # Strategic layer UI
│   ├── basescape_screen.lua         # Management layer UI
│   └── battlescape_screen.lua       # Tactical layer UI
├── widgets/                         # UI component system (24×24 grid-based)
├── geoscape/                        # Strategic systems
├── basescape/                       # Management systems
├── battlescape/                     # Tactical systems
└── libs/                            # Third-party (toml, json, etc.)
```

### Game Content (`mods/core/`)
```
mods/core/
├── mod.toml                         # Core mod metadata (load_order=1)
├── rules/
│   ├── units/                       # Unit definitions (TOML)
│   ├── items/weapons.toml           # Weapons with damage types
│   ├── crafts/                      # Spacecraft definitions
│   ├── facilities/                  # Base facility types
│   ├── missions/                    # Mission templates
│   └── research/                    # Technology tree
├── assets/
│   ├── units/                       # 24×24 PNG sprites
│   ├── items/                       # 12×12 or 24×24 PNG icons
│   └── audio/                       # OGG music/sound effects
└── mapblocks/                       # Tactical map terrain tiles
```

### Documentation (`design/` + `api/`)
```
design/
├── mechanics/                       # Game design specs (29 files)
│   ├── Battlescape.md              # Combat system detailed spec
│   ├── Units.md                    # Unit stats & progression spec
│   ├── Basescape.md                # Facility & management spec
│   ├── DamageTypes.md              # Canonical damage/armor reference
│   └── [24 other mechanic specs]
├── SENIOR_DESIGNER_AUDIT.md        # Quality assurance findings (NEW)
└── ...

api/
├── MODDING_GUIDE.md                # Mod creation guide
├── GAME_API.toml                   # TOML schema (defines all content types)
└── [20+ API reference files]
```

### Tests (`tests2/`)
```
tests2/
├── runners/                         # Test execution scripts
├── unit/                            # Unit tests (fast)
├── integration/                     # Integration tests (cross-module)
├── battlescape/                     # Tactical system tests
├── geoscape/                        # Strategic system tests
├── basescape/                       # Management system tests
├── performance/                     # Performance/benchmark tests
└── by-type/                         # Tests grouped by system
```

---

## 🎮 Critical Developer Workflows

### Running the Game

**With Debug Console** (recommended):
```bash
cd engine
lovec .
```
Loads mod manager first, prints all `print()` output to console.

**Release Mode** (no console):
```bash
cd engine
love .
```

### Building Distributable

```bash
cd build
./build.bat          # Windows: creates alienfall.exe + .love file
./build.sh           # Linux/macOS: creates executables for all platforms
```
Outputs to `build/output/` (excludes tests, docs, and tools automatically).

### Running Tests

**All Tests:**
```bash
# Via task (recommended)
Ctrl+Shift+D → "🧪 TEST: All Tests"

# Or via terminal
cd engine
lovec tests2/runners
```

**Specific Test Suite:**
```bash
lovec tests2/runners battlescape          # Battlescape system tests
lovec tests2/runners unit                 # Unit tests only
lovec tests2/runners performance          # Performance benchmarks
```

**With Coverage Tracking:**
```bash
$env:TEST_COVERAGE=1; lovec tests2/runners
```
(Windows PowerShell syntax as per project)

### Building/Running Tasks

**Via VS Code:**
- Ctrl+Shift+D opens task palette
- Available: Game debug, game release, all test suites, individual test categories
- Tasks run in integrated terminal with proper environment

**Key Scripts:**
- `run/run_debug.bat` - Run with debug features enabled
- `run/run_release.bat` - Run optimized release
- `run/run_tests2_all.bat` - Run comprehensive test suite
- `build/build.bat` - Create distributable package

### Adding New Content

**Content Creation Workflow:**
```
1. Read: design/mechanics/[System].md (understand what you're adding)
2. Check: api/GAME_API.toml (verify TOML schema for content type)
3. Create: mods/core/rules/[type]/[name].toml (add content definition)
4. Add Assets: mods/core/assets/[type]/[name].png (sprite if needed)
5. Test: lovec engine (run game, check logs/mods/ for errors)
6. Iterate: Fix TOML schema errors, validate against schema
```

**Example - Add New Unit:**
```bash
# 1. Copy template
cp mods/minimal_mod/rules/example.toml mods/core/rules/units/my_unit.toml

# 2. Define unit following api/GAME_API.toml schema
[unit.my_soldier]
name = "My Soldier"
type = "soldier"
health = 100
time_units = 60
# ... (see design/mechanics/Units.md for stats)

# 3. Add sprite (24×24 PNG)
cp my_unit.png mods/core/assets/units/

# 4. Test
lovec engine  # Check logs/mods/mod_errors_*.log for validation
```

---

## 🔧 Project-Specific Conventions

### Lua Code Style

**Module Declaration:**
```lua
---@class MyModule
---@field current_state table
local MyModule = {}

function MyModule.initialize()
    -- ...
end

return MyModule
```

**Require Pattern (always at top):**
```lua
local ModManager = require("mods.mod_manager")
local StateManager = require("core.state.state_manager")
local Utils = require("utils.some_util")

-- Module-level functions use dot notation
function MyModule.do_something()
end
```

**State Interface (if creating game screen):**
```lua
local MyState = {}

function MyState:enter(...)
    -- Called when switching TO this state
end

function MyState:exit()
    -- Called when switching FROM this state
end

function MyState:update(dt)
    -- Called every frame with delta time
end

function MyState:draw()
    -- Render this state
end

function MyState:keypressed(key, scancode, isrepeat)
    -- Handle keyboard input
end

return MyState
```

### Game Grid System

**All UI elements snap to 24×24 grid:**
- Window: 960×720 pixels = 40 columns × 30 rows
- Each cell: 24×24 pixels (perfect for 12×12 scaled 2x)
- Calculation: `position_grid = math.floor(pixel_position / 24)`

**Widget System:**
```lua
local Widgets = require("widgets.init")

-- Create grid-aligned button
local button = Widgets.Button:new(x_grid, y_grid, width_grid, height_grid)
-- where x_grid, y_grid are in grid coordinates (multiply by 24 for pixels)
```

### Data-Driven Content (TOML)

**Never hardcode game content** - always use TOML + ModManager:

```lua
-- ❌ WRONG: Hardcoding content
local units = {
    { name = "Soldier", health = 100 },
    { name = "Elite", health = 150 }
}

-- ✅ RIGHT: Load from TOML via ModManager
local units = ModManager:get_all_units()  -- Returns all units from all mods
local elite = ModManager:get_unit("elite_soldier")  -- By ID
```

**TOML Examples Follow Snake Case:**
```toml
[unit.elite_soldier]               # NOT [unit.EliteSoldier]
name = "Elite Soldier"              # Human readable
health = 150
time_units = 60                     # NOT timeUnits or TimeUnits
```

### File Naming Convention

| Type | Convention | Example |
|------|-----------|---------|
| **Game Screens** | lowercase_underscores | `geoscape_screen.lua` |
| **Systems** | lowercase_underscores | `state_manager.lua` |
| **TOML Content** | lowercase_underscores | `elite_soldier.toml` |
| **Assets (PNG)** | lowercase_underscores | `elite_soldier.png` |
| **Mods** | lowercase_underscores | `mods/my_faction/` |

### State Management (Critical Pattern)

**State transitions are EXPLICIT:**
```lua
-- Use StateManager.switch() to change screens
local StateManager = require("core.state.state_manager")

-- Switch to geoscape
StateManager.switch("geoscape")

-- Switch to battlescape with parameters
StateManager.switch("battlescape", { map_seed = 12345 })

-- In the state, receive via enter()
function BattlescapeState:enter(params)
    self.map_seed = params.map_seed
end
```

**Never directly call state functions** - always go through StateManager.

---

## 🔌 Integration Points & Dependencies

### ModManager (Entry Point for Content)

**When to Use:**
```lua
local ModManager = require("mods.mod_manager")

-- Get all content of a type
local all_units = ModManager:get_all_units()
local all_items = ModManager:get_all_items()
local all_missions = ModManager:get_all_missions()

-- Get specific item by ID
local rifle = ModManager:get_item("rifle_standard")

-- Get mods in load order
local mods = ModManager:get_active_mods()  -- Returns in load_order sequence

-- Register new content type (rarely needed, core content pre-registered)
ModManager:register_content_type("weapons")
```

### DataLoader (TOML Parsing)

```lua
local DataLoader = require("core.data.data_loader")

-- Load all TOML files from mods
local data = DataLoader:load_all_data()

-- Load specific directory
local units = DataLoader:load_toml_directory("rules/units")

-- Parse single TOML file
local config = DataLoader:load_toml_file("path/to/file.toml")
```

### StateManager (Game State Control)

```lua
local StateManager = require("core.state.state_manager")

-- Register a new state (usually done in main.lua)
StateManager.register("my_screen", MyScreenState)

-- Switch to state
StateManager.switch("my_screen")

-- Current state available
if StateManager.current then
    StateManager.current:update(dt)
end

-- Global data storage (persists across state switches)
StateManager.global_data.campaign = campaign_instance
```

### Asset Loading

```lua
local Assets = require("core.assets")

-- Load graphics
local image = Assets:get_image("units/soldier.png")
local spritesheet = Assets:get_spritesheet("combat_animations")

-- Load audio
local sound = Assets:get_sound("weapons/rifle_fire.ogg")
local music = Assets:get_music("geoscape/theme.ogg")

-- All paths relative to game root (automatic through Love2D filesystem)
```

### External Libraries (in `engine/libs/`)

| Library | Purpose | Usage |
|---------|---------|-------|
| **toml** | TOML parsing | `require("libs.toml")` |
| **json** | JSON encoding | `require("libs.json")` |
| **class** | OOP helper | `require("libs.class")` |
| **math_util** | Math functions | `require("libs.math_util")` |

---

## 🧪 Testing Pattern (Critical for AI Agents)

### Test Framework Structure

```lua
local TestFramework = require("core.testing.test_framework")

-- Register test suite
TestFramework:suite("Unit System Tests", function(suite)

    -- Describe test case
    suite:test("Unit health recovery", function()
        local unit = create_test_unit()
        unit:take_damage(50)
        unit:rest(1)  -- 1 week

        -- Assertions
        assert_true(unit.health > 50, "Health should increase after rest")
    end)

    -- Test state setup/teardown
    suite:setup(function()
        -- Before each test
    end)

    suite:teardown(function()
        -- After each test
    end)
end)
```

### Running Tests During Development

```bash
# Run while editing (re-run on save)
lovec tests2/runners unit

# Run with coverage
$env:TEST_COVERAGE=1; lovec tests2/runners

# Run specific subsystem
lovec tests2/runners battlescape
lovec tests2/runners geoscape
lovec tests2/runners basescape
```

### When to Add Tests

**Add tests when:**
1. Implementing mechanics that affect game balance
2. Creating systems with complex logic (state machines, calculations)
3. Building shared utilities (used across multiple systems)
4. Fixing bugs (write test to prevent regression)

**Not needed for:**
- UI rendering (hard to test, test manually)
- Asset loading (tested by content loading)
- Simple view/display code

---

## 📊 Key Design Patterns in Codebase

### 1. **Modular State Machines**

Each game layer (Geoscape/Basescape/Battlescape) is a State with enter/exit/update/draw:

```lua
-- Example: BattlescapeState
function BattlescapeState:enter(mission_data)
    self:generate_map(mission_data)
    self:spawn_units()
    self.turn = 1
end

function BattlescapeState:update(dt)
    if self.current_player_turn then
        self:update_ui(dt)
    else
        self:update_ai(dt)
    end
end

function BattlescapeState:exit()
    self:save_results()
    self:cleanup_memory()
end
```

### 2. **Data-Driven Content System**

All game content defined in TOML, loaded by ModManager, no hardcoding:

```lua
-- ✅ Content loaded from TOML
local unit_def = ModManager:get_unit("elite_soldier")
-- Returns: {id: "elite_soldier", name: "Elite Soldier", health: 150, ...}

-- ❌ Never hardcode
-- local unit_def = {id: "elite_soldier", health: 150}
```

### 3. **Widget Grid System**

UI positioned on 24×24 grid, not pixel coordinates:

```lua
-- Grid coordinates (not pixels)
local button = Widgets.Button:new(10, 5, 8, 2)  -- x_grid, y_grid, w_grid, h_grid
-- Converts internally to pixel positions (10*24=240px, 5*24=120px, etc.)
```

### 4. **Component-Based Architecture**

Units/objects composed of stats, traits, equipment components:

```lua
local unit = {
    id = "soldier_1",
    stats = {health: 100, time_units: 60, ...},
    traits = {"Fast", "Loyal"},
    equipment = {primary: rifle, armor: vest, ...}
}

-- Access via: unit.stats.health, unit.traits[1], unit.equipment.primary
```

### 5. **Hierarchical Testing**

Tests organized by system, each suite independently runnable:

```
tests2/
├── unit/            → Fast, isolated tests (< 100ms each)
├── integration/     → Cross-module tests (< 1s each)
├── battlescape/     → Full tactical system tests (< 5s each)
├── geoscape/        → Full strategic system tests
└── performance/     → Benchmark tests
```

---

## 🚀 Quick Start for AI Agents

**When assigned a task in AlienFall codebase:**

1. **Understand the layer** - Is it Geoscape (strategic), Basescape (management), or Battlescape (tactical)?
2. **Check design first** - Read `design/mechanics/[System].md` to understand what's supposed to happen
3. **Find precedent** - Look for similar existing systems in the codebase
4. **Use ModManager** - Load content via `ModManager:get_*()`, never hardcode
5. **Test thoroughly** - Add tests in `tests2/` to validate changes
6. **Check logs** - Run game with `lovec engine`, check console for errors
7. **Validate TOML** - If editing content, verify against `api/GAME_API.toml` schema

**Red Flags:**
- ❌ Hardcoding values instead of using TOML
- ❌ Directly manipulating state instead of StateManager.switch()
- ❌ Pixel coordinates instead of grid coordinates
- ❌ Not testing complex logic

**Green Flags:**
- ✅ Content loaded from ModManager
- ✅ Clear state transitions via StateManager
- ✅ Grid-aligned UI elements
- ✅ Test coverage for mechanics
- ✅ Follows existing code style and patterns

---

## 📚 Reference

### Key Documentation Files

| Document | Purpose | When to Read |
|----------|---------|--------------|
| `README.md` | Project overview | Understanding AlienFall concept |
| `design/mechanics/*.md` | Game mechanics specs | Implementing gameplay systems |
| `api/GAME_API.toml` | Content schema | Creating TOML content files |
| `api/MODDING_GUIDE.md` | Mod creation guide | Building mods/total conversions |
| `architecture/ARCHITECTURE_GUIDE.md` | System architecture | Understanding system interactions |
| `build/README.md` | Build process | Creating distributable releases |
| `design/SENIOR_DESIGNER_AUDIT.md` | Quality issues found | Understanding design gaps to fix |

### Most-Used Modules

```lua
local ModManager = require("mods.mod_manager")           -- Content loading
local StateManager = require("core.state.state_manager") -- Game state control
local DataLoader = require("core.data.data_loader")      -- TOML parsing
local Widgets = require("widgets.init")                  -- UI components
local Assets = require("core.assets")                    -- Graphics/audio
local TestFramework = require("core.testing.test_framework") -- Testing
```

### Common Tasks

| Task | How To |
|------|--------|
| Add new unit | Edit `mods/core/rules/units/` TOML + PNG sprite |
| Add new item | Edit `mods/core/rules/items/` TOML + PNG icon |
| Add new screen | Create `gui/scenes/my_screen.lua`, implement state interface, register in main.lua |
| Add new system | Create `engine/[system_name]/` directory, follow modular pattern |
| Run tests | `lovec tests2/runners [category]` or use VS Code task (Ctrl+Shift+D) |
| Build release | `cd build && ./build.bat` (Windows) or `./build.sh` (Linux/macOS) |

---

**Last Updated:** October 31, 2025
**Version:** 1.0
**For Questions:** See project Discord or review `README.md` + `api/MODDING_GUIDE.md`
