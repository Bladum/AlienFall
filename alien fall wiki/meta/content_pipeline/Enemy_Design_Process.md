# Enemy Design Process

**Tags:** #content-creation #enemy-design #balance #ai  
**Last Updated:** September 30, 2025  
**Related:** [[README]], [[Mission_Design_Template]], [[Item_Design_Checklist]]

---

## Overview

This guide covers the complete process for designing enemy units in Alien Fall, from initial concept through balance testing and integration. Enemy design combines stat distribution, AI behavior patterns, visual design, and tactical role definition to create memorable and challenging opponents.

---

## Enemy Design Framework

### Core Design Questions

Before creating an enemy, answer these questions:

1. **What is the tactical role?**
   - Tank (high HP, draws fire)
   - DPS (high damage output)
   - Support (buffs allies, debuffs players)
   - Control (limits player actions)
   - Specialist (unique mechanic)

2. **What is the threat level?**
   - Cannon fodder (weak, numerous)
   - Standard (balanced threat)
   - Elite (strong, rare)
   - Boss (unique, mission-ending threat)

3. **What makes it memorable?**
   - Unique ability or mechanic
   - Distinctive visual design
   - Special AI behavior pattern
   - Lore/narrative significance

4. **How does it challenge the player?**
   - Forces specific counter-play
   - Punishes common strategies
   - Requires adaptation
   - Creates emergent scenarios

---

## Enemy Stat Framework

### Primary Stats

**Health (HP)**
- Cannon Fodder: 3-5 HP
- Standard: 6-10 HP
- Elite: 12-20 HP
- Boss: 25-50 HP

**Armor**
- None: 0 (vulnerable)
- Light: 1-2 (basic protection)
- Medium: 3-5 (significant defense)
- Heavy: 6-10 (tank-level)

**Damage Output**
- Low: 2-4 damage per shot
- Medium: 4-6 damage per shot
- High: 6-10 damage per shot
- Extreme: 10+ damage per shot

**Accuracy**
- Poor: 50-60%
- Average: 65-75%
- Good: 75-85%
- Excellent: 85-95%

**Action Points (AP)**
- Limited: 4-6 AP (move OR shoot)
- Standard: 8-10 AP (move AND shoot)
- High: 12-14 AP (multiple actions)
- Extreme: 16+ AP (boss-tier mobility)

**Reactions (Overwatch)**
- None: 0 (never reacts)
- Low: 1 reaction per turn
- Medium: 2 reactions per turn
- High: 3+ reactions per turn

### Secondary Stats

**Will** - Resistance to panic, mind control, morale effects (1-100)  
**Sight Range** - Tiles visible in fog of war (8-16 tiles)  
**Detection** - Stealth detection capability (0-10)  
**Mobility** - Movement type (ground, flying, aquatic)  
**Size** - Collision size (1×1, 2×2, 3×3 tiles)  

---

## Enemy Budget System

Each enemy has a point value for mission balancing:

```
Base Cost = 50 points

HP: +5 points per HP above 5
Armor: +10 points per armor point
Damage: +8 points per damage above 4
Accuracy: +2 points per 5% above 65%
AP: +5 points per 2 AP above 8
Reactions: +15 points per reaction slot
Special Abilities: +20-100 points each

Example: Sectoid
- HP: 6 (+5)
- Armor: 0 (+0)
- Damage: 4 (+0)
- Accuracy: 65% (+0)
- AP: 10 (+5)
- Reactions: 1 (+15)
- Special: Psi Panic (+40)
= 115 points total
```

---

## Enemy Design Template

### Enemy ID
`enemy_unique_id`

### Enemy Name
"Display Name"

### Enemy Type/Faction
Alien / Human Faction / Rogue AI / etc.

### Tactical Role
Tank / DPS / Support / Control / Specialist

### Threat Level
Cannon Fodder / Standard / Elite / Boss

### Design Concept
2-3 sentence description of enemy concept and what makes it unique.

---

