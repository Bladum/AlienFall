@echo off
REM Clean up old log files
REM Keeps last 30 days, archives 30-90 days, deletes >90 days

echo Running log cleanup...
echo.

REM Run cleanup tool
lua tools\log_cleanup.lua

echo.
echo Cleanup complete!
pause

