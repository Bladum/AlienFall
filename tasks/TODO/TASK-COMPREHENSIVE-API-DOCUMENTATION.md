# Task: Comprehensive API Documentation & Mock Data Generation

**Status:** TODO  
**Priority:** High  
**Created:** October 21, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

This task encompasses a complete API documentation overhaul followed by massive mock data generation for all moddable entities in AlienFall. The work extracts every data entity from 19 game systems that modders need to know about, creates comprehensive API documentation with TOML examples, and generates exhaustive mock data suitable for testing and dummy mod content creation.

**Scope**: All game systems (Geoscape, Basescape, Battlescape, Economy, Finance, Units, Crafts, Politics, Interception, Items, etc.)

---

## Purpose

Why is this task necessary?

1. **Modding Foundation**: Mods need clear API documentation for every entity that can be customized. Without it, modders cannot create compatible content.
2. **Data-Driven Design**: The game is data-driven; every configurable element should be documented with structure, types, and examples.
3. **Testing Infrastructure**: Mock data ensures comprehensive testing coverage and validates all API functionality.
4. **Quality Assurance**: TOML examples provide concrete patterns for modders to follow and ensure consistency.
5. **Development Velocity**: Documented API reduces friction when adding new systems or extending existing ones.

---

## Requirements

### Functional Requirements

- [ ] Extract all moddable entities from wiki/systems/ documentation (19 systems total)
- [ ] Create comprehensive API documentation for each entity type
- [ ] Document all properties, types, constraints, and relationships for each entity
- [ ] Provide TOML format examples for every entity (extracted from engine code where available)
- [ ] Generate mock data covering 100% of documented API surface
- [ ] Create example mod data structures demonstrating API usage
- [ ] Establish clear patterns for entity relationships and data organization
- [ ] Document mod loading sequences and entity initialization order

### Technical Requirements

- [ ] All API documentation follows consistent format (schema, types, examples)
- [ ] TOML examples match engine parsing expectations
- [ ] Mock data uses realistic values aligned with game balance
- [ ] Mock data generation scripts are modular and reusable
- [ ] Mock data covers edge cases and boundary conditions
- [ ] Example mods demonstrate all major API patterns
- [ ] Documentation cross-references between related entities
- [ ] API docs integrate with wiki/api/ directory structure

### Acceptance Criteria

- [ ] Every moddable data entity has documented schema in `wiki/api/`
- [ ] 50+ TOML examples provided across all entity types
- [ ] Mock data set contains 1000+ entries covering all entity types
- [ ] Example mod structure demonstrates complete mod workflow
- [ ] All API documentation references back to system docs
- [ ] Zero gaps between wiki/systems/ documentation and API docs
- [ ] Modders can create new content using only the API documentation
- [ ] No undocumented required fields or hidden dependencies

---

## Plan

### Step 1: Analysis & Entity Extraction (4-6 hours)

**Description**: Map all moddable entities from 19 wiki system documents

**Deliverables**:
- Complete list of 80-120 distinct entity types
- Entity relationship diagram
- Classification by system and layer (strategic/operational/tactical/meta)
- Identification of entity dependencies and initialization order

**Files to create**:
- `docs/PHASE-4-API-EXTRACTION-MAPPING.md` (mapping document)

**Approach**:
1. Read all 19 system wiki files systematically
2. Extract every data structure mentioned (Units, Buildings, Crafts, Weapons, Armor, Research, etc.)
3. Identify relationships between entities (e.g., Units contain Equipment, Bases contain Facilities)
4. Map TOML format requirements for each entity type
5. Document required vs optional fields
6. Create entity dependency graph
7. Identify initialization order constraints

