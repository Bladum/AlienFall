
# GUI

## Concept

The GUI provides a clean, intuitive strategic and tactical interface that prioritises clarity and player control over visual complexity. It groups the game's major modes into distinct screens so players can quickly access information and take actions without being overwhelmed.

## Mechanics

The interface is organised into the game's primary layers and a set of secondary screens:

- Geoscape
  - Acts as the strategic hub. Displays a clear world map, current events and notifications, and a time control panel (play, pause, fast‑forward, day/month ticks).
  - Provides quick access to bases, craft assignment, transfers, research and campaign summaries.
  - Notification plumbing surfaces mission timers, event choices and campaign state with provenance metadata where useful.

- Basescape
  - Grid‑based base view for construction and management.
  - Direct access to personnel rosters, storage and facility controls.
  - Configuration screens validate build requirements, show resource costs, and present time/repair queues.

- Battlescape
  - Tactical playfield with an uncluttered view of the map and actionable HUD.
  - Unit information panels (HP, action points, status effects), ability/action buttons, and a prominent end‑turn control.
  - Contextual tooltips and preview panels show effects, cooldowns and deterministic outcome previews where applicable.

- Research
  - Visual tech tree with unlock requirements, prerequisites and short previews of gameplay impact.
  - Should support filtering and deterministic preview of unlocked Pedia entries or gameplay features.

- Manufacturing
  - Queue‑based production interface showing active projects, required inputs, facility capacity, estimated completion times and refunds on cancellation.
  - Reservation indicators for resources and man‑hours.

- Pedia
  - Read‑only in‑game encyclopedia with canonical entries, unlock sources and provenance metadata.
  - Supports staged reveals and direct links to the systems that unlock entries (research, quests, mission outcomes).

Common UI behaviours and expectations

- Hierarchy and focus: primary map or battle view remains visually dominant; panels are lightweight and collapsible to avoid obscuring core information.
- Predictable validation: all confirmation dialogs (installations, research commits, launches) present required inputs, duration, costs and irreversible consequences upfront.
- Deterministic previews: show seeded previews for actions that affect game state (install times, promotion projections, mission timings) to support designer QA and player trust.
- Accessibility and input: keyboard shortcuts, gamepad navigation and clear focus order for keyboard users; readable fonts and high‑contrast UI modes.
- Telemetry and provenance hooks: surfaces that expose event ids, seeds and provenance where required for debugging and replay.
- Modding friendliness: data‑driven labels, layouts and content so Pedia, tech trees and UI strings can be extended without code changes.

## Examples

- Geoscape layout
  - World map center; event/notification strip on the right; time control and current month/funding at the top; quick action toolbar along the bottom for base/craft/research screens.

- Basescape layout
  - Tile grid in the centre; personnel and storage panels on the left; build palette and selected facility details on the right, including resource costs and build time.

- Battlescape layout
  - Play area central; unit list and target info left; action buttons and ability hotbar bottom; minimap and status overlays top right; end‑turn button bottom right.

- Research and Manufacturing
  - Research tree shown as a network graph with unlock tooltips; manufacturing queue shows multiple projects with drag‑to‑reorder support and per‑project resource reservation indicators.

- Pedia usage
  - When research completes, the relevant Pedia entry is unlocked and marked with provenance (unlock source id, seed_locked flag). Entries are exportable for designers in JSON/CSV.

## References

Design precedents and related games

- X‑COM (classic/modern) and Long War: clear separation of strategic (Geoscape), base management and tactical (Battlescape) views; useful patterns for notifications, tech trees and deterministic previews.
- Xenonauts and Jagged Alliance: strong base management and roster UIs that emphasise clarity of provisioning and equip state.
- RimWorld and Left 4 Dead director: examples of presentation of emergent events and pacing systems; RimWorld’s incident UI and Left 4 Dead’s director cues inform how to surface campaign pressure and notification weight.
- Into the Breach: compact tactical UI that communicates deterministic outcomes clearly, useful for designing ability previews and deterministic combat information.

Real‑world analogies and practices

- Military command centres: prioritisation of a central map with layered overlays (radar, logistics, tasking) mirrors Geoscape design; clear, timely notifications and drillable provenance are standard for operational decision support.
- Air traffic / flight operations displays: consolidated situational awareness panels and time controls suggest patterns for sortie scheduling and refuelling indicators.
- Project management dashboards: manufacturing queue, resource reservation and refund rules map closely to typical build/production dashboards used in industry tools.

Cross‑system ties within this design file

- Calendar and Campaign: Geoscape time controls and monthly summaries must align with Calendar tick ordering and campaign sampling; UI previews should reflect month‑boundary effects.
- Pedia, Research and Manufacturing: UI should provide direct backlinks between Pedia entries, research unlocks and manufacturing recipes for discoverability.
- Provenance and telemetry: all UI actions that alter game state (install transformations, commit manufacture, launch craft, award medals) should expose hooks that log event ids, seeds and inputs so replays reproduce exact outcomes.

Engineering and UX guidance

- Make UI behaviour data‑driven to support modding and designer iteration (labels, panel layouts, validation rules).
- Provide seeded preview tooling for designers and QA that replays UI‑visible state with campaign/world seeds.
- Surface precise failure reasons (insufficient resources, slot missing, banned tag) rather than generic errors to aid correction and reduce frustration.
- Prioritise performance: defer heavy previews until requested and cache deterministic preview results where possible to keep the UI responsive.
- Accessibility and localization: ensure all UI strings are localised, and include scalable UI styles and color‑accessible palettes.

Further reading and tools

- Usability heuristics for games and software (e.g., Nielsen’s heuristics adapted for games).
- Long War/X‑COM modding threads and UI discussions for practical examples of deterministic previews and provenance in player‑facing interfaces.
- Human factors literature on command display design and situational awareness for principles applicable to the Geoscape and Battlescape presentation.
- Prototyping tools: Figma/Sketch for rapid UI iteration and automated export of layouts to data templates for runtime use.
- Accessibility guidelines (WCAG) for contrast, keyboard navigation and scalable text to ensure the game is usable by a broad audience.
- Telemetry best practices for provenance: structured logs including event id, seed, tick id and input snapshot to support deterministic replays and forensic debugging.
- Modding resources: recommend documenting UI data schema and exportable Pedia formats so community authors can integrate new content with minimal friction.
