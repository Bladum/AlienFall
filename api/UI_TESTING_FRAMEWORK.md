# UI Testing Framework - YAML-Based Automated Testing

**Status:** ✅ IMPLEMENTED
**Framework Type:** Declarative YAML-based UI test definition and execution
**Supported Screens:** Main Menu, Geoscape, Battlescape, Basescape
**Test Format:** YAML with step and assertion syntax

---

## Overview

The UI Testing Framework provides:
- **YAML-Based Definitions:** Declarative test cases using YAML syntax
- **UI Interaction Simulation:** Click, type, select, wait operations
- **Element Selection:** By ID, class, or text content
- **Smart Assertions:** Verify visibility, state, content, and existence
- **Test Organization:** Categorized by screen and purpose
- **Error Reporting:** Detailed failure messages with screenshots
- **Performance Tracking:** Test execution time and statistics

---

## Architecture

### Component Structure

```
UITestFramework (core)
├── YAML Parser
│   ├── Parse test definitions
│   ├── Extract steps and assertions
│   └── Build test cases
├── Element Registry
│   ├── UI element registration
│   ├── Selector mapping
│   └── Element state tracking
├── Interaction Engine
│   ├── Click simulation
│   ├── Text input
│   ├── Selection
│   └── Wait operations
├── Assertion Engine
│   ├── Visibility checks
│   ├── State validation
│   ├── Content verification
│   └── Existence checks
└── Reporting
    ├── Test results
    ├── Screenshots on fail
    ├── Performance metrics
    └── Summary reports
```

### Test Categories

- **ui_unit:** Single component tests
- **ui_integration:** Multi-component interaction tests
- **ui_acceptance:** Full screen/feature tests
- **ui_regression:** Regression test suite
- **ui_accessibility:** Accessibility tests

---

## YAML Test Format

### Basic Structure

```yaml
test_name:
  description: "Test description"
  category: "ui_acceptance"
  skip: false
  steps:
    - action_name(selector, params...)
    - action_name(selector, params...)
  assertions:
    - assertion_name(selector, expected...)
    - assertion_name(selector, expected...)
```

### Test Sections

#### Description
```yaml
description: "Clear description of what test verifies"
```

#### Category
```yaml
category: "ui_acceptance"  # ui_unit, ui_integration, ui_acceptance, etc.
```

#### Skip
```yaml
skip: false  # Set to true to skip test
```

#### Steps
```yaml
steps:
  - click("button_id")
  - type("input_id", "text to type")
  - select("dropdown_id", "option_value")
  - wait(500)  # milliseconds
```

#### Assertions
```yaml
assertions:
  - visible("element_id")
  - notVisible("element_id")
  - enabled("element_id")
  - disabled("element_id")
  - text("element_id", "expected text")
  - value("element_id", "expected value")
  - exists("element_id")
  - notExists("element_id")
```

---

## API Reference

### Framework Initialization

```lua
local UITestFramework = require("engine.gui.ui_test_framework")

UITestFramework.init()
```

**Configuration:**
```lua
UITestFramework.config.verbose = true              -- Detailed logging
UITestFramework.config.headless = false            -- Headless mode
UITestFramework.config.screenshot_on_fail = true   -- Screenshot on failure
UITestFramework.config.max_wait_time = 5000        -- Max wait (ms)
```

### Element Registration

```lua
UITestFramework.registerElement("button_id", selector, {
    type = "button",
    value = "Click Me",
    onClick = function() print("clicked") end,
})
```

### UI Interactions

#### Click
```lua
UITestFramework.click("button_id")
```
Click an element. Raises error if element not visible/enabled.

#### Type
```lua
UITestFramework.type("input_id", "text content")
```
Type text into an input field.

#### Select
```lua
UITestFramework.select("dropdown_id", "option_value")
```
Select an option from dropdown/select element.

#### Wait
```lua
UITestFramework.wait(1000)  -- milliseconds
```
Wait for specified duration.

#### Wait For Element
```lua
UITestFramework.waitForElement("element_id", 5000)  -- timeout in ms
```
Wait for element to appear and become visible.

### Assertions

#### Visibility Assertions
```lua
UITestFramework.assertVisible("element_id")
UITestFramework.assertNotVisible("element_id")
```

#### State Assertions
```lua
UITestFramework.assertEnabled("element_id")
UITestFramework.assertDisabled("element_id")
```

#### Content Assertions
```lua
UITestFramework.assertText("element_id", "expected text")
UITestFramework.assertValue("element_id", "expected value")
```

#### Existence Assertions
```lua
UITestFramework.assertExists("element_id")
UITestFramework.assertNotExists("element_id")
```

### Test Execution

