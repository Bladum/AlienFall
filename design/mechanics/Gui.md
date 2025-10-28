# GUI System

> **Status**: Design Document  
> **Last Updated**: 2025-10-28  
> **Related Systems**: Assets.md, Geoscape.md, Battlescape.md, Basescape.md

## Table of Contents

- [Overview](#overview)
- [Scene System](#scene-system)
- [Widget System](#widget-system)
- [Layout Systems](#layout-systems)
- [Responsive Design](#responsive-design)
- [UI Themes](#ui-themes)
- [Scene-Specific Layouts](#scene-specific-layouts)
- [Geoscape Scene](#geoscape-scene)

## Overview

Player communication layer providing accessible, intuitive interaction with all game systems. Scene-based architecture with widget-driven UI enabling responsive design across resolutions.

## Scene System

**Architecture**: Stack-based rendering with only top scene receiving input. Lower scenes pause.

**Scene Types**:

| Type | Purpose | Examples | Interaction |
|------|---------|----------|-------------|
| **Full-Screen** | Dedicated focus for major systems | Geoscape, Basescape, Battlescape | Primary interface |
| **Modal** | Overlay dialog with context | Item purchase, confirmation | Blocks lower scenes |
| **Transition** | Animation between scenes | Fade (0.3s), Slide (1s) | Visual continuity |
| **Persistent HUD** | Always-visible elements | Health bars, resource display | Background layer |

**Scene Lifecycle**:
1. Initialize
2. Enter (trigger fade-in)
3. Update (process input/logic)
4. Draw (render)
6. Exit (trigger fade-out)
7. Cleanup (release resources)

### Event System

- **Input Events**: Click, Hover, Focus, Blur, Change, Double-Click, Right-Click
- **Callbacks**: Trigger on events, enable responsive behavior

## Widget System
**Interactive Components**:
- **Buttons** (clickable actions, multi-state: normal/hover/pressed/disabled)
- **Panels** (content containers, support scrolling, resizing, dragging)
- **Labels** (text display, single/multi-line, word wrap)
- **Text Boxes** (input fields, validation, placeholder support)
- **Toggles** (binary selection, visual indicator)
- **Sliders** (continuous values, min/max range, step increments)
- **Dropdowns** (option selection, searchable, multi-select variant)
- **Lists** (scrollable item selection, sortable, multi-select)
- **Grids** (multi-column layout, row highlighting, column resizing)
- **Scroll Views** (overflow handling, custom scrollbars, momentum scrolling)
- **Tabs** (multi-pane interface, lazy loading)
- **Progress Bars** (visual progress, color coding, ETA display)
- **Input Validators** (real-time validation feedback, error messages)

**Unified Properties**:
- Position/Size (screen coordinates or relative units)
- Visibility (display toggle, fade animations)
- Enabled State (interaction availability, disabled appearance)
- Callbacks (event handlers for all interactions)
- Style (appearance settings, theme support)
- Hierarchy (parent-child relationships, depth layering)
- Tooltips (help text, hover delay, word wrap)
- Constraints (sizing rules, maintain aspect ratio)
- Animation (state transitions, tweening support)
- Input Focus (keyboard navigation, tab order)

## Layout Systems

**Anchor-Based Layout**:
- Fixed positioning to screen edges
- Ideal for HUD elements
- Maintains aspect ratio

**Flex-Box Layout**:
- Flow-based positioning
- Automatic wrapping
- Ideal for menus

**Grid Layout**:
- Rows and columns
- Ideal for equipment (3Ă—4 grids)
- Regular spacing

**Stack Layout**:
- Vertical or horizontal stacking
- Automatic spacing
- Ideal for dialog buttons

## Responsive Design

**Measurement System**:
- **Relative Units**: Percentage of screen width/height
- **Pixel Grid**: 24Ă—24 pixel grid snappoint for consistency
- **Resolution Support**: 800Ă—600 to 4K displays

**Safe Areas**:
- Critical HUD elements away from edges
- Bezel-aware positioning

**Aspect Ratio Adaptation**:
- Wide (16:9, 16:10): Horizontal UI emphasis
- Tall (9:16, 4:3): Vertical UI emphasis
- Auto-adjustment for monitor orientation

## UI Themes

**Consistency Modes**:
- **Light** (bright backgrounds, dark text, ideal for diurnal play)
- **Dark** (dark backgrounds, light text, reduces eye strain)
- **High Contrast** (maximum readability, accessibility-focused)
- **Pixel Art** (retro aesthetic, chunky fonts, bright colors)
- **Monochrome** (colorblind-friendly, grayscale with patterns)

**Theme Components**:
- **Color Scheme** (palette mapping for all UI elements)
  - Primary (actions, highlights)
  - Secondary (information, status)
  - Success (positive results, +values)
  - Warning (cautions, time-sensitive)
  - Danger (errors, destructive actions)
  - Neutral (backgrounds, disabled states)
- **Typography** (font selection, sizes, weights)
  - Header font (16px/20px/24px)
  - Body font (12px standard)
  - Monospace font (code/numbers)
- **Spacing** (default margins/padding: 4px grid)
- **Borders/Shadows** (visual depth, element separation)
- **Icons** (visual communication, consistency)
- **Animations** (fade/slide/scale timing, easing functions)

**Persistence**:
- Player preference saved to game configuration
- Auto-loaded on application start
- Can be changed mid-game with immediate refresh
- Per-scene theme overrides supported

**Advanced Theme Features**:
- **Dynamic Theming**: Color adjustments based on game state (night/day cycle affects UI)
- **Theme Inheritance**: UI elements inherit parent theme settings
- **Custom Palettes**: Players can create/import custom color schemes
- **Font Scaling**: Adjust all font sizes for accessibility (0.8× to 1.5×)

---

## Advanced UI Patterns

### Modal Dialogs

**Types**:
- **Confirmation** (Yes/No/Cancel)
- **Input** (Text entry with validation)
- **Selection** (Choose from list)
- **Alert** (Information/Warning/Error message)
- **Progress** (Long-running operation)

**Behavior**:
- Blocks interaction with background scene
- Darkened background reduces distraction
- Keyboard support (ESC to cancel, Enter to confirm)
- Multiple dialogs supported (stack behavior)

### Context Menus

**Implementation**:
- Right-click trigger on interactive elements
- Position near cursor
- Auto-adjust to stay on-screen
- Fade with click outside or selection

**Common Actions**:
- Inspect/Details
- Edit/Modify
- Delete/Remove
- Transfer/Move
- Cancel/Close

### Drag & Drop System

**Behavior**:
- Click and hold to initiate
- Visual preview while dragging
- Drop zone highlighting (valid/invalid)
- Auto-scroll when near list edges
- Undo on invalid drop

**Use Cases**:
- Equipment loadout management (drag items between slots)
- Base facility construction (drag facilities to grid)
- Mission assignment (drag units to craft/team)
- Inventory management (drag items between bases/slots)

### Notification System

**Notification Types**:
- **Info** (Blue, general information)
- **Success** (Green, action completed)
- **Warning** (Yellow, caution needed)
- **Error** (Red, action failed)
- **Alert** (Flashing red, urgent attention)

**Display**:
- Toast notifications (corner of screen, 3-5s duration)
- Notification feed (persistent, scrollable)
- Modal alerts (important messages, require acknowledgment)
- Icon badges (number indicators on UI elements)

**Examples**:
- "Mission completed successfully" (Green toast, 3s)
- "Insufficient credits" (Red modal, requires OK)
- "Research complete: Plasma Weapons" (Green notification feed)
- "Base under attack!" (Red flashing alert)

### Viewport & Scaling

**Resolution Support**:
- Minimum: 800×600
- Standard: 960×720 (12×12 pixel grid, 24×24 displayed)
- HD: 1920×1440
- 4K: 3840×2880

**Scaling Strategy**:
- All measurements in logical pixels (960×720 base)
- Automatic scaling to device resolution
- UI elements snap to 24×24 grid
- Text scales with viewport

**Aspect Ratio Adaptation**:
- **Wide (16:9, 16:10)**: Horizontal UI emphasis
  - Panels arrange left/right
  - Bottom HUD bar compressed
- **Tall (9:16, 4:3)**: Vertical UI emphasis
  - Panels stack top/bottom
  - Side HUD bars removed
- **Auto-adjustment**: Responsive layout changes based on detected ratio

---



### Geoscape Scene

**Main Components**:
- **Hex Grid** (center): 80Ă—40 world map
- **Province Details** (right): Status, facilities, units
- **Mission Queue** (bottom): Active and queued missions
- **Budget/Relations** (top): Current financial status, country relationships
- **Action Buttons** (bottom-right): Deploy craft, end turn

**Sub-Scenes**:
- Manage Bases (base overview, facility construction)
- Research Queue (active research, available techs)
- Diplomacy (relation management, advisor hiring)
- World Analytics (statistics, faction status)
- Budget Breakdown (detailed finance view)

### Basescape Scene

**Main Components**:
- **Base Grid** (center-left): 2D facility layout
- **Facilities Panel** (right): Facility details, construction options
- **Units/Crafts/Prisoners** (right-bottom): Squad management
- **Production/Research Queues** (bottom): Status and ETA

**Sub-Scenes**:
- Facility Details (stats, bonuses, upgrades)
- Unit Equipment (weapons, armor, loadout)
- Research Queue (tech selection, progress)
- Manufacturing Queue (equipment production)
- Base Analytics (statistics, efficiency)
- Base Transfer (resource movement)

### Battlescape Scene

**Main Components**:
- **Hex Grid Map** (center): Tactical battlefield
- **Unit Command Panel** (bottom): Movement/action options
- **Unit List** (left): Squad roster with status
- **Objective Display** (top-left): Mission goal
- **Cooldown Display** (bottom-left): Ability timers
- **Turn Counter/Minimap** (top-right): Current turn, field overview

**Sub-Scenes**:
- Pause Menu (continue, options, save, quit)
- Combat Log (action history)
- Ability Details (preview ability effects)
- Post-Mission Summary (results, rewards, casualties)

### Interception Scene

**Main Components**:
- **Craft Status** (left): Health, armor, weapons
- **Enemy Status** (right): Enemy craft status
- **Action Queue** (center): Queued actions display
- **Command Buttons** (bottom): Attack, move, evade
- **Combat Log** (bottom-right): Action history
- **Outcome Prediction** (top-right): Success probability


