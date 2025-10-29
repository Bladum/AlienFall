# FAQ: Game Overview & Core Loop

[← Back to FAQ Index](FAQ_INDEX.md)

---

## What kind of game is AlienFall?

**Short answer**: X-COM UFO Defense + Civilization + Magic: The Gathering, but with no fixed victory conditions.

**Detailed answer**: AlienFall is a turn-based strategy game with three interconnected layers:
- **Strategic layer (Geoscape)**: Like Civilization's world map - manage global operations, diplomacy, and long-term planning
- **Operational layer (Basescape)**: Like SimCity meets X-COM base - build facilities, research tech, manufacture equipment
- **Tactical layer (Battlescape)**: Like X-COM combat meets roguelikes - squad-based hex combat with procedural maps and permadeath
- **Bonus layer (Interception)**: Like Magic: The Gathering - card-game style air combat between Geoscape and Battlescape

---

## Q: Is this just an X-COM clone?

**A**: No. While heavily inspired by X-COM, AlienFall has fundamental differences:

| Aspect | X-COM | AlienFall |
|--------|-------|-----------|
| **Victory** | Destroy alien base to win | No fixed victory - sandbox progression |
| **Time pressure** | Calendar-based with fail states | Monthly cycles, no game-over timer |
| **Interception** | Real-time air combat minigame | Turn-based card combat system (MTG-style) |
| **Base building** | One main base focus | Multiple bases, one per province (territorial control) |
| **Unit progression** | Stats increase gradually | Battle for Wesnoth-style rank promotions with branching paths |
| **Battlescape** | Scripted maps | Procedurally generated roguelike dungeons |
| **Diplomacy** | Funding only | Europa Universalis-style relations with countries |
| **Campaign** | Linear story | Emergent narrative, faction dynamics |

---

## Q: How does the core game loop work?

**A**: Think of it as nested loops, like Civilization + X-COM combined:

### Monthly Strategic Cycle (Geoscape)
1. **Morning phase**: Check country relations, receive funding, review missions
2. **Planning phase**: Deploy craft, start research, queue manufacturing
3. **Interception**: Card combat when encountering UFOs (MTG-style)
4. **Mission deployment**: Select squad for ground combat
5. **Battlescape**: Tactical hex combat (X-COM + roguelike)
6. **After-action**: Collect salvage, heal wounded, upgrade equipment
7. **End month**: Relations update, alien threat escalates, new missions spawn

### Comparison to Similar Games:
- **Like Civilization**: Monthly turns with multiple actions per turn
- **Like X-COM**: Geoscape → Interception → Battlescape flow
- **Unlike XCOM 2**: No doom clock forcing you forward
- **Unlike Phoenix Point**: No real-time elements anywhere

---

## Q: What are the victory conditions?

**A**: **There are none!** This is a sandbox campaign like Minecraft or Dwarf Fortress.

You create your own goals:
- **Military victory**: Eliminate all alien factions
- **Economic victory**: Achieve 100% funding from all countries
- **Scientific victory**: Research all technologies
- **Territorial victory**: Control all provinces with bases
- **Diplomatic victory**: Allied with all countries
- **Survivor mode**: Last as long as possible against escalating threats

**Why no fixed victory?**
- Encourages experimentation and multiple playstyles
- Avoids "optimal path" syndrome from X-COM/XCOM 2
- Supports modding community creating their own campaigns
- Players can set personal challenges (speedruns, pacifist runs, etc.)

---

## Q: How does time work? Is it real-time like Europa Universalis or turn-based like Civilization?

**A**: **Asynchronous turn-based** - a hybrid system:

### On the Geoscape (Strategic)
- Time advances in **monthly increments**
- Actions have **realistic delays** (research takes days, travel takes hours)
- You can pause, plan, and execute multiple actions before advancing time
- **Unlike real-time strategy**: No time pressure, think as long as you want
- **Like Civilization**: Discrete turns with multi-action planning
- **Unlike X-COM**: No real-time interception minigame

### On the Battlescape (Tactical)
- Pure turn-based combat with no time limits
- Each turn = 30 seconds of in-game time
- All units move, then all enemies move (alternating phases)
- **Like X-COM**: Traditional turn-based tactical combat
- **Unlike Invisible Inc**: No simultaneous resolution
- **Like Into the Breach**: See enemy actions before they happen

### During Interception (Air Combat)
- Turn-based card combat system
- Action points determine what you can do each turn
- **Like Magic: The Gathering**: Mana (energy) + action points
- **Like Slay the Spire**: Deck building with resource management
- **Unlike X-COM**: No real-time dodging or positioning

---

## Q: Can I save and load anytime? Is there ironman mode?

**A**: **Yes and no**:
- **Manual saves**: Save anytime on Geoscape (like Civilization)
- **Auto-saves**: Before each battle (like X-COM)
- **Ironman mode**: Not enforced, but supported
- **Permadeath**: Units die permanently in combat (like X-COM)
- **No reload cheesing**: Missions generate procedurally, so reloading gives different maps

**Comparison**:
- **Like X-COM**: Auto-save before battles
- **Like Civilization**: Manual save system
- **Unlike XCOM 2**: No enforced ironman option
- **Like Darkest Dungeon**: Losses are permanent and meaningful

---

## Q: How long is a typical campaign?

**A**: **Variable**, since there's no fixed ending:

| Playstyle | Estimated Duration | Comparison |
|-----------|-------------------|------------|
| **Speed run** (1 faction eliminated) | 10-20 hours | Short X-COM campaign |
| **Casual play** (multiple factions) | 30-50 hours | Standard Civilization game |
| **Completionist** (all tech, all provinces) | 60-100 hours | Long XCOM 2 campaign |
| **Endless survival** | Infinite | Dwarf Fortress fortress mode |

**Factors affecting length**:
- Number of factions active
- Self-imposed challenges
- How aggressive you expand
- Whether you pursue all research branches

---

## Q: Is there a tutorial?

**A**: **In development**. Currently:
- Tooltips explain mechanics in-game
- This FAQ serves as reference documentation
- Design documents provide detailed explanations
- Modding community creates guides

**Planned features**:
- Interactive tutorial missions
- Context-sensitive help system
- Advisor characters (like Civilization)

---

## Q: What makes AlienFall unique compared to other X-COM-likes?

**A**: Key differentiators:

1. **Three-layer architecture**: Most games have 2 layers (strategy + tactics). AlienFall adds Basescape as a separate city-building layer.

2. **Card-based air combat**: Instead of real-time interception, you build "decks" of craft weapons and play them tactically.

3. **Territorial base building**: One base per province (like Risk territories) instead of unlimited scattered bases.

4. **Procedural battlescape**: Every combat map is unique, roguelike-style.

5. **Sandbox campaign**: No forced narrative or win conditions.

6. **Battle for Wesnoth promotions**: Units have branching promotion trees, not just stat increases.

7. **Data-driven modding**: Everything is TOML files, making total conversions easy.

8. **Multi-faction dynamics**: Aliens aren't unified - factions compete and evolve.

---

## Q: Can I play this like [other game]?

### Like X-COM UFO Defense?
✅ Yes, very similar core loop  
✅ Research tech from salvage  
✅ Build bases and manage economy  
❌ Different interception system  
❌ No fixed victory condition  

### Like XCOM 2?
✅ Squad-based tactical combat  
✅ Soldier progression and customization  
❌ No avatar project timer  
❌ Different base building (grid-based)  
❌ Card-based air combat  

### Like Civilization?
✅ Monthly strategic turns  
✅ Diplomacy with multiple nations  
✅ Tech tree research  
❌ No culture/religion mechanics  
❌ Combat is X-COM-style, not civ armies  

### Like Phoenix Point?
✅ Global map management  
✅ Multiple faction dynamics  
❌ No real-time elements  
❌ Different combat resolution  
❌ Card-based interception  

---

## Q: What's the learning curve like?

**A**: **Steep initially, but approachable for genre veterans**:

| Background | Learning Curve |
|------------|---------------|
| **X-COM veterans** | Gentle - most mechanics are familiar |
| **Civilization players** | Moderate - strategic layer feels natural |
| **Card game players (MTG/Hearthstone)** | Moderate - interception will feel natural |
| **New to strategy games** | Steep - lots of interconnected systems |

**Recommended learning path**:
1. Start with Geoscape tutorial (if you know Civilization)
2. Start with Battlescape tutorial (if you know X-COM)
3. Read this FAQ section by section
4. Play a short test campaign to learn systems
5. Restart with knowledge gained (normal for 4X games)

---

## Q: Is multiplayer planned?

**A**: **Not currently**, but the architecture supports it:
- Turn-based gameplay is multiplayer-friendly
- Save/load system could enable "play by email" style
- AI can replace human players during testing
- Community interest may drive future development

---

## Q: What's the tone/theme? Is it serious like X-COM or humorous?

**A**: **Serious military sci-fi with moral ambiguity**:
- You lead a covert organization, not always the "good guys"
- Karma system tracks ethical choices (hidden)
- Alien factions have their own motivations
- No cartoonish humor, grounded tone
- Similar to original X-COM, not the reboots

---

## Q: How replayable is it?

**A**: **Extremely high replayability**:

**Factors creating replayability**:
- Procedural battlescape maps (roguelike dungeons)
- Multiple faction configurations
- Branching research paths (can't get everything)
- Different base placement strategies
- Karma system creates different story outcomes
- Unit permadeath makes each campaign unique
- Modding support enables total conversions

**Comparison**:
- **More replayable than**: X-COM (scripted maps)
- **Similar to**: Civilization (every game is different)
- **Similar to**: Roguelikes (procedural content)
- **Less replayable than**: Dwarf Fortress (infinite complexity)

---

## Q: What platforms does it support?

**A**: **Desktop platforms via Love2D**:
- Windows ✅
- Linux ✅
- macOS ✅
- Mobile ❌ (not planned)
- Web browser ❌ (not planned)

---

## Q: Is it open source? Can I contribute?

**A**: **Yes!**
- Fully open source on GitHub
- Lua + Love2D engine (easy to learn)
- TOML-based content (no coding needed for mods)
- Active development with AI assistance
- Community contributions welcome

---

## Next Steps

- **Understand the strategic layer**: Read [Geoscape FAQ](FAQ_GEOSCAPE.md)
- **Learn base building**: Read [Basescape FAQ](FAQ_BASESCAPE.md)
- **Master tactical combat**: Read [Battlescape FAQ](FAQ_BATTLESCAPE.md)
- **Explore air combat**: Read [Interception FAQ](FAQ_INTERCEPTION.md)

[← Back to FAQ Index](FAQ_INDEX.md)

