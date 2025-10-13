# ============================================================================
# Fix Require Paths After Engine Restructure
# ============================================================================
#
# This script automatically updates require() statements in Lua files
# to match the new engine folder structure.
#
# Run this AFTER running migrate_engine_structure.ps1
#
# Usage:
#   .\fix_require_paths.ps1
#
# Options:
#   -DryRun : Show what would be changed without modifying files
#
# ============================================================================

param(
    [switch]$DryRun = $false
)

$ErrorActionPreference = "Stop"
$projectRoot = "c:\Users\tombl\Documents\Projects"
$engineRoot = Join-Path $projectRoot "engine"

# Colors for output
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }

Write-Info "`n============================================"
Write-Info "Fix Require Paths Script"
Write-Info "============================================`n"

if ($DryRun) {
    Write-Warning "DRY RUN MODE - No changes will be made`n"
}

# Define all require path mappings
$requireMappings = @(
    # Core systems
    @{Pattern='require\s*\(\s*["\']systems\.state_manager["\']\s*\)'; Replacement='require("core.state_manager")'},
    @{Pattern='require\s*\(\s*["\']systems\.assets["\']\s*\)'; Replacement='require("core.assets")'},
    @{Pattern='require\s*\(\s*["\']systems\.data_loader["\']\s*\)'; Replacement='require("core.data_loader")'},
    @{Pattern='require\s*\(\s*["\']systems\.mod_manager["\']\s*\)'; Replacement='require("core.mod_manager")'},
    
    # Shared systems
    @{Pattern='require\s*\(\s*["\']systems\.pathfinding["\']\s*\)'; Replacement='require("shared.pathfinding")'},
    @{Pattern='require\s*\(\s*["\']systems\.spatial_hash["\']\s*\)'; Replacement='require("shared.spatial_hash")'},
    @{Pattern='require\s*\(\s*["\']systems\.team["\']\s*\)'; Replacement='require("shared.team")'},
    @{Pattern='require\s*\(\s*["\']systems\.ui["\']\s*\)'; Replacement='require("shared.ui")'},
    
    # Battlescape - main module
    @{Pattern='require\s*\(\s*["\']modules\.battlescape["\']\s*\)'; Replacement='require("battlescape.init")'},
    @{Pattern='require\s*\(\s*["\']modules\.battlescape\.init["\']\s*\)'; Replacement='require("battlescape.init")'},
    
    # Battlescape - UI layer
    @{Pattern='require\s*\(\s*["\']modules\.battlescape\.input["\']\s*\)'; Replacement='require("battlescape.ui.input")'},
    @{Pattern='require\s*\(\s*["\']modules\.battlescape\.render["\']\s*\)'; Replacement='require("battlescape.ui.render")'},
    @{Pattern='require\s*\(\s*["\']modules\.battlescape\.ui["\']\s*\)'; Replacement='require("battlescape.ui.ui")'},
    @{Pattern='require\s*\(\s*["\']modules\.battlescape\.logic["\']\s*\)'; Replacement='require("battlescape.ui.logic")'},
    
    # Battlescape - logic layer
    @{Pattern='require\s*\(\s*["\']battle\.battlefield["\']\s*\)'; Replacement='require("battlescape.logic.battlefield")'},
    @{Pattern='require\s*\(\s*["\']battle\.turn_manager["\']\s*\)'; Replacement='require("battlescape.logic.turn_manager")'},
    @{Pattern='require\s*\(\s*["\']battle\.unit_selection["\']\s*\)'; Replacement='require("battlescape.logic.unit_selection")'},
    @{Pattern='require\s*\(\s*["\']battle\.battlescape_integration["\']\s*\)'; Replacement='require("battlescape.logic.integration")'},
    
    # Battlescape - ECS systems
    @{Pattern='require\s*\(\s*["\']battle\.systems\.movement_system["\']\s*\)'; Replacement='require("battlescape.systems.movement_system")'},
    @{Pattern='require\s*\(\s*["\']battle\.systems\.shooting_system["\']\s*\)'; Replacement='require("battlescape.systems.shooting_system")'},
    @{Pattern='require\s*\(\s*["\']battle\.systems\.accuracy_system["\']\s*\)'; Replacement='require("battlescape.systems.accuracy_system")'},
    @{Pattern='require\s*\(\s*["\']battle\.systems\.range_system["\']\s*\)'; Replacement='require("battlescape.systems.range_system")'},
    @{Pattern='require\s*\(\s*["\']battle\.systems\.vision_system["\']\s*\)'; Replacement='require("battlescape.systems.vision_system")'},
    @{Pattern='require\s*\(\s*["\']battle\.systems\.hex_system["\']\s*\)'; Replacement='require("battlescape.systems.hex_system")'},
    @{Pattern='require\s*\(\s*["\']battle\.systems\.move_mode_system["\']\s*\)'; Replacement='require("battlescape.systems.move_mode_system")'},
    
    # Battlescape - ECS components
    @{Pattern='require\s*\(\s*["\']battle\.components\.health["\']\s*\)'; Replacement='require("battlescape.components.health")'},
    @{Pattern='require\s*\(\s*["\']battle\.components\.movement["\']\s*\)'; Replacement='require("battlescape.components.movement")'},
    @{Pattern='require\s*\(\s*["\']battle\.components\.team["\']\s*\)'; Replacement='require("battlescape.components.team")'},
    @{Pattern='require\s*\(\s*["\']battle\.components\.transform["\']\s*\)'; Replacement='require("battlescape.components.transform")'},
    @{Pattern='require\s*\(\s*["\']battle\.components\.vision["\']\s*\)'; Replacement='require("battlescape.components.vision")'},
    
    # Battlescape - entities
    @{Pattern='require\s*\(\s*["\']battle\.entities\.unit_entity["\']\s*\)'; Replacement='require("battlescape.entities.unit_entity")'},
    
    # Battlescape - map systems
    @{Pattern='require\s*\(\s*["\']battle\.grid_map["\']\s*\)'; Replacement='require("battlescape.map.grid_map")'},
    @{Pattern='require\s*\(\s*["\']battle\.map_generator["\']\s*\)'; Replacement='require("battlescape.map.map_generator")'},
    @{Pattern='require\s*\(\s*["\']battle\.map_saver["\']\s*\)'; Replacement='require("battlescape.map.map_saver")'},
    @{Pattern='require\s*\(\s*["\']battle\.map_block["\']\s*\)'; Replacement='require("battlescape.map.map_block")'},
    @{Pattern='require\s*\(\s*["\']battle\.mapblock_system["\']\s*\)'; Replacement='require("battlescape.map.mapblock_system")'},
    
    # Battlescape - effects
    @{Pattern='require\s*\(\s*["\']battle\.animation_system["\']\s*\)'; Replacement='require("battlescape.effects.animation_system")'},
    @{Pattern='require\s*\(\s*["\']battle\.fire_system["\']\s*\)'; Replacement='require("battlescape.effects.fire_system")'},
    @{Pattern='require\s*\(\s*["\']battle\.smoke_system["\']\s*\)'; Replacement='require("battlescape.effects.smoke_system")'},
    
    # Battlescape - rendering
    @{Pattern='require\s*\(\s*["\']battle\.renderer["\']\s*\)'; Replacement='require("battlescape.rendering.renderer")'},
    @{Pattern='require\s*\(\s*["\']battle\.camera["\']\s*\)'; Replacement='require("battlescape.rendering.camera")'},
    
    # Battlescape - combat systems
    @{Pattern='require\s*\(\s*["\']systems\.weapon_system["\']\s*\)'; Replacement='require("battlescape.combat.weapon_system")'},
    @{Pattern='require\s*\(\s*["\']systems\.equipment_system["\']\s*\)'; Replacement='require("battlescape.combat.equipment_system")'},
    @{Pattern='require\s*\(\s*["\']systems\.action_system["\']\s*\)'; Replacement='require("battlescape.combat.action_system")'},
    @{Pattern='require\s*\(\s*["\']systems\.los_system["\']\s*\)'; Replacement='require("battlescape.combat.los_system")'},
    @{Pattern='require\s*\(\s*["\']systems\.los_optimized["\']\s*\)'; Replacement='require("battlescape.combat.los_optimized")'},
    @{Pattern='require\s*\(\s*["\']systems\.unit["\']\s*\)'; Replacement='require("battlescape.combat.unit")'},
    @{Pattern='require\s*\(\s*["\']systems\.battle_tile["\']\s*\)'; Replacement='require("battlescape.combat.battle_tile")'},
    
    # Battlescape - utilities
    @{Pattern='require\s*\(\s*["\']battle\.utils\.debug["\']\s*\)'; Replacement='require("battlescape.utils.debug")'},
    @{Pattern='require\s*\(\s*["\']battle\.utils\.hex_math["\']\s*\)'; Replacement='require("battlescape.utils.hex_math")'},
    
    # Geoscape
    @{Pattern='require\s*\(\s*["\']modules\.geoscape["\']\s*\)'; Replacement='require("geoscape.init")'},
    @{Pattern='require\s*\(\s*["\']modules\.geoscape\.init["\']\s*\)'; Replacement='require("geoscape.init")'},
    @{Pattern='require\s*\(\s*["\']modules\.geoscape\.input["\']\s*\)'; Replacement='require("geoscape.ui.input")'},
    @{Pattern='require\s*\(\s*["\']modules\.geoscape\.render["\']\s*\)'; Replacement='require("geoscape.ui.render")'},
    @{Pattern='require\s*\(\s*["\']modules\.geoscape\.data["\']\s*\)'; Replacement='require("geoscape.logic.data")'},
    @{Pattern='require\s*\(\s*["\']modules\.geoscape\.logic["\']\s*\)'; Replacement='require("geoscape.logic.world_state")'},
    
    # Basescape
    @{Pattern='require\s*\(\s*["\']modules\.basescape["\']\s*\)'; Replacement='require("basescape.init")'},
    
    # Menu
    @{Pattern='require\s*\(\s*["\']modules\.menu["\']\s*\)'; Replacement='require("menu.main_menu")'},
    @{Pattern='require\s*\(\s*["\']modules\.tests_menu["\']\s*\)'; Replacement='require("menu.tests_menu")'},
    @{Pattern='require\s*\(\s*["\']modules\.widget_showcase["\']\s*\)'; Replacement='require("menu.widget_showcase")'},
    
    # Tools
    @{Pattern='require\s*\(\s*["\']modules\.map_editor["\']\s*\)'; Replacement='require("tools.map_editor.init")'},
    @{Pattern='require\s*\(\s*["\']systems\.mapblock_validator["\']\s*\)'; Replacement='require("tools.validators.mapblock_validator")'}
)

