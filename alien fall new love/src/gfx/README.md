# GFX Directory - Graphics and Rendering System

## Overview

The `gfx/` directory contains the graphics rendering system for Alien Fall. This includes sprite management, animation systems, UI rendering, and graphics utilities. The graphics system is designed for pixel-perfect rendering with a fixed 800x600 resolution and 20x20 pixel grid system.

## Directory Structure

### `gui/`

UI-specific graphics and rendering:

#### `basescape/`

Base management interface graphics:

- Facility icons and sprites
- UI panels and backgrounds
- Status indicators
- Progress bars

**GROK**: Base UI graphics - visual elements for base management screens

#### `battlescape/`

Tactical combat graphics:

- Unit sprites and animations
- Terrain tiles
- Combat effects
- UI overlays

**GROK**: Battle graphics - tactical combat visual elements

#### `geoscape/`

Strategic world view graphics:

- World map tiles
- Craft sprites
- Mission markers
- Strategic overlays

**GROK**: World map graphics - strategic view visual elements

#### `interception/`

Aircraft interception graphics:

- UFO sprites
- Craft sprites
- Interception effects
- Radar displays

**GROK**: Interception graphics - UFO interception visual elements

#### `organization/`

Organization management graphics:

- Personnel icons
- Craft icons
- Facility icons
- Status displays

**GROK**: Organization graphics - management interface visual elements

#### `lore/`

Story and information graphics:

- Portrait images
- Historical images
- Cutscene backgrounds
- Text formatting

**GROK**: Lore graphics - story and information visual elements

### Icon System

#### Game Icons (`icon_*.png`)

24x24 pixel UI navigation icons:

- `icon_geoscape.png` - World map navigation
- `icon_base.png` - Base management navigation
- `icon_research.png` - Research screen navigation
- `icon_manufacture.png` - Manufacturing screen navigation
- `icon_purchase.png` - Purchase screen navigation
- `icon_sell.png` - Sell screen navigation
- `icon_hire.png` - Personnel hiring navigation
- `icon_transfer.png` - Transfer screen navigation
- `icon_options.png` - Settings navigation
- `icon_stats.png` - Statistics navigation

**GROK**: Navigation icons - 24x24 pixel UI navigation elements

## Graphics Architecture

### Rendering Pipeline

Graphics system uses layered rendering:

```lua
function GraphicsSystem:render()
    -- Background layer
    self:renderBackground()

    -- World/entities layer
    self:renderWorld()

    -- UI layer
    self:renderUI()

    -- Overlay layer (tooltips, etc.)
    self:renderOverlays()
end
```

### Sprite Management

Sprites are managed through sprite sheets:

```lua
SpriteSheet = class()

function SpriteSheet:init(image, frameWidth, frameHeight)
    self.image = image
    self.frameWidth = frameWidth
    self.frameHeight = frameHeight
    self.framesPerRow = math.floor(image:getWidth() / frameWidth)
    self.totalFrames = self.framesPerRow * math.floor(image:getHeight() / frameHeight)
end

function SpriteSheet:getQuad(frameIndex)
    local row = math.floor((frameIndex - 1) / self.framesPerRow)
    local col = (frameIndex - 1) % self.framesPerRow
    return love.graphics.newQuad(
        col * self.frameWidth, row * self.frameHeight,
        self.frameWidth, self.frameHeight,
        self.image:getWidth(), self.image:getHeight()
    )
end
```

### Animation System

Animations are frame-based sequences:

```lua
Animation = class()

function Animation:init(spriteSheet, frames, frameDuration)
    self.spriteSheet = spriteSheet
    self.frames = frames
    self.frameDuration = frameDuration
    self.currentFrame = 1
    self.timer = 0
    self.looping = true
end

function Animation:update(dt)
    self.timer = self.timer + dt
    if self.timer >= self.frameDuration then
        self.timer = self.timer - self.frameDuration
        self.currentFrame = self.currentFrame + 1
        if self.currentFrame > #self.frames then
            if self.looping then
                self.currentFrame = 1
            else
                self.currentFrame = #self.frames
            end
        end
    end
end

function Animation:draw(x, y)
    local quad = self.spriteSheet:getQuad(self.frames[self.currentFrame])
    love.graphics.draw(self.spriteSheet.image, quad, x, y)
end
```

## Pixel-Perfect Rendering

### Grid System

All graphics align to 20x20 pixel grid:

```lua
local GRID_SIZE = 20

function drawGridAligned(x, y, sprite)
    local gridX = math.floor(x / GRID_SIZE) * GRID_SIZE
    local gridY = math.floor(y / GRID_SIZE) * GRID_SIZE
    love.graphics.draw(sprite, gridX, gridY)
end
```

### Resolution Management

Fixed 800x600 internal resolution:

