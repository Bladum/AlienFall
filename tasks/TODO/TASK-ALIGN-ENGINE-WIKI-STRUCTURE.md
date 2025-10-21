# Task: Align Engine Folder Structure with Wiki Systems

**Status:** IN_PROGRESS  
**Priority:** Critical  
**Created:** October 21, 2025  
**Assigned To:** AI Agent  
**Estimated Duration:** 16-24 hours  

---

## Overview

Restructure the `engine/` folder hierarchy to match the wiki `wiki/systems/` architecture. This involves:
1. Creating dedicated `content/` folders for items, units, and crafts
2. Merging `scenes/`, `ui/`, and `widgets/` into a single `gui/` folder
3. Verifying all other folders align with wiki structure
4. Finding and fixing misplaced files (e.g., research in wrong folders)
5. Updating all require() paths and documentation

---

## Purpose

The current engine structure has evolved organically and doesn't cleanly map to the wiki's system-based architecture. This creates:
- **Unclear file locations** - Hard to find system code by wiki name
- **Inconsistent organization** - Similar systems in different folder structures
- **Maintenance challenges** - Multiple require paths for same functionality
- **Onboarding friction** - New developers struggle to navigate

Aligning engine with wiki creates a unified reference model where developers can map wiki design directly to code implementation.

---

## Requirements

### Functional Requirements
- [ ] All wiki systems (Basescape, Battlescape, Crafts, Economy, Finance, Geoscape, Gui, Items, Units, AI, Politics, Lore, etc.) map to engine folders
- [ ] Content data (items, units, crafts) in dedicated folders
- [ ] GUI components (scenes, ui, widgets) in single gui/ folder
- [ ] All require() paths updated across entire codebase
- [ ] No broken requires or console warnings
- [ ] Game runs successfully with all systems intact

### Technical Requirements
- [ ] Folder structure matches wiki/systems/ naming
- [ ] All requires updated in engine/, tests/, and mods/
- [ ] No circular dependencies introduced
- [ ] Tests continue to pass
- [ ] Documentation updated to reflect new structure

### Acceptance Criteria
- [ ] `engine/` structure documented and matches wiki
- [ ] All 20+ wiki systems have corresponding engine folders
- [ ] Zero broken requires in codebase
- [ ] Game runs without console warnings
- [ ] All tests pass
- [ ] NAVIGATION.md updated with new folder mappings

---

## Plan

### Step 1: Audit & Mapping (2 hours)
**Description:** Map all wiki/systems files to existing engine folders and identify gaps/misalignments
**Files affected:**
- wiki/systems/ (all 20 files)
- engine/ (all 25+ top-level folders)

**Audit Checklist:**
- [ ] Basescape.md → engine/basescape/
- [ ] Battlescape.md → engine/battlescape/
- [ ] Crafts.md → engine/core/crafts/ or engine/content/crafts/
- [ ] Economy.md → engine/economy/
- [ ] Finance.md → engine/economy/finance/ or needs move
- [ ] Geoscape.md → engine/geoscape/
- [ ] Gui.md → engine/scenes/ or engine/ui/ (needs consolidation)
- [ ] Items.md → engine/content/items/ or engine/core/items/
- [ ] Units.md → engine/content/units/ or engine/core/units/
- [ ] AI Systems.md → engine/ai/
- [ ] Politics.md → engine/politics/
- [ ] Lore.md → engine/lore/
- [ ] Analytics.md → engine/analytics/
- [ ] Assets.md → engine/assets/
- [ ] 3D.md → engine/battlescape/rendering_3d/ or engine/3d/
- [ ] Integration.md → engine/core/ or engine/interception/
- [ ] Interception.md → engine/interception/
- [ ] Accessibility.md → engine/accessibility/
- [ ] Network.md → engine/network/

**Output:** Audit report listing all misalignments

---

