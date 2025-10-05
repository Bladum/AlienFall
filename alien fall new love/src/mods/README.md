# Mod System Directory - Comprehensive Modding Infrastructure

## Overview

The `mod_system/` directory contains the complete modding infrastructure for Alien Fall. This system provides comprehensive mod support with content merging, dependency resolution, validation, and runtime loading capabilities.

## Core Mod System Components

### Content Loading

#### `loader.lua`

**Purpose**: Main mod loading orchestration

- Mod discovery and loading order
- Dependency resolution
- Content merging and overriding
- Error handling and rollback

**GROK**: Mod loader - modify loading order for custom mod priorities

#### `directory_scanner.lua`

**Purpose**: Filesystem scanning for mod content

- Recursive directory traversal
- File type detection and categorization
- Mod structure validation
- Content indexing

**GROK**: File scanner - extend for new mod file types

### Content Processing

#### `content_detector.lua`

**Purpose**: Content type detection and classification

- TOML file parsing and validation
- Content type inference from structure
- Metadata extraction
- Compatibility checking

**GROK**: Content detection - add new content types for mods

#### `catalog_merger.lua`

**Purpose**: Content merging and conflict resolution

- Catalog merging strategies
- Override handling
- Conflict detection and resolution
- Content validation

**GROK**: Content merger - customize merge strategies for different content types

### Runtime Systems

#### `hook_runner.lua`

**Purpose**: Runtime mod hook execution

- Event-driven hook system
- Hook registration and execution
- Parameter passing and return values
- Error isolation

**GROK**: Hook system - add new hook points for mod extensibility

#### `validator.lua`

**Purpose**: Mod content validation and integrity checking

- Schema validation
- Cross-reference checking
- Dependency validation
- Content integrity verification

**GROK**: Validator - extend validation rules for new content types

## Mod Architecture

### Mod Structure

Mods follow standardized directory structure:

```
mods/
  example_mod/
    main.toml          # Mod metadata and configuration
    data/              # Game content files
      units/
      items/
      missions/
    assets/            # Graphics, sounds, etc.
    scripts/           # Lua scripts (if needed)
    README.md          # Mod documentation
```

### Mod Loading Pipeline

Complete loading process with error handling:

```lua
ModSystem = class()

function ModSystem:loadMods()
    -- Phase 1: Discovery
    local modList = self.scanner:scanModDirectory()

    -- Phase 2: Dependency resolution
    local loadOrder = self:resolveDependencies(modList)

    -- Phase 3: Validation
    for _, modInfo in ipairs(loadOrder) do
        if not self.validator:validateMod(modInfo) then
            self:handleValidationError(modInfo)
        end
    end

    -- Phase 4: Loading
    for _, modInfo in ipairs(loadOrder) do
        self:loadModContent(modInfo)
    end

    -- Phase 5: Integration
    self.merger:mergeAllContent()
end
```

### Content Merging Strategies

Different merge strategies for different content types:

```lua
ContentMerger = class()

function ContentMerger:mergeCatalogs(baseCatalog, modCatalog, strategy)
    if strategy == "override" then
        return self:mergeOverride(baseCatalog, modCatalog)
    elseif strategy == "additive" then
        return self:mergeAdditive(baseCatalog, modCatalog)
    elseif strategy == "replace" then
        return self:mergeReplace(baseCatalog, modCatalog)
    end
end

function ContentMerger:mergeOverride(base, mod)
    local result = table.deepcopy(base)
    for key, value in pairs(mod) do
        result[key] = value  -- Mod content overrides base
    end
    return result
end
```

## Hook System

### Runtime Extensibility

Hooks allow mods to extend game behavior:

```lua
-- Hook definition
hooks = {
    "unit:created",
    "mission:generated",
    "research:completed",
    "combat:resolved"
}

-- Hook execution
function HookRunner:executeHook(hookName, parameters)
    local handlers = self.registeredHooks[hookName] or {}

    for _, handler in ipairs(handlers) do
        local success, result = pcall(handler, parameters)
        if not success then
            self:handleHookError(hookName, handler, result)
        end
    end

    return parameters  -- Modified parameters
end
```

