
# System Prompt for AlienFall Love2D Development

## Project Overview

AlienFall (also known as XCOM Simple) is an open-source, turn-based strategy game inspired by X-COM, developed using Love2D in Lua. Features include Geoscape (global strategy), Battlescape (tactical combat), base management, economy, and open-ended gameplay. Emphasizes moddability and documentation.

---

## MANDATORY: Running and Debugging with Love2D 12

### Always Run with Console Enabled

**The game MUST be run with Love2D 12.0+ with console output enabled.**

**Command to run:**
```bash
lovec "engine"
```

**Alternative methods:**
- Execute `run_xcom.bat` from project root
- Use VS Code task: "Run XCOM Simple Game" (Ctrl+Shift+P > Run Task)

**Console is enabled in `conf.lua`:**
```lua
t.console = true  -- Provides debug console on Windows
```

### Debugging Requirements

**Always use print statements for debugging:**
```lua
print("[ModuleName] Debug message: " .. tostring(value))
```

**Check console output for:** initialization messages, errors, state transitions, module loading, performance warnings.

**Use on-screen debug when needed:**
```lua
love.graphics.print("Debug: " .. value, 10, 10)
```

**Error handling with pcall:**
```lua
local ok, err = pcall(func, args)
if not ok then print("[ERROR] " .. err) end
```

---

## MANDATORY: Temporary Files

**ALL temporary files MUST be created in the project's temp/ directory.**

### Rules:
- ✅ **Use:** `"temp/"` for project temp directory (relative to project root)
- ✅ **Use:** `love.filesystem.getSaveDirectory()` for Love2D save dir
- ❌ **NEVER:** Create temp files in system TEMP directory
- ❌ **NEVER:** Create temp files in engine folder
- ❌ **NEVER:** Create temp files in other project directories

### Example:
```lua
local tempDir = "temp"
local filepath = tempDir .. "/tempfile.tmp"
local file = io.open(filepath, "w")
if file then
    file:write(content)
    file:close()
    print("[DEBUG] Created temp file: " .. filepath)
else
    print("[ERROR] Cannot create temp file in temp directory")
end
```

---

## Project Structure and Navigation

### Key Directories

```
c:\Users\tombl\Documents\Projects\
├── .github/                    -- GitHub configuration and AI instructions
├── api/                        -- API documentation
├── architecture/               -- Architecture documentation and guides
├── design/                     -- Game design documentation
├── docs/                       -- Additional documentation
├── engine/                     -- Main game engine (AlienFall/XCOM Simple)
│   ├── main.lua               -- Entry point
│   ├── conf.lua               -- Love2D configuration
│   ├── accessibility/         -- Accessibility features
│   ├── ai/                    -- AI systems
│   ├── analytics/             -- Analytics and metrics
│   ├── assets/                -- Game assets
│   ├── basescape/             -- Base management layer
│   ├── battlescape/           -- Tactical combat layer
│   ├── content/               -- Game content
│   ├── core/                  -- Core engine systems
│   ├── economy/               -- Economic systems
│   ├── geoscape/              -- Strategic layer
│   ├── gui/                   -- GUI framework
│   ├── interception/          -- Craft interception layer
│   ├── localization/          -- Localization
│   ├── lore/                  -- Game lore content
│   ├── mods/                  -- Mod support
│   ├── network/               -- Networking features
│   ├── politics/              -- Political systems
│   ├── portal/                -- Portal systems
│   ├── tutorial/              -- Tutorial system
│   ├── utils/                 -- Utility functions
│   └── widgets/               -- Widget library
├── lore/                       -- Game lore and story content
├── mods/                       -- Mod content
├── tasks/                      -- Task management
│   ├── TASK_TEMPLATE.md        -- Template for new tasks (USE THIS)
│   ├── tasks.md                -- Task tracking (UPDATE THIS)
│   ├── DONE/                   -- Completed tasks
│   └── TODO/                   -- Active tasks
├── temp/                       -- Temporary files directory (USE THIS FOR TEMP FILES)
├── tests/                      -- All test files
│   ├── README.md               -- Test documentation
│   ├── AI_AGENT_QUICK_REF.md  -- AI agent quick reference
│   ├── mock/                  -- Mock data for testing
│   ├── runners/               -- Test runner scripts
│   ├── battle/                -- Battle system tests
│   ├── battlescape/           -- Battlescape tests
│   ├── geoscape/              -- Geoscape tests
│   ├── integration/           -- Integration tests
│   ├── performance/           -- Performance tests
│   ├── systems/               -- System tests
│   ├── unit/                  -- Unit tests
│   └── widgets/               -- Widget tests
└── tools/                      -- Standalone development tools
```

### Important Files to Know

**Core Game Files:**
- `engine/main.lua` - Game entry point
- `engine/conf.lua` - Love2D configuration
- `engine/core/state_manager.lua` - State management

**Documentation:**
- `api/MASTER_INDEX.md` - Master documentation index
- `architecture/README.md` - Architecture overview
- `design/README.md` - Design documentation

**Task Management:**
- `tasks/tasks.md` - Central task tracking
- `tasks/TASK_TEMPLATE.md` - Template for new tasks

**Testing:**
- `tests/README.md` - How to run tests
- `tests/mock/README.md` - Mock data usage guide

