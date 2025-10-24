# Task: Validate Mod Content Internal Consistency

**Status:** TODO
**Priority:** High
**Created:** 2025-10-24
**Completed:** N/A
**Assigned To:** AI Agent

**Dependencies:** None (can run independently of API validation)

---

## Overview

Create content validator that checks if mod content is internally consistent. Validates that all references within mod point to existing entities and that all referenced assets (images, audio, files) actually exist.

---

## Purpose

**Why this is needed:**
- Mod references non-existent technologies
- Units require items that don't exist in mod
- Tilesets reference missing PNG files
- Research requires techs that aren't defined
- Audio files referenced but missing
- Manufacturing requires items not in mod
- Facilities require techs that don't exist
- Missions reference maps that aren't defined
- Silent failures at runtime
- Confusing errors for mod creators

**What problem it solves:**
- Catches broken references before runtime
- Validates asset file existence
- Ensures tech tree is complete (no dangling dependencies)
- Ensures missions have all required data
- Ensures units have valid equipment
- Generates comprehensive report of issues
- Helps mod creators fix problems
- Prevents game crashes from missing content

**Difference from TASK-002:**
- TASK-002 validates against GAME_API.toml (structure/types)
- This task validates within mod itself (references/assets)
- Complementary validators

---

## Requirements

### Functional Requirements

#### Reference Validation
- [ ] Unit references to items (weapons, armor) - check items exist
- [ ] Unit references to races - check races exist
- [ ] Unit unlock requirements (techs) - check techs exist
- [ ] Item unlock requirements (techs) - check techs exist
- [ ] Research prerequisites - check prerequisite techs exist
- [ ] Research unlock (techs, items, units) - check entities exist
- [ ] Manufacturing requirements (items, techs) - check entities exist
- [ ] Facility requirements (techs) - check techs exist
- [ ] Mission requirements (units, items, maps) - check entities exist
- [ ] Craft requirements (weapons, items) - check entities exist
- [ ] Alien deployment (units, items) - check entities exist
- [ ] Region/country references - check existence
- [ ] Event triggers (entities) - check entities exist

#### Asset Validation
- [ ] Sprite/texture files exist (PNG, JPG)
- [ ] Audio files exist (OGG, WAV, MP3)
- [ ] Map files exist (if referenced)
- [ ] Tileset images exist
- [ ] UI asset files exist
- [ ] Font files exist (if custom fonts)
- [ ] Any other referenced files

#### Tech Tree Validation
- [ ] No circular dependencies in research
- [ ] Starting techs exist
- [ ] All tech prerequisites form valid tree
- [ ] No unreachable techs (orphaned)
- [ ] Tech costs are sane (not negative, not zero unless intended)

#### Mission/Map Validation
- [ ] Mission maps reference valid tilesets
- [ ] Tilesets reference valid mapblocks
- [ ] Mapblocks reference valid terrain
- [ ] Alien deployment has valid units
- [ ] Loot tables reference valid items

#### Balance Sanity Checks (Warnings)
- [ ] Items with zero cost (suspicious)
- [ ] Units with zero health (broken)
- [ ] Weapons with no damage (useless)
- [ ] Research with no time (instant, suspicious)
- [ ] Manufacturing with no time (instant, suspicious)
- [ ] Negative values where shouldn't be

### Technical Requirements
- [ ] Written in Lua
- [ ] Can run standalone: `lovec tools/validators/validate_content.lua mods/core`
- [ ] Can validate specific categories
- [ ] Detailed error reports with entity IDs and line numbers
- [ ] Warning reports for suspicious but not invalid data
- [ ] Summary statistics
- [ ] Exit code 0 if valid, non-zero if errors
- [ ] JSON output mode for CI/CD
- [ ] Verbose mode for debugging

### Acceptance Criteria
- [ ] Validator catches all reference types
- [ ] Validator checks all asset file types
- [ ] Validator detects circular dependencies
- [ ] Validator detects orphaned tech tree branches
- [ ] Generates clear, actionable error messages
- [ ] Documentation explains all error types
- [ ] Returns proper exit codes
- [ ] Works on all mod folders
- [ ] Performance acceptable for large mods

---

## Plan

### Step 1: Create Content Validator Structure
**Description:** Set up validator script framework

