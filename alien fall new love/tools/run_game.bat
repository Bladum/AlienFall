@echo off
setlocal enabledelayedexpansion

REM Set default values
set "TEST_MODE=false"
set "TEST_WATCH=false"
set "TEST_FILE="
set "DEBUG_MODE=false"

REM Parse command line arguments
:parse_args
if "%~1"=="" goto :end_parse
if "%~1"=="--test" (
    set "TEST_MODE=true"
    shift
    goto :parse_args
)
if "%~1"=="--test-watch" (
    set "TEST_MODE=true"
    set "TEST_WATCH=true"
    shift
    goto :parse_args
)
if "%~1"=="--test-file" (
    set "TEST_FILE=%~2"
    set "TEST_MODE=true"
    shift
    shift
    goto :parse_args
)
if "%~1"=="--debug" (
    set "DEBUG_MODE=true"
    shift
    goto :parse_args
)
shift
goto :parse_args
:end_parse

REM Set Love2D executable - always use console version for debugging
set "LOVE_EXE=lovec.exe"

REM Set environment variables for test mode
if "%TEST_MODE%"=="true" (
    set "LOVE_TEST_MODE=true"
    echo Running Alien Fall in test mode...
    if "%TEST_WATCH%"=="true" (
        set "LOVE_TEST_WATCH=true"
        echo   Watch mode: enabled
    )
    if defined TEST_FILE (
        set "LOVE_TEST_FILE=%TEST_FILE%"
        echo   Test file: %TEST_FILE%
    )
) else (
    echo Running Alien Fall...
)

REM Run the game
"C:\Program Files\LOVE\%LOVE_EXE%" .

endlocal