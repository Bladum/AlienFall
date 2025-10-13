# Task: Reduce Menu Button Size

**Status:** TODO  
**Priority:** Low  
**Created:** October 12, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Make menu buttons smaller: 8×2 grid cells (192×48 pixels) instead of current size.

---

## Purpose

Improve menu aesthetics and make better use of screen space. Smaller buttons look more refined and allow for more UI elements if needed.

---

## Requirements

### Functional Requirements
- [ ] All menu buttons 8×2 grid cells (192×48 pixels)
- [ ] Buttons still clickable and readable
- [ ] Buttons properly grid-aligned
- [ ] Menu layout adjusted for new size
- [ ] Consistent across all menus

### Technical Requirements
- [ ] Update button dimensions
- [ ] Recalculate button positions
- [ ] Maintain grid alignment (24×24)
- [ ] Update any hardcoded sizes
- [ ] Test on different screens

### Acceptance Criteria
- [ ] All menu buttons are 192×48 pixels
- [ ] Buttons aligned to 24×24 grid
- [ ] Text readable and properly centered
- [ ] Buttons responsive to clicks
- [ ] Layout looks good
- [ ] Consistent across all menus

---

## Plan

### Step 1: Identify All Menu Buttons
**Description:** Find all menu button instances  
**Files to search:**
- `engine/modules/menu.lua`
- `engine/modules/basescape.lua`
- `engine/modules/geoscape/*.lua`
- `engine/modules/battlescape.lua`
- Any other menu/UI files

**Search for:**
- Button widget creation
- Button size specifications
- Layout definitions

**Estimated time:** 1 hour

### Step 2: Update Main Menu Buttons
**Description:** Resize buttons in main menu  
**Files to modify:**
- `engine/modules/menu.lua`

**Changes:**
- Width: 8 grid cells (192 pixels)
- Height: 2 grid cells (48 pixels)
- Recenter buttons on screen
- Adjust spacing between buttons

**Estimated time:** 2 hours

### Step 3: Update Basescape Menu Buttons
**Description:** Resize buttons in basescape  
**Files to modify:**
- `engine/modules/basescape.lua`

**Estimated time:** 1 hour

### Step 4: Update Geoscape Menu Buttons
**Description:** Resize buttons in geoscape  
**Files to modify:**
- Files in `engine/modules/geoscape/`

**Estimated time:** 1 hour

### Step 5: Update Battlescape Menu Buttons
**Description:** Resize buttons in battlescape  
**Files to modify:**
- `engine/modules/battlescape.lua`

**Note:** Don't affect action panel buttons (those are 6×2)

**Estimated time:** 1 hour

### Step 6: Update Tests Menu
**Description:** Resize buttons in tests menu  
**Files to modify:**
- `engine/modules/tests_menu.lua`

**Estimated time:** 30 minutes

### Step 7: Update Widget Showcase
**Description:** Resize buttons in widget showcase  
**Files to modify:**
- `engine/modules/widget_showcase.lua`

**Estimated time:** 30 minutes

### Step 8: Verify Grid Alignment
**Description:** Use grid overlay to verify  
**Actions:**
- Press F9 to show grid
- Check all menu buttons align
- Verify positions are multiples of 24
- Verify sizes are multiples of 24

**Estimated time:** 1 hour

### Step 9: Adjust Button Layout
**Description:** Recalculate button positions  
**Considerations:**
- Center buttons on screen
- Consistent spacing
- Visual balance
- Adequate spacing for readability

**Standard spacing:** 1 grid cell (24 pixels) between buttons

**Estimated time:** 2 hours

### Step 10: Test All Menus
**Description:** Manual testing of all menus  
**Test:**
- Main menu: All buttons work
- Basescape: All buttons work
- Geoscape: All buttons work
- Battlescape: All buttons work
- Tests menu: All buttons work
- Widget showcase: All buttons work
- Text is readable
- Buttons respond to clicks
- Layout looks good

**Estimated time:** 2 hours

---

## Implementation Details

### Architecture

**Button Size Standard:**
- **Menu Buttons:** 8×2 grid cells (192×48 pixels)
- **Action Buttons:** 6×2 grid cells (144×48 pixels)
- **Small Buttons:** 4×2 grid cells (96×48 pixels)

**Grid Calculation:**
- 1 grid cell = 24 pixels
- 8 cells width = 192 pixels
- 2 cells height = 48 pixels

**Centering on Screen:**
```lua
-- Screen: 960×720 pixels (40×30 grid cells)
-- Button: 192×48 pixels (8×2 grid cells)

-- Horizontal center
local screenCenterX = 960 / 2  -- 480 pixels (20 grid cells)
local buttonCenterX = screenCenterX - (192 / 2)  -- 384 pixels (16 grid cells)

-- Snap to grid
local buttonX = math.floor(buttonCenterX / 24) * 24  -- 384 pixels (16 grid cells)

-- Result: Button starts at grid column 16, width 8 cells
-- Takes columns 16-23 (centered on 40-cell width)
```

