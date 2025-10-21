# Engine/Wiki Alignment - Implementation Plan

**Date:** October 21, 2025  
**Status:** READY FOR EXECUTION  
**Total Estimated Time:** 16-24 hours  

---

## Audit Findings Summary

### Critical Issues Discovered

#### 1. ❌ GUI Components Scattered (CRITICAL)
**Current State:**
- `engine/scenes/` - Scene definitions
- `engine/ui/` - UI screens  
- `engine/widgets/` - Widget components

**Problem:** Three separate folders for one system (Gui.md)

**Solution:** Merge into `engine/gui/`
- `engine/gui/scenes/` ← move from engine/scenes/
- `engine/gui/ui/` ← move from engine/ui/
- `engine/gui/widgets/` ← move from engine/widgets/

**Estimated Effort:** 3 hours (including require updates)

---

#### 2. ❌ Content Mixed with Core (CRITICAL)
**Current State:**
- `engine/core/crafts/` - Content definition
- `engine/core/items/` - Content definition
- `engine/core/units/` - Content definition

**Problem:** Game content mixed with core engine code

**Solution:** Move to `engine/content/`
- `engine/content/crafts/` ← move from core/crafts/
- `engine/content/items/` ← move from core/items/
- `engine/content/units/` ← move from core/units/

**Estimated Effort:** 2 hours (including require updates)

---

#### 3. ❌ Research System in Wrong Location (CRITICAL)
**Current State:** Research code scattered across TWO locations:
- `engine/geoscape/logic/research_manager.lua`
- `engine/geoscape/logic/research_entry.lua`
- `engine/geoscape/logic/research_project.lua`
- `engine/economy/research/research_system.lua`
- `engine/widgets/advanced/researchtree.lua` (UI widget)

**Problem:** Research is a **BASESCAPE** system (base research labs), not Geoscape

**Solution:** Consolidate into `engine/basescape/research/`
- Move `engine/economy/research/research_system.lua` → `engine/basescape/research/`
- Move research logic from geoscape/ → `engine/basescape/research/` (consolidate duplicates)
- Keep `engine/widgets/advanced/researchtree.lua` → `engine/gui/widgets/advanced/`
- Delete geoscape research files (duplicates)

**Estimated Effort:** 4 hours (consolidate logic, update requires)

---

#### 4. ⚠️ Salvage System Split Across Two Locations
**Current State:**
- `engine/battlescape/logic/salvage_processor.lua` (post-battle processing)
- `engine/economy/marketplace/salvage_system.lua` (storage/trading)

**Problem:** Salvage is split between two systems

**Decision Needed:** 
- Option A: Keep split (post-battle in battlescape, trading in economy)
- Option B: Unify in one location

**Recommended:** Option A is acceptable (different concerns)

---

#### 5. ⚠️ Legacy Files to Remove/Archive
**Current State:** 4 legacy/duplicate files in engine/ root:
- `engine/balance_adjustments.lua`
- `engine/performance_optimization.lua`
- `engine/phase5_integration.lua`
- `engine/polish_features.lua`

**Action:** Move to `tools/archive/` or verify if needed

---

## Implementation Steps

### STEP 1: Create New Folder Structure (0.5 hours)

**Actions:**
```powershell
# Create new folders
New-Item -ItemType Directory -Path "engine\content" -Force
New-Item -ItemType Directory -Path "engine\gui" -Force
```

**Verification:**
```
engine/
├── content/       (NEW - for game content)
├── gui/           (NEW - for UI/GUI)
└── ... (existing folders)
```

---

### STEP 2: Move Content Folders (1.5 hours)

#### 2a. Move Crafts
```powershell
# Move folder
Move-Item "engine\core\crafts" "engine\content\crafts" -Force

# Find and update requires
grep -r "require.*core.*crafts" engine/ tests/ mods/
# Update all occurrences:
# OLD: require("core.crafts...")
# NEW: require("content.crafts...")
```

**Files to Update:** ~10-15 files

---

#### 2b. Move Items
```powershell
# Move folder
Move-Item "engine\core\items" "engine\content\items" -Force

# Find and update requires
grep -r "require.*core.*items" engine/ tests/ mods/
# Update all occurrences:
# OLD: require("core.items...")
# NEW: require("content.items...")
```

