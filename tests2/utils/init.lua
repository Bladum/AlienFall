-- tests2/utils/init.lua
-- Utility and helper test suite

local utils = {}

-- Utility tests
utils.helpers = require("tests2.utils.test_helpers")

function utils:runAll()
    print("\n" .. string.rep("═", 80))
    print("UTILITY TESTS - Utils Module")
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
    print("UTILS TEST SUMMARY: " .. passed .. " passed, " .. failed .. " failed")
    print(string.rep("═", 80) .. "\n")
end

return utils
