-- Image Rescaler for Armies
-- Rescales all PNG images in armies/*/graphics/ to 80x80 pixels with transparent background

local rescaler = {}

-- Function to rescale a single image
function rescaler.rescale_image(input_path, output_path)
    print("[Rescaler] Rescaling: " .. input_path .. " -> " .. output_path)

    -- Load the original image
    local success, image = pcall(function()
        return love.graphics.newImage(input_path)
    end)

    if not success then
        print("[ERROR] Failed to load image: " .. input_path)
        return false
    end

    local orig_w, orig_h = image:getDimensions()
    print("[Rescaler] Original size: " .. orig_w .. "x" .. orig_h)

    -- Create a new canvas of 72x72 with transparent background
    local canvas = love.graphics.newCanvas(72, 72)
    love.graphics.setCanvas(canvas)

    -- Clear with transparent background (though it will be filled)
    love.graphics.clear(0, 0, 0, 0)  -- RGBA: transparent

    -- Scale back to 72x72
    local scale = 72 / orig_w

    -- Draw the scaled image to fill 80x80
    love.graphics.setColor(1, 1, 1, 1)  -- White (no tint)
    love.graphics.draw(
        image,
        0,  -- x
        0,  -- y
        0,  -- rotation
        scale,  -- scale x
        scale   -- scale y
    )

    love.graphics.setCanvas()  -- Reset to default canvas
    love.graphics.setColor(1, 1, 1, 1)  -- Reset color

    -- Save the canvas as PNG
    local image_data = love.graphics.readbackTexture(canvas)
    local save_success = pcall(function()
        image_data:encode("png", output_path)
    end)

    if save_success then
        print("[Rescaler] ✓ Saved: " .. output_path)
        return true
    else
        print("[ERROR] Failed to save: " .. output_path)
        return false
    end
end

-- Function to process all images in armies folder
function rescaler.process_all_armies()
    print("\n[Rescaler] ========================================")
    print("[Rescaler] IMAGE RESCALER FOR ARMIES")
    print("[Rescaler] ========================================")
    print("[Rescaler] Target size: 80x80 pixels")
    print("[Rescaler] Background: Transparent")
    print("[Rescaler] ========================================\n")

    -- Create output directory
    local output_base = "output_rescaled"
    if not love.filesystem.getInfo(output_base) then
        love.filesystem.createDirectory(output_base)
    end

    local armies = {"blue", "red", "yellow"}
    local total_processed = 0
    local total_success = 0

    for _, army in ipairs(armies) do
        print("[Rescaler] Processing army: " .. army)

        local graphics_dir = "armies/" .. army .. "/graphics"
        local output_dir = output_base .. "/" .. army

        -- Create army output directory
        if not love.filesystem.getInfo(output_dir) then
            love.filesystem.createDirectory(output_dir)
        end

        -- Get all items in graphics directory
        local items = love.filesystem.getDirectoryItems(graphics_dir)

        for _, item in ipairs(items) do
            if item:match("%.png$") then
                local input_path = graphics_dir .. "/" .. item
                local output_path = output_dir .. "/" .. item

                total_processed = total_processed + 1

                if rescaler.rescale_image(input_path, output_path) then
                    total_success = total_success + 1
                end
            end
        end

        print("[Rescaler] Finished army: " .. army .. "\n")
    end

    print("[Rescaler] ========================================")
    print("[Rescaler] RESCALING COMPLETE")
    print("[Rescaler] Processed: " .. total_processed .. " images")
    print("[Rescaler] Successful: " .. total_success .. " images")
    if total_processed > total_success then
        print("[Rescaler] Failed: " .. (total_processed - total_success) .. " images")
    end
    print("[Rescaler] Output directory: " .. output_base)
    print("[Rescaler] ========================================\n")

    return total_success == total_processed
end

return rescaler