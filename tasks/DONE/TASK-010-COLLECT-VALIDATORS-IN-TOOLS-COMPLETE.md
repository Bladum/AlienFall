# Task: Collect All Validators in tools/ Folder and Add VS Code Tasks

**Status:** TODO
**Priority:** High
**Created:** 2025-10-24
**Completed:** N/A
**Assigned To:** AI Agent

**Dependencies:**
- TASK-001 (GAME_API.toml)
- TASK-002 (API validator)
- TASK-003 (mock data generator)
- TASK-004 (content validator)
- TASK-009 (mods must be organized)

---

## Overview

Collect all validator scripts, testing tools, analysis utilities, and development aids into a well-organized `tools/` folder structure. Create VS Code tasks for each tool to enable AI Agent and developers to easily run validators, analyzers, and generators directly from the IDE.

---

## Purpose

**Why this is needed:**
- Validator scripts scattered across project
- Hard to find the right tool
- No consistent interface
- Manual command-line invocation required
- AI Agent needs easy access to tools
- Developers waste time finding/running tools
- No centralized tool documentation

**What problem it solves:**
- Centralized tool location
- Easy discovery of available tools
- Consistent invocation via VS Code tasks
- AI Agent can use tools via tasks
- Better developer experience
- Standardized tool interface

---

## Requirements

### Functional Requirements

#### Tool Organization
- [ ] All validators in `tools/validators/`
- [ ] All generators in `tools/generators/`
- [ ] All analyzers in `tools/analyzers/`
- [ ] All testing utilities in `tools/testing/`
- [ ] All documentation tools in `tools/docs/`
- [ ] All asset tools in `tools/assets/`
- [ ] Each tool has README.md

#### VS Code Tasks
- [ ] Task for each major tool
- [ ] Task categories organized
- [ ] Keyboard shortcuts configured
- [ ] AI Agent can discover tasks
- [ ] Tasks use proper icons
- [ ] Tasks have problem matchers

#### Tool Standardization
- [ ] Common CLI interface
- [ ] Consistent output format
- [ ] Exit codes standardized
- [ ] Help text for all tools
- [ ] Version information
- [ ] JSON output option (for AI Agent)

### Technical Requirements
- [ ] All tools runnable with `lovec`
- [ ] All tools work from workspace root
- [ ] All tools support `--help`
- [ ] All tools support `--version`
- [ ] All tools support `--json` (machine-readable output)
- [ ] All tools have tests

### Acceptance Criteria
- [ ] All tools moved to tools/
- [ ] Each tool documented
- [ ] VS Code tasks created for each tool
- [ ] AI Agent can list and use tools
- [ ] Keyboard shortcuts configured
- [ ] Team approves organization

---

## Plan

### Step 1: Audit Existing Tools
**Description:** Find all existing validator/tool scripts

**Current known tools:**
```
tools/
├── asset_verification/
├── docs_validator/
└── (possibly more)

tests/
├── validate_*.lua (?)
└── runners/ (test runners, not validators)

(possibly scattered elsewhere)
```

**Tool audit process:**
1. Search for all `.lua` files with "validate", "check", "analyze", "generate" in name or content
2. Search for all scripts in `tools/`
3. Search for all utility scripts
4. Categorize by purpose

**Grep searches:**
```bash
# Find validator scripts
grep -r "validate" --include="*.lua" .

# Find generator scripts
grep -r "generate" --include="*.lua" .

# Find analyzer scripts
grep -r "analyze" --include="*.lua" .

# Find checker scripts
grep -r "check" --include="*.lua" .
```

**Create inventory:**
`temp/tool_inventory.md`

**Format:**
```markdown
# Tool Inventory

## Validators

### API Validator
- **Location:** `tools/validators/validate_mod.lua` (TASK-002)
- **Purpose:** Validate mod TOML against GAME_API
- **Usage:** `lovec tools/validators/validate_mod.lua <mod_path>`
- **Status:** ✅ Exists (from TASK-002)

### Content Validator
- **Location:** `tools/validators/validate_content.lua` (TASK-004)
- **Purpose:** Validate mod internal consistency
- **Usage:** `lovec tools/validators/validate_content.lua <mod_path>`
- **Status:** ✅ Exists (from TASK-004)

### (continue for all found validators)

## Generators

### Mock Data Generator
- **Location:** `tools/generators/generate_mock_data.lua` (TASK-003)
- **Purpose:** Generate synthetic mod data
- **Usage:** `lovec tools/generators/generate_mock_data.lua --output <path> --strategy <strategy>`
- **Status:** ✅ Exists (from TASK-003)

### (continue for all generators)

## Analyzers

### Mod Content Auditor
- **Location:** `tools/mods/audit_mod_content.lua` (TASK-009)
- **Purpose:** Audit and categorize mod content
- **Usage:** `lovec tools/mods/audit_mod_content.lua <mod_path>`
- **Status:** ✅ Exists (from TASK-009)

### (continue for all analyzers)

## Testing Utilities

### Test Runner
- **Location:** `tests/runners/run_all.lua`
- **Purpose:** Run all tests
- **Usage:** `lovec tests/runners/run_all.lua`
- **Status:** ✅ Exists

### (continue for all test utilities)

## Documentation Tools

### Docs Validator
- **Location:** `tools/docs_validator/`
- **Purpose:** Validate documentation
- **Usage:** (to be determined)
- **Status:** ⚠️ Needs review

### (continue for all doc tools)

## Asset Tools

### Asset Verification
- **Location:** `tools/asset_verification/`
- **Purpose:** Verify asset integrity
- **Usage:** (to be determined)
- **Status:** ⚠️ Needs review

### (continue for all asset tools)

## Uncategorized

### (list any tools that don't fit above categories)

## Missing Tools

### (list tools that should exist but don't)
```

