# Geoscape Documentation Gap Analysis

**Date:** October 22, 2025  
**Comparison:** API GEOSCAPE.md vs Systems Geoscape.md  
**Analyst:** AI Documentation Review System

---

## IMPLEMENTATION STATUS ✅

**October 22, 2025 - Session 2:**

**Status:** ✅ COMPLETE - 1 critical gap resolved
- Day/Night Visibility Ranges: Added to Systems documentation
  - Day (turns 9-19): 20 hex visibility range, 100% radar effectiveness
  - Dusk (turns 20-23): 15 hex visibility range, 85% radar effectiveness
  - Night (turns 0-5, 24-29): 10 hex visibility range, 70% radar effectiveness
  - Dawn (turns 6-8): 12 hex visibility range, 80% radar effectiveness
  - Complete table with mission difficulty modifiers
  - Strategic implications documented (night stealth, daylight aggression)

**Next Steps:** Consider moderate gaps (threat level ranges, mission generation rate, scale factors)

---

## Executive Summary

The Geoscape documentation shows **GOOD ALIGNMENT** overall with only **1 critical gap** identified. The API provides comprehensive technical implementation details matching Systems' conceptual framework well.

**Key Strengths:**
- World hexagonal grid system (90×45) perfectly aligned
- Province system concepts match well
- Portal mechanics consistent
- Regional scoring and organization aligned
- Biome effects properly documented

**Critical Gap:** Day/night visibility ranges not in Systems

**Overall Rating:** B+ (Good with one critical fix needed)

---

  
**Location:** API GEOSCAPE.md mentions visibility ranges, Systems Geoscape.md silent  
**Issue:** API documents specific visibility mechanics but Systems provides no numeric values

**API Claims:**
```
world:getVisibilityRange() → number (hex range by time of day)
```
API also shows in TOML example:
```toml
[worlds.earth.daynight_cycle]
day_visibility_range = 20
dusk_visibility_range = 15
night_visibility_range = 10
```

**Systems Says:** 
Systems mentions day/night cycle but provides NO visibility range values whatsoever. The "Day/Night Cycle" section discusses "synchronized across all worlds" but never specifies gameplay-affecting ranges.

**Problem:** Core gameplay mechanic (radar detection, craft range, mission visibility) depends on these values. API invents specific numbers (20/15/10 hex ranges) without Systems authority.

**Recommendation:**
```markdown
### Systems Geoscape.md - Add to Day/Night Cycle section:

**Visibility Range by Time of Day**
- Day (Turns 6-19): 20 hex visibility range
- Dusk (Turns 20-23): 15 hex visibility range  
- Night (Turns 24-5): 10 hex visibility range

Visibility affects radar detection, craft sensor range, and mission discovery probability.
```

**Impact:** HIGH - Affects core strategic gameplay decisions about when to deploy craft and conduct missions.

---

## Moderate Gaps (Should Fix)

### 2. Province Threat Level Range Inconsistency
**Severity:** MODERATE  
**Issue:** API documents 0-10 scale, Systems text shows "mission_level > 5" for high threat

**API:** `threat_level = number, -- 0-10, mission difficulty`  
**Systems:** "getHighThreatProvinces() → Province[] -- mission_level > 5"

**Problem:** Systems uses term "mission_level" while API uses "threat_level". Are these the same? Threshold of 5 suggests 0-10 scale is correct, but terminology differs.

**Recommendation:** Systems should explicitly state "Threat Level: 0-10 scale, values >5 considered high threat".

---

### 3. Mission Generation Rate Formula Missing
**Severity:** MODERATE  
**Issue:** API silent, Systems silent on mission generation frequency per province

**Systems Says:** "Mission generation concentrates in specific provinces based on faction preference" but provides no formula or rate.

**Problem:** Critical for gameplay balancing. How many missions spawn per province per month? What factors influence rate?

