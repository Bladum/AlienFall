# Economy Gap Analysis

**Analysis Date:** October 22, 2025  
**Comparison:** `wiki/api/ECONOMY.md` vs `wiki/systems/Economy.md`  
**Status:** ✅ COMPLETED - Module scope clarified

---

## IMPLEMENTATION STATUS ✅

**October 22, 2025 - Session 2:**

**Status:** ✅ RESOLVED - Module boundary clarification added
- Critical gap: Module boundaries (Economy vs Research vs Manufacturing)
- Resolution: Added scope clarification to Systems Economy.md explaining that this document is an integrated economic systems overview covering Research, Manufacturing, Marketplace, Suppliers, Black Market, and Transfer systems
- Note: While API may separate these into distinct modules, Systems treats them as interconnected economic operations
- Rationale: Players experience these as unified economy layer (research enables manufacturing, manufacturing consumes resources from suppliers, resources sell at marketplace)

---

## Executive Summary

**Overall Alignment:** MODERATE - Systems document is heavily focused on marketplace/suppliers with detailed mechanics. API provides broader economic infrastructure. Significant gap: Systems documents research/manufacturing extensively, API doesn't cover these in Economy module.

**Critical Issues:** 1 (Module boundary confusion)  
**Moderate Issues:** 8  
**Minor Issues:** 6

---

  
**Location:** Throughout entire document  
**Issue:** Systems Economy.md documents Research, Manufacturing, Marketplace, Suppliers, and Transfer systems. API ECONOMY.md only documents economic transactions, resources, items, and inventory. **Research and Manufacturing are NOT in API Economy module.**

**Systems Sections:**
- Research Projects (detailed mechanics)
- Research Technology Tree
- Manufacturing Projects (detailed production queues)
- Marketplace
- Black Market
- Supplier System
- Transfer System

**API Sections:**
- Economics (global financial state)
- TradePartner
- FinancialEvent
- Resource
- Item / ItemType
- ResourcePool
- ManufacturingOrder (brief mention)

**Conflict:** Systems treats "Economy" as umbrella for research/manufacturing/trading. API separates these into distinct modules.

**Resolution:** Either:
1. Clarify Systems Economy.md is actually "Economic Systems Overview" covering multiple modules, OR
2. Split Systems into separate documents (Research.md, Manufacturing.md, Economy.md), OR
3. Document in API where Research and Manufacturing actually reside

---

## Moderate Gaps (8)

### 2. Resource Type Definitions
**Severity:** MODERATE  
**Location:** Resource Entity  
**Issue:** API provides Resource entity with TOML examples, Systems doesn't document resources as distinct from items.

**API Defines:**
```lua
Resource = {
  id = string,
  category = string,              -- "raw_material", "component", "ammunition"
  stackable = bool,
  max_stack = number | nil,
  base_price = number,
  rarity = number,                -- 1-5
}
```

**API TOML Examples:**
- Alloy Plates: stackable, max 50, 500 credits, rarity 2
- Electronics: stackable, max 100, 800 credits, rarity 2
- Rare Earth: stackable, max 30, 2000 credits, rarity 4
- Alien Alloy: stackable, max 20, 5000 credits, rarity 5

**Systems States:**
- Mentions "Raw resources (materials, alien components)" in manufacturing requirements
- Doesn't define resource types or stacking rules

**Resolution:** Systems should document resource categories and stacking limits.

---

### 3. Market Price Fluctuation Formula
**Severity:** MODERATE  
**Location:** Economics entity  
**Issue:** API mentions "market_fluctuation = number, -50 to +50 (price modifier %)" but doesn't provide formula. Systems doesn't document fluctuation.

**Resolution:** Systems should specify:
- How market fluctuation is calculated
- What triggers price changes
- How often prices update

---

### 4. Supplier Relationship Mechanics
**Severity:** MODERATE  
**Location:** Supplier System  
**Issue:** Systems provides extremely detailed supplier relationship formulas, API mentions TradePartner with relationship but less detail.

**Systems Specifies:**
```
Relation Change = (Purchase Amount / 1000) - Diplomatic Stance Conflict
Monthly Maintenance = -1 point per month (no purchases)
Pricing Modifier = 1.0 + (0.005 × (100 - Relation))
```

**Systems Also Has:**
- Complete relationship tier table (-100 to +100)
- Pricing modifiers by relationship level
- Delivery time modifiers
- Exclusive item unlock thresholds

**API Has:**
```lua
TradePartner = {
  reputation = number,            -- -100 to +100 with trader
  price_multiplier = number,      -- 0.8 = 20% cheaper, 1.2 = 20% markup
}
```

**Resolution:** API should reference Systems supplier relationship formulas or document them in API.

---

### 5. Research Cost Scaling Mechanics
**Severity:** MODERATE  
**Location:** Research Projects section (Systems only)  
**Issue:** Systems documents detailed research mechanics including "50%-150% randomly determined at campaign start" multiplier. API doesn't have research in Economy module.

**Resolution:** Clarify where research is documented in API. If in separate module, cross-reference.

---

### 6. Manufacturing Batch Bonus Formula
**Severity:** MODERATE  
**Location:** Manufacturing Projects section (Systems only)  
**Issue:** Systems specifies batch production bonuses (5-10% per unit), API has ManufacturingOrder entity but doesn't document bonuses.

