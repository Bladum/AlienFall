# New Mod: Assets

## Goal / Purpose

The Assets folder contains custom graphics, audio, fonts, and other media files for your mod.

## Content

- **fonts/** - Custom font files
- **sounds/** - Custom audio/music files
- **terrain/** - Custom terrain textures
- **unit weapons/** - Custom weapon graphics
- **units/** - Custom unit artwork

## Features

- **Multi-media Support**: All asset types in one place
- **Organization**: Separate folders by asset type
- **Easy Access**: Clear structure for asset loading
- **Override System**: Can override core game assets

## Integrations with Other Systems

### Asset Loader
- Assets loaded by engine asset system
- Can override core game assets
- Referenced in rules/content

### Rules System
- Rules reference assets
- Weapons reference weapon graphics
- Units reference unit artwork

## See Also

- [New Mod README](../README.md) - Mod overview
- [Assets API](../../../api/ASSETS.md) - Asset system interface
- [Core Assets](../core/rules/README.md) - Asset structure
