-- tests2/tutorial/init.lua
-- Tutorial system tests

local tutorial = {}

-- Tutorial tests
tutorial.tutorial_system = require("tests2.tutorial.tutorial_system_test")

function tutorial:runAll()
    print("\n" .. string.rep("═", 80))
    print("TUTORIAL TESTS - 1 Test File")
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
    print("TUTORIAL TEST SUMMARY: " .. passed .. " passed, " .. failed .. " failed")
    print(string.rep("═", 80) .. "\n")
end

return tutorial
