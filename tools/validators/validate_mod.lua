#!/usr/bin/env lua
-- validate_mod.lua - Main validator script
-- Usage: lovec tools/validators/validate_mod.lua <mod_path> [options]
--
-- Options:
--   --schema <path>    Path to GAME_API.toml (default: api/GAME_API.toml)
--   --verbose          Show detailed output
--   --json             Output JSON format
--   --markdown         Output markdown format
--   --category <cat>   Validate only specific category
--   --output <file>    Write report to file

-- Setup paths for require
if love then
  -- Love2D environment
  package.path = love.filesystem.getWorkingDirectory() .. "/tools/validators/lib/?.lua;" .. package.path
else
  -- Standard Lua
  package.path = "./tools/validators/lib/?.lua;" .. package.path
end

-- Load library modules
local SchemaLoader = require("schema_loader")
local FileScanner = require("file_scanner")
local TypeValidator = require("type_validator")
local ReportGenerator = require("report_generator")

---Parse command line arguments
local function parseArgs(arg)
  local args = {
    modPath = nil,
    schema = "api/GAME_API.toml",
    verbose = false,
    json = false,
    markdown = false,
    category = nil,
    output = nil,
  }

  for i, v in ipairs(arg) do
    if v == "--verbose" then
      args.verbose = true
    elseif v == "--json" then
      args.json = true
    elseif v == "--markdown" then
      args.markdown = true
    elseif v == "--schema" and arg[i + 1] then
      args.schema = arg[i + 1]
    elseif v == "--category" and arg[i + 1] then
      args.category = arg[i + 1]
    elseif v == "--output" and arg[i + 1] then
      args.output = arg[i + 1]
    elseif not v:match("^%-") then
      args.modPath = v
    end
  end

  return args
end

---Main validation function
local function main()
  local args = parseArgs(arg)

  -- Validate arguments
  if not args.modPath then
    print("Usage: lovec tools/validators/validate_mod.lua <mod_path> [options]")
    print("")
    print("Options:")
    print("  --verbose              Show detailed output")
    print("  --json                 Output JSON format")
    print("  --markdown             Output markdown format")
    print("  --schema <path>        Path to GAME_API.toml")
    print("  --category <name>      Validate only specific category")
    print("  --output <file>        Write report to file")
    print("")
    print("Examples:")
    print("  lovec tools/validators/validate_mod.lua mods/core")
    print("  lovec tools/validators/validate_mod.lua mods/core --json")
    print("  lovec tools/validators/validate_mod.lua mods/core --category units")
    return 1
  end

  print("")
  print("AlienFall Mod Validator v1.0")
  print("=============================")
  print("")

  -- Load schema
  local ok, result = pcall(function()
    return SchemaLoader.load(args.schema)
  end)

  if not ok then
    print("ERROR: Failed to load schema: " .. tostring(result))
    return 1
  end

  local schema = result

  -- Scan mod folder
  local files = FileScanner.scanMod(args.modPath)

  if #files == 0 then
    print("WARNING: No TOML files found in mod")
    return 0
  end

  -- Create report
  local report = ReportGenerator.createReport()

  -- Validate each file
  for _, filePath in ipairs(files) do
    -- Categorize file
    local category = FileScanner.categorizeFile(filePath, args.modPath)

    if not category then
      ReportGenerator.addFileResult(report, filePath, nil, {
        { field = nil, message = "File location not recognized by API" }
      }, {})
    else
      -- Skip if category filter is active
      if args.category and args.category ~= category then
        goto continue
      end

      -- Get schema definition
      local definition = SchemaLoader.getDefinition(schema, category)

      if not definition then
        ReportGenerator.addFileResult(report, filePath, category, {
          { field = nil, message = "Unknown category: " .. category }
        }, {})
        goto continue
      end

      -- Validate location and naming
      local locationErrors = FileScanner.validateLocation(filePath, args.modPath, category, schema)
      local namingErrors = FileScanner.validateNaming(filePath, category, schema)

      -- Load and parse TOML
      local file, fileErr = io.open(filePath, "r")
      if not file then
        ReportGenerator.addFileResult(report, filePath, category, {
          { field = nil, message = "Cannot open file: " .. (fileErr or "unknown") }
        }, {})
        goto continue
      end

      local content = file:read("*a")
      file:close()

      -- Parse TOML
      local parseOk, tomlData = pcall(function()
        local toml = require("toml") or require("Toml")
        return toml.parse(content)
      end)

      if not parseOk then
        ReportGenerator.addFileResult(report, filePath, category, {
          { field = nil, message = "TOML parse error: " .. tostring(tomlData) }
        }, {})
        goto continue
      end

      -- Validate content
      local errors, warnings = TypeValidator.validate(tomlData, definition, filePath)

      -- Combine all errors
      for _, err in ipairs(locationErrors) do
        table.insert(errors, { field = nil, message = err })
      end
      for _, err in ipairs(namingErrors) do
        table.insert(errors, { field = nil, message = err })
      end

      -- Add results to report
      ReportGenerator.addFileResult(report, filePath, category, errors, warnings)
    end

    ::continue::
  end

  -- Generate output
  local output
  if args.json then
    output = ReportGenerator.json(report)
  elseif args.markdown then
    output = ReportGenerator.markdown(report)
  else
    output = nil  -- console output
  end

  -- Write output
  if args.output then
    local outFile = io.open(args.output, "w")
    if outFile then
      if output then
        outFile:write(output)
      else
        outFile:write(ReportGenerator.markdown(report))  -- Default to markdown for files
      end
      outFile:close()
      print("Report written to: " .. args.output)
    else
      print("ERROR: Cannot write to output file: " .. args.output)
    end
  else
    if output then
      print(output)
    else
      -- Console output
      return ReportGenerator.console(report, args.verbose)
    end
  end

  -- Return exit code
  if report.summary.totalErrors > 0 then
    return 1
  else
    return 0
  end
end

-- Run main function
local exitCode = main()
os.exit(exitCode or 0)
