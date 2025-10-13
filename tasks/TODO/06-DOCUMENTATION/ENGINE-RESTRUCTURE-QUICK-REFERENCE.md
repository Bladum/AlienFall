# Engine Restructure - Quick Reference Guide

## File Location Lookup Table

Use this guide to find where files moved during the restructure.

---

## Core Systems (engine/core/)

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `systems/state_manager.lua` | `core/state_manager.lua` |
| `systems/assets.lua` | `core/assets.lua` |
| `systems/data_loader.lua` | `core/data_loader.lua` |
| `systems/mod_manager.lua` | `core/mod_manager.lua` |

**Require paths change:**
```lua
-- OLD
require("systems.state_manager")
require("systems.assets")
require("systems.data_loader")
require("systems.mod_manager")

-- NEW
require("core.state_manager")
require("core.assets")
require("core.data_loader")
require("core.mod_manager")
```

---

## Shared Systems (engine/shared/)

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `systems/pathfinding.lua` | `shared/pathfinding.lua` |
| `systems/spatial_hash.lua` | `shared/spatial_hash.lua` |
| `systems/team.lua` | `shared/team.lua` |
| `systems/ui.lua` | `shared/ui.lua` |

**Require paths change:**
```lua
-- OLD
require("systems.pathfinding")
require("systems.team")

-- NEW
require("shared.pathfinding")
require("shared.team")
```

---

## Battlescape (engine/battlescape/)

### UI Layer (engine/battlescape/ui/)

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `modules/battlescape/input.lua` | `battlescape/ui/input.lua` |
| `modules/battlescape/render.lua` | `battlescape/ui/render.lua` |
| `modules/battlescape/ui.lua` | `battlescape/ui/ui.lua` |
| `modules/battlescape.lua` | `battlescape/init.lua` |

### Logic Layer (engine/battlescape/logic/)

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `battle/battlefield.lua` | `battlescape/logic/battlefield.lua` |
| `battle/turn_manager.lua` | `battlescape/logic/turn_manager.lua` |
| `battle/unit_selection.lua` | `battlescape/logic/unit_selection.lua` |
| `battle/battlescape_integration.lua` | `battlescape/logic/integration.lua` |

### ECS Systems (engine/battlescape/systems/)

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `battle/systems/movement_system.lua` | `battlescape/systems/movement_system.lua` |
| `battle/systems/shooting_system.lua` | `battlescape/systems/shooting_system.lua` |
| `battle/systems/accuracy_system.lua` | `battlescape/systems/accuracy_system.lua` |
| `battle/systems/range_system.lua` | `battlescape/systems/range_system.lua` |
| `battle/systems/vision_system.lua` | `battlescape/systems/vision_system.lua` |
| `battle/systems/hex_system.lua` | `battlescape/systems/hex_system.lua` |
| `battle/systems/move_mode_system.lua` | `battlescape/systems/move_mode_system.lua` |

### ECS Components (engine/battlescape/components/)

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `battle/components/health.lua` | `battlescape/components/health.lua` |
| `battle/components/movement.lua` | `battlescape/components/movement.lua` |
| `battle/components/team.lua` | `battlescape/components/team.lua` |
| `battle/components/transform.lua` | `battlescape/components/transform.lua` |
| `battle/components/vision.lua` | `battlescape/components/vision.lua` |

### ECS Entities (engine/battlescape/entities/)

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `battle/entities/unit_entity.lua` | `battlescape/entities/unit_entity.lua` |

### Map Systems (engine/battlescape/map/)

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `battle/grid_map.lua` | `battlescape/map/grid_map.lua` |
| `battle/map_generator.lua` | `battlescape/map/map_generator.lua` |
| `battle/map_saver.lua` | `battlescape/map/map_saver.lua` |
| `battle/map_block.lua` | `battlescape/map/map_block.lua` |
| `battle/mapblock_system.lua` | `battlescape/map/mapblock_system.lua` |

### Effects Systems (engine/battlescape/effects/)

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `battle/animation_system.lua` | `battlescape/effects/animation_system.lua` |
| `battle/fire_system.lua` | `battlescape/effects/fire_system.lua` |
| `battle/smoke_system.lua` | `battlescape/effects/smoke_system.lua` |