**Estimated time:** 3-4 hours

---

### Step 2: Design Target tools/ Structure
**Description:** Design organized folder structure

**Target structure:**
```
tools/
├── README.md (index of all tools)
├── TOOL_STANDARD.md (standard interface guide)
├── common/
│   ├── cli.lua (common CLI parsing)
│   ├── output.lua (common output formatting)
│   └── utils.lua (shared utilities)
├── validators/
│   ├── README.md
│   ├── validate_mod.lua (API validation - TASK-002)
│   ├── validate_content.lua (content validation - TASK-004)
│   ├── validate_assets.lua (asset existence/format)
│   ├── validate_balance.lua (balance checking)
│   ├── validate_references.lua (reference integrity)
│   └── validate_all.lua (run all validators)
├── generators/
│   ├── README.md
│   ├── generate_mock_data.lua (TASK-003)
│   ├── generate_unit.lua (unit generator)
│   ├── generate_item.lua (item generator)
│   └── generate_mod_template.lua (new mod scaffold)
├── analyzers/
│   ├── README.md
│   ├── analyze_mod_content.lua (audit mod - TASK-009)
│   ├── analyze_balance.lua (balance analysis)
│   ├── analyze_dependencies.lua (dependency graph)
│   ├── analyze_coverage.lua (API coverage)
│   └── analyze_complexity.lua (content complexity)
├── converters/
│   ├── README.md
│   ├── convert_legacy_mod.lua (upgrade old mods)
│   ├── convert_json_to_toml.lua (format conversion)
│   └── convert_toml_to_json.lua (format conversion)
├── testing/
│   ├── README.md
│   ├── create_test_mod.lua (scaffold test mod)
│   ├── compare_mods.lua (diff two mods)
│   └── benchmark_mod.lua (performance testing)
├── docs/
│   ├── README.md
│   ├── generate_api_docs.lua (from GAME_API.toml)
│   ├── generate_mod_docs.lua (document mod content)
│   ├── validate_docs.lua (check documentation)
│   └── update_readme.lua (auto-update READMEs)
├── assets/
│   ├── README.md
│   ├── verify_assets.lua (check asset integrity)
│   ├── optimize_sprites.lua (sprite optimization)
│   ├── generate_asset_manifest.lua (list all assets)
│   └── check_missing_assets.lua (find missing)
└── dev/
    ├── README.md
    ├── setup_workspace.lua (workspace setup)
    ├── create_release.lua (package release)
    └── check_health.lua (project health check)
```

**Categories:**
- **validators/** - Verify correctness
- **generators/** - Create new content
- **analyzers/** - Analyze existing content
- **converters/** - Transform formats
- **testing/** - Testing utilities
- **docs/** - Documentation tools
- **assets/** - Asset management
- **dev/** - Development workflow

**Estimated time:** 2-3 hours

---

### Step 3: Create Common Tool Infrastructure
**Description:** Shared utilities for all tools

**tools/common/cli.lua:**
```lua
-- Common CLI argument parsing

local CLI = {}

-- Parse command-line arguments
function CLI.parse(args, schema)
    local parsed = {
        flags = {},
        options = {},
        positional = {}
    }

    local i = 1
    while i <= #args do
        local arg = args[i]

        if arg:match("^%-%-") then
            -- Long option (--option=value or --option value)
            local key, value = arg:match("^%-%-([^=]+)=(.+)$")
            if key then
                parsed.options[key] = value
            else
                key = arg:match("^%-%-(.+)$")
                if schema.flags and schema.flags[key] then
                    parsed.flags[key] = true
                else
                    -- Next arg is value
                    i = i + 1
                    parsed.options[key] = args[i]
                end
            end
        elseif arg:match("^%-") then
            -- Short option (-o value)
            local key = arg:match("^%-(.+)$")
            if schema.flags and schema.flags[key] then
                parsed.flags[key] = true
            else
                i = i + 1
                parsed.options[key] = args[i]
            end
        else
            -- Positional argument
            table.insert(parsed.positional, arg)
        end

        i = i + 1
    end

    return parsed
end

-- Show help text
function CLI.showHelp(toolName, description, usage, options)
    print(string.format("%s - %s", toolName, description))
    print("")
    print("Usage:")
    print("  " .. usage)
    print("")
    print("Options:")
    for _, opt in ipairs(options) do
        print(string.format("  %-20s %s", opt.flag, opt.description))
    end
end

-- Show version
function CLI.showVersion(toolName, version)
    print(string.format("%s version %s", toolName, version))
end

return CLI
```

**tools/common/output.lua:**
```lua
-- Common output formatting

local Output = {}

-- Output formats
Output.FORMAT_TEXT = "text"
Output.FORMAT_JSON = "json"
Output.FORMAT_MARKDOWN = "markdown"

local currentFormat = Output.FORMAT_TEXT

function Output.setFormat(format)
    currentFormat = format
end

-- Print result
function Output.result(data)
    if currentFormat == Output.FORMAT_JSON then
        Output.json(data)
    elseif currentFormat == Output.FORMAT_MARKDOWN then
        Output.markdown(data)
    else
        Output.text(data)
    end
end

-- JSON output
function Output.json(data)
    local json = require("tools.common.json")  -- or use external lib
    print(json.encode(data))
end

-- Text output
function Output.text(data)
    -- Pretty-print for humans
    if data.success then
        print("✅ SUCCESS")
    else
        print("❌ FAILURE")
    end

    if data.summary then
        print("\nSummary:")
        for k, v in pairs(data.summary) do
            print(string.format("  %s: %s", k, v))
        end
    end

    if data.errors and #data.errors > 0 then
        print("\nErrors:")
        for i, err in ipairs(data.errors) do
            print(string.format("  %d. %s", i, err.message))
            if err.location then
                print(string.format("     Location: %s", err.location))
            end
        end
    end

    if data.warnings and #data.warnings > 0 then
        print("\nWarnings:")
        for i, warn in ipairs(data.warnings) do
            print(string.format("  %d. %s", i, warn.message))
        end
    end
end

-- Markdown output
function Output.markdown(data)
    print("# Validation Result")
    print("")

    if data.success then
        print("**Status:** ✅ PASS")
    else
        print("**Status:** ❌ FAIL")
    end

    print("")

    if data.summary then
        print("## Summary")
        print("")
        for k, v in pairs(data.summary) do
            print(string.format("- **%s:** %s", k, v))
        end
        print("")
    end

    if data.errors and #data.errors > 0 then
        print("## Errors")
        print("")
        for i, err in ipairs(data.errors) do
            print(string.format("%d. **%s**", i, err.message))
            if err.location then
                print(string.format("   - Location: `%s`", err.location))
            end
        end
        print("")
    end
end

-- Exit with code
function Output.exit(success)
    os.exit(success and 0 or 1)
end

return Output
```

**tools/common/utils.lua:**
```lua
-- Shared utility functions

local Utils = {}

-- File system utilities
function Utils.fileExists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    end
    return false
end

function Utils.readFile(path)
    local file = io.open(path, "r")
    if not file then return nil, "Cannot open file: " .. path end
    local content = file:read("*all")
    file:close()
    return content
end

function Utils.writeFile(path, content)
    local file = io.open(path, "w")
    if not file then return false, "Cannot write file: " .. path end
    file:write(content)
    file:close()
    return true
end

-- String utilities
function Utils.split(str, delimiter)
    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

function Utils.trim(str)
    return str:match("^%s*(.-)%s*$")
end

-- Table utilities
function Utils.deepCopy(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for k, v in pairs(orig) do
            copy[Utils.deepCopy(k)] = Utils.deepCopy(v)
        end
    else
        copy = orig
    end
    return copy
end

function Utils.merge(t1, t2)
    local result = Utils.deepCopy(t1)
    for k, v in pairs(t2) do
        result[k] = v
    end
    return result
end

-- Path utilities
function Utils.joinPath(...)
    local parts = {...}
    return table.concat(parts, "/"):gsub("//+", "/")
end

function Utils.dirname(path)
    return path:match("(.*/)")
