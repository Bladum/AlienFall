# Combat & Tactics Diagrams

**Created:** October 21, 2025  
**Purpose:** Visual representation of combat mechanics, damage calculations, and tactical systems

---

## 1. Combat Flow Diagram

### Diagram: Turn-Based Combat Loop

```
┌────────────────────────────────────────────────────────────┐
│           BATTLESCAPE TURN-BASED COMBAT LOOP               │
└────────────────────────────────────────────────────────────┘

BATTLE INITIALIZATION
├─ Generate map (procedurally)
├─ Place player squad at spawn
├─ Place enemy units at their spawn
├─ Initialize fog of war
├─ Set initial civilian positions (if applicable)
└─ Enter main combat loop

┌─────────────────────────────────────────────────────────┐
│                 START OF COMBAT TURN                      │
│                     (Repeats until victory/defeat)       │
└─────────────────────────────────────────────────────────┘

PHASE 1: PLAYER ACTION PHASE (Active)
├─ For each player unit (in squad order):
│
│  UNIT MENU OPTIONS:
│  ├─ 1. Move (spend TU)
│  │  ├─ Select destination hex
│  │  ├─ Calculate path (A* pathfinding)
│  │  ├─ Show action point cost (distance × 4)
│  │  ├─ Check for interrupts (reaction fire trigger)
│  │  ├─ Execute movement
│  │  └─ Update fog of war
│  │
│  ├─ 2. Attack (spend TU)
│  │  ├─ Select target (enemy unit)
│  │  ├─ Select weapon mode (auto/burst/snap/aimed)
│  │  ├─ Show accuracy percentage
│  │  ├─ Show TU cost (mode-dependent: 20-60 TU)
│  │  ├─ Confirm action
│  │  ├─ Roll to hit (random vs accuracy)
│  │  ├─ If hit: Roll damage
│  │  ├─ Apply armor reduction
│  │  └─ Deduct HP from target
│  │
│  ├─ 3. Use Item (spend TU)
│  │  ├─ Select item (grenade, medikit, etc.)
│  │  ├─ Select target location/unit
│  │  ├─ Show success/effect area
│  │  ├─ Confirm action
│  │  ├─ Execute effect (damage/heal/stun)
│  │  └─ Remove item from inventory
│  │
│  ├─ 4. Use Ability (spend TU & energy)
│  │  ├─ Select psionic/special ability
│  │  ├─ Select target
│  │  ├─ Show energy cost
│  │  ├─ Confirm action
│  │  ├─ Roll vs target resistance
│  │  └─ Apply effect (if successful)
│  │
│  ├─ 5. Take Cover (spend TU)
│  │  ├─ Move to adjacent cover
│  │  ├─ Select cover direction (full/half)
│  │  ├─ Set defensive stance
│  │  └─ Gain cover bonuses
│  │
│  ├─ 6. End Unit Turn (confirm)
│  │  └─ Move to next unit in squad
│  │
│  └─ 7. Undo Last Action (if available)
│     └─ Reset last action point spend
│
│  UNIT STATUS:
│  ├─ Health: XX/100 HP
│  ├─ Action Points: XX/100 TU
│  ├─ Energy: XX/50
│  ├─ Ammo: XX/WWW (carried/magazine)
│  ├─ Status: Normal/Wounded/Panicked/Stunned/Dead
│  └─ Cover: None/Half/Full
│
└─ When all player units finished: Advance to AI Phase

PHASE 2: AI ACTION PHASE (Reactive)
├─ For each enemy unit (sorted by initiative):
│
│  AI DECISION TREE:
│  ├─ Can I see player units?
│  │  ├─ Yes: Evaluate threats
│  │  │  ├─ Pick highest threat target
│  │  │  ├─ Decide action (move closer, attack, retreat)
│  │  │  ├─ Execute action
│  │  │  └─ Repeat until TU spent or action complete
│  │  │
│  │  └─ No: Patrol/Search
│  │     ├─ Move toward last known position
│  │     ├─ Scan for movement
│  │     └─ Return to patrol pattern if no threat
│  │
│  └─ When out of TU: Advance to next enemy
│
│  AI BEHAVIOR MODES:
│  ├─ Aggressive: Attack immediately, high risk
│  ├─ Defensive: Take cover, conservative fire
│  ├─ Cautious: Investigate, limited engagement
│  ├─ Retreat: Avoid combat, move to safety
│  ├─ Search: Patrol, look for targets
│  └─ Hold: Stay in place, defensive
│
└─ When all enemy units finished: Advance to Resolution Phase

PHASE 3: RESOLUTION & SPECIAL EVENTS
├─ Environmental effects:
│  ├─ Fire spread (each fire tile has 15% spread chance)
│  ├─ Smoke dissipation
│  ├─ Hazard damage (lava, etc.)
│  └─ Visibility updates
│
├─ Unit recovery:
│  ├─ Regenerate energy (psions: 5% per turn)
│  ├─ Recover from stun/panic (10% per turn)
│  └─ Morale updates (casualties reduce morale)
│
├─ Objective checks:
│  ├─ Is primary objective complete?
│  ├─ Is secondary objective triggered?
│  ├─ Any units in danger zone?
│  └─ Time limit exceeded?
│
└─ Victory/Defeat condition check:
   ├─ Player squad eliminated? → DEFEAT
   ├─ Primary objective complete? → VICTORY
   ├─ Escaped map boundary? → VICTORY
   ├─ Time limit exceeded? → MISSION FAILED
   └─ Continue? → Advance to next turn

┌─────────────────────────────────────────────────────────┐
│              END OF TURN (if battle continues)           │
│         Return to START OF COMBAT TURN                  │
└─────────────────────────────────────────────────────────┘

BATTLE CONCLUSION
├─ Victory Screen (if won)
│  ├─ Mission objectives: Status
│  ├─ Casualties: Friendly and Enemy
│  ├─ Salvage: Items recovered
│  ├─ Experience: Units gained XP
│  └─ Next: Return to Geoscape
│
├─ Defeat Screen (if lost)
│  ├─ Casualties: All friendly units
│  ├─ Lost items: Equipment value
│  ├─ Options: Reload / Abort / Continue (if units left)
│  └─ Next: Return to Geoscape or reload save
│
└─ Mission Summary returned to Geoscape


TURN STRUCTURE TIMING:
┌────────────────────────────────────────┐
│ Action Point (TU) Economy:             │
│ • Movement: 4 TU per hex               │
│ • Attack snap: 20 TU                   │
│ • Attack aimed: 40 TU                  │
│ • Attack burst: 30 TU                  │
│ • Attack auto: 60 TU                   │
│ • Use item: 15 TU                      │
│ • Take cover: 10 TU                    │
│ • End turn: Free (spends remaining TU) │
│                                        │
│ Total per unit: 100 TU per turn        │
│ Can accumulate TU across turns         │
└────────────────────────────────────────┘
```

