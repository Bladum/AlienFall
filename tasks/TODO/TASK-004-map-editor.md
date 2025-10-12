# Task: Map Editor Module

**Status:** TODO  
**Priority:** High  
**Created:** October 12, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Create a new game module "Map Editor" that allows designing and editing tactical maps. Features include hex grid editor, tile palette, map list with filtering, and save/load functionality.

---

## Purpose

Enable rapid creation and modification of tactical maps without manual TOML editing. Improve designer workflow and map creation speed. Essential tool for content creation.

---

## Requirements

### Functional Requirements
- [ ] New scene/module accessible from main menu
- [ ] Left panel (240px): Map list with filter, Save/Load buttons
- [ ] Center: Hex grid editor matching battlescape display
- [ ] Right panel (240px): Tile palette with filter
- [ ] LMB: Paint active tile on grid
- [ ] RMB: Pick tile from grid (eyedropper)
- [ ] Maps stored as TOML in `mods/new/mapblocks/`
- [ ] Real-time grid updates
- [ ] Undo/Redo support

### Technical Requirements
- [ ] 24×24 pixel grid alignment for all UI
- [ ] Widget-based UI (ListBox, TextInput, Button, etc.)
- [ ] TOML read/write for map persistence
- [ ] Hex coordinate system matching battlescape
- [ ] Viewport scrolling for large maps
- [ ] Efficient rendering (only visible tiles)
- [ ] Input handling for paint/pick tools

### Acceptance Criteria
- [ ] Editor accessible from main menu
- [ ] Can create new blank map
- [ ] Can load existing mapblock
- [ ] Can paint tiles with LMB
- [ ] Can pick tiles with RMB
- [ ] Can filter tile palette
- [ ] Can filter map list
- [ ] Can save map to TOML
- [ ] Saved maps load correctly in battlescape
- [ ] No performance issues with large maps
- [ ] All UI elements grid-aligned

---

## Plan

### Step 1: Create MapEditor Module Structure
**Description:** Set up basic module file and state registration  
**Files to create:**
- `engine/modules/map_editor.lua`

**Estimated time:** 30 minutes

### Step 2: Design UI Layout
**Description:** Plan widget layout with grid coordinates  
**Layout:**
- Left panel: (0, 0) to (10, 30) - 240×720 pixels
- Center: (10, 0) to (30, 30) - 480×720 pixels
- Right panel: (30, 0) to (40, 30) - 240×720 pixels

**Estimated time:** 20 minutes

### Step 3: Implement Left Panel (Map List)
**Description:** Create map list with filter and buttons  
**Widgets needed:**
- TextInput for filter (10×1 grid cells)
- ListBox for map list (10×24 grid cells)
- Button for Save (5×2 grid cells)
- Button for Load (5×2 grid cells)

**Files to modify:**
- `engine/modules/map_editor.lua`

**Estimated time:** 1.5 hours

### Step 4: Implement Center Panel (Hex Grid Editor)
**Description:** Create interactive hex grid with paint/pick tools  
**Features:**
- Render hex grid like battlescape
- Track mouse position to hex coordinates
- Paint tool (LMB)
- Pick tool (RMB)
- Visual feedback for active tile

**Files to modify:**
- `engine/modules/map_editor.lua`

**Estimated time:** 2 hours

### Step 5: Implement Right Panel (Tile Palette)
**Description:** Create filterable tile selection palette  
**Widgets needed:**
- TextInput for filter (10×1 grid cells)
- ListBox for tile list with images (10×28 grid cells)

**Files to modify:**
- `engine/modules/map_editor.lua`

**Estimated time:** 1 hour

### Step 6: Implement Save/Load Functionality
**Description:** TOML serialization for mapblocks  
**Functions:**
- saveMap(filename, mapData)
- loadMap(filename)
- scanMapblocks() - list available maps

**Files to modify:**
- `engine/modules/map_editor.lua`
- Create `engine/systems/mapblock_io.lua` (optional helper)

**Estimated time:** 1.5 hours

### Step 7: Add Undo/Redo System
**Description:** Track tile changes for undo/redo  
**Implementation:**
- Command pattern for tile changes
- Undo stack with max history
- Ctrl+Z / Ctrl+Y keyboard shortcuts

**Files to modify:**
- `engine/modules/map_editor.lua`

**Estimated time:** 1 hour

### Step 8: Polish and Testing
**Description:** UI polish, testing, bug fixes  
**Tasks:**
- Test with existing mapblocks
- Create new map from scratch
- Verify TOML output format
- Test in battlescape

**Estimated time:** 1 hour

---

## Implementation Details

### Architecture
Map Editor follows MVC pattern:
- **Model:** Map data structure (tiles, metadata, size)
- **View:** Widget-based UI and hex grid renderer
- **Controller:** Input handlers for paint/pick/save/load

### Key Components

