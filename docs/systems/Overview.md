# AlienFall: Complete Documentation Overview (TL;DR)

**Version**: 1.0 | **Last Updated**: October 20, 2025 | **Audience**: New players, developers, designers

---

## One-Sentence Summary

AlienFall is a turn-based strategy game inspired by X-COM where players lead a covert global organization against alien threats through strategic resource management, turn-based tactical combat, and evolving organizational complexity.

---

## What is AlienFall?

### Project Identity

**AlienFall** (also known as XCOM Simple) is an open-source, turn-based strategy game developed using Love2D (Lua) as both a game and an experiment in AI-assisted game development. It combines:

- **Strategic depth** (Geoscape): Global resource management, diplomacy, and long-term planning
- **Tactical challenge** (Battlescape): Squad-level turn-based combat on procedurally generated maps
- **Economic simulation** (Basescape): Base construction, facility management, and resource production
- **Progression systems**: Unit advancement, technology research, and organizational growth
- **Open-ended gameplay**: No fixed victory conditions; sandbox environment encouraging experimentation

### Game Type Classification

| Category | Classification |
|----------|---|
| **Genre** | Turn-Based Strategy / Tactical RPG |
| **Platform** | Desktop (Windows/Linux/Mac via Love2D) |
| **Perspective** | Top-down isometric for Geoscape/Basescape; hex-grid tactical for Battlescape |
| **Game Flow** | Asynchronous turn-based (no real-time pressure) |
| **Playerstyle** | Single-player with save/load progression |
| **Modding** | Supports YAML/Lua total conversions through mod system |
| **Theme** | Sci-fi military with X-COM inspiration, morally ambiguous protagonist |

### Target Audience

- **Core Gamers**: Players experienced with tactical turn-based games (X-COM, Civilization, Fire Emblem)
- **Strategy Enthusiasts**: Those who enjoy macro-level resource optimization and strategic planning
- **Modders**: Community members interested in creating total conversion content
- **AI/Game Dev Community**: Interest in agentic code generation and collaborative AI development
- **Lore Fans**: Players interested in branching narrative and faction dynamics

### Inspirations & References

- **X-COM: UFO Defense** (primary mechanical inspiration; not a clone)
- **Heroes of Might and Magic** (Geoscape resource management analogy)
- **Civilization** (diplomatic relations, research trees, cultural development)
- **Eador** (multi-level strategic simulation)
- **Battle for Wesnoth** (promotion tree mechanics, unit attachment)
- **UFO: Enemy Unknown** (turn-based alien combat reference)

---

## Core Game Systems (3-Layer Architecture)

AlienFall operates on three distinct but interconnected layers:

### 1. GEOSCAPE (Strategic Layer) - Monthly Cycles

**What Players Do**:
- Manage a global covert organization defending Earth from alien threats
- Deploy craft to intercept UFOs and respond to missions
- Build bases in strategic locations to expand operational reach
- Balance diplomacy with allied nations to maintain funding
- Respond to escalating alien threats with strategic decision-making

**Key Mechanics**:
- **World Map**: 90×45 hexagonal grid representing Earth divided into provinces and regions
- **Bases**: Player constructs one permanent base per province for operations
- **Craft**: Vehicles that travel between provinces and intercept UFOs
- **Missions**: Procedurally generated threats (UFO crashes, alien bases, colony defense, etc.)
- **Detection**: Radar systems reveal nearby threats; stealth UFOs hide until detected
- **Relations**: Diplomacy with countries affects funding, mission availability, and marketplace access
- **Escalation**: Alien threat level rises monthly; peaks trigger UFO armada events
- **Interception**: Deploy craft to combat UFOs before they complete ground missions

**Timescale**: Monthly game updates; most actions resolve after 1-30 day delays

**Victory Path**: No fixed win condition; player creates goals (eliminate alien factions, achieve 100% funding, research all tech, conquer all regions, etc.)

---

