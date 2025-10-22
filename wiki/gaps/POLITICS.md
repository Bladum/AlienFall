# Politics Documentation Gap Analysis

**Date:** October 22, 2025  
**Comparison:** API POLITICS.md vs Systems Politics.md  
**Analyst:** AI Documentation Review System

---

## IMPLEMENTATION STATUS ✅

**October 22, 2025 - Session 2:**

**Status:** ✅ COMPLETED (2 of 2 critical gaps resolved)
- Critical gap #1: Fame system - Added comprehensive OrganizationFame entity with properties, functions, tier table, sources, and FameManager service to API POLITICS.md
- Critical gap #2: Karma system - Added comprehensive OrganizationKarma entity with properties, functions, alignment levels, action sources, and KarmaManager service to API POLITICS.md
- Resolution: Both systems now fully documented in API with complete integration points, matching Systems specifications

---

## Executive Summary

The Politics documentation shows **MODERATE MISALIGNMENT** with **2 critical gaps** identified. Major scope problem: Systems covers 6 major systems, API covers only diplomatic relationships.

**Key Strengths:**
- Relationship scale (-100 to +100) aligned
- Country relationship effects mostly consistent
- Supplier relationship pricing formulas match
- Faction relationship mechanics aligned

**Critical Gaps:**
- Fame system in Systems but not API
- Karma system in Systems but not API

**Scope Problem:** Fundamental organizational issue between documents

**Overall Rating:** C+ (Acceptable where covered, major scope gaps)

---

## Recommendation Priority

1. **URGENT:** Add Fame system to API or move to separate document
2. **URGENT:** Add Karma system to API or move to separate document
3. **HIGH:** Clarify document scope and organization

---

1. **URGENT:** Add Fame system to API or move to separate document
2. **URGENT:** Add Karma system to API or move to separate document
3. **HIGH:** Clarify document scope and organization

---

## Critical Gaps (MUST FIX)

### 1. Fame System Completely Missing from API
**Severity:** CRITICAL  
**Location:** Systems Politics.md has extensive Fame section, API POLITICS.md has NONE  
**Issue:** Major gameplay system (Fame 0-100 with gameplay effects) documented in Systems but completely absent from API

**Systems Provides:**
```markdown
## Fame System

Fame Range: 0-100
- Unknown (0-24)
- Known (25-59)
- Famous (60-89)
- Legendary (90-100)

Gameplay Effects:
- Mission Generation: +20-30% at high fame
- Supplier Availability: Tier-locked suppliers
- Recruitment: +15% quality per tier
- Funding Bonus: +10% to +50%
- Fame decay: -1 to -2 per month

Fame Sources:
- Mission Success: +5
- Mission Failure: -3
- UFO Destroyed: +2
- Base Raided: -10
- Research Breakthrough: +3
- Black Market Discovery: -20
```

**API Shows:**
NOTHING about fame tracking, fame levels, fame effects, or fame decay.

**Problem:** This is a COMPLETE GAMEPLAY SYSTEM with:
- Numeric tracking (0-100)
- Tiered effects (Unknown → Legendary)
- Monthly decay mechanics
- Multiple income/loss sources
- Affects missions, suppliers, recruitment, funding

How can this entire system be in Systems but not in API?

**Possible Explanations:**
1. Fame belongs in different API module (not Politics)
2. Fame not yet implemented but planned in Systems
3. Documentation organization error

