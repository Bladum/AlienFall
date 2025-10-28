# API Documentation

**Purpose:** Single source of truth for all game system contracts, data structures, and TOML schemas  
**Audience:** Developers, modders, AI agents, system designers  
**Status:** Active development  
**Last Updated:** 2025-10-28

---

## 📋 Table of Contents

- [Overview](#overview)
- [Folder Structure](#folder-structure)
- [Key Features](#key-features)
- [Content](#content)
- [Input/Output](#inputoutput)
- [Relations to Other Modules](#relations-to-other-modules)
- [Format Standards](#format-standards)
- [How to Use](#how-to-use)
- [How to Contribute](#how-to-contribute)
- [AI Agent Instructions](#ai-agent-instructions)
- [Good Practices](#good-practices)
- [Bad Practices](#bad-practices)
- [Quick Reference](#quick-reference)

---

## Overview

The `api/` folder is the **authoritative reference** for all game systems, defining contracts, data structures, TOML schemas, and integration points. It serves as the bridge between design specifications and engine implementation.

**Core Purpose:**
- Define system interfaces and contracts
- Document TOML schemas for mod content
- Specify data structures and entities
- Show integration points between systems
- Provide usage examples and best practices

---

## Folder Structure

```
api/
├── README.md                          ← This file
├── GAME_API.toml                      ← MASTER SCHEMA (source of truth)
│
├── Core Guides
│   ├── GAME_API_GUIDE.md             ← How to read/write API docs
│   ├── MODDING_GUIDE.md              ← Creating mods with TOML
│   ├── SYNCHRONIZATION_GUIDE.md      ← Keeping docs in sync
│   └── NAMING_CONVENTIONS.md         ← Naming rules
│
├── Layer APIs (Game Modes)
│   ├── GEOSCAPE.md                   ← World map, missions, UFO tracking
│   ├── BASESCAPE.md                  ← Base management, facilities
│   ├── BATTLESCAPE.md                ← Tactical combat (2D)
│   ├── BATTLESCAPE_3D_COMBAT.md      ← 3D combat (future)
│   └── INTERCEPTION.md               ← Air combat
│
├── Entity APIs
│   ├── UNITS.md                      ← Soldiers, aliens, civilians
│   ├── ITEMS.md                      ← All items, equipment
│   ├── WEAPONS_AND_ARMOR.md          ← Combat gear
│   ├── CRAFTS.md                     ← Aircraft, UFOs
│   ├── FACILITIES.md                 ← Base facilities
│   └── PERKS.md                      ← Unit abilities, traits
│
├── System APIs
│   ├── AI_SYSTEMS.md                 ← AI behavior, decision making
│   ├── ECONOMY.md                    ← Resources, costs, trading
│   ├── FINANCE.md                    ← Budget, funding, income
│   ├── RESEARCH_AND_MANUFACTURING.md ← Tech tree, production
│   ├── MISSIONS.md                   ← Mission generation, objectives
│   ├── POLITICS.md                   ← Diplomacy, factions
│   ├── CAMPAIGN.md                   ← Campaign progression
│   └── LORE.md                       ← Story, narrative system
│
├── Technical APIs
│   ├── GUI.md                        ← UI components, widgets
│   ├── RENDERING.md                  ← Graphics, sprites
│   ├── ASSETS.md                     ← Asset loading, management
│   ├── ANALYTICS.md                  ← Telemetry, metrics
│   ├── INTEGRATION.md                ← Cross-system integration
│   ├── TESTING_FRAMEWORK.md          ← Test infrastructure
│   ├── UI_TESTING_FRAMEWORK.md       ← UI test tools
│   └── QA_SYSTEM.md                  ← Quality assurance
│
└── World APIs
    ├── COUNTRIES.md                   ← Nations, regions
    └── PILOTS.md                      ← Pilot system (craft crew)
```

---

## Key Features

- **Master TOML Schema:** `GAME_API.toml` is the single source of truth for all TOML configurations
- **System Contracts:** Each API defines clear interfaces between systems
- **Data Models:** Complete entity structures with all properties
- **TOML Examples:** Real-world examples for modders
- **Integration Points:** Shows system dependencies and connections
- **Cross-References:** Links to design docs, architecture, and implementation
- **Validation Rules:** Constraints and validation logic
- **Usage Examples:** Code samples for developers

---

## Content

### 36 API Files

| Category | Files | Purpose |
|----------|-------|---------|
| **Core Guides** | 4 files | How to use APIs, create mods, sync docs |
| **Layer APIs** | 5 files | Game modes (Geoscape, Basescape, Battlescape) |
| **Entity APIs** | 6 files | Game entities (units, items, crafts, facilities) |
| **System APIs** | 9 files | Game systems (AI, economy, research, politics) |
| **Technical APIs** | 8 files | Engine systems (GUI, rendering, testing) |
| **World APIs** | 2 files | World data (countries, pilots) |
| **Master Schema** | 1 file | GAME_API.toml (TOML source of truth) |

### Each API File Contains

1. **Overview** - System purpose and scope
2. **Core Entities** - Data structures and properties
3. **TOML Schema** - Configuration format for mods
4. **Functions/Methods** - System operations
5. **Integration Points** - Dependencies on other systems
6. **Usage Examples** - Code and TOML samples
7. **Validation Rules** - Constraints and error checking
8. **Cross-References** - Links to related docs

---

## Input/Output

### Inputs (What APIs Consume)

| Input | Source | Purpose |
|-------|--------|---------|
| Design specs | `design/mechanics/*.md` | System requirements |
| Architecture diagrams | `architecture/**/*.md` | System integration |
| Engine requirements | Developer needs | Implementation contracts |
| Mod requirements | Modder needs | TOML schemas |

### Outputs (What APIs Produce)

| Output | Target | Purpose |
|--------|--------|---------|
| System contracts | `engine/**/*.lua` | Implementation guide |
| TOML schemas | `mods/*/rules/**/*.toml` | Mod configuration |
| Data models | Developers | Entity structures |
| Integration specs | All systems | Cross-system interfaces |
| Validation rules | Engine validators | Data verification |

---

## Relations to Other Modules

### Upstream Dependencies (APIs Read From)

```
design/mechanics/*.md → api/*.md
    ↓
Mechanic designs define what APIs must support
```

### Downstream Dependencies (APIs Write To)

```
api/*.md → engine/**/*.lua
    ↓
API contracts define engine implementation

api/GAME_API.toml → mods/*/rules/**/*.toml
    ↓
Master schema validates all mod content

api/*.md → architecture/**/*.md
    ↓
APIs inform architecture diagrams
```

### Integration Map

| Module | Relationship | Details |
|--------|--------------|---------|
| **design/** | Input | Design specs define API requirements |
| **architecture/** | Peer | APIs and architecture stay synchronized |
| **engine/** | Output | APIs define implementation contracts |
| **mods/** | Output | APIs define TOML schemas for content |
| **tests2/** | Validation | Tests verify API contracts work |
| **docs/** | Reference | API guides link to instruction docs |

---

## Format Standards

### API Document Structure

```markdown
# [SYSTEM_NAME] API

**Version:** X.Y.Z
**Status:** Draft/Stable/Deprecated

## Overview
Brief system description

## Core Entities
### Entity Name
**Properties:**
- property_name (type) - description

## TOML Schema
```toml
[entity.entity_id]
property = value
```

## Functions/Methods
### function_name(params)
Description, parameters, returns

## Integration Points
- System A: How they connect
- System B: Dependencies

## Usage Examples
### Example 1: Common Use Case
Code sample

## Validation Rules
- Rule 1: Constraint description

## See Also
- [Related Doc](link)
```

### TOML Schema Standards

- Use `GAME_API.toml` as master schema
- All TOML follows TOML 1.0.0 spec
- Use snake_case for keys
- Document all fields with comments
- Provide example values
- Specify types and constraints
- Mark required vs optional fields

---

## How to Use

### For Developers (Engine Implementation)

1. **Find the relevant API:** Use the folder structure above
2. **Read Overview section:** Understand system purpose
3. **Study Core Entities:** Learn data structures
4. **Check Integration Points:** Identify dependencies
5. **Follow Usage Examples:** Copy/adapt code samples
6. **Implement in engine:** Create `engine/[layer]/[system].lua`
7. **Write tests:** Verify API contract in `tests2/`

**Example: Implementing Units System**
```bash
# 1. Read API
cat api/UNITS.md

# 2. Check design
cat design/mechanics/units.md

# 3. Review architecture
cat architecture/layers/BATTLESCAPE.md

# 4. Implement
# Create engine/battlescape/unit_manager.lua

# 5. Test
lovec "tests2/runners" run_single_test battlescape/unit_manager_test
```

### For Modders (Content Creation)

1. **Start with:** [MODDING_GUIDE.md](MODDING_GUIDE.md)
2. **Reference:** [GAME_API.toml](GAME_API.toml) for complete schema
3. **Find entity type:** Locate relevant API file (UNITS.md, ITEMS.md, etc.)
4. **Copy TOML example:** From API documentation
5. **Customize values:** Modify for your mod
6. **Validate:** Test in game with `lovec "engine"`

**Example: Creating Custom Unit**
```bash
# 1. Read schema
cat api/GAME_API.toml | grep -A 50 "\[unit\]"

# 2. Copy example from api/UNITS.md to mods/my_mod/rules/units/custom.toml

# 3. Test
lovec "engine"  # Check console for errors
```

### For AI Agents (Automated Tasks)

See [AI Agent Instructions](#ai-agent-instructions) section below.

---

## How to Contribute

### Adding a New API File

1. **Check if needed:**
   - Does system need TOML config? → Yes, create API
   - Does system need cross-system interface? → Yes, create API
   - Is it internal-only implementation? → No API needed

2. **Create API document:**
   ```bash
   # Use template structure (see Format Standards above)
   touch api/MY_SYSTEM.md
   ```

3. **Update GAME_API.toml:**
   ```toml
   # Add schema for new system
   [my_system]
   # ... fields
   ```

4. **Add to this README:**
   - Update folder structure
   - Update content table
   - Add to relevant category

5. **Create cross-references:**
   - Link from `design/mechanics/my_system.md`
   - Link from `architecture/systems/MY_SYSTEM.md`
   - Update `api/SYNCHRONIZATION_GUIDE.md`

### Updating Existing API

1. **Version properly:**
   - Breaking change: Increment major version
   - New feature: Increment minor version
   - Bug fix: Increment patch version

2. **Update all sections:**
   - Core Entities (if data changed)
   - TOML Schema (if config changed)
   - Integration Points (if dependencies changed)
   - Usage Examples (keep up to date)

3. **Sync with code:**
   - Update engine implementation
   - Update tests to match new API
   - Migrate existing mods if breaking

4. **Update documentation:**
   - Mark deprecated features
   - Add migration guide for breaking changes
   - Update SYNCHRONIZATION_GUIDE.md

---

## AI Agent Instructions

### When to Read APIs

| Scenario | Action |
|----------|--------|
| Implementing new system | Read relevant API + design + architecture |
| Creating mod content | Read GAME_API.toml + specific entity API |
| Fixing integration bug | Read both systems' Integration Points |
| Optimizing system | Read API to understand contracts |
| Writing tests | Read API for expected behavior |

### How to Navigate

```
1. Start with overview (this README)
2. Identify system category (Layer/Entity/System/Technical)
3. Read specific API file
4. Check GAME_API.toml for TOML schema
5. Review Usage Examples section
6. Cross-reference with:
   - design/mechanics/[system].md (requirements)
   - architecture/[layer]/[system].md (integration)
   - engine/[layer]/[system].lua (implementation)
```

### API-First Workflow

```
User asks to implement feature
    ↓
1. Check if API exists: ls api/*.md | grep -i [system]
    ↓
2a. If exists: Read API → Follow contract → Implement
2b. If missing: Create design → Create API → Implement
    ↓
3. Verify against API contract
    ↓
4. Update API if implementation reveals issues
```

### Reading GAME_API.toml

```lua
-- GAME_API.toml is the MASTER SCHEMA
-- All mod TOML must match this schema

-- Structure:
[entity_type.entity_id]      -- Top-level entity
property = value              -- Required properties
optional_property = value     -- Optional properties

[entity_type.entity_id.sub_entity]  -- Nested entities
sub_property = value

-- To validate mod TOML:
-- 1. Read GAME_API.toml schema
-- 2. Compare mod TOML structure
-- 3. Check all required fields present
-- 4. Verify types match (string, number, boolean, array, table)
```

### Common AI Tasks

| Task | Steps |
|------|-------|
| **Add new entity type** | 1. Read similar entity API (e.g., UNITS.md for new unit type)<br>2. Copy TOML schema structure<br>3. Update GAME_API.toml with new schema<br>4. Create API doc section<br>5. Add example TOML |
| **Fix integration issue** | 1. Read both systems' APIs<br>2. Check Integration Points sections<br>3. Identify contract mismatch<br>4. Fix in engine code<br>5. Update API if contract was unclear |
| **Optimize performance** | 1. Read API for expected behavior<br>2. Profile code (logs/system/performance_*.json)<br>3. Optimize without breaking contract<br>4. Verify tests still pass |
| **Create mod content** | 1. Read GAME_API.toml for schema<br>2. Find entity API for examples<br>3. Copy TOML template<br>4. Customize values<br>5. Validate with lovec "engine" |

---

## Good Practices

### ✅ Documentation

- Keep API docs in sync with engine code
- Update GAME_API.toml when adding new TOML fields
- Provide real, working examples
- Link to related documentation
- Version APIs properly (semantic versioning)
- Mark deprecated features clearly

### ✅ TOML Schemas

- Define in GAME_API.toml first, implement second
- Document all fields with comments
- Provide sensible defaults
- Use consistent naming (snake_case)
- Group related properties in sub-tables
- Validate mod content against schema

### ✅ Integration

- Document all system dependencies
- Show data flow between systems
- Provide integration examples
- Keep contracts loose (favor composition over tight coupling)
- Use event systems for loose coupling

### ✅ Examples

- Show common use cases
- Provide both code and TOML examples
- Include error handling examples
- Keep examples simple and focused
- Test examples regularly

---

## Bad Practices

### ❌ Documentation

- Don't let APIs diverge from code
- Don't skip TOML schema documentation
- Don't forget to version API changes
- Don't mix implementation details with contracts
- Don't create APIs for internal-only systems

### ❌ TOML Schemas

- Don't use reserved Lua keywords as keys
- Don't create deeply nested structures (>3 levels)
- Don't use camelCase or PascalCase (use snake_case)
- Don't skip required field validation
- Don't change schemas without migration guide

### ❌ Integration

- Don't create circular dependencies
- Don't expose internal implementation details
- Don't tightly couple unrelated systems
- Don't skip integration point documentation
- Don't assume system load order

### ❌ Examples

- Don't show incomplete/broken examples
- Don't use placeholder values (use realistic data)
- Don't skip error cases
- Don't make examples too complex
- Don't forget to test example code

---

## Quick Reference

### Essential Files

| File | Purpose | When to Use |
|------|---------|-------------|
| `GAME_API.toml` | Master TOML schema | Creating/validating mods |
| `GAME_API_GUIDE.md` | API documentation guide | Writing new API docs |
| `MODDING_GUIDE.md` | Modding tutorial | Creating mods |
| `SYNCHRONIZATION_GUIDE.md` | Keep docs in sync | Updating any system |
| `NAMING_CONVENTIONS.md` | Naming standards | Naming anything |

### Most Common APIs

| System | File | Use Case |
|--------|------|----------|
| Units | `UNITS.md` | Soldiers, aliens, civilians |
| Items | `ITEMS.md` | All equipment, items |
| Weapons | `WEAPONS_AND_ARMOR.md` | Combat gear |
| Facilities | `FACILITIES.md` | Base buildings |
| Missions | `MISSIONS.md` | Mission generation |
| Research | `RESEARCH_AND_MANUFACTURING.md` | Tech tree |
| Economy | `ECONOMY.md` | Resources, trading |

### Quick Commands

```bash
# Find API for system
ls api/*.md | grep -i [system_name]

# Validate TOML against schema
lovec "engine"  # Watch console for mod loading errors

# Check API sync status
cat api/SYNCHRONIZATION_GUIDE.md

# Generate tests from API
lovec "tests2/generators" scaffold_module_tests engine/[layer]/[system].lua
```

### Related Documentation

- **Design:** [design/README.md](../design/README.md) - Game mechanic specifications
- **Architecture:** [architecture/README.md](../architecture/README.md) - System integration diagrams
- **Engine:** Implementation of API contracts
- **Mods:** [mods/README.md](../mods/README.md) - Content that uses these APIs
- **Tests:** [tests2/README.md](../tests2/README.md) - Verification of API contracts

---

**Last Updated:** 2025-10-28  
**Maintainers:** Development Team  
**Questions:** See [GAME_API_GUIDE.md](GAME_API_GUIDE.md) or ask in project Discord

