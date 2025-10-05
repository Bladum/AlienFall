# 3D Maze Demo - Map System Documentation

## Overview
This demo features a complete PNG-based map save/load system with terrain-based level design.

## Controls
- **Arrow Keys / WASD**: Move forward/backward, turn left/right
- **Q/E**: Quick turn left/right (90 degrees)
- **P**: Save current map to PNG file
- **L**: Load the most recent PNG map file
- **ESC**: Exit game

## Terrain Types and Colors

The game uses hex color-coded terrains that can be edited in any image editor:

| Terrain Type | Hex Color | RGB | Walkable | Description |
|--------------|-----------|-----|----------|-------------|
| Stone Wall | #000000 | (0, 0, 0) | No | Solid stone walls |
| Grass | #008000 | (0, 128, 0) | Yes | Grass floor |
| Path | #994D00 | (153, 77, 0) | Yes | Brown dirt path |
| Stone Floor | #B3B3B3 | (179, 179, 179) | Yes | Light gray stone |
| Wood Wall | #996633 | (153, 102, 51) | No | Light brown wood wall |
| Wood Door | #FF0000 | (255, 0, 0) | Yes | Red door (walkable) |
| Player Start | #FFFF00 | (255, 255, 0) | N/A | Yellow marker for spawn |

## File Locations

### Save Location
Maps are saved to the **project directory** (where main.lua is located):
```
c:\Users\tombl\Documents\Projects\3d_maze_demo\maze_map_YYYYMMDD_HHMMSS.png
```

### File Format
- PNG format, 60x60 pixels (matches maze size)
- Each pixel represents one tile
- Hex color values determine terrain type
- Yellow pixel (#FFFF00) marks player spawn position

## Workflow

### 1. Generate and Save
1. Run the game
2. Press **P** to save the current map
3. File saves to project directory with timestamp

### 2. Edit Map
1. Open the PNG file in any image editor (Paint, GIMP, Photoshop, etc.)
2. Use the exact hex colors from the table above
3. Paint pixels to create your custom map layout:
   - #000000 for walls
   - #008000 for grass areas
   - #994D00 for paths
   - #FF0000 for doors
   - #FFFF00 for where player should start
4. Save the file

### 3. Load Custom Map
1. Run the game
2. Press **L** to load the most recent PNG
3. Game will:
   - Read all pixel colors
   - Match colors to nearest terrain type
   - Rebuild 3D geometry
   - Position player at yellow pixel (or center if no yellow found)

## Minimap

The minimap in the top-left corner shows:
- Color-coded terrain (matching PNG colors)
- Player position (yellow dot)
- Player facing direction (red line)
- 30x30 tile view area centered on player

## Technical Details

### Color Matching
The loader uses Euclidean distance in RGB space to find the closest terrain match for each pixel. This allows some tolerance for compression artifacts.

### Map Rebuilding
When a map loads:
1. All maze tiles are updated with new terrain data
2. Wall geometry is regenerated for non-walkable terrain
3. Floor geometry is regenerated for walkable terrain
4. Player is repositioned to spawn point
5. 3D models are recreated

### Love2D 12 Compatibility
- Uses `love.graphics.readbackTexture()` instead of deprecated `canvas:newImageData()`
- Saves directly to filesystem using absolute paths
- Compatible with Love2D 11.x and 12.x

## Example Custom Maps

### Simple Room
Create a #000000 border (walls) with #008000 grass inside and a #FFFF00 pixel for spawn.

### Maze
Paint #000000 stone walls in a maze pattern, #994D00 paths for corridors, and #FF0000 doors at key points.

### Multi-Area
Use different floor types (#008000 grass, #B3B3B3 stone, #994D00 path) to create distinct themed areas.

## Tips for Map Editing

1. **Use exact colors**: Even 1 RGB value off will match to wrong terrain
2. **Zoom in**: Work at high zoom (400%+) to paint individual pixels
3. **Test frequently**: Save and load often to see results
4. **Mark spawn**: Always include one #FFFF00 pixel or player spawns at center
5. **Hex color picker**: Use #000000, #008000, #994D00, #B3B3B3, #996633, #FF0000, #FFFF00
5. **Accessible spawn**: Make sure yellow pixel is on walkable terrain

## Troubleshooting

### Map doesn't load
- Check file is in project directory
- Verify file is exactly 60x60 pixels
- Ensure filename starts with "maze_map_"

### Wrong terrain appears
- Use eyedropper to verify hex color values
- Avoid anti-aliasing or gradients
- Save as PNG-8 for exact colors

### Player spawns in wall
- Check yellow pixel (#FFFF00) is on walkable terrain (not #000000/#996633)
- If no yellow pixel, player spawns at maze center

## Future Enhancements

Possible additions:
- Variable maze sizes
- More terrain types
- Animated textures
- Multiple floor levels
- Save/load to custom filenames
