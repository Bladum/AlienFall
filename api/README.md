# API Documentation

**Purpose:** Authoritative reference for all game systems, data structures, and integration points  
**Audience:** Developers, mod creators, system designers, AI agents  
**Status:** Active development - see individual files for completion status  
**Last Updated:** 2025-10-27

---

## 📋 Quick Navigation

- [How to Use This Documentation](#how-to-use-this-documentation)
- [System Documentation Index](#system-documentation)
- [Best Practices](#best-practices)
- [Integration Guides](#integrations-with-other-systems)
- [Contributing](#contributing)

---

## Goal / Purpose

The API folder contains comprehensive documentation of game systems, entities, and interfaces. It serves as the authoritative reference for understanding how different game systems work, what data structures they use, and how other systems can integrate with them.

**Key Functions:**
- **System Contracts** - Define interfaces between systems
- **Data Models** - Document entity structures and properties
- **TOML Schemas** - Specify mod configuration formats
- **Integration Points** - Show how systems connect
- **Usage Examples** - Provide working code samples

---

## How to Use This Documentation

### For Developers

1. **Understanding a System:** Read the Overview section of the relevant API file
2. **Implementing Features:** Check Core Entities and Functions sections
3. **Integration:** Review Integration Points to see dependencies
4. **Examples:** Copy and adapt Usage Examples for your needs

### For Mod Creators

1. **Start with:** [MODDING_GUIDE.md](MODDING_GUIDE.md)
2. **Schema Reference:** [GAME_API.toml](GAME_API.toml) for complete TOML format
3. **Examples:** Each API file has TOML configuration examples
4. **Testing:** Use examples from `mods/core/rules/` as templates

### For System Designers

1. **Design First:** Document in `design/mechanics/` before implementing
2. **API Second:** Create API documentation defining the system contract
3. **Implementation:** Build in `engine/` following the API spec
4. **Validation:** Write tests to verify API compliance

### For AI Agents

1. **Quick Context:** Read Overview and Implementation Status sections
2. **Data Structures:** Use Core Entities as source of truth
3. **Integration:** Check Integration Points before modifying systems
4. **Alignment:** Verify changes against both API and `design/mechanics/`

---

## Content

### Master Schema & Guides (NEW!)

**Foundation for all API documentation:**

- **GAME_API.toml** - ⭐ Master API schema definition file
  - Single source of truth for ALL mod TOML configurations
  - Defines every entity type, field, type constraint, and validation rule
  - Used by validators, tools, and IDE plugins
  - See [GAME_API_GUIDE.md](GAME_API_GUIDE.md) for usage

- **GAME_API_GUIDE.md** - Complete guide to using the schema
  - How to read field definitions
  - Type reference and constraints
  - Enum values and cross-references
  - Examples for each entity type
  - Troubleshooting common errors

- **SYNCHRONIZATION_GUIDE.md** - Keep engine, schema, and docs in sync
  - Process for updating API when code changes
  - Synchronization checklist
  - Version management and deprecation
  - Tools and validation
  - Automation opportunities

### System Documentation

API documentation files organized by game layer and system type:

#### 🎯 Core Systems & Guides

- **[GAME_API.toml](GAME_API.toml)** - ⭐ Master TOML schema definition (single source of truth)
- **[GAME_API_GUIDE.md](GAME_API_GUIDE.md)** - Complete guide to using the TOML schema
- **[SYNCHRONIZATION_GUIDE.md](SYNCHRONIZATION_GUIDE.md)** ✅ - Keep engine and docs in sync
- **[NAMING_CONVENTIONS.md](NAMING_CONVENTIONS.md)** - ✅ Standard naming patterns for methods and properties
- **[MODDING_GUIDE.md](MODDING_GUIDE.md)** ✅ - Complete modding reference
- **[INTEGRATION.md](INTEGRATION.md)** - System integration patterns

#### 🌍 Strategic Layer (Geoscape)

- **[GEOSCAPE.md](GEOSCAPE.md)** ✅ - World map, hexagonal grid, provinces, calendar, time progression
- **[COUNTRIES.md](COUNTRIES.md)** ✅ - Country entities, diplomatic relations, funding, panic mechanics
- **[CRAFTS.md](CRAFTS.md)** ⚠️ - Spacecraft, movement, fuel, equipment, crew capacity
- **[PILOTS.md](PILOTS.md)** 🚧 - Aircraft crew, interception specialists, progression
- **[INTERCEPTION.md](INTERCEPTION.md)** 🚧 - Air combat mechanics, UFO engagement
- **[MISSIONS.md](MISSIONS.md)** ⚠️ - Mission generation, objectives, deployment

#### 🏭 Operational Layer (Basescape)

- **[BASESCAPE.md](BASESCAPE.md)** ⚠️ - Base management, grid system, infrastructure
- **[FACILITIES.md](FACILITIES.md)** ✅ - Facility types, adjacency bonuses, power grid, personnel efficiency
- **[RESEARCH_AND_MANUFACTURING.md](RESEARCH_AND_MANUFACTURING.md)** ✅ - Tech trees, production queues
- **[ECONOMY.md](ECONOMY.md)** ✅ - Economic management, trading, marketplace
- **[FINANCE.md](FINANCE.md)** ✅ - Financial tracking, budgets, income/expense

#### ⚔️ Tactical Layer (Battlescape)

- **[BATTLESCAPE.md](BATTLESCAPE.md)** ✅ - Tactical combat, hex grid, turn management, 10 entities documented
- **[UNITS.md](UNITS.md)** ⚠️ - Unit entities, stats, progression, classes
- **[PERKS.md](PERKS.md)** ✅ - Unit perks, boolean traits, capabilities
- **[ITEMS.md](ITEMS.md)** ✅ - Equipment system, inventory, item stacks
- **[WEAPONS_AND_ARMOR.md](WEAPONS_AND_ARMOR.md)** ✅ - Combat equipment, damage types, stats
- **[AI_SYSTEMS.md](AI_SYSTEMS.md)** 🚧 - AI behaviors, tactical decisions

#### 🎮 Cross-Layer Systems

- **[GUI.md](GUI.md)** 🚧 - UI framework, widgets, scene management
- **[RENDERING.md](RENDERING.md)** 🚧 - Graphics, sprites, visual effects
- **[ASSETS.md](ASSETS.md)** 🚧 - Asset loading, resource management
- **[ANALYTICS.md](ANALYTICS.md)** 🚧 - Telemetry, metrics, tracking
- **[POLITICS.md](POLITICS.md)** 🚧 - Political systems, factions
- **[LORE.md](LORE.md)** 🚧 - Story content, narrative

#### 🧪 Testing & Quality

- **[TESTING_FRAMEWORK.md](TESTING_FRAMEWORK.md)** ✅ - Test infrastructure, hierarchical organization
- **[UI_TESTING_FRAMEWORK.md](UI_TESTING_FRAMEWORK.md)** ✅ - UI testing with YAML definitions
- **[QA_SYSTEM.md](QA_SYSTEM.md)** ✅ - Code quality assurance, analysis tools

#### 📖 Campaign & Content

- **[CAMPAIGN.md](CAMPAIGN.md)** ✅ - Campaign structure, phase progression, threat management

**Status Legend:**
- ✅ Complete and verified
- ⚠️ Mostly complete, needs updates
- 🚧 In progress or incomplete

---

## System Relationships

### Integration Matrix

| System | Primary Dependencies | Integration Complexity |
|--------|---------------------|----------------------|
| **Geoscape** | Countries, Crafts, Missions, Calendar | High |
| **Countries** | Geoscape, Politics, Economy | Medium |
| **Battlescape** | Units, Items, AI, Map | High |
| **Units** | Battlescape, Items, Progression | Medium |
| **Research** | Facilities, Economy, Tech Tree | Medium |
| **Economy** | Countries, Trading, Finance | Medium |
| **Crafts** | Geoscape, Pilots, Interception | Medium |
| **Facilities** | Basescape, Economy, Research | Low |

### Data Flow Overview

```
Strategic Layer (Geoscape)
    ↓
  Missions Generated
    ↓
Operational Layer (Basescape)
    ↓
  Units Equipped
    ↓
Tactical Layer (Battlescape)
    ↓
  Combat Resolution
    ↓
  Resources Gained
    ↓
Strategic Layer (Economy)
```

---

## Best Practices

### ✅ Good Practices

#### 1. Read Before Implementing
```lua
-- GOOD: Check API first, then implement
local Country = require("geoscape.country.country_manager")
local manager = Country.new()
manager:getCountry("usa")  -- Method documented in API
```

#### 2. Follow TOML Schema
```toml
# GOOD: All required fields present
[[unit]]
id = "soldier_rookie"
name = "Rookie Soldier"
type = "soldier"
faction = "xcom"

[unit.stats]
health = 30
```

#### 3. Use Type Annotations
```lua
-- GOOD: Clear types as documented in API
---@param country_id string Country identifier
---@return table|nil Country state or nil
function CountryManager:getCountry(country_id)
    return self.countries[country_id]
end
```

#### 4. Document Integration Points
```lua
-- GOOD: Reference related systems
-- Integrates with: MissionManager, EconomyManager, GeoScape
function CountryManager:calculateFunding(country_id)
    -- Implementation
end
```

### ❌ Bad Practices

#### 1. Don't Assume Undocumented Behavior
```lua
-- BAD: Using undocumented internal structure
local funding = country._internal_funding_cache[id]

-- GOOD: Use documented API
local funding = manager:calculateFunding(id)
```

#### 2. Don't Skip Required TOML Fields
```toml
# BAD: Missing required fields
[[unit]]
id = "soldier"
# Missing: name, type, faction, stats
```

#### 3. Don't Create Tight Coupling
```lua
-- BAD: Direct access to other system internals
local units = battlescape.unit_system.internal_units

-- GOOD: Use public API
local units = battlescape:getUnits()
```

#### 4. Don't Ignore Return Types
```lua
-- BAD: Not checking for nil
local unit = Unit.new("invalid_class")
unit:takeDamage(10)  -- Crash if unit is nil

-- GOOD: Validate returns
local unit = Unit.new("soldier")
if unit then
    unit:takeDamage(10)
end
```

### 📖 Documentation Standards

When documenting new systems:

1. **Use Standard Template** (see template below)
2. **Include TOML Examples** for all configuration
3. **Document All Methods** with parameters and return types
4. **Add Integration Section** showing connections to other systems
5. **Provide Usage Examples** for common scenarios
6. **List Implementation Status** (what's done, what's planned)

### 🔧 Naming Conventions

```lua
-- Entities: PascalCase
Unit, Country, Craft, Facility

-- Functions: camelCase
getCountry(), calculateFunding(), isAlive()

-- Files: snake_case
country_manager.lua, unit_system.lua

-- TOML IDs: snake_case
"soldier_rookie", "plasma_rifle", "command_center"

-- Properties: snake_case
country.funding_level, unit.max_health
```

---

## API Documentation Template

Use this template for new API files:

```markdown
# System Name API Reference

**System:** Layer Classification
**Module:** `engine/path/to/module/`
**Latest Update:** YYYY-MM-DD
**Status:** 🚧 In Progress | ✅ Complete | ⚠️ Needs Review

---

## Overview

Brief description (2-3 paragraphs)

**Layer Classification:** Strategic/Tactical/Operational
**Primary Responsibility:** Core duties
**Integration Points:** Related systems

---

## Implementation Status

### ✅ Implemented (in engine/)
- Feature with file reference

### 🚧 Partially Implemented
- Incomplete features

### 📋 Planned (in design/)
- Future features

---

## Core Entities

### Entity: EntityName

**Properties:**
\`\`\`lua
EntityName = {
  property = type, -- Description
}
\`\`\`

**TOML Configuration:**
\`\`\`toml
[[entity]]
id = "example"
property = value
\`\`\`

**Functions:**
\`\`\`lua
-- Category
entity:method(param: type) → returnType
\`\`\`

---

## Integration Guide

How this connects to other systems.

---

## Usage Examples

### Example: Common Use Case
\`\`\`lua
-- Working code example
\`\`\`

---

## Configuration Reference

Complete TOML schema with all fields.

---

## Best Practices

✅ Do this
❌ Don't do this

---

## Related Documentation

- [Related System](SYSTEM.md)
- [Design Mechanics](../design/mechanics/SYSTEM.md)
- [Architecture](../architecture/systems/SYSTEM.md)

---

**End of System Name API Reference**
\`\`\`

---

## Integrations with Other Systems

### Engine Implementation (`engine/`)

**Direct Correspondence:**
- Each API file documents a system module in `engine/`
- API defines the contract, engine provides the implementation
- Engine code should follow API specifications exactly

**Verification Process:**
1. Check that all API-documented methods exist in engine
2. Verify parameter types and return values match
3. Ensure TOML loading matches documented schema
4. Test integration points between systems

**Example Mapping:**
```
API: COUNTRIES.md
  └→ Engine: engine/geoscape/country/country_manager.lua
  └→ TOML: mods/core/rules/country/countries.toml
  └→ Tests: tests2/geoscape/country_test.lua
```

### Mods System (`mods/`)

**Mod Content Creation:**
- Mod developers use API documentation to create TOML content
- TOML format defined in each API file
- Examples provided for all entity types

**Validation:**
- TOML must conform to schema in [GAME_API.toml](GAME_API.toml)
- Use validator tools before deployment
- Reference existing content in `mods/core/rules/` as templates

**Example Mod Content:**
```
Mod Structure:
  mods/my_mod/
    ├── mod.toml              # Mod metadata
    ├── rules/
    │   ├── units/
    │   │   └── soldiers.toml  # Custom units (follows UNITS.md)
    │   ├── items/
    │   │   └── weapons.toml   # Custom weapons (follows WEAPONS_AND_ARMOR.md)
    │   └── country/
    │       └── countries.toml # Custom countries (follows COUNTRIES.md)
```

### Design Documentation (`design/mechanics/`)

**Design → API → Implementation Flow:**

1. **Design Phase:** Document gameplay mechanics in `design/mechanics/`
2. **API Phase:** Define system contract in `api/`
3. **Implementation Phase:** Build in `engine/` following API
4. **Content Phase:** Create TOML configurations in `mods/`
5. **Testing Phase:** Verify in `tests/`

**Alignment:**
- API reflects design decisions from `design/mechanics/`
- Architecture patterns from `architecture/` guide structure
- Design gaps documented in `design/gaps/`

**Example:**
```
Design: design/mechanics/Countries.md
  └→ API: api/COUNTRIES.md
  └→ Engine: engine/geoscape/country/country_manager.lua
  └→ Architecture: architecture/layers/GEOSCAPE.md
```

### Testing (`tests/`, `tests2/`)

**Test Coverage:**
- Test cases verify API compliance
- Mock data follows API specifications
- Integration tests validate system interactions

**Test Types:**
1. **Unit Tests:** Test individual methods match API signatures
2. **Integration Tests:** Verify system connections work as documented
3. **API Compliance Tests:** Check engine implements all documented features
4. **TOML Validation:** Ensure configurations match schema

**Example Test:**
```lua
-- tests2/geoscape/country_test.lua
-- Verifies COUNTRIES.md API compliance

describe("CountryManager", function()
    it("should implement getCountry() as documented", function()
        local manager = CountryManager.new()
        local country = manager:getCountry("usa")
        -- Verify returns match API specification
        assert.is_table(country)
        assert.equals("usa", country.id)
    end)
end)
```

---

## Contributing

### Adding New Systems

When adding new systems or features, follow this workflow:

#### 1. Design First (`design/mechanics/`)
```markdown
Create: design/mechanics/NEW_SYSTEM.md
Document:
  - Gameplay mechanics
  - Rules and balance
  - Player interactions
  - Integration with existing systems
```

#### 2. Define API (`api/`)
```markdown
Create: api/NEW_SYSTEM.md
Document:
  - Entity structures
  - Method signatures
  - TOML schema
  - Integration points
  - Usage examples
```

#### 3. Update Master Schema (`api/GAME_API.toml`)
```toml
Add TOML schema definitions for new entities
```

#### 4. Implement in Engine (`engine/`)
```lua
Create: engine/layer/new_system.lua
Implement following API specification exactly
```

#### 5. Create TOML Content (`mods/core/rules/`)
```toml
Create: mods/core/rules/category/items.toml
Add example configurations
```

#### 6. Write Tests (`tests2/`)
```lua
Create: tests2/layer/new_system_test.lua
Verify API compliance
```

#### 7. Update Documentation
- [ ] Add to `api/README.md` system list
- [ ] Cross-reference related systems
- [ ] Update integration matrix
- [ ] Add to architecture docs if needed

### Updating Existing Systems

When modifying existing systems:

1. **Update Design** if gameplay mechanics change
2. **Update API** with new methods/properties
3. **Update Engine** to match new API
4. **Update TOML** configurations if schema changes
5. **Update Tests** to cover new functionality
6. **Verify Integration** points still work
7. **Document Breaking Changes** in API file

### Quality Checklist

Before committing API changes:

- [ ] **API follows standard template**
- [ ] **All methods documented** with parameters and returns
- [ ] **TOML examples provided** for all entities
- [ ] **Integration points listed**
- [ ] **Usage examples included**
- [ ] **Status badges updated** (✅/⚠️/🚧)
- [ ] **Cross-references added** to related systems
- [ ] **Engine alignment verified**
- [ ] **Tests updated** or added
- [ ] **GAME_API.toml updated** if TOML schema changed

### Common Pitfalls to Avoid

❌ **Don't:**
- Document features that don't exist in engine
- Create API without corresponding design doc
- Skip TOML examples
- Forget to update integration matrix
- Leave methods undocumented
- Use inconsistent naming conventions

✅ **Do:**
- Keep API and engine in sync
- Provide complete examples
- Document all integration points
- Use standard templates
- Add status indicators
- Cross-reference related systems

---

## See Also

- [Architecture README](../architecture/README.md) - System design and integration flows
- [Design Mechanics](../design/mechanics/) - Game design specifications
- [Engine Main](../engine/README.md) - Core engine implementation
- [Mods System](../mods/README.md) - Modding and content creation
