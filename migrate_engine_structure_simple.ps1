param(
    [switch]$DryRun = $false
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Engine Restructure Migration Script" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "DRY RUN MODE - No changes will be made`n" -ForegroundColor Yellow
}

$projectRoot = "c:\Users\tombl\Documents\Projects"
$engineRoot = Join-Path $projectRoot "engine"

# Check we're in the right directory
if (-not (Test-Path $engineRoot)) {
    Write-Host "Error: engine folder not found at $engineRoot" -ForegroundColor Red
    exit 1
}

Write-Host "Project root: $projectRoot" -ForegroundColor Cyan
Write-Host "Engine root: $engineRoot`n" -ForegroundColor Cyan

# ============================================================================
# Create New Folder Structure
# ============================================================================

Write-Host "Creating new folder structure..." -ForegroundColor Cyan

$folders = @(
    "engine/core",
    "engine/shared",
    "engine/battlescape",
    "engine/battlescape/ui",
    "engine/battlescape/logic",
    "engine/battlescape/systems",
    "engine/battlescape/components",
    "engine/battlescape/entities",
    "engine/battlescape/map",
    "engine/battlescape/effects",
    "engine/battlescape/rendering",
    "engine/battlescape/combat",
    "engine/battlescape/utils",
    "engine/battlescape/tests",
    "engine/geoscape",
    "engine/geoscape/ui",
    "engine/geoscape/logic",
    "engine/geoscape/systems",
    "engine/geoscape/tests",
    "engine/basescape",
    "engine/basescape/ui",
    "engine/basescape/logic",
    "engine/basescape/systems",
    "engine/basescape/tests",
    "engine/interception",
    "engine/interception/ui",
    "engine/interception/logic",
    "engine/interception/systems",
    "engine/interception/tests",
    "engine/menu",
    "engine/tools",
    "engine/tools/map_editor",
    "engine/tools/validators",
    "engine/scripts",
    "engine/tests",
    "engine/tests/core",
    "engine/tests/battlescape",
    "engine/tests/integration",
    "engine/tests/performance",
    "engine/tests/systems"
)

$created = 0
foreach ($folder in $folders) {
    $fullPath = Join-Path $projectRoot $folder
    if (-not (Test-Path $fullPath)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        }
        Write-Host "  Created: $folder" -ForegroundColor Green
        $created++
    }
}

Write-Host "`nCreated $created new folders`n" -ForegroundColor Green

# ============================================================================
# Move Files
# ============================================================================

function Move-File {
    param([string]$source, [string]$destination)

    if (-not (Test-Path $source)) {
        Write-Host "  Source not found: $source" -ForegroundColor Yellow
        return $false
    }

    $destDir = Split-Path $destination -Parent
    if (-not (Test-Path $destDir)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $destDir -Force | Out-Null
        }
    }

    if (-not $DryRun) {
        Move-Item -Path $source -Destination $destination -Force
    }

    Write-Host "  Moved: $(Split-Path $source -Leaf) -> $destination" -ForegroundColor Green
    return $true
}

Write-Host "Moving core systems..." -ForegroundColor Cyan

$coreMoves = @(
    @{From="engine/systems/state_manager.lua"; To="engine/core/state_manager.lua"},
    @{From="engine/systems/assets.lua"; To="engine/core/assets.lua"},
    @{From="engine/systems/data_loader.lua"; To="engine/core/data_loader.lua"},
    @{From="engine/systems/mod_manager.lua"; To="engine/core/mod_manager.lua"}
)

$moved = 0
foreach ($move in $coreMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-File $source $dest) { $moved++ }
}

Write-Host "`nMoved $moved core system files`n" -ForegroundColor Green

Write-Host "Moving shared systems..." -ForegroundColor Cyan

$sharedMoves = @(
    @{From="engine/systems/pathfinding.lua"; To="engine/shared/pathfinding.lua"},
    @{From="engine/systems/spatial_hash.lua"; To="engine/shared/spatial_hash.lua"},
    @{From="engine/systems/team.lua"; To="engine/shared/team.lua"},
    @{From="engine/systems/ui.lua"; To="engine/shared/ui.lua"}
)

$moved = 0
foreach ($move in $sharedMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-File $source $dest) { $moved++ }
}

Write-Host "`nMoved $moved shared system files`n" -ForegroundColor Green

Write-Host "Moving battlescape files..." -ForegroundColor Cyan

# UI layer
$uiMoves = @(
    @{From="engine/modules/battlescape/input.lua"; To="engine/battlescape/ui/input.lua"},
    @{From="engine/modules/battlescape/render.lua"; To="engine/battlescape/ui/render.lua"},
    @{From="engine/modules/battlescape/ui.lua"; To="engine/battlescape/ui/ui.lua"},
    @{From="engine/modules/battlescape/logic.lua"; To="engine/battlescape/ui/logic.lua"},
    @{From="engine/modules/battlescape.lua"; To="engine/battlescape/init.lua"}
)

