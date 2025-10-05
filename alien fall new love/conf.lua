function love.conf(t)
    t.title = "Alien Fall"
    t.version = "12.0"
    t.window.width = 800
    t.window.height = 600
    t.window.resizable = true
    t.window.fullscreen = false
    t.window.vsync = 1
    t.window.msaa = 0  -- Disable antialiasing for crisp pixel art
    t.highdpi = false  -- Love2D 12: moved from t.window.highdpi to t.highdpi
    t.console = true   -- SYSTEM REQUIREMENT: Console always enabled for debugging

    -- Check environment variables for test mode
    if os.getenv("LOVE_TEST_MODE") then
        _G.TEST_MODE = true
        _G.TEST_WATCH = os.getenv("LOVE_TEST_WATCH") == "true"
        _G.TEST_FILE = os.getenv("LOVE_TEST_FILE")
        t.console = true
    end
end