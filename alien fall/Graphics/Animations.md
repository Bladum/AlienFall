# Animations

## Overview
The animation system provides dynamic visual effects and character movements throughout the game. Using frame-based animations with precise timing controls, it creates synchronized visual feedback that enhances the turn-based gameplay experience and maintains immersion.

## Mechanics
- Frame-based animation sequences
- Timing synchronization with game turns
- State management for animation transitions
- Looping and one-shot animation types
- Performance-optimized rendering
- Integration with unit actions and effects

## Examples
| Animation Type | Frame Count | Duration | Trigger |
|----------------|-------------|----------|---------|
| Unit Movement | 8-12 frames | 0.5 seconds | Movement action |
| Weapon Fire | 4-6 frames | 0.3 seconds | Attack action |
| Damage Effect | 6 frames | 0.4 seconds | Hit received |
| Status Effect | 8 frames (looping) | Continuous | Status applied |

## References
- Love2D: Animation frameworks
- XCOM: Unit animation systems
- See also: Shaders, Tileset Loader, Unit Actions