end

function Utils.basename(path)
    return path:match("([^/]+)$")
end

return Utils
```

**Estimated time:** 4-5 hours

---

### Step 4: Create Tool Standard Document
**Description:** Define standard interface for all tools

**tools/TOOL_STANDARD.md:**
```markdown
# Tool Development Standard

All tools in this directory must follow this standard for consistency.

## Command-Line Interface

### Required Arguments

All tools MUST support:
- `--help` or `-h`: Show help text
- `--version` or `-v`: Show version
- `--json`: Output in JSON format (for AI Agent)

### Optional Arguments

Tools SHOULD support:
- `--verbose`: Verbose output
- `--quiet`: Minimal output
- `--output <file>`: Write output to file

### Positional Arguments

Use positional arguments for primary input:
```bash
lovec tool.lua <input> [options]
```

## Output Format

### Exit Codes

- `0`: Success
- `1`: General error
- `2`: Invalid arguments
- `3`: File not found
- `4`: Validation failed

### Text Output (default)

```
✅ SUCCESS (or ❌ FAILURE)

Summary:
  Total: 42
  Passed: 40
  Failed: 2

Errors:
  1. Type mismatch in units/soldier.toml
     Location: line 15, field 'health'
     Expected: integer
     Got: string

Warnings:
  1. Deprecated field 'old_field' in items/rifle.toml
```

### JSON Output (--json)

```json
{
  "success": true,
  "summary": {
    "total": 42,
    "passed": 40,
    "failed": 2
  },
  "errors": [
    {
      "message": "Type mismatch in units/soldier.toml",
      "location": "line 15, field 'health'",
      "expected": "integer",
      "got": "string",
      "severity": "error"
    }
  ],
  "warnings": [
    {
      "message": "Deprecated field 'old_field' in items/rifle.toml",
      "location": "line 10",
      "severity": "warning"
    }
  ]
}
```

## File Structure

### Template

```lua
#!/usr/bin/env lovec

-- Tool: <Tool Name>
-- Version: 1.0.0
-- Description: <Brief description>

-- Load common libraries
local CLI = require("tools.common.cli")
local Output = require("tools.common.output")
local Utils = require("tools.common.utils")

-- Tool metadata
local TOOL_NAME = "tool_name"
local TOOL_VERSION = "1.0.0"
local TOOL_DESCRIPTION = "Brief description"

-- CLI schema
local CLI_SCHEMA = {
    flags = {
        help = true,
        version = true,
        json = true,
        verbose = true
    },
    options = {
        output = "string"
    }
}

-- Help text
local function showHelp()
    CLI.showHelp(
        TOOL_NAME,
        TOOL_DESCRIPTION,
        "lovec tool.lua <input> [options]",
        {
            { flag = "--help, -h", description = "Show this help" },
            { flag = "--version, -v", description = "Show version" },
            { flag = "--json", description = "Output in JSON format" },
            { flag = "--output <file>", description = "Write output to file" }
        }
    )
end

-- Main logic
local function main(args)
    local parsed = CLI.parse(args, CLI_SCHEMA)

    -- Handle flags
    if parsed.flags.help then
        showHelp()
        Output.exit(true)
    end

    if parsed.flags.version then
        CLI.showVersion(TOOL_NAME, TOOL_VERSION)
        Output.exit(true)
    end

    if parsed.flags.json then
        Output.setFormat(Output.FORMAT_JSON)
    end

    -- Validate input
    if #parsed.positional == 0 then
        print("Error: No input provided")
        showHelp()
        Output.exit(false)
    end

    local input = parsed.positional[1]

    -- Tool logic here
    local result = {
        success = true,
        summary = {
            processed = 1
        },
        errors = {},
        warnings = {}
    }

    -- Output result
    Output.result(result)
    Output.exit(result.success)
end

-- Entry point
local args = {...}
main(args)
```

