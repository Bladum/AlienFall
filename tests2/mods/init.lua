-- tests2/mods/init.lua
-- Mod system tests

local mods = {}

-- Mod tests
mods.mod_system = require("tests2.mods.mod_system_test")

function mods:runAll()
    print("\n" .. string.rep("═", 80))
    print("MOD TESTS - 1 Test File")
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
    print("MOD TEST SUMMARY: " .. passed .. " passed, " .. failed .. " failed")
    print(string.rep("═", 80) .. "\n")
end

return mods
