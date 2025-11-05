# Battlescape AI Summary

## Hierarchy & Roles

- **Side layer** selects global stance (Aggressive, Tactical, Defensive, Retreat) based on mission type, strength ratio, terrain, and squad morale; allies mirror player focus, neutrals avoid combat.
- **Teams** (2-4 squads) carry specialized roles—Assault, Support, Flanking, Defense—coordinating movement, healing, and cover usage each turn through a reuseable evaluation loop.
- **Squads** maintain formations (line, column, wedge, cluster, dispersed) chosen for terrain; decisions sequence objective evaluation → enemy visibility → movement planning → formation upkeep → target assignment.
- **Units** run a deterministic state machine (Idle, Alert, Move, Engage, Suppressed, Reaction Fire) with confidence tracking that modulates aggression, retreat thresholds, accuracy bonuses/penalties, and action selection.

## Decision Mechanics

- **Confidence** starts at 60%, decays with casualties/suppression/time, climbs with hits/kills/objectives/allies; behavior windows: 0-20 retreat, 21-40 defensive, 41-60 balanced, 61-80 aggressive, 81-100 dominant.
- **Target prioritization** uses weighted score: Threat (0.5), Distance (0.3), Exposure (0.2); >80 results in focus fire, <20 deprioritized unless no alternatives.
- Formations tweak targeting heuristics (e.g., line favors closest/exposed; column favors distant threats; wedge focuses elites/flankers).

## Pathfinding & AP Economy

- A* pathfinding weights terrain, cover, cohesion; movement cost = base + terrain modifier + cover bonus − cohesion penalty, avoiding isolation while seeking LoS positions.
- Action points: base 4 per turn, floor 1, cap 5; penalties from low health (−2), panic (−2), trauma (−1), stunned (−2), suppression restricts actions but keeps AP.
- Difficulty modifiers grant +1 AP to player units on Easy; other levels use shared economy.

## QA Focus

- Validate strategy selection flips appropriately with force ratios and mission objectives.
- Ensure confidence adjustments stack correctly and clamp to 10-95% boundary; verify behavioral transitions at thresholds.
- Test formation adherence during pathfinding, especially in narrow corridors (columns) and open areas (lines/wedges).
- Confirm AP reductions never drop below 1 and that suppression locks action choices without incorrectly altering AP totals.
- Run threat scoring scenarios to confirm focus fire on high-value exposed targets and deprioritization of entrenched low-threat enemies.
