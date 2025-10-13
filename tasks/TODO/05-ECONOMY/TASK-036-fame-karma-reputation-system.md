# Task: Fame, Karma & Reputation System - Integrated Meta-Progression

**Status:** TODO  
**Priority:** High  
**Created:** October 13, 2025  
**Completed:** N/A  
**Assigned To:** AI Agent

---

## Overview

Implement integrated Fame, Karma, and Reputation systems that track player's public recognition, moral choices, and relationships. These systems affect supplier prices/availability, country funding, faction missions, black market access, and unlock special content.

---

## Purpose

Create interconnected meta-progression systems that give player actions meaning beyond immediate tactical benefits. Fame tracks how well-known the organization is, Karma tracks ethical choices, and Reputation aggregates overall standing. These affect all economic and diplomatic systems.

---

## Requirements

### Functional Requirements
- [ ] **Fame System:** Public recognition level (0-100)
- [ ] **Karma System:** Moral alignment (-100 to +100)
- [ ] **Reputation System:** Aggregate standing with entities
- [ ] **Score System:** Monthly performance rating
- [ ] **Fame Effects:** Recruitment, supplier access, funding bonuses
- [ ] **Karma Effects:** Black market access, special missions, content unlocks
- [ ] **Reputation Effects:** Prices, availability, relations
- [ ] **Score Effects:** End-game achievements, rankings
- [ ] **Integration:** All systems affect suppliers, countries, factions

### Technical Requirements
- [ ] Persistent state tracking
- [ ] Event-driven updates
- [ ] Visual feedback (meters, notifications)
- [ ] Integration with marketplace (TASK-034)
- [ ] Integration with black market (TASK-035)
- [ ] Integration with relations (TASK-027)
- [ ] Integration with funding system

### Acceptance Criteria
- [ ] Fame increases from successful missions, decreases from failures
- [ ] Karma changes based on ethical choices (civilians, prisoners, black market)
- [ ] Reputation calculated from fame, karma, and relations
- [ ] High fame attracts better recruits and increases funding
- [ ] Low karma unlocks black market, high karma unlocks humanitarian missions
- [ ] Reputation affects all supplier prices and availability
- [ ] Score calculated monthly from performance
- [ ] Visual meters show current levels

---

## Plan

### Step 1: Fame System (8 hours)
**Description:** Track public recognition and media coverage  
**Files to create:**
- `engine/geoscape/systems/fame_system.lua`
- `engine/geoscape/logic/fame_modifiers.lua`

**Fame System:**
```lua
FameSystem = {
    fame = 50,  -- Current fame (0-100)
    level = "Known",  -- Unknown, Known, Famous, Legendary
    
    -- Thresholds
    thresholds = {
        unknown = 0,
        known = 25,
        famous = 60,
        legendary = 90,
    },
}

FameSystem:modifyFame(delta, reason)
    local oldFame = self.fame
    self.fame = math.max(0, math.min(100, self.fame + delta))
    
    -- Check level change
    local oldLevel = self:getLevel(oldFame)
    local newLevel = self:getLevel(self.fame)
    
    if oldLevel ~= newLevel then
        EventManager:emit("fame_level_changed", {
            oldLevel = oldLevel,
            newLevel = newLevel,
            fame = self.fame,
        })
    end
    
    print("[Fame] " .. oldFame .. " → " .. self.fame .. " (" .. reason .. ")")

FameSystem:getLevel(fame)
    if fame >= 90 then return "Legendary" end
    if fame >= 60 then return "Famous" end
    if fame >= 25 then return "Known" end
    return "Unknown"

FameSystem:getFameModifier()
    -- Returns multiplier for funding (0.5 to 2.0)
    return 0.5 + (self.fame / 100) * 1.5
```

**Fame Sources:**
- **Mission Success:** +5 fame
- **Mission Failure:** -3 fame
- **UFO Destroyed:** +2 fame
- **Base Raided:** -10 fame
- **Research Breakthrough:** +3 fame
- **Black Market Discovery:** -20 fame
- **Major Victory:** +15 fame
- **Civilian Casualties:** -5 fame

**Fame Effects:**
1. **Funding:** High fame = higher monthly funding
2. **Recruitment:** Better recruit quality at high fame
3. **Supplier Access:** Some suppliers require minimum fame
4. **Media Attention:** High fame = more scrutiny (black market risk)
5. **Panic Reduction:** Famous organization reassures civilians

