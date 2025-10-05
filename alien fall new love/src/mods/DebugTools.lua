-- DebugTools - Tools to help mod creators debug and validate their mods
-- Provides validation, schema checking, dependency analysis, and error reporting

local class = require('lib.middleclass')
local Logger = require('engine.logger')

local DebugTools = class('DebugTools')

function DebugTools:initialize()
    self.logger = Logger.new("DebugTools")
    
    -- Schema definitions for different content types
    self.schemas = self:initializeSchemas()
    
    self.logger:info("DebugTools initialized")
end

function DebugTools:initializeSchemas()
    return {
        unit = {
            required_fields = {"id", "name", "class_id"},
            optional_fields = {"stats", "abilities", "inventory"},
            field_types = {
                id = "string",
                name = "string",
                class_id = "string",
                stats = "table"
            }
        },
        item = {
            required_fields = {"id", "name", "type"},
            optional_fields = {"damage", "accuracy", "cost", "weight"},
            field_types = {
                id = "string",
                name = "string",
                type = "string",
                damage = "number",
                accuracy = "number"
            }
        },
        mission = {
            required_fields = {"id", "label", "map"},
            optional_fields = {"objective", "enemies", "rewards"},
            field_types = {
                id = "string",
                label = "string",
                map = "string"
            }
        },
        facility = {
            required_fields = {"id", "label", "size"},
            optional_fields = {"buildCost", "buildDays", "upkeep"},
            field_types = {
                id = "string",
                label = "string",
                size = "table",
                buildCost = "number",
                buildDays = "number"
            }
        },
        research = {
            required_fields = {"id", "label"},
            optional_fields = {"cost", "prerequisites", "unlocks"},
            field_types = {
                id = "string",
                label = "string",
                cost = "number"
            }
        }
    }
end

function DebugTools:validateMod(mod)
    local errors = {}
    local warnings = {}
    
    -- Check required mod manifest fields
    if not mod.id then
        table.insert(errors, "Missing required field: id")
    end
    if not mod.name then
        table.insert(warnings, "Missing recommended field: name")
    end
    if not mod.version then
        table.insert(warnings, "Missing recommended field: version")
    end
    
    -- Validate ID format
    if mod.id and not mod.id:match("^[a-z_][a-z0-9_]*$") then
        table.insert(errors, "Invalid mod ID format: " .. mod.id .. 
            " (must be lowercase, alphanumeric with underscores)")
    end
    
    -- Check dependencies
    if mod.dependencies then
        for _, dep in ipairs(mod.dependencies) do
            if type(dep) ~= "string" then
                table.insert(errors, "Invalid dependency type: " .. type(dep))
            end
        end
    end
    
    -- Validate catalogs
    if mod.catalogs then
        for catalog_name, entries in pairs(mod.catalogs) do
            local catalog_errors = self:validateCatalog(catalog_name, entries)
            for _, err in ipairs(catalog_errors) do
                table.insert(errors, string.format("[%s] %s", catalog_name, err))
            end
        end
    end
    
    -- Validate TOML content
    if mod.tomlContent then
        for content_type, files in pairs(mod.tomlContent) do
            if type(files) ~= "table" then
                table.insert(errors, string.format("Invalid tomlContent format for %s", content_type))
            end
        end
    end
    
    return {
        valid = #errors == 0,
        errors = errors,
        warnings = warnings
    }
end

function DebugTools:validateCatalog(catalog_name, entries)
    local errors = {}
    
    local schema = self.schemas[catalog_name]
    if not schema then
        -- No schema defined, skip validation
        return errors
    end
    
    for entry_id, entry in pairs(entries) do
        -- Check required fields
        for _, field in ipairs(schema.required_fields) do
            if entry[field] == nil then
                table.insert(errors, string.format("Entry '%s' missing required field: %s", 
                    entry_id, field))
            end
        end
        
        -- Check field types
        for field, expected_type in pairs(schema.field_types) do
            if entry[field] ~= nil then
                local actual_type = type(entry[field])
                if actual_type ~= expected_type then
                    table.insert(errors, string.format(
                        "Entry '%s' field '%s' has wrong type: expected %s, got %s",
                        entry_id, field, expected_type, actual_type))
                end
            end
        end
    end
    
    return errors
end

