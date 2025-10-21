# Battlescape Systems Quick Reference

**Purpose**: Fast lookup for Battlescape mechanics and systems  
**Audience**: Developers, modders, testers  
**Format**: Quick tables and key information

---

## Damage Models

### Four Damage Models
```
STUN   → 100% stun, 10% morale    | Non-lethal, recovers 2/turn
HURT   → 75% health, 25% stun     | Lethal, permanent damage
MORALE → 100% morale              | Psychological damage only
ENERGY → 80% energy, 20% stun     | Stamina drain, recovers 3/turn
```

### Key Formula
```lua
effectiveDamage = baseDamage * (1 - armorPenetration) * armorValue
statDamage = effectiveDamage * distributionRatio
```

---

## Morale States

### State Thresholds
```
Morale > 40:  NORMAL      (Full control, all actions available)
20 < M < 40:  PANICKED    (Flee behavior, reduced accuracy)
M < 20:       BERSERK     (Attack anything, ignore orders)
M <= 0:       UNCONSCIOUS (No action)
```

### State Triggers
- Damage taken: Lose morale equal to 10% of damage
- Ally dies nearby: Lose 15-20 morale
- Fear effect: Lose 10-25 morale based on source
- Seeing enemy: Minor morale loss (varies by unit)

### Recovery
- Normal: +5 per turn
- After panic: +10 per turn (recovery boost)

---

## Weapon Firing Modes

### Six Available Modes

| Mode | AP Cost | Accuracy | Range | Damage | Usage |
|------|---------|----------|-------|--------|-------|
| SNAP | 12 | -5% | Normal | 1x | Quick shot, moving |
| AIM | 16 | +15% | Normal | 1x | Careful aim |
| LONG | 14 | -10% | 1.5x | 1x | Extended range |
| AUTO | 20 | -15% | Normal | 3x | Multiple shots |
| HEAVY | 18 | -8% | Normal | 2x | Powerful hit |
| FINESSE | 14 | +10% | Normal | 0.8x | Precision targeting |

---

## Accuracy Calculation

### Step-by-Step
1. **Base**: Unit accuracy (60-80%) + weapon modifier (-10% to +10%)
2. **Range**: Linear modifier based on distance (0-125% of max range)
3. **Cover**: -5% per cover point (max -50%)
4. **LOS**: -50% if not visible
5. **Clamp**: Constrain to 5%-95% range

### Example
```
Base accuracy: 70%
Mode modifier: +15% (AIM mode)
Range modifier (8 hexes, 12 max): -5% (20% of max, linear decline)
Cover modifier (2 obstacles): -10%
LOS modifier: 0% (visible)
Final: min(95%, max(5%, 70 + 15 - 5 - 10 + 0)) = 70%
```

---

## Psionic Abilities

### 11+ Abilities Quick List

**Damage**
- `PSI_DAMAGE` - Damage (stun/hurt/morale/energy)
- `PSI_CRITICAL` - Force critical wound

**Terrain**
- `DAMAGE_TERRAIN` - Destroy terrain tile
- `UNCOVER_TERRAIN` - Reveal area
- `MOVE_TERRAIN` - Telekinesis on terrain

**Environment**
- `CREATE_FIRE` - Start fire on tile
- `CREATE_SMOKE` - Create smoke cloud

**Objects**
- `MOVE_OBJECT` - Telekinesis on objects

**Unit Control**
- `MIND_CONTROL` - Take control of enemy
- `SLOW_UNIT` - Reduce AP by 2
- `HASTE_UNIT` - Increase AP by 2

### Psionic Skill Check
```
Attack Roll = Psi Skill × random(0.7 to 1.3)
Defense Roll = Will × random(0.7 to 1.3)
Success = Attack Roll > Defense Roll
```

---

## Cover System

### Cover Values by Obstacle

| Obstacle | Cost | Modifier | Type |
|----------|------|----------|------|
| Small smoke | 2 | -10% | Transparent |
| Large smoke | 4 | -20% | Transparent |
| Small fire | 0 | -0% | Transparent |
| Large fire | 1 | -5% | Transparent |
| Small object | 1 | -5% | Solid |
| Medium object | 2 | -10% | Solid |
| Large object | 4 | -20% | Solid |
| Small unit | 1 | -5% | Solid |
| Medium unit | 2 | -10% | Solid |
| Large unit | 3 | -15% | Solid |

### Cumulative Calculation
```
Total Cover = Sum of all obstacles between shooter and target
Max penalty = -50% (clamped)
Min chance = 5% (always possible hit)
```

---

## Terrain Destruction

### Armor Values

| Terrain | Armor | Material |
|---------|-------|----------|
| Flower/plant | 3 | Plant |
| Wooden wall | 6 | Wood |
| Brick wall | 8 | Stone |
| Stone wall | 10 | Stone |
| Metal wall | 12 | Metal |
| Rubble | 8-12 | Mixed |

### Destruction States
```
UNDAMAGED
    ↓ (damage >= armor)
DAMAGED (reduced armor, visual change)
    ↓ (damage >= damaged_armor)
RUBBLE (floor with destruction visual)
    ↓ (damage >= rubble_armor)
BARE_GROUND (clean floor)
```

### Material Resistance
```
Wood     | +20% Kinetic | +20% Fire  | -20% Explosion
Plant    | +20% Water   | -20% Fire  | -20% Chemical
Stone    | +20% Expl    | +20% Kin   | -20% Energy, -20% Chem
Metal    | +20% Kin     | +20% Expl  | -20% Energy
```

---

## Equipment System

### Armor Types
- **Light**: Lower defense, more mobility
- **Medium**: Balanced
- **Heavy**: Higher defense, less mobility

