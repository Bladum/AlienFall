# Task: New Widget Development

**Status:** TODO  
**Priority:** Medium  
**Created:** October 12, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Design and implement 10 new useful widgets specifically for turn-based strategy game UIs. Each widget should follow the existing widget system architecture and grid alignment.

---

## Purpose

Expand the widget library with game-specific components that will be used throughout the game UI. Reduce code duplication and improve UI development speed.

---

## Requirements

### Functional Requirements
- [ ] 10 new widgets designed for strategy game use
- [ ] Each widget follows 24×24 pixel grid system
- [ ] Consistent with existing widget architecture
- [ ] Full documentation for each widget
- [ ] Test cases for each widget
- [ ] Demo/showcase integration

### Technical Requirements
- [ ] Inherit from BaseWidget
- [ ] Use theme system for styling
- [ ] Implement standard widget interface (update, draw, events)
- [ ] Grid-aligned positioning
- [ ] Proper input handling
- [ ] State management (enabled/disabled, hover, etc.)

### Acceptance Criteria
- [ ] All 10 widgets implemented
- [ ] Each widget has documentation in `widgets/docs/`
- [ ] Each widget has tests in `widgets/tests/`
- [ ] All widgets added to showcase
- [ ] All widgets follow grid alignment
- [ ] No console errors or warnings
- [ ] Performance tested with multiple instances

---

## Plan

### Step 1: Design Widget Specifications
**Description:** Define the 10 widgets and their requirements  
**Widgets to implement:**
1. **UnitCard** - Display unit portrait, name, stats, HP bar
2. **ActionBar** - Horizontal bar with action buttons (move, shoot, etc.)
3. **ResourceDisplay** - Show resources with icon + value (money, materials)
4. **MiniMap** - Small map overview with fog of war
5. **TurnIndicator** - Current turn, phase, active unit indicator
6. **InventorySlot** - Grid slot for items with drag-drop
7. **ResearchTree** - Tech tree node with connections
8. **NotificationBanner** - Sliding banner for game events
9. **ContextMenu** - Right-click context menu
10. **RangeIndicator** - Hex-based range display overlay

**Estimated time:** 1 hour

### Step 2: Implement Core Widgets (1-5)
**Description:** Create first 5 widgets  
**Files to create:**
- `engine/widgets/display/unitcard.lua`
- `engine/widgets/navigation/actionbar.lua`
- `engine/widgets/display/resourcedisplay.lua`
- `engine/widgets/display/minimap.lua`
- `engine/widgets/display/turnindicator.lua`

**Estimated time:** 4 hours

### Step 3: Implement Advanced Widgets (6-10)
**Description:** Create remaining 5 widgets  
**Files to create:**
- `engine/widgets/input/inventoryslot.lua`
- `engine/widgets/advanced/researchtree.lua`
- `engine/widgets/display/notificationbanner.lua`
- `engine/widgets/navigation/contextmenu.lua`
- `engine/widgets/advanced/rangeindicator.lua`

**Estimated time:** 4 hours

### Step 4: Write Documentation
**Description:** Create docs for each widget  
**Files to create:**
- 10 files in `engine/widgets/docs/`

**Estimated time:** 2 hours

### Step 5: Write Tests
**Description:** Create test cases for each widget  
**Files to create:**
- 10 files in `engine/widgets/tests/`

**Estimated time:** 2 hours

### Step 6: Add to Showcase
**Description:** Integrate widgets into widget_showcase  
**Files to modify:**
- `engine/modules/widget_showcase.lua`

**Estimated time:** 1 hour

### Step 7: Integration Testing
**Description:** Test widgets in actual game contexts  
**Test cases:**
- UnitCard in battlescape
- ActionBar in tactical UI
- ResourceDisplay in basescape
- MiniMap in geoscape

**Estimated time:** 1.5 hours

---

## Implementation Details

### Widget Specifications

#### 1. UnitCard
**Purpose:** Display unit information in compact card format  
**Features:**
- Portrait image (48×48 pixels, 2×2 grid cells)
- Unit name label
- Health bar
- Stats display (TU, accuracy, etc.)
- Status icons (stunned, panicked, etc.)

**Size:** 8×6 grid cells (192×144 pixels)

#### 2. ActionBar
**Purpose:** Horizontal bar of action buttons for selected unit  
**Features:**
- Multiple button slots
- Icon-based actions
- Hotkey indicators
- Disabled state when action unavailable
- Tooltip on hover

**Size:** Variable width × 2 grid cells height

#### 3. ResourceDisplay
**Purpose:** Show single resource with icon and value  
**Features:**
- Icon (24×24)
- Current value
- Optional max value
- Color coding for low/critical levels
- Trend indicator (up/down arrow)

**Size:** 4×1 grid cells (96×24 pixels)

#### 4. MiniMap
**Purpose:** Small overhead map view  
**Features:**
- Simplified map rendering
- Player units (blue dots)
- Enemy units (red dots)
- Fog of war
- Click to center view
- Viewport indicator

**Size:** 10×10 grid cells (240×240 pixels)

#### 5. TurnIndicator
**Purpose:** Display current turn and phase information  
**Features:**
- Turn number
- Phase name (Player, Enemy, Civilian)
- Active unit name/portrait
- Time units remaining
- End turn button

**Size:** 8×3 grid cells (192×72 pixels)

#### 6. InventorySlot
**Purpose:** Grid slot for inventory management  
**Features:**
- Item icon display
- Quantity badge
- Drag and drop support
- Hover tooltip
- Right-click menu
- Empty/filled states

