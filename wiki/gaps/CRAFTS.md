# Crafts Gap Analysis

**Analysis Date:** October 22, 2025  
**Comparison:** `wiki/api/CRAFTS.md` vs `wiki/systems/Crafts.md`  
**Status:** ⏳ REQUIRES ATTENTION - Good alignment with 2 critical gaps

---

## IMPLEMENTATION STATUS ✅

**October 22, 2025 - Session 2:**

**Status:** ✅ COMPLETE - All 2 critical gaps resolved
- Craft Stat Ranges: Added comprehensive "Craft Statistics Reference (By Size)" section with tables for HP, Fuel, Speed, Crew, Cargo, Armor, Radar by craft size
  - HP ranges: 100-150 (small) to 500-600 (extra large)
  - Fuel capacity: 500-800 (small) to 6,000-8,000 (extra large)
  - Speed ranges documented with modifiers
  - Crew capacity with addon expansion tables
  - Cargo capacity with weight scaling
  - Armor ratings by craft class
  - Radar power and detection ranges

- Craft Experience & Progression: Expanded to comprehensive "Rank Advancement Table" with:
  - Experience sources table (+1 to +25 XP per source)
  - XP thresholds: 0, 100, 300, 600, 1,000, 1,500, 2,100
  - Stat improvements per rank (HP, Armor, Speed, Accuracy, Dodge, Radar)
  - Promotion mechanics and upgrade trade-off analysis
  - Cumulative stat progression table

**Next Steps:** Verify weapon slot counts, fuel consumption formulas documented, consider moderate gaps

---

## Executive Summary

**Overall Alignment:** GOOD - Both documents are comprehensive and well-aligned on core concepts. API provides implementation details while Systems provides strategic context. Gaps are around specific numeric values and progression rates.

**Critical Issues:** 2 (Craft stats, experience progression)  
**Moderate Issues:** 11  
**Minor Issues:** 8

---

## Priority Actions

1. **CRITICAL:** Document craft stat ranges (HP, fuel, speed, etc.) in Systems
2. **CRITICAL:** Clarify craft experience progression rates
3. **HIGH:** Document fuel consumption formulas
4. **MEDIUM:** Specify addon slot counts and addon effects

---

## Critical Gaps (2)

### 1. Craft Stat Ranges Not Documented
**Severity:** CRITICAL  
**Location:** Craft Statistics section  
**Issue:** API specifies exact ranges for craft stats, Systems describes concepts only.

**API Specifies:**
```lua
Craft = {
  hp_max = number,                -- Range not specified in API code
  fuel_capacity = number,         -- Range not specified
  speed = number,                 -- "Hexes per turn"
  armor_rating = number,          -- "Defense value"
  cargo_capacity = number,        -- "Max weight in kg"
  crew_capacity = number,         -- "Max crew size"
}
```

**API TOML Examples:**
- Skyranger: max_hp = 200, max_fuel = 500, capacity = 10, speed = 2
- Interceptor: max_hp = 150, max_fuel = 800, capacity = 2, speed = 4
- Firestorm: max_hp = 120, max_fuel = 1000, capacity = 1, speed = 5
- Avenger: max_hp = 250, max_fuel = 8000, capacity = 8, speed = 500

**Systems States:**
- "Health (Hit Points): 50 HP (Small Scout) to 500+ HP (Battleship)"
- "Fuel System: fuel stored in base inventory"
- "Speed: Geoscape: Number of province-hexes traversable per turn"
- "Crew Capacity: 4-20+ units depending on craft class"

**Issue:** API provides example values in TOML, Systems provides ranges, but ranges don't align:
- API Avenger speed = 500, but what unit? Hexes per turn?
- Systems says speed is "1-2, High (3-4), Very High (4+)" but API shows 2, 4, 5, 500

**Resolution:** Systems must specify:
- HP range by craft size (small: 100-200, medium: 200-400, large: 400-600, etc.)
- Fuel capacity range (500-8000)
- Speed range (1-5 for tactical, or clarify if 500 is different unit)
- Crew capacity range (1-20)
- Cargo capacity range

---

### 2. Craft Experience & Rank Progression Formula
**Severity:** CRITICAL  
**Location:** Craft Experience & Progression  
**Issue:** API mentions experience system, Systems describes it, but **neither specifies XP requirements for rank advancement**.

**API States:**
```lua
Craft = {
  experience = number,            -- Combat experience
  rank = number,                  -- 0-6 (promotion ranks)
  kills = number,                 -- Total kills (UFO/enemy)
}

-- Functions:
craft:gainExperience(amount: number) → void
craft:promote() → boolean (on rank-up threshold)
craft:getRank() → number
```

**Systems States:**
- "Experience Acquisition: Crafts gain experience through multiple channels"
- "Rank Structure: All units [crafts] are categorized by Rank, representing their experience and specialization level"
- Refers to rank 0-6 system from Units

**BUT:** Neither document specifies:
- How much XP per kill?
- How much XP per mission?
- XP thresholds for rank 0→1, 1→2, etc.

