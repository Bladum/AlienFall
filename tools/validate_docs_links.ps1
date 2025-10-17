# Docs Links Validator PowerShell Script
# Validates that all documentation cross-references point to existing files
#
# Usage:
#   .\validate_docs_links.ps1
#
# Output:
#   Creates: validate_docs_links_report.txt
#   Console: Summary statistics

param(
    [string]$ProjectRoot = (Split-Path -Parent (Split-Path -Parent $PSScriptRoot))
)

Write-Host "Starting documentation link validation..." -ForegroundColor Cyan
Write-Host "Project root: $ProjectRoot" -ForegroundColor Gray
Write-Host ""

$report = @()
$report += "Documentation Links Validation Report"
$report += "====================================="
$report += "Generated: $(Get-Date)"
$report += "Project Root: $ProjectRoot"
$report += ""

# Find all markdown files in docs/
$docsPath = Join-Path $ProjectRoot "docs"
$mdFiles = Get-ChildItem -Path $docsPath -Filter "*.md" -Recurse -ErrorAction SilentlyContinue

Write-Host "Scanning $($mdFiles.Count) documentation files..." -ForegroundColor Yellow
$report += "Scanning $($mdFiles.Count) documentation files..."
$report += ""

$stats = @{
    total_files = $mdFiles.Count
    total_links = 0
    valid_links = 0
    broken_links = 0
    vague_links = 0
    errors = @()
}

# Pattern to find implementation links: > **Implementation**: `path/to/file`
$linkPattern = '> \*\*Implementation\*\*: `([^`]+)`'

foreach ($mdFile in $mdFiles) {
    $content = Get-Content -Path $mdFile.FullName -Raw -ErrorAction SilentlyContinue
    if ($content) {
        $matches = [regex]::Matches($content, $linkPattern)
        foreach ($match in $matches) {
            $stats.total_links++
            $link = $match.Groups[1].Value
            
            # Try to resolve the link
            $fullPath = Join-Path $ProjectRoot $link
            $fullPath = $fullPath -replace "\\", "/"
            
            if (Test-Path $fullPath) {
                $stats.valid_links++
                Write-Host "✓ $link" -ForegroundColor Green
            } elseif ($link -match '\*') {
                # Vague links with wildcards
                $stats.vague_links++
                $stats.errors += @{
                    type = "VAGUE"
                    file = $mdFile.FullName
                    link = $link
                    message = "Vague link pattern (contains wildcards)"
                }
                Write-Host "⚠ $link (vague)" -ForegroundColor Yellow
            } else {
                # Broken link
                $stats.broken_links++
                $stats.errors += @{
                    type = "BROKEN"
                    file = $mdFile.FullName
                    link = $link
                    message = "File not found: $fullPath"
                }
                Write-Host "✗ $link (broken)" -ForegroundColor Red
            }
        }
    }
}

# Generate statistics section
$report += ""
$report += "STATISTICS"
$report += "=========="
$report += "Total documentation files: $($stats.total_files)"
$report += "Total implementation links: $($stats.total_links)"
$report += "Valid links: $($stats.valid_links)"
$report += "Broken links: $($stats.broken_links)"
$report += "Vague links: $($stats.vague_links)"
$report += ""

if ($stats.total_links -gt 0) {
    $validPercent = ($stats.valid_links / $stats.total_links) * 100
    $report += "Link validity: $([math]::Round($validPercent, 1))%"
}

# Generate errors section
if ($stats.errors.Count -gt 0) {
    $report += ""
    $report += "ISSUES FOUND"
    $report += "============"
    
    $byType = @{}
    foreach ($error in $stats.errors) {
        if (-not $byType.ContainsKey($error.type)) {
            $byType[$error.type] = @()
        }
        $byType[$error.type] += $error
    }
    
    foreach ($errorType in $byType.Keys) {
        $errors = $byType[$errorType]
        $report += ""
        $report += "$errorType LINKS ($($errors.Count))"
        $report += ("-" * 30)
        
        foreach ($error in $errors) {
            $relFile = $error.file -replace [regex]::Escape($ProjectRoot), ""
            $report += "File: $relFile"
            $report += "Link: $($error.link)"
            $report += "Issue: $($error.message)"
            $report += ""
        }
    }
} else {
    $report += ""
    $report += "✓ All links are valid!"
}

# Write report file
$reportPath = Join-Path $ProjectRoot "validate_docs_links_report.txt"
$report | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host ""
Write-Host "✓ Report written to: $reportPath" -ForegroundColor Green

# Print summary to console
Write-Host ""
Write-Host "VALIDATION SUMMARY" -ForegroundColor Cyan
Write-Host "=================="
Write-Host "Total links: $($stats.total_links)"
Write-Host "Valid: $($stats.valid_links)" -ForegroundColor Green
Write-Host "Broken: $($stats.broken_links)" -ForegroundColor Red
Write-Host "Vague: $($stats.vague_links)" -ForegroundColor Yellow

if ($stats.broken_links -eq 0) {
    Write-Host "✓ All links are valid!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "✗ $($stats.broken_links) broken links found" -ForegroundColor Red
    exit 1
}
