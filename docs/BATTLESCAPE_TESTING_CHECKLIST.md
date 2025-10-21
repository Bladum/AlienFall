# Battlescape System Manual Testing Checklist

**Purpose**: Verify all Battlescape systems work correctly in-game  
**Prerequisites**: Run game with `lovec "engine"` and monitor console for errors  
**Status**: Use this checklist to validate comprehensive audit findings

---

## 1. Damage System Testing

### Test 1.1: Stun Damage
- [ ] Start a battle mission
- [ ] Have unit take stun damage
- [ ] Verify:
  - [ ] Unit shows stun indicator
  - [ ] Stun value displayed correctly
  - [ ] Unit can still move (stun doesn't block action)
  - [ ] Check console for: `[DamageSystem] Applied STUN damage`
  - [ ] Stun recovers each turn (2 points/turn)

### Test 1.2: Hurt Damage
- [ ] Have unit take hurt damage
- [ ] Verify:
  - [ ] Health value decreases
  - [ ] Max HP reduces (permanent damage)
  - [ ] Unit can be killed with sufficient hurt damage
  - [ ] Check console for damage application messages

### Test 1.3: Morale Damage
- [ ] Have unit take morale damage
- [ ] Verify:
  - [ ] Morale value decreases
  - [ ] Unit displays panic/berserk state if threshold crossed
  - [ ] Recovery over time (5 points/turn)
  - [ ] Affects unit behavior accordingly

### Test 1.4: Energy Damage
- [ ] Have unit take energy damage
- [ ] Verify:
  - [ ] Energy pool drains
  - [ ] AP cost increases as energy depletes
  - [ ] Unit becomes fatigued visually
  - [ ] Energy recovers (3 points/turn)

---

## 2. Morale System Testing

### Test 2.1: Normal State (Morale > 40)
- [ ] Verify unit responds to player commands
- [ ] Unit performs all available actions
- [ ] No panic/berserk behavior

### Test 2.2: Panic State (Morale 20-40)
- [ ] Reduce unit morale to 20-40
- [ ] Verify:
  - [ ] Unit enters panic state
  - [ ] Unit flees from enemies
  - [ ] Unit ignores player commands
  - [ ] Visual indicator shows panic
  - [ ] Console shows: `[MoraleSystem] Unit panicked`

### Test 2.3: Berserk State (Morale < 20)
- [ ] Reduce unit morale below 20
- [ ] Verify:
  - [ ] Unit enters berserk state
  - [ ] Unit attacks nearby enemies
  - [ ] Unit attacks through cover
  - [ ] Unit ignores player commands
  - [ ] Visual indicator shows berserk

### Test 2.4: Morale Recovery
- [ ] Damage unit morale
- [ ] Verify:
  - [ ] Morale recovers 5 points per turn
  - [ ] Recovery continues each turn
  - [ ] Unit returns to normal after threshold
  - [ ] State transitions work correctly

---

## 3. Weapon System Testing

### Test 3.1: Weapon Mode Selection
- [ ] Select a unit with ranged weapon
- [ ] Verify weapon mode selector appears
- [ ] Try each available mode:
  - [ ] SNAP - Quick, less accurate
  - [ ] AIM - Careful, accurate
  - [ ] LONG - Extended range
  - [ ] AUTO - Multiple shots
  - [ ] HEAVY - Powerful attack
  - [ ] FINESSE - Precise targeting

### Test 3.2: Mode Effects on Accuracy
- [ ] SNAP mode: Should show ~-5% accuracy
- [ ] AIM mode: Should show ~+15% accuracy
- [ ] LONG mode: Extended range
- [ ] AUTO mode: Multiple projectiles
- [ ] HEAVY mode: Higher damage
- [ ] FINESSE mode: Precise aiming

### Test 3.3: AP Costs Per Mode
- [ ] Verify each mode costs correct AP
- [ ] Verify AP reduction with correct calculation
- [ ] Verify unit can't execute mode if insufficient AP

### Test 3.4: Weapon Restrictions
- [ ] Melee weapons should only have melee modes
- [ ] Pistols should not have AUTO/HEAVY
- [ ] Sniper rifles should have LONG mode

---

## 4. Accuracy & Targeting Testing

### Test 4.1: Base Accuracy
- [ ] Fire at target with clear line of sight
- [ ] Verify hit frequency matches documented accuracy
- [ ] Try multiple shots to see hit distribution

### Test 4.2: Range Modifiers
- [ ] Fire at close range (0-3 hexes): Should see high accuracy
- [ ] Fire at medium range (6-9 hexes): Medium accuracy
- [ ] Fire at long range (10-12 hexes): Reduced accuracy
- [ ] Fire beyond max range (15+ hexes): Should see low/no hits
- [ ] Console should show range modifier applied

### Test 4.3: Cover Modifiers
- [ ] Target behind partial cover (1 obstacle)
- [ ] Verify accuracy reduced by ~5%
- [ ] Target behind heavy cover (4+ obstacles)
- [ ] Verify accuracy reduced by ~20-50%
- [ ] Check console for cover calculation

### Test 4.4: Line of Sight Penalty
- [ ] Target visible: No penalty
- [ ] Target not visible (behind wall): -50% accuracy
- [ ] Try shooting at blind targets: Should see many misses

---

## 5. Projectile Deviation Testing

### Test 5.1: Miss Deviation
- [ ] Fire at target and intentionally miss
- [ ] Observe projectile path
- [ ] Verify projectile deviates to nearby tile
- [ ] Check deviation distance appropriate
- [ ] Console should show deviation calculation

### Test 5.2: Obstacle Collision
- [ ] Fire projectile through smoke
- [ ] Should sometimes hit smoke instead of target
- [ ] Fire through destructible walls
- [ ] Should sometimes damage wall instead
- [ ] Fire through transparent obstacles
- [ ] Should pass through (no collision)

### Test 5.3: Obstacle Hit Chance
- [ ] Path through cover value 2: 10% hit chance
- [ ] Path through cover value 4: 20% hit chance
- [ ] Verify obstacle hits vary probabilistically

---

## 6. Cover System Testing

### Test 6.1: Smoke Cover
- [ ] Place smoke cloud between shooter and target
- [ ] Small smoke (cover 2): -10% accuracy
- [ ] Large smoke (cover 4): -20% accuracy
- [ ] Verify cumulative with other obstacles

### Test 6.2: Fire Cover
- [ ] Place fire between shooter and target
- [ ] Small fire (cover 0): No accuracy penalty
- [ ] Large fire (cover 1): -5% accuracy
- [ ] Verify fire also damages units passing through

### Test 6.3: Object/Unit Cover
- [ ] Place object as cover
- [ ] Small object: -5% accuracy
- [ ] Medium object: -10% accuracy
- [ ] Large object: -20% accuracy
- [ ] Place unit as cover: Similar modifiers

### Test 6.4: Cumulative Cover
- [ ] Multiple obstacles between shooter/target
- [ ] Verify all cover values sum correctly
- [ ] Total reduced to max (-50%) if appropriate
- [ ] Minimum always 5% hit chance

---

## 7. Terrain Destruction Testing

### Test 7.1: Wooden Wall Destruction
- [ ] Fire at wooden wall (armor 6)
- [ ] Damage less than 6: No effect
- [ ] Damage >= 6: Wall becomes DAMAGED
- [ ] Damage DAMAGED wall with armor 5: Becomes RUBBLE
- [ ] Rubble visual should show destruction

### Test 7.2: Stone Wall Destruction
- [ ] Fire at stone wall (armor 10)
- [ ] Verify same progression: UNDAMAGED → DAMAGED → RUBBLE
- [ ] Verify appropriate armor at each stage

### Test 7.3: Metal Wall Destruction
- [ ] Fire at metal wall (armor 12)
- [ ] Most resistant to destruction
- [ ] Verify high damage required

### Test 7.4: Rubble Properties
- [ ] Destroyed terrain becomes walkable
- [ ] Cannot use as cover (transparent)
- [ ] Visual shows destruction appropriately
- [ ] Can be destroyed further if damaged again

---

## 8. Psionic System Testing

### Test 8.1: Psionic Abilities Available
- [ ] Select unit with psionic ability
- [ ] Verify all 11+ abilities listed:
  - [ ] Psi Damage
  - [ ] Psi Critical
  - [ ] Damage Terrain
  - [ ] Uncover Terrain
  - [ ] Move Terrain
  - [ ] Create Fire
  - [ ] Create Smoke
  - [ ] Move Object
  - [ ] Mind Control
  - [ ] Slow Unit
  - [ ] Haste Unit

### Test 8.2: Psionic Skill Check
- [ ] Use psionic ability on target
- [ ] Verify skill check calculated: Psi Skill vs. Will
- [ ] Check console for: `[PsionicsSystem] Skill check`
- [ ] Sometimes succeeds, sometimes fails
- [ ] Success/failure probability reasonable

### Test 8.3: Psionic Range & LOS
- [ ] Try psionic ability on distant target (beyond range)
- [ ] Should fail or show "out of range"
- [ ] Try on target without LOS
- [ ] Should fail or show "no line of sight"
- [ ] Try on visible target within range
- [ ] Should succeed/fail based on skill check

### Test 8.4: Psionic Effects
- [ ] Psi Damage: Should apply stun/hurt/morale damage
- [ ] Mind Control: Should switch unit allegiance temporarily
- [ ] Slow Unit: Should reduce AP by 2
- [ ] Haste Unit: Should increase AP by 2
- [ ] Create Fire/Smoke: Should place environmental effect

---

## 9. Line of Sight Testing

### Test 9.1: Basic LOS
- [ ] Unit can see adjacent tile: Yes
- [ ] Unit can see through 3 hexes: Yes
- [ ] Unit cannot see through wall: No
- [ ] Unit cannot see through dense forest: No

### Test 9.2: Obstacle Transparency
- [ ] Smoke reduces sight but allows partial vision
- [ ] Fire reduces sight but allows partial vision
- [ ] Walls completely block vision
- [ ] Dense trees block vision

### Test 9.3: LOS Updating
- [ ] Move unit: LOS updates
- [ ] Destroy wall: LOS changes
- [ ] Create smoke: LOS partially blocked
- [ ] Smoke clears: LOS restores

---

## 10. Equipment System Testing

### Test 10.1: Armor Equipping
- [ ] Equip armor on unit
- [ ] Verify armor changes in unit display
- [ ] Check stats update: armor value changes
- [ ] Try equipping different armor: Works correctly

### Test 10.2: Armor Effects
- [ ] Light armor: Lower defense, more mobility
- [ ] Heavy armor: Higher defense, less mobility
- [ ] Verify damage reduction based on armor

### Test 10.3: Skill Equipping
- [ ] Equip skill on unit (if multiple skills allowed)
- [ ] Verify skill activation
- [ ] Check related stat modifications

---

## 11. Integration Testing

### Test 11.1: Full Damage Pipeline
- [ ] Unit shoots enemy with specific weapon/mode
- [ ] Follow complete chain:
  - [ ] Weapon selected with firing mode
  - [ ] Accuracy calculated with all modifiers
  - [ ] Projectile fired and deviation checked
  - [ ] Target hit or missed
  - [ ] If hit: Armor calculated
  - [ ] If armor penetrated: Damage model applied
  - [ ] Unit stats modified accordingly
  - [ ] Morale impact calculated
  - [ ] Status effects applied

### Test 11.2: Battle Flow
- [ ] Start mission
- [ ] Deploy squad
- [ ] Execute multiple rounds:
  - [ ] Units take turns
  - [ ] Damage applied correctly
  - [ ] Morale changes tracked
  - [ ] Environmental effects apply
  - [ ] Psionic abilities available
  - [ ] Terrain destruction works
  - [ ] Mission objectives progress

### Test 11.3: Console Logging
- [ ] Monitor console throughout mission
- [ ] Verify all systems logging:
  - [ ] Weapon firing
  - [ ] Accuracy calculations
  - [ ] Damage application
  - [ ] Morale changes
  - [ ] Psionic activation
  - [ ] No errors or warnings

---

## 12. Console Verification (Critical)

While running game with `lovec "engine"`, verify:

- [ ] Game loads without errors
- [ ] Console shows initialization messages
- [ ] Console shows damage calculations when weapons fire
- [ ] Console shows morale changes
- [ ] Console shows psionic attempts
- [ ] Console shows LOS calculations
- [ ] No stack traces visible
- [ ] No nil reference errors
- [ ] No table access errors
- [ ] FPS remains stable (60+)

**Watch for errors like**:
- ❌ `[ERROR] attempt to index a nil value`
- ❌ `[ERROR] bad argument to 'add'`
- ❌ Stack traces in output
- ❌ "Cannot find module" errors

---

## Summary Checklist

### Core Systems Verified
- [ ] Damage models (STUN, HURT, MORALE, ENERGY)
- [ ] Morale system (NORMAL, PANIC, BERSERK, UNCONSCIOUS)
- [ ] Weapon modes (6 modes tested)
- [ ] Accuracy calculation (base, range, cover, LOS)
- [ ] Projectile deviation (miss handling, collision)
- [ ] Cover system (smoke, fire, objects, cumulative)
- [ ] Terrain destruction (progression, materials)
- [ ] Psionic system (11+ abilities, skill checks)
- [ ] Equipment system (armor, skills)
- [ ] Line of sight (visibility, obstacles)
- [ ] Integration (full damage pipeline)
- [ ] Console logging (no errors)

### Final Sign-Off

- [ ] All systems working correctly
- [ ] No console errors
- [ ] Performance acceptable (60+ FPS)
- [ ] Gameplay feels balanced
- [ ] No game-breaking bugs
- [ ] Ready for production testing

---

**Testing Date**: _______________  
**Tester**: _______________  
**Issues Found**: _______________  
**Notes**: _______________
