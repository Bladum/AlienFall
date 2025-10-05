---
title: Widget Architecture and Dependencies
summary: Analysis of widget composition, dependencies, and build hierarchy for AlienFall's UI system
tags:
  - gui
  - widgets
  - architecture
  - dependencies
  - love2d
---

# Widget Architecture and Dependencies

This document provides a comprehensive analysis of how AlienFall's widget library is structured, including the dependency hierarchy, composition patterns, and implementation guidelines for building complex widgets from basic components.

## Overview

The AlienFall widget system follows a modular, composable architecture where complex user interface elements are built by combining simpler, reusable components. This approach ensures consistency, maintainability, and efficient development of the game's UI.

## Widget Dependency Hierarchy

### Level 0: Fundamental Basic Widgets (No Dependencies)

These are the atomic building blocks that form the foundation of all other widgets:

- **Label**: Pure text display widget
- **Icon**: Simple icon display widget
- **Button**: Primary clickable action element
- **Separator**: Visual divider element
- **Panel**: Basic container widget

### Level 1: Simple Composite Widgets

Built directly from Level 0 widgets through composition:

- **ImageButton** = Button + Icon
- **CheckButton** = Button + Label
- **RadioButton** = Button + Label
- **ToggleButton** = Button (with persistent state)
- **Scrollbar** = Independent scrolling control
- **Window** = Panel + Button + Label

### Level 2: Input and Selection Widgets

Build on Level 0-1 widgets with added functionality:

- **TextInput** = Basic text input field (fundamental)
- **Slider** = Button (thumb) + Label + visual track
- **Spinner** = TextInput + Button (increment/decrement)
- **TextArea** = TextInput + Scrollbar
- **ListBox** = Label + Scrollbar + selection logic
- **ComboBox** = Button + ListBox (dropdown)

### Level 3: Data Display Widgets

Use Level 0-2 widgets for structured data presentation:

- **Table** = Label + Scrollbar + Button (sortable headers)
- **ItemList** = ListBox + Icon
- **StatusBar** = Label + Panel + ProgressBar
- **Badge** = Icon + Label

### Level 4: Container and Layout Widgets

Composition of containers with navigation and organization:

- **TabContainer** = Panel + Button (tabs)
- **ScrollPanel** = Panel + Scrollbar
- **GroupBox** = Panel + Label (titled container)
- **SplitPanel** = Panel + Splitter control

### Level 5+: Complex Game-Specific Widgets

Built from multiple lower-level widgets for specialized functionality:

- **InventoryGrid** = Panel + ItemList + DragDrop system
- **UnitPanel** = Panel + UnitPortrait + HealthBar + Buttons
- **BattlescapeGrid** = Panel + Unit icons + movement overlays
- **ResearchTree** = Panel + TreeView (TreeView = ListBox + expand/collapse buttons)
- **GeoscapeMap** = Panel + MiniMap + Province overlays

## Composition Patterns

### Button-Based Widgets
Most interactive widgets use Button as their foundation:

```lua
-- Pattern: Button + specialized behavior
local CheckButton = {
    button = Button:new(x, y, w, h, {text = label}),
    checked = false,
    onToggle = callback
}
```

### List-Based Widgets
Scrollable lists follow a consistent pattern:

```lua
-- Pattern: Container + Scrollbar + Items
local ListBox = {
    panel = Panel:new(x, y, w, h),
    scrollbar = Scrollbar:new(x + w - 20, y, 20, h),
    items = {},
    selectedIndex = nil
}
```

### Container-Based Widgets
Complex widgets use Panel as their base:

```lua
-- Pattern: Panel + child widgets + layout logic
local TabContainer = {
    panel = Panel:new(x, y, w, h),
    tabs = {}, -- array of Button widgets
    contentArea = Panel:new(x, y + 30, w, h - 30),
    activeTab = 1
}
```

## Implementation Guidelines

### Build Order
Implement widgets in dependency order to ensure all prerequisites exist:

1. **Start with Level 0**: Label, Icon, Button, Separator, Panel
2. **Build Level 1**: Composite widgets using Level 0
3. **Progress upward**: Each level builds on previous levels
4. **Test composition**: Verify widgets work together correctly