```lua
local INTERNAL_WIDTH = 800
local INTERNAL_HEIGHT = 600

function love.conf(t)
    t.window.width = INTERNAL_WIDTH
    t.window.height = INTERNAL_HEIGHT
    t.window.resizable = true
    t.window.vsync = true
end

function love.draw()
    -- Set up coordinate system
    love.graphics.scale(love.graphics.getWidth() / INTERNAL_WIDTH,
                       love.graphics.getHeight() / INTERNAL_HEIGHT)

    -- Render at internal resolution
    -- All coordinates are in 800x600 space
end
```

## Asset Management

### Resource Loading

Graphics assets are loaded and cached:

```lua
AssetManager = class()

function AssetManager:init()
    self.images = {}
    self.fonts = {}
    self.sounds = {}
end

function AssetManager:loadImage(path)
    if not self.images[path] then
        self.images[path] = love.graphics.newImage(path)
    end
    return self.images[path]
end

function AssetManager:loadFont(path, size)
    local key = path .. "_" .. size
    if not self.fonts[key] then
        self.fonts[key] = love.graphics.newFont(path, size)
    end
    return self.fonts[key]
end
```

### Texture Filtering

Pixel-perfect rendering with nearest-neighbor filtering:

```lua
function love.conf(t)
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = true
    t.window.vsync = true
end

function love.load()
    -- Set nearest-neighbor filtering for pixel art
    love.graphics.setDefaultFilter("nearest", "nearest")
end
```

## UI Rendering

### Widget Rendering

UI widgets handle their own rendering:

```lua
function Button:draw()
    -- Draw button background
    love.graphics.setColor(self:getBackgroundColor())
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Draw button border
    love.graphics.setColor(self:getBorderColor())
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    -- Draw button text
    love.graphics.setColor(self:getTextColor())
    love.graphics.printf(self.text, self.x, self.y + self.height/2 - self.font:getHeight()/2,
                        self.width, "center")
end
```

### Layout System

Grid-based UI layout:

```lua
function UIManager:layoutGrid()
    local cols = 40  -- 800 / 20
    local rows = 30  -- 600 / 20

    for i, widget in ipairs(self.widgets) do
        local col = (i - 1) % cols
        local row = math.floor((i - 1) / cols)
        widget:setGridPosition(col, row)
    end
end
```

## Performance Optimization

### Batch Rendering

Group similar draw calls:

```lua
function GraphicsSystem:renderSprites()
    -- Batch sprite rendering
    love.graphics.setColor(1, 1, 1)
    for _, sprite in ipairs(self.sprites) do
        love.graphics.draw(sprite.image, sprite.x, sprite.y)
    end
end
```

### Texture Atlasing

Combine small textures into atlases:

```lua
function createTextureAtlas(sources)
    local atlas = love.graphics.newCanvas(ATLAS_SIZE, ATLAS_SIZE)
    love.graphics.setCanvas(atlas)

    local positions = {}
    for i, source in ipairs(sources) do
        local x = (i - 1) % ATLAS_COLS * TILE_SIZE
        local y = math.floor((i - 1) / ATLAS_COLS) * TILE_SIZE
        love.graphics.draw(source, x, y)
        positions[source] = {x, y}
    end

    love.graphics.setCanvas()
    return atlas, positions
end
```

## Testing Strategy

### Graphics Testing

Graphics system tested for:

- Rendering correctness
- Performance benchmarks
- Memory usage
- Compatibility across resolutions

### Asset Testing

Asset loading tested for:

- File format support
- Error handling
- Memory management
- Loading performance

## Development Guidelines

### Creating Graphics Assets

1. **GROK**: Use 20x20 pixel grid for all UI elements
2. **GROK**: Design for 800x600 fixed resolution
3. **GROK**: Use pixel art style consistently
4. **GROK**: Create sprite sheets for animations
5. **GROK**: Optimize texture sizes
6. **GROK**: Test at multiple scales

### Graphics Programming

- **GROK**: Use grid-based positioning for UI
- **GROK**: Implement batch rendering for performance
- **GROK**: Cache loaded assets
- **GROK**: Handle resolution scaling properly
- **GROK**: Profile rendering performance

### Asset Organization

- **GROK**: Group related assets in subdirectories
- **GROK**: Use consistent naming conventions
- **GROK**: Document asset specifications
- **GROK**: Version control large asset files
- **GROK**: Optimize for file size
- `icon_turn.png` - Refresh/forward icon (Turn button)
  - Alternative search: "refresh icon" or "turn icon"

- `icon_menu.png` - Menu/hamburger icon (Menu button)
  - Alternative search: "menu icon" or "hamburger icon"

## Icon Requirements

- **Size**: 24x24 pixels
- **Format**: PNG with transparency support
- **Style**: Consistent pixel art style to match the game
- **Color**: Should work well on dark button backgrounds

## Recommended Sources

1. **Flaticon**: Free icons with many XCOM-style options
2. **Game-icons.net**: Free game-appropriate icons
3. **OpenGameArt**: Free game assets
4. **IconFinder**: Various free/paid icon options

## Implementation Notes

Icons are loaded by the Button widget and scaled to fit appropriately above the button text. The current implementation supports 24x24 pixel icons that are scaled down if needed to fit the button layout.
