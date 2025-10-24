#!/usr/bin/env lua
-- validate_content.lua - Content Validator Main Script
-- Validates mod content for internal consistency
-- Usage: lovec tools/validators/validate_content.lua <mod_path> [options]
--
-- Options:
--   --verbose       Show detailed output
--   --json          Output JSON format
--   --skip-assets   Skip asset file validation
--   --only-assets   Only validate asset files
--   --category      Validate specific category
--   --output        Write report to file

-- Setup paths for require
if love then
  -- Love2D environment
  package.path = love.filesystem.getWorkingDirectory() .. "/tools/validators/lib/?.lua;" .. package.path
else
  -- Standard Lua
  package.path = "./tools/validators/lib/?.lua;" .. package.path
end

-- Load library modules
local ContentLoader = require("content_loader")
local ReferenceValidator = require("reference_validator")
local AssetValidator = require("asset_validator")
local TechTreeValidator = require("tech_tree_validator")
local BalanceValidator = require("balance_validator")
local ReportGenerator = require("report_generator")

-- Parse command line arguments
local function parseArgs(arg)
  local args = {
    modPath = nil,
    verbose = false,
    json = false,
    markdown = false,
    skipAssets = false,
    onlyAssets = false,
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
    elseif v == "--skip-assets" then
      args.skipAssets = true
    elseif v == "--only-assets" then
      args.onlyAssets = true
    elseif v == "--category" and arg[i + 1] then
      args.category = arg[i + 1]
    elseif v == "--output" and arg[i + 1] then
      args.output = arg[i + 1]
    elseif not v:match("^%-") and not args.modPath then
      args.modPath = v
    end
  end
  
  return args
end

-- Print to console or file
local function print_output(file, text)
  if file then
    file:write(text .. "\n")
  else
    print(text)
  end
end

-- Main validation function
local function main()
  local args = parseArgs(arg)
  
  -- Validate arguments
  if not args.modPath then
    io.stderr:write("Usage: lovec tools/validators/validate_content.lua <mod_path> [options]\n")
    io.stderr:write("Options:\n")
    io.stderr:write("  --verbose       Show detailed output\n")
    io.stderr:write("  --json          Output JSON format\n")
    io.stderr:write("  --markdown      Output markdown format\n")
    io.stderr:write("  --skip-assets   Skip asset file validation\n")
    io.stderr:write("  --only-assets   Only validate asset files\n")
    io.stderr:write("  --category      Validate specific category\n")
    io.stderr:write("  --output        Write report to file\n")
    os.exit(1)
  end
  
  -- Open output file if specified
  local outFile = nil
  if args.output then
    outFile = io.open(args.output, "w")
    if not outFile then
      io.stderr:write("Error: Cannot open output file: " .. args.output .. "\n")
      os.exit(1)
    end
  end
  
  local out = function(text) print_output(outFile, text) end
  
  -- Header
  out("=" .. string.rep("=", 70) .. "=")
  out("Content Validator - Checking Mod Internal Consistency")
  out("=" .. string.rep("=", 70) .. "=")
  out("")
  out("Mod Path: " .. args.modPath)
  out("")
  
  -- Load mod
  out("Loading mod content...")
  local mod, err = ContentLoader.loadMod(args.modPath)
  
  if not mod then
    out("ERROR: Failed to load mod: " .. tostring(err))
    os.exit(1)
  end
  
  local index = ContentLoader.buildIndex(mod)
  local totalEntities = ContentLoader.countEntities(mod)
  
  out("Loaded " .. totalEntities .. " entities")
  out("")
  
  -- Initialize results
  local allErrors = {}
  local allWarnings = {}
  local validations = {}
  
  -- Run validations
  if not args.onlyAssets then
    out("Validating entity references...")
    local refErrors = ReferenceValidator.validate(mod, index)
    for _, err in ipairs(refErrors) do
      table.insert(allErrors, err)
    end
    out("  Found " .. #refErrors .. " reference errors")
    table.insert(validations, {name = "References", errors = #refErrors, warnings = 0})
  end
  
  if not args.skipAssets then
    out("Validating asset files...")
    local assetErrors = AssetValidator.validate(mod, args.modPath)
    for _, err in ipairs(assetErrors) do
      table.insert(allErrors, err)
    end
    out("  Found " .. #assetErrors .. " missing assets")
    table.insert(validations, {name = "Assets", errors = #assetErrors, warnings = 0})
  end
  
  if not args.onlyAssets then
    out("Validating tech tree...")
    if mod.research and next(mod.research) then
      local techErrors, techWarnings = TechTreeValidator.validate(mod.research, index)
      for _, err in ipairs(techErrors) do
        table.insert(allErrors, err)
      end
      for _, warn in ipairs(techWarnings) do
        table.insert(allWarnings, warn)
      end
      out("  Found " .. #techErrors .. " tech tree errors, " .. #techWarnings .. " warnings")
      table.insert(validations, {name = "Tech Tree", errors = #techErrors, warnings = #techWarnings})
    else
      out("  (No research/tech tree in mod)")
    end
    
    out("Running balance sanity checks...")
    local balanceWarnings = BalanceValidator.validate(mod)
    for _, warn in ipairs(balanceWarnings) do
      table.insert(allWarnings, warn)
    end
    out("  Found " .. #balanceWarnings .. " balance warnings")
    table.insert(validations, {name = "Balance", errors = 0, warnings = #balanceWarnings})
  end
  
  out("")
  
  -- Summary
  local totalErrors = #allErrors
  local totalWarnings = #allWarnings
  
  out("=" .. string.rep("=", 70) .. "=")
  out("VALIDATION SUMMARY")
  out("=" .. string.rep("=", 70) .. "=")
  out("")
  out("Total entities checked: " .. totalEntities)
  out("Total errors found: " .. totalErrors)
  out("Total warnings found: " .. totalWarnings)
  out("")
  
  -- Validation breakdown
  if args.verbose then
    out("Validation Breakdown:")
    for _, val in ipairs(validations) do
      out("  " .. val.name .. ": " .. val.errors .. " errors, " .. val.warnings .. " warnings")
    end
    out("")
  end
  
  -- Error details
  if totalErrors > 0 then
    out("=" .. string.rep("=", 70) .. "=")
    out("ERRORS (" .. totalErrors .. ")")
    out("=" .. string.rep("=", 70) .. "=")
    out("")
    
    local errorsByType = {}
    for _, err in ipairs(allErrors) do
      local errType = err.type or "unknown"
      if not errorsByType[errType] then
        errorsByType[errType] = {}
      end
      table.insert(errorsByType[errType], err)
    end
    
    for errType, errors in pairs(errorsByType) do
      out(string.upper(errType) .. " (" .. #errors .. " errors)")
      
      for i, err in ipairs(errors) do
        if i > 10 and not args.verbose then
          out("  ... and " .. (#errors - 10) .. " more (use --verbose to see all)")
          break
        end
        
        out("  " .. i .. ". " .. err.message)
        if err.entity then
          out("     Entity: " .. err.entity)
        end
        if err.reference then
          out("     Reference: " .. err.reference)
        end
        if err.field then
          out("     Field: " .. err.field)
        end
        if err.file and args.verbose then
          out("     File: " .. err.file)
        end
      end
      out("")
    end
  end
  
  -- Warning details
  if totalWarnings > 0 and args.verbose then
    out("=" .. string.rep("=", 70) .. "=")
    out("WARNINGS (" .. totalWarnings .. ")")
    out("=" .. string.rep("=", 70) .. "=")
    out("")
    
    local warningsByType = {}
    for _, warn in ipairs(allWarnings) do
      local warnType = warn.type or "unknown"
      if not warningsByType[warnType] then
        warningsByType[warnType] = {}
      end
      table.insert(warningsByType[warnType], warn)
    end
    
    for warnType, warnings in pairs(warningsByType) do
      out(string.upper(warnType) .. " (" .. #warnings .. " warnings)")
      
      for i, warn in ipairs(warnings) do
        if i > 5 then
          out("  ... and " .. (#warnings - 5) .. " more")
          break
        end
        
        out("  " .. i .. ". " .. warn.message)
        if warn.tech then
          out("     Tech: " .. warn.tech)
        end
        if warn.entity then
          out("     Entity: " .. warn.entity)
        end
      end
      out("")
    end
  end
  
  -- Result
  out("=" .. string.rep("=", 70) .. "=")
  if totalErrors > 0 then
    out("❌ CONTENT VALIDATION FAILED - " .. totalErrors .. " error(s) found")
    if totalWarnings > 0 then
      out("⚠️  Also " .. totalWarnings .. " warning(s) found")
    end
  else
    out("✅ CONTENT VALIDATION PASSED")
    if totalWarnings > 0 then
      out("⚠️  " .. totalWarnings .. " warning(s) found (review recommended)")
    end
  end
  out("=" .. string.rep("=", 70) .. "=")
  out("")
  
  -- JSON output
  if args.json then
    out("JSON Report:")
    local report = {
      summary = {
        modPath = args.modPath,
        entitiesChecked = totalEntities,
        totalErrors = totalErrors,
        totalWarnings = totalWarnings,
        passed = totalErrors == 0,
      },
      errors = allErrors,
      warnings = allWarnings,
    }
    
    -- Simple JSON encoding
    local json = ReportGenerator.toJSON(report)
    out(json)
  end
  
  -- Close output file
  if outFile then
    outFile:close()
    io.stderr:write("Report written to: " .. args.output .. "\n")
  end
  
  -- Exit with appropriate code
  if totalErrors > 0 then
    os.exit(1)
  else
    os.exit(0)
  end
end

-- Run main
main()
