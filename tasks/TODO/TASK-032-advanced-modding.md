# Task: Advanced Modding - Campaign Data Loading & Validation

**Status:** TODO
**Priority:** Medium
**Created:** October 24, 2025
**Completed:** N/A
**Assigned To:** AI Agent

---

## Overview

Enable modders to create custom campaign content (missions, factions, events, tech trees) by:
1. Creating mod loading system for campaign data files
2. Implementing validation framework for custom content
3. Building compatibility layer for mod versions
4. Providing modding API and documentation
5. Creating example mods demonstrating all features

This extends the campaign system to **community-driven content creation**.

---

## Purpose

The campaign system has a solid foundation but is limited to hardcoded content. Modders want to:
- Create custom factions and alien types
- Design new mission templates
- Add custom research trees and technology
- Create campaign scenario variants (different starting conditions)
- Share mods with community

Without modding support, the campaign is a closed system. With it, it becomes a platform.

---

## Requirements

### Functional Requirements
- [ ] Mod system loads campaign data from Lua/TOML files
- [ ] Campaign mods can define: factions, missions, events, tech trees, units
- [ ] Mods can override core campaign content or extend it
- [ ] Validation ensures mods don't break campaign logic
- [ ] Multiple mods can be loaded simultaneously (with conflict resolution)
- [ ] Mod version compatibility checking (mods compatible with game version)
- [ ] Mod dependencies (mods can depend on other mods)
- [ ] Graceful fallback if mod is invalid
- [ ] Mod configuration UI in settings menu
- [ ] Mod list displays enabled/disabled mods

### Technical Requirements
- [ ] Create `engine/mods/campaign_mod_loader.lua`
- [ ] Create `engine/mods/campaign_mod_validator.lua`
- [ ] Create `engine/mods/campaign_compatibility_checker.lua`
- [ ] Implement mod dependency resolver
- [ ] Create mod conflict detection
- [ ] Support Lua and TOML mod files
- [ ] Version compatibility system

### Acceptance Criteria
- [ ] Mod loads without errors (Exit Code 0)
- [ ] Invalid mods rejected with helpful error message
- [ ] Multiple mods load and work together
- [ ] Mod dependencies resolved correctly
- [ ] Conflicts detected and reported
- [ ] Fallback to core content if mod fails
- [ ] Mod enabled/disabled in settings
- [ ] Example mods work correctly

---

## Plan

### Step 1: Mod System Architecture (6 hours)
**Description:** Design mod loading and validation framework
**Files to modify/create:**
- `engine/mods/campaign_mod_manager.lua` (NEW - 400 lines)
- `engine/mods/campaign_mod_loader.lua` (NEW - 350 lines)
- `engine/mods/mod_registry.lua` (NEW - 200 lines)

**Architecture:**
```
Mod Discovery (scan mod directories)
    ↓
Load mod.json (metadata)
    ↓
Dependency Resolution
    ↓
Validation (schema, logic)
    ↓
Conflict Detection
    ↓
Load Campaign Data (Lua/TOML)
    ↓
Integration into Campaign System
```

**Mod metadata structure:**
```json
{
  "id": "my_custom_faction",
  "name": "Custom Faction Pack",
  "version": "1.0.0",
  "game_version": ">=1.0.0",
  "author": "ModAuthor",
  "description": "Adds 3 new factions to campaign",
  "dependencies": ["base_game>=1.0.0"],
  "files": [
    "factions/custom1.lua",
    "factions/custom2.lua"
  ]
}
```

**Estimated time:** 6 hours

### Step 2: Validation Framework (7 hours)
**Description:** Create content validation system
**Files to modify/create:**
- `engine/mods/campaign_mod_validator.lua` (NEW - 500 lines)
- `engine/mods/validation_schemas.lua` (NEW - 400 lines)
- `engine/mods/validation_rules.lua` (NEW - 300 lines)

**Validation types:**

1. **Schema Validation:**
   - Faction must have: name, units, tech_tree, relations
   - Mission must have: name, objectives, enemy_composition, rewards
   - Event must have: trigger, effects, probability
   - Tech must have: name, cost, prerequisites

2. **Logic Validation:**
   - No circular dependencies in tech trees
   - Faction units must exist in database
   - Tech prerequisites must be valid techs
   - Mission difficulties within valid range
   - Resource costs non-negative

3. **Compatibility Validation:**
   - Mod version compatible with game version
   - All dependencies satisfied
   - No conflicting content (same IDs)

**Error reporting:**
```lua
{
  valid = false,
  errors = {
    "Missing required field: 'name' in faction 'Sectoids'",
    "Circular dependency: Tech A → B → A",
    "Unknown unit: 'UnknownAlien' referenced in faction"
  },
  warnings = {
    "Tech cost seems high: 5000 science points"
  }
}
```

**Estimated time:** 7 hours

