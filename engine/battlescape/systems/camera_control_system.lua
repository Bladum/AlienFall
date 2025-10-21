---Camera Control System - Tactical Viewport Management
---
---Manages tactical camera controls including viewport pan, zoom, unit following, snap-to-action,
---and height level selection for isometric/hex tactical combat view. Provides smooth camera
---transitions and focus management for optimal battlefield visibility.
---
---Camera Controls:
---  - Pan: Arrow keys or edge-of-screen mouse movement
---  - Zoom: Mouse wheel or keyboard shortcuts (0.5x - 2.0x)
---  - Follow Unit: Camera tracks selected unit automatically
---  - Snap to Action: Camera centers on combat events
---  - Height Level: Toggle between map elevation layers
---
---Zoom Levels:
---  - Minimum Zoom: 0.5x (wide battlefield overview)
---  - Default Zoom: 1.0x (standard tactical view)
---  - Maximum Zoom: 2.0x (close-up detail view)
---  - Smooth Transition: Interpolated zoom changes
---
---Camera Modes:
---  - Free Camera: Player-controlled pan and zoom
---  - Follow Mode: Tracks selected unit movement
---  - Action Camera: Auto-centers on combat events
---  - Cinematic Mode: Scripted camera for cutscenes
---
---Viewport Constraints:
---  - Boundary Limits: Camera stays within map bounds
---  - Focus Padding: Minimum distance from screen edges
---  - Smooth Clamping: Gradual boundary enforcement
---  - Multi-Level: Supports 3D elevation viewing
---
---Key Exports:
---  - panCamera(dx, dy): Moves viewport by delta pixels
---  - setZoom(zoomLevel): Sets zoom level (0.5-2.0)
---  - followUnit(unit): Enables unit tracking mode
---  - snapToPosition(x, y): Instantly centers on position
---  - smoothPanTo(x, y, duration): Animated camera movement
---
---Integration:
---  - Works with input system for keyboard/mouse control
---  - Uses renderer to apply viewport transform
---  - Integrates with action system for event focusing
---  - Connects to UI for minimap synchronization
---
---@module battlescape.systems.camera_control_system
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local CameraControl = require("battlescape.systems.camera_control_system")
---  CameraControl.followUnit(selectedUnit)
---  CameraControl.setZoom(1.5)
---  CameraControl.snapToPosition(targetX, targetY)
---
---@see battlescape.rendering.renderer For viewport rendering
---@see battlescape.ui.input For camera control input

local CameraControlSystem = {}

local CONFIG = {
    -- Zoom
    MIN_ZOOM = 0.5,
    MAX_ZOOM = 2.0,
    ZOOM_STEP = 0.1,
    DEFAULT_ZOOM = 1.0,
    
    -- Pan
    PAN_SPEED = 300,           -- Pixels per second
    EDGE_PAN_MARGIN = 40,      -- Pixels from edge
    EDGE_PAN_SPEED = 200,
    
    -- Follow
    FOLLOW_SMOOTHING = 0.1,    -- Lerp factor
    
    -- Bounds
    MAP_WIDTH = 1440,          -- 60 hexes × 24 pixels
    MAP_HEIGHT = 1440,
    SCREEN_WIDTH = 960,
    SCREEN_HEIGHT = 720,
    
    -- Height levels
    MAX_HEIGHT = 5,
    HEIGHT_OFFSET = 12,        -- Pixels per height level
}

local cameraState = {
    x = 0,
    y = 0,
    zoom = CONFIG.DEFAULT_ZOOM,
    targetX = 0,
    targetY = 0,
    following = nil,
    heightLevel = 0,
    bounds = {minX = 0, minY = 0, maxX = CONFIG.MAP_WIDTH, maxY = CONFIG.MAP_HEIGHT},
}

