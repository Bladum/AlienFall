# Tools Folder - Development Utilities

**Purpose:** Store development tools that automate, validate, and assist development  
**Audience:** Developers, content creators, QA engineers  
**Format:** Lua scripts, Love2D applications, documentation

---

## What Goes in tools/

### Structure
```
tools/
├── README.md                    Tools documentation
│
├── validators/                  Quality assurance tools
│   ├── toml_validator.lua      Validate TOML against schema
│   ├── asset_validator.lua     Check asset existence/format
│   ├── import_scanner.lua      Validate require() statements
│   ├── content_validator.lua   Entity reference checking
│   ├── test_quality.lua        Test completeness checker
│   ├── docs_validator.lua      Documentation link checking
│   └── architecture_drift.lua  Code vs architecture alignment
│
├── generators/                  Code/content generation
│   ├── entity_scaffold.lua     Generate entity boilerplate
│   ├── scaffold_module_tests.lua  Generate test stubs
│   ├── toml_template.lua       Generate TOML templates
│   ├── api_doc_generator.lua   Extract API from code
│   ├── module_structure.lua    Create full module structure
│   └── dependency_graph.lua    Visualize dependencies
│
├── map_editor/                  Visual map creation
│   ├── main.lua                Editor application
│   ├── grid.lua                Hex grid rendering
│   ├── tools.lua               Paint/select/erase tools
│   └── export.lua              Export to TOML
│
├── world_editor/                Geographic data editing
│   ├── main.lua                Editor application
│   ├── provinces.lua           Province editing
│   └── export.lua              Export to TOML
│
├── task/                        Task management tools
│   ├── create_task.lua         Create new task
│   ├── list_tasks.lua          List/filter tasks
│   ├── report.lua              Generate metrics
│   └── dependency_graph.lua    Visualize task dependencies
│
├── mod/                         Mod development tools
│   ├── create_mod.lua          Create new mod structure
│   ├── package.lua             Package mod for distribution
│   └── validator.lua           Validate mod completeness
│
└── qa/                          Quality assurance
    ├── run_qa_suite.lua        Run all QA checks
    ├── coverage_report.lua     Generate coverage report
    └── performance_profile.lua  Profile performance
```

---

## Core Principle: Automate the Repetitive

**Tools exist to:**
- Catch errors automatically (validators)
- Generate boilerplate consistently (generators)
- Create complex data visually (editors)
- Automate repetitive tasks (utilities)

**Key Rule:** If you do it more than twice, automate it.

---

## Content Guidelines

### What Belongs Here
- ✅ Validators (quality assurance automation)
- ✅ Generators (boilerplate creation)
- ✅ Editors (visual content creation tools)
- ✅ Task management utilities
- ✅ Mod development tools
- ✅ QA and analysis tools
- ✅ Development documentation

### What Does NOT Belong Here
- ❌ Game code - goes in engine/
- ❌ Tests - goes in tests2/
- ❌ Game content - goes in mods/
- ❌ Build/deployment scripts - goes in run/ or root

---

## Tool Categories

### Category 1: Validators

**Purpose:** Automatically catch errors before they cause problems

**TOML Validator:**
```bash
lua tools/validators/toml_validator.lua mods/my_mod/ api/GAME_API.toml

# Checks:
# - TOML syntax valid
# - Types match schema (integer vs string)
# - Values in ranges (strength in [6, 12])
# - Required fields present
# - Pattern matching (ID format)

# Example output:
✓ unit.rookie_soldier
  ✓ id: "rookie_soldier" (matches pattern)
  ✓ strength: 8 (in range [6, 12])
✗ unit.broken_unit
  ✗ strength: 15 (out of range [6, 12])
  ✗ missing required field: 'name'
```

**Asset Validator:**
```bash
lua tools/validators/asset_validator.lua mods/

# Checks:
# - All referenced files exist
# - Correct formats (PNG for images, OGG for sounds)
# - Correct dimensions (24x24 for units)
# - No orphaned assets (unreferenced files)

# Example output:
✓ units/rookie.png exists (24x24, PNG)
✗ units/veteran.png missing
✗ sounds/rifle.mp3 wrong format (should be OGG)
```

**Import Scanner:**
```bash
lua tools/validators/import_scanner.lua engine/

# Checks:
# - All require() statements resolve
# - No circular dependencies
# - No missing modules
# - Dependency graph is acyclic

# Example output:
✓ engine/unit.lua - All imports valid
✗ engine/battle.lua - Requires missing "combat_resolver"
✗ Circular: A → B → C → A
```

---

### Category 2: Generators

