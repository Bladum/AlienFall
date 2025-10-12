# AlienFall Wiki - Game Mechanics Summary

> **Purpose**: High-level extraction of unique game mechanics from each wiki file/folder
> **Created**: 2025-10-09
> **Use Case**: Quick reference for reusing mechanics in new format

---

## Root Level Files

### README.md
- Three-layer gameplay architecture (Geoscape, Basespace, Battlescape)
- Open-ended sandbox gameplay with no fixed win conditions
- Province-based world map system
- TOML configuration + Lua scripting moddability
- Love2D + Lua technical stack

### quick-start-guide.md
- Five-layer game loop (Strategic → Operational → Tactical → Base → Economy)
- UFO detection → Interception → Crash site generation flow
- Monthly funding from nations based on performance
- Alien technology recovery and research progression

### QUICK_REFERENCE.md
- Quick lookup tables for stats, formulas, and mechanics
- Cross-referenced system values

### contributing.md
- Code standards and development practices
- AI-assisted development workflow
- Documentation standards and templates

---

## Design Folder

### game-design-document.md
- Core gameplay pillars (tension, depth, mastery, progression)
- System integration philosophy
- Deterministic design principles
- Moddability-first approach
- Data-driven systems architecture

### balancing-framework.md
- Statistical balance methodology
- Difficulty scaling curves
- Resource pacing mechanics
- Enemy strength progression

### difficulty-settings.md
- Multiple difficulty tiers
- Adaptive difficulty options
- Player-configurable challenge levels
- Ironman mode (permadeath, single save)

### victory-defeat-conditions.md
- Campaign victory conditions
- Defeat triggers (bankruptcy, base loss, territory loss)
- Sandbox mode (no fixed end)
- Optional victory conditions

### mvp-scope-definition.md
- Minimum viable product scope
- Core vs. optional features
- Development prioritization

### game-loop-overview.md
- Strategic → Tactical → Management cycle
- Feedback loop mechanics
- Layer transitions and integration

---

## Game Folder

### game/geoscape/

#### geoscape-overview.md
- Globe visualization and world map
- Province/region/territory system
- Time acceleration and pause mechanics
- Real-time event triggers
- UFO detection via radar coverage
- Detection ranges and probabilities
- False positive detection system
- Multi-base coordination

#### world-map.md
- Geographic region definition
- Territory control mechanics
- Country borders and relationships
- Province management

#### ufo-detection.md
- Radar coverage zones
- Detection probability calculations
- UFO tracking system
- Hyper-wave decoder mechanics
- Early warning systems

#### mission-generation.md
- Dynamic mission creation based on alien activity
- Mission type variety (crash sites, terror, base assault, UFO landing)
- Geographic distribution of missions
- Threat assessment and priority
- Mission timing and expiration

#### time-management.md
- 5-speed time acceleration
- Pause on event system
- Real-time vs. accelerated time
- Time-based triggers and events
- Day/night cycle tracking

#### territory-control.md
- Regional influence mechanics
- Alien expansion system
- Liberation campaigns
- Control point mechanics
- Territory benefits and penalties

---

### game/basespace/

#### base-management-overview.md
- HQ anchor system (facilities must connect to HQ)
- Facility construction queue
- Multiple base sizes (3×3, 5×5, 7×7 grids)
- Base template archetypes (Recon Post, Interception Hub, Research Outpost)
- Inter-base transfer system
- Base defense missions

#### base-layout.md
- Grid-based base construction
- Facility adjacency bonuses
- Optimal layout strategies
- Defense positioning

#### facility-system.md
- Service tag system (Research, Manufacturing, Housing, Storage, Defense)
- Facility capacity limits
- Construction time and costs
- Facility destruction and repair
- Operational vs. under-construction states

#### facility-types.md
- HQ (command center)
- Living Quarters (personnel capacity)
- Labs (research speed bonus)
- Workshops (manufacturing capacity)
- Storage (item capacity)
- Hangars (craft storage)
- Defense systems (base defense)
- Power generators
- Alien Containment

