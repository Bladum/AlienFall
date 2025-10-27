@echo off
REM Run tests with logging enabled
REM Test results will be saved to logs/tests/

echo Running tests with logging...
echo Test logs will be saved to: logs/tests/

REM Create logs directory if it doesn't exist
if not exist "logs\tests" mkdir "logs\tests"

REM Run tests based on parameter
if "%1"=="" (
    echo Running all tests...
    lovec "tests2/runners" run_all
) else if "%1"=="subsystem" (
    echo Running subsystem: %2
    lovec "tests2/runners" run_subsystem %2
) else if "%1"=="single" (
    echo Running single test: %2
    lovec "tests2/runners" run_single_test %2
) else (
    echo Usage: run_tests_with_logging.bat [subsystem ^<name^>] [single ^<test_path^>]
    echo   No args: Run all tests
    echo   subsystem ^<name^>: Run specific subsystem
    echo   single ^<test_path^>: Run single test
)

echo.
echo Tests completed. Check logs in:
echo - logs/tests/ (test results, failures, coverage)
pause
@echo off
REM Run game with logging enabled
REM All output will be saved to logs/ folder

echo Starting AlienFall with logging...
echo Logs will be saved to: logs/game/

REM Create logs directory if it doesn't exist
if not exist "logs\game" mkdir "logs\game"
if not exist "logs\system" mkdir "logs\system"

REM Run the game
lovec "engine"

echo.
echo Game closed. Check logs in:
echo - logs/game/ (gameplay logs)
echo - logs/system/ (engine logs)
pause

