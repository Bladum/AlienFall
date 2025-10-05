# Tactical Combat Basics

**Tags:** `#tutorial` `#player-guide` `#combat` `#tactics` `#battlescape`  
**Related:** [[First_Mission_Walkthrough]], [[QuickStart_Guide]], [[Intermediate_Strategies]]  
**Audience:** New Players  
**Reading Time:** 18 minutes

---

## Overview

Master the fundamentals of tactical combat in Alien Fall. This comprehensive guide covers combat mechanics, positioning strategies, action economy, and winning tactics to dominate the battlescape.

**What You'll Learn:**
- Combat action system and AP management
- Cover mechanics and positioning
- Weapon systems and effective range
- Flanking, overwatch, and advanced tactics
- Enemy behavior patterns

---

## Combat Fundamentals

### Action Points (AP) System

Every combat action costs Action Points:

```
ACTION POINT COSTS
═══════════════════════════════════════════
Action              | AP Cost | Details
────────────────────┼─────────┼───────────
Move (1 tile)       | 1 AP    | Walk
Dash (2 tiles)      | 2 AP    | Run
Shoot Primary       | 4 AP    | Attack
Shoot Secondary     | 3 AP    | Pistol
Reload              | 2 AP    | Refill ammo
Throw Grenade       | 4 AP    | AoE damage
Use Item            | 2-4 AP  | Medkit, etc.
Crouch/Stand        | 1 AP    | Stance change
Overwatch           | 4 AP    | Reaction fire
Hunker Down         | 2 AP    | +40 defense
═══════════════════════════════════════════
```

**Starting AP:** 12 per turn (all soldiers)  
**AP Regeneration:** Full 12 AP every turn  
**Negative AP:** Cannot perform actions

### AP Management Strategy

**Efficient Turn Examples:**

```
EXAMPLE 1: Aggressive Advance
─────────────────────────────────────
Move 4 tiles        → 4 AP spent (8 remaining)
Shoot enemy         → 4 AP spent (4 remaining)
Take cover          → 1 AP spent (3 remaining)
Overwatch (can't - need 4 AP!)
─────────────────────────────────────
Result: Aggressive but no reaction fire

EXAMPLE 2: Conservative Play
─────────────────────────────────────
Move 3 tiles        → 3 AP spent (9 remaining)
Crouch              → 1 AP spent (8 remaining)
Shoot enemy         → 4 AP spent (4 remaining)
Overwatch           → 4 AP spent (0 remaining)
─────────────────────────────────────
Result: Covered and protected

EXAMPLE 3: Overwatch Trap
─────────────────────────────────────
Move 2 tiles        → 2 AP spent (10 remaining)
Reload              → 2 AP spent (8 remaining)
Overwatch           → 4 AP spent (4 remaining)
Reserve AP          → 4 AP saved
─────────────────────────────────────
Result: Reaction fire + safety margin
```

**Golden Rules:**
1. Always save 4 AP for shooting
2. Reserve AP for overwatch if possible
3. Plan full turn before first action
4. Movement = most expensive action over time

---

## Cover System

### Cover Types

```
COVER MECHANICS
═══════════════════════════════════════════

🛡️ HALF COVER (+20 Defense)
────────────────────────────────────
• Low walls
• Crates/boxes  
• Car doors
• Windows
• Small debris

Hit Chance: Base -20%


🛡️🛡️ FULL COVER (+40 Defense)
────────────────────────────────────
• High walls
• Thick trees
• Vehicles
• Buildings
• Large structures

Hit Chance: Base -40%


❌ NO COVER (0 Defense)
────────────────────────────────────
• Open ground
• Middle of room
• Exposed positions

Hit Chance: Base +0% (DANGER!)
```

### Cover Rules

**Cover Direction:**
- Cover only protects from the direction you're facing
- Flanked shots ignore cover bonuses
- Rear shots ignore cover completely

```
        Enemy 1 (Front)
            ↓
    [■] ← Soldier in full cover
            ↑
        Enemy 2 (Rear)

Enemy 1 shot: -40% hit (full cover)
Enemy 2 shot: +30% hit (flanked + no cover!)
```

