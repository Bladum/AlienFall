# 🛠️ Test Utilities

**Helper functions and utilities for test implementation**

---

## 📦 Available Utilities

All utilities are in `test_helpers.lua`:

```lua
local Helpers = require("tests2.utils.test_helpers")
```

---

## 📁 File Operations

### Check if File Exists

```lua
if Helpers.fileExists("path/to/file.lua") then
  -- File exists
end
```

### Read File

```lua
local content = Helpers.readFile("path/to/file.lua")
if content then
  print(content)
end
```

### Write File

```lua
Helpers.writeFile("path/to/file.lua", "file content")
```

### Delete File

```lua
Helpers.deleteFile("path/to/file.lua")
```

---

## 🗂️ Temporary Files

**Important:** Always use `temp/` directory per Love2D guidelines!

### Get Temp Directory

```lua
local tempDir = Helpers.getTempDir()  -- Returns: "temp"
```

### Create Temp File

```lua
-- Creates unique temp file: temp/mytest_1635021234_5678.json
local tempFile = Helpers.createTempFile("mytest", ".json")

Helpers.writeFile(tempFile, data)
```

### Cleanup Temp File

```lua
Helpers.cleanupTempFile(tempFile)
```

### Full Example

```lua
Suite:beforeEach(function()
  testFile = Helpers.createTempFile("test", ".tmp")
end)

Suite:afterEach(function()
  Helpers.cleanupTempFile(testFile)
end)

Suite:testMethod("Method:name", {...}, function()
  Helpers.writeFile(testFile, "test data")
  local content = Helpers.readFile(testFile)
  assert(content == "test data")
end)
```

---

## 📊 Data Structures

### Deep Copy Table

```lua
local original = {a = 1, b = {c = 2}}
local copy = Helpers.deepCopy(original)

copy.b.c = 99
-- original.b.c is still 2 (not affected)
```

### Merge Tables

```lua
local t1 = {a = 1, b = 2}
local t2 = {b = 3, c = 4}
local merged = Helpers.merge(t1, t2)
-- merged = {a = 1, b = 3, c = 4}
```

### Check if Table Contains Value

```lua
local list = {10, 20, 30}
if Helpers.tableContains(list, 20) then
  print("Found!")
end
```

### Get Table Size

```lua
local tbl = {a = 1, b = 2, c = 3}
local size = Helpers.tableSize(tbl)  -- Returns: 3
```

---

## ✅ Assertions

### Assert Equals

```lua
Helpers.assertEqual(actual, expected, "Error message")

-- Example:
local result = calculator:add(2, 3)
Helpers.assertEqual(result, 5, "2 + 3 should be 5")
```

### Assert Throws

```lua
Helpers.assertThrows(fn, expectedError, "Message")

-- Example:
Helpers.assertThrows(function()
  StateManager:new({invalid = true})
end, "Invalid", "Should throw on invalid config")
```

### Assert No Throw

```lua
Helpers.assertNoThrow(fn, "Message")

-- Example:
Helpers.assertNoThrow(function()
  StateManager:new()
end, "Should not throw on valid config")
```

---

## 🎭 Mocking & Spying

### Create Mock Function

```lua
local mock = Helpers.mockFunction("return value")

-- Use it:
mock.fn()
mock.fn(arg1, arg2)

-- Check calls:
print(mock.callCount)     -- How many times called
print(mock.calls[1])      -- First call args
print(mock.returnValue)   -- What it returns
```

### Create Spy Wrapper

```lua
local original = function(x) return x * 2 end
local spy = Helpers.spy(original)

-- Use spy:
spy.fn(5)    -- calls original, returns 10

-- Check calls:
print(spy.callCount)      -- 1
print(spy.calls[1])       -- {5}
print(spy.returnValues[1]) -- {10}
```

---

## ⏱️ Performance Measurement

### Measure Execution Time

```lua
local result = Helpers.measureTime(function()
  -- Code to measure
  for i = 1, 1000 do
    local _ = i * 2
  end
end, 100)  -- Run 100 times

print("Total: " .. result.total .. "s")
print("Average: " .. result.average .. "s per iteration")
```

---

## 🎮 Love2D Specific

### Mock Love2D Environment

```lua
-- For testing outside of Love2D context
Helpers.mockLoveEnvironment()

-- Now love.graphics, love.filesystem available
love.graphics.print("test", 0, 0)
```

### Mock Game State

```lua
local state = Helpers.mockGameState()
-- Returns:
-- {
--   phase = "geoscape",
--   turn = 1,
--   year = 2024,
--   money = 1000,
--   units = {},
--   basesCount = 0,
--   mapSize = {width = 100, height = 100}
-- }
```

---

## 🖨️ Debugging Helpers

### Debug Print

