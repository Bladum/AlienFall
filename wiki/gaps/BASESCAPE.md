# Basescape - Gap Analysis

**Date:** October 22, 2025  
**API File:** `wiki/api/BASESCAPE.md`  
**Systems File:** `wiki/systems/Basescape.md`

---

## IMPLEMENTATION STATUS ✅ VERIFIED

**October 22, 2025 - Session 1:**

**Status:** ✅ MINIMAL CHANGES REQUIRED  
- Finding: EXCELLENT ALIGNMENT - 0 critical gaps
- Note: Only minor value clarifications needed (grid dimensions, power output)
- Action: Approved for low-priority review - no urgent changes

---

## Executive Summary

**Overall Assessment:** ✅ **EXCELLENT ALIGNMENT** - Both documents are comprehensive and well-aligned. Systems provides strategic design vision while API provides implementation details. Very few conflicts or invented mechanics.

**Critical Issues Found:** 0  
**Moderate Issues Found:** 2 (Minor value conflicts only)  
**Minor Issues Found:** 5

---

## Critical Gaps

**NONE FOUND** - Both documents are remarkably consistent and comprehensive.

---

## Moderate Gaps

### 1. Base Grid Dimensions - CONFLICTING VALUES

**API Claims:**
```lua
-- Base Grid Dimensions: 40 tiles wide × 60 tiles tall (typical base maximum size)
```

**Systems Documentation:**
```
Base Dimensions by Size:
- Small (4×4): 16 tiles
- Medium (5×5): 25 tiles
- Large (6×6): 36 tiles
- Huge (7×7): 49 tiles
```

**Analysis:**
- API mentions 40×60 as "maximum size" for display/rendering
- Systems specifies actual playable grid sizes (4×4 to 7×7)
- These are COMPATIBLE but confusing without clarification

**Impact:** MODERATE - Could confuse implementers about actual grid size  
**Recommendation:** API should clarify that 40×60 is rendering viewport, not playable grid. Playable grids are 4×4 to 7×7 as Systems specifies.

---

### 2. Facility HP Values - NOT IN SYSTEMS

**API Claims:**
```lua
facility:getHP() → number
facility:getMaxHP() → number
facility:takeDamage(amount: number) → void
```

**Systems Documentation:**
- ✅ Mentions facility damage mechanics
- ✅ Describes damage states (50-90% production when damaged)
- ❌ **NO SPECIFIC HP VALUES** provided
- ❌ **NO HP RANGES** by facility type

**Impact:** MODERATE - Implementation detail missing from Systems  
**Recommendation:** Systems should specify HP ranges by facility type (e.g., "1×1 facilities: 20-30 HP, 2×2 facilities: 50-75 HP")

---

## Minor Gaps

### 3. Power Plant Output - SLIGHT VARIATION

**API Claims:**
```lua
power_output = 100  -- Per power plant
```

**Systems Documentation:**
```
Power Plant (Standard): +50 power per plant
```

**Analysis:**
- API says 100 power
- Systems says 50 power
- **CONFLICT** in values

**Impact:** LOW - Single numeric value conflict  
**Recommendation:** Reconcile actual power output value. Use Systems value (50) unless API is more recent.

---

### 4. ProductionJob Entity - API MORE DETAILED

**API Claims:**
```lua
ProductionJob = {
  id, type, target_item, target_tech, quantity,
  progress_percent, turns_remaining, is_complete,
  priority, cost_credits, cost_resources
}
```

**Systems Documentation:**
- ✅ Mentions manufacturing and research queues
- ❌ **NO DETAILED STRUCTURE** for production jobs
- ❌ **NO PRIORITY SYSTEM** described

**Impact:** LOW - Implementation detail, not design specification  
**Recommendation:** Systems could add production job structure but not critical

---

### 5. Transfer System - API ONLY

**API Claims:**
- Complete inter-base transfer system
- TransferRoute entity
- Supply line management
- Interception mechanics

**Systems Documentation:**
- ❌ **NOT MENTIONED** at all

**Impact:** LOW - Likely advanced feature not yet in Systems design  
**Recommendation:** If transfer system exists, add to Systems. If planned, mark as "future feature" in API.

---

### 6. Facility Specialization - NOT IN SYSTEMS

**API Claims:**
```lua
specialization = string,        -- "weapons", "armor", "medkits", etc.
specialization_bonus = number,  -- +X% efficiency
```

**Systems Documentation:**
- ❌ **NO MENTION** of facility specialization

**Impact:** LOW - Advanced feature  
**Recommendation:** Clarify if specialization is implemented or planned

---

### 7. Construction Progress Tracking - API MORE DETAILED

**API Claims:**
```lua
construction_progress = number,        -- 0-100
construction_turns_remaining = number,
facility:getConstructionProgress() → number
```

**Systems Documentation:**
- ✅ Mentions construction times
- ❌ **NO PROGRESS TRACKING** described