#### construction-queue.md
- Queued construction system
- Interruption mechanics
- Rush construction options
- Resource allocation during construction

#### personnel-management.md
- Scientist hiring and allocation
- Engineer hiring and allocation
- Soldier recruitment
- Personnel capacity limits
- Salaries and wage management
- Personnel transfer between bases

#### storage-management.md
- Item storage limits
- Overflow handling
- Storage prioritization
- Item transfer logistics

#### base-defense.md
- Base defense mission triggers
- Facility damage during defense
- Personnel casualties
- Defense installation effectiveness
- Enemy base assault mechanics

---

### game/battlescape/

#### battlescape-overview.md
- Turn-based tactical combat
- Action Point (AP) economy
- Time Unit (TU) integration
- Unit actions (movement, combat, special)
- Line of Sight (LOS) system
- Line of Fire (LOF) system
- Cover system (partial/full)
- Fog of war
- Suppression mechanics
- Environmental interactions

#### turn-flow.md
- Initiative-based turn order
- Player turn → Enemy turn → Civilian turn phases
- Action execution sequence
- Reaction fire triggers
- Environmental update phase
- Turn counter and round tracking
- Victory/defeat condition checks per turn

#### mission-types.md
- UFO Crash Site recovery
- UFO Landing Site assault
- Terror Mission defense
- Alien Base assault
- Base Defense
- Escort/VIP missions
- Sabotage missions
- Retaliation strikes

#### Deployment.md
- Pre-mission squad selection
- Equipment loadout management
- Deployment zone placement
- Craft-based deployment
- Entry point mechanics
- Starting formation options

#### loot-and-recovery.md
- Alien corpse recovery
- Artifact collection
- Weapon retrieval
- Intact UFO component salvage
- Live alien capture system
- Mission rewards calculation

#### victory-conditions.md
- Kill all enemies
- Secure objectives
- VIP extraction
- Survive X turns
- Destroy target objectives
- Time-limited missions

#### terrain-types.md
- Urban environments
- Rural farmland
- Forest/jungle
- Desert
- Arctic/snow
- Underwater (special missions)
- UFO interior
- Alien base interior

#### tileset-design.md
- 16×16 pixel art tile standard
- Multi-level terrain
- Destructible terrain
- Cover tile properties
- Interactive objects
- Visual consistency rules

---

### game/battle combat/

#### core-combat-math.md
- Hit chance formula: Base accuracy + range modifier + cover modifier + stance modifier
- Damage calculation: Base damage - armor reduction
- Critical hit system (chance, multiplier)
- Armor penetration formula
- RNG seeding for deterministic combat
- D100 roll system

#### accuracy-at-range.md
- Range-based accuracy degradation
- Optimal range mechanics
- Long-range penalties
- Point-blank bonuses
- Weapon-specific range curves

#### hit-chance-calculation.md
- Base accuracy stat
- Target cover bonus
- Target stance bonus (crouch, prone)
- Target size modifiers
- Environmental modifiers (darkness, smoke, fog)
- Final probability clamps (min 5%, max 95%)

#### damage-types.md
- Kinetic damage (bullets, explosives)
- Energy damage (lasers, plasma)
- Incendiary damage (fire)
- Chemical damage (acid, poison)
- Stun damage (non-lethal)
- Armor effectiveness by damage type

#### line-of-sight.md
- Raycasting LOS algorithm
- Obstacle blocking
- Partial occlusion
- Height advantage visibility
- Darkness and visibility reduction
- Spotting system (units reveal other units)

#### line-of-fire.md
- LOF distinct from LOS
- Friendly fire risk
- Obstacle trajectory blocking
- Grenade arc calculations
- Spread fire patterns

#### cover-system.md
- Full cover (+40 defense)
- Half cover (+20 defense)
- No cover (0 defense)
- Cover direction (facing matters)
- Destructible cover
- Flanking negates cover

