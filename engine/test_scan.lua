---@diagnostic disable: inject-field
---@diagnostic disable: duplicate-set-field

---@class love
---@field load fun()
---@field keypressed fun(key: string)
---@field draw fun()
---@field filesystem table
---@field graphics table
---@field event table

-- Test file scanning
local function load()
    print("[TEST] ========== FILESYSTEM DEBUG ==========")

    -- Get parent directory path (project root)
    local source = love.filesystem.getSource()
    local parent_path = source:match("(.*)\\[^\\]*$")  -- Remove last directory for Windows

    -- List root directory using io (since love.filesystem can't access parent)
    print("\n[TEST] Listing root directory (" .. parent_path .. ")")
    local command = 'dir /b "' .. parent_path .. '" 2>nul'
    local handle = io.popen(command)
    local output = ""
    if handle then
        output = handle:read("*a")
        handle:close()
    else
        print("[ERROR] Could not list directory")
    end

    local root_items = {}
    for line in output:gmatch("[^\r\n]+") do
        table.insert(root_items, line)
    end

    for _, item in ipairs(root_items) do
        print("[TEST]   - " .. item)
    end

    -- Look for integrated MIDI folder in engine
    print("\n[TEST] Looking for assets/music/midi folder...")
    local midi_path = "assets/music/midi"
    local success, items = pcall(love.filesystem.getDirectoryItems, midi_path)

    if success then
        print("[TEST] FOUND: " .. midi_path)
        print("[TEST] Contents:")

        for _, file in ipairs(items) do
            print("[TEST]   - " .. file)
        end
    else
        print("[TEST] MIDI folder NOT found at: " .. midi_path)
    end

    print("\n[TEST] Press ESC to exit")
end

local function keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

local function draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("[TEST] Check console output. Press ESC to exit.", 10, 10)
end

love.load = load
love.keypressed = keypressed
love.draw = draw
