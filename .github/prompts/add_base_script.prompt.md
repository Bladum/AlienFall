# add_base_script

Create or update base defense system scripts in TOML format.

## Prefix
`base_`

## Task Type
Content Creation / Modification

## Description
Create or update base defense script entries in `mods/core/basescape/` folder. Base scripts define how bases function, respond to attacks, and integrate with defense systems and facility mechanics.

## Inputs

### Required
- **Base Script ID**: Unique identifier (e.g., `base_defense_standard`, `base_underground_secure`)
- **Script Name**: Display name for UI
- **Base Type**: Category - `primary`, `regional`, `underground`, `secret`, `outpost`, `research_facility`
- **Description**: Base design and capabilities

### Optional
- **Defense Systems**: Active defense capabilities
- **Garrison Configuration**: Default units stationed
- **Facility Layout**: Grid arrangement and interactions
- **Defense Mechanics**: How base defends against attacks
- **Special Properties**: Unique base features
- **Strategic Value**: Importance and vulnerability

## Scope

### Affected Files
- `mods/core/basescape/` (base configuration)
- Related: Facility definitions
- Related: Defense systems
- Related: Unit and equipment systems

### Validation
- ✓ Base Script ID is unique
- ✓ All required TOML fields present
- ✓ Base type matches valid category
- ✓ Defense system references valid
- ✓ Unit references exist
- ✓ Facility references valid
- ✓ Grid layout logical

## TOML Structure Template

```toml
[base_script]
id = "base_script_id"
name = "Base Script Display Name"
description = "Description of base design and capabilities"
base_type = "primary|regional|underground|secret|outpost|research_facility"
tags = ["tag1", "tag2"]

[location]
geoscape_region = "region_id"
location_type = "mountain|underground|urban|island|polar"
strategic_importance = "critical|high|moderate|low"

[grid]
grid_width = 8
grid_height = 8
grid_depth = 3  # Underground levels
total_grid_space = 64

[facilities]
starting_facilities = ["facility_id"]
facility_limit = 20
research_labs = 2
manufacturing = 2
storage = 3

[defense]
defense_type = "active|passive|combined"
defense_rating = 75
detection_range = 300
interception_capability = true
ground_defense_available = true

[[defense_systems]]
system_id = "system_1"
system_type = "turret|missile_battery|laser|shield"
position = {x = 2, y = 2}
firing_arc = 360
damage_per_round = 25
rounds_per_minute = 2

[garrison]
starting_garrison_size = 20
garrison_max = 50
garrison_unit_types = ["unit_id"]
combat_effectiveness = 0.8

[personnel]
max_personnel_capacity = 100
max_engineers = 10
max_scientists = 15
max_soldiers = 50

[resources]
starting_funds = 25000
starting_alloys = 200
storage_capacity = 2000
production_capacity = 10

[sustainability]
maintenance_cost_per_day = 500
fuel_consumption_per_day = 100
power_generation = 500
power_consumption = 450

[special_features]
stealth_capable = false
rapid_mobilization = true
research_acceleration = 1.0
manufacturing_bonus = 1.0

[vulnerability]
detection_difficulty = "moderate"
infiltration_risk = 0.3
assault_resistance = 0.8
evacuation_time_hours = 8

[upgrade_paths]
upgrade_available = true
expandable = true
defensibility_improvement = 0.2
```

## Outputs

### Created/Modified
- Base script entry with complete configuration
- Defense systems configured
- Facility layout planned
- Resource systems established
- Garrison structure defined

### Validation Report
- ✓ TOML syntax verified
- ✓ Base Script ID uniqueness confirmed
- ✓ All facility references valid
- ✓ Grid space calculation correct
- ✓ Defense systems positioned validly
- ✓ Garrison configuration sensible
- ✓ Resource sustainability balanced

## Process

1. **Define Base Type**: Establish purpose and security level
2. **Plan Grid Layout**: Design facility arrangement
3. **Configure Defense**: Set defense systems and capabilities
4. **Set Garrison**: Establish starting units
5. **Configure Resources**: Set initial economy
6. **Add Facilities**: Choose starting facilities
7. **Set Sustainability**: Balance costs and income
8. **Validate**: Check TOML and base balance
9. **Test**: Build and manage base in-game
10. **Document**: Update base documentation

## Testing Checklist

- [ ] Base loads without errors
- [ ] Grid layout displays correctly
- [ ] Facilities can be placed
- [ ] Defense systems function
- [ ] Garrison deploys properly
- [ ] Resources generate correctly
- [ ] Maintenance costs apply
- [ ] Upgrades work (if available)
- [ ] Base can defend against attack
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Base balances with other bases
- [ ] Personnel capacity enforced

## References

- API: `docs/basescape/`
- Examples: `mods/core/basescape/`
- Balance Guide: `docs/basescape/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
