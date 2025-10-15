# Task: Convert Examples to Mod Content

**Status:** TODO  
**Priority:** Medium  
**Created:** 2025-01-XX  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Convert concrete examples from wiki/wiki/examples.md into actual TOML mod content files in mods/core/examples/. Create corresponding documentation in docs/modding/examples.md for reference. Remove examples.md from wiki after migration.

---

## Purpose

The examples.md file contains valuable reference data (unit stats, craft specs, item properties, facilities, factions, missions, etc.) that belongs in the mod content system, not in wiki documentation. By converting to TOML files, modders can use these as templates for creating custom content, and the game can potentially use them as fallback/example content.

---

## Requirements

### Functional Requirements
- [ ] Convert all unit stat examples to TOML files
- [ ] Convert all craft stat examples to TOML files
- [ ] Convert all item stat examples to TOML files
- [ ] Convert all facility examples to TOML files
- [ ] Convert all faction examples to TOML files
- [ ] Convert all mission examples to TOML files
- [ ] Convert all research/manufacturing/purchase examples to TOML files
- [ ] Convert all weapon modes and damage type examples to TOML files

### Technical Requirements
- [ ] Create mods/core/examples/ directory structure
- [ ] Follow existing TOML format conventions from mods/core/
- [ ] Ensure all examples are valid and parseable
- [ ] Document TOML structure in docs/modding/examples.md
- [ ] Add validation for example files

### Acceptance Criteria
- [ ] All examples from examples.md exist as TOML files
- [ ] TOML files follow consistent naming convention
- [ ] Examples documented in docs/modding/examples.md with usage instructions
- [ ] Examples can be loaded by mod system without errors
- [ ] examples.md removed from wiki/wiki/
- [ ] Modders can use examples as templates for custom content

---

## Plan

### Step 1: Create Directory Structure
**Description:** Set up organized folder structure in mods/core/examples/  
**Files to create:**
- `mods/core/examples/units/`
- `mods/core/examples/crafts/`
- `mods/core/examples/items/`
- `mods/core/examples/facilities/`
- `mods/core/examples/factions/`
- `mods/core/examples/missions/`
- `mods/core/examples/research/`
- `mods/core/examples/manufacturing/`
- `mods/core/examples/weapons/`

**Estimated time:** 1 hour

### Step 2: Convert Unit Examples to TOML
**Description:** Create TOML files for Assault Soldier, Sniper, Heavy Weapons, etc.  
**Files to create:**
- `mods/core/examples/units/assault_soldier.toml`
- `mods/core/examples/units/sniper.toml`
- `mods/core/examples/units/heavy_weapons.toml`
- Additional unit type examples

**Example TOML structure**:
```toml
[unit]
id = "example_assault_soldier"
name = "Assault Soldier"
type = "soldier"

[stats]
health = 100
action_points = 8
accuracy = 65
time_units = 50
strength = 40
reactions = 50
bravery = 60
```

**Estimated time:** 2 hours

### Step 3: Convert Craft Examples to TOML
**Description:** Create TOML files for Interceptor, Skyranger, Heavy Fighter  
**Files to create:**
- `mods/core/examples/crafts/interceptor.toml`
- `mods/core/examples/crafts/transport_skyranger.toml`
- `mods/core/examples/crafts/heavy_fighter.toml`

**Estimated time:** 1.5 hours

### Step 4: Convert Item & Weapon Examples to TOML
**Description:** Create TOML files for Laser Rifle, Alien Alloy Armor, Medi-Kit, weapon modes  
**Files to create:**
- `mods/core/examples/items/laser_rifle.toml`
- `mods/core/examples/items/alien_alloy_armor.toml`
- `mods/core/examples/items/medi_kit.toml`
- `mods/core/examples/weapons/weapon_modes.toml`
- `mods/core/examples/weapons/damage_types.toml`

**Estimated time:** 2 hours

### Step 5: Convert Facility, Faction, Mission Examples to TOML
**Description:** Create TOML files for Living Quarters, Laboratory, Sectoids, Mutons, Crash Site, Terror Mission  
**Files to create:**
- `mods/core/examples/facilities/living_quarters.toml`
- `mods/core/examples/facilities/laboratory.toml`
- `mods/core/examples/facilities/workshop.toml`
- `mods/core/examples/factions/sectoids.toml`
- `mods/core/examples/factions/mutons.toml`
- `mods/core/examples/factions/ethereals.toml`
- `mods/core/examples/missions/crash_site.toml`
- `mods/core/examples/missions/terror_mission.toml`

**Estimated time:** 2.5 hours