**Estimated time:** 8 hours

---

### Step 2: Karma System (8 hours)
**Description:** Track moral/ethical choices  
**Files to create:**
- `engine/geoscape/systems/karma_system.lua`
- `engine/geoscape/logic/karma_modifiers.lua`

**Karma System:**
```lua
KarmaSystem = {
    karma = 0,  -- Current karma (-100 to +100)
    alignment = "Neutral",  -- Saint, Good, Neutral, Dark, Evil
    
    -- Thresholds
    thresholds = {
        saint = 75,
        good = 25,
        neutral = -24,
        dark = -74,
        evil = -100,
    },
}

KarmaSystem:modifyKarma(delta, reason)
    local oldKarma = self.karma
    self.karma = math.max(-100, math.min(100, self.karma + delta))
    
    -- Check alignment change
    local oldAlign = self:getAlignment(oldKarma)
    local newAlign = self:getAlignment(self.karma)
    
    if oldAlign ~= newAlign then
        EventManager:emit("karma_alignment_changed", {
            oldAlignment = oldAlign,
            newAlignment = newAlign,
            karma = self.karma,
        })
    end
    
    print("[Karma] " .. oldKarma .. " → " .. self.karma .. " (" .. reason .. ")")

KarmaSystem:getAlignment(karma)
    if karma >= 75 then return "Saint" end
    if karma >= 25 then return "Good" end
    if karma >= -24 then return "Neutral" end
    if karma >= -75 then return "Dark" end
    return "Evil"
```

**Karma Sources:**
- **Civilian Saved:** +2 karma
- **Civilian Killed:** -5 karma
- **Prisoner Executed:** -10 karma
- **Prisoner Interrogated (torture):** -3 karma
- **Humanitarian Mission:** +10 karma
- **Black Market Purchase:** -5 to -20 karma
- **War Crime:** -30 karma
- **Peaceful Resolution:** +15 karma

**Karma Effects:**
1. **Black Market Access:** Low karma unlocks black market
2. **Mission Types:** High karma = humanitarian missions, Low karma = covert ops
3. **Recruit Morale:** High karma improves morale
4. **Supplier Attitudes:** Ethical suppliers prefer high karma
5. **Story Branches:** Karma affects campaign choices
6. **End Game:** Different endings based on karma

**Estimated time:** 8 hours

---

### Step 3: Reputation System (8 hours)
**Description:** Aggregate standing calculation  
**Files to create:**
- `engine/geoscape/systems/reputation_system.lua`
- `engine/geoscape/logic/reputation_calculator.lua`

**Reputation System:**
```lua
ReputationSystem = {
    reputation = 50,  -- Overall reputation (0-100)
    
    -- Component weights
    weights = {
        fame = 0.4,
        karma = 0.2,
        countryRelations = 0.3,
        supplierRelations = 0.1,
    },
}

ReputationSystem:calculateReputation()
    local fame = FameSystem:getFame()  -- 0-100
    local karma = (KarmaSystem:getKarma() + 100) / 2  -- Convert -100/+100 to 0-100
    local countries = self:getAverageCountryRelation()  -- -2 to +2, convert to 0-100
    local suppliers = self:getAverageSupplierRelation()  -- -2 to +2, convert to 0-100
    
    -- Weighted average
    self.reputation = 
        (fame * self.weights.fame) +
        (karma * self.weights.karma) +
        (countries * self.weights.countryRelations) +
        (suppliers * self.weights.supplierRelations)
    
    return self.reputation

ReputationSystem:getAverageCountryRelation()
    local total = 0
    local count = 0
    for country in CountryManager:getAllCountries() do
        local rel = RelationsManager:getRelation("country", country.id)
        total += ((rel + 2) / 4) * 100  -- Convert -2/+2 to 0-100
        count += 1
    end
    return count > 0 and (total / count) or 50

ReputationSystem:getLabel()
    if self.reputation >= 90 then return "Legendary" end
    if self.reputation >= 70 then return "Excellent" end
    if self.reputation >= 50 then return "Good" end
    if self.reputation >= 30 then return "Poor" end
    return "Terrible"
```

**Reputation Effects:**
- All marketplace prices (-30% to +50%)
- Item availability (some items require minimum reputation)
- Mission access (special missions for high reputation)
- Funding multiplier
- Recruit quality