**Cover Destruction:**
- Explosives destroy cover
- Some weapons damage cover over time
- Cover can collapse during mission

### Effective Cover Usage

**DO's ✓**
```
✓ End every turn in cover
✓ Face toward known threats
✓ Use full cover when available
✓ Check cover from all angles
✓ Crouch in half cover (+10 bonus)
```

**DON'Ts ❌**
```
❌ Stand in open ground
❌ Face away from enemies
❌ Rely on destroyed cover
❌ Cluster soldiers in same cover
❌ Ignore flanking routes
```

---

## Weapon Systems

### Weapon Categories

```
ASSAULT RIFLE
─────────────────────────────────────
Damage: 3-5
Range: 15 tiles (optimal: 5-10)
Accuracy: 65% base
Ammo: 30 rounds
Reload: 2 AP

Best For:
• Balanced combat
• Mid-range engagements
• Reliable damage
• All-purpose weapon
```

```
SHOTGUN
─────────────────────────────────────
Damage: 5-8
Range: 8 tiles (optimal: 1-4)
Accuracy: 50% base, +30% close range
Ammo: 6 rounds
Reload: 2 AP

Best For:
• Close quarters combat
• High damage burst
• Flanking attacks
• Assault class soldiers
```

```
SNIPER RIFLE
─────────────────────────────────────
Damage: 6-9
Range: 25 tiles (optimal: 15-25)
Accuracy: 70% base
Ammo: 5 rounds
Reload: 3 AP

Best For:
• Long-range elimination
• High-value targets
• Overwatch positions
• Sniper class soldiers
```

```
LMG (Light Machine Gun)
─────────────────────────────────────
Damage: 4-6
Range: 18 tiles (optimal: 8-15)
Accuracy: 60% base
Ammo: 50 rounds
Reload: 3 AP

Best For:
• Suppression
• Sustained fire
• Area denial
• Heavy class soldiers
```

### Weapon Effectiveness by Range

```
RANGE EFFECTIVENESS TABLE
═══════════════════════════════════════════
Range    | Shotgun | AR  | LMG | Sniper
─────────┼─────────┼─────┼─────┼────────
0-5      | ★★★★★   | ★★★ | ★★  | ★
6-10     | ★★      | ★★★★| ★★★ | ★★
11-15    | ★       | ★★★ | ★★★★| ★★★★
16-20    | -       | ★★  | ★★★ | ★★★★★
21-25    | -       | ★   | ★★  | ★★★★★
═══════════════════════════════════════════
```

---

## Hit Chance Mechanics

### Hit Chance Formula

```
Hit Chance = Soldier Aim + Modifiers - Enemy Defense

Base Soldier Aim:
• Rookie: 65%
• Squaddie: 70%
• Corporal: 75%
• Sergeant: 80%
• Lieutenant: 85%
• Captain: 90%

Positive Modifiers:
+ Height advantage: +20%
+ Flanking shot: +30%
+ Point-blank range (<3 tiles): +20%
+ Scoped weapon: +10%
+ Laser sight: +5%

Negative Modifiers:
- Half cover: -20%
- Full cover: -40%
- Long range: -5% per 5 tiles
- Darkness: -10%
- Smoke: -20%
```

### Hit Chance Examples

```
SCENARIO 1: Long Range Shot
─────────────────────────────────────
Soldier Aim: 65% (Rookie)
Range: 20 tiles (-20%)
Enemy in full cover (-40%)
─────────────────────────────────────
Hit Chance: 65% - 20% - 40% = 5%
Recommendation: Don't take this shot!


SCENARIO 2: Optimal Shot
─────────────────────────────────────
Soldier Aim: 75% (Corporal)
Range: 8 tiles (0%)
Height advantage (+20%)
Enemy in half cover (-20%)
─────────────────────────────────────
Hit Chance: 75% + 20% - 20% = 75%
Recommendation: Good shot, take it!


SCENARIO 3: Flanking Shot
─────────────────────────────────────
Soldier Aim: 70% (Squaddie)
Range: 5 tiles (+10% optimal)
Flanking (+30%)
No cover (0%)
─────────────────────────────────────
Hit Chance: 70% + 10% + 30% = 110% → 95% max
Recommendation: Excellent shot!
```

