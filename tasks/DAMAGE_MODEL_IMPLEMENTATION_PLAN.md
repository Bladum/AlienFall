# Damage Model - Complete Implementation Plan

**Created:** October 13, 2025  
**Author:** AI Agent  
**Status:** Planning Complete - Ready for Implementation

---

## Overview

This document provides a comprehensive overview of the damage model implementation for Alien Fall. The damage model consists of three interconnected systems that handle all aspects of combat damage from weapon fire to explosion effects.

---

## System Architecture

```
COMBAT FLOW:
1. Weapon Fire → Creates Projectile (TASK-013)
2. Projectile Travels → Hits Target or Terrain
3. Impact Detection → Triggers Damage Resolution
4. Damage Type Check:
   - POINT DAMAGE → DamageSystem (TASK-014)
   - AREA DAMAGE → ExplosionSystem (TASK-015) → DamageSystem
5. Apply Damage to Units/Terrain
6. Secondary Effects → Wounds, Morale Loss, Fire, Smoke
```

---

## Three Core Systems

### 1. Projectile System (TASK-013)
**Purpose:** Universal projectile entity for all ranged attacks

**Key Features:**
- All weapons (guns, lasers, grenades) create projectiles
- Projectiles travel from shooter to target position
- Collision detection with units and terrain
- Support for point and area damage types
- Visual animation during flight

**Files:**
- `engine/battle/systems/projectile_system.lua`
- `engine/battle/entities/projectile.lua`
- `engine/battle/utils/trajectory.lua`

**Task Document:** `tasks/TODO/TASK-013-projectile-system.md`

---

### 2. Damage Resolution System (TASK-014)
**Purpose:** Calculate and apply damage with armor modifiers

**Damage Calculation Steps:**
1. **Resistance Modifier:** `effectivePower = weaponPower / armorResistance`
   - Example: 5 power vs 50% resistance = 5 / 0.5 = 10 effective power
2. **Armor Subtraction:** `finalDamage = effectivePower - armorValue`
   - Example: 10 effective - 2 armor = 8 final damage
3. **Distribution:** Split damage across pools based on weapon ratios
   - Example: 8 damage × 75% health = 6 HP damage
   - Example: 8 damage × 25% stun = 2 stun damage
4. **Critical Hits:** Roll for wounds (bleeding 1 HP/turn)
5. **Morale Loss:** Bravery checks to avoid morale damage
6. **Death/Unconsciousness:** Check if unit dies or falls unconscious

**Damage Types:**
- Kinetic (bullets, physical projectiles)
- Explosive (grenades, rockets)
- Laser (energy weapons)
- Fire (incendiary)
- Melee (close combat)
- Bio (biological agents)
- Acid (corrosive)
- Stun (non-lethal)
- Psi (psychic attacks)

**Files:**
- `engine/battle/systems/damage_system.lua`
- `engine/battle/systems/morale_system.lua`
- `engine/battle/systems/damage_types.lua`

**Task Document:** `tasks/TODO/TASK-014-damage-resolution-system.md`

---

### 3. Explosion Area Damage System (TASK-015)
**Purpose:** Handle area-of-effect explosions with propagating damage

**Explosion Mechanics:**
1. **Epicenter:** Full power at impact point (e.g., 10)
2. **Ring 1:** 6 adjacent tiles at power - dropoff (e.g., 8)
3. **Ring 2+:** Propagate to 3 neighbors each
4. **Obstacles:** Units and terrain absorb power
   - Wall (armor=5): 8 power - 5 = 3 continues
   - Unit (armor=2): 8 power - 2 = 6 continues
5. **Overlapping Waves:** Highest power wins
6. **Chain Explosions:** Explosive terrain triggers new explosions
7. **Animation:** Visual rings expand with 50-60ms delays
8. **Environmental Effects:** Create fire and smoke

**Power Propagation Example:**
```
Grenade: power=10, drop=2

Ring 0 (epicenter): power=10 → damages at 10
Ring 1 (6 tiles):   power=8  → damages at 8
Ring 2:             power=6  → damages at 6
Ring 3:             power=4  → damages at 4
Ring 4:             power=2  → damages at 2
Ring 5:             power=0  → stops
```

