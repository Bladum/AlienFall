# HEX Grid Tactical Combat Implementation - Planning Summary

**Date:** October 13, 2025  
**Status:** Planning Complete - Ready to Implement  
**Total Effort:** 208 hours (10+ weeks @ 20h/week)

---

## What Was Created

### 📋 Master Planning Document
**File:** `tasks/TODO/TASK-016-hex-tactical-combat-master-plan.md`

A comprehensive 20+ system implementation plan covering:
- Complete feature breakdown (21 sub-tasks)
- Architecture design and file organization
- Data structures and algorithms
- Testing strategy and performance targets
- Documentation requirements
- Risk assessment and dependencies

### 🎯 Quick Reference Guide
**File:** `tasks/HEX_COMBAT_QUICK_REFERENCE.md`

Fast-access reference including:
- Implementation order and priorities
- Critical path visualization
- Parallel development tracks
- File organization structure
- Testing requirements
- Progress tracking

### 📝 Example Task Document
**File:** `tasks/TODO/TASK-016A-pathfinding-system.md`

Detailed task template showing:
- Step-by-step implementation plan
- Complete code examples and pseudocode
- Comprehensive testing strategy
- Debug and profiling techniques
- Documentation requirements
- Review checklist

### 📊 Task Tracking Update
**File:** `tasks/tasks.md`

Added TASK-016 as critical priority task with:
- Master plan reference
- Phase breakdown
- Time estimates
- Sub-task overview

---

## Feature Coverage - Complete System

### ✅ Covered Systems (21 systems)

#### Phase 1: Core Grid Systems (4 systems)
1. **Pathfinding** - A* with terrain costs, TU consumption, multi-turn planning
2. **Distance & Area** - Radius, ring, cone, arbitrary shape calculations
3. **Grid Query** - Spatial queries with performance indexing
4. **Height System** - Multi-level support, elevation effects

#### Phase 2: Line of Sight & Fire (5 systems)
5. **Line of Sight** - Vision with partial blocking, height, darkness
6. **Line of Fire** - Fire trajectory with obstacles and hit probability
7. **Cover System** - Direction-based cover, destructible, flanking
8. **Raycasting** - Fast ray intersection for instant hit weapons
9. **Partial Cover** - Windows, fences, grates with hit chance reduction

#### Phase 3: Environmental Effects (4 systems)
10. **Smoke System** - Multi-level propagation, wind, dissipation, LOS blocking
11. **Fire System** - Spread algorithm, intensity levels, smoke generation
12. **Destructible Terrain** - HP, armor, destruction states, chain effects
13. **Explodable Terrain** - Secondary explosions, chain reactions

#### Phase 4: Advanced Combat (5 systems)
14. **Explosion System** - Power propagation, dropoff, blast waves, animation
15. **Shrapnel System** - Multi-projectile fragments from explosions
16. **Beam Weapons** - Instant hit lasers with penetration
17. **Throwable Trajectory** - Arc trajectory for grenades and thrown items
18. **Reaction Fire** - Opportunity fire during enemy movement

#### Phase 5: Stealth & Detection (3 systems)
19. **Sound System** - Noise generation, propagation, radius calculation
20. **Hearing & Detection** - Multi-sensor detection without LOS
21. **Stealth Mechanics** - Hidden movement, light levels, camouflage

---

## Polish to English Feature Mapping

All requested Polish features are covered:

| Polish Feature | English System | Task ID |
|----------------|----------------|---------|
| Pathfinding with move cost | Enhanced Pathfinding | 016A |
| Line of fire i osłona | Line of Fire + Cover | 016F + 016G |
| Raycasting | Raycasting System | 016H |
| Raytracing | Raycasting (same) | 016H |
| Shrapnel system | Shrapnel System | 016O |
| Line of sight | Line of Sight | 016E |
| Sense of hear, noise | Sound + Detection | 016S + 016T |
| Patrzenie przez okno/plot | Partial Cover Shooting | 016I |
| Reaction fire | Reaction Fire | 016R |
| Area calculation | Distance & Area Math | 016B |
| Distance to | Distance Calculations | 016B |
| Smoke model | Smoke System | 016J |
| Fire model | Fire System | 016K |
| Destructible terrain | Destructible Terrain | 016L |
| Flammable terrain | Fire System | 016K |
| Explodable terrain | Explodable Terrain | 016M |
| Area damage explosion | Explosion System | 016N |
| Beam weapon (laser) | Beam Weapon System | 016P |
| Throwable trajectory | Throwable Trajectory | 016Q |

