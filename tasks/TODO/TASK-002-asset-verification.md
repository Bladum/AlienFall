# Task: Asset Verification and Creation

**Status:** TODO  
**Priority:** High  
**Created:** October 12, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Check all terrain tiles and units defined in TOML files for image asset definitions. For any missing assets, copy existing placeholder images with correct naming so they can be edited later.

---

## Purpose

Ensure every game entity (terrain, unit) has a visual representation. Missing assets cause runtime errors and broken gameplay. Placeholder images allow development to continue while proper art is created.

---

## Requirements

### Functional Requirements
- [ ] Scan all terrain types in `rules/battle/terrain.toml`
- [ ] Scan all unit classes in `rules/unit/classes.toml`
- [ ] Check for corresponding image files in `assets/` folders
- [ ] Create placeholder images for missing assets
- [ ] Add image path definitions to TOML files if missing

### Technical Requirements
- [ ] Script to scan TOML files for entity IDs
- [ ] Script to check if `assets/terrain/{id}.png` exists
- [ ] Script to check if `assets/units/{id}.png` exists
- [ ] Copy/create 32x32 placeholder images
- [ ] Update TOML files with image paths

### Acceptance Criteria
- [ ] All terrain types have `image = "terrain/{id}.png"` in TOML
- [ ] All unit classes have `image = "units/{id}.png"` in TOML
- [ ] All referenced images exist in assets folder
- [ ] Game runs without "image not found" errors
- [ ] Console log shows "All assets verified" message

---

## Plan

### Step 1: Create Asset Verification Script
**Description:** Write Lua script to scan TOML files and check for images  
**Files to create:**
- `engine/utils/verify_assets.lua`

**Estimated time:** 45 minutes

### Step 2: Run Verification
**Description:** Execute script and generate report of missing assets  
**Files to analyze:**
- `mods/new/rules/battle/terrain.toml`
- `mods/new/rules/unit/classes.toml`
- `mods/new/assets/terrain/`
- `mods/new/assets/units/`

**Estimated time:** 15 minutes

### Step 3: Create Placeholder Images
**Description:** For each missing asset, copy placeholder and rename  
**Files to create:**
- Multiple PNG files in `mods/new/assets/terrain/`
- Multiple PNG files in `mods/new/assets/units/`

**Estimated time:** 30 minutes

### Step 4: Update TOML Definitions
**Description:** Add image field to all terrain/unit definitions  
**Files to modify:**
- `mods/new/rules/battle/terrain.toml`
- `mods/new/rules/unit/classes.toml`

**Estimated time:** 20 minutes

### Step 5: Verify Loading
**Description:** Run game and confirm all assets load  
**Test cases:**
- Load battlescape
- Check console for asset loading messages
- Verify no "missing image" warnings

**Estimated time:** 10 minutes

---

## Implementation Details

### Architecture
Asset verification follows this process:
1. Parse all TOML files to extract entity IDs
2. For each ID, check if image file exists
3. Generate report of missing assets
4. Create placeholder images (32x32 pink squares with text)
5. Update TOML files with image paths

### Key Components
- **AssetVerifier:** Script to scan and verify assets
- **ImageGenerator:** Creates placeholder images
- **TOMLUpdater:** Adds image fields to definitions

### TOML Image Field Format
```toml
[terrain.road]
id = "road"
name = "Road"
image = "terrain/road.png"
...
```

### Placeholder Image
- Size: 32×32 pixels
- Color: Pink (#FF00FF) for visibility
- Text: Entity ID centered
- Format: PNG with transparency

### Dependencies
- TOML parser for reading definitions
- love.image for creating images
- File system access for checking files

---

## Testing Strategy

### Unit Tests
- Test TOML parsing extracts all IDs
- Test image path resolution
- Test placeholder creation

### Integration Tests
- Test asset loader finds all images
- Test game displays placeholders correctly
- Test no console errors

### Manual Testing Steps
1. Run asset verification script
2. Review missing assets report
3. Check that placeholders were created
4. Run game with `lovec "engine"`
5. Enter battlescape
6. Verify all tiles display (even if placeholder)
7. Check console for no image errors

### Expected Results
- Verification script lists all entities
- Missing assets report generated
- Placeholder images created
- TOML files updated
- Game runs without asset errors

---

## How to Run/Debug

### Running Asset Verification
```lua
-- Add to tests_menu or run standalone
lovec "engine" -c "require('utils.verify_assets').run()"
```

### Running the Game
```bash
lovec "engine"
```

### Debugging
- Check console for "[AssetVerifier] Checking terrain: {id}"
- Look for "[AssetVerifier] Missing: assets/terrain/{id}.png"
- Verify placeholder creation messages
- Check Assets.load() messages for image loading

### Temporary Files
All verification reports should be written to:
```lua
local tempDir = os.getenv("TEMP")
local reportPath = tempDir .. "\\asset_verification_report.txt"
```

---

## Documentation Updates

### Files to Update
- [ ] `tasks/tasks.md` - Add task entry
- [ ] `wiki/API.md` - Document asset naming conventions
- [ ] `wiki/DEVELOPMENT.md` - Add asset verification to workflow
- [ ] `README.md` - Note placeholder assets

---

## Notes

- Placeholder images are temporary - mark clearly for replacement
- Consider using different colors for different entity types
- May need to update Assets system to load from mod paths

---

## Blockers

None. Asset system and TOML loading already functional.

---

## Review Checklist

- [ ] All TOML entities have image fields
- [ ] All referenced images exist
- [ ] Placeholders are clearly marked
- [ ] No hardcoded asset paths
- [ ] Script uses TEMP folder for reports
- [ ] Console logging for verification process
- [ ] Tests written and passing
- [ ] Documentation updated

---

## Post-Completion

### What Worked Well
TBD

### What Could Be Improved
TBD

### Lessons Learned
TBD
