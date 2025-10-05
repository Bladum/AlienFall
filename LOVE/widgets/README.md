# LÖVE Widget Library for Tactical/Strategy Games

A comprehensive, professional-grade widget library for LÖVE (Love2D) designed specifically for tactical and strategy games like OpenXCOM. This library provides a complete UI toolkit with theming, accessibility, focus management, and specialized widgets for game interfaces.

## Overview

This widget library offers over 60+ UI components optimized for strategy games, including tactical displays, base management interfaces, research systems, soldier management, manufacturing, geoscape interfaces, and specialized widgets for mission generation, base defense, research tracking, and soldier development. All widgets inherit from a common base class and integrate seamlessly with the theming and animation systems.

### Key Features

- **Tactical Game Optimized**: Specialized widgets for unit panels, action bars, mini-maps, and turn indicators
- **Base Building Support**: Facility panels, research interfaces, soldier rosters, and manufacturing systems
- **Geoscape Integration**: World map with UFO tracking and mission planning
- **Accessibility First**: Full keyboard navigation, screen reader support, and customizable themes
- **Professional Theming**: Multiple built-in themes (default, dark, high-contrast) with easy customization
- **Animation System**: Smooth transitions and effects for polished UI interactions
- **Drag & Drop**: Built-in drag-and-drop system for inventory and tactical interfaces
- **Validation**: Input validation and error handling for robust user interfaces

## Getting Started

### Installation

1. Copy the `widgets/` folder into your LÖVE project
2. Require the main widget module:
```lua
local widgets = require('widgets')
```

### Basic Usage

```lua
local widgets = require('widgets')

function love.load()
    -- Create a button
    local button = widgets.Button:new(100, 100, 200, 50, "Start Game", function()
        print("Game started!")
    end)
    
    -- Create a unit panel for tactical games
    local unitPanel = widgets.UnitPanel:new(50, 200, 300, 400, unitData)
end

function love.update(dt)
    widgets.core.update(dt)
end

function love.draw()
    widgets.core.draw()
end
```

## Theming

The library includes a comprehensive theming system with multiple built-in themes:

```lua
-- Set a theme
widgets.core.theme.setTheme("dark")

-- Customize theme colors
widgets.core.theme.primary = {0.2, 0.6, 1.0}
widgets.core.theme.background = {0.1, 0.1, 0.15}
```

### Built-in Themes

- **default**: Clean, professional appearance
- **dark**: Dark theme for extended gaming sessions
- **highContrast**: Accessibility-focused high contrast theme

## Core Systems

### Base Widget Class

All widgets inherit from `core.Base`, providing:
- Position and size management
- Focus and keyboard navigation
- Theming integration
- Accessibility support
- Child widget management

### Focus Management

```lua
-- Enable focus management
widgets.core.focus.enable()

-- Navigate between widgets
if love.keyboard.isDown("tab") then
    widgets.core.focus.next()
end
```

### Animation System

```lua
-- Animate a widget property
widgets.Animation.create(widget, "x", 100, 200, 1.0, "ease_out", function()
    print("Animation complete!")
end)

-- Update animations in love.update
widgets.Animation.update(dt)
```

## Widget Reference

### Core Widgets

#### Button
Interactive button with multiple styles and states.
```lua
local button = widgets.Button:new(x, y, w, h, text, callback, options)
```

#### Label
Text display widget with styling options.
```lua
local label = widgets.Label:new(x, y, w, h, text, options)
```

#### TextInput
Text input field with validation and autocomplete.
```lua
local input = widgets.TextInput:new(x, y, w, h, placeholder, options)
```

### Tactical Game Widgets

#### UnitPanel
Display unit information, stats, and equipment.
```lua
local unitPanel = widgets.UnitPanel:new(x, y, w, h, unitData, options)
```

#### ActionBar
Display unit abilities and actions with cooldowns.
```lua
local actionBar = widgets.ActionBar:new(x, y, w, h, options)
```

#### MiniMap
Tactical mini-map with unit positions and terrain.
```lua
local miniMap = widgets.MiniMap:new(x, y, w, h, mapData, options)
```

