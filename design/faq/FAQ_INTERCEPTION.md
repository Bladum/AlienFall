# FAQ: Interception - Air Combat

[← Back to FAQ Index](FAQ_INDEX.md)

---

## Q: What is Interception? How is it different from X-COM?

**A**: **Turn-based card combat, not real-time dodging**:

Interception is the air combat layer where:
- Craft engage UFOs in turn-based combat
- Weapons are played like cards from your hand
- Energy and action points limit actions
- Multi-sector tactical positioning matters
- Victory allows ground mission; defeat forces retreat

**Key Difference from X-COM**:
- **X-COM**: Real-time minigame with dodging and positioning
- **AlienFall**: Turn-based card combat like Magic: The Gathering
- **Why?**: More strategic depth, less twitch skill, consistent with turn-based philosophy

**Comparisons**:
- **Like Magic: The Gathering**: Card-based tactical combat with mana
- **Like Slay the Spire**: Deck building with action points
- **Like Hearthstone**: Board control with positioning
- **Unlike X-COM**: Not real-time, no manual dodging
- **Like FTL**: Crew management with weapon systems

---

## Q: How does the card system work?

**A**: **Weapons as cards, energy as mana**:

### Card Combat Basics

**Your "Deck"**:
- Each weapon on your craft = one card
- Draw weapons based on craft configuration
- Play weapons by spending energy + action points
- Discard pile when weapons cooldown

**Example Craft Loadout**:
```
Craft: F-16 Interceptor
Weapons (Cards):
  - Cannon (2 AP, 1 Energy) - Always available
  - Sidewinder Missile (3 AP, 3 Energy) - Heavy damage
  - Countermeasures (1 AP, 2 Energy) - Defensive
  - Afterburner (2 AP, 4 Energy) - Mobility
```

### Comparison to Card Games

| Mechanic | AlienFall | MTG | Hearthstone | Slay the Spire |
|----------|-----------|-----|-------------|----------------|
| **Cards** | Craft weapons | Spell cards | Spell cards | Attack cards |
| **Mana** | Energy Points | Mana pool | Mana crystals | Energy |
| **Turn limit** | Action Points | None | Actions per turn | 3 cards/turn |
| **Board** | 3 sectors | Battlefield | Board | Single enemy |
| **Deck** | Fixed loadout | 60 cards | 30 cards | Draw pile |

---

## Q: What are Action Points and Energy Points?

**A**: **Dual resource system like MTG with time units**:

### Action Points (AP)
- Represent **time** during your turn
- Each turn gives you 6-10 AP (varies by craft)
- Spent on actions: move, shoot, defend
- Similar to X-COM Time Units

### Energy Points (EP)
- Represent **power** for weapons
- Pool size depends on craft power generators
- Regenerates each turn (+5-10 EP typical)
- Similar to MTG mana

### Example Turn
```
Start: 10 AP, 15 EP available

Action 1: Fire Cannon (2 AP, 1 EP)
  → Remaining: 8 AP, 14 EP

Action 2: Fire Missile (3 AP, 3 EP)
  → Remaining: 5 AP, 11 EP

Action 3: Activate Shield (2 AP, 4 EP)
  → Remaining: 3 AP, 7 EP

Action 4: Move to Air Sector (3 AP, 0 EP)
  → Remaining: 0 AP, 7 EP (turn ends)
```

**Comparison**:
- **Like MTG**: Energy = mana, must manage both resources
- **Like X-COM**: AP = time units
- **Like Slay the Spire**: Limited energy per turn
- **Unlike Hearthstone**: Two resources, not one

---

## Q: What are the three sectors? Why do they matter?

**A**: **Vertical battlefield positioning like naval combat**:

### Three Combat Sectors

| Sector | Altitude | Craft Types | Strategic Role |
|--------|----------|-------------|---------------|
| **Air** | Upper | Fighters, interceptors, UFOs | Air superiority, bombing runs |
| **Land/Water** | Middle | Ground bases, coastal defenses | Static defense, support |
| **Underground** | Lower | Submarine bases, bunkers | Hidden operations, last resort |

### Sector Mechanics

