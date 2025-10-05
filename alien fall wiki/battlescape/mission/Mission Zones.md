# Deployment Zone System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Zone Definition and Properties](#zone-definition-and-properties)
  - [Size Scaling and Capacity](#size-scaling-and-capacity)
  - [Tactical Positioning Framework](#tactical-positioning-framework)
  - [Zone Types and Classification](#zone-types-and-classification)
  - [Assignment and Generation](#assignment-and-generation)
  - [Data Structure and Configuration](#data-structure-and-configuration)
- [Examples](#examples)
  - [Small Map Deployment](#small-map-deployment)
  - [Medium Map Deployment](#medium-map-deployment)
  - [Large Map Deployment](#large-map-deployment)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Deployment Zone System provides strategic map blocks designated for player unit deployment, with zone availability and capacity scaling based on battlefield dimensions. These areas offer flexible positioning options while maintaining tactical balance and mission structure integrity. The system ensures fair deployment opportunities across different map sizes and mission types, allowing players to choose optimal starting positions for their tactical approach.

## Mechanics

### Zone Definition and Properties
Core framework for deployment area specification:

**Zone Characteristics:**
- **Block-Based Structure**: Zones consist of one or more connected Map Blocks
- **Rectangular Boundaries**: Defined by coordinate bounds within the Battle Grid
- **Capacity Limits**: Maximum units that can deploy in each zone
- **Terrain Requirements**: Must contain valid spawn positions and movement areas

### Size Scaling and Capacity
Dynamic zone availability based on battlefield dimensions:

**Scaling Rules:**
- **Small Maps (4x4)**: 1-2 deployment zones with 3-4 unit capacity each
- **Medium Maps (5x5)**: 2-3 deployment zones with 4-6 unit capacity each
- **Large Maps (6x6+)**: 3-4 deployment zones with 5-8 unit capacity each
- **Special Missions**: Additional zones for complex scenarios with specialized roles

### Tactical Positioning Framework
Strategic placement affecting initial player advantage:

**Position Factors:**
- **Cover Access**: Proximity to defensive terrain and hard cover
- **Objective Distance**: Path length and complexity to mission goals
- **Threat Exposure**: Initial vulnerability to enemy deployment and patrol routes
- **Movement Options**: Available tactical maneuverability and flanking opportunities

### Zone Types and Classification
Different deployment categories for varied tactical approaches:

**Primary Deployment Zones:**
- **High Priority**: Best tactical positioning with optimal cover and objective access
- **Full Capacity**: Can accommodate maximum unit count for the map size
- **Strategic Value**: Positioned for mission success and defensive advantages
- **Defensive Options**: Good access to cover positions and chokepoints

**Secondary Deployment Zones:**
- **Alternative Positioning**: Different strategic approaches and angles of attack
- **Reduced Capacity**: Fewer units can deploy compared to primary zones
- **Specialized Roles**: Suited for specific unit types or tactical styles
- **Risk-Reward Balance**: More aggressive positioning or defensive fallbacks

**Reserve Zones:**
- **Delayed Activation**: Available for mid-mission reinforcements
- **Limited Access**: Restricted to certain unit types or special conditions
- **Tactical Surprise**: Unexpected positioning for ambushes or flanking maneuvers
- **Emergency Use**: Fallback deployment areas for mission recovery

### Assignment and Generation
Procedural zone creation during battlefield assembly:

**Assignment Process:**
1. **Block Evaluation**: Assess all Map Blocks for deployment suitability and tactical value
2. **Priority Ranking**: Rank blocks by cover rating, threat level, and objective access
3. **Zone Creation**: Group high-ranking blocks into cohesive deployment areas
4. **Capacity Setting**: Determine unit limits based on zone size and terrain quality

**Balance Considerations:**
- **Enemy Proximity**: Avoid zones too close to enemy positions or patrol routes
- **Objective Access**: Ensure viable paths to all mission goals from each zone
- **Terrain Variety**: Different zones offer varied tactical styles and approaches
- **Difficulty Scaling**: Adjust zone quality and positioning based on mission difficulty

### Data Structure and Configuration
TOML-based configuration for deployment zone properties:

```toml
[deployment_zone]
id = "primary_deployment_alpha"
name = "Main Entrance"
type = "primary"

[deployment_zone.area]
blocks = ["building_entrance", "courtyard_south"]
bounds = { x1 = 20, y1 = 10, x2 = 35, y2 = 25 }
total_tiles = 225

[deployment_zone.capacity]
max_units = 6
recommended_units = 4
unit_types_allowed = ["all"]

[deployment_zone.tactical]
cover_rating = 8
threat_level = 3
objective_access = 9
movement_freedom = 7

[deployment_zone.features]
spawn_points = 12
cover_positions = 8
overwatch_points = 3
chokepoints = 2

[deployment_zone.metadata]
priority = 1
unlocked_by_default = true
special_requirements = []
visual_highlight = "green_overlay"
```

## Examples

### Small Map Deployment
Compact battlefield with focused deployment options:

**4x4 Block Grid Configuration:**
- **2 Primary Zones**: Main entrance and side access, 3-4 units each
- **Total Capacity**: 6-8 units across all zones
- **Tactical Focus**: Direct objective access with limited flanking options
- **Mission Integration**: Quick deployment for fast-paced encounters

### Medium Map Deployment
Balanced battlefield with tactical flexibility:

**5x5 Block Grid Configuration:**
- **3 Deployment Zones**: Primary entrance, secondary flank, reserve position
- **Total Capacity**: 10-15 units with varied positioning options
- **Tactical Focus**: Multiple approaches with cover and maneuverability options
- **Mission Integration**: Standard deployment for balanced mission complexity

### Large Map Deployment
Expansive battlefield with strategic depth:

**6x6+ Block Grid Configuration:**
- **4+ Deployment Zones**: Multiple primary and secondary options plus reserves
- **Total Capacity**: 20+ units with extensive positioning flexibility
- **Tactical Focus**: Complex positioning with long-term strategic implications
- **Mission Integration**: Extended deployment for large-scale operations

## Related Wiki Pages
- [Unit Distribution System](Unit Distribution.md) - Process using deployment zones
- [Spawn Point System](Spawn Point.md) - Individual positions within zones
- [Map Block System](Map Blocks.md) - Building blocks of deployment zones
- [Battlefield System](Battlefield.md) - Context for zone placement and integration

## References to Existing Games and Mechanics
- **XCOM Series**: Multiple deployment zones with tactical positioning choices
- **Fire Emblem**: Class-based deployment restrictions and zone capacity limits
- **Final Fantasy Tactics**: Strategic deployment affecting initial positioning advantages
- **Tactical RPG Genre**: Standard practice of pre-battle unit placement and positioning