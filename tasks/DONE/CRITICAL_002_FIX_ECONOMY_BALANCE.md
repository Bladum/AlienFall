# Task: CRITICAL #2 - Fix Early Game Economy Balance

**Status:** TODO
**Priority:** Critical
**Created:** 2025-10-31
**Completed:** N/A
**Assigned To:** Game Balance Designer + Senior Economist

---

## Overview

**BLOCKER**: Early game economy is unbalanced. Player faces 150-200K monthly deficit, making early game unaffordable and creating "impossible to sustain" situation.

**Current Calculation**:
- Monthly Income: 50-70K (country funding + minimal manufacturing)
- Monthly Expenses: 200-250K+ (base + units + facilities + crafts)
- **Net Result**: -130K to -200K monthly deficit

**Problem**: No mechanism to cover this deficit. Mission salvage values are undefined.

---

## Purpose

Early game must be economically playable. Without fix:
- Player cannot maintain base
- Cannot afford unit salaries
- Cannot do facility maintenance
- Game becomes "resource starvation" immediately

This creates terrible first-play experience and blocks campaign progression.

---

## Requirements

### Functional Requirements
- [ ] Income and expenses balanced for early game (target: break-even or small surplus)
- [ ] Mission salvage values defined and economically meaningful
- [ ] Early-game resource progression clear and achievable
- [ ] Country funding scales appropriately with game progress
- [ ] Base maintenance costs balanced with earning potential

### Technical Requirements
- [ ] All cost values specified with ranges and reasoning
- [ ] Income sources quantified (each mission type, each reward)
- [ ] Monthly budget cycle documented
- [ ] Difficulty scaling integrated (easy vs hard economics)

### Acceptance Criteria
- [ ] Balanced budget sheet for first 5 months of campaign
- [ ] Mission salvage values defined for all mission types
- [ ] Early game is playable without deficit
- [ ] No contradictions between Finance.md, Economy.md, Basescape.md
- [ ] Economic progression clear through mid-game

---

## Current State Analysis

### Income Breakdown (Monthly, Early Game)

| Source | Amount | Notes |
|--------|--------|-------|
| Country Funding (Level 5) | 50K | At ~$1M country GDP |
| Manufacturing | 5-20K | Early game, low capacity |
| Research Milestone | 0 | None in first month |
| Equipment Sales | 0 | No salvage yet |
| **Total Monthly Income** | **55-70K** | Not enough |

### Expense Breakdown (Monthly, Early Game)

| Category | Amount | Formula | Notes |
|----------|--------|---------|-------|
| Base Maintenance | 150K | 150 × 1² | 1 small base |
| Unit Salaries | 50K | 5K × 10 units | 10 unit squad |
| Craft Maintenance | 4K | 2K × 2 crafts | 2 transport/fighter |
| Facility Operations | 20K+ | Per facility | Lab, Barracks, etc. |
| **Total Monthly Expenses** | **224K+** | Too high |

**Problem**: Income 55-70K vs Expenses 224K+ = **Deficit of 154-169K per month**

At this rate, player burns through starting capital (typically 500K) in **3 months**.

---

## Gap Analysis: Where Did Numbers Come From?

### Income Sources
- **Country Funding**: Finance.md claims "Level 5 = 5% of GDP"
  - Assumed GDP ~$1M
  - 5% = 50K
  - But is $1M reasonable? (Unclear)

- **Manufacturing**: Economy.md claims "5-20K" profit
  - Based on selling manufactured goods
  - But manufacturing costs undefined
  - No manufacturing capacity specified for early game

- **Mission Salvage**: UNDEFINED
  - No values given for UFO crash loot
  - No values for alien equipment
  - No values for research materials
  - **This is the missing piece**

### Expense Sources
- **Base Maintenance**: Basescape.md claims "150K × size²"
  - 1 small base = 150K × 1 = 150K
  - Is this too high? Seems excessive

- **Unit Salaries**: Finance.md claims "5K per unit per month"
  - 10 units = 50K
  - Seems reasonable

- **Craft Maintenance**: Finance.md claims "2K per craft per month"
  - 2 crafts = 4K
  - Seems reasonable

- **Facility Operations**: Basescape.md claims "5-50K per facility"
  - Range is 10x variance!
  - No specifics on which cost what

---

## Design Options

### Option A: Increase Income (Recommended Balanced)

