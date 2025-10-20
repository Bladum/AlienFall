# Quick Overview (TL;DR)

### Core Foundation
- **Turn-based strategy** inspired by X-COM; combines global strategy (Geoscape) + base management (Basescape) + tactical combat (Battlescape)
- **Time System**: Geoscape 1 turn/day; Battlescape 1 turn/10 seconds; Interception 1 turn/5 minutes; calendar: 6 days/week, 30 days/month, 360 days/year
- **Four Game Layers**: Geoscape (80Ă—40 hex global map), Basescape (5Ă—5 facility grid), Battlescape (60-105Ă—60-105 hex procedural maps), Interception (craft vs. UFO combat)
- **Core Mechanics**: Turn-based, no real-time elements; procedurally-generated missions; extensive moddability via TOML and Lua
- **Player Experience**: Sandbox gameplay with player-driven goals; emergent storytelling through faction interactions; permadeath optional difficulty

### AI Systems
- **Strategic AI (Geoscape)**: Factions (autonomous antagonists with agendas), Countries (funding/relations), Suppliers (marketplace/pricing), Mission generation (objectives, UFO placement, difficulty scaling)
- **Operational AI (Interception)**: UFO behavior system with tactical attack/flee decisions, damage calculations, outcome determination
- **Tactical AI (Battlescape)**: 4-level hierarchy (Side â†’ Team â†’ Squad â†’ Unit) with faction alignment, tactical coordination, resource allocation, and emergent behavior
- **Unit-Level AI**: Pathfinding (A* hex grid), target selection (threat assessment + priority weighting), weapon mode selection, reaction fire, evasion, suppression penalties
- **Formation & Coordination**: Wedge/Line/Column/Circle formations; overlapping fire coverage; morale management; leader bonus (+1 morale aura, auto-promote on death)
- **Behavior Modifiers**: Cautious/Normal/Aggressive postures; specialized tactics (suppression, CQB, explosives); risk tolerance and casualty thresholds

### Modding & Assets
- **Asset Types**: PNG graphics (12Ă—12 upscaled 24Ă—24), OGG music, WAV sound effects, TOML data files
- **Mod Creation**: Basic folder structure, entry point definition, asset organization, template generation; TOML data definitions for items/units/weapons
- **Mod Loading**: Load core game mods first, apply user mods in priority order, handle dependencies/conflicts, report missing dependencies
- **API Integration**: Access game systems through mod API, event hooks for behavior, safe execution sandboxing
- **Validation**: TOML syntax checking, required field validation, type validation; automated checks for common issues, warnings for deprecated features
- **Testing Framework**: Load specific mods in test environment, compare expected vs. actual outcomes, performance profiling for mod impact

### Analytics System
- **Purpose**: Track gameplay (combat, units, missions, economy, research, diplomacy) to identify balance deviations and design issues
- **Key Metrics**: Weapon DPS (<15% spread), weapon usage (>5% per weapon), unit class win rate (45-55%), difficulty targets (85%/65%/40%/15% for Rookie/Normal/Hard/Impossible), performance (60 FPS, <100ms turn calc, <3s load)
- **Auto-Balance**: Autonomously plays 100+ game years; logs all events; calculates metrics; identifies deviations; recommends config changes; re-runs to verify
- **Feedback Loop**: Balancing recommends tuning â†’ players engage â†’ analytics track metrics â†’ compare theory vs. real gameplay â†’ adjust design â†’ repeat
- **Per-Layer Scaling**: Battlescape adapts enemy difficulty per squad performance; Geoscape scales UFO distribution; Interception craft scale earlyâ†’midâ†’late game; Basescape paces research/manufacturing/salvage
- **Dashboard & Reports**: Campaign timeline visualization, faction status, metrics graphs, event feed, executive summary, recommended adjustments, raw data export

### Basescape (Base Management)
- **Core Concept**: 5Ă—5 facility grid management system with resource allocation, research, manufacturing, and unit training; monthly budget cycle with income/expenses
- **Facilities**: 12 core types (Power, Barracks, Storage, Lab, Workshop, Hospital, Academy, Garage, Hangar, Radar, Turret, Prison) with size variants (1Ă—1 to 3Ă—3)
- **Mechanics**: Adjacency bonuses for connected facilities; facility lifecycle (Operational/Construction/Damaged/Offline/Destroyed); power distribution system
- **Unit Management**: Recruitment from countries/factions/advisors; barracks capacity (8-20 units); stat progression with specialization options; health recovery and sanity tracking
- **Research & Manufacturing**: 10-30 day project timelines; dependency chains; facility multipliers; completion rewards; resource conversion systems
- **Monthly Cycle**: Income calculation, expenses, maintenance costs, advisor salaries, corruption taxes, reserve forecasting; 3-month projection system

