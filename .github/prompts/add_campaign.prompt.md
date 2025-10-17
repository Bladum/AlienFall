# add_campaign

Create or update campaign definitions including phases, progression, and narrative structure in TOML format.

## Prefix
`campaign_`

## Task Type
Content Creation / Modification

## Description
Create or update campaign entries in `mods/core/campaign/` folder. Campaigns structure game progression through phases, missions, and narrative arcs with pacing, difficulty scaling, and story milestones.

## Inputs

### Required
- **Campaign ID**: Unique identifier (e.g., `campaign_core_story`, `campaign_shadow_war`)
- **Campaign Name**: Display name for UI
- **Campaign Type**: Category - `story`, `sandbox`, `challenge`, `tutorial`, `seasonal`
- **Description**: Campaign overview and narrative scope

### Optional
- **Phases**: Campaign phases with progression conditions
- **Mission Sequence**: Ordered mission progression
- **Narrative Arcs**: Story structure and pacing
- **Difficulty Scaling**: Progressive difficulty increase
- **Unlock Conditions**: Requirements for campaign access
- **Victory Conditions**: How campaign is won
- **Replayability**: Whether campaign can be replayed

## Scope

### Affected Files
- `mods/core/campaign/*.toml` (separate file per campaign)
- Related: `mods/core/technology/` (for research unlocks)
- Related: `mods/core/geoscape/` (for world state)
- Related: Mission definitions

### Validation
- ✓ Campaign ID is unique
- ✓ All required TOML fields present
- ✓ Campaign type matches valid category
- ✓ All referenced missions exist
- ✓ Phase progression is logical
- ✓ Difficulty scaling is reasonable
- ✓ Victory conditions are achievable
- ✓ No circular progression dependencies

## TOML Structure Template

```toml
[campaign]
id = "campaign_id"
name = "Campaign Display Name"
description = "Campaign overview and story scope"
type = "story|sandbox|challenge|tutorial|seasonal"
difficulty_base = 1
replayable = true
tags = ["tag1", "tag2"]

[narrative]
opening_narration = "Campaign start story"
victory_narration = "Campaign completion story"
theme = "alien_invasion|shadow_war|dimensional_war"
story_progression = "linear|branching|sandbox"

[progression]
starting_funds = 50000
starting_technology = ["tech_id"]
starting_facilities = ["facility_id"]
starting_soldiers = 12
starting_crafts = ["craft_id"]

[[phases]]
id = "phase_id"
name = "Phase Name"
description = "Phase story and objectives"
duration_days = 30
difficulty_modifier = 1.0

[[phases.missions]]
mission_id = "mission_id"
sequence_order = 1
mandatory = true
success_required_for_next = true

[victory]
victory_conditions = ["condition1", "condition2"]
failure_conditions = ["all_bases_destroyed"]
game_over_condition = "base_lost"
victory_narration = "Victory story text"

[difficulty_scaling]
initial_difficulty = 1.0
per_phase_increase = 0.1
per_day_increase = 0.01
enemy_reinforcement_scaling = 1.2

[unlocks]
unlock_requirements = ["tech_id", "mission_id"]
unlock_resources = true
unlock_crafts = ["craft_id"]
unlock_facilities = ["facility_id"]

[settings]
permadeath_available = true
ironman_mode_available = true
save_limit = "unlimited"
reload_penalty = "none"
```

## Outputs

### Created/Modified
- Campaign entry with complete progression structure
- Phase definitions with proper pacing
- Mission sequence established
- Narrative framework defined
- Difficulty scaling configured

### Validation Report
- ✓ TOML syntax verified
- ✓ Campaign ID uniqueness confirmed
- ✓ All missions referenced exist
- ✓ Phase progression logical
- ✓ Difficulty scaling reasonable
- ✓ Victory conditions achievable
- ✓ No progression blockages

## Process

1. **Plan Campaign Structure**: Define phases and narrative
2. **Design Mission Sequence**: Order missions by progression
3. **Set Difficulty Curve**: Configure progressive challenge
4. **Configure Resources**: Set starting conditions
5. **Define Victory/Failure**: Establish end conditions
6. **Validate**: Check TOML and cross-references
7. **Test**: Play through campaign and verify pacing
8. **Document**: Update campaign documentation

## Testing Checklist

- [ ] Campaign loads without errors
- [ ] Starting resources available
- [ ] Missions unlock in proper sequence
- [ ] Difficulty scales appropriately
- [ ] Victory conditions achievable
- [ ] All unlocks granted correctly
- [ ] Narrative flow is logical
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Campaign completes successfully
- [ ] Replay functionality works (if enabled)

## References

- API: `docs/geoscape/` and `docs/campaign/`
- Examples: `mods/core/campaign/`
- Balance Guide: `docs/balance/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