#### TurnIndicator
Show current turn, phase, and time remaining.
```lua
local turnIndicator = widgets.TurnIndicator:new(x, y, w, h, turnData, options)
```

### Base Building Widgets

#### BaseFacilityPanel
Manage base facilities like radar, workshops, and living quarters.
```lua
local facilityPanel = widgets.BaseFacilityPanel:new(x, y, w, h, facility, options)
```

#### ResearchPanel
Display research progress and tech tree.
```lua
local researchPanel = widgets.ResearchPanel:new(x, y, w, h, researchData, options)
```

#### ManufacturePanel
Manage manufacturing queues and production facilities.
```lua
local manufacturePanel = widgets.ManufacturePanel:new(x, y, w, h, facilities, options)
```

#### SoldierRoster
Manage soldier assignments, stats, and training.
```lua
local soldierRoster = widgets.SoldierRoster:new(x, y, w, h, soldiers, options)
```

### Geoscape Widgets

#### Geoscape
Interactive world map with UFO tracking and mission planning.
```lua
local geoscape = widgets.Geoscape:new(x, y, w, h, worldData, options)
```

### UI Components

#### Dialog
Modal/non-modal dialog windows.
```lua
local dialog = widgets.Dialog:new(title, content, options)
```

#### ProgressBar
Progress indicators with customizable appearance.
```lua
local progress = widgets.ProgressBar:new(x, y, w, h, options)
```

#### Chart
Data visualization with multiple chart types.
```lua
local chart = widgets.Chart:new(x, y, w, h, chartType, data, options)
```

### Specialized Widgets

#### AlertSystem
Notification system for game alerts.
```lua
local alerts = widgets.AlertSystem:new(options)
```

#### TechTree
Technology tree visualization.
```lua
local techTree = widgets.TechTree:new(x, y, w, h, techData, options)
```

#### MissionDebrief
Post-mission analysis and statistics display.
```lua
local debrief = widgets.MissionDebrief:new(x, y, w, h, missionResult, options)
```

#### UFOTracker
Detailed UFO monitoring and threat assessment.
```lua
local ufoTracker = widgets.UFOTracker:new(x, y, w, h, ufoData, options)
```

#### SoldierTraining
Soldier skill development and specialization.
```lua
local training = widgets.SoldierTraining:new(x, y, w, h, soldier, options)
```

#### ResearchTracker
Research progress monitoring and scientist allocation.
```lua
local researchTracker = widgets.ResearchTracker:new(x, y, w, h, researchData, options)
```

#### BaseDefense
Base security systems and patrol management.
```lua
local baseDefense = widgets.BaseDefense:new(x, y, w, h, defenseData, options)
```

#### MissionGenerator
Mission creation and customization tools.
```lua
local missionGen = widgets.MissionGenerator:new(x, y, w, h, options)
```

#### SoldierStats
Detailed soldier performance and development tracking.
```lua
local soldierStats = widgets.SoldierStats:new(x, y, w, h, soldier, options)
```

## Accessibility

The library includes comprehensive accessibility features:

- **Keyboard Navigation**: Full keyboard support for all interactive widgets
- **Screen Reader Support**: Accessibility announcements for state changes
- **High Contrast Themes**: Built-in high contrast theme for visibility
- **Focus Indicators**: Clear visual focus indicators
- **Customizable Hints**: Configurable accessibility hints and labels

```lua
-- Enable accessibility
widgets.core.config.enableAccessibility = true

-- Set custom accessibility labels
button.accessibilityLabel = "Start new tactical mission"
button.accessibilityHint = "Press enter to begin the mission"
```

## Integration Examples

### OpenXCOM-Style Interface

```lua
local widgets = require('widgets')

function createXCOMInterface()
    -- Main geoscape view
    local geoscape = widgets.GeoScape:new(0, 0, 800, 600, worldData)
    
    -- Base management panel
    local basePanel = widgets.BaseFacilityPanel:new(820, 50, 400, 500, baseData)
    
    -- Research panel
    local researchPanel = widgets.ResearchPanel:new(820, 570, 400, 300, researchData)
    
    -- Soldier roster
    local soldierRoster = widgets.SoldierRoster:new(10, 620, 800, 400, soldiers)
    
    -- Manufacturing panel
    local manufacturePanel = widgets.ManufacturePanel:new(10, 1030, 800, 300, facilities)
end
```

