# add_organization

Create or update player organization/faction configuration in TOML format.

## Prefix
`org_`

## Task Type
Content Creation / Modification

## Description
Create or update organization entries in `mods/core/` folder. Organizations represent the player's command structure with ranks, divisions, capabilities, and progression mechanics affecting gameplay systems.

## Inputs

### Required
- **Organization ID**: Unique identifier (e.g., `org_xcom_international`)
- **Organization Name**: Display name for UI
- **Organization Type**: Category - `military`, `scientific`, `paramilitary`, `corporate`, `international`
- **Description**: Organization purpose and structure

### Optional
- **Rank System**: Military rank hierarchy
- **Divisions**: Organizational departments
- **Technology Level**: Starting technology tier
- **Initial Resources**: Starting funding and inventory
- **Capabilities**: What organization can do
- **Progression**: How organization grows
- **Relationships**: Standing with governments and factions

## Scope

### Affected Files
- `mods/core/` (organization configuration file)
- Related: Campaign definitions
- Related: Facility systems
- Related: Personnel systems

### Validation
- ✓ Organization ID is unique
- ✓ All required TOML fields present
- ✓ Organization type matches valid category
- ✓ Rank hierarchy is logical
- ✓ Division references valid
- ✓ Starting resources reasonable
- ✓ Technology level appropriate

## TOML Structure Template

```toml
[organization]
id = "org_id"
name = "Organization Display Name"
description = "Description of organization purpose and structure"
org_type = "military|scientific|paramilitary|corporate|international"
location_headquarters = "region_id"
tags = ["tag1", "tag2"]

[founding]
founded_year = 2024
founding_reason = "In response to alien invasion"
charter_authority = "United Nations"
legal_status = "official|provisional|classified"

[structure]
leadership_type = "hierarchical|council|consensus"
max_personnel = 500
command_hierarchy = ["rank_id"]

[[divisions]]
division_id = "tactical"
division_name = "Tactical Operations"
description = "Field combat and tactical operations"
personnel_capacity = 200
division_head = "advisor_id"

[[divisions]]
division_id = "research"
division_name = "Research & Development"
description = "Technology research and innovation"
personnel_capacity = 100
division_head = "advisor_id"

[[ranks]]
rank_id = "soldier"
rank_name = "Soldier"
rank_order = 1
salary_per_month = 2000
max_personnel_at_rank = 100

[[ranks]]
rank_id = "commander"
rank_name = "Commander"
rank_order = 10
salary_per_month = 5000
max_personnel_at_rank = 1

[resources]
starting_funds = 100000
starting_alloys = 500
starting_engineers = 5
starting_scientists = 5
starting_soldiers = 20

[capabilities]
research_available = true
manufacturing_available = true
craft_operations = true
diplomat_available = true
special_operations = true

[progression]
level_maximum = 20
experience_to_level_2 = 10000
experience_per_level = 5000
unlock_structure = true
upgrade_capabilities = true

[relationships]
government_relations = {country_id = "neutral"}
faction_relations = {faction_id = "neutral"}
starting_allies = []
starting_enemies = ["faction_alien"]

[military]
command_authority = "international"
treaty_obligations = ["treaty_id"]
standing_rules = "combat_authorized"
escalation_level = 1

[finance]
monthly_budget = 25000
budget_sources = ["government_funding"]
operating_cost_per_day = 500
profit_opportunities = true

[morale]
organization_morale_base = 0.75
morale_factors = ["casualty_rate", "mission_success", "funding"]
morale_effects_on_gameplay = true

[victory_condition]
primary_victory = "defeat_alien_threat"
secondary_objectives = ["protect_civilian", "recover_artifacts"]
```

## Outputs

### Created/Modified
- Organization entry with complete structure
- Rank hierarchy defined
- Divisions and departments established
- Starting resources configured
- Progression mechanics set
- Relationships with factions/governments defined

### Validation Report
- ✓ TOML syntax verified
- ✓ Organization ID uniqueness confirmed
- ✓ Rank hierarchy logical
- ✓ All divisions referenced
- ✓ Starting resources reasonable
- ✓ Relationships valid
- ✓ Progression balanced
- ✓ Victory conditions achievable

## Process

1. **Define Organization**: Establish type and purpose
2. **Design Structure**: Create rank hierarchy and divisions
3. **Set Starting Resources**: Configure initial inventory
4. **Configure Capabilities**: Determine available systems
5. **Plan Progression**: Define growth and upgrades
6. **Set Relationships**: Establish faction/government standing
7. **Configure Finance**: Set budget and costs
8. **Validate**: Check TOML and logical consistency
9. **Test**: Play through with organization in-game
10. **Document**: Update organization documentation

## Testing Checklist

- [ ] Organization loads without errors
- [ ] Organization appears in game
- [ ] Rank system displays correctly
- [ ] Divisions function properly
- [ ] Starting resources granted
- [ ] Personnel capacity enforced
- [ ] Budget system works
- [ ] Progression unlocks work
- [ ] Relationships affect diplomacy
- [ ] Morale factors apply
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Organization feels balanced and complete

## References

- API: `docs/basescape/` and `docs/politics/`
- Examples: `mods/core/`
- Balance Guide: `docs/balance/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
