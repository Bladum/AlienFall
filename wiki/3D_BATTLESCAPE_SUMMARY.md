# 3D Battlescape Implementation - Executive Summary

**Project:** First-Person 3D View for Tactical Battlescape  
**Created:** October 13, 2025  
**Status:** Planned (3 Tasks Created)  
**Total Estimated Time:** 85 hours (10-12 days)

---

## Overview

Implementation of a first-person 3D view for the tactical battlescape, allowing players to toggle between traditional 2D top-down view and immersive first-person perspective. Inspired by classic games like Eye of the Beholder, Ishar, and Wolfenstein 3D, but maintaining full turn-based tactical gameplay.

---

## Key Features

### Core Concept
- **Toggle System:** Press SPACE to switch between 2D and 3D views
- **Hex-Based 3D:** First-person rendering adapted for hexagonal grid (6 wall faces, not 4)
- **Shared Logic:** Both views use same battlefield data - only rendering changes
- **Turn-Based Preservation:** All movement is still turn-based, just animated for visual appeal
- **Pixel Art Style:** 24×24 pixel assets rendered with nearest-neighbor filtering

### First-Person Controls
- **W:** Move forward (one hex tile)
- **S:** Move backward (one hex tile)
- **A:** Rotate left 60° (hex direction)
- **D:** Rotate right 60° (hex direction)
- **TAB:** Switch between friendly units
- **Right-click:** Shoot at target
- **E:** Pick up item
- **Q:** Drop item

### Visual Features
- **Environment:** Floor, walls, ceiling/sky rendered from first-person viewpoint
- **Units:** Billboard sprites that always face camera (Doom-style)
- **Objects:** Trees, tables, fences as transparent billboards
- **Effects:** Fire, smoke, explosions as animated sprites
- **Visibility:** Day/night cycle, fog of war, line of sight all enforced
- **Distance Fog:** Progressive darkening based on distance
- **Minimap:** Tactical overview in corner showing position and orientation

---

## Three-Phase Implementation

### Phase 1: Core Rendering System (24 hours)
**Task:** TASK-026-3d-battlescape-core-rendering.md  
**Priority:** High

**Deliverables:**
- g3d library integration
- Hex raycasting system (6 walls per tile)
- First-person camera controller
- Floor, wall, ceiling rendering
- Distance-based fog
- Day/night sky rendering
- SPACE key toggle between 2D/3D

**Key Files:**
- `battlescape/rendering/renderer_3d.lua` - Main 3D renderer
- `battlescape/rendering/camera_3d.lua` - First-person camera
- `battlescape/rendering/hex_raycaster.lua` - Hex raycasting
- `battlescape/rendering/hex_geometry.lua` - Hex math utilities
- `libs/g3d/` - 3D rendering library

---

### Phase 2: Unit Interaction & Controls (28 hours)
**Task:** TASK-027-3d-battlescape-unit-interaction.md  
**Priority:** High  
**Depends On:** Phase 1

**Deliverables:**
- Billboard unit rendering (sprites face camera)
- WASD hex movement with animation (200ms per tile)
- A/D rotation with animation (200ms per 60°)
- Mouse picking (tiles, walls, units, items)
- Ground item rendering (5 slots per tile, 50% scale)
- Minimap integration
- TAB unit switching
- GUI consistency (same panels as 2D)

**Key Files:**
- `battlescape/rendering/billboard.lua` - Billboard sprite system
- `battlescape/systems/movement_3d.lua` - 3D movement controller
- `battlescape/systems/mouse_picking_3d.lua` - Mouse raycasting
- `battlescape/rendering/item_renderer_3d.lua` - Ground items

---

### Phase 3: Effects & Advanced Features (33 hours)
**Task:** TASK-028-3d-battlescape-effects-advanced.md  
**Priority:** Medium  
**Depends On:** Phase 2