### Step 2: Create Content Folders (3 hours)
**Description:** Create dedicated `engine/content/` folder with items/, units/, crafts/ subfolders
**Files to create/move:**
- [ ] Create: `engine/content/`
- [ ] Create: `engine/content/items/`
- [ ] Create: `engine/content/units/`
- [ ] Create: `engine/content/crafts/`
- [ ] Move item-related code from economy/items → content/items/
- [ ] Move unit-related code from core/units or battlescape/units → content/units/
- [ ] Move craft-related code from core/crafts or geoscape/crafts → content/crafts/

**Check requires:**
- [ ] Grep for "require.*items" and verify new path
- [ ] Grep for "require.*units" and verify new path
- [ ] Grep for "require.*crafts" and verify new path
- [ ] Verify tests reference new paths

---

### Step 3: Merge GUI Components (4 hours)
**Description:** Create `engine/gui/` folder and merge scenes/, ui/, widgets/ into it
**Files to move:**
- [ ] Create: `engine/gui/`
- [ ] Move: `engine/scenes/` → `engine/gui/scenes/`
- [ ] Move: `engine/ui/` → `engine/gui/ui/`
- [ ] Move: `engine/widgets/` → `engine/gui/widgets/`
- [ ] Remove old folders

**Check requires:**
- [ ] Grep for "require.*scenes" and update to gui.scenes
- [ ] Grep for "require.*ui" and update to gui.ui
- [ ] Grep for "require.*widgets" and update to gui.widgets
- [ ] Verify all 50+ requires updated
- [ ] Verify tests reference new paths

**Files to update (estimated 30-40 files):**
- engine/main.lua
- engine/core/state_manager.lua
- engine/battlescape/main.lua
- All test files
- All mods files

---

### Step 4: Verify System Folders (3 hours)
**Description:** Ensure all other folders match wiki and are properly named
**Folders to verify:**
- [ ] engine/ai/ matches wiki/systems/AI Systems.md
- [ ] engine/analytics/ matches wiki/systems/Analytics.md
- [ ] engine/basescape/ matches wiki/systems/Basescape.md
- [ ] engine/battlescape/ matches wiki/systems/Battlescape.md
- [ ] engine/economy/ matches wiki/systems/Economy.md
- [ ] engine/geoscape/ matches wiki/systems/Geoscape.md
- [ ] engine/interception/ matches wiki/systems/Interception.md
- [ ] engine/politics/ matches wiki/systems/Politics.md
- [ ] engine/lore/ matches wiki/systems/Lore.md
- [ ] engine/accessibility/ exists (wiki/systems/Accessibility.md)
- [ ] engine/localization/ exists (for i18n)
- [ ] engine/network/ exists (for multiplayer)
- [ ] engine/tutorial/ exists (for tutorial system)
- [ ] engine/core/ contains core systems (assets, data_loader, mod_manager, state_manager)

**Folders to potentially remove/rename:**
- [ ] Check engine/utils/ - should this be core/utils or utils/?
- [ ] Check engine/balance_adjustments.lua - should go in economy/ or tools/
- [ ] Check engine/performance_optimization.lua - should go in tools/ or core/
- [ ] Check engine/phase5_integration.lua - legacy artifact?
- [ ] Check engine/polish_features.lua - legacy artifact?

---

### Step 5: Find & Fix Misplaced Files (4 hours)
**Description:** Search for files in wrong locations and move them
**Examples to check:**
- [ ] Research system - should be in basescape/research/ or economy/research/
- [ ] Finance system - should be in economy/finance/
- [ ] Salvage system - should be in economy/salvage/
- [ ] Reputation system - should be in politics/reputation/ or core/reputation/
- [ ] Relations system - should be in politics/relations/
- [ ] Marketplace - should be in economy/marketplace/
- [ ] Suppliers - should be in economy/suppliers/

**Search strategy:**
- [ ] Grep for "research" files in all folders
- [ ] Grep for "finance" files in all folders
- [ ] Grep for "salvage" files in all folders
- [ ] Grep for "reputation" files in all folders
- [ ] Grep for "marketplace" files in all folders
- [ ] Check each file's wiki mapping

**Action:** Move each file to proper system folder, update requires

---

