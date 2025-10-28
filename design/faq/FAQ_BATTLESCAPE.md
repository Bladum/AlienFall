# FAQ: Battlescape - Tactical Combat

[← Back to FAQ Index](FAQ_INDEX.md)

---

## Q: What is Battlescape? Is it like X-COM combat?

**A**: **Yes, but with roguelike procedural generation**:

Battlescape is turn-based squad combat where you:
- Control 4-12 soldiers in hex-based combat
- Fight on procedurally generated maps (like roguelikes)
- Make tactical decisions with action points
- Manage permadeath (soldiers die permanently)
- Complete objectives under fire

**Comparisons**:
- **Like X-COM**: Turn-based tactical combat with action points
- **Like Into the Breach**: Hex grid, see enemy actions
- **Like roguelikes**: Procedural maps, permadeath matters
- **Like Fire Emblem**: Unit positioning, terrain tactics
- **Unlike XCOM 2**: No fixed map layouts

---

## Q: How does the hex grid work?

**A**: **Vertical axial coordinate system** (flat-top hexagons):

### Hex Basics
- Each hex = 2-3 meters of game space
- 6 adjacent neighbors per hex
- Line-of-sight uses hex edges
- Elevation affects gameplay

**Direction System**:
```
     NW(4)    NE(5)
        \    /
    W(3)--HEX--E(0)
        /    \
     SW(2)    SE(1)
```

**Comparison**:
- **Like Civilization V**: Hex-based movement
- **Like Battle for Wesnoth**: Hex grid tactics
- **Unlike X-COM**: Not square tiles
- **Unlike XCOM 2**: Not square cover system

### Why Hexagons?

**Advantages over squares**:
- Equal distance to all 6 neighbors (fairer movement)
- More natural terrain flow
- Better for tactical flanking
- Fewer "diagonal exploits"

---

## Q: How do action points work?

**A**: **Like X-COM's Time Units**:

### Action Point System

Each unit has Action Points (AP) per turn:
- **Movement**: 1 AP per hex moved
- **Basic actions**: 1-2 AP (open door, reload)
- **Shooting**: 2-4 AP (depends on weapon)
- **Special abilities**: 3-6 AP (varies)
- **Reaction fire**: Reserved AP (like X-COM)

### Example Turn
```
Soldier has 12 AP:
- Move 4 hexes (4 AP) → 8 AP remaining
- Shoot rifle (3 AP) → 5 AP remaining
- Reload weapon (2 AP) → 3 AP remaining
- Reserve for reaction (3 AP) → 0 AP remaining
```

**Comparison**:
- **Like X-COM**: Time Unit system
- **Like Jagged Alliance**: AP economy
- **Unlike XCOM 2**: Not "move + action" binary
- **Like Fallout 1/2**: AP determines possible actions

---

## Q: Is there permadeath? What happens when soldiers die?

**A**: **Yes, full permadeath like X-COM**:

### Death Consequences
- **Soldier dies**: Lost permanently (like X-COM)
- **Equipment lost**: Can't recover gear from corpse mid-mission
- **Experience lost**: Trained veterans gone forever
- **Morale impact**: Squad morale decreases
- **Replacement cost**: Recruit and train new soldier

**Comparison**:
- **Like X-COM**: Permadeath is core mechanic
- **Like Fire Emblem (classic)**: Dead = gone forever
- **Unlike XCOM 2**: No "revive" option
- **Like Darkest Dungeon**: Death is meaningful, prepare for it

### Softening Permadeath

**Medical System**:
- Wounded soldiers can be stabilized (prevents death)
- Medics can revive unconscious units (before bleeding out)
- Evacuation zones allow rescuing wounded
- **Once dead**: No resurrection

**Risk Management**:
- Don't over-commit veterans to risky missions
- Train backup soldiers (like X-COM strategy)
- Rotate squad members to spread experience
- Accept losses as part of gameplay

---

## Q: How does combat resolution work?

**A**: **Dice rolls with modifiers** (like tabletop RPGs):

### Attack Formula
```
Hit Chance = Base Accuracy - Distance Penalty - Cover Bonus + Aim Bonus
Clamped to 5%-95% (no guaranteed hits)

Damage = Weapon Damage - Armor Reduction
Crit Chance = Separate roll (10% base, modified by perks)
```

**Factors Affecting Hit Chance**:
- **Weapon accuracy**: Each weapon has base stat
- **Shooter skill**: Unit's aim stat (increases with experience)
- **Distance**: Longer range = lower accuracy
- **Cover**: Target in cover harder to hit
- **Elevation**: Height advantage improves accuracy
- **Flanking**: Side/rear shots bypass cover

**Comparison**:
- **Like X-COM**: RNG-based hit rolls
- **Like XCOM 2**: Cover provides defense bonus
- **Unlike Into the Breach**: Not deterministic
- **Like Baldur's Gate**: D&D-style attack rolls

---

## Q: How does cover work?

**A**: **Like XCOM 2 half/full cover system**:

### Cover Types

| Cover Type | Defense Bonus | Visual Indicator | Examples |
|------------|--------------|------------------|----------|
| **None** | 0% | Open ground | Empty hexes |
| **Low** | +20 defense | Half-height | Walls, boxes, sandbags |
| **High** | +40 defense | Full-height | Buildings, tanks, trees |
| **Full** | Immune | Cannot be targeted | Inside building |

