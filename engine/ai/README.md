# AI Module

## Overview
The **AI Module** provides artificial intelligence systems for AlienFall, including pathfinding, tactical decision-making, strategic planning, and coordination across all game layers.

## Purpose
- **Pathfinding**: A* algorithms for movement calculation
- **Tactical AI**: Turn-based combat decision-making
- **Strategic AI**: Long-term planning and resource allocation
- **Squad Coordination**: Multi-unit tactical coordination
- **Threat Assessment**: Danger evaluation and prioritization

## Core Files
| File | Purpose |
|------|---------|
| `ai_coordinator.lua` | Central AI coordinator |
| `strategic_planner.lua` | Strategy generation |
| `squad_coordination.lua` | Multi-unit coordination |
| `threat_assessment.lua` | Threat evaluation |

## Integration
**Depends On:** `core.state_manager`, `battlescape.entities`, `content.units`
**Used By:** `battlescape`, `geoscape`, `basescape`

## Testing
- `tests/unit/ai/` - AI system tests
- `tests/systems/ai/` - Integration tests

## Related Documentation
- `api/AI_SYSTEMS.md` - AI API reference
- `architecture/03-combat-tactics.md` - Architecture
