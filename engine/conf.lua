---Love2D Configuration Module
---
---Configures the Love2D engine for Alien Fall. Sets window properties, grid system,
---enabled modules, and performance settings. This file is loaded by Love2D before
---main.lua and configures the engine's behavior.
---
---Key Configuration:
---  - Resolution: 960×720 pixels (40×30 grid at 24px per cell)
---  - Grid System: All UI elements snap to 24×24 pixel grid
---  - Console: Enabled for debug output on Windows
---  - Resizable: Yes, with 960×720 minimum for UI compatibility
---  - MSAA: 2x anti-aliasing for smooth rendering
---  - VSync: Enabled to prevent screen tearing
---
---Key Exports:
---  - love.conf(t): Configures Love2D engine settings
---
---Dependencies:
---  - None (loaded before main.lua by Love2D)
---
---@module conf
---@author AlienFall Development Team
---@copyright 2025 AlienFall Project
---@license Open Source
---
---@usage
---  -- This file is automatically loaded by Love2D
---  -- No manual invocation required
---
---@see main For game initialization after configuration
---@see utils.viewport For dynamic resolution handling
---@see widgets.core.grid For grid system implementation

function love.conf(t)
    t.identity = "alien_fall"               -- Save directory name
    t.version = "12.0"                      -- Love2D version
    t.console = true                        -- Enable console (useful for debugging on Windows)
    
    t.window.title = "Alien Fall"          -- Window title
    t.window.icon = "icon.png"              -- Window icon
    t.window.width = 960                    -- Window width (40 grid columns × 24px)
    t.window.height = 720                   -- Window height (30 grid rows × 24px)
    t.window.borderless = false             -- Window has borders
    t.window.resizable = true               -- Allow resizing for dynamic resolution
    t.window.minwidth = 960                 -- Minimum width
    t.window.minheight = 720                -- Minimum height
    t.window.fullscreen = false             -- Always windowed
    -- No borderless, no fullscreen, no resizing
    t.window.vsync = 1                      -- Enable vertical sync
    t.window.msaa = 2                       -- Multisample anti-aliasing (4x)
    t.window.alwaysOnTop = true             -- Keep window on top of others
    t.window.x = 100                        -- Window x position
    t.window.y = 100                        -- Window y position
    
    t.modules.audio = true                  -- Enable audio module
    t.modules.event = true                  -- Enable event module
    t.modules.graphics = true               -- Enable graphics module
    t.modules.image = true                  -- Enable image module
    t.modules.joystick = false              -- Disable joystick (not needed)
    t.modules.keyboard = true               -- Enable keyboard
    t.modules.math = true                   -- Enable math
    t.modules.mouse = true                  -- Enable mouse
    t.modules.physics = false               -- Disable physics (not needed)
    t.modules.sound = true                  -- Enable sound
    t.modules.system = true                 -- Enable system
    t.modules.timer = true                  -- Enable timer
    t.modules.touch = false                 -- Disable touch (not needed)
    t.modules.video = false                 -- Disable video (not needed)
    t.modules.window = true                 -- Enable window
    t.modules.thread = true                 -- Enable threading
end


























