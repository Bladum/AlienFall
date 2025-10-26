-- tests2/widgets/init.lua
-- Widget system test suite

local widgets = {}

-- Widget tests
widgets.widget_lifecycle = require("tests2.widgets.widget_lifecycle_test")
widgets.widget_advanced = require("tests2.widgets.widget_advanced_test")

function widgets:runAll()
    print("\n" .. string.rep("═", 80))
    print("WIDGET TESTS - 2 Test Files")
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
    print("WIDGET TEST SUMMARY: " .. passed .. " passed, " .. failed .. " failed")
    print(string.rep("═", 80) .. "\n")
end

return widgets
