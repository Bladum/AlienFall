-- tests2/economy/init.lua
-- Economy systems test suite

local economy = {}

-- Economy tests
economy.economic_simulation = require("tests2.economy.economic_simulation_test")
economy.economy_simulation = require("tests2.economy.economy_simulation_test")
economy.economy = require("tests2.economy.economy_test")
economy.financial_manager = require("tests2.economy.financial_manager_test")
economy.manufacturing = require("tests2.economy.manufacturing_test")
economy.marketplace_economy = require("tests2.economy.marketplace_economy_test")
economy.marketplace = require("tests2.economy.marketplace_test")
economy.research_queue = require("tests2.economy.research_queue_test")
economy.research_system = require("tests2.economy.research_system_test")
economy.research = require("tests2.economy.research_test")
economy.resource_allocation = require("tests2.economy.resource_allocation_test")
economy.resource_flow_optimization = require("tests2.economy.resource_flow_optimization_test")
economy.resource_flow = require("tests2.economy.resource_flow_test")
economy.resource_market = require("tests2.economy.resource_market_test")
economy.salvage = require("tests2.economy.salvage_test")
economy.supply_chain = require("tests2.economy.supply_chain_test")
economy.tech_tree_system = require("tests2.economy.tech_tree_system_test")
economy.upgrade_system = require("tests2.economy.upgrade_system_test")

function economy:runAll()
    print("\n" .. string.rep("═", 80))
    print("ECONOMY TESTS - 19 Test Files")
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
    print("ECONOMY TEST SUMMARY: " .. passed .. " passed, " .. failed .. " failed")
    print(string.rep("═", 80) .. "\n")
end

return economy
