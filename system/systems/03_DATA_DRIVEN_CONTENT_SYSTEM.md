# Data-Driven Content System
**Pattern: Separating Logic from Data**

**Purpose:** Enable content creation without code changes, support modding, hot-reload configuration  
**Problem Solved:** Hardcoded values, recompilation for content changes, impossible modding  
**Universal Pattern:** Applicable to any system requiring configurable behavior

---

## 🎯 Core Concept

**Principle:** Code defines HOW systems work. Data defines WHAT exists in those systems.

```
ENGINE (Logic)                    CONTENT (Data)
┌─────────────��───┐              ┌──────────────────┐
│ function Unit() │              │ [unit.rookie]    │
│   load(data)    │ ←────loads───│   strength = 8   │
│   update()      │              │   health = 90    │
│   render()      │              │ [unit.veteran]   │
└─────────────────┘              │   strength = 12  │
        │                         │   health = 120   │
        │                         └──────────────────┘
        └─ Same code handles ALL units via data
```

**Key Rule:** Zero hardcoded content. Everything configurable.

**Why This Matters:**
- **Flexibility:** Change content without recompilation
- **Moddability:** Users can create new content
- **Hot-Reload:** See changes immediately
- **Separation:** Artists/designers work independently of programmers
- **Validation:** Schema ensures content correctness

---

## 📊 System Architecture

### Component 1: Schema Definition

**Purpose:** Define WHAT data CAN exist

**Location:** `api/GAME_API.toml`

**Structure:**
```toml
[entities.unit]
description = "Combat operative with persistent identity"

[entities.unit.fields]
id = { type = "string", required = true, pattern = "^[a-z_][a-z0-9_]*$" }
name = { type = "string", required = true }
strength = { type = "integer", range = [6, 12], required = true }
health = { type = "integer", range = [1, 9999], required = true }
sprite = { type = "string", required = true, pattern = ".*\\.png$" }
```

**Input:** Design specifications (what entities exist)  
**Output:** Schema for validation  
**Validates:** Type, range, required fields, patterns

**Why Schema First:**
- Prevents invalid data from entering system
- Documents data structure formally
- Enables automatic validation
- Single source of truth for structure

---

### Component 2: Content Definition

**Purpose:** Define WHAT data DOES exist

**Location:** `mods/core/rules/units/soldiers.toml`

**Structure:**
```toml
[unit.rookie]
id = "rookie"
name = "Rookie Soldier"
strength = 8
health = 90
sprite = "units/rookie.png"

[unit.veteran]
id = "veteran"
name = "Veteran Soldier"
strength = 12
health = 120
sprite = "units/veteran.png"
```

**Input:** Schema definition  
**Output:** Entity data  
**Validates:** Against schema (toml_validator.lua)

**Why TOML:**
- Human-readable and writable
- Supports complex nested structures
- Easy to parse in Lua
- Git-friendly (line-based diffs)

---

### Component 3: Content Loader

**Purpose:** Parse data files and validate

**Location:** `engine/mods/mod_loader.lua`

**Process:**
```lua
-- 1. Discover all mods
local mods = ModLoader:discoverMods("mods/")
print("Found " .. #mods .. " mods")

-- 2. Resolve dependencies
local load_order = ModLoader:resolveDependencies(mods)
print("Load order: " .. table.concat(load_order, " → "))

-- 3. Load each mod's TOML files
for _, mod in ipairs(load_order) do
    print("Loading mod: " .. mod.name)
    
    local toml_files = ModLoader:findTOMLFiles(mod.path .. "/rules/")
    
    for _, file in ipairs(toml_files) do
        -- Parse TOML
        local data = TOML.parse(love.filesystem.read(file))
        
        -- Validate against schema
        local valid, errors = Schema:validate(data, "api/GAME_API.toml")
        
        if valid then
            ContentRegistry:register(data)
            print("  ✓ " .. file)
        else
            error("Validation failed: " .. file .. "\n" .. errors)
        end
    end
end

-- 4. Load assets
local sprites = ContentRegistry:getAllSprites()
AssetLoader:loadSprites(sprites)
print("Loaded " .. #sprites .. " sprites")
```

**Input:** TOML files, asset files  
**Output:** Loaded entities in memory  
**Validates:** Schema compliance, asset existence

---

### Component 4: Content Registry

**Purpose:** Store loaded entities for runtime access

