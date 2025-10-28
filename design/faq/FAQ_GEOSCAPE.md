# FAQ: Geoscape - Strategic Layer

[← Back to FAQ Index](FAQ_INDEX.md)

---

## Q: What is the Geoscape? Is it like Civilization's world map?

**A**: **Yes, very similar!**

The Geoscape is your strategic world view where you:
- Manage global operations
- Deploy craft to missions
- Build bases in territories
- Conduct diplomacy with countries
- Track alien activity

**Comparisons**:
- **Like Civilization**: Hexagonal world map with territories
- **Like X-COM**: UFO tracking and interception
- **Like Europa Universalis**: Diplomatic relations and territory control
- **Like Risk**: One base per province (territorial ownership)

---

## Q: How does the world map work?

**A**: **90×45 hexagonal grid** representing Earth:

### Map Structure
- **Hexes**: Basic tiles (~500km each) like Civilization
- **Provinces**: Groups of 6-12 hexes (like Civ cities)
- **Regions**: Collections of provinces (like Civ continents)
- **Countries**: Political entities owning provinces

### Map Comparison

| Game | World Representation |
|------|---------------------|
| **Civilization** | Square tiles, continents | 
| **AlienFall** | Hex tiles, provinces |
| **Europa Universalis** | Province-based map |
| **AlienFall** | Province-based with hex subdivisions |
| **XCOM 2** | Abstract world map nodes |
| **AlienFall** | Detailed hex geography |

---

## Q: How do bases work? Is it like X-COM's multiple bases?

**A**: **Similar but with strict territorial limits**:

