# Interception Layer Summary

## Battlespace Structure

- Encounters resolve across three stacked sectors (air, land/water, underground) with up to four objects per side per tier; weapons specify which sectors they can reach.
- Player units occupy the left, enemies the right; only scripted abilities shift units between sectors mid-fight.

## Turn Economy

- Action Points per turn scale with hull integrity: 4 at >50% HP, 3 between 25-50%, 2 below 25%.
- Energy pools (small craft 50-100, large 100-200, bases 200-400) regenerate 5-15 per tick; AP + energy costs gate firing, evasion, and systems.
- Running out of either resource locks weapon/evasion usage until regeneration catches up.

## Accuracy & Damage Model

- Final hit chance = Base Accuracy − range penalty (−2% per hex beyond optimal, capped at 1.5× range) − evasion + situational modifiers; clamped 5-95%.
- Evasion modes persist until overridden: light (−10%, 5 AP/5 EP), full (−20%, 1 AP/15 EP), emergency (−30%, 2 AP/25 EP).
- Damage = Base × (1 ± 5-10% variance); weapon bands: point defense 15-25, cannon 40-60, missile 50-80, laser 60-90, plasma 70-120, torpedo 60-100.
- Heat tracks per shot (+5 single, +15 burst, +3/turn beam, +20 overcharge); dissipation: bases −15/turn, large −10, small −5 with ±5 environment modifiers. Accuracy drops 10% at 51-100 heat; ≥101 jams weapon until <50, with doubled cooling while jammed.

## Range, Cooldown, and States

- Flight time expressed as turns to impact (close 5 → very long 1) independent of cooldowns (typically 1-3 turns).
- Health zero destroys craft/installation; hitting 25% HP triggers retreat checks or auto-shutdown of base weapons.

## Outcomes & Progression

- Victory removes enemy force or secures objective; survivors enter repair (baseline 10% max HP per week). Defeat destroys craft and damages facilities, potentially spawning rescue missions.
- Partial victories force enemy retreat and may spawn crash/landing sites for Battlescape follow-up.
- Pilots earn XP (participation +10, kill +50, assist +25, survival +10, forced retreat +30, flawless defense +50) with split to co-pilot/crew; ranks unlock maneuvers (barrel roll, immelman, cobra).

## Base Defense & Environment

- Base emplacements behave as interception objects; radar links grant +10% accuracy, power draw counts against basescape priorities.
- Failed interception can escalate to optional Battlescape defense; success shields facilities from damage.
- Weather/biomes shift accuracy and heat: rain −5%, storm −10%, sandstorm −5% accuracy/+10% heat, ocean −5 heat/turn, desert +5 heat/turn, arctic −5 energy regen, blizzard grounds land AA.

## QA Targets

- Validate AP/EP scaling with hull damage, evasion persistence, accuracy clamps, heat thresholds, and repair timers.
- Cover sector targeting restrictions, partial victory crash generation, pilot XP distribution, and weather-based modifiers.
