# TASK-FIX-ENGINE-ALIGNMENT: Align Engine Implementation with Wiki Game Design

**Task ID**: FIX-ENGINE-ALIGNMENT  
**Created**: October 21, 2025  
**Status**: IN_PROGRESS  
**Priority**: HIGH  
**Estimated Time**: 40-60 hours  

---

## Executive Summary

The engine has 89% wiki alignment (from previous audit), but the Relations system was already implemented (not a gap!). This task systematically verifies that ALL engine implementations match the latest wiki game design specifications and fixes any misalignments.

**Key Finding**: Relations system is COMPLETE in `engine/politics/relations/` - audit was outdated.

**Scope**: Compare 16 wiki systems against engine implementations and identify design mismatches that need fixing.

---

## Requirements

### Functional Requirements

1. **System Verification**
   - [ ] Verify each of 16 wiki systems has matching engine implementation
   - [ ] Compare design specs with actual code behavior
   - [ ] Identify any design-code mismatches
   - [ ] Document all gaps and fixes needed

2. **Design Alignment**
   - [ ] Geoscape: Hex grid, 90×45 tiles, provinces, radar, missions
   - [ ] Basescape: 5×5 grid facilities, HQ center, construction gating
   - [ ] Battlescape: Hex combat, units, weapons, AI, 2D+3D rendering
   - [ ] Economy: Research, manufacturing, marketplace integration
   - [ ] Combat: Damage models, weapon modes, abilities
   - [ ] Units: Progression, equipment, stats, specialization
   - [ ] Relations: Countries, suppliers, factions (VERIFIED COMPLETE)
   - [ ] Finance: Funding, costs, suppliers, reputation
   - [ ] Lore: Factions, narratives, campaigns
   - [ ] AI: 6 behavior modes, threat assessment, coordination
   - [ ] UI: HUD, inventory, targeting, actions
   - [ ] Items: Weapons, armor, grenades, ammo
   - [ ] Integration: State management, persistence, mod system
   - [ ] Analytics: Metrics, telemetry (optional)
   - [ ] Interception: Air combat system (partial)
   - [ ] Assets: Asset loading, fonts, images, sounds

3. **Code Quality**
   - [ ] All implementations follow code standards (docs/CODE_STANDARDS.md)
   - [ ] All files have proper LuaDoc comments
   - [ ] No hardcoded values - use configuration files
   - [ ] Proper error handling with pcall
   - [ ] All systems have README documentation

4. **Testing Requirements**
   - [ ] Each system verified by running with Love2D console
   - [ ] No warnings or errors in console output
   - [ ] Core game loop works end-to-end
   - [ ] Each gap verified against wiki spec before fixing

---

## Detailed Plan

### Phase 1: Comprehensive Audit (8-12 hours)

Create detailed alignment report comparing wiki specs against engine code.

#### 1.1 Geoscape System Audit (2 hours)
- **Files to Check**: 
  - `engine/geoscape/world/world_state.lua` (world management)
  - `engine/geoscape/world/world_renderer.lua` (rendering)
  - `engine/geoscape/systems/` (all systems)
- **Wiki Specs to Verify**:
  - Hexagonal grid implementation
  - 90×45 hex size for Earth
  - 500km per hex scale
  - Multi-world support
  - Province/region/biome systems
  - Radar coverage mechanics
  - Mission generation
- **Output**: `docs/GEOSCAPE_DESIGN_AUDIT.md`

#### 1.2 Basescape System Audit (2 hours)
- **Files to Check**:
  - `engine/basescape/base_manager.lua` (grid and construction)
  - `engine/basescape/facilities/` (facility system)
  - `engine/basescape/logic/` (facility logic)
- **Wiki Specs to Verify**:
  - 5×5 grid architecture
  - Hexagonal neighbor topology (6 adjacent tiles)
  - HQ center placement at (2,2)
  - Facility types and costs
  - Construction time calculations
  - Personnel assignment
  - Maintenance and economics
- **Output**: `docs/BASESCAPE_DESIGN_AUDIT.md`

#### 1.3 Battlescape System Audit (2 hours)
- **Files to Check**:
  - `engine/battlescape/data/maptile.lua` (tile system)
  - `engine/battlescape/data/tilesets.lua` (tilesets)
  - `engine/battlescape/mission_map_generator.lua` (map gen)
  - `engine/battlescape/combat/damage_models.lua` (combat)
  - `engine/battlescape/battle_ecs/hex_system.lua` (hex grid)