#### Suppression.md
- Suppression accumulation per shot
- Aim penalty from suppression
- Movement penalty from suppression
- Panic risk from suppression
- Suppression decay per turn

#### environmental-effects.md
- Fire spread mechanics
- Smoke obscuration
- Explosive environment destruction
- Electrified water
- Gas/poison clouds
- Weather effects (rain, snow)

#### smoke-fire.md
- Smoke grenade mechanics
- Fire damage over time
- Fire spread to adjacent tiles
- Smoke visibility penalty
- Smoke duration and dissipation

#### cover-system.md
- Dynamic cover destruction
- Cover penetration by high-damage weapons
- Partial vs. full cover calculation
- Corner peeking mechanics

#### objects-on-battle-field.md
- Interactive doors
- Destructible walls
- Explosive barrels
- Computer terminals
- Medical kits (battlefield pickups)
- Ammo crates

#### battle-at-night-or-day.md
- Day/night mission timing
- Visibility reduction at night
- Flashlight/flare mechanics
- Night vision equipment
- Tactical advantages of darkness

#### battlefield-sight-and-sense.md
- Visual detection
- Sound-based detection
- Motion sensors
- Psionic detection
- Alien sensing abilities

#### light-vs-fog-of-war.md
- Fog of war (unexplored areas)
- Shroud (previously seen, now unseen areas)
- Light radius per unit
- Flare illumination
- Building interior darkness

---

### game/units/

#### unit-attributes.md
- Health (HP/hit points)
- Strength (carrying capacity, melee damage)
- Accuracy (ranged hit chance)
- Reactions (reaction fire speed)
- Bravery (morale, panic resistance)
- Time Units (TU) / Action Points (AP)
- Psionic Strength
- Psionic Skill
- Throwing Accuracy
- Sight Radius

#### unit-actions.md
- Move action
- Shoot action (aimed, snap, auto)
- Reload action
- Throw grenade action
- Melee attack action
- Use item action
- Open/close door action
- Pick up item action
- Overwatch action
- Hunker down action
- Psionic actions

#### unit-movement.md
- Grid-based movement
- TU cost per tile
- Diagonal movement cost
- Terrain movement modifiers
- Climbing mechanics
- Swimming mechanics
- Flying units
- Jumping/vaulting

#### unit-experience.md
- Combat experience gain
- Stat improvement from experience
- Rank progression (Rookie → Squaddie → Corporal → Sergeant → Captain → Colonel)
- Kill count tracking
- Mission participation XP

#### unit-morale.md
- Morale stat (0-100)
- Morale effects on performance
- Berserk state (uncontrolled aggression)
- Panic state (loss of control)
- Morale recovery between missions
- Leadership bonus to squad morale

#### unit-panic.md
- Panic triggers (ally death, injury, suppression)
- Panic roll mechanics
- Panic effects (flee, drop weapon, go berserk)
- Bravery stat panic resistance
- Panic duration and recovery

#### unit-injuries.md
- Wound severity (minor, moderate, critical)
- Recovery time mechanics
- Injury effects on stats
- Field medical treatment
- Hospital facility healing
- Permanent injuries (scars)

#### unit-fatigue.md
- Fatigue accumulation during mission
- Fatigue effects (reduced TU, accuracy penalty)
- Rest and recovery
- Stimulants to counter fatigue
- Mission length fatigue buildup

#### unit-status-effects.md
- Bleeding (damage over time)
- Poisoned (stat reduction)
- Stunned (immobilized)
- On fire (damage + panic)
- Blinded (accuracy penalty)
- Disoriented (TU penalty)
- Mind-controlled (AI takes control)

#### unit-psionics.md
- Psionic abilities (mind control, panic, etc.)
- Psionic strength vs. resistance
- Psionic line of sight requirement
- Psionic detection
- Psi-amp equipment
- Psionic training facilities

#### unit-reactions.md
- Reaction fire system (overwatch)
- Reaction TU reserve
- Reaction trigger conditions
- Multiple reaction shots
- Snap shot on reaction
- Reaction stat influences speed