---

## Tactical Positioning

### The Three Principles

**1. Cover Discipline**
```
ALWAYS be in cover when turn ends
Exception: Moving to better position

Bad:  [S] ← Soldier in open
         ↓ Enemy shoots: 85% hit!

Good: [S]■ ← Soldier in full cover
          ↓ Enemy shoots: 45% hit!
```

**2. Spacing**
```
DON'T cluster soldiers (grenade risk)

Bad:  [S][S][S] ← 3 soldiers adjacent
         ↓ Grenade hits all 3!

Good: [S]  [S]  [S] ← Soldiers spread
          ↓ Grenade hits only 1
```

**3. Crossfire**
```
Position soldiers to flank enemies

    [S]
     ↓
[E] ← Enemy ← [S]
     
Both soldiers have flanking shot!
Enemy must choose which to face
```

### Advanced Positioning Tactics

**The L-Shape Formation:**
```
Before Contact:
[S]
[S]
[S][S] ← Turns corner

After Contact (enemies spotted):
[S]     [E][E] ← Enemies
[S] ↗  
[S][S] ← Flanking from two sides
```

**The Overwatch Corridor:**
```
Narrow hallway control:

[S] Overwatch
    ↓
    ║
    ║ ← Kill zone
    ║
[S] Overwatch

Any enemy entering = multiple reaction shots
```

**Height Advantage:**
```
Upper Floor:    [S] +20% aim bonus
                 ↓
Ground Floor:   [E] Cannot see soldier
                
Always take high ground!
```

---

## Action Economy

### Understanding Action Economy

**Definition:** Action economy = total actions per turn

```
YOUR TEAM (4 soldiers × 12 AP each)
─────────────────────────────────────
Total: 48 AP per turn
Actions: ~12 actions per turn (4 AP avg)

ENEMY TEAM (6 aliens × 12 AP each)
─────────────────────────────────────
Total: 72 AP per turn
Actions: ~18 actions per turn

You are OUTNUMBERED in action economy!
Must fight smarter, not harder!
```

### Improving Action Economy

**1. Kill Enemies (Reduce Their Actions)**
```
Turn 1: Kill 2 enemies
Enemy Team: 6 → 4 aliens
Enemy Actions: 18 → 12 per turn

Result: Now only 1.5:1 disadvantage vs 2:1!
```

**2. Overwatch (Get Extra Actions)**
```
Your Turn: Move + Overwatch (4 soldiers)
Enemy Turn: 1 alien moves
Result: 4 reaction shots (FREE actions!)

Effect: +4 actions during enemy turn
```

**3. Suppress Enemies (Deny Their Actions)**
```
Heavy suppresses alien:
Alien penalties: -30% aim, cannot overwatch
Effect: Alien wastes turn moving/missing
```

**4. Focus Fire (Maximize Efficiency)**
```
INEFFICIENT:
4 soldiers spread damage to 4 enemies
Result: 4 wounded enemies, all still shooting

EFFICIENT:
4 soldiers focus fire 2 enemies
Result: 2 dead enemies, 2 untouched
Effect: -2 enemy actions per turn
```

---

## Overwatch Mechanics

### How Overwatch Works

```
OVERWATCH SEQUENCE
═══════════════════════════════════════

1. Soldier uses Overwatch action (4 AP)
2. Blue cone shows firing arc
3. Turn ends, overwatch active
4. Enemy turn begins
5. Enemy moves in overwatch cone
6. Soldier auto-fires (reaction shot)
7. Overwatch expires
```

**Overwatch Properties:**
- Fires at FIRST enemy entering cone
- Only one shot per overwatch
- -20% aim penalty (reaction shot)
- Triggers on movement, not shooting
- Can miss (normal hit chance applies)

### Effective Overwatch Usage

**When to Overwatch:**
```
✓ Covering doorways/corridors
✓ Last soldier with 4+ AP remaining
✓ Defensive positions
✓ Expecting enemy reinforcements
✓ Protecting flanks
```