### Widget Creation Template
All widgets should follow this structure:

```lua
local WidgetName = {}
WidgetName.__index = WidgetName

function WidgetName:new(x, y, w, h, options)
    local obj = {
        -- Position and dimensions
        x = x, y = y, w = w, h = h,

        -- Child widgets (composition)
        childWidget = ChildWidget:new(...),

        -- Widget-specific properties
        -- ...

        -- Options and callbacks
        options = options or {},
        onEvent = options.onEvent
    }
    setmetatable(obj, self)
    return obj
end

function WidgetName:draw()
    -- Draw child widgets first
    if self.childWidget then
        self.childWidget:draw()
    end

    -- Draw widget-specific elements
    -- ...
end

function WidgetName:update(dt)
    -- Update child widgets
    if self.childWidget then
        self.childWidget:update(dt)
    end

    -- Update widget-specific logic
    -- ...
end

return WidgetName
```

### Event Propagation
Events should propagate from parent to child widgets:

```lua
function WidgetName:mousepressed(x, y, button)
    -- Check child widgets first (top to bottom Z-order)
    if self.childWidget and self.childWidget:mousepressed(x, y, button) then
        return true
    end

    -- Handle widget-specific events
    -- ...
end
```

## Key Architectural Principles

### 1. Composition over Inheritance
- Widgets are built by combining simpler widgets
- Avoid deep inheritance hierarchies
- Prefer "has-a" relationships over "is-a"

### 2. Consistent API
- All widgets follow the same initialization pattern: `new(x, y, w, h, options)`
- Event handling methods are standardized: `draw()`, `update(dt)`, `mousepressed()`, etc.
- Options tables provide flexible configuration

### 3. Grid Alignment
- All positioning and sizing aligns to the 20×20 pixel grid
- Ensures consistent visual spacing and alignment
- Simplifies responsive layout calculations

### 4. Theme Integration
- All visual elements use the centralized theme system
- Colors, fonts, and styles are configurable
- Supports runtime theme switching

### 5. Accessibility First
- Keyboard navigation support for all interactive widgets
- Screen reader compatibility
- High contrast mode support

## Missing Widgets Identified

During analysis, two basic widgets were found to be missing from the documentation:

### Scrollbar Widget
- **Purpose**: Scrollable control for content navigation
- **Dependencies**: None (fundamental)
- **Used by**: ListBox, TextArea, Table, ScrollPanel
- **Status**: Added to BasicInteractive.md

### Window Widget
- **Purpose**: Movable/resizable container for dialogs
- **Dependencies**: Panel, Button, Label
- **Used by**: Modal dialogs, popup windows
- **Status**: Added to BasicInteractive.md

## Testing Strategy

### Unit Testing
- Test each widget in isolation
- Verify composition works correctly
- Test event propagation and handling

### Integration Testing
- Test widget combinations
- Verify layout and positioning
- Test interaction between widgets

### Visual Testing
- Ensure grid alignment is maintained
- Verify theme application
- Test different screen resolutions

## Performance Considerations

### Rendering Optimization
- Use batch operations for multiple widgets
- Implement viewport culling for large lists
- Cache rendered elements when possible

### Memory Management
- Reuse widget instances when possible
- Implement proper cleanup for removed widgets
- Monitor memory usage in complex scenes

### Event Handling Efficiency
- Use event bubbling instead of polling
- Implement efficient hit testing
- Avoid unnecessary event processing

## Future Extensions

### Planned Enhancements
- **Animation System**: Smooth transitions between widget states
- **Layout Managers**: Automatic positioning and sizing
- **Data Binding**: Automatic UI updates from data changes
- **Internationalization**: Enhanced text handling for multiple languages

### Potential New Widgets
- **TreeView**: Hierarchical data display (uses ListBox + expand/collapse)
- **PropertyGrid**: Key-value pair editor
- **Chart**: Data visualization widget
- **Calendar**: Date selection interface

This architecture ensures that AlienFall's UI system remains maintainable, extensible, and consistent while providing the complex interfaces needed for strategic gameplay.