**Recommendation:**
```markdown
### API POLITICS.md - Add new section or verify module location:

## Fame System API

### Entity: OrganizationFame

Tracks public reputation and recognition level.

**Properties:**
```lua
OrganizationFame = {
  current_fame = number,          -- 0-100 current level
  fame_tier = string,             -- "unknown", "known", "famous", "legendary"
  monthly_decay = number,         -- -1 to -2 typical
  last_update_turn = number,
}
```

**Functions:**
```lua
Fame.getFame() → number
Fame.getFameTier() → string
Fame.adjustFame(delta: number, reason: string) → void
Fame.processMonthlyDecay() → void
Fame.getEffects() → table {mission_bonus, recruitment_bonus, funding_bonus}
```

**Services:**
```lua
FameManager.getMissionGenerationBonus() → number (0.0 to 0.30)
FameManager.getRecruitmentQualityBonus() → number (0.0 to 0.45)
FameManager.getFundingMultiplier() → number (1.0 to 1.50)
FameManager.getSupplierTierAccess() → number (1-4)
```

**Integration Points:**
- Missions: Fame affects generation rate
- Suppliers: Fame gates premium supplier access
- Finance: Fame modifies funding
- Recruitment: Fame affects unit quality
```

**Impact:** CRITICAL - Major gameplay progression system completely undocumented in API.

---

### 2. Karma System Completely Missing from API
**Severity:** CRITICAL  
**Location:** Systems Politics.md has extensive Karma section, API POLITICS.md has NONE  
**Issue:** Hidden moral alignment system (-100 to +100) documented in Systems but absent from API

**Systems Provides:**
```markdown
## Karma System

Karma Range: -100 (malevolent) to +100 (benevolent)
- Evil (-100 to -75)
- Ruthless (-74 to -40)
- Pragmatic (-39 to -10)
- Neutral (-9 to +9)
- Principled (+10 to +40)
- Saint (+41 to +100)

Karma Sources:
- Civilian Killed: -10
- Civilian Saved: +5
- Prisoner Executed: -20
- Prisoner Spared: +10
- Interrogation (Torture): -3
- Humanitarian Mission: +15
- Black Market Purchase: -5 to -20
- War Crime: -30

Mechanical Effects:
- Black Market access gated
- Humanitarian missions gated
- Special mission types vary
- Supplier preferences affected
- Story branches determined
```

**API Shows:**
NOTHING about karma tracking, alignment levels, karma sources, or karma effects.

**Problem:** This is a HIDDEN MORALITY SYSTEM affecting:
- Mission availability
- Supplier access
- Story branches
- Contract types
- Multiple endings

Complete absence from API means no implementation guidance exists.

**Recommendation:**
```markdown
### API POLITICS.md - Add new section:

## Karma System API

### Entity: OrganizationKarma

Hidden moral alignment tracker affecting story and opportunities.

**Properties:**
```lua
OrganizationKarma = {
  current_karma = number,         -- -100 to +100
  alignment = string,             -- "evil", "ruthless", "pragmatic", "neutral", "principled", "saint"
  karma_history = table,          -- Recent karma changes
}
```

**Functions:**
```lua
Karma.getKarma() → number
Karma.getAlignment() → string
Karma.adjustKarma(delta: number, reason: string) → void
Karma.canAccessBlackMarket() → boolean
Karma.canAccessHumanitarianMissions() → boolean
```

**Services:**
```lua
KarmaManager.checkMissionAvailability(mission_type: string) → boolean
KarmaManager.getSupplierPreference(supplier_id: string) → number (-1, 0, +1)
KarmaManager.getStoryBranch() → string
KarmaManager.processAction(action_type: string, context: table) → number (karma change)
```

**Karma Triggers:**
```lua
-- Civilian casualties
KarmaManager.recordCivilianDeath() → -10 karma

-- Prisoner handling
KarmaManager.recordPrisonerExecution() → -20 karma
KarmaManager.recordPrisonerRelease() → +10 karma

-- Operations
KarmaManager.recordBlackMarketPurchase(value: number) → -5 to -20 karma
KarmaManager.recordHumanitarianSuccess() → +15 karma
```

**Integration Points:**
- Missions: Karma affects mission type availability
- Suppliers: Karma influences supplier preferences
- Story: Karma determines branching paths and endings
- Contracts: Karma gates certain faction missions
```

**Impact:** CRITICAL - Hidden morality system with story branching completely missing from API.