**Purpose:** Create consistent boilerplate automatically

**Entity Scaffolder:**
```bash
lua tools/generators/entity_scaffold.lua Pilot

# Creates:
# - engine/pilots/pilot.lua (class skeleton)
# - tests2/pilots/pilot_test.lua (test stubs)
# - api/PILOTS.md (API doc entry)
# - mods/core/rules/pilots/template.toml (TOML template)

# Output:
Generated 4 files for entity: Pilot
Next: Implement logic in engine/pilots/pilot.lua
```

**Test Scaffolder:**
```bash
lua tools/generators/scaffold_module_tests.lua engine/battlescape/unit.lua

# Analyzes unit.lua for public functions
# Generates test stubs with 3 scenarios each

# Output:
Generated: tests2/battlescape/unit_test.lua
Found 8 public functions
Created 24 test stubs (3 scenarios per function)
TODO: Implement test logic
```

**TOML Template Generator:**
```bash
lua tools/generators/toml_template.lua unit elite_soldier

# Reads schema from api/GAME_API.toml
# Generates template with all fields

# Output: elite_soldier.toml
[unit.elite_soldier]
# Unique identifier (required, pattern: ^[a-z_][a-z0-9_]*$)
id = "elite_soldier"

# Display name (required, string)
name = "Elite Soldier"

# Physical strength (required, integer, range: [6, 12])
strength = 11
```

---

### Category 3: Editors

**Purpose:** Visual tools for complex data creation

**Map Editor:**
```bash
lovec tools/map_editor/

# Features:
# - Visual hex grid (20x20 tiles)
# - Tile painting (grass, stone, water, etc.)
# - Object placement (spawn points, objectives)
# - Property editing (elevation, cover)
# - Export to map_block.toml

# Workflow:
# 1. Open editor
# 2. Paint terrain visually
# 3. Place objects
# 4. Save → exports TOML
# 5. Load in game immediately
```

**World Editor:**
```bash
lovec tools/world_editor/

# Features:
# - Visual province/region editing
# - Country boundaries
# - City/base placement
# - Resource distribution
# - Export to geoscape data

# Benefits:
# - Visual feedback immediate
# - WYSIWYG editing
# - Constraints enforced automatically
# - 10x faster than manual TOML editing
```

---

### Category 4: Task Tools

**Purpose:** Manage project work efficiently

**Task Creator:**
```bash
lua tools/task/create_task.lua "Implement Feature X" --priority=HIGH --category=Feature

# Creates: tasks/TODO/IMPLEMENT_FEATURE_X.md
# Pre-filled with:
# - Template structure
# - Metadata (date, priority, category)
# - Empty sections ready to fill
```

**Task Reporter:**
```bash
lua tools/task/report.lua

# Output:
Project Status Report
Total Tasks: 45
TODO: 15 (33%)
In Progress: 5 (11%)
Done: 25 (56%)

By Priority:
- CRITICAL: 2 (both In Progress)
- HIGH: 8 (5 TODO, 3 In Progress)

Health: GOOD ✓
```

---

## Tool Usage Patterns

### Pre-Commit Validation
```bash
# .git/hooks/pre-commit

#!/bin/bash
echo "Running validators..."

# Validate TOML
lua tools/validators/toml_validator.lua mods/
if [ $? -ne 0 ]; then
    echo "❌ TOML validation failed"
    exit 1
fi

# Validate assets
lua tools/validators/asset_validator.lua mods/
if [ $? -ne 0 ]; then
    echo "❌ Asset validation failed"
    exit 1
fi

echo "✅ All validations passed"
exit 0
```

### Automated Code Generation
```bash
# Generate complete feature structure
lua tools/generators/module_structure.lua pilot_system

# Creates:
# - design/mechanics/pilot_system.md
# - api/PILOT_SYSTEM.md
# - architecture/systems/pilot_system.md
# - engine/pilot_system/init.lua
# - tests2/pilot_system/init_test.lua
# - mods/core/rules/pilot_system/defaults.toml

# Then: Fill in logic, not boilerplate
```

### Visual Content Creation
```bash
# Designer creates map visually
lovec tools/map_editor/

# Time comparison:
# Manual TOML editing: 2-4 hours
# Visual editor: 15-30 minutes
# Error rate: Manual 30%, Editor <5%
```

---

## Integration with Development Workflow

### Development → Validation
```
Developer makes changes
    ↓
Pre-commit hook runs validators
    ↓
If validation fails → Block commit, show errors
If validation passes → Allow commit
```

