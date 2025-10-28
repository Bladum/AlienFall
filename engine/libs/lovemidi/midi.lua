-- lovemidi wrapper for Love2D
-- Based on: https://github.com/SiENcE/lovemidi
--
-- This module provides native MIDI playback using Windows MIDI API
-- Requires: midi.dll (place in game root or libs/lovemidi/)

local ffi = require("ffi")
local midi = {}

-- Check if we're on Windows
if love.system.getOS() ~= "Windows" then
    print("[lovemidi] Warning: lovemidi only works on Windows")
    return midi
end

-- Load the MIDI DLL
local midiLib = nil
local midiLoaded = false

-- Try to load from multiple locations
local dllPaths = {
    "midi.dll",
    "libs/lovemidi/midi.dll",
    "engine/libs/lovemidi/midi.dll",
}

for _, path in ipairs(dllPaths) do
    local success, result = pcall(ffi.load, path)
    if success then
        midiLib = result
        midiLoaded = true
        print("[lovemidi] Loaded MIDI library from: " .. path)
        break
    end
end

if not midiLoaded then
    print("[lovemidi] ERROR: Could not load midi.dll")
    print("[lovemidi] Please download from: https://github.com/SiENcE/lovemidi")
    print("[lovemidi] Place midi.dll in: engine/libs/lovemidi/ or game root")
    return midi
end

-- FFI definitions for MIDI API
ffi.cdef[[
    // MIDI functions
    bool midiInit();
    void midiClose();
    bool midiOpenFile(const char* filename);
    void midiCloseFile();
    bool midiPlay();
    void midiStop();
    void midiPause();
    void midiResume();
    bool midiIsPlaying();
    bool midiIsPaused();
    void midiSetVolume(int volume); // 0-127
    int midiGetVolume();
    double midiGetPosition(); // in seconds
    double midiGetLength(); // in seconds
    void midiSetPosition(double seconds);
]]

-- Initialize MIDI system
local function init()
    if midiLoaded then
        local success = midiLib.midiInit()
        if success then
            print("[lovemidi] MIDI system initialized")
            return true
        else
            print("[lovemidi] ERROR: Failed to initialize MIDI system")
            return false
        end
    end
    return false
end

-- Close MIDI system
local function close()
    if midiLoaded then
        midiLib.midiClose()
        print("[lovemidi] MIDI system closed")
    end
end

-- Open a MIDI file
function midi.openFile(filename)
    if not midiLoaded then return false end

    -- Convert Love2D path to absolute path
    local realPath = filename

    -- Check if file exists using Love2D filesystem first
    if not love.filesystem.getInfo(filename) then
        print("[lovemidi] ERROR: File not found: " .. filename)
        return false
    end

    -- Get the source directory (where the game is running from)
    local sourceDir = love.filesystem.getSource()

    -- If source is a directory, construct full path
    if love.filesystem.getInfo(filename) then
        realPath = sourceDir .. "/" .. filename
        -- Normalize path separators for Windows
        realPath = realPath:gsub("/", "\\")
    end

    print("[lovemidi] Opening file: " .. realPath)
    local success = midiLib.midiOpenFile(realPath)

    if success then
        print("[lovemidi] File opened successfully")
        return true
    else
        print("[lovemidi] ERROR: Failed to open file: " .. realPath)
        return false
    end
end

-- Close current MIDI file
function midi.closeFile()
    if midiLoaded then
        midiLib.midiCloseFile()
    end
end

-- Play MIDI
function midi.play()
    if not midiLoaded then return false end
    local success = midiLib.midiPlay()
    if success then
        print("[lovemidi] Playing MIDI")
    else
        print("[lovemidi] ERROR: Failed to play MIDI")
    end
    return success
end

-- Stop MIDI
function midi.stop()
    if midiLoaded then
        midiLib.midiStop()
        print("[lovemidi] Stopped MIDI")
    end
end

-- Pause MIDI
function midi.pause()
    if midiLoaded then
        midiLib.midiPause()
        print("[lovemidi] Paused MIDI")
    end
end

-- Resume MIDI
function midi.resume()
    if midiLoaded then
        midiLib.midiResume()
        print("[lovemidi] Resumed MIDI")
    end
end

-- Check if MIDI is playing
function midi.isPlaying()
    if not midiLoaded then return false end
    return midiLib.midiIsPlaying()
end

-- Check if MIDI is paused
function midi.isPaused()
    if not midiLoaded then return false end
    return midiLib.midiIsPaused()
end

-- Set volume (0-127)
function midi.setVolume(volume)
    if midiLoaded then
        volume = math.max(0, math.min(127, volume))
        midiLib.midiSetVolume(volume)
    end
end

-- Get volume (0-127)
function midi.getVolume()
    if not midiLoaded then return 0 end
    return midiLib.midiGetVolume()
end

-- Get playback position in seconds
function midi.getPosition()
    if not midiLoaded then return 0 end
    return midiLib.midiGetPosition()
end

-- Get total length in seconds
function midi.getLength()
    if not midiLoaded then return 0 end
    return midiLib.midiGetLength()
end

-- Set playback position in seconds
function midi.setPosition(seconds)
    if midiLoaded then
        midiLib.midiSetPosition(seconds)
    end
end

-- Initialize on load
midi.available = init()

-- Store module info
midi.loaded = midiLoaded
midi.version = "1.0.0"

return midi

