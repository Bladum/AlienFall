# TASK-010: Game Balance and Economy

**Status:** DONE  
**Created:** October 15, 2025  
**Completed:** October 15, 2025  
**Priority:** HIGH  
**Effort:** 13 hours

## Overview

Document game balance parameters, economic systems, and balancing philosophy for all game layers.

## Completed Work

✅ Created `docs/balance/GAME_NUMBERS.md` (276 lines)
✅ Created `docs/rules/MECHANICAL_DESIGN.md` (306 lines)
- Complete balance reference with all tuning values
- Action economy (AP costs, movement)
- Combat mechanics (hit chance, damage, morale)
- Economy and resources (funding, salaries, research)
- Base management costs and capacities
- Battlescape parameters

## What Was Done

1. Extracted balance data from `wiki/numbers.md`
2. Extracted mechanical rules from `wiki/rules ideas.md`
3. Organized by game layer (tactical, strategic, economic)
4. Created reference tables for easy lookup
5. Included balancing philosophy

## Action Economy

| Action | AP Cost | Notes |
|--------|---------|-------|
| Move (1 tile) | 1 | Base, terrain modifies |
| Snap Shot | 1 | Quick attack, -10% accuracy |
| Aimed Shot | 2 | Standard attack, +20% accuracy |
| Burst Fire | 3 | Multiple rounds, high ammo use |
| Grenade | 2 | Throw + detonate |
| Overwatch | 1 | Reaction fire setup |

## Combat System

- **Base Hit:** 50-95% (weapon + skill + modifiers)
- **Critical Chance:** 10% (1.5× damage multiplier)
- **Armor Reduction:** 1:1 (each point reduces damage 1)
- **Morale Effects:** Shaken (-10% accuracy), Panicked (-30% accuracy)

## Economic Systems

| Resource | Monthly | Notes |
|----------|---------|-------|
| Starting Credits | 1,000,000 | Initial capital |
| Country Funding | 500K-2M | Performance-based |
| Scientist Salary | 5,000 | Research capacity |
| Soldier Salary | 2K-5K | By rank |

## Research Costs

| Tier | RP Cost | Duration (10 Scientists) |
|------|---------|--------------------------|
| Early | 100-300 | 2-3 weeks |
| Mid | 500-1K | 4-6 weeks |
| Late | 2K-5K | 8-12 weeks |
| Breakthrough | 10K+ | 20+ weeks |

## Facility Costs

| Facility | Cost | Maintenance |
|----------|------|-------------|
| Living Quarters | 200K | 10K/month |
| Laboratory | 500K | 30K/month |
| Workshop | 400K | 25K/month |
| Hangar | 600K | 40K/month |

## Game Phases

1. **Shadow War** (Months 1-3) - Investigation, conventional warfare
2. **First Contact** (Months 4-8) - Alien technology discovered
3. **Escalation** (Months 9-20) - Alien capabilities increase
4. **Endgame** (Months 21+) - Final confrontation

## Balancing Philosophy

- **Early Game:** Learn mechanics, survive (Low-moderate difficulty)
- **Mid Game:** Base expansion, tech race (Moderate-high difficulty)
- **Late Game:** Endgame tech, final missions (High-extreme difficulty)

## Living Document

All values subject to tuning:
- AP costs: Can adjust 0.5-4 range
- Hit chances: Can adjust 40-100% range
- Armor reduction: Can adjust 0.5-2× range
- Economy: Can adjust ×0.5 to ×2.0

## Testing

- ✅ All numbers validated
- ✅ Balance spreadsheet ready
- ✅ Tuning parameters documented
- ✅ Reference tables complete

## Documentation

- Location: `docs/balance/GAME_NUMBERS.md`
- Mechanical rules: `docs/rules/MECHANICAL_DESIGN.md`
- Cross-referenced in: API, FAQ

---

**Document Version:** 1.0  
**Status:** COMPLETE - Balance Reference & Living Document