**Location:** `engine/mods/content_registry.lua`

**Structure:**
```lua
ContentRegistry = {
    units = {},     -- All unit definitions
    items = {},     -- All item definitions
    missions = {},  -- All mission definitions
    crafts = {},    -- Aircraft definitions
    research = {},  -- Research projects
    -- etc.
}

function ContentRegistry:register(data)
    -- Register entities from parsed TOML
    for entity_type, entities in pairs(data) do
        for entity_id, entity_data in pairs(entities) do
            if not self[entity_type] then
                self[entity_type] = {}
            end
            
            -- Store entity
            self[entity_type][entity_id] = entity_data
            
            print("Registered: " .. entity_type .. "." .. entity_id)
        end
    end
end

function ContentRegistry:get(entity_type, entity_id)
    if not self[entity_type] then
        error("Unknown entity type: " .. entity_type)
    end
    
    local entity = self[entity_type][entity_id]
    if not entity then
        error("Unknown entity: " .. entity_type .. "." .. entity_id)
    end
    
    return entity
end

function ContentRegistry:getAll(entity_type)
    return self[entity_type] or {}
end
```

**Input:** Validated entity data  
**Output:** Runtime entity lookup  
**Access Pattern:** `ContentRegistry:get("unit", "rookie")`

---

### Component 5: Entity Factory

**Purpose:** Create runtime instances from content data

**Location:** `engine/core/entity_factory.lua`

**Process:**
```lua
function EntityFactory:createUnit(unit_id)
    -- 1. Get definition from registry
    local def = ContentRegistry:get("unit", unit_id)
    if not def then
        error("Unit not found: " .. unit_id)
    end
    
    -- 2. Create instance
    local unit = Unit.new(def.id, def.name, 1)
    
    -- 3. Apply data from TOML
    unit.strength = def.strength
    unit.dexterity = def.dexterity or 7  -- Default if not specified
    unit.constitution = def.constitution or 9
    unit.health_max = def.health
    unit.health_current = def.health
    
    -- 4. Load sprite asset
    unit.sprite = def.sprite
    unit.sprite_image = AssetLoader:getSprite(def.sprite)
    if not unit.sprite_image then
        error("Sprite not found: " .. def.sprite)
    end
    
    -- 5. Apply additional properties
    if def.starting_weapon then
        unit.weapon = EntityFactory:createItem(def.starting_weapon)
    end
    
    if def.starting_armor then
        unit.armor = EntityFactory:createItem(def.starting_armor)
    end
    
    return unit
end
```

**Input:** Entity ID  
**Output:** Runtime instance  
**Pattern:** Data → Instance conversion

---

## 🔄 Data Flow

### Loading Flow

```
1. Mod Discovery
   Scan mods/ folder → List of available mods
   
2. Dependency Resolution
   Read mod.toml files → Determine load order via topological sort
   
3. TOML Parsing
   Read rules/*.toml → Convert to Lua tables
   
4. Schema Validation
   Lua tables + GAME_API.toml → Valid entities OR error messages
   
5. Registry Population
   Valid entities → ContentRegistry storage
   
6. Asset Loading
   Extract sprite paths → Load PNG files into memory
   
7. Runtime Ready
   Game can create instances via EntityFactory
```

### Mod Override Flow

```
Core mod loads first:
  [unit.rookie]
  strength = 8
  health = 90

Custom mod loads second:
  [unit.rookie]
  strength = 10  ← OVERRIDE (per-field granularity)

Result in ContentRegistry:
  unit.rookie.strength = 10  (from custom mod)
  unit.rookie.health = 90    (from core mod, not overridden)
```

**Override Rules:**
- Later mods override earlier mods
- Per-field granularity (not whole entity)
- Load order determined by dependencies

---

## ✅ Validation Rules

### Rule 1: Schema Completeness

**Check:** All entity types have complete schemas

```bash
tools/validators/schema_validator.lua api/GAME_API.toml

# Checks:
# - All fields have type definitions
# - Ranges are logical (min < max)
# - Required fields marked
# - Patterns are valid regex
# - No undefined types
```

**Violations:**
- Field without type: `name = { required = true }` (missing type!)
- Invalid range: `strength = { range = [12, 6] }` (inverted!)
- Bad pattern: `id = { pattern = "[a-z+" }` (unclosed bracket!)