**Files to create:**
- `tools/validators/validate_content.lua` - main entry point
- `tools/validators/lib/content_loader.lua` - loads all mod TOML files
- `tools/validators/lib/reference_validator.lua` - validates entity references
- `tools/validators/lib/asset_validator.lua` - validates file existence
- `tools/validators/lib/tech_tree_validator.lua` - validates tech dependencies
- `tools/validators/lib/balance_validator.lua` - sanity checks
- `tools/validators/lib/report_generator.lua` - reuse from TASK-002

**CLI interface:**
```bash
# Validate entire mod
lovec tools/validators/validate_content.lua mods/core

# Validate specific category
lovec tools/validators/validate_content.lua mods/core --category research

# Verbose mode
lovec tools/validators/validate_content.lua mods/core --verbose

# JSON output
lovec tools/validators/validate_content.lua mods/core --json

# Only check references (skip assets)
lovec tools/validators/validate_content.lua mods/core --skip-assets

# Only check assets (skip references)
lovec tools/validators/validate_content.lua mods/core --only-assets
```

**Estimated time:** 2-3 hours

---

### Step 2: Implement Content Loader
**Description:** Load all TOML files and build entity registry

**File:** `tools/validators/lib/content_loader.lua`

**Functions:**
```lua
local ContentLoader = {}

-- Load entire mod into memory
function ContentLoader.loadMod(modPath)
  local mod = {
    units = {},
    items = {},
    weapons = {},
    armor = {},
    crafts = {},
    facilities = {},
    research = {},
    manufacturing = {},
    missions = {},
    ufos = {},
    aliens = {},
    regions = {},
    countries = {},
    events = {},
    pilots = {},
    perks = {},
    tilesets = {},
    mapblocks = {},
  }

  -- Scan and load each category
  for category, _ in pairs(mod) do
    mod[category] = ContentLoader.loadCategory(modPath, category)
  end

  return mod
end

-- Load all files from specific category
function ContentLoader.loadCategory(modPath, category)
  local entities = {}
  local categoryPath = modPath .. "/rules/" .. category

  -- Find all TOML files
  local files = scanDirectory(categoryPath, "*.toml")

  for _, filePath in ipairs(files) do
    local data, err = loadTOML(filePath)

    if data then
      entities[data.id] = {
        data = data,
        file = filePath,
        category = category,
      }
    else
      print("[ERROR] Failed to load " .. filePath .. ": " .. err)
    end
  end

  return entities
end

-- Build entity ID index for fast lookups
function ContentLoader.buildIndex(mod)
  local index = {
    byId = {},
    byCategory = mod,
  }

  for category, entities in pairs(mod) do
    for entityId, entity in pairs(entities) do
      index.byId[entityId] = {
        entity = entity,
        category = category,
      }
    end
  end

  return index
end
```

**Estimated time:** 3-4 hours

---

### Step 3: Implement Reference Validator
**Description:** Check all entity references are valid

**File:** `tools/validators/lib/reference_validator.lua`

