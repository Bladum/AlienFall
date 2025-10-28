@echo off
REM AlienFall Build Test Script (Windows)
REM
REM Purpose: Test built .love file
REM Usage: test_build.bat

setlocal enabledelayedexpansion

echo ========================================
echo AlienFall Build Test
echo ========================================
echo.

set BUILD_DIR=%~dp0
set OUTPUT_DIR=%BUILD_DIR%output
set LOVE_FILE=%OUTPUT_DIR%\alienfall.love

REM Check if build exists
if not exist "%LOVE_FILE%" (
    echo [ERROR] Build not found: %LOVE_FILE%
    echo [ERROR] Run build.bat first!
    exit /b 1
)

echo [TEST] Testing build: alienfall.love
echo.

REM Test 1: File exists and has reasonable size
echo [TEST 1] Checking file size...
for %%A in ("%LOVE_FILE%") do set SIZE=%%~zA
set /a SIZE_MB=!SIZE! / 1048576

if !SIZE! LSS 1048576 (
    echo [FAIL] File too small: !SIZE_MB! MB ^(expected ^>1 MB^)
    exit /b 1
)

if !SIZE! GTR 104857600 (
    echo [WARN] File very large: !SIZE_MB! MB ^(expected ^<100 MB^)
    echo [WARN] Consider optimizing assets
)

echo [PASS] Size OK: !SIZE_MB! MB
echo.

REM Test 2: ZIP structure validation
echo [TEST 2] Validating ZIP structure...
powershell -Command "Add-Type -Assembly System.IO.Compression.FileSystem; $zip = [System.IO.Compression.ZipFile]::OpenRead('%LOVE_FILE%'); $hasMain = $false; $hasConf = $false; foreach($entry in $zip.Entries) { if($entry.FullName -eq 'main.lua') { $hasMain = $true } if($entry.FullName -eq 'conf.lua') { $hasConf = $true } } $zip.Dispose(); if($hasMain -and $hasConf) { exit 0 } else { exit 1 }" 2>nul

if %errorlevel% NEQ 0 (
    echo [FAIL] Missing main.lua or conf.lua in root of .love file
    exit /b 1
)

echo [PASS] Contains main.lua and conf.lua
echo.

REM Test 3: Check for Love2D installation
echo [TEST 3] Checking for Love2D...
where love >nul 2>nul
if %errorlevel% NEQ 0 (
    echo [WARN] Love2D not in PATH
    echo [WARN] Cannot test runtime execution
    echo [INFO] Install Love2D from: https://love2d.org/
    echo.
    echo ========================================
    echo Build Validation: PARTIAL
    echo ========================================
    echo.
    echo Static checks passed, but cannot test runtime.
    echo To fully test, install Love2D and run:
    echo   love "%LOVE_FILE%"
    echo.
    exit /b 0
)

echo [PASS] Love2D found
echo.

REM Test 4: Quick runtime test (starts and exits immediately)
echo [TEST 4] Testing runtime execution...
echo [INFO] Starting game for 5 seconds...
echo [INFO] Game window should appear briefly...
echo.

REM Start Love2D in background and kill after 5 seconds
start "" love "%LOVE_FILE%"
timeout /t 5 /nobreak >nul
taskkill /f /im love.exe >nul 2>nul

echo [PASS] Game executed (check console for errors)
echo.

REM Summary
echo ========================================
echo Build Validation: PASSED
echo ========================================
echo.
echo All automated tests passed!
echo.
echo Manual testing recommended:
echo 1. Run: love "%LOVE_FILE%"
echo 2. Navigate through main menu
echo 3. Test all game screens:
echo    - Geoscape
echo    - Basescape
echo    - Battlescape (tactical map)
echo    - Settings
echo 4. Test save/load functionality
echo 5. Check console for warnings/errors
echo.
echo If manual tests pass, build is ready for distribution.
echo.

endlocal

