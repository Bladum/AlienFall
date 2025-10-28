# Engine - Love2D Game Implementation

**Purpose:** Complete Love2D game engine implementation in Lua  
**Audience:** Developers, AI agents, modders  
**Status:** Active development  
**Last Updated:** 2025-10-28

---

## 📋 Table of Contents

- [Overview](#overview)
- [Folder Structure](#folder-structure)
- [Key Features](#key-features)
- [Content](#content)
- [Input/Output](#inputoutput)
- [Relations to Other Modules](#relations-to-other-modules)
- [Format Standards](#format-standards)
- [How to Use](#how-to-use)
- [How to Contribute](#how-to-contribute)
- [AI Agent Instructions](#ai-agent-instructions)
- [Good Practices](#good-practices)
- [Bad Practices](#bad-practices)
- [Quick Reference](#quick-reference)

---

## Overview

The `engine/` folder contains the **complete game implementation** in Lua using Love2D framework. This is where all design specifications, API contracts, and architectural plans become working code.

**Core Purpose:**
- Implement all game systems in Lua
- Provide Love2D callbacks and lifecycle management
- Integrate all subsystems (geoscape, basescape, battlescape)
- Load and manage mod content
- Handle rendering, input, and game loop

**Entry Point:** `main.lua` (Love2D entry point)  
**Configuration:** `conf.lua` (Love2D settings)

---

## Folder Structure

```
engine/
├── main.lua                           ← Love2D entry point (love.load, love.update, love.draw)
├── conf.lua                           ← Love2D configuration (window, modules, version)
├── icon.png                           ← Application icon
│
├── core/                              ← Core Engine Systems
│   ├── state_manager.lua             ← Game state machine (menu, geoscape, battle, etc.)
│   ├── event_bus.lua                 ← Event system for loose coupling
│   ├── logger.lua                    ← Logging system (writes to logs/)
│   ├── config.lua                    ← Configuration management
│   └── [other core systems]
│
├── geoscape/                          ← World Map & Strategy Layer
│   ├── world_manager.lua             ← World state, time progression
│   ├── mission_generator.lua         ← Mission creation and placement
│   ├── ufo_tracker.lua               ← UFO detection and tracking
│   ├── country_manager.lua           ← Country relations, funding
│   └── [geoscape systems]
│
├── basescape/                         ← Base Management Layer
│   ├── base_manager.lua              ← Base state, facilities
│   ├── facility_system.lua           ← Facility construction, maintenance
│   ├── personnel_manager.lua         ← Soldier hiring, training
│   ├── craft_hangar.lua              ← Craft storage, loadout
│   ├── storage_system.lua            ← Item storage, inventory
│   └── [basescape systems]
│
├── battlescape/                       ← Tactical Combat Layer
│   ├── battle_manager.lua            ← Battle state, turn management
│   ├── battle_ecs/                   ← ECS for tactical combat
│   │   ├── hex_math.lua              ← Hex coordinate system (CRITICAL)
│   │   ├── components.lua            ← ECS components
│   │   ├── systems.lua               ← ECS systems
│   │   └── entities.lua              ← Entity management
│   ├── pathfinding.lua               ← A* pathfinding on hex grid
│   ├── line_of_sight.lua             ← LOS calculation
│   ├── combat_resolver.lua           ← Attack resolution, damage
│   └── [battlescape systems]
│
├── interception/                      ← Air Combat Layer
│   ├── interception_manager.lua      ← Air combat state
│   ├── dogfight_system.lua           ← Craft vs UFO combat
│   └── [interception systems]
│
├── economy/                           ← Economic Systems
│   ├── economy_manager.lua           ← Budget, income, expenses
│   ├── market_system.lua             ← Trading, prices
│   └── [economy systems]
│
├── ai/                                ← AI Systems
│   ├── ai_manager.lua                ← AI coordination
│   ├── decision_tree.lua             ← AI decision making
│   ├── behavior_tree.lua             ← Complex AI behaviors
│   └── [ai systems]
│
├── gui/                               ← User Interface
│   ├── gui_manager.lua               ← UI state management
│   ├── widgets/                      ← Reusable UI components
│   │   ├── button.lua
│   │   ├── panel.lua
│   │   ├── list.lua
│   │   └── [other widgets]
│   ├── screens/                      ← Full screen UIs
│   │   ├── main_menu.lua
│   │   ├── geoscape_screen.lua
│   │   ├── basescape_screen.lua
│   │   └── [other screens]
│   └── [gui systems]
│
├── mods/                              ← Mod Loading System
│   ├── mod_loader.lua                ← Load mods from mods/ folder
│   ├── mod_validator.lua             ← Validate TOML against schema
│   ├── content_registry.lua          ← Register loaded content
│   └── [mod systems]
│
├── content/                           ← Content Management
│   ├── content_manager.lua           ← Manage loaded content
│   ├── unit_definitions.lua          ← Unit data structures
│   ├── item_definitions.lua          ← Item data structures
│   └── [content systems]
│
├── assets/                            ← Asset Loading & Management
│   ├── asset_loader.lua              ← Load sprites, sounds, data
│   ├── sprite_manager.lua            ← Sprite caching, batching
│   ├── sound_manager.lua             ← Audio playback
│   └── [asset systems]
│
├── audio/                             ← Audio Systems
│   ├── audio_manager.lua             ← Sound effects, music
│   ├── music_player.lua              ← Background music
│   └── [audio systems]
│
├── politics/                          ← Politics & Diplomacy
│   ├── politics_manager.lua          ← Faction relations
│   ├── diplomacy_system.lua          ← Diplomatic actions
│   └── [politics systems]
│
├── lore/                              ← Lore & Narrative
│   ├── lore_manager.lua              ← Story progression
│   ├── event_system.lua              ← Narrative events
│   └── [lore systems]
│
├── analytics/                         ← Analytics & Telemetry
│   ├── analytics_manager.lua         ← Collect metrics
│   ├── balance_tracker.lua           ← Track game balance data
│   └── [analytics systems]
│
├── tutorial/                          ← Tutorial System
│   ├── tutorial_manager.lua          ← Tutorial state
│   └── [tutorial systems]
│
├── accessibility/                     ← Accessibility Features
│   ├── accessibility_manager.lua     ← A11y settings
│   └── [accessibility systems]
│
├── localization/                      ← Localization System
│   ├── i18n.lua                      ← Translation system
│   └── [localization systems]
│
├── utils/                             ← Utility Functions
│   ├── math_utils.lua                ← Math helpers
│   ├── table_utils.lua               ← Table operations
│   ├── string_utils.lua              ← String operations
│   └── [other utils]
│
└── libs/                              ← External Libraries
    ├── inspect.lua                    ← Table inspection
    ├── lume.lua                       ← Utility collection
    └── [other libraries]
```

---

## Key Features

- **Complete Game Implementation:** All systems from design/API implemented
- **Love2D Framework:** Uses Love2D 11.x callbacks and APIs
- **Modular Architecture:** Clear separation by game layer
- **ECS Pattern:** Entity-Component-System for tactical combat
- **Hex Grid System:** Universal vertical axial coordinates
- **Event-Driven:** Loose coupling via event bus
- **Mod Support:** Dynamic content loading from mods/
- **Hot Reload:** Development features for faster iteration
- **Analytics:** Built-in metrics collection

---

## Content

### Code Organization

| Folder | Lines of Code | Files | Purpose |
|--------|---------------|-------|---------|
| `core/` | ~2000 | ~10 | Foundation systems |
| `geoscape/` | ~3000 | ~15 | World map, strategy |
| `basescape/` | ~2500 | ~12 | Base management |
| `battlescape/` | ~5000 | ~25 | Tactical combat |
| `gui/` | ~3500 | ~20 | User interface |
| `ai/` | ~2000 | ~10 | AI behavior |
| `mods/` | ~1500 | ~5 | Mod loading |
| `Other` | ~3000 | ~20 | Support systems |

**Total:** ~22,500 lines of Lua code across ~117 files

### Key Systems by Priority

| Priority | System | File | Status |
|----------|--------|------|--------|
| 1 | State Management | `core/state_manager.lua` | ✅ Stable |
| 1 | Mod Loading | `mods/mod_loader.lua` | ✅ Stable |
| 1 | Hex Math | `battlescape/battle_ecs/hex_math.lua` | ✅ Stable |
| 2 | Geoscape | `geoscape/world_manager.lua` | 🚧 Active |
| 2 | Basescape | `basescape/base_manager.lua` | 🚧 Active |
| 2 | Battlescape | `battlescape/battle_manager.lua` | 🚧 Active |
| 3 | AI | `ai/ai_manager.lua` | 📝 Planned |
| 3 | Economy | `economy/economy_manager.lua` | 📝 Planned |

---

## Input/Output

### Inputs (What Engine Consumes)

| Input | Source | Purpose |
|-------|--------|---------|
| Design specs | `design/mechanics/*.md` | Implementation requirements |
| API contracts | `api/*.md` | System interfaces |
| Architecture | `architecture/**/*.md` | Structure guidelines |
| Mod content | `mods/*/rules/**/*.toml` | Game content |
| Assets | `mods/*/assets/**/*` | Graphics, audio |
| Player input | Love2D callbacks | User interaction |

### Outputs (What Engine Produces)

| Output | Target | Purpose |
|--------|--------|---------|
| Game state | Runtime memory | Current game state |
| Rendered output | Screen | Visual feedback |
| Audio output | Speakers | Sound effects, music |
| Log files | `logs/**/*.log` | Runtime data, errors |
| Analytics | `logs/analytics/*.json` | Metrics, telemetry |
| Save files | (future) | Persistent game state |

---

## Relations to Other Modules

### Upstream Dependencies (Engine Reads From)

```
design/mechanics/*.md → engine/**/*.lua
    ↓
Design specs define what to implement

api/*.md → engine/**/*.lua
    ↓
API contracts define interfaces

architecture/**/*.md → engine/**/*.lua
    ↓
Architecture defines structure

mods/*/rules/**/*.toml → engine/mods/mod_loader.lua
    ↓
Mods provide game content
```

### Downstream Dependencies (Engine Writes To)

```
engine/**/*.lua → logs/**/*.log
    ↓
Engine writes runtime logs

engine/analytics/*.lua → logs/analytics/*.json
    ↓
Engine collects metrics
```

### Integration Map

| Module | Relationship | Details |
|--------|--------------|---------|
| **design/** | Input | Implements design specifications |
| **api/** | Input | Follows API contracts |
| **architecture/** | Input | Matches architectural structure |
| **mods/** | Input | Loads content from mods |
| **tests2/** | Validation | Verified by test suite |
| **logs/** | Output | Writes runtime data |
| **docs/** | Reference | Follows coding instructions |

---

## Format Standards

### Lua Code Standards

```lua
-- File header comment
-- filepath: engine/subsystem/module.lua

-- Module declaration
local ModuleName = {}

-- Private functions (local)
local function privateFunction(param)
    -- Implementation
end

-- Public functions
function ModuleName.publicFunction(param)
    -- Implementation
    return result
end

-- Constructor pattern
function ModuleName.new(...)
    local instance = {}
    -- Initialize
    return instance
end

-- Module return
return ModuleName
```

### Naming Conventions

- **Files:** snake_case.lua (`state_manager.lua`)
- **Modules:** PascalCase (`StateManager`)
- **Functions:** camelCase (`updateState()`)
- **Variables:** camelCase (`currentState`)
- **Constants:** UPPER_SNAKE_CASE (`MAX_HEALTH`)
- **Private:** prefix with `_` (`_internalFunction`)

### Love2D Callbacks

```lua
-- main.lua structure
function love.load(args)
    -- Initialize systems
end

function love.update(dt)
    -- Update game state (dt = delta time)
end

function love.draw()
    -- Render everything
end

function love.keypressed(key)
    -- Handle keyboard input
end

function love.mousepressed(x, y, button)
    -- Handle mouse input
end

function love.quit()
    -- Cleanup
end
```

---

## How to Use

### Running the Game

```bash
# Windows
lovec "engine"
# or
run_xcom.bat

# Linux/Mac
love engine/

# Debug mode (verbose logging)
lovec "engine" --debug
```

### Development Workflow

1. **Read design/API/architecture:**
   ```bash
   cat design/mechanics/[System].md
   cat api/[SYSTEM].md
   cat architecture/systems/[SYSTEM].md
   ```

2. **Implement in engine:**
   ```bash
   # Create module
   touch engine/[layer]/[system].lua
   
   # Edit module following standards
   ```

3. **Test implementation:**
   ```bash
   # Run game to test
   lovec "engine"
   
   # Run unit tests
   lovec "tests2/runners" run_subsystem [layer]
   ```

4. **Check for errors:**
   ```bash
   # Watch console output
   # Check logs/
   cat logs/game/game_*.log
   cat logs/system/errors_*.log
   ```

### Adding New System

1. **Choose location:**
   - Core system? → `core/`
   - Game layer? → `geoscape/`, `basescape/`, `battlescape/`
   - Cross-cutting? → Appropriate folder

2. **Create module file:**
   ```lua
   -- engine/subsystem/my_system.lua
   local MySystem = {}
   
   function MySystem.new()
       local instance = {}
       -- Initialize
       return instance
   end
   
   return MySystem
   ```

3. **Register in main.lua:**
   ```lua
   local MySystem = require("engine.subsystem.my_system")
   local mySystem = MySystem.new()
   ```

4. **Write tests:**
   ```bash
   # Create test file
   touch tests2/subsystem/my_system_test.lua
   ```

---

## How to Contribute

### Code Quality

- Follow naming conventions
- Add comments for complex logic
- Use `pcall` for error handling
- Avoid globals (use `local`)
- Keep functions small (<50 lines)
- Document public APIs

### Testing

- Write tests alongside code
- Test happy path + error cases
- Keep tests fast (<10ms)
- Use hierarchical test suite

### Performance

- Profile before optimizing
- Use locals for performance
- Cache frequently accessed data
- Batch rendering operations
- Monitor FPS and memory

---

## AI Agent Instructions

### When to Modify Engine

| Scenario | Action |
|----------|--------|
| New system | Read design → Read API → Implement in engine → Write tests |
| Bug fix | Read logs → Find bug → Fix code → Verify tests pass |
| Optimization | Profile (logs/system/performance_*.json) → Optimize → Benchmark |
| Refactor | Update architecture → Refactor code → Update tests |

### How to Navigate

```
1. Identify system type:
   - Core system? → core/
   - Game layer? → geoscape/, basescape/, battlescape/
   - Support? → appropriate folder

2. Read relevant files:
   - System manager (e.g., battle_manager.lua)
   - Supporting modules
   - Related systems

3. Check integration points:
   - What systems does this depend on?
   - What systems depend on this?
   - Event bus usage?

4. Implement changes following standards

5. Test thoroughly
```

### Common Tasks

| Task | Steps |
|------|-------|
| **Implement feature** | 1. Read design/API/architecture<br>2. Create/update module<br>3. Update main.lua if needed<br>4. Write tests<br>5. Run game + tests |
| **Fix bug** | 1. Read logs to find error<br>2. Locate bug in code<br>3. Fix with error handling<br>4. Verify tests pass<br>5. Check logs for errors |
| **Optimize** | 1. Read performance logs<br>2. Profile code<br>3. Optimize bottlenecks<br>4. Benchmark improvements<br>5. Verify functionality intact |

---

## Good Practices

### ✅ Code

- Use local variables everywhere
- Require modules at file top
- Handle errors with pcall
- Return early from functions
- Use meaningful variable names
- Comment complex algorithms

### ✅ Architecture

- Keep systems decoupled (event bus)
- Follow single responsibility
- Use dependency injection
- Avoid circular dependencies
- Cache expensive operations

### ✅ Love2D

- Separate update from draw
- Batch draw calls
- Use SpriteBatches for performance
- Respect Love2D callbacks
- Clean up resources in love.quit

---

## Bad Practices

### ❌ Code

- Don't use global variables
- Don't hardcode values
- Don't skip error handling
- Don't create circular dependencies
- Don't duplicate code

### ❌ Architecture

- Don't tightly couple systems
- Don't put everything in main.lua
- Don't skip state management
- Don't ignore performance
- Don't forget to clean up

---

## Quick Reference

### Essential Files

| File | Purpose | When to Use |
|------|---------|-------------|
| `main.lua` | Entry point | Starting point, initialization |
| `conf.lua` | Configuration | Love2D settings |
| `core/state_manager.lua` | State machine | Game state transitions |
| `core/event_bus.lua` | Events | Cross-system communication |
| `mods/mod_loader.lua` | Mod loading | Loading game content |
| `battlescape/battle_ecs/hex_math.lua` | Hex math | Spatial calculations |

### Quick Commands

```bash
# Run game
lovec "engine"

# Run with debug
lovec "engine" --debug

# Test subsystem
lovec "tests2/runners" run_subsystem [layer]

# Check logs
cat logs/system/errors_*.log
```

### Related Documentation

- **Design:** [design/README.md](../design/README.md) - What engine implements
- **API:** [api/README.md](../api/README.md) - Contracts engine follows
- **Architecture:** [architecture/README.md](../architecture/README.md) - Structure engine matches
- **Tests:** [tests2/README.md](../tests2/README.md) - Verification of engine
- **Docs:** [docs/instructions/🛠️ Love2D & Lua.instructions.md](../docs/instructions/🛠️%20Love2D%20&%20Lua.instructions.md) - Coding standards

---

**Last Updated:** 2025-10-28  
**Maintainers:** Engine Team  
**Questions:** See [docs/instructions/](../docs/instructions/) or ask in project Discord

