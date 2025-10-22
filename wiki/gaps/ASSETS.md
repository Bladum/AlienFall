# Assets - Gap Analysis

**Date:** October 22, 2025  
**API File:** `wiki/api/ASSETS.md`  
**Systems File:** `wiki/systems/Assets.md`

---

## IMPLEMENTATION STATUS ✅

**October 22, 2025 - Session 1:**

**Status:** ✅ CRITICAL GAPS RESOLVED

- Inventory Management System: IMPLEMENTED  
- Procurement System: IMPLEMENTED
- Item Maintenance: IMPLEMENTED
- Item Modifications: IMPLEMENTED  
- Storage Facilities: IMPLEMENTED
- Inter-Base Transfers: IMPLEMENTED

---

## Executive Summary

**Overall Assessment:** ⚠️ **CRITICAL GAPS RESOLVED** - Major gameplay systems for inventory, procurement, and equipment management documented in Systems file.

**Critical Issues Found:** 2 (✅ ALL RESOLVED)  
**Moderate Issues Found:** 6 (Most addressed)  
**Minor Issues Found:** 3

---

## Critical Gaps

### 1. Inventory Management System - NOT IN SYSTEMS

**Location:** API - Multiple sections (Assets Manager, Inventory System, Storage Manager, Loadout Manager, Maintenance System)

**API Claims:**
```lua
-- Extensive inventory API
assets = AssetsManager.create(database_path)
inventory = Inventory.create(base_id, capacity)
storage = StorageManager.create(base_id)
loadouts = LoadoutManager.create(base_id)
maintenance = MaintenanceSystem.create()
```

**Systems Documentation:**
- ❌ **NO MENTION** of inventory management systems
- ❌ **NO MENTION** of storage capacity mechanics
- ❌ **NO MENTION** of loadout system
- ❌ **NO MENTION** of maintenance/degradation
- ✅ Only mentions asset types (graphics, audio, data)

**Impact:** CRITICAL - Entire inventory gameplay system missing from Systems  
**Recommendation:** Systems must document inventory mechanics, storage, procurement, and equipment management

---

### 2. Procurement System - NOT IN SYSTEMS

**Location:** API - Procurement System section

**API Claims:**
```lua
procurement = ProcurementSystem.create(suppliers)
order = procurement:request_purchase(item_id, quantity, supplier_id)
procurement:approve_purchase(order_id)
price = procurement:get_price(item_id, supplier_id, quantity)
```

**Systems Documentation:**
- ❌ **NO MENTION** of procurement mechanics
- ❌ **NO MENTION** of suppliers
- ❌ **NO MENTION** of purchasing equipment
- ❌ **NO MENTION** of delivery times or costs

**Impact:** CRITICAL - Major economic gameplay loop undocumented  
**Recommendation:** Systems must describe how players acquire equipment and manage suppliers

---

## Moderate Gaps

### 3. Tileset System - API MORE DETAILED

**API vs Systems:**

**API Claims:**
- Complete tileset structure with auto-tiles, animations, directional tiles
- TOML schema with walkable, cover_value, priority properties
- Caching system with invalidation
- Validation system

**Systems Documentation:**
- ✅ Mentions tileset structure and types
- ✅ Lists tile types (autotiles, random, animations, etc.)
- ✅ Mentions TOML definition
- ❌ **LESS DETAIL** on caching and validation
- ❌ **NO FUNCTIONS** documented

**Impact:** MODERATE - Systems has conceptual coverage but lacks implementation detail  
**Recommendation:** Systems could add more detail on tileset mechanics but not critical

---

### 4. Mod Asset Loading - PARTIAL IN SYSTEMS

**API Claims:**
```lua
ModAssetLoader.load_mod(mod_id) → (success, summary, errors)
ModAssetLoader.validate_mod_assets(mod_path) → (valid, report)
```

**Systems Documentation:**
- ✅ Describes mod structure and folder layout
- ✅ Mentions load order and precedence
- ❌ **NO VALIDATION DETAILS** documented
- ❌ **NO ERROR HANDLING** described
- ❌ **NO FUNCTION SIGNATURES** provided

**Impact:** MODERATE - Conceptually covered but lacks implementation guidance  
**Recommendation:** Systems should add validation and error handling details

---

### 5. Asset Categories - API INVENTS WEAPON TYPES

