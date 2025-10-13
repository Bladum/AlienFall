-- Love2D and LuaJIT globals for Lua Language Server
love = {
    graphics = {},
    window = {},
    audio = {},
    filesystem = {},
    timer = {},
    event = {},
    keyboard = {},
    mouse = {},
    joystick = {},
    physics = {},
    sound = {},
    system = {},
    thread = {},
    math = {},
    data = {},
    video = {},
    image = {}
}

-- Love2D main functions
love.getVersion = function() end

-- Graphics functions
love.graphics.clear = function(r, g, b, a, stencil, depth) end
love.graphics.print = function(text, x, y, r, sx, sy, ox, oy, kx, ky) end
love.graphics.printf = function(text, x, y, limit, align, r, sx, sy, ox, oy, kx, ky) end
love.graphics.setColor = function(red, green, blue, alpha) end
love.graphics.getWidth = function() return 0 end
love.graphics.getHeight = function() return 0 end
love.graphics.readbackTexture = function(texture) return {} end -- Love2D 12.0+
love.graphics.newImage = function(data) return {} end
love.graphics.rectangle = function(mode, x, y, w, h, rx, ry, segments) end
love.graphics.circle = function(mode, x, y, radius, segments) end
love.graphics.line = function(x1, y1, x2, y2, ...) end

-- Window functions
love.window.setTitle = function(title) end
love.window.setMode = function(width, height, flags) end
love.window.getFullscreen = function() end
love.window.setFullscreen = function(fullscreen) return true end

-- Timer functions
love.timer.getDelta = function() return 0.0 end
love.timer.getTime = function() return 0.0 end
love.timer.sleep = function(s) end

-- Filesystem functions
love.filesystem.read = function(name, size) return "", 0, nil, "" end
love.filesystem.write = function(name, data, size) return true, "" end
love.filesystem.exists = function(name) end
love.filesystem.getDirectoryItems = function(dir) return {} end

-- Keyboard functions
love.keyboard.isScancodeDown = function(scancode) end

-- Mouse functions
love.mouse.getPosition = function() end
love.mouse.isDown = function(button) end
love.mouse.setVisible = function(visible) end

-- Event functions
love.event.pump = function() end
love.event.poll = function() end

-- Math functions
love.math.random = function(min, max) return 0 end
love.math.setRandomSeed = function(seed) end

-- Lua standard math functions (Lua 5.3+ available in LuaJIT)
math.angle = function(x1, y1, x2, y2) return 0 end
math.dist = function(x1, y1, x2, y2) return 0 end
math.normalize = function(x, y) return 0, 0 end

-- LuaJIT specific globals
bit = {
    band = function(x, y) end,
    bor = function(x, y) end,
    bxor = function(x, y) end,
    bnot = function(x) end,
    lshift = function(x, n) end,
    rshift = function(x, n) end,
    arshift = function(x, n) end,
    rol = function(x, n) end,
    ror = function(x, n) end
}

jit = {
    version = "LuaJIT 2.1.0-beta3",
    version_num = 20100,
    os = "",
    arch = "",
    status = function() end,
    on = function() end,
    off = function() end,
    flush = function() end
}

ffi = {
    load = function(name) end,
    typeof = function(def) end,
    cdef = function(def) end,
    new = function(ctype, init) end,
    cast = function(ctype, val) end,
    sizeof = function(ctype) end,
    alignof = function(ctype) end,
    metatype = function(ctype, metatable) end,
    gc = function(cdata, finalizer) end,
    copy = function(dst, src, len) end,
    fill = function(dst, len, c) end,
    string = function(ptr, len) end
}