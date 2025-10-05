# Map Creation Guide

## How to Create Custom Maps

Maps are PNG files where each pixel represents one grid tile. Colors determine terrain type and spawn points.

## Terrain Colors

Maps use the following color mapping (defined in `config/colors.lua`):

### Standard Terrain Types
```lua
Colors.TERRAIN_MAP = {
    [Constants.TERRAIN.FLOOR] = {0.5, 0.5, 0.5},  -- Gray (RGB: 128, 128, 128)
    [Constants.TERRAIN.WALL]  = {0.0, 0.0, 0.0},  -- Black (RGB: 0, 0, 0)
    [Constants.TERRAIN.DOOR]  = {0.6, 0.3, 0.0},  -- Brown (RGB: 153, 77, 0)
}
```

### Spawn Point Colors (Special)
These colors are detected separately and converted to floor tiles with units:

- **Yellow (RGB: 255, 255, 0)** = Player team spawn (Team 1)
- **Cyan (RGB: 0, 255, 255)** = Ally team spawn (Team 2)
- **Magenta (RGB: 255, 0, 255)** = Enemy team spawn (Team 3)
- **White (RGB: 255, 255, 255)** = Neutral team spawn (Team 4)

## Color Matching Tolerance

The MapLoader uses approximate color matching with a tolerance of 0.15 (out of 1.0). This means:
- Colors within 15% of target RGB values will match
- Slight variations in color are acceptable
- Makes hand-editing easier

## Creating a Map

### Option 1: Simple Image Editor (MS Paint, GIMP, etc.)

1. Create a new image:
   - Size: 60x60 pixels (or any square size, will be scaled)
   - Color mode: RGB
   - No alpha channel needed

2. Use the color palette:
   ```
   Black (0,0,0)         = Walls
   Gray (128,128,128)    = Floors
   Brown (153,77,0)      = Doors
   
   Yellow (255,255,0)    = Player spawn
   Cyan (0,255,255)      = Ally spawn
   Magenta (255,0,255)   = Enemy spawn
   White (255,255,255)   = Neutral spawn
   ```

3. Paint your map:
   - Draw black borders for walls
   - Fill interior with gray for floors
   - Add yellow pixel(s) where player units should start
   - Add magenta pixel(s) where enemy units should start
   - Add other spawn colors as needed

4. Save as PNG:
   - File > Save As > PNG
   - Name: `my_map.png`
   - Save to: `assets/maps/my_map.png`

5. Update main.lua:
   ```lua
   local mapFilename = "assets/maps/my_map.png"
   ```

### Option 2: Procedural Generation

Use the test map generator:
```lua
map, playerStarts = MapLoader.generateTestMap(60, 60)
```

Then save it to edit:
```lua
MapLoader.saveToPNG(map, "my_exported_map.png")
```

### Option 3: Code-Based Generation

Create maps programmatically:
```lua
local map = {}
for y = 1, 60 do
    map[y] = {}
    for x = 1, 60 do
        if x == 1 or x == 60 or y == 1 or y == 60 then
            map[y][x] = Tile.new(x, y, Constants.TERRAIN.WALL)
        else
            map[y][x] = Tile.new(x, y, Constants.TERRAIN.FLOOR)
        end
    end
end
```

## Example Map Layouts

### Simple Arena (20x20)
```
WWWWWWWWWWWWWWWWWWWW
W..................W
W..................W
W..................W
W..................W
W.....Y............W  (Y = Player spawn)
W..................W
W..................W
W..................W
W..................W
W..................W
W..................W
W..................W
W..................W
W............M.....W  (M = Enemy spawn)
W..................W
W..................W
W..................W
W..................W
WWWWWWWWWWWWWWWWWWWW

W = Black pixel (wall)
. = Gray pixel (floor)
Y = Yellow pixel (player)
M = Magenta pixel (enemy)
```

### Maze with Multiple Teams
```
WWWWWWWWWWWWWWW
WY..W.........W
W...W.........W  Y = Player
W...WWWWW.....W  C = Ally
W.............W  M = Enemy
W.....WWWW....W  W = Neutral
W.....W..W....W
W..C..W..W....W
WWWWW.W..W....W
W.....W..WWWWWW
W.............W
W..M..........W
W.........W...W
W.........W...W
WWWWWWWWWWWWWWW
```

