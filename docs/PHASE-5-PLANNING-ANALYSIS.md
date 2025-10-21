# Phase 5 Planning Analysis: API Documentation & Mock Data

**Analysis Date**: October 21, 2025  
**Planning Status**: COMPLETE  
**Task Document**: `tasks/TODO/TASK-COMPREHENSIVE-API-DOCUMENTATION.md`

---

## Problem Statement

### Current State
The project has:
- ✅ 19 comprehensive game system documents (wiki/systems/)
- ✅ Engine implementation for all systems (92% alignment)
- ✅ Stable, production-ready code
- ❌ **NO comprehensive API documentation for modders**
- ❌ **NO mock data for testing**
- ❌ **NO example mods showing patterns**

### The Gap
Modders cannot create compatible content because:
1. **Missing Documentation**: No complete reference showing what data entities exist
2. **Hidden Requirements**: No documented schema for TOML files
3. **Unknown Patterns**: No examples of how to structure mod content
4. **Unclear Relationships**: No documentation of how entities connect
5. **Validation Uncertainty**: No documented constraints and rules

### Why This Matters
- **Modding Community**: Cannot contribute without API documentation
- **Content Creation**: No way to know what's configurable
- **Quality Control**: No validation framework for custom content
- **Testing**: No mock data for comprehensive testing
- **Development**: New features need examples and documentation

---

## Scope Analysis

### Entities to Document

Based on analysis of 19 wiki system files, approximately 80-120 distinct moddable entity types across:

#### Strategic Layer (Geoscape)
- World/Nations/Regions/Provinces
- Biomes (terrain types)
- Strategic sites (bases, monuments, objectives)
- UFO types and encounters
- Mission types (strategic layer)
- Faction definitions
- Diplomatic relations

#### Operational Layer (Basescape)
- Base configurations
- Facility definitions (25+ types)
- Grid layout and expansion
- Facility adjacency effects
- Power management
- Storage management
- Personnel recruitment

#### Tactical Layer (Battlescape)
- Mission definitions (tactical)
- Squad compositions
- Enemy placement
- Environmental modifiers
- Victory conditions
- Loot tables

#### Equipment & Items
- Weapons (20+ types)
- Armor (15+ types)
- Components/ammunition
- Equipment loadouts
- Research items

#### Economy & Finance
- Resources (4 types)
- Prices and markets
- Supplier definitions
- Manufacturing recipes
- Research projects
- Budget categories

#### Politics & Relations
- Faction definitions
- Diplomat traits
- Alliance rules
- Reputation systems
- Trade agreements

#### Meta Systems
- Analytics events
- Tutorial sequences
- Narrative events
- Lore entries
- Localization strings

### Data Extraction Points

**API Documentation will extract from:**

1. **Wiki System Files** (19 files)
   - Entity descriptions and mechanics
   - Field explanations
   - Constraints and rules

2. **Engine Code** (engine/ folder)
   - Actual data structures
   - TOML parsing logic
   - Validation rules
   - Type requirements

3. **Example Data** (engine/assets/data/ and mods/core/)
   - Working TOML examples
   - Real values and ranges
   - Common patterns

---

## Reasoning: Why Phase 5 Follows Phase 2

### Phase 2 (Oct 21) - Engine Alignment ✅ COMPLETE
- Fixed critical system gaps
- Aligned engine with wiki documentation
- Achieved 92% overall alignment
- Production code stable

### Phase 3 (Theoretical) - System Integration
- Would implement inter-system connections
- Would validate data flows
- **Not needed yet - Phase 2 already achieved alignment**

### Phase 4 (Theoretical) - UI Implementation
- Would build gameplay interface
- Would implement player-facing features
- **Blocked by Phase 5 output (API docs, mock data)**

### Phase 5 (Now) - API Documentation & Mock Data ⬅️ NEXT
- **Why now?**
  - Phase 2 established stable foundation
  - API docs cannot be written until implementation is correct (now true)
  - Mock data needs complete schema (Phase 5 provides this)
  - Example mods need working engine (Phase 2 provided this)
  
- **What it enables**
  - Modding community can create content
  - Developers have test data
  - New systems can be documented as added
  - Foundation for long-term maintainability

