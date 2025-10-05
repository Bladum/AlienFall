# Data Validation

## Table of Contents

1. [Overview](#overview)
2. [Validation Architecture](#validation-architecture)
3. [TOML Schema Validation](#toml-schema-validation)
4. [Type Checking](#type-checking)
5. [Dependency Validation](#dependency-validation)
6. [Error Reporting](#error-reporting)
7. [Hot-Reloading System](#hot-reloading-system)
8. [Debug Tools](#debug-tools)
9. [Implementation](#implementation)
10. [Cross-References](#cross-references)

---

## Overview

The Data Validation System ensures all TOML configuration files and mod data conform to expected schemas, preventing runtime errors and helping mod developers identify issues quickly. It provides comprehensive validation, detailed error messages, and hot-reloading capabilities for rapid development.

### Design Principles

1. **Fail Fast**: Detect errors at load time, not during gameplay
2. **Clear Errors**: Provide actionable error messages with line numbers
3. **Schema-Driven**: Define expected structure declaratively
4. **Developer-Friendly**: Tools to help mod creators debug issues
5. **Performance**: Validate once at load, cache results

### Key Features

- **TOML Schema Validation**: Define expected structure for all data files
- **Type Checking**: Verify field types (string, number, boolean, table)
- **Range Validation**: Ensure values fall within acceptable ranges
- **Reference Validation**: Check that IDs reference existing entities
- **Dependency Resolution**: Verify mod dependencies and load order
- **Hot-Reloading**: Reload data files without restarting the game
- **Error Context**: Show file, line number, and suggested fixes

---

## Validation Architecture

### System Components

```lua
-- Validation system structure
DataValidation = {
    schemas = {},           -- Registered schemas
    validators = {},        -- Custom validator functions
    errors = {},            -- Accumulated errors
    warnings = {},          -- Non-critical issues
    validated_files = {},   -- Cache of validated data
    hot_reload_enabled = false
}
```

### Validation Phases

```
1. Load Phase
   ├─ Parse TOML files
   ├─ Schema validation
   └─ Type checking

2. Reference Phase
   ├─ Resolve ID references
   ├─ Check cross-references
   └─ Validate relationships

3. Dependency Phase
   ├─ Mod dependency resolution
   ├─ Load order verification
   └─ Conflict detection

4. Semantic Phase
   ├─ Business logic validation
   ├─ Balance checks
   └─ Completeness verification
```

### Validation Levels

```lua
VALIDATION_LEVELS = {
    ERROR = 1,      -- Fatal: prevents game from running
    WARNING = 2,    -- Non-fatal: game runs but issues reported
    INFO = 3,       -- Informational: suggestions for improvement
    DEBUG = 4       -- Development: verbose validation info
}
```

---

## TOML Schema Validation

### Schema Definition

```lua
-- Define schema for an entity type
function define_schema(entity_type, schema)
    DataValidation.schemas[entity_type] = schema
end

-- Example: Unit schema
define_schema("unit", {
    required_fields = {
        "id",           -- Unique identifier
        "name",         -- Display name
        "stats",        -- Stats table
        "sprite"        -- Sprite path
    },
    optional_fields = {
        "description",
        "abilities",
        "starting_equipment",
        "cost"
    },
    nested_schemas = {
        stats = {
            required_fields = {
                "health", "time_units", "accuracy",
                "strength", "reactions", "bravery"
            },
            field_types = {
                health = "number",
                time_units = "number",
                accuracy = "number",
                strength = "number",
                reactions = "number",
                bravery = "number"
            },
            field_ranges = {
                health = {min = 1, max = 200},
                time_units = {min = 1, max = 100},
                accuracy = {min = 0, max = 150},
                strength = {min = 1, max = 100},
                reactions = {min = 0, max = 100},
                bravery = {min = 0, max = 100}
            }
        }
    },
    field_types = {
        id = "string",
        name = "string",
        sprite = "string",
        description = "string",
        abilities = "array",
        starting_equipment = "array",
        cost = "number"
    },
    field_patterns = {
        id = "^[a-z][a-z0-9_]*$",  -- lowercase, underscores
        sprite = "%.png$"            -- Must end in .png
    }
})
```

### Schema Validation Implementation

```lua
-- Validate data against schema
function validate_against_schema(data, schema, context)
    local errors = {}
    
    -- Check required fields
    for _, field in ipairs(schema.required_fields or {}) do
        if data[field] == nil then
            table.insert(errors, {
                level = VALIDATION_LEVELS.ERROR,
                message = "Missing required field: " .. field,
                context = context,
                suggestion = "Add '" .. field .. " = <value>' to the file"
            })
        end
    end
    
    -- Check field types
    for field, expected_type in pairs(schema.field_types or {}) do
        if data[field] ~= nil then
            local actual_type = type(data[field])
            if actual_type == "table" and expected_type == "array" then
                -- Arrays are tables in Lua
                if not is_array(data[field]) then
                    table.insert(errors, {
                        level = VALIDATION_LEVELS.ERROR,
                        message = "Field '" .. field .. "' should be an array, got table",
                        context = context
                    })
                end
            elseif actual_type ~= expected_type then
                table.insert(errors, {
                    level = VALIDATION_LEVELS.ERROR,
                    message = "Field '" .. field .. "' should be " .. expected_type .. ", got " .. actual_type,
                    context = context,
                    suggestion = "Change to: " .. field .. " = <" .. expected_type .. ">"
                })
            end
        end
    end
    
    -- Check field patterns (regex)
    for field, pattern in pairs(schema.field_patterns or {}) do
        if data[field] ~= nil and type(data[field]) == "string" then
            if not string.match(data[field], pattern) then
                table.insert(errors, {
                    level = VALIDATION_LEVELS.ERROR,
                    message = "Field '" .. field .. "' does not match pattern: " .. pattern,
                    context = context,
                    suggestion = "Value must match pattern: " .. pattern
                })
            end
        end
    end
    
    -- Check field ranges
    for field, range in pairs(schema.field_ranges or {}) do
        if data[field] ~= nil and type(data[field]) == "number" then
            if range.min and data[field] < range.min then
                table.insert(errors, {
                    level = VALIDATION_LEVELS.ERROR,
                    message = "Field '" .. field .. "' value " .. data[field] .. " below minimum " .. range.min,
                    context = context
                })
            end
            if range.max and data[field] > range.max then
                table.insert(errors, {
                    level = VALIDATION_LEVELS.ERROR,
                    message = "Field '" .. field .. "' value " .. data[field] .. " exceeds maximum " .. range.max,
                    context = context
                })
            end
        end
    end
    
    -- Validate nested schemas
    for field, nested_schema in pairs(schema.nested_schemas or {}) do
        if data[field] ~= nil then
            local nested_context = context .. "." .. field
            local nested_errors = validate_against_schema(data[field], nested_schema, nested_context)
            for _, err in ipairs(nested_errors) do
                table.insert(errors, err)
            end
        end
    end
    
    -- Check for unknown fields (warnings)
    local all_valid_fields = {}
    for _, f in ipairs(schema.required_fields or {}) do all_valid_fields[f] = true end
    for _, f in ipairs(schema.optional_fields or {}) do all_valid_fields[f] = true end
    
    for field, _ in pairs(data) do
        if not all_valid_fields[field] then
            table.insert(errors, {
                level = VALIDATION_LEVELS.WARNING,
                message = "Unknown field: " .. field,
                context = context,
                suggestion = "Remove this field or check for typos"
            })
        end
    end
    
    return errors
end
```

---

## Type Checking

### Type System

```lua
-- Supported data types
TYPE_DEFINITIONS = {
    string = function(value)
        return type(value) == "string"
    end,
    
    number = function(value)
        return type(value) == "number"
    end,
    
    integer = function(value)
        return type(value) == "number" and math.floor(value) == value
    end,
    
    boolean = function(value)
        return type(value) == "boolean"
    end,
    
    array = function(value)
        if type(value) ~= "table" then return false end
        -- Check if all keys are sequential integers starting from 1
        local count = 0
        for k, _ in pairs(value) do
            if type(k) ~= "number" or k < 1 or math.floor(k) ~= k then
                return false
            end
            count = count + 1
        end
        return count == #value
    end,
    
    table = function(value)
        return type(value) == "table"
    end,
    
    enum = function(value, allowed_values)
        for _, allowed in ipairs(allowed_values) do
            if value == allowed then return true end
        end
        return false
    end,
    
    reference = function(value, entity_type)
        -- Check if referenced entity exists
        return entity_exists(entity_type, value)
    end,
    
    color = function(value)
        -- Hex color: #RRGGBB or #RRGGBBAA
        return type(value) == "string" and 
               string.match(value, "^#%x%x%x%x%x%x%x?%x?$") ~= nil
    end,
    
    file_path = function(value)
        return type(value) == "string" and love.filesystem.getInfo(value) ~= nil
    end
}
```

### Type Validation

```lua
-- Validate field type
function validate_type(value, type_spec, field_name, context)
    if type(type_spec) == "string" then
        -- Simple type
        local validator = TYPE_DEFINITIONS[type_spec]
        if not validator then
            return {
                level = VALIDATION_LEVELS.ERROR,
                message = "Unknown type specification: " .. type_spec,
                context = context .. "." .. field_name
            }
        end
        
        if not validator(value) then
            return {
                level = VALIDATION_LEVELS.ERROR,
                message = "Field '" .. field_name .. "' expected type " .. type_spec .. ", got " .. type(value),
                context = context
            }
        end
        
    elseif type(type_spec) == "table" then
        -- Complex type with parameters
        if type_spec.type == "enum" then
            if not TYPE_DEFINITIONS.enum(value, type_spec.values) then
                return {
                    level = VALIDATION_LEVELS.ERROR,
                    message = "Field '" .. field_name .. "' must be one of: " .. table.concat(type_spec.values, ", "),
                    context = context,
                    suggestion = "Valid values: " .. table.concat(type_spec.values, ", ")
                }
            end
            
        elseif type_spec.type == "reference" then
            if not TYPE_DEFINITIONS.reference(value, type_spec.entity_type) then
                return {
                    level = VALIDATION_LEVELS.ERROR,
                    message = "Field '" .. field_name .. "' references non-existent " .. type_spec.entity_type .. ": " .. tostring(value),
                    context = context,
                    suggestion = "Ensure the referenced " .. type_spec.entity_type .. " is defined"
                }
            end
            
        elseif type_spec.type == "array_of" then
            if not TYPE_DEFINITIONS.array(value) then
                return {
                    level = VALIDATION_LEVELS.ERROR,
                    message = "Field '" .. field_name .. "' should be an array",
                    context = context
                }
            end
            
            -- Validate each element
            for i, element in ipairs(value) do
                local elem_error = validate_type(element, type_spec.element_type, field_name .. "[" .. i .. "]", context)
                if elem_error then return elem_error end
            end
        end
    end
    
    return nil -- No error
end
```

### Example Type Specifications

```lua
-- Weapon schema with complex types
define_schema("weapon", {
    required_fields = {"id", "name", "damage", "range", "accuracy_modifier", "fire_mode"},
    field_types = {
        id = "string",
        name = "string",
        damage = {type = "array_of", element_type = "integer"},
        range = "integer",
        accuracy_modifier = "integer",
        fire_mode = {type = "enum", values = {"snap", "auto", "aimed"}},
        ammo_type = {type = "reference", entity_type = "ammo"},
        sprite = "file_path",
        color = "color"
    }
})
```

---

## Dependency Validation

### Mod Dependency System

```lua
-- Mod manifest structure
mod_manifest = {
    id = "example_mod",
    version = "1.0.0",
    dependencies = {
        {id = "base_game", version = ">=1.0.0"},
        {id = "core_expansion", version = "~1.2.0"}
    },
    load_order = 100,  -- Higher = loads later
    conflicts = {"incompatible_mod"}
}
```

### Dependency Resolution

```lua
-- Validate mod dependencies
function validate_mod_dependencies(mod)
    local errors = {}
    
    for _, dep in ipairs(mod.dependencies or {}) do
        local dep_mod = find_mod(dep.id)
        
        if not dep_mod then
            table.insert(errors, {
                level = VALIDATION_LEVELS.ERROR,
                message = "Missing required dependency: " .. dep.id,
                context = "mod:" .. mod.id,
                suggestion = "Install mod '" .. dep.id .. "' or remove it from dependencies"
            })
        else
            -- Check version compatibility
            if not version_satisfies(dep_mod.version, dep.version) then
                table.insert(errors, {
                    level = VALIDATION_LEVELS.ERROR,
                    message = "Dependency '" .. dep.id .. "' version mismatch. Required: " .. dep.version .. ", Found: " .. dep_mod.version,
                    context = "mod:" .. mod.id,
                    suggestion = "Update '" .. dep.id .. "' to version " .. dep.version
                })
            end
        end
    end
    
    -- Check for conflicts
    for _, conflict_id in ipairs(mod.conflicts or {}) do
        local conflict_mod = find_mod(conflict_id)
        if conflict_mod and conflict_mod.enabled then
            table.insert(errors, {
                level = VALIDATION_LEVELS.ERROR,
                message = "Mod '" .. mod.id .. "' conflicts with '" .. conflict_id .. "'",
                context = "mod:" .. mod.id,
                suggestion = "Disable one of the conflicting mods"
            })
        end
    end
    
    return errors
end

-- Version comparison (semantic versioning)
function version_satisfies(version, requirement)
    -- Simple version checking
    -- Supports: "1.0.0", ">=1.0.0", "~1.2.0" (compatible with 1.2.x)
    
    if string.sub(requirement, 1, 2) == ">=" then
        local min_version = string.sub(requirement, 3)
        return compare_versions(version, min_version) >= 0
    elseif string.sub(requirement, 1, 1) == "~" then
        local base_version = string.sub(requirement, 2)
        local major, minor = parse_version(base_version)
        local v_major, v_minor = parse_version(version)
        return v_major == major and v_minor == minor
    else
        return version == requirement
    end
end
```

### Load Order Resolution

```lua
-- Calculate mod load order
function calculate_load_order(mods)
    local sorted = {}
    local visited = {}
    local visiting = {}
    
    -- Topological sort (dependencies first)
    local function visit(mod)
        if visited[mod.id] then return end
        if visiting[mod.id] then
            error("Circular dependency detected: " .. mod.id)
        end
        
        visiting[mod.id] = true
        
        -- Visit dependencies first
        for _, dep in ipairs(mod.dependencies or {}) do
            local dep_mod = find_mod(dep.id)
            if dep_mod then
                visit(dep_mod)
            end
        end
        
        visiting[mod.id] = false
        visited[mod.id] = true
        table.insert(sorted, mod)
    end
    
    -- Sort by explicit load_order first, then dependencies
    table.sort(mods, function(a, b)
        return (a.load_order or 0) < (b.load_order or 0)
    end)
    
    for _, mod in ipairs(mods) do
        visit(mod)
    end
    
    return sorted
end
```

---

## Error Reporting

### Error Structure

```lua
-- Error object
validation_error = {
    level = VALIDATION_LEVELS.ERROR,
    message = "Missing required field: id",
    file = "mods/example_mod/units/soldier.toml",
    line = 15,
    column = 3,
    context = "unit.soldier",
    suggestion = "Add 'id = \"soldier\"' to the file",
    stack_trace = {...}
}
```

### Error Collection

```lua
-- Collect all validation errors
function collect_validation_errors()
    local all_errors = {}
    
    -- Validate all data files
    for category, files in pairs(data_files) do
        for _, file_path in ipairs(files) do
            local errors = validate_file(file_path, category)
            for _, err in ipairs(errors) do
                err.file = file_path
                table.insert(all_errors, err)
            end
        end
    end
    
    return all_errors
end

-- Sort errors by severity
function sort_errors(errors)
    table.sort(errors, function(a, b)
        if a.level ~= b.level then
            return a.level < b.level  -- Errors first
        else
            return a.file < b.file     -- Then by file
        end
    end)
end
```

### Error Display

```lua
-- Format error message for console
function format_error_message(error)
    local level_names = {
        [VALIDATION_LEVELS.ERROR] = "ERROR",
        [VALIDATION_LEVELS.WARNING] = "WARNING",
        [VALIDATION_LEVELS.INFO] = "INFO",
        [VALIDATION_LEVELS.DEBUG] = "DEBUG"
    }
    
    local msg = string.format(
        "[%s] %s:%d:%d - %s",
        level_names[error.level],
        error.file or "unknown",
        error.line or 0,
        error.column or 0,
        error.message
    )
    
    if error.suggestion then
        msg = msg .. "\n  Suggestion: " .. error.suggestion
    end
    
    return msg
end

-- Print all errors to console
function print_validation_errors(errors)
    print("\n========== VALIDATION REPORT ==========\n")
    
    local error_count = 0
    local warning_count = 0
    
    for _, err in ipairs(errors) do
        print(format_error_message(err))
        
        if err.level == VALIDATION_LEVELS.ERROR then
            error_count = error_count + 1
        elseif err.level == VALIDATION_LEVELS.WARNING then
            warning_count = warning_count + 1
        end
    end
    
    print("\n========================================")
    print(string.format("Total: %d errors, %d warnings", error_count, warning_count))
    print("========================================\n")
    
    if error_count > 0 then
        error("Validation failed with " .. error_count .. " errors. Fix errors before continuing.")
    end
end
```

### In-Game Error UI

```lua
-- Draw validation errors in-game
function draw_validation_errors(errors)
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    
    love.graphics.setColor(1, 0, 0)
    love.graphics.print("VALIDATION ERRORS", 300, 40)
    
    love.graphics.setColor(1, 1, 1)
    local y = 80
    for i, err in ipairs(errors) do
        if i > 20 then
            love.graphics.print("... and " .. (#errors - 20) .. " more errors", 40, y)
            break
        end
        
        local msg = string.format("%s:%d - %s",
            err.file or "unknown",
            err.line or 0,
            err.message
        )
        
        love.graphics.print(msg, 40, y)
        y = y + 20
    end
    
    love.graphics.print("Press ESC to exit", 300, 550)
end
```

---

## Hot-Reloading System

### File Watching

```lua
-- Hot-reload system
HotReload = {
    enabled = false,
    watched_files = {},
    last_modified = {},
    reload_delay = 0.5  -- Seconds to wait before reloading
}

-- Watch a file for changes
function HotReload:watch_file(file_path)
    self.watched_files[file_path] = true
    local info = love.filesystem.getInfo(file_path)
    if info then
        self.last_modified[file_path] = info.modtime
    end
end

-- Check for file changes
function HotReload:update(dt)
    if not self.enabled then return end
    
    for file_path, _ in pairs(self.watched_files) do
        local info = love.filesystem.getInfo(file_path)
        if info then
            local last_mod = self.last_modified[file_path] or 0
            if info.modtime > last_mod then
                self:reload_file(file_path)
                self.last_modified[file_path] = info.modtime
            end
        end
    end
end

-- Reload a data file
function HotReload:reload_file(file_path)
    print("Hot-reloading: " .. file_path)
    
    -- Parse TOML
    local content = love.filesystem.read(file_path)
    local success, data = pcall(toml.parse, content)
    
    if not success then
        print("ERROR: Failed to parse " .. file_path .. ": " .. tostring(data))
        return
    end
    
    -- Validate
    local errors = validate_file_data(data, file_path)
    if #errors > 0 then
        print("VALIDATION ERRORS in " .. file_path .. ":")
        for _, err in ipairs(errors) do
            print("  " .. err.message)
        end
        return
    end
    
    -- Apply changes
    apply_data_update(file_path, data)
    
    print("Successfully reloaded: " .. file_path)
end
```

### Incremental Updates

```lua
-- Apply data updates without full reload
function apply_data_update(file_path, new_data)
    -- Determine data category from file path
    local category = get_data_category(file_path)
    
    if category == "units" then
        -- Update unit definitions
        for _, unit_data in ipairs(new_data.units or {}) do
            UNIT_TEMPLATES[unit_data.id] = unit_data
        end
        
    elseif category == "weapons" then
        -- Update weapon definitions
        for _, weapon_data in ipairs(new_data.weapons or {}) do
            WEAPON_TEMPLATES[weapon_data.id] = weapon_data
        end
        
    elseif category == "missions" then
        -- Update mission templates
        for _, mission_data in ipairs(new_data.missions or {}) do
            MISSION_TEMPLATES[mission_data.id] = mission_data
        end
    end
    
    -- Trigger refresh for affected systems
    trigger_system_refresh(category)
end
```

---

## Debug Tools

### Validation Console

```lua
-- Interactive validation console
ValidationConsole = {
    commands = {},
    history = {},
    output = {}
}

-- Register console commands
function ValidationConsole:init()
    self:register_command("validate", function(args)
        local file_path = args[1]
        if not file_path then
            return "Usage: validate <file_path>"
        end
        
        local errors = validate_file(file_path)
        if #errors == 0 then
            return "✓ No errors found in " .. file_path
        else
            return string.format("✗ Found %d errors in %s", #errors, file_path)
        end
    end)
    
    self:register_command("check_refs", function(args)
        local entity_type = args[1]
        return check_all_references(entity_type)
    end)
    
    self:register_command("reload", function(args)
        local file_path = args[1]
        HotReload:reload_file(file_path)
        return "Reloaded: " .. file_path
    end)
end

-- Execute console command
function ValidationConsole:execute(command_line)
    local parts = split_string(command_line, " ")
    local command_name = parts[1]
    local args = {table.unpack(parts, 2)}
    
    local command = self.commands[command_name]
    if not command then
        return "Unknown command: " .. command_name
    end
    
    local result = command(args)
    table.insert(self.output, result)
    table.insert(self.history, command_line)
    
    return result
end
```

### Data Inspector

```lua
-- Inspect loaded data
DataInspector = {}

function DataInspector:inspect_entity(entity_type, entity_id)
    local template = get_template(entity_type, entity_id)
    if not template then
        return "Entity not found: " .. entity_type .. "." .. entity_id
    end
    
    -- Pretty-print entity data
    print("========== " .. entity_type .. ": " .. entity_id .. " ==========")
    print_table(template, 0)
    print("=" .. string.rep("=", 50))
end

function DataInspector:list_entities(entity_type)
    local templates = get_all_templates(entity_type)
    print("========== " .. entity_type .. " (" .. #templates .. ") ==========")
    for _, template in ipairs(templates) do
        print("  " .. template.id .. " - " .. (template.name or "unnamed"))
    end
    print("=" .. string.rep("=", 50))
end

function DataInspector:find_references_to(entity_type, entity_id)
    print("Finding references to " .. entity_type .. "." .. entity_id .. "...")
    
    local references = {}
    
    -- Search all data files
    for category, templates in pairs(ALL_TEMPLATES) do
        for id, template in pairs(templates) do
            local refs = find_references_in_table(template, entity_type, entity_id)
            if #refs > 0 then
                table.insert(references, {
                    category = category,
                    id = id,
                    references = refs
                })
            end
        end
    end
    
    print("Found " .. #references .. " references:")
    for _, ref in ipairs(references) do
        print("  " .. ref.category .. "." .. ref.id)
        for _, path in ipairs(ref.references) do
            print("    at: " .. path)
        end
    end
end
```

### Validation Report Generator

```lua
-- Generate comprehensive validation report
function generate_validation_report()
    local report = {
        timestamp = os.date("%Y-%m-%d %H:%M:%S"),
        errors = {},
        warnings = {},
        statistics = {}
    }
    
    -- Collect all errors
    local all_errors = collect_validation_errors()
    sort_errors(all_errors)
    
    for _, err in ipairs(all_errors) do
        if err.level == VALIDATION_LEVELS.ERROR then
            table.insert(report.errors, err)
        elseif err.level == VALIDATION_LEVELS.WARNING then
            table.insert(report.warnings, err)
        end
    end
    
    -- Calculate statistics
    report.statistics = {
        total_files = count_data_files(),
        total_entities = count_all_entities(),
        total_mods = count_mods(),
        error_count = #report.errors,
        warning_count = #report.warnings
    }
    
    -- Write report to file
    local report_text = format_report(report)
    love.filesystem.write("validation_report.txt", report_text)
    
    print("Validation report written to: validation_report.txt")
    
    return report
end
```

---

## Implementation

### Data Validation Manager

```lua
-- Main validation system
DataValidationManager = {}

function DataValidationManager:init()
    self.schemas = {}
    self.validators = {}
    self.errors = {}
    self.warnings = {}
    
    -- Register default schemas
    self:register_default_schemas()
    
    -- Enable hot-reload in development mode
    if IS_DEVELOPMENT_MODE then
        HotReload.enabled = true
    end
end

-- Validate all game data
function DataValidationManager:validate_all()
    print("Validating all game data...")
    
    self.errors = {}
    self.warnings = {}
    
    -- Validate base game data
    self:validate_category("units")
    self:validate_category("weapons")
    self:validate_category("items")
    self:validate_category("missions")
    self:validate_category("facilities")
    self:validate_category("research")
    self:validate_category("crafts")
    
    -- Validate mod data
    for _, mod in ipairs(loaded_mods) do
        self:validate_mod(mod)
    end
    
    -- Validate cross-references
    self:validate_references()
    
    -- Print report
    print_validation_errors(self.errors)
    
    if #self.warnings > 0 then
        print(string.format("Note: %d warnings found (non-fatal)", #self.warnings))
    end
    
    return #self.errors == 0
end

-- Validate a single category
function DataValidationManager:validate_category(category)
    local schema = self.schemas[category]
    if not schema then
        print("Warning: No schema defined for category: " .. category)
        return
    end
    
    local templates = get_all_templates(category)
    for id, template in pairs(templates) do
        local errors = validate_against_schema(template, schema, category .. "." .. id)
        for _, err in ipairs(errors) do
            if err.level == VALIDATION_LEVELS.ERROR then
                table.insert(self.errors, err)
            else
                table.insert(self.warnings, err)
            end
        end
    end
end

return DataValidationManager
```

---

## Cross-References

### Related Systems

- **[Modding System](Modding.md)** - Mod structure and loading
- **[Save System](Save_System.md)** - Data serialization and validation
- **[Data Loading](../core/Data_Loading.md)** - TOML parsing and data structures
- **[Error Handling](../core/Error_Handling.md)** - Error propagation and recovery

### Data Files

- `data/schemas/*.toml` - Schema definitions for validation
- `config/validation_rules.toml` - Validation configuration

### Implementation Files

- `src/core/data_validation.lua` - Main validation system
- `src/core/schema_validator.lua` - Schema validation logic
- `src/core/hot_reload.lua` - Hot-reloading system
- `src/tools/validation_console.lua` - Debug console

---

**End of Data Validation System Specification**

*Version 1.0 - September 30, 2025*