**When NOT to Overwatch:**
```
❌ Low-aim soldiers (will miss)
❌ No enemies visible
❌ Better to shoot now
❌ Need to reload
❌ Out of good position
```

### Overwatch Traps

**The Doorway Trap:**
```
Setup:
 ┌──┐
 │  │
 │ [S][S] ← Both on overwatch
 │  ║
 └──┘
    ↓
    Enemy comes through door
    
Result: 2 reaction shots on entry!
```

**The Cross-Overwatch:**
```
[S] Overwatch ↘
              [E] ← Enemy position
[S] Overwatch ↗

Any movement: Hit from 2 angles!
```

---

## Enemy Engagement Tactics

### Target Priority System

**Always shoot in this order:**

```
PRIORITY 1: Immediate Threats
─────────────────────────────────────
• Enemies in flanking position
• Enemies about to grenade you
• Wounded enemies (1 shot = kill)
• High-damage enemies (Mutons, etc.)

PRIORITY 2: Tactical Threats  
─────────────────────────────────────
• Enemies in good cover
• Enemies with powerful weapons
• Support enemies (medics, leaders)
• Enemies near objectives

PRIORITY 3: Low Threats
─────────────────────────────────────
• Distant enemies
• Enemies behind full cover
• Weak enemy types (Sectoids)
• Disoriented/suppressed enemies
```

### Focus Fire Doctrine

**ALWAYS focus fire on single targets:**

```
SCENARIO: 3 visible enemies

WRONG (Spread Damage):
─────────────────────────────────────
Soldier 1 → Enemy A (3 damage)
Soldier 2 → Enemy B (4 damage)
Soldier 3 → Enemy C (5 damage)
Soldier 4 → Enemy A (2 damage)

Result:
Enemy A: 5 damage (wounded, still alive)
Enemy B: 4 damage (wounded, still alive)
Enemy C: 5 damage (wounded, still alive)

Next turn: All 3 enemies shoot back!


CORRECT (Focus Fire):
─────────────────────────────────────
Soldier 1 → Enemy A (3 damage)
Soldier 2 → Enemy A (4 damage) ✓ KILL
Soldier 3 → Enemy B (5 damage)
Soldier 4 → Enemy B (3 damage) ✓ KILL

Result:
Enemy A: DEAD
Enemy B: DEAD
Enemy C: Untouched

Next turn: Only 1 enemy shoots back!
```

**Focus Fire Benefits:**
- Reduces enemy action economy
- Prevents damage spread
- Guarantees kills vs chance to wound
- Simplifies decision-making

---

## Grenade Tactics

### Grenade Types

```
FRAG GRENADE
─────────────────────────────────────
Damage: 3-6 to all in radius
Radius: 3×3 tiles
Range: 10 tiles
Cost: 4 AP to throw

Best For:
• Grouped enemies (2+)
• Destroying cover
• Guaranteed damage
• Emergency situations
```

```
SMOKE GRENADE
─────────────────────────────────────
Effect: -20% enemy aim
Radius: 5×5 tiles
Duration: 2 turns
Cost: 4 AP to throw

Best For:
• Protecting wounded soldiers
• Breaking enemy overwatch
• Covering advances
• Defensive maneuvers
```

```
FLASHBANG
─────────────────────────────────────
Effect: -30% aim, cannot special abilities
Radius: 3×3 tiles
Duration: 1 turn
Cost: 4 AP to throw

Best For:
• Disabling dangerous enemies
• Interrupting alien abilities
• Emergency crowd control
```

### Grenade Tactics

**When to Use Grenades:**
```
✓ 2+ enemies clustered
✓ Enemies behind heavy cover (destroy it!)
✓ Guaranteed kill on low-HP enemy
✓ Prevent enemy turn (flashbang)
✓ Cover retreat (smoke)
```

**When NOT to Use Grenades:**
```
❌ Single enemy
❌ Mission loot in blast radius
❌ Friendlies nearby
❌ Low damage alternative to shooting
❌ "Just because you have it"
```

