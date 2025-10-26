@echo off
REM ─────────────────────────────────────────────────────────────────────────
REM BATCH FILE: Run a single test file
REM ─────────────────────────────────────────────────────────────────────────
REM Usage: run_tests2_single.bat core/state_manager_test
REM        run_tests2_single.bat battlescape/tactical_combat_test
REM        run_tests2_single.bat ai/advanced_ai_test
REM ─────────────────────────────────────────────────────────────────────────

setlocal enabledelayedexpansion

if "%1"=="" (
    echo.
    echo Usage: run_tests2_single.bat [path/to/test_name]
    echo.
    echo Examples:
    echo   run_tests2_single.bat core/state_manager_test
    echo   run_tests2_single.bat battlescape/tactical_combat_test
    echo   run_tests2_single.bat ai/advanced_ai_test
    echo.
    echo Test files are located in tests2/{subsystem}/
    echo.
    pause
    exit /b 1
)

echo.
echo ════════════════════════════════════════════════════════════════════════
echo AlienFall Test Suite 2 - Single Test: %1
echo ════════════════════════════════════════════════════════════════════════
echo.

REM Check if Love2D is installed
if not exist "C:\Program Files\LOVE\lovec.exe" (
    echo ERROR: Love2D not found at C:\Program Files\LOVE\lovec.exe
    echo Please install Love2D 12.0+ from https://love2d.org
    pause
    exit /b 1
)

REM Run single test
"C:\Program Files\LOVE\lovec.exe" "tests2" run %1

REM Force close Love2D window if still open (timeout: 2 seconds)
timeout /t 2 /nobreak >nul 2>&1
taskkill /IM love.exe /F >nul 2>&1

pause
