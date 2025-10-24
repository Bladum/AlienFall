# Documentation Validator

Tool for validating documentation cross-references to ensure all implementation links point to existing files.

## Overview

The Documentation Validator scans all markdown files and verifies that cross-reference links to code files are valid. This ensures documentation stays synchronized with the actual codebase and prevents broken links.

## Quick Start

### Launch the Tool

**Option 1: PowerShell (Recommended on Windows)**
```powershell
.\tools\docs_validator\validate_docs_links.ps1
```

**Option 2: Lua (Cross-Platform)**
```bash
lua tools/docs_validator/validate_docs_links.lua
```

**Option 3: From Project Root**
```bash
cd c:\Users\tombl\Documents\Projects
.\tools\docs_validator\validate_docs_links.ps1
```

The validator runs and generates a report file with results.

## Features

- **Cross-Reference Validation**: Checks all documentation links point to existing files
- **Pattern Detection**: Finds implementation links with `> **Implementation**: \`path\``
- **Issue Categories**: Separates valid, broken, and vague links
- **Detailed Reports**: Show exact file and line numbers
- **Console Output**: Color-coded results (green/red/yellow)
- **Multiple Formats**: Text reports for easy reading
- **Suggestions**: Provides guidance for fixing broken links

## How to Use

### Basic Validation

```powershell
.\tools\docs_validator\validate_docs_links.ps1
```

Scans all markdown files in `docs/` folder and creates report.

### Output Report

Report file: `validate_docs_links_report.txt`

Contains:
- Scan summary (date, file count)
- Valid links count
- Broken links with details
- Vague links that need clarification
- Suggestions for fixes

### Understanding Results

**Example Console Output**:
```
[✓] 43 valid links
[✗] 3 broken links
[⚠] 1 vague links
```

**Report Summary**:
```
DOCUMENTATION LINKS VALIDATION REPORT
=====================================
Generated: 2025-10-22 14:30:00
Project Root: c:\Users\tombl\Documents\Projects

SCAN SUMMARY
────────────────────────────────
Documentation Files Scanned: 47
Total Implementation Links: 47
Valid Links: 43 ✓
Broken Links: 3 ✗
Vague Links: 1 ⚠
```

## Understanding Validation Results

### Valid Links

All implementation links point to existing files:

```
File: wiki/API.md
Line 45: > **Implementation**: `engine/core/state_manager.lua`
Status: ✓ VALID (file found)
```

### Broken Links

Implementation links point to files that don't exist:

```
File: wiki/FEATURES.md
Line 78: > **Implementation**: `engine/core/old_module.lua`
Status: ✗ BROKEN (file not found)
Suggestion: Remove this reference or create the file
```

### Vague Links

Links use wildcards or patterns that match too many files:

```
File: docs/ARCHITECTURE.md
Line 12: > **Implementation**: `engine/**/*.lua`
Status: ⚠ VAGUE (matches 248 files)
Suggestion: Be more specific with the file path
```

## File Structure

```
tools/docs_validator/
├── validate_docs_links.ps1   -- PowerShell implementation (Windows)
├── validate_docs_links.lua   -- Lua implementation (cross-platform)
└── README.md                 -- This file
```

## Link Format

Documentation should include implementation links in this format:

```markdown
## State Manager

Handles game state transitions and persistence.

> **Implementation**: `engine/core/state_manager.lua`

The state manager provides:
- State transitions
- Persistence handling
- Configuration management
```

### Valid Link Examples

```markdown
> **Implementation**: `engine/core/state_manager.lua`
> **Implementation**: `engine/battlescape/ai.lua`
> **Implementation**: `tests/unit/test_state.lua`
```

### Link Format Rules

- Start with `> **Implementation**: `
- Path wrapped in backticks
- Use forward slashes: `/`
- Can be absolute or relative to project
- Should point to specific files (not directories)

## Troubleshooting

### Scanner Won't Run

**Problem**: PowerShell "cannot be loaded because running scripts is disabled"

**Solution**:
```powershell
# Allow scripts temporarily
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Then run
.\tools\docs_validator\validate_docs_links.ps1
```

### Lua Script Errors

**Problem**: `lua: command not found`

**Solutions**:
1. Check Lua installed:
   ```bash
   lua -v
   ```

2. Install Lua 5.1+ from https://www.lua.org/download.html

3. Or use Love2D:
   ```bash
   lovec tools/docs_validator/validate_docs_links.lua
   ```

### Report Not Generated

**Problem**: Scanner runs but no report file created

**Solutions**:
1. Check current directory:
   ```powershell
   Get-Location
   ```

2. Run from project root:
   ```bash
   cd c:\Users\tombl\Documents\Projects
   .\tools\docs_validator\validate_docs_links.ps1
   ```

3. Check write permissions on project folder
4. Try alternative output location:
   ```powershell
   .\tools\docs_validator\validate_docs_links.ps1 -OutputFile "$env:TEMP\report.txt"
   ```

