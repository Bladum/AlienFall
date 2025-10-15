# Task: Document Facilities System

**Status:** TODO  
**Priority:** High  
**Created:** October 15, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent / Developer

---

## Overview

Create comprehensive documentation for the Facilities System in `docs/content/facilities/` or `docs/basescape/facilities.md` based on the existing implementation in `engine/basescape/facilities/` and the design notes in `wiki/wiki/facilities.md`.

---

## Purpose

The Facilities System is **fully implemented** in the engine but **lacks documentation** in the docs/ folder. This creates a gap where:
- Game designers cannot reference facility mechanics
- Balancers don't have a central source for facility stats and bonuses
- Modders cannot understand how to create custom facilities
- Developers need to read code to understand the facility system

This task creates the missing documentation to close that gap.

---

## Requirements

### Functional Requirements
- [ ] Document construction rules (prerequisites, costs, time, terrain)
- [ ] Document connection system (facility linking and power distribution)
- [ ] Document capacity bonuses (radar, prisoners, units, crafts, items, research, manufacturing)
- [ ] Document operational bonuses (healing, training, sanity, repair, defenses)
- [ ] Document facility adjacency bonus system
- [ ] Document base health during interception
- [ ] Document neutral units in facilities during battlescape
- [ ] Document map blocks used for battlescape representation
- [ ] Document service system (required/provided services)
- [ ] Document special facility types (underwater, underground, space)

### Technical Requirements
- [ ] Follow docs/ folder structure and format standards
- [ ] Include examples and formulas for bonuses
- [ ] Cross-reference related systems (basescape, battlescape, interception, economy)
- [ ] Include links to implementation (`engine/basescape/facilities/`)
- [ ] Include links to tests (`tests/` if they exist)
- [ ] Decide on location: `docs/content/facilities/` OR `docs/basescape/facilities.md`

### Acceptance Criteria
- [ ] Complete facilities mechanics documentation created
- [ ] All facility types and bonuses documented
- [ ] Construction system fully explained
- [ ] Examples provided for common scenarios
- [ ] Cross-references to related docs working
- [ ] After completion, `wiki/wiki/facilities.md` can be removed

---

## Plan

### Step 1: Analyze Implementation
**Description:** Read and understand the current facilities implementation  
**Files to review:**
- `engine/basescape/facilities/` (all facility files)
- `engine/basescape/` (base management integration)
- `engine/battlescape/` (facility map blocks if applicable)
- `engine/interception/` (base defense mechanics)
- `wiki/wiki/facilities.md` (design notes - 117 lines)

**Estimated time:** 1.5 hours

### Step 2: Decide Documentation Location
**Description:** Determine best location for facilities documentation  
**Options:**
- **Option A:** `docs/content/facilities/` - Separate content folder (like crafts)
- **Option B:** `docs/basescape/facilities.md` - Within basescape folder

**Decision factors:**
- Facilities are core to basescape layer
- But also referenced in battlescape and interception
- Content/ folder is for game entities (units, items, crafts)

**Recommendation:** `docs/content/facilities/` for consistency with crafts

**Estimated time:** 15 minutes

### Step 3: Create Documentation Structure
**Description:** Set up folder structure and main files  
**Files to create:**
- `docs/content/facilities/README.md` (main facilities documentation)
- `docs/content/facilities/construction.md` (construction rules - optional)
- `docs/content/facilities/bonuses.md` (capacity and operational bonuses - optional)
- `docs/content/facilities/special-types.md` (underwater, underground, space - optional)

**Estimated time:** 30 minutes

