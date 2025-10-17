# Task: Document Craft System

**Status:** DONE  
**Priority:** High  
**Created:** October 15, 2025  
**Completed:** October 16, 2025  
**Assigned To:** AI Agent / Developer

---

## Overview

Create comprehensive documentation for the Craft System in `docs/content/crafts/` based on the existing implementation in `engine/core/crafts/craft.lua` and the design notes in `wiki/wiki/crafts.md`.

---

## Purpose

The Craft System is **fully implemented** in the engine but **lacks documentation** in the docs/ folder. This creates a gap where:
- Game designers cannot reference craft mechanics
- Balancers don't have a central source for craft stats
- Modders cannot understand how to create custom crafts
- Developers need to read code to understand the system

This task creates the missing documentation to close that gap.

---

## Requirements

### Functional Requirements
- [ ] Document all craft stats (speed, health, weapon slots, cargo, fuel, range, etc.)
- [ ] Document craft equipment system (weapons, addons, slots)
- [ ] Document craft operations on geoscape (travel, radar, interception)
- [ ] Document craft progression/experience system
- [ ] Document craft maintenance and repair mechanics
- [ ] Document craft fuel and range mechanics
- [ ] Document craft action points and energy pool
- [ ] Document craft types (air, land, water)
- [ ] Document craft purchase/manufacture system

### Technical Requirements
- [ ] Follow docs/ folder structure and format standards
- [ ] Include examples and formulas
- [ ] Cross-reference related systems (geoscape, interception, economy)
- [ ] Include links to implementation (`engine/core/crafts/`)
- [ ] Include links to tests (`tests/` if they exist)

### Acceptance Criteria
- [ ] Complete craft mechanics documentation in `docs/content/crafts/`
- [ ] All craft stats and formulas documented
- [ ] Examples provided for common scenarios
- [ ] Cross-references to related docs working
- [ ] After completion, `wiki/wiki/crafts.md` can be removed

---

## Plan

### Step 1: Analyze Implementation
**Description:** Read and understand the current craft implementation  
**Files to review:**
- `engine/core/crafts/craft.lua`
- `engine/geoscape/` (craft operations)
- `engine/interception/` (craft combat)
- `wiki/wiki/crafts.md` (design notes)

**Estimated time:** 1 hour

### Step 2: Create Documentation Structure
**Description:** Set up folder structure and main files  
**Files to create:**
- `docs/content/crafts/README.md` (main craft documentation)
- `docs/content/crafts/stats.md` (craft statistics reference)
- `docs/content/crafts/equipment.md` (weapons and addons)
- `docs/content/crafts/operations.md` (geoscape operations)

**Estimated time:** 30 minutes

### Step 3: Write Core Documentation
**Description:** Document all craft mechanics and systems  
**Content to include:**
- Craft stats and attributes
- Equipment system (weapons, addons, slots)
- Operations (travel, radar, deployment)
- Progression and experience
- Maintenance and repair
- Fuel and range calculations
- Action points and energy mechanics
- Craft types and their differences

**Estimated time:** 2 hours

### Step 4: Add Examples and Cross-References
**Description:** Enhance documentation with examples and links  
**Tasks:**
- Add example craft configurations
- Add example travel calculations
- Add example fuel consumption scenarios
- Cross-reference geoscape, interception, economy docs
- Link to implementation files

**Estimated time:** 30 minutes

### Step 5: Review and Verify
**Description:** Verify documentation against implementation  
**Tasks:**
- Check all stats match implementation
- Verify formulas are correct
- Ensure all mechanics are covered
- Validate cross-references work
- Get review from team member if available

**Estimated time:** 30 minutes

---

## Implementation Details

### Architecture
This is a **documentation task** - no code changes required. The craft system is already implemented in:
- `engine/core/crafts/craft.lua` - Core craft class and mechanics
- `engine/geoscape/` - Geoscape craft operations
- `engine/interception/` - Interception combat mechanics

The documentation will be created in:
- `docs/content/crafts/` - New folder for craft documentation

### Key Components
- **Craft Stats:** Speed, health, slots, capacity, fuel, range, AP, energy
- **Equipment:** Weapon slots, addon slots, modular loadouts
- **Operations:** Travel, radar detection, mission deployment
- **Progression:** Experience system and craft upgrades
- **Maintenance:** Repair mechanics and costs
- **Fuel System:** Consumption, range calculation, refueling

### Dependencies
- Geoscape system (for craft movement)
- Interception system (for combat)
- Economy system (for purchase/manufacture)
- Base facilities (hangars for storage)

