## Interception

### Overview

Interception is the tactical engagement layer positioned between the Geoscape (strategic) and Battlescape (tactical squad combat) levels. It represents mid-level military engagements between player craft/bases and enemy forces (UFOs, alien bases, missions). The interception system uses a card-game-like combat model featuring hero-level craft and base defenses engaging enemy objectives.

**Design Philosophy**
Interception bridges strategic deployment and tactical ground combat. It simulates aerial/orbital combat and base defense scenarios before the conflict escalates to ground-level battlescape. The system emphasizes resource commitment, positioning, and weapon selection over individual unit tactics.

---

### Strategic Environment

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

**Combat Formation**
- Player forces occupy left side of engagement screen
- Enemy forces occupy right side of engagement screen
- Sectors are independent but visible simultaneously
- Cross-sector targeting available with appropriate weapons

---

### Equipment & Weapon Systems

**Equipment Specialization**
Craft equipment determines available actions and tactical capabilities during interception. Equipment loadouts define what targets can be engaged.

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

### Weapon Mechanics

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

### Action Point System

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

### Energy Point System

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

### Object Capabilities

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

### Combat Model Simplification

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

### Object Deactivation

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

### Interception Outcomes

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

### Experience & Advancement

**Interception Experience**
- **Craft Crews**: Gain experience for participation in interception
- **Base Defenders**: Do NOT gain experience from base defense actions
- Experience rates based on: Damage dealt, enemies defeated, mission completion
- Crew experience improves accuracy, damage, and tactical capabilities over time

**Experience Applications**
- Improved hit chances for veteran crews
- Increased damage output
- Reduced weapon cooldowns
- Better energy management

---

### Base Defense Integration

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

### Biome & Environmental Effects

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

### Interception as Strategic Layer

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

### Design Analogy

**Card Battle Game Comparison**
Interception resembles tactical card battle games at the strategic hero level:

- **Heroes**: Craft and bases (similar to card game heroes)
- **Armies**: Equipment and weapons (similar to card game units)
- **Resources**: Action Points and Energy Points (card game mana equivalent)
- **Tactics**: Sector positioning and weapon selection (card game deck building)
- **Tempo**: Turn-based engagement with action economy (card game turn structure)

The interception system abstracts mid-level combat into resource management and tactical selection, avoiding individual soldier-level micromanagement while maintaining strategic depth.
	