```lua
Helpers.debug("ModuleName", "Some message")
-- Output: [ModuleName] Some message
```

### Print Table Contents

```lua
local data = {
  name = "Test",
  values = {1, 2, 3},
  nested = {a = 1, b = 2}
}

Helpers.printTable(data)
-- Output:
-- name = "Test"
-- values:
--   1 = 1
--   2 = 2
--   3 = 3
-- nested:
--   a = 1
--   b = 2
```

### Format Value for Display

```lua
print(Helpers.formatValue(nil))          -- "nil"
print(Helpers.formatValue(true))         -- "true"
print(Helpers.formatValue(42))           -- "42"
print(Helpers.formatValue("hello"))      -- "hello"
print(Helpers.formatValue({1,2,3}))      -- "{table: 3 items}"
print(Helpers.formatValue(function()end)) -- "[function]"
```

---

## 🔗 Usage Examples

### Complete Test Using Helpers

```lua
local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local Helpers = require("tests2.utils.test_helpers")

local Suite = HierarchicalSuite:new({
  modulePath = "engine.core.save_system",
  description = "Save/load functionality"
})

Suite:beforeEach(function()
  -- Create temp file for each test
  _tempFile = Helpers.createTempFile("save_test", ".json")
end)

Suite:afterEach(function()
  -- Cleanup
  Helpers.cleanupTempFile(_tempFile)
end)

Suite:group("Save Operations", function()

  Suite:testMethod("SaveSystem:save", {
    description = "Saves data to file",
    testCase = "happy_path"
  }, function()
    local data = {player = 1, money = 100}

    -- Write data
    Helpers.writeFile(_tempFile, "test data")

    -- Verify it exists
    assert(Helpers.fileExists(_tempFile))

    -- Read and check
    local content = Helpers.readFile(_tempFile)
    Helpers.assertEqual(content, "test data")
  end)

end)

return Suite
```

---

## 📝 Full API Reference

### File Operations

```lua
Helpers.fileExists(path)              -- boolean
Helpers.readFile(path)                -- string or nil
Helpers.writeFile(path, content)      -- boolean
Helpers.deleteFile(path)              -- boolean
```

### Temp Files

```lua
Helpers.getTempDir()                  -- "temp"
Helpers.createTempFile(prefix, ext)   -- "temp/prefix_xxx.ext"
Helpers.cleanupTempFile(path)         -- boolean
```

### Data Structures

```lua
Helpers.deepCopy(tbl)                 -- table
Helpers.merge(t1, t2)                 -- table
Helpers.tableContains(tbl, value)     -- boolean
Helpers.tableSize(tbl)                -- number
```

### Assertions

```lua
Helpers.assertEqual(actual, expected, msg)
Helpers.assertThrows(fn, expectedError, msg)
Helpers.assertNoThrow(fn, msg)
```

### Mocking

```lua
Helpers.mockFunction(returnValue)     -- mock object
Helpers.spy(fn)                       -- spy object
```

### Performance

```lua
Helpers.measureTime(fn, iterations)   -- {total, average, iterations}
```

### Love2D

```lua
Helpers.mockLoveEnvironment()         -- nil
Helpers.mockGameState()               -- table
```

### Debugging

```lua
Helpers.debug(prefix, message)        -- nil (prints)
Helpers.printTable(tbl, indent)       -- nil (prints)
Helpers.formatValue(v)                -- string
```

---

## 🎯 Best Practices

### 1. Always Cleanup Temp Files

```lua
Suite:afterEach(function()
  if tempFile then
    Helpers.cleanupTempFile(tempFile)
  end
end)
```

### 2. Use Descriptive Error Messages

```lua
-- Good:
Helpers.assertEqual(result, 42, "Calculator should return 42 for valid input")

-- Bad:
Helpers.assertEqual(result, 42)
```

### 3. Group Assertions Logically

```lua
-- Good - testing one thing:
Suite:testMethod("Parser:parse", {
  description = "Parses valid JSON"
}, function()
  local json = '{"name":"test"}'
  local result = Parser:parse(json)

  assert(result ~= nil)
  Helpers.assertEqual(result.name, "test")
end)

-- Not: mixing multiple unrelated assertions
```

### 4. Use Mocks for External Dependencies

```lua
Suite:testMethod("Unit:takeDamage", {
  description = "Reduces health"
}, function()
  local unit = Unit:new()
  local audioMock = Helpers.mockFunction()

  unit:takeDamage(10)

  assert(unit:getHealth() < 100)
end)
```

---

## 🔗 Related

- `../README.md` - Main usage guide
- `../framework/hierarchical_suite.lua` - Test framework
- `../core/example_counter_test.lua` - Complete example

---

*Test utilities and helpers for Love2D test framework*
*Simplify common testing tasks and assertions*