**Grenade Math:**
```
Frag grenade vs 3 enemies:

Option A: Shoot 1 enemy (65% × 5 damage = 3.25 expected)
Option B: Grenade 3 enemies (100% × 4 damage × 3 = 12 total!)

Grenade delivers 3.7× more expected damage!
```

---

## Common Tactical Mistakes

### Mistake 1: Moving Before Scouting ❌

```
WRONG:
Turn 1: Rush forward 8 tiles
Result: Trigger 3 enemy groups!

CORRECT:
Turn 1: Move 3 tiles, overwatch
Turn 2: Cautiously advance
Result: Engage 1 group at a time
```

### Mistake 2: Reloading Prematurely ❌

```
WRONG:
Ammo: 25/30 rounds
Action: Reload (2 AP wasted)
Result: Miss shooting opportunity

CORRECT:
Ammo: 25/30 rounds  
Action: Shoot enemy (still 21 rounds left)
Reload: Only when <10 rounds or no targets
```

### Mistake 3: Leaving Soldiers Exposed ❌

```
WRONG:
Move soldier to shoot
End turn in open ground
Result: Enemy free shots (85% hit!)

CORRECT:
Move soldier to covered position
Shoot from cover
End turn protected
```

### Mistake 4: Ignoring Flanks ❌

```
WRONG:
All soldiers advance on front
Aliens flank from side
Result: Cover useless, flanked shots!

CORRECT:
2 soldiers watch flanks
4 soldiers advance
Result: Protected from surprises
```

### Mistake 5: Wasting Overwatch ❌

```
WRONG:
All 4 soldiers overwatch
No enemies visible
Result: 16 AP wasted

CORRECT:
2 soldiers advance/shoot
2 soldiers overwatch (support)
Result: Balanced aggression + protection
```

---

## Advanced Combat Techniques

### The "Swedish Drink" Breach

**Clearing rooms efficiently:**

```
SETUP:
        ┌─────────┐
        │ [E][E]  │ ← Room with enemies
        │ [E]     │
        └─────┬───┘
              │ ← Door
        [S][S]
        [S][S] ← Stack outside
        
EXECUTION:
1. Soldier 1: Throw flashbang inside
2. Soldier 2: Enter, shoot left enemy
3. Soldier 3: Enter, shoot right enemy
4. Soldier 4: Overwatch door (cover exit)

Result: 2 kills, enemies disoriented, exit covered
```

### Suppression Tactics

```
SUPPRESSION MECHANICS
─────────────────────────────────────
Heavy with LMG suppresses enemy:
Enemy penalties:
• -30% aim
• Cannot use abilities
• -2 AP if tries to move

Effect: Enemy neutralized for 1 turn!
```

**Suppression Combos:**
```
Turn Setup:
1. Heavy suppresses Enemy A
2. Sniper shoots Enemy A (safe, A can't shoot back)
3. Assault flanks Enemy A
4. Enemy A suppressed, exposed, about to die

Next Turn:
Enemy A: Suppressed, hesitates
Your Turn: Free kill!
```

### Bait and Switch

```
BAIT TACTIC
─────────────────────────────────────
1. Weak soldier moves into open (BAIT)
2. Aliens shoot bait (likely miss or weak hit)
3. 3 soldiers on overwatch trigger
4. Aliens die in crossfire

Risk: Bait might die
Reward: Multiple reaction shots
```

---

## Enemy Behavior Patterns

### Alien AI Patterns

**Sectoids (Weak):**
- Prefer cover
- Will take snap shots
- Use psionics if available
- Flee when alone

**Floaters (Mobile):**
- Use height advantage
- Flank when possible
- Aggressive closing
- Less cover-dependent

**Mutons (Aggressive):**
- Advance steadily
- Suppress soldiers
- Tank damage
- Rarely retreat

**Chrysalids (Melee):**
- Rush forward
- Ignore cover
- Close distance ASAP
- Deadly at close range

### Countering Each Enemy Type

**vs Sectoids:**
```
Strategy: Aggressive push
Tactic: Focus fire, rapid elimination
Threat: Low (weak)
Priority: Low (kill last if others present)
```