## Advanced Techniques

### Adding New Terrain Types

1. Add to Constants.lua:
   ```lua
   Constants.TERRAIN = {
       FLOOR = 1,
       WALL = 2,
       DOOR = 3,
       WATER = 4,  -- New!
       LAVA = 5,   -- New!
   }
   ```

2. Add colors to colors.lua:
   ```lua
   Colors.TERRAIN_MAP = {
       [Constants.TERRAIN.FLOOR] = {0.5, 0.5, 0.5},
       [Constants.TERRAIN.WALL] = {0.0, 0.0, 0.0},
       [Constants.TERRAIN.DOOR] = {0.6, 0.3, 0.0},
       [Constants.TERRAIN.WATER] = {0.0, 0.3, 0.8},  -- Blue
       [Constants.TERRAIN.LAVA] = {1.0, 0.2, 0.0},   -- Orange
   }
   ```

3. Update Tile.lua if needed:
   ```lua
   function Tile:isTraversable()
       return self.terrainType ~= Constants.TERRAIN.WALL and
              self.terrainType ~= Constants.TERRAIN.LAVA
   end
   ```

### Multiple Spawn Points per Team

Simply use multiple pixels of the same color:
```
Yellow pixel at (10, 10) = Player unit 1
Yellow pixel at (12, 10) = Player unit 2
Yellow pixel at (14, 10) = Player unit 3

Magenta pixel at (50, 50) = Enemy unit 1
Magenta pixel at (48, 50) = Enemy unit 2
```

### Map Scaling

Maps are automatically scaled to match `Constants.GRID_SIZE`:
- A 30x30 PNG will be upscaled to 60x60
- A 120x120 PNG will be downscaled to 60x60
- Non-square images will be cropped

For best results:
- Use exact grid size (60x60)
- Or use multiples (30x30, 120x120, etc.)

## Testing Your Map

1. Create your PNG file
2. Place in `assets/maps/`
3. Update main.lua:
   ```lua
   local mapFilename = "assets/maps/your_map.png"
   ```
4. Run the game:
   ```bash
   cd 3d_tactical_game
   love .
   ```
5. Check console output:
   ```
   MapLoader: Loading map from assets/maps/your_map.png
   MapLoader: PNG dimensions: 60x60, target grid: 60x60
   MapLoader: Player start at (10, 10)
   MapLoader: Enemy start at (50, 50)
   MapLoader: Loaded 60x60 grid with 2 spawn points
   ```

## Troubleshooting

### "Failed to load image data"
- Check file path is correct
- Verify PNG is in `assets/maps/` folder
- Make sure file extension is `.png` not `.PNG` or `.jpg`

### "No spawn points found"
- Check spawn colors are correct RGB values
- Yellow = (255, 255, 0)
- Magenta = (255, 0, 255)
- Use exact colors, tolerance is only 15%

### "Units not spawning where expected"
- Remember: PNG coordinates are (x, y) from top-left
- Game grid is [y][x] indexing
- Check console output for actual spawn coordinates

### Map looks wrong in game
- Verify terrain colors match `Colors.TERRAIN_MAP`
- Use color picker to check exact RGB values
- Remember black (0,0,0) is wall, gray (128,128,128) is floor

## Example: Creating a Test Map in GIMP

1. File > New > 60x60 pixels, RGB mode
2. Select pencil tool (hard edge, 1px size)
3. Set foreground color to black (0,0,0)
4. Draw border around edges
5. Draw some interior walls
6. Set foreground to gray (128,128,128)
7. Fill remaining areas
8. Set foreground to yellow (255,255,0)
9. Click once for player spawn
10. Set foreground to magenta (255,0,255)
11. Click once for enemy spawn
12. File > Export As > my_map.png
13. Copy to `assets/maps/`
14. Test!

---

## Ready to Design!

Start with simple layouts and gradually add complexity. Remember:
- Keep spawn points away from walls
- Balance team starting positions
- Test frequently
- Use the test map generator as a starting point

Happy mapping! 🗺️
