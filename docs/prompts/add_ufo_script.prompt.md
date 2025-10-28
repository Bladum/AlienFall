# add_ufo_script

Create or update UFO/alien craft behavior and appearance scripts in TOML format.

## Prefix
`ufo_`

## Task Type
Content Creation / Modification

## Description
Create or update UFO script entries in `mods/core/battlescape/` folder. UFO scripts define how alien crafts appear, behave, attack patterns, and interact with player forces during interception and base defense missions.

## Inputs

### Required
- **UFO ID**: Unique identifier (e.g., `ufo_scout_patrol`, `ufo_carrier_mothership`)
- **UFO Name**: Display name for UI
- **UFO Type**: Category - `scout`, `fighter`, `transport`, `carrier`, `mothership`, `specialized`
- **Description**: UFO characteristics and role

### Optional
- **Visual Properties**: Appearance and animation
- **Behavior**: Combat tactics and movement patterns
- **Weapons Configuration**: Armament and targeting
- **Crew**: Unit types and squad composition
- **Performance**: Speed, maneuverability, durability
- **Special Abilities**: Unique capabilities

## Scope

### Affected Files
- `mods/core/battlescape/ai/` (UFO AI scripts)
- Related: Craft definitions
- Related: Unit definitions
- Related: Interception systems

### Validation
- ✓ UFO ID is unique
- ✓ All required TOML fields present
- ✓ UFO type matches valid category
- ✓ Behavior references are valid
- ✓ Unit composition is valid
- ✓ Weapon references exist
- ✓ Performance stats balanced

## TOML Structure Template

```toml
[ufo]
id = "ufo_id"
name = "UFO Display Name"
description = "Description of UFO type and characteristics"
ufo_type = "scout|fighter|transport|carrier|mothership|specialized"
faction = "faction_id"
tags = ["tag1", "tag2"]

[appearance]
visual_model = "model_id"
color_scheme = "color_id"
size = "small|medium|large|huge"
animated = true
animation_style = "hovering|gliding|erratic"

[performance]
speed_cruise = 600
speed_max = 1000
acceleration = 1.2
maneuverability = 0.8
fuel_capacity = 10000
fuel_consumption = 800

[combat_stats]
hull_integrity = 150
armor_value = 30
shield_strength = 50
weapon_hardpoints = 3
defensive_systems = 2

[weapons]
primary_weapon = "weapon_id"
secondary_weapon = "weapon_id"
tertiary_weapon = "weapon_id"
targeting_system = "basic|advanced|military"
fire_rate = 1.0

[crew]
crew_size = 5
crew_composition = ["unit_id"]
commander_type = "unit_id"
pilot_skill = 0.8

[behavior]
behavior_profile = "aggressive|defensive|cautious|hit_and_run"
tactic_style = "ranged|melee|balanced|evasive"
targeting_priority = ["craft", "ground_targets"]
retreat_condition = "health_below_25_percent"
escape_probability = 0.5

[special_abilities]
abilities = ["ability_id"]
special_movement = "cloaking|dimensional_phase"
regeneration_enabled = false

[mission_roles]
suitable_missions = ["patrol", "attack", "escort"]
formation_position = "scout|fighter|support"

[difficulty]
difficulty_modifier = 1.0
experience_reward = 500
threat_level = "high"
```

## Outputs

### Created/Modified
- UFO script entry with complete specification
- Combat stats balanced
- Behavior and tactics configured
- Crew composition defined
- Weapons and abilities established

### Validation Report
- ✓ TOML syntax verified
- ✓ UFO ID uniqueness confirmed
- ✓ All unit references valid
- ✓ Weapon references exist
- ✓ Combat stats balanced
- ✓ Behavior parameters valid
- ✓ Performance reasonable

## Process

1. **Define UFO Type**: Establish role and purpose
2. **Configure Performance**: Set speed and maneuverability
3. **Set Combat Stats**: Balance hull and armor
4. **Assign Weapons**: Configure armament
5. **Compose Crew**: Select unit types
6. **Define Behavior**: Set tactical patterns
7. **Add Abilities**: Configure special powers
8. **Validate**: Check TOML and combat balance
9. **Test**: Encounter UFO in-game and verify behavior
10. **Document**: Update UFO documentation

## Testing Checklist

- [ ] UFO loads without errors
- [ ] UFO appears in interception missions
- [ ] Movement behavior works as specified
- [ ] Combat tactics follow behavior profile
- [ ] Weapons fire correctly
- [ ] Crew spawns properly
- [ ] Hull integrity applies correctly
- [ ] Special abilities function
- [ ] Difficulty scaling works
- [ ] Retreat condition triggers
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] UFO balances with other UFOs

## References

- API: `docs/battlescape/ai-system/`
- Examples: `mods/core/battlescape/ai/`
- Balance Guide: `docs/battlescape/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