## Documentation

Each tool MUST have:
- Docstring at top of file
- README.md in category folder
- Entry in tools/README.md

## Testing

Each tool SHOULD have:
- Unit tests in tests/unit/tools/
- Integration tests if applicable

## Checklist

- [ ] Follows CLI standard
- [ ] Supports --help, --version, --json
- [ ] Uses common libraries
- [ ] Proper exit codes
- [ ] Documented
- [ ] Tested
```

**Estimated time:** 2-3 hours

---

### Step 5: Move/Create Validator Tools
**Description:** Organize all validators

**Move existing validators:**
```bash
# From TASK-002
mv <location> tools/validators/validate_mod.lua

# From TASK-004
mv <location> tools/validators/validate_content.lua
```

**Create new validators:**

**tools/validators/validate_all.lua:**
```lua
-- Run all validators on a mod

local CLI = require("tools.common.cli")
local Output = require("tools.common.output")

local validators = {
    "tools/validators/validate_mod.lua",
    "tools/validators/validate_content.lua",
    "tools/validators/validate_assets.lua",
    "tools/validators/validate_references.lua"
}

local function main(args)
    local modPath = args[1]

    if not modPath then
        print("Usage: lovec validate_all.lua <mod_path>")
        os.exit(1)
    end

    print(string.format("Running all validators on: %s\n", modPath))

    local allPassed = true
    local results = {}

    for _, validator in ipairs(validators) do
        print(string.format("Running %s...", validator))
        local cmd = string.format('lovec "%s" "%s" --json', validator, modPath)
        local handle = io.popen(cmd)
        local output = handle:read("*all")
        local success = handle:close()

        -- Parse JSON output
        local json = require("tools.common.json")
        local result = json.decode(output)

        table.insert(results, {
            validator = validator,
            result = result
        })

        if not result.success then
            allPassed = false
            print("  ❌ FAILED")
        else
            print("  ✅ PASSED")
        end
    end

    -- Summary
    print("\n" .. string.rep("=", 60))
    if allPassed then
        print("✅ ALL VALIDATORS PASSED")
    else
        print("❌ SOME VALIDATORS FAILED")
    end

    Output.exit(allPassed)
end

main({...})
```

**tools/validators/README.md:**
```markdown
# Validators

Tools for validating mod content.

## Available Validators

### validate_mod.lua
**Purpose:** Validate mod TOML files against GAME_API

**Usage:**
```bash
lovec tools/validators/validate_mod.lua mods/core
lovec tools/validators/validate_mod.lua mods/core --json
```

**Checks:**
- TOML syntax
- Field types
- Required fields
- Enum values
- Value ranges

### validate_content.lua
**Purpose:** Validate mod internal consistency

**Usage:**
```bash
lovec tools/validators/validate_content.lua mods/core
```

**Checks:**
- Reference integrity
- Tech tree cycles
- Asset existence
- Balance issues

### validate_assets.lua
**Purpose:** Verify all referenced assets exist

**Usage:**
```bash
lovec tools/validators/validate_assets.lua mods/core
```

**Checks:**
- Sprite files exist
- Sound files exist
- Correct formats
- Correct dimensions

### validate_references.lua
**Purpose:** Check all entity references are valid

**Usage:**
```bash
lovec tools/validators/validate_references.lua mods/core
```

**Checks:**
- All referenced entities exist
- No circular references
- No orphaned entities

### validate_all.lua
**Purpose:** Run all validators at once

**Usage:**
```bash
lovec tools/validators/validate_all.lua mods/core
```

## VS Code Tasks

Use tasks to run validators:
- `Ctrl+Shift+P` → "Run Task" → "🔍 Validate: All"
- `Ctrl+Shift+P` → "Run Task" → "🔍 Validate: API"
- `Ctrl+Shift+P` → "Run Task" → "🔍 Validate: Content"
```

**Estimated time:** 6-8 hours

---

### Step 6: Move/Create Generator Tools
**Description:** Organize all generators

**Move existing generators:**
```bash
# From TASK-003
mv <location> tools/generators/generate_mock_data.lua
```

**Create new generators:**

**tools/generators/generate_mod_template.lua:**
```lua
-- Generate new mod template

local function createModTemplate(modName, outputPath)
    local structure = {
        "mod.toml",
        "README.md",
        "rules/units/",
        "rules/items/weapons/",
        "rules/items/armor/",
        "rules/research/",
        "rules/facilities/",
        "rules/crafts/",
        "assets/sprites/",
        "assets/sounds/"
    }

    -- Create mod.toml
    local modToml = string.format([[
[mod]
id = "%s"
name = "%s"
version = "1.0.0"
author = "Your Name"
description = "Brief description of your mod"

[load_order]
priority = 10

[tags]
tags = ["custom", "content"]
]], modName, modName)

    -- Create README.md
    local readme = string.format([[
# %s

## Description

Brief description of your mod.

## Features

- Feature 1
- Feature 2

## Installation

1. Copy this folder to `mods/%s`
2. Enable in game settings

## Credits

Created by Your Name
]], modName, modName)

    -- Write files and create directories
    -- (implementation...)

    print(string.format("✅ Created mod template: %s", outputPath))
