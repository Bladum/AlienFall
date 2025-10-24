# Master script to run entire migration process
# Executes all phases in sequence with option to continue or stop

param(
    [switch]$DryRun = $false,
    [switch]$AutoContinue = $false,
    [switch]$Verbose = $false
)

$ErrorActionPreference = "Stop"
if ($Verbose) { $VerbosePreference = "Continue" }

Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                                    ║" -ForegroundColor Cyan
Write-Host "║      🚀 ENGINE RESTRUCTURING - MASTER MIGRATION SCRIPT 🚀         ║" -ForegroundColor Cyan
Write-Host "║                                                                    ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host ""
Write-Host "This script will execute all 7 migration phases:" -ForegroundColor White
Write-Host "  1️⃣  Prepare & Validate" -ForegroundColor White
Write-Host "  2️⃣  Copy Files to New Structure" -ForegroundColor White
Write-Host "  3️⃣  Update Imports in Engine" -ForegroundColor White
Write-Host "  4️⃣  Update Imports in Tests" -ForegroundColor White
Write-Host "  5️⃣  Reorganize Test Mock Data" -ForegroundColor White
Write-Host "  6️⃣  Delete Old Directories" -ForegroundColor White
Write-Host "  7️⃣  Validate New Structure" -ForegroundColor White

if ($DryRun) {
    Write-Host ""
    Write-Host "⚠️  DRY RUN MODE - No changes will be made" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Gray

# Function to run phase
function RunPhase {
    param(
        [int]$PhaseNumber,
        [string]$ScriptName,
        [string]$PhaseDescription
    )
    
    Write-Host ""
    Write-Host "[PHASE $PhaseNumber]: $PhaseDescription" -ForegroundColor Cyan
    Write-Host "Running: $ScriptName" -ForegroundColor Gray
    Write-Host ""
    
    $scriptPath = ".\migrate\$ScriptName"
    
    if ($DryRun) {
        & $scriptPath -DryRun -Verbose:$Verbose
    } else {
        & $scriptPath -Verbose:$Verbose
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "❌ Phase $PhaseNumber failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        $continue = Read-Host "Continue to next phase anyway? (yes/no)"
        if ($continue -ne "yes") {
            Write-Host "❌ Migration stopped." -ForegroundColor Red
            exit 1
        }
    }
    
    if (-not $AutoContinue) {
        Write-Host ""
        $continue = Read-Host "Continue to next phase? (yes/no)"
        if ($continue -ne "yes") {
            Write-Host "⏸️  Migration paused." -ForegroundColor Yellow
            exit 0
        }
    }
}

# Run all phases
try {
    RunPhase 1 "1_PrepareMigration.ps1" "Prepare & Validate"
    RunPhase 2 "2_CopyFilesToNewStructure.ps1" "Copy Files"
    RunPhase 3 "3_UpdateImportsInEngine.ps1" "Update Engine Imports"
    RunPhase 4 "4_UpdateImportsInTests.ps1" "Update Test Imports"
    RunPhase 5 "5_ReorganizeTestMock.ps1" "Reorganize Mock Data"
    RunPhase 6 "6_DeleteOldDirectories.ps1" "Delete Old Directories"
    RunPhase 7 "7_ValidateStructure.ps1" "Validate Structure"
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                                                                    ║" -ForegroundColor Green
    Write-Host "║               ✅ ALL MIGRATION PHASES COMPLETE! ✅                 ║" -ForegroundColor Green
    Write-Host "║                                                                    ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "🎉 ENGINE RESTRUCTURING MIGRATION SUCCESSFUL!" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Test game runs: lovec engine" -ForegroundColor White
    Write-Host "  2. Run test suite: lovec tests/runners" -ForegroundColor White
    Write-Host "  3. Update documentation:" -ForegroundColor White
    Write-Host "     - api/ files (1-2 hours)" -ForegroundColor White
    Write-Host "     - architecture/ files (1-2 hours)" -ForegroundColor White
    Write-Host "     - docs/ files (1 hour)" -ForegroundColor White
    Write-Host "  4. Commit changes: git commit -m 'Restructure: Reorganize engine...'" -ForegroundColor White
    
} catch {
    Write-Host ""
    Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Stack trace:" -ForegroundColor Gray
    Write-Host $_.ScriptStackTrace -ForegroundColor Gray
    exit 1
}
