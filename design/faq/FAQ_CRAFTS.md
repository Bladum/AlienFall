# FAQ: Crafts & Pilots

> **Audience**: Experienced strategy gamers familiar with X-COM, Ace Combat, Flight Simulators  
> **Last Updated**: 2025-10-28  
> **Related Mechanics**: [Crafts.md](../mechanics/Crafts.md), [Units.md §Pilots](../mechanics/Units.md#unified-pilot-specification), [Interception.md](../mechanics/Interception.md)

---

## Quick Navigation

- [Craft Types & Roles](#craft-types--roles)
- [Pilot System](#pilot-system)
- [Fuel & Travel](#fuel--travel)
- [Craft Equipment](#craft-equipment)
- [Base Defense](#base-defense)
- [Game Comparisons](#game-comparisons)

---

## Craft Types & Roles

### Q: What craft types exist?

**A**: **6 main categories** from transport to interceptor (like **X-COM** craft variety).

**Craft Categories**:

### 1. **Transport Craft** (Troop Deployment)
- **Role**: Deploy soldiers to missions
- **Capacity**: 8-14 units + equipment
- **Speed**: 1.5 hexes/turn (slow)
- **Weapons**: None or light defense
- **Examples**: Skyranger, Skyfortress

### 2. **Interceptor Craft** (Air Combat)
- **Role**: Destroy UFOs
- **Capacity**: 1-2 pilots only
- **Speed**: 3 hexes/turn (fast)
- **Weapons**: Heavy guns, missiles
- **Examples**: Falcon, Firestorm

### 3. **Bomber Craft** (Ground Attack)
- **Role**: Strategic bombing missions
- **Capacity**: 2-4 crew
- **Speed**: 2 hexes/turn (medium)
- **Weapons**: Bombs, rockets
- **Examples**: Thunderbolt, Devastator

### 4. **Scout Craft** (Reconnaissance)
- **Role**: Detect UFOs, reveal map
- **Capacity**: 1-2 pilots
- **Speed**: 2.5 hexes/turn (fast)
- **Weapons**: Light defense
- **Examples**: Raven, Spectre

### 5. **Carrier Craft** (Mobile Base)
- **Role**: Long-range operations
- **Capacity**: 20-30 units + workshops
- **Speed**: 1 hex/turn (very slow)
- **Weapons**: Heavy defense
- **Examples**: Avenger (late game)

### 6. **Hybrid Craft** (Multi-Role)
- **Role**: Transport + combat
- **Capacity**: 6-10 units
- **Speed**: 2 hexes/turn
- **Weapons**: Medium guns
- **Examples**: Lightning, Marauder

---

### Q: How many craft can I have?

**A**: Limited by **hangar capacity** (like **X-COM** hangar system).

**Hangar Limits**:
- **Small Hangar**: 1 craft (any size)
- **Large Hangar**: 2 craft (small/medium) OR 1 large craft
- **Carrier Hangar**: 1 carrier craft only

**Base Example**:
- 2× Small Hangars = 2 craft total
- 1× Large Hangar = 2 small OR 1 large
- Total: 3-4 craft per base

**Strategic Implications**:
- Must choose craft roles carefully
- Multiple bases expand craft fleet
- Hangar construction priority decision

---

### Q: Can craft be destroyed?

**A**: **Yes** - Craft can be shot down and lost permanently (like **XCOM** ironman).

**Craft Loss Conditions**:
- **Interception defeat**: HP reaches 0 in air combat
- **UFO crash**: Rare chance during landing
- **Base attack**: Destroyed in hangar by enemies

**Loss Consequences**:
- Craft destroyed permanently
- Pilots aboard: 50% chance survival
- Equipment salvaged: 25% of craft value
- Must rebuild (expensive and time-consuming)

**Protection**:
- Better armor reduces destruction chance
- Skilled pilots reduce loss risk (-10% per 20 pilot skill)
- Multiple craft provide redundancy

---

## Pilot System

### Q: How do pilots work?

**A**: **Dual-role system** - Units can be soldiers OR pilots (see [Units.md](../mechanics/Units.md#unified-pilot-specification)).

**Key Principle**: All units have a **Piloting stat** (0-100), but only Pilot class specialists can operate craft effectively.

**Piloting Requirements**:

| Craft Type | Minimum Piloting | Recommended Class |
|------------|------------------|-------------------|
| **Transport** | 30 | Any unit (basic flight) |
| **Scout** | 40 | Pilot class |
| **Interceptor** | 50 | Fighter Pilot specialization |
| **Bomber** | 50 | Bomber Pilot specialization |
| **Carrier** | 70 | Ace Pilot (Rank 4+) |

---

### Q: Can soldiers also pilot craft?

**A**: **Yes** - Any unit can attempt piloting, but specialists are better.

**Untrained Pilot Penalties**:
- **Piloting <30**: Cannot fly (crash risk 100%)
- **Piloting 30-49**: Can fly transports only (50% combat penalty)
- **Piloting 50-69**: Basic flight (no combat bonuses)
- **Piloting 70-89**: Competent (standard performance)
- **Piloting 90-100**: Expert (bonus speed, accuracy)

**Strategic Decisions**:
- Use soldiers for transport flights (saves pilot slots)
- Dedicate Pilot class units to combat craft
- Train units in Academy (+5 piloting per month)

---

### Q: How do pilots gain experience?

**A**: **Dual XP tracks** - Ground combat XP + Piloting XP (separate).

**Ground Combat XP** (Standard):
- Kills, objectives, participation (see [FAQ_UNITS.md](FAQ_UNITS.md))
- Applies when unit deploys to battlescape

**Piloting XP** (Separate):
- **Interception victory**: +5 piloting per UFO destroyed
- **Successful mission**: +2 piloting per mission completed
- **Evasion**: +1 piloting per successful dodge
- **Academy training**: +5 piloting per month

**Piloting Progression**:
- Piloting 30: Can fly basic craft
- Piloting 50: Can fly combat craft
- Piloting 70: Ace status (+10% combat bonuses)
- Piloting 90: Master pilot (+20% bonuses)

---

### Q: What happens if a pilot dies?

**A**: **Craft grounded** until replacement found (like **Ace Combat** pilot loss).

**Pilot Loss Impact**:
- Craft cannot fly without pilot
- Interception missions unavailable
- Transport missions require replacement
- Must train or recruit new pilot (weeks)

**Replacement Options**:
1. **Promote existing unit**: Train soldier to pilot (1-3 months)
2. **Recruit pilot**: Hire pilot directly (expensive, 50,000 credits)
3. **Academy training**: Fast-track soldier (5,000 credits, 1 month)

**Strategic Risk**:
- Veteran pilots extremely valuable (rare)
- Losing ace pilot = months to replace
- Multiple pilots per base recommended

---

## Fuel & Travel

### Q: How does fuel work?

**A**: **Limited resource** per craft (like **flight simulators**).

**Fuel Mechanics**:
- Each craft has **fuel capacity** (100-500 units)
- **Movement costs fuel** (1 fuel per hex traveled)
- **Refueling**: Automatic at base (free)
- **Empty fuel**: Craft must return to base or crash

**Fuel Capacity by Type**:

| Craft Type | Fuel Capacity | Max Range |
|------------|---------------|-----------|
| **Interceptor** | 150 | 150 hexes |
| **Transport** | 300 | 300 hexes |
| **Scout** | 200 | 200 hexes |
| **Bomber** | 250 | 250 hexes |
| **Carrier** | 500 | 500 hexes |

**Strategic Implications**:
- Must plan routes (cannot cross entire map)
- Fuel bases enable long-range operations
- Emergency refuel available (expensive, 5,000 credits)

---

### Q: Can craft run out of fuel mid-flight?

**A**: **Yes** - **Forces emergency landing** or crash (risk mechanic).

**Out of Fuel Scenarios**:
1. **Over friendly territory**: Emergency landing at nearest base (safe)
2. **Over hostile territory**: Crash landing (50% crew survival, craft destroyed)
3. **Over ocean**: Crash into water (25% crew survival, craft destroyed)

**Fuel Management**:
- UI shows fuel remaining and range circle
- Warning at 25% fuel ("Return to base recommended")
- Auto-return option (craft automatically returns at 50% fuel)

---

### Q: How fast do craft travel?

**A**: Speed varies by type (1-3 hexes/turn).

**Travel Speed**:

| Craft Type | Speed | Time to Cross Map (90 hexes) |
|------------|-------|------------------------------|
| **Carrier** | 1 hex/turn | 90 turns (90 hours) |
| **Transport** | 1.5 hex/turn | 60 turns (60 hours) |
| **Bomber** | 2 hex/turn | 45 turns (45 hours) |
| **Scout** | 2.5 hex/turn | 36 turns (36 hours) |
| **Interceptor** | 3 hex/turn | 30 turns (30 hours) |

**Time = Critical Resource**:
- UFOs can escape if pursuit too slow
- Mission windows limited (12-48 hours typically)
- Fast craft provide strategic flexibility

---

## Craft Equipment

### Q: Can I customize craft loadouts?

**A**: **Yes** - **Modular equipment system** (like **Ace Combat** aircraft customization).

**Equipment Slots**:
1. **Weapons** (2 slots): Guns, missiles, bombs
2. **Systems** (2 slots): Radar, jammer, shields
3. **Armor** (1 slot): Light, medium, heavy
4. **Engine** (1 slot): Standard, advanced, alien

---

### Q: What weapons can craft use?

**A**: **8 weapon categories** from guns to missiles.

**Craft Weapons**:

| Weapon | Damage | Range | Ammo | Best For |
|--------|--------|-------|------|----------|
| **Cannon** | 15 | 5 hexes | Infinite | Sustained fire |
| **Laser** | 20 | 8 hexes | Infinite | No reload |
| **Plasma** | 30 | 10 hexes | Infinite | Late game |
| **Missile** | 50 | 15 hexes | 6 shots | Burst damage |
| **Torpedo** | 80 | 20 hexes | 3 shots | Heavy targets |
| **Bomb** | 100 | Drop | 5 bombs | Ground attack |
| **EMP** | 0 (stun) | 10 hexes | 4 shots | Disable UFOs |
| **Nuclear** | 500 | 30 hexes | 1 shot | Ultimate weapon |

**Strategic Choices**:
- **Cannons**: Reliable, no ammo limit
- **Missiles**: High burst damage, limited ammo
- **Lasers**: Alien tech, no reload
- **Bombs**: Ground missions only

---

### Q: What about craft armor?

**A**: **3 tiers** from light to heavy (trade-off: protection vs. speed).

**Armor Types**:

| Armor | HP Bonus | Speed Penalty | Cost |
|-------|----------|---------------|------|
| **Light Alloy** | +50 HP | 0 | 20K |
| **Composite** | +100 HP | -0.5 hex/turn | 50K |
| **Alien Alloy** | +200 HP | 0 | 100K |
| **Heavy Plating** | +300 HP | -1 hex/turn | 150K |

**Strategic Implications**:
- Light armor: Fast but fragile (scouts)
- Heavy armor: Slow but tanky (bombers)
- Alien tech: Best of both worlds (expensive)

---

## Base Defense

### Q: Can craft defend bases?

**A**: **Yes** - Craft provide **base defense** during attacks.

**Base Defense Roles**:
1. **Air Defense**: Intercept attacking UFOs before they land
2. **Ground Support**: Provide fire support during base defense missions
3. **Evacuation**: Extract personnel if base falls

**Defense Mechanics**:
- Craft in hangar: **Automatically scrambles** when base attacked
- Pilot required: Craft can't launch without pilot
- Damage: Craft can be destroyed in hangar if not launched

**Strategic Value**:
- Multiple craft = layered defense
- Interceptors critical for base survival
- Losing craft in hangar = permanent loss

---

### Q: What happens if base is attacked and craft are on mission?

**A**: **Base defenseless** - Must defend with ground forces only.

**Away Craft Scenario**:
- Craft on mission cannot defend base
- Base defense relies on facilities and ground units
- May lose craft in hangar if base overrun

**Strategic Risk Management**:
- Keep at least 1 interceptor at base
- Multiple bases provide redundancy
- Emergency recall option (craft returns immediately, costs extra fuel)

---

## Game Comparisons

### Q: How similar is this to X-COM craft system?

**Comparison**:

| Feature | X-COM (1994) | XCOM 2 (2016) | AlienFall |
|---------|--------------|---------------|-----------|
| **Craft Types** | 5 types | 2 types | 6 types |
| **Pilot System** | ❌ None | ❌ None | ✅ Yes |
| **Fuel Limits** | ✅ Yes | ❌ No | ✅ Yes |
| **Equipment Slots** | ✅ Yes | ⚠️ Limited | ✅ Extensive |
| **Base Defense** | ✅ Yes | ⚠️ Limited | ✅ Yes |
| **Craft Loss** | ✅ Permanent | ⚠️ Temporary | ✅ Permanent |

**Biggest Differences**:
1. **Pilot system**: AlienFall has pilot progression (X-COM doesn't)
2. **Dual-role units**: Units can be soldiers OR pilots
3. **Fuel management**: More realistic (XCOM 2 has infinite fuel)

---

### Q: Is this like Ace Combat?

**A**: **Partially** - Similar pilot progression, different combat system.

**Similarities**:
- ✅ Pilot skill progression
- ✅ Aircraft customization (weapons, equipment)
- ✅ Ace pilot bonuses
- ✅ Multiple aircraft types

**Differences**:
- ❌ No dogfighting (card-based interception instead)
- ❌ No 3D flight mechanics (hex-based strategy)
- ✅ But: Pilots can deploy to ground combat (unique)

**If you like Ace Combat pilot progression, you'll appreciate AlienFall's pilot XP system.**

---

### Q: How does it compare to flight simulators?

**A**: **Not a simulator** - **Strategic craft management**, not realistic flight.

**What's Similar**:
- ✅ Fuel management
- ✅ Equipment loadouts
- ✅ Multiple aircraft types

**What's Different**:
- ❌ No realistic physics (hex movement)
- ❌ No cockpit view (strategic map)
- ❌ No complex controls (automated flight)

**AlienFall is X-COM with pilot depth, not a flight sim.**

---

## Related Content

**For detailed information, see**:
- **[Crafts.md](../mechanics/Crafts.md)** - Complete craft specifications
- **[Units.md §Pilots](../mechanics/Units.md#unified-pilot-specification)** - Pilot progression system
- **[Interception.md](../mechanics/Interception.md)** - Air combat mechanics
- **[Basescape.md](../mechanics/Basescape.md)** - Hangar construction and base defense
- **[Geoscape.md](../mechanics/Geoscape.md)** - Craft movement on world map

---

## Quick Reference

**Craft Types**: 6 (Transport, Interceptor, Bomber, Scout, Carrier, Hybrid)  
**Pilot Requirement**: Piloting stat 30+ (basic), 50+ (combat), 70+ (ace)  
**Dual Role**: Units can be soldiers OR pilots (not both simultaneously)  
**Fuel System**: 1 fuel per hex traveled, automatic refuel at base  
**Equipment Slots**: 2 weapons, 2 systems, 1 armor, 1 engine  
**Speed Range**: 1-3 hexes/turn (Carrier slowest, Interceptor fastest)  
**Base Defense**: Craft automatically scramble when base attacked  
**Craft Loss**: Permanent (must rebuild), 50% pilot survival chance  
**Piloting XP**: Separate from ground combat XP, +5 per UFO kill

