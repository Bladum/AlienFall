# Mod Validator

## Overview
The Mod Validator is a critical system that ensures mods are compatible with the game and do not break core functionality. It performs comprehensive checks on mod structure, dependencies, and content integrity before allowing mods to load, providing essential feedback for mod developers and users.

## Mechanics
- **Structure Validation**: Verifies required files and directory structure
- **Dependency Checking**: Confirms all required dependencies are present and compatible
- **Content Integrity**: Validates data formats and references
- **Syntax Checking**: Ensures Lua scripts and TOML configs are syntactically correct
- **Version Compatibility**: Checks mod compatibility with current game version
- **Conflict Detection**: Identifies potential conflicts with other loaded mods
- **Error Reporting**: Provides detailed error messages and suggestions for fixes

## Examples
| Validation Type | Check Performed | Error Message |
|-----------------|-----------------|---------------|
| File Structure | Missing mod.toml | "mod.toml not found in mod directory" |
| Dependencies | Missing required mod | "Required mod 'example-mod' not installed" |
| Syntax Error | Invalid Lua script | "Syntax error in script.lua at line 25" |
| Version Mismatch | Incompatible game version | "Mod requires game version 2.0 or higher" |

## References
- XCOM: Mod validation prevents crashes from incompatible mods
- Steam Workshop: Content validation systems
- See Mod Loader for integration with loading process
- See Mod Dependencies for dependency validation rules