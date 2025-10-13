# HEX Grid Tactical Combat - Quick Task Reference

**Master Plan:** [TASK-016-hex-tactical-combat-master-plan.md](TASK-016-hex-tactical-combat-master-plan.md)  
**Created:** October 13, 2025  
**Total Effort:** 208 hours (10+ weeks)  
**Status:** Ready to implement

---

## Implementation Order (21 Sub-Tasks)

### PHASE 1: Core Grid Systems (40 hours)
Foundation layer - everything else depends on these

| Task | System | Priority | Hours | Files to Create/Modify |
|------|--------|----------|-------|------------------------|
| **016A** | Pathfinding with Movement Costs | Critical | 16 | `pathfinding.lua`, `movement_system.lua` |
| **016B** | Distance & Area Calculations | High | 8 | `area_math.lua`, `hex_math.lua` |
| **016C** | Grid Query System | Medium | 8 | `spatial_query.lua` |
| **016D** | Height & Multi-Level Support | Medium | 8 | `height_math.lua`, `hex_system.lua` |

**Deliverable:** Units can pathfind through complex terrain with costs

---

### PHASE 2: Line of Sight & Fire (48 hours)
Vision and targeting systems

| Task | System | Priority | Hours | Files to Create/Modify |
|------|--------|----------|-------|------------------------|
| **016E** | Enhanced Line of Sight | Critical | 12 | `vision_system.lua`, `hex_line.lua` |
| **016F** | Line of Fire System | Critical | 12 | `line_of_fire.lua` |
| **016G** | Cover System | High | 12 | `cover_system.lua`, terrain data |
| **016H** | Raycasting System | High | 8 | `raycast.lua` |
| **016I** | Shooting Through Partial Objects | Medium | 4 | `cover_system.lua`, partial cover data |

**Deliverable:** Units can see, target, and benefit from cover

---

### PHASE 3: Environmental Effects (44 hours)
Dynamic battlefield atmosphere

| Task | System | Priority | Hours | Files to Create/Modify |
|------|--------|----------|-------|------------------------|
| **016J** | Smoke System Enhanced | High | 12 | `smoke_system.lua`, `smoke_cloud.lua` |
| **016K** | Fire System Enhanced | High | 12 | `fire_system.lua`, flammability data |
| **016L** | Destructible Terrain | High | 12 | `terrain_destruction.lua`, durability data |
| **016M** | Explodable Terrain | Medium | 8 | `terrain_destruction.lua`, explodable data |

**Deliverable:** Fire spreads, smoke blocks sight, terrain is destroyed

---

### PHASE 4: Advanced Combat (52 hours)
Complete weapon systems

| Task | System | Priority | Hours | Files to Create/Modify |
|------|--------|----------|-------|------------------------|
| **016N** | Explosion & Area Damage | Critical | 16 | `explosion_system.lua`, `blast_propagation.lua` |
| **016O** | Shrapnel System | High | 12 | `shrapnel_system.lua`, `shrapnel.lua` |
| **016P** | Beam Weapon System | High | 8 | `beam_weapon.lua`, beam weapons data |
| **016Q** | Throwable Trajectory | High | 8 | `trajectory.lua`, `throwing_system.lua` |
| **016R** | Reaction Fire System | Critical | 8 | `reaction_fire.lua`, `movement_system.lua` |

**Deliverable:** All weapon types functional with proper mechanics

---

### PHASE 5: Stealth & Detection (24 hours)
Sound-based gameplay

| Task | System | Priority | Hours | Files to Create/Modify |
|------|--------|----------|-------|------------------------|
| **016S** | Sound System | Medium | 12 | `sound_system.lua`, `sound_event.lua` |
| **016T** | Hearing & Detection | Medium | 8 | `detection_system.lua`, `ai_investigation.lua` |
| **016U** | Stealth Mechanics | Low | 4 | `stealth_system.lua` |

**Deliverable:** Stealth gameplay with sound detection

---

## Critical Path (Must be done in order)

```
HexMath (✅ DONE)
    ↓
016A: Pathfinding → Movement works
    ↓
016B: Area Math → AOE calculations
    ↓
016D: Height Math → 3D positioning
    ↓
016E: Line of Sight → Units can see
    ↓
016F: Line of Fire → Units can target
    ↓
016G: Cover System → Tactical positioning
    ↓
016N: Explosions → Area damage
    ↓
016R: Reaction Fire → Turn-based tactics complete
```

---

## Parallel Development Tracks

These can be worked on simultaneously:

### Track A: Movement & Pathfinding
- 016A → 016C → 016D
- Enables: Unit movement, AI navigation

### Track B: Vision & Combat
- 016E → 016F → 016G → 016H → 016I
- Enables: Targeting, shooting, cover