**Coverage: 100% - All requested features planned**

---

## Implementation Strategy

### Critical Path (Must Follow)
```
✅ HexMath (Already Done)
    ↓
016A: Pathfinding (16h)
    ↓
016B: Area Math (8h)
    ↓
016D: Height (8h)
    ↓
016E: Line of Sight (12h)
    ↓
016F: Line of Fire (12h)
    ↓
016G: Cover System (12h)
    ↓
016N: Explosions (16h)
    ↓
016R: Reaction Fire (8h)
```

### Parallel Tracks (Can Work Simultaneously)

**Track A - Movement:**
- 016A → 016C → 016D (32 hours)

**Track B - Vision:**
- 016E → 016F → 016G → 016H → 016I (48 hours)

**Track C - Environment:**
- 016J → 016K → 016L → 016M (44 hours)

**Track D - Weapons:**
- 016N → 016O → 016P → 016Q (44 hours)

**Track E - Stealth:**
- 016S → 016T → 016U (24 hours)

---

## File Structure - What Will Be Created

### 📁 New Utility Files (15 files)
```
engine/battle/utils/
├── pathfinding.lua           [016A] - A* pathfinding
├── area_math.lua             [016B] - Area calculations
├── height_math.lua           [016D] - Elevation math
├── hex_line.lua              [016E] - Bresenham for hexes
├── raycast.lua               [016H] - Ray intersection
├── blast_propagation.lua     [016N] - Explosion waves
└── trajectory.lua (enhance)  [016Q] - Arc trajectories
```

### 📁 New System Files (12 files)
```
engine/battle/systems/
├── spatial_query.lua         [016C] - Grid queries
├── line_of_fire.lua          [016F] - Fire trajectory
├── cover_system.lua          [016G] - Cover calculation
├── terrain_destruction.lua   [016L] - Destructible terrain
├── shrapnel_system.lua       [016O] - Shrapnel
├── beam_weapon.lua           [016P] - Laser weapons
├── throwing_system.lua       [016Q] - Grenades
├── reaction_fire.lua         [016R] - Opportunity fire
├── sound_system.lua          [016S] - Sound events
├── detection_system.lua      [016T] - Multi-sensor
└── stealth_system.lua        [016U] - Stealth
```

### 📁 Enhanced System Files (4 files)
```
engine/battle/systems/
├── movement_system.lua       [016A] - Add pathfinding
├── vision_system.lua         [016E] - Enhance LOS
├── smoke_system.lua          [016J] - Enhance propagation
└── explosion_system.lua      [016N] - Add area damage
```

### 📁 New Data Files (6 files)
```
engine/data/
├── terrain_movement_costs.lua    [016A]
├── terrain_cover_data.lua        [016G]
├── partial_cover_data.lua        [016I]
├── terrain_flammability.lua      [016K]
├── terrain_durability.lua        [016L]
├── explodable_terrain.lua        [016M]
└── sound_levels.lua              [016S]
```

### 📁 New Entity Files (3 files)
```
engine/battle/entities/
├── smoke_cloud.lua           [016J]
├── shrapnel.lua              [016O]
└── sound_event.lua           [016S]
```

### 📁 Test Files (21 files)
```
engine/battle/tests/
├── test_pathfinding.lua
├── test_area_math.lua
├── test_spatial_query.lua
├── (... 18 more test files ...)
```

**Total: 61+ new/enhanced files**

---

## Architecture Highlights

### Layer Separation
```
┌─────────────────────────────────────┐
│   Game Layer (modules/)             │
│   - Battlescape UI                  │
│   - Player input handling           │
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│   System Layer (battle/systems/)    │
│   - Game logic                      │
│   - State management                │
│   - Component coordination          │
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│   Utility Layer (battle/utils/)     │
│   - Pure algorithms                 │
│   - Math functions                  │
│   - No game state                   │
└─────────────┬───────────────────────┘
              │
┌─────────────▼───────────────────────┐
│   Data Layer (data/, entities/)     │
│   - Configuration                   │
│   - Entity definitions              │
│   - Constants                       │
└─────────────────────────────────────┘
```

