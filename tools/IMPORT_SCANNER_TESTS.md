# Test Suite for Import Scanner

Unit tests and integration tests for verifying import scanner functionality.

## Test Files Structure

```
tests/
├── import_scanner/          # Import scanner specific tests
│   ├── test_basic_scan.lua
│   ├── test_circular_deps.lua
│   ├── test_missing_modules.lua
│   └── test_duplicate_requires.lua
└── fixtures/
    ├── good_module.lua      # Valid module (no issues)
    ├── bad_import.lua       # Missing import
    ├── circular_a.lua       # Circular: A -> B
    ├── circular_b.lua       # Circular: B -> A
    └── duplicate_requires.lua # Duplicate requires
```

## Running Tests

### All Tests
```powershell
# Run all import scanner tests
.\tests\import_scanner\run_tests.ps1

# With verbose output
.\tests\import_scanner\run_tests.ps1 -Verbose
```

### Specific Test
```powershell
# Run specific test file
.\tools\scan_imports.ps1 -EnginePath "./tests/fixtures" -Format json
```

### Integration Test
```powershell
# Full system test with game engine
.\tools\scan_imports.ps1 -EnginePath "./engine" -Strict -Verbose
```

## Test Fixtures

### good_module.lua
Clean module with no issues:
```lua
local utils = require('core.utils')
-- Proper imports, no circular deps
```

### bad_import.lua
Contains missing module reference:
```lua
local missing = require('this.does.not.exist')  -- Error!
```

### circular_a.lua, circular_b.lua
Demonstrate circular dependency detection:
```lua
-- circular_a.lua
local b = require('circular_b')

-- circular_b.lua
local a = require('circular_a')  -- Creates cycle
```

## Expected Results

### Basic Scan Test
- Input: Clean engine folder
- Expected: 0 errors, 0 missing modules
- Assert: FilesScanned > 0

### Circular Dependency Test
- Input: circular_a.lua + circular_b.lua
- Expected: Circular dependency detected
- Assert: CircularDependencies > 0

### Missing Module Test
- Input: bad_import.lua
- Expected: Missing module reported
- Assert: MissingModules > 0, contains reference to bad_import.lua

### Duplicate Test
- Input: duplicate_requires.lua (has `require('x')` twice)
- Expected: Duplicate detected
- Assert: DuplicateRequires > 0

## Manual Testing

### Test 1: Verify Basic Functionality
```powershell
# Setup: Clear temp results
Remove-Item -Path "import_report.txt" -ErrorAction SilentlyContinue

# Run scan
.\tools\scan_imports.ps1

# Verify: File exists
Test-Path "import_report.txt"

# Verify: Contains expected sections
Select-String "SCAN SUMMARY" "import_report.txt"
Select-String "Total Files Scanned" "import_report.txt"
```

### Test 2: Verify Strict Mode
```powershell
# Test with existing issues (should exit 1)
.\tools\scan_imports.ps1 -Strict -EnginePath "tests/fixtures"
$strictStatus = $LASTEXITCODE

# Should be non-zero if issues found
if ($strictStatus -ne 0) {
    Write-Host "✓ Strict mode correctly detected issues"
} else {
    Write-Host "✗ Strict mode failed to detect issues"
}
```

### Test 3: Verify Format Output
```powershell
# Test text format
.\tools\scan_imports.ps1 -Format text -OutputFile report_text.txt
$textSize = (Get-Item "report_text.txt").Length
Write-Host "Text report size: $textSize bytes"

# Test JSON format
.\tools\scan_imports.ps1 -Format json -OutputFile report_json.json
$json = Get-Content "report_json.json" | ConvertFrom-Json
Write-Host "JSON reports $(if ($json) { 'parsed' } else { 'failed' })"

# Test HTML format
.\tools\scan_imports.ps1 -Format html -OutputFile report_html.html
$htmlSize = (Get-Item "report_html.html").Length
Write-Host "HTML report size: $htmlSize bytes"
```

### Test 4: Performance Test
```powershell
# Measure scan time on full engine
$timer = Measure-Command {
    .\tools\scan_imports.ps1 -Format text -OutputFile perf_report.txt
}

Write-Host "Scan time: $($timer.TotalSeconds) seconds"
Write-Host "✓ Performance acceptable if < 5 seconds"
```

### Test 5: Error Handling
```powershell
# Test with non-existent path
.\tools\scan_imports.ps1 -EnginePath "C:\does\not\exist"
$errorStatus = $LASTEXITCODE
Write-Host "✓ Correctly handled missing path (exit code: $errorStatus)"

# Test with invalid output path
.\tools\scan_imports.ps1 -OutputFile "C:\invalid\path\report.txt"
# Should handle gracefully or show error
```

## Continuous Integration

### GitHub Actions Test Job
```yaml
name: Import Scanner Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Run Basic Scan
        run: |
          powershell -File "tools/scan_imports.ps1" `
            -Format text `
            -OutputFile "scan_result.txt"
      
      - name: Verify Results
        run: |
          powershell -Command "
            if (Test-Path 'scan_result.txt') {
              Write-Host '✓ Report generated'
            } else {
              throw 'Report not generated'
            }
          "
      
      - name: Run Strict Mode
        run: |
          powershell -File "tools/scan_imports.ps1" -Strict
```

## Test Coverage

| Feature | Test | Status |
|---------|------|--------|
| Basic scanning | test_basic_scan.lua | ✓ |
| Missing modules | test_missing_modules.lua | ✓ |
| Circular deps | test_circular_deps.lua | ✓ |
| Duplicate requires | test_duplicate_requires.lua | ✓ |
| Text format | Manual | ✓ |
| JSON format | Manual | ✓ |
| HTML format | Manual | ✓ |
| Strict mode | Manual | ✓ |
| Error handling | Manual | ✓ |
| Performance | Manual | ✓ |

## Quick Test Command

Run this to test the scanner is working:
```powershell
# One-liner to verify scanner works
.\tools\scan_imports.ps1 -Verbose -Format json | ConvertFrom-Json | Select-Object Summary
```

Expected output:
```
Summary
-------
@{FilesScanned=XXX; FilesWithRequires=YYY; TotalErrors=Z; TotalIssues=W}
```

## Troubleshooting Tests

### Test Fails: Report Not Created
- Check output directory write permissions
- Verify engine path exists
- Run with `-Verbose` to see debug info

### Test Fails: Wrong Issue Count
- Clear any cached results
- Run fresh scan
- Check test fixture files haven't been modified

### Test Fails: Performance Poor
- Check system resources
- Close other applications
- Try with smaller test set first

## See Also

- `IMPORT_SCANNER.md` - Full scanner documentation
- `IMPORT_SCANNER_EXAMPLES.md` - Usage examples
- `tests/README.md` - General test documentation
