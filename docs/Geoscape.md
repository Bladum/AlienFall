## Geoscape

### Overview

The Geoscape is the strategic layer of the game, representing the global view of military operations across the entire world. It combines elements from games like Eador, Heroes of Might and Magic, and Europa Universalis, where player craft function as heroes commanding armies (units), moving across a defined world map. The Geoscape manages base locations, mission generation, craft deployment, radar detection, and strategic decision-making at the macro level.

**Design Philosophy**
The Geoscape emphasizes strategic planning and resource allocation. Players must balance multiple objectives: base expansion, craft deployment, mission interception, country relationships, and long-term territorial control. The system supports multiple playstyles from aggressive expansion to defensive consolidation.

---

### Universe System

**Overview**
The Universe manages all worlds and inter-world connectivity. Multiple independent worlds exist simultaneously, each with their own geopolitical situation and mission generation. Portals provide limited inter-world travel.

**Multi-World Mechanics**
- **Multiple Worlds**: Earth is primary world; others include alien homeworlds, colonized planets, orbital stations
- **Inter-World Distances**: Game tracks distance between worlds for travel calculations
- **Portal Network**: Limited connection points between worlds enable strategic routing
- **Dimensional Constraints**: Not all worlds are accessible simultaneously; progression unlocks new worlds
- **World States**: Each world maintains independent campaign states, mission generation, and faction presence
- **Parallel Operations**: Multiple worlds operate simultaneously; player must divide attention

**Strategic Implication**
Managing multiple active worlds provides additional complexity and strategic depth. Players must prioritize resource allocation across worlds.

**World Switching Mechanics**
- Portal access enables instant world transitions
- Resources/craft remain on original world; cannot be transported between worlds without special mechanics
- Funding allocation considers performance on all worlds
- Research applies globally but mission threats are world-specific

---

### World System

**Overview**
A World is a complete strategic map represented as a 2D hexagonal grid. Earth is the primary world (90×45 hex tiles, each representing 500km). Multiple worlds exist with varying sizes and configurations.

**World Structure**
- **Grid System**: Hexagonal tile grid providing clear tactical positioning
- **Scale**: Earth = 90×45 hexes (typical: 4,050 total provinces)
- **Tile Resolution**: Each hex ≈ 500km on Earth
- **Province Container**: Each world contains complete list of all provinces
- **World Properties**: Unique biome sets, faction presence, accessibility restrictions

**World Data Management**
- Worlds are loaded from configuration files (e.g., earth.toml)
- Persistent world state tracked across game sessions
- Province ownership, base locations, and mission states persist
- Campaign progression maintained per-world

**Multiple Worlds**
- Earth: Primary starting world
- Alien Homeworlds: Enemy faction homelands
- Space Stations: Orbital facilities above planets
- Colonies: Distant human outposts
- Mysterious Locations: Late-game discovered worlds

**World Transitions**
- Players can switch between active worlds via portals
- Day/night cycle synchronized across all worlds
- Calendar events apply globally even when on different worlds
- Campaign generation happens independently per world

---

### World Renderer

**Overview**
The World Renderer displays the hexagonal map with visual clarity and strategic information overlay. It supports multiple display modes to convey different information layers.

**Rendering Features**
- **Hexagonal Map Display**: Clear hex grid visualization
- **Mouse Zoom**: Player can zoom in/out to adjust tactical vs. strategic view
- **Province Positioning**: Provinces occupy specific hex positions
- **Capital Highlighting**: Regional capital cities highlight their sector
- **Visual Clarity**: Hex grid layout prevents positioning ambiguity

**Information Display Modes**
The map can display different overlay modes, similar to Europa Universalis strategic map colors:

| Display Mode | Shows | Purpose |
|---|---|---|
| **Political** | Country borders, relationships | Diplomatic overview |
| **Relations** | Supplier/faction relationships, colors | Diplomatic status |
| **Resources** | Resource distribution, availability | Economic planning |
| **Bases** | Player/enemy base locations, levels | Military overview |
| **Missions** | Active missions, mission types, icons | Threat assessment |
| **Score** | Regional score levels, progress bars | Performance tracking |
| **Biome** | Terrain types, climate zones, features | Environmental context |

**Strategic Utility**
Color-coded overlays allow players to quickly assess situations and make informed decisions without menu diving.

