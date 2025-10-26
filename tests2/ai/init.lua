-- tests2/ai/init.lua
-- AI systems test suite

local ai = {}

-- AI system tests
ai.advanced = require("tests2.ai.advanced_ai_test")
ai.coordinator = require("tests2.ai.ai_coordinator_test")
ai.tactical_decision = require("tests2.ai.ai_tactical_decision_test")
ai.tactical_planning = require("tests2.ai.ai_tactical_planning_test")
ai.faction = require("tests2.ai.faction_ai_test")
ai.performance = require("tests2.ai.performance_optimization_test")
ai.strategic_planner = require("tests2.ai.strategic_planner_test")
ai.tactical = require("tests2.ai.tactical_ai_test")

function ai:runAll()
    print("\n" .. string.rep("═", 80))
    print("AI SYSTEMS TESTS - 8 Test Files")
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
    print("AI TEST SUMMARY: " .. passed .. " passed, " .. failed .. " failed")
    print(string.rep("═", 80) .. "\n")
end

return ai
