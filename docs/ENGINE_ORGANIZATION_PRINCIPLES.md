# Engine Organization Principles

**Version:** 1.0
**Status:** Draft for Review
**Last Updated:** October 25, 2025

---

## Overview

These principles define the ideal structure for the AlienFall engine and guide all code organization decisions.

---

## Principle 1: Hierarchical Organization (Three Levels)

### Level 1: Foundation Systems
- **Folder:** `core/`, `utils/`, `assets/`
- **Purpose:** Provide infrastructure all other systems depend on
- **Characteristics:**
  - No dependencies on game logic
  - Reusable across projects
  - Core to all functionality

**Examples:**
- `core/state_manager.lua` - Game state machine
- `utils/math.lua` - Vector math utilities
- `assets/loader.lua` - Asset loading

### Level 2: Gameplay Systems
- **Folder:** `systems/` (ai, economy, politics, analytics, content, lore, tutorial)
- **Purpose:** Provide cross-layer game systems used by multiple layers
- **Characteristics:**
  - Can depend on Level 1
  - Never depend on game layers (Level 3)
  - Used by one or more game layers
  - Independent of each other (minimal interdependency)

**Examples:**
- `systems/ai/tactical_ai.lua` - AI used by battlescape and geoscape
- `systems/economy/calculator.lua` - Economy system used by geoscape and basescape
- `systems/analytics/metrics.lua` - Analytics used everywhere

### Level 3: Game Layers
- **Folder:** `layers/` (geoscape, basescape, battlescape, interception)
- **Purpose:** Implement distinct gameplay phases/screens
- **Characteristics:**
  - Can depend on Level 1 and Level 2
  - Independent of other layers (no layer-to-layer dependencies)
  - Represent distinct game states
  - Turn-based phases

**Examples:**
- `layers/geoscape/` - Strategic world management
- `layers/battlescape/` - Tactical squad combat
- `layers/basescape/` - Base administration
- `layers/interception/` - UFO interception

### Level 4: UI/Presentation (Cross-cutting)
- **Folder:** `ui/` (framework, widgets, rendering, input, localization)
- **Purpose:** Handle all user interface concerns
- **Characteristics:**
  - Can be used by any layer
  - Separate from game logic
  - Testable independently
  - Reusable components

### Dependency Flow

```
┌─────────────────────────────────┐
│   Game Layers (Level 3)         │
│ (geoscape, basescape, etc.)     │
└──────────┬──────────────────────┘
           ↓
┌─────────────────────────────────┐
│  Gameplay Systems (Level 2)     │
│ (ai, economy, politics, etc.)   │
└──────────┬──────────────────────┘
           ↓
┌─────────────────────────────────┐
│ Foundation Systems (Level 1)    │
│ (core, utils, assets, etc.)     │
└─────────────────────────────────┘

UI (Level 4) can be used by any level but shouldn't depend on game logic
```

---

## Principle 2: Single Responsibility

Each folder should have a **clear, single purpose**.

| Folder | Purpose | Contains |
|--------|---------|----------|
| `core/` | Game state infrastructure | state_manager, event_system, globals |
| `utils/` | Generic utilities | math, tables, strings, files |
| `systems/` | Cross-layer gameplay | ai, economy, politics, etc. |
| `layers/` | Game phases | geoscape, basescape, battlescape |
| `ui/` | User interface | widgets, rendering, input |
| `assets/` | Asset management | loading, caching, formats |
| `accessibility/` | Accessibility features | colorblind, screen reader, etc. |
| `mods/` | Mod system | loading, validation, integration |

**Anti-pattern:** Folder with mixed purposes
```lua
-- ❌ BAD: "utilities" folder with unrelated things
utils/
├── math.lua          ✓ math utility
├── texture_loader.lua  ✗ asset loading (should be in assets/)
├── ai_helper.lua     ✗ AI utility (should be in systems/ai/)
└── unit_behavior.lua ✗ game logic (should be in layers/)
```

---

## Principle 3: Folder Depth and File Organization

### File Organization Rules

1. **Maximum 3-4 levels deep**
   - Level 1: `engine/`
   - Level 2: `engine/systems/`
   - Level 3: `engine/systems/ai/`
   - Level 4: `engine/systems/ai/tactics/` ← maximum
   - Deeper → indicates poor organization

