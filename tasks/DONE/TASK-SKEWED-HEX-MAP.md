## Skewed Hex Map Implementation Plan

### Overview
This document outlines the plan for implementing a skewed hex map rendering system, as shown in the reference image. The current system uses offset coordinates with vertical columns. The new system will use a diagonal/skewed layout for more natural hex representation.

### Current System
- **Coordinate System**: Offset coordinates (column, row)
- **Visual Layout**: Vertical columns with alternating rows offset
- **Tile Positioning**: Each tile at (x, y) offset if column is even

### Proposed Skewed Hex System

#### Coordinate System
- **Axial Coordinates**: (q, r) - already used internally
- **Pixel Mapping**: Skewed layout where hexes are arranged diagonally

#### Visual Layout
```
Current (Vertical):        Proposed (Skewed):
  O   O   O                O  O  O  O
   O   O   O              O  O  O  O
  O   O   O              O  O  O  O
   O   O   O            O  O  O  O
```

#### Implementation Steps

1. **Update Rendering**
   - Modify `BattlefieldRenderer` to use skewed positioning
   - Formula for skewed hex layout:
     ```lua
     x_pixel = q * tile_width * 0.75
     y_pixel = (q * 0.5 + r) * tile_height
     ```

2. **Update Input Handling**
   - Convert mouse clicks to skewed hex coordinates
   - Reverse transformation:
     ```lua
     q = x_pixel / (tile_width * 0.75)
     r = (y_pixel - q * 0.5 * tile_height) / tile_height
     ```

3. **Update Camera System**
   - Adjust camera bounds for skewed layout
   - Update minimap to show skewed representation

4. **Update Pathfinding**
   - No changes needed (uses axial coordinates internally)
   - Already hex-aware with proper neighbor calculations

5. **Update LOS System**
   - No changes needed (uses axial coordinates)
   - Raycasting works in coordinate space, not pixel space

#### Benefits
- More natural hex representation
- Better matches traditional hex board games
- Easier to see hex structure visually
- Diagonal paths look more natural

#### Backwards Compatibility
- Keep offset coordinate conversion functions
- Add flag to toggle between layouts
- Update save/load to handle both formats

#### Files to Modify
- `engine/systems/battle/renderer.lua` - Main rendering changes
- `engine/modules/battlescape.lua` - Input handling
- `engine/systems/battle/camera.lua` - Camera bounds
- `engine/systems/battle/hex_math.lua` - Add skewed conversion functions

#### Testing Checklist
- [ ] Units render in correct positions
- [ ] Mouse clicks select correct tiles
- [ ] Pathfinding displays correctly
- [ ] Movement animations work
- [ ] Camera panning feels natural
- [ ] Minimap shows correct representation
- [ ] Fog of war aligns properly
- [ ] All existing features work (LOS, movement, etc.)

### Reference Image Analysis
The attached image shows:
- Diagonal hex arrangement
- Each row offset by half a hex width
- Natural 60-degree angles between hex faces
- Compact representation (less wasted space)

### Implementation Priority
- **Phase 1**: Add skewed rendering (visual only)
- **Phase 2**: Update input handling
- **Phase 3**: Update camera and minimap
- **Phase 4**: Testing and refinement
- **Phase 5**: Make configurable via setting

### Notes
- This is a FUTURE enhancement
- Current system works fine for gameplay
- Mainly aesthetic improvement
- Can be added without breaking existing saves
