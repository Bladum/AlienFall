# Game Design Document: UFO / X-COM (1994-style)

Version: 1.0
Author: GitHub Copilot
Date: 2025-08-18

# Overview

This document defines a precise design for a strategy/tactics hybrid inspired by MicroProse's 1994 classic "UFO: Enemy Unknown" (a.k.a. X-COM: UFO Defense). The goal is to recreate the core systems, player experience, and balancing philosophy of the original while specifying concrete data shapes, mechanics, and content required for implementation and testing.

Design goals:
- Faithful recreation of the two-layer gameplay: strategic global management (Geoscape) and turn-based tactical encounters (Battlescape).
- Clear, deterministic simulation rules with emergent complexity.
- Data-driven content to allow easy tuning of units, weapons, and aliens.

Target platform: desktop (Windows first), single-player.

Core pillars:
- Base & resource management (build, research, manufacture, personnel).
- Strategic decision-making (allocation, interception, mission selection).
- Tactical combat requiring positioning, risk assessment, and resource use.

# Requirements checklist
- Create a GDD describing all major systems for a 1994-style X-COM (UFO) game. [Done]
- Focus on the 1994 MicroProse design and be precise/detailed. [Done]
- Provide data shapes, mechanics, UI considerations, balancing notes, and testing/QA guidance. [Done]

# High-level game loop / player experience

1. Player begins by selecting a starting country and initial funding package.
2. The Geoscape runs in near-real-time: UFO events, panic changes, funding reports, and mission alerts appear.
3. Player allocates resources: build facilities, hire staff, buy/produce equipment, and research alien tech.
4. When a UFO appears, the player scrambles interceptors; if engaged, an air-to-air minigame resolves or the UFO escapes/crashes.
5. If a UFO is downed or a terror/activity mission is triggered, the player sends a ground squad to a Battlescape mission.
6. Battlescape is turn-based tactical combat with action points, line of sight, and destructible terrain.
7. Post-mission: salvage, research alien items, recover survivors, and decide on manufacturing and deployment.
8. Repeat until long-term objectives are satisfied or the project collapses (funding/panic threshold).

# Important systems (detailed)

1) Geoscape (Strategic Layer)
- Purpose: Present world map, manage base locations, monitor UFO/alien activity, funding, panic levels, and research/manufacturing queues.
- World state:
  - Countries: name, funding multiplier, panic level (0-100), research/funding modifiers, continent.
  - UFO spawns: type, strength, flight path, altitude, speed, ownership.
- Player actions:
  - Purchase/construct facilities: Antenna, Workshop, Laboratory, Living Quarters, Hangar, Alien Containment, etc.
  - Hire/fire staff: scientists, engineers, soldiers, technicians, administrators. Staff have stats: efficiency, rank, salary, morale.
  - Deploy interceptors: assign pilots, armaments (standard missiles), fuel costs.
  - Place base radar coverage and detection radius (range depends on radar level).
  - Set production queues and allocate manufacturing capacity.
- Time model: Geoscape advances in discrete ticks (e.g., 1 minute per tick). Events can be scheduled by ticks. Faster than Battlescape.

2) Base Management (expanded)
- Purpose: manage physical bases where you build, research, store, and heal — a core long-term resource sink and progression bottleneck.

