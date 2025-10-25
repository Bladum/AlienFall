--[[
  Spritesheet Generator - Main Entry Point

  Object-oriented structure:
  - src/Army.lua - represents each army
  - src/Generator.lua - coordinates generation
  - armies/{red,yellow,blue}/ - army configs and graphics
  - cfg/ - engine configuration
  - output/ - generated spritesheets
]]--

function love.load()
    print("\n========== SPRITESHEET GENERATOR - OOP VERSION ==========\n")

    -- Load required modules
    local Army = require("src.Army")
    local Generator = require("src.Generator")

    -- Create generator
    local generator = Generator.new()

    -- Create armies from config folders
    local armies_to_generate = { "red", "yellow", "blue" }

    for _, army_name in ipairs(armies_to_generate) do
        local army_path = "armies/" .. army_name

        -- Check if army folder exists
        if love.filesystem.getInfo(army_path) then
            local army = Army.new(army_name, army_path)
            generator:addArmy(army)
        else
            print("[MAIN] ⚠ Army folder not found: " .. army_path)
        end
    end

    -- Generate all armies
    print("[MAIN] Starting batch generation...\n")
    local success = generator:generateAll()

    if success then
        print("[MAIN] ✓ All spritesheets generated successfully!")
    else
        print("[MAIN] ✗ Some spritesheets failed to generate")
    end

    print("\n[MAIN] Output directory: output/\n")

    -- Exit
    love.event.quit()
end

function love.draw()
    love.graphics.print("Generating spritesheets... check console", 10, 10)
end