### Cover Mechanics

**Like XCOM 2**:
- Cover must be between shooter and target
- Flanking bypasses cover bonus
- Destructible cover breaks under fire
- High ground improves accuracy

**Unlike XCOM 2**:
- Hex-based, not square edges
- Cover faces all 6 directions
- Elevation adds separate bonus
- No "dash to cover" mechanic (pure AP movement)

**Tactical Implications**:
- Always end turn in cover (survival 101)
- Flank enemies to remove their cover
- Destroy cover to expose enemies
- Elevation gives both cover AND aim bonus

---

## Q: How is map generation different from X-COM?

**A**: **Fully procedural like roguelikes**:

### Map Generation

**Like X-COM**:
- Mission-specific maps (UFO crash, alien base, etc.)
- Variety of terrain types (urban, rural, alien)

**Unlike X-COM**:
- Every map is procedurally generated (not scripted)
- Maps use modular "blocks" (like Spelunky chunks)

### Procedural System Details

**Block-Based Generation**:
- Maps assembled from 8×8 hex "chunks" (like Spelunky rooms)
- Each chunk has connection points (doors, corridors)
- Chunks categorized by type: combat, corridor, objective, spawn
- Mission type determines chunk selection probability

**Mission-Specific Templates**:

| Mission Type | Map Size | Chunk Distribution | Special Features |
|--------------|----------|-------------------|------------------|
| **UFO Crash** | 40×30 hexes | 60% forest, 30% crash site, 10% clearings | Damaged UFO as objective |
| **Alien Base** | 50×40 hexes | 70% corridors, 20% rooms, 10% command | Multi-level structure |
| **Terror Mission** | 45×35 hexes | 80% urban, 15% streets, 5% parks | Civilian units spawn |
| **Supply Raid** | 35×25 hexes | 50% warehouse, 30% storage, 20% exterior | Resource crates as objectives |
| **Retaliation** | 30×30 hexes | 100% your base layout | Uses your actual base grid |

**Procedural Elements**:
- **Cover placement**: Algorithm ensures 40-60% tiles have cover
- **Elevation variation**: 20-30% tiles have height differences (±1-2 levels)
- **Destructible elements**: 30-40% cover can be destroyed
- **Line-of-sight blockers**: Ensures no spawn-camping (minimum 8 hex distance)
- **Extraction zones**: Always generated at map edge, opposite from spawn

**Why Procedural Matters**:
- **No memorization**: Can't learn optimal paths like X-COM
- **Replayability**: Same mission type feels different each time
- **Anti-cheese**: Can't exploit known enemy positions
- **Roguelike tension**: Unknown map = higher stakes
- **Tactical adaptation**: Must react to terrain, not pre-plan

**Comparison**:
- **Like Spelunky**: Room-based procedural generation
- **Like Into the Breach**: Predictable enemy spawns, random terrain
- **Like XCOM 2**: Mission variety, but maps aren't scripted
- **Unlike Darkest Dungeon**: Not corridor-only, full 2D maps
- Never play the same map twice