function DebugTools:analyzeDependencies(mods)
    local analysis = {
        missing = {},
        circular = {},
        order = {}
    }
    
    local mod_map = {}
    for _, mod in ipairs(mods) do
        mod_map[mod.id] = mod
    end
    
    -- Check for missing dependencies
    for _, mod in ipairs(mods) do
        if mod.dependencies then
            for _, dep_id in ipairs(mod.dependencies) do
                if not mod_map[dep_id] then
                    table.insert(analysis.missing, {
                        mod = mod.id,
                        dependency = dep_id
                    })
                end
            end
        end
    end
    
    -- Check for circular dependencies (simplified check)
    local visited = {}
    local function hasCircular(mod_id, chain)
        if visited[mod_id] then
            return false
        end
        
        for _, id in ipairs(chain) do
            if id == mod_id then
                table.insert(analysis.circular, chain)
                return true
            end
        end
        
        local mod = mod_map[mod_id]
        if not mod or not mod.dependencies then
            return false
        end
        
        local new_chain = {}
        for _, id in ipairs(chain) do
            table.insert(new_chain, id)
        end
        table.insert(new_chain, mod_id)
        
        for _, dep_id in ipairs(mod.dependencies) do
            if hasCircular(dep_id, new_chain) then
                return true
            end
        end
        
        visited[mod_id] = true
        return false
    end
    
    for _, mod in ipairs(mods) do
        hasCircular(mod.id, {})
    end
    
    return analysis
end

function DebugTools:generateReport(mod)
    local report = {
        "=== Mod Validation Report ===",
        "",
        "Mod ID: " .. (mod.id or "UNKNOWN"),
        "Mod Name: " .. (mod.name or "UNKNOWN"),
        "Version: " .. (mod.version or "UNKNOWN"),
        ""
    }
    
    local result = self:validateMod(mod)
    
    if result.valid then
        table.insert(report, "✓ Validation PASSED")
    else
        table.insert(report, "✗ Validation FAILED")
    end
    
    if #result.errors > 0 then
        table.insert(report, "")
        table.insert(report, "Errors:")
        for _, err in ipairs(result.errors) do
            table.insert(report, "  • " .. err)
        end
    end
    
    if #result.warnings > 0 then
        table.insert(report, "")
        table.insert(report, "Warnings:")
        for _, warn in ipairs(result.warnings) do
            table.insert(report, "  • " .. warn)
        end
    end
    
    table.insert(report, "")
    table.insert(report, "=== End Report ===")
    
    return table.concat(report, "\n")
end

function DebugTools:browseContent(mod)
    local content = {
        "=== Mod Content Browser ===",
        "",
        "Mod: " .. (mod.name or mod.id),
        ""
    }
    
    -- List catalogs
    if mod.catalogs then
        table.insert(content, "Catalogs:")
        for catalog_name, entries in pairs(mod.catalogs) do
            local count = 0
            for _ in pairs(entries) do
                count = count + 1
            end
            table.insert(content, string.format("  • %s (%d entries)", catalog_name, count))
        end
    end
    
    -- List TOML content
    if mod.tomlContent then
        table.insert(content, "")
        table.insert(content, "TOML Content:")
        for content_type, files in pairs(mod.tomlContent) do
            table.insert(content, string.format("  • %s (%d files)", content_type, #files))
            for _, file in ipairs(files) do
                table.insert(content, string.format("    - %s", file))
            end
        end
    end
    
    -- List hooks
    if mod.hooks then
        table.insert(content, "")
        table.insert(content, "Hooks:")
        local count = 0
        for hook_name, _ in pairs(mod.hooks) do
            table.insert(content, string.format("  • %s", hook_name))
            count = count + 1
        end
        if count == 0 then
            table.insert(content, "  (none)")
        end
    end
    
    table.insert(content, "")
    table.insert(content, "=== End Browser ===")
    
    return table.concat(content, "\n")
end

function DebugTools:suggestFixes(errors)
    local suggestions = {}
    
    for _, error in ipairs(errors) do
        local suggestion = nil
        
        if error:match("Missing required field") then
            local field = error:match("field: (%w+)")
            suggestion = string.format("Add the required field '%s' to your manifest or entry", field)
        elseif error:match("Invalid mod ID format") then
            suggestion = "Use only lowercase letters, numbers, and underscores in mod ID"
        elseif error:match("wrong type") then
            local field, expected = error:match("field '(%w+)' .* expected (%w+)")
            suggestion = string.format("Change field '%s' to type %s", field, expected)
        end
        
        if suggestion then
            table.insert(suggestions, {
                error = error,
                suggestion = suggestion
            })
        end
    end
    
    return suggestions
end

function DebugTools:checkSchema(content_type, data)
    local schema = self.schemas[content_type]
    if not schema then
        return {
            valid = true,
            message = "No schema defined for type: " .. content_type
        }
    end
    
    local errors = self:validateCatalog(content_type, data)
    
    return {
        valid = #errors == 0,
        errors = errors,
        schema = schema
    }
end

return DebugTools
