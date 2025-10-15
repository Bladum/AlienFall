# PHASE 4: Wiki Cleanup & Development Preparation
## Transition from Documentation Extraction to Implementation

**Created:** October 15, 2025  
**Status:** TODO  
**Priority:** HIGH  
**Estimated Time:** 4-6 hours total  
**Blocks:** Phase 1 Implementation (Foundation Systems)

---

## 🎯 Objectives

### Primary Goals
1. ✅ Verify complete docs/ structure (27 extracted files)
2. ✅ Delete all 26 extracted wiki/ files (now redundant)
3. ✅ Verify no broken documentation links
4. ✅ Create Phase 1 implementation tasks (Foundation Systems)
5. ✅ Prepare engine/ for development

### Success Criteria
- [ ] All docs/ files verified present and functional
- [ ] All wiki/ files to be deleted identified and logged
- [ ] No cross-reference breakage
- [ ] Phase 1 tasks fully documented and ready
- [ ] Ready to run `lovec "engine"` without errors

---

## 📋 Tasks

### Task 1: Verify docs/ Structure (0.5 hours)
**Objective:** Confirm all 27 Phase 3c extracted files are present and in correct locations

**Verification Checklist:**

**Tier 1 Files (12 - Core Design):**
- [ ] docs/design/ exists with 12+ files
- [ ] docs/FAQ.md exists (2,456 lines)
- [ ] docs/OVERVIEW.md exists
- [ ] docs/GLOSSARY.md exists

**Tier 2 Files (8 - Development Guides):**
- [ ] docs/API.md exists (1,811 lines)
- [ ] docs/DEVELOPMENT.md exists (~1,000 lines)
- [ ] docs/core/LUA_BEST_PRACTICES.md exists (~400 lines)
- [ ] docs/core/LUA_DOCSTRING_GUIDE.md exists (267 lines)
- [ ] docs/battlescape/QUICK_REFERENCE.md exists (129 lines)
- [ ] docs/testing/TESTING.md exists (313 lines)
- [ ] docs/design/REFERENCES.md exists (993 lines)

**Tier 3 Part A - System Architecture (3):**
- [ ] docs/systems/RESOLUTION_SYSTEM_ANALYSIS.md exists (656 lines)
- [ ] docs/systems/TILESET_SYSTEM.md exists (825 lines)
- [ ] docs/systems/FIRE_SMOKE_MECHANICS.md exists (334 lines)

**Tier 3 Part B - Rendering & Balance (3):**
- [ ] docs/rendering/HEX_RENDERING_GUIDE.md exists (611 lines)
- [ ] docs/balance/GAME_NUMBERS.md exists (276 lines)
- [ ] docs/rules/MECHANICAL_DESIGN.md exists (306 lines)

**Command to verify:**
```powershell
# List all docs/ files recursively to verify structure
Get-ChildItem -Path "c:\Users\tombl\Documents\Projects\docs" -Recurse -Include "*.md" | Measure-Object
```

**Expected result:** 27+ .md files across docs/ structure

---

### Task 2: Create Cross-Reference Map (0.5 hours)
**Objective:** Generate a discovery map showing where to find specific information

**Create: docs/QUICK_NAVIGATION.md**

Content to include:
```markdown
# Quick Navigation Guide - Where to Find Information

## 🎮 Core Game Systems
- **Geoscape (Strategic):** docs/geoscape/
- **Basescape (Base Management):** docs/basescape/
- **Battlescape (Combat):** docs/battlescape/
- **Interception:** docs/interception/
- **Economy:** docs/economy/

## 🛠️ Technical Documentation
- **API Reference:** docs/API.md
- **Code Standards:** docs/core/LUA_BEST_PRACTICES.md
- **Docstring Format:** docs/core/LUA_DOCSTRING_GUIDE.md
- **Development Guide:** docs/DEVELOPMENT.md
- **Testing Framework:** docs/testing/TESTING.md

## ⚙️ System Architecture
- **Resolution System:** docs/systems/RESOLUTION_SYSTEM_ANALYSIS.md
- **Tileset System:** docs/systems/TILESET_SYSTEM.md
- **Fire & Smoke Mechanics:** docs/systems/FIRE_SMOKE_MECHANICS.md
- **Hex Rendering:** docs/rendering/HEX_RENDERING_GUIDE.md
- **Game Balance Numbers:** docs/balance/GAME_NUMBERS.md
- **Mechanical Design:** docs/rules/MECHANICAL_DESIGN.md

## 📚 Reference
- **FAQ:** docs/FAQ.md
- **Glossary:** docs/GLOSSARY.md
- **Project Structure:** docs/PROJECT_STRUCTURE.md
- **References & Links:** docs/design/REFERENCES.md

## 📋 Implementation Tasks
- **Master Plan:** tasks/TODO/MASTER-IMPLEMENTATION-PLAN.md
- **Phase 1 Tasks:** tasks/TODO/01-BATTLESCAPE/*, tasks/TODO/02-GEOSCAPE/*, etc.
- **Completed Tasks:** tasks/DONE/

## 🎓 Learning Resources
- **Getting Started:** docs/DEVELOPMENT.md
- **Code Quality:** docs/core/LUA_BEST_PRACTICES.md + LUA_DOCSTRING_GUIDE.md
- **Game Mechanics:** docs/FAQ.md
- **Balance Reference:** docs/balance/GAME_NUMBERS.md
```

