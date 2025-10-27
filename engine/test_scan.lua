-- Test file scanning
function love.load()
    print("[TEST] ========== FILESYSTEM DEBUG ==========")

    -- List root directory
    print("\n[TEST] Listing root directory (.)")
    local root_items = love.filesystem.getDirectoryItems(".")
    for _, item in ipairs(root_items) do
        print("[TEST]   - " .. item)
    end

    -- Try to find MIDI TEST folder (with space)
    print("\n[TEST] Looking for MIDI TEST folder...")
    local found = false
    for _, item in ipairs(root_items) do
        if string.lower(item) == "midi test" then
            print("[TEST] FOUND: " .. item)
            found = true

            -- List contents
            print("[TEST] Contents of '" .. item .. "':")
            local midi_items = love.filesystem.getDirectoryItems(item)
            for _, midi_file in ipairs(midi_items) do
                print("[TEST]   - " .. midi_file)
            end
        end
    end

    if not found then
        print("[TEST] MIDI TEST folder NOT found!")
    end

    print("\n[TEST] Press ESC to exit")
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("[TEST] Check console output. Press ESC to exit.", 10, 10)
end