### Key Rules
- **One base per province maximum** (like settling cities in Civilization)
- Bases are permanent (can't relocate)
- Province control determines operational range
- Strategic placement is critical

### Base Placement Strategy

**Like Civilization city placement**:
- Consider adjacency to resources
- Plan for radar coverage overlap
- Balance economic vs. defensive positions
- Choke points control regions

**Unlike X-COM**:
- Can't spam unlimited bases
- Province ownership is exclusive
- Base size affects diplomacy (large bases require good relations)

### Base Sizes

| Size | Cost | Build Time | Strategic Use | Civilization Comparison |
|------|------|------------|--------------|------------------------|
| **Small** (4×4) | 150K | 30 days | Scout bases, forward outposts | Settler |
| **Medium** (5×5) | 250K | 45 days | Standard operations | City |
| **Large** (6×6) | 400K | 60 days | Regional hubs | Capital |
| **Huge** (7×7) | 600K | 90 days | Strategic strongholds | Wonder city |

---

## Q: How does base expansion work?

**A**: **Like Civilization city growth but manual**:

- Bases start at chosen size (Small/Medium/Large/Huge)
- Can expand sequentially (Small→Medium→Large→Huge)
- Expansion costs credits and time
- Diplomatic requirements increase with size
- All existing facilities preserved during expansion

**Cost Gates**:
- Technology requirements (like Civ tech prerequisites)
- Country relations (Large/Huge need positive relations)
- Credits available (economic bottleneck)
- Sequential progression (can't skip sizes)

---

## Q: What's the deal with radar coverage?

**A**: **Like X-COM + Civilization fog of war**:

### Detection System
- Each base has a radar range (hex radius)
- UFOs/missions visible only within radar range
- Stealth UFOs require higher detection level
- Overlapping coverage improves detection

**Comparison**:
- **Like Civilization**: Fog of war reveals territory
- **Like X-COM**: Radar coverage for UFO detection
- **Unlike StarCraft**: Not real-time, updates per turn

---

## Q: How does diplomacy work? Is it like Europa Universalis?

**A**: **Simplified EU4 with X-COM funding mechanics**:

### Relationship Scale
- Range: -100 (hostile) to +100 (allied)
- Affects funding level (1-10 scale)
- Controls base building permissions
- Influences mission availability

### Relationship Thresholds

| Range | Status | Effects | EU4 Comparison |
|-------|--------|---------|----------------|
| **-100 to -50** | Hostile | No funding, base restrictions | Rival |
| **-49 to 0** | Unfriendly | Reduced funding, limited missions | Neutral |
| **+1 to +49** | Neutral | Standard funding | Friendly |
| **+50 to +74** | Friendly | Bonus funding, more missions | Allied |
| **+75 to +100** | Allied | Maximum funding, special missions | Alliance |

### How to Improve Relations

**Like Europa Universalis**:
- Complete missions in their territory (+5 per mission)
- Defend their provinces from aliens (+10)
- Trade with their suppliers (+2)
- Share research discoveries (+3)

**Like X-COM**:
- Monthly funding payments improve goodwill
- Protecting their territory maintains relations
- Ignoring their provinces damages relations

**Unlike EU4**:
- No royal marriages or trade agreements
- No casus belli for war
- Relations change monthly, not yearly

---

## Q: What's the alien threat escalation? Is it like XCOM 2's Avatar Project?

**A**: **Similar concept, different execution**:

### Escalation System
- Alien threat rises monthly
- Multiple factions escalate independently
- Peaks trigger UFO armada events (like Avatar Project milestones)
- **No game over** - you can lose battles and recover

### Comparison

| Feature | XCOM 2 Avatar Project | AlienFall Escalation |
|---------|----------------------|---------------------|
| **Timer** | Fixed countdown | Monthly accumulation |
| **Failure** | Game over | Setback, not game over |
| **Reduction** | Attack specific facilities | Win missions, destroy bases |
| **Multiple threats** | Single unified threat | Multiple faction threats |
| **Pressure** | Time-limited panic | Steady escalation |

**Why different?**:
- No forced "lose on timer" game-over
- Multiple alien factions compete (not unified)
- Escalation can be reversed through victories
- Sandbox nature means no artificial urgency

---

## Q: How does time advance on the Geoscape?

**A**: **Monthly cycles like Civilization**:

### Monthly Turn Structure
1. **Start of month**: Funding received, relations updated
2. **Action phase**: Deploy craft, start research, plan bases
3. **Event resolution**: Missions occur, battles resolve
4. **End of month**: Alien escalation, new missions spawn

**Turn Flow**:
- **Like Civilization**: Click "end turn" when ready
- **Unlike real-time strategy**: No time pressure
- **Like X-COM**: Events trigger based on timers
- **Unlike XCOM 2**: No forced turn limits

---

## Q: What are missions? How do they spawn?

**A**: **Procedurally generated like X-COM + event-driven**:

### Mission Types
- **UFO Crashes**: Shoot down UFOs, recover salvage (classic X-COM)
- **Alien Bases**: Attack established alien installations
- **Terror Missions**: Defend cities from alien attacks
- **Council Missions**: Special objectives from countries
- **Random Events**: Procedurally generated threats

### Mission Generation

**Like X-COM**:
- UFOs appear on radar, can be intercepted
- Crash sites must be investigated quickly
- Terror missions are time-sensitive

**Like Civilization events**:
- Random events based on current game state
- Choices affect outcomes
- Some missions are procedurally generated

**Unlike XCOM 2**:
- No fixed mission calendar
- Missions scale with alien threat level
- Multiple factions generate different mission types

---

## Q: What happens if I ignore missions?

**A**: **Consequences but not game over**:

### Ignored Mission Consequences
- **Country relations decrease** (-5 to -15)
- **Alien faction strengthens** (builds bases, recruits units)
- **Escalation increases faster** (+1 threat per ignored mission)
- **Funding may decrease** (if country becomes hostile)

**Comparison**:
- **Like X-COM**: Ignored terror missions damage relations
- **Unlike XCOM 2**: No instant game over from ignoring missions
- **Like Civilization**: Actions have long-term consequences
- **Unlike Phoenix Point**: No faction permanently lost

---

## Q: How do UFO interceptions work?

**A**: **Card-based combat, not real-time**:

When a craft encounters a UFO:
1. Enter Interception screen (separate from Geoscape)
2. Play weapons as cards (like Magic: The Gathering)
3. Manage energy and action points
4. Resolve combat turn-by-turn

**See [Interception FAQ](FAQ_INTERCEPTION.md) for details**

**Comparison**:
- **Unlike X-COM**: No real-time dodging minigame
- **Like MTG**: Card-based tactical decisions
- **Like Slay the Spire**: Deck building with resources
- **Unlike Phoenix Point**: Purely turn-based

---

## Q: Can I lose the game on the Geoscape?

**A**: **Technically no, but you can reach unwinnable states**:

### "Soft" Fail States
- All bases destroyed → Can't operate
- All countries hostile → No funding
- All craft destroyed → Can't deploy to missions
- Massive debt → Can't afford operations

**Like Civilization**: You can limp along in a losing position  
**Unlike X-COM**: No forced game over screen  
**Like Dwarf Fortress**: "Losing is fun" - learn and restart  
**Unlike XCOM 2**: No doom timer ending your run  

---

## Q: What's the optimal number of bases?

**A**: **Depends on strategy, like Civilization city count**:

| Strategy | Base Count | Reasoning |
|----------|-----------|-----------|
| **Tall** | 3-5 bases | Maximize individual base development |
| **Wide** | 8-12 bases | Control maximum territory |
| **Defensive** | 5-7 bases | Strategic chokepoints |
| **Economic** | 6-10 bases | Resource access points |

**Like Civilization**:
- More cities = more resources but higher maintenance
- Strategic positioning > raw numbers
- Quality over quantity viable

**Unlike X-COM**:
- One base per province limit prevents spam
- Each base serves specific purpose
- Can't relocate, so placement is permanent

---

## Q: How does fuel work for craft travel?

**A**: **Resource-based logistics, like actual military operations**:

### Fuel Mechanics
- Craft consume fuel traveling between provinces
- Fuel stored in base inventory (no refueling phase)
- Insufficient fuel = craft can't launch
- Strategic resource management required

**Comparison**:
- **Like Total War**: Army supply lines
- **Unlike X-COM**: Fuel is explicit resource, not abstract
- **Like Hearts of Iron**: Fuel limits operations
- **Unlike StarCraft**: Not just "gas" - specific logistics

---

## Q: What's the Geoscape endgame like?

**A**: **Open-ended, like Civilization's late game**:

### Endgame Scenarios
- **Military dominance**: Eliminate all alien factions
- **Economic victory**: Control all provinces
- **Diplomatic mastery**: Allied with all countries
- **Survival mode**: Withstand escalating threats
- **Custom goals**: Set your own objectives

**Comparison**:
- **Like Civilization**: Multiple victory paths
- **Unlike X-COM**: No "final mission" ending
- **Like Dwarf Fortress**: Play until you want to stop
- **Unlike XCOM 2**: No forced narrative conclusion

---

## Q: Can I automate Geoscape management?

**A**: **Partially, like Civilization governors**:

### Automation Options
- Research can auto-continue next project
- Manufacturing queues run automatically
- Craft can auto-patrol regions
- **Base construction**: Always manual
- **Diplomacy**: Always manual
- **Mission selection**: Always manual

**Why limited automation?**:
- Strategic decisions are the core gameplay
- Automation would trivialize the layer
- Player agency is paramount

---

## Next Steps

- **Learn base construction**: Read [Basescape FAQ](FAQ_BASESCAPE.md)
- **Master air combat**: Read [Interception FAQ](FAQ_INTERCEPTION.md)
- **Understand diplomacy**: Read [Politics FAQ](FAQ_POLITICS.md)
- **See full mechanics**: Check [design/mechanics/Geoscape.md](../mechanics/Geoscape.md)

[← Back to FAQ Index](FAQ_INDEX.md)