### Step 4: Write Core Documentation
**Description:** Document all facility mechanics and systems  
**Content to include:**
- **Construction:** Prerequisites, costs, time, terrain, connection requirements
- **Connection System:** How facilities must link to HQ and each other
- **Capacity Bonuses:** Radar (km), prisoners (space), units (size-based), crafts (size-based), items (size-based), research (man-days), manufacturing (man-days)
- **Operational Bonuses:** Healing (+HP/week), training (+XP/week), sanity (+sanity/week), repair (+%/week), base defenses (interception stats), battlescape defenses (turret units)
- **Adjacency:** Performance boosts from strategic placement
- **Base Health:** Facility health contributing to interception endurance
- **Neutral Units:** Non-combatants in facilities during battlescape
- **Map Blocks:** Visual representation in tactical combat
- **Services:** Required and provided service tags
- **Special Types:** Underwater, underground, space variants

**Estimated time:** 2.5 hours

### Step 5: Add Examples and Cross-References
**Description:** Enhance documentation with examples and links  
**Tasks:**
- Add example facility layouts
- Add example bonus calculations
- Add example construction chains (prerequisite trees)
- Cross-reference basescape, battlescape, interception, economy docs
- Link to implementation files
- Add facility type comparison table

**Estimated time:** 45 minutes

### Step 6: Review and Verify
**Description:** Verify documentation against implementation  
**Tasks:**
- Check all bonuses match implementation
- Verify construction rules are correct
- Ensure all facility types are covered
- Validate cross-references work
- Get review from team member if available

**Estimated time:** 30 minutes

---

## Implementation Details

### Architecture
This is a **documentation task** - no code changes required. The facilities system is already implemented in:
- `engine/basescape/facilities/` - Facility types and mechanics
- `engine/basescape/` - Base management and construction
- `engine/battlescape/` - Facility map blocks and tactical representation
- `engine/interception/` - Base defense mechanics

The documentation will be created in:
- `docs/content/facilities/` - New folder for facilities documentation

### Key Components
- **Construction System:** Prerequisites, costs, time, connection requirements
- **Capacity Bonuses:** Radar, prisoners, units, crafts, items, research, manufacturing
- **Operational Bonuses:** Healing, training, sanity, repair, defenses
- **Adjacency System:** Strategic placement bonuses
- **Service System:** Required/provided service tags
- **Special Types:** Underwater, underground, space facilities
- **Battlescape Integration:** Map blocks and neutral units
- **Interception Integration:** Base health and defense stats

### Dependencies
- Basescape system (for construction and management)
- Economy system (for costs and manufacturing)
- Battlescape system (for map blocks)
- Interception system (for base defense)

---

## Testing Strategy

### Documentation Quality Checks
- [ ] All facility types documented
- [ ] All bonuses include formulas and examples
- [ ] Cross-references work correctly
- [ ] Implementation links are valid
- [ ] Construction prerequisites shown clearly
- [ ] Capacity calculations explained

### Verification Against Implementation
- [ ] Read `engine/basescape/facilities/` to verify facility types
- [ ] Check bonus calculations match implementation
- [ ] Verify construction rules are accurate
- [ ] Confirm service system works as described
- [ ] Validate special facility types exist

### Manual Review Steps
1. Read through all created documentation
2. Compare with implementation code
3. Verify examples work as described
4. Check cross-references navigate correctly
5. Ensure formatting follows docs/ standards
6. Validate facility type comparison table is accurate

### Expected Results
- Complete facilities system documentation in `docs/content/facilities/`
- All mechanics accurately described
- Easy-to-understand examples included
- Ready to remove `wiki/wiki/facilities.md`

---

## How to Run/Debug

This is a documentation task - no game execution required.

### Reviewing Implementation
```bash
# Open facilities implementation
ls engine/basescape/facilities/

# Search for facility usage in basescape
grep -r "facility\|facilities" engine/basescape/

# Search for facility usage in battlescape
grep -r "facility" engine/battlescape/

# Search for facility usage in interception
grep -r "facility" engine/interception/
```

### Verifying Documentation
- Read created docs in VS Code
- Check markdown rendering with preview
- Verify links work (Ctrl+Click in VS Code)
- Review with docs/OVERVIEW.md for consistency

---

## Documentation Updates