# Get all Lua files recursively
$luaFiles = Get-ChildItem -Path $engineRoot -Filter "*.lua" -Recurse

$totalChanges = 0
$filesModified = 0

Write-Info "Scanning $($luaFiles.Count) Lua files...`n"

foreach ($file in $luaFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $originalContent = $content
    $fileChanges = 0
    
    foreach ($mapping in $requireMappings) {
        $matches = [regex]::Matches($content, $mapping.Pattern)
        if ($matches.Count -gt 0) {
            $content = $content -replace $mapping.Pattern, $mapping.Replacement
            $fileChanges += $matches.Count
        }
    }
    
    if ($fileChanges -gt 0) {
        $relativePath = $file.FullName.Substring($engineRoot.Length + 1)
        Write-Info "$relativePath - $fileChanges change(s)"
        
        if (-not $DryRun) {
            Set-Content -Path $file.FullName -Value $content -NoNewline -Encoding UTF8
        }
        
        $totalChanges += $fileChanges
        $filesModified++
    }
}

Write-Info "`n============================================"
if ($DryRun) {
    Write-Warning "DRY RUN COMPLETE"
    Write-Info "Would modify $filesModified files with $totalChanges total changes"
} else {
    Write-Success "✓ Complete!"
    Write-Info "Modified $filesModified files with $totalChanges total changes"
}
Write-Info "============================================`n"

# Check main.lua specifically
$mainLuaPath = Join-Path $engineRoot "main.lua"
if (Test-Path $mainLuaPath) {
    Write-Info "Checking main.lua for require statements..."
    $mainContent = Get-Content -Path $mainLuaPath
    $requireLines = $mainContent | Select-String -Pattern 'require\s*\('
    
    if ($requireLines.Count -gt 0) {
        Write-Info "`nFound $($requireLines.Count) require statements in main.lua:"
        foreach ($line in $requireLines) {
            Write-Info "  Line $($line.LineNumber): $($line.Line.Trim())"
        }
    }
}

Write-Info "`nNext steps:"
Write-Info "1. Run the game: lovec engine"
Write-Info "2. Check console for 'module not found' errors"
Write-Info "3. Manually fix any remaining require issues"
Write-Info "4. Run tests to verify everything works`n"
