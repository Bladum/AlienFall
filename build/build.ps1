$ErrorActionPreference = 'Continue'

# Colors
$cyan = 'Cyan'
$green = 'Green'
$yellow = 'Yellow'
$red = 'Red'

Write-Host '========================================' -ForegroundColor $cyan
Write-Host 'AlienFall Build System' -ForegroundColor $cyan
Write-Host '========================================' -ForegroundColor $cyan
Write-Host ''

# Setup paths
$buildDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $buildDir
$engineDir = Join-Path $projectRoot 'engine'
$modsDir = Join-Path $projectRoot 'mods'
$outputDir = Join-Path $buildDir 'output'
$tempDir = Join-Path $buildDir 'temp'
$packageDir = Join-Path $tempDir 'package'

Write-Host "[BUILD] Build directory: $buildDir" -ForegroundColor $green
Write-Host "[BUILD] Engine directory: $engineDir" -ForegroundColor $green
Write-Host "[BUILD] Mods directory: $modsDir" -ForegroundColor $green
Write-Host ''

# Read version
$version = Get-Content (Join-Path $buildDir 'version.txt') -Raw
$version = $version.Trim()
Write-Host "[BUILD] Version: $version" -ForegroundColor $green
Write-Host ''

# Create directories
Write-Host '[SETUP] Creating directories...' -ForegroundColor $yellow
$null = New-Item -ItemType Directory -Force -Path $outputDir
$null = New-Item -ItemType Directory -Force -Path $packageDir
Write-Host '[SETUP] Done.' -ForegroundColor $green
Write-Host ''

# Validate
Write-Host '[VALIDATE] Checking engine structure...' -ForegroundColor $yellow
$errors = 0

if (-not (Test-Path (Join-Path $engineDir 'main.lua'))) {
    Write-Host '[ERROR] main.lua not found!' -ForegroundColor $red
    $errors++
}

if (-not (Test-Path (Join-Path $engineDir 'conf.lua'))) {
    Write-Host '[ERROR] conf.lua not found!' -ForegroundColor $red
    $errors++
}

if (-not (Test-Path (Join-Path $modsDir 'core' 'mod.toml'))) {
    Write-Host '[ERROR] Core mod not found!' -ForegroundColor $red
    $errors++
}

if ($errors -gt 0) {
    Write-Host "[ERROR] $errors validation errors!" -ForegroundColor $red
    exit 1
}

Write-Host '[VALIDATE] Engine structure OK.' -ForegroundColor $green
Write-Host ''

# Copy engine files
Write-Host '[PACKAGE] Copying engine files...' -ForegroundColor $yellow
try {
    Copy-Item -Path (Join-Path $engineDir '*') -Destination $packageDir -Recurse -Force -ErrorAction Stop
    Write-Host '[PACKAGE] Engine copied successfully.' -ForegroundColor $green
} catch {
    Write-Host "[ERROR] Failed to copy engine: $_" -ForegroundColor $red
    exit 1
}

# Copy mods
Write-Host '[PACKAGE] Copying mods directory...' -ForegroundColor $yellow
try {
    $modsDestDir = Join-Path $packageDir 'mods'
    $null = New-Item -ItemType Directory -Force -Path $modsDestDir
    Copy-Item -Path (Join-Path $modsDir '*') -Destination $modsDestDir -Recurse -Force -ErrorAction Stop
    Write-Host '[PACKAGE] Mods copied successfully.' -ForegroundColor $green
} catch {
    Write-Host "[ERROR] Failed to copy mods: $_" -ForegroundColor $red
    exit 1
}

# Clean up test files
Write-Host '[PACKAGE] Removing test files...' -ForegroundColor $yellow
@('.luarc.json', 'test_scan.lua', 'simple_test.lua') | ForEach-Object {
    $testFile = Join-Path $packageDir $_
    if (Test-Path $testFile) {
        Remove-Item -Path $testFile -Force -ErrorAction SilentlyContinue
    }
}
Write-Host '[PACKAGE] Cleanup complete.' -ForegroundColor $green
Write-Host ''

# Create .love file
Write-Host '[BUILD] Creating .love file...' -ForegroundColor $yellow
$loveFile = Join-Path $outputDir 'alienfall.love'

try {
    Push-Location $packageDir
    Compress-Archive -Path '*' -DestinationPath $loveFile -Force -ErrorAction Stop
    Pop-Location
    Write-Host '[BUILD] .love file created.' -ForegroundColor $green
} catch {
    Write-Host "[ERROR] Failed to create .love file: $_" -ForegroundColor $red
    Pop-Location
    exit 1
}

# Verify
if (-not (Test-Path $loveFile)) {
    Write-Host '[ERROR] .love file not found after creation!' -ForegroundColor $red
    exit 1
}

$fileSize = (Get-Item $loveFile).Length
$fileSizeMB = [math]::Round($fileSize / 1MB, 2)
Write-Host "[BUILD] File size: $fileSizeMB MB" -ForegroundColor $green
Write-Host ''

# Summary
Write-Host '========================================' -ForegroundColor $cyan
Write-Host 'Build Complete!' -ForegroundColor $cyan
Write-Host '========================================' -ForegroundColor $cyan
Write-Host ''
Write-Host 'Output directory:' -ForegroundColor $green
Get-ChildItem $outputDir | ForEach-Object {
    $size = [math]::Round($_.Length / 1MB, 2)
    Write-Host "  $($_.Name) - $size MB" -ForegroundColor $green
}
Write-Host ''
Write-Host 'To test: love ' + $loveFile -ForegroundColor $cyan
Write-Host 'Or:      cd ' + $outputDir -ForegroundColor $cyan
Write-Host ''
Write-Host 'Success!' -ForegroundColor $green

