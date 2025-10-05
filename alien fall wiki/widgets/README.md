# Widget Library

> **Purpose:** Catalogue the reusable UI components that implement AlienFall’s Love2D interface, organised for rapid lookup and integration.

## Role in AlienFall
- Provide grid-aligned controls used across Geoscape, Basescape, Interception, Battlescape, and meta screens.
- Offer deterministic feedback (seed exposure, timers, statuses) consistent with the game’s simulation-guided UI.
- Serve as the foundation for mod-extensible widgets and theme customization.

## Player / Design Goals
- Maintain pixel-perfect alignment on the 20×20 logical grid with 10×10 source art scaled ×2.
- Keep complex strategy interactions discoverable through consistent widgets and hover states.
- Ensure accessibility across keyboard, mouse, and controller input paths.

## System Boundaries
- Focuses on reusable widget modules consumed by Love2D states. Screen-level flows and interaction principles live in [`GUI/README.md`](../GUI/README.md).
- Excludes engine-level input abstraction (see `technical/README.md`) and ad-hoc debug tooling widgets.

## Mechanics / Implementation
### Library Overview
- Widgets snap to 20×20 logical units and reuse shared drawing helpers.
- Each module exports `new(props)` constructors returning Love2D draw/update functions and optional event hooks.
- The widget registry loads core components from `LOVE/src/gui` and allows mods to register additional entries via `mods/<id>/gui/widgets.lua`.

### Widget Categories
- **[Basic Interactive Widgets](BasicInteractive.md)** (20 widgets) – Buttons, list boxes, text inputs, table grids, etc.
- **[Advanced Interactive Widgets](AdvancedInteractive.md)** (4 widgets) – Drag/drop systems, inventory grids, equipment slots.
- **[Layout and Container Widgets](LayoutContainer.md)** (4 widgets) – Panels, tabs, scroll containers, split views.
- **[Display and Feedback Widgets](DisplayFeedback.md)** (4 widgets) – Progress bars, meters, tooltips, notifications.
- **[Specialized Game Widgets](SpecializedGame.md)** (5 widgets) – Globe map, minimap, turn indicators, status effects, calendar.
- **[Additional Strategy Game Widgets](StrategyGame.md)** (12 widgets) – Resource panels, action queues, research trees, mission objectives, diplomacy panels.
- **[Base Management Widgets](BaseManagement.md)** (12 widgets) – Base layout editor, market panel, reports, personnel roster, communications panel.
- **[Battlescape Widgets](Battlescape.md)** (15 widgets) – Tactical overlays, unit action panels, targeting reticles, turn order queue.
- **[Geoscape Widgets](Geoscape.md)** (12 widgets) – Province map, mission markers, craft tracker, interception tracker, diplomacy map.
- **[UFOPedia Widgets](UFOPedia.md)** (10 widgets) – Encyclopaedia navigation, entry viewers, search widgets, bookmarks.

See [Widget Architecture](WidgetArchitecture.md) for composition diagrams and dependency trees.

## Data & Events
- **Primary Catalogs:** Widget metadata tokens in `assets/ui/theme.toml`, layout templates in `gui/layouts/*.lua` (planned), localization keys in `assets/locale/*.toml`.
- **Services:** `gui/theme_manager.lua`, `services/event_bus.lua`, `gui/input_router.lua`.
- **Events:** Widgets listen for `gui:theme_changed`, `gui:input_action`, and publish `gui:notification`, `gui:modal_opened`, and domain-specific events (e.g., `basescape:queue_updated`).

## Integration Hooks
- **Theme Integration:** Widgets consume color and typography tokens from `theme_manager`. See [`GUI/README.md`](../GUI/README.md#theme-and-style-tokens).
- **Input Abstraction:** Actions map through the shared input layer; widget modules expose `:on_action(actionId)` handlers.
- **Modding:** Mods register additional widgets by calling `WidgetRegistry:register(id, factory)`; documentation should include usage examples in mod guides.

## Development Workflow
1. **Design:** Define purpose, success criteria, and accessibility requirements (see GUI design principles).
2. **Specification:** Document props, events, and visual states inside the relevant category page.
3. **Implementation:** Build the Love2D module, ensuring grid alignment and deterministic animations.
4. **Integration:** Register with the widget catalogue and wire into the target screen state.
5. **Validation:** Run layout lint checks, accessibility passes, and performance profiling.

## Quality Assurance
- **Grid Validation:** Automated tests confirm positions and sizes align with the 20×20 grid.
- **Accessibility:** Keyboard navigation, screen reader descriptions, and colour contrast must match GUI standards.
- **Performance:** Batch draw calls and reuse canvases to stay within the 60 FPS target.
- **Cross-Screen Testing:** Validate behaviour inside Geoscape, Basescape, Interception, and Battlescape states.

## Related Reading
- [GUI System](../GUI/README.md) – Interaction standards, navigation patterns, and theming.
- [Notification System](NotificationSystem.md) – Centralised notification management and delivery.
- [Technical README](../technical/README.md) – Input abstraction, event bus, and modding details.
- [Love2D Implementation Plan](../Love2D_Implementation_Plan.md) – Engine blueprint and service layout.

## Tags
`#gui` `#widgets` `#ux` `#love2d` `#grid20x20` `#accessibility` `#localization` `#theming`