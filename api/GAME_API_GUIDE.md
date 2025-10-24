# GAME_API.toml - Comprehensive Usage Guide

**Status:** ✅ Complete and Ready for Use
**Version:** 1.0.0
**Last Updated:** October 24, 2025

---

## What is GAME_API.toml?

`GAME_API.toml` is the **master API schema definition file** that serves as the single source of truth for the entire game's data structure. It defines:

- **Every entity type** that can exist in mod TOML files (Units, Items, Crafts, Facilities, Research, etc.)
- **Every field** that each entity can have
- **Type constraints** (must be string, integer, enum, etc.)
- **Value constraints** (min/max values, valid enum options)
- **Required vs optional fields**
- **Default values**
- **Cross-references** between entities (foreign keys)

### Why This Matters

Without a schema, mod creators face problems:
- ❌ No way to know what fields are valid
- ❌ No way to know what type a field should be
- ❌ Typos in field names cause silent failures
- ❌ Invalid values cause runtime errors
- ❌ No consistency across different mods
- ❌ Engine code doesn't match mod data structure

With the schema:
- ✅ Single source of truth for all data
- ✅ Tools can validate TOML before loading
- ✅ IDE support for autocomplete (future)
- ✅ Clear error messages for invalid data
- ✅ Consistency across all mods
- ✅ Easier to add new features

---

## File Location

**Location:** `api/GAME_API.toml` (in project root or `api/` folder)

**Usage:**
- Referenced by all validation tools
- Read by data loaders on startup
- Used by IDE plugins (future)
- Consulted by documentation generators

---

## Structure Overview

### File Organization

```toml
[_meta]                 # Metadata about the schema
[_mappings]             # Maps API sections to engine code
[_enums]                # Lists of valid values
[api.units]             # Unit/personnel definitions
[api.items]             # Items/equipment definitions
[api.crafts]            # Aircraft definitions
[api.facilities]        # Base facility definitions
[api.research]          # Research/technology definitions
[api.missions]          # Mission definitions
[api.geoscape]          # World map definitions
[api.economy]           # Economic system definitions
[api.aliens]            # Alien species definitions
[api.lore]              # Story/lore definitions
[api.manufacturing]     # Production recipe definitions
[_validation]           # Global validation rules
[_performance]          # Performance guidelines
[_examples]             # Example configurations
[_version_history]      # Version tracking
```

### Reading the Schema

Each entity type section shows:

```toml
[api.ENTITY_TYPE]
description = "What this entity type is for"
file_location = "mods/*/rules/entities/*.toml"

[api.ENTITY_TYPE.SPECIFIC_ENTITY]
description = "What this specific entity represents"
required_fields = ["id", "name", ...]

[api.ENTITY_TYPE.SPECIFIC_ENTITY.fields]
field_name = {
  type = "TYPE",              # string, integer, float, boolean, enum, array, table
  required = BOOL,            # true if must always be present
  default = VALUE,            # Used if field omitted
  min = NUMBER,               # Minimum value (for numeric fields)
  max = NUMBER,               # Maximum value
  values = ["opt1", "opt2"],  # Valid enum values
  references = "other.entity.id",  # Foreign key reference
  pattern = "^regex$",        # Validation pattern
  description = "..."         # Explanation
}
```

---

## How to Use the Schema

### For Mod Creators

When creating new mod content, use the schema as a reference:

**Example: Create a new unit class**

1. Check what fields are allowed: Look in `[api.units.unit_class.fields]`
2. See what is required: Note `required = true` fields
3. Check constraints: See `min`, `max`, `values`, `pattern`
4. Add your new unit:

```toml
# mods/mymod/rules/units/unit_classes.toml

[[unit_class]]
id = "my_specialist"                    # Must match pattern ^[a-z0-9_]+$
name = "My Specialist"                  # Any text
unit_type = "soldier"                   # Must be one of: soldier, alien, civilian, pilot
hp_base = 75                            # Must be integer, 1-999
accuracy_base = 80                      # Default 70, 0-100
strength_base = 12                      # Default 10, 1-20
```

### For Engine Developers

When loading mod data, validate against the schema:

```lua
-- Pseudo-code validation
local schema = loadTOML("api/GAME_API.toml")

function validateUnitClass(data)
  local fields = schema["api.units.unit_class.fields"]

  for field_name, field_spec in pairs(fields) do
    if field_spec.required and data[field_name] == nil then
      error("Required field missing: " .. field_name)
    end

    if data[field_name] ~= nil then
      local value = data[field_name]

      -- Type check
      if field_spec.type == "integer" and type(value) ~= "number" then
        error(field_name .. " must be integer")
      end

      -- Range check
      if field_spec.min and value < field_spec.min then
        error(field_name .. " value " .. value .. " below minimum " .. field_spec.min)
      end

      -- Enum check
      if field_spec.values and not tableContains(field_spec.values, value) then
        error(field_name .. " value '" .. value .. "' not in valid options")
      end
    end
  end
end
```