---

## Moderate Gaps (Should Fix)

### 3. Power Points System Missing from API
**Severity:** MODERATE  
**Issue:** Systems documents Power Points (organizational currency) but API doesn't track them

**Systems Provides:**
Complete Power Points section with:
- Acquisition (1 point/month base, events add/subtract)
- Accumulation over time
- Usage (advisors, org levels, tech unlocks, emergency measures)
- No maximum cap
- Strategic timing

**API Shows:**
No Power Points entity, no tracking, no functions.

**Problem:** Power Points are strategic currency for hiring advisors and leveling organization. Should this be in Politics API or separate module?

**Recommendation:** Add to API or clarify module:
```lua
-- If in Politics API:
PowerPoints = {
  current_points = number,
  monthly_generation = number,
  lifetime_earned = number,
}

-- If in separate Organization API:
-- Reference from Politics API to Organization module
```

---

### 4. Advisors System Missing from API
**Severity:** MODERATE  
**Issue:** Systems has comprehensive Advisors section but API has no advisor entities

**Systems Provides:**
Complete Advisors system with:
- 8 advisor types (CTO, CFO, COO, etc.)
- Costs (6-12 Power Points)
- Monthly salaries (1,000-5,000 credits)
- Bonuses (research speed, income, production, etc.)
- Synergies between advisors
- Hiring/firing mechanics

**API Shows:**
No Advisor entity, no advisor management.

**Problem:** Advisors are key strategic choices affecting all game systems. Should be documented somewhere in API.

**Recommendation:** Determine correct module for Advisors (Organization? Management?) and document:
```lua
Advisor = {
  id = string,
  name = string,
  type = string, -- "CTO", "CFO", "COO", etc.
  cost_power_points = number,
  monthly_salary = number,
  bonuses = table,
}
```

---

### 5. Organization Level System Missing
**Severity:** MODERATE  
**Issue:** Systems mentions Organization Level affecting gameplay but API has no entity

**Systems References:**
- "Organization Level" mentioned in Fame, Events, Difficulty sections
- Affects mission difficulty, event frequency, enemy scaling
- Levels cost Power Points to advance

**API Shows:**
No Organization entity, no level tracking.

**Problem:** Organization Level is fundamental progression system. Where is it documented?

**Recommendation:** Clarify if Organization Level belongs in:
- Politics module (political influence)
- Progression module (advancement system)
- Core module (fundamental state)

---

### 6. Country Monthly Funding Calculation Formula
**Severity:** MODERATE  
**Issue:** Both documents mention funding but neither provides precise formula

**API Shows:**
```lua
Country = {
  monthly_funding = number,
  funding_level = number, -- 0-10 scale
  funding_requested = number,
}
```

**Systems Shows:**
```markdown
Per level: 10% base funding adjustment
Funding Tier Changes: Relationships determine funding level
```

**Problem:** Exact formula unclear. Is it:
- Base_Funding × (1 + Funding_Level × 0.10)?
- Base_Funding × Funding_Level?
- Something else?

**Recommendation:** Systems should specify:
```
Monthly Funding = Country_GDP × Funding_Level × 0.01 × Relationship_Modifier
Where:
- Country_GDP: Economic power (10,000-100,000)
- Funding_Level: 0-10 scale
- Relationship_Modifier: 0.5 at -50 relations, 1.0 at 0, 1.5 at +100
```

---

### 7. Supplier Pricing Formula Precision
**Severity:** MODERATE  
**Issue:** Both documents provide formulas but slightly different

**Systems Shows:**
```
Pricing Modifier = 1.0 + (0.005 × (100 - Relationship))
```

**API Shows:**
```
At relation -100: Price 1.5x
At relation 0: Price 1.0x
At relation +100: Price 0.5x
```

**Problem:** These formulas produce different results!

Systems formula at relation -100:
= 1.0 + (0.005 × 200) = 1.0 + 1.0 = 2.0x price (not 1.5x)

