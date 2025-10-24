# Task: Generate Synthetic Mock Data Based on GAME_API

**Status:** TODO
**Priority:** Medium
**Created:** 2025-10-24
**Completed:** N/A
**Assigned To:** AI Agent

**Dependencies:** TASK-001 (GAME_API.toml must exist first)

---

## Overview

Create automated generator that produces synthetic mod content and test data based on GAME_API.toml definitions. Generated data will be valid, consistent, and cover all API definitions for testing, prototyping, and validation purposes.

---

## Purpose

**Why this is needed:**
- Need test data for unit tests
- Need mock data for integration tests
- Need synthetic mod for API coverage testing
- Need data generation for prototyping new mechanics
- Need example data for mod creators
- Manual data creation is time-consuming and error-prone
- Need to test edge cases (min/max values, all enums, etc.)
- Need quick way to populate empty mods

**What problem it solves:**
- Automated creation of valid test data
- Complete API coverage in generated mods
- Consistent data for reproducible tests
- Quick prototyping without manual TOML writing
- Examples for every entity type
- Stress testing with large datasets
- Validation of GAME_API.toml completeness

---

## Requirements

### Functional Requirements
- [ ] Load and parse GAME_API.toml schema
- [ ] Generate valid TOML files for ALL entity types
- [ ] Generate data that covers all possible field types
- [ ] Generate data that covers all enum values
- [ ] Generate data that respects min/max constraints
- [ ] Generate data with all required fields present
- [ ] Generate data with optional fields (configurable)
- [ ] Generate realistic IDs (human-readable, not random UUIDs)
- [ ] Generate consistent cross-references (units reference real techs)
- [ ] Support multiple generation strategies:
  - Minimal: One example per entity type
  - Coverage: All enum combinations tested
  - Stress: Large volume (100s of entities)
  - Realistic: Game-balanced reasonable values
