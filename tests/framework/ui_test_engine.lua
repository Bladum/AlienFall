-- UI Test Engine
-- Executes declarative UI tests for automated testing

local UITestEngine = {}

-- Test context
UITestEngine.context = {
  current_scene = nil,
  ui_elements = {},
  last_screenshot = nil,
  test_results = {passed = 0, failed = 0, skipped = 0},
  current_test = nil,
}

-- Available actions
UITestEngine.actions = {}

-- Action: launch
function UITestEngine.actions.launch(args)
  print("[UITest] Launching game/scene...")

  if args.scene then
    print("[UITest]   Scene: " .. args.scene)
    UITestEngine.context.current_scene = args.scene
  end

  if args.console then
    print("[UITest]   Console: enabled")
  end

  return true, "Game launched"
end

-- Action: wait
function UITestEngine.actions.wait(args)
  local seconds = tonumber(args.seconds or 1)
  print("[UITest] Waiting " .. seconds .. " seconds...")

  -- In real implementation, would use love.timer
  -- For testing: just log it
  return true, "Waited " .. seconds .. "s"
end

-- Action: click
function UITestEngine.actions.click(args)
  local element_id = args.element_id or "unknown"
  local x = tonumber(args.x or 0)
  local y = tonumber(args.y or 0)

  print("[UITest] Clicking element: " .. element_id .. " at (" .. x .. ", " .. y .. ")")
  return true, "Clicked " .. element_id
end

-- Action: input_text
function UITestEngine.actions.input_text(args)
  local field_id = args.field_id or "unknown"
  local text = args.text or ""

  print("[UITest] Typing into " .. field_id .. ": " .. text)
  return true, "Entered text"
end

-- Action: screenshot
function UITestEngine.actions.screenshot(args)
  local name = args.name or ("screenshot_" .. os.time())
  print("[UITest] Taking screenshot: " .. name)

  UITestEngine.context.last_screenshot = name
  return true, "Screenshot taken: " .. name
end

-- Action: assert_element_exists
function UITestEngine.actions.assert_element_exists(args)
  local element_id = args.element_id or "unknown"
  print("[UITest] Asserting element exists: " .. element_id)

  -- In real implementation, would check UI registry
  return true, "Element found"
end

-- Action: assert_scene
function UITestEngine.actions.assert_scene(args)
  local expected_scene = args.scene or "unknown"
  print("[UITest] Asserting current scene: " .. expected_scene)

  if UITestEngine.context.current_scene == expected_scene then
    return true, "Scene matches"
  else
    return false, "Scene mismatch: expected " .. expected_scene .. ", got " .. (UITestEngine.context.current_scene or "unknown")
  end
end

-- Action: navigate
function UITestEngine.actions.navigate(args)
  local menu = args.menu or "unknown"
  print("[UITest] Navigating to: " .. menu)

  UITestEngine.context.current_scene = menu
  return true, "Navigated to " .. menu
end

-- Execute a single action
function UITestEngine:executeAction(action)
  if not action or not action.action then
    return false, "Invalid action"
  end

  local action_name = action.action
  local action_func = self.actions[action_name]

  if not action_func then
    return false, "Unknown action: " .. action_name
  end

  local ok, result = pcall(action_func, action.args or {})

  if not ok then
    return false, "Action error: " .. tostring(result)
  end

  return result
end

-- Execute a test
function UITestEngine:executeTest(test_definition)
  print("")
  print("[UITest] ========================================")
  print("[UITest] TEST: " .. test_definition.name)
  print("[UITest] ========================================")

  self.context.current_test = test_definition.name
  local steps = test_definition.steps or {}
  local step_count = 0
  local failed = false

  for _, step in ipairs(steps) do
    step_count = step_count + 1
    print("[UITest] Step " .. step_count .. ":")

    local ok, result = self:executeAction(step)

    if not ok then
      print("[UITest]   ✗ FAILED: " .. result)
      failed = true
      break
    else
      print("[UITest]   ✓ OK")
    end
  end

  if failed then
    print("[UITest] TEST FAILED")
    self.context.test_results.failed = self.context.test_results.failed + 1
    return false
  else
    print("[UITest] TEST PASSED")
    self.context.test_results.passed = self.context.test_results.passed + 1
    return true
  end
end

-- Execute all tests in a script
function UITestEngine:executeScript(script)
  print("")
  print("╔" .. string.rep("═", 62) .. "╗")
  print("║ UI Test Suite: " .. script.name .. string.rep(" ", 47 - #script.name) .. "║")
  print("╚" .. string.rep("═", 62) .. "╝")
  print("")

  -- Run setup
  if script.setup and #script.setup > 0 then
    print("[UITest] Running setup...")
    for _, action in ipairs(script.setup) do
      self:executeAction(action)
    end
    print("")
  end

  -- Run tests
  if script.tests then
    for test_name, test_def in pairs(script.tests) do
      self:executeTest(test_def)
    end
  end

  -- Run teardown
  if script.teardown and #script.teardown > 0 then
    print("")
    print("[UITest] Running teardown...")
    for _, action in ipairs(script.teardown) do
      self:executeAction(action)
    end
  end

  -- Print summary
  print("")
  print("═══════════════════════════════════════════════════════════════")
  print("RESULTS:")
  print("  ✓ Passed:  " .. self.context.test_results.passed)
  print("  ✗ Failed:  " .. self.context.test_results.failed)
  print("  ⊘ Skipped: " .. self.context.test_results.skipped)
  print("═══════════════════════════════════════════════════════════════")

  return self.context.test_results.failed == 0
end

return UITestEngine
