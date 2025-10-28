-- Native MIDI Player using lovemidi
-- Provides real audio playback through Windows MIDI API

local lovemidi = require("libs.lovemidi.midi")

local MidiPlayerNative = {
    isPlaying = false,
    currentFile = nil,
    volume = 0.6, -- 0-1 range
    available = false
}

-- Initialize
function MidiPlayerNative:init()
    self.available = lovemidi.loaded and lovemidi.available

    if self.available then
        print("[MidiPlayerNative] Native MIDI playback available")
        -- Set initial volume (convert 0-1 to 0-127)
        lovemidi.setVolume(math.floor(self.volume * 127))
    else
        print("[MidiPlayerNative] Native MIDI playback NOT available")
        print("[MidiPlayerNative] Download midi.dll from: https://github.com/SiENcE/lovemidi")
    end

    return self.available
end

-- Play a MIDI file
function MidiPlayerNative:play(filePath)
    if not self.available then
        print("[MidiPlayerNative] ERROR: lovemidi not available")
        return false
    end

    -- Stop any currently playing MIDI
    self:stop()

    print("[MidiPlayerNative] Attempting to play: " .. filePath)

    -- Open the file
    if not lovemidi.openFile(filePath) then
        print("[MidiPlayerNative] ERROR: Failed to open file: " .. filePath)
        return false
    end

    -- Play the file
    if lovemidi.play() then
        self.isPlaying = true
        self.currentFile = filePath
        print("[MidiPlayerNative] Successfully started playback: " .. filePath)
        return true
    else
        print("[MidiPlayerNative] ERROR: Failed to start playback")
        lovemidi.closeFile()
        return false
    end
end

-- Stop playback
function MidiPlayerNative:stop()
    if not self.available then return end

    if self.isPlaying then
        lovemidi.stop()
        lovemidi.closeFile()
        self.isPlaying = false
        self.currentFile = nil
        print("[MidiPlayerNative] Stopped playback")
    end
end

-- Pause playback
function MidiPlayerNative:pause()
    if not self.available then return end

    if self.isPlaying then
        lovemidi.pause()
        print("[MidiPlayerNative] Paused playback")
    end
end

-- Resume playback
function MidiPlayerNative:resume()
    if not self.available then return end

    if lovemidi.isPaused() then
        lovemidi.resume()
        print("[MidiPlayerNative] Resumed playback")
    end
end

-- Set volume (0-1)
function MidiPlayerNative:setVolume(volume)
    if not self.available then return end

    self.volume = math.max(0, math.min(1, volume))
    -- Convert to 0-127 range for MIDI
    lovemidi.setVolume(math.floor(self.volume * 127))
    print("[MidiPlayerNative] Volume set to: " .. self.volume)
end

-- Get volume (0-1)
function MidiPlayerNative:getVolume()
    return self.volume
end

-- Update (call each frame)
function MidiPlayerNative:update(dt)
    if not self.available then return end

    -- Check if playback has finished
    if self.isPlaying and not lovemidi.isPlaying() then
        print("[MidiPlayerNative] Playback finished")
        self.isPlaying = false
        lovemidi.closeFile()
        self.currentFile = nil
    end
end

-- Get playback status
function MidiPlayerNative:getIsPlaying()
    if not self.available then return false end
    return lovemidi.isPlaying()
end

-- Get playback position in seconds
function MidiPlayerNative:getPosition()
    if not self.available then return 0 end
    return lovemidi.getPosition()
end

-- Get total length in seconds
function MidiPlayerNative:getLength()
    if not self.available then return 0 end
    return lovemidi.getLength()
end

-- Seek to position in seconds
function MidiPlayerNative:setPosition(seconds)
    if not self.available then return end
    lovemidi.setPosition(seconds)
end

-- Initialize on module load
MidiPlayerNative:init()

return MidiPlayerNative

