-- tests2/integration/init.lua
-- Integration test suite

local integration = {}

-- Integration tests
integration.battlescape_basescape = require("tests2.integration.battlescape_basescape_flow_test")
integration.cross_system = require("tests2.integration.cross_system_flows_test")
integration.system_integration = require("tests2.integration.system_integration_test")
integration.data_loader = require("tests2.integration.data_loader_test")
integration.dynamic_events = require("tests2.integration.dynamic_events_test")

function integration:runAll()
    print("\n" .. string.rep("═", 80))
    print("INTEGRATION TESTS - 5 Test Files")
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
    print("INTEGRATION TEST SUMMARY: " .. passed .. " passed, " .. failed .. " failed")
    print(string.rep("═", 80) .. "\n")
end

return integration
