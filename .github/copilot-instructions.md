
# System Prompt for AlienFall Love2D Development

## Project Overview

AlienFall (also known as XCOM Simple) is an open-source, turn-based strategy game inspired by X-COM, developed using Love2D in Lua. Features include Geoscape (global strategy), Battlescape (tactical combat), base management, economy, and open-ended gameplay. Emphasizes moddability and documentation.

## Technologies and Tools

- **Love2D**: 2D game framework (version 12.0+) for graphics, audio, input, and window management.
- **Lua**: Programming language (version 5.1+), focusing on clean, modular code.
- **VS Code**: Primary IDE with GitHub Copilot.
- **Git**: Version control with branches and PRs.

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

1. **Always use print statements for debugging:**
   ```lua
   print("[ModuleName] Debug message: " .. tostring(value))
   ```

2. **Check console output for:**
   - Initialization messages
   - Error messages and stack traces
   - State transitions
   - Module loading confirmation
   - Performance warnings

3. **Use on-screen debug when needed:**
   ```lua
   love.graphics.print("Debug: " .. value, 10, 10)
   ```

4. **Error handling with pcall:**
   ```lua
   local success, result = pcall(riskyFunction, arg1)
   if not success then
       print("[ERROR] " .. result)
   end
   ```

---

## MANDATORY: Temporary Files

**ALL temporary files MUST be created in the system TEMP directory.**

### Rules:
- ✅ **Use:** `os.getenv("TEMP")` for Windows temp directory
- ✅ **Use:** `love.filesystem.getSaveDirectory()` for Love2D save dir
- ❌ **NEVER:** Create temp files in project directories
- ❌ **NEVER:** Create temp files in engine folder
- ❌ **NEVER:** Use relative paths for temp files

### Example:
```lua
local tempDir = os.getenv("TEMP")
if not tempDir then
    print("[ERROR] Cannot access TEMP directory")
    return nil
end

local filepath = tempDir .. "\\tempfile.tmp"
local file = io.open(filepath, "w")
if file then
    file:write(content)
    file:close()
    print("[DEBUG] Created temp file: " .. filepath)
end
```

---

## MANDATORY: Task Management System

### When Planning Work

**You MUST create comprehensive task documentation for any planned work.**

1. **Copy template to TODO folder:**
   ```
   tasks/TASK_TEMPLATE.md → tasks/TODO/TASK-XXX-description.md
   ```

2. **Fill in ALL sections:**
   - Overview and Purpose
   - Requirements (Functional, Technical, Acceptance Criteria)
   - Detailed Plan (Step-by-step with file paths and time estimates)
   - Implementation Details (Architecture, Components, Dependencies)
   - Testing Strategy (Unit tests, Integration tests, Manual steps)
   - How to Run/Debug (Love2D console instructions)
   - Documentation Updates (Which files need updating)
   - Review Checklist

3. **Update `tasks/tasks.md`:**
   - Add entry with Task ID, Name, Status, Priority, Files affected
   - Place in appropriate priority section (High/Medium/Low)

4. **Track progress:**
   - Move from TODO → IN_PROGRESS when starting
   - Move to DONE folder when complete
   - Update `tasks.md` with status changes and completion date

### Task Workflow States

- **TODO** - Planned and documented, not started
- **IN_PROGRESS** - Currently being worked on
- **TESTING** - Implementation complete, testing in progress
- **DONE** - Completed, tested, documented, moved to DONE folder

### Agent Responsibilities

**Before starting any work:**
- Create detailed task document from template
- Break down into implementable steps
- Identify all files to be modified/created
- Document testing approach
- List documentation that needs updating

**During work:**
- Update task status in tasks.md
- Log progress and decisions in task file
- Run game frequently with Love2D console to verify
- Check for errors, warnings, or unexpected behavior

**After completion:**
- Verify all acceptance criteria met
- Run all tests and manual verification
- Update API.md, FAQ.md, DEVELOPMENT.md as needed
- Move task to DONE folder
- Fill in "What Worked Well" and "Lessons Learned"
- Update tasks.md with completion info

