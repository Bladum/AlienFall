# Import Scanner

Comprehensive tool for scanning Lua files and detecting import/require problems.

## Overview

The Import Scanner detects missing modules, circular dependencies, duplicate requires, and invalid file paths in Lua code. It helps maintain a healthy codebase by preventing common module loading errors.

## Quick Start

### Launch the Tool

**Option 1: PowerShell (Recommended on Windows)**
```powershell
.\tools\import_scanner\scan_imports.ps1
```

**Option 2: Batch File (Windows)**
```batch
.\tools\import_scanner\run_import_scan.bat text
```

**Option 3: Lua (Cross-Platform)**
```bash
lua tools/import_scanner/scan_imports.lua
```

**Option 4: Bash (Linux/Mac)**
```bash
bash tools/import_scanner/scan_imports.sh
```

The scanner runs and generates a detailed report file.

## Features

- **Missing Module Detection**: Finds required files that don't exist
- **Circular Dependency Detection**: Identifies module cycles that can cause issues
- **Duplicate Require Detection**: Finds redundant requires in same file
- **Invalid Path Detection**: Catches malformed or incorrect paths
- **Multiple Output Formats**: Text, JSON, or HTML reports
- **CI/CD Integration**: Exit codes and strict mode for automation
- **Verbose Logging**: Detailed debug information for troubleshooting
- **Performance Analysis**: Statistics about scanning and findings

## How to Use

### Basic Scan

```powershell
.\tools\import_scanner\scan_imports.ps1
```

This scans the engine folder and creates `import_report.txt` with results.

### Specify Output Format

```powershell
# Text report (default)
.\tools\import_scanner\scan_imports.ps1 -Format text

# JSON for machine processing
.\tools\import_scanner\scan_imports.ps1 -Format json -OutputFile report.json

# HTML for viewing in browser
.\tools\import_scanner\scan_imports.ps1 -Format html
```

### Verbose Output

```powershell
# Shows detailed scan progress in console
.\tools\import_scanner\scan_imports.ps1 -Verbose
```

### Strict Mode

```powershell
# Treats warnings as errors (exit code 1)
# Useful for CI/CD pipelines
.\tools\import_scanner\scan_imports.ps1 -Strict
```

### Custom Engine Path

```powershell
# Scan a different folder
.\tools\import_scanner\scan_imports.ps1 -EnginePath "c:\path\to\custom\engine"
```

## File Structure

```
tools/import_scanner/
├── scan_imports.ps1          -- PowerShell implementation (Windows)
├── scan_imports.lua          -- Lua implementation (cross-platform)
├── scan_imports.sh           -- Bash implementation (Linux/Mac)
├── run_import_scan.bat       -- Batch launcher (Windows)
├── quick_scan.ps1            -- Quick scan wrapper
└── README.md                 -- This file
```

## Understanding Reports

### Text Report Example

```
═══════════════════════════════════════════════════════
LUA IMPORT SCANNER REPORT
═══════════════════════════════════════════════════════

Scan Date: 2025-10-22 14:30:45
Engine Path: ./engine

───────────────────────────────────────────────────────
SCAN SUMMARY
───────────────────────────────────────────────────────
Total Files Scanned: 145
Files with Requires: 98
Total Errors: 3
Missing Modules: 5
Circular Dependencies: 1
Duplicate Requires: 2

───────────────────────────────────────────────────────
MISSING MODULES (5)
───────────────────────────────────────────────────────

File: engine/ai/strategic.lua
Module: utils.math_ext (Line 12)
Attempted paths:
  - utils/math_ext.lua
  - utils/math_ext
  - engine/utils/math_ext.lua

Status: NOT FOUND
Suggestion: Check if module name is correct or file is missing
```

### JSON Report Example

```json
{
  "ScanDate": "2025-10-22T14:30:45Z",
  "EnginePath": "./engine",
  "Summary": {
    "FilesScanned": 145,
    "FilesWithRequires": 98,
    "TotalErrors": 3,
    "TotalIssues": 8
  },
  "MissingModules": [
    {
      "File": "engine/ai/strategic.lua",
      "Module": "utils.math_ext",
      "Line": 12,
      "Status": "NOT_FOUND"
    }
  ],
  "CircularDependencies": []
}
```

### HTML Report

Visual report with:
- Summary statistics
- Color-coded issue categories
- File listings with line numbers
- Interactive expandable sections
- Export capability

## Common Issues and Solutions

### Missing Modules

**Problem**: `utils.math_ext` not found

**Solutions**:
1. Check if file exists:
   ```bash
   ls engine/utils/math_ext.lua
   ```

