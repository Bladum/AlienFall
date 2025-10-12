# Fire and Smoke Mechanics

## Overview

The fire and smoke systems add environmental hazards to tactical combat. Fire spreads across flammable terrain, damages units, and produces smoke. Smoke reduces visibility and creates tactical opportunities for concealment and flanking.

## Fire System

### Fire Basics

- **Binary State**: Tiles are either on fire or not (no fire levels)
- **Damage**: Units standing in fire take **5 HP per turn** at the start of each turn
- **Duration**: Fire persists indefinitely until extinguished (not yet implemented)
- **Visual**: Animated flickering orange effect

### Terrain Flammability

Each terrain type has a flammability value (0.0 = fireproof, 1.0 = highly flammable):

| Terrain       | Flammability | Notes                          |
|---------------|--------------|--------------------------------|
| Floor         | 0.1          | Concrete/stone - minimal burn  |
| Wall          | 0.2          | Stone walls - low flammability |
| Wood Wall     | 0.8          | Wooden structures burn easily  |
| Door          | 0.7          | Wooden doors ignite readily    |
| Tree          | 0.9          | Natural vegetation, very flammable |
| Bushes        | 0.9          | Dense undergrowth, high risk   |
| Grass         | 0.6          | Dry grass, moderate burn       |
| Rock          | 0.0          | Stone - completely fireproof   |
| Water         | 0.0          | Cannot burn                    |
| Mud           | 0.1          | Wet soil, very low risk        |
| Road          | 0.0          | Paved surface - fireproof      |
| Fence         | 0.6          | Wooden fence, moderate risk    |

### Fire Spreading

Fire spreads to adjacent hexes each turn:

1. **Spread Chance**: 30% base chance per adjacent flammable tile
2. **Flammability Multiplier**: `spreadChance = 0.3 * terrain.flammability`
3. **Neighbor Check**: Uses 6-direction hex neighbor system
4. **Execution**: Spreading occurs during `fireSystem:update()` at turn end

**Example**:
- Fire on grass (0.6 flammability)
- Adjacent bush tile (0.9 flammability)
- Spread probability: `0.3 * 0.9 = 27%`
- Roll: `math.random() < 0.27` determines if fire spreads

### Fire and Movement

- **Blocked**: Fire tiles have **0 movement cost** (impassable)
- **Implemented in**: `action_system.lua:calculateMovementCost()`
- **Multi-tile Units**: Cannot move if ANY tile would touch fire

### Fire and Line of Sight

- **Sight Cost Penalty**: Fire adds **+3 sight cost**
- **Accumulation**: LOS system tracks cumulative sight cost
- **Blocking**: If accumulated cost exceeds unit vision range, visibility blocked
- **Implemented in**: `los_optimized.lua:castShadow()`

### Fire Methods

```lua
-- Start fire at a tile
fireSystem:startFire(x, y)

-- Spread fire to neighbors (automatic each turn)
fireSystem:spreadFire()

-- Damage units in fire (automatic each turn)
fireSystem:damageUnitsInFire(units)

-- Produce smoke from fire (automatic each turn)
fireSystem:produceSmoke()

-- Update all fire effects (call at end of turn)
fireSystem:update(units)

-- Check if tile is on fire
if battlefield.map[y][x].effects.fire then
    -- Tile is burning
end
```

## Smoke System

### Smoke Levels

Smoke has three intensity levels:

| Level      | Value | Sight Cost | Opacity | Dissipation Rate |
|------------|-------|------------|---------|------------------|
| **Light**  | 1     | +2         | 0.3     | 33% per turn     |
| **Medium** | 2     | +4         | 0.5     | 33% per turn     |
| **Heavy**  | 3     | +6         | 0.7     | 33% per turn     |

### Smoke Production

- **Source**: Fire tiles produce smoke at end of each turn
- **Amount**: 1 level of smoke per fire tile per turn
- **Accumulation**: Multiple smoke sources stack up to level 3 (heavy)
- **Visual**: Translucent gray overlay with opacity based on level