- Facilities and their roles (detailed):
  - Living Quarters / Barracks
    - Purpose: houses soldiers and civilian staff. Increases maximum roster count and reduces monthly morale/turnover.
    - Metrics: footprint (tiles), build_time, power_draw (small), maintenance_cost, staff_capacity.
  - Workshop / Manufacturing
    - Purpose: convert blueprints + materials into items, ammo, armors, and vehicles. Handles manufacturing queues.
    - Metrics: concurrent_production_slots, base_throughput (units/day), engineer_requirement (more engineers reduce build time), power_draw, maintenance.
  - Laboratory
    - Purpose: host research projects. More labs or larger labs increase concurrent research slots and reduce research time per scientist efficiency.
    - Metrics: research_slots, base_research_rate, scientist_capacity, power_draw.
  - Radar / Antenna (Detection)
    - Purpose: extend local UFO detection; better radar equipment grants longer detection ranges and higher quality tracks.
    - Mechanics: detection radius (km) and track_quality (affects ability to intercept/engage). Radar requires power and technicians for maintenance.
  - Hangar / Airfield
    - Purpose: store and launch interceptors. Hangars occupy tiles and provide parking/servicing slots.
    - Mechanics: interceptors require runway/taxi space or dedicated hangar slots; hangar level determines max interceptor size and number.
  - Alien Containment / Interrogation / Autopsy Lab
    - Purpose: store captured live aliens and run autopsies to unlock technology prerequisites.
    - Mechanics: containment cells use power and require security staff; autopsy yields research samples and requires scientists.
  - Medical Bay
    - Purpose: treat wounded soldiers faster and handle long-term recovery; optional facilities like surgery reduce lost time of injured soldiers.
  - Power Plant / Generators
    - Purpose: provide base power to run facilities. Generator capacity must exceed the sum of facility power_draw values, otherwise power outages reduce efficiency.
    - Mechanics: generators have build cost, maintenance, and generate X power units; placing insufficient power causes incremental penalties.
  - Storage / Ammunition Depot
    - Purpose: hold inventory (ammo, medkits, spare parts). Storage size limits stockpiles.

- Staff roles, effects and salaries:
  - Scientists
    - Effect: increase research throughput; higher-level scientists reduce project time and unlock complex work faster.
    - Salary: monthly cost; hiring higher-skill scientists increases expense.
  - Engineers / Technicians
    - Effect: speed up manufacturing, facility repairs, and autopsy/engineering tasks. Engineers reduce build and manufacture time.
    - Salary: moderate monthly cost.
  - Pilots
    - Effect: determine interceptor effectiveness (higher pilot_skill increases chance-to-hit and reduces losses in air combat).
    - Salary: per pilot, required for interceptors.
  - Soldiers (Operatives)
    - Effect: combat roster. Soldier ranks influence battlefield performance.
  - Admin / Security
    - Effect: stabilizes base reliability, lowers chance of facility sabotage/containment breaches (rare events).

- Power, maintenance and economy rules (implementation notes):
  - Power accounting: every facility defines a power_draw (integer). Generators provide discrete power units. If demand > supply:
    - Apply progressive penalties: reduced research/manufacture speed, radar coverage drops, intermittent failures.
  - Maintenance & salaries: monthly tick subtracts facility upkeep and salaries from funding. A funding shortfall causes automation: non-essential facilities disable or staff furloughed.
  - Facility construction: costs credits + build_time (ticks/days) + engineer_work. Engineers assigned accelerate build.

- Base layout and tile rules (practical constraints inspired by classic X-COM):
  - Rooms occupy contiguous tiles in orthogonal rectangles; corridors connect rooms via door tiles.
  - Some facilities require minimum room sizes (e.g., Autopsy needs a 3x3). Hangars require direct exterior access.
  - Adjacency bonuses: placing workshops near storage reduces inventory travel time (implementation optional).
  - Security: containment should be isolated; place security doors and corridors to limit breaches.

- Strategic integration and automation:
  - Multiple bases: maintain an array of bases with varying specialties (research hub, air defence, forward operations). Moving manufacturing or research between bases should be allowed by queue transfer.
  - Radar coverage map: each base's radar defines a detection footprint; overlapping coverage improves track quality.

- Example facility rows (data-driven contracts you can import into the engine):
  - id, name, footprint_tiles, build_time_days, power_draw, staff_required, base_cost
  - fac_living, "Living Quarters", 6, 7, 2, {soldiers:8, staff:2}, 12000
  - fac_lab, "Laboratory", 9, 14, 4, {scientists:6}, 24000
  - fac_workshop, "Workshop", 8, 10, 3, {engineers:4}, 18000
  - fac_radar, "Radar Dome", 4, 5, 3, {technicians:2}, 10000
  - fac_hangar, "Hangar", 12, 12, 6, {pilots:2, groundcrew:2}, 30000
  - fac_containment, "Alien Containment", 6, 8, 3, {security:2, scientists:1}, 20000
  - fac_power, "Generator", 4, 6, -20 (supply), {engineers:1}, 15000

