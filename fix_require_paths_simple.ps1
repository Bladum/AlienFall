param(
    [switch]$DryRun = $false
)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Fix Require Paths Script" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "DRY RUN MODE - No changes will be made`n" -ForegroundColor Yellow
}

$projectRoot = "c:\Users\tombl\Documents\Projects"
$engineRoot = Join-Path $projectRoot "engine"

# Get all Lua files in the engine directory
$luaFiles = Get-ChildItem -Path $engineRoot -Filter "*.lua" -Recurse

Write-Host "Found $($luaFiles.Count) Lua files to process`n" -ForegroundColor Cyan

$replacements = @(
    @{Pattern='require\s*\(\s*["'']systems\.state_manager["'']\s*\)'; Replacement='require("core.state_manager")'},
    @{Pattern='require\s*\(\s*["'']systems\.assets["'']\s*\)'; Replacement='require("core.assets")'},
    @{Pattern='require\s*\(\s*["'']systems\.data_loader["'']\s*\)'; Replacement='require("core.data_loader")'},
    @{Pattern='require\s*\(\s*["'']systems\.mod_manager["'']\s*\)'; Replacement='require("core.mod_manager")'},
    @{Pattern='require\s*\(\s*["'']systems\.pathfinding["'']\s*\)'; Replacement='require("shared.pathfinding")'},
    @{Pattern='require\s*\(\s*["'']systems\.spatial_hash["'']\s*\)'; Replacement='require("shared.spatial_hash")'},
    @{Pattern='require\s*\(\s*["'']systems\.team["'']\s*\)'; Replacement='require("shared.team")'},
    @{Pattern='require\s*\(\s*["'']systems\.ui["'']\s*\)'; Replacement='require("shared.ui")'},
    @{Pattern='require\s*\(\s*["'']systems\.weapon_system["'']\s*\)'; Replacement='require("battlescape.combat.weapon_system")'},
    @{Pattern='require\s*\(\s*["'']systems\.equipment_system["'']\s*\)'; Replacement='require("battlescape.combat.equipment_system")'},
    @{Pattern='require\s*\(\s*["'']systems\.action_system["'']\s*\)'; Replacement='require("battlescape.combat.action_system")'},
    @{Pattern='require\s*\(\s*["'']systems\.los_system["'']\s*\)'; Replacement='require("battlescape.combat.los_system")'},
    @{Pattern='require\s*\(\s*["'']systems\.los_optimized["'']\s*\)'; Replacement='require("battlescape.combat.los_optimized")'},
    @{Pattern='require\s*\(\s*["'']systems\.unit["'']\s*\)'; Replacement='require("battlescape.combat.unit")'},
    @{Pattern='require\s*\(\s*["'']systems\.battle_tile["'']\s*\)'; Replacement='require("battlescape.combat.battle_tile")'},
    @{Pattern='require\s*\(\s*["'']battle\.battlefield["'']\s*\)'; Replacement='require("battlescape.logic.battlefield")'},
    @{Pattern='require\s*\(\s*["'']battle\.turn_manager["'']\s*\)'; Replacement='require("battlescape.logic.turn_manager")'},
    @{Pattern='require\s*\(\s*["'']battle\.unit_selection["'']\s*\)'; Replacement='require("battlescape.logic.unit_selection")'},
    @{Pattern='require\s*\(\s*["'']battle\.battlescape_integration["'']\s*\)'; Replacement='require("battlescape.logic.integration")'},
    @{Pattern='require\s*\(\s*["'']battle\.grid_map["'']\s*\)'; Replacement='require("battlescape.map.grid_map")'},
    @{Pattern='require\s*\(\s*["'']battle\.map_generator["'']\s*\)'; Replacement='require("battlescape.map.map_generator")'},
    @{Pattern='require\s*\(\s*["'']battle\.map_saver["'']\s*\)'; Replacement='require("battlescape.map.map_saver")'},
    @{Pattern='require\s*\(\s*["'']battle\.map_block["'']\s*\)'; Replacement='require("battlescape.map.map_block")'},
    @{Pattern='require\s*\(\s*["'']battle\.mapblock_system["'']\s*\)'; Replacement='require("battlescape.map.mapblock_system")'},
    @{Pattern='require\s*\(\s*["'']battle\.animation_system["'']\s*\)'; Replacement='require("battlescape.effects.animation_system")'},
    @{Pattern='require\s*\(\s*["'']battle\.fire_system["'']\s*\)'; Replacement='require("battlescape.effects.fire_system")'},
    @{Pattern='require\s*\(\s*["'']battle\.smoke_system["'']\s*\)'; Replacement='require("battlescape.effects.smoke_system")'},
    @{Pattern='require\s*\(\s*["'']battle\.renderer["'']\s*\)'; Replacement='require("battlescape.rendering.renderer")'},
    @{Pattern='require\s*\(\s*["'']battle\.camera["'']\s*\)'; Replacement='require("battlescape.rendering.camera")'},
    @{Pattern='require\s*\(\s*["'']modules\.battlescape["'']\s*\)'; Replacement='require("battlescape.init")'},
    @{Pattern='require\s*\(\s*["'']modules\.battlescape\.input["'']\s*\)'; Replacement='require("battlescape.ui.input")'},
    @{Pattern='require\s*\(\s*["'']modules\.battlescape\.render["'']\s*\)'; Replacement='require("battlescape.ui.render")'},
    @{Pattern='require\s*\(\s*["'']modules\.battlescape\.ui["'']\s*\)'; Replacement='require("battlescape.ui.ui")'},
    @{Pattern='require\s*\(\s*["'']modules\.battlescape\.logic["'']\s*\)'; Replacement='require("battlescape.ui.logic")'},
    @{Pattern='require\s*\(\s*["'']modules\.menu["'']\s*\)'; Replacement='require("menu.main_menu")'},
    @{Pattern='require\s*\(\s*["'']modules\.tests_menu["'']\s*\)'; Replacement='require("menu.tests_menu")'},
    @{Pattern='require\s*\(\s*["'']modules\.widget_showcase["'']\s*\)'; Replacement='require("menu.widget_showcase")'},
    @{Pattern='require\s*\(\s*["'']modules\.basescape["'']\s*\)'; Replacement='require("basescape.init")'},
    @{Pattern='require\s*\(\s*["'']modules\.map_editor["'']\s*\)'; Replacement='require("tools.map_editor.init")'}
)