### Mod API

Mods can register hooks and extend functionality:

```lua
-- Example mod hook registration
function MyMod:init()
    hookRunner:registerHook("unit:created", function(unit)
        -- Add custom unit initialization
        if unit.type == "custom_unit" then
            unit.customProperty = "value"
        end
        return unit
    end)
end
```

## Validation System

### Content Validation

Comprehensive validation of mod content:

```lua
ModValidator = class()

function ModValidator:validateMod(modInfo)
    local errors = {}

    -- Check required files
    if not modInfo.mainFile then
        table.insert(errors, "Missing main.toml file")
    end

    -- Validate content structure
    for contentType, content in pairs(modInfo.content) do
        local typeErrors = self:validateContentType(contentType, content)
        for _, error in ipairs(typeErrors) do
            table.insert(errors, error)
        end
    end

    -- Check dependencies
    local depErrors = self:validateDependencies(modInfo)
    for _, error in ipairs(depErrors) do
        table.insert(errors, error)
    end

    return #errors == 0, errors
end
```

### Cross-Reference Validation

Ensure mod content references exist:

```lua
function ModValidator:validateCrossReferences(modContent, allContent)
    local errors = {}

    for _, unit in pairs(modContent.units or {}) do
        -- Check weapon references
        if unit.weapon and not allContent.items[unit.weapon] then
            table.insert(errors, "Unit " .. unit.id .. " references unknown weapon " .. unit.weapon)
        end

        -- Check armor references
        if unit.armor and not allContent.items[unit.armor] then
            table.insert(errors, "Unit " .. unit.id .. " references unknown armor " .. unit.armor)
        end
    end

    return errors
end
```

## Dependency Resolution

### Mod Dependencies

Handle complex mod interdependencies:

```lua
DependencyResolver = class()

function DependencyResolver:resolveDependencies(mods)
    local resolved = {}
    local visiting = {}
    local visited = {}

    for _, mod in ipairs(mods) do
        if not visited[mod.id] then
            self:resolveModDependencies(mod, mods, resolved, visiting, visited)
        end
    end

    return resolved
end

function DependencyResolver:resolveModDependencies(mod, allMods, resolved, visiting, visited)
    visiting[mod.id] = true

    for _, depId in ipairs(mod.dependencies or {}) do
        if visiting[depId] then
            error("Circular dependency detected: " .. mod.id .. " -> " .. depId)
        end

        if not visited[depId] then
            local depMod = self:findModById(allMods, depId)
            if depMod then
                self:resolveModDependencies(depMod, allMods, resolved, visiting, visited)
            else
                error("Missing dependency: " .. depId .. " required by " .. mod.id)
            end
        end
    end

    visiting[mod.id] = nil
    visited[mod.id] = true
    table.insert(resolved, mod)
end
```

## Testing Strategy

### Mod Loading Testing

Mod system tested for reliability:

- Loading order validation
- Dependency resolution testing
- Content merging verification
- Error handling validation

### Content Validation Testing

Mod content tested for correctness:

- Schema validation testing
- Cross-reference checking
- Dependency validation
- Runtime integration testing

## Development Guidelines

### Creating New Mod Content Types

1. **GROK**: Define content schema and validation rules
2. **GROK**: Implement content detection logic
3. **GROK**: Add merging strategy for the content type
4. **GROK**: Update validation system
5. **GROK**: Test with sample mod content

### Hook System Extension

- **GROK**: Identify extension points in game systems
- **GROK**: Define hook signatures and parameters
- **GROK**: Implement hook execution in appropriate places
- **GROK**: Document hook API for modders
- **GROK**: Test hook execution and error handling

### Validation Rule Development

- **GROK**: Define validation requirements for new content
- **GROK**: Implement validation logic
- **GROK**: Add appropriate error messages
- **GROK**: Test validation with valid and invalid content
- **GROK**: Ensure validation performance

### Dependency Management

- **GROK**: Design dependency declaration format
- **GROK**: Implement resolution algorithm
- **GROK**: Handle circular dependency detection
- **GROK**: Test complex dependency scenarios
- **GROK**: Provide clear error messages for dependency issues