# Geoscape System

> **Status**: Design Document
> **Last Updated**: 2025-10-28
> **Related Systems**: Basescape.md, Crafts.md, Countries.md, Interception.md, hex_vertical_axial_system.md

## Table of Contents

- [Overview](#overview)
- [World Map System](#world-map-system)
- [Base Management](#base-management)
- [Craft System](#craft-system)
- [Mission System](#mission-system)
- [Detection & Radar](#detection--radar)
- [Diplomacy & Relations](#diplomacy--relations)
- [Alien Threat Escalation](#alien-threat-escalation)
- [Interception Combat](#interception-combat)
- [Time & Turn Management](#time--turn-management)
- [Strategic Decision Making](#strategic-decision-making)
- [Examples](#examples)
- [Balance Parameters](#balance-parameters)
- [Difficulty Scaling](#difficulty-scaling)
- [Testing Scenarios](#testing-scenarios)
- [Related Features](#related-features)
- [Implementation Notes](#implementation-notes)
- [Review Checklist](#review-checklist)

---

## Overview

### System Architecture

Geoscape is the strategic global layer where players manage their covert organization on a world scale. It operates on monthly cycles with asynchronous turn-based gameplay, where actions have realistic time delays and consequences ripple through the global theater. The system emphasizes strategic positioning, resource allocation, and long-term planning in response to escalating alien threats.

**Design Philosophy**

Geoscape creates meaningful strategic depth through interconnected systems: base placement affects radar coverage and interception range; diplomatic relations influence funding and mission availability; craft positioning determines response capability. The monthly timescale encourages careful planning while maintaining engagement through procedurally generated events and escalating threats.

**Core Principle**: Global strategic management with territorial control and resource optimization.

---

## World Map System

### Hexagonal Grid

The world is represented as a 90×45 hexagonal grid, with each hex representing approximately 500km of Earth territory. Hexes are organized into provinces (groups of 6-12 hexes) and regions (collections of provinces sharing cultural/geographic characteristics).

**Hex Properties**
- **Terrain**: Affects movement costs, base construction viability, and mission generation
- **Population**: Influences mission frequency and diplomatic importance
- **Resources**: Strategic materials available for base construction and research
- **Ownership**: Country affiliation affects diplomatic relations and funding

**Map Generation**
- Procedural continent formation with realistic geography
- Strategic choke points and defensible positions
- Balanced resource distribution across regions
- Cultural and political boundaries reflecting real-world divisions

### Province System

Provinces serve as the primary territorial unit for strategic gameplay:

**Province Control**
- One base per province (exclusive territorial occupation)
- Province ownership affects regional diplomacy
- Control provides access to local resources and population
- Loss of control triggers diplomatic penalties

**Strategic Value**
- Population density affects funding potential
- Geographic position influences interception coverage
- Resource availability impacts base efficiency
- Political alignment affects mission generation

---

## Base Management

### Base Placement Strategy

Bases are permanent installations providing operational hubs for the player's organization. Strategic placement is critical for maximizing radar coverage, interception range, and resource access.

**Placement Rules**
- One base per province maximum
- Construction requires clear hex (no mountains, cities, or alien bases)
- Adjacent hexes provide adjacency bonuses
- Distance from other bases affects operational efficiency

**Base Functions**
- **Radar Coverage**: Detection radius for UFOs and missions
- **Craft Operations**: Launch/recovery facilities for spacecraft
- **Resource Processing**: Salvage refinement and storage
- **Personnel Housing**: Unit recruitment and training facilities

### Base Expansion

Bases grow through facility construction and territory control:

**Growth Mechanics**
- Initial construction establishes core facilities
- Expansion adds specialized capabilities
- Territory control extends operational range
- Research unlocks advanced base technologies

---

## Craft System

### Craft Types

Crafts are the player's mobile assets capable of global deployment, interception, and ground operations.

**Craft Categories**
- **Interceptors**: Fast, lightly armed craft for air-to-air combat
- **Transports**: Heavily armed craft for ground deployment and salvage
- **Heavy Transports**: Large capacity craft for base construction and major operations
- **Specialized Craft**: Research vessels, stealth craft, and experimental designs

**Craft Statistics**
- **Speed**: Movement points per turn on geoscape
- **Range**: Operational distance before requiring refuel
- **Capacity**: Number of units or equipment carried
- **Weapons**: Air-to-air combat effectiveness
- **Armor**: Damage resistance in combat

### Movement & Deployment

Craft movement follows realistic aviation mechanics with fuel consumption and maintenance requirements.

**Movement System**
- Hex-based movement with terrain modifiers
- Fuel consumption based on distance and craft type
- Maintenance cycles requiring base downtime
- Weather effects on operational capability

**Deployment States**
- **Base**: Stationed at friendly base, ready for immediate launch
- **Transit**: Moving between locations, vulnerable to interception
- **Mission**: Engaged in active operations
- **Recovery**: Returning to base, reduced capability

---

## COMPREHENSIVE GEOSCAPE SPECIFICATIONS (A2, A8, R5, C3, B3)

### A2: PORTAL SYSTEM SPECIFICATION

**Overview**: Portals are research-gated teleportation structures enabling instantaneous base-to-base travel, fundamentally altering strategic mobility.

**Portal Mechanics**:

**Portal Activation**:
- Requires research technology: "Portal Network" (tier 3 research)
- Cost: 50,000 credits to construct portal network infrastructure at single base
- Build time: 30 days
- One portal per base (max 2 portals per player)

**Portal Functionality**:
- **Teleportation**: Transfer units or equipment between portal-connected bases instantly (same turn)
- **Resource Transfer**: Move resources automatically between portals (supply transfer automated)
- **Craft Recall**: Bring damaged craft back instantly without fuel/travel time
- **No Combat**: Cannot transport units mid-mission or in active combat

**Travel via Portal**:
```
Portal Travel Cost:
- Activation: 5,000 credits per use (operational energy cost)
- Capacity: Up to 10 units or 5,000 kg equipment per transport
- Duration: Instant (same turn execution)
- Cooldown: None (can use multiple times per turn if credits available)
```

**Strategic Implications**:
- Enables rapid response to crises
- Reduces mobility advantage of multiple bases
- Creates economic cost (5,000 credits per use) balancing instant travel
- Late-game tech rewards strategic patience with early-game infrastructure investment

**Portal Network Limitations**:
- Must have both source and destination portals active
- Cannot transport craft (only units/equipment)
- Cannot bypass interception range (craft still require normal travel)
- Disabled if either portal facility damaged

---

### A8: WEATHER SYSTEM INTEGRATION

**Overview**: Weather affects geoscape visibility, craft movement, and mission generation.

**Weather Types**:

| Weather | Generation | Duration | Geoscape Impact | Mission Impact |
|---------|-----------|----------|-----------------|-----------------|
| **Clear** | 40% probability | 2-4 weeks | Normal visibility (100%) | Normal difficulty |
| **Rain** | 30% probability | 1-2 weeks | Reduced visibility (75%) | +10% alien difficulty |
| **Storm** | 20% probability | 3-5 days | Greatly reduced (50%) | +20% difficulty, -20% accuracy |
| **Snow** | 5% probability | 2-3 weeks | Severely reduced (25%) | +30% difficulty, mission may be blocked |
| **Blizzard** | 3% probability | 1 week | Extreme (10%) | All missions blocked, craft grounded |
| **Seasonal** | Tied to season | ~3 months | Regional modifiers | Affects mission types available |

**Seasonal Cycles** (Modder-Configurable):
- **Spring**: Rain, moderate temperatures, mixed missions
- **Summer**: Clear weather, high visibility, alien activity escalates
- **Fall**: Storm risk, moderate conditions, balanced missions
- **Winter**: Snow/blizzard risk, low visibility, reduced alien activity

**Geoscape Visibility Impact**:
- Clear weather: Full radar range + mission visibility
- Rain: Radar range −25%, UFO detection −15%
- Storm: Radar range −50%, UFO detection −30%
- Snow: Radar range −75%, UFO detection −50%
- Blizzard: No radar operation, all missions blocked

**Mission Generation**:
- Clear: All mission types available
- Rain/Storm: Terror missions increase (aliens attack despite weather)
- Snow: Reduced mission frequency (−50%)
- Blizzard: NO missions generated (all alien activity halted)

**Weather Modifiers in Battlescape** (See Battlescape.md):
- Apply to combat accuracy, sight ranges, movement costs
- Blizzard: −3 sight per tile, +3 movement cost per tile, −20% accuracy
- Snow: −2 sight, +2 movement, −15% accuracy
- Rain: −1 sight, +1 movement, −10% accuracy

---

### R5: CAMPAIGN STRUCTURE SPECIFICATION

**Overview**: Campaign structure defines predefined mission arcs and strategic narrative progression.

**Campaign Phases**:

| Phase | Months | Threat Level | Key Events | Alien Activity |
|-------|--------|--------------|-----------|-----------------|
| **Phase 1: Contact** | 1-3 | Low | First UFO sightings, base construction | Scout ships (minimal damage) |
| **Phase 2: Escalation** | 4-8 | Moderate | Resource competition, diplomacy strain | Increased interception, terror missions |
| **Phase 3: Crisis** | 9-14 | High | Major alien push, base attacks | Coordinated attacks, reinforcements |
| **Phase 4: Climax** | 15+ | Extreme | Final alien assault, endgame decision | Mothership arrival, apocalyptic choices |

**Predefined Mission Arcs**:

**Arc 1: Outbreak (Phase 1)**
- Trigger: Campaign start
- Missions: 3-5 crash recovery, 2-3 terror defense
- Reward: Research data, initial alien tech
- Narrative: Humanity first encounters aliens

**Arc 2: Alien Research (Phase 2)**
- Trigger: After 100,000 damage dealt to aliens
- Missions: Investigation missions, artifact recovery
- Reward: Advanced research data, unique weapons
- Narrative: Discovering alien origins

**Arc 3: Base Defense (Phase 3)**
- Trigger: After 3rd alien base discovered
- Missions: Base assault, capture aliens
- Reward: Prisoners, high-tech equipment
- Narrative: Coordinated offensive against aliens

**Arc 4: Final Reckoning (Phase 4)**
- Trigger: When alien threat reaches 100%
- Missions: Assault mothership, prevent invasion
- Reward: Ending-determining missions
- Narrative: Humanity's last stand

**Strategic Checkpoints**:
- Month 3: First major UFO battle
- Month 6: Second base pressure
- Month 9: Alien base discovered
- Month 12: Invasion warning detected
- Month 15: Potential endgame trigger

---

### C3: STEALTH MECHANICS BUDGET SYSTEM

**Overview**: Stealth missions use a "stealth budget" limiting how many overt actions before discovery.

**Stealth Budget Mechanics**:

**Budget Definition**:
- Missions with stealth objectives: 0-100 stealth budget points
- Units on mission share one budget (team resource, not individual)
- Budget depletes with each visible action
- When budget reaches 0: Mission shifts from stealth to combat

**Budget Depletion**:

| Action | Cost | Condition |
|--------|------|-----------|
| **Moving in open** | 1 point/hex | Not in cover, enemy visible |
| **Firing weapon** | 10 points | Ranged attack outside cover |
| **Grenades/explosives** | 25 points | Area-effect weapon use |
| **Melee attack** | 5 points | Close combat engagement |
| **Running** | 3 points/hex | Fast movement (loud) |
| **Sneaking** | 0 points | Slow careful movement |
| **Stealth kill** | 0 points | Melee from concealment |
| **Alert guard** | 20 points | Guard spots unit and sounds alarm |
| **Alarms triggered** | 50 points | Facility alarm activated |

**Stealth Status**:
- **Undetected** (100-76%): Normal operations
- **Suspicious** (75-51%): Enemies on alert but not engaged
- **Compromised** (50-26%): Direct enemy contact, combat imminent
- **Discovered** (25-0%): Combat begins, stealth mission failed
- **Combat** (0%): Full enemy engagement, stealth advantage lost

**Budget Example**:
```
Mission: Infiltrate alien base, steal artifact
Starting Budget: 80 points
Action Sequence:
  - Move 3 hexes in open (unseen): 0 points
  - Sneak 5 hexes to guard: 0 points (sneaking = free)
  - Stealth kill guard: 0 points (melee from concealment)
  - Open secured door: 0 points (silent action)
  - Grab artifact and move to exit: 0 points
  - Sneak 8 hexes to extraction point: 0 points
  Final Budget: 80 points (mission success!)

Alternative Sequence:
  - Move 3 hexes in open: 3 points
  - Guard spots unit: 20 points alert
  - Fire rifle (loud): 10 points
  - Grenade explosion: 25 points
  - Alarm triggered: 50 points
  Final Budget: −13 points (discovered! Combat begins)
```

**Stealth Reward**:
- Mission completion with budget 50+: Mission bonus (+500 XP, +10,000 credits)
- Mission completion with budget 0-49: Standard rewards only
- Budget negative: Mission failed (objectives incomplete)

---

### B3: CRAFT MOVEMENT & INTERCEPTION LAYER

**Overview**: Craft movement represents mobile deployment on geoscape and vulnerability to interception.

**Craft Movement Mechanics**:

**Movement Points**:
```
Movement Per Turn = Craft Speed × Fuel Available
Fuel Cost = Distance Traveled × Fuel Efficiency
```

**Craft Speed Categories**:

| Craft Type | Speed (hexes/turn) | Fuel Capacity | Range |
|-----------|-------------------|---------------|-------|
| **Fighter** | 8 | 200 | 1,600 km (16 hexes × ~100km) |
| **Interceptor** | 10 | 250 | 2,500 km |
| **Transport** | 4 | 400 | 1,600 km |
| **Bomber** | 3 | 500 | 1,500 km |
| **Capital** | 2 | 800 | 1,600 km |

**Interception Points** (Vulnerability):

When craft move, they become vulnerable to interception:

| Movement | Interception Risk | Detection Chance |
|----------|------------------|------------------|
| **Base to destination (direct)** | High | +100% (enemy alerted) |
| **Stealth route (avoiding radar)** | Medium | +50% |
| **High altitude (fastest)** | High | +100% (visible) |
| **Low altitude (slowest)** | Low | +30% (harder to spot) |
| **At base (stationary)** | None | 0% |

**Interception Combat**:
- Craft engaged by enemy interceptors: Forces air-to-air combat
- Damage reduces craft capability temporarily
- Surviving damaged craft can return to base (reduced speed)
- Destroyed craft lost with all equipment/units

**Fuel Management**:
- Each hex movement costs fuel
- Fuel regenerates 50% per turn at base (limited by base capacity)
- Empty fuel: Craft crashes or limps home (very slow)
- Range = Fuel Capacity ÷ Movement Distance

**Strategic Implications**:
- Craft position creates response time (closer bases = faster response)
- Interception risk forces strategic choices (fast/exposed vs slow/safe routes)
- Fuel management creates economic pressure (more bases = distributed response)
- Multi-craft coordination enables coordinated strikes

**Craft Movement Example**:
```
Fighter at Base A, need to reach Base C (6 hexes away)

Option 1: Direct Route
- Speed: 8 hexes/turn
- Distance: 6 hexes
- Time: 1 turn
- Fuel: 6 × 12.5% = 75% of tank
- Interception Risk: HIGH (+100%, visible approach)

Option 2: Stealth Route (avoiding radar coverage)
- Speed: 4 hexes/turn (low altitude, slower)
- Distance: 8 hexes (indirect path)
- Time: 2 turns
- Fuel: 8 × 12.5% = 100% of tank (refuel at waypoint)
- Interception Risk: MEDIUM (+50%, harder to detect)

Player chooses based on urgency vs safety
```

---

## Mission System

### Mission Types

**Source Reference**: CRAFT_CAPACITY_MODEL.md §Squad Composition & Deployment

Missions represent alien activities requiring player intervention, generated procedurally based on global threat levels and player actions.

**Primary Mission Types**
- **UFO Crash Recovery**: Salvage alien technology from crashed spacecraft
- **Terror Missions**: Protect civilian populations from alien attacks
- **Alien Base Assault**: Destroy established alien installations
- **Research Missions**: Investigate unusual alien activities
- **Escort Missions**: Protect VIPs or critical transports

**Mission Parameters**
- **Difficulty**: Based on alien technology level and player preparedness
- **Time Limit**: Mission expiration affects success/failure consequences
- **Rewards**: Salvage value, research data, diplomatic impact
- **Risks**: Unit casualties, base damage, diplomatic penalties

### Mission Generation

Missions spawn based on algorithmic threat assessment:

**Generation Factors**
- **Alien Activity Level**: Higher threat increases mission frequency
- **Player Detection**: Undetected UFOs generate crash recovery missions
- **Geographic Factors**: Population centers attract terror missions
- **Diplomacy Status**: Friendly nations request assistance missions

---

## Detection & Radar

### Radar Coverage System

Radar systems provide the primary method of detecting alien activity, with coverage determined by base placement and technology level.

**Radar Mechanics**
- **Coverage Radius**: Detection range in hexes from base location
- **Detection Probability**: Chance to spot UFOs within range
- **False Positives**: Weather and terrain affect accuracy
- **Technology Bonuses**: Research improves detection capability

**Detection States**
- **Undetected**: UFO operates freely, may complete missions
- **Detected**: UFO visible on geoscape, interception possible
- **Tracked**: UFO position and trajectory known
- **Intercepted**: Player craft engaged with UFO

### Stealth & Counter-Detection

Advanced alien craft employ stealth technology requiring upgraded detection systems.

**Stealth Mechanics**
- **Stealth Level**: UFO ability to avoid radar detection
- **Detection Threshold**: Required radar technology to spot craft
- **Jamming**: Some UFOs can temporarily disable local radar
- **Terrain Masking**: Geographic features provide natural concealment

---

## Diplomacy & Relations

### Country Relations System

Diplomatic relations with global powers provide funding, resources, and strategic advantages.

**Relation Levels**
- **Allied**: Full funding, shared intelligence, joint operations
- **Friendly**: Standard funding, marketplace access, mission requests
- **Neutral**: Reduced funding, limited marketplace, occasional missions
- **Unfriendly**: Minimal funding, restricted access, diplomatic penalties
- **Hostile**: No funding, blocked territories, active opposition

**Relation Modifiers**
- **Mission Success**: Successful operations improve relations
- **Alien Activity**: Failed missions damage diplomatic standing
- **Base Placement**: Strategic positioning affects local relations
- **Economic Support**: Funding levels influence diplomatic warmth

### Funding Mechanics

Countries provide monthly funding based on diplomatic relations and economic factors.

**Funding Formula**
```
Funding = Funding_Level × Relation_Modifier × Alien_Threat_Multiplier
```

**Funding Parameters**
- **Funding Level**: Absolute amount per country (10K-125K based on economic strength)
- **Relation Modifier**: Diplomatic standing adjustment (0.5x to 2.0x)
- **Threat Multiplier**: Increased funding during high alien activity (1.0x to 1.5x)

**Starting Capital**
New campaigns begin with initial capital reserves to fund early operations:

| Difficulty | Starting Capital | Purpose |
|------------|------------------|---------|
| **Easy** | 750,000 credits | Generous starting funds for relaxed early game |
| **Normal** | 500,000 credits | Balanced starting position requiring good management |
| **Hard** | 250,000 credits | Tight budget emphasizing strategic resource allocation |
| **Impossible** | 100,000 credits | Extreme challenge requiring immediate mission success |

---

## Alien Threat Escalation

### Threat Progression

Alien activity escalates over time, increasing in frequency and sophistication.

**Escalation Phases**
- **Phase 1 (Months 1-3)**: Scouting missions, basic UFOs
- **Phase 2 (Months 4-6)**: Terror operations, improved craft
- **Phase 3 (Months 7-9)**: Base construction, advanced technology
- **Phase 4 (Months 10+)**: Invasion preparation, elite units

**Progression Triggers**
- **Time-Based**: Automatic advancement every few months
- **Activity-Based**: Accelerated by failed missions and low detection
- **Technology-Based**: Advanced alien research unlocks new capabilities

### Global Panic System

Civilian populations react to alien activity with escalating panic levels.

**Panic Mechanics**
- **Local Panic**: Province-level reaction to nearby activity
- **National Panic**: Country-wide response affecting funding
- **Global Panic**: World-spanning events triggering major consequences

**Panic Effects**
- **Funding Reduction**: Lower government allocations
- **Mission Generation**: Increased terror and investigation missions
- **Diplomatic Strain**: Worsening relations with affected countries
- **Country Collapse**: Extreme panic leads to government breakdown

---

## Interception Combat

### Air-to-Air Combat

Interception represents aerial engagements between player craft and alien UFOs.

**Combat Resolution**
- **Range Engagement**: Long-range missile combat
- **Dogfighting**: Close-range maneuvering combat
- **Damage Systems**: Progressive craft degradation
- **Escape Mechanics**: UFOs may flee or self-destruct

**Tactical Factors**
- **Craft Performance**: Speed, weapons, and armor ratings
- **Pilot Skill**: Crew experience affects combat effectiveness
- **Technology Difference**: Equipment advantages/disadvantages
- **Environmental Effects**: Weather impact on combat

### Combat Outcomes

Engagement results determine mission progression and strategic consequences.

**Victory Conditions**
- **UFO Destruction**: Full salvage recovery, research data
- **UFO Damage**: Partial recovery, reduced rewards
- **UFO Escape**: Mission continues, diplomatic penalties
- **Craft Loss**: Unit casualties, equipment destruction

---

## Time & Turn Management

### Monthly Cycle System

Geoscape operates on a monthly turn structure with asynchronous action resolution.

**Turn Phases**
1. **Action Declaration**: Player commits to missions and movements
2. **Time Advancement**: Actions resolve over days/weeks
3. **Event Resolution**: Missions complete, funding received
4. **Status Updates**: Relations change, panic levels adjust

**Time Delays**
- **Craft Movement**: Hours to days based on distance
- **Mission Resolution**: Days to weeks based on complexity
- **Base Construction**: Weeks to months for completion
- **Research Projects**: Months for major breakthroughs

### Asynchronous Gameplay

Actions resolve independently, allowing strategic planning without real-time pressure.

**Resolution Mechanics**
- **Parallel Processing**: Multiple actions resolve simultaneously
- **Interrupt Handling**: Critical events can alter planned actions
- **Save/Load System**: Preserve game state between sessions
- **Replay Capability**: Review past decisions and outcomes

---

## Strategic Decision Making

### Resource Allocation

Players must balance multiple competing priorities across the global theater.

**Strategic Trade-offs**
- **Coverage vs. Concentration**: Widespread bases vs. concentrated strength
- **Offense vs. Defense**: Aggressive interception vs. base protection
- **Research vs. Operations**: Technology investment vs. immediate threats
- **Diplomacy vs. Action**: Political management vs. military operations

### Long-term Planning

Geoscape rewards strategic foresight and adaptive planning.

**Planning Horizons**
- **Tactical**: Immediate mission response and craft deployment
- **Operational**: Base placement and radar coverage optimization
- **Strategic**: Research priorities and diplomatic management
- **Campaign**: Long-term victory conditions and organizational growth

### Victory Conditions

Open-ended gameplay allows multiple paths to success.

**Potential Objectives**
- **Elimination**: Destroy all alien threats and bases
- **Containment**: Reduce alien activity to minimal levels
- **Technological**: Research all available alien technology
- **Diplomatic**: Achieve maximum funding from all nations
- **Exploration**: Discover and investigate all alien activities

---

## Configuration

### TOML Structure

Geoscape systems are configured through TOML files in `mods/core/geoscape/`.

**Key Configuration Files**
- `world.toml`: Map generation parameters and terrain data
- `missions.toml`: Mission types, frequencies, and rewards
- `craft.toml`: Craft specifications and performance data
- `radar.toml`: Detection systems and coverage calculations

### Balance Parameters

Critical values affecting gameplay difficulty and pacing:

**Geoscape System Configuration**:
- Monthly cycle operation (campaign progresses monthly)
- Hex grid scale (500 km per hex)
- Maximum simultaneous bases per player (12)
- Radar detection range baseline (8 hexes)
- Funding decay rate over time (0.95x multiplier)
- Panic threshold for triggering endgame events (75% world panic)

---

## Integration Points

### Battlescape Connection
- Mission deployment transitions to tactical combat
- Unit performance affects strategic outcomes
- Salvage recovery impacts research and manufacturing

### Basescape Connection
- Base facilities provide geoscape capabilities
- Research unlocks improved craft and detection
- Manufacturing produces equipment for operations

### Economy Integration
- Funding provides operational budget
- Salvage drives research and production
- Marketplace affects equipment availability

### Politics Integration
- Diplomatic relations influence funding and access
- Country panic affects global stability
- International cooperation enables joint operations</content>
<parameter name="filePath">c:\Users\tombl\Documents\Projects\design\mechanics\Geoscape.md
---
## Related Content
**For detailed information, see**:
- **Basescape.md** - Base construction and facility management
- **Missions.md** - Mission types, generation, and objectives
- **Countries.md** - Country mechanics and funding
- **Crafts.md** - Craft deployment and movement
- **Interception.md** - UFO interception mechanics
- **HexSystem.md** - Coordinate system for world map
- **Politics.md** - Diplomatic relations and factions
- **Finance.md** - Economic systems and budgeting
---
## Implementation Notes
**Priority Systems**:
1. World map hex grid (90�45 hexes)
2. Province and region system
3. Base placement mechanics
4. Craft movement and deployment
5. Mission detection and radar
6. Time management and turn progression
**Balance Considerations**:
- World map size should allow strategic positioning
- Radar coverage should create meaningful gaps
- Travel time should matter tactically
- Base placement should be permanent decision
**Testing Focus**:
- Hex coordinate calculations
- Pathfinding across oceans and terrain
- Radar overlap and gaps
- Mission spawn distribution

---

## Examples

### Scenario 1: Strategic Base Placement
**Setup**: Starting campaign with limited funding, need to establish first base
**Action**: Analyze world map for optimal location balancing radar coverage, resource access, and diplomatic relations
**Result**: Base placed in allied territory with good radar overlap, enabling early mission detection and interception

### Scenario 2: Craft Deployment Dilemma
**Setup**: Multiple missions spawn simultaneously across different regions
**Action**: Position crafts strategically to respond to highest-priority threats while maintaining patrol coverage
**Result**: Successful interception of key UFO while secondary missions are handled by repositioned assets

### Scenario 3: Escalation Response
**Setup**: Alien threat escalates, multiple bases under threat
**Action**: Deploy crafts for defense, reposition assets, manage diplomatic fallout from failed missions
**Result**: Strategic withdrawal from untenable positions, consolidation of forces for key defensive actions

### Scenario 4: Global Resource Management
**Setup**: Multiple bases operational, competing for limited funding and resources
**Action**: Allocate funding strategically, prioritize research and production based on threat assessment
**Result**: Balanced development across bases, optimized for current campaign phase

---

## Balance Parameters

| Parameter | Value | Range | Reasoning | Difficulty Scaling |
|-----------|-------|-------|-----------|-------------------|
| World Map Size | 90×45 hexes | 60×30 to 120×60 | Strategic depth vs. complexity | No scaling |
| Base Construction Cost | 50,000 credits | 25K-100K | Permanent commitment | ×0.8 on Easy |
| Radar Coverage Radius | 8 hexes | 4-12 | Detection capability | +2 on Hard |
| Craft Movement Speed | 2 hexes/hour | 1-4 | Response time balance | ×1.5 on Impossible |
| Monthly Funding Base | 10,000 credits | 5K-20K | Operational budget | ×0.7 on Easy |
| Mission Spawn Rate | 3-5 per month | 1-8 | Challenge frequency | +1 per difficulty level |
| Alien Escalation Rate | +0.2 per month | 0.1-0.5 | Threat progression | ×1.5 on Hard |

---

## Difficulty Scaling

### Easy Mode
- Base construction costs: 20% reduction
- Monthly funding: +30% increase
- Radar coverage: +2 hexes bonus
- Mission frequency: 2-3 per month
- Alien escalation: 30% slower

### Normal Mode
- All parameters at standard values
- Balanced strategic challenge
- Standard resource management
- Normal threat progression

### Hard Mode
- Base construction costs: +25% increase
- Monthly funding: -20% reduction
- Radar coverage: -2 hexes penalty
- Mission frequency: 4-6 per month
- Alien escalation: 25% faster

### Impossible Mode
- Base construction costs: +50% increase
- Monthly funding: -40% reduction
- Radar coverage: -4 hexes penalty
- Mission frequency: 5-8 per month
- Alien escalation: 50% faster
- Craft movement: 25% slower

---

## Testing Scenarios

- [ ] **Hex Grid Navigation**: Verify coordinate calculations and pathfinding work correctly
  - **Setup**: Create test world map with known hex coordinates
  - **Action**: Calculate paths between various points
  - **Expected**: Accurate distance calculations and valid movement paths
  - **Verify**: Compare calculated vs. expected hex distances

- [ ] **Radar Coverage Overlap**: Test that radar coverage creates meaningful strategic gaps
  - **Setup**: Place multiple bases with radar facilities
  - **Action**: Calculate total coverage area and gaps
  - **Expected**: Strategic positioning matters for mission detection
  - **Verify**: Coverage maps show realistic overlap and blind spots

- [ ] **Craft Movement Timing**: Verify travel times affect tactical decision making
  - **Setup**: Craft at base, mission spawns at distance
  - **Action**: Calculate travel time and interception window
  - **Expected**: Distance creates meaningful response delays
  - **Verify**: Travel time calculations match expected values

- [ ] **Resource Allocation**: Test funding distribution across multiple bases
  - **Setup**: Three bases with different priorities
  - **Action**: Allocate monthly budget strategically
  - **Expected**: Resource management creates meaningful trade-offs
  - **Verify**: Budget calculations and facility construction

- [ ] **Mission Spawn Distribution**: Verify missions spawn in appropriate regions
  - **Setup**: Run mission generation over multiple months
  - **Action**: Analyze spawn locations and frequencies
  - **Expected**: Missions cluster in high-threat areas
  - **Verify**: Statistical distribution matches design parameters

---

## Related Features

- **[Basescape System]**: Base construction and facility management (Basescape.md)
- **[Mission System]**: Mission types, generation, and objectives (Missions.md)
- **[Countries System]**: Diplomatic relations and funding (Countries.md)
- **[Crafts System]**: Craft deployment and movement mechanics (Crafts.md)
- **[Interception System]**: UFO interception combat (Interception.md)
- **[Hex System]**: World map coordinate system (HexSystem.md)
- **[Politics System]**: Diplomatic relations and factions (Politics.md)
- **[Finance System]**: Economic systems and budgeting (Finance.md)

---

## Review Checklist

- [ ] World map system clearly defined with hex grid mechanics
- [ ] Base management integration with facilities and radar
- [ ] Craft system deployment and movement mechanics specified
- [ ] Mission detection and radar coverage calculations detailed
- [ ] Diplomacy and relations mechanics documented
- [ ] Alien threat escalation system balanced
- [ ] Time management and turn progression implemented
- [ ] Strategic decision making framework established
- [ ] Balance parameters quantified with reasoning
- [ ] Difficulty scaling implemented across all systems
- [ ] Testing scenarios comprehensive and testable
- [ ] Related systems properly linked
- [ ] No undefined terminology
- [ ] Implementation feasible
