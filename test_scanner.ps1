#!/usr/bin/env powershell
# Quick test of the import scanner

# First, navigate to the project root
$projectRoot = "c:\Users\tombl\Documents\Projects"
Set-Location $projectRoot

Write-Host "Import Scanner Test" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Current Directory: $(Get-Location)"
Write-Host "Engine Path Check: $(Test-Path './engine')"
Write-Host "Scanner Script Check: $(Test-Path './tools/scan_imports.ps1')"
Write-Host ""

if (Test-Path './tools/scan_imports.ps1') {
    Write-Host "✓ Scanner script found" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "Running scan..." -ForegroundColor Yellow
    
    # Run the scanner
    & "./tools/scan_imports.ps1" -Format text -OutputFile "import_report.txt" -Verbose
    
    Write-Host ""
    Write-Host "Scan complete!" -ForegroundColor Green
    
    if (Test-Path "./import_report.txt") {
        Write-Host ""
        Write-Host "Report Preview (first 30 lines):" -ForegroundColor Cyan
        Write-Host "=================================" -ForegroundColor Cyan
        Get-Content "./import_report.txt" | Select-Object -First 30
        Write-Host "..."
        Write-Host ""
        Write-Host "Full report saved to: ./import_report.txt" -ForegroundColor Green
    }
} else {
    Write-Host "✗ Scanner script not found!" -ForegroundColor Red
    Write-Host "Please ensure you're in the project root directory" -ForegroundColor Red
}
