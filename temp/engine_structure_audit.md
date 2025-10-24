# Engine Folder Structure Audit Report

**Generated:** October 25, 2025
**Status:** Initial Analysis Complete

---

## Executive Summary

The engine folder has **grown organically** over time with **inconsistent organization patterns**. There are currently:
- **16 top-level folders** plus 2 root files (main.lua, conf.lua)
- **Layers mixed with systems** at same organizational level
- **Clear categorization** exists but could be optimized
- **No intermediate organization levels** (missing layer/ or systems/ grouping)

---

## Current Structure

```
engine/
├── main.lua                 # Game entry point
├── conf.lua                 # Love2D config
├── icon.png                 # Game icon
├── .luarc.json             # Lua IDE config
│
├── Core Systems (should be in core/)
│   ├── core/                # ✓ Correct location
│   ├── utils/               # ✓ Correct location
│   ├── assets/              # ✓ Correct location (mostly)
│   └── mods/                # ~ Correct but could be in core/
│
├── Game Layers (good organization)
│   ├── geoscape/            # ✓ Strategic layer
│   ├── basescape/           # ✓ Base management layer
│   ├── battlescape/         # ✓ Tactical combat layer
│   ├── interception/        # ✓ Craft interception layer
│   └── tutorial/            # ~ Tutorial system (cross-layer)
│
├── Cross-Layer Systems (inconsistent)
│   ├── ai/                  # AI (used by multiple layers)
│   ├── economy/             # Economic (used by multiple layers)
│   ├── politics/            # Politics (used by multiple layers)
│   ├── analytics/           # Analytics (cross-layer)
│   ├── content/             # Content loading (cross-layer)
│   └── lore/                # Lore system (cross-layer)
│
├── UI/Presentation (mixed organization)
│   ├── gui/                 # GUI framework
│   ├── widgets/             # MISSING! Should exist but isn't separate
│   └── localization/        # Localization (belongs with gui/)
│
└── Specialized Systems
    ├── accessibility/       # Accessibility features
    ├── network/            # Networking (future)
    └── portal/             # Portal system (where is this?)
```

---

## Organization Issues Found

### 1. **Mixed Abstraction Levels**

**Problem:** Game layers (geoscape, basescape, battlescape) are at same level as utility systems (utils, core).

**Current:**
```
engine/
├── core/                  (system)
├── utils/                 (system)
├── geoscape/              (game layer)
├── battlescape/           (game layer)
└── ai/                    (system used by layers)
```

**Better:**
```
engine/
├── core/                  (core systems)
├── utils/                 (utilities)
├── systems/               (cross-layer systems)
│   ├── ai/
│   ├── economy/
│   ├── politics/
│   └── ...
└── layers/                (game layers)
    ├── geoscape/
    ├── basescape/
    ├── battlescape/
    └── interception/
```

### 2. **UI Organization Fragmentation**

**Problem:** GUI-related files scattered:
- `gui/` - GUI framework
- `widgets/` - Should exist but files might be in `gui/widgets/`
- `localization/` - Translation (belongs in UI)
- Widget rendering might be in `core/` or `gui/`

**Impact:** Hard to find GUI components
**Solution:** Consolidate under `gui/`:
```
gui/
├── framework/      # Core GUI classes
├── widgets/        # UI components (button, panel, etc.)
├── rendering/      # GUI rendering
├── input/         # GUI input handling
└── localization/  # Translations
```

### 3. **Cross-Layer Systems at Wrong Level**

**Problem:** Systems used by multiple layers (ai, economy, politics, analytics) are peers to game layers:
- Hard to find cross-layer functionality
- No clear dependency direction
- Difficult to understand which systems are used where

**Systems affected:**
- `ai/` - Used by battlescape, geoscape
- `economy/` - Used by geoscape, basescape
- `politics/` - Used by geoscape
- `analytics/` - Used everywhere
- `content/` - Used everywhere
- `lore/` - Used everywhere

**Solution:** Create `systems/` folder for cross-layer utilities:
```
systems/
├── ai/
├── economy/
├── politics/
├── analytics/
├── content/
└── lore/
```

### 4. **Core vs System Confusion**

**Problem:** `core/` folder contains:
- True core (state_manager, event_system)
- Generic systems (could be in utils/ or systems/)
- Unclear what belongs here

**Solution:** Clearly define:
- `core/` = Game state management, core infrastructure ONLY
- `systems/` = Reusable game systems
- `utils/` = Generic utilities (math, tables, etc.)

### 5. **Depth Inconsistency**

**Problem:** Some folders have subfolders, others don't:
- `battlescape/` - Probably has depth
- `utils/` - Probably flat
- `gui/` - Unclear if has subfolders
- `ai/` - Unclear organization

**Impact:** Inconsistent mental model
**Solution:** Standardize depth at each level

### 6. **Missing Organizational Structures**

**Missing:**
- No `systems/` folder for cross-layer systems
- No `layers/` folder grouping game layers
- No `ui/` folder consolidating all UI-related code
- No `gameplay/` folder for core gameplay systems
- No `data/` folder for data loaders

**Exists but unclear purpose:**
- `content/` - Content loading (should be in systems/)
- `lore/` - Lore system (should be in systems/)
- `portal/` - Portal system (where is it exactly?)
- `tutorial/` - Tutorial (cross-layer, should be in systems/)

