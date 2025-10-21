-- Map Editor Configuration
-- Standalone Love2D application for map editing

function love.conf(t)
    t.title = "XCOM Simple - Map Editor"
    t.version = "12.0"
    t.window.width = 960
    t.window.height = 720
    t.window.resizable = false
    t.window.vsync = 1
    t.console = true  -- Enable console for debugging
    
    -- Load modules
    t.modules.joystick = false
    t.modules.physics = false
end

























