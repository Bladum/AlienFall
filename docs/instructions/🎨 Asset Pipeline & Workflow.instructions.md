# 🎨 Asset Pipeline & Workflow Best Practices

**Domain:** Asset Management & Production  
**Focus:** Sprite creation, optimization, batching, version control, asset naming  
**Version:** 1.0  
**Date:** October 2025

## Overview

This guide covers managing game assets efficiently, from creation through optimization and integration.

## Asset Organization

### ✅ DO: Organize Assets by Type and Purpose

```
assets/
├── sprites/
│   ├── units/
│   │   ├── soldier.png
│   │   ├── sniper.png
│   │   └── medic.png
│   ├── enemies/
│   │   ├── alien_grunt.png
│   │   └── alien_sniper.png
│   ├── ui/
│   │   ├── button_idle.png
│   │   ├── button_hover.png
│   │   └── button_pressed.png
│   └── terrain/
│       ├── grass.png
│       ├── concrete.png
│       └── water.png
├── tilesets/
│   ├── base_tileset.tsx
│   └── combat_tileset.tsx
├── fonts/
│   ├── ui_regular.ttf
│   └── ui_bold.ttf
└── config/
    ├── units.json
    ├── weapons.json
    └── difficulty.json
```

---

### ✅ DO: Use Consistent Naming Conventions

```lua
-- Sprite naming: [category]_[description]_[state].png
-- Examples:
-- unit_soldier_idle.png
-- unit_soldier_moving.png
-- unit_soldier_attacking.png
-- enemy_alien_idle.png
-- ui_button_hover.png

function loadSprite(category, name, state)
    local filename = string.format("assets/sprites/%s/%s_%s.png", category, name, state)
    return love.graphics.newImage(filename)
end

-- Usage
local soldierIdle = loadSprite("units", "soldier", "idle")
local alienAttack = loadSprite("enemies", "alien", "attacking")
```

---

## Asset Optimization

### ✅ DO: Optimize Sprite Sheet Layout

```lua
-- Pack sprites efficiently into atlases
SPRITE_ATLAS = {
    unit_sprites = {
        image = "assets/spritesheet_units.png",
        quads = {
            soldier_idle = love.graphics.newQuad(0, 0, 32, 32, 256, 256),
            soldier_move = love.graphics.newQuad(32, 0, 32, 32, 256, 256),
            sniper_idle = love.graphics.newQuad(64, 0, 32, 32, 256, 256)
        }
    }
}

function drawSpriteFromAtlas(atlasName, spriteName, x, y)
    local atlas = SPRITE_ATLAS[atlasName]
    local quad = atlas.quads[spriteName]
    
    if quad and atlas.image then
        love.graphics.draw(atlas.image, quad, x, y)
    end
end

-- Usage
drawSpriteFromAtlas("unit_sprites", "soldier_idle", 100, 100)
```

---

### ✅ DO: Implement Asset Caching

```lua
ASSET_CACHE = {}

function cacheAsset(name, asset)
    ASSET_CACHE[name] = asset
    print("[CACHE] Asset cached: " .. name)
end

function getAsset(name, loader)
    if ASSET_CACHE[name] then
        return ASSET_CACHE[name]
    end
    
    local asset = loader(name)
    cacheAsset(name, asset)
    return asset
end

-- Usage
function loadUnitSprite(unitType)
    return getAsset("sprite_" .. unitType, function(name)
        return love.graphics.newImage("assets/units/" .. unitType .. ".png")
    end)
end

-- First call loads and caches
local sprite1 = loadUnitSprite("soldier")
-- Second call uses cache
local sprite2 = loadUnitSprite("soldier")
```

---

## Asset Import & Export

### ✅ DO: Support Multiple Asset Sources

```lua
-- Handle Aseprite exports
function loadAsepriteAnimation(filename)
    local imageFile = filename .. ".png"
    local dataFile = filename .. ".json"
    
    local image = love.graphics.newImage(imageFile)
    local data = loadJSON(dataFile)
    
    local frames = {}
    for _, frameData in ipairs(data.frames) do
        table.insert(frames, {
            quad = love.graphics.newQuad(
                frameData.frame.x,
                frameData.frame.y,
                frameData.frame.w,
                frameData.frame.h,
                image:getDimensions()
            ),
            duration = frameData.duration / 1000  -- Convert to seconds
        })
    end
    
    return {image = image, frames = frames}
end

-- Handle Tiled map exports
function loadTiledMap(filename)
    local data = loadJSON(filename)
    
    local map = {
        width = data.width,
        height = data.height,
        tileWidth = data.tilewidth,
        tileHeight = data.tileheight,
        layers = {}
    }
    
    for _, layer in ipairs(data.layers) do
        table.insert(map.layers, {
            name = layer.name,
            data = layer.data,
            visible = layer.visible
        })
    end
    
    return map
end
```

