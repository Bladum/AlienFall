-- Love2D Configuration
-- Optimized for Love2D 12.x

function love.conf(t)
    t.identity = "3d_tactical_game"
    t.version = "12.0"
    t.console = true  -- Enable console for debugging
    
    -- Window settings
    t.window.title = "3D Tactical Combat Game"
    t.window.width = 1280
    t.window.height = 720
    t.window.resizable = true
    t.window.vsync = 1
    t.window.msaa = 0
    t.window.depth = 16  -- Enable depth buffer for 3D
    t.window.stencil = false
    
    -- Modules
    t.modules.audio = true
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = false
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = true  -- Box2D for projectiles
    t.modules.sound = true
    t.modules.system = true
    t.modules.thread = false
    t.modules.timer = true
    t.modules.touch = false
    t.modules.video = false
    t.modules.window = true
end






