### For Documentation Generators

Use the schema to auto-generate documentation:

```lua
-- Generate docs from schema
function generateEntityDoc(entity_type_name)
  local spec = schema["api." .. entity_type_name]
  local doc = "# " .. entity_type_name .. "\n\n"
  doc = doc .. spec.description .. "\n\n"
  doc = doc .. "**File:** " .. spec.file_location .. "\n\n"

  -- Generate field table
  doc = doc .. "| Field | Type | Required | Description |\n"
  doc = doc .. "|-------|------|----------|-------------|\n"

  for field, spec in pairs(spec.fields) do
    doc = doc .. "| " .. field .. " | " .. spec.type .. " | "
    doc = doc .. (spec.required and "Yes" or "No") .. " | "
    doc = doc .. spec.description .. " |\n"
  end

  return doc
end
```

---

## Field Type Reference

### Basic Types

| Type | Examples | Notes |
|------|----------|-------|
| `string` | "rifle_standard", "Soldier" | Text field, any characters allowed |
| `integer` | 100, 0, -50 | Whole number, can be negative |
| `float` | 1.5, 0.95, 3.14 | Decimal number |
| `boolean` | true, false | True or false value |

### Complex Types

| Type | Syntax | Example |
|------|--------|---------|
| `enum` | `type = "enum", values = [...]` | `type = "enum", values = ["soldier", "alien"]` |
| `array` | `type = "array[string]"` | `ability_bonus = ["skill1", "skill2"]` |
| `table` | `type = "table[string -> integer]"` | `stat_modifiers = {strength = 1.2, will = 1.15}` |
| `reference` | `references = "other.entity.id"` | `starting_weapon = "rifle_standard"` (must exist in items) |

### Type Examples

```toml
# String field
id = "unit_rifleman"

# Integer field with range
hp_base = 65                 # 1-999

# Float field with range
fire_rate_base = 0.9         # 0.5-3.0

# Boolean field
is_positive = true

# Enum field (restricted values)
unit_type = "soldier"        # Must be: soldier, alien, civilian, pilot

# Array field
abilities = ["skill1", "skill2", "skill3"]

# Table/object field
stat_modifiers = {
  strength = 1.2
  intelligence = 1.1
}

# Reference field (foreign key)
starting_weapon = "rifle_standard"  # Must be valid items.id
```

---

## Common Constraints

### Required Fields

Fields marked `required = true` must always be present:

```toml
# ❌ INVALID - Missing 'id'
[[unit_class]]
name = "Missing ID"
unit_type = "soldier"

# ✅ VALID
[[unit_class]]
id = "my_unit"
name = "Has ID"
unit_type = "soldier"
```

### Numeric Ranges

Fields with `min` and `max` constraints:

```toml
# ❌ INVALID - health too low
hp_base = 0             # Minimum is 1

# ❌ INVALID - health too high
hp_base = 10000         # Maximum is 999

# ✅ VALID
hp_base = 65            # Within 1-999
```

### Enum Values

Fields with predefined valid values:

```toml
# ❌ INVALID - not in valid list
unit_type = "robot"     # Not in [soldier, alien, civilian, pilot]

# ✅ VALID
unit_type = "soldier"   # Is in valid list
```

### Pattern Validation

Field must match regex pattern:

```toml
# ❌ INVALID - contains uppercase
id = "My_Unit"          # Pattern requires ^[a-z0-9_]+$

# ❌ INVALID - contains special chars
id = "unit-01"          # Hyphens not allowed

# ✅ VALID
id = "my_unit_01"       # Matches ^[a-z0-9_]+$
```

### References (Foreign Keys)

Field must reference valid entity:

```toml
# ❌ INVALID - weapon doesn't exist
starting_weapon = "nonexistent_rifle"

# ✅ VALID (if item exists)
starting_weapon = "rifle_standard"  # Must exist in items.id
```

### Default Values

If field omitted, default is used:

```toml
# Missing accuracy_base - uses default of 70
[[unit_class]]
id = "my_unit"
name = "Unit"
unit_type = "soldier"
hp_base = 65            # Default 70 accuracy applied

# Explicit value overrides default
[[unit_class]]
id = "my_unit_2"
name = "Unit 2"
unit_type = "soldier"
hp_base = 65
accuracy_base = 85      # Uses 85, not default
```

