# Task: World Editor Tool Development

**Status:** TODO
**Priority:** Critical
**Created:** October 24, 2025
**Assigned To:** Development Team

---

## Overview

Develop a specialized editor for defining and editing the world structure at the strategic layer. The editor enables designers to create provinces, regions, countries, and biomes, then assign them to individual world tiles on the geoscape map. The world is a 90×45 hexagonal grid where each tile can be assigned terrain type, province, region, country, and biome.

---

## Purpose

The geoscape requires a pre-defined world structure with provinces (political boundaries), regions (geographical areas), countries (political entities), and biomes (environmental zones). Currently, this requires manual TOML editing. The editor provides:
- Visual interface for assigning world attributes to tiles
- Validation of assignments (ensure no orphan tiles)
- Organization of definitions by type
- Export to TOML format for game engine consumption

---

## Requirements

### Functional Requirements
- [x] Load world definitions from TOML files (provinces, regions, countries, biomes)
- [x] Display tab interface with separate panels for each entity type
- [x] Central editor panel for assigning attributes to world tiles
- [x] World tile type palette (WATER, LAND, ROUGH, BLOCK - hardcoded)
- [x] Assign Province, Region, Country, and Biome to individual tiles
- [x] Set terrain movement cost (affects movement between provinces)
- [x] Display existing definitions from TOML files
- [x] Save world state to TOML format
- [x] Load existing world definitions from TOML
- [x] Validation that all tiles have valid assignments
- [x] Layer visualization (view by province, region, country, or biome)

### Technical Requirements
- [x] Standalone Love2D application
- [x] Located in `tools/world_editor/`
- [x] Uses hexagonal grid system matching game world (90×45)
- [x] Tab widget for organizing entity type panels
- [x] TOML file I/O for definitions and world state
- [x] Definitions loaded from TOML (NOT created in editor)
- [x] Only assigning existing definitions is allowed
- [x] World tile type hardcoded (WATER, LAND, ROUGH, BLOCK)
- [x] Color coding for visual differentiation

### Acceptance Criteria
- [x] Editor launches without errors
- [x] Can load world definitions from TOML
- [x] Can create new world or load existing
- [x] Can assign entities to tiles
- [x] Can change terrain types
- [x] Can view world by different layers
- [x] Can save world to TOML format
- [x] Can load world back into game engine
- [x] Validation prevents invalid states
- [x] Performance: 60 FPS with 90×45 grid

---

## Plan

### Phase 1: Project Setup & World Grid (5 hours)
**Description:** Set up editor application and implement hexagonal world grid
**Files to create/modify:**
- `tools/world_editor/` (new directory)
- `tools/world_editor/main.lua` - Entry point
- `tools/world_editor/conf.lua` - Love2D configuration
- `tools/world_editor/src/world_grid.lua` - 90×45 hex grid data structure
- `tools/world_editor/src/hex_renderer.lua` - Isometric hex rendering

**Key tasks:**
- Create project structure with proper folder organization
- Implement 90×45 hexagonal grid (axial coordinates)
- Implement hex rendering with isometric view
- Add zoom and pan controls
- Display grid with tile coordinates

**Estimated time:** 5 hours

### Phase 2: Definition Manager System (7 hours)
**Description:** Implement loading and management of definitions
**Files to create/modify:**
- `tools/world_editor/src/definition_manager.lua` - Load/manage definitions
- `tools/world_editor/src/tab_widget.lua` - Tab control widget
- `tools/world_editor/src/entity_browser.lua` - Browse loaded definitions
- `mods/core/geoscape/worlds/` - World definition TOML files

**Key tasks:**
- Implement tab widget with 5 tabs (Provinces, Regions, Countries, Biomes, Settings)
- Create definition manager to load from TOML files
- Display provinces in Province tab with list view
- Display regions in Region tab with list view
- Display countries in Country tab with list view
- Display biomes in Biome tab with list view
- Add search/filter for finding definitions
- Allow selection of definitions for assignment

**Estimated time:** 7 hours

### Phase 3: World Tile Assignment System (8 hours)
**Description:** Implement tile assignment UI and core logic
**Files to create/modify:**
- `tools/world_editor/src/tile_selector.lua` - Central editor panel
- `tools/world_editor/src/tile_properties.lua` - Right panel showing tile properties
- `tools/world_editor/src/assignment_system.lua` - Core assignment logic
- `tools/world_editor/src/terrain_palette.lua` - Terrain type selector

**Key tasks:**
- Implement central editor with hex grid display
- Implement right panel showing selected tile properties
- Create terrain type palette (WATER, LAND, ROUGH, BLOCK)
- Implement tile selection (click on hex to select)
- Display selected tile's current assignments
- Implement assignment: click definition in left panel, then click tile
- Allow reassignment of individual attributes (province, region, country, biome, terrain)
- Add visual feedback for terrain types (color coding)

**Estimated time:** 8 hours

