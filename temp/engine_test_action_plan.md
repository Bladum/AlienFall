# Engine & Test Implementation Action Plan

> **Based on**: update_mechanics_completion_report.md  
> **Date**: 2025-10-28  
> **Priority**: High  
> **Estimated Time**: 15-20 hours

---

## Executive Summary

Design and API documentation is **100% complete**. Engine and Tests are **partially implemented** and need expansion to match the comprehensive design specifications.

**Key Finding**: Existing engine files `morale_system.lua` and `black_market_system.lua` provide basic functionality but are missing ~70% of the features defined in the new comprehensive design documents.

---

## Phase 1: Engine Updates (High Priority)

### 1.1 Update Morale System (~200 lines)
**File**: `engine/battlescape/systems/morale_system.lua`

**Add Missing Features**:
```lua
-- Morale Event Functions (NEW)
function MoraleSystem.onAllyKilled(unitId, distance)
function MoraleSystem.onTakeDamage(unitId)
function MoraleSystem.onCriticalHit(unitId)
function MoraleSystem.onFlanked(unitId)
function MoraleSystem.onOutnumbered(unitId)
function MoraleSystem.onCommanderKilled(unitId)

-- Action Functions (NEW)
function MoraleSystem.restAction(unitId)  -- 2 AP → +1 morale
function MoraleSystem.leaderRally(leaderId, targetId)  -- 4 AP → +2 morale
function MoraleSystem.leaderAura(leaderId, radius)  -- +1 morale/turn within 8 hexes

-- Sanity Functions (EXPAND)
function MoraleSystem.applyMissionTrauma(unitId, missionType, isNight, alliesKilled, failed)
function MoraleSystem.weeklyBaseRecovery(unitId)
function MoraleSystem.weeklyTempleRecovery(unitId)
function MoraleSystem.medicalTreatment(unitId, cost)
function MoraleSystem.leaveVacation(unitId, cost)

-- Penalty Calculations (EXPAND)
function MoraleSystem.getMoraleAccuracyPenalty(unitId)  -- More granular thresholds
function MoraleSystem.getSanityAccuracyPenalty(unitId)
function MoraleSystem.getSanityMoraleModifier(unitId)
function MoraleSystem.canDeploy(unitId)  -- Check if sanity > 0
```

**Reference**: `design/mechanics/MoraleBraverySanity.md`

---

### 1.2 Expand Black Market System (~500 lines)
**File**: `engine/economy/marketplace/black_market_system.lua`

**Add 5 New Service Categories**:

```lua
-- Mission Generation (NEW)
function BlackMarketSystem:purchaseMission(missionType, targetRegion, cost)
function BlackMarketSystem:getAvailableMissions(karma)
-- 7 mission types: assassination, sabotage, heist, kidnapping, false_flag, data_theft, smuggling

-- Event Purchasing (NEW)
function BlackMarketSystem:purchaseEvent(eventType, targetCountry, cost)
function BlackMarketSystem:getAvailableEvents(karma, fame)
-- 8 event types: improve_relations, sabotage_economy, incite_rebellion, etc.

-- Unit Recruitment (NEW)
function BlackMarketSystem:recruitUnit(unitType, cost)
function BlackMarketSystem:getAvailableUnits(karma, fame)
-- 5 unit types: mercenary, defector, augmented, assassin, clone

-- Craft Purchase (NEW)
function BlackMarketSystem:purchaseCraft(craftType, cost)
function BlackMarketSystem:getAvailableCraft(karma, fame)
-- 4 craft types: black_interceptor, modified_bomber, captured_ufo, stealth_transport

-- Corpse Trading (NEW)
function BlackMarketSystem:sellCorpse(corpseItem, baseId)
function BlackMarketSystem:getCorpseValue(corpseType, condition)
-- 5 corpse types with values 5K-100K
```

**Access Tier System** (NEW):
```lua
function BlackMarketSystem:getAccessLevel(karma, fame)
-- Returns: "restricted" | "standard" | "enhanced" | "complete"

function BlackMarketSystem:canAccess(karma, fame, contentType)
-- Check if player can access specific service
```

**Reference**: `design/mechanics/BlackMarket.md`

---

### 1.3 Update Unit Recovery (~50 lines)
**File**: `engine/geoscape/processing/unit_recovery_progression.lua`

**Update Sanity Recovery**:
```lua
-- Update _calculateSanityRecoveryRate function
-- Base: +1 per week
-- Temple bonus: +1 additional per week (check if base has Temple)
-- Medical treatment: +3 immediate (10,000 credits)
-- Leave/vacation: +5 over 2 weeks (5,000 credits)
```

