# API Synchronization Guide

**Status:** ✅ Complete
**Version:** 1.0.0
**Last Updated:** October 24, 2025
**Purpose:** Maintain alignment between engine code, API documentation, and GAME_API.toml schema

---

## Implementation Status

### ✅ Implemented
- Synchronization workflow documented
- GAME_API.toml as master schema
- Update checklist provided
- Version management guidelines

### 🚧 Partially Implemented
- Automated validation scripts
- Schema change detection

### 📋 Planned
- Automated sync verification tool
- CI/CD integration for schema validation
- Breaking change detection system

---

## Overview

The API ecosystem consists of three interconnected pieces:

```
┌─────────────────────────────────────────────────┐
│  1. ENGINE CODE                                 │
│  (engine/*.lua)                                 │
│  - Loads data                                   │
│  - Uses fields in code                          │
│  - Defines expectations                         │
└─────────────┬───────────────────────────────────┘
              │
              ↓
┌─────────────────────────────────────────────────┐
│  2. GAME_API.TOML SCHEMA                        │
│  (api/GAME_API.toml)                            │
│  - Master source of truth                       │
│  - Defines all fields & types                   │
│  - Serves validators & tools                    │
└─────────────┬───────────────────────────────────┘
              │
              ↓
┌─────────────────────────────────────────────────┐
│  3. API DOCUMENTATION                           │
│  (api/*.md)                                     │
│  - Human-readable reference                     │
│  - Usage examples                               │
│  - Integration patterns                         │
└─────────────────────────────────────────────────┘
```

**Goal:** Keep all three synchronized when changes are made.

---

## When Synchronization Happens

### Scenario 1: Adding a New Field to Engine

**Situation:** Engine code needs to read a new field from mod data.

**Example:** Adding `skill_trees` array to unit classes for progression customization.

**Step-by-Step:**

1. **Update Engine Code** (`engine/basescape/units/progression.lua`)
   ```lua
   function Unit:loadSkillTree(unit_class_data)
     self.skill_trees = unit_class_data.skill_trees or {}  -- NEW FIELD
     self:initializeSkills()
   end
   ```

2. **Update GAME_API.toml** (`api/GAME_API.toml`)
   ```toml
   [api.units.unit_class.fields]
   skill_trees = { type = "array[string]", required = false, description = "Available skill trees" }
   ```

3. **Update API Documentation** (`api/UNITS.md`)
   ```markdown
   ### Skill Trees

   Units can specialize through one or more skill trees...
   ```

**Timeline:** Update all three synchronously before merging to main branch.

### Scenario 2: Fixing a Field Type

**Situation:** A field is documented as integer but should be float for precision.

**Example:** `fire_rate_base` is currently integer (0-3) but should be float (0.1-3.0) for weapons balance.

**Step-by-Step:**

1. **Identify Problem**
   - Engine code expects integer: `int fire_rate = weapon.fire_rate_base`
   - Schema says: `type = "integer"`
   - But weapons need: `1.5`, `0.8`, etc.

2. **Update Engine Code** to handle float
   ```lua
   -- Before
   local fire_rate = math.floor(weapon.fire_rate_base)

   -- After
   local fire_rate = weapon.fire_rate_base  -- Accepts float
   ```

3. **Update GAME_API.toml**
   ```toml
   fire_rate_base = { type = "float", required = false, default = 1.0, min = 0.1, max = 3.0 }
   ```

4. **Update API Documentation**
   ```markdown
   fire_rate_base = (float) 0.1-3.0 - attacks per turn (e.g., 0.8, 1.5)
   ```

5. **Migration Notice** - Alert existing mod creators about the change
   ```markdown
   ⚠️ Breaking Change: fire_rate_base now accepts float values (was integer)

   Old: fire_rate_base = 2
   New: fire_rate_base = 1.5 (or still 2.0)
   ```

### Scenario 3: Renaming a Field

**Situation:** A field name is confusing and needs renaming.

**Example:** `max_hp` should be `hp_max` for consistency.

**Process:**

1. **Plan Migration**
   - Decide on transition period
   - Support both old and new names temporarily
   - Set deprecation timeline