---

## Entity Type Details

### Units (api.units)

Defines soldiers, aliens, and character types.

**File:** `mods/*/rules/units/unit_classes.toml`
**Required Fields:** `id`, `name`, `unit_type`, `hp_base`

**Key Fields:**
- `id` - Unique identifier
- `name` - Display name
- `unit_type` - Base type (soldier/alien/civilian/pilot)
- `hp_base` - Starting health
- `stat_*` - Base stats (accuracy, strength, reaction, etc.)
- `starting_weapon` - Default equipped weapon
- `starting_armor` - Default equipped armor

### Items (api.items)

Defines weapons, armor, consumables, and resources.

**File:** `mods/*/rules/items/items.toml`
**Required Fields:** `id`, `name`, `type`

**Key Fields:**
- `id` - Unique identifier
- `name` - Display name
- `type` - Item type (weapon/armor/consumable/resource)
- `weight` - Item weight in kg
- `value` - Sale price
- `damage` - (weapons only)
- `armor_value` - (armor only)
- `is_craftable` - Can be manufactured?
- `craft_components` - Required materials to craft

### Crafts (api.crafts)

Defines aircraft and spacecraft.

**File:** `mods/*/rules/crafts/craft_types.toml`
**Required Fields:** `id`, `name`, `type`

**Key Fields:**
- `id` - Unique identifier
- `name` - Display name
- `type` - Craft type (transport/interceptor/gunship/etc.)
- `crew_capacity` - Max personnel
- `speed` - Movement hexes per turn
- `fuel_capacity` - Max fuel
- `hp_max` - Hit points
- `weapon_slots` - Number of weapons

### Facilities (api.facilities)

Defines base buildings.

**File:** `mods/*/rules/facilities/base_facilities.toml`
**Required Fields:** `id`, `name`, `type`, `cost`

**Key Fields:**
- `id` - Unique identifier
- `name` - Display name
- `type` - Facility type (command/research/manufacturing/etc.)
- `width` - Grid width in hexes
- `height` - Grid height in hexes
- `cost` - Build cost in credits
- `capacity` - Personnel or storage capacity
- `power_consumption` - Power required
- `power_generation` - Power produced

### Research (api.research)

Defines technologies and research projects.

**File:** `mods/*/rules/research/tech_tree.toml`
**Required Fields:** `id`, `name`, `cost`

**Key Fields:**
- `id` - Unique identifier
- `name` - Display name
- `cost` - Research cost
- `time` - Research duration
- `requires` - Prerequisite techs
- `unlocks_items` - Items made available
- `unlocks_facilities` - Facilities made available
- `unlocks_crafts` - Crafts made available

### Manufacturing (api.manufacturing)

Defines production recipes.

**File:** `mods/*/rules/manufacturing/manufacturing.toml`
**Required Fields:** `id`, `output_item`, `components`

**Key Fields:**
- `id` - Unique identifier
- `output_item` - Item produced
- `output_quantity` - Quantity made
- `components` - Input materials
- `time` - Production time
- `cost` - Production cost
- `required_facility` - Where it can be made

---

## Cross-Reference Mappings

The schema maps API sections to engine code locations:

| API Section | Engine Modules | Key Files |
|---|---|---|
| `api.units` | battlescape/units, basescape/personnel | unit_classes.toml, units.toml |
| `api.items` | content/items | items.toml, weapons.toml, armor.toml |
| `api.crafts` | geoscape/crafts, interception | craft_types.toml, craft_weapons.toml |
| `api.facilities` | basescape/facilities | base_facilities.toml |
| `api.research` | research | tech_tree.toml |
| `api.manufacturing` | basescape/manufacturing | manufacturing.toml |
| `api.geoscape` | geoscape | regions.toml, countries.toml |
| `api.economy` | economy | prices.toml, costs.toml |
| `api.aliens` | content/aliens | races.toml, alien_units.toml |

**Use this mapping to:**
- Find where engine code loads specific data
- Know which mod files affect which systems
- Understand integration points
- Trace data flow through engine

---

## Validation Rules

### Global Rules

Applied to all entities:

| Rule | Constraint |
|------|-----------|
| **ID Format** | Must match `^[a-z0-9_]+$` (lowercase letters, numbers, underscores) |
| **ID Length** | 1-50 characters |
| **Name Length** | 1-100 characters |
| **Description Length** | 0-1000 characters |
| **Required Fields** | Every entity must have `id` and `name` |
| **Disallowed Characters** | `<`, `>`, `"`, `'`, `{`, `}` in string fields |

### Entity-Specific Rules

Different rules for different entity types:

