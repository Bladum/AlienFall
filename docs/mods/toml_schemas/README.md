# TOML Schemas Documentation

Complete documentation for all TOML file schemas used in AlienFall mod content.

## Overview

All mod content in AlienFall is defined using TOML files (version 1.0.0). This directory contains comprehensive schema documentation for each content type, including:
- Required fields
- Optional fields
- Data types and valid ranges
- Relationships between content types
- Complete examples

## Content Types (13 Schemas)

| File | Content Type | Location | Purpose |
|------|--------------|----------|---------|
| [units_schema.md](units_schema.md) | Units | `mods/core/rules/units/` | Soldier, alien, civilian definitions |
| [weapons_schema.md](weapons_schema.md) | Weapons | `mods/core/rules/items/weapons.toml` | Weapon stats and combat properties |
| [armours_schema.md](armours_schema.md) | Armour | `mods/core/rules/items/armours.toml` | Protection gear and equipment |
| [items_schema.md](items_schema.md) | Items/Equipment | `mods/core/rules/items/` | Grenades, medkits, utility equipment |
| [facilities_schema.md](facilities_schema.md) | Facilities | `mods/core/rules/facilities/` | Base buildings and structures |
| [missions_schema.md](missions_schema.md) | Missions | `mods/core/rules/missions/` | Mission definitions and parameters |
| [campaigns_schema.md](campaigns_schema.md) | Campaigns | `mods/core/campaigns/` | Campaign phases and timelines |
| [factions_schema.md](factions_schema.md) | Factions | `mods/core/factions/` | Faction definitions with units and tech |
| [technology_schema.md](technology_schema.md) | Technology | `mods/core/technology/` | Research trees and tech progression |
| [narrative_schema.md](narrative_schema.md) | Narrative | `mods/core/narrative/` | Story events and dialogue |
| [geoscape_schema.md](geoscape_schema.md) | Geoscape | `mods/core/geoscape/` | World map and countries |
| [economy_schema.md](economy_schema.md) | Economy | `mods/core/economy/` | Marketplace and funding systems |

## Quick Reference

### Creating New Content

1. **Choose content type** - See table above to find relevant schema
2. **Read schema documentation** - Understand required vs optional fields
3. **Use example TOML** - Copy and modify provided examples
4. **Validate with ModManager** - Test with `DataLoader.load()`
5. **Debug with console** - Watch Love2D console for errors

### Example: Adding a New Weapon

```toml
# mods/core/rules/items/weapons.toml

[[weapon]]
id = "plasma_cannon_mk2"
name = "Plasma Cannon MK2"
description = "Upgraded plasma cannon with increased damage"
type = "primary"
damage = 100
accuracy = 65
range = 30
ammo_type = "plasma_cartridge"
cost = 3000
tech_level = "advanced_plasma"
```

Then access it in code:
```lua
local weapon = DataLoader.weapons.get("plasma_cannon_mk2")
print(weapon.damage)  -- 100
```

## Field Type Glossary

| Type | Format | Example | Notes |
|------|--------|---------|-------|
| `string` | Text | `"soldier_rookie"` | Use quotes for text |
| `number` | Integer or float | `30`, `45.5` | No quotes |
| `boolean` | true/false | `true` | Lowercase, no quotes |
| `array` | `[value1, value2]` | `["ability1", "ability2"]` | Comma-separated list |
| `table` | `{ key = value }` | `{ health = 30, armor = 10 }` | Key-value pairs |
| `datetime` | YYYY-MM-DD | `1996-01-15` | ISO 8601 format |

## Common Patterns

### Stat Objects
Most units have stat objects:
```toml
[unit.stats]
health = 30
armor = 0
will = 60
reaction = 50
shooting = 50
throwing = 40
strength = 50
psionic_power = 0
psionic_defense = 40
```

### Equipment Slots
Define what equipment units can carry:
```toml
[unit.equipment]
primary = "rifle"
secondary = "pistol"
armor = "combat_armor_light"
grenades = ["hand_grenade"]
```

### Arrays of Objects
Use `[[section.name]]` for arrays:
```toml
[[unit]]
id = "soldier_rookie"
# ...

[[unit]]
id = "soldier_squaddie"
# ...
```

## Validation & Debugging

### Check Console Output

Run game with `lovec "engine"` and watch for:
```
[DataLoader] ✓ Loaded 25 weapons
[DataLoader] ✓ Loaded 10 facilities
```

### Common Errors

**Missing file:**
```
[DataLoader] ERROR: Failed to load weapons
```
→ Check file path in `mods/core/rules/items/weapons.toml`

**Invalid TOML syntax:**
```
[DataLoader] ERROR: Failed to load TOML file
```
→ Validate TOML at [TOML Validator](https://www.toml-lint.com)

**Missing required field:**
```
[DataLoader] ERROR: Missing expected key 'weapon'
```
→ Check schema documentation for required fields

## Best Practices

1. **Use meaningful IDs** - `soldier_rookie`, not `unit_1`
2. **Provide descriptions** - Help other modders understand content
3. **Include costs** - Balance gameplay economics
4. **Specify tech levels** - Show progression: conventional → plasma → laser → dimensional
5. **Test in game** - Run and verify content loads correctly
6. **Use examples** - Copy from existing TOML files and modify
7. **Keep organized** - One file per content category (soldiers.toml, aliens.toml, etc.)

## Related Documentation

- **API Reference**: `docs/API.md`
- **Mod Development Guide**: `docs/mods/modding_guide.md`
- **Core Mod README**: `mods/core/README.md`
- **Data Loader Source**: `engine/core/data_loader.lua`

## Troubleshooting

### Content not loading?

1. Check file location matches schema documentation
2. Verify TOML syntax is valid
3. Ensure IDs don't have spaces or special characters
4. Watch console output for specific errors
5. Compare with provided examples

### ID conflicts?

Use unique prefixes:
```toml
id = "faction_sectoids_soldier"  # Avoid conflicts
id = "faction_mutons_soldier"
```

### Array loading issues?

Use `[[item]]` syntax for arrays:
```toml
[[weapon]]
id = "rifle"
# ...

[[weapon]]
id = "pistol"
# ...
```

NOT:
```toml
[weapons]
[[weapon]]  # ← Wrong! This won't parse correctly
```

## Contributing

To add new content types:

1. Create new schema documentation file
2. Add loader function to `engine/core/data_loader.lua`
3. Update `mods/core/` with template TOML files
4. Document in this README

---

**Last Updated:** October 16, 2025  
**TOML Version:** 1.0.0  
**AlienFall Version:** Development
