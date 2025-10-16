# 🎨 UI/UX Design Best Practices for AlienFall

**Domain**: User Interface & Experience Design  
**Focus**: Accessibility, responsive design, interaction patterns  
**Version**: 1.0  
**Last Updated**: October 16, 2025

---

## Table of Contents

1. [Information Architecture](#information-architecture)
2. [Visual Hierarchy & Clarity](#visual-hierarchy--clarity)
3. [Pixel Grid Alignment](#pixel-grid-alignment)
4. [Color & Visual Feedback](#color--visual-feedback)
5. [Accessibility](#accessibility)
6. [Interaction Patterns](#interaction-patterns)
7. [Animation & Polish](#animation--polish)
8. [Theming & Customization](#theming--customization)
9. [Dialog & Text Design](#dialog--text-design)
10. [Mobile/Responsive](#mobile--responsive)
11. [Common Patterns](#common-patterns)
12. [Testing & Validation](#testing--validation)

---

## Information Architecture

### ✅ DO: Organize Information Hierarchically

Users should find what they need quickly.

**Information Hierarchy:**

```
AlienFall Main Menu:
┌──────────────────────────────┐
│    ALIENFALL - MAIN MENU     │  ← Primary action
├──────────────────────────────┤
│  [New Game]                  │  ← Most common action, prominent
│  [Load Game]                 │  ← Secondary action
│  [Options]                   │  ← Less common
├──────────────────────────────┤
│  [Credits]  [Exit]           │  ← Tertiary actions, bottom
└──────────────────────────────┘

Hierarchy: Important → Medium → Secondary
Users see primary actions first
```

### ✅ DO: Create Clear Navigation Paths

Users should know where to go and how to go back.

**Navigation Pattern:**

```
Main Menu
  ├─ Campaign
  │  ├─ Geoscape
  │  │  └─ [Back to Campaign]
  │  ├─ Battlescape
  │  │  └─ [Back to Campaign]
  │  └─ Base Management
  │     └─ [Back to Campaign]
  ├─ Options
  │  └─ [Back to Main Menu]
  └─ Credits
     └─ [Back to Main Menu]

Every screen shows:
- Current location
- Path back to parent
- Available forward actions
```

### ✅ DO: Group Related Functions

Similar actions together aid discovery.

**Functional Grouping:**

```
Combat Interface:
┌─────────────────────────────┐
│ UNIT ORDERS                 │
│ [Move] [Attack] [Reload]    │  ← Offensive
│ [Overwatch] [Suppress]      │  ← Defensive
│ [Item] [Ability]            │  ← Special
├─────────────────────────────┤
│ CAMERA CONTROLS             │
│ [Zoom In] [Zoom Out]        │  ← View control
│ [Center Unit]               │
│ [End Turn]                  │  ← End action
├─────────────────────────────┤
│ [Menu] [Settings]           │  ← Exit/Meta
└─────────────────────────────┘

Related functions grouped, unrelated separated
```

---

## Visual Hierarchy & Clarity

### ✅ DO: Use Size to Show Importance

Larger = more important to the user.

**Size Hierarchy:**

```
Base Status Screen:

Personnel Count - LARGEST (most important)
┌─────────────────────┐
│       285/300       │
│    (95% CAPACITY)   │
└─────────────────────┘

Secondary Stats - MEDIUM
┌──────────┬──────────┐
│ Health   │ Morale   │
│  95%     │  85%     │
└──────────┴──────────┘

Tertiary Details - SMALL
Facilities: 12 | Research: 150pts | Funds: $125k

Detail hierarchy matches importance
```

### ✅ DO: Use Color for Emphasis

Color draws attention and communicates status.

**Color Usage:**

```
Status Colors:
- Green: Good, success, available
- Yellow: Caution, warning, available but limited
- Red: Danger, error, unavailable
- Gray: Disabled, offline, not actionable
- Blue: Information, neutral, selected

Example:
Soldier Health:
90%+ HP → Green bar
50-90%  → Yellow bar
<50%    → Red bar

Player instantly sees status
```

### ✅ DO: Maintain Clear Contrast

Text must be readable on all backgrounds.

**Contrast Guidelines:**

```
Text on Dark Background:
- White text on black: ✓ High contrast (100%)
- Light gray on dark gray: ✗ Low contrast (<50%)

Text on Light Background:
- Black text on white: ✓ High contrast
- Dark gray on light gray: ✗ Low contrast

Rule: Difference > 50% contrast for readability
Use Color Contrast Analyzer tool

Examples:
✓ White text on dark blue
✓ Black text on light yellow
✗ Light blue text on light gray
✗ Dark purple text on black
```

---

## Pixel Grid Alignment

### ✅ DO: Snap All UI Elements to Grid

24×24 pixel grid system (see Pixel Art guidelines).

**Grid Alignment:**

```
Screen is 40×30 grid cells (960×720)

Valid UI positions:
- (0, 0) - top-left
- (24, 0) - one cell right
- (48, 24) - two right, one down

Invalid positions:
- (23, 15) - off-grid
- (12.5, 10.5) - sub-pixel

Check: Is position divisible by 24?
position.x % 24 == 0 ✓
position.x % 24 != 0 ✗

All UI must snap to grid
```

### ✅ DO: Design UI at Native Resolution

Design at 960×720 (40×30 grid cells).

**Resolution Strategy:**

```
Never design UI at 480×360 (too small to see)
Never design UI at 1920×1440 (wastes space)

Design at 960×720:
- 40 columns × 30 rows
- Can see detail clearly
- Scales easily to other resolutions
- Maintains pixel-perfect appearance

Layouts:
- Full screen: 40×30 cells
- Sidebar: 8×30 cells
- Main area: 32×30 cells
- Panel: 12×8 cells
```

---

## Color & Visual Feedback

### ✅ DO: Provide Clear Feedback for All Actions

User should see response to every action.

**Feedback Types:**

```
Click Button "Attack":
1. Button visual change (pressed appearance)
2. Cursor might change (feedback)
3. Unit animation (action happening)
4. Sound effect (audio feedback)
5. UI update (result shown)

Every interaction gets immediate feedback
```

### ✅ DO: Use Visual States for Interactive Elements

Show what can be interacted with.

**Interactive States:**

```
Button States:
NORMAL:    [  ATTACK  ]     (standard, clickable)
HOVER:     [  ATTACK  ]     (highlighted, clickable)
ACTIVE:    [  ATTACK  ]     (pressed, responding)
DISABLED:  [  ATTACK  ]     (grayed, not clickable)

Slider States:
NORMAL:    ◯─────●─────◯    (can interact)
HOVER:     ◯─────◉─────◯    (can interact, glowing)
ACTIVE:    ◯─────◆─────◯    (being dragged)

Clear visual distinction for each state
```

---

## Accessibility

### ✅ DO: Support Keyboard Navigation

Not all players use mouse.

**Keyboard Support:**

```
Tab key: Move between controls
Enter: Activate focused control
Arrow keys: Navigate menus
Esc: Back/Close menu
Alt+F4: Exit game (system standard)

Visible Focus Indicator:
┌─────────────┐
│ New Game    │  ← Selected (visible border/highlight)
├─────────────┤
│ Load Game   │  ← Not selected
├─────────────┤
│ Options     │
└─────────────┘

Tab → Load Game becomes selected
```

### ✅ DO: Support Screen Readers

Text-based interaction for accessibility.

**Screen Reader Support:**

```
All UI elements need labels:
✓ <button>Attack</button>
✓ <input aria-label="Unit name" />
✓ Icons have alt text

Status messages spoken:
"Soldier hit enemy for 25 damage"
"Turn changed to enemy"
"Mission complete"

Avoid: Images only, no text descriptions
Use: Clear text labels everywhere
```

### ✅ DO: Implement Color Blindness Modes

Not everyone sees colors the same.

**Color Blind Modes:**

```
Deuteranopia (red-green blind):
- Use blue/yellow contrast instead
- Add patterns in addition to colors
- Patterns distinguish status

Protanopia (red-green blind):
- Same as deuteranopia

Tritanopia (blue-yellow blind):
- Use red/blue contrast
- Again, add patterns

Implementation:
- Option: "Color Blind Mode: [Deuteranopia]"
- Uses different palette
- Maintains contrast and clarity

Always have pattern backup for colors
Not "red = dangerous", but "red + ⚠️ symbol = dangerous"
```

---

## Interaction Patterns

### ✅ DO: Use Consistent Interaction Models

Users learn one way, use it everywhere.

**Consistent Interaction:**

```
Combat Selection:
Click unit → Unit selected (blue outline)
Click terrain → Unit moves there
Click enemy → Unit attacks

Base Management:
Click building → Building selected (blue outline)
Click upgrade → Upgrade happens
Click remove → Building removed

Consistent: Click = select/interact everywhere
```

### ✅ DO: Implement Undo Where Possible

Mistakes happen, let users fix them.

**Undo Pattern:**

```
Scenario: Click wrong target
1. Player realizes mistake
2. Press Ctrl+Z (or Undo button)
3. Action reversed

Without undo: Player feels trapped
With undo: Player feels safe trying things

Implement undo for:
- Building placement/removal
- Unit positioning (in planning phase)
- Loadout changes
- Research cancellation

NOT for: Combat actions (part of turn commitment)
```

---

## Animation & Polish

### ✅ DO: Animate Transitions

Make state changes smooth and understandable.

**Transition Animation:**

```
Menu transitions:
Main Menu → Campaign
1. Main menu fades out (200ms)
2. Campaign loads
3. Campaign fades in (200ms)

Result: User sees change, understands progression

Without animation: Jarring, disorienting
With animation: Smooth, professional
```

### ✅ DO: Add Micro-interactions

Small animations improve feel.

**Micro-interactions:**

```
Button press:
[  CLICK  ] → Button moves down 2px (100ms)
             → Sound effect plays
             → Button returns to normal (100ms)

Result: Physical feedback, feels responsive

Resource gain:
$50,000 gained
Numbers tick up: $0 → $50,000 (over 1 second)
Gold sparkles appear
Sound effect plays

Result: Satisfying, visible reward
```

---

## Theming & Customization

### ✅ DO: Allow UI Theme Customization

Players have different preferences.

**Theme Options:**

```
Available Themes:
- Dark (default): Black background, white text
- Light: White background, dark text
- High Contrast: Maximum contrast for accessibility
- Colorblind (Deuteranopia)
- Colorblind (Protanopia)

UI Setting:
Theme: [Dark ▼]
Size: [Normal ▼]
Animation: [Enabled ☑]

Each theme consistently applied everywhere
```

### ✅ DO: Support Text Size Scaling

Readability is crucial.

**Text Size Options:**

```
Available Sizes:
- Small (80%): For large screens, veteran players
- Normal (100%): Default
- Large (120%): Improved readability
- Extra Large (150%): Accessibility option

Implementation:
- All text uses scaling factor
- UI layouts adapt to text size
- No text truncation

Setting: Text Size: [Normal ▼]
Result: Entire UI scales proportionally
```

---

## Dialog & Text Design

### ✅ DO: Use Clear, Direct Language

Avoid jargon and unclear phrasing.

**Language Clarity:**

```
UNCLEAR:
"Are you sure you want to execute the termination protocol?"

CLEAR:
"Delete the base? This cannot be undone."

UNCLEAR:
"Insufficient resources for facility expansion."

CLEAR:
"Need $50,000 to build this facility. You have $30,000."

Direct language helps players understand consequences
```

### ✅ DO: Design Confirmation Dialogs

Prevent accidental destructive actions.

**Confirmation Pattern:**

```
Destructive Action Attempt:
Delete this soldier?

This soldier will be permanently removed.
This cannot be undone.

[DELETE]  [CANCEL]
  (Red)    (Normal)

Two buttons clearly labeled
Warning text explains consequence
Destructive action in red
Cancel in normal color
```

---

## Mobile/Responsive

### ✅ DO: Support Multiple Screen Sizes

Not everyone plays on same resolution.

**Responsive Design:**

```
Screen Sizes:
- 960×720 (default, 40×30 grid)
- 1280×960 (widescreen, 53×40 grid)
- 1920×1440 (4K, 80×60 grid)
- 640×480 (small, 26×20 grid)

Layout Strategy:
- Base layout: 960×720
- Large screen: Add side panels, more info
- Small screen: Stack vertically, hide non-essential

Responsive rule: Layout adapts, content remains
```

### ✅ DO: Handle Touch Input

Some players use touch screens.

**Touch Considerations:**

```
Touch UI:
- Buttons larger (hit target: 24×24 minimum)
- No hover state (use long-press instead)
- Gesture support: Swipe to pan, pinch to zoom
- Double-tap to select

Touch vs Mouse:
MOUSE: Precise clicking, hover feedback
TOUCH: Large targets, tap feedback, gesture

Support both input types simultaneously
```

---

## Common Patterns

### Combat HUD Pattern

```
┌────────────────────────────┐
│ COMBAT (3/8) [Enemy Units] │
├────────────────────────────┤
│ Selected: Soldier (85% HP) │
│ AP: 2/2                    │
│                            │
│ [Move] [Attack] [Reload]   │
│ [Overwatch] [Cancel]       │
├────────────────────────────┤
│ Minimap / Objective        │
├────────────────────────────┤
│ [Menu] [End Turn]          │
└────────────────────────────┘

Always visible: Unit info, current action
Easy to access: Common actions visible
```

### Base Management Pattern

```
┌─────────────────┬──────────────┐
│                 │              │
│   Base View     │  Sidebar:    │
│   (visual base) │  Personnel   │
│                 │  Facilities  │
│   [Build Mode]  │  Resources   │
│                 │  Upgrades    │
├─────────────────┴──────────────┤
│ [Save] [Options] [Exit Base]   │
└────────────────────────────────┘

Visual representation primary
Sidebar shows details
Actions at bottom
```

---

## Testing & Validation

### ✅ DO: Test with Diverse Users

Get feedback from different perspectives.

**Testing Checklist:**

```
□ Keyboard navigation (all menus navigable via keyboard)
□ Screen reader (with narrator/JAWS)
□ Color blind mode (use simulator)
□ Zoom levels (read text at 150%)
□ Different resolutions (test 640×480, 960×720, 1920×1440)
□ Different frame rates (60fps, 30fps)
□ Slow internet (simulate latency if online features)
□ Different input devices (keyboard, mouse, gamepad)
```

### ✅ DO: Measure UI Performance

UI should never lag.

**Performance Targets:**

```
Menu: < 0.5 seconds to open
Button: < 0.1 seconds response time
Animation: 60 FPS or 30 FPS (never stutter)
Transition: < 0.5 seconds

Monitor:
- Frame time (should be consistent)
- Draw calls (minimize redundant redraws)
- Memory usage (don't leak allocations)

Profiling tools: Love2D console, integrated profiler
```

---

**Version**: 1.0  
**Last Updated**: October 16, 2025  
**Status**: Active Best Practice Guide

*See also: UI framework documentation in engine/ui/*
