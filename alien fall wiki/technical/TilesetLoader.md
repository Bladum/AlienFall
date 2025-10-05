# Tileset Loader

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Tileset File Format](#tileset-file-format)
  - [Loader Architecture](#loader-architecture)
  - [Tile Extraction Process](#tile-extraction-process)
  - [Memory Management](#memory-management)
  - [Cache System](#cache-system)
  - [Performance Optimization](#performance-optimization)
- [Examples](#examples)
  - [Tileset Structure Example](#tileset-structure-example)
  - [Loading Pipeline Example](#loading-pipeline-example)
  - [Memory Optimization Example](#memory-optimization-example)
  - [Cache Management Example](#cache-management-example)
  - [Batch Rendering Example](#batch-rendering-example)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Alien Fall's Tileset Loader system manages the loading and processing of large PNG tileset files containing Battle Tile images. The system efficiently extracts individual tile images from texture atlases, manages memory usage, and provides fast access to tile graphics during gameplay through multi-level caching and batch processing.

The tileset loader is a critical component of the technical infrastructure, enabling efficient rendering of tactical battlescapes while maintaining performance and supporting extensive modding capabilities.

## Mechanics

### Tileset File Format

Tilesets use a structured format optimized for efficient loading and rendering.

File Structure:
- Large PNG files with tiles arranged in regular grids
- Companion TOML metadata files defining tile properties and layout
- Support for configurable spacing and margins between tiles
- Variable tile dimensions (32x32, 64x64, 128x128 pixels)
- Category-based organization (ground, urban, alien, effects)

Format Specifications:
- Image format: PNG with full transparency support
- Maximum dimensions: 4096x4096 pixels for large texture atlases
- Tile grid layout with consistent spacing and margins
- Metadata includes tile properties, coordinates, and gameplay attributes

### Loader Architecture

The loader uses a modular architecture with multiple specialized components.

Core Components:
- Tileset cache for loaded texture atlases
- Tile cache for individual extracted tile images
- Quad cache for GPU-optimized rendering regions
- Metadata cache for tile property information

Loading Pipeline:
- Discovery: Locate tileset files and metadata
- Validation: Verify file integrity and format compliance
- Texture Loading: Load PNG files into GPU memory
- Quad Generation: Create rendering regions for each tile
- Metadata Parsing: Process TOML configuration files
- Cache Population: Store tiles in memory hierarchies
- System Registration: Make tiles available to rendering systems

### Tile Extraction Process

Individual tiles are extracted from texture atlases using efficient GPU operations.

Quad Generation:
- Define rectangular regions within larger texture atlases
- Create GPU quad objects for each tile position
- Support for rotation and scaling transformations
- Memory-efficient sharing of base textures

Batch Processing:
- Process tiles in groups to avoid frame rate drops
- Background loading during non-critical game phases
- Progressive extraction to maintain responsiveness
- Error handling for corrupted or missing tiles

Image Extraction:
- Canvas-based rendering for individual tile isolation
- Transparency preservation and color key handling
- Automatic optimization for target hardware capabilities
- Fallback generation for missing or corrupted tiles

### Memory Management

The system optimizes memory usage through sharing and intelligent allocation.

Texture Sharing:
- Single texture atlas shared across multiple tiles
- Quad references instead of duplicate texture data
- Reference counting for automatic cleanup
- Memory monitoring with configurable thresholds

Resource Optimization:
- LRU (Least Recently Used) cache eviction policies
- Automatic cleanup of unused tile resources
- Memory budgeting to prevent system overload
- Platform-specific optimization for different hardware

### Cache System

Multi-level caching ensures fast access while managing memory constraints.

Cache Hierarchy:
- L1 Cache: Fast RAM-based storage for frequently used tiles
- L2 Cache: Disk-based persistent storage for less common tiles
- Texture Cache: GPU memory storage for rendering optimization
- Quad Cache: Pre-computed rendering regions for performance

Cache Management:
- Intelligent prefetching based on usage patterns
- Automatic invalidation when tilesets are updated
- Background loading to prevent gameplay interruptions
- Configurable cache sizes based on available memory

### Performance Optimization

Multiple strategies ensure smooth performance during gameplay.

Loading Strategies:
- Progressive loading during loading screens and transitions
- Background processing to avoid blocking main thread
- Streaming for large tilesets to manage memory usage
- On-demand loading for tiles not immediately needed

Rendering Optimization:
- Level-of-detail (LOD) system for distant tiles
- Texture sorting to minimize GPU state changes
- Batch processing for efficient rendering queues
- Mipmap generation for scaling performance

## Examples

### Tileset Structure Example

A comprehensive tileset for urban combat scenarios:

```
urban_tileset.png (1024x1024 pixels)
├── Grid: 16x16 tiles (64x64 pixels each)
├── Categories: Road, Building, Cover, Destruction
├── Properties: Movement costs, cover values, destructibility
├── Metadata: urban_tiles.toml with tile definitions
└── Variants: Normal, damaged, and seasonal variations
```

### Loading Pipeline Example

Processing a new tileset during game initialization:

- Discovery: Locate "ground_tileset.png" and "ground_tiles.toml"
- Validation: Verify PNG integrity and TOML syntax
- Texture Loading: Upload 1024x1024 texture to GPU memory
- Quad Generation: Create 256 quad regions for individual tiles
- Metadata Parsing: Load movement costs and cover properties
- Cache Population: Store in L1 cache for immediate access
- Registration: Make tiles available to map generation systems

### Memory Optimization Example

Efficient memory usage for a large terrain tileset:

- Base Texture: Single 1024x1024 image (4MB)
- Individual Tiles: 256 tiles × 64×64 pixels each (would be 256MB if separate)
- Quad References: 256 quads × 4KB each (1MB total)
- Memory Savings: 99.75% reduction through texture sharing
- Cache Efficiency: Frequently used tiles stay in fast RAM access

### Cache Management Example

Intelligent caching during a tactical mission:

- L1 Cache: Grass, road, and building tiles (most common)
- L2 Cache: Special tiles like craters and debris (less common)
- Prefetching: Load adjacent tiles before they enter viewport
- Eviction: Remove unused alien tiles when switching to urban maps
- Background Loading: Prepare next mission's tiles during debriefing

### Batch Rendering Example

Optimizing rendering performance during combat:

- Tile Sorting: Group tiles by texture atlas to minimize GPU switches
- Batch Processing: Render 100 tiles in single draw call instead of 100 calls
- Performance Gain: 3-5x improvement in frame rate
- Memory Efficiency: Reduced GPU state changes and driver overhead
- Scalability: Maintains performance with large battlefield maps

## Related Wiki Pages

- [BattleTileset.md](../battlescape/BattleTileset.md) - Tileset file format.
- [Battle tile.md](../battlescape/Battle%20tile.md) - Individual tile usage.
- [Battle map.md](../battlescape/Battle%20map.md) - Map rendering system.
- [Modding.md](../technical/Modding.md) - Moddable asset loading.
- [SaveSystem.md](../technical/SaveSystem.md) - Asset persistence.
- [BattleMapBlocks.md](../battlescape/BattleMapBlocks.md) - Block loading.
- [Performance.md](../technical/Performance.md) - Performance optimization.
- [Rendering.md](../technical/Rendering.md) - Rendering pipeline.

## References to Existing Games and Mechanics

- Unity game engine: Asset loading and management systems.
- Unreal Engine: Texture atlas and resource loading.
- Game development: Sprite sheet and tileset loading.
- OpenGL/DirectX: Texture management and atlasing.
- Love2D: Image and asset loading.
- Godot: Resource loading system.
- AAA game pipelines: Asset streaming and optimization.
- Mobile games: Texture atlas optimization.

