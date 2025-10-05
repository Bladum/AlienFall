# Region

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Identification and Composition Framework](#identification-and-composition-framework)
  - [Scope and Containment Rules](#scope-and-containment-rules)
  - [Spawn Weighting and Runtime Adjustment Systems](#spawn-weighting-and-runtime-adjustment-systems)
  - [Faction Preference and Relationship Framework](#faction-preference-and-relationship-framework)
  - [Mission Filtering and Compatibility Systems](#mission-filtering-and-compatibility-systems)
  - [Reports, Telemetry and Aggregation Framework](#reports,-telemetry-and-aggregation-framework)
  - [Multiplayer and Scoring Integration](#multiplayer-and-scoring-integration)
  - [Region-Scoped Events and Persistence](#region-scoped-events-and-persistence)
- [Examples](#examples)
  - [Identification and Composition Cases](#identification-and-composition-cases)
  - [Scope and Containment Scenarios](#scope-and-containment-scenarios)
  - [Spawn Weighting and Runtime Adjustment Examples](#spawn-weighting-and-runtime-adjustment-examples)
  - [Faction Preference and Relationship Cases](#faction-preference-and-relationship-cases)
  - [Mission Filtering and Compatibility Scenarios](#mission-filtering-and-compatibility-scenarios)
  - [Reports, Telemetry and Aggregation Cases](#reports,-telemetry-and-aggregation-cases)
  - [Multiplayer and Scoring Integration Examples](#multiplayer-and-scoring-integration-examples)
  - [Region-Scoped Events and Persistence Cases](#region-scoped-events-and-persistence-cases)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Region system establishes hierarchical organization above individual provinces, grouping multiple province points into thematically consistent areas for narrative control, spawn weighting, and strategic gameplay. Regions enable designers to concentrate activity, tune local event pacing, and present coherent story beats across neighboring provinces while maintaining data-driven flexibility for scripted campaigns and emergent director behavior. The system simplifies balancing through spatial scales, supports deterministic runtime adjustments, and provides comprehensive modding capabilities through explicit province lists, weights, and scheduler hooks.

From a design perspective, a Region groups multiple Provinces to create larger, thematically consistent areas for narrative, spawn weighting and reporting. Regions let designers control where activity concentrates, tune local event pacing and present coherent story beats across neighbouring provinces. Because they are data-driven lists of province IDs with weights and tags, Regions are flexible authoring tools for both scripted campaigns and emergent director behaviour.

## Mechanics

### Identification and Composition Framework

Stable regional definition and metadata structure:

- Stable Identifiers: Each region has persistent ID and explicit province ID lists for spatial definition and boundary establishment
- Metadata Fields: Human-readable name, description, and classification tags (Arctic, Coastal, Urban) for thematic identification
- Province Lists: Explicit collections of province points defining regional boundaries, composition, and spatial clustering
- World Containment: Regions belong to single worlds without cross-world spanning, maintaining planetary integrity
- Mixed Terrain: Regions may include land and water provinces for coastal and naval mission support and environmental diversity
- Thematic Consistency: Province groupings create coherent environmental, strategic, and narrative themes

### Scope and Containment Rules

Spatial organization and boundary management:

- Single World Membership: Regions contained within individual worlds maintaining planetary integrity and separation
- Boundary Definition: Explicit province lists establish clear regional boundaries and membership criteria
- Overlapping Prevention: Design principles minimize region overlaps with precedence rules when necessary
- Spatial Clustering: Provinces grouped by geographic, strategic, or narrative significance for gameplay coherence
- Containment Validation: Runtime checks ensure province membership and regional integrity
- Dynamic Boundaries: Potential for runtime boundary adjustments through events or campaign progression

### Spawn Weighting and Runtime Adjustment Systems

Dynamic activity control and deterministic modification:

- Base Weights: Data-driven spawn weights biasing alien campaign and mission origin locations for activity concentration
- Dynamic Modification: Runtime weight adjustments through global events, player actions, and faction behavior patterns
- Deterministic Changes: Seeded scheduler hooks enable reproducible weight modifications and campaign progression
- Event Integration: Scripted director events modify spawn weights for narrative control and strategic pacing
- Performance Control: Weight adjustments limit spawn breadth and control activity concentration for balance
- Feedback Loops: Weight modifications based on regional activity levels and player strategic responses

### Faction Preference and Relationship Framework

Regional faction behavior and targeting mechanics:

- Per-Faction Preferences: Region-specific weights altering faction targeting likelihood for campaigns and special events
- Strategic Alignment: Faction preferences reflect regional characteristics (pirates favoring coastal areas, cold-adapted factions in arctic regions)
- Campaign Influence: Preference weights affect faction behavior patterns and regional activity distribution
- Dynamic Relationships: Faction preferences may change based on regional control, events, and campaign progression
- Thematic Consistency: Faction-region relationships support narrative coherence and strategic depth
- Balance Integration: Preference systems enable faction specialization and regional strategic diversity

### Mission Filtering and Compatibility Systems

Regional mission control and spawn management:

- Whitelist/Blacklist System: Regions declare allowed/forbidden mission types for precise spawn control and thematic consistency
- Tag-Based Filters: Mission compatibility determined by region tags and mission requirements for environmental appropriateness
- Spawn Rejection: Incompatible missions rejected or adjusted during generation process to maintain regional integrity
- Regional Specialization: Filters create region-specific mission profiles and activity patterns for varied gameplay
- Compatibility Checking: Mission generators consult region filters before spawn placement and parameter adjustment
- Override Mechanisms: Special events or campaign states may temporarily modify regional filters

### Reports, Telemetry and Aggregation Framework

Regional analytics and performance tracking:

- Regional Analytics: Incident summaries, resource yields, public score aggregation for UI display and AI decision-making
- Director Inputs: Region-scoped telemetry feeds director systems and strategic AI for adaptive behavior
- Performance Metrics: Activity tracking, efficiency measurements, and strategic assessments for balance validation
- Designer Diagnostics: Debugging tools and balance validation through regional reporting and trend analysis
- Historical Tracking: Event logging and trend analysis for campaign continuity and player progression
- Aggregation Rules: Deterministic combination of province-level data into regional summaries

### Multiplayer and Scoring Integration

Competitive mechanics and achievement systems:

- Competitive Mechanics: Regions function as scoring buckets for multiplayer control points and influence metrics
- Control Bonuses: Regional ownership grants recurring benefits and strategic advantages for competitive gameplay
- Objective Systems: Region-based goals and achievements for multiplayer modes and campaign progression
- Influence Metrics: Control percentages and dominance measurements for scoring calculations and leaderboard systems
- Team Objectives: Multiplayer goals tied to regional control, contestation, and strategic positioning
- Scoring Hooks: Integration with achievement systems and victory condition tracking

### Region-Scoped Events and Persistence

Localized event system and state management:

- Localized Events: Events seeded and executed with region scope for focused narrative impact and strategic consequences
- Temporary Modifications: Events modify spawn weights, faction preferences, mission filters with duration-based effects
- Deterministic Execution: Seeded event system ensures reproducible regional event outcomes and campaign consistency
- Campaign Integration: Region events support story beats, strategic progression, and emergent narrative development
- Scoped Persistence: Event effects contained within region boundaries and duration limits for controlled impact
- State Tracking: Region state persistence across campaign sessions with event history and modification tracking

## Examples

### Identification and Composition Cases
- Southeast Asia Region: ID "southeast_asia", provinces ["bangkok", "singapore", "jakarta"], tags ["coastal", "high_population"], description "Tropical archipelago with dense urban centers"
- Arctic Circle Region: ID "arctic_circle", provinces ["northern_canada", "greenland", "siberia_north"], tags ["arctic", "frozen"], description "Polar region with extreme cold and limited access"
- Mid-Atlantic Region: ID "mid_atlantic", provinces ["atlantic_ocean", "sargasso_sea"], tags ["ocean", "naval"], description "Open ocean area with strong currents and naval activity"
- Industrial Belt Region: ID "industrial_belt", provinces ["ruhr_valley", "pittsburgh", "manchester"], tags ["industrial", "polluted"], description "Heavily industrialized area with manufacturing focus"

### Scope and Containment Scenarios
- Single World Membership: European regions contained within Earth world, maintaining continental integrity and preventing cross-world overlap
- Boundary Definition: Explicit province lists create clear boundaries between neighboring regions like "Western Europe" and "Eastern Europe"
- Overlapping Prevention: Design rules prevent province overlap with precedence systems for contested border areas
- Spatial Clustering: Geographic provinces grouped by mountain ranges, river systems, or political boundaries
- Containment Validation: Runtime checks ensure all region provinces exist and belong to correct world
- Dynamic Boundaries: Campaign events potentially shifting province membership between regions

### Spawn Weighting and Runtime Adjustment Examples
- Base Weights: Southeast Asia region with weight 1.5x for terror campaigns due to high population density
- Dynamic Modification: Alien invasion event increasing arctic region weight by 2.0x for cold-adapted faction activity
- Deterministic Changes: Seeded scheduler hook reducing industrial belt weight after environmental cleanup event
- Event Integration: Scripted story beat doubling coastal region weights during naval invasion phase
- Performance Control: Weight caps preventing single region from dominating 40% of total mission spawns
- Feedback Loops: Player base construction in region reducing spawn weights through deterrence effects

### Faction Preference and Relationship Cases
- Per-Faction Preferences: Pirate faction with 3.0x preference for coastal regions, minimal arctic preference
- Strategic Alignment: Cold-adapted alien faction with 2.5x arctic region preference, reduced tropical activity
- Campaign Influence: Terrorist faction targeting high-population regions with urban infrastructure focus
- Dynamic Relationships: Faction preferences shifting after diplomatic events or territorial changes
- Thematic Consistency: Aquatic faction favoring ocean regions, subterranean faction preferring mountainous areas
- Balance Integration: Preference diversity preventing faction clustering and encouraging varied strategies

### Mission Filtering and Compatibility Scenarios
- Whitelist/Blacklist System: Arctic region blacklisting naval missions, whitelisting cold-weather operations
- Tag-Based Filters: Coastal region requiring "naval" tag for ship-based missions, rejecting landlocked operations
- Spawn Rejection: Industrial region rejecting environmental missions incompatible with urban setting
- Regional Specialization: Mountain region specializing in base assault missions with terrain advantages
- Compatibility Checking: Mission generator rejecting jungle missions in desert region based on biome mismatch
- Override Mechanisms: Special events temporarily allowing incompatible missions for narrative purposes

### Reports, Telemetry and Aggregation Cases
- Regional Analytics: Southeast Asia region reporting 25 terror incidents, $500K resource yield, +150 public score
- Director Inputs: High-activity region triggering increased AI response and mission escalation
- Performance Metrics: Industrial belt region showing 85% mission success rate, 3.2 average difficulty rating
- Designer Diagnostics: Debug view displaying spawn weight distributions and filter effectiveness
- Historical Tracking: Trend analysis showing region activity increasing 40% over previous quarter
- Aggregation Rules: Province-level funding contributions combined into regional economic summary

### Multiplayer and Scoring Integration Examples
- Competitive Mechanics: European region contested between players, granting control points for leaderboard scoring
- Control Bonuses: Industrial belt ownership providing +$200K monthly income and research acceleration
- Objective Systems: "Secure North America" achievement requiring control of all continental regions
- Influence Metrics: 65% control percentage in Pacific region contributing to global dominance score
- Team Objectives: Cooperative multiplayer goal requiring shared control of strategic regions
- Scoring Hooks: Regional achievements unlocking special units or diplomatic advantages

### Region-Scoped Events and Persistence Cases
- Localized Events: "Arctic Anomaly" event spawning unique missions only in arctic region provinces
- Temporary Modifications: Environmental disaster reducing industrial region spawn weights for 3 months
- Deterministic Execution: Seeded event system ensuring "Coastal Storm" always affects same provinces
- Campaign Integration: Story event increasing Southeast Asia region weights during invasion narrative
- Scoped Persistence: Pirate activity bonus lasting 6 months within affected coastal region
- State Tracking: Region remembering past events for narrative continuity and player briefing context

## Related Wiki Pages

- [Province.md](../geoscape/Province.md) - Province management and regions.
- [World.md](../geoscape/World.md) - World region composition.
- [Biome.md](../geoscape/Biome.md) - Regional biome consistency.
- [Universe.md](../geoscape/Universe.md) - Multi-world regional systems.
- [Geoscape.md](../geoscape/Geoscape.md) - Strategic layer integration.
- [Mission Detection and Assignment.md](../interception/Mission%20Detection%20and%20Assignment.md) - Regional mission spawning.
- [Monthly reports.md](../finance/Monthly%20reports.md) - Regional reporting.
- [Faction.md](../lore/Faction.md) - Regional faction preferences.

## References to Existing Games and Mechanics

- **Civilization Series**: Civilization territories and regional control
- **Europa Universalis**: Colonial regions and trade nodes
- **Crusader Kings**: Duchy and kingdom regions
- **Hearts of Iron**: Theater commands and regional warfare
- **Victoria Series**: Colonial regions and diplomatic influence
- **Stellaris**: Sector and regional empire management
- **Endless Space**: System clusters and regional control
- **Galactic Civilizations**: Sector control and regional influence
- **Total War Series**: Province regions and campaign areas
- **Warcraft III**: Zone control and regional objectives

