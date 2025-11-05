# Pilot Assignment Snapshot

## Core Rules

- Any unit can occupy a craft’s single pilot slot; doing so locks them out of ground deployments while the craft is active and subjects them to crash risk.
- Piloting is just another stat: default 0 for untrained units, 6–12 (and higher via XP) for trained pilots. Gains come from unified XP, promotion bonuses, traits (Natural Pilot +15, Ace +20, Clumsy −10), and gear (Flight Helmet +5, Neural Link +10).
- Only the pilot contributes craft bonuses; passengers/crew gain transport and XP but never modify performance.

## Craft Performance Bonuses

- Accuracy/Dodge: Base craft value + (Piloting ÷ 5). Thresholds unlock abilities—50+: Evasive Maneuvers (+20% dodge), 70+: Precision Strike (+30% accuracy once), 90+: Ace Maneuver (perfect dodge once).
- No minimum piloting requirement per hull; low-stat pilots simply underperform. Assignment swaps require craft at base and consume one strategic turn.

## XP & Role Tension

- Single XP pool: interceptions and ground missions both feed total XP, which drives rank, piloting growth, and perk unlocks. No separate pilot track.
- Strategic trade-off: use veterans with high piloting to secure interceptions or keep them planetside for elite tactical squads; losing a craft can delete top soldiers.

## Implementation Notes

- UI should clearly flag pilot status, piloting stat, and resulting craft modifiers; reassignment flow (pilot ↔ barracks) must enforce “craft at base” rule.
- Tests: verify bonus math, threshold abilities, XP sharing with passengers, reassignment timing, and crash casualty handling.
