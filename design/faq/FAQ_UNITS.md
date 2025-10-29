# FAQ: Units & Progression

> **Audience**: Experienced strategy gamers familiar with X-COM, Battle for Wesnoth, XCOM  
> **Last Updated**: 2025-10-28  
> **Related Mechanics**: [Units.md](../mechanics/Units.md), [Pilots.md](../mechanics/Pilots.md)

---

## Quick Navigation

- [Unit Classes & Roles](#unit-classes--roles)
- [Experience & Progression](#experience--progression)
- [Equipment & Restrictions](#equipment--restrictions)
- [Morale & Psychology](#morale--psychology)
- [Transformations](#transformations)
- [Pilots](#pilots)
- [Game Comparisons](#game-comparisons)

---

## Unit Classes & Roles

### Q: What's the unit class system like?

**A**: Similar to **Battle for Wesnoth** promotion trees combined with **XCOM's** class specialization.

**Key Features**:
- **7 Ranks** (0-6): Conscript → Agent → Specialist → Expert → Master → Elite → Hero
- **Branching promotions**: Each rank offers specialization choices
- **Permanent decisions**: Once you choose a path, can only change via demotion
- **Class equipment bonuses**: Units get +50% effectiveness with matching equipment

**Example progression**:
```
Rank 0: Conscript (basic unit)
    ↓
Rank 1: Agent (choose role: Soldier, Support, Scout, Specialist, Leader, Pilot)
    ↓
Rank 2: Rifleman, Medic, Ranger, Grenadier, Commander, Fighter Pilot, etc.
    ↓
Rank 3-6: Further specialization
```

---

### Q: How is this different from X-COM?

**Comparison**:

| Feature | X-COM (Original) | XCOM (2012) | AlienFall |
|---------|------------------|-------------|-----------|
| **Rank System** | None (stats only) | 7 ranks, fixed path | 7 ranks, branching |
| **Class Choice** | Recruit only | 4 classes (at rank) | 5+ roles (Rank 1) |
| **Specialization** | Equipment-based | Linear progression | Branching tree |
| **Demotion** | N/A | N/A | ✅ Possible (50% XP kept) |
| **Hero Units** | None | None | 1 per player (Rank 6) |

**What's similar**:
- Permadeath (units die permanently)
- Experience from missions
- Equipment restrictions by rank
- Stat-based combat effectiveness

**What's unique**:
- Branching promotion trees (like Wesnoth)
- Demotion system (respec without losing unit)
- Single Hero unit (extremely rare, powerful)
- Class synergy bonuses (+50% with matching gear)

---

### Q: Can I have multiple heroes?

**A**: **No** - You can only have **1 Hero unit (Rank 6)** per player at a time.

**Why?**:
- Heroes are legendary commanders with faction-wide bonuses
- Requires **243 Rank 1 units** minimum to promote one
- Represents the player's supreme commander
- Balance: Prevents hero stacking

**What happens if my hero dies?**:
- You can promote a new hero (if you meet requirements)
- Hero bonuses are lost until replacement promoted
- Hero corpses cannot be resurrected

---

## Experience & Progression

### Q: How do units gain experience?

**A**: Similar to **XCOM** but with multiple XP sources.

**XP Sources**:

| Activity | XP Gained | Notes |
|----------|-----------|-------|
| **Enemy Kills** | 5 XP per kill | Standard combat reward |
| **Damage Dealt** | 0.5 XP per 10 damage | Rewards participation |
| **Enemy Spotting** | 2 XP per unique enemy | Reconnaissance value |
| **Objectives Complete** | 10-50 XP | Mission-dependent |
| **Wounds Taken** | 1 XP per 5 damage | Rewards frontline play |
| **Mission Participation** | 10 XP | Just for showing up |

**Bonus XP**:
- **Smart trait**: +20% XP gain
- **Medals**: One-time bonuses (25-200 XP)
- **Training**: +1-3 XP per week in barracks

**Rank Thresholds**:
- Rank 1: 100 XP
- Rank 2: 300 XP (total: 400)
- Rank 3: 600 XP (total: 1,000)
- Rank 4: 1,000 XP (total: 2,000)
- Rank 5: 1,500 XP (total: 3,500)
- Rank 6: 2,100 XP (total: 5,600)

---

### Q: What are traits and how do I get them?

**A**: Traits are permanent modifiers (like **Total War** character traits).

**Trait Point System**:
- Each unit has **4 trait points** to spend
- Positive traits cost points (1-2 points)
- Negative traits refund points (1-2 points)
- Example: Fast (1) + Strong (1) + Brave (2) = 4 points used

**Common Traits**:

**Positive** (cost points):
- **Fast**: Speed +2 (1 point)
- **Strong**: Strength +2 (1 point)
- **Agile**: Action Points +1 (2 points, Rank 2+)
- **Smart**: XP Gain +20% (1 point)
- **Leader**: Morale Aura +1 (2 points, Rank 2+)

**Negative** (refund points):
- **Fragile**: Health -2 (1 point back)
- **Clumsy**: Accuracy -10% (1 point back)
- **Stupid**: XP Gain -20% (1 point back)
- **Coward**: Morale -2 (1 point back)

**Trait Rules**:
- Assigned at recruitment (cannot change without transformation)
- Some traits require specific ranks
- Contradictory traits cancel (Smart + Stupid = invalid)

---

### Q: Can I retrain units to different classes?

**A**: **Yes** - via the **Demotion** system (unique to AlienFall).

**How it works**:
1. Demote unit by 1 rank (e.g., Rank 4 → Rank 3)
2. Unit retains 50% of current XP
3. Choose new specialization path at next promotion
4. Costs 1 week in barracks (no credit cost)

**Example**:
- Rank 4 Sniper (1,000 XP) demotes to Rank 3 Specialist (600 XP retained)
- Can now choose Medic path instead of Sniper
- Promotes to Rank 4 Medic at 1,000 XP

**Strategic Use**:
- Adapt to changing needs (need more medics? Retrain snipers)
- Experiment with builds without losing veteran units
- Recover from bad specialization choices

**Limitations**:
- Cannot demote below Rank 1
- Lose half of progress (50% XP)
- Takes 1 week (unit unavailable)

---

## Equipment & Restrictions

### Q: Can any unit use any equipment?

**A**: **No** - Equipment has class and rank restrictions (like **RPG class systems**).

**Restriction Types**:

**1. Rank Requirements**:
- Tier 1 weapons: Any unit
- Tier 2 weapons: Rank 2+
- Tier 3 weapons: Rank 3+
- Advanced armor: Rank requirements vary

**2. Class Requirements**:
- Heavy weapons: Specialist class only
- Sniper rifles: Sniper specialization recommended
- Medikits: Any unit (but +50% effectiveness for Medics)

**3. Class Mismatch Penalty**:
- Using equipment from untrained class: **-30% accuracy, -1 movement**
- Example: Scout using Heavy Cannon (Specialist weapon) = severe penalties

**4. Class Synergy Bonus**:
- Using equipment matching trained class: **+50% effectiveness**
- Example: Medic using Medikit heals for 4.5 HP instead of 3 HP

---

### Q: How does inventory work?

**A**: **Resident Evil-style** weight capacity system.

**Capacity Rules**:
- Each unit has **Strength stat** (6-12)
- Carry capacity = Strength value
- Each item has weight (1-3 units typical)
- **Binary system**: Either can carry all or none (no partial equipping)

**Equipment Slots**:
1. **Primary Weapon** (1 slot)
2. **Secondary Weapon** (1 slot)
3. **Armor** (1 slot)

**Example**:
- Strength 8 unit can carry:
  - Rifle (2 weight) + Pistol (1 weight) + Combat Armor (3 weight) + 2x Grenades (1 weight each) = 8 weight ✅
  - Heavy Cannon (4 weight) + Heavy Armor (5 weight) = 9 weight ❌ Overencumbered

**Overflow Penalty**: +5% maintenance cost per overflow unit

---

## Morale & Psychology

### Q: How does morale work?

**A**: Two-system approach: **Morale** (in-battle) + **Sanity** (long-term).

### Morale System (In-Battle)

**Similar to**: Total War morale system

**Mechanics**:
- **Starting Morale** = Bravery stat (6-12 range)
- **Degrades** during battle from stress
- **Recovers** via Rest action or Leader rally

**Morale Effects**:

| Morale | Status | AP Penalty | Accuracy Penalty | Behavior |
|--------|--------|------------|------------------|----------|
| **6-12** | Confident | 0 | 0% | Normal |
| **3-5** | Stressed | 0 | -10% | Minor penalty |
| **2** | Shaken | -1 AP | -15% | Impaired |
| **1** | Panicking | -2 AP | -25% | Severe |
| **0** | **PANIC** | All AP lost | -50% | Cannot act |

**Morale Loss Events**:
- Ally killed (visible): -1 to -4
- Taking damage: -1
- Flanked by enemies: -1 per turn
- Leader killed: -2 to -4
- Night mission: -1 (starts with penalty)

**Recovery**:
- **Rest action** (2 AP): +1 morale
- **Leader rally** (4 AP): +2 morale to target
- **Leader aura**: +1 morale per turn (passive, 8 hex radius)

---

### Sanity System (Long-Term)

**Similar to**: Darkest Dungeon sanity mechanics

**Mechanics**:
- **Range**: 6-12 (separate from morale)
- **Persists** between missions (doesn't reset)
- **Drops AFTER mission** based on trauma
- **Recovers slowly** (weeks, not turns)

**Sanity Loss** (Post-Mission):
- Standard mission: 0
- Moderate stress: -1
- Hard mission: -2
- Horror mission: -3
- **Additional**: Night missions (-1), Ally deaths (-1 each), Mission failure (-2)

**Sanity Recovery**:
- Base: +1 per week
- Temple facility: +2 per week
- Medical treatment: +3 immediate (10,000 credits)
- Leave/vacation: +5 over 2 weeks (5,000 credits)

**Low Sanity Effects**:
- 5-6 sanity: -10% accuracy, -1 morale at mission start
- 3-4 sanity: -15% accuracy, -2 morale
- 0 sanity: **BROKEN** - cannot deploy

**Strategic Implications**:
- **Rotate units** between missions (sanity recovery time)
- **Build Temple** early (doubles recovery rate)
- **Track sanity** to avoid breakdowns
- **Plan roster** for 2-3x squad size (rotation pool)

---

### Q: What happens when a unit panics?

**A**: **Panic = morale 0** → Unit loses all AP and cannot act.

**Panic Triggers**:
- Morale drops to 0 from stress
- Sanity 0 (broken state)
- Special attacks (psionic fear, terror weapons)

**Panic Effects**:
- Unit has **0 AP available** (cannot move, shoot, or use items)
- Accuracy -50% (if somehow forced to act)
- May drop weapon or flee (AI-controlled behavior)

**Recovery from Panic**:
- Leader rally (4 AP from another unit): +2 morale → recovers if above 0
- End of turn: Check if morale recovered naturally
- Mission end: Morale resets to Bravery stat

**Comparison**:
- **X-COM (1994)**: Panic causes berserk or flee behavior
- **XCOM 2**: Panic causes uncontrolled actions
- **AlienFall**: Panic = complete incapacitation (0 AP)

---

## Transformations

### Q: What are transformations?

**A**: **Permanent surgical/biological modifications** (like Deus Ex augmentations).

**Key Rules**:
- Each unit can undergo **exactly ONE** transformation
- Transformations are **permanent and irreversible**
- Require high-level research + expensive cost
- Modify stats or unlock new abilities

---

### Q: What transformation types exist?

**A**: Two categories: **Biological** and **Mechanical**

**Biological Transformations**:
- **Combat Augmentation** (5,000 credits): Speed +2, Aim +2
- **Psionic Awakening** (8,000 credits): Psi +5, Sanity -2, enables psi abilities
- **Berserker Protocol** (6,000 credits): Strength +3, Health +3, Aim -1 (melee focus)
- **Enhanced Perception** (7,000 credits): Sight +3, Sense +2, Speed +1 (scout)
- **Regeneration** (10,000 credits): Health Regen +2/turn in battle

**Mechanical Transformations**:
- **Cyborg Framework** (8,000 credits): Strength +2, Speed +1, Armor +2 (hybrid)
- **Full Mechanization** (15,000 credits): Health +5, Armor +5, Immune to morale (robot)
- **Targeting System** (6,000 credits): Accuracy +15%, Aim +2
- **Kinetic Absorption** (7,000 credits): Kinetic Resistance +30%, Speed -1

**Strategic Decisions**:
- Choose transformations based on unit role
- Biological = retain humanity (morale/sanity still apply)
- Mechanical = lose psychology (immune to panic, but also no morale bonuses)
- Cannot undo (unit is permanently modified)

---

### Q: Can transformed units be resurrected?

**A**: **No** - Transformed units cannot be cloned or resurrected.

**Why**:
- Transformation data is unique and cannot be replicated
- Resurrection protocol works only on baseline biological units
- Transformed corpses provide no salvage value

**Implications**:
- Transformations increase unit value but also risk
- Veteran transformed units are irreplaceable
- Consider transformation timing carefully (early vs. late career)

---

## Pilots

### Q: How do pilots work?

**A**: Pilots are **specialized units** that can operate craft in addition to ground combat.

**Key Principle**: All units have a **Piloting stat** (0-100), but only Pilot class specialists can operate craft effectively.

**Pilot Class Progression**:
```
Rank 0: Conscript
    ↓
Rank 1: Pilot (basic craft operation)
    ↓
Rank 2: Fighter Pilot, Bomber Pilot, Transport Pilot, Scout Pilot
    ↓
Rank 3: Ace Fighter, Strategic Bomber, Master Transport, Recon Expert
    ↓
Rank 4: Squadron Commander (can command multiple craft)
```

**Piloting Stat**:
- Default: 20-40 (untrained units)
- Improves through: Interception missions (+2-5 per mission), Academy training (+5 per month)
- Pilot class specialists gain +10 per rank

**Craft Requirements**:
- **Minimum Piloting 30**: Any unit can attempt basic flight
- **Piloting 50+**: Pilot class recommended (effective operation)
- **Piloting 70+**: Ace Pilot specialization (expert)
- **Piloting 90+**: Squadron Commander (master)

**Dual Role**:
- Pilots can deploy to ground combat when not flying
- Cannot pilot craft AND deploy to battlescape simultaneously
- Must choose per mission: fly OR fight on ground

**For full details**: See [Units.md §Unified Pilot Specification](../mechanics/Units.md#unified-pilot-specification)

---

## Game Comparisons

### Q: How similar is this to X-COM/XCOM?

**Similarity Matrix**:

| Feature | X-COM (1994) | XCOM 2 (2016) | AlienFall | Notes |
|---------|--------------|---------------|-----------|-------|
| **Permadeath** | ✅ Yes | ✅ Yes | ✅ Yes | Units die permanently |
| **Rank System** | ❌ None | ✅ 7 ranks | ✅ 7 ranks | |
| **Class Specialization** | ❌ Equipment-based | ✅ 4 classes | ✅ 5+ roles | Branching in AlienFall |
| **Experience Gain** | ❌ Missions only | ✅ Missions | ✅ Multiple sources | Also training, medals |
| **Morale System** | ✅ Yes | ✅ Simplified | ✅ Complex | Two-system (morale + sanity) |
| **Unit Customization** | ❌ Minimal | ✅ Extensive | ✅ Very extensive | Traits + transformations |
| **Demotion/Respec** | ❌ No | ❌ No | ✅ Yes | Unique feature |
| **Hero Units** | ❌ No | ❌ No | ✅ 1 max | Rank 6 legendary |

**Biggest Differences**:
1. **Branching Promotions**: AlienFall uses Battle for Wesnoth-style promotion trees
2. **Demotion System**: Can respec units without losing them entirely
3. **Sanity System**: Long-term psychological consequences (Darkest Dungeon-inspired)
4. **Hero Units**: Single legendary commander (unique mechanic)
5. **Trait System**: 4-point trait system for deep customization

---

### Q: Is this similar to Battle for Wesnoth?

**A**: **Yes** - The promotion system is heavily inspired by Wesnoth.

**Similarities**:
- ✅ Branching promotion trees (multiple paths per rank)
- ✅ Permanent class choices (cannot switch without cost)
- ✅ Experience-based progression
- ✅ Unit rarity (Hero units = legendary)

**Differences**:
- ❌ Wesnoth has no equipment system (AlienFall does)
- ❌ Wesnoth promotions are automatic (AlienFall requires player choice)
- ❌ Wesnoth has no sanity/morale (AlienFall has both)
- ✅ AlienFall adds demotion (Wesnoth doesn't have this)

**If you liked Wesnoth promotions, you'll love AlienFall's system.**

---

## Related Content

**For detailed information, see**:
- **[Units.md](../mechanics/Units.md)** - Complete unit system specification
- **[Pilots.md](../mechanics/Pilots.md)** - Pilot specialization details
- **[MoraleBraverySanity.md](../mechanics/MoraleBraverySanity.md)** - Psychological systems
- **[Items.md](../mechanics/Items.md)** - Equipment specifications
- **[Economy.md](../mechanics/Economy.md)** - Training and recruitment costs

---

## Quick Reference

**Unit Ranks**: 0 (Conscript) → 6 (Hero)  
**Max Heroes**: 1 per player  
**Trait Points**: 4 per unit  
**Morale Range**: 0-12 (0 = panic)  
**Sanity Range**: 6-12 (0 = broken)  
**Transformations**: 1 per unit, permanent  
**Demotion**: 50% XP retained, 1 week retraining  
**Piloting Stat**: 0-100 (30 minimum for flight)

