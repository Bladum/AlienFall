# Task: Grid-Based Widget System for AlienFall

**Status:** TODO  
**Priority:** High  
**Created:** October 10, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Create a focused, well-documented widget system with 24x24 pixel grid-snapping for the AlienFall game. The system will include 23 essential widgets, a theme system, debug grid visualization, and fullscreen support.

---

## Purpose

The current widget system is over-engineered with too many features. We need a simplified, production-ready widget library that:
- Provides essential UI components with minimal but complete functionality
- Uses a consistent 24x24 pixel grid system for precise layout
- Includes comprehensive documentation and test cases
- Has a centralized theme system for consistent styling
- Supports debugging tools for UI design

---

## Requirements

### Functional Requirements
- [ ] 23 core widgets implemented (button, image button, combo box, checkbox, list box, scroll box, progress bar, health bar, radio box, tooltip, frame box, one-line edit, multiline edit, dropdown, panel, container, spinner, tab widget, dialog, autocomplete, table, textarea, textinput, window)
- [ ] All widgets snap to 24x24 pixel grid
- [ ] Theme system for centralized styling
- [ ] F9 toggles debug grid overlay (shows 40x30 grid lines)
- [ ] F12 toggles fullscreen with proper widget scaling
- [ ] Resolution: 960x720 (40x30 grid of 24x24 pixels)
- [ ] Each widget has documentation
- [ ] Each widget has test cases
- [ ] Demo application showcasing all widgets
- [ ] Mock data system for widget content

### Technical Requirements
- [ ] All widgets in `engine/widgets/` directory
- [ ] Modular architecture with base widget class
- [ ] Proper Love2D 12+ integration
- [ ] No external dependencies beyond Love2D
- [ ] Performance optimized (object pooling where appropriate)
- [ ] Console debugging support
- [ ] All temporary files use TEMP directory

### Acceptance Criteria
- [ ] All 23 widgets functional and documented
- [ ] Demo app runs without errors using `lovec "engine"`
- [ ] F9 shows/hides debug grid overlay
- [ ] F12 switches fullscreen smoothly
- [ ] All widgets align to 24x24 grid correctly
- [ ] Theme changes apply to all widgets
- [ ] Test suite passes for all widgets
- [ ] Documentation complete for each widget

---

## Plan

### Step 1: Project Structure Setup
**Description:** Create the widget system directory structure and core files  
**Files to modify/create:**
- `engine/widgets/init.lua` - Widget system loader
- `engine/widgets/base.lua` - Base widget class with grid snapping
- `engine/widgets/theme.lua` - Theme system
- `engine/widgets/grid.lua` - Grid system and debug overlay
- `engine/widgets/mock_data.lua` - Mock data generator
- `engine/conf.lua` - Update configuration for 960x720 resolution

**Estimated time:** 2 hours

### Step 2: Core System Implementation
**Description:** Implement grid system, theme system, and base widget  
**Files to create:**
- `engine/widgets/base.lua` - Base widget with:
  - Position snapping to 24x24 grid
  - Size snapping to 24x24 grid
  - Theme integration
  - Common properties (x, y, width, height, visible, enabled)
  - Event handling (hover, click, focus)
- `engine/widgets/theme.lua` - Theme system with:
  - Color definitions
  - Font specifications
  - Border/padding standards
  - Default theme
- `engine/widgets/grid.lua` - Grid debug system:
  - F9 toggle
  - Draw 40x30 grid lines
  - Grid coordinate display

**Estimated time:** 3 hours

### Step 3: Basic Widgets (Batch 1)
**Description:** Implement foundational widgets  
**Files to create:**
- `engine/widgets/button.lua` - Clickable button
- `engine/widgets/imagebutton.lua` - Button with image
- `engine/widgets/label.lua` - Text display
- `engine/widgets/panel.lua` - Background panel
- `engine/widgets/container.lua` - Widget grouping container

**Estimated time:** 4 hours

### Step 4: Input Widgets (Batch 2)
**Description:** Implement text input and editing widgets  
**Files to create:**
- `engine/widgets/textinput.lua` - Single-line text input
- `engine/widgets/textarea.lua` - Multi-line text area
- `engine/widgets/checkbox.lua` - Checkbox with label
- `engine/widgets/radiobutton.lua` - Radio button for groups
- `engine/widgets/spinner.lua` - Numeric up/down spinner

**Estimated time:** 5 hours