**Reference types to check:**
```lua
local ReferenceValidator = {}

function ReferenceValidator.validate(mod, index)
  local errors = {}

  -- Validate each category
  table.insert(errors, ReferenceValidator.validateUnits(mod.units, index))
  table.insert(errors, ReferenceValidator.validateItems(mod.items, index))
  table.insert(errors, ReferenceValidator.validateResearch(mod.research, index))
  table.insert(errors, ReferenceValidator.validateManufacturing(mod.manufacturing, index))
  table.insert(errors, ReferenceValidator.validateFacilities(mod.facilities, index))
  table.insert(errors, ReferenceValidator.validateMissions(mod.missions, index))
  table.insert(errors, ReferenceValidator.validateCrafts(mod.crafts, index))
  table.insert(errors, ReferenceValidator.validateAliens(mod.aliens, index))

  return flatten(errors)
end

-- Validate unit references
function ReferenceValidator.validateUnits(units, index)
  local errors = {}

  for unitId, unit in pairs(units) do
    local data = unit.data

    -- Check race exists
    if data.race and not index.byId[data.race] then
      table.insert(errors, {
        entity = unitId,
        file = unit.file,
        field = "race",
        reference = data.race,
        message = "Unit references non-existent race: " .. data.race,
      })
    end

    -- Check starting armor exists
    if data.armor and not index.byId[data.armor] then
      table.insert(errors, {
        entity = unitId,
        file = unit.file,
        field = "armor",
        reference = data.armor,
        message = "Unit references non-existent armor: " .. data.armor,
      })
    end

    -- Check required tech exists
    if data.requires then
      for _, techId in ipairs(data.requires) do
        if not index.byId[techId] then
          table.insert(errors, {
            entity = unitId,
            file = unit.file,
            field = "requires",
            reference = techId,
            message = "Unit requires non-existent tech: " .. techId,
          })
        end
      end
    end

    -- Check starting items exist
    if data.starting_equipment then
      for _, itemId in ipairs(data.starting_equipment) do
        if not index.byId[itemId] then
          table.insert(errors, {
            entity = unitId,
            file = unit.file,
            field = "starting_equipment",
            reference = itemId,
            message = "Unit references non-existent item: " .. itemId,
          })
        end
      end
    end
  end

  return errors
end

-- Validate item references
function ReferenceValidator.validateItems(items, index)
  local errors = {}

  for itemId, item in pairs(items) do
    local data = item.data

    -- Check required tech
    if data.requires then
      for _, techId in ipairs(data.requires) do
        if not index.byId[techId] then
          table.insert(errors, {
            entity = itemId,
            file = item.file,
            field = "requires",
            reference = techId,
            message = "Item requires non-existent tech: " .. techId,
          })
        end
      end
    end

    -- Check ammo reference (for weapons)
    if data.ammo and not index.byId[data.ammo] then
      table.insert(errors, {
        entity = itemId,
        file = item.file,
        field = "ammo",
        reference = data.ammo,
        message = "Weapon references non-existent ammo: " .. data.ammo,
      })
    end
  end

  return errors
end

-- Validate research references
function ReferenceValidator.validateResearch(research, index)
  local errors = {}

  for researchId, researchData in pairs(research) do
    local data = researchData.data

    -- Check prerequisites exist
    if data.requires then
      for _, prerequisiteId in ipairs(data.requires) do
        if not index.byId[prerequisiteId] then
          table.insert(errors, {
            entity = researchId,
            file = researchData.file,
            field = "requires",
            reference = prerequisiteId,
            message = "Research requires non-existent tech: " .. prerequisiteId,
          })
        end
      end
    end

    -- Check unlocked items exist
    if data.unlocks_items then
      for _, itemId in ipairs(data.unlocks_items) do
        if not index.byId[itemId] then
          table.insert(errors, {
            entity = researchId,
            file = researchData.file,
            field = "unlocks_items",
            reference = itemId,
            message = "Research unlocks non-existent item: " .. itemId,
          })
        end
      end
    end

    -- Check unlocked units exist
    if data.unlocks_units then
      for _, unitId in ipairs(data.unlocks_units) do
        if not index.byId[unitId] then
          table.insert(errors, {
            entity = researchId,
            file = researchData.file,
            field = "unlocks_units",
            reference = unitId,
            message = "Research unlocks non-existent unit: " .. unitId,
          })
        end
      end
    end
  end

  return errors
end

-- Validate manufacturing references
function ReferenceValidator.validateManufacturing(manufacturing, index)
  local errors = {}

  for manufactureId, manufactureData in pairs(manufacturing) do
    local data = manufactureData.data

    -- Check produces item exists
    if data.produces and not index.byId[data.produces] then
      table.insert(errors, {
        entity = manufactureId,
        file = manufactureData.file,
        field = "produces",
        reference = data.produces,
        message = "Manufacturing produces non-existent item: " .. data.produces,
      })
    end

    -- Check required items exist
    if data.requires_items then
      for itemId, quantity in pairs(data.requires_items) do
        if not index.byId[itemId] then
          table.insert(errors, {
            entity = manufactureId,
            file = manufactureData.file,
            field = "requires_items",
            reference = itemId,
            message = "Manufacturing requires non-existent item: " .. itemId,
          })
        end
      end
    end

    -- Check required tech exists
    if data.requires_tech then
      for _, techId in ipairs(data.requires_tech) do
        if not index.byId[techId] then
          table.insert(errors, {
            entity = manufactureId,
            file = manufactureData.file,
            field = "requires_tech",
            reference = techId,
            message = "Manufacturing requires non-existent tech: " .. techId,
          })
        end
      end
    end
  end

  return errors
end

-- Similar functions for facilities, missions, crafts, aliens, etc.
```

**Estimated time:** 6-8 hours (many reference types to check)

---