**Tools:**
- `tools/README.md` - Overview of development tools

**Temporary Files:**
- `temp/` - Project temp directory

---

## Code Standards and Best Practices

- **Lua Quality**: Clean, readable code with meaningful names. Avoid globals. Use `pcall` for error handling.
- **Comments**: Document complex logic, parameters, return values. Use `--` for single-line, `--[[ ]]--` for multi-line.
- **File Structure**: snake_case for files, PascalCase for modules, camelCase for functions/variables.
- **Testing**: Keep tests up-to-date. Write unit tests for functions, integration tests for systems. Use mock data from `tests/mock/`.
- **Love2D**: Structure around callbacks (`love.load`, `love.update`, `love.draw`). Separate logic/rendering/input.

---

## Game Development Patterns & Systems

**Patterns:**
- **Turn-Based Mechanics**: Phases for actions, AI, resolution
- **Event System**: Callbacks/observers for events
- **Data-Driven**: Configurable data in tables/files
- **UI**: 12x12 pixel art upscaled to 24x24
- **Balance**: Configurable values

**Systems:**
- **Turn-Based**: All systems are fully turn-based; no real-time elements
- **Geoscape**: Global world map with provinces, regions, countries. Manage missions, UFO tracking, and send crafts
- **Basescape**: 2D grid-based base management with facilities, crafts, units, research, and manufacturing
- **Battlescape**: Tactical combat with units on procedurally generated 2D pixel art maps. Squad-level, turn-based
- **Strategic Layer**: Diplomacy, politics, factions, research tech trees, and organization progression

## Development Workflow

- **Coding**: Follow Code Standards. Run with Love2D console: `lovec "engine"`
- **Testing**: Keep tests up-to-date. Run tests regularly with `run_tests.bat`
- **Documentation**: Update relevant docs in `api/`, `docs/`, `architecture/`, `design/` when making changes
- **Version Control**: Use branches and frequent commits

## AI Assistant Guidelines

- **Temporary Files**: Always use project's `temp/` directory - never create temp files elsewhere
- **Documentation**: Update relevant docs in `api/`, `docs/`, `architecture/`, `design/` when making changes
- **Testing**: Always run with Love2D console enabled. Keep tests up-to-date with code changes
- **Code Quality**: Prevent errors (globals, nil checks), highlight performance issues, encourage modularity
- **Reporting**: Brief summaries directly in chat after tasks are completed

## Validation and Quality Assurance

- No crashes or errors during console runs
- Keep tests passing and up-to-date
- Follow Code Standards above

---

## CRITICAL: FILE ORGANIZATION & WORKFLOW

### ❌ NEVER Create Status/Summary Files
**NO** `*_SUMMARY.md`, `*_STATUS.md`, `*_COMPLETE.md`, `*_REPORT.md` files anywhere
**NO** random documentation in workspace root
**NO** progress tracking files

Only output status directly in chat, never as files.

### File Organization Rules

**Design/Mechanics** → `design/mechanics/`
- New mechanics specifications, rules, balance parameters
- Example: `design/mechanics/pilot_system.md`

**API Documentation** → `api/` (ONLY if mechanic needs TOML config or cross-system API)
- System contracts and usage examples
- Data structures and configurations
- Example: Update `api/UNITS.md` for pilot API

**Architecture** → `architecture/` (ONLY if mechanic impacts system design)
- Diagrams, roadmap updates, integration flows
- When mechanics create dependencies or change interactions

**Engine Implementation** → `engine/`
- Production Lua code, systems, managers
- Organized by layer: `battlescape/`, `geoscape/`, `basescape/`, `content/`

**Mod Configuration** → `mods/core/rules/`
- TOML configuration and game content
- After engine is ready to load it
- Example: `mods/core/rules/units/pilots.toml`

**Code Standards** → `docs/`
- Programming patterns, practices, HOW to code
- NOT for mechanics or API - only for development practices

**Lore** → `lore/`
- Story elements, world building, narrative

**Tests** → `tests/`
- Unit and integration tests
- ALWAYS update when engine code changes

### Workflow: Design → API → Architecture → Engine → Mods → Tests

1. **Design Mechanics** (if new): Create `design/mechanics/MECHANIC.md`
2. **Define API** (if needed): Create/update `api/SYSTEM.md` only if mechanic needs TOML or cross-system calls
3. **Update Architecture** (if needed): Update diagrams/roadmap only if affects dependencies or interactions
4. **Implement Engine**: Create/update in `engine/`
5. **Create Mod Content**: Create/update in `mods/core/rules/`
6. **Update Tests**: Create/update in `tests/`

---

## Resources

- Love2D Docs: https://love2d.org/wiki/Main_Page
- Lua Manual: https://www.lua.org/manual/5.1/
- UFO API/Wiki: https://www.ufopaedia.org/ (X-COM reference)

---

## Quick Reference

### Run Game
```bash
lovec "engine"
```

### Get Temp Dir
```lua
local temp = "temp"
```

### Debug Print
```lua
print("[ModuleName] Message: " .. tostring(value))
```

### Error Handling
```lua
local ok, err = pcall(func, args)
if not ok then print("[ERROR] " .. err) end
```
