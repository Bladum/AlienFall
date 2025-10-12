# Task: Mapblock and Tile Validation

**Status:** TODO  
**Priority:** High  
**Created:** October 12, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Ensure all mapblocks are properly defined in TOML files, and verify that every tile referenced in mapblocks has a corresponding definition in terrain.toml with assigned images.

---

## Purpose

Prevent runtime errors caused by undefined tiles in mapblocks. Ensure mapblock system is complete and consistent, allowing reliable map generation for battlescape missions.

---

## Requirements

### Functional Requirements
- [ ] All mapblocks defined in `mods/new/mapblocks/*.toml`
- [ ] Each mapblock references only valid terrain tile IDs
- [ ] All referenced tiles exist in `rules/battle/terrain.toml`
- [ ] All terrain definitions have image assignments
- [ ] Validation script reports any inconsistencies

### Technical Requirements
- [ ] Mapblock validator scans all .toml files in mapblocks folder
- [ ] Cross-references tile IDs with terrain definitions
- [ ] Checks for orphaned references
- [ ] Generates validation report
- [ ] Integration with mod loading system

### Acceptance Criteria
- [ ] All 10 mapblocks pass validation
- [ ] No undefined tile references
- [ ] All tiles have images assigned
- [ ] Validation runs during mod loading
- [ ] Console shows validation success message
- [ ] Mapblocks load correctly in battlescape

---

## Plan

### Step 1: Create Mapblock Validator
**Description:** Build validator to check mapblock integrity  
**Files to create:**
- `engine/systems/mapblock_validator.lua`

**Estimated time:** 1 hour

### Step 2: Scan Existing Mapblocks
**Description:** Run validator on all existing mapblocks  
**Files to analyze:**
- All files in `mods/new/mapblocks/`
- `mods/new/rules/battle/terrain.toml`

**Estimated time:** 15 minutes

### Step 3: Fix Validation Issues
**Description:** Correct any undefined tile references or missing definitions  
**Files to modify:**
- Various mapblock TOML files
- `mods/new/rules/battle/terrain.toml` (add missing terrain types)

**Estimated time:** 45 minutes

### Step 4: Integrate Validation
**Description:** Add validation to mod loading process  
**Files to modify:**
- `engine/systems/mod_manager.lua` (call validator during load)
- `engine/systems/data_loader.lua` (validate after terrain load)

**Estimated time:** 30 minutes

### Step 5: Testing
**Description:** Verify validation works and mapblocks load  
**Test cases:**
- Validator detects invalid tile references
- All mapblocks pass validation
- Battlescape can use mapblocks for generation

**Estimated time:** 20 minutes

---

## Implementation Details

### Architecture
Validation process:
1. Load terrain type definitions
2. Scan mapblocks folder for TOML files
3. For each mapblock:
   - Parse tile assignments
   - Check each tile ID against terrain definitions
   - Verify terrain has image assignment
   - Report missing/invalid references
4. Generate comprehensive validation report

### Key Components
- **MapblockValidator.validate(modPath):** Main validation entry
- **MapblockValidator.scanMapblocks(path):** Find all mapblock files
- **MapblockValidator.checkTileReferences(mapblock, terrainDefs):** Verify tiles
- **MapblockValidator.generateReport():** Output validation results

### Validation Report Format
```
Mapblock Validation Report
==========================
Mapblock: urban_block_01
  ✓ Metadata valid
  ✓ Size: 15x15
  ✓ 225 tiles defined
  ✗ Undefined tile: "concrete" at position 3_5
  ✗ Tile "grass" missing image definition

Summary: 10 mapblocks, 8 passed, 2 failed, 15 issues found
```

### Dependencies
- TOML parser
- ModManager (for paths)
- DataLoader (for terrain definitions)
- File system access

---

## Testing Strategy

### Unit Tests
- Test validator parses mapblock correctly
- Test tile reference checking logic
- Test report generation

### Integration Tests
- Test validator runs during mod loading
- Test validation prevents loading invalid mapblocks
- Test console error messages are clear

### Manual Testing Steps
1. Create test mapblock with invalid tile reference
2. Run game with `lovec "engine"`
3. Check console for validation error
4. Fix the invalid reference
5. Verify validation passes
6. Load battlescape with validated mapblocks
7. Verify map generation works

### Expected Results
- Invalid mapblocks are detected
- Clear error messages in console
- Valid mapblocks load successfully
- No runtime errors from undefined tiles

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```

### Running Validation Standalone
```lua
-- Add to tests_menu
local MapblockValidator = require("systems.mapblock_validator")
local report = MapblockValidator.validate("mods/new")
print(report)
```

### Debugging
- Check console for "[MapblockValidator] Scanning mapblocks..."
- Look for validation error messages
- Use `print()` to trace tile checking
- Verify TOML parsing is correct

### Console Output to Look For
```
[MapblockValidator] Scanning mapblocks in: mods/new/mapblocks
[MapblockValidator] Found 10 mapblock files
[MapblockValidator] Validating: urban_block_01.toml
[MapblockValidator] All tiles valid for urban_block_01
[MapblockValidator] Validation complete: 10/10 passed
```

---

## Documentation Updates

### Files to Update
- [ ] `tasks/tasks.md` - Add task entry
- [ ] `wiki/API.md` - Document MapblockValidator API
- [ ] `wiki/MAPBLOCK_GUIDE.md` - Add validation requirements
- [ ] `wiki/DEVELOPMENT.md` - Note validation in workflow

---

## Notes

- Mapblock validation should be strict to prevent runtime issues
- Consider adding validation for mapblock size limits
- May want to validate spawn points and special tiles later

---

## Blockers

None. TOML system and mapblocks already implemented.

---

## Review Checklist

- [ ] Validator detects all invalid references
- [ ] All mapblocks pass validation
- [ ] Clear error messages for failures
- [ ] Validation integrated into mod loading
- [ ] No performance impact (validation only on load)
- [ ] Console logging for validation process
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] No warnings in Love2D console

---

## Post-Completion

### What Worked Well
TBD

### What Could Be Improved
TBD

### Lessons Learned
TBD
