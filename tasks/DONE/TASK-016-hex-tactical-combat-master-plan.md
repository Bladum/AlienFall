# Task: HEX Grid Tactical Combat System - Master Implementation Plan

**Status:** TODO  
**Priority:** Critical  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Comprehensive implementation of all HEX grid tactical combat mechanics for turn-based strategy gameplay inspired by X-COM UFO Defense. This master plan covers 20+ interconnected systems for pathfinding, line of sight/fire, combat mechanics, environmental effects, and destructible terrain on a 2D hexagonal grid.

---

## Purpose

Transform AlienFall into a fully functional tactical combat game with:
- **Strategic Movement**: Pathfinding with terrain costs, obstacles, and tactical positioning
- **Realistic Combat**: Line of fire, cover mechanics, reaction fire, and area damage
- **Environmental Systems**: Fire spread, smoke propagation, destructible/explodable terrain
- **Advanced Mechanics**: Raycasting, shrapnel, sound detection, stealth combat
- **Complete Weapon Systems**: Bullets, lasers, explosives, thrown objects

This creates the foundation for deep tactical gameplay comparable to classic X-COM.

---

## Master Feature List

### Core Grid Operations (Foundation)
1. ✅ **HEX Grid Math** - Basic coordinate conversion and neighbor finding (DONE)
2. ⬜ **Pathfinding with Movement Costs** - A* pathfinding considering terrain costs, TU/AP consumption
3. ⬜ **Distance Calculations** - Various distance metrics (Manhattan, Euclidean, hex distance)
4. ⬜ **Area Calculations** - Get all hexes in radius, ring, cone, or arbitrary shape

### Line of Sight & Fire Systems
5. ⬜ **Line of Sight (LOS)** - Basic visibility with terrain blocking and height
6. ⬜ **Line of Fire (LOF)** - Fire trajectory with cover calculation
7. ⬜ **Raycasting** - Fast line intersection for instant hit weapons
8. ⬜ **Raytracing** - Full path tracing for ricochets and penetration
9. ⬜ **Cover System** - Calculate cover value based on terrain and obstacles
10. ⬜ **Shooting Through Objects** - Partial cover (windows, fences) with hit probability

### Environmental Effects
11. ⬜ **Smoke System** - Multi-level smoke propagation and LOS blocking
12. ⬜ **Fire System** - Fire spread with flammable terrain and intensity levels
13. ⬜ **Destructible Terrain** - Damage and destroy terrain tiles
14. ⬜ **Flammable Terrain** - Terrain catches fire with probability
15. ⬜ **Explodable Terrain** - Terrain explodes when destroyed (chain reactions)

### Combat Mechanics
16. ⬜ **Explosion System** - Area damage with power wave from epicenter
17. ⬜ **Shrapnel System** - Multiple projectiles from explosion
18. ⬜ **Beam Weapons** - Laser/plasma instant hit with penetration
19. ⬜ **Throwable Trajectory** - Arc trajectory for grenades
20. ⬜ **Reaction Fire** - Opportunity fire during enemy movement

### Stealth & Detection
21. ⬜ **Sound System** - Noise generation and hearing radius
22. ⬜ **Stealth Mechanics** - Hidden movement and detection
23. ⬜ **Sense of Hearing** - Sound-based detection without LOS

---

## Implementation Phases

### Phase 1: Core Grid Systems (Foundation) - 40 hours
**Goal:** Establish robust HEX grid utilities for all other systems to build on

#### TASK-016A: Enhanced Pathfinding System
- **Priority:** Critical
- **Time:** 16 hours
- **Dependencies:** HexMath (complete)
- **Description:** 
  - Implement A* pathfinding with proper hex distance heuristic
  - Support terrain movement costs (1x normal, 2x rough, 4x very rough, infinite blocking)
  - Calculate TU/AP consumption along path
  - Support multi-turn movement planning
  - Path visualization for player
- **Files:**
  - `engine/battlescape/map/pathfinding.lua` (new)
  - `engine/battlescape/logic/movement_system.lua` (enhance)