**Approach**: Boost early-game country funding

**Changes**:
- Country funding starting level: 6 → 8 (80K instead of 50K)
- Mission salvage for UFO crash: +50K first time, +25K recurring
- Manufacturing efficiency bonus: +15K early game

**New Income**: 55-70K → 120-140K
**Net Result**: From -154K deficit → possible break-even

**Advantages**:
- Preserves base costs (realistic large-scale ops)
- Preserves unit salaries
- Rewards early military success
- Felt less "nerfed"

**Disadvantages**:
- Changes difficulty balance
- Makes game easier overall

### Option B: Decrease Expenses (Recommended for Tension)

**Approach**: Lower maintenance costs

**Changes**:
- Base maintenance: 150K × size² → 75K × size² (small base 75K)
- Facility operations: 5-50K range → 2-15K range (average -10K)
- Unit salaries: 5K → 3K (total -20K for 10 units)

**New Expenses**: 224K → 105-120K
**Net Result**: From -154K deficit → break-even or small surplus

**Advantages**:
- Creates survival tension (limited resources)
- Rewards careful facility management
- Makes late-game profits more meaningful

**Disadvantages**:
- Makes bases feel cheaper/less impactful
- Reduces maintenance cost as difficulty lever

### Option C: Hybrid Balanced Approach (Recommended Most Realistic)

**Changes**:
1. **Income Boost**:
   - Country funding Level 1 → Level 1: 10K (was 5K)
   - Mission salvage defined: UFO crash 30K, Alien base 75K, Terror mission 40K
   - First-month bonus: +50K "organizational startup" funding

2. **Expense Optimization**:
   - Base maintenance: 150K × size² → 100K × size² (small base 100K)
   - Facility operations average: 20K → 10K (remove 10K)
   - Starting squad: 10 units → 8 units (save 10K monthly)

3. **Mission-Based Economy**:
   - Player must complete ~2 missions/month early game
   - UFO crash (common): 30K salvage = income surge
   - Alien base (rare): 75K salvage = major breakthrough
   - Without missions: slow decline but playable

**New Monthly Flow** (First Month, 2 UFO crashes):
```
Income:
- Country funding (Level 1): 10K
- UFO crash #1: 30K
- UFO crash #2: 30K
- Manufacturing (minimal): 5K
Total Income: 75K

Expenses:
- Base (small, 100K formula): 100K
- Units (8, 3K each): 24K
- Crafts (2, 2K each): 4K
- Facilities (average): 8K
Total Expenses: 136K

Net: -61K (still deficit, but manageable from starting capital)

Month 2+ (if 1-2 UFO crashes per month continue):
- Income: 40-70K from missions + 10K funding = 50-80K
- Expenses: 136K
- Still need mission success to break even
```

**Advantages**:
- Creates meaningful mission economy (must do missions to survive)
- Balanced early and late game
- Realistic progression
- Difficulty lever: adjust UFO crash frequency by mission difficulty

**Disadvantages**:
- Most complex to implement
- Requires mission-based income system
- Campaign unpredictability (fewer missions = economic crisis)

---

## Plan

### Step 1: Designer Decision on Economic Philosophy
**Description**: Determine if early game should be "tight survival" or "comfortable growth"
**Decision Points**:
- [ ] Should early game feel tight or comfortable?
- [ ] Should missions be required to survive? (Economy gate on campaign progress?)
- [ ] What's target first-month cash flow? (Surplus, break-even, or acceptable deficit?)

**Owner:** Senior Game Designer
**Estimated time:** 1-2 hours

### Step 2: Quantify Mission Salvage Values
**Description**: Define loot value for every mission type
**Files to modify**:
- `design/mechanics/Economy.md`
- `design/mechanics/Missions.md`

**Specific values needed**:

| Mission Type | Salvage Value | Reasoning |
|--------------|---------------|-----------|
| UFO Crash (Small) | 20-30K | Common, standard |
| UFO Crash (Large) | 50-75K | Rare, valuable |
| Alien Base Attack | 75-150K | Very rare, major |
| Terror Mission | 40-60K | Rare, important |
| Base Defense | 15-25K | Common, defensive |
| Abduction Rescue | 30-40K | Moderate, research value |

**Estimated time:** 2 hours

