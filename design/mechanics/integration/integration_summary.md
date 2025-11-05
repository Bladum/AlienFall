# Integration System Summary

## Purpose & Role

- Ensures Geoscape, Interception, Battlescape, and Basescape exchange state cleanly without circular dependencies.
- Maintains vertical campaign loop: strategy → interception → tactical → operations → back to strategy.
- Provides explicit integration contracts so each layer remains testable in isolation.

## Core Integration Points

- **Geoscape → Interception**: Passes mission context (UFO profile, location, timing) and receives aerial outcome modifiers.
- **Interception → Battlescape**: Supplies ground mission seeds with damage modifiers and optional difficulty shifts.
- **Battlescape → Basescape**: Returns casualties, salvage manifests, XP, and fame deltas for processing.
- **Basescape → Geoscape**: Feeds roster readiness, manufacturing unlocks, research status, and economy updates.
- **Event Bus**: Mission lifecycle emits `mission_created`, `mission_intercepted`, `mission_complete` events for observers (funding, diplomacy, analytics).

## Data Flow Highlights

- Mission lifecycle covers five phases (generation, interception, tactical combat, salvage processing, strategic impact) with explicit payload schemas.
- State passing uses immutable mission records; downstream systems clone or transform but never mutate upstream structures.
- Key payloads: mission context (type, biome, objectives, enemy tiers), mission results (success flag, losses, rewards), organization capabilities (craft readiness, research unlocks).

## Architectural Patterns

- **State Passing** dominates cross-layer communication, keeping coupling low and transitions testable.
- **Event Publishing/Listeners** propagate mission outcomes to funding, politics, and analytics without hard dependencies.
- **Query Interfaces** expose read-only views (e.g., Basescape equipment queries) to consumers across layers.
- No circular dependencies; vertical flow remains acyclic.

## Coupling & Boundaries

- Horizontal coupling within layers stays medium/tight (e.g., facility adjacency) but cross-layer coupling is intentionally one-way.
- Basescape acts as integration hub, converting tactical output into strategic readiness.
- AI stack consumes world state from each layer but never writes into foreign systems directly.

## Performance & Risk Notes

- Bottlenecks arise during mission generation (procedural seeding), salvage processing (bulk inventory updates), and large mission payload serialization.
- Error propagation must surface invalid payloads early; schema validation happens at state transfer boundaries.
- Save/load integrity depends on consistent serialization of mission context and results—tests cover inter-layer handoffs.

## QA & Testing Priorities

- Contract tests for mission payloads, ensuring every phase accepts/produces valid schemas.
- Regression tests simulating mission lifecycle permutations (success, failure, partial interception).
- Stress scenarios validating batch salvage processing, high-mission concurrency, and escalation ladder feedback loops.
- Analytics smoke tests ensuring event bus emits correct telemetry for mission phases.
