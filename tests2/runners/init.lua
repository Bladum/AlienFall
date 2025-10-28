-- tests2/runners/init.lua
-- Test runner utilities

local runners = {}

-- Load runner scripts
runners.run_all = require("tests2.runners.run_all")
runners.run_subsystem = require("tests2.runners.run_subsystem")
runners.run_single = require("tests2.runners.run_single_test")

function runners:runAll()
    print("\n" .. string.rep("═", 80))
    print("TEST RUNNERS - Runner Infrastructure")
    print(string.rep("═", 80))
    print("Runners are invoked separately")
    print(string.rep("═", 80) .. "\n")
end

return runners
