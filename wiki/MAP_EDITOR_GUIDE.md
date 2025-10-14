# Map Editor User Guide

## Overview

The Map Editor is a visual tool for creating and editing Map Blocks for AlienFall. Map Blocks are 15×15 tile grids (or multiples) that serve as building blocks for tactical combat maps.

---

## Launching the Map Editor

```bash
lovec engine/run_map_editor.lua
```

The editor will open in a 960×720 window with three panels:
- **Left Panel** (240px): Tileset Browser
- **Center Panel** (480px): Canvas for editing
- **Right Panel** (240px): Tile Palette

---

## Interface Layout

```
┌─────────────────────────────────────────────────┐
│ Title Bar - Block Name, Fill %, Current Tool    │
├──────────┬──────────────────────┬───────────────┤
│ Tileset  │                      │ Tile Palette  │
│ Browser  │      Canvas          │               │
│          │   [Map Grid Here]    │               │
│  urban   │                      │  ┌───┬───┐   │
│  forest  │                      │  │001│002│   │
│  ufo     │                      │  ├───┼───┤   │
│          │                      │  │003│004│   │
└──────────┴──────────────────────┴───────────────┘
│ Help: LMB=Paint RMB=Erase F9=Grid Ctrl+Z=Undo  │
└─────────────────────────────────────────────────┘
```

---

## Basic Workflow

### 1. Select a Tileset
- Click on a tileset name in the **left panel**
- The **right panel** will populate with tiles from that tileset
- Example tilesets: `urban`, `forest`, `ufo_ship`, `farmland`

### 2. Select a Tile
- Click on a tile in the **right panel**
- The selected tile will be highlighted with a border
- The title bar shows the selected tile KEY (e.g., `urban:floor_01`)

### 3. Paint Tiles
- **Left-click** on the canvas to paint the selected tile
- **Hold and drag** left mouse button to paint multiple tiles
- Painted tiles appear immediately on the canvas

### 4. Erase Tiles
- **Right-click** on the canvas to erase a tile
- **Hold and drag** right mouse button to erase multiple tiles
- Erased tiles become transparent (EMPTY)

### 5. Save Your Work
- Press **Ctrl+S** to save your Map Block
- Save to `mods/core/mapblocks/yourblock.toml`
- The Map Block can now be used in Map Scripts

---

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| **Ctrl+Z** | Undo last action |
| **Ctrl+Y** | Redo undone action |
| **Ctrl+S** | Save Map Block to TOML |
| **Ctrl+O** | Open Map Block (planned) |
| **Ctrl+N** | New blank Map Block |
| **F9** | Toggle grid overlay |
| **P** | Switch to Paint tool |
| **E** | Switch to Erase tool |
| **Mouse Wheel** | Zoom in/out on canvas |

---

## Mouse Controls

| Action | Effect |
|--------|--------|
| **LMB (Canvas)** | Paint selected tile |
| **RMB (Canvas)** | Erase tile |
| **LMB + Drag (Canvas)** | Paint multiple tiles |
| **RMB + Drag (Canvas)** | Erase multiple tiles |
| **LMB (Tileset Browser)** | Select tileset |
| **LMB (Tile Palette)** | Select tile |
| **Mouse Wheel (Canvas)** | Zoom in/out |
| **Mouse Wheel (Panels)** | Scroll lists |

---

## Metadata Editing

Every Map Block has metadata that controls how it's used in Map Scripts:

### Fields:
- **ID** - Unique identifier (e.g., `urban_small_01`)
- **Name** - Human-readable name (e.g., `Small Urban Building`)
- **Group** - Grouping number 0-99 (0=always use, 1+=group filtering)
- **Tags** - Comma-separated tags (e.g., `urban, building, single_story`)
- **Author** - Creator name
- **Difficulty** - Mission difficulty 1-5

### How to Edit:
Currently metadata is edited directly in the TOML file after saving. Future versions will have a metadata editor panel.

---

## Understanding Map Tile KEYs

Map Tiles are referenced using the format: `tilesetId:tileId`

**Examples:**
- `urban:floor_01` - Floor tile from urban tileset
- `urban:wall_01` - Wall tile from urban tileset
- `forest:tree_pine_01` - Pine tree from forest tileset
- `ufo:floor_metal_01` - Metal floor from UFO ship tileset

The Map Editor automatically validates KEYs and prevents invalid tile placement.

---

## Undo/Redo System

The editor maintains a **history of up to 50 states**:
- Each paint or erase action saves a new state
- **Ctrl+Z** moves back through history
- **Ctrl+Y** moves forward through history
- Saving clears the dirty flag but preserves history
- Creating a new block clears all history

---

## Grid Overlay

Press **F9** to toggle the grid overlay:
- **Green lines** show 24×24 pixel grid cells
- Helps align multi-tile objects
- Shows block boundaries
- Useful for precision editing

---

## Statistics

The title bar displays real-time statistics:
- **Fill %** - Percentage of non-empty tiles
- **Unique** - Number of different tiles used
- **Dirty** - Asterisk (*) if unsaved changes exist

**Example:**
```
urban_small_01* | Fill: 67.3% | Unique: 8 | Tool: Paint
```
The asterisk indicates unsaved changes.

---

## Saving and Loading

### Save Format (TOML)
Map Blocks are saved as TOML files:

```toml
[mapblock]
id = "custom_building_01"
name = "Custom Building"
width = 15
height = 15
group = 1
tags = "urban, building"
author = "YourName"
difficulty = 2

[mapblock.tiles]
0_0 = "urban:wall_01"
0_1 = "urban:wall_01"
1_0 = "urban:floor_01"
1_1 = "urban:floor_01"
# ... more tiles
```

