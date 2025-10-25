-- UI Test Framework - YAML-based automated UI testing
-- Provides declarative UI test definitions and automated execution

local UITestFramework = {}

-- YAML parser for test definitions
local YAMLParser = {}

function YAMLParser.parse(yaml_content)
    local tests = {}
    local current_test = nil
    local current_section = nil

    for line in yaml_content:gmatch("[^\n]+") do
        -- Trim whitespace
        line = line:match("^%s*(.-)%s*$")

        if line ~= "" and not line:match("^#") then
            -- Top-level test definition
            if line:match("^%w+:$") then
                if current_test then
                    table.insert(tests, current_test)
                end
                current_test = {
                    name = line:match("^(%w+):"),
                    steps = {},
                    assertions = {},
                    config = {},
                }
            -- Test configuration
            elseif line:match("^%s+description:") then
                local desc = line:match('description:%s*"([^"]+)"')
                if current_test then
                    current_test.description = desc
                end
            elseif line:match("^%s+category:") then
                local cat = line:match('category:%s*"([^"]+)"')
                if current_test then
                    current_test.category = cat
                end
            elseif line:match("^%s+skip:") then
                local skip = line:match("skip:%s*(%w+)")
                if current_test then
                    current_test.skip = skip == "true"
                end
            -- Steps section
            elseif line:match("^%s+steps:") then
                current_section = "steps"
            -- Assertions section
            elseif line:match("^%s+assertions:") then
                current_section = "assertions"
            -- Step items
            elseif current_section == "steps" and line:match("^%s+%-") then
                local action = line:match("^%s+%-(.+)$")
                if action and current_test then
                    table.insert(current_test.steps, {
                        action = action:match('^%s*(.-)%s*$')
                    })
                end
            -- Assertion items
            elseif current_section == "assertions" and line:match("^%s+%-") then
                local assertion = line:match("^%s+%-(.+)$")
                if assertion and current_test then
                    table.insert(current_test.assertions, {
                        assertion = assertion:match('^%s*(.-)%s*$')
                    })
                end
            end
        end
    end

    if current_test then
        table.insert(tests, current_test)
    end

    return tests
end

-- UI Test Framework
UITestFramework.config = {
    verbose = true,
    headless = false,
    screenshot_on_fail = true,
    max_wait_time = 5000,
}

UITestFramework.registry = {
    test_suites = {},
    ui_elements = {},
    total_tests = 0,
    passed = 0,
    failed = 0,
    skipped = 0,
}

UITestFramework.ui_selectors = {
    by_id = {},
    by_class = {},
    by_text = {},
}

---
-- Initialize UI test framework
---
function UITestFramework.init()
    print("\n" .. string.rep("=", 70))
    print("UI TEST FRAMEWORK INITIALIZATION")
    print(string.rep("=", 70) .. "\n")

    print(string.format("✓ Verbose mode: %s", UITestFramework.config.verbose and "ON" or "OFF"))
    print(string.format("✓ Headless mode: %s", UITestFramework.config.headless and "ON" or "OFF"))
    print(string.format("✓ Screenshots on fail: %s", UITestFramework.config.screenshot_on_fail and "YES" or "NO"))
    print(string.format("✓ Max wait time: %dms", UITestFramework.config.max_wait_time))

    print("\n" .. string.rep("-", 70) .. "\n")
end

---
-- Register UI element for testing
---
function UITestFramework.registerElement(id, selector, properties)
    properties = properties or {}

    local element = {
        id = id,
        selector = selector,
        type = properties.type or "unknown",
        value = properties.value or nil,
        visible = true,
        enabled = true,
        properties = properties,
    }

    UITestFramework.registry.ui_elements[id] = element
    UITestFramework.ui_selectors.by_id[id] = element

    return element
end

---
-- Find UI element
---
function UITestFramework.findElement(selector)
    -- By ID
    if UITestFramework.ui_selectors.by_id[selector] then
        return UITestFramework.ui_selectors.by_id[selector]
    end

    -- By class
    if UITestFramework.ui_selectors.by_class[selector] then
        return UITestFramework.ui_selectors.by_class[selector]
    end

    -- By text
    if UITestFramework.ui_selectors.by_text[selector] then
        return UITestFramework.ui_selectors.by_text[selector]
    end

    return nil
end

---
-- UI Interaction Commands
---
function UITestFramework.click(selector)
    local element = UITestFramework.findElement(selector)
    if not element then
        error("Element not found: " .. selector)
    end

    if not element.visible then
        error("Element not visible: " .. selector)
    end

    if not element.enabled then
        error("Element not enabled: " .. selector)
    end

    -- Simulate click
    if element.properties.onClick then
        element.properties.onClick()
    end

    if UITestFramework.config.verbose then
        print(string.format("  ✓ Clicked: %s", selector))
    end

    return true
