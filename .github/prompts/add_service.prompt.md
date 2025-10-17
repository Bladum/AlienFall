# add_service

Create or update base service definitions in TOML format.

## Prefix
`service_`

## Task Type
Content Creation / Modification

## Description
Create or update service entries in `mods/core/basescape/services/` folder. Services are ongoing operations providing benefits, consuming resources, or enabling special capabilities at bases.

## Inputs

### Required
- **Service ID**: Unique identifier (e.g., `service_research_boost`, `service_infiltration_network`)
- **Service Name**: Display name for UI
- **Service Type**: Category - `research`, `training`, `intelligence`, `manufacturing`, `defense`, `diplomatic`, `economic`
- **Description**: Service purpose and impact

### Optional
- **Cost**: Daily operational or activation cost
- **Duration**: How long service lasts if not continuous
- **Benefits**: What the service provides (bonuses, unlocks, resources)
- **Requirements**: Facility, technology, or personnel needs
- **Limitations**: Restrictions on service usage
- **Cancelation**: Can service be stopped/paused

## Scope

### Affected Files
- `mods/core/basescape/services/` (if created)
- Related: `mods/core/basescape/facilities/`
- Related: `mods/core/technology/`
- Related: Base management and economy systems

### Validation
- ✓ Service ID is unique
- ✓ All required TOML fields present
- ✓ Service type matches valid category
- ✓ Costs are reasonable
- ✓ Duration is positive if specified
- ✓ Benefits are quantifiable
- ✓ Requirements reference existing entities
- ✓ No impossible requirement combinations

## TOML Structure Template

```toml
[[services]]
id = "service_id"
name = "Service Display Name"
description = "Description of service function and impact"
type = "research|training|intelligence|manufacturing|defense|diplomatic|economic"
category = "subcategory"
tags = ["tag1", "tag2"]

[availability]
always_available = true
minimum_organization_level = 1
minimum_base_level = 1
technology_required = "tech_id"
facility_required = "facility_id"
personnel_required = 1

[cost]
cost_per_activation = 5000
cost_per_day_active = 500
cost_currency = "cash|resources|both"

[benefits]
provides_bonus = "research|production|training"
bonus_magnitude = 1.5
unlock_technology = ["tech_id"]
unlock_items = ["item_id"]
training_points = 100
morale_boost = 0.1

[duration]
duration_type = "permanent|temporary|recurring"
duration_days = 30
can_be_cancelled = true
cancellation_penalty = 0

[capacity]
max_active_services = 1
service_frequency = "always|hourly|daily|weekly"
max_concurrent_uses = 10

[requirements]
required_soldiers = 2
required_specialists = 1
required_equipment = ["item_id"]
research_prerequisite = "tech_id"

[effects]
morale_effect = 0.05
efficiency_effect = 1.2
resource_generation = {cash = 100, resources = 50}
```

## Outputs

### Created/Modified
- Service entry in TOML with complete specification
- Cost structure balanced
- Benefits clearly defined
- Requirements appropriately set
- Duration and limitation rules established

### Validation Report
- ✓ TOML syntax verified
- ✓ Service ID uniqueness confirmed
- ✓ All requirements valid
- ✓ Costs are reasonable
- ✓ Benefits are balanced
- ✓ No impossible configurations
- ✓ No conflicts with existing services

## Process

1. **Define Service Purpose**: Determine type and primary benefit
2. **Establish Requirements**: Set facility, technology, and personnel needs
3. **Configure Benefits**: Determine magnitude and type of bonuses
4. **Set Costs**: Balance cost with benefit
5. **Define Duration**: Determine if permanent, temporary, or recurring
6. **Validate**: Check TOML and cross-references
7. **Test**: Activate service in-game and verify benefits
8. **Document**: Update service documentation

## Testing Checklist

- [ ] Service loads without errors
- [ ] Service can be activated/purchased
- [ ] Costs are deducted correctly
- [ ] Benefits apply as expected
- [ ] Duration functions properly
- [ ] Requirements prevent use when not met
- [ ] Service can be cancelled (if applicable)
- [ ] Morale/efficiency effects work
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Service balances with other services

## References

- API: `docs/basescape/`
- Examples: `mods/core/basescape/services/`
- Balance Guide: `docs/content/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