**Unit Classes:**
- `unit_type` must be in valid list
- `hp_base` must be 1-999
- `accuracy_base` must be 0-100
- All stat fields must be reasonable ranges

**Items:**
- `type` must be valid (weapon/armor/consumable/resource)
- `weight` must be non-negative
- `value` must be non-negative
- If `is_craftable`, must have `craft_components`

**Crafts:**
- `crew_capacity` must be 1+
- `speed` must be positive
- `fuel_capacity` must be positive
- `cost` must be positive

**Facilities:**
- `width` and `height` must be 1-5
- `cost` must be positive
- `capacity` must be non-negative
- `power_generation` and `power_consumption` must be non-negative

---

## Enum Reference

Quick lookup for valid enum values:

### Unit Types
```
soldier, alien, civilian, hybrid, mechanical, pilot
```

### Craft Types
```
transport, interceptor, gunship, assault, scout, bomber
```

### Facility Types
```
command, residential, manufacturing, storage, power, detection, medical, research, defense
```

### Item Types
```
weapon, armor, consumable, resource, lore, equipment, ammo
```

### Damage Types
```
kinetic, energy, explosive, psionic, hazard, incendiary, acid, cold
```

### Armor Classes
```
light, medium, heavy, power, alien, hazmat, stealth
```

### Tech Levels
```
conventional, plasma, laser, alien, advanced, exotic
```

### Status Effects
```
bleeding, stunned, panicked, poisoned, burning, unconscious, frozen, petrified, confused, controlled
```

---

## Working with the Schema

### Step 1: Find Entity Type

Look in `[api.ENTITY_TYPE]` section for your entity.

### Step 2: Read Field Definitions

Check `[api.ENTITY_TYPE.SPECIFIC_ENTITY.fields]` for all available fields.

### Step 3: Identify Requirements

Note which fields have `required = true`.

### Step 4: Check Constraints

See `min`, `max`, `values`, `pattern`, `references` for constraints.

### Step 5: Validate Your Data

Ensure your TOML matches the schema before using.

---

## Troubleshooting

### Error: "Unknown field 'my_stat'"

**Cause:** Field not defined in schema
**Solution:** Check schema section to see valid fields

### Error: "Field 'type' requires one of: soldier, alien, civilian, pilot. Got: 'robot'"

**Cause:** Invalid enum value
**Solution:** Use one of the valid values listed

### Error: "Field 'hp_base' requires integer 1-999. Got: 0"

**Cause:** Value out of range
**Solution:** Set value within min-max range

### Error: "Required field 'id' is missing"

**Cause:** Required field not provided
**Solution:** Add required field to your entity

### Error: "Reference validation failed: starting_weapon='rifle_xyz' not found"

**Cause:** Referenced entity doesn't exist
**Solution:** Ensure referenced entity is defined in appropriate mod

---

## Best Practices

### 1. Always Check the Schema

Before adding a new field, check if it exists in the schema. If not, propose adding it.

### 2. Use Meaningful IDs

```toml
# ❌ Bad - unclear purpose
id = "item1"

# ✅ Good - clear meaning
id = "rifle_plasma_advanced"
```

### 3. Keep Fields Organized

```toml
# ✅ Good organization
[[unit_class]]
id = "rifleman"
name = "Rifleman"
unit_type = "soldier"

# Stats
hp_base = 65
accuracy_base = 70
strength_base = 10

# Equipment
starting_weapon = "rifle"
starting_armor = "light_armor"
```

### 4. Use Comments for Complex Configs

```toml
# Veteran+ units get bonuses
[[rank]]
rank_id = 1
name = "Veteran"
xp_required = 100
stat_bonuses = {accuracy = 5, strength = 1}  # +5% accuracy, +1 strength
```

### 5. Validate Before Deploying

Always validate your mod against the schema:

```bash
# Future validation tool
love2d-mod-validator mods/mymod/
```

---

## Future Enhancements

Planned improvements to schema:

- [ ] IDE/Editor support (auto-complete, validation)
- [ ] Web-based schema browser
- [ ] Automated documentation generation
- [ ] Schema versioning and migration tools
- [ ] Performance profiling recommendations
- [ ] Backwards compatibility checker
- [ ] Schema diff tool for updates

---

## For More Information

- **API Synchronization:** See `api/SYNCHRONIZATION_GUIDE.md`
- **Modding Guide:** See `api/MODDING_GUIDE.md`
- **Engine Code:** See corresponding `engine/` modules
- **Examples:** See `mods/core/rules/` for reference implementations

---

**Last Updated:** October 24, 2025
**Schema Version:** 1.0.0
**Status:** ✅ Complete and Documented