### 2. BASESCAPE (Operational Layer) - Daily Management

**What Players Do**:
- Design and expand base facilities within a hex-grid layout
- Recruit and train soldiers into specialized combat units
- Direct research projects to unlock new technologies and equipment
- Manage manufacturing queues to produce weapons and supplies
- Allocate monthly budget between facilities, personnel, and growth

**Key Mechanics**:
- **Base Grid**: Hexagonal facility layout; base size (4×4 to 7×7) determines capacity and cost
- **Facilities**: Modular buildings (Labs, Workshops, Barracks, etc.) providing services through adjacency bonuses
- **Service Economy**: Power, Research Capacity, Manufacturing Capacity traded as binary resources
- **Personnel**: Units serve as soldiers and pseudo-workforce; no individual scientists/engineers
- **Research**: Unlocks technology categories enabling manufacturing and new gameplay options
- **Manufacturing**: Produces equipment, ammunition, and consumables significantly cheaper than marketplace
- **Marketplace**: Commerce system with competing suppliers; pricing/availability affected by diplomacy
- **Maintenance**: Monthly costs scale with base complexity; growth creates economic pressure
- **Transfers**: Inter-base logistics enabling resource redistribution and supply chains

**Timescale**: Daily decisions; facility construction takes weeks; research takes weeks

**Feedback Loop**: Mission salvage → research unlock → manufacturing → equipped units → better missions → more salvage

---

### 3. BATTLESCAPE (Tactical Layer) - Per-Mission Combat

**What Players Do**:
- Deploy squads to alien mission sites for tactical ground combat
- Navigate procedurally generated maps using hex-grid movement
- Engage aliens using turn-based action economy (4 AP per unit per turn)
- Manage unit positioning, cover utilization, and ammunition
- Extract objectives while minimizing casualties and damage

**Key Mechanics**:
- **Hex Grid Combat**: 2-3 meter hexagons; each hex holds 1 unit maximum
- **Procedural Maps**: Generated from map blocks (15-hex clusters) procedurally assembled into battles
- **Turn Order**: Player team → Allied teams → Enemy teams; player controls unit action order
- **Action Economy**: 4 AP per unit per turn; actions include Move, Fire, Overwatch, Rest, Cover, Suppress, Throw
- **Line-of-Sight**: Visibility calculation with sight cost; determines what units can see and target
- **Accuracy**: Hit chance derived from unit accuracy, weapon, range, cover, and visibility; 5-95% clamped
- **Weapon Modes**: Different firing configurations (Snap, Burst, Aim) modifying accuracy and AP cost
- **Environmental Hazards**: Smoke, fire, and gas clouds creating dynamic tactical challenges
- **Terrain Destruction**: Destructible walls and cover; destroyed obstacles become rubble
- **Unit Psychology**: Morale and sanity systems creating breakdown conditions under stress
- **Mission Objectives**: Goals like Eliminate Enemies, Defend Objective, Rescue Units, Reach Location

**Timescale**: Single mission typically 15-30 turns (7.5-15 minutes of in-game time)

**Reward Structure**: XP (unit promotion), equipment salvage, research opportunities, mission rewards

---

## Integration: How Systems Connect

### Vertical Integration (Top-Down)

```
GEOSCAPE Decision
  ↓ (generates mission type/difficulty)
BATTLESCAPE Combat
  ↓ (produces salvage and casualties)
BASESCAPE Salvage Processing
  ↓ (enables research and manufacturing)
GEOSCAPE Capability Unlock
  ↓ (improves strategic options)
LOOP
```

**Example**: Player decides to defend an important region (Geoscape) → accepts base defense mission (Battlescape) → defeats aliens and captures armor (Battlescape) → analyzes armor technology (Basescape research) → unlocks advanced armor manufacturing (Basescape) → equips next squad with better armor (Basescape) → next mission has higher success rate (Geoscape improvement).

### Horizontal Integration (System Interaction)

