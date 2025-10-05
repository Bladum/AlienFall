---
title: Basescape UI Specification
summary: Detailed interface flows for facilities, personnel, and logistics management.
tags:
  - gui
  - basescape
  - ux
  - love2d
  - grid20x20
---

# Basescape UI Specification

## Purpose
- Present base operations with deterministic clarity and minimal modal friction.
- Support up to 12 bases with identical interaction grammar.
- Surface capacity limits, service dependencies, and construction timelines at a glance.

## Layout Summary
- **Facility Grid Panel (left 60%)**: Interactive blueprint of the base using the 20×20 logical grid.
- **Top Navigation Ribbon**: Tabs for Build, Barracks, Hangars, Prison, Hospital, Research, Workshop, Marketplace, Transfer, Reports.
- **Right Operations Stack (width 25%)**: Contextual inspectors (facility details, staff roster, production queue).
- **Bottom Action Tray**: Primary actions, undo/redo for build planning, and monthly alert banner.

## Core Interactions
### Build Mode
- Selecting the Build tab highlights valid tiles with green overlays; blocked tiles show red hashed pattern.
- Facility catalogue (right stack) lists unlocked buildings with icons, power usage, build time.
- Drag placing larger footprints snaps to grid; ghost preview includes service lines (power, comms).
- Confirmation modal summarises cost, upkeep, completion date; queue retains deterministic order.

### Staffing & Units
- Barracks tab splits into `Roster`, `Training`, `Equipment` subviews using sub-tabs under the ribbon.
- Roster cards show health, sanity, role, assigned craft.
- Equipment subview integrates a horizontal carousel for loadouts with comparison tooltips referencing items data.

### Hangars & Craft Logistics
- Hangars tab uses column layout: craft list (left), detail view (centre), logistics queue (right).
- Craft detail includes loadout slots, fuel status, maintenance timer, assigned squad summary.
- Logistics queue displays ongoing refits and expected completion time anchored to campaign ticks.

### Prison & Hospital
- Prison view emphasises detainee status (alive, critical, converted). Context buttons: `Interrogate`, `Transfer`, `Execute`.
- Hospital view charts recovery timelines with progress bars overlaid on character portraits; tooltips show deterministic return-to-duty dates.

### Research & Workshop
- Research uses tree navigation in the right stack; selecting a project shows prerequisites, scientists assigned, estimated completion (deterministic seed displayed).
- Workshop queue supports drag-to-reorder with AP style cost preview. Idle warnings appear as amber badges on the Workshop tab.

### Marketplace & Transfer
- Marketplace uses buy/sell tabs with stashed inventory search (filter by tag: weapons, armor, components).
- Price changes animate colour shifts (green discount, red surcharge).
- Transfer screen displays origin/destination pickers and transport ETA; warns when transport capacity is exceeded.

### Reports
- Reports tab aggregates base-specific dashboards: power usage, staffing saturation, facility uptime.
- Export to monthly report push pins into geoscape analytics for cross-reference.

## Information Architecture
- **Capacity Strip**: Horizontal gauges for power, storage, living quarters, workshop hours.
- **Alert Icons**: Tab badges display counts (e.g., `Research (2)` meaning two idle scientists).
- **Breadcrumbs**: Secondary header shows `Base Name › Tab › Subview` for quick orientation.

## Accessibility
- Keyboard navigation: `ALT+LEFT/RIGHT` cycles tabs, `CTRL+TAB` cycles bases.
- Screen reader cues (text-to-speech) triggered on facility selection and capacity overflow.
- High-contrast palette toggle uses Love2D shader variant defined in GUI common systems.

## Modding Hooks
- Facility catalogue pulls from `data/gui/basescape_catalog.toml`; mods can add categories.
- Tab ribbon order adjustable per base via `data/gui/basescape_tabs.toml`.
- Alert badge thresholds configurable (`warning`, `critical`) per capacity type.

## Related Reading
- [GUI Overview](../GUI.md)
- [Basescape Overview](../basescape/README.md)
- [Economy README](../economy/README.md)
- [Finance README](../finance/README.md)
- [Units README](../units/README.md)

## Tags
`#gui` `#basescape` `#facilities` `#ux` `#grid20x20`
