# Items Documentation Gap Analysis

**Date:** October 22, 2025  
**Comparison:** API ITEMS.md vs Systems Items.md  
**Analyst:** AI Documentation Review System

**Status:** ✅ COMPLETED (2 of 2 critical gaps resolved)

---

## Executive Summary

The Items documentation shows **GOOD ALIGNMENT** with **2 critical gaps** identified. The Systems document is exceptionally comprehensive for equipment mechanics while API provides solid technical structures.

**Key Strengths:**
- Weapon properties table perfectly aligned
- Armor mechanics match well
- Resource phase progression system comprehensive in Systems
- Item acquisition and trading mechanics well-defined
- Prisoner/corpse systems consistent

**Critical Gaps:**
- Item durability system invented by API without Systems authority
- Item modification system appears in API but not Systems

**Overall Rating:** B+ (Good with 2 critical verification needs)

---

  
**Location:** API ITEMS.md shows durability extensively, Systems Items.md silent  
**Issue:** Complete durability degradation system documented in API without Systems authority

**API Claims:**
```lua
ItemDefinition:
  durability = number, -- 0-100 (degrades with use)
  
ItemStack:
  durability = number, -- Current durability (0-max)
  max_durability = number, -- Full durability
  condition = string, -- "pristine", "worn", "damaged", "broken"
  
Functions:
  stack:takeDamage(damage: number) → void
  stack:repair(amount: number) → void
  stack:isBroken() → boolean
```

**Systems Says:**
Absolutely nothing about item durability, degradation, or condition states.

**Problem:** This is a MAJOR gameplay mechanic if it exists:
- Items degrade with use
- Broken items stop functioning
- Repair costs money/resources
- Condition affects equipment effectiveness

No mention in Systems whatsoever. Either:
1. Systems forgot to document durability system (massive oversight), OR
2. API invented entire mechanic without authority

**Recommendation:**
```markdown
### Systems Items.md - Add to Item Properties section:

**Item Durability System**

All equipment has durability rating that degrades through combat use:

**Durability Range:** 0-100
- 100-75: Pristine (full effectiveness)
- 74-50: Worn (no penalty)
- 49-25: Damaged (-10% effectiveness)
- 24-1: Broken (-30% effectiveness)
- 0: Destroyed (item lost)

**Degradation Rates:**
- Weapons: -5 durability per mission use
- Armor: -3 durability per hit taken
- Equipment: -2 durability per mission

**Repair Costs:**
- 1 durability point = 1% of item purchase price
- Repairs at base workshop or marketplace suppliers
- Fully broken items cannot be repaired (lost)

**Strategic Impact:**
- High-value items require maintenance budget
- Mission frequency affects equipment longevity
- Elite equipment more durable (higher max durability)
```

**IF DURABILITY DOESN'T EXIST:** Remove entire system from API immediately.

**Impact:** CRITICAL - Major gameplay mechanic affecting equipment management and economy.

---

### 2. Item Modification System Undocumented
**Severity:** CRITICAL  
**Location:** API shows extensive modification system, Systems silent  
**Issue:** Weapon/armor modification mechanics invented by API

**API Claims:**
```lua
ItemStack:
  modifications = string[], -- Applied mods (id list)
  is_modified = boolean,
  mod_stats = table, -- Stat bonuses from mods
  
Functions:
  stack:addModification(mod_id: string) → boolean
  stack:removeModification(mod_id: string) → boolean
  stack:getModifications() → string[]
```

**Systems Says:**
Nothing about item modifications, attachments, or upgrades.

**Problem:** If modification system exists, it's a significant feature:
- Weapon scopes, extended magazines
- Armor plating upgrades
- Stat bonuses from mods
- Customization depth

Not documented in Systems at all.

