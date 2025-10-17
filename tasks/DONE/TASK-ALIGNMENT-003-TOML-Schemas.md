# Task: Define TOML Schemas and Documentation

**Status:** TODO  
**Priority:** HIGH  
**Created:** October 16, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent / Development Team

---

## Overview

Create comprehensive documentation for all TOML file schemas used in mod content. Define required fields, optional fields, data types, valid values, and provide examples. Enable modders to create valid content without reverse-engineering code.

---

## Purpose

**Current Problem:**
- TOML content structure is implicit from code
- No documentation of required/optional fields
- Modders must guess field names and formats
- No validation against schemas
- High chance of content errors

**Solution:**
Create detailed schema documentation for each content type, following OpenXCOM's approach but adapted for AlienFall.

---

## Requirements

### Functional Requirements
- [ ] Document schema for all 13+ content types
- [ ] Specify required vs optional fields
- [ ] Define data types and valid ranges
- [ ] Provide complete examples
- [ ] Explain relationships between content types
- [ ] Include migration guide from code to TOML

### Technical Requirements
- [ ] Schema format: Markdown documentation with embedded examples
- [ ] Compatible with existing TOML parser
- [ ] Matches DataLoader expectations (TASK-ALIGNMENT-002)
- [ ] Follows TOML 1.0.0 specification
- [ ] Includes validation rules

### Acceptance Criteria
- [ ] Schema docs exist for all content types
- [ ] Each schema includes required fields, optional fields, examples
- [ ] Schemas validated against existing TOML files
- [ ] Documentation accessible from docs/mods/
- [ ] Quick reference guide created
- [ ] Integration with mod development guide

---

## Plan

### Step 1: Create Schema Documentation Structure (1 hour)
**Description:** Set up documentation structure  
**Directories to create:**
```
docs/mods/toml_schemas/
├── README.md
├── terrain_schema.md
├── weapons_schema.md
├── armors_schema.md
├── units_schema.md
├── facilities_schema.md
├── missions_schema.md
├── campaigns_schema.md
├── factions_schema.md
├── technology_schema.md
├── narrative_schema.md
├── geoscape_schema.md
└── economy_schema.md
```

**Estimated time:** 1 hour

### Step 2: Document Terrain Schema (2 hours)
**Description:** Complete terrain.toml schema documentation  
**Files to create:**
- `docs/mods/toml_schemas/terrain_schema.md`

