$files = @("docs\3D.md", "docs\AI Systems.md", "docs\Analytics.md", "docs\Assets.md", "docs\Basescape.md", "docs\Battlescape.md", "docs\Crafts.md", "docs\Economy.md", "docs\Finance.md", "docs\Geoscape.md", "docs\Gui.md", "docs\integration.md", "docs\Interception.md", "docs\Items.md", "docs\Lore.md", "docs\Politics.md", "docs\Units.md")

Write-Host "=== FINAL VERIFICATION - ALL 17 FILES ===" -ForegroundColor Cyan
Write-Host ""

$allGood = $true
foreach ($file in $files) {
    $content = Get-Content $file -Raw
    $lines = $content -split "`n"
    
    # Find TOC position
    $tocStart = -1
    $tocEnd = -1
    for ($i = 0; $i -lt $lines.Length; $i++) {
        if ($lines[$i] -match "^## Table of Contents") {
            $tocStart = $i
        }
        if ($tocStart -gt -1 -and $i -gt $tocStart -and $lines[$i] -match "^## [^T]") {
            $tocEnd = $i
            break
        }
    }
    
    # Count TOC entries
    $tocCount = 0
    if ($tocStart -gt -1 -and $tocEnd -gt -1) {
        for ($i = $tocStart + 1; $i -lt $tocEnd; $i++) {
            if ($lines[$i] -match "^- \[") {
                $tocCount++
            }
        }
    }
    
    # Count H2 sections (excluding TOC itself)
    $h2Count = 0
    foreach ($line in $lines) {
        if ($line -match "^## " -and $line -notmatch "^## Table of Contents") {
            $h2Count++
        }
    }
    
    $fileName = Split-Path $file -Leaf
    
    if ($h2Count -eq $tocCount) {
        Write-Host "$fileName | H2: $h2Count | TOC: $tocCount | ✅" -ForegroundColor Green
    } else {
        Write-Host "$fileName | H2: $h2Count | TOC: $tocCount | ❌" -ForegroundColor Red
        $allGood = $false
    }
}

Write-Host ""
if ($allGood) {
    Write-Host "🎉 ALL 17 FILES PERFECT! ✅" -ForegroundColor Green
} else {
    Write-Host "⚠️ SOME FILES STILL HAVE ISSUES" -ForegroundColor Red
}
