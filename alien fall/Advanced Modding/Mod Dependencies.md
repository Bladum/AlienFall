# Mod Dependencies

## Overview
Mod dependencies ensure that required mods are loaded in the correct order and version compatibility is maintained. This system prevents conflicts, missing features, and crashes by managing inter-mod relationships. Players receive clear guidance on required mods and potential compatibility issues.

## Mechanics
- Dependency declaration in mod metadata
- Version requirement specification
- Load order resolution and conflict detection
- Missing dependency warnings and installation prompts
- Circular dependency prevention
- Optional vs required dependency distinction

## Examples
| Dependency Type | Example | Impact | Resolution |
|-----------------|---------|--------|------------|
| Required | Core API mod | Game crash if missing | Auto-install prompt |
| Optional | UI enhancement | Feature disabled | Graceful degradation |
| Version-specific | API v2.1+ | Compatibility issues | Update requirement |

## References
- Steam Workshop - Dependency management
- Minecraft Forge - Mod compatibility system
- See also: Mod Validation, TOML Load for Config, Game API