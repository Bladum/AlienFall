# Update require() statements in test files to match new engine structure
# Run AFTER 3_UpdateImportsInEngine.ps1 completes

param(
    [switch]$DryRun = $false,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"
if ($Verbose) { $VerbosePreference = "Continue" }

Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  PHASE 4.4: UPDATE IMPORTS IN TEST FILES                         ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Define replacements - same as engine updates
$replacements = @(
    @('require("utils.', 'require("core.utils.'),
    @("require('utils.", "require('core.utils."),
    @('require("ai.', 'require("systems.ai.'),
    @("require('ai.", "require('systems.ai."),
    @('require("economy.', 'require("systems.economy.'),
    @("require('economy.", "require('systems.economy."),
    @('require("politics.', 'require("systems.politics.'),
    @("require('politics.", "require('systems.politics."),
    @('require("analytics.', 'require("systems.analytics.'),
    @("require('analytics.", "require('systems.analytics."),
    @('require("content.', 'require("systems.content.'),
    @("require('content.", "require('systems.content."),
    @('require("lore.', 'require("systems.lore.'),
    @("require('lore.", "require('systems.lore."),
    @('require("tutorial.', 'require("systems.tutorial.'),
    @("require('tutorial.", "require('systems.tutorial."),
    @('require("geoscape.', 'require("layers.geoscape.'),
    @("require('geoscape.", "require('layers.geoscape."),
    @('require("basescape.', 'require("layers.basescape.'),
    @("require('basescape.", "require('layers.basescape."),
    @('require("battlescape.', 'require("layers.battlescape.'),
    @("require('battlescape.", "require('layers.battlescape."),
    @('require("interception.', 'require("layers.interception.'),
    @("require('interception.", "require('layers.interception."),
    @('require("gui.', 'require("ui.'),
    @("require('gui.", "require('ui."),
    @('require("widgets.', 'require("ui.widgets.'),
    @("require('widgets.", "require('ui.widgets.")
)

# Find all Lua test files
$testFiles = Get-ChildItem -Path "tests" -Filter "*.lua" -Recurse | Where-Object { $_.Name -match "test_.*\.lua$|.*_test\.lua$" }

Write-Host "Found $(($testFiles | Measure-Object).Count) test files to process" -ForegroundColor Cyan
Write-Host ""

$filesModified = 0
$replacementsApplied = 0

foreach ($file in $testFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $fileChanged = $false
    
    foreach ($replacement in $replacements) {
        $oldPattern = $replacement[0]
        $newPattern = $replacement[1]
        
        if ($content -like "*$oldPattern*") {
            $fileChanged = $true
            $count = ($content -split [regex]::Escape($oldPattern)).Count - 1
            $replacementsApplied += $count
            
            if (-not $DryRun) {
                $content = $content -replace [regex]::Escape($oldPattern), $newPattern
            }
        }
    }
    
    if ($fileChanged) {
        $relativePath = Resolve-Path -Path $file.FullName -Relative
        
        if ($DryRun) {
            Write-Host "🔄 [DRY RUN] Would update: $relativePath" -ForegroundColor Yellow
        } else {
            Write-Host "✏️  Updating: $relativePath" -ForegroundColor Cyan
            Set-Content -Path $file.FullName -Value $content -Force
            $filesModified++
        }
    }
}

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  TEST IMPORT UPDATE COMPLETE                                     ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "📋 Dry run completed." -ForegroundColor Yellow
    Write-Host "   Would have updated: $filesModified files" -ForegroundColor Yellow
    Write-Host "   Would have applied: $replacementsApplied replacements" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Run without -DryRun to perform actual updates." -ForegroundColor Yellow
} else {
    Write-Host "✅ Modified $filesModified test files" -ForegroundColor Green
    Write-Host "✅ Applied $replacementsApplied replacements" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "Next step: Reorganize test mock data structure" -ForegroundColor Cyan
    Write-Host "  Run: .\migrate\5_ReorganizeTestMock.ps1" -ForegroundColor White
}
