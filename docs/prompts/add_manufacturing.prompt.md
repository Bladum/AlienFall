# add_manufacturing

Create or update manufacturing recipe definitions in TOML format.

## Prefix
`manufacturing_`

## Task Type
Content Creation / Modification

## Description
Create or update manufacturing recipe entries in `mods/core/economy/manufacturing.toml`. Recipes define how items are crafted from raw materials with costs, time, facility requirements, and production rates.

## Inputs

### Required
- **Recipe ID**: Unique identifier (e.g., `recipe_plasma_rifle`, `recipe_combat_armor`)
- **Item Produced**: Which item this recipe creates
- **Production Category**: Category - `weapons`, `armor`, `ammunition`, `equipment`, `craft_components`
- **Description**: What's being manufactured

### Optional
- **Resource Requirements**: Raw materials needed
- **Production Time**: How long manufacturing takes
- **Production Yield**: Quantity produced per batch
- **Facility Requirements**: Where it can be manufactured
- **Technology Prerequisites**: Required research
- **Cost Modifiers**: Difficulty and efficiency factors

## Scope

### Affected Files
- `mods/core/economy/manufacturing.toml`
- Related: Item definitions (items being produced)
- Related: Facility definitions (manufacturing facilities)
- Related: Technology trees (research prerequisites)

### Validation
- ✓ Recipe ID is unique
- ✓ Produced item exists
- ✓ All required TOML fields present
- ✓ Category matches valid type
- ✓ Resource costs are positive
- ✓ Production time is reasonable
- ✓ Facility requirements exist
- ✓ Technology prerequisites are valid
- ✓ No circular recipes (item requiring itself)

## TOML Structure Template

```toml
[[recipes]]
id = "recipe_id"
name = "Recipe Display Name"
description = "Description of what's being manufactured"
item_produced = "item_id"
category = "weapons|armor|ammunition|equipment|craft_components"
subcategory = "specific_type"
tags = ["tag1", "tag2"]

[production]
quantity_per_batch = 1
production_time_hours = 24
production_efficiency = 1.0
production_difficulty = 1.0

[resources]
resource_cost = {alloy = 50, plasteel = 30, electronics = 10}
resource_waste = 0.1
resource_scarcity_modifier = 1.0

[requirements]
required_facility = "facility_id"
alternative_facilities = ["facility_id"]
required_technology = "research_id"
required_organization_level = 1
minimum_personnel_skill = 1

[output]
market_value = 500
cost_to_player = 50000
profit_margin = 0.5
sellable = true
tradeable = true

[constraints]
production_limit_per_day = -1  # -1 = unlimited
storage_space_required = 2
maintenance_cost_per_production = 100

[quality]
quality_base = 1.0
quality_variance = 0.05
durability_factor = 1.0
```

## Outputs

### Created/Modified
- Recipe entry in TOML with complete specification
- Resource costs configured and balanced
- Production time set appropriately
- Facility and technology requirements established
- Output values determined

### Validation Report
- ✓ TOML syntax verified
- ✓ Recipe ID uniqueness confirmed
- ✓ Item produced exists
- ✓ Resources are available
- ✓ Facility exists and can produce
- ✓ Technology requirements met
- ✓ Cost/value balanced
- ✓ No circular recipes
- ✓ Production time reasonable

## Process

1. **Define Item**: Determine what's being produced
2. **Calculate Resources**: Determine material requirements
3. **Set Production Time**: Balance with difficulty
4. **Choose Facility**: Select manufacturing location
5. **Set Technology**: Establish research prerequisite
6. **Configure Output**: Determine market value and cost
7. **Validate**: Check TOML and economic balance
8. **Test**: Manufacture item in-game and verify
9. **Document**: Update manufacturing documentation

## Testing Checklist

- [ ] Recipe loads without errors
- [ ] Recipe appears in manufacturing menu
- [ ] Resources available in inventory
- [ ] Production cost deducted correctly
- [ ] Production time accurate
- [ ] Item produced correctly
- [ ] Facility produces correctly
- [ ] Technology gates recipe properly
- [ ] Market value reasonable
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Recipe balances economically
- [ ] Production efficiency works

## References

- API: `docs/economy/manufacturing.md`
- Examples: `mods/core/economy/manufacturing.toml`
- Balance Guide: `docs/economy/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