- **Tests:**
  - Path through open terrain
  - Path around obstacles
  - Path through varied terrain costs
  - Multi-turn movement calculation

#### TASK-016B: Distance and Area Calculations
- **Priority:** High
- **Time:** 8 hours
- **Dependencies:** HexMath (complete)
- **Description:**
  - Hex distance (already exists, enhance)
  - Euclidean distance for ranges
  - Manhattan distance for alternate metrics
  - Get hexes in radius (circle)
  - Get hexes in ring (donut shape)
  - Get hexes in cone (weapon arcs)
  - Get hexes in arbitrary shape (for abilities)
- **Files:**
  - `engine/battlescape/map/hex_math.lua` (enhance)
  - `engine/battlescape/map/area_math.lua` (new)
- **Tests:**
  - Verify radius calculations
  - Test cone accuracy at different angles
  - Validate ring calculations

#### TASK-016C: Grid Query System
- **Priority:** Medium
- **Time:** 8 hours
- **Dependencies:** HexSystem, AreaMath
- **Description:**
  - Get all units in area
  - Get all terrain in area
  - Get all effects in area
  - Spatial indexing for performance
  - Query by type, faction, condition
- **Files:**
  - `engine/battlescape/logic/spatial_query.lua` (new)
- **Tests:**
  - Query units in radius
  - Query terrain types
  - Performance test with 100+ entities

#### TASK-016D: Height and Multi-Level Support
- **Priority:** Medium
- **Time:** 8 hours
- **Dependencies:** HexSystem
- **Description:**
  - Add height property to hexes
  - Height-based LOS calculations
  - Climbing/falling mechanics
  - Height advantage in combat
- **Files:**
  - `engine/battlescape/map/hex_system.lua` (enhance)
  - `engine/battlescape/map/height_math.lua` (new)
- **Tests:**
  - LOS blocked by elevation
  - Height advantage calculations
  - Falling damage

---

### Phase 2: Line of Sight & Fire (Vision) - 48 hours
**Goal:** Complete vision and targeting systems with cover mechanics

#### TASK-016E: Enhanced Line of Sight System
- **Priority:** Critical
- **Time:** 12 hours
- **Dependencies:** HexSystem, HeightMath
- **Description:**
  - Bresenham line algorithm adapted for hexes
  - Support partial blocking (smoke, windows)
  - Height-based LOS (shoot over low walls)
  - Darkness and lighting levels
  - Peripheral vision vs direct LOS
  - LOS caching for performance
- **Files:**
  - `engine/battlescape/logic/vision_system.lua` (enhance)
  - `engine/battlescape/map/hex_line.lua` (new)
- **Tests:**
  - LOS through open terrain
  - LOS blocked by walls
  - LOS through smoke (partial)
  - Height advantage LOS

#### TASK-016F: Line of Fire System
- **Priority:** Critical
- **Time:** 12 hours
- **Dependencies:** VisionSystem, CoverSystem
- **Description:**
  - Calculate fire trajectory (different from LOS)
  - Account for weapon height and angles
  - Calculate hit probability based on LOF obstructions
  - Support arc fire (grenades) vs direct fire
  - Determine if target is hittable
- **Files:**
  - `engine/battlescape/combat/line_of_fire.lua` (new)
- **Tests:**
  - Direct LOF to target
  - LOF blocked by cover
  - Arc trajectory calculations
  - Partial obstruction hit penalties

#### TASK-016G: Cover System
- **Priority:** High
- **Time:** 12 hours
- **Dependencies:** LOSSystem, LOFSystem, TerrainData
- **Description:**
  - Calculate cover value (0%, 25%, 50%, 75%, 100%)
  - Consider terrain between shooter and target
  - Half cover vs full cover
  - Direction-based cover (flanking)
  - Destructible cover (reduces over time)
  - Cover visualization for player
- **Files:**
  - `engine/battlescape/combat/cover_system.lua` (new)
  - `engine/data/terrain_cover_data.lua` (new)
- **Tests:**
  - Cover from walls
  - Partial cover from low obstacles
  - Flanking negates cover
  - Destroyed cover recalculation

