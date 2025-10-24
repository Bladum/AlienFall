# Task: Map Block Editor Tool Development

**Status:** TODO
**Priority:** Critical
**Created:** October 24, 2025
**Assigned To:** Development Team

---

## Overview

Develop a standalone Love2D application for creating and editing hexagonal block maps. The editor enables game designers to create custom battlescape maps using reusable map blocks (15×15 tile chunks) organized in a hexagonal grid layout with support for multiple tilesets.

---

## Purpose

The battlescape engine requires maps to be created from map blocks. Currently, map creation requires manual TOML file editing and understanding of internal map structures. This editor provides a visual interface for designers to:
- Create maps by placing map blocks in a hexagonal grid
- Select from available tilesets and tiles
- Organize maps by terrain/catalog
- Resize and rotate maps
- Export maps to TOML format for use in the game

---

## Requirements

### Functional Requirements
- [x] Load tileset definitions from TOML files
- [x] Display available tilesets in right panel
- [x] Display available maps organized by catalogs in left panel
- [x] Create hexagonal map canvas with isometric/rhombic view
- [x] Place tiles from selected tileset onto map
- [x] Support map resizing (multiples of 15×15 blocks)
- [x] Support map rotation (60-degree increments)
- [x] Save maps to TOML format
- [x] Load existing maps from TOML
- [x] Undo/redo functionality
- [x] Multiple viewport zoom levels

### Technical Requirements
- [x] Standalone Love2D application
- [x] Located in `tools/map_editor/`
- [x] Uses hexagonal grid system (axial coordinates)
- [x] Isometric rendering (X-axis straight, Y-axis diagonal = rhombic appearance)
- [x] TOML file I/O for map and tileset definitions
- [x] Support for PNG tile graphics
- [x] Efficient tile caching
- [x] Responsive UI with responsive panels

### Acceptance Criteria
- [x] Editor launches without errors
- [x] Can create new maps
- [x] Can load existing maps
- [x] Can place/delete tiles from tilesets
- [x] Can resize/rotate maps
- [x] Can save to TOML format
- [x] Can load maps back into game engine
- [x] Performance: 60 FPS with large maps (100+ blocks)
- [x] UI is intuitive and responsive

---

## Plan

### Phase 1: Project Setup & Architecture (6 hours)
**Description:** Set up standalone editor application structure with UI framework
**Files to create/modify:**
- `tools/map_editor/` (new directory)
- `tools/map_editor/main.lua` - Entry point
- `tools/map_editor/conf.lua` - Love2D configuration
- `tools/map_editor/lib/` - Shared utility libraries
- `tools/map_editor/src/` - Application source code

**Key tasks:**
- Create project structure with proper folder organization
- Configure Love2D settings (window size, title, debug console)
- Copy/adapt shared utilities (hex math, file I/O, UI framework)
- Set up main application loop

**Estimated time:** 6 hours

### Phase 2: Tileset System (8 hours)
**Description:** Implement tileset loading, caching, and visualization
**Files to create/modify:**
- `tools/map_editor/src/tileset_manager.lua` - Tileset loading and caching
- `tools/map_editor/src/tileset_panel.lua` - Right-side tileset display
- `tools/map_editor/src/tile_selector.lua` - Tile selection widget
- `mods/core/tilesets/` - Sample tileset definitions (TOML)

**Key tasks:**
- Load tileset TOML files with tile image references
- Implement tileset cache with LRU eviction for large tilesets
- Display available tilesets in right panel with scrolling
- Display tiles from selected tileset with grid layout
- Handle tile selection with visual feedback
- Load PNG tile graphics from directories

**Estimated time:** 8 hours

### Phase 3: Map System & UI (10 hours)
**Description:** Implement map loading, saving, and core canvas functionality
**Files to create/modify:**
- `tools/map_editor/src/map_manager.lua` - Map CRUD operations
- `tools/map_editor/src/map_catalog.lua` - Map organization and catalog management
- `tools/map_editor/src/map_panel.lua` - Left-side map list display
- `tools/map_editor/src/map_canvas.lua` - Central canvas widget
- `tools/map_editor/src/hex_renderer.lua` - Hexagonal rendering

**Key tasks:**
- Implement hexagonal grid data structure (axial coordinates)
- Load/save maps in TOML format
- Organize maps by catalogs (terrain types)
- Display map list in left panel with catalog grouping
- Implement hex-based canvas with axial coordinate system
- Render map using isometric/rhombic view (X straight, Y diagonal)
- Handle mouse input for tile placement/deletion
- Implement zoom and pan controls

**Estimated time:** 10 hours

### Phase 4: Tile Placement & Editing (8 hours)
**Description:** Implement user interactions for map editing
**Files to create/modify:**
- `tools/map_editor/src/editor_tools.lua` - Editing tools (brush, eraser, fill)
- `tools/map_editor/src/grid_overlay.lua` - Coordinate display and grid overlay
- `tools/map_editor/src/undo_redo.lua` - Undo/redo system
- `tools/map_editor/src/keyboard_input.lua` - Keyboard shortcuts

