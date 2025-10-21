# Phase 2 Task 1: Data File Verification Checklist

**Status**: IN_PROGRESS  
**Date Started**: October 21, 2025  
**Purpose**: Verify all data-driven game values are correct for balance and consistency

---

## Data File Inventory

### Core Game Rules
```
mods/core/rules/
├── items/
│   ├── weapons.toml
│   ├── armours.toml
│   ├── ammo.toml
│   ├── equipment.toml
│   └── README.md
├── units/
│   └── (class definitions)
└── facilities/
    └── (facility definitions)
```

### Economy & Systems
```
mods/core/economy/
├── suppliers.toml (if exists)
├── marketplace.toml (if exists)
└── (pricing data)

mods/core/
├── factions/
├── technology/
├── campaigns/
└── geoscape/
```

---

## Verification Tasks

### 1. WEAPONS VERIFICATION ✅

**File**: `mods/core/rules/items/weapons.toml`

**What to Check**:
- [ ] Weapon names match wiki documentation
- [ ] Damage values reasonable (5-50 range)
- [ ] Accuracy values between 50-95%
- [ ] AP costs between 1-8 points
- [ ] Ammo capacity logical (pistol ≤20, rifle ≤60)
- [ ] Damage types correct (STUN, HURT, MORALE, ENERGY)
- [ ] Range values logical (3-20 tiles)
- [ ] Weight reasonable (0.5-8 kg)
- [ ] Fire modes available (SNAP, AIM, etc.)
- [ ] Critical chance 0-15%

**Balance Checks**:
- Early game weapons: 5-15 damage, 70-85% accuracy
- Mid game weapons: 15-30 damage, 60-80% accuracy
- Late game weapons: 30-50 damage, 50-75% accuracy
- Sniper weapons: high damage (40+), lower accuracy (50-60%)
- Machine guns: lower damage (20-25), high ROF (AUTO mode)

**Status**: ⏳ PENDING

---

### 2. ARMOR VERIFICATION ⏳

**File**: `mods/core/rules/items/armours.toml`

**What to Check**:
- [ ] Armor types (light, medium, heavy, powered)
- [ ] Protection values 0-50 range
- [ ] Weight appropriate to protection
- [ ] Cost scaling with protection
- [ ] Movement penalties for heavy armor (-1 AP max)
- [ ] Special abilities documented
- [ ] Balance between protection and mobility

**Balance Checks**:
- Light armor: 5-10 protection, no penalty, cheap
- Medium armor: 15-25 protection, -1 AP possible, moderate cost
- Heavy armor: 30-40 protection, -1-2 AP, expensive
- Powered armor: 45-50 protection, special abilities, very expensive

**Status**: ⏳ PENDING

---

### 3. AMMUNITION VERIFICATION ⏳

**File**: `mods/core/rules/items/ammo.toml`

**What to Check**:
- [ ] Ammo types defined (standard, AP, explosive, incendiary, etc.)
- [ ] Damage modifiers correct (0.8-1.5x)
- [ ] Special effects defined (armor pen, explosion, fire)
- [ ] Cost scaling logical
- [ ] Availability restrictions (research gates)

**Ammo Types**:
- STANDARD: 1.0x damage, no special effects
- AP (Armor Piercing): 0.9x damage, +15% armor penetration
- EXPLOSIVE: 1.3x damage, creates explosion radius
- INCENDIARY: 1.1x damage, creates fire
- STUN: 0.5x damage, high stun chance (50%)

**Status**: ⏳ PENDING

---

### 4. EQUIPMENT VERIFICATION ⏳

**File**: `mods/core/rules/items/equipment.toml`

**What to Check**:
- [ ] Grenades: damage, radius, effects
- [ ] Medical kits: healing values
- [ ] Medikits: scope and effect appropriate
- [ ] Armor sets complete
- [ ] Cost scaling consistent
- [ ] Weight reasonable
- [ ] Research prerequisites clear

**Grenade Balance**:
- Frag: 30-40 damage, 3 hex radius
- Smoke: 0 damage, 4 hex radius, vision blocking
- Flash: 0 damage, 5 hex radius, stun effect
- Incendiary: 15-20 damage, creates fire
- EMP: 0 damage, disables electronics

**Status**: ⏳ PENDING

---

### 5. UNIT CLASSES VERIFICATION ⏳

**File**: `mods/core/rules/units/` (if exists)

**What to Check**:
- [ ] Unit stat distribution (TU, HP, Accuracy, Reactions, Strength, Psi)
- [ ] Stat ranges 20-90 reasonable
- [ ] Class specializations logical
- [ ] Starting equipment appropriate
- [ ] Experience multiplier fair (0.5-2.0x)

**Unit Class Balance**:
- Rookie: Balanced stats, 60-70 average
- Assault: High HP (80+), TU (70+), low accuracy
- Sniper: Low HP (50-60), high accuracy (85+)
- Medic: Balanced, high psi if applicable
- Heavy: High HP (85+), low mobility
- Engineer: Balanced, psi resistance bonus

**Status**: ⏳ PENDING

---

### 6. FACILITIES VERIFICATION ⏳

**Files**: `mods/core/rules/facilities/` or economy files

