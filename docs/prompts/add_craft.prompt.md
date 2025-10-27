# add_craft

Create or update aircraft and vehicle definitions in TOML format.

## Prefix
`craft_`

## Task Type
Content Creation / Modification

## Description
Create or update craft entries for aircraft and vehicles used in Geoscape and Basescape. Crafts include interceptors, transports, and specialized vehicles with weapons, sensors, and equipment.

## Inputs

### Required
- **Craft ID**: Unique identifier (e.g., `interceptor_basic`, `transport_heavy`, `scout_ufo`)
- **Craft Name**: Display name for UI
- **Craft Type**: Category - `interceptor`, `transport`, `scout`, `specialized`, `ufo`
- **Description**: Role and primary function

### Optional
- **Performance Stats**: Speed, fuel consumption, radar range
- **Capacity**: Troop transport capacity, cargo space
- **Weapons**: Mounted weaponry and defensive systems
- **Sensors**: Detection and targeting systems
- **Armor/Hull**: Defensive capabilities
- **Crew Requirements**: Pilot and specialist needs
- **Maintenance Costs**: Operational expenses
- **Fuel System**: Fuel tank capacity and consumption

## Scope

### Affected Files
- `mods/core/economy/crafts.toml` (or create if needed)
- Related: `mods/core/geoscape/` (for geoscape integration)
- Related: `mods/core/basescape/` (for base deployment)
- Related: `mods/core/economy/` (for manufacturing/upgrades)

### Validation
- ✓ Craft ID is unique
- ✓ All required TOML fields present
- ✓ Craft type matches valid category
- ✓ Performance stats are reasonable
- ✓ Weapon references exist
- ✓ Capacity values are positive integers
- ✓ No circular equipment dependencies
- ✓ Cross-references validated

## TOML Structure Template

```toml
[[crafts]]
id = "craft_id"
name = "Craft Display Name"
description = "Description of craft role and capabilities"
type = "interceptor|transport|scout|specialized|ufo"
faction = "faction_id"
tags = ["tag1", "tag2"]

[performance]
speed_cruise = 800
speed_max = 1200
acceleration = 1.5
fuel_capacity = 5000
fuel_consumption_per_hour = 500
radar_range = 500
detection_range = 300

[physical]
length = 15.5
width = 8.2
height = 4.8
weight_empty = 5000
weight_max = 7500

[capacity]
crew_pilot = 1
crew_specialist = 2
troop_capacity = 12
cargo_capacity = 500

[weapons]
primary_weapon = "weapon_id"
secondary_weapon = "weapon_id"
defensive_system = "defense_id"
turret_count = 2
ammo_capacity = 250

[armor]
hull_strength = 100
shield_value = 20
damage_resistance = [0.8, 0.9, 0.7]

[maintenance]
upkeep_cost_per_day = 100
repair_cost_per_damage_point = 50
maintenance_interval_days = 30

[sensors]
sensor_type = "basic|advanced|military"
identification_range = 400
tracking_capacity = 10
```

## Outputs

### Created/Modified
- Craft entry in TOML file with specifications
- Performance values balanced for game progression
- Equipment slots validated
- Capacity and cost values consistent

### Validation Report
- ✓ TOML syntax verified
- ✓ Craft ID uniqueness confirmed
- ✓ All equipment references valid
- ✓ Performance stats balanced
- ✓ Capacity values reasonable
- ✓ Maintenance costs consistent
- ✓ No conflicts with existing crafts

## Process

1. **Query Existing Crafts**: Check for duplicates and similar designs
2. **Define Specifications**: Gather performance and capacity requirements
3. **Balance Stats**: Ensure progression appropriateness
4. **Configure Equipment**: Set valid weapon and sensor references
5. **Determine Costs**: Calculate manufacturing and maintenance expenses
6. **Validate**: Check TOML and cross-references
7. **Test**: Deploy craft in-game and verify stats
8. **Document**: Update crafts documentation

## Testing Checklist

- [ ] Craft loads without errors
- [ ] Stats display correctly in base/geoscape UI
- [ ] Equipment slots populate correctly
- [ ] Weapons mount and function properly
- [ ] Fuel consumption calculates correctly
- [ ] Cargo capacity functions as expected
- [ ] Maintenance costs apply properly
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Craft appears in appropriate selections

## References

- API: `docs/geoscape/` and `docs/basescape/`
- Examples: `mods/core/geoscape/crafts.toml`
- Balance Guide: `docs/content/crafts/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