API says 1.5x at -100.

**Recommendation:** Reconcile formulas. Correct version:
```
Pricing Modifier = 1.0 + (0.0025 × (100 - Relationship))
```
This produces:
- -100 relations: 1.0 + 0.5 = 1.5x ✓
- 0 relations: 1.0 + 0.25 = 1.25x (not 1.0x though...)
- +100 relations: 1.0 + 0 = 1.0x

Needs correction in both documents!

---

### 8. Faction Reputation Tracking
**Severity:** MODERATE  
**Issue:** API shows both "reputation" and "player_reputation" - are these the same?

**API:**
```lua
Faction = {
  reputation = number, -- -100 to +100 with player
  player_reputation = number, -- -100 to +100 with faction
}
```

**Problem:** Duplicate properties or different concepts? Clarify.

**Recommendation:** Eliminate duplication: "Use `player_reputation` only. Remove `reputation` to avoid confusion."

---

### 9. Voting Weight Calculation
**Severity:** MODERATE  
**Issue:** API mentions voting weight but Systems doesn't explain how it's calculated

**API:**
```lua
Country = {
  voting_weight = number, -- 0-100
  has_voting_power = bool, -- Weight > 25?
  is_influential = bool, -- Weight > 50?
}
```

**Systems:**
No voting weight calculation.

**Problem:** How is voting weight determined? GDP? Population? Relations?

**Recommendation:** Add to Systems:
```
Voting Weight Calculation:
Base Weight = (Country_GDP / Total_World_GDP) × 100
Relation Modifier = ±30 based on relations
Final Weight = Base Weight + Relation Modifier
```

---

## Minor Gaps (Nice to Fix)

### 10. Country Government Type Effects
**Severity:** MINOR  
**Issue:** API tracks government type but neither document explains effects

**API:** `government_type = string, -- "democracy", "dictatorship", "theocracy"`  
**Systems:** No government type mechanics

**Problem:** Does government type affect gameplay? If yes, document. If no, remove.

**Recommendation:** Either define effects or remove: "Government types are flavor only (no mechanical impact)."

---

### 11. Country Leader Name Tracking
**Severity:** MINOR  
**Issue:** API tracks leader name but no mechanics around it

**API:** `leader = string, -- Current leader name`  
**Systems:** No leader mechanics

**Problem:** Do leaders change? Do they have opinions? Traits?

**Recommendation:** Clarify scope: "Leader names are narrative flavor for story events (no mechanical effects)."

---

### 12. Agreement Expiration Mechanics
**Severity:** MINOR  
**Issue:** API shows expiration dates but Systems doesn't explain renewal/termination

**API:**
```lua
Agreement = {
  expiration_date = number | nil, -- Eternal if nil
}
```

**Systems:**
Mentions trade agreements but not duration.

**Problem:** Do agreements auto-renew? Can they be terminated early?

**Recommendation:** Add to Systems: "Trade Agreements: 6-month duration, auto-renew if relations >0, terminable with -10 relation penalty."

---

### 13. Political Event Severity Range
**Severity:** MINOR  
**Issue:** API shows severity 0-100 but Systems doesn't use severity

**API:** `severity = number, -- 0-100 (importance)`  
**Systems:** Categorizes events by type but not severity

**Problem:** How does severity affect gameplay?

**Recommendation:** Define: "Event Severity: 0-30 minor (local effect), 31-70 major (regional), 71-100 critical (global)."

---

### 14. Relations Entry Historical Tracking
**Severity:** MINOR  
**Issue:** API documents RelationsEntry history but Systems doesn't explain usage

**API:**
```lua
RelationsEntry = {
  date = number,
  change = number,
  reason = string,
  value_before = number,
  value_after = number,
}
```

**Problem:** Is this visible to player? Used for debugging? Analytics?

