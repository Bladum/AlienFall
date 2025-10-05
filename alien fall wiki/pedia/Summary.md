# Pedia Summary

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Purpose and Presentation](#purpose-and-presentation)
  - [Data and Storage](#data-and-storage)
  - [Article Template](#article-template)
  - [Display Rules and UX](#display-rules-and-ux)
  - [Tabular Keys and Category Conventions](#tabular-keys-and-category-conventions)
  - [Sections and Taxonomy](#sections-and-taxonomy)
  - [Hooks and Automation](#hooks-and-automation)
  - [Provenance, Determinism and Tooling](#provenance,-determinism-and-tooling)
  - [Modding Notes](#modding-notes)
- [Examples](#examples)
  - [Article Flow Example](#article-flow-example)
  - [Staged Reveal Example](#staged-reveal-example)
  - [Sectoid Entry Example](#sectoid-entry-example)
  - [Export and Tooling Example](#export-and-tooling-example)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Pedia is Alien Fall's comprehensive in-game encyclopedia system that serves as both a player reference tool and a design documentation system. It documents all game systems, items, units, lore, and alien entities through data-driven entries that are progressively unlocked through gameplay progression. The system emphasizes deterministic unlocks, canonical schemas, and full modding support while maintaining audit trails for debugging and telemetry.

The Pedia functions as a living reference that reveals information through research completion, quest progression, and scripted discoveries. Each entry follows a standardized YAML schema that ensures consistent presentation across UI, tooltips, and export formats. The system supports staged reveals for complex items, provenance tracking for unlocks, and comprehensive tooling for designers and modders.

## Mechanics

### Purpose and Presentation

The Pedia serves dual purposes: as an in-game reference for players and as auditable documentation for designers. Every article follows a single canonical schema that enables deterministic consumption by UI systems, tooltip generators, and export tools.

Entries remain read-only during gameplay and are only revealed through explicit unlock conditions. The system supports staged reveal states (such as Artifact → Analyzed → Usable) where each stage requires a distinct unlock key. Every article maintains provenance records including unlock source, seed locking status, and timestamp for debugging and telemetry purposes.

### Data and Storage

All Pedia content is authored as YAML files loaded at runtime, with explicit IDs, unlock keys, and presentation metadata that remain fully mod-editable. Content files must validate against the canonical schema to prevent missing unlocks or circular references.

The data structure supports:
- Explicit article categorization and taxonomy
- Staged unlock progression with distinct keys per stage
- Provenance tracking for all unlocks and interactions
- Localization key support for all user-facing text
- Asset references for images and media

### Article Template

Each Pedia article follows a standardized YAML template:

```yaml
title: short_display_name_localization_key
description: long_markdown_text_localization_key
images:
  thumbnail: path/asset_id
  large: path/asset_id
tabs: [Overview, Stats, Unlocks, Related]  # explicit order
table:  # map(key → value) for compact info rows
  key1: value1
  key2: value2
unlock:
  tech_id?: research_technology_id
  quest_id?: quest_completion_id
  condition_flags?: [flag1, flag2]
provenance:
  unlocked_by: unlock_source_id
  seed_locked: boolean
  debug_info?: additional_debug_data
hooks?:
  on_view?: telemetry_hook_id
  on_unlock?: analytics_hook_id
```

### Display Rules and UX

The Pedia UI prominently displays unlock sources for every article (e.g., "Unlocked by: Laser Weapons Study (Research)") with quick links to related research or quest systems. Articles that grant gameplay effects expose explicit fields and provide backlinks to related entries.

For staged entries, the current progression stage is prominently displayed alongside per-stage unlock information. The system provides CSV/JSON export functionality per article, including full provenance metadata for design and modding purposes.

### Tabular Keys and Category Conventions

The Pedia uses standardized tabular keys organized by category:

Crafts:
- class, hull_id, speed, range, fuel_capacity, weapon_slots, addon_slots, unit_capacity, maintenance_cost, unlock

Craft Items:
- item_type, slot, weight, power_use, damage, range, special_effects, unlock

Units:
- class, rank, HP, Aim, Will, Speed, Psi, Energy, inventory_slots, salary, unlock

Armors:
- armor_value, weight, mobility_penalty, special_resists, unlock

Weapons:
- damage_model, energy_cost, AP_cost, range, modes, unlock

Facilities:
- size, services_provided, services_required, power_use, maintenance, build_cost, unlock

Transformations:
- slot, effects, install_time_days, side_effects, facility_required, unlock

Factions/Regions/Worlds:
- overview, political_effects, economy_value, affinity_tags, notable_assets, unlock

Alien Objects:
- class, hull/max_hull, damage_profile, onboard_units, salvage_table, detection_cover, mission_behaviour, unlock

All user-facing text keys use localized strings while numeric values support direct tooling and tuning usage.

### Sections and Taxonomy

The Pedia organizes content into stable categories that UI and export tools can reliably consume:

- Crafts, Craft items, Units, Armors, Weapons, Facilities, Classes
- Origins/Backgrounds, Transformations, Medals, Wounds
- Factions, Races, Countries, Regions, Worlds, Biomes, Dossiers
- Organization, Alien UFOs, Alien races, Alien units, Alien items
- Alien armors, Alien ranks, Alien missions, Alien artifacts

This taxonomy remains stable to ensure predictable UI structures and export compatibility.

### Hooks and Automation

Designers can attach optional hooks for telemetry, tutorials, or analytics purposes:
- `on_pedia_view`: Triggered when player views an article
- `on_pedia_unlock`: Triggered when an article becomes available

All hook interactions are recorded in provenance logs to correlate with telemetry and tutorial systems.

### Provenance, Determinism and Tooling

Every entry maintains complete provenance records:
- `unlocked_by`: Source identifier for the unlock
- `seed_locked`: Boolean indicating seeded deterministic behavior
- `debug_info`: Optional additional debugging data

Tooling validates schemas, detects missing unlock mappings, and reports circular references or unreachable entries. All exports include provenance fields to enable reproducible preview states.

### Modding Notes

The Pedia supports extensive modding through:
- YAML-based content storage matching canonical schemas
- Explicit unlock mapping keys (tech_id, quest_id, condition_flags)
- Localization key support for all text content
- Optional analytics and tutorial hooks
- Schema validation and seeded preview tooling

## Examples

### Article Flow Example

A new craft entry is authored in YAML with images, canonical tab ordering, and table data for speed/range/hull statistics. The entry includes `unlock.tech_id` pointing to a research technology. When the research completes, the Pedia entry appears with `provenance.unlocked_by` set to the research ID and `seed_locked` as false.

### Staged Reveal Example

An alien artifact entry exists in three progression stages:
- Discovered: Minimal lore description with basic identification
- Analyzed: Detailed statistical breakdown and properties
- Usable: Complete information including crafting recipes

Each stage requires distinct unlock keys, with the UI displaying current progression and linking to unlock sources.

### Sectoid Entry Example

```yaml
title: Sectoid
description: >
  Small, frail alien beings with limited combat capabilities but potent psionic abilities.
  Sectoids serve as the basic infantry of alien forces, often deployed in large numbers.
  Their mindshock attacks can disrupt soldier positioning and create tactical opportunities
  for alien advances. Counter with heavy weapons and suppressive fire.
images:
  thumbnail: ui/pedia/sectoid_thumb.png
  large: ui/pedia/sectoid_full.png
table:
  Race: Sectoid
  HP: 20
  Will: 10
  Abilities: Mindshock (psionic), Low Armor
  Salvage: "{ alien_alloys: 0.2, brain_module: 0.05 }"
  Unlock: sectoid_autopsy
provenance:
  unlocked_by: sectoid_autopsy
  seed_locked: false
```

### Export and Tooling Example

Designers export a craft entry to JSON for analytics purposes. The export includes the complete article table, tab ordering, image asset IDs, and full provenance data (unlock ID, seed flag, unlock timestamp) enabling QA teams to reproduce exact unlock sequences in preview harnesses.

## Related Wiki Pages

- [Research tree.md](../economy/Research%20tree.md) - Research progression and unlocks
- [Geoscape.md](../geoscape/Geoscape.md) - Discovery and exploration mechanics
- [Lore.md](../lore/Lore.md) - Content categories and storytelling
- [Units.md](../units/Units.md) - Unit documentation and entries
- [Items.md](../items/Items.md) - Item documentation and properties
- [SaveSystem.md](../technical/SaveSystem.md) - Data persistence and storage
- [Modding.md](../technical/Modding.md) - Mod integration and custom entries
- [AI.md](../ai/AI.md) - Dynamic content generation
- [Basescape.md](../basescape/Basescape.md) - Research facilities and labs
- [Technical.md](../technical/Technical.md) - Schema definitions and tooling

## References to Existing Games and Mechanics

- **X-COM Series**: Research database and alien codex system
- **Mass Effect Series**: Codex system with progressive unlocks
- **Dragon Age Series**: Codex entries and lore collection
- **Fallout Series**: Pip-Boy database and holotape system
- **The Elder Scrolls Series**: Lore books and in-game encyclopedia
- **Final Fantasy Series**: Bestiary and monster documentation
- **Persona Series**: Compendium system for demons and entries
- **Kingdom Hearts Series**: Encyclopedia and character database
- **Tales Series**: Monster book and collection system
- **Xenoblade Chronicles**: Collectopedia and discovery system