### Step 4: Implement Asset Validator
**Description:** Check all referenced files exist

**File:** `tools/validators/lib/asset_validator.lua`

**Asset checks:**
```lua
local AssetValidator = {}

function AssetValidator.validate(mod, modPath)
  local errors = {}

  -- Check all entity types for asset references
  for category, entities in pairs(mod) do
    for entityId, entity in pairs(entities) do
      local assetErrors = AssetValidator.checkEntityAssets(entity, modPath)
      for _, err in ipairs(assetErrors) do
        table.insert(errors, err)
      end
    end
  end

  return errors
end

function AssetValidator.checkEntityAssets(entity, modPath)
  local errors = {}
  local data = entity.data

  -- Common asset fields to check
  local assetFields = {
    "sprite",
    "sprite_sheet",
    "image",
    "icon",
    "texture",
    "sound",
    "sound_fire",
    "sound_hit",
    "sound_reload",
    "sound_ambient",
    "music",
    "portrait",
    "tileset_image",
    "map_image",
  }

  for _, fieldName in ipairs(assetFields) do
    if data[fieldName] then
      local assetPath = modPath .. "/" .. data[fieldName]

      if not AssetValidator.fileExists(assetPath) then
        table.insert(errors, {
          entity = entity.data.id,
          file = entity.file,
          field = fieldName,
          asset = data[fieldName],
          message = "Referenced asset file does not exist: " .. data[fieldName],
        })
      end
    end
  end

  -- Check arrays of assets
  if data.sprites then
    for i, spritePath in ipairs(data.sprites) do
      local assetPath = modPath .. "/" .. spritePath

      if not AssetValidator.fileExists(assetPath) then
        table.insert(errors, {
          entity = entity.data.id,
          file = entity.file,
          field = "sprites[" .. i .. "]",
          asset = spritePath,
          message = "Referenced sprite file does not exist: " .. spritePath,
        })
      end
    end
  end

  -- Check sounds array
  if data.sounds then
    for soundType, soundPath in pairs(data.sounds) do
      local assetPath = modPath .. "/" .. soundPath

      if not AssetValidator.fileExists(assetPath) then
        table.insert(errors, {
          entity = entity.data.id,
          file = entity.file,
          field = "sounds." .. soundType,
          asset = soundPath,
          message = "Referenced sound file does not exist: " .. soundPath,
        })
      end
    end
  end

  return errors
end

function AssetValidator.fileExists(filePath)
  -- Try to open file
  local file = io.open(filePath, "r")

  if file then
    file:close()
    return true
  else
    return false
  end
end
```

**Estimated time:** 4-5 hours

---

### Step 5: Implement Tech Tree Validator
**Description:** Validate research dependencies form valid tree

**File:** `tools/validators/lib/tech_tree_validator.lua`

