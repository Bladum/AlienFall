# add_unit

Create or update unit definitions for soldiers, aliens, and NPC characters in TOML format.

## Prefix
`unit_`

## Task Type
Content Creation / Modification

## Description
Create or update unit entries in `mods/core/` folder. Units represent characters in battle including soldiers, aliens, civilians, and special units. Each unit has attributes, abilities, equipment slots, and AI behavior.

## Inputs

### Required
- **Unit ID**: Unique identifier (e.g., `soldier_basic`, `sectoid_warrior`, `ethereal_commander`)
- **Unit Name**: Display name for UI
- **Unit Type**: Category - `soldier`, `alien`, `civilian`, `elite`, `commander`
- **Description**: Role and characteristics of the unit

### Optional
- **Base Stats**: Health, armor, will, reaction, skills
- **Abilities**: Special powers and tactical abilities
- **Equipment Slots**: Loadout configuration
- **AI Behavior**: Tactical decision patterns
- **Faction Affiliation**: Which faction/organization uses this unit
- **Progression**: Experience levels, stat growth

## Scope

### Affected Files
- `mods/core/factions/faction_*.toml` (for alien units)
- `mods/core/units/` (if created, or game-specific directory)
- Related: `mods/core/technology/` (for abilities/equipment)
- Related: `mods/core/economy/items.toml` (for equipment references)

### Validation
- ✓ Unit ID is unique
- ✓ All required TOML fields present
- ✓ Unit type matches valid category
- ✓ Stats are balanced (0-100 scale or specified range)
- ✓ Equipment slots exist in inventory system
- ✓ Abilities are defined and available
- ✓ No circular dependencies
- ✓ Faction references are valid

## TOML Structure Template

```toml
[[units]]
id = "unit_id"
name = "Unit Display Name"
description = "Description of unit role and abilities"
type = "soldier|alien|civilian|elite|commander"
faction = "faction_id"
tags = ["tag1", "tag2"]

[stats]
health_max = 100
armor = 5
will = 80
reaction = 50
strength = 60
accuracy = 55
throwing = 45
psionic_power = 30
psionic_defense = 40

[physical]
height = "average"
weight = 75
gender = "male|female|neutral"
appearance = "human|alien_type"

[abilities]
available = ["ability_id1", "ability_id2"]
starting_abilities = ["ability_id1"]
ability_trees = ["tree_name"]

[equipment]
primary_slot = "item_id"
secondary_slot = "item_id"
armor_slot = "armor_id"
utility_slots = 2
special_equipment = ["item_id"]

[experience]
experience_points = 0
level = 1
level_max = 20
experience_per_level = 1000

[ai]
behavior = "aggressive|defensive|cautious|support"
tactics = "ranged|melee|balanced"
difficulty_modifier = 1.0
```

## Outputs

### Created/Modified
- Unit entry in TOML file with all attributes
- Proper stat balancing
- Ability and equipment references validated
- AI configuration defined

### Validation Report
- ✓ TOML syntax verified
- ✓ Unit ID uniqueness confirmed
- ✓ Stats balanced against other units
- ✓ All equipment references valid
- ✓ All abilities defined
- ✓ Faction exists
- ✓ No conflicts

## Process

1. **Check Existing Units**: Verify no duplicate unit IDs
2. **Define Unit Role**: Determine purpose and category
3. **Balance Stats**: Ensure appropriate difficulty level
4. **Configure Equipment**: Set valid item references
5. **Define Abilities**: Reference or create ability definitions
6. **Set AI Behavior**: Configure tactical behavior
7. **Validate**: Check TOML and cross-references
8. **Test**: Spawn unit in battle and verify stats/abilities

## Testing Checklist

- [ ] Unit spawns without errors
- [ ] Stats display correctly in UI
- [ ] Equipment loads properly
- [ ] Abilities activate correctly
- [ ] AI behavior follows configuration
- [ ] Unit balances with similar units
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Unit appears in appropriate UI lists
- [ ] Faction display is correct

## References

- API: `docs/battlescape/unit-systems/`
- Examples: `mods/core/factions/faction_sectoids.toml`
- Balance Guide: `docs/content/units/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
