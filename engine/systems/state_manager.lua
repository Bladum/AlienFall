-- State Manager
-- Handles switching between game states (menu, geoscape, battlescape, basescape)

local StateManager = {}

-- Current active state
StateManager.current = nil
StateManager.states = {}

-- Register a new state
function StateManager.register(name, state)
    StateManager.states[name] = state
    print("[StateManager] Registered state: " .. name .. " (total states: " .. StateManager.countStates() .. ")")
end

-- Switch to a different state
function StateManager.switch(name, ...)
    print("[StateManager] Attempting to switch to: " .. name)
    local stateNames = StateManager.getStateNames()
    print("[StateManager] Available states: " .. table.concat(stateNames, ", "))
    
    if not StateManager.states[name] then
        print("[StateManager] ERROR: State '" .. name .. "' not found in states table")
        print("[StateManager] States table contents:")
        for k, v in pairs(StateManager.states) do
            print("  " .. k .. " = " .. tostring(v))
        end
        error("[StateManager] State '" .. name .. "' does not exist!")
    end
    
    -- Call exit on current state if it exists
    if StateManager.current and StateManager.current.exit then
        StateManager.current:exit()
    end
    
    -- Switch to new state
    StateManager.current = StateManager.states[name]
    print("[StateManager] Switched to state: " .. name)
    
    -- Call enter on new state if it exists
    if StateManager.current.enter then
        StateManager.current:enter(...)
    end
end

-- Update current state
function StateManager.update(dt)
    if StateManager.current and StateManager.current.update then
        StateManager.current:update(dt)
    end
end

-- Draw current state
function StateManager.draw()
    if StateManager.current and StateManager.current.draw then
        StateManager.current:draw()
    end
end

-- Forward keyboard input to current state
function StateManager.keypressed(key, scancode, isrepeat)
    if StateManager.current and StateManager.current.keypressed then
        StateManager.current:keypressed(key, scancode, isrepeat)
    end
end

-- Forward mouse press to current state
function StateManager.mousepressed(x, y, button, istouch, presses)
    if StateManager.current and StateManager.current.mousepressed then
        StateManager.current:mousepressed(x, y, button, istouch, presses)
    end
end

-- Forward mouse release to current state
function StateManager.mousereleased(x, y, button, istouch, presses)
    if StateManager.current and StateManager.current.mousereleased then
        StateManager.current:mousereleased(x, y, button, istouch, presses)
    end
end

-- Forward mouse movement to current state
function StateManager.mousemoved(x, y, dx, dy, istouch)
    if StateManager.current and StateManager.current.mousemoved then
        StateManager.current:mousemoved(x, y, dx, dy, istouch)
    end
end

-- Forward mouse wheel to current state
function StateManager.wheelmoved(x, y)
    if StateManager.current and StateManager.current.wheelmoved then
        StateManager.current:wheelmoved(x, y)
    end
end

-- Get list of state names (for debugging)
function StateManager.getStateNames()
    local names = {}
    for name, _ in pairs(StateManager.states) do
        table.insert(names, name)
    end
    return names
end

-- Count states (for debugging)
function StateManager.countStates()
    local count = 0
    for _ in pairs(StateManager.states) do
        count = count + 1
    end
    return count
end

return StateManager