---

## Testing Strategy

### Documentation Quality Checks
- [ ] All craft stats documented
- [ ] All formulas include examples
- [ ] Cross-references work correctly
- [ ] Implementation links are valid
- [ ] Examples are accurate

### Verification Against Implementation
- [ ] Read `engine/core/crafts/craft.lua` to verify stats
- [ ] Check geoscape integration for operations
- [ ] Verify interception mechanics match docs
- [ ] Confirm fuel/range calculations are correct

### Manual Review Steps
1. Read through all created documentation
2. Compare with implementation code
3. Verify examples work as described
4. Check cross-references navigate correctly
5. Ensure formatting follows docs/ standards

### Expected Results
- Complete craft system documentation in `docs/content/crafts/`
- All mechanics accurately described
- Easy-to-understand examples included
- Ready to remove `wiki/wiki/crafts.md`

---

## How to Run/Debug

This is a documentation task - no game execution required.

### Reviewing Implementation
```bash
# Open craft implementation
code engine/core/crafts/craft.lua

# Search for craft usage in geoscape
grep -r "craft" engine/geoscape/

# Search for craft usage in interception
grep -r "craft" engine/interception/
```

### Verifying Documentation
- Read created docs in VS Code
- Check markdown rendering with preview
- Verify links work (Ctrl+Click in VS Code)
- Review with docs/OVERVIEW.md for consistency

---

## Documentation Updates

### Files to Create
- [ ] `docs/content/crafts/README.md` - Main craft documentation
- [ ] `docs/content/crafts/stats.md` - Craft statistics reference (optional)
- [ ] `docs/content/crafts/equipment.md` - Equipment system (optional)
- [ ] `docs/content/crafts/operations.md` - Operations guide (optional)

### Files to Update
- [ ] `docs/OVERVIEW.md` - Add link to crafts documentation
- [ ] `docs/content/README.md` - Add crafts to content index (if exists)
- [ ] `docs/geoscape/README.md` - Add cross-reference to crafts
- [ ] `docs/economy/README.md` - Add cross-reference to craft purchase

### Files to Remove (After Completion)
- [ ] `wiki/wiki/crafts.md` - Design notes superseded by docs

---

## Notes

**Source Materials:**
- `wiki/wiki/crafts.md` - Contains 111 lines of design notes
- `engine/core/crafts/craft.lua` - Actual implementation

**Key Craft Mechanics to Document:**
1. **Stats:** Speed, health, weapon slots (1-2), addon slots (0-2), personnel capacity, cargo limit, fuel consumption, range, AP (4), energy pool, dodge, aim, armor, radar, stealth, size
2. **Equipment:** Weapons and addons, max 3 total slots, different weapon sizes for different craft classes
3. **Operations:** Province-to-province travel, automatic radar detection, interception or return to base
4. **Progression:** Experience levels (100/300/600/1000/1500/2100), slower than units, better to build new craft
5. **Repairs:** 10% health per week base, faster with facilities
6. **Fuel:** Consumed per travel, range based on path cost and craft type
7. **Types:** Air, land, water - affects travel paths and interception positions

**Documentation Format:**
Follow the format established in `docs/battlescape/`, `docs/geoscape/`, etc. with:
- Clear sections with headers
- Code examples where applicable
- Cross-references to related systems
- Implementation and test links at the top

---

## Blockers

None - All information is available in existing code and design notes.

**Dependencies:**
- None - This is a documentation task

**Open Questions:**
- Should we split into multiple files or keep in one README.md? (Recommend starting with one file, split if it gets too large)

---

## Review Checklist

- [ ] All craft stats documented with descriptions
- [ ] Equipment system fully explained
- [ ] Operations (travel, radar, deployment) covered
- [ ] Progression and experience documented
- [ ] Maintenance and repair mechanics explained
- [ ] Fuel and range calculations with examples
- [ ] AP and energy pool mechanics documented
- [ ] Craft types (air/land/water) explained
- [ ] Purchase/manufacture system documented
- [ ] Cross-references to related docs added
- [ ] Implementation links included
- [ ] Examples provided for clarity
- [ ] Formatting follows docs/ standards
- [ ] Markdown renders correctly
- [ ] Ready to remove wiki/wiki/crafts.md

---

## Post-Completion

### What Worked Well
- (To be filled after completion)

### What Could Be Improved
- (To be filled after completion)

### Lessons Learned
- (To be filled after completion)