- **Wiki Specs to Verify**:
  - Hexagonal grid combat
  - 4 damage model types
  - 6 weapon modes
  - 11 psionic abilities
  - Unit equipment and inventory
  - AI behavior modes
- **Output**: `docs/BATTLESCAPE_DESIGN_AUDIT.md`

#### 1.4 Economy, Finance, Relations Audit (1 hour)
- **Files to Check**:
  - `engine/economy/research/research_system.lua`
  - `engine/economy/production/manufacturing_system.lua`
  - `engine/politics/relations/relations_manager.lua` ✓ (verified complete)
  - `engine/geoscape/systems/funding_manager.lua` (if exists)
- **Wiki Specs to Verify**:
  - Research tree implementation
  - Manufacturing queue and time
  - Marketplace system
  - Relations affecting funding/pricing
  - Finance tracking
- **Output**: `docs/ECONOMY_DESIGN_AUDIT.md`

#### 1.5 Integration Systems Audit (1 hour)
- **Files to Check**:
  - `engine/core/state_manager.lua` (state management)
  - `engine/core/data_loader.lua` (TOML loading)
  - `engine/mods/mod_manager.lua` (mod system)
  - `engine/scenes/` (scene navigation)
- **Wiki Specs to Verify**:
  - State transitions (Geoscape → Battlescape → Basescape)
  - Persistence and save/load
  - Mod system architecture
  - Configuration from TOML files
- **Output**: `docs/INTEGRATION_DESIGN_AUDIT.md`

#### 1.6 Compile Audit Summary (2 hours)
- Merge all audit reports into `docs/ENGINE_DESIGN_ALIGNMENT_REPORT.md`
- Create gap list with priorities
- Identify specific files needing changes
- Estimate time for each fix

### Phase 2: Fix Critical Gaps (20-30 hours)

Fix any design-code mismatches found in Phase 1, prioritized by impact.

#### 2.1 Geoscape Fixes (if needed)
- **Time**: 4-8 hours
- **Typical Issues**:
  - World grid scale verification
  - Province system completeness
  - Radar coverage calculations
  - Mission generation balance

#### 2.2 Basescape Fixes (if needed)
- **Time**: 4-8 hours
- **Typical Issues**:
  - Facility grid hex topology
  - Construction time calculations
  - Personnel assignment validation
  - Economic feedback loops

#### 2.3 Battlescape Fixes (if needed)
- **Time**: 4-8 hours
- **Typical Issues**:
  - Hex grid combat verification
  - Damage model implementation
  - Weapon mode effects
  - AI threat assessment

#### 2.4 Economy/Finance Fixes (if needed)
- **Time**: 2-4 hours
- **Typical Issues**:
  - Research project timing
  - Manufacturing queue behavior
  - Marketplace pricing integration
  - Relations funding multipliers

#### 2.5 Integration Fixes (if needed)
- **Time**: 2-4 hours
- **Typical Issues**:
  - State transition smoothness
  - Save/load cycle validation
  - Mod system completeness
  - Configuration loading

### Phase 3: Verification & Testing (8-12 hours)

Run comprehensive tests to verify all systems work as designed.

#### 3.1 Unit Tests
- Run all existing tests: `run_tests.bat`
- Create new tests for any modified systems
- Verify test coverage for critical paths
- **Time**: 2-4 hours

#### 3.2 Integration Tests
- **Test Cases**:
  - [ ] Start game → Geoscape loads correctly
  - [ ] Geoscape → Detect mission → Enter Battlescape
  - [ ] Battlescape → Combat → Return to Geoscape
  - [ ] Geoscape → Base → Basescape
  - [ ] Basescape → Build facility → Check economy
  - [ ] Save game → Load game → State preserved
  - [ ] Each game loop cycle (day/week/month)
- **Time**: 3-4 hours
- **Verification**: Run with Love2D console, check for warnings/errors

#### 3.3 Manual Playtesting
- Play through 1 full game cycle (1 month)
- Verify all systems behave per wiki design
- Check balance against design specs
- Document any remaining issues
- **Time**: 3-4 hours

### Phase 4: Documentation Updates (4-6 hours)

Update all documentation to reflect fixed implementations.

#### 4.1 Update API Documentation
- `wiki/api/` files updated with actual implementation paths
- All API examples verified to work
- Parameter types documented accurately
- **Time**: 2-3 hours

#### 4.2 Update Implementation Status
- `docs/ENGINE_IMPLEMENTATION_STATUS.md` updated
- `docs/ALIGNMENT_AUDIT_SUMMARY.md` updated to show 100% if all fixed
- `docs/GEOSCAPE_IMPLEMENTATION_STATUS.md` verified current
- **Time**: 1 hour

