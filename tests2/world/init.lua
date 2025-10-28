-- tests2/world/init.lua
-- World systems tests

local world = {}

-- World tests
world.world_map_generation = require("tests2.world.world_map_generation_test")

function world:runAll()
    print("\n" .. string.rep("═", 80))
    print("WORLD TESTS - 1 Test File")
    print(string.rep("═", 80))

    local passed = 0
    local failed = 0

    for name, test in pairs(self) do
        if type(test) == "table" and test.run then
            local ok, err = pcall(function() test:run() end)
            if ok then passed = passed + 1
            else failed = failed + 1; print("[ERROR] " .. name .. ": " .. tostring(err)) end
        end
    end

    print("\n" .. string.rep("═", 80))
    print("WORLD TEST SUMMARY: " .. passed .. " passed, " .. failed .. " failed")
    print(string.rep("═", 80) .. "\n")
end

return world