### Design Principles
1. **Pure Functions**: Utilities have no side effects
2. **Loose Coupling**: Systems communicate via interfaces
3. **Data-Driven**: Behavior defined in data files
4. **Testable**: Each layer can be tested independently
5. **Performant**: Spatial indexing, caching, pooling

---

## Performance Targets

| System | Target | Critical | Notes |
|--------|--------|----------|-------|
| Pathfinding (30 hexes) | < 5ms | < 10ms | With obstacles |
| LOS (per pair) | < 1ms | < 2ms | Cached when possible |
| LOF calculation | < 2ms | < 5ms | With cover check |
| Explosion (8 radius) | < 10ms | < 20ms | Full propagation |
| Sound propagation | < 2ms | < 5ms | Through walls |
| Smoke dissipation | < 1ms | < 2ms | Per update |
| Frame rate (20 units) | 60 FPS | 30 FPS | With effects |

---

## Testing Strategy Summary

### Test Pyramid
```
              Unit Tests (21 files)
             /                     \
        Integration Tests (4 scenarios)
       /                                 \
  Manual Gameplay Tests (7 scenarios)
```

### Coverage Goals
- **Utilities**: 90%+ code coverage
- **Systems**: 80%+ code coverage
- **Integration**: All critical paths tested
- **Manual**: All player-facing features verified

### Test Scenarios
1. **Urban Combat** - Buildings, destruction, windows
2. **Fire Fight** - Flames spread, smoke propagation
3. **Stealth Mission** - Sound detection, silence
4. **Artillery** - Chain explosions, shrapnel

---

## Documentation Deliverables

### Wiki Updates Required
- **API.md**: All 21 systems documented with examples
- **FAQ.md**: Player-facing mechanics explained
- **DEVELOPMENT.md**: Adding new systems guide

### Code Documentation
- Google-style docstrings on all public functions
- Module-level overview comments
- Algorithm explanations
- Usage examples

### README Files
- Update `engine/battle/README.md` with new systems
- Create `engine/battle/systems/README.md` if needed
- Create `engine/battle/utils/README.md` if needed

---

## Risk Mitigation

### High Risks Identified
1. **Performance** - Many calculations per frame
   - **Mitigation**: Spatial indexing, caching, profiling
   
2. **Complexity** - 21 interconnected systems
   - **Mitigation**: Clear interfaces, unit tests, phased approach
   
3. **Balance** - Smoke, fire, explosions need tuning
   - **Mitigation**: Data-driven config, playtesting

### Known Challenges
- HEX coordinate conversions (use HexMath consistently)
- Turn-based animations (async vs sync)
- AI decision complexity (start simple, iterate)
- Save/load serialization (design for it early)

---

## Next Steps

### Immediate Actions
1. ✅ **Read Master Plan**: Review TASK-016 master document fully
2. ⬜ **Review Existing Code**: Study `hex_math.lua` and `hex_system.lua`
3. ⬜ **Set Up Profiling**: Install/configure Love2D profiler
4. ⬜ **Create First Task**: Copy template for TASK-016A (Pathfinding)

### Start Implementation
1. Begin with **TASK-016A** (Pathfinding) - most critical
2. Write tests first (TDD approach)
3. Implement algorithm
4. Profile performance
5. Document API
6. Mark complete in tasks.md

### Development Workflow
```bash
# 1. Run game with console
lovec "engine"

# 2. Test specific system
# (add test runner commands as needed)

# 3. Profile performance
# (use Love2D profiler)

# 4. Check console for errors
# (all debug output visible)
```

---

## Success Metrics

### Technical Success
- [ ] All 21 systems implemented and tested
- [ ] 90%+ test coverage on utilities
- [ ] 80%+ test coverage on systems
- [ ] All performance targets met
- [ ] No memory leaks over 1000 turns
- [ ] No console errors or warnings

### Gameplay Success
- [ ] Pathfinding finds intelligent routes
- [ ] Cover provides tactical value
- [ ] Fire/smoke create dynamic situations
- [ ] Explosions feel powerful and fair
- [ ] Stealth is viable and rewarding
- [ ] Reaction fire adds tension

### Quality Success
- [ ] Code follows all Lua best practices
- [ ] API documentation complete
- [ ] FAQ explains mechanics clearly
- [ ] Developer guide enables modding
- [ ] Clean git history with good commits

---

## Time Investment Analysis