### Track C: Environment
- 016J → 016K → 016L → 016M
- Enables: Fire, smoke, destruction

### Track D: Advanced Weapons
- 016N → 016O → 016P → 016Q
- Enables: Explosives, beams, grenades

### Track E: Stealth
- 016S → 016T → 016U
- Enables: Sound detection, stealth

---

## Feature Coverage

### ✅ Implemented Features (Polish PL → ENG)
- ✅ **HEX Grid Math** - Podstawowe obliczenia siatki (hex_math.lua)
- ⬜ **Pathfinding with move cost** - Wyszukiwanie ścieżki z kosztem ruchu
- ⬜ **Line of fire** - Linia ognia i wpływ terenu na osłonę
- ⬜ **Raycasting** - Szybkie śledzenie promieni
- ⬜ **Raytracing** - Pełne śledzenie trajektorii
- ⬜ **Shrapnel system** - System odłamków z eksplozji
- ⬜ **Line of sight** - Linia wzroku i wpływ terenu
- ⬜ **Sense of hear** - Słuch, hałas, mechanizmy walki w ukryciu
- ⬜ **Shooting through holes** - Patrzenie i strzelanie przez okna, płoty
- ⬜ **Reaction fire** - Ogień reakcji
- ⬜ **Area calculation** - Obliczenia obszarów
- ⬜ **Distance to** - Odległości
- ⬜ **Smoke model** - Model dymu i jak działa
- ⬜ **Fire model** - Model ognia i jak się rozprzestrzenia
- ⬜ **Destructible terrain** - Zniszczalny teren
- ⬜ **Flammable terrain** - Łatwopalny teren
- ⬜ **Explodable terrain** - Teren wybuchowy
- ⬜ **Area damage explosion** - Fala obrażeń od epicentrum
- ⬜ **Beam weapons** - Broń laserowa
- ⬜ **Throwable trajectory** - Trajektoria rzucanych obiektów

---

## File Organization

### New Utility Files (15 files)
```
engine/battle/utils/
├── pathfinding.lua         [016A]
├── area_math.lua           [016B]
├── height_math.lua         [016D]
├── hex_line.lua            [016E]
├── raycast.lua             [016H]
├── blast_propagation.lua   [016N]
└── trajectory.lua          [016Q] (enhance)
```

### New System Files (12 files)
```
engine/battle/systems/
├── spatial_query.lua       [016C]
├── line_of_fire.lua        [016F]
├── cover_system.lua        [016G]
├── terrain_destruction.lua [016L]
├── shrapnel_system.lua     [016O]
├── beam_weapon.lua         [016P]
├── throwing_system.lua     [016Q]
├── reaction_fire.lua       [016R]
├── sound_system.lua        [016S]
├── detection_system.lua    [016T]
└── stealth_system.lua      [016U]
```

### Enhanced System Files (4 files)
```
engine/battle/systems/
├── movement_system.lua     [016A]
├── vision_system.lua       [016E]
├── smoke_system.lua        [016J]
├── explosion_system.lua    [016N]
```

### New Data Files (6 files)
```
engine/data/
├── terrain_cover_data.lua      [016G]
├── partial_cover_data.lua      [016I]
├── terrain_flammability.lua    [016K]
├── terrain_durability.lua      [016L]
├── explodable_terrain.lua      [016M]
└── sound_levels.lua            [016S]
```

### New Entity Files (3 files)
```
engine/battle/entities/
├── smoke_cloud.lua         [016J]
├── shrapnel.lua            [016O]
└── sound_event.lua         [016S]
```

**Total:** 40+ new/enhanced files

---

## Testing Requirements

### Test Files to Create (21 files)
```
engine/battle/tests/
├── test_pathfinding.lua        [016A]
├── test_area_math.lua          [016B]
├── test_spatial_query.lua      [016C]
├── test_height_math.lua        [016D]
├── test_vision_system.lua      [016E]
├── test_line_of_fire.lua       [016F]
├── test_cover_system.lua       [016G]
├── test_raycast.lua            [016H]
├── test_partial_cover.lua      [016I]
├── test_smoke_system.lua       [016J]
├── test_fire_system.lua        [016K]
├── test_terrain_destruction.lua [016L]
├── test_explodable_terrain.lua [016M]
├── test_explosion_system.lua   [016N]
├── test_shrapnel_system.lua    [016O]
├── test_beam_weapon.lua        [016P]
├── test_throwing_system.lua    [016Q]
├── test_reaction_fire.lua      [016R]
├── test_sound_system.lua       [016S]
├── test_detection_system.lua   [016T]
└── test_stealth_system.lua     [016U]
```

### Integration Test Scenarios
1. **Urban Combat** - Buildings, windows, destructible walls
2. **Fire Fight** - Flammable terrain, smoke, explosions
3. **Stealth Mission** - Sound detection, silent weapons
4. **Artillery Barrage** - Chain explosions, shrapnel