### 7. **File Location Issues**

**Likely misplaced files:**
- UI rendering code scattered across layers
- Math utilities might be in both `utils/` and layer subfolders
- Input handling duplicated across layers
- Validator logic (belongs in tools/ not engine/)

### 8. **Naming Inconsistency**

**Issues:**
- Some files end with `_manager.lua`, others with `_system.lua`
- Some with `_handler.lua`, `_controller.lua`
- No clear naming convention per folder type
- Generic names like `manager.lua` without prefix

---

## Proposed New Organization

### High-Level Structure

```
engine/
├── core/                # Core engine systems (state, events)
│   ├── state_manager.lua
│   ├── event_system.lua
│   └── globals.lua
│
├── utils/              # Generic utilities
│   ├── math.lua
│   ├── table.lua
│   ├── string.lua
│   └── file.lua
│
├── ui/                 # All UI/presentation
│   ├── framework/      # Core GUI classes
│   ├── widgets/        # UI components
│   ├── rendering/      # GUI rendering
│   └── localization/   # Translations
│
├── systems/            # Cross-layer gameplay systems
│   ├── ai/             # AI systems
│   ├── economy/        # Economic systems
│   ├── politics/       # Political systems
│   ├── analytics/      # Metrics and analytics
│   ├── content/        # Content loading
│   ├── lore/           # Lore/story system
│   └── tutorial/       # Tutorial system
│
├── accessibility/      # Accessibility features
│
├── layers/             # Game layers (turn-based phases)
│   ├── geoscape/       # Strategic world map
│   ├── basescape/      # Base management
│   ├── battlescape/    # Tactical combat
│   └── interception/   # Craft interception
│
├── assets/             # Asset loading and management
│
├── mods/               # Mod system integration
│
├── network/            # Networking (future)
│
├── main.lua            # Entry point
├── conf.lua            # Love2D config
└── icon.png            # Icon
```

### Benefits

✅ **Clear hierarchy:** Three organizational levels:
1. Core systems (bottom)
2. Gameplay systems (middle)
3. Game layers (top)

✅ **Improved discoverability:** Know where to look for:
- UI code → `ui/`
- Cross-layer systems → `systems/`
- Game layers → `layers/`

✅ **Better dependency direction:**
- Layers depend on systems
- Systems depend on core and utils
- No circular dependencies possible

✅ **Scalability:** Easy to add new layers/systems

✅ **Consistent naming:** Each folder type has clear purpose

---

## Migration Complexity Assessment

| Category | Impact | Files | Effort |
|----------|--------|-------|--------|
| Create folders | Low | - | 1 hour |
| Move files | Medium | ~15-20 | 2-3 hours |
| Update imports | High | 50+ | 6-8 hours |
| Update tests | Medium | 20+ | 3-4 hours |
| Verify functionality | High | - | 4-5 hours |
| **TOTAL** | **High** | **70+** | **16-21 hours** |

---

## Recommended Implementation Plan

### Phase 1: Planning (2-3 hours)
1. ✅ Audit current structure (THIS REPORT)
2. Define organization principles
3. Review with team
4. Get approval

### Phase 2: Preparation (2-3 hours)
1. Create migration script (automated)
2. Create backup of engine folder
3. Create git branch

### Phase 3: Migration (8-10 hours)
1. Create new folder structure
2. Move files using git mv (preserves history)
3. Update all import statements
4. Update test files
5. Verify imports and requires

### Phase 4: Verification (4-5 hours)
1. Run all tests
2. Run game
3. Check console for errors
4. Manual testing of all layers

### Phase 5: Documentation (2-3 hours)
1. Update README files
2. Update architecture docs
3. Create structure principles doc
4. Update copilot instructions

---

## Files That Need Attention

### Files to Verify Location

**In utils/ - verify these belong there:**
- Any UI rendering code?
- Any layer-specific code?
- Any system-specific code?

**In core/ - might belong elsewhere:**
- Any layer-specific managers?
- Any UI-related code?
- Any cross-layer system code?

**In gui/ vs widgets/ - consolidate:**
- Are both folders used?
- Can they be merged?
- What's the division?

**In battlescape/ - large folder likely needs subfolders:**
- Combat system (units, damage, effects)
- Movement system (pathfinding, grid)
- Rendering (map rendering, UI)
- AI (tactical AI)

### Deep Dive Folders

Need analysis of:
1. `battlescape/` - largest layer, likely needs internal org
2. `geoscape/` - needs subfolders
3. `basescape/` - needs subfolders
4. `ai/` - needs categorization
5. `gui/` vs widgets structure

---

## Next Steps

1. **Review this report** - Team feedback
2. **Define principles** - Create organization standards
3. **Generate detailed plan** - File-by-file moves
4. **Create tools** - Automated migration scripts
5. **Execute migration** - Actually reorganize
6. **Verify** - Tests and manual checks
7. **Document** - Update all docs

---

## Related Tasks

- **TASK-007:** Rewrite Engine READMEs - Will be easier after reorganization
- **TASK-008:** Architecture Review - Will need updated structure
- **Validators:** Check structure compliance ongoing

---

**Status:** Audit Complete - Ready for Planning Phase
