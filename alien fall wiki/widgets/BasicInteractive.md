---
title: Basic Interactive Widgets
summary: Fundamental UI controls for standard user interactions in AlienFall
tags:
  - gui
  - widgets
  - basic
  - interactive
  - love2d
---

# Basic Interactive Widgets

This document provides comprehensive specifications for the 20 basic interactive widgets that form the foundation of AlienFall's user interface. These widgets handle standard user interactions and are designed for maximum reusability across different game screens.

## Table of Contents
- [Overview](#overview)
- [Button Widget](#button-widget)
- [ImageButton Widget](#imagebutton-widget)
- [CheckButton Widget](#checkbox-widget)
- [RadioButton Widget](#radiobutton-widget)
- [ComboBox Widget](#combobox-widget)
- [ListBox Widget](#listbox-widget)
- [TextInput Widget](#textinput-widget)
- [TextArea Widget](#textarea-widget)
- [Table Widget](#table-widget)
- [ItemList Widget](#itemlist-widget)
- [Label Widget](#label-widget)
- [Slider Widget](#slider-widget)
- [Spinner Widget](#spinner-widget)
- [ToggleButton Widget](#togglebutton-widget)
- [Separator Widget](#separator-widget)
- [StatusBar Widget](#statusbar-widget)
- [Icon Widget](#icon-widget)
- [Badge Widget](#badge-widget)
- [Scrollbar Widget](#scrollbar-widget)
- [Window Widget](#window-widget)
- [Implementation Notes](#implementation-notes)

## Overview

Basic interactive widgets provide the fundamental building blocks for user interaction in AlienFall. Each widget is designed with the following principles:

- **Grid-Aligned**: All positioning and sizing adheres to the 20×20 pixel logical grid
- **Accessible**: Full keyboard navigation and screen reader support
- **Consistent**: Unified visual styling and interaction patterns
- **Performant**: Optimized rendering and memory usage
- **Localizable**: All text content supports internationalization

## Button Widget

### Purpose
The Button widget serves as the primary interaction element for all user actions across AlienFall's interface. It provides clear visual feedback and supports various action types.

### Key Features

#### Grid Snapping
- Size and position constrained to 20×20 pixel increments
- Minimum size: 40×40 pixels (2×2 grid units)
- Ensures pixel-perfect alignment across all screen resolutions

#### Visual States
- **Normal**: Default appearance with subtle background
- **Hover**: Highlighted background and border for mouse interaction
- **Pressed**: Inset appearance with darker colors for click feedback
- **Disabled**: Grayed out with reduced opacity and blocked interaction
- **Focused**: Keyboard focus indicator with dotted border

#### Icon Support
- 20×20 pixel icon sprites positioned left/center/right
- Automatic text layout adjustment based on icon placement
- Support for animated icons and state-specific variations

#### Text Rendering
- Single or multi-line text with configurable font size (8-16pt)
- Left, center, right, and justified alignment options
- Automatic text wrapping for longer button labels
- Font weight and style customization

#### Accessibility Features
- Keyboard navigation with Tab order and Enter/Space activation
- Screen reader labels with descriptive text
- High contrast mode support for visual impairments
- Focus management with proper tab ordering

### Game-Specific Usage
- Primary action buttons in battlescape (Move, Attack, Overwatch)
- Menu navigation and screen transitions
- Confirmation dialogs and modal actions
- Quick action shortcuts in strategic interfaces

### Implementation Details
```lua
-- Example usage
local button = Button:new(x, y, width, height, {
    text = "Confirm Action",
    icon = "confirm_icon",
    iconPosition = "left",
    onClick = function() handleConfirmation() end,
    enabled = true,
    tooltip = "Click to confirm this action"
})
```

## ImageButton Widget

### Purpose
Specialized button widget optimized for icon-heavy interfaces where visual recognition is more important than text labels.

### Key Features

#### Sprite-Based Design
- Uses 20×20 pixel icon sprites with hover/press state variations
- Supports sprite sheets with multiple states per button
- Automatic state transitions with smooth animations

#### Tooltip Integration
- Mandatory tooltip showing action name, hotkey, and description
- Rich tooltip content with formatting and additional information
- Context-sensitive help based on current game state

#### Grid Alignment
- All instances positioned on 20×20 pixel grid intersections
- Consistent sizing ensures visual harmony in toolbars and panels

#### State Feedback
- Visual feedback for enabled/disabled states
- Cooldown timers with progress indicators
- Resource availability indicators

### Game-Specific Usage
- Battlescape action buttons (Move, Attack, Overwatch)
- Toolbar controls in strategic interfaces
- Quick action panels in base management
- Command shortcuts in research and manufacturing

## CheckButton Widget

### Purpose
Binary state selection widget for settings, filters, and toggleable options that can be selected independently.

### Key Features

#### Checkbox/Radio Variants
- Standard checkbox for independent options
- Visual differentiation between checkbox and radio button styles
- Consistent appearance across different contexts

#### Visual States
- Unchecked, checked, indeterminate (checkbox only)
- Hover and pressed states for interaction feedback
- Disabled state with visual dimming

#### Label Integration
- Inline text labels with proper spacing and alignment
- Support for multi-line labels and text wrapping
- Configurable label positioning relative to checkbox

#### Group Management
- Optional grouping for related checkbox sets
- Visual grouping indicators and layout assistance

### Game-Specific Usage
- Research project toggles and priority settings
- Facility power switches and operational modes
- Unit equipment filters and display options
- Game settings and configuration options

## RadioButton Widget

### Purpose
Exclusive selection widget for choosing one option from a mutually exclusive set of alternatives.

### Key Features

#### Group Association
- Automatic exclusive selection within defined groups
- Group management with proper state synchronization
- Visual feedback for group membership and selection

#### Visual Feedback
- Clear selected/unselected states with distinct styling
- Group highlighting to show related options
- Smooth state transitions and animations

#### Label Support
- Integrated text labels with consistent spacing
- Support for complex labels with formatting
- Alignment options for different layout requirements

#### Keyboard Navigation
- Tab navigation and arrow key cycling within groups
- Proper focus management for accessibility
- Group-based navigation shortcuts

### Game-Specific Usage
- Difficulty selection and game mode choices
- Strategic option selection in mission planning
- Equipment loadout choices and weapon preferences
- Base facility upgrade path selection

## ComboBox Widget

### Purpose
Dropdown selection interface for choosing from predefined lists with optional search functionality.

### Key Features

#### Dropdown List
- Scrollable list with mouse and keyboard navigation
- Visual selection highlighting and hover effects
- Support for large datasets with efficient rendering

#### Search Support
- Optional text input for filtering long lists
- Real-time filtering with instant results
- Search highlighting and result counting

#### Grid Constraints
- Dropdown width constrained to 20×20 pixel increments
- Dynamic height calculation based on content
- Proper boundary checking to stay within screen limits

#### State Persistence
- Remembers last selection across sessions
- Support for default values and placeholder text
- Selection history for quick re-selection

### Game-Specific Usage
- Weapon selection in equipment management
- Research project choices in laboratory interfaces
- Craft assignment dropdowns in geoscape
- Mission type selection in strategic planning

## ListBox Widget

### Purpose
Scrollable list interface for displaying and selecting multiple items with various selection modes.

### Key Features

#### Virtual Scrolling
- Efficient rendering of large datasets with smooth scrolling
- On-demand content loading for performance optimization
- Memory management for large item collections

#### Selection Modes
- Single selection with visual highlighting
- Multi-selection with Ctrl/Shift modifiers
- Range selection with drag operations
- Custom selection logic support

#### Item Templates
- Configurable item layouts with icons, text, and status indicators
- Support for complex item hierarchies and grouping
- Custom rendering for specialized item types

#### Sorting Support
- Column-based sorting with visual sort indicators
- Multiple sort criteria and custom comparers
- Stable sorting to maintain relative order

### Game-Specific Usage
- Unit rosters in base management screens
- Research queues and manufacturing lists
- Inventory management and item catalogs
- Mission logs and historical records

## TextInput Widget

### Purpose
Text entry interface with validation, autocomplete, and formatting support for user input.

### Key Features

#### Input Validation
- Real-time validation with visual feedback
- Custom validation rules and error messages
- Input filtering and sanitization

#### Autocomplete Support
- Intelligent suggestions based on context and history
- Keyboard navigation through suggestion lists
- Learning from user input patterns

#### Formatting Options
- Text masking for passwords and sensitive data
- Input formatting for numbers, dates, and special formats
- Character limits and length restrictions

#### Accessibility Features
- Screen reader support with input announcements
- Keyboard shortcuts for common operations
- Proper focus management and tab ordering

### Game-Specific Usage
- Save file naming and mission titles
- Research project naming and descriptions
- Unit naming and customization
- Configuration value entry

## TextArea Widget

### Purpose
Multi-line text display widget optimized for reading large amounts of formatted text content.

### Key Features

#### Read-Only Display
- Non-editable text content with automatic word wrapping
- Optimized for reading rather than editing
- Support for large text documents

#### Text Justification
- Left, center, right, and full justification options
- Professional typography with proper line spacing
- Support for different text alignment needs

#### Scrolling Support
- Vertical scrolling for content exceeding display area
- Smooth scrolling with momentum and bounce effects
- Scroll position memory and bookmarking

#### Rich Text Support
- Basic formatting (bold, italic, colors) for styled content
- Support for embedded images and icons
- Structured content with headings and sections

### Game-Specific Usage
- UFOPedia entries and research descriptions
- Mission briefings and objective details
- Historical records and timeline information
- Help text and tutorial content

## Table Widget

### Purpose
Custom column tabular data display with sorting and advanced data manipulation capabilities.

### Key Features

#### Custom Columns
- Configurable column definitions with headers and data types
- Dynamic column sizing and reordering
- Column visibility toggles and customization

#### Header Sorting
- Click-to-sort functionality on column headers
- Multi-column sorting with priority indicators
- Custom sort functions for complex data types

#### Variable Column Widths
- Resizable columns with minimum/maximum constraints
- Proportional and fixed width options
- Auto-sizing based on content

#### Advanced Features
- Row selection and multi-selection support
- Data filtering and search capabilities
- Export functionality for data analysis
- Pagination for large datasets

### Game-Specific Usage
- Purchase lists and transaction histories
- Research progress and statistical data
- Unit comparisons and equipment statistics
- Mission debriefs and performance metrics

## ItemList Widget

### Purpose
Specialized list widget optimized for inventory items with drag-and-drop functionality.

### Key Features

#### Compact Layout
- Single row per item with icon and name display
- Efficient space usage for inventory management
- Consistent item presentation across interfaces

#### Drag Source Functionality
- LMB drag initiates drag-and-drop operations
- RMB quick-add functionality for rapid equipping
- Visual feedback during drag operations

#### Filtering and Organization
- Category-based filtering (weapons, armor, utilities)
- Search functionality with real-time results
- Sorting by various criteria (name, type, value)

#### Visual States
- Normal, hover, and selection states
- Availability indicators and quantity displays
- Status overlays for equipped/locked items

### Game-Specific Usage
- Equipment management and loadout building
- Base inventory browsing and organization
- Research material selection and allocation
- Craft cargo and supply management

## Label Widget

### Purpose
Simple text display widget for static content, captions, and informational text.

### Key Features

#### Text Display
- Single or multi-line text rendering
- Support for basic text formatting and styling
- Automatic text wrapping and layout

#### Alignment Options
- Left, center, right, and justified text alignment
- Vertical alignment controls
- Baseline alignment for consistent typography

#### Font Control
- Configurable font size, weight, and family
- Color customization with theme support
- Anti-aliasing and rendering quality options

#### Auto-sizing
- Automatic width/height adjustment based on content
- Minimum/maximum size constraints
- Dynamic resizing based on content changes

### Game-Specific Usage
- Form labels and field descriptions
- Status messages and informational text
- Menu item labels and navigation text
- Caption text for images and diagrams

## Slider Widget

### Purpose
Continuous value selection control with visual feedback and precise value control.

### Key Features

#### Value Range
- Configurable minimum, maximum, and step values
- Support for integer and floating-point values
- Custom value ranges for different use cases

#### Visual Feedback
- Handle position indicates current value
- Optional numerical value display
- Color-coded value ranges and thresholds

#### Orientation Support
- Horizontal and vertical slider orientations
- Automatic layout adjustment based on orientation
- Touch-friendly sizing for different orientations

#### Advanced Features
- Tick marks and value markers
- Snap-to-tick functionality
- Keyboard input support for precise values

### Game-Specific Usage
- Volume controls and audio settings
- Graphics quality and performance settings
- Game difficulty and challenge level adjustment
- Resource allocation sliders in management interfaces

## Spinner Widget

### Purpose
Numeric input control with increment/decrement buttons for precise value entry.

### Key Features

#### Numeric Input
- Direct text input with validation
- Increment/decrement buttons with configurable step sizes
- Support for integer and decimal values

#### Range Limits
- Minimum and maximum value constraints
- Visual feedback for out-of-range values
- Automatic value clamping and correction

#### Formatting Options
- Custom number formatting (decimal places, separators)
- Unit display (currency, percentages, measurements)
- Localization support for different number formats

#### Input Validation
- Real-time validation with error indicators
- Custom validation rules and constraints
- Undo/redo support for value changes

### Game-Specific Usage
- Quantity selection in purchase interfaces
- Resource allocation in management screens
- Configuration values and settings
- Coordinate and measurement input

## ToggleButton Widget

### Purpose
Button that maintains a persistent on/off state for mode switching and persistent options.

### Key Features

#### State Persistence
- Maintains on/off state across interactions
- Visual toggle indicators with distinct styling
- State synchronization across related controls

#### Group Support
- Optional mutual exclusion within toggle groups
- Visual grouping indicators and layout assistance
- Group state management and validation

#### Visual States
- Distinct pressed/released appearances
- State transition animations and effects
- Custom icons for different toggle states

#### Interaction Feedback
- Clear visual feedback for state changes
- Sound effects and haptic feedback support
- Confirmation dialogs for critical state changes

### Game-Specific Usage
- Tool selection in design interfaces
- View mode switching (2D/3D, different overlays)
- Feature toggles in configuration screens
- Mode switching in tactical interfaces

## Separator Widget

### Purpose
Visual divider element for organizing interface content and improving visual hierarchy.

### Key Features

#### Orientation Options
- Horizontal and vertical separator orientations
- Automatic orientation detection based on context
- Flexible placement in different layout scenarios

#### Style Options
- Solid, dashed, and dotted line styles
- Custom colors and opacity levels
- Thickness and spacing customization

#### Integration
- Proper spacing calculations for adjacent elements
- Theme-aware styling and color schemes
- Responsive behavior in different container sizes

### Game-Specific Usage
- Section dividers in complex interfaces
- Menu separation in navigation panels
- Content grouping in data displays
- Visual hierarchy improvement in dense interfaces

## StatusBar Widget

### Purpose
Dynamic status display for current application state and contextual information.

### Key Features

#### Dynamic Text
- Context-sensitive status messages
- Real-time updates based on application state
- Priority-based message queuing and display

#### Progress Integration
- Optional progress indicators for ongoing operations
- Completion status and time remaining displays
- Multi-operation progress tracking

#### Multi-section Support
- Divisible into sections for different information types
- Independent updates for different status areas
- Flexible layout and sizing options

#### Auto-hide Behavior
- Configurable auto-hide timing for non-critical messages
- User interaction to show/hide status information
- Persistent display options for important status

### Game-Specific Usage
- Operation status in base management
- Mission progress and objective status
- System status and performance indicators
- Background process monitoring

## Icon Widget

### Purpose
Simple icon display widget for visual indicators, decorations, and symbolic communication.

### Key Features

#### Icon Library
- Predefined icon set with consistent sizing
- Themed icon variants for different contexts
- Scalable vector-based icons where possible

#### Customization
- Color customization with theme integration
- Size options (16×16, 20×20, 32×32 pixels)
- Opacity and blending mode controls

#### Animation Support
- Optional animated icons for status indication
- State-based animation triggers
- Performance-optimized animation systems

### Game-Specific Usage
- Status indicators in complex interfaces
- Decorative elements in UI panels
- Symbolic representation of game concepts
- Visual feedback in interactive elements

## Badge Widget

### Purpose
Notification indicator widget for displaying counts, status, and alerts on other UI elements.

### Key Features

#### Count Display
- Numerical indicators for unread items and notifications
- Custom formatting for large numbers (1K+, 10K+)
- Zero-count hiding options

#### Positioning
- Attachable to other widgets with smart positioning
- Offset controls for precise placement
- Collision detection and repositioning

#### Style Variants
- Different badge styles for notification types
- Color coding for priority levels
- Size variants for different contexts

#### Animation
- Pulse and glow effects for attention-grabbing
- Count change animations
- Entrance/exit animations

### Game-Specific Usage
- Unread message indicators
- Inventory item counts
- Mission objective progress
- Research completion notifications

## Scrollbar Widget

### Purpose
Scrollable control for navigating content that exceeds the visible area in lists, panels, and other containers.

### Key Features

#### Scroll Mechanics
- Vertical and horizontal scrolling support
- Draggable thumb with proportional sizing
- Smooth scrolling with optional momentum
- Scroll wheel and keyboard navigation

#### Visual Design
- Configurable thumb and track appearance
- Auto-hide options for clean interfaces
- Arrow buttons for precise navigation
- Size and position customization

#### Interaction
- Click and drag on thumb for direct positioning
- Click on track for page scrolling
- Arrow buttons for incremental movement
- Touch-friendly sizing for mobile interfaces

#### Integration
- Attachable to scrollable containers
- Scroll position callbacks and events
- Minimum/maximum scroll range configuration
- Smooth animation for programmatic scrolling

### Game-Specific Usage
- ListBox scrolling for large item lists
- TextArea scrolling for long documents
- Table scrolling for wide data displays
- Panel scrolling for content overflow

## Window Widget

### Purpose
Movable, resizable container window for modal dialogs, popups, and secondary interfaces.

### Key Features

#### Window Management
- Draggable title bar for repositioning
- Resizable borders with corner and edge handles
- Modal and non-modal window types
- Z-order management for overlapping windows

#### Visual Design
- Configurable title bar with close/minimize buttons
- Border styling with resize handles
- Background content area with padding
- Shadow and depth effects for layering

#### Content Area
- Flexible content container for child widgets
- Automatic layout and positioning
- Scroll support for large content
- Content clipping and overflow handling

#### Interaction
- Title bar dragging for window movement
- Border resizing with visual feedback
- Button controls for window operations
- Focus management and activation

### Game-Specific Usage
- Modal dialogs for confirmations and settings
- Inventory windows and equipment management
- Research details and UFOPedia entries
- Mission briefings and tactical overlays

## Implementation Notes

### Grid System Integration
All basic interactive widgets must adhere to the 20×20 pixel logical grid system:
- Positions must be multiples of 20 pixels
- Dimensions must be multiples of 20 pixels (minimum 20×20)
- Internal element spacing must maintain grid alignment

### Performance Considerations
- Implement efficient rendering with minimal draw calls
- Use object pooling for frequently created/destroyed widgets
- Optimize event handling to avoid unnecessary processing
- Support for batch updates during heavy UI changes

### Accessibility Compliance
- Full keyboard navigation support
- Screen reader compatibility with proper labeling
- High contrast mode support
- Configurable input methods (mouse, keyboard, controller)

### Localization Support
- All text content must support localization keys
- Dynamic text loading based on current language
- Proper handling of text expansion/contraction
- RTL language support where applicable

### Testing Requirements
- Unit tests for core functionality
- Integration tests for widget interactions
- Accessibility testing with automated tools
- Performance testing under various load conditions