### Content Creation → Generation
```
Need new entity
    ↓
Run entity scaffolder
    ↓
Boilerplate created automatically
    ↓
Developer fills in logic only
```

### Complex Data → Visual Editing
```
Need new map
    ↓
Open map editor
    ↓
Paint visually (WYSIWYG)
    ↓
Save → TOML generated automatically
    ↓
Load in game immediately
```

---

## Tool Development Guidelines

### Creating a New Tool

**Step 1: Identify Need**
```
Ask:
- Is this task repetitive? (done more than twice?)
- Does it require manual validation? (error-prone?)
- Is it complex to do manually? (visual editing?)
```

**Step 2: Choose Tool Type**
```
Validator: Catches errors automatically
Generator: Creates boilerplate consistently
Editor: Visual interface for complex data
Utility: Automates specific task
```

**Step 3: Implement**
```lua
-- tools/validators/my_validator.lua

local function validate(file_path)
    -- 1. Read file
    local content = love.filesystem.read(file_path)
    
    -- 2. Parse and validate
    local errors = {}
    -- ... validation logic
    
    -- 3. Report results
    if #errors == 0 then
        print("✓ " .. file_path)
        return true
    else
        print("✗ " .. file_path)
        for _, error in ipairs(errors) do
            print("  " .. error)
        end
        return false
    end
end

return { validate = validate }
```

**Step 4: Document**
```markdown
# My Validator

## Purpose
Validates [what] against [criteria]

## Usage
```bash
lua tools/validators/my_validator.lua [file]
```

## Output
✓ Success
✗ Error with details
```

**Step 5: Integrate**
```bash
# Add to pre-commit hooks
# Add to CI/CD pipeline
# Document in tools/README.md
```

---

## Validation

### Tool Quality Checklist

- [ ] Clear purpose (solves specific problem)
- [ ] Easy to use (simple command line)
- [ ] Clear output (success/failure obvious)
- [ ] Fast execution (<5 seconds for validators)
- [ ] Documented (usage, examples)
- [ ] Error handling (doesn't crash on invalid input)
- [ ] Return codes (0 = success, 1 = failure for scripts)
- [ ] Integrated into workflow (pre-commit, CI/CD)

---

## Best Practices

### 1. Make Tools Simple to Use
```bash
# GOOD: Clear, simple command
lua tools/validators/toml_validator.lua mods/

# BAD: Complex parameters, unclear
lua tools/validate.lua --type=toml --path=mods/ --schema=api/GAME_API.toml --verbose=true
```

### 2. Provide Clear Output
```bash
# GOOD: Clear success/failure
✓ unit.rookie_soldier (all valid)
✗ unit.broken_unit (2 errors)
  - strength: 15 (out of range [6, 12])
  - missing required field: 'name'

# BAD: Cryptic output
Error in unit 2
Field error
```

### 3. Fail Fast
```bash
# Stop on first critical error
# Don't continue processing if fundamental issue
if not file_exists then
    error("File not found: " .. file_path)
    return
end
```

### 4. Return Proper Exit Codes
```lua
-- For scripts that run in CI/CD
if all_valid then
    os.exit(0)  -- Success
else
    os.exit(1)  -- Failure
end
```

### 5. Document Everything
```markdown
Each tool needs:
- Purpose (what it does)
- Usage (how to run it)
- Examples (sample commands)
- Output (what to expect)
- Integration (how it fits in workflow)
```

---

## Troubleshooting

### Tool Not Working
```
Check:
1. Is Love2D installed? (for editors)
2. Is Lua installed? (for scripts)
3. Are paths correct? (relative vs absolute)
4. Dependencies present? (required modules)
5. Permissions correct? (can read/write files)
```

### Validator False Positives
```
Check:
1. Is schema up to date?
2. Is validation logic correct?
3. Edge cases handled?
4. Type checking too strict?

Action: Review and update validator logic
```

### Generator Output Wrong
```
Check:
1. Is template up to date?
2. Are placeholders correct?
3. Is schema being read correctly?
4. File paths correct?

Action: Update generator template/logic
```

---

## Maintenance

**On API Change:**
- Update validators to match new schema
- Update generators to use new structure
- Update editors to support new fields

**Monthly:**
- Review tool effectiveness (are they being used?)
- Update documentation
- Check for new automation opportunities

**Per Release:**
- Verify all tools work with current codebase
- Update tools for any framework changes
- Document new tools added

---

**See:** tools/README.md

**Related:**
- [systems/06_AUTOMATION_TOOLS_SYSTEM.md](../systems/06_AUTOMATION_TOOLS_SYSTEM.md) - Automation tools system pattern