**Example Main Menu Layout:**
```lua
-- engine/modules/menu.lua
local Menu = {}

function Menu:init()
    local screenWidth = 960
    local screenHeight = 720
    local buttonWidth = 192  -- 8 grid cells
    local buttonHeight = 48  -- 2 grid cells
    local buttonSpacing = 24  -- 1 grid cell
    
    -- Center horizontally
    local buttonX = (screenWidth - buttonWidth) / 2
    buttonX = math.floor(buttonX / 24) * 24  -- Snap to grid
    
    -- Stack vertically, centered
    local numButtons = 5
    local totalHeight = (numButtons * buttonHeight) + ((numButtons - 1) * buttonSpacing)
    local startY = (screenHeight - totalHeight) / 2
    startY = math.floor(startY / 24) * 24  -- Snap to grid
    
    self.buttons = {}
    
    local labels = {"New Game", "Load Game", "Options", "Credits", "Exit"}
    for i, label in ipairs(labels) do
        local buttonY = startY + (i - 1) * (buttonHeight + buttonSpacing)
        local button = Button:new(buttonX, buttonY, buttonWidth, buttonHeight, label)
        table.insert(self.buttons, button)
    end
end
```

**Before (hypothetical 12×3 cells = 288×72):**
```
Screen: 960×720
Button: 288×72
Position: (336, Y)  -- 14 grid cells from left
```

**After (8×2 cells = 192×48):**
```
Screen: 960×720
Button: 192×48
Position: (384, Y)  -- 16 grid cells from left
```

### Key Components
- **Button Widget:** Standard button with new size
- **Menu Layouts:** All menu files with button positioning
- **Grid System:** Ensures proper alignment

### Dependencies
- Widget system (Button widget)
- Grid system (alignment)
- All menu modules

---

## Testing Strategy

### Manual Testing Steps
1. Launch game
2. Check main menu buttons
   - Size looks correct
   - Text is readable
   - Buttons centered
   - Clicking works
3. Enter basescape
   - Check menu buttons
4. Enter geoscape
   - Check menu buttons
5. Enter battlescape
   - Check menu buttons (not action panel)
6. Check other menus
7. Press F9 → Verify grid alignment
8. Test at different window sizes (if resizable)

### Expected Results
- All menu buttons 192×48 pixels
- All buttons grid-aligned
- Text clear and centered
- Responsive to clicks
- Visually balanced layouts
- Consistent across menus

---

## How to Run/Debug

### Running the Game
```bash
lovec "engine"
```

### Check Button Sizes
```lua
-- Add to button initialization
print("[Button] Size: " .. self.width .. "×" .. self.height .. 
      " Position: " .. self.x .. "," .. self.y)

-- Verify grid alignment
local gridX = self.x % 24
local gridY = self.y % 24
if gridX ~= 0 or gridY ~= 0 then
    print("[WARNING] Button not grid-aligned: offset " .. gridX .. "," .. gridY)
end
```

### Visual Verification
- Press F9 to show grid overlay
- Verify button boundaries align with grid
- Verify button starts and ends on grid lines

---

## Documentation Updates

### Files to Update
- [ ] `wiki/QUICK_REFERENCE.md` - Update button sizes
- [ ] Widget documentation - Update button size standards
- [ ] Code comments - Update button size comments

---

## Notes

**Size Comparison:**
- Old (assumed): 12×3 cells = 288×72 pixels
- New: 8×2 cells = 192×48 pixels
- Reduction: 33% width, 33% height, ~56% area

**Benefits:**
- More screen real estate
- Cleaner, more refined look
- Allows more UI elements if needed
- Better proportions

**Considerations:**
- Ensure text still fits
- Maintain readability
- Keep adequate click area
- Preserve visual hierarchy

**Consistency:**
- Menu buttons: 8×2 (192×48)
- Action buttons: 6×2 (144×48) - already specified
- Icon buttons: 2×2 (48×48) - if applicable
- Notification buttons: 2×2 (48×48) - already specified

---

## Blockers

None - straightforward size changes.

---

## Review Checklist

- [ ] All menu button instances found
- [ ] Main menu buttons resized
- [ ] Basescape menu buttons resized
- [ ] Geoscape menu buttons resized
- [ ] Battlescape menu buttons resized
- [ ] Tests menu buttons resized
- [ ] Widget showcase buttons resized
- [ ] All buttons grid-aligned
- [ ] Button layouts adjusted
- [ ] Text readable and centered
- [ ] All buttons clickable
- [ ] Visually balanced
- [ ] Consistent across all menus
- [ ] Documentation updated

---

## Post-Completion

### What Worked Well
- To be filled after completion

### What Could Be Improved
- To be filled after completion

### Lessons Learned
- To be filled after completion
