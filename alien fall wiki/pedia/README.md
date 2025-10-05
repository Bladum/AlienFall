# Pedia Overview

The Pedia is AlienFall’s in-game knowledge base. This README defines the feature’s structure, unlock rules, and Love2D implementation details.

## Role in AlienFall
- Provide players with searchable, spoiler-aware information about units, items, lore, and mechanics.
- Deliver narrative context, tutorials, and strategy tips as players progress.
- Act as the public surface for deterministic data (see `data/` tables) so QA can verify content quickly.

## Player Experience Goals
- **Accessible:** Entries unlock automatically when content is encountered; manual browsing is intuitive.
- **Spoiler control:** Sensitive entries unlock via research or story events only.
- **Cross-linked:** Entries reference related systems so players can jump between topics easily.

## System Boundaries
- Covers entry taxonomy, unlock triggers, tagging, search, UI layout, and localisation.
- Interfaces with items, units, lore, economy, organization, and GUI systems.

## Core Mechanics
### Entry Types
- Categories: `unit`, `item`, `craft`, `facility`, `mission`, `lore`, `mechanic`, `tutorial`.
- Each entry has metadata: `id`, `title`, `summary`, `body`, `tags`, `unlock_conditions`, `related_entries`.
- Entries stored in TOML and localised via separate text files keyed by entry id.

### Unlock System
- Triggers include research completion, first encounter, manufacturing, event resolution, or manual award.
- Unlocks are deterministic: `_unlock_log` records seeds and sources for replays.
- Entries may have multiple unlock tiers (basic info vs. advanced tactical data).

### UI & Navigation
- Pedia uses the 20×20 grid with a two-column layout: category navigation left (6 tiles wide), content pane right (14 tiles).
- Search supports filtering by tags and text. Fuzzy match avoids randomness—results sorted deterministically by priority then alphabetically.
- Related entries display as tile-aligned buttons at the bottom of each article.

## Implementation Hooks
- **Data Tables:** `data/pedia/entries.toml`, `data/pedia/categories.toml`, `data/pedia/unlocks.toml`.
- **Event Bus:** `pedia:entry_unlocked`, `pedia:category_viewed`, `pedia:search_performed`.
- **Love2D Rendering:** Text rendered via Love2D font objects; content pane scrolls in 20px increments to maintain grid alignment.
- **Localization:** Each entry body uses localisation keys (e.g., `pedia.item.laser_rifle.body`). Localisation files stored under `assets/localisation/`.

## Grid & Visual Standards
- Navigation list items: 20×60 logical tiles (1×3). Active highlight uses palette consistent with GUI spec.
- Content padding: 20px on all sides. Inline icons (10×10 scaled ×2) align with text baseline.

## Data & Tags
- Tags drive cross-linking and search: `#geoscape`, `#battlescape`, `#economy`, `#lore`, `#tutorial`, `#advanced`.
- Spoiler levels: `public`, `restricted`, `classified` to gate content.

## Related Reading
- [GUI Specification](../GUI.md)
- [Lore README](../lore/README.md)
- [Items README](../items/README.md)
- [Units README](../units/README.md)
- [Technical README](../technical/README.md)

## Tags
`#pedia` `#documentation` `#love2d` `#grid20x20`