### Rendering (engine/battlescape/rendering/)

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `battle/renderer.lua` | `battlescape/rendering/renderer.lua` |
| `battle/camera.lua` | `battlescape/rendering/camera.lua` |

### Combat Systems (engine/battlescape/combat/)

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `systems/weapon_system.lua` | `battlescape/combat/weapon_system.lua` |
| `systems/equipment_system.lua` | `battlescape/combat/equipment_system.lua` |
| `systems/action_system.lua` | `battlescape/combat/action_system.lua` |
| `systems/los_system.lua` | `battlescape/combat/los_system.lua` |
| `systems/los_optimized.lua` | `battlescape/combat/los_optimized.lua` |
| `systems/unit.lua` | `battlescape/combat/unit.lua` |
| `systems/battle_tile.lua` | `battlescape/combat/battle_tile.lua` |

### Utilities (engine/battlescape/utils/)

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `battle/utils/debug.lua` | `battlescape/utils/debug.lua` |
| `battle/utils/hex_math.lua` | `battlescape/utils/hex_math.lua` |

### Tests (engine/battlescape/tests/)

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `battle/tests/test_all_systems.lua` | `battlescape/tests/test_all_systems.lua` |
| `battle/tests/test_ecs_components.lua` | `battlescape/tests/test_ecs_components.lua` |

**Require paths change:**
```lua
-- OLD
require("modules.battlescape")
require("battle.battlefield")
require("battle.systems.movement_system")
require("systems.weapon_system")

-- NEW
require("battlescape.init")
require("battlescape.logic.battlefield")
require("battlescape.systems.movement_system")
require("battlescape.combat.weapon_system")
```

---

## Geoscape (engine/geoscape/)

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `modules/geoscape/init.lua` | `geoscape/init.lua` |
| `modules/geoscape/input.lua` | `geoscape/ui/input.lua` |
| `modules/geoscape/render.lua` | `geoscape/ui/render.lua` |
| `modules/geoscape/data.lua` | `geoscape/logic/data.lua` |
| `modules/geoscape/logic.lua` | `geoscape/logic/world_state.lua` |

**Require paths change:**
```lua
-- OLD
require("modules.geoscape.init")

-- NEW
require("geoscape.init")
```

---

## Basescape (engine/basescape/)

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `modules/basescape.lua` | `basescape/init.lua` |

**Note:** Basescape needs to be expanded into full structure with ui/, logic/, systems/, tests/ subfolders.

**Require paths change:**
```lua
-- OLD
require("modules.basescape")

-- NEW
require("basescape.init")
```

---

## Menu Screens (engine/menu/)

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `modules/menu.lua` | `menu/main_menu.lua` |
| `modules/tests_menu.lua` | `menu/tests_menu.lua` |
| `modules/widget_showcase.lua` | `menu/widget_showcase.lua` |

**Require paths change:**
```lua
-- OLD
require("modules.menu")
require("modules.tests_menu")
require("modules.widget_showcase")

-- NEW
require("menu.main_menu")
require("menu.tests_menu")
require("menu.widget_showcase")
```

---

## Tools (engine/tools/)

### Map Editor

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `modules/map_editor.lua` | `tools/map_editor/init.lua` |

### Validators

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `systems/mapblock_validator.lua` | `tools/validators/mapblock_validator.lua` |
| `utils/verify_assets.lua` | `tools/validators/asset_verifier.lua` |

**Require paths change:**
```lua
-- OLD
require("modules.map_editor")
require("systems.mapblock_validator")

-- NEW
require("tools.map_editor.init")
require("tools.validators.mapblock_validator")
```

---

## Utility Scripts (engine/scripts/)

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `run_test.lua` | `scripts/run_test.lua` |
| `run_quick_test.lua` | `scripts/run_quick_test.lua` |
| `run_asset_verification.lua` | `scripts/run_asset_verification.lua` |
| `run_mapblock_validation.lua` | `scripts/run_mapblock_validation.lua` |
| `run_range_accuracy_tests.lua` | `scripts/run_range_accuracy_tests.lua` |
| `test_runner.lua` | `scripts/test_runner.lua` |