end

function UITestFramework.type(selector, text)
    local element = UITestFramework.findElement(selector)
    if not element then
        error("Element not found: " .. selector)
    end

    if element.type ~= "input" and element.type ~= "textarea" then
        error("Element is not an input: " .. selector)
    end

    -- Simulate text input
    element.value = text

    if UITestFramework.config.verbose then
        print(string.format("  ✓ Typed in %s: '%s'", selector, text))
    end

    return true
end

function UITestFramework.select(selector, option)
    local element = UITestFramework.findElement(selector)
    if not element then
        error("Element not found: " .. selector)
    end

    if element.type ~= "select" and element.type ~= "dropdown" then
        error("Element is not a select: " .. selector)
    end

    -- Simulate selection
    element.value = option

    if UITestFramework.config.verbose then
        print(string.format("  ✓ Selected in %s: '%s'", selector, option))
    end

    return true
end

function UITestFramework.wait(milliseconds)
    if UITestFramework.config.verbose then
        print(string.format("  ⏱  Waiting %dms", milliseconds))
    end

    local start = os.clock()
    while (os.clock() - start) * 1000 < milliseconds do
        -- Busy wait
    end

    return true
end

function UITestFramework.waitForElement(selector, timeout)
    timeout = timeout or UITestFramework.config.max_wait_time
    local start = os.clock()

    while (os.clock() - start) * 1000 < timeout do
        local element = UITestFramework.findElement(selector)
        if element and element.visible then
            return element
        end
    end

    error("Element not found within timeout: " .. selector)
end

---
-- UI Assertions
---
function UITestFramework.assertVisible(selector)
    local element = UITestFramework.findElement(selector)
    if not element or not element.visible then
        error("Element not visible: " .. selector)
    end
end

function UITestFramework.assertNotVisible(selector)
    local element = UITestFramework.findElement(selector)
    if element and element.visible then
        error("Element should not be visible: " .. selector)
    end
end

function UITestFramework.assertEnabled(selector)
    local element = UITestFramework.findElement(selector)
    if not element or not element.enabled then
        error("Element not enabled: " .. selector)
    end
end

function UITestFramework.assertDisabled(selector)
    local element = UITestFramework.findElement(selector)
    if element and element.enabled then
        error("Element should be disabled: " .. selector)
    end
end

function UITestFramework.assertText(selector, expected_text)
    local element = UITestFramework.findElement(selector)
    if not element then
        error("Element not found: " .. selector)
    end

    if element.value ~= expected_text then
        error(string.format("Text mismatch in %s: expected '%s', got '%s'",
            selector, expected_text, element.value or ""))
    end
end

function UITestFramework.assertValue(selector, expected_value)
    local element = UITestFramework.findElement(selector)
    if not element then
        error("Element not found: " .. selector)
    end

    if element.value ~= expected_value then
        error(string.format("Value mismatch in %s: expected '%s', got '%s'",
            selector, tostring(expected_value), tostring(element.value)))
    end
end

function UITestFramework.assertExists(selector)
    local element = UITestFramework.findElement(selector)
    if not element then
        error("Element not found: " .. selector)
    end
end

function UITestFramework.assertNotExists(selector)
    local element = UITestFramework.findElement(selector)
    if element then
        error("Element should not exist: " .. selector)
    end
end

---
-- Run UI test case
---
function UITestFramework.runTest(test_case, scenario)
    local result = {
        name = test_case.name,
        scenario = scenario,
        status = "pending",
        steps_passed = 0,
        steps_failed = 0,
        assertions_passed = 0,
        assertions_failed = 0,
        error = nil,
        duration = 0,
    }

    if test_case.skip then
        result.status = "skipped"
        UITestFramework.registry.skipped = UITestFramework.registry.skipped + 1
        return result
    end

    local start_time = os.clock()

    if UITestFramework.config.verbose then
        print(string.format("\nRunning: %s", test_case.name))
        print(string.rep("-", 70))
    end

    -- Execute steps
    for _, step in ipairs(test_case.steps or {}) do
        local step_ok, step_err = pcall(function()
            UITestFramework.executeStep(step)
        end)

        if step_ok then
            result.steps_passed = result.steps_passed + 1
        else
            result.steps_failed = result.steps_failed + 1
            result.error = tostring(step_err)
            if UITestFramework.config.verbose then
                print(string.format("  ✗ Step failed: %s", result.error))
            end
        end
    end

    -- Execute assertions
    for _, assertion in ipairs(test_case.assertions or {}) do
        local assert_ok, assert_err = pcall(function()
            UITestFramework.executeAssertion(assertion)
        end)

        if assert_ok then
            result.assertions_passed = result.assertions_passed + 1
        else
            result.assertions_failed = result.assertions_failed + 1
            result.error = tostring(assert_err)
            if UITestFramework.config.verbose then
                print(string.format("  ✗ Assertion failed: %s", result.error))
            end
        end
    end

    result.duration = os.clock() - start_time

    if result.steps_failed == 0 and result.assertions_failed == 0 then
        result.status = "passed"
        UITestFramework.registry.passed = UITestFramework.registry.passed + 1
        if UITestFramework.config.verbose then
            print("  ✓ Test passed")
        end
    else
        result.status = "failed"
        UITestFramework.registry.failed = UITestFramework.registry.failed + 1
        if UITestFramework.config.verbose then
            print("  ✗ Test failed")
        end
    end

    return result