**Files to Update:** ~15-20 files

---

#### 2c. Move Units
```powershell
# Move folder
Move-Item "engine\core\units" "engine\content\units" -Force

# Find and update requires
grep -r "require.*core.*units" engine/ tests/ mods/
# Update all occurrences:
# OLD: require("core.units...")
# NEW: require("content.units...")
```

**Files to Update:** ~15-20 files

---

### STEP 3: Merge GUI Components (3 hours)

#### 3a. Create GUI Subfolders
```powershell
# Create subfolders (if needed)
New-Item -ItemType Directory -Path "engine\gui\scenes" -Force
New-Item -ItemType Directory -Path "engine\gui\ui" -Force
New-Item -ItemType Directory -Path "engine\gui\widgets" -Force
```

---

#### 3b. Move Scenes
```powershell
# Move folder
Move-Item "engine\scenes\*" "engine\gui\scenes\" -Force

# Find and update requires
grep -r "require.*scenes" engine/ tests/ mods/ | grep -v "gui.scenes"
# Update all occurrences:
# OLD: require("scenes...")
# NEW: require("gui.scenes...")
```

**Files to Update:** ~20-25 files

---

#### 3c. Move UI
```powershell
# Move folder
Move-Item "engine\ui\*" "engine\gui\ui\" -Force

# Find and update requires
grep -r "require.*ui" engine/ tests/ mods/ | grep -v "gui.ui" | grep -v "gui\." | grep -v "battlescape.*ui" | grep -v "basescape.*ui" | grep -v "geoscape.*ui" | grep -v "interception.*ui"
# Update all occurrences:
# OLD: require("ui...")
# NEW: require("gui.ui...")
# (Be careful: avoid matching system-specific UI like battlescape.ui)
```

**Files to Update:** ~20-30 files

---

#### 3d. Move Widgets
```powershell
# Move folder
Move-Item "engine\widgets\*" "engine\gui\widgets\" -Force

# Find and update requires
grep -r "require.*widgets" engine/ tests/ mods/ | grep -v "gui.widgets"
# Update all occurrences:
# OLD: require("widgets...")
# NEW: require("gui.widgets...")
```

**Files to Update:** ~15-20 files

---

#### 3e. Clean Up Old Folders
```powershell
# Remove old, now-empty folders
Remove-Item "engine\scenes" -Force
Remove-Item "engine\ui" -Force
Remove-Item "engine\widgets" -Force
```

---

### STEP 4: Fix Research System Misplacement (3 hours)

#### 4a. Create Research Folder in Basescape
```powershell
# Create folder
New-Item -ItemType Directory -Path "engine\basescape\research" -Force
```

---

#### 4b. Consolidate Research Files
```powershell
# Move from economy/research to basescape/research
Move-Item "engine\economy\research\research_system.lua" "engine\basescape\research\" -Force

# Analyze geoscape/logic files to consolidate
# Files: research_manager.lua, research_entry.lua, research_project.lua
# Action: Determine if these are duplicates or different implementations
# Then consolidate into basescape/research/
```

**Files to Check:** 
- `engine/geoscape/logic/research_manager.lua`
- `engine/geoscape/logic/research_entry.lua`
- `engine/geoscape/logic/research_project.lua`

---

#### 4c. Move Research Widget
```powershell
# Move widget to GUI
Move-Item "engine\widgets\advanced\researchtree.lua" "engine\gui\widgets\advanced\" -Force
```

---

#### 4d. Update All Research Requires
```powershell
# Find all research requires
grep -r "research" engine/ tests/ mods/ | grep "require"

# Update paths:
# OLD: require("geoscape.logic.research_...")
# NEW: require("basescape.research.research_...")
# OLD: require("economy.research...")
# NEW: require("basescape.research...")
# OLD: require("widgets.advanced.researchtree")
# NEW: require("gui.widgets.advanced.researchtree")
```

**Files to Update:** ~25-30 files

---

### STEP 5: Verify System Folders (1 hour)

