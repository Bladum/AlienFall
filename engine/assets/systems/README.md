# Assets System

## Goal / Purpose
The Assets subsystem manages all game assets including images, fonts, and sounds. It provides centralized loading, caching, and management of game resources to optimize performance and enable dynamic asset replacement through mods.

## Content
- **Asset loaders** - Font, image, and sound loading systems
- **Asset caching** - In-memory asset storage for fast access
- **Asset registries** - Indexed asset collections for quick lookup
- **Asset verification** - Validation and error checking for assets
- **Dynamic loading** - Runtime asset loading for mod support

## Features
- Lazy loading of assets
- Asset caching and memory management
- Fallback asset handling
- Error recovery for missing assets
- Mod asset integration
- Asset hot-reloading support

## Integrations with Other Folders / Systems
- **engine/assets/images** - Image asset storage and loading
- **engine/assets/fonts** - Font asset storage and loading
- **engine/assets/sounds** - Audio asset storage and loading
- **engine/assets/systems** - Asset management systems
- **engine/core/assets.lua** - Core asset manager
- **engine/gui** - Asset usage in UI rendering
- **engine/battlescape/rendering** - Asset usage in battle rendering
- **engine/geoscape/rendering** - Asset usage in geoscape rendering
- **engine/mods** - Mod asset loading and integration
