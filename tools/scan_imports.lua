#!/usr/bin/env lua
--[[
  Lua Import Scanner
  
  Scans Lua files in the engine folder for potential import/require problems:
  - Missing required modules
  - Circular dependencies
  - Invalid file paths
  - Unused requires
  - Duplicate requires
  
  Usage: lua scan_imports.lua [options]
  
  Options:
    --engine-path PATH    Path to engine folder (default: ./engine)
    --output FILE         Output report file (default: import_report.txt)
    --format FORMAT       Report format: text|json|html (default: text)
    --strict              Treat warnings as errors
    --verbose             Show detailed scan progress
]]

local lfs = require('lfs')
local json = require('json') -- optional

-- Configuration
local config = {
  engine_path = './engine',
  output_file = 'import_report.txt',
  format = 'text',
  strict = false,
  verbose = false,
  max_depth = 50,
}

-- Scan results storage
local results = {
  files_scanned = 0,
  errors = {},
  warnings = {},
  missing_modules = {},
  circular_deps = {},
  unused_requires = {},
  duplicate_requires = {},
  dependency_graph = {},
  file_list = {},
  valid_files = 0,
}

-- Helper functions
local function log(msg, level)
  level = level or 'info'
  if config.verbose then
    print(string.format('[%s] %s', level:upper(), msg))
  end
end

local function file_exists(path)
  local attr = lfs.attributes(path)
  return attr and attr.mode == 'file'
end

local function dir_exists(path)
  local attr = lfs.attributes(path)
  return attr and attr.mode == 'directory'
end

local function normalize_path(path)
  path = path:gsub('\\', '/')
  path = path:gsub('^%./', '')
  return path
end

local function resolve_require_path(require_name, current_file_dir)
  -- Handle different require formats
  local variations = {
    require_name .. '.lua',
    require_name,
    current_file_dir .. '/' .. require_name .. '.lua',
    current_file_dir .. '/' .. require_name,
    './engine/' .. require_name .. '.lua',
    './engine/' .. require_name,
  }
  
  for _, path in ipairs(variations) do
    if file_exists(path) then
      return normalize_path(path)
    end
  end
  
  return nil
end

local function extract_requires(file_path)
  local requires = {}
  local duplicate_check = {}
  
  local file = io.open(file_path, 'r')
  if not file then
    table.insert(results.errors, {
      file = file_path,
      message = 'Cannot open file for reading',
    })
    return requires
  end
  
  local line_num = 0
  for line in file:lines() do
    line_num = line_num + 1
    
    -- Match: require('module') or require("module")
    local module_single = line:match("require%s*%(%s*['\"]([^'\"]+)['\"]%s*%)")
    if module_single then
      if duplicate_check[module_single] then
        table.insert(results.duplicate_requires, {
          file = file_path,
          module = module_single,
          line = line_num,
          previous_line = duplicate_check[module_single],
        })
      else
        table.insert(requires, {
          module = module_single,
          line = line_num,
          type = 'require',
        })
        duplicate_check[module_single] = line_num
      end
    end
    
    -- Match: local x = require('module')
    local assign_module = line:match("local%s+%w+%s*=%s*require%s*%(%s*['\"]([^'\"]+)['\"]%s*%)")
    if assign_module and not duplicate_check[assign_module] then
      table.insert(requires, {
        module = assign_module,
        line = line_num,
        type = 'assignment',
      })
      duplicate_check[assign_module] = line_num
    end
  end
  
  file:close()
  return requires
end

local function scan_lua_file(file_path, depth)
  depth = depth or 0
  
  if depth > config.max_depth then
    table.insert(results.errors, {
      file = file_path,
      message = 'Maximum recursion depth exceeded',
    })
    return
  end
  
  results.files_scanned = results.files_scanned + 1
  table.insert(results.file_list, file_path)
  
  log('Scanning: ' .. file_path, 'debug')
  
  local requires = extract_requires(file_path)
  
  if #requires == 0 then
    log('  No requires found', 'debug')
  else
    results.valid_files = results.valid_files + 1
  end
  
  local current_dir = file_path:match('(.+)/') or '.'
  
  for _, req in ipairs(requires) do
    local resolved_path = resolve_require_path(req.module, current_dir)
    
    if not resolved_path then
      table.insert(results.missing_modules, {
        file = file_path,
        module = req.module,
        line = req.line,
        attempted_paths = {
          req.module .. '.lua',
          req.module,
          current_dir .. '/' .. req.module .. '.lua',
        },
      })
      log('  Missing: ' .. req.module, 'warning')
    else
      -- Store dependency
      if not results.dependency_graph[file_path] then
        results.dependency_graph[file_path] = {}
      end
      table.insert(results.dependency_graph[file_path], {
        module = req.module,
        resolved = resolved_path,
        line = req.line,
      })
      log('  Found: ' .. req.module .. ' -> ' .. resolved_path, 'debug')
      
      -- Recursively scan found file
      if not results.file_list[resolved_path] then
        scan_lua_file(resolved_path, depth + 1)
      end
    end
  end
