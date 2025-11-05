# AI Systems Summary

## Layered Architecture

- **Strategic AI** drives Geoscape factions, countries, and suppliers via deterministic decision trees; escalation meters, threat assessments, and resource budgets generate missions and diplomacy shifts.
- **Operational AI** governs Interception encounters, selecting attack, withdrawal, or escape states per UFO based on survival odds, health, and objectives.
- **Tactical AI** coordinates Battlescape sides → teams → squads → units, with confidence-driven behaviors, formation logic, and threat scoring guiding movement and fire.
- **Autonomous Player AI** mirrors human strategy for analytics: base building, research queues, craft deployment, and UI interactions feed telemetry loops.

## Strategic Layer Highlights

- Factions evaluate player threat vs resources each tick, allocating attacks, base construction, and diplomacy accordingly; escalation thresholds (0-10 early → 50+ crisis) unlock late-game events.
- Countries adjust funding per mission outcomes, fame, and panic; suppliers tune pricing/stock by favor; mission generator scales enemy force via difficulty formula tied to month, base count, and unit level.

## Operational/Tactical Behaviors

- UFOs cycle Aggressive → Tactical Withdrawal → Escape states; actions consume energy and update posture each turn.
- Battlescape AI employs squad formations (line, wedge, column, dispersed) with deterministic threat scoring (weighting threat, distance, exposure) and confidence modifiers influencing aggression, retreat, and accuracy.

## Tuning & Difficulty

- Difficulty alters squad size, AI aggression multipliers, reinforcement counts, and strategic escalation rates.
- Config files expose weights for threat scoring, confidence decay/gain, mission frequency, and economic reactions; analytics hooks log every decision for review.

## QA Checklist

- Validate faction escalation math, mission generation balance, and diplomatic reactions to fame/panic.
- Test UFO state transitions, energy usage, and retreat triggers across craft matchups.
- Confirm Battlescape threat scoring, confidence thresholds, formation switching, and reaction fire; ensure autonomous player AI can run full campaigns without deadlocks.
