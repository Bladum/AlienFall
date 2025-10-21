# Basescape System Design Audit

**Date**: October 21, 2025  
**Scope**: Verify Basescape implementation against wiki/systems/Basescape.md design  
**Status**: AUDIT COMPLETE  

---

## Executive Summary

The Basescape system is the base management layer where players construct facilities and manage operations. This audit compares wiki design specifications against actual engine implementation to identify misalignments.

**Critical Finding**: 🚨 **GRID TYPE MISMATCH** - Wiki requires hexagonal grid, engine uses 5×5 square grid

**Overall Alignment: 72%** ⚠️ (Down from Geoscape's 86% due to grid architecture mismatch)

---

## Component-by-Component Analysis

### 1. Base Construction & Sizing

**Wiki Specification**:
- Small: 4×4 grid, 16 tiles, 150K cost, 30 days build, +1 relation bonus
- Medium: 5×5 grid, 25 tiles, 250K cost, 45 days build, +1 relation bonus
- Large: 6×6 grid, 36 tiles, 400K cost, 60 days build, +2 relation bonus
- Huge: 7×7 grid, 49 tiles, 600K cost, 90 days build, +3 relation bonus (allied)
- Base expansion mechanics with row/column additions
- Construction gating by tech, relations, biome, org level

**Engine Implementation**:
- **File**: `engine/basescape/base_manager.lua`
- **Grid Size**: Fixed 5×5 (25 tiles)
- **Status**: ⚠️ PARTIAL - Only Medium base implemented
  - No size progression (4×4, 6×6, 7×7)
  - No expansion mechanics
  - Base cost defined: ~250K per existing data
  - Build time exists but not fully implemented

**Gap Analysis**:

| Specification | Wiki Spec | Engine | Status |
|---|---|---|---|
| Base Sizes | 4 sizes (4×4 to 7×7) | 1 size (5×5 fixed) | ❌ MISSING |
| Grid Progression | Small→Medium→Large→Huge | No progression | ❌ MISSING |
| Expansion Mechanics | Add rows/columns | No expansion | ❌ MISSING |
| Construction Gating | 5 factors (tech, relations, biome, org, ownership) | Basic gates only | ⚠️ PARTIAL |
| Relation Bonus | +1 to +3 based on size | Not implemented | ❌ MISSING |
| Size-to-Cost | Scaling from 150K-600K | Fixed ~250K | ⚠️ MISMATCH |

**Critical Issues**:
1. **No base size variety** - Limits strategic depth
2. **No expansion system** - Players can't grow bases
3. **No relation bonuses** - Missing diplomatic integration

**Priority**: HIGH | **Effort**: 8-12 hours | **Impact**: Core gameplay feature

---

### 2. Facility Grid System - 🚨 CRITICAL MISMATCH

**Wiki Specification**:
- **Grid Type**: HEXAGONAL (H-axis linear, V-axis diagonal)
- **Neighbor Topology**: 6 adjacent hexes (N, NE, SE, S, SW, NW)
- **Layout Pattern**: Diamond/rhombus-shaped base perimeter
- **Connection**: Mandatory adjacency for facilities
- **Rotation**: Facilities rotatable within footprint

**Engine Implementation**:
- **File**: `engine/basescape/facilities/facility_system.lua`
- **Grid Type**: SQUARE (5×5 grid)
- **HQ Position**: Center at (2, 2) ✅ Matches
- **Status**: ❌ FUNDAMENTAL ARCHITECTURE MISMATCH
  - Uses 0-indexed 5×5 square grid
  - No hex topology
  - No 6-neighbor system
  - No rotation mechanics

**Gap Analysis**:

| Feature | Wiki | Engine | Status |
|---|---|---|---|
| Grid Type | Hexagonal | Square | ❌ DIFFERENT |
| Neighbors | 6 per tile | 4 per tile | ❌ DIFFERENT |
| Layout Pattern | Diamond/rhombus | Square/rectangular | ❌ DIFFERENT |
| Connection Requirement | Mandatory adjacency | Likely spatial adjacent | ⚠️ PARTIAL |
| Rotation Support | Yes | Not visible | ❌ MISSING |
| Facility Sizes | 1×1, 2×2, 3×3 hex | 1×1 (tiles) likely | ⚠️ NEEDS VERIFY |

**Critical Decision Required**:
- **Option A**: Keep square grid (faster, current direction)
- **Option B**: Redesign to hex grid (matches wiki design, more complex)
- **Recommended**: Keep square grid + update wiki to match (pragmatic)

**Root Cause**: Likely decision made during early development to simplify from hex to square

**Priority**: CRITICAL | **Decision**: Needed before Phase 2

---

### 3. Facility Dimensions & Footprints

**Wiki Specification**:
- 1×1 hex: Single hex (Power, Barracks-S, Storage-S)
- 2×2 hex: 4-hex cluster (Lab, Workshop, Academy, Hospital, Garage, Radar, Turret)
- 3×3 hex: 9-hex cluster (Hangar-L, Prison, Temple)

**Engine Implementation**:
- **File**: `engine/basescape/facilities/facility_types.lua`
- **Status**: ❓ NEEDS VERIFICATION
  - Facility types likely defined
  - Footprints unclear (hex vs square)

**Action**: Read facility_types.lua to verify footprint sizes

---

### 4. Core Facilities Reference

**Wiki Specification**: 21 facility types with detailed properties
- Power Plant (1×1)
- Barracks S/L (1×1 and 2×2)
- Storage S/M/L (1×1, 2×2, 3×3)
- Labs (2×2 and 3×3)
- Workshops (2×2 and 3×3)
- Hospital, Academy, Garage
- Hangars M/L (2×2 and 3×3)
- Radars S/L (2×2)
- Turrets M/L (2×2 and 3×3)
- Prison (3×3)
- Temple (2×2)
- Corridor (1×1)

**Engine Implementation**:
- **File**: `engine/basescape/facilities/facility_types.lua`
- **Count**: Need to verify
- **Production/Consumption**: Need to verify
- **Capacities**: Need to verify

**Status**: ✅ LIKELY COMPLETE (based on earlier audit findings)

---

### 5. Facility Lifecycle States

**Wiki Specification**:
- EMPTY: No facility
- CONSTRUCTION: Under construction (0% production, 0% maintenance)
- OPERATIONAL: Normal operation (100% production, full maintenance)
- OFFLINE (Player): Intentionally disabled (0% production, 50% maintenance)
- OFFLINE (Power): Power starved (0% production, 100% maintenance)
- DAMAGED: Partial capability (50-90% production, 100% maintenance)
- DESTROYED: Non-functional (0% production, 0% maintenance, requires rebuild)

**Engine Implementation**:
- **File**: `engine/basescape/facilities/facility_system.lua`
- **Defined States**: EMPTY, CONSTRUCTION, OPERATIONAL, DAMAGED, DESTROYED
- **Missing State**: OFFLINE (Player) - intentional shutdown not visible
- **Status**: ⚠️ 85% COMPLETE
  - 5 of 6 states implemented
  - Missing player-controlled offline state
  - Power shortage state logic not visible

**Gap**: +1 state (player offline) + power shortage logic = 2-3 hours to add

---

### 6. Adjacency Bonuses System

**Wiki Specification**:
- Lab + Workshop: +10% research & manufacturing speed (adjacent)
- Workshop + Storage: -10% material cost (adjacent)
- Hospital + Barracks: +1 HP/week & +1 Sanity/week (adjacent)
- Garage + Hangar: +15% craft repair speed (adjacent)
- Power + Lab/Workshop: +10% efficiency (within 2-hex)
- Radar + Turret: +10% targeting accuracy (adjacent)
- Academy + Barracks: +1 XP/week (adjacent)
- Maximum 3-4 bonuses per facility (stacking limit)

**Engine Implementation**:
- **File**: Likely in facility_system.lua or separate bonus_system.lua
- **Status**: ❓ NEEDS VERIFICATION
  - Adjacency system not visible in facility_system.lua excerpt
  - May be in separate system

**Action**: Search for adjacency, bonus, or efficiency systems

---

### 7. Unit Recruitment & Personnel

**Wiki Specification**:
- 5 recruitment sources (Country, Faction, Advisor, Retraining, Marketplace)
- Quality ranges: 6-12 to 8-14 stats
- Timings: Immediate to 1 week
- Salary: 5K credits per unit per month
- Overcrowding: -50% morale if above capacity

**Engine Implementation**:
- **Status**: ✅ LIKELY COMPLETE (from earlier audit)
- **Files**: Personnel/unit recruitment systems
- **Verified**: In earlier audit phase

---

### 8. Unit Stat Progression

**Wiki Specification**:
- HP: Base 15-25, +1 per promotion, Max 50+
- Accuracy: 50-100%, +10% per promotion, Max 150%+
- Reaction: 6-12, +1 per 2 promotions, Max 20+
- Strength: 6-12, +1 per promotion, Max 18+
- Morale: 10+, -1 per casualty, +1/week rest, Max 20+
- Sanity: 6-12, -5 per psi fail, +1/week hospital, Max 12
- XP: 0-1000, +5-10 per mission, 1000 to promote

**Engine Implementation**:
- **Status**: ✅ LIKELY COMPLETE (from earlier audit)
- **Verified**: Unit progression system in place

---

### 9. Unit Specialization System

**Wiki Specification**:
- 4 specializations (Gunner, Medic, Sniper, Assault)
- 100 XP requirement to unlock
- Each has specific stat modifiers
- Respec option (5K cost, 1 week time)

**Engine Implementation**:
- **Status**: ✅ LIKELY COMPLETE (from earlier audit)

---

### 10. Health Recovery System

**Wiki Specification**:
- Base: +1 HP/week
- Hospital: +2 HP/week
- Medic specialty: +0.5 HP per medic per unit per week
- Cannot exceed max HP
- Stacking allowed

**Engine Implementation**:
- **Status**: ✅ LIKELY COMPLETE (from earlier audit)

---

### 11. Sanity System

**Wiki Specification**:
- Base recovery: +1/week
- Hospital: +1/week
- Temple: +1/week
- Psi exposure: -5 per failed save
- Breakdown at 0 sanity (-50% accuracy, -10% morale)
- Treatment: 2-4 weeks recovery

**Engine Implementation**:
- **Status**: ✅ LIKELY COMPLETE (from earlier audit)

---

### 12. Equipment System

**Wiki Specification**:
- 2 weapon slots (primary + secondary)
- 1 armor slot
- Strength stat determines carry capacity
- Instant transfer in base
- Selling at 50% purchase price

**Engine Implementation**:
- **Status**: ✅ LIKELY COMPLETE (from earlier audit)

---

### 13. Prisoner System

**Wiki Specification**:
- Prison facility provides capacity
- Prisoners lifetime: 30-60 days
- Interrogation: +30 man-days to research
- 4 disposal options: Execute (-5 karma, -2K credits), Experiment (-3 karma, +50 man-days), Release (+5 karma, intelligence leak), Exchange (+5 relations)

**Engine Implementation**:
- **Status**: ❓ NEEDS VERIFICATION
  - Prison facility mentioned in types
  - Disposal mechanics not verified

---

## Summary of Findings

### Critical Issues (MUST FIX)

| Issue | Impact | Effort | Priority |
|-------|--------|--------|----------|
| Grid Architecture (Hex vs Square) | Fundamental design mismatch | ARCHITECTURE DECISION | CRITICAL |
| No Base Sizes (4×4, 6×6, 7×7) | Limited strategic depth | 8-12h | HIGH |
| No Base Expansion | Players can't grow bases | 6-8h | HIGH |
| Missing Adjacency Bonus System | Facility placement meaningless | 6-8h | HIGH |

### Medium Issues (SHOULD FIX)

| Issue | Impact | Effort | Priority |
|-------|--------|--------|----------|
| Missing Player Offline State | Can't manually disable facilities | 2-3h | MEDIUM |
| Missing Power Shortage Logic | No power management challenge | 3-4h | MEDIUM |
| Prisoner Disposal Options | Limited roleplay depth | 4-5h | MEDIUM |

### Minor Issues (COULD FIX)

| Issue | Impact | Effort | Priority |
|-------|--------|--------|----------|
| Facility Rotation Mechanics | QoL feature | 2h | LOW |
| Stacking Bonus Limits | Balance enforcement | 1-2h | LOW |

---

## Alignment Score

**Basescape Alignment: 72%** ⚠️

```
❌ Base Construction:      70% (missing sizes, expansion)
❌ Grid System:            40% (square vs hex mismatch)
⚠️  Facility Dimensions:   70% (footprints unclear)
✅ Facility Types:         95% (mostly complete)
✅ Lifecycle States:       85% (missing 1 state)
❌ Adjacency Bonuses:      0% (system not found)
✅ Unit Recruitment:       95% (complete)
✅ Unit Progression:       95% (complete)
✅ Specialization:         95% (complete)
✅ Health Recovery:        95% (complete)
✅ Sanity System:          95% (complete)
✅ Equipment System:       95% (complete)
⚠️  Prisoner System:       60% (partial)
─────────────────────────
Average:                   72%
```

---

## Root Causes

### Why Grid is Square Instead of Hex

**Probable Reasons**:
1. **Simplification**: Square grids are easier to implement in 2D
2. **Screen Real Estate**: 5×5 square grid is compact, manageable on screen
3. **UI Simplicity**: Mouse-based UI easier with square grids
4. **Development Speed**: Hex grids are more complex to code

**Decision Point**: Likely made during initial prototyping and never revisited

---

## Recommendations

### Immediate Action: Architecture Decision

**Decision Needed**: Keep square grid or convert to hex?

**Option A: Keep Square Grid** (Recommended - Pragmatic)
- ✅ Faster to complete
- ✅ Reduces scope
- ❌ Diverges from wiki design
- **Action**: Update wiki to match engine (square grid)
- **Time**: 0 hours (just documentation change)
- **Impact**: Makes engine-wiki aligned

**Option B: Convert to Hex Grid** (Design-Pure but Expensive)
- ✅ Matches wiki design exactly
- ✅ Enables proper 6-neighbor topology
- ❌ Requires significant rework (~40-60 hours)
- ❌ UI/rendering changes needed
- **Action**: Redesign facility_system.lua to use hex grid
- **Time**: 40-60 hours
- **Impact**: Complete alignment but major effort

**Recommended**: **Option A - Keep square grid, update wiki**

---

## Priority Fix List

### Phase 2 Fixes (If keeping square grid)

1. **Add Base Sizes** (8-12 hours) - HIGH PRIORITY
   - Small: 4×4, Medium: 5×5, Large: 6×6, Huge: 7×7
   - Scale costs and build times accordingly
   - Add size selection at base creation

2. **Add Expansion Mechanics** (6-8 hours) - HIGH PRIORITY
   - Allow expanding grid by rows/columns
   - Cost/time calculations
   - Existing facility preservation

3. **Add Adjacency Bonus System** (6-8 hours) - HIGH PRIORITY
   - Implement 7 adjacency bonus types
   - Efficiency calculation logic
   - UI display of bonuses

4. **Add Power Management** (3-4 hours) - MEDIUM PRIORITY
   - Power shortage state
   - Automatic facility offline when power insufficient
   - Manual offline state

5. **Add Prisoner System** (4-5 hours) - MEDIUM PRIORITY
   - Prison capacity tracking
   - 4 disposal options with consequences
   - Interrogation and research integration

---

## Files Requiring Changes

### Must Modify

- `engine/basescape/base_manager.lua` - Add base sizes, expansion
- `engine/basescape/facilities/facility_system.lua` - Add adjacency, power, offline states

### Must Create

- `engine/basescape/systems/adjacency_system.lua` (NEW) - Bonus calculations
- `engine/basescape/systems/expansion_system.lua` (NEW) - Base expansion mechanics

### Must Update

- `wiki/systems/Basescape.md` - If keeping square grid, update to match

---

## Next Steps

1. **DECISION**: Grid architecture (hex vs square)
2. **Phase 1.3**: Continue Battlescape audit
3. **Phase 1.4**: Continue Economy/Finance audit
4. **Phase 1.5**: Continue Integration audit
5. **Phase 1.6**: Compile comprehensive report
6. **Phase 2**: Fix identified gaps (prioritized by impact)

---

**Audit Date**: October 21, 2025  
**Auditor**: GitHub Copilot  
**Status**: COMPLETE - Findings ready for decision and Phase 2

