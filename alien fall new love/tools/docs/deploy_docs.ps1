# PowerShell script to deploy MkDocs documentation to GitHub Pages

Write-Host "================================" -ForegroundColor Cyan
Write-Host "Deploying Alien Fall Wiki" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if mkdocs is installed
$mkdocsCheck = Get-Command mkdocs -ErrorAction SilentlyContinue
if (-not $mkdocsCheck) {
    Write-Host "Error: mkdocs not installed" -ForegroundColor Red
    Write-Host "Install with: pip install mkdocs-material" -ForegroundColor Yellow
    exit 1
}

# Check if we're in the right directory
if (-not (Test-Path "mkdocs.yml")) {
    Write-Host "Error: mkdocs.yml not found" -ForegroundColor Red
    Write-Host "Run this script from the project root" -ForegroundColor Yellow
    exit 1
}

# Build the documentation
Write-Host "Building documentation..." -ForegroundColor Yellow
mkdocs build --clean

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Build failed" -ForegroundColor Red
    exit 1
}

# Deploy to GitHub Pages
Write-Host ""
Write-Host "Deploying to GitHub Pages..." -ForegroundColor Yellow
mkdocs gh-deploy --force

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Deployment failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "================================" -ForegroundColor Green
Write-Host "✓ Deployment complete!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""
Write-Host "Documentation available at:" -ForegroundColor Cyan
Write-Host "https://alienfall.github.io/alienfall" -ForegroundColor White
