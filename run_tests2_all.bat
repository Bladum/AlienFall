@echo off
REM ─────────────────────────────────────────────────────────────────────────
REM BATCH FILE: Run all 148 tests in tests2 suite
REM ─────────────────────────────────────────────────────────────────────────

setlocal enabledelayedexpansion

echo.
echo ════════════════════════════════════════════════════════════════════════
echo AlienFall Test Suite 2 - Run All Tests
echo ════════════════════════════════════════════════════════════════════════
echo.

REM Check if Love2D is installed
if not exist "C:\Program Files\LOVE\lovec.exe" (
    echo ERROR: Love2D not found at C:\Program Files\LOVE\lovec.exe
    echo Please install Love2D 12.0+ from https://love2d.org
    pause
    exit /b 1
)

REM Run all tests
"C:\Program Files\LOVE\lovec.exe" "tests2/runners" run_all

REM Force close Love2D window if still open (timeout: 2 seconds)
timeout /t 2 /nobreak >nul 2>&1
taskkill /IM love.exe /F >nul 2>&1

pause
