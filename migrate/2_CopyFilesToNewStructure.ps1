# Copy files from old structure to new structure
# Run AFTER 1_PrepareMigration.ps1 completes

param(
    [switch]$DryRun = $false,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"
if ($Verbose) { $VerbosePreference = "Continue" }

Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  PHASE 4.2: COPY FILES TO NEW STRUCTURE                          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Define copy operations: @(Source, Destination)
$copyOperations = @(
    # Utils → core/utils
    @("engine/utils", "engine/core/utils"),
    
    # Systems - horizontal
    @("engine/ai", "engine/systems/ai"),
    @("engine/economy", "engine/systems/economy"),
    @("engine/politics", "engine/systems/politics"),
    @("engine/analytics", "engine/systems/analytics"),
    @("engine/content", "engine/systems/content"),
    @("engine/lore", "engine/systems/lore"),
    @("engine/tutorial", "engine/systems/tutorial"),
    
    # Layers - vertical
    @("engine/geoscape", "engine/layers/geoscape"),
    @("engine/basescape", "engine/layers/basescape"),
    @("engine/battlescape", "engine/layers/battlescape"),
    @("engine/interception", "engine/layers/interception"),
    
    # UI
    @("engine/gui", "engine/ui"),
    @("engine/widgets", "engine/ui/widgets")
)

$successCount = 0
$failureCount = 0

foreach ($op in $copyOperations) {
    $source = $op[0]
    $dest = $op[1]
    
    if (-not (Test-Path $source)) {
        Write-Host "⏭️  Skipping (not found): $source → $dest" -ForegroundColor Gray
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
    
    # Copy directory
    if ($DryRun) {
        Write-Host "🔄 [DRY RUN] Would copy: $source → $dest" -ForegroundColor Yellow
    } else {
        Write-Host "🔄 Copying: $source → $dest" -ForegroundColor Cyan
        
        if (Test-Path $dest) {
            Write-Host "   Removing existing destination..." -ForegroundColor Gray
            Remove-Item -Path $dest -Recurse -Force
        }
        
        Copy-Item -Path $source -Destination $dest -Recurse -Force
        Write-Host "   ✅ Done" -ForegroundColor Green
        $successCount++
    }
}

# Special handling: move utils inside core
if (-not $DryRun -and (Test-Path "engine/core/utils")) {
    Write-Host ""
    Write-Host "Note: Old utils/ location can be deleted after verification" -ForegroundColor Gray
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  COPY COMPLETE                                                   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "📋 Dry run completed. No files were actually copied." -ForegroundColor Yellow
    Write-Host "Run without -DryRun to perform actual migration." -ForegroundColor Yellow
} else {
    Write-Host "✅ Copied $successCount directories successfully" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "Next step: Update imports in engine files" -ForegroundColor Cyan
    Write-Host "  Run: .\migrate\3_UpdateImportsInEngine.ps1" -ForegroundColor White
}