end

---
-- Execute test step
---
function UITestFramework.executeStep(step)
    local action = step.action or ""

    if action:match("^click") then
        local selector = action:match('click%s*%("([^"]+)"%)')
        UITestFramework.click(selector)
    elseif action:match("^type") then
        local selector, text = action:match('type%s*%("([^"]+)"%s*,s*"([^"]+)"%)')
        UITestFramework.type(selector, text)
    elseif action:match("^select") then
        local selector, option = action:match('select%s*%("([^"]+)"%s*,s*"([^"]+)"%)')
        UITestFramework.select(selector, option)
    elseif action:match("^wait") then
        local ms = action:match("wait%s*%((%-?%d+)%)")
        UITestFramework.wait(tonumber(ms) or 1000)
    end
end

---
-- Execute assertion
---
function UITestFramework.executeAssertion(assertion)
    local assertion_str = assertion.assertion or ""

    if assertion_str:match("^visible") then
        local selector = assertion_str:match('visible%s*%("([^"]+)"%)')
        UITestFramework.assertVisible(selector)
    elseif assertion_str:match("^notVisible") then
        local selector = assertion_str:match('notVisible%s*%("([^"]+)"%)')
        UITestFramework.assertNotVisible(selector)
    elseif assertion_str:match("^enabled") then
        local selector = assertion_str:match('enabled%s*%("([^"]+)"%)')
        UITestFramework.assertEnabled(selector)
    elseif assertion_str:match("^disabled") then
        local selector = assertion_str:match('disabled%s*%("([^"]+)"%)')
        UITestFramework.assertDisabled(selector)
    elseif assertion_str:match("^text") then
        local selector, text = assertion_str:match('text%s*%("([^"]+)"%s*,s*"([^"]+)"%)')
        UITestFramework.assertText(selector, text)
    elseif assertion_str:match("^exists") then
        local selector = assertion_str:match('exists%s*%("([^"]+)"%)')
        UITestFramework.assertExists(selector)
    end
end

---
-- Load UI test suite from YAML
---
function UITestFramework.loadTestsFromYAML(yaml_content)
    local tests = YAMLParser.parse(yaml_content)

    for _, test in ipairs(tests) do
        UITestFramework.registry.total_tests = UITestFramework.registry.total_tests + 1
        table.insert(UITestFramework.registry.test_suites, test)
    end

    return tests
end

---
-- Generate test report
---
function UITestFramework.generateReport()
    print("\n" .. string.rep("=", 70))
    print("UI TEST REPORT")
    print(string.rep("=", 70) .. "\n")

    print(string.format("Total UI Tests: %d", UITestFramework.registry.total_tests))
    print(string.format("  ✓ Passed: %d (%.1f%%)",
        UITestFramework.registry.passed,
        UITestFramework.registry.total_tests > 0 and (UITestFramework.registry.passed / UITestFramework.registry.total_tests * 100) or 0))
    print(string.format("  ✗ Failed: %d (%.1f%%)",
        UITestFramework.registry.failed,
        UITestFramework.registry.total_tests > 0 and (UITestFramework.registry.failed / UITestFramework.registry.total_tests * 100) or 0))
    print(string.format("  ⊘ Skipped: %d (%.1f%%)",
        UITestFramework.registry.skipped,
        UITestFramework.registry.total_tests > 0 and (UITestFramework.registry.skipped / UITestFramework.registry.total_tests * 100) or 0))

    print("\n" .. string.rep("=", 70) .. "\n")

    return {
        total = UITestFramework.registry.total_tests,
        passed = UITestFramework.registry.passed,
        failed = UITestFramework.registry.failed,
        skipped = UITestFramework.registry.skipped,
    }
end

return UITestFramework