**Estimated time:** 8 hours

---

### Step 4: Score System (6 hours)
**Description:** Monthly performance rating  
**Files to create:**
- `engine/geoscape/systems/score_system.lua`

**Score System:**
```lua
ScoreSystem = {
    monthlyScore = 0,
    totalScore = 0,
    scoreHistory = {},  -- Month-by-month
}

ScoreSystem:calculateMonthlyScore()
    local score = 0
    
    -- Mission performance
    score += missionSuccesses * 50
    score -= missionFailures * 30
    
    -- UFO activity
    score += ufosDestroyed * 20
    score -= ufosEscaped * 10
    
    -- Civilian protection
    score += civiliansSaved * 5
    score -= civiliansKilled * 10
    
    -- Country satisfaction
    for country in CountryManager:getAllCountries() do
        local rel = RelationsManager:getRelation("country", country.id)
        score += rel * 100  -- -200 to +200 per country
    end
    
    -- Research progress
    score += researchCompleted * 100
    
    -- Reputation bonus
    score += ReputationSystem:getReputation() * 2
    
    self.monthlyScore = score
    self.totalScore += score
    
    table.insert(self.scoreHistory, {
        month = Calendar:getCurrentMonth(),
        year = Calendar:getCurrentYear(),
        score = score,
    })
    
    return score

ScoreSystem:getRank()
    if self.totalScore >= 50000 then return "S" end
    if self.totalScore >= 30000 then return "A" end
    if self.totalScore >= 15000 then return "B" end
    if self.totalScore >= 5000 then return "C" end
    return "D"
```

**Score Effects:**
- End-game achievements
- Global leaderboard (optional)
- Advisor availability (high score attracts advisors)
- Special funding bonuses

**Estimated time:** 6 hours

---

### Step 5: Supplier Integration (8 hours)
**Description:** Link fame/karma/reputation to supplier system  
**Dependencies:** TASK-034 (Marketplace System)
**Files to modify:**
- `engine/geoscape/logic/marketplace_pricing.lua`
- `engine/geoscape/systems/supplier_manager.lua`

**Supplier Reputation Effects:**
```lua
-- Enhanced pricing formula from TASK-034
MarketplacePricing:calculatePrice(entry, quantity, supplierId)
    local basePrice = entry.basePrice
    
    -- 1. Supplier relationship (-50% to +100%)
    local relationshipMod = self:getRelationshipModifier(supplierId)
    
    -- 2. Bulk discount (5% per 10 items, max 30%)
    local bulkDiscount = self:getBulkDiscount(quantity)
    
    -- 3. REPUTATION MODIFIER (-20% to +30%)
    local reputation = ReputationSystem:getReputation()
    local reputationMod = 1.3 - (reputation / 100) * 0.5  -- 130% at 0 rep, 80% at 100 rep
    
    -- 4. FAME MODIFIER (famous = better deals)
    local fame = FameSystem:getFame()
    local fameMod = 1.1 - (fame / 100) * 0.2  -- 110% at 0 fame, 90% at 100 fame
    
    -- Final price
    local pricePerUnit = basePrice * relationshipMod * bulkDiscount * reputationMod * fameMod
    local totalPrice = pricePerUnit * quantity
    
    return pricePerUnit, totalPrice
end

-- Supplier access based on reputation/karma
SupplierManager:canAccessSupplier(supplierId)
    local supplier = self:getSupplier(supplierId)
    
    -- Check reputation requirement
    if supplier.minReputation then
        if ReputationSystem:getReputation() < supplier.minReputation then
            return false, "Insufficient reputation"
        end
    end
    
    -- Check karma requirement
    if supplier.minKarma then
        if KarmaSystem:getKarma() < supplier.minKarma then
            return false, "Supplier refuses to deal with you"
        end
    end
    
    -- Check fame requirement
    if supplier.minFame then
        if FameSystem:getFame() < supplier.minFame then
            return false, "Supplier hasn't heard of you"
        end
    end
    
    return true
end
```

**Example Suppliers with Requirements:**
```toml
[ethical_supplier]
id = "ethical_defense"
name = "Ethical Defense Corporation"
min_karma = 25  # Only deals with "good" orgs
min_reputation = 60

[premium_supplier]
id = "luxury_arms"
name = "Luxury Arms International"
min_fame = 70  # Only deals with famous orgs
min_reputation = 80

[black_market_dealer]
id = "underground_network"
max_karma = -10  # Only deals with "dark" orgs
min_reputation = 0  # No reputation requirement
```