#### TASK-016H: Raycasting System
- **Priority:** High
- **Time:** 8 hours
- **Dependencies:** HexLine, HexSystem
- **Description:**
  - Fast ray intersection for instant weapons
  - Hit detection along ray path
  - Support for penetration (bullets through walls)
  - Multiple hit detection (penetrating shots)
  - Reflection/ricochet angles
- **Files:**
  - `engine/battlescape/map/raycast.lua` (new)
- **Tests:**
  - Ray hits first obstacle
  - Ray penetrates thin walls
  - Ray reflects off surfaces
  - Multiple entity hits

#### TASK-016I: Shooting Through Partial Objects
- **Priority:** Medium
- **Time:** 4 hours
- **Dependencies:** CoverSystem, LOFSystem
- **Description:**
  - Define partial blocking objects (windows, fences, grates)
  - Calculate hit probability reduction
  - Chance to hit obstacle instead of target
  - Destructible partial cover
- **Files:**
  - `engine/data/partial_cover_data.lua` (new)
  - `engine/battlescape/combat/cover_system.lua` (enhance)
- **Tests:**
  - Shoot through window
  - Hit fence instead of target
  - Destroy partial cover

---

### Phase 3: Environmental Effects (Atmosphere) - 44 hours
**Goal:** Dynamic battlefield with smoke, fire, and destructible environment

#### TASK-016J: Smoke System
- **Priority:** High
- **Time:** 12 hours
- **Dependencies:** VisionSystem, AreaMath
- **Description:**
  - Multi-level smoke (light, medium, heavy)
  - Smoke propagation algorithm
  - Wind affects smoke direction
  - Smoke dissipates over time
  - Blocks LOS partially or fully
  - Smoke grenades and smoke from explosions/fire
- **Files:**
  - `engine/battlescape/effects/smoke_system.lua` (enhance)
  - `engine/battlescape/entities/smoke_cloud.lua` (new)
- **Tests:**
  - Smoke spreads from source
  - Smoke blocks LOS
  - Smoke dissipates over time
  - Wind moves smoke

#### TASK-016K: Fire System Enhancement
- **Priority:** High
- **Time:** 12 hours
- **Dependencies:** HexSystem, SmokeSystem
- **Description:**
  - Fire spread algorithm using hex neighbors
  - Flammable terrain types (wood, grass, fuel)
  - Fire intensity levels (1-5)
  - Fire damage to units per turn
  - Fire creates smoke
  - Fire consumes oxygen (suffocation in enclosed spaces)
  - Water/foam extinguishes fire
- **Files:**
  - `engine/battlescape/effects/fire_system.lua` (enhance)
  - `engine/data/terrain_flammability.lua` (new)
- **Tests:**
  - Fire spreads to adjacent hexes
  - Non-flammable terrain stops spread
  - Units take damage in fire
  - Fire creates smoke

#### TASK-016L: Destructible Terrain System
- **Priority:** High
- **Time:** 12 hours
- **Dependencies:** HexSystem, DamageSystem
- **Description:**
  - Terrain hit points per type
  - Terrain armor vs damage types
  - Terrain destroyed → becomes rubble/hole
  - Partial destruction (walls → damaged walls)
  - Chain destruction (support pillars)
  - Terrain blocks projectiles until destroyed
- **Files:**
  - `engine/battlescape/map/terrain_destruction.lua` (new)
  - `engine/data/terrain_durability.lua` (new)
- **Tests:**
  - Wall destroyed by explosives
  - Partial damage to terrain
  - Chain destruction
  - Projectile penetration

#### TASK-016M: Explodable Terrain
- **Priority:** Medium
- **Time:** 8 hours
- **Dependencies:** ExplosionSystem, TerrainDestruction
- **Description:**
  - Terrain types that explode when destroyed (fuel tanks, gas pipes)
  - Secondary explosions
  - Chain reaction explosions
  - Explosive terrain properties (blast radius, damage)
- **Files:**
  - `engine/data/explodable_terrain.lua` (new)
  - `engine/battlescape/map/terrain_destruction.lua` (enhance)
- **Tests:**
  - Fuel tank explodes when shot
  - Chain explosion from multiple tanks
  - Explosive terrain damages surroundings

