# Battle Mechanics Documentation

## Overview

The `mechancis` folder contains comprehensive documentation for all tactical battle mechanics in Alien Fall. Each mechanic is documented in a dedicated Markdown file with consistent structure, covering core gameplay systems that govern combat resolution, unit behavior, environmental effects, and strategic decision-making.

These mechanics form the foundation of the battlescape experience, implementing deterministic, data-driven systems that ensure reproducible outcomes for testing, balance analysis, and multiplayer synchronization.

## Documentation Structure

All mechanics files follow a standardized format:

- **Table of Contents**: Quick navigation to major sections
- **Overview**: High-level description and purpose
- **Mechanics**: Detailed breakdown of system components
- **Examples**: Practical scenarios and calculations
- **Related Wiki Pages**: Cross-references to connected systems
- **References**: Inspiration from existing games and mechanics

## Core Mechanics

### Combat Resolution
- **[Accuracy at Range](Accuracy%20at%20Range.md)**: Deterministic accuracy falloff system with banded range modifiers
- **[Line of Fire](Line%20of%20Fire.md)**: Projectile trajectory and obstruction mechanics
- **[Line of Sight](Line%20of%20sight.md)**: Visibility calculations and fog-of-war implementation
- **[Throwing](Throwing.md)**: Throwable item mechanics including grenades, mines, and flares

### Unit State Systems
- **[Morale](Morale.md)**: Mission-scoped psychological state affecting action efficiency
- **[Panic](Panic.md)**: Severe morale failure triggering AI-controlled behavior
- **[Sanity](Sanity.md)**: Campaign-scoped resilience with long-term psychological effects
- **[Unconscious](Unconscious.md)**: Incapacitated unit handling and post-mission resolution
- **[Wounds](Wounds.md)**: Acute trauma penalties with strategic recovery implications

### Environmental Effects
- **[Battle Day & Night](Battle%20Day%20&%20Night.md)**: Time-of-day visibility modifiers
- **[Lighting & Fog of War](Lighting%20&%20Fog%20of%20War.md)**: Illumination states and concealment mechanics
- **[Objects](Objects.md)**: Temporary tile-based elements (grenades, bodies, mines, throwables)
- **[Smoke & Fire](Smoke%20&%20Fire.md)**: Area denial and environmental hazards
- **[Terrain Damage](Terrain%20damage.md)**: Destructive terrain modification and propagation
- **[Terrain Elevation](Terrain%20Elevation.md)**: Simple high/low floor variations with movement costs

### Special Abilities
- **[Psionics](Psionics.md)**: Mental abilities with deterministic success resolution
- **[Surrender](Surrender.md)**: Automatic battle conclusion when viable units remain

## Key Design Principles

### Determinism & Reproducibility
- All random elements use seeded generation for consistent outcomes
- Complete provenance logging for debugging and balance analysis
- Mission-seeded calculations ensure multiplayer parity

### Data-Driven Configuration
- TOML-based configuration files for easy tuning
- External data separation from executable logic
- Modder-friendly architecture

### Balance & Clarity
- Transparent mechanics with clear player communication
- Comprehensive examples and edge case documentation
- Performance-conscious implementations

## Navigation Guide

### For Game Designers
- Start with core combat systems (Accuracy, Line of Sight)
- Review unit state mechanics for behavioral tuning
- Examine environmental effects for tactical variety

### For Programmers
- Reference mechanics sections for implementation requirements
- Use examples for validation and testing
- Check data structure examples for configuration formats

### For Modders
- Review TOML examples for configuration patterns
- Study cross-references for system integration points
- Use references for balance inspiration

## Related Documentation

- **[Battle Map](../map/)**: Terrain and layout systems
- **[Unit Systems](../../units/)**: Character progression and abilities
- **[AI Systems](../ai/)**: Opponent behavior and decision-making
- **[Deployment](../deployment/)**: Mission setup and unit placement

## File Index

| File | Description | Key Concepts |
|------|-------------|--------------|
| Accuracy at Range.md | Range-based accuracy modifiers | Range bands, falloff curves, dispersion |
| Battle Day & Night.md | Time-of-day tactical effects | Visibility modifiers, equipment integration |
| Lighting & Fog of War.md | Visibility states and illumination | Fog states, reveal mechanics, sense detection |
| Line of Fire.md | Projectile pathing and blocking | Trajectory, obstruction, ricochet |
| Line of sight.md | Unit visibility calculations | Sight budgets, occlusion, team visibility |
| Morale.md | Short-term psychological state | Will tests, AP modifiers, panic triggers |
| Objects.md | Temporary tile-based elements | Grenades, mines, bodies, throwables |
| Panic.md | Severe morale failure behavior | AI control, behavior selection, cascade effects |
| Psionics.md | Mental ability system | Success resolution, resource management, targeting |
| Sanity.md | Long-term psychological resilience | Campaign effects, recovery mechanics |
| Smoke & Fire.md | Environmental hazards | Area denial, visibility occlusion, burning |
| Surrender.md | Automatic battle conclusion | Viability assessment, capture processing |
| Terrain Damage.md | Destructive terrain modification | Material properties, propagation, absorption |
| Terrain Elevation.md | Simple floor height variations | High/low floors, movement costs |
| Throwing.md | Throwable item deployment | Range calculation, accuracy, object placement |
| Unconscious.md | Incapacitated unit handling | Revival mechanics, post-mission conversion |
| Wounds.md | Acute trauma penalties | Damage thresholds, healing, strategic impact |

---

*This documentation is part of the Alien Fall technical specification. All mechanics are designed for Love2D implementation with Lua scripting.*