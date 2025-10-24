# Core Mod Lore: Narrative Events

## Goal / Purpose

The Narrative folder contains story events, dialog, and interactive narrative content that plays during the game.

## Content

- Narrative event configurations (.toml)
- Story event triggers and conditions
- Dialog content and NPC interactions
- Narrative consequence definitions
- Event progression and chaining

## Features

- **Story Events**: Significant moments in campaign narrative
- **Dialog System**: NPC dialog and player interactions
- **Event Triggers**: When events occur in gameplay
- **Branching Narrative**: Multiple dialogue/story paths
- **Consequences**: How choices affect game state
- **Event Chaining**: Events that lead to other events
- **Conditionals**: Complex event triggering logic

## Integrations with Other Systems

### Narrative System
- Loaded and managed by `engine/lore/lore_manager.lua`
- Events trigger via `engine/lore/narrative_hooks.lua`
- Dialog managed by narrative system

### Campaign System
- Events tied to campaign phases
- Progress gates when events can occur
- Story progression through events

### Geoscape
- Events triggered by geoscape conditions
- Faction events and diplomatic incidents
- World events and disasters

### Basescape
- Base-specific narrative events
- Research breakthrough moments
- Recruitment and personnel events

### Battlescape
- Mission briefing narratives
- Combat event narration
- Post-battle consequences

### Design & Lore
- Events from `lore/story/` phases
- Implements narrative design from `design/mechanics/Lore.md`
- Character arcs from `lore/` documentation

## Event Categories

- **Story Events**: Campaign progression events
- **Faction Events**: Faction-specific occurrences
- **Character Events**: NPC personal narratives
- **Discovery Events**: Research and technology breakthroughs
- **Crisis Events**: Emergencies and disasters
- **Victory Events**: Mission successes and achievements
- **Defeat Events**: Mission failures and setbacks

## See Also

- [Lore README](../../../lore/README.md) - Lore overview
- [Story Content](../../../lore/story/README.md) - Campaign narrative
- [Core Lore README](../README.md) - Lore content overview
- [Lore API](../../../api/LORE.md) - Narrative system interface