**Like Roguelikes**:
- Procedural assembly of pre-built chunks
- Guaranteed playability (no impossible layouts)
- Strategic variety (can't memorize maps)

### Map Block System

**Structure**:
1. **Battle Tiles**: Individual hexes (terrain, cover, objects)
2. **Map Blocks**: 10×10 hex clusters (rooms, corridors)
3. **Map Segments**: Collections of blocks (buildings, areas)
4. **Full Map**: 50×50 to 80×80 hexes (assembled segments)

**Comparison**:
- **Like Spelunky**: Chunked procedural generation
- **Like XCOM 2**: Modular map pieces
- **Unlike roguelikes**: Not completely random (follows rules)
- **Like Slay the Spire**: Curated randomness

---

## Q: What's the squad size? Can I bring more soldiers?

**A**: **Variable squad size 4-12 units, mission-dependent**:

### Squad Size Mechanics

**Mission Type Limits**:

| Mission Type | Min Squad | Max Squad | Recommended | Why |
|--------------|----------|----------|-------------|-----|
| **Scout Mission** | 2 | 6 | 4 | Small map, stealth focus |
| **Standard Combat** | 4 | 10 | 6-8 | Balanced engagement |
| **Terror Mission** | 6 | 12 | 10 | Many civilians to protect |
| **Base Defense** | All | All | All available | Defending your home |
| **UFO Assault** | 6 | 12 | 8-10 | Large map, heavy resistance |

**Squad Size Trade-offs**:
- **Smaller squads** (4-6): Faster turns, easier to manage, stealth-friendly, higher risk
- **Larger squads** (10-12): More firepower, absorb casualties, slower turns, chaos management

### Role-Based Composition

**Essential Roles** (minimum viable squad):
```
1. Leader (Officer) - Morale support, +1 morale aura
2. Medic - Heals 25 HP per use (50 HP with Medic class)
3. Heavy Weapons - Suppression, anti-armor
4. Scout/Sniper - Long-range, reconnaissance
```

**Example 6-Unit Squad** (balanced):
```
1. Officer (Leader) - Rifle + Officer Armor
   → Role: Command, morale stability, tactical decisions
   → Why: +1 morale per turn to nearby allies (8 hex radius)

2. Medic (Support) - Pistol + Medikit + Medic Armor
   → Role: Healing (25 HP → 37 HP with class bonus)
   → Why: Essential for mission survival, stabilizes wounded

3. Heavy (Assault) - Heavy Cannon + Heavy Assault Armor
   → Role: Suppression fire, destroy cover, anti-armor
   → Why: High damage output, controls battlefield

4. Sniper (Marksman) - Sniper Rifle + Ghillie Suit
   → Role: Long-range elimination (25 hex range)
   → Why: Safe damage from distance, overwatch specialist

5. Scout (Recon) - Rifle + Light Scout Armor
   → Role: Mobility (+1 hex/turn), flanking, spotting
   → Why: Reveals enemy positions, fast repositioning

6. Grenadier (Demolitions) - Rifle + 3 Grenades
   → Role: Area denial, cover destruction, grouped enemies
   → Why: Grenades bypass cover (3 hex radius, 30 damage)
```

**Example 10-Unit Squad** (aggressive assault):
```
Core 6 above +
7. Assault #2 - Shotgun + Combat Armor (close quarters)
8. Rifleman - Rifle + Combat Armor (flexible DPS)
9. Specialist - Psionic Amplifier + Psi abilities (crowd control)
10. Backup Medic - Pistol + Medikit (redundancy)
```

**Squad Synergies**:
- **Leader + Heavy**: Officer morale prevents Heavy from panicking when taking fire
- **Scout + Sniper**: Scout reveals enemies, Sniper eliminates from safety
- **Medic + Assault**: Medic keeps frontline alive during aggressive pushes
- **Grenadier + Anyone**: Destroy cover, allies shoot exposed enemies next turn

**Comparison**:
- **Like RPG parties**: Tank, healer, DPS, support roles
- **Like XCOM 2**: Specialist classes with synergies
- **Like Battle for Wesnoth**: Combined arms tactics
- **Unlike Fire Emblem**: No permanent unit grid positioning

---

## Q: How does unit progression work in combat?

**A**: **Battle for Wesnoth-style rank progression with branching specialization paths**:

### Rank System Overview

**7 Rank Levels** (0-6):

| Rank | XP Required | Class Example | Capabilities |
|------|-------------|---------------|-------------|
| **0** | 0 XP | Conscript | Basic stats, limited equipment |
| **1** | 100 XP | Agent | Role selection, trained operative |
| **2** | 300 XP | Specialist | Role proficiency, improved stats |
| **3** | 600 XP | Expert | Specialization begins, unique abilities |
| **4** | 1,000 XP | Master | Advanced specialization, elite gear |
| **5** | 1,500 XP | Elite | Peak specialization, rare abilities |
| **6** | 2,100 XP | Hero | Unique, one per squad maximum |

### XP Gain Mechanics

**Combat XP Sources**:

| Action | XP Gained | Notes |
|--------|----------|-------|
| **Kill enemy** | 10-50 XP | Varies by enemy rank |
| **Assist kill** | 5-25 XP | Damaged enemy killed by ally |
| **Survive mission** | 25 XP | Participation bonus |
| **Complete objective** | 50 XP | Shared among squad |
| **First blood** | +10 XP | Bonus for first kill |
| **Flawless mission** | +25 XP | No damage taken |

**XP Example** (standard mission):
```
Mission: UFO Crash Site
Squad: 6 soldiers

Soldier A (Rifleman):
- Killed 3 Sectoids (30 XP)
- Assisted 2 kills (10 XP)
- Survived mission (25 XP)
- Total: 65 XP (65% toward Rank 1 → 2)

Soldier B (Officer):
- Killed 1 Sectoid (10 XP)
- Completed objective (50 XP)
- Survived mission (25 XP)
- Total: 85 XP (reaches Rank 2 if at Rank 1)

Soldier C (Heavy):
- Killed 5 Sectoids (50 XP)
- First blood bonus (10 XP)
- Survived mission (25 XP)
- Flawless (no damage) (25 XP)
- Total: 110 XP (reaches Rank 2 + 10 XP toward Rank 3)
```

### Branching Specialization Paths

**Rank 1 → Rank 2** (Role Selection):
```
Agent → Choose Role:
├─ Soldier → Rifleman / Grenadier / Gunner
├─ Support → Medic / Engineer / Specialist
├─ Leader → Officer / Tactician / Commander
├─ Scout → Recon / Sniper / Infiltrator
├─ Specialist → Psion / Hacker / Demolitionist
└─ Pilot → Fighter Pilot / Bomber Pilot / Transport Pilot
```

**Rank 2 → Rank 3** (Specialization):
```
Example: Soldier path
Rifleman → Marksman / Assault Specialist
Grenadier → Demolitionist / Bombardier
Gunner → Suppressor / Heavy Gunner
```

**Rank 3 → Rank 4** (Advanced Specialization):
```
Example: Marksman path
Marksman → Sniper Elite / Sharpshooter
(+20% accuracy, +5 hex range, "Aimed Shot" ability)
```

### Promotion Example: Recruit to Hero

**Starting Point: Rank 0 Conscript (0 XP)**
```
Mission 1: First deployment
- Kills: 1 (10 XP)
- Survived: (25 XP)
- Total: 35 XP / 100 XP (35% to Rank 1)

Mission 2: Second deployment
- Kills: 2 (20 XP)
- Assisted: 1 (5 XP)
- Survived: (25 XP)
- Total: 50 XP → Cumulative: 85 XP / 100 XP (85%)

Mission 3: Third deployment
- Kills: 1 (10 XP)
- Objective: (50 XP)
- Survived: (25 XP)
- Total: 85 XP → Cumulative: 170 XP
→ RANK UP to Rank 1 (Agent) at 100 XP
→ 70 XP toward Rank 2 (70/300 = 23%)
```

**Rank 1 → Rank 2 (Agent → Specialist)**:
```
Player chooses: "Soldier" role → "Rifleman" specialization

Stats improvement:
- Accuracy: 6 → 8 (+2)
- Health: 25 → 30 (+5)
- Bravery: 6 → 7 (+1)

Abilities unlocked:
- "Snap Shot" (1 AP, -20% accuracy)
- "Aimed Shot" (3 AP, +20% accuracy)
```

**Rank 5 → Rank 6 (Elite → Hero)**:
```
Requirements:
- 2,100 XP total
- 3 Rank 5 units in your roster
- Only ONE Hero allowed per squad
- Special mission completion required

Hero Benefits:
- +50% stats across the board
- Unique ability (e.g., "Last Stand" - cannot die for 1 turn)
- Faction-wide bonus (e.g., +5% morale to all units)
- Custom appearance/name
```

### Trait System Integration

**Traits affect XP gain**:
- **Smart trait**: +20% XP gain (100 XP mission → 120 XP)
- **Stupid trait**: -20% XP gain (100 XP mission → 80 XP)
- **Veteran trait**: +10% XP gain (starts at Rank 1)

**Example**:
```
Two soldiers on same mission:
- Normal soldier: 100 XP gained
- Smart soldier: 120 XP gained (+20%)
- Stupid soldier: 80 XP gained (-20%)

Over 10 missions:
- Normal: 1,000 XP (Rank 4)
- Smart: 1,200 XP (Rank 4 + progress to Rank 5)
- Stupid: 800 XP (Rank 3)
```

### Comparison to Other Games

| Game | Progression Style | AlienFall Equivalent |
|------|------------------|---------------------|
| **Battle for Wesnoth** | Branching promotions | Exact match: Rank system |
| **XCOM 2** | Linear soldier classes | Similar: Class selection at Rank 1 |
| **Fire Emblem** | Class changes | Similar: Specialization branches |
| **X-COM (original)** | Stat increases only | Different: AlienFall has class paths |
| **Darkest Dungeon** | Fixed classes | Different: AlienFall allows progression |

**Key Difference**: AlienFall combines stat growth (X-COM) with class specialization (XCOM 2) and branching paths (Battle for Wesnoth)

**For complete unit progression details, see: design/mechanics/Units.md and api/UNITS.md**

---

## Q: How does morale work?

**A**: **Dynamic morale system affects combat effectiveness, like Total War**:

### Morale Mechanics (In-Battle)

**Morale Range**: 0 to Bravery stat (6-12 typical)
- **Starting morale** = Bravery stat
- **Resets after mission** = Back to Bravery value
- **Temporary system**: Only affects current battle

**Morale Thresholds & Penalties**:

| Morale Level | Status | AP Penalty | Accuracy Penalty | Behavior |
|-------------|--------|-----------|------------------|----------|
| **6+ (High)** | Confident | None | None | Normal combat effectiveness |
| **4-5** | Steady | None | -5% | Slight stress, manageable |
| **3** | Stressed | None | -10% | Noticeable performance drop |
| **2** | Shaken | -1 AP | -15% | Significant combat penalty |
| **1** | Panicking | -2 AP | -25% | Barely functional |
| **0** | PANIC | All AP lost | -50% | Cannot act this turn |

**Morale Loss Events** (see design/mechanics/MoraleBraverySanity.md):

| Event | Morale Loss | Example |
|-------|-------------|---------|
| **Ally killed (visible)** | -1 | Squadmate dies within 5 hexes |
| **Taking damage** | -1 | Each time unit is hit |
| **Critical hit received** | -2 | Lucky enemy shot |
| **Flanked by enemies** | -1 per turn | Surrounded, no cover |
| **Outnumbered 3:1** | -1 per turn | Squad overwhelmed |
| **New alien type** | -1 | First encounter with Chryssalid |
| **Commander killed** | -2 | Officer unit dies |
| **Night mission start** | -1 | Mission begins in darkness |

### Morale Recovery Actions

**Rest Action** (2 AP → +1 morale):
```
Example: Soldier at 2 morale, has 4 AP remaining
- Spend 2 AP: Rest action
- Morale increases to 3
- Remaining 2 AP can be used for move/shoot
```

**Leader Rally** (4 AP → +2 morale to target):
```
Requires: Officer class unit
Range: 8 hexes
Example: Officer rallies panicked soldier
- Officer spends 4 AP
- Target gains +2 morale (0 → 2, exits PANIC)
- Target can act next turn
```

**Leader Aura** (passive +1 morale per turn):
```
Requires: Officer class unit
Range: 8 hexes
Effect: All allies within range gain +1 morale per turn
Example: Officer at center of formation
- 4 soldiers within 8 hexes
- Each gains +1 morale per turn passively
- No AP cost, always active
```

### Preventing Panic - Strategic Tips

**1. Officer Placement**:
```
Formation:
  Scout (6 hexes ahead)
     |
  Officer (center)
  / | \ 
Heavy Medic Sniper (within 8 hex radius)

Why: Leader aura covers entire squad
```

**2. Minimize Morale Loss**:
- **Kill enemies quickly**: Dead enemies can't inflict morale loss
- **Use cover**: Reduces chance of taking damage = less morale loss
- **Overwatch**: Reaction fire prevents flanking = less morale loss
- **Spread formation**: Ally deaths only affect units within 5 hexes

**3. Rest Actions During Lulls**:
```
Turn sequence:
1. Kill immediate threats (spend 3-4 AP)
2. Use remaining 2 AP for Rest action
3. Morale stays at healthy level
4. Prevents morale spiral
```

**4. Protect the Officer**:
```
Priority: Officer survival > Heavy survival > Sniper survival
Reason: Officer death = -2 morale to everyone + loss of aura
Result: Entire squad becomes vulnerable to panic
```

### Panic Recovery Example

**Scenario**: Heavy Weapons unit panics during alien ambush
```
Turn 1 (Panic occurs):
- Heavy takes critical hit: -2 morale (4 → 2)
- Ally dies nearby: -1 morale (2 → 1)
- Flanked by aliens: -1 morale (1 → 0) → PANIC
- Heavy loses all AP, cannot act

Turn 2 (Recovery):
- Officer moves within 8 hexes (3 AP)
- Officer uses Rally action on Heavy (4 AP)
- Heavy gains +2 morale (0 → 2)
- Officer aura passive: Heavy gains +1 morale (2 → 3)
- Heavy still shaken but can act next turn

Turn 3 (Stabilization):
- Heavy uses Rest action (2 AP → +1 morale: 3 → 4)
- Officer aura continues: Heavy gains +1 morale (4 → 5)
- Heavy back to "Steady" status, full effectiveness
```

**Comparison**:
- **Like Total War**: Morale system affects unit performance
- **Like Darkest Dungeon**: Stress management is critical
- **Like XCOM**: Panic can happen but is recoverable
- **Unlike Fire Emblem**: No morale system, units always fight optimally

**For long-term psychological effects, see Sanity system in design/mechanics/MoraleBraverySanity.md**

---

## Q: Can I destroy terrain?

**A**: **Yes, destructible environment**:

### Destructible Cover

**Cover Destruction**:
- Explosives destroy cover
- Sustained fire damages cover (HP-based)
- Aliens can destroy cover too
- Reveals enemies hiding behind

**Strategic Uses**:
- Remove enemy cover before assault
- Create new paths through buildings
- Deny flanking positions
- Area denial with fire/explosions

**Comparison**:
- **Like XCOM 2**: Destructible cover system
- **Unlike X-COM (original)**: More dynamic destruction
- **Like Company of Heroes**: Environmental destruction
- **Unlike Civilization**: Permanent terrain changes during mission

---

## Q: What are the mission types?

**A**: **Varied objectives like X-COM**:

### Mission Categories

| Mission Type | Objective | X-COM Equivalent | Difficulty |
|--------------|-----------|------------------|------------|
| **UFO Crash** | Recover salvage, eliminate aliens | Crash Site | Medium |
| **Alien Base** | Destroy alien installation | Alien Base Assault | Hard |
| **Terror Mission** | Save civilians from attack | Terror Mission | Hard |
| **Extraction** | Rescue VIP, extract | Council Mission | Medium |
| **Escort** | Protect VIP during travel | Supply Barge (similar) | Medium |
| **Sabotage** | Destroy alien equipment | N/A (new) | Hard |
| **Defense** | Protect base from assault | Base Defense | Very Hard |

**Mission Outcomes**:
- **Success**: Full rewards, good relations, salvage
- **Partial**: Some objectives met, reduced rewards
- **Failure**: No rewards, bad relations, lost units
- **Retreat**: Abort mission, save soldiers, no rewards

---

## Q: Can I retreat from missions?

**A**: **Yes, but with consequences**:

### Retreat Mechanics

**How to Retreat**:
- Move units to extraction zone
- Call evac craft (takes 2-3 turns)
- Board craft with surviving units
- Leave mission area

**Consequences**:
- Mission marked as failure
- No salvage recovered
- Country relations decrease
- Dead/unconscious units lost
- Can recover wounded if stabilized

**Comparison**:
- **Like XCOM 2**: Evac zones available
- **Unlike X-COM (original)**: Not forced to fight to death
- **Like Fire Emblem**: Can abandon chapter
- **Unlike Into the Breach**: No perfect victory requirement

**When to Retreat**:
- Squad is overwhelmed (outnumbered 3:1)
- Too many casualties (50%+ dead/wounded)
- Objective impossible (key soldier dead)
- Save remaining veterans (better to retreat than lose all)

---

## Q: How does line-of-sight work?

**A**: **Hex-based LOS with elevation**:

### LOS Rules

**Basic LOS**:
- Draw line from shooter hex to target hex
- Obstacles block LOS (walls, high cover)
- Units block LOS to targets behind them
- Elevation matters (high ground sees over obstacles)

**Elevation Rules**:
- +1 elevation: See over low cover
- +2 elevation: See over high cover
- Shooting down: +5% accuracy bonus
- Shooting up: -5% accuracy penalty

**Comparison**:
- **Like X-COM**: Tile-based LOS
- **Like XCOM 2**: Elevation affects vision
- **Unlike Into the Breach**: Not perfect information (fog of war)
- **Like Wesnoth**: Hex-based vision rules

---

## Q: What's the combat pace like?

**A**: **Deliberate and tactical (not twitchy)**:

### Turn Structure

**Player Phase**:
- Activate each soldier individually
- Plan movement and actions
- Execute in any order
- Can undo actions (before confirming)

**Enemy Phase**:
- Aliens activate after all soldiers moved
- You see their actions resolve
- Reaction fire can interrupt (if reserved AP)

**Mission Duration**:
- Small mission: 10-20 turns (15-30 minutes)
- Medium mission: 20-40 turns (30-60 minutes)
- Large mission: 40-60+ turns (60-90 minutes)

**Comparison**:
- **Like X-COM**: Think before acting
- **Slower than XCOM 2**: More units, larger maps
- **Faster than Civilization combat**: Pure tactics
- **Like Chess**: Every move matters

---

## Q: Is there a difficulty system?

**A**: **Adaptive AI, not fixed difficulty**:

### Difficulty Factors

**AI Behavior**:
- Learns from your tactics (avoids repeated strategies)
- Scales with campaign progress (better units, more enemies)
- Mission difficulty varies (some easier, some brutal)

**Player Control**:
- Choose mission difficulty (optional hard missions available)
- Self-imposed challenges (no medkits, no retreats, etc.)
- Modding difficulty parameters

**Comparison**:
- **Like X-COM**: Escalating threat level
- **Unlike XCOM 2**: No difficulty slider
- **Like roguelikes**: Emergent difficulty
- **Like Darkest Dungeon**: Risk is up to player

---

## Q: What happens to wounded soldiers?

**A**: **Recovery time like X-COM**:

### Wound System

**Injury Severity**:
- Light wounds: 7-14 days recovery
- Moderate wounds: 15-30 days recovery
- Severe wounds: 31-60 days recovery
- Critical wounds: 61-90 days recovery

**During Recovery**:
- Soldier unavailable for missions
- Still paid salary
- Can heal faster with medical facilities
- Might gain negative traits (injury complications)

**Comparison**:
- **Like X-COM**: Wounded soldiers need time
- **Like XCOM 2**: Recovery system
- **Unlike Fire Emblem**: Not permanent injury
- **Like Darkest Dungeon**: Need backups for injured heroes

---

## Q: How does morale work?

**A**: **Three-part psychological system: Bravery → Morale → Sanity**:

### The System

**Bravery** (Core Stat):
- Range: 6-12 (like other stats)
- Represents inherent courage
- Determines starting morale in battle
- Examples: Rookie (6), Veteran (10), Hero (12)

**Morale** (In-Battle):
- Starts at Bravery value each mission
- Degrades from combat stress
- Affects AP and accuracy during battle
- Resets to Bravery after mission

**Sanity** (Long-Term):
- Range: 6-12, separate from morale
- Drops after missions based on trauma
- Recovers slowly in base (weeks)
- Affects future deployments

**Comparison**:
- **Like Total War**: Morale affects combat performance
- **Like Darkest Dungeon**: Stress system with long-term effects
- **Unlike XCOM 2**: More granular panic system
- **Like Warhammer**: Leadership and morale buffs

---

## Q: What makes morale drop during combat?

**A**: **Stress events during battle**:

### Morale Loss Events

| Event | Morale Loss | When It Happens |
|-------|-------------|----------------|
| **Ally killed** | -1 | Witnessed death within 5 hexes |
| **Taking damage** | -1 | Each time unit is hit |
| **Critical hit** | -2 | Receive critical damage |
| **Flanked** | -1 | Enemies on multiple sides |
| **Outnumbered** | -1 | 3:1 enemy advantage |
| **New alien** | -1 | First encounter with alien type |
| **Commander killed** | -2 | Squad leader dies |

**Example Combat**:
```
Turn 1: Start with 10 morale (Bravery 10)
Turn 3: Ally killed → 9 morale
Turn 5: Take damage → 8 morale
Turn 7: Flanked by 2 enemies → 7 morale
Turn 9: Another ally killed → 6 morale
Still functional but stressed
```

**Comparison**:
- **Like Total War**: Units break under casualties
- **Like XCOM 2**: Panic from deaths and flanking
- **More granular than X-COM**: Not binary panic/normal
- **Like Darkest Dungeon**: Cumulative stress events

---

## Q: What happens when morale gets low?

**A**: **Gradual performance degradation, then panic**:

### Morale Thresholds

| Morale | Status | AP Penalty | Accuracy | Effect |
|--------|--------|------------|----------|--------|
| **6-12** | Confident | 0 | 0% | Normal performance |
| **4-5** | Steady | 0 | -5% | Minor penalty |
| **3** | Stressed | 0 | -10% | Noticeable issues |
| **2** | Shaken | -1 AP | -15% | Can't do as much |
| **1** | Panicking | -2 AP | -25% | Severely impaired |
| **0** | **PANIC** | All AP lost | -50% | Cannot act |

**Panic Mode (0 Morale)**:
- Unit loses ALL action points
- Cannot move, shoot, or perform any action
- May flee toward map edge (10% chance)
- May drop weapon (5% chance)
- Lasts until morale restored

**Comparison**:
- **Like Total War**: Units route when morale breaks
- **Like XCOM 2**: Panic disables units
- **More predictable**: Gradual degradation, not sudden
- **Like Darkest Dungeon**: Afflictions from stress

---

## Q: How do I restore morale during combat?

**A**: **Rest actions and leader support**:

### Morale Recovery Options

**Rest Action**:
- **Cost**: 2 AP
- **Effect**: +1 morale
- **Frequency**: Once per turn
- **Use**: Unit spends time composing themselves

**Leader Rally**:
- **Cost**: 4 AP (leader action)
- **Effect**: +2 morale to target within 5 hexes
- **Requirement**: Unit has "Leadership" trait

**Leader Aura** (Passive):
- +1 morale per turn to units within 8 hexes
- Stacks with Rest action
- Always active if leader alive

**Comparison**:
- **Like Total War**: Generals rally nearby troops
- **Like Darkest Dungeon**: Stress healing abilities
- **Unlike XCOM 2**: Can actively manage morale
- **Like Fire Emblem**: Support bonuses

---

## Q: What's the difference between morale and sanity?

**A**: **Morale = battle, Sanity = campaign**:

### Key Differences

| Aspect | Morale | Sanity |
|--------|--------|--------|
| **Timeframe** | During battle only | Between battles |
| **Starting value** | Equals Bravery | 6-12 independent stat |
| **Degradation** | Combat stress | Mission trauma |
| **Recovery** | Rest actions (immediate) | Weekly in base (slow) |
| **Reset** | Full reset after mission | Persists across missions |
| **Impact** | AP and accuracy | Future deployment readiness |

### How They Interact

**During Mission**:
- Morale degrades from combat
- Morale affects performance
- Morale resets at mission end

**After Mission**:
- Sanity drops based on mission horror
- Low sanity reduces starting morale next mission
- Sanity takes weeks to recover

**Example Flow**:
```
Mission 1: Start 10 morale → drops to 3 → mission ends, reset to 10
Post-mission: Sanity drops by 2 (horror mission) → 8 sanity
Mission 2: Start 10 morale, but -5% accuracy from sanity
```

**Comparison**:
- **Like Darkest Dungeon**: Short-term stress + long-term afflictions
- **Unlike XCOM 2**: No long-term psychological tracking
- **Like Battle Brothers**: Injuries persist, affect future battles
- **Like Total War**: Morale in battle + army veterancy between

---

## Q: How does sanity drop after missions?

**A**: **Based on mission difficulty and trauma**:

### Sanity Loss Table

| Mission Type | Base Loss | Additional Factors |
|--------------|-----------|-------------------|
| **Standard** | 0 | Routine operations |
| **Moderate** | -1 | High stress |
| **Hard** | -2 | Extreme trauma |
| **Horror** | -3 | Psychological terror |

**Additional Losses**:
- Night mission: -1
- Ally killed: -1 per death
- Civilian casualties: -1 per 5 deaths
- Mission failure: -2
- Base assault: -3

**Example**:
```
Mission: Hard alien base assault at night
Base loss: -2 (hard)
Night: -1
3 allies killed: -3
Total: -6 sanity loss

Veteran starts at 10 sanity → drops to 4 sanity
Result: -15% accuracy next mission, -2 morale start
```

**Comparison**:
- **Like Darkest Dungeon**: Stress afflictions persist
- **Like XCOM 2**: No persistent trauma system
- **Like Battle Brothers**: Permanent injuries from combat
- **Like Total War**: Unit experience but not trauma

---

## Q: How do I recover sanity?

**A**: **Time in base, Temple facility, medical treatment**:

### Sanity Recovery Options

**Passive Recovery**:
- Base recovery: +1 sanity per week
- Temple facility: +1 additional per week
- Total with Temple: +2 sanity per week

**Active Recovery**:
- Medical treatment: +3 sanity immediately (10,000 credits)
- Leave/vacation: +5 sanity over 2 weeks (5,000 credits)

**Recovery Time Example**:
```
Unit at 4 sanity (Breaking status)
With Temple: +2 per week
Needs to reach 7+ for comfortable deployment
Recovery time: 2 weeks minimum

Without Temple: +1 per week
Recovery time: 3-4 weeks
```

**Strategic Implications**:
- **Build Temple early**: Doubles sanity recovery rate
- **Rotate soldiers**: Don't deploy same unit every mission
- **Large roster**: Need 2-3x squad size for rotation
- **Mission selection**: Avoid horror missions when sanity low

**Comparison**:
- **Like Darkest Dungeon**: Sanitarium and tavern recovery
- **Like XCOM 2**: Wounded soldiers need recovery time
- **Like Battle Brothers**: Time heals injuries
- **Like Football Manager**: Squad rotation prevents burnout

---

## Q: What happens if sanity reaches 0?

**A**: **Unit is BROKEN - cannot deploy**:

### Broken State

**When Sanity = 0**:
- Unit marked as "Broken"
- Cannot be deployed on any mission
- Occupies roster slot but unavailable
- Requires mandatory treatment

**Treatment Options**:
- Temple/Psych Ward: +2 sanity per week (slow recovery)
- Medical treatment: +3 sanity immediate (10,000 credits)
- Discharge: Remove unit permanently (free up slot)

**Recovery Timeline**:
- Minimum 3 weeks to deploy again (sanity 3+)
- Full recovery: 6-12 weeks to maximum
- Expensive to rush recovery

**Comparison**:
- **Like Darkest Dungeon**: Afflictions remove hero from roster
- **Like Blood Bowl**: Injured players miss games
- **Unlike XCOM 2**: No permanent psychological damage
- **Like real military**: PTSD requires treatment

---

## Q: How does bravery increase?

**A**: **Experience, traits, and equipment**:

### Bravery Progression

**Base Increases**:
- +1 bravery per 3 ranks gained (maximum +4)
- Veterans naturally become braver

**Trait Bonuses**:
- "Brave" trait: +2 bravery
- "Fearless" trait: +3 bravery (rare)
- "Timid" trait: -2 bravery (negative)

**Equipment Bonuses**:
- Officer gear: +1 bravery
- Ceremonial armor: +1 bravery
- Medal display: +1 per 3 medals

**Example Progression**:
```
Rank 0 Rookie: 6 bravery
Rank 3 Soldier: 7 bravery (+1 from ranks)
Rank 6 Veteran: 8 bravery (+2 total)
+ "Brave" trait: 10 bravery
+ Officer badge: 11 bravery
Final: 11 morale capacity in battle
```

**Comparison**:
- **Like Fire Emblem**: Stats grow with levels
- **Like XCOM 2**: Will stat increases with rank
- **Unlike X-COM original**: Not random stat increases
- **Like Battle for Wesnoth**: Promotion improves stats

---

## Q: Should I deploy low-sanity units?

**A**: **Risky but sometimes necessary**:

### Decision Matrix

| Sanity | Deploy? | Risk | Mitigation |
|--------|---------|------|------------|
| **10-12** | Yes | None | Normal ops |
| **7-9** | Yes | Low | Acceptable penalty |
| **5-6** | Maybe | Medium | Easy missions only |
| **3-4** | Avoid | High | Emergency only |
| **1-2** | No | Very High | Will break soon |
| **0** | Impossible | N/A | Cannot deploy |

**When to Deploy Low-Sanity Units**:
- Emergency (no other units available)
- Easy/routine mission (low expected stress)
- Veteran with critical skills
- Can afford to lose them

**When to Rest Units**:
- Sanity below 6
- Horror mission upcoming
- Multiple consecutive deployments
- Have backup units available

**Comparison**:
- **Like Darkest Dungeon**: Risk management with stressed heroes
- **Like sports management**: Play injured athletes or rest them
- **Unlike XCOM 2**: No such management needed
- **Like real military**: Combat fatigue is real concern

---

## Q: What's the optimal roster size for sanity management?

**A**: **2-3x squad size minimum**:

### Roster Planning

**Minimum**: 2x squad size
- 6-man squad → 12 soldiers minimum
- Allows basic rotation
- Limited flexibility

**Optimal**: 3x squad size
- 6-man squad → 18 soldiers optimal
- Full rotation capability
- Redundancy for losses

**Large**: 4x squad size
- 6-man squad → 24 soldiers
- Multiple specialized teams
- Maximum flexibility

**Cost-Benefit**:
- Larger roster = more salaries
- But prevents sanity spiral
- Insurance against casualties
- Enables mission specialization

**Comparison**:
- **Like Darkest Dungeon**: 20+ heroes for 4-man dungeons
- **Like XCOM 2**: Recommend 2x squad size minimum
- **Like sports teams**: Starters + bench + reserves
- **Like real military**: Rotation doctrine

---

## Q: How does morale/sanity compare to other games?

**A**: **Hybrid of several systems**:

### System Comparisons

**vs. Total War Morale**:
- ✅ Similar: Units break under stress
- ✅ Similar: Leaders boost nearby morale
- ❌ Different: Also has long-term sanity
- ❌ Different: More granular thresholds

**vs. Darkest Dungeon Stress**:
- ✅ Similar: Short-term stress (morale) + long-term afflictions (sanity)
- ✅ Similar: Recovery requires time/facilities
- ❌ Different: No quirks or random afflictions
- ❌ Different: More predictable degradation

**vs. XCOM 2 Will**:
- ✅ Similar: Panic from stress
- ✅ Similar: Can recover during mission
- ❌ Different: Will doesn't degrade long-term
- ❌ Different: No facility-based recovery

**vs. Battle Brothers Morale**:
- ✅ Similar: Combat morale affects performance
- ✅ Similar: Experience improves morale
- ❌ Different: Sanity tracks between battles
- ❌ Different: More complex recovery system

**Unique to AlienFall**:
- Three-layer system (Bravery → Morale → Sanity)
- Predictable degradation and recovery
- Strategic roster management required
- Temple facility integration

---

## Next Steps

- **Understand unit progression**: Read [Units FAQ](FAQ_UNITS.md)
- **Learn base facilities**: Read [Basescape FAQ](FAQ_BASESCAPE.md)
- **Master equipment**: Read [Items FAQ](FAQ_ITEMS.md)
- **See full mechanics**: Check [design/mechanics/MoraleBraverySanity.md](../mechanics/MoraleBraverySanity.md)

[← Back to FAQ Index](FAQ_INDEX.md)



