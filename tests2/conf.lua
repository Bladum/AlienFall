-- ─────────────────────────────────────────────────────────────────────────
-- Love2D Configuration for tests2
-- ─────────────────────────────────────────────────────────────────────────

function love.conf(t)
    t.title = "AlienFall - Test Suite 2"
    t.version = "12.0"

    -- Window settings
    t.window.width = 1280
    t.window.height = 720
    t.window.resizable = true
    t.window.vsync = 1

    -- Console for debugging
    t.console = true

    -- Modules
    t.modules.audio = true
    t.modules.event = true
    t.modules.graphics = true
    t.modules.image = true
    t.modules.joystick = true
    t.modules.keyboard = true
    t.modules.math = true
    t.modules.mouse = true
    t.modules.physics = true
    t.modules.sound = true
    t.modules.system = true
    t.modules.timer = true
    t.modules.touch = true
    t.modules.video = true
    t.modules.window = true
    t.modules.thread = true
    t.modules.data = true

    -- Identity (for save files)
    t.identity = "alienfall_tests2"

    -- For Love2D 12
    t.window.highdpi = true
end