- **Economy**: Mission salvage funds research and manufacturing; manufacturing revenue supplements country funding
- **Diplomacy**: Mission performance in regions affects country relations; relations determine funding levels
- **Technology**: Research unlocks manufacturing categories; manufacturing supplies equipped units
- **Unit Progression**: Battlescape XP drives Basescape training; trained units improve Geoscape mission success
- **Escalation**: Geoscape threat level determines Battlescape enemy squad composition and Basescape facility defense requirements

---

## Gameplay Loop: A Campaign Turn

### The Monthly Cycle

**Phase 1: Strategic Planning (Geoscape)**
1. Review alien mission locations detected by radar
2. Assess resource situation (credits, materials, craftavailability)
3. Decide craft deployment strategy (intercept UFO or let it land for ground mission?)
4. Prioritize base expansion or facility construction
5. Set research and manufacturing focus for the month

**Phase 2: Tactical Execution (Battlescape)**
1. Craft deploys to UFO/Mission location
2. Squad enters tactical battle map
3. Player controls unit actions for 15-30 turns
4. Complete mission objective while managing casualties
5. Extract salvage and gather intelligence

**Phase 3: Recovery & Planning (Basescape)**
1. Wounded units enter hospital for recovery
2. Salvage processed into resources
3. Research projects advance based on scientist allocation
4. Manufacturing produces equipped for next squad
5. Marketplace purchases supplement production
6. Monthly financial reconciliation resolves
7. Country relations update based on regional performance
8. Next cycle begins

**Time Scale**: ~1-2 hours per campaign month in active play

---

## Key Design Principles

### 1. **Deterministic Decision-Making**
- All outcomes derive from state rules, not random probability
- Apparent randomness emerges from incomplete information and probabilistic generation
- Debugging and analysis enabled through transparent decision logging

### 2. **Organizational Growth**
- Player organization evolves through five stages:
  1. **Covert Actions**: Underground startup investigating anomalies
  2. **Covert Bureau**: Government-affiliated shadow agency
  3. **Covert Command**: Global strike force with elite units
  4. **Covert Division**: Militarized planetary defense organization
  5. **Covert Enclave**: Interplanetary power with independent agenda

### 3. **Turn-Based Non-Real-Time**
- All gameplay is turn-based; no real-time pressure exists
- Geoscape turns = 1 calendar day; Battlescape turns = ~30 seconds
- Players have unlimited time to make tactical decisions

### 4. **Meaningful Unit Attachment**
- Units persist across missions and gain experience/specialization
- Player emotional investment grows as veterans advance in rank
- Veteran loss feels catastrophic, creating tactical caution

### 5. **Multiple Valid Playstyles**
- **Research-Focused**: Prioritize tech advantage through early research
- **Manufacturing-Focused**: Economic dominance through production capacity
- **Defense-Focused**: Military hardening and interception superiority
- **Support-Focused**: Elite unit development through training and healthcare
- **All strategies viable**: No single dominant path; rebalancing maintains options

### 6. **Resource Scarcity Creates Tension**
- Limited monthly budgets force prioritization
- Manufacturing requires raw materials; research requires scientist man-days
- Facility capacity creates bottlenecks; expansion costs time and credits
- Economic pressure creates difficulty without artificial AI advantage

### 7. **Moddability Through Configuration**
- YAML-based configuration enables total conversions
- No scripting language required; data-driven design enables easy modding
- Multiple factions, unit types, and equipment categories easily configurable

---

## Economy at a Glance

### Monthly Financial Flow

**Income Sources**:
- Country funding (primary, scales 0-10 levels based on relations)
- Manufacturing profit (secondary, scales with production volume)
- Research milestone bonuses (tertiary, one-time per technology)
- Equipment resale (small, 50% of purchase price)