**Key entities to map**:
- **Geoscape**: World, Countries, Regions, Provinces, Biomes, Missions, UFOs, Strategic Sites
- **Basescape**: Bases, Facilities, Grid Layout, Base Maintenance
- **Units**: Soldiers, Squad Configurations, Experience Tracks, Unit Progression
- **Economy**: Resources, Prices, Suppliers, Marketplace Items, Research Projects, Manufacturing
- **Finance**: Personnel Costs, Facility Maintenance, Budget Categories, Revenue Streams
- **Equipment**: Weapons, Armor, Items, Components, Loadouts
- **Crafts**: Aircraft Specifications, Loadouts, Crews
- **Battlescape**: Missions (Tactical), Mission Types, Enemy Squads, Environmental Modifiers
- **Politics**: Factions, Diplomatic Relations, Alliance Systems
- **Interception**: Interception Mechanics, Craft Combat, Base Defense

**Estimated time:** 5 hours

---

### Step 2: Engine Code Extraction (6-8 hours)

**Description**: Extract existing data structures and TOML parsing from engine code

**Deliverables**:
- Complete TOML file structure from all data loading modules
- Actual data examples from engine assets/
- Parsing logic documentation
- Validation rules and constraints

**Files to analyze**:
- `engine/assets/data/` (all Lua data files)
- `engine/core/data_loader.lua` (parsing logic)
- `engine/basescape/data/` (Basescape entities)
- `engine/battlescape/data/` (Battlescape entities)
- `engine/geoscape/data/` (Geoscape entities)
- `engine/*/data/` (all system-specific data)
- `engine/mods/mod_manager.lua` (mod loading)
- `engine/mods/mod_loader.lua` (mod parsing)

**Approach**:
1. Identify all data_loader or similar modules
2. Extract TOML parsing logic and expected structures
3. Find example data in engine assets
4. Document validation and constraint logic
5. Map type requirements for each field
6. Identify optional vs required fields
7. Extract error handling patterns

**Estimated time:** 7 hours

---

### Step 3: Comprehensive API Documentation (8-10 hours)

**Description**: Create wiki/api/ documentation for all entities with consistent schema

**Deliverables**:
- `wiki/api/ENTITIES.md` - Master entity reference
- `wiki/api/ENTITIES_GEOSCAPE.md` - Strategic layer entities
- `wiki/api/ENTITIES_BASESCAPE.md` - Operational layer entities
- `wiki/api/ENTITIES_BATTLESCAPE.md` - Tactical layer entities
- `wiki/api/ENTITIES_EQUIPMENT.md` - Equipment entities
- `wiki/api/ENTITIES_ECONOMY.md` - Economy entities
- `wiki/api/TOML_SPECIFICATION.md` - TOML format guide (updated)
- `wiki/api/ENTITY_RELATIONSHIPS.md` - Entity graph and dependencies
- `wiki/api/VALIDATION_RULES.md` - Constraints and validation
- `wiki/api/MOD_LOADING_SEQUENCE.md` - Initialization order

**Documentation format for each entity**:

```markdown
## Entity: [Name]

### Purpose
[What is this entity for?]

### Schema
```toml
[entity_type]
id = "string (required, unique)"
name = "string (required)"
description = "string (optional)"
# ... all fields with types and constraints
```

### Fields

| Field | Type | Required | Default | Constraints | Example |
|-------|------|----------|---------|-------------|---------|
| id | string | Yes | N/A | Must be unique | "laser_rifle_mk1" |

### Relationships
[Which entities reference this? Which entities does this reference?]

### Constraints
- Constraint 1
- Constraint 2

### Validation Rules
- Rule 1 (code example if needed)
- Rule 2

### TOML Example
```toml
[complete working example]
```

### Modding Notes
[Tips for modders creating this entity]
```

**Files to create/update**:
- Create 6-8 new entity documentation files
- Update `wiki/api/README.md` with index
- Update `wiki/api/CORE.md` if necessary
- Create `wiki/api/GLOSSARY.md` for common patterns

**Approach**:
1. Create master entity list from Step 1 analysis
2. For each entity type, extract complete schema
3. Document every field with type and constraints
4. Provide real TOML examples from engine
5. Create validation rule documentation
6. Map relationships between all entities
7. Document initialization order/dependencies
8. Cross-reference back to system wiki pages