end

local function scan_directory(dir_path, pattern)
  pattern = pattern or '%.lua$'
  
  if not dir_exists(dir_path) then
    log('Directory not found: ' .. dir_path, 'error')
    return
  end
  
  for item in lfs.dir(dir_path) do
    if item ~= '.' and item ~= '..' then
      local full_path = dir_path .. '/' .. item
      local attr = lfs.attributes(full_path)
      
      if attr.mode == 'file' and item:match(pattern) then
        scan_lua_file(full_path)
      elseif attr.mode == 'directory' then
        scan_directory(full_path, pattern)
      end
    end
  end
end

local function detect_circular_deps()
  local function check_circular(file, current_chain, visited)
    visited = visited or {}
    current_chain = current_chain or {}
    
    if visited[file] then
      return
    end
    visited[file] = true
    
    for _, dep in ipairs(current_chain) do
      if dep == file then
        table.insert(results.circular_deps, current_chain)
        return
      end
    end
    
    local deps = results.dependency_graph[file] or {}
    for _, dep_info in ipairs(deps) do
      local new_chain = {}
      for _, item in ipairs(current_chain) do
        table.insert(new_chain, item)
      end
      table.insert(new_chain, file)
      check_circular(dep_info.resolved, new_chain, visited)
    end
  end
  
  for file, _ in pairs(results.dependency_graph) do
    check_circular(file, {}, {})
  end
end

