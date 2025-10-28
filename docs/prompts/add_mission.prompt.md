# add_mission

Create or update mission definitions including objectives, rewards, and parameters in TOML format.

## Prefix
`mission_`

## Task Type
Content Creation / Modification

## Description
Create or update mission entries in `mods/core/campaign/` or `mods/core/geoscape/` folders. Missions are tactical operations with objectives, enemy composition, map selection, rewards, and narrative context.

## Inputs

### Required
- **Mission ID**: Unique identifier (e.g., `mission_tutorial_first_contact`, `mission_terror_defense`)
- **Mission Name**: Display name for UI
- **Mission Type**: Category - `tutorial`, `terror_defense`, `ufo_crash_recovery`, `base_defense`, `alien_facility`, `escort`, `rescue`
- **Description**: Narrative and objective context

### Optional
- **Objectives**: Primary and secondary goals
- **Map Configuration**: Map block selection, difficulty
- **Enemy Composition**: Unit types and squad size
- **Rewards**: Experience, items, cash, research
- **Failure Conditions**: Loss conditions and penalties
- **Difficulty Scaling**: Progression-based adjustments
- **Narrative Context**: Story integration
- **Unlocks**: Missions or content unlocked on completion

## Scope

### Affected Files
- `mods/core/campaign/` or `mods/core/geoscape/missions.toml`
- Related: `mods/core/battlescape/mapblocks/` (for map references)
- Related: `mods/core/factions/` (for enemy configuration)
- Related: `mods/core/economy/` (for rewards)

### Validation
- ✓ Mission ID is unique
- ✓ All required TOML fields present
- ✓ Mission type matches valid category
- ✓ Map blocks exist and are accessible
- ✓ Enemy units are defined
- ✓ Objective conditions are logical
- ✓ Rewards are balanced
- ✓ No broken references

## TOML Structure Template

```toml
[[missions]]
id = "mission_id"
name = "Mission Display Name"
description = "Mission briefing and narrative context"
type = "tutorial|terror_defense|ufo_crash_recovery|base_defense|alien_facility|escort|rescue"
difficulty_level = 1
priority = "high|medium|low"
tags = ["tag1", "tag2"]

[narrative]
story_context = "Why this mission is happening"
briefing_text = "Pre-mission briefing for player"
victory_text = "Post-victory narration"
failure_text = "Post-failure narration"

[objectives]
primary = "Eliminate all aliens"
secondary = ["Rescue civilian", "Recover artifact"]
failure_conditions = ["All squaddies killed", "Civilians perish"]

[map]
mapblock_id = "mapblock_id"
mapblock_theme = "urban|rural|industrial|alien"
map_difficulty = 1
environmental_hazards = ["radiation", "fire"]

[enemies]
enemy_faction = "faction_id"
squad_size = 6
squad_composition = ["unit_id", "unit_id"]
reinforcement_waves = 2
reinforcement_timing = 3

[rewards]
experience_points = 500
cash_reward = 5000
item_rewards = ["item_id1", "item_id2"]
research_unlock = "tech_id"
relation_change = {faction = "faction_id", change = 10}

[requirements]
minimum_soldiers = 4
required_technology = []
required_equipment = []
minimum_organization_level = 1

[progression]
unlocks_missions = ["mission_id"]
unlocks_research = ["tech_id"]
unlocks_facilities = ["facility_id"]
```

## Outputs

### Created/Modified
- Mission entry in TOML with complete specification
- Objectives properly defined and achievable
- Enemy composition balanced for difficulty level
- Map configuration validated
- Rewards appropriate for challenge

### Validation Report
- ✓ TOML syntax verified
- ✓ Mission ID uniqueness confirmed
- ✓ All map blocks exist
- ✓ All enemy units defined
- ✓ Rewards balanced
- ✓ Cross-references valid
- ✓ Difficulty progression appropriate

## Process

1. **Design Mission**: Define narrative and objectives
2. **Select Map**: Choose or create appropriate mapblock
3. **Configure Enemies**: Establish challenging but fair composition
4. **Set Rewards**: Balance with mission difficulty
5. **Define Progression**: Determine unlocks and requirements
6. **Validate**: Check TOML and cross-references
7. **Test**: Play mission and verify difficulty/balance
8. **Document**: Update campaign documentation

## Testing Checklist

- [ ] Mission loads without errors
- [ ] Map loads correctly with no missing blocks
- [ ] Enemies spawn in proper composition
- [ ] Objectives display correctly
- [ ] Mission can be completed
- [ ] Rewards are granted on completion
- [ ] Difficulty is appropriate for level
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Mission appears in mission list
- [ ] Progression unlocks work correctly

## References

- API: `docs/geoscape/` and `docs/battlescape/`
- Examples: `mods/core/campaign/`
- Balance Guide: `docs/content/missions/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