**Positioning**:
- Maximum 4 objects per sector (craft, bases, UFOs, missions)
- Cannot directly attack different sectors (need appropriate weapons)
- Moving between sectors costs AP and leaves you vulnerable

**Weapon Requirements**:
- **Air-to-Air**: Engage aircraft in same sector
- **Air-to-Land**: Bomb ground installations from Air sector
- **Air-to-Underwater**: Anti-submarine weapons
- **Land-to-Air**: AA defenses shoot at Air sector

**Comparison**:
- **Like Hearthstone**: Board zones with positioning
- **Like naval warfare**: Surface vs. submarine layers
- **Like StarCraft**: Air vs. ground unit targeting
- **Unlike FTL**: Not room-based, sector-based

---

## Q: How do I build my craft "deck"?

**A**: **Equipment loadout like Armored Core or Ace Combat**:

### Craft Customization

**Loadout Slots**:
- Weapon slots: 2-6 weapons (depends on craft)
- Defense slots: 1-3 systems (shields, armor, ECM)
- Utility slots: 1-2 systems (radar, generators)

**Weapon Selection Strategy**:
- **Balanced**: Mix of weapons for all ranges
- **Alpha strike**: Heavy burst damage, long cooldowns
- **Sustained DPS**: Rapid-fire low damage
- **Anti-capital**: Specialized for large targets
- **Anti-fighter**: Fast-firing for agile UFOs

### Example Loadouts

**Fighter Loadout** (anti-UFO):
```
- 2× Rapid Cannon (low cost, high RoF)
- 1× Missile Pod (burst damage)
- 1× Countermeasures (defense)
- 1× Afterburner (mobility)
```

**Bomber Loadout** (anti-base):
```
- 1× Heavy Bomb (max damage)
- 1× Precision Missile (targeted strike)
- 2× Point Defense (survival)
- 1× Shield Generator (protection)
```

**Comparison**:
- **Like Armored Core**: Mech customization with weight limits
- **Like Ace Combat**: Aircraft loadouts for missions
- **Like MTG deck building**: Synergy between cards
- **Like Slay the Spire**: Build for specific strategy

---

## Q: How does weapon range work?

**A**: **Turn delay before impact (unique mechanic)**:

### Range as Flight Time

Range is measured in **turns to impact**, not distance:

| Range Class | Turns to Impact | Weapon Examples | Tactical Implication |
|-------------|----------------|-----------------|---------------------|
| **Point Blank** | 5 turns | Slow rockets, bombs | Close-range brawl |
| **Short** | 4 turns | Medium missiles | Standard engagement |
| **Medium** | 3 turns | Fast missiles | Most common range |
| **Long** | 2 turns | Rapid projectiles | Sniper weapons |
| **Very Long** | 1 turn | Laser weapons | Near-instant |

### Why This Matters

**Flight Time Creates Tactics**:
- Fire long-range weapons first (arrive later)
- Time burst damage to hit simultaneously
- Evade incoming slow projectiles
- Layer attacks for sustained pressure

**Example Combat**:
```
Turn 1: Fire long-range missile (2 turn delay)
Turn 2: Fire medium-range cannon (3 turn delay)
Turn 3: Both weapons hit this turn (coordinated strike)
```

**Comparison**:
- **Like FTL**: Weapons have charge times
- **Unlike MTG**: Not instant resolution
- **Like Into the Breach**: Telegraph enemy attacks
- **Unique mechanic**: Range = time, not space

---

## Q: What about weapon cooldowns?

**A**: **Separate from range, like ability cooldowns**:

### Cooldown System

**How It Works**:
- Cooldown = turns between firing same weapon
- Starts after weapon is fired (not after impact)
- Independent of range/flight time

**Example**:
```
Missile Weapon:
  - Range: 1 turn to impact (very fast)
  - Cooldown: 3 turns between shots
  
Turn 1: Fire missile (hits Turn 2)
Turn 2: Missile hits, but still on cooldown
Turn 3: Still on cooldown
Turn 4: Can fire again
```

