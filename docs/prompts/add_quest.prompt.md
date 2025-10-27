# add_quest

Create or update quest/objective definitions in TOML format.

## Prefix
`quest_`

## Task Type
Content Creation / Modification

## Description
Create or update quest entries in `mods/core/narrative/` or `mods/core/geoscape/` folders. Quests are objectives with multiple stages, rewards, and narrative context that provide player direction and story progression.

## Inputs

### Required
- **Quest ID**: Unique identifier (e.g., `quest_first_contact`, `quest_research_psionic`)
- **Quest Name**: Display name for UI
- **Quest Type**: Category - `main_story`, `side_quest`, `bounty`, `research_chain`, `faction_mission`
- **Description**: Quest purpose and objectives

### Optional
- **Quest Stages**: Progression steps
- **Objectives**: Goals within each stage
- **Rewards**: Experience, items, cash
- **Constraints**: Time limits, requirements
- **Branching**: Quest decision points
- **Narrative**: Quest story and dialogue

## Scope

### Affected Files
- `mods/core/narrative/quests.toml` (if created)
- Related: `mods/core/geoscape/`
- Related: Campaign and mission systems
- Related: Faction and dialogue systems

### Validation
- ✓ Quest ID is unique
- ✓ All required TOML fields present
- ✓ Quest type matches valid category
- ✓ Objectives are logical and achievable
- ✓ Stage progression makes sense
- ✓ Rewards are reasonable
- ✓ Requirements reference valid entities

## TOML Structure Template

```toml
[[quests]]
id = "quest_id"
name = "Quest Display Name"
description = "Quest overview and purpose"
quest_type = "main_story|side_quest|bounty|research_chain|faction_mission"
priority = "primary|secondary|optional"
tags = ["tag1", "tag2"]

[narrative]
quest_giver = "npc_id"
giver_faction = "faction_id"
story_text = "Quest narrative and context"
flavor_text = "Additional narrative details"

[[stages]]
stage_id = 1
stage_name = "Stage Name"
stage_text = "What happens in this stage"
objectives = ["Objective 1", "Objective 2"]
required_completion = true

[[stages.tasks]]
task_id = "task_1"
task_text = "Specific goal to complete"
task_type = "combat|exploration|research|diplomacy"
completion_requirement = "all"  # all|any

[[stages]]
stage_id = 2
stage_name = "Final Stage"
stage_text = "Quest conclusion stage"
objectives = ["Final Objective"]
required_completion = true

[rewards]
completion_text = "What happens when quest completes"
experience_reward = 1000
cash_reward = 5000
item_rewards = ["item_id"]
technology_unlock = ["tech_id"]
unlock_quests = ["quest_id"]
reputation_change = {faction = "faction_id", change = 25}

[constraints]
minimum_organization_level = 1
required_technology = []
required_missions = []
time_limit_days = -1  # -1 = unlimited
abandonment_allowed = true

[conditions]
quest_active = true
repeatable = false
failure_possible = true
failure_condition = "time_expired"
failure_consequence = "lose_reputation"

[progression]
required_completion_for_campaign = false
unlocks_campaign_phase = false
blocks_other_quests = []
```

## Outputs

### Created/Modified
- Quest entry in TOML with complete structure
- Stages defined logically
- Objectives clear and achievable
- Rewards balanced
- Narrative framework established

### Validation Report
- ✓ TOML syntax verified
- ✓ Quest ID uniqueness confirmed
- ✓ Stages logical and sequential
- ✓ Objectives achievable
- ✓ Rewards balanced
- ✓ All references valid
- ✓ No circular quest locks

## Process

1. **Define Quest Concept**: Establish type and purpose
2. **Write Narrative**: Create story and character context
3. **Design Stages**: Break quest into logical steps
4. **Set Objectives**: Define clear goals for each stage
5. **Configure Rewards**: Balance with difficulty
6. **Add Constraints**: Set requirements and limits
7. **Validate**: Check TOML and quest logic
8. **Test**: Complete quest in-game and verify
9. **Document**: Update quest documentation

## Testing Checklist

- [ ] Quest loads without errors
- [ ] Quest appears in quest log
- [ ] Narrative displays correctly
- [ ] Stages progress properly
- [ ] Objectives track correctly
- [ ] Quest can be completed
- [ ] Rewards granted on completion
- [ ] NPCs recognize quest progress
- [ ] Time limits enforce (if set)
- [ ] Abandonment works (if allowed)
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Quest balances with others

## References

- API: `docs/narrative/` and `docs/geoscape/`
- Examples: `mods/core/narrative/`
- Balance Guide: `docs/narrative/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
