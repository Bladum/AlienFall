# Geoscape AI

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Director Authority Hierarchy](#director-authority-hierarchy)
  - [Strategic Priority Evaluation](#strategic-priority-evaluation)
  - [Decision Cadence and Timing](#decision-cadence-and-timing)
  - [Adaptive Campaign Management](#adaptive-campaign-management)
  - [Deterministic Processing and Moddability](#deterministic-processing-and-moddability)
- [Examples](#examples)
  - [Authority Escalation Response](#authority-escalation-response)
  - [Strategic Priority Adaptation](#strategic-priority-adaptation)
  - [Campaign Template Selection](#campaign-template-selection)
  - [Adaptive Behavior Patterns](#adaptive-behavior-patterns)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Geoscape AI, embodied in the Alien Director system, serves as the strategic mastermind orchestrating global campaign pressure against the player. This deterministic AI framework manages long-term alien objectives through hierarchical decision-making, adaptive resource allocation, and responsive campaign management. The Director creates emergent strategic challenges by exploiting player weaknesses, managing campaign pacing, and maintaining appropriate difficulty scaling across the world map.

The system emphasizes fairness and transparency, operating within the same game rules as the player while leveraging superior planning horizons and pooled resources. All decisions follow explainable heuristics with seeded randomization ensuring reproducible outcomes for testing, balancing, and modding. The Director acts as a pacing tool, creating dynamic strategic pressure that adapts to player performance without resorting to opaque mechanics or unfair advantages.

## Mechanics

### Director Authority Hierarchy
The AI operates through a structured authority system with escalating decision-making power:
- Tactical Authority: Immediate crisis response, emergency mission deployment, and direct threat neutralization
- Operational Authority: Theater-specific resource allocation, mission wave scheduling, and regional focus management
- Strategic Authority: Long-term campaign planning, template selection, and global resource distribution

Authority levels escalate based on campaign legitimacy, with higher authority enabling more aggressive or comprehensive responses to player actions.

### Strategic Priority Evaluation
The Director continuously assesses player state through multiple observable factors:
- Economic Pressure: Funding levels, income sources, and financial stability analysis
- Military Strength: Interceptor count, base defenses, and technological capabilities
- Geographic Coverage: Radar network extent and detection gaps
- Research Progress: Technological advancement and counter-strategy requirements
- Recent Performance: Tactical outcomes and strategic momentum indicators

These factors generate weighted priority scores that influence campaign selection and resource allocation.

### Decision Cadence and Timing
Strategic decisions occur at multiple time scales for responsive yet predictable behavior:
- Monthly Cadence: Major campaign template selection, resource redistribution, and strategic reassessment
- Weekly Cadence: Operational adjustments, mission scheduling refinements, and theater focus shifts
- Daily Cadence: Mission deployment timing and immediate response to player developments
- Immediate Cadence: Crisis interventions, emergency deployments, and priority overrides

### Adaptive Campaign Management
The Director employs template-based campaign generation with dynamic adaptation:
- Campaign Templates: Reusable strategic patterns for invasion, harassment, technology focus, or economic pressure
- Wave Scheduling: Coordinated mission deployment with configurable intensity and timing
- Resource Allocation: Budget distribution across research, production, and operational needs
- Target Selection: Province and region prioritization based on strategic value and vulnerability

### Deterministic Processing and Moddability
All AI behavior incorporates seeded randomization for reproducible strategic outcomes:
- Seeded Sampling: Campaign template selection and mission scheduling use deterministic random streams
- Telemetry Logging: Decision provenance recording for debugging, balancing, and replay analysis
- Data-Driven Configuration: Priority weights, escalation thresholds, and behavior parameters exposed as moddable data
- Performance Optimization: Efficient processing ensuring real-time strategic decision-making

## Examples

### Authority Escalation Response
When player forces destroy a key alien base, the Director's legitimacy drops below 30%, triggering tactical authority activation. This results in immediate emergency mission waves, increased resource allocation to threatened regions, and accelerated deployment of advanced units to stabilize the situation.

### Strategic Priority Adaptation
Detecting extensive radar coverage over North America but gaps in Asian surveillance, the Director shifts priorities: reducing mission intensity in well-covered regions while sampling base-building campaigns for undetected foothold establishment in Asia. Economic analysis reveals the USA as the primary funding source, prompting terror campaign selection to reduce public score and funding flows.

### Campaign Template Selection
Following player laser weapon research breakthrough, the Director samples a "retaliation" campaign template, deploying heavier armored UFOs and prioritizing missions that neutralize the new technological advantage. The template includes inter-wave delays and escalation mechanics that gradually increase threat levels as the player adapts.

### Adaptive Behavior Patterns
An aggressive player expanding rapidly across multiple continents triggers increased mission frequency and higher-difficulty unit deployment. The Director concentrates resources in key theaters, using harassment campaigns to drain player funding while establishing covert bases in undefended regions. Success metrics track campaign effectiveness, with automatic adjustment if pressure proves insufficient.

## Related Wiki Pages

- [Geoscape.md](../geoscape/Geoscape.md) - Strategic layer and world management
- [AI.md](../ai/AI.md) - General AI systems and frameworks
- [Interception.md](../interception/Interception.md) - Combat interception mechanics
- [Economy.md](../economy/Economy.md) - Resource allocation and management
- [Finance.md](../finance/Finance.md) - Economic pressure and costs
- [Mission objectives.md](../battlescape/Mission%20objectives.md) - Mission generation and objectives
- [Technical.md](../technical/Technical.md) - Infrastructure and processing systems
- [Modding.md](../technical/Modding.md) - AI customization and modding
- [SaveSystem.md](../technical/SaveSystem.md) - State persistence and tracking
- [Research tree.md](../economy/Research%20tree.md) - Technology progression and unlocks

## References to Existing Games and Mechanics

- **X-COM Series**: Alien Director AI and strategic pressure
- **Civilization Series**: AI opponent strategic decision-making
- **Total War Series**: Campaign AI and faction management
- **Crusader Kings III**: Dynasty AI and long-term planning
- **Europa Universalis IV**: Nation AI and diplomatic strategies
- **Stellaris**: Empire AI and galactic management
- **Homeworld Series**: Fleet AI and tactical coordination
- **Commandos Series**: Mission AI and patrol patterns
- **XCOM 2**: Avatar project and adaptive AI
- **Phoenix Point**: Faction AI and resource competition

