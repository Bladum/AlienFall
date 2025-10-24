# Core Mod Tilesets: Common

## Goal / Purpose

The Common folder contains shared tileset assets used across all battlescape environments. These are universal tiles that appear in multiple biomes and are foundational to map construction.

## Content

- Shared sprite definitions
- Common UI elements
- Universal props and objects
- Basic terrain types
- Shared collision definitions

## Features

- **Reusable Assets**: Assets used across environments
- **Consistency**: Common look across different maps
- **Performance**: Shared memory for common tiles
- **Standardization**: Standard tile sizes and formats
- **Flexibility**: Can be combined with environment-specific tiles

## Integrations with Other Systems

### All Tilesets
- Referenced by environment-specific tilesets
- Provides base assets for all environments
- Common layer in tile rendering

### Rendering System
- Common tiles loaded always
- Efficient sprite management
- Shared sprite batching

### Mapblocks
- Used in all map compositions
- Reduces memory through sharing
- Ensures visual consistency

## See Also

- [Tilesets README](../README.md) - Tileset overview
- [City Tilesets](../city/README.md) - Urban tiles
- [Farmland Tilesets](../farmland/README.md) - Rural tiles
- [Core Mod README](../../README.md) - Core content overview
