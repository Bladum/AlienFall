# ============================================================================
# Engine Folder Restructure Migration Script
# ============================================================================
# 
# This script automates the reorganization of the engine/ folder structure.
# It creates new folders and moves files according to TASK-ENGINE-RESTRUCTURE.
#
# IMPORTANT: This script will modify your project structure!
# - Creates a backup branch before starting
# - Run from project root: c:\Users\tombl\Documents\Projects\
# - Requires git to be available
#
# Usage:
#   .\migrate_engine_structure.ps1
#
# Options:
#   -DryRun : Show what would be done without making changes
#   -SkipBackup : Skip creating backup branch (NOT RECOMMENDED)
#
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
# Phase 0: Pre-flight Checks
# ============================================================================

Write-Info "`n============================================"
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

# Check git status
Push-Location $projectRoot
try {
    $gitStatus = git status --porcelain
    if ($gitStatus) {
        Write-Warning "Warning: You have uncommitted changes."
        Write-Warning "It's recommended to commit or stash changes before restructuring.`n"
        $continue = Read-Host "Continue anyway? (y/N)"
        if ($continue -ne 'y' -and $continue -ne 'Y') {
            Write-Info "Aborting."
            exit 0
        }
    }
} finally {
    Pop-Location
}

# Create backup branch
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
    } finally {
        Pop-Location
    }
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
    param(
        [string]$source,
        [string]$destination
    )
    
    if (-not (Test-Path $source)) {
        Write-Warning "  Source not found: $source"
        return $false
    }
    
    $destDir = Split-Path $destination -Parent
    New-DirectoryIfNotExists $destDir | Out-Null
    
    if (-not $DryRun) {
        Move-Item -Path $source -Destination $destination -Force
    }
    
    Write-Info "  Moved: $(Split-Path $source -Leaf) → $destination"
    return $true
}

function Copy-FileWithLogging {
    param(
        [string]$source,
        [string]$destination
    )
    
    if (-not (Test-Path $source)) {
        Write-Warning "  Source not found: $source"
        return $false
    }
    
    $destDir = Split-Path $destination -Parent
    New-DirectoryIfNotExists $destDir | Out-Null
    
    if (-not $DryRun) {
        Copy-Item -Path $source -Destination $destination -Force
    }
    
    Write-Info "  Copied: $(Split-Path $source -Leaf) → $destination"
    return $true
}

function New-ReadmeFile {
    param(
        [string]$path,
        [string]$title,
        [string]$description
    )
    
    $readmePath = Join-Path $path "README.md"
    if (Test-Path $readmePath) {
        return $false
    }
    
    $content = @"
# $title

$description

"@
    
    if (-not $DryRun) {
        Set-Content -Path $readmePath -Value $content -Encoding UTF8
    }
    
    Write-Info "  Created README: $readmePath"
    return $true
}

# ============================================================================
# Phase 1: Create New Folder Structure
# ============================================================================

Write-Info "`n============================================"
Write-Info "Phase 1: Creating New Folder Structure"
Write-Info "============================================`n"