2. **Update Code** (Phase 1 - Support Both)
   ```lua
   local hp_max = unit_data.hp_max or unit_data.max_hp  -- Accept both
   if unit_data.max_hp then
     print("[WARNING] Field 'max_hp' deprecated, use 'hp_max' instead")
   end
   ```

3. **Update Schema** (Phase 1 - Note Deprecation)
   ```toml
   hp_max = { type = "integer", required = true }
   max_hp = { type = "integer", required = false, deprecated = true,
              migration_note = "Use hp_max instead" }
   ```

4. **Update Documentation** (Phase 1 - Show Deprecation)
   ```markdown
   **Field:** hp_max (was: max_hp - deprecated)
   **Type:** Integer
   **Description:** ...

   ⚠️ NOTE: Old name 'max_hp' still works but is deprecated. Use 'hp_max' instead.
   ```

5. **Phase 2** (After transition period)
   - Remove support for old name
   - Remove from schema
   - Update docs to remove deprecation notice

### Scenario 4: Adding a New Entity Type

**Situation:** New game system needs new entity type.

**Example:** Adding "Spaceship" as distinct from Crafts.

**Step-by-Step:**

1. **Define Requirements** in design docs
   - What fields does this entity need?
   - How does it differ from existing entities?
   - Where is it stored/loaded?

2. **Add to Schema** (`api/GAME_API.toml`)
   ```toml
   [api.spaceships]
   description = "Interstellar spacecraft for campaign"
   file_location = "mods/*/rules/spaceships/*.toml"

   [api.spaceships.spaceship]
   description = "..."
   required_fields = ["id", "name", "type"]

   [api.spaceships.spaceship.fields]
   id = { type = "string", required = true, ... }
   name = { type = "string", required = true, ... }
   # ... all fields
   ```

3. **Add Engine Code** to load and use
   ```lua
   -- engine/campaign/spaceships.lua
   function SpaceshipSystem.loadSpaceships()
     local spaceships = {}
     local data = love.filesystem.load("mods/core/rules/spaceships/spaceships.toml")
     -- Parse and validate against schema
     return spaceships
   end
   ```

4. **Add API Documentation** (`api/SPACESHIPS.md`)
   ```markdown
   # Spaceships API Reference

   [Complete documentation]
   ```

5. **Update SYNCHRONIZATION_GUIDE.md** to document new type

---

## Synchronization Checklist

Use this checklist when making changes:

### For Adding Fields

- [ ] **Engine Code**
  - [ ] Code can read new field
  - [ ] Code handles missing field gracefully
  - [ ] No runtime errors with new data

- [ ] **Schema (GAME_API.toml)**
  - [ ] Field added to correct entity section
  - [ ] Type specified correctly
  - [ ] Default value set (if applicable)
  - [ ] Min/max constraints added
  - [ ] Description is clear

- [ ] **API Documentation**
  - [ ] Field documented in appropriate file
  - [ ] Type and constraints listed
  - [ ] Example usage provided
  - [ ] Integration notes included

- [ ] **Testing**
  - [ ] Schema validates with validator tool
  - [ ] Existing mods still work
  - [ ] New field works in new mods
  - [ ] Documentation is accurate

### For Changing Fields

- [ ] **Analysis**
  - [ ] Identify all code that uses field
  - [ ] Check all mods that might use field
  - [ ] Plan migration strategy

- [ ] **Implementation**
  - [ ] Update engine code first
  - [ ] Maintain backward compatibility (if possible)
  - [ ] Update schema
  - [ ] Update documentation
  - [ ] Add migration notes

- [ ] **Testing**
  - [ ] Old mods still work
  - [ ] New format works
  - [ ] Migrations apply correctly
  - [ ] No silent failures

### For Removing Fields

- [ ] **Deprecation Phase** (if applicable)
  - [ ] Field marked deprecated in schema
  - [ ] Engine supports old field
  - [ ] Warning message in console
  - [ ] Documentation shows deprecation
  - [ ] Timeline announced

- [ ] **Removal Phase**
  - [ ] Engine no longer supports old field
  - [ ] Schema field removed
  - [ ] Documentation updated
  - [ ] Breaking change notice

