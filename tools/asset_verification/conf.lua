-- Asset Verification Configuration
-- Standalone Love2D application for verifying game assets

function love.conf(t)
    t.title = "XCOM Simple - Asset Verification"
    t.version = "12.0"
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = false
    t.window.vsync = 1
    t.console = true  -- Enable console for debugging
    
    -- Load modules (minimal needed for asset verification)
    t.modules.audio = false
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.touch = false
    t.modules.video = false
end

























