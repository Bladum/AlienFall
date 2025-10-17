# Rules Directory

Game rules and definitions for units, items, facilities, and missions.

## Subdirectories

- **units/**: Unit type definitions (soldiers, aliens, civilians)
- **items/**: Item definitions (weapons, armour, ammo, equipment)
- **facilities/**: Base facility definitions with effects
- **missions/**: Mission type definitions and configurations

## Loading Rules

Rules are loaded through `DataLoader`:

```lua
DataLoader.loadUnits()
DataLoader.loadItems()
DataLoader.loadFacilities()
DataLoader.loadMissions()
```

## File Format

All files use TOML 1.0.0 format. See `docs/mods/toml_schemas/` for schema details.
