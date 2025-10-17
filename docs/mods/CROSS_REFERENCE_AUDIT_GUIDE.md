# Documentation Cross-Reference Audit Guide

## Overview

This guide explains the documentation cross-reference system and how to audit and maintain links between design documentation and engine implementation.

## Purpose

Maintaining bidirectional references between:
- **Design Documentation** (`docs/`) - "What it should do"
- **Engine Implementation** (`engine/`) - "How it actually works"

This ensures:
- Design stays synchronized with code
- Developers can find relevant documentation
- Documentation doesn't become outdated
- Changes are tracked and propagated

## Cross-Reference Format

### In Documentation Files

Use this format in design documentation to link to implementation:

```markdown
# Feature Name

Description of feature...

> **Implementation**: `engine/core/state_manager.lua`

More details...
```

Format:
- **Prefix**: `> **Implementation**: `
- **Path**: Relative from project root
- **Syntax**: Backticks around path

Example links:
- `engine/core/data_loader.lua` - Single file
- `engine/battlescape/` - Directory/module
- `engine/ui/widgets/button.lua` - Nested file

### In Engine Code

Use Lua docstring comments to reference design documentation:

```lua
--- Battle Phase Manager
--- Manages the turn-based battle system with alternating player/AI phases.
---
--- **Design Documentation**: docs/battlescape/combat-mechanics/battle_phases.md
--- **Schema**: docs/mods/toml_schemas/campaigns_schema.md
---
--- @module engine.battlescape.battle_phase_manager
local BattlePhaseManager = {}
```

Format:
- **Prefix**: `**Design Documentation**: `
- **Path**: Relative from project root
- **Syntax**: Markdown link syntax in comments

## Cross-Reference Types

### 1. Module Documentation Links

In top-level docstring:

```lua
--- @see docs/battlescape/README.md
--- @see docs/core/concepts.md
```

### 2. Function Documentation Links

In function docstring:

```lua
--- Load combat stats from TOML files.
--- @see docs/mods/toml_schemas/units_schema.md
function DataLoader.loadUnits()
```

### 3. Complex Feature Links

For major features:

```lua
--- Battle System
--- Complete turn-based combat implementation with:
--- - Unit management (docs/battlescape/unit-systems/)
--- - Combat mechanics (docs/battlescape/combat-mechanics/)
--- - Map generation (docs/battlescape/map-generation/)
```

## Validation Tools

### PowerShell Script

```bash
.\tools\validate_docs_links.ps1
```

Validates all `> **Implementation**: ` links in documentation.

**Output**:
- `validate_docs_links_report.txt` - Full report
- Console - Summary statistics

### Lua Script

```bash
lovec "tools/validate_docs_links.lua"
```

Same validation in Lua (use if PowerShell unavailable).

## Audit Process

### Step 1: Run Validator

```powershell
cd c:\Users\tombl\Documents\Projects
.\tools\validate_docs_links.ps1
```

### Step 2: Check Report

Read `validate_docs_links_report.txt`:

```
ISSUES FOUND
============

BROKEN LINKS (3)
------------------------------
File: docs/battlescape/maps.md
Link: engine/battlescape/map_generator.lua
Issue: File not found

...
```

### Step 3: Fix Issues

For each broken link:

1. **Verify correct path** - Is the file in the right location?
2. **Update link** - Fix path if file moved
3. **Add missing docs** - Create documentation if needed
4. **Add to code** - Add reference in Lua docstring

### Step 4: Verify

```powershell
.\tools\validate_docs_links.ps1
```

Ensure no errors reported.

## Standards

### Documentation Links

✅ **Good examples**:
```markdown
> **Implementation**: `engine/core/state_manager.lua`
> **Implementation**: `engine/battlescape/`
> **Implementation**: `mods/core/rules/units/`
```

❌ **Bad examples**:
```markdown
> **Implementation**: engine/core/state_manager.lua    # No backticks
Implementation: engine/core/state_manager.lua          # Wrong format
See: state_manager.lua                                 # Relative path
```

