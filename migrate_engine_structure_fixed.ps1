# ============================================================================
# Engine Folder Restructure Migration Script (FIXED VERSION)
# ============================================================================

param(
    [switch]$DryRun = $false,
    [switch]$SkipBackup = $false
)

$ErrorActionPreference = "Stop"
$projectRoot = "c:\Users\tombl\Documents\Projects"
$engineRoot = Join-Path $projectRoot "engine"

# Colors for output
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { param($msg) Write-Host $msg -ForegroundColor Red }

# ============================================================================
# Pre-flight Checks
# ============================================================================

Write-Info "============================================"
Write-Info "Engine Restructure Migration Script"
Write-Info "============================================`n"

if ($DryRun) {
    Write-Warning "DRY RUN MODE - No changes will be made`n"
}

# Check we're in the right directory
if (-not (Test-Path $engineRoot)) {
    Write-Error "Error: engine folder not found at $engineRoot"
    Write-Error "Please run this script from the project root."
    exit 1
}

Write-Info "Project root: $projectRoot"
Write-Info "Engine root: $engineRoot`n"

# ============================================================================
# Create Backup Branch
# ============================================================================

if (-not $SkipBackup -and -not $DryRun) {
    Write-Info "Creating backup branch..."
    Push-Location $projectRoot
    try {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $backupBranch = "backup/pre-restructure-$timestamp"
        git branch $backupBranch
        Write-Success "✓ Created backup branch: $backupBranch`n"
    } catch {
        Write-Error "Failed to create backup branch: $_"
        exit 1
    }
    finally {
        Pop-Location
    }
}

# ============================================================================
# Helper Functions
# ============================================================================

function New-DirectoryIfNotExists {
    param([string]$path)
    if (-not (Test-Path $path)) {
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
        }
        Write-Info "  Created: $path"
        return $true
    }
    return $false
}

function Move-FileWithLogging {
    param([string]$source, [string]$destination)

    if (-not (Test-Path $source)) {
        Write-Warning "  Source not found: $source"
        return $false
    }

    $destDir = Split-Path $destination -Parent
    New-DirectoryIfNotExists $destDir | Out-Null

    if (-not $DryRun) {
        Move-Item -Path $source -Destination $destination -Force
    }

    Write-Info "  Moved: $(Split-Path $source -Leaf) -> $destination"
    return $true
}

# ============================================================================
# Phase 1: Create New Folder Structure
# ============================================================================

Write-Info "`n============================================"
Write-Info "Phase 1: Creating New Folder Structure"
Write-Info "============================================`n"

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
    if (New-DirectoryIfNotExists $fullPath) { $created++ }
}

Write-Success "`n✓ Phase 1 Complete: Created $created new folders`n"

# ============================================================================
# Phase 2: Move Core Systems
# ============================================================================

Write-Info "`n============================================"
Write-Info "Phase 2: Moving Core Systems"
Write-Info "============================================`n"

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
    if (Move-FileWithLogging $source $dest) { $moved++ }
}

Write-Success "`n✓ Phase 2 Complete: Moved $moved core system files`n"

# ============================================================================
# Phase 3: Move Shared Systems
# ============================================================================

Write-Info "`n============================================"
Write-Info "Phase 3: Moving Shared Systems"
Write-Info "============================================`n"

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
    if (Move-FileWithLogging $source $dest) { $moved++ }
}

Write-Success "`n✓ Phase 3 Complete: Moved $moved shared system files`n"

# ============================================================================
# Phase 4: Restructure Battlescape
# ============================================================================

Write-Info "`n============================================"
Write-Info "Phase 4: Restructuring Battlescape"
Write-Info "============================================`n"

# UI layer
Write-Info "Moving battlescape UI layer..."
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
    if (Move-FileWithLogging $source $dest) { $moved++ }
}

# Logic layer
Write-Info "`nMoving battlescape logic..."
$logicMoves = @(
    @{From="engine/battle/battlefield.lua"; To="engine/battlescape/logic/battlefield.lua"},
    @{From="engine/battle/turn_manager.lua"; To="engine/battlescape/logic/turn_manager.lua"},
    @{From="engine/battle/unit_selection.lua"; To="engine/battlescape/logic/unit_selection.lua"},
    @{From="engine/battle/battlescape_integration.lua"; To="engine/battlescape/logic/integration.lua"}
)

