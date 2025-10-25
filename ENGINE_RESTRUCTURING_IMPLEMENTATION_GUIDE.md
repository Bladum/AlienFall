# ENGINE RESTRUCTURING IMPLEMENTATION GUIDE

**Date:** October 25, 2025  
**Status:** Ready for Execution  
**Total Phases:** 6 (plus Phase 0 setup)  
**Estimated Total Time:** 6-8 hours

---

## TABLE OF CONTENTS
1. Phase 0: Setup & Backup (30 min)
2. Phase 1: Eliminate Duplicates (2-3 hours)
3. Phase 2: Organize Geoscape (1 hour)
4. Phase 3: Restructure Battlescape (1.5 hours)
5. Phase 4: Organize Core Systems (1 hour)
6. Phase 5: Comprehensive Testing (1-2 hours)
7. Phase 6: Documentation & Commit (30 min)

---

## ⚠️ CRITICAL PREREQUISITES

Before starting ANY phase:

1. **Ensure console is available:**
   ```bash
   cd c:\Users\tombl\Documents\Projects
   # Verify love is available
   where lovec
   ```

2. **Verify git status is clean:**
   ```bash
   git status
   # Should show: "nothing to commit, working tree clean"
   ```

3. **Backup current state locally:**
   ```bash
   # Just run one test to ensure everything works
   lovec tests/runners
   ```

4. **Create tracking document** (copy RESTRUCTURING_IMPLEMENTATION_LOG.md)

---

## PHASE 0: SETUP & BACKUP

**Duration:** 30 minutes  
**Goal:** Prepare for safe restructuring with git branches and backups

### Step 0.1: Create Git Branch

```bash
cd c:\Users\tombl\Documents\Projects

# Create phase-specific branch
git checkout -b engine-restructure-phase-1
# Output: Switched to a new branch 'engine-restructure-phase-1'

# Verify you're on new branch
git branch
# Output: * engine-restructure-phase-1
#           engine-restructure
#           main
```

### Step 0.2: Verify Engine Structure

```bash
# Count files before restructuring
Get-ChildItem -Recurse -Path "engine" -File | Measure-Object | Select-Object Count
# Expected: 443

# List all subsystem folders
Get-ChildItem -Path "engine" -Directory | Select-Object Name
```

### Step 0.3: Create Restructuring Tools Directory

```bash
# Create directory for tracking tools
mkdir -Force "engine\restructuring_tools"

# Create file list for reference
Get-ChildItem -Recurse -Path "engine" -File | `
  Select-Object @{n='Path';e={$_.FullName -replace 'C:\\Users\\tombl\\Documents\\Projects\\', ''}} | `
  ConvertTo-Csv -NoTypeInformation | `
  Out-File "engine\restructuring_tools\original_file_list.csv"
```

### Step 0.4: Document Current Baseline

```bash
# Save current file structure
tree engine /F /A > engine\restructuring_tools\original_structure.txt 2>$null
```

### Step 0.5: Run Initial Test Suite

```bash
# Ensure everything works before changes
lovec tests/runners

# Should see all tests pass (green output)
# Note: Save console output if there are any warnings
```

### Step 0.6: Verify Import Baseline

```bash
# Find all "require" statements as baseline
grep -r "require.*engine" engine/ --include="*.lua" | `
  wc -l
# Note the count for later comparison
```

---

## PHASE 1: ELIMINATE DUPLICATES

**Duration:** 2-3 hours  
**Goal:** Delete 18 duplicate files, rename 4 files for clarity, preserve 5 intentional duplicates

### Prerequisites
- Phase 0 completed
- DUPLICATE_RESOLUTION_PLAN.md reviewed
- git branch created

### Critical: Duplicate Processing Order

**PROCESS EACH DUPLICATE IN THIS ORDER:**

For **EACH** duplicate group:
1. Find all imports of the file
2. Identify which version to KEEP/DELETE/RENAME
3. Update imports in ALL files
4. Delete/rename the file
5. Run tests (AFTER EACH GROUP)
6. Commit (AFTER EACH GROUP)

### GROUP 1: base_manager.lua

**Keeping:** `engine/basescape/base_manager.lua`  
**Deleting:** `engine/logic/base_manager.lua`, `engine/systems/base_manager.lua`