**Impact:** LOW - Implementation detail  
**Recommendation:** Systems could mention progress tracking is visible to player

---

## Excellent Alignments

### 1. Base Size Progression - PERFECTLY ALIGNED ✅

**Both documents agree on:**
| Size | Grid | Cost | Time | Capacity |
|------|------|------|------|----------|
| Small | 4×4 | 150K | 30d | 8-10 |
| Medium | 5×5 | 250K | 45d | 15-18 |
| Large | 6×6 | 400K | 60d | 24-28 |
| Huge | 7×7 | 600K | 90d | 35-40 |

**Assessment:** Perfect alignment

---

### 2. Facility Grid System - ALIGNED ✅

**Both documents agree on:**
- Square grid (orthogonal)
- 4-directional adjacency (North, South, East, West)
- No diagonal adjacency
- Corridor bridges for connectivity
- Mandatory adjacency to main cluster

**Assessment:** Perfect conceptual alignment

---

### 3. Adjacency Bonuses - PERFECTLY ALIGNED ✅

**Both documents list identical bonuses:**
- Lab + Workshop: +10% research & manufacturing
- Workshop + Storage: -10% material cost
- Hospital + Barracks: +1 HP/week, +1 Sanity/week
- Garage + Hangar: +15% craft repair speed
- Power Plant + Lab/Workshop: +10% efficiency
- Radar + Turret: +10% accuracy
- Academy + Barracks: +1 XP/week

**Assessment:** Perfect alignment

---

### 4. Power Management System - ALIGNED ✅

**Both documents describe:**
- Power priority hierarchy (Critical → Essential → Military → Production → Storage → Defense)
- Shortage resolution (offline low-priority facilities)
- Manual facility control
- Emergency power-down

**Assessment:** Excellent alignment, Systems has more detail

---

### 5. Facility Types - WELL ALIGNED ✅

**Both documents list same core facilities:**
- Power Plant, Barracks, Storage, Lab, Workshop
- Hospital, Academy, Garage, Hangar
- Radar, Turret, Prison, Temple, Corridor

**Power consumption and sizes match between documents**

**Assessment:** Excellent alignment

---

### 6. Expansion System - ALIGNED ✅

**Both documents describe:**
- Sequential progression (Small → Medium → Large → Huge)
- Expansion costs and times
- Prerequisites (technology, relations, economy)
- Facility preservation during expansion

**Assessment:** Perfect alignment

---

### 7. Construction Gates - ALIGNED ✅

**Both documents agree on:**
- Technology requirements
- Country relations minimums
- Biome penalties
- Organization level gates
- Province ownership requirements

**Assessment:** Perfect alignment

---

### 8. Base Maintenance Economics - ALIGNED ✅

**Both documents provide same cost structure:**
- Layout maintenance: (Base Size)² × 5K
- Facility maintenance: Per facility cost
- Unit salaries: 5K per unit per month
- Craft maintenance: 2K per craft per month
- Inactive facility tax: 50% of active maintenance

**Assessment:** Perfect alignment

---

### 9. Defense System - ALIGNED ✅

**Both documents describe:**
- Passive defense (turrets, facilities)
- Active defense (player Battlescape engagement)
- Defense rating calculation
- Facility damage mechanics
- Repair cost formula

**Assessment:** Excellent alignment

---

## Recommendations Summary

### For Systems Documentation (Basescape.md):

1. **CLARIFY GRID SIZE (Low Priority):**
   - Specify that 40×60 is rendering viewport, not playable grid
   - Emphasize playable grids are 4×4 to 7×7

2. **ADD MINOR DETAILS (Optional):**
   - Facility HP ranges by type
   - Production job structure
   - Construction progress tracking

3. **VERIFY TRANSFER SYSTEM:**
   - If inter-base transfers exist, add to documentation
   - If planned, coordinate with API documentation

### For API Documentation (BASESCAPE.md):

1. **FIX POWER OUTPUT VALUE:**
   - Change power plant output from 100 to 50 (match Systems)
   - Or verify correct value and update Systems

2. **CLARIFY GRID DIMENSIONS:**
   - Add note that 40×60 is rendering viewport
   - Emphasize actual playable grids are smaller (4×4 to 7×7)

3. **MARK ADVANCED FEATURES:**
   - If transfer system not yet implemented, mark as "planned"
   - If specialization not implemented, mark as "future feature"

---

## Conclusion

The Basescape documentation is exemplary in alignment. Both documents are comprehensive, well-structured, and highly consistent. The few discrepancies are minor:
1. Grid dimension clarification needed (rendering vs. playable)
2. Power plant output value conflict (100 vs. 50)
3. Some advanced features in API may not be documented/implemented yet

**Overall Quality:** ✅ EXCELLENT - Use as template for other system/API pairs

**Priority:** LOW - Only minor clarifications needed, both documents are production-ready
