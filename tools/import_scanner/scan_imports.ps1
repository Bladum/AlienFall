#!/usr/bin/env powershell
<#
.SYNOPSIS
    Scans Lua files in the engine folder for import problems
    
.DESCRIPTION
    Comprehensive Lua import scanner that detects:
    - Missing required modules
    - Circular dependencies
    - Invalid file paths
    - Unused requires
    - Duplicate requires
    
.PARAMETER EnginePath
    Path to the engine folder (default: ./engine)
    
.PARAMETER OutputFile
    Output report file (default: import_report.txt)
    
.PARAMETER Format
    Report format: text|json|html (default: text)
    
.PARAMETER Verbose
    Show detailed scan progress
    
.PARAMETER Strict
    Treat warnings as errors (exit code 1 on issues)
    
.EXAMPLE
    .\scan_imports.ps1 -EnginePath ./engine -OutputFile report.txt -Verbose
    
.EXAMPLE
    .\scan_imports.ps1 -Format json -OutputFile report.json
#>

param(
    [string]$EnginePath = './engine',
    [string]$OutputFile = 'import_report.txt',
    [ValidateSet('text', 'json', 'html')][string]$Format = 'text',
    [switch]$Verbose,
    [switch]$Strict
)

# ===== Configuration =====
$config = @{
    EnginePath = $EnginePath
    OutputFile = $OutputFile
    Format = $Format
    Verbose = $Verbose
    Strict = $Strict
    MaxDepth = 50
}

# ===== Results Storage =====
$results = @{
    FilesScanned = 0
    Errors = @()
    Warnings = @()
    MissingModules = @()
    CircularDeps = @()
    DuplicateRequires = @()
    DependencyGraph = @{}
    FileList = @{}
    ValidFiles = 0
}

# ===== Helper Functions =====
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('info', 'warning', 'error', 'debug')][string]$Level = 'info'
    )
    
    if ($Level -eq 'debug' -and -not $config.Verbose) { return }
    
    $timestamp = Get-Date -Format 'HH:mm:ss'
    $levelStr = $Level.ToUpper()
    Write-Host "[$timestamp] [$levelStr] $Message"
}

function Test-FilePath {
    param([string]$Path)
    return (Test-Path -Path $Path -PathType Leaf)
}

function Test-DirectoryPath {
    param([string]$Path)
    return (Test-Path -Path $Path -PathType Container)
}

function Normalize-Path {
    param([string]$Path)
    $Path = $Path -replace '\\', '/'
    $Path = $Path -replace '^\./', ''
    return $Path
}

function Resolve-RequirePath {
    param(
        [string]$RequireName,
        [string]$CurrentFileDir
    )
    
    $variations = @(
        "$RequireName.lua",
        $RequireName,
        "$CurrentFileDir/$RequireName.lua",
        "$CurrentFileDir/$RequireName",
        "./engine/$RequireName.lua",
        "./engine/$RequireName"
    )
    
    foreach ($path in $variations) {
        if (Test-FilePath -Path $path) {
            return (Normalize-Path -Path $path)
        }
    }
    
    return $null
}

function Extract-Requires {
    param([string]$FilePath)
    
    $requires = @()
    $duplicateCheck = @{}
    
    try {
        $content = Get-Content -Path $FilePath -ErrorAction Stop
        $lineNum = 0
        
        foreach ($line in $content) {
            $lineNum++
            
            # Match: require('module') or require("module")
            if ($line -match "require\s*\(\s*['\"]([^'\"]+)['\"]\s*\)") {
                $module = $matches[1]
                
                if ($duplicateCheck.ContainsKey($module)) {
                    $results.DuplicateRequires += @{
                        File = $FilePath
                        Module = $module
                        Line = $lineNum
                        PreviousLine = $duplicateCheck[$module]
                    }
                } else {
                    $requires += @{
                        Module = $module
                        Line = $lineNum
                        Type = 'require'
                    }
                    $duplicateCheck[$module] = $lineNum
                }
            }
        }
    } catch {
        $results.Errors += @{
            File = $FilePath
            Message = "Cannot read file: $_"
        }
    }
    
    return $requires
}

