@echo off
REM AlienFall Love2D Build Script (Windows)
REM
REM Purpose: Package AlienFall for distribution
REM Output: .love file and platform-specific builds
REM Usage: build.bat [clean|all]

echo ========================================
echo AlienFall Build System
echo ========================================
echo.

REM Read version from version.txt
set /p VERSION=<version.txt
echo [BUILD] Version: %VERSION%
echo.

REM Determine build mode
set BUILD_MODE=%1
if "%BUILD_MODE%"=="" set BUILD_MODE=all

echo [BUILD] Mode: %BUILD_MODE%
echo.

REM Setup paths
set PROJECT_ROOT=%~dp0..
set ENGINE_DIR=%PROJECT_ROOT%\engine
set MODS_DIR=%PROJECT_ROOT%\mods
set BUILD_DIR=%~dp0
set OUTPUT_DIR=%BUILD_DIR%output
set TEMP_DIR=%BUILD_DIR%temp

REM Clean old builds if requested
if "%BUILD_MODE%"=="clean" (
    echo [CLEAN] Removing old build artifacts...
    if exist "%OUTPUT_DIR%" rmdir /s /q "%OUTPUT_DIR%"
    if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"
    echo [CLEAN] Done.
    echo.
)

REM Create output directories
echo [SETUP] Creating output directories...
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"
if not exist "%TEMP_DIR%\package" mkdir "%TEMP_DIR%\package"
echo [SETUP] Done.
echo.

REM Validate engine structure
echo [VALIDATE] Checking engine structure...
if not exist "%ENGINE_DIR%\main.lua" (
    echo [ERROR] main.lua not found in engine directory!
    exit /b 1
)
if not exist "%ENGINE_DIR%\conf.lua" (
    echo [ERROR] conf.lua not found in engine directory!
    exit /b 1
)
if not exist "%MODS_DIR%\core\mod.toml" (
    echo [ERROR] Core mod not found in mods directory!
    exit /b 1
)
echo [VALIDATE] Engine structure OK.
echo.

REM Copy engine files to temp package directory
echo [PACKAGE] Copying engine files...
xcopy /E /I /Y /Q "%ENGINE_DIR%\*" "%TEMP_DIR%\package\" >nul

REM Remove excluded files/folders from package
echo [PACKAGE] Removing excluded files...
if exist "%TEMP_DIR%\package\.luarc.json" del /q "%TEMP_DIR%\package\.luarc.json"
if exist "%TEMP_DIR%\package\test_scan.lua" del /q "%TEMP_DIR%\package\test_scan.lua"
if exist "%TEMP_DIR%\package\simple_test.lua" del /q "%TEMP_DIR%\package\simple_test.lua"

REM Copy mods directory to package
echo [PACKAGE] Copying mods directory...
if not exist "%TEMP_DIR%\package\mods" mkdir "%TEMP_DIR%\package\mods"
xcopy /E /I /Y /Q "%MODS_DIR%\*" "%TEMP_DIR%\package\mods\" >nul
echo [PACKAGE] Files prepared.
echo.

REM Create .love file (ZIP archive)
echo [BUILD] Creating .love file...
cd /d "%TEMP_DIR%\package"

REM Check if PowerShell is available (Windows 10+)
where powershell >nul 2>nul
if %errorlevel%==0 (
    echo [BUILD] Using PowerShell Compress-Archive...
    powershell -Command "Compress-Archive -Path * -DestinationPath '%OUTPUT_DIR%\alienfall.love' -Force"
) else (
    echo [BUILD] Using 7-Zip...
    REM Try to find 7-Zip
    set SEVENZIP=
    if exist "C:\Program Files\7-Zip\7z.exe" set SEVENZIP=C:\Program Files\7-Zip\7z.exe
    if exist "C:\Program Files (x86)\7-Zip\7z.exe" set SEVENZIP=C:\Program Files (x86)\7-Zip\7z.exe

    if "!SEVENZIP!"=="" (
        echo [ERROR] Neither PowerShell nor 7-Zip found!
        echo [ERROR] Please install 7-Zip or use Windows 10+
        exit /b 1
    )

    "!SEVENZIP!" a -tzip "%OUTPUT_DIR%\alienfall.love" * >nul
)

cd /d "%BUILD_DIR%"

if not exist "%OUTPUT_DIR%\alienfall.love" (
    echo [ERROR] Failed to create .love file!
    exit /b 1
)

REM Get file size
for %%A in ("%OUTPUT_DIR%\alienfall.love") do set SIZE=%%~zA
set /a SIZE_MB=!SIZE! / 1048576
echo [BUILD] Created: alienfall.love (!SIZE_MB! MB)
echo.

REM Platform-specific builds (optional - requires Love2D distribution files)
echo [INFO] Platform-specific builds require Love2D distribution files.
echo [INFO] Download from: https://love2d.org/
echo [INFO] Extract to: build\love2d-windows\, build\love2d-linux\, etc.
echo.

if exist "%BUILD_DIR%\love2d-windows" (
    echo [WINDOWS] Building Windows executable...
    if not exist "%TEMP_DIR%\windows" mkdir "%TEMP_DIR%\windows"

    REM Copy Love2D files
    xcopy /E /I /Y /Q "%BUILD_DIR%\love2d-windows\*" "%TEMP_DIR%\windows\" >nul

    REM Fuse .love with love.exe
    copy /b "%TEMP_DIR%\windows\love.exe" + "%OUTPUT_DIR%\alienfall.love" "%TEMP_DIR%\windows\alienfall.exe" >nul
    del /q "%TEMP_DIR%\windows\love.exe"

    REM Create ZIP
    cd /d "%TEMP_DIR%\windows"
    powershell -Command "Compress-Archive -Path * -DestinationPath '%OUTPUT_DIR%\alienfall-windows.zip' -Force" 2>nul
    cd /d "%BUILD_DIR%"

    if exist "%OUTPUT_DIR%\alienfall-windows.zip" (
        for %%A in ("%OUTPUT_DIR%\alienfall-windows.zip") do set WIN_SIZE=%%~zA
        set /a WIN_SIZE_MB=!WIN_SIZE! / 1048576
        echo [WINDOWS] Created: alienfall-windows.zip (!WIN_SIZE_MB! MB)
    ) else (
        echo [WINDOWS] Warning: Failed to create Windows build
    )
    echo.
) else (
    echo [INFO] Skipping Windows build (love2d-windows not found)
    echo.
)

REM Summary
echo ========================================
echo Build Complete!
echo ========================================
echo.
echo Output directory: %OUTPUT_DIR%
echo.
echo Files created:
dir /b "%OUTPUT_DIR%"
echo.
echo To test: love output\alienfall.love
echo Or run: test_build.bat
echo.

REM Cleanup temp directory (optional)
set /p CLEANUP="Clean up temporary files? (y/n): "
if /i "%CLEANUP%"=="y" (
    echo [CLEANUP] Removing temporary files...
    rmdir /s /q "%TEMP_DIR%"
    echo [CLEANUP] Done.
)

echo.
echo [BUILD] Success!
echo.

endlocal

