# Core Mod Rules: Units

## Goal / Purpose

The Units folder contains unit type specifications and configurations. This defines all unit classes, species, abilities, and stats for combat and strategic units.

## Content

- Unit configuration files (.toml)
- Unit class definitions
- Ability specifications
- Stat and progression data
- Equipment and loadout configurations

## Features

- **Unit Classes**: Different unit types (soldiers, aliens, etc.)
- **Species/Factions**: Aliens, human soldiers, etc.
- **Abilities**: Special abilities and skills
- **Stats**: Health, armor, accuracy, reaction time
- **Progression**: Experience and leveling
- **Equipment**: Weapons and armor slots
- **Personality**: Unit behaviors and traits

## Integrations with Other Systems

### Battlescape
- Units used in tactical combat
- Combat stat calculations
- Ability resolution and effects

### Basescape
- Unit recruitment and training
- Personnel management
- Promotion and experience
- Equipment assignment

### Geoscape
- Strategic military unit availability
- Deployment to regions
- Squad composition

### AI Systems
- Unit capabilities affect AI decisions
- Faction units defined here
- Enemy composition

### Research & Advancement
- New unit classes unlock through research
- Ability progression through tech
- Equipment availability

### Campaign Progression
- Units progress through campaign phases
- New unit types introduced
- Difficulty scaling per unit

### Design Specifications
- Unit design in `design/mechanics/Units.md`
- Ability design in `design/mechanics/`
- Balance parameters

### API Documentation
- Unit format in `api/UNITS.md`
- Ability specs in `api/`
- Equipment in `api/ITEMS.md` and `api/WEAPONS_AND_ARMOR.md`

## Unit Categories

- **Human Soldiers**: Player-controlled combatants
- **Sectoids**: Alien PSI-users
- **Mutons**: Alien heavy hitters
- **Chryssalids**: Alien melee threats
- **Ethereals**: Command units
- **Support**: NPCs and contractors

## See Also

- [Core Mod Rules README](../README.md) - Rules overview
- [Core Mod README](../../README.md) - Core content overview
- [Units API](../../../api/UNITS.md) - Unit specifications
- [Weapons API](../../../api/WEAPONS_AND_ARMOR.md) - Equipment specs
- [Design Units](../../../design/mechanics/Units.md) - Unit design specs
