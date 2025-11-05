# Fame, Karma, Reputation, Score Summary

## Metric Snapshot

- **Karma (-100 to +100)**: moral alignment; decays toward 0; gates advisors, missions, and narrative endings.
- **Fame (0-100)**: public notoriety; decays without activity; drives mission volume/difficulty, alien focus, and certain market unlocks.
- **Reputation (0-100)**: legal authority; only increases (baseline +1 per quarter); boosts diplomatic leverage and base permissions.
- **Score (0-∞)**: cumulative civilians saved per country; never decays; primary ending determinant and gratitude driver.

## Gain & Loss Patterns

- Karma shifts via mission ethics, prisoner handling, advisor choices, and moral events (±5 to ±20 typical).
- Fame rises on splashy victories, research releases, interceptions, and even notorious defeats; fades during quiet months.
- Reputation grows through time, sanctioned operations, and shared research; no loss mechanics defined.
- Score accrues per mission/defense/UFO kill; modders set per-mission values.

## Gameplay Hooks

- Karma thresholds unlock or forbid alignment-specific advisors and story arcs; extreme values anchor the tone of the campaign.
- Fame influences encounter pacing (more missions, higher-tier UFOs), increases diplomatic visibility, and gates certain black market tiers.
- Reputation affects negotiation outcomes, funding grants, and base construction approvals; high values broadcast legitimacy.
- Score feeds endgame states—high totals yield optimistic outcomes, low totals trigger bleak endings; tracked per nation to show regional success.

## Integration Notes

- Metrics operate independently from diplomatic Relations; a player can be saintly yet politically isolated or infamous but well-funded.
- UI displays trends and thresholds for each metric; advisors and missions call out exact requirements.
- Modders tune decay curves, event values, and gating thresholds through config, keeping this file canonical for reference.

## Testing Focus

- Verify decays (Karma/Fame drift toward zero while Reputation/Score remain stable).
- Ensure mission/advisor locks trigger precisely at configured thresholds.
- Confirm Fame-driven mission escalation and UFO targeting react to value changes.
- Validate Score accumulation per country and downstream ending calculations.
