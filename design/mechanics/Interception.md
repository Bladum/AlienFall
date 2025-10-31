# Interception System

> **Status**: Design Document
> **Last Updated**: 2025-10-28
> **Related Systems**: Geoscape.md, Crafts.md, PilotSystem_Technical.md, Items.md

## Table of Contents

- [Overview](#overview)
- [Strategic Environment](#strategic-environment)
- [Equipment & Weapon Systems](#equipment--weapon-systems)
- [Weapon Mechanics](#weapon-mechanics)
- [Action Point System](#action-point-system)
- [Energy Point System](#energy-point-system)
- [Object Capabilities](#object-capabilities)
- [Combat Model Simplification](#combat-model-simplification)
- [Object Deactivation](#object-deactivation)
- [Interception Outcomes](#interception-outcomes)
- [Experience & Advancement](#experience--advancement)
- [Base Defense Integration](#base-defense-integration)
- [Biome & Environmental Effects](#biome--environmental-effects)
- [Interception as Strategic Layer](#interception-as-strategic-layer)
- [Design Analogy](#design-analogy)

---

## Overview

Interception is the tactical engagement layer positioned between the Geoscape (strategic) and Battlescape (tactical squad combat) levels. It represents mid-level military engagements between player craft/bases and enemy forces (UFOs, alien bases, missions). The interception system uses a card-game-like combat model featuring hero-level craft and base defenses engaging enemy objectives.

**Design Philosophy**

Interception bridges strategic deployment and tactical ground combat. It simulates aerial/orbital combat and base defense scenarios before the conflict escalates to ground-level battlescape. The system emphasizes resource commitment, positioning, and weapon selection over individual unit tactics.

---

## Strategic Environment

**Three-Dimensional Engagement Space**
Combat is organized into three altitude sectors representing different operational domains:

- **Air Sector (Upper)**: Aircraft, orbital platforms, flying craft, space-based weapons
- **Land/Water Sector (Middle)**: Ground installations, submarines, coastal defenses, land-based craft
- **Underground Sector (Lower)**: Underground bases, subterranean installations, deep bunkers

**Sector Capacity**
- Maximum 4 objects per sector
- Objects include: Player craft, player bases, enemy UFOs, enemy missions, defensive installations
- Mixing of object types within sectors allowed
- Sector switching restricted during engagement (see "Deactivation Mechanics")

- Combat Formation
- Player forces occupy left side of engagement screen
- Enemy forces occupy right side of engagement screen
- Sectors are independent but visible simultaneously
- Cross-sector targeting available with appropriate weapons

---

## Equipment & Weapon Systems

**Equipment Specialization**
Craft equipment determines available actions and tactical capabilities during interception.

**Weapon Type Interactions**

| Weapon Type | Primary Target | Effect |
|---|---|---|
| **Air-to-Air** | Enemy Aircraft/UFOs | Direct aerial combat; enables mutual combat above land |
| **Air-to-Land** | Ground Installations | Enables bombing of ground bases and structures |
| **Water-to-Water** | Naval Targets/Submarines | Enables underwater combat and torpedoes |
| **Air-to-Underwater** | Submerged Targets | Anti-submarine capability; attacks underwater threats |
| **Land-to-Air** | Aircraft/Orbital | Base AA defense; static anti-aircraft coverage |
| **Land-to-Water** | Naval/Submarine | Coastal defense; ground-based naval warfare |

**Cross-Sector Combat**
- Weapons enable interactions between different sectors
- Loadout diversity creates tactical decision-making
- Wrong equipment for target = no engagement capability
- Players must anticipate enemy sector positioning

---

## Weapon Mechanics

**Weapon Properties**
Each weapon has distinct characteristics that define its effectiveness:

- **Chance to Hit**: Accuracy rating; lower percentages reflect difficult targeting
- **Action Point Cost**: AP required to fire weapon (varies by weapon type)
- **Energy Point Cost**: EP required per shot (energy pools limit firing frequency)
- **Cooldown**: Turns between successive shots (e.g., missiles fire every 3 turns)
- **Range (Turns to Impact)**: Simulates projectile travel time before damage applies
- **Damage Value**: Raw damage on successful hit (no armor/resistance calculations)

**Range & Flight Time System**

Range is measured by turn delay before impact, creating suspenseful exchanges:

| Range Class | Turns to Impact | Strategic Implication |
|---|---|---|
| **Close** | 5 turns | Point-blank; slow projectiles or instant fire |
| **Short** | 4 turns | Adjacent sector; medium travel time |
| **Medium** | 3 turns | Standard combat range; balanced timing |
| **Long** | 2 turns | Extended range; rapid impact |
| **Very Long** | 1 turn | Intercontinental; nearly instant strikes |

**Critical Distinction**
Range (turns to impact) is SEPARATE from cooldown mechanics:
- **Range**: How long projectile takes to reach target
- **Cooldown**: How long between successive shots
- Example: Missile weapon with 1-turn range but 3-turn cooldown fires every 3 turns with 1-turn flight time

**Special Weapons**
Specialized weapons operate on craft and bases but not individual soldiers:

**Craft/Base Offensive Weapons**
- Rockets: Multi-target capability; medium cooldown
- Bombs: Area effect damage; extended damage radius
- Torpedoes: Water-specialized; devastating to naval targets
- Lasers: Energy-based; infinite ammo but high energy cost

**Craft/Base Defensive Systems**
- Shields: Reduce incoming damage
- Armor Plating: Passive damage reduction
- Radar: Detection and targeting capability
- Power Generators: Increase energy pool and regeneration

---

### Hit Chance Calculation (Core Combat Formula)

The hit chance determines whether a weapon successfully strikes its target. All weapons use the same calculation system:

```
Final Hit Chance = Base Accuracy - Distance Penalty - Target Evasion + Modifiers
Clamped to 5%-95% (no guaranteed hits or misses)

Where:
- Base Accuracy: Weapon accuracy rating (50%-95% typical)
- Distance Penalty: -(Range - Optimal Range) × 2% per hex beyond optimal
- Target Evasion: Target's evasion maneuver stat (0-30%)
- Modifiers: Environmental/status effects (±5-15%)
```

#### Base Accuracy by Weapon Type

| Weapon Type | Base Accuracy | Optimal Range |
|---|---|---|
| **Point Defense** | 85% | 5 hexes |
| **Main Cannon** | 75% | 8 hexes |
| **Missile Pod** | 80% | 10 hexes |
| **Laser Array** | 70% | 12 hexes |
| **Plasma Caster** | 65% | 8 hexes |
| **Torpedo** | 75% | 6 hexes |

#### Distance Penalty Calculation

For shots beyond optimal range:

```
Distance Penalty = (Current Range - Optimal Range) × 2% per hex

Example: Missile at 10 hex range (optimal 10) = 0% penalty
         Missile at 12 hex range (optimal 10) = -4% penalty
         Missile at 15 hex range (optimal 10) = -10% penalty
```

**Maximum Range:** Weapons cannot fire beyond 1.5× optimal range (beyond that range, distance penalty drops accuracy below 5% minimum)

#### Evasion Modifier

Evasion maneuvers reduce incoming hit chance:

| Evasion Level | Defensive Bonus | Cost |
|---|---|---|
| **None** | 0% | — |
| **Light Evasion** | -10% | 5 AP + 5 EP |
| **Full Evasion** | -20% | 1 AP + 15 EP |
| **Emergency Dodge** | -30% | 2 AP + 25 EP |

**Duration:** Evasion modifiers persist until disabled or new action taken

#### Hit Chance Example

```
Scenario: Player fires Missile Pod at UFO

Weapon: Missile Pod
- Base Accuracy: 80%
- Optimal Range: 10 hexes

Target: UFO
- Current Range: 12 hexes
- Evasion Active: -15% bonus (Light evasion)
- Environmental Modifier: +5% (favorable wind)

Calculation:
Base = 80%
Distance = -(12 - 10) × 2% = -4%
Evasion = -15%
Environment = +5%
Final = 80 - 4 - 15 + 5 = 66%

Player fires with 66% hit chance
```

#### Accuracy Modifiers

These factors apply modifiers to hit chance:

| Modifier | Effect | Source |
|---|---|---|
| **Stability Bonus** | +5-10% | Standing still 1+ turn |
| **Burst Penalty** | -5-15% | Firing rapidly without pause |
| **Environmental Cover** | -5-20% | Target partially obscured |
| **Weapon Damage Focus** | -10% | Dedicating high AP to weapon attack |
| **Stabilization Systems** | +10-15% | Craft technology/addon |
| **Sensor Malfunction** | -20-30% | Electronic warfare active |

---

### Damage Calculation (Core Combat Formula)

Damage determines health loss from successful hits. Unlike hit chance, damage is deterministic with minimal variance:

```
Final Damage = Base Damage × (1 + Variance) × (1 + Critical Bonus)
No armor reduction multipliers (intentional design choice)

Where:
- Base Damage: Weapon's damage rating
- Variance: ±5-10% random spread (weapon-dependent)
- Critical Bonus: 0% (no critical hits in Interception)
```

#### Base Damage by Weapon Type

| Weapon Type | Damage Range | Variance | Notes |
|---|---|---|---|
| **Point Defense** | 15-25 | ±5% | Fast firing |
| **Main Cannon** | 40-60 | ±10% | Balanced |
| **Missile Pod** | 50-80 | ±8% | Explosive |
| **Laser Array** | 60-90 | ±5% | Energy-based |
| **Plasma Caster** | 70-120 | ±10% | Exotic |
| **Torpedo** | 60-100 | ±8% | Water-specialized |

#### Damage Variance Example

```
Scenario: Point Defense cannon fires

Weapon: Point Defense
- Base Damage: 20
- Variance: ±5%

Damage Roll:
Random = -3% (within ±5% range)
Final = 20 × (1 - 0.03) = 20 × 0.97 = 19.4 ≈ 19 damage

Next Shot:
Random = +5% (at variance limit)
Final = 20 × (1 + 0.05) = 20 × 1.05 = 21 damage
```

#### No Armor Reduction

**Design Note:** Interception intentionally excludes armor reduction mechanics:

- **Why:** Simplifies combat outcomes and reduces formula complexity
- **Effect:** All damage applies uniformly regardless of target armor rating
- **Consequence:** Armor serves as cosmetic/narrative element only
- **Strategic Impact:** Player focuses on tactical positioning rather than armor type selection

#### Damage Application

When hit resolves:
1. Check if attack hits (using hit chance roll)
2. If hit: Roll damage (using variance calculation)
3. Apply damage to target's health (subtract from HP)
4. Check if target deactivated (see Object Deactivation section)
5. If target destroyed (HP = 0): Remove from combat

---

### Thermal/Heat System (Weapon Stability)

Extended combat generates heat buildup in weapons and systems. Heat can cause weapon jams and reduced combat efficiency:

#### Heat Generation

| Action | Heat Generated | Notes |
|---|---|---|
| **Single Shot** | +5 heat | Standard weapon fire |
| **Burst Fire** | +15 heat | Rapid multi-shot volley |
| **Sustained Beam** | +3 per turn | Laser weapons |
| **Overcharge Shot** | +20 heat | Forced extra damage with penalty |
| **Weapon Jam** | 0 heat | Already jammed, cannot fire |

#### Heat Dissipation

| Unit Type | Base Dissipation | Modifier |
|---|---|---|
| **Bases** | -15 heat/turn | Fast cooling (stationary) |
| **Large Craft** | -10 heat/turn | Medium cooling |
| **Small Craft** | -5 heat/turn | Limited cooling capacity |
| **Environmental** | ±5 heat | Ocean (-5, favorable), Desert (+5, unfavorable) |

#### Heat Threshold & Effects

| Heat Level | Effect | Status |
|---|---|---|
| **0-50 heat** | No penalty | Normal operation |
| **51-100 heat** | -10% accuracy on next shot | Warning state |
| **101+ heat** | Weapon JAMMED; cannot fire | Jam state |

**Heat Resolution:**
1. Weapon fires (adds heat)
2. Check if heat > 100 (jam check)
3. If jammed: Weapon disabled until heat < 50
4. During jam: Weapon cannot fire, but heat dissipates at x2 rate
5. Once < 50 heat: Weapon automatically unjams and resumes fire

#### Heat Example Scenario

```
Turn 1: Cannon fires single shot
- Heat: 0 + 5 = 5
- Accuracy penalty: 0%
- Weapon status: Operational

Turn 2: Cannon fires burst
- Heat: 5 + 15 = 20
- Accuracy penalty: 0%
- Weapon status: Operational

Turn 3: Cannon fires burst again + takes environmental penalty
- Heat: 20 + 15 + 5 (desert) = 40
- Accuracy penalty: 0%
- Weapon status: Operational

Turn 4: No action, cooling only
- Heat: 40 - 10 (dissipation) = 30
- Weapon status: Operational

Turn 5: Overcharge shot (intentional high damage)
- Heat: 30 + 20 = 50
- Accuracy penalty: 0% (still at warning threshold)
- Weapon status: Operational (barely)

Turn 6: Single shot
- Heat: 50 + 5 = 55
- Accuracy penalty: -10% (warning state)
- Check jam: 55 < 101, no jam yet
- Weapon status: Warning (degraded accuracy)

Turn 7: Single shot again
- Heat: 55 + 5 = 60
- Accuracy penalty: -10% (still warning)
- Weapon status: Warning

Turn 8: Player attempts burst fire
- Heat before: 60
- Burst would add: +15
- Heat would be: 75
- Accuracy: -10% penalty applies
- Weapon fires (successfully)
- Heat: 75

Turn 9: Another burst
- Heat before: 75 + (-10 dissipation) = 65
- Burst adds: +15
- Heat would be: 80
- Weapon fires
- Heat: 80

Turn 10: One more burst (pushing it)
- Heat before: 80 + (-10 dissipation) = 70
- Burst adds: +15
- Heat would be: 85
- Weapon fires
- Heat: 85

Turn 11: Overcharge attempt
- Heat before: 85 + (-10 dissipation) = 75
- Overcharge would add: +20
- Heat would be: 95
- STILL not jammed, but very close
- Weapon fires
- Heat: 95

Turn 12: Single shot
- Heat before: 95 + (-10 dissipation) = 85
- Single shot adds: +5
- Heat would be: 90
- Weapon fires
- Heat: 90

Turn 13: Burst fire (final push)
- Heat before: 90 + (-10 dissipation) = 80
- Burst adds: +15
- Heat would be: 95
- Weapon fires
- Heat: 95

Turn 14: Another shot attempt
- Heat before: 95 + (-10 dissipation) = 85
- Single shot adds: +5
- Heat would be: 90
- Weapon fires
- Heat: 90

Turn 15: Burst fire (this does it)
- Heat before: 90 + (-10 dissipation) = 80
- Burst adds: +15
- Heat would be: 95
- Still firing...

Turn 16: Overcharge attempt (finally exceeds threshold)
- Heat before: 95 + (-10 dissipation) = 85
- Overcharge adds: +20
- Heat = 105: JAMMED!
- Weapon JAMS and cannot fire

Turn 17-20: Cooling phase (2× rate while jammed)
- Turn 17: 105 - 20 (2× dissipation) = 85
- Turn 18: 85 - 20 = 65
- Turn 19: 65 - 20 = 45 (UNJAM! <50 threshold)
- Weapon automatically resets
- Ready to fire again
```

#### Heat Addiction Prevention

Heat accumulation discourages sustained high-damage output:

- Players must manage cooling between burst attacks
- Overuse of high-damage weapons risks jamming
- Strategic decision: Continue high damage (risk jam) vs. cool down (lose turn)
- Environmental factors reward or punish thermal management

---

## Action Point System

**Action Point Mechanics**
Action Points govern how frequently units can perform actions during combat turns. AP regenerates at start of each turn based on health status.

**Base Action Points by Health Status**
- **Healthy Units** (>50% HP): 4 AP per turn (fully regenerating)
- **Damaged Units** (25-50% HP): 3 AP per turn
- **Critical Units** (<25% HP): 2 AP per turn

**Action Costs Reference**
- **Weapon Fire**: 1-4 AP depending on weapon
  - Snap shot (quick fire): 1 AP, -10% accuracy
  - Aimed shot (standard): 2 AP, +20% accuracy
  - Burst fire (multiple rounds): 3 AP, high ammo consumption
  - Heavy weapon fire: 4 AP, devastating damage
- **Special Ability**: 1-3 AP
- **Defense Posture**: 1 AP to activate defensive mode
- **Energy Generation**: 2 AP to dedicate turn to energy recovery
- **Overwatch Setup**: 1 AP to prepare reaction fire

**Health-Based Degradation**
- Damage directly degrades combat capability by reducing action economy
- Heavily damaged craft/bases become vulnerable due to reduced actions per turn
- Healing or repairs restore AP capability
- Temporary buffs can exceed normal AP caps

**Advanced Mechanics**
- **Quick Actions**: Some abilities consume 0 AP (passive reactions)
- **Burst Mode**: Can spend extra AP for improved weapon accuracy (+5% per AP spent)
- **Fatigue**: Consecutive turns of high AP usage causes fatigue penalty (-1 AP next turn)
- **Second Wind**: Special ability to recover 1 AP at cost of 50 energy points
- **Adrenaline Rush**: Emergency mode grants +1 AP once per combat

---

## Energy Point System

**Energy Pool Mechanics**
Energy Points represent combined capacity for:
- Weapon discharge power
- Defensive shield strength
- Propulsion/maneuvering
- Electronic countermeasures

**Energy Regeneration by Unit Type**
- **Bases**: Per-turn regeneration rate very high (50+ EP/turn typical)
- **Large Craft**: Moderate regeneration (10-15 EP/turn)
- **Small Craft**: Limited regeneration (5-10 EP/turn)
- **Depleted energy**: No weapons, no defenses, reduced capability

**Energy Cost Examples**
- **Standard Weapon**: 5-10 EP per shot
- **Heavy Weapon**: 15-25 EP per shot
- **Energy Weapon**: 20-40 EP per shot but infinite ammo
- **Shield Activation**: 10 EP per turn active
- **Electronic Warfare**: 15 EP per action
- **Emergency Overload**: Temporary boost costs 50 EP (damage self next turn)
- **Evasion Maneuver**: 5-15 EP depending on intensity

**Energy Depletion Effects**
- Cannot fire weapons without sufficient EP
- Defensive systems require energy to function
- Units become passive targets when energy depleted
- Recovery requires turn-based regeneration
- Some weapons cannot fire when EP below minimum threshold (e.g., weapons need 25% EP minimum)
- Shield collapse at 0 EP (full damage taken)

**Energy Management Strategies**
- **Rationing**: Prioritize critical weapons, reduce defense usage
- **Regeneration Focus**: Dedicate turns to recovering energy pool
- **Power Distribution**: Allocate energy between offense and defense
- **Prioritized Recovery**: Protect high-value targets while recovering energy
- **Overcharge**: Exceed energy reserves but suffer damage next turn
- **Power Surge**: Temporary boost requiring cooldown period

**Thermal/Dissipation Mechanics**
- Extended weapon use generates heat buildup
- Overheating causes weapon jams or cooldown extensions
- Bases cool more efficiently than craft (passive dissipation)
- Environmental factors affect heat dissipation (ocean = faster cooling, desert = slower cooling)
- Heat accumulation: +5 per weapon shot, -10 per turn cooling (bases -15)
- Jam threshold: Weapon jams at 100+ heat, requiring cooldown

---

## Object Capabilities

**Every Combat Object Possesses**
- **Health Points**: Damage threshold before destruction
- **Action Points**: 4 per turn (modified by health status)
- **Energy Points**: Pool of energy for all operations

**Available Actions (per turn)**
Each object can select from:
1. **Weapon Usage**: Attack enemy objects using equipped weapons
2. **Passive Systems**: Activate shields, defensive structures, countermeasures
3. **Evasion Maneuvers** (Craft/UFOs only): Perform dodging to reduce incoming hit chance
4. **Energy Regeneration**: Intentionally dedicate turn to restoring EP pool
5. **Sector Movement** (normally restricted; see deactivation)

**Passive Defense Systems**
- Shield activation: Reduces incoming damage by percentage
- Electronic warfare: Degrades enemy accuracy
- Armor reinforcement: Increases defense rating
- Countermeasures: Specific defense against missile attacks

---

## Combat Model Simplification

**Excluded Mechanics**
The interception system intentionally excludes complexity for streamlined gameplay:

- **No Critical Hits**: Damage is consistent and predictable
- **No Morale System**: Units do not become panicked or broken
- **No Sanity Mechanics**: Psychological damage not tracked
- **No Armor Reduction Multipliers**: Damage applies equally regardless of armor
- **No Resistances**: All damage types apply uniformly

**Design Rationale**
Simplification creates transparent gameplay where players understand exactly how damage translates to outcomes. This supports strategic planning over random chance.

---

## Object Deactivation

**Deactivation Mechanics**
Objects can become disabled through damage, creating escalating vulnerability:

**Deactivation Chance Thresholds**
- **>50% Health**: No deactivation risk; unit fully operational
- **25-50% Health**: Low deactivation risk (~10-20% per turn)
- **<25% Health**: High deactivation risk (~40-60% per turn)

**Deactivation Process**
- Damaged objects accumulate deactivation probability each turn
- When deactivated: Object becomes inert and uncontrollable
- Deactivated units do NOT respond to player commands
- Deactivated objects become vulnerable to finishing shots

**Post-Deactivation Consequence**
- Deactivated craft may drop into lower sector (air → land → underground)
- Deactivated bases become vulnerable to assault
- Deactivated mission objects stop executing objectives
- If ALL objects on one side deactivated: That side loses interception

**Victory Condition**
- **Straight Win**: Reduce enemy to 0 HP (destruction)
- **Forced Win**: Deactivate all enemy objects (incapacitation)
- Once all enemy objects deactivated, player side wins interception

---

## Interception Outcomes

**Victory Conditions (Player Wins)**
1. **Total Destruction**: Reduce all enemy objects to 0 HP
2. **Complete Deactivation**: All enemy objects become inert/deactivated
3. **Strategic Retreat**: Enemy forces disengage (optional)

**Defeat Conditions (Player Loses)**
1. **Total Destruction**: All player objects reduced to 0 HP
2. **Complete Deactivation**: All player objects become inert
3. **Tactical Failure**: Unable to prevent enemy mission objective

**Post-Victory Options**
- **Return to Geoscape**: Combat ends; player retains damaged craft/bases
- **Escalate to Battlescape**: Transition to ground combat if interception involved landing troops
- **Continued Pursuit**: Damaged enemy objects may flee to adjacent regions

**Post-Defeat Consequences**
- **Craft Lost**: Destroyed craft removed from inventory; crew casualties likely
- **Base Damaged**: Bases may sustain damage but remain operable
- **Enemy Success**: Unopposed enemy missions complete their objectives
- **Score Penalties**: Mission failure reduces funding and country relations

---

## Experience & Advancement

**Pilot Experience from Interception**

In the redesigned system, **pilots** (not crafts) gain experience from interception missions. Pilots are units assigned to crafts as crew, and they progress through pilot-specific ranks based on interception combat.

### Pilot XP Gain

**XP Distribution by Crew Position:**

| Crew Position | XP Multiplier | Role |
|---------------|---------------|------|
| **Primary Pilot** | 100% | Controls craft, full XP rewards |
| **Co-Pilot** | 50% | Assists pilot, half XP rewards |
| **Crew Member** | 25% | Operates subsystems, quarter XP |
| **Additional Crew** | 10% | Support roles, minimal XP |

**XP Sources & Amounts:**

| Action | Base Pilot XP | Co-Pilot XP | Crew XP |
|--------|---------------|-------------|---------|
| **Mission Participation** | +10 XP | +5 XP | +2 XP |
| **Kill Enemy Craft** | +50 XP | +25 XP | +12 XP |
| **Assist in Kill** | +25 XP | +12 XP | +6 XP |
| **Survive Interception** | +10 XP | +5 XP | +2 XP |
| **Victory (force retreat)** | +30 XP | +15 XP | +7 XP |
| **Perfect Victory (no damage)** | +50 XP | +25 XP | +12 XP |
| **Damage Dealt (per 100)** | +5 XP | +2 XP | +1 XP |
| **Enemy Detected** | +5 XP | +2 XP | +1 XP |

**Example Interception Mission:**
```
Mission: Intercept UFO over urban sector
Crew: Alice (Pilot), Bob (Co-Pilot), Charlie (Crew)

Actions:
- UFO detected: +5 XP (pilot), +2 XP (co-pilot), +1 XP (crew)
- 200 damage dealt: +10 XP (pilot), +5 XP (co-pilot), +2 XP (crew)
- UFO destroyed: +50 XP (pilot), +25 XP (co-pilot), +12 XP (crew)
- Perfect victory: +50 XP (pilot), +25 XP (co-pilot), +12 XP (crew)

Total Pilot XP:
- Alice: 115 Pilot XP
- Bob: 57 Pilot XP
- Charlie: 27 Pilot XP
```

### Pilot Rank Progression

Pilot XP advances pilots through **pilot-specific ranks** (separate from ground combat ranks):

| Rank | Pilot XP Required | Rank Name | Stat Bonuses |
|------|------------------|-----------|--------------|
| **0** | 0 | Rookie | Base stats |
| **1** | 100 | Trained Pilot | Piloting +1 |
| **2** | 300 | Veteran Pilot | Piloting +2, class specialization |
| **3** | 600 | Ace Pilot | Piloting +3, special abilities |
| **4** | 1,000 | Master Pilot | Piloting +4, elite bonuses |
| **5** | 1,500 | Legendary Pilot | Piloting +5, unique abilities |

**Dual Progression**: Pilots track BOTH pilot XP (from interception) AND ground combat XP (from battlescape) independently. A unit can be Rank 3 Ace Fighter Pilot + Rank 2 Rifleman simultaneously.

### Pilot Stat Improvements

As pilots gain ranks, their **piloting stat** increases, directly improving craft performance:

**Piloting Stat Bonus → Craft Performance:**
- **Speed**: (Piloting - 6) × 2% bonus
- **Accuracy**: (Piloting - 6) × 3% bonus
- **Dodge**: (Piloting - 6) × 2% bonus
- **Fuel Efficiency**: (Piloting - 6) × 1% bonus

**Example Progression:**
```
Rookie Pilot (Piloting 6): +0% bonuses
Veteran Pilot (Piloting 8): +4% speed, +6% accuracy, +4% dodge
Ace Pilot (Piloting 10): +8% speed, +12% accuracy, +8% dodge
Legendary Pilot (Piloting 12): +12% speed, +18% accuracy, +12% dodge
```

### Crew Experience Benefits

**Veteran Crews Provide:**
1. **Higher Craft Bonuses**: Better piloting stats = better craft performance
2. **Special Abilities**: Ace pilots unlock abilities (Evasive Maneuvers, Precision Strike)
3. **Fatigue Resistance**: Higher-rank pilots resist fatigue better (-10% fatigue per rank)
4. **Leadership**: Ace pilots provide morale bonuses to crew (+1 morale per rank above 2)

**No Craft Experience**: Crafts themselves do NOT gain experience or ranks. All progression belongs to the pilots operating them. Swapping pilots changes craft performance immediately.

### Base Defenders

**Important Note**: Base defense facilities and their operators do NOT gain pilot XP from base defense actions. Pilot XP is gained only through active craft-based interception missions.

---

## Base Defense Integration

**Facility-Based Defense**
Facilities with base defense capability contribute to interception:

**Defense System Usage**
- Base defense facilities automatically participate in interception
- Facilities provide same weapon/defense capabilities as craft
- Stationary positions provide accuracy/stability bonuses
- Unlimited energy capacity (bases rarely run out)

**Base vs. Craft Comparison**
| Attribute | Craft | Base |
|---|---|---|
| **Mobility** | High; can maneuver and evade | Static; cannot evade |
| **Energy** | Limited; must manage carefully | Virtually unlimited |
| **Hit Chance** | Degraded by movement | Enhanced by stability |
| **Experience Gain** | Yes; crews improve | No; bases do not advance |
| **Damage Range** | Limited by fuel constraints | Effectively unlimited |

**Assault Operations**
When player forces assault enemy alien bases during interception:
- Player craft engage enemy base defenses
- Base defensive weapons respond automatically
- Successful assault can disable or destroy enemy base
- Failure may force retreat to geoscape

---

## Biome & Environmental Effects

**Terrain Influence on Interception**
Province biome affects interception appearance and mechanics:

**Biome Effects**
- **Water/Ocean**: Water sector combat emphasized; naval units enhanced; air combat limited
- **Mountains**: Air sector advantages; ground sector combat in varied terrain
- **Forest**: Varied terrain; all combat types feasible; reduced visibility
- **Urban**: Ground sector emphasized; air combat restricted by structures
- **Desert**: Open engagement; all sectors fully functional; extreme visibility

**Visual Appearance**
- Interception background imagery matches province biome
- Tactical positioning reflects environmental features
- Biome may unlock specific mission types (underwater missions, mountain operations)

---

## Interception as Strategic Layer

**Position in Game Flow**
```
Geoscape → [Radar Detection] → Interception → [Victory/Defeat] → Battlescape or Return
                                                      ↓
                                                 [Outcome Determines]
                                                      ↓
                                          Player Win/Lose/Tactical Retreat
```

**Strategic Decision Points**
1. **Engagement Decision**: Commit to interception or let mission continue
2. **Loadout Selection**: Choose craft equipment for predicted enemy composition
3. **Tactical Positioning**: Arrange craft and bases in optimal sector arrangement
4. **Resource Allocation**: Decide which bases/craft to deploy
5. **Risk Assessment**: Evaluate potential losses vs. mission importance

**Long-Term Consequences**
- Damaged craft must be repaired (time & credits)
- Losses affect future military capability
- Successful interception gains experience for crews
- Multiple consecutive failures damage country relations

---

## Design Analogy

**Card Battle Game Comparison**
Interception resembles tactical card battle games at the strategic hero level:

- **Heroes**: Craft and bases (similar to card game heroes)
- **Armies**: Equipment and weapons (similar to card game units)
- **Resources**: Action Points and Energy Points (card game mana equivalent)
- **Tactics**: Sector positioning and weapon selection (card game deck building)
- **Tempo**: Turn-based engagement with action economy (card game turn structure)

The interception system abstracts mid-level combat into resource management and tactical selection, avoiding individual soldier-level micromanagement while maintaining strategic depth.




---
## Integration with Other Systems
Interception integrates with:
### Geoscape System
- UFO detection triggers interception opportunities
- Craft travel to intercept positions
- Successful interception prevents ground missions
### Crafts System
- Uses craft stats (speed, weapons, armor)
- Pilot skills affect combat effectiveness
- Craft equipment determines available actions
### Units System (Pilots)
- Pilot skills modify interception success
- Dual XP tracks (ground + flight)
- Ace pilots provide significant bonuses
### Missions System
- Failed interception leads to ground missions
- Successful interception generates salvage/rewards
- UFO crashes create battlefield missions
**For complete system integration details, see [Integration.md](Integration.md)**

## Examples

### Scenario 1: Basic Interception
**Setup**: Player craft engages UFO in air sector
**Action**: Uses weapon action, depletes energy points
**Result**: UFO damaged, mission prevented, salvage generated

### Scenario 2: Base Defense
**Setup**: UFO attacks player base with defenses active
**Action**: Turrets engage automatically, player can join combat
**Result**: UFO destroyed or repelled, base damage minimized

## Balance Parameters

| Parameter | Value | Range | Reasoning | Difficulty Scaling |
|-----------|-------|-------|-----------|-------------------|
| Action Points per Turn | 4 | 3-5 | Action economy balance | -1 on Hard |
| Energy Points per Turn | 3 | 2-4 | Resource management | -1 on Hard |
| Sector Capacity | 4 | 3-5 | Combat complexity | +1 on Hard |
| Weapon Cooldown | 2 turns | 1-3 | Tactical pacing | +1 on Hard |

## Difficulty Scaling

### Easy Mode
- Increased action/energy points (+1 each)
- Reduced enemy damage output
- More forgiving positioning requirements

### Normal Mode
- Standard action/energy allocation
- Balanced enemy capabilities
- Standard sector restrictions

### Hard Mode
- Reduced action/energy points (-1 each)
- Increased enemy effectiveness
- Stricter positioning rules

### Impossible Mode
- Minimum action/energy points
- Maximum enemy aggression
- Severe positioning penalties

## Testing Scenarios

- [ ] **Weapon Combat Test**: Fire weapons at enemy craft
  - **Setup**: Craft in same sector as UFO
  - **Action**: Use weapon action
  - **Expected**: Damage applied, energy consumed
  - **Verify**: Combat log shows correct calculations

- [ ] **Sector Movement Test**: Move between altitude sectors
  - **Setup**: Craft in air sector
  - **Action**: Use movement action to change sectors
  - **Expected**: Position updated, action consumed
  - **Verify**: Sector display reflects change

## Related Features

- **[Geoscape System]**: Mission detection and deployment (Geoscape.md)
- **[Crafts System]**: Vehicle capabilities and equipment (Crafts.md)
- **[Pilot System]**: Pilot skills and bonuses (Pilots.md)
- **[Items System]**: Weapons and equipment (Items.md)

## Implementation Notes

- Card-based combat mechanics using action/energy resources
- Three-dimensional sector system for positioning
- Turn-based resolution with simultaneous execution
- Integration with Battlescape for ground escalation

## Review Checklist

- [ ] Strategic environment defined
- [ ] Weapon mechanics documented
- [ ] Action/energy systems balanced
- [ ] Sector positioning clear
- [ ] Combat outcomes specified
- [ ] Experience system implemented
- [ ] Base defense integration complete
- [ ] Environmental effects included