**Obstacle Blocking:**
```
Ring 1 tile has stone wall (armor=5):
- Incoming power: 8
- Wall absorption: 8 - 5 = 3
- Continues at: 3 - 2 (dropoff) = 1
- Next ring gets power=1 (weak but continues)

Ring 1 tile has heavy unit (armor=7):
- Incoming power: 8
- Unit absorption: 8 - 7 = 1
- Continues at: 1 - 2 (dropoff) = -1
- Propagation stops (no negative power)
```

**Files:**
- `engine/battle/systems/explosion_system.lua`
- Integration with fire_system.lua and smoke_system.lua

**Task Document:** `tasks/TODO/TASK-015-explosion-area-damage-system.md`

---

## Complete Damage Flow Examples

### Example 1: Pistol Shot (Point Damage)

**Setup:**
- Weapon: Pistol (power=5, kinetic, 75% health / 25% stun, 5% crit)
- Target: Soldier with Medium Armor (resistance={kinetic=0.5}, armor=2)

**Flow:**
1. Player fires pistol → ProjectileSystem creates projectile
2. Projectile travels to target tile
3. Projectile hits → calls DamageSystem.resolveDamage()
4. **Damage Calculation:**
   - Base power: 5 (kinetic)
   - Armor resistance to kinetic: 50%
   - Effective power: 5 / 0.5 = **10**
   - Armor value: 2
   - Final damage: 10 - 2 = **8**
   - Distribution: 75% health, 25% stun
   - Health damage: 8 × 0.75 = **6 HP**
   - Stun damage: 8 × 0.25 = **2 stun**
5. **Critical Hit Roll:** 23% > 5%, no critical
6. **Apply Damage:** Unit loses 6 HP, gains 2 stun
7. **Morale Check:** Bravery roll, loses 3 morale on failure

**Console Output:**
```
[ProjectileSystem] Projectile created: pistol → (15,20)
[ProjectileSystem] Projectile impact at (15,20)
[DamageSystem] Weapon power: 5, type: kinetic
[DamageSystem] Armor resistance: 50%, effective: 10
[DamageSystem] Armor value: 2, final damage: 8
[DamageSystem] Distribution: 6 health, 2 stun
[Unit] Soldier took 6 HP damage (44/50), 2 stun (2/100)
[MoraleSystem] Morale loss: 3 (67/70)
```

---

### Example 2: Grenade Explosion (Area Damage)

**Setup:**
- Weapon: Fragmentation Grenade (power=10, drop=2, explosive)
- Map: Mix of open tiles, walls (armor=5), units (armor=2,3)

**Flow:**
1. Player throws grenade → ProjectileSystem creates projectile
2. Projectile travels with arc trajectory
3. Projectile lands → calls ExplosionSystem.createExplosion()
4. **Explosion Propagation:**
   - **Ring 0 (epicenter at 10,15):**
     - Power: 10
     - Damages terrain and any unit at epicenter
   - **Ring 1 (6 adjacent tiles):**
     - Power: 10 - 2 = 8
     - Tile (11,15): Open grass → continues at 8-2=6
     - Tile (10,16): Stone wall (armor=5) → 8-5=3 → continues at 3-2=1
     - Tile (9,15): Soldier (armor=2) → damages soldier, continues at 8-2-2=4
     - Tile (10,14): Open → continues at 6
     - etc.
   - **Ring 2:**
     - Propagates from Ring 1 tiles
     - Power varies by path (6, 4, 2, 1)
   - **Ring 3:** Power 4, 2
   - **Ring 4:** Power 2
   - **Ring 5:** Power 0, stops
5. **Apply Damage to All Units:**
   - Soldier at (9,15): Takes 8 explosive damage via DamageSystem
   - Alien at (11,16): Takes 6 explosive damage via DamageSystem
   - Units further out: Take 4, 2 damage
6. **Chain Explosions:**
   - Explosive barrel at (11,16) destroyed → queues new explosion
7. **Environmental Effects:**
   - Fire created at epicenter (wooden floor)
   - Smoke created on multiple tiles (grass terrain)
8. **Animation:**
   - Ring 0 drawn at t=0ms
   - Ring 1 drawn at t=55ms
   - Ring 2 drawn at t=110ms
   - etc.

