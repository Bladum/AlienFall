#!/usr/bin/env powershell
<#
.SYNOPSIS
    Quick scan wrapper - runs import scanner and opens report
    
.DESCRIPTION
    Convenience script that runs the import scanner and displays results
    
.PARAMETER Format
    Report format: text|json|html (default: text)
    
.PARAMETER Open
    Open report in default viewer
    
.PARAMETER Verbose
    Show detailed progress
    
.EXAMPLE
    .\quick_scan.ps1 -Open
    
.EXAMPLE
    .\quick_scan.ps1 -Format html -Open
#>

param(
    [ValidateSet('text', 'json', 'html')][string]$Format = 'text',
    [switch]$Open,
    [switch]$Verbose
)

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$scanScript = Join-Path $scriptPath 'scan_imports.ps1'

$extension = switch ($Format) {
    'json' { '.json' }
    'html' { '.html' }
    default { '.txt' }
}

$outputFile = "import_report$extension"

Write-Host "Running Lua import scanner..." -ForegroundColor Cyan
Write-Host "Format: $Format" -ForegroundColor Gray
Write-Host "Output: $outputFile" -ForegroundColor Gray
Write-Host ""

$params = @{
    Format = $Format
    OutputFile = $outputFile
}

if ($Verbose) {
    $params.Verbose = $true
}

& $scanScript @params

if ($Open -and (Test-Path $outputFile)) {
    Write-Host ""
    Write-Host "Opening report..." -ForegroundColor Cyan
    Start-Process $outputFile
}