**Resolution:** Systems must document:
- XP per UFO kill (by UFO size/type)
- XP per mission completed
- XP thresholds for each rank (0→1: 100 XP, 1→2: 300 XP, etc.)

---

## Moderate Gaps (11)

### 3. Fuel Consumption Formula
**Severity:** MODERATE  
**Location:** Fuel System  
**Issue:** Systems mentions "1-5 fuel per hex movement" and "fuel consumed automatically", API states "fuel_consumption_per_hex" but doesn't specify values.

**Resolution:** Systems should provide fuel consumption table:
```
Small craft: 1 fuel per hex
Medium craft: 2-3 fuel per hex
Large craft: 4-5 fuel per hex
```

### 4. Weapon Slot Count by Craft Size
**Severity:** MODERATE  
**Location:** Craft Statistics → Weapon Slots  
**Issue:** API states "weapon_slots = number" with examples (2, 3, 4, 6), Systems states "Maximum: 2 weapon slots".

**API TOML Shows:**
- Skyranger: weapon_slots = 2
- Interceptor: weapon_slots = 3
- Firestorm: weapon_slots = 4
- Avenger: weapon_slots = 6

**Systems States:**
- "Maximum: 2 weapon slots (hardpoints) per craft"
- "Large crafts cannot equip 4 weapons; slot count is fixed"

**Conflict:** API shows 3-6 slots, Systems says max 2.

**Resolution:** Clarify if:
- 2 is base, more slots via addons/upgrades?
- Systems is outdated and should be updated to 2-6?
- API TOML examples are incorrect?

### 5. Addon Slot Count
**Severity:** MODERATE  
**Location:** Craft Statistics → Addon Slots  
**Issue:** API mentions "addon_slots", Systems states "Maximum: 2 addon slots per craft".

**API States:**
```lua
Craft = {
  addons = Addon[],               -- Installed upgrades
}
```

**Systems States:**
- "Maximum: 2 addon slots per craft"
- Lists addon examples but doesn't specify which crafts have how many slots

**Resolution:** Clarify if all crafts have exactly 2 addon slots or if it varies by craft size.

### 6. Damage Percentage Effect on Performance
**Severity:** MODERATE  
**Location:** Health & Damage section  
**Issue:** API states "damage_percentage affects speed/fuel", Systems doesn't document this mechanic.

**API States:**
```lua
Craft = {
  damage_percentage = number,     -- 0-100, affects speed/fuel
}
```

**Systems States:**
- Only mentions HP and repair mechanics
- No mention of damage affecting performance

**Resolution:** Systems should document: "When craft HP drops below 50%, speed is reduced by 10% and fuel consumption increases by 20%."

### 7. Stealth Rating Mechanic
**Severity:** MODERATE  
**Location:** Craft Detection  
**Issue:** API TOML shows "stealth_rating = 0.3" for Firestorm, Systems describes "Cover (Stealth/Concealment)" but doesn't specify numeric values.

**Resolution:** Systems should document stealth rating scale (0.0 = no stealth, 1.0 = maximum stealth) and effects.

### 8. Landing Noise Mechanic Details
**Severity:** MODERATE  
**Location:** Landing Noise & Stealth Budget  
**Issue:** Systems provides complete landing noise mechanic with specific values, API doesn't mention it at all.

**Systems Specifies:**
- Stealth Budget: 250 points
- Large Craft: 150-200 landing noise
- Small Craft: 20-50 landing noise

**API States:**
- No mention of landing noise or stealth budget

**Resolution:** API should add landing noise property or Systems should clarify if this is planned vs implemented.

### 9. Craft Weapon Properties
**Severity:** MODERATE  
**Location:** CraftWeapon entity (mentioned but not detailed in either document)  
**Issue:** Both documents mention craft weapons but don't detail weapon properties.

**API Mentions:**
```lua
Craft = {
  weapons = CraftWeapon[],        -- Equipped weapons
}
```

**Systems States:**
- "Weapons: Cannons, Missiles, Laser Arrays, etc. (see Weapons section)"
- But no weapons section in Crafts.md

**Resolution:** Create CraftWeapon entity documentation or reference Items system.

### 10. Repair Rate Formula
**Severity:** MODERATE  
**Location:** Craft Maintenance & Repair  
**Issue:** API has repair functions but doesn't specify repair rate, Systems mentions repair but no specifics.

**API States:**
```lua
craft:repairDamage(amount) → void
craft:repairFull() → bool
craft:repair(amount: number) → (remaining_damage: number)
```