```bash
# Step 1: Find all imports
grep -r "logic/base_manager\|systems/base_manager" engine/ --include="*.lua"
# Note ALL files that import these

# Step 2: Update imports (if any found)
# Edit each file found above and change:
# FROM: require("engine.logic.base_manager") or require("engine.systems.base_manager")
# TO:   require("engine.basescape.base_manager")

# Step 3: Delete duplicate files
Remove-Item -Force "engine\logic\base_manager.lua" -ErrorAction SilentlyContinue
Remove-Item -Force "engine\systems\base_manager.lua" -ErrorAction SilentlyContinue

# Step 4: Verify deletion
Get-ChildItem -Path "engine" -Filter "base_manager.lua" -Recurse
# Should only show: engine/basescape/base_manager.lua

# Step 5: Run tests
lovec tests/runners
# All tests should pass. If they fail, CHECK IMPORTS IN PREVIOUS STEP

# Step 6: Commit
git add -A
git commit -m "refactor: consolidate base_manager duplicates to basescape/ (Phase 1)"
```

### GROUP 2: los_system.lua

**Keeping:** `engine/battlescape/systems/los_system.lua`  
**Deleting:** `engine/battlescape/combat/los_system.lua`

```bash
grep -r "battlescape/combat/los_system" engine/ --include="*.lua"

# Update any imports found to point to systems/ version

Remove-Item -Force "engine\battlescape\combat\los_system.lua" -ErrorAction SilentlyContinue

lovec tests/runners

git add -A
git commit -m "refactor: consolidate los_system duplicates to battlescape/systems/ (Phase 1)"
```

### GROUP 3: morale_system.lua

**Keeping:** `engine/battlescape/systems/morale_system.lua`  
**Deleting:** `engine/battlescape/combat/morale_system.lua`

```bash
grep -r "battlescape/combat/morale_system" engine/ --include="*.lua"

# Update any imports

Remove-Item -Force "engine\battlescape\combat\morale_system.lua" -ErrorAction SilentlyContinue

lovec tests/runners

git add -A
git commit -m "refactor: consolidate morale_system duplicates to battlescape/systems/ (Phase 1)"
```

### GROUP 4: flanking_system.lua

**Keeping:** `engine/battlescape/combat/flanking_system.lua`  
**Deleting:** `engine/battlescape/systems/flanking_system.lua`

```bash
grep -r "battlescape/systems/flanking_system" engine/ --include="*.lua"

Remove-Item -Force "engine\battlescape\systems\flanking_system.lua" -ErrorAction SilentlyContinue

lovec tests/runners

git add -A
git commit -m "refactor: consolidate flanking_system duplicates to battlescape/combat/ (Phase 1)"
```

### GROUP 5: pathfinding.lua (RENAME)

**Action:** Rename both files to clarify purpose

```bash
# Geoscape version - strategic
Rename-Item -Path "engine\geoscape\pathfinding.lua" -NewName "strategic_pathfinding.lua"

# Battlescape version - tactical
Rename-Item -Path "engine\battlescape\pathfinding.lua" -NewName "tactical_pathfinding.lua"

# Find all imports of "pathfinding"
grep -r "require.*pathfinding" engine/ --include="*.lua"

# For EACH result:
# - If in geoscape context: change to strategic_pathfinding
# - If in battlescape context: change to tactical_pathfinding

lovec tests/runners

git add -A
git commit -m "refactor: rename pathfinding files to distinguish strategic vs tactical (Phase 1)"
```

### CONTINUE WITH REMAINING DUPLICATES

Process each remaining duplicate group using the same pattern:

1. Find imports: `grep -r "search_pattern" engine/ --include="*.lua"`
2. Update imports in affected files
3. Delete or rename files
4. Run tests
5. Commit each change

**Remaining groups to process (continue same procedure):**
- GROUP 6-27 (see DUPLICATE_RESOLUTION_PLAN.md for each)

---

## PHASE 2: ORGANIZE GEOSCAPE

**Duration:** 1 hour  
**Goal:** Move 24 geoscape root files into 7 organized folders

### Target Structure

```
engine/geoscape/
├── managers/
│   ├── geoscape_manager.lua
│   ├── continent_manager.lua
│   ├── country_manager.lua
│   ├── region_manager.lua
│   └── faction_manager.lua
├── systems/
│   ├── mission_system.lua
│   ├── squad_system.lua
│   ├── craft_system.lua
│   └── interception_system.lua
├── logic/
│   ├── diplomacy_logic.lua
│   ├── politics_logic.lua
│   └── campaign_logic.lua
├── processing/
│   ├── research_processor.lua
│   ├── economy_processor.lua
│   └── facility_processor.lua
├── state/
│   └── geoscape_state.lua
├── audio/
│   └── (audio-related files)
└── ai/
    └── (ai strategy files)
```

### Step 2.1: Create Target Folders

