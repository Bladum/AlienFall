# GUI System Summary

## Architecture Overview

- Scene stack handles all rendering/input; only top scene receives events while lower scenes pause. Scene lifecycle: init → enter (fade) → update → draw → exit → cleanup.
- Scene types: full-screen (Geoscape/Basescape/Battlescape), modal overlays, transitions (fade 0.3 s, slide 1 s), and persistent HUD layers sharing assets.
- Event bus delivers clicks, hover, focus/blur, change, double/right click to widget callbacks, supporting keyboard navigation and focus state.

## Widget Framework

- Core widgets: buttons, panels, labels, text boxes, toggles, sliders, dropdowns, lists, grids, scroll views, tabs, progress bars, tooltips, validators.
- Shared properties include positioning (absolute or relative), visibility, enablement, styling (theme-driven), hierarchy, constraints, animations, and input focus order.
- Drag-and-drop, context menus, modal dialogs, notifications, and viewport scaling are baked in for loadout management, facility placement, mission assignment, and alerting.

## Layout & Responsiveness

- Layout managers: anchor (HUD), flex-flow (menus), grid (equipment 3×4), and stack (dialog buttons) layered atop 24×24 snap grid.
- Responsive rules support 800×600 through 4K: relative units, safe areas, aspect-aware rearrangements (wide = horizontal emphasis, tall = vertical stacking).
- Scaling uses logical 960×720 base; UI elements auto-resize, fonts scale 0.8×–1.5×; pixel grid ensures crisp retro aesthetic.

## Theming & Accessibility

- Theme presets (Light, Dark, High Contrast, Pixel, Monochrome) define palette, typography (12 px body, 16–24 px headers), spacing, borders, icons, animation easing.
- Player preferences persist in config and live-switch mid-session; elements inherit parent themes with overrides for scene-specific palettes.
- Advanced features: dynamic theming (day/night), custom palette import, font scaling slider, high-contrast mode, colorblind-friendly patterns.

## Advanced Patterns

- Modal dialogs block interaction, dim background, support keyboard shortcuts (Esc cancel, Enter confirm); stack behavior allows nested dialogues.
- Drag-and-drop previews, zone highlighting, auto-scroll near edges, and invalid-drop rollback; used for loadouts, facility placement, squad assignment.
- Notification system: toasts (3–5 s), feeds, modal alerts, icon badges with color coding (info/success/warning/error/alert).
- Context menus auto-clamp to viewport, triggered via right-click with standard actions (inspect, edit, delete, transfer).

## Scene Implementations

- **Geoscape**: central hex map (80×40), province panel, mission queue, budget/relations bar, action buttons; sub-scenes for bases, research, diplomacy, analytics, finance.
- **Basescape**: facility grid, details panel, unit/craft/prisoner panes, production/research queues; sub-scenes for detailed facility/unit management.
- **Battlescape**: tactical map, command bar, squad list, objectives, cooldowns, turn counter/minimap; sub-scenes for pause, combat log, ability preview, debrief.
- **Interception**: craft vs enemy status panels, action queue, command buttons, combat log, outcome predictor.

## Integration & Performance

- Relies on asset pipeline for sprites/fonts, input system for event capture, state manager for scene transitions, and data systems for HUD metrics.
- Targets: button response instant (<100 ms), transitions 0.3–1.0 s, loadout snaps to 24 grid, resolution shift without overlap.
- Difficulty scaling modifies density: Easy enlarges elements and tooltips, Hard reduces sizes/contrast, Impossible minimal HUD.

## QA Focus

- Scene transition smoothness, event propagation ordering, widget state updates, and modal stacking.
- Responsive behavior across resolutions/aspect ratios; ensure HUD safe zones on ultrawide/vertical monitors.
- Theme switching/fallbacks, accessibility toggles (font scaling, high contrast), localization text wrapping.
- Drag-drop validation, notification queuing, context menu positioning, and keyboard navigation/tab order regression.