- Best-practice design notes (derived from classic play and Ufopaedia ideas):
  - Start small: prioritize Radar + Living Quarters + Lab early. Expand Workshop once basic alloy/weapon blueprints are unlocked.
  - Separate containment and autopsy: prevents an autopsy breach from exposing your entire base.
  - Locate hangars with clear exterior access and room for interceptor service; keep power plants centrally placed to reduce cable routing complexity (implementation-specific).

- QA & telemetry to track for balancing:
  - Average base power utilization, average facility idle time, manufacturing queue completion time, research throughput (scientist-days/week), monthly running cost vs funding.


3) Research & Tech Tree
- Research items: weapons, armors, vehicle tech, alien biology, psionics, alien alloys.
- Research project data shape:
  - id, name, prerequisites (list of ids), research_cost (scientist-days or abstract points), required_samples (alien corpse/object), dependencies, outputs (blueprint ids), time_modifier based on scientist_skill.
- Unlock path approximates original X-COM: basic ballistics -> alloys -> beam weapons -> plasma -> advanced materials -> psionics.

4) Manufacturing & Inventory
- Production items include weapons, ammunition, armor, grenades, vehicles, and special equipment.
- Manufacturing queue entries: item_id, quantity, start_tick, completion_tick, resources_consumed.
- Salvage from missions yields alien materials and artifacts used as resources to manufacture advanced items.

5) Strategic Combat (Air interception)
- Interceptors and UFOs: speed, acceleration, maneuverability, missile load, ammo, pilot_skill.
- Combat can be resolved via a simplified simulation: missile volley exchange with hit probability influenced by speed, altitude, ECM, and pilot skill. Outcome: UFO escapes, is damaged, or crashes.

6) Battlescape (Tactical Layer) — Core mechanics
- Map representation: grid-based (square tiles), each tile contains terrain metadata: cover, elevation, passable, destruction_level, LOS_block.
- Unit data shape (shared by soldiers and aliens): id, type, HP, morale, agility, strength, stamina, reactions, accuracy, loot_table, inventory (fixed size), facing, current_position, AP (action points), status_effects (stunned, poisoned, panicked, unconscious).
- Turn economy: each unit has two-phase action: Reaction Phase (opportunity shots) and Player/AI Turn Phase. Movement and actions consume AP. AP is refreshed at start of unit's turn. Reactions use separate reaction points.
- Action points and actions (classic X-COM style):
  - Walk/Run costs AP based on tile and carried weight.
  - Aimed Fire vs Snap Fire vs Auto Fire: each consumes different AP amounts and has differing accuracy and recoil rules.
  - Crouch, Prone, Quick-Stab, Throw Grenade, Use Item, Reload.
  - Grenade throws use range tables and chance-to-hit area-of-effect.
  - Melee attacks (close-stab) have deterministic hit and critical rules.
- Line of Sight (LOS) & Fog of War: LOS determined by tile geometry and elevation. Vision range reduced at night; lights and flares change visibility.
- Cover / Armor: cover reduces chance-to-hit; armor reduces damage per hit. Armor has an armor rating and per-hit damage mitigation.
- Damage model: weapons have damage dice or fixed damage. Hit location model optional (head/torso/limbs) to allow criticals — the 1994 game used body-part criticals.

7) Aim and Accuracy
- Hit chance formula (data-driven, deterministic):
  - BaseChance = AttackerAccuracy + (WeaponAimBonus) - TargetCoverPenalty - DistancePenalty - MovementPenalty - Stress/Morale modifiers.
  - Reactions use reduced aim bonuses and a fraction of AP.

8) AI Behavior
- AI is driven by weighted goals and simple tactical routines:
  - Primary objectives: protect high-value targets, retrieve artifacts, flank player units, retreat if suppressed.
  - Movement uses heuristics: advance toward LOS to player, seek cover, use flanking where available.
  - Special behaviors: some aliens use ranged plasma with suppression; others prefer melee and will charge when in line.

9) Soldier Roster & Progression
- Soldiers have: name, rank, stats (strength, accuracy, reaction, health, stamina), fatigue, experience.
- Promotion: XP thresholds raise rank, granting small stat increases and access to higher-tier equipment.
- Injuries and recovery: wounds cause time-off or permanent stat loss; psionic/chemical statuses handled separately.