### Step 6: Update All Requires (5 hours)
**Description:** Update all require() statements to match new folder structure
**Affected folders:**
- [ ] engine/ - all 25+ folders
- [ ] tests/ - all test files
- [ ] mods/ - all mod definition files
- [ ] tools/ - any build scripts

**Strategy:**
- [ ] Create comprehensive grep search for "require" statements
- [ ] Group by old path → new path mapping
- [ ] Use replace_string_in_file for each mapping
- [ ] Verify no broken requires remain
- [ ] Run game to check console for missing module errors

**Estimated changes:** 100-200 require statements

---

### Step 7: Update Documentation (2 hours)
**Description:** Update all documentation to reflect new folder structure
**Files to update:**
- [ ] wiki/NAVIGATION.md - add new folder structure map
- [ ] wiki/systems/README.md - update paths to engine folders
- [ ] docs/PROJECT_STRUCTURE.md - describe new layout
- [ ] wiki/architecture/README.md - link to new structure
- [ ] engine/ folder README files in key folders

**Documentation additions:**
- [ ] Folder mapping table (wiki system → engine folder)
- [ ] File location guide for common systems
- [ ] Navigation flowchart

---

### Step 8: Test & Verify (2 hours)
**Description:** Run game and verify all systems work correctly
**Manual tests:**
- [ ] Run game: `lovec engine`
- [ ] Check console output for errors/warnings
- [ ] Test each major system (geoscape, battlescape, basescape, etc.)
- [ ] Verify save/load still works
- [ ] Check mod loading
- [ ] Run test suite: `lua run_tests.bat`

**Verification checklist:**
- [ ] Zero "module not found" errors
- [ ] Zero "cannot find file" errors
- [ ] All scenes load correctly
- [ ] All UI elements render
- [ ] Game transitions between screens work
- [ ] 100% of previous tests still pass

---

## Implementation Details

### Architecture

**Current Structure Problems:**
```
engine/
├── scenes/        (UI layer)
├── ui/            (UI layer) ← duplicate/inconsistent!
├── widgets/       (UI layer) ← should merge with above
├── core/
│   ├── crafts/
│   ├── items/
│   └── units/     (content, not core!)
├── battlescape/
├── basescape/
├── geoscape/
└── [20+ other folders]
```

**Target Structure (Wiki-Aligned):**
```
engine/
├── core/          (Core engine systems)
│   ├── state_manager.lua
│   ├── data_loader.lua
│   ├── mod_manager.lua
│   ├── assets.lua
│   └── ...
├── content/       (Game content/definitions)
│   ├── items/
│   ├── units/
│   └── crafts/
├── gui/           (UI/Menu/Widgets - consolidated)
│   ├── scenes/
│   ├── ui/
│   ├── widgets/
│   └── rendering/
├── battlescape/   (System folders matching wiki)
├── basescape/
├── geoscape/
├── economy/
├── politics/
├── ai/
└── [other systems...]
```

### Key Components

**Content Folders (New):**
- `engine/content/items/` - Item definitions, system logic
- `engine/content/units/` - Unit definitions, system logic
- `engine/content/crafts/` - Craft definitions, system logic

**GUI Folder (New - Merged):**
- `engine/gui/scenes/` - Scene definitions
- `engine/gui/ui/` - UI screen logic
- `engine/gui/widgets/` - Widget components
- `engine/gui/rendering/` - Rendering helpers

**System Folders (Verified/Updated):**
- `engine/basescape/` - Base management
- `engine/battlescape/` - Tactical combat
- `engine/economy/` - Finance, research, manufacturing, marketplace
- `engine/geoscape/` - Strategic world
- `engine/politics/` - Relations, factions, organizations
- `engine/ai/` - AI systems
- `engine/core/` - Core engine
- `engine/accessibility/` - Accessibility features
- `engine/analytics/` - Analytics/metrics
- `engine/lore/` - Story/lore systems
- `engine/localization/` - I18n
- `engine/network/` - Multiplayer
- `engine/tutorial/` - Tutorial system

### Dependencies

