# Lua Import Scanner

Comprehensive tool suite for scanning Lua files in the engine folder for potential import/require problems and generating detailed reports.

## Overview

The scanner detects:
- **Missing Modules**: Required files that don't exist
- **Circular Dependencies**: Module A requires B, B requires A
- **Duplicate Requires**: Same module required multiple times in one file
- **Invalid Paths**: Incorrect or malformed require statements
- **Unused Requires**: Modules that are required but never used (planned feature)

## Installation

### Requirements
- Windows: PowerShell 5.0+, Lua 5.1+ (for Lua script), or Git Bash
- Linux/Mac: Bash 4.0+, Lua 5.1+

### Setup
All scripts are located in the `tools/` folder:
```
tools/
├── scan_imports.ps1       # PowerShell implementation (recommended on Windows)
├── scan_imports.lua       # Pure Lua implementation (cross-platform)
├── scan_imports.sh        # Bash implementation (Linux/Mac)
├── run_import_scan.bat    # Windows batch launcher
├── quick_scan.ps1         # Quick wrapper script
└── IMPORT_SCANNER.md      # This file
```

## Quick Start

### Windows (Recommended)
```powershell
# Method 1: Using batch script
.\run_import_scan.bat text

# Method 2: Using PowerShell directly
.\tools\scan_imports.ps1 -OutputFile report.txt -Format text

# Method 3: Quick scan with HTML report
.\tools\quick_scan.ps1 -Format html -Open
```

### Windows (Alternative - Lua)
```bash
lua tools\scan_imports.lua --engine-path engine --output report.txt --format text
```

### Linux/Mac
```bash
bash tools/scan_imports.sh --engine-path engine --output report.txt --verbose
```

## Usage

### PowerShell Script
```powershell
.\tools\scan_imports.ps1 [Options]

Options:
  -EnginePath PATH      Path to engine folder (default: ./engine)
  -OutputFile FILE      Output report file (default: import_report.txt)
  -Format FORMAT        Report format: text|json|html (default: text)
  -Verbose              Show detailed scan progress
  -Strict               Treat warnings as errors (exit code 1)
```

#### Examples
```powershell
# Basic scan with text output
.\tools\scan_imports.ps1

# Verbose scan with JSON output
.\tools\scan_imports.ps1 -Verbose -Format json -OutputFile scan.json

# Strict mode (fail on any issue)
.\tools\scan_imports.ps1 -Strict -Format text

# HTML report with auto-open
.\tools\quick_scan.ps1 -Format html -Open
```

### Batch Script
```batch
run_import_scan.bat [FORMAT] [OPTIONS]

FORMAT:  text (default), json, html
OPTIONS: --verbose, --strict
```

#### Examples
```batch
REM Basic scan
run_import_scan.bat

REM JSON output
run_import_scan.bat json

REM Verbose HTML scan
run_import_scan.bat html --verbose

REM Strict mode
run_import_scan.bat text --strict
```

### Lua Script
```bash
lua tools/scan_imports.lua [Options]

Options:
  --engine-path PATH    Path to engine folder (default: ./engine)
  --output FILE         Output report file (default: import_report.txt)
  --format FORMAT       Report format: text|json|html (default: text)
  --verbose             Show detailed scan progress
  --strict              Treat warnings as errors
```

#### Examples
```bash
# Basic scan
lua tools/scan_imports.lua

# Custom engine path
lua tools/scan_imports.lua --engine-path ./engine --verbose

# JSON output
lua tools/scan_imports.lua --format json --output scan.json

# Strict mode
lua tools/scan_imports.lua --strict
```

### Bash Script
```bash
bash tools/scan_imports.sh [Options]

Options:
  --engine-path PATH    Path to engine folder (default: ./engine)
  --output FILE         Output report file (default: import_report.txt)
  --format FORMAT       Report format: text|json (default: text)
  --verbose             Show detailed scan progress
  --strict              Treat warnings as errors
```

## Output Formats

### Text Format (Default)
Human-readable report with sections:
- **Scan Summary**: Statistics about files scanned and issues found
- **Errors**: Critical issues that prevent module loading
- **Missing Modules**: Required files that don't exist
- **Circular Dependencies**: Dependency cycles that could cause issues
- **Duplicate Requires**: Redundant require statements

Example:
```
═══════════════════════════════════════════════════════
LUA IMPORT SCANNER REPORT
═══════════════════════════════════════════════════════

Scan Date: 2025-10-16 14:30:45
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
```

### JSON Format
Machine-readable format for integration with other tools:
```json
{
  "ScanDate": "2025-10-16T14:30:45Z",
  "EnginePath": "./engine",
  "Summary": {
    "FilesScanned": 145,
    "FilesWithRequires": 98,
    "TotalErrors": 3,
    "TotalIssues": 8
  },
  "Errors": [
    {
      "File": "engine/core/state_manager.lua",
      "Message": "Cannot read file: permission denied"
    }
  ],
  "MissingModules": [
    {
      "File": "engine/ai/strategic.lua",
      "Module": "utils.math_ext",
      "Line": 12,
      "AttemptedPaths": [...]
    }
  ]
}
```