---

### World Tile System

**Overview**
World Tiles are the individual hexagonal cells comprising the world map. Each tile has terrain properties affecting movement costs and gameplay mechanics. Tiles themselves are not gameplay entities but support pathfinding and rendering.

**Tile Terrain Types**
- **Water**: Ocean, lakes, rivers; allows naval movement only
- **Land**: Grassland, plains; default traversable terrain
- **Land Rough**: Hills, foothills; moderate movement penalty
- **Land Very Rough**: Mountains, volcanic; high movement penalty, restricted access

**Movement Cost Impact**
Terrain affects craft travel speed and movement point expenditure. Rough terrain slows movement, creating tactical positioning considerations.

**Gameplay Integration**
- World tiles are NOT used for individual gameplay actions
- Primarily support pathfinding and shortest-route calculation
- Enable terrain-based movement costs
- Provide visual map representation

---

### World Path System

**Overview**
World Paths are pre-calculated shortest routes between two provinces for specific craft types. They optimize travel by accounting for craft-specific movement capabilities (aircraft vs. naval vs. ground).

**Path Calculation**
- **Craft-Type Specific**: Different paths for air, water, and ground movement
- **Shortest Route**: Dijkstra or A* pathfinding algorithm
- **Tile Optimization**: Uses world tile terrain costs
- **Dynamic Updates**: Recalculated when world state changes significantly

**Craft Type Paths**
- **Air Routes**: Direct line-of-sight paths, ignoring terrain
- **Water Routes**: Naval-only paths following coastal and ocean routes
- **Ground Routes**: Land-only paths avoiding water, using least-resistance terrain

**Strategic Use**
- Determines craft range: Maximum distance = Craft Speed × Available Movement Points
- Shows available deployment zones for missions
- Enables players to plan efficient routes
- Reveals strategically important chokepoints

---

### Province System

**Overview**
Provinces are the fundamental entities of the Geoscape. Each province is a graph node capable of containing bases, missions, and craft. Provinces are the primary target of strategic operations and diplomatic relations.

**Province Components**
- **Location**: Fixed hexagonal grid position
- **Base Slot**: Can contain single player base
- **Mission Capacity**: Can host multiple enemy missions (sites, UFOs, bases)
- **Craft Capacity**: Can host multiple player craft (no limit)
- **Economy**: Contributes to country economic power
- **Biome**: Defines environmental properties
- **Population**: Population density affects mission generation
- **Satisfaction**: Public morale in province

**Province Identity**
Provinces are uniquely identifiable and persistent. Player decisions affect province state permanently until reversed (base destruction, mission completion, etc.).

**Province Connections**
- Provinces connect to adjacent provinces via hex grid
- Travel cost between provinces varies based on terrain
- Some connections blocked (water/land restrictions)
- Connection costs affect optimal pathfinding

**Provincial Economy**
- Each province produces monthly income
- Income based on population and development
- Player organization receives percentage of income
- Enemy factions also claim portions of provincial economies
- Can establish trade agreements to redirect revenue

**Strategic Importance**
- Base construction locks province to one base per location
- Mission generation concentrates in specific provinces based on faction preference
- Province control indicates strategic territory ownership
- Multiple provinces form regions for scoring and governance
- Upgrading province facilities increases economic output
- Well-developed provinces attract more player investment

---

### Biome System

**Overview**
Biomes define the environmental characteristics of provinces, affecting gameplay mechanics, visuals, and available mission types. Each province has exactly one biome classification.

**Biome Properties**
Each biome determines:

| Property | Impact |
|---|---|
| **Fauna/Flora** | Visual appearance; mission lore flavor |
| **Terrain Type** | Battlescape map generation options |
| **Interception Background** | Aerial combat environment appearance |
| **Land Battlescape Terrain** | Available terrain types for ground combat |
| **Water/Land Classification** | Movement capabilities; naval vs. land focus |
| **Mission Type Probability** | Likelihood of specific mission types |
| **Biome Hazards** | Environmental damage during missions |
| **Resource Density** | Salvage/loot availability per mission |

