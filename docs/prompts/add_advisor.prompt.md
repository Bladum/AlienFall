# add_advisor

Create or update AI advisor/character definitions in TOML format.

## Prefix
`advisor_`

## Task Type
Content Creation / Modification

## Description
Create or update advisor entries in `mods/core/narrative/` or `mods/core/lore/` folders. Advisors are NPC characters providing advice, commentary, and narrative guidance with personalities and expertise areas.

## Inputs

### Required
- **Advisor ID**: Unique identifier (e.g., `advisor_commander_sato`, `advisor_scientist_elena`)
- **Advisor Name**: Display name for UI
- **Advisor Role**: Category - `commander`, `scientist`, `engineer`, `diplomat`, `psychologist`, `spiritual_guide`
- **Description**: Advisor background and expertise

### Optional
- **Personality**: Character traits and speech patterns
- **Expertise Areas**: Fields of knowledge
- **Commentary**: Lines for various game situations
- **Morale Effects**: Impact on team morale
- **Special Abilities**: Unique advisor functions
- **Relationships**: Connections with other NPCs

## Scope

### Affected Files
- `mods/core/narrative/advisors.toml` (if created)
- Related: `mods/core/lore/characters/`
- Related: Dialogue and narrative systems
- Related: Tutorial and guidance systems

### Validation
- ✓ Advisor ID is unique
- ✓ All required TOML fields present
- ✓ Advisor role matches valid category
- ✓ Dialogue strings are present
- ✓ Morale effects reasonable
- ✓ Expertise areas valid
- ✓ Relationships reference valid advisors

## TOML Structure Template

```toml
[[advisors]]
id = "advisor_id"
name = "Advisor Display Name"
description = "Background and expertise of advisor"
role = "commander|scientist|engineer|diplomat|psychologist|spiritual_guide"
organization = "organization_id"
tags = ["tag1", "tag2"]

[appearance]
title = "Official Title"
rank = "Commander"
appearance_description = "Physical description"
voice_type = "male|female|neutral"

[personality]
personality_type = "optimistic|cynical|cautious|aggressive"
speech_pattern = "formal|casual|technical|poetic"
humor_level = "dark|light|none"
stress_response = "calm|anxious|reactive"

[expertise]
primary_expertise = "field"
secondary_expertise = ["field"]
knowledge_areas = ["military", "science"]
specializations = ["weapons", "armor"]

[morale]
morale_bonus = 0.1
morale_penalty_when_absent = -0.05
morale_effect_on_soldiers = "positive"
confidence_boost = 0.15

[availability]
available_from_start = true
unlock_condition = "campaign_phase"
dismissible = false
replacement_available = true

[commentary]
comment_on_victory = "Commentary on successful mission"
comment_on_defeat = "Commentary on failed mission"
comment_on_casualties = "Response to soldier deaths"
comment_on_research = "Response to research completion"
comment_on_crisis = "Response to major crisis"
comment_general = "General observations"

[[commentary.situations]]
situation = "low_morale"
response = "Advisor's morale boost suggestion"

[[commentary.situations]]
situation = "low_funds"
response = "Advisor's economic suggestion"

[relationships]
best_friend = "advisor_id"
rival = "advisor_id"
respects = ["advisor_id"]
conflicts_with = ["advisor_id"]

[special_abilities]
ability_id = "advisor_ability"
ability_trigger = "manual|automatic|situational"
ability_cooldown_days = 0
ability_effect = "morale_boost|insight|discount"

[dialogue]
greeting_line = "Greeting when starting game session"
briefing_style = "detailed|brief|technical|casual"
available_for_player_questions = true
max_interactions_per_session = 5

[progression]
experience_points = 0
loyalty_points = 0
stress_level = 0
effectiveness_rating = 1.0
```

## Outputs

### Created/Modified
- Advisor entry with complete character definition
- Personality and expertise established
- Commentary lines written for situations
- Morale effects configured
- Relationships defined

### Validation Report
- ✓ TOML syntax verified
- ✓ Advisor ID uniqueness confirmed
- ✓ All dialogue present
- ✓ Relationships reference valid advisors
- ✓ Morale effects reasonable
- ✓ Expertise areas valid
- ✓ No circular relationships

## Process

1. **Create Character Concept**: Develop advisor personality and background
2. **Define Role**: Establish primary expertise and function
3. **Write Personality**: Create speech patterns and traits
4. **Author Commentary**: Write advisor lines for various situations
5. **Set Morale Effects**: Configure morale impact
6. **Establish Relationships**: Connect advisor to others
7. **Add Abilities**: Configure special functions
8. **Validate**: Check TOML and narrative consistency
9. **Test**: Interact with advisor in-game
10. **Document**: Update advisor documentation

## Testing Checklist

- [ ] Advisor loads without errors
- [ ] Advisor appears in game
- [ ] Personality and speech style consistent
- [ ] Commentary displays at appropriate times
- [ ] Morale bonuses apply correctly
- [ ] Special abilities function
- [ ] Relationships display correctly
- [ ] Dialogue is engaging and lore-appropriate
- [ ] No console errors
- [ ] TOML validates successfully
- [ ] Advisor balances with other advisors
- [ ] Character feels distinct and unique

## References

- API: `docs/narrative/` and `docs/lore/`
- Examples: `mods/core/narrative/`
- Dialogue Guide: `docs/narrative/dialogue.md`
- Game Numbers: `docs/balance/GAME_NUMBERS.md`
