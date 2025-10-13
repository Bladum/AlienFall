# Combat Shooting System - Task Breakdown

**Created:** October 13, 2025  
**Status:** Tasks Planned and Documented  
**Total Tasks:** 5  
**Estimated Total Time:** 76 hours  
**Priority:** High

---

## Overview

This document summarizes the 5 comprehensive tasks created for implementing the complete combat shooting system in Alien Fall. The system covers everything from weapon equipment to projectile physics and miss mechanics.

---

## System Architecture

The combat shooting system is divided into 5 interconnected subsystems:

```
TASK-008: Weapon & Equipment System (Foundation)
    ↓
TASK-009: Range & Accuracy Calculation
    ↓
TASK-010: Cover & Line of Sight System
    ↓
TASK-011: Final Accuracy & Fire Modes
    ↓
TASK-012: Projectile Trajectory & Miss System
```

---

## Task Breakdown

### TASK-008: Weapon and Equipment System
**Status:** TODO  
**Priority:** High  
**Time Estimate:** 13 hours  
**Dependencies:** None (Foundation task)

**Purpose:**
Establishes the core weapon and equipment system. Units can equip weapons in left/right hand, armor, and skills. Weapons have properties like AP cost, EP cost, range, base accuracy, and cooldown. Energy system replaces traditional ammo with regeneration.

**Key Features:**
- Equipment slots: left_weapon, right_weapon, armor, skill
- Weapon properties: AP cost (default 1), EP cost (default 1), range, base accuracy, cooldown (default 0)
- Energy system: consumption on use, slow regeneration per turn
- Example: Pistol (range 15, accuracy 60%) + Knife (range 1, accuracy 90%) + Jacket

**Files Created:**
- `engine/data/weapons.lua` - Weapon definitions
- `engine/data/armor.lua` - Armor definitions
- `engine/data/skills.lua` - Skill definitions
- `engine/systems/weapon_system.lua` - Weapon management
- `engine/systems/equipment_system.lua` - Equipment management
- `engine/battle/systems/energy_system.lua` - Energy consumption/regen
- `engine/battle/systems/cooldown_system.lua` - Cooldown tracking

**Task Document:** `tasks/TODO/TASK-008-weapon-equipment-system.md`

---

### TASK-009: Range and Accuracy Calculation System
**Status:** TODO  
**Priority:** High  
**Time Estimate:** 11 hours  
**Dependencies:** TASK-008

**Purpose:**
Implements range-based accuracy falloff. Weapons maintain 100% accuracy up to 75% of max range, then drop to 50% at max range, and 0% at 125% range. Makes positioning and weapon choice tactical decisions.

**Key Features:**
- **Accuracy Zones:**
  - 0-75% range: 100% of weapon accuracy
  - 75-100% range: Linear drop from 100% to 50%
  - 100-125% range: Linear drop from 50% to 0%
  - Beyond 125%: Cannot shoot
- Hex grid distance calculation
- Range multiplier applied to base weapon accuracy
- UI displays effective accuracy after range modifier

**Example:**
Pistol (base 60%, range 15 tiles) shooting at 12 tiles (80% of max):
- Range zone: 75-100% (in the dropoff zone)
- Range multiplier: 0.9 (90%)
- Effective accuracy: 60% × 0.9 = 54%

**Files Created:**
- `engine/battle/utils/hex_math.lua` - Hex distance functions
- `engine/battle/systems/range_system.lua` - Range calculations
- `engine/battle/systems/accuracy_system.lua` - Accuracy modifiers

**Task Document:** `tasks/TODO/TASK-009-range-accuracy-system.md`

---

### TASK-010: Cover and Line of Sight System
**Status:** TODO  
**Priority:** High  
**Time Estimate:** 19 hours  
**Dependencies:** TASK-008, TASK-009

**Purpose:**
Creates tactical depth through cover mechanics. Raycast from shooter to target, checking each object for cover value. Cover reduces accuracy by 5% per point. Objects with cover ≥20 completely block shots. Sight blockers (sight_cost=99) make targets invisible.

**Key Features:**
- **Cover Mechanics:**
  - Each cover point reduces accuracy by 5%
  - Cover ≥20 blocks shots completely
  - Smoke: cover=1, sight_cost=3 (makes vision harder)
  - Windows: low cover (bullets pass through)
  - Walls: cover=99, sight_cost=99 (total block)
- **Visibility System:**
  - sight_cost=99 makes target invisible
  - Invisible targets suffer -50% accuracy penalty
- Cover from obstacles and effects tracked separately
- Multiple cover sources stack (e.g., 3 smoke clouds = -15% accuracy)

**Example:**
Shooting through 2 smoke clouds and a fence:
- Obstacle cover: 5 (fence)
- Effect cover: 2 (2× smoke)
- Total cover: 7 points
- Accuracy penalty: 7 × 5% = -35%
- Final multiplier: 0.65 (65% of original)