2. **Within Each Folder:**
   - **Main file:** `mod_name.lua` or `init.lua` (if multiple related files)
   - **Subfolders:** Only if 5+ related files

3. **File Size Limits:**
   - Max 500-1000 lines per file
   - If larger → consider splitting into module + implementations

### Examples

**Good structure:**
```
battlescape/
├── init.lua               # Module entry point
├── unit_manager.lua       # Units (200 lines)
├── movement.lua           # Movement system (300 lines)
├── combat/
│   ├── damage.lua         # Damage calculation
│   ├── hit_chance.lua     # Accuracy calculation
│   └── effects.lua        # Combat effects
├── maps/
│   ├── generator.lua      # Map generation
│   ├── renderer.lua       # Map rendering
│   └── loader.lua         # Map loading
└── ai/
    ├── tactical.lua       # Tactical AI
    └── behavior_tree.lua  # Behavior implementation
```

**Bad structure:**
```
battlescape/
├── combat_system.lua      # 2000 lines (TOO BIG)
├── stuff.lua              # Generic name
├── helpers.lua            # Too generic
├── utils/
│   ├── math.lua           # Math (belongs in core utils)
│   ├── validators.lua     # Validation (belongs in core)
│   └── ...10 more files   # Overly deep
└── nested/deeply/folder/structure/  # Too many levels
```

---

## Principle 4: File Naming Conventions

### Naming Patterns by Type

| File Type | Pattern | Example |
|-----------|---------|---------|
| Module/system | `{name}.lua` | `damage_calculator.lua` |
| Manager | `{system}_manager.lua` | `unit_manager.lua` |
| Controller | `{system}_controller.lua` | `movement_controller.lua` |
| Handler | `{event}_handler.lua` | `input_handler.lua` |
| Renderer | `{system}_renderer.lua` | `map_renderer.lua` |
| Loader | `{type}_loader.lua` | `asset_loader.lua` |
| Validator | `{type}_validator.lua` | `config_validator.lua` |
| Utils | `{domain}_utils.lua` | `math_utils.lua` |
| Init file | `init.lua` | (when grouping related files) |

### Naming Rules

1. **Use snake_case:** `unit_manager.lua` ✓, `UnitManager.lua` ✗
2. **Be specific:** `manager.lua` ✗, `unit_manager.lua` ✓
3. **Reflect domain:** `battlescape/combat/damage.lua`, not `battlescape/damage.lua`
4. **Use suffix for type:** `*_manager.lua`, `*_renderer.lua`, etc.
5. **One responsibility per file:** Single purpose in name

---

## Principle 5: Module Structure

### Consistent Module Format

Every `.lua` file should follow this structure:

```lua
---@module damage_calculator
-- Damage calculation system for battlescape combat
-- Exports: calculate(source, target) -> damage

local DamageCalculator = {}

-- ============================================================================
-- Public API
-- ============================================================================

function DamageCalculator.calculate(source, target)
    -- Implementation
end

function DamageCalculator.getModifiers(unit)
    -- Implementation
end

-- ============================================================================
-- Internal Helpers
-- ============================================================================

local function _applyArmor(damage, armor)
    -- Private helper
end

-- ============================================================================
-- Module Export
-- ============================================================================

return DamageCalculator
```

### Requirements

1. **Module comment at top** - Describe purpose in 1-2 sentences
2. **Public API section** - All exported functions documented
3. **Internal section** - Private helpers after public API
4. **Return statement** - Export table/module at end
5. **Type hints** - Use Lua type annotations (prefer @param, @return)

---

## Principle 6: Import Path Organization

### Import Path Rules

1. **Relative paths from `engine/`:**
   ```lua
   local StateManager = require("core.state_manager")
   local Math = require("utils.math")
   local AI = require("systems.ai.tactical")
   local Battlescape = require("layers.battlescape")
   ```

2. **Never use:**
   ```lua
   -- ❌ Relative paths with ./
   local StateManager = require("./core/state_manager")
   
   -- ❌ Absolute paths
   local StateManager = require("/home/user/project/engine/core/state_manager")
   
   -- ❌ Mixed separators
   local StateManager = require("core/state_manager")  -- Use . not /
   ```

