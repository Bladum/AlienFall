# Assets

Game assets and media files.

## Overview

The assets directory contains all visual, audio, and font resources used by the game.

## Directory Structure

### fonts/
Font files for text rendering (currently empty - fonts loaded from system).

### images/
Image files for sprites, backgrounds, and UI elements (currently empty).

### sounds/
Audio files for sound effects and music (currently empty).

## Asset Loading

Assets are managed by the assets system:

```lua
local Assets = require("systems.assets")

-- Load an image
local image = Assets:getImage("path/to/image.png")

-- Load a font
local font = Assets:getFont("fontName", size)

-- Load a sound
local sound = Assets:getSound("path/to/sound.wav")
```

## Asset Types

- **Images**: PNG, JPG for sprites and backgrounds
- **Fonts**: TTF, OTF for text rendering
- **Audio**: WAV, OGG for sound effects and music

## Performance

- **Caching**: Assets are cached after first load
- **Pooling**: Frequently used assets remain in memory
- **Streaming**: Large assets loaded on demand

## Dependencies

- **Love2D**: Graphics, audio, and filesystem APIs
- **Asset System**: Centralized asset management
- **Resource Paths**: Relative paths from assets/ directory