$filesChanged = 0
$replacementsMade = 0

foreach ($file in $luaFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $originalContent = $content
    $fileChanged = $false

    foreach ($replacement in $replacements) {
        $pattern = $replacement.Pattern
        $newValue = $replacement.Replacement

        if ($content -match $pattern) {
            $content = $content -replace $pattern, $newValue
            $replacementsMade++
            $fileChanged = $true
            Write-Host "  Updated: $($file.Name) - $pattern -> $newValue" -ForegroundColor Green
        }
    }

    if ($fileChanged) {
        if (-not $DryRun) {
            Set-Content -Path $file.FullName -Value $content -NoNewline
        }
        $filesChanged++
    }
}

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "Summary" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "DRY RUN COMPLETE - No changes were made" -ForegroundColor Yellow
    Write-Host "Would have updated $filesChanged files with $replacementsMade replacements`n" -ForegroundColor Cyan
} else {
    Write-Host "Updated $filesChanged files with $replacementsMade replacements`n" -ForegroundColor Green
}

Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "1. Run the game with Love2D console: lovec engine" -ForegroundColor White
Write-Host "2. Check console for any remaining 'module not found' errors" -ForegroundColor White
Write-Host "3. Test all game modes (battlescape, menu, etc.)" -ForegroundColor White
Write-Host "4. Run tests: love scripts/run_test.lua" -ForegroundColor White
Write-Host "5. Commit changes to git`n" -ForegroundColor White

Write-Host "============================================`n" -ForegroundColor Green