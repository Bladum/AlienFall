# Navigation Widgets

Interface navigation and selection components.

## Overview

Navigation widgets enable users to browse, select, and navigate through game interfaces and data.

## Files

### menubar.lua
Horizontal menu bar with dropdown menus.

### tabbar.lua
Tabbed navigation interface.

### listbox.lua
Scrollable list with selection.

### treeview.lua
Hierarchical tree navigation.

### breadcrumb.lua
Navigation path display.

## Usage

```lua
local ListBox = require("widgets.navigation.listbox")

local missionList = ListBox:new({
    x = 24, y = 24,
    width = 192, height = 240,
    items = {"Intercept UFO", "Ground Assault", "Terror Mission"},
    onSelect = function(index, item)
        selectMission(item)
    end
})

-- Tabbed interface
local TabBar = require("widgets.navigation.tabbar")
local tabs = TabBar:new({
    x = 24, y = 288,
    width = 384, height = 24,
    tabs = {"Geoscape", "Basescape", "Research"},
    onTabChange = function(tabIndex)
        switchScreen(tabIndex)
    end
})
```

## Features

- **Menu Systems**: Hierarchical command organization
- **Tabbed Interfaces**: Multi-panel navigation
- **List Selection**: Single and multi-select lists
- **Tree Navigation**: Folder-like data browsing
- **Breadcrumb Trails**: Navigation context

## Interaction Patterns

- **Keyboard Navigation**: Arrow keys and shortcuts
- **Mouse Selection**: Click and drag operations
- **Search**: Filter and find functionality
- **Accessibility**: Screen reader navigation

## Dependencies

- **BaseWidget**: Grid positioning and events
- **Theme System**: Navigation styling
- **Data Sources**: Content for lists and trees