---

## 2. Damage Calculation System

### Diagram: Weapon → Armor Interaction

```
┌────────────────────────────────────────────────────────────┐
│         DAMAGE CALCULATION PIPELINE                         │
└────────────────────────────────────────────────────────────┘

INPUT: Weapon Attack Resolution
├─ Attacker stats (accuracy, strength)
├─ Weapon properties (damage, AP cost, range)
├─ Weapon mode (auto/burst/snap/aimed)
├─ Defender stats (armor, evasion)
├─ Range to target
├─ Environmental factors (cover, height)
└─ Random seed (for reproducibility)

STAGE 1: ACCURACY CHECK (To-Hit Roll)
┌──────────────────────────────────────┐
│ Accuracy = Base Accuracy             │
│           + Weapon modifier          │
│           + Mode modifier            │
│           + Range penalty            │
│           - Target cover bonus       │
│           - Movement penalty         │
│                                      │
│ Example: Assault Rifle to Sectoid   │
│ Base: 65%                           │
│ Weapon: +5%                         │
│ Snap mode: -10%                     │
│ At 3 hexes: -10%                    │
│ In half cover: -15%                 │
│ = 65 + 5 - 10 - 10 - 15 = 35%      │
│                                      │
│ Roll d100 vs 35%                    │
│ Roll = 42 → MISS                    │
│ Roll = 28 → HIT (continue to damage)│
└──────────────────────────────────────┘
         │
    ┌────▼────────────────┐
    │ Did attack hit?     │
    └────┬────────────────┘
         │
    ┌────┴─────────────────────┐
   YES                         NO
    │                          │
    ▼                          ▼
(Continue)              (End - No Damage)

STAGE 2: DAMAGE ROLL (Weapon Damage)
┌──────────────────────────────────────┐
│ Base Damage = d(Weapon Dice)         │
│ e.g., Assault Rifle = d20            │
│                                      │
│ Modifiers:                           │
│ • Weapon mode damage (auto -20%,     │
│   burst normal, snap +10%, aimed +20%)
│ • Attacker strength bonus            │
│ • Environmental (height advantage)  │
│                                      │
│ Example:                             │
│ d20 roll = 15                       │
│ Base weapon = 15 damage            │
│ Aimed mode bonus: +3 (15 × 1.2)    │
│ Strength bonus: +2                  │
│ = 15 + 3 + 2 = 20 damage          │
└──────────────────────────────────────┘
         │
         ▼

STAGE 3: ARMOR PENETRATION
┌──────────────────────────────────────┐
│ Armor Rating (AR) = Target armor     │
│                                      │
│ Damage vs Armor:                    │
│ • Kinetic: Standard damage           │
│ • Laser: Vs AR × 0.8 (less blocked) │
│ • Plasma: Vs AR × 1.2 (more blocked)│
│ • Chemical: Ignores 50% AR          │
│                                      │
│ Example: Assault Rifle (Kinetic)    │
│ Damage: 20                          │
│ Target armor: 3 points              │
│ Penetration check:                  │
│   20 vs 3 → 20 - 3 = 17 damage    │
│                                      │
│ If armor ≥ damage:                  │
│   Blocked: 0 damage, reduced to 1   │
└──────────────────────────────────────┘
         │
         ▼

STAGE 4: SPECIAL EFFECTS (Damage Type)
┌──────────────────────────────────────┐
│ Damage Type Effects:                 │
│                                      │
│ KINETIC (Bullets, cannon)           │
│ • Standard impact damage             │
│ • Can ricochet (20% chance)         │
│ • No special effect                  │
│                                      │
│ LASER (Energy weapons)              │
│ • Ignores 20% of armor              │
│ • 10% chance to cause burn (DoT)   │
│ • Reduced damage to armored units   │
│                                      │
│ PLASMA (Plasma weapons)             │
│ • Ignores 10% of armor              │
│ • 20% chance to cause burn (severe) │
│ • High damage, rare ammunition      │
│                                      │
│ CHEMICAL (Gas, acid)                │
│ • Ignores 50% of armor              │
│ • Affects area (2-tile radius)     │
│ • Lingering effect (poison DoT)    │
│ • Affects friendlies too!           │
│                                      │
│ Apply special effects if triggered  │
└──────────────────────────────────────┘
         │
         ▼

STAGE 5: CRITICAL HIT CHECK
┌──────────────────────────────────────┐
│ Critical Hit Chance:                 │
│ Base: 5% + (Accuracy / 20)          │
│                                      │
│ Example:                             │
│ Accuracy 60% → 5 + 3 = 8% crit    │
│ Roll d100 = 7 → CRITICAL HIT        │
│                                      │
│ Critical Multiplier:                 │
│ • Standard: 2x damage               │
│ • Headshot: 3x damage (if targeted) │
│ • Explosive: 2.5x + splash         │
│                                      │
│ Damage after crit: 17 × 2 = 34 hp  │
└──────────────────────────────────────┘
         │
         ▼

OUTPUT: Final Damage Value
├─ Total HP damage: 34 points
├─ Special effects: Burn (1d4 DoT)
├─ Critical multiplier: 2x
├─ Armor remaining: 3 points
└─ Target health: 100 → 66 HP


DAMAGE TYPE EFFECTIVENESS MATRIX:
┌──────────┬──────────┬──────────┬──────────┬──────────┐
│ Weapon   │ Kinetic  │ Laser    │ Plasma   │ Chemical │
├──────────┼──────────┼──────────┼──────────┼──────────┤
│ Armor    │ 100%     │ 120%     │ 80%      │ 150%     │
│ Shield   │ 100%     │ 80%      │ 120%     │ 50%      │
│ Bio Unit │ 100%     │ 100%     │ 100%     │ 100%     │
│ Mechanical│100%     │ 120%     │ 80%      │ 50%      │
│ Energy   │ 100%     │ 150%     │ 80%      │ 100%     │
└──────────┴──────────┴──────────┴──────────┴──────────┘
(Values = damage multiplier vs target type)


EXAMPLE COMPLETE ATTACK:
┌────────────────────────────────────────────────┐
│ Soldier "Vega" fires Assault Rifle at Sectoid │
├────────────────────────────────────────────────┤
│ 1. Accuracy check: 65% vs d100(42) → HIT    │
│ 2. Damage roll: d20 = 15 → 15 damage       │
│ 3. Aimed mode: 15 × 1.2 = 18 damage       │
│ 4. Armor penetration: 18 - 3 armor = 15   │
│ 5. Critical check: 8% vs d100(31) → NO     │
│ 6. Fire effect: 10% vs d100(75) → NO       │
│ 7. FINAL DAMAGE: 15 HP                      │
│                                              │
│ Sectoid health: 45 → 30 HP (wounded)        │
└────────────────────────────────────────────────┘
```

