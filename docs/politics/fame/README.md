# Fame System - Public Recognition & Media Coverage

> **Implementation**: `engine/geoscape/systems/fame_system.lua`
> **Tests**: `tests/geoscape/`
> **Related**: `docs/politics/karma/`, `docs/economy/marketplace.md`, `docs/progression/organization.md`

The Fame system tracks how well-known the player's organization is across the world. Fame affects funding levels, recruitment quality, supplier availability, and attracts media attention with associated risks.

## 📊 Fame Mechanics

### Fame Scale
- **Range**: 0 (Unknown) to 100 (Legendary)
- **Starting Level**: 50 (Known)
- **Decay**: -2 points per month of inactivity

### Fame Levels

| Level | Range | Effects | Media Presence |
|-------|-------|---------|-----------------|
| **Unknown** | 0-24 | No funding bonus, limited recruitment | Minimal coverage |
| **Known** | 25-59 | 0% funding bonus (+1.0x multiplier) | Local news |
| **Famous** | 60-89 | +25% funding bonus (+1.25x multiplier) | International coverage |
| **Legendary** | 90-100 | +50% funding bonus (+1.5x multiplier) | Global sensation |

## 🎯 Fame Effects

### Funding System
- **Unknown**: 0.5x multiplier on base funding
- **Known**: 1.0x multiplier (baseline funding)
- **Famous**: 1.25x multiplier (25% increase)
- **Legendary**: 1.5x multiplier (50% increase)

### Recruitment Quality
- **Unknown**: Only basic recruits available
- **Known**: Standard recruits with average stats
- **Famous**: Better recruits with +1 stat increase
- **Legendary**: Elite recruits with +2 stat increase

### Supplier Access
- Minimum fame requirements unlock premium suppliers
- High fame provides access to restricted equipment suppliers
- Legendary fame unlocks exotic equipment sources

### Black Market Risk
- **Unknown**: 5% discovery chance per transaction
- **Known**: 10% discovery chance
- **Famous**: 15% discovery chance (higher scrutiny)
- **Legendary**: 20% discovery chance (maximum scrutiny)

### Panic Reduction
- Famous organization reassures civilians in panic zones
- Legendary organization provides significant panic reduction
- Mission success better counteracts panic at high fame

## 📈 Fame Gains

| Event | Fame Gain | Notes |
|-------|-----------|-------|
| Mission Success | +5 | Standard mission victory |
| UFO Destroyed | +2 | Downing UFO in combat |
| Research Breakthrough | +3 | Completing major research |
| Major Victory | +15 | Significant strategic win |
| Base Defense Victory | +10 | Successfully defending own base |
| UFO Interception | +8 | Successful craft combat |

## 📉 Fame Losses

| Event | Fame Loss | Notes |
|-------|-----------|-------|
| Mission Failure | -3 | Mission objective not achieved |
| Base Raided | -10 | Base successfully attacked |
| Civilian Casualties | -5 | Per mission with civilian deaths |
| Black Market Discovery | -20 | Getting caught in black market deal |
| High-Profile Defeat | -15 | Loss of flagship base or squad |
| Research Failure | -2 | Failed research project |

## 🔄 Fame Trends

The system tracks changes over recent history to identify trends:

- **Improving**: Average gain > +1 per recent action
- **Declining**: Average loss > -1 per recent action  
- **Stable**: Less than ±1 average change

Trends affect:
- Recruitment morale (improving trend = better morale)
- Supplier relationships (improving trend = better prices)
- Country funding (declining trend may trigger funding loss notifications)

## 🎮 Strategic Implications

### High Fame Strategy
- Maximize funding for base expansion and research
- Access better equipment from premium suppliers
- Attract quality recruits and experienced soldiers
- BUT: Higher discovery risk for black market activities

### Low Fame Strategy
- Minimal scrutiny enables covert operations
- Black market access carries less risk
- Lower funding requires careful resource management
- Recruitment limited to basic troops

### Balanced Approach
- Maintain "Known" or "Famous" level for steady funding
- Strategic use of black market with manageable discovery risk
- Access to good suppliers while maintaining operational security

## 📋 Implementation Details

**Key Systems Integration:**
- `FundingSystem`: Multiplies monthly funding by fame modifier
- `RecruitmentSystem`: Filters available recruits based on fame level
- `MarketplaceSystem`: Some suppliers require minimum fame
- `BlackMarketSystem`: Increases discovery chance based on fame
- `ReputationSystem`: Fame is 40% weight in overall reputation calculation

**State Persistence:**
- Fame value saved in save game
- History of recent changes maintained (last 20 changes)
- Trend calculated automatically from history

**Events:**
- `fame_level_changed`: Fired when crossing threshold to new level
- `fame_modified`: Fired on any fame change (with delta and reason)

## 🔗 Cross-System Interactions

### With Karma System
- High karma (Saint) + High fame = Genuine heroism, funding bonus
- Low karma (Evil) + High fame = Ruthless efficiency, funding bonus but supplier penalties

### With Relations System
- High fame improves country opinions (+1-2 relationship per major success)
- High fame damage (discovery, disaster) impacts all country relationships

### With Economy
- High fame allows negotiation for better supplier prices (-10-20%)
- High fame attracts investors (bonus funding opportunities)

