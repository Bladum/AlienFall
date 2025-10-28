# Items System

> **Status**: Design Document  
> **Last Updated**: 2025-10-28  
> **Related Systems**: Units.md, Crafts.md, Economy.md, Battlescape.md

## Table of Contents

- [Overview](#overview)
- [Item Categories](#item-categories)
- [Item Properties & Statistics](#item-properties--statistics)
- [Item Durability System](#item-durability-system)
- [Item Modification System](#item-modification-system)
- [Item Acquisition & Usage](#item-acquisition--usage)
- [Resources System](#resources-system)
- [Unit Equipment](#unit-equipment)
- [Craft Equipment](#craft-equipment)
- [Special Item Types](#special-item-types)
- [Economy & Trading](#economy--trading)
- [Appendix: Quick Reference](#appendix-quick-reference)

---

## Overview

The items and equipment system in AlienFall is fundamental to player progression, tactical decision-making, and base management. All equipment must be researched before use or manufacture, and their availability is tied to game progression phases. The system emphasizes strategic choice: players must decide between equipping units immediately, selling for profit, trading with allies, or synthesizing materials for future projects.

### Key Principles

- **Research-Gated**: Most items require research to purchase, use, or manufacture
- **Phase-Based**: Available resources and equipment change with game progression
- **Capacity-Limited**: Units and crafts have limited carrying capacity; base storage requires facilities
- **Karma-Driven**: Trading and disposal decisions affect faction relations and player reputation
- **Class-Synergized**: Some equipment provides bonuses or penalties based on unit class compatibility

---

## Item Categories

Items fall into five primary categories, each with distinct mechanics and usage:

### 1. **Resources**

Strategic materials consumed in manufacturing, research, and craft travel. Core game progression depends on acquiring and managing these efficiently.

**Core Resource Types**:
- **Fuel**: Powers craft travel across the globe
- **Energy Sources**: Powers facilities, craft systems, and weapons
- **Construction Materials**: Required for base facility construction and expansion
- **Biological Materials**: Used in research and advanced manufacturing

**By Game Phase**:

| Phase | Resources | Purpose | Examples |
|-------|-----------|---------|----------|
| **Early Human** | Fuel (5K), Metal (3K) | Basic crafts, equipment | Scout missions, first weapons |
| **Advanced Human** | Fusion Core (50K), Titanium (20K), Uranium (100K) | Advanced tech unlocks | Interceptor craft, plasma research |
| **Alien War** | Elerium (200K), Alien Alloy (150K) | Alien tech integration | UFO weapons, advanced armor |
| **Aquatic War** | Zrbite (250K), Aqua Plastic (200K) | Underwater operations | Submarine development, naval combat |
| **Dimensional War** | Warp Crystal (500K), Rift Matter (300K) | Dimensional tech | Teleportation, portal research |
| **Ultimate** | Quantum Processor (1M), Reality Anchor (800K) | Endgame supremacy | AI integration, reality manipulation |
| **Virtual/AI War** | Data Core (100K), Processing Power (50K) | Digital warfare | Cyber attacks, AI combat systems |

**Mechanics**:
- Crafts consume fuel directly from base inventory per mission—no refueling phase exists
- If insufficient fuel remains, craft cannot travel (creates interesting resource management tension)
- Resources can be synthesized (e.g., Metal + Fuel → Titanium) or traded with suppliers

**Resource Acquisition & Management**:
- **Crafts Consume Fuel**: Fuel is consumed automatically per travel; no separate refueling mechanic
- **Stranding Risk**: Insufficient fuel prevents craft launch; forces players to maintain reserves
- **Synthesis System**: Convert common resources into rare materials (Metal + Fuel → Titanium)
- **Trading**: Sell surplus resources at 50% purchase price; convert to credits for reinvestment
- **Black Market**: High-cost alien resources available through black market suppliers (reputation risk)
- **Supply Contracts**: Establish contracts with factions for steady resource income

**Economic Strategy**:
Players must balance three competing interests:
1. **Manufacturing**: Convert resources → equipment → equip troops immediately
2. **Trading**: Convert resources → credits → reinvest in other priority areas (research, facilities)
3. **Synthesis**: Convert common resources → rare materials → enable advanced manufacturing

### 2. **Lore Items**

Non-mechanical story objects collected through special missions and narrative events. These items carry no direct gameplay advantage but unlock research and manufacturing opportunities.

**Characteristics**:
- Typically zero weight and zero storage space
- Cannot be sold by accident (flagged to prevent player mistakes)
- May enable new research trees or unlock advanced equipment
- Represent story progression and world-building

**Usage**:
- Historical artifacts may unlock research into ancient alien technology
- Creature specimens enable biological research
- Technology salvage provides manufacturing blueprints

### 3. **Unit Equipment**

Weapons, armor, and consumable items that soldiers carry into battle. Equipment directly impacts combat effectiveness and tactical options.

#### Unit Weapons

**Characteristics**:
- Weapons have AP (Action Point) cost and EP (Energy Point) cost
- Range, accuracy, and damage vary by weapon type
- All weapons can be thrown as emergency actions
- Damage types include Kinetic, Energy, Explosive, Psionic, and Hazard

**Weapon Types & Statistics**:

| Type | Range | AP Cost | EP Cost | Base Accuracy | Base Damage | Usage Notes |
|------|-------|---------|---------|----------------|-------------|------------|
| Pistol | 8 hex | 1-2 | 5-10 | 75% | 12 | Fast, light |
| Rifle | 15 hex | 2 | 10 | 70% | 18 | Standard infantry |
| Sniper Rifle | 25 hex | 3 | 15 | 85% | 35 | Requires stationary aim |
| Shotgun | 4 hex | 2 | 10 | 60% | 45 | Close quarters, high damage |
| Melee | 1 hex | 1 | 5 | 80% | 20 | Silent, always available |

**Weapon Firing Modes** (mutually exclusive, chosen before shot):
- **Snap Shot**: -20% accuracy, 1 AP—quick reflexive fire
- **Aimed Shot**: +20% accuracy, 3 AP, stationary—deliberate targeting
- **Burst Fire**: -10% accuracy, 3 AP, 2-3x damage—medium coverage
- **Auto Fire**: -20% accuracy, 4 AP—sustained fire, unreliable but devastating

**Special Weapons & Consumables**:

| Item | AP Cost | Effect | Range | Charges | Notes |
|------|---------|--------|-------|---------|-------|
| Grenade | 1 | 30 damage, area effect | 3 hex radius | - | Can bounce off walls |
| Mine | 2 | 40 damage, proximity triggered | 3 hex radius | - | Defensive placement |
| Flare | 1 | +3 hex vision for 2 turns | 3 hex radius | - | Dispels darkness |
| Flashbang | 1 | 1-turn stun | 2 hex radius | - | Non-lethal control |
| Flashlight | - | +2 night vision | Equipped | - | Passive, always active |
| Night Vision Goggles | - | +5 night vision | Equipped | 100 turns | Passive when equipped |
| Motion Scanner | - | +3 sight range | Equipped | 50 turns | Detects movement |
| Psionic Amplifier | - | Enables psychic abilities | Equipped | - | 30 EP per use |
| Medikit | 1 | 25 HP (Medic) / 15 HP (Others) | Self | 5 charges | Class synergy +50% for Medic |

**Damage Types**: Kinetic | Energy | Explosive | Psionic | Hazard

**No Critical Hits System**: Damage is consistent; critical hits do not exist. Instead, success is rewarded through tactical positioning, better armor penetration, and choice of damage types.

#### Unit Armor

Protective gear that reduces incoming damage and may provide tactical bonuses or penalties.

**Armor Types & Statistics**:

| Armor Type | Movement Penalty | AP Penalty | Armor Value | Accuracy Penalty | Cost | Notes |
|------------|------------------|-----------|-------------|------------------|------|-------|
| Light Scout | +1 hex/turn | 0 | +5 | +5% | 8K | Mobility-focused |
| Combat Armor | -1 hex/turn | -1 AP | +15 | -5% | 15K | Balanced |
| Heavy Assault | -2 hex/turn | -2 AP | +25 | -10% | 25K | Tanking specialist |
| Hazmat Suit | Varies | Varies | +10 | Varies | 12K | +100% poison resistance |
| Stealth Suit | Varies | Varies | +8 | +20% stealth | 20K | Infiltration-focused |
| Medic Armor | Varies | Varies | +8 | Varies | 10K | +50% healing potency |
| Sniper Ghillie | Varies | Varies | +10 | +10% accuracy, +1 sight | 18K | Marksman-optimized |

**Armor Mechanics**:
- Armor Value represents damage reduction (1 point = 1 damage absorbed)
- Armor class cannot be changed during battle—must be equipped before deployment
- Each armor type sets resistances to Kinetic, Energy, and Hazard damage types unless overridden by special armor
- Unit race determines default resistances if armor doesn't specify them
- Each armor type may provide class synergies (bonuses/penalties based on unit class)

**Class Synergy Examples**:
- Medic + Medikit: +50% healing effectiveness
- Non-specialist + Heavy Cannon: -30% accuracy penalty
- Specialist units unlock access to more powerful equipment

### 4. **Craft Equipment**

Weapons, armor systems, and support modules mounted on interceptor craft. These are fixed during interception missions and cannot be modified mid-combat.

#### Craft Weapons

Weapons mounted in hardpoint slots (left, right, center).

**Weapon Classes**:

| Weapon | Range | Damage | AP Cost | EP Cost | Cooldown | Accuracy | Special |
|--------|-------|--------|---------|---------|----------|----------|---------|
| Point Defense Turret | 20 km | 15 | 2 | 5 | 1 turn | 75% | Anti-missile |
| Main Cannon | 20 km | 40 | 3 | 10 | 1 turn | 75% | Balanced |
| Missile Pod | 60 km | 80 (area) | 4 | 15 | 2 turns | 85% | Homing |
| Laser Array | 40 km | 60/turn | 3 | 20 | None | 75% | Sustained beam |
| Plasma Caster | 30 km | 70 | 4 | 25 | 2 turns | 70% | Ignores 50% armor |
| Specialty Weapon | Variable | Variable | Variable | Variable | Variable | Variable | EMP, Concussive, Tractor |

**Weapon Properties**:
- All craft weapons are inherently hostile—there is no repair/support systems during interception
- Damage types include Kinetic, Energy, and Explosive
- Cooler weapons have longer engagement windows but higher single-hit damage
- Sustained weapons like Laser Array provide consistent output but consume more energy

#### Craft Support Systems & Armor

Fixed systems providing defense, mobility, and capacity enhancements.

| System | Category | Effect | Cost Implications | Notes |
|--------|----------|--------|-------------------|-------|
| Energy Shield | Defense | +10 health, +20 energy, +5 regen/turn | Premium | Power-dependent |
| Ablative Armor | Defense | -50% explosive damage, degrades 10% per hit | Standard | Temporary defense |
| Reactive Plating | Defense | Explosive +40%, Kinetic +20% resistance | Standard | Specialized defense |
| Standard Armor Plates | Defense | +50 health | Budget | Solid baseline |
| Afterburner | Mobility | +1 speed, higher fuel consumption | Performance | Aggressive pursuit |
| Additional Fuel Tank | Logistics | +50% range | Range-focused | Enables distant missions |
| Cargo Pod | Logistics | +10 capacity | Supply runs | Utility upgrade |
| Passenger Cabin | Logistics | +2 crew capacity | Troop transport | Unit recovery |
| Enhanced Radar | Sensors | +100% detection range | Detection | Early warning system |

**Armor Integration Mechanics**:
- Multiple armor systems can be combined for layered defense
- Armor degrades with damage and doesn't regenerate naturally
- Shield systems drain energy but provide powerful defense
- Players must balance offense, defense, and logistics

### 5. **Prisoners**

Living captured units held at base for research, interrogation, and potential trade/release.

**Mechanics**:
- Created when enemies are captured during battle rather than killed
- Stored in specialized prison facility (not regular storage)
- Each prisoner can be researched multiple times to unlock different research topics
- Subject to limited lifespan (10-60 days depending on species)
- Can be released for diplomatic bonus or sold for profit/penalty

**Karma Impact**:
- Releasing prisoners: +Karma, -Credits
- Selling prisoners: +Credits, -Karma, may damage faction relations
- Executing prisoners: Severe -Karma impact
- Playing "good" vs "evil" faction determines optimal strategy

### 6. **Corpses**

Deceased unit remains converted into collectible items, enabling research and analysis.

**Mechanics**:
- When any unit dies, its body converts into a "Corpse of [Race]" item
- Items equipped by the deceased unit are dropped at the death location
- Each race has exactly one corpse type (all human corpses are identical)
- Corpses can be researched to provide genetic/biological insights
- Living captured units of a race enable class analysis (prisoner interrogation)
- Collecting corpses generates negative karma (unless committed to "evil" playthrough)

**Strategic Implications**:
- Corpse research is cheaper than living prisoner research
- Only living prisoners reveal unit class information
- Players must balance ethical concerns with research efficiency

### 7. **Other Items**

Miscellaneous items with no direct game mechanics—collectibles, trophies, or narrative objects without functional use.

---

## Item Properties & Statistics

Every item in the game is defined by consistent properties that determine its acquisition, utility, and management.

### Essential Properties

#### **Price & Economic Value**

| Property | Range | Mechanics |
|----------|-------|-----------|
| Purchase Price | Variable | Base cost from suppliers; modified by faction relations (±150% to -20%) |
| Sale Value | 50% of Purchase | Fixed ratio; always predictable |
| Supplier Availability | Varies | Specific suppliers may carry or refuse items based on karma/relations |
| Rarity | Common → Exotic | Affects availability and value |

**Pricing Mechanics**:
- Supplier relations directly affect prices (better relations = cheaper purchases, better sell values)
- Fame and karma impact supplier trust and availability
- Surplus resources can be sold back to generate credits for reinvestment
- Black market suppliers offer alien resources at premium prices with reputation risk

#### **Weight**

Represents a unit or craft's burden, limited by carrying capacity.

| Item Type | Typical Weight | Example |
|-----------|----------------|---------|
| Light | 0.1-1.0 | Flashlight, grenade |
| Standard | 1.0-3.0 | Pistol (1), rifle (2) |
| Heavy | 3.0-10.0 | Heavy cannon, armor |

**Capacity Limits**:
- **Unit Inventory**: 6-12 weight capacity (varies by unit class and strength)
- **Craft Capacity**: 20-100 weight capacity (varies by craft class)
- **Overflow Penalty**: Each weight unit over capacity costs +5% maintenance monthly

#### **Storage Space**

Represents physical storage footprint at base (distinct from weight).

| Item Type | Space Units | Facility Capacity |
|-----------|-------------|-------------------|
| Small | 0.1-1.0 | Pistol (1 space) |
| Standard | 1.0-2.0 | Rifle (2 space) |
| Large | 2.0-5.0 | Armor (2-3 space) |

**Base Storage**:
- Each storage facility provides ~100 space units
- Items not in designated slots are stacked in warehouse
- Running out of storage capacity prevents acquiring new items

#### **Research Requirements**

Items are gated behind research milestones:

| Gate Type | Effect | Examples |
|-----------|--------|----------|
| Purchase Research | Must research to buy from suppliers | Tier 1 weapons, armor |
| Use Research | Must research to equip/use item | Advanced armor, psionics |
| Manufacture Research | Must research to produce items | All manufactured equipment |

**Research Unlocking**:
- Some items auto-research when prerequisites complete
- Others require direct research investment after prerequisites
- Special items may require story progression or rare components

---

## Item Durability System

All equipment items degrade through use during combat missions. Durability represents the condition and functionality of equipment, affecting its effectiveness in battle.

### Durability Mechanics

**Durability Range**: 0-100 (represents percentage of original condition)

| Condition | Durability Range | Effect | Repair Cost |
|-----------|------------------|--------|------------|
| Pristine | 100-75% | Full effectiveness, peak performance | N/A |
| Worn | 74-50% | No functionality penalty, cosmetic wear | 25% base cost |
| Damaged | 49-25% | -10% effectiveness (accuracy/damage) | 50% base cost |
| Critical | 24-1% | -30% effectiveness, unreliable operation | 75% base cost |
| Destroyed | 0% | Non-functional, item lost permanently | N/A |

**Degradation Rates by Item Type**:
- **Weapons**: -5 durability per mission use (regardless of shots fired)
- **Armor**: -3 durability per hit taken (stacks with multiple hits)
- **Consumables**: Consumed completely on use (grenades, medkits)
- **Equipment/Tools**: -2 durability per mission

**Example Timeline**:
- Rifle starts at 100 durability (pristine)
- After 5 missions: 75 durability (worn)
- After 10 missions: 50 durability (worn)
- After 15 missions: 25 durability (damaged, -10% accuracy)
- After 20 missions: 0 durability (destroyed, item lost)

### Repair System

**Repair Locations**:
- Base workshop (primary repair facility)
- Marketplace suppliers (emergency repair service)
- Field medic cannot repair weapons/armor (only heal units)

**Repair Mechanics**:
- 1 durability point costs 1% of base item purchase price to restore
- Restoring from 25→50 durability costs 25% of base item cost
- Repairs take 1 day per 10 durability points at base
- Emergency repairs at marketplace cost 50% premium but happen instantly

**Strategic Implications**:
- High-value items (Plasma Weapons, Heavy Armor) have expensive maintenance budgets
- Frequent missions mean constant repair costs eat into economy
- Choice: Keep elite equipment and pay repair costs, or use cheaper items
- Breaking expensive weapons is costly and wasteful

**Restrictions**:
- Completely destroyed items (0 durability) cannot be repaired—item is permanently lost
- No in-field repairs possible; must return to base after missions

### Durability Factors

**Mission Environment**:
- Volcanic terrain: +2 durability loss per mission (heat damage)
- Underwater: +1 durability loss per mission (corrosion)
- Urban/Standard: Normal degradation
- Arctic: No additional degradation (cold preserves materials)

**Unit Class Impact**:
- Specialist units cause +1 durability loss (intense weapon usage)
- Support units cause -1 durability loss (gentler equipment handling)
- Standard units cause normal degradation

**Armor Durability Special Rules**:
- Armor loses durability when hit, not per mission
- Heavy Assault Armor loses durability 50% slower (better craftsmanship)
- Stealth Suit loses durability 50% faster (delicate construction)

---

## Item Modification System

Equipment can be enhanced with modifications (attachments, upgrades, enhancements) providing stat bonuses and special tactical abilities. Modifications are permanent installations that affect equipment capability.

### Modification Slots

Each item type has specific modification slots available:

| Item Type | Slots | Capacity | Notes |
|-----------|-------|----------|-------|
| Weapons | 2 slots | Firearm specific | Scope, barrel, magazine, stock |
| Armor | 1 slot | Single enhancement | Plating, padding, camouflage |
| Utility/Tools | 1 slot | Single enhancement | Varies by tool type |
| Consumables | 0 slots | N/A | Grenades, medkits cannot be modified |
| Resources | 0 slots | N/A | Fuel, materials cannot be modified |

**Modification Architecture**:
- Each item maintains independent modification list
- Modifications stack multiplicatively (not additively) for accuracy/damage
- Modifications are reusable if removed before item destruction
- Destroying an item destroys all its modifications permanently

### Modification Categories & Effects

**Weapon Modifications**:

| Modification | Slot | Cost | Effect | Research Required |
|--------------|------|------|--------|-------------------|
| Scope | Firearm | 5K | +15% accuracy, +1 sight range | Advanced Targeting |
| Laser Sight | Firearm | 6K | +10% accuracy (close range only) | Laser Technology |
| Extended Magazine | Firearm | 3K | +50% ammo capacity (grenades/missiles) | Engineering |
| Armor-Piercing Rounds | Firearm | 4K | +20% damage vs armored targets | Advanced Ammunition |
| Silencer | Firearm | 4K | Silent shots, no detection radius | Stealth Technology |
| Stock Enhancement | Firearm | 2K | -1 AP cost for aimed shots | Gunsmithing |
| Rapid-Fire Module | Firearm | 7K | +1 extra burst shot (burst fire only) | Advanced Firearms |

**Armor Modifications**:

| Modification | Slot | Cost | Effect | Research Required |
|--------------|------|------|--------|-------------------|
| Ceramic Plating | Armor | 8K | +5 armor value, -2% movement speed | Advanced Armor |
| Lightweight Alloy | Armor | 6K | -10% movement penalty | Materials Engineering |
| Reactive Plating | Armor | 10K | +40% explosive resistance | Specialized Defense |
| Camouflage Overlay | Armor | 5K | +15% stealth effectiveness | Camouflage Tech |
| Thermal Lining | Armor | 4K | +100% heat/cold resistance | Environmental Tech |

**Utility/Tool Modifications**:

| Modification | Slot | Cost | Effect | Research Required |
|--------------|------|------|--------|-------------------|
| Night Vision Upgrade | Scanner | 3K | +3 hex night vision | Optics Research |
| Extended Battery | Tool | 2K | +50% uses (doubled charge count) | Power Systems |
| Sensor Boost | Tool | 5K | +100% detection range | Advanced Sensors |

### Modification Restrictions

**Mutually Exclusive Modifications**:
- **Scope** ↔ **Laser Sight**: Cannot have both (sight system conflict)
- **Silencer** ↔ **Rapid-Fire Module**: Cannot have both (noise vs fire rate conflict)
- **Armor Plating** ↔ **Lightweight Alloy**: Cannot have both (weight tradeoff conflict)

**Item Condition Restrictions**:
- Cannot install modifications on Damaged/Critical/Destroyed items
- Only Pristine or Worn condition items accept modifications
- Installation damage: Item loses 5 durability during modification (installation risk)

### Modification Installation & Removal

**Installation Process**:
- Location: Base workshop (requires Engineering facility)
- Cost: 10% of base modification cost + 5 durability loss
- Time: 1 day per modification installed
- Prerequisite: Modification research must be completed

**Removal Process**:
- Location: Base workshop
- Cost: Free (modifications are reusable)
- Time: Instant (remove during loadout prep)
- Result: Modification stored in inventory for reuse

**Strategic Implications**:
- High-value weapon modifications (Armor-Piercing, Rapid-Fire) worth preserving across items
- Budget decisions: Equip 1 elite modified weapon or 2 standard weapons
- Late-game synergies: Heavily modified veteran equipment becomes irreplaceable
- Loadout planning: Swap modifications between missions for tactical optimization

### Modification Synergies

**Weapon Examples**:
- **Precision Build**: Scope + Laser Sight (can't combine) or Scope + Stock Enhancement
- **Silent Assassin**: Silencer + Camouflage Armor + Stealth Suit
- **Rapid Suppression**: Rapid-Fire Module + Extended Magazine (tactical overload)
- **Armor Penetrator**: Armor-Piercing Rounds + Heavy Weapon targeting

**Armor Examples**:
- **Tank Build**: Ceramic Plating + Reactive Plating (maximum defense)
- **Scout Build**: Lightweight Alloy + Camouflage Overlay (speed + stealth)
- **Environmental Specialist**: Thermal Lining + relevant mission environment

---

## Item Acquisition & Usage

### How Units Use Equipment

#### **Inventory Compatibility Rules**

Before a unit can equip an item:

1. **Class Requirement Check**: Some items are restricted to specific unit classes
   - Example: Heavy Cannon is Specialist-only
   - Non-matching classes suffer accuracy penalties (-30%)

2. **Capacity Check**: Unit must have sufficient weight capacity
   - Weight cannot exceed unit strength limit
   - Exceeding capacity is possible but applies maintenance penalties

3. **Research Check**: Unit's faction must have completed required research
   - Items cannot be used without researched technology
   - Exception: Some items can be used by enemies even without player research

**Class Synergy Bonuses**:
- Medic + Medikit = +50% healing potency
- Specialist + Advanced Weapons = No penalty, full effectiveness
- Class Mismatch = Accuracy penalty (-30%), potential other penalties

#### **Battle Inventory Mechanics**

Equipment management changes dramatically during tactical combat:

- **Armor**: Fixed at mission start; cannot be changed mid-battle
- **Weapons**: Can be swapped (costs AP equivalent to drop/equip time)
- **Consumables**: Can be dropped, picked up, or used on allies
- **Corpses & Items**: Available for pickup at their tile location
- **Throwing**: Any item can be thrown as emergency measure (costs 1 AP)

### How Crafts Use Equipment

Craft equipment is fixed before interception missions begin:

- **Weapons**: Hardpoint slots determine loadout (left, right, center)
- **Systems**: Support systems are pre-installed and active
- **No Repairs**: Damaged craft systems cannot be repaired mid-mission
- **No Refueling**: Fuel consumption is calculated pre-mission; impossible to refuel in flight
- **Inventory Fixed**: Cargo capacity is reserved; cannot take off with new items added after mission acceptance

### Base Item Management

At base, items serve multiple functions:

- **Inventory Management**: Organize and store items in facilities
- **Manufacturing**: Use items as components to produce new equipment
- **Research**: Corpses and prisoners enable research unlocks
- **Trading**: Sell surplus items to suppliers for credits
- **Synthesis**: Convert resources (Metal + Fuel → Titanium) for efficiency

---

## Resources System

Resources are the lifeblood of base operations, enabling research, manufacturing, and craft operations.

### Resource Types by Game Phase

Each phase introduces new core resources reflecting technological progression:

#### **Early Human Phase** (Game Start)
- **Fuel**: Powers craft travel; foundational for operations
- **Metal**: Primary construction and manufacturing material
- **Power**: Enables facility operations and weapon charges

#### **Advanced Human Phase** (Post-Research)
- **Fusion Core**: Advanced power generation; enables future research
- **Titanium**: Superior construction material; more durable facilities
- **Uranium**: Weaponizable material; enables advanced weapons research

#### **Alien War Phase** (First Contact)
- **Elerium**: Alien energy source; extremely valuable; enables alien weapons
- **Alien Alloy**: Superior armor material; dramatically better protection

#### **Aquatic War Phase** (Undersea Operations)
- **Zrbite**: Underwater-specific resource; unique properties
- **Aqua Plastic**: Buoyancy-engineered material; water operations

#### **Dimensional War Phase** (Interdimensional Breach)
- **Warp Crystal**: Dimensional manipulation; teleportation/portal tech
- **Rift Matter**: Dimensional fabric; reality-bending weapons

#### **Ultimate Phase** (Endgame Revelation)
- **Quantum Processor**: Computational substrate; AI integration
- **Reality Anchor**: Exotic matter; fundamental force manipulation

#### **Virtual/AI War Phase** (Digital Realm)
- **Data Core**: Computational storage; information/consciousness substrate
- **Processing Power**: CPU equivalent; enables digital warfare

### Resource Acquisition & Management

**Craft Fuel Mechanics**:
- Crafts have fuel item and consumption rate configured at base
- Fuel is consumed directly from base inventory per travel (no refueling phase)
- If insufficient fuel exists, craft cannot launch
- Forces players to maintain fuel reserves or risk being stranded

**Resource Synthesis**:
- Base facilities enable resource conversion (Metal + Fuel → Titanium)
- Synthesis creates more valuable resources from common ones
- Valuable for late-game scaling and efficiency

**Trade & Economics**:
- Sell surplus resources to suppliers (50% purchase price)
- Trade resources between categories if beneficial (Fuel ↔ Metal)
- Black market suppliers offer alien resources at premium (high risk)
- Establish supply contracts with factions for steady resource income

### Economic Strategy

Players must balance three competing interests:

1. **Manufacturing**: Convert resources → equipment → equip troops immediately
2. **Trading**: Convert resources → credits → reinvest in other areas
3. **Synthesis**: Convert common resources → rare materials → advanced manufacturing

Optimal strategy depends on current phase, available research, and faction standing.

---

## Unit Equipment

### Armor Selection Strategy

Armor choice defines tactical role and capabilities:

**Mobility-First** (Light Scout):
- Ideal for: Scouts, fast-movers, specialists needing evasion
- Trade: -5 armor for +1 hex/turn movement and +5% accuracy
- Cost: 8K

**Balanced** (Combat Armor):
- Ideal for: Standard infantry, jack-of-all-trades
- Trade: Slight movement penalty (-1 hex/turn) for +15 armor
- Cost: 15K

**Tank** (Heavy Assault):
- Ideal for: Breachers, suppression, defensive positions
- Trade: Significant movement penalty (-2 hex/turn) for +25 armor
- Cost: 25K

**Specialized**:
- **Hazmat Suit**: Toxic/biological environment protection; +100% poison resist
- **Stealth Suit**: Infiltration/reconnaissance; +20% stealth bonus
- **Medic Armor**: Field medic support; +50% healing potency
- **Sniper Ghillie**: Marksmanship focus; +10% accuracy, +1 sight range

### Weapon Selection Strategy

Weapon choice determines engagement range and tactical flexibility:

**Close Quarters** (Melee, Shotgun):
- Melee: 1 hex range, reliable 80% accuracy, silent, always available
- Shotgun: 4 hex range, 45 damage, unreliable 60% accuracy
- Use: Point-blank suppression, breaching rooms, ambush tactics

**Medium Range** (Pistol, Rifle):
- Pistol: 8 hex range, fast 1 AP cost, moderate 12 damage
- Rifle: 15 hex range, standard 2 AP cost, consistent 18 damage
- Use: Flexible engagement, coverage, rapid fire

**Long Range** (Sniper Rifle):
- Range: 25 hex (maximum), 85% base accuracy, 35 damage
- Mechanics: Requires stationary aim (cannot move and fire same turn)
- Use: Overwatch position, crowd control from distance

**Specialization**:
- Specialists unlock heavy cannons and advanced weapons
- Non-specialists suffer -30% accuracy when using restricted equipment

---

## Craft Equipment

### Weapon Loadout Strategy

Craft weapons are fixed pre-mission; choose for expected encounter:

**Anti-Air Doctrine**:
- Point Defense Turrets: Cover incoming threats with overlapping fire
- Missile Pod: Medium-range area damage
- Laser Array: Sustained pressure against tougher targets

**Anti-Ground Doctrine**:
- Main Cannons: Balanced damage and accuracy
- Missile Pod: Area effect for grouped enemies
- Plasma Caster: Armor penetration for tanked opponents

**Hybrid Loadout**:
- Main Cannon + Point Defense: Offense and defense balance
- Missile Pod + Laser Array: Range and area coverage

### Support System Strategy

Systems enable specialty tactics:

**Defensive Doctrine**:
- Energy Shield: Peak damage reduction if power available
- Ablative Armor: Temporary defense against explosive burst
- Reactive Plating: Specialized defense against specific damage types

**Offensive Doctrine**:
- Afterburner: Aggressive pursuit, positioning advantage
- Enhanced Weapons: Damage amplifiers and specialization

**Logistics Doctrine**:
- Fuel Tank: Extended range, remote operations
- Cargo Pod: Supply missions, resources hauling
- Passenger Cabin: Unit extraction, reinforcement deployment

**Detection Doctrine**:
- Enhanced Radar: Early warning, ambush prevention

---

## Special Item Types

### Prisoners

**Acquisition**: Capture enemy units during battle (alive, not killed)

**Mechanics**:
- Stored in dedicated prison facility (capacity separate from storage)
- Research value: Each prisoner can be researched multiple times for different techs
- Lifespan: 10-60 days depending on species; corpse created on death
- Options: Release (diplomatic), Sell (profit), Execute (evil), Interrogate (info)

**Strategic Use**:
- Living prisoners enable unit class research (reveals class abilities)
- Cheaper research than captured corpses alone
- Relationship impact: Releasing improves faction standing; selling harms it

### Corpses

**Acquisition**: Automatically generated when units die in battle

**Mechanics**:
- Dropped at death location; can be picked up by allies
- One corpse type per race (all human corpses identical)
- Research: Unlock genetic/biological insights
- Storage: Normal storage facility (counts toward capacity)

**Strategic Use**:
- Cheaper research entry point than living prisoners
- Ethical concerns: Corpse harvesting generates -Karma
- Prerequisite: Living prisoners of same race for class-specific research

---

## Economy & Trading

### Supplier Relations

Suppliers form the backbone of the economy. Relations affect:

| Relation Level | Purchase Price | Sale Price | Availability |
|----------------|----------------|------------|--------------|
| Hostile (-) | +150% | 25% | Limited |
| Neutral (±0) | Base (100%) | 50% | Full catalog |
| Friendly (+) | -20% | 60% | Full + specials |

### Economic Decisions

Players constantly choose between:

**Option 1: Manufacturing**
- Convert resources → equipment immediately
- Upside: Units equipped quickly; immediate combat advantage
- Downside: Resources consumed; no flexibility

**Option 2: Trading**
- Sell surplus resources to suppliers
- Upside: Convert to credits; reinvest in other areas
- Downside: Resources gone; dependent on market prices

**Option 3: Synthesis**
- Convert common resources → rare materials
- Upside: Better resource efficiency; value multiplication
- Downside: Requires research; facility space; time investment

**Option 4: Black Market**
- High-risk acquisition of alien resources
- Upside: Access to restricted materials early
- Downside: Severe relation penalties; might attract unwanted attention

### Item Flow Management

Base acts as central hub:

```
Acquisition (missions, suppliers, synthesis)
    ↓
Storage (inventory management)
    ↓
Distribution (equip units, mount craft, assign facilities)
    ↓
Usage (combat, research, crafting)
    ↓
Overflow/Surplus (sell, trade, or hold for future use)
```

---

## Appendix: Quick Reference

### Item Categories
- **Resources**: Fuel, Energy, Materials, Biological
- **Lore**: Story objects, research unlock
- **Unit Equipment**: Weapons, Armor, Consumables
- **Craft Equipment**: Weapons, Systems, Armor
- **Prisoners**: Living captives for research/trade
- **Corpses**: Deceased unit remains
- **Other**: Collectibles with minimal function

### Key Mechanics
- All equipment requires research before purchase/use/manufacture
- Weight represents burden; storage represents footprint (distinct)
- Armor fixed at mission start; weapons can swap mid-battle
- Craft equipment fixed pre-interception
- Fuel consumed from base per craft travel (no refueling)
- Prisoners generate research value; corpses provide cheaper entry
- Karma impacts prisoner/corpse handling and faction relations
- Supplier relations directly affect pricing (±150% to -20%)

### Resource Phase Progression
1. Early Human (Fuel, Metal, Power)
2. Advanced Human (Fusion, Titanium, Uranium)
3. Alien War (Elerium, Alien Alloy)
4. Aquatic War (Zrbite, Aqua Plastic)
5. Dimensional War (Warp Crystal, Rift Matter)
6. Ultimate Phase (Quantum Processor, Reality Anchor)
7. Virtual/AI War (Data Core, Processing Power)