**What to Check**:
- [ ] Facility costs 1,000-100,000 range
- [ ] Construction time 10-100 days
- [ ] Maintenance cost 100-5,000/month
- [ ] Capacity provided (units, items, research, etc.)
- [ ] Power consumption 5-100 MW
- [ ] Service requirements clear

**Facility Balance**:
- Command Center: mandatory, moderate cost, high capacity
- Living Quarters: cheap, moderate capacity (20 units)
- Workshop: moderate cost, 2 production queues
- Lab: moderate cost, 2 research projects
- Hangar: expensive, 2 craft capacity
- Power Plant: moderate, provides power

**Status**: ⏳ PENDING

---

### 7. RESEARCH VERIFICATION ⏳

**File**: `mods/core/technology/` or economy files

**What to Check**:
- [ ] Research cost 1,000-50,000 science points
- [ ] Research time 5-100 days
- [ ] Prerequisites logical (basic before advanced)
- [ ] Unlocks appropriate items/facilities
- [ ] Cost scaling with progression

**Research Chain Examples**:
- Laser Weapons: 5,000 pts, unlocks laser rifle/pistol
- Plasma Weapons: 20,000 pts (requires Laser), unlocks plasma rifle
- Armor Tech: 8,000 pts, unlocks medium armor
- Power Armor: 30,000 pts (requires Armor Tech), unlocks powered armor

**Status**: ⏳ PENDING

---

### 8. MANUFACTURING VERIFICATION ⏳

**Files**: Economy or manufacturing data

**What to Check**:
- [ ] Manufacturing times 5-50 days reasonable
- [ ] Material costs documented
- [ ] Cost scaling with quantity
- [ ] Batch bonuses applied (5-10%)
- [ ] Research prerequisites gate items

**Manufacturing Examples**:
- Rifle Ammo: 1 day, cheap materials
- Laser Rifle: 20 days, 100 materials
- Armor: 15 days, 50 materials
- Vehicle: 40 days, 500 materials

**Status**: ⏳ PENDING

---

### 9. MARKETPLACE VERIFICATION ⏳

**Files**: Economy or supplier data

**What to Check**:
- [ ] Base prices reasonable
- [ ] Relationship modifiers (-2.0 to +2.0) applied correctly
- [ ] Bulk discount thresholds (10+, 20+, 50+, 100+)
- [ ] Regional availability restrictions
- [ ] Research prerequisites for advanced items
- [ ] Stock limits prevent exploitation

**Marketplace Balance**:
- Standard supplier: neutral pricing
- Black market: 30% premium, restricted items
- Government supplier: discounts for allies
- Regional suppliers: limited availability

**Status**: ⏳ PENDING

---

### 10. ECONOMY THRESHOLDS VERIFICATION ⏳

**Files**: Economy or financial system data

**What to Check**:
- [ ] Monthly income 10,000-50,000 range
- [ ] Monthly expenses 5,000-30,000 range
- [ ] Debt limits reasonable (50,000-200,000)
- [ ] Funding multipliers -0.5x to +1.5x
- [ ] Income sources diverse
- [ ] Expense categories complete

**Economy Components**:
- Government funding: base 20,000/month, relations modifiers
- Mission rewards: 1,000-5,000 per mission
- Trade profit: 100-1,000/month variable
- Maintenance costs: 5,000-15,000/month facility-dependent
- Salaries: 100-500 per unit/month
- Research costs: 100-1,000/day per project

**Status**: ⏳ PENDING

---

## Verification Process

### For Each Data File:

1. **Read TOML file**
   ```
   cat mods/core/rules/items/weapons.toml
   ```

2. **Cross-reference wiki documentation**
   - Check wiki/systems/Economy.md for expected values
   - Check wiki/systems/Battlescape.md for combat balance
   - Check wiki/FAQ.md for game mechanics

3. **Verify Against Code**
   - Look up how values are used in Lua code
   - Check damage calculations
   - Check cost calculations
   - Check modifiers application

4. **Document Findings**
   - ✅ MATCHES: Value matches documentation and code
   - ⚠️ DIFFERS: Value differs, but is reasonable
   - ❌ WRONG: Value causes issues (too high/low)
   - 📋 MISSING: Value not documented

5. **Adjust If Needed**
   - Update TOML file if incorrect
   - Document reason for change
   - Re-verify calculations

---

## Summary Template

### SECTION: [Name]
**File**: `path/to/file.toml`  
**Status**: ✅ VERIFIED / ⚠️ ADJUSTED / ❌ ISSUES FOUND

**Findings**:
- Item count: X items
- Value ranges: min-max
- Balance assessment: OK / ISSUES / NEEDS TUNING

**Changes Made** (if any):
- Changed X from Y to Z (reason: ...)

**Verification Date**: YYYY-MM-DD  
**Verified By**: [Name]

---

## Overall Summary

**Files Verified**: 0/10
**Files Adjusted**: 0/10
**Files with Issues**: 0/10
**Total Changes**: 0

**Overall Status**: NOT STARTED

**Next Steps**:
1. Read each TOML file
2. Cross-reference with wiki
3. Verify calculations
4. Adjust as needed
5. Document changes

---

**Task Completion**: 0%  
**Est. Completion Time**: 3-4 hours  
**Start Time**: October 21, 2025  
**Target Completion**: October 21, 2025 EOD
