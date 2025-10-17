# Units TOML Schema

Complete schema documentation for unit definitions.

## File Location

```
mods/core/rules/units/soldiers.toml
mods/core/rules/units/aliens.toml
mods/core/rules/units/civilians.toml
```

## Overview

Units represent individual soldiers, aliens, and civilians in the game. Each unit has stats, equipment, and abilities.

## File Format

Array of unit tables:
```toml
[[unit]]
id = "unit_id_here"
# ... fields ...

[[unit]]
id = "another_unit"
# ... fields ...
```

## Schema Definition

### Required Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | string | Unique identifier | `"soldier_rookie"` |
| `name` | string | Display name | `"Rookie Soldier"` |
| `type` | string | Unit type | `"soldier"`, `"alien"`, `"civilian"` |
| `side` | string | Which side: human/alien/civilian | `"human"` |

### Optional Fields

| Field | Type | Description | Default |
|-------|------|-------------|---------|
| `description` | string | Longer description | `""` |
| `faction` | string | Faction ID | `"unaffiliated"` |
| `image` | string | Sprite path | `"units/generic.png"` |
| `rank` | string | Military rank | `"private"` |

### Stats Object

All units should have a `[unit.stats]` table with combat statistics:

```toml
[unit.stats]
health = 30              # Hit points (1-100)
armor = 0               # Damage reduction (0-30)
will = 60               # Morale/Psionic resistance (0-100)
reaction = 50           # Initiative/Evasion (0-100)
shooting = 50           # Accuracy with ranged weapons (0-100)
throwing = 40           # Grenade accuracy (0-100)
strength = 50           # Melee damage/carry capacity (0-100)
psionic_power = 0       # Psionic ability strength (0-100)
psionic_defense = 40    # Psionic resistance (0-100)
```

**Ranges:** All stats 0-100, where 50 is average human/alien ability

### Abilities Object (Optional)

Define special abilities:

```toml
[unit.abilities]
psi_panic = "psi_panic"
mind_control = "mind_control_weak"
resurrection = "restore_corpses"
melee_attack = "claw_strike"
leadership = "command_aura"
healing = "field_medic"
```

### Equipment Object

Define starting equipment:

```toml
[unit.equipment]
primary = "rifle"                    # Main weapon
secondary = "pistol"                 # Sidearm (optional)
armor = "combat_armor_light"         # Armor type
grenades = ["hand_grenade"]          # Available grenades (array)
```

All equipment must reference valid IDs from:
- `weapons.toml` for weapons
- `armours.toml` for armor
- `equipment.toml` for grenades/items

## Complete Example

### Rookie Soldier
```toml
[[unit]]
id = "soldier_rookie"
name = "Rookie Soldier"
description = "Untrained soldier with basic equipment"
type = "soldier"
faction = "xcom"
side = "human"
image = "units/soldier.png"
rank = "rookie"

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

[unit.equipment]
primary = "rifle"
secondary = "pistol"
armor = "combat_armor_light"
grenades = ["hand_grenade"]
```

### Veteran Sergeant
```toml
[[unit]]
id = "soldier_sergeant"
name = "Sergeant"
description = "Squad leader with leadership abilities"
type = "soldier"
faction = "xcom"
side = "human"
image = "units/soldier.png"
rank = "sergeant"

[unit.stats]
health = 40
armor = 0
will = 70
reaction = 60
shooting = 60
throwing = 50
strength = 60
psionic_power = 0
psionic_defense = 50

[unit.abilities]
leadership = "command_aura"

[unit.equipment]
primary = "rifle"
secondary = "pistol"
armor = "combat_armor_heavy"
grenades = ["hand_grenade", "proximity_grenade"]
```

### Sectoid Alien
```toml
[[unit]]
id = "sectoid_soldier"
name = "Sectoid Soldier"
description = "Grey-skinned psionic alien, foot soldier"
type = "alien"
faction = "faction_sectoids"
side = "alien"
image = "units/sectoid.png"
rank = "common"

[unit.stats]
health = 30
armor = 0
will = 80
reaction = 50
shooting = 50
throwing = 40
strength = 50
psionic_power = 40
psionic_defense = 60

[unit.abilities]
psi_panic = "psi_panic"
mind_control = "mind_control_weak"

[unit.equipment]
primary = "plasma_pistol"
secondary = "none"
armor = "none"
```

## Field Validation Rules

### ID Field
- Must be unique across all units
- Use snake_case: `soldier_rookie`, not `SoldierRookie`
- Start with faction/type: `sectoid_soldier`, `alien_floater`
- No spaces or special characters

### Type Field
Valid values:
- `"soldier"` - Human soldiers
- `"alien"` - Alien unit
- `"heavy"` - Heavy weapons specialist
- `"sniper"` - Sniper class
- `"support"` - Support/medic class
- `"civilian"` - Non-combatant

### Side Field
Valid values:
- `"human"` - XCOM and human units
- `"alien"` - All alien species
- `"civilian"` - Civilians

### Faction Field
Should match valid faction IDs:
- `"xcom"` - XCOM organization
- `"faction_sectoids"` - Sectoid faction
- `"faction_mutons"` - Muton faction
- `"faction_ethereals"` - Ethereal faction
- `"civilian"` - Civilian faction

### Rank Field
Common values:
- `"rookie"` - Lowest rank
- `"squaddie"` - Standard soldier
- `"sergeant"` - Squad leader
- `"leader"` - High-ranking unit
- `"commander"` - Faction commander
- `"common"` - Generic alien
- `"elite"` - Elite alien

## Usage in Code

```lua
local DataLoader = require("core.data_loader")
DataLoader.load()

-- Get specific unit
local unit = DataLoader.units.get("soldier_rookie")
print(unit.name)              -- "Rookie Soldier"
print(unit.stats.health)      -- 30

-- Get all units
local unitIds = DataLoader.units.getAllIds()
for _, id in ipairs(unitIds) do
    local unit = DataLoader.units.get(id)
    print(unit.name)
end

-- Get units by faction
local xcomUnits = DataLoader.units.getByFaction("xcom")

-- Get units by side
local humanUnits = DataLoader.units.getBySide("human")
local alienUnits = DataLoader.units.getBySide("alien")
```

## Best Practices

1. **Balanced stats** - Average soldier should have ~50 across most stats
2. **Progressive upgrade** - Rookies weaker than veterans
3. **Faction characteristics** - All sectoids should be psionic-focused
4. **Equipment matching** - Aliens shouldn't have human weapons
5. **Unique abilities** - Each type should have special abilities
6. **Consistent naming** - Use prefixes like `faction_sectoids_` for all units

## Common Mistakes

❌ **Wrong:**
```toml
[unit]
id = soldier_rookie         # No quotes
name = Rookie Soldier       # No quotes
stats.health = 30           # Wrong structure
```

✅ **Correct:**
```toml
[[unit]]
id = "soldier_rookie"
name = "Rookie Soldier"

[unit.stats]
health = 30
```

---

**Schema Version:** 1.0  
**Last Updated:** October 16, 2025
