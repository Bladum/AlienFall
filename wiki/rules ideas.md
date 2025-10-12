## Weapons & Armor (phase-indexed reference)

Weapons (Phase 0 - Shadow War):

- Standard Ballistic: Common human firearms, effective against human factions and some supernatural entities.

- BlackOps Weaponry: Advanced, often silenced or specialized human-derived weapons.

- Supernatural Countermeasures: Specialized items for dealing with paranormal threats.
Title: AlienFall Systems GDD (Rules and Mechanics)

Summary
- This document is the single-source mechanics reference. It defines systems, data contracts, and processing steps with no story, examples, or setting-specific content. Pair with `lore.md` to reskin the game without changing rules.

Table of Contents
- 1. Top-level Contract
- 2. Design Ethos
- 3. Time and Pacing
- 4. Strategic Layer (Geoscape)
- 5. Facilities (Abstract Catalog)
- 6. Personnel and Roles
- 7. Materials and Research
- 8. Manufacturing and Logistics
- 9. Detection, Tracking, and Interception
- 10. Tactical Layer (Battlescape/Hydroscape/Dimensional)
- 11. Actions, Costs, and Initiative
- 12. Targeting, Accuracy, and Damage Pipeline
- 13. Morale, Panic, and Recovery
- 14. AI Behavior Contracts
- 15. Save/Load and Determinism Requirements

1. Top-level Contract
- Inputs: player strategic choices (construction, staffing, R&D, deployments), tactical choices (movement, targeting, item use), world events (object spawns), RNG seed.
- Outputs: mission outcomes, salvage/materials, research progress, funding/panic deltas, roster changes, phase progression.
- Success: outcomes are readable and skillful play reduces risk without removing tension.

2. Design Ethos
- Deterministic, data-driven subsystems for AP accounting, LOS, accuracy, and reaction fire. RNG adds tension, not opacity.
- Separation of concerns: rules are story-agnostic; all narrative data lives in `lore.md` or content packs.

3. Time and Pacing
- Strategic time: continuous, compressible; monthly funding and scheduled events; progress bars for construction, manufacturing, research.
- Tactical time: discrete turns with Action Points (AP) per unit; reaction phase resolves before active turns.
- Design rule: all turn order, AP, LOS, and rolls are reproducible with a seed.

4. Strategic Layer (Geoscape)
4.1 Nations and Funding
- Nation model: {panic: 0..100, funding_rate, region, modifiers}.
- Funding_rate = base_rate × (1 − panic_effect) × diplomatic_modifiers.
- Panic thresholds: 50 warning, 75 ultimatum, 100 funding withdrawal; propagation rules can apply regionally.

4.2 Bases and Facilities
- Facility exposes effects via typed modifiers: detection_radius, track_quality, research_slots, production_slots, containment_capacity, hangar_slots, power_output, power_draw.
- Power: if sum(draw) ≤ sum(output) ⇒ normal; else apply staged penalties: disable non‑essentials, then probabilistic outages on criticals if deficit persists.
- Layout constraints: adjacency and exterior tile requirements are declarative; adjacency may grant marginal throughput bonuses.

4.3 Staff and Assignment
- Roles provide additive and multiplicative modifiers to systems they influence.
- Hiring has delay and recurring cost; global pools cap availability.

4.4 Detection and Interception
- Detection chance is a function of distance, sensor level, and target signature.
- Track quality determines intel fidelity and improves interception resolution.
- Outcomes: escape, forced landing, crash; crash spawns a tactical mission instance.

5. Facilities (Abstract Catalog)
- Living Quarters: capacity modifiers for personnel.
- Laboratories: research_slots; optional adjacency_speed_bonus.
- Workshops: production_slots; optional adjacency_speed_bonus.
- Hangars: one craft per hangar; affects scramble times.
- Storage: capacity for items/materials.
- Power Generators: define power_output and reliability.
- Sensor Arrays: detection_radius and track_quality modifiers.
- Base Defenses: intercept strength during assaults.
- Containment: live_capture capacity and breach probability.
- Specialized Labs (late): unlock advanced research domains.

6. Personnel and Roles
- Roles: Soldiers, Scientists, Engineers, Investigators, Security, Specialists (setting-agnostic subtypes).
- Each role defines: base stats, assignment targets, and effects {research_speed, production_speed, detection_uptime, containment_stability, interceptor_effectiveness}.
- Training: roles can gain ranks; ranks provide deterministic bonuses.

7. Materials and Research
7.1 Materials
- Abstract material types are referenced by tags (e.g., alloy, exotic_power, dimensional). Concrete names belong to content packs.
- Materials gate manufacturing and research via resource costs.