**Estimated time:** 9 hours

---

### Step 4: Mock Data Generation Scripts (6-8 hours)

**Description**: Create modular mock data generation framework

**Deliverables**:
- `tests/mock/GENERATION_GUIDE.md` - How to generate mock data
- `tests/mock/generator_base.lua` - Base generator framework
- `tests/mock/generator_geoscape.lua` - Strategic layer mock data
- `tests/mock/generator_basescape.lua` - Operational layer mock data
- `tests/mock/generator_battlescape.lua` - Tactical layer mock data
- `tests/mock/generator_equipment.lua` - Equipment mock data
- `tests/mock/generator_economy.lua` - Economy mock data
- `tests/mock/generators/` - Modular generators for each entity type
- `tests/mock/generated_data.lua` - Master mock data file (1000+ entries)

**Framework Design**:

```lua
-- Generator pattern
local Generator = {}

function Generator:new()
    local self = setmetatable({}, self)
    self.data = {}
    self.ids = {}
    return self
end

function Generator:generateEntity(type, count, options)
    -- Generate 'count' random entities of 'type'
    -- Return Lua table ready for TOML export
end

function Generator:toTOML(filename)
    -- Convert generated data to TOML format
    -- Write to file or return string
end

function Generator:validate()
    -- Verify all generated data meets constraints
end
```

**Mock data coverage**:
- 100-200 units/soldiers
- 50-75 weapons and armor
- 100-150 research projects
- 50-75 manufacturing items
- 30-50 base facilities
- 20-30 crafts/aircraft
- 50-75 items/components
- 100-150 missions
- 100-150 equipment loadouts
- All other entity types

**Approach**:
1. Create base generator framework
2. Build modular generators for each entity type
3. Implement realistic value ranges (from game balance docs)
4. Add relationship generation (Unit→Equipment, Base→Facilities, etc.)
5. Create validation framework
6. Generate full mock dataset
7. Export to TOML format
8. Create usage guide

**Estimated time:** 7 hours

---

### Step 5: Example Mod Creation (4-6 hours)

**Description**: Create complete example mod demonstrating all API patterns

**Deliverables**:
- `mods/examples/COMPLETE_MOD_EXAMPLE/` - Full working example mod
  - `init.lua` - Mod entry point
  - `data/units.toml` - Custom unit definitions
  - `data/weapons.toml` - Custom weapons
  - `data/armor.toml` - Custom armor
  - `data/facilities.toml` - Custom facilities
  - `data/research.toml` - Custom research
  - `data/crafts.toml` - Custom crafts
  - `data/missions.toml` - Custom missions
  - `README.md` - Mod documentation
- `mods/examples/MINIMAL_MOD_EXAMPLE/` - Minimal example (single entity type)
- `wiki/examples/MOD_CREATION_TUTORIAL.md` - Step-by-step mod creation guide
- `wiki/examples/MOD_API_PATTERNS.md` - Common patterns and best practices

**Example mod content**:
- 10-15 new unit types
- 5-10 new weapons
- 3-5 new armor sets
- 2-3 new base facilities
- 3-5 research projects
- 2-3 new craft types
- Custom mission types

**Approach**:
1. Design coherent example mod theme (e.g., "Alien Tech" mod)
2. Create all required TOML files with complete data
3. Implement mod initialization
4. Add cross-references between entities
5. Document all patterns used
6. Create minimal example for simplicity
7. Write comprehensive tutorial
8. Document best practices and anti-patterns

**Estimated time:** 5 hours

---

### Step 6: Integration & Cross-Referencing (3-4 hours)

**Description**: Integrate API docs with system docs, create navigation

**Deliverables**:
- Updated `wiki/api/README.md` with comprehensive index
- Updated `wiki/systems/README.md` with API cross-references
- `wiki/MODDING_COMPLETE_REFERENCE.md` - Master modding guide
- Navigation links in all API and system docs
- Integration testing verification

