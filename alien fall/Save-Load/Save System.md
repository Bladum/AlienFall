# Save System

## Overview
The Save System provides persistent storage for all game state, progress, and user data. It supports comprehensive saving and loading of campaigns, bases, units, and strategic elements, using deterministic serialization to ensure reproducible saves and enable replay validation.

## Mechanics
- **Comprehensive State Saving**: Captures all game entities, progress, and settings
- **Deterministic Serialization**: Ensures identical game states produce identical save files
- **Campaign Continuity**: Allows players to resume campaigns at any point
- **Multiple Save Slots**: Support for multiple save games and quick saves
- **Replay Validation**: Saves enable verification of mission outcomes and achievements
- **Cross-Platform Compatibility**: Save files work across different platforms

## Examples
| Save Type | Content Saved | Use Case |
|-----------|---------------|----------|
| Quick Save | Current game state | Temporary saves during play |
| Manual Save | Full campaign state | Major milestones or before risky actions |
| Auto Save | Periodic snapshots | Crash recovery and progress protection |
| Ironman Save | Deterministic state | Challenge mode with replay validation |
| Mod Save | Mod-specific data | Preserving mod progress and settings |

## References
- XCOM: Ironman mode and save system
- Civilization: Multiple save slots and auto-save
- See Game API for mod save integration
- See Engine Tests for serialization testing