**Checks:**
```lua
local TechTreeValidator = {}

function TechTreeValidator.validate(research, index)
  local errors = {}
  local warnings = {}

  -- Build dependency graph
  local graph = TechTreeValidator.buildGraph(research)

  -- Check for circular dependencies
  local circularDeps = TechTreeValidator.findCircularDependencies(graph, research)
  for _, cycle in ipairs(circularDeps) do
    table.insert(errors, {
      type = "circular_dependency",
      techs = cycle,
      message = "Circular dependency detected: " .. table.concat(cycle, " -> "),
    })
  end

  -- Check for orphaned techs (unreachable from starting techs)
  local orphaned = TechTreeValidator.findOrphanedTechs(graph, research, index)
  for _, techId in ipairs(orphaned) do
    table.insert(warnings, {
      type = "orphaned_tech",
      tech = techId,
      message = "Tech is unreachable (no path from starting techs): " .. techId,
    })
  end

  -- Check for starting techs that don't exist
  local missingStart = TechTreeValidator.checkStartingTechs(research, index)
  for _, techId in ipairs(missingStart) do
    table.insert(errors, {
      type = "missing_starting_tech",
      tech = techId,
      message = "Starting tech does not exist: " .. techId,
    })
  end

  return errors, warnings
end

function TechTreeValidator.buildGraph(research)
  local graph = {}

  for techId, techData in pairs(research) do
    graph[techId] = {
      prerequisites = techData.data.requires or {},
      unlocks = {},
    }
  end

  -- Build reverse edges (what each tech unlocks)
  for techId, node in pairs(graph) do
    for _, prerequisiteId in ipairs(node.prerequisites) do
      if graph[prerequisiteId] then
        table.insert(graph[prerequisiteId].unlocks, techId)
      end
    end
  end

  return graph
end

function TechTreeValidator.findCircularDependencies(graph, research)
  local cycles = {}
  local visited = {}
  local recursionStack = {}

  local function dfs(techId, path)
    if recursionStack[techId] then
      -- Found cycle
      local cycleStart = nil
      for i, id in ipairs(path) do
        if id == techId then
          cycleStart = i
          break
        end
      end

      if cycleStart then
        local cycle = {}
        for i = cycleStart, #path do
          table.insert(cycle, path[i])
        end
        table.insert(cycle, techId) -- close the cycle
        table.insert(cycles, cycle)
      end

      return
    end

    if visited[techId] then
      return
    end

    visited[techId] = true
    recursionStack[techId] = true
    table.insert(path, techId)

    local node = graph[techId]
    if node then
      for _, prerequisiteId in ipairs(node.prerequisites) do
        dfs(prerequisiteId, path)
      end
    end

    table.remove(path)
    recursionStack[techId] = false
  end

  for techId, _ in pairs(graph) do
    if not visited[techId] then
      dfs(techId, {})
    end
  end

  return cycles
end

function TechTreeValidator.findOrphanedTechs(graph, research, index)
  -- Find all techs reachable from starting techs
  local startingTechs = TechTreeValidator.getStartingTechs(research, index)
  local reachable = {}

  local function dfs(techId)
    if reachable[techId] then
      return
    end

    reachable[techId] = true

    local node = graph[techId]
    if node then
      for _, unlockedTech in ipairs(node.unlocks) do
        dfs(unlockedTech)
      end
    end
  end

  for _, startTechId in ipairs(startingTechs) do
    dfs(startTechId)
  end

  -- Find orphaned techs (not reachable)
  local orphaned = {}
  for techId, _ in pairs(research) do
    if not reachable[techId] then
      table.insert(orphaned, techId)
    end
  end

  return orphaned
end

function TechTreeValidator.getStartingTechs(research, index)
  -- Techs with no prerequisites are starting techs
  local starting = {}

  for techId, techData in pairs(research) do
    local prereqs = techData.data.requires or {}

    if #prereqs == 0 then
      table.insert(starting, techId)
    end
  end

  return starting
end
```

**Estimated time:** 5-6 hours

---

### Step 6: Implement Balance Validator
**Description:** Sanity checks for suspicious values

**File:** `tools/validators/lib/balance_validator.lua`

**Sanity checks:**
```lua
local BalanceValidator = {}

function BalanceValidator.validate(mod)
  local warnings = {}

  -- Check units
  for unitId, unit in pairs(mod.units) do
    local data = unit.data

    if data.stats then
      -- Health should not be zero or negative
      if data.stats.health and data.stats.health <= 0 then
        table.insert(warnings, {
          entity = unitId,
          file = unit.file,
          field = "stats.health",
          value = data.stats.health,
          message = "Unit has zero or negative health",
        })
      end

      -- Time units should not be zero
      if data.stats.time_units and data.stats.time_units <= 0 then
        table.insert(warnings, {
          entity = unitId,
          file = unit.file,
          field = "stats.time_units",
          value = data.stats.time_units,
          message = "Unit has zero or negative time units",
        })
      end

      -- Suspiciously high values
      if data.stats.health and data.stats.health > 999 then
        table.insert(warnings, {
          entity = unitId,
          file = unit.file,
          field = "stats.health",
          value = data.stats.health,
          message = "Unit health suspiciously high (>999)",
        })
      end
    end
  end

  -- Check items/weapons
  for itemId, item in pairs(mod.items) do
    local data = item.data

    -- Zero cost items (suspicious unless intentional)
    if data.cost and data.cost == 0 then
      table.insert(warnings, {
        entity = itemId,
        file = item.file,
        field = "cost",
        value = 0,
        message = "Item has zero cost (intentional?)",
      })
    end

    -- Weapon with no damage
    if data.type == "weapon" and data.damage and data.damage == 0 then
      table.insert(warnings, {
        entity = itemId,
        file = item.file,
        field = "damage",
        value = 0,
        message = "Weapon has zero damage",
      })
    end

    -- Negative values
    if data.weight and data.weight < 0 then
      table.insert(warnings, {
        entity = itemId,
        file = item.file,
        field = "weight",
        value = data.weight,
        message = "Item has negative weight",
      })
    end
  end

  -- Check research
  for researchId, researchData in pairs(mod.research) do
    local data = researchData.data

    -- Zero time research (instant, suspicious)
    if data.time and data.time == 0 then
      table.insert(warnings, {
        entity = researchId,
        file = researchData.file,
        field = "time",
        value = 0,
        message = "Research has zero time (instant research)",
      })
    end

    -- Zero cost research
    if data.cost and data.cost == 0 then
      table.insert(warnings, {
        entity = researchId,
        file = researchData.file,
        field = "cost",
        value = 0,
        message = "Research has zero cost",
      })
    end
  end

  -- Check manufacturing
  for manufactureId, manufactureData in pairs(mod.manufacturing) do
    local data = manufactureData.data

    -- Zero time manufacturing
    if data.time and data.time == 0 then
      table.insert(warnings, {
        entity = manufactureId,
        file = manufactureData.file,
        field = "time",
        value = 0,
        message = "Manufacturing has zero time (instant production)",
      })
    end
  end

  return warnings
end
```

