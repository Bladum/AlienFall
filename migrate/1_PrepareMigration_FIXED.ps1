# Validate project structure before migration
# Run this first to ensure safe migration

param(
    [switch]$DryRun = $false,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"
if ($Verbose) { $VerbosePreference = "Continue" }

Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "PHASE 4.1: PREPARE MIGRATION" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan

# 1. Check we're in project root
if (-not (Test-Path "engine")) {
    Write-Host "[ERROR] 'engine' folder not found. Run from project root." -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Project root confirmed" -ForegroundColor Green

# 2. Check git is initialized
if (-not (Test-Path ".git")) {
    Write-Host "[ERROR] Not a git repository. Initialize git first." -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Git repository found" -ForegroundColor Green

# 3. Check for dirty working directory
$gitStatus = git status --porcelain
if ($gitStatus) {
    Write-Host "[WARN] Uncommitted changes detected:" -ForegroundColor Yellow
    Write-Host $gitStatus
    Write-Host ""
    $confirm = Read-Host "Continue anyway? (yes/no)"
    if ($confirm -ne "yes") { exit 0 }
} else {
    Write-Host "[OK] Clean working directory" -ForegroundColor Green
}

# 4. Verify CURRENT (OLD) engine structure exists
$requiredFolders = @(
    "engine/core",
    "engine/ai",
    "engine/economy",
    "engine/geoscape",
    "engine/basescape",
    "engine/battlescape",
    "engine/gui",
    "engine/utils",
    "engine/analytics",
    "engine/content",
    "engine/lore",
    "engine/politics",
    "engine/tutorial",
    "engine/interception"
)

Write-Host ""
Write-Host "Checking current engine structure..." -ForegroundColor Cyan

$missingFolders = @()
foreach ($folder in $requiredFolders) {
    if (Test-Path $folder) {
        Write-Host "  [OK] $folder" -ForegroundColor Green
    } else {
        Write-Host "  [MISS] $folder" -ForegroundColor Red
        $missingFolders += $folder
    }
}

if ($missingFolders.Count -gt 0) {
    Write-Host ""
    Write-Host "[ERROR] Required folders are missing:" -ForegroundColor Red
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
Write-Host "Checking for conflicts..." -ForegroundColor Cyan

$conflicts = @()
foreach ($folder in $newFolders) {
    if (Test-Path $folder) {
        Write-Host "  [CONFLICT] $folder already exists!" -ForegroundColor Yellow
        $conflicts += $folder
    } else {
        Write-Host "  [OK] $folder clear" -ForegroundColor Green
    }
}

if ($conflicts.Count -gt 0) {
    Write-Host ""
    Write-Host "[WARN] Migration target folders already exist. They will be OVERWRITTEN." -ForegroundColor Yellow
    $confirm = Read-Host "Continue? (yes/no)"
    if ($confirm -ne "yes") { exit 0 }
}

# 6. Count files to be migrated
Write-Host ""
Write-Host "Analyzing scope..." -ForegroundColor Cyan

$engineFileCount = (Get-ChildItem engine -Recurse -File | Measure-Object).Count
$testFileCount = (Get-ChildItem tests -Recurse -File -Filter "*.lua" | Measure-Object).Count

Write-Host "  Engine files: $engineFileCount" -ForegroundColor Cyan
Write-Host "  Test files (.lua): $testFileCount" -ForegroundColor Cyan

# 7. Summary and recommendation
Write-Host ""
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "MIGRATION SCOPE SUMMARY" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "WHAT WILL HAPPEN:"
Write-Host "  1. Create new folder structure (systems/, layers/, ui/)"
Write-Host "  2. Copy ~$engineFileCount engine files to new locations"
Write-Host "  3. Update require() statements in engine files"
Write-Host "  4. Update require() statements in test files"
Write-Host "  5. Delete old engine folders"
Write-Host ""
Write-Host "ESTIMATED TIME: 18-27 hours"
Write-Host ""
Write-Host "SAFETY MEASURES:"
Write-Host "  - All changes can be reverted with: git reset --hard HEAD"
Write-Host "  - Create git branch before starting"
Write-Host "  - Backup recommended"
Write-Host ""

# Ask for confirmation
Write-Host "Do you want to proceed with migration? (yes/no)" -ForegroundColor Cyan
$confirm = Read-Host

if ($confirm -eq "yes") {
    Write-Host ""
    Write-Host "[OK] Preparation complete. Ready to proceed." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Create git branch: git checkout -b engine-restructure" -ForegroundColor White
    Write-Host "  2. Run: .\migrate\2_CopyFilesToNewStructure.ps1" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "[CANCELLED] Migration cancelled." -ForegroundColor Yellow
    exit 0
}
