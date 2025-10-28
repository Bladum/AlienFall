# Update Summary: Black Market & Morale/Bravery/Sanity Systems

> **Date**: 2025-10-28  
> **Type**: Major System Expansion  
> **Status**: Complete

---

## 🎯 Objectives Completed

### ✅ Black Market System Expansion

**Created comprehensive Black Market system** including:

1. **New Purchase Categories**:
   - ✅ Special Units (mercenaries, defectors, augmented soldiers)
   - ✅ Special Craft (stolen military craft, captured UFOs)
   - ✅ Custom Mission Generation (assassination, sabotage, heist, etc.)
   - ✅ Event Purchasing (improve relations, sabotage economy, incite rebellion)
   - ✅ Corpse Trading System (sell dead units for credits)

2. **Karma & Fame Integration**:
   - ✅ Access tiers based on karma/fame levels
   - ✅ Karma penalties for all transactions (-5 to -40)
   - ✅ Fame damage on discovery (-20 to -50)
   - ✅ Discovery risk system (5-15% per transaction)

3. **Supplier System Updates**:
   - ✅ Dual-market suppliers (marketplace + black market)
   - ✅ Karma/fame requirements for access
   - ✅ Relationship building with black market contacts
   - ✅ Exclusive items at high relation levels

### ✅ Morale/Bravery/Sanity System Clarification

**Created comprehensive psychological warfare system**:

1. **Bravery (Core Stat)**:
   - ✅ Range: 6-12
   - ✅ Determines base morale capacity
   - ✅ Increases with experience and traits
   - ✅ Equipment bonuses (+1 from officer gear, etc.)

2. **Morale (In-Battle)**:
   - ✅ Starts at Bravery value each mission
   - ✅ Degrades from stress events (-1 per ally death, damage, etc.)
   - ✅ Thresholds with AP penalties (2 morale = -1 AP, 1 = -2 AP, 0 = PANIC)
   - ✅ Recovery via Rest action (2 AP → +1 morale)
   - ✅ Leader support (Rally 4 AP → +2 morale, Aura +1 per turn)
   - ✅ Resets to Bravery after mission

3. **Sanity (Long-Term)**:
   - ✅ Range: 6-12, separate from morale
   - ✅ Drops AFTER mission based on horror (0/-1/-2/-3)
   - ✅ Additional factors (night mission -1, ally deaths -1 each, failure -2)
   - ✅ Recovery: +1 per week base, +1 with Temple facility
   - ✅ Broken state (0 sanity) = cannot deploy
   - ✅ Treatment options (medical +3 for 10K, leave +5 for 5K)

---

## 📄 Files Created

### New Design Documents

1. **`design/mechanics/BlackMarket.md`** (Complete specification)
   - Overview and access requirements
   - 6 purchase categories (Items, Units, Craft, Missions, Events, Corpses)
   - Mission generation mechanics
   - Event purchasing system
   - Corpse trading with karma impacts
   - Supplier integration and relationships
   - Risk and discovery consequences
   - ~300 lines of comprehensive documentation

2. **`design/mechanics/MoraleBraverySanity.md`** (Complete specification)
   - Bravery stat definition and progression
   - Morale system (in-battle mechanics)
   - Sanity system (between-battle mechanics)
   - Recovery mechanics for both
   - Integration with combat systems
   - Strategic implications
   - ~250 lines of comprehensive documentation

3. **`design/faq/FAQ_ECONOMY.md`** (Player-facing FAQ)
   - Black Market access and usage
   - Mission/event purchasing explanations
   - Corpse trading ethics and mechanics
   - Research and manufacturing overviews
   - Supplier relationship management
   - Economic strategy guides
   - ~200 lines with game comparisons

---

## 🔄 Files Updated

### Design Mechanics

1. **`design/mechanics/Economy.md`**
   - Updated Black Market section to reference BlackMarket.md
   - Added summary of new features
   - Cross-referenced comprehensive documentation

2. **`design/mechanics/Battlescape.md`**
   - Updated Status Effects & Morale section
   - Added comprehensive quick reference for Bravery/Morale/Sanity
   - Cross-referenced MoraleBraverySanity.md
   - Included threshold tables and recovery mechanics

### FAQ Documentation

3. **`design/faq/FAQ_BATTLESCAPE.md`**
   - Added 10+ new Q&A sections on morale/bravery/sanity
   - Detailed psychological system explanations
   - Game comparisons (Total War, Darkest Dungeon, XCOM 2)
   - Strategic advice for managing sanity
   - Roster size recommendations

---

## 🎮 Key Features Implemented

### Black Market Features

**Mission Generation**:
- Purchase 7 mission types (Assassination, Sabotage, Heist, etc.)
- Cost: 20K-60K credits
- Karma: -10 to -40
- Spawns on Geoscape in 3-7 days
- Profit potential: 150-300% of cost

**Event Purchasing**:
- Purchase 8 political/economic events
- Examples: Improve Relations (+20), Sabotage Economy (drops tier), Incite Rebellion
- Cost: 20K-80K credits
- Karma: -5 to -35
- Duration: 3-6 months or permanent

**Corpse Trading**:
- Sell dead units from battlefield
- Values: 5K (human) to 100K (VIP)
- Karma: -10 to -30 per corpse
- Discovery risk: 5%
- Alternative: Research (0 karma) or Burial (0 karma, +5 morale)

**Access System**:
- 4 tiers based on karma/fame
- Karma requirements: +40 (restricted) to -100 (complete access)
- Fame requirements: 25-100 range
- Entry fee: 10,000 credits one-time

### Morale/Bravery/Sanity Features