**Estimated time:** 3-4 hours

---

### Step 7: Implement Main Validator
**Description:** Orchestrate all validation checks

**File:** `tools/validators/validate_content.lua`

**Main logic:**
```lua
-- Parse arguments
local args = parseArgs(arg)

print("Content Validator - Checking mod internal consistency")
print("===================================================")
print("Mod: " .. args.modPath)
print("")

-- Load entire mod
print("Loading mod content...")
local mod = ContentLoader.loadMod(args.modPath)
local index = ContentLoader.buildIndex(mod)

-- Count entities
local totalEntities = 0
for _, entities in pairs(mod) do
  totalEntities = totalEntities + tableSize(entities)
end
print("Loaded " .. totalEntities .. " entities")
print("")

-- Run validations
local allErrors = {}
local allWarnings = {}

print("Validating entity references...")
local refErrors = ReferenceValidator.validate(mod, index)
append(allErrors, refErrors)
print("  Found " .. #refErrors .. " reference errors")

if not args.skipAssets then
  print("Validating asset files...")
  local assetErrors = AssetValidator.validate(mod, args.modPath)
  append(allErrors, assetErrors)
  print("  Found " .. #assetErrors .. " missing assets")
end

print("Validating tech tree...")
local techErrors, techWarnings = TechTreeValidator.validate(mod.research, index)
append(allErrors, techErrors)
append(allWarnings, techWarnings)
print("  Found " .. #techErrors .. " tech tree errors")
print("  Found " .. #techWarnings .. " tech tree warnings")

print("Running balance sanity checks...")
local balanceWarnings = BalanceValidator.validate(mod)
append(allWarnings, balanceWarnings)
print("  Found " .. #balanceWarnings .. " balance warnings")

-- Generate report
local report = {
  summary = {
    entitiesChecked = totalEntities,
    totalErrors = #allErrors,
    totalWarnings = #allWarnings,
  },
  errors = allErrors,
  warnings = allWarnings,
}

print("")
print("Generating report...")

if args.json then
  print(ReportGenerator.json(report))
else
  ReportGenerator.console(report, args.verbose)
end

-- Exit with appropriate code
if #allErrors > 0 then
  print("")
  print("❌ CONTENT VALIDATION FAILED - " .. #allErrors .. " errors found")
  os.exit(1)
else
  print("")
  print("✅ CONTENT VALIDATION PASSED")
  if #allWarnings > 0 then
    print("⚠ " .. #allWarnings .. " warnings found (not critical)")
  end
  os.exit(0)
end
```

**Estimated time:** 3-4 hours

---

### Step 8: Add VS Code Tasks
**Description:** Make content validator easy to run

**Tasks:**
```json
{
  "label": "🔍 VALIDATE: Content - Core Mod",
  "type": "shell",
  "command": "lovec",
  "args": ["tools/validators/validate_content.lua", "mods/core"]
},
{
  "label": "🔍 VALIDATE: Content - All Mods",
  "type": "shell",
  "command": "powershell",
  "args": [
    "-Command",
    "foreach ($mod in Get-ChildItem -Directory mods) { & lovec tools/validators/validate_content.lua $mod.FullName }"
  ]
}
```