- **Why not before Phase 2?**
  - Engine wasn't aligned with wiki yet
  - Would have documented wrong patterns
  - Would need to be redone after Phase 2
  - Waste of effort

---

## Component Analysis

### 1. API Documentation (Why Essential)

**Without API docs, modders face:**
- Reverse-engineering code to understand schema
- Trial and error with TOML files
- Inconsistent content (no patterns to follow)
- Hidden dependencies discovered through crashes
- No validation until runtime

**With API docs, modders get:**
- Clear schema showing all fields
- Type information and constraints
- Real TOML examples they can copy
- Understanding of relationships
- Validation rules preventing errors

**Impact**: From 0% moddability to 80%+ moddability

### 2. Mock Data Generation (Why Powerful)

**Without mock data:**
- Manual test data creation (tedious)
- Incomplete coverage (some entity types untested)
- Unrealistic values (balance issues)
- Missing relationships (edge cases missed)

**With mock data:**
- 1000+ automatically generated entries
- Complete coverage of all entity types
- Realistic values (from game balance)
- All relationships tested
- Edge cases identified

**Benefits:**
- Comprehensive test coverage
- Baseline for performance testing
- Examples for API documentation
- Quick setup for development/demo
- Content for dummy mod

### 3. Example Mods (Why Necessary)

**Without examples:**
- Modders have no reference
- "How do I create a weapon?"
- "What files go in the mod folder?"
- "How does the mod load?"
- Trial and error approach

**With examples:**
- Complete, working reference implementation
- Clear file structure
- Demonstrated patterns
- Copy-paste starting point
- Best practices shown

**Two levels serve different audiences:**
- **Complete example**: "Show me everything"
- **Minimal example**: "Show me the simplest case"

---

## Entity Relationship Analysis

### Top-Level Relationships

```
World (Strategic Container)
├─ Nations
│  ├─ Regions
│  │  └─ Provinces
│  │     ├─ Bases
│  │     │  ├─ Facilities (25+ types)
│  │     │  ├─ Personnel (Soldiers, Scientists, Engineers)
│  │     │  ├─ Equipment
│  │     │  ├─ Crafts
│  │     │  └─ Projects (Research, Manufacturing)
│  │     ├─ Missions (Strategic - "Investigate anomaly")
│  │     └─ UFOs (Encounters)
│  └─ Factions (Diplomatic relationships)
├─ Biomes (Terrain configurations)
├─ Strategic Sites
└─ Time/Timeline

Battlescape (Tactical Container)
├─ Missions (Tactical - "Defend base from squad")
├─ Squads
│  ├─ Units (Soldiers)
│  │  ├─ Equipment (Weapon, Armor, Items)
│  │  ├─ Skills/Experience
│  │  └─ Status
│  └─ Loadout
├─ Enemy Groups
├─ Environmental Modifiers
└─ Loot Tables (Salvage from victory)

Research & Manufacturing
├─ Research Projects
│  ├─ Prerequisites (other projects)
│  ├─ Required Items (to analyze)
│  ├─ Unlocks (new manufacturing, etc.)
│  └─ Man-Days (effort to complete)
├─ Manufacturing Recipes
│  ├─ Input Materials
│  ├─ Output Items
│  ├─ Facility Requirements
│  └─ Engineer Hours
└─ Tech Tree (dependency graph)

Economy
├─ Resources (4 types: Credits, Supplies, Intel, Exotic)
├─ Suppliers
│  ├─ Prices
│  ├─ Inventory
│  └─ Relations modifier
├─ Marketplace Items
├─ Personnel Costs
├─ Facility Maintenance
└─ Financial Reports
```

### Why Relationships Matter

Every entity is related to others:
- A **Unit** references **Equipment**
- **Equipment** requires **Manufacturing**
- **Manufacturing** needs **Research**
- **Research** uses **Facilities**
- **Facilities** go in **Bases**
- **Bases** are in **Provinces**

Modders need to understand these connections:
- "If I create a new weapon, how does it affect research?"
- "Can I create a new facility type?"
- "What constraints exist?"
- "What fields are required?"

API documentation must show all relationships clearly.

---

## Data Scale Estimation

### Mock Data Breakdown (1000+ entries target)