### False Positives

**Problem**: Links marked broken but files exist

**Solutions**:
1. Check path separators (must use `/`)
2. Verify case sensitivity matches file system
3. Check for typos in documented path
4. Verify file is in correct location

### False Negatives

**Problem**: Links marked valid but files don't exist

**Solutions**:
1. Verify scanner is checking correct project root
2. Check that files were not recently deleted
3. Look for symlinks or directory junctions
4. Re-run scanner to refresh cache

## Fixing Broken Links

### Problem: File Doesn't Exist

1. **Option A**: Create the file if it should exist
   ```bash
   mkdir -p engine/core
   touch engine/core/new_module.lua
   ```

2. **Option B**: Update documentation with correct path
   ```markdown
   > **Implementation**: `engine/core/existing_module.lua`
   ```

3. **Option C**: Remove the documentation if feature not implemented

### Problem: Vague/Wildcard Links

**Before** (too vague):
```markdown
> **Implementation**: `engine/**/*.lua`
```

**After** (specific):
```markdown
> **Implementation**: `engine/core/state_manager.lua`
```

## Advanced Usage

### PowerShell with Custom Options

```powershell
# Specify project root
.\tools\docs_validator\validate_docs_links.ps1 -ProjectRoot "C:\path\to\project"

# Output to different file
.\tools\docs_validator\validate_docs_links.ps1 -OutputFile "my_report.txt"
```

### Lua Script

```bash
lua tools/docs_validator/validate_docs_links.lua

# Or with Love2D
lovec tools/docs_validator/validate_docs_links.lua
```

### Automated Validation

Run as part of development workflow:

```powershell
# Validate documentation as part of build
.\tools\docs_validator\validate_docs_links.ps1

# Check report
if ($LASTEXITCODE -ne 0) {
    Write-Host "Documentation validation failed!"
    exit 1
}
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Docs Validation

on: [push, pull_request]

jobs:
  validate:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Validate Documentation Links
        run: |
          powershell -ExecutionPolicy Bypass -File "tools/docs_validator/validate_docs_links.ps1"
          
      - name: Upload Report
        if: always()
        uses: actions/upload-artifact@v2
        with:
          name: docs-validation-report
          path: validate_docs_links_report.txt
```

### Local Git Hook

Create `.git/hooks/pre-commit`:
```bash
#!/bin/bash
powershell -ExecutionPolicy Bypass -File "tools/docs_validator/validate_docs_links.ps1"

if [ $? -ne 0 ]; then
    echo "Documentation validation failed!"
    exit 1
fi
```

## Console Output

**PowerShell Output**:
```
Starting documentation link validation...
Project root: c:\Users\tombl\Documents\Projects

Scanning 47 documentation files...

VALIDATION RESULTS
═════════════════════════════════════════
Valid links: 43 ✓
Broken links: 3 ✗
Vague links: 1 ⚠

Broken Links:
  engine/core/old_module.lua (docs/FAQ.md:45)
  engine/ui/missing_widget.lua (wiki/API.md:67)

See report: validate_docs_links_report.txt
```

## Best Practices

### Writing Documentation with Implementation Links

1. **Add links after implementation exists**:
   ```markdown
   > **Implementation**: `engine/core/new_feature.lua`
   ```

2. **Keep links specific** (not wildcards):
   ```markdown
   ✓ Good:   `engine/core/state_manager.lua`
   ✗ Bad:    `engine/**/*.lua`
   ```

3. **Use relative paths from project root**:
   ```markdown
   ✓ Good:   `engine/core/module.lua`
   ✗ Bad:    `../../Projects/engine/core/module.lua`
   ```

4. **Update links when moving files**:
   ```bash
   git mv engine/old/file.lua engine/new/file.lua
   # Update documentation links immediately
   ```

5. **Remove links for deprecated features**:
   - If feature removed, delete implementation link
   - Note removal in commit message

## Related Tools

- **Import Scanner** - Validate Lua requires
- **Asset Verification** - Verify asset references
- **Map Editor** - Visual map editing

## Related Documentation

- `wiki/DEVELOPMENT.md` - Development workflow
- `wiki/API.md` - API reference (heavily documented)
- `docs/` - All documentation files
- `docs/CODE_STANDARDS.md` - Code quality standards

## Maintenance

### Running Validation

**Recommended**: Run validation before each commit
```bash
# Pre-commit hook does this automatically
git commit  # Hook runs validator
```

**Manual validation**:
```powershell
.\tools\docs_validator\validate_docs_links.ps1
```

**Review results**:
```bash
notepad validate_docs_links_report.txt
```

## See Also

- **Main Tools README** - `tools/README.md`
- **Project Structure** - `wiki/PROJECT_STRUCTURE.md`
- **Import Scanner** - `tools/import_scanner/README.md`
