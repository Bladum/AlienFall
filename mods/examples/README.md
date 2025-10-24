# Example Mods

## Goal / Purpose

The Examples folder contains example mod implementations demonstrating how to create and structure custom mods for AlienFall. These serve as reference implementations and templates for mod development.

## Content

- **complete/** - Complete example mod with all features
- **minimal/** - Minimal example mod showing basic structure

## Features

- **Reference Implementations**: How to properly structure mods
- **Best Practices**: Recommended patterns and organization
- **Documentation**: Comments and guides in example code
- **Reusable Structure**: Can be copied and modified
- **Multiple Complexity Levels**: Minimal to comprehensive examples
- **Testing**: Examples can be loaded and tested

## Integrations with Other Systems

### Mod System
- Examples loaded by `engine/mods/mod_manager.lua`
- Demonstrate mod loading and initialization
- Show mod override system

### Content System
- Show how to define units, weapons, facilities
- Demonstrate configuration format
- Examples of content organization

### Design Documentation
- Reference for `design/mechanics/`
- Show how design translates to content
- Demonstrate TOML usage

### API Documentation
- Implement APIs from `api/`
- Practical examples of API usage
- Configuration format examples

## Getting Started with Mods

1. Copy `minimal/` or `complete/` as starting point
2. Rename and customize `mod.toml`
3. Add your content files
4. Test with game loading system
5. Refer to core mod for advanced examples

## See Also

- [Mods README](../README.md) - Modding system overview
- [Core Mod](../core/README.md) - Base game content
- [Complete Example](./complete/README.md) - Full featured example
- [Minimal Example](./minimal/README.md) - Simple starter example
- [Mod System](../../engine/mods/README.md) - Technical implementation
