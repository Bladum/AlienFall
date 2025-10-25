---Debug - ECS Battle System Debug Utilities
---
---Debug flags, logging, and visualization tools for ECS battle system development.
---Provides performance tracking, debug overlays, hex grid visualization, and
---verbose logging. Essential for development and troubleshooting.
---
---Features:
---  - Debug flag toggles (grid, FOW, vision, paths)
---  - Performance profiling
---  - Verbose logging
---  - Visual overlays (hex grid, vision cones)
---  - Frame timing analysis
---  - Memory tracking
---
---Debug Flags:
---  - enabled: Master debug toggle
---  - showHexGrid: Hex grid overlay
---  - showFOW: Fog of war visualization
---  - showVisionCones: Unit vision arcs
---  - showPaths: Pathfinding visualization
---  - logVerbose: Detailed console output
---
---Performance Tracking:
---  - Frame time (ms)
---  - System execution time
---  - Entity count
---  - Component updates
---
---Key Exports:
---  - Debug.enabled: Master toggle
---  - Debug.log(msg): Conditional logging
---  - Debug.startTimer(name): Begins profiling
---  - Debug.endTimer(name): Ends profiling and logs
---  - Debug.drawGrid(hexSystem): Renders hex grid
---
---Dependencies:
---  - None (standalone utilities)
---
---@module battlescape.battle_ecs.debug
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  local Debug = require("battlescape.battle_ecs.debug")
---  Debug.enabled = true
---  Debug.log("[MovementSystem] Unit moved to " .. x .. "," .. y)
---
---@see battlescape.battle_ecs.init For usage

-- debug.lua
-- Debug utilities for battle system
-- Part of ECS architecture

local Debug = {}

-- Debug flags
Debug.enabled = false
Debug.showHexGrid = false
Debug.showFOW = true
Debug.showVisionCones = false
Debug.showPaths = false
Debug.logVerbose = false

-- Performance tracking
Debug.frameTime = 0
Debug.updateTime = 0
Debug.drawTime = 0
Debug.lastFPS = 0

-- Print with module prefix
function Debug.print(module, message)
    if Debug.enabled then
        print("[" .. module .. "] " .. tostring(message))
    end
end

-- Log error with stack trace
function Debug.error(module, message)
    print("[ERROR:" .. module .. "] " .. tostring(message))
    print(debug.traceback())
end

-- Log warning
function Debug.warn(module, message)
    if Debug.enabled then
        print("[WARN:" .. module .. "] " .. tostring(message))
    end
end

-- Verbose logging (only if enabled)
function Debug.log(module, message)
    if Debug.logVerbose then
        print("[LOG:" .. module .. "] " .. tostring(message))
    end
end

-- Draw debug text on screen
function Debug.drawText(text, x, y, color)
    if not Debug.enabled then return end
    
    love.graphics.push()
    love.graphics.origin()
    
    if color then
        love.graphics.setColor(color.r/255, color.g/255, color.b/255, 1)
    else
        love.graphics.setColor(1, 1, 0, 1)  -- Yellow default
    end
    
    love.graphics.print(text, x, y)
    love.graphics.pop()
end

-- Draw debug rectangle
function Debug.drawRect(mode, x, y, width, height, color)
    if not Debug.enabled then return end
    
    love.graphics.push()
    if color then
        love.graphics.setColor(color.r/255, color.g/255, color.b/255, 0.5)
    else
        love.graphics.setColor(1, 0, 0, 0.5)  -- Red default
    end
    
    love.graphics.rectangle(mode, x, y, width, height)
    love.graphics.pop()
end

-- Draw debug line
function Debug.drawLine(x1, y1, x2, y2, color)
    if not Debug.enabled then return end
    
    love.graphics.push()
    if color then
        love.graphics.setColor(color.r/255, color.g/255, color.b/255, 1)
    else
        love.graphics.setColor(0, 1, 0, 1)  -- Green default
    end
    
    love.graphics.line(x1, y1, x2, y2)
    love.graphics.pop()
end

-- Draw debug circle
function Debug.drawCircle(mode, x, y, radius, color)
    if not Debug.enabled then return end
    
    love.graphics.push()
    if color then
        love.graphics.setColor(color.r/255, color.g/255, color.b/255, 0.5)
    else
        love.graphics.setColor(0, 0, 1, 0.5)  -- Blue default
    end
    
    love.graphics.circle(mode, x, y, radius)
    love.graphics.pop()
end

-- Toggle debug mode
function Debug.toggle()
    Debug.enabled = not Debug.enabled
    print("[Debug] Debug mode: " .. (Debug.enabled and "ON" or "OFF"))
end

-- Toggle hex grid display
function Debug.toggleHexGrid()
    Debug.showHexGrid = not Debug.showHexGrid
    print("[Debug] Hex grid: " .. (Debug.showHexGrid and "ON" or "OFF"))
end

-- Toggle FOW display
function Debug.toggleFOW()
    Debug.showFOW = not Debug.showFOW
    print("[Debug] Fog of War: " .. (Debug.showFOW and "ON" or "OFF"))
end

-- Toggle vision cone display
function Debug.toggleVisionCones()
    Debug.showVisionCones = not Debug.showVisionCones
    print("[Debug] Vision cones: " .. (Debug.showVisionCones and "ON" or "OFF"))
end

-- Start performance timer
function Debug.startTimer(name)
    if not Debug.enabled then return end
    Debug[name .. "_start"] = love.timer.getTime()
end

-- End performance timer and log
function Debug.endTimer(name)
    if not Debug.enabled then return end
    local startTime = Debug[name .. "_start"]
    if startTime then
        local elapsed = (love.timer.getTime() - startTime) * 1000
        Debug[name] = elapsed
        if elapsed > 16.67 then  -- Slower than 60fps
            Debug.warn("Performance", name .. " took " .. string.format("%.2f", elapsed) .. "ms")
        end
    end
end

-- Draw performance stats
function Debug.drawPerformanceStats()
    if not Debug.enabled then return end
    
    local fps = love.timer.getFPS()
    local memUsage = collectgarbage("count")
    
    local stats = string.format(
        "FPS: %d\nMem: %.2f MB\nUpdate: %.2fms\nDraw: %.2fms",
        fps,
        memUsage / 1024,
        Debug.updateTime or 0,
        Debug.drawTime or 0
    )
    
    Debug.drawText(stats, 10, 10, {r = 255, g = 255, b = 0})
end

return Debug


