**Expense Sources**:
- Base maintenance (scales with base size: 5K × size²)
- Facility maintenance (per-facility 5-50K monthly)
- Unit salaries (5K per unit per month)
- Craft maintenance (2K per craft per month)
- Research funding (scientist man-days × labor cost)
- Manufacturing labor (engineer man-days × labor cost)
- Facility repair (damage from UFO attacks)

**Economic Strategy**:
- Early game: Tight budget; must prioritize research vs. expansion
- Mid game: Growth income; expand facilities and unit count
- Late game: Exponential income; research acceleration possible

---

## Win/Loss Conditions & Progression

### Victory Conditions (Player-Defined)

Since no fixed win condition exists, players create goals:

- **Eliminate All Factions**: Destroy all alien bases and UFO forces
- **Achieve 100% Funding**: Max out country relations and monthly income
- **Research All Technology**: Unlock complete tech tree
- **Conquer All Regions**: Establish bases in all major world regions
- **Build Ultimate Unit**: Advance one unit to Hero rank (rank 6)
- **Survive Indefinitely**: Campaign endurance challenge

### Loss Conditions (Hard Triggers)

- **Organizational Collapse**: All bases destroyed; insufficient resources to rebuild
- **Funding Dissolution**: Countries abandon support; monthly funding reaches 0
- **Overwhelming Invasion**: Alien forces overrun defenses faster than replacements possible
- **Strategic Paralysis**: Insufficient resource production to equip next squad

### Difficulty Scaling

- **Easy**: 75% enemy squad size; reduced AI aggression; no reinforcements
- **Normal**: 100% enemy squad size; standard AI behavior
- **Hard**: 125% enemy squad size; enhanced AI tactics; 1 reinforcement wave
- **Impossible**: 150% enemy squad size; expert AI behavior; 2-3 reinforcement waves

---

## Content Breadth: What's Available?

### Units & Specializations
- **Human Classes**: Soldier, Medic, Sniper, Assault, Engineer, Leader (6 primary, extensible)
- **Alien Types**: Sectoids, Ethereals, Hybrids, Mutons, Celatids (5+ faction types)
- **Unit Ranks**: 0-6 (recruit to hero); stat progression with diminishing returns

### Equipment Categories
- **Weapons**: Pistols, Rifles, Sniper Rifles, Shotguns, Grenades, Melee, Psi-weapons
- **Armor**: Light Scout, Combat Armor, Heavy Assault, Hazmat, Stealth, Specialist variants
- **Items**: Medikit, Flashlight, Night Vision, Motion Scanner, Psionic Amplifier (expandable)
- **Ammunition Types**: Kinetic, Energy, Explosive, Chemical, Biological, Psionic

### Facility Types
- **Production**: Lab, Workshop, Academy (research and manufacturing)
- **Support**: Hospital, Temple, Barracks (unit support and housing)
- **Logistics**: Storage, Garage, Hangar (inventory and craft management)
- **Defense**: Turret, Radar, Corridor (base protection and detection)
- **Special**: Prison (interrogation), Corridor (connection)

### Research Paths
- **Human Tech**: 3-tier progression (Basic → Advanced → Cutting-Edge)
- **Alien Tech**: Unlocked after capturing aliens (5-tier progression)
- **Hybrid Tech**: Combining human and alien knowledge (end-game content)

### Regions & Nations
- **Earth Regions**: ~30-50 countries and regions across multiple continents
- **Alien Worlds**: Discovered through progression (Moon, Mars, alien homeworlds)
- **Special Locations**: Strategic facilities, resource nodes, dimensional rifts

---

## Content Depth & Replayability

### Procedural Generation
- **Map Generation**: Battlescape maps procedurally assembled from map blocks per biome
- **Mission Generation**: Missions procedurally created based on faction state and escalation
- **Difficulty Scaling**: Encounters dynamically scale with player advancement
- **Campaign Variety**: Random campaign start conditions (relations, resources, threat levels)