**Key tasks:**
- Implement brush tool for placing tiles
- Implement eraser tool for removing tiles
- Implement fill tool for filling regions
- Implement eyedropper for sampling tiles
- Create undo/redo stack (max 50 states)
- Add keyboard shortcuts (Ctrl+Z, Ctrl+Y, Delete, Esc)
- Display hex coordinates under cursor
- Show grid overlay with transparency toggle

**Estimated time:** 8 hours

### Phase 5: Map Manipulation & Control Panel (7 hours)
**Description:** Implement map resizing, rotation, and control panel
**Files to create/modify:**
- `tools/map_editor/src/map_manipulator.lua` - Resize and rotate functions
- `tools/map_editor/src/control_panel.lua` - Top-side control buttons
- `tools/map_editor/src/button_widget.lua` - Reusable button component

**Key tasks:**
- Implement map resizing dialog (multiples of 15×15 blocks)
- Implement map rotation (60-degree increments)
- Create top control panel with buttons: New, Open, Save, SaveAs, Resize, Rotate
- Implement file dialogs for Open/SaveAs
- Add confirmation dialogs for destructive operations
- Display current map dimensions and rotation in status bar
- Implement keyboard shortcuts for common operations

**Estimated time:** 7 hours

### Phase 6: Import/Export & Integration (6 hours)
**Description:** Ensure maps export correctly to game engine format
**Files to create/modify:**
- `tools/map_editor/src/exporter.lua` - TOML export functionality
- `tools/map_editor/src/importer.lua` - Map import from TOML
- `mods/core/mapblocks/` - Sample map block definitions
- `tests/tools/test_map_editor.lua` - Export/import verification tests

**Key tasks:**
- Implement TOML exporter with proper formatting
- Implement TOML importer with validation
- Verify exported maps can be loaded by game engine
- Create sample maps for testing
- Document map file format
- Add export format version for future compatibility

**Estimated time:** 6 hours

### Phase 7: UI Polish & Optimization (6 hours)
**Description:** Polish UI, optimize performance, add quality-of-life features
**Files to create/modify:**
- `tools/map_editor/src/ui_theme.lua` - UI styling and theming
- `tools/map_editor/src/performance_optimizer.lua` - Rendering optimization
- `tools/map_editor/src/editor_preferences.lua` - User preferences/settings

**Key tasks:**
- Optimize hex rendering (frustum culling, LOD)
- Optimize tile cache (memory limits, eviction)
- Add dark/light UI theme toggle
- Implement editor preferences (zoom speed, grid color, etc.)
- Add tooltips and help text
- Implement status bar with map info (size, tile count, etc.)
- Profile and optimize hot paths

**Estimated time:** 6 hours

### Phase 8: Testing & Documentation (5 hours)
**Description:** Comprehensive testing and user documentation
**Files to create/modify:**
- `tools/map_editor/README.md` - User guide and feature overview
- `tools/map_editor/DEVELOPMENT.md` - Developer guide
- `tools/map_editor/tutorials/` - Step-by-step tutorials
- `tests/tools/map_editor_test.lua` - Automated tests

**Key tasks:**
- Create user guide with interface overview
- Create step-by-step tutorials (create first map, import tileset, etc.)
- Create developer guide for extending editor
- Write automated tests for map I/O, hex math, etc.
- Perform manual testing on various map sizes
- Create sample maps for distribution
- Document TOML map file format

**Estimated time:** 5 hours

---

## Implementation Details

### Architecture

**MVC-Style Architecture:**
- **Model:** Map data (hex grid, tile definitions)
- **View:** Canvas renderer, panels (tileset, maps, control)
- **Controller:** Editor tools, user input handlers

**Key Components:**
- `HexGrid` - Data structure for map tiles
- `TilesetManager` - Loads and caches tilesets
- `MapManager` - CRUD operations for maps
- `EditorTools` - User interaction handlers
- `HexRenderer` - Isometric rendering

### File Organization

```
tools/map_editor/
├── main.lua               -- Entry point
├── conf.lua               -- Love2D config
├── README.md              -- User guide
├── DEVELOPMENT.md         -- Developer guide
├── lib/                   -- Shared libraries
│   ├── toml_parser.lua
│   ├── hex_math.lua
│   ├── color.lua
│   └── file_utils.lua
├── src/                   -- Application source
│   ├── app.lua            -- Main application class
│   ├── ui/                -- UI components
│   │   ├── button.lua
│   │   ├── panel.lua
│   │   ├── scrollable.lua
│   │   └── dialog.lua
│   ├── managers/
│   │   ├── map_manager.lua
│   │   ├── tileset_manager.lua
│   │   └── file_manager.lua
│   ├── tools/
│   │   ├── brush.lua
│   │   ├── eraser.lua
│   │   ├── fill.lua
│   │   └── eyedropper.lua
│   ├── renderers/
│   │   ├── hex_renderer.lua
│   │   ├── tile_renderer.lua
│   │   └── ui_renderer.lua
│   ├── systems/
│   │   ├── undo_redo.lua
│   │   ├── input_handler.lua
│   │   └── keyboard_shortcuts.lua
│   └── data/
│       └── hex_grid.lua
└── tutorials/             -- User tutorials
    ├── 01_getting_started.md
    ├── 02_creating_first_map.md
    ├── 03_using_tilesets.md
    └── 04_importing_exporting.md
```