---

## Common Issues and Solutions

### Issue: Schema and Code Don't Match

**Problem:** Schema says field is string, but engine code expects integer.

**Detection:** Validation passes, but engine crashes at runtime.

**Solution:**
1. Identify which is wrong (schema or code)
2. Check API documentation to understand intent
3. Update the one that's wrong
4. Test both old and new data
5. Document change clearly

**Prevention:**
- Always check schema before writing engine code
- Run schema validation on all mod data
- Test with sample mods

### Issue: Documentation Outdated

**Problem:** Docs show field as required, but schema shows optional.

**Detection:** Mod creators get confused, submit invalid data.

**Solution:**
1. Compare doc with schema
2. Update the incorrect one
3. Add note explaining the change
4. Alert mod creators if it affects them

**Prevention:**
- Review docs during code review
- Use automated doc generation from schema (future)
- Update docs at same time as schema

### Issue: Existing Mods Break After Change

**Problem:** Changed field name/type, now old mods fail to load.

**Detection:** Game crashes when loading mod or gives validation error.

**Solution:**
1. Support old field name during load (with deprecation warning)
2. Convert old format to new format
3. Document migration path
4. Give mod creators time to update

**Prevention:**
- Plan changes carefully
- Support both old and new temporarily
- Use major version bumps for breaking changes
- Give advance notice

---

## Tools and Validation

### Schema Validator (Planned)

```bash
# Validate all mods against schema
love2d-mod-validator validate --schema api/GAME_API.toml mods/

# Validate specific mod
love2d-mod-validator validate mods/mymod/

# Generate report
love2d-mod-validator validate mods/ --output report.json
```

### Documentation Generator (Planned)

```bash
# Auto-generate API docs from schema
love2d-doc-generator generate --schema api/GAME_API.toml --output api/

# Generate mod template
love2d-doc-generator template --schema api/GAME_API.toml mods/mymod/
```

### Diff Tool (Planned)

```bash
# See what changed in schema
love2d-schema-diff api/GAME_API.toml api/GAME_API.toml.old

# See migration impact
love2d-schema-diff --mods mods/ api/GAME_API.toml.old api/GAME_API.toml
```

### Manual Validation (Today)

```lua
-- Load schema and validate
local schema = love.filesystem.load("api/GAME_API.toml")
local validator = require("tools.validators.schema_validator")

for mod_name in io.popen("dir mods"):lines() do
  local status, errors = validator:validate("mods/" .. mod_name, schema)
  if not status then
    print("Mod " .. mod_name .. " has errors:")
    for _, error in ipairs(errors) do
      print("  - " .. error)
    end
  end
end
```

---

## Version Management

### Schema Versioning

Schema follows semantic versioning:

```toml
[_meta]
api_version = "1.0.0"    # Major.Minor.Patch

# MAJOR: Breaking changes to structure
#   1.0.0 → 2.0.0 (when field types change fundamentally)

# MINOR: New features, backward compatible
#   1.0.0 → 1.1.0 (when new optional fields added)

# PATCH: Bug fixes, clarifications
#   1.0.0 → 1.0.1 (when constraints corrected)
```

### Version History

Track all schema changes:

```toml
[_version_history.v1_0_0]
version = "1.0.0"
released = "2025-10-24"
breaking_changes = []
new_fields = ["units.perks", "crafts.addons"]
removed_fields = []
changed_fields = []
notes = "Initial comprehensive schema"

[_version_history.v1_1_0]
version = "1.1.0"
released = "2025-11-15"
breaking_changes = []
new_fields = ["items.enchantments", "weapons.attachments"]
removed_fields = []
changed_fields = ["items.damage_type (added)"]
notes = "Added enchantment system, weapon attachments"

[_version_history.v2_0_0]
version = "2.0.0"
released = "2026-01-01"
breaking_changes = ["units.max_hp renamed to units.hp_max"]
new_fields = []
removed_fields = ["units.max_hp (deprecated in 1.1.0)"]
changed_fields = []
notes = "Major refactor for consistency"
```

### Compatibility Matrix