---

### Phase 4: Advanced Combat Mechanics (Weapons) - 52 hours
**Goal:** Complete weapon systems and combat resolution

#### TASK-016N: Explosion and Area Damage System
- **Priority:** Critical
- **Time:** 16 hours
- **Dependencies:** AreaMath, TerrainDestruction, DamageSystem
- **Description:**
  - Explosion power propagation from epicenter
  - Power dropoff by distance (inverse square)
  - Obstacles absorb blast power
  - Damage wave algorithm (ring-by-ring)
  - Shockwave pushes objects
  - Destroy terrain in blast radius
  - Create smoke and fire
  - Animated explosion rings
- **Files:**
  - `engine/battlescape/effects/explosion_system.lua` (enhance)
  - `engine/battlescape/effects/blast_propagation.lua` (new)
- **Tests:**
  - Explosion damages all in radius
  - Power reduced by distance
  - Obstacles block blast
  - Chain explosions

#### TASK-016O: Shrapnel System
- **Priority:** High
- **Time:** 12 hours
- **Dependencies:** ExplosionSystem, ProjectileSystem, Raycast
- **Description:**
  - Generate N shrapnel pieces from explosion
  - Random direction and velocity
  - Each shrapnel is mini-projectile
  - Shrapnel damages first thing hit
  - Shrapnel can penetrate based on power
  - Visual representation (particles)
- **Files:**
  - `engine/battlescape/effects/shrapnel_system.lua` (new)
  - `engine/battlescape/entities/shrapnel.lua` (new)
- **Tests:**
  - Shrapnel radiates from explosion
  - Shrapnel damages units
  - Shrapnel stopped by walls
  - Shrapnel count based on explosive

#### TASK-016P: Beam Weapon System
- **Priority:** High
- **Time:** 8 hours
- **Dependencies:** Raycast, ProjectileSystem
- **Description:**
  - Instant hit beam weapons (laser, plasma)
  - Full penetration through multiple targets
  - Damage reduction per target penetrated
  - Can cut through walls (high power)
  - Visual beam effect
  - Heat buildup mechanics (sustained beams)
- **Files:**
  - `engine/battlescape/combat/beam_weapon.lua` (new)
  - `engine/battlescape/combat/beam_weapons.lua` (new)
- **Tests:**
  - Laser hits instantly
  - Beam penetrates multiple targets
  - Beam cuts through terrain
  - Visual beam rendering

#### TASK-016Q: Throwable Object Trajectory
- **Priority:** High
- **Time:** 8 hours
- **Dependencies:** AreaMath, HeightMath, ProjectileSystem
- **Description:**
  - Arc trajectory calculation for thrown objects
  - Account for gravity and throw strength
  - Maximum range based on strength stat
  - Can throw over obstacles
  - Bounce mechanics for some objects
  - Preview trajectory for player
  - Hit chance based on accuracy and distance
- **Files:**
  - `engine/battlescape/map/trajectory.lua` (enhance)
  - `engine/battlescape/combat/throwing_system.lua` (new)
- **Tests:**
  - Grenade arcs to target
  - Throw over wall
  - Bounce off surfaces
  - Trajectory preview

#### TASK-016R: Reaction Fire System
- **Priority:** Critical
- **Time:** 8 hours
- **Dependencies:** VisionSystem, ShootingSystem, MovementSystem
- **Description:**
  - Reserve TUs for reaction shots
  - Trigger on enemy movement in LOS
  - Snap shot at moving target
  - Accuracy penalty for reaction fire
  - Multiple reaction shots if TUs available
  - Player can enable/disable reaction mode
  - AI reaction fire behavior
- **Files:**
  - `engine/battlescape/combat/reaction_fire.lua` (new)
  - `engine/battlescape/logic/movement_system.lua` (enhance)
- **Tests:**
  - Reaction shot during enemy turn
  - TU consumption for reaction
  - Multiple reaction shots
  - Reaction disabled when out of TUs

---

### Phase 5: Stealth & Detection (Sensors) - 24 hours
**Goal:** Sound-based detection and stealth gameplay