**Approach**:
1. Add cross-references from system docs to API docs
2. Update API README with entity index
3. Create master modding reference guide
4. Add "Related API" sections to system docs
5. Update example pages with links
6. Verify all links work (internal consistency check)
7. Create reference checklist for navigation

**Estimated time:** 3.5 hours

---

### Step 7: Validation & Testing (4-5 hours)

**Description**: Verify API completeness and mock data validity

**Deliverables**:
- `docs/PHASE-4-API-VALIDATION-REPORT.md` - Completeness report
- Test results for mock data
- Schema validation for all TOML examples
- Coverage report (API vs. systems)

**Validation checks**:
- [ ] All 19 systems have corresponding API documentation
- [ ] All entity types have documented schema
- [ ] All TOML examples parse correctly
- [ ] All mock data passes validation rules
- [ ] No required fields missing from examples
- [ ] All entity relationships documented
- [ ] Cross-references are bidirectional
- [ ] Example mods load without errors
- [ ] API documentation matches actual engine code
- [ ] Modders could create content using only API docs

**Approach**:
1. Create validation script checking entity coverage
2. Parse all TOML examples (syntax validation)
3. Run mock data through engine validators
4. Verify example mods load correctly
5. Create coverage matrix (systems vs. API docs)
6. Identify any gaps and document them
7. Generate completeness report

**Estimated time:** 4.5 hours

---

### Step 8: Documentation & Final Polish (3-4 hours)

**Description**: Update all relevant wiki files and create summary

**Deliverables**:
- Updated `wiki/API.md` (if exists) or reference to new API docs
- Updated `wiki/DEVELOPMENT.md` with API documentation reference
- `docs/PHASE-4-COMPLETION-SUMMARY.md` - Final summary report
- Updated `wiki/README.md` with new API doc references

**Approach**:
1. Update main wiki files to reference new API documentation
2. Add API documentation to DEVELOPMENT workflow
3. Create completion summary with statistics
4. Update project navigation
5. Ensure all docs follow standard format
6. Final proofreading and consistency check

**Estimated time:** 3.5 hours

---

## Implementation Details

### Architecture

**Three-phase approach**:

1. **Analysis Phase** (Steps 1-2)
   - Extract all moddable entities from documentation
   - Analyze engine code for actual implementations
   - Identify patterns and relationships

2. **Documentation Phase** (Steps 3-6)
   - Create comprehensive API documentation
   - Build example mods
   - Integrate with existing wiki
   - Create navigation and cross-references

3. **Validation Phase** (Steps 7-8)
   - Test all documentation completeness
   - Verify mock data validity
   - Generate reports
   - Polish and finalize

**Entity Organization**:
```
wiki/api/
├── README.md (index and navigation)
├── CORE.md (core engine entities)
├── ARCHITECTURE.md (architectural patterns)
├── ENTITIES.md (master entity reference)
├── ENTITIES_GEOSCAPE.md (strategic layer)
├── ENTITIES_BASESCAPE.md (operational layer)
├── ENTITIES_BATTLESCAPE.md (tactical layer)
├── ENTITIES_EQUIPMENT.md (equipment entities)
├── ENTITIES_ECONOMY.md (economy entities)
├── ENTITIES_META.md (meta systems)
├── TOML_SPECIFICATION.md (TOML format guide)
├── ENTITY_RELATIONSHIPS.md (entity dependency graph)
├── VALIDATION_RULES.md (constraints and rules)
└── MOD_LOADING_SEQUENCE.md (initialization order)

mods/examples/
├── COMPLETE_MOD_EXAMPLE/ (full example with all entity types)
├── MINIMAL_MOD_EXAMPLE/ (simple single-type example)
└── README.md (example mod index)

tests/mock/
├── GENERATION_GUIDE.md (how to generate mock data)
├── generator_base.lua (base framework)
├── generator_geoscape.lua (strategic layer)
├── generator_basescape.lua (operational layer)
├── generator_battlescape.lua (tactical layer)
├── generator_equipment.lua (equipment)
├── generator_economy.lua (economy)
├── generators/ (modular generators)
└── generated_data.lua (complete mock dataset)
```