#### unit-sanity.md
- Sanity stat (separate from morale)
- Sanity loss triggers (alien encounters, psionic attacks)
- Insanity effects
- Long-term sanity management
- Therapy and recovery

#### alien-species.md
- Sectoid (psionic, weak physical)
- Muton (strong, armored)
- Floater/Flyer (aerial mobility)
- Chryssalid (melee, zombification)
- Ethereal (high psionics)
- Sectopod (robotic, heavy weapons)
- UFO crew compositions
- Alien rank hierarchy (Soldier, Navigator, Leader, Commander)

#### player-soldiers.md
- Soldier classes (optional)
- Starting stats distribution
- Soldier names and nationalities
- Soldier portraits
- Soldier biography
- Permadeath mechanics

#### civilian-types.md
- Civilian AI behavior (flee, hide)
- Civilian casualties (score penalties)
- Civilian rescue objectives
- Civilian panic mechanics

#### robot-mechanical-units.md
- Player-controlled robots/drones
- Robot stats (no morale/panic)
- Robot repair vs. healing
- Expendable unit mechanics

#### unit-equipment.md
- Primary weapon slot
- Secondary weapon slot
- Armor slot
- Grenade slots
- Utility item slots
- Ammunition management
- Weight and encumbrance

#### Salaries.md
- Soldier monthly pay
- Scientist monthly pay
- Engineer monthly pay
- Pilot monthly pay
- Salary scaling by rank/experience
- Salary as monthly expense

---

### game/items/

#### Weapons.md
- Ballistic weapons (pistol, rifle, shotgun, sniper rifle, machine gun)
- Energy weapons (laser, plasma, fusion)
- Explosive weapons (grenade launcher, rocket launcher)
- Melee weapons (knife, stun rod)
- Alien weapons (plasma rifle, blaster launcher)
- Weapon stats (damage, accuracy, range, TU cost, ammo)
- Weapon tiers (conventional, advanced, alien, hybrid)

#### Armor.md
- Personal armor (standard, powered, flying)
- Armor value (damage reduction)
- Armor coverage
- Armor weight (encumbrance)
- Special armor properties (fire resistance, psionic shielding)
- Armor tiers (basic, carapace, titan, psionic)

#### Equipment.md
- Medkit (heal wounds)
- Motion scanner (detect movement)
- Proximity grenade (trap)
- Flare (illuminate area)
- Smoke grenade (obscure vision)
- Stun grenade (incapacitate)
- Mind shield (psionic defense)
- Grappling hook (vertical movement)

#### Consumables.md
- Ammunition types
- Grenade types
- Medkit uses
- Stimulants
- Field rations (for extended missions)

#### craft-components.md
- Craft engines
- Craft weapons
- Craft armor plating
- Craft electronics
- UFO components (loot for research)

---

### game/crafts/

#### craft-types.md
- Interceptor (fast, light weapons)
- Fighter (balanced)
- Transport (soldier deployment, slow)
- Heavy Interceptor (slow, heavy weapons)
- Specialized craft (stealth, recon)
- UFO types (Scout, Fighter, Harvester, Battleship)

#### craft-stats.md
- Speed (pursuit ability)
- Armor (damage resistance)
- Fuel capacity (range limit)
- Weapon hardpoints
- Soldier capacity (for transports)

#### craft-weapons.md
- Cannon (basic)
- Missile (high damage, limited ammo)
- Laser cannon (advanced)
- Plasma beam (alien tech)
- Fusion ball (end-game)
- Weapon range, damage, accuracy

#### craft-equipment.md
- Targeting computer (accuracy bonus)
- Afterburners (speed boost)
- Extra fuel tanks (extended range)
- Countermeasures (dodge bonus)

#### craft-movement.md
- Craft speed on geoscape
- Fuel consumption rate
- Return to base mechanics
- Out-of-fuel emergency landing