### Step 3: Rebalance Monthly Costs
**Description**: Adjust all monthly expense categories for balance
**Files to modify**:
- `design/mechanics/Basescape.md` - Base maintenance
- `design/mechanics/Finance.md` - Facility costs, unit salaries
- `design/mechanics/Economy.md` - Overall budget

**Rebalancing decisions**:
- [ ] Final base maintenance formula
- [ ] Final unit salary per level
- [ ] Final facility operation costs (per facility type)
- [ ] Craft maintenance costs (adjust if needed)

**Estimated time:** 2-3 hours

### Step 4: Rebalance Country Funding Levels
**Description**: Adjust funding levels to support chosen economy model
**Files to modify**:
- `design/mechanics/Finance.md` - Funding levels 1-10

**New funding levels** (assuming Level 10 is maximum):
- Level 1: 10K/month
- Level 2: 15K/month
- Level 3: 22K/month
- Level 4: 30K/month
- Level 5: 40K/month
- Level 6: 50K/month
- Level 7: 65K/month
- Level 8: 80K/month
- Level 9: 100K/month
- Level 10: 125K/month

**Estimated time:** 1 hour

### Step 5: Create Early Game Budget Model
**Description**: Build detailed financial model for first 12 months
**Files to create**:
- `design/ECONOMY_EARLY_GAME_MODEL.xlsx` (or .md table)

**Model contents**:
- Month-by-month cash flow
- Expense assumptions (base size, unit count, facilities)
- Income assumptions (mission frequency, country relations)
- Break-even analysis
- Difficulty scaling (easy vs hard)

**Estimated time:** 3-4 hours

### Step 6: Define Starting Capital
**Description**: Specify how much money player starts with
**Files to modify**:
- `design/mechanics/Geoscape.md` - Campaign start conditions

**Questions to answer**:
- [ ] Starting capital: 500K? 250K? 1M?
- [ ] Is this enough for first month? (Should force careful planning)
- [ ] Difficulty scaling: does easy mode start with more?

**Estimated time:** 1 hour

### Step 7: Update Finance Documentation
**Description**: Rewrite Finance.md with consistent numbers
**Files to modify**:
- `design/mechanics/Finance.md` (complete rewrite of income/expense sections)
- `design/mechanics/Economy.md` (add mission salvage values)
- `design/mechanics/Basescape.md` (confirm maintenance formula)

**Estimated time:** 3 hours

### Step 8: Testing & Validation
**Description**: Verify economy is playable through first month
**Test cases**:
- [ ] Month 1 budget: can player avoid deficit with 2 UFO crashes?
- [ ] Month 1 budget: what if only 1 UFO crash? (Still playable?)
- [ ] Month 1 budget: what if 3 UFO crashes? (Is surplus reasonable?)
- [ ] 12-month projection: does economy stabilize? (Should become profitable mid-game)
- [ ] Difficulty scaling: easy vs hard income difference meaningful? (~50% bonus/penalty?)

**Estimated time:** 3-4 hours

---

## Economic Model Specifications

### Key Metrics

**Break-Even Analysis** (for balance validation):
- When does cash flow become positive?
- What mission frequency is required?
- At what campaign point is player "economically stable"?

**Target Balance**:
- Month 1-3: Tight/survival (mission-dependent)
- Month 4-6: Improving (base management pays off)
- Month 7+: Profitable (can expand operations)

### Starting Scenarios

**Easy Mode**:
- Starting capital: 750K
- Country funding Level 3 (22K)
- UFO crash frequency: +50% (more salvage opportunities)
- Base maintenance: -20% (easier operations)
- Result: First month should be slightly profitable

**Normal Mode**:
- Starting capital: 500K
- Country funding Level 1 (10K)
- UFO crash frequency: Standard
- Base maintenance: Standard
- Result: First month tight but manageable with missions

**Hard Mode**:
- Starting capital: 250K
- Country funding Level 0 (0K, must earn relations first)
- UFO crash frequency: -30% (rarer opportunities)
- Base maintenance: +25% (complex operations)
- Result: First month crisis - must complete missions to survive

---

## Implementation Details

### Budget Formula Evolution

**Current (Broken)**:
```
Monthly Income = 50K (country) + 10K (manufacturing) = 60K
Monthly Expenses = 150K (base) + 50K (units) + 4K (crafts) + 20K (facilities) = 224K
Net = -164K (UNPLAYABLE)
```