### Key Components

- **API Documentation**: Schema + type reference + TOML examples for every entity
- **Mock Data Generator**: Reusable framework for creating test data
- **Example Mods**: Complete, working mod examples showing all patterns
- **Validation Framework**: Ensures all data meets constraints
- **Navigation System**: Cross-references between docs

### Dependencies

- `wiki/systems/` - Source documentation (19 files)
- `engine/assets/data/` - Engine data examples
- `engine/core/data_loader.lua` - Parsing logic
- `engine/mods/` - Mod system implementation
- Existing mock data in `tests/mock/` - Reference patterns

---

## Testing Strategy

### Unit Tests

- API schema validation (each entity type)
- Mock data generation correctness
- TOML parsing/export
- Entity relationship validation
- Constraint enforcement

### Integration Tests

- Example mod loading without errors
- Mock data compatibility with engine
- Cross-entity relationship integrity
- Documentation completeness verification

### Manual Testing Steps

1. **API Documentation Review**
   - Read each entity doc and verify completeness
   - Check TOML examples for correctness
   - Verify type constraints are documented

2. **Mock Data Validation**
   - Generate mock data via generator framework
   - Verify all entities pass validation
   - Check relationships between entities
   - Validate against engine constraints

3. **Example Mod Testing**
   - Load both example mods in game
   - Verify all custom entities appear correctly
   - Test entity interactions
   - Verify no console errors

4. **Documentation Completeness**
   - Verify every system has API docs
   - Check all entity types are documented
   - Verify cross-references work
   - Test that modders could create content using only API docs

### Expected Results

- API documentation covers 100% of moddable entities
- Mock data generation produces valid, realistic data
- Example mods load and function correctly
- No gaps between system docs and API docs
- Modders have all information needed to create content

---

## How to Run/Debug

### Running the Game

```bash
lovec "engine"
```

Or use VS Code task: "Run XCOM Simple Game"

### Debugging

**API Documentation Development**:
- Use VS Code Markdown preview for doc review
- Validate TOML syntax manually or via parser
- Cross-reference with engine code during writing

**Mock Data Generation**:
- Print generated data structures: `print(require("mock.generated_data"))`
- Validate mock data in console during game startup
- Check for validation errors in Love2D console

**Example Mod Testing**:
- Load mod through game UI
- Check Love2D console for mod loading messages
- Verify custom entities appear in game

### Temporary Files

- All generation output stored in proper locations (not TEMP)
- Mock data stored in `tests/mock/generated_data.lua`
- Example mods stored in `mods/examples/`

---

## Documentation Updates

### Files to Create
- [ ] `wiki/api/ENTITIES.md`
- [ ] `wiki/api/ENTITIES_GEOSCAPE.md`
- [ ] `wiki/api/ENTITIES_BASESCAPE.md`
- [ ] `wiki/api/ENTITIES_BATTLESCAPE.md`
- [ ] `wiki/api/ENTITIES_EQUIPMENT.md`
- [ ] `wiki/api/ENTITIES_ECONOMY.md`
- [ ] `wiki/api/ENTITY_RELATIONSHIPS.md`
- [ ] `wiki/api/VALIDATION_RULES.md`
- [ ] `wiki/api/MOD_LOADING_SEQUENCE.md`
- [ ] `wiki/examples/MOD_CREATION_TUTORIAL.md`
- [ ] `wiki/examples/MOD_API_PATTERNS.md`
- [ ] `mods/examples/COMPLETE_MOD_EXAMPLE/init.lua`
- [ ] `mods/examples/COMPLETE_MOD_EXAMPLE/README.md`
- [ ] `mods/examples/COMPLETE_MOD_EXAMPLE/data/*.toml`
- [ ] `tests/mock/GENERATION_GUIDE.md`
- [ ] `tests/mock/generator_base.lua`
- [ ] `tests/mock/generators/*.lua` (modular generators)
- [ ] `docs/PHASE-4-API-EXTRACTION-MAPPING.md`
- [ ] `docs/PHASE-4-COMPLETION-SUMMARY.md`