### Battlescape (Tactical Combat)
- **Core Concept**: Hex-based tactical combat with turn-based squad-level gameplay on procedurally generated maps; permadeath optional difficulty
- **Map System**: 60-105 hex grids with procedural generation; terrain types (open/normal/rough/very rough/impassable); elevation effects; dynamic lighting (day/night/transitional)
- **Combat Mechanics**: Hex-grid movement with MP costs; LOS/cover system with partial visibility; accuracy modifiers (distance, mode, equipment, stance, environment); weapon modes (Snapshot/Aimed/Burst/Auto/Melee)
- **Unit System**: 7 stat ranges (HP/Accuracy/Reaction/Strength/Morale/Sanity/XP); promotions at 100 XP with specialization unlock; traits (Brave/Bloodthirsty/Tactical/Lucky/Fragile/Clumsy/Psychic)
- **Status Effects**: Panic (2 turns, auto-end), Berserk (3-5 turns, attack-closest), Suppression (1-2 turns, penalty), Surrender (team defeat)
- **Psionic System**: 13 abilities (Telekinesis/Psionic Damage/Blast/Teleport/Force Shield/Stun Burst/Mind Trick/Healing Wave/Fear Aura/Reflect/Clairvoyance/Possession/Telepathy) with AP/Energy costs and cooldowns

### Interception (Air Combat)
- **Core Concept**: Turn-based aerial combat system identical to Battlescape but focuses on craft vs. UFO engagement; same damage/accuracy/cover mechanics on different map scale
- **Interception Map**: 80Ă—40 hex grid representing airspace; scale 5 km per hex; craft speed 80-120 km/turn; UFO speed 40-160 km/turn depending on class
- **Craft Equipment**: Player crafts (Interceptor/Fighter/Gunship/Bomber/Stealth), Weapons (Point Defense/Main Cannon/Missile Pod/Laser Array/Plasma Cannon), Armor (Light/Medium/Heavy)
- **UFO System**: 4 UFO classes (Scout/Fighter/Harvester/Battleship) with HP/Speed/Armor/Weapons; AI behavior tree (Detectâ†’Assessâ†’Engage/Evadeâ†’Combatâ†’Reinforce/Retreat/Crash)
- **Outcomes**: Destruction (complete kill, all salvage), Crash (creates ground battle site), Escape (UFO flees, may retry later), Loss (craft destroyed, pilot becomes POW)
- **Mechanics**: Damage calculations like Battlescape, craft HP tiers, crew damage (pilot injury affects controls), interception resolution (3-7 turns typical)

### Shared Content (Items, Units, Crafts)
- **Units**: Stat ranges (6-12 for humans), unit classes (Rookie/Veteran/Elite), experience-based advancement, specialization branching, trait system
- **Crafts**: Scout/Interceptor/Transport/Heavy Fighter types with HP/Speed/Range/Crew/Cargo/Weapons/Fuel specs; Geoscape-only transport; Interception for air combat
- **Geoscape Weapons**: Cannon/Missile types for craft; Point Defense/Main Cannon/Missiles Pod/Laser Array/Plasma Cannon for base defense
- **Progression**: Craft experience, armor upgrades, weapon unlocks, pilot skill advancement; maintenance, fuel, and repair mechanics

### Politics & Diplomacy
- **Fame** (0-5000): Public visibility scaling benefits (recruitment quality, mission availability, supplier pricing); maintenance cost (0-100K/month) at high levels
- **Karma** (-1000 to +1000): Moral alignment affecting mission availability; high karma unlocks ethical missions, low karma unlocks pragmatic missions
- **Relations** (-3 to +3): Per-country/faction standing determining funding, mission generation, supplier pricing; improved by success, damaged by failures/civilian kills
- **Reputation**: Premium currency earned through missions; spent on Organization Level advancement (50-150 Rep per level) and Advisor hiring
- **Organization Levels** (1-5): Unlocks more bases/crafts/units/advisors but increases corruption tax (0% â†’ 40%); gates story progression
- **Advisors** (8 types): CTO/COO/CFO/CMO/CIO/CDO/Medical/CRO with global bonuses (research/manufacturing/anti-corruption/XP/detection/relations/sanity/recruitment) costing 25-40 Rep + 50-120K monthly