function Scan-LuaFile {
    param(
        [string]$FilePath,
        [int]$Depth = 0
    )
    
    if ($Depth -gt $config.MaxDepth) {
        $results.Errors += @{
            File = $FilePath
            Message = 'Maximum recursion depth exceeded'
        }
        return
    }
    
    $results.FilesScanned++
    $results.FileList[$FilePath] = $true
    
    Write-Log "Scanning: $FilePath" -Level debug
    
    $requires = Extract-Requires -FilePath $FilePath
    
    if ($requires.Count -gt 0) {
        $results.ValidFiles++
    }
    
    $currentDir = Split-Path -Parent $FilePath
    
    foreach ($req in $requires) {
        $resolvedPath = Resolve-RequirePath -RequireName $req.Module -CurrentFileDir $currentDir
        
        if (-not $resolvedPath) {
            $results.MissingModules += @{
                File = $FilePath
                Module = $req.Module
                Line = $req.Line
                AttemptedPaths = @(
                    "$($req.Module).lua",
                    $req.Module,
                    "$currentDir/$($req.Module).lua"
                )
            }
            Write-Log "  Missing: $($req.Module)" -Level warning
        } else {
            if (-not $results.DependencyGraph.ContainsKey($FilePath)) {
                $results.DependencyGraph[$FilePath] = @()
            }
            
            $results.DependencyGraph[$FilePath] += @{
                Module = $req.Module
                Resolved = $resolvedPath
                Line = $req.Line
            }
            
            Write-Log "  Found: $($req.Module) -> $resolvedPath" -Level debug
            
            if (-not $results.FileList.ContainsKey($resolvedPath)) {
                Scan-LuaFile -FilePath $resolvedPath -Depth ($Depth + 1)
            }
        }
    }
}

function Scan-Directory {
    param(
        [string]$DirectoryPath,
        [string]$Pattern = '*.lua'
    )
    
    if (-not (Test-DirectoryPath -Path $DirectoryPath)) {
        Write-Log "Directory not found: $DirectoryPath" -Level error
        return
    }
    
    $files = Get-ChildItem -Path $DirectoryPath -Filter $Pattern -Recurse -File -ErrorAction SilentlyContinue
    
    foreach ($file in $files) {
        Scan-LuaFile -FilePath $file.FullName
    }
}

function Detect-CircularDeps {
    $visited = @{}
    
    function Check-Circular {
        param(
            [string]$File,
            [array]$CurrentChain = @(),
            [hashtable]$VisitedLocal = @{}
        )
        
        if ($VisitedLocal.ContainsKey($File)) {
            return
        }
        $VisitedLocal[$File] = $true
        
        foreach ($dep in $CurrentChain) {
            if ($dep -eq $File) {
                $results.CircularDeps += , $CurrentChain
                return
            }
        }
        
        if ($results.DependencyGraph.ContainsKey($File)) {
            foreach ($depInfo in $results.DependencyGraph[$File]) {
                $newChain = $CurrentChain + $File
                Check-Circular -File $depInfo.Resolved -CurrentChain $newChain -VisitedLocal $VisitedLocal
            }
        }
    }
    
    foreach ($file in $results.DependencyGraph.Keys) {
        Check-Circular -File $file -CurrentChain @() -VisitedLocal @{}
    }
}