#### craft-damage-and-repair.md
- Craft HP system
- Critical damage (destroyed in combat)
- Repair time mechanics
- Repair costs (engineers + materials)
- Pilot survival chance

#### craft-combat.md
- Auto-resolve air combat
- Engagement range
- Attack rolls and damage
- Dodge mechanics
- Disengagement rules

---

### game/interception/

#### interception-system.md
- Scramble launch procedures
- Pursuit mechanics (speed chase)
- Engagement initiation
- Auto-resolve combat
- Crash site generation on UFO destruction
- UFO landing if not intercepted
- Multi-craft interception (coordinated attacks)
- Wing formation bonuses

---

### game/economy/

#### economy-overview.md
- Budget system (monthly income/expenses)
- Funding from nations (score-based)
- Debt accumulation and interest
- Salaries and wages
- Equipment pricing
- Black market trading

#### research-system.md
- Research project queue
- Scientist allocation
- Research time calculation
- Tech tree dependencies
- Research prerequisites
- Breakthrough discoveries
- Research item requirements (alien artifacts, corpses, live specimens)

#### manufacturing-system.md
- Manufacturing queue
- Engineer allocation
- Production time calculation
- Material costs
- Bulk production discounts
- Item crafting

#### budget-system.md
- Monthly income sources
- Monthly expense categories
- Budget surplus/deficit
- Financial planning tools
- Budget alerts

#### funding-system.md
- Nation funding council
- Monthly funding allocation per nation
- Score impact on funding
- Funding increase/decrease
- Nation withdrawal (zero funding)
- Regional funding zones

#### Debt.md
- Debt accumulation when budget negative
- Interest rate on debt
- Debt repayment mechanics
- Bankruptcy game over condition
- Emergency loans

#### Pricing.md
- Base item prices
- Dynamic pricing (supply/demand)
- Sell prices vs. buy prices
- Alien artifact values
- Elerium pricing

#### black-market.md
- Illegal item trading
- Black market access conditions
- Risk/reward mechanics
- Contraband items
- Price fluctuations

#### resource-trading.md
- Inter-base item transfer
- External market trading
- Resource conversion
- Trade routes

---

### game/organization/

#### Company.md
- Organization name and branding
- Company reputation
- Company hierarchy
- Multinational coordination

#### Reputation.md
- Nation reputation per country
- Global reputation score
- Reputation effects on funding
- Reputation gain/loss triggers

#### Score.md
- Monthly score calculation
- Mission success/failure scores
- UFO destruction bonuses
- Terror mission penalties
- Civilian casualties penalties
- Global score ranking

#### Fame.md
- Public awareness of organization
- Fame benefits (recruitment, funding)
- Fame penalties (alien targeting)

#### Karma.md
- Long-term consequence system
- Ethical choices tracking
- Karma effects on events
- Hidden karma score

#### Policies.md
- Strategic policy choices
- Policy benefits and drawbacks
- Policy unlock conditions
- Policy conflicts

---

### game/lore/

#### lore-and-setting.md
- Alien invasion scenario
- Earth defense organization origin
- Alien motivations
- Technology background
- Timeline of invasion

#### campaign-structure.md
- Campaign phases (Early, Mid, Late game)
- Mission sequence generation
- Difficulty scaling over time
- Alien tech progression
- Research-gated progression
- Narrative arcs
- Victory/defeat triggers

#### events.md
- Story events (triggered by progress)
- Random events
- Calendar-based events
- Consequence events (from player actions)
- Event choices and branching

#### factions.md
- Alien faction types
- Human faction relationships
- Faction-specific units and tech
- Faction diplomacy (if applicable)
- Faction conflicts

#### missions.md
- Mission scripting system
- Scripted narrative missions
- Mission objectives beyond combat
- Character-driven missions

#### quests.md
- Side quest system
- Quest chains
- Optional objectives
- Quest rewards
- Quest tracking

#### ufopedia.md
- In-game encyclopedia
- Research unlocks entries
- Alien species entries
- Technology descriptions
- Story lore entries

