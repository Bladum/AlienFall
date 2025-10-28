-- tests2/ui/init.lua
-- UI and widget integration test suite

local ui = {}

-- UI system tests
ui.widgets = require("tests2.widgets.init")

function ui:runAll()
    print("\n" .. string.rep("═", 80))
    print("UI TESTS - Widget and GUI system integration")
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
    print("UI TEST SUMMARY: " .. passed .. " passed, " .. failed .. " failed")
    print(string.rep("═", 80) .. "\n")
end

return ui