```bash
mkdir -Force "engine\geoscape\managers"
mkdir -Force "engine\geoscape\systems"
mkdir -Force "engine\geoscape\logic"
mkdir -Force "engine\geoscape\processing"
mkdir -Force "engine\geoscape\state"
mkdir -Force "engine\geoscape\audio"
mkdir -Force "engine\geoscape\ai"
```

### Step 2.2: Move Files

```bash
# Move manager files
Move-Item "engine\geoscape\geoscape_manager.lua" "engine\geoscape\managers\"
Move-Item "engine\geoscape\continent_manager.lua" "engine\geoscape\managers\"
Move-Item "engine\geoscape\country_manager.lua" "engine\geoscape\managers\"
Move-Item "engine\geoscape\region_manager.lua" "engine\geoscape\managers\"
Move-Item "engine\geoscape\faction_manager.lua" "engine\geoscape\managers\"

# Move system files
Move-Item "engine\geoscape\mission_system.lua" "engine\geoscape\systems\"
Move-Item "engine\geoscape\squad_system.lua" "engine\geoscape\systems\"
Move-Item "engine\geoscape\craft_system.lua" "engine\geoscape\systems\"
Move-Item "engine\geoscape\interception_system.lua" "engine\geoscape\systems\"

# Continue for other categories...
```

### Step 2.3: Update All Imports

```bash
# Find all requires of geoscape modules
grep -r "engine\.geoscape\." engine/ --include="*.lua"

# For EACH result, update the path:
# FROM: require("engine.geoscape.geoscape_manager")
# TO:   require("engine.geoscape.managers.geoscape_manager")
```

### Step 2.4: Delete Empty Folders

```bash
# Remove original empty subfolders
Get-ChildItem "engine\geoscape" -Directory | Where-Object { `
  @(Get-ChildItem -Path $_.FullName -Recurse -File).Count -eq 0 `
} | Remove-Item -Recurse -Force
```

### Step 2.5: Validate & Commit

```bash
lovec tests/runners

# Verify no geoscape files remain at root
Get-ChildItem -Path "engine\geoscape" -File -Depth 0 | Select-Object Name

git add -A
git commit -m "refactor: organize geoscape into 7 folders by concern (Phase 2)"
```

---

## PHASE 3: RESTRUCTURE BATTLESCAPE

**Duration:** 1.5 hours  
**Goal:** Flatten battlescape, organize into 8 folders, remove 18+ empty folders

### Target Structure

```
engine/battlescape/
├── managers/
│   └── battlescape_manager.lua
├── map_system/
│   ├── map_manager.lua
│   ├── map_generation.lua
│   └── procedural_gen.lua
├── combat/
│   ├── combat_manager.lua
│   ├── action_resolver.lua
│   ├── los_system.lua
│   ├── morale_system.lua
│   ├── flanking_system.lua
│   └── tactical_logic.lua
├── effects/
│   ├── effect_system.lua
│   ├── particle_system.lua
│   ├── animation_system.lua
│   └── ...
├── ai/
│   ├── battlescape_ai.lua
│   ├── unit_ai.lua
│   └── squad_ai.lua
├── ecs/
│   ├── entity_system.lua
│   ├── component_system.lua
│   ├── system_base.lua
│   └── ...
├── rendering/
│   ├── battlescape_renderer.lua
│   ├── unit_renderer.lua
│   ├── map_renderer.lua
│   └── ...
└── ui/
    ├── battlescape_ui.lua
    ├── hud.lua
    ├── status_panel.lua
    └── ...
```

### Procedure (Similar to Phase 2)

1. **Create target folders** (8 new directories)
2. **Identify all battlescape files** at all nesting levels
3. **Analyze each file** to determine correct folder
4. **Move files** to target folders
5. **Update all imports** throughout engine
6. **Delete empty nested folders**
7. **Run tests** - verify all pass
8. **Commit** with message "refactor: flatten battlescape, organize into 8 folders (Phase 3)"

---

## PHASE 4: ORGANIZE CORE SYSTEMS

**Duration:** 1 hour  
**Goal:** Move core 15 mixed files into 8 organized folders by concern

### Target Structure

```
engine/core/
├── state/
│   ├── state_manager.lua
│   ├── state_transition.lua
│   └── state_persistence.lua
├── assets/
│   ├── asset_loader.lua
│   ├── asset_cache.lua
│   └── asset_manager.lua
├── audio/
│   ├── audio_manager.lua
│   ├── audio_mixer.lua
│   └── audio_effects.lua
├── data/
│   ├── data_loader.lua
│   ├── data_serializer.lua
│   └── data_validator.lua
├── events/
│   ├── event_system.lua
│   ├── event_bus.lua
│   └── event_handlers.lua
├── ui/
│   ├── gui_base.lua
│   ├── gui_framework.lua
│   └── gui_manager.lua
├── systems/
│   ├── initialization.lua
│   ├── shutdown.lua
│   └── lifecycle.lua
└── entities/
    ├── entity_base.lua
    ├── entity_manager.lua
    └── entity_pool.lua
```