#### alien-artifacts.md
- Unique alien items
- Artifact research requirements
- Artifact-based tech unlocks
- Artifact narrative significance

---

### game/system/

#### core-action-point-system.md
- AP pool per unit per turn
- Action AP costs
- AP reservation for reactions
- AP scaling with stats
- AP recovery per turn

#### core-time-units.md
- TU system (alternative to AP)
- TU granularity (0-100 scale)
- TU costs for actions
- TU snapshot mechanic
- TU vs. AP system differences

#### core-energy-pool-system.md
- Energy as separate resource from AP
- Energy regeneration mechanics
- Energy-based abilities
- Energy capacity scaling

#### core-capacity-systems.md
- Storage capacity limits
- Personnel capacity limits
- Craft capacity limits
- Capacity overflow handling
- Capacity expansion mechanics

#### core-save-system.md
- Save slots (multiple campaigns)
- Autosave mechanics
- Ironman mode (single save, no reloads)
- Save file integrity
- Cross-platform saves

#### core-resource-management.md
- Money tracking
- Material inventory
- Personnel roster
- Craft roster
- Resource allocation priorities

#### core-turn-system.md
- Turn order determination
- Initiative system
- Player turn → AI turn phases
- Turn counter
- Round progression
- Victory/defeat checks per turn

---

### game/battle generator/

#### map-generator-overview.md
- Block-based procedural generation
- Deterministic seeded generation
- Tileset system
- Map block assembly
- Map prefab system
- Map script rules

#### battle-grid.md
- Grid dimensions (20×20, 40×40, 60×60)
- Tile coordinates (X, Y, Z for multi-level)
- Grid traversal algorithms

#### battle-tile.md
- Tile properties (passable, cover, destructible)
- Tile terrain type
- Tile elevation
- Tile special features

#### map-block.md
- Block definition (10×10 tile segments)
- Block categories (entry, corridor, room, objective)
- Block rotation and mirroring
- Block connection points

#### map-prefabs.md
- Complete pre-built maps
- Mission-specific prefabs
- Prefab modification rules
- Prefab selection logic

#### map-script.md
- Generation rule scripts
- Procedural algorithms
- Environmental condition rules
- Mission-specific generation logic

#### battlefield-generation.md
- Layout phase
- Block assembly phase
- Terrain decoration phase
- Object placement phase
- Validation phase

---

### game/ai/

#### ai-overview.md
- Utility-based decision framework
- AI personality system (aggressive, defensive, tactical)
- Threat assessment
- Group coordination
- Deterministic AI (seeded for reproducibility)

#### alien-strategy.md
- Alien strategic objectives
- Campaign orchestration
- Resource allocation AI
- Adaptive difficulty

#### battlescape-ai.md
- Tactical combat decision-making
- Target prioritization
- Cover usage AI
- Flanking tactics AI
- Retreat mechanics

#### geoscape-ai.md
- UFO mission generation AI
- Alien base construction AI
- Retaliation strike AI
- Strategic target selection

#### movement-ai.md
- Pathfinding (A* algorithm)
- Movement cost calculation
- Obstacle avoidance
- Formation movement

#### map-exploration.md
- Exploration AI for fog of war
- Scouting behavior
- Room clearing tactics

#### Behaviors.md
- Behavior tree system
- State machine transitions
- Aggression levels
- Fear/retreat behaviors

#### faction-behavior.md
- Faction-specific AI tactics
- Faction goals and priorities
- Inter-faction AI interactions

#### battle-team-level-ai.md
- Squad-level coordination
- Squad formations
- Combined arms tactics
- Support unit AI

#### map-ai-nodes.md
- AI navigation hints
- Cover node marking
- Objective markers for AI
- Patrol route nodes

---

### game/user_interface/

#### ui-design-guidelines.md
- 16×16 pixel art UI standard
- Color palette consistency
- Accessibility features
- Responsive layout

#### geoscape-ui.md
- World map interface
- Time controls
- Base selection
- UFO tracking display
- Interception controls

