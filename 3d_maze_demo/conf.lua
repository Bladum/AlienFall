-- 3D Maze Demo Configuration for Love2D
function love.conf(t)
    t.identity = "3d_maze_demo"
    t.version = "12.0"
    t.console = true -- Enable console for debugging

    t.window.title = "3D Maze Demo - Wolfenstein Style"
    t.window.icon = nil
    t.window.width = 1200
    t.window.height = 800
    t.window.borderless = false
    t.window.resizable = true
    t.window.minwidth = 800
    t.window.minheight = 600
    t.window.fullscreen = false
    t.window.fullscreentype = "desktop"
    t.window.vsync = 1
    t.window.msaa = 0 -- No antialiasing for crisp pixels
    t.window.depth = true -- Enable depth buffer for 3D
    t.window.displayindex = 1
    t.highdpi = false
    t.window.x = nil
    t.window.y = nil

    t.modules.audio = false
    t.modules.data = true
    t.modules.event = true
    t.modules.font = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = false
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = false
    t.modules.physics = false
    t.modules.sound = false
    t.modules.system = true
    t.modules.thread = false
    t.modules.timer = true
    t.modules.touch = false
    t.modules.video = false
    t.modules.window = true
end