-- tests2/accessibility/init.lua
-- Accessibility features test suite

local accessibility = {}

-- Accessibility feature tests
accessibility.accessibility = require("tests2.accessibility.accessibility_test")
accessibility.colorblind = require("tests2.core.colorblind_mode_test")

function accessibility:runAll()
    print("\n" .. string.rep("═", 80))
    print("ACCESSIBILITY TESTS - 2 Test Files")
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
    print("ACCESSIBILITY TEST SUMMARY: " .. passed .. " passed, " .. failed .. " failed")
    print(string.rep("═", 80) .. "\n")
end

return accessibility