**Reference**: `design/mechanics/MoraleBraverySanity.md` section "Sanity Recovery"

---

### 1.4 Create New Engine Files (5 files, ~800 lines)

#### A. Corpse Trading System
**File**: `engine/economy/corpse_trading.lua` (~150 lines)
```lua
local CorpseTrading = {}

function CorpseTrading.createCorpseFromUnit(deadUnit)
-- Convert dead unit to corpse item

function CorpseTrading.getCorpseValue(corpseType, condition, isFresh, isPreserved)
-- Human: 5K, Alien common: 15K, Alien rare: 50K, VIP: 100K
-- Fresh: +50%, Preserved: +100%, Damaged: -50%

function CorpseTrading.sellCorpse(corpseItem, karmaSystem, discoveryChance)
-- Sell corpse, apply karma penalty, roll for discovery

function CorpseTrading.getAlternativeUses(corpseItem)
-- Research (0 karma), Burial (0 karma, +5 morale), Ransom (0 karma, +relations)
```

#### B. Mission Generation System
**File**: `engine/economy/mission_generation.lua` (~200 lines)
```lua
local MissionGeneration = {}

function MissionGeneration.purchaseMission(missionType, targetRegion, cost, karma)
-- Generate custom mission on Geoscape
-- Types: assassination, sabotage, heist, kidnapping, false_flag, data_theft, smuggling
-- Cost: 20K-60K, Karma: -10 to -40

function MissionGeneration.spawnMission(missionData, targetRegion)
-- Spawn mission on map in 3-7 days

function MissionGeneration.getMissionReward(missionType, baseCost)
-- Calculate profit potential (150-300% of cost)
```

#### C. Event Purchasing System
**File**: `engine/economy/event_purchasing.lua` (~200 lines)
```lua
local EventPurchasing = {}

function EventPurchasing.purchaseEvent(eventType, targetCountry, cost, karma)
-- Trigger political/economic event
-- 8 types: improve_relations, sabotage_economy, incite_rebellion, etc.
-- Cost: 20K-80K, Karma: -5 to -35

function EventPurchasing.applyEvent(eventData, targetCountry)
-- Apply event effects (relations change, economy tier drop, etc.)

function EventPurchasing.getEventDuration(eventType)
-- 3-6 months or permanent
```

#### D. Temple Facility
**File**: `engine/basescape/temple_facility.lua` (~100 lines)
```lua
local TempleFacility = {}

function TempleFacility.create(baseId, position)
-- Create Temple facility (2x2 or 3x3)

function TempleFacility.applySanityBonus(baseId)
-- +1 sanity per week to all units at base

function TempleFacility.getConfiguration()
-- Cost: 12K, Power: 8, Service: Psi Education + Sanity recovery
```

#### E. Morale Actions
**File**: `engine/battlescape/morale_actions.lua` (~150 lines)
```lua
local MoraleActions = {}

function MoraleActions.restAction(unitId, battleState)
-- Cost: 2 AP, Effect: +1 morale
-- Check AP available, apply morale boost

function MoraleActions.leaderRally(leaderId, targetId, battleState)
-- Cost: 4 AP, Effect: +2 morale to target within 5 hexes
-- Requires "Leadership" trait

function MoraleActions.leaderAura(leaderId, battleState)
-- Passive: +1 morale per turn to units within 8 hexes
-- Apply at start of each turn
```

---

## Phase 2: Test Implementation (High Priority)

### 2.1 Create New Test Files (5 files, ~850 lines)

#### A. Morale System Tests
**File**: `tests2/battlescape/morale_system_test.lua` (~200 lines)
```lua
local HierarchicalSuite = require("tests2.framework.hierarchical_suite")
local suite = HierarchicalSuite.new("MoraleSystem", "tests2/battlescape/morale_system_test.lua")

-- Test bravery initialization (6-12 range)
-- Test morale events (ally death, damage, flanking)
-- Test thresholds (AP penalties at 2, 1, 0 morale)
-- Test Rest action (2 AP → +1 morale)
-- Test Leader rally (4 AP → +2 morale)
-- Test Leader aura (+1 morale/turn within 8 hexes)
-- Test panic state (0 morale = all AP lost)
-- Test accuracy penalties (4-5: -5%, 3: -10%, 2: -15%, 1: -25%, 0: -50%)
```

#### B. Sanity System Tests
**File**: `tests2/battlescape/sanity_system_test.lua` (~150 lines)
```lua
-- Test post-mission sanity loss (standard 0, moderate -1, hard -2, horror -3)
-- Test night mission penalty (-1)
-- Test ally death trauma (-1 per death)
-- Test mission failure trauma (-2)
-- Test sanity recovery (+1/week base, +2/week with Temple)
-- Test broken state (0 sanity = cannot deploy)
-- Test accuracy penalties from sanity
-- Test starting morale reduction from low sanity
```

