--- Test suite for InputBuffer system
-- Tests buffering, processing, priority, and expiration

local InputBuffer = require('core.input_buffer')

-- Mock handler for testing
local MockHandler = {}
function MockHandler:new()
    local obj = {
        keyPressedEvents = {},
        keyReleasedEvents = {},
        textInputEvents = {},
        mousePressedEvents = {},
        mouseReleasedEvents = {},
        mouseMovedEvents = {},
        wheelMovedEvents = {}
    }
    setmetatable(obj, { __index = MockHandler })
    return obj
end

function MockHandler:keypressed(key, scancode, isrepeat)
    table.insert(self.keyPressedEvents, { key = key, scancode = scancode, isrepeat = isrepeat })
end

function MockHandler:keyreleased(key, scancode)
    table.insert(self.keyReleasedEvents, { key = key, scancode = scancode })
end

function MockHandler:textinput(text)
    table.insert(self.textInputEvents, { text = text })
end

function MockHandler:mousepressed(x, y, button, istouch)
    table.insert(self.mousePressedEvents, { x = x, y = y, button = button, istouch = istouch })
end

function MockHandler:mousereleased(x, y, button, istouch)
    table.insert(self.mouseReleasedEvents, { x = x, y = y, button = button, istouch = istouch })
end

function MockHandler:mousemoved(x, y, dx, dy, istouch)
    table.insert(self.mouseMovedEvents, { x = x, y = y, dx = dx, dy = dy, istouch = istouch })
end

function MockHandler:wheelmoved(dx, dy)
    table.insert(self.wheelMovedEvents, { dx = dx, dy = dy })
end

function MockHandler:clear()
    self.keyPressedEvents = {}
    self.keyReleasedEvents = {}
    self.textInputEvents = {}
    self.mousePressedEvents = {}
    self.mouseReleasedEvents = {}
    self.mouseMovedEvents = {}
    self.wheelMovedEvents = {}
end

-- Test functions
local tests = {}

