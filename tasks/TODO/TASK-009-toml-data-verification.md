# Task: TOML-Based Data Loading Verification

**Status:** TODO  
**Priority:** Critical  
**Created:** October 12, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Ensure all game data (tiles, units, mapblocks, weapons, armours, etc.) loads exclusively from TOML files with no hardcoded content in engine code. Verify complete separation of data and code.

---

## Purpose

Achieve full data-driven architecture where all content is moddable. Enable content creators to modify game data without touching engine code. Ensure maintainability and extensibility.

---

## Requirements

### Functional Requirements
- [ ] All terrain types load from TOML
- [ ] All unit classes load from TOML
- [ ] All weapons load from TOML
- [ ] All armours load from TOML
- [ ] All mapblocks load from TOML
- [ ] No hardcoded game data in Lua code
- [ ] All content accessed through ModManager

### Technical Requirements
- [ ] DataLoader system handles all TOML loading
- [ ] No fallback to hardcoded defaults in code
- [ ] Validation ensures TOML data is complete
- [ ] Error messages indicate missing TOML data
- [ ] Performance impact minimal

### Acceptance Criteria
- [ ] Code audit finds no hardcoded content
- [ ] All data loaded via DataLoader
- [ ] Game runs entirely from TOML files
- [ ] Removing TOML file causes clear error
- [ ] Adding new content requires only TOML edits
- [ ] Console confirms TOML data sources

---

## Plan

### Step 1: Audit Current Data Loading
**Description:** Search codebase for hardcoded data  
**Files to search:**
- All Lua files in `engine/`
- Look for hardcoded arrays/tables of game data
- Find any fallback default values

**Search patterns:**
- Terrain definitions in code
- Unit stat tables
- Weapon/armour data
- Mapblock data

**Estimated time:** 45 minutes

### Step 2: Identify Hardcoded Content
**Description:** Create list of hardcoded data to remove  
**Files to document:**
- File path
- Line numbers
- Type of hardcoded data
- Replacement strategy

**Estimated time:** 30 minutes

### Step 3: Move Hardcoded Data to TOML
**Description:** Transfer any remaining hardcoded data to TOML files  
**Files to modify:**
- Various TOML files in `mods/new/rules/`
- Remove hardcoded data from Lua files
- Update code to load from TOML

**Estimated time:** 2 hours

### Step 4: Update DataLoader
**Description:** Ensure DataLoader handles all content types  
**Files to modify:**
- `engine/systems/data_loader.lua`

**Add loaders for:**
- Items (if not present)
- Facilities (if not present)
- Research topics (if not present)
- Any other game content

**Estimated time:** 1 hour

### Step 5: Remove Fallback Defaults
**Description:** Remove code that provides default values  
**Strategy:**
- Change from: `value = data.value or defaultValue`
- Change to: `value = data.value` (with validation)
- Add error if required value missing

**Files to modify:**
- Various modules that load data
- DataLoader validation

**Estimated time:** 1 hour

### Step 6: Add Validation
**Description:** Validate TOML data completeness  
**Files to modify:**
- `engine/systems/data_loader.lua`
- Create `engine/systems/data_validator.lua`

**Validations:**
- Required fields present
- Value types correct
- References valid (e.g., terrain IDs exist)
- No missing images
- Numeric ranges valid

**Estimated time:** 1.5 hours

### Step 7: Update Error Handling
**Description:** Clear error messages for missing data  
**Examples:**
- "Terrain 'concrete' referenced but not defined in terrain.toml"
- "Unit class 'soldier' missing required field 'health'"
- "Weapon 'rifle' not found in weapons.toml"

**Files to modify:**
- DataLoader
- All systems that access data

**Estimated time:** 45 minutes

### Step 8: Testing
**Description:** Verify complete TOML-based loading  
**Test cases:**
- Remove TOML file → should error
- Corrupt TOML file → should error
- Missing required field → should error
- Valid TOML → should load
- All game systems work with TOML data

**Estimated time:** 1 hour

---

## Implementation Details

### Architecture
Complete separation of data and code:
```
Code Layer (Engine)
    ↓ loads via
DataLoader Layer (Systems)
    ↓ reads from
ModManager Layer (Systems)
    ↓ accesses
TOML Files (Mods)
```