### Smoke Dissipation

Each turn, smoke has a chance to dissipate:

1. **Dissipation Chance**: 33% per turn per smoke tile
2. **Gradual**: Smoke level reduces by 1 (heavy → medium → light → clear)
3. **Random**: `math.random() < 0.33` determines dissipation
4. **Execution**: Occurs during `smokeSystem:update()` at turn end

### Smoke Spreading

Smoke can spread to adjacent tiles:

1. **Trigger**: Heavy smoke (level 3) spreads to empty neighbors
2. **Spread Chance**: 20% per adjacent tile
3. **Result**: Creates light smoke (level 1) in neighboring hex
4. **Limitation**: Only spreads from heavy smoke

### Smoke and Visibility

- **Sight Cost**: Each smoke level adds +2 sight cost
  - Light: +2
  - Medium: +4
  - Heavy: +6
- **LOS Integration**: Added to accumulated sight cost in shadow casting
- **Fog of War**: Smoke blocks vision like other high sight cost terrain
- **Tactical Use**: Create smoke screens for concealment

### Smoke Methods

```lua
-- Add smoke to a tile
smokeSystem:addSmoke(x, y, amount)  -- amount: 1-3

-- Get current smoke level
local level = smokeSystem:getSmokeLevel(x, y)  -- returns 0-3

-- Spread heavy smoke to neighbors (automatic)
smokeSystem:spreadSmoke()

-- Dissipate smoke (automatic each turn)
smokeSystem:dissipateSmoke()

-- Update all smoke effects (call at end of turn)
smokeSystem:update()

-- Check smoke level
local smoke = battlefield.map[y][x].effects.smoke or 0
if smoke >= 2 then
    -- Medium or heavy smoke
end
```

## Integration with Battlescape

### Initialization

```lua
-- In battlescape:enter()
self.fireSystem = FireSystem.new()
self.smokeSystem = SmokeSystem.new()

-- Pass battlefield and smoke system to fire system
fireSystem:setBattlefield(battlefield)
fireSystem:setSmokeSystem(smokeSystem)
smokeSystem:setBattlefield(battlefield)
```

### Turn Update

```lua
-- In battlescape:endTurn()
self.fireSystem:update(self.units)  -- Spread fire, damage units, produce smoke
self.smokeSystem:update()           -- Dissipate and spread smoke
```

### Rendering

```lua
-- In battlescape:draw() after terrain but before units
self:drawFireAndSmoke()

function Battlescape:drawFireAndSmoke()
    -- Draw fire with animated flicker
    for y = 1, self.battlefield.height do
        for x = 1, self.battlefield.width do
            if self.battlefield.map[y][x].effects.fire then
                local flicker = 0.5 + 0.5 * math.sin(self.gameTime * 10)
                love.graphics.setColor(1, 0.4 * flicker, 0, 0.7)
                -- Draw fire rectangle at tile position
            end
        end
    end
    
    -- Draw smoke with level-based opacity
    for y = 1, self.battlefield.height do
        for x = 1, self.battlefield.width do
            local smokeLevel = self.battlefield.map[y][x].effects.smoke or 0
            if smokeLevel > 0 then
                local alpha = smokeLevel * 0.2 + 0.1
                love.graphics.setColor(0.5, 0.5, 0.5, alpha)
                -- Draw smoke rectangle at tile position
            end
        end
    end
end
```

## Debug Controls

### Testing Fire and Smoke

- **F6**: Start test fire at camera center (5x5 fire cluster)
- **F7**: Clear all fire and smoke effects
- **Console**: Enable with `t.console = true` in `conf.lua`

### Console Commands