foreach ($move in $logicMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-FileWithLogging $source $dest) { $moved++ }
}

# Map systems
Write-Info "`nMoving battlescape map systems..."
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
    if (Move-FileWithLogging $source $dest) { $moved++ }
}

# Effects
Write-Info "`nMoving battlescape effects..."
$effectMoves = @(
    @{From="engine/battle/animation_system.lua"; To="engine/battlescape/effects/animation_system.lua"},
    @{From="engine/battle/fire_system.lua"; To="engine/battlescape/effects/fire_system.lua"},
    @{From="engine/battle/smoke_system.lua"; To="engine/battlescape/effects/smoke_system.lua"}
)

foreach ($move in $effectMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-FileWithLogging $source $dest) { $moved++ }
}

# Rendering
Write-Info "`nMoving battlescape rendering..."
$renderMoves = @(
    @{From="engine/battle/renderer.lua"; To="engine/battlescape/rendering/renderer.lua"},
    @{From="engine/battle/camera.lua"; To="engine/battlescape/rendering/camera.lua"}
)

foreach ($move in $renderMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-FileWithLogging $source $dest) { $moved++ }
}

# Combat systems
Write-Info "`nMoving combat systems from systems/..."
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
    if (Move-FileWithLogging $source $dest) { $moved++ }
}

Write-Success "`n✓ Phase 4 Complete: Moved $moved battlescape files`n"

# ============================================================================
# Phase 5: Restructure Geoscape
# ============================================================================

Write-Info "`n============================================"
Write-Info "Phase 5: Restructuring Geoscape"
Write-Info "============================================`n"

$geoscapeMoves = @(
    @{From="engine/modules/geoscape/init.lua"; To="engine/geoscape/init.lua"},
    @{From="engine/modules/geoscape/input.lua"; To="engine/geoscape/ui/input.lua"},
    @{From="engine/modules/geoscape/render.lua"; To="engine/geoscape/ui/render.lua"},
    @{From="engine/modules/geoscape/data.lua"; To="engine/geoscape/logic/data.lua"},
    @{From="engine/modules/geoscape/logic.lua"; To="engine/geoscape/logic/world_state.lua"}
)

$moved = 0
foreach ($move in $geoscapeMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-FileWithLogging $source $dest) { $moved++ }
}

Write-Success "`n✓ Phase 5 Complete: Moved $moved geoscape files`n"

# ============================================================================
# Phase 6: Restructure Basescape
# ============================================================================

Write-Info "`n============================================"
Write-Info "Phase 6: Restructuring Basescape"
Write-Info "============================================`n"

$basescapeMoves = @(
    @{From="engine/modules/basescape.lua"; To="engine/basescape/init.lua"}
)

$moved = 0
foreach ($move in $basescapeMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-FileWithLogging $source $dest) { $moved++ }
}

Write-Success "`n✓ Phase 6 Complete: Moved $moved basescape files`n"

# ============================================================================
# Phase 7: Reorganize Menus and Tools
# ============================================================================

Write-Info "`n============================================"
Write-Info "Phase 7: Reorganizing Menus and Tools"
Write-Info "============================================`n"

# Menu files
Write-Info "Moving menu screens..."
$menuMoves = @(
    @{From="engine/modules/menu.lua"; To="engine/menu/main_menu.lua"},
    @{From="engine/modules/tests_menu.lua"; To="engine/menu/tests_menu.lua"},
    @{From="engine/modules/widget_showcase.lua"; To="engine/menu/widget_showcase.lua"}
)

$moved = 0
foreach ($move in $menuMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-FileWithLogging $source $dest) { $moved++ }
}

# Tools
Write-Info "`nMoving tools..."
$toolMoves = @(
    @{From="engine/modules/map_editor.lua"; To="engine/tools/map_editor/init.lua"},
    @{From="engine/systems/mapblock_validator.lua"; To="engine/tools/validators/mapblock_validator.lua"},
    @{From="engine/utils/verify_assets.lua"; To="engine/tools/validators/asset_verifier.lua"}
)

foreach ($move in $toolMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-FileWithLogging $source $dest) { $moved++ }
}