### Procedure

Same as Phase 2 and 3:
1. Create 8 target folders
2. Move 15 files into appropriate folders
3. Update all imports
4. Delete empty nested folders
5. Run tests
6. Commit

---

## PHASE 5: COMPREHENSIVE TESTING & VALIDATION

**Duration:** 1-2 hours  
**Goal:** Verify all changes work correctly, no imports broken, game fully functional

### Step 5.1: Run Full Test Suite

```bash
# Run all test categories
lovec tests/runners

# Record output - should see all PASS
```

### Step 5.2: Verify File Count

```bash
# Should be 443 - 18 = 425 files (if duplicates deleted)
Get-ChildItem -Recurse -Path "engine" -File | Measure-Object | Select-Object Count
```

### Step 5.3: Check for Broken Imports

```bash
# Find all require statements
grep -r "require" engine/ --include="*.lua" | grep -v "-- " > imports_log.txt

# Look for common patterns of broken imports:
# - require("engine.deleted_file")
# - require("path/that/no/longer/exists")
# - OLD_REQUIRES patterns

grep -r "require.*logic/base_manager" engine/ --include="*.lua"
# Should return ZERO results (file was deleted)

grep -r "require.*combat/los_system" engine/ --include="*.lua"
# Should return ZERO results (file was deleted)
```

### Step 5.4: Launch Game & Test

```bash
# Run game with debug console
lovec engine

# Expected behavior:
# 1. Game window opens
# 2. No console errors
# 3. Main menu appears
# 4. Can navigate through UI
# 5. Can start battlescape
# 6. Game responds to input

# Let it run for 30 seconds, then close with ALT+F4
```

### Step 5.5: Validate Import Graph

```bash
# Create import map to verify no circular dependencies
lua restructuring_tools/validate_restructuring.lua

# Output should show:
# ✓ No circular imports detected
# ✓ All imports valid
# ✓ No orphaned files
```

### Step 5.6: Check for Empty Folders

```bash
# List any remaining empty folders
Get-ChildItem -Path "engine" -Recurse -Directory | Where-Object { `
  @(Get-ChildItem -Path $_.FullName -File).Count -eq 0 `
} | Select-Object FullName

# Should be minimal (maybe just old placeholder folders)
```

### Step 5.7: Create Validation Report

```bash
# Document the results
echo "=== RESTRUCTURING VALIDATION REPORT ===" > restructuring_tools/validation_report.txt
echo "Date: $(Get-Date)" >> restructuring_tools/validation_report.txt
echo "Files remaining: 425" >> restructuring_tools/validation_report.txt
echo "Tests: PASS" >> restructuring_tools/validation_report.txt
echo "Import validation: PASS" >> restructuring_tools/validation_report.txt
echo "Game launch: PASS" >> restructuring_tools/validation_report.txt
```

---

## PHASE 6: DOCUMENTATION & FINAL COMMIT

**Duration:** 30 minutes  
**Goal:** Update documentation, create PR summary, finalize changes

### Step 6.1: Update Architecture Docs

```bash
# Update architecture/README.md to reflect new structure

# Update architecture/01-game-structure.md with new diagrams

# Example content to add:
# "The engine is now organized into clear subsystems:
#  - Geoscape: Strategic layer with 7 organized folders
#  - Battlescape: Tactical combat with 8 organized folders
#  - Basescape: Base management with dedicated structure
#  - Core: Foundation systems organized by concern
#  - And more..."
```

### Step 6.2: Update API Documentation Reference

```bash
# Create mapping between API docs and engine folders
# Save to docs/API_ENGINE_MAPPING.md

# Show how each API file maps to engine implementation
```

### Step 6.3: Create Migration Guide

```bash
# Document the changes for team
# Save to docs/ENGINE_RESTRUCTURING_MIGRATION.md

# Include:
# - What changed
# - Why it changed
# - How to import from new locations
# - Examples of updated import statements
```

### Step 6.4: Verify All Documentation

```bash
# Check that all documentation files are up-to-date
Get-ChildItem -Path "docs", "architecture", "api" -Filter "*.md" -Recurse | `
  Select-Object FullName