- [ ] Generate proper folder structure (mods/*/rules/*)
- [ ] Generate README.md explaining generated content
- [ ] Support seeded random generation (reproducible)
- [ ] Support incremental generation (add to existing mod)

### Technical Requirements
- [ ] Written in Lua
- [ ] Can run standalone: `lovec tools/generators/generate_mock_data.lua`
- [ ] Command-line interface with options
- [ ] Output to specified mod folder
- [ ] Clear progress output during generation
- [ ] Validate generated data (self-test)
- [ ] Generate both mod content and test fixtures
- [ ] Support JSON output format (for non-TOML consumers)

### Acceptance Criteria
- [ ] Generator script exists and runs
- [ ] Can generate complete synthetic mod
- [ ] Generated mod passes validation (TASK-002)
- [ ] Generated data covers 100% of API definitions
- [ ] Generated data is internally consistent
- [ ] Documentation explains generated content
- [ ] Multiple generation strategies work
- [ ] Seeded generation is reproducible
- [ ] Generated data loads in engine without errors

---

## Plan

### Step 1: Create Generator Script Structure
**Description:** Set up basic generator with CLI interface

**Files to create:**
- `tools/generators/generate_mock_data.lua` - main entry point
- `tools/generators/lib/schema_loader.lua` - loads GAME_API.toml (reuse from validators)
- `tools/generators/lib/data_generator.lua` - core generation logic
- `tools/generators/lib/name_generator.lua` - generates realistic names
- `tools/generators/lib/id_generator.lua` - generates consistent IDs
- `tools/generators/lib/cross_reference_resolver.lua` - handles entity references
- `tools/generators/lib/toml_writer.lua` - writes TOML files
- `tools/generators/README.md` - documentation

**CLI interface:**
```bash
# Generate minimal synthetic mod
lovec tools/generators/generate_mock_data.lua --output mods/synth_mod --strategy minimal

# Generate full coverage mod
lovec tools/generators/generate_mock_data.lua --output mods/synth_mod --strategy coverage

# Generate stress test mod (lots of data)
lovec tools/generators/generate_mock_data.lua --output mods/synth_mod --strategy stress --count 500

# Generate with seed for reproducibility
lovec tools/generators/generate_mock_data.lua --output mods/synth_mod --seed 12345

# Generate only specific categories
lovec tools/generators/generate_mock_data.lua --output mods/synth_mod --categories units,items

# Generate test fixtures for test suite
lovec tools/generators/generate_mock_data.lua --output tests/fixtures/mock_data --format test
```

**Estimated time:** 2-3 hours

---

### Step 2: Implement Core Data Generator
**Description:** Logic to generate data for each field type

**File:** `tools/generators/lib/data_generator.lua`

**Generator for each type:**
```lua
local DataGenerator = {}

function DataGenerator.generate(fieldDef, strategy, context)
  local fieldType = fieldDef.type

  if fieldType == "string" then
    return DataGenerator.generateString(fieldDef, strategy, context)
  elseif fieldType == "integer" then
    return DataGenerator.generateInteger(fieldDef, strategy, context)
  elseif fieldType == "float" then
    return DataGenerator.generateFloat(fieldDef, strategy, context)
  elseif fieldType == "boolean" then
    return DataGenerator.generateBoolean(fieldDef, strategy, context)
  elseif fieldType == "enum" then
    return DataGenerator.generateEnum(fieldDef, strategy, context)
  elseif fieldType == "array" then
    return DataGenerator.generateArray(fieldDef, strategy, context)
  elseif fieldType == "table" then
    return DataGenerator.generateTable(fieldDef, strategy, context)
  elseif fieldType == "reference" then
    return DataGenerator.generateReference(fieldDef, strategy, context)
  end
end

-- Generate string values
function DataGenerator.generateString(fieldDef, strategy, context)
  local fieldName = context.fieldName

  -- Use context to generate meaningful strings
  if fieldName == "name" or fieldName == "display_name" then
    return NameGenerator.generate(context.entityType)
  elseif fieldName == "description" then
    return "Generated description for " .. (context.entityId or "entity")
  elseif fieldName:match("_file") or fieldName:match("_path") then
    return "assets/" .. context.entityType .. "/" .. context.entityId .. ".png"
  else
    return "generated_" .. fieldName
  end
end

-- Generate integer values
function DataGenerator.generateInteger(fieldDef, strategy, context)
  local min = fieldDef.min or 0
  local max = fieldDef.max or 100

  if strategy == "minimal" then
    return min
  elseif strategy == "coverage" then
    -- Return different values to cover range
    return math.random(min, max)
  elseif strategy == "stress" then
    return math.random(min, max)
  elseif strategy == "realistic" then
    -- Use realistic values based on field name
    return DataGenerator.generateRealisticInteger(fieldDef, context)
  end
end

-- Generate enum values
function DataGenerator.generateEnum(fieldDef, strategy, context)
  local values = fieldDef.values

  if strategy == "minimal" then
    return values[1]
  elseif strategy == "coverage" then
    -- Ensure all enum values get used across entities
    local index = context.coverageIndex or 1
    return values[((index - 1) % #values) + 1]
  else
    return values[math.random(1, #values)]
  end
end

-- Generate array values
function DataGenerator.generateArray(fieldDef, strategy, context)
  local elementType = fieldDef.element_type
  local minSize = fieldDef.min_size or 1
  local maxSize = fieldDef.max_size or 5

  local size = math.random(minSize, maxSize)
  local array = {}

  for i = 1, size do
    table.insert(array, DataGenerator.generate(elementType, strategy, context))
  end

  return array
end

-- Generate table/object values
function DataGenerator.generateTable(fieldDef, strategy, context)
  local result = {}

  for fieldName, subFieldDef in pairs(fieldDef.fields or {}) do
    local subContext = {
      fieldName = fieldName,
      entityType = context.entityType,
      entityId = context.entityId,
      parent = context,
    }

    result[fieldName] = DataGenerator.generate(subFieldDef, strategy, subContext)
  end

  return result
end

-- Generate reference values (foreign keys)
function DataGenerator.generateReference(fieldDef, strategy, context)
  local referencedType = fieldDef.references

  -- Look up existing entity of referenced type
  -- Or generate placeholder ID
  return IDGenerator.getReferenceId(referencedType, context)
end
```

**Estimated time:** 6-8 hours

---

### Step 3: Implement Name Generator
**Description:** Generate realistic names for entities

**File:** `tools/generators/lib/name_generator.lua`

**Name generation strategies:**
```lua
local NameGenerator = {}

-- Name word banks
local prefixes = {
  weapon = {"Auto", "Heavy", "Light", "Plasma", "Laser", "Pulse"},
  unit = {"Elite", "Veteran", "Rookie", "Squad", "Tactical"},
  tech = {"Advanced", "Improved", "Experimental", "Basic"},
  facility = {"Advanced", "Basic", "Secure", "Underground"},
}

local bases = {
  weapon = {"Rifle", "Pistol", "Cannon", "Launcher", "Blade"},
  unit = {"Soldier", "Scout", "Sniper", "Medic", "Heavy"},
  tech = {"Weapons", "Armor", "Tactics", "Engineering"},
  facility = {"Laboratory", "Workshop", "Hangar", "Storage"},
}

local suffixes = {
  weapon = {"Mk1", "Mk2", "Type-A", "Type-B", "v2"},
  tech = {"I", "II", "III", "Alpha", "Beta"},
}

function NameGenerator.generate(entityType, seed)
  local prefix = prefixes[entityType] or {}
  local base = bases[entityType] or {"Item"}
  local suffix = suffixes[entityType] or {}

  local parts = {}

  -- Sometimes add prefix
  if math.random() > 0.5 and #prefix > 0 then
    table.insert(parts, prefix[math.random(1, #prefix)])
  end

  -- Always add base
  table.insert(parts, base[math.random(1, #base)])

  -- Sometimes add suffix
  if math.random() > 0.7 and #suffix > 0 then
    table.insert(parts, suffix[math.random(1, #suffix)])
  end

  return table.concat(parts, " ")
end

-- Generate realistic alien names
function NameGenerator.generateAlienName()
  local consonants = {"x", "z", "k", "th", "v", "sh", "ch", "r", "n", "m"}
  local vowels = {"a", "e", "i", "o", "u", "aa", "ee"}

  local name = ""
  local length = math.random(2, 4)

  for i = 1, length do
    name = name .. consonants[math.random(1, #consonants)]
    name = name .. vowels[math.random(1, #vowels)]
  end

  -- Capitalize first letter
  return name:sub(1,1):upper() .. name:sub(2)
end

-- Generate location names
function NameGenerator.generateLocationName()
  local locations = {
    "North America", "South America", "Europe", "Asia",
    "Africa", "Australia", "Arctic", "Antarctic",
    "Pacific", "Atlantic", "Mediterranean"
  }
  return locations[math.random(1, #locations)]
end
```

**Estimated time:** 3-4 hours

---

### Step 4: Implement ID Generator
**Description:** Generate consistent, readable IDs

**File:** `tools/generators/lib/id_generator.lua`

**ID generation logic:**
```lua
local IDGenerator = {}

-- Track generated IDs to avoid duplicates
local generatedIds = {}

-- Track entities for cross-references
local entityRegistry = {
  units = {},
  items = {},
  techs = {},
  facilities = {},
  -- etc.
}

function IDGenerator.generate(entityType, name, index)
  -- Convert name to snake_case ID
  local id = name:lower():gsub("%s+", "_"):gsub("[^%w_]", "")

  -- Add prefix based on type
  local prefix = {
    units = "unit_",
    items = "item_",
    weapons = "wpn_",
    armor = "arm_",
    techs = "tech_",
    facilities = "fac_",
  }

  id = (prefix[entityType] or "") .. id

  -- Ensure uniqueness
  if generatedIds[id] then
    id = id .. "_" .. index
  end

  generatedIds[id] = true

  return id
end

function IDGenerator.registerEntity(entityType, entityId)
  if not entityRegistry[entityType] then
    entityRegistry[entityType] = {}
  end
  table.insert(entityRegistry[entityType], entityId)
end

function IDGenerator.getReferenceId(entityType, context)
  local entities = entityRegistry[entityType] or {}

  if #entities > 0 then
    -- Return random existing entity
    return entities[math.random(1, #entities)]
  else
    -- Return placeholder (will be generated later)
    return "placeholder_" .. entityType
  end
end

function IDGenerator.resolveReferences()
  -- Second pass: replace placeholders with actual IDs
  -- This is called after all entities are generated
end
```

**Estimated time:** 2-3 hours

---

### Step 5: Implement Cross-Reference Resolver
**Description:** Ensure references between entities are valid

**File:** `tools/generators/lib/cross_reference_resolver.lua`

**Two-pass generation:**
```lua
local CrossReferenceResolver = {}

-- First pass: generate all entities with placeholder references
function CrossReferenceResolver.generateWithPlaceholders(schema, strategy)
  local entities = {}

  for entityType, definition in pairs(schema) do
    entities[entityType] = {}

    -- Generate entities for this type
    local count = CrossReferenceResolver.getCount(entityType, strategy)

    for i = 1, count do
      local entity = DataGenerator.generateEntity(definition, strategy, {
        entityType = entityType,
        index = i,
      })

      entities[entityType][entity.id] = entity
      IDGenerator.registerEntity(entityType, entity.id)
    end
  end

  return entities
end

-- Second pass: resolve placeholder references to actual IDs
function CrossReferenceResolver.resolveReferences(entities, schema)
  for entityType, entityList in pairs(entities) do
    for entityId, entity in pairs(entityList) do
      CrossReferenceResolver.resolveEntityReferences(entity, schema, entities)
    end
  end
end

function CrossReferenceResolver.resolveEntityReferences(entity, schema, allEntities)
  for fieldName, value in pairs(entity) do
    if type(value) == "string" and value:match("^placeholder_") then
      local referencedType = value:match("^placeholder_(.+)$")

      -- Get random entity of referenced type
      local candidates = {}
      for id, _ in pairs(allEntities[referencedType] or {}) do
        table.insert(candidates, id)
      end

      if #candidates > 0 then
        entity[fieldName] = candidates[math.random(1, #candidates)]
      end
    elseif type(value) == "table" then
      -- Recursively resolve nested tables
      CrossReferenceResolver.resolveEntityReferences(value, schema, allEntities)
    end
  end
end

-- Determine how many entities to generate based on strategy
function CrossReferenceResolver.getCount(entityType, strategy)
  if strategy == "minimal" then
    return 1
  elseif strategy == "coverage" then
    -- Generate enough to cover all enum combinations
    return 10
  elseif strategy == "stress" then
    return 100
  elseif strategy == "realistic" then
    local realisticCounts = {
      units = 20,
      items = 30,
      weapons = 15,
      armor = 10,
      techs = 40,
      facilities = 12,
    }
    return realisticCounts[entityType] or 10
  end

  return 5
end
```

**Estimated time:** 4-5 hours

---

### Step 6: Implement TOML Writer
**Description:** Write generated data to TOML files

**File:** `tools/generators/lib/toml_writer.lua`

**TOML formatting:**
```lua
local TOMLWriter = {}

function TOMLWriter.write(data, filePath)
  local content = TOMLWriter.serialize(data)

  -- Ensure directory exists
  local dir = filePath:match("(.+)/[^/]+$")
  if dir then
    love.filesystem.createDirectory(dir)
  end

  -- Write file
  local file = io.open(filePath, "w")
  if file then
    file:write(content)
    file:close()
    return true
  else
    print("[ERROR] Cannot write file: " .. filePath)
    return false
  end
end

function TOMLWriter.serialize(data, indent)
  indent = indent or 0
  local result = {}
  local indentStr = string.rep("  ", indent)

  for key, value in pairs(data) do
    if type(value) == "table" then
      -- Check if it's an array or object
      if #value > 0 then
        -- Array
        table.insert(result, indentStr .. key .. " = [")
        for _, item in ipairs(value) do
          table.insert(result, indentStr .. "  " .. TOMLWriter.serializeValue(item) .. ",")
        end
        table.insert(result, indentStr .. "]")
      else
        -- Object/table
        table.insert(result, indentStr .. "[" .. key .. "]")
        table.insert(result, TOMLWriter.serialize(value, indent + 1))
      end
    else
      table.insert(result, indentStr .. key .. " = " .. TOMLWriter.serializeValue(value))
    end
  end

  return table.concat(result, "\n")
end

function TOMLWriter.serializeValue(value)
  if type(value) == "string" then
    return '"' .. value:gsub('"', '\\"') .. '"'
  elseif type(value) == "number" then
    return tostring(value)
  elseif type(value) == "boolean" then
    return value and "true" or "false"
  else
    return '"' .. tostring(value) .. '"'
  end
end
```

**Estimated time:** 3-4 hours

---

### Step 7: Implement Main Generator Logic
**Description:** Orchestrate generation process

**File:** `tools/generators/generate_mock_data.lua`

**Main flow:**
```lua
-- Parse arguments
local args = parseArgs(arg)

-- Set random seed for reproducibility
if args.seed then
  math.randomseed(args.seed)
end

-- Load schema
local schema = SchemaLoader.load("api/GAME_API.toml")

-- Filter categories if specified
local categoriesToGenerate = args.categories or schema.getAllCategories()

-- Generate entities (first pass - with placeholders)
print("Generating entities...")
local entities = CrossReferenceResolver.generateWithPlaceholders(schema, args.strategy)

-- Resolve cross-references (second pass)
print("Resolving cross-references...")
CrossReferenceResolver.resolveReferences(entities, schema)

-- Write to files
print("Writing TOML files...")
for entityType, entityList in pairs(entities) do
  local outputDir = args.output .. "/rules/" .. entityType

  for entityId, entityData in pairs(entityList) do
    local filePath = outputDir .. "/" .. entityId .. ".toml"
    TOMLWriter.write(entityData, filePath)
    print("  Created: " .. filePath)
  end
end

-- Generate README
print("Generating README...")
local readme = generateReadme(entities, args)
TOMLWriter.write(readme, args.output .. "/README.md")

-- Validate generated data
if args.validate then
  print("Validating generated data...")
  os.execute('lovec tools/validators/validate_mod.lua "' .. args.output .. '"')
end

print("Generation complete!")
print("Output: " .. args.output)
print("Strategy: " .. args.strategy)
print("Total files: " .. countGeneratedFiles(entities))
```

**Estimated time:** 3-4 hours

---

### Step 8: Generate README for Generated Mods
**Description:** Explain what was generated and how to use it

**Content:**
```markdown
# Generated Synthetic Mod

This mod was automatically generated using the mock data generator.

## Generation Details

- **Strategy:** {strategy}
- **Seed:** {seed}
- **Date:** {date}
- **Generator Version:** {version}

## Contents

### Units ({count})
Generated unit types covering all unit API definitions.
- soldier types: {soldier_count}
- alien types: {alien_count}
- civilian types: {civilian_count}

### Items ({count})
Generated items covering all item API definitions.
- weapons: {weapon_count}
- armor: {armor_count}
- equipment: {equipment_count}

... (etc for all categories)

## Purpose

This synthetic data is used for:
- Testing the game engine
- Validating API completeness
- Prototyping new mechanics
- Example data for mod creators

## Notes

- All data is synthetic and not balanced for gameplay
- Cross-references are valid but arbitrary
- Names are randomly generated
- Numeric values follow API constraints but may not be realistic

## How to Use

1. Copy this mod to `mods/` folder
2. Enable in game mod loader
3. Start new game

## Validation

Run validator to check this mod:
```bash
lovec tools/validators/validate_mod.lua mods/synth_mod
```
```

**Estimated time:** 2 hours

---

### Step 9: Create Test Fixture Generator
**Description:** Generate data specifically for test suite

**Special requirements for test data:**
- Minimal size (fast to load)
- Edge cases (min/max values, empty arrays, all enums)
- Known IDs (tests can reference specific entities)
- No random elements (deterministic)

**Output location:** `tests/fixtures/generated/`

**Estimated time:** 2-3 hours

---

### Step 10: Add VS Code Tasks
**Description:** Make generator easy to run from VS Code

**Tasks:**
```json
{
  "label": "🎲 GENERATE: Minimal Synthetic Mod",
  "type": "shell",
  "command": "lovec",
  "args": ["tools/generators/generate_mock_data.lua", "--output", "mods/synth_mod", "--strategy", "minimal"]
},
{
  "label": "🎲 GENERATE: Full Coverage Mod",
  "type": "shell",
  "command": "lovec",
  "args": ["tools/generators/generate_mock_data.lua", "--output", "mods/synth_mod", "--strategy", "coverage"]
},
{
  "label": "🎲 GENERATE: Test Fixtures",
  "type": "shell",
  "command": "lovec",
  "args": ["tools/generators/generate_mock_data.lua", "--output", "tests/fixtures/generated", "--format", "test"]
}
```

**Estimated time:** 1 hour

---

### Step 11: Documentation
**Description:** Complete usage documentation

**File:** `tools/generators/README.md`

**Must cover:**
- What the generator does
- Generation strategies explained
- Command-line usage examples
- How to customize generation
- How generated data is structured
- How to use generated mods
- How to use generated test fixtures
- Troubleshooting

**Estimated time:** 2-3 hours

---

### Step 12: Testing
**Description:** Validate generator works correctly

**Test scenarios:**
- [ ] Generate minimal mod - succeeds
- [ ] Generate coverage mod - succeeds
- [ ] Generate stress mod - succeeds
- [ ] Generated data validates (TASK-002)
- [ ] Generated data loads in engine
- [ ] Seeded generation is reproducible
- [ ] Cross-references are valid
- [ ] All enum values get covered
- [ ] Test fixtures work in test suite

**Estimated time:** 4-5 hours

---

## Implementation Details

### Architecture

**Two-Phase Generation:**
1. **Phase 1:** Generate all entities with placeholder references
2. **Phase 2:** Resolve placeholders to actual entity IDs

**Modular Design:**
```
generate_mock_data.lua
├── lib/schema_loader.lua (reuse from validators)
├── lib/data_generator.lua (core generation logic)
├── lib/name_generator.lua (realistic names)
├── lib/id_generator.lua (consistent IDs)
├── lib/cross_reference_resolver.lua (handle references)
└── lib/toml_writer.lua (write files)
```

### Key Components

**DataGenerator:** Generates values for each field type
**NameGenerator:** Creates realistic entity names
**IDGenerator:** Creates consistent, readable IDs
**CrossReferenceResolver:** Ensures references are valid
**TOMLWriter:** Formats and writes TOML files

### Dependencies

- GAME_API.toml (TASK-001)
- TOML writer/encoder
- Filesystem access
- Random number generator

---

## Testing Strategy

### Unit Tests

**test_data_generator.lua:**
- Test generation for each field type
- Test strategy differences
- Test constraint respect (min/max)

**test_name_generator.lua:**
- Test name generation for each type
- Test name uniqueness

**test_id_generator.lua:**
- Test ID generation
- Test ID uniqueness
- Test reference resolution

**test_cross_reference_resolver.lua:**
- Test two-phase generation
- Test reference validity

### Integration Tests

**test_generator_integration.lua:**
- Generate complete mod
- Validate generated mod
- Load generated mod in engine
- Check all entities present
- Check cross-references valid

### Manual Testing

1. Generate minimal mod
2. Load in game - verify works
3. Generate coverage mod
4. Validate with TASK-002 validator
5. Check all API sections covered

---

## Documentation Updates

### Files to Create
- [ ] `tools/generators/generate_mock_data.lua`
- [ ] `tools/generators/lib/*.lua`
- [ ] `tools/generators/README.md`

### Files to Update
- [ ] `tools/README.md` - add generator to tools list
- [ ] `.vscode/tasks.json` - add generation tasks
- [ ] `tests/README.md` - mention test fixture generation
- [ ] `api/MODDING_GUIDE.md` - mention generator as learning tool

---

## Notes

**Use Cases:**
1. **Testing:** Generate test fixtures for automated tests
2. **Validation:** Generate mod that covers 100% of API
3. **Prototyping:** Quickly create data for new mechanics
4. **Examples:** Show mod creators what valid data looks like
5. **Stress Testing:** Generate large mods to test performance
6. **Development:** Populate empty mods quickly

**Generation Strategies:**
- **Minimal:** One entity per type, minimal fields
- **Coverage:** Ensure all enums/types tested
- **Stress:** Large volume for performance testing
- **Realistic:** Game-balanced values
- **Edge:** Edge cases (min/max, empty, etc.)

**Future Enhancements:**
- Template-based generation (custom patterns)
- Import from existing mods (learn patterns)
- Balance-aware generation (realistic stats)
- Visual generator UI
- Export to multiple formats (JSON, CSV)

---

## Blockers

**Must have:**
- [ ] TASK-001 completed (GAME_API.toml exists)
- [ ] TOML encoder available

**Potential issues:**
- Complex cross-references might be hard to resolve
- Some field types might need special handling
- Performance with large stress test generation

---

## Review Checklist

- [ ] All field types generate correctly
- [ ] All entity types covered
- [ ] Cross-references are valid
- [ ] Generated data validates
- [ ] Generated data loads in engine
- [ ] Documentation complete
- [ ] VS Code tasks work
- [ ] Tests pass
- [ ] Code follows best practices

---

## Success Criteria

**Task is DONE when:**
1. Generator exists and runs
2. Can generate complete mods
3. Generated data validates (TASK-002)
4. Generated data loads in engine
5. All strategies work
6. Test fixtures work in tests
7. Documentation complete
8. VS Code tasks functional
9. Manual testing successful

**This enables:**
- Fast test data creation
- Complete API coverage testing
- Quick prototyping
- Example data for mod creators
- Stress testing
- Validation of GAME_API.toml completeness
