-- Test file for GamepadManager

local GamepadManager = require('core.gamepad_manager')

local TestGamepadManager = {}

function TestGamepadManager.run()
    print("\n=== Testing GamepadManager ===\n")
    
    local manager = GamepadManager:new()
    
    -- Test 1: Initialization
    print("Test 1: Initialization")
    assert(manager ~= nil, "Manager should be created")
    assert(manager.navigation_enabled == true, "Navigation should be enabled by default")
    print("✓ Passed")
    
    -- Test 2: Connection status
    print("\nTest 2: Connection Status")
    local connected = manager:isConnected()
    print("  Gamepad connected: " .. tostring(connected))
    if connected then
        local joystick = manager:getActiveJoystick()
        print("  Active controller: " .. joystick:getName())
    end
    print("✓ Passed")
    
    -- Test 3: Button mapping
    print("\nTest 3: Button Mapping")
    local confirm_button = manager:getButtonMapping('confirm')
    assert(confirm_button == GamepadManager.static.BUTTONS.A, "Confirm should map to A button")
    
    manager:setButtonMapping('test_action', GamepadManager.static.BUTTONS.X)
    assert(manager:getButtonMapping('test_action') == GamepadManager.static.BUTTONS.X, "Custom mapping should work")
    print("✓ Passed")
    
    -- Test 4: Deadzone
    print("\nTest 4: Deadzone Settings")
    manager:setDeadzone(0.3)
    assert(manager:getDeadzone() == 0.3, "Deadzone should be settable")
    manager:setDeadzone(-0.5) -- Should clamp to 0
    assert(manager:getDeadzone() >= 0, "Deadzone should clamp to valid range")
    manager:setDeadzone(1.5) -- Should clamp to 1
    assert(manager:getDeadzone() <= 1, "Deadzone should clamp to valid range")
    print("✓ Passed")
    
    -- Test 5: Navigation enabled/disabled
    print("\nTest 5: Navigation Toggle")
    manager:setNavigationEnabled(false)
    assert(manager:isNavigationEnabled() == false, "Navigation should be disabled")
    manager:setNavigationEnabled(true)
    assert(manager:isNavigationEnabled() == true, "Navigation should be enabled")
    print("✓ Passed")
    
    -- Test 6: Button prompts
    print("\nTest 6: Button Prompts")
    local prompt = manager:getButtonPrompt('confirm')
    if connected then
        assert(prompt ~= nil, "Button prompt should exist for connected controller")
        print("  Confirm button prompt: " .. tostring(prompt))
    end
    print("✓ Passed")
    
    -- Test 7: Save/Load mapping
    print("\nTest 7: Save/Load Mapping")
    manager:setButtonMapping('custom', GamepadManager.static.BUTTONS.Y)
    manager:setDeadzone(0.25)
    
    local saved_data = manager:saveMapping()
    assert(saved_data ~= nil, "Should save mapping data")
    assert(saved_data.button_mapping.custom == GamepadManager.static.BUTTONS.Y, "Custom mapping should be saved")
    assert(saved_data.stick_deadzone == 0.25, "Deadzone should be saved")
    
    manager:setDeadzone(0.5) -- Change it
    manager:loadMapping(saved_data)
    assert(manager:getDeadzone() == 0.25, "Deadzone should be restored")
    assert(manager:getButtonMapping('custom') == GamepadManager.static.BUTTONS.Y, "Custom mapping should be restored")
    print("✓ Passed")
    
    -- Test 8: Update function
    print("\nTest 8: Update Function")
    local direction = manager:update(0.016) -- One frame at 60fps
    print("  Navigation direction: " .. tostring(direction))
    print("✓ Passed")
    
    print("\n=== All GamepadManager tests passed! ===\n")
    return true
end

-- Run tests if executed directly
if ... == nil then
    TestGamepadManager.run()
end

return TestGamepadManager
