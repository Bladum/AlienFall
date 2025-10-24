# Core Mod Rules: Crafts

## Goal / Purpose

The Crafts folder contains spacecraft specifications and configurations. This defines all aircraft that can be built, equipped, and used for missions and interception.

## Content

- Craft configuration files (.toml)
- Craft specifications and stats
- Craft equipment specifications
- Craft capability definitions

## Features

- **Craft Types**: Different spacecraft for different roles
- **Stats & Capabilities**: Speed, armor, capacity, weapons
- **Equipment Slots**: Hardpoints for weapons and equipment
- **Maintenance**: Costs and resource requirements
- **Crew Management**: Personnel requirements
- **Fuel Systems**: Range and fuel consumption
- **Upgrades**: Enhancement progression

## Integrations with Other Systems

### Geoscape
- Crafts shown on world map
- Used for missions and interception
- Regional craft presence affects strategy

### Interception System
- Crafts used for UFO interception
- Combat capabilities in air battles
- Damage and repair mechanics

### Basescape
- Crafts stored in hangars
- Personnel assigned to craft
- Maintenance facility requirements
- Equipment/weapon loadout

### Research & Manufacturing
- New craft unlock through research
- Craft upgrades available
- Production time and resource costs

### Mission System
- Crafts used for troop transport
- Craft capabilities affect mission options
- Personnel deployment via craft

### Design Specifications
- Craft design in `design/mechanics/Crafts.md`
- Balance in `design/mechanics/`

### API Documentation
- Craft format in `api/CRAFTS.md`
- Weapon hardpoints in `api/WEAPONS_AND_ARMOR.md`
- Equipment specs in `api/ITEMS.md`

## Craft Categories

- **Scout**: Fast reconnaissance aircraft
- **Interceptor**: Air-to-air combat
- **Transport**: Troop transport
- **Bomber**: Heavy weapons platform
- **Utility**: Specialized roles

## See Also

- [Core Mod Rules README](../README.md) - Rules overview
- [Core Mod README](../../README.md) - Core content overview
- [Crafts API](../../../api/CRAFTS.md) - Craft specifications
- [Weapons API](../../../api/WEAPONS_AND_ARMOR.md) - Weapon specs
- [Interception System](../../../engine/interception/README.md) - Air combat