#### TASK-016S: Sound System
- **Priority:** Medium
- **Time:** 12 hours
- **Dependencies:** AreaMath, HexSystem
- **Description:**
  - Sound events with radius and volume
  - Sound propagation through terrain
  - Walls muffle sound (reduce radius)
  - Different actions create different sounds (walking, shooting, explosions)
  - Sound markers on map for player
  - AI reacts to sounds
- **Files:**
  - `engine/battlescape/logic/sound_system.lua` (new)
  - `engine/battlescape/entities/sound_event.lua` (new)
  - `engine/data/sound_levels.lua` (new)
- **Tests:**
  - Gunshot creates sound
  - Sound radius calculated
  - Walls reduce sound range
  - AI investigates sound

#### TASK-016T: Hearing and Detection
- **Priority:** Medium
- **Time:** 8 hours
- **Dependencies:** SoundSystem, VisionSystem
- **Description:**
  - Units have hearing radius stat
  - Detect enemies by sound without LOS
  - Last known position tracking
  - Investigation behavior
  - Stealth bonus for silent weapons
- **Files:**
  - `engine/battlescape/logic/detection_system.lua` (new)
  - `engine/battlescape/logic/ai_investigation.lua` (new)
- **Tests:**
  - Unit hears gunshot
  - Unit moves to investigate
  - Silent weapon doesn't alert
  - Detection radius calculation

#### TASK-016U: Stealth Mechanics
- **Priority:** Low
- **Time:** 4 hours
- **Dependencies:** VisionSystem, SoundSystem, DetectionSystem
- **Description:**
  - Stealth mode (slower movement, less noise)
  - Light level affects detection
  - Prone position harder to see
  - Camouflage equipment bonuses
  - Spotted status and alertness levels
- **Files:**
  - `engine/battlescape/logic/stealth_system.lua` (new)
- **Tests:**
  - Stealth mode reduces detection
  - Dark areas help stealth
  - Prone harder to spot
  - Breaking stealth alerts enemies

---

## Architecture Overview

### Core Utilities (Foundation Layer)
```
battle/utils/
├── hex_math.lua           -- Grid coordinate math (DONE)
├── pathfinding.lua        -- A* pathfinding (NEW)
├── area_math.lua          -- Area/radius calculations (NEW)
├── height_math.lua        -- Height and elevation (NEW)
├── hex_line.lua           -- Bresenham for hexes (NEW)
├── raycast.lua            -- Ray intersection (NEW)
├── trajectory.lua         -- Arc trajectory (ENHANCE)
└── blast_propagation.lua  -- Explosion waves (NEW)
```

### Battle Systems (Game Logic Layer)
```
battle/systems/
├── hex_system.lua         -- Grid management (DONE)
├── movement_system.lua    -- Movement + pathfinding (ENHANCE)
├── vision_system.lua      -- Line of sight (ENHANCE)
├── line_of_fire.lua       -- Fire trajectory (NEW)
├── cover_system.lua       -- Cover calculation (NEW)
├── spatial_query.lua      -- Grid queries (NEW)
├── smoke_system.lua       -- Smoke propagation (ENHANCE)
├── terrain_destruction.lua -- Destructible terrain (NEW)
├── explosion_system.lua   -- Area damage (ENHANCE)
├── shrapnel_system.lua    -- Shrapnel (NEW)
├── beam_weapon.lua        -- Laser weapons (NEW)
├── throwing_system.lua    -- Grenades (NEW)
├── reaction_fire.lua      -- Opportunity fire (NEW)
├── sound_system.lua       -- Audio events (NEW)
├── detection_system.lua   -- Multi-sensor detection (NEW)
└── stealth_system.lua     -- Stealth mechanics (NEW)
```

### Data Definitions (Configuration Layer)
```
data/
├── terrain_cover_data.lua      -- Cover values (NEW)
├── partial_cover_data.lua      -- Windows, fences (NEW)
├── terrain_flammability.lua    -- Fire spread (NEW)
├── terrain_durability.lua      -- HP and armor (NEW)
├── explodable_terrain.lua      -- Explosive objects (NEW)
└── sound_levels.lua            -- Noise data (NEW)
```