---

## Project Structure and Navigation

### Key Directories

```
c:\Users\tombl\Documents\Projects\
├── .github/                        -- GitHub configuration and AI instructions
│   └── copilot-instructions.md     -- This system prompt file
├── run_tests.bat                   -- Test runner script
├── run_xcom.bat                    -- Game launcher script
├── engine/                         -- Main game engine (AlienFall/XCOM Simple)
│   ├── main.lua                    -- Entry point (love.load, love.update, love.draw)
│   ├── conf.lua                    -- Love2D configuration (console, window, modules)
│   ├── accessibility/              -- Accessibility features
│   ├── ai/                         -- AI systems (diplomacy, pathfinding, strategic, tactical)
│   ├── analytics/                  -- Analytics and metrics
│   ├── assets/                     -- Game assets (data, fonts, images, sounds)
│   ├── basescape/                  -- Base management layer (base, data, facilities, logic, services)
│   ├── battlescape/                -- Tactical combat layer (mission_map_generator.lua, ai, battle, etc.)
│   ├── core/                       -- Core engine systems
│   ├── economy/                    -- Economic systems
│   ├── geoscape/                   -- Strategic layer (world map, missions)
│   ├── interception/               -- Craft interception layer
│   ├── localization/               -- Localization and internationalization
│   ├── lore/                       -- Game lore and story content
│   ├── mods/                       -- Mod support
│   ├── network/                    -- Networking features
│   ├── politics/                   -- Political systems
│   ├── scenes/                     -- Scene management
│   ├── tutorial/                   -- Tutorial system
│   ├── ui/                         -- UI framework
│   ├── utils/                      -- Utility functions
│   └── widgets/                    -- Widget library (buttons, panels, etc.)
├── mods/                           -- Mod content
│   ├── README.md                   -- Mod documentation
│   ├── core/                       -- Core mod data
│   └── new/                        -- Additional mods
├── tasks/                          -- Task management
│   ├── TASK_TEMPLATE.md            -- Template for new tasks (USE THIS)
│   ├── tasks.md                    -- Task tracking (UPDATE THIS)
│   ├── DONE/                       -- Completed tasks
│   └── TODO/                       -- Active tasks
├── tests/                          -- All test files (consolidated)
│   ├── AI_AGENT_QUICK_REF.md       -- AI agent quick reference
│   ├── AI_AGENT_TEST_GUIDE.md      -- AI agent testing guide
│   ├── QUICK_TEST_COMMANDS.md      -- Quick test commands
│   ├── README.md                   -- Test documentation
│   ├── TEST_API_FOR_AI.lua         -- Test API for AI
│   ├── TEST_DEVELOPMENT_GUIDE.md   -- Test development guide
│   ├── test_mapblock_integration.lua -- Mapblock integration test
│   ├── battle/                     -- Battle system tests
│   ├── battlescape/                -- Battlescape tests
│   ├── geoscape/                   -- Geoscape tests
│   ├── integration/                -- Integration tests
│   ├── performance/                -- Performance tests
│   ├── runners/                    -- Test runner scripts
│   ├── systems/                    -- System tests
│   ├── unit/                       -- Unit tests
│   ├── widgets/                    -- Widget tests
│   └── mock/                       -- Mock data for testing
│       ├── battlescape.lua         -- Mock battlescape data
│       ├── economy.lua             -- Mock economy data
│       ├── facilities.lua          -- Mock facilities data
│       ├── geoscape.lua            -- Mock geoscape data
│       ├── items.lua               -- Mock items data
│       ├── maps.lua                -- Mock maps data
│       ├── missions.lua            -- Mock mission data
│       ├── MOCK_DATA_QUALITY_GUIDE.md -- Mock data quality guidelines
│       ├── README.md               -- Mock data documentation
│       ├── units.lua               -- Mock units data
│       └── widgets.lua             -- Mock widgets data
│   ├── battlescape/                -- Battlescape tests
│   ├── geoscape/                   -- Geoscape tests
│   ├── integration/                -- Integration tests
│   ├── performance/                -- Performance tests
│   ├── runners/                    -- Test runner scripts
│   ├── systems/                    -- System tests
│   ├── unit/                       -- Unit tests
│   └── widgets/                    -- Widget tests
├── tools/                          -- Standalone development tools
│   ├── README.md                   -- Tools documentation
│   ├── asset_verification/         -- Asset validation tool
│   └── map_editor/                 -- Visual map editor
└── wiki/                           -- Documentation
    ├── API.md                      -- API reference (READ THIS for API info)
    ├── FAQ.md                      -- Common questions (READ THIS for game info)
    ├── DEVELOPMENT.md              -- Development workflow (READ THIS for workflow)
    ├── PROJECT_STRUCTURE.md        -- Detailed project navigation
    ├── ...                         -- Additional documentation files
    ├── internal/                   -- Internal documentation
    ├── refences/                   -- References (note: typo in folder name)
    └── wiki/                       -- Additional wiki content
```