**Content structure:**
```markdown
# Terrain TOML Schema

## Overview
Defines terrain types for battlescape tactical maps.

## File Location
`mods/*/rules/battle/terrain.toml`

## Schema Definition

### Required Fields
| Field | Type | Description | Example |
|-------|------|-------------|---------|
| terrain | table | Root terrain definitions | See below |

### Terrain Entry Schema
| Field | Type | Required | Description | Valid Values |
|-------|------|----------|-------------|--------------|
| id | string | ✅ Yes | Unique terrain ID | snake_case |
| name | string | ✅ Yes | Display name | Any string |
| image | string | ✅ Yes | Asset path | path/to/image.png |
| passable | boolean | ✅ Yes | Can units walk through | true/false |
| blocksLOS | boolean | ✅ Yes | Blocks line of sight | true/false |
| cover | string | ⚠️ Optional | Cover value | "none", "half", "full" |
| destructible | boolean | ⚠️ Optional | Can be destroyed | true/false |
| health | integer | ⚠️ Optional | Hit points if destructible | 0-1000 |

### Complete Example
```toml
[terrain.grass]
id = "grass"
name = "Grass Terrain"
image = "terrain/grass.png"
passable = true
blocksLOS = false
cover = "none"
```

## Validation Rules
- `id` must be unique within file
- `image` must reference existing asset
- If `destructible = true`, `health` is required
- `cover` must be one of: "none", "half", "full"

## Related Schemas
- Assets: `image` field links to asset files
- MapBlocks: Reference terrain types by ID
```

**Estimated time:** 2 hours

### Step 3: Document Weapons Schema (3 hours)
**Description:** Complete weapons.toml schema documentation  
**Files to create:**
- `docs/mods/toml_schemas/weapons_schema.md`

**Schema includes:**
- Weapon stats (damage, accuracy, range)
- Fire modes (snap, auto, aimed)
- Ammo capacity and type
- Sound and visual effects
- Cost and manufacturing requirements

**Estimated time:** 3 hours

### Step 4: Document Units Schema (3 hours)
**Description:** Complete units schema (soldiers, aliens, civilians)  
**Files to create:**
- `docs/mods/toml_schemas/units_schema.md`

**Schema includes:**
- Unit statistics (health, TU, stamina, etc.)
- Armor compatibility
- Inventory configuration
- Rank progression
- AI behavior flags

**Estimated time:** 3 hours

### Step 5: Document Facilities Schema (2 hours)
**Description:** Complete facilities.toml schema  
**Files to create:**
- `docs/mods/toml_schemas/facilities_schema.md`

**Estimated time:** 2 hours

### Step 6: Document Missions Schema (2 hours)
**Description:** Complete mission_types.toml schema  
**Files to create:**
- `docs/mods/toml_schemas/missions_schema.md`

**Estimated time:** 2 hours

### Step 7: Document Campaigns Schema (3 hours)
**Description:** Complete campaign phase schema  
**Files to create:**
- `docs/mods/toml_schemas/campaigns_schema.md`

**Estimated time:** 3 hours

### Step 8: Document Factions Schema (2 hours)
**Description:** Complete faction definition schema  
**Files to create:**
- `docs/mods/toml_schemas/factions_schema.md`

**Estimated time:** 2 hours

### Step 9: Document Technology Schema (3 hours)
**Description:** Complete research tree schema  
**Files to create:**
- `docs/mods/toml_schemas/technology_schema.md`

**Estimated time:** 3 hours

### Step 10: Document Remaining Schemas (3 hours)
**Description:** Complete narrative, geoscape, economy schemas  
**Files to create:**
- `docs/mods/toml_schemas/narrative_schema.md`
- `docs/mods/toml_schemas/geoscape_schema.md`
- `docs/mods/toml_schemas/economy_schema.md`

**Estimated time:** 3 hours

### Step 11: Create Quick Reference Guide (2 hours)
**Description:** Summary document with all schemas  
**Files to create:**
- `docs/mods/toml_schemas/README.md` - Index and quick reference
- `docs/mods/TOML_QUICK_REFERENCE.md` - Single-page reference

**Estimated time:** 2 hours

### Step 12: Integration and Validation (2 hours)
**Description:** Validate schemas against existing TOML files  
**Tasks:**
- Check schemas match TASK-ALIGNMENT-001 templates
- Verify DataLoader expectations (TASK-ALIGNMENT-002)
- Test examples parse correctly
- Update mod development guide

**Files to update:**
- `docs/mods/system.md` - Link to schemas
- `docs/QUICK_NAVIGATION.md` - Add schema references

**Estimated time:** 2 hours

---

## Implementation Details

### Documentation Template
Each schema document follows this structure:
```markdown
# [Content Type] TOML Schema

## Overview
Brief description of what this content type does.

## File Location
Where the TOML file should be placed in mod directory.

## Schema Definition
### Required Fields
Table of required fields with types and descriptions.

### Optional Fields
Table of optional fields with defaults.

### Nested Structures
Tables, arrays, and complex structures.

## Complete Examples
Full working examples with comments.

## Validation Rules
What the loader validates.

## Related Schemas
Cross-references to other content types.

## Common Patterns
Typical use cases and patterns.

## Troubleshooting
Common errors and solutions.
```

### Schema Documentation Style
- Clear, concise descriptions
- Tables for field definitions
- Code blocks for examples
- Validation rules explicit
- Cross-references for relationships

### Key Components
- **Field Tables:** Name, Type, Required, Description, Valid Values
- **Examples:** Complete, working, commented
- **Validation:** What gets checked by DataLoader
- **Relationships:** How schemas link together

---

## Testing Strategy

### Validation Tests
For each schema:
1. Create example TOML file following schema
2. Parse with TOML parser
3. Load with DataLoader
4. Verify all fields accessible
5. Test validation rules work

### Documentation Review
- [ ] All fields documented
- [ ] Examples parse correctly
- [ ] Validation rules complete
- [ ] Cross-references valid
- [ ] No ambiguities

### Integration Tests
```lua
-- Test schema documentation matches implementation
local TOML = require("utils.toml")
local DataLoader = require("core.data_loader")

-- Load example from schema docs
local exampleData = TOML.load("docs/mods/toml_schemas/examples/terrain_example.toml")

-- Verify DataLoader can load it
DataLoader.terrainTypes = DataLoader.loadTerrainTypes()
local terrain = DataLoader.terrainTypes.get("grass")

assert(terrain ~= nil, "Example should load successfully")
assert(terrain.passable ~= nil, "Required fields should be present")
```

---

## How to Run/Debug

1. **Create schema document:**
   - Follow template structure
   - Add field definitions
   - Include complete examples

2. **Validate example:**
   ```bash
   lovec "engine" -e "print(require('utils.toml').load('example.toml'))"
   ```

3. **Test with DataLoader:**
   ```lua
   local DataLoader = require("core.data_loader")
   DataLoader.load()
   -- Check if example data loaded
   ```

4. **Review checklist:**
   - All required fields documented?
   - Optional fields have defaults?
   - Examples work?
   - Validation rules clear?

---

## Documentation Updates

### Files to Create
- `docs/mods/toml_schemas/` (12+ files)
- `docs/mods/TOML_QUICK_REFERENCE.md`

### Files to Update
- `docs/mods/system.md` - Add schema section
- `docs/QUICK_NAVIGATION.md` - Link to schemas
- `README.md` - Mention schema documentation
- `tasks/tasks.md` - Mark complete

---

## Review Checklist

- [ ] All 12+ schemas documented
- [ ] Each schema has required/optional field tables
- [ ] Complete examples provided
- [ ] Examples parse without errors
- [ ] Validation rules documented
- [ ] Cross-references added
- [ ] Quick reference guide created
- [ ] Integration with mod guide
- [ ] No ambiguous descriptions
- [ ] Consistent format across all schemas

---

## Notes

**Design References:**
- OpenXCOM ruleset format: https://www.ufopaedia.org/index.php/Ruleset_Reference_(OpenXcom)
- TOML 1.0.0 spec: https://toml.io/en/v1.0.0
- Existing TOML files from TASK-ALIGNMENT-001

**Schema Priority:**
1. Units, Weapons, Armors (gameplay-critical)
2. Missions, Campaigns (strategic layer)
3. Factions, Technology (progression)
4. Others (polish)

**Integration:**
- TASK-ALIGNMENT-001 creates TOML files
- TASK-ALIGNMENT-002 implements loaders
- THIS TASK documents what loaders expect
- TASK-ALIGNMENT-005 will validate against schemas

---

## What Worked Well
(To be filled in after completion)

---

## Lessons Learned
(To be filled in after completion)

---

## Follow-up Tasks
- TASK-ALIGNMENT-005: Implement Content Validation (validate against these schemas)
- TASK-ALIGNMENT-006: Create Mod Development Guide (use schemas as reference)
