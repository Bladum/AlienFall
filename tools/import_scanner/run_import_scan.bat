@echo off
REM Lua Import Scanner - Windows Batch Runner
REM
REM Scans Lua files in the engine folder for import problems
REM and generates a detailed report
REM
REM Usage: run_import_scan.bat [format]
REM   format: text (default), json, html
REM
REM Examples:
REM   run_import_scan.bat
REM   run_import_scan.bat json
REM   run_import_scan.bat html --verbose

setlocal enabledelayedexpansion

echo.
echo ══════════════════════════════════════════════════════════
echo  Lua Import Scanner
echo ══════════════════════════════════════════════════════════
echo.

REM Parse arguments
set FORMAT=text
set VERBOSE=
set STRICT=

if not "%~1"=="" (
    set FORMAT=%~1
)

:parse_args
shift
if "%~1"=="" goto args_done
if "%~1"=="--verbose" (
    set VERBOSE=--verbose
    goto parse_args
)
if "%~1"=="--strict" (
    set STRICT=--strict
    goto parse_args
)
goto parse_args

:args_done

echo [INFO] Format: %FORMAT%
if not "%VERBOSE%"=="" echo [INFO] Verbose mode enabled
if not "%STRICT%"=="" echo [INFO] Strict mode enabled
echo.

REM Check if PowerShell is available
powershell -Command "exit 0" 2>nul
if %ERRORLEVEL% equ 0 (
    echo [INFO] Using PowerShell scanner...
    powershell -ExecutionPolicy Bypass -File "tools\import_scanner\scan_imports.ps1" ^
        -Format %FORMAT% ^
        -OutputFile "import_report.txt" ^
        %VERBOSE% ^
        %STRICT%
    goto done
)

REM Fallback to Lua if PowerShell not available
echo [INFO] PowerShell not available, trying Lua...
if exist "engine" (
    lua tools\import_scanner\scan_imports.lua ^
        --format %FORMAT% ^
        --output import_report.txt %VERBOSE% %STRICT%
    goto done
) else (
    echo [ERROR] Cannot find engine folder
    exit /b 1
)

:done
echo.
echo [INFO] Scan complete. Report: import_report.txt
pause