**Note:** These are run scripts, not require'd, so no require path changes needed.

---

## Tests (engine/tests/)

### Core Tests

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| (new location) | `tests/core/` |

### Battlescape Tests

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `battle/tests/` | `tests/battlescape/` |

### Integration Tests

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `tests/test_mapblock_integration.lua` | `tests/integration/test_mapblock_integration.lua` |
| `tests/test_phase2.lua` | `tests/integration/test_phase2.lua` |

### Performance Tests

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `tests/test_performance.lua` | `tests/performance/test_performance.lua` |

### System Tests

| OLD LOCATION | NEW LOCATION |
|-------------|--------------|
| `tests/test_battle_systems.lua` | `tests/systems/test_battle_systems.lua` |
| `tests/test_los_fow.lua` | `tests/systems/test_los_fow.lua` |

---

## Unchanged Folders

These folders remain in their current location with no changes:

- ✅ `engine/widgets/` - UI widget library
- ✅ `engine/utils/` - General utilities (scaling, viewport)
- ✅ `engine/data/` - Game data files
- ✅ `engine/assets/` - Images, sounds, fonts
- ✅ `engine/libs/` - External libraries
- ✅ `engine/love_definitions/` - Love2D type definitions

---

## Common Require Patterns

### Main Entry Points

```lua
-- State Management
local StateManager = require("core.state_manager")

-- Asset Loading
local Assets = require("core.assets")

-- Game Modes
local Menu = require("menu.main_menu")
local Geoscape = require("geoscape.init")
local Battlescape = require("battlescape.init")
local Basescape = require("basescape.init")

-- Shared Systems
local Pathfinding = require("shared.pathfinding")
local Team = require("shared.team")
```

### Battlescape Internal Requires

```lua
-- Within battlescape code
local Battlefield = require("battlescape.logic.battlefield")
local TurnManager = require("battlescape.logic.turn_manager")
local Camera = require("battlescape.rendering.camera")
local WeaponSystem = require("battlescape.combat.weapon_system")
local MovementSystem = require("battlescape.systems.movement_system")
```

---

## Migration Checklist

When updating a file:

- [ ] Update all `require()` statements to use new paths
- [ ] Update any string references to file paths (error messages, logs)
- [ ] Update any dynamic requires (if using string concatenation)
- [ ] Update comments referencing other file locations
- [ ] Run the game to verify no "module not found" errors
- [ ] Check Love2D console for warnings

---

## Testing After Migration

1. **Syntax check:** Look for require errors in console
2. **Module loading:** Verify all modules load on game start
3. **Mode switching:** Test transitions between all game modes
4. **Tool access:** Verify map editor, widget showcase work
5. **Test suite:** Run `love scripts/run_test.lua`
6. **Manual play:** Play through battlescape, geoscape, basescape

---

## Rollback Instructions

If something breaks:

1. **Check console:** Look for "module 'X' not found" errors
2. **Verify paths:** Ensure file actually exists at new location
3. **Check require:** Verify require path matches new file location
4. **Git diff:** Review changes to see what was modified
5. **Revert if needed:** `git revert <commit>` or `git reset --hard`

Keep backup branch until fully validated!

---

## Quick Find Commands

### Find all require statements in a file:
```powershell
Select-String -Pattern 'require\(' -Path engine\**\*.lua
```

### Find specific require pattern:
```powershell
Select-String -Pattern 'require\("systems\.' -Path engine\**\*.lua
```

### Find all files requiring a specific module:
```powershell
Select-String -Pattern 'require\("battle\.battlefield"\)' -Path engine\**\*.lua
```

---

## Priority Order for Fixing Requires

1. **Fix main.lua first** - Entry point loads everything
2. **Fix init.lua files** - Module entry points
3. **Fix state_manager** - Manages mode transitions
4. **Fix each mode's init.lua** - Battlescape, Geoscape, Basescape
5. **Fix internal requires** - Within each mode
6. **Fix cross-mode requires** - When modes reference each other
7. **Fix test files** - After core game works

