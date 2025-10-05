---
title: Geoscape UI Specification
summary: Layout, flows, and interactions for the strategic world view.
tags:
  - gui
  - geoscape
  - ux
  - love2d
  - grid20x20
---

# Geoscape UI Specification

## Purpose
- Provide commanders with a deterministic overview of global operations.
- Surface time, missions, diplomacy, and logistics without obscuring the map.
- Maintain visual continuity with the 20×20 grid and 10×10 art standard.

## Layout Summary
- **Primary Canvas (left 70%)**: Orthographic world map rendered at 800×600 logical pixels, snapped to the 20×20 grid.
- **Top Command Bar**: Time controls, funding, panic summary, alert queue, and subscreen tabs.
- **Right Insight Stack (width 20%)**: Collapsible panels for mission details, diplomacy summaries, and scheduled events.
- **Bottom Toast Lane**: Timed notifications (mission spawn, research complete, finance alert) with dismiss and pin options.

## Navigation & States
- Time control buttons: `Pause`, `1×`, `5×`, `30×`, plus keyboard shortcuts (`SPACE`, `1`, `2`, `3`).
- Subscreen tabs (persistent across sessions):
  - **World Map** (default)
  - **Manufacturing**
  - **Research**
  - **Map Modes**
  - **Reports**
  - **Government**
  - **Diplomacy**
  - **Quests**
  - **World Switcher**
- Each tab swaps the right insight stack while the main map remains interactive unless a modal overlay is open.

## Interaction Patterns
### Province Selection
- Hover: highlight province border, display tooltip with owner, panic, radar coverage, active missions.
- Click: lock focus, populate insight stack with province card, action buttons (`View Base`, `Launch Craft`, `Open Diplomacy`).
- Double-click: recentre camera and open the most relevant subscreen (e.g., Diplomacy for capital provinces).

### Mission Workflow
1. **Alert Toast** appears with mission icon, name, expiry timer, and `Focus` button.
2. On focus, map centres on mission marker; insight stack switches to mission card.
3. Mission card offers `Intercept`, `Deploy Strike Team`, or `Delay` (if research prerequisites missing).
4. Selecting `Intercept` opens craft picker overlay with squad loadout summary before transitioning to Interception scene.

### Diplomacy Snapshot
- Diplomacy tab lists factions sorted by attitude. Each entry shows relationship meter, trade access, favours owed.
- Selecting faction expands to reveal province influence, outstanding requests, and `Propose Deal` button.
- Deals use modal flow with confirmation summary and projected relationship deltas.

### Reports & Analytics
- Reports tab displays timeline charts (funding, panic, score) using Love2D canvas overlays.
- Export buttons queue report snapshots to the in-game archive (for review in Menu → Archives).
- Monthly report alerts push players into this tab automatically when they first appear.

## Information Architecture
- **Status Strip (top-right)**: Funding total, monthly trend arrow, panic meter, global alert indicator.
- **Event Queue**: Chronological list with filters (All, Strategic, Research, Logistics). Each entry reveals seeded deterministic timestamps.
- **Mission Markers**: Icon + colour-coded ring (mission type). Tooltip shows success rewards, penalties, expiry.
- **Map Layers**: Toggle buttons for radar coverage, supply lines, diplomatic zones. Only one analytic layer active at a time to avoid clutter.

## Notifications & Feedback
- Alerts escalate in three tiers:
  - **Critical**: Red toast, pauses time automatically (e.g., terror mission, base attack).
  - **Warning**: Amber toast, blinks status strip but time continues (e.g., low funding warning).
  - **Info**: Blue toast, fades after 8 seconds (e.g., research completed).
- All alerts log to `logs/alerts/geoscape_<campaignId>.log` for QA parity.

## Accessibility Considerations
- Colour-blind palette for mission markers with shape differentiation (circle, diamond, hex).
- Time control keys remappable; default tooltips show key binding.
- Insight stack supports keyboard navigation (`TAB` cycling) with focus outlines snapped to 20×20 grid increments.

## Modding Hooks
- Tab order and visibility configurable via `data/gui/geoscape_tabs.toml`.
- Mission card layout exposes slots for modded actions (e.g., `Negotiate` for diplomacy mods).
- Toast templates defined in `data/gui/geoscape_toasts.toml`; mods can append new alert types referencing standard severity tokens.

## Related Reading
- [GUI Overview](../GUI.md)
- [Geoscape Overview](../geoscape/README.md)
- [Economy README](../economy/README.md)
- [Organization README](../organization/README.md)
- [Interception README](../interception/README.md)

## Tags
`#gui` `#geoscape` `#ux` `#determinism` `#grid20x20`
