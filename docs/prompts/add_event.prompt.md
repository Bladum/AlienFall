# add_event

Create or update event definitions in TOML format.

## Prefix
`event_`

## Task Type
Content Creation / Modification

## Description
Create or update event entries in `mods/core/narrative/` or `mods/core/geoscape/` folders. Events are triggered occurrences that affect gameplay with narrative consequences, resource changes, or mission generation.

## Inputs

### Required
- **Event ID**: Unique identifier (e.g., `event_ufo_sighting`, `event_base_discovered`)
- **Event Name**: Display name for UI
- **Event Type**: Category - `narrative`, `crisis`, `discovery`, `diplomatic`, `military`, `economic`
- **Description**: Event purpose and trigger conditions

### Optional
- **Trigger Conditions**: When event occurs
- **Consequences**: Results and effects
- **Resources**: Cost or reward
- **Narrative**: Story text and flavor
- **Options**: Player choices and responses
- **Unlock Conditions**: What event unlocks

## Scope

### Affected Files
- `mods/core/narrative/events.toml` (if created)
- Related: `mods/core/geoscape/`
- Related: Mission and campaign systems
- Related: Politics and diplomacy

### Validation
- ✓ Event ID is unique
- ✓ All required TOML fields present
- ✓ Event type matches valid category
- ✓ Trigger conditions are logical
- ✓ Consequences are clear and balanced
- ✓ Resource changes are reasonable
- ✓ Options have logical outcomes

## TOML Structure Template

```toml
[[events]]
id = "event_id"
name = "Event Display Name"
description = "Description of event and its significance"
type = "narrative|crisis|discovery|diplomatic|military|economic"
category = "subcategory"
tags = ["tag1", "tag2"]

[trigger]
trigger_type = "timer|condition|choice|random"
trigger_condition = "condition_description"
trigger_probability = 0.5
minimum_days_elapsed = 0
maximum_days_to_trigger = 30

[narrative]
story_text = "Event description and narrative impact"
flavor_text = "Additional color commentary"
urgency_level = "low|medium|high|critical"
public_knowledge = true

[consequences]
effects_on_organization = "positive|negative|neutral"
effect_magnitude = 1.0
organization_impact = {morale = 10, funding = 5000}
casualty_potential = 0
resource_change = {cash = 1000, research = 50}

[choices]
has_player_choice = true
choice_count = 2

[[choices.options]]
id = "option_1"
text = "Option description"
consequence = "consequence_id"
resource_cost = {cash = 500}
reputation_change = {faction = "faction_id", change = 10}

[[choices.options]]
id = "option_2"
text = "Alternative option"
consequence = "consequence_id"
resource_cost = {cash = 1000}

[outcomes]
success_outcome = "text_id"
failure_outcome = "text_id"
consequence_text = "What happens after event"
unlock_missions = ["mission_id"]
unlock_technology = ["tech_id"]

[restrictions]
minimum_organization_level = 1
required_technology = []
required_missions_completed = []
conflicting_events = ["event_id"]
```

## Outputs

### Created/Modified
- Event entry in TOML with complete structure
- Trigger conditions clearly defined
- Consequences and outcomes specified
- Player choices configured (if applicable)
- Narrative text written

### Validation Report
- ✓ TOML syntax verified
- ✓ Event ID uniqueness confirmed
- ✓ Trigger conditions logical
- ✓ Consequences balanced
- ✓ Resource changes reasonable
- ✓ Choice options valid
- ✓ No impossible conditions
- ✓ Cross-references valid

## Process

1. **Define Event Concept**: Establish purpose and type
2. **Set Trigger**: Determine when event occurs
3. **Write Narrative**: Create event story and descriptions
4. **Configure Consequences**: Determine effects and rewards/penalties
5. **Add Player Choices**: Create branching options (if applicable)
6. **Define Outcomes**: Establish results and unlocks
7. **Validate**: Check TOML and logical consistency
8. **Test**: Trigger event in-game and verify behavior
9. **Document**: Update event documentation

## Testing Checklist

- [ ] Event loads without errors
- [ ] Event triggers under correct conditions
- [ ] Narrative text displays properly
- [ ] Consequences apply correctly
- [ ] Resources change as specified
- [ ] Player choices work (if available)
- [ ] Outcomes triggered correctly
- [ ] Unlocks granted properly
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Event balances with other events
- [ ] Event doesn't conflict with active events

## References

- API: `docs/geoscape/` and `docs/narrative/`
- Examples: `mods/core/narrative/`
- Balance Guide: `docs/narrative/`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