### Code Comments

✅ **Good examples**:
```lua
--- See design docs at docs/battlescape/combat_mechanics.md
--- Reference: docs/mods/toml_schemas/units_schema.md
```

❌ **Bad examples**:
```lua
--- See docs/battlescape (missing filename)
--- Look at "combat mechanics" (vague path)
```

## Best Practices

1. **Always bidirectional** - If docs link to code, code should link back
2. **Use full paths** - Always relative to project root
3. **Keep updated** - Update cross-references when files move
4. **Run validator** - Before commits, run validation
5. **Fix immediately** - Don't let broken links accumulate
6. **Document changes** - Explain link updates in commit messages

## Maintenance Schedule

- **Weekly**: `validate_docs_links.ps1` after major changes
- **Before PR**: Run validator before pull requests
- **Quarterly**: Full cross-reference audit
- **On refactoring**: Update all links when moving/renaming files

## Common Issues

### Issue: "Broken link: engine/battlescape/old_name.lua"

**Cause**: File was renamed

**Fix**:
```markdown
- Old: engine/battlescape/old_name.lua
+ New: engine/battlescape/new_name.lua
```

### Issue: "Vague link: engine/battlescape/*"

**Cause**: Link uses wildcards

**Fix**: Point to specific file or directory:
```markdown
- Old: engine/battlescape/*
+ New: engine/battlescape/battle_system.lua
  (or)
+ New: engine/battlescape/
```

### Issue: Path doesn't exist in code but docs reference it

**Cause**: Documentation references planned but not-yet-implemented file

**Solution 1**: Create the file structure (implementation task)

**Solution 2**: Update documentation to reference existing file

**Solution 3**: Mark as "PLANNED" - document when it will exist

```markdown
> **Implementation** (PLANNED): `engine/future/neural_network.lua`
> **Planned for**: Q2 2026
```

## Integration with Development

### Before Starting Work

1. Check if documentation exists for the feature
2. Note the design documentation path
3. Refer to docs while implementing
4. Add code comments linking back to docs

### During Implementation

```lua
--- Unit Combat Resolution
--- Implements turn-based combat between units.
---
--- **Design**: docs/battlescape/combat-mechanics/resolution.md
--- **Schema**: docs/mods/toml_schemas/units_schema.md
---
--- Algorithm:
--- 1. Get attacker and defender
--- 2. Calculate base damage (see docs for formula)
--- 3. Apply armor/resistance
--- 4. Modify by abilities
---
function ResolveCombat(attacker, defender)
    -- Implementation follows design doc
end
```

### Before Commit

```bash
.\tools\validate_docs_links.ps1
```

Ensure clean report before pushing.

### When Refactoring

1. Collect all cross-references
2. Update file locations
3. Run validator
4. Commit both code and docs updates

## Tools Reference

| Tool | Purpose | Command |
|------|---------|---------|
| `validate_docs_links.ps1` | Validate all doc links | `.\tools\validate_docs_links.ps1` |
| `validate_docs_links.lua` | Validate (alternative) | `lua tools/validate_docs_links.lua` |
| grep | Find cross-references | `grep -r "Implementation.*lua" docs/` |

## Troubleshooting

### Validator not finding files

1. Ensure paths are relative to project root
2. Check file exists: `Test-Path engine/core/state_manager.lua`
3. Verify no typos in paths
4. Use forward slashes: `engine/core/` not `engine\core\`

### Links working in editor but validator fails

1. Check for URL encoding issues
2. Verify file actually exists
3. Compare path case (Windows is case-insensitive but validator checks literally)

### Too many broken links

1. Run file search: Find documentation links pointing to files that were deleted
2. Either restore files or update documentation
3. Consider bulk update with search/replace if pattern matches

---

**Last Updated**: October 16, 2025  
**Validator Version**: 1.0  
**Status**: Active & Maintained