**Estimated time:** 1 hour

---

### Step 9: Documentation
**Description:** Document content validator usage

**Add to:** `tools/validators/README.md`

**Must cover:**
- What content validation checks
- Difference from API validation (TASK-002)
- How to run content validator
- How to interpret errors
- Common errors and fixes
- Asset file organization
- Tech tree best practices

**Estimated time:** 2 hours

---

### Step 10: Testing
**Description:** Validate content validator works

**Test scenarios:**
- [ ] Detect missing item reference
- [ ] Detect missing tech reference
- [ ] Detect missing asset file
- [ ] Detect circular tech dependency
- [ ] Detect orphaned tech
- [ ] Detect zero health unit
- [ ] Detect negative cost item
- [ ] Valid mod passes
- [ ] Generate correct JSON output

**Create test fixtures:**
- `tests/fixtures/mods/valid_content/` - perfect mod
- `tests/fixtures/mods/broken_references/` - broken refs
- `tests/fixtures/mods/missing_assets/` - missing files
- `tests/fixtures/mods/circular_tech/` - circular deps

**Estimated time:** 4-5 hours

---

## Implementation Details

### Architecture

**Modular Validation:**
```
validate_content.lua
├── lib/content_loader.lua (load all mod files)
├── lib/reference_validator.lua (check entity refs)
├── lib/asset_validator.lua (check file existence)
├── lib/tech_tree_validator.lua (check tech deps)
├── lib/balance_validator.lua (sanity checks)
└── lib/report_generator.lua (reuse from TASK-002)
```

**Validation Types:**
1. **Reference Validation:** Entity IDs referenced exist
2. **Asset Validation:** Files referenced exist
3. **Tech Tree Validation:** Research forms valid DAG
4. **Balance Validation:** Values are sane

### Key Components

**ContentLoader:** Loads all TOML files into memory
**ReferenceValidator:** Checks entity references
**AssetValidator:** Checks file existence
**TechTreeValidator:** Checks tech dependencies
**BalanceValidator:** Sanity checks on values

### Dependencies

- TOML parser
- Filesystem access (io module)
- Graph algorithms (for cycle detection)

---

## Testing Strategy

### Unit Tests
- Test content loader
- Test reference checking
- Test asset checking
- Test cycle detection
- Test balance checks

### Integration Tests
- Test with fixture mods
- Test valid mod passes
- Test broken mod fails
- Test warning detection

### Manual Testing
- Run on mods/core
- Deliberately break references
- Remove asset files
- Create circular tech deps
- Check error messages

---

## Documentation Updates

### Files to Create
- [ ] `tools/validators/validate_content.lua`
- [ ] `tools/validators/lib/*.lua`

### Files to Update
- [ ] `tools/validators/README.md` - add content validation docs
- [ ] `tools/README.md` - mention content validator
- [ ] `.vscode/tasks.json` - add tasks
- [ ] `api/MODDING_GUIDE.md` - mention content validation

---

## Notes

**Validation Levels:**
- **Errors:** Must fix (broken references, missing files)
- **Warnings:** Should review (suspicious values, orphaned content)

**Performance:**
- Load entire mod into memory (faster validation)
- Build index once (O(1) lookups)
- Acceptable for mods with 1000s of entities

**Future Enhancements:**
- Auto-fix broken references (suggest alternatives)
- Visualization of tech tree
- Balance analysis (detect OP items)
- Cross-mod validation (mod conflicts)

---

## Blockers

**Must have:**
- [ ] TOML parser
- [ ] File system access

**Potential issues:**
- Large mods might be slow to load
- Complex references might be hard to track
- Asset paths might vary by platform

---

## Review Checklist

- [ ] All reference types checked
- [ ] All asset types checked
- [ ] Tech tree validation works
- [ ] Balance checks appropriate
- [ ] Clear error messages
- [ ] Documentation complete
- [ ] VS Code tasks work
- [ ] Tests pass

---

## Success Criteria

**Task is DONE when:**
1. Content validator exists and runs
2. Detects all reference types
3. Detects missing assets
4. Detects circular dependencies
5. Detects orphaned content
6. Generates clear reports
7. Returns correct exit codes
8. Documentation complete
9. Tests pass
10. Manual validation successful

**This enables:**
- Catch broken mods early
- Faster mod development
- Better mod quality
- Clearer error messages
- CI/CD content validation
