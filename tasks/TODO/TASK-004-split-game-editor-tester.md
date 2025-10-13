# Task: Split Project into Game/Editor/Tester

**Status:** TODO  
**Priority:** High  
**Created:** October 12, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Split the monolithic project into three separate applications: GAME (engine folder), EDITOR (new editor folder), and TEST APP (new tester folder). Each should have its own main.lua and conf.lua optimized for its specific purpose.

---

## Purpose

Improve modularity, reduce complexity, and optimize each application for its specific use case. Make it easier to work on each component independently.

---

## Requirements

### Functional Requirements
- [ ] Game application in `engine/` folder
- [ ] Editor application in `editor/` folder  
- [ ] Test application in `tester/` folder
- [ ] Each has its own main.lua
- [ ] Each has its own conf.lua
- [ ] Shared code properly referenced
- [ ] Each can run independently

### Technical Requirements
- [ ] No code duplication (shared code in common location)
- [ ] Clear separation of concerns
- [ ] Proper module paths for each application
- [ ] Each optimized for its purpose (window size, modules, etc.)
- [ ] All imports updated correctly

### Acceptance Criteria
- [ ] Game runs standalone from engine/
- [ ] Editor runs standalone from editor/
- [ ] Tester runs standalone from tester/
- [ ] No broken imports
- [ ] Each application has appropriate features
- [ ] Documentation explains structure

---

## Plan

### Step 1: Plan Directory Structure
**Description:** Define final folder structure and shared code location  
**New structure:**
```
c:\Users\tombl\Documents\Projects\
├── engine/           -- Main game
│   ├── main.lua
│   ├── conf.lua
│   └── ...
├── editor/           -- Map/content editor (NEW)
│   ├── main.lua
│   ├── conf.lua
│   └── ...
├── tester/           -- Test runner (NEW)
│   ├── main.lua
│   ├── conf.lua
│   └── ...
├── shared/           -- Shared code (NEW)
│   ├── systems/
│   ├── widgets/
│   ├── utils/
│   └── ...
├── mods/             -- Moved from engine/mods
├── assets/           -- Shared assets?
└── wiki/
```

**Estimated time:** 2 hours

### Step 2: Create Shared Code Structure
**Description:** Move shared code to common location  
**Files to move:**
- `engine/systems/` → `shared/systems/`
- `engine/widgets/` → `shared/widgets/`
- `engine/utils/` → `shared/utils/`
- `engine/libs/` → `shared/libs/`

**Files to keep in engine:**
- `engine/modules/` (game-specific)
- `engine/battle/` (game-specific)

**Estimated time:** 4 hours

### Step 3: Create Editor Application
**Description:** Set up editor folder with map editor  
**Files to create:**
- `editor/main.lua`
- `editor/conf.lua`
- `editor/editor_state.lua`
- `editor/tool_palette.lua`
- `editor/map_canvas.lua`

**Files to move:**
- `engine/modules/map_editor.lua` → `editor/map_editor.lua`

**Estimated time:** 6 hours

### Step 4: Create Tester Application
**Description:** Set up tester folder with test runner  
**Files to create:**
- `tester/main.lua`
- `tester/conf.lua`
- `tester/test_runner.lua`
- `tester/test_ui.lua`

**Files to move:**
- `engine/tests/` → `tester/tests/`
- `engine/modules/tests_menu.lua` → `tester/menu.lua`

**Estimated time:** 6 hours

### Step 5: Update Game Application
**Description:** Update engine/ to reference shared code  
**Files to modify:**
- `engine/main.lua` - Update require paths
- `engine/conf.lua` - Optimize for game
- All files in `engine/modules/` - Update imports
- All files in `engine/battle/` - Update imports

**Estimated time:** 4 hours

### Step 6: Update All Import Paths
**Description:** Update all require() calls to use correct paths  
**Pattern changes:**
- `require("systems.X")` → `require("shared.systems.X")`
- `require("widgets.X")` → `require("shared.widgets.X")`
- `require("utils.X")` → `require("shared.utils.X")`

**Files to update:**
- All .lua files in engine/
- All .lua files in editor/
- All .lua files in tester/

**Estimated time:** 6 hours

### Step 7: Move Mods Folder
**Description:** Move mods/ out of engine/  
**Files to move:**
- `engine/mods/` → `mods/`

**Files to update:**
- Any code that loads mods (update path)
- `systems/mod_manager.lua` (update base path)

**Estimated time:** 2 hours

### Step 8: Create Launch Scripts
**Description:** Create convenient launch scripts  
**Files to create:**
- `run_game.bat` - Launch game
- `run_editor.bat` - Launch editor
- `run_tests.bat` - Launch tester
- Update `run_xcom.bat` to point to correct location

**Estimated time:** 1 hour

### Step 9: Update Configuration Files
**Description:** Optimize conf.lua for each application  
**Changes:**
- Game: Focus on performance, full modules
- Editor: Larger window, different modules
- Tester: Console enabled, minimal graphics

**Files to modify:**
- `engine/conf.lua`
- `editor/conf.lua`
- `tester/conf.lua`

**Estimated time:** 2 hours

### Step 10: Update Documentation
**Description:** Document new structure  
**Files to update:**
- `README.md` - Explain three applications
- `wiki/DEVELOPMENT.md` - Update workflow
- `wiki/API.md` - Update file paths
- Create `editor/README.md`
- Create `tester/README.md`
- Update `engine/README.md`

**Estimated time:** 3 hours

