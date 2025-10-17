# Import Scanner Examples

Quick command examples and use cases for the Lua import scanner.

## Basic Usage

### Windows - Quick Scan
```powershell
# Run from project root
.\tools\quick_scan.ps1

# Or using batch script
.\tools\run_import_scan.bat
```

### Windows - Full Reports
```powershell
# Text report (console-friendly)
.\tools\scan_imports.ps1 -Format text -OutputFile report.txt

# JSON report (for parsing/analysis)
.\tools\scan_imports.ps1 -Format json -OutputFile report.json

# HTML report (visual inspection)
.\tools\scan_imports.ps1 -Format html -OutputFile report.html

# HTML with auto-open
.\tools\quick_scan.ps1 -Format html -Open
```

### Windows - Detailed Analysis
```powershell
# Verbose mode - see every file being scanned
.\tools\scan_imports.ps1 -Verbose -OutputFile verbose_report.txt

# Strict mode - exit with error if ANY issues found
.\tools\scan_imports.ps1 -Strict -OutputFile report.txt

# Combined
.\tools\scan_imports.ps1 -Verbose -Strict -Format json -OutputFile detailed.json
```

### Windows - Custom Engine Path
```powershell
# Scan different engine location
.\tools\scan_imports.ps1 -EnginePath "C:\path\to\other\engine" -OutputFile other_report.txt

# Scan with relative path
.\tools\scan_imports.ps1 -EnginePath "../backup/engine" -OutputFile backup_report.txt
```

## Linux/Mac Usage

### Basic Scan
```bash
bash tools/scan_imports.sh --engine-path ./engine --output report.txt

bash tools/scan_imports.sh --verbose
```

### Lua Cross-Platform
```bash
# Works anywhere Lua is installed
lua tools/scan_imports.lua --format text --output report.txt

lua tools/scan_imports.lua --verbose --strict --engine-path ./engine
```

## Use Cases

### 1. Pre-Commit Verification
Ensure no broken imports before committing:
```powershell
# Run before git commit
.\tools\scan_imports.ps1 -Strict
if ($LASTEXITCODE -ne 0) {
    Write-Host "Fix import errors before committing!" -ForegroundColor Red
    exit 1
}
```

### 2. CI/CD Pipeline
```yaml
# GitHub Actions example
- name: Verify Lua Imports
  run: |
    powershell -File "tools/scan_imports.ps1" -Strict -Format json -OutputFile scan.json
    
- name: Upload Report
  uses: actions/upload-artifact@v2
  with:
    name: lua-import-scan
    path: scan.json
```

### 3. Code Review Analysis
```powershell
# Generate detailed report for review
$report = .\tools\scan_imports.ps1 -Verbose -Format json

# Filter for specific issues
$report | Select-Object MissingModules | Format-Table

# Check for circular dependencies
$report | Select-Object CircularDependencies
```

### 4. Regular Health Checks
```powershell
# Create automated scheduled scan
$reportDate = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$reportPath = "reports\scan_$reportDate.txt"

New-Item -ItemType Directory -Path "reports" -Force | Out-Null
.\tools\scan_imports.ps1 -Format text -OutputFile $reportPath

Write-Host "Report saved: $reportPath"
```

### 5. Module Dependency Mapping
```powershell
# Generate JSON to analyze dependency structure
.\tools\scan_imports.ps1 -Format json -OutputFile deps.json

# Parse and display dependency graph
$deps = Get-Content deps.json | ConvertFrom-Json
$deps.DependencyGraph | Format-Table -AutoSize
```

## Real-World Scenarios

### Scenario 1: Refactoring Module Structure
You're reorganizing files and need to verify all requires still work:
```powershell
# Before refactoring
.\tools\scan_imports.ps1 -Strict -OutputFile before.txt

# ... move files around ...

# After refactoring - verify no broken imports
.\tools\scan_imports.ps1 -Strict -OutputFile after.txt

# Compare reports
Compare-Object (Get-Content before.txt) (Get-Content after.txt)
```

### Scenario 2: Debugging Missing Module Error
Game crashes with "module not found" error:
```powershell
# Scan for missing modules
.\tools\scan_imports.ps1 -Verbose -Format json | 
    Select-Object MissingModules |
    Format-List

# The report shows which file requires the missing module and at what line
```

### Scenario 3: Circular Dependency Discovered
Performance issues or strange behavior detected:
```powershell
# Check for circular dependencies
$report = .\tools\scan_imports.ps1 -Format json
$report.CircularDependencies | Format-Table

# Use this to refactor the affected modules
```

### Scenario 4: Adding New Module
Creating new feature module and want to verify integration:
```powershell
# Before adding new requires
$baseline = .\tools\scan_imports.ps1 -Format json

# ... add new requires to modules ...

# After adding requires
$updated = .\tools\scan_imports.ps1 -Format json

# Compare to ensure no new issues
$comparison = Compare-Object $baseline.Summary $updated.Summary
```

## Automation Scripts

### Weekly Scan Report
```powershell
# Save as tools\weekly_scan.ps1
param([string]$EmailTo)

$date = Get-Date -Format "yyyy-MM-dd"
$reportPath = "reports\weekly_scan_$date.txt"

.\tools\scan_imports.ps1 -Verbose -Format text -OutputFile $reportPath

if ((Get-Item $reportPath).Length -gt 1KB) {
    Write-Host "Issues found! Report size: $(Get-Item $reportPath).Length bytes"
    
    if ($EmailTo) {
        Send-MailMessage -From "dev@project.local" `
                        -To $EmailTo `
                        -Subject "Weekly Import Scan - Issues Found" `
                        -Body (Get-Content $reportPath | Out-String) `
                        -SmtpServer "localhost"
    }
} else {
    Write-Host "No issues found!"
}
```