**Weapon Categories**:
- **Rapid fire**: 0-1 turn cooldown (cannons)
- **Standard**: 2-3 turn cooldown (missiles)
- **Heavy**: 4-5 turn cooldown (bombs, torpedoes)
- **Special**: Variable (lasers, experimental)

**Comparison**:
- **Like MOBA abilities**: Cooldown per skill
- **Like X-COM**: TU cost per action
- **Like MTG**: Tap/untap mechanics
- **Unlike StarCraft**: Not continuous fire

---

## Q: How do I win interception combat?

**A**: **Destroy enemy or force retreat**:

### Victory Conditions

**Player Victory**:
- Destroy all enemy craft/UFOs
- Force enemy to retreat (low HP)
- Enemy runs out of energy/weapons

**Player Defeat**:
- Your craft destroyed
- Run out of energy AND ammo
- Choose to retreat (preserve craft)

**Outcomes**:
- **Victory**: Proceed to ground mission (Battlescape)
- **Defeat**: Lose craft, pilot, mission opportunity
- **Mutual destruction**: Both sides destroyed (rare)

**Comparison**:
- **Like MTG**: Reduce opponent to 0 life
- **Like FTL**: Destroy enemy ship
- **Unlike X-COM**: Can retreat without mission fail
- **Like Slay the Spire**: Boss fights or die

---

## Q: What happens to damaged craft?

**A**: **Repair time and costs**:

### Damage and Repairs

**Damage Types**:
- **Light damage** (75-100% HP): 1-3 days repair
- **Moderate damage** (50-74% HP): 4-7 days repair
- **Heavy damage** (25-49% HP): 8-15 days repair
- **Critical damage** (1-24% HP): 16-30 days repair
- **Destroyed** (0% HP): Craft lost, need new craft

**Repair Costs**:
- Credit cost scales with damage severity
- Requires base hangar facility
- Engineers speed repair (more engineers = faster)
- Can prioritize repair of critical craft

**Comparison**:
- **Like X-COM**: Damaged craft need time to repair
- **Like World of Warships**: Damage persists between battles
- **Unlike StarCraft**: Ships don't auto-heal
- **Like Darkest Dungeon**: Heroes need recovery

---

## Q: How do pilots affect interception?

**A**: **Pilot skills modify craft performance**:

### Pilot System

**Pilot Skills**:
- **Accuracy**: Improves weapon hit chance
- **Evasion**: Chance to dodge incoming fire
- **Energy Management**: Increased EP regeneration
- **Initiative**: Act earlier in turn order

**Pilot Experience**:
- Gain XP from successful interceptions
- Level up to improve skills
- Can specialize (Fighter Ace, Bomber Pilot, etc.)
- Permadeath if craft destroyed

**Comparison**:
- **Like Ace Combat**: Named pilots with skills
- **Like XCOM 2**: Soldier-style progression
- **Like Fire Emblem**: Named units with growth
- **Unlike X-COM (original)**: Pilots have identity