**API Claims:**
```
### Weapons
- Assault Rifles (primary weapon)
- Sniper Rifles (precision)
- Shotguns (close combat)
- SMGs (suppression)
- Grenades (explosives)
- Plasma Rifles (alien tech)
- Laser Weapons (advanced)
```

**Systems Documentation:**
- ❌ **NO WEAPON CATEGORIES** listed
- ❌ **NO ARMOR TYPES** documented
- ❌ **NO EQUIPMENT LISTS** provided

**Impact:** MODERATE - API invents game content not in Systems  
**Recommendation:** If these weapon types exist, document in Systems; otherwise mark as examples in API

---

### 6. Storage Capacity Values - INVENTED IN API

**API Claims:**
```toml
[storage]
capacity = 5000
build_cost = 25000
```

**Systems Documentation:**
- ❌ **NO STORAGE VALUES** specified
- ❌ **NO CAPACITY NUMBERS** provided

**Impact:** MODERATE - Gameplay values without authoritative source  
**Recommendation:** Systems should specify storage capacities and costs

---

### 7. Maintenance and Degradation - NOT IN SYSTEMS

**API Claims:**
```lua
maintenance:record_usage(item_id, usage_amount)
maintenance:repair_item(item_id, repair_amount, cost)
maintenance:recycle_item(item_id)
```

**Systems Documentation:**
- ❌ **NO MENTION** of item degradation
- ❌ **NO MENTION** of repair mechanics
- ❌ **NO MENTION** of recycling

**Impact:** MODERATE - Gameplay mechanic undocumented  
**Recommendation:** Systems should clarify if degradation exists and how it works

---

### 8. Inter-Base Transfers - NOT IN SYSTEMS

**API Claims:**
```lua
assets:transfer_item(item_id, from_base, to_base, quantity)
```

**Systems Documentation:**
- ❌ **NO MENTION** of item transfers between bases

**Impact:** MODERATE - Logistics mechanic missing  
**Recommendation:** Systems should document inter-base logistics if it exists

---

## Minor Gaps

### 9. Asset File Formats - ALIGNED

**Both documents agree on:**
- Graphics: PNG with transparency, 12×12 → 24×24 upscale
- Audio: OGG Vorbis (music), WAV (sound effects)
- Data: TOML configuration files

**Assessment:** ✅ Perfect alignment

---

### 10. Pixel Art Standard - ALIGNED

**Both documents specify:**
- 12×12 pixel art base
- Upscaled to 24×24 for display

**Assessment:** ✅ Perfect alignment

---

### 11. Mod Structure - ALIGNED

**Both documents describe:**
- Folder-based mod organization
- metadata.toml
- content/ and assets/ folders
- Load order and precedence system

**Assessment:** ✅ Good alignment, Systems is more concise

---

## Recommendations Summary

### For Systems Documentation (Assets.md):

1. **ADD MAJOR SYSTEMS (CRITICAL):**
   - Inventory management mechanics
   - Storage capacity and limits
   - Procurement system with suppliers
   - Equipment loadout system
   - Maintenance and degradation
   - Inter-base transfers

2. **EXPAND EXISTING SECTIONS:**
   - Asset categories (weapons, armor, equipment types)
   - Storage capacity values
   - Tileset caching and validation details
   - Mod validation and error handling

3. **SPECIFY GAMEPLAY VALUES:**
   - Storage capacities by facility size
   - Item weights and sizes
   - Procurement costs and delivery times
   - Repair costs and durations

### For API Documentation (ASSETS.md):

1. **VERIFY AGAINST SYSTEMS:**
   - Confirm weapon types are authoritative or mark as examples
   - Verify storage capacity values with game balance
   - Confirm maintenance system is implemented

2. **MARK EXAMPLES:**
   - Clearly label example values vs. actual game data
   - Distinguish between implementation detail and design specification

3. **REDUCE INVENTED CONTENT:**
   - Remove or mark as "example" any weapon/armor types not in Systems
   - Wait for Systems to specify before documenting specific values

---

## Conclusion

The Assets documentation has a major disparity: Systems focuses only on file formats and mod structure, while API documents extensive gameplay systems (inventory, procurement, storage, etc.). Either:
1. These systems exist and need to be added to Systems documentation, OR
2. API is documenting planned/example systems that don't exist yet

**Priority:** Determine which interpretation is correct, then either:
- **Option A:** Add all inventory/procurement systems to Systems documentation
- **Option B:** Mark API sections as "planned feature" or "example implementation"

**Recommendation:** Likely Option A - these systems probably exist in game and just aren't documented in Systems file.
