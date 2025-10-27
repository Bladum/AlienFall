# API Folder - Interface Contracts & Schema Definitions

**Purpose:** Define formal contracts, data structures, and validation schemas  
**Audience:** Developers, architects, AI agents  
**Format:** Markdown documentation + TOML schemas

---

## What Goes in api/

### Structure
```
api/
├── README.md                    Overview and usage guide
├── GAME_API_GUIDE.md           How to use the API system
├── GAME_API.toml               Master schema (SOURCE OF TRUTH)
├── SYNCHRONIZATION_GUIDE.md    Keep docs and code in sync
├── MODDING_GUIDE.md            For mod creators
├── NAMING_CONVENTIONS.md       Consistent naming rules
│
├── UNITS.md                    Unit system API
├── ITEMS.md                    Item system API
├── CRAFTS.md                   Craft/vehicle system API
├── MISSIONS.md                 Mission system API
├── RESEARCH_AND_MANUFACTURING.md
├── ECONOMY.md                  Economic systems API
├── AI_SYSTEMS.md               AI behavior API
├── GEOSCAPE.md                 World map API
├── BATTLESCAPE.md              Tactical combat API
├── BASESCAPE.md                Base management API
└── ... (36 total API documents)
```

---

## Core Principle: Single Source of Truth

**GAME_API.toml is the master schema.** All other documents reference it.

```toml
# api/GAME_API.toml - THE definitive schema

[entities.unit]
description = "Individual combat operative"

[entities.unit.fields]
id = { type = "string", required = true, pattern = "^[a-z_][a-z0-9_]*$" }
name = { type = "string", required = true }
strength = { type = "integer", range = [6, 12], required = true }
health = { type = "integer", range = [1, 9999], required = true }

[entities.unit.functions]
gainExperience = {
    parameters = [{ name = "amount", type = "integer" }],
    returns = "void",
    description = "Add experience points to unit"
}
```

**Why TOML as source of truth:**
- Machine-readable (validators can parse)
- Human-readable (designers can understand)
- Versionable (git tracks changes)
- Single location (no duplication)

---

## Content Guidelines

### What Belongs Here
- ✅ Function signatures with parameter types
- ✅ Data structure definitions
- ✅ TOML/JSON schemas with validation rules
- ✅ Type definitions (integer, string, boolean, etc.)
- ✅ Valid ranges and constraints
- ✅ Required vs optional fields
- ✅ Enum values and their meanings

### What Does NOT Belong Here
- ❌ Implementation details ("Use hash table for lookups")
- ❌ Design rationale ("Why 5 XP per kill") - goes in design/
- ❌ Architecture diagrams - goes in architecture/
- ❌ Actual code implementation - goes in engine/
- ❌ Game content - goes in mods/

---

## Schema Structure Example

### Markdown Documentation (api/UNITS.md)
```markdown
# Units API

## Data Structure

### Unit Entity
- **id** (string, required): Unique identifier (pattern: ^[a-z_][a-z0-9_]*$)
- **name** (string, required): Display name
- **strength** (integer, required): Physical power (range: 6-12)
- **health** (integer, required): Hit points (range: 1-9999)

## Functions

### gainExperience(amount: integer) → void
Add experience points to unit.

**Parameters:**
- amount (integer): XP to add (must be >= 0)

**Returns:** void

**Validation:**
- Rejects negative amounts
- Type must be integer
```

### TOML Schema (api/GAME_API.toml)
```toml
[entities.unit.functions.gainExperience]
parameters = [
    { name = "amount", type = "integer", min = 0 }
]
returns = "void"
description = "Add experience points to unit"
validation = [
    "amount >= 0",
    "type(amount) == 'number'"
]
```

---

## Integration with Other Folders

### design/ → api/
Design specs become formal contracts:
- **Design:** "Units gain 5 XP per kill, promote at 100 XP"
- **API:** `gainExperience(amount: integer)` with validation rules

### api/ → architecture/
APIs define what needs to be diagrammed:
- **API:** Defines `gainExperience()` function
- **Architecture:** Shows sequence diagram of how it's called

### api/ → engine/
Contracts must be implemented:
- **API:** Defines signature and validation
- **Engine:** Implements the function exactly as specified

### api/ → mods/
Schema validates content:
- **API:** Defines unit structure and ranges
- **Mods:** TOML validates against schema 100%

---

## Validation System

### Type Validation
```toml
[entities.unit.fields]
strength = { type = "integer", range = [6, 12] }
# Validates:
# - Must be integer (not string "8")
# - Must be in range [6, 12]
# - Rejects: 5, 13, "8", null
```

### Pattern Validation
```toml
id = { type = "string", pattern = "^[a-z_][a-z0-9_]*$" }
# Validates:
# - Must start with lowercase letter or underscore
# - Can contain lowercase, digits, underscores
# - Rejects: "Rookie Soldier" (spaces, capitals)
```

### Required Field Validation
```toml
name = { type = "string", required = true }
# Validates:
# - Field must exist in TOML
# - Cannot be null or undefined
```

---

## TOML Validator Usage

