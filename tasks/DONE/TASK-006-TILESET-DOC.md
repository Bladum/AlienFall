# TASK-006: Tileset System Documentation

**Status:** DONE  
**Created:** October 15, 2025  
**Completed:** October 15, 2025  
**Priority:** HIGH  
**Effort:** 12 hours

## Overview

Document tileset organization, Map Tile definitions, and multi-tile modes (variants, animation, autotile, damage states).

## Completed Work

✅ Created `docs/systems/TILESET_SYSTEM.md` (825 lines)
- Complete tileset architecture
- 5 common tilesets documented
- Multi-tile modes (random variant, sprite animation, autotile, damage states)
- Asset creation guidelines
- Modding support

## What Was Done

1. Extracted from `wiki/TILESET_SYSTEM.md`
2. Organized by topic (overview, architecture, modes, integration)
3. Included TOML definition examples
4. Created asset creation guidelines

## System Architecture

```
Tilesets (Folders)
  ↓
PNG Files (24×24 or larger)
  ↓
Map Tiles (TOML definitions with KEYs)
  ↓
Map Blocks (15×15 grids)
  ↓
Battlefield (Rendered maps)
```

## Multi-Tile Modes

1. **Random Variant** - Multiple 24×24 sections stacked
2. **Sprite Animation** - Animated frames for doors, fires, machinery
3. **Autotile Generation** - Seamless transitions for roads, walls
4. **Multi-Cell Occupancy** - Large objects spanning multiple hexes
5. **Damage States** - Visual progression as health decreases

## Common Tilesets

- Furnitures (chairs, tables, shelves)
- Weapons (crates, racks, equipment)
- Farmland (hay, fences, trees)
- City (walls, roads, lights)
- UFO Ship (alien structures, doors, consoles)

## Asset Guidelines

- PNG dimensions: Multiples of 24
- Color: 24-bit RGB or 32-bit RGBA
- Naming: lowercase_with_underscores
- Format examples provided

## Testing

- ✅ All modes documented
- ✅ Examples validated
- ✅ Asset creation guidelines complete

---

**Document Version:** 1.0  
**Status:** COMPLETE - Asset System Documentation
