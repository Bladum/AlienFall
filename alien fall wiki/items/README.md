# Items Overview

Items deliver combat power, strategic resources, and story flavour. This README presents the definitive plan for weapon stats, damage models, and manufacturing hooks under the Love2D implementation.

## Role in AlienFall
- Empower units, crafts, and facilities with equipment that shapes tactics and strategy.
- Provide resource sinks and rewards across manufacturing, research, and missions.
- Embed lore and campaign progression into collectible artefacts.

## Player Experience Goals
- **Readable stats:** Damage, accuracy bands, and action costs are understandable at a glance.
- **Meaningful upgrades:** New items should feel like sidegrades or upgrades with clear trade-offs.
- **Unified handling:** Whether on a soldier, craft, or base, items obey consistent rules for damage and resource usage.

## System Boundaries
- Covers personal gear, craft weapons, base defenses, consumables, resources, lore artefacts, and manufacturing recipes.
- Interfaces with battlescape (unit actions), interception (craft loadouts), economy (manufacturing, suppliers), units (encumbrance), and lore/pedia (unlock text).

## Core Mechanics
### Taxonomy & Tags
- Items are grouped into families: `weapon`, `armor`, `utility`, `consumable`, `resource`, `craft_weapon`, `facility_module`, `lore`.
- Damage types (kinetic, energy, plasma, chemical, psionic) determine mitigation interactions; data stored in `data/items/damage_types.toml`.
- Tags (e.g., `armor_piercing`, `splash`, `underwater`, `support`) drive availability and AI evaluation.

### Damage Model
- Base damage + spread + critical multiplier.
- Armour pierce and resistances apply before final HP deduction; leftover damage can convert to wounds or structure damage.
- Area effects use deterministic templates keyed to the 20×20 grid to ensure reproducible blast footprints.

### Action Economy
- Each item lists AP cost, energy cost (if applicable), cooldown, and ammo usage per action.
- Multi-mode weapons define separate action entries (single shot, burst, auto) sharing ammo pools but distinct AP costs.
- Consumables may apply status effects or spawn entities; all effects logged for replay.

### Manufacturing & Resources
- Recipes specify inputs (resources, credits, research tags) and outputs. Manufacturing times scale with workshop bonuses.
- Resources (alloys, elerium, biomatter) have rarity tiers and black-market value.
- Lore items unlock pedia entries and may provide bonuses or story beats when analysed.

## Implementation Hooks
- **Data Tables:**
	- `data/items/items.toml` – master list with stats, tags, unlock requirements.
	- `data/items/recipes.toml` – manufacturing inputs/outputs.
	- `data/items/damage_types.toml` – resistances and mitigation formulas.
	- `data/items/status_effects.toml` – shared status definitions.
- **Event Bus:** `item:equipped`, `item:unequipped`, `item:used`, `item:crafted`, `item:destroyed`, `item:analyzed`.
- **Love2D Rendering:** Item icons are 10×10 sprites scaled ×2; UI slot backgrounds snap to the 20×20 grid.
- **Localization:** Pedia names and descriptions stored alongside item data for multi-language support.

## Grid & Visual Standards
- Equipment screens align slot grids to 20×20 pixels; drag/drop hotspots match the same step.
- Blast templates overlay translucent 20×20 tiles to show affected area before confirmation.

## Data & Tags
- Weapon tags: `rifle`, `pistol`, `heavy`, `melee`, `grenade`, `psionic`.
- Armor tags: `light`, `medium`, `heavy`, `hazard`, `naval`, `underwater`.
- Resource tags: `alloy`, `elerium`, `biomass`, `intelligence`, `currency`.

## Related Reading
- [Units README](../units/README.md)
- [Battlescape README](../battlescape/README.md)
- [Crafts README](../crafts/README.md)
- [Economy README](../economy/README.md)
- [Pedia README](../pedia/README.md)

## Tags
`#items` `#damage` `#manufacturing` `#love2d` `#grid20x20`
