# add_research

Create or update technology research definitions in TOML format.

## Prefix
`research_`

## Task Type
Content Creation / Modification

## Description
Create or update research entries in `mods/core/technology/` folder. Research represents technology trees with costs, prerequisites, and unlocks for items, facilities, and gameplay mechanics.

## Inputs

### Required
- **Research ID**: Unique identifier (e.g., `research_plasma_weapons`, `research_psionic_training`)
- **Research Name**: Display name for UI
- **Research Category**: Category - `weapons`, `armor`, `defense`, `medical`, `facility`, `craft`, `psionic`, `alien_tech`
- **Description**: What technology unlocks

### Optional
- **Research Cost**: Time and resources required
- **Prerequisites**: Required prior research
- **Unlocks**: What becomes available after research
- **Effects**: Gameplay modifications from research
- **Facility Requirements**: Which facilities can conduct research
- **Alien Tech Integration**: Level of alien technology involvement
- **Progression Path**: Where it leads in tech tree

## Scope

### Affected Files
- `mods/core/technology/` folder (organized by phase)
- Related: Item definitions (weapons, armor)
- Related: Facility definitions (labs, manufacturing)
- Related: Unit abilities
- Related: Craft systems

### Validation
- ✓ Research ID is unique
- ✓ All required TOML fields present
- ✓ Research category matches valid type
- ✓ Cost values are reasonable
- ✓ Prerequisites exist and don't form loops
- ✓ Unlocks are valid items/facilities
- ✓ Facility requirements exist
- ✓ Tech tree logic is coherent

## TOML Structure Template

```toml
[[research]]
id = "research_id"
name = "Research Display Name"
description = "Description of technology and its applications"
category = "weapons|armor|defense|medical|facility|craft|psionic|alien_tech"
category_subcategory = "specific_type"
tags = ["tag1", "tag2"]

[cost]
research_points_required = 5000
research_time_days = 30
resource_cost = {alloy = 100, plasteel = 50}
cost_variation = 0.1

[prerequisites]
required_research = ["research_id"]
minimum_organization_level = 1
minimum_technology_level = "ballistic"
minimum_facilities = ["facility_id"]

[unlocks]
unlock_items = ["item_id"]
unlock_facilities = ["facility_id"]
unlock_abilities = ["ability_id"]
unlock_upgrades = ["upgrade_id"]
unlock_research = ["research_id"]

[gameplay_effects]
damage_modifier = 0.1
armor_modifier = 0.15
accuracy_modifier = 0.05
movement_speed_modifier = 0.0
cost_reduction = 0.2

[facility_options]
required_facility = "facility_id"
alternative_facilities = ["facility_id"]
research_speed_bonus = 1.0

[research_path]
tech_tree_parent = "research_id"
tech_tree_children = ["research_id"]
alternate_paths = ["research_id"]

[requirements]
alien_artifact_required = false
alien_interrogation_required = false
dissection_required = false
unique_item_required = false

[progression]
phase_available = "phase1_sky_war"
priority_level = "high|medium|low"
research_order_index = 1
display_in_tree = true
```

## Outputs

### Created/Modified
- Research entry in TOML with complete specification
- Cost parameters balanced
- Prerequisites and unlocks configured
- Gameplay effects defined
- Tech tree integration established

### Validation Report
- ✓ TOML syntax verified
- ✓ Research ID uniqueness confirmed
- ✓ Prerequisites don't form cycles
- ✓ Unlocks are valid and balanced
- ✓ Costs reasonable for unlocks
- ✓ Facility requirements exist
- ✓ Tech tree progression logical
- ✓ No conflicting tech paths

## Process

1. **Define Technology**: Establish what's being researched
2. **Determine Cost**: Balance with other research
3. **Set Prerequisites**: Establish requirements
4. **Define Unlocks**: Determine what becomes available
5. **Configure Gameplay Effects**: Set stat modifications
6. **Plan Tech Tree**: Position in research tree
7. **Validate**: Check TOML and tech tree logic
8. **Test**: Research in-game and verify unlocks
9. **Document**: Update technology documentation

## Testing Checklist

- [ ] Research loads without errors
- [ ] Research appears in tech tree UI
- [ ] Prerequisites enforce correctly
- [ ] Research completes with proper timing
- [ ] Unlocked items appear in menus
- [ ] Unlocked facilities buildable
- [ ] Gameplay effects apply correctly
- [ ] Cost is deducted properly
- [ ] Tech tree shows connections
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Research balances with other tech
- [ ] Prerequisites achievable

## References

- API: `docs/economy/research.md`
- Examples: `mods/core/technology/`
- Balance Guide: `docs/balance/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
