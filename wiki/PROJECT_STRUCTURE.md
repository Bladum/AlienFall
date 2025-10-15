# Project Structure Guide

This document provides a comprehensive guide to navigating the AlienFall project structure after the major restructure.

## Overview

The project has been restructured for better organization, maintainability, and AI navigation. Key changes include:

- **Layer-based architecture**: Game systems organized by functional layers
- **Consolidated testing**: All tests moved to root-level `tests/` folder
- **Separated concerns**: Mods, tools, and mock data at project root
- **Clean engine**: Engine folder contains only game code, no tests or mods

## Directory Structure

```
c:\Users\tombl\Documents\Projects\
├── .github/
│   └── copilot-instructions.md     # AI assistant guidelines (UPDATED)
├── .vscode/
│   └── tasks.json                  # VS Code tasks
├── engine/                         # MAIN GAME ENGINE
│   ├── main.lua                    # Game entry point
│   ├── conf.lua                    # Love2D configuration
│   ├── layers/                     # GAME LAYERS (by concern)
│   │   ├── geoscape/               # Strategic world map layer
│   │   ├── basescape/              # Base management layer
│   │   ├── battlescape/            # 3D tactical combat layer
│   │   ├── interception/           # Craft interception layer
│   │   └── battle/                 # ECS battle system layer
│   ├── ui/                         # USER INTERFACE
│   │   └── widgets/                # Widget library (buttons, panels, etc.)
│   ├── core/                       # CORE ENGINE SYSTEMS
│   │   ├── state_manager.lua       # Screen/state management
│   │   ├── mod_manager.lua         # Mod loading system
│   │   └── assets.lua              # Asset management
│   ├── shared/                     # SHARED GAME LOGIC
│   │   ├── combat/                 # Combat mechanics
│   │   ├── units/                  # Unit definitions
│   │   └── pathfinding.lua         # Pathfinding utilities
│   ├── systems/                    # CROSS-LAYER SYSTEMS
│   │   ├── calendar.lua            # Game calendar
│   │   └── economy.lua             # Economic systems
│   ├── utils/                      # UTILITY FUNCTIONS & LIBRARIES
│   │   ├── libs/                   # External libraries (TOML, etc.)
│   │   ├── love_definitions/       # Love2D type definitions
│   │   └── ...                     # Other utilities
│   ├── data/                       # GAME DATA FILES
│   ├── ui/                         # USER INTERFACE
│   │   ├── widgets/                # UI widget library
│   │   └── menu/                   # Menu screens
│   ├── assets/                     # GAME ASSETS
│   └── .luarc.json                 # Lua LSP configuration
├── tests/                          # ALL TEST FILES (consolidated)
│   ├── runners/                    # Test runner scripts
│   ├── unit/                       # Unit tests
│   ├── integration/                # Integration tests
│   ├── performance/                # Performance tests
│   ├── battle/                     # Battle system tests
│   ├── battlescape/                # Battlescape tests
│   ├── core/                       # Core system tests
│   ├── systems/                    # System tests
│   └── README.md                   # Test documentation
├── mock/                           # MOCK DATA FOR TESTING
│   ├── units.lua                   # Mock unit data
│   ├── items.lua                   # Mock item data
│   ├── missions.lua                # Mock mission data
│   ├── maps.lua                    # Mock map data
│   ├── mock_data.lua               # Legacy mock data
│   └── README.md                   # Mock data usage guide
├── tools/                          # STANDALONE DEVELOPMENT TOOLS
│   ├── map_editor/                 # Visual map editor (standalone app)
│   └── asset_verification/         # Asset validation tool
├── mods/                           # MOD CONTENT
│   ├── core/                       # Core game mods
│   └── new/                        # Additional mods
├── wiki/                           # DOCUMENTATION
│   ├── API.md                      # API reference
│   ├── FAQ.md                      # Game mechanics FAQ
│   ├── DEVELOPMENT.md              # Development workflow
│   ├── PROJECT_STRUCTURE.md        # This file
│   └── [other docs]                # Additional documentation
├── tasks/                          # TASK MANAGEMENT
│   ├── tasks.md                    # Task tracking
│   ├── TASK_TEMPLATE.md           # Template for new tasks
│   ├── TODO/                       # Active tasks
│   └── DONE/                       # Completed tasks
├── OTHER/                          # LEGACY/DEMO CONTENT
├── run_xcom.bat                   # Quick launch script
└── [other project files]
```

## Navigation Guide

### Finding Game Systems

