# Units Gap Analysis

**Analysis Date:** October 22, 2025  
**Comparison:** `wiki/api/UNITS.md` vs `wiki/systems/Units.md`  
**Status:** ✅ COMPLETED - All 3 critical gaps resolved

---

## IMPLEMENTATION STATUS ✅

**October 22, 2025 - Session 2:**

# UNITS

**Status**: ✅ COMPLETED (3 of 3 gaps resolved)
- Critical gap #1: Action Points range discrepancy (user says 1-4, Systems table says 2-5) - RESOLVED: Systems now documents "Valid Range: 1-4 AP per turn after all modifiers applied"
- Critical gap #2: Transformation requirements not specified - RESOLVED: Systems now documents rank-based requirements and XP progression
- Critical gap #3: Trait point value limits unclear (2-4 points range?) - RESOLVED: Systems now documents "Units have exactly 4 trait points available"

---

## Executive Summary

**Overall Alignment:** GOOD - Both documents are comprehensive and well-aligned on core unit mechanics. Systems provides authoritative stat ranges and progression tables.

**Critical Issues:** 3 (Action Points range, Transformation requirements, Trait points)  
**Moderate Issues:** 9  
**Minor Issues:** 7

**Overall Rating:** B+ (Good with 3 critical clarifications needed)

---

  
**Location:** Combat Statistics section  
**Issue:** User specified "action point range is 1-4" but Systems table shows **"2-5"** as AP range.

**API States:**
```lua
Unit = {
  action_points = number,         -- AP per turn (usually 4)
}

-- In Battlescape:
"action_points_base = 4"
```

**Systems States:**
- Table: "Action Points (AP): Base: 4 per turn (fixed across all units), **Range: 2-5**"
- Later: "Units have 4 AP per turn that resets every turn"

**User's Example:** "action point range is 1-4"

**Issue:** Three different values:
- User says: 1-4
- Systems says: 2-5  (in table)
- Systems says: 4 base (in text)
- API says: 4 base (in config)

