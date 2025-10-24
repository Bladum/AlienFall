# Validate project structure before migration
# Run this first to ensure safe migration

param(
    [switch]$DryRun = $false,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"
if ($Verbose) { $VerbosePreference = "Continue" }

Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  PHASE 4.1: PREPARE MIGRATION - Validate Structure               ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# 1. Check we're in project root
if (-not (Test-Path "engine")) {
    Write-Host "❌ ERROR: 'engine' folder not found. Run from project root." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Project root confirmed" -ForegroundColor Green

# 2. Check git is initialized
if (-not (Test-Path ".git")) {
    Write-Host "❌ ERROR: Not a git repository. Initialize git first." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Git repository found" -ForegroundColor Green

# 3. Check for dirty working directory
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "⚠️  WARNING: Uncommitted changes detected:" -ForegroundColor Yellow
    Write-Host $gitStatus
    Write-Host ""
    $confirm = Read-Host "Continue anyway? (yes/no)"
    if ($confirm -ne "yes") { exit 0 }
} else {
    Write-Host "✅ Clean working directory" -ForegroundColor Green
}

# 4. Verify current engine structure exists
$requiredFolders = @(
    "engine/core",
    "engine/ai",
    "engine/economy",
    "engine/geoscape",
    "engine/basescape",
    "engine/battlescape",
    "engine/gui",
    "engine/utils"
)

Write-Host ""
Write-Host "Checking current engine structure..." -ForegroundColor Cyan

$missingFolders = @()
foreach ($folder in $requiredFolders) {
    if (Test-Path $folder) {
        Write-Host "  ✅ $folder" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $folder (missing)" -ForegroundColor Red
        $missingFolders += $folder
    }
}

if ($missingFolders.Count -gt 0) {
    Write-Host ""
    Write-Host "❌ ERROR: Required folders are missing:" -ForegroundColor Red
    $missingFolders | ForEach-Object { Write-Host "   - $_" }
    exit 1
}

# 5. Verify new structure doesn't already exist
$newFolders = @(
    "engine/systems",
    "engine/layers",
    "engine/ui"
)

Write-Host ""
Write-Host "Checking for conflicts (new folders that shouldn't exist yet)..." -ForegroundColor Cyan

$conflicts = @()
foreach ($folder in $newFolders) {
    if (Test-Path $folder) {
        Write-Host "  ⚠️  $folder (already exists!)" -ForegroundColor Yellow
        $conflicts += $folder
    } else {
        Write-Host "  ✅ $folder (clear)" -ForegroundColor Green
    }
}

if ($conflicts.Count -gt 0) {
    Write-Host ""
    Write-Host "⚠️  WARNING: Migration target folders already exist. They will be OVERWRITTEN." -ForegroundColor Yellow
    $confirm = Read-Host "Continue? (yes/no)"
    if ($confirm -ne "yes") { exit 0 }
}

# 6. Count files to be migrated
Write-Host ""
Write-Host "Analyzing scope of migration..." -ForegroundColor Cyan

$engineFileCount = (Get-ChildItem engine -Recurse -File | Measure-Object).Count
$testFileCount = (Get-ChildItem tests -Recurse -File -Filter "*.lua" | Measure-Object).Count
$docFileCount = (Get-ChildItem api, architecture, docs -Recurse -File -Filter "*.md" -ErrorAction SilentlyContinue | Measure-Object).Count

Write-Host "  📁 Engine files: $engineFileCount" -ForegroundColor Cyan
Write-Host "  🧪 Test files (.lua): $testFileCount" -ForegroundColor Cyan
Write-Host "  📖 Doc files (.md): $docFileCount" -ForegroundColor Cyan

# 7. Check for requires patterns in key files
Write-Host ""
Write-Host "Scanning for require() statements that will need updating..." -ForegroundColor Cyan

$requirePatterns = @(
    "require\(.*['\"]ai\.",
    "require\(.*['\"]economy\.",
    "require\(.*['\"]geoscape\.",
    "require\(.*['\"]basescape\.",
    "require\(.*['\"]battlescape\.",
    "require\(.*['\"]gui\.",
    "require\(.*['\"]utils\."
)

$totalRequires = 0
foreach ($pattern in $requirePatterns) {
    $matches = Select-String -Path "engine/**/*.lua" -Pattern $pattern -Recurse -ErrorAction SilentlyContinue
    if ($matches) {
        $count = ($matches | Measure-Object).Count
        Write-Host "  $pattern : $count occurrences" -ForegroundColor Yellow
        $totalRequires += $count
    }
}

Write-Host "  📊 Total requires to update in engine: $totalRequires" -ForegroundColor Cyan

# 8. Check test imports
Write-Host ""
$testRequires = Select-String -Path "tests/**/*.lua" -Pattern "require\(" -Recurse -ErrorAction SilentlyContinue
if ($testRequires) {
    $testRequireCount = ($testRequires | Measure-Object).Count
    Write-Host "  📊 Total requires in tests: $testRequireCount" -ForegroundColor Cyan
}

# 9. Summary and recommendation
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  MIGRATION SCOPE SUMMARY                                         ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "
📋 WHAT WILL HAPPEN:
   1. Create new folder structure (systems/, layers/, ui/)
   2. Copy ~$engineFileCount engine files to new locations
   3. Update ~$totalRequires require() statements in engine files
   4. Update ~$testRequireCount require() statements in test files
   5. Reorganize ~50 test mock data folders
   6. Delete old engine folders (ai/, economy/, geoscape/, etc.)
   7. Update ~20 API documentation files
   8. Update ~6 architecture documentation files

⏱️  ESTIMATED TIME: 18-27 hours
   - Automated parts: 2-4 hours
   - Testing/verification: 4-6 hours
   - Documentation updates: 3-4 hours
   - Troubleshooting/fixes: 8-12 hours

⚠️  CRITICAL STEPS:
   - Tests MUST be updated parallel with engine changes
   - Import scanner MUST be reconfigured before validation
   - Game must be tested after each major phase

✅ SAFETY MEASURES:
   - All changes can be reverted with: git reset --hard HEAD~1
   - Create git branch before starting: git checkout -b migration-work
   - Backup recommended: git branch migration-backup

" -ForegroundColor White

# Ask for confirmation
Write-Host "Do you want to proceed with migration? (yes/no)" -ForegroundColor Cyan
$confirm = Read-Host

if ($confirm -eq "yes") {
    Write-Host ""
    Write-Host "✅ Preparation complete. Ready to proceed." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Create git branch: git checkout -b engine-restructure" -ForegroundColor White
    Write-Host "  2. Run: .\migrate\2_CopyFilesToNewStructure.ps1" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "❌ Migration cancelled." -ForegroundColor Yellow
    exit 0
}