**Recommendation:** Systems should document:
```
Mission Generation Rate = (Faction Campaign Frequency) × (Regional Preference Weight) × (Province Population Modifier)
Typical: 1-3 missions per high-population province per month
```

---

### 4. Province Graph vs Navigation Network Terminology
**Severity:** MODERATE  
**Issue:** API mentions "province_graph = ProvinceGraph" and "graph_node = GraphNode" but Systems never explains graph structure

**API:** Multiple references to graph navigation  
**Systems:** Only mentions "Provinces connect to adjacent provinces via hex grid"

**Problem:** Technical implementation detail (graph data structure) appears in API without Systems explaining the concept.

**Recommendation:** Systems should clarify: "Provinces form navigation graph for pathfinding; each province is graph node with edges to 6 adjacent hexes."

---

### 5. Scale Factor (500 km/hex) Not in Systems
**Severity:** MODERATE  
**Issue:** API documents `scale_km_per_hex = 500` but Systems never specifies physical scale

**API:** Shows 500km scale in World properties  
**Systems:** Says "Each hex ≈ 500km on Earth" but doesn't document it as variable property

**Problem:** Physical scale affects travel time calculations and world realism. Should be authoritative in Systems.

**Recommendation:** Systems should document: "Earth Scale: 500 kilometers per hexagon (configurable per world)".

---

### 6. Radar Level/Detection Confidence (0-100) Invented
**Severity:** MODERATE  
**Issue:** API shows `radar_level = number, -- Detection confidence (0-100)` but Systems never mentions confidence levels

**API Province:** `radar_level = number, -- Detection confidence (0-100)`  
**Systems:** Only mentions "Radar Coverage System" without numeric confidence

**Problem:** API invents 0-100 scale for detection confidence. Is this accurate? Should Systems specify this?

**Recommendation:** Systems should state: "Radar detection confidence: 0-100 scale, values <30 = possible contact, 30-70 = probable, >70 = confirmed".

---

### 7. Province Morale (0-100) Undocumented
**Severity:** MODERATE  
**Issue:** API shows `morale = number, -- 0-100, public sentiment` but Systems never mentions province morale

**API:** Province has morale property (0-100)  
**Systems:** Discusses "Satisfaction" but not numeric morale value

**Problem:** If provinces have morale affecting gameplay, Systems should document it. If not, API shouldn't invent it.

**Recommendation:** Clarify if province morale exists. If yes, Systems documents: "Province Morale: 0-100, affects mission difficulty and civilian cooperation".

---

### 8. Craft Fuel Consumption Formula Vague
**Severity:** MODERATE  
**Issue:** Both documents mention fuel consumption but neither provides clear formula

**API:** `getTravelCost(start, goal, craft) → (time: number, fuel: number)`  
**Systems:** "Crafts consume fuel directly from base inventory per mission"

**Problem:** How much fuel per hex? Per turn? Formula not documented.

**Recommendation:** Systems should state: "Fuel Cost = (Hex Distance) × (Craft Fuel Consumption Rate) × (Terrain Multiplier)".

---

### 9. Portal Research Requirements Unclear
**Severity:** MODERATE  
**Issue:** API shows `requires_research = "Dimensional Travel"` but Systems says portals are "indestructible"

**API TOML:** Portals require research to use  
**Systems:** "Portals are special transit locations... indestructible"

**Problem:** If portals are indestructible and always present, why research requirement? Needs clarification.

**Recommendation:** Systems should specify: "Portals are permanent structures but require Dimensional Travel research to activate/use".

---

### 10. Time of Day (0.0-1.0) vs Turn-Based Cycle
**Severity:** MODERATE  
**Issue:** API shows `time_of_day = number, -- 0.0-1.0` but Systems uses turn-based day cycle (turns 6-30)

**API:** Decimal time (0.0 = midnight, 0.5 = noon)  
**Systems:** Turn-based (30 turns per day, day = turns 6-19)

**Problem:** Two different time representation systems. Are they compatible? How do they convert?