#### basescape-ui.md
- Base layout view
- Facility management UI
- Personnel roster
- Research/manufacturing queues
- Storage inventory

#### battlescape-ui.md
- Tactical map view
- Unit action menu
- Health/TU display
- Turn indicator
- Overwatch mode indicator
- Line of fire preview

#### menus-and-navigation.md
- Main menu
- Options menu
- Load/save menu
- Navigation between layers

#### Notifications.md
- Event notifications
- Mission alerts
- Research complete notifications
- Manufacturing complete notifications
- Base attack warnings

#### Tooltips.md
- Context-sensitive tooltips
- Stat explanations
- Ability descriptions
- Item info popups

#### Accessibility.md
- Colorblind modes
- Text size options
- Control remapping
- Audio cues

#### widgets/
##### widget-system.md
- Custom widget architecture
- Widget event handling
- Widget rendering pipeline

##### widget-geoscape-widgets.md
- Globe widget
- Radar coverage widget
- Craft status widget

##### widget-basescape-widgets.md
- Base grid widget
- Facility widget
- Personnel list widget

##### widget-battlescape-widgets.md
- Tactical grid widget
- Unit portrait widget
- Action menu widget

---

## Development Folder

### development/readme.md
- Architecture overview
- Module organization
- Code standards
- Best practices

### architecture-component-system.md
- Entity-component architecture
- Component definitions
- System processing

### architecture-event-system.md
- Event bus architecture
- Event subscription
- Event publishing
- Event priority

### architecture-data-flow.md
- Data flow diagrams
- State management
- Data synchronization

### state-management.md
- Game state architecture
- State transitions
- State serialization

### love2d-integration.md
- Love2D framework integration
- Callback structure
- Resource loading
- Graphics rendering

### audio-system.md
- Sound effect management
- Music playback
- Audio mixing
- 3D spatial audio

### rendering-system.md
- Rendering pipeline
- Layer rendering
- Sprite batching
- Camera system

### input-system.md
- Keyboard input handling
- Mouse input handling
- Controller support
- Input mapping

### file-system.md
- File I/O operations
- Save directory management
- Asset loading
- Mod file loading

### console-commands.md
- Debug console
- Cheat commands
- Testing commands
- Performance profiling commands

### debug-tools.md
- Debug overlays
- Performance monitoring
- Memory profiling
- Log viewing

### data-structures.md
- Core data structures
- Table schemas
- Optimization patterns

### Serialization.md
- Save/load serialization
- JSON/TOML serialization
- Version compatibility

### toml-format.md
- TOML configuration format
- Data-driven design
- Mod configuration

---

## Modding Folder

### modding-overview.md
- Mod system architecture
- Mod loading order
- Mod compatibility

### mod-structure.md
- Mod folder structure
- Required mod files
- Mod metadata

### mod-api-reference.md
- Lua scripting API
- Hook system
- Event hooks
- Function overrides

### lua-scripting.md
- Lua scripting basics
- Custom scripts
- Script execution context

### toml-configuration.md
- TOML data definition
- Unit definition
- Weapon definition
- Mission definition

### mod-dependencies.md
- Mod dependency declaration
- Load order management
- Conflict resolution

### mod-validation.md
- Mod validation tools
- Error checking
- Compatibility testing

### content-generator-tools.md
- Random weapon generator
- Random unit generator
- Mission generator tool

### generators/
#### generator-campaign-generator.md
- Campaign creation tool
- Event sequencing
- Mission pool generation

#### generator-craft-class-generator.md
- Craft stat generation
- Balanced craft creation

#### generator-event-generator.md
- Event creation tool
- Trigger condition setup

#### generator-facility-generator.md
- Custom facility generation
- Facility balance testing

---

## Tutorials Folder

### tutorial-adding-a-weapon.md
- Step-by-step weapon creation
- TOML weapon definition
- Sprite integration
- Balance testing

### tutorial-creating-a-mission-type.md
- Custom mission type creation
- Objective scripting
- Victory condition definition
- Map requirements

