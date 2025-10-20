# AlienFall Architecture Decision Records (ADRs)

**Status**: Active | **Last Updated**: October 2025

This directory contains Architecture Decision Records (ADRs) documenting major design decisions and their rationale.

---

## What is an ADR?

An Architecture Decision Record is a document capturing:
- **What** decision was made
- **Why** it was chosen
- **When** the decision was made
- **Who** was involved
- **Consequences** of the decision

ADRs provide historical context for why the architecture is structured as it is.

---

## Index of ADRs

### Current ADRs

| ID | Title | Status | Date |
|----|----|--------|------|
| [ADR-001](#adr-001) | Hexagonal Grid Topology | Accepted | Oct 2025 |
| [ADR-002](#adr-002) | Turn-Based vs Real-Time | Accepted | Oct 2025 |
| [ADR-003](#adr-003) | Module Separation | Accepted | Oct 2025 |
| [ADR-004](#adr-004) | Data Persistence | Accepted | Oct 2025 |
| [ADR-005](#adr-005) | AI Hierarchical Decision-Making | Accepted | Oct 2025 |

---

## ADR-001

**Title**: Hexagonal Grid Topology

**Status**: Accepted

**Context**:
The game needed a grid topology for positioning units on both Geoscape and Battlescape.
Options considered: rectangular grid vs hexagonal grid.

**Decision**:
Use hexagonal grid topology for both Geoscape (global map) and Battlescape (tactical combat).

**Rationale**:
- Hexagonal grids provide 6 neighbors (more uniform than 4-8 rectangular neighbors)
- Diagonal movement is equal to orthogonal movement (more balanced)
- Better visual representation for movement ranges and line-of-sight
- Cleaner LOS calculations without diagonal ambiguity

**Consequences**:
- (+) More balanced tactical movement and ranges
- (+) Cleaner pathfinding algorithms
- (-) Slightly more complex coordinate systems
- (-) Non-standard grid (requires custom implementation vs built-in rectangular)

---

## ADR-002

**Title**: Turn-Based vs Real-Time

**Status**: Accepted

**Context**:
Core game loop required decision between turn-based and real-time gameplay.
X-COM (inspiration) uses turn-based tactical combat but real-time strategy layer.

**Decision**:
Implement purely turn-based gameplay (both Geoscape and Battlescape).
No real-time elements.

**Rationale**:
- Enables complex strategic decisions without time pressure
- Supports AI with same turn structure as players
- Easier playtesting and balance verification
- Aligns with X-COM inspiration
- Reduces implementation complexity (no simultaneous updates)

**Consequences**:
- (+) Complex strategy is possible without time pressure
- (+) Equal turn structure for all entities
- (+) Easier to implement and test
- (-) Less dynamic feel than real-time
- (-) Turn transitions can feel slow with many units

---

## ADR-003

**Title**: Module Separation

**Status**: Accepted

**Context**:
Large game required organization into subsystems.
Question: How to separate concerns while maintaining communication?

**Decision**:
Divide into domain-specific modules:
- **Geoscape**: Strategic global operations
- **Basescape**: Base management and logistics
- **Battlescape**: Tactical combat
- **Core**: Common systems (state, assets, events)

Each module is as self-contained as possible with well-defined interfaces.

**Rationale**:
- Clear separation of concerns aids maintainability
- Independent module development
- Easier to test subsystems
- Extensible for mods
- Matches game's conceptual layers

**Consequences**:
- (+) Clear module boundaries
- (+) Independent development
- (+) Easier testing
- (-) Requires careful interface design
- (-) Communication between modules needs coordination
- (-) Can't easily mix layers (no Battlescape inside Geoscape turn)

---

## ADR-004

**Title**: Data Persistence Architecture

**Status**: Accepted

**Context**:
Game needs to save/load game state.
Options: Serialized tables vs structured save format vs database.

**Decision**:
Use Lua table serialization for save format.
Save complete game state as nested Lua tables.

**Rationale**:
- Love2D has built-in Lua support
- Tables are natural Lua data structure
- No external dependencies
- Modders can easily inspect/modify save files
- Extensible for additions

**Consequences**:
- (+) Simple implementation in Lua
- (+) Transparent to modders
- (+) No external dependencies
- (-) File size can be large
- (-) Version migration needed for compatibility
- (-) Security concerns if untrusted mods edit saves

---

## ADR-005

**Title**: AI Hierarchical Decision-Making

**Status**: Accepted

**Context**:
Game needs AI for multiple levels: strategic (Geoscape), tactical (Battlescape), unit (combat).
Question: Single monolithic AI vs layered approach?

**Decision**:
Implement hierarchical AI with separate decision-makers per layer:
- **Strategic AI**: Plans faction operations (Geoscape)
- **Tactical AI**: Handles squad-level decisions
- **Unit AI**: Individual unit combat decisions

Each layer makes decisions with limited scope, reporting upward.

**Rationale**:
- Scalable to many units without overwhelming computation
- Understandable AI behavior (each layer has clear purpose)
- Easier to debug (each level independently)
- Tunable difficulty (adjust individual layers)
- Supports both player vs AI and AI vs AI

**Consequences**:
- (+) Scalable to many units
- (+) Understandable behavior
- (-) Requires careful coordination between layers
- (-) Risky decisions made locally might conflict strategically
- (-) More complex overall than single monolithic AI

---

## How to Create a New ADR

### ADR Template

```markdown
## ADR-XXX

**Title**: [Decision Title]

**Status**: [Proposed | Accepted | Deprecated | Superseded]

**Date**: [Date]

**Context**:
[Describe the problem that led to this decision]

**Decision**:
[State the decision clearly]

**Rationale**:
[Explain why this was chosen over alternatives]

**Consequences**:
- (+) [Positive consequence]
- (-) [Negative consequence]

**Alternatives Considered**:
- [Alternative 1]: Why not chosen
- [Alternative 2]: Why not chosen

**Related Decisions**:
- [Other related ADR]

**Notes**:
[Any additional information]
```

### Steps to Create ADR

1. **Identify Major Decision**: Something that affects architecture significantly
2. **Document Context**: What problem does this solve?
3. **Explain Decision**: What was chosen and why?
4. **Note Consequences**: What are the trade-offs?
5. **File Name**: `ADR-XXX-Title.md`
6. **Add to Index**: Update this README
7. **Review**: Get team consensus on major decisions

---

## Related Documentation

- **[System Architecture](SYSTEM_INTERACTION.md)** - How systems interact
- **[Data Flow](DATA_FLOW.md)** - Data movement patterns
- **[Code Standards](../CODE_STANDARDS.md)** - Implementation conventions

---

**Last Updated**: October 2025 | **Total ADRs**: 5