### Tactical Combat Interface

```lua
function createTacticalInterface()
    -- Unit action bar
    local actionBar = widgets.ActionBar:new(50, 500, 700, 80, {
        actions = unitActions,
        orientation = "horizontal"
    })
    
    -- Unit panels for squad
    local unitPanels = {}
    for i, unit in ipairs(squad) do
        unitPanels[i] = widgets.UnitPanel:new(750, 50 + (i-1)*120, 250, 100, unit)
    end
    
    -- Mini-map
    local miniMap = widgets.MiniMap:new(750, 450, 250, 200, battleMap)
    
    -- Turn indicator
    local turnIndicator = widgets.TurnIndicator:new(50, 20, 200, 40, turnData)
    
    return {actionBar, miniMap, turnIndicator, unpack(unitPanels)}
end
```

### Research Management Interface

```lua
function createResearchInterface()
    -- Research tracker for project monitoring
    local researchTracker = widgets.ResearchTracker:new(10, 10, 600, 400, researchData)
    
    -- Tech tree for technology progression
    local techTree = widgets.TechTree:new(620, 10, 400, 400, techData)
    
    -- Scientist allocation panel
    local scientistPanel = widgets.SoldierRoster:new(10, 420, 600, 200, scientists, {
        filter = "scientists"
    })
    
    return {researchTracker, techTree, scientistPanel}
end
```

### Base Defense System

```lua
function createBaseDefenseInterface()
    -- Base defense management
    local baseDefense = widgets.BaseDefense:new(10, 10, 500, 350, defenseData)
    
    -- Patrol route assignment
    local patrolPanel = widgets.SoldierRoster:new(520, 10, 300, 350, soldiers, {
        filter = "available"
    })
    
    -- Threat detection alerts
    local alertSystem = widgets.AlertSystem:new({
        position = "top-right",
        maxAlerts = 5
    })
    
    return {baseDefense, patrolPanel, alertSystem}
end
```

### Mission Planning Interface

```lua
function createMissionPlanningInterface()
    -- Mission generator for creating custom missions
    local missionGen = widgets.MissionGenerator:new(10, 10, 400, 300)
    
    -- Soldier selection for mission assignment
    local soldierSelect = widgets.SoldierRoster:new(420, 10, 400, 300, soldiers)
    
    -- Mission briefing preview
    local briefing = widgets.MissionBriefing:new(10, 320, 810, 280, missionData)
    
    return {missionGen, soldierSelect, briefing}
end
```

### Soldier Development Interface

```lua
function createSoldierDevelopmentInterface()
    -- Detailed soldier statistics
    local soldierStats = widgets.SoldierStats:new(10, 10, 400, 500, selectedSoldier)
    
    -- Training management
    local training = widgets.SoldierTraining:new(420, 10, 400, 300, selectedSoldier)
    
    -- Equipment assignment
    local equipment = widgets.InventoryGrid:new(420, 320, 400, 190, soldierEquipment)
    
    return {soldierStats, training, equipment}
end
```

## API Reference

### Core Module

#### widgets.core.Base
Base class for all widgets.

**Methods:**
- `new(x, y, w, h)`: Create new widget instance
- `update(dt)`: Update widget state
- `draw()`: Render widget
- `addChild(child)`: Add child widget
- `removeChild(child)`: Remove child widget

#### widgets.core.theme
Theming system.

**Methods:**
- `setTheme(name)`: Set active theme
- `getTheme()`: Get current theme
- `customizeTheme(colors)`: Customize theme colors

#### widgets.core.focus
Focus management system.

**Methods:**
- `enable()`: Enable focus management
- `disable()`: Disable focus management
- `next()`: Move focus to next widget
- `previous()`: Move focus to previous widget

### Widget-Specific APIs

Each widget has its own API documented in its source file header. Key widgets include:

- **Button**: Click handling, styling, loading states
- **UnitPanel**: Unit stats, equipment, status display
- **InventoryGrid**: Item management, drag-and-drop
- **ActionBar**: Ability display, cooldowns, categories
- **MiniMap**: Terrain rendering, unit positions
- **BaseFacilityPanel**: Facility management, construction
- **ResearchPanel**: Research progress, tech tree navigation
- **SoldierRoster**: Soldier management and assignments
- **ManufacturePanel**: Production queue and facility management
- **Geoscape**: World map and UFO tracking
- **MissionDebrief**: Post-mission analysis and statistics
- **UFOTracker**: UFO monitoring and threat assessment
- **SoldierTraining**: Skill development and specialization
- **ResearchTracker**: Research progress and scientist allocation
- **BaseDefense**: Base security and patrol management
- **MissionGenerator**: Mission creation and customization
- **SoldierStats**: Detailed soldier performance tracking

## 🚀 Potential New Widgets

Based on analysis of the current library, here are potential new widgets that could enhance tactical/strategy game development:

### Advanced Tactical Widgets
- **FormationEditor** - Squad formation planning and unit positioning
- **TacticalOverlay** - Range indicators, line-of-sight visualization, cover analysis
- **CommandChain** - Chain of command visualization and officer management
- **MoraleMeter** - Unit morale tracking with visual feedback
- **SuppressionSystem** - Suppression effects and panic state management

### Enhanced Base Management
- **PowerGrid** - Electrical system management and power distribution
- **SupplyChain** - Resource logistics and supply route management
- **PersonnelManagement** - Detailed staff assignment and rotation
- **SecuritySystem** - Base security monitoring and alarm management
- **ExpansionPlanner** - Base expansion planning and construction phases

### Geoscape Enhancements
- **WeatherSystem** - Weather effects on mission success and UFO detection
- **DiplomacyInterface** - International relations and funding management
- **SatelliteNetwork** - Satellite deployment and coverage visualization
- **TerrorTracker** - Terror mission monitoring and prevention
- **HyperwaveDecoder** - Alien communications interception and analysis

### Research & Development
- **LabSimulator** - Research project simulation and outcome prediction
- **TechDatabase** - Technology tree exploration and prerequisite visualization
- **AlienContainment** - Captured alien management and interrogation
- **ProvingGround** - Weapon testing and performance analysis
- **ArchiveSystem** - Mission debrief archive and historical data analysis

### Multiplayer Support
- **MultiplayerLobby** - Player matchmaking and game setup
- **Scoreboard** - Real-time scoring and leaderboard management
- **ChatSystem** - In-game communication with tactical commands
- **SpectatorMode** - Observer interface for watching games
- **ReplaySystem** - Mission replay and analysis tools

## 📊 Performance Considerations

For optimal performance in tactical games:

### Memory Management
```lua
-- Reuse widget instances instead of creating new ones
local unitPanelPool = {}
function getUnitPanel(unit)
    local panel = table.remove(unitPanelPool) or widgets.UnitPanel:new(0, 0, 200, 300)
    panel:setUnit(unit)
    return panel
end
```

### Update Optimization
```lua
-- Only update visible widgets
function love.update(dt)
    for _, widget in ipairs(visibleWidgets) do
        widget:update(dt)
    end
end
```

### Rendering Optimization
```lua
-- Use scissor for large UI areas
love.graphics.setScissor(x, y, w, h)
widgets.draw()
love.graphics.setScissor()
```

## 🎯 Enhanced Widget Documentation

Recent improvements have enhanced comments in key widgets with detailed OpenXCOM-specific context:

### Core System Widgets
- **`actionbar.lua`** - Unit ability selection with action point systems and turn limits
- **`alertsystem.lua`** - Mission-critical notifications for tactical decision-making
- **`animation.lua`** - Smooth transitions for unit movements and UI feedback
- **`autocomplete.lua`** - Fast selection from large soldier/research datasets
- **`calendar.lua`** - Timeline management for mission planning and research scheduling
- **`chart.lua`** - Real-time data visualization for tactical analysis

### Integration Patterns