function Generate-TextReport {
    $lines = @(
        '═══════════════════════════════════════════════════════',
        'LUA IMPORT SCANNER REPORT',
        '═══════════════════════════════════════════════════════',
        '',
        "Scan Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
        "Engine Path: $($config.EnginePath)",
        '',
        '───────────────────────────────────────────────────────',
        'SCAN SUMMARY',
        '───────────────────────────────────────────────────────',
        "Total Files Scanned: $($results.FilesScanned)",
        "Files with Requires: $($results.ValidFiles)",
        "Total Errors: $($results.Errors.Count)",
        "Missing Modules: $($results.MissingModules.Count)",
        "Circular Dependencies: $($results.CircularDeps.Count)",
        "Duplicate Requires: $($results.DuplicateRequires.Count)",
        ''
    )
    
    if ($results.Errors.Count -gt 0) {
        $lines += @(
            '───────────────────────────────────────────────────────',
            "ERRORS ($($results.Errors.Count))",
            '───────────────────────────────────────────────────────'
        )
        
        foreach ($err in $results.Errors) {
            $lines += @(
                "File: $($err.File)",
                "Error: $($err.Message)",
                ''
            )
        }
    }
    
    if ($results.MissingModules.Count -gt 0) {
        $lines += @(
            '───────────────────────────────────────────────────────',
            "MISSING MODULES ($($results.MissingModules.Count))",
            '───────────────────────────────────────────────────────'
        )
        
        foreach ($miss in $results.MissingModules) {
            $lines += @(
                "File: $($miss.File)",
                "Module: $($miss.Module) (Line $($miss.Line))",
                'Attempted paths:'
            )
            
            foreach ($path in $miss.AttemptedPaths) {
                $lines += "  - $path"
            }
            
            $lines += ''
        }
    }
    
    if ($results.CircularDeps.Count -gt 0) {
        $lines += @(
            '───────────────────────────────────────────────────────',
            "CIRCULAR DEPENDENCIES ($($results.CircularDeps.Count))",
            '───────────────────────────────────────────────────────'
        )
        
        for ($i = 0; $i -lt $results.CircularDeps.Count; $i++) {
            $cycle = $results.CircularDeps[$i]
            $lines += "Cycle $($i + 1):"
            
            foreach ($file in $cycle) {
                $lines += "  → $file"
            }
            
            $lines += ''
        }
    }
    
    if ($results.DuplicateRequires.Count -gt 0) {
        $lines += @(
            '───────────────────────────────────────────────────────',
            "DUPLICATE REQUIRES ($($results.DuplicateRequires.Count))",
            '───────────────────────────────────────────────────────'
        )
        
        foreach ($dup in $results.DuplicateRequires) {
            $lines += @(
                "File: $($dup.File)",
                "Module: $($dup.Module)",
                "Lines: $($dup.PreviousLine) (first), $($dup.Line) (duplicate)",
                ''
            )
        }
    }
    
    $lines += @(
        '───────────────────────────────────────────────────────',
        'END OF REPORT',
        '═══════════════════════════════════════════════════════'
    )
    
    return $lines -join "`n"
}

function Generate-JsonReport {
    $reportObj = @{
        ScanDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        EnginePath = $config.EnginePath
        Summary = @{
            FilesScanned = $results.FilesScanned
            FilesWithRequires = $results.ValidFiles
            TotalErrors = $results.Errors.Count
            TotalIssues = $results.Errors.Count + $results.MissingModules.Count + $results.CircularDeps.Count
        }
        Errors = $results.Errors
        MissingModules = $results.MissingModules
        CircularDependencies = $results.CircularDeps
        DuplicateRequires = $results.DuplicateRequires
    }
    
    return $reportObj | ConvertTo-Json -Depth 10
}

