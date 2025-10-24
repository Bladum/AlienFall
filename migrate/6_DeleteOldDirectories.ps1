# Delete old engine directories after successful migration
# Run AFTER verifying new structure is complete

param(
    [switch]$DryRun = $false,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"
if ($Verbose) { $VerbosePreference = "Continue" }

Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  PHASE 4.6: DELETE OLD DIRECTORIES                               ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host ""
Write-Host "⚠️  WARNING: This step DELETES old directories permanently!" -ForegroundColor Yellow
Write-Host "Make sure you've verified the new structure is complete and working." -ForegroundColor Yellow
Write-Host ""

$foldersToDelete = @(
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

Write-Host "Folders to delete:" -ForegroundColor Cyan
$foldersToDelete | ForEach-Object { Write-Host "  - $_" }

Write-Host ""
$confirm = Read-Host "Continue with deletion? (yes/no)"

if ($confirm -ne "yes") {
    Write-Host "❌ Deletion cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""

$deletedCount = 0

foreach ($folder in $foldersToDelete) {
    if (-not (Test-Path $folder)) {
        Write-Host "⏭️  Skipping (not found): $folder" -ForegroundColor Gray
        continue
    }
    
    if ($DryRun) {
        Write-Host "🗑️  [DRY RUN] Would delete: $folder" -ForegroundColor Yellow
    } else {
        Write-Host "🗑️  Deleting: $folder" -ForegroundColor Red
        
        # Use git rm for git repo to preserve history
        if (Test-Path ".git") {
            git rm -r $folder 2>$null
        } else {
            Remove-Item -Path $folder -Recurse -Force
        }
        
        Write-Host "   ✅ Deleted" -ForegroundColor Green
        $deletedCount++
    }
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  OLD DIRECTORY CLEANUP COMPLETE                                  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "📋 Dry run completed." -ForegroundColor Yellow
    Write-Host "No directories were actually deleted." -ForegroundColor Yellow
    Write-Host "Run without -DryRun to perform actual deletion." -ForegroundColor Yellow
} else {
    Write-Host "✅ Deleted $deletedCount old directories" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "Next step: Validate new structure" -ForegroundColor Cyan
    Write-Host "  Run: .\migrate\7_ValidateStructure.ps1" -ForegroundColor White
}