### Phase Breakdown
| Phase | Systems | Hours | % of Total |
|-------|---------|-------|------------|
| Phase 1: Core Grid | 4 | 40 | 19% |
| Phase 2: LOS/LOF | 5 | 48 | 23% |
| Phase 3: Environment | 4 | 44 | 21% |
| Phase 4: Combat | 5 | 52 | 25% |
| Phase 5: Stealth | 3 | 24 | 12% |
| **Total** | **21** | **208** | **100%** |

### Milestone Schedule (@ 20h/week)
- **Week 1-2**: Phase 1 complete (Foundation)
- **Week 3-4**: Phase 2 complete (Vision)
- **Week 5-6**: Phase 3 complete (Environment)
- **Week 7-8**: Phase 4 complete (Combat)
- **Week 9**: Phase 5 complete (Stealth)
- **Week 10**: Testing, polish, documentation

### Efficiency Factors
- **Reuse**: Existing HexMath saves ~8 hours
- **Parallel**: Multiple tracks can overlap
- **Experience**: Learning curve on first systems
- **Testing**: TDD catches bugs early
- **Documentation**: Write as you code

---

## References

### Created Documents
1. **Master Plan**: `tasks/TODO/TASK-016-hex-tactical-combat-master-plan.md`
2. **Quick Reference**: `tasks/HEX_COMBAT_QUICK_REFERENCE.md`
3. **Example Task**: `tasks/TODO/TASK-016A-pathfinding-system.md`
4. **This Summary**: `tasks/HEX_GRID_PLANNING_SUMMARY.md`

### External References
- **HEX Grid Math**: https://www.redblobgames.com/grids/hexagons/
- **A* Pathfinding**: https://www.redblobgames.com/pathfinding/a-star/
- **X-COM Mechanics**: https://www.ufopaedia.org/
- **Lua Best Practices**: `wiki/LUA_BEST_PRACTICES.md`

### Project Documentation
- **API Reference**: `wiki/API.md`
- **Game FAQ**: `wiki/FAQ.md`
- **Dev Guide**: `wiki/DEVELOPMENT.md`
- **Quick Reference**: `wiki/QUICK_REFERENCE.md`

---

## Questions & Answers

**Q: Is this too ambitious?**  
A: No. It's well-planned with clear phases. Each system is independent and testable. The 208-hour estimate is realistic for the scope.

**Q: Can I change the order?**  
A: Some flexibility exists, but the critical path must be followed. Parallel tracks can be worked simultaneously.

**Q: What if I get stuck?**  
A: Each task has detailed implementation notes, pseudocode, and examples. The architecture is designed to be modular.

**Q: How do I test HEX grid code?**  
A: Use Love2D console (`lovec "engine"`), print statements, and F9 debug grid overlay. Visual debugging is powerful.

**Q: What about AI?**  
A: This plan focuses on the grid systems. AI integration is Phase 6 (future work) but will use these systems.

**Q: Can I skip documentation?**  
A: No. Documentation is part of each task. It ensures code is maintainable and understandable.

---

## Final Checklist

### Planning Complete ✅
- [x] Master plan document created
- [x] Quick reference guide created
- [x] Example task document created
- [x] All features from Polish list mapped
- [x] Architecture designed
- [x] File structure planned
- [x] Performance targets set
- [x] Testing strategy defined
- [x] Documentation requirements listed
- [x] Risks identified and mitigated
- [x] Task tracking updated

### Ready to Implement ✅
- [x] Clear starting point (TASK-016A)
- [x] Dependencies identified
- [x] Tools available (Love2D, console)
- [x] Templates ready
- [x] Testing framework in place
- [x] Documentation structure prepared

### Success Criteria Defined ✅
- [x] Technical metrics set
- [x] Gameplay goals clear
- [x] Quality standards established
- [x] Performance targets defined

---

## Conclusion

**Status: ✅ PLANNING COMPLETE - READY TO IMPLEMENT**

All 21 HEX grid tactical combat systems have been thoroughly planned with:
- Detailed implementation steps
- Clear architecture and file structure
- Comprehensive testing strategy
- Performance targets and optimization plans
- Documentation requirements
- Risk mitigation strategies

The plan covers 100% of requested features with realistic time estimates and a proven development approach. Implementation can begin immediately with TASK-016A (Pathfinding System).

**Recommended Next Step:** Review the master plan document completely, then start TASK-016A.

---

**Created:** October 13, 2025  
**Document Version:** 1.0  
**Status:** Final