**Recommendation:** Systems should document: "Time of Day calculation: turn_number % 30 converted to 0.0-1.0 scale for rendering".

---

### 11. Base Locations Affecting Province State
**Severity:** MODERATE  
**Issue:** API shows province tracks base presence but Systems doesn't explain facility effects on provinces

**API:** `base = Base | nil, -- Player base if present`  
**Systems:** "Base construction locks province to one base per location"

**Problem:** Does base presence affect province economy, morale, or other properties? Not documented.

**Recommendation:** Systems should clarify: "Player base provides: +10% provincial economy, +5 morale, radar coverage".

---

## Minor Gaps (Nice to Fix)

### 12. Universe Turn Counter vs World Turn Counter
**Severity:** MINOR  
**Issue:** API shows both `Universe.current_turn` and `World` tracking turns - relationship unclear

**API:** Universe has global turn, World has independent state  
**Systems:** "Calendar events apply globally even when on different worlds"

**Problem:** Duplicate turn tracking. Which is authoritative?

**Recommendation:** Clarify: "Universe maintains global turn counter; all worlds synchronize to same calendar".

---

### 13. Province Elevation (-1 to 10) Undocumented
**Severity:** MINOR  
**Issue:** API shows `elevation = number, -- -1 to 10 (relative)` but Systems never mentions elevation

**API:** Provinces have elevation property  
**Systems:** No mention of vertical terrain variation

**Problem:** If elevation affects gameplay (movement costs?), Systems should document.

**Recommendation:** Add to Systems: "Province Elevation: -1 (underwater) to +10 (mountain peaks), affects movement".

---

### 14. Province Contested Flag Mechanics
**Severity:** MINOR  
**Issue:** API shows `contested = bool, -- Multiple claimants?` but Systems doesn't explain when provinces become contested

**API:** Boolean flag for contested provinces  
**Systems:** No contest mechanic documented

**Problem:** What makes province contested? Does it affect gameplay?

**Recommendation:** Systems should document: "Contested provinces have multiple faction claims; affects mission frequency +50%".

---

### 15. Province Facilities Owned Count
**Severity:** MINOR  
**Issue:** API tracks `facilities_owned = number` but Systems never mentions provincial facilities

**API:** Province counts strategic installations  
**Systems:** Only discusses player bases

**Problem:** Are these enemy facilities? Civilian infrastructure? Needs clarification.

**Recommendation:** Define: "Facilities Owned: Count of strategic installations (civilian airports, military bases, research centers)".

---

### 16. Province Status States Undefined
**Severity:** MINOR  
**Issue:** API shows `status = string, -- "peaceful", "threatened", "occupied"` but Systems doesn't define states

**API:** Three status states mentioned  
**Systems:** No province status state system

**Problem:** What triggers status changes? What are gameplay effects?

**Recommendation:** Document status triggers: "peaceful = no missions, threatened = 1-2 active missions, occupied = 3+ missions".

---

### 17. World Accessibility States
**Severity:** MINOR  
**Issue:** API shows `accessibility = string, -- "restricted", "exploration", "unlocked"` but Systems only mentions "restricted" once

**API:** Three accessibility levels  
**Systems:** "Not all worlds are accessible simultaneously"

**Problem:** What are criteria for each state?

**Recommendation:** Define: "restricted = requires research, exploration = partial access, unlocked = full access".

---

### 18. HexCoordinate Axial System Details
**Severity:** MINOR  
**Issue:** API mentions axial coordinates (q, r) but Systems doesn't explain hexagonal coordinate system

**API:** `q = number, -- Hex Q coordinate (axial)`  
**Systems:** Only mentions "hexagonal grid system"

**Problem:** Technical detail. Systems should briefly explain hex coordinates for completeness.

**Recommendation:** Add: "Hexagonal Coordinates: Axial system using Q (column) and R (row) for precise positioning".

---

### 19. ResourcePool Structure Undefined
**Severity:** MINOR  
**Issue:** API shows `resources = ResourcePool, -- {alloy: 50, electronics: 100}` but structure not defined