**Console Output:**
```
[ProjectileSystem] Grenade impact at (10,15)
[ExplosionSystem] Explosion: epicenter=(10,15), power=10, drop=2
[ExplosionSystem] Ring 0: 1 tiles at power 10
[ExplosionSystem] Ring 1: 6 tiles at power 8
[ExplosionSystem]   Tile (9,15): Soldier (armor=2), damage=8, continues at 4
[DamageSystem] Resolving damage: soldier takes 8 explosive
[DamageSystem] Effective power: 8 / 0.6 = 13
[DamageSystem] Final damage: 13 - 2 = 11 HP
[Unit] Soldier took 11 HP damage (39/50)
[ExplosionSystem]   Tile (10,16): Wall (armor=5), blocked: 8-5=3, continues at 1
[ExplosionSystem] Ring 2: 4 tiles (2 blocked)
[ExplosionSystem] Ring 3: 3 tiles
[ExplosionSystem] Ring 4: 2 tiles
[ExplosionSystem] Ring 5: power=0, stopping
[ExplosionSystem] Chain explosion: explosive barrel at (11,16)
[FireSystem] Fire started at (10,15)
[SmokeSystem] Smoke created at (9,15), (11,15), (10,14)
```

---

### Example 3: Critical Hit with Wound

**Setup:**
- Weapon: Sniper Rifle (power=8, kinetic, 15% crit chance)
- Target: Alien (light armor, resistance={kinetic=0.7}, armor=1)

**Flow:**
1. Shot hits target
2. **Damage Calculation:**
   - Effective power: 8 / 0.7 = 11
   - Final damage: 11 - 1 = 10 HP
3. **Critical Hit Roll:** 12% < 15% → **CRITICAL HIT!**
4. Apply 10 HP damage
5. Apply 1 WOUND to target
6. **Bleeding Effect:** Target loses 1 HP per turn until treated

**Turn Sequence:**
```
Turn 1: Critical hit → 10 HP damage + 1 wound (40/50 HP, 1 wound)
Turn 2: Bleeding → 1 HP loss (39/50 HP, 1 wound)
Turn 3: Bleeding → 1 HP loss (38/50 HP, 1 wound)
Turn 4: Medic treats wound (38/50 HP, 0 wounds, bleeding stopped)
```

---

## Data Structure Extensions

### Weapon TOML Updates
```toml
[weapons.pistol]
id = "pistol"
name = "Pistol"
type = "ranged"
damage = 5
damageType = "kinetic"        # NEW: damage type for resistance
healthRatio = 0.75            # NEW: 75% to health
stunRatio = 0.25              # NEW: 25% to stun
criticalChance = 0.05         # NEW: 5% crit chance
projectileSpeed = 500         # NEW: pixels per second
range = 12
base_accuracy = 60

[weapons.grenade]
id = "grenade"
name = "Fragmentation Grenade"
type = "grenade"
damage = 10
damageType = "explosive"
explosionPower = 10           # NEW: power at epicenter
explosionDrop = 2             # NEW: power reduction per ring
healthRatio = 1.0
stunRatio = 0.0
criticalChance = 0.0
projectileSpeed = 300
projectileArc = true          # NEW: uses arc trajectory
```

### Armor TOML Updates
```toml
[armours.medium_armour]
id = "medium_armour"
name = "Medium Armour"
type = "medium"
armourValue = 2
resistances = {               # NEW: resistance by damage type
    kinetic = 0.5,            # 50% resistance (divide power by 0.5)
    explosive = 0.6,          # 40% more effective vs armor
    laser = 0.8,              # 20% more effective
    fire = 0.7,
    melee = 0.5
}
weight = 4
mobilityPenalty = 1
```

### Unit Entity Updates
```lua
-- In unit.lua
unit.wounds = 0               -- NEW: wound count for bleeding
unit.morale = unit.maxMorale  -- NEW: current morale
unit.stun = 0                 -- NEW: stun damage
unit.bleeding = 0             -- NEW: HP loss per turn from wounds
```

---

## Implementation Order

### Phase 1: Foundation (TASK-013)
**Goal:** Get projectiles working
1. Create projectile entity structure
2. Implement ProjectileSystem
3. Add trajectory calculation
4. Add collision detection
5. Integrate with weapon fire
6. Add visual rendering
7. Test projectile flight

**Outcome:** Firing weapon creates visible projectile that travels and hits target

---

### Phase 2: Basic Damage (TASK-014)
**Goal:** Damage calculation with armor
1. Define damage types
2. Implement core damage calculation (resistance + armor)
3. Add damage distribution to pools
4. Integrate with projectile impact
5. Test basic damage flow
6. Add critical hits and wounds
7. Implement morale system

**Outcome:** Projectile impact applies calculated damage to units

---