| Entity Type | Count | Rationale | Examples |
|-------------|-------|-----------|----------|
| Units | 150 | Varied soldier types, experience levels | Rookies, Veterans, Specialists |
| Weapons | 60 | Different damage types, tech levels | Pistol, Rifle, Plasma, Alien tech |
| Armor | 40 | Light, medium, heavy, alien | Combat Suit, Powered Suit, Chitin |
| Items | 75 | Consumables, components, artifacts | Medkit, Ammo, Alien Component |
| Facilities | 50 | Base-building blocks | Barracks, Lab, Hangar, Defense Tower |
| Research | 120 | Tech tree nodes | Basic Training, Plasma Weapons, Autopsy |
| Manufacturing | 85 | Recipes and production lines | Rifle Production, Armor Crafting |
| Crafts | 30 | Aircraft types and variants | Fighter, Transport, Science Vessel |
| Missions (Strategic) | 100 | Mission templates with variations | Terror Attack, UFO Crash, Infiltration |
| Missions (Tactical) | 80 | Squad-level combat scenarios | Defend Position, Clear Building |
| Squads | 40 | Pre-configured team compositions | Strike Team, Reconnaissance Team |
| Loadouts | 80 | Equipment combinations | Light Scout, Heavy Assault, Support |
| Bases | 20 | Base configurations | Small Outpost, Medium Base, Strategic Hub |
| Factions | 15 | Nations and organizations | USA, China, European Union, Alien Races |
| Resources | 8 | Resource types with pricing | Credits, Supplies, Intel, Exotic Materials |
| Biomes | 10 | Terrain types with properties | Desert, Forest, Arctic, Urban, Ocean |
| **TOTAL** | **~1,000** | **Complete coverage** | **All entity types** |

### Why This Scale?

1. **Coverage**: Every entity type represented
2. **Variety**: Multiple examples of each type
3. **Relationships**: Cross-entity references testable
4. **Edge Cases**: Boundary conditions discoverable
5. **Performance**: Large dataset tests scalability
6. **Documentation**: Real examples for API docs

---

## Documentation Format Pattern

Every API entity will follow:

```markdown
## Entity: [Name]

### Purpose
[What is this entity? Why does it exist?]

### Schema
```toml
[entity_type]
id = "string (unique identifier)"
name = "string (human-readable name)"
# ... all fields ...
```

### Fields
[Table with Type, Required, Default, Constraints, Example for each field]

### Relationships
[Which entities reference this? Which entities does it reference?]

### Validation Rules
[All constraints and checks applied to instances of this entity]

### TOML Example
[Working, real example that can be directly used]

### Modding Notes
[Tips and best practices for modders creating this entity type]
```

### Why This Format?

1. **Comprehensive**: Schema + examples + rules
2. **Reference-friendly**: Modders can quickly find what they need
3. **Type-safe**: Clear types prevent errors
4. **Searchable**: Each entity documented identically
5. **Linked**: Cross-references help navigation
6. **Practical**: Real examples they can use

---

## TOML Format Considerations

### Why TOML?

**Chosen format for all mod data:**

✅ **Advantages:**
- Human-readable (better than JSON/Lua for modders)
- Comments supported (document within files)
- Type-safe (strings, numbers, arrays, tables)
- Version control friendly (clear diffs)
- Industry standard (familiar to many developers)
- Easy to parse (many libraries available)

❌ **Alternatives considered:**
- **JSON**: Valid but less human-friendly
- **Lua**: Valid but harder to sandbox/validate
- **XML**: Too verbose for game data
- **YAML**: Too complex for this use case

### TOML Structure Pattern

```toml
# Mod data follows organizational pattern:

[entity_type.entity_1]
id = "unique_id"
name = "Display Name"
# ... fields ...

[entity_type.entity_2]
id = "unique_id_2"
name = "Another Name"
# ... fields ...

# References between entities:
loadout_weapon = "weapon_1"  # Points to another entity
facility_requirements = ["research_1", "research_2"]  # Array of references
```

### Validation Before Parsing

Mock data generation will validate:
1. All required fields present
2. All types correct
3. All referenced entities exist
4. All values within constraints
5. Relationships consistent

---

## Integration Points