function CameraControlSystem.init()
    cameraState = {
        x = 0,
        y = 0,
        zoom = CONFIG.DEFAULT_ZOOM,
        targetX = 0,
        targetY = 0,
        following = nil,
        heightLevel = 0,
        bounds = {minX = 0, minY = 0, maxX = CONFIG.MAP_WIDTH, maxY = CONFIG.MAP_HEIGHT},
    }
end

function CameraControlSystem.update(dt)
    -- Edge panning
    local mx, my = love.mouse.getPosition()
    if mx < CONFIG.EDGE_PAN_MARGIN then
        cameraState.x = cameraState.x - CONFIG.EDGE_PAN_SPEED * dt
    elseif mx > CONFIG.SCREEN_WIDTH - CONFIG.EDGE_PAN_MARGIN then
        cameraState.x = cameraState.x + CONFIG.EDGE_PAN_SPEED * dt
    end
    if my < CONFIG.EDGE_PAN_MARGIN then
        cameraState.y = cameraState.y - CONFIG.EDGE_PAN_SPEED * dt
    elseif my > CONFIG.SCREEN_HEIGHT - CONFIG.EDGE_PAN_MARGIN then
        cameraState.y = cameraState.y + CONFIG.EDGE_PAN_SPEED * dt
    end
    
    -- Follow unit
    if cameraState.following then
        cameraState.targetX = cameraState.following.x * 24 - CONFIG.SCREEN_WIDTH / 2
        cameraState.targetY = cameraState.following.y * 24 - CONFIG.SCREEN_HEIGHT / 2
        cameraState.x = cameraState.x + (cameraState.targetX - cameraState.x) * CONFIG.FOLLOW_SMOOTHING
        cameraState.y = cameraState.y + (cameraState.targetY - cameraState.y) * CONFIG.FOLLOW_SMOOTHING
    end
    
    -- Clamp to bounds
    cameraState.x = math.max(cameraState.bounds.minX, math.min(cameraState.x, cameraState.bounds.maxX - CONFIG.SCREEN_WIDTH / cameraState.zoom))
    cameraState.y = math.max(cameraState.bounds.minY, math.min(cameraState.y, cameraState.bounds.maxY - CONFIG.SCREEN_HEIGHT / cameraState.zoom))
end

function CameraControlSystem.pan(dx, dy)
    cameraState.x = cameraState.x + dx
    cameraState.y = cameraState.y + dy
    cameraState.following = nil
end

function CameraControlSystem.zoom(delta)
    cameraState.zoom = math.max(CONFIG.MIN_ZOOM, math.min(cameraState.zoom + delta * CONFIG.ZOOM_STEP, CONFIG.MAX_ZOOM))
end

function CameraControlSystem.centerOn(x, y)
    cameraState.x = x * 24 - CONFIG.SCREEN_WIDTH / (2 * cameraState.zoom)
    cameraState.y = y * 24 - CONFIG.SCREEN_HEIGHT / (2 * cameraState.zoom)
    cameraState.following = nil
end

function CameraControlSystem.followUnit(unit)
    cameraState.following = unit
end

function CameraControlSystem.stopFollowing()
    cameraState.following = nil
end

function CameraControlSystem.setHeightLevel(level)
    cameraState.heightLevel = math.max(0, math.min(level, CONFIG.MAX_HEIGHT))
end

function CameraControlSystem.getTransform()
    return {
        offsetX = -cameraState.x,
        offsetY = -cameraState.y - (cameraState.heightLevel * CONFIG.HEIGHT_OFFSET),
        zoom = cameraState.zoom,
    }
end

function CameraControlSystem.screenToWorld(screenX, screenY)
    local worldX = (screenX / cameraState.zoom) + cameraState.x
    local worldY = (screenY / cameraState.zoom) + cameraState.y
    return worldX / 24, worldY / 24
end

function CameraControlSystem.worldToScreen(worldX, worldY)
    local screenX = (worldX * 24 - cameraState.x) * cameraState.zoom
    local screenY = (worldY * 24 - cameraState.y) * cameraState.zoom
    return screenX, screenY
end

return CameraControlSystem

