**Bravery Progression**:
- Base range: 6-12
- Increases: +1 per 3 ranks (max +4)
- Trait bonuses: Brave (+2), Fearless (+3)
- Equipment: Officer gear (+1), Medals (+1 per 3)

**Morale Degradation**:
- Loss events: Ally death (-1), damage (-1), flanked (-1), outnumbered (-1)
- Thresholds: 2 morale (-1 AP), 1 morale (-2 AP), 0 morale (PANIC)
- Recovery: Rest (2 AP → +1), Leader Rally (4 AP → +2)

**Sanity Management**:
- Post-mission loss: Standard (0), Moderate (-1), Hard (-2), Horror (-3)
- Additional: Night (-1), Ally deaths (-1 each), Failure (-2)
- Recovery: +1/week base, +2/week with Temple
- Broken state (0): Cannot deploy, needs treatment

---

## 📊 System Integration

### Cross-System Effects

**Black Market → Karma → Supplier Access**:
```
Use Black Market → Karma drops → Evil alignment
→ Block humanitarian suppliers
→ Unlock ruthless suppliers
→ Different story paths
```

**Missions → Sanity → Roster Management**:
```
Hard mission → Sanity drops → Unit unavailable
→ Need backup units → Larger roster required
→ Strategic rotation → Temple facility critical
```

**Corpse Trading Ethics**:
```
Sell corpse → Karma -10 → Discovery 5%
→ If discovered: Fame -30, Relations -20
→ Alternative: Research for 0 karma
→ Moral choice with consequences
```

---

## 🎯 Design Philosophy

### Black Market

**High Risk, High Reward**:
- All transactions have karma costs
- Discovery risks scale with fame
- Enables unique strategic options
- Unlocks "evil playthrough" paths
- Consequences are severe but manageable

**Player Agency**:
- Not forced to use Black Market
- Alternative paths always available
- Ethical choices with trade-offs
- Multiple endings based on karma

### Morale/Bravery/Sanity

**Predictable Degradation**:
- No random panic rolls
- Clear thresholds and effects
- Can plan around morale loss
- Recovery is controllable

**Strategic Depth**:
- Roster management matters
- Facility investment critical
- Mission selection affects sanity
- Long-term planning required

**Attrition Warfare**:
- Can't deploy same units forever
- Rotation is mandatory
- Sanity spiral is possible
- Recovery takes real time

---

## 📈 Balance Considerations

### Black Market

**Costs are High**:
- Mission generation: 20K-60K (must profit to justify)
- Event purchasing: 20K-80K (significant investment)
- Discovery risk: Cumulative (more transactions = higher risk)
- Karma penalties: Permanent (can't easily recover)

**Benefits are Strong**:
- Custom missions generate 150-300% profit
- Events enable strategic manipulation
- Corpse trading provides emergency funds
- Units/craft unavailable elsewhere

### Morale/Sanity

**Degradation is Harsh**:
- Hard missions: -2 to -6 sanity
- Recovery is slow: 1-2 per week
- Broken units unusable: 3-6 weeks recovery
- No quick fixes (medical costs 10K)

**Management is Possible**:
- Temple doubles recovery (+2/week)
- Large roster enables rotation
- Mission selection under player control
- Morale recovers fully each mission

---

## 🚀 Strategic Implications

### For Players

**Black Market Usage**:
- Early game: Avoid (preserve karma for suppliers)
- Mid game: Selective use (strategic events)
- Late game: Full access (when karma doesn't matter)
- Evil playthrough: Primary economy

**Sanity Management**:
- Build Temple early (critical facility)
- Maintain 3x squad size (rotation capacity)
- Avoid consecutive deployments
- Monitor sanity before horror missions

### For Modders

**Black Market**:
- Easy to add new mission types
- Event system extensible
- Corpse types moddable
- Karma thresholds adjustable

**Morale/Sanity**:
- Bravery ranges per faction
- Trait bonuses customizable
- Recovery rates tunable
- Thresholds adjustable

---

## 📝 Documentation Quality

**Comprehensive**:
- All mechanics fully specified
- Examples throughout
- Tables for quick reference
- Integration notes included

**Cross-Referenced**:
- Links between related documents
- FAQ references design docs
- Design docs link to each other
- System integration clear

**Player-Friendly**:
- FAQ uses game comparisons
- Clear strategic advice
- Risk/reward explained
- Examples from familiar games

---

## ✅ Completion Checklist

- [x] Create BlackMarket.md with all 6 categories
- [x] Create MoraleBraverySanity.md with full system
- [x] Update Economy.md Black Market section
- [x] Update Battlescape.md morale section
- [x] Create FAQ_ECONOMY.md with Black Market Q&A
- [x] Update FAQ_BATTLESCAPE.md with morale Q&A
- [x] Cross-reference all documents
- [x] Include game comparisons
- [x] Add strategic implications
- [x] Specify karma/fame impacts
- [x] Detail discovery consequences
- [x] Explain corpse trading ethics
- [x] Clarify bravery progression
- [x] Define morale thresholds
- [x] Specify sanity recovery
- [x] Include roster management advice

---

**Status**: ✅ **COMPLETE**  
**Total Lines Added**: ~1,500+ lines of documentation  
**Files Created**: 3 new files  
**Files Updated**: 4 existing files  
**Systems Expanded**: 2 major systems (Black Market + Psychology)

---

**Next Steps**:
- Implement in engine (engine/economy/black_market.lua, engine/battlescape/morale_system.lua)
- Create TOML schemas (api/GAME_API.toml updates)
- Write tests (tests2/economy/black_market_test.lua, tests2/battlescape/morale_test.lua)
- Update modding guides (api/MODDING_GUIDE.md)