### Step 5: Selection Widgets (Batch 3)
**Description:** Implement dropdown and list selection widgets  
**Files to create:**
- `engine/widgets/dropdown.lua` - Dropdown menu
- `engine/widgets/combobox.lua` - Editable dropdown
- `engine/widgets/listbox.lua` - Scrollable list
- `engine/widgets/autocomplete.lua` - Autocomplete text input

**Estimated time:** 5 hours

### Step 6: Display Widgets (Batch 4)
**Description:** Implement progress, health, and scrolling widgets  
**Files to create:**
- `engine/widgets/progressbar.lua` - Progress indicator
- `engine/widgets/healthbar.lua` - Unit health display
- `engine/widgets/scrollbox.lua` - Scrollable content area
- `engine/widgets/tooltip.lua` - Hover tooltip

**Estimated time:** 4 hours

### Step 7: Complex Widgets (Batch 5)
**Description:** Implement advanced layout and data widgets  
**Files to create:**
- `engine/widgets/framebox.lua` - Labeled group box
- `engine/widgets/tabwidget.lua` - Tabbed interface
- `engine/widgets/table.lua` - Data table with sorting/filtering
- `engine/widgets/dialog.lua` - Modal dialog window
- `engine/widgets/window.lua` - Draggable window

**Estimated time:** 6 hours

### Step 8: Fullscreen and Scaling
**Description:** Implement F12 fullscreen toggle with proper scaling  
**Files to modify:**
- `engine/main.lua` - Add F12 key handler
- `engine/widgets/grid.lua` - Add scaling support

**Estimated time:** 2 hours

### Step 9: Documentation
**Description:** Create comprehensive documentation for each widget  
**Files to create:**
- `engine/widgets/docs/button.md`
- `engine/widgets/docs/imagebutton.md`
- ... (one for each widget)
- `engine/widgets/README.md` - Widget system overview
- `engine/widgets/THEME_GUIDE.md` - Theme customization guide

**Estimated time:** 4 hours

### Step 10: Test Suite
**Description:** Create test cases for each widget  
**Files to create:**
- `engine/widgets/tests/test_base.lua`
- `engine/widgets/tests/test_button.lua`
- `engine/widgets/tests/test_imagebutton.lua`
- ... (one for each widget)
- `engine/widgets/tests/run_tests.lua` - Test runner

**Estimated time:** 5 hours

### Step 11: Demo Application
**Description:** Create standalone demo showcasing all widgets  
**Files to create:**
- `engine/widgets/demo/main.lua` - Demo app entry point
- `engine/widgets/demo/conf.lua` - Demo configuration
- `engine/widgets/demo/screens/basic_widgets.lua`
- `engine/widgets/demo/screens/input_widgets.lua`
- `engine/widgets/demo/screens/selection_widgets.lua`
- `engine/widgets/demo/screens/display_widgets.lua`
- `engine/widgets/demo/screens/complex_widgets.lua`
- `engine/widgets/demo/assets/` - Demo images/fonts
- `engine/widgets/demo/run_demo.bat` - Quick launch script

**Estimated time:** 4 hours

### Step 12: Mock Data System
**Description:** Create mock data generator for widget testing  
**Files to create:**
- `engine/widgets/mock_data.lua` - Mock data functions:
  - `generateNames()` - Random names
  - `generateItems()` - Item lists
  - `generateTableData()` - Table rows
  - `generateHealthBars()` - Unit health data
  - `generateTooltips()` - Tooltip text

**Estimated time:** 2 hours

### Step 13: Integration and Polish
**Description:** Integrate widget system with main game  
**Files to modify:**
- `engine/main.lua` - Initialize widget system
- `engine/conf.lua` - Finalize configuration
- `engine/systems/ui.lua` - Update to use new widgets

**Estimated time:** 3 hours

### Step 14: Testing
**Description:** Comprehensive testing of entire widget system  
**Test cases:**
- All widgets render correctly on grid
- F9 shows/hides debug grid
- F12 toggles fullscreen
- Theme changes apply instantly
- All widgets respond to input
- Demo app runs without errors
- Test suite passes 100%

**Estimated time:** 3 hours

**Total Estimated Time:** 52 hours

---

## Implementation Details

### Architecture

**Grid System:**
- Base coordinate system: 960x720 (40 columns × 30 rows)
- Grid cell size: 24×24 pixels
- All widget positions must be multiples of 24
- All widget sizes must be multiples of 24

