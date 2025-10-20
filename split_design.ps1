# Script to split design.md into individual files

$designFile = "c:\Users\tombl\Documents\Projects\docs\design.md"
$docsFolder = "c:\Users\tombl\Documents\Projects\docs"

# Map section names to file names
$sections = @(
    @{ Name = "Quick Overview (TL;DR)"; File = "overview.md"; StartLine = 45 },
    @{ Name = "Core Foundation"; File = "foundation.md"; StartLine = 166 },
    @{ Name = "AI Systems"; File = "ai.md"; StartLine = 237 },
    @{ Name = "Assets & Modding System"; File = "assets.md"; StartLine = 287 },
    @{ Name = "Analytics System"; File = "analytics.md"; StartLine = 385 },
    @{ Name = "Basescape (Base Management)"; File = "basescape.md"; StartLine = 443 },
    @{ Name = "Battlescape (Tactical Combat)"; File = "battlescape.md"; StartLine = 709 },
    @{ Name = "Interception (Air Combat)"; File = "interception.md"; StartLine = 1524 },
    @{ Name = "Shared Content"; File = "shared.md"; StartLine = 1692 },
    @{ Name = "Politics & Diplomacy"; File = "politics.md"; StartLine = 1896 },
    @{ Name = "Finance"; File = "finance.md"; StartLine = 2280 },
    @{ Name = "Lore"; File = "lore.md"; StartLine = 2477 },
    @{ Name = "Geoscape: Strategic Layer"; File = "geoscape.md"; StartLine = 2698 },
    @{ Name = "User Interface"; File = "interface.md"; StartLine = 2884 },
    @{ Name = "Multiplayer"; File = "multiplayer.md"; StartLine = 3057 },
    @{ Name = "Localization & Internationalization"; File = "localization.md"; StartLine = 3349 },
    @{ Name = "3D Battlescape: Optional First-Person Alternative"; File = "threedee.md"; StartLine = 3514 },
    @{ Name = "Cross-System Integration"; File = "integration.md"; StartLine = 4129 }
)

# Read all lines
$allLines = Get-Content $designFile

# Extract and save each section
for ($i = 0; $i -lt $sections.Count; $i++) {
    $currentSection = $sections[$i]
    $nextSection = if ($i -lt $sections.Count - 1) { $sections[$i + 1] } else { $null }
    
    # Calculate line range
    $startIdx = $currentSection.StartLine - 1  # Convert to 0-based index
    $endIdx = if ($nextSection) { $nextSection.StartLine - 2 } else { $allLines.Count - 1 }
    
    # Extract section (keeping the ## header and content)
    $sectionContent = $allLines[$startIdx..$endIdx] -join "`n"
    
    # Convert ## to # (since each file is now top-level)
    $sectionContent = $sectionContent -replace "^## ", "# " -replace "`n## ", "`n# "
    
    # Save to file
    $outputPath = Join-Path $docsFolder $currentSection.File
    Set-Content -Path $outputPath -Value $sectionContent -Encoding UTF8
    
    Write-Host "Created: $($currentSection.File)"
}

Write-Host "Done! All sections split successfully."
