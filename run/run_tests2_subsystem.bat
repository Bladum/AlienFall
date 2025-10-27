@echo off
REM ─────────────────────────────────────────────────────────────────────────
REM BATCH FILE: Run a specific subsystem test suite
REM ─────────────────────────────────────────────────────────────────────────
REM Usage: run_tests2_subsystem.bat core
REM        run_tests2_subsystem.bat geoscape
REM        run_tests2_subsystem.bat battlescape
REM ─────────────────────────────────────────────────────────────────────────

setlocal enabledelayedexpansion

if "%1"=="" (
    echo.
    echo Usage: run_tests2_subsystem.bat [subsystem]
    echo.
    echo Available subsystems:
    echo   - core         (30 tests)
    echo   - geoscape     (26 tests)
    echo   - battlescape  (20 tests)
    echo   - basescape    (14 tests)
    echo   - economy      (18 tests)
    echo   - politics     (15 tests)
    echo   - lore         (10 tests)
    echo   - ai           (7 tests)
    echo   - utils        (1 test)
    echo.
    pause
    exit /b 1
)

echo.
echo ════════════════════════════════════════════════════════════════════════
echo AlienFall Test Suite 2 - Subsystem: %1
echo ════════════════════════════════════════════════════════════════════════
echo.

REM Check if Love2D is installed
if not exist "C:\Program Files\LOVE\lovec.exe" (
    echo ERROR: Love2D not found at C:\Program Files\LOVE\lovec.exe
    echo Please install Love2D 12.0+ from https://love2d.org
    pause
    exit /b 1
)

REM Run subsystem tests
"C:\Program Files\LOVE\lovec.exe" "tests2/runners" run_subsystem %1

REM Force close Love2D window if still open (timeout: 2 seconds)
timeout /t 2 /nobreak >nul 2>&1
taskkill /IM love.exe /F >nul 2>&1

pause
