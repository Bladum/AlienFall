# Mission Generation & Outcomes

## Purpose

- Wraps strategic escalation, faction goals, and player actions into tactical deployments that feed the Battlescape, diplomacy, economy, and progression loops.
- Supplies designers with levers (frequency, rewards, composition, karma) to craft interesting campaign arcs and difficulty pacing.

## Generation Pipeline

- Monthly scheduler aggregates faction activity (2-5/month), country pleas (1-3), random/world events (0-2), player-triggered hooks, black market contracts, and escalation milestones.
- Algorithm: pick mission archetype → compute difficulty using `month ×0.2 + bases ×0.15 + avg_unit_level ×0.1` → choose province weighted by faction presence and radar coverage → roll enemy roster/neutral counts → assign rewards, penalties, XP modifiers → enqueue on Geoscape radar list.
- Purchased contracts incubate 3-7 days before spawning, carry large payouts, and apply karma hits that downstream into diplomacy and faction blame systems.

## Mission Families & Objectives

- **Alien Operations**: Crash, landing, base assault, terror, abduction, supply raid; each defines crew mix bands, salvage tables, relations swings, and escalation adjustments.
- **Country Requests**: Base/colony defense, escort, research facility; gated by relations thresholds (+25 to +75) with success restoring panic/funding and failure eroding alliances.
- **Black Market Contracts**: Assassination, sabotage, heist, kidnapping, false flag, data theft, smuggling; player-funded with explicit credit/karma trade-offs and unique loot hooks.
- Primary goals (eliminate foes, secure assets, preserve VIPs/facilities) layer with secondary bonuses (keep UFO intact, hit civilian survival quotas, stealth requirements) to encourage varied tactics.
- Failure consequences cascade: panic spikes, relations loss up to withdrawal, facility destruction with 90-day rebuild timers, alien bases remaining active, or blame shifts via false flag outcomes.

## Rewards, Scaling, and Progression

- Credits span 300–2000 for standard ops, 120K+ for contracts; fame +5 to +15 on terror rescues; karma cost −5 to −40 governs black market reputational risk.
- Salvage payout targets 50% of market value, supplementing economy/research; colony/base defenses preserve infrastructure instead of netting large credits.
- Difficulty bands adjust mission counts (Easy 2-3 → Impossible 5-8/month), enemy squad size (0.75× → 1.5×), and reward multipliers (Easy ×1.25, Hard ×0.8, Impossible ×0.6) to maintain pressure.
- XP formula: `Total = (Base 50 × Difficulty Multiplier × Mission Modifier) + Performance Bonus`, yielding ~60 XP Easy crash success → 230 XP Impossible base victory; ensures Battlescape squads rank appropriately for later arcs.

## Integration & QA Focus

- Geoscape detection and interception flow dictate which missions become playable; failed interceptions transition to landings/terror, while successful shoot-downs spawn crash recoveries.
- Battlescape map packages depend on mission archetype (urban terror, facility defense, base layout mirroring Basescape blueprint); neutral civilians/militia seeded per spec.
- Diplomacy/economy hooks: apply relations deltas, panic changes, funding tier modifiers, karma adjustments, and inventory losses in the same tick the mission resolves.
- QA checkpoints: regression tests for mission distribution, difficulty curves, reward/XP math, diplomatic shifts, contract spawn timing; scenario tables already specified in design doc for automated validation.