### Step 1: Analysis Phase Output
Feeds into Steps 2-3:
- Entity list (what to document)
- Relationships (how to link them)
- Initialization order (constraints)
- Dependencies (when loaded)

### Step 2: Engine Code Analysis Output
Feeds into Step 3:
- TOML parsing patterns (how to validate)
- Example data structures (real working examples)
- Type information (what types are used)
- Validation logic (what rules apply)

### Step 3: API Documentation Output
Feeds into Steps 4-5:
- Entity schemas (what to generate)
- Relationships (how to link data)
- Validation rules (constraints for generator)
- TOML examples (proof of correctness)

### Step 4: Mock Data Generation Output
Feeds into Steps 5-7:
- Test data (example mod content)
- Real examples (for API docs if needed)
- Validation results (proof of system)
- Dataset for testing

### Step 5: Example Mods Output
Feeds into Step 6:
- Working mod structure (pattern for others)
- Real TOML files (demonstrate format)
- Init.lua patterns (how to load)
- Documentation patterns (how to explain)

### Steps 6-8: Integration, Validation, Polish
Final deliverables:
- Complete, cross-referenced documentation
- Verified completeness (all systems covered)
- All links working
- Final polished state

---

## Success Criteria

### Functionality
- [ ] All 19 systems have API documentation
- [ ] All 80-120 entity types documented
- [ ] 50+ working TOML examples provided
- [ ] Zero gaps between systems and API

### Quality
- [ ] 1000+ mock data entries generated and validated
- [ ] All TOML examples parse correctly
- [ ] All mock data passes constraints
- [ ] All relationships validated

### Usability
- [ ] Example mods load without errors in game
- [ ] Modders can create content using only API docs
- [ ] Documentation is beginner-friendly
- [ ] All cross-references work

### Coverage
- [ ] Generator covers all entity types
- [ ] Mock data uses realistic values
- [ ] Edge cases represented
- [ ] Boundary conditions tested

---

## Risks & Mitigations

### Risk 1: Entity Relationships Incomplete
- **Risk**: Miss some relationships, create incorrect documentation
- **Mitigation**: Phase 2 code analysis will find all relationships
- **Prevention**: Validation phase will catch gaps

### Risk 2: TOML Examples Invalid
- **Risk**: Examples don't parse or are incorrect
- **Mitigation**: Parse all examples before documenting
- **Prevention**: Test mock data generation

### Risk 3: Scope Creep
- **Risk**: Keep adding details, lose schedule
- **Mitigation**: Fixed scope: 19 systems, 80-120 entities, 1000 mock data
- **Prevention**: Use checklist to track completion

### Risk 4: Documentation Becomes Outdated
- **Risk**: Engine changes break docs
- **Mitigation**: Documentation tied to stable Phase 2 code
- **Prevention**: Version together going forward

---

## Long-Term Value

### Immediate (Phase 5)
- Enables modding community
- Provides test infrastructure
- Documents all entities

### Short-Term (Months 1-3)
- Community begins creating mods
- Bug fixes identified through modding
- API refined based on usage

### Long-Term (6+ months)
- Rich mod ecosystem
- Community content extends gameplay
- Game lives longer through community contributions
- Foundation for DLC or expansions

---

## Comparison: With vs Without Phase 5

### Without Phase 5
- ❌ No modding community can form
- ❌ No test data available
- ❌ New developers have hard time learning
- ❌ API changes are dangerous (no reference)
- ❌ Content creation requires reverse-engineering

### With Phase 5
- ✅ Clear modding path for community
- ✅ Comprehensive test data available
- ✅ New developers can learn from examples
- ✅ API changes are documented changes
- ✅ Content creation is straightforward

---

## Conclusion

**Phase 5 is critical infrastructure that enables the next phase of AlienFall development.** 

While Phase 2 established technical correctness (code matches design), Phase 5 establishes:

1. **Discoverability** - What entities exist? Where are they documented?
2. **Usability** - How do I create custom content?
3. **Quality** - How do I ensure my content is correct?
4. **Sustainability** - How do I maintain this long-term?

Without Phase 5, the game is technically complete but locked to in-house development. With Phase 5, the game becomes a platform for community contributions.

The 44-51 hour investment in Phase 5 enables orders-of-magnitude value through community extensions.