**Available Biomes**
- **Ocean**: Water-dominant; naval battles; underwater missions; naval craft required
- **Grassland**: Typical terrain; balanced mission types; moderate difficulty
- **Forest**: Dense vegetation; reduced visibility; ambush-prone; infiltration missions
- **Mountain**: Rough terrain; air-focused combat; mining opportunities; altitude effects
- **Desert**: Open terrain; extreme visibility; resource scarcity; sandstorm events
- **Urban**: City centers; civilian presence; structure-based combat; precision required
- **Arctic**: Extreme cold; limited resources; specialized units; survival challenges
- **Volcanic**: Dangerous terrain; geothermal resources; hazardous conditions; lava flows

**Biome Modifiers**
- **Movement Cost**: Terrain multiplier for craft travel speed
- **Combat Difficulty**: Enemy unit strength scaling
- **Research Impact**: Biome-specific technology unlocks
- **Recruitment**: Unit availability varies by biome
- **Mission Generation**: Certain mission types favor specific biomes

**Gameplay Integration**
- Biomes affect what unit types are available for recruitment
- Mission difficulty scales based on biome hazards
- Battlescape maps are procedurally generated using biome-appropriate terrain
- Interception visuals match biome environment
- Survival mechanics apply in extreme biomes (arctic cold, volcanic heat)
- Environmental events (blizzards, earthquakes) affect operations

---

### Region System

**Overview**
Regions are groupings of provinces that share geopolitical and administrative boundaries. All scoring is calculated at regional level, then aggregated to countries. Regions provide both strategic boundaries and administrative organization.

**Region Structure**
- **Province Grouping**: Multiple provinces form single region (typically 4-12 provinces per region)
- **Regional Control**: Ownership indicated by player base count
- **Scoring Aggregation**: Regional score calculated from all provinces
- **Mission Generation**: Factions operate regionally with regional preference weights
- **Resource Management**: Some resources are region-specific
- **Population**: Total regional population affects overall game balance

**Regional Economy**
- Monthly regional income = sum of provincial economies
- Regional development affects faction operations
- Some suppliers are region-locked
- Trade agreements operate at regional level
- Regional infrastructure bonuses apply to all provinces in region

**Strategic Implications**
- **Regional Scoring**: Score gains/losses computed at regional level monthly
- **Mission Weights**: Each region has weighted probability affecting mission generation
- **Purchase Restrictions**: Some suppliers only available in specific regions
- **Recruitment Pools**: Military units available vary by region
- **Base Construction**: Regional infrastructure affects base efficiency

**Gameplay Examples**
- Asian regions have higher probability of Asian faction missions
- European regions have diverse mission types and suppliers
- Resource-rich regions attract more mining-focused missions
- Densely populated regions have higher civilian protection value
- Frontier regions have limited infrastructure and higher costs

**Regional Progression**
- Clearing all missions in region allows advancement
- Regional bosses provide special rewards upon defeat
- Region control bonuses apply to all bases in region
- Can establish regional alliances with countries

---

### Portal System

**Overview**
Portals are special transit locations enabling instantaneous, cost-free travel between two provinces, even if they reside on different worlds. Portals provide critical strategic value through enabled rapid deployment.

**Portal Mechanics**
- **Instantaneous Travel**: No movement cost; immediate transport
- **Cross-World**: Connects provinces across different worlds
- **Bidirectional**: Travel works both directions
- **Limited Locations**: Not all provinces have portals; rare strategic assets
- **Indestructible**: Cannot be damaged or blocked by enemy action

**Strategic Value**
- Emergency deployment to threatened provinces
- Rapid repositioning of fleet elements
- Circumvent movement restrictions
- Create strategic chokepoints

**Portal Networks**
Portals typically exist in pairs, creating stable wormhole connections. Players can discover new portals through exploration and progression.

---

### Country System

**Overview**
Countries are political entities representing allied and hostile nations that the player must protect and manage. Each country has economic power, diplomatic relations, and strategic importance. Countries are the source of player funding and mission generation.

**Country Structure**
- **Province Ownership**: Countries own multiple provinces
- **Economic Power**: Sum of all owned provinces' economies
- **Player Relationship**: Range -100 (hostile) to +100 (allied)
- **Funding Allocation**: Determines monthly financial support
- **Mission Generation**: Country affects mission types in provinces
- **Military Capacity**: Available units and recruitment pools
- **Regional Influence**: Extends across all owned provinces