```bash
# Validate all mod content against schema
lua tools/validators/toml_validator.lua mods/ api/GAME_API.toml

# Example output:
Validating: mods/core/rules/units/soldiers.toml

✓ unit.rookie_soldier
  ✓ id: "rookie_soldier" (valid pattern)
  ✓ name: "Rookie Soldier" (string, required)
  ✓ strength: 8 (in range [6, 12])
  ✓ health: 90 (in range [1, 9999])

✗ unit.elite_soldier
  ✗ strength: 15 (out of range [6, 12])
  ✗ missing required field: 'name'

Errors: 2
Warnings: 0
```

---

## API Document Structure

Each API document (e.g., UNITS.md) should contain:

### 1. Overview
Brief description of the system

### 2. Entities
Data structures with all fields

### 3. Functions
All available functions with signatures

### 4. Events
Events that the system emits

### 5. States
Valid states and transitions

### 6. Validation Rules
Constraints and validation logic

### 7. Examples
Code examples showing usage

### 8. Integration
How it connects to other systems

---

## Common Patterns

### Pattern 1: Entity Definition
```toml
[entities.entity_name]
description = "Brief description"

[entities.entity_name.fields]
id = { type = "string", required = true }
name = { type = "string", required = true }
value = { type = "integer", range = [min, max] }
```

### Pattern 2: Function Definition
```toml
[entities.entity_name.functions.functionName]
parameters = [
    { name = "param1", type = "integer" },
    { name = "param2", type = "string", optional = true }
]
returns = "type"
description = "What it does"
```

### Pattern 3: Enum Definition
```toml
[enums.unit_rank]
values = ["rookie", "squaddie", "sergeant", "captain", "major", "colonel"]
description = "Unit promotion ranks"
```

---

## Synchronization Guide

**Critical:** Keep GAME_API.toml synchronized with:
- Markdown API docs (*.md)
- Engine implementation (engine/)
- TOML content (mods/)

**Process:**
1. Change design (design/)
2. Update API schema (api/GAME_API.toml)
3. Update API docs (api/*.md)
4. Update architecture if needed (architecture/)
5. Implement in engine (engine/)
6. Update content (mods/)
7. Update tests (tests2/)

**Tool:**
```bash
lua tools/validators/api_sync_checker.lua
# Checks all API components are synchronized
```

---

## Modding Guide Integration

API documentation enables modders:

**For Modders:**
1. Read api/GAME_API.toml to see available entities
2. Read api/MODDING_GUIDE.md for instructions
3. Create TOML files matching schema
4. Validate with toml_validator.lua
5. Test in game

**Example:**
```toml
# mymod/rules/units/custom_units.toml

[unit.my_custom_unit]
id = "my_custom_unit"
name = "My Custom Unit"
strength = 10  # Must be in [6, 12] per API
health = 100
sprite = "units/my_custom.png"
```

---

## Validation Checklist

API quality check:

- [ ] All entities defined in GAME_API.toml
- [ ] All fields have type definitions
- [ ] Required fields marked
- [ ] Ranges specified where applicable
- [ ] Patterns validated for strings
- [ ] Functions have parameter types
- [ ] Return types specified
- [ ] Documentation matches schema
- [ ] No implementation details in API
- [ ] Design rationale references design/

---

## Best Practices

### 1. Single Source of Truth
GAME_API.toml is authoritative. All other docs reference it.

### 2. Machine-Readable First
Schema must be parseable by validators. Human readability is secondary.

### 3. Strict Validation
Define tight constraints. Better to reject invalid data than accept garbage.

### 4. Version Changes Carefully
API changes break mods. Version carefully, document breaking changes.

### 5. Document Validation Rules
Don't just say "valid email" - specify the exact regex pattern.

### 6. Keep Synchronized
When API changes, update ALL related documents immediately.

---

## Tools

### Schema Validator
```bash
lua tools/validators/schema_validator.lua api/GAME_API.toml
# Validates schema syntax and completeness
```

### TOML Validator
```bash
lua tools/validators/toml_validator.lua mods/ api/GAME_API.toml
# Validates TOML content against schema
```

### API Coverage Checker
```bash
lua tools/validators/api_coverage.lua design/ api/
# Checks if all design decisions have API contracts
```

### Sync Checker
```bash
lua tools/validators/api_sync_checker.lua
# Verifies API, docs, and code are synchronized
```

---

## Maintenance

**On Design Change:**
1. Update GAME_API.toml
2. Update corresponding API doc (*.md)
3. Validate all existing TOML
4. Update engine if needed

**Monthly:**
- Review API for completeness
- Check synchronization
- Update documentation

**Per Release:**
- Version API changes
- Document breaking changes
- Migration guide for modders

---

**See:** api/README.md for complete usage guide

**Related:**
- [modules/01_DESIGN_FOLDER.md](01_DESIGN_FOLDER.md) - Design specs become API contracts
- [modules/03_ARCHITECTURE_FOLDER.md](03_ARCHITECTURE_FOLDER.md) - APIs are diagrammed
- [modules/04_ENGINE_FOLDER.md](04_ENGINE_FOLDER.md) - APIs are implemented
- [modules/05_MODS_FOLDER.md](05_MODS_FOLDER.md) - Content validates against API

