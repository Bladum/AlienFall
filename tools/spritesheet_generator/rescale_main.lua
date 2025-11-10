-- Rescale Images Main Script
-- Runs the image rescaler for all armies

function love.load()
    print("\n========== IMAGE RESCALER ==========\n")

    -- Load the rescaler module
    local rescaler = require("rescale_images")

    -- Process all armies
    local success = rescaler.process_all_armies()

    if success then
        print("[MAIN] ✓ All images rescaled successfully!")
    else
        print("[MAIN] ✗ Some images failed to rescale")
    end

    print("\n[MAIN] Check output_rescaled/ directory for results\n")

    -- Exit
    love.event.quit()
end

function love.draw()
    love.graphics.print("Rescaling images... check console", 10, 10)
end