#### C. Black Market Expansion Tests
**File**: `tests2/economy/black_market_expansion_test.lua` (~250 lines)
```lua
-- Test mission generation (7 types)
-- Test event purchasing (8 types)
-- Test unit recruitment (5 types)
-- Test craft purchasing (4 types)
-- Test corpse trading (5 types)
-- Test access tiers (karma/fame requirements)
-- Test discovery risk
-- Test karma penalties
```

#### D. Corpse Trading Tests
**File**: `tests2/economy/corpse_trading_test.lua` (~100 lines)
```lua
-- Test corpse creation from dead units
-- Test value calculation (type, condition)
-- Test condition modifiers (fresh +50%, preserved +100%, damaged -50%)
-- Test karma penalties (human -10, alien -15 to -25, VIP -30)
-- Test discovery risk (5%)
-- Test alternative uses (research, burial, ransom)
```

#### E. Integration Tests
**File**: `tests2/integration/morale_sanity_integration_test.lua` (~150 lines)
```lua
-- Test morale + sanity penalty stacking
-- Test complete mission flow (morale during, sanity after)
-- Test recovery cycle (weekly in base + Temple)
-- Test roster rotation strategy
-- Test broken state preventing deployment
```

### 2.2 Update Existing Tests (2 files, ~80 lines)

#### A. Karma System Tests
**File**: `tests2/politics/karma_system_test.lua` (~50 lines)
```lua
-- Add tests for new karma penalties:
suite:testMethod("applyMissionGenerationPenalty", ...)  -- -10 to -40
suite:testMethod("applyEventPurchasePenalty", ...)  -- -5 to -35
suite:testMethod("applyUnitRecruitmentPenalty", ...)  -- -10 to -30
suite:testMethod("applyCraftPurchasePenalty", ...)  -- -15 to -30
suite:testMethod("applyCorpseTradingPenalty", ...)  -- -10 to -30
```

#### B. Karma Reputation Tests
**File**: `tests2/basescape/karma_reputation_test.lua` (~30 lines)
```lua
-- Add tests for discovery consequences
suite:testMethod("applyDiscoveryPenalty", ...)  -- Fame -20 to -50
suite:testMethod("applyRelationPenalty", ...)  -- Relations -30 to -70
```

---

## Phase 3: Verification (Critical)

### 3.1 Run Tests
```bash
lovec "tests2/runners" run_subsystem battlescape
lovec "tests2/runners" run_subsystem economy
lovec "tests2/runners" run_subsystem politics
lovec "tests2/runners" run_all
```

**Expected**: All tests passing (100%)

### 3.2 Run Game
```bash
lovec "engine"
```

**Expected**: 
- Exit Code: 0
- No console errors
- Systems load successfully
- New features accessible in-game

### 3.3 Manual Testing
- Deploy unit to mission → Test morale events
- Complete mission → Test sanity loss
- Wait 1 week → Test sanity recovery
- Access black market → Test new services
- Purchase mission → Verify spawn on Geoscape
- Trade corpse → Verify karma penalty

---

## Implementation Priority Order

### Week 1: Core Morale/Sanity (Critical Path)
1. Update `morale_system.lua` (+200 lines)
2. Create `morale_actions.lua` (+150 lines)
3. Update `unit_recovery_progression.lua` (+50 lines)
4. Create `temple_facility.lua` (+100 lines)
5. Create morale/sanity tests (+350 lines)
6. Verify with game run

### Week 2: Black Market Expansion (High Value)
1. Update `black_market_system.lua` (+500 lines)
2. Create `corpse_trading.lua` (+150 lines)
3. Create `mission_generation.lua` (+200 lines)
4. Create `event_purchasing.lua` (+200 lines)
5. Create black market tests (+350 lines)
6. Update karma tests (+80 lines)
7. Verify with game run

### Week 3: Integration & Polish (Quality Assurance)
1. Create integration tests (+150 lines)
2. Full test suite run
3. Fix any issues discovered
4. Performance optimization
5. Documentation updates (if needed)
6. Final verification run

---

## Success Criteria

✅ All engine files updated/created
✅ All test files created/updated
✅ All tests passing (100%)
✅ Game runs without errors (Exit Code 0)
✅ Manual testing confirms functionality
✅ Documentation matches implementation
✅ Cross-layer consistency verified

---

**Total Work**: ~2,480 lines of code (1,550 engine + 930 tests)
**Estimated Time**: 15-20 hours
**Priority**: High (design complete, awaiting implementation)
**Blockers**: None (all dependencies satisfied)

