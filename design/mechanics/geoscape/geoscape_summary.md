# Geoscape Summary

## Strategic Clock

- Global time advances hourly; research, manufacturing, travel, and construction tick simultaneously with events queued chronologically.
- Monthly summary resolves funding, diplomacy, maintenance, alien escalation, and transitions campaign phases (Contact → Escalation → Crisis → Climax at months 3/6/9/12/15).

## World Layout

- Earth/Moon/Mars share a 90×45 hex grid (~500 km per hex) aggregated into provinces and regions; each stores terrain, population, resources, ownership, unrest, and alien influence.
- Base placement restricted by terrain, hostile control, and diplomatic permissions; no adjacency bonuses—coverage purely facility-driven.

## Craft & Mission Flow

- Craft states: Ready, Transit, Mission, Recovery; fuel determines range, and route choice (direct/stealth/low altitude) modifies interception risk (+100%, +50%, +30%).
- Portal transport (Tier 3 research) enables instant transfer between two portal bases (cost 50K build, 5K per use, 10 units or 5K kg capacity).
- Radar + weather determine detection (clear 100%, rain 75%, storm 50%, snow 25%, blizzard 0); missions spawn 2-5 faction ops, 1-3 country events, 0-2 randoms monthly plus player-triggered interceptions.

## Stealth & Alert Budget

- Covert missions use a 0-100 alert pool; loud actions consume points (shots −10, grenades −25, alarms −50). ≥50 remains undetected, 25-49 compromised, <25 escalates to combat.
- Successful extraction with ≥50 grants bonus credits/XP; failure shifts mission to Battlescape engagement.

## Territory & Escalation

- Provinces swap control due to mission outcomes, alien influence, or diplomatic collapse; losing provinces reduces funding and detection, alien bases force mission surge.
- Campaign phases scale UFO frequency, mission templates, and alien tech tiers; each phase ties to research gates and story progression.

## Integration & Testing

- Geoscape orchestrates game state transitions (Battlescape/Basescape), passes mission data, and persists province/craft/weather seeds per turn.
- QA focus: radar/weather detection math, craft fuel/risk, alert pool boundaries, phase checkpoints, portal transport constraints, and province state transitions feeding missions/diplomacy.