### tutorial-creating-a-mod.md
- Mod setup guide
- File structure creation
- Testing workflow
- Distribution

### tutorial-custom-ai-behavior.md
- Custom AI behavior creation
- Behavior tree editing
- AI personality definition
- Testing AI

### code-examples.md
- Lua code snippets
- Common patterns
- Example implementations

---

## Meta Folder (Documentation Management)

### documentation-standards.md
- Documentation format
- Writing style guide
- Markdown standards
- Frontmatter requirements

### frontmatter-template.md
- YAML frontmatter structure
- Required fields
- Metadata tags

### topic-clusters.md
- Documentation organization
- Topic grouping
- Cross-references

### cross-reference-index.md
- Link index
- Related topics
- Navigation paths

### template-library.md
- Document templates
- Reusable sections
- Boilerplate content

---

## Unique Game Mechanics Summary (Consolidated)

### Strategic Layer
- **Province-based territory control** (regions subdivided into provinces)
- **Multi-base coordination** with specialized base roles
- **Dynamic UFO behavior** with landing, escaping, and patrol patterns
- **Adaptive alien AI** that responds to player strategy
- **Five-speed time acceleration** with event-triggered pausing

### Tactical Layer
- **Hybrid AP/TU system** (Action Points + Time Units for precision)
- **Reaction fire reservation** (reserve AP for overwatch)
- **Suppression accumulation** (multiple hits increase suppression)
- **Destructible terrain** affecting cover and tactics
- **Multi-level maps** with Z-axis navigation
- **Light vs. Fog of War** distinction (explored vs. visible)
- **Panic and morale system** with berserk/flee outcomes
- **Unit fatigue** accumulating during long missions
- **Sanity system** (separate from morale, long-term effects)
- **Psionic combat** (mind control, panic induction)

### Economy Layer
- **Score-based funding** (nations adjust funding monthly based on performance)
- **Debt and interest** mechanics (can go into debt, accrue interest)
- **Black market trading** (illegal but profitable)
- **Bankruptcy game over** condition
- **Resource trading** between bases and external markets

### Research & Tech
- **Research-gated progression** (tech tree unlocks new capabilities)
- **Item-based research** (requires alien corpses, artifacts, live specimens)
- **Manufacturing queue** with bulk production discounts
- **Engineer and scientist allocation** (limited personnel resource)

### Base Management
- **HQ anchor system** (all facilities must connect to HQ)
- **Service tag system** (facilities provide specific services)
- **Base defense missions** (aliens can assault your bases)
- **Base template archetypes** (specialized base roles)
- **Variable base sizes** (3×3, 5×5, 7×7 grids)

### AI & Enemies
- **Utility-based AI** with personality traits
- **Deterministic AI** (seeded for save/load consistency)
- **Strategic AI campaign orchestration** (aliens plan long-term)
- **Alien rank hierarchy** (Soldier, Navigator, Leader, Commander)
- **Adaptive difficulty** scaling

### Progression & Campaign
- **Open-ended sandbox** (no mandatory victory condition)
- **Permadeath mechanics** (soldiers, pilots, bases)
- **Campaign phases** (Early, Mid, Late game with different challenges)
- **Event system** (story events, random events, consequence events)
- **Faction system** with relationships and conflicts

### Unique Innovations
- **Dual AP/TU system** (strategy + precision)
- **Sanity separate from morale** (long-term psychological effects)
- **Province-based territory** (more granular than regions)
- **HQ anchor base construction** (facilities must connect)
- **Score-funding-debt triangle** (economic pressure and recovery)
- **Suppression accumulation** (stacking effect from multiple shots)
- **Light vs. Fog distinction** (explored areas vs. currently visible)
- **Adaptive alien AI** that learns from player tactics

---

## End of Summary

This document provides a high-level extraction of unique game mechanics across all wiki files. Use this as a reference when adapting these mechanics to new formats or when designing similar game systems.
