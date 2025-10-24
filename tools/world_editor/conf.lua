-- World Editor Configuration
-- Standalone Love2D application for world editing

function love.conf(t)
    t.title = "XCOM Simple - World Editor"
    t.version = "12.0"
    t.window.width = 1200
    t.window.height = 800
    t.window.resizable = true
    t.window.vsync = 1
    t.console = true  -- Enable console for debugging

    -- Load modules
    t.modules.joystick = false
    t.modules.physics = false
end