```lua
-- Start fire at specific tile
fireSystem:startFire(45, 45)

-- Add smoke manually
smokeSystem:addSmoke(50, 50, 3)  -- Heavy smoke

-- Get fire count
local fireCount = 0
for y = 1, battlefield.height do
    for x = 1, battlefield.width do
        if battlefield.map[y][x].effects.fire then
            fireCount = fireCount + 1
        end
    end
end
print("Active fires: " .. fireCount)
```

## Tactical Implications

### Offensive Uses

1. **Area Denial**: Block enemy movement paths with fire
2. **Damage Over Time**: Force enemies out of cover by setting it ablaze
3. **Smoke Screens**: Use fire to generate smoke for concealment
4. **Flushing**: Drive enemies from wooded areas with spreading fire

### Defensive Uses

1. **Barrier Creation**: Use fire lines to protect flanks
2. **Smoke Cover**: Generate smoke for retreat or repositioning
3. **Vision Denial**: Reduce enemy LOS with heavy smoke
4. **Distraction**: Force enemies to react to environmental threats

### Risks

1. **Friendly Fire**: Your units take 5 HP/turn in flames
2. **Uncontrolled Spread**: Fire spreads randomly, can backfire
3. **Smoke Blocks Both Sides**: Smoke reduces your vision too
4. **Terrain Destruction**: (Future) Fire may destroy cover

## Performance Considerations

### Fire System

- **Tile Storage**: Fire stored as boolean in `tile.effects.fire`
- **Spreading**: O(n) where n = number of fire tiles
- **Iteration**: Only checks tiles currently on fire, not entire map

### Smoke System

- **Tile Storage**: Smoke stored as integer (0-3) in `tile.effects.smoke`
- **Update**: O(m) where m = number of smoke tiles
- **Rendering**: Only draws tiles with smoke > 0

### Optimization Tips

1. **Batch Updates**: Both systems update once per turn, not per frame
2. **Sparse Storage**: Only tiles with effects consume memory
3. **Visual Effects**: Use simple shapes (rectangles) for performance
4. **Limit Spread**: 30% and 20% spread chances prevent exponential growth

## Future Enhancements

### Planned Features

1. **Fire Extinguishing**: Water, foam, or time-based extinguishing
2. **Explosive Reactions**: Fuel/ammo caches explode when on fire
3. **Smoke Grenades**: Deploy smoke without fire
4. **Wind Effects**: Wind direction affects smoke movement
5. **Terrain Damage**: Fire destroys wooden structures over time
6. **Suffocation**: Heavy smoke causes minor damage to units
7. **Panic**: Units may panic when surrounded by fire

### Implementation Notes

- All systems use battlefield coordinate system (1-based Lua indexing)
- Fire and smoke update at **end** of turn (after all actions)
- LOS updates automatically include fire/smoke penalties
- Save/load will need to serialize fire and smoke tile effects

## Troubleshooting

### Fire Not Spreading

1. Check terrain flammability: `TerrainTypes.get(terrainId).flammability`
2. Verify fire system initialized: `fireSystem ~= nil`
3. Check spreading is called: Look for `[FireSystem] Spreading fire...` in console
4. Low flammability + 30% chance = rare spreads (working as designed)

### Smoke Not Appearing

1. Verify fire is active: `battlefield.map[y][x].effects.fire == true`
2. Check smoke production called: `[FireSystem] Producing smoke...` in console
3. Ensure smoke system initialized: `smokeSystem ~= nil`
4. Check rendering order: Fire/smoke drawn after terrain, before units

### Performance Issues

1. Monitor console for fire counts: Should stay < 100 tiles
2. Use F7 to clear if fire spreads out of control
3. Check dissipation working: Smoke should clear over 3-5 turns
4. Reduce fire spread chance if needed (adjust 0.3 constant in fire_system.lua)

## See Also

- [API Documentation](API.md) - Complete API reference for FireSystem and SmokeSystem
- [FAQ](FAQ.md) - Common questions about fire and smoke mechanics
- [Battle Systems](ECS_BATTLE_SYSTEM_API.md) - Integration with other battle systems
