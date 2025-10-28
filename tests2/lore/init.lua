-- tests2/lore/init.lua
-- Lore systems test suite

local lore = {}

-- Lore tests
lore.alien_biology = require("tests2.lore.alien_biology_test")
lore.artifact_acquisition = require("tests2.lore.artifact_acquisition_test")
lore.artifact_power = require("tests2.lore.artifact_power_test")
lore.event_chain = require("tests2.lore.event_chain_test")
lore.event_system = require("tests2.lore.event_system_test")
lore.lore_integration = require("tests2.lore.lore_integration_test")
lore.lore_manager = require("tests2.lore.lore_manager_test")
lore.lore_progression = require("tests2.lore.lore_progression_test")
lore.mutation_system = require("tests2.lore.mutation_system_test")

function lore:runAll()
    print("\n" .. string.rep("═", 80))
    print("LORE TESTS - 9 Test Files")
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
    print("LORE TEST SUMMARY: " .. passed .. " passed, " .. failed .. " failed")
    print(string.rep("═", 80) .. "\n")
end

return lore
