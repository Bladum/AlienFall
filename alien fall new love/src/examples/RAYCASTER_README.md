# 3D Raycaster Demo - Wolfenstein/Dungeon Master Style

## Overview
First-person 3D perspective renderer inspired by classic games:
- **Wolfenstein 3D** - Fast raycasting engine
- **Eye of the Beholder** - Grid-based dungeon crawler
- **Dungeon Master** - First-person perspective
- **Ishar** - Atmospheric 3D environments

## Technical Implementation

### Rendering Method
- **Raycasting with DDA Algorithm**: Digital Differential Analyzer for precise wall detection
- **Colored Polygon Walls**: Each vertical screen strip is a colored rectangle (not textured yet)
- **Fixed Z-axis**: Single-layer block world (like early Minecraft or Wolfenstein)
- **First-Person Eye View**: Player sees from eye-level perspective

### Visual Features

#### Wall Colors (Based on Wall Type)
- **Type 1 (Red)**: Outer boundary walls - RGB(0.7, 0.3, 0.3)
- **Type 2 (Green)**: Inner room walls - RGB(0.3, 0.7, 0.3)
- **Type 3 (Blue)**: Special areas - RGB(0.3, 0.3, 0.7)
- **Type 4 (Yellow)**: Reserved - RGB(0.7, 0.7, 0.3)
- **Type 5 (Magenta)**: Reserved - RGB(0.7, 0.3, 0.7)

#### Depth Perception Effects
1. **Side Shading**: X-side walls are 70% brightness, Y-side walls are 100% (creates sense of direction)
2. **Distance Fog**: Walls fade darker with distance (30% minimum brightness)
3. **Fish-eye Correction**: Proper distance calculation prevents curved walls
4. **Perspective Scaling**: Closer walls appear taller (inverse distance projection)

### Controls
- **W**: Move forward
- **S**: Move backward
- **A**: Strafe left
- **D**: Strafe right
- **Q**: Rotate 90° left
- **E**: Rotate 90° right
- **ESC**: Exit

### Technical Constants
```lua
FOV = 90°              -- Field of view (wider than Wolfenstein's 60°)
WALL_HEIGHT = 300px    -- Base wall height for projection
DISTANCE_SCALE = 60    -- Projection distance multiplier
MAX_DEPTH = 20 tiles   -- Maximum ray distance
NUM_RAYS = 800         -- One ray per screen pixel (width)
```

### Map Structure
- **32x32 grid** of tiles
- **0**: Empty floor (walkable)
- **1-5**: Wall types with different colors
- Player starts at position (2.5, 2.5)

### Rendering Pipeline
1. Clear screen with ceiling (dark blue-gray) and floor (dark brown-gray)
2. Cast 800 rays (one per horizontal pixel) across field of view
3. For each ray:
   - Use DDA algorithm to find nearest wall
   - Calculate corrected distance (fish-eye fix)
   - Compute wall height based on distance
   - Apply wall color based on type
   - Apply side shading (x-side darker)
   - Apply distance fog
   - Draw vertical colored strip

### Future Enhancements (Not Implemented)
- [ ] Textured walls using image mapping
- [ ] Textured floor/ceiling
- [ ] Multiple height levels
- [ ] Sprites (enemies, items, decorations)
- [ ] Doors and interactive objects
- [ ] Lighting effects
- [ ] Shadows

## Comparison to Classic Games

### Wolfenstein 3D
- ✅ Grid-based movement
- ✅ Raycasting renderer
- ✅ 90-degree rotation
- ✅ First-person perspective
- ❌ No textures yet (using colors)
- ❌ No sprites yet

### Dungeon Master / Eye of the Beholder
- ✅ Grid-based movement
- ✅ First-person view
- ✅ 90-degree rotation
- ✅ Block-based world
- ❌ No complex UI overlay yet
- ❌ No party system

### Minecraft (Classic Mode)
- ✅ Block-based world
- ✅ First-person view
- ✅ Single Z-layer
- ❌ No free-look (grid-locked)
- ❌ No building/mining

## Code Architecture

### Key Functions
- `castRay(angle)`: DDA raycasting algorithm - returns distance, wall type, and hit side
- `draw3DView()`: Main rendering function - casts rays and draws colored wall strips
- `drawMinimap()`: Top-down 2D map overlay
- `getMapCell(x, y)`: Safe map access with boundary checking

### Performance
- **800 rays per frame** (one per pixel width)
- **Efficient DDA algorithm** (no expensive square roots per step)
- **Simple polygon fills** (rectangles only)
- **Target: 60 FPS** at 800x600 resolution

## Usage in Game
This demo serves as the foundation for the tactical battlescape renderer, showing how to:
1. Render 3D perspective from 2D grid data
2. Handle player movement and collision
3. Create depth perception without complex 3D math
4. Maintain performance with simple raycasting