```lua
-- Load tests from YAML
local yaml_content = [[
test_name:
  description: "Test description"
  steps:
    - click("button")
  assertions:
    - visible("button")
]]

UITestFramework.loadTestsFromYAML(yaml_content)

-- Run test
local test = UITestFramework.registry.test_suites[1]
local result = UITestFramework.runTest(test, "screen_name")

-- Generate report
UITestFramework.generateReport()
```

---

## Writing UI Tests

### Step 1: Create YAML Test File

```yaml
# tests/ui/my_feature_tests.yaml

button_click_test:
  description: "Verify button can be clicked"
  category: "ui_unit"
  steps:
    - click("my_button")
  assertions:
    - enabled("my_button")

form_submission:
  description: "Test form input and submission"
  category: "ui_integration"
  steps:
    - click("name_input")
    - type("name_input", "John Doe")
    - click("email_input")
    - type("email_input", "john@example.com")
    - click("submit_button")
    - wait(1000)
  assertions:
    - visible("success_message")
    - notVisible("error_message")
```

### Step 2: Register Elements

```lua
-- In test setup
UITestFramework.registerElement("my_button", "#button", {
    type = "button",
    onClick = function() print("Button clicked") end,
})

UITestFramework.registerElement("name_input", "input.name", {
    type = "input",
})

UITestFramework.registerElement("submit_button", "button.submit", {
    type = "button",
})

UITestFramework.registerElement("success_message", ".success", {
    type = "label",
})
```

### Step 3: Load and Run Tests

```lua
local yaml_content = require("tests.ui.my_feature_tests")  -- Or read from file
UITestFramework.loadTestsFromYAML(yaml_content)

for _, test in ipairs(UITestFramework.registry.test_suites) do
    UITestFramework.runTest(test, "feature_screen")
end

UITestFramework.generateReport()
```

---

## Test Examples

### Main Menu Test

```yaml
# tests/ui/menu_tests.yaml

main_menu_buttons:
  description: "Verify all main menu buttons are visible and enabled"
  category: "ui_unit"
  steps:
    - wait(300)
  assertions:
    - visible("new_game_button")
    - visible("load_game_button")
    - visible("settings_button")
    - enabled("new_game_button")
    - enabled("load_game_button")
    - enabled("settings_button")

new_game_flow:
  description: "Test complete new game initialization"
  category: "ui_acceptance"
  steps:
    - click("new_game_button")
    - wait(500)
    - click("difficulty_hard")
    - wait(200)
    - click("confirm_button")
    - wait(2000)
  assertions:
    - notVisible("main_menu_buttons")
    - visible("game_screen")
```

### Combat UI Test

```yaml
# tests/ui/battlescape_tests.yaml

unit_selection_and_action:
  description: "Test selecting unit and choosing action"
  category: "ui_integration"
  steps:
    - click("unit_1")
    - wait(200)
    - click("move_button")
    - wait(300)
  assertions:
    - visible("action_panel")
    - enabled("move_button")
    - visible("movement_indicator")

weapon_mode_selection:
  description: "Test switching weapon firing modes"
  category: "ui_unit"
  steps:
    - click("weapon_dropdown")
    - wait(100)
    - select("weapon_dropdown", "aimed_shot")
    - wait(300)
  assertions:
    - text("weapon_dropdown", "aimed_shot")
    - visible("accuracy_display")
```

### Base Management Test

```yaml
# tests/ui/basescape_tests.yaml

facility_construction_flow:
  description: "Test building a new facility"
  category: "ui_acceptance"
  steps:
    - click("construction_tab")
    - wait(300)
    - click("facility_aircraft_hangar")
    - wait(200)
    - click("construct_button")
    - wait(1500)
  assertions:
    - visible("construction_queue")
    - visible("facility_under_construction")
    - notVisible("construct_button")
```

---

## Best Practices

### ✅ Do

- Use descriptive test names
- One feature per test
- Wait appropriately between actions
- Test both success and failure paths
- Use semantic selectors (ID, class, name)
- Clear and specific assertions
- Organize by feature/screen
- Document complex tests

### ❌ Don't

- Test implementation details
- Make tests dependent on each other
- Use magic numbers for waits
- Test too many things in one test
- Use fragile XPath-like selectors
- Ignore error handling
- Skip assertion checks
- Create tests that are hard to debug

### Naming Conventions

```yaml
# Good: Clear, specific, actionable
button_click_succeeds
form_validation_shows_error
unit_selection_displays_actions

# Bad: Vague, non-specific
test_button
test_form
test_unit
```

### Wait Times

Use appropriate wait times:
- Button click response: 100-200ms
- Modal/dialog open: 300-500ms
- Animation completion: 500-1000ms
- Network/async operation: 1000-2000ms

---

## Test Organization

### Recommended Structure