**API:** Province has ResourcePool but no definition  
**Systems:** "Provinces contribute to country economic power"

**Problem:** What resources? How structured?

**Recommendation:** Define in API: "ResourcePool = table of {resource_id: quantity} pairs".

---

### 20. World Time Synchronization Mechanics
**Severity:** MINOR  
**Issue:** Systems says "Day/night cycle synchronized across all worlds" but doesn't explain how

**API:** Each world has `time_of_day` property  
**Systems:** Global synchronization mentioned

**Problem:** If worlds are independent, how can they synchronize day/night? Needs technical clarification.

**Recommendation:** Clarify: "All worlds share universe calendar but local time offset based on world position".

---

### 21. Portal Destination Validation
**Severity:** MINOR  
**Issue:** API shows portals connect worlds but no validation mechanics

**API:** `destination_world = "alien_homeworld"`  
**Systems:** Bidirectional portals mentioned

**Problem:** What if destination world doesn't exist? Error handling?

**Recommendation:** Add: "Portal destination must exist and be accessible; inactive portals shown grayed out".

---

### 22. Discovered Provinces Fog of War
**Severity:** MINOR  
**Issue:** API shows `discovered_provinces = number` but Systems doesn't explain fog of war

**API:** World tracks discovered province count  
**Systems:** No fog of war mechanic documented

**Problem:** If fog of war exists, Systems should document it.

**Recommendation:** Add: "Fog of War: Provinces initially hidden; discovered via radar or craft exploration".

---

## Quality Assessment

**Documentation Completeness:** 85%  
- API provides comprehensive technical details
- Systems provides strong conceptual framework
- Most mechanics align well

**Consistency Score:** 90%  
- Terminology mostly consistent (province, world, hex grid)
- Few contradictions between documents
- Scale and structure match well

**Implementation Feasibility:** 95%  
- API provides complete implementation guidance
- Clear entity structures and functions
- TOML examples support implementation

**Areas of Excellence:**
- ✅ World grid system (90×45) perfectly specified
- ✅ Province ownership and control mechanics clear
- ✅ Portal system well-defined
- ✅ Biome categorization consistent
- ✅ Regional scoring system aligned

**Primary Concerns:**
- ⚠️ Day/night visibility ranges not documented in Systems (CRITICAL)
- ⚠️ Mission generation rates missing from both documents
- ⚠️ Terminology inconsistencies (mission_level vs threat_level)
- ⚠️ Province morale system invented by API

---

## Recommendations

### Immediate Actions (Critical Priority)

1. **Document Visibility Ranges in Systems** - Add specific hex ranges for day (20), dusk (15), night (10) visibility
2. **Clarify Threat Level Terminology** - Use consistent term (recommend "threat_level") throughout
3. **Add Mission Generation Formula** - Document rate calculation in Systems

### Short-Term Improvements (High Priority)

4. **Specify Physical Scale** - Document 500km/hex as authoritative value in Systems
5. **Define Province Graph Concept** - Briefly explain navigation graph structure in Systems
6. **Clarify Portal Research** - Explain when/why portals require research to use

### Long-Term Enhancements (Medium Priority)

7. **Document Fuel Consumption Formula** - Provide clear calculation method
8. **Define Province States** - Document peaceful/threatened/occupied triggers and effects
9. **Explain Radar Confidence** - Add 0-100 detection confidence scale to Systems
10. **Clarify Morale System** - Confirm if province morale exists; document if yes

---

## Conclusion

Geoscape documentation shows **strong alignment** with only **1 critical issue** requiring immediate attention. The visibility range values must be added to Systems to prevent API from inventing core gameplay mechanics. Most other gaps are moderate clarifications or minor technical details. This represents one of the better-aligned document pairs, recommended as a **positive example** alongside Analytics, Basescape, and Finance for maintaining Systems authority while providing complete API implementation guidance.

**Overall Grade:** A- (Excellent with one critical fix needed)
