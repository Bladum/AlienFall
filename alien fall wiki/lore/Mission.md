# Mission

## Table of Contents
- [Overview](#overview)
  - [Key Design Principles](#key-design-principles)
- [Mechanics](#mechanics)
  - [Mission Spawn and Initial State](#mission-spawn-and-initial-state)
    - [UFO Missions](#ufo-missions)
    - [Site Missions](#site-missions)
    - [Base Missions](#base-missions)
  - [Mission Ownership and Location](#mission-ownership-and-location)
  - [Mission Cover, Detection and Determinism](#mission-cover,-detection-and-determinism)
  - [Mission Scripts and Lifecycle](#mission-scripts-and-lifecycle)
  - [Daily Processing Order](#daily-processing-order)
  - [Mission Failure, Expiration and Resolution](#mission-failure,-expiration-and-resolution)
  - [Story Progression, Player Influence and Campaign Ties](#story-progression,-player-influence-and-campaign-ties)
  - [Design, Data and Moddability](#design,-data-and-moddability)
  - [Provenance and Telemetry](#provenance-and-telemetry)
  - [UX Guidance](#ux-guidance)
- [Examples](#examples)
  - [Monthly Spawn Flow Example](#monthly-spawn-flow-example)
  - [Mission Lifecycle Examples](#mission-lifecycle-examples)
  - [Common Mission Statuses](#common-mission-statuses)
  - [Story Progression Examples](#story-progression-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Missions represent first-class geoscape objects that embody discrete encounters (UFOs, sites, bases) with scripted lifecycles, location tracking, and faction ownership. Missions are instantiated by campaign/wave systems and execute deterministic scripts controlling movement, detection, spawns, and outcomes. They expose detectability, timers, and salvage rewards while emitting provenance for designer reproducibility. Missions are authored as templates and scripts in data to tune pacing and ensure deterministic behavior.

The mission system serves as the core encounter engine, bridging campaign-level strategic decisions with tactical combat resolution. Missions provide the structured framework for player engagement across multiple timescales, from immediate interception decisions to long-term base assault campaigns.

### Key Design Principles

- Deterministic Execution: Seeded randomization ensuring reproducible mission outcomes
- Data-Driven Design: TOML configuration for extensive modding and tuning
- Provenance Tracking: Complete audit trails for debugging and analysis
- Scripted Lifecycles: Atomic primitives controlling complex mission behaviors
- Strategic Integration: Seamless connection between geoscape and battlescape systems

## Mechanics

### Mission Spawn and Initial State

Instantiation Parameters: Missions are created with unique identifiers, type classifications, faction ownership, geographic positioning, initial detection difficulty, controlling scripts, reward structures, provenance linking, and mission-specific parameters.

Type Categories: Missions encompass airborne patrols (UFOs), ground installations (sites), persistent fortifications (bases), crash remnants, and passive objectives with distinct behavioral patterns.

#### UFO Missions
Advanced mission type capable of movement between provinces with sophisticated behavioral patterns controlled by UFO scripts. UFOs can land on surfaces, dive underwater, or maintain flight, with interception outcomes determining whether they can be recovered during subsequent land assaults.

Key Characteristics:
- Inter-Provincial Movement: Can relocate between provinces within the same turn
- Multi-Environment Operation: Capable of surface landing, underwater diving, or sustained flight
- Scripted Behavior: UFO scripts dictate movement patterns and decision-making logic
- Post-Interception Recovery: Shot-down UFOs can be salvaged during land assault operations

#### Site Missions
Basic static mission type that remains fixed in a province, waiting for player engagement. Sites provide straightforward objectives that yield score rewards upon completion but offer minimal defensive capabilities for interception operations.

Key Characteristics:
- Static Positioning: No movement capability, fixed location throughout lifetime
- Player-Initiated Resolution: Requires active player interception to resolve
- Score Rewards: Successful completion provides points against affected regions/countries
- Minimal Defenses: Limited interception defensive capabilities

#### Base Missions
Advanced persistent mission type that endures indefinitely while spawning additional missions over time. Bases grow progressively more challenging and must be actively countered by players to prevent escalating strategic consequences.

Key Characteristics:
- Indefinite Duration: No natural expiration, persists until player intervention
- Mission Spawning: Generates additional missions over time as growth mechanism
- Progressive Difficulty: Increases in challenge level and defensive capabilities
- Strategic Imperative: Must be stopped to prevent major negative score impacts

Initial Configuration: Each mission receives starting cover values, lifetime constraints, salvage tables, score rewards, expiration penalties, detection modifiers, and spawn parameters upon creation.

Provenance Establishment: Missions record deterministic seeds, tick identifiers, template selections, province assignments, and parent campaign/wave relationships for complete audit trails.

### Mission Ownership and Location

Faction Affiliation: Every mission belongs to a specific faction, maintaining ownership consistency and enabling faction-specific behaviors.

Geographic Binding: Missions are anchored to provinces/regions, allowing regional mission coexistence while respecting ownership boundaries.

Mixed-Faction Scenarios: Coexisting missions from different factions require explicit designer authorization to prevent ownership conflicts.

Location Dynamics: Missions can relocate between provinces through scripted movement, updating geographic indexing and regional associations.

### Mission Cover, Detection and Determinism

Cover Mechanics: Missions begin with numeric cover values representing detection difficulty, reduced by player sensor contributions (radar networks, in-flight sensors) to determine visibility.

Detection Thresholds: Cover reduction below critical values triggers mission revelation, enabling interception and assault capabilities.

Deterministic Randomness: All detection rolls, target selections, and lifecycle decisions use seeded random number generation derived from world/campaign seeds with named streams for reproducibility.

Provenance Transparency: Detection events record seeds, tick identifiers, selected templates, resolved provinces, and sensor contributions for complete decision traceability.

### Mission Scripts and Lifecycle

Script Architecture: Missions execute ordered atomic primitives (MoveToProvince, PatrolAir, LandAndStay, SpawnMissionHere, BuildForwardBase) with deterministic branches and conditional logic.

Execution Model: Scripts advance through steps with immediate execution followed by delay periods, supporting zero-delay multi-step processing within single ticks.

Branching Logic: Scripts contain deterministic branches triggered by detection states, time elapsed, or probability rolls with named RNG streams.

Hook Integration: Scripts support lifecycle hooks (on_script_start, on_step_start, on_step_tick, on_step_complete, on_script_complete) for telemetry and scripted logic extension.

### Daily Processing Order

Deterministic Sequence: Daily processing follows fixed order - script advancement, detection updates, player reactions, and end-of-day resolution - preserving reaction windows.

Script Execution: Missions advance controlling scripts, executing movement, spawn timers, and state changes.

Detection Updates: Sensor contributions are aggregated and detection rolls performed, updating mission visibility states.

Player Agency Window: Detected missions allow interception assignments, assault scheduling, and transfer coordination.

Resolution Phase: Mission expirations, unresolved penalties, and score/funding effects apply after player actions to maintain strategic timing.

### Mission Failure, Expiration and Resolution

Expiration Consequences: Timed missions applying configured penalties (score losses, resource reductions, quest impacts) upon lifetime expiration.

UFO Resolution Paths: Interception outcomes determine forced landing (ground mission spawn), escape (script resumption with relocation), or crash (crash-site mission creation).

Base Persistence: Bases endure through multi-stage assault sequences, with level progression, spawn rates, and defensive capabilities governed by base scripts.

Outcome Branching: Mission resolution triggers appropriate reward distributions, penalty applications, and follow-up mission spawning based on completion type.

### Story Progression, Player Influence and Campaign Ties

Monthly Sampling: Calendar-driven campaign instantiation with seeded faction weights determining eligible templates and mission budgets.

Campaign Structure: Multi-wave generators spanning months with inter-wave delays and explicit timing controls for pacing management.

Player Impact: Research completion, quest fulfillment, and tactical outcomes modify faction states, spawn weights, and template availability.

Escalation Control: Faction resolution removes missions from spawn pools, with active campaigns pruned at sampling boundaries.

Safety Mechanisms: Monthly caps, faction limits, weight reductions, and template downgrades enforce pressure boundaries through data-driven constraints.

### Design, Data and Moddability

Data-Driven Configuration: All parameters (wave delays, lifetimes, spawn pools, detection values, salvage tables) authored in TOML for code-free tuning.

Template Pluggability: Mission templates, script primitives, and base profiles designed as versioned, replaceable components.

Designer Tooling: Seeded preview systems enabling full mission lifecycle reproduction from instance seeds.

Mod Integration: Comprehensive hooks for telemetry export, mission creation/modification tracking, and deterministic replay support.

### Provenance and Telemetry

Comprehensive Logging: Record seeds, tick identifiers, per-step decisions, spawned mission IDs, target provinces, inter-wave timings and remaining monthly budgets for debugging and balance tuning.

Failure Documentation: Surface failure and reason information (unpaid payroll, insufficient funds) in logs and UI for replayability and debugging.

Audit Trails: Complete provenance tracking enabling exact sequence reproduction for QA and designer analysis.

### UX Guidance

Strategic Planning: Surface "time-to-impact", current faction spawn weights, active campaigns, projected monthly mission budgets, detection contributors and time-to-expiry to help players plan and make informed decisions.

Detection Transparency: Clear UI about detection contributors, time-to-expiry, projected consequences and provenance metadata so players can reason about outcomes.

Mission Status Clarity: Distinct visual indicators for mission types (flying, landed, crashed, base, passive) with appropriate action prompts.

## Examples

### Monthly Spawn Flow Example
Month Boundary: Calendar triggers campaign pool sampling, selecting Campaign A (Faction X) with instantiated waves.

Wave Execution: Day 2 spawns Large UFO with escorts in Region Y, missions created with cover values, script instances, and provenance tracking.

Detection Phase: Days 2-5 advance scripts, sensor networks reveal fleet, player intercepts on Day 3 triggering dogfight resolution.

Resolution: Post-interception, scripted branches execute across months until campaign completion or faction resolution.

### Mission Lifecycle Examples
Site Expiration: Timed abduction site expires after lifetime, applying score/resource penalties to host country.

UFO Outcomes: Dogfight results force landing (timed ground mission spawn), escape (script relocation), or crash (salvage/captive crash-site creation).

Base Pressure: Level-2 base monthly script spawns defensive missions and supply raids, level influencing spawn weights and reward quality.

### Common Mission Statuses
Flying: Airborne movement with interception capability, dogfights occurring in this state.

Landed: Surface presence spawning timed ground tactical missions for assault operations.

Crashed: Destroyed aerial assets spawning crash-site missions with salvage and captive recovery.

Base: Persistent multi-stage fortifications requiring coordinated ground assaults for destruction.

Passive: Static objectives yielding score/salvage upon resolution with time-limited completion windows.

### Story Progression Examples
Research Unlock: Player completes anti-stealth research → on_research_complete reduces a faction's spawn weight next month and increases interception success probability.

Resolved Faction: Completing a final quest chain removes that faction from the monthly campaign pool; active Campaign templates tied to it are pruned at the next month boundary.

## Related Wiki Pages

- [Campaign.md](../lore/Campaign.md) - Mission campaign spawning and waves.
- [Faction.md](../lore/Faction.md) - Mission faction ownership and behavior.
- [Event.md](../lore/Event.md) - Mission event triggers and spawning.
- [Calendar.md](../lore/Calendar.md) - Mission timing and scheduling.
- [Geoscape.md](../geoscape/Geoscape.md) - Mission geoscape presence and detection.
- [Battlescape.md](../battlescape/Battlescape.md) - Mission combat resolution.
- [UFO Script.md](../lore/UFO%20Script.md) - UFO mission scripts and behaviors.
- [Enemy Base script.md](../lore/Enemy%20Base%20script.md) - Base mission scripts and assaults.

## References to Existing Games and Mechanics

- **XCOM Series**: Mission types and strategic objectives
- **Mass Effect Series**: Mission structure and quest design
- **Dragon Age Series**: Quest and mission progression systems
- **The Witcher Series**: Contract and quest mission systems
- **Fallout Series**: Quest variety and mission objectives
- **The Elder Scrolls Series**: Main quest and side mission structures
- **Deus Ex Series**: Mission-based gameplay and objectives
- **Metal Gear Solid Series**: Stealth mission objectives and infiltration
- **Tom Clancy's Series**: Tactical mission operations
- **Ghost Recon Series**: Tactical mission objectives and execution