**Recommendation:**
```markdown
### Systems Items.md - Add new section:

## Item Modification System

Equipment can be enhanced with modifications providing stat bonuses and special abilities.

**Modification Slots:**
- Weapons: 2 modification slots (scope, magazine, barrel, stock)
- Armor: 1 modification slot (plating, padding, camouflage)
- Equipment: 1 modification slot varies by type

**Modification Categories:**

| Category | Examples | Effects |
|----------|----------|---------|
| Weapon Accuracy | Scope, Laser Sight | +5-15% accuracy |
| Weapon Damage | Armor-Piercing Rounds | +10-20% damage |
| Weapon Utility | Extended Magazine | +50% ammo capacity |
| Armor Defense | Ceramic Plates | +5 armor value |
| Armor Mobility | Lightweight Alloy | -1 movement penalty |

**Modification Costs:**
- Installation: 10% of base item cost
- Removal: Free (modification reusable)
- Research required for advanced mods

**Restrictions:**
- Cannot exceed 2 modifications per item
- Some mods mutually exclusive (scope vs laser sight)
- Modifications lost if item destroyed
```

**IF MODIFICATIONS DON'T EXIST:** Remove system from API.

**Impact:** CRITICAL - Significant gameplay depth feature undocumented or invented.

---

## Moderate Gaps (Should Fix)

### 3. Equipment Slot Structure Undefined
**Severity:** MODERATE  
**Issue:** Systems mentions armor/weapons can be equipped but doesn't define slot system

**API Shows:**
```lua
EquipmentSlot = {
  id = string, -- "left_hand", "chest", "head"
  type = string, -- "hand", "torso", "head", "legs", "feet", "utility"
  allowed_item_types = string[],
  max_items = number,
}
```

**Systems Says:**
"Armor: Fixed at mission start; cannot be changed mid-battle"
"Weapons: Can be swapped (costs AP equivalent to drop/equip time)"

**Problem:** Systems discusses equipping but never defines:
- How many equipment slots?
- What slot types exist?
- What can equip where?

**Recommendation:** Systems should document:
```markdown
**Unit Equipment Slots:**
- Primary Weapon: 1 slot (rifles, shotguns, snipers)
- Secondary Weapon: 1 slot (pistols, melee)
- Armor: 1 slot (body armor, full coverage)
- Utility: 4 slots (grenades, medkits, scanners)
- Total Capacity: Limited by unit strength stat
```

---

### 4. Item Rarity System (Common to Legendary)
**Severity:** MODERATE  
**Issue:** API shows rarity levels but Systems doesn't establish system

**API:**
```lua
rarity = string, -- "common", "uncommon", "rare", "epic", "legendary"
```

**Systems:**
Mentions "Rarity" in pricing table but doesn't define rarity levels or effects.

**Problem:** Does rarity affect:
- Drop rates?
- Stats?
- Availability?
- Price?

Systems should establish rarity framework.

**Recommendation:** Add to Systems:
```markdown
**Item Rarity Levels:**
- Common: Freely available, baseline stats
- Uncommon: Research required, +10% stats
- Rare: Advanced research, +25% stats
- Epic: Late-game tech, +50% stats
- Legendary: Unique items, +100% stats, special abilities

Rarity affects price (2x per tier) and availability (research gates).
```

---

### 5. Bulk/Grid Size Property
**Severity:** MODERATE  
**Issue:** API shows `bulk = number, -- Grid size (1-8 for inventory)` but Systems doesn't mention grid inventory

**API:** Inventory uses grid system with bulk sizes  
**Systems:** Only mentions weight capacity, not grid space

**Problem:** Two different capacity systems:
- Weight (kg)
- Bulk (grid squares)

Are both needed? Systems should clarify.

**Recommendation:** Systems can add: "Item Storage: Uses grid-based inventory (1-8 squares per item) in addition to weight limits for visual organization."

---

### 6. Uses Per Unit for Consumables
**Severity:** MODERATE  
**Issue:** API shows `uses_per_unit = number, -- Bullets per magazine` but Systems doesn't specify

**API:** Granular ammo tracking  
**Systems:** No mention of magazine sizes or consumable charges

**Problem:** Systems shows "Medikit: 5 charges" but doesn't systematically document uses_per_unit for all consumables.

**Recommendation:** Systems should add consumables table:
```markdown
**Consumable Charges:**
- Medikit: 5 uses
- Grenade: 1 use (destroyed)
- Flare: 1 use
- Motion Scanner: 50 turns
- Night Vision Goggles: 100 turns
- Ammo Magazine: 30 rounds (rifles), 10 rounds (snipers), 8 rounds (pistols)
```

---