### Important Files to Know

**Core Game Files:**
- `engine/main.lua` - Game entry point
- `engine/conf.lua` - Love2D configuration
- `engine/core/state_manager.lua` - State management

**Documentation:**
- `wiki/API.md` - Full API documentation
- `wiki/FAQ.md` - Game mechanics and FAQ
- `wiki/DEVELOPMENT.md` - Development workflow
- `wiki/PROJECT_STRUCTURE.md` - Detailed project navigation

**Task Management:**
- `tasks/tasks.md` - Central task tracking
- `tasks/TASK_TEMPLATE.md` - Template for new tasks

**Testing:**
- `tests/README.md` - How to run tests
- `tests/mock/README.md` - Mock data usage guide

**Tools:**
- `tools/README.md` - Overview of development tools

---

## Code Standards and Best Practices

- **Lua Quality**: Write clean, readable, maintainable code. Use meaningful variable/function names. Avoid global variables. Implement proper error handling with `pcall` and `assert`. Follow SOLID principles where applicable in Lua context.
- **Comments**: Add comments for complex logic, algorithms, and non-obvious code. Use `--` for single-line comments and `--[[ ]]--` for multi-line. Document function purposes, parameters, and return values.
- **Docstrings**: Use LuaDoc format for module and function documentation. Include descriptions, parameter types, return types, and usage examples.
- **README Files**: Maintain up-to-date README.md files in all major directories (engine/, tests/, tests/mock/, tools/, mods/, wiki/). Include purpose, usage instructions, dependencies, and contribution guidelines.
- **File Structure**: Keep proper folder organization. Group related files logically. Use consistent naming conventions (snake_case for files, PascalCase for modules).
- **Testing**: Keep tests up-to-date with code changes. Write unit tests for new functions, integration tests for systems. Use mock data from `tests/mock/` folder. Run tests regularly and fix failing tests immediately.
- **Lua Basics**: Use `local` variables, `camelCase` for functions/variables, `UPPER_CASE` for constants, `PascalCase` for modules. Handle errors with `pcall`, optimize performance (reuse objects, use `ipairs`/`pairs`).
- **Love2D Practices**: Structure around callbacks (`love.load`, `love.update`, `love.draw`). Separate logic/rendering/input. Manage resources in `love.load`/`love.quit`. Use `love.graphics` for drawing, `love.audio` for sound, `love.filesystem` for data.
- **Style**: 4-space indentation, <100 char lines, meaningful comments.

---

## Game Development Patterns

- **Turn-Based Mechanics**: Phases for actions, AI, resolution.
- **Event System**: Callbacks/observers for events.
- **Data-Driven**: Configurable data in tables/files.
- **UI**: 12x12 pixel art upscaled to 24x24.
- **Balance**: Configurable values.

## Development Workflow