**Fix:** Complete schema definition

---

### Rule 2: Content Validation

**Check:** All TOML validates against schema

```bash
tools/validators/toml_validator.lua mods/ api/GAME_API.toml

# For each TOML file:
# - Parse syntax (valid TOML?)
# - Check types (integer vs string?)
# - Check ranges (value in [min, max]?)
# - Check required (all fields present?)
# - Check patterns (ID matches regex?)
```

**Violations:**
- Wrong type: `strength = "8"` (string, should be integer)
- Out of range: `strength = 15` (range is [6, 12])
- Missing required: No 'id' field
- Bad pattern: `id = "Rookie Soldier"` (spaces not allowed in pattern)

**Fix:** Correct TOML to match schema

---

### Rule 3: Asset Existence

**Check:** All referenced assets exist

```bash
tools/validators/content_validator.lua mods/

# For each entity:
# - sprite = "units/rookie.png" → File exists at mods/*/assets/units/rookie.png?
# - sound = "weapons/rifle.ogg" → File exists?
# - portrait = "portraits/rookie.png" → File exists?
```

**Violations:**
- Missing file: References "units/missing.png" (file not found)
- Wrong format: Image is 32x32 (should be 24x24 for units)
- Wrong type: Sound is MP3 (should be OGG)

**Fix:** Add missing assets or fix references

---

### Rule 4: Reference Integrity

**Check:** Entity references are valid

```bash
tools/validators/reference_checker.lua mods/

# Example check:
# [unit.rookie]
# starting_weapon = "rifle_basic"  ← Does rifle_basic exist in items?
# starting_armor = "armor_basic"   ← Does armor_basic exist in items?
# requires_research = "laser_tech" ← Does laser_tech exist in research?
```

**Violations:**
- References non-existent item: `starting_weapon = "laser_rifle"` (not defined)
- Circular dependency: Unit A requires B, B requires A
- Missing prerequisite: Research requires tech that doesn't exist

**Fix:** Add missing entities or fix references

---

## 🔧 Mod System Architecture

### Mod Structure

```
mods/my_custom_mod/
├── mod.toml                 # Metadata
├── rules/                   # TOML configurations
│   ├── units/
│   │   └── custom_units.toml
│   ├── items/
│   │   └── custom_items.toml
│   └── missions/
│       └── custom_missions.toml
└── assets/                  # Asset files
    ├── units/
    │   └── custom_unit.png
    ├── items/
    │   └── custom_item.png
    └── sounds/
        └── custom_sound.ogg
```

### Mod Metadata (mod.toml)

```toml
[mod]
id = "my_custom_mod"                    # Unique identifier (lowercase_with_underscores)
name = "My Custom Mod"                  # Display name
version = "1.0.0"                       # Semantic versioning (major.minor.patch)
author = "Author Name"                  # Creator
description = "Adds custom units and weapons"  # What it does

dependencies = ["core"]                 # Required mods (load order)
engine_version = "0.1.0"               # Minimum engine version required

[mod.content]
units = true                           # Contains unit definitions
items = true                           # Contains item definitions
missions = false                       # No mission changes
facilities = false                     # No facility changes
research = false                       # No research changes
```

**Purpose:**
- Define mod identity and version
- Specify dependencies (load order)
- Declare what content types included
- Ensure engine compatibility

---

### Mod Loading Order

```
1. Core mod (always first)
   └─ mods/core/ (base game content)

2. Dependency resolution via topological sort
   ├─ Mod A (depends on: core)
   ├─ Mod B (depends on: core, Mod A)
   └─ Mod C (depends on: core)

3. Final load order:
   1. core          (no dependencies)
   2. Mod A         (depends only on core)
   3. Mod C         (depends only on core, alphabetical)
   4. Mod B         (depends on Mod A, loads after)
```

**Algorithm:** Topological sort of dependency DAG (Directed Acyclic Graph)

**Error Cases:**
- Circular dependency: A → B → A (error, cannot resolve)
- Missing dependency: Mod needs X but X not found (error)
- Version mismatch: Mod needs engine 0.2.0 but running 0.1.0 (error)

---

### Mod Override Behavior

