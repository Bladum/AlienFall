-- UI Test Runner
-- Loads and executes YAML-based UI test scripts

local UITestRunner = {}

local YAMLParser = require("tests.framework.yaml_parser")
local UITestEngine = require("tests.framework.ui_test_engine")

-- Load a test script from file
function UITestRunner.loadScript(file_path)
  print("[UITestRunner] Loading test script: " .. file_path)

  local ok, content = pcall(love.filesystem.read, file_path)

  if not ok or not content then
    error("Failed to load test script: " .. file_path)
  end

  -- Parse YAML
  local script = YAMLParser.parseTestScript(content)

  print("[UITestRunner] ✓ Loaded script: " .. script.name)
  print("[UITestRunner]   Tests: " .. (script.tests and table.count(script.tests) or 0))

  return script
end

-- Load and run a test script
function UITestRunner.runScript(file_path)
  local script = UITestRunner.loadScript(file_path)
  return UITestEngine:executeScript(script)
end

-- Load and run all test scripts in a directory
function UITestRunner.runDirectory(directory)
  print("[UITestRunner] Loading test scripts from: " .. directory)

  local ok, files = pcall(love.filesystem.getDirectoryItems, directory)

  if not ok or not files then
    error("Failed to read directory: " .. directory)
  end

  local test_count = 0
  local success_count = 0

  for _, file in ipairs(files) do
    if file:match("%.yaml$") then
      test_count = test_count + 1
      local file_path = directory .. "/" .. file

      local ok, result = pcall(function()
        return UITestRunner.runScript(file_path)
      end)

      if ok and result then
        success_count = success_count + 1
      end
    end
  end

  print("")
  print("[UITestRunner] ========================================")
  print("[UITestRunner] Summary:")
  print("[UITestRunner]   Total scripts: " .. test_count)
  print("[UITestRunner]   Successful: " .. success_count)
  print("[UITestRunner]   Failed: " .. (test_count - success_count))
  print("[UITestRunner] ========================================")

  return success_count == test_count
end

-- Helper for table counting
function table.count(t)
  local count = 0
  for _ in pairs(t) do
    count = count + 1
  end
  return count
end

return UITestRunner