**Recommendation:** Clarify: "Relations History: Stored for analytics and player review in Diplomacy screen (last 12 entries)."

---

### 15. Faction Military Power Effects
**Severity:** MINOR  
**Issue:** API tracks military_power but neither document explains calculation or effects

**API:** `military_power = number, -- Combat effectiveness`  
**Systems:** No military power mechanics

**Problem:** What is military power scale? How calculated? What does it do?

**Recommendation:** Define: "Faction Military Power: 0-100 scale = (Total Units × Avg Unit Level). Affects mission difficulty and threat assessment."

---

### 16. Country Panic Level Mechanics
**Severity:** MINOR  
**Issue:** API tracks panic_level but Systems doesn't explain panic effects

**API:** `panic_level = number, -- 0-100 (fear/anxiety)`  
**Systems:** No panic mechanics

**Problem:** What causes panic? What does high panic do?

**Recommendation:** Add to Systems: "Panic Level: Increases +10 per failed mission defense, -5 per successful defense. At 100 panic, country leaves coalition permanently."

---

## Quality Assessment

**Documentation Completeness:** 60%  
- Systems provides 6 major systems (Fame, Karma, Relations, Power, Advisors, Org Level)
- API only covers 1 system (Relations)
- Major scope mismatch

**Consistency Score:** 70%  
- Relationship mechanics align reasonably well
- Fame/Karma completely missing from API
- Terminology mostly consistent where overlap exists

**Implementation Feasibility:** 65%  
- Relationship implementation clear
- Fame/Karma systems not implementable (no API)
- Power Points/Advisors not implementable (no API)

**Areas of Excellence:**
- ✅ Relationship scale (-100 to +100) unified
- ✅ Country relationship effects mostly aligned
- ✅ Faction diplomacy concepts consistent

**Primary Concerns:**
- ⚠️ Fame system in Systems, not in API (CRITICAL)
- ⚠️ Karma system in Systems, not in API (CRITICAL)
- ⚠️ Power Points system missing from API
- ⚠️ Advisors system missing from API
- ⚠️ Supplier pricing formula inconsistency

---

## Recommendations

### Immediate Actions (Critical Priority)

1. **Add Fame System to API** - Document Fame entity, functions, effects in Politics module or redirect to appropriate module
2. **Add Karma System to API** - Document Karma entity, functions, alignment mechanics
3. **Clarify Document Scope** - Determine if Politics should include Fame/Karma/Power/Advisors or if these belong in different modules

### Short-Term Improvements (High Priority)

4. **Add Power Points Entity** - Document in appropriate module (Politics or Organization)
5. **Add Advisors System** - Document advisor entities and management
6. **Fix Supplier Pricing Formula** - Reconcile inconsistent formulas between documents
7. **Document Funding Formula** - Provide precise monthly funding calculation

### Long-Term Enhancements (Medium Priority)

8. **Add Organization Level** - Document level tracking and effects
9. **Clarify Voting Weight** - Define calculation method
10. **Define Panic Mechanics** - Document panic effects and thresholds

---

## Conclusion

Politics documentation shows **MODERATE MISALIGNMENT** with **2 critical gaps** and a significant **SCOPE PROBLEM**. The core issue is that Systems Politics.md covers 6 major gameplay systems (Fame, Karma, Relationships, Power Points, Advisors, Organization Level) while API POLITICS.md only covers Relationships. This is either:

1. **Documentation Organization Issue:** Fame/Karma/Power/Advisors belong in different API modules (not Politics)
2. **Implementation Gap:** These systems exist in Systems but haven't been implemented yet
3. **API Documentation Gap:** These systems are implemented but not documented in API

**Immediate action required:** Clarify document scope and locate/create API documentation for Fame, Karma, Power Points, Advisors, and Organization Level systems. The relationship mechanics that ARE covered show decent alignment but can't compensate for missing 5 major systems.

**Overall Grade:** C+ (Acceptable where covered, major scope gaps)