#### 5a. Check Each System
```
✅ engine/basescape/       - Basescape systems
✅ engine/battlescape/     - Battlescape systems
✅ engine/geoscape/        - Geoscape systems (remove research files!)
✅ engine/economy/         - Economy systems (remove research folder!)
✅ engine/interception/    - Interception system
✅ engine/politics/        - Politics/relations/factions
✅ engine/ai/              - AI systems
✅ engine/core/            - Core engine systems
✅ engine/accessibility/   - Accessibility
✅ engine/analytics/       - Analytics
✅ engine/assets/          - Assets
✅ engine/localization/    - Localization
✅ engine/network/         - Network/multiplayer
✅ engine/lore/            - Lore systems
✅ engine/tutorial/        - Tutorial
⚠️ engine/utils/           - Utilities (consolidate into core/utils?)
```

#### 5b. Clean Up Legacy Files
```powershell
# Move to archive
Move-Item "engine\balance_adjustments.lua" "tools\archive\" -Force
Move-Item "engine\performance_optimization.lua" "tools\archive\" -Force
Move-Item "engine\phase5_integration.lua" "tools\archive\" -Force
Move-Item "engine\polish_features.lua" "tools\archive\" -Force
```

---

### STEP 6: Update Core Requires (5 hours)

This is the bulk of the work. Use systematic search/replace.

#### 6a. Build Require Mapping Table

```
OLD PATH → NEW PATH
content.crafts ← core.crafts
content.items ← core.items
content.units ← core.units
gui.scenes ← scenes
gui.ui ← ui (careful: check context!)
gui.widgets ← widgets
basescape.research ← economy.research (PRIMARY)
basescape.research ← geoscape.logic.research_* (consolidate)
gui.widgets.advanced.researchtree ← widgets.advanced.researchtree
```

---

#### 6b. Update in Batches

For each mapping, use find/replace across codebase:

**Batch 1: Content System**
```lua
-- engine/main.lua
require("core.crafts") → require("content.crafts")
require("core.items") → require("content.items")
require("core.units") → require("content.units")
```

**Batch 2: GUI System**
```lua
require("scenes.) → require("gui.scenes.")
require("ui.") → require("gui.ui.") (context-specific)
require("widgets.") → require("gui.widgets.")
```

**Batch 3: Research System**
```lua
require("economy.research") → require("basescape.research")
require("geoscape.logic.research_") → require("basescape.research.")
require("widgets.advanced.researchtree") → require("gui.widgets.advanced.researchtree")
```

---

#### 6c. Verify No Broken Requires

After each batch:
```bash
lovec engine  # Run game and check console for errors
# Look for: "module not found", "cannot open"
```

---

### STEP 7: Verify & Remove Old Research Files (1 hour)

Once research is consolidated in basescape/:

```powershell
# Remove old research files from geoscape
Remove-Item "engine\geoscape\logic\research_manager.lua" -Force
Remove-Item "engine\geoscape\logic\research_entry.lua" -Force
Remove-Item "engine\geoscape\logic\research_project.lua" -Force

# Remove old research folder from economy
Remove-Item "engine\economy\research" -Recurse -Force
```

---

### STEP 8: Update Documentation (2 hours)

#### 8a. Update Navigation Guide
File: `wiki/NAVIGATION.md`

Add new section:
```markdown
## Engine Folder Structure

### Content Systems (game data)
- `engine/content/crafts/` - Spacecraft definitions
- `engine/content/items/` - Equipment and items
- `engine/content/units/` - Unit/soldier definitions

### GUI/UI Systems (unified)
- `engine/gui/scenes/` - Scene definitions
- `engine/gui/ui/` - UI screen logic
- `engine/gui/widgets/` - Widget components

### System Folders (match wiki)
- `engine/basescape/` ← Basescape.md (now includes research/)
- `engine/battlescape/` ← Battlescape.md
- `engine/geoscape/` ← Geoscape.md
- ... (etc)
```

---

#### 8b. Create Structure Diagram
File: `engine/STRUCTURE.md` (NEW)

```markdown
# Engine Folder Structure

## Current Organization

```
engine/
├── content/          ← Game content (data-driven)
│   ├── crafts/
│   ├── items/
│   └── units/
├── gui/              ← UI/GUI systems (unified)
│   ├── scenes/
│   ├── ui/
│   └── widgets/
├── basescape/        ← Base management (includes research)
├── battlescape/      ← Tactical combat
├── geoscape/         ← Strategic world
├── economy/          ← Economy systems
├── ai/               ← AI systems
├── core/             ← Core engine
└── ... (other systems)
```

## Wiki Alignment

Each wiki/systems/*.md file maps to an engine/ folder:
- wiki/systems/Basescape.md → engine/basescape/
- wiki/systems/Battlescape.md → engine/battlescape/
- ... (etc)
```

