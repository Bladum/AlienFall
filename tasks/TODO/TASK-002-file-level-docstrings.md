# TASK-002: Add FILE-LEVEL Google-Style Docstrings to All Engine Files

## Task Information
- **Task ID**: TASK-002
- **Created**: 2025-10-14
- **Status**: TODO
- **Priority**: HIGH
- **Estimated Time**: 8-10 hours
- **Assignee**: AI Agent

## Overview and Purpose

Add comprehensive FILE-LEVEL docstrings at the TOP of every single .lua file in the engine/ folder. This is NOT about method/class docstrings - this is ONLY about the module-level documentation at the very beginning of each file.

**CRITICAL REQUIREMENTS:**
- Docstring MUST be at the very top of the file (line 1)
- Docstring describes the ENTIRE FILE/MODULE purpose
- Use Google-style Lua docstring format with `---` comments
- Include: module description, key classes/functions, usage examples, dependencies
- NO method-level or class-level docstrings in this task
- ONLY file-level module documentation

## Requirements

### Functional Requirements
1. **FR-1**: Every .lua file in engine/ must have file-level docstring at line 1
2. **FR-2**: Docstring must describe the module's purpose and contents
3. **FR-3**: Docstring must list key exported functions/classes
4. **FR-4**: Docstring must include usage examples where applicable
5. **FR-5**: Docstring must list module dependencies

### Technical Requirements
1. **TR-1**: Use Google-style Lua docstring format with `---` prefix
2. **TR-2**: Include `@module` tag with module path
3. **TR-3**: Include `@author`, `@copyright`, `@license` tags
4. **TR-4**: Include `@see` tags for related modules
5. **TR-5**: Keep existing code unchanged, only add docstring at top

### Acceptance Criteria
- [ ] All 474 .lua files have file-level docstring
- [ ] Each docstring is at line 1 (very top of file)
- [ ] Each docstring describes module purpose comprehensively
- [ ] Each docstring lists key exports (functions, classes, tables)
- [ ] Each docstring includes usage examples
- [ ] Each docstring lists dependencies
- [ ] Game still runs without errors after all changes
- [ ] No method/class docstrings added (only file-level)

## Detailed Plan

### Step 1: Create Docstring Template (15 min)
**Files**: `tasks/TODO/docstring_template.lua`
**Action**: Create standard template for file-level docstrings
**Example Template**:
```lua
---Module Short Description
---
---Longer description explaining what this module does, its role in the engine,
---and how it fits into the overall architecture.
---
---Key Exports:
---  - functionName(): Description
---  - ClassName: Description
---  - TABLE_CONSTANT: Description
---
---Dependencies:
---  - require("module.path"): What it's used for
---  - require("other.module"): What it's used for
---
---@module full.module.path
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Module = require("module.path")
---  Module.someFunction()
---
---@see related.module For related functionality
---@see other.module For additional context
```

### Step 2: Core Files (30 min, 2 files)
**Files**:
- `engine/main.lua`
- `engine/conf.lua`

**Action**: Add file-level docstrings describing game entry point and configuration

### Step 3: Core Systems (1 hour, 11 files)
**Files**: `engine/core/*.lua`
- `state_manager.lua`
- `assets.lua`
- `data_loader.lua`
- `audio_system.lua`
- `ui.lua`
- `team.lua`
- `spatial_hash.lua`
- `save_system.lua`
- `mapblock_validator.lua`

**Action**: Add file-level docstrings for core engine systems

### Step 4: Scenes (30 min, 8 files)
**Files**: `engine/scenes/*.lua`
- `main_menu.lua`
- `tests_menu.lua`
- `widget_showcase.lua`
- `geoscape_screen.lua`
- `basescape_screen.lua`
- `battlescape_screen.lua`
- `deployment_screen.lua`
- `interception_screen.lua`

**Action**: Add file-level docstrings for all game screens/states

### Step 5: Widgets (1.5 hours, 57 files)
**Folders**: `engine/widgets/core/`, `engine/widgets/buttons/`, `engine/widgets/containers/`, `engine/widgets/display/`, `engine/widgets/input/`, `engine/widgets/navigation/`, `engine/widgets/advanced/`, `engine/widgets/combat/`

**Action**: Add file-level docstrings to all widget files

### Step 6: Battlescape (3 hours, 174 files - LARGEST)
**Folders**: `engine/battlescape/combat/`, `engine/battlescape/maps/`, `engine/battlescape/battlefield/`, `engine/battlescape/systems/`, `engine/battlescape/rendering/`, `engine/battlescape/effects/`, `engine/battlescape/battle_ecs/`, `engine/battlescape/mapscripts/`, `engine/battlescape/logic/`, `engine/battlescape/entities/`, `engine/battlescape/ui/`, `engine/battlescape/data/`, `engine/battlescape/utils/`

**Action**: Systematically add file-level docstrings to all battlescape files

### Step 7: Geoscape (30 min, 13 files)
**Folders**: `engine/geoscape/world/`, `engine/geoscape/geography/`, `engine/geoscape/systems/`, `engine/geoscape/ui/`

**Action**: Add file-level docstrings for strategic layer