### Armor Effect on Stats
- Defense: +1-5 points per armor type
- Movement: -2-0 points per armor type
- Accuracy: -1-2 points (encumbrance)

### Skills
- One skill per unit (in current implementation)
- Modify related stats
- Can be replaced with compatible unit class

---

## Line of Sight

### Obstacle Transparency

| Obstacle | Blocks | Partial | Transparent |
|----------|--------|---------|-------------|
| Wall | ✓ | - | - |
| Dense tree | ✓ | - | - |
| Rock | ✓ | - | - |
| Smoke | - | ✓ | - |
| Fire | - | ✓ | - |
| Unit | - | ✓ | - |

### LOS Calculation
- Requires direct line from shooter to target
- Obstacles reduce LOS but may not completely block
- Each obstacle has sight cost that accumulates

---

## Unit Stats

### Combat Stats
```
Health   | Current/Max HP
Stun     | Current stun accumulation
Morale   | Current morale level
Energy   | Stamina/action points
Accuracy | Ranged attack accuracy (base)
Bravery  | Morale loss resistance
Will     | Psionic defense
Armor    | Physical defense
```

### Stat Ranges (Typical)
```
Health: 20-80 (varies by class)
Accuracy: 60-90%
Bravery: 30-100
Will: 30-90
Armor: 0-12 (by type)
```

---

## Unit Classes

### Example Classes (Verify in data files)
- **Soldier**: High health, good accuracy
- **Specialist**: Medium health, high skills
- **Sniper**: Lower health, excellent ranged accuracy
- **Engineer**: Medium health, tech abilities
- **Psion**: Lower health, psionic powers

### Stat Adjustments by Class
- Soldiers get +10% health, +5% accuracy
- Specialists get +15% skills, +5% bravery
- Snipers get +20% ranged accuracy, -10% health
- Engineers get +10% technical stat, normal combat
- Psions get +20% Will, +15% psi skill

---

## Key Formulas

### Damage Application
```lua
armor_reduction = baseDamage * (1 - armorPenetration)
final_damage = armor_reduction * armorDefense
stat_damage = {}
for stat, ratio in pairs(model.distribution) do
    stat_damage[stat] = final_damage * ratio
end
```

### Accuracy Check
```lua
roll = random(0, 100)
if roll <= final_accuracy then
    hit = true
else
    deviation_distance = target_distance * (final_accuracy / 100)
    projectile:deviate(deviation_distance)
end
```

### Morale Change
```lua
morale_loss = base_loss * (1 - bravery/200)
if morale < PANIC_THRESHOLD and random() > (morale/100) then
    enter_panic_state()
elseif morale < BERSERK_THRESHOLD and random() > (morale/100) then
    enter_berserk_state()
end
```

---

## Common Development Tasks

### Add New Weapon Mode
1. Define in `weapon_modes.lua`
2. Add to weapon's available modes
3. Implement accuracy/AP modifiers
4. Add to UI selector

### Add New Damage Model
1. Define in `damage_models.lua`
2. Set distribution ratios
3. Define effects (recovery, can_kill, etc.)
4. Update damage system to recognize

### Add New Psionic Ability
1. Define in `psionics_system.lua`
2. Add to ABILITIES enumeration
3. Create ability definition with cost/range
4. Implement effect in psionics system

### Add New Status Effect
1. Track in unit stats
2. Update each turn in battle loop
3. Add visual indicator
4. Integrate with morale/damage systems

---

## Testing Checklist

**Before Gameplay**:
- [ ] All damage models apply correctly
- [ ] Morale state transitions work
- [ ] All weapon modes available
- [ ] Accuracy modified by all factors
- [ ] Projectiles deviate on miss
- [ ] Cover reduces accuracy
- [ ] Terrain can be destroyed
- [ ] Psionic abilities execute
- [ ] LOS updates correctly
- [ ] Console has no errors

**During Gameplay**:
- [ ] Units respond to damage
- [ ] Units panic at low morale
- [ ] Weapons fire with correct modifiers
- [ ] Environmental effects work
- [ ] AI responds appropriately

---

## File Locations

```
engine/battlescape/combat/
├── damage_models.lua           Damage distribution
├── damage_system.lua           Damage application
├── morale_system.lua           Morale tracking
├── weapon_system.lua           Weapon mechanics
├── weapon_modes.lua            Firing modes
├── psionics_system.lua         Psionic abilities
├── los_system.lua              Line of sight
├── los_optimized.lua           LOS optimization
├── projectile_system.lua       Projectile handling
├── equipment_system.lua        Armor/skills
├── unit.lua                    Unit entity
└── battle_tile.lua             Tile structure
```

---

## Common Errors & Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| Nil damage | Armor doesn't exist | Check armor ID in data |
| Morale stuck | No recovery trigger | Verify update loop called |
| Weapon mode missing | Not in weapon definition | Add to weapon data |
| LOS not updating | Cache not cleared | Verify tile update called |
| Psi ability fails silently | PP cost not met | Check PP balance |

---

## Performance Notes

- LOS calculation optimized with `los_optimized.lua`
- Projectile paths cached when possible
- Damage calculations done once per hit
- Morale checks on state transition only
- Consider profiling if FPS drops below 60

---

## Further Reading

- **Full Wiki**: `wiki/systems/Battlescape.md`
- **Audit Report**: `docs/BATTLESCAPE_AUDIT.md`
- **Testing Guide**: `docs/BATTLESCAPE_TESTING_CHECKLIST.md`
- **API Reference**: `wiki/api/` (create as needed)

---

**Last Updated**: 2025  
**Version**: 1.0 (Based on Audit Complete)