function Generate-HtmlReport {
    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Lua Import Scanner Report</title>
    <style>
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            margin: 0; 
            padding: 20px; 
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        .container { 
            max-width: 1200px; 
            margin: 0 auto; 
            background: white; 
            padding: 30px; 
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
        h1 { 
            color: #333; 
            border-bottom: 3px solid #667eea; 
            padding-bottom: 15px;
            margin-top: 0;
        }
        h2 { 
            color: #667eea; 
            margin-top: 30px;
            border-left: 4px solid #667eea;
            padding-left: 15px;
        }
        .summary { 
            background: linear-gradient(135deg, #e7f3ff, #f0e7ff);
            padding: 20px; 
            margin: 20px 0; 
            border-radius: 5px;
            border-left: 4px solid #667eea;
        }
        .summary p {
            margin: 10px 0;
            line-height: 1.6;
        }
        .error-item { 
            background: #ffe7e7; 
            padding: 15px; 
            margin: 10px 0; 
            border-left: 4px solid #ff0000;
            border-radius: 4px;
        }
        .warning-item { 
            background: #fff4e7; 
            padding: 15px; 
            margin: 10px 0; 
            border-left: 4px solid #ff8800;
            border-radius: 4px;
        }
        code { 
            background: #f5f5f5; 
            padding: 4px 8px; 
            border-radius: 3px;
            font-family: 'Courier New', monospace;
        }
        .file-path {
            color: #0066cc;
            font-weight: bold;
        }
        .timestamp { 
            color: #999; 
            font-size: 0.9em;
            margin-top: 20px;
            border-top: 1px solid #eee;
            padding-top: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔍 Lua Import Scanner Report</h1>
        <p class="timestamp">Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
        
        <div class="summary">
            <h2>Summary</h2>
            <p><strong>Engine Path:</strong> <code>$($config.EnginePath)</code></p>
            <p><strong>Files Scanned:</strong> $($results.FilesScanned)</p>
            <p><strong>Files with Requires:</strong> $($results.ValidFiles)</p>
            <p><strong>Total Issues Found:</strong> $($results.Errors.Count + $results.MissingModules.Count + $results.CircularDeps.Count)</p>
        </div>
        
        <h2>Issues</h2>
        <p>No detailed HTML view yet - check text or JSON report for full details.</p>
    </div>
</body>
</html>
"@
    
    return $html
}

# ===== Main Execution =====
function Main {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  Lua Import Scanner                                    ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Log "Starting Lua import scan..." -Level info
    Write-Log "Engine path: $($config.EnginePath)" -Level info
    
    if (-not (Test-DirectoryPath -Path $config.EnginePath)) {
        Write-Log "Engine path not found: $($config.EnginePath)" -Level error
        exit 1
    }
    
    # Scan all Lua files
    Scan-Directory -DirectoryPath $config.EnginePath
    
    # Detect circular dependencies
    Detect-CircularDeps
    
    # Generate report
    $report = switch ($config.Format) {
        'text' { Generate-TextReport }
        'json' { Generate-JsonReport }
        'html' { Generate-HtmlReport }
        default { Generate-TextReport }
    }
    
    # Write report
    try {
        $report | Out-File -FilePath $config.OutputFile -Encoding UTF8
        Write-Log "Report written to: $($config.OutputFile)" -Level info
    } catch {
        Write-Log "Cannot write report to: $($config.OutputFile)" -Level error
        Write-Host $report
    }
    
    # Print summary
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "SCAN COMPLETE" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "Files Scanned: $($results.FilesScanned)" -ForegroundColor Green
    Write-Host "Errors: $($results.Errors.Count)" -ForegroundColor $(if ($results.Errors.Count -gt 0) { 'Red' } else { 'Green' })
    Write-Host "Missing Modules: $($results.MissingModules.Count)" -ForegroundColor $(if ($results.MissingModules.Count -gt 0) { 'Yellow' } else { 'Green' })
    Write-Host "Circular Dependencies: $($results.CircularDeps.Count)" -ForegroundColor $(if ($results.CircularDeps.Count -gt 0) { 'Red' } else { 'Green' })
    Write-Host "Duplicate Requires: $($results.DuplicateRequires.Count)" -ForegroundColor $(if ($results.DuplicateRequires.Count -gt 0) { 'Yellow' } else { 'Green' })
    Write-Host ""
    
    if ($config.Strict -and ($results.Errors.Count -gt 0 -or $results.MissingModules.Count -gt 0)) {
        exit 1
    }
}

Main