### Validation System
```lua
local DataValidator = {}

function DataValidator.validateTerrain(terrainData)
    local required = {"id", "name", "moveCost", "sightCost"}
    
    for _, field in ipairs(required) do
        if not terrainData[field] then
            error(string.format("Terrain missing required field: %s", field))
        end
    end
    
    -- Type validation
    assert(type(terrainData.moveCost) == "number", "moveCost must be number")
    assert(terrainData.moveCost >= 0, "moveCost must be >= 0")
    
    return true
end
```

### Error Messages
```lua
-- Bad: Generic error
error("Invalid data")

-- Good: Specific error with context
error(string.format(
    "[DataLoader] Terrain '%s' missing required field 'moveCost' in %s",
    terrainId,
    tomlPath
))
```

### Before/After Examples

**Before (Hardcoded):**
```lua
local defaultTerrain = {
    floor = {moveCost = 2, sightCost = 1},
    wall = {moveCost = 0, sightCost = 1000}
}

local terrain = loadedData.terrain or defaultTerrain.floor
```

**After (TOML-only):**
```lua
local terrain = DataLoader.terrainTypes.get(terrainId)
if not terrain then
    error(string.format(
        "[Battlescape] Terrain '%s' not found in terrain.toml",
        terrainId
    ))
end
```

### Key Components
- **DataLoader:** TOML loading and caching
- **DataValidator:** Schema validation
- **ModManager:** Content path resolution
- **Error handling:** Clear, actionable messages

### Dependencies
- TOML parser library
- ModManager for file paths
- File system access
- Error handling system

---

## Testing Strategy

### Unit Tests
- Test DataLoader loads all content types
- Test validation catches missing fields
- Test error messages are clear
- Test performance impact is minimal

### Integration Tests
- Test game runs entirely from TOML
- Test all modules use DataLoader
- Test no hardcoded fallbacks
- Test mod content overrides work

### Manual Testing Steps
1. Run game with `lovec "engine"`
2. Verify console shows TOML loading messages
3. Enter battlescape
4. Check terrain loads from TOML
5. Check units load from TOML
6. Temporarily rename terrain.toml
7. Run game - should error clearly
8. Restore terrain.toml
9. Corrupt a TOML file
10. Run game - should error clearly
11. Restore TOML file
12. Add new terrain to TOML
13. Verify it appears in game

### Expected Results
- All content loads from TOML
- No hardcoded data in code
- Clear errors for missing data
- Game is fully data-driven
- Mods can replace all content

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```

### Checking Data Sources
```lua
-- Print where data comes from
print("Terrain source:", DataLoader.terrainTypes.source)
print("Loaded terrain types:", table.concat(DataLoader.terrainTypes.getAllIds(), ", "))
```

### Testing Data Validation
```lua
-- Temporarily remove field from TOML
-- Run game and check error message
```

### Debugging
- Check console for "[DataLoader] Loading X from: path"
- Verify TOML paths are correct
- Check for fallback logic in code
- Use grep to find hardcoded data

### Console Output
```
[DataLoader] Loading terrain types from: mods/new/rules/battle/terrain.toml
[DataLoader] Loaded 16 terrain types
[DataLoader] Loading weapons from: mods/new/rules/item/weapons.toml
[DataLoader] Loaded 13 weapons
[DataLoader] All game data loaded from TOML files
```

---

## Documentation Updates

### Files to Update
- [ ] `tasks/tasks.md` - Add task entry
- [ ] `wiki/API.md` - Document DataLoader API
- [ ] `wiki/DEVELOPMENT.md` - Emphasize TOML-only data
- [ ] `wiki/FAQ.md` - How to add new content
- [ ] `README.md` - Note data-driven architecture

---

## Notes

- Consider adding schema files for TOML validation
- May want to add TOML editor with validation
- Could add hot-reload for TOML changes
- Think about TOML inheritance for mods

---

## Blockers

None. TOML system and DataLoader already implemented.

---

## Review Checklist

- [ ] Code audit found no hardcoded data
- [ ] All content loads via DataLoader
- [ ] Validation catches errors
- [ ] Error messages are clear
- [ ] Performance acceptable
- [ ] No fallback defaults in code
- [ ] ModManager integration complete
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] Console logging confirms TOML sources

---

## Post-Completion

### What Worked Well
TBD

### What Could Be Improved
TBD

### Lessons Learned
TBD
