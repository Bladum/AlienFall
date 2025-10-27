@echo off
REM Run all XCOM Simple tests
REM Requires Love2D 12.0+ with lovec.exe in PATH

echo ============================================================
echo XCOM SIMPLE - TEST SUITE RUNNER
echo ============================================================
echo.

REM Check if Love2D is available
where lovec >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: lovec.exe not found in PATH
    echo Please install Love2D 12.0+ or add it to your PATH
    echo.
    echo Expected location: C:\Program Files\LOVE\lovec.exe
    pause
    exit /b 1
)

echo Running comprehensive test suite...
echo.

REM Run tests from project root
"C:\Program Files\LOVE\lovec.exe" tests\runners

REM Capture exit code
set TEST_RESULT=%ERRORLEVEL%

REM Force close Love2D window if still open (timeout: 2 seconds)
timeout /t 2 /nobreak >nul 2>&1
taskkill /IM love.exe /F >nul 2>&1

echo.
echo ============================================================
if %TEST_RESULT% EQU 0 (
    echo TESTS PASSED
) else (
    echo TESTS FAILED
)
echo ============================================================
echo.

pause
exit /b %TEST_RESULT%
