# Battlescape Summary

## Battlefield Structure

- Uses shared vertical axial coordinates `{q, r}`; tiles convert to cube space for distance math, keeping Geoscape/Basescape parity.
- Four-tier map pipeline: tile → 15-hex block → procedural grid → final battlefield; scripts rotate/mirror blocks, draw roads/rivers, and enforce biome rules.
- Sides (player, ally, enemy, neutral) split into teams that share line of sight and initiative budgets; deployment assigns squads to landing zones (1-4 depending on map size).

## Turn Economy & Initiative

- One turn ≈30 in-game seconds; base 4 AP per unit with modifiers for health (<25% HP −2 AP), morale (panic tiers), suppression (−3 AP stacks), and stimulants (+1 AP, cap 5).
- Initiative = speed ± encumbrance/status; player wins ties, and reaction reserves must be held back from AP pool.
- Difficulty multipliers adjust squad size (75–150%), AI intelligence (50–300%), reinforcement count (0–3 waves), and landing zone pressure.

## Combat Resolution

- Final accuracy = Base Aim × Range × Fire Mode × Cover × LOS, clamped 5–95%; cover sums 5% penalties per obstacle while LOS halves accuracy when obscured.
- Projectile deviation re-traces hex path on misses, allowing scatter damage and obstacle strikes; explosions propagate orthogonally with −5 damage per hex and 100% wall blocking.
- Damage model stacks base variance, location multipliers (head 1.5×, limb 0.8×), armor resistances (light +5, combat +15, heavy +25 with AP penalties), and eight damage types with status riders.

## Advanced Systems

- Status suite spans suppression, stun pools, fire, smoke, gas variants, frost, bleeding, and morale/sanity cross-talk; leaders can rally (+2 morale, 5-hex radius) while mechanical units ignore panic entirely.
- Concealment layer regulates stealth budgets, detection cones, noise propagation, and alert states; overwatch and melee counters respect visibility and remaining AP.
- First-person mode (see `3D.md`) mirrors mechanics exactly, adding WSAD navigation, FOV-limited vision (90° cone), and instant toggles back to overhead view.

## Environment & Objectives

- Terrain materials carry armor tiers (flowers 3, wood 6, brick 8, stone 10, metal 12) with damage → damaged → rubble → ground progression; weather imports from Geoscape (rain −10% accuracy, snow +2 AP cost, blizzard −20%).
- Mission archetypes cover elimination, captures, evacuations, defenses, sabotage, and timer-driven extractions; failure triggers squad wipe, timer expiration, or unmet objective logic.
- Loot manifests, injuries, morale deltas, and captive states persist back to Basescape, powering research, manufacturing queues, and narrative beats.

## QA Targets

- Exercise map scripts per biome, landing zone validation, squad auto-promotion equipment budgets, and cross-team LOS sharing.
- Verify AP/initiative modifiers, fire mode costs, cover accumulation, projectile deviation, and explosion blocking across weapon classes.
- Stress status stacking (suppression, fire, gas, frost), stealth detection thresholds, 3D↔2D toggles, and persistence of battle results (XP, injuries, salvage, morale).
