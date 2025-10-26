-- tests2/politics/init.lua
-- Politics systems test suite

local politics = {}

-- Politics tests
politics.counter_intelligence = require("tests2.politics.counter_intelligence_test")
politics.diplomacy_system = require("tests2.politics.diplomacy_system_test")
politics.diplomatic_relations = require("tests2.politics.diplomatic_relations_test")
politics.factional_trends = require("tests2.politics.factional_trends_test")
politics.faction_allegiance = require("tests2.politics.faction_allegiance_test")
politics.faction_reputation = require("tests2.politics.faction_reputation_test")
politics.faction_warfare = require("tests2.politics.faction_warfare_test")
politics.fame = require("tests2.politics.fame_test")
politics.karma_system = require("tests2.politics.karma_system_test")
politics.karma = require("tests2.politics.karma_test")
politics.political_management = require("tests2.politics.political_management_test")
politics.region_politics = require("tests2.politics.region_politics_test")
politics.relations = require("tests2.politics.relations_test")
politics.reputation = require("tests2.politics.reputation_test")
politics.trade_diplomacy = require("tests2.politics.trade_diplomacy_test")

function politics:runAll()
    print("\n" .. string.rep("═", 80))
    print("POLITICS TESTS - 15 Test Files")
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
    print("POLITICS TEST SUMMARY: " .. passed .. " passed, " .. failed .. " failed")
    print(string.rep("═", 80) .. "\n")
end

return politics