**Country Economy**
- **Base Economy**: Sum of individual province economies
- **Economic Growth**: Increases through player mission success, trade agreements
- **Economic Decline**: Damaged by enemy operations, player negligence
- **Player Funding**: Player receives percentage of GDP based on funding level
- **Funding Tiers**: 0-10 levels; higher = more funding
- **GDP Calculation**: Per-province production × number of owned provinces

**Diplomatic Relations**
- **Scoring Impact**: Monthly score in country provinces affects relationship changes
- **Relationship Thresholds**: Score changes trigger relationship shifts (every 20 points = ±1)
- **Funding Tier Changes**: Relationships determine funding level allocation
- **Mission Consequences**: Poor relationships reduce mission availability
- **Incident System**: Negative incidents accumulate and damage relations
- **Satisfaction Tracking**: Country satisfaction separate from relations; affects retention

**Country Maintenance**
- Countries require active protection from alien threats
- Undefended provinces suffer damage to satisfaction
- Regular defeats in country provinces reduce both relations and funding
- Allied countries provide better mission rewards
- Hostile countries generate more mission volume

**Country-Specific Features**
- Each country has unique unit types available for recruitment
- Research applies globally; units are country-specific
- Some facilities only build in specific countries
- Trade agreements redirect provincial income
- Can negotiate defense pacts with countries

---

### Travel System

**Overview**
Travel represents craft movement between provinces. Craft are assigned missions to specific provinces and travel there using pre-calculated world paths. Travel speed determines operational capability and range.

**Travel Mechanics**
- **Movement Points**: Craft have limited movement per turn (based on speed stat)
- **Path Selection**: Automatic use of optimal world paths for craft type
- **Speed Factor**: Craft speed determines distance traveled per movement point
- **Cumulative Distance**: Total distance = Speed × Available Movement Points
- **Cost Calculation**: Terrain multipliers increase travel cost in rough terrain
- **Multi-Leg Journeys**: Crafts can stop in intermediate provinces and continue later

**Travel Calculation Formula**
```
Reachable Distance = (Movement Points / Turn) × Craft Speed × Terrain Modifiers
Travel Time = Path Distance / Craft Speed
```

**Craft Type Capabilities**
- **Aircraft**: Ignore terrain; direct routes; fastest travel
- **Naval**: Water routes only; slower than air; unable to travel land
- **Ground**: Land routes only; affected by terrain; slowest travel
- **Teleport**: Can bypass terrain restrictions; limited uses

**Strategic Implications**
- **Range Calculation**: Effective craft range varies by terrain
- **Deployment Time**: Remote provinces require longer travel time
- **Strategic Positioning**: Base locations determine deployment capability
- **Interception Timing**: Mission travel time allows interception planning
- **Fuel Consumption**: Long journeys consume fuel; aircraft must refuel

**Movement Point Economy**
- Fast craft can travel multiple provinces per turn
- Slow craft limited to adjacent regions
- Strategic craft placement extends operational range
- Craft can "wait" in provinces for multiple turns
- Refueling points allow extended range operations

**Travel Events**
- Random encounters during travel (if mechanic enabled)
- Weather effects on travel speed
- Craft damage during transit
- Supply line disruptions

---

### Radar Coverage System

**Overview**
Radar Coverage represents the detection capability of player bases and craft. Equipped with radar systems, bases and craft scan nearby provinces daily to detect enemy missions. This creates dynamic mission revelation and interception opportunities.

**Radar Mechanics**
- **Daily Scans**: Once per day cycle at dawn
- **Range-Based**: Each radar has effective range (number of provinces)
- **Coverage Zone**: Radius expands with advanced radar technology
- **Multiple Coverage**: Multiple radar sources overlap; comprehensive coverage
- **Stacking Effect**: Overlapping coverage increases detection reliability

**Radar Power & Range by Type**

| Radar Type | Power | Range (Provinces) | Cost |
|---|---|---|---|
| **Small Radar** | 20 | 5 | Low |
| **Large Radar** | 50 | 10 | Medium |
| **Hyperwave Decoder** | 100 | 20 | High |
| **Craft (Basic)** | 10 | 3 | Standard |
| **Craft (Advanced)** | 25 | 7 | Premium |

