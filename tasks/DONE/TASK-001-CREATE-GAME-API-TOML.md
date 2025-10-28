# Task: Create Master GAME_API.TOML Definition File

**Status:** TODO
**Priority:** Critical
**Created:** 2025-10-24
**Completed:** N/A
**Assigned To:** AI Agent

---

## Overview

Create a single, comprehensive TOML file (`GAME_API.toml`) that defines ALL API definitions for the entire game. This file defines the TYPE and STRUCTURE of every keyword that can exist in ANY mod TOML file, serving as the single source of truth for the game's data structure.

---

## Purpose

**Why this is needed:**
- Currently API documentation is scattered across multiple `.md` files in `api/` folder
- Engine code in `engine/` folder has its own structure
- Design docs in `design/` have their own definitions
- No single source of truth for what TOML structure should look like
- Mod creators have no schema to validate against
- Automated validation is impossible without this

**What problem it solves:**
- Provides schema definition for ALL mod content
- Enables automated validation of mod TOML files
- Serves as single source of truth for API structure
- Allows tooling (LSP, validators) to check TOML correctness
- Ensures consistency between engine code, API docs, and actual mod data

---

## Requirements

### Functional Requirements
- [ ] Define complete structure for units (soldiers, aliens, civilians)
- [ ] Define complete structure for items (weapons, armor, equipment)
- [ ] Define complete structure for crafts (interceptors, transports)
- [ ] Define complete structure for facilities (base buildings)
- [ ] Define complete structure for research (tech tree)
- [ ] Define complete structure for manufacturing (production)
- [ ] Define complete structure for missions (mission types, maps)
- [ ] Define complete structure for UFOs (alien crafts)
- [ ] Define complete structure for aliens (races, ranks)
- [ ] Define complete structure for regions/countries (geoscape)
- [ ] Define complete structure for events (scripted events)
- [ ] Define complete structure for starting conditions (new game setup)
- [ ] Define complete structure for pilots (pilot system)
- [ ] Define complete structure for perks/skills
- [ ] Define complete structure for economy (prices, costs)
- [ ] Define complete structure for politics (factions, diplomacy)
- [ ] Define complete structure for lore (story content)
- [ ] Define all ENUM values for restricted fields
- [ ] Define all TYPE constraints (string, int, float, bool, array, table)
- [ ] Define REQUIRED vs OPTIONAL fields
- [ ] Define DEFAULT values where applicable
- [ ] Define MIN/MAX constraints for numeric values
- [ ] Define REFERENCES to other entities (foreign keys)

### Technical Requirements
- [ ] Use TOML format (not JSON or YAML)
- [ ] Use clear section naming: `[api.units]`, `[api.items]`, etc.
- [ ] Use schema-like notation to indicate types
- [ ] Document each field with inline comments
- [ ] Include examples within comments
- [ ] Structure must be parseable by Lua TOML parser
- [ ] Must cover 100% of current API documentation in `api/` folder
- [ ] Must align with engine code expectations in `engine/` folder
- [ ] Must align with design mechanics in `design/mechanics/` folder

### Acceptance Criteria
- [ ] Single `GAME_API.toml` file exists in project root or `api/` folder
- [ ] File contains definitions for ALL game entities
- [ ] Each field has type annotation (e.g., `name = "string"`)
- [ ] Each field has comment explaining purpose
- [ ] ENUM fields list all valid values
- [ ] Required fields are marked as required
- [ ] Optional fields are marked with defaults
- [ ] File can be parsed by Lua TOML library without errors
- [ ] Documentation exists explaining how to read the schema
- [ ] Cross-reference table maps API sections to engine modules

---

## Plan

### Step 1: Audit Existing API Documentation
**Description:** Scan all files in `api/` folder and extract complete list of entities and their fields

**Files to analyze:**
- `api/UNITS.md`
- `api/ITEMS.md`
- `api/WEAPONS_AND_ARMOR.md`
- `api/CRAFTS.md`
- `api/FACILITIES.md`
- `api/RESEARCH_AND_MANUFACTURING.md`
- `api/MISSIONS.md`
- `api/GEOSCAPE.md`
- `api/PILOTS.md`
- `api/POLITICS.md`
- `api/ECONOMY.md`
- `api/LORE.md`
- `api/BATTLESCAPE.md`
- `api/BASESCAPE.md`
- `api/CAMPAIGN.md`
- All other files in `api/`

**Actions:**
- Extract all entity types mentioned
- Extract all field names for each entity
- Extract all data types mentioned
- Extract all enum values mentioned
- Note any constraints (min/max, required, optional)

**Output:** `temp/api_audit.txt` - comprehensive list of all API elements

**Estimated time:** 2-3 hours

---

### Step 2: Audit Engine Code Structure
**Description:** Scan engine code to understand what fields are actually USED and EXPECTED

**Files to analyze:**
- `engine/content/*.lua` - content loaders
- `engine/battlescape/*.lua` - combat systems
- `engine/basescape/*.lua` - base management
- `engine/geoscape/*.lua` - strategic layer
- `engine/core/*.lua` - core systems
- All other relevant engine modules

