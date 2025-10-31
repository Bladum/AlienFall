# Hex Coordinate System

> **Status**: Technical Specification
> **Last Updated**: 2025-10-28
> **Related Systems**: Geoscape.md, Battlescape.md, Basescape.md

## Table of Contents
- [Overview](#overview)
- [Coordinate System](#coordinate-system)
- [Visual Representation](#visual-representation)
- [Map Block System](#map-block-system)
- [World Map](#world-map)
- [Battle Map](#battle-map)
- [Coordinate Calculations](#coordinate-calculations)
- [Implementation Guidelines](#implementation-guidelines)

---

## Overview

AlienFall uses a **Hex Vertical Axial** coordinate system for ALL maps in the game. This unified system applies to:
- World Map (Geoscape)
- Battle Map (Battlescape)
- Base Layout (Basescape)

While this creates visually "skewed" maps, it resolves numerous technical problems related to hex grid mathematics, pathfinding, and coordinate conversions.

### Key Benefits
- Single unified coordinate system across all game layers
- Simplified neighbor calculations
- No coordinate conversion errors between systems
- Consistent pathfinding algorithms
- Easier mod development (one system to learn)

---

## Coordinate System

### Axial Coordinates (q, r)
All hexagons use axial coordinates with two values:
- **q**: Column coordinate (horizontal axis)
- **r**: Row coordinate (vertical axis, shifted)

### Vertical Layout
- Hexagons have **flat sides on top and bottom** (⬡ orientation)
- Columns run vertically (parallel to r-axis)
- Odd columns (q=1, 3, 5...) are shifted down by 0.5 hex height
- Even columns (q=0, 2, 4...) are aligned

### Cube Coordinate Conversion
For distance calculations, convert to cube coordinates (x, y, z) where x+y+z=0:
```
x = q
z = r
y = -x - z
```

Distance formula:
```
distance = (|x1-x2| + |y1-y2| + |z1-z2|) / 2
```

### Six Neighbors (Vertical Axial)
Each hex has 6 neighbors:
```
Direction 0 (E):  q+1, r+0
Direction 1 (SE): q+0, r+1
Direction 2 (SW): q-1, r+1
Direction 3 (W):  q-1, r+0
Direction 4 (NW): q+0, r-1
Direction 5 (NE): q+1, r-1
```

---

## Visual Representation

### How It Looks

#### Standard Rectangular Building (Conceptually)
```
+---+---+---+
| 1 | 2 | 3 |
+---+---+---+
| 4 | 5 | 6 |
+---+---+---+
```

#### Same Building in Hex Vertical Axial (Pasted Image 1)
Due to the hex grid, rectangular structures appear "skewed":
```
   ⬡ ⬡ ⬡
  ⬡ ⬡ ⬡
```
- Rooms align to hex grid, not rectangular grid
- Walls follow hex edges (6 possible directions)
- Doorways connect adjacent hexes
- Visual appearance is "diamond-like" rather than rectangular

**This is intentional and correct behavior.**

---

## Map Block System

### Map Block Dimensions
Each map block contains **exactly 15 hexes** arranged in a ring pattern:
```
     ⬡ ⬡ ⬡
    ⬡ ⬡ ⬡ ⬡
   ⬡ ⬡ ⬡ ⬡ ⬡
    ⬡ ⬡ ⬡ ⬡
     ⬡ ⬡ ⬡

Center hex: q=2, r=2 (in local block coordinates)
Total hexes: 15
Pattern: Ring of 3 rows with 3-4-5-4-3 hexes
```

### Map Block Grid (Pasted Image 2)
Battle maps are built by arranging multiple map blocks in a grid:
- Small Battle: 4×4 blocks = 16 blocks = ~240 hexes
- Medium Battle: 5×5 blocks = 25 blocks = ~375 hexes
- Large Battle: 6×6 blocks = 36 blocks = ~540 hexes
- Huge Battle: 7×7 blocks = 49 blocks = ~735 hexes

Each block can be:
- Rotated (0°, 60°, 120°, 180°, 240°, 300°)
- Mirrored (horizontal or vertical)
- Inverted (swap terrain types)

---

## World Map

### Geoscape Grid (Pasted Image 4)
The world map uses a 90×45 hex grid representing Earth:
- **Width**: 90 hexes (q = 0 to 89)
- **Height**: 45 hexes (r = 0 to 44)
- **Total Provinces**: ~4050 hexes

### Visual Characteristics
- Coastlines follow hex edges (creates jagged appearance)
- Countries are collections of adjacent hexes
- Regions are larger groups of hexes
- Borders align to hex grid (no sub-hex precision)

### Map Wrapping
- Horizontal wrapping: q = 90 wraps to q = 0 (spherical Earth)
- No vertical wrapping: r = 0 and r = 44 are poles

---

## Battle Map

### Battle Tile (Smallest Unit)
Each hex on the battle map contains the following data:
- **Coordinates**: Q and R values for hex position
- **Terrain Type**: Classification such as floor, wall, water, fire
- **Walkability**: Boolean indicating if units can traverse this hex
- **Movement Cost**: AP cost to enter this hex
- **Occupant**: Reference to unit currently on hex (if any)
- **Ground Objects**: Items on ground (maximum 5 items)
- **Active Effects**: Environmental effects like smoke, fire, gas
- **LOS Obstruction**: Visibility blocking value (0.0 clear to 1.0 blocked)
- **Fog of War**: State of visibility (hidden, revealed, or active)

### Coordinate Ranges
For a medium battle (5×5 blocks):
- Local block coordinates: q=[0..4], r=[0..4] per block
- World battlefield coordinates: q=[0..24], r=[0..24]
- Total hexes: ~375 (15 hexes per block × 25 blocks)

---

## Coordinate Calculations

### Example from Pasted Image 3

#### Neighbor Calculation
Starting hex: `{q=3, r=4}`

Six neighbors in cardinal directions:
- **East** (dir 0): `{q=4, r=4}` (q+1, r+0)
- **Southeast** (dir 1): `{q=3, r=5}` (q+0, r+1)
- **Southwest** (dir 2): `{q=2, r=5}` (q-1, r+1)
- **West** (dir 3): `{q=2, r=4}` (q-1, r+0)
- **Northwest** (dir 4): `{q=3, r=3}` (q+0, r-1)
- **Northeast** (dir 5): `{q=4, r=3}` (q+1, r-1)

#### Distance Calculation
From `{q=0, r=0}` to `{q=5, r=3}`:

Conversion to cube coordinates:
- Hex1: x=0, y=0, z=0
- Hex2: x=5, y=-8, z=3

Distance = (|0-5| + |0-(-8)| + |0-3|) / 2
         = (5 + 8 + 3) / 2
         = 8 hexes
```

#### Pixel Conversion
For rendering, convert hex coordinates to pixel position:
```
hexSize = 24  -- pixels from center to corner
hexWidth = hexSize * sqrt(3) ≈ 41.57 pixels
hexHeight = hexSize * 2 = 48 pixels

pixelX = hexSize * sqrt(3) * q
pixelY = hexSize * 1.5 * r

For odd columns (q % 2 == 1):
  pixelY += hexSize * 0.75  -- shift down by half hex
```

---

## Implementation Guidelines

### All Maps Use Vertical Axial

**World Map (Geoscape):**
- Province grid: 90×45 hexes
- Each province: one hex
- Coordinates: {q, r} in range [0..89, 0..44]

**Battle Map (Battlescape):**
- Map blocks: 15 hexes each
- Battle grid: 4×4 to 7×7 blocks
- Coordinates: {q, r} in range [0..N] where N varies by map size

**Base Layout (Basescape):**
- Facility placement on hex grid
- Base dimensions: variable (typically 10×10 to 20×20 hexes)
- Facilities occupy multiple adjacent hexes

### Coordinate System Requirements

1. **Storage**: Always store as axial coordinates {q, r}
2. **Calculations**: Convert to cube {x, y, z} for distance/path
3. **Rendering**: Convert to pixel {x, y} for display
4. **Never mix systems**: Don't store offset coordinates

### API Consistency

All APIs must use axial coordinates. Function examples: `unit:moveTo(q, r)` where Q is axial column coordinate and R is axial row coordinate. Never use ambiguous pixel coordinates like `unit:moveTo(x, y)` which creates confusion between pixel and hex coordinates.

### Documentation Standards

Always specify coordinate system in function documentation with:
- Q parameter description (Axial Q coordinate - column)
- R parameter description (Axial R coordinate - row)
- Return value description indicating success flag
- Clear function signature showing hex-based coordinates for unit movement

---

## Benefits of This Approach

### Mathematical Consistency
- Single source of truth for all coordinate math
- No conversion errors between systems
- Simplified pathfinding algorithms
- Consistent neighbor calculations

### Development Efficiency
- Modders learn one system, not three
- Less code duplication
- Fewer bugs related to coordinate conversion
- Easier testing (one set of test cases)

### Visual Trade-offs
- Maps appear "skewed" or "diamond-shaped"
- Rectangular buildings look tilted
- Players adapt quickly to visual style
- Artistic style becomes distinctive feature

---

## Migration Notes

### Previous System Issues
- Multiple coordinate systems (offset, axial, cube)
- Conversion bugs between Geoscape and Battlescape
- Inconsistent neighbor calculations
- Different APIs for different map types

### New System Benefits
- Unified coordinate system eliminates conversion
- Single hex_math.lua module for all calculations
- Consistent API across all game layers
- Simplified documentation and tutorials

---

## Conclusion

The Hex Vertical Axial system is the **universal coordinate standard** for AlienFall. All maps, calculations, and APIs must use this system. While it creates visually unusual maps, the technical benefits far outweigh the aesthetic trade-offs, resulting in more robust, maintainable, and moddable code.

**When in doubt: Use axial coordinates {q, r} everywhere.**

## Examples

### Scenario 1: Pathfinding Calculation
**Setup**: Unit at {q: 0, r: 0} needs to move to {q: 2, r: 1}
**Action**: Calculate path using axial coordinates
**Result**: Path found through adjacent hexes, distance = 2

### Scenario 2: Range Check
**Setup**: Weapon with range 3, target at {q: 1, r: 2}
**Action**: Calculate distance from {q: 0, r: 0}
**Result**: Distance = 2, target within range

## Balance Parameters

| Parameter | Value | Range | Reasoning | Difficulty Scaling |
|-----------|-------|-------|-----------|-------------------|
| Hex Size | 24px radius | 16-32px | Visual clarity | No scaling |
| Neighbor Count | 6 | 4-8 | Tactical options | No scaling |
| Movement Cost | 1 per hex | 0.5-2 | Pacing control | No scaling |
| Diagonal Movement | Not allowed | Boolean | Simplicity | No scaling |

## Difficulty Scaling

### Easy Mode
- Clearer hex boundaries
- Simplified movement rules
- More forgiving positioning

### Normal Mode
- Standard hex mechanics
- Normal movement restrictions
- Standard visual clarity

### Hard Mode
- Smaller hex sizes
- Stricter positioning requirements
- More complex terrain interactions

### Impossible Mode
- Minimal visual feedback
- Complex hex interactions
- Severe movement penalties

## Testing Scenarios

- [ ] **Coordinate Conversion Test**: Convert between coordinate systems
  - **Setup**: Hex at axial {q: 1, r: 2}
  - **Action**: Convert to cube coordinates
  - **Expected**: Cube coordinates {x: 1, y: -3, z: 2}
  - **Verify**: x + y + z = 0

- [ ] **Neighbor Calculation Test**: Find adjacent hexes
  - **Setup**: Center hex at {q: 0, r: 0}
  - **Action**: Calculate all neighbors
  - **Expected**: 6 neighbors returned
  - **Verify**: No duplicates, all valid coordinates

## Related Features

- **[Geoscape System]**: World map coordinates (Geoscape.md)
- **[Battlescape System]**: Tactical map grid (Battlescape.md)
- **[Basescape System]**: Facility placement grid (Basescape.md)
- **[AI System]**: Pathfinding calculations (AI.md)

## Implementation Notes

- Vertical axial coordinate system {q, r}
- Cube coordinates for distance calculations
- Single hex_math.lua module for all operations
- No coordinate conversion between systems

## Review Checklist

- [ ] Coordinate system defined
- [ ] Visual representation specified
- [ ] Map block system documented
- [ ] World map integration complete
- [ ] Battle map integration complete
- [ ] Coordinate calculations verified
- [ ] Implementation guidelines followed