**Resolution:** Systems must clarify:
- Base AP: 4 (all documents agree on this)
- Valid range after modifiers: Is it 1-4 (user's understanding) or 2-5 (Systems table)?
- What causes AP reduction below base 4?
- What is the absolute minimum AP (1 or 2)?

---

### 2. Transformation Requirements Not Specified
**Severity:** CRITICAL  
**Location:** Unit Transformations & Advancement  
**Issue:** API documents comprehensive transformation system with **specific level/XP requirements**, but Systems only describes transformation effects without prerequisites.

**API Specifies:**
```lua
UnitTransformation = {
  required_level = 8,                         -- Must reach this level
  required_experience = 50000,                -- Alternative XP requirement
  required_kills = 100,                       -- Combat prerequisite
  required_missions = 10,                     -- Mission count prerequisite
}

sectoid_transformation_paths = {
  {level = 1, name = "Sectoid Warrior", ...},
  {level = 5, name = "Sectoid Ranger", ...},
  {level = 8, name = "Sectoid Elite", requirement = {kills = 100, missions = 10}},
  {level = 12, name = "Sectoid Commander", ...}
}
```

**Systems States:**
- Lists transformations with stat bonuses and costs
- "Combat Augmentation: Rank 3+, Biology Lab, 5,000 credits"
- "Psionic Awakening: Rank 3+, Psi Lab, 8,000 credits"

**Gap:** API shows level-based requirements (level 1, 5, 8, 12), Systems shows rank-based (Rank 2+, 3+, 4+). Are level and rank the same thing?

**Resolution:** Systems must specify:
- Is "level" the same as "rank"?
- What XP amounts are required for transformations?
- Document transformation progression paths with prerequisites

---

### 3. Trait Point Value System
**Severity:** CRITICAL  
**Location:** Unit Traits section  
**Issue:** Systems describes trait point system but doesn't specify **maximum point value** clearly.

**Systems States:**
- "Traits: Each unit can possess multiple traits, balanced by point value"
- "Trait Point Value: Each trait has a value (typically 1-3 points)"
- "Units can accumulate traits up to a **total value of 2-4 points**"

**Issue:** "2-4 points" is a range, not a specific limit. Does this mean:
- Minimum 2 points, maximum 4 points?
- Varies by unit class (some get 2, some get 4)?
- Player chooses anywhere in 2-4 range?

**Resolution:** Systems must specify:
- Exact point limit (e.g., "4 points maximum")
- Whether limit varies by class/rank
- Starting trait points at recruitment vs gained through progression

---

## Moderate Gaps (9)

### 4. Base Stat Ranges Consistency
**Severity:** MODERATE  
**Issue:** Both documents state "6-12" as base stat range for humans, but some discrepancies in derived stats.

**API States:**
```lua
Unit = {
  strength = number,              -- 6-12 range
  dexterity = number,             -- 6-12 range
  constitution = number,          -- 6-12 range
  intelligence = number,          -- 6-12 range
  perception = number,            -- 6-12 range
  will = number,                  -- 6-12 range
}
```

**Systems States:**
- Primary Stats table: "Range: 6-12" for all stats
- But also: "Bravery (BRA): 6–12"
- And: "Sanity: 6-12"
- And: "Psi Skill (PSI): 0–20"

**Consistency Check:**
- Most stats: 6-12 ✓
- Psi: 0-20 (makes sense for specialized stat) ✓
- AP range: 2-5 or 1-4? (see Critical Gap #1)

**Resolution:** Minor discrepancy, mostly consistent.

### 5. Experience Requirements Table
**Severity:** MODERATE  
**Issue:** Both documents have XP requirement tables but with slight differences in presentation.

**API States:**
```lua
-- Progression Requirements
| Rank | XP Required | Title |
|------|-------------|-------|
| 0 | 0 | Rookie |
| 1 | 100 | Veteran |
| 2 | 300 | Expert |
| 3 | 600 | Specialist |
| 4 | 1000 | Elite |
| 5 | 1500 | Commander |
| 6 | 2500 | Legend |
```

**Systems States:**
```
| Rank | Experience Required | Description |
|------|-------------------|-------------|
| Rank 0 | 0 XP | Basic/Conscript |
| Rank 1 | 100 XP | Agent |
| Rank 2 | 300 XP | Specialist |
| Rank 3 | 600 XP | Expert |
| Rank 4 | 1,000 XP | Master |
| Rank 5 | 1,500 XP | Elite |
| Rank 6 | 2,100 XP | Hero |
```

**Conflict:** Rank 6 requirement differs:
- API: 2,500 XP
- Systems: 2,100 XP

**Resolution:** Clarify which is correct.

### 6. Smart/Stupid Trait XP Modifier
**Severity:** MODERATE  
**Issue:** Both documents mention Smart trait gives "+20% XP" but don't specify if this applies to all XP sources.

**Resolution:** Clarify: Does +20% XP apply to combat kills, mission completion, training, and objectives?

### 7. Weapon/Armor Stat Bonuses Not Documented
**Severity:** MODERATE  
**Location:** Equipment section  
**Issue:** Systems lists weapons/armor with some stats, but doesn't specify stat bonuses to unit.

**Systems Weapon Table:**
| Weapon | Range | AP | Damage | Accuracy | EP Cost |
|--------|-------|-----|--------|----------|---------|
| Pistol | 8 | 1 | 12 | 70% | 5 |
| Rifle | 15 | 2 | 18 | 70% | 8 |

**Missing:** Do these weapons provide stat bonuses to the unit beyond their inherent properties?
- Example: Sniper Rifle gives +20% accuracy when equipped?
- Example: Heavy Armor gives +5 strength?

**Resolution:** Either:
- Document that equipment provides no stat bonuses (only weapon properties apply), OR
- Document stat bonuses per equipment type

### 8. Health Regeneration Rates
**Severity:** MODERATE  
**Location:** Unit Health & Recovery  
**Issue:** Systems specifies health recovery rates, API mentions heal functions but doesn't specify rates.

**Systems States:**
- "Passive Recovery: +1 HP per week in barracks"
- "Active Recovery: Medikit use: 3 HP (Medic class) or 2 HP (other classes)"

**API States:**
```lua
unit:heal(amount: number) → void
UnitCombat.healUnit(unit: Unit, amount: number) → void
```

**Resolution:** API should reference Systems recovery rates or document them in API.

### 9. Morale Recovery Rates
**Severity:** MODERATE  
**Location:** Unit Morale & Psychology  
**Issue:** Systems mentions morale recovery but doesn't specify exact rates.

**Systems States:**
- "Rest action: 2 AP → +1 morale per turn"
- "Leader aura: +1 morale to nearby allies per turn"
- "Post-mission: Morale resets to base BRAVERY value"

**API Doesn't Specify:**
- Passive morale recovery rate per turn
- How many turns to full morale recovery?

**Resolution:** Systems should document: "Morale automatically recovers +1 per turn when not under stress, up to BRAVERY stat maximum."

### 10. Sanity Recovery Rates
**Severity:** MODERATE  
**Location:** Unit Morale & Psychology  
**Issue:** Systems specifies sanity recovery, but some ambiguity remains.

**Systems States:**
- "Base recovery: +1 sanity per week (automatic, passive)"
- "Hospital facility: +1 additional sanity per week"
- "Temple facility: +1 additional sanity per week"

**Issue:** Do Hospital and Temple stack? (+3 total?) or exclusive? (+2 max?)

**Resolution:** Clarify stacking rules for facility bonuses.

### 11. Critical Hit Wound Mechanic
**Severity:** MODERATE  
**Location:** Wounds System  
**Issue:** Systems states "Critical hits always inflict 1 wound", but what about non-critical hits?

**Systems States:**
- "Infliction: Critical hits always inflict 1 wound"
- "Severe damage can cause permanent wounds: Critical hit while at <3 HP: Wound inflicted"

**Conflict:** Are wounds ONLY from crits, or can low HP also cause wounds without a crit?

**Resolution:** Clarify wound infliction rules:
- Crits always wound (regardless of HP)
- Low HP crits wound (redundant with above?)
- Non-crits can wound if HP < 3? (needs clarification)

### 12. Trait Requirements Section
**Severity:** MODERATE  
**Location:** Unit Traits → Trait Requirements & Synergies  
**Issue:** Systems mentions class/race requirements for traits but doesn't provide comprehensive list.

**Systems States:**
- "Leader" trait requires Rank 2+ and leadership-class specialization
- "Alien Biology" trait only available to alien units

**Resolution:** Provide complete trait requirement table showing which traits require which classes/ranks/races.

---

## Minor Gaps (7)

### 13. Status Effect Enums
**Severity:** MINOR  
**Issue:** API lists status effect strings, Systems describes them conceptually.

**Resolution:** Acceptable - API provides implementation details.

### 14. Unit Type Enums
**Severity:** MINOR  
**Issue:** API uses "human", "alien", "mechanical", Systems describes types.

**Resolution:** Acceptable.

### 15. Function Signatures
**Severity:** MINOR  
**Issue:** API provides extensive function signatures, Systems doesn't.

**Resolution:** Acceptable division of concerns.

### 16. TOML Configuration Format
**Severity:** MINOR  
**Issue:** API provides TOML examples for unit classes, Systems doesn't.

**Resolution:** Acceptable - API documents implementation format.

### 17. Usage Examples
**Severity:** MINOR  
**Issue:** API provides code examples, Systems doesn't.

**Resolution:** Acceptable - API provides implementation guidance.

### 18. Face & Appearance System Details
**Severity:** MINOR  
**Issue:** Systems documents face customization (64 combinations), API doesn't mention.

**Resolution:** Acceptable - Systems documents design feature, API doesn't need to implement yet.

### 19. Personal Statistics Tracking
**Severity:** MINOR  
**Issue:** Systems lists tracked stats (missions, kills, wounds), API provides some but not all.

**Resolution:** API should add any missing stat tracking based on Systems requirements.

---

## Recommendations

### Immediate Actions (Critical Gaps)

1. **Action Points Range:**
   - **PRIORITY:** Resolve user's example (1-4) vs Systems table (2-5)
   - Add to Systems: "Base AP: 4. After all modifiers (health, morale, sanity): minimum 1 AP, maximum 5 AP"
   - Clarify if user's 1-4 is a misunderstanding or if Systems table is wrong

2. **Transformation Requirements:**
   - Add to Systems: Full transformation progression table with level/XP requirements
   - Clarify relationship between "level" and "rank" (are they the same?)
   - Document XP thresholds for each transformation tier

3. **Trait Point Value:**
   - Add to Systems: "Units have exactly 4 trait points to allocate at creation"
   - Or: "Units start with 2 trait points, gain +1 per 3 ranks (max 4)"
   - Specify if limit is fixed or variable

### Short-Term Actions (Moderate Gaps)

4. **Experience Table Discrepancy:** Resolve Rank 6 XP (2,100 vs 2,500)
5. **Smart Trait XP:** Clarify that +20% applies to all XP sources
6. **Equipment Stat Bonuses:** Document if equipment provides stat bonuses beyond weapon properties
7. **Health Recovery:** API should reference Systems rates
8. **Morale Recovery:** Document passive morale recovery rate
9. **Sanity Recovery:** Clarify facility stacking rules
10. **Wound Infliction:** Clarify all wound conditions (crits, low HP, etc.)
11. **Trait Requirements:** Create comprehensive trait requirement table
12. **Stat Gain Progression:** Verify Systems table matches intended design

### Long-Term Actions (Minor Gaps)

13. Consider documenting status effect enums in Systems
14. Add personal statistics tracking to API based on Systems requirements
15. Cross-reference face customization with UI implementation

---

## Quality Assessment

**Strengths:**
- Both documents comprehensive and well-structured
- Core stat system aligned (6-12 base range)
- Experience progression table mostly consistent
- Trait system well-documented in Systems
- Equipment and inventory mechanics detailed in both

**Weaknesses:**
- Action point range needs clarification (user example vs Systems table)
- Transformation system has level/rank terminology confusion
- Trait point value limit ambiguous (2-4 points range)
- Some numeric values (Rank 6 XP) differ between documents
- Equipment stat bonuses not clearly documented

**Overall:** Good alignment. The foundation is solid with authoritative stat ranges in Systems. Main issues are around clarifying action point ranges (critical for user's concern), transformation requirements, and trait point limits. Much better than AI Systems or Battlescape where API invented many values.