### Entity Components (Data Layer)
```
battle/entities/
├── smoke_cloud.lua        -- Smoke entity (NEW)
├── shrapnel.lua           -- Shrapnel projectile (NEW)
└── sound_event.lua        -- Sound occurrence (NEW)
```

---

## Data Structures

### Pathfinding Node
```lua
{
    q = 10,           -- Hex Q coordinate
    r = 15,           -- Hex R coordinate
    g = 8,            -- Cost from start
    h = 12,           -- Heuristic to goal
    f = 20,           -- Total cost (g + h)
    parent = node,    -- Previous node in path
    terrain_cost = 2  -- Movement multiplier
}
```

### Cover Data
```lua
{
    value = 50,           -- Cover percentage (0-100)
    direction = 2,        -- Direction of cover (hex facing)
    destructible = true,  -- Can be destroyed
    durability = 20,      -- HP remaining
    partial = false       -- Full or partial cover
}
```

### Sound Event
```lua
{
    x = 240,          -- World X position
    y = 360,          -- World Y position
    volume = 80,      -- Sound intensity (0-100)
    radius = 15,      -- Hearing range in hexes
    type = "gunshot", -- Event type
    created = 1.5,    -- Time created
    duration = 3.0    -- How long it lasts
}
```

### Explosion Wave
```lua
{
    center_q = 10,
    center_r = 15,
    power = 100,        -- Initial blast power
    current_ring = 0,   -- Propagation ring
    max_radius = 8,     -- Maximum affected hexes
    affected = {},      -- Already damaged hexes
    frame = 0           -- Animation frame
}
```

---

## Testing Strategy

### Unit Tests (Per System)
Each system will have dedicated test file:
- `engine/battlescape/tests/test_pathfinding.lua`
- `engine/battlescape/tests/test_los_system.lua`
- `engine/battlescape/tests/test_cover_system.lua`
- etc.

### Integration Tests
- **Smoke + Fire + LOS**: Fire creates smoke that blocks line of sight
- **Explosion + Terrain + Shrapnel**: Explosion destroys terrain and generates shrapnel
- **Movement + Reaction Fire + Sound**: Movement triggers reaction fire and sound
- **Cover + Destruction + LOF**: Cover is destroyed, improving line of fire

### Performance Tests
- Pathfinding with 1000+ hexes
- LOS calculations for 20+ units
- Explosion with 100+ affected hexes
- Sound propagation through complex map

### Gameplay Tests
Create test scenarios:
1. **Urban Combat**: Buildings, windows, destructible walls
2. **Fire Fight**: Flammable terrain, smoke, explosions
3. **Stealth Mission**: Sound detection, darkness, silent weapons
4. **Artillery Barrage**: Multiple explosions, chain reactions, shrapnel

---

## Performance Considerations

### Optimization Strategies
1. **Spatial Indexing**: Use grid sectors for fast entity queries
2. **LOS Caching**: Cache LOS results between static units
3. **Dirty Flags**: Only recalculate when terrain changes
4. **Pooling**: Reuse projectile, smoke, sound objects
5. **LOD**: Reduce calculation detail for distant effects
6. **Async Processing**: Spread heavy calculations over multiple frames

### Performance Targets
- Pathfinding: < 5ms for 30 hex path
- LOS calculation: < 1ms per unit pair
- Explosion: < 10ms for 8 hex radius
- Frame rate: 60 FPS with 20+ units and active effects

---

## Documentation Requirements

### API Documentation
Update `wiki/API.md` with:
- All new utility functions
- System interfaces
- Data structure formats
- Usage examples

### Game Mechanics Guide
Update `wiki/FAQ.md` with:
- How cover works
- Fire and smoke mechanics
- Reaction fire rules
- Sound detection ranges
- Stealth gameplay tips

### Developer Guide
Update `wiki/DEVELOPMENT.md` with:
- How to add new terrain types
- How to create new weapon systems
- Performance profiling tools
- Testing procedures

### Code Documentation
- Google-style docstrings for all functions
- Module-level documentation
- Data structure comments
- Algorithm explanations