**Actions:**
- Find all places where TOML data is loaded
- Identify what fields are accessed
- Identify what types are expected
- Find any validation logic
- Note any default values in code

**Output:** `temp/engine_audit.txt` - list of fields actually used by engine

**Estimated time:** 3-4 hours

---

### Step 3: Audit Design Documentation
**Description:** Review design docs to ensure all planned mechanics are covered

**Files to analyze:**
- `design/mechanics/*.md`
- `design/gaps/*.md`
- `architecture/*.md`

**Actions:**
- Identify mechanics that need data structures
- Check if current API covers these mechanics
- Note any missing fields or entities

**Output:** `temp/design_audit.txt` - list of design requirements

**Estimated time:** 1-2 hours

---

### Step 4: Create Schema Structure
**Description:** Design the structure of `GAME_API.toml` file

**Approach:**
```toml
# GAME_API.toml - Master API Schema Definition
# This file defines the structure and types for all mod TOML files

[_meta]
version = "1.0.0"
description = "Game API Schema - defines structure for all mod content"

# UNITS API DEFINITION
[api.units]
# Defines structure for files in: mods/*/rules/units/*.toml

  [api.units.fields]
  id = { type = "string", required = true, description = "Unique unit identifier" }
  name = { type = "string", required = true, description = "Display name" }
  type = { type = "enum", required = true, values = ["soldier", "alien", "civilian"], description = "Unit type" }
  race = { type = "string", required = true, description = "Race identifier, references races.toml" }
  rank = { type = "string", required = false, default = "rookie", description = "Starting rank" }

  [api.units.fields.stats]
  health = { type = "integer", required = true, min = 1, max = 999, description = "Health points" }
  time_units = { type = "integer", required = true, min = 1, max = 255, description = "Time units per turn" }
  stamina = { type = "integer", required = true, min = 1, max = 255, description = "Stamina/energy" }
  # ... etc

# ITEMS API DEFINITION
[api.items]
# Defines structure for files in: mods/*/rules/items/*.toml

  [api.items.fields]
  id = { type = "string", required = true, description = "Unique item identifier" }
  name = { type = "string", required = true, description = "Display name" }
  type = { type = "enum", required = true, values = ["weapon", "armor", "equipment", "craft_weapon", "ammo"], description = "Item type" }
  # ... etc

# Continue for all entity types...
```

**Files to create:**
- `GAME_API.toml` - main schema file
- `api/GAME_API_GUIDE.md` - how to read and use the schema

**Estimated time:** 4-6 hours

---

### Step 5: Populate Complete Schema
**Description:** Fill in ALL fields for ALL entity types based on audits

**Sections to complete:**
- `[api.units]` - all unit types
- `[api.items]` - all items
- `[api.weapons]` - weapon specifics
- `[api.armor]` - armor specifics
- `[api.crafts]` - craft types
- `[api.facilities]` - base facilities
- `[api.research]` - research projects
- `[api.manufacturing]` - manufacturing projects
- `[api.missions]` - mission types
- `[api.ufos]` - UFO types
- `[api.aliens]` - alien races
- `[api.regions]` - geoscape regions
- `[api.countries]` - countries
- `[api.events]` - scripted events
- `[api.starting]` - starting game data
- `[api.pilots]` - pilot data
- `[api.perks]` - skills/perks
- `[api.economy]` - economic data
- `[api.politics]` - political entities
- `[api.lore]` - story content
- `[api.tilesets]` - battlescape tilesets
- `[api.mapblocks]` - map blocks

**Estimated time:** 8-12 hours

---

### Step 6: Add Cross-Reference Mappings
**Description:** Create mapping between API schema, engine code, and mod file locations

**Create section:**
```toml
[_mappings]
# Maps API definitions to engine modules and mod file paths

  [_mappings.units]
  api_section = "api.units"
  engine_module = "engine/content/units_loader.lua"
  mod_path = "mods/*/rules/units/*.toml"
  validator = "tools/validators/validate_units.lua"

  [_mappings.items]
  api_section = "api.items"
  engine_module = "engine/content/items_loader.lua"
  mod_path = "mods/*/rules/items/*.toml"
  validator = "tools/validators/validate_items.lua"

# ... etc for all types
```

**Estimated time:** 2-3 hours

---

### Step 7: Create Synchronization Guide
**Description:** Document how to keep engine, API docs, and GAME_API.toml in sync

**Create file:** `api/SYNCHRONIZATION_GUIDE.md`

**Content must cover:**
- When to update `GAME_API.toml`
- How to update when adding new fields to engine
- How to update when adding new entity types
- How to validate consistency
- Automated tools to check sync (future task)
- Workflow for developers

**Estimated time:** 2 hours

---

### Step 8: Validation and Testing
**Description:** Ensure schema is complete and usable

**Test cases:**
- Parse `GAME_API.toml` with Lua TOML parser - must succeed
- Load existing mod TOML files and check against schema manually
- Verify all fields in current `mods/core/rules/` are covered
- Verify all fields in API docs are covered
- Verify all fields used in engine are covered
- Check for typos and inconsistencies

