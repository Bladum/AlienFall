# Movement Action System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Action Point and Speed Framework](#action-point-and-speed-framework)
  - [Step Cost Calculation System](#step-cost-calculation-system)
  - [Terrain and Environmental Effects](#terrain-and-environmental-effects)
  - [Path Planning and Execution](#path-planning-and-execution)
  - [Special Movement Abilities and Traits](#special-movement-abilities-and-traits)
- [Examples](#examples)
  - [Basic Movement Calculations](#basic-movement-calculations)
  - [Terrain Movement Examples](#terrain-movement-examples)
  - [Path Trimming Scenarios](#path-trimming-scenarios)
  - [Unit Archetype Examples](#unit-archetype-examples)
  - [Environmental Effects Examples](#environmental-effects-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Movement Action System implements a deterministic, data-driven conversion between Action Points and traversable distance, providing designers with precise control over tactical pacing and unit positioning. Movement costs are calculated per step using configurable base costs, diagonal modifiers, terrain multipliers, and rotation penalties, while Action Points are treated as a continuous budget supporting partial movements and fractional consumption.

When planned movement exceeds available Action Points, the system deterministically trims the path to the longest reachable prefix, ensuring reproducible outcomes and predictable player feedback. This framework enables distinct mobility archetypes through Speed stat tuning and terrain interactions, creating clear tactical trade-offs between positioning speed and action flexibility.

## Mechanics

### Action Point and Speed Framework
Core resource management for movement execution:
- Action Points (AP): Player-facing resource budget treated as continuous floating-point values
- Speed Stat: Movement points generated per Action Point spent (typically 6-12 points per AP)
- Movement Points: Internal currency calculated as AP × Speed for precise movement budgeting
- Continuous Consumption: Fractional AP usage allowed for partial distance movement
- Budget Management: Automatic path trimming when movement exceeds available resources

### Step Cost Calculation System
Deterministic per-step movement costing with multiple modifiers:
- Base Orthogonal Cost: Configurable base cost for straight-line movement (default: 2 movement points)
- Diagonal Multiplier: Increased cost for diagonal movement (default: 1.5× base cost)
- Rotation Costs: Additional movement points for facing changes (1 point per 90° turn)
- Terrain Multipliers: Environmental modifiers scaling base movement costs
- Cumulative Path Cost: Sum of all individual step costs for complete movement planning

### Terrain and Environmental Effects
Environmental factors modifying movement efficiency:
- Terrain Types: Normal, light, heavy, rough, broken, rubble with different cost multipliers
- Weather Effects: Rain, snow, fog increasing movement costs and reducing visibility
- Time of Day: Night movement penalties due to reduced visibility and navigation difficulty
- Unit Status: Wounds, exhaustion, equipment load affecting mobility capabilities
- Environmental Hazards: Smoke, fire, obstacles creating movement barriers and detours

### Path Planning and Execution
Algorithmic movement route calculation with resource validation:
- Pathfinding Algorithms: A* or similar optimal route calculation considering all modifiers
- AP Budget Validation: Verification that planned path fits available Action Points
- Deterministic Trimming: Automatic path reduction to longest reachable prefix when budget exceeded
- Facing Integration: Rotation costs included in movement planning and execution
- Preview System: Player feedback showing movement costs, AP consumption, and remaining resources

### Special Movement Abilities and Traits
Unit differentiation through movement specialization:
- Movement Traits: Fleet Footed (+speed), Mountain Goat (terrain bonuses), Urban Fighter (rubble navigation)
- Unit Archetypes: Distinct mobility profiles (fast scouts, heavy infantry, stealth specialists)
- Equipment Effects: Armor, gear, and items modifying movement capabilities and penalties
- Status Effects: Temporary conditions affecting movement efficiency and terrain navigation
- Mod Integration: Custom movement rules, terrain types, and special abilities

## Examples

### Basic Movement Calculations
- Unit Speed = 8, Move 12 orthogonal plain tiles: Total movement cost = 12 × 2 = 24 points → AP consumed = 24 ÷ 8 = 3.0 AP
- Unit Speed = 7, 1 diagonal plain tile + 90° turn: Diagonal cost = 2 × 1.5 = 3, rotation = 1 → Total = 4 points → AP consumed = 4 ÷ 7 ≈ 0.571 AP
- Rough terrain diagonal step, Speed = 9: Step cost = 2 × 1.5 × 1.5 = 4.5 points → AP consumed = 4.5 ÷ 9 = 0.5 AP

### Terrain Movement Examples
- Normal Terrain: 1.0× base cost (no penalty, standard movement)
- Light Terrain: 1.5× base cost (scrub, light woods, minor obstacles)
- Heavy Terrain: 2.0× base cost (dense woods, shallow water, significant barriers)
- Rough Terrain: 1.5× base cost (broken ground, slopes, uneven surfaces)
- Broken Terrain: 2.5× base cost (debris, craters, destroyed structures)
- Rubble Terrain: 3.0× base cost (urban destruction, collapsed buildings, maximum difficulty)

### Path Trimming Scenarios
- Planned path requires 30 movement points, budget allows 24: Engine trims to longest prefix using 24 points, defers remaining 6 points to next turn
- Complex path with rotation: 3 orthogonal steps + 90° turn + 2 diagonal steps, trimmed at AP limit with partial execution
- Terrain variation: Path through mixed terrain types, trimmed to maintain AP budget while preserving optimal route

### Unit Archetype Examples
- Scout: Speed 10, reduced terrain penalties, high mobility for reconnaissance and flanking
- Heavy Infantry: Speed 6, high armor protection, slower but durable movement through difficult terrain
- Specialist: Speed 8, terrain-specific bonuses (urban fighter ignores rubble, mountain goat reduces elevation costs)
- Wounded Unit: Base speed reduced by 30%, increased terrain penalties from injury and fatigue
- Exhausted Unit: Base speed reduced by 50%, severe mobility impairment requiring rest or medical attention

### Environmental Effects Examples
- Rain: 20% movement speed reduction across all terrain types due to slippery conditions
- Night: 10% movement penalty from reduced visibility and navigation difficulty
- Smoke: Additional movement costs in obscured areas with potential for disorientation
- Fire: Movement barriers and hazard avoidance requiring detour pathfinding
- Combined Effects: Rain + night = 32% total movement penalty with compounded visibility issues

## Related Wiki Pages

- [Unit actions.md](../battlescape/Unit%20actions.md) - Framework including movement as a core action with AP costs.
- [Terrain Elevation.md](../battlescape/Terrain%20Elevation.md) - Height differences affecting movement costs and pathfinding.
- [Battle map.md](../battlescape/Battle%20map.md) - Map structure and connectivity for movement paths.
- [Battle tile.md](../battlescape/Battle%20tile.md) - Tile properties determining movement costs and accessibility.
- [Action - Running.md](../battlescape/Action%20-%20Running.md) - Alternative movement mode with speed trade-offs.
- [Action - Sneaking.md](../battlescape/Action%20-%20Sneaking.md) - Stealth movement with reduced speed and concealment.
- [Line of sight.md](../battlescape/Line%20of%20sight.md) - Movement affecting visibility and vice versa.
- [Morale.md](../battlescape/Morale.md) - Morale influencing movement decisions and panic behavior.
- [Energy.md](../units/Energy.md) - AP system powering movement and actions.
- [Stats.md](../units/Stats.md) - Speed stat determining movement efficiency.
- [Encumbrance.md](../units/Encumbrance.md) - Equipment capacity limits for loadouts.
- [Sizes.md](../units/Sizes.md) - Unit dimensions impacting terrain navigation.
- [Battlescape AI.md](../ai/Battlescape%20AI.md) - AI pathfinding and movement decision-making.

## References to Existing Games and Mechanics

The Movement Action System draws from movement mechanics in strategy and tactical games:

- **X-COM series (1994-2016)**: AP-based movement with terrain costs and pathfinding.
- **Civilization series (1991-2021)**: Movement points with terrain penalties and strategic positioning.
- **Fire Emblem series (1990-2023)**: Grid movement with AP costs and terrain modifiers.
- **Advance Wars series (2001-2018)**: Unit-specific movement costs across terrain types.
- **Final Fantasy Tactics (1997)**: AP system with terrain effects and height-based movement.
- **Disgaea series (2003-2022)**: Complex terrain penalties and stat-based movement ranges.
- **Into the Breach (2018)**: Grid-based movement with action limits and environmental interactions.
- **Tactics Ogre (1995)**: Turn-based movement with terrain and elevation costs.