**Size:** 2×2 grid cells (48×48 pixels)

#### 7. ResearchTree
**Purpose:** Tech tree node with connections  
**Features:**
- Node icon and name
- Research status (available, researching, completed, locked)
- Connection lines to prerequisites
- Click to select
- Progress indicator
- Cost display

**Size:** 6×4 grid cells (144×96 pixels)

#### 8. NotificationBanner
**Purpose:** Sliding notification for game events  
**Features:**
- Slide in/out animation
- Icon + message text
- Auto-dismiss timer
- Click to dismiss
- Priority levels (info, warning, critical)
- Queue for multiple notifications

**Size:** 16×2 grid cells (384×48 pixels)

#### 9. ContextMenu
**Purpose:** Right-click popup menu  
**Features:**
- Dynamic menu items
- Icon + label for each item
- Keyboard shortcuts shown
- Disabled items greyed out
- Auto-position to stay on screen
- Click outside to close

**Size:** Variable (min 6×1 per item)

#### 10. RangeIndicator
**Purpose:** Visual overlay showing range on hex grid  
**Features:**
- Hex-based range calculation
- Color-coded ranges (move, shoot, throw)
- Transparency gradient
- Pathfinding integration
- Line of sight awareness
- Multiple range types

**Size:** Overlay (no fixed size)

### Base Structure for Each Widget
```lua
local WidgetName = setmetatable({}, {__index = BaseWidget})
WidgetName.__index = WidgetName

function WidgetName.new(x, y, width, height, options)
    local self = BaseWidget.new(x, y, width, height)
    setmetatable(self, WidgetName)
    
    -- Initialize widget-specific properties
    self.property = options.property or default
    
    return self
end

function WidgetName:update(dt)
    if not self.enabled then return end
    BaseWidget.update(self, dt)
    -- Widget-specific update logic
end

function WidgetName:draw()
    if not self.visible then return end
    -- Widget-specific drawing
end

-- Event handlers
function WidgetName:onMousePressed(x, y, button) end
function WidgetName:onMouseReleased(x, y, button) end
function WidgetName:onMouseMoved(x, y, dx, dy) end
function WidgetName:onKeyPressed(key) end

return WidgetName
```

### Dependencies
- BaseWidget for inheritance
- Theme system for colors/fonts
- Grid system for alignment
- Input handling from state manager
- Asset system for icons

---

## Testing Strategy

### Unit Tests
Each widget should have tests for:
- Constructor creates valid widget
- Grid alignment is correct
- Properties can be set/get
- Events trigger correctly
- Theme application works
- Enabled/disabled states

### Integration Tests
- Multiple widget instances don't interfere
- Widgets work in actual game modules
- Performance with many instances
- Memory cleanup on widget removal

### Manual Testing Steps
1. Run widget showcase
2. Verify each widget displays correctly
3. Test interaction (click, hover, keyboard)
4. Test grid alignment with F9
5. Test with different themes
6. Test edge cases (empty data, max values)
7. Use in actual game context
8. Check for memory leaks

### Expected Results
- All widgets render correctly
- Input handling works smoothly
- No console errors
- Grid alignment perfect
- Performance acceptable
- Theme styling consistent

---

## How to Run/Debug

### Running Widget Showcase
```bash
lovec "engine"
# Then select "Widget Showcase" from menu
```

### Testing Individual Widget
```lua
-- In widget_showcase.lua
local testWidget = UnitCard.new(0, 0, 8, 6, {
    unitName = "Soldier",
    health = 75,
    maxHealth = 100,
    timeUnits = 60
})
```

### Debugging
- Use F9 to verify grid alignment
- Print widget bounds: `print(widget.x, widget.y, widget.width, widget.height)`
- Check mouse hit detection
- Verify event propagation

### Console Output
```
[Widgets] Loading UnitCard widget
[Widgets] UnitCard: Grid aligned at (0, 0), size (192, 144)
[UnitCard] Created for unit: Soldier
```

---

## Documentation Updates

### Files to Update
- [ ] `tasks/tasks.md` - Add task entry
- [ ] `engine/widgets/README.md` - List new widgets
- [ ] `wiki/API.md` - Document each widget API
- [ ] Individual widget docs in `engine/widgets/docs/`

### Documentation Template for Each Widget
```markdown
# WidgetName Widget

## Purpose
Brief description of what this widget does.

## Constructor
\`\`\`lua
WidgetName.new(x, y, width, height, options)
\`\`\`

## Parameters
- **x, y:** Grid-aligned position
- **width, height:** Size in pixels (must be multiple of 24)
- **options:** Table with widget-specific options

## Methods
List of public methods

## Events
List of events this widget fires

## Example Usage
Code example showing typical usage

## Visual Example
Screenshot or ASCII art showing the widget
```

---

## Notes

- Consider adding animation support to some widgets
- May want to add sound effects for interactions
- Consider accessibility features (keyboard navigation)
- Think about mobile/touch support for future

---

## Blockers

None. Widget system fully functional.

---

## Review Checklist

- [ ] All 10 widgets implemented
- [ ] Grid alignment verified (F9 test)
- [ ] Theme system used throughout
- [ ] No hardcoded colors or sizes
- [ ] Documentation complete
- [ ] Tests written and passing
- [ ] Added to showcase
- [ ] Performance tested
- [ ] No memory leaks
- [ ] Console logging appropriate
- [ ] Code follows standards

---

## Post-Completion

### What Worked Well
TBD

### What Could Be Improved
TBD

### Lessons Learned
TBD