Write-Success "`n✓ Phase 7 Complete: Moved $moved menu and tool files`n"

# ============================================================================
# Phase 8: Move Scripts and Tests
# ============================================================================

Write-Info "`n============================================"
Write-Info "Phase 8: Moving Scripts and Tests"
Write-Info "============================================`n"

# Scripts
Write-Info "Moving utility scripts..."
$scriptFiles = Get-ChildItem -Path $engineRoot -Filter "run_*.lua"
$moved = 0
foreach ($file in $scriptFiles) {
    $source = $file.FullName
    $dest = Join-Path $engineRoot "scripts/$($file.Name)"
    if (Move-FileWithLogging $source $dest) { $moved++ }
}

$testRunners = @("test_runner.lua", "test_fs2.lua")
foreach ($testFile in $testRunners) {
    $source = Join-Path $engineRoot $testFile
    if (Test-Path $source) {
        $dest = Join-Path $engineRoot "scripts/$testFile"
        if (Move-FileWithLogging $source $dest) { $moved++ }
    }
}

# Tests
Write-Info "`nMoving test files..."
$testMoves = @(
    @{From="engine/tests/test_mapblock_integration.lua"; To="engine/tests/integration/test_mapblock_integration.lua"},
    @{From="engine/tests/test_phase2.lua"; To="engine/tests/integration/test_phase2.lua"},
    @{From="engine/tests/test_performance.lua"; To="engine/tests/performance/test_performance.lua"},
    @{From="engine/tests/test_battle_systems.lua"; To="engine/tests/systems/test_battle_systems.lua"},
    @{From="engine/tests/test_los_fow.lua"; To="engine/tests/systems/test_los_fow.lua"}
)

foreach ($move in $testMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-FileWithLogging $source $dest) { $moved++ }
}

Write-Success "`n✓ Phase 8 Complete: Moved $moved script and test files`n"

# ============================================================================
# Phase 9: Cleanup Empty Folders
# ============================================================================

Write-Info "`n============================================"
Write-Info "Phase 9: Cleaning Up Empty Folders"
Write-Info "============================================`n"

$foldersToCheck = @(
    "engine/battle",
    "engine/modules/battlescape",
    "engine/modules/geoscape"
)

$removed = 0
foreach ($folder in $foldersToCheck) {
    $fullPath = Join-Path $projectRoot $folder
    if (Test-Path $fullPath) {
        $items = Get-ChildItem -Path $fullPath -Recurse
        if ($items.Count -eq 0) {
            if (-not $DryRun) {
                Remove-Item -Path $fullPath -Recurse -Force
            }
            Write-Info "  Removed empty folder: $folder"
            $removed++
        } else {
            Write-Warning "  Folder not empty, keeping: $folder"
        }
    }
}

Write-Success "`n✓ Phase 9 Complete: Cleaned up $removed empty folders`n"

# ============================================================================
# Summary
# ============================================================================

Write-Info "`n============================================"
Write-Info "Migration Summary"
Write-Info "============================================`n"

if ($DryRun) {
    Write-Warning "DRY RUN COMPLETE - No actual changes were made"
    Write-Info "Run the script without -DryRun to apply changes.`n"
} else {
    Write-Success "✓ Migration Complete!`n"

    Write-Info "Next Steps:"
    Write-Info "1. Update require paths in main.lua and other files"
    Write-Info "2. Run the game with Love2D console: lovec engine"
    Write-Info "3. Check console for ""module not found"" errors"
    Write-Info "4. Update wiki documentation"
    Write-Info "5. Run tests: love scripts/run_test.lua"
    Write-Info "6. Commit changes to git`n"

    Write-Info "Reference documents:"
    Write-Info "- tasks/TODO/ENGINE-RESTRUCTURE-QUICK-REFERENCE.md"
    Write-Info "- tasks/TODO/ENGINE-RESTRUCTURE-VISUAL-COMPARISON.md"
    Write-Info "- tasks/TODO/TASK-ENGINE-RESTRUCTURE.md`n"

    if (-not $SkipBackup) {
        Write-Info "Backup branch created: $backupBranch"
        Write-Info "To restore backup: git checkout $backupBranch`n"
    }
}

Write-Success "============================================`n"