---

## Practical Implementation

### ✅ DO: Version Asset Files

```lua
function saveAssetManifest()
    local manifest = {
        version = "1.0.0",
        created = os.date("%Y-%m-%d %H:%M:%S"),
        assets = {}
    }
    
    -- Scan all asset directories
    local assetDirs = {"sprites", "tilesets", "fonts"}
    
    for _, dir in ipairs(assetDirs) do
        for file in love.filesystem.getDirectoryItems("assets/" .. dir) do
            local path = "assets/" .. dir .. "/" .. file
            manifest.assets[path] = {
                size = love.filesystem.getInfo(path).size,
                modified = love.filesystem.getInfo(path).modtime
            }
        end
    end
    
    love.filesystem.write("assets/manifest.json", jsonEncode(manifest))
end
```

---

### ✅ DO: Batch Sprite Loading

```lua
function preloadAllAssets()
    local categories = {"units", "enemies", "ui", "terrain"}
    
    for _, category in ipairs(categories) do
        print("[PRELOAD] Loading " .. category .. " assets...")
        
        for file in love.filesystem.getDirectoryItems("assets/sprites/" .. category) do
            if file:endsWith(".png") then
                local assetName = category .. "_" .. file:sub(1, -5)
                local asset = love.graphics.newImage("assets/sprites/" .. category .. "/" .. file)
                cacheAsset(assetName, asset)
            end
        end
    end
    
    print("[PRELOAD] All assets loaded")
end

function love.load()
    preloadAllAssets()
end
```

---

### ✅ DO: Create Asset Builder Script

```bash
@echo off
REM build_assets.bat - Optimize and prepare assets for release

setlocal enabledelayedexpansion

echo [ASSETS] Building asset packages...

REM Compress sprites
call:compressSprites "assets/sprites" "build/sprites"

REM Generate sprite atlases (if tool available)
if exist "tools/atlas_builder.exe" (
    call tools/atlas_builder.exe --input assets/sprites --output build/atlases
)

REM Generate manifest
lua.exe -e "require('scripts/generate_manifest')"

echo [ASSETS] Build complete

:compressSprites
setlocal
set input=%~1
set output=%~2

if not exist "%output%" mkdir "%output%"

REM Use ImageMagick or similar to compress
for /r "%input%" %%F in (*.png) do (
    echo Compressing %%F...
)

endlocal
goto:eof
```

---

### ❌ DON'T: Load Assets on Demand During Gameplay

```lua
-- BAD: Causes frame drops during gameplay
function drawEnemyBad(enemy)
    if not enemy.sprite then
        -- Loading image during gameplay!
        enemy.sprite = love.graphics.newImage("assets/enemies/" .. enemy.type .. ".png")
    end
    love.graphics.draw(enemy.sprite, enemy.x, enemy.y)
end

-- GOOD: Preload all assets upfront
function drawEnemyGood(enemy)
    love.graphics.draw(getAsset("enemy_" .. enemy.type), enemy.x, enemy.y)
end
```

---

### ❌ DON'T: Mix Asset Formats Without Validation

```lua
-- BAD: Assume file exists
function loadAssetBad(filename)
    return love.graphics.newImage(filename)
end

-- GOOD: Validate before loading
function loadAssetGood(filename)
    if not love.filesystem.getInfo(filename) then
        print("[ERROR] Asset not found: " .. filename)
        return getDefaultAsset()
    end
    
    local success, asset = pcall(love.graphics.newImage, filename)
    if not success then
        print("[ERROR] Failed to load: " .. filename)
        return getDefaultAsset()
    end
    
    return asset
end
```

---

## Common Patterns & Checklist

- [x] Organize assets by type and purpose
- [x] Use consistent naming conventions
- [x] Pack sprites into atlases
- [x] Implement asset caching
- [x] Support multiple export formats
- [x] Version asset files
- [x] Preload critical assets
- [x] Create asset build scripts
- [x] Validate assets on load
- [x] Document asset requirements

---

## References

- Aseprite: https://www.aseprite.org/
- Tiled Map Editor: https://www.mapeditor.org/
- TexturePacker: https://www.codeandweb.com/texturepacker