**See [Pilots FAQ](FAQ_CRAFTS.md#pilots) for full details**

---

## Q: Can I have multiple craft in one interception?

**A**: **Yes, wing-based combat**:

### Multi-Craft Engagements

**Wing Formation**:
- Deploy 1-4 craft to same engagement
- Each craft acts independently (own AP/EP)
- Shared battlefield (same 3 sectors)
- Coordinate attacks for combos

**Strategic Benefits**:
- Overwhelm single UFO with numbers
- Specialize craft roles (fighter + bomber)
- Cover each other's weaknesses
- Absorb damage across multiple hulls

**Comparison**:
- **Like FTL**: Multiple ships in fleet (modded)
- **Like XCOM 2**: Multi-squad missions
- **Unlike X-COM**: Not one-vs-one only
- **Like naval warfare**: Task force coordination

---

## Q: What's the difference between interception and base defense?

**A**: **Same system, different context**:

### Interception vs. Base Defense

| Aspect | Interception | Base Defense |
|--------|--------------|--------------|
| **Location** | Over province | At your base |
| **Player units** | Craft only | Craft + base defenses |
| **Enemy units** | UFOs, alien craft | UFOs + ground assault |
| **Stakes** | Lose craft | Lose entire base |
| **Retreat option** | Yes | No (defend or die) |

**Base Defense Mechanics**:
- Base defense facilities act as "units"
- Have their own weapons (turrets, missiles)
- Static position (Land sector)
- If interception lost → ground battle (Battlescape)

**Comparison**:
- **Like X-COM base defense**: High stakes battle
- **Like Tower Defense**: Static defenses + mobile units
- **Unlike FTL**: Can't retreat from base assault
- **Like StarCraft**: Defend your main base

---

## Q: How do environmental effects work?

**A**: **Biome-based modifiers**:

### Environmental Hazards

**Biome Effects**:
- **Ocean**: Water sector combat, different weapons
- **Mountain**: Altitude affects performance
- **Arctic**: Ice damage to craft systems
- **Desert**: Heat reduces EP regeneration
- **Urban**: Limited maneuverability

**Strategic Implications**:
- Equip craft for expected biomes
- Specialized weapons for terrain
- Pilot skills matter more in harsh conditions

**Comparison**:
- **Like MTG**: Different "lands" affect play
- **Like Into the Breach**: Environmental hazards
- **Unlike X-COM**: Not cosmetic differences
- **Like Civilization**: Terrain affects combat

---

## Q: Is there RNG in interception?

**A**: **Yes, but manageable**:

### Randomness Factors

**RNG Elements**:
- Hit chance rolls (weapon accuracy)
- Crit chance rolls (bonus damage)
- Evasion rolls (dodge attacks)

**Controlled Factors**:
- Your deck (weapon loadout)
- Your positioning (sector choice)
- Your tactics (when to fire, when to defend)
- Your pilot skills (improve RNG odds)

**Reducing RNG**:
- High-accuracy weapons (more consistent)
- Multiple weapons (more attempts)
- Pilot training (better odds)
- Defensive systems (mitigate bad rolls)

**Comparison**:
- **Like XCOM 2**: RNG but mitigatable
- **Less than X-COM**: Fewer random factors
- **More than Into the Breach**: Not deterministic
- **Like MTG**: RNG in draws, skill in play

---

## Q: Can I automate interceptions?

**A**: **Yes, with consequences**:

### Auto-Resolve Option

**How It Works**:
- Click "Auto-Resolve" instead of manual combat
- AI calculates outcome based on stats
- Instant result (no tactical play)
- Higher variance in outcomes

**When to Use**:
- Overwhelming advantage (you vastly outclass enemy)
- Low-stakes missions (don't care about efficiency)
- Time-saving (skip tedious fights)

**When to Avoid**:
- Close matchups (tactical play matters)
- Rare/valuable pilots (don't risk RNG)
- Learning experience (need to practice)

**Comparison**:
- **Like Total War**: Auto-resolve battles
- **Like XCOM 2**: No auto-resolve option
- **Like Civilization**: Skip combat animations
- **Risk**: Lose more craft than manual play

---

## Q: What makes a good interception strategy?

**A**: **Energy management + weapon timing + positioning**:

### Core Strategies

**Alpha Strike**:
- Heavy weapons, high burst
- Win quickly or lose
- High risk, high reward

**Attrition**:
- Sustained fire, outlast enemy
- Defensive focus, energy regen
- Low risk, slow victory

**Hit-and-Run**:
- Mobile craft, strike from range
- Evade, reposition, strike again
- Medium risk, tactical play

**Comparison**:
- **Like MTG archetypes**: Aggro, Control, Combo
- **Like StarCraft**: Rush, Macro, Cheese
- **Like Slay the Spire**: Build archetypes
- **Player choice**: Multiple viable strategies

---

## Next Steps

- **Master craft loadouts**: Read [Crafts FAQ](FAQ_CRAFTS.md)
- **Understand pilot progression**: Read [Units FAQ](FAQ_UNITS.md#pilots)
- **Learn weapon types**: Read [Items FAQ](FAQ_ITEMS.md#craft-weapons)
- **See full mechanics**: Check [design/mechanics/Interception.md](../mechanics/Interception.md)

[← Back to FAQ Index](FAQ_INDEX.md)

