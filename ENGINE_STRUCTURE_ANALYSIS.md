# ENGINE STRUCTURE ANALYSIS

**Analysis Date:** October 25, 2025  
**Status:** COMPLETE  
**Files Analyzed:** 443 Lua files across 17 subsystems

---

## EXECUTIVE SUMMARY

The AlienFall engine contains 443 Lua files organized across 17 subsystems with significant structural issues:

- **27 duplicate file groups** causing maintenance confusion
- **24 geoscape files at root level** with no organization
- **48 mostly-empty directories** cluttering the structure
- **Core systems mixed without concern separation**
- **API documentation misaligned** with engine implementation
- **Inconsistent naming conventions** throughout

**Solution:** 6-phase restructuring to organize all systems into clear, manageable hierarchies.

---

## CRITICAL FINDINGS

### 1. DUPLICATE FILES (27 Groups Identified)

| Filename | Count | Location(s) | Decision |
|----------|-------|-------------|----------|
| base_manager.lua | 3 | basescape/, logic/, systems/ | KEEP basescape/, DELETE others |
| los_system.lua | 2 | battlescape/systems/, battlescape/combat/ | KEEP systems/, DELETE combat/ |
| morale_system.lua | 2 | battlescape/systems/, battlescape/combat/ | KEEP systems/, DELETE combat/ |
| flanking_system.lua | 2 | battlescape/combat/, battlescape/systems/ | KEEP combat/, DELETE systems/ |
| pathfinding.lua | 2 | geoscape/, battlescape/ | RENAME: strategic_pathfinding.lua, tactical_pathfinding.lua |
| audio_manager.lua | 3 | core/, audio/, content/ | CONSOLIDATE to core/ |
| state_manager.lua | 2 | core/, basescape/ | KEEP core/, DELETE basescape/ |
| research_system.lua | 2 | basescape/, economy/ | KEEP BOTH (intentional - economy wraps basescape) |
| economy_manager.lua | 2 | economy/, basescape/ | KEEP economy/, DELETE basescape/ |
| mission_manager.lua | 2 | battlescape/, geoscape/ | KEEP geoscape/, DELETE battlescape/ |

*+ 17 more duplicate groups (see DUPLICATE_RESOLUTION_PLAN.md)*

**Total Duplicates to Remove:** 18 files  
**Total Duplicates to Rename:** 4 files  
**Intentional Duplicates to Keep:** 5 file pairs

---

### 2. GEOSCAPE CHAOS (24 files at root level)

**Current Structure:**
```
engine/geoscape/
├── *.lua (24 files at root - NO ORGANIZATION)
├── empty_folder_1/
├── empty_folder_2/
├── empty_folder_3/
└── ... (13 empty subfolders)
```

**Current Files (No Organization):**
- geoscape_manager.lua
- geoscape_state.lua
- continent_manager.lua
- country_manager.lua
- region_manager.lua
- faction_manager.lua
- mission_manager.lua
- squad_manager.lua
- craft_manager.lua
- interception_manager.lua
- diplomacy_manager.lua
- politics_manager.lua
- economy_manager.lua
- research_manager.lua
- facility_manager.lua
- unit_manager.lua
- player_manager.lua
- campaign_manager.lua
- pathfinding.lua
- ai_advisor.lua
- + 4 more unrelated files

**Problem:** No clear organization makes file discovery difficult.

**Solution:**
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
│   ├── geoscape_audio.lua
│   └── (audio-related files)
└── ai/
    ├── ai_advisor.lua
    └── ai_strategies.lua