---

### Task 3: Identify Wiki Files for Deletion (1 hour)
**Objective:** Create definitive list of all wiki/ files to delete

**Actions:**

1. List all files currently in wiki/ folder:
```powershell
Get-ChildItem -Path "c:\Users\tombl\Documents\Projects\wiki" -Recurse -Include "*.md" | Select-Object FullName
```

2. Create **tasks/TODO/WIKI-FILES-TO-DELETE.md** documenting:
   - All files marked for deletion
   - Where their content was extracted to
   - Verification that no content was lost

**Files to Delete (Expected 26-30 files):**

```markdown
# Wiki Files Scheduled for Deletion

## Tier 1-3 Extracted Files (All migrated to docs/)
- wiki/API.md → docs/API.md ✅
- wiki/DEVELOPMENT.md → docs/DEVELOPMENT.md ✅
- wiki/FAQ.md → docs/FAQ.md ✅
- wiki/LUA_BEST_PRACTICES.md → docs/core/LUA_BEST_PRACTICES.md ✅
- wiki/LUA_DOCSTRING_GUIDE.md → docs/core/LUA_DOCSTRING_GUIDE.md ✅
- wiki/QUICK_REFERENCE.md → docs/battlescape/QUICK_REFERENCE.md ✅
- wiki/TESTING.md → docs/testing/TESTING.md ✅
- wiki/references.md → docs/design/REFERENCES.md ✅
- wiki/RESOLUTION_SYSTEM_ANALYSIS.md → docs/systems/RESOLUTION_SYSTEM_ANALYSIS.md ✅
- wiki/TILESET_SYSTEM.md → docs/systems/TILESET_SYSTEM.md ✅
- wiki/FIRE_SMOKE_MECHANICS.md → docs/systems/FIRE_SMOKE_MECHANICS.md ✅
- wiki/HEX_RENDERING_GUIDE.md → docs/rendering/HEX_RENDERING_GUIDE.md ✅
- wiki/numbers.md → docs/balance/GAME_NUMBERS.md ✅
- wiki/rules ideas.md → docs/rules/MECHANICAL_DESIGN.md ✅

[... more files ...]

## Archival (Keep in wiki/internal/archive/)
- wiki/MIGRATION_GUIDE.md → wiki/internal/archive/MIGRATION_GUIDE.md ✅

## Status
**Total to delete:** XX files
**Already deleted:** 0 files
**Archive preserved:** 1 file (MIGRATION_GUIDE)
**Ready to proceed:** YES ✅
```

---

### Task 4: Create Phase 1 Implementation Tasks (2 hours)
**Objective:** Generate 3 foundational task files for Phase 1 development

**Create 3 new tasks in tasks/TODO/02-GEOSCAPE/:**

#### 4a. PHASE-1.1-GEOSCAPE-CORE-IMPLEMENTATION.md
```
Geoscape Core (Week 1) - 80 hours
- Hex world map (80×40 = 3,200 hex tiles, 500km/tile)
- Province system with biome classification
- Hex pathfinding for craft travel routes
- Calendar/turn system (1 turn = 1 day)
- Basic strategic UI (world view, province info, deployment)

Files to create/modify:
- engine/core/world/ (new)
- engine/core/calendar.lua (new)
- engine/geoscape/geoscape_ui.lua
- mods/core/data/provinces.toml (new)

Tests:
- Test hex pathfinding accuracy
- Test calendar advancement
- Test province classification
- Test world map rendering

Completion criteria:
- Can navigate world with mouse/keyboard
- Can see provinces with biome colors
- Can advance time and see calendar update
- Can see 80×40 hex grid on screen
```

