# Battlescape Rendering

## Goal / Purpose
Handles all visual rendering for battlescape including unit sprites, terrain tiles, UI overlays, animations, and camera/viewport management.

## Content
- **Sprite rendering** - Unit and terrain sprite drawing
- **Tile rendering** - Tileset rendering and management
- **Camera system** - Viewport and camera controls
- **Layer system** - Depth sorting and layer management
- **Animation rendering** - Effect and unit animations
- **UI overlay** - In-battle UI rendering
- **Lighting system** - Lighting and shadow effects

## Features
- Efficient sprite batching
- Isometric or orthographic projection
- Smooth camera panning
- Layer-based rendering
- Animation support
- Performance optimization

## Integrations with Other Folders / Systems
- **engine/battlescape/battlefield** - Map and unit data
- **engine/battlescape/effects** - Effect rendering
- **engine/battlescape/entities** - Unit rendering
- **engine/battlescape/ui** - UI overlay rendering
- **engine/assets/images** - Sprite assets
- **engine/gui/widgets** - Widget rendering
- **engine/core/viewport.lua** - Viewport utilities