7.2 Research
- Project contract: {id, prerequisites: [tech_ids, samples], cost, outputs: [blueprints, facilities, unit_upgrades], tags}.
- Throughput scales with scientists; diminishing returns beyond a threshold.
- Interrogations and autopsies are modeled as projects over captured entities or items.

8. Manufacturing and Logistics
- Workshops have production_slots; production_rate per slot × engineers × modifiers.
- Queues support parallelization limited by slots; partial progress persists across pauses.
- Maintenance and upkeep costs apply monthly.

9. Detection, Tracking, and Interception
- Detection probability P = clamp(SensorPower × Signature / Distance² × modifiers).
- Track quality Q ∈ [0,1] increases with persistent contact; Q gates intel and engagement options.
- Interception resolves via opposed rolls: interceptor_effectiveness vs. target_defense, modified by Q and loadouts.

10. Tactical Layer
10.1 Map and Tiles
- Tile schema: {walkable, movement_cost, cover_type, elevation, los_block: none/partial/full, destructible_hp, env_mods}.
- Cover mechanics: full cover blocks fire from many angles; transparent cover penalizes aim without blocking LOS fully.

10.2 Movement and Encumbrance
- AP_move = base_move_cost × tile_cost × encumbrance_factor.
- Encumbrance tiers (none/light/medium/heavy) are derived from carried_weight/strength and affect max AP and aim penalties.

11. Actions, Costs, and Initiative
- Actions are either fixed‑cost (AP = constant) or percentage‑cost (AP = ceil(pct × MaxAP)).
- Reaction fire triggers on movement into LOS based on reaction stat and reserved AP.
- Initiative order is determined by an initiative stat with deterministic tie‑breakers (unit id, then previous order).

12. Targeting, Accuracy, and Damage Pipeline
- Accuracy = base_weapon_accuracy × shooter_skill × stance_mods × movement_mods × cover_mods × env_mods × rng.
- Damage pipeline: roll_damage → apply_resistances (by damage_type) → apply_armor (penetration vs. armor value) → apply_status (bleed, stun, panic) → destructible interactions.
- Area effects resolve with falloff functions; friendly fire permitted unless explicitly disabled by content pack.

13. Morale, Panic, and Recovery
- Morale per unit changes with casualties, damage taken, leadership auras, and fear effects.
- Panic thresholds cause loss of control or penalties next turn; recovery tests occur each turn with modifiers.
- Post‑mission recovery: wounds map to downtime; mental stress maps to fatigue.

14. AI Behavior Contracts
- Behavior trees or utility scores must consume only observable state + seeded RNG.
- Threat assessment prioritizes proximity, vulnerability, objective pressure, and suppression status.
- Fog of war is respected; cheating via omniscience is prohibited.

15. Save/Load and Determinism Requirements
- All random decisions derive from a mission/strategic seed and context indices.
- Save files include seeds and counters; replays produce identical outcomes given identical inputs.
Firing modes, penalties and rates
- Weapon fire modes (snap/aim/auto): defined by AP cost, accuracy modifier, and recoil/multi-shot rules.
- Recoil and aim penalties accumulate per-shot; automatic fire applies aim penalty per pellet/shot.

Hit chance and modifiers (expanded)
- BaseHit = AttackerAccuracy + WeaponAccuracyBonus + AimStanceBonus
- Modifiers applied: -RangePenalty, -TargetMovementPenalty, -CoverPenalty, +HighGroundBonus, -DarknessPenalty, -SmokePenalty, -SuppressionPenalty, +/-WeaponSpecialModifiers.
- FinalHitChance clamped to [min,max] to avoid impossible extremes.

Damage resolution
- Resolve: if hit -> compute raw_damage -> subtract armor_by_location -> apply damage_type_specials (e.g., energy bypass vs armor) -> check for status effects and incapacitation.
- Critical hits: rare chance based on head/torso hit multiplier; criticals may cause instant incapacitation or bleeding.

Status effects and injuries
- Status categories: stunned, unconscious, bleeding (stacking severity), poisoned, panicked, suppressed, mind-controlled.
- Bleeding severity maps to HP loss per-turn and affects action ability.
- Injury severity tiers: Light (days recovery), Moderate (weeks), Severe (months), Critical (permanent loss/limb, possible death).

Reaction / Overwatch rules (expanded)
- Reaction eligibility: a reaction shot can be triggered if a unit has reserved reaction points, clear LOS, and the moving unit enters the reaction cone.
- Reaction accuracy = fraction_of_normal_accuracy * reaction_stat_modifier - movement_penalty.
- Multiple reactions resolved by reaction priority (higher reaction stat first) and limited by ammo/AP.