---

## Performance Targets

| System | Target | Critical |
|--------|--------|----------|
| Pathfinding (30 hexes) | < 5ms | < 10ms |
| LOS (per unit pair) | < 1ms | < 2ms |
| Explosion (8 hex radius) | < 10ms | < 20ms |
| Sound propagation | < 2ms | < 5ms |
| Frame rate (20 units) | 60 FPS | 30 FPS |

---

## Documentation Updates Required

### API Documentation (`wiki/API.md`)
- [ ] Pathfinding API
- [ ] Area calculation functions
- [ ] LOS/LOF interfaces
- [ ] Cover system API
- [ ] Explosion system API
- [ ] Sound system API

### Game Mechanics (`wiki/FAQ.md`)
- [ ] How cover works
- [ ] Fire and smoke mechanics
- [ ] Reaction fire rules
- [ ] Sound detection ranges
- [ ] Stealth gameplay tips

### Developer Guide (`wiki/DEVELOPMENT.md`)
- [ ] Adding new terrain types
- [ ] Creating new weapon systems
- [ ] Performance profiling
- [ ] Testing procedures

---

## Quick Start Guide

### For Implementing a Task

1. **Read Master Plan**: [TASK-016-hex-tactical-combat-master-plan.md](TASK-016-hex-tactical-combat-master-plan.md)

2. **Check Dependencies**: Make sure prerequisite tasks are complete

3. **Create Task Document**: Copy template and fill in details
   ```bash
   copy tasks\TASK_TEMPLATE.md tasks\TODO\TASK-016X-name.md
   ```

4. **Write Tests First**: TDD approach
   ```lua
   -- engine/battle/tests/test_system.lua
   local function test_basic_functionality()
       -- Test code here
   end
   ```

5. **Implement System**: Follow architecture in master plan

6. **Run with Console**:
   ```bash
   lovec "engine"
   ```

7. **Profile Performance**: Use Love2D profiler

8. **Update Documentation**: API, FAQ, comments

9. **Mark Complete**: Update tasks.md

---

## Common Patterns

### System Template
```lua
-- system_name.lua
-- Brief description
-- Part of ECS architecture for battle system

local HexMath = require("battle.utils.hex_math")
local Debug = require("battle.utils.debug")

local SystemName = {}

function SystemName.new()
    local self = {
        -- State here
    }
    Debug.print("SystemName", "Initialized")
    return self
end

function SystemName.update(self, dt)
    -- Update logic
end

return SystemName
```

### Utility Function Template
```lua
--- Calculate something useful
-- @param q number: Hex Q coordinate
-- @param r number: Hex R coordinate
-- @param distance number: Distance in hexes
-- @return table: List of hexes in range
function UtilityModule.getSomething(q, r, distance)
    local results = {}
    -- Implementation
    return results
end
```

---

## FAQ

**Q: Where do I start?**  
A: Start with TASK-016A (Pathfinding). It's the most critical foundation piece.

**Q: Can I skip Phase 1 and jump to weapons?**  
A: No. Phases must be done in order due to dependencies.

**Q: Can I work on multiple tasks in parallel?**  
A: Yes, within the same phase or different tracks (see Parallel Development Tracks).

**Q: How do I test HEX grid functions?**  
A: Run `lovec "engine"` with console enabled. Use print statements and visual debug overlay (F9).

**Q: What if a task takes longer than estimated?**  
A: Update the task document with actual time and reasons. Adjust future estimates.

**Q: Where is the HEX grid code?**  
A: `engine/battle/utils/hex_math.lua` and `engine/battle/systems/hex_system.lua`

---

## Reference Links

- **Master Plan**: [TASK-016-hex-tactical-combat-master-plan.md](TASK-016-hex-tactical-combat-master-plan.md)
- **HEX Grid Guide**: [Red Blob Games](https://www.redblobgames.com/grids/hexagons/)
- **X-COM Mechanics**: [UFOpaedia](https://www.ufopaedia.org/)
- **API Docs**: `wiki/API.md`
- **Game FAQ**: `wiki/FAQ.md`
- **Dev Guide**: `wiki/DEVELOPMENT.md`

---

## Progress Tracking

Update this section as tasks are completed:

- [ ] Phase 1: Core Grid Systems (0/4 tasks)
- [ ] Phase 2: Line of Sight & Fire (0/5 tasks)
- [ ] Phase 3: Environmental Effects (0/4 tasks)
- [ ] Phase 4: Advanced Combat (0/5 tasks)
- [ ] Phase 5: Stealth & Detection (0/3 tasks)

**Total Progress: 0/21 tasks (0%)**

---

**Last Updated:** October 13, 2025  
**Next Task:** TASK-016A (Pathfinding with Movement Costs)