#### 4.3 Create Fix Summary
- Document all changes made in Phase 2
- Link to specific commits/files
- Update task template with lessons learned
- **Time**: 1-2 hours

---

## Implementation Details

### Critical Systems to Verify

#### System #1: Geoscape Relations Integration ✓ VERIFIED COMPLETE
- **Implementation**: `engine/politics/relations/relations_manager.lua` (350+ lines)
- **Status**: COMPLETE - Track relations for countries, suppliers, factions
- **Integration**: Used by ReputationSystem for funding/pricing multipliers
- **Gap**: NONE - Already fully implemented
- **Action**: Mark as verified and complete

#### System #2: Hex Grid Topology
- **Geoscape Hex**: `engine/geoscape/systems/hex_grid.lua` - Verify 90×45 grid
- **Battlescape Hex**: `engine/battlescape/battle_ecs/hex_system.lua` - Verify hex math
- **Basescape Grid**: `engine/basescape/base_manager.lua` - Uses 5×5 (NOT hex) - VERIFY THIS IS INTENTIONAL
- **Action**: Confirm hex implementation matches wiki, check grid dimensions

#### System #3: Facility Construction Gating
- **File**: `engine/basescape/base_manager.lua` buildFacility function
- **Wiki Spec**: Construction gated by technology, relations, biome, org level, ownership
- **Action**: Verify all gating conditions are implemented

#### System #4: Combat System Integration
- **Files**: `engine/battlescape/combat/damage_models.lua`, `weapon_modes.lua`, `psionics_system.lua`
- **Wiki Spec**: 4 damage types, 6 weapon modes, 11 psionic abilities
- **Action**: Count actual implementations vs wiki specs

#### System #5: State Transitions
- **Files**: `engine/core/state_manager.lua`, `engine/scenes/`
- **Wiki Spec**: Seamless transitions between Geoscape → Battlescape → Basescape
- **Action**: Verify no data loss during transitions

### Dependency Graph

```
Relations System ✓ COMPLETE
  ├── Funding System
  │   └── Geoscape Economy
  ├── Marketplace Prices
  │   └── Economy System
  └── Mission Generation
      └── Geoscape Mission Manager

Geoscape System
  ├── Hex Grid
  ├── Provinces/Regions/Biomes
  ├── Missions
  ├── Crafts & Interception
  └── Base Locations

Basescape System
  ├── Facility Grid (5×5)
  ├── Personnel Assignment
  ├── Construction Queue
  ├── Research
  └── Manufacturing

Battlescape System
  ├── Hex Combat Grid
  ├── Units & Equipment
  ├── Combat Resolution
  ├── Damage Models
  └── AI Behavior

Economy System
  ├── Research Projects
  ├── Manufacturing Queue
  ├── Marketplace
  └── Finance Tracking
```

---

## Testing Strategy

### Test Coverage Required

1. **Unit Tests**
   - Each system has dedicated test file
   - Run: `run_tests.bat` or `lua tests/runners/run_all_tests.lua`
   - Target: 100% coverage on public APIs

2. **Integration Tests**
   - State transitions (Geo → Battle → Base)
   - Data persistence (save/load cycle)
   - Economy feedback (research → manufacturing → marketplace)
   - Relation cascades (relations → funding → prices)

3. **Manual Verification**
   - **Console Check**: Run `lovec "engine"` and watch console for:
     - No [ERROR] messages
     - All [Module] initialization messages present
     - State transitions logged correctly
   - **Gameplay Check**: Play 1 month of game
     - All systems update correctly
     - No crashes or hangs
     - UI displays correct information

### How to Run/Debug

**Run Game with Console**:
```bash
lovec "engine"
```

**Check for Errors**:
- Look for `[ERROR]` messages in console
- Look for `[WARNING]` messages
- Verify state transitions logged

**Debug Specific System**:
- Find system initialization in `engine/main.lua` → `love.load()`
- Verify module required correctly: `local Module = require("path.to.module")`
- Add debug prints: `print("[ModuleName] Debug: " .. tostring(value))`
- Check Love2D console output

---

## Acceptance Criteria

### Must Complete

- [ ] All 16 wiki systems verified against engine implementations
- [ ] Gap list created and prioritized
- [ ] All critical gaps (marked HIGH) fixed
- [ ] Game runs without errors in Love2D console
- [ ] Save/load cycle works without data loss
- [ ] Complete game loop playable (1 month)

### Should Complete

