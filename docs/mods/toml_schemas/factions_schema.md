# Factions TOML Schema

Complete schema documentation for faction definitions.

## File Location

```
mods/core/factions/faction_*.toml
```

Examples:
- `faction_sectoids.toml`
- `faction_mutons.toml`
- `faction_ethereals.toml`

## Overview

Factions represent organized groups (alien species, military, human organizations) with units, technology, and relationships.

## File Format

Single faction per file:

```toml
[faction]
id = "faction_sectoids"
# ... fields ...

[[units]]
type = "sectoid_soldier"
# ... fields ...
```

## Schema Definition

### Faction Section

#### Required Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | string | Unique faction ID | `"faction_sectoids"` |
| `name` | string | Faction display name | `"Sectoid Empire"` |
| `description` | string | Faction description | `"Grey-skinned psionic aliens..."` |
| `type` | string | Faction category | `"alien"`, `"human"` |

#### Optional Fields

| Field | Type | Description | Default |
|-------|------|-------------|---------|
| `tags` | array | Classification tags | `[]` |
| `active_phases` | array | Campaign phases active in | `[]` |
| `tech_level` | string | Technology tier | `"conventional"` |

### Characteristics Section

```toml
[characteristics]
psionic = true
aquatic = false
dimensional = false
primary_trait = "psionic_dominance"
```

### Relationships Section

```toml
[relationships]
allies = ["faction_ethereals"]
enemies = ["xcom"]
neutral = []
```

### Units Array

```toml
[[units]]
type = "sectoid_soldier"
name = "Sectoid Soldier"
# ... unit fields ...
```

### Technology Section

```toml
[technology]
tech_tree = ["plasma_weapons", "psionic_enhancement"]
research_speed = 1.2
```

### Gameplay Section

```toml
[gameplay]
squad_composition = "3-5 soldiers + 1 leader"
tactics = "psionics_focused"
difficulty_modifier = 1.1
appearance_frequency = "common"
```

## Complete Example

### Sectoid Empire Faction

```toml
[faction]
id = "faction_sectoids"
name = "Sectoid Empire"
description = "Grey-skinned psionic aliens, scouts of the Reticulan Cabal"
type = "alien"
tags = ["alien", "psionic", "terrestrial"]
active_phases = ["phase1_sky_war", "phase2_deep_war", "phase3_dimensional_war"]
tech_level = "plasma"

[characteristics]
psionic = true
aquatic = false
dimensional = false
primary_trait = "psionic_dominance"

[relationships]
allies = ["faction_ethereals", "faction_mutons"]
enemies = ["xcom", "faction_blackops"]
neutral = []

[[units]]
type = "sectoid_soldier"
name = "Sectoid Soldier"
count_per_squad = 2
spawn_weight = 10
health = 30
armor = 0
will = 80
reaction = 50
shooting = 50
throwing = 40
strength = 50
psionic_power = 40
psionic_defense = 60
abilities = ["psi_panic", "mind_probe"]
equipment_primary = "plasma_pistol"

[[units]]
type = "sectoid_leader"
name = "Sectoid Leader"
count_per_squad = 1
spawn_weight = 5
health = 40
armor = 0
will = 90
reaction = 55
shooting = 55
throwing = 45
strength = 55
psionic_power = 60
psionic_defense = 70
abilities = ["psi_panic", "mind_control", "resurrection"]
equipment_primary = "plasma_rifle"

[technology]
tech_tree = ["plasma_weapons", "psionic_enhancement", "mind_control_tech"]
research_speed = 1.2

[gameplay]
squad_composition = "3-5 soldiers + 1 leader"
tactics = "psionics_focused"
difficulty_modifier = 1.1
appearance_frequency = "common"
```

## Unit Entry Fields

Each unit array entry defines a unit type available to the faction:

| Field | Type | Description |
|-------|------|-------------|
| `type` | string | Unit type ID (should match units.toml) |
| `name` | string | Display name |
| `count_per_squad` | number | How many spawn per squad |
| `spawn_weight` | number | Probability relative to others (1-10) |
| `health` | number | Hit points |
| `armor` | number | Armor value |
| `will` | number | Morale/psionic defense |
| `reaction` | number | Initiative/evasion |
| `shooting` | number | Ranged accuracy |
| `throwing` | number | Grenade accuracy |
| `strength` | number | Melee damage |
| `psionic_power` | number | Psionic ability |
| `psionic_defense` | number | Psionic resistance |
| `abilities` | array | Special abilities |
| `equipment_primary` | string | Main weapon |

## Field Validation Rules

### Type Field
- `"alien"` - Extraterrestrial species
- `"human"` - Human factions
- `"hybrid"` - Mixed/genetically modified

### Tags
Common tags:
- `"alien"`, `"human"`, `"supernatural"`
- `"psionic"`, `"melee"`, `"ranged"`
- `"terrestrial"`, `"aquatic"`, `"dimensional"`
- `"leader"`, `"common"`, `"elite"`

### Characteristics

| Field | Type | Meaning |
|-------|------|---------|
| `psionic` | boolean | Has psionic abilities |
| `aquatic` | boolean | Can fight underwater |
| `dimensional` | boolean | Uses dimensional tech |
| `primary_trait` | string | Main characteristic |

### Appearance Frequency
- `"rare"` - Rarely encountered
- `"uncommon"` - Sometimes encountered
- `"common"` - Frequently encountered
- `"constant"` - Always present

### Squad Composition
Examples:
- `"3-5 soldiers + 1 leader"`
- `"2-4 soldiers + 1-2 specialists"`
- `"solo_unit"` - Single strong unit
- `"swarm"` - Many weak units

## Usage in Code

```lua
local DataLoader = require("core.data_loader")
DataLoader.load()

-- Get faction
local faction = DataLoader.factions.get("faction_sectoids")
print(faction.name)                 -- "Sectoid Empire"

-- Get faction units
local units = faction.units
for _, unit in ipairs(units) do
    print(unit.name)
end

-- Get faction by type
local aliens = DataLoader.factions.getByType("alien")
```

---

**Schema Version:** 1.0  
**Last Updated:** October 16, 2025
