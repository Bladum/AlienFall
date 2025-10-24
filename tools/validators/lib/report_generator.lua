-- ReportGenerator: Format validation results for different outputs
-- Generates human-readable console output and machine-readable JSON

local ReportGenerator = {}

---Generate console report with colors
---@param report table The validation report
---@param verbose boolean Show verbose output
function ReportGenerator.console(report, verbose)
  local function colorize(text, color)
    -- Simple color codes for Windows/Unix
    local colors = {
      reset = "\27[0m",
      red = "\27[31m",
      green = "\27[32m",
      yellow = "\27[33m",
      blue = "\27[34m",
      gray = "\27[90m",
    }
    return (colors[color] or "") .. text .. (colors.reset or "")
  end

  -- Header
  print("")
  print(colorize("=== Mod Validation Report ===", "blue"))
  print("")

  -- Summary
  local summary = report.summary
  print("Summary:")
  print("  Files checked: " .. summary.filesChecked)
  print("  Files valid: " .. colorize(summary.filesValid .. "", "green"))
  print("  Files with errors: " .. colorize(summary.filesWithErrors .. "", "red"))
  print("  Files with warnings: " .. colorize(summary.filesWithWarnings .. "", "yellow"))
  print("  Total errors: " .. colorize(summary.totalErrors .. "", "red"))
  print("  Total warnings: " .. colorize(summary.totalWarnings .. "", "yellow"))
  print("")

  -- File-by-file results
  if verbose or summary.totalErrors > 0 then
    print("Details:")
    print("")

    for _, fileReport in ipairs(report.files) do
      local status = "✓"
      local statusColor = "green"

      if fileReport.errors and #fileReport.errors > 0 then
        status = "✗"
        statusColor = "red"
      elseif fileReport.warnings and #fileReport.warnings > 0 then
        status = "⚠"
        statusColor = "yellow"
      end

      print(colorize(status, statusColor) .. " " .. fileReport.path)

      -- Show errors
      if fileReport.errors and #fileReport.errors > 0 then
        for _, error in ipairs(fileReport.errors) do
          print("    " .. colorize("ERROR", "red") .. " [" .. (error.field or "unknown") .. "]: " .. error.message)
        end
      end

      -- Show warnings
      if fileReport.warnings and #fileReport.warnings > 0 then
        for _, warning in ipairs(fileReport.warnings) do
          print("    " .. colorize("WARNING", "yellow") .. " [" .. (warning.field or "unknown") .. "]: " .. warning.message)
        end
      end

      if verbose and fileReport.valid then
        print("    All checks passed")
      end

      print("")
    end
  end

  -- Final result
  print(colorize("=== Result ===", "blue"))
  if summary.totalErrors > 0 then
    print(colorize("❌ VALIDATION FAILED", "red") .. " - " .. summary.totalErrors .. " error(s) found")
    return 1
  else
    print(colorize("✅ VALIDATION PASSED", "green"))
    if summary.totalWarnings > 0 then
      print("   (with " .. summary.totalWarnings .. " warning(s))")
    end
    return 0
  end
end

---Generate JSON report for machine parsing
---@param report table The validation report
---@return string jsonString JSON formatted report
function ReportGenerator.json(report)
  -- Simple JSON serialization
  local function serializeValue(value)
    if type(value) == "string" then
      return '"' .. value:gsub('"', '\\"') .. '"'
    elseif type(value) == "number" then
      return tostring(value)
    elseif type(value) == "boolean" then
      return value and "true" or "false"
    elseif type(value) == "table" then
      if #value > 0 then
        -- Array
        local items = {}
        for _, v in ipairs(value) do
          table.insert(items, serializeValue(v))
        end
        return "[" .. table.concat(items, ",") .. "]"
      else
        -- Object
        local pairs_list = {}
        for k, v in pairs(value) do
          table.insert(pairs_list, '"' .. k .. '":' .. serializeValue(v))
        end
        return "{" .. table.concat(pairs_list, ",") .. "}"
      end
    end
    return "null"
  end

  return serializeValue(report)
end

---Generate markdown report for documentation
---@param report table The validation report
---@return string markdownString Markdown formatted report
function ReportGenerator.markdown(report)
  local md = {}

  table.insert(md, "# Mod Validation Report\n")
  table.insert(md, "## Summary\n")

  local summary = report.summary
  table.insert(md, "- **Files checked:** " .. summary.filesChecked)
  table.insert(md, "- **Valid files:** " .. summary.filesValid)
  table.insert(md, "- **Files with errors:** " .. summary.filesWithErrors)
  table.insert(md, "- **Files with warnings:** " .. summary.filesWithWarnings)
  table.insert(md, "- **Total errors:** " .. summary.totalErrors)
  table.insert(md, "- **Total warnings:** " .. summary.totalWarnings)
  table.insert(md, "\n")

  if summary.totalErrors > 0 then
    table.insert(md, "## Errors\n")
    for _, fileReport in ipairs(report.files) do
      if fileReport.errors and #fileReport.errors > 0 then
        table.insert(md, "### " .. fileReport.path .. "\n")
        for _, error in ipairs(fileReport.errors) do
          table.insert(md, "- **" .. (error.field or "Unknown") .. "**: " .. error.message)
        end
        table.insert(md, "\n")
      end
    end
  end

  if summary.totalWarnings > 0 then
    table.insert(md, "## Warnings\n")
    for _, fileReport in ipairs(report.files) do
      if fileReport.warnings and #fileReport.warnings > 0 then
        table.insert(md, "### " .. fileReport.path .. "\n")
        for _, warning in ipairs(fileReport.warnings) do
          table.insert(md, "- **" .. (warning.field or "Unknown") .. "**: " .. warning.message)
        end
        table.insert(md, "\n")
      end
    end
  end

  return table.concat(md, "\n")
end

---Create new report structure
---@return table report
function ReportGenerator.createReport()
  return {
    summary = {
      filesChecked = 0,
      filesValid = 0,
      filesWithErrors = 0,
      filesWithWarnings = 0,
      totalErrors = 0,
      totalWarnings = 0,
    },
    files = {},
  }
end

---Add file result to report
---@param report table The report to update
---@param filePath string Path to the file
---@param category string Entity category
---@param errors table Array of errors
---@param warnings table Array of warnings
function ReportGenerator.addFileResult(report, filePath, category, errors, warnings)
  report.summary.filesChecked = report.summary.filesChecked + 1

  local isValid = #errors == 0
  if isValid then
    report.summary.filesValid = report.summary.filesValid + 1
  else
    report.summary.filesWithErrors = report.summary.filesWithErrors + 1
    report.summary.totalErrors = report.summary.totalErrors + #errors
  end

  if #warnings > 0 then
    report.summary.filesWithWarnings = report.summary.filesWithWarnings + 1
    report.summary.totalWarnings = report.summary.totalWarnings + #warnings
  end

  table.insert(report.files, {
    path = filePath,
    category = category,
    valid = isValid,
    errors = errors,
    warnings = warnings,
  })
end

return ReportGenerator