**Estimated time:** 3-4 hours

---

## Implementation Details

### Architecture

**Schema Format Choice: TOML**
- Readable by humans
- Parseable by Lua (already have TOML parser)
- Supports nested structures
- Supports comments for documentation
- Can represent types as string values

**Schema Structure:**
```
GAME_API.toml
├── [_meta] - schema metadata
├── [_mappings] - cross-references
├── [api.units] - unit definitions
│   └── [api.units.fields] - field definitions
├── [api.items] - item definitions
│   └── [api.items.fields] - field definitions
└── ... (all other entity types)
```

**Type System:**
- `type = "string"` - text value
- `type = "integer"` - whole number
- `type = "float"` - decimal number
- `type = "boolean"` - true/false
- `type = "enum"` - restricted set of values (with `values` array)
- `type = "array"` - list of values (with `element_type`)
- `type = "table"` - nested object/structure
- `type = "reference"` - foreign key to another entity (with `references`)

**Field Attributes:**
- `required` - must be present (true/false)
- `default` - default value if omitted
- `min` / `max` - numeric constraints
- `values` - enum valid values
- `references` - what entity type this refers to
- `description` - human-readable explanation
- `deprecated` - mark old fields (for migration)

### Key Components

- **GAME_API.toml** - main schema file, defines all structures
- **api/GAME_API_GUIDE.md** - documentation on reading schema
- **api/SYNCHRONIZATION_GUIDE.md** - workflow for keeping in sync
- **Audit outputs** - temporary files documenting current state

### Dependencies

- Existing TOML parser in engine (must support reading schema format)
- All current API documentation files
- All current engine loader code
- All current design documentation

---

## Testing Strategy

### Manual Validation
- [ ] Parse GAME_API.toml with Lua - no errors
- [ ] Manually check 10 random entities from mods/core against schema
- [ ] Verify all API docs are represented
- [ ] Check all design mechanics have corresponding API definitions

### Coverage Testing
- [ ] List all entity types in engine code
- [ ] Confirm each has section in GAME_API.toml
- [ ] List all fields accessed in engine
- [ ] Confirm each is defined in GAME_API.toml

### Consistency Testing
- [ ] Compare field names in API docs vs GAME_API.toml
- [ ] Compare types in engine vs GAME_API.toml
- [ ] Check for duplicate definitions
- [ ] Check for conflicting type definitions

---

## Documentation Updates

### Files to Create
- [ ] `GAME_API.toml` - main schema file (root or api/ folder)
- [ ] `api/GAME_API_GUIDE.md` - how to use the schema
- [ ] `api/SYNCHRONIZATION_GUIDE.md` - keep things in sync

### Files to Update
- [ ] `api/README.md` - add reference to GAME_API.toml
- [ ] `api/MODDING_GUIDE.md` - reference schema for mod creators
- [ ] `README.md` - mention schema in main docs
- [ ] `.github/copilot-instructions.md` - add schema to AI instructions

---

## Notes

**Critical Decisions:**
1. Where to place `GAME_API.toml`?
   - Option A: Project root (high visibility)
   - Option B: `api/` folder (logical grouping)
   - **Recommendation:** `api/GAME_API.toml` - keeps API stuff together

2. How detailed should type definitions be?
   - Should we define exact sprite paths format?
   - Should we define coordinate systems?
   - **Recommendation:** Start with high-level, refine iteratively

3. How to handle version evolution?
   - Schema will change as game develops
   - Need versioning strategy
   - **Recommendation:** Use `_meta.version` field, document changes

**Future Enhancements:**
- Automated sync checker (future task)
- LSP/validator tooling (future task)
- Schema migration tools for mod updates
- Visual schema browser/editor

---

## Blockers

**Must have before starting:**
- [ ] Complete access to all API documentation
- [ ] Complete access to engine code
- [ ] Complete access to design docs
- [ ] Working Lua TOML parser to test parsing

**Potential issues:**
- API docs might be incomplete or outdated
- Engine code might use undocumented fields
- Design docs might have mechanics not yet in engine
- TOML parser might not support all needed features

---

## Review Checklist

- [ ] All entity types from API docs are included
- [ ] All entity types from engine are included
- [ ] All entity types from design are included
- [ ] All fields have type definitions
- [ ] All enums have complete value lists
- [ ] All required fields are marked
- [ ] All optional fields have defaults
- [ ] All cross-references are documented
- [ ] TOML syntax is valid
- [ ] File is well-commented
- [ ] Guide documentation is clear
- [ ] Sync workflow is documented

---

## Success Criteria

**Task is DONE when:**
1. `api/GAME_API.toml` exists and is complete
2. File parses without errors
3. 100% of current API documentation is represented
4. 100% of engine-used fields are represented
5. Documentation guides exist and are clear
6. Manual validation of sample mods succeeds
7. Cross-reference mappings are complete
8. Team reviews and approves schema structure

**This enables:**
- Next task: Automated mod validation
- Next task: Mock data generation
- Next task: LSP/tooling creation
- Better consistency across project
- Faster mod development
- Fewer runtime errors from bad data