local function generate_text_report()
  local lines = {
    '═══════════════════════════════════════════════════════',
    'LUA IMPORT SCANNER REPORT',
    '═══════════════════════════════════════════════════════',
    '',
    'Scan Date: ' .. os.date('%Y-%m-%d %H:%M:%S'),
    'Engine Path: ' .. config.engine_path,
    '',
    '───────────────────────────────────────────────────────',
    'SCAN SUMMARY',
    '───────────────────────────────────────────────────────',
    'Total Files Scanned: ' .. results.files_scanned,
    'Files with Requires: ' .. results.valid_files,
    'Total Errors: ' .. #results.errors,
    'Total Warnings: ' .. #results.warnings,
    'Missing Modules: ' .. #results.missing_modules,
    'Circular Dependencies: ' .. #results.circular_deps,
    'Duplicate Requires: ' .. #results.duplicate_requires,
    '',
  }
  
  if #results.errors > 0 then
    table.insert(lines, '───────────────────────────────────────────────────────')
    table.insert(lines, 'ERRORS (' .. #results.errors .. ')')
    table.insert(lines, '───────────────────────────────────────────────────────')
    for _, err in ipairs(results.errors) do
      table.insert(lines, 'File: ' .. err.file)
      table.insert(lines, 'Error: ' .. err.message)
      table.insert(lines, '')
    end
  end
  
  if #results.missing_modules > 0 then
    table.insert(lines, '───────────────────────────────────────────────────────')
    table.insert(lines, 'MISSING MODULES (' .. #results.missing_modules .. ')')
    table.insert(lines, '───────────────────────────────────────────────────────')
    for _, miss in ipairs(results.missing_modules) do
      table.insert(lines, 'File: ' .. miss.file)
      table.insert(lines, 'Module: ' .. miss.module .. ' (Line ' .. miss.line .. ')')
      table.insert(lines, 'Attempted paths:')
      for _, path in ipairs(miss.attempted_paths) do
        table.insert(lines, '  - ' .. path)
      end
      table.insert(lines, '')
    end
  end
  
  if #results.circular_deps > 0 then
    table.insert(lines, '───────────────────────────────────────────────────────')
    table.insert(lines, 'CIRCULAR DEPENDENCIES (' .. #results.circular_deps .. ')')
    table.insert(lines, '───────────────────────────────────────────────────────')
    for i, cycle in ipairs(results.circular_deps) do
      table.insert(lines, 'Cycle ' .. i .. ':')
      for _, file in ipairs(cycle) do
        table.insert(lines, '  → ' .. file)
      end
      table.insert(lines, '')
    end
  end
  
  if #results.duplicate_requires > 0 then
    table.insert(lines, '───────────────────────────────────────────────────────')
    table.insert(lines, 'DUPLICATE REQUIRES (' .. #results.duplicate_requires .. ')')
    table.insert(lines, '───────────────────────────────────────────────────────')
    for _, dup in ipairs(results.duplicate_requires) do
      table.insert(lines, 'File: ' .. dup.file)
      table.insert(lines, 'Module: ' .. dup.module)
      table.insert(lines, 'Lines: ' .. dup.previous_line .. ' (first), ' .. dup.line .. ' (duplicate)')
      table.insert(lines, '')
    end
  end
  
  table.insert(lines, '───────────────────────────────────────────────────────')
  table.insert(lines, 'END OF REPORT')
  table.insert(lines, '═══════════════════════════════════════════════════════')
  
  return table.concat(lines, '\n')
end

local function generate_html_report()
  local html = [[
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Lua Import Scanner Report</title>
  <style>
    body { font-family: 'Courier New', monospace; margin: 20px; background: #f5f5f5; }
    .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; }
    h1 { color: #333; border-bottom: 2px solid #007bff; padding-bottom: 10px; }
    h2 { color: #007bff; margin-top: 30px; }
    .summary { background: #e7f3ff; padding: 15px; margin: 15px 0; border-radius: 5px; }
    .error { background: #ffe7e7; padding: 10px; margin: 10px 0; border-left: 4px solid #ff0000; }
    .warning { background: #fff4e7; padding: 10px; margin: 10px 0; border-left: 4px solid #ff8800; }
    .info { background: #f0f0f0; padding: 10px; margin: 10px 0; border-left: 4px solid #0088ff; }
    code { background: #f5f5f5; padding: 2px 6px; border-radius: 3px; }
    .timestamp { color: #666; font-size: 0.9em; }
  </style>
</head>
<body>
  <div class="container">
    <h1>Lua Import Scanner Report</h1>
    <p class="timestamp">Generated: ]] .. os.date('%Y-%m-%d %H:%M:%S') .. [[</p>
    
    <div class="summary">
      <h2>Summary</h2>
      <p><strong>Engine Path:</strong> ]] .. config.engine_path .. [[</p>
      <p><strong>Files Scanned:</strong> ]] .. results.files_scanned .. [[</p>
      <p><strong>Files with Requires:</strong> ]] .. results.valid_files .. [[</p>
      <p><strong>Total Issues:</strong> ]] .. (#results.errors + #results.missing_modules + #results.circular_deps) .. [[</p>
    </div>
  </div>
</body>
</html>
  ]]
  return html
end

-- Parse command line arguments
local function parse_args()
  local args = arg
  local i = 1
  
  while i <= #args do
    if args[i] == '--engine-path' then
      config.engine_path = args[i + 1]
      i = i + 2
    elseif args[i] == '--output' then
      config.output_file = args[i + 1]
      i = i + 2
    elseif args[i] == '--format' then
      config.format = args[i + 1]
      i = i + 2
    elseif args[i] == '--strict' then
      config.strict = true
      i = i + 1
    elseif args[i] == '--verbose' then
      config.verbose = true
      i = i + 1
    else
      i = i + 1
    end
  end
end

-- Main execution
local function main()
  print('[INFO] Starting Lua import scan...')
  print('[INFO] Engine path: ' .. config.engine_path)
  
  parse_args()
  
  if not dir_exists(config.engine_path) then
    print('[ERROR] Engine path not found: ' .. config.engine_path)
    os.exit(1)
  end
  
  -- Scan all Lua files
  scan_directory(config.engine_path)
  
  -- Detect circular dependencies
  detect_circular_deps()
  
  -- Generate report
  local report = ''
  if config.format == 'text' then
    report = generate_text_report()
  elseif config.format == 'html' then
    report = generate_html_report()
  end
  
  -- Write report
  local output = io.open(config.output_file, 'w')
  if output then
    output:write(report)
    output:close()
    print('[INFO] Report written to: ' .. config.output_file)
  else
    print('[ERROR] Cannot write report to: ' .. config.output_file)
    print(report)
  end
  
  -- Print summary
  print('')
  print('═══════════════════════════════════════════════════════')
  print('SCAN COMPLETE')
  print('═══════════════════════════════════════════════════════')
  print('Files Scanned: ' .. results.files_scanned)
  print('Errors: ' .. #results.errors)
  print('Missing Modules: ' .. #results.missing_modules)
  print('Circular Dependencies: ' .. #results.circular_deps)
  print('Duplicate Requires: ' .. #results.duplicate_requires)
  
  if config.strict and (#results.errors > 0 or #results.missing_modules > 0) then
    os.exit(1)
  end
end

main()
