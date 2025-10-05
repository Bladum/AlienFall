# Love2D Widget Library Analysis

This document provides a comprehensive analysis of the Love2D widget library for tactical/strategy games. Each widget is listed with a brief description and markdown hyperlink to the source file.

## Core Files

- **[core.lua](core.lua)**: Core subsystem providing foundational services for all UI components, including configuration, theming, focus management, and accessibility hooks.
- **[init.lua](init.lua)**: Widget system initialization and module loader for centralized loading and access to all UI widgets.
- **[theme.lua](theme.lua)**: Unified theming system providing centralized theme definitions, runtime theme switching, and smooth transitions for consistent UI styling.
- **[rangeslider.lua](rangeslider.lua)**: Range slider widget with dual handles for selecting numeric ranges with dragging, snapping, and animations.

## Documentation

- **[docstring_template.md](docstring_template.md)**: Template defining the standard format for documentation in all widget files.

## AlienFall-Specific Widgets

These widgets are specialized for the AlienFall tactical strategy game, providing interfaces for geoscape, battlescape, base management, and research systems.

### Action and Command Widgets
- **[actionbar.lua](alienfall/actionbar.lua)**: Unit ability and action selection interface for tactical combat with cooldowns, costs, and visual feedback.
- **[commandpanel.lua](alienfall/commandpanel.lua)**: Command panel for tactical operations and unit control in battlescape interfaces.

### Base Management Widgets
- **[basefacilitypanel.lua](alienfall/basefacilitypanel.lua)**: Comprehensive interface for managing base facilities, construction, and maintenance with progress tracking.
- **[baselayout.lua](alienfall/baselayout.lua)**: Base layout management for facility placement and base organization.
- **[manufacturepanel.lua](alienfall/manufacturepanel.lua)**: Manufacturing panel for production queues and resource management.
- **[resourcebar.lua](alienfall/resourcebar.lua)**: Resource tracking and display for base management and economy.

### Research and Technology Widgets
- **[research_tracker.lua](alienfall/research_tracker.lua)**: Research progress tracking and scientist allocation interface.
- **[researchpanel.lua](alienfall/researchpanel.lua)**: Comprehensive research project management with progress bars and tech tree navigation.

### Soldier Management Widgets
- **[soldier_stats.lua](alienfall/soldier_stats.lua)**: Soldier statistics display and management interface.
- **[soldier_training.lua](alienfall/soldier_training.lua)**: Soldier training and development tracking system.
- **[soldierroster.lua](alienfall/soldierroster.lua)**: Comprehensive soldier roster management with assignments, stats, and equipment.

### Geoscape and Mission Widgets
- **[geoscape.lua](alienfall/geoscape.lua)**: Interactive world map for UFO tracking, interceptor management, and mission planning.
- **[interception.lua](alienfall/interception.lua)**: Interception management for UFO engagement and defense operations.
- **[mission_generator.lua](alienfall/mission_generator.lua)**: Mission generation and briefing system.
- **[missionbriefing.lua](alienfall/missionbriefing.lua)**: Mission briefing display with objectives and intelligence.
- **[missiondebrief.lua](alienfall/missiondebrief.lua)**: Mission debriefing interface with results and statistics.
- **[ufo_tracker.lua](alienfall/ufo_tracker.lua)**: UFO monitoring and analysis interface with real-time tracking and threat assessment.

### Battlescape Widgets
- **[battlescape.lua](alienfall/battlescape.lua)**: Comprehensive tactical combat interface displaying units, terrain, and real-time battle management.
- **[alertsystem.lua](alienfall/alertsystem.lua)**: Alert system for tactical notifications and status updates.

## Common Widgets

Basic UI components providing fundamental interactive elements for game interfaces.

### Basic Input Widgets
- **[button.lua](common/button.lua)**: Interactive button with rich styling, accessibility, and multiple visual variants for game interfaces.
- **[imagebutton.lua](common/imagebutton.lua)**: Image-based button with hover/press states for visual navigation and action triggers.
- **[togglebutton.lua](common/togglebutton.lua)**: Toggle button maintaining persistent on/off state for settings and preferences.
- **[label.lua](common/label.lua)**: Versatile text display with rich formatting, animation, and interaction capabilities.
- **[textinput.lua](common/textinput.lua)**: Advanced text input with validation, autocomplete, masking, and accessibility features.
- **[textarea.lua](common/textarea.lua)**: Basic multi-line text editing with cursor movement and navigation.
- **[spinner.lua](common/spinner.lua)**: Numeric spinner with increment/decrement controls for precise value input.

### Selection Widgets
- **[checkbox.lua](common/checkbox.lua)**: Checkbox with binary/indeterminate states, animations, and group behaviors.
- **[radiobutton.lua](common/radiobutton.lua)**: Radio button for exclusive selection within groups.
- **[dropdown.lua](common/dropdown.lua)**: Simple dropdown selection from predefined lists.
- **[combobox.lua](common/combobox.lua)**: Combobox with dropdown selection and basic search functionality.
- **[listbox.lua](common/listbox.lua)**: Scrollable list with selection support for item lists.
- **[menu.lua](common/menu.lua)**: Basic vertical menu with selectable items and mouse interaction.

