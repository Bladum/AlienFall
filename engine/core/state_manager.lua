--- State Manager
--- Handles switching between game states (menu, geoscape, battlescape, basescape).
---
--- This module manages the game's state machine, allowing transition between
--- different screens/modes. Each state is a table with optional callbacks:
--- enter(...), exit(), update(dt), draw(), keypressed(), mousepressed(), etc.
---
--- Example usage:
---   local StateManager = require("core.state_manager")
---   StateManager.register("menu", MenuState)
---   StateManager.switch("menu")
---
--- State Interface:
---   - enter(...): Called when entering state (receives switch args)
---   - exit(): Called when leaving state
---   - update(dt): Called every frame with delta time
---   - draw(): Called to render state
---   - keypressed(key, scancode, isrepeat): Keyboard input
---   - mousepressed(x, y, button, istouch, presses): Mouse button down
---   - mousereleased(x, y, button, istouch, presses): Mouse button up
---   - mousemoved(x, y, dx, dy, istouch): Mouse movement
---   - wheelmoved(x, y): Mouse wheel scrolling

--- @class StateManager
--- @field current table|nil Currently active state
--- @field states table Registered state table (name -> state)
local StateManager = {}

-- Current active state
StateManager.current = nil
StateManager.states = {}

--- Register a new state in the state manager.
---
--- Adds a state to the states table so it can be switched to later.
--- Prints debug message with state name and total count.
---
--- @param name string Unique identifier for this state
--- @param state table State object with optional callbacks
--- @return nil
function StateManager.register(name, state)
    StateManager.states[name] = state
    print("[StateManager] Registered state: " .. name .. " (total states: " .. StateManager.countStates() .. ")")
end

--- Switch to a different state.
---
--- Calls exit() on current state, switches to new state, then calls
--- enter(...) with any additional arguments. Errors if state not found.
--- Prints debug messages during transition.
---
--- @param name string Name of state to switch to
--- @param ... any Additional arguments passed to new state's enter()
--- @error If state name is not registered
--- @return nil
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

--- Update current state.
---
--- Calls update(dt) callback on active state if it exists.
--- Called every frame from main.lua love.update().
---
--- @param dt number Delta time in seconds since last frame
--- @return nil
function StateManager.update(dt)
    if StateManager.current and StateManager.current.update then
        StateManager.current:update(dt)
    end
end

--- Draw current state.
---
--- Calls draw() callback on active state if it exists.
--- Called every frame from main.lua love.draw().
---
--- @return nil
function StateManager.draw()
    if StateManager.current and StateManager.current.draw then
        StateManager.current:draw()
    end
end

--- Forward keyboard input to current state.
---
--- Calls keypressed() callback on active state if it exists.
--- Called from main.lua love.keypressed().
---
--- @param key string Key identifier (e.g., "space", "escape")
--- @param scancode string Physical key scancode
--- @param isrepeat boolean True if key is being held
--- @return nil
function StateManager.keypressed(key, scancode, isrepeat)
    if StateManager.current and StateManager.current.keypressed then
        StateManager.current:keypressed(key, scancode, isrepeat)
    end
end

--- Forward mouse button press to current state.
---
--- Calls mousepressed() callback on active state if it exists.
--- Called from main.lua love.mousepressed().
---
--- @param x number Mouse X coordinate in pixels
--- @param y number Mouse Y coordinate in pixels
--- @param button number Mouse button (1=left, 2=right, 3=middle)
--- @param istouch boolean True if touch event
--- @param presses number Number of consecutive presses
--- @return nil
function StateManager.mousepressed(x, y, button, istouch, presses)
    if StateManager.current and StateManager.current.mousepressed then
        StateManager.current:mousepressed(x, y, button, istouch, presses)
    end
end

--- Forward mouse button release to current state.
---
--- Calls mousereleased() callback on active state if it exists.
--- Called from main.lua love.mousereleased().
---
--- @param x number Mouse X coordinate in pixels
--- @param y number Mouse Y coordinate in pixels
--- @param button number Mouse button (1=left, 2=right, 3=middle)
--- @param istouch boolean True if touch event
--- @param presses number Number of consecutive presses
--- @return nil
function StateManager.mousereleased(x, y, button, istouch, presses)
    if StateManager.current and StateManager.current.mousereleased then
        StateManager.current:mousereleased(x, y, button, istouch, presses)
    end
end

--- Forward mouse movement to current state.
---
--- Calls mousemoved() callback on active state if it exists.
--- Called from main.lua love.mousemoved().
---
--- @param x number Current mouse X coordinate in pixels
--- @param y number Current mouse Y coordinate in pixels
--- @param dx number Change in X since last movement
--- @param dy number Change in Y since last movement
--- @param istouch boolean True if touch event
--- @return nil
function StateManager.mousemoved(x, y, dx, dy, istouch)
    if StateManager.current and StateManager.current.mousemoved then
        StateManager.current:mousemoved(x, y, dx, dy, istouch)
    end
end

--- Forward mouse wheel scrolling to current state.
---
--- Calls wheelmoved() callback on active state if it exists.
--- Called from main.lua love.wheelmoved().
---
--- @param x number Horizontal scroll amount
--- @param y number Vertical scroll amount
--- @return nil
function StateManager.wheelmoved(x, y)
    if StateManager.current and StateManager.current.wheelmoved then
        StateManager.current:wheelmoved(x, y)
    end
end

--- Get list of registered state names.
---
--- Returns array of all state names for debugging and diagnostics.
--- Used during state switching to show available states.
---
--- @return table Array of state name strings
function StateManager.getStateNames()
    local names = {}
    for name, _ in pairs(StateManager.states) do
        table.insert(names, name)
    end
    return names
end

--- Count number of registered states.
---
--- Returns total number of states in the states table.
--- Used for debug messages during state registration.
---
--- @return number Total state count
function StateManager.countStates()
    local count = 0
    for _ in pairs(StateManager.states) do
        count = count + 1
    end
    return count
end

return StateManager