end

local args = {...}
if #args < 2 then
    print("Usage: lovec generate_mod_template.lua <mod_name> <output_path>")
    os.exit(1)
end

createModTemplate(args[1], args[2])
```

**tools/generators/README.md:**
```markdown
# Generators

Tools for generating content.

## Available Generators

### generate_mock_data.lua
**Purpose:** Generate synthetic test data

**Usage:**
```bash
lovec tools/generators/generate_mock_data.lua --output mods/synth_mod --strategy coverage
```

### generate_mod_template.lua
**Purpose:** Create new mod scaffold

**Usage:**
```bash
lovec tools/generators/generate_mod_template.lua my_new_mod mods/my_new_mod
```

### generate_unit.lua
**Purpose:** Generate unit entity template

**Usage:**
```bash
lovec tools/generators/generate_unit.lua --name "My Unit" --type soldier --output mods/core/rules/units/my_unit.toml
```
```

**Estimated time:** 5-6 hours

---

### Step 7: Move/Create Analyzer Tools
**Description:** Organize all analyzers

**Move existing analyzers:**
```bash
# From TASK-009
mv <location> tools/analyzers/analyze_mod_content.lua
```

**Create new analyzers:**

**tools/analyzers/analyze_coverage.lua:**
```lua
-- Analyze API coverage of a mod

local function analyzeCoverage(modPath, apiPath)
    -- Load GAME_API
    local api = loadGameAPI(apiPath)

    -- Load mod content
    local modContent = loadModContent(modPath)

    -- Check coverage for each entity type
    local coverage = {}

    for entityType, apiDef in pairs(api) do
        coverage[entityType] = {
            total_fields = 0,
            used_fields = 0,
            unused_fields = {}
        }

        -- Count fields in API
        for field in pairs(apiDef.fields) do
            coverage[entityType].total_fields = coverage[entityType].total_fields + 1
        end

        -- Check which fields are used in mod
        for entity in pairs(modContent[entityType] or {}) do
            for field in pairs(entity) do
                if apiDef.fields[field] then
                    coverage[entityType].used_fields = coverage[entityType].used_fields + 1
                end
            end
        end

        -- Find unused fields
        for field in pairs(apiDef.fields) do
            local used = false
            for entity in pairs(modContent[entityType] or {}) do
                if entity[field] then
                    used = true
                    break
                end
            end
            if not used then
                table.insert(coverage[entityType].unused_fields, field)
            end
        end
    end

    -- Output report
    print("# API Coverage Report\n")
    for entityType, cov in pairs(coverage) do
        local percentage = (cov.used_fields / cov.total_fields) * 100
        print(string.format("## %s: %.1f%%", entityType, percentage))
        print(string.format("  Used: %d/%d fields", cov.used_fields, cov.total_fields))
        if #cov.unused_fields > 0 then
            print("  Unused fields: " .. table.concat(cov.unused_fields, ", "))
        end
        print("")
    end
end

local args = {...}
if #args < 2 then
    print("Usage: lovec analyze_coverage.lua <mod_path> <api_path>")
    os.exit(1)
end

analyzeCoverage(args[1], args[2])
```

**tools/analyzers/README.md:**
```markdown
# Analyzers

Tools for analyzing content.

## Available Analyzers

### analyze_mod_content.lua
**Purpose:** Audit and categorize mod content

**Usage:**
```bash
lovec tools/analyzers/analyze_mod_content.lua mods/core
```

### analyze_coverage.lua
**Purpose:** Check API coverage

**Usage:**
```bash
lovec tools/analyzers/analyze_coverage.lua mods/core api/GAME_API.toml
```

### analyze_balance.lua
**Purpose:** Analyze game balance

**Usage:**
```bash
lovec tools/analyzers/analyze_balance.lua mods/core
```

### analyze_dependencies.lua
**Purpose:** Generate dependency graph