---

## 3. Line of Sight & Cover System

### Diagram: Vision, Cover, and Positioning

```
┌────────────────────────────────────────────────────────────┐
│      LINE OF SIGHT & COVER MECHANICS                       │
└────────────────────────────────────────────────────────────┘

LINE OF SIGHT (LOS) SYSTEM:

┌─ Basic Visibility ──────────────────────────────────────┐
│                                                         │
│ Unit can see another unit if:                          │
│ 1. Path from unit center to target center unobstructed │
│ 2. Target within vision range (tactical range)         │
│ 3. Not in heavy fog/darkness (if applicable)           │
│                                                         │
│ Vision Range by unit type:                             │
│ • Infantry: 10 hexes (tactical range)                 │
│ • Marksman: 15 hexes (with sniper weapon)             │
│ • Alien unit: 12 hexes (average)                      │
│ • Commander: 8 hexes (suppression range)              │
│                                                         │
│ Line of sight blocked by:                              │
│ • Walls (complete block)                              │
│ • Trees (partial block)                               │
│ • Water features (complete block if deep)             │
│ • Terrain elevation (blocked if height difference)    │
│ • Smoke/fog (vision reduced by 50%)                   │
│ • Unit collision (can see past other units)           │
└─────────────────────────────────────────────────────────┘

COVER SYSTEM:

┌─ Cover Types ──────────────────────────────────────────┐
│                                                         │
│ Full Cover:                    Half Cover:              │
│ ┌─────────────────┐           ┌─────────────────┐    │
│ │ █████████████   │           │ ░░░░░░█████████ │    │
│ │ █ UNIT █████████│           │ ░ UNIT ███████░ │    │
│ │ █████████████   │           │ ░░░░░░█████████ │    │
│ └─────────────────┘           └─────────────────┘    │
│                                                         │
│ • No damage from front     │ • 50% damage from front │
│ • Normal damage from side  │ • 75% damage from side  │
│ • Can't shoot from full    │ • Can shoot/be shot at  │
│                             │ • Requires adjacent tile│
│                             │   with partial obstacle│
│                                                         │
│ Bonus from cover:                                      │
│ • Full cover: +5 armor points (damage reduction)     │
│ • Half cover: +3 armor points                        │
│ • Flanked: No cover bonus (exposed rear)             │
└─────────────────────────────────────────────────────────┘

┌─ Cover Interaction with Accuracy ──────────────────────┐
│                                                         │
│ Accuracy Modification:                                 │
│ • Clear line of sight:  0% penalty                    │
│ • Half cover:          -15% to accuracy              │
│ • Full cover:          -30% to accuracy              │
│ • Flanked/rear:        +10% to accuracy (exposed)    │
│ • Height advantage:     +5% to accuracy              │
│ • Height disadvantage:  -5% to accuracy              │
│                                                         │
│ Damage Reduction:                                      │
│ • Half cover: Incoming damage × 0.75                │
│ • Full cover: Incoming damage × 0.50                │
│ • Note: Only applies from front/side                 │
│          Rear attacks bypass cover                   │
└─────────────────────────────────────────────────────────┘

FLANKING SYSTEM:

┌─ Flanking Positions ────────────────────────────────────┐
│                                                         │
│ Unit is flanked when attacked from side/rear         │
│ Coverage map (X = attacker directions that flank):    │
│                                                         │
│        FRONT ─────►                                    │
│                                                         │
│           ↙     ↓     ↘                               │
│         ↙       ↓       ↘                             │
│     ╱─────────────────────╲                           │
│    │       █ UNIT █       │                           │
│    │       ███████        │                           │
│     ╲─────────────────────╱                           │
│         ↖       ↑       ↗                             │
│           ↖     ↑     ↗                               │
│                                                         │
│ Front (safe):     ▬ (full cover applies)             │
│ Flanks (danger):  ↙↘ and ↙↖ (-cover, +accuracy)    │
│ Rear (exposed):   ↑ (-25% defense, +25% enemy acc) │
│                                                         │
│ Flanking penalties:                                    │
│ • Flanked: Unit is attacked from side hexes        │
│   - Loses half cover bonus                          │
│   - Attacker gains +10% accuracy                    │
│   - Defender takes +25% damage                      │
│                                                         │
│ • Rear attack: Unit is attacked from behind        │
│   - Loses all cover bonuses                         │
│   - Attacker gains +25% accuracy                    │
│   - Defender takes +50% damage                      │
│   - Can trigger panic check (morale)                │
└─────────────────────────────────────────────────────────┘

FOG OF WAR (FoW):

┌─ Fog of War System ────────────────────────────────────┐
│                                                         │
│ Units only see hexes within their vision range       │
│ Unseen hexes are "fogged" (hidden from player)       │
│                                                         │
│ Revealed by:                                           │
│ • Direct line of sight (primary)                     │
│ • Ally unit sighting (shared vision)                 │
│ • Radar/sensor coverage (partial)                    │
│ • Previous turn knowledge (memory of seen areas)     │
│                                                         │
│ Effects:                                               │
│ • Cannot target fogged units                         │
│ • Fog is dynamic (updates each turn)                │
│ • Ambush mechanic: Enemies in fog can surprise     │
│ • Strategic element: Information is valuable        │
│                                                         │
│ Memory system:                                         │
│ • Seen terrain stays visible (not fogged)            │
│ • Enemy units disappear if no LOS (may return)      │
│ • Explosions/fire are visible through fog (partial) │
│ • Audio cues indicate distant threats                │
└─────────────────────────────────────────────────────────┘
```

