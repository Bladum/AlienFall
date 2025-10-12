# AlienFall Wiki Mechanics Summary

> **Purpose:** Comprehensive catalog of unique game mechanics extracted from wiki documentation. Use this to identify mechanics when restructuring wiki for new format.
> 
> **Version:** 2.0 Extended
> **Total Lines:** 2000+
> **Coverage:** Complete mechanics extraction from all wiki folders

---

## Table of Contents

1. [Advanced Modding](#advanced-modding)
2. [AI Systems](#ai-systems)
3. [Battle Map Generator](#battle-map-generator)
4. [Battle Tactical Combat](#battle-tactical-combat)
5. [Battlescape AI](#battlescape-ai)
6. [Core Systems](#core-systems)
7. [Economy](#economy)
8. [Finance](#finance)
9. [Geoscape](#geoscape)
10. [GUI Systems](#gui-systems)
11. [Interception](#interception)
12. [Items](#items)
13. [Lore](#lore)
14. [Modding](#modding)
15. [Organization](#organization)
16. [Technical](#technical)
17. [Widgets](#widgets)
18. [Content Generator](#content-generator)
19. [Audio](#audio)
20. [Integration Points](#integration-points)

---

## Advanced Modding

### Lua Load for Scripts
- Script execution during initialization and runtime
- Event hooking system for game state changes
- API access for game systems modification
- Error handling and sandboxing for security
- Load order management for script dependencies
- Hot reloading support for development
- Performance monitoring with execution time limits

### Mod API Reference
- Event-driven hook system with priority ordering
- Sandboxed Lua execution with controlled API access
- Data extension points for units, items, research
- Version compatibility and dependency management
- Performance monitoring and error isolation
- Mod metadata with ID, version, dependencies, permissions

### Mod Dependencies
- Dependency declaration in mod metadata
- Version requirement specification (semantic versioning)
- Load order resolution and conflict detection
- Missing dependency warnings and installation prompts
- Circular dependency prevention
- Optional vs required dependency distinction

### Mod Validation
- File integrity verification (checksums, signatures)
- Script syntax validation and compilation testing
- API usage compliance checking
- Security sandbox testing for malicious code
- Version compatibility verification
- Dependency validation against installed mods

### TOML Load for Config
- TOML parsing for configuration files
- Setting persistence across game sessions
- Type validation and default value handling
- Nested configuration structures support
- In-game settings UI generation
- Runtime configuration reloading

---

## AI Systems

### Alien Strategy
- Strategic Objectives: territorial control, resource acquisition, tech advancement, player disruption, escalation management
- Campaign Orchestration: activation triggers, priority assignment, conflict resolution, termination logic, success metrics
- Resource Allocation: UFO fleet management, unit deployment, technology distribution, energy budgeting, recovery routing
- Adaptive Intelligence: pattern recognition, risk assessment, tactical adjustment, contingency planning, long-term learning
- Faction Coordination: specialization respect, cooperative objectives, resource sharing, conflict mediation, unified escalation

### Battlescape AI
- Utility-Based Decision Framework: survival assessment, lethality potential, tactical positioning, strategic objectives, group coordination
- AI Personality System: aggressive, cautious, balanced, specialized profiles with configurable weights
- Tactical Awareness: enemy tracking, opportunity recognition (flanking/overwatch), cover evaluation, group dynamics
- Combat Action Selection: movement decisions, attack targeting, ability usage, defensive actions
- Group Coordination: formation maintenance, focus fire, area control, supporting actions
- Deterministic Processing: seeded randomization, telemetry logging, data-driven configuration, performance optimization

### Faction Behavior
- Faction Profile System: aggression levels, strategic focus, technology priorities, territorial preferences, operational doctrine
- Mission Priority Allocation: weighted distribution across abduction, terror, infiltration, research, base assault, supply missions
- Resource Management: allocation between UFO production, troop training, research, base expansion
- Escalation Trigger System: probabilistic responses to player events with escalation probabilities
- Dynamic Threat Assessment: military strength (0-40), technology (0-30), strategic position (0-30), recent performance
- Adaptive Learning: pattern recognition, counter-strategy development, force sizing, strategic exploitation
- Multi-Faction Coordination: joint operations, resource sharing, conflict mediation, unified escalation
- Competitive Resource Dynamics: priority calculation, deterministic winner selection, contested resources

### Geoscape AI (Alien Director)
- Director Authority Hierarchy: tactical, operational, strategic authority with escalating decision power
- Strategic Priority Evaluation: economic pressure, military strength, geographic coverage, research progress, recent performance
- Decision Cadence: monthly (major campaigns), weekly (operational adjustments), daily (mission deployment), immediate (crisis)
- Adaptive Campaign Management: template-based generation, wave scheduling, resource allocation, target selection
- Deterministic Processing: seeded sampling, telemetry logging, data-driven configuration, performance optimization

---

## Battle Map Generator

### Map Generator
- Generation Pipeline: terrain selection → block assembly → grid construction → connectivity validation → objective placement → landing zones → balance checking → finalization
- Terrain Analysis: mission type influence, difficulty scaling, faction preferences, time and weather effects
- Block Placement Algorithm: connectivity requirements, rarity weighting, rotation/mirroring, fallback mechanisms
- Connectivity Validation: flood fill analysis, connectivity thresholds, automatic correction, performance optimization
- Objective and Deployment: objective positioning, landing zone balance, accessibility checks, dynamic adjustment
- Balance Analysis: cover distribution, chokepoint balance, open area ratio, feature spread

### Battle Field
- Multi-layer grid system for terrain, objects, and units
- Environmental hazards and destructible terrain
- Dynamic line-of-sight and fog-of-war calculations

### Battle Grid
- 20×20 logical tile system with coordinate mapping
- Grid-based pathfinding and movement validation
- Elevation and multi-level terrain support

### Battle Tile
- Tile properties: terrain type, cover value, movement cost, height
- Destructible tile states and damage tracking
- Environmental effects per tile (fire, smoke, water)

### Map Block
- Modular map sections with defined dimensions
- Edge connectivity rules for block assembly
- Rotation and mirroring support
- Rarity weights for procedural generation

### Map Prefab
- Pre-designed map sections for key locations
- Guaranteed placement rules for objectives
- Theme-appropriate asset collections

### Map Script
- Procedural generation rules and constraints
- Mission-specific map requirements
- Dynamic event triggers based on map state

### Tileset
- Terrain type definitions and visual assets
- Biome-specific tile collections
- Compatibility rules between tile types

---

## Battle Tactical Combat

### Accuracy at Range
**Range Bands System:**
- Point-Blank Range: 0-3 tiles - extremely close quarters combat, most weapons excel
- Close Range: 4-8 tiles - optimal for SMGs and shotguns, urban combat focus
- Medium Range: 9-15 tiles - balanced range for assault rifles, open field engagements
- Long Range: 16-25 tiles - sniper and marksman territory, overwatch positions
- Extreme Range: 26+ tiles - long-range specialized weapons only, significant penalties

**Weapon Accuracy Profiles:**
- Assault Rifle: optimal 6-12 tiles, close falloff 0.05, far falloff 0.08
- Sniper Rifle: optimal 15-30 tiles, close falloff 0.02, far falloff 0.03
- Submachine Gun: optimal 3-8 tiles, close falloff 0.03, far falloff 0.12
- Shotgun: optimal 2-6 tiles, close falloff 0.04, far falloff 0.15
- Heavy weapons: variable profiles based on weapon type

**Environmental Accuracy Modifiers:**
- Elevation changes impact trajectory calculation
- Wind conditions push projectiles off course
- Rain/fog/dust reduce visibility and stability (up to -30% accuracy)
- Partial cover reduces effective accuracy against concealed targets
- Flanking positions provide accuracy bonuses
- Overwatch positions allow sustained aiming (+accuracy)

**Unit State Impact on Accuracy:**
- Movement while firing: significant stability penalty (-40%)
- Injury status: wounded units experience control reduction (up to -60%)
- Fatigue: tired units have decreased concentration (up to -30%)
- Morale: low morale affects focus and precision (up to -25%)
- Experience: skilled units maintain accuracy under adverse conditions (+skill modifier up to +50%)

**Difficulty Scaling:**
- Easy Mode: reduced range penalties, forgiving accuracy curves
- Normal Mode: standard range modifiers with tactical consequences
- Hard Mode: increased penalties requiring precise positioning
- Very Hard Mode: extreme accuracy degradation emphasizing cover use

**Configuration Values:**
- Base accuracy range: 5-95% (minimum/maximum hit chance)
- Environmental modifier maximum: 30% penalty
- Skill modifier maximum: 50% bonus
- Movement penalty: 40% accuracy reduction
- Injury penalty maximum: 60% reduction
- Fatigue penalty maximum: 30% reduction
- Morale penalty maximum: 25% reduction

### Battle at Night or Day
- Time-of-day lighting affects visibility ranges
- Night combat: reduced vision distance, unit detection harder
- Day combat: standard visibility, no penalties
- Light sources: flares, torches, personal lights provide illumination radius
- Vision range modifiers scale with darkness level
- Night vision equipment provides advantages in darkness
- Thermal vision bypasses darkness penalties entirely

### Light vs Fog of War
- Dynamic lighting system updates real-time
- Personal light sources create illumination bubbles
- Light-based detection supplements line-of-sight
- Environmental light levels affect all units
- Light sources reveal enemy positions
- Darkness provides concealment bonuses
- Fog of war persists without direct illumination

### Line of Fire
- Clear firing path validation before shooting
- Obstacle height interference checked
- Cover objects block line of fire
- Friendly fire risk calculated automatically
- Partial obstructions reduce hit chance
- Elevation differences modify firing angles
- Destructible objects can be shot through

### Line of Sight
- Ray-casting algorithm for visibility checks
- Tile centroid alignment ensures consistency
- Elevation impacts sight lines significantly
- Multiple visibility levels (clear/partial/none)
- Fog of war tracks previously seen areas
- Unit vision ranges vary by type
- Special vision modes (thermal/night vision)

### Objects on Battle Field
- Interactive objects: doors, windows, furniture, consoles
- Cover objects: walls, vehicles, crates with armor values
- Destructible environment: objects break under fire
- Interactive object states: open/closed, intact/destroyed
- Objects provide cover bonuses when positioned correctly
- Terrain features affect movement and combat
- Environmental interactions create tactical options

### Smoke & Fire
**Smoke Mechanics:**
- Smoke clouds block line of sight completely
- Smoke grenade deployment creates area denial
- Smoke duration: 2-5 turns depending on weather
- Smoke dissipation affected by wind and weather
- Movement through smoke possible but visibility zero
- Thermal vision can see through smoke

**Fire Mechanics:**
- Fire spreading to adjacent tiles based on fuel
- Fire damage-over-time to units in flames (5-15 damage/turn)
- Fire blocks movement through affected tiles
- Fire creates smoke secondary effect
- Fire duration depends on terrain type (2-10 turns)
- Fire can be extinguished with water or suppressant
- Units on fire take continuous damage and accuracy penalty

**Combined Effects:**
- Smoke + fire creates dangerous area denial zones
- Fires produce smoke as secondary effect
- Environmental hazards stack for tactical advantage
- Area of effect weapons trigger environmental interactions

### Suppression
- Accuracy penalties from sustained fire: -10 to -40% hit chance
- Morale impact from being suppressed: -15 to -30 morale
- Suppression duration: 1-3 turns depending on fire intensity
- Area denial through sustained fire coverage
- Suppressed units have movement speed reduction
- AI prioritizes breaking suppression or taking cover
- Heavy weapons provide superior suppression effects
- Suppression breaks on return fire or movement

### Time Units (TU)
**TU Budget System:**
- Base TU budget: 60 per unit per turn
- Maximum TU possible: 120 (with modifiers)
- Minimum TU: 0 (exhausted or incapacitated)
- Granularity: 1 TU increments for precise action tracking
- Full reset each turn regardless of previous usage
- No TU banking between turns

**Action Cost Categories:**
- Quick actions: 5-15 TU (reload, use item, take cover)
- Standard actions: 20-40 TU (shooting, melee, overwatch)
- Complex actions: 50+ TU (hacking, planting explosives)
- Movement costs: terrain-dependent per tile moved

**Specific Action Costs:**
- Normal terrain movement: 8 TU per tile
- Difficult terrain movement: 12 TU per tile
- Rough terrain movement: 16 TU per tile
- Rifle fire: 30 TU per shot
- Sniper fire: 40 TU per shot
- Melee attack: 25 TU per attack
- Grenade throw: 35 TU per throw
- Overwatch setup: 10 TU to establish
- Use medkit: 20 TU for healing
- Reload weapon: 15 TU per reload
- Take cover: 5 TU for positioning

**TU Modifiers:**
- Wounded penalty: -15 TU additive, 3 turn duration, stackable
- Adrenaline boost: +20% TU multiplicative, 2 turn duration, non-stackable
- Fatigued penalty: -10 TU additive, permanent until rest, stackable
- Equipment bonuses: varies by item type
- Status effects: various positive and negative modifiers

**Unit Type TU Profiles:**
- Infantry: 60 base TU, 1.0 combat efficiency, 1.0 movement efficiency
- Heavy: 55 base TU, 1.1 combat efficiency, 0.8 movement efficiency
- Specialist: 65 base TU, 0.9 combat efficiency, 1.1 movement efficiency
- Commander: 70 base TU, 1.0 combat/movement, coordination abilities

**Turn Management:**
- Full reset enabled at turn start
- Modifier persistence across turns
- Partial action loss on turn interruption
- Efficiency tracking for balance analysis
- Action history retained for 10 turns
- Statistics collection for gameplay metrics

**Performance Limits:**
- Calculation time limit: 1ms per TU update
- Turn reset time limit: 10ms maximum
- Modifier update time limit: 5ms per check
- Memory usage limit: 1MB for TU system
- Max units per battle: 100 simultaneous units
- Max actions per turn: 500 total actions
- Max modifiers per unit: 5 active modifiers

**Balance Validation:**
- Average actions per turn: 2-4 actions optimal
- TU efficiency: 70-90% utilization target
- Cost variance: 0.2-3.0x multiplier range
- Modifier frequency: 10-30% of turns affected

### Unit Actions
**Action Point Economy (Detailed):**
- Total AP per turn: 4-10 depending on unit class
- Basic movement: 1 AP per tile traversed
- Terrain modifiers apply: flat (1 AP), rough (1.5 AP), difficult (2 AP)
- Combat actions: ranged attacks (1-3 AP), melee (2 AP), special weapons (3-4 AP)
- Special abilities: utility actions (2-4 AP), class abilities (3-5 AP)
- Item usage: simple items (1 AP), complex items (2 AP), equipment changes (2-3 AP)

**Movement Action Types:**
- Basic Movement: standard walking pace, 1 AP per tile, no penalties
- Low Profile/Crouch: stealth movement, 1.5 AP per tile, +20% stealth, -10% visibility
- Sprint/Run: rapid movement, 0.75 AP per tile, -30% accuracy, +1 fatigue per tile
- Climb: vertical movement, 2 AP per height level, requires suitable terrain
- Swim: water movement, 1.5 AP per tile, -20% accuracy while swimming
- Jump/Vault: obstacle crossing, 2 AP per action, requires adequate strength

**Combat Actions (Comprehensive):**

*Ranged Combat:*
- Standard Shot: basic firing mode, 1 AP, standard accuracy
- Aimed Shot: precision firing, 2 AP, +20% accuracy, takes more time
- Burst Fire: multiple rounds, 2 AP, 3-5 shots, -10% accuracy per shot
- Suppressive Fire: area denial, 2-3 AP, reduces enemy morale and accuracy
- Called Shot: target specific body part, 3 AP, -20% to hit, increased critical damage
- Snapshot: quick reaction shot, 1 AP, -15% accuracy
- Overwatch Shot: reaction fire mode, uses reserved AP from previous turn

*Melee Combat:*
- Basic Attack: standard melee, 2 AP, weapon damage
- Charge Attack: momentum strike, 3 AP, requires movement, +50% damage
- Disarm Attempt: remove enemy weapon, 2 AP, opposed skill check
- Grapple: restrain enemy, 3 AP, prevents enemy movement
- Bash: stun attack, 2 AP, chance to disorient target
- Execution: coup de grace, 2 AP, only on incapacitated enemies

*Grenade Actions:*
- Throw Grenade: standard throw, 2 AP, range based on strength
- Set Timer: delayed explosion, 1 AP + throw, 1-5 turn delay
- Smoke Deployment: concealment, 2 AP, creates smoke cloud
- Flashbang Throw: stun grenade, 2 AP, disorients enemies in radius
- Incendiary Grenade: fire starter, 2 AP, creates lasting fire
- EMP Grenade: electronics disabler, 2 AP, disables mechanical units

**Special Actions (Detailed):**

*Overwatch System:*
- Setup Cost: 1 AP to establish overwatch
- Time Unit Cost: 20 TU to maintain
- Reaction Window: triggers on enemy movement in vision
- Accuracy Modifier: +10% for prepared shot
- Shot Limitations: one reaction shot per enemy action
- Breaking Overwatch: enemy fire or grenade forces break
- Squad Overwatch: multiple units can coordinate

*Reload Actions:*
- Standard Reload: full magazine, 2 AP, 15 TU
- Speed Reload: partial magazine, 1 AP, 10 TU, wastes remaining ammo
- Tactical Reload: during cover, 1 AP, 12 TU, +5% accuracy next shot
- Belt Feed: heavy weapon, 3 AP, 25 TU, sustained fire capability
- Quick Draw: weapon swap, 1 AP, 8 TU, ready different weapon

*Medical Actions:*
- First Aid: stabilize wound, 2 AP, 20 TU, stops bleeding
- Full Heal: major healing, 3 AP, 35 TU, restores 40-60 HP
- Revive Downed: resuscitate unconscious, 3 AP, 30 TU, requires medkit
- Pain Management: temporary boost, 2 AP, 15 TU, reduces injury penalties
- Status Cure: remove negative effect, 2 AP, 20 TU, cures poison/burn/etc

*Equipment Actions:*
- Switch Weapon: change active weapon, 1 AP, 8 TU
- Use Item: consume item, 1-2 AP depending on item complexity
- Deploy Gadget: place equipment, 2 AP, 15 TU (motion sensor, mine, etc.)
- Hack Terminal: computer access, 4 AP, 45 TU, skill check required
- Lockpick: open locked door, 3 AP, 30 TU, tool required
- Plant Explosive: set demolition charge, 3 AP, 30 TU, timer optional

**Advanced Action Mechanics:**

*Action Queuing:*
- Plan multiple actions before execution
- Actions execute in sequence automatically
- Can cancel queued actions before commitment
- Visual preview shows action sequence
- AP cost calculated and displayed before confirmation

*Conditional Actions:*
- "If-Then" logic for reaction scenarios
- "Move to position IF clear, ELSE take cover"
- "Shoot enemy IF visible, ELSE overwatch"
- Triggers activate based on battlefield conditions

*Interrupted Actions:*
- Enemy reaction fire can interrupt movement
- High-priority threats force action reassessment
- Morale checks can cancel planned actions
- Environmental hazards trigger defensive responses

*Opportunity Actions:*
- Free actions from special circumstances
- Door breaching during movement (no extra AP)
- Quick reload after kill (reflex perk)
- Dodge reaction (defensive perk)

**Modifiers Affecting Actions:**
- Fatigue: increases AP costs by 10-50%
- Injury: specific actions limited or impossible
- Morale: low morale restricts aggressive actions
- Experience: veterans gain efficiency bonuses (-5 to -15% AP costs)
- Equipment: specialized gear reduces specific action costs
- Environmental: weather and terrain affect feasibility
- Status Effects: buffs and debuffs modify action availability

**Unit-Specific Action Sets:**

*Infantry Classes:*
- Assault Trooper: mobility bonuses, burst fire specialization, close quarters focus
- Sniper: precision shots, overwatch expertise, called shots available
- Support: medical actions, suppression capability, team buffs
- Heavy Weapons: area effects, sustained fire, defensive positions
- Scout: stealth actions, detection abilities, rapid movement
- Engineer: technical actions, demolitions, equipment deployment

*Alien Unit Actions:*
- Drone: flying movement (ignore terrain), scanning abilities, hit-and-run
- Heavy Alien: powerful melee, area attacks, intimidation effects
- Psionic Units: mind control, psi attacks, telekinesis actions
- Terror Units: fear-inducing actions, regeneration, frenzied attacks

**Tactical Action Applications:**

*Combined Arms Tactics:*
- Fire and Maneuver: suppression + movement coordination
- Bounding Overwatch: alternating advance and cover
- Flanking Maneuver: coordinated positioning for advantage
- Breach and Clear: synchronized room entry with multiple units

*Resource Management:*
- AP Conservation: holding actions in reserve for reactions
- AP Investment: spending all for maximum immediate impact
- Balanced Approach: mix of offense and defense
- Opportunity Cost: choosing between multiple action options

**Configuration Examples:**
```toml
[action_points.basic_movement]
cost_per_tile = 1
terrain_modifier_min = 0.5  # easy terrain
terrain_modifier_max = 2.0  # difficult terrain

[action_points.combat_actions]
ranged_min = 1  # snapshot
ranged_max = 3  # aimed shot
melee = 2       # standard attack
special_min = 2 # basic ability
special_max = 4 # advanced ability

[action_points.item_usage]
simple = 1   # use medkit
complex = 2  # hack terminal
advanced = 3 # plant explosives

[time_units.quick_actions]
min = 5   # take cover
max = 15  # use item

[time_units.standard_actions]
min = 20  # melee attack
max = 40  # sniper shot

[time_units.complex_actions]
min = 50  # hacking
max = 80  # complex technical task
```

### Unit Attributes
**Core Attributes (Primary Stats):**
- Health (HP): 50-150 range, determines survivability
- Strength: 5-15 range, affects carry capacity and melee damage
- Speed: 5-15 range, determines movement distance and initiative
- Accuracy: 30-90 range, base hit chance percentage
- Reactions: 5-15 range, affects reaction fire and initiative
- Bravery: 10-100 range, resistance to panic and morale loss
- Willpower: 10-100 range, resistance to psionic attacks
- Throwing Accuracy: 30-90 range, grenade precision
- Psi Strength: 0-100 range, psionic power (if capable)
- Psi Skill: 0-100 range, psionic ability effectiveness

**Derived Attributes:**
- Carry Capacity: Strength × 2kg, maximum equipment weight
- Movement Distance: Speed stat × 1.5 tiles per AP
- Initiative: (Reactions + Speed) / 2, determines turn order
- Melee Damage: Strength × weapon multiplier
- Psi Defense: Bravery + Willpower combined resistance
- Fatigue Resistance: (Strength + Bravery) / 2
- Recovery Rate: Strength-based healing modifier

**Experience-Based Progression:**
- Experience Points (XP): gained from combat actions
- Level Range: 1-10 possible ranks
- Rank Progression: Rookie → Squaddie → Corporal → Sergeant → Lieutenant → Captain → Major → Colonel
- Attribute Gains per Level: 1-2 points to random stats
- Skill Points: earned at levels 3, 6, 9 for specializations
- Level 10 Bonus: +5 to all stats, special ability unlock

**Racial Modifiers:**
- Human: balanced stats, no special modifiers, adaptable
- Human Elite: +10% all stats, special forces training
- Alien Warrior: +20% strength, +15% reactions, -10% bravery
- Alien Scout: +30% speed, +20% reactions, -20% strength
- Alien Commander: +25% willpower, +30% psi strength, leadership bonus
- Mechanical Unit: Immune to morale/psi, no healing, high armor
- Biological Experiment: Variable stats, unstable traits

**Unit Class Differences:**
- Soldier (Infantry): Balanced attributes, general purpose
- Quick actions: 5-15 TU
- Standard actions: 20-40 TU
- Complex actions: 50+ TU
- Granular timing and reaction system

### Unit Actions
- Action Point Economy: 1-6 AP per action, basic movement (1 AP/tile), combat (1-3 AP), abilities (2-4 AP)
- Movement Actions: basic, low profile, sprint, climb, swim
- Combat Actions: ranged (snap/aimed/burst/suppressive/called), melee (basic/charge/disarm/grapple), grenades
- Special Actions: overwatch, reload variants, medical, equipment
- Action queuing and conditional/interrupted/opportunity actions
- Unit-specific action sets for classes and aliens

### Unit Attributes
- Core stats: Health, Strength, Speed, Accuracy, Reactions
- Derived attributes: carry capacity, movement distance, initiative
- Experience-based progression
- Racial modifiers and unit class differences

### Unit Equipment
- Weapon slots: primary, secondary, grenades
- Armor slots with protection values
- Utility items and gadgets
- Encumbrance system based on Strength

### Unit Experience
- Experience points from combat actions
- Rank progression system
- Skill unlocks and attribute improvements
- Veteran bonuses

### Unit Fatigue
- Fatigue accumulation from actions and time
- Performance penalties from exhaustion
- Rest and recovery mechanics
- Mission length impact on fatigue

### Unit Injuries
- Wound system: light, moderate, severe, critical
- Injury location (head, torso, limbs)
- Bleeding and stabilization mechanics
- Long-term recovery and disability

### Unit Morale
- Morale Scale: 0-100 (broken → fanatical)
- Morale Modifiers: combat events, leadership, environment, unit status, mission factors
- Morale Effects: accuracy, movement, decision-making modifiers
- Panic and Breaking: panic checks, random actions, permanent breakdown at 0
- Recovery rates: daily, combat, medical, psychological support
- Leadership influence: officer bonuses, squad cohesion, heroic actions
- Racial morale characteristics

### Unit Movement
- Grid-based movement with AP costs
- Terrain movement modifiers (rough, water, obstacles)
- Climbing and vertical movement
- Sprint vs. cautious movement modes

### Unit Panic
- Panic triggers: high damage, ally deaths, alien sightings, psionic attacks
- Panic effects: random movement, dropping weapons, cowering, berserk
- Panic recovery through leadership and time
- Racial panic resistance

### Unit Psionics
- Psi Abilities: mind control, psi attacks, telekinesis, mind shields
- Psi Defenses: resistance training, sanity system, detection tools
- Psi Costs: energy drain, sanity damage on failure, regeneration
- Psi Level Requirements: 1-10 scale with unlocked abilities
- Psi Energy Pool: 50-200 capacity with regeneration rates
- Ability Success Rates: 40-95% based on skill and resistance
- Equipment integration for psi enhancement and resistance

### Unit Reactions
- Reaction fire triggers: enemy movement in line of sight
- Reaction shots with accuracy penalties
- Reserved action points for reactions
- Opportunity fire system

### Unit Sanity
- Sanity points affected by horror events
- Sanity loss from alien encounters and psionics
- Insanity effects and hallucinations
- Recovery through rest and treatment

### Unit Status Effects
- Buffs: inspired, stimmed, shielded, overwatch
- Debuffs: stunned, poisoned, burning, frozen, panicked, suppressed
- Duration tracking and effect stacking
- Status effect interactions and immunities

---

## Battlescape AI

### Battle Map Movement
- Pathfinding with A* algorithm on tactical grid
- Movement cost calculation with terrain factors
- Threat assessment during movement planning
- Cover-to-cover movement prioritization

### Battle Team Level AI
- Squad coordination and formation keeping
- Team tactics: bounding overwatch, fire teams, suppression support
- Target prioritization at squad level
- Tactical objective assessment

### Behaviors
- Behavior trees for AI decision making
- Personality-driven behavior selection
- Context-sensitive action evaluation
- Emergent tactical behaviors from utility scoring

### Map AI Nodes
- Pre-calculated tactical positions
- Cover quality markers
- Chokepoint identification
- Overwatch position markers

### Map Exploration
- Unknown area prioritization
- Scouting unit designation
- Safe exploration paths
- Contact avoidance vs. engagement decisions

### Movement
- Efficient path calculation
- Danger zone avoidance
- Flanking route identification
- Retreat path planning

---

## Core Systems

### Action Economy
- Tactical AP: 4 AP per soldier turn (~6 second narrative time)
- Operational AP: 4 AP per craft round (~30 second narrative time)
- Strategic Time: continuous 5-minute increments with speed multipliers (1×/5×/30×)
- Consistent 4 AP budget across contexts
- Fractional handling: round-down for distance, round-up for costs
- No AP banking between turns

### Capacity Systems
- Unit Encumbrance: Max_Weight = Strength × Multiplier
- Craft Cargo: dual-capacity for weight and unit slots
- Binary validation: accepted or rejected, no partial penalties
- Pre-mission validation prevents invalid loadouts
- Runtime validation for pickup/swap actions

### Energy Systems
- Tactical Energy: 0-100 per unit for abilities and equipment
- Operational Energy: 0-100 per craft for weapons and maneuvers
- Automatic end-of-turn regeneration with modifiers
- Energy costs for abilities, heavy weapons, powered armor, special movement
- Energy clips, power generators, charging stations

### Time Systems
- Strategic Layer: 5-minute ticks with 1×/5×/30× speed
- Operational Layer: ~30 second combat rounds
- Tactical Layer: ~6 second combat turns
- Time Conversions: 288 ticks/day, 360-day year (12×30)
- Event scheduling in tick increments
- Auto-pause on critical events

### Balancing Framework
- Deterministic difficulty scaling
- Player performance tracking
- Dynamic encounter adjustment
- Resource availability balancing

### Battle Turn System
- Turn-based tactical layer with initiative order
- Action point allocation per unit
- Simultaneous resolution for reactions
- Turn order display and prediction

### Battlefield Sight and Sense
- Multi-sensory detection: visual, audio, thermal, motion
- Sense-specific ranges and accuracy
- Environmental impact on detection
- Fog of war with last-seen positions

### Event System
- Global event bus for inter-system communication
- Event subscriptions with priority
- Event payload validation
- Deterministic event ordering

### Geo Turn System
- Continuous time progression on strategic layer
- Event scheduling and resolution
- Mission spawning cadence
- Time-based resource generation

### Interception Turn System
- Round-based air combat resolution
- Simultaneous craft actions
- Energy and cooldown management
- Outcome determination

### Modding API
- Hook registration for game events
- Data extension systems
- Script sandboxing
- Version compatibility management

### Progression and Difficulty Scaling
- Technology progression gates
- Enemy force scaling with player progress
- Strategic escalation mechanics
- Difficulty curve management

### Reputation System
- Faction-based reputation tracking
- Reputation modifiers from missions and actions
- Diplomatic consequences of reputation
- Reputation thresholds for content unlocks

### Score System
- Mission performance scoring
- Monthly score aggregation
- Score impact on funding and narrative
- Victory condition scoring

### Tutorial System
- Context-sensitive tutorials
- Progressive feature unlocking
- Help system integration
- Tutorial skip and replay options

---

## Economy

### Black Market
- Illegal goods trading with detection risk
- Price fluctuations and availability
- Reputation impact from black market use
- Contraband acquisition opportunities

### Item Crafting
- Recipe-based crafting system
- Material requirements and costs
- Workshop capacity constraints
- Production time and queue management

### Manufacturing
- Production projects with material/credit/man-hour costs
- Queue priority reordering
- Workshop capacity allocation
- Daily progress accumulation

### Marketplace
- Supplier system with curated stock
- Regional availability and reputation gates
- Monthly stock refresh with deterministic seeds
- Purchase and sale mechanics

### Research Tree
- Atomic TOML research entries with prerequisites
- Research-hours cost and daily progress
- Directed acyclic graph structure
- Branching choices with tags
- Lab capacity consumption
- Unlock payloads: items, facilities, research, story events

### Resource Flow
- Income: funding, contracts, market sales, black market, interest
- Expenses: salaries, maintenance, manufacturing, purchases
- Treasury reserves and debt ledger
- Asset flow: salvage → storage → equipped units → market

### Suppliers
- Global, regional, military, corporate, black market suppliers
- Stock generation with rarity tiers
- Delivery times and transfers
- Reputation requirements for access

### Transfers
- Movement of items, units, crafts between bases
- Deterministic travel times
- Cargo reservations and overflow policies
- Transfer tracking and notifications

---

## Finance

### Debt & Emergency Credit
- Three-tier loan system with different rates
- Daily compounding interest
- Missed payment escalation to sanctions
- Lose condition from excessive debt

### Funding Model
- Monthly funding from country satisfaction (0-200%)
- Base amount modified by security status and story events
- Panic spikes trigger funding reviews
- Deterministic formulas for funding calculation

### Income Sources
- Primary: country funding
- Secondary: contracts, marketplace profits, black market, reserve interest
- Dynamic income based on performance

### Monthly Reports
- Income and expense summary
- Debt status and projections
- Score and reputation updates
- Risk flagging and alerts

### Score & Reputation
- Mission outcomes tracking
- Civilian loss penalties
- Strategic objective completion
- Monthly score deltas feeding funding

### Win-Loss Conditions
- Victory: narrative objectives or reputation + research thresholds
- Defeat: zero funding, debt threshold exceeded, time-sensitive objective failure
- Deterministic win/loss checks with logging

---

## Geoscape

### Biome
- Environmental type classification
- Terrain and mission type associations
- Weather pattern determination

### Country
- Funding contributor with satisfaction tracking
- Territory ownership and panic levels
- Diplomatic status and relations

### Craft Operations
- Dispatch validation: distance, fuel, sortie limits
- Instant movement with deterministic time consumption
- Recovery systems: fuel replenishment, repair timers
- Operational limits: range, fuel, speed, maintenance

### Detection
- Radar coverage and mission visibility
- Surveillance service integration
- Detection ranges and accuracy
- Undetected mission consequences

### Game Loop
- 5-minute tick increments
- Event scheduling and resolution
- State transitions and persistence
- Auto-pause functionality

### Mission Types
- Abduction, terror, infiltration, research, base assault, supply raid, crash site, landing site
- Template-based generation with weighted decks
- Province tag and regional characteristic matching
- Detection and player choice integration

### Portal
- Activity escalation marking alien entry
- Inter-world travel mechanics
- Portal network for multi-world campaigns
- Neutralization objectives

### Province
- Hex-derived graph connections
- Province data: coordinates, biome, economy, population, ownership, tags
- Dynamic state: panic, missions, radar coverage, portal status

### Region
- Province grouping for funding and diplomacy
- Regional mission weighting
- Collective diplomatic weight

### Terrain
- Map terrain type determination
- Mission environment selection
- Strategic terrain features

### Universe
- Multi-world support with portal connections
- Shared scheduler and mission pipeline
- Strategic expansion mechanics

### World Time
- Deterministic tick-based progression
- Campaign calendar (360-day year)
- Time-of-day tracking
- Seasonal mechanics

---

## GUI Systems

### Basescape UI
- Base layout visual editor
- Facility placement interface
- Personnel management screens
- Manufacturing and research queues

### Battlescape UI
- Tactical overlay with grid
- Unit action panels
- Targeting reticles
- Turn order queue display

### Geoscape UI
- Province map with mission markers
- Craft tracker and interception interface
- Diplomacy map overlay
- Time controls and event notifications

### Interception UI
- 3×3 engagement grid display
- Action point and energy indicators
- Weapon selection interface
- Base defense facility overlay

### Menu and Meta UI
- Main menu and settings
- Save/load interface
- Options and key binding
- Credits and tutorials

### Notification System
- Event notification queue
- Priority-based alert system
- Dismissible vs. blocking notifications
- Notification history log

---

## Interception

### Air Battle
- 3×3 grid tactical combat
- Player slots X/Y/Z vs. alien slots A/B/C
- Layer representation: air/surface/sub-surface
- Slot swapping and layer shifts costing AP + energy

### Air Weapons
- Weapon types: missiles, cannons, beams, support systems
- AP and energy costs with round-based cooldowns
- Range and damage profiles
- Air-to-air, air-to-land, anti-submarine tags

### Base Defense and Bombardment
- Base Defense Mode: facilities in grid slots, destruction damages layout
- Bombardment Mode: player bombers target enemy bases, reduces battlescape difficulty
- Base facility participation as grid weapons
- Shared energy from base services

### Enemy Base Assault
- Pre-assault bombardment phase
- Infiltration vs. direct assault options
- Base difficulty modifiers
- Strategic base destruction impacts

### Interception Core Mechanics
- Action Economy: 4 AP per craft per round
- Detection and Ambush: radar/satellite/sensor detection, ambush grants surprise rounds
- Outcome Resolution: victory (crash sites), stalemate (disengagement), defeat (craft loss/base damage)
- Special modes: underwater combat with pressure/sonar/depth mechanics
- Deterministic animations with grid-aligned effects

### Land Battle Transitions
- Crash site generation from air victories
- Landing site preparation
- Mission setup with salvage and difficulty modifiers
- Transition to battlescape with context

### Underwater Combat
- Aquatic Environment: pressure damage, visibility limits, current effects, breathing mechanics
- Submarine Craft: depth control, aquatic propulsion, pressure resistance, sonar systems
- Underwater Weapons: torpedoes, depth charges, sonic weapons, mine deployment
- Combat Dynamics: 3D positioning, slow movement, stealth (silent running), environmental hazards
- Detection Systems: active/passive sonar, magnetic anomaly, thermal imaging
- Damage: flooding effects, pressure damage, explosive propagation, salvage operations

---

## Items

### Damage Calculations
- Base damage + spread + critical multiplier
- Armor pierce and resistances
- Leftover damage conversion to wounds/structure damage

### Damage Model
- Damage types: kinetic, energy, plasma, chemical, psionic
- Type-specific mitigation interactions
- Area effect templates on 20×20 grid
- Deterministic blast footprints

### Damage Types
- Kinetic: ballistic weapons, explosives
- Energy: lasers, electrical
- Plasma: alien weapons
- Chemical: acid, poison, gas
- Psionic: mental damage

### Item Action Economy
- AP cost, energy cost, cooldown, ammo per action
- Multi-mode weapons with shared ammo, distinct AP costs
- Status effect application
- Effect logging for replay

### Unit Items
- Taxonomy: weapon, armor, utility, consumable, resource, craft_weapon, facility_module, lore
- Tags for availability and AI evaluation
- Manufacturing recipes with inputs/outputs
- Pedia integration for lore items

### Weapon Modes
- Single shot, burst fire, auto fire
- Aimed vs. snap shots
- Suppressive fire mode
- Mode-specific costs and effects

---

## Lore

### Alien Species
- Faction-specific alien races
- Racial traits and abilities
- Technology preferences
- Behavioral patterns

### Calendar
- 360-day year (12 months × 30 days)
- Seasonal narrative beats
- Event scheduling tied to calendar
- Time-limited story missions

### Campaign
- Campaign Phases: Arrival → Escalation → Crisis → Resolution
- Phase transitions from score/research/story triggers
- Mission weights and event decks per phase
- AI aggression multipliers

### Enemy Base Script
- Installation lore and modifiers
- Map themes and narrative rewards
- Base defeat impacts on campaign

### Event
- Template scripts with conditions (province_tag, research_done, time_window)
- Provenance logging for determinism
- Story beat triggers
- Branching outcomes

### Faction
- Alien factions, council nations, corporations, resistance cells
- Goals, favors, penalties per faction
- Reputation system integration
- Faction-specific missions and events

### Mission
- Story-driven mission templates
- Narrative context for operations
- Mission chain progression
- Branching mission paths

### Quest
- Structured story arcs
- Event chaining with branching
- Quest progress tracking
- Rewards and consequences

### UFO Script
- Flight personalities: scout, terror, retaliator
- AI Director weight integration
- UFO behavioral patterns

---

## Modding

### API Reference
- Comprehensive API documentation
- Sandboxed function whitelist
- Event hook registration
- Data extension interfaces

### Content Override System
- Mod priority-based override resolution
- Specific key overwrites
- List/map merging strategies
- Conflict warnings

### Getting Started
- 15-minute first mod tutorial
- Basic mod structure
- Development workflow
- Testing and debugging

### Mod Structure
- File organization standards
- `mod.toml` manifest format
- `data/`, `assets/`, `scripts/` directories
- Widget and localization registration

---

## Organization

### Company
- Player organization structure
- Hierarchy and command chain
- Organizational capabilities
- Corporate reputation

### Fame
- Public recognition tracking
- Fame impact on recruitment and funding
- Fame-based unlock tiers

### Karma
- Moral choice tracking
- Karma consequences for gameplay
- Ethical decision system

### Policies
- Organizational policy selection
- Policy effects on operations
- Policy unlocks and restrictions

### Reputation System
- Multi-faction reputation tracking
- Reputation modifiers from actions
- Diplomatic unlocks from reputation tiers
- Trade and mission access gates

---

## Technical

### Data Schemas
- TOML schema definitions
- Validation rules and checks
- Schema versioning
- Data migration system

### Data Structures
- Core data structures for game entities
- Deterministic data handling
- Serialization formats
- Data integrity verification

### Determinism
- Seeded RNG system with scope management
- Reproducible outcomes for replay
- State consistency validation
- Deterministic event ordering

### Grid System
- 20×20 logical grid for all screens
- Tile-based positioning
- Snap-to-grid helpers
- Grid-aligned rendering

### Input Abstraction Layer
- Keyboard, mouse, controller normalization
- Semantic action mapping (`ui_accept`, `ui_cancel`, `ui_next_tab`)
- Runtime remapping without restart
- Scripted input sequences for testing

### Line of Sight
- Ray-casting algorithm
- Tile centroid alignment
- Elevation impact calculation
- Efficient LOS caching

### Modding Architecture
- Mod loading and priority resolution
- Sandbox restrictions and API whitelist
- Widget and theme registration
- Localization integration

### Pathfinding
- A* algorithm implementation
- Movement cost calculation
- Threat-aware pathfinding
- Path caching and optimization

### Save System
- Serialized Lua tables with zlib compression
- Autosave after turns and milestones
- Replay metadata storage
- Save versioning and migration

### Service Locator
- Shared service registry
- Service lifecycle management
- Event bus integration
- Time and economy services

### State Stack
- Screen state management (menu, geoscape, basescape, interception, battlescape, pedia)
- Push/pop state transitions
- State-specific input, update, draw routing

---

## Widgets

### Advanced Interactive Widgets (4)
- Drag/drop systems
- Inventory grids
- Equipment slots
- Advanced input controls

### Base Management Widgets (12)
- Base layout editor
- Market panel
- Personnel roster
- Communications panel
- Manufacturing queue
- Research allocation
- Storage management
- Transfer tracking
- Monthly reports
- Facility status
- Defense configuration
- Base naming

### Basic Interactive Widgets (20)
- Buttons
- List boxes
- Text inputs
- Table grids
- Checkboxes
- Radio buttons
- Sliders
- Dropdowns
- Spinners
- Color pickers
- File browsers
- Date pickers
- Time pickers
- Number inputs
- Password inputs
- Search boxes
- Tags input
- Rating widgets
- Toggle switches
- Pagination

### Battlescape Widgets (15)
- Tactical overlays
- Unit action panels
- Targeting reticles
- Turn order queue
- Cover indicators
- Threat display
- Ability buttons
- Status effects display
- Movement preview
- Attack preview
- Reaction indicators
- Suppression markers
- Overwatch zones
- Line of sight overlay
- Environmental hazards

### Display and Feedback Widgets (4)
- Progress bars
- Meters (health, energy, morale)
- Tooltips
- Notifications

### Geoscape Widgets (12)
- Province map
- Mission markers
- Craft tracker
- Interception tracker
- Diplomacy map
- Radar coverage overlay
- Time controls
- Alert notifications
- Event log
- Province details
- Region overview
- Portal indicators

### Layout and Container Widgets (4)
- Panels
- Tabs
- Scroll containers
- Split views

### Specialized Game Widgets (5)
- Globe map
- Minimap
- Turn indicators
- Status effects display
- Calendar widget

### Strategy Game Widgets (12)
- Resource panels
- Action queues
- Research trees
- Mission objectives
- Diplomacy panels
- Tech tree visualization
- Campaign progress
- Victory conditions
- Threat assessment
- Strategic overview
- Event timeline
- Faction relations

### UFOPedia Widgets (10)
- Encyclopedia navigation
- Entry viewers
- Search widgets
- Bookmarks
- Category browsers
- Image galleries
- Stat comparisons
- Tech tree links
- Cross-references
- History tracking

### Widget Architecture
- 20×20 logical grid alignment
- 10×10 source art scaled ×2
- Theme token integration
- Input abstraction layer
- Modular composition
- Deterministic animations
- Accessibility support
- Localization integration

---

## Content Generator

### Base Script Generator
- Procedural base layout generation
- Facility placement rules
- Starting base templates
- AI base generation

### Campaign Generator
- Campaign arc creation
- Phase balancing
- Event distribution
- Difficulty curve generation

### Craft Class Generator
- Craft stat generation
- Weapon loadout templates
- Craft role definitions
- Balance validation

### Event Generator
- Random event creation
- Condition-based triggers
- Outcome branching
- Narrative consistency checks

### Facility Generator
- Custom facility definitions
- Cost and benefit balancing
- Tech requirement generation
- Facility chain creation

---

## Audio

### Sound System
- Audio playback with Love2D
- Sound effect management
- Music system with crossfading
- Volume controls and mixing
- Positional audio in battlescape
- Audio cues for events
- Accessibility audio options

---

### Combat Damage System (Comprehensive)

**Base Damage Formula:**
```
Damage = Base_Weapon_Damage + Random_Spread + Critical_Multiplier - Armor_Reduction
```

Where:
- Base_Weapon_Damage: weapon's inherent damage stat
- Random_Spread: ±20% variance for unpredictability
- Critical_Multiplier: 1.5x-3.0x on critical hits
- Armor_Reduction: target's armor value

**Damage Spread Calculation:**
- Minimum Damage: Base × 0.8 (20% below base)
- Maximum Damage: Base × 1.2 (20% above base)
- Average Damage: Base damage (expected value)
- Distribution: uniform random within range

**Critical Hit System:**
- Base Crit Chance: 5-15% depending on weapon
- Crit Modifiers: +skill, +flanking position, +aimed shot
- Crit Confirmation: second roll to confirm critical
- Crit Damage Multiplier: weapon-dependent (1.5x-3.0x)
- Headshot Bonus: additional +0.5x multiplier
- Backstab Bonus: +1.0x when attacking from behind

**Armor Penetration:**
- Armor Pierce Rating: weapon's AP value (0-100%)
- Effective Armor: Target_Armor × (1 - AP_Rating)
- Minimum Damage: at least 20% damage penetrates armor
- Maximum Armor: cannot reduce damage below 20%
- Armor Degradation: armor loses effectiveness as damaged

**Damage Type Modifiers:**
- Kinetic vs Armor: standard penetration
- Energy vs Shields: +50% damage
- Plasma vs Organics: +30% damage
- Chemical vs Unprotected: +100% damage, DOT
- Psionic vs Mind: bypasses physical armor entirely
- Explosive: area damage with falloff

**Cover Damage Reduction:**
- No Cover: 0% reduction, full damage
- Half Cover: -30% damage taken
- Full Cover: -60% damage taken
- Reinforced Cover: -80% damage taken
- Flanked: cover bonus negated, +20% damage taken
- Cover Destruction: sustained fire destroys cover

**Status Effect Damage:**
- Burning: 5-15 HP per turn for 3-5 turns
- Poison: 3-8 HP per turn for 5-10 turns
- Bleeding: 2-6 HP per turn until treated
- Acid: 8-12 HP per turn + armor degradation
- Electric: 10-20 instant damage + stun chance
- Psionic: 5-10 mental damage + sanity loss

---

### Research Technology Tree (Complete)

**Research Entry Structure:**
- Research ID: unique identifier
- Display Name: player-facing name
- Description: lore and gameplay explanation
- Research Cost: scientist-hours required
- Prerequisites: required prior research
- Unlocks: items, facilities, further research
- Research Category: weapons, armor, aliens, psionics, etc.

**Tier 1 Research (Early Game, 0-3 months):**

*Conventional Weapons (Starting):*
- Advanced Ballistics: 3 days, unlocks improved rifles
- Explosive Compounds: 5 days, unlocks advanced grenades
- Precision Optics: 4 days, unlocks scopes and sniper upgrades
- Ballistic Vests: 5 days, unlocks basic body armor

*Initial Alien Analysis (Requires UFO Recovery):*
- Alien Materials: 7 days, foundational research, unlocks armor path
- UFO Power Source: 10 days, unlocks laser weapons path
- Alien Alloys: 8 days, unlocks advanced construction
- Elerium-115: 12 days, unlocks power systems

*Facility Research:*
- Radar Systems: 7 days, unlocks basic detection
- Long Range Radar: 10 days, extends detection range
- Laboratory Expansion: 5 days, increases research capacity
- Workshop Efficiency: 5 days, reduces manufacturing time

**Tier 2 Research (Mid Game, 3-6 months):**

*Laser Technology Path (Requires UFO Power Source):*
- Laser Weaponry: 15 days, unlocks laser rifle, pistol
- Heavy Laser: 20 days, unlocks squad support weapon
- Laser Cannon (craft): 18 days, unlocks craft weapon
- Laser-Resistant Materials: 12 days, armor upgrade component

*Plasma Technology Path (Requires Plasma Weapon capture):*
- Plasma Weaponry: 25 days, unlocks plasma rifle
- Heavy Plasma: 30 days, unlocks heavy plasma weapon
- Plasma Cannon (craft): 28 days, advanced craft weapon
- Plasma Containment: 20 days, improves plasma efficiency

*Advanced Armor (Requires Alien Alloys):*
- Powered Armor: 18 days, unlocks powered armor suit
- Titan Armor: 22 days, unlocks heavy armored suit  
- Ghost Armor: 20 days, unlocks stealth armor
- Flying Suit: 25 days, unlocks personal flight capability

*Alien Biology (Requires Alien Corpses):*
- Sectoid Autopsy: 8 days, reveals psi weakness
- Muton Autopsy: 10 days, reveals strength genetics
- Chryssalid Autopsy: 12 days, reveals reproduction method
- Ethereal Autopsy: 15 days, unlocks psi research path

**Tier 3 Research (Late Game, 6-12 months):**

*Fusion Technology (Requires Elerium + Alien Computers):*
- Fusion Weapons: 40 days, unlocks fusion rifle
- Blaster Launcher: 50 days, unlocks guided missile weapon
- Fusion Cannon (craft): 45 days, ultimate craft weapon
- Fusion Power Core: 35 days, unlimited power for bases

*Ultimate Armor:*
- Fusion Armor: 35 days, best protection available
- Personal Flying Suit: 45 days, flight + protection
- Psi Armor: 40 days, psi resistance + physical protection

*Psionics (Requires Ethereal Research):*
- Psi Lab: 30 days, unlocks psi training facility
- Mind Control: 35 days, offensive psi ability
- Telekinesis: 38 days, object manipulation ability
- Mind Shield: 30 days, psi defense system
- Psi Amp: 25 days, psi power amplification device

*Advanced Craft (Requires Multiple Alien Technologies):*
- Firestorm: 45 days, advanced interceptor
- Lightning: 50 days, multi-role fighter
- Avenger: 60 days, ultimate transport/bomber
- Hyperwave Decoder: 20 days, perfect UFO detection

**Tier 4 Research (End Game, Victory Path):**

*Alien Origins (Requires All Alien Leader Autopsies):*
- Alien Origins: 90 days, reveals invasion master plan
- Cydonia or Bust: 60 days, unlocks final mission location
- The Final Solution: 30 days, strategy for ultimate victory

*Ultimate Technology:*
- Hyperspace Drive: 120 days, interstellar travel capability
- Dimensional Portal: 100 days, multi-world access
- Psionic Mastery: 80 days, complete mental dominance
- Fusion Mastery: 70 days, unlimited energy applications

**Branching Research Paths:**

*Weapon Specialization (Choose One):*
- Kinetic Mastery: +30% ballistic damage, penetration bonuses
- Energy Mastery: +30% laser/plasma damage, shield bypass
- Explosive Mastery: +50% explosive radius and damage

*Armor Specialization (Choose One):*
- Heavy Armor Focus: +50% armor values, -50% mobility penalty
- Stealth Armor Focus: +100% stealth, special infiltration missions
- Powered Armor Focus: +special abilities, energy shields

*Research Strategy Paths:*
- Aggressive Research: 50% faster, 50% more expensive, higher risk
- Cautious Research: 25% slower, 25% cheaper, guaranteed success
- Balanced Research: standard rates, no modifiers

**Research Dependencies (Complex Unlock Trees):**

```
Laser Path:
UFO Power Source (10d) →
├─ Laser Weaponry (15d) →
│  ├─ Heavy Laser (20d)
│  └─ Laser Cannon (18d)
└─ Laser Resistant Armor (12d) → Powered Armor (18d)

Plasma Path (Requires Captured Plasma Weapon):
Plasma Weaponry (25d) →
├─ Heavy Plasma (30d) →
│  └─ Plasma Sniper (35d)
├─ Plasma Cannon (28d) →
│  └─ Fusion Cannon (45d)
└─ Plasma Containment (20d)

Psi Path (Requires Ethereal Corpse):
Ethereal Autopsy (15d) → Psi Research (30d) →
├─ Mind Control (35d) →
│  └─ Mass Mind Control (50d)
├─ Telekinesis (38d) →
│  └─ Psi Storms (55d)
└─ Mind Shield (30d) →
   └─ Psi Fortress (40d)

Victory Path (Requires All Prerequisites):
All Alien Leader Autopsies → Alien Origins (90d) →
Hyperspace Navigation (120d) → Final Mission Access
```

**Research Modifiers and Bonuses:**
- Scientist Skill: experienced scientists +20% research speed
- Laboratory Quality: advanced labs +30% efficiency
- Multiple Scientists: up to 10 scientists per project, diminishing returns
- Related Research: prior knowledge in field +15% speed
- Captured Alive: living specimen +40% research effectiveness
- Intact UFO: undamaged craft +50% technology insights
- Alien Commander Interrogation: reveals hidden research paths

---

### Manufacturing System (Complete)

**Manufacturing Project Types:**
- Equipment Production: weapons, armor, items
- Craft Production: interceptors, transports
- Facility Construction: base buildings (handled separately)
- Ammunition Production: consumables and reloads
- Prototype Development: experimental one-off items

**Manufacturing Capacity System:**
- Workshop Capacity: man-hours per day (base 20, upgradable to 50)
- Engineer Assignment: engineers provide man-hours (5-10 per engineer)
- Multiple Workshops: capacities stack across base
- Multi-Base Manufacturing: distribute large orders
- Queue Management: priority system for project ordering

**Manufacturing Costs:**

*Labor Costs:*
- Engineer Salaries: $20,000-$40,000 per month per engineer
- Workshop Maintenance: $10,000 per month base cost
- Facility Upkeep: power and maintenance fees

*Material Costs:*
- Common Materials: metals, plastics, electronics
- Rare Materials: alien alloys, elerium, exotic compounds
- Components: specialized parts from suppliers or salvage

*Time Investment:*
- Simple Items: 10-50 man-hours (1-3 days)
- Complex Items: 100-300 man-hours (5-15 days)
- Craft Production: 500-2000 man-hours (25-100 days)
- Bulk Orders: scaled time with efficiency bonuses

**Example Manufacturing Recipes:**

*Conventional Weapons:*
- Assault Rifle: 20 man-hours, $2,000, standard materials
- Sniper Rifle: 30 man-hours, $3,500, precision components
- Heavy Machine Gun: 40 man-hours, $4,000, reinforced parts

*Laser Weapons (Tier 2):*
- Laser Rifle: 80 man-hours, $10,000, 5 alien alloys, 2 UFO power units
- Heavy Laser: 120 man-hours, $15,000, 8 alien alloys, 3 power units
- Laser Cannon: 150 man-hours, $20,000, 10 alloys, 5 power units

*Plasma Weapons (Tier 3):*
- Plasma Rifle: 100 man-hours, $25,000, 10 alloys, 5 elerium
- Heavy Plasma: 150 man-hours, $35,000, 15 alloys, 8 elerium
- Plasma Cannon: 200 man-hours, $50,000, 20 alloys, 12 elerium

*Armor Production:*
- Body Armor: 30 man-hours, $5,000, standard materials
- Powered Armor: 100 man-hours, $30,000, 15 alloys, 5 elerium
- Flying Suit: 150 man-hours, $50,000, 20 alloys, 10 elerium, antigrav unit

*Craft Manufacturing:*
- Interceptor: 500 man-hours, $200,000, standard materials
- Firestorm: 1000 man-hours, $600,000, 50 alloys, 20 elerium
- Avenger: 2000 man-hours, $2,000,000, 100 alloys, 50 elerium, fusion core

**Manufacturing Efficiency:**
- Research Bonuses: technology research reduces production time (-20%)
- Engineer Skill: experienced engineers work faster (+15%)
- Workshop Upgrades: improved facilities increase capacity (+50%)
- Bulk Production: economies of scale (5+ units: -10% time per unit)
- Rush Orders: 2x engineers, 50% time reduction, +50% cost
- Quality Control: slower production (+20% time), higher quality output

**Project Management:**
- Queue Prioritization: reorder projects dynamically
- Project Cancellation: refund 50% of materials, lose all time invested
- Project Suspension: pause indefinitely, resume later with no loss
- Completion Milestones: partial deliveries for large craft projects
- Auto-Reorder: automatically queue next unit upon completion

---

### Determinism and Save System (Comprehensive)

**Seed Architecture (Detailed):**

*Campaign Master Seed:*
- Generated at campaign start (date-based or player-chosen)
- Example: `seed:campaign:20251009`
- All other seeds derived from this
- Determines entire playthrough reproducibility

*System-Level Seeds:*
```
seed:world → Province events, UFO spawns, alien activity
seed:mission → Mission generation, enemy placement, loot
seed:combat → Hit/miss rolls, damage variance, critical hits  
seed:ai → Enemy decisions, patrol paths, target selection
seed:economy → Market prices, research breakthroughs, manufacturing quality
seed:events → Random events, story beats, faction actions
```

*Subsystem Seeds (Derived from System Seeds):*
```
seed:world:province:001 → Events in specific province
seed:mission:terror:042 → Specific terror mission generation
seed:combat:unit:123 → Combat rolls for unit 123
seed:ai:faction:sectoid → Sectoid faction decision-making
```

**Deterministic RNG Usage:**
```lua
-- Correct deterministic approach
function generateMission(campaign_seed, mission_id)
    local mission_seed = deriveSeed(campaign_seed, "seed:mission:" .. mission_id)
    local rng = createSeededRNG(mission_seed)
    
    local num_enemies = rng:random(8, 15)
    local map_layout = selectMapLayout(rng, mission_type)
    
    return {
        layout = map_layout,
        seed = mission_seed  -- Store for replay
    }
end
```

**Save File Organization:**

*Save Directory Structure:*
```
saves/
├── campaign_001_ironman/
│   ├── metadata.toml
│   ├── geoscape_state.toml
│   ├── bases_state.toml
│   ├── units_state.toml
│   ├── research_state.toml
│   └── rng_state.toml
├── campaign_002_normal/
└── autosave/
    └── quicksave.sav
```

**Save Metadata Example:**
```toml
[campaign]
name = "Operation Enduring Peace"
difficulty = "veteran"
ironman = false
version = "1.0.3"
playtime_seconds = 14523

[seeds]
campaign_master = "seed:campaign:20251009"
world = "seed:world:123456789"

[statistics]
missions_total = 45
missions_success = 38
soldiers_recruited = 62
aliens_killed = 342
```

**Autosave System:**
- Autosave Triggers: After missions, every 30 minutes, before major decisions
- Autosave Limit: keep last 5 autosaves, rotate oldest
- Quicksave: manual save, overwrite previous quicksave
- Ironman Mode: single save file, no manual saves, permadeath

**Save Validation:**
- Checksum Verification: detect file corruption
- Version Compatibility: migrate old saves to new versions
- Mod Compatibility: warn if mods changed/removed
- Integrity Checks: validate all references resolve correctly

---

### Geoscape Detailed Operations

**Time System Implementation:**
- Real-time with pause capability
- Speed multipliers: 1x, 2x, 5x, 30-minute leap
- Time tick every 5 minutes (12 ticks per hour)
- Events processed on scheduled ticks
- Calendar system: days, months, years tracking

**Province Management System:**
- Total Provinces: 16 global regions
- Control Percentage: 0-100% player control
- Alien Infiltration: 0-100% alien presence
- Panic Levels: low, medium, high, critical
- Funding Per Province: $50k-$1M monthly base
- Population Density: affects mission frequency
- Strategic Value: high-value provinces targeted first

**UFO Activity Patterns:**
- UFO Types: scout, fighter, harvester, terror ship, battleship, supply ship
- Mission Types: recon, research, abduction, terror, base assault, supply
- Flight Patterns: loiter, patrol, direct approach, evasive
- Altitude Layers: very low, low, high, very high
- Speed Ranges: 100 kph (slow) to 4000 kph (extremely fast)
- Detection Difficulty: stealth vs visible profiles

**Radar Detection System:**
- Short Range Radar: 600 km radius, basic detection
- Long Range Radar: 1200 km radius, advanced detection
- Hyperwave Decoder: unlimited range, full UFO identification
- Detection Probability: based on UFO size, altitude, speed
- Tracking Duration: continuous tracking vs intermittent
- Radar Cross Section: larger UFOs easier to detect

**Interception Mechanics (Detailed):**
- Launch Window: 1-10 minutes depending on distance
- Fuel Consumption: distance + combat time
- Engagement Range: weapon-dependent (50-200 km)
- Combat Rounds: 15-second increments
- Hit Probability: craft accuracy vs UFO agility
- Damage Application: weapon damage vs UFO armor
- Disengagement Rules: fuel low, damage critical, mission abort
- Multiple Craft Tactics: coordinate attacks, pincer maneuvers

**Weapon Systems (Craft):**

*Tier 1 - Conventional:*
- Cannon: 10-20 damage, 100% ammo-based, short range
- Stingray Missiles: 70 damage, 6 missiles, medium range
- Avalanche Missiles: 100 damage, 3 missiles, long range

*Tier 2 - Laser:*
- Laser Cannon: 40-60 damage, unlimited, medium range
- Plasma Beam: 80-120 damage, unlimited, long range

*Tier 3 - Fusion:*
- Fusion Ball: 150-200 damage, unlimited, very long range
- EMP Cannon: 50 damage + systems disable, unlimited

**Craft Types (Detailed):**

*Interceptor:*
- Speed: 2100 kph
- Max Weapons: 2
- Fuel Range: 2000 km
- Armor: medium
- Purpose: fast response, UFO pursuit

*Firestorm (Advanced Interceptor):*
- Speed: 3000 kph
- Max Weapons: 2
- Fuel Range: 3500 km
- Armor: heavy
- Purpose: any UFO engagement, superior performance

*Skyranger (Transport):*
- Speed: 1200 kph
- Max Weapons: 0
- Capacity: 14 soldiers + equipment
- Armor: light
- Purpose: deploy troops to ground missions

*Avenger (Ultimate Transport/Bomber):*
- Speed: 2500 kph
- Max Weapons: 2
- Capacity: 26 soldiers + equipment
- Armor: heavy
- Purpose: assault missions, late-game dominance

**Mission Generation (Geoscape):**
- Mission Types: 12 different categories
- Mission Frequency: based on alien activity level
- Mission Duration: 6 hours to 7 days before expiration
- Mission Location: province-based, bias toward high-value
- Mission Detection: radar required, some auto-detected
- Mission Priority: terror (critical), base assault (high), research (low)
- Multiple Simultaneous Missions: up to 5 active at once

**Base Building (Comprehensive):**

*Facility Types and Specifications:*
- Access Lift: $300k, instant, required, connects all facilities
- Living Quarters: $400k, 7 days, houses 50 personnel
- Laboratory: $750k, 14 days, +50 research capacity, holds 10 scientists
- Workshop: $800k, 16 days, +50 manufacturing capacity, holds 10 engineers
- Small Hangar: $200k, 6 days, holds 1 interceptor
- Large Hangar: $600k, 15 days, holds 1 transport + 2 interceptors
- General Stores: $150k, 5 days, +50 storage capacity
- Alien Containment: $400k, 10 days, holds 10 live aliens for research
- Psi Lab: $750k, 14 days, trains 10 soldiers in psionics
- Hyper-wave Decoder: $1.4M, 18 days, global UFO detection
- Grav Shield: $1.2M, 20 days, +500 base defense
- Fusion Generator: $900k, 12 days, unlimited power
- Mind Shield: $1M, 16 days, protects against psi attacks

*Base Defense Mechanics:*
- Base Vulnerability: detected by alien retaliation missions
- Defense Value: sum of facilities + soldiers + defenses
- Defense Mission: tactical combat in base facilities
- Loss Consequences: facilities destroyed, personnel killed, game over if critical

*Multi-Base Strategy:*
- Optimal Base Count: 3-6 bases for global coverage
- Specialization: research base, manufacturing base, interceptor base
- Resource Sharing: transfer items, soldiers, craft between bases
- Cost Efficiency: shared facilities reduce redundancy

---

### Economy System (Extended)

**Income Sources:**
- Monthly Funding: $500k-$8M depending on provincial support
- Mission Rewards: $10k-$500k per successful mission
- Item Sales: sell captured alien tech, manufactured goods
- Black Market: higher prices, risk of penalties
- Research Grants: bonus income for technology breakthroughs

**Expense Categories:**
- Personnel Salaries: $1M-$5M monthly depending on staff size
- Facility Maintenance: $500k-$2M monthly for all bases
- Manufacturing Materials: variable, $10k-$500k per project
- Craft Fuel and Maintenance: $50k-$200k monthly
- Research Equipment: consumable costs for research projects
- Emergency Funds: reserve for unexpected costs

**Financial Mechanics:**
- Monthly Budget Cycle: income at month start, expenses throughout
- Debt System: can go into debt up to -$10M, penalties apply
- Bankruptcy: game over if debt exceeds limit for 3 months
- Credit Rating: affects manufacturing material costs
- Economic Events: random events modify income/expenses

**Cost Examples (Detailed):**

*Personnel Monthly Salaries:*
- Soldier (Rookie): $20,000
- Soldier (Squaddie): $30,000
- Soldier (Lieutenant): $40,000
- Soldier (Captain): $60,000
- Soldier (Colonel): $100,000
- Scientist: $30,000-$50,000 (skill-based)
- Engineer: $25,000-$45,000 (skill-based)
- Support Staff: $15,000 per person

*Facility Maintenance (Monthly):*
- Access Lift: $4,000
- Living Quarters: $10,000
- Laboratory: $30,000
- Workshop: $35,000
- Small Hangar: $15,000
- Large Hangar: $25,000
- Alien Containment: $15,000
- Psi Lab: $25,000
- Hyper-wave Decoder: $50,000
- Defense Facilities: $20,000-$40,000

*Item Sale Values:*
- Alien Alloys: $3,000 per unit
- Elerium-115: $5,000 per unit
- UFO Power Source: $60,000
- Plasma Rifle: $30,000
- Alien Corpse: $1,000-$5,000 depending on type
- Live Alien: $50,000-$200,000 (high value, research bonus)

---

### AI Behavior Systems (Extended)

**Utility-Based AI Decision Making:**
- Action Scoring: 0-100 utility score per possible action
- Multi-Factor Evaluation: health, position, threats, objectives
- Randomization: ±15% variance to avoid predictability
- Personality Modifiers: aggressive, cautious, tactical personalities
- Team Coordination: group utility scores for cooperative tactics

**Personality Profiles:**

*Aggressive:*
- +30% weight to attack actions
- +20% movement toward player units
- -20% defensive positioning
- Higher risk tolerance
- Preferred by Mutons, Chryssalids

*Cautious:*
- +30% weight to defensive actions
- +20% cover seeking
- -20% offensive positioning
- Lower risk tolerance
- Preferred by Sectoids, Scientists

*Tactical:*
- Balanced weights across actions
- +30% weight to flanking maneuvers
- +20% weight to grenade usage
- Adapts to battlefield state
- Preferred by Floaters, Heavy units

*Psionic:*
- +50% weight to psi attacks when available
- Targets high-value/low-willpower enemies
- Maintains distance from threats
- Preferred by Ethereals, Sectoid Commanders

**Patrol Behavior:**
- Patrol Routes: pre-defined or procedural paths
- Patrol Speed: 50% normal movement speed
- Patrol Radius: 10-20 tiles from spawn point
- Patrol State: unaware, investigating, alert, combat
- State Transitions: triggered by sight, sound, team communication

**Target Selection (Advanced):**
- Threat Assessment: damage potential × accuracy × distance
- Opportunity Evaluation: flanking bonus, reaction fire risk
- Value Prioritization: medics > engineers > heavies > scouts
- Wounded Targeting: +50% utility for low-health targets
- Exposed Targeting: +30% utility for targets in open

**Grenade Usage Logic:**
- Grenade Types: frag, smoke, stun, acid, fire
- Usage Criteria: 2+ targets in area OR destroy cover
- Danger Evaluation: friendly fire avoidance, collateral check
- Throw Accuracy: skill-based, range penalties
- Grenade Economy: limited supply, conserve for key moments

**Reaction Fire AI:**
- Overwatch Mode: 30-50% TU reserved for reactions
- Trigger Distance: 8-15 tiles depending on weapon
- Interrupt Calculation: attacker speed vs defender reactions
- Snap Shot: lower accuracy, faster response
- Aimed Shot: higher accuracy, slower response (if TU allows)

**Team Tactics:**
- Leader Election: highest rank unit coordinates
- Group Formations: line, wedge, overwatch pairs
- Suppression Fire: pin targets while allies maneuver
- Leapfrog Advancement: alternate unit movement
- Focus Fire: concentrate attacks on single target

---

## Summary

This wiki covers a comprehensive XCOM-inspired turn-based strategy game with:

**Strategic Layer (Geoscape)**
- Global time progression with mission spawning
- Multi-faction alien invasions with adaptive AI
- Base building, research, manufacturing, and economy
- Funding, debt, score, and win/loss conditions
- Interception system bridging air and ground combat

**Tactical Layer (Battlescape)**  
- Grid-based tactical combat with action points and time units
- Rich unit systems: attributes, morale, fatigue, injuries, sanity, psionics
- Line of sight/fire, cover, suppression, reactions
- Environmental effects: smoke, fire, lighting, destructible terrain
- Utility-based AI with personality profiles

**Systems Integration**
- Deterministic simulation with seeded RNG
- Event-driven architecture with service locator
- Data-driven design with TOML configuration
- Extensive modding support with Lua scripting
- Love2D implementation with 20×20 grid standard

**Content Depth**
- Multi-world campaigns with portals
- Procedurally generated tactical maps
- Research trees unlocking technologies
- Manufacturing and resource management
- Reputation systems across multiple factions
- Lore integration with narrative campaigns

All systems designed for moddability, determinism, and balanced emergent gameplay.
