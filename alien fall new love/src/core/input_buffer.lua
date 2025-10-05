--- Input Buffer System
-- Prevents missed inputs during lag spikes by buffering input events
-- Processes buffered inputs during update loop to ensure no input is lost

local class = require('lib.middleclass')

---@class InputBuffer
---@field private _keyboardBuffer table Buffer for keyboard events
---@field private _mouseBuffer table Buffer for mouse events
---@field private _maxBufferSize number Maximum buffer size
---@field private _inputAge table Age tracking for inputs
---@field private _maxInputAge number Maximum age before input expires
local InputBuffer = class('InputBuffer')

-- Constants
local DEFAULT_MAX_BUFFER_SIZE = 100
local DEFAULT_MAX_INPUT_AGE = 1.0 -- seconds
local INPUT_PRIORITY = {
    HIGH = 1,
    NORMAL = 2,
    LOW = 3
}

---Initialize input buffer
---@param config table Configuration options
function InputBuffer:initialize(config)
    config = config or {}
    
    self._maxBufferSize = config.maxBufferSize or DEFAULT_MAX_BUFFER_SIZE
    self._maxInputAge = config.maxInputAge or DEFAULT_MAX_INPUT_AGE
    
    -- Separate buffers for different input types
    self._keyboardBuffer = {}
    self._mouseBuffer = {}
    self._inputAge = {}
    
    -- Statistics
    self._stats = {
        totalBuffered = 0,
        totalProcessed = 0,
        totalDropped = 0,
        currentBufferSize = 0
    }
end

---Buffer a keyboard event
---@param eventType string Event type ("keypressed", "keyreleased", "textinput")
---@param key string Key name
---@param scancode string Scancode (optional)
---@param isrepeat boolean Is key repeat (optional)
---@param priority number Priority level (optional, default NORMAL)
function InputBuffer:bufferKeyboard(eventType, key, scancode, isrepeat, priority)
    if #self._keyboardBuffer >= self._maxBufferSize then
        -- Buffer full - drop oldest low priority input
        self:_dropOldestLowPriority(self._keyboardBuffer)
    end
    
    local input = {
        type = "keyboard",
        eventType = eventType,
        key = key,
        scancode = scancode,
        isrepeat = isrepeat or false,
        priority = priority or INPUT_PRIORITY.NORMAL,
        timestamp = love.timer.getTime()
    }
    
    table.insert(self._keyboardBuffer, input)
    self._stats.totalBuffered = self._stats.totalBuffered + 1
    self._stats.currentBufferSize = self._stats.currentBufferSize + 1
end

---Buffer a mouse event
---@param eventType string Event type ("mousepressed", "mousereleased", "mousemoved", "wheelmoved")
---@param x number Mouse X coordinate
---@param y number Mouse Y coordinate
---@param button number Mouse button (optional)
---@param istouch boolean Is touch event (optional)
---@param dx number Delta X for moved/wheel events (optional)
---@param dy number Delta Y for moved/wheel events (optional)
---@param priority number Priority level (optional, default NORMAL)
function InputBuffer:bufferMouse(eventType, x, y, button, istouch, dx, dy, priority)
    if #self._mouseBuffer >= self._maxBufferSize then
        -- Buffer full - drop oldest low priority input
        self:_dropOldestLowPriority(self._mouseBuffer)
    end
    
    local input = {
        type = "mouse",
        eventType = eventType,
        x = x,
        y = y,
        button = button,
        istouch = istouch or false,
        dx = dx,
        dy = dy,
        priority = priority or INPUT_PRIORITY.NORMAL,
        timestamp = love.timer.getTime()
    }
    
    table.insert(self._mouseBuffer, input)
    self._stats.totalBuffered = self._stats.totalBuffered + 1
    self._stats.currentBufferSize = self._stats.currentBufferSize + 1
end

---Drop oldest low priority input from buffer
---@param buffer table Buffer to drop from
function InputBuffer:_dropOldestLowPriority(buffer)
    -- Find oldest low priority input
    local oldestIndex = nil
    local oldestTime = math.huge
    
    for i, input in ipairs(buffer) do
        if input.priority == INPUT_PRIORITY.LOW and input.timestamp < oldestTime then
            oldestTime = input.timestamp
            oldestIndex = i
        end
    end
    
    -- If no low priority, drop oldest normal priority
    if not oldestIndex then
        for i, input in ipairs(buffer) do
            if input.priority == INPUT_PRIORITY.NORMAL and input.timestamp < oldestTime then
                oldestTime = input.timestamp
                oldestIndex = i
            end
        end
    end
    
    -- Drop the oldest (never drop high priority)
    if oldestIndex then
        table.remove(buffer, oldestIndex)
        self._stats.totalDropped = self._stats.totalDropped + 1
        self._stats.currentBufferSize = self._stats.currentBufferSize - 1
    end