**Estimated time:** 8 hours

---

### Step 6: Country Funding Integration (6 hours)
**Description:** Link fame/reputation to country funding  
**Dependencies:** TASK-027 (Relations System)
**Files to modify:**
- `engine/geoscape/systems/funding_manager.lua`

**Funding Formula:**
```lua
FundingManager:calculateMonthlyFunding(countryId)
    local country = CountryManager:getCountry(countryId)
    local baseFunding = country.baseFunding  -- e.g., $100,000
    
    -- 1. Country relationship (-100% to +200%)
    local relation = RelationsManager:getRelation("country", countryId)
    local relationMod = 1.0 + (relation / 2)  -- -2 = 0%, 0 = 100%, +2 = 200%
    
    -- 2. FAME MODIFIER (0.5x to 2x)
    local fameMod = FameSystem:getFameModifier()  -- 0.5 to 2.0
    
    -- 3. REPUTATION MODIFIER (0.7x to 1.3x)
    local reputation = ReputationSystem:getReputation()
    local reputationMod = 0.7 + (reputation / 100) * 0.6
    
    -- 4. Score modifier (monthly performance)
    local scoreMod = 1.0 + (ScoreSystem:getMonthlyScore() / 10000)  -- Bonus for good score
    
    -- Final funding
    local funding = baseFunding * relationMod * fameMod * reputationMod * scoreMod
    return funding
end
```

**Effect Examples:**
```
Low fame (10) + low reputation (20) + poor relations (-1):
  $100k * 0.5 * 0.55 * 0.82 = $22,550 (77.5% cut)

High fame (90) + high reputation (85) + good relations (+1.5):
  $100k * 2.0 * 1.21 * 1.82 = $440,440 (340% increase!)
```

**Estimated time:** 6 hours

---

### Step 7: Mission Unlocks (6 hours)
**Description:** Fame/karma unlock special mission types  
**Files to create:**
- `engine/geoscape/logic/mission_unlocks.lua`

**Mission Type Unlocks:**
```lua
-- High Karma missions
MissionType = {
    id = "humanitarian_aid",
    requiredKarma = 50,  -- "Good" or better
    description = "Help disaster victims",
    rewards = {karma = 10, fame = 5},
}

-- Low Karma missions
MissionType = {
    id = "black_ops",
    maxKarma = -25,  -- "Dark" or worse
    description = "Covert elimination",
    rewards = {credits = 50000, karma = -10},
}

-- High Fame missions
MissionType = {
    id = "public_demonstration",
    requiredFame = 70,  # "Famous" or better
    description = "Public weapons demonstration",
    rewards = {fame = 10, funding_boost = 1.2},
}
```

**Estimated time:** 6 hours

---

### Step 8: UI Implementation (14 hours)
**Description:** Visual meters, panels, and notifications  
**Files to create:**
- `engine/geoscape/ui/fame_meter.lua`
- `engine/geoscape/ui/karma_meter.lua`
- `engine/geoscape/ui/reputation_panel.lua`
- `engine/geoscape/ui/organization_screen.lua`

**Organization Screen Layout:**
```
┌─────────────────────────────────────────┐
│ Organization Status                     │
├─────────────────────────────────────────┤
│ Fame:       [████████░░] 80 (Famous)   │
│ Karma:      [░░░░█████░] 45 (Good)     │
│ Reputation: [███████░░░] 72 (Excellent)│
│ Score:      15,450 (Rank: B)            │
├─────────────────────────────────────────┤
│ Effects:                                │
│ • Funding: +60% (fame bonus)            │
│ • Prices: -15% (reputation bonus)       │
│ • Recruitment: +2 quality (fame)        │
│ • Black Market: Locked (karma too high) │
├─────────────────────────────────────────┤
│ Recent Changes:                         │
│ • Mission success: +5 fame              │
│ • Civilian saved: +2 karma              │
│ • Country relations improved            │
└─────────────────────────────────────────┘
```

**Widgets:**
- FameMeter (horizontal bar, 0-100)
- KarmaMeter (horizontal bar, -100 to +100, colored)
- ReputationPanel (aggregate with breakdown)
- OrganizationScreen (full status overview)
- NotificationPopup (on level changes)

