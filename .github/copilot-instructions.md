
# System Prompt for AlienFall Love2D Development

## Project Overview

AlienFall (also known as XCOM Simple) is an open-source, turn-based strategy game inspired by X-COM, developed using Love2D in Lua. Features include Geoscape (global strategy), Battlescape (tactical combat), base management, economy, and open-ended gameplay. Emphasizes moddability and documentation.

## Technologies and Tools

- **Love2D**: 2D game framework (version 12.0+) for graphics, audio, input, and window management.
- **Lua**: Programming language (version 5.1+), focusing on clean, modular code.
- **Widgets Library**: Custom UI framework in `widgets/`.
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
├── engine/                          -- Main game engine (XCOM Simple)
│   ├── main.lua                    -- Entry point (love.load, love.update, love.draw)
│   ├── conf.lua                    -- Love2D configuration (console, window, modules)
│   ├── systems/                    -- Core game systems
│   │   ├── state_manager.lua      -- State/screen management
│   │   └── ui.lua                 -- UI widgets (buttons, labels, panels)
│   ├── modules/                    -- Game states/screens
│   │   ├── menu.lua               -- Main menu
│   │   ├── geoscape.lua           -- Strategic layer
│   │   ├── battlescape.lua        -- Tactical combat
│   │   └── basescape.lua          -- Base management
│   ├── utils/                      -- Utility functions
│   ├── data/                       -- Game data (JSON/Lua)
│   └── assets/                     -- Images, sounds, fonts
├── wiki/                           -- Documentation
│   ├── API.md                      -- API reference (READ THIS for API info)
│   ├── FAQ.md                      -- Common questions (READ THIS for game info)
│   ├── DEVELOPMENT.md              -- Dev guide (READ THIS for workflow)
│   └── wiki/                       -- Additional wiki pages
├── mods/                           -- Mod content
│   └── core/                       -- Core mod data
├── tasks/                          -- Task management
│   ├── tasks.md                    -- Task tracking (UPDATE THIS)
│   ├── TASK_TEMPLATE.md           -- Template for tasks (USE THIS)
│   ├── TODO/                       -- Active tasks
│   └── DONE/                       -- Completed tasks
└── run_xcom.bat                   -- Quick launch script
```

### Important Files to Know

**Core Game Files:**
- `engine/main.lua` - Game entry point
- `engine/conf.lua` - Love2D configuration
- `engine/systems/state_manager.lua` - State management
- `engine/systems/ui.lua` - UI widgets

**Documentation:**
- `wiki/API.md` - Full API documentation
- `wiki/FAQ.md` - Game mechanics and FAQ
- `wiki/DEVELOPMENT.md` - Development workflow

**Task Management:**
- `tasks/tasks.md` - Central task tracking
- `tasks/TASK_TEMPLATE.md` - Template for new tasks

---

## Code Standards and Best Practices

- **Lua Basics**: Use `local` variables, `camelCase` for functions/variables, `UPPER_CASE` for constants, `PascalCase` for modules. Handle errors with `pcall`, optimize performance (reuse objects, use `ipairs`/`pairs`).
- **Love2D Practices**: Structure around callbacks (`love.load`, `love.update`, `love.draw`). Separate logic/rendering/input. Manage resources in `love.load`/`love.quit`. Use `love.graphics` for drawing, `love.audio` for sound, `love.filesystem` for data.
- **Style**: 4-space indentation, <100 char lines, meaningful comments.

---

## MANDATORY: Widget System and Grid Layout

### Grid System Requirements

**ALL UI elements MUST snap to a 24×24 pixel grid.**

- **Resolution:** 960×720 pixels (40 columns × 30 rows)
- **Grid Cell Size:** 24×24 pixels
- **Position Rule:** ALL widget X and Y positions MUST be multiples of 24
- **Size Rule:** ALL widget widths and heights MUST be multiples of 24
- **No Exceptions:** Even temporary or animated widgets must respect the grid

### Grid Helper Functions

```lua
-- Snap position to grid
local gridX, gridY = widgets.snapToGrid(rawX, rawY)

-- Snap size to grid
local gridWidth, gridHeight = widgets.snapSize(rawWidth, rawHeight)

-- Convert grid coordinates to pixels
local pixelX, pixelY = widgets.gridToPixels(gridCol, gridRow)

