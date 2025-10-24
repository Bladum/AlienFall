# Reorganize test mock data structure to match new engine structure
# Run AFTER 4_UpdateImportsInTests.ps1 completes

param(
    [switch]$DryRun = $false,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"
if ($Verbose) { $VerbosePreference = "Continue" }

Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  PHASE 4.5: REORGANIZE TEST MOCK DATA STRUCTURE                  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Define mock folder reorganization operations
$mockOperations = @(
    # Mock folder structure to reorganize
    @("tests/mock/engine/ai", "tests/mock/engine/systems/ai"),
    @("tests/mock/engine/economy", "tests/mock/engine/systems/economy"),
    @("tests/mock/engine/politics", "tests/mock/engine/systems/politics"),
    @("tests/mock/engine/analytics", "tests/mock/engine/systems/analytics"),
    @("tests/mock/engine/content", "tests/mock/engine/systems/content"),
    @("tests/mock/engine/lore", "tests/mock/engine/systems/lore"),
    @("tests/mock/engine/tutorial", "tests/mock/engine/systems/tutorial"),
    @("tests/mock/engine/geoscape", "tests/mock/engine/layers/geoscape"),
    @("tests/mock/engine/basescape", "tests/mock/engine/layers/basescape"),
    @("tests/mock/engine/battlescape", "tests/mock/engine/layers/battlescape"),
    @("tests/mock/engine/interception", "tests/mock/engine/layers/interception"),
    @("tests/mock/engine/gui", "tests/mock/engine/ui"),
    @("tests/mock/engine/widgets", "tests/mock/engine/ui/widgets"),
    @("tests/mock/engine/utils", "tests/mock/engine/core/utils")
)

$successCount = 0

foreach ($op in $mockOperations) {
    $source = $op[0]
    $dest = $op[1]
    
    if (-not (Test-Path $source)) {
        Write-Host "⏭️  Skipping (not found): $source" -ForegroundColor Gray
        continue
    }
    
    # Create destination parent if needed
    $destParent = Split-Path -Parent $dest
    if (-not (Test-Path $destParent)) {
        Write-Host "  Creating parent directory: $destParent" -ForegroundColor Gray
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $destParent -Force | Out-Null
        }
    }
    
    # Move directory
    if ($DryRun) {
        Write-Host "🔄 [DRY RUN] Would move: $source → $dest" -ForegroundColor Yellow
    } else {
        Write-Host "🔄 Moving: $source → $dest" -ForegroundColor Cyan
        
        if (Test-Path $dest) {
            Write-Host "   Removing existing destination..." -ForegroundColor Gray
            Remove-Item -Path $dest -Recurse -Force
        }
        
        # Copy and delete (simpler and more reliable)
        Copy-Item -Path $source -Destination $dest -Recurse -Force
        Remove-Item -Path $source -Recurse -Force
        
        Write-Host "   ✅ Done" -ForegroundColor Green
        $successCount++
    }
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  MOCK DATA REORGANIZATION COMPLETE                               ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "📋 Dry run completed." -ForegroundColor Yellow
    Write-Host "No mock folders were actually moved." -ForegroundColor Yellow
    Write-Host "Run without -DryRun to perform actual reorganization." -ForegroundColor Yellow
} else {
    Write-Host "✅ Reorganized $successCount mock data folders" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "Next step: Delete old engine directories" -ForegroundColor Cyan
    Write-Host "  Run: .\migrate\6_DeleteOldDirectories.ps1" -ForegroundColor White
}