**Usage:**
```bash
lovec tools/analyzers/analyze_dependencies.lua mods/core --output temp/dependencies.dot
```
```

**Estimated time:** 6-7 hours

---

### Step 8: Create VS Code Tasks for All Tools
**Description:** Add VS Code tasks for each tool

**Add to .vscode/tasks.json:**
```json
{
  "version": "2.0.0",
  "tasks": [
    // VALIDATORS
    {
      "label": "🔍 Validate: All (current mod)",
      "type": "shell",
      "command": "C:\\Program Files\\LOVE\\lovec.exe",
      "args": [
        "tools/validators/validate_all.lua",
        "${input:modPath}"
      ],
      "group": {
        "kind": "test",
        "isDefault": false
      },
      "presentation": {
        "reveal": "always",
        "panel": "dedicated"
      },
      "problemMatcher": {
        "owner": "validator",
        "fileLocation": ["relative", "${workspaceFolder}"],
        "pattern": {
          "regexp": "^(Error|Warning):\\s+(.*)\\s+in\\s+(.*)$",
          "severity": 1,
          "message": 2,
          "file": 3
        }
      }
    },
    {
      "label": "🔍 Validate: API (core mod)",
      "type": "shell",
      "command": "C:\\Program Files\\LOVE\\lovec.exe",
      "args": [
        "tools/validators/validate_mod.lua",
        "mods/core"
      ],
      "group": "test",
      "presentation": {
        "reveal": "always"
      }
    },
    {
      "label": "🔍 Validate: Content (core mod)",
      "type": "shell",
      "command": "C:\\Program Files\\LOVE\\lovec.exe",
      "args": [
        "tools/validators/validate_content.lua",
        "mods/core"
      ],
      "group": "test"
    },
    {
      "label": "🔍 Validate: Assets (core mod)",
      "type": "shell",
      "command": "C:\\Program Files\\LOVE\\lovec.exe",
      "args": [
        "tools/validators/validate_assets.lua",
        "mods/core"
      ],
      "group": "test"
    },
    {
      "label": "🔍 Validate: messy_mod (should FAIL)",
      "type": "shell",
      "command": "C:\\Program Files\\LOVE\\lovec.exe",
      "args": [
        "tools/validators/validate_all.lua",
        "mods/messy_mod"
      ],
      "group": "test"
    },

    // GENERATORS
    {
      "label": "🎲 Generate: Mock Data",
      "type": "shell",
      "command": "C:\\Program Files\\LOVE\\lovec.exe",
      "args": [
        "tools/generators/generate_mock_data.lua",
        "--output", "${input:outputPath}",
        "--strategy", "${input:generationStrategy}"
      ],
      "group": "build"
    },
    {
      "label": "🎲 Generate: New Mod Template",
      "type": "shell",
      "command": "C:\\Program Files\\LOVE\\lovec.exe",
      "args": [
        "tools/generators/generate_mod_template.lua",
        "${input:modName}",
        "mods/${input:modName}"
      ],
      "group": "build"
    },

    // ANALYZERS
    {
      "label": "📊 Analyze: Mod Content",
      "type": "shell",
      "command": "C:\\Program Files\\LOVE\\lovec.exe",
      "args": [
        "tools/analyzers/analyze_mod_content.lua",
        "${input:modPath}"
      ],
      "group": "none"
    },
    {
      "label": "📊 Analyze: API Coverage",
      "type": "shell",
      "command": "C:\\Program Files\\LOVE\\lovec.exe",
      "args": [
        "tools/analyzers/analyze_coverage.lua",
        "${input:modPath}",
        "api/GAME_API.toml"
      ],
      "group": "none"
    },
    {
      "label": "📊 Analyze: Balance",
      "type": "shell",
      "command": "C:\\Program Files\\LOVE\\lovec.exe",
      "args": [
        "tools/analyzers/analyze_balance.lua",
        "${input:modPath}"
      ],
      "group": "none"
    },

    // CONVERTERS
    {
      "label": "🔄 Convert: Legacy Mod",
      "type": "shell",
      "command": "C:\\Program Files\\LOVE\\lovec.exe",
      "args": [
        "tools/converters/convert_legacy_mod.lua",
        "${input:modPath}",
        "--output", "${input:outputPath}"
      ],
      "group": "none"
    },

    // DOCUMENTATION
    {
      "label": "📚 Docs: Generate API Documentation",
      "type": "shell",
      "command": "C:\\Program Files\\LOVE\\lovec.exe",
      "args": [
        "tools/docs/generate_api_docs.lua",
        "api/GAME_API.toml",
        "--output", "docs/generated/"
      ],
      "group": "none"
    },

    // ASSETS
    {
      "label": "🎨 Assets: Verify All",
      "type": "shell",
      "command": "C:\\Program Files\\LOVE\\lovec.exe",
      "args": [
        "tools/assets/verify_assets.lua",
        "${input:modPath}"
      ],
      "group": "test"
    },

    // DEVELOPMENT
    {
      "label": "🛠️ Dev: Check Project Health",
      "type": "shell",
      "command": "C:\\Program Files\\LOVE\\lovec.exe",
      "args": [
        "tools/dev/check_health.lua"
      ],
      "group": "none"
    }
  ],

  "inputs": [
    {
      "id": "modPath",
      "type": "promptString",
      "description": "Path to mod folder",
      "default": "mods/core"
    },
    {
      "id": "outputPath",
      "type": "promptString",
      "description": "Output path",
      "default": "temp/output"
    },
    {
      "id": "modName",
      "type": "promptString",
      "description": "Mod name"
    },
    {
      "id": "generationStrategy",
      "type": "pickString",
      "description": "Generation strategy",
      "options": ["coverage", "realistic", "stress", "minimal"],
      "default": "coverage"
    }
  ]
}
```

**Estimated time:** 4-5 hours

---

### Step 9: Create Keyboard Shortcuts
**Description:** Add keybindings for common tasks

**Add to .vscode/keybindings.json:**
```json
[
  {
    "key": "ctrl+shift+v ctrl+a",
    "command": "workbench.action.tasks.runTask",
    "args": "🔍 Validate: All (current mod)"
  },
  {
    "key": "ctrl+shift+v ctrl+m",
    "command": "workbench.action.tasks.runTask",
    "args": "🔍 Validate: API (core mod)"
  },
  {
    "key": "ctrl+shift+v ctrl+c",
    "command": "workbench.action.tasks.runTask",
    "args": "🔍 Validate: Content (core mod)"
  },
  {
    "key": "ctrl+shift+g ctrl+m",
    "command": "workbench.action.tasks.runTask",
    "args": "🎲 Generate: Mock Data"
  },
  {
    "key": "ctrl+shift+a ctrl+m",
    "command": "workbench.action.tasks.runTask",
    "args": "📊 Analyze: Mod Content"
  },
  {
    "key": "ctrl+shift+a ctrl+c",
    "command": "workbench.action.tasks.runTask",
    "args": "📊 Analyze: API Coverage"
  }
]
```

**Estimated time:** 1-2 hours

---

### Step 10: Create tools/README.md Index
**Description:** Master index of all tools

**tools/README.md:**
```markdown
# Tools Directory

Development tools for AlienFall.

## Quick Access

**VS Code Tasks:** Press `Ctrl+Shift+P` → "Run Task" → Select tool

