# Lore Overview

Lore binds AlienFall’s mechanics into a cohesive narrative. This README defines the canonical storytelling tools and how they interact with Love2D systems.

## Role in AlienFall
- Provide factions, events, and artefacts that contextualise gameplay decisions.
- Drive campaign arcs that modulate difficulty, unlocks, and win conditions.
- Feed the in-game Pedia and external communication with authoritative canon.

## Player Experience Goals
- **Consistency:** Story beats align with mechanics—no lore contradicting the Love2D implementation.
- **Reactivity:** Player success or failure triggers believable narrative responses.
- **Discoverability:** Lore surfaces through missions, events, and items without overwhelming the player.

## System Boundaries
- Covers campaign structure, factions, quests, scripted events, enemy base narratives, calendar beats, and UFO story hooks.
- Interfaces with geoscape (mission spawning), economy (faction trade), organization (reputation), pedia (entries), and finance (council reactions).

## Core Mechanics
### Campaign Phases
- Campaign broken into deterministic phases: Arrival ➜ Escalation ➜ Crisis ➜ Resolution.
- Each phase sets mission weights, event decks, and AI aggression multipliers.
- Phase transitions triggered by score thresholds, research breakthroughs, or story missions.

### Factions & Reputation
- Define alien factions, council nations, corporations, resistance cells. Each has goals, favours, and penalties.
- Reputation values feed finance funding modifiers and unlock narrative missions.
- Faction data stored in `data/lore/factions.toml` with tags like `council`, `corporate`, `resistance`, `alien`.

### Events & Quests
- Events use template scripts referencing conditions (`province_tag`, `research_done`, `time_window`).
- Quests string events together into structured arcs with branching outcomes.
- All events log provenance (`event:<id>`) for deterministic replays.

### Enemy Installations & UFO Scripts
- Enemy base lore provides mission modifiers, map themes, and narrative rewards.
- UFO scripts define flight personalities (scout, terror, retaliator) and integrate with AI Director weights.
- Calendar entries highlight seasonal beats (e.g., “Long Night”) that modify mission decks.

## Implementation Hooks
- **Data Tables:** `campaign.toml`, `factions.toml`, `events.toml`, `quests.toml`, `ufo_scripts.toml`, `calendar.toml`.
- **Event Bus:** `lore:event_triggered`, `lore:quest_advanced`, `lore:phase_changed`, `lore:faction_reputation_changed`.
- **Pedia Integration:** Each lore entry references a Pedia article id for cross-linking.
- **Localization:** Narrative text pulled from dedicated localisation files; scripts store keys, not raw text.

## Grid & Visual Standards
- Lore overlays (briefings, alerts) snap to the 20×20 UI grid. Cinematic panels can break the grid but must anchor to tile corners.
- Iconography uses 10×10 sprites scaled ×2, matching the rest of the UI.

## Data & Tags
- Campaign tags: `arrival`, `escalation`, `crisis`, `resolution`.
- Event tags: `story`, `reaction`, `panic`, `intel`, `favour`.
- Quest tags: `main_arc`, `side_arc`, `tutorial`, `faction`.
- UFO tags: `scout`, `supply`, `terror`, `assault`.

## Related Reading
- [Organization README](../organization/README.md)
- [Geoscape README](../geoscape/README.md)
- [Pedia README](../pedia/README.md)
- [Finance README](../finance/README.md)

## Tags
`#lore` `#campaign` `#factions` `#events` `#love2d`