#### Real-time Tactical Updates
```lua
-- Alert system for mission events
local alertSystem = widgets.AlertSystem:new({
    position = "top-right",
    maxAlerts = 5
})

-- Auto-complete for soldier selection
local soldierSelect = widgets.AutoComplete:new(x, y, w, h, "Select soldier...", {
    suggestions = soldierNames,
    fuzzyMatch = true,
    onSuggestionSelect = function(soldierName)
        selectSoldier(soldierName)
    end
})
```

#### Animated UI Transitions
```lua
-- Smooth unit movement animations
widgets.Animation.create(unitSprite, "x", currentX, targetX, 0.5, "ease_out", function()
    unit.movementComplete = true
    alertSystem:addAlert("SUCCESS", "Unit Moved", "Movement completed successfully")
end)

-- Chart updates for research progress
local researchChart = widgets.Chart:new(x, y, w, h, "line", researchData, {
    animateOnLoad = true,
    title = "Research Progress Over Time"
})
```

#### Timeline-based Mission Planning
```lua
-- Calendar for scheduling operations
local missionCalendar = widgets.Calendar:new(x, y, w, h, {
    selectedDate = missionDate,
    onDateSelect = function(date)
        scheduleMission(date)
    end
})
```

All widgets follow a consistent lifecycle:

- **new()**: Constructor, sets up properties and components.
- **update(dt)**: Called every frame for animations and state updates.
- **draw()**: Renders the widget.
- **mousepressed/mousereleased/mousemoved**: Input handling.
- **keypressed/keyreleased**: Keyboard input.
- **focusGained/focusLost**: Focus management.

## Theming

Widgets use `core.theme` for colors and fonts. Available themes:
- `default`: Light theme
- `dark`: Dark theme  
- `highContrast`: High contrast for accessibility

Switch themes at runtime:
```lua
widgets.Theme.setTheme('dark')
```

## Accessibility

The library includes comprehensive accessibility support:
- Screen reader announcements
- Keyboard navigation
- High contrast mode
- Focus indicators

Enable accessibility:
```lua
widgets.Core.config.enableAccessibility = true
widgets.Core.config.enableKeyboardNavigation = true
```

## Focus Management

Widgets can be focusable for keyboard navigation:
```lua
widgets.Core.registerFocusableWidget(myWidget)
```

Navigate with Tab/Shift+Tab, activate with Space/Enter.

## Creating Custom Widgets

Extend `core.Base`:
```lua
local MyWidget = {}
MyWidget.__index = MyWidget
setmetatable(MyWidget, {__index = widgets.Core.Base})

function MyWidget:new(x, y, w, h, options)
    local obj = widgets.Core.Base.new(self, x, y, w, h)
    -- Custom initialization
    return obj
end

function MyWidget:draw()
    -- Custom drawing
end
```

## Integration with Games

For tactical/strategy games:

1. Use `UnitPanel` for unit information
2. `ActionBar` for ability selection
3. `TurnIndicator` for turn management
4. `MiniMap` for tactical overview
5. `InventoryGrid` for item management
6. `AlertSystem` for notifications

Example mission screen:
```lua
local briefing = widgets.MissionBriefing:new(50, 50, 700, 500, missionData)
local actionBar = widgets.ActionBar:new(50, 570, 700, 50, {actions = unitActions})
```

## API Reference

### Core

- `core.config`: Global configuration
- `core.theme`: Current theme colors/fonts
- `core.focus`: Focus management
- `core.accessibility`: Accessibility features
- `core.registerFocusableWidget(widget)`: Register for focus
- `core.announce(text)`: Screen reader announcement

### Common Widget Properties

- `x, y, w, h`: Position and size
- `enabled`: Whether interactive
- `visible`: Whether drawn
- `focusable`: Whether can receive focus
- `onClick, onChange, etc.`: Event callbacks

### Common Widget Methods

- `update(dt)`: Update state
- `draw()`: Render
- `mousepressed(x, y, button)`: Mouse input
- `keypressed(key)`: Keyboard input

## Contributing

When adding new widgets:
1. Inherit from `core.Base`
2. Use `core.theme` for styling
3. Support accessibility and focus
4. Add to `init.lua` modules list
5. Document in this README

## License

This widget library is provided as-is for use in LÖVE projects.