Suppression & suppression effects
- Suppression is a discrete resource applied to units under heavy fire; accumulating suppression reduces aim, raises chance of panic, and prevents full AP recovery.
- Suppression decay: per-turn reduction if not being fired upon.

Cover destruction & terrain interaction
- Destructible cover has HP; explosions and high-penetration weapons lower cover HP and may destroy cover, changing battlefield geometry mid-match.

Stealth, detection and concealment
- Concealment provides a detection threshold: detectors (motion scanners, sonar) provide a detection_score; if detection_score >= threshold, unit becomes revealed.
- Stealth bonuses depend on movement (stationary concealment > moving), darkness, and camouflage gear.

Environmental hazards
- Fire: spreads to adjacent flammable tiles, deals per-turn damage, reduces visibility, and suppresses units.
- Smoke: reduces hit chance, blocks grenade LOS, and can hide movement but gives concealment penalties for allies.
- Water pressure: damage or movement penalties in deep tiles if unit lacks appropriate gear.

Psionic systems (detailed)
- Psionic stats: PsiPower, PsiResistance, PsiEnergy (resource). Psi actions cost PsiEnergy and have a PSI_Skill check vs target PsiResistance.
- Psi effects: mind control (control for N turns, requires save each turn), panic aura (reduces bravery), psi-damage (bypasses certain armor types), psi-stun.
- Psi sickness: cumulative exposure causes temporary stat penalties and may require recovery if thresholds crossed.

AI behavior & heuristics (deep)
- AI goal weights: protect_value(target), retrieve_value(artifact), suppress_value(player_units), flank_value.
- Tactics: choose cover, maintain distance based on role (ranged prefer mid-range, melee close), use abilities according to cooldown and priority (e.g., psionics on highest-bravery target).
- Retreat logic: if casualties exceed threshold or command unit killed, AI may withdraw or call reinforcements.

Unit progression & perma-death rules
- XP allocation: based on enemy value, role actions (heals, revives, objectives), and mission outcome. Promotion thresholds yield rank increases and small stat increments and unlock perks.
- Permanent death: on death, unit removed from roster; salvaged gear may be lost; design recommends memorialization mechanics.

Healing, medical and recovery
- Medkits: immediate field stabilization removing bleeding or restoring HP; advanced surgery reduces recovery time but costs resources.
- Recovery times deterministic by injury severity; optional permanent stat penalties for critical injuries.

Vehicles, craft & special units
- Vehicles have crew slots; vehicle HP and subsystem damage (engines, weapons) determine vehicle behavior. Vehicle destruction may eject crew (with injuries).

Mission objectives and scoring
- Primary objectives mandatory; secondary objectives grant additional rewards and lore. Scoring based on losses, time, civilians saved, items recovered, and altered panic.

Spawn scaling & encounter composition
- Enemy composition scales with global phase and mission type; mixed compositions ensure threat diversity (frontline, support, special units).

---

## Combat economy & balance principles (expanded)

Risk vs reward
- Capture mechanics: capture attempts require special actions (stun, net, contain) and increase chance of mission complication, but grant unique research samples that unlock higher-tier tech.

Determinism vs variance
- Core subsystems deterministic; RNG applied post-hit to determine damage variance and critical rolls. Avoid large swings that invalidate tactical choices.

Scaling knobs and tuning
- Threat curve parameters: spawn_rate(t), unit_power(t), special_event_probability(t). Designers tune these curves as functions of global phase, player tech index, and panic.
- Resource economy knobs: manufacturing lead time, research cost multipliers, staff salary scaling, salvage drop rates.

Telemetry & KPIs
- Mandatory telemetry streams: mission_length_distribution, casualty_rate_by_phase, time_to_next_phase, funding_vs_spend, research_completion_histogram, base_power_utilization.

---

## Edge-case rules & failure modes (detailed)

Power shortfall escalation
- Tiered penalties: 1) reduce non-essential throughput. 2) scale research/manufacturing penalties per X% deficit. 3) degrade radar/sonar ranges and track quality. 4) random facility failures if unresolved.

Funding collapse rules
- Funding drain triggers: if a majority of nations hit 100% panic or key nations withdraw, progressive funding loss occurs. Designers should implement graceful degradation: auto-sell non-critical inventory, furlough non-essential staff, and lock certain features instead of instant failure where possible.

Determinism & save behaviour
- Use deterministic seeds for reproducible QA scenarios. Designers should document RNG domains (tactical hits, crits, spawn randomness) and ensure save/reload does not bypass unavoidable mission constraints.