end

---Process buffered inputs
---@param dt number Delta time
---@param handler table Input handler with callback methods
function InputBuffer:process(dt, handler)
    if not handler then return end
    
    local currentTime = love.timer.getTime()
    
    -- Process keyboard buffer
    for i = #self._keyboardBuffer, 1, -1 do
        local input = self._keyboardBuffer[i]
        
        -- Check if input has expired
        if (currentTime - input.timestamp) > self._maxInputAge then
            table.remove(self._keyboardBuffer, i)
            self._stats.totalDropped = self._stats.totalDropped + 1
            self._stats.currentBufferSize = self._stats.currentBufferSize - 1
        else
            -- Process input
            if input.eventType == "keypressed" and handler.keypressed then
                handler:keypressed(input.key, input.scancode, input.isrepeat)
            elseif input.eventType == "keyreleased" and handler.keyreleased then
                handler:keyreleased(input.key, input.scancode)
            elseif input.eventType == "textinput" and handler.textinput then
                handler:textinput(input.key)
            end
            
            table.remove(self._keyboardBuffer, i)
            self._stats.totalProcessed = self._stats.totalProcessed + 1
            self._stats.currentBufferSize = self._stats.currentBufferSize - 1
        end
    end
    
    -- Process mouse buffer
    for i = #self._mouseBuffer, 1, -1 do
        local input = self._mouseBuffer[i]
        
        -- Check if input has expired
        if (currentTime - input.timestamp) > self._maxInputAge then
            table.remove(self._mouseBuffer, i)
            self._stats.totalDropped = self._stats.totalDropped + 1
            self._stats.currentBufferSize = self._stats.currentBufferSize - 1
        else
            -- Process input
            if input.eventType == "mousepressed" and handler.mousepressed then
                handler:mousepressed(input.x, input.y, input.button, input.istouch)
            elseif input.eventType == "mousereleased" and handler.mousereleased then
                handler:mousereleased(input.x, input.y, input.button, input.istouch)
            elseif input.eventType == "mousemoved" and handler.mousemoved then
                handler:mousemoved(input.x, input.y, input.dx, input.dy, input.istouch)
            elseif input.eventType == "wheelmoved" and handler.wheelmoved then
                handler:wheelmoved(input.dx, input.dy)
            end
            
            table.remove(self._mouseBuffer, i)
            self._stats.totalProcessed = self._stats.totalProcessed + 1
            self._stats.currentBufferSize = self._stats.currentBufferSize - 1
        end
    end
end

---Clear all buffered inputs
function InputBuffer:clear()
    self._keyboardBuffer = {}
    self._mouseBuffer = {}
    self._stats.currentBufferSize = 0
end

---Clear keyboard buffer only
function InputBuffer:clearKeyboard()
    local count = #self._keyboardBuffer
    self._keyboardBuffer = {}
    self._stats.currentBufferSize = self._stats.currentBufferSize - count
end

---Clear mouse buffer only
function InputBuffer:clearMouse()
    local count = #self._mouseBuffer
    self._mouseBuffer = {}
    self._stats.currentBufferSize = self._stats.currentBufferSize - count
end

---Get buffer statistics
---@return table stats Buffer statistics
function InputBuffer:getStatistics()
    return {
        totalBuffered = self._stats.totalBuffered,
        totalProcessed = self._stats.totalProcessed,
        totalDropped = self._stats.totalDropped,
        currentBufferSize = self._stats.currentBufferSize,
        keyboardBufferSize = #self._keyboardBuffer,
        mouseBufferSize = #self._mouseBuffer,
        dropRate = self._stats.totalDropped / math.max(1, self._stats.totalBuffered)
    }
end

---Print buffer statistics to console
function InputBuffer:printStatistics()
    local stats = self:getStatistics()
    
    print("=== Input Buffer Statistics ===")
    print(string.format("Total Buffered: %d", stats.totalBuffered))
    print(string.format("Total Processed: %d", stats.totalProcessed))
    print(string.format("Total Dropped: %d", stats.totalDropped))
    print(string.format("Current Buffer: %d (Keyboard: %d, Mouse: %d)", 
        stats.currentBufferSize, stats.keyboardBufferSize, stats.mouseBufferSize))
    print(string.format("Drop Rate: %.1f%%", stats.dropRate * 100))
    print("================================")
end

---Get input priority constants
---@return table priorities Priority constants
function InputBuffer.getPriorities()
    return INPUT_PRIORITY
end

return InputBuffer
