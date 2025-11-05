# Battlescape Damage Types Summary

## Core Types & Armor Interactions

| Type | Primary Sources | Light | Medium | Heavy | Shield Notes | Key Riders |
|------|-----------------|-------|--------|-------|--------------|------------|
| Kinetic | Firearms, melee | 50% | 30% | 10% | Shields 0% | Straight damage |
| Explosive | Grenades, rockets | 40% | 20% | 5% | Shields 50% | Orthogonal waves stopped by walls, halved by armor |
| Energy | Plasma, beams | 20% | 40% | 60% | Shields 90% | High vs lightly armored |
| Psi | Mind attacks | 0% | 0% | 0% | Psi shield 80% | Ignores physical armor |
| Stun | Shock, concussive | 70% | 50% | 30% | Shields 40%, Insulated 95% | Builds stun pool (−1/turn decay) |
| Acid | Corrosive weaponry | 30% | 50% | 70% | Shields 0%, Acid-proof 85% | Applies corrosion (armor degradation) |
| Fire | Incendiary | 40% | 50% | 60% | Shields 30%, Fire-proof 80% | Applies burning DoT + morale hit |
| Frost | Cryo tech | 60% | 50% | 40% | Shields 20%, Frost-proof 85% | Applies slow (+AP/move penalties) |

## Explosion Waves

- Propagate separately along four cardinal directions; distance scaling 100% → 80% → 60% → 40% per hex.
- Walls block waves completely; units reduce damage 50% then apply armor resist but do not block propagation.
- Tactical implication: hugging walls counters explosions; stacking units does not protect rear ranks.

## Status Interplay

- Acid reduces subsequent armor effectiveness, opening targets to Kinetic/Energy follow-ups.
- Fire introduces DOT + morale loss; smoke spawns from burning tiles raising sight cost.
- Frost stacks movement penalties (+1 AP per hex) and −10% accuracy per layer.
- Stun accumulates in 0–20 pool, immobilizes at >10, knocks prone at >20; decay −1 per turn or −5 when idle.

## Equipment Counterplay

- Specialized armor variants (psi shield, insulated, acid/fire/frost resistant) mitigate niche threats but trade general resistances.
- Energy shields excel vs Energy/Explosive but weak vs Acid/Kinetic; synergy with positioning vital.

## QA Notes

- Validate resistance tables align with armor tiers across unit, shield, and special armor definitions.
- Test explosion propagation across mixed terrain (walls, units, open) to ensure blocking rules apply correctly.
- Confirm status riders trigger appropriately after base damage (corrosion stacking, burning duration, stun thresholds).
- Ensure Exotic armor pieces apply correct reductions and interact with primary resistances multiplicatively.