### Files to Create
- [ ] `docs/content/facilities/README.md` - Main facilities documentation
- [ ] `docs/content/facilities/construction.md` - Construction rules (optional)
- [ ] `docs/content/facilities/bonuses.md` - Bonuses reference (optional)
- [ ] `docs/content/facilities/special-types.md` - Special facility types (optional)

### Files to Update
- [ ] `docs/OVERVIEW.md` - Add link to facilities documentation
- [ ] `docs/content/README.md` - Add facilities to content index (if exists)
- [ ] `docs/basescape/README.md` - Add cross-reference to facilities
- [ ] `docs/economy/README.md` - Add cross-reference to facility construction costs
- [ ] `docs/battlescape/README.md` - Add cross-reference to facility map blocks
- [ ] `docs/interception/README.md` - Add cross-reference to base defense

### Files to Remove (After Completion)
- [ ] `wiki/wiki/facilities.md` - Design notes superseded by docs

---

## Notes

**Source Materials:**
- `wiki/wiki/facilities.md` - Contains 117 lines of design notes
- `engine/basescape/facilities/` - Actual implementation

**Key Facility Mechanics to Document:**

1. **Construction:**
   - Prerequisites (tech requirements)
   - Costs (credits, materials)
   - Time (days to build)
   - Connection requirement (must link to HQ)

2. **Capacity Bonuses:**
   - Radar: Range in km (1 tile = 500km), power for mission detection
   - Prisoners: 1 prisoner = 1 space
   - Units: Size-based (1 space for normal, 4 for large)
   - Crafts: Size-based (1-4+ spaces)
   - Items: Based on SIZE attribute
   - Research: Man-days of scientist work (daily payment when used)
   - Manufacturing: Man-days of engineer work (daily payment when used)

3. **Operational Bonuses:**
   - Healing: +HP/week (base: 1 HP/week)
   - Training: +XP/week (base: 1 XP/week)
   - Sanity: +sanity/week (base: 1/week)
   - Repair: +%/week (base: 10%/week)
   - Interception Defense: Weapon stats
   - Battlescape Defense: Turret unit templates

4. **Special Features:**
   - Adjacency bonuses (needs design agreement)
   - Base health contribution for interception
   - Neutral units during battlescape
   - Map block for tactical representation
   - Service tags (required/provided)

5. **Special Types:**
   - Underwater: Aquatic bases only
   - Underground: Standard (default)
   - Space: Orbital bases only

**Documentation Format:**
Follow the format established in `docs/basescape/`, `docs/economy/`, etc. with:
- Clear sections with headers
- Tables for facility comparison
- Formulas with examples
- Cross-references to related systems
- Implementation and test links at the top

---

## Blockers

None - All information is available in existing code and design notes.

**Dependencies:**
- None - This is a documentation task

**Open Questions:**
- Should we use `docs/content/facilities/` or `docs/basescape/facilities.md`? (Recommend content/facilities/ for consistency)
- How does adjacency bonus work exactly? (Mark as "To be determined" if not clear from implementation)

---

## Review Checklist

- [ ] All facility types documented
- [ ] Construction rules fully explained (prerequisites, costs, time)
- [ ] Connection system documented
- [ ] All capacity bonuses explained with formulas
- [ ] All operational bonuses explained with formulas
- [ ] Adjacency bonus system documented
- [ ] Base health mechanics explained
- [ ] Neutral units system documented
- [ ] Map block integration documented
- [ ] Service system explained
- [ ] Special facility types covered (underwater, underground, space)
- [ ] Cross-references to related docs added
- [ ] Implementation links included
- [ ] Examples provided for clarity
- [ ] Facility comparison table included
- [ ] Formatting follows docs/ standards
- [ ] Markdown renders correctly
- [ ] Ready to remove wiki/wiki/facilities.md

---

## Post-Completion

### What Worked Well
- (To be filled after completion)

### What Could Be Improved
- (To be filled after completion)

### Lessons Learned
- (To be filled after completion)