**Mission Detection**
- **Cover Stat**: Missions have cover/stealth rating (0-100)
- **Detection Threshold**: If cover < radar strength, mission detected
- **Cover Reduction**: Over time, cover stat naturally degrades
- **Cover Reduction Formula**: New Cover = max(0, oldCover - (radarPower × effectiveness))
- **Distance Effectiveness**: effectiveness = max(0, 1 - (distance / radarRange))
- **Active Detection**: Player can target specific provinces for enhanced scans
- **Scan Cost**: Active scans consume energy/power
- **False Positives**: Low radar strength may trigger false alarms

**Detection Mechanics**
- Multiple radars can scan same mission (cumulative reduction)
- Missions become increasingly visible over days (natural cover degradation)
- Advanced research improves radar effectiveness
- Radar jamming countermeasures reduce detection range
- Environmental conditions affect radar reliability

**Radar Technology Progression**
- **Basic Radar**: Short range (~2-3 provinces); low detection power
- **Advanced Radar**: Medium range (~5-7 provinces); better detection
- **Strategic Radar**: Long range (~10+ provinces); excellent detection
- **Satellite Coverage**: Continental/global reach; research-required

**Radar Upgrades**
- **Range Extension**: Increases effective detection radius
- **Sensitivity Boost**: Improves ability to detect well-hidden missions
- **Coverage Overlap**: Reduces blind spots in coverage zones
- **Passive Mode**: Low-power continuous scanning
- **Active Mode**: High-power targeted detection

**Strategic Depth**
- **Detection Denial**: Position bases strategically to minimize blind spots
- **Radar Upgrade**: Research technology to improve radar range and sensitivity
- **Stealth Operations**: Position craft out of hostile radar range
- **Early Warning**: Detect threats before they strike player bases
- **Counter-Detection**: Enemies can detect player radar signatures
- **Radar Jamming**: Enemy capabilities to blind player detection

**Coverage Analysis**
- Player can view coverage zone overlay on map
- Undetected provinces highlighted
- Radar strength displayed numerically
- Projected coverage after research shown

---

### Random Encounter System (Proposed)

**Overview**
*[DESIGN QUESTION: Under consideration for future implementation]*

During transit between provinces, craft might encounter hostile forces in mid-journey. This would create additional risk to travel and reward careful route planning.

**Potential Mechanics**
- **Encounter Chance**: Probability of hostiles during travel
- **Interception Zone**: Mid-route combat outside normal provinces
- **Escape Option**: Players could bypass or engage encountered forces
- **Resource Loss**: Failed encounters cause damage/losses during travel

**Implementation Status**: Currently hypothetical; requires clarification on scope and integration with existing travel system.

---

### Geoscape Gameplay Loop

**Overview**
The core Geoscape gameplay loop represents the primary player interaction with the strategic layer.

**Standard Turn Sequence**

1. **Observe Generated Missions**: Automatically spawned missions appear on map
2. **Detect via Radar**: Radar coverage reveals nearby missions
3. **Plan Response**: Evaluate threat and determine response strategy
4. **Assign Craft**: Dispatch craft from base to mission province
5. **Execute Travel**: Craft moves via world path to target province
6. **Intercept or Defend**: Initiate interception with craft/base forces
7. **Resolve Engagement**: Interception succeeds/fails
8. **Escalate or Return**: Either continue to Battlescape or return to Geoscape
9. **Manage Resources**: Repair craft, allocate personnel, process rewards

**Decision Points**
- Base construction location selection
- Mission response prioritization
- Craft assignment and loadout
- Route selection (when alternatives exist)
- Engagement vs. avoidance decisions

---

### Visual Design Analogy

**Inspirational Games**
The Geoscape resembles strategic layers from:

- **Heroes of Might and Magic**: Craft as heroes; movement-based turn system; province-based gameplay
- **Eador**: Multi-level world management; province control; economic simulation
- **Europa Universalis**: Diplomatic map; relationship tracking; regional scoring; color-coded overlays

**Key Similarity**
Craft = Heroes commanding armies (units), moving across a well-defined world where provinces represent both strategic resources and tactical deployment zones.

---

### Geoscape Map Scales

**Strategic Scale** (Zoomed Out)
- View entire world/region
- See broad territory control
- Assess global threat level
- Plan long-term strategies
- Country borders visible
- Regional scoring apparent

**Tactical Scale** (Zoomed In)
- Focus on specific region
- Detail base locations
- Identify nearby missions
- Plan precise routes
- Province boundaries clear
- Biome details visible
	
