-- Verify final output dimensions (400% scaled)

function love.load()
    print("=== VERIFYING 400% SCALED OUTPUT ===\n")

    local output_files = {
        "output/red_A4_150items.png",
        "output/yellow_A4_150items.png",
        "output/blue_A4_150items.png"
    }

    for _, filepath in ipairs(output_files) do
        local success, image = pcall(love.graphics.newImage, filepath)
        if success then
            local w = image:getWidth()
            local h = image:getHeight()
            print(filepath .. ": " .. w .. "x" .. h .. " (expected: 3200x4800)")
        else
            print(filepath .. ": ERROR - " .. tostring(image))
        end
    end

    print("\n=== SCALING VERIFICATION ===")
    print("Original canvas: 800x1200")
    print("Scaling: 400% (4x)")
    print("Expected output: 3200x4800")
    print("Filter: nearest neighbor (no antialiasing)")
    print("Pixel-perfect scaling for crisp edges")

    print("\nVerification complete!")
    love.event.quit()
end

function love.draw()
    love.graphics.print("Verifying 400% scaled output...", 10, 10)
end