---

## 4. Action Point Economy

### Diagram: TU Cost Breakdown by Action

```
┌────────────────────────────────────────────────────────────┐
│        ACTION POINT (TU) ECONOMY REFERENCE                 │
└────────────────────────────────────────────────────────────┘

UNIT POOL: 100 TU per turn (can save up to 50 for next turn)

MOVEMENT COSTS:
├─ Walk (1 hex):         4 TU
├─ Walk (2 hex):         8 TU
├─ Walk (3 hex):        12 TU
├─ Run (2+ hexes):      5 TU per hex (faster, louder)
├─ Prone/Crouch:        +50% TU cost
├─ Climb/Traverse:      +100% TU cost
├─ Swimming:            +200% TU cost
└─ Disengage (retreat): 30 TU (even if ending turn)

ATTACK COSTS (by weapon mode):
├─ Reaction Fire:        
│  ├─ 1st shot: Free (if ready)
│  ├─ 2nd+ shots: 50 TU each
│
├─ Aimed Shot (high accuracy, slow):
│  ├─ Pistol: 25 TU
│  ├─ Rifle: 40 TU
│  ├─ Sniper: 50 TU
│  ├─ Heavy: 60 TU
│
├─ Snap Shot (quick, lower accuracy):
│  ├─ Pistol: 15 TU
│  ├─ Rifle: 20 TU
│  ├─ Sniper: 30 TU
│  ├─ Heavy: 40 TU
│
├─ Burst Fire (multiple rounds):
│  ├─ Pistol: 20 TU (3 rounds)
│  ├─ Rifle: 30 TU (5 rounds)
│  ├─ SMG: 25 TU (8 rounds)
│  ├─ Heavy: 50 TU (4 rounds)
│
└─ Full Auto (continuous):
   ├─ SMG: 60 TU (15 rounds)
   ├─ Rifle: 60 TU (10 rounds)
   └─ Heavy: 80 TU (8 rounds)

SPECIAL ACTIONS:
├─ Use Item (grenade, medikit, etc.):    15 TU
├─ Take Cover (move to adjacent cover):  10 TU
├─ Go Prone (take defensive stance):     10 TU
├─ Stand Up (from prone):                 5 TU
├─ Activate Ability (psionic power):     20-40 TU
├─ Reload:                                10 TU
├─ Switch Weapon:                         5 TU
├─ Open/Close Door:                       5 TU
├─ Interact with Object:                 10 TU
└─ Throw Item (without detonation):     10 TU

END OF TURN:
└─ End Turn: Free (all remaining TU spent)

TU ECONOMY EXAMPLES:

EXAMPLE 1: Aggressive Assault
├─ Move 2 hexes: 8 TU
├─ Fire snap shot: 20 TU
├─ Move 1 hex: 4 TU
├─ Fire snap shot: 20 TU
├─ Move 1 hex (to cover): 4 TU
├─ Take cover: 10 TU
├─ Fire aimed: 40 TU
├─ = 106 TU → EXCEEDS, can't do all
└─ Actual: Skip last aimed shot, fire snap instead

EXAMPLE 2: Defensive Position
├─ Move 2 hexes (to cover): 8 TU
├─ Take cover: 10 TU
├─ Ready for reaction fire: 15 TU
├─ Reload: 10 TU
├─ Prep grenade (ready for next turn): 5 TU
├─ End turn: Rest of TU (52 TU spent)
└─ Can fire reaction shots if enemies move

EXAMPLE 3: Tactical Advance
├─ Move cautiously (crouch): 6 TU
├─ Scan for targets: Free (part of movement)
├─ Fire aimed shot: 40 TU
├─ Move behind cover: 8 TU
├─ Take cover: 10 TU
├─ Ready suppression fire: 20 TU
├─ End turn: Rest of TU (84 TU spent)
└─ Next turn: Can suppress enemies


RESOURCE MANAGEMENT:

Unit Stats Track:
├─ Health: 30-100 HP (depends on unit)
├─ Action Points: 100 TU per turn
├─ Energy: 40-100 pts (psions/special units)
├─ Ammo: Varies by weapon
│  ├─ Pistol: 30-60 rounds per magazine
│  ├─ Rifle: 20-30 rounds per magazine
│  ├─ Heavy: 8-15 rounds per magazine
│  ├─ Grenades: 1-5 total
│  └─ Consumables: 1-3 total
│
├─ Status Effects:
│  ├─ Normal (full function)
│  ├─ Wounded (move penalty -10%)
│  ├─ Critical (move -25%, attack -30%)
│  ├─ Stunned (can't act, -1 turn)
│  ├─ Panicked (random movement)
│  └─ Dead (removed from battle)
│
└─ Morale: Affects behavior and special actions

CUMULATIVE TU RULES:
├─ Unused TU: Can carry up to 50 TU to next turn
├─ TU Overflow: Excess TU is lost
├─ Overtime: Some abilities grant bonus TU
└─ Recovery: Resting/standing still does NOT restore TU
```

---

## Summary

Combat mechanics create engaging tactical depth:

1. **Combat Flow:** Turn-based with phases for player → AI → resolution
2. **Damage System:** Accuracy → Roll → Penetration → Effects → Crit checks
3. **Positioning:** LOS, cover, flanking create tactical positioning value
4. **Resource Economy:** Limited TU per turn forces action prioritization

These systems ensure:
- Strategic choices (every action has opportunity cost)
- Tactical positioning (cover and LOS matter)
- Balanced combat (multiple viable strategies)
- Player agency (clear cause-effect relationships)

---

**Related Documentation:**
- `wiki/systems/Battlescape.md` - Combat detailed mechanics
- `engine/battlescape/combat/damage_models.lua` - Implementation
- `engine/battlescape/battle_ecs/hex_system.lua` - Hex grid & LOS
