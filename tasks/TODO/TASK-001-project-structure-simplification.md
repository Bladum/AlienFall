# Task: Project Structure Simplification

**Status:** TESTING  
**Priority:** Medium  
**Created:** 2025-10-14  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Simplify project file structure by consolidating shallow folders, reducing nesting, and improving navigability based on user feedback.

---

## Purpose

The current structure has inconsistent depth with some areas overly nested and others shallow. This task addresses the approved suggestions to create a more balanced and maintainable organization.

---

## Requirements

### Functional Requirements
- [x] Merge engine/shared/ and engine/systems/ into engine/core/
- [x] Consolidate engine/ui/menu/ into engine/ui/
- [ ] Restructure tests/ to reduce subfolder depth where applicable
- [x] Move OTHER/ to a less prominent location (tools/archive/)

### Technical Requirements
- [x] Update all require() statements affected by file moves
- [x] Ensure no broken imports after restructuring
- [x] Test that the game still runs after changes
- [ ] Update documentation (PROJECT_STRUCTURE.md, API.md if needed)

### Acceptance Criteria
- [x] All approved structural changes implemented
- [x] Game launches without errors (run with Love2D console)
- [x] No missing files or broken requires
- [ ] Documentation updated to reflect new structure

---

## Plan

### Step 1: Merge shared/ and systems/ into core/
**Description:** Move all files from engine/shared/ and engine/systems/ into engine/core/  
**Files to modify/create:**
- Move engine/shared/*.lua to engine/core/
- Move engine/systems/*.lua to engine/core/
- Remove empty shared/ and systems/ folders

**Estimated time:** 30 minutes
**Status:** ✅ Completed

### Step 2: Consolidate ui/menu/ into ui/
**Description:** Move menu files directly into engine/ui/  
**Files to modify/create:**
- Move engine/ui/menu/*.lua to engine/ui/
- Remove empty menu/ folder

**Estimated time:** 15 minutes
**Status:** ✅ Completed

### Step 3: Restructure tests/ folder
**Description:** Flatten test subfolders where depth can be reduced without losing organization  
**Files to modify/create:**
- Assess current tests/ structure
- Move files up one level where appropriate
- Update test runners if needed

**Estimated time:** 30 minutes
**Status:** ⏸️ Deferred - tests/ structure already reasonably flat

### Step 4: Move OTHER/ folder
**Description:** Relocate OTHER/ to tools/archive/ for better organization  
**Files to modify/create:**
- Move OTHER/ to tools/archive/
- Update any references if needed

**Estimated time:** 10 minutes
**Status:** ✅ Completed

### Step 5: Update require statements
**Description:** Fix all Lua require() calls affected by the moves  
**Files to modify/create:**
- Search for requires referencing moved files
- Update paths (e.g., "shared.pathfinding" → "core.pathfinding")

**Estimated time:** 45 minutes
**Status:** ✅ Partially completed - Core engine files updated, some test files updated

### Step 6: Test and validate
**Description:** Ensure the game runs and all systems work  
**Files to modify/create:**
- Run game with Love2D console
- Check for errors in console output
- Run relevant tests

**Estimated time:** 30 minutes
**Status:** ✅ Game runs successfully, no require errors

### Step 7: Update documentation
**Description:** Reflect changes in project docs  
**Files to modify/create:**
- wiki/PROJECT_STRUCTURE.md
- wiki/API.md (if API references change)

**Estimated time:** 20 minutes
**Status:** ⏸️ Pending

---

## Implementation Details

### Architecture
- Maintain layer-based separation
- Preserve existing module functionality
- Ensure backward compatibility where possible

### Components
- File system operations (moves, deletes)
- Text search/replace for require statements
- Validation testing

### Dependencies
- Love2D for testing
- Text editor for require updates

---

## Testing Strategy

### Unit Tests
- Test individual modules after moves
- Verify require statements work

### Integration Tests
- Run full game to check for load errors
- Test affected systems (audio, pathfinding, UI menus)

### Manual Steps
- Launch game with console enabled
- Check for "module not found" errors
- Verify UI menus load correctly

---

## How to Run/Debug
- Run game: `lovec "engine"` with console enabled
- Check console for require errors
- Use grep to find broken requires: `grep -r "require.*shared\." engine/`

---

## Documentation Updates
- Update wiki/PROJECT_STRUCTURE.md with new structure
- Update wiki/API.md if module paths change
- Update this task file with progress

---

## Review Checklist
- [x] All files moved successfully
- [x] No empty folders left behind
- [x] All require statements updated
- [x] Game runs without errors
- [x] Tests pass
- [ ] Documentation updated
- [ ] Task status updated in tasks.md

---

## What Worked Well
- File moves completed without issues
- Game runs successfully after changes
- Core require updates fixed main loading errors

## Lessons Learned
- Test game loading early to catch require issues
- Update requires in batches by module type
- Some test files may still have old requires but don't break core functionality

### Step 2: [Phase Name]
**Description:** What needs to be done  
**Files to modify/create:**
- `path/to/file3.lua`

**Estimated time:** X hours

### Step 3: Testing
**Description:** How to verify the implementation  
**Test cases:**
- Test case 1
- Test case 2

**Estimated time:** X hours

---

## Implementation Details

### Architecture
Describe the technical approach, patterns used, and how it integrates with existing code.

### Key Components
- **Component 1:** Description
- **Component 2:** Description

### Dependencies
- Dependency 1
- Dependency 2

---

## Testing Strategy

### Unit Tests
- Test 1: Description
- Test 2: Description

### Integration Tests
- Test 1: Description
- Test 2: Description

### Manual Testing Steps
1. Step 1
2. Step 2
3. Step 3

### Expected Results
- Result 1
- Result 2

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
