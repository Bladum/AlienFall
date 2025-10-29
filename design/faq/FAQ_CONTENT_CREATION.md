# FAQ: Content Creation

> **Audience**: Modders creating balanced game content  
> **Last Updated**: 2025-10-28  
> **Related Docs**: [GAME_API.toml](../../api/GAME_API.toml), [Economy.md](../mechanics/Economy.md), [Units.md](../mechanics/Units.md)

---

## Quick Navigation

- [Creating Units](#creating-units)
- [Creating Weapons](#creating-weapons)
- [Creating Facilities](#creating-facilities)
- [Balance Guidelines](#balance-guidelines)
- [Mission Design](#mission-design)
- [Playtesting](#playtesting)

---

## Creating Units

### Q: How do I balance a new unit?

**A**: **Follow stat guidelines** based on unit role.

**Stat Ranges by Role**:

| Role | Health | Accuracy | Strength | Speed | Cost |
|------|--------|----------|----------|-------|------|
| **Scout** | 12-16 | 65-75% | 6-8 | 2 | 15-25K |
| **Soldier** | 16-20 | 70-80% | 8-10 | 1 | 20-30K |
| **Sniper** | 14-18 | 80-90% | 6-8 | 1 | 30-40K |
| **Heavy** | 18-24 | 60-70% | 10-12 | 1 | 35-45K |
| **Medic** | 14-18 | 65-75% | 7-9 | 1 | 25-35K |
| **Leader** | 16-20 | 75-85% | 8-10 | 1 | 40-60K |

**Balance Principle**: Higher combat stats = Higher cost

---

### Q: What makes a unit overpowered?

**A**: **Multiple strong stats** without trade-offs.

**Overpowered Signs**:
- ❌ High health + High accuracy (no weakness)
- ❌ High damage + High speed (too mobile)
- ❌ Low cost + Elite stats (imbalanced economy)
- ❌ Special abilities + No cooldowns (spam potential)

**Balanced Approach**:
- ✅ High accuracy → Low health (glass cannon)
- ✅ High speed → Low damage (scout)
- ✅ High health → Low accuracy (tank)
- ✅ Special abilities → High cooldowns (strategic use)

---

## Creating Weapons

### Q: How do I balance weapon damage?

**A**: **Damage-per-AP formula** with range consideration.

**Target DPA by Tier**:
- Tier 1 (Conventional): 8-10 DPA
- Tier 2 (Advanced): 12-15 DPA
- Tier 3 (Alien Tech): 18-22 DPA
- Tier 4 (Ultimate): 25-30 DPA

**Balancing Factors**:
- Higher DPA → Lower accuracy OR shorter range
- Area damage → Reduce DPA by 30%
- Special effects (stun, fire) → Reduce base damage 20%

---

## Creating Facilities

### Q: How do I design a balanced facility?

**A**: **Cost vs Benefit analysis**.

**Cost Formula**:
```
Build Cost = Base Cost × Grid Size × Power Level
Maintenance = Build Cost / 50 per month
```

**Power Levels**:
- Essential (Power, Storage): 1.0x
- Production (Workshop, Lab): 1.5x
- Combat (Hangar, Defense): 2.0x
- Ultimate (Special): 3.0x+

---

## Balance Guidelines

### Q: How do I test if content is balanced?

**A**: **Autonomous playtesting** (AI vs AI simulations).

**Balance Targets**:
- **Units**: 45-55% survival rate
- **Weapons**: 45-55% win rate when used
- **Facilities**: Used in 40-60% of bases

---

## Mission Design

### Q: How do I create a custom mission?

**A**: **Define objectives, enemies, rewards** in TOML.

**Difficulty Tiers**:
- Easy: 4-6 units, Rank 0-1, No reinforcements
- Medium: 6-8 units, Rank 1-2, 1 wave
- Hard: 8-10 units, Rank 2-3, 2 waves
- Very Hard: 10-12 units, Rank 3-4, 3 waves

---

## Playtesting

### Q: How do I playtest my mod?

**A**: **Manual testing + Autonomous AI testing**.

**Testing Checklist**:
- ✅ Unit stats display correctly
- ✅ Weapon damage feels balanced
- ✅ Facility cost reasonable
- ✅ Mission difficulty appropriate

---

## Related Content

**For detailed information, see**:
- **[GAME_API.toml](../../api/GAME_API.toml)** - Data structure reference
- **[Economy.md](../mechanics/Economy.md)** - Economic balance
- **[Units.md](../mechanics/Units.md)** - Unit stat guidelines
- **[Items.md](../mechanics/Items.md)** - Weapon specifications

---

## Quick Reference

**Unit Cost Formula**: 10,000 + (stat_value × multipliers) + bonuses  
**Weapon DPA Target**: Tier 1 (8-10), Tier 2 (12-15), Tier 3 (18-22)  
**Balanced Win Rate**: 45-55% (50% ideal)  
**Monthly Surplus**: 25% of income  
**Playtesting**: 1000+ simulations for reliable data