**Why High Accuracy Matters:**
Sniper with 120% base accuracy can overcome penalties:
- 5 points of cover = -25% accuracy
- 120% - 25% = 95% (still at max)
- Normal 60% accuracy would be 35% (barely hit)

**Files Created:**
- `engine/battle/utils/hex_raycast.lua` - Hex raycasting
- `engine/battle/systems/cover_system.lua` - Cover calculation
- `engine/battle/systems/visibility_system.lua` - Visibility tracking
- Integration with `engine/systems/los_system.lua`

**Task Document:** `tasks/TODO/TASK-010-cover-los-system.md`

---

### TASK-011: Final Accuracy and Fire Modes System
**Status:** TODO  
**Priority:** High  
**Time Estimate:** 16 hours  
**Dependencies:** TASK-008, TASK-009, TASK-010

**Purpose:**
Combines all accuracy modifiers into final to-hit calculation. Implements fire modes for tactical variety. Ensures accuracy is always reasonable (5-95%) and predictable (5% increments).

**Key Features:**
- **Complete Accuracy Formula:**
  ```
  base = (unit_accuracy / 100) × weapon_accuracy
  final = base × fire_mode × range × cover × visibility
  final = clamp(final, 5, 95)
  final = snap(final, 5)
  ```
- **Fire Modes:**
  - **Snap Shot:** 1 AP, 100% accuracy, 1 shot, 1 EP
  - **Aimed Shot:** 2 AP, 150% accuracy, 1 shot, 1 EP
  - **Auto Fire:** 2 AP, 75% accuracy, 3 shots, 3 EP
- Accuracy always 5-95% (no impossible or guaranteed shots)
- Snapped to 5% increments (5, 10, 15, ..., 95)
- UI shows detailed breakdown of all modifiers

**Example Calculation:**
- Unit accuracy: 80%
- Weapon: Pistol (60%, range 15)
- Fire mode: Aimed (1.5×)
- Distance: 12 tiles (80% range) → multiplier 0.9
- Cover: 3 obstacle + 1 effect → multiplier 0.8
- Visible: Yes → multiplier 1.0

Calculation:
1. Base: 0.8 × 60 = 48%
2. Fire mode: 48 × 1.5 = 72%
3. Range: 72 × 0.9 = 64.8%
4. Cover: 64.8 × 0.8 = 51.84%
5. Visibility: 51.84 × 1.0 = 51.84%
6. Clamp: 51.84% (in range)
7. Snap: 50% (nearest 5%)

**Final: 50% to hit**

**Files Created:**
- `engine/data/fire_modes.lua` - Fire mode definitions
- `engine/battle/systems/fire_mode_system.lua` - Fire mode logic
- Enhanced `engine/battle/systems/accuracy_system.lua` - Master calculation
- `engine/widgets/accuracy_tooltip.lua` - Accuracy breakdown UI

**Task Document:** `tasks/TODO/TASK-011-final-accuracy-firemodes.md`

---

### TASK-012: Projectile Trajectory and Miss System
**Status:** TODO  
**Priority:** High  
**Time Estimate:** 17 hours  
**Dependencies:** TASK-011

**Purpose:**
Implements satisfying and realistic shooting resolution. Bullets physically travel through battlefield, can be stopped by cover, and miss in believable ways based on accuracy. Provides visual feedback and allows stray bullets to hit unintended targets.

**Key Features:**
- **Hit Resolution:**
  - Roll to-hit using final accuracy
  - Projectile travels directly to target center
  - Each object on path has chance to stop bullet (5% per cover point)
  - Max deviation from hit point: 30°
  - Shooting through windows possible (low cover = low stop chance)
  
- **Miss Resolution:**
  - Deviation angle = 30° × (1 - accuracy / 100)
  - Higher accuracy = closer misses
  - Random direction (one of 6 hex directions)
  - Distance based on deviation angle and range
  - Miss radius = distance × tan(deviation) × random(0.5-1.5)
  - Never lands on target hex (always adjacent)
  
- **Additional Features:**
  - Unintended target collision detection
  - Projectile animation
  - Visual trajectory display
  - Console logging of trajectory

**Miss Examples:**

**High Accuracy Miss (85% accuracy):**
- Deviation: 30° × 0.15 = 4.5°
- Distance: 10 tiles
- Max radius: 10 × tan(4.5°) = 0.8 tiles
- Result: Lands very close to target

**Low Accuracy Miss (25% accuracy):**
- Deviation: 30° × 0.75 = 22.5°
- Distance: 8 tiles
- Max radius: 8 × tan(22.5°) = 3.3 tiles
- Result: Lands 2-5 tiles away from target