**Widget Hierarchy:**
```
BaseWidget (base.lua)
├── Button (button.lua)
├── ImageButton (imagebutton.lua)
├── Label (label.lua)
├── TextInput (textinput.lua)
├── TextArea (textarea.lua)
├── Checkbox (checkbox.lua)
├── RadioButton (radiobutton.lua)
├── Spinner (spinner.lua)
├── Dropdown (dropdown.lua)
├── ComboBox (combobox.lua)
├── ListBox (listbox.lua)
├── Autocomplete (autocomplete.lua)
├── ProgressBar (progressbar.lua)
├── HealthBar (healthbar.lua)
├── ScrollBox (scrollbox.lua)
├── Tooltip (tooltip.lua)
├── FrameBox (framebox.lua)
├── Panel (panel.lua)
├── Container (container.lua)
├── TabWidget (tabwidget.lua)
├── Table (table.lua)
├── Dialog (dialog.lua)
└── Window (window.lua)
```

**Theme System:**
```lua
theme = {
    colors = {
        primary = {r=100, g=100, b=200, a=255},
        background = {r=20, g=20, b=30, a=255},
        text = {r=220, g=220, b=220, a=255},
        border = {r=150, g=150, b=150, a=255},
        hover = {r=120, g=120, b=220, a=255},
        active = {r=140, g=140, b=240, a=255},
        disabled = {r=80, g=80, b=80, a=255},
    },
    fonts = {
        default = nil,  -- Loaded in init
        small = nil,
        large = nil,
    },
    spacing = 24,  -- Grid size
    border_width = 2,
    padding = 4,
}
```

### Key Components

- **BaseWidget:** Core widget class with grid snapping, event handling, theme integration
- **GridSystem:** Debug overlay, coordinate conversion, snapping functions
- **ThemeManager:** Centralized styling, color management, font management
- **MockData:** Test data generation for all widget types
- **WidgetFactory:** Helper functions to create pre-configured widgets

### Dependencies

- Love2D 12.0+
- No external libraries
- Uses `engine/assets/fonts/` for text rendering
- Uses `engine/assets/images/` for image buttons

---

## Testing Strategy

### Unit Tests

Each widget will have unit tests for:
- Grid snapping correctness
- Mouse interaction (hover, click)
- Keyboard input (where applicable)
- Theme application
- State changes (enabled/disabled, visible/hidden)
- Value changes (for input widgets)

### Integration Tests

- Theme changes affect all widgets
- Container properly manages child widgets
- Tab switching in TabWidget
- Dialog modal behavior
- Window dragging and positioning
- Grid coordinate system accuracy

### Manual Testing Steps

1. Run demo app: `lovec "engine/widgets/demo"`
2. Test F9 debug grid toggle
3. Test F12 fullscreen toggle
4. Navigate through all demo screens
5. Interact with each widget type
6. Verify grid alignment visually
7. Test theme switching
8. Check console for warnings/errors

### Expected Results

- All widgets aligned to 24×24 grid
- No visual artifacts or overlaps
- Smooth fullscreen transition
- Debug grid overlay matches widget positions
- All interactions respond immediately
- No console errors or warnings
- Demo runs at 60 FPS

---

## How to Run/Debug

### Running the Demo
```bash
# Run widget demo
lovec "engine/widgets/demo"

# Or use batch file
engine\widgets\demo\run_demo.bat
```

### Running the Game with New Widgets
```bash
# Run main game
lovec "engine"

# Or use VS Code task
Ctrl+Shift+P > Run Task > Run XCOM Simple Game
```

### Running Tests
```bash
# Run widget test suite
lovec "engine/widgets/tests"
```

### Debugging

**Console Output:**
- Enable in `conf.lua`: `t.console = true`
- Use `print("[WidgetName] Debug message")` format
- Check for initialization messages
- Monitor widget creation/destruction

**Debug Grid (F9):**
- Press F9 to toggle grid overlay
- Green lines show 24×24 grid
- Red crosshairs show mouse position
- Grid coordinates displayed in corner

**Common Debug Patterns:**
```lua
-- Widget creation
print("[Button] Created at (" .. self.x .. ", " .. self.y .. ")")

-- Grid snapping
print("[Grid] Snapped " .. rawX .. " to " .. snappedX)

-- Event handling
print("[Widget] Clicked at grid (" .. gridX .. ", " .. gridY .. ")")
```

### Temporary Files
- All temporary files MUST use: `os.getenv("TEMP")`
- Never create temp files in `engine/widgets/`
- Example: `os.getenv("TEMP") .. "\\widget_cache.tmp"`

---

## Documentation Updates

### Files to Update
- [x] `tasks/tasks.md` - Add this task
- [ ] `wiki/API.md` - Add widget system API reference
- [ ] `wiki/DEVELOPMENT.md` - Add widget development guidelines
- [ ] `engine/widgets/README.md` - Widget system overview
- [ ] `engine/widgets/THEME_GUIDE.md` - Theme customization
- [ ] `engine/widgets/docs/*.md` - Individual widget docs
- [ ] `.github/copilot-instructions.md` - Add grid system info