### Step 8: Remaining Modules (1.5 hours, ~40 files)
**Folders**:
- `engine/economy/` (8 files)
- `engine/politics/` (4 files)
- `engine/ai/` (3 files)
- `engine/lore/` (5 files)
- `engine/shared/` (4 files)
- `engine/utils/` (5 files)
- `engine/mods/` (1 file)
- `engine/basescape/` (2 files)
- `engine/interception/` (if any files exist)

**Action**: Complete file-level docstrings for all remaining modules

### Step 9: Verification (30 min)
**Action**: 
1. Run grep to find files without file-level docstrings
2. Check that all docstrings start at line 1
3. Verify game runs: `lovec engine`
4. Check console for errors

## Implementation Details

### Docstring Format Example

```lua
---Tactical Pathfinding System
---
---Implements A* pathfinding algorithm for tactical combat movement on a grid-based
---battlefield. Handles multi-tile units, obstacle avoidance, action point costs,
---and threat zones for tactical movement planning.
---
---Key Exports:
---  - findPath(start, goal, unit, map): Calculates optimal path
---  - getMovementCost(tile, unit): Returns AP cost for tile
---  - isValidMove(tile, unit): Checks if move is legal
---
---Dependencies:
---  - battlescape.maps.grid_map: Battlefield grid representation
---  - battlescape.combat.unit: Unit stats and properties
---  - utils.heap: Priority queue for A* algorithm
---
---@module ai.pathfinding.tactical_pathfinding
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Pathfinding = require("ai.pathfinding.tactical_pathfinding")
---  local path = Pathfinding.findPath(startTile, goalTile, unit, battlefield)
---  for _, tile in ipairs(path) do
---    unit:moveTo(tile)
---  end
---
---@see battlescape.maps.grid_map For battlefield representation
---@see battlescape.combat.unit For unit movement properties
```

### Batch Processing Strategy

Process files in batches by folder:
1. Read file to understand its purpose
2. Create appropriate file-level docstring
3. Insert at line 1 (before any existing code)
4. Verify syntax with Love2D after each batch

### Quality Checklist Per File
- [ ] Docstring starts at line 1
- [ ] Clear module description (2-3 sentences)
- [ ] Lists key exports (3-5 most important)
- [ ] Includes usage example
- [ ] Lists dependencies
- [ ] Has @module tag with correct path
- [ ] Has @see tags for related modules

## Testing Strategy

### Syntax Testing
```bash
# After each batch of files
lovec engine
```

### Verification Script
```powershell
# Find files without file-level docstrings
Get-ChildItem -Path engine -Recurse -Filter *.lua | ForEach-Object {
    $firstLine = Get-Content $_.FullName -First 1
    if (-not ($firstLine -match "^---")) {
        Write-Host "Missing docstring: $($_.FullName)"
    }
}
```

### Integration Testing
- [ ] Main menu loads
- [ ] Geoscape loads
- [ ] Battlescape loads
- [ ] Basescape loads
- [ ] No console errors

## How to Run/Debug

```bash
# Run game with console
lovec engine

# Check console output for:
# - Module loading errors
# - Syntax errors from docstrings
# - Missing dependencies
```

## Documentation Updates

### Files to Update After Completion
1. `wiki/API.md` - Add section on docstring standards
2. `wiki/DEVELOPMENT.md` - Add docstring guidelines for new files
3. `tasks/tasks.md` - Mark TASK-002 as complete

## Progress Tracking

### Files Completed: 0 / 474

#### Core (0/2)
- [ ] main.lua
- [ ] conf.lua

#### Core Systems (0/11)
- [ ] core/state_manager.lua
- [ ] core/assets.lua
- [ ] core/data_loader.lua
- [ ] core/audio_system.lua
- [ ] core/ui.lua
- [ ] core/team.lua
- [ ] core/spatial_hash.lua
- [ ] core/save_system.lua
- [ ] core/mapblock_validator.lua

#### Scenes (0/8)
- [ ] scenes/main_menu.lua
- [ ] scenes/tests_menu.lua
- [ ] scenes/widget_showcase.lua
- [ ] scenes/geoscape_screen.lua
- [ ] scenes/basescape_screen.lua
- [ ] scenes/battlescape_screen.lua
- [ ] scenes/deployment_screen.lua
- [ ] scenes/interception_screen.lua

(Continue for all 474 files...)

## Review Checklist

- [ ] All 474 files have file-level docstring
- [ ] All docstrings start at line 1
- [ ] All docstrings follow template format
- [ ] Game runs without errors
- [ ] Console shows no warnings about docstrings
- [ ] No existing code was modified (only docstrings added)
- [ ] All @module paths are correct
- [ ] All @see references are valid
- [ ] Documentation updated (API.md, DEVELOPMENT.md)

## Notes

**CRITICAL**: This task is ONLY about file-level docstrings. Do NOT add:
- Method/function docstrings
- Class docstrings
- Parameter documentation
- Return value documentation

Those are separate tasks. This task is PURELY about the top-of-file module documentation.

## Completion Criteria

Task is complete when:
1. All 474 .lua files have file-level docstring at line 1
2. Game runs successfully: `lovec engine`
3. Verification script shows 0 files missing docstrings
4. All screens load without errors
5. Documentation updated