**Files Created:**
- `engine/battle/systems/to_hit_system.lua` - Hit/miss roll
- `engine/battle/systems/projectile_system.lua` - Projectile physics
- `engine/battle/systems/miss_system.lua` - Miss deviation calculation
- `engine/battle/systems/collision_system.lua` - Terrain/unit collision
- Enhanced `engine/battle/animation_system.lua` - Projectile animation

**Task Document:** `tasks/TODO/TASK-012-projectile-trajectory-miss.md`

---

## Implementation Order

The tasks must be completed in sequence due to dependencies:

1. **TASK-008** - Foundation (weapons, equipment, energy)
2. **TASK-009** - Add range-based accuracy
3. **TASK-010** - Add cover and LOS
4. **TASK-011** - Combine all modifiers + fire modes
5. **TASK-012** - Implement shooting resolution

Each task builds on the previous, creating a complete and cohesive combat system.

---

## Key Design Principles

### 1. No Ammo Reloading
- Energy system replaces traditional ammo
- Energy consumed on weapon use
- Regenerates slowly each turn
- Simpler than ammo management

### 2. Accuracy Always Reasonable
- Minimum 5% (nothing impossible)
- Maximum 95% (nothing guaranteed)
- Snapped to 5% increments (clean UI)
- Player always knows exact probability

### 3. High Accuracy is Valuable
- Overcomes range penalties
- Shoots through more cover
- Maintains accuracy through smoke
- Example: 120% base can still hit 95% through heavy cover

### 4. Tactical Depth
- Fire modes: speed vs accuracy
- Range: close for accuracy
- Cover: use it or overcome it
- Positioning matters significantly

### 5. Realistic Physics
- Bullets travel through battlefield
- Cover can stop projectiles
- Misses land near target if accurate
- Stray bullets can hit others

---

## Testing Strategy

Each task includes comprehensive testing:

### Unit Tests
- Formula calculations
- Edge cases (zero range, max range, etc.)
- Component integration
- Performance benchmarks

### Integration Tests
- Cross-system interactions
- UI display accuracy
- Full shooting sequence
- Console logging verification

### Manual Testing
- Run with `lovec "engine"`
- Test various scenarios
- Verify UI displays correct info
- Check console for errors
- Use F9 grid overlay for positioning

---

## Documentation

Each task document includes:

- ✅ Complete requirements (functional, technical, acceptance criteria)
- ✅ Step-by-step implementation plan with time estimates
- ✅ Detailed architecture and components
- ✅ Mathematical formulas and examples
- ✅ Code samples with docstrings
- ✅ Testing strategy (unit, integration, manual)
- ✅ Debug instructions (console, visualization)
- ✅ Documentation updates needed (API.md, FAQ.md, etc.)
- ✅ Dependencies and blockers
- ✅ Review checklist

---

## Time Estimates

| Task | Description | Estimated Time |
|------|-------------|----------------|
| TASK-008 | Weapon & Equipment | 13 hours |
| TASK-009 | Range & Accuracy | 11 hours |
| TASK-010 | Cover & LOS | 19 hours |
| TASK-011 | Final Accuracy & Fire Modes | 16 hours |
| TASK-012 | Projectile & Miss | 17 hours |
| **TOTAL** | **Complete Combat System** | **76 hours** |

---

## Files Created

### Task Documents
- `tasks/TODO/TASK-008-weapon-equipment-system.md` (335 lines)
- `tasks/TODO/TASK-009-range-accuracy-system.md` (425 lines)
- `tasks/TODO/TASK-010-cover-los-system.md` (520 lines)
- `tasks/TODO/TASK-011-final-accuracy-firemodes.md` (585 lines)
- `tasks/TODO/TASK-012-projectile-trajectory-miss.md` (545 lines)

### Tracking
- `tasks/tasks.md` - Updated with all 5 tasks in High Priority section

### Summary
- `COMBAT_SYSTEM_TASK_BREAKDOWN.md` - This document

---

## Next Steps

1. **Review** all task documents for completeness
2. **Validate** dependencies and estimates
3. **Begin TASK-008** - Weapon and Equipment System
4. **Follow sequence** through TASK-012
5. **Test thoroughly** at each step
6. **Document** as you go (API.md, FAQ.md)
7. **Update tasks.md** with progress

---

## Notes

- All tasks follow TASK_TEMPLATE.md structure
- All use Love2D console for debugging (`lovec "engine"`)
- All respect mandatory requirements (grid system, temp files, etc.)
- All include comprehensive documentation updates
- All have detailed testing strategies
- All follow Lua/Love2D best practices

---

## Questions or Issues?

Refer to:
- Individual task documents in `tasks/TODO/`
- `tasks/TASK_TEMPLATE.md` for task structure
- `wiki/API.md` for existing systems
- `wiki/DEVELOPMENT.md` for workflow
- `wiki/FAQ.md` for game mechanics

---

**Document Complete**  
**Ready to Begin Implementation**