10) Equipment & Items (canonical list with data shape)
- Weapons: id, name, type (ballistic/energy/plasma), ammo_type, magazine_size, damage, accuracy_bonus, multiple_fire_modes, weight, AP_costs (snap, aimed, auto), recoil, penetration.
- Armor: id, name, armor_points_by_location, movement_penalty, weight.
- Gadgets: medkits (HP restoration), stun grenades, smoke grenades, motion scanners, proximity mines.
- Alien artifacts: produce blueprints or temporary battlefield benefits.

11) Alien Design
- Alien types cataloged by threat level. Each entry: id, name, HP, behavior_profile (ranged/melee/stealth/psionic), loot_table, size_class, armor, movement.
- Sample tiers (examples): Floaters, Outsiders, Sector Commanders, Leaders, Abductors, Sectoids, Mutons, Cyberdiscs, Ethereals.

12) Mission Types and Objectives
- UFO Crash/Land: primary objective is neutralize aliens, optional: capture live.
- Abduction: timed objective to rescue civilians before aliens pickup.
- Terror: kill/damage civilians to increase panic; player must reduce casualties.
- Assault on Base/Hidden Ops: special unique objectives with multiple waves.

13) Save & Data
- Save file holds: world seed, Geoscape tick, base layouts, staff roster, inventory counts, research states, manufacturing queues, soldier stats, active mission list, random generator state for reproducibility.

14) UI / UX Considerations
- Geoscape:
  - World map with overlays (panic, funding, radar range).
  - Facility UI shows build progress, power usage, and staff assignments.
  - Briefing dialogs for missions with estimated difficulty, known alien types, and rules-of-engagement.
- Battlescape:
  - Action panel: current unit AP, inventory slots with quick-select, weapon fire mode toggles, stance (stand/crouch/prone).
  - Top-right: turn-phase indicator, remaining enemies count, mission timer (if applicable).
  - Context-sensitive hover tooltips showing precise AP costs and hit probabilities (deterministic values) to support tactical planning.

15) Audio & Visual (1994-styled constraints)
- Low-poly sprites/2D isometric tiles or simple 3D with sprite-based aliens. Palette-limited art to match aesthetic.
- Sound: short MIDI music loops for Geoscape; short synthesized effects for weapon fire, alien calls, and UI clicks.

16) Balancing & Metrics
- Key balance targets:
  - Mission length: average 12–30 turns to complete standard battlescape missions.
  - Soldier survival: avoid too-high attrition early-game; early missions should have moderate risk.
  - Research pacing: first-tier tech should be reachable in 2–4 mid-length missions.
- Tuning knobs (data-driven): alien spawn rate, alien HP per tier, weapon damage and AP costs, research costs, manufacturing time.

17) Edge cases & Design notes
- Fog of War exploits: prevent infinite camping by adding limited ammo and dynamic mission timers for certain mission types.
- Save scumming: deterministic RNG seeded by save to allow reproduction but warn QA about save-reload exploits.

18) QA & Testing Plan
- Unit tests for deterministic subsystems: hit chance formula, AP accounting, LOS blocking, reaction shot resolution.
- Automated integration tests for: Geoscape event scheduling, research completion with partial prerequisites, and manufacturing queue handling.
- Playtests: scripted scenarios for early-, mid-, and late-game states. Track KPIs: average mission turns, soldier mortality rate, player funding over time.

19) Data-driven tables (appendix)
- Weapon example row (CSV-like):
  - id, name, type, ammo, mag_size, damage, accurate_mod, snap_AP, aimed_AP, auto_AP, weight
  - wpn_1, "Laser Rifle", energy, lr_cells, 20, 8, +10, 25, 50, 60, 8

- Alien example row:
  - id, name, tier, hp, armor, behavior, loot
  - al_01, "Sectoid", 1, 5, 0, ranged/cover, corpse_small

Appendix: Minimal data contracts

- Unit JSON schema (simplified):
  - { id: string, type: string, hp: int, max_hp: int, accuracy: int, reaction: int, movement: int, inventory: [{item_id, qty}], position: {x,y,z}, ap: int, status: [] }