### HTML Format
Interactive visual report (minimal version, can be enhanced):
- Summary statistics
- Color-coded issue categories
- File and module information
- Timestamp and metadata

## Understanding Reports

### Missing Modules
When a module cannot be found:
1. Check if the file exists
2. Verify the require statement uses correct path
3. Ensure file is not misspelled or in wrong directory
4. Check if path separators are correct (/ not \)

Example fix:
```lua
-- Before (wrong)
local math_ext = require('utils.math_ext')

-- After (correct)
local math_ext = require('utils/math_ext')
```

### Circular Dependencies
When modules form a cycle:
1. File A requires B
2. File B requires A
3. Creates a circular loop

**Impact**: Can cause loading order issues or infinite recursion

**Solution**: Refactor to break the cycle:
- Move common code to a third module
- Use late binding (require inside functions)
- Restructure module hierarchy

Example:
```lua
-- Before (circular)
-- engine/core/game.lua
local state = require('core.state_manager')

-- engine/core/state_manager.lua
local game = require('core.game')

-- After (fixed)
-- Create new module with shared code
-- engine/core/shared.lua
local shared = { ... }

-- Now both can require from shared
```

### Duplicate Requires
Same module required multiple times in one file:

**Impact**: Minor - unnecessary overhead, poor code organization

**Solution**: Move require to top of file or extract into helper function

```lua
-- Before
function load_data()
    local utils = require('utils')
    return utils.load()
end

function process_data()
    local utils = require('utils')  -- Duplicate!
    return utils.process()
end

-- After
local utils = require('utils')

function load_data()
    return utils.load()
end

function process_data()
    return utils.process()
end
```

## Troubleshooting

### PowerShell Script Won't Run
```powershell
# Check execution policy
Get-ExecutionPolicy

# Temporarily allow script execution
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Then run script
.\tools\scan_imports.ps1
```

### Lua Script Shows Errors
```bash
# Check Lua is installed
lua -v

# Run with explicit path
C:\path\to\lua.exe tools\scan_imports.lua
```

### Engine Path Not Found
```powershell
# Check current working directory
(Get-Location).Path

# Run from project root
cd C:\Users\tombl\Documents\Projects
.\tools\scan_imports.ps1

# Or specify absolute path
.\tools\scan_imports.ps1 -EnginePath "C:\Users\tombl\Documents\Projects\engine"
```

### Report File Not Created
```powershell
# Check write permissions
Test-Path -Path (Get-Location)

# Try alternative output location
.\tools\scan_imports.ps1 -OutputFile "$env:TEMP\import_report.txt"

# Check file is not locked
Get-ChildItem -Path "import_report.txt" | Select-Object -Property *
```

## Integration with CI/CD

### GitHub Actions
```yaml
name: Lua Import Scanner

on: [push, pull_request]

jobs:
  scan:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      - name: Scan Imports
        run: |
          powershell -ExecutionPolicy Bypass -File "tools/scan_imports.ps1" `
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
powershell -File "tools/scan_imports.ps1" -Strict
if [ $? -ne 0 ]; then
    echo "Import scan failed. Fix issues before committing."
    exit 1
fi
```

## Advanced Usage

### Analyzing Dependency Graph
The scanner generates a dependency graph showing which files require which modules:
```
File: engine/ai/strategic.lua
  Requires:
    - utils/math ✓
    - core/state_manager ✓
    - config/ai_config ✗ (missing)
```

### Performance Considerations
- Scanner processes entire engine directory recursively
- Maximum recursion depth: 50 levels (prevents infinite loops)
- Duplicate file processing is avoided
- Memory usage: ~100KB per 100 Lua files

### Custom Configuration
Edit scanner script to modify:
- `maxDepth`: Maximum recursion level (default: 50)
- `Pattern`: File pattern to scan (default: `*.lua`)
- Report sections and formatting

## Common Patterns

### Proper Module Structure
```lua
-- engine/utils/math.lua
local math_utils = {}

function math_utils.add(a, b)
    return a + b
end

return math_utils
```

```lua
-- engine/core/calculator.lua
local math = require('utils/math')

function calculator(a, b)
    return math.add(a, b)
end
```

### Avoiding Circular Dependencies
```lua
-- ✓ Good: Late binding
function get_game_state()
    local state = require('core.state_manager')
    return state.get()
end

-- ✓ Good: Shared module
-- engine/core/shared.lua - common functionality
local shared = require('core.shared')
-- Both modules can now use shared code
```

## Performance Tips

1. **Reduce Require Calls**: Move requires to file top
2. **Avoid Circular References**: Keep module hierarchy linear
3. **Use Local References**: Don't re-require frequently
4. **Lazy Load When Needed**: Only require inside functions when necessary

## Reporting Issues

If scanner reports false positives:
1. Check actual require statement in file
2. Verify file exists and path is correct
3. Run with `--verbose` for detailed debug info
4. Check that Lua files use correct naming (snake_case)

## See Also

- `wiki/DEVELOPMENT.md` - Development workflow
- `wiki/API.md` - API reference
- `engine/main.lua` - Game entry point
- `tasks/TASK_TEMPLATE.md` - Task documentation

## License

Part of AlienFall/XCOM Simple project. See LICENSE file.
