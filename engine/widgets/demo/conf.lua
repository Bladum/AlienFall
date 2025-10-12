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
