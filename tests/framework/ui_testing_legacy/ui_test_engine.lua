-- UI Testing Framework: Core Engine
-- Loads and executes UI test scripts defined in YAML or Lua

local UITestEngine = {}

local testResults = {
    passed = 0,
    failed = 0,
    skipped = 0,
    errors = {}
}

local currentScene = nil
local elementRegistry = {}

---Register a UI element by ID
function UITestEngine.registerElement(id, element, properties)
    elementRegistry[id] = {
        element = element,
        properties = properties or {}
    }
end

---Get element by ID
function UITestEngine.getElement(id)
    return elementRegistry[id]
end

---Find elements by text content
function UITestEngine.findElementsByText(text)
    local results = {}
    for id, entry in pairs(elementRegistry) do
        if entry.properties and entry.properties.text == text then
            table.insert(results, {id = id, entry = entry})
        end
    end
    return results
end

---Find elements by type
function UITestEngine.findElementsByType(elementType)
    local results = {}
    for id, entry in pairs(elementRegistry) do
        if entry.properties and entry.properties.type == elementType then
            table.insert(results, {id = id, entry = entry})
        end
    end
    return results
end

---Set current scene
function UITestEngine.setScene(scene)
    currentScene = scene
end

---Get current scene
function UITestEngine.getScene()
    return currentScene
end

---Click an element by ID
function UITestEngine.clickElement(id)
    local entry = elementRegistry[id]
    if not entry then
        error("Element not found: " .. id)
    end

    if entry.element.click then
        entry.element:click()
    elseif entry.element.onPress then
        entry.element:onPress()
    else
        error("Element does not support clicking: " .. id)
    end
end

---Type text into element
function UITestEngine.inputText(id, text)
    local entry = elementRegistry[id]
    if not entry then
        error("Element not found: " .. id)
    end

    if entry.element.setText then
        entry.element:setText(text)
    elseif entry.element.text then
        entry.element.text = text
    else
        error("Element does not support text input: " .. id)
    end
end

---Assert element exists
function UITestEngine.assertElementExists(id)
    if not elementRegistry[id] then
        error("Element not found: " .. id)
    end
end

---Assert element visible
function UITestEngine.assertElementVisible(id)
    local entry = elementRegistry[id]
    if not entry then
        error("Element not found: " .. id)
    end

    if entry.element.visible == false then
        error("Element not visible: " .. id)
    end
end

---Assert element has text
function UITestEngine.assertElementText(id, expectedText)
    local entry = elementRegistry[id]
    if not entry then
        error("Element not found: " .. id)
    end

    local actualText = entry.element.text or ""
    if actualText ~= expectedText then
        error("Expected text '" .. expectedText .. "', got '" .. actualText .. "'")
    end
end

---Assert current scene
function UITestEngine.assertScene(sceneName)
    if currentScene ~= sceneName then
        error("Expected scene '" .. sceneName .. "', got '" .. currentScene .. "'")
    end
end

---Wait for element
function UITestEngine.waitForElement(id, maxSeconds)
    maxSeconds = maxSeconds or 5
    local endTime = os.clock() + maxSeconds

    while os.clock() < endTime do
        if elementRegistry[id] then
            return true
        end
        -- Small delay to prevent spinning
    end

    error("Timeout waiting for element: " .. id)
end

---Wait for scene
function UITestEngine.waitForScene(sceneName, maxSeconds)
    maxSeconds = maxSeconds or 5
    local endTime = os.clock() + maxSeconds

    while os.clock() < endTime do
        if currentScene == sceneName then
            return true
        end
        -- Small delay
    end

    error("Timeout waiting for scene: " .. sceneName)
end

---Execute test steps
function UITestEngine.executeSteps(steps)
    for i, step in ipairs(steps) do
        local action = step.action
        local args = step.args or {}

        print("[Step " .. i .. "] " .. action)

        if action == "click" then
            UITestEngine.clickElement(args.element_id)
        elseif action == "input_text" then
            UITestEngine.inputText(args.element_id, args.text)
        elseif action == "wait" then
            local seconds = args.seconds or 1
            -- In real implementation, use love.timer or similar
        elseif action == "assert_element_exists" then
            UITestEngine.assertElementExists(args.element_id)
        elseif action == "assert_element_visible" then
            UITestEngine.assertElementVisible(args.element_id)
        elseif action == "assert_text" then
            UITestEngine.assertElementText(args.element_id, args.text)
        elseif action == "assert_scene" then
            UITestEngine.assertScene(args.scene)
        elseif action == "set_scene" then
            UITestEngine.setScene(args.scene)
        else
            error("Unknown action: " .. action)
        end
    end
end

---Run a UI test script
function UITestEngine.runScript(script)
    local testCount = 0

    for _, test in ipairs(script.tests or {}) do
        testCount = testCount + 1
        print("\n[Test " .. testCount .. "] " .. test.name)

        local success, err = pcall(function()
            UITestEngine.executeSteps(test.steps)
        end)

        if success then
            print("✓ " .. test.name .. " PASSED")
            testResults.passed = testResults.passed + 1
        else
            print("✗ " .. test.name .. " FAILED")
            print("  Error: " .. tostring(err))
            testResults.failed = testResults.failed + 1
            table.insert(testResults.errors, {
                test = test.name,
                error = tostring(err)
            })
        end
    end

    return testResults.failed == 0
end

---Get test results
function UITestEngine.getResults()
    return testResults
end

---Reset engine state
function UITestEngine.reset()
    testResults = {
        passed = 0,
        failed = 0,
        skipped = 0,
        errors = {}
    }
    currentScene = nil
    elementRegistry = {}
end

return UITestEngine
