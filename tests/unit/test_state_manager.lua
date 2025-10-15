-- Unit Tests for State Manager
-- Tests state transitions, screen management, and state stack operations

local StateManagerTest = {}

-- Mock state for testing
local MockState = {}
MockState.__index = MockState

function MockState.new(name)
    local self = setmetatable({}, MockState)
    self.name = name
    self.loaded = false
    self.entered = false
    self.exited = false
    self.updateCalled = false
    self.drawCalled = false
    return self
end

function MockState:load()
    self.loaded = true
    print("[MockState] " .. self.name .. " loaded")
end

function MockState:enter()
    self.entered = true
    print("[MockState] " .. self.name .. " entered")
end

function MockState:exit()
    self.exited = true
    print("[MockState] " .. self.name .. " exited")
end

function MockState:update(dt)
    self.updateCalled = true
end

function MockState:draw()
    self.drawCalled = true
end

-- Test state registration
function StateManagerTest.testRegisterState()
    local StateManager = require("core.state_manager")
    StateManager.reset() -- Clear any existing states
    
    local testState = MockState.new("TestState")
    StateManager.register("test", testState)
    
    assert(StateManager.states.test ~= nil, "State not registered")
    assert(StateManager.states.test == testState, "Wrong state registered")
    
    print("✓ testRegisterState passed")
end

-- Test state switching
function StateManagerTest.testSwitchState()
    local StateManager = require("core.state_manager")
    StateManager.reset()
    
    local state1 = MockState.new("State1")
    local state2 = MockState.new("State2")
    
    StateManager.register("state1", state1)
    StateManager.register("state2", state2)
    
    -- Switch to state1
    StateManager.switch("state1")
    assert(StateManager.current == state1, "State1 not current")
    assert(state1.entered == true, "State1 not entered")
    
    -- Switch to state2
    StateManager.switch("state2")
    assert(StateManager.current == state2, "State2 not current")
    assert(state1.exited == true, "State1 not exited")
    assert(state2.entered == true, "State2 not entered")
    
    print("✓ testSwitchState passed")
end

-- Test state push/pop
function StateManagerTest.testPushPopState()
    local StateManager = require("core.state_manager")
    StateManager.reset()
    
    local state1 = MockState.new("State1")
    local state2 = MockState.new("State2")
    
    StateManager.register("state1", state1)
    StateManager.register("state2", state2)
    
    -- Start with state1
    StateManager.switch("state1")
    
    -- Push state2
    StateManager.push("state2")
    assert(StateManager.current == state2, "State2 not current after push")
    assert(#StateManager.stack == 2, "Stack size incorrect after push")
    
    -- Pop state2
    StateManager.pop()
    assert(StateManager.current == state1, "State1 not restored after pop")
    assert(#StateManager.stack == 1, "Stack size incorrect after pop")
    
    print("✓ testPushPopState passed")
end

-- Test update and draw forwarding
function StateManagerTest.testUpdateDraw()
    local StateManager = require("core.state_manager")
    StateManager.reset()
    
    local state = MockState.new("TestState")
    StateManager.register("test", state)
    StateManager.switch("test")
    
    -- Test update
    StateManager.update(0.016)
    assert(state.updateCalled == true, "Update not called")
    
    -- Test draw
    StateManager.draw()
    assert(state.drawCalled == true, "Draw not called")
    
    print("✓ testUpdateDraw passed")
end

-- Test invalid state handling
function StateManagerTest.testInvalidState()
    local StateManager = require("core.state_manager")
    StateManager.reset()
    
    local success, err = pcall(function()
        StateManager.switch("nonexistent")
    end)
    
    assert(not success, "Should fail on nonexistent state")
    
    print("✓ testInvalidState passed")
end

-- Test state with data passing
function StateManagerTest.testStateData()
    local StateManager = require("core.state_manager")
    StateManager.reset()
    
    local state = MockState.new("DataState")
    state.receivedData = nil
    state.enter = function(self, data)
        self.entered = true
        self.receivedData = data
    end
    
    StateManager.register("data", state)
    StateManager.switch("data", {testValue = 42})
    
    assert(state.receivedData ~= nil, "Data not passed")
    assert(state.receivedData.testValue == 42, "Incorrect data value")
    
    print("✓ testStateData passed")
end

-- Run all tests
function StateManagerTest.runAll()
    print("\n=== State Manager Tests ===")
    
    StateManagerTest.testRegisterState()
    StateManagerTest.testSwitchState()
    StateManagerTest.testPushPopState()
    StateManagerTest.testUpdateDraw()
    StateManagerTest.testInvalidState()
    StateManagerTest.testStateData()
    
    print("✓ All State Manager tests passed!\n")
end

return StateManagerTest