**Systems States:**
```
1 unit: 100% time
5 units: 95% per unit (batch bonus 5%)
10 units: 90% per unit (batch bonus 10%)
```

**Resolution:** If manufacturing is in separate module, document batch bonuses there.

---

### 7. Transfer Cost Formula
**Severity:** MODERATE  
**Location:** Transfer System section (Systems only)  
**Issue:** Systems provides complete transfer cost formula, API doesn't document transfer system in Economy module.

**Systems Specifies:**
```
Transfer Cost = (Item Count × Item Mass × Distance Modifier × Transport Type Multiplier) + Base Fee
Distance Modifier = Distance in hexes × 0.5
Transport Type Multiplier: Air 2.0, Ground 1.0, Maritime 0.5
Base Fee: 50-200 credits
```

**Resolution:** Clarify if transfer system is in Economy API or separate logistics module.

---

### 8. Item Durability/Condition System
**Severity:** MODERATE  
**Location:** Item entity  
**Issue:** API documents condition (0-100 durability), Systems doesn't mention item degradation.

**API Has:**
```lua
Item = {
  condition = number,             -- 0-100 (durability)
  is_broken = bool,
  current_value = number,         -- Affected by condition
}
```

**Resolution:** Systems should document if items degrade with use and how condition affects value.

---

### 9. Black Market Access Conditions
**Severity:** MODERATE  
**Location:** Black Market section  
**Issue:** Systems mentions black market requires "low Karma (<-40)", API mentions "black_market" trader type but doesn't specify access conditions.

**Resolution:** API should reference Systems requirements or document karma thresholds.

---

## Minor Gaps (6)

### 10. Financial Event Types
**Severity:** MINOR  
**Issue:** API lists event types ("recession", "boom", "inflation", "market_crash"), Systems doesn't detail these.

**Resolution:** Systems could document economic events for completeness.

### 11. Item Categories
**Severity:** MINOR  
**Issue:** API categorizes items as "weapon", "armor", "consumable", Systems doesn't enumerate categories.

**Resolution:** Minor - acceptable division.

### 12. Marketplace Stock Refresh Rate
**Severity:** MINOR  
**Issue:** Systems states "Marketplace stock refreshes monthly", API doesn't specify refresh rate.

**Resolution:** API should add restock_interval property or reference Systems.

### 13. Bulk Purchase Discount Thresholds
**Severity:** MINOR  
**Issue:** Systems specifies "5% per 5+ items, 15% per 20+ items, 25% per 50+ items", API doesn't document discount tiers.

**Resolution:** API should add bulk discount formula.

### 14. Delivery Time Ranges
**Severity:** MINOR  
**Issue:** Systems specifies delivery times (1-14 days typical, by supplier type), API mentions "delivery_time_days" but doesn't specify ranges.

**Resolution:** API should reference Systems delivery time table.

### 15. Resource Rarity Scale
**Severity:** MINOR  
**Issue:** API uses "rarity = number, 1-5 (5 = rarest)", Systems doesn't explain what rarity means.

**Resolution:** Systems should document rarity effects on availability/price.

---

## Recommendations

### Immediate Actions (Critical Gap)

1. **Module Boundaries:**
   - Clarify that Systems "Economy.md" is actually an overview of multiple modules
   - Document where Research system lives in API (likely separate module)
   - Document where Manufacturing system lives in API (likely separate module)
   - Consider renaming Systems "Economy.md" to "Economic Systems Overview.md"
   - Create separate Systems documents for Research.md and Manufacturing.md if they're distinct modules

### Short-Term Actions (Moderate Gaps)

2. **Resource Documentation:** Add resource categories and stacking rules to Systems
3. **Market Fluctuation:** Document price fluctuation formula in Systems
4. **Supplier Relationships:** API should reference Systems detailed formulas
5. **Research/Manufacturing:** Clarify module boundaries and cross-reference
6. **Transfer System:** Clarify if transfer is part of Economy or separate logistics module
7. **Item Condition:** Document degradation mechanics in Systems if implemented
8. **Black Market Access:** Document karma thresholds in API
9. **Bulk Discounts:** Add discount formula to API

### Long-Term Actions (Minor Gaps)

10. Document economic events in Systems
11. Enumerate item categories in Systems
12. Add marketplace restock intervals to API
13. Document delivery time ranges in API
14. Explain rarity scale effects in Systems

---

## Quality Assessment

**Strengths:**
- Systems provides exceptionally detailed supplier, marketplace, and transfer mechanics
- API provides good entity structure for resources, items, and inventory
- Both documents comprehensive in their respective focuses

**Weaknesses:**
- Major confusion about module boundaries (Research/Manufacturing in Systems but not API Economy)
- Systems documents many systems (Research, Manufacturing, Marketplace, Suppliers, Transfer) that may belong in separate modules
- Resource/item distinction not clear in Systems
- Many Systems formulas not reflected in API

**Overall:** Moderate alignment. The main issue is not gaps between API and Systems, but rather **scope confusion**. Systems "Economy.md" appears to be an umbrella document covering multiple systems (Research, Manufacturing, Trading, Logistics) while API Economy module focuses narrowly on economic transactions and resources. This suggests Systems needs restructuring into separate documents, or API needs to clarify where these other systems are documented.