#### 4b. PHASE-1.2-MAP-GENERATION-SYSTEM.md
```
Map Generation (Week 2) - 60 hours
- Procedural mission map generation
- Biome → Terrain mapping
- MapBlock asset selection
- Squad placement (player/ally/enemy/neutral)
- Integration with existing battlescape

Files to create/modify:
- engine/battlescape/map_generator.lua (new)
- engine/battlescape/biome_terrain_mapper.lua (new)
- mods/core/data/map_generation.toml (new)

Tests:
- Test biome → terrain conversion
- Test MapBlock selection
- Test unit placement validity
- Test map generation performance

Completion criteria:
- Generate 4×4 to 7×7 tile battlefield
- Proper squad placement
- <2 second generation time
- No impassable terrain traps
```

#### 4c. PHASE-1.3-MISSION-DETECTION-CAMPAIGN-LOOP.md
```
Mission Detection & Campaign Loop (Week 3) - 45 hours
- Daily mission detection (% chance per province)
- Mission type generation (site investigation, UFO crash, defense, etc.)
- Mission urgency/expiration system
- Campaign state tracking (victories, defeats, score)
- Mission reward calculation

Files to create/modify:
- engine/geoscape/mission_detection.lua (new)
- engine/geoscape/campaign_manager.lua (new)
- engine/geoscape/mission_types.lua (new)
- mods/core/data/mission_types.toml (new)

Tests:
- Test mission spawning rates
- Test mission type distribution
- Test urgency timing
- Test reward calculation

Completion criteria:
- Missions spawn daily in provinces
- Mission timer system working
- Player can select mission and deploy
- Campaign state properly tracked
```

---

### Task 5: Update tasks/tasks.md (0.5 hours)
**Objective:** Update main task tracking file with Phase 4 progress

**Actions:**
1. Add Phase 4 section to tasks.md header
2. List all 3 Phase 1 tasks as TODO
3. Add note about wiki deletion step
4. Create summary table

**Content to add to tasks.md:**
```markdown
---

## 🚀 PHASE 4: WIKI CLEANUP & DEVELOPMENT PREPARATION (October 15, 2025)

**Status:** IN PROGRESS  
**Objective:** Clean up documentation and prepare for Phase 1 implementation  
**Duration:** 4-6 hours  
**Blocks:** Phase 1 Development

### Progress
- [ ] Task 1: Verify docs/ structure (27 files)
- [ ] Task 2: Create cross-reference map
- [ ] Task 3: Identify wiki deletion files
- [ ] Task 4: Create Phase 1 implementation tasks
- [ ] Task 5: Update task tracking

### Phase 1 Foundation Systems Tasks (Ready after Phase 4)

#### 🎯 PHASE 1.1: GEOSCAPE CORE (80 hours - Week 1)
**File:** tasks/TODO/02-GEOSCAPE/PHASE-1.1-GEOSCAPE-CORE-IMPLEMENTATION.md
**Status:** READY FOR DEVELOPMENT
- Hex world map (80×40 grid)
- Province system with biomes
- Hex pathfinding for crafts
- Calendar/turn system

#### 🎯 PHASE 1.2: MAP GENERATION (60 hours - Week 2)
**File:** tasks/TODO/01-BATTLESCAPE/PHASE-1.2-MAP-GENERATION-SYSTEM.md
**Status:** READY FOR DEVELOPMENT
- Procedural mission map generation
- Biome→Terrain mapping
- MapBlock selection
- Squad placement

#### 🎯 PHASE 1.3: MISSION DETECTION (45 hours - Week 3)
**File:** tasks/TODO/02-GEOSCAPE/PHASE-1.3-MISSION-DETECTION-CAMPAIGN-LOOP.md
**Status:** READY FOR DEVELOPMENT
- Daily mission detection
- Mission type generation
- Campaign loop management
- Mission rewards

**Total Phase 1 Effort:** 185 hours (3 weeks for solo dev)

---
```

---

### Task 6: Delete Wiki Files (1 hour)
**Objective:** Remove all redundant wiki/ files (content preserved in docs/)

**Commands:**
```powershell
# Option 1: Delete specific files (safer)
$filesToDelete = @(
    "wiki/API.md",
    "wiki/DEVELOPMENT.md",
    "wiki/FAQ.md",
    "wiki/LUA_BEST_PRACTICES.md",
    "wiki/LUA_DOCSTRING_GUIDE.md",
    "wiki/QUICK_REFERENCE.md",
    "wiki/TESTING.md",
    "wiki/references.md",
    "wiki/RESOLUTION_SYSTEM_ANALYSIS.md",
    "wiki/TILESET_SYSTEM.md",
    "wiki/FIRE_SMOKE_MECHANICS.md",
    "wiki/HEX_RENDERING_GUIDE.md",
    "wiki/numbers.md",
    "wiki/rules ideas.md"
    # ... more files
)

foreach ($file in $filesToDelete) {
    $fullPath = "c:\Users\tombl\Documents\Projects\$file"
    if (Test-Path $fullPath) {
        Remove-Item $fullPath -Force
        Write-Host "✅ Deleted: $file"
    }
}

# Option 2: Delete entire wiki/ (if empty after file deletion)
Remove-Item "c:\Users\tombl\Documents\Projects\wiki" -Recurse -Force
```

