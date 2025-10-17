# Organization System

**Status:** Core Implementation Complete (UI pending)  
**Priority:** Medium  
**Version:** 1.0 (October 16, 2025)

---

## Overview

Organization level and progression system tracking player organization's development, capabilities, and unlocked features. Affects recruitment quality, funding, research speed, manufacturing capacity, and available advisors.

---

## Implemented Features

### Organization Level System (`organization.lua`)
- **5-Tier Progression**: Rookie → Established → Veteran → Elite → Legendary
- **Experience-Based**: Earn XP from missions, research, achievements
- **Level Thresholds**: 0-500, 501-1500, 1501-3500, 3501-6500, 6501+ XP
- **Automatic Leveling**: XP automatically triggers level-up when threshold reached
- **History Tracking**: Complete history of XP gains and level-ups

### Feature Unlocking System
- **19 Unlockable Features**: Squad sizes, equipment tiers, facility types, craft slots, advisors
- **Level-Gated**: Features unlock progressively from Rookie to Legendary
- **Cascading Access**: Higher levels unlock more advanced options
- **Feature Querying**: Check what's available at current level

### Bonus System
- **Recruitment Multiplier**: 1.0x (Rookie) → 2.2x (Legendary) - affects soldier quality/availability
- **Funding Multiplier**: 1.0x → 1.6x - affects monthly government grants
- **Research Multiplier**: 1.0x → 1.6x - affects technology development speed
- **Manufacturing Multiplier**: 1.0x → 1.4x - affects production efficiency
- **Advisor Slots**: 0 → 5 advisors available

---

## API Reference

### Organization System

```lua
local Organization = require("engine.politics.organization.organization")
local org = Organization:new()

-- XP Management
org:addXP(100, "Mission success")           -- Add XP with reason
org:getLevel()                              -- Returns current level (1-5)
org:getLevelName()                          -- Returns level name ("Rookie", etc)
org:getLevelProgress()                      -- Returns current/needed XP, progress %

-- Feature Unlocking
org:canUnlock("advanced_facilities")        -- Check if feature available
org:getUnlockedFeatures()                   -- List all unlocked features
org:getOrganizationBonus("recruitment")     -- Get bonus multiplier (1.0-2.2)
org:getAllBonuses()                         -- Get all bonus types

-- Statistics
org:getStats()                              -- Get complete stats object

-- Persistence
org:save()                                  -- Serialize for save file
org:load(data)                              -- Restore from save file
```

---

## Feature Unlock Progression

### Rookie (Level 1) - Basic Operations
- ✓ Basic facilities
- ✓ Small squads (4-6 units)
- ✓ Basic equipment
- ✓ Single craft

### Established (Level 2) - Growing Organization
- ✓ Advanced facilities
- ✓ Medium squads (6-10 units)
- ✓ Advanced equipment
- ✓ Two crafts
- ✓ First advisor
- ✓ Armor customization

### Veteran (Level 3) - Experienced Command
- ✓ Elite facilities
- ✓ Large squads (10-16 units)
- ✓ Elite equipment
- ✓ Three crafts
- ✓ Three advisors
- ✓ 25% research acceleration
- ✓ Special missions

### Elite (Level 4) - Strategic Influence
- ✓ Legendary facilities
- ✓ Full squads (16-20 units)
- ✓ Legendary equipment
- ✓ Four crafts
- ✓ Four advisors
- ✓ 50% research acceleration
- ✓ Minor diplomatic immunity
- ✓ 25% funding bonus

### Legendary (Level 5) - Maximum Organization
- ✓ Ultimate facilities
- ✓ Mega squads (20+ units)
- ✓ Ultimate equipment
- ✓ Five+ crafts
- ✓ Five advisors
- ✓ 100% research acceleration
- ✓ Full diplomatic immunity
- ✓ 50% funding bonus
- ✓ 50% construction discount

---

## XP Gain Sources

| Source | XP Amount | Condition |
|--------|-----------|-----------|
| Mission Success | 100 | Base reward |
| Mission Objectives | +50 per objective | Completing bonuses |
| Research Completion | tech_level * 100 | When research finishes |
| Facility Construction | facility_tier * 200 | When facility completes |
| Diplomatic Agreement | 50 | Successfully negotiated |
| Special Achievements | 50-500 | Event-based unlocks |

---

## Dependencies

- `politics/relations/` - Reputation and diplomatic integration
- `politics/fame/` - Organization fame system
- `politics/karma/` - Moral alignment affects org standing
- `economy/finance/` - Funding calculations
- `basescape/facilities/` - Facility unlocking
- `core/crafts/` - Craft capacity expansion

---

## Integration Points

### Recruitment System
Uses `getOrganizationBonus("recruitment")` to improve soldier quality/quantity based on level.

### Funding System
Government grants multiplied by `getOrganizationBonus("funding")` based on organization level.

### Research System
Research speed multiplied by `getOrganizationBonus("research")` based on organization level.

### Manufacturing System
Production efficiency multiplied by `getOrganizationBonus("manufacturing")` based on organization level.

### Advisor System
Maximum advisors limited by `getOrganizationBonus("advisor_slots")` based on organization level.

---

**Note:** UI screen for organization management is in scope for next phase.