---

## Dependencies Between Tasks

### Critical Path
```
HexMath (DONE)
    ↓
Pathfinding (016A) → Movement System
    ↓
Area Math (016B) → All AOE systems
    ↓
Height Math (016D) → LOS/LOF systems
    ↓
LOS System (016E) → Vision, Cover, Reaction Fire
    ↓
LOF System (016F) → Shooting, Cover
    ↓
Cover System (016G) → Combat Resolution
```

### Parallel Tracks
- **Environmental**: Smoke → Fire → Destruction → Explosions
- **Weapons**: Projectiles → Beams → Throwables → Explosions
- **Stealth**: Sound → Detection → Stealth
- **Terrain**: Height → Destruction → Flammable/Explodable

---

## Milestones

### Milestone 1: Foundation (Week 1-2)
- ✅ Pathfinding working
- ✅ Distance/Area calculations complete
- ✅ Height system integrated
- **Deliverable**: Units can move through complex terrain

### Milestone 2: Vision (Week 3-4)
- ✅ LOS system complete
- ✅ LOF system working
- ✅ Cover system functional
- **Deliverable**: Units can see and target with cover

### Milestone 3: Environment (Week 5-6)
- ✅ Smoke propagation working
- ✅ Fire spread functional
- ✅ Destructible terrain implemented
- **Deliverable**: Dynamic battlefield with effects

### Milestone 4: Advanced Combat (Week 7-8)
- ✅ Explosions with area damage
- ✅ Shrapnel system working
- ✅ Beam weapons functional
- ✅ Reaction fire implemented
- **Deliverable**: Complete weapon systems

### Milestone 5: Polish (Week 9)
- ✅ Sound system complete
- ✅ Stealth mechanics working
- ✅ All tests passing
- ✅ Documentation complete
- **Deliverable**: Production-ready tactical combat

---

## Risk Assessment

### High Risk Areas
1. **Performance**: Pathfinding and LOS can be CPU intensive
   - **Mitigation**: Implement caching and spatial indexing early
   
2. **Complexity**: Many interconnected systems
   - **Mitigation**: Strict interfaces, unit tests for each system
   
3. **Balance**: Difficulty tuning smoke, fire, explosions
   - **Mitigation**: Extensive playtesting, configurable values

### Known Challenges
- **HEX to Pixel**: Coordinate conversion for rendering
- **Turn-Based**: Async animations in synchronous game loop
- **AI**: Complex decision making with new systems
- **Save/Load**: Serializing dynamic effects

---

## Success Criteria

### Technical Criteria
- [ ] All 20 systems implemented and tested
- [ ] 90%+ test coverage for core systems
- [ ] 60 FPS with 20 units and 10+ active effects
- [ ] No memory leaks over 1000 turn game
- [ ] Clean separation of concerns (no system dependencies violations)

### Gameplay Criteria
- [ ] Pathfinding finds optimal routes through complex terrain
- [ ] Cover provides meaningful tactical advantages
- [ ] Fire and smoke create dynamic battlefield situations
- [ ] Explosions feel powerful and impactful
- [ ] Stealth gameplay is viable and rewarding
- [ ] Reaction fire creates tension and tactical depth

### Quality Criteria
- [ ] All code follows Lua best practices
- [ ] Comprehensive API documentation
- [ ] Player-facing mechanics explained in FAQ
- [ ] Developer guide for extending systems
- [ ] No console warnings or errors

---

## Post-Implementation Plans

### Phase 6: AI Integration (Future)
- AI uses pathfinding for movement
- AI evaluates cover positions
- AI uses grenades and area weapons
- AI reacts to sound and stealth

### Phase 7: Advanced Features (Future)
- Multi-level maps (buildings with floors)
- Underwater combat
- Zero-gravity environments
- Weather effects (rain extinguishes fire)
- Day/night cycle (affects LOS)

### Phase 8: Modding Support (Future)
- Custom terrain types
- Custom weapon systems
- Scriptable effects
- Map editor integration

---

## Task Breakdown Structure

