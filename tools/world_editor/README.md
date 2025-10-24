# World Editor Tool

Standalone Love2D application for editing strategic world structure and geography.

## Features

- 90×45 hexagonal grid world visualization
- Province, region, country, and biome assignment to tiles
- Terrain type selection (WATER, LAND, ROUGH, BLOCK)
- Layer visualization (view world by province/region/country/biome)
- Real-time property editing
- Save/load world states in TOML format
- Grid overlay toggle
- Zoom and pan controls

## Running the Editor

### Method 1: Batch File (Recommended)
```
run_world_editor.bat
```

### Method 2: Love2D Command
```
lovec "tools\world_editor"
```

### Method 3: From Project Root
```
lovec tools/world_editor
```

## Controls

**Mouse:**
- **Left Click**: Select tile
- **Right Click + Drag**: Pan canvas
- **Mouse Wheel**: Zoom in/out

**Keyboard:**
- **P**: View Province layer
- **R**: View Region layer
- **C**: View Country layer
- **B**: View Biome layer
- **F9**: Toggle grid overlay
- **Ctrl+S**: Save world
- **ESC**: Exit editor

## UI Layout

```
┌──────────────────────────────────────────────────────────────────────┐
│ World Editor - [World Name]      Size: 90x45  Layer: PROVINCE       │ ← Title bar
├─────────────┬──────────────────────────────┬─────────────────────────┤
│             │                              │                         │
│  Province   │        World Hex Grid        │  Selected Tile:         │
│  Region     │   (90×45 hexagonal grid)     │  Q: 45, R: 22          │
│  Country    │                              │  Province: France       │
│  Biome      │  Click to select tile        │  Biome: Temperate       │
│  Settings   │  Right-drag to pan           │  Terrain: LAND          │
│             │  Wheel to zoom               │                         │
│             │                              │                         │
├─────────────┴──────────────────────────────┴─────────────────────────┤
│ LMB: Select | RMB: Pan | Wheel: Zoom | P/R/C/B: Layer | Ctrl+S: Save │
└──────────────────────────────────────────────────────────────────────┘
```

## File Structure

```
tools/world_editor/
├── main.lua                 -- Main application entry
├── conf.lua                 -- Love2D configuration
├── run_world_editor.bat     -- Quick launch script
├── README.md                -- This file
└── [future: additional modules]
```

## Development

The world editor is designed to:
1. Load world definitions from TOML files (provinces, regions, countries, biomes)
2. Display a 90×45 hexagonal grid representing the world
3. Allow assignment of these definitions to individual tiles
4. Support visualization by different layers (province, region, country, biome)
5. Export world state to TOML format for use in the game engine

## Status

**Phase 1-3**: Skeleton implementation complete
**Phase 4-8**: Full implementation in progress

See `tasks/TODO/TASK-EDITOR-002-world-editor.md` for detailed implementation plan.

## See Also

- `TASK-EDITOR-002-world-editor.md` - Complete task specification
- `engine/geoscape/world/world.lua` - World system implementation
- `tools/map_editor/` - Map editor (similar project structure)
