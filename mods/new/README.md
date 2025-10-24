# New Mod Template

## Goal / Purpose

The New mod folder is a template for creating new custom mods. Start here to add your own content and extensions to AlienFall.

## Content

- **rules/** - Game rule configurations
  - **battle/** - Battle-specific rules
  - **item/** - Item definitions
  - **unit/** - Unit definitions
- **assets/** - Custom game assets
  - **fonts/** - Custom fonts
  - **sounds/** - Custom audio
  - **terrain/** - Custom terrain
  - **unit weapons/** - Unit-specific weapons
  - **units/** - Unit artwork
- **mapblocks/** - Custom tactical map blocks
- **faces/** - Character face artwork
- **mod.toml** - Mod manifest and metadata

## Features

- **Pre-organized Structure**: Ready for content
- **Multiple Content Types**: Can add all types
- **Asset Support**: Folder for custom graphics/audio
- **Flexible**: Use what you need, remove what you don't
- **Documented**: Each folder explains purpose

## Getting Started

1. **Review mod.toml** - Understand your mod definition
2. **Choose content types** - What will your mod add?
3. **Follow examples** - Reference core mod for format
4. **Add your content** - Create TOML files
5. **Test** - Load in game and verify

## Content Organization

- **rules/** for game rule overrides
- **assets/** for custom graphics/audio
- **mapblocks/** for tactical maps
- **faces/** for character portraits

## Customization Tips

1. Keep mod.toml metadata updated
2. Follow API documentation for formats
3. Reference core mod for examples
4. Test balance and interactions
5. Document any unique features

## See Also

- [Mods README](../README.md) - Modding system overview
- [Core Mod](../core/README.md) - Base game content
- [Examples](../examples/README.md) - Example mods
- [API Documentation](../../api/README.md) - Configuration specs
- [Mod System](../../engine/mods/README.md) - Technical implementation