### Individual Task Files (To Be Created)
- `TASK-016A-pathfinding-system.md`
- `TASK-016B-distance-area-calculations.md`
- `TASK-016C-grid-query-system.md`
- `TASK-016D-height-multi-level.md`
- `TASK-016E-line-of-sight-enhanced.md`
- `TASK-016F-line-of-fire-system.md`
- `TASK-016G-cover-system.md`
- `TASK-016H-raycasting-system.md`
- `TASK-016I-partial-cover-shooting.md`
- `TASK-016J-smoke-system-enhanced.md`
- `TASK-016K-fire-system-enhanced.md`
- `TASK-016L-destructible-terrain.md`
- `TASK-016M-explodable-terrain.md`
- `TASK-016N-explosion-area-damage.md`
- `TASK-016O-shrapnel-system.md`
- `TASK-016P-beam-weapon-system.md`
- `TASK-016Q-throwable-trajectory.md`
- `TASK-016R-reaction-fire-system.md`
- `TASK-016S-sound-system.md`
- `TASK-016T-hearing-detection.md`
- `TASK-016U-stealth-mechanics.md`

---

## Notes

### Design Philosophy
- **Emergent Gameplay**: Simple systems combine for complex situations
- **Player Agency**: Clear information for tactical decisions
- **Deterministic**: Same input = same output (for testing and replay)
- **Moddable**: Data-driven design for easy customization

### Reference Games
- **X-COM UFO Defense**: Gold standard for tactical combat
- **Jagged Alliance 2**: Interrupt system, sound detection
- **Silent Storm**: Destructible terrain, realistic ballistics
- **Battle Brothers**: Hex grid combat, morale system

### Technical Inspiration
- **Red Blob Games**: Hex grid algorithms (redblobgames.com/grids/hexagons/)
- **Amit's A* Pages**: Pathfinding optimization
- **Game Programming Patterns**: System architecture

---

## Review Checklist

### Before Starting
- [ ] Read all existing battle system code
- [ ] Understand current HexMath and HexSystem
- [ ] Review X-COM mechanics documentation
- [ ] Set up performance profiling tools

### During Development
- [ ] Write tests before implementation (TDD)
- [ ] Profile performance regularly
- [ ] Document as you code
- [ ] Commit frequently with clear messages
- [ ] Run game with Love2D console for debugging

### After Completion
- [ ] All unit tests pass
- [ ] Integration tests pass
- [ ] Performance targets met
- [ ] Documentation updated
- [ ] Code review completed
- [ ] Gameplay tested by humans

---

## Time Estimate Summary

| Phase | Hours | Weeks @ 20h/week |
|-------|-------|------------------|
| Phase 1: Core Grid Systems | 40 | 2.0 |
| Phase 2: Line of Sight & Fire | 48 | 2.4 |
| Phase 3: Environmental Effects | 44 | 2.2 |
| Phase 4: Advanced Combat | 52 | 2.6 |
| Phase 5: Stealth & Detection | 24 | 1.2 |
| **Total** | **208** | **10.4** |

**Note**: Estimates assume single developer working part-time. Actual time may vary based on:
- Existing code reuse
- Performance optimization needs
- Testing thoroughness
- Documentation detail level

---

## Getting Started

### Recommended Order
1. Read this master plan completely
2. Review existing HexMath and HexSystem code
3. Start with TASK-016A (Pathfinding) - most critical
4. Implement Phase 1 completely before moving to Phase 2
5. Test each system thoroughly before integration
6. Update tasks.md as you complete each sub-task

### Quick Start Commands
```bash
# Run game with console
lovec "engine"

# Run specific test
lovec "engine" --test pathfinding

# Run all battle tests
lovec "engine" --test-suite battle
```

---

## Contact and Questions

If stuck or need clarification:
1. Check `wiki/API.md` for existing systems
2. Check `wiki/FAQ.md` for game mechanics
3. Review X-COM Ufopaedia for reference mechanics
4. Ask specific questions with context

---

**END OF MASTER PLAN**

This document serves as the roadmap for implementing a complete hex grid tactical combat system. Break down each phase into individual tasks as needed, and track progress in `tasks/tasks.md`.