**vs Floaters:**
```
Strategy: Overwatch traps
Tactic: Cover vertical angles
Threat: Medium (mobility)
Priority: Medium (prevent flanks)
```

**vs Mutons:**
```
Strategy: Heavy weapons, grenades
Tactic: Destroy cover, focus fire
Threat: High (damage + armor)
Priority: High (kill first)
```

**vs Chrysalids:**
```
Strategy: Keep distance, overwatch
Tactic: Shoot advancing enemies
Threat: Extreme (instant kill potential)
Priority: CRITICAL (kill on sight)
```

---

## Combat Checklist

### Pre-Mission:
- [ ] All soldiers equipped with primary weapon
- [ ] All soldiers have backup pistol
- [ ] At least 2 grenades in squad
- [ ] At least 1 medkit available
- [ ] Armor equipped on all soldiers

### Turn Start:
- [ ] Check all visible enemies
- [ ] Identify highest-threat targets
- [ ] Plan movement for all soldiers
- [ ] Reserve AP for reactions
- [ ] Check ammo counts

### Turn End:
- [ ] All soldiers in cover
- [ ] Soldiers facing enemies
- [ ] At least 1 soldier on overwatch
- [ ] No soldiers exposed/flanked
- [ ] Ready for enemy turn

### After Combat:
- [ ] Collect mission loot
- [ ] Check soldier HP
- [ ] Use medkits if needed
- [ ] Reload all weapons
- [ ] Prepare for next encounter

---

## Quick Reference Tables

### Damage by Weapon Type

| Weapon        | Min | Max | Avg | Shots/Turn |
|---------------|-----|-----|-----|------------|
| Pistol        | 2   | 3   | 2.5 | 3-4        |
| Shotgun       | 5   | 8   | 6.5 | 2          |
| Assault Rifle | 3   | 5   | 4.0 | 3          |
| Sniper Rifle  | 6   | 9   | 7.5 | 1-2        |
| LMG           | 4   | 6   | 5.0 | 3          |
| Plasma Rifle  | 5   | 8   | 6.5 | 3          |

### Tactical Formulas

```
Expected Damage = Hit Chance × Average Damage

Example:
65% hit × 4 damage = 2.6 expected damage

Effective HP = HP ÷ (1 - Defense%)

Example:
100 HP with 40% cover = 100 ÷ 0.6 = 166 effective HP
```

---

## Next Steps

### Recommended Tutorials:
1. **[[First_Mission_Walkthrough]]** - Apply these tactics
2. **[[Intermediate_Strategies]]** - Advanced combat techniques
3. **[[Research_Strategy_Guide]]** - Unlock better weapons/armor

### Advanced Topics:
- **[[/wiki/battlescape/Combat]]** - Combat system deep dive
- **[[/wiki/battlescape/README]]** - Battlescape architecture
- **[[../balance/README]]** - Combat balance and tuning

---

## Frequently Asked Questions

**Q: What's the best weapon type?**  
A: Assault rifles for reliability, sniper rifles for damage, shotguns for CQC.

**Q: Should I always use overwatch?**  
A: Only if 4+ AP remaining and no better action available.

**Q: How do I deal with Chrysalids?**  
A: Overwatch traps, keep distance, focus fire immediately.

**Q: When should I retreat?**  
A: When >50% squad casualties or mission unwinnable.

**Q: Can I shoot through cover?**  
A: No, line of sight blocked = cannot shoot.

**Q: What if I run out of ammo?**  
A: Switch to pistol (secondary weapon) or use grenades.

---

## Conclusion

You now understand:
- ✓ Action point system and AP management
- ✓ Cover mechanics and effective positioning
- ✓ Hit chance calculation and optimization
- ✓ Overwatch tactics and reaction fire
- ✓ Focus fire doctrine and target priority

**Master these fundamentals to dominate combat!**

Every battle is a puzzle to solve with positioning, action economy, and smart decision-making. Practice these tactics, learn from mistakes, and adapt to enemy behavior. Victory awaits the tactically sound commander!

---

*Last Updated: September 30, 2025*  
*Version: 1.0 - Initial Release*