$newFolders = @(
    # Core folders
    @{Path="engine/core"; Desc="Essential systems used by all game modes"},
    @{Path="engine/shared"; Desc="Systems shared between multiple modes"},
    
    # Battlescape structure
    @{Path="engine/battlescape"; Desc="Tactical combat system"},
    @{Path="engine/battlescape/ui"; Desc="Battlescape UI layer (input, render, HUD)"},
    @{Path="engine/battlescape/logic"; Desc="Battlescape game logic"},
    @{Path="engine/battlescape/systems"; Desc="Battlescape ECS systems"},
    @{Path="engine/battlescape/components"; Desc="Battlescape ECS components"},
    @{Path="engine/battlescape/entities"; Desc="Battlescape entity factories"},
    @{Path="engine/battlescape/map"; Desc="Map generation and management"},
    @{Path="engine/battlescape/effects"; Desc="Visual and gameplay effects"},
    @{Path="engine/battlescape/rendering"; Desc="Rendering systems"},
    @{Path="engine/battlescape/combat"; Desc="Combat mechanics"},
    @{Path="engine/battlescape/utils"; Desc="Battlescape utilities"},
    @{Path="engine/battlescape/tests"; Desc="Battlescape tests"},
    
    # Geoscape structure
    @{Path="engine/geoscape"; Desc="Strategic map system"},
    @{Path="engine/geoscape/ui"; Desc="Geoscape UI layer"},
    @{Path="engine/geoscape/logic"; Desc="Geoscape game logic"},
    @{Path="engine/geoscape/systems"; Desc="Geoscape-specific systems"},
    @{Path="engine/geoscape/tests"; Desc="Geoscape tests"},
    
    # Basescape structure
    @{Path="engine/basescape"; Desc="Base management system"},
    @{Path="engine/basescape/ui"; Desc="Basescape UI layer"},
    @{Path="engine/basescape/logic"; Desc="Basescape game logic"},
    @{Path="engine/basescape/systems"; Desc="Basescape-specific systems"},
    @{Path="engine/basescape/tests"; Desc="Basescape tests"},
    
    # Interception structure
    @{Path="engine/interception"; Desc="Craft interception system"},
    @{Path="engine/interception/ui"; Desc="Interception UI layer"},
    @{Path="engine/interception/logic"; Desc="Interception game logic"},
    @{Path="engine/interception/systems"; Desc="Interception-specific systems"},
    @{Path="engine/interception/tests"; Desc="Interception tests"},
    
    # Menu and tools
    @{Path="engine/menu"; Desc="Menu screens"},
    @{Path="engine/tools"; Desc="Development tools"},
    @{Path="engine/tools/map_editor"; Desc="Map editor tool"},
    @{Path="engine/tools/validators"; Desc="Validation tools"},
    
    # Scripts and tests
    @{Path="engine/scripts"; Desc="Utility scripts"},
    @{Path="engine/tests"; Desc="Unified test suite"},
    @{Path="engine/tests/core"; Desc="Core system tests"},
    @{Path="engine/tests/battlescape"; Desc="Battlescape tests"},
    @{Path="engine/tests/integration"; Desc="Integration tests"},
    @{Path="engine/tests/performance"; Desc="Performance tests"},
    @{Path="engine/tests/systems"; Desc="Specific system tests"}
)

$created = 0
foreach ($folder in $newFolders) {
    $fullPath = Join-Path $projectRoot $folder.Path
    if (New-DirectoryIfNotExists $fullPath) {
        $created++
        # Create README for main folders
        if ($folder.Path -notlike "*/*/*/*") {
            New-ReadmeFile $fullPath $folder.Path $folder.Desc | Out-Null
        }
    }
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

Write-Info "Moving to core/..."
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

Write-Info "Moving to shared/..."
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
$battlescapeUIMoves = @(
    @{From="engine/modules/battlescape/input.lua"; To="engine/battlescape/ui/input.lua"},
    @{From="engine/modules/battlescape/render.lua"; To="engine/battlescape/ui/render.lua"},
    @{From="engine/modules/battlescape/ui.lua"; To="engine/battlescape/ui/ui.lua"},
    @{From="engine/modules/battlescape/logic.lua"; To="engine/battlescape/ui/logic.lua"},
    @{From="engine/modules/battlescape.lua"; To="engine/battlescape/init.lua"}
)

$moved = 0
foreach ($move in $battlescapeUIMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-FileWithLogging $source $dest) { $moved++ }
}

# Logic layer
Write-Info "`nMoving battlescape logic..."
$battlescapeLogicMoves = @(
    @{From="engine/battle/battlefield.lua"; To="engine/battlescape/logic/battlefield.lua"},
    @{From="engine/battle/turn_manager.lua"; To="engine/battlescape/logic/turn_manager.lua"},
    @{From="engine/battle/unit_selection.lua"; To="engine/battlescape/logic/unit_selection.lua"},
    @{From="engine/battle/battlescape_integration.lua"; To="engine/battlescape/logic/integration.lua"}
)

foreach ($move in $battlescapeLogicMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-FileWithLogging $source $dest) { $moved++ }
}

# ECS Systems
Write-Info "`nMoving battlescape ECS systems..."
$battleSystemsPath = Join-Path $engineRoot "battle/systems"
if (Test-Path $battleSystemsPath) {
    $systemFiles = Get-ChildItem -Path $battleSystemsPath -Filter "*.lua"
    foreach ($file in $systemFiles) {
        $source = $file.FullName
        $dest = Join-Path $engineRoot "battlescape/systems/$($file.Name)"
        if (Move-FileWithLogging $source $dest) { $moved++ }
    }
}

# ECS Components
Write-Info "`nMoving battlescape ECS components..."
$battleComponentsPath = Join-Path $engineRoot "battle/components"
if (Test-Path $battleComponentsPath) {
    $componentFiles = Get-ChildItem -Path $battleComponentsPath -Filter "*.lua"
    foreach ($file in $componentFiles) {
        $source = $file.FullName
        $dest = Join-Path $engineRoot "battlescape/components/$($file.Name)"
        if (Move-FileWithLogging $source $dest) { $moved++ }
    }
}