**Command Line:** `lovec tools/<category>/<tool>.lua [args]`

## Tool Categories

### 🔍 Validators (`tools/validators/`)
Verify correctness of mods and content.

| Tool | Purpose | VS Code Task | Shortcut |
|------|---------|-------------|----------|
| `validate_all.lua` | Run all validators | 🔍 Validate: All | `Ctrl+Shift+V A` |
| `validate_mod.lua` | API validation | 🔍 Validate: API | `Ctrl+Shift+V M` |
| `validate_content.lua` | Content validation | 🔍 Validate: Content | `Ctrl+Shift+V C` |
| `validate_assets.lua` | Asset verification | 🔍 Validate: Assets | - |
| `validate_references.lua` | Reference checking | 🔍 Validate: References | - |

[Full documentation](validators/README.md)

### 🎲 Generators (`tools/generators/`)
Generate content and templates.

| Tool | Purpose | VS Code Task | Shortcut |
|------|---------|-------------|----------|
| `generate_mock_data.lua` | Synthetic data | 🎲 Generate: Mock Data | `Ctrl+Shift+G M` |
| `generate_mod_template.lua` | New mod scaffold | 🎲 Generate: Mod Template | - |
| `generate_unit.lua` | Unit template | - | - |
| `generate_item.lua` | Item template | - | - |

[Full documentation](generators/README.md)

### 📊 Analyzers (`tools/analyzers/`)
Analyze content and statistics.

| Tool | Purpose | VS Code Task | Shortcut |
|------|---------|-------------|----------|
| `analyze_mod_content.lua` | Content audit | 📊 Analyze: Mod Content | `Ctrl+Shift+A M` |
| `analyze_coverage.lua` | API coverage | 📊 Analyze: API Coverage | `Ctrl+Shift+A C` |
| `analyze_balance.lua` | Balance analysis | 📊 Analyze: Balance | - |
| `analyze_dependencies.lua` | Dependency graph | - | - |

[Full documentation](analyzers/README.md)

### 🔄 Converters (`tools/converters/`)
Convert between formats.

| Tool | Purpose | VS Code Task |
|------|---------|-------------|
| `convert_legacy_mod.lua` | Upgrade old mods | 🔄 Convert: Legacy Mod |
| `convert_json_to_toml.lua` | JSON → TOML | - |
| `convert_toml_to_json.lua` | TOML → JSON | - |

[Full documentation](converters/README.md)

### 📚 Documentation Tools (`tools/docs/`)
Generate and validate documentation.

| Tool | Purpose | VS Code Task |
|------|---------|-------------|
| `generate_api_docs.lua` | API documentation | 📚 Docs: Generate API |
| `generate_mod_docs.lua` | Mod documentation | - |
| `validate_docs.lua` | Doc validation | - |

[Full documentation](docs/README.md)

### 🎨 Asset Tools (`tools/assets/`)
Manage game assets.

| Tool | Purpose | VS Code Task |
|------|---------|-------------|
| `verify_assets.lua` | Asset verification | 🎨 Assets: Verify All |
| `optimize_sprites.lua` | Sprite optimization | - |
| `generate_asset_manifest.lua` | Asset listing | - |

[Full documentation](assets/README.md)

### 🛠️ Development Tools (`tools/dev/`)
Development workflow utilities.

| Tool | Purpose | VS Code Task |
|------|---------|-------------|
| `check_health.lua` | Project health check | 🛠️ Dev: Check Health |
| `setup_workspace.lua` | Workspace setup | - |
| `create_release.lua` | Package release | - |

[Full documentation](dev/README.md)

## For AI Agents

All tools support `--json` flag for machine-readable output:

```bash
lovec tools/validators/validate_mod.lua mods/core --json
```

Output format:
```json
{
  "success": true,
  "summary": { "total": 42, "passed": 40, "failed": 2 },
  "errors": [...],
  "warnings": [...]
}
```

### Discovering Tools

List all available tools:
```bash
# List validators
ls tools/validators/*.lua

# List generators
ls tools/generators/*.lua

# etc.
```

### Running Tools

```bash
# Validate a mod
lovec tools/validators/validate_mod.lua mods/core

# Generate mock data
lovec tools/generators/generate_mock_data.lua --output mods/test --strategy coverage

# Analyze content
lovec tools/analyzers/analyze_mod_content.lua mods/core
```

## Tool Standard

All tools follow a common standard. See [TOOL_STANDARD.md](TOOL_STANDARD.md).

## Contributing

When adding new tools:
1. Follow [TOOL_STANDARD.md](TOOL_STANDARD.md)
2. Add to appropriate category folder
3. Update category README.md
4. Update this index
5. Add VS Code task (optional)
6. Add keyboard shortcut (optional)
```

**Estimated time:** 3-4 hours

---

### Step 11: Test All Tools
**Description:** Verify all tools work

**Test matrix:**

| Tool | Test Command | Expected Result |
|------|-------------|----------------|
| validate_all.lua | `lovec tools/validators/validate_all.lua mods/core` | ✅ PASS |
| validate_mod.lua | `lovec tools/validators/validate_mod.lua mods/messy_mod` | ❌ FAIL |
| generate_mock_data.lua | `lovec tools/generators/generate_mock_data.lua --output temp/test --strategy minimal` | ✅ Creates mod |
| analyze_mod_content.lua | `lovec tools/analyzers/analyze_mod_content.lua mods/core` | ✅ Outputs report |
| ... | (test all tools) | ... |

**VS Code task testing:**
```
1. Press Ctrl+Shift+P
2. Type "Run Task"
3. Select each task
4. Verify it runs correctly
5. Check output
```

**Keyboard shortcut testing:**
```
1. Press each shortcut
2. Verify correct task runs
```

**Estimated time:** 4-5 hours

---

### Step 12: Update Documentation
**Description:** Document tool organization

**Files to update:**

**README.md:**
Add section:
```markdown
## Development Tools

