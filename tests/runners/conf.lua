-- Love2D Configuration for Test Runner

function love.conf(t)
    t.identity = "xcom_simple_tests"
    t.version = "12.0"
    t.console = true
    
    t.window.title = "XCOM Simple - Test Runner"
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = false
    t.window.vsync = 1
    
    t.modules.joystick = false
    t.modules.physics = false
end