$moved = 0
foreach ($move in $uiMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-File $source $dest) { $moved++ }
}

# Logic layer
$logicMoves = @(
    @{From="engine/battle/battlefield.lua"; To="engine/battlescape/logic/battlefield.lua"},
    @{From="engine/battle/turn_manager.lua"; To="engine/battlescape/logic/turn_manager.lua"},
    @{From="engine/battle/unit_selection.lua"; To="engine/battlescape/logic/unit_selection.lua"},
    @{From="engine/battle/battlescape_integration.lua"; To="engine/battlescape/logic/integration.lua"}
)

foreach ($move in $logicMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-File $source $dest) { $moved++ }
}

# Map systems
$mapMoves = @(
    @{From="engine/battle/grid_map.lua"; To="engine/battlescape/map/grid_map.lua"},
    @{From="engine/battle/map_generator.lua"; To="engine/battlescape/map/map_generator.lua"},
    @{From="engine/battle/map_saver.lua"; To="engine/battlescape/map/map_saver.lua"},
    @{From="engine/battle/map_block.lua"; To="engine/battlescape/map/map_block.lua"},
    @{From="engine/battle/mapblock_system.lua"; To="engine/battlescape/map/mapblock_system.lua"}
)

foreach ($move in $mapMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-File $source $dest) { $moved++ }
}

# Effects
$effectMoves = @(
    @{From="engine/battle/animation_system.lua"; To="engine/battlescape/effects/animation_system.lua"},
    @{From="engine/battle/fire_system.lua"; To="engine/battlescape/effects/fire_system.lua"},
    @{From="engine/battle/smoke_system.lua"; To="engine/battlescape/effects/smoke_system.lua"}
)

foreach ($move in $effectMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-File $source $dest) { $moved++ }
}

# Rendering
$renderMoves = @(
    @{From="engine/battle/renderer.lua"; To="engine/battlescape/rendering/renderer.lua"},
    @{From="engine/battle/camera.lua"; To="engine/battlescape/rendering/camera.lua"}
)

foreach ($move in $renderMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-File $source $dest) { $moved++ }
}

# Combat systems
$combatMoves = @(
    @{From="engine/systems/weapon_system.lua"; To="engine/battlescape/combat/weapon_system.lua"},
    @{From="engine/systems/equipment_system.lua"; To="engine/battlescape/combat/equipment_system.lua"},
    @{From="engine/systems/action_system.lua"; To="engine/battlescape/combat/action_system.lua"},
    @{From="engine/systems/los_system.lua"; To="engine/battlescape/combat/los_system.lua"},
    @{From="engine/systems/los_optimized.lua"; To="engine/battlescape/combat/los_optimized.lua"},
    @{From="engine/systems/unit.lua"; To="engine/battlescape/combat/unit.lua"},
    @{From="engine/systems/battle_tile.lua"; To="engine/battlescape/combat/battle_tile.lua"}
)

foreach ($move in $combatMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-File $source $dest) { $moved++ }
}

Write-Host "`nMoved $moved battlescape files`n" -ForegroundColor Green

# ============================================================================
# Summary
# ============================================================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Migration Summary" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "DRY RUN COMPLETE - No actual changes were made" -ForegroundColor Yellow
    Write-Host "Run the script without -DryRun to apply changes.`n" -ForegroundColor Cyan
} else {
    Write-Host "Migration Complete!`n" -ForegroundColor Green

    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Update require paths in main.lua and other files" -ForegroundColor White
    Write-Host "2. Run the game with Love2D console: lovec engine" -ForegroundColor White
    Write-Host "3. Check console for module not found errors" -ForegroundColor White
    Write-Host "4. Update wiki documentation" -ForegroundColor White
    Write-Host "5. Run tests: love scripts/run_test.lua" -ForegroundColor White
    Write-Host "6. Commit changes to git`n" -ForegroundColor White

    Write-Host "Reference documents:" -ForegroundColor Cyan
    Write-Host "- tasks/TODO/ENGINE-RESTRUCTURE-QUICK-REFERENCE.md" -ForegroundColor White
    Write-Host "- tasks/TODO/ENGINE-RESTRUCTURE-VISUAL-COMPARISON.md" -ForegroundColor White
    Write-Host "- tasks/TODO/TASK-ENGINE-RESTRUCTURE.md`n" -ForegroundColor White
}

Write-Host "============================================`n" -ForegroundColor Green