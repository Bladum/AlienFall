# add_faction

Create or update faction definitions including aliens, organizations, and factions in TOML format.

## Prefix
`faction_`

## Task Type
Content Creation / Modification

## Description
Create or update faction entries in `mods/core/factions/` folder. Factions represent alien species, organizations, governments, or groups with relationships, technology, units, and diplomatic properties.

## Inputs

### Required
- **Faction ID**: Unique identifier (e.g., `faction_sectoids`, `faction_xcom`, `faction_local_government`)
- **Faction Name**: Display name for UI
- **Faction Type**: Category - `alien_species`, `government`, `organization`, `military`, `corporate`
- **Description**: Characteristics and background

### Optional
- **Units**: Available unit types for this faction
- **Technology Level**: Tech tree and research progression
- **Diplomatic Relations**: Relationships with other factions
- **Appearance Frequency**: How often they appear
- **Special Traits**: Unique characteristics or abilities
- **Gameplay Modifiers**: Difficulty and behavior adjustments
- **Equipment Profile**: Default equipment loadout

## Scope

### Affected Files
- `mods/core/factions/faction_*.toml`
- Related: `mods/core/technology/` (for tech trees)
- Related: `mods/core/geoscape/` (for political integration)
- Related: Mission and encounter systems

### Validation
- ✓ Faction ID is unique
- ✓ All required TOML fields present
- ✓ Faction type matches valid category
- ✓ All unit references exist
- ✓ Technology references are valid
- ✓ Relationship references point to existing factions
- ✓ Difficulty modifiers are reasonable (0.5-2.0 range)
- ✓ No circular dependencies

## TOML Structure Template

```toml
[faction]
id = "faction_id"
name = "Faction Display Name"
description = "Description of faction characteristics and role"
type = "alien_species|government|organization|military|corporate"
tags = ["tag1", "tag2"]

[characteristics]
alien = true
aquatic = false
dimensional = false
psionic = false
primary_trait = "trait_name"
intelligence_level = "primitive|average|advanced|genius"

[appearance]
appearance_frequency = "rare|uncommon|common|always"
starting_phase = "phase1_sky_war"
technology_phase = "plasma|dimensional|psionic"

[[units]]
type = "unit_id"
name = "Unit Display Name"
spawn_weight = 10
squad_role = "soldier|specialist|commander"
health = 30
will = 80
psionic_power = 40
abilities = ["ability_id"]
equipment_primary = "item_id"

[[units]]
type = "unit_id_2"
name = "Unit Display Name 2"
spawn_weight = 5
squad_role = "commander"
health = 40
will = 90

[technology]
tech_tree = ["tech_id1", "tech_id2"]
starting_tech = ["tech_id1"]
research_speed = 1.0
tech_level = "ballistic|laser|plasma|dimensional"

[relationships]
allies = ["faction_id"]
enemies = ["faction_id"]
neutral = ["faction_id"]
trade_partners = ["faction_id"]

[gameplay]
squad_composition = "3-5 soldiers + 1 leader"
tactics = "aggressive|defensive|balanced"
difficulty_modifier = 1.0
morale_modifier = 1.0
intelligence_modifier = 1.0

[diplomacy]
diplomatic_stance = "hostile|neutral|friendly|unknown"
trade_value = 100
technological_cooperation = false
military_alliance = false

[economy]
starting_cash = 10000
income_modifier = 1.0
research_cost_modifier = 1.0
manufacturing_cost_modifier = 1.0
```

## Outputs

### Created/Modified
- Faction entry in TOML with complete specification
- Unit composition defined and balanced
- Technology tree established
- Diplomatic relations configured
- Gameplay modifiers appropriate

### Validation Report
- ✓ TOML syntax verified
- ✓ Faction ID uniqueness confirmed
- ✓ All unit references valid
- ✓ Technology tree complete
- ✓ Relationships bidirectional (optional)
- ✓ Difficulty modifiers balanced
- ✓ No conflicts with existing factions

## Process

1. **Define Faction Concept**: Establish role and characteristics
2. **Design Unit Roster**: Create or reference unit types
3. **Establish Technology**: Define tech progression
4. **Configure Relationships**: Set diplomatic and military relations
5. **Set Gameplay Parameters**: Configure difficulty and behavior
6. **Validate**: Check TOML and cross-references
7. **Test**: Encounter faction in-game and verify behavior
8. **Document**: Update faction documentation

## Testing Checklist

- [ ] Faction loads without errors
- [ ] Units spawn correctly with proper stats
- [ ] Technology tree loads without breaks
- [ ] Faction appears in appropriate game systems
- [ ] Difficulty modifiers affect gameplay appropriately
- [ ] Relationships display correctly
- [ ] Units use correct equipment
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Faction balances with similar factions
- [ ] Diplomatic interactions work correctly

## References

- API: `docs/geoscape/` and `docs/politics/`
- Examples: `mods/core/factions/`
- Balance Guide: `docs/content/units/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
