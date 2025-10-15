# Map Editor Tool

Standalone Love2D application for editing XCOM Simple maps.

## Features

- Visual tile-based map editing with 24×24 pixel grid
- Tileset browser with preview and filtering
- Tile palette for quick tile selection
- Multiple editing tools:
  - **Paint**: Place individual tiles
  - **Fill**: Flood fill areas
  - **Erase**: Clear tiles
  - **Select**: Copy/paste regions
- Real-time map statistics (size, fill percentage, unique tiles)
- Save/load map files
- Grid overlay toggle (F9)
- Fullscreen toggle (F12)

## Running the Editor

### Method 1: Batch File (Recommended)
```
run_map_editor.bat
```

### Method 2: Love2D Command
```
lovec "tools\map_editor"
```

### Method 3: From Project Root
```
lovec tools/map_editor
```

## Controls

**Mouse:**
- **Left Click**: Use current tool (paint/fill/erase)
- **Right Click + Drag**: Pan canvas
- **Mouse Wheel**: Zoom in/out

**Keyboard:**
- **P**: Paint tool
- **F**: Fill tool
- **E**: Erase tool
- **S**: Select tool
- **Ctrl+S**: Save map
- **Ctrl+O**: Open map
- **Ctrl+Z**: Undo
- **Ctrl+Y**: Redo
- **F9**: Toggle grid overlay
- **F12**: Toggle fullscreen
- **ESC**: Exit editor

## UI Layout

```
┌─────────────────────────────────────────────────────────────┐
│ Map Editor - [Map Name]          Size: 15x15  Fill: 45%    │ ← Title bar
├───────────┬─────────────────────────────────┬───────────────┤
│           │                                 │               │
│  Tileset  │        Map Canvas               │  Tile Palette │
│  Browser  │   (Scrollable/Zoomable)         │   (Current    │
│           │                                 │    Tileset)   │
│  - Urban  │   [Grid with tiles displayed]   │               │
│  - Forest │                                 │  [Tile grid]  │
│  - Desert │   Click to place tiles          │   Click to    │
│  - ...    │   Right-drag to pan             │   select      │
│           │   Wheel to zoom                 │               │
│           │                                 │               │
└───────────┴─────────────────────────────────┴───────────────┘
```

**Grid System:**
- Resolution: 960×720 pixels (40×30 grid cells)
- Grid cell: 24×24 pixels
- All UI elements snap to grid
- Map tiles scale with zoom

## File Structure

```
tools/map_editor/
├── main.lua                 -- Main application entry
├── conf.lua                 -- Love2D configuration
├── run_map_editor.bat       -- Quick launch script
└── README.md                -- This file
```

**Dependencies (from engine/):**
- `battlescape.ui.map_editor` - Map editor core
- `battlescape.ui.tileset_browser` - Tileset browser widget
- `battlescape.ui.tile_palette` - Tile palette widget
- `battlescape.data.tilesets` - Tileset data loader
- `battlescape.map.mapblock_loader_v2` - Map file I/O
- `widgets` - UI widget system
- `widgets.core.theme` - Theme system

## Map Files

**Location:** `mods/core/mapblocks/[tileset]/[map_name].map`

**Format:** Custom binary or Lua table format with:
- Map dimensions (width, height)
- Tile data (2D grid of tile keys)
- Metadata (name, author, tileset, description)
- Entry points (spawn positions)

## Development

**Adding New Tools:**
1. Add tool logic to `engine/battlescape/ui/map_editor.lua`
2. Add keyboard shortcut in `main.lua:keypressed()`
3. Update this README with new tool description

**Adding New Tilesets:**
1. Create tileset definition in `mods/core/tilesets/`
2. Add tileset images to `engine/assets/images/tilesets/`
3. Restart map editor

**Debugging:**
- Console window shows debug output (enabled in conf.lua)
- Press F9 to toggle grid overlay
- Check console for errors when loading tilesets/maps

## Troubleshooting

**Editor won't start:**
- Verify Love2D 12.0+ is installed
- Check console for require() errors
- Ensure engine/ folder exists at `../../engine/`

**Tileset not loading:**
- Check tileset TOML file syntax
- Verify tileset images exist in `engine/assets/images/tilesets/`
- Run asset verification tool first

**Map won't save:**
- Check write permissions on mods/ folder
- Verify target tileset folder exists
- Check console for error messages

**Performance issues:**
- Reduce map size for large maps
- Disable grid overlay (F9)
- Close tileset browser if not needed

## See Also

- `wiki/MAP_EDITOR_GUIDE.md` - Comprehensive editing guide
- `wiki/MAPBLOCK_GUIDE.md` - Map format documentation
- `wiki/TILESET_SYSTEM.md` - Tileset system documentation
- `tools/asset_verification/` - Asset verification tool