```

---

### 3. BATTLESCAPE OVER-NESTING

**Current Structure:**
```
engine/battlescape/
├── battlescape_manager.lua (5 root files)
├── combat/ (23 files - deeply nested)
│   ├── actions/
│   │   ├── movement.lua
│   │   ├── firing.lua
│   │   └── ...
│   ├── tactical/ (more nesting)
│   ├── effects/ (more nesting)
│   └── ai/
├── ui/ (8 folders + many empty)
├── rendering/ (12 files + empty folders)
├── empty/ (multiple empty folders)
└── ...
```

**Problem:** 18+ empty subfolders, unclear file placement, over-nested hierarchy.

**Solution:**
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

---

### 4. BASESCAPE SEVERELY UNDERDEVELOPED

**Current Structure:**
```
engine/basescape/
├── base_manager.lua (only 1 file!)
├── empty_folder_1/
├── empty_folder_2/
├── empty_folder_3/
└── ... (8 empty subfolders)
```

**Problem:** API documents extensive Basescape system, but only 1 file exists.

**Solution:**
```
engine/basescape/
├── managers/
│   ├── base_manager.lua
│   ├── facility_manager.lua
│   └── crew_manager.lua
├── systems/
│   ├── research_system.lua
│   ├── manufacturing_system.lua
│   ├── maintenance_system.lua
│   └── staffing_system.lua
├── facilities/
│   ├── facility_definitions.lua
│   ├── facility_logic.lua
│   └── facility_effects.lua
├── base/
│   ├── base_layout.lua
│   ├── base_construction.lua
│   └── base_utils.lua
├── research/
│   ├── research_logic.lua
│   ├── research_progress.lua
│   └── research_effects.lua
├── logic/
│   ├── production_logic.lua
│   ├── resource_logic.lua
│   └── capability_logic.lua
└── ui/
    ├── basescape_ui.lua
    ├── facility_panel.lua
    ├── research_panel.lua
    └── ...
