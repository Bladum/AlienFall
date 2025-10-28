@echo off
REM Simple AlienFall Build Script
echo ========================================
echo AlienFall Build System
echo ========================================
echo.

REM Read version
set /p VERSION=<version.txt
echo Version: %VERSION%
echo.

REM Setup paths
set BUILD_DIR=%~dp0
set PROJECT_ROOT=%BUILD_DIR%..
set ENGINE_DIR=%PROJECT_ROOT%\engine
set MODS_DIR=%PROJECT_ROOT%\mods
set OUTPUT_DIR=%BUILD_DIR%output
set TEMP_DIR=%BUILD_DIR%temp

REM Create directories
echo Creating directories...
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
if not exist "%TEMP_DIR%\package" mkdir "%TEMP_DIR%\package"
echo.

REM Validate
echo Validating engine...
if not exist "%ENGINE_DIR%\main.lua" (
    echo ERROR: main.lua not found!
    pause
    exit /b 1
)
if not exist "%ENGINE_DIR%\conf.lua" (
    echo ERROR: conf.lua not found!
    pause
    exit /b 1
)
echo Engine structure OK.
echo.

REM Copy engine files
echo Copying engine files...
xcopy /E /I /Y /Q "%ENGINE_DIR%\*" "%TEMP_DIR%\package\" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy engine files!
    pause
    exit /b 1
)
echo.

REM Remove test files
echo Cleaning up test files...
if exist "%TEMP_DIR%\package\.luarc.json" del /q "%TEMP_DIR%\package\.luarc.json"
if exist "%TEMP_DIR%\package\test_scan.lua" del /q "%TEMP_DIR%\package\test_scan.lua"
if exist "%TEMP_DIR%\package\simple_test.lua" del /q "%TEMP_DIR%\package\simple_test.lua"
echo.

REM Copy mods
echo Copying mods directory...
xcopy /E /I /Y /Q "%MODS_DIR%\*" "%TEMP_DIR%\package\mods\" >nul
if errorlevel 1 (
    echo ERROR: Failed to copy mods!
    pause
    exit /b 1
)
echo.

REM Create .love file (ZIP)
echo Creating .love file...
cd /d "%TEMP_DIR%\package"
powershell -Command "Compress-Archive -Path * -DestinationPath '%OUTPUT_DIR%\alienfall.love' -Force"
cd /d "%BUILD_DIR%"

if not exist "%OUTPUT_DIR%\alienfall.love" (
    echo ERROR: Failed to create .love file!
    pause
    exit /b 1
)
echo.

REM Show result
echo ========================================
echo Build Complete!
echo ========================================
echo.
echo Output: %OUTPUT_DIR%\alienfall.love
echo.
dir "%OUTPUT_DIR%\alienfall.love"
echo.
echo To test: love output\alienfall.love
echo.
pause