### Finance & Economics
- **Monthly Cycle**: Income from countries (funding), salvage, manufacturing sales; Expenses: bases, units, crafts, research, manufacturing, advisors, upgrades, maintenance
- **Penalties**: Corruption tax (0-30% of income by org level), Fame maintenance (10-100K/month by fame level)
- **Budget Reconciliation**: Net income/deficit calculation, reserves tracking, 3-month forecasting, deficit mode warnings
- **Corruption Tax**: Deducted by organization level; higher levels cost more to operate; CFO advisor suppresses 5%
- **Deficit Management**: Debt mode triggered when reserves <0; 5% interest per month; consequences (relations drop, advisors leave, bases close)

### Geoscape (Strategic Layer)
- **Core Concept**: Global 80Ă—40 hex map divided into provinces/regions/countries; simultaneous turn resolution with UFO/faction activity; strategic mission deployment and interception
- **Map System**: Global hex grid with province ownership, UFO detection/interception, landing zones, mission generation; day/night cycle affects global regions
- **UFO Activity**: Autonomous UFO placement, roaming, attacking missions, interception triggering; UFO classes with strategic variety
- **Missions**: Auto-generated with objective types (Eliminate/Defend/Reach Extraction/Rescue/Capture/Investigate/Secure Device/Assassinate/Survive Duration/Area Denial); stealth budget optional
- **Diplomacy**: Dynamic NPC interactions, faction agendas, political pressure, trade routes, alliances, conflicts; player can negotiate, raid, defend, research

### User Interface
- **Resolution**: 40Ă—30 grid (960Ă—720 display); 24Ă—24 pixel grid for widget snapping (12Ă—12 pixel art upscaled 2Ă—)
- **Layout**: Widget-based system with flexible positioning and scaling
- **Menu System**: Main menu (campaign/settings/credits/exit), in-game menus (base/battlescape/geoscape/interception views)
- **Information Panels**: HUD elements (status, objectives, notifications), detail panels (unit stats, facility info, research progress), log viewers
- **Input**: Mouse + keyboard controls; camera controls (pan/zoom); unit selection and action commands
- **Accessibility**: Colorblind mode, UI scaling, font size options, keyboard shortcuts, text-to-speech support (optional)

### Localization & Internationalization
- **Languages**: Support for multiple languages via localization system; user-selected language preference; translation file format (JSON/CSV)
- **Text Management**: String IDs for all UI text, dialog, and descriptions; central translation repository; fallback to English if translation missing
- **Cultural Adaptation**: Number/date/currency formatting per locale; cultural unit names and descriptions; visual asset variants per region (optional)
- **Community Translation**: Framework for community-driven translations; translator credits system

### Multiplayer System
- **Turn-Based Multiplayer**: Simultaneous turn submission; collaborative or competitive gameplay modes
- **Networking**: Client-server architecture; turn-based sync; state serialization for save/load
- **Matchmaking**: Lobby system, difficulty pairing, session management
- **Player Interaction**: Trade/diplomacy system, shared events, chat integration
- **Asynchronous Modes**: Play-by-mail style support, turn notifications, session persistence

### Cross-System Integration
- **Cascading Consequences**: Base damage affects unit recovery time; UFO crashes create ground battles; diplomatic actions affect mission generation; economic actions affect research pace
- **Feedback Loops**: Success builds momentum (higher fame, better relations); failure compounds (debt, advisor loss, relation damage); dynamic difficulty scaling
- **Layer Interactions**: Battlescape outcomes affect Geoscape relations; Geoscape decisions trigger Battlescape missions; Economy affects research and recruitment; Diplomacy enables/blocks missions
- **Emergent Storytelling**: Faction agendas create dynamic conflicts; player choices create diverging paths; long-term campaign consequences; permadeath affects strategy

### 3D Battlescape (Optional Alternative)
- **Core Concept**: First-person 2.5D tactical alternative to hex battlescape; Wolfenstein 3D-style engine; turn-based movement and combat; single-unit control focus
- **Perspective**: First-person view with 2.5D rendering; grid-based movement; smooth animation between tiles
- **Gameplay**: Move/strafe/rotate per turn; weapon selection and firing; use inventory items; interact with environment
- **Camera**: Follow unit movement, rotate for targeting, zoom for detail; minimap for tactical overview
- **Compatibility**: Shares item/weapon/unit data with hex battlescape; can switch between views; generates compatible save files; optional difficulty toggle

---

