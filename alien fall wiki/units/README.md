# Units Overview

Units are the heart of AlienFall’s tactical and strategic layers. This README consolidates action economy, progression, and personnel management with Love2D implementation notes.

## Role in AlienFall
- Represent soldiers, agents, civilians, and aliens across battlescape, geoscape, and narrative scenes.
- Provide progression hooks (experience, traits, medals) that mirror campaign performance.
- Consume resources (salaries, training time) and require base infrastructure for upkeep.

## Player Experience Goals
- **Distinct archetypes:** Classes and traits create clear tactical identities.
- **Persistent consequences:** Injuries, trauma, and morale affect both short- and long-term play.
- **Agency & attachment:** Players customise loadouts, names, and backgrounds and feel responsible for outcomes.

## System Boundaries
- Covers stats, AP, energy, inventory, encumbrance, experience, promotions, traits, injuries, recruitment, salaries, and transformations.
- Interfaces with items (gear), battlescape (combat), basescape (healing/training), economy (costs), and organization (fame/karma impacts).

## Core Mechanics
### Attributes & Resources
- Core stats: Health, Stamina, Accuracy, Reflexes, Strength, Mind, Morale.
- Action Points (AP) govern turn actions; Energy (where applicable) fuels abilities.
- Encumbrance reduces AP and increases stamina drain; thresholds stored in `data/units/encumbrance.toml`.

### Classes & Traits
- Base classes (Scout, Assault, Support, Heavy, Psi) define baseline stats and unlockable abilities.
- Traits include positive, neutral, and negative modifiers; acquired through promotion, events, or trauma.
- Transformations (cybernetic, psionic, mutation) offer late-game specialisation with trade-offs.

### Progression
- Experience gained from missions, training, and events. Promotion thresholds deterministic per class.
- Ranks confer stat boosts and unlock abilities; stored in `data/units/ranks.toml`.
- Medals record achievements; each medal grants optional trait choices.

### Recruitment & Salaries
- Recruitment pools refresh monthly with candidates tagged by origin (`military`, `scientist`, `resistance`).
- Salaries and upkeep deducted during finance month-end processing. Desertion risk triggers if payments lapse.

### Injuries & Recovery
- Injuries convert mission damage into recovery timers using deterministic tables.
- Sanity and morale damage tracked separately; extended trauma can generate negative traits.
- Medical facilities reduce recovery time via basescape services.

## Implementation Hooks
- **Data Tables:** `stats.toml`, `classes.toml`, `traits.toml`, `ranks.toml`, `medals.toml`, `recruitment.toml`, `injuries.toml`.
- **Event Bus:** `unit:recruited`, `unit:promoted`, `unit:injured`, `unit:recovered`, `unit:trait_added`, `unit:dismissed`, `unit:died`.
- **Love2D Rendering:** Unit portrait widgets use 20×20 logical frames with layered 10×10 sprite components (face, armour, insignia).
- **Save Data:** Persist stats, traits, injuries, medals, equipment, and personal history.

## Grid & Visual Standards
- Barracks UI uses 20×20 tiles; roster list items occupy 20×80 logical pixels.
- Tactical overlays (movement, suppression) use grid-aligned highlights consistent with the battlescape spec.

## Data & Tags
- Class tags: `scout`, `assault`, `support`, `heavy`, `psi`.
- Trait tags: `positive`, `negative`, `combat`, `psych`, `cybernetic`, `mutant`.
- Recruitment tags: `military`, `scientist`, `engineer`, `resistance`. 

## Related Reading
- [Items README](../items/README.md)
- [Battlescape README](../battlescape/README.md)
- [Basescape README](../basescape/README.md)
- [Economy README](../economy/README.md)
- [Organization README](../organization/README.md)

## Tags
`#units` `#progression` `#battlescape` `#love2d`
