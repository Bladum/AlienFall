# Units System

> **Status**: Design Document  
> **Last Updated**: 2025-10-28  
> **Related Systems**: Battlescape.md, Items.md, Crafts.md, Pilots.md, Economy.md

## Table of Contents

- [Overview](#overview)
- [Unit Classification](#unit-classification)
- [Unit Recruitment](#unit-recruitment)
- [Unit Statistics](#unit-statistics)
- [Experience & Progression](#experience--progression)
- [Unit Inventory & Equipment](#unit-inventory--equipment)
- [Unit Traits](#unit-traits)
- [Transformations](#transformations)
- [Unit Roles & Specializations](#unit-roles--specializations)
- [Unit Health & Recovery](#unit-health--recovery)
- [Unit Morale & Psychology](#unit-morale--psychology)
- [Unit Customization & Individuality](#unit-customization--individuality)
- [Unit Cost & Maintenance](#unit-cost--maintenance)
- [Quick Reference Table](#quick-reference-table)
- [Design Philosophy](#design-philosophy)

---

## Overview

### Design Context

The Unit system is the foundation of tactical gameplay in AlienFall. Units represent individual soldiers, specialized operatives, and alien entities that form the backbone of combat operations. The system features a deep progression mechanic inspired by XCOM and Battle for Wesnoth, where units advance through experience-based ranks with branching specialization paths.

**Core Philosophy**: Units are persistent, valuable assets that grow stronger through combat experience. Player attachment and strategic planning around unit composition is essential to the game experience.

---

## Unit Classification

### Class System

Units are organized through a **class hierarchy** that represents both their role and their specialization level. The class system follows a **promotion tree** model where units progress through increasingly specialized paths.

#### Rank Structure

All units are categorized by **Rank**, representing their experience and specialization level:

| Rank | Experience Required | Description |
|------|-------------------|-------------|
| **Rank 0** | 0 XP | Basic/Conscript (recruit level, limited supplies) |
| **Rank 1** | 100 XP | Agent (trained operative, basic role assignment) |
| **Rank 2** | 300 XP | Specialist (role proficiency achieved) |
| **Rank 3** | 600 XP | Expert (significant specialization begins) |
| **Rank 4** | 1,000 XP | Master (advanced specialization) |
| **Rank 5** | 1,500 XP | Elite (peak specialization, rare) |
| **Rank 6** | 2,100 XP | Hero (unique, one per squad maximum) |

**Note**: Smart trait accelerates XP gain by +20%, while Stupid trait decelerates it accordingly.

#### Class Hierarchy

The class structure follows a three-tier progression within each faction:

- **Rank 0**: Base unit (e.g., Sectoid for alien faction, Conscript for humans)
- **Rank 1**: Role assignment (Soldier, Support, Leader, Scout, Specialist, **Pilot**)
- **Rank 2**: Role specialization (e.g., within Soldier: Rifleman, Grenadier, Gunner; within Pilot: Fighter Pilot, Bomber Pilot, Transport Pilot)
- **Rank 3**: Specialization begins (e.g., Sniper specialist training; Ace Fighter for pilots)
- **Rank 4**: Advanced specialization (e.g., Marksman with special abilities; Strategic Bomber for pilots)
- **Rank 5**: Master specialization (e.g., Legendary Sniper with unique bonuses; Master Pilot with fleet command)
- **Rank 6**: Hero class (e.g., Supreme Commander with faction-wide bonuses)

**Class Synergy**: Equipment and abilities scale with unit class. A unit of a lower class attempting to use Rank 4+ equipment suffers -30% accuracy penalty. Units trained in a class bonus matching their equipment receive +50% effectiveness (e.g., Medic using Medikit heals for +50%).


#### Rank Progression Requirements

**Unit Acquisition Tiers**:
- Rank 0 units: Available early, limited quantity, purchased as raw recruits
- Rank 1+ units: Require prerequisite facility levels and technology research
- Specialist ranks (2+): Require either promotion or specialist recruitment contracts

**Rank Limits** (enforced by squad depth):
- Rank 0: Unlimited quantity
- Rank 1: Unlimited quantity
- Rank 2: Minimum 3 Rank 1 units required in squad
- Rank 3: Minimum 3 Rank 2 units required (implies 9 Rank 1 minimum)
- Rank 4: Minimum 3 Rank 3 units required (implies 27 Rank 1 minimum)
- Rank 5: Minimum 3 Rank 4 units required (implies 81 Rank 1 minimum)
- Rank 6: Minimum 3 Rank 5 units required (implies 243 Rank 1 minimum); only **one hero per player**

**Starting Units**: Player-recruited units begin at Rank 1 with "Agent" class. Subsequent recruits may be purchased at Rank 0 for cheaper cost or higher ranks through specialist suppliers.

### Unit Type

Units are classified by their biological or mechanical nature, which determines maintenance and healing methods:

- **Biological**: Healed through medical facilities and medikit items. Subject to morale effects and panic.
- **Mechanical**: Repaired using maintenance facilities and repair kits. Immune to morale/panic but require specialized maintenance resources.

### Faction Association

Every unit belongs to a **faction** (Humans, Sectoids, Ethereals, etc.), but within the player's organization:
- **Race**: Humans (default for player forces; visual and cultural identity)
- **Alien Races**: Available through recruitment, alliance, or capture
- Races themselves provide no stat bonuses—all stat distribution is class-based

---

## Unit Recruitment

### Standard Recruitment

Recruits are typically acquired through the **Marketplace** at **Rank 1** as "Agent" class, the basic operative template. Standard recruitment is limited by marketplace availability and monthly budget.

### Specialized Recruitment

Access to specialized units unlocks through:

1. **Technology Research**: Unlock new supplier contracts for specialized operatives or unique ranks
2. **Supplier Relationships**: Establish relations with weapon dealers, mercenary groups, and underground networks
3. **Specialist Recruitment**: Hire operatives at Rank 2+ for premium costs
4. **Robot Manufacturing**: Unlock mechanical unit production through engineering research
5. **Resurrection Program**: Recover fallen units from corpse specimens (high resource cost, unpredictable outcomes)
6. **Black Market Access**: High-cost recruitment of elite or rare units; impacts faction relations and ethics score

### Recruitment Constraints

- **Fame/Reputation**: Negative karma may block access to legitimate suppliers
- **Supplier Relations**: Poor standing reduces recruitment options and increases costs
- **Facility Availability**: Limited barracks space restricts new unit acquisition
- **Economic Capacity**: Monthly budget limits recruitment quantity

---

## Unit Statistics

All units are defined by a core set of **stats** that determine combat effectiveness, utility, and survival. Base stat ranges for humans vary between 6-12, with aliens and specialists outside this range.

### Combat Statistics

#### Action Points (AP)
- **Base**: 4 per turn (fixed across all units in Battlescape)
- **Valid Range**: 1-4 AP per turn after all modifiers applied
  - **Minimum**: 1 AP (guaranteed, even at critical status)
  - **Maximum**: 5 AP (with positive modifiers - rare, exceptional)
- **Reduction Sources**:
  - Health <50%: -1 AP
  - Health <25%: -2 AP (cumulative with above)
  - Morale = 0 (panicked): -1 AP
  - Sanity <50%: -1 AP
  - Stun effect: -2 AP (loses entire turn)
- **Bonus Sources**:
  - Agile trait: +1 AP (requires Rank 2+)
  - Heroic Stimulant item: +1 AP (one-time use, risky)
  - Leadership aura: No direct bonus, but nearby allies inherit +1 morale
- **Modifiers**: Some traits, equipment, and special abilities impact AP
- **Usage**: Each action (move, shoot, throw, use item) costs AP (typically 1-2 AP per action)
- **Scope**: Battlefield-specific resource, resets each turn at Battlescape phase start
- **Edge Case**: If all penalty sources apply (panicked, low health, low sanity, stunned), total could drop below 1 - clamped to minimum 1 AP

**AP Calculation Example:**
```
Base AP: 4
- Health 40% (not <25%): -1 AP = 3 AP
- Morale 0 (panicked): -1 AP = 2 AP
- Sanity 60%: no penalty
- Special: Agile trait not equipped

Final AP: 2 AP per turn (within 1-4 range)
```

#### Movement Points
- **Base**: AP × Speed stat
- **Usage**: Alternative AP cost for movement based on terrain
- **Calculation**: Speed determines hexagons traversable per movement action
- **Affected By**: Armor weight, encumbrance, status effects (stunned, exhausted)

#### Health (Hit Points)
- **Range**: 6-12 base (biological units); 10-20 (mechanical units)
- **Damage**: Taken from weapon attacks, explosions, hazards
- **Healing**: Passive recovery +1 HP/week in base facilities; active healing through Medikit during battle
- **Death**: Unit is incapacitated when HP ≤ 0 (corpse recoverable if extraction possible)

#### Armor Value (Built-in)
- **Range**: 0-2 base armor from physiology
- **Bonus Armor**: Added through equipped armor items (+5 to +25)
- **Function**: Each armor point reduces incoming damage by 1 point
- **Type Resists**: Effective against Kinetic damage; less effective against Energy/Explosive/Hazard
- **Resistances**:
  - Kinetic: 0-50% reduction
  - Energy: 0-40% reduction
  - Hazard: 0-30% reduction

### Accuracy & Targeting

#### Aim Stat
- **Range**: 6-12
- **Effect**: Base accuracy for ranged weapons (ballistic, energy, thrown)
- **Modifiers**: Equipment accuracy bonuses, status effects, movement penalties
- **Min/Max**: Minimum 5% accuracy, maximum 95% accuracy after all modifiers

#### Melee Stat
- **Range**: 6-12
- **Effect**: Effectiveness in hand-to-hand combat, both attack and defense
- **Usage**: Melee attacks, dodging melee attacks, blocking with shields
- **Synergy**: Works with strength for determining damage bonus

#### React Stat
- **Range**: 6-12
- **Effect**: Triggers reaction fire when enemies act; chance to dodge incoming fire
- **Usage**: Overwatch trigger chance; defensive dodge chance when under fire
- **Synergy**: Works with speed for determining dodge effectiveness

### Movement & Awareness

#### Speed Stat
- **Range**: 6-12
- **Effect**: Movement distance per turn, rotation speed
- **Movement Cost**: Base cost is 2 MP per hex, MP = AP * Speed
- **Affected By**: Armor weight (-1 to -2 movement for heavy armor), status effects
- **Bonus**: Bonus movement from traits (e.g., Fast trait +2)

#### Piloting Stat
- **Range**: 0-100 (not 6-12 like other stats)
- **Effect**: When unit is assigned as pilot, provides bonuses to craft performance
- **Base**: 20-40 (random at recruitment)
- **Improved By**: XP gain (+1 per 100 XP), class bonuses, traits, equipment
- **Bonuses**: Craft Dodge = +(Piloting/5)%, Craft Accuracy = +(Piloting/5)%
- **See**: Pilots.md for complete piloting mechanics
- **Note**: Any unit can pilot, but higher Piloting = better craft performance

#### Sight Range
- **Base**: 16 hexagons (day), 8 hexagons (night)
- **Modifier**: +5 with superior optics, night vision goggles
- **Effect**: Reveals enemy positions and hazards within range
- **Cost**: Sight is a passive perception check; maintaining line-of-sight requires no AP
- **Terrain Modifiers**: Obscuring terrain (fog, smoke) reduces sight by -3 to -5 hexagons

#### Sense (Omnidirectional Detection)
- **Base**: 0 (humans lack innate sense)
- **Alien Ability**: Some alien species have innate sense ability
- **Effect**: Detects enemies regardless of line-of-sight; ignores cover
- **Usage**: Detects units, not terrain; useful for ambush detection
- **Modifier**: +5 hexagons with motion scanner equipment

#### Cover Bonus
- **Base**: 0 (in-built concealment)
- **Effect**: Reduces enemy line-of-sight range against this unit
- **Synergy**: Stealth armor and abilities provide +20% concealment
- **Usage**: Unit benefits from cover when partially obscured by terrain

### Morale & Psychological

**For Complete System Details**: See [MoraleBraverySanity.md](./MoraleBraverySanity.md)

#### Bravery Stat (Core Stat)
- **Range**: 6-12 (standard stat range)
- **Effect**: Determines starting morale in battle
- **Usage**: Represents inherent courage and fear resistance
- **Impact**: Higher bravery = larger morale pool, better panic resistance
- **Progression**: +1 per 3 ranks (experience-based growth)
- **Modifiers**:
  - Trait "Brave": +2 bravery
  - Trait "Fearless": +3 bravery (rare)
  - Officer gear: +1 bravery
  - Medal display: +1 per 3 medals

#### Morale (In-Battle System)
- **Range**: 0 to Bravery value (dynamic during combat)
- **Starting Value**: Equals Bravery stat at mission start
- **Degradation**: Combat stress reduces morale
- **Panic Threshold**: 0 morale = PANIC (unit loses all AP)
- **AP Penalties**:
  - 2 morale: -1 AP per turn
  - 1 morale: -2 AP per turn
  - 0 morale: All AP lost (cannot act)
- **Accuracy Penalties**:
  - 4-5 morale: -5% accuracy
  - 3 morale: -10% accuracy
  - 2 morale: -15% accuracy
  - 1 morale: -25% accuracy
  - 0 morale: -50% accuracy
- **Recovery**:
  - Rest action: 2 AP → +1 morale
  - Leader rally: 4 AP → +2 morale to target
  - Leader aura: +1 morale per turn (passive, within 8 hexes)
- **Reset**: Morale fully resets to Bravery value after mission

#### Morale Loss Events

| Event | Morale Loss | When It Occurs |
|-------|-------------|----------------|
| Ally killed (visible) | -1 | Within 5 hexes |
| Taking damage | -1 | Each hit received |
| Critical hit received | -2 | Per critical |
| Flanked by enemies | -1 | Per turn flanked |
| Outnumbered (3:1) | -1 | Per turn |
| New alien type | -1 | First encounter |
| Commander killed | -2 | Squad leader death |
| Night mission start | -1 | Mission begins at night |

#### Sanity Stat (Long-Term Psychological)
- **Range**: 6-12 (separate from morale)
- **Effect**: Long-term mental stability between missions
- **Persistence**: Does NOT reset between missions
- **Loss**: Drops AFTER mission based on trauma
  - Standard mission: 0 sanity loss
  - Moderate mission: -1 sanity
  - Hard mission: -2 sanity
  - Horror mission: -3 sanity
  - Night missions: additional -1
  - Ally deaths: -1 per death
  - Mission failure: -2
- **Recovery**: 
  - Base recovery: +1 per week
  - Temple facility: +1 additional per week (+2 total)
  - Medical treatment: +3 immediate (10,000 credits)
  - Leave/vacation: +5 over 2 weeks (5,000 credits)
- **Broken State** (0 sanity): Unit cannot deploy, requires treatment
- **Performance Impact**:
  - 7-9 sanity: -5% accuracy
  - 5-6 sanity: -10% accuracy, -1 morale start
  - 3-4 sanity: -15% accuracy, -2 morale start
  - 1-2 sanity: -25% accuracy, -3 morale start

#### Strategic Implications
- **Morale**: Managed during combat via Rest actions and leader support
- **Sanity**: Managed between missions via roster rotation and Temple facility
- **Interaction**: Low sanity reduces starting morale and adds accuracy penalties
- **Penalties Stack**: Morale + Sanity penalties are cumulative
- **Roster Size**: Recommend 2-3x squad size for rotation (sanity recovery)

### Special Abilities

#### Psi Stat (Psionic Power)
- **Range**: 2-12 (2 = weak psionic capability; 12 = master psionic)
- **Requirement**: Unlocked through research, special traits, or transformation
- **Usage**: Offensive psionic attacks, defensive shields, mind control
- **Equipment**: Psionic Amplifier (enables offensive psionics; +30 EP cost per use)
- **Defense**: Uses Psi stat to resist enemy psionic effects
- **Scaling**: Psi abilities gain +1 damage per 2 Psi points

#### Piloting Stat (Vehicle Operation)
- **Range**: 6-12 (human standard), 0-20 (alien/mechanical potential)
- **Default**: 6 (untrained personnel), 8-10 (trained pilot classes), 12+ (ace pilots)
- **Purpose**: Represents unit's ability to operate vehicles (crafts, tanks, aircraft) effectively
- **Usage**: Unit can be assigned as pilot/crew to craft; piloting stat provides bonuses to craft performance
- **Effect on Craft Performance**:
  - **Speed Bonus**: Each point above 6 = +2% craft speed
  - **Accuracy Bonus**: Each point above 6 = +3% craft weapon accuracy
  - **Dodge Bonus**: Each point above 6 = +2% craft dodge chance
  - **Fuel Efficiency**: Each point above 6 = +1% fuel efficiency
- **Example**: Piloting 10 (4 points above base) = +8% speed, +12% accuracy, +8% dodge, +4% fuel efficiency
- **Synergies**: 
  - Dexterity affects craft initiative (reaction time in interception)
  - Perception affects craft sensor range (detection radius)
  - Intelligence affects system management (power distribution efficiency)
- **Progression**: Increases through pilot class specialization and interception combat experience
- **Class Requirement**: Pilot classes (Fighter Pilot, Bomber Pilot, etc.) provide +2 to +5 piloting bonuses
- **Dual Role**: Units with high piloting can operate crafts during geoscape/interception and fight as soldiers in battlescape
- **Fatigue Effect**: Pilot fatigue (0-100) reduces effective piloting stat by up to 50% at maximum fatigue
- **Training**: Can be improved through base training facilities (+1 per 2 weeks in flight simulator)

**Design Philosophy**: Piloting represents distinct skill set (spatial awareness, reflex coordination, mechanical understanding) separate from infantry combat. High-piloting units are valuable for craft operation but may sacrifice ground combat specialization.

#### Wisdom (Intelligence)
- **Status**: Under design (intended for future implementation)
- **Potential Role**: Could represent tactical decision-making, research bonus, or ability learning speed
- **Reserved**: For future expansion

### Size Classification

Units occupy a single battle tile regardless of physical size, but size affects:

- **Barracks Storage**: Size 1 (normal) vs Size 2 (large) vs Size 4 (behemoth) affects squad capacity
- **Craft Capacity**: Larger units consume more crew/cargo slots
- **Armor Effectiveness**: Larger units receive +50% armor value due to increased mass

---

## Experience & Progression

### Experience Acquisition

Units gain experience through multiple channels:

#### Base Training
- **Passive Training**: +1 XP per week in barracks (no cost)
- **Active Training**: +1 to +3 XP per week (requires training facility, costs credits)
- **Smart Trait**: Accelerates XP gain by +20% across all sources
- **Stupid Trait**: Decelerates XP gain by -20%

#### Combat Experience
Experience awarded at end of battle for:

1. **Enemy Eliminations**: +5 XP per kill
2. **Damage Inflicted**: +0.5 XP per 10 damage dealt
3. **Enemy Spotting**: +2 XP per unique enemy spotted during mission
4. **Objectives Completed**: +10-50 XP per mission objective (varies)
5. **Wounds Sustained**: +1 XP per 5 damage taken (encourages frontline play)
6. **Mission Participation**: +10 XP just for completing the mission

#### Medals & Commendations
Earned through achievement conditions; each unit can earn each medal only once:

- **Survivor**: Survive 20 consecutive battles → +25 XP (one-time)
- **Destroyer**: Kill 100 enemies across all battles → +50 XP (one-time)
- **Sharpshooter**: Achieve 50 headshots (or crits on non-humanoids) → +40 XP (one-time)
- **Guardian**: Take 200 damage and survive → +30 XP (one-time)
- **Hero**: Complete mission objective solo → +100 XP (one-time)
- **Legendary**: Complete entire campaign without casualty → +200 XP (one-time, squad-wide)

**Medal Impact**: Medals are universal—not faction or class-specific. They reward strategic play and bravery.

### Rank Promotion

#### Promotion Mechanic
- **Location**: Promotion occurs in base facilities (Personnel Center or Barracks)
- **Trigger**: Automatic when XP threshold reached
- **Cost**: Free (no credits required)
- **Time**: Instant (occurs end-of-turn or during admin phase)
- **Timing**: Promotions are never calculated mid-battle; experience is awarded post-battle and promotions applied during next base phase

#### Choosing Specialization Path
When promoting to **Rank 2+**, the player selects the unit's new class from available **promotion branches**:

Example progression tree:
```
Rank 1: Agent
├─ Rank 2: Rifleman → Rank 3: Assault Specialist → Rank 4: Commando → Rank 5: Battle Master
├─ Rank 2: Support → Rank 3: Medic → Rank 4: Surgeon → Rank 5: Field Commander
└─ Rank 2: Specialist → Rank 3: Marksman → Rank 4: Sniper → Rank 5: Ghost Operative
```

**One-Time Choice**: Each promotion branch is permanent. Demoting a unit allows switching paths (see Demotion below).

### Class Requirements for Equipment

**Class Hierarchy in Equipment**:
- A unit of Class X may use equipment requiring Class X
- A unit of Class Y (descended from X through promotion tree) may use equipment requiring Class X
- Example: Commando (Rank 4) may use Rifleman (Rank 2) equipment; Rifleman cannot use Commando equipment

**Class Mismatch Penalty**: Using equipment from a class path the unit never trained in: **-30% accuracy, -1 movement**

### Demotion System

Units can voluntarily demote to explore alternate specialization paths:

**Demotion Rules**:
- Unit drops one rank level (Rank 4 → Rank 3)
- Unit retains 50% of current XP (1,000 XP → 500 XP at demote)
- Unit loses specialization; Rank 2+ rank choice opens new branches
- **Cost**: Free but requires one week in barracks to retrain
- **Use Case**: Allows strategic pivoting without abandoning experienced units

Example: A Rank 4 Sniper (1,000 XP) demoting to Rank 3 would retain 600 XP as a generic Specialist, then choose to promote into a different Rank 4 path (e.g., Medic)

---

## Unit Inventory & Equipment

### Capacity System

**Inventory Capacity**:
- Each unit has **Strength stat-based capacity** (6-12, representing carrying capacity)
- Total item weight cannot exceed capacity, or unit cannot carry the load
- **Binary System**: Unit either carries all items or cannot carry them at all—no partial equipping

### Equipment Slots

Units have **3 primary equipment slots**:

1. **Primary Weapon**: Rifle, Pistol, Grenade Launcher, Heavy Cannon, etc.
2. **Secondary Weapon**: Backup weapon, grenades, or utility item
3. **Armor**: Body armor, environmental suit, or specialized protective gear

**Slot Modifications**:
- Some traits, wounds, or transformations may reduce available slots
- In-built weapons (mechanical units) may occupy slots permanently
- Grenades and consumables can occupy secondary weapon slot

### Weapon Categories

All items that can be wielded as weapons:

#### Ranged Weapons
- **Pistol**: 8-hex range, 1 AP, 12 base damage, 70% accuracy, 5 EP cost
- **Rifle**: 15-hex range, 2 AP, 18 base damage, 70% accuracy, 8 EP cost
- **Sniper Rifle**: 25-hex range, 3 AP, 35 base damage, 85% accuracy, 12 EP cost
- **Shotgun**: 3-hex range, 2 AP, 45 base damage, 60% accuracy, 10 EP cost, 3-hex area blast
- **Grenade Launcher**: 12-hex range, 2 AP, 30 area damage, 65% accuracy, 15 EP cost
- **Heavy Cannon**: 20-hex range, 3 AP, 60 base damage, 55% accuracy, 20 EP cost (Specialist requirement)

#### Melee Weapons
- **Knife**: 1-hex range, 1 AP, 8 base damage, 8 melee to hit, infinite energy
- **Sword**: 1-hex range, 1 AP, 15 base damage, 10 melee to hit, infinite energy
- **Plasma Blade**: 1-hex range, 1 AP, 25 base damage (Specialist requirement), 12 melee to hit, 8 EP cost

#### Thrown Weapons
- **Grenade**: 1 AP, 30 area damage, 3-hex radius blast, uses Aim stat
- **Incendiary Grenade**: 1 AP, 20 damage + fire DoT, 3-hex radius
- **Smoke Grenade**: 1 AP, creates 3-hex smoke area (blocks vision), 2-turn duration
- **Flashbang**: 1 AP, stuns enemies in 2-hex radius for 1 turn, 2 AP cost to act while stunned
- **Flashlight**: Handheld torch, +2 night vision, no AP cost to equip

#### Support Weapons
- **Psionic Amplifier**: 1 AP to activate, enables psionic attacks, 30 EP per attack
- **Stun Baton**: 1 AP, 10 damage + 50% stun chance, 5 EP cost, no range requirement
- **EMP Grenade**: 1 AP, disables mechanical units in 3-hex area for 1 turn

#### Medical Equipment
- **Medikit**: 5 charges, 1 AP per use, heals 25 HP (Medic) or 15 HP (non-Medic), 1 per unit
- **Stimulant Injector**: 1 AP, restores 10 HP and +2 morale, costs 50 credits

#### Utility Equipment
- **Motion Scanner**: +3 sight range, 50-turn battery, 1 AP to activate
- **Night Vision Goggles**: +5 night vision, 100-turn battery, passive when equipped
- **Repair Kit**: Repairs mechanical units, 25 HP per use, 3 charges
- **Scope Attachment**: +20% accuracy for aimed shots, can attach to any rifle

### Armor Categories

All items worn as body armor. Armor provides Armor Value (damage reduction), movement/AP modifiers, accuracy bonuses/penalties, and damage type resistances. Armor Value: 1 point = 1 damage reduction.

#### Standard Armor Types

| Armor Type | Armor Value | Movement Penalty | AP Penalty | Accuracy | Cost | Special |
|-----------|-----------|------------------|-----------|----------|------|---------|
| **Light Scout** | +5 | +1 hex/turn | 0 | +5% | 8K | Mobility-focused; no penalties |
| **Combat Armor** | +15 | -1 hex/turn | -1 AP | -5% | 15K | Balanced; standard protection |
| **Heavy Assault** | +25 | -2 hex/turn | -2 AP | -10% | 25K | Max protection; mobility cost |
| **Hazmat Suit** | +10 | 0 | 0 | -5% | 12K | +100% poison/hazard resistance |
| **Stealth Suit** | +8 | 0 | 0 | Normal | 20K | +20% concealment/stealth |
| **Medic Vest** | +8 | 0 | 0 | Normal | 10K | +50% medikit healing effectiveness |
| **Sniper Ghillie** | +10 | -1 hex/turn | 0 | +10% | 18K | +1 sight range; marksman-optimized |

#### Armor Classification

**Armor Weight Categories**:
- **Light armor** (Scout): 0 movement penalty, 0 AP penalty
- **Medium armor** (Combat): -1 hex/turn movement, -1 AP/turn
- **Heavy armor** (Assault): -2 hex/turn movement, -2 AP/turn, -5% accuracy penalty
- **Specialized armor** (Hazmat/Stealth/Medic/Sniper): Varies by type

#### Damage Type Resistances

Different armor types provide varying resistances to damage types:

**Armor Resistance Ranges**:
- Kinetic: 0-50% reduction
- Energy: 0-40% reduction  
- Hazard (poison/chemical): 0-30% reduction

**Resistance-Bearing Armor**:
- **Ablative Armor**: -50% explosive damage; degrades 10% per explosive hit (temporary defense)
- **Reactive Armor**: -40% explosive, -20% kinetic (reactive tiles absorb impact)
- **Energy Shield** (power-dependent): -50% all damage types; requires fuel/energy to regenerate
- **Standard Armor**: No special resistances; base Kinetic reduction only

### Inventory Management

**Weight Capacity**: Based on unit's Strength stat (6-12)
- Strength 6 = 6 item capacity
- Strength 12 = 12 item capacity
- Each weapon = 1-2 weight units
- Each armor = 2-3 weight units
- Each utility item = 0.5-1 weight unit

**Overflow Penalty**: Carrying beyond capacity inflicts +5% maintenance costs per overflow unit (representing damage from overexertion)

**Quick-Access System**: Unused inventory slots can hold ammunition, consumables, or mission-specific items

---

## Unit Traits

### Trait System

**Traits** are permanent modifiers assigned to units during recruitment or advancement. Each unit can possess **multiple traits**, balanced by point value.

### Trait Mechanics

**Trait Point Value**:
- Each trait has a point cost (positive traits cost 1-2 points, negative traits refund 1-2 points)
- **Units have exactly 4 trait points available** to spend on positive traits or save via negative traits
  - Starting trait points: 4 (all units recruit at full allocation)
  - Minimum: Units can drop to 0 points by taking enough negative traits
  - Maximum: 4 points (fixed cap, cannot exceed)
- Positive traits (speed +2, strong +2) **consume points** from the 4-point pool
- Negative traits (fragile -1 HP, clumsy -1 accuracy) **refund points** back into the pool (up to 4 max)
- Example builds:
  - Tank: Fast (1) + Strong (1) + Brave (2) = 4 points used
  - Scout: Fast (1) + Sharp Eyes (1) + Lucky (1) + Stupid (-1 refunded) = 3 points used, 1 point available
  - Budget: Coward (-1 refunded) + Fragile (-1 refunded) + Stupid (-1 refunded) = 6 points available but still capped at 4 max

**Scope**: Traits are assigned at unit recruitment and cannot be changed without special interventions (transformation, research)

**Trait Point Constraints by Rank**:
- **Rank 0 (Recruit):** 4 points available, can only pick traits without rank requirement
- **Rank 2+:** Unlock Rank 2 traits (e.g., Agile, Leader, Brave)
- **Rank 4+:** Unlock Rank 4 traits (e.g., Legendary traits - if implemented)

**Trait Synergies & Conflicts**:
- Smart + Stupid: **Mutually exclusive** (cannot have both)
- Leader + Brave: Strong synergy (creates squad anchor unit)
- Psychic + Research: Psionic requires both trait purchase AND "Psionic Research" tech unlock


### Positive Traits

| Trait | Effect | Point Cost | Requirements |
|-------|--------|------------|--------------|
| **Fast** | Speed +2 | 1 | Any |
| **Strong** | Strength +2 | 1 | Any |
| **Agile** | Action Points +1 | 2 | Rank 2+ |
| **Sharp Eyes** | Sight +2 hexagons | 1 | Any |
| **Smart** | XP Gain +20% | 1 | Any (conflicts with Stupid) |
| **Loyal** | Salary -50% | 1 | Any |
| **Leader** | Morale Aura +1 (allies in 3-hex radius gain +1 morale) | 2 | Rank 2+ |
| **Brave** | Panic immunity until morale ≤ 0 | 2 | Rank 2+ |
| **Sharpshooter** | Accuracy +10% | 1 | Any |
| **Bloodthirsty** | Melee damage +5 | 1 | Any |
| **Psychic** | Unlocks psionic abilities (base psi stat 5) | 2 | Research required |
| **Lucky** | +10% critical hit chance (if crits exist) | 1 | Any |

### Negative Traits

| Trait | Effect | Points Refunded | Restrictions |
|-------|--------|-----------------|--------------|
| **Fragile** | Health -2 | 1 | Prevents Heavy Armor |
| **Clumsy** | Accuracy -10%, Speed -1 | 1 | None |
| **Stupid** | XP Gain -20% | 1 | Conflicts with Smart |
| **Coward** | Morale penalty -2, panic threshold +1 | 1 | Rank 1-2 only |
| **Pacifist** | Damage -25% (ideological penalty) | 2 | Ethical restriction |
| **Weak** | Strength -2 (carry capacity reduced) | 1 | Limits heavy weapons |
| **Stubborn** | Cannot be demoted/promoted normally | 2 | Permanent choice |

### Trait Requirements & Synergies

**Class Requirements**: Some traits are locked to specific classes or ranks
- Example: "Leader" trait requires Rank 2+ and leadership-class specialization

**Race Requirements**: Some traits may be faction or race-restricted
- Example: "Alien Biology" trait only available to alien units

**Synergies**: Traits can interact:
- Smart + XP boost from medals creates rapid advancement
- Leader + Brave combo creates valuable squad anchors
- Psychic + Psi stat improves psionic effectiveness

---

## Transformations

### Transformation System

**Transformations** are permanent surgical or biological modifications that fundamentally alter a unit.

**Rules**:
- Each unit can undergo **exactly one transformation** (permanent, irreversible)
- Transformations are either **Biological** or **Mechanical**
- Transformations can modify stats, unlock new abilities, or change equipment slots
- Transformations are difficult, require high-level research, and are expensive

### Transformation Categories

#### Biological Transformations

| Transformation | Stat Bonus | Cost | Requirements | Effects |
|---|---|---|---|---|
| **Combat Augmentation** | Speed +2, Aim +2 | 5,000 credits | Rank 3+, Biology Lab | Standard combat enhancement |
| **Psionic Awakening** | Psi +5, Sanity -2 | 8,000 credits | Rank 3+, Psi Lab | Enables psionic abilities |
| **Berserker Protocol** | Strength +3, Health +3, Aim -1 | 6,000 credits | Rank 3+, Combat Lab | Melee-focused enhancement |
| **Enhanced Perception** | Sight +3, Sense +2, Speed +1 | 7,000 credits | Rank 2+, Sensory Lab | Scout/Recon enhancement |
| **Regeneration** | Health Regen +2/turn in battle | 10,000 credits | Rank 4+, Gene Lab | Passive healing during combat |

#### Mechanical Transformations

| Transformation | Stat Bonus | Cost | Requirements | Effects |
|---|---|---|---|---|
| **Cyborg Framework** | Strength +2, Speed +1, Armor +2 | 8,000 credits | Rank 3+, Robotics Lab | Hybrid human-machine |
| **Full Mechanization** | Health +5, Armor +5, Morale immune | 15,000 credits | Rank 4+, Advanced Robotics | Becomes full robot (no morale/sanity) |
| **Targeting System** | Accuracy +15%, Aim +2 | 6,000 credits | Rank 2+, Targeting Lab | Precision enhancement |
| **Kinetic Absorption** | Kinetic Resistance +30%, Speed -1 | 7,000 credits | Rank 3+, Defense Lab | Absorbs impact damage |

### Transformation Effects on Equipment

**Equipment Slot Changes**:
- Some transformations disable equipment slots (e.g., Full Mechanization doesn't allow armor swapping)
- Others unlock new slots (e.g., Cyborg Framework allows equipment-less operation)
- Transformation weapons are built-in and cannot be swapped

**Stat Interactions**: Transformation bonuses stack with trait bonuses and equipment bonuses

### Transformation Recovery & Reversal

- Transformations are **permanent and irreversible**
- No refund of transformation credits upon unit removal
- Transformed units cannot be cloned or resurrected; the transformation data is lost

---

## Unit Roles & Specializations

### Combat Roles

Based on class and rank, units fill different battlefield roles:

#### Soldier
- **Primary**: General combat, adaptable
- **Strengths**: Balanced stats, flexible equipment
- **Progression**: Rifleman → Assault Specialist → Commando

#### Support
- **Primary**: Healing, buffing, utility
- **Strengths**: Medical abilities, morale bonuses
- **Progression**: Medic → Combat Medic → Field Surgeon

#### Scout
- **Primary**: Reconnaissance, high movement
- **Strengths**: Speed, sight range, light armor
- **Progression**: Scout → Ranger → Ghost Operative

#### Specialist
- **Primary**: Heavy weapons, area control
- **Strengths**: High damage, area effects
- **Progression**: Grenadier → Heavy Specialist → Demolitions Expert

#### Leader
- **Primary**: Command, morale, squad support
- **Strengths**: Leadership aura, decision-making bonuses
- **Progression**: Squad Leader → Commander → Legendary Commander

### Role Customization

Players can mix and match traits, equipment, and specializations to create hybrid roles:
- Agile Specialist (Scout + Heavy Weapons for unique mobility)
- Melee Combat Medic (Support role with close-range healing)
- Recon Soldier (Soldier class with Scout equipment and traits)

---

## Unit Health & Recovery

### Health Management

**Passive Recovery**:
- +0 HP per turn in battle (no passive healing)
- +1 HP per week in barracks
- +3 HP per week in Medical Facility

**Active Recovery**:
- Medikit use: 3 HP (Medic class) or 2 HP (other classes), 5 charges per kit
- Surgical facility: Instant full healing, costs 50K
- Stimulant injection: +1 HP, one-time use item

### Wound System

Severe damage can cause **permanent wounds**:
- Critical hit while at <3 HP: Wound inflicted
- Wound reduces max HP by -1 permanently until healed surgically
- Multiple wounds can reduce a unit's max HP to dangerous levels
- Surgical facility can remove wounds (heals max HP): 300 credits per wound

### Death & Extraction

**Unit Death**:
- HP drops to 0 → Unit is incapacitated
- If unit is not evacuated within 3 turns, unit is **permanently lost**
- Enemy captures unit after 5 turns (prisoner status)

**Extraction**:
- Requires friendly unit to perform Rescue action (1 AP, move to incapacitated unit)
- Rescued unit is carried to extraction zone
- Extraction vehicle transports rescued units back to base

**Corpse Recovery**:
- Dead unit becomes a resource item (Corpse)
- Can be used in Resurrection protocols for significant cost
- Resurrection success rate: 60-80% (varies by facility quality)

---

## Unit Morale & Psychology

### Morale Mechanics

**Morale Tracking**:
- Each unit has **current morale** (0-10 scale, in battle)
- Bravery stat determines starting morale (base 5 + ½ Bravery)
- Morale changes during battle based on events

**Morale Events**:

| Event | Morale Change | Scope |
|-------|---------------|-------|
| Unit kills enemy | +2 morale | Killer only |
| Friendly unit dies | -1 to -4 (rank-based) | All nearby units |
| Friendly unit wounded critically | -1 morale | All nearby units |
| Leader dies | -2 morale (always), -4 (if visible) | All units in squad |
| Secure objective | +1 morale | Objective team |
| Escape danger/cover taken | +1 morale | Unit entering cover |
| Surrounded (enemies in 360°) | -1 morale | Surrounded unit per turn |

**Panic Mechanics**:
- When morale drops ≤ 2: Unit enters **Panic** state
- Panicked unit: Cannot use ranged weapons (-100% accuracy), must move away from threats (AI-controlled)
- Panic duration: Until morale recovers to >3 or unit takes damage (gains +1 morale upon taking damage)

### Sanity System

**Sanity Degradation**:
- Witnessing alien transformations: -1 Sanity
- Witnessing brutal kills/executions: -1 Sanity
- Surviving a near-death experience: -1 Sanity
- Psychological horror environments (alien hives, dimensional rifts): -1 per turn in exposure

**Low Sanity Effects**:
- Sanity ≤ 3: Unit takes +1 damage from psionic attacks
- Sanity ≤ 1: Unit has -15% accuracy, -2 morale
- Sanity 0: Unit becomes "broken" and must be reassigned (unusable in combat until recovered)

**Sanity Recovery**:
- Rest in barracks: +1 per week
- Psychiatric session (facility): +2-3 per session, costs 100 credits
- Combat success: +1 upon mission completion
- Promotion: +2 upon achieving new rank

---

## Unit Customization & Individuality

### Face & Appearance System

**Character Customization**:
- Player-controlled units have **individualized appearances**
- Options for humans: 4 skin tones × 2 genders × 8 face variants = **64 unique face combinations**
- Each unit retains the same face throughout their career

**Visual Identity**:
- Armor color customization (cosmetic, no gameplay effect)
- Personal insignia/markings unlocked through medals
- Named units displayed with their custom name and rank insignia

**Future Expansions**:
- Alien race faces (Sectoid, Ethereal, Muton variants)
- Robot visual customization (chassis color, design variants)
- Cosmetic cosmetic customization slots (hats, scarves, emblems)

### Unit Naming

- Player assigns custom name at recruitment
- Names are displayed in combat HUD and base UI
- Unit nickname earned through medals/achievements

### Personal Statistics

Each unit tracks:
- Mission count (total battles participated)
- Enemy kills (cumulative)
- Damage dealt (cumulative)
- Damage taken (cumulative)
- Wounds received (total, some permanent)
- Commendations earned (medals, promotions)
- Squad assignment history
- Favorite weapon/equipment choice

---

## Unit Cost & Maintenance

### Recruitment Cost

| Unit Rank | Cost | Training Time | Availability |
|-----------|------|---------|------|
| **Rank 0 (Recruit)** | 500 credits | 1 week | Marketplace |
| **Rank 1 (Agent)** | 800 credits | Immediate | Marketplace |
| **Rank 2 (Specialist)** | 2,000 credits | 2 weeks | Specialist suppliers |
| **Rank 3 (Expert)** | 5,000 credits | 3 weeks | Elite suppliers |
| **Rank 4+ (Master)** | 10,000+ credits | 4 weeks | Rare/black market |

### Maintenance Cost

**Monthly Salary**:
- Base cost per unit per month: 200 credits
- Loyal trait: -50% salary (100 credits)
- High rank units: Higher salary (Rank 3+ = 300 credits, Rank 5+ = 500 credits)
- Mechanical units: -50% salary (electronics cheaper than food)

**Facility Costs**:
- Barracks (base cost): included in monthly upkeep
- Advanced barracks: +50 credits per unit per month (faster recovery)
- Medical facility: +100 credits per unit per month (passive healing available)

### Budget Impact

- Early game: 4-6 units × 200-300 credits = 800-1,800 credits/month maintenance
- Mid game: 12-16 units × average 300 credits = 3,600-4,800 credits/month
- Late game: 20+ units × 300-500 credits = 6,000-10,000+ credits/month

---

## Quick Reference Table

| Aspect | Details |
|--------|---------|
| **Stat Ranges** | 6-12 (humans); 0-20 (specialized) |
| **Rank Progression** | Rank 0 (0 XP) → Rank 6 (2,100 XP hero) |
| **Equipment Slots** | 2 weapons, 1 armor (3 total) |
| **Inventory Capacity** | Equal to Strength stat (6-12) |
| **Action Points** | 4 per turn (fixed, modifers possible) |
| **Morale Range** | 0-10 (in battle); Panic ≤ 2 |
| **Traits per Unit** | Multiple traits up to point value 2-4 |
| **Transformations** | 1 per unit, permanent, irreversible |
| **Monthly Salary** | 200 credits base; varies by rank |
| **Max Squad Size** | Rank-limited (see Rank Limits section) |
| **Recovery Time** | 3-7 days in barracks (depends on wounds) |

---

## Pilot System

### Overview

Pilots are specialized military personnel who operate aircraft and helicopters. Unlike ground troops, pilots are recruited and managed as individuals with persistent progression throughout the campaign. Pilots gain experience through interception missions and can rank up to improve both their personal stats and the performance of their assigned craft.

### Pilot Classification

Pilots are classified by the type of aircraft they operate:

| **Pilot Class** | **Craft Type** | **Specialization** | **Recruitment Cost** | **Monthly Salary** |
|---|---|---|---|---|
| **Fighter Pilot** | Fighter Interceptor | Air-to-air combat, dogfighting | 800 credits | 150 credits |
| **Bomber Pilot** | Bomber/Transport | Long-range missions, cargo ops | 700 credits | 140 credits |
| **Helicopter Pilot** | Attack Helicopter | Close air support, reconnaissance | 750 credits | 145 credits |
| **Rookie Pilot** | Any (on assignment) | Unspecialized, fresh recruit | 500 credits | 100 credits |

### Pilot Progression System

#### Experience Gain

Pilots gain experience through successful interception missions:

- **Per Mission Completion**: 5 XP (baseline)
- **Bonus XP**: +2 XP for each enemy UFO destroyed by the pilot's craft
- **Mission Difficulty Scaling**: Higher-class UFOs provide bonus multiplier (Scouter ×1, Fighter ×1.5, Cruiser ×2)

#### Rank System

Pilots progress through three distinct ranks, gaining cumulative stat bonuses:

| **Rank** | **XP Threshold** | **SPEED Bonus** | **AIM Bonus** | **REACTION Bonus** | **Title Modifier** |
|---|---|---|---|---|---|
| **Rookie (0)** | 0 XP | — | — | — | "Rookie" |
| **Veteran (1)** | 50 XP | +1 | +2 | +1 | "Veteran" |
| **Elite (2)** | 150 XP | +2 | +4 | +2 | "Elite" |

#### Stat Bonus Application

- Bonuses accumulate across ranks (Rank 2 gets both Rank 1 and Rank 2 bonuses)
- Bonuses apply to the pilot's personal unit when selected in squad
- Bonuses apply to assigned craft performance (see Craft Bonuses section)
- Multiple pilots in same craft stack bonuses (up to 3 crew slots per craft)

### Craft Assignment & Bonuses

#### Pilot Slots vs. Crew Slots

Each aircraft has two types of slots:

| **Slot Type** | **Quantity** | **Purpose** | **Bonus Application** |
|---|---|---|---|
| **Pilot Slot** | 1 (primary) | Main aircraft operator | Applies full stat bonus to craft |
| **Crew Slots** | 2-3 (varies) | Secondary staff (co-pilot, weapons officer, etc.) | Each applies 50% stat bonus |

#### Craft Performance Bonus Formula

Pilot contribution to craft stats is calculated as:

```
Bonus% = (Pilot_Stat - 5) / 100 × 100
```

Example: Pilot with AIM 7 applying to Interceptor
- Bonus = (7 - 5) / 100 = 0.02 = +2% accuracy bonus

Multiple pilots stack multiplicatively:
- Pilot 1 (AIM 7): +2% accuracy
- Pilot 2 (AIM 6): +1% accuracy
- Combined: +3% accuracy

#### Specialist Pilot Types

Certain pilots excel in specific roles:

| **Specialist** | **Craft Type** | **Starting Bonus** | **Progression** |
|---|---|---|---|
| Dogfighter | Fighter Interceptor | +1 AIM | Gains +1 AIM per rank (total +3 at Rank 2) |
| Bomber Expert | Bomber/Transport | +1 SPEED | Gains +1 SPEED per rank (total +3 at Rank 2) |
| Scout Master | Helicopter | +1 REACTION | Gains +1 REACTION per rank (total +3 at Rank 2) |

### Pilot Management

#### Recruitment

- Available in basescape facility: **Officer's Quarters**
- Recruitment screen shows available pilot class and starting stats
- Randomized within stat ranges per pilot class

#### Rest & Recovery

- Pilots require mandatory rest after 3 consecutive missions
- Reduced performance if fatigued (-10% accuracy, -5% evasion)
- Rest in quarters recovers fatigue

#### Removal from Service

- Pilots can be dismissed (refund: 50% recruitment cost)
- Pilot death in interception is permanent loss
- Promotions create narrative moments (rankup event)

### Pilot Design Philosophy

The Pilot system serves distinct strategic purposes:

1. **Persistent Individual Investment**: Unlike expendable ground troops, pilots develop personal histories and represent permanent assets
2. **Long-term Progression**: XP-based ranking creates reward for veteran pilots and motivation to keep experienced pilots alive
3. **Craft Specialization**: Pilot-craft pairing creates emergent strategy (specialized pilots for high-value missions)
4. **Narrative Depth**: Named pilots with ranks and specializations create storytelling opportunities
5. **Economic Balance**: High-value pilots justify expensive interception facilities and represent ongoing operational cost
6. **Asymmetric Resource**: Pilots require training time and cannot be "bought" like equipment; they must be developed

---

## Perks System

### Overview

Perks are behavioral modifications, training enhancements, and psychological conditioning that customize unit abilities beyond base class capabilities. Both soldiers and pilots can receive perks through training, events, or special circumstances. Perks represent specific tactical advantages or roleplay elements that make units feel unique and memorable.

### Perk Categories

Perks are organized into eight functional categories:

| **Category** | **Function** | **Examples** | **Typical Effect** |
|---|---|---|---|
| **Basic** | Foundational traits | "Well Trained", "Hardened" | +Stat bonuses, +morale |
| **Combat** | Weapon & accuracy | "Crack Shot", "Headshot Specialist" | +Damage, +accuracy in conditions |
| **Movement** | Mobility & positioning | "Fleet Footed", "Sprinter" | +Movement range, +speed |
| **Defense** | Protection & survival | "Iron Skin", "Bulletproof Intuition" | +Armor, +dodge, damage reduction |
| **Special** | Unique abilities | "Leader", "Medic" | Squad effects, healing abilities |
| **Resistance** | Status immunities | "Iron Lungs", "Toxin Resistant" | Immune/resistant to specific effects |
| **Skill** | Specialized knowledge | "Technician", "Scout" | Interact with objects, detect enemies |
| **Trait** | Personality/background | "Veteran", "Survivor" | Roleplay elements, narrative hooks |

### How Perks Work

#### Perk Assignment

- Perks are assigned to unit classes during recruitment
- Individual units can override defaults during squad setup
- Perks persist on unit even after equipping different gear
- Perks are tied to the unit, not the equipment

#### Perk Activation

- Perks are **always active** unless disabled by special event
- Some perks activate conditionally (e.g., "Ambush Expert" only in ambush missions)
- Combat perks check conditions before applying effect
- UI displays active perks on unit summary

#### Perk Stacking

- Multiple perks on same unit stack their effects
- Contradictory perks cancel each other (cannot have both "Brave" and "Coward")
- Same perk cannot be applied twice
- Perk combinations enable unique synergy builds

### Common Perk Reference

#### Basic Perks (General Training)

| **Perk** | **Effect** | **Default Classes** |
|---|---|---|
| Well Trained | +10% accuracy, +1 AIM stat | Soldier, Officer |
| Hardened | +15% morale resistance | Soldier, Veteran |
| Alert | +1 REACTION stat, easier to spot ambush | Scout, Pilot |
| Steady Aim | +5% accuracy at range | Sniper, Sharpshooter |
| Quick Reflexes | +1 SPEED stat | Scout, Infiltrator |

#### Combat Perks (Offensive)

| **Perk** | **Effect** | **Default Classes** |
|---|---|---|
| Crack Shot | +15% accuracy with rifles | Sharpshooter, Sniper |
| Headshot Specialist | +50% crit damage on headshots | Sniper, Assassin |
| Close Quarters Combat | +20% accuracy with melee, +1 damage | Assault, Berserker |
| Suppressive Fire | Enemies in target area suffer -20% accuracy | Heavy Weapons |
| Ricochet Shot | Bullets can pierce thin walls | Sniper, Marksman |

#### Movement Perks (Mobility)

| **Perk** | **Effect** | **Default Classes** |
|---|---|---|
| Fleet Footed | +2 movement range | Scout, Infiltrator |
| Sprinter | +1 SPEED stat, can dash | Scout, Athlete |
| Acrobatics | No falling damage, +movement over obstacles | Scout, Infiltrator |
| Sneaker | +30% stealth when not moving | Infiltrator, Spy |
| Long Stride | Movement doesn't trigger overwatch | Scout, Ranger |

#### Defense Perks (Protection)

| **Perk** | **Effect** | **Default Classes** |
|---|---|---|
| Iron Skin | +20% armor | Tank, Heavy Soldier |
| Bulletproof Intuition | 20% chance to dodge incoming shots | Veteran, Officer |
| Pain Suppression | Injuries don't reduce accuracy | Veteran, Soldier |
| Reinforced Armor | Additional armor layer (similar to Heavy Armor) | Tank, Juggernaut |
| Evasion Expert | +15% evasion stat | Scout, Infiltrator |

#### Special Perks (Squad Effects)

| **Perk** | **Effect** | **Default Classes** |
|---|---|---|
| Leader | Squad accuracy +5%, morale +1 | Officer, Commander |
| Medic | Can heal allies (10 HP per action) | Support, Medical |
| Motivator | Nearby allies gain +1 morale | Officer, Sergeant |
| Discipline | Nearby allies resist panic (20% better) | Officer, Sergeant |
| Scout Master | Reveals hidden enemies in area | Scout, Intel Officer |

#### Resistance Perks (Status Immunity)

| **Perk** | **Effect** | **Default Classes** |
|---|---|---|
| Iron Lungs | Immune to gas/poison | Support, Hazmat |
| Toxin Resistant | 50% damage reduction from poison | Engineer, Scientist |
| Cold Blooded | Immune to panic from alien presence | Veteran, Psychic |
| Thick Skull | +50% resistance to stun effects | Tank, Heavy Soldier |
| Disease Resistant | Immune to infection/mutation | Support, Medical |

#### Skill Perks (Specialized Knowledge)

| **Perk** | **Effect** | **Default Classes** |
|---|---|---|
| Technician | Can hack computers, disable bombs | Engineer, Hacker |
| Lockpick | Can open locked doors/containers | Infiltrator, Spy |
| Medic Training | Can perform field surgery (+20 HP) | Support, Medical |
| Archaeologist | Can identify ancient artifacts | Scientist, Explorer |
| Linguist | Can communicate with aliens (reduces aggression) | Diplomat, Scientist |

#### Trait Perks (Personality & Background)

| **Perk** | **Effect** | **Default Classes** |
|---|---|---|
| Survivor | +20% health, permanent aura of determination | Veteran |
| Coward | -15% morale, but flees danger faster | Conscript (negative trait) |
| Hothead | +20% damage when angry, +15% friendly fire risk | Assault |
| Brave | +20% accuracy, immune to fear | Officer, Hero |
| Humorous | +1 morale to squad through humor | Recruit, Support |

### Perk Combinations & Synergies

#### Combo Examples

| **Combo Name** | **Perks** | **Synergy Effect** | **Playstyle** |
|---|---|---|---|
| **Sharpshooter** | Crack Shot + Headshot Specialist + Steady Aim | +60% accuracy, +50% crit | Long-range sniper |
| **Assault Tank** | Close Quarters Combat + Iron Skin + Pain Suppression | Melee tank that doesn't care about damage | Frontline brawler |
| **Ghost Scout** | Fleet Footed + Sneaker + Acrobatics | Mobile infiltrator that moves silently | Hit-and-run tactician |
| **Squad Leader** | Leader + Motivator + Discipline | Command presence that buffs entire squad | Support commander |
| **Lone Wolf** | Survivor + Brave + Long Stride | Solo unit that excels when separated | Independent operator |

#### Stacking Rules

- **Stat bonuses stack additively** (Well Trained +10% AIM, Steady Aim +5% = +15%)
- **Percentage effects can stack** but with diminishing returns
- **Conditional perks don't conflict** if conditions don't overlap
- **Contradictory perks cancel** (Brave vs Coward, Leader vs Loner)

### Perk Unlocking & Progression

#### How Units Gain Perks

1. **Class Default**: Assigned on recruitment (Soldier gets "Well Trained", Sniper gets "Crack Shot")
2. **Achievement**: Earn through in-game actions
   - Get 10 kills = unlock "Veteran"
   - Land headshots = unlock "Headshot Specialist"
   - Survive critical hit = unlock "Bulletproof Intuition"
3. **Research**: Unlock through research projects
   - Research "Advanced Combat Training" = unlock "Suppressive Fire"
4. **Event**: Special story events or random moments
   - Surviving alien terror attack = unlock "Cold Blooded"

#### Perk Rarity Tiers (Optional)

| **Tier** | **Frequency** | **Impact** | **Examples** |
|---|---|---|---|
| **Common** | Every soldier has | +5-10% to stats | Well Trained, Alert |
| **Uncommon** | ~50% of soldiers | +10-20% or situational | Crack Shot, Sneaker |
| **Rare** | ~20% of soldiers | +20-30% or powerful effect | Headshot Specialist, Leader |
| **Legendary** | <5% of soldiers | Major gameplay change | Survivor, Cold Blooded |

### Perks in UI

#### Squad Setup Screen

- Unit card displays active perks as icons
- Hover over perk icon = tooltip with description
- Option to disable/enable perk if conflicts exist
- Perk counts affect unit rating/reliability

#### Unit Summary

- Perk list shows all perks and active status
- Green = active, Red = disabled/conflicting
- Statistics panel shows how perks modify base stats
- History section tracks perk unlock events

### Perk Design Philosophy

The Perk system serves multiple strategic and narrative purposes:

1. **Customization & Identity**: Perks enable unique builds and let players create memorable unit personas
2. **Progression Rewards**: Perk unlocks provide long-term goals and reward player investment
3. **Tactical Depth**: Perk combinations create synergies and force build decisions
4. **Balance Tool**: Perks allow granular difficulty adjustment per unit without direct stat changes
5. **Narrative Hooks**: Perks represent unit history, personality, and special backgrounds
6. **Roleplay Support**: Perks enable player storytelling ("My Brave Sniper who survived 50 missions")
7. **Asymmetric Strength**: Perks allow specialist units to excel in specific roles without breaking general balance

---

## Design Philosophy

The Unit system emphasizes:

1. **Permanent Consequences**: Unit death is meaningful; loss impacts squad composition
2. **Strategic Growth**: Progression through ranked classes creates investment
3. **Customization**: Traits, equipment, and specialization paths allow unique builds
4. **Psychological Depth**: Morale and sanity add narrative weight to combat
5. **Resource Management**: Salary and maintenance balance unit acquisition vs. operational cost
6. **Individuality**: Named, customized units create roleplay and emotional attachment
7. **Specialized Roles**: Pilots and perks enable unique unit identities beyond class designation
8. **Long-term Development**: Progression systems reward keeping veteran units alive and trained

This system rewards careful squad composition, tactical positioning, and long-term planning while maintaining the high-stakes, consequences-matter feel of tactical strategy games. Pilots represent permanent strategic assets, while perks allow deep customization and create memorable unit personalities.