---

#### 8c. Update Project Structure Doc
File: `docs/PROJECT_STRUCTURE.md`

Update "engine/" section to reflect new structure

---

### STEP 9: Test & Verify (2 hours)

#### 9a. Run Game
```bash
lovec "engine"
```

Check console output:
- [ ] No "module not found" errors
- [ ] No "cannot find file" errors
- [ ] All systems initialize successfully
- [ ] Game transitions work

#### 9b. Run Tests
```bash
lua run_tests.bat
```

Verify:
- [ ] All tests pass
- [ ] No broken require paths in tests
- [ ] Test output shows 100% success

#### 9c. Manual Verification
- [ ] Start game, test main menu
- [ ] Test scene transitions
- [ ] Verify GUI displays correctly
- [ ] Test a few systems (basescape, battlescape if runnable)

#### 9d. Documentation Verification
- [ ] Folder structure matches wiki
- [ ] All 19 wiki systems have engine/ folders
- [ ] Navigation guide updated
- [ ] No broken require paths documented

---

## Detailed File-by-File Updates

### Files Likely to Need Require Updates

**Engine Core:**
- engine/main.lua
- engine/conf.lua
- engine/core/state_manager.lua
- engine/core/data_loader.lua
- engine/core/mod_manager.lua

**System Initializers:**
- engine/basescape/main.lua
- engine/battlescape/main.lua
- engine/geoscape/main.lua
- engine/interception/main.lua
- engine/economy/main.lua

**UI/Scene Handlers:**
- engine/scenes/main_menu.lua (→ gui/scenes/)
- engine/ui/battle_ui.lua (→ gui/ui/)
- All scene transition files

**Widget References:**
- engine/ui/menu/main_menu.lua (→ gui/ui/)
- All UI screen files that reference widgets

**Test Files:**
- tests/unit/*.lua
- tests/integration/*.lua
- tests/mock/*.lua

**Mod Files:**
- mods/core/rules/*.lua
- mods/*/init.lua

---

## Risk Mitigation

### Backup Strategy
1. Before starting: `git commit -m "Pre-alignment backup"`
2. After each step: `git commit -m "Step X: [description]"`
3. If broken: `git revert` to last working point

### Testing Strategy
1. Test after folder moves (before require updates)
2. Test after each batch of require updates
3. Test after all changes complete
4. Create test checklist

### Common Mistakes to Avoid
- ❌ Updating requires before moving folders
- ❌ Missing require updates in tests/
- ❌ Mixed old/new path formats
- ❌ Forgetting to remove old folders
- ❌ Not testing after each major change

---

## Time Estimates per Step

| Step | Task | Est. Time | Actual |
|------|------|-----------|--------|
| 1 | Create folders | 0.5h | - |
| 2 | Move content (crafts/items/units) | 1.5h | - |
| 3 | Merge GUI (scenes/ui/widgets) | 3h | - |
| 4 | Fix research system | 3h | - |
| 5 | Verify system folders | 1h | - |
| 6 | Update all requires | 5h | - |
| 7 | Remove old files/research | 1h | - |
| 8 | Update documentation | 2h | - |
| 9 | Test & verify | 2h | - |
| **TOTAL** | | **19h** | - |

---

## Success Criteria

- [x] Audit complete & findings documented
- [ ] New folder structure created (content/, gui/)
- [ ] All content moved to engine/content/
- [ ] All GUI merged into engine/gui/
- [ ] Research system consolidated in basescape/
- [ ] All require() statements updated (100+ changes)
- [ ] No broken requires in codebase
- [ ] Game runs without console errors
- [ ] All tests pass
- [ ] Documentation updated & complete
- [ ] Wiki/engine alignment verified

---

## Status Tracking

**Created:** October 21, 2025  
**Last Updated:** October 21, 2025  
**Next Steps:** Execute STEP 1-3 (folder moves)

