-- Configuration for Map Block Test Runner

function love.conf(t)
    t.console = true                -- Enable console for debug output
    t.window.title = "Map Block Test"
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = false
    t.modules.joystick = false
    t.modules.physics = false
    t.modules.touch = false
    t.modules.video = false
end
