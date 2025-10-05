# AI Systems

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Strategic Director Framework](#strategic-director-framework)
  - [Interception Controllers](#interception-controllers)
  - [Battlescape Utility AI](#battlescape-utility-ai)
  - [Deterministic Processing System](#deterministic-processing-system)
  - [Data-Driven Configuration](#data-driven-configuration)
  - [Grid Integration Standards](#grid-integration-standards)
  - [Implementation Hooks](#implementation-hooks)
- [Examples](#examples)
  - [Strategic Director Operations](#strategic-director-operations)
  - [Interception Decision-Making](#interception-decision-making)
  - [Battlescape Action Evaluation](#battlescape-action-evaluation)
  - [Personality System Applications](#personality-system-applications)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

AlienFall implements deterministic artificial intelligence across every layer of gameplay, from strategic campaign orchestration to tactical unit control during ground combat. This comprehensive AI framework creates intelligent opposition that operates within published game rules while providing challenging, learnable behavior patterns through transparent decision-making processes. The system emphasizes fairness, reproducibility, and moddability by utilizing seeded randomization, data-driven configuration, and explainable scoring heuristics.

The AI architecture supports the strategic Alien Director managing global campaigns, interception controllers handling air combat maneuvers, and battlescape utility systems governing tactical unit actions. All AI components share deterministic processing principles enabling identical replay behavior for quality assurance, competitive challenges, and mod testing. Designers control AI tone and escalation through TOML data files rather than code modifications, providing extensive customization without engine changes.

## Mechanics

### Strategic Director Framework
The Alien Director orchestrates global campaign pressure through hierarchical decision-making:
- Monthly Cadence: Major campaign template selection and resource redistribution across theaters
- Weekly Cadence: Operational adjustments and mission scheduling refinements based on player actions
- Daily Cadence: Mission deployment timing and immediate response to strategic developments
- Objective Scoring: Weighted evaluation of funding impact, regional panic levels, and research race progression
- Template System: Weighted scenario deck sampling keyed to tags like urban, naval, or covert operations
- Deterministic RNG: Dedicated scope `director:<campaignSeed>` ensures reproducible template selection

### Interception Controllers
Air combat AI manages craft maneuvers and weapon systems within tactical constraints:
- Maneuver Evaluation: Independent assessment of advance, hold, and evasive positioning options
- Weapon Selection: Optimal firing solutions constrained by shared energy and action point pools
- Tactical Objectives: Three-round mission success planning with retreat thresholds
- Strategic Preservation: Fleet loss prevention through conservative engagement disengagement
- Deterministic Processing: RNG namespace `interception:<missionId>` for reproducible combat outcomes

### Battlescape Utility AI
Tactical unit control through weighted multi-factor action evaluation:
- Action Scoring: Weighted factors including survival assessment, objective pressure, ally support, and threat elimination
- Personality Profiles: Configurable behavior patterns (aggressive, cautious, psionic, terror) adjusting scoring weights
- Fog-of-War Handling: Last-seen information caching and squad coordination through shared blackboard state
- Data-Driven Weights: All scoring factors and personality adjustments defined in TOML configuration files
- Real-Time Processing: Efficient algorithms enabling responsive decision-making during player turn execution

### Deterministic Processing System
All AI decisions incorporate seeded randomization for reproducible outcomes:
- Seed Management: Campaign-scoped random number generation ensuring identical behavior across sessions
- Provenance Logging: Complete decision history recording for replay validation and debugging
- Telemetry Integration: AI choice tracking with seed context, option scores, and selected actions
- State Consistency: Deterministic state updates preventing divergence during replays

### Data-Driven Configuration
AI behavior controlled through external data files enabling extensive customization:
- Configuration Location: TOML files under `data/ai/*.toml` defining weights and behavior toggles
- Tag Integration: AI parameters reference standard wiki tags for consistent cross-system behavior
- Mod Support: Complete AI customization through mod data file overrides without code changes
- Balance Iteration: Designer-accessible tuning enabling rapid balance adjustments

### Grid Integration Standards
AI systems respect unified coordinate and rendering standards:
- Battlescape Grid: 20×20 logical tile system with 10×10 pixel sprites scaled 2× for rendering
- Line-of-Sight Sampling: Tile centroid alignment ensuring consistent visibility calculations
- Interception Grid: 3×3 slot positioning mapped to Love2D coordinate system through UI manager
- Movement Pathfinding: Grid-aligned navigation respecting terrain and obstacle constraints

### Implementation Hooks
AI integration with Love2D game loop and event systems:
- Update Registration: `aiDirector:update(dt)` and `battleAI:update(dt)` within game state manager
- State-Specific Activation: Tactical AI only processes during active battlescape state
- Event Subscriptions: Director listens to `geoscape:mission_completed`, `battlescape:unit_destroyed`, `finance:funding_adjusted`
- Telemetry Output: Required logging fields defined in `technical/README.md` for replay analysis

## Examples

### Strategic Director Operations
Monthly evaluation detects player has strong North American radar coverage but weak Asian presence. Director samples base-building campaign template for undetected foothold establishment in Asia while reducing mission intensity in well-covered regions. Economic analysis identifies USA as primary funding source, triggering terror campaign selection to reduce public score and funding flows. Template includes wave scheduling with 2-week intervals and progressive escalation mechanics.

### Interception Decision-Making
Alien craft evaluates three maneuver options against player interceptor: advance to weapon range (70% hit chance but 50% damage risk), hold position (35% hit chance, 20% risk), or evasive retreat (10% hit chance, minimal risk). AI calculates expected value considering mission success probability and strategic fleet preservation thresholds, selecting advance maneuver due to favorable damage trade-off and mission priority.

### Battlescape Action Evaluation
Muton soldier evaluates four actions: flank exposed player unit (85 damage potential, 40% self-risk), take cover (0 damage, 10% risk), use intimidation ability (area control effect, 15% risk), or suppressive fire on enemy position (25 damage, 30% risk). Aggressive personality weights offensive actions highly, resulting in flank selection despite elevated personal risk due to high damage potential and positioning advantage.

### Personality System Applications
Cautious Chryssalid personality prioritizes ambush positioning over direct engagement, waiting in cover for isolated targets rather than attacking grouped units. When wounded below 50% health, personality triggers retreat behavior to safe terrain while maintaining threat to nearby units. Contrast with aggressive personality pursuing wounded targets despite counter-fire risks for guaranteed elimination.

## Related Wiki Pages

- [Alien Strategy.md](Alien%20Strategy.md) - Strategic campaign orchestration and invasion planning
- [Geoscape AI.md](Geoscape%20AI.md) - Director authority hierarchy and adaptive management
- [Battlescape AI.md](Battlescape%20AI.md) - Tactical combat AI and utility scoring
- [Faction_Behavior.md](Faction_Behavior.md) - Faction-specific behavior patterns and coordination
- [Geoscape.md](../geoscape/README.md) - Strategic layer integration and world management
- [Interception.md](../interception/README.md) - Air combat mechanics and controller integration
- [Battlescape.md](../battlescape/README.md) - Tactical combat systems and AI coordination
- [Technical.md](../technical/README.md) - Infrastructure and processing architecture
- [Modding.md](../technical/Modding.md) - AI customization and data file structure

## References to Existing Games and Mechanics

- **XCOM Series**: Alien Director AI and strategic pressure systems
- **Civilization Series**: AI opponent strategic decision-making and personality systems
- **Total War Series**: Campaign AI and tactical battle coordination
- **StarCraft**: Unit micro-management AI and tactical positioning
- **Command & Conquer**: Base management AI and resource allocation
- **Europa Universalis IV**: Nation AI and diplomatic strategies
- **Stellaris**: Empire AI and fleet management systems
- **Homeworld**: Fleet AI and formation coordination
- **Phoenix Point**: Faction AI and adaptive enemy behavior