### System Prompt Updates

Add to `.github/copilot-instructions.md`:

```markdown
## Widget System and Grid Layout

### Grid System
- **Resolution:** 960×720 pixels (40×30 grid)
- **Grid Cell Size:** 24×24 pixels
- **ALL widget positions MUST be multiples of 24**
- **ALL widget sizes MUST be multiples of 24**
- Use `widgets.snapToGrid(x, y)` for positioning
- Use `widgets.snapSize(width, height)` for sizing

### Debug Tools
- **F9:** Toggle grid overlay (shows 40×30 grid lines)
- **F12:** Toggle fullscreen (with proper widget scaling)

### Widget Guidelines
- All widgets inherit from `BaseWidget`
- Use theme system for all styling
- Implement proper event handling (hover, click, focus)
- Document widget API in widget file header
- Create test cases in `engine/widgets/tests/`
- Use mock data from `engine/widgets/mock_data.lua`

### Theme System
- Centralized styling in `engine/widgets/theme.lua`
- All colors, fonts, spacing from theme
- Support theme switching at runtime
- Never hardcode visual properties
```

---

## Notes

### Design Decisions

1. **24×24 Grid:** Chosen for clean 40×30 layout, divisible by common widget sizes
2. **Minimal Features:** Each widget has core functionality only, avoiding feature creep
3. **Theme System:** Centralized styling prevents inconsistent appearance
4. **Debug Grid:** Essential for precise UI layout work
5. **Mock Data:** Enables testing without game integration

### Widget Feature Scope

Each widget should have ONLY these features:
- **Button:** Click, hover, enabled/disabled, icon/text
- **ImageButton:** Image display, click, hover, enabled/disabled
- **ComboBox:** Editable dropdown with text input
- **Checkbox:** Toggle state, label, enabled/disabled
- **ListBox:** Scrollable list, selection, items
- **ScrollBox:** Scrollable content area, vertical/horizontal
- **ProgressBar:** Value display, min/max, fill direction
- **HealthBar:** Current/max health, color gradient
- **RadioButton:** Group selection, label, enabled/disabled
- **Tooltip:** Hover text, delay, positioning
- **FrameBox:** Labeled border, child widget container
- **TextInput:** Single-line edit, cursor, selection
- **TextArea:** Multi-line edit, scrolling, cursor
- **Dropdown:** List selection, auto-close
- **Panel:** Background rectangle, border
- **Container:** Child widget layout and management
- **Spinner:** Numeric value, up/down buttons, step
- **TabWidget:** Multiple tabs, tab switching, content areas
- **Dialog:** Modal display, title, buttons, content
- **Autocomplete:** Text input with suggestion dropdown
- **Table:** Headers, rows, column sorting, filtering
- **Window:** Draggable, title bar, close button, content area

---

## Blockers

None currently identified.

---

## Review Checklist

- [ ] All widgets follow grid system (24×24 snapping)
- [ ] BaseWidget provides common functionality
- [ ] Theme system controls all visual properties
- [ ] F9 debug grid works correctly
- [ ] F12 fullscreen works correctly
- [ ] All 23 widgets implemented and functional
- [ ] Each widget has documentation file
- [ ] Each widget has test cases
- [ ] Demo app showcases all widgets
- [ ] Mock data system generates test data
- [ ] No global variables (all use `local`)
- [ ] Proper error handling with `pcall` where needed
- [ ] Performance optimized (60 FPS in demo)
- [ ] All temporary files use TEMP folder
- [ ] Console debugging statements added
- [ ] Code follows Lua/Love2D best practices
- [ ] Documentation updated in wiki
- [ ] System prompt updated with grid info
- [ ] No warnings in Love2D console

---

## Post-Completion

### What Worked Well
- TBD after completion

### What Could Be Improved
- TBD after completion

### Lessons Learned
- TBD after completion

---

## Widget Implementation Priority

**Phase 1 (Critical):** Button, Label, Panel, Container  
**Phase 2 (High):** TextInput, Checkbox, Dropdown, ListBox  
**Phase 3 (Medium):** ProgressBar, HealthBar, ScrollBox, Tooltip  
**Phase 4 (Medium):** FrameBox, TabWidget, Dialog, Window  
**Phase 5 (Nice to have):** ImageButton, ComboBox, RadioButton, Spinner, Autocomplete, Table, TextArea

This allows iterative development and early testing of core functionality.
