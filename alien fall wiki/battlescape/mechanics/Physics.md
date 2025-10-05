# Battlescape Physics

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Physics Engine Integration](#physics-engine-integration)
  - [Bullet Physics](#bullet-physics)
  - [Beam Weapons](#beam-weapons)
  - [Explosion Propagation](#explosion-propagation)
  - [Battle Tile Physical Objects](#battle-tile-physical-objects)
  - [Pathfinding with Movement Costs](#pathfinding-with-movement-costs)
  - [Line of Fire and Line of Sight](#line-of-fire-and-line-of-sight)
- [Examples](#examples)
- [Related Wiki Pages](#related-wiki-pages)

## Overview

The battlescape uses physics-based simulation for all projectiles, explosions, and collision detection to create dynamic, emergent tactical gameplay. Using Box2D or similar physics engine, bullets fly as independent physics objects, explosions propagate realistically, and terrain provides physical barriers and cover. This approach ensures consistent, predictable behavior while allowing for dramatic moments when physics interactions create unexpected tactical opportunities.

## Mechanics

### Physics Engine Integration

All combat resolution uses physics simulation for accuracy and consistency:
- **Physics Engine**: Box2D or equivalent for 2D physics simulation
- **Real-time Simulation**: Bullets and explosions resolve in real-time during animation phase
- **Deterministic Results**: Seeded physics for reproducible outcomes in testing
- **Collision Detection**: Physics engine handles all projectile-target interactions
- **Performance**: Optimized for tactical combat scale (dozens of units, hundreds of bullets)

### Bullet Physics

Projectiles are physical objects that fly until collision:
- **Physics Objects**: Each bullet is a Box2D object with velocity and collision properties
- **Independent Flight**: Bullets travel independently until hitting targets or terrain
- **Collision Response**: On hit, bullets apply damage and trigger effects
- **Multiple Hits**: Single bullet can penetrate or ricochet based on weapon properties
- **Trajectory Calculation**: Initial velocity and angle determine flight path
- **Environmental Effects**: Wind, gravity (for grenades), and terrain affect trajectory

### Beam Weapons

Laser and plasma weapons use line-based collision detection:
- **Line Representation**: Beam rendered as line between weapon and target
- **Collision Detection**: Ray-cast or line collision used to detect all objects in path
- **Instant Hit**: Beams resolve immediately, no travel time
- **Penetration**: Beams may penetrate multiple targets based on weapon power
- **Cover Interaction**: Beams blocked by solid terrain, reduced by partial cover
- **Visual Feedback**: Beam rendering shows exact path and collision points

### Explosion Propagation

Grenades and explosives create radial damage patterns:
- **Radial Bullet System**: Explosion fires multiple bullets in all directions
- **Damage Calculation**: Base damage = 10, drop-off = 2, effective range = 5 tiles
- **Bullet Count**: 60 bullets fired every 6 degrees (360° coverage)
- **Damage Distribution**: Each bullet carries damage/bullet_count (10/6 ≈ 1.67 per bullet)
- **Accumulation**: Objects hit by multiple bullets sum total damage received
- **Obstruction**: Terrain and objects block some bullets, creating realistic shadow zones
- **Fragment Behavior**: Bullets may ricochet or penetrate based on obstacle properties

### Battle Tile Physical Objects

All battle tiles have corresponding Box2D physics objects:
- **Size Categories**: Large circle, medium circle, small circle, large rect, medium rect, small rect
- **Cover Objects**: Physical shapes providing collision and line-of-sight blocking
- **Windows and Doors**: Special handling for partially transparent objects
  - **Window Solution**: Two small rectangles with gap in middle for line of sight/fire
  - **Door Solution**: Dynamic objects that can be opened/closed, changing collision state
- **Destructible Terrain**: Objects can be destroyed, changing physics state of tile
- **Height Levels**: Multi-level objects for buildings and elevation

### Pathfinding with Movement Costs

Movement uses tile-based pathfinding with rotation and terrain costs:
- **Rotation Cost**: 90-degree rotation = 1 MP (movement point)
- **Standard Movement**: Moving to adjacent tile = 2 MP
- **Diagonal Movement**: Moving diagonally = 3 MP (50% more than standard)
- **Crouch Toggle**: Enable/disable crouch = 4 MP
- **Terrain Modifiers**:
  - Normal terrain: 2 MP base cost
  - Rough terrain: 4 MP (2x normal)
  - Very rough terrain: 6 MP (3x normal)
- **Action Points Available**: Speed × 4 AP per turn (typical speed 6-12 = 24-48 AP total)
- **Pathfinding Algorithm**: A* with terrain cost weights for optimal route calculation

### Line of Fire and Line of Sight

Ray tracing determines visibility and targeting:
- **Ray Tracing**: Box2D ray-cast or custom line-based collision detection
- **LOS Calculation**: Trace line from unit eye position to target
- **LOF Calculation**: Trace line from weapon position to target
- **Obstruction Detection**: Count and classify objects blocking line
- **Partial Cover**: Objects partially blocking line provide cover bonuses
- **Height Consideration**: Elevation affects line calculations for multi-level maps
- **Fog of War**: LOS calculations update fog of war state dynamically

## Examples

### Bullet Physics Example
Soldier fires rifle at alien 20 tiles away:
1. Rifle creates bullet physics object with initial velocity toward target
2. Bullet travels at 100 m/s, taking 0.2 seconds to reach target distance
3. Bullet collides with alien's physics body, dealing 6 damage
4. If alien in partial cover, bullet may hit cover object first, reducing damage
5. Animation shows bullet trail and impact effect

### Explosion Example
Grenade thrown to center of room with 4 enemies:
1. Grenade lands at coordinates (25, 15) in tactical grid
2. System creates 60 physics bullets radiating in all directions
3. Each bullet carries 10/6 ≈ 1.67 damage
4. Enemy A hit by 8 bullets = 8 × 1.67 ≈ 13 damage
5. Enemy B behind wall hit by 2 bullets = 2 × 1.67 ≈ 3 damage
6. Enemy C in open hit by 10 bullets = 10 × 1.67 ≈ 17 damage
7. Wall blocks 45 bullets completely, creating damage shadow

### Beam Weapon Example
Soldier fires laser at alien through window:
1. System casts ray from soldier position to alien position
2. Ray intersects window gap (two small rectangles with space)
3. Laser passes through gap and hits alien
4. Instant hit applies 7 damage to alien
5. Visual effect shows continuous beam through window

### Pathfinding Example
Unit with Speed 8 (32 AP total) plans movement:
1. Rotate 90° right = 1 MP (31 AP remaining)
2. Move forward 3 tiles through normal terrain = 3 × 2 = 6 MP (25 AP remaining)
3. Move diagonal 2 tiles = 2 × 3 = 6 MP (19 AP remaining)
4. Enter rough terrain tile = 4 MP (15 AP remaining)
5. Crouch for cover = 4 MP (11 AP remaining)
6. Total movement cost: 21 MP, 11 AP remaining for shooting

## Related Wiki Pages

- [Battle Grid.md](../battlescape/map/Battle%20Grid.md) - Tactical grid system
- [Battle tile.md](../battlescape/map/Battle%20tile.md) - Individual tile definitions
- [Line of sight.md](../battlescape/combat/Line%20of%20sight.md) - Visibility mechanics
- [Cover.md](../battlescape/Cover.md) - Cover system integration
- [Action - Movement.md](../battlescape/combat/Action%20-%20Movement.md) - Movement actions
- [Damage calculations.md](../items/Damage%20calculations.md) - Damage resolution
- [Unit actions.md](../battlescape/units/Unit%20actions.md) - Combat actions

## References to Existing Games and Mechanics

- **XCOM Series**: Turn-based tactical combat with cover and flanking
- **Worms Series**: Physics-based projectiles and explosive damage
- **Angry Birds**: Physics simulation for satisfying destruction
- **Box2D Documentation**: 2D physics engine reference
- **Love2D Physics**: Love2D Box2D integration examples