**Deliverables:**
- Fire system integration (animated flames)
- Smoke system integration (transparent clouds)
- Object rendering (trees, tables, fences)
- Objects block movement but allow vision
- LOS/FOW enforcement in 3D
- Shooting mechanics (right-click to fire)
- Muzzle flash, bullet tracers, hit effects
- Explosion animations
- Z-sorting for proper rendering order
- Full combat system integration

**Key Files:**
- `battlescape/rendering/effects_3d.lua` - 3D effects renderer
- `battlescape/rendering/object_renderer_3d.lua` - Object renderer
- `battlescape/combat/combat_3d.lua` - 3D combat handler

---

## Technical Architecture

### Rendering Pipeline
```
[Input: SPACE key] 
    |
    v
[Battlescape.viewMode] = "2D" or "3D"
    |
    +-- [2D Mode] -> BattlefieldRenderer (existing)
    |                   |
    |                   +-> Top-down tile rendering
    |                   +-> Sprite-based units
    |
    +-- [3D Mode] -> Renderer3D (new)
                        |
                        +-> Hex raycasting
                        +-> Floor/wall/ceiling rendering
                        +-> Billboard unit rendering
                        +-> Effect rendering (fire, smoke)
                        +-> Distance fog application
```

### Data Sharing
Both 2D and 3D modes share:
- **Battlefield:** Tile data (terrain, units, objects, items)
- **Units:** Position, stats, inventory, action points
- **Combat System:** Hit calculation, damage, effects
- **LOS System:** Visibility, fog of war
- **Turn Manager:** Active team, turn order
- **Fire/Smoke Systems:** Effect positions and states

### Hex Grid Adaptation
**Key Difference from Square Grids:**
- **6 directions** instead of 4 or 8
- **6 wall faces** per tile instead of 4
- **60° rotations** instead of 90° or 45°
- **Hex distance** calculation for fog/LOS

**Hex Directions (0-5):**
```
     NW (2)    NE (1)
        \      /
   W (3) - HEX - E (0)
        /      \
     SW (4)    SE (5)
```

---

## Integration Points

### Existing Systems Used
1. **Assets System** (`core/assets.lua`) - Texture loading
2. **Hex Math** (`battle/utils/hex_math.lua`) - Grid calculations
3. **LOS System** (`battlescape/combat/los_optimized.lua`) - Visibility
4. **Action System** (`battlescape/combat/action_system.lua`) - Combat
5. **Fire System** (`battlescape/effects/fire_system.lua`) - Fire effects
6. **Smoke System** (`battlescape/effects/smoke_system.lua`) - Smoke effects
7. **Team Manager** (`shared/team.lua`) - Turn management
8. **Pathfinding** (`shared/pathfinding.lua`) - Movement validation

### New Dependencies
- **g3d library** - 3D rendering primitives for Love2D
- **Billboard rendering** - Sprite-based 3D objects
- **Hex raycasting** - Custom implementation for hex grids

---

## Development Workflow

### Phase 1: Foundation (Days 1-3)
1. Copy g3d library from 3d_maze_demo
2. Create basic 3D renderer structure
3. Implement hex raycasting
4. Render basic floor and walls
5. Add SPACE toggle functionality
6. Test with simple maps

### Phase 2: Interaction (Days 4-7)
1. Implement billboard rendering for units
2. Add WASD movement controls
3. Add A/D rotation controls
4. Implement mouse picking
5. Render ground items
6. Integrate minimap
7. Test movement and unit switching

### Phase 3: Polish (Days 8-12)
1. Integrate fire effects
2. Integrate smoke effects
3. Add object rendering
4. Enforce LOS/FOW
5. Implement shooting mechanics
6. Add explosion effects
7. Performance optimization
8. Final testing and documentation

---

## Testing Strategy

### Unit Testing
- Hex raycasting accuracy (6 wall faces)
- Billboard facing direction
- Movement validation (hex neighbors)
- Item slot positioning (5 per tile)
- Z-sorting correctness
- LOS filtering