**Estimated time:** 14 hours

---

### Step 9: Event System Integration (6 hours)
**Description:** Automatic updates from game events  
**Files to create:**
- `engine/geoscape/systems/meta_progression_events.lua`

**Event Listeners:**
```lua
-- Mission events
EventManager:on("mission_completed", function(mission)
    if mission.success then
        FameSystem:modifyFame(5, "Mission success: " .. mission.name)
        ScoreSystem:addMissionSuccess()
    else
        FameSystem:modifyFame(-3, "Mission failure: " .. mission.name)
        ScoreSystem:addMissionFailure()
    end
end)

-- Civilian events
EventManager:on("civilian_killed", function(data)
    KarmaSystem:modifyKarma(-5, "Civilian casualty")
    FameSystem:modifyFame(-2, "Civilian casualties reported")
    ScoreSystem:addCivilianCasualty()
end)

-- Black market events
EventManager:on("black_market_purchase", function(purchase)
    KarmaSystem:modifyKarma(purchase.karmaImpact, "Black market deal")
end)

EventManager:on("black_market_discovered", function(data)
    FameSystem:modifyFame(-20, "Illegal arms scandal")
    KarmaSystem:modifyKarma(data.karmaImpact * 2, "Black market exposed")
end)

-- Research events
EventManager:on("research_completed", function(research)
    FameSystem:modifyFame(3, "Research breakthrough")
    ScoreSystem:addResearch()
end)

-- Monthly update
EventManager:on("month_end", function()
    ScoreSystem:calculateMonthlyScore()
    ReputationSystem:calculateReputation()
end)
```

**Estimated time:** 6 hours

---

### Step 10: Data Files & Testing (10 hours)
**Description:** Configuration data and comprehensive testing  
**Files to create:**
- `engine/data/meta_progression_config.lua`
- `engine/geoscape/tests/test_fame_system.lua`
- `engine/geoscape/tests/test_karma_system.lua`
- `engine/geoscape/tests/test_reputation_system.lua`

**Test Cases:**
1. Fame increases/decreases correctly
2. Karma alignment changes trigger events
3. Reputation calculated from components
4. Score accumulates monthly
5. Supplier prices affected by reputation
6. Funding affected by fame
7. Missions unlock based on karma/fame
8. Black market access based on karma

**Estimated time:** 10 hours

---

### Step 11: Documentation (6 hours)
**Description:** Complete API and gameplay documentation  
**Files to update:**
- `wiki/API.md`
- `wiki/FAQ.md`
- `wiki/wiki/organization.md`

**Estimated time:** 6 hours

---

## Implementation Details

### System Interactions

```
Fame (Public Recognition)
  ├─> Funding: +50% to +200%
  ├─> Recruitment: Better quality
  ├─> Supplier Access: Unlock premium suppliers
  └─> Black Market: Higher discovery risk

Karma (Moral Alignment)
  ├─> Mission Types: Unlock karma-specific missions
  ├─> Black Market: Low karma unlocks access
  ├─> Morale: High karma improves morale
  └─> Story: Affects campaign branches

Reputation (Aggregate Standing)
  ├─> Prices: -30% to +50%
  ├─> Availability: Unlock items/suppliers
  ├─> Relations: Affects all entity relations
  └─> Funding: +/- 30%

Score (Performance Rating)
  ├─> Achievements: End-game rewards
  ├─> Advisors: High score attracts advisors
  └─> Leaderboard: Optional global ranking
```

---

## Time Estimate

**Total: 94 hours (12 days)**

- Step 1: Fame System - 8h
- Step 2: Karma System - 8h
- Step 3: Reputation System - 8h
- Step 4: Score System - 6h
- Step 5: Supplier Integration - 8h
- Step 6: Country Funding Integration - 6h
- Step 7: Mission Unlocks - 6h
- Step 8: UI Implementation - 14h
- Step 9: Event System Integration - 6h
- Step 10: Data Files & Testing - 10h
- Step 11: Documentation - 6h

---

## Dependencies

- **TASK-027:** Relations system (country relations)
- **TASK-034:** Marketplace system (supplier integration)
- **TASK-035:** Black market system (karma effects)
- **TASK-025 Phase 2:** Calendar (monthly calculations)