### Phase 3: Explosions (TASK-015)
**Goal:** Area damage with propagation
1. Create explosion data structure
2. Implement propagation algorithm (flood-fill)
3. Add obstacle absorption
4. Apply damage to units in area
5. Implement chain explosions
6. Integrate fire/smoke creation
7. Add visual ring animation
8. Test explosion scenarios

**Outcome:** Grenades create expanding explosions that damage multiple units

---

## Testing Strategy

### Unit Tests
Each task has comprehensive unit tests:
- **TASK-013:** Projectile creation, movement, collision
- **TASK-014:** Damage calculations, distributions, criticals
- **TASK-015:** Propagation algorithm, absorption, chains

### Integration Tests
- Fire weapon → projectile → damage → unit health change
- Throw grenade → explosion → area damage → multiple units damaged
- Critical hit → wound → bleeding over turns
- Chain explosion → sequential explosions

### Manual Testing with Console
All systems must work with Love2D console enabled (`lovec "engine"`):
```bash
lovec "engine"
```

Console shows detailed debug output for all calculations:
- Projectile creation and impact
- Damage calculations step-by-step
- Explosion propagation ring-by-ring
- Morale checks and wound applications

---

## Documentation Requirements

### API Documentation (wiki/API.md)
- ProjectileSystem API
- DamageSystem API
- ExplosionSystem API
- MoraleSystem API
- All public methods documented

### Mechanics Documentation (wiki/)
- Damage calculation formulas with examples
- Damage type vs armor resistance tables
- Explosion propagation mechanics
- Critical hits and wounds
- Morale system

### Code Documentation
- Full LuaDoc comments on all functions
- @param, @return, @class tags
- Usage examples in docstrings
- README.md in each system folder

---

## Performance Considerations

### Optimizations
- Projectile pool (reuse projectile entities)
- Explosion power map caching
- Morale check batching
- Damage calculation caching for same weapon+armor

### Expected Performance
- Projectile update: <1ms per projectile
- Damage calculation: <0.5ms per unit
- Explosion propagation: <5ms for typical grenade
- No frame drops during combat

---

## Future Enhancements

### Post-MVP Features
- Damage randomization (80-120% of base)
- Over-penetration mechanics
- Armor degradation over time
- Damage falloff with range
- Damage vulnerabilities (negative resistance)
- Projectile deflection/ricochet
- Homing projectiles
- Multi-stage explosions

---

## Success Criteria

### Minimum Viable Product
- [x] Task documents created with full specifications
- [ ] All three systems implemented
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] Manual testing with console successful
- [ ] No crashes or errors
- [ ] Documentation complete
- [ ] Performance acceptable (<16ms per frame)

### Quality Standards
- Clean, modular code
- Comprehensive error handling
- Detailed console debug output
- Full LuaDoc comments
- Test coverage >80%
- No hardcoded values (use TOML)

---

## Blockers and Dependencies

### No External Blockers
All tasks can be implemented independently using existing systems:
- Battlefield for unit/terrain queries
- FireSystem already exists
- SmokeSystem already exists
- AnimationSystem already exists
- WeaponSystem already exists

### Task Dependencies
- TASK-014 depends on TASK-013 (projectiles trigger damage)
- TASK-015 depends on TASK-014 (explosions use damage system)

---

## Task Status Summary

| Task | Status | Priority | Estimated Time | Files |
|------|--------|----------|----------------|-------|
| TASK-013 | TODO | High | 16 hours | projectile_system.lua, projectile.lua, trajectory.lua |
| TASK-014 | TODO | High | 18 hours | damage_system.lua, morale_system.lua, damage_types.lua |
| TASK-015 | TODO | High | 21 hours | explosion_system.lua |
| **Total** | | | **55 hours** | **7 new files + TOML updates** |

---

## Conclusion

The damage model is fully planned and ready for implementation. All three tasks have detailed specifications, step-by-step plans, comprehensive testing strategies, and clear success criteria. The systems are modular and can be implemented incrementally, with each task building on the previous one.

The implementation will provide a complete combat damage system supporting:
- ✅ Unified projectile system for all weapons
- ✅ Sophisticated damage calculation with armor modifiers
- ✅ Area-of-effect explosions with realistic propagation
- ✅ Secondary effects (wounds, morale, fire, smoke)
- ✅ Visual feedback and animation
- ✅ Full moddability via TOML files

**Next Step:** Begin implementation with TASK-013 (Projectile System).