### Integration Testing
- 2D ↔ 3D mode switching
- Shared data consistency
- Turn-based logic preservation
- Combat system integration
- Effect system integration
- Performance under load

### Manual Testing
- Visual quality (pixel art crispness)
- Animation smoothness (200ms timing)
- Mouse picking accuracy
- Visibility rules enforcement
- Combat feedback clarity
- UI consistency

---

## Performance Targets

- **Frame Rate:** 60 FPS in 3D mode
- **Memory:** < 200MB additional for 3D renderer
- **Mode Switch:** < 100ms transition time
- **Unit Count:** 20+ units visible without slowdown
- **Effect Count:** 10+ fires, 5+ smoke clouds at 60 FPS

---

## Risk Mitigation

### Technical Risks
1. **Hex rendering complexity**
   - Mitigation: Reference 3d_maze_demo, but adapt for hex geometry
   
2. **Performance with many effects**
   - Mitigation: Z-sorting optimization, effect pooling, LOD system
   
3. **Billboard sprite artifacts**
   - Mitigation: Proper texture filtering (nearest), alpha blending

4. **LOS integration complexity**
   - Mitigation: Use existing shadow-casting system, just filter results

### Timeline Risks
1. **Underestimated complexity**
   - Mitigation: Phase 3 is "Medium" priority, can defer if needed
   
2. **g3d library limitations**
   - Mitigation: Evaluate early in Phase 1, have backup rendering approach

---

## Success Criteria

### Must Have (Phase 1 & 2)
- [x] Toggle between 2D and 3D views
- [x] First-person rendering of terrain
- [x] WASD movement controls
- [x] Unit billboard rendering
- [x] Mouse picking for targeting
- [x] Basic combat functionality
- [x] Minimap display

### Should Have (Phase 3)
- [x] Fire and smoke effects
- [x] Object rendering (trees, tables)
- [x] Full LOS/FOW enforcement
- [x] Shooting with visual feedback
- [x] Explosion effects

### Nice to Have (Future)
- [ ] Dynamic lighting system
- [ ] Weather effects (rain, snow)
- [ ] Footstep sounds
- [ ] Ambient audio
- [ ] Unit death animations
- [ ] Weapon reload animations
- [ ] Destructible environment

---

## Documentation Requirements

### Code Documentation
- Inline comments for all 3D rendering code
- API documentation for new modules
- Architecture diagrams for rendering pipeline

### User Documentation
- **FAQ Updates:** How to use 3D mode
- **Wiki Updates:** 3D controls, features, limitations
- **Dev Guide Updates:** 3D rendering system overview

### Task Tracking
- Update tasks.md with progress
- Move task files through TODO → IN_PROGRESS → DONE
- Log lessons learned in each task document

---

## Future Enhancements

### Post-MVP Features
1. **VR Support** - Adapt for VR headsets (major undertaking)
2. **Advanced Lighting** - Dynamic shadows, flashlights
3. **Weather System** - Rain, fog, snow in 3D view
4. **Destructible Environment** - Walls break apart when damaged
5. **Advanced Animations** - Unit movement, weapon reloading, death
6. **Sound Design** - Positional audio, ambient sounds
7. **Cinematic Camera** - Automated camera for kill shots
8. **Replay System** - Record and playback battles in 3D

---

## Conclusion

This three-phase implementation plan provides a complete first-person 3D tactical view for the battlescape while maintaining all existing turn-based gameplay mechanics. The phased approach allows for incremental development and testing, with each phase delivering tangible value:

- **Phase 1:** Players can see the battlefield in 3D
- **Phase 2:** Players can control units and interact in 3D
- **Phase 3:** Players have full combat and effects in 3D

Total investment of 85 hours (~2 weeks) brings a unique and immersive feature that differentiates the game from traditional 2D tactical games while preserving the deep tactical gameplay.

**Recommendation:** Proceed with Phase 1 as high priority to validate technical approach, then evaluate Phase 2 & 3 based on results.
