# Graphics Spritesheet Generator
# Uruchamia Love2D do wygenerowania arkuszy A4 z grafikami

Write-Host ""
Write-Host "========== GRAPHICS SPRITESHEET GENERATOR ==========" -ForegroundColor Cyan
Write-Host ""
Write-Host "Generowanie arkuszy A4 do drukowania..." -ForegroundColor Yellow
Write-Host "Każda grafika będzie wklejona 150 razy (10x15)." -ForegroundColor Yellow
Write-Host ""
Write-Host "Patrz konsolę Love2D dla szczegółów..." -ForegroundColor Gray
Write-Host ""

$projectRoot = $PSScriptRoot
Set-Location $projectRoot

$loveExecutable = "C:\Program Files\LOVE\lovec.exe"

if (-not (Test-Path $loveExecutable)) {
    Write-Host "BŁĄD: Love2D nie znalezione w: $loveExecutable" -ForegroundColor Red
    exit 1
}

# Uruchom generator
& $loveExecutable "spritesheet_generator"

Write-Host ""
Write-Host "========== GOTOWE ==========" -ForegroundColor Green
Write-Host "Arkusze znajdują się w: spritesheet_generator\output_spritesheets\" -ForegroundColor Green
Write-Host ""
