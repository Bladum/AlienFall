# Implementation Progress - Unit Movement and Rotation System

## Completed ✓

1. **Animation System Created** (`engine/systems/battle/animation_system.lua`)
   - Movement animation (200ms per tile)
   - Rotation animation (100ms per 60°)
   - Smooth interpolation between positions/facings

2. **Unit Updates** (`engine/systems/unit.lua`)
   - Added `animX`, `animY`, `animFacing` properties
   - Updated `moveTo()` to sync animation positions

3. **Renderer Updates** (`engine/systems/battle/renderer.lua`)
   - `drawUnit()` uses animation positions
   - `drawFacingIndicator()` uses animation facing
   - `drawSelectionHighlight()` shows animated white pulsing rectangle
   - Facing indicator always displayed as white dot

4. **Path Highlighting**
   - Blue circles and text for hovered path
   - Green circles for general movement range
   - Already implemented in previous iteration

## Still TODO

### 1. Integrate Animation System into Battlescape
- Add animation system instance to Battlescape:enter()
- Call `animationSystem:update(dt)` in Battlescape:update()
- Block input during animations
- Pass time parameter to drawSelectionHighlight()

### 2. Update Movement to Use Animations
- Modify `ActionSystem:moveUnitAlongPath()` to:
  - Animate each step in the path
  - Chain animations (movement → rotation → movement → ...)
  - Update LOS after each step completes
  - Final position update only after all animations complete

### 3. Right-Click Rotation
- Add RMB handler in `battlescape:mousepressed()`
- When RMB clicked:
  - Calculate target facing direction from unit to click position
  - Start rotation animation
  - Update LOS when rotation completes
  - Deduct rotation MP cost

### 4. LOS Updates During Movement
- After each movement animation completes:
  - Call `LOS:calculateVisibilityForUnit()`
  - Update team visibility with `team:updateFromUnitLOS()`
  - Reveal tiles progressively as unit moves

### 5. Click Behavior Updates
- **LMB on reachable tile**: Move unit with animations
- **LMB outside range**: Deselect unit
- **RMB anywhere**: Rotate unit to face that direction

### 6. Collision Prevention
- Already implemented in `ActionSystem:calculateMovementCost()`
- Verify units cannot overlap during pathfinding

## Files That Need Updates

1. `engine/modules/battlescape.lua`
   - Integrate AnimationSystem
   - Add RMB rotation handler
   - Block input during animations
   - Update draw calls with time parameter

2. `engine/systems/action_system.lua`  
   - Make moveUnitAlongPath() use animations
   - Add rotation-only function for RMB

3. `engine/systems/battle/unit_selection.lua`
   - Update handleClick() for RMB rotation
   - Update handleClick() for LMB deselection outside range

## Next Steps

1. Integrate AnimationSystem into Battlescape
2. Wire up RMB rotation
3. Make movement use animations with LOS updates
4. Test all interactions work smoothly