# ECS Entities
Write-Info "`nMoving battlescape ECS entities..."
$battleEntitiesPath = Join-Path $engineRoot "battle/entities"
if (Test-Path $battleEntitiesPath) {
    $entityFiles = Get-ChildItem -Path $battleEntitiesPath -Filter "*.lua"
    foreach ($file in $entityFiles) {
        $source = $file.FullName
        $dest = Join-Path $engineRoot "battlescape/entities/$($file.Name)"
        if (Move-FileWithLogging $source $dest) { $moved++ }
    }
}

# Map systems
Write-Info "`nMoving battlescape map systems..."
$battlescapeMapMoves = @(
    @{From="engine/battle/grid_map.lua"; To="engine/battlescape/map/grid_map.lua"},
    @{From="engine/battle/map_generator.lua"; To="engine/battlescape/map/map_generator.lua"},
    @{From="engine/battle/map_saver.lua"; To="engine/battlescape/map/map_saver.lua"},
    @{From="engine/battle/map_block.lua"; To="engine/battlescape/map/map_block.lua"},
    @{From="engine/battle/mapblock_system.lua"; To="engine/battlescape/map/mapblock_system.lua"}
)

foreach ($move in $battlescapeMapMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-FileWithLogging $source $dest) { $moved++ }
}

# Effects
Write-Info "`nMoving battlescape effects..."
$battlescapeEffectsMoves = @(
    @{From="engine/battle/animation_system.lua"; To="engine/battlescape/effects/animation_system.lua"},
    @{From="engine/battle/fire_system.lua"; To="engine/battlescape/effects/fire_system.lua"},
    @{From="engine/battle/smoke_system.lua"; To="engine/battlescape/effects/smoke_system.lua"}
)

foreach ($move in $battlescapeEffectsMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-FileWithLogging $source $dest) { $moved++ }
}

# Rendering
Write-Info "`nMoving battlescape rendering..."
$battlescapeRenderMoves = @(
    @{From="engine/battle/renderer.lua"; To="engine/battlescape/rendering/renderer.lua"},
    @{From="engine/battle/camera.lua"; To="engine/battlescape/rendering/camera.lua"}
)

foreach ($move in $battlescapeRenderMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-FileWithLogging $source $dest) { $moved++ }
}

# Combat systems (from systems/)
Write-Info "`nMoving combat systems from systems/..."
$battlescapeCombatMoves = @(
    @{From="engine/systems/weapon_system.lua"; To="engine/battlescape/combat/weapon_system.lua"},
    @{From="engine/systems/equipment_system.lua"; To="engine/battlescape/combat/equipment_system.lua"},
    @{From="engine/systems/action_system.lua"; To="engine/battlescape/combat/action_system.lua"},
    @{From="engine/systems/los_system.lua"; To="engine/battlescape/combat/los_system.lua"},
    @{From="engine/systems/los_optimized.lua"; To="engine/battlescape/combat/los_optimized.lua"},
    @{From="engine/systems/unit.lua"; To="engine/battlescape/combat/unit.lua"},
    @{From="engine/systems/battle_tile.lua"; To="engine/battlescape/combat/battle_tile.lua"}
)

foreach ($move in $battlescapeCombatMoves) {
    $source = Join-Path $projectRoot $move.From
    $dest = Join-Path $projectRoot $move.To
    if (Move-FileWithLogging $source $dest) { $moved++ }
}

# Utilities
Write-Info "`nMoving battlescape utilities..."
$battleUtilsPath = Join-Path $engineRoot "battle/utils"
if (Test-Path $battleUtilsPath) {
    $utilFiles = Get-ChildItem -Path $battleUtilsPath -Filter "*.lua"
    foreach ($file in $utilFiles) {
        $source = $file.FullName
        $dest = Join-Path $engineRoot "battlescape/utils/$($file.Name)"
        if (Move-FileWithLogging $source $dest) { $moved++ }
    }
}

# Tests
Write-Info "`nMoving battlescape tests..."
$battleTestsPath = Join-Path $engineRoot "battle/tests"
if (Test-Path $battleTestsPath) {
    $testFiles = Get-ChildItem -Path $battleTestsPath -Filter "*.lua"
    foreach ($file in $testFiles) {
        $source = $file.FullName
        $dest = Join-Path $engineRoot "battlescape/tests/$($file.Name)"
        if (Move-FileWithLogging $source $dest) { $moved++ }
    }
}

# Copy init.lua if exists
$battleInitPath = Join-Path $engineRoot "battle/init.lua"
if (Test-Path $battleInitPath) {
    $dest = Join-Path $engineRoot "battlescape/init_battle.lua"
    Copy-FileWithLogging $battleInitPath $dest | Out-Null
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
    Write-Info "3. Check console for 'module not found' errors"
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
