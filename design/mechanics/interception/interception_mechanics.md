# Interception Core Mechanics

## Engagement Space

- Three stacked sectors: Air (fliers/orbitals), Land/Water (ground sites, naval assets), Underground (subterranean bases); each sector hosts up to four allied or hostile objects.
- Player objects always render left, enemies right; sector switching limited to scripted abilities.
- Weapons define cross-sector reach: air-to-air, air-to-land, land-to-air, land-to-water, air-to-underwater, water-to-water.

## Turn Resources

- Craft and installations receive AP per turn based on health state: >50 % HP → 4 AP, 25–50 % → 3 AP, <25 % → 2 AP.
- Energy pools fuel actions: small craft 50–100 EP (regen 5–10), large craft 100–200 EP (regen 10–15), bases 200–400 EP (regen 15+).
- Actions consume both AP and EP; running dry prevents weapon use or evasion until regeneration ticks.

## Accuracy Resolution

- Final hit chance = Base Accuracy − Distance Penalty − Target Evasion + situational modifiers, clamped to 5–95 %.
- Base accuracies: point defense 85 %, cannon 75 %, missiles 80 %, lasers 70 %, plasma 65 %, torpedoes 75 %.
- Distance penalty: −2 % per hex beyond optimal (max 1.5× optimal range).
- Evasion options: light (−10 %, 5 AP/5 EP), full (−20 %, 1 AP/15 EP), emergency (−30 %, 2 AP/25 EP); persists until new action.
- Environmental modifiers ±5–15 % (weather, sensor states, cover arcs).

## Damage & Heat

- Damage = Base × (1 ± variance), with variance 5–10 % depending on weapon; no armor reduction or critical hits.
- Representative damage spans: point defense 15–25, cannon 40–60, missiles 50–80, lasers 60–90, plasma 70–120, torpedoes 60–100.
- Heat accumulates per shot (single +5, burst +15, beam +3/turn, overcharge +20); dissipation: bases −15/turn, large craft −10, small craft −5, ±5 environmental.
- Thresholds: ≤50 normal, 51–100 −10 % accuracy, ≥101 jams weapon until heat <50 (dissipation doubles while jammed).

## Range & Cooldown

- Range measured in turns to impact: close 5, short 4, medium 3, long 2, very long 1; separate from weapon cooldown (1–3 turns typical).
- Missile example: 1-turn flight, 3-turn cooldown; lasers strike same turn but consume EP each turn sustained.

## Object States

- Health tracks structural integrity; reaching zero destroys object (craft lost, base facility disabled).
- Deactivation thresholds: 25 % HP forces retreat check; bases auto-disable weapons/engines before destruction.

## Outcomes & Post-Combat

- Victory: enemy forces eliminated or objective protected; surviving player craft accrue repair times (10 % max HP per week baseline).
- Defeat: craft destroyed (crew escape pods trigger rescue mission), bases suffer facility damage, alien objective proceeds.
- Partial victory: enemy forced to retreat; may yield crash/landing site generating Battlescape mission.

## Experience & Pilots

- Pilot XP awards: mission participation +10, kill +50, assist +25, survival +10, forced retreat +30, flawless defence +50.
- XP split: pilot 100 %, co-pilot 50 %, crew 25 %; feeds separate pilot rank progression unlocking maneuvers (barrel roll, immelman, cobra).

## Base Defence Integration

- Base installations act as stationary interception objects; turrets consume power, radar boosts accuracy by 10 % when linked.
- Failed interception triggers optional Battlescape defence mission; success prevents facility damage.

## Environmental Effects

- Weather modifies accuracy and detection (clear 0, rain −5 %, storm −10 %, sandstorm −5 % accuracy/+10 % heat, blizzard grounding land-based AA).
- Biome-specific hazards: ocean grants −5 heat/turn, desert +5, arctic reduces energy regen by 5.
