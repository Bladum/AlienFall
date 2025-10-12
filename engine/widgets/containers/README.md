# Container Widgets

Layout and grouping components for UI organization.

## Overview

Container widgets provide layout management and visual grouping for organizing other UI elements.

## Files

### panel.lua
Basic container with background and border.

### scrollpanel.lua
Scrollable container for content larger than display area.

### tabpanel.lua
Tabbed interface with multiple content panels.

### groupbox.lua
Labeled grouping container with title.

### layout.lua
Automatic layout management utilities.

## Usage

```lua
local Panel = require("widgets.containers.panel")

local controlPanel = Panel:new({
    x = 24, y = 24,
    width = 192, height = 240,
    title = "Mission Control"
})

-- Add child widgets
controlPanel:addChild(deployButton)
controlPanel:addChild(statusLabel)

-- Scroll panel for long lists
local ScrollPanel = require("widgets.containers.scrollpanel")
local missionList = ScrollPanel:new({
    x = 240, y = 24,
    width = 144, height = 288,
    contentHeight = 480  -- Scrollable content
})
```

## Features

- **Layout Management**: Automatic positioning of child widgets
- **Scrolling**: Vertical and horizontal scroll support
- **Tabbed Interfaces**: Multiple content areas with tabs
- **Visual Grouping**: Borders, backgrounds, and titles
- **Event Propagation**: Input events to child widgets

## Layout System

Containers use grid-based layout:
- **Absolute**: Manual positioning
- **Flow**: Automatic horizontal/vertical flow
- **Grid**: Table-like positioning
- **Anchor**: Relative positioning

## Dependencies

- **BaseWidget**: Grid positioning and event handling
- **Theme System**: Container styling
- **Child Widgets**: Contained UI elements