- [ ] All MEDIUM gaps fixed
- [ ] All tests passing (run_tests.bat)
- [ ] Performance verified (no stuttering, >60 FPS)
- [ ] API documentation updated
- [ ] Implementation status docs updated to 100%

### Could Complete (if time)

- [ ] All LOW gaps fixed
- [ ] Analytics system completed
- [ ] Interception system polished
- [ ] Extra content created for variety

---

## Dependencies & Blockers

### No External Blockers
- All systems already partially implemented
- No missing libraries or tools
- No platform-specific issues identified

### Internal Dependencies
- Relations system ✓ Complete (not a blocker)
- Geoscape framework exists (needs verification)
- Basescape framework exists (needs verification)
- Battlescape framework exists (needs verification)

---

## Documentation Updates

### Files to Update

1. **docs/ENGINE_DESIGN_ALIGNMENT_REPORT.md** (NEW)
   - Comprehensive audit of all 16 systems
   - Gap list with priorities
   - Fix recommendations

2. **docs/GEOSCAPE_DESIGN_AUDIT.md** (NEW)
   - Detailed Geoscape alignment check
   - Hex grid verification
   - Province/mission system verification

3. **docs/BASESCAPE_DESIGN_AUDIT.md** (NEW)
   - Facility grid hex topology check
   - Construction gating verification
   - Personnel system check

4. **docs/BATTLESCAPE_DESIGN_AUDIT.md** (NEW)
   - Hex grid combat verification
   - Damage model count verification
   - Weapon/ability implementation check

5. **docs/ECONOMY_DESIGN_AUDIT.md** (NEW)
   - Research system verification
   - Manufacturing queue check
   - Marketplace integration check

6. **docs/INTEGRATION_DESIGN_AUDIT.md** (NEW)
   - State transition verification
   - Save/load system check
   - Mod system verification

7. **docs/ALIGNMENT_AUDIT_SUMMARY.md** (UPDATED)
   - Update to show 100% alignment after fixes
   - Update gap status to "FIXED"
   - Update relations status to "VERIFIED COMPLETE"

8. **wiki/API.md** (UPDATED)
   - Link to actual implementation files
   - Verify all API examples work

### README Updates

- [ ] `engine/README.md` - System overview
- [ ] `engine/geoscape/README.md` - Geoscape subsystems
- [ ] `engine/basescape/README.md` - Basescape subsystems
- [ ] `engine/battlescape/README.md` - Battlescape subsystems

---

## Success Metrics

| Metric | Target | Current |
|--------|--------|---------|
| Wiki-Engine Alignment | 100% | 89%+ |
| Critical Gaps Fixed | 100% | TBD after audit |
| Medium Gaps Fixed | 100% | TBD after audit |
| Low Gaps Fixed | 80%+ | TBD after audit |
| Test Coverage | >90% | TBD |
| Game Stability | No crashes | TBD |
| Frame Rate | >60 FPS | TBD |
| Load Time | <5 seconds | TBD |

---

## How to Use This Task

1. **Phase 1 Audit**: Run all audit checks listed in Phase 1
2. **Document Findings**: Create audit reports as specified
3. **Prioritize Fixes**: Use gap list to prioritize Phase 2 work
4. **Execute Fixes**: Work through Phase 2 fixes in priority order
5. **Verify Changes**: Run Phase 3 tests after each fix
6. **Update Docs**: Complete Phase 4 documentation updates
7. **Mark Complete**: When all acceptance criteria met

---

## Related Documentation

- [Wiki Game Design](../../wiki/README.md) - All game design specs
- [Engine Implementation Status](./ENGINE_IMPLEMENTATION_STATUS.md) - Current status
- [API Reference](../../wiki/api/README.md) - API documentation
- [Code Standards](../CODE_STANDARDS.md) - How to code
- [Testing Guide](../../tests/README.md) - How to test

---

## Progress Tracking

### What Worked Well

- Relations system was already complete
- Engine structure well-organized
- Separate subsystem folders make auditing easier
- Comprehensive game design in wiki provides clear spec

### What Could Improve

- Initial audit missed Relations system completion
- Documentation should link to actual implementation files
- API docs should have been verified before this task

### Lessons Learned

- Always check both old folder (`geoscape/systems/`) AND new folder (`politics/relations/`)
- Relations system had moved/been reorganized - update audit paths
- Comprehensive grep search catches hidden implementations

---

## Sign-Off

**Created By**: GitHub Copilot  
**Date**: October 21, 2025  
**Status**: IN_PROGRESS  

**Next Step**: Begin Phase 1 Comprehensive Audit