### Files to Update
- [ ] `wiki/api/README.md` - Add comprehensive index
- [ ] `wiki/systems/README.md` - Add API cross-references
- [ ] `wiki/API.md` (if exists) - Reference new docs
- [ ] `wiki/DEVELOPMENT.md` - Add API docs to workflow
- [ ] `mods/README.md` - Link to example mods
- [ ] `tests/mock/README.md` - Add generator documentation
- [ ] Main `wiki/README.md` - Update navigation

---

## Notes

### Key Decisions

1. **TOML Format**: Using TOML for mod data (human-readable, easy to parse, example-friendly)
2. **Mock Data Scale**: 1000+ entries ensure comprehensive testing coverage
3. **Example Mods**: Two levels of examples (complete + minimal) for different learning styles
4. **Centralized Documentation**: All API docs in `wiki/api/` for easy discovery
5. **Generator Framework**: Reusable pattern for future mock data generation

### Considerations

- **Modding Audience**: Documentation must be beginner-friendly for new modders
- **Consistency**: All API docs follow identical schema and format
- **Maintenance**: Mock data and examples should be easy to regenerate when game changes
- **Future-Proof**: Generator framework should support new entity types without modification
- **Cross-References**: Bidirectional links between system docs and API docs

### Phase Integration

This work builds on completed Phase 2 (Engine Alignment Fixes) by providing the modding infrastructure needed for long-term extensibility. It enables the mod ecosystem and ensures quality control over custom content.

---

## Blockers

None identified. All source documentation exists. Engine code is available for analysis.

---

## Review Checklist

- [ ] All 19 systems have corresponding API documentation
- [ ] Every entity type has documented schema with all fields
- [ ] All TOML examples are valid and match engine expectations
- [ ] Mock data set is comprehensive (1000+ entries across all types)
- [ ] Example mods demonstrate all major API patterns
- [ ] Generator framework is modular and reusable
- [ ] All documentation follows consistent format and style
- [ ] Cross-references between docs are complete and bidirectional
- [ ] No required fields missing from documentation
- [ ] Validation rules clearly specify constraints
- [ ] Documentation is beginner-friendly for new modders
- [ ] No circular dependencies in entity relationships
- [ ] All files follow Lua naming conventions (snake_case)
- [ ] Code examples follow project best practices
- [ ] Generator performance is acceptable (completes in <10s)
- [ ] Example mods load without console errors
- [ ] All documentation links work and are up-to-date

---

## Post-Completion

### What Worked Well
- [To be filled after completion]

### What Could Be Improved
- [To be filled after completion]

### Lessons Learned
- [To be filled after completion]

---

## Estimated Timeline

**Total Duration**: 38-51 hours

| Phase | Hours | Milestones |
|-------|-------|-----------|
| Step 1: Analysis | 5 | Entity mapping complete |
| Step 2: Code Extraction | 7 | TOML patterns documented |
| Step 3: API Documentation | 9 | All entities documented |
| Step 4: Mock Data | 7 | 1000+ entries generated |
| Step 5: Example Mods | 5 | Complete + minimal examples |
| Step 6: Integration | 3.5 | Cross-references complete |
| Step 7: Validation | 4.5 | Coverage verified |
| Step 8: Polish | 3.5 | Final documentation updates |
| **Total** | **44-51** | **Project complete** |

**Execution Options**:
- **Sequential**: 6-7 weeks (1 hour/day)
- **Focused**: 2-3 weeks (5-7 hours/day)
- **Intensive**: 1 week (6-7 hours/day)

