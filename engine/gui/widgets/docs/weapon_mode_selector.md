# Weapon Mode Selector Widget

**File:** `engine/widgets/combat/weapon_mode_selector.lua`  
**Purpose:** Visual mode selection interface for weapon firing modes  
**Grid Size:** 24×8 grid cells (576×192 pixels)

## Overview

The Weapon Mode Selector displays 6 firing modes in a 2×3 grid layout. Each mode button shows:
- Mode name and keyboard shortcut
- AP cost multiplier
- EP cost multiplier  
- Accuracy modifier
- Brief description

Unavailable modes (per weapon) are grayed out. Selected mode is highlighted.

## Constructor

```lua
local selector = WeaponModeSelector.new(x, y, weaponId)
```

### Parameters
- `x` (number): X position in pixels (grid-aligned)
- `y` (number): Y position in pixels (grid-aligned)
- `weaponId` (string, optional): Initial weapon ID

### Returns
- (table): New WeaponModeSelector instance

## Properties

### Core Properties
- `weaponId` (string): Current weapon ID
- `selectedMode` (string): Currently selected mode ID ("SNAP", "AIM", etc.)
- `availableModes` (table): Array of available mode IDs for current weapon
- `onModeSelect` (function): Callback when mode is selected: `function(mode)`

### Layout Properties
- `buttonWidth` (number): 192 pixels (8 grid cells)
- `buttonHeight` (number): 96 pixels (4 grid cells)
- `buttonSpacing` (number): 0 (compact layout)

## Methods

### updateWeapon(weaponId)
Update the weapon and refresh available modes.

```lua
selector:updateWeapon("sniper_rifle")
```

**Parameters:**
- `weaponId` (string): Weapon ID to display modes for

**Effects:**
- Updates `self.weaponId`
- Refreshes `self.availableModes` from weapon data
- Switches to first available mode if current mode unavailable

### isModeAvailable(mode)
Check if mode is available for current weapon.

```lua
local canUseAuto = selector:isModeAvailable("AUTO")
```

**Parameters:**
- `mode` (string): Mode ID to check

**Returns:**
- (boolean): True if mode is in availableModes array

### setSelectedMode(mode)
Set the selected mode (if available).

```lua
selector:setSelectedMode("LONG")
```

**Parameters:**
- `mode` (string): Mode ID to select

**Effects:**
- Updates `self.selectedMode` if mode is available
- Calls `self.onModeSelect(mode)` callback if set
- Ignored if mode is unavailable

### getModeStats(mode)
Get mode statistics for display.

```lua
local stats = selector:getModeStats("AUTO")
-- Returns: {apCost = "1.0x", epCost = "1.5x", accuracyMod = "-10%", description = "Burst fire"}
```

**Parameters:**
- `mode` (string): Mode ID

**Returns:**
- (table): Stats with fields:
  - `apCost` (string): AP multiplier formatted (e.g., "1.5x")
  - `epCost` (string): EP multiplier formatted (e.g., "2.0x")
  - `accuracyMod` (string): Accuracy modifier formatted (e.g., "+15%")
  - `description` (string): Brief mode description

## Events

### mousepressed(x, y, button)
Handle mouse click on mode buttons.

**Behavior:**
- Detects which mode button was clicked (2×3 grid)
- Selects mode if available
- Returns true if handled, false otherwise

### keypressed(key)
Handle keyboard shortcuts (1-6 keys).

**Shortcuts:**
- `1` - SNAP
- `2` - AIM
- `3` - LONG
- `4` - AUTO
- `5` - HEAVY
- `6` - FINESSE

**Behavior:**
- Selects corresponding mode if available
- Returns true if handled, false otherwise

## Visual States

### Normal Mode Button
- Background: secondary color
- Text: normal text color
- Border: standard border

### Selected Mode Button
- Background: primary color (highlighted)
- Text: normal text color
- Border: standard border

### Unavailable Mode Button
- Background: disabled color (grayed out)
- Text: disabled text color
- Border: standard border
- Not clickable

### Hover Mode Button (Available)
- Background: hover color
- Text: normal text color
- Border: standard border

## Usage Example