### Layout and Container Widgets
- **[panel.lua](common/panel.lua)**: Versatile container with layout management, collapsible sections, and scrolling.
- **[window.lua](common/window.lua)**: Movable, resizable floating container with title bars and modal functionality.
- **[dialog.lua](common/dialog.lua)**: Modal/non-modal interaction windows with customizable content and button layouts.
- **[container.lua](common/container.lua)**: Basic container widget for grouping child widgets.
- **[tab.lua](common/tab.lua)**: Single tab for tabbed interfaces with activation state management.
- **[tabcontainer.lua](common/tabcontainer.lua)**: Tab container managing multiple content panels with tab navigation.
- **[tabwidget.lua](common/tabwidget.lua)**: Tab widget managing tabbed interfaces with content switching.

### Progress and Display Widgets
- **[progressbar.lua](common/progressbar.lua)**: Progress bar with animations, multiple orientations, and visual effects.
- **[slider.lua](common/slider.lua)**: Versatile slider for numeric input with single/range selection and rich customization.
- **[table.lua](common/table.lua)**: Virtualized grid with sorting, filtering, and editing capabilities.

### Utility and Support Widgets
- **[scrollbar.lua](common/scrollbar.lua)**: Vertical/horizontal scrolling with draggable thumb.
- **[tooltip.lua](common/tooltip.lua)**: Tooltip system for contextual information display with animations.
- **[tooltip_manager.lua](common/tooltip_manager.lua)**: Tooltip manager for global tooltip coordination.
- **[validation.lua](common/validation.lua)**: Validation utilities for form widgets and input validation.

### Mixins and Helpers
- **[autocomplete_mixin.lua](common/autocomplete_mixin.lua)**: Mixin providing autocomplete behavior for text widgets.
- **[interactive_mixin.lua](common/interactive_mixin.lua)**: Mixin providing interactive helpers for hover/press/focus tracking.
- **[emmy_types.lua](common/emmy_types.lua)**: EmmyLua type stubs for Love2D types to help static analyzers.

### Documentation and Analysis
- **[audit_annotations.json](common/audit_annotations.json)**: Audit report on documentation coverage and standardization.
- **[docstring_feature_analysis.md](common/docstring_feature_analysis.md)**: Analysis of widget features and commonization opportunities.
- **[docstring_standardization_report.md](common/docstring_standardization_report.md)**: Report on docstring standardization recommendations.

## Complex Widgets

Advanced UI components providing sophisticated functionality for complex game interfaces.

### Tactical and Strategy Widgets
- **[minimap.lua](complex/minimap.lua)**: Compact tactical overview with fog of war, unit markers, and interactive navigation.
- **[unitpanel.lua](complex/unitpanel.lua)**: Display panel for tactical units showing stats, abilities, and status effects.
- **[turnindicator.lua](complex/turnindicator.lua)**: Turn-based game state display with timers and player information.
- **[statuseffect.lua](complex/statuseffect.lua)**: Visual representation of temporary unit conditions and buffs/debuffs.

### Data Visualization Widgets
- **[chart.lua](complex/chart.lua)**: Comprehensive charting for data visualization in strategy games.
- **[calendar.lua](complex/calendar.lua)**: Interactive calendar for date selection and timeline management.

### Inventory and Management Widgets
- **[inventory.lua](complex/inventory.lua)**: Simple grid-based inventory for item management.
- **[inventorygrid.lua](complex/inventorygrid.lua)**: Advanced grid-based inventory with drag-and-drop functionality.

### Layout and Interaction Widgets
- **[layout.lua](complex/layout.lua)**: Advanced layout management system for widget arrangement.
- **[dragdrop.lua](complex/dragdrop.lua)**: Drag-and-drop system for reusable drag-and-drop functionality.
- **[radialmenu.lua](complex/radialmenu.lua)**: Circular context menu for rapid action selection in tactical games.

### Map and Grid Widgets
- **[gridmap.lua](complex/gridmap.lua)**: Grid-based map display for tactical games with tile rendering.
- **[tilemap.lua](complex/tilemap.lua)**: Multi-layer tile grid management for level editors and tactical maps.

### Node and Graph Widgets
- **[node.lua](complex/node.lua)**: Graph node widget for node-based editors with input/output ports.
- **[nodegraph.lua](complex/nodegraph.lua)**: Node canvas for visual node-based editing and graph management.

### Tree and Hierarchical Widgets
- **[treeview.lua](complex/treeview.lua)**: Tree view for hierarchical data display with expansion/collapse.
- **[techtree.lua](complex/techtree.lua)**: Interactive visualization of research trees with dependencies.

### Utility Widgets
- **[animation.lua](complex/animation.lua)**: Animation system for smooth transitions and visual effects.
- **[autocomplete.lua](complex/autocomplete.lua)**: Advanced autocomplete widget with fuzzy matching.
- **[colorpicker.lua](complex/colorpicker.lua)**: Color palette widget for color selection.

## Test Files

- **[test_container.lua](common/tests/test_container.lua)**: Smoke test for container widget functionality.
- **[test_autocomplete_mixin.lua](common/tests/test_autocomplete_mixin.lua)**: Smoke test for autocomplete mixin.
- **[README.md](common/tests/README.md)**: Documentation for test files and running instructions.
