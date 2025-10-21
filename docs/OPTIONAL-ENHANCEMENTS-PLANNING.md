# Optional Enhancements Planning

**Status**: READY TO BEGIN  
**Date Started**: October 21, 2025  
**Total Estimated Time**: 13-18 hours

---

## Enhancement Options (Priority Order)

### 1️⃣ Prison Disposal System (4-5 hours) - HIGH IMPACT

**Objective**: Implement prisoner disposal mechanics (Execute, Experiment, Release, Exchange)

**Implementation Tasks**:
- Prison facility prisoner storage and tracking
- 4 disposal options with consequences
- Karma/relations impact system
- Prisoner lifetime mechanics (30-60 days)
- Interrogation research bonus

**Files to Create/Modify**:
- `engine/basescape/systems/prisoner_system.lua` (NEW)
- `engine/basescape/facilities/prison.lua` (UPDATE)
- Integration with karma system

**Expected Output**: 300-400 LOC new code

**Impact**: Adds moral choice system, increases basescape depth

---

### 2️⃣ Region System Verification (1-2 hours) - MEDIUM IMPACT

**Objective**: Verify region system is fully connected to provinces and functions properly

**Verification Tasks**:
- Check region data structure
- Verify province-to-region mapping
- Validate region properties affect mission generation
- Confirm region population affects recruitment
- Test region ownership mechanics

**Files to Check**:
- `engine/geoscape/world/regions.lua`
- `engine/geoscape/world/provinces.lua`
- `engine/geoscape/missions/mission_generator.lua`

**Expected Output**: Verification report + any bug fixes needed

**Impact**: Quality assurance, potential bug fixes

---

### 3️⃣ Travel System Review (2-3 hours) - MEDIUM IMPACT

**Objective**: Validate travel mechanics (fuel, time, events)

**Review Tasks**:
- Verify fuel consumption mechanics
- Check travel time calculation
- Validate en-route event handling
- Confirm interception mechanics during travel
- Test multi-leg journey support

**Files to Check**:
- `engine/geoscape/travel/travel_system.lua`
- `engine/geoscape/travel/fuel_system.lua`
- `engine/geoscape/travel/events.lua`

**Expected Output**: Review report + any bug fixes

**Impact**: Ensures core gameplay loop works smoothly

---

### 4️⃣ Portal/Multi-World System (6-8 hours) - ADVANCED FEATURE

**Objective**: Implement multi-world portal connectivity (advanced feature)

**Implementation Tasks**:
- Portal data structure and storage
- Multi-world state management
- Portal travel mechanics
- Inter-world distance calculations
- Portal activation and discovery

**Files to Create/Modify**:
- `engine/geoscape/portals/portal_system.lua` (NEW)
- `engine/geoscape/world/world.lua` (UPDATE)
- Integration with travel system

**Expected Output**: 500-600 LOC new code

**Impact**: Adds advanced late-game mechanic

---

## Recommended Approach

**Sequence**: 1 → 2 → 3 → 4 (priority order)

**Option A**: Do all 4 (13-18 hours)
**Option B**: Do 1, 2, 3 (7-10 hours)
**Option C**: Do just 1 and 2 (5-7 hours)
**Option D**: Do just 1 (4-5 hours)

---

## Which Would You Like To Do?

Enter:
- **A** - All 4 enhancements (full feature set)
- **B** - 1, 2, 3 (practical gameplay features)
- **C** - 1, 2 (essential features)
- **D** - Just 1 (quick prison system)
- **CUSTOM** - Specify which ones you want
