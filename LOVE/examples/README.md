# GUI Library Examples

This folder contains examples for the simple GUI library located in `../GUI/`.

## Running the Example

### Option 1: Using the batch file (Windows)
Double-click `run_example.bat` or run it from command prompt.

### Option 2: Manual command
```powershell
cd "C:\Users\tombl\Documents\AlienFall\LOVE\examples"
& "C:\Users\tombl\Documents\AlienFall\LOVE\love-11.5-win64\love.exe" .
```

### Option 3: Command line
```bash
love "C:\Users\tombl\Documents\AlienFall\LOVE\examples"
```

## What the Example Shows

The `main.lua` file demonstrates:
- Creating and using Button, Checkbox, RadioButton, and Label widgets
- Proper Love2D integration with mouse handling
- Radio button group functionality
- Callback functions for user interactions

## Library Location

The GUI library is located at `../GUI/common/button/` and contains:
- `button.lua` - Clickable button widget
- `checkbox.lua` - Toggleable checkbox widget
- `radio_button.lua` - Radio button with group support
- `label.lua` - Text display widget
- `init.lua` - Library loader

## Troubleshooting

If you get path errors, make sure you're running Love2D from the examples folder (not passing main.lua as an argument). The package.path is configured to find the GUI library relative to this examples folder.