### File Locations
- **User Blocks:** `mods/core/mapblocks/`
- **Temp Saves:** System temp directory (use Ctrl+S to save properly)

### Loading Blocks
Use **Ctrl+O** (planned) to load existing Map Blocks for editing.

---

## Tips and Best Practices

### 1. Start with Perimeter
- Draw walls around the perimeter first
- Fill interior with floor tiles
- Add doors and details last

### 2. Use Groups Effectively
- **Group 0:** Always available (generic terrain)
- **Group 1-10:** Building interiors
- **Group 11-20:** Outdoor structures
- **Group 21-30:** UFO components
- **Group 31-99:** Custom/special blocks

### 3. Tag Appropriately
- Use consistent tag naming (lowercase, underscores)
- Common tags: `urban`, `forest`, `ufo`, `building`, `terrain`, `single_story`, `multi_story`
- Tags enable smart Map Script filtering

### 4. Test in Game
After creating a Map Block:
1. Save it to `mods/core/mapblocks/`
2. Reference it in a Map Script with `addBlock`
3. Test the Map Script in-game
4. Iterate based on gameplay

### 5. Use Undo Liberally
- Experiment freely - you have 50 undo states
- Try different tile combinations
- Don't worry about mistakes

### 6. Multi-Tile Objects
Some tiles occupy multiple cells (e.g., large trees, vehicles):
- The editor shows multi-cell tiles correctly
- Position the anchor point (top-left) where you want the object
- The editor handles multi-cell placement automatically

---

## Common Workflows

### Creating a Simple Room
```
1. Select urban tileset
2. Select wall_01 tile
3. Draw 5×5 perimeter (walls)
4. Select floor_01 tile
5. Fill 3×3 interior (floors)
6. Select door_01 tile
7. Replace one wall with door
8. Ctrl+S to save
```

### Creating a Forest Patch
```
1. Select forest tileset
2. Select grass_01 tile
3. Fill entire 15×15 area
4. Select tree_pine_01 tile
5. Paint ~10 trees scattered
6. Select bush_01 tile
7. Paint ~5 bushes between trees
8. Ctrl+S to save
```

### Creating a UFO Interior
```
1. Select ufo_ship tileset
2. Select floor_metal_01 tile
3. Fill base layer
4. Select wall_metal_01 tile
5. Draw room divisions
6. Select console_01, bed_01, etc.
7. Add furniture
8. Select door_auto_01 tile
9. Add doors between rooms
10. Ctrl+S to save
```

---

## Troubleshooting

### Issue: No tiles showing in palette
**Solution:** Make sure you clicked a tileset in the left panel first

### Issue: Can't paint tiles
**Solution:** Ensure you've selected a tile from the palette (right panel)

### Issue: Tiles look wrong
**Solution:** Toggle grid (F9) to verify alignment, check zoom level

### Issue: Save failed
**Solution:** Check file path is writable, ensure filename has no invalid characters

### Issue: Undo doesn't work
**Solution:** Undo only works for paint/erase actions after history was saved

---

## Map Block Specifications

### Size Requirements
- **Width/Height:** Must be multiples of 15 (15, 30, 45, 60, etc.)
- **Recommended:** 15×15 for buildings, 30×30 for large structures
- **Maximum:** No hard limit, but 60×60 is practical maximum

### Tile Limits
- **Total Tiles:** width × height
- **Example:** 15×15 = 225 tiles
- **Performance:** Blocks under 1,000 tiles render instantly

### Map Tile KEY Format
- **Format:** `tilesetId:tileId`
- **Valid Characters:** a-z, 0-9, underscore
- **Examples:** `urban:floor_01`, `forest:tree_pine_02`

---

## Integration with Map Scripts

Map Blocks created in the editor can be used in Map Scripts:

```toml
# In a Map Script (mods/core/mapscripts/my_mission.toml)

[[commands]]
type = "addBlock"
block = "custom_building_01"  # Your Map Block ID
x = 10
y = 10
```

The Map Script system will:
1. Load your Map Block from `mods/core/mapblocks/`
2. Place it at the specified coordinates
3. Render it on the hex grid during gameplay

---

## Advanced Features

### Zoom Controls
- **Mouse Wheel Up:** Zoom in (max 2.0x)
- **Mouse Wheel Down:** Zoom out (min 0.5x)
- Zoom centered on canvas
- Grid scales with zoom

### Camera Controls (Planned)
- **Middle Mouse + Drag:** Pan camera
- **Arrow Keys:** Pan camera
- Useful for large Map Blocks

### Selection Tools (Planned)
- **Rectangle Select:** Select area to copy/paste
- **Fill Tool:** Flood-fill contiguous tiles
- **Eyedropper:** Pick tile from canvas

---

## Hotkeys Quick Reference

**Essential:**
- `LMB` - Paint
- `RMB` - Erase
- `Ctrl+Z` - Undo
- `Ctrl+S` - Save

**Tools:**
- `P` - Paint tool
- `E` - Erase tool
- `F9` - Toggle grid

**File Operations:**
- `Ctrl+N` - New block
- `Ctrl+O` - Open block (planned)
- `Ctrl+S` - Save block

---

## Further Reading

- **[Map Tile KEY Reference](MAP_TILE_KEY_REFERENCE.md)** - All available tiles
- **[Map Script Reference](MAP_SCRIPT_REFERENCE.md)** - Using blocks in scripts
- **[Tileset System](TILESET_SYSTEM.md)** - How tilesets work
- **[Map Block Guide](MAPBLOCK_GUIDE.md)** - Map Block specification
- **[Hex Rendering Guide](HEX_RENDERING_GUIDE.md)** - Hex grid system

---

**Happy Map Building!** 🗺️
