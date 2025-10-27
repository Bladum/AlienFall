-- Simple MIDI Test - Direct Testing
-- This bypasses all the complex state management to isolate the problem

-- Test 1: Can we read files?
print("=== TEST 1: File Reading ===")
print("Love2D source: " .. love.filesystem.getSource())

local dirs = {"MIDI TEST", ".", "engine"}
for _, dir in ipairs(dirs) do
    print("Trying to read: " .. dir)
    local ok, items = pcall(love.filesystem.getDirectoryItems, dir)
    if ok then
        print("  SUCCESS - " .. #items .. " items")
        for i, file in ipairs(items) do
            if i <= 5 then  -- Show first 5
                print("    - " .. file)
            end
        end
    else
        print("  FAILED")
    end
end

-- Test 2: Can we find MIDI file?
print("\n=== TEST 2: Finding MIDI ===")
local midiPath = "MIDI TEST/Queen - Bohemian Rhapsody.mid"
print("Looking for: " .. midiPath)
local exists = love.filesystem.getInfo(midiPath)
if exists then
    print("  FOUND! Size: " .. exists.size .. " bytes")
else
    print("  NOT FOUND")
end

-- Test 3: Can we read MIDI file?
print("\n=== TEST 3: Reading MIDI ===")
local success, data = pcall(love.filesystem.read, midiPath)
if success and data then
    print("  SUCCESS - Read " .. #data .. " bytes")
    print("  First 4 bytes: " .. string.format("%02X %02X %02X %02X",
        string.byte(data, 1), string.byte(data, 2), string.byte(data, 3), string.byte(data, 4)))
else
    print("  FAILED")
end

print("\n=== END DIAGNOSTICS ===")
