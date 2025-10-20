# User Interface

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
5. Exit (trigger fade-out)
6. Cleanup (release resources)

- Event System
- **Input Events**: Click, Hover, Focus, Blur, Change, Double-Click, Right-Click
- **Callbacks**: Trigger on events, enable responsive behavior

## Widget System
**Interactive Components**:
- Buttons (clickable actions)
- Panels (content containers)
- Labels (text display)
- Text Boxes (input fields)
- Toggles (binary selection)
- Sliders (continuous values)
- Dropdowns (option selection)
- Lists (scrollable item selection)
- Grids (multi-column layout)
- Scroll Views (overflow handling)

**Unified Properties**:
- Position/Size (screen coordinates)
- Visibility (display toggle)
- Enabled State (interaction availability)
- Callbacks (event handlers)
- Style (appearance settings)
- Hierarchy (parent-child relationships)
- Tooltips (help text)
- Constraints (sizing rules)

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
- Light
- Dark
- High Contrast (Accessibility)
- Pixel Art (Retro aesthetic)

**Theme Components**:
- Color Scheme (palette mapping)
- Typography (font selection)
- Spacing (default margins/padding)
- Borders/Shadows (visual depth)
- Icons (visual communication)

**Persistence**:
- Player preference saved
- Auto-loaded on application start

## Scene-Specific Layouts

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

#### Basescape Scene

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

#### Battlescape Scene

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

#### Interception Scene

**Main Components**:
- **Craft Status** (left): Health, armor, weapons
- **Enemy Status** (right): Enemy craft status
- **Action Queue** (center): Queued actions display
- **Command Buttons** (bottom): Attack, move, evade
- **Combat Log** (bottom-right): Action history
- **Outcome Prediction** (top-right): Success probability