**No new circular dependencies should be introduced:**
- Content/ depends on core/ (for registries)
- GUI/ depends on core/ (for assets, state)
- Systems depend on content/ for data definitions
- Tests depend on mocks and systems

---

## Testing Strategy

### Unit Tests
- Verify content/ modules load without errors
- Verify gui/ modules load without errors
- Verify system folders unchanged functionality

### Integration Tests
- Run full game startup sequence
- Test scene transitions
- Test UI rendering
- Test system initialization

### Manual Testing Steps
1. Start game: `lovec engine`
2. Verify console shows no errors
3. Test main menu screens
4. Test game state transitions
5. Load a saved game (if available)
6. Run battlescape test if available
7. Check all require paths in console output

### Expected Results
- All 50+ require statements resolve successfully
- Game runs without warnings or errors
- All previous functionality intact
- File locations match wiki structure

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use the VS Code task: "Run XCOM Simple Game"

### Debugging
- Love2D console is enabled in `conf.lua` (t.console = true)
- Use `print()` statements to verify require() paths
- Check console for "module not found" errors
- Use editor search to find old path references

### Verification Commands
```lua
-- In console, check module paths:
print(require("core.state_manager"))  -- Should work
print(require("gui.scenes.main"))      -- Should work
print(require("content.items"))        -- Should work
```

### Temporary Files
- All temporary files created during refactoring use: `os.getenv("TEMP")`
- Never create temp files in project directories

---

## Documentation Updates

### Files to Update
- [ ] `wiki/NAVIGATION.md` - Primary navigation for new structure
- [ ] `wiki/systems/README.md` - System folder descriptions
- [ ] `docs/PROJECT_STRUCTURE.md` - Detailed folder layout
- [ ] `engine/README.md` - New root folder guide
- [ ] Create `engine/STRUCTURE.md` - Implementation guide

### New Documentation Structure
```
wiki/
├── NAVIGATION.md (updated with new folder map)
├── systems/
│   ├── README.md (updated paths)
│   ├── Basescape.md → engine/basescape/
│   └── ...
docs/
├── PROJECT_STRUCTURE.md (updated)
engine/
├── STRUCTURE.md (NEW - folder layout guide)
├── README.md (or update existing)
└── core/STRUCTURE.md, gui/STRUCTURE.md, etc.
```

---

## Notes

### Implementation Order
1. **Audit first** - Get full picture before moving files
2. **Create new folders** - Set up target structure
3. **Move content** - Content/ is lowest-risk
4. **Merge GUI** - GUI is self-contained, lower risk
5. **Update requires** - Most changes concentrated here
6. **Verify systems** - Ensure nothing broken
7. **Document** - Final step

### Risk Mitigation
- Git commit before each major step
- Keep old folders until verification complete
- Test after each require update batch
- Have working backup (git branch)

### Common Issues
- **Require path typos** - Use consistent naming (no mix of . and /)
- **Circular dependencies** - Keep dependency graph clean
- **Forgotten requires** - Grep search catches most
- **Test failures** - May need mock updates

---

## Blockers

None identified. This is a straightforward refactoring with clear scope.

---

## Review Checklist

- [ ] Code follows folder structure standards
- [ ] All require() paths updated
- [ ] No circular dependencies
- [ ] Zero console warnings/errors
- [ ] Tests pass completely
- [ ] Documentation updated
- [ ] Wiki/engine alignment complete
- [ ] Code reviewed for misplaced files
- [ ] All systems verified working
- [ ] Navigation guide created

---

## Post-Completion

### What Worked Well
- Document patterns found during audit
- Efficient require() path replacement strategy
- Clear mapping between wiki and engine

### What Could Be Improved
- Identify any remaining organizational issues
- Document any systems that need additional splitting

### Lessons Learned
- Keep code structure closely aligned with documentation
- Regular structure reviews prevent drift
- Use consistent naming conventions

---

## Progress Log

**Session 1 - October 21, 2025:**
- Task created and documented
- Audit plan established
- 8 implementation steps defined
- Ready to begin execution

