# FAQ: AI Systems

> **Audience**: Experienced strategy gamers familiar with 4X games, Total War, XCOM  
> **Last Updated**: 2025-10-28  
> **Related Mechanics**: [AI.md](../mechanics/AI.md), [Battlescape.md](../mechanics/Battlescape.md), [Geoscape.md](../mechanics/Geoscape.md)

---

## Quick Navigation

- [Enemy AI Behavior](#enemy-ai-behavior)
- [Faction AI Strategies](#faction-ai-strategies)
- [Difficulty Scaling](#difficulty-scaling)
- [Autonomous Playtesting](#autonomous-playtesting)
- [Strategic Escalation](#strategic-escalation)
- [Game Comparisons](#game-comparisons)

---

## Enemy AI Behavior

### Q: How smart is the enemy AI?

**A**: **Context-aware** tactical AI (like **XCOM 2** but more adaptive).

**AI Capabilities**:
- ✅ **Cover usage**: AI prioritizes cover and flanking
- ✅ **Ability usage**: Uses grenades, special abilities tactically
- ✅ **Target prioritization**: Focuses weakened units, high-value targets
- ✅ **Retreat logic**: Falls back when outnumbered or low health
- ✅ **Overwatch discipline**: Uses overwatch to control zones
- ✅ **Squad coordination**: Multiple units coordinate attacks

**AI Complexity Levels**:
- **Easy**: 50% AI intelligence (basic tactics)
- **Normal**: 100% AI intelligence (standard behavior)
- **Hard**: 200% AI intelligence (advanced tactics)
- **Impossible**: 300% AI intelligence (expert play)

---

### Q: Does AI cheat?

**A**: **No stat cheating**, but gets **strategic advantages** on higher difficulties.

**AI Does NOT Get**:
- ❌ Bonus accuracy
- ❌ Extra damage
- ❌ Free units
- ❌ Perfect knowledge (fog of war applies)

**AI DOES Get** (Hard/Impossible):
- ✅ **Reinforcements**: Extra waves arrive during battle
- ✅ **Better positioning**: Starts in advantageous positions
- ✅ **Squad size**: Larger enemy squads (+25-50%)
- ✅ **Smarter tactics**: Better target prioritization

**Philosophy**: AI should be smart, not artificially boosted.

---

### Q: How does AI use cover?

**A**: **Prioritizes safety** (like **XCOM** AI).

**Cover AI Behavior**:
1. **Evaluate threats**: Identify player units in sight
2. **Calculate danger**: Determine which hexes are safest
3. **Prefer cover**: Choose full cover > half cover > no cover
4. **Consider flanking**: Balance safety vs. offensive position
5. **Move to cover**: Always end movement in cover if possible

**Cover Priority Formula**:
```
Safety Score = Cover Bonus - (Enemy Line of Fire × Threat)
Highest Safety Score = Best move
```

**Example**:
- Hex A: Full cover (+20 defense), 2 enemies can shoot = Score 20 - 2×10 = 0
- Hex B: Half cover (+10 defense), 1 enemy can shoot = Score 10 - 1×10 = 0
- Hex C: No cover (0 defense), 0 enemies can shoot = Score 0
- **AI chooses Hex C** (no line of fire = safest)

---

### Q: Does AI flank players?

**A**: **Yes** - AI actively seeks flanking positions (like **XCOM 2** AI).

**Flanking AI Logic**:
1. **Detect player cover**: Identify units in cover
2. **Calculate flank positions**: Find hexes that negate cover
3. **Risk assessment**: Balance flank benefit vs. exposure
4. **Coordinate**: Multiple units flank simultaneously if possible

**Flanking Priority**:
- **High-value targets**: Leaders, medics, wounded units
- **Isolated units**: Players separated from squad
- **Cover-reliant units**: Heavy armor units in cover

**Counter-Flanking**:
- AI protects its own flanks (positions units to watch sides)
- Retreats if player attempts counter-flank

---

### Q: How does AI use grenades?

**A**: **Tactically** - Targets clusters and destroys cover.

**Grenade AI Logic**:
- **Target clusters**: 3+ player units in grenade radius = high priority
- **Destroy cover**: Remove cover protecting player units
- **Finish wounded**: Use grenades on low-health targets
- **Suppress**: Create smoke or fire to block player movement

**Grenade Priority Conditions**:
1. **3+ units in blast**: Automatic grenade use
2. **Cover destruction**: If player relies on single cover piece
3. **Wounded target**: If grenade guarantees kill
4. **Retreat aid**: Smoke grenades to cover retreat

---

## Faction AI Strategies

### Q: Do different alien factions have different AI?

**A**: **Yes** - Each faction has unique **strategic behavior** (like **Total War** faction traits).

**Faction AI Personalities**:

### 1. Sectoids (Psionic Focus)
- **Strategy**: Mind control, stay at range
- **Tactics**: Avoid melee, use psionic attacks
- **Behavior**: Defensive, rely on abilities
- **Weakness**: Low health, vulnerable to rushes

### 2. Ethereals (Mind Control Specialists)
- **Strategy**: Dominate battlefield through psionics
- **Tactics**: Stay behind lines, control player units
- **Behavior**: Ultra-defensive, maximum range
- **Weakness**: Require line of sight for psionics

### 3. Mutons (Brute Force)
- **Strategy**: Overwhelm with strength
- **Tactics**: Charge forward, melee focus
- **Behavior**: Aggressive, fearless
- **Weakness**: Low accuracy at range

### 4. Chryssalids (Biological Horror)
- **Strategy**: Swarm and infect
- **Tactics**: Rush with overwhelming numbers
- **Behavior**: Berserker (ignore losses)
- **Weakness**: No ranged attacks

### 5. Cyberdiscs (Mechanical Warfare)
- **Strategy**: Heavy firepower, high armor
- **Tactics**: Suppress player, area denial
- **Behavior**: Calculated, prioritizes survival
- **Weakness**: Vulnerable to EMP

---

### Q: Do factions adapt to player strategies?

**A**: **Yes** - Factions **learn and counter** player tactics (unique mechanic).

**Adaptation System**:

**Player Behavior Tracked**:
- **Weapon usage**: Which weapons player favors
- **Tactics**: Flanking frequency, grenade usage, overwatch reliance
- **Unit composition**: Soldier/sniper/heavy ratio
- **Mission approach**: Stealth vs. aggression

**Faction Response** (after 5-10 missions):
- **Counter-weapons**: Deploy units resistant to player's favorite weapons
- **Counter-tactics**: If player flanks often, AI guards flanks better
- **Counter-composition**: If player uses snipers, AI deploys faster melee units
- **Counter-approach**: If player plays stealthy, AI uses sensors

**Example**:
1. Player frequently uses snipers (long-range)
2. After 5 missions, AI analysis complete
3. Next mission: AI deploys fast melee units (Chryssalids) to counter snipers
4. Player must adapt strategy

---

### Q: Can I exploit AI patterns?

**A**: **Initially yes, but AI adapts** (anti-cheese mechanic).

**Common Exploits & AI Responses**:

| Player Exploit | AI Counter-Adaptation |
|----------------|----------------------|
| **Overwatch camp** | AI uses grenades to destroy cover, forces movement |
| **Sniper nest** | AI sends fast melee units, uses smoke |
| **Grenade spam** | AI spreads out, avoids clustering |
| **Door camping** | AI breaches walls, uses alternate entry |
| **Line of sight abuse** | AI uses indirect fire (grenades, mortars) |

**Adaptation Time**: 5-10 missions before AI fully counters strategy

---

## Difficulty Scaling

### Q: How does difficulty affect AI?

**A**: **Three scaling factors** (like **Civilization** difficulty).

**Difficulty Settings**:

| Difficulty | Squad Size | AI Intelligence | Reinforcements |
|------------|------------|-----------------|----------------|
| **Easy** | 75% | 50% | None |
| **Normal** | 100% | 100% | None |
| **Hard** | 125% | 200% | 1 wave |
| **Impossible** | 150% | 300% | 2-3 waves |

**AI Intelligence Scaling**:
- **50%**: Basic tactics, predictable
- **100%**: Standard tactics, uses abilities
- **200%**: Advanced tactics, flanking, coordination
- **300%**: Expert tactics, perfect ability timing, adaptive

**Squad Size Example**:
- Normal difficulty: 6-unit enemy squad
- Hard difficulty: 8-unit enemy squad (125% = +2 units)
- Impossible: 9-unit enemy squad (150% = +3 units)

---

### Q: Do reinforcements spawn during battle?

**A**: **Yes** - On Hard/Impossible difficulty (like **XCOM 2** reinforcements).

**Reinforcement Mechanics**:
- **Timing**: Turn 5, 10, 15 (varies by mission)
- **Size**: 3-6 units per wave
- **Location**: Map edges, predetermined spawn points
- **Warning**: 1-turn warning before arrival

**Difficulty Comparison**:
- **Easy/Normal**: No reinforcements (static enemy count)
- **Hard**: 1 reinforcement wave (mid-mission)
- **Impossible**: 2-3 waves (constant pressure)

**Strategic Impact**:
- Forces aggressive play (can't camp)
- Time pressure (complete objectives before overwhelmed)
- Resource drain (ammunition, medikits)

---

## Autonomous Playtesting

### Q: What is autonomous playtesting?

**A**: **AI plays the game against itself** to balance content (unique feature).

**How It Works**:
1. **AI plays both sides**: Player AI vs. Enemy AI
2. **Thousands of simulations**: Test balance automatically
3. **Data collection**: Win rates, survival rates, weapon effectiveness
4. **Auto-balancing**: Adjust stats based on results

**What Gets Tested**:
- **Weapon balance**: If weapon has 80%+ win rate, nerf it
- **Enemy difficulty**: If enemies win 70%+ missions, tone down
- **Map balance**: If one spawn position wins 60%+, adjust map
- **Unit viability**: If unit never survives, buff it

---

### Q: Does AI cheat in playtesting?

**A**: **No** - AI uses same rules as players.

**Playtesting AI Rules**:
- Uses exact player unit stats
- Follows fog of war (no omniscience)
- Uses same weapons/equipment available to players
- Obeys AP/movement/energy restrictions

**Goal**: Simulate real player experience, not test with cheating AI

---

### Q: How does this affect balance?

**A**: **Continuous auto-balancing** (like **MOBAs** patch cycles).

**Balance Workflow**:
1. **Detect imbalance**: Playtesting AI finds overpowered weapons (80%+ win rate)
2. **Adjust values**: Reduce damage/accuracy/range
3. **Re-test**: Run 1,000 more simulations
4. **Validate**: Check if win rate normalized (45-55% ideal)
5. **Deploy**: Update game with balanced values

**Example**:
- Plasma Rifle: 85% win rate detected
- Nerf damage: 60 → 50
- Re-test: 52% win rate
- Deploy update: Plasma Rifle balanced

**Benefits**:
- No human bias in balance
- Fast iteration (thousands of tests per hour)
- Continuous improvement

---

## Strategic Escalation

### Q: Does the game get harder over time?

**A**: **Yes** - Dynamic difficulty (like **XCOM 2 Avatar Project**).

**Escalation Mechanics**:
- **Month 1-3**: Basic enemies (Sectoids, weak units)
- **Month 4-6**: Advanced enemies (Mutons, Ethereals)
- **Month 7-9**: Elite enemies (Chryssalids swarms)
- **Month 10+**: Ultimate enemies (Battleships, psionic masters)

**Technology Arms Race**:
- Player researches plasma weapons → Enemies deploy plasma-resistant armor
- Player uses stealth → Enemies deploy sensors
- Player builds psionic units → Enemies use psi-shields

---

### Q: Can I slow down escalation?

**A**: **Yes** - By **destroying alien infrastructure** (strategic targets).

**Escalation Reduction**:
- **Destroy UFO bases**: -10% escalation per base
- **Disrupt supply lines**: -5% escalation per disruption
- **Complete strategic objectives**: -20% escalation
- **Eliminate faction leadership**: -30% escalation (major victory)

**Escalation Formula**:
```
Escalation Level = (Month × 10) - (Strategic Victories × 20)
If Escalation < 0, no new enemy types deploy
```

**Example**:
- Month 5: Base escalation 50%
- Destroyed 2 UFO bases: -20%
- Final escalation: 30% (delayed enemy progression)

---

## Game Comparisons

### Q: How does this compare to XCOM AI?

**Comparison**:

| Feature | XCOM (1994) | XCOM 2 (2016) | AlienFall |
|---------|-------------|---------------|-----------|
| **Cover Usage** | ⚠️ Basic | ✅ Advanced | ✅ Advanced |
| **Flanking** | ❌ No | ✅ Yes | ✅ Yes |
| **Ability Usage** | ❌ Limited | ✅ Tactical | ✅ Tactical |
| **Adaptation** | ❌ No | ❌ No | ✅ Yes (learns) |
| **Cheating** | ⚠️ Some | ⚠️ Some | ❌ None |
| **Faction AI** | ❌ Same | ⚠️ Minor differences | ✅ Unique personalities |

**Biggest Difference**: **AlienFall AI adapts to player strategies** (unique mechanic)

---

### Q: Is this like Total War AI?

**A**: **Partially** - Similar faction personalities, different tactical depth.

**Similarities**:
- ✅ Faction-specific AI behaviors
- ✅ Difficulty scaling (squad size, reinforcements)
- ✅ Morale system affects AI decisions
- ✅ Retreat logic when losing

**Differences**:
- ✅ AlienFall AI adapts to player (Total War doesn't)
- ❌ No formation mechanics (hex-based, not rank-and-file)
- ✅ Autonomous playtesting (unique to AlienFall)

---

### Q: How does it compare to 4X game AI?

**A**: **Strategic layer similar** to Civilization AI.

| Feature | Civilization | Stellaris | AlienFall |
|---------|--------------|-----------|-----------|
| **Strategic Planning** | ✅ Yes | ✅ Yes | ✅ Yes (faction goals) |
| **Diplomacy AI** | ✅ Complex | ✅ Complex | ⚠️ Simplified |
| **War Preparation** | ✅ Yes | ✅ Yes | ✅ Yes (escalation) |
| **Adaptive AI** | ❌ No | ❌ No | ✅ Yes |
| **Tactical Combat AI** | ⚠️ Basic | ⚠️ Auto-resolve | ✅ Advanced (hex-based) |

**AlienFall combines**:
- 4X strategic AI (escalation, faction goals)
- XCOM tactical AI (hex combat, abilities)
- Unique adaptation system

---

## Related Content

**For detailed information, see**:
- **[AI.md](../mechanics/AI.md)** - Complete AI system specification
- **[Battlescape.md](../mechanics/Battlescape.md)** - Tactical combat where AI operates
- **[Geoscape.md](../mechanics/Geoscape.md)** - Strategic AI behaviors
- **[Missions.md](../mechanics/Missions.md)** - AI mission generation

---

## Quick Reference

**AI Intelligence**: 50% (Easy) to 300% (Impossible)  
**Adaptation Time**: 5-10 missions to learn player strategies  
**Reinforcements**: None (Easy/Normal), 1 wave (Hard), 2-3 waves (Impossible)  
**Squad Size Scaling**: 75% (Easy) to 150% (Impossible)  
**Cheating**: None (AI uses same rules as player)  
**Faction AI**: 5 unique personalities (Sectoids, Ethereals, Mutons, Chryssalids, Cyberdiscs)  
**Escalation**: +10% per month, reducible via strategic victories  
**Autonomous Playtesting**: Continuous balance testing via AI vs AI simulations