2. Verify path separators (use `/` not `\`):
   ```lua
   -- Correct
   local math = require("utils/math")
   
   -- Incorrect
   local math = require("utils\math")
   ```

3. Check for typos in filename
4. Verify file is in correct directory

### Circular Dependencies

**Problem**: Module A requires B, B requires A

**Example**:
```lua
-- engine/core/game.lua
local state = require("core/state_manager")

-- engine/core/state_manager.lua
local game = require("core/game")  -- CIRCULAR!
```

**Solutions**:
1. **Extract common code**:
   ```lua
   -- Create engine/core/shared.lua with common functionality
   local shared = { ... }
   return shared
   ```

2. **Use late binding**:
   ```lua
   -- Require inside functions, not at module level
   function get_game_state()
       local state = require("core/state_manager")
       return state
   end
   ```

3. **Restructure modules** to break dependency cycle

### Duplicate Requires

**Problem**: Same module required multiple times in one file

**Example**:
```lua
function load_data()
    local utils = require("utils")  -- First require
    return utils.load()
end

function process_data()
    local utils = require("utils")  -- DUPLICATE
    return utils.process()
end
```

**Solution**: Move require to top of file
```lua
local utils = require("utils")

function load_data()
    return utils.load()
end

function process_data()
    return utils.process()
end
```

## Troubleshooting

### Scanner Won't Run

**Problem**: PowerShell: "cannot be loaded because running scripts is disabled"

**Solution**:
```powershell
# Allow PowerShell scripts temporarily
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Then run
.\tools\import_scanner\scan_imports.ps1
```

### Lua Script Errors

**Problem**: `lua: command not found` or module not found

**Solutions**:
1. Check Lua installed:
   ```bash
   lua -v
   ```

2. Use full path:
   ```bash
   C:\Lua\lua.exe tools/import_scanner/scan_imports.lua
   ```

3. Use Love2D instead:
   ```bash
   lovec tools/import_scanner
   ```

### Report Not Created

**Problem**: Scanner runs but no output file

**Solutions**:
1. Check current directory:
   ```powershell
   Get-Location
   ```

2. Run from project root:
   ```bash
   cd c:\Users\tombl\Documents\Projects
   .\tools\import_scanner\scan_imports.ps1
   ```

3. Specify explicit output path:
   ```powershell
   .\tools\import_scanner\scan_imports.ps1 -OutputFile "C:\temp\report.txt"
   ```

### Too Many False Positives

**Problem**: Scanner reports issues that aren't real

**Solutions**:
1. Check that paths are correct in report
2. Verify case sensitivity matches file system
3. Check for symlinks or junction points
4. Run with `-Verbose` for detailed debug info

## CI/CD Integration

### GitHub Actions

```yaml
name: Lua Import Scan

on: [push, pull_request]

jobs:
  scan:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Scan Lua Imports
        run: |
          powershell -ExecutionPolicy Bypass -File "tools/import_scanner/scan_imports.ps1" `
            -Format text `
            -Strict `
            -OutputFile "import_scan_report.txt"
            
      - name: Upload Report
        if: always()
        uses: actions/upload-artifact@v2
        with:
          name: import-scan-report
          path: import_scan_report.txt
```

### Local Git Hook

Create `.git/hooks/pre-commit`:
```bash
#!/bin/bash
cd "$(git rev-parse --show-toplevel)"

powershell -ExecutionPolicy Bypass -File "tools/import_scanner/scan_imports.ps1" -Strict

if [ $? -ne 0 ]; then
    echo "Lua import scan failed. Fix issues before committing."
    exit 1
fi
```

Make executable:
```bash
chmod +x .git/hooks/pre-commit
```

## Advanced Usage

### Quick Scan Wrapper

```powershell
.\tools\import_scanner\quick_scan.ps1
```

Runs scan with optimal settings and auto-opens results.

### Batch Processing

To scan multiple projects:

```powershell
$projects = @("engine", "tests", "tools")

foreach ($project in $projects) {
    .\tools\import_scanner\scan_imports.ps1 -EnginePath $project
}
```

### Performance Analysis

Check scan statistics:
```powershell
# Verbose output shows scan performance
.\tools\import_scanner\scan_imports.ps1 -Verbose

# JSON format for metric extraction
.\tools\import_scanner\scan_imports.ps1 -Format json | ConvertFrom-Json
```

## Console Output

When running with `-Verbose`:

```
[Import Scanner] Scanning: ./engine
[Import Scanner] Found 145 Lua files
[Import Scanner] Processing: engine/core/state_manager.lua
[Import Scanner] Found 8 requires in engine/core/state_manager.lua
[Import Scanner] Checking: core/game
[Import Scanner] Status: OK (engine/core/game.lua)
[Import Scanner] Scan complete
[Import Scanner] Issues found: 8
[Import Scanner] Report written: import_report.txt
```

## Related Tools

- **Asset Verification** - Verify asset references (parallel tool)
- **Map Editor** - Visual map editing
- **Spritesheet Generator** - Asset management

## Related Documentation

- `wiki/DEVELOPMENT.md` - Development workflow
- `wiki/API.md` - API reference
- `docs/CODE_STANDARDS.md` - Code quality standards
- `engine/` - Main engine code

## See Also

- **Main Tools README** - `tools/README.md`
- **Project Structure** - `wiki/PROJECT_STRUCTURE.md`