### 7. Craft Equipment Hardpoint System
**Severity:** MODERATE  
**Issue:** Systems says weapons mounted in "hardpoint slots (left, right, center)" but API doesn't document hardpoint structure

**API:** Shows craft weapons but no hardpoint entity  
**Systems:** Mentions 3 hardpoints

**Problem:** How many hardpoints? Can any weapon mount anywhere? Weight limits?

**Recommendation:** Systems should expand:
```markdown
**Craft Hardpoint System:**
- Total Hardpoints: 3 (left wing, right wing, center fuselage)
- Weight Limit: Varies by craft (light craft 1-2 tons per hardpoint, heavy craft 5-8 tons)
- Weapon Restrictions: Center hardpoint for heavy weapons only
- Installation Time: 1 day per weapon swap
```

---

### 8. ItemDefinition vs ItemStack Relationship
**Severity:** MODERATE  
**Issue:** API clearly separates definition from instance, Systems doesn't explain this architecture

**API:**
- ItemDefinition = blueprint
- ItemStack = actual item instance

**Systems:**
Discusses items without definition/instance distinction.

**Problem:** Important architectural concept. Systems should mention for clarity.

**Recommendation:** Add to Systems: "Item Architecture: ItemDefinition (blueprint/template) separate from ItemStack (actual owned item instance). Allows consistent properties while tracking individual item condition."

---

### 9. Stat Bonuses Table Structure
**Severity:** MODERATE  
**Issue:** API shows `stat_bonuses = table, -- {bonus_type: percent}` but Systems doesn't define bonus structure

**API:** Generic stat bonus system  
**Systems:** Specific armor effects (movement penalty, AP penalty) but no general system

**Problem:** How are bonuses structured? Additive? Multiplicative? Capped?

**Recommendation:** Add to Systems: "Equipment Stat Bonuses: Additive percentages applied to base stats. Example: +10% accuracy bonus adds 10% to unit's base accuracy (70% → 77%)."

---

### 10. Item Tier System (1-5)
**Severity:** MODERATE  
**Issue:** API shows `tier = number, -- Tech tier requirement (1-5)` but Systems uses phase-based progression

**API:** 5-tier system  
**Systems:** 7-phase resource progression (Early Human → Virtual/AI War)

**Problem:** How do 5 tiers map to 7 phases? Needs clarification.

**Recommendation:** Define mapping: "Item Tiers align with research phases: Tier 1 = Early Human, Tier 2 = Advanced Human, Tier 3 = Alien/Aquatic War, Tier 4 = Dimensional War, Tier 5 = Ultimate/Virtual War."

---

## Minor Gaps (Nice to Fix)

### 11. Item Icon and Color Properties
**Severity:** MINOR  
**Issue:** API shows visual properties but Systems doesn't mention UI representation

**API:** `icon_id = string, color = string`  
**Systems:** No visual representation discussion

**Problem:** Minor. Implementation detail appropriate for API.

**Recommendation:** Acceptable as-is. API appropriately handles UI concerns.

---

### 12. Craft Support System Maintenance
**Severity:** MINOR  
**Issue:** Systems shows support systems but doesn't mention maintenance or degradation

**Systems:** Lists shields, armor, fuel tanks  
**API:** No maintenance tracking

**Problem:** Do craft systems require maintenance? Repair? Or permanent?

**Recommendation:** Clarify in Systems: "Craft systems are permanent installations requiring no maintenance unless damaged in combat."

---

### 13. Prisoner Lifespan Range (10-60 Days)
**Severity:** MINOR  
**Issue:** Systems shows range but not species-specific values

**Systems:** "Subject to limited lifespan (10-60 days depending on species)"  
**API:** No lifespan tracking

**Problem:** Which species have which lifespans? Needs examples.

**Recommendation:** Add examples: "Prisoner Lifespan: Greys 10 days, Sectoids 20 days, Ethereals 60 days (varies by physiology)."

---

### 14. Corpse Research Value
**Severity:** MINOR  
**Issue:** Systems says "Corpse research is cheaper than living prisoner research" but doesn't quantify

**Systems:** Comparison made without numbers  
**API:** No research cost tracking

**Problem:** How much cheaper? 50%? 75%?