3. **Module structure matches path:**
   ```lua
   -- File: engine/systems/ai/tactical.lua
   -- Import: require("systems.ai.tactical")
   ```

---

## Principle 7: Layer Organization

### Game Layers (Level 3)

Each game layer (geoscape, basescape, battlescape, interception) can have **internal subfolders** but should follow consistent patterns:

```
layers/{layer}/
├── init.lua              # Layer initialization
├── manager.lua           # Layer state management
├── ui/                   # UI specific to this layer
│   ├── panels/
│   ├── widgets/
│   └── rendering.lua
├── systems/              # Layer-specific systems
│   ├── ai.lua
│   ├── controller.lua
│   └── logic.lua
├── data/                 # Layer data structures
│   ├── state.lua
│   └── constants.lua
└── utils/                # Layer-specific utilities
    └── helpers.lua
```

### Requirements

1. **Each layer is independent** - No layer depends on another layer
2. **Layer manager** - Central state management for layer
3. **UI subfolder** - Layer-specific UI separate from logic
4. **Systems subfolder** - Layer-specific gameplay systems
5. **Clear entry point** - `init.lua` or `{layer_name}.lua`

---

## Principle 8: Cross-Layer Systems

### System Organization

Systems in `systems/` folder should be **completely independent** of game layers:

```
systems/{system}/
├── init.lua              # Module entry point
├── manager.lua           # System manager
├── calculator.lua        # Business logic
└── utils.lua             # Utilities (optional)
```

### Requirements

1. **No game logic** - Systems should be reusable
2. **No layer dependencies** - Never require layers
3. **Clear interface** - Public API well-defined
4. **Minimal coupling** - Loose dependencies between systems
5. **Configurable** - Accept parameters, don't hardcode

**Example: Good system design**
```lua
-- systems/ai/tactical.lua - ✓ GOOD
-- Can be used by any layer that has units
local TacticalAI = {}

function TacticalAI.decideAction(unit, state)
    -- unit and state are generic objects
    -- doesn't know if this is battlescape or geoscape
end

return TacticalAI
```

**Example: Bad system design**
```lua
-- systems/ai/tactical.lua - ✗ BAD
-- Tightly coupled to battlescape
local TacticalAI = {}
local Battlescape = require("layers.battlescape")  -- ❌ NO!

function TacticalAI.decideAction(unit)
    -- Now this can only work with battlescape
    Battlescape.moveUnit(unit, ...)
end

return TacticalAI
```

---

## Principle 9: UI Organization

### UI Folder Structure

```
ui/
├── framework/            # Core GUI classes
│   ├── window.lua
│   ├── panel.lua
│   └── component.lua
├── widgets/              # Reusable UI components
│   ├── button.lua
│   ├── slider.lua
│   ├── text_input.lua
│   └── menu.lua
├── rendering/            # GUI rendering
│   ├── renderer.lua
│   ├── colors.lua
│   └── fonts.lua
├── input/                # UI input handling
│   ├── keyboard.lua
│   ├── mouse.lua
│   └── controller.lua
└── localization/         # Translations
    ├── strings.lua
    ├── en.lua
    ├── es.lua
    └── loader.lua
```

### Requirements

1. **Framework vs Widgets** - Framework = base classes, Widgets = implementations
2. **Localization separate** - Easy to swap languages
3. **Rendering abstraction** - GUI code doesn't directly call Love2D
4. **Input handling** - Separate from game input
5. **Reusable components** - All widgets can be used in any layer

---

## Principle 10: Dependency Rules

### The Dependency Graph

```
Allowed:            Forbidden:
Layer → System      Layer ← System
Layer → Core        Layer → Layer
System → Core       System → Layer
UI → anything       UI → Game Logic (beyond parameters)
Core → nothing      Core → anything
```

### Violation Detection

**Violations to catch:**
```lua
-- ❌ Layer depending on layer
local Geoscape = require("layers.geoscape")  -- IN battlescape

-- ❌ System depending on layer
local Battlescape = require("layers.battlescape")  -- IN systems/ai

-- ❌ Layer depending on itself (circular)
require("layers.battlescape.ai")  -- FROM layers/battlescape

-- ❌ Core depending on anything
local System = require("systems.ai")  -- IN core
```

