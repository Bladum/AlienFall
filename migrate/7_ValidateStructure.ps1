# Validate the new engine structure after migration
# Run AFTER all previous steps complete

param(
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"
if ($Verbose) { $VerbosePreference = "Continue" }

Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  PHASE 4.7: VALIDATE NEW STRUCTURE                               ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$validationsPassed = 0
$validationsFailed = 0

# Check 1: Required new folders exist
Write-Host ""
Write-Host "Validating new folder structure..." -ForegroundColor Cyan

$requiredNewFolders = @(
    "engine/core",
    "engine/core/utils",
    "engine/systems",
    "engine/systems/ai",
    "engine/systems/economy",
    "engine/systems/politics",
    "engine/systems/analytics",
    "engine/systems/content",
    "engine/systems/lore",
    "engine/systems/tutorial",
    "engine/layers",
    "engine/layers/geoscape",
    "engine/layers/basescape",
    "engine/layers/battlescape",
    "engine/layers/interception",
    "engine/ui",
    "engine/ui/widgets"
)

foreach ($folder in $requiredNewFolders) {
    if (Test-Path $folder) {
        Write-Host "  ✅ $folder" -ForegroundColor Green
        $validationsPassed++
    } else {
        Write-Host "  ❌ $folder (MISSING!)" -ForegroundColor Red
        $validationsFailed++
    }
}

# Check 2: Old folders are deleted
Write-Host ""
Write-Host "Verifying old directories are removed..." -ForegroundColor Cyan

$oldFolders = @(
    "engine/ai",
    "engine/economy",
    "engine/politics",
    "engine/analytics",
    "engine/content",
    "engine/lore",
    "engine/tutorial",
    "engine/geoscape",
    "engine/basescape",
    "engine/battlescape",
    "engine/interception",
    "engine/gui",
    "engine/widgets",
    "engine/utils"
)

foreach ($folder in $oldFolders) {
    if (Test-Path $folder) {
        Write-Host "  ❌ $folder (still exists!)" -ForegroundColor Red
        $validationsFailed++
    } else {
        Write-Host "  ✅ $folder (removed)" -ForegroundColor Green
        $validationsPassed++
    }
}

# Check 3: Key files exist in new locations
Write-Host ""
Write-Host "Verifying key files in new locations..." -ForegroundColor Cyan

$keyFiles = @(
    "engine/core/state_manager.lua",
    "engine/systems/ai/tactical.lua",
    "engine/systems/economy/funds.lua",
    "engine/layers/geoscape/manager.lua",
    "engine/layers/basescape/manager.lua",
    "engine/layers/battlescape/manager.lua",
    "engine/ui/framework.lua",
    "engine/main.lua"
)

foreach ($file in $keyFiles) {
    if (Test-Path $file) {
        Write-Host "  ✅ $file" -ForegroundColor Green
        $validationsPassed++
    } else {
        Write-Host "  ⚠️  $file (not found)" -ForegroundColor Yellow
    }
}

# Check 4: Scan for old-style requires in engine files
Write-Host ""
Write-Host "Scanning for old-style require() statements..." -ForegroundColor Cyan

$oldRequirePatterns = @(
    'require("ai\.',
    'require("economy\.',
    'require("geoscape\.',
    'require("basescape\.',
    'require("battlescape\.',
    "require('ai\.",
    "require('economy\.",
    "require('geoscape\.",
    "require('basescape\.",
    "require('battlescape\."
)

$foundOldRequires = 0
foreach ($pattern in $oldRequirePatterns) {
    $matches = Select-String -Path "engine/**/*.lua" -Pattern $pattern -Recurse -ErrorAction SilentlyContinue
    if ($matches) {
        $count = ($matches | Measure-Object).Count
        Write-Host "  ❌ Found $count old requires: $pattern" -ForegroundColor Red
        $foundOldRequires += $count
        $validationsFailed++
    }
}

if ($foundOldRequires -eq 0) {
    Write-Host "  ✅ No old-style requires found" -ForegroundColor Green
    $validationsPassed++
}

# Check 5: Verify test mock structure
Write-Host ""
Write-Host "Verifying test mock data structure..." -ForegroundColor Cyan

$mockStructures = @(
    "tests/mock/engine/systems",
    "tests/mock/engine/layers",
    "tests/mock/engine/core/utils"
)

foreach ($folder in $mockStructures) {
    if (Test-Path $folder) {
        Write-Host "  ✅ $folder" -ForegroundColor Green
        $validationsPassed++
    } else {
        Write-Host "  ⚠️  $folder (not found)" -ForegroundColor Yellow
    }
}

# Check 6: File count validation
Write-Host ""
Write-Host "Counting engine files..." -ForegroundColor Cyan

$newEngineFiles = (Get-ChildItem engine -Recurse -File | Measure-Object).Count
Write-Host "  📊 Total files in new structure: $newEngineFiles" -ForegroundColor Cyan

if ($newEngineFiles -gt 50) {
    Write-Host "  ✅ File count reasonable" -ForegroundColor Green
    $validationsPassed++
} else {
    Write-Host "  ⚠️  File count may be low" -ForegroundColor Yellow
}

# Final Summary
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  VALIDATION SUMMARY                                              ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host ""
Write-Host "✅ Validations passed: $validationsPassed" -ForegroundColor Green
Write-Host "❌ Validations failed: $validationsFailed" -ForegroundColor Red

if ($validationsFailed -eq 0) {
    Write-Host ""
    Write-Host "🎉 ALL VALIDATIONS PASSED!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Run tests: lovec tests/runners" -ForegroundColor White
    Write-Host "  2. Run game: lovec engine" -ForegroundColor White
    Write-Host "  3. Update documentation files" -ForegroundColor White
    Write-Host "  4. Git commit: git commit -m 'Restructure: Reorganize engine into hierarchical structure'" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "⚠️  Some validations failed. Please review and fix issues before proceeding." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Review the failures above and run this script again after fixes." -ForegroundColor Yellow
}