### Step 3: Compatibility & Versioning (5 hours)
**Description:** Implement version checking and compatibility
**Files to modify/create:**
- `engine/mods/campaign_compatibility_checker.lua` (NEW - 250 lines)
- `engine/mods/version_parser.lua` (NEW - 150 lines)

**Version system:**
- Semantic versioning: MAJOR.MINOR.PATCH
- Version constraints: >=1.0.0, <2.0.0, ~1.2.3
- Game version stored in core files
- Mods specify minimum game version

**Compatibility checks:**
```lua
-- Check mod compatible with game version
local compatible = CompatibilityChecker.check_compatibility(
  mod_version = "1.0.0",
  game_version = "1.0.0",
  requirement = ">=1.0.0, <2.0.0"
)

-- Resolve dependency conflicts
local resolution = CompatibilityChecker.resolve_dependencies({
  "base_game>=1.0.0",
  "faction_pack=1.0.0",
  "weapons_mod>=1.5.0"
})
```

**Estimated time:** 5 hours

### Step 4: Mod Loading Integration (8 hours)
**Description:** Integrate mods into campaign system
**Files to modify/create:**
- `engine/geoscape/campaign_mod_integration.lua` (NEW - 400 lines)
- `engine/geoscape/campaign_orchestrator.lua` (modify - add mod loading)
- `engine/mods/mod_conflict_resolver.lua` (NEW - 250 lines)

**Loading process:**
1. Scan mod directories
2. Load mod metadata
3. Validate each mod
4. Resolve dependencies
5. Detect conflicts (same faction ID)
6. Load valid mods
7. Skip invalid mods (log error)
8. Initialize campaign with combined mods

**Conflict resolution:**
- If 2 mods define same faction: error + skip second mod
- If 2 mods define same tech: load first, warn about duplicate
- If dependency missing: skip dependent mod, log error

**Estimated time:** 8 hours

### Step 5: Settings UI for Mods (5 hours)
**Description:** Add mod management to settings menu
**Files to modify/create:**
- `engine/gui/scenes/mod_settings_screen.lua` (NEW - 350 lines)
- `engine/gui/widgets/mod_list.lua` (NEW - 250 lines)
- `engine/gui/widgets/mod_details_panel.lua` (NEW - 200 lines)

**Mod Settings Screen:**
```
┌─────────────────────────────────────────────┐
│          Mod Settings                       │
├─────────────────────────────────────────────┤
│ Enabled Mods:                               │
│ ☑ Custom Faction Pack v1.0.0               │
│ ☑ Weapons Expansion v2.1.0                 │
│ ☐ Difficulty Tweaks v1.0.0 (disabled)      │
│                                             │
│ Mod Details (selected: Custom Faction):     │
│ Description: Adds 3 new factions...         │
│ Author: ModAuthor                           │
│ Version: 1.0.0                              │
│ Dependencies: base_game>=1.0.0              │
│                                             │
│ [Enable] [Disable] [Unload] [Details...]   │
└─────────────────────────────────────────────┘
```

**Features:**
- Toggle mods on/off
- View mod details (author, version, description)
- Show conflicts/errors
- Unload mod
- Check dependencies

**Estimated time:** 5 hours

### Step 6: Modding API Documentation (6 hours)
**Description:** Create API and tutorial for modders
**Files to create:**
- `api/MODDING_GUIDE.md` (NEW - 1500 lines)
- `api/MOD_API_REFERENCE.md` (NEW - 1000 lines)
- `mods/examples/` - Example mods (NEW)

**Documentation includes:**
1. Getting started with mods
2. Mod structure and organization
3. Faction system API
4. Mission template API
5. Tech tree API
6. Event system API
7. Example: Custom faction mod
8. Example: Mission template mod
9. Example: Tech tree expansion
10. Troubleshooting

**Estimated time:** 6 hours

### Step 7: Example Mods (6 hours)
**Description:** Create example mods demonstrating all features
**Files to create:**
- `mods/examples/example_faction_mod/` (NEW)
- `mods/examples/example_mission_mod/` (NEW)
- `mods/examples/example_tech_mod/` (NEW)

**Example 1: Custom Faction Mod**
- Adds "Insectoid Hive" faction
- 3 new unit types
- Custom tech tree
- Custom tech unlocks
- 500 lines total

**Example 2: Custom Mission Templates**
- Adds "Alien Harvesting" mission type
- Custom objectives
- Custom reward tables
- 400 lines total

**Example 3: Tech Tree Expansion**
- Adds 8 new research paths
- Extends existing tree
- New manufacturing unlocks
- 350 lines total

**Estimated time:** 6 hours

### Step 8: Integration Testing (7 hours)
**Description:** Test mod system end-to-end
**Files to create:**
- `tests/integration/test_mod_loading.lua` (NEW - 400 lines)
- `tests/integration/test_mod_validation.lua` (NEW - 350 lines)
- `tests/integration/test_mod_conflicts.lua` (NEW - 300 lines)