```lua
local WeaponModeSelector = require("widgets.combat.weapon_mode_selector")

-- Create selector at grid position (10, 20)
local selector = WeaponModeSelector.new(240, 480, "assault_rifle")

-- Set mode selection callback
selector.onModeSelect = function(mode)
    print("Selected mode: " .. mode)
    -- Apply mode to shooting system
end

-- Update weapon when player changes weapon
selector:updateWeapon("sniper_rifle")

-- In love.draw()
selector:draw()

-- In love.mousepressed()
if selector:mousepressed(x, y, button) then
    -- Mode was selected
end

-- In love.keypressed()
if selector:keypressed(key) then
    -- Mode was selected via keyboard
end
```

## Integration with Battlescape

Typical integration in battlescape targeting overlay:

```lua
-- In battlescape init
self.modeSelector = WeaponModeSelector.new(24, 600, nil)
self.modeSelector.onModeSelect = function(mode)
    self.selectedMode = mode
    print("[Battlescape] Firing mode changed to: " .. mode)
end

-- When unit selects weapon
function Battlescape:onUnitSelected(unit)
    local weaponId = unit.weapon1 or unit.left_weapon
    self.modeSelector:updateWeapon(weaponId)
end

-- In battlescape:draw()
if self.targetingMode then
    self.modeSelector:draw()
end

-- In battlescape input handlers
self.modeSelector:mousepressed(x, y, button)
self.modeSelector:keypressed(key)
```

## Mode Information

| Mode | Key | Description | AP Mod | EP Mod | Acc Mod |
|------|-----|-------------|--------|--------|---------|
| SNAP | 1 | Quick shot | 0.6x | 0.5x | -15% |
| AIM | 2 | Careful aim | 1.0x | 1.0x | 0% |
| LONG | 3 | Sniper shot | 1.5x | 1.2x | +15% |
| AUTO | 4 | Burst (5 bullets) | 1.0x | 1.5x | -10% |
| HEAVY | 5 | Power shot | 1.2x | 2.0x | -5% |
| FINESSE | 6 | Precision strike | 1.0x | 1.0x | +5% |

## Weapon Mode Availability Examples

Different weapons have different available modes:

```lua
-- Sniper Rifle: precision only
availableModes = ["AIM", "LONG", "FINESSE"]

-- Assault Rifle: versatile
availableModes = ["SNAP", "AIM", "LONG", "AUTO"]

-- SMG: close-quarters
availableModes = ["SNAP", "AIM", "AUTO"]

-- Heavy Cannon: power only
availableModes = ["AIM", "HEAVY"]

-- Pistol: simple
availableModes = ["SNAP", "AIM"]
```

## Grid Alignment

Widget uses 24-pixel grid:
- Total size: 24×8 cells (576×192 pixels)
- Each button: 8×4 cells (192×96 pixels)
- Layout: 3 columns × 2 rows
- No spacing between buttons (compact)

## Dependencies

- `widgets.core.base` - BaseWidget class
- `widgets.core.theme` - Theme system
- `battlescape.combat.weapon_system` - Weapon data access
- `battlescape.combat.weapon_modes` - Mode definitions

## Testing

Create test file: `engine/widgets/tests/test_weapon_mode_selector.lua`

```lua
local WeaponModeSelector = require("widgets.combat.weapon_mode_selector")

function test_mode_selection()
    local selector = WeaponModeSelector.new(0, 0, "rifle")
    selector:setSelectedMode("AUTO")
    assert(selector.selectedMode == "AUTO")
end

function test_unavailable_modes()
    local selector = WeaponModeSelector.new(0, 0, "sniper_rifle")
    -- Sniper cannot use AUTO
    assert(not selector:isModeAvailable("AUTO"))
    selector:setSelectedMode("AUTO")
    -- Should not change to unavailable mode
    assert(selector.selectedMode ~= "AUTO")
end

function test_keyboard_shortcuts()
    local selector = WeaponModeSelector.new(0, 0, "rifle")
    selector:keypressed("4")  -- Key 4 = AUTO
    assert(selector.selectedMode == "AUTO")
end
```

## Future Enhancements

- [ ] Visual effects on mode change (flash, sound)
- [ ] Show current ammo count per mode
- [ ] Display bullets fired for AUTO mode
- [ ] Show effective range per mode
- [ ] Tooltips with detailed mode info
- [ ] Animation on unavailable mode click
- [ ] Color-code modes by type (accuracy/power/speed)