**Verification:**
```powershell
# Verify wiki/ is gone or only contains archive/
Get-ChildItem -Path "c:\Users\tombl\Documents\Projects\wiki" -Recurse | Where-Object { $_.Name -notlike "*archive*" }
```

---

### Task 7: Verify No Broken References (0.5 hours)
**Objective:** Check that no code references removed wiki/ files

**Search for "wiki/" references in codebase:**
```powershell
# Search in engine/
Select-String -Path "c:\Users\tombl\Documents\Projects\engine\**\*.lua" -Pattern "wiki/" -Recurse

# Search in docs/
Select-String -Path "c:\Users\tombl\Documents\Projects\docs\**\*.md" -Pattern "wiki/" -Recurse

# Expected: Should find only archive references or historical notes
```

**Expected output:** 0 broken references (only archive/ path should appear)

---

### Task 8: Validation & Sign-Off (0.5 hours)
**Objective:** Confirm Phase 4 complete and Phase 1 ready to start

**Checklist:**

**Documentation:**
- [ ] 27 extracted files verified in docs/
- [ ] Cross-reference map created (QUICK_NAVIGATION.md)
- [ ] Wiki deletion log documented
- [ ] No broken references in codebase

**Implementation Tasks:**
- [ ] PHASE-1.1-GEOSCAPE-CORE-IMPLEMENTATION.md created
- [ ] PHASE-1.2-MAP-GENERATION-SYSTEM.md created
- [ ] PHASE-1.3-MISSION-DETECTION-CAMPAIGN-LOOP.md created
- [ ] All 3 tasks properly formatted with objectives and deliverables

**Project State:**
- [ ] engine/ ready for development (no compilation errors)
- [ ] Can run `lovec "engine"` without errors
- [ ] Console shows clean startup
- [ ] tasks/tasks.md updated with Phase 1

**Sign-Off:**
```
✅ Phase 4 Complete
✅ Documentation Cleaned
✅ Phase 1 Foundation Tasks Ready
✅ Ready to Proceed with Development
```

---

## 📊 Summary

### What's Happening
1. **Verification:** Confirm all 27 Phase 3c extracted docs/ files are present
2. **Navigation:** Create quick reference guide for where to find information
3. **Cleanup:** Delete 26 redundant wiki/ files (content preserved)
4. **Preparation:** Create 3 Phase 1 task files ready for development
5. **Validation:** Ensure no broken references, project is ready to run

### Timeline
- **Task 1:** 0.5 hours (verification)
- **Task 2:** 0.5 hours (navigation map)
- **Task 3:** 1 hour (deletion list)
- **Task 4:** 2 hours (Phase 1 tasks)
- **Task 5:** 0.5 hours (task tracking update)
- **Task 6:** 1 hour (delete wiki files)
- **Task 7:** 0.5 hours (reference verification)
- **Task 8:** 0.5 hours (validation)

**Total:** 6.5 hours

### Success Metrics
- ✅ 27/27 docs/ files verified
- ✅ 26 wiki/ files deleted
- ✅ 0 broken documentation links
- ✅ 3 Phase 1 tasks documented
- ✅ engine/ ready to run
- ✅ Phase 1 can start immediately after

### Next Phase
**PHASE 1: FOUNDATION SYSTEMS (Weeks 1-3, 185 hours)**
- Week 1: Geoscape Core (80 hours)
- Week 2: Map Generation System (60 hours)
- Week 3: Mission Detection & Campaign Loop (45 hours)

---

## 📝 Notes

### Important
- **All Phase 3c content preserved** in docs/ before deletion
- **Archive maintained** at wiki/internal/archive/ for historical reference
- **No data loss risk** - all wiki/ files are redundant copies

### Future Improvements
- Consider migrating docs/ to central documentation website
- Generate API documentation from code (docstrings)
- Create visual architecture diagrams
- Set up automated documentation generation

### Dependencies
- Phase 4 must complete before Phase 1 starts
- Phase 1 requires docs/ structure to be stable
- Implementation will reference docs/ frequently

---

**Status:** Ready to Execute Phase 4  
**Created:** October 15, 2025  
**Assignee:** Development Team  
**Owner:** Project Lead