**Test scenarios:**
1. Single valid mod loads correctly
2. Multiple valid mods load together
3. Invalid mod rejected with error message
4. Dependency conflicts detected
5. Version incompatibility detected
6. Mod can be disabled in settings
7. Campaign works with mods loaded
8. Example mods load without errors
9. Conflict resolution works correctly
10. Mods persist across game sessions

**Estimated time:** 7 hours

---

## Implementation Details

### Architecture

**Mod Loading Flow:**
```
Scan mod directories
    ↓
Load mod.json for each
    ↓
Validate mod metadata
    ↓
Check version compatibility
    ↓
Resolve dependencies
    ↓
Detect conflicts
    ├→ Valid: Load Lua/TOML files
    └→ Invalid: Log error, skip mod
    ↓
Merge with core content
    ↓
Campaign ready with mods
```

**Integration with Campaign:**
```
CampaignOrchestrator
    ↓
Load core campaign data
    ↓
Load mods via CampaignModManager
    ↓
Merge mod content into campaign
    ↓
Campaign uses combined data
```

### Key Components

- **CampaignModManager:** Central mod management
- **CampaignModLoader:** Load mod files
- **CampaignModValidator:** Validate content
- **CompatibilityChecker:** Version checking
- **ModConflictResolver:** Detect conflicts
- **CampaignModIntegration:** Merge mods with core

### Dependencies

- Campaign system (TASK-025) - COMPLETE ✅
- Settings system (existing) - verified functional
- Widget system (existing) - verified functional
- JSON/TOML parsing (existing) - verified functional

---

## Testing Strategy

### Unit Tests
- Mod loading from files
- Schema validation
- Version compatibility checking
- Dependency resolution
- Conflict detection

### Integration Tests
- Single mod loads
- Multiple mods load together
- Example mods work correctly
- Campaign runs with mods
- Settings UI works

### Manual Testing Steps

1. **Load valid mod:**
   - Create test mod in `mods/custom/`
   - Start game
   - Check console: "Loaded mod: custom"
   - Verify mod content in campaign

2. **Try invalid mod:**
   - Create invalid mod (missing field)
   - Start game
   - Check error message: helpful, not cryptic
   - Game still works (fallback to core)

3. **Test multiple mods:**
   - Load 3 valid mods
   - Verify all load correctly
   - Check for conflicts (none in valid mods)
   - Campaign works with all mods

4. **Test mod settings:**
   - Open settings → Mods
   - See list of loaded mods
   - Toggle one off
   - Restart game
   - Verify it's disabled

5. **Test example mods:**
   - Load `example_faction_mod`
   - Launch campaign
   - New faction appears in options
   - Campaign plays with new faction

### Expected Results

After mod loading:
- Valid mods integrated into campaign
- Invalid mods skipped with error logged
- Multiple mods coexist without conflict
- Campaign works correctly with mods

After mod settings change:
- Disabled mods not loaded
- Enabled mods loaded next session
- Campaign content reflects mod selection

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```

### Debugging Mods

1. **Check mod loading:**
```lua
print("[ModManager] Scanning for mods...")
print("[ModManager] Found mod: " .. mod_id .. " v" .. version)
print("[ModManager] Loading " .. filename)
```

2. **Validate mod content:**
```lua
print("[Validator] Validating mod: " .. mod_id)
print("[Validator] Schema check: " .. (valid and "PASS" or "FAIL"))
print("[Validator] Logic check: " .. (valid and "PASS" or "FAIL"))
```

3. **Check dependencies:**
```lua
print("[Dependencies] Checking for: " .. dep_name)
print("[Dependencies] Found: " .. (found and "YES" or "MISSING"))
```

---

## Documentation Updates

### Files to Update/Create
- [ ] `api/MODDING_GUIDE.md` - Complete modding guide (NEW)
- [ ] `api/MOD_API_REFERENCE.md` - API reference (NEW)
- [ ] `mods/README.md` - Mod directory guide
- [ ] `README.md` - Update features list
- [ ] Code comments - Mod integration docs

---

## Notes

- Start with simple modding (single faction addition)
- Advance to complex (tech trees, events)
- Example mods are critical for adoption
- Validation errors must be helpful (not cryptic)
- Consider mod compilation/packaging (future)
- Plan for mod repository/sharing (future)

---

## Blockers

None identified - all dependencies exist.

---

## Review Checklist

- [ ] Mod system loads without errors
- [ ] Validation works correctly
- [ ] Version checking works
- [ ] Conflict detection works
- [ ] Multiple mods load together
- [ ] Example mods work
- [ ] Settings UI functional
- [ ] Documentation clear
- [ ] Error messages helpful
- [ ] Graceful fallback works

---

## Estimated Total Time

**6 + 7 + 5 + 8 + 5 + 6 + 6 + 7 = 50 hours (6-7 days)**
