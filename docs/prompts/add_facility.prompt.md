# add_facility

Create or update base facility definitions in TOML format.

## Prefix
`facility_`

## Task Type
Content Creation / Modification

## Description
Create or update facility entries in `mods/core/basescape/facilities/` folder. Facilities are base buildings providing manufacturing, research, training, storage, and strategic capabilities within the base grid system.

## Inputs

### Required
- **Facility ID**: Unique identifier (e.g., `facility_laboratory`, `facility_hangar`, `facility_barracks`)
- **Facility Name**: Display name for UI
- **Facility Type**: Category - `research`, `manufacturing`, `storage`, `training`, `command`, `defense`, `utility`
- **Description**: Facility purpose and functionality

### Optional
- **Grid Size**: Base grid footprint (e.g., 2x2, 3x1)
- **Construction Cost**: Time and resources to build
- **Maintenance Cost**: Daily operational expense
- **Capacity**: Storage, manufacturing speed, or research boost
- **Production Output**: What facility produces (if applicable)
- **Requirements**: Technology or level prerequisites
- **Special Properties**: Unique abilities or restrictions
- **Upgrade Paths**: Available enhancements

## Scope

### Affected Files
- `mods/core/basescape/facilities/*.toml`
- Related: `mods/core/technology/` (for tech requirements)
- Related: `mods/core/economy/` (for costs and production)
- Related: Base management systems

### Validation
- ✓ Facility ID is unique
- ✓ All required TOML fields present
- ✓ Facility type matches valid category
- ✓ Grid dimensions are positive integers
- ✓ Costs are reasonable and balanced
- ✓ Technology requirements exist
- ✓ Production values are valid
- ✓ No circular upgrade dependencies

## TOML Structure Template

```toml
[facility]
id = "facility_id"
name = "Facility Display Name"
description = "Description of facility function and purpose"
type = "research|manufacturing|storage|training|command|defense|utility"
category = "subcategory"
tags = ["tag1", "tag2"]

[placement]
grid_width = 2
grid_height = 2
buildable_outdoors = true
buildable_underground = true
placement_restrictions = []

[construction]
construction_time_days = 15
construction_cost_cash = 50000
construction_materials = {alloy = 100, plasteel = 50}
maintenance_cost_per_day = 50

[capacity]
storage_capacity = 1000
manufacturing_slots = 2
research_speed_bonus = 1.5
training_capacity = 4
personnel_max = 10

[functionality]
primary_function = "research|manufacturing|storage|training|command"
research_categories = ["weapons", "armor"]
manufacturing_categories = ["ammo", "grenades"]
provides_bonus = "will|accuracy|strength"
bonus_magnitude = 0.15

[production]
production_item = "item_id"
production_rate_per_day = 1.5
production_efficiency = 1.0
production_prerequisites = []

[requirements]
technology_required = "tech_id"
facility_required = "facility_id"
minimum_organization_level = 1
minimum_base_level = 1

[upgrades]
upgrade_to = "facility_id"
upgrade_cost_cash = 25000
upgrade_time_days = 7
upgrade_materials = {alloy = 50}

[strategic]
grants_ability = "ability_id"
unlocks_research = ["tech_id"]
provides_defense = 10
provides_detection = 100
```

## Outputs

### Created/Modified
- Facility entry in TOML with full specification
- Grid layout defined appropriately
- Production/capacity values balanced
- Costs and maintenance reasonable
- Technology requirements integrated

### Validation Report
- ✓ TOML syntax verified
- ✓ Facility ID uniqueness confirmed
- ✓ All tech requirements exist
- ✓ Grid dimensions valid
- ✓ Costs balanced with production
- ✓ Capacity values reasonable
- ✓ Upgrade paths don't loop
- ✓ No conflicts

## Process

1. **Define Facility Role**: Determine type and primary function
2. **Design Grid Layout**: Plan base placement footprint
3. **Set Specifications**: Configure capacity and production
4. **Balance Costs**: Determine construction and maintenance
5. **Define Requirements**: Set technology prerequisites
6. **Create Upgrades**: Plan progression path if applicable
7. **Validate**: Check TOML and cross-references
8. **Test**: Build facility in-game and verify functionality
9. **Document**: Update facility documentation

## Testing Checklist

- [ ] Facility loads without errors
- [ ] Facility can be placed in base
- [ ] Grid placement is correct
- [ ] Production functions properly
- [ ] Capacity limits work correctly
- [ ] Maintenance costs apply
- [ ] Requirements prevent placement when needed
- [ ] Upgrades work if defined
- [ ] Bonuses apply correctly
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Facility balances with other facilities

## References

- API: `docs/basescape/`
- Examples: `mods/core/basescape/facilities/`
- Balance Guide: `docs/content/facilities/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