**Per-Field Override:**
```
Core defines:
  [unit.rookie]
  id = "rookie"
  name = "Rookie Soldier"
  strength = 8
  health = 90
  sprite = "units/rookie.png"

Mod A defines:
  [unit.rookie]
  strength = 10  ← Only this field

Result after loading both:
  [unit.rookie]
  id = "rookie"              ← From core
  name = "Rookie Soldier"    ← From core
  strength = 10              ← From Mod A (overridden!)
  health = 90                ← From core
  sprite = "units/rookie.png" ← From core
```

**Granularity:** Per-field override, not whole entity

**Why:** Allows mods to change specific values without redefining everything

---

## 🚫 Anti-Patterns

### Anti-Pattern 1: Hardcoded Content

**WRONG:**
```lua
-- engine/battlescape/units/unit.lua
function Unit.createRookie()
    local unit = Unit.new()
    unit.id = "rookie"
    unit.name = "Rookie Soldier"
    unit.strength = 8      ← Hardcoded!
    unit.health = 90       ← Hardcoded!
    return unit
end
```

**RIGHT:**
```lua
-- engine/core/entity_factory.lua
function EntityFactory:createUnit(unit_id)
    local def = ContentRegistry:get("unit", unit_id)
    local unit = Unit.new()
    unit.id = def.id
    unit.name = def.name
    unit.strength = def.strength    ← From data!
    unit.health = def.health        ← From data!
    return unit
end
```

**Why:** Hardcoded values require recompilation. Data-driven allows modding and balance changes without code changes.

---

### Anti-Pattern 2: Code in Data

**WRONG:**
```toml
[unit.rookie]
strength = 8
health = 90
on_hit = "function(self, damage) self.health = self.health - damage end"  ← Code in data!
```

**RIGHT:**
```toml
[unit.rookie]
strength = 8
health = 90
on_hit_behavior = "standard_damage"  ← Reference to behavior, not code
# Behavior defined in engine, not data
```

**Why:**
- Security risk (arbitrary code execution)
- Impossible to validate
- Breaks data-driven principle
- Can't hot-reload safely

---

### Anti-Pattern 3: Schema in Multiple Places

**WRONG:**
- Define unit structure in code comments
- Redefine in design documentation
- Redefine in TOML examples
- All three have different definitions! Drift!

**RIGHT:**
- Define ONCE in api/GAME_API.toml
- All other places REFERENCE the schema
- Validate all TOML against this single schema
- Single source of truth

**Why:** Duplication causes drift. Validation becomes impossible when no authoritative source exists.

---

### Anti-Pattern 4: Validation After Load

**WRONG:**
```lua
-- Load data first
local data = TOML.parse(file)
ContentRegistry:register(data)  ← Invalid data now in system!

-- Validate later (too late!)
local valid = Schema:validate(data)
if not valid then
    -- Data already loaded and might be used!
    print("Warning: Invalid data")
end
```

**RIGHT:**
```lua
-- Validate BEFORE registering
local data = TOML.parse(file)

local valid, errors = Schema:validate(data, "api/GAME_API.toml")
if not valid then
    error("Invalid data in " .. file .. ":\n" .. errors)
end

-- Only valid data gets registered
ContentRegistry:register(data)  ← Only valid data
```

**Why:** Fail fast. Prevent invalid data from ever entering the system.

---

## 🔧 Tools for Data-Driven System

### 1. TOML Validator

```bash
lua tools/validators/toml_validator.lua mods/my_mod/

# Validates:
# - TOML syntax correct
# - Schema compliance
# - Type correctness
# - Range validation
# - Required fields present
# - Pattern matching

# Example output:
Validating: mods/my_mod/rules/units/my_units.toml

✓ unit.my_soldier
  ✓ id: "my_soldier" (matches pattern)
  ✓ strength: 9 (in range [6, 12])
  ✓ All required fields present

✗ unit.broken_unit
  ✗ strength: 15 (out of range [6, 12])
  ✗ missing required field: 'name'
  ✗ sprite: "invalid" (doesn't match pattern .*\.png$)

Summary: 1 valid, 1 invalid
```

---

### 2. Content Validator

```bash
lua tools/validators/content_validator.lua mods/my_mod/

# Validates:
# - Asset files exist
# - Asset formats correct (PNG, OGG)
# - Asset dimensions correct (24x24 for units)
# - Reference integrity (all refs valid)
# - No orphaned assets

# Example output:
Checking assets...

✓ units/rookie.png exists (24x24, PNG)
✗ units/veteran.png missing
✗ units/elite.png wrong size (32x32, should be 24x24)

Checking references...

✓ rookie.starting_weapon = "rifle_basic" (exists in items)
✗ veteran.starting_weapon = "laser_rifle" (not found in items)

Summary: 3 errors found
```