---

## UI & player information rules (expanded)

Transparency rules
- Tactical: must display AP/TU costs, exact hit chance breakdown (show contributing modifiers), stance, current inventory, ammunition counts, reaction points and suppression level.
- Strategic: must show base power vs capacity, staff assignments with effects, radar/sonar/dimensional coverage overlays, monthly income/expenses, nation panic per-country.

Feedback & tutorialization
- Provide contextual tooltips explaining how a modifier affects outcome (e.g., "-20% hit from half-cover"). Use gradual introduction via tutorial missions.

---


## Testing & validation rules (expanded)

Unit test targets (design-level test cases)
- Hit formula sanity: given deterministic inputs, expected hit chance must match table for sample weapons/stances.
- AP accounting: sequence of actions should result in exact expected remaining AP across variations (move+aim+fire sequences).
- Reaction resolution: two units with X and Y reaction produce predictable ordering and resolution.

Integration test targets
- Research completion with dependent samples: test partial prerequisites and scientist assignment scaling.
- Manufacturing queue: test multiple concurrent items with engineer modifiers and resource consumption.
- Mission reproducibility: seed-based mission replays reproduce key outcomes (spawn locations, enemy composition, major hits)

Playtest scenarios
- Create canonical early/mid/late scenario snapshots to validate pacing: start budget, base composition, typical roster and tech levels; measure KPIs after X simulated months.

Quality gates
- New systems require passing unit/integration tests and KPIs within predefined tolerances. Failure to meet gates blocks release.


---


If you want, I can now:
- convert these mechanics into a compact checklist for designers (per-system acceptance criteria), or
- author a set of human-readable deterministic test cases (non-code) for QA to implement.

## Canonical examples (Ufopaedia-derived)

These concrete example values and sample data rows are canonical reference values used for early data tables and deterministic QA scenarios. They are derived from classic Ufopaedia/X-COM canonical values and are intentionally explicit so designers and engineers can import them into small test harnesses.

Time Units (selected canonical values)
- Turning 45 degrees: 1 TU (fixed)
- Kneel / Crouch: 4 TU (fixed)
- Stand from kneel: 8 TU (fixed)
- Reload weapon: 15 TU (fixed)
- Use medikit charge: 10 TU (fixed)
- Throwing an item / grenade: 25% of Max TUs (percentage)

Weapon example rows (data-driven sample; percentage TU costs are of the soldier's Max TU):
- id, name, type, ammo, mag_size, damage, aimed_TU_pct, snap_TU_pct, auto_TU_pct, weight
- laser_rifle, "Laser Rifle", energy, lr_cells, 20, 8, 34, 18, 34, 8
- heavy_plasma, "Heavy Plasma", plasma, hp_rounds, 20, 14, 60, 35, 65, 20
- gauss_rifle, "Gauss Rifle", ballistic, 5.56, 25, 10, 34, 18, 34, 10

Common alien example rows (sample table rows for early tuning):
- id, name, tier, HP, armor, movement, behavior, loot
- sectoid, "Sectoid", 1, 5, 0, 18, ranged/stealth, corpse_small
- floater, "Floater", 2, 8, 0, 30, ranged/assault, corpse_medium
- muton, "Muton", 4, 22, 3, 24, assault/melee, corpse_large

TU calculation scenarios (examples used in unit tests):
- Soldier A: Max TU = 60. Laser Rifle aimed fire (34%) costs 0.34 * 60 = 20.4 -> integer TU cost = 20 (round down).
- Soldier A: Snap fire (18%) = 10.8 -> 10 TU.
- Soldier B: Max TU = 50. Heavy Plasma auto (65%) costs 32.5 -> 32 TU (integer truncated).

Example mission walk-through (canonical early scenario)
- Situation: UFO crash-site, night mission. Player deploys 6-soldier squad (two rookies TU50, two regulars TU60, two veterans TU72).
- Turn 1 (Deployment): Soldiers exit landing vehicle — each uses 4–8 TU to orient and crouch. A veteran with TU72 can move 6 tiles (4 TU per tile average) and still aim once (34% TU) for overwatch; rookies will manage fewer tiles and likely set up a defensive line.
- Reaction fire: enemy floater moves into LOS; reaction shot costs are calculated from attacker's reaction skill and TU (deterministic). A veteran with high reaction will often get the reaction and potentially kill the floater before it fires.
- Turn 3–6: Player uses aimed shots (higher TU cost but higher accuracy) and grenades (25% TU to prime/throw). Recover corpses for research/manufacture.