### Step 11: Testing
**Description:** Verify all three applications work  
**Test:**
- Game launches and runs
- Editor launches and runs
- Tester launches and runs
- No broken imports
- No missing files
- All features work

**Estimated time:** 4 hours

---

## Implementation Details

### Architecture

**Directory Structure:**
```
Projects/
├── engine/              -- GAME APPLICATION
│   ├── main.lua         -- Game entry point
│   ├── conf.lua         -- Game config (fullscreen, 960x720)
│   ├── modules/         -- Game-specific screens
│   ├── battle/          -- Battle system
│   └── assets/          -- Game assets
│
├── editor/              -- EDITOR APPLICATION
│   ├── main.lua         -- Editor entry point
│   ├── conf.lua         -- Editor config (windowed, larger)
│   ├── map_editor.lua   -- Map editing logic
│   ├── tool_palette.lua -- Editor tools
│   └── assets/          -- Editor-specific assets
│
├── tester/              -- TEST APPLICATION
│   ├── main.lua         -- Test runner entry point
│   ├── conf.lua         -- Test config (console, minimal)
│   ├── test_runner.lua  -- Test execution
│   ├── test_ui.lua      -- Test results display
│   └── tests/           -- All test files
│
├── shared/              -- SHARED CODE
│   ├── systems/         -- Core game systems
│   ├── widgets/         -- UI widgets
│   ├── utils/           -- Utility functions
│   └── libs/            -- Third-party libraries
│
├── mods/                -- GAME CONTENT
│   └── core/            -- Core mod
│
└── wiki/                -- DOCUMENTATION
```

**Game main.lua:**
```lua
-- engine/main.lua
-- Add shared to path
package.path = package.path .. ";../shared/?.lua;../shared/?/init.lua"

local StateManager = require("shared.systems.state_manager")
local Menu = require("modules.menu")

function love.load()
    StateManager.init()
    StateManager.setState(Menu)
end

function love.update(dt)
    StateManager.update(dt)
end

function love.draw()
    StateManager.draw()
end
```

**Editor main.lua:**
```lua
-- editor/main.lua
package.path = package.path .. ";../shared/?.lua;../shared/?/init.lua"

local MapEditor = require("map_editor")

function love.load()
    MapEditor.init()
end

function love.update(dt)
    MapEditor.update(dt)
end

function love.draw()
    MapEditor.draw()
end
```

**Tester main.lua:**
```lua
-- tester/main.lua
package.path = package.path .. ";../shared/?.lua;../shared/?/init.lua"

local TestRunner = require("test_runner")

function love.load()
    TestRunner.init()
    TestRunner.runAll()
end

function love.update(dt)
    TestRunner.update(dt)
end

function love.draw()
    TestRunner.draw()
end
```

### Key Components
- **Game:** Full game experience, optimized for play
- **Editor:** Map and content creation tools
- **Tester:** Automated test execution and reporting
- **Shared:** All common code used by all three

### Module Path Configuration
Each application adds shared/ to Lua path:
```lua
package.path = package.path .. ";../shared/?.lua;../shared/?/init.lua"
```

---

## Testing Strategy

### Manual Testing Steps
1. Launch game: `lovec "engine"`
2. Verify game runs normally
3. Test all game features
4. Launch editor: `lovec "editor"`
5. Verify editor loads
6. Test map editing features
7. Launch tester: `lovec "tester"`
8. Verify tests run
9. Check no import errors in any application
10. Verify shared code accessible from all three

### Expected Results
- All three applications launch successfully
- No import errors
- No missing files
- All features work as before
- Code properly shared between applications

---

## How to Run/Debug

### Running Game
```bash
cd engine
lovec .
# or
lovec "engine"
```

### Running Editor
```bash
cd editor
lovec .
# or
lovec "editor"
```

### Running Tester
```bash
cd tester
lovec .
# or
lovec "tester"
```

### Debugging Import Issues
```lua
-- Add to top of main.lua
print("Package path:", package.path)
print("Current directory:", love.filesystem.getSourceBaseDirectory())

-- Verify module loads
local status, module = pcall(require, "shared.systems.state_manager")
if not status then
    print("Failed to load:", module)
end
```

---

## Documentation Updates

### Files to Update
- [x] `README.md` - Explain three applications
- [x] `wiki/DEVELOPMENT.md` - Update workflow
- [x] `wiki/API.md` - Update file paths
- [x] `wiki/QUICK_REFERENCE.md` - Update structure
- [x] `engine/README.md` - Game-specific docs
- [x] `editor/README.md` - Editor documentation (create)
- [x] `tester/README.md` - Testing documentation (create)
- [x] `shared/README.md` - Shared code documentation (create)

---

## Notes

- Consider using symbolic links if code sharing becomes difficult
- May need to adjust asset loading paths
- Save files should be application-specific
- Each application can have different Love2D module requirements
- Consider future: could compile each separately

---

## Blockers

None - significant refactoring but no external dependencies.

---

## Review Checklist

- [ ] Shared folder created with common code
- [ ] Editor folder created and functional
- [ ] Tester folder created and functional
- [ ] Engine folder updated and functional
- [ ] All imports updated correctly
- [ ] No code duplication
- [ ] All applications launch successfully
- [ ] No broken functionality
- [ ] Documentation updated
- [ ] Launch scripts created
- [ ] Mods folder moved and working
- [ ] All tests pass

---

## Post-Completion

### What Worked Well
- To be filled after completion

### What Could Be Improved
- To be filled after completion

### Lessons Learned
- To be filled after completion