### Step 6: Convert Research, Manufacturing, Purchase Examples to TOML
**Description:** Create TOML files for research entries, manufacturing entries, marketplace purchases  
**Files to create:**
- `mods/core/examples/research/laser_weapons.toml`
- `mods/core/examples/manufacturing/laser_rifle_production.toml`
- `mods/core/examples/marketplace/basic_supplies.toml`

**Estimated time:** 1.5 hours

### Step 7: Create Comprehensive Documentation
**Description:** Document all examples with usage instructions for modders  
**Files to create:**
- `docs/modding/examples.md` (comprehensive guide)
- `mods/core/examples/README.md` (quick reference)

**Content:**
- Purpose of example files
- How to use examples as templates
- TOML structure explanation for each content type
- Best practices for creating custom content
- Validation and testing instructions

**Estimated time:** 2 hours

### Step 8: Validation and Testing
**Description:** Verify all TOML files are valid and can be loaded by mod system  
**Test cases:**
- Parse all TOML files without errors
- Validate required fields are present
- Check data types are correct
- Test loading examples in game

**Files to create:**
- `tests/integration/test_example_mod_content.lua`

**Estimated time:** 1.5 hours

### Step 9: Remove wiki/wiki/examples.md
**Description:** After successful migration, remove source file  
**Files to remove:**
- `wiki/wiki/examples.md`

**Estimated time:** 0.5 hours

---

## Implementation Details

### Architecture
**TOML Structure**:
- Each example is a standalone TOML file
- Files organized by content type (units/, crafts/, items/, etc.)
- Follow existing mods/core/ TOML conventions
- Include comments explaining each field

**Mod System Integration**:
- Examples loaded like any other mod content
- Can be used as fallback content if no other mods loaded
- Modders can copy and modify for custom content

### Key Components
- **TOML Files**: Structured data files for each example
- **Documentation**: Comprehensive modding guide
- **Validation**: Parser and validator for TOML content

### Dependencies
- Existing mod system in engine/mods/
- TOML parser library
- mods/core/ directory structure

---

## Testing Strategy

### Unit Tests
- Test 1: Parse all TOML files successfully
- Test 2: Validate required fields present
- Test 3: Check data types match expected types
- Test 4: Verify referential integrity (e.g., item references)

### Integration Tests
- Test 1: Load all examples through mod system
- Test 2: Instantiate units with example stats
- Test 3: Create crafts with example specs
- Test 4: Verify no errors in console during loading

### Manual Testing Steps
1. Run game with `lovec "engine"`
2. Enable examples mod in mod loader
3. Verify all examples load without errors in console
4. Check that example units/crafts/items appear in game (if applicable)
5. Verify modders can copy and modify examples

### Expected Results
- All TOML files parse successfully
- No errors in Love2D console
- Examples provide clear templates for modders
- Documentation is comprehensive and helpful

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```
or use the VS Code task: "Run XCOM Simple Game"

### Debugging
- Love2D console is enabled in `conf.lua` (t.console = true)
- Use `print("[ModLoader] Loading example: " .. filename)` for tracking
- Add validation logging: `print("[Validation] Example valid: " .. example_id)`
- Check console for TOML parsing errors
- Use TOML validator tools for syntax checking

### TOML Validation
- Use online TOML validator: https://www.toml-lint.com/
- Use `toml` Lua library's parser for validation
- Add validation script in tools/

---

## Documentation Updates

### Files to Update
- [x] `docs/modding/examples.md` - Create comprehensive examples guide
- [x] `mods/core/examples/README.md` - Quick reference for examples
- [ ] `docs/modding/content_creation.md` - Link to examples
- [ ] `wiki/API.md` - Document example loading API
- [ ] `wiki/FAQ.md` - Add "How to use examples for modding?" entry

---

## Notes

- Examples should be simple and clear, not complex
- Include comments in TOML files explaining each field
- Follow consistent naming convention: `example_<type>_<name>.toml`
- Examples serve dual purpose: reference for modders + fallback game content
- Consider making examples loadable as a "starter pack" mod

---

## Blockers

- Need to verify TOML format conventions from existing mods/core/ files
- May need to create TOML schema/validation system if doesn't exist

---

## Review Checklist

- [ ] Code follows Lua/Love2D best practices
- [ ] All TOML files follow consistent format
- [ ] Required fields present in all examples
- [ ] Comments explain purpose of each field
- [ ] No warnings in Love2D console when loading
- [ ] Documentation is clear and comprehensive
- [ ] Examples serve as good templates for modders
- [ ] Naming convention is consistent
- [ ] All examples validated and tested

---

## Post-Completion

### What Worked Well
- TBD after implementation

### What Could Be Improved
- TBD after implementation

### Lessons Learned
- TBD after implementation
