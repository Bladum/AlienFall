# Facilities TOML Schema

Complete schema documentation for base facility definitions.

## File Locations

```
mods/core/rules/facilities/base_facilities.toml
mods/core/rules/facilities/research_facilities.toml
mods/core/rules/facilities/manufacturing.toml
mods/core/rules/facilities/defense.toml
```

## Overview

Facilities represent base buildings that provide functions like research, manufacturing, defense, and living space.

## File Format

```toml
[[facility]]
id = "command_center"
# ... fields ...
```

## Schema Definition

### Required Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | string | Unique identifier | `"command_center"` |
| `name` | string | Display name | `"Command Center"` |
| `type` | string | Facility category | `"command"`, `"research"`, `"manufacturing"` |
| `width` | number | Grid width in base (1-4) | `2` |
| `height` | number | Grid height in base (1-3) | `2` |
| `cost` | number | Build cost in credits | `2000` |
| `time_to_build` | number | Construction time in days | `10` |

### Optional Fields

| Field | Type | Description | Default |
|-------|------|-------------|---------|
| `description` | string | Longer description | `""` |
| `maintenance_cost` | number | Monthly cost per facility | `0` |
| `capacity` | number | Storage or personnel capacity | `0` |
| `production_rate` | number | Production speed multiplier | `1.0` |
| `research_rate` | number | Research speed multiplier | `1.0` |
| `specialization` | string | Specialized function | `""` |
| `effect` | string | Game effect ID | `""` |

## Complete Examples

### Command Center
```toml
[[facility]]
id = "command_center"
name = "Command Center"
description = "Strategic command and control center"
type = "command"
width = 2
height = 2
cost = 2000
time_to_build = 10
maintenance_cost = 50
effect = "base_command"
```

### Research Laboratory
```toml
[[facility]]
id = "research_lab"
name = "Research Laboratory"
description = "General scientific research facility"
type = "research"
width = 3
height = 2
cost = 1800
time_to_build = 9
maintenance_cost = 35
research_rate = 1.0
effect = "research_speed"
```

### Weapons Manufacturing
```toml
[[facility]]
id = "manufacturing_weapons"
name = "Weapons Manufacturing"
description = "Weapon production facility"
type = "manufacturing"
width = 3
height = 3
cost = 2000
time_to_build = 10
maintenance_cost = 40
production_rate = 1.5
specialization = "weapons"
```

## Facility Types

### Command
- `command_center` - Main command and control

### Residential
- `living_quarters` - Soldier housing
- `barracks` - Training facilities

### Research
- `research_lab` - General research
- `alien_research` - Alien tech research
- `psionic_lab` - Psionic research
- `chemistry_lab` - Chemical/biological research

### Manufacturing
- `workshop` - General equipment
- `manufacturing_weapons` - Weapons production
- `manufacturing_armor` - Armor production
- `manufacturing_ammunition` - Ammunition production

### Defense
- `defense_cannon` - Anti-air cannons
- `defense_laser` - Laser defenses
- `defense_missile` - Missile systems
- `motion_detection` - Alarm systems

### Support
- `power_generator` - Power generation
- `radar_station` - Detection/coverage
- `med_lab` - Medical treatment
- `storage` - Item storage
- `alien_containment` - Alien prisoners

## Field Validation Rules

### Dimensions
- Width: 1-4 tiles
- Height: 1-3 tiles
- Typical: 2x2 or 3x2

### Type Field
Valid categories:
- `"command"` - Command/control
- `"residential"` - Housing/morale
- `"research"` - Technology research
- `"manufacturing"` - Production
- `"defense"` - Base defense
- `"medical"` - Healing/treatment
- `"storage"` - Storage/capacity
- `"power"` - Power systems
- `"detection"` - Radar/sensors

### Cost Range
- Small (1x1): 500-1000 credits
- Medium (2x2): 800-2000 credits
- Large (3x3): 1500-3000 credits

### Time to Build
Range: 3-15 days (represents in-game weeks)

### Production/Research Rate
- Slow: 0.8x (specialized, high-cost)
- Standard: 1.0x (baseline)
- Fast: 1.2-1.5x (efficient)

## Usage in Code

```lua
local DataLoader = require("core.data_loader")
DataLoader.load()

-- Get facility
local facility = DataLoader.facilities.get("command_center")
print(facility.name)            -- "Command Center"
print(facility.cost)            -- 2000

-- Get facilities by type
local research = DataLoader.facilities.getByType("research")
local defense = DataLoader.facilities.getByType("defense")
```

---

**Schema Version:** 1.0  
**Last Updated:** October 16, 2025