### Good Dependencies
```lua
-- ✓ Layer using system
local AI = require("systems.ai")  -- IN layers/battlescape

-- ✓ System using core
local Events = require("core.event_system")  -- IN systems/ai

-- ✓ Layer using core
local State = require("core.state_manager")  -- IN layers/geoscape

-- ✓ System using utils
local Math = require("utils.math")  -- IN systems/ai
```

---

## Principle 11: API Contracts

### Each Module Should Define

1. **Purpose** - What does this module do? (in header comment)
2. **Exports** - What functions/tables are public? (document in header)
3. **Dependencies** - What does this module require? (list imports)
4. **Contracts** - What do functions expect/return? (type hints)

### Example Module Header

```lua
---@module damage_calculator
-- Calculates damage in combat.
--
-- Exports:
--   calculate(attacker, defender) -> number
--   getModifiers(unit) -> table
--
-- Dependencies:
--   utils.math - Vector math
--   core.config - Configuration values
--
-- Used By:
--   layers.battlescape.combat - Damage resolution
--   systems.ai.tactical - Damage prediction

local DamageCalculator = {}

---Calculate total damage dealt by attacker to defender
---@param attacker table Unit attacking
---@param defender table Unit defending
---@return number damage Total damage dealt
function DamageCalculator.calculate(attacker, defender)
    -- Implementation
end

return DamageCalculator
```

---

## Anti-Patterns to Avoid

### 1. God Object Folders

**❌ BAD:**
```
utils/
├── everything.lua     # 3000 lines
├── helper.lua
├── math.lua
└── ...50 more files
```

**✓ GOOD:**
```
utils/
├── math.lua
├── table.lua
├── string.lua
└── file.lua
```

### 2. Circular Dependencies

**❌ BAD:**
```lua
-- systems/ai/tactical.lua
local Combat = require("systems.combat")

-- systems/combat/damage.lua
local AI = require("systems.ai.tactical")  -- CIRCULAR!
```

**✓ GOOD:**
```lua
-- Both depend on neutral core
local Config = require("core.config")
```

### 3. Layer-to-Layer Dependencies

**❌ BAD:**
```lua
-- layers/battlescape/init.lua
local Geoscape = require("layers.geoscape")  -- NO!
```

**✓ GOOD:**
```lua
-- Use core to communicate between layers
local StateManager = require("core.state_manager")
StateManager.switchLayer("geoscape")
```

### 4. Everything in Root

**❌ BAD:**
```
engine/
├── unit.lua
├── item.lua
├── weapon.lua
├── armor.lua
├── damage.lua
├── healing.lua
├── movement.lua
├── ai.lua
└── ...100 files in root
```

**✓ GOOD:**
```
engine/
└── layers/
    └── battlescape/
        ├── units.lua
        ├── combat.lua
        ├── movement.lua
        └── ai.lua
```

---

## Applying These Principles

### When Adding New Code

1. **Identify purpose** - What game system is this?
2. **Find right folder** - Level 1, 2, 3, or 4?
3. **Pick correct location** - Which specific folder?
4. **Follow naming** - Match established patterns
5. **Document APIs** - Add header comments
6. **Check dependencies** - Follow dependency rules
7. **Get review** - Have code reviewed for adherence

### When Refactoring Existing Code

1. **Audit location** - Is file in right folder?
2. **Check naming** - Does name reflect content?
3. **Verify dependencies** - Any rule violations?
4. **Test imports** - Do all requires still work?
5. **Update documentation** - Reflect new structure

---

## Validation Checklist

When reviewing code organization:

- [ ] Files in appropriate folders
- [ ] Folder purposes clear and single-focused
- [ ] Folder depth 3-4 levels maximum
- [ ] File names follow conventions
- [ ] Module structure consistent
- [ ] APIs documented
- [ ] Dependencies follow rules
- [ ] No circular dependencies
- [ ] No layer-to-layer coupling
- [ ] Systems independent of layers
- [ ] UI separate from game logic

---

## References

- **Related Task:** TASK-006 (Reorganize Engine Structure)
- **Audit Report:** `temp/engine_structure_audit.md`
- **Current Structure:** `architecture/README.md`
- **Code Standards:** `docs/CODE_STANDARDS.md`

---

**Status:** Draft - Ready for team review and refinement