| Schema Version | Engine Version | Mod Compatibility |
|---|---|---|
| 1.0.0 | 1.0.0+ | Mods for v1.0 |
| 1.1.0 | 1.1.0+ | Mods for v1.0 (with warnings) |
| 2.0.0 | 2.0.0+ | Mods for v2.0 ONLY |

---

## Process: How to Update Everything

### For Planned Features

1. **Add to Task List** (`tasks/`)
   - What needs to change?
   - Why?
   - Timeline?

2. **Design Phase** (`design/mechanics/`)
   - Document the change
   - Show examples
   - Note impacts

3. **Implementation Phase**
   - Update engine code
   - Update schema
   - Update documentation
   - Add tests

4. **Review Phase**
   - Code review
   - Schema consistency check
   - Documentation review
   - Test coverage

5. **Merge & Release**
   - Merge to main
   - Tag version
   - Announce to mods/devs

### For Bug Fixes

1. **Identify Issue**
   - Code bug? Schema bug? Doc bug?

2. **Fix at Source**
   - Update relevant files
   - Ensure consistency

3. **Test**
   - Reproduce original issue
   - Verify fix works
   - No regressions

4. **Document**
   - Add changelog entry
   - Update version history
   - Note impact

---

## Responsibilities

### Schema Owner

- Keeps GAME_API.toml updated
- Reviews all schema changes
- Maintains version history
- Validates consistency

### Engine Developer

- Checks schema before coding
- Updates schema when code changes
- Tests against schema
- Reports inconsistencies

### Documentation Writer

- Keeps docs synchronized
- Reviews doc changes against schema
- Updates version notes
- Tracks deprecations

### QA / Tester

- Tests mods against schema
- Reports schema issues
- Validates migrations
- Tests backward compatibility

---

## Example: Complete Change Workflow

### Scenario: Add Pilot Skill System

**Week 1: Design**
- Decide on skill structure
- Create design doc: `design/mechanics/pilot_skills.md`
- Get approval from team

**Week 2: Implementation**

Step 1: Update Engine Code
```lua
-- engine/interception/pilot_skills.lua
function PilotSkills:loadSkills(pilot_data)
  self.skills = pilot_data.skills or {}
  self:initializeSkillModifiers()
end
```

Step 2: Update Schema
```toml
# In api/GAME_API.toml
[api.units.pilots.fields]
skills = { type = "array[string]", required = false,
           description = "Learned skills for pilot" }
```

Step 3: Update Documentation
```markdown
# api/PILOTS.md
## Pilot Skills

Pilots can learn combat skills through training...
```

Step 4: Write Tests
```lua
-- tests/unit/pilot_skills_test.lua
function TestPilotSkills:test_load_skills()
  -- Test that skills load correctly
end
```

Step 5: Update This Guide
- Add pilot skills to relevant scenarios
- Note any special sync concerns

**Week 3: Review**
- Code review
- Schema review
- Doc review
- Test review

**Week 4: Release**
- Merge to main
- Tag version
- Update CHANGELOG
- Announce to modders

---

## Automation Opportunities

Future improvements to reduce manual sync:

1. **Schema-to-Doc Generator**
   - Auto-generate API docs from schema
   - Keeps docs always in sync
   - Human-friendly formatting

2. **Mod Validator**
   - Automatic schema validation
   - Clear error messages
   - Can be integrated into CI/CD

3. **Type Checker**
   - Verify engine code reads correct types
   - Static analysis on Lua code
   - Flags mismatches

4. **Change Detector**
   - Compare schema versions
   - Identify breaking changes
   - Generate migration guides

5. **Documentation Diff**
   - See what docs need updating
   - Compare with schema
   - Generate required updates

---

## Getting Help

**Questions about schema?** → `api/GAME_API_GUIDE.md`
**Questions about sync?** → This file
**Questions about code?** → Code comments
**Questions about design?** → Design docs

**Report inconsistencies:**
- Create issue: "Schema/Engine mismatch: ..."
- Include: Field name, what's wrong, should be
- Link: Relevant files and line numbers

---

**Last Updated:** October 24, 2025
**Document Status:** ✅ Complete
**Next Review:** October 31, 2025