```
tests/
├── ui/
│   ├── menu_tests.yaml          # Main menu tests
│   ├── battlescape_tests.yaml   # Combat interface tests
│   ├── geoscape_tests.yaml      # Strategic map tests
│   ├── basescape_tests.yaml     # Base management tests
│   ├── accessibility_tests.yaml # Accessibility tests
│   └── regression_tests.yaml    # Regression suite
├── ui_runners/
│   ├── run_menu_tests.lua
│   ├── run_ui_tests.lua
│   └── ui_test_runner.lua
└── fixtures/
    └── ui_elements.lua          # Element definitions
```

### Test Distribution

- **Unit tests:** 40% (individual component tests)
- **Integration tests:** 40% (multi-component interaction)
- **Acceptance tests:** 20% (full feature/screen tests)

---

## Output and Reporting

### Console Output

```
======================================================================
UI TEST FRAMEWORK INITIALIZATION
======================================================================

✓ Verbose mode: ON
✓ Headless mode: OFF
✓ Screenshots on fail: YES
✓ Max wait time: 5000ms

Running: button_click_test
----------------------------------------------------------------------
  ✓ Clicked: my_button
  ✓ Assertion passed: element visible
  ✓ Test passed

======================================================================
UI TEST REPORT
======================================================================

Total UI Tests: 15
  ✓ Passed: 14 (93.3%)
  ✗ Failed: 1 (6.7%)
  ⊘ Skipped: 0 (0.0%)

Failed Tests:
  - form_validation: "Text mismatch in error_message"
```

### Screenshot On Failure

When `screenshot_on_fail = true`, failed tests capture screen:
```
temp/screenshots/
├── form_validation_1.png        # Failed test screenshot
├── unit_selection_2.png
└── craft_dispatch_3.png
```

---

## Running Tests

### Command Line

```bash
# Run all UI tests
lovec tests/ui_runners/ui_test_runner.lua

# Run specific screen tests
lovec tests/ui_runners/run_menu_tests.lua
lovec tests/ui_runners/run_battlescape_tests.lua
```

### In Code

```lua
local UITestFramework = require("engine.gui.ui_test_framework")

UITestFramework.init()
UITestFramework.loadTestsFromYAML(yaml_content)

for _, test in ipairs(UITestFramework.registry.test_suites) do
    UITestFramework.runTest(test, "screen_name")
end

local report = UITestFramework.generateReport()
print("Pass rate: " .. report.passed .. "/" .. report.total)
```

---

## Advanced Features

### Conditional Steps

```yaml
conditional_test:
  description: "Test with conditional logic"
  category: "ui_acceptance"
  steps:
    - click("toggle_button")
    - wait(300)
    # Assertion in steps (framework checks results)
  assertions:
    - visible("toggled_panel")
```

### Element Waits

```yaml
async_operation:
  description: "Test asynchronous operation completion"
  category: "ui_integration"
  steps:
    - click("start_operation_button")
    - waitFor("operation_complete_message", 5000)
  assertions:
    - text("status_message", "Operation completed")
```

### Custom Selectors

```lua
-- Register element with multiple selector types
UITestFramework.registerElement("unit_panel", {
    id = "unit_panel",
    class = "panel-unit",
    text = "Unit Information",
    type = "panel",
})
```

---

## Troubleshooting

### Test Not Finding Element

- Verify element is registered
- Check selector is correct
- Ensure element is visible when needed
- Add wait time before assertion

### Test Timing Issues

- Increase wait times for slow operations
- Use `waitForElement()` instead of fixed wait
- Check for animation completion
- Profile slow operations

### False Failures

- Add debug output to understand state
- Screenshot on failure to see actual state
- Check for race conditions
- Verify test cleanup

---

## Performance Targets

| Test Type | Target Speed | Max Duration |
|-----------|--------------|--------------|
| UI Unit | < 200ms | 500ms |
| UI Integration | < 1s | 2s |
| UI Acceptance | < 3s | 5s |
| Full UI Suite | < 30s | 60s |

---

## Integration with Game

### During Development

```lua
-- In game initialization
if love.arg.raw[2] == "ui_test" then
    local UITestFramework = require("engine.gui.ui_test_framework")
    UITestFramework.init()
    -- Register elements and run tests
end
```

### Screenshot Functionality

Tests can capture screenshots for analysis:

```lua
love.graphics.captureScreenshot(function(imageData)
    imageData:encode("png", "temp/screenshots/test_name_" .. os.time() .. ".png")
end)
```

---

## Summary

The UI Testing Framework provides:

✅ **YAML-Based Definitions:** Declarative, easy-to-read test cases
✅ **Comprehensive Interactions:** Click, type, select, wait operations
✅ **Smart Assertions:** Verify visibility, state, and content
✅ **Element Management:** Register and manage UI elements
✅ **Detailed Reporting:** Test results with performance metrics
✅ **Screenshots on Failure:** Visual debugging support
✅ **Organized Structure:** Categorized by screen and purpose
✅ **Easy Integration:** Works with Love2D game engine

Ready for production use and continuous expansion!
