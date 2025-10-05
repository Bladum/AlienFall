# TOML Load for Config

## Overview
TOML configuration file loading enables mods to define custom settings and options that persist across game sessions. This human-readable format allows mod authors to create configurable parameters while providing players with clear, organized settings interfaces. Configuration files support complex data structures and validation rules.

## Mechanics
- TOML parsing for configuration files
- Setting persistence across game sessions
- Type validation and default value handling
- Nested configuration structures support
- In-game settings UI generation
- Runtime configuration reloading

## Examples
| Config Type | Structure | Use Case | Player Access |
|-------------|-----------|----------|---------------|
| Unit Balance | Stats table | Difficulty adjustment | Settings menu |
| UI Layout | Position/size | Interface customization | Mod options |
| Game Rules | Boolean flags | Gameplay variants | New game setup |

## References
- Rust - TOML configuration system
- Hugo - Configuration file format
- See also: Mod Dependencies, Lua Load for Scripts, Core Systems