# FAQ: Items & Equipment

> **Audience**: Experienced strategy gamers familiar with X-COM, Diablo, RPGs  
> **Last Updated**: 2025-10-28  
> **Related Mechanics**: [Items.md](../mechanics/Items.md), [Economy.md](../mechanics/Economy.md)

---

## Quick Navigation

- [Weapon Types](#weapon-types)
- [Armor System](#armor-system)
- [Inventory Management](#inventory-management)
- [Equipment Progression](#equipment-progression)
- [Crafting & Manufacturing](#crafting--manufacturing)
- [Salvage & Loot](#salvage--loot)
- [Game Comparisons](#game-comparisons)

---

## Weapon Types

### Q: What weapon categories exist?

**A**: 8 main categories with tech progression (like **X-COM tech tree**).

**Weapon Categories**:

1. **Rifles** (15-hex range, 2 AP, 18 damage, 70% accuracy)
   - Conventional → Laser → Plasma → Particle Beam
   
2. **Pistols** (8-hex range, 1 AP, 12 damage, 70% accuracy)
   - Backup weapons, fast firing
   
3. **Sniper Rifles** (25-hex range, 3 AP, 35 damage, 85% accuracy)
   - Long-range precision, requires Sniper specialization
   
4. **Shotguns** (3-hex range, 2 AP, 45 damage, 60% accuracy, 3-hex blast)
   - Close-range devastation
   
5. **Heavy Weapons** (20-hex range, 3 AP, 60 damage, 55% accuracy)
   - Grenade Launchers, Heavy Cannons, Rocket Launchers
   - Requires Specialist class
   
6. **Melee Weapons** (1-hex range, 1 AP, 8-25 damage, infinite energy)
   - Knife, Sword, Plasma Blade
   
7. **Grenades** (throwable, 1 AP, 30 area damage, 3-hex radius)
   - Explosive, Incendiary, Smoke, Flashbang, EMP
   
8. **Special Weapons** (varies)
   - Psionic Amplifier, Stun Baton, Flamethrower

---

### Q: How do weapon modes work?

**A**: Weapons have multiple firing modes (like **XCOM 2** weapon abilities).

**Standard Modes**:

| Mode | AP Cost | Accuracy Modifier | Effect |
|------|---------|-------------------|--------|
| **Snap** | 1 | -5% | Quick shot |
| **Auto** | 2 | -10% | Burst fire |
| **Burst** | 2 | ±0% | Controlled burst |
| **Aim** | 2 | +15% | Careful shot |
| **Far** | 1 | -15% | Long-range shot |
| **Critical** | 2 | +25% | Increased crit chance |

**Weapon Modes Unlock**:
- Basic weapons: Snap, Aim
- Advanced weapons: +Burst, Auto
- Alien tech: +Critical, Overcharge (energy weapons)

**Strategic Use**:
- **Snap**: Low chance to hit but fast (reaction fire)
- **Aim**: High chance to hit (finishing blow)
- **Auto**: Multiple shots (suppression)
- **Critical**: High crit chance (kill secured targets)

---

### Q: What are weapon damage types?

**A**: 11 damage types, each with armor interactions.

**Damage Types**:

1. **Kinetic** (bullets, melee) - Physical trauma
2. **Explosion** (grenades, rockets) - Area damage + knockback
3. **Energy** (lasers, plasma) - Burns, heat damage
4. **Chemical** (gas, acid) - Corrosive over time
5. **Biological** (toxins, viruses) - Infection, disease
6. **Psionic** (psychic attacks) - Mental damage
7. **Melee** (hand-to-hand) - Physical close combat
8. **Fire** (incendiary) - Burning, heat
9. **Smoke** (smoke grenades) - Stun/suffocation
10. **Stun** (taser, shock) - Temporary incapacitation
11. **Warp** (exotic sci-fi) - Dimensional effects

**Armor Resistance**:
- Different armor types have resistance/vulnerability to damage types
- Example: Heavy armor has +50% kinetic resistance but -30% energy vulnerability

---

## Armor System

### Q: How does armor work?

**A**: **Armor Value** (damage reduction) + **Damage Type Resistances** (like **Diablo** armor system).

**Armor Mechanics**:
- **Armor Value**: Each point reduces incoming damage by 1 HP
- **Movement Penalty**: Heavier armor reduces movement (-1 to -2 hex/turn)
- **AP Penalty**: Heavy armor reduces available AP (-1 to -2 per turn)
- **Accuracy Penalty**: Heavy armor reduces accuracy (-5% to -10%)

---

### Q: What armor types exist?

**A**: 7 main categories from light to heavy.

**Armor Types**:

| Armor | Armor Value | Movement | AP | Accuracy | Cost | Special |
|-------|-------------|----------|-----|-----------| -----|---------|
| **Light Scout** | +5 | +1 hex/turn | 0 | +5% | 8K | Mobility bonus |
| **Combat Armor** | +15 | -1 hex/turn | -1 AP | -5% | 15K | Balanced |
| **Heavy Assault** | +25 | -2 hex/turn | -2 AP | -10% | 25K | Maximum protection |
| **Hazmat Suit** | +10 | 0 | 0 | -5% | 12K | +100% poison resist |
| **Stealth Suit** | +8 | 0 | 0 | 0% | 20K | +20% concealment |
| **Medic Vest** | +8 | 0 | 0 | 0% | 10K | +50% medikit effectiveness |
| **Sniper Ghillie** | +10 | -1 hex/turn | 0 | +10% | 18K | +1 sight range |

**Tech Progression**:
- **Tier 1**: Body armor, tactical vests (conventional)
- **Tier 2**: Composite armor, exoskeletons (advanced)
- **Tier 3**: Alien alloy armor, energy shields (alien tech)
- **Tier 4**: Psi-shields, Titan armor (ultimate)

---

### Q: What are damage resistances?

**A**: Specialized armor provides % reduction against specific damage types.

**Resistance Examples**:
- **Ablative Armor**: -50% explosive damage (degrades per hit)
- **Reactive Armor**: -40% explosive, -20% kinetic (reactive tiles)
- **Energy Shield**: -50% all damage types (requires fuel)
- **Hazmat Suit**: +100% chemical/poison resistance

**Strategic Implications**:
- Choose armor based on expected enemies
- Explosive-heavy missions: Wear reactive armor
- Chemical warfare: Wear hazmat suit
- Stealth missions: Wear stealth suit

---

## Inventory Management

### Q: How does inventory work?

**A**: **Resident Evil-style** weight capacity system with 3 equipment slots.

**Capacity System**:
- **Carry Capacity** = Strength stat (6-12 units)
- **Binary System**: Either can carry all items or none (no partial equipping)
- Each item has weight (0.5-3 units)
- **Overflow Penalty**: +5% maintenance cost per overflow unit

**Equipment Slots**:
1. **Primary Weapon** (1 slot)
2. **Secondary Weapon** (1 slot)
3. **Armor** (1 slot)

**Example Loadouts**:
- **Balanced** (Strength 8):
  - Rifle (2) + Pistol (1) + Combat Armor (3) + 2× Grenades (2) = 8 weight ✅
  
- **Heavy** (Strength 10):
  - Heavy Cannon (4) + Combat Armor (3) + Medikit (1) + 2× Grenades (2) = 10 weight ✅
  
- **Overencumbered** (Strength 8):
  - Heavy Cannon (4) + Heavy Assault Armor (5) = 9 weight ❌ Cannot equip

---

### Q: Can I drop items during missions?

**A**: **Yes** - Items can be dropped, picked up, or swapped (like **Diablo** inventory).

**Item Management Actions**:
- **Drop**: 0 AP (instant), item left on tile
- **Pick Up**: 1 AP, pick up item from tile
- **Swap**: 1 AP, exchange equipped item for tile item
- **Throw**: 2 AP, throw item to another location

**Strategic Uses**:
- Drop heavy weapon to reduce weight for movement
- Pick up dead ally's equipment
- Swap weapons mid-battle (situational)
- Throw items to allies

**Salvage Integration**:
- Dropped items salvaged after mission
- Dead unit equipment automatically collected
- Mission loot items can be picked up

---

## Equipment Progression

### Q: How do I unlock better equipment?

**A**: **Research unlocks** + **Manufacturing** (like **Civilization tech tree**).

**Progression Path**:
1. **Salvage alien tech** (from missions)
2. **Research alien tech** (in research lab)
3. **Unlock manufacturing** (research completion)
4. **Manufacture equipment** (in workshop)
5. **Equip units** (via inventory)

**Tech Tree Branches**:
- **Weapons**: Conventional → Laser → Plasma → Particle Beam
- **Armor**: Body Armor → Composite → Alien Alloys → Energy Shields
- **Special**: Psionic, Gravitational (late game)

---

### Q: Can I buy equipment directly?

**A**: **Yes** - Via marketplace from 6 suppliers (but research-locked).

**Purchase Limitations**:
- **Tech Prerequisites**: Cannot buy alien-tech items until researched
- **Supplier Relations**: Poor relations restrict access
- **Fame Requirements**: Low fame blocks premium suppliers
- **Pricing**: Marketplace 30-50% more expensive than manufacturing

**When to Buy**:
- Early game (no manufacturing yet)
- Emergency replacements (need equipment NOW)
- Rare items (limited availability)

**When to Manufacture**:
- Mid-late game (workshops operational)
- Bulk production (cheaper per unit)
- Alien tech (requires manufacturing)

---

## Crafting & Manufacturing

### Q: How does manufacturing work?

**A**: **StarCraft-style production queue** with resource requirements.

**Manufacturing Mechanics**:
- **Requirements**: Engineers + Workshop + Raw Materials + Credits
- **Time**: Variable (1-30 days depending on item complexity)
- **Queue**: Can queue 3-10 projects simultaneously
- **Efficiency**: More engineers = faster production (diminishing returns)

**Production Cost**:
```
Total Cost = (Base Item Cost) × Quantity
Daily Cost = Total Cost / Days to Complete
Resource Consumption = Item Resource Requirements × Quantity
```

**Example**:
- Laser Rifle: 2,000 credits, 5 days, 2 engineers
- With 4 engineers: 3 days (80% speed boost)
- With 10 engineers: 2 days (60% average speed)

---

### Q: Where do I get raw materials?

**A**: **Salvage system** (primary source) + **Marketplace** (secondary).

**Material Sources**:
1. **Mission Salvage**:
   - Enemy equipment (50% market value)
   - UFO components (alien alloys, elerium)
   - Corpses (autopsy research)
   
2. **Marketplace Purchase**:
   - Raw materials supplier (80-110% base cost)
   - Bulk discounts available
   
3. **Scrap Processing**:
   - Damaged items → scrap (50-75% value)
   - Workshop processing (1-2 days)

**Salvage Value** (Post-Mission):
- Early game: 500-2,000 credits
- Mid game: 3,000-10,000 credits
- Late game: 10,000-50,000 credits
- UFO crash: 20,000-100,000 credits

---

## Salvage & Loot

### Q: What can I salvage?

**A**: Everything on the battlefield (automatic collection after victory).

**Salvage Categories**:

1. **Enemy Equipment**:
   - Weapons (70-90% condition)
   - Armor (40-70% condition)
   - Ammunition (100% condition)
   
2. **Corpses**:
   - Human: Resurrection only (0 credits)
   - Alien: 500-5,000 credits (research or black market)
   
3. **UFO Components**:
   - Power Source: 10,000-30,000 credits
   - Navigation: 5,000-15,000 credits
   - Alloys: 3,000-10,000 credits per unit
   - Weapons: 8,000-25,000 credits
   
4. **Mission Artifacts**:
   - Special items: 10,000-50,000 credits
   - Quest items: Variable value
   
5. **Environmental Loot**:
   - Ammo crates: 50-500 credits
   - Supplies: 100-1,000 credits

---

### Q: How does salvage condition work?

**A**: **Condition states** determine value and usability.

**Condition Tiers**:
- **Pristine (90-100%)**: Full price, use immediately
- **Good (70-90%)**: 90% value, minor damage
- **Damaged (40-70%)**: 50% value, requires repair before use
- **Scrap (10-40%)**: 25% value, salvage components only
- **Destroyed (<10%)**: 10% value, raw materials only

**Condition After Combat**:
- Enemy weapons: 70-90% (damaged by combat)
- Enemy armor: 40-70% (damaged by killing blow)
- Corpses: 100% (always perfect for research)
- UFO components: 30-80% (depends on crash severity)

---

### Q: What's the salvage processing time?

**A**: Depends on item type and complexity.

**Processing Times**:

| Item Type | Time | Facility | Result |
|-----------|------|----------|--------|
| **Common Equipment** | Instant | None | Use or sell immediately |
| **Alien Weapons** | 2-5 days | Workshop | Unlock manufacturing |
| **Alien Armor** | 3-7 days | Workshop | Unlock manufacturing |
| **UFO Components** | 5-15 days | Workshop | Alien materials |
| **Scrap Metal** | 1-2 days | Workshop | Raw materials |
| **Alien Artifacts** | 10-50 man-days | Research Lab | Research unlock |
| **Alien Corpses** | 20-80 man-days | Research Lab | Autopsy knowledge |

---

## Game Comparisons

### Q: How similar is the item system to X-COM?

**Comparison**:

| Feature | X-COM (1994) | XCOM 2 (2016) | AlienFall |
|---------|--------------|---------------|-----------|
| **Tech Progression** | ✅ Yes | ✅ Yes | ✅ Yes |
| **Salvage System** | ✅ Yes | ✅ Yes | ✅ Expanded |
| **Weapon Mods** | ❌ No | ✅ Yes | ⚠️ Planned |
| **Armor Tiers** | ✅ Simple | ✅ Complex | ✅ Very complex |
| **Inventory Weight** | ✅ Yes | ❌ No | ✅ Yes (Strength-based) |
| **Damage Types** | ⚠️ Basic | ⚠️ Basic | ✅ 11 types |
| **Manufacturing** | ✅ Yes | ✅ Yes | ✅ Enhanced |
| **Equipment Slots** | ⚠️ Many | ⚠️ Limited | ⚠️ 3 slots |

**Biggest Differences**:
1. **Damage Type System**: 11 types vs. X-COM's 3-4
2. **Armor Resistances**: Specialized armor for specific threats
3. **Salvage Condition**: Condition states affect value/usability
4. **Weight System**: Resident Evil-style capacity vs. XCOM 2's slot system
5. **Manufacturing Queue**: StarCraft-style production queue

---

### Q: Is this like Diablo's item system?

**A**: **Partially** - Armor resistances are similar, but no random stats.

**Similarities**:
- ✅ Damage type resistances (fire, cold, etc.)
- ✅ Equipment slot limitations
- ✅ Item rarity tiers (common, rare, legendary)
- ✅ Inventory weight management

**Differences**:
- ❌ No random stat generation (fixed item stats)
- ❌ No unique/legendary items with special abilities (planned future feature)
- ❌ No socketing system (no gems/runes)
- ✅ But: Manufacturing system (craft exact items)

**If you like Diablo's tactical depth, you'll appreciate AlienFall's damage type complexity.**

---

### Q: How does it compare to Resident Evil inventory?

**A**: **Similar** weight/capacity system.

**Similarities**:
- ✅ Weight-based capacity (Strength stat = capacity)
- ✅ Binary system (carry all or none)
- ✅ Strategic item management (what to carry?)
- ✅ Dropping items to make space

**Differences**:
- ❌ No grid-based tetris inventory (just weight values)
- ❌ No item combining (no herb mixing)
- ✅ Can swap items during missions (more flexible)

---

## Related Content

**For detailed information, see**:
- **[Items.md](../mechanics/Items.md)** - Complete item specifications
- **[Economy.md](../mechanics/Economy.md)** - Manufacturing and salvage systems
- **[Units.md](../mechanics/Units.md)** - Equipment restrictions and synergies
- **[Battlescape.md](../mechanics/Battlescape.md)** - Combat mechanics and damage
- **[Missions.md](../mechanics/Missions.md)** - Salvage opportunities

---

## Quick Reference

**Weapon Categories**: 8 (Rifles, Pistols, Snipers, Shotguns, Heavy, Melee, Grenades, Special)  
**Armor Types**: 7 (Light Scout to Heavy Assault + specialized)  
**Damage Types**: 11 (Kinetic, Explosive, Energy, etc.)  
**Equipment Slots**: 3 (Primary, Secondary, Armor)  
**Carry Capacity**: Strength stat (6-12 units)  
**Salvage Conditions**: 5 (Pristine → Destroyed)  
**Tech Progression**: 4 tiers (Conventional → Laser → Plasma → Particle Beam)  
**Manufacturing**: Workshop + Engineers + Materials + Time

