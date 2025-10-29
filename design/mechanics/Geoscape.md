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

## Mission System

### Mission Types

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
Funding = GDP × Funding_Level × Relation_Modifier × Alien_Threat_Multiplier
```

**Funding Parameters**
- **GDP**: Country economic output (static value)
- **Funding Level**: Government allocation to anti-alien programs
- **Relation Modifier**: Diplomatic standing adjustment
- **Threat Multiplier**: Increased funding during high alien activity

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

```toml
[geoscape]
monthly_cycles = true
hex_size_km = 500
max_bases = 12
radar_base_range = 8
funding_decay_rate = 0.95
panic_threshold = 75
```

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
