# Task: Project Structure Refactor

**Status:** DONE  
**Priority:** High  
**Created:** 2025-10-12  
**Completed:** 2025-10-12  
**Assigned To:** AI Agent

---

## Overview

Refactor the project file structure to improve organization, maintainability, and scalability. This includes moving subsystems, splitting large files, consolidating documentation, and cleaning up legacy content.

---

## Purpose

The current structure has grown organically and has several issues:
- Battle system nested too deeply in systems/
- Large monolithic files (battlescape.lua ~1500 lines)
- Scattered documentation
- Legacy mod content cluttering the structure
- Test runner in wrong location

This refactor will create a cleaner, more maintainable codebase.

---

## Requirements

### Functional Requirements
- [ ] Battle system moved to top-level module
- [ ] Large files split into logical modules
- [ ] Documentation consolidated
- [ ] Legacy content archived
- [ ] Test structure organized
- [ ] Naming conventions standardized

### Technical Requirements
- [ ] All require() statements updated after moves
- [ ] No broken imports or missing files
- [ ] Game still runs after refactor
- [ ] Tests still pass

### Acceptance Criteria
- [ ] Game launches without errors
- [ ] All tests pass
- [ ] No missing assets or broken links
- [ ] Documentation accessible in one place
- [ ] Code is more modular and easier to navigate

---

## Plan

### Step 1: Move Battle System
**Description:** Move systems/battle/ to engine/battle/ and update all require statements  
**Files to modify/create:**
- Move entire `engine/systems/battle/` to `engine/battle/`
- Update requires in `modules/battlescape.lua`
- Update requires in test files
- Update `run_tests.lua` if needed

**Estimated time:** 2 hours

### Step 2: Split Battlescape Module
**Description:** Break down the large battlescape.lua into smaller, focused modules  
**Files to modify/create:**
- Create `modules/battlescape/` directory
- Split `modules/battlescape.lua` into:
  - `init.lua` (main module)
  - `ui.lua` (GUI logic)
  - `logic.lua` (game logic)
  - `render.lua` (rendering)
- Update require in `main.lua`

**Estimated time:** 4 hours

### Step 3: Relocate Test Runner
**Description:** Move run_tests.lua to engine/tests/  
**Files to modify/create:**
- Move `run_tests.lua` to `engine/tests/run_tests.lua`
- Update any references

**Estimated time:** 30 minutes

### Step 4: Create Default Assets Directory
**Description:** Create engine/assets/ for core game assets  
**Files to modify/create:**
- Create `engine/assets/` directory
- Move any default assets from mods/ if applicable

**Estimated time:** 30 minutes

### Step 5: Consolidate Documentation
**Description:** Move engine/docs/ to wiki/ and organize  
**Files to modify/create:**
- Move `engine/docs/` to `wiki/internal/`
- Update any links in README

**Estimated time:** 1 hour

### Step 6: Archive Legacy Mods
**Description:** Move mods/old/ to OTHER/legacy_mods/  
**Files to modify/create:**
- Move `engine/mods/old/` to `OTHER/legacy_mods/`

**Estimated time:** 15 minutes

### Step 7: Reorganize Test Structure
**Description:** Group tests by system  
**Files to modify/create:**
- Create subdirectories in `engine/tests/`
- Move test files accordingly
- Update `run_tests.lua`

**Estimated time:** 1 hour

### Step 8: Testing and Validation
**Description:** Run game and tests to ensure everything works  
**Test cases:**
- Launch game with Love2D
- Run test suite
- Check for any missing requires

**Estimated time:** 1 hour

---

## Implementation Details

### Architecture
- Maintain existing module loading patterns
- Use relative requires within submodules
- Keep Love2D conventions

### Key Components
- **Battle System:** Independent module with ECS architecture
- **Battlescape:** Split into UI, logic, render components
- **Assets:** Separate mod assets from core assets

### Dependencies
- Love2D 12.0+
- Existing mod system
- Test framework

---

## Testing Strategy

### Unit Tests
- Test battle system components
- Test battlescape submodules
- Test asset loading

### Integration Tests
- Full game launch
- Mod loading
- Battle system integration

### Manual Testing Steps
1. Run `lovec engine` to launch game
2. Navigate to battlescape
3. Test battle functionality
4. Run `lua run_tests.lua` (updated path)
5. Check console for errors

### Expected Results
- Game runs without require errors
- All battle features work
- Tests pass
- Documentation accessible

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use the VS Code task: "Run XCOM Simple Game"

### Debugging
- Love2D console is enabled in `conf.lua` (t.console = true)
- Use `print()` statements for debugging output
- Check console window for errors and debug messages
- Use `love.graphics.print()` for on-screen debug info

### Temporary Files
- All temporary files MUST be created in: `os.getenv("TEMP")` or `love.filesystem.getSaveDirectory()`
- Never create temp files in project directories

---

## Documentation Updates

### Files to Update
- [ ] `wiki/API.md` - If adding new API functions
- [ ] `wiki/FAQ.md` - If addressing common issues
- [ ] `wiki/DEVELOPMENT.md` - If changing dev workflow
- [ ] `README.md` - If user-facing changes
- [ ] Code comments - Add inline documentation

---

## Notes

Any additional notes, considerations, or concerns.

---

## Blockers

Any blockers or dependencies that need to be resolved before this task can be completed.

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] No global variables (all use `local`)
- [ ] Proper error handling with `pcall` where needed
- [ ] Performance optimized (object reuse, efficient loops)
- [ ] All temporary files use TEMP folder
- [ ] Console debugging statements added
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] Code reviewed
- [ ] No warnings in Love2D console

---

## Post-Completion

### What Worked Well
- Point 1
- Point 2

### What Could Be Improved
- Point 1
- Point 2

### Lessons Learned
- Lesson 1
- Lesson 2
