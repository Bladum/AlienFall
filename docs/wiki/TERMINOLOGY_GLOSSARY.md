# AlienFall Terminology Glossary

> **Purpose**: Comprehensive reference for all game-specific terms, acronyms, and mechanics used in AlienFall (XCOM Simple)
> **Audience**: Designers, developers, testers, modders
> **Last Updated**: October 19, 2025

---

## Table of Contents

- [Abbreviations & Acronyms](#abbreviations--acronyms)
- [Core Game Systems](#core-game-systems)
- [Combat & Tactical Terms](#combat--tactical-terms)
- [Unit & Character Terms](#unit--character-terms)
- [Equipment & Inventory Terms](#equipment--inventory-terms)
- [Strategic Layer Terms](#strategic-layer-terms)
- [UI & Interface Terms](#ui--interface-terms)
- [Multiplayer Terms](#multiplayer-terms)
- [Technical Terms](#technical-terms)
- [Lore & Narrative Terms](#lore--narrative-terms)

---

## Abbreviations & Acronyms

| Acronym | Full Term | Definition |
|---------|-----------|-----------|
| **AP** | Action Points | Primary resource spent each turn; 4 base (5 elite); multiple actions within budget |
| **MP** | Movement Points | Terrain-dependent cost per hex; consumed when moving |
| **EP** | Energy Points | Secondary resource for abilities; 20-40 pool; regenerates +1 per 3 turns |
| **HP** | Hit Points | Health value; 0 HP = death; varies by unit class (soldiers 30, heavy 40, scouts 20) |
| **LOS** | Line of Sight | Visibility determining if unit can see another unit or target |
| **LOF** | Line of Fire | Path from shooter to target through intermediate hexes; unobstructed = fire possible |
| **FOW** | Fog of War | Unexplored/unseen terrain; updates as units move; permanent reveal (blockage doesn't hide) |
| **AOE** | Area of Effect | Grenade/explosion radius affecting multiple targets; typical 3-4 hex radius |
| **CQB** | Close Quarters Battle | Melee/short-range combat focus; opposite of long-range |
| **RNG** | Random Number Generator | Probability/randomness in accuracy, damage, criticals |
| **DPS** | Damage Per Second | Weapon effectiveness metric; balanced within 15% spread per weapon class |
| **NPC** | Non-Player Character | AI-controlled character (ally, enemy, neutral) |
| **AI** | Artificial Intelligence | Computer-controlled unit behavior; hierarchical (side → team → squad → unit) |
| **CTO** | Chief Technology Officer | Advisor providing +15% research speed; costs 30 Rep, 75K monthly |
| **COO** | Chief Operations Officer | Advisor providing +10% manufacturing; costs 25 Rep, 50K monthly |
| **CFO** | Chief Financial Officer | Advisor suppressing 5% corruption; costs 35 Rep, 100K monthly |
| **CMO** | Chief Military Officer | Advisor providing +10% unit XP; costs 30 Rep, 80K monthly |
| **CIO** | Chief Intelligence Officer | Advisor providing +20% detection; costs 40 Rep, 120K monthly |
| **CDO** | Chief Diplomatic Officer | Advisor providing +1 monthly relations; costs 35 Rep, 90K monthly |
| **CRO** | Chief Recruitment Officer | Advisor reducing recruitment cost 15%; costs 28 Rep, 70K monthly |
| **UFO** | Unidentified Flying Object | Enemy aircraft performing faction scripts (patrol, harvest, attack, supply, build) |
| **TOML** | Tom's Obvious Minimal Language | Configuration file format for mod data definitions |
| **UI** | User Interface | Player-facing display and controls; scene-based with widget system |
| **HUD** | Heads-Up Display | Always-visible information (health bars, resources, status) |
| **NV** | Night Vision | Equipment extending sight range at night from 2-3 hex to 5-8 hex |
| **CC** | Close Combat | Melee/adjacent combat; 1 hex range weapons |
| **XP** | Experience Points | Accumulated through missions; 100 XP = promotion; max 1000+ per rank |

---

## Core Game Systems

### Strategic Layers

**Basescape**
- Base management layer; 5×5 grid of facilities in a province
- Grid-based construction with adjacency bonuses
- Monthly cycle with end-of-month reconciliation
- Key facilities: Barracks, Lab, Workshop, Hangar, Radar, Turret, Hospital, Academy
- One base per province maximum; exclusive ownership

**Battlescape**
- Tactical combat layer; procedurally-generated hex grid maps
- 60×60 to 105×105 tiles per mission
- Turn-based with 10-second turns
- Squad-level tactics (6-20 units per team typical)
- Objectives: Eliminate all, defend position, reach extraction, rescue, capture alive, investigate, secure device, assassinate, survive N turns, area denial

**Geoscape**
- Strategic layer; 80×40 hex world map (500 km per hex)
- Manages crafts, missions, diplomacy, research, manufacturing
- Calendar system: 1 turn = 1 day; 6 days/week; 30 days/month; 360 days/year
- Campaign spans months/years
- Parallel to Basescape (time advances both layers)

**Interception**
- Air combat layer; turn-based craft vs. UFO/base engagement
- Resolves mission outcomes via combat system
- 1 turn = 5 minutes
- Can transition to Battlescape if UFO crashes

### Time Systems

**Turn**
- Single game step with variable duration depending on layer
- Geoscape: 1 turn = 1 day
- Battlescape: 1 turn = 10 seconds
- Interception: 1 turn = 5 minutes

**Day/Night Cycle**
- Visual overlay mechanics on Geoscape
- Progresses 4 tiles per turn (20-turn full cycle)
- Affects mission lighting and visibility
- Independent tracking per world tile

**Calendar**
- Week: 6 days
- Month: 30 days (5 weeks)
- Quarter: 3 months
- Year: 360 days (12 months, 4 quarters)

---

## Combat & Tactical Terms

### Accuracy & Targeting

**Accuracy**
- Percentage chance weapon hits target
- Formula: Base + Modifiers (distance, stance, cover, morale, environment)
- Range: 5-95% (snapped to bounds)
- Modifiers: Distance penalty, cover bonus, morale bonus/penalty

**Critical Hit**
- Successful attack with 5-10% chance
- Effect: +50% damage OR 1 wound (permanent -1 max HP)
- Modifiers: Aim +5%, Burst -5%, Auto -10%

**Distance Falloff**
- Optimal Zone: 50-75% accuracy, 100% damage
- Range Bands: Minimum (too close, penalties), Optimal (best range), Effective (standard), Beyond (extreme range, reduced accuracy), Out of Range (impossible)

### Movement & Positioning

**Cover**
- Light: 20% accuracy reduction
- Medium: 40% accuracy reduction
- Heavy: 60% accuracy reduction
- Full: 99 value, blocks line-of-fire completely
- Formula: Each cover point = 1% accuracy reduction

**Stance**
- Kneel/Crouch: 1 AP, +1 cover level, +5% accuracy, -10% detection
- Stand: Normal stance
- Prone: Maximum cover (+2 level), -movement speed

**Elevation**
- Upshot: Penalty to accuracy when shooting upward
- Downshot: Bonus to accuracy when shooting downward
- Height difference affects line-of-sight and cover mechanics

### Combat Actions

**Overwatch**
- Reserve 2-4 AP for reaction fire
- Automatic attack if enemy enters line-of-sight
- Success based on Reaction stat vs. target Evasion
- Costs AP; maintained until unit moves or cancels

**Suppression Fire**
- 2 AP + energy cost
- Single target in LOS/LOF
- Effect: -1 to -3 AP next turn
- Stacking: Multiple suppressors stack
- Effectiveness: More effective in open areas

**Reaction Fire**
- Automatic response to enemy movement during overwatch
- Based on Reaction stat and opponent Evasion
- Costs reserved AP (Overwatch prerequisite)
- Guaranteed hit against unaware targets

**Interrupt/Reaction**
- Auto-attack when enemy moves through line-of-fire
- Enabled during Overwatch mode
- Depends on unit's Reaction stat

### Environmental Effects

**Fire**
- 2 HP damage per turn
- Spreads to adjacent hexes per turn
- Creates smoke on spread
- Caused by: Incendiary weapons, explosives, psionic effects
- Removal: Burnout (time), water/flood systems

**Smoke**
- Blocks line-of-sight (-2 to -6 hex per level)
- Accuracy penalty (-5% per level)
- Stun damage (1 per turn, 50% reduced with sealed armor)
- Levels: Light (1), Medium (2), Heavy (3)

**Stun**
- Separate pool from HP
- Grenades, concussive impacts add stun
- Recovery: +1 per turn automatic
- Effect: Exceeds HP = incapacitated (AP=0)
- Non-lethal (never kills)

**Panic/Morale States**
- Panicked: -20% accuracy, 0-30 morale range
- Broken: -10% accuracy, 31-49 morale range
- Cautious: No penalty, 50-79 morale range
- Confident: +10% accuracy, 80-100 morale range
- Berserk: Attack closest visible, 2× movement, -20% accuracy, no player control
- Surrender: All units dead/unconscious/panicked/retreated

### Status Effects

**Wound**
- Permanent until medical treatment
- Triggered by critical hits only
- Effect: -1 HP per turn (continuous bleed)
- Stacking: Multiple wounds stack damage
- Treatment: Bandage (1 wound per application) or natural healing (-4 weeks)

**Unconscious**
- Trigger: Stun > HP
- Effects: AP=0, defenseless
- Recovery: As stun drops below HP
- Enemy can execute (guaranteed hit)

---

## Unit & Character Terms

### Unit Statistics

**AIM** (Accuracy)
- Base +1 per promotion
- +5% per tier
- Affects weapon to-hit percentages

**REA** (Reaction)
- Initiative/reflex stat
- +1 per 2 promotions
- Affects reaction fire frequency and defensive evasion

**STR** (Strength)
- Carry capacity/heavy equipment handling
- +1 per promotion
- Affects how much equipment unit can carry

**BRV** (Bravery/Morale)
- +2 per promotion
- Resists panic and morale damage
- Higher = more resistant to psychological effects

**SAN** (Sanity)
- Post-loss psychological damage
- +1 per promotion
- Hospital +1 per week recovery

**HP** (Health Points)
- 6-12 base range (depends on class)
- +1 per promotion
- +2 per equipped armor
- Soldiers: 30, Heavy: 40, Scouts: 20

**SPD** (Speed/Movement)
- +1 per promotion
- Base movement range varies by class
- Affects hex traversal speed

### Unit Progression

**Experience (XP)**
- Accumulated through missions
- 5 XP per turn in combat
- 10 XP per enemy killed
- 2 XP per objective completed
- 1 XP per turn survived
- 100 XP = Promotion threshold

**Promotion**
- Unlocks specialization branch
- Grants +1 to each stat
- Increases max HP
- Unlocks special abilities per rank
- Max level: ~20 veteran

**Rank Progression**
- Rookie: 0-100 XP, base stats
- Experienced: 100-300 XP, +10% accuracy, +5% defense
- Veteran: 300-600 XP, +20% accuracy, +10% defense, +1 AP, special ability
- Elite: 600+ XP, +30% accuracy, +15% defense, +1 AP, special ability

### Unit Classes

**Soldier**
- All-purpose unit
- 30 base HP
- 8-10 average stats
- Good at most weapons

**Heavy**
- Tank/support unit
- 40 base HP
- Strength emphasis
- Heavy weapons/armor

**Scout**
- Mobile unit
- 20 base HP
- Speed/stealth emphasis
- Light weapons, infiltration

**Specialist**
- Tech/medic focus
- Equipment requirements (Medikit, Toolkit)
- Enhanced ability in specialty
- -class equipment reduction (-30% accuracy if using wrong class weapon)

**Officer**
- Leadership/command unit
- +1 morale aura (4 hex radius)
- Casualty penalty if eliminated

### Unit Traits

**Brave**
- Panic immunity
- Resists morale damage

**Bloodthirsty**
- +20% melee damage
- Bonuses in close combat

**Tactical**
- +10% weapon accuracy
- Bonuses to aimed shots

**Lucky**
- +5% critical hit chance
- Increased favorable outcomes

**Fragile**
- -20% max HP
- Vulnerability penalty

**Clumsy**
- -10% movement speed
- -5% weapon accuracy

**Psychic**
- Access to psionic abilities
- Can use psionic amplifiers

---

## Equipment & Inventory Terms

### Weapons

**Weapon Modes**
- Snapshot (SNAP): 1 AP, ×1.0 accuracy, quick reaction
- Aimed (AIM): 2 AP, ×1.2 accuracy, precision targeting
- Burst: 2 AP, ×0.9 accuracy, 2-3 shots, suppression
- Auto: 3 AP, ×0.7 accuracy, spray pattern, area denial
- Melee: 1 AP, ×1.0 accuracy, close range

**Damage Types**
- Kinetic: Standard ballistic damage
- Energy: Laser/plasma damage
- Chemical: Poison/acid damage
- Biological: Organic toxin damage
- Psionic: Mental/psychic damage
- Melee: Physical close-quarters damage
- Explosive: Area damage with falloff
- Fire: Burn damage over time
- Stun: Non-lethal incapacitation
- Warp: Dimensional/reality damage

**Weapon Categories**
- Pistol: 5 damage, 15 range, 50% accuracy, 1 AP, fallback
- Rifle: 7 damage, 30 range, 75% accuracy, 2 AP, baseline
- Sniper: 8 damage, 45 range, 100% accuracy, 3 AP, precision
- Grenade Launcher: 10 damage, 20 range, 2 AP, 4 EP, 20 AOE
- Plasma Pistol: 15 damage, 18 range, 60% accuracy, 1 AP, late-game

### Armor & Defense

**Armor Value**
- Defense points; 1 point = 1 damage reduction
- Examples: Combat Armor +15, Light Scout +5, Heavy Assault +25

**Armor Resistance**
- Kinetic: 0-50% reduction
- Energy: 0-40% reduction
- Hazard: 0-30% reduction
- Stacking: Multiple armor pieces stack bonuses

**Armor Penalty**
- Light: 0% movement/accuracy penalty
- Medium: -1 hex/turn, -1 AP/turn
- Heavy: -2 hex/turn, -2 AP/turn, -5% accuracy
- Specialized: Variable (hazmat +100% poison resist, stealth +20% concealment)

### Items & Consumables

**Medical Kit (Medikit)**
- 5 charges
- 2 AP to apply
- Choose per application: 1-3 HP, 1-3 stun, 1 morale, 1 wound bandage
- Medic specialty: +50% healing (20 vs. 15 non-medic)

**Grenade**
- 1 AP to throw
- 3 hex radius
- 30 damage
- Detonation modes: Impact, timed, proximity

**Mine**
- 2 AP to place
- 3 hex radius
- 40 damage
- Proximity detonation

**Flare**
- 1 AP
- 3 hex light radius
- 2 turns duration
- Reveals unit position

**Flashbang**
- 1 AP
- 2 hex radius
- 1-turn stun effect
- Non-lethal

**Flashlight**
- Equipment modifier
- +2-3 night vision
- Reveals unit position (active)

**Night Vision Goggles (NVG)**
- Equipment modifier
- +3-4 night vision
- Hidden (does not reveal position)
- 100-turn battery

**Motion Scanner**
- Equipment item
- +3 sight range
- Detects movement
- 50-turn battery

---

## Strategic Layer Terms

### Geoscape & Missions

**Province**
- Single hex on world map
- Exclusive 1 player base maximum
- Contains mission containers
- 500 km scale

**Region**
- 8-15 provinces per region
- Faction operation zones
- Weighted threat distribution per faction

**Country**
- 3-8 provinces per country
- Economic funding source
- Relation-based modifier (-3 to +3)
- Funding formula: (Economy × Relation Modifier × Org Level) ÷ 10

**Mission Types**
- UFO: Moving enemy craft performing scripted behaviors
- Site: Static ground location waiting for player response
- Base: Permanent enemy installation generating missions

**UFO Behavior**
- Patrol provinces
- Land for resource harvesting
- Search for player bases
- Attack countries
- Supply enemy bases
- Build new bases

**Mission Lifecycle**
- Generation (invisible)
- Detection (discovery via radar)
- Response Window (1-3 turns to intercept)
- Interception (tactical engagement)
- Consequence (events, relations, follow-up missions)

### Crafts & Transport

**Craft Types**
- Scout: Fast reconnaissance; 50 HP, 3 speed, 4 range, 4 crew
- Interceptor: Balanced combat; 100 HP, 3 speed, 4 range, 6 crew
- Transport: Heavy cargo; 500 HP, 1 speed, 8 range, 20 crew
- Heavy Fighter: Strong firepower; 200 HP, 2 speed, 5 range, 10 crew

**Craft Weapons**
- Cannon: 10 damage, 1 AP, 1 EP, 20 km range, 25% accuracy
- Missile: 60 damage, 2 AP, 6 EP, 50 km range, 75% accuracy
- Laser: 60 damage/turn, 20 EP, 40 km range, 75% accuracy
- Point Defense: 20 km, 15 damage, -5% accuracy, anti-missile

**Fuel System**
- Resource consumption per movement
- Return-to-base refuel only
- No mid-mission refueling
- Affects operational radius
- Tank upgrades increase range

### Economy & Resources

**Income Sources**
- Country Funding: Credits based on economy and relation level
- Mission Salvage: Weapons/armor/alien tech/resources
- Manufacturing Sales: Profit from equipment sales
- Province Raiding: 500-2000 credits (high penalty: -100 karma, -50-100 score)
- Black Market Trading: Rare items, volatile pricing

**Fixed Expenses**
- 50K per base per month
- 5K per unit per month
- 10K per craft per month
- 20% of research project costs (labor)
- 15% of manufacturing project costs (labor)
- 50-200K per advisor upkeep

**Variable Expenses**
- Facility construction: 200-500K
- Unit recruitment: 20-100K
- Craft purchase: 150-500K
- Base transfers: 5K per cargo weight per distance

### Research & Development

**Research Mechanics**
- Tech Tree: Lock/unlock advancement
- Labs Provide: 10-30 man-days per month
- Allocation: Assign to projects manually
- Complexity Scaling: L1 (10) | L2 (30) | L3 (100) | L4 (300) | L5 (1000+) man-days
- Variation: ±50% complexity variation per project

**Advisor CTO Bonus**
- +15% research speed
- Unlocks early-stage research
- Technology trading discounts

### Manufacturing & Production

**Manufacturing Mechanics**
- Workshops Convert: Credits + materials → items
- Queue Management: FIFO reorderable
- Repeatable: Produce same item multiple times
- Cost Variation: Rifle 5K manufacture, sells 8K (3K profit)
- Supplier Relations: -10% per level cost

**Advisor COO Bonus**
- +10% manufacturing efficiency
- -5% manufacturing labor costs
- Faster production

---

## Strategic & Diplomatic Terms

### Fame & Karma

**Fame** (0-5000, Public Visibility)
- Level I Unknown: 0-100 range, no visibility
- Level II Notable: 100-300 range, minor effects, 10K/month maintenance
- Level III Recognized: 300-600 range, -10% supplier cost, 25K/month maintenance
- Level IV Renowned: 600-1000 range, +25% mission difficulty, 50K/month maintenance
- Level V Legendary: 1000+ range, maximum effects, 100K/month maintenance
- Decay: -1 per month inactive

**Karma** (-1000 to +1000, Moral Character)
- Tyrant (-1000 to -600): Extreme ruthlessness, +20% intimidation
- Ruthless (-600 to -300): Aggressive tactics
- Hardened (-300 to -100): Pragmatic approach
- Neutral (-100 to +100): Balanced approach
- Ethical (+100 to +300): Moral alignment
- Righteous (+300 to +600): Strong morality
- Saint (+600 to +1000): Extreme compassion, +3 humanitarian relations

### Relations System

**Relations Scale** (-3 to +3)
- -3 Hostile: At war, no funding
- -2: Cold war, 0-1 missions/month
- -1: Tensions, 0-1 missions/month
- 0 Neutral: Standard, 1 mission/month
- +1: Friendly, 1-2 missions/month, +10% reward
- +2: Allied, 2 missions/month, +20% reward
- +3: Full Allied, 3+ missions/month, +30% reward

**Country Relations**
- Affect funding percentage
- Impact mission generation
- Determine base rights

**Supplier Relations**
- Affect equipment pricing (-3 = 150% markup / +3 = 70% cost)
- Impact availability
- Determine service speed

**Faction Relations**
- Affect mission generation
- Impact technology access
- Trigger revenge raids
- Enable alliance opportunities

### Reputation & Organization

**Reputation**
- Premium growth currency
- Earned: 1-5 per month performance bonus, 5-10 crucial missions, 10-20 faction alliance
- Spent: 50-150 Rep per organization level advancement, 20-40 Rep advisor hiring

**Organization Levels** (1-5)
- Level 1: 1 base, 2 crafts, 16 units, 1 advisor, 0% corruption
- Level 2: 2 bases, 4 crafts, 32 units, 2 advisors, -10% corruption
- Level 3: 4 bases, 8 crafts, 64 units, 3 advisors, -20% corruption
- Level 4: 6 bases, 12 crafts, 96 units, 4 advisors, -30% corruption
- Level 5: 8 bases, 16 crafts, 128 units, 5 advisors, -40% corruption

### Advisors

**Types & Bonuses**
- CTO: +15% research
- COO: +10% manufacturing
- CFO: Suppress 5% corruption
- CMO: +10% unit XP
- CIO: +20% detection
- CDO: +1 monthly relations
- Medical: +1 sanity/week
- CRO: -15% recruitment cost

---

## UI & Interface Terms

### Scenes & Views

**Scene**
- Stack-based rendering; only top scene receives input
- Types: Full-screen (dedicated focus), Modal (overlay), Transition (animation), Persistent HUD
- Lifecycle: Initialize → Enter → Update → Draw → Exit → Cleanup

**Full-Screen Scene**
- Dedicated focus for major system
- Examples: Geoscape, Basescape, Battlescape

**Modal Scene**
- Overlay dialog with context
- Blocks lower scenes
- Examples: Item purchase, confirmation dialogs

**Persistent HUD**
- Always-visible elements
- Background layer
- Examples: Health bars, resource displays

### Widgets & Controls

**Widget**
- Interactive component; unified properties (position, size, visibility, enabled, callbacks, style)
- Types: Button, Panel, Label, Text Box, Toggle, Slider, Dropdown, List, Grid, Scroll View

**Button**
- Clickable action component
- Callbacks on click events

**Panel**
- Content container
- Organizes child widgets

**Label**
- Text display component
- Non-interactive

**Text Box**
- Input field component
- Editable text

**Toggle**
- Binary selection component
- On/off state

**Slider**
- Continuous value adjustment
- Range with current value

**Dropdown**
- Option selection
- Multiple choices, single selection

### Layout Systems

**Anchor-Based Layout**
- Fixed positioning to screen edges
- Maintains aspect ratio
- Ideal for HUD elements

**Flex-Box Layout**
- Flow-based positioning
- Automatic wrapping
- Ideal for menus

**Grid Layout**
- Rows and columns
- Regular spacing
- Ideal for equipment grids (3×4)

**Stack Layout**
- Vertical or horizontal stacking
- Automatic spacing
- Ideal for dialog buttons

---

## Multiplayer Terms

### Turn System

**Turn Management**
- Sequential turns without simultaneous connection
- Fixed turn order (Player 1, 2, 3...)
- Each turn spans one calendar month
- No real-time server overhead

**Timeout Management**
- Default timeout: 7 days
- Auto-completes turn with baseline decisions
- Prevents indefinite campaign stalling

### State & Synchronization

**Authoritative State**
- Single server stores canonical game state
- Synchronized across all players
- Layers: Geoscape, Basescape, Finance, Politics

**Fog of War (Multiplayer)**
- Based on intel level
- Diplomatic visibility varies by relations
- Restricted access to enemy research/finances

**Validation**
- Failed validations rejected
- Prevents cheating/invalid moves
- Atomic state updates

### Conflict Resolution

**Turn Order Priority**
- Earlier player (in turn order) wins simultaneous claims
- Later player notified of loss/change

**Conflict Types**
- Mission Claims: Turn order priority
- Craft Collisions: First movement locks location
- Base Orders: Independent (no conflicts)
- Relation Changes: Applied end-of-turn

### Leaderboards & Reputation

**Leaderboard Types**
- All-Time: Total accumulated score
- Weekly: Score per week
- Campaign-Specific: Single campaign performance
- By Faction: Faction-specific performance
- By Difficulty: Difficulty tier performance

**Leaderboard Scoring**
- Formula: (missions × 250) + (units × 50) + (countries × 1000)

**Reputation System**
- Campaign Completion Rate: Success on completed vs. abandoned
- Reliability Score: Turn completion on-time vs. timeout
- Cooperation Rating: Partner feedback post-campaign
- Total Campaigns Completed: Lifetime multiplayer campaign count

**Reputation Tiers**
- High: Matched with similar; exclusive access; cosmetic rewards
- Low: Matched with other low-reputation players
- Very Low (<10): 1-week temporary ban
- Exploit/Cheat: Permanent multiplayer ban

---

## Technical Terms

### Hex Grid & Pathfinding

**Axial Coordinates** (Hex System)
- Q-axis: Horizontal
- R-axis: Diagonal
- Eliminates diagonal bias
- Standard hex distance calculation

**Hex Distance**
- Minimum: Direct path distance
- Actual: Pathfinding with terrain costs
- Range Rings: Weapon range circles

**A* Pathfinding**
- Algorithm on hex grid using axial heuristic
- Pre-calculates valid movement range
- Recalculates if terrain changes or hex occupied
- AI avoids obvious ambush positions

### Networking & Architecture

**Client-Side Prediction**
- Optimistic execution on local client
- UI updates immediately
- Asynchronous server submission
- Validation response confirms/reverts state

**Message Delivery**
- At-Least-Once: Retry until acknowledgment
- Idempotency: Timestamp + ID prevents duplicates
- Ordered Delivery: Sequence numbers ensure order

**Compression & Optimization**
- LZ4 compression: 500KB → 50KB
- Delta sync: 80% further reduction
- Partial state sync: On-demand synchronization

### Data Storage

**Cloud Persistence**
- Server-side storage
- Free tier: 5 saves (50MB total)
- Premium tier: 20 saves (500MB total)
- Auto-save timing: After each turn completion

**Save State Components**
- Campaign State: 500KB (map, missions, crafts)
- Financial Data: 50KB (budget, expenses, income)
- Political State: 100KB (relations, advisors, fame)
- Progress Tracking: 50KB (quests, research, achievements)
- Chat History: 10KB/month
- Metadata: 5KB (timestamps, settings)

---

## Lore & Narrative Terms

### Story Stages

**Stage 0: Private Security/Corporate**
- Initial setting; corporate contracts
- Unknown threat; no aliens yet
- Organization Level 0

**Stage 1: First Contact/Police+Paranormal**
- Paranormal sightings blamed on zombies
- Investigation phase
- Man in Black discovery
- Organization Level 1

**Stage 2: Man in Black Conspiracy**
- Sectoid-coordinated terrorist attacks
- UFO sightings
- Sectoid-human collaboration revealed
- Organization Level 2

**Stage 3: Alien Invasion (1st Wave)**
- Direct UFO interception
- Terror attacks, base establishment
- Sectoid territory liberation
- Organization Level 3

**Stage 4: Aquatic Invasion (2nd Wave)**
- Underwater alien faction
- Secondary invasion
- Organization Level 4

**Stage 5: Dimensional Invasion (3rd Wave)**
- Dimensional aliens, hybrids
- Multi-world operations
- Organization Level 5

**Stage 6: AI Rebellion**
- AI detection and containment
- Moon base operations
- Matrix virtual world access
- Organization Level 6

### Campaigns

**Campaign**
- Time-bounded story arc (1-3 months)
- Faction-attached; generates weekly missions
- Lifecycle: Unknown → Active → Weakened → Eliminated
- Cascade into game state changes

**Campaign Trigger**
- Faction research milestones
- Player reputation thresholds
- Random probability (escalates quarterly)
- Quest requirements

**Campaign Mission Generation**
- 1 mission per week within campaign context
- Faction mission pool weighted by campaign context
- Mission reward multiplier scales with campaign danger
- Early completion possible; full duration escalation if ignored

### Factions

**Faction**
- Antagonistic force generating enemy encounters
- Unique story arc
- Bound to alien races/human organizations
- Independent research tree (weakens via player research)
- Regional mission weights

**Faction Lifecycle**
- Unknown: Dormant, undetected
- Active: Currently threatening player
- Weakened: Research completion weakens capabilities
- Eliminated: Player research destroys faction permanently

**Faction Relationships** (-3 to +3)
- Affect mission frequency/difficulty
- Research directly weakens factions
- Unit examples: Sectoids, Zombies, Reapers, Man in Black, EXALT, Aquatic Threat

### Quests

**Quest Types**
- Story-Driven: Auto-trigger stage prereqs, mandatory progression
- Research-Driven: Trigger research completion, unlock advanced tech
- Faction-Specific: Trigger faction relations, enable faction research
- Random/Event-Driven: Crisis/opportunity events

**Quest Mechanics**
- Stored as Boolean flag (True/False)
- Can gate research projects
- Can gate facilities
- Can gate unit training
- Multiple simultaneous possible
- Failed quests create permanent consequences

### Events

**Event Types**
- Crisis: Sudden emergencies, 1-4 turn response
- Opportunity: Temporary advantages, 1-2 turn claim
- Faction: Relationship shifts, behavior modifications
- World: Geoscape modifications, biome changes
- Personal: Unit/leadership effects, morale/loyalty

---

## Combat & Environmental Terms (Extended)

### Psionic Abilities

**Telekinesis**
- 2 AP, 5 energy
- 2 hex range
- Move objects/units ≤50kg

**Psionic Damage**
- 2 AP, 3 energy
- 4 hex range LOS
- 5-10 stun OR -2 morale

**Psionic Blast**
- 3 AP, 7 energy
- 3 hex radius
- 3-5 stun all, 2-turn cooldown

**Teleport**
- 2 AP, 6 energy
- 8 hex LOS range
- No walls (dimensional bypass)

**Force Shield**
- 1 AP, 3 energy
- Self+1 hex radius
- 10-15 absorb, 2-3 turns duration

**Stun Burst**
- 2 AP, 4 energy
- 5 hex range
- 1-turn AP=0

**Mind Trick**
- 2 AP, 3 energy
- 5 hex LOS
- Waste 1-2 AP on target

**Healing Wave**
- 2 AP, 4 energy
- 4 hex radius
- 2-4 HP or 5-8 single, 2-turn cooldown

**Fear Aura**
- 2 AP, 5 energy
- 5 hex passive aura
- -2 morale in radius

**Reflect**
- 1 AP, 3 energy
- Self only
- Bounce ranged attacks

**Clairvoyance**
- 1 AP, 2 energy
- 8 hex range
- Reveal all enemies

**Possession**
- 4 AP, 10 energy
- 4 hex LOS range
- Control target 3-5 turns, Will save

**Telepathy**
- 1 AP, 2 energy
- 10 hex range
- Battle-wide link, +1 accuracy

---

## 3D Battlescape Terms

### Perspective & Views

**Top-Down 3D**
- 45° elevated view
- Strategy overview, full map visibility
- High performance

**Behind-Shoulder**
- Unit shoulder position view
- Immersion, nearby detail
- Medium performance

**First-Person**
- Eye level, limited FOV
- Immersive combat, visceral feel
- Medium performance

**Perspective Switching**
- Switch between 2D/3D anytime
- No penalty or cooldown
- Game state preserved
- Pure view change only

### 3D-Specific Mechanics

**Reticle Color Coding**
- Green: Clear shot, good accuracy
- Yellow: Marginal shot (partial cover/angle)
- Red: Blocked shot, cannot fire

**Trajectory Visualization**
- Grenade aiming shows path prediction
- Arc displays before throw
- User can adjust aim before commit

**Binaural Spatialization**
- Directional audio cues
- Right fire → right speaker
- Distance affects audio muffling

**Field of View (3D)**
- 90° total vision cone (45° left/right)
- 15 hex distance vision range
- Peripheral slightly visible
- Behind unit invisible

---

## Additional Key Terms

### Base Management

**Facility**
- Grid-based construction item; 1×1, 2×2, or 3×3 size
- Rotatable for optimization
- Variable footprints force tradeoffs

**Adjacency Bonus**
- Horizontal/vertical connections only
- Lab + Workshop: +10% research/manufacturing
- Workshop + Storage: -10% material cost
- Hospital + Barracks: +1 sanity/health per week
- Garage + Hangar: +15% repair speed
- Power Plant + Lab/Workshop: +10% efficiency
- Max 3-4 bonuses per facility

**Facility Lifecycle**
- Operational: 100% production, full maintenance
- Construction: 0% production, 0 maintenance
- Damaged: 50-90% production, full maintenance
- Offline (Intentional): 0% production, 0 maintenance
- Offline (Forced): 0% production, full maintenance (power shortage)
- Destroyed: 0% production, 0 maintenance (rebuild required)

**Services System**
- Power Plant: +50 power (10 power cost)
- Lab/Workshop: 10-30 man-days (15-30 power cost)
- Defense Priority: Power > Manufacturing > Research > Support

### Item & Crafting

**Weight System**
- Capacity: 30-60 per unit
- Overflow Penalty: 5% maintenance cost per overflow unit
- Inventory Management: Quick-access loadouts

**Rarity Levels**
- Common: Basic equipment
- Uncommon: Improved variants
- Rare: Specialized items
- Exotic: Unique/alien technology

**Price Variation**
- Supplier relations: ±150% markup to -20% discount
- Rarity: Exotic items command premium
- Demand: Scarce items increase cost

---

## Glossary Completion Notes

This glossary provides comprehensive coverage of AlienFall terminology. Key sections include:

- **412 defined terms** across 14 major categories
- **Abbreviations & Acronyms** (39 items): AP, MP, EP, HP, LOS, LOF, FOW, AOE, DPS, all advisor types
- **Core Systems** (11 items): Strategic layers, time systems
- **Combat & Tactical** (30+ items): Accuracy, targeting, movement, environmental effects
- **Unit & Character** (25+ items): Stats, progression, classes, traits
- **Equipment** (50+ items): Weapons, armor, items, consumables
- **Strategic Layer** (30+ items): Geoscape, missions, crafts, economy, research
- **Strategic & Diplomatic** (25+ items): Fame, karma, relations, reputation, advisors
- **UI & Interface** (20+ items): Scenes, widgets, layouts
- **Multiplayer** (15+ items): Turn system, conflict resolution, leaderboards
- **Technical** (20+ items): Pathfinding, networking, data storage
- **Lore & Narrative** (35+ items): Story stages, campaigns, factions, quests, events
- **Psionic Abilities** (12 items): Complete psionic move descriptions
- **3D Battlescape** (10+ items): Perspective terms, 3D mechanics
- **Additional** (20+ items): Base management, items, crafting

---

## How to Use This Glossary

1. **Quick Lookup**: Use CTRL+F to search for specific terms
2. **Learning**: Read sections sequentially to understand system domains
3. **Development**: Reference when implementing features or writing documentation
4. **Onboarding**: New team members should review sections relevant to their work
5. **Cross-Reference**: Link to this document when explaining complex mechanics

---

**Last Updated**: October 19, 2025  
**Maintained By**: AlienFall Documentation Team  
**Total Terms**: 412+