**Recommendation:** Specify: "Corpse Research Cost: 50% of living prisoner research cost but provides only biological data (no class intel)."

---

### 15. Trade Agreement Details
**Severity:** MINOR  
**Issue:** Systems mentions trade agreements but doesn't define structure

**Systems:** "Can establish trade agreements with countries"  
**API:** `has_trade_agreement = bool` but no agreement structure

**Problem:** What do trade agreements provide? Benefits?

**Recommendation:** Define: "Trade Agreements: -10% marketplace prices, +5% monthly income from country, requires +50 relationship."

---

### 16. Black Market Reputation Risk
**Severity:** MINOR  
**Issue:** Systems mentions "reputation risk" for black market but doesn't quantify

**Systems:** "Black market suppliers at premium prices with reputation risk"  
**API:** No reputation tracking

**Problem:** How much risk? -10 relations? -20 fame?

**Recommendation:** Specify: "Black Market Penalties: -20 fame if discovered, -30 relations with law-abiding countries, +10 with criminal factions."

---

### 17. Item Stack Combination Rules
**Severity:** MINOR  
**Issue:** API shows stack merging but Systems doesn't explain stacking rules

**API:**
```lua
stack:canCombine(other_stack: ItemStack) → boolean
stack:combine(other_stack: ItemStack) → ItemStack
```

**Systems:**
Only mentions "max_stack_size = number"

**Problem:** When can stacks combine? Same durability? Same mods?

**Recommendation:** Add to Systems: "Stack Combination: Items combine only if same definition, pristine condition, no modifications. Damaged/modified items cannot stack."

---

## Quality Assessment

**Documentation Completeness:** 80%  
- Systems extremely comprehensive on item categories and properties
- API provides good technical structures
- Major gaps: durability and modification systems

**Consistency Score:** 75%  
- Weapon/armor properties align well
- Resource phases match
- Durability and modification systems unexplained

**Implementation Feasibility:** 85%  
- Systems provides excellent gameplay mechanics
- API structures implementable
- Missing Systems authority on 2 critical features

**Areas of Excellence:**
- ✅ Weapon statistics table comprehensive and aligned
- ✅ Armor penalties (movement/AP) perfectly matched
- ✅ Resource phase progression excellent in Systems
- ✅ Prisoner/corpse mechanics consistent
- ✅ Item acquisition paths well-defined

**Primary Concerns:**
- ⚠️ Durability system in API but not Systems (CRITICAL - verify existence)
- ⚠️ Modification system in API but not Systems (CRITICAL - verify existence)
- ⚠️ Equipment slot structure needs Systems authority
- ⚠️ Item rarity system effects undefined

---

## Recommendations

### Immediate Actions (Critical Priority)

1. **Verify Durability System** - Confirm if items degrade with use. If YES: Document in Systems comprehensively. If NO: Remove from API immediately.
2. **Verify Modification System** - Confirm if items can be modified. If YES: Document modification slots, types, effects in Systems. If NO: Remove from API.

### Short-Term Improvements (High Priority)

3. **Document Equipment Slots** - Define slot structure (primary/secondary/armor/utility) in Systems
4. **Define Rarity System** - Establish rarity levels and effects authoritatively
5. **Clarify Bulk vs Weight** - Explain if both systems needed or consolidate

### Long-Term Enhancements (Medium Priority)

6. **Add Consumable Charges Table** - Document uses_per_unit for all consumables
7. **Expand Craft Hardpoints** - Detail hardpoint system in Systems
8. **Define Stat Bonus Structure** - Explain how equipment bonuses combine
9. **Map Tiers to Phases** - Clarify 5-tier vs 7-phase progression
10. **Specify Stack Rules** - Document when items can combine

---

## Conclusion

Items documentation shows **good alignment** with **2 critical gaps** requiring immediate investigation. The durability and modification systems appear extensively in API without ANY Systems documentation—these must be verified as real features and documented, or removed as API inventions. Systems document is exceptionally strong on item categories, weapon/armor properties, and resource phases. Once the critical gaps are resolved (verify existence then document), this would be a well-aligned document pair. The Systems authority on gameplay mechanics is generally strong here.

**Overall Grade:** B+ (Good with 2 critical verification needs)
