# Assets & Modding System

## Table of Contents

- [Asset Types & Organization](#asset-types--organization)
- [Tileset System](#tileset-system)
- [Asset Management & Caching](#asset-management--caching)
- [Mod Creation](#mod-creation)
- [Mod Loading & Integration](#mod-loading--integration)
- [Testing & Validation](#testing--validation)
- [Mod API Documentation](#mod-api-documentation)

## Asset Types & Organization

- **Graphics**: PNG with transparency, 12×12 pixel art upscaled to 24×24 display
- **Audio**: OGG Vorbis (music), WAV (sound effects)
- **Data**: TOML configuration files with hierarchical structure and fallbacks

## Tileset System

- **Structure**: Folder-based, each tileset contains PNG variations
- **Types**: 
  - Autotiles (self-connecting)
  - Random variants
  - Animations (frame sequences)
  - Directional (8-way)
  - Static
- **Definition**: TOML specifies tile properties (walkable, cover value, priority)
- **Loading**: On-demand per map, cached during session

## Asset Management & Caching

- Tileset caching with invalidation on file changes
- Automatic save points and manual save slots with compression
- Mod asset loading with precedence system
- Asset validation and dependency tracking

## Mod Creation

### Mod Structure
- Basic folder structure for new mods
- Entry point file definition
- Asset organization conventions
- Configuration template generation
- Asset folder hierarchy (graphics/, audio/, data/)

### Mod Data Format (TOML)

Standard format for mod data definitions:

```toml
[item]
name = "item_name"
stats = { damage = 10, weight = 2 }

[unit]
class = "Soldier"
abilities = ["shoot", "move", "reload"]

[asset]
graphics = "sprites/unit.png"
audio = "sounds/footstep.ogg"
```

## Mod Loading & Integration

### Load Order
- Load core game assets and mods first
- Apply user mods in priority order
- Handle mod dependencies and conflicts
- Report missing dependencies
- Asset precedence system (later mods override earlier)

### API Integration
- Access game systems through mod API
- Event hooks for mod behavior
- Safe execution sandboxing
- Asset access through standardized paths

## Testing & Validation

### Mod Validation
- TOML syntax validation
- Required field checking
- Type validation for values
- Automated checks for common issues
- Warning system for deprecated features
- Compatibility checking with game version

### Testing Framework
- Load specific mods in test environment
- Compare expected vs actual outcomes
- Performance profiling for mod impact
- Asset loading verification
- Resource usage tracking

## Mod API Documentation

Complete reference for:
- Available functions and hooks
- Event system integration
- Asset loading and registration
- Data structure definitions
- Best practices and examples
- Asset path conventions

---

