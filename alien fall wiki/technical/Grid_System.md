# Grid System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Core Grid Specifications](#core-grid-specifications)
  - [Sprite System](#sprite-system)
  - [UI Layout System](#ui-layout-system)
  - [Coordinate Systems](#coordinate-systems)
  - [Rendering System](#rendering-system)
  - [Battlescape Grid](#battlescape-grid)
  - [Grid Calculator Utility](#grid-calculator-utility)
  - [Design Constraints](#design-constraints)
  - [Visual Guidelines](#visual-guidelines)
  - [Debugging Tools](#debugging-tools)
- [Examples](#examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Grid System defines Alien Fall's 20×20 pixel grid architecture as the single source of truth for all UI elements, sprites, and layouts throughout the game. AlienFall is a pixel art game with fixed 800×600 internal resolution (40×30 grid units), where the grid system ensures crisp visuals and predictable layouts across all screens through strict adherence to grid-aligned positioning and nearest-neighbor filtering. All measurements in the game are multiples of 20 pixels, with sprite art created at 10×10 resolution and scaled 2× during rendering to match grid cells exactly.

The system encompasses sprite alignment, UI widget positioning, coordinate system transformations, and rendering configuration to deliver pixel-perfect consistency. The grid framework supports both fixed UI layouts and dynamic battlescape grids while maintaining visual clarity and tactical precision through deterministic positioning rules.

## Mechanics

### Core Grid Specifications

### Grid Unit Definition

```
GRID_SIZE = 20 pixels
```

**All measurements in AlienFall are multiples of 20 pixels.**

### Resolution Breakdown

**Internal Resolution:**
```
Width:  800 pixels = 40 grid units
Height: 600 pixels = 30 grid units
Total:  40×30 grid = 1200 grid cells
```

**Visual Representation:**
```
┌────────────────────────────────────────┐ ← 800px (40 grid units)
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │ Each ░ = 20×20 grid cell
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│ ... (30 rows total) ...                 │
└────────────────────────────────────────┘
↑
600px (30 grid units)
```

---

## Sprite System

### Sprite Resolution

**Base Sprite Size:**
```
10×10 pixels at 1× scale (native art resolution)
```

**Displayed Sprite Size:**
```
20×20 pixels at 2× scale (matches grid cell exactly)
```

**Rendering:**
```lua
-- Pixel-perfect sprite rendering
love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.draw(sprite, x, y, 0, 2, 2)  -- 2× scale factor
```

### Sprite Alignment

**Grid-Aligned Sprites:**
```
sprite.x = grid_unit_x * GRID_SIZE
sprite.y = grid_unit_y * GRID_SIZE

Example:
Grid position (5, 3) → Screen position (100, 60) pixels
```

**Sub-Pixel Movement:**
```
-- NOT ALLOWED for UI elements
sprite.x = 103.5  -- WRONG: Not on grid

-- ALLOWED for smooth animation (intermediate frames)
-- But final resting position must be grid-aligned
```

### Multi-Cell Sprites

**2×2 Sprites:**
```
Dimensions: 40×40 pixels (2 grid units × 2 grid units)
Origin: Top-left corner at grid position
Example: Large unit icon, 2×2 facility
```

**4×4 Sprites:**
```
Dimensions: 80×80 pixels (4 grid units × 4 grid units)
Origin: Top-left corner at grid position
Example: Huge building, large enemy
```

**Arbitrary Sizes:**
```
Width/Height must be multiples of GRID_SIZE (20px)
Valid: 20, 40, 60, 80, 100, 120, 140, 160, 180, 200...
Invalid: 15, 25, 37, 50, 73, 111...
```

---

## UI Layout System

### Widget Sizing

**Standard Button:**
```
Width:  4 grid units (80px)
Height: 2 grid units (40px)
```

**Small Button:**
```
Width:  3 grid units (60px)
Height: 1 grid unit (20px)
```

**Large Button:**
```
Width:  6 grid units (120px)
Height: 2 grid units (40px)
```

**Panel/Window:**
```
Minimum: 10×10 grid units (200×200px)
Maximum: 38×28 grid units (760×560px)
  → Leave 1 grid unit margin on all sides
```

### Layout Grid Examples

**Main Menu Screen (40×30 grid):**
```
┌──────────────────────────────────────┐
│ ████████ ALIEN FALL ████████         │ Row 0-4: Title
│                                      │
│          ╔════════════╗              │ Row 10-12: New Game button
│          ║ NEW  GAME  ║              │
│          ╚════════════╝              │
│          ╔════════════╗              │ Row 14-16: Continue button
│          ║  CONTINUE  ║              │
│          ╚════════════╝              │
│          ╔════════════╗              │ Row 18-20: Options button
│          ║  OPTIONS   ║              │
│          ╚════════════╝              │
│          ╔════════════╗              │ Row 22-24: Quit button
│          ║    QUIT    ║              │
│          ╚════════════╝              │
└──────────────────────────────────────┘
```

**Geoscape HUD (40×30 grid):**
```
┌──────────────────────────────────────┐
│ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █ █  │ Row 0-1: Top bar
│ ┌────────────────────────┐ ┌──────┐ │
│ │                        │ │ INFO │ │ Row 2-22: Map + sidebar
│ │      MAP  VIEW         │ │ PANE │ │
│ │                        │ │      │ │
│ │                        │ └──────┘ │
│ └────────────────────────┘          │
│ [BTN] [BTN] [BTN] [BTN] [BTN] [BTN] │ Row 28-29: Bottom buttons
└──────────────────────────────────────┘
```

### Spacing Rules

**Margin:**
```
Screen edge margin: 1 grid unit (20px)
Panel edge margin: 1 grid unit (20px)
```

**Padding:**
```
Button padding: 0.5 grid units (10px) inside border
Text padding: 0.5 grid units (10px) from container edge
```

**Gap:**
```
Button gap: 1 grid unit (20px) between buttons
Section gap: 2 grid units (40px) between major sections
```

---

## Coordinate Systems

### Logical Coordinates (Grid Units)

**Grid Position:**
```lua
-- Position in grid units (0-39 for x, 0-29 for y)
logical_x = 10  -- 10th grid column
logical_y = 5   -- 5th grid row
```

**Conversion to Screen:**
```lua
screen_x = logical_x * GRID_SIZE  -- 10 * 20 = 200px
screen_y = logical_y * GRID_SIZE  -- 5 * 20 = 100px
```

### Screen Coordinates (Pixels)

**Pixel Position:**
```lua
-- Position in pixels (0-800 for x, 0-600 for y)
pixel_x = 200
pixel_y = 100
```

**Conversion to Grid:**
```lua
logical_x = math.floor(pixel_x / GRID_SIZE)  -- 200 / 20 = 10
logical_y = math.floor(pixel_y / GRID_SIZE)  -- 100 / 20 = 5
```

### Mouse Coordinates

**Window Space → Internal Space:**
```lua
-- Mouse position in window (can be any size due to scaling)
mouse_window_x, mouse_window_y = love.mouse.getPosition()

-- Convert to internal 800×600 space
local window_width, window_height = love.graphics.getDimensions()
local scale_x = 800 / window_width
local scale_y = 600 / window_height

internal_x = mouse_window_x * scale_x
internal_y = mouse_window_y * scale_y

-- Convert to grid units
grid_x = math.floor(internal_x / GRID_SIZE)
grid_y = math.floor(internal_y / GRID_SIZE)
```

---

## Rendering System

### Display Modes

**Windowed Mode:**
```
Initial window size: 800×600 (1:1 pixel mapping)
Resizable: Yes (maintains aspect ratio)
Scaling: Nearest-neighbor (pixel-perfect)
```

**Fullscreen Mode:**
```
Method: Letterboxed (black bars if needed)
Aspect ratio: 4:3 (800:600)
Scaling: Integer multiples preferred (2×, 3×, 4×)
Fallback: Non-integer scale with nearest-neighbor filtering
```

### Scaling System

**Canvas Rendering:**
```lua
-- Create internal 800×600 canvas
local canvas = love.graphics.newCanvas(800, 600)
canvas:setFilter("nearest", "nearest")  -- Pixel-perfect

function love.draw()
    -- Draw to internal canvas
    love.graphics.setCanvas(canvas)
    draw_game_content()
    love.graphics.setCanvas()
    
    -- Scale canvas to window
    local window_w, window_h = love.graphics.getDimensions()
    local scale_x = window_w / 800
    local scale_y = window_h / 600
    local scale = math.min(scale_x, scale_y)  -- Maintain aspect ratio
    
    local offset_x = (window_w - 800 * scale) / 2
    local offset_y = (window_h - 600 * scale) / 2
    
    love.graphics.draw(canvas, offset_x, offset_y, 0, scale, scale)
end
```

### Anti-Aliasing

**Disabled:**
```lua
-- conf.lua
t.window.msaa = 0  -- No anti-aliasing for crisp pixel art
```

**Font Rendering:**
```lua
-- Use pixel fonts or scale appropriately
font = love.graphics.newFont("pixel_font.ttf", 16)
font:setFilter("nearest", "nearest")
```

---

## Battlescape Grid

### Tactical Grid

**Map Tiles:**
```
1 battlefield tile = 1 grid unit = 20×20 pixels (at 2× scale)
Native tile art: 10×10 pixels (scaled 2×)
```

**Viewport:**
```
Visible area: 32×24 tiles (640×480 pixels)
Map size: Unlimited (scrollable)
Scroll increment: 1 tile (20 pixels)
```

**Unit Sprites:**
```
Standard unit: 1×1 tile (20×20 pixels)
Large unit: 2×2 tiles (40×40 pixels)
Huge unit: 4×4 tiles (80×80 pixels)
```

### Isometric Considerations

**Note:** AlienFall uses top-down view, not isometric.

If future isometric mode is added:
```
Tile footprint: Still 20×20 grid cell
Tile art: May be taller (e.g., 20×30 for vertical walls)
Alignment: Base of tile aligns to grid
```

---

## Grid Calculator Utility

### Position Calculations

**Grid to Pixel:**
```lua
function grid_to_pixel(grid_x, grid_y)
    return grid_x * GRID_SIZE, grid_y * GRID_SIZE
end
```

**Pixel to Grid:**
```lua
function pixel_to_grid(pixel_x, pixel_y)
    return math.floor(pixel_x / GRID_SIZE), math.floor(pixel_y / GRID_SIZE)
end
```

**Snap to Grid:**
```lua
function snap_to_grid(pixel_x, pixel_y)
    local grid_x = math.floor(pixel_x / GRID_SIZE)
    local grid_y = math.floor(pixel_y / GRID_SIZE)
    return grid_x * GRID_SIZE, grid_y * GRID_SIZE
end
```

**Center in Cell:**
```lua
function center_in_grid(grid_x, grid_y, sprite_width, sprite_height)
    local pixel_x = grid_x * GRID_SIZE + (GRID_SIZE - sprite_width) / 2
    local pixel_y = grid_y * GRID_SIZE + (GRID_SIZE - sprite_height) / 2
    return pixel_x, pixel_y
end
```

### Collision Detection

**Point in Grid Cell:**
```lua
function point_in_cell(point_x, point_y, cell_grid_x, cell_grid_y)
    local cell_pixel_x = cell_grid_x * GRID_SIZE
    local cell_pixel_y = cell_grid_y * GRID_SIZE
    return point_x >= cell_pixel_x and point_x < cell_pixel_x + GRID_SIZE and
           point_y >= cell_pixel_y and point_y < cell_pixel_y + GRID_SIZE
end
```

**Rectangle Overlap:**
```lua
function grid_rect_overlap(x1, y1, w1, h1, x2, y2, w2, h2)
    -- All coordinates in grid units
    return x1 < x2 + w2 and x2 < x1 + w1 and
           y1 < y2 + h2 and y2 < y1 + h1
end
```

---

## Design Constraints

### What Must Align to Grid

**✓ Always Grid-Aligned:**
- UI buttons and panels
- Menu items and lists
- Window positions and sizes
- Icon grid layouts
- Battlefield tiles
- Unit positions (resting state)
- Building footprints

**✗ Exceptions (Sub-Pixel Allowed):**
- Animation intermediate frames
- Smooth scrolling transitions
- Particle effects
- Mouse cursor
- Text rendering (if font doesn't fit grid)

### Common Grid Sizes

**UI Elements:**
```
Button:       4×2 grid (80×40px)
Icon:         1×1 grid (20×20px)
Large Icon:   2×2 grid (40×40px)
Panel:        10×8 grid (200×160px)
Full Screen:  40×30 grid (800×600px)
```

**Battlescape:**
```
Tile:         1×1 grid (20×20px)
Unit:         1×1 grid (20×20px)
Large Unit:   2×2 grid (40×40px)
Viewport:     32×24 grid (640×480px)
```

---

## Visual Guidelines

### Pixel Art Best Practices

**Sprite Creation:**
1. Create at 10×10 native resolution
2. Use solid colors (no gradients)
3. Limit palette (8-16 colors per sprite)
4. Avoid anti-aliasing edges
5. Test at 2× scale (20×20 display size)

**UI Creation:**
1. Design at 800×600 resolution
2. Use grid overlay during design
3. Align all elements to grid
4. Use consistent spacing (multiples of 20)
5. Test at multiple window sizes

### Color Palette

**Grid Debug Colors:**
```lua
grid_line_color = {0.2, 0.2, 0.2, 0.5}  -- Dark gray, semi-transparent
grid_unit_highlight = {1, 1, 0, 0.3}     -- Yellow, translucent
grid_cell_hover = {0, 1, 0, 0.2}         -- Green, translucent
```

---

## Debugging Tools

### Grid Overlay

**Debug Rendering:**
```lua
function draw_grid_overlay()
    love.graphics.setColor(0.2, 0.2, 0.2, 0.5)
    
    -- Vertical lines
    for x = 0, 800, GRID_SIZE do
        love.graphics.line(x, 0, x, 600)
    end
    
    -- Horizontal lines
    for y = 0, 600, GRID_SIZE do
        love.graphics.line(0, y, 800, y)
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end
```

**Grid Coordinates Display:**
```lua
function draw_grid_coords()
    local mouse_x, mouse_y = get_internal_mouse_position()
    local grid_x, grid_y = pixel_to_grid(mouse_x, mouse_y)
    
    love.graphics.print(string.format("Grid: (%d, %d)", grid_x, grid_y), 10, 10)
    love.graphics.print(string.format("Pixel: (%d, %d)", mouse_x, mouse_y), 10, 30)
end
```

### Alignment Validation

**Check Grid Alignment:**
```lua
function is_grid_aligned(pixel_value)
    return pixel_value % GRID_SIZE == 0
end

function validate_widget_position(widget)
    if not is_grid_aligned(widget.x) or not is_grid_aligned(widget.y) then
        error(string.format("Widget at (%d, %d) is not grid-aligned!", widget.x, widget.y))
    end
end
```

---

## Implementation Checklist

**For Every New UI Element:**
- [ ] Position is multiple of GRID_SIZE (20px)
- [ ] Width is multiple of GRID_SIZE (20px)
- [ ] Height is multiple of GRID_SIZE (20px)
- [ ] Tested at 800×600 internal resolution
- [ ] Tested at multiple window sizes
- [ ] Tested at fullscreen
- [ ] No sub-pixel positioning (unless animating)
- [ ] Sprites use nearest-neighbor filtering

**For Every New Sprite:**
- [ ] Created at 10×10 native resolution
- [ ] Scaled 2× for display (20×20)
- [ ] No anti-aliasing on edges
- [ ] Fits within grid cell boundaries
- [ ] Tested against various backgrounds

---

## Love2D Configuration

**conf.lua Settings:**
```lua
function love.conf(t)
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = true
    t.window.msaa = 0  -- No anti-aliasing
    t.window.minwidth = 800
    t.window.minheight = 600
end
```

**main.lua Initialization:**
```lua
function love.load()
    -- Set default filter to nearest-neighbor
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- Create internal canvas
    canvas = love.graphics.newCanvas(800, 600)
    canvas:setFilter("nearest", "nearest")
    
    -- Define grid constant
    GRID_SIZE = 20
end
```

---

## Examples

### Widget Positioning
A button widget positioned at grid coordinates (5, 3) renders at screen position (100, 60) pixels. Width of 6 grid units = 120 pixels. Height of 2 grid units = 40 pixels. The button snaps perfectly to grid boundaries, ensuring pixel-perfect alignment with surrounding UI elements.

### Sprite Scaling
A soldier sprite created at 10×10 pixel native resolution scales 2× to 20×20 pixels for display. Nearest-neighbor filtering maintains crisp pixel art edges. The sprite occupies exactly one grid cell, aligning perfectly with tactical grid tiles.

### Multi-Cell UI Element
A facility preview widget spans 4×3 grid units (80×60 pixels). Top-left corner positions at grid (10, 8) = screen (200, 160). The preview represents a facility that will occupy 4×3 tiles in the base grid, with perfect 1:1 visual correspondence.

### Battlescape Tile Rendering
A 20×30 tile battlescape map occupies 400×600 pixels (20×30 grid units). Each tile renders at exact 20×20 pixels. Fog of war overlays align to tile boundaries. Unit positions snap to grid centers for clarity.

### Window Scaling
Game window resizes from 800×600 to 1600×1200. Internal canvas remains 800×600. Scaling factor = 2.0×. Grid positions remain unchanged in logical space. Rendering scales up using nearest-neighbor to maintain pixel art aesthetic.

### Sub-Grid Animation
A unit moves from tile (5, 3) to (6, 3). Start position: 100 pixels. End position: 120 pixels. Animation interpolates through 101, 102...119 pixels over 20 frames. Final position snaps to 120 pixels (grid-aligned) when animation completes.

## Related Wiki Pages

- [GUI System](../GUI/README.md) - UI component architecture
- [Widgets](../widgets/README.md) - Reusable UI widget library
- [Battlescape](../battlescape/README.md) - Tactical grid rendering
- [Love2D UI Design System](../love2d_ui_design_system.md) - Comprehensive UI specifications

## References to Existing Games and Mechanics

- **Celeste**: Pixel-perfect platformer with strict grid alignment
- **Stardew Valley**: 16×16 grid system for farming and building
- **Into the Breach**: 8×8 tactical grid with clear visual feedback
- **FTL**: Fixed resolution UI with scalable display
- **Dead Cells**: Pixel art with nearest-neighbor scaling
- **Terraria**: 16×16 tile grid with 2× sprite scaling
- **Shovel Knight**: NES-era pixel art grid discipline
- **Undertale**: 640×480 fixed resolution with character scaling
- **Hyper Light Drifter**: Strict pixel art grid for environments
- **CrossCode**: HD pixel art with grid-based level design