**Strategic Layer (Geoscape):**
- Location: `engine/layers/geoscape/`
- Purpose: World map, mission management, UFO tracking
- Key files: `systems/world_map.lua`, `logic/missions.lua`

**Base Management (Basescape):**
- Location: `engine/layers/basescape/`
- Purpose: Facility management, research, manufacturing
- Key files: `systems/facilities.lua`, `logic/research.lua`

**Tactical Combat (Battlescape):**
- Location: `engine/layers/battlescape/`
- Purpose: 3D tactical combat, unit movement, combat systems
- Key files: `combat/unit.lua`, `systems/los_system.lua`

**ECS Battle System:**
- Location: `engine/layers/battle/`
- Purpose: Alternative battle system using ECS architecture
- Key files: `systems/combat_system.lua`, `entities/unit_entity.lua`

### Finding UI Components

**Widget Library:**
- Location: `engine/ui/widgets/`
- Structure: `buttons/`, `containers/`, `display/`, `input/`
- Main file: `init.lua` (loads all widgets)

**Menu Screens:**
- Location: `engine/menu/`
- Files: `main_menu.lua`, `tests_menu.lua`, `widget_showcase.lua`

### Finding Tests

**Test Organization:**
- Unit tests: `tests/unit/`
- Integration tests: `tests/integration/`
- Performance tests: `tests/performance/`
- Battle tests: `tests/battle/`
- Battlescape tests: `tests/battlescape/`

**Running Tests:**
- Test runners: `tests/runners/`
- Main test runner: `tests/runners/run_tests.lua`
- Documentation: `tests/README.md`

### Finding Documentation

**API Reference:** `wiki/API.md`
**Game Mechanics:** `wiki/FAQ.md`
**Development Workflow:** `wiki/DEVELOPMENT.md`
**This Guide:** `wiki/PROJECT_STRUCTURE.md`

## Module Require Patterns

### Engine Modules
```lua
-- Layers
require("layers.geoscape.systems.world_map")
require("layers.battlescape.combat.unit")

-- UI
require("ui.widgets.button")
require("ui.widgets")

-- Core systems
require("core.state_manager")
require("core.mod_manager")

-- Shared logic
require("shared.combat.damage")
require("shared.units.stats")

-- Cross-layer systems
require("systems.calendar")
require("systems.economy")
```

### Test Modules
```lua
-- Test runners
require("tests.runners.run_battlescape_test")

-- Test modules
require("tests.unit.test_unit_creation")
require("tests.integration.test_mission_flow")
```

### Tool Modules
```lua
-- Tools are standalone apps, not modules
-- Run with: lovec tools/map_editor
```

### Mock Data
```lua
require("mock.units")
require("mock.items")
require("mock.missions")
```

## Development Workflow

1. **New Features:** Create task in `tasks/TODO/` using `TASK_TEMPLATE.md`
2. **Code Changes:** Work in appropriate `engine/layers/` subdirectory
3. **Testing:** Add tests to `tests/` subfolders, run with test runners
4. **Documentation:** Update relevant `wiki/` files
5. **Task Completion:** Move task file to `tasks/DONE/`

## File Naming Conventions

- **Modules:** `snake_case.lua` (e.g., `combat_system.lua`)
- **Classes:** `PascalCase.lua` (e.g., `UnitEntity.lua`)
- **Tests:** `test_descriptive_name.lua`
- **Tools:** `snake_case.lua` (standalone apps)

## Common Operations

### Running the Game
```bash
lovec engine
# or
./run_xcom.bat
```

### Running Tests
```bash
# From project root
lovec tests/runners/run_tests.lua
```

### Using Tools
```bash
# Map editor
lovec tools/map_editor

# Asset verification
lovec tools/asset_verification
```

### Creating Tasks
```bash
copy tasks/TASK_TEMPLATE.md tasks/TODO/TASK-XXX-description.md
```

## Troubleshooting

**Module not found errors:**
- Check require paths match new structure
- Layers: `layers.layer_name.module`
- UI: `ui.widgets.component`
- Tests: `tests.category.module`

**Test failures:**
- Ensure mock data is loaded: `require("mock.units")`
- Check test runner paths

**Tool issues:**
- Tools are standalone Love2D apps
- Run from project root: `lovec tools/tool_name`

## Architecture Overview

- **Layer-based:** Game systems separated by functional concerns
- **State-driven:** Screen management via state manager
- **Component-based:** UI widgets and game entities
- **Moddable:** Content loaded from `mods/` directory
- **Testable:** Comprehensive test suite with mock data
- **Tool-assisted:** Development tools for content creation

This structure provides clear separation of concerns, easy navigation, and scalable development practices.