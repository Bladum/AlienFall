# Geoscape Core Mechanics

## Strategic Layer Scope

- Monthly turn loop controlling global bases, craft deployments, diplomacy, and mission responses.
- All actions consume real time; simultaneous events resolve by timestamp.

## World Map Structure

- Globe discretised into 90×45 hex grid; each hex ≈500 km of surface area.
- Hexes aggregate into provinces (6–12 hexes) and regions grouping allied provinces.
- Hex attributes drive mechanics: terrain (movement, construction), population (mission cadence, funding weight), resources (construction inputs), ownership (diplomatic state).
- Procedural generator ensures equitable resource spread, realistic choke points, and culturally aligned borders.

## Province & Territory Control

- One player base per province; control grants local resources and diplomatic leverage.
- Losing a province triggers relation penalties for the owning country and reduces radar coverage.
- Provinces record unrest and alien influence; high values escalate mission frequency.

## Base Network Rules

- Placement blocked by mountains, dense urban hexes, or hostile strongholds.
- Initial build queue establishes command, power, radar, hangar, and logistics facilities.
- Expansion unlocks via research; each facility contributes power draw, maintenance, and functional bonuses.
- Territory adjacency no longer grants bonuses; coverage is determined solely by facility stats.

## Portal Transport (Research Tier 3)

- Construction cost 50 000 cr, 30‑day build, limit two portals total.
- Activation fee 5 000 cr per use; transfers up to 10 units or 5 000 kg instantly between portal bases.
- Cannot move craft or operate if either portal is disabled; ignores distance but still subject to strategic turn order.

## Craft Posture on Geoscape

- States: Base (ready), Transit (interceptable), Mission (locked), Recovery (returning with penalties).
- Movement cost = distance × fuel efficiency; range constrained by onboard fuel.
- Interception risk modifiers: direct routes +100%, stealth routing +50%, low-altitude +30%; stationary craft immune.

## Weather & Seasonal Modifiers

- Global weather rolls per region; durations measured in days or weeks.
- Radar visibility scaling: clear 100 %, rain 75 %, storm 50 %, snow 25 %, blizzard 0 % (missions grounded).
- Seasonal presets adjust weather odds and mission templates (e.g., winter halves mission spawn rate, summer boosts alien aggression).

## Mission Flow & Detection

- Radar facilities define detection radius; penalties from weather apply multiplicatively.
- Monthly spawn bands: 2–5 faction missions, 1–3 country missions, 0–2 random events, plus player-triggered interceptions.
- Mission catalogue spans crash recovery, terror defence, base assault, colony defence, research recovery, supply raids.

## Stealth Operations Budget

- Stealth missions share a 0–100 alert pool; budget depleted by overt actions (shots −10, grenades −25, alarms −50, etc.).
- Alert bands: ≥50 undetected, 25–49 compromised, <25 combat. Exceeding budget forces tactical escalation.
- Successful extraction with ≥50 alert grants bonus credits and XP.

## Campaign Escalation Curve

- Phase 1 Contact (months 1–3): scouts, introductory missions.
- Phase 2 Escalation (4–8): increased interceptions, diplomatic strain.
- Phase 3 Crisis (9–14): coordinated assaults, base raids.
- Phase 4 Climax (15+): mothership arrival, endgame branches.
- Checkpoints at months 3/6/9/12/15 gate scripted mission arcs and research unlocks.

## Strategic Timekeeping

- Global clock advances in discrete hours; construction, research, manufacturing, and travel execute concurrently.
- Monthly summary resolves funding adjustments, diplomatic shifts, maintenance costs, and alien escalation ticks.

## Integration Touchpoints

- Geoscape exposes mission hooks to Battlescape, feeds interception sims, and consumes outputs from diplomacy, finance, and unit rosters.
- State data persisted per turn: province ownership, weather seeds, mission queue, craft statuses, funding modifiers.
