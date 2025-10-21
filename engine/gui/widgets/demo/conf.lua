---Widget Demo Configuration - Love2D Configuration File
---
---Love2D configuration for the standalone widget demo application. Configures
---window settings, enabled modules, and Love2D framework options. This demo
---showcases all 23+ widgets in a standalone application separate from the main game.
---
---Configuration Settings:
---  - Window: 1200×900 resolution
---  - Console: Enabled for debugging
---  - Grid: 24×24 pixel grid system
---  - MSAA: Disabled (pixel art)
---  - VSync: Enabled
---
---Purpose:
---  - Standalone widget testing environment
---  - Visual showcase of all widgets
---  - Development and debugging tool
---  - Demonstration for documentation
---
---Key Configuration:
---  - t.console = true: Enables debug console
---  - t.window.width/height: Sets window size
---  - nearest filter: Pixel-perfect rendering
---  - All modules enabled: Full Love2D functionality
---
---Dependencies:
---  - Love2D 12.0+: Game framework
---
---@module widgets.demo.conf
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  -- Run with: lovec "engine/widgets/demo"
---  -- Or execute: run_demo.bat
---
---@see widgets.demo.main For demo application code

-- Widget Demo Configuration
function love.conf(t)
    t.title = "Widget System Demo - AlienFall"
    t.version = "12.0"
    t.console = true  -- Enable console for debugging
    
    -- Window settings
    t.window.width = 1200
    t.window.height = 900
    t.window.resizable = false
    t.window.vsync = 1
    t.window.msaa = 0
    t.window.display = 1
    t.window.highdpi = false
    t.window.x = nil
    t.window.y = nil
    
    -- Modules
    t.modules.audio = true
    t.modules.event = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = false
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = false
    t.modules.sound = true
    t.modules.system = true
    t.modules.timer = true
    t.modules.touch = false
    t.modules.video = false
    t.modules.window = true
    t.modules.thread = false
end


