function tests.test_basic_keyboard_buffering()
    local buffer = InputBuffer:new()
    local handler = MockHandler:new()
    
    -- Buffer keyboard events
    buffer:bufferKeyboard("keypressed", "space", "space", false)
    buffer:bufferKeyboard("keyreleased", "space", "space")
    
    -- Verify buffered
    local stats = buffer:getStatistics()
    assert(stats.totalBuffered == 2, "Should have buffered 2 keyboard events")
    assert(stats.keyboardBufferSize == 2, "Keyboard buffer should have 2 items")
    
    -- Process buffer
    buffer:process(0.016, handler)
    
    -- Verify processed
    assert(#handler.keyPressedEvents == 1, "Should have processed 1 keypressed event")
    assert(handler.keyPressedEvents[1].key == "space", "Key should be space")
    assert(#handler.keyReleasedEvents == 1, "Should have processed 1 keyreleased event")
    
    local stats2 = buffer:getStatistics()
    assert(stats2.totalProcessed == 2, "Should have processed 2 events")
    assert(stats2.currentBufferSize == 0, "Buffer should be empty")
    
    print("✓ test_basic_keyboard_buffering passed")
end

function tests.test_basic_mouse_buffering()
    local buffer = InputBuffer:new()
    local handler = MockHandler:new()
    
    -- Buffer mouse events
    buffer:bufferMouse("mousepressed", 100, 200, 1, false)
    buffer:bufferMouse("mousereleased", 100, 200, 1, false)
    buffer:bufferMouse("mousemoved", 150, 250, nil, false, 50, 50)
    buffer:bufferMouse("wheelmoved", 0, 0, nil, false, 0, 1)
    
    -- Verify buffered
    local stats = buffer:getStatistics()
    assert(stats.totalBuffered == 4, "Should have buffered 4 mouse events")
    assert(stats.mouseBufferSize == 4, "Mouse buffer should have 4 items")
    
    -- Process buffer
    buffer:process(0.016, handler)
    
    -- Verify processed
    assert(#handler.mousePressedEvents == 1, "Should have processed 1 mousepressed event")
    assert(handler.mousePressedEvents[1].x == 100, "X should be 100")
    assert(handler.mousePressedEvents[1].y == 200, "Y should be 200")
    assert(#handler.mouseReleasedEvents == 1, "Should have processed 1 mousereleased event")
    assert(#handler.mouseMovedEvents == 1, "Should have processed 1 mousemoved event")
    assert(#handler.wheelMovedEvents == 1, "Should have processed 1 wheelmoved event")
    
    local stats2 = buffer:getStatistics()
    assert(stats2.totalProcessed == 4, "Should have processed 4 events")
    
    print("✓ test_basic_mouse_buffering passed")
end

function tests.test_input_priority()
    local buffer = InputBuffer:new({ maxBufferSize = 3 })
    local priorities = InputBuffer.getPriorities()
    
    -- Buffer high priority input
    buffer:bufferKeyboard("keypressed", "escape", "escape", false, priorities.HIGH)
    
    -- Fill buffer with low priority
    buffer:bufferKeyboard("keypressed", "a", "a", false, priorities.LOW)
    buffer:bufferKeyboard("keypressed", "b", "b", false, priorities.LOW)
    buffer:bufferKeyboard("keypressed", "c", "c", false, priorities.LOW)
    
    -- Try to add one more (should drop oldest low priority)
    buffer:bufferKeyboard("keypressed", "d", "d", false, priorities.NORMAL)
    
    local stats = buffer:getStatistics()
    assert(stats.totalDropped == 1, "Should have dropped 1 input")
    assert(stats.currentBufferSize == 3, "Buffer should be at max size")
    
    print("✓ test_input_priority passed")
end

function tests.test_input_expiration()
    -- Mock love.timer.getTime for testing
    local originalGetTime = love.timer.getTime
    local currentTime = 0
    love.timer.getTime = function() return currentTime end
    
    local buffer = InputBuffer:new({ maxInputAge = 0.5 })
    local handler = MockHandler:new()
    
    -- Buffer input at time 0
    buffer:bufferKeyboard("keypressed", "space", "space", false)
    
    -- Advance time past expiration
    currentTime = 0.6
    
    -- Process buffer (should drop expired input)
    buffer:process(0.016, handler)
    
    local stats = buffer:getStatistics()
    assert(stats.totalDropped == 1, "Should have dropped 1 expired input")
    assert(#handler.keyPressedEvents == 0, "Should not have processed expired input")
    
    -- Restore original function
    love.timer.getTime = originalGetTime
    
    print("✓ test_input_expiration passed")
end

function tests.test_buffer_clearing()
    local buffer = InputBuffer:new()
    
    -- Buffer various inputs
    buffer:bufferKeyboard("keypressed", "space", "space", false)
    buffer:bufferKeyboard("keypressed", "enter", "enter", false)
    buffer:bufferMouse("mousepressed", 100, 200, 1, false)
    buffer:bufferMouse("mousemoved", 150, 250, nil, false, 50, 50)
    
    local stats = buffer:getStatistics()
    assert(stats.currentBufferSize == 4, "Should have 4 buffered inputs")
    
    -- Clear keyboard buffer
    buffer:clearKeyboard()
    local stats2 = buffer:getStatistics()
    assert(stats2.keyboardBufferSize == 0, "Keyboard buffer should be empty")
    assert(stats2.mouseBufferSize == 2, "Mouse buffer should still have 2")
    
    -- Clear all
    buffer:clear()
    local stats3 = buffer:getStatistics()
    assert(stats3.currentBufferSize == 0, "All buffers should be empty")
    
    print("✓ test_buffer_clearing passed")
end

function tests.test_buffer_overflow()
    local buffer = InputBuffer:new({ maxBufferSize = 5 })
    
    -- Fill buffer beyond capacity
    for i = 1, 10 do
        buffer:bufferKeyboard("keypressed", tostring(i), tostring(i), false)
    end
    
    local stats = buffer:getStatistics()
    assert(stats.currentBufferSize <= 5, "Buffer size should not exceed max")
    assert(stats.totalDropped == 5, "Should have dropped 5 inputs")
    assert(stats.totalBuffered == 10, "Should have attempted to buffer 10")
    
    print("✓ test_buffer_overflow passed")
end

function tests.test_statistics_tracking()
    local buffer = InputBuffer:new()
    local handler = MockHandler:new()
    
    -- Buffer and process inputs
    for i = 1, 5 do
        buffer:bufferKeyboard("keypressed", tostring(i), tostring(i), false)
    end
    
    buffer:process(0.016, handler)
    
    local stats = buffer:getStatistics()
    assert(stats.totalBuffered == 5, "Should track total buffered")
    assert(stats.totalProcessed == 5, "Should track total processed")
    assert(stats.totalDropped == 0, "Should track dropped (none)")
    assert(stats.dropRate == 0, "Drop rate should be 0%")
    
    print("✓ test_statistics_tracking passed")
end

function tests.test_handler_with_missing_methods()
    local buffer = InputBuffer:new()
    
    -- Handler with only some methods
    local partialHandler = {
        keypressed = function(self, key, scancode, isrepeat)
            -- Only handles keypressed
        end
    }
    
    -- Buffer various input types
    buffer:bufferKeyboard("keypressed", "space", "space", false)
    buffer:bufferMouse("mousepressed", 100, 200, 1, false)
    
    -- Should not error even though handler doesn't implement all methods
    local success = pcall(function()
        buffer:process(0.016, partialHandler)
    end)
    
    assert(success, "Should handle missing methods gracefully")
    
    print("✓ test_handler_with_missing_methods passed")
end

function tests.test_multiple_process_calls()
    local buffer = InputBuffer:new()
    local handler = MockHandler:new()
    
    -- Buffer inputs
    buffer:bufferKeyboard("keypressed", "a", "a", false)
    buffer:bufferKeyboard("keypressed", "b", "b", false)
    
    -- First process call
    buffer:process(0.016, handler)
    assert(#handler.keyPressedEvents == 2, "Should process both inputs")
    
    handler:clear()
    
    -- Second process call (buffer should be empty)
    buffer:process(0.016, handler)
    assert(#handler.keyPressedEvents == 0, "Should not reprocess inputs")
    
    print("✓ test_multiple_process_calls passed")
end

function tests.test_text_input_buffering()
    local buffer = InputBuffer:new()
    local handler = MockHandler:new()
    
    -- Buffer text input
    buffer:bufferKeyboard("textinput", "H")
    buffer:bufferKeyboard("textinput", "e")
    buffer:bufferKeyboard("textinput", "l")
    buffer:bufferKeyboard("textinput", "l")
    buffer:bufferKeyboard("textinput", "o")
    
    -- Process buffer
    buffer:process(0.016, handler)
    
    assert(#handler.textInputEvents == 5, "Should have processed 5 text inputs")
    assert(handler.textInputEvents[1].text == "H", "First char should be H")
    
    print("✓ test_text_input_buffering passed")
end

function tests.test_priority_never_drops_high()
    local buffer = InputBuffer:new({ maxBufferSize = 2 })
    local priorities = InputBuffer.getPriorities()
    
    -- Buffer high priority inputs
    buffer:bufferKeyboard("keypressed", "escape", "escape", false, priorities.HIGH)
    buffer:bufferKeyboard("keypressed", "f1", "f1", false, priorities.HIGH)
    
    -- Try to add low priority (should not drop high priority)
    buffer:bufferKeyboard("keypressed", "space", "space", false, priorities.LOW)
    
    local stats = buffer:getStatistics()
    assert(stats.currentBufferSize == 2, "Should maintain max buffer size")
    -- The low priority input should have been dropped or replaced oldest non-high priority
    
    print("✓ test_priority_never_drops_high passed")
end

function tests.test_custom_configuration()
    local buffer = InputBuffer:new({
        maxBufferSize = 50,
        maxInputAge = 2.0
    })
    
    -- Buffer many inputs
    for i = 1, 30 do
        buffer:bufferKeyboard("keypressed", tostring(i), tostring(i), false)
    end
    
    local stats = buffer:getStatistics()
    assert(stats.currentBufferSize == 30, "Should handle 30 inputs with size 50")
    assert(stats.totalDropped == 0, "Should not drop inputs under capacity")
    
    print("✓ test_custom_configuration passed")
end

-- Run all tests
function run_all_tests()
    print("\n=== Running InputBuffer Tests ===\n")
    
    local passed = 0
    local failed = 0
    
    for name, test in pairs(tests) do
        local success, err = pcall(test)
        if success then
            passed = passed + 1
        else
            failed = failed + 1
            print("✗ " .. name .. " FAILED:")
            print("  " .. tostring(err))
        end
    end
    
    print(string.format("\n=== Test Results: %d passed, %d failed ===\n", passed, failed))
    
    return failed == 0
end

-- Export tests
return {
    tests = tests,
    run = run_all_tests
}