### Continuous Monitoring
```powershell
# Save as tools\monitor_imports.ps1
# Run this in background to watch for import issues

$reportPath = "reports\current_scan.txt"

while ($true) {
    Clear-Host
    Write-Host "Running import scan..." -ForegroundColor Cyan
    
    .\tools\scan_imports.ps1 -Verbose -Format text -OutputFile $reportPath
    
    $issues = Select-String "^(Error|Missing|Circular)" $reportPath | Measure-Object
    
    if ($issues.Count -gt 0) {
        Write-Host "⚠️  Found $($issues.Count) issues!" -ForegroundColor Yellow
        Get-Content $reportPath | tail -20
    } else {
        Write-Host "✓ No issues found" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "Waiting 5 minutes before next scan..." -ForegroundColor Gray
    Start-Sleep -Seconds 300
}
```

### Integration with Game Development Workflow
```powershell
# Save as tools\dev_workflow.ps1
# Run after game modifications

param(
    [switch]$Quick,      # Quick scan only
    [switch]$Full,       # Full scan + tests
    [switch]$Report      # Generate report only
)

Write-Host "AlienFall Development Workflow" -ForegroundColor Cyan

# Step 1: Check imports
Write-Host "1. Checking Lua imports..." -ForegroundColor Yellow
$importStatus = .\tools\scan_imports.ps1 -Strict
if ($LASTEXITCODE -ne 0) {
    Write-Host "   ✗ Import errors found!" -ForegroundColor Red
    exit 1
}
Write-Host "   ✓ Imports OK" -ForegroundColor Green

if ($Quick) { exit 0 }

# Step 2: Run tests
if (-not $Report) {
    Write-Host "2. Running unit tests..." -ForegroundColor Yellow
    # ... run tests ...
    Write-Host "   ✓ Tests passed" -ForegroundColor Green
}

# Step 3: Generate report
Write-Host "3. Generating report..." -ForegroundColor Yellow
$date = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
.\tools\scan_imports.ps1 -Format json -OutputFile "reports\scan_$date.json"
Write-Host "   ✓ Report generated" -ForegroundColor Green

Write-Host ""
Write-Host "Workflow complete!" -ForegroundColor Cyan
```

## Integration Patterns

### With Game Launch
```batch
REM save as run_xcom_safe.bat
@echo off
echo Checking imports before launch...
powershell -ExecutionPolicy Bypass -File "tools\scan_imports.ps1" -Strict
if %ERRORLEVEL% neq 0 (
    echo Import errors detected! Cannot launch.
    pause
    exit /b 1
)
echo Imports OK. Launching game...
C:\Program Files\LOVE\lovec.exe engine
```

### With Test Runner
```powershell
# In run_tests.bat or similar
powershell -File "tools\scan_imports.ps1" -Strict -Format text

if ($LASTEXITCODE -ne 0) {
    Write-Host "Import validation failed!" -ForegroundColor Red
    exit 1
}

# Continue with tests...
```

## Reporting and Analysis

### Generate Summary Report
```powershell
$json = .\tools\scan_imports.ps1 -Format json
$summary = $json | ConvertFrom-Json

Write-Host "Import Scan Summary:" -ForegroundColor Cyan
Write-Host "  Files Scanned: $($summary.Summary.FilesScanned)"
Write-Host "  Issues Found: $($summary.Summary.TotalIssues)"
Write-Host "  Missing Modules: $($summary.MissingModules.Count)"
Write-Host "  Circular Deps: $($summary.CircularDependencies.Count)"
```

### Export to CSV for Analysis
```powershell
$json = .\tools\scan_imports.ps1 -Format json | ConvertFrom-Json

# Export missing modules
$json.MissingModules | Export-Csv -Path "missing_modules.csv" -NoTypeInformation

# Export circular dependencies
$json.CircularDependencies | Export-Csv -Path "circular_deps.csv" -NoTypeInformation
```

### Archive Reports
```powershell
$date = Get-Date -Format "yyyy-MM"
$archiveDir = "reports\archive\$date"

New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null

.\tools\scan_imports.ps1 -Format text -OutputFile "$archiveDir\scan_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').txt"

Write-Host "Report archived to: $archiveDir"
```

## Troubleshooting Examples

### Issue: Script Takes Too Long
```powershell
# Profile to see which files take longest
Measure-Command {
    .\tools\scan_imports.ps1 -Verbose
} | Select-Object TotalSeconds
```

### Issue: Getting False Positives
```powershell
# Run verbose to see exactly what paths it's checking
.\tools\scan_imports.ps1 -Verbose -OutputFile verbose.txt
Get-Content verbose.txt | grep -i "attempted"
```

### Issue: Need to Track Changes
```powershell
# Keep baseline
$baseline = .\tools\scan_imports.ps1 -Format json

# ... make changes ...

# Compare
$current = .\tools\scan_imports.ps1 -Format json
$diff = Compare-Object -ReferenceObject $baseline -DifferenceObject $current
```

## See Also

- `IMPORT_SCANNER.md` - Full documentation
- `tools/` - Scanner scripts and tools
- `wiki/DEVELOPMENT.md` - Development workflow
