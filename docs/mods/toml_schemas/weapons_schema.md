# Weapons TOML Schema

Complete schema documentation for weapon definitions.

## File Location

```
mods/core/rules/items/weapons.toml
```

## Overview

Weapons define ranged attack equipment with damage, accuracy, range, and ammunition types.

## File Format

Array of weapon tables:
```toml
[[weapon]]
id = "rifle"
# ... fields ...

[[weapon]]
id = "plasma_rifle"
# ... fields ...
```

## Schema Definition

### Required Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | string | Unique identifier | `"rifle"` |
| `name` | string | Display name | `"Rifle"` |
| `type` | string | Weapon type | `"primary"`, `"secondary"` |
| `damage` | number | Damage per shot (0-150) | `50` |
| `accuracy` | number | Hit probability (0-100%) | `70` |
| `range` | number | Maximum range in tiles | `25` |
| `ammo_type` | string | Required ammo ID | `"rifle_ammo"` |

### Optional Fields

| Field | Type | Description | Default |
|-------|------|-------------|---------|
| `description` | string | Longer description | `""` |
| `fire_rate` | number | Shots per turn | `1` |
| `cost` | number | Purchase cost in credits | `0` |
| `tech_level` | string | Technology tier | `"conventional"` |
| `weight` | number | Carrying weight | `1` |
| `critical_chance` | number | Critical hit % (0-100) | `10` |

## Complete Examples

### Conventional Rifle
```toml
[[weapon]]
id = "rifle"
name = "Rifle"
description = "Standard issue rifle"
type = "primary"
damage = 50
accuracy = 70
range = 25
ammo_type = "rifle_ammo"
cost = 800
tech_level = "conventional"
```

### Plasma Rifle
```toml
[[weapon]]
id = "plasma_rifle"
name = "Plasma Rifle"
description = "Standard alien plasma rifle"
type = "primary"
damage = 70
accuracy = 70
range = 25
ammo_type = "plasma_cartridge"
cost = 0
tech_level = "plasma"
```

### Heavy Machine Gun
```toml
[[weapon]]
id = "machine_gun"
name = "Machine Gun"
description = "Rapid-fire heavy weapon"
type = "primary"
damage = 45
accuracy = 50
range = 20
fire_rate = 3
ammo_type = "rifle_ammo"
cost = 1500
tech_level = "conventional"
```

## Field Validation Rules

### Type Field
- `"primary"` - Main weapon (rifle, plasma rifle, sniper rifle)
- `"secondary"` - Sidearm (pistol)
- `"heavy"` - Heavy weapons (machine gun, missile launcher)

### Damage Range
- Conventional: 30-70
- Plasma: 60-100
- Laser: 60-95
- Explosives: 80-150

### Accuracy Range
- Low accuracy: 40-50% (unreliable weapons)
- Medium accuracy: 60-75% (standard weapons)
- High accuracy: 80-95% (precision weapons)

### Tech Level Values
- `"conventional"` - Conventional ballistic weapons
- `"plasma"` - Alien plasma technology
- `"laser"` - Advanced laser technology
- `"dimensional"` - Dimensional weapons

## Usage in Code

```lua
local DataLoader = require("core.data_loader")
DataLoader.load()

-- Get weapon
local weapon = DataLoader.weapons.get("plasma_rifle")
print(weapon.damage)        -- 70
print(weapon.accuracy)      -- 70
print(weapon.range)         -- 25

-- Get all weapons by type
local primaries = DataLoader.weapons.getByType("primary")
local secondaries = DataLoader.weapons.getByType("secondary")
```

---

**Schema Version:** 1.0  
**Last Updated:** October 16, 2025