### Randomness Elements
- **Equipment Drops**: Random salvage selection from defeated enemies
- **Promotions**: Random stat distribution when units advance ranks (with biases)
- **Research Costs**: Multiplier (50-150%) randomly determined per campaign for replayability
- **Supply Availability**: Marketplace stock fluctuation per month

### Replayability Factors
- **Multiple Playstyles**: Different facility prioritization creates distinct playthroughs
- **Difficulty Scaling**: 4 difficulty modes provide 4+ distinct challenge levels
- **Campaign Variation**: Different starting conditions and random events
- **Modding Support**: Total conversion potential enables community-created content

---

## Current Development Status

### What's Implemented

- **Geoscape Core**: World map, provinces, nations, basic mission generation
- **Basescape Core**: Facility system, unit management, research, manufacturing
- **Battlescape Core**: Hex-grid combat, turn-based actions, line-of-sight, accuracy system
- **Economy**: Marketplace, suppliers, transfer system, research trees
- **Progression**: Unit XP, promotions, equipment, technology unlocks
- **AI Systems**: Strategic (faction behavior), Operational (UFO tactics), Tactical (squad combat)

### What's In Progress / Planned

- **3D Battlescape**: First-person/2.5D perspective variant for immersion
- **Expanded Modding**: More configuration options and community content support
- **AI Integration**: Future LLM integration for narrative generation and player assistance
- **Multiplayer**: Possible cooperative squad management (not core design)
- **Performance**: Optimization for lower-spec systems

### Known Limitations

- **Lua/Love2D Constraints**: No C++ modules; performance limited to Lua speed ceiling
- **Asset Creation**: Pixel art currently 16×16 upscaled to 32×32 (limiting detail)
- **Content Volume**: Relatively lean on narrative/dialogue (focuses on mechanics)
- **Single-Player Only**: Multiplayer not implemented (possible future feature)

---

## How to Get Started

### For Players
1. Run `lovec "engine"` or execute `run_xcom.bat`
2. Configure difficulty and starting conditions
3. Place first base in strategic location
4. Recruit initial squad and respond to first alien contact
5. Expect learning curve; tutorials optional

### For Developers
1. Read `../wiki/API.md` for system interfaces
2. Review `../wiki/DEVELOPMENT.md` for workflow
3. Examine `../engine/main.lua` for entry point
4. Study individual system documents (Geoscape.md, Battlescape.md, etc.)
5. Check `../tests/` folder for test patterns

### For Modders
1. Study `../mods/README.md` for mod structure
2. Review configuration file format in `../mods/core/`
3. Create new mod in `../mods/new/`
4. Test using `lovec "engine"` with mod enabled

### For Designers
1. Read all documentation files in `../` folder
2. Review balance parameters in system documents
3. Create design specifications in `../tasks/TODO/` folder using TASK_TEMPLATE.md
4. Use `../tasks/tasks.md` to track design work

---

## Key Takeaways

| Aspect | Summary |
|--------|---------|
| **What** | Turn-based strategy game inspired by X-COM with Geoscape/Basescape/Battlescape layers |
| **Why** | Demonstrate AI-assisted game development; create extensible, moddable tactical game |
| **When** | Monthly Geoscape cycles with daily Basescape management and per-mission Battlescape combat |
| **Where** | Hexagonal world map divided into provinces and regions across multiple planets |
| **Who** | Players lead covert organization through five evolutionary stages; units persist and develop |
| **How** | Resource optimization through research/manufacturing feeding into better-equipped units for combat |
| **Victory** | Open-ended progression with player-defined goals and emergent gameplay from system interaction |

---

## Navigation Quick Links

- **Complete Glossary**: See `docs/01_GLOSSARY.md`
- **System Integration**: See `docs/Integration.md`
- **API Reference**: See `wiki/API.md`
- **Development Workflow**: See `wiki/DEVELOPMENT.md`
- **Project Structure**: See `wiki/PROJECT_STRUCTURE.md`
- **FAQ**: See `wiki/FAQ.md`

---

**End of Documentation Overview**