All development tools are in `tools/`:
- **Validators:** Verify mod correctness
- **Generators:** Create content
- **Analyzers:** Analyze content
- **Converters:** Format conversion
- **Documentation:** Generate docs
- **Assets:** Asset management
- **Dev:** Development utilities

**Quick access via VS Code tasks:**
- Press `Ctrl+Shift+P`
- Type "Run Task"
- Select tool

[Full tool documentation](tools/README.md)
```

**api/MODDING_GUIDE.md:**
Add section on validation:
```markdown
## Validating Your Mod

Use validators to check your mod:

```bash
# Validate API compliance
lovec tools/validators/validate_mod.lua mods/your_mod

# Validate content
lovec tools/validators/validate_content.lua mods/your_mod

# Run all validators
lovec tools/validators/validate_all.lua mods/your_mod
```

Or use VS Code task: `🔍 Validate: All`
```

**tests/README.md:**
Add section on test tools:
```markdown
## Testing Tools

Tools for testing in `tools/testing/`:
- `create_test_mod.lua` - Create test mod
- `compare_mods.lua` - Diff two mods
- `benchmark_mod.lua` - Performance testing
```

**Estimated time:** 2-3 hours

---

## Implementation Details

### Architecture

**Centralized tools/ Structure:**
```
tools/
├── common/ (shared utilities)
├── validators/ (verification)
├── generators/ (creation)
├── analyzers/ (analysis)
├── converters/ (transformation)
├── testing/ (test utilities)
├── docs/ (documentation)
├── assets/ (asset management)
└── dev/ (development workflow)
```

**VS Code Integration:**
- Tasks for each tool
- Keyboard shortcuts for common tools
- Problem matchers for validators
- Input prompts for arguments

**AI Agent Support:**
- JSON output for all tools
- Discoverable via file system
- Runnable via tasks
- Standardized interface

### Key Components

**Common Libraries:**
- `cli.lua` - Argument parsing
- `output.lua` - Output formatting
- `utils.lua` - Shared utilities

**Tool Standard:**
- Consistent CLI interface
- Standard exit codes
- JSON output support
- Help text

**VS Code Tasks:**
- Task per tool
- Input prompts
- Problem matchers
- Keyboard shortcuts

### Dependencies

- TASK-001 (GAME_API.toml) - for validators
- TASK-002 (API validator) - existing tool
- TASK-003 (mock generator) - existing tool
- TASK-004 (content validator) - existing tool
- TASK-009 (mod organization) - for testing

---

## Testing Strategy

### Tool Testing
- [ ] Each tool runs without errors
- [ ] --help shows help text
- [ ] --version shows version
- [ ] --json outputs valid JSON
- [ ] Exit codes correct

### VS Code Task Testing
- [ ] All tasks listed
- [ ] All tasks run
- [ ] Input prompts work
- [ ] Problem matchers work
- [ ] Keyboard shortcuts work

### Integration Testing
- [ ] Tools work together
- [ ] validate_all runs all validators
- [ ] Generators create valid content
- [ ] Validators catch errors

---

## Documentation Updates

### Files to Create
- [ ] `tools/README.md` - master index
- [ ] `tools/TOOL_STANDARD.md` - tool standard
- [ ] `tools/common/` - common libraries
- [ ] `tools/*/README.md` - category docs
- [ ] `.vscode/tasks.json` - VS Code tasks
- [ ] `.vscode/keybindings.json` - keyboard shortcuts

### Files to Update
- [ ] `README.md` - add tools section
- [ ] `api/MODDING_GUIDE.md` - validation info
- [ ] `tests/README.md` - test tools info

---

## Notes

**Tool Organization Benefits:**
- Easy to find tools
- Consistent interface
- VS Code integration
- AI Agent friendly
- Better developer experience

**AI Agent Usage:**
AI Agent can:
1. List available tasks: `Ctrl+Shift+P` → "Run Task"
2. Run tools via tasks
3. Parse JSON output
4. Chain tools together

**Keyboard Shortcuts:**
Common tools have shortcuts:
- `Ctrl+Shift+V A` - Validate all
- `Ctrl+Shift+G M` - Generate mock data
- `Ctrl+Shift+A M` - Analyze mod content

---

## Blockers

**Must have:**
- [ ] TASK-002 completed (API validator)
- [ ] TASK-003 completed (mock generator)
- [ ] TASK-004 completed (content validator)
- [ ] TASK-009 completed (mods organized)

**Potential issues:**
- Finding all scattered tools
- Standardizing tool interfaces
- VS Code task configuration
- Keyboard shortcut conflicts

---

## Review Checklist

- [ ] All tools moved to tools/
- [ ] tools/ structure organized
- [ ] Common libraries created
- [ ] Tool standard documented
- [ ] All tools follow standard
- [ ] VS Code tasks created
- [ ] Keyboard shortcuts configured
- [ ] All tools tested
- [ ] Documentation complete
- [ ] AI Agent can use tools

---

## Success Criteria

**Task is DONE when:**
1. All tools organized in tools/
2. Each category has README
3. Common libraries implemented
4. Tool standard documented
5. All tools follow standard
6. VS Code tasks created for all tools
7. Keyboard shortcuts configured
8. All tools tested and working
9. Master index complete
10. AI Agent can discover and use tools

**This enables:**
- Easy tool discovery
- Consistent tool usage
- VS Code integration
- AI Agent automation
- Better developer workflow
