-- tests2/generators/init.lua
-- Test generation tools

local generators = {}

-- Generator tools
generators.scaffold = require("tests2.generators.scaffold_module_tests")
generators.analyze = require("tests2.generators.analyze_engine_structure")

function generators:runAll()
    print("\n" .. string.rep("═", 80))
    print("GENERATOR TOOLS - Test Generators")
    print(string.rep("═", 80))

    local passed = 0
    local failed = 0

    for name, tool in pairs(self) do
        if type(tool) == "table" and tool.run then
            local ok, err = pcall(function() tool:run() end)
            if ok then passed = passed + 1
            else failed = failed + 1; print("[ERROR] " .. name .. ": " .. tostring(err)) end
        end
    end

    print("\n" .. string.rep("═", 80))
    print("GENERATOR TOOLS SUMMARY: " .. passed .. " passed, " .. failed .. " failed")
    print(string.rep("═", 80) .. "\n")
end

return generators
