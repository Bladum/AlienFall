-- tests2/audio/init.lua
-- Audio systems test suite

local audio = {}

-- Audio system tests
audio.audio_system = require("tests2.audio.audio_system_test")

function audio:runAll()
    print("\n" .. string.rep("═", 80))
    print("AUDIO SYSTEMS TESTS - 1 Test File")
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
    print("AUDIO TEST SUMMARY: " .. passed .. " passed, " .. failed .. " failed")
    print(string.rep("═", 80) .. "\n")
end

return audio