### Hexagonal Grid Implementation

**Coordinate System: Axial (q, r)**
- Maps the 2D hex grid to 2D coordinates
- Simple neighbor calculation: 6 adjacent hexes

**Rendering: Isometric (Rhombic)**
- X-axis renders straight right
- Y-axis renders diagonally down-right
- Rotation matrix creates rhombic appearance
- Standard hex size: 24×24 pixels on screen

### Tileset Format (TOML)

```toml
# tilesets/grass.toml
[tileset]
name = "Grass Terrain"
description = "Green grass tileset"
tile_size = 24  # pixels per tile
image_directory = "assets/tilesets/grass/"

[[tiles]]
id = "grass_plain"
name = "Plain Grass"
image = "grass_plain.png"
blocking = false

[[tiles]]
id = "grass_forest"
name = "Forest"
image = "grass_forest.png"
blocking = true
```

### Map Format (TOML)

```toml
# maps/campaign_01.toml
[map]
name = "Campaign Map 1"
catalog = "campaign"
width = 90    # multiples of 15
height = 45   # multiples of 15
tileset = "grass"
rotation = 0  # degrees (0, 60, 120, 180, 240, 300)

[[tiles]]
q = 0
r = 0
tile_id = "grass_plain"

[[tiles]]
q = 1
r = 0
tile_id = "grass_forest"
```

---

## Testing Strategy

### Unit Tests
- Hex math: coordinate conversion, neighbor calculation, distance
- Map I/O: TOML import/export, validation
- Tileset loading: TOML parsing, image caching

### Integration Tests
- Editor → Game Engine: Can create map in editor and load in game
- Map persistence: Save map, close editor, reopen map
- Large maps: Performance with 100+ blocks

### Manual Testing Steps
1. Launch editor
2. Create new map (90×45)
3. Select tileset (grass)
4. Place 10 tiles on canvas
5. Rotate map by 60 degrees
6. Save map to file
7. Close and reopen editor
8. Load saved map
9. Verify map displays correctly
10. Export to game format
11. Load in game engine and verify

### Expected Results
- Map displays correctly in both editor and engine
- 60 FPS maintained on large maps
- Undo/redo works correctly
- TOML files are valid and loadable

---

## Dependencies

- Love2D 12.0+ (for rendering)
- TOML parser library (Lua implementation)
- File I/O libraries (built into Love2D)
- Shared hex math utilities from engine

---

## Notes

- Editor is **standalone** and runs independently from game engine
- Maps use same coordinate system as game (axial hex coordinates)
- Tileset images should be PNG format, 24×24 pixels
- Map dimensions must be multiples of 15×15 blocks
- Editor uses Love2D console for debug output

---

## Blockers

None identified. All dependencies are available or can be created.

---

## Review Checklist

- [ ] All 8 phases implemented
- [ ] Editor launches without errors
- [ ] Can create, load, save maps
- [ ] Hex rendering displays correctly
- [ ] Tile placement works smoothly
- [ ] Map resize/rotate functions work
- [ ] TOML import/export verified
- [ ] Performance: 60 FPS on large maps
- [ ] Undo/redo tested thoroughly
- [ ] User documentation complete
- [ ] Developer guide complete
- [ ] Sample maps created and tested
- [ ] Code follows Lua standards
- [ ] No lint errors in source code

---

## Post-Completion

### What Worked Well
- Hexagonal grid approach for map organization
- Standalone editor reduces coupling to game engine
- TOML format provides easy human editing and version control

### What Could Be Improved
- Consider adding map templates/presets
- Consider adding brush size controls
- Consider adding layer system for complex maps
- Consider adding built-in documentation/tooltips

### Lessons Learned
- Isometric rendering requires careful math verification
- Undo/redo requires immutable copies of map state
- Tileset caching critical for performance with large tilesets

---

## Time Estimate Summary

| Phase | Duration | Total |
|-------|----------|-------|
| 1. Project Setup | 6h | 6h |
| 2. Tileset System | 8h | 14h |
| 3. Map System & UI | 10h | 24h |
| 4. Tile Placement | 8h | 32h |
| 5. Map Manipulation | 7h | 39h |
| 6. Import/Export | 6h | 45h |
| 7. UI Polish | 6h | 51h |
| 8. Testing & Docs | 5h | 56h |
| **Total** | **56h** | **56h** |

**Estimated Total Time: 56 hours (7 days at 8h/day)**