**MapEditor Module:**
```lua
local MapEditor = {
    currentMap = nil,      -- Active map being edited
    activeTile = "floor",  -- Selected tile for painting
    mapList = {},          -- Available mapblocks
    tileList = {},         -- Available terrain tiles
    history = {},          -- Undo/redo stack
    widgets = {}           -- UI widgets
}
```

**Map Data Structure:**
```lua
{
    metadata = {
        id = "custom_map_01",
        name = "Custom Map",
        width = 20,
        height = 20,
        biome = "urban",
        difficulty = 2,
        author = "Player",
        tags = "custom"
    },
    tiles = {
        ["0_0"] = "road",
        ["0_1"] = "floor",
        -- ...
    }
}
```

**UI Layout (Grid Coordinates):**
```
┌─────────────┬──────────────────┬─────────────┐
│ Left Panel  │   Center View    │ Right Panel │
│ (0,0-10,30) │   (10,0-30,30)   │ (30,0-40,30)│
│             │                  │             │
│ [Filter   ] │                  │ [Filter   ] │
│ ┌─────────┐ │   ╱﹨╱﹨╱﹨╱﹨     │ ┌─────────┐ │
│ │Map List │ │  ╱  ╲  ╲  ╲      │ │Tile List│ │
│ │         │ │ ╱    ╲  ╲  ╲     │ │ [img] ID│ │
│ │         │ │ ﹨  ╱﹨  ╱﹨  ╱     │ │ [img] ID│ │
│ │         │ │  ╲╱  ╲╱  ╲╱      │ │ [img] ID│ │
│ └─────────┘ │                  │ └─────────┘ │
│ [Save][Load]│                  │             │
└─────────────┴──────────────────┴─────────────┘
```

### Dependencies
- Widget system (ListBox, TextInput, Button, Panel)
- TOML parser for save/load
- Terrain definitions from DataLoader
- Hex grid rendering from battlescape
- ModManager for mapblock paths

---

## Testing Strategy

### Unit Tests
- Test map data serialization/deserialization
- Test tile coordinate conversion
- Test undo/redo logic
- Test filter functionality

### Integration Tests
- Test saving map creates valid TOML
- Test loaded maps work in battlescape
- Test widget interactions
- Test keyboard shortcuts

### Manual Testing Steps
1. Launch game, select "Map Editor" from menu
2. Filter map list, select existing map
3. Click Load button
4. Use LMB to paint tiles
5. Use RMB to pick tiles
6. Filter tile palette
7. Create new blank map
8. Paint some tiles
9. Click Save, enter filename
10. Exit editor
11. Enter battlescape with new map
12. Verify map displays correctly

### Expected Results
- Editor UI displays correctly
- All widgets are grid-aligned
- Paint tool works smoothly
- Tile palette filters correctly
- Save creates valid TOML
- Saved maps load in battlescape
- Undo/redo works as expected

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```

### Accessing Map Editor
- Main Menu → "Map Editor" button

### Debugging
- Check console for "[MapEditor] Initialized"
- Use F9 to toggle grid overlay
- Print current tile: `print("Active tile: " .. MapEditor.activeTile)`
- Check saved TOML files in `mods/new/mapblocks/`

### Console Output to Look For
```
[MapEditor] Initialized
[MapEditor] Loaded 10 existing mapblocks
[MapEditor] Loaded 16 terrain types
[MapEditor] Map saved: custom_map_01.toml
[MapEditor] Map loaded: urban_block_01
```

### Temporary Files
Save drafts/backups to:
```lua
local tempDir = os.getenv("TEMP")
local autosavePath = tempDir .. "\\mapeditor_autosave.toml"
```

---

## Documentation Updates

### Files to Update
- [ ] `tasks/tasks.md` - Add task entry
- [ ] `wiki/API.md` - Document MapEditor module
- [ ] `wiki/DEVELOPMENT.md` - Add map editor to workflow
- [ ] `wiki/MAPBLOCK_GUIDE.md` - Add editor usage section
- [ ] `README.md` - Note map editor feature

---

## Notes

- Consider adding grid size selector (10×10, 15×15, 20×20, etc.)
- May want to add copy/paste functionality
- Could add layer support for multiple levels
- Consider terrain brush patterns (fill, line, rect)
- Add visual indicators for spawn points (future feature)

---

## Blockers

None. All required systems (widgets, TOML, terrain) are implemented.

---

## Review Checklist

- [ ] All UI elements grid-aligned (24×24 pixels)
- [ ] Uses existing widget system
- [ ] TOML output matches mapblock format
- [ ] No hardcoded paths
- [ ] Proper error handling
- [ ] Efficient rendering
- [ ] Undo/redo works correctly
- [ ] Keyboard shortcuts documented
- [ ] Tests written and passing
- [ ] Documentation updated
- [ ] No warnings in Love2D console

---

## Post-Completion

### What Worked Well
TBD

### What Could Be Improved
TBD

### Lessons Learned
TBD