---

### 3. Schema Generator

```bash
lua tools/generators/schema_generator.lua design/mechanics/

# Reads design docs
# Generates schema entries for GAME_API.toml

# Example:
Reading design/mechanics/Units.md...
Found entity: Unit
Found fields: id, name, strength, health, rank, experience
Generating schema...

Output written to: api/GAME_API_generated.toml

Review and merge into GAME_API.toml
```

---

### 4. Content Generator (TOML Template)

```bash
lua tools/generators/toml_generator.lua unit elite_soldier

# Creates TOML template with:
# - All required fields from schema
# - Example/default values
# - Comments explaining each field

# Output: elite_soldier.toml
[unit.elite_soldier]
# Unique identifier (required, pattern: ^[a-z_][a-z0-9_]*$)
id = "elite_soldier"

# Display name (required, string)
name = "Elite Soldier"

# Physical strength (required, integer, range: [6, 12])
strength = 11

# Hit points (required, integer, range: [1, 9999])
health = 120

# Sprite path (required, string, pattern: .*\.png$)
sprite = "units/elite_soldier.png"
```

---

## 📊 System Health Metrics

### Metric 1: Data-Driven Ratio

```
Content in TOML: >95%
Hardcoded content in code: <5% (constants only, like max players = 8)
```

### Metric 2: Validation Pass Rate

```
TOML validation: 100% (all content validates)
Asset validation: 100% (all assets exist)
Reference validation: 100% (no broken links)
```

### Metric 3: Mod Compatibility

```
Core mod loads: 100% (always)
Custom mods load successfully: >90%
Mod conflicts: <5%
```

### Metric 4: Hot-Reload Success

```
TOML changes detected: 100%
Successful hot-reloads: >95%
Runtime errors after reload: <5%
```

---

## 🌍 Universal Adaptation

### Pattern in Different Domains

**Game Development** (current):
- Engine: Game systems logic
- Content: Units, items, levels, missions

**Web Application:**
- Engine: Business logic, services
- Content: Configuration, localization, themes

**Data Pipeline:**
- Engine: Processing logic, transformations
- Content: Data source configurations, schemas

**Mobile App:**
- Engine: App functionality code
- Content: UI themes, strings, config

**Embedded System:**
- Engine: Firmware code
- Content: Device profiles, calibration data

**Key Insight:** Separate WHAT varies from WHAT stays the same in ANY domain.

---

## 🎯 Success Criteria

Data-driven system is working when:

✅ Zero hardcoded content in engine code  
✅ All content validates 100% against schema  
✅ Non-programmers can create content safely  
✅ Mods work without engine code changes  
✅ Hot-reload works reliably during development  
✅ Validation catches 100% of schema violations  
✅ Content changes don't require recompilation  
✅ Modders have clear documentation and tools  

---

## 📝 Implementation Checklist

To implement this pattern in your project:

- [ ] Define schema format (TOML, JSON, YAML, etc.)
- [ ] Create master schema file (like GAME_API.toml)
- [ ] Build schema validator
- [ ] Build content loader with validation before registration
- [ ] Create content registry for runtime access
- [ ] Build entity factory (data → instance conversion)
- [ ] Implement mod system (discovery, dependencies, loading)
- [ ] Build content validator (assets, references)
- [ ] Support hot-reload (detect file changes, reload safely)
- [ ] Document content creation process
- [ ] Train team on data-driven development
- [ ] Create tools (validators, generators, templates)

---

**Related Systems:**
- [01_SEPARATION_OF_CONCERNS_SYSTEM.md](01_SEPARATION_OF_CONCERNS_SYSTEM.md) - Content is Concern 5
- [02_PIPELINE_ARCHITECTURE_SYSTEM.md](02_PIPELINE_ARCHITECTURE_SYSTEM.md) - Content is Stage 5
- [modules/05_MODS_FOLDER.md](../modules/05_MODS_FOLDER.md) - Mods folder details

**Last Updated:** 2025-10-27  
**Pattern Maturity:** Production-Proven

---

*"Data-driven design is not about moving code to files—it's about separating what varies from what stays the same."*