```

---

### 5. CORE SYSTEMS MIXED WITHOUT CONCERNS

**Current Structure:**
```
engine/core/
├── assets.lua (asset loading)
├── audio_manager.lua (audio)
├── data_loader.lua (data)
├── events.lua (events)
├── gui_base.lua (GUI)
├── state_manager.lua (state)
├── ... (9 more files mixed together)
```

**Problem:** No concern separation - state, assets, audio, data, events, UI, systems all in same folder.

**Solution:**
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

---

### 6. EMPTY FOLDER PROLIFERATION

**Identified 48 mostly-empty directories:**
- engine/basescape/ - 8 empty folders
- engine/geoscape/ - 13 empty folders
- engine/battlescape/ - 18 empty folders
- engine/basescape/ - 9+ more empty folders

**Problem:** Clutters file browser, confuses developers, appears unfinished.

**Solution:** Delete all empty folders during restructuring phases.

---

### 7. API-TO-ENGINE MISALIGNMENT

**API Documentation Exists For:**
- ✅ Basescape (TOML config, full API) - Engine has only 1 file
- ✅ Economy (full API) - Engine has scattered files
- ✅ Politics (full API) - Engine has no organized system
- ✅ Interception (full API) - Engine has files in geoscape
- ✅ Missions (full API) - Engine has basic implementation
- ✅ Pilots (full API) - Engine has no dedicated subsystem
- ✅ Crafts (full API) - Engine has scattered files
- ✅ Facilities (full API) - Engine has no dedicated system

**Solution:** Create engine files matching API structure during Phase 2-4.

---

### 8. NAMING INCONSISTENCIES

**Patterns Found:**
- `_manager.lua` - 47 files (game manager, state manager, etc.)
- `_system.lua` - 34 files (combat system, effect system, etc.)
- `_controller.lua` - 8 files (no clear distinction from manager)
- `_processor.lua` - 6 files (no clear distinction from system)
- `_handler.lua` - 4 files (unclear purpose)
- `_logic.lua` - 12 files (ambiguous scope)

**Problem:** No clear difference between manager/system/controller/processor.

**Standards Applied in Restructuring:**
- `*_manager.lua` - Entity/system lifecycle management (create, destroy, update collections)
- `*_system.lua` - Core logic system (rules, processing, calculations)
- `*_logic.lua` - Specific logic module (isolated algorithms)
- `*_processor.lua` - Data transformation (input → output)
- `*_handler.lua` - Event/message handling (response to events)

---

## SUBSYSTEM-BY-SUBSYSTEM BREAKDOWN

### Geoscape (Strategic Layer)
**Current State:** 24 files at root, 13 empty subfolders  
**Issues:** No organization, hard to navigate  
**Target State:** 7 organized folders (managers, systems, logic, processing, audio, state, ai)  
**Files Affected:** 24  
**Estimated Time:** 1 hour

### Battlescape (Tactical Combat)
**Current State:** 5 root files, 18 nested subfolders, many empty  
**Issues:** Over-nested, unclear hierarchy  
**Target State:** 8 organized folders (managers, map_system, combat, effects, ai, ecs, rendering, ui)  
**Files Affected:** 42  
**Estimated Time:** 1.5 hours

### Basescape (Base Management)
**Current State:** 1 file, 8 empty subfolders  
**Issues:** Severely underdeveloped  
**Target State:** 7 organized folders (managers, systems, facilities, base, research, logic, ui)  
**Files Affected:** 1 (needs 20+ new files)  
**Estimated Time:** 2 hours (limited - awaiting feature dev)

### Core (Foundation Systems)
**Current State:** 15 mixed files, no concern separation  
**Issues:** All concerns in same folder  
**Target State:** 8 organized folders (state, assets, audio, data, events, ui, systems, entities)  
**Files Affected:** 15  
**Estimated Time:** 45 minutes

### Economy (Economic Systems)
**Current State:** Scattered across basescape, core, geoscape  
**Issues:** No dedicated organization  
**Target State:** Dedicated economy/ folder with clear structure  
**Files Affected:** 8-12  
**Estimated Time:** 1 hour

### Content (Game Content)
**Current State:** Mixed files, some duplicates with mods/  
**Issues:** Unclear organization  
**Target State:** Organized by content type (units, weapons, items, etc.)  
**Files Affected:** 24  
**Estimated Time:** 1 hour

### Other Subsystems (Politics, Analytics, AI, GUI, etc.)
**Current State:** Various states of disorganization  
**Issues:** Subsystem-specific  
**Target State:** Organized folders with clear structure  
**Files Affected:** 80+  
**Estimated Time:** 2-3 hours

---

## IMPLEMENTATION PHASES

### Phase 0: Setup & Backup (30 min)
1. Create git branch `engine-restructure-phase-1`
2. Verify engine structure baseline
3. Create `restructuring_tools/` directory
4. Document current state

### Phase 1: Eliminate Duplicates (2-3 hours)
1. Find all imports of each duplicate
2. Update imports in all files
3. Delete/rename duplicate files
4. Run tests after each deletion
5. Commit changes

### Phase 2: Organize Geoscape (1 hour)
1. Create 7 target folders
2. Move 24 files into folders
3. Update all imports
4. Run tests
5. Commit

### Phase 3: Restructure Battlescape (1.5 hours)
1. Create 8 target folders
2. Move/reorganize 42 files
3. Update all imports
4. Run tests
5. Commit

### Phase 4: Organize Core & Other Systems (2 hours)
1. Create target folders
2. Move/reorganize files
3. Update all imports
4. Run tests
5. Commit

### Phase 5: Comprehensive Testing & Validation (1-2 hours)
1. Run full test suite
2. Verify game launches and runs
3. Check all imports
4. Validate structure against API
5. Document any issues

### Phase 6: Documentation & Final Commit (30 min)
1. Update architecture docs
2. Update README files
3. Create migration guide
4. Final commit and PR

---

## SUCCESS CRITERIA

After restructuring, the following must be true:

✅ All 443 files still present (nothing lost)
✅ No duplicate filenames in same system
✅ All tests passing (unit, integration, system)
✅ Geoscape organized (24 files in 7 folders)
✅ Battlescape flattened (40+ empty folders removed)
✅ Core organized (15 files in 8 folders by concern)
✅ Basescape structured (ready for feature implementation)
✅ All imports working (no broken requires)
✅ Game fully playable (menu → battlescape → all systems)
✅ Professional structure (industry standard organization)

---

## RISKS & MITIGATIONS

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Broken imports after file move | High | High | Run tests after each move, grep for imports |
| Accidentally delete wrong file | Low | High | Use git, review each deletion |
| Import circular dependency | Medium | High | Validate import graph before moves |
| Game won't start | Medium | High | Test after each phase |
| Rebase conflicts | Low | Medium | Commit frequently, use git stash |
| Forget to update some imports | Medium | Medium | Use automated grep to find all references |

---

## NEXT STEPS

1. **Read RESTRUCTURING_DOCUMENTATION_INDEX.md** (navigation guide)
2. **Read ENGINE_RESTRUCTURING_IMPLEMENTATION_GUIDE.md** (exact procedures)
3. **Execute Phase 0** (setup & backup)
4. **Execute Phase 1** (eliminate duplicates with validation)
5. **Proceed through Phases 2-6** with full testing

---

## FILE REFERENCES

- `DUPLICATE_RESOLUTION_PLAN.md` - Decisions for all 27 duplicates
- `ENGINE_RESTRUCTURING_IMPLEMENTATION_GUIDE.md` - Step-by-step procedures
- `RESTRUCTURING_IMPLEMENTATION_LOG.md` - Progress tracking
- `RESTRUCTURING_BEFORE_AND_AFTER.md` - Visual comparisons

---

**Status:** Ready for implementation  
**Date:** October 25, 2025