**Systems States:**
- "Repairs: See Maintenance section"
- Maintenance section mentions "Base recovery: +1 HP per week" (but that's for units, not crafts)

**Resolution:** Systems should specify craft repair rates:
- Passive repair in base: X HP per day
- Active repair with facility: Y HP per day
- Emergency repair cost: Z credits per HP

### 11. Addon Weight/Power Requirements
**Severity:** MODERATE  
**Location:** Craft Addons & Upgrades  
**Issue:** Systems lists addons with effects but doesn't mention weight or power requirements, API mentions addons but doesn't detail requirements.

**Resolution:** Systems should document if addons have installation requirements beyond just slot availability.

### 12. Craft Manufacturing Time
**Severity:** MODERATE  
**Location:** Craft Manufacturing  
**Issue:** API TOML shows "build_time = 90" for Avenger, Systems states "1-4 weeks depending on craft class".

**Resolution:** Clarify build time units (days vs weeks) and provide build time by craft class.

### 13. Craft Maintenance Cost Formula
**Severity:** MODERATE  
**Location:** Craft Cost  
**Issue:** API shows "maintenance_cost = 15000" for Avenger, Systems doesn't mention maintenance costs.

**Resolution:** Systems should document monthly maintenance costs by craft size/type.

---

## Minor Gaps (8)

### 14. Craft Status Enums
**Severity:** MINOR  
**Issue:** API lists status strings ("ready", "flying", "damaged", "refueling", "deployed"), Systems describes states conceptually.

**Resolution:** Acceptable - API provides implementation details.

### 15. Craft Type Classification Strings
**Severity:** MINOR  
**Issue:** API uses "transport", "interceptor", "assault", "gunship", Systems uses same plus additional types (bomber, scout, etc.).

**Resolution:** Minor - both documents generally aligned.

### 16. Function Signatures
**Severity:** MINOR  
**Issue:** API provides extensive function signatures, Systems doesn't.

**Resolution:** Acceptable division of concerns.

### 17. TOML Configuration Format
**Severity:** MINOR  
**Issue:** API provides TOML examples, Systems doesn't.

**Resolution:** Acceptable - API documents implementation format.

### 18. Integration Points Section
**Severity:** MINOR  
**Issue:** API has integration points section, Systems doesn't.

**Resolution:** Acceptable - API documents technical integration.

### 19. Usage Examples
**Severity:** MINOR  
**Issue:** API provides code examples, Systems doesn't.

**Resolution:** Acceptable - API provides implementation guidance.

### 20. Craft Types by Engine & Terrain
**Severity:** MINOR  
**Issue:** Systems has detailed "Craft Types by Engine & Terrain" section (air-based, water-based, hybrid), API doesn't distinguish.

**Resolution:** Acceptable - Systems provides strategic design context, API provides runtime properties.

### 21. Craft-Unit Integration
**Severity:** MINOR  
**Issue:** Systems has "Craft-Unit Integration" section discussing how units board/deploy, API doesn't detail this.

**Resolution:** Acceptable - deployment mechanics likely documented in Missions or Battlescape systems.

---

## Recommendations

### Immediate Actions (Critical Gaps)

1. **Craft Stat Ranges:**
   - Add to Systems: HP ranges by craft size (small: 100-200, medium: 200-400, large: 400-600)
   - Add to Systems: Fuel capacity ranges (500-8000)
   - Add to Systems: Speed ranges (1-5 hexes per turn for tactical, clarify if different for strategic)
   - Add to Systems: Crew capacity ranges (1-20)
   - Add to Systems: Cargo capacity ranges (kg or weight units)
   - Verify API TOML examples align with Systems ranges

2. **Craft Experience & Ranks:**
   - Add to Systems: XP per UFO kill (by UFO type/size)
   - Add to Systems: XP per mission completed
   - Add to Systems: XP thresholds for each rank (0→1, 1→2, etc.)
   - Add to API: Reference Systems XP tables

### Short-Term Actions (Moderate Gaps)

3. **Fuel Consumption:** Document fuel costs per hex by craft size
4. **Weapon Slots:** Resolve conflict (API shows 2-6 slots, Systems says max 2)
5. **Addon Slots:** Clarify if all crafts have 2 slots or varies
6. **Damage Effects:** Document how HP damage affects speed/fuel consumption
7. **Stealth Rating:** Document stealth scale and effects in Systems
8. **Landing Noise:** Add to API if implemented, or clarify as planned in Systems
9. **Craft Weapons:** Create CraftWeapon documentation or reference Items system
10. **Repair Rates:** Specify passive/active repair rates and costs
11. **Addon Requirements:** Document weight/power/tech requirements for addons
12. **Build Time:** Clarify time units and provide table by craft class
13. **Maintenance Costs:** Document monthly upkeep by craft type

### Long-Term Actions (Minor Gaps)

14. Consider adding craft status enum list to Systems for completeness
15. Cross-reference craft types with mission deployment rules
16. Document craft-unit boarding/deployment mechanics (may belong in separate system)

---

## Quality Assessment

**Strengths:**
- Both documents comprehensive and well-structured
- Core craft concepts aligned (movement, fuel, combat, crew)
- Systems provides excellent strategic context (landing noise, craft roles, manufacturing)
- API provides good implementation structure

**Weaknesses:**
- Stat ranges not clearly documented in Systems
- Experience/rank progression formula missing from both
- Weapon slot count conflict between documents
- Some mechanics in Systems not reflected in API (landing noise)
- Fuel consumption formula not specified

**Overall:** Good alignment. The foundation is solid, but numeric values and progression formulas need to be specified in Systems to prevent API from inventing them. Less problematic than AI Systems or Battlescape gaps, but still requires attention to stat ranges and experience system.
