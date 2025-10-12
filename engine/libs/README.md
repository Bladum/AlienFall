# Libraries

Third-party libraries and dependencies.

## Overview

The libs directory contains external libraries and utilities used by the game engine.

## Files

### toml.lua
TOML (Tom's Obvious, Minimal Language) parser for configuration files.

## Usage

Libraries are loaded as standard Lua modules:

```lua
local toml = require("libs.toml")

-- Parse TOML configuration
local config = toml.parse([[
[section]
key = "value"
number = 42
]])

print(config.section.key)  -- "value"
```

## Library Management

- **Version Control**: Libraries are committed to repository
- **Compatibility**: Tested with Love2D Lua environment
- **Licensing**: Compatible with project license

## Dependencies

- **Lua 5.1**: Compatible with Love2D's Lua version
- **Filesystem**: Access to libs/ directory for loading