```

### Step 6.5: Final Git Commit

```bash
git add -A
git commit -m "docs: update architecture and api mapping after engine restructuring (Phase 6)"

# Verify all commits
git log --oneline | head -10

# Should see:
# - Phase 6 commit
# - Phase 5 commits
# - Phase 4 commits
# - ... all the way back to Phase 1
```

### Step 6.6: Create Pull Request

```bash
# Switch to engine-restructure branch
git checkout engine-restructure

# Merge phase-1 branch into engine-restructure
git merge engine-restructure-phase-1

# Push to remote (if applicable)
git push origin engine-restructure

# Create PR with summary:
# Title: "Engine Restructuring - All Phases Complete"
# Body:
# "This PR completes the full engine restructuring:
#
#  ✅ Phase 1: Eliminated 18 duplicates, renamed 4 files
#  ✅ Phase 2: Organized geoscape (24 files → 7 folders)
#  ✅ Phase 3: Flattened battlescape (40+ files → 8 folders)
#  ✅ Phase 4: Organized core systems (15 files → 8 folders)
#  ✅ Phase 5: Comprehensive validation - all tests pass
#  ✅ Phase 6: Documentation updated
#
#  Total Changes:
#  - 443 Lua files reorganized
#  - 18 duplicates eliminated
#  - 4 files renamed for clarity
#  - 50+ empty folders removed
#  - Professional structure achieved
#
#  All tests passing. Game fully functional."
```

---

## TROUBLESHOOTING GUIDE

### Problem: "Cannot find module" error after moving files

**Cause:** Imports not updated  
**Solution:**
```bash
# Find the old import path
grep -r "module_name" engine/ --include="*.lua"

# Update to new path
# Rerun tests
lovec tests/runners
```

### Problem: Tests fail after Phase X

**Cause:** Likely broken import  
**Solution:**
1. Check console output for specific error
2. Note the module name
3. Find all imports: `grep -r "module_name" engine/`
4. Verify files exist at imported paths
5. Update imports or restore files if needed

### Problem: Game won't start

**Cause:** Could be circular import or critical file moved wrong  
**Solution:**
```bash
# Check if main.lua can be loaded
lua -c engine/main.lua

# Run with more verbose output
lovec engine 2>&1 | head -50

# Roll back last change if needed
git revert HEAD
```

### Problem: Can't find where file moved to

**Solution:**
```bash
# Find any file by name
Get-ChildItem -Path "engine" -Filter "filename.lua" -Recurse

# Find all recent moves in git log
git log --name-status --oneline | grep -A 5 -B 5 "filename"
```

---

## EMERGENCY ROLLBACK

If something goes seriously wrong:

```bash
# Option 1: Rollback last commit
git revert HEAD
lovec tests/runners

# Option 2: Rollback to Phase start
git reset --hard engine-restructure
lovec tests/runners

# Option 3: Rollback entire branch
git checkout main
rm -Recurse -Force .git/engine-restructure-phase-1
```

---

## SUCCESS CRITERIA CHECKLIST

After ALL phases complete:

- [ ] All 425 files present (443 - 18 deleted duplicates)
- [ ] No files named same across subsystems (duplicates resolved)
- [ ] All tests pass (unit, integration, system)
- [ ] Geoscape organized (24 files in 7 folders)
- [ ] Battlescape flat (no 18+ empty folders, 8 organized folders)
- [ ] Core organized (15 files in 8 folders by concern)
- [ ] Basescape ready for development (clear structure)
- [ ] All imports valid (grep shows zero broken imports)
- [ ] Game launches successfully
- [ ] Game fully playable (UI responsive, systems functional)
- [ ] Architecture docs updated
- [ ] Migration guide created
- [ ] All commits meaningful and atomic
- [ ] PR summary complete

---

## QUICK REFERENCE COMMANDS

```bash
# Count Lua files
Get-ChildItem -Recurse -Path "engine" -File | Measure-Object | Select-Object Count

# Find all imports
grep -r "require.*engine" engine/ --include="*.lua" | wc -l

# Find specific file duplicates
Get-ChildItem -Path "engine" -Filter "filename.lua" -Recurse

# List all empty folders
Get-ChildItem -Path "engine" -Recurse -Directory | Where-Object { `
  @(Get-ChildItem -Path $_.FullName -File).Count -eq 0 `
}

# Run tests
lovec tests/runners

# Run game
lovec engine

# Create git branch
git checkout -b engine-restructure-phase-1

# Commit changes
git add -A
git commit -m "message"
```

---

**Status:** Ready to execute  
**Estimated Total Time:** 6-8 hours  
**Next Step:** Start Phase 0
