# Lua Google-Style Docstring Guide for Alien Fall

This guide defines the documentation standards for all Lua code in the Alien Fall project.

## Overview

We use Google-style docstrings adapted for Lua. All public functions, modules, and classes must be documented.

---

## Module/File Header

Every Lua file should start with a header docstring:

```lua
--- Module Name
--- Brief description of what this module does.
---
--- This module provides [detailed description].
--- 
--- Example usage:
---   local ModuleName = require("path.to.module")
---   local instance = ModuleName.new()
---   instance:doSomething()
---
--- @module ModuleName
--- @author Alien Fall Team
--- @license MIT

local ModuleName = {}
```

---

## Function Documentation

### Basic Function

```lua
--- Brief description of what the function does.
---
--- Longer description with more details about behavior,
--- edge cases, or implementation notes.
---
--- @param paramName type Description of parameter
--- @param optionalParam? type Optional parameter (note the ?)
--- @return type Description of return value
--- @usage
---   local result = myFunction(value, optionalValue)
function myFunction(paramName, optionalParam)
    -- implementation
end
```

### Function with Multiple Returns

```lua
--- Calculate position and velocity.
---
--- @param time number Current time in seconds
--- @param acceleration number Acceleration value
--- @return number x position
--- @return number velocity Current velocity
function calculateMotion(time, acceleration)
    local pos = 0.5 * acceleration * time * time
    local vel = acceleration * time
    return pos, vel
end
```

### Method Documentation (Object-Oriented)

```lua
--- Create a new Unit instance.
---
--- Initializes a unit with the given class and position.
--- Loads stats from DataLoader and applies equipment modifiers.
---
--- @param classId string Unit class identifier (e.g., "soldier", "alien")
--- @param team string Team identifier
--- @param x number Grid X position
--- @param y number Grid Y position
--- @return Unit New unit instance or nil if class not found
--- @usage
---   local unit = Unit.new("soldier", "player", 5, 10)
function Unit.new(classId, team, x, y)
    -- implementation
end
```

---

## Parameter Types

Common Lua types to use in @param:
- `string` - String value
- `number` - Numeric value (integer or float)
- `boolean` - True or false
- `table` - Generic table
- `function` - Function reference
- `nil` - Nil value
- `any` - Any type
- `ClassName` - Specific class/module name (e.g., `Unit`, `Team`, `Battlefield`)
- `type1|type2` - Multiple possible types (e.g., `string|nil`)

---

## Complex Examples

### Table Parameter

```lua
--- Initialize the battlefield with configuration.
---
--- @param config table Configuration table with fields:
---   - width: number Map width in tiles
---   - height: number Map height in tiles
---   - seed: number? Optional random seed
---   - biome: string Biome type ("forest", "urban", etc.)
--- @return boolean Success status
function Battlefield:init(config)
    -- implementation
end
```

### Function with Errors

```lua
--- Load a map from file.
---
--- Reads map data from TOML file and validates structure.
--- Throws error if file doesn't exist or format is invalid.
---
--- @param filename string Path to map file
--- @return table Parsed map data
--- @error If file not found or invalid format
--- @usage
---   local success, map = pcall(MapLoader.load, "maps/forest01.toml")
---   if not success then print("Error:", map) end
function MapLoader.load(filename)
    -- implementation
end
```

---

## Class/Table Documentation

```lua
--- Unit entity representing a character in combat.
---
--- Units have stats, equipment, position, and combat state.
--- They can move, attack, and use items during combat.
---
--- Properties:
---   - id: number Unique identifier
---   - name: string Display name
---   - x, y: number Grid position
---   - health: number Current HP
---   - maxHealth: number Maximum HP
---   - team: string Team identifier
---
--- @class Unit
--- @field id number Unique identifier
--- @field name string Display name
--- @field health number Current hit points
local Unit = {}
Unit.__index = Unit
```

---

## Constants

```lua
--- Grid cell size in pixels.
--- All UI elements must align to this grid.
--- @constant
local GRID_SIZE = 24

--- Maximum units per team.
--- @constant
local MAX_UNITS = 20
```

---

## README.md Format for Folders

Each folder should have a README.md with this structure:

```markdown
# Folder Name

Brief description of folder purpose.

## Overview

Detailed explanation of what this folder contains and its role in the project.

## Files

### filename.lua
Brief description of what this file does.

### another_file.lua
Brief description of what this file does.

## Usage

Example of how to use modules in this folder:
\`\`\`lua
local Module = require("folder.module")
local instance = Module.new()
\`\`\`

## Dependencies

- List of required modules
- External dependencies

## Notes

- Important implementation details
- Known limitations
- Future improvements
```

---

## Best Practices

1. **Be Concise**: Keep descriptions clear and brief
2. **Use Examples**: Include usage examples for complex functions
3. **Document Public APIs**: All public functions must be documented
4. **Keep Updated**: Update docs when changing function signatures
5. **Explain Why**: Include reasoning for non-obvious implementations
6. **Link Related**: Reference related functions/modules in descriptions

---

## Tools

- **LuaDoc**: Can generate HTML docs from these comments
- **Language Server**: VS Code Lua extension understands @param/@return
- **Validation**: Check all public functions have docstrings

---

## Checklist for Documentation

- [ ] File header with module description
- [ ] All public functions have docstrings
- [ ] All parameters documented with types
- [ ] Return values documented
- [ ] Usage examples for complex functions
- [ ] Error conditions noted
- [ ] README.md in folder

---

## References

- Google Style Guide: https://google.github.io/styleguide/pyguide.html
- LuaDoc: https://keplerproject.github.io/luadoc/
- Lua 5.1 Manual: https://www.lua.org/manual/5.1/
