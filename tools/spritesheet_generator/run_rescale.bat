@echo off
REM Image Rescaler
REM Rescales all PNG images in armies/*/graphics/ to 80x80 pixels

echo.
echo ========== IMAGE RESCALER ==========
echo.
echo Rescaling images to 80x80 pixels with transparent background...
echo - Blue army
echo - Red army
echo - Yellow army
echo.
echo Output: output_rescaled\
echo.

cd /d "%~dp0"

"C:\Program Files\LOVE\lovec.exe" "rescale_main.lua"

echo.
echo ========== COMPLETE ==========
echo Rescaled images are in: output_rescaled\
echo.