### Stat Block
```toml
[unit]
id = "enemy_sectoid"
name = "Sectoid"
type = "alien"
tier = "standard"
point_value = 115

[stats]
health = 6
armor = 0
action_points = 10
movement_range = 8  # tiles per AP spent
reactions = 1
will = 40
sight_range = 12

[stats.offense]
weapon = "plasma_pistol"
base_damage = 4
accuracy = 65
crit_chance = 5
ammo_capacity = 8

[stats.defense]
dodge = 10  # % chance to completely avoid hit
cover_bonus = 20  # bonus when in cover

[abilities]
psi_panic = true
telepathic_link = true  # Shares sight with nearby sectoids

[ai_behavior]
primary = "cautious"  # See AI behavior patterns
preferred_range = "medium"  # 6-12 tiles
cover_seeking = true
grenade_usage = false
ability_priority = ["psi_panic", "shoot"]

[loot]
corpse = "sectoid_corpse"
weapon_drop_chance = 30
special_items = ["elerium_shard"]
special_item_chance = 15
```

---

### Abilities

**Ability 1: Psi Panic**
- **Type**: Active, single-target
- **Cost**: 6 AP
- **Range**: 10 tiles, line-of-sight not required
- **Effect**: Target must pass Will check (DC 40) or panic for 2 turns
- **Cooldown**: 2 turns
- **AI Usage**: Prioritizes high-value targets, uses when safe

**Ability 2: Telepathic Link**
- **Type**: Passive, aura
- **Cost**: None
- **Range**: 8 tiles
- **Effect**: All Sectoids within range share sight and detection
- **Cooldown**: None
- **AI Usage**: Automatically active

---

### AI Behavior Pattern

**Primary Behavior**: Cautious
- Seeks cover aggressively (80% of time)
- Avoids overwatch (will not move through it)
- Prefers medium range (6-12 tiles)
- Uses Psi Panic when target isolated or high-value

**Decision Tree**:
1. If in danger and no cover → Find cover (Priority 1)
2. If enemy in psi range and safe → Use Psi Panic (Priority 2)
3. If enemy visible in range → Shoot from cover (Priority 3)
4. If no enemy visible → Advance cautiously (Priority 4)
5. If heavily wounded → Retreat to allies (Priority 5)

**Special Conditions**:
- If Sectoid Commander present → More aggressive, less cover-seeking
- If last Sectoid alive → Attempts to flee

---

### Visual Design

**Sprite Description**:
- Gray humanoid, large head, black eyes
- Thin limbs, hunched posture
- Purple/black uniform
- Carries plasma pistol

**Animation Set**:
- Idle: Gentle head bob, scanning
- Walk: Slow, cautious movement
- Attack: Raise pistol, fire energy bolt
- Psi Attack: Eyes glow, hands to head
- Hit: Recoil, stagger
- Death: Collapse, disintegrate

**VFX**:
- Plasma shot: Purple energy bolt
- Psi attack: Purple energy waves from head
- Telepathic link: Faint purple lines between Sectoids

---

### Balance Considerations

**Strengths**:
- Psi abilities bypass cover
- Telepathic network makes them hard to ambush
- Cheap point cost allows large groups
- Medium range versatility

**Weaknesses**:
- Low HP (dies in 2-3 shots)
- No armor (full damage from all weapons)
- Low Will makes them panic-prone
- Cautious AI can be predictable

**Counter-Play**:
- High Will soldiers resist Psi Panic
- Focus fire to eliminate quickly
- Mind shields negate psi abilities
- Flanking bypasses cover

**Progression Curve**:
- Early game (Lvl 1-2): Threatening psi abilities
- Mid game (Lvl 3-5): Weak but numerous
- Late game (Lvl 6+): Cannon fodder

---

### Loot & Rewards

**Guaranteed Drops**:
- Sectoid Corpse (research material)

**Possible Drops** (30% chance):
- Plasma Pistol (damaged)

**Rare Drops** (15% chance):
- Elerium Shard (valuable resource)

**Research Unlocks**:
- Sectoid Autopsy → Psi Research path
- Plasma Pistol → Laser Weapons

---

## Enemy Types Catalog

### Alien Faction

**Sectoid** (115pts) - Psi support, early game threat  
**Floater** (150pts) - Flying mobility, medium threat  
**Muton** (250pts) - Heavy assault, late-game challenge  
**Chryssalid** (200pts) - Melee horror, creates zombies  
**Ethereal** (500pts) - Psi master, boss-tier  

### Human Enemies (Future)

**Exalt Operative** (180pts) - Stealth specialist  
**Exalt Heavy** (220pts) - Suppression support  
**Rogue Android** (300pts) - High durability, no morale  

### Special Bosses

**Sectoid Commander** (400pts) - Enhanced psi, leader buffs  
**Muton Elite** (450pts) - Elite warrior with rage mechanic  
**Uber Ethereal** (800pts) - Final boss, multiple phases  

---

## Enemy Creation Workflow

### Phase 1: Concept (1 hour)
1. Define role and threat level
2. Identify unique mechanic/ability
3. Sketch visual design
4. Write 1-page design doc
5. Get approval from lead designer

### Phase 2: Stat Design (2 hours)
1. Fill out stat block template
2. Calculate point value
3. Balance against existing enemies
4. Define ability mechanics
5. Design AI behavior pattern

### Phase 3: Implementation (3-4 hours)
1. Create TOML data file
2. Implement abilities in Lua
3. Configure AI behavior
4. Set up loot tables
5. Add to spawn pools

### Phase 4: Art Creation (4-8 hours)
1. Create 10×10 pixel sprite
2. Animate (idle, walk, attack, death)
3. Create VFX for abilities
4. Compile sprite sheet
5. Integrate into game

### Phase 5: Testing (2-4 hours)
1. Unit testing (stats, abilities work)
2. AI testing (behavior makes sense)
3. Balance testing (appropriate difficulty)
4. Integration testing (works in missions)
5. Playtest feedback

### Phase 6: Tuning (1-2 hours)
1. Adjust stats based on testing
2. Tweak AI behavior
3. Balance point value
4. Final approval
5. Add to enemy catalog

**Total Time**: 13-22 hours per enemy

---

## AI Behavior Patterns

### Aggressive
- Rushes player positions
- Ignores cover if enemy visible
- Uses grenades and explosives
- High risk, high reward

### Cautious
- Seeks cover always
- Avoids overwatch
- Prefers medium/long range
- Retreats when wounded

### Flanker
- Attempts to move around player
- Uses mobility to avoid front lines
- Attacks from unexpected angles
- Good for flying units

### Sniper
- Stays at maximum range
- Seeks elevated positions
- Never enters close range
- Relocates if flanked

### Berserker
- Pure melee focus
- Charges shortest path to enemy
- Takes damage to close distance
- No self-preservation

### Support
- Stays behind front line
- Uses buffs and healing
- Low aggression
- Protects key units

---

## Common Pitfalls

### ❌ Stat Creep
**Problem**: Each new enemy stronger than last  
**Solution**: Use point budget system, maintain balance curve

### ❌ Unfun Mechanics
**Problem**: Abilities that feel cheap or unfair  
**Solution**: Ensure counter-play exists, telegraph danger

### ❌ Homogeneous Design
**Problem**: All enemies feel samey  
**Solution**: Distinct roles, unique abilities, varied AI

### ❌ One-Dimensional
**Problem**: Enemy only good in one scenario  
**Solution**: Flexible design, multiple tactical applications

### ❌ Visual Confusion
**Problem**: Can't distinguish enemy types quickly  
**Solution**: Clear silhouettes, color coding, consistent design language

---

## Related Documentation

- [[README]] - Content pipeline overview
- [[Mission_Design_Template]] - Using enemies in missions
- [[Item_Design_Checklist]] - Weapon/equipment design
- [[../../ai/README]] - AI system architecture
- [[../../units/README]] - Unit system documentation
- [[../../../examples/lua/ai_behavior]] - AI behavior scripting example

---

**Document Status:** Complete  
**Review Date:** October 7, 2025  
**Owner:** Combat Designer