-- Convert pixels to grid coordinates
local gridCol, gridRow = widgets.pixelsToGrid(pixelX, pixelY)
```

### Debug Tools

- **F9:** Toggle grid overlay
  - Shows 40×30 green grid lines
  - Displays red crosshairs at mouse position
  - Shows grid coordinates in corner
  - Essential for UI layout work

- **F12:** Toggle fullscreen
  - Switches between windowed and fullscreen
  - Maintains proper widget scaling
  - All widgets remain grid-aligned

### Widget Development Rules

1. **Always use grid snapping:**
   ```lua
   self.x, self.y = widgets.snapToGrid(x, y)
   self.width, self.height = widgets.snapSize(width, height)
   ```

2. **Inherit from BaseWidget:**
   ```lua
   local MyWidget = setmetatable({}, {__index = BaseWidget})
   ```

3. **Use theme system for ALL styling:**
   ```lua
   local color = theme.colors.primary
   local font = theme.fonts.default
   local padding = theme.padding
   ```

4. **Never hardcode visual properties:**
   - ❌ `love.graphics.setColor(100, 100, 200)`
   - ✅ `love.graphics.setColor(theme.colors.primary.r, theme.colors.primary.g, theme.colors.primary.b)`

5. **Document widget API:**
   - Create `engine/widgets/docs/widgetname.md`
   - Include constructor parameters, methods, properties, events
   - Add usage examples

6. **Write test cases:**
   - Create `engine/widgets/tests/test_widgetname.lua`
   - Test grid snapping, input handling, theme application
   - Verify enabled/disabled states

7. **Use mock data for testing:**
   ```lua
   local mockData = require("widgets.mock_data")
   local items = mockData.generateItems(10)
   ```

### Widget Architecture

```
engine/widgets/
├── init.lua              -- Widget system loader
├── base.lua              -- BaseWidget class (grid snapping, events, theme)
├── theme.lua             -- Theme system (colors, fonts, spacing)
├── grid.lua              -- Grid system (debug overlay, snapping functions)
├── mock_data.lua         -- Mock data generator
├── button.lua            -- Individual widgets...
├── imagebutton.lua
├── ...
├── docs/                 -- Widget documentation
│   ├── button.md
│   └── ...
├── tests/                -- Widget test suite
│   ├── test_button.lua
│   └── ...
└── demo/                 -- Standalone demo app
    ├── main.lua
    ├── conf.lua
    └── run_demo.bat
```

### Grid Coordinate Examples

```
Grid Position (0, 0)   → Pixel Position (0, 0)
Grid Position (1, 1)   → Pixel Position (24, 24)
Grid Position (10, 5)  → Pixel Position (240, 120)
Grid Position (39, 29) → Pixel Position (936, 696) -- Bottom-right corner

Widget at grid (5, 3) with size (4, 2):
  X: 5 × 24 = 120 pixels
  Y: 3 × 24 = 72 pixels
  Width: 4 × 24 = 96 pixels
  Height: 2 × 24 = 48 pixels
```

### Common Grid Sizes

- **Buttons:** 4×2 grid cells (96×48 pixels)
- **Labels:** Variable width, 1 cell height (24 pixels)
- **Panels:** Multiples of 24 pixels
- **Dialog Windows:** Typically 12×8 to 20×12 grid cells
- **Text Input:** 6×1 to 12×1 grid cells (144-288 pixels wide)
- **List Box:** 8×10 grid cells typical (192×240 pixels)

---

## Code Organization

- **Modules**: Use `require()` as `folder.module` (e.g., `widgets.button`).
- **File Structure**:
  - `main.lua`: Entry point.
  - `widgets/`: UI components.
  - `assets/`: Images, sounds, fonts.
  - `scripts/`: Game logic.
  - `tests/`: Unit/integration tests.
- **Architecture**: State machine for screens, table-based entities, component architecture.

## Game Development Patterns

- **Turn-Based Mechanics**: Phases for actions, AI, resolution.
- **Event System**: Callbacks/observers for events.
- **Data-Driven**: Configurable data in tables/files.
- **UI**: Widgets library, 16x16 pixel art upscaled to 32x32.
- **Balance**: Configurable values.

## Development Workflow

- **Planning**: Create comprehensive task documents using `tasks/TASK_TEMPLATE.md`. Update `tasks/tasks.md` with all planned work.
- **Coding**: Modular, testable code with comments. Run with Love2D console enabled for debugging.
- **Testing**: Run with `lovec "engine"`, check console for errors. Write unit tests.
- **Validation**: Check syntax, performance, standards. Verify no console warnings.
- **Documentation**: Update `wiki/API.md`, `wiki/FAQ.md`, `wiki/DEVELOPMENT.md`. Maintain comments.
- **Version Control**: Frequent commits with branches.
- **Task Management**: Move tasks through TODO → IN_PROGRESS → TESTING → DONE workflow.

## AI Assistant Guidelines

- **Context**: Reference XCOM mechanics, existing widgets/patterns.
- **Suggestions**: Lua/Love2D compatible, readable, functional.
- **Focus**: Prevent errors (globals, nil checks), highlight performance, encourage modularity.
- **Testing/Docs**: Always recommend running with Love2D console. Add comments/docs for complex features.
- **Best Practices**: Follow standards; check codebase if unsure.
- **Task Management**: Always create task documents before starting work. Update tasks.md throughout.
- **Temporary Files**: Always use `os.getenv("TEMP")` - never create temp files in project directories.
- **Documentation**: Update wiki files (API.md, FAQ.md, DEVELOPMENT.md) when making changes.

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
- Project Wiki: `wiki/` folder
  - `wiki/API.md` - API documentation
  - `wiki/FAQ.md` - Game mechanics and FAQ
  - `wiki/DEVELOPMENT.md` - Development workflow
  - `wiki/wiki/` - Additional documentation
- Source Code: `engine/` folder for game code
- Mods: `mods/` folder for custom content
- Tests: `tests/` folder for unit/integration tests
- Tasks: `tasks/` folder for task management
  - `tasks/tasks.md` - Task tracking
  - `tasks/TASK_TEMPLATE.md` - Template for new tasks
  - `tasks/TODO/` - Active tasks
  - `tasks/DONE/` - Completed tasks
- Codebase: Study `engine/` folder for patterns and systems.

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