- Research project schema:
  - { id: string, name: string, cost: int, prerequisites: [string], required_samples: [string], time_estimate_ticks: int }

Next steps (suggested implementation priorities)
1. Implement deterministic core rules: AP accounting, hit chance formula, LOS engine, and save RNG seed.
2. Create data tables for weapons, aliens, and research; write a small harness to run deterministic battles between scripted squads to validate balancing.
3. Implement Geoscape event scheduler and a simple interception simulation.

Closing summary

This GDD captures the essential systems and data shapes needed to build an experience faithful to MicroProse's 1994 X-COM. It favors deterministic, data-driven rules for easy tuning and reproducible QA. If you want, I can now:
- generate CSV starter tables for weapons/aliens/research,
- synthesize example JSON schemas and unit tests for hit calculation, or
- expand the Battlescape section into explicit AP tables and weapon stat lists.

---
End of document.

# Ufopaedia-derived examples and canonical values

I used canonical references (Ufopaedia) for Time Units (TUs), weapon percentage costs, and sample alien/weapon stats. Below are concrete examples you can drop into data tables.

1) Time Units — selected fixed and percentage costs (canonical behavior)
- Turning 45 degrees: 1 TU (fixed)
- Kneel/Crouch: 4 TU (fixed); Stand from kneel: 8 TU
- Reload weapon: 15 TU (fixed)
- Use medikit charge: 10 TU (fixed)
- Throwing an item/grenade: 25% of Max TUs (percentage)
- Firing a weapon: weapon-specific percentage of Max TUs (examples below)

2) Weapon example rows (data-driven; percentage TU cost uses weapon firing mode)
- Note: percentage TU costs are of the soldier's Max TU (not current TU). Values approximate original X-COM and Ufopaedia references.

- id, name, type, ammo, mag_size, damage, aimed_TU_pct, snap_TU_pct, auto_TU_pct, weight
- laser_rifle, "Laser Rifle", energy, lr_cells, 20, 8, 34, 18, 34, 8
- heavy_plasma, "Heavy Plasma", plasma, hp_rounds, 20, 14, 60, 35, 65, 20
- gauss_rifle, "Gauss Rifle", ballistic, 5.56, 25, 10, 34, 18, 34, 10

3) Common alien example rows (approximate canonical stats)
- id, name, tier, HP, armor, movement, behavior, loot
- sectoid, "Sectoid", 1, 5, 0, 18, ranged/stealth, corpse_small
- floater, "Floater", 2, 8, 0, 30, ranged/assault, corpse_medium
- muton, "Muton", 4, 22, 3, 24, assault/melee, corpse_large

4) Sample TU calculation scenarios
- Soldier A: Max TU = 60. Laser Rifle aimed fire (34%) costs 0.34 * 60 = 20.4 -> integer TU cost = 20 (round down). Snap fire (18%) = 10.8 -> 10 TU.
- Soldier B: Max TU = 50. Heavy Plasma auto (65%) costs 32.5 -> 32 TU (integer truncated). This means low-TU soldiers can often perform fewer shots per turn on percentage-cost weapons.

5) Example mission walk-through (short)
- Situation: UFO crash-site, night mission. Player deploys 6-soldier squad (two rookies TU50, two regulars TU60, two veterans TU72).
- Turn 1 (Deployment): Soldiers exit landing vehicle — each uses 4–8 TU to orient and crouch. A veteran with TU72 can move 6 tiles (4 TU per tile average) and still aim once (34% TU) for overwatch; rookies will manage fewer tiles and likely set up a defensive line.
- Reaction fire: enemy floater moves into LOS; reaction shot costs are calculated from attacker's reaction skill and TU (deterministic). A veteran with high reaction will often get the reaction and potentially kill the floater before it fires.
- Turn 3–6: Player uses aimed shots (higher TU cost but higher accuracy) and grenades (25% TU to prime/throw). Recover corpses for research/manufacture.

References: core mechanics and TU tables referenced from Ufopaedia pages (Time Units, Weapons, and Aliens) for canonical 1994 X-COM values and percentages.