### Phase 4: Layer Visualization & Debugging (6 hours)
**Description:** Implement layer view and visualization tools
**Files to create/modify:**
- `tools/world_editor/src/layer_toggle.lua` - Layer switching UI
- `tools/world_editor/src/layer_renderer.lua` - Render different layers
- `tools/world_editor/src/validation_system.lua` - Validation and error checking

**Key tasks:**
- Implement layer toggle buttons (View by Province, Region, Country, Biome)
- Color-code tiles based on selected layer
- Display layer legend with entity names
- Implement validation checker:
  - All tiles have terrain type
  - All tiles have province (if LAND or ROUGH)
  - All tiles have biome (if LAND)
  - All tiles have country (if applicable)
- Display validation errors with tooltip/highlight
- Show statistics (# provinces, # regions, etc.)

**Estimated time:** 6 hours

### Phase 5: World Tile Type System (5 hours)
**Description:** Implement terrain type selection and movement costs
**Files to create/modify:**
- `tools/world_editor/src/terrain_type_system.lua` - Terrain mechanics
- `tools/world_editor/src/movement_cost_display.lua` - Display movement costs

**Key tasks:**
- Implement hardcoded terrain types:
  - WATER: Naval movement allowed, blocks land units
  - LAND: Land movement allowed, movement cost 1
  - ROUGH: Land movement allowed, movement cost 3
  - BLOCK: No movement allowed by any type
- Allow selection of terrain type for each tile
- Display movement cost in tile info panel
- Add terrain type color scheme:
  - WATER: Blue
  - LAND: Green
  - ROUGH: Brown
  - BLOCK: Gray
- Implement flood-fill tool for terrain types

**Estimated time:** 5 hours

### Phase 6: Import/Export & Validation (6 hours)
**Description:** Implement TOML save/load and validation
**Files to create/modify:**
- `tools/world_editor/src/exporter.lua` - TOML export
- `tools/world_editor/src/importer.lua` - TOML import
- `tools/world_editor/src/validator.lua` - Validation framework
- `mods/core/geoscape/` - World state TOML files

**Key tasks:**
- Implement world state TOML export:
  - Save all tile assignments (province, region, country, biome, terrain)
  - Save world metadata (name, version, date)
  - Use axial coordinates for compact representation
- Implement world state TOML import:
  - Load and validate TOML format
  - Check for missing definitions
  - Verify coordinate bounds
- Create comprehensive validation:
  - All tiles have valid assignments
  - All referenced definitions exist
  - No orphan provinces/regions/countries/biomes
- Export validation report

**Estimated time:** 6 hours

### Phase 7: UI Polish & Optimization (5 hours)
**Description:** Polish UI and optimize performance
**Files to create/modify:**
- `tools/world_editor/src/ui_theme.lua` - UI styling
- `tools/world_editor/src/performance_optimizer.lua` - Performance optimization
- `tools/world_editor/src/editor_preferences.lua` - User preferences

**Key tasks:**
- Optimize hex rendering (frustum culling, LOD)
- Implement dark/light theme toggle
- Add tooltips and help text
- Implement undo/redo for tile assignments
- Add status bar with world info (size, coverage %)
- Performance profiling and optimization
- Memory optimization for large world

**Estimated time:** 5 hours

### Phase 8: Testing & Documentation (5 hours)
**Description:** Comprehensive testing and user documentation
**Files to create/modify:**
- `tools/world_editor/README.md` - User guide
- `tools/world_editor/DEVELOPMENT.md` - Developer guide
- `tools/world_editor/tutorials/` - Step-by-step tutorials
- `tests/tools/world_editor_test.lua` - Automated tests

**Key tasks:**
- Create user guide with interface overview
- Create tutorials (create world, assign entities, etc.)
- Create developer guide
- Write automated tests for I/O and validation
- Create sample world for distribution
- Document world file format
- Verify exported world can be loaded in game

**Estimated time:** 5 hours

---

## Implementation Details

### Architecture

**Component Structure:**
- **World Grid:** 90×45 hexagonal grid (axial coordinates)
- **Definition Manager:** Load and manage entity definitions
- **Tile Assignment System:** Track province/region/country/biome/terrain per tile
- **Layer System:** Visualize different layers (province, region, etc.)
- **Validation System:** Check world state validity

### UI Layout

```
┌─────────────────────────────────────────────────┐
│ File | Edit | View | Help                        │ (Menu bar)
├──────────────────────────────────────────────────┤
│ New | Open | Save | Validate | Export           │ (Toolbar)
├─────────┬────────────────────────┬──────────────┤
│         │                        │ Properties   │
│ Defs    │    World Tile Grid     │              │
│ Tabs:   │    (Central Editor)    │ Tile:        │
│ Prov    │                        │ Province:[ ] │
│ Reg     │                        │ Region:  [ ] │
│ Count   │    [90×45 hex grid]    │ Country: [ ] │
│ Biome   │                        │ Biome:   [ ] │
│ Set     │                        │ Terrain: [ ] │
│         │                        │              │
├─────────┴────────────────────────┴──────────────┤
│ Viewport: Zoom 100% | Pan: [0, 0]              │ (Status bar)
└──────────────────────────────────────────────────┘
```

### Data Structures

**Tile Structure:**
```lua
{
  q = 0,              -- Axial coordinate
  r = 0,              -- Axial coordinate
  terrain = "LAND",   -- WATER, LAND, ROUGH, BLOCK
  province = "prov_france",
  region = "region_normandy",
  country = "country_france",
  biome = "biome_temperate_forest"
}
```

**Definition Structure:**
```lua
{
  id = "prov_france",
  name = "France",
  color = {0.2, 0.6, 0.2},  -- RGB for visualization
  type = "province"
}
```

### World TOML Format

```toml
# worlds/earth.toml
[world]
name = "Earth 1999"
width = 90
height = 45
version = "1.0.0"
created = "2025-10-24"

[[tiles]]
q = 0
r = 0
terrain = "LAND"
province = "prov_usa"
region = "region_west_coast"
country = "country_usa"
biome = "biome_temperate_forest"

[[tiles]]
q = 1
r = 0
terrain = "WATER"
province = "prov_pacific_ocean"
region = "region_pacific"
country = "country_international"
biome = "biome_ocean"
```

### Definition TOML Format

```toml
# geoscape/provinces.toml
[[provinces]]
id = "prov_france"
name = "France"
color = [0.2, 0.6, 0.2]

# geoscape/regions.toml
[[regions]]
id = "region_normandy"
name = "Normandy"
color = [0.4, 0.7, 0.4]

# geoscape/countries.toml
[[countries]]
id = "country_france"
name = "France"
color = [0.1, 0.3, 0.6]

# geoscape/biomes.toml
[[biomes]]
id = "biome_temperate_forest"
name = "Temperate Forest"
color = [0.0, 0.8, 0.0]
```

---

## Testing Strategy

### Unit Tests
- Tile assignment validation
- Definition loading from TOML
- Terrain type validation
- Layer rendering correctness

### Integration Tests
- Editor → Game Engine: World created in editor loads in game
- World persistence: Save/load cycle
- Large world: 90×45 grid performance

### Manual Testing Steps
1. Launch editor
2. Load definition files (provinces, regions, countries, biomes)
3. Create new 90×45 world
4. Switch to Province layer and verify empty
5. Assign province "France" to 10 tiles
6. Switch to Region layer and assign regions
7. Assign countries and biomes
8. Set terrain types (mix of LAND, WATER, ROUGH)
9. Run validation - should pass
10. Save world to TOML
11. Close and reopen editor
12. Load saved world
13. Verify assignments correct
14. Export to game format
15. Load in game engine

### Expected Results
- World displays 90×45 grid correctly
- Layer views show correct assignments
- Validation catches errors
- 60 FPS maintained
- World loads in game engine
- All assignments preserved through save/load cycle

---

## Dependencies

- Love2D 12.0+
- TOML parser (Lua implementation)
- Tab widget framework
- Hex math utilities
- Shared UI components

---

## Notes

- Editor is **standalone** and runs independently
- Definitions are **loaded from TOML** - not created in editor
- Only **assignment of existing definitions** is allowed
- Terrain types are **hardcoded** (WATER, LAND, ROUGH, BLOCK)
- World is always **90×45** hexagonal grid
- Axial coordinate system matches game engine

---

## Blockers

None identified.

---

## Review Checklist

- [ ] Editor launches without errors
- [ ] Can load definition files from TOML
- [ ] Can create new world (90×45)
- [ ] Can assign provinces/regions/countries/biomes to tiles
- [ ] Layer visualization works for all 4 layers
- [ ] Terrain types displayed with color coding
- [ ] Can change terrain types
- [ ] Validation system prevents invalid states
- [ ] TOML save/load works correctly
- [ ] Performance: 60 FPS on 90×45 grid
- [ ] Undo/redo tested
- [ ] User documentation complete
- [ ] Developer guide complete
- [ ] Code follows Lua standards
- [ ] No lint errors

---

## Post-Completion

### What Worked Well
- Hexagonal grid approach matches game world
- Tab interface organizes entity types logically
- Layer visualization makes assignments clear
- TOML format enables version control

### What Could Be Improved
- Consider adding flood-fill for terrain types
- Consider adding random generation templates
- Consider adding region painting tools
- Consider adding biome suggestions based on terrain

### Lessons Learned
- Definition validation critical to prevent corrupted worlds
- Color coding makes visualization much clearer
- Layer switching should be fast/responsive for large worlds

---

## Time Estimate Summary

| Phase | Duration | Total |
|-------|----------|-------|
| 1. Project Setup | 5h | 5h |
| 2. Definition Manager | 7h | 12h |
| 3. Tile Assignment | 8h | 20h |
| 4. Layer Visualization | 6h | 26h |
| 5. Terrain Type System | 5h | 31h |
| 6. Import/Export | 6h | 37h |
| 7. UI Polish | 5h | 42h |
| 8. Testing & Docs | 5h | 47h |
| **Total** | **47h** | **47h** |

**Estimated Total Time: 47 hours (6 days at 8h/day)**
