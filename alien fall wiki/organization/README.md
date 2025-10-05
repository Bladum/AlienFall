# Organization Overview

Organization captures the player’s meta-progression: reputation, policies, and internal structure. This README brings the system in line with the Love2D implementation and modern design goals.

## Role in AlienFall
- Represent the player-led organisation (Alienfall Initiative) as it grows in fame, influence, and moral alignment.
- Provide policy levers that tune gameplay (research focus, recruitment priorities, diplomacy posture).
- Track relationships with external factions and feed finance/funding outcomes.

## Player Experience Goals
- **Agency:** Policies feel like strategic statements with tangible mechanical impact.
- **Visibility:** Reputation (fame/karma) changes are communicated through UI, events, and funding shifts.
- **Integration:** Organization choices influence missions, tech, economy, and story arcs.

## System Boundaries
- Covers fame, karma, company structure, policies, recruitment, and faction relations.
- Interfaces with finance (funding modifiers), economy (supplier access), lore (events/quests), geoscape (mission availability), and units (recruitment pools).

## Core Mechanics
### Fame & Reputation
- Fame measures public support (0–100). High fame boosts funding, recruitment quality, and event options; low fame increases panic and sanctions.
- Karma tracks moral alignment on a -50 to +50 scale. Extreme values unlock unique policies and events.
- Fame and karma values stored in `data/organization/reputation.toml` for tuning.

### Company Structure
- Organisation tiers (Front, Command, Directorate) unlock slots for policies, advisors, and divisions.
- Advisors provide passive bonuses keyed to economy, science, military, or diplomacy tags.
- Division upgrades grant persistent perks but require upkeep paid monthly.

### Policies
- Policies are discrete choices (e.g., “Rapid Response”, “Scientific Focus”, “Zero Tolerance”).
- Each policy has prerequisites (fame, karma, research) and provides buffs plus trade-offs.
- Policies occupy limited slots and can be swapped with cooldowns to prevent exploitative toggling.

### Faction Relations
- Tracks standing with council nations, corporations, resistance cells, and aliens.
- Standing influences mission availability, supplier discounts, and event outcomes.
- Values update deterministically based on missions, policies, and lore events.

## Implementation Hooks
- **Data Tables:** `reputation.toml`, `policies.toml`, `advisors.toml`, `factions.toml`, `divisions.toml`.
- **Event Bus:** `org:fame_changed`, `org:karma_changed`, `org:policy_adopted`, `org:policy_revoked`, `org:faction_standing_changed`.
- **UI:** Organization dashboard sits on the 20×20 grid. Reputation meters use horizontal bars in 20px increments, policy cards align to tiles.
- **Save Data:** Persist active policies, advisor assignments, reputation values, and division upgrades.

## Grid & Visual Standards
- Dashboard uses a 3-column layout (Policies, Reputation, Advisors) each 200 logical pixels wide (10 tiles).
- Icons for factions, policies, and advisors are 10×10 sprites scaled ×2.

## Data & Tags
- Reputation tags: `fame`, `karma`, `panic`, `influence`.
- Policy tags: `military`, `science`, `economy`, `diplomacy`, `covert`.
- Faction tags: `council`, `corporate`, `resistance`, `alien`.

## Related Reading
- [Finance README](../finance/README.md)
- [Economy README](../economy/README.md)
- [Lore README](../lore/README.md)
- [Geoscape README](../geoscape/README.md)

## Tags
`#organization` `#reputation` `#policies` `#love2d`