- **Planning**: Create comprehensive task documents using `tasks/TASK_TEMPLATE.md`. Update `tasks/tasks.md` with all planned work.
- **Coding**: Follow Code Standards and Best Practices. Run with Love2D console enabled for debugging.
- **Testing**: Run with `lovec "engine"`, check console for errors. Keep tests up-to-date with code changes.
- **Validation**: Check syntax, performance, standards. Verify no console warnings.
- **Documentation**: Update `wiki/API.md`, `wiki/FAQ.md`, `wiki/DEVELOPMENT.md` when making changes.
- **Version Control**: Frequent commits with branches.
- **Task Management**: Move tasks through TODO → IN_PROGRESS → TESTING → DONE workflow.
- **Quality Assurance**: Follow Code Standards and Best Practices section above.

## AI Assistant Guidelines

- **Context**: Reference XCOM mechanics and existing patterns.
- **Suggestions**: Lua/Love2D compatible, readable, functional.
- **Focus**: Prevent errors (globals, nil checks), highlight performance, encourage modularity.
- **Testing**: Always recommend running with Love2D console. Keep tests up-to-date with code changes.
- **Best Practices**: Follow standards in Code Standards section above.
- **Task Management**: Always create task documents before starting work. Update tasks.md throughout.
- **Temporary Files**: Always use `os.getenv("TEMP")` - never create temp files in project directories.
- **Documentation**: Update wiki files when making changes.

## Specific Game Systems

- **Geoscape**: Global world map divided into provinces, regions, and countries. Manage missions, UFO tracking, and send crafts for operations. Similar to Risk board game mechanics with strategic territory control and mission deployment.
- **Basescape**: Base management in a 2D grid layout with facilities, crafts, units, research labs, manufacturing, and marketplace. Similar to Civilization city management for resource allocation and development.
- **Strategic Layer**: Diplomacy, politics, factions, suppliers, countries, research tech trees, and organization level progression. Handles alliances, trade, and global influence.
- **Interception**: Turn-based interception mechanics with crafts vs. bases, missions, and UFOs. Similar to a battle card game with tactical engagements and resource commitment.
- **Battlescape**: Tactical combat with units on procedurally generated 2D maps. Rogue-like squad-level gameplay on a single-layer pixel art tile grid. Turn-based movement and actions.
- **Alternative Battlescape**: First-person 2.5D perspective for single-unit control, inspired by Wolfenstein 3D but fully turn-based. Focus on individual unit movement and combat in a 3D-like environment.
- **Core Mechanics**: All systems are turn-based; no real-time elements. Emphasize strategic planning, resource management, and tactical decisions.

## Validation and Quality Assurance

- **Syntax**: Lua validators.
- **Runtime**: No crashes/errors.
- **Performance**: Monitor FPS/memory.
- **Reviews/Playtesting**: Ensure standards and mechanics.

## Resources

- Love2D Docs: https://love2d.org/wiki/Main_Page
- Lua Manual: https://www.lua.org/manual/5.1/
- UFO API/Wiki: https://www.ufopaedia.org/ (X-COM reference)
- **Project Structure**: See "Project Structure and Navigation" section above for complete directory layout
- **Key Documentation** (READ THESE):
  - `wiki/API.md` - API reference
  - `wiki/FAQ.md` - Game mechanics and FAQ
  - `wiki/DEVELOPMENT.md` - Development workflow
  - `wiki/PROJECT_STRUCTURE.md` - Detailed project navigation
- **Codebase**: Study `engine/` folder for patterns and systems

## What to Remember

**MANDATORY Rules (see detailed sections above):**
- Always run game with Love2D console enabled (`lovec "engine"`)
- Create temp files ONLY in `os.getenv("TEMP")` directory
- ALL UI elements MUST snap to 24×24 pixel grid (40×30 grid = 960×720 resolution)
- Create task documents before starting work using `tasks/TASK_TEMPLATE.md`
- Keep tests up-to-date with code changes
- Follow Code Standards and Best Practices section above

---

## Quick Reference

### Run Game
```bash
lovec "engine"
```

### Create Task
```bash
copy tasks\TASK_TEMPLATE.md tasks\TODO\TASK-XXX-name.md
```

### Get Temp Dir
```lua
local temp = os.getenv("TEMP")
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