**Proposed (Option C - Hybrid)**:
```
Monthly Income = 10K (country) + 30K (missions) + 5K (manufacturing) = 45K base
              + UFO crash salvage (20-30K each, ~2/month)
              = 85-105K with missions

Monthly Expenses = 100K (base) + 24K (units) + 4K (crafts) + 8K (facilities) = 136K
Net = -31K to -51K (deficit, but manageable from 500K starting capital)

Month 6-12:
Monthly Income = 40K (country, higher relations) + 40K (missions) + 20K (manufacturing) = 100K
Monthly Expenses = 100K (base) + 24K (units) + 4K (crafts) + 12K (facilities) = 140K
Net = -40K (still tight, encourages further expansion)

Month 12+:
With upgraded manufacturing facilities:
Monthly Income = 60K (country) + 50K (missions) + 50K (manufacturing) = 160K
Monthly Expenses = 150K (larger base + more units) = 150K
Net = +10K (finally profitable!)
```

### Difficulty Scaling Multipliers

| Factor | Easy | Normal | Hard |
|--------|------|--------|------|
| Country funding | ×1.5 | ×1.0 | ×0.5 |
| Mission salvage | ×1.3 | ×1.0 | ×0.7 |
| Base maintenance | ×0.8 | ×1.0 | ×1.25 |
| Unit salaries | ×0.8 | ×1.0 | ×1.2 |
| Manufacturing profit | ×1.2 | ×1.0 | ×0.8 |

---

## Testing Strategy

### Unit Tests
- [ ] Income calculation for each source
- [ ] Expense calculation for each category
- [ ] Mission salvage value ranges
- [ ] Difficulty multiplier application

### Integration Tests
- [ ] Full 12-month budget cycle
- [ ] Mission frequency impact on cash flow
- [ ] Country relations impact on funding
- [ ] Base expansion cost integration

### Manual Testing Steps
1. Start new campaign (Normal difficulty)
2. Record starting capital
3. Month 1: Complete 2 UFO crash missions
4. Check month 1 financial report
5. Verify net cash flow matches projections
6. Repeat through month 12
7. Verify economy stabilizes

### Expected Results
- First month deficit recoverable from starting capital
- Second month possible break-even with missions
- Month 12 should show sustainable profitability

---

## Documentation Updates

### Files to Update
- [ ] `design/mechanics/Finance.md` - Complete rewrite with new numbers
- [ ] `design/mechanics/Economy.md` - Add mission salvage values
- [ ] `design/mechanics/Basescape.md` - Confirm maintenance formula
- [ ] `design/mechanics/Missions.md` - Document salvage values per mission
- [ ] `design/mechanics/Geoscape.md` - Add starting capital, campaign length
- [ ] Create `design/ECONOMY_EARLY_GAME_MODEL.md` (new reference)

---

## Notes

- This is the SECOND highest priority issue affecting playability
- Economic balance affects difficulty scaling significantly
- Economy drives campaign pacing (tight = faster progress, loose = slower)
- Player experience heavily depends on economic stress level
- Mission-based economy creates meaningful decision-making

---

## Blockers

**Depends on**: CRITICAL #1 (Pilot Stat Scale) - No direct dependency, but coordinate to ensure pilot income fits model

---

## Related Tasks

Related to this task:
- CRITICAL #4: Economy Resource Costs (overall budget consistency)
- CRITICAL #5: Experience (XP) System (campaign duration affects income need)
- CRITICAL #6: Unit Stat Ranges (salary calculations)
- HIGH #5: Research Cost Multiplier (research funding from economy)

---

## Review Checklist

- [ ] All income sources quantified with formula
- [ ] All expense sources quantified with formula
- [ ] Mission salvage values defined for all types
- [ ] Budget sheet shows playable early game
- [ ] Difficulty scaling implemented
- [ ] No contradictions between files
- [ ] 12-month projection shows sustainable progression
- [ ] Economic stress feels appropriate for difficulty

---

## Success Criteria

**Game is economically playable when**:
- ✅ Player can complete first mission without bankruptcy
- ✅ First month is tight but not impossible
- ✅ By month 6, economy shows improvement
- ✅ By month 12, expansion feels sustainable
- ✅ Mission frequency directly impacts economic health
- ✅ Difficulty modes have meaningful economic differences
