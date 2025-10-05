# Squad-Level AI System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Squad Formation System](#squad-formation-system)
  - [Squad Types and Behaviors](#squad-types-and-behaviors)
  - [Formation Management](#formation-management)
  - [Map Node Integration](#map-node-integration)
  - [Coordinated Maneuvers](#coordinated-maneuvers)
  - [Squad Cohesion and Morale](#squad-cohesion-and-morale)
- [Examples](#examples)
  - [Formation Types](#formation-types)
  - [Squad Coordination Scenarios](#squad-coordination-scenarios)
  - [Code Examples](#code-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Squad-Level AI system implements coordinated unit group behavior in Alien Fall, serving as the critical bridge between individual unit actions and strategic mission planning. Squads consist of 1-5 units working toward common tactical objectives, leveraging map nodes for positioning and pathfinding to create emergent behaviors from synchronized unit actions. The system creates sophisticated group tactics while maintaining deterministic outcomes for testing and modding.

The squad AI emphasizes formation maintenance, role specialization, and adaptive coordination, integrating with the hierarchical AI architecture to translate strategic goals into tactical execution. Squads dynamically adjust formations, coordinate maneuvers, and maintain cohesion while responding to battlefield conditions and mission requirements.

## Mechanics

### Squad Formation System

Dynamic squad creation and management adapting to mission requirements:

- **Composition Analysis**: Unit capability assessment for optimal grouping
- **Mission Matching**: Squad creation based on tactical objectives and terrain
- **Size Optimization**: 1-5 unit groups balancing coordination and flexibility
- **Dynamic Reorganization**: Runtime squad restructuring responding to casualties

### Squad Types and Behaviors

Specialized tactical patterns for different operational contexts:

- **Assault Squads**: Direct engagement and objective capture with high-risk tolerance
- **Defense Squads**: Area denial and position holding with low-risk focus
- **Flanking Squads**: Maneuver warfare and encirclement with medium-risk balance
- **Recon Squads**: Intelligence gathering with minimal engagement priority
- **Support Squads**: Logistics and special operations with variable risk assessment

## Formation Management

### Formation Types

**Wedge Formation:**
- Point unit leads, others provide flanking support
- Ideal for: Breaking through defenses, urban assaults
- Advantages: Concentrated firepower forward, mutual support
- Disadvantages: Vulnerable flanks, difficult in tight terrain

**Line Formation:**
- Units spread evenly across frontage
- Ideal for: Area denial, suppressive fire
- Advantages: Maximum coverage, interlocking fire
- Disadvantages: Weak center, easy to flank

**Column Formation:**
- Units stacked vertically for depth
- Ideal for: Movement through dangerous areas, reserves
- Disadvantages: Limited firepower projection

**Skirmish Line:**
- Loose spacing with individual initiative
- Ideal for: Recon, harassment, hit-and-run
- Advantages: Flexible positioning, hard to pin down
- Disadvantages: Low cohesion, vulnerable to concentrated attacks

### Dynamic Formation Adjustment

Squads adapt formations based on situation, terrain, and enemy positioning to optimize tactical effectiveness.

## Map Node Integration

### Node-Based Coordination

Squads use map nodes as coordination points for positioning, pathfinding, and tactical decision-making.

### Multi-Squad Node Control

Competing squads vie for valuable nodes based on faction priorities, squad strength, and mission objectives.

## Coordinated Maneuvers

### Flanking Operations

Multi-unit flanking tactics combining suppression fire with maneuver elements.

### Suppression and Maneuver

Combined arms tactics with designated fire support and advancing maneuver elements.

### Bounding Overwatch

Alternating movement with security, where half the squad moves while the other provides overwatch.

## Squad Cohesion and Morale

### Cohesion Mechanics

Squad effectiveness depends on unit relationships, successful actions, casualties, leadership, and terrain stress.

### Cohesion Effects

Cohesion impacts squad performance across different ranges, affecting coordination, morale, and panic risk.

### Morale Propagation

Squad morale influences individual units, with cohesion providing additional morale bonuses.

## Communication and Signaling

### Squad Communication Channels

Units signal status and intentions through various communication types including support requests, enemy sightings, and threat warnings.

### Signal Response

Squads react to signals from members, adjusting tactics based on threat levels and new intelligence.

## Fog of War and Intelligence Sharing

### Shared Intelligence

Squads pool knowledge of the battlefield, combining individual unit discoveries into comprehensive shared intelligence.

### Exploration Coordination

Squads coordinate to explore unknown areas efficiently, assigning zones and establishing communication points.

## Performance Optimization

### Squad Processing Efficiency

Batch operations for multiple units including formation updates, pathfinding, signal propagation, and intelligence sharing.

### Scalability Considerations

Handle large numbers of squads through processing priorities, background updates, memory management, and network synchronization.

## Testing and Balancing

### Squad Behavior Scenarios

Test coordination in various situations including formation integrity, maneuver execution, communication effectiveness, and cohesion dynamics.

### Balance Metrics

Quantitative evaluation of squad AI including coordination efficiency, survival rates, objective achievement, and adaptation speed.

## Squad AI Flow Diagram

```
Squad Creation → Role Assignment → Formation Selection
      ↓              ↓                      ↓
Mission Assignment → Node Targeting → Path Planning
      ↓              ↓                      ↓
Tactic Selection → Coordination Setup → Execution
      ↓              ↓                      ↓
Status Monitoring → Signal Processing → Adaptation
```

## Formation Decision Matrix

| Situation | Preferred Formation | Rationale | Risk Level |
|-----------|-------------------|-----------|------------|
| Urban Combat | Wedge | Concentrated breakthrough | High |
| Open Terrain | Line | Maximum coverage | Medium |
| Movement | Column | Speed and protection | Low |
| Recon | Skirmish | Flexibility and coverage | Low |
| Defense | Perimeter | All-around security | Low |

## Modding Support

### Custom Squad Types

Allow mods to define new squad behaviors through TOML configuration with custom formations, unit compositions, and tactics.

### Custom Tactics

Moddable maneuver definitions enabling unique squad behaviors and special abilities.

## Code Examples

### Squad Creation

```lua
function create_tactical_squad(units, squad_type, objective)
    local squad = {
        id = generate_squad_id(),
        units = units,
        type = squad_type,  -- "assault", "defense", "flanking", "recon", etc.
        objective = objective,
        formation = select_formation(squad_type, #units),
        cohesion = calculate_initial_cohesion(units),
        map_node_target = nil,
        status = "forming"
    }

    -- Assign roles within squad
    assign_squad_roles(squad)

    -- Establish communication links
    setup_squad_communication(squad)

    return squad
end
```

### Formation Adjustment

```lua
function adjust_formation(squad, tactical_situation)
    local current_formation = squad.formation
    local new_formation = current_formation

    -- Terrain analysis
    if tactical_situation.terrain_type == "urban" then
        new_formation = "wedge"  -- Concentrated for building clearing
    elseif tactical_situation.terrain_type == "open" then
        new_formation = "line"   -- Spread for maximum coverage
    end

    -- Enemy positioning
    if tactical_situation.enemy_flanked then
        new_formation = "column"  -- Concentrate for defense
    elseif tactical_situation.flanking_opportunity then
        new_formation = "skirmish"  -- Spread for maneuver
    end

    -- Apply formation change if needed
    if new_formation ~= current_formation then
        transition_formation(squad, new_formation, tactical_situation)
    end
end
```

### Node Assignment

```lua
function assign_squad_to_node(squad, target_node, mission_context)
    -- Check node capacity and faction priorities
    if not can_occupy_node(squad, target_node) then
        return false
    end

    -- Calculate path to node
    local path = calculate_squad_path(squad, target_node.position)

    -- Assign movement waypoints
    squad.waypoints = path

    -- Set squad objective
    squad.objective = {
        type = "occupy_node",
        target = target_node,
        priority = target_node.priorities[squad.faction] or 50
    }

    return true
end
```

### Node Contesting

```lua
function resolve_node_contest(squads, contested_node)
    local claimants = {}

    -- Evaluate each squad's claim
    for _, squad in ipairs(squads) do
        local claim_strength = calculate_node_claim(squad, contested_node)
        if claim_strength > 0 then
            table.insert(claimants, {squad = squad, strength = claim_strength})
        end
    end

    -- Sort by claim strength
    table.sort(claimants, function(a, b) return a.strength > b.strength end)

    -- Assign node to strongest claimant
    if #claimants > 0 then
        local winner = claimants[1].squad
        occupy_node(winner, contested_node)

        -- Displace weaker squads
        for i = 2, #claimants do
            displace_squad(claimants[i].squad, contested_node)
        end
    end
end
```

### Flanking Maneuver

```lua
function execute_flanking_maneuver(main_squad, flanking_squad, enemy_position)
    -- Main squad provides suppression
    main_squad.tactic = "suppress"
    main_squad.target_area = enemy_position

    -- Flanking squad maneuvers
    flanking_squad.tactic = "flank"
    flanking_squad.target_position = calculate_flank_position(enemy_position)

    -- Coordinate timing
    local suppression_start = get_current_turn() + 1
    local flank_execution = suppression_start + 2

    schedule_squad_action(main_squad, "begin_suppression", suppression_start)
    schedule_squad_action(flanking_squad, "begin_flank", flank_execution)

    -- Signal completion
    setup_maneuver_completion_handler(main_squad, flanking_squad)
end
```

### Bounding Overwatch

```lua
function execute_bounding_overwatch(squad, movement_path)
    local units = squad.units
    local bound_size = 3  -- tiles per bound

    for i = 1, #movement_path, bound_size do
        local bound_end = math.min(i + bound_size - 1, #movement_path)
        local moving_units = {}
        local overwatch_units = {}

        -- Split squad
        for j, unit in ipairs(units) do
            if j % 2 == 1 then
                table.insert(moving_units, unit)
            else
                table.insert(overwatch_units, unit)
            end
        end

        -- Moving element advances
        move_units_to_position(moving_units, movement_path[bound_end])

        -- Overwatch element provides security
        assign_overwatch_positions(overwatch_units, movement_path[bound_end])

        -- Swap roles for next bound
        units = alternate_roles(units)
    end
end
```

### Cohesion Update

```lua
function update_squad_cohesion(squad, recent_events)
    local cohesion_change = 0

    -- Successful actions increase cohesion
    if recent_events.successful_action then
        cohesion_change = cohesion_change + 5
    end

    -- Casualties decrease cohesion
    if recent_events.unit_lost then
        cohesion_change = cohesion_change - 15
    end

    -- Leadership improves cohesion
    local leader_bonus = calculate_leadership_bonus(squad.leader)
    cohesion_change = cohesion_change + leader_bonus

    -- Terrain effects
    if squad.formation_stressed then
        cohesion_change = cohesion_change - 3
    end

    squad.cohesion = math.max(0, math.min(100, squad.cohesion + cohesion_change))
end
```

### Morale Propagation

```lua
function propagate_squad_morale(squad)
    local squad_morale = calculate_squad_morale(squad)

    for _, unit in ipairs(squad.units) do
        -- Squad morale influences individual morale
        local morale_influence = (squad_morale - unit.morale) * 0.3
        unit.morale = math.max(0, math.min(100, unit.morale + morale_influence))

        -- Cohesion bonus
        if squad.cohesion > 50 then
            unit.morale = unit.morale + 2
        end
    end
end
```

### Squad Communication

```lua
local communication_types = {
    REQUEST_SUPPORT = "request_support",
    ENEMY_SPOTTED = "enemy_spotted",
    OBJECTIVE_COMPLETE = "objective_complete",
    UNDER_THREAT = "under_threat",
    RETREATING = "retreating"
}

function send_squad_signal(sending_unit, signal_type, data)
    local squad = sending_unit.squad
    local signal = {
        type = signal_type,
        sender = sending_unit,
        data = data,
        timestamp = get_current_turn(),
        range = calculate_communication_range(sending_unit)
    }

    -- Propagate to squad members
    for _, unit in ipairs(squad.units) do
        if unit ~= sending_unit and distance(sending_unit.position, unit.position) <= signal.range then
            receive_signal(unit, signal)
        end
    end
end
```

### Signal Handling

```lua
function handle_squad_signal(squad, signal)
    if signal.type == "under_threat" then
        -- Assess threat level
        local threat_level = assess_signal_threat(signal)

        if threat_level > 70 then
            -- High threat: consolidate or retreat
            squad.tactic = "consolidate"
        elseif threat_level > 30 then
            -- Medium threat: provide support
            dispatch_support(squad, signal.sender.position)
        end

    elseif signal.type == "enemy_spotted" then
        -- Update squad intelligence
        update_squad_intelligence(squad, signal.data)

        -- Adjust positioning if needed
        reevaluate_positioning(squad)
    end
end
```

### Intelligence Sharing

```lua
function share_squad_intelligence(squad)
    local combined_intelligence = {}

    -- Collect intelligence from all units
    for _, unit in ipairs(squad.units) do
        for position, info in pairs(unit.known_map) do
            combined_intelligence[position] = merge_intelligence_info(
                combined_intelligence[position],
                info
            )
        end
    end

    -- Distribute combined intelligence
    for _, unit in ipairs(squad.units) do
        unit.known_map = table.deepcopy(combined_intelligence)
    end

    return combined_intelligence
end
```

### Exploration Coordination

```lua
function coordinate_exploration(squads, unknown_areas)
    local exploration_plan = {
        assigned_zones = {},
        overlapping_coverage = {},
        communication_points = {}
    }

    -- Assign zones to squads
    for _, area in ipairs(unknown_areas) do
        local best_squad = find_best_exploration_squad(squads, area)
        if best_squad then
            table.insert(exploration_plan.assigned_zones, {
                area = area,
                squad = best_squad
            })
        end
    end

    -- Identify communication points
    exploration_plan.communication_points = identify_communication_points(exploration_plan)

    return exploration_plan
end
```

### Modding Configuration

```toml
[custom_squad.beast_pack]
type = "hunting_pack"
formation = "pack_hunt"
unit_types = ["alpha_beast", "hunter_beast", "scout_beast"]
tactics = ["pack_ambush", "relentless_pursuit"]
cohesion_factors = ["pack_mentality", "predator_instinct"]

[strategy.beast_pack]
risk_tolerance = 80
objective_priority = "elimination"
communication_range = 15
adaptability = 60
```

### Custom Tactics

```lua
function custom_pack_ambush(squad, target_area)
    -- Custom ambush logic for beast pack
    local ambush_positions = calculate_pack_positions(squad, target_area)

    -- Position alpha beast centrally
    position_unit(squad.alpha_unit, ambush_positions.center)

    -- Position hunters on flanks
    for _, hunter in ipairs(squad.hunters) do
        position_unit(hunter, ambush_positions.flanks[math.random(#ambush_positions.flanks)])
    end

    -- Scouts provide early warning
    assign_patrol_route(squad.scouts, target_area.perimeter)
end

## Examples

### Formation Types

#### Wedge Formation
Point unit leadership with flanking support structure:

- **Tactical Application**: Breaking through defensive lines and urban assaults
- **Strengths**: Concentrated forward firepower and mutual unit protection
- **Weaknesses**: Vulnerable to flanking attacks and tight terrain difficulties
- **Unit Positioning**: Lead unit at point, supporting units at 45-degree angles

#### Line Formation
Even frontage distribution for maximum coverage:

- **Tactical Application**: Area denial and suppressive fire coverage
- **Strengths**: Complete coverage area and interlocking fire capabilities
- **Weaknesses**: Center vulnerability and easy flanking opportunities
- **Unit Positioning**: Equal spacing across frontage with depth variation

#### Column Formation
Depth-focused movement through dangerous areas:

- **Tactical Application**: Reserve positioning and hazardous terrain navigation
- **Strengths**: Protected movement and casualty minimization
- **Weaknesses**: Limited firepower projection and slow response time
- **Unit Positioning**: Stacked positioning with movement priority

#### Skirmish Line
Flexible spacing with individual initiative:

- **Tactical Application**: Reconnaissance and hit-and-run tactics
- **Strengths**: Hard targeting and adaptable positioning
- **Weaknesses**: Low cohesion and concentrated attack vulnerability
- **Unit Positioning**: Variable spacing with independent movement freedom

### Squad Coordination Scenarios

#### Urban Assault
City fighting with building exploitation and close-quarters tactics:

- **Squad Composition**: Assault squad with close-quarters specialists
- **Formation**: Wedge formation for breach and clear operations
- **Coordination**: Suppressive fire from overwatch positions
- **Contingency**: Room clearing and fallback positioning

#### Rural Defense
Open terrain position holding with field fortifications:

- **Squad Composition**: Defense squad with ranged specialists
- **Formation**: Line formation with interlocking fields of fire
- **Coordination**: Overwatch networks and reinforcement positioning
- **Contingency**: Fighting withdrawal and rally point establishment

#### Forest Recon
Woodland intelligence gathering with stealth movement:

- **Squad Composition**: Recon squad with stealth specialists
- **Formation**: Skirmish line for maximum coverage area
- **Coordination**: Communication waypoints and signal protocols
- **Contingency**: Emergency extraction and evasion routes

### Code Examples

#### Squad Formation System

```lua
function create_optimal_squad(available_units, mission_type, terrain_type)
    local squad_candidates = {}
    
    -- Analyze unit capabilities
    for _, unit in ipairs(available_units) do
        local capabilities = analyze_unit_capabilities(unit)
        table.insert(squad_candidates, {
            unit = unit,
            capabilities = capabilities,
            compatibility_score = 0
        })
    end
    
    -- Determine optimal squad size (1-5 units)
    local optimal_size = determine_optimal_squad_size(mission_type, terrain_type)
    
    -- Select compatible units
    local selected_units = select_compatible_units(squad_candidates, optimal_size, mission_type)
    
    -- Create squad structure
    local squad = {
        id = generate_squad_id(),
        units = selected_units,
        type = determine_squad_type(selected_units, mission_type),
        formation = select_initial_formation(selected_units, terrain_type),
        cohesion = calculate_initial_cohesion(selected_units)
    }
    
    return squad
end
```

#### Formation Management

```lua
function maintain_formation(squad, target_position, current_formation)
    local formation_positions = calculate_formation_positions(
        target_position, 
        current_formation, 
        #squad.units
    )
    
    -- Assign positions to units
    for i, unit in ipairs(squad.units) do
        local assigned_position = formation_positions[i]
        if assigned_position then
            move_unit_to_position(unit, assigned_position, squad)
        end
    end
    
    -- Check formation integrity
    local integrity = check_formation_integrity(squad, formation_positions)
    if integrity < FORMATION_INTEGRITY_THRESHOLD then
        adjust_formation(squad, current_formation, integrity)
    end
    
    return formation_positions
end
```

#### Coordinated Maneuvers

```lua
function execute_bounding_overwatch(squad, movement_path, overwatch_positions)
    local maneuver_plan = {
        moving_element = {},
        overwatch_element = {},
        timing = {},
        contingencies = {}
    }
    
    -- Split squad into elements
    maneuver_plan.moving_element = select_moving_element(squad)
    maneuver_plan.overwatch_element = get_remaining_units(squad, maneuver_plan.moving_element)
    
    -- Position overwatch element
    maneuver_plan.overwatch_positions = position_overwatch_element(
        maneuver_plan.overwatch_element, 
        overwatch_positions
    )
    
    -- Plan movement timing
    maneuver_plan.timing = coordinate_movement_timing(
        maneuver_plan.moving_element, 
        maneuver_plan.overwatch_element, 
        movement_path
    )
    
    -- Generate contingencies
    maneuver_plan.contingencies = generate_maneuver_contingencies(
        squad, 
        movement_path, 
        maneuver_plan
    )
    
    return maneuver_plan
end
```

## Related Wiki Pages

- [Unit AI.md](../ai/Unit%20AI.md) - Individual unit behaviors within squad context
- [Strategic AI.md](../ai/Strategic%20AI.md) - Mission-level squad assignment and objectives
- [Map Nodes.md](../ai/Map%20Nodes.md) - Navigation infrastructure for squad movement
- [Movement.md](../ai/Movement.md) - Pathfinding and positioning for squad formations
- [Behaviors.md](../ai/Behaviors.md) - Unit behavior types contributing to squad roles
- [Exploration.md](../ai/Exploration.md) - Squad-based reconnaissance and intelligence gathering
- [Battle tile.md](../battlescape/Battle%20tile.md) - Terrain affecting formation effectiveness
- [Terrain Elevation.md](../battlescape/Terrain%20Elevation.md) - Height considerations for squad positioning
- [Line of sight.md](../battlescape/Line%20of%20sight.md) - Visibility affecting squad coordination
- [Unit actions.md](../battlescape/Unit%20actions.md) - Combat actions coordinated at squad level

## References to Existing Games and Mechanics

The Squad-Level AI system draws from group coordination mechanics in tactical and strategy games:

- **XCOM series (1994-2016)**: Squad-based positioning and overwatch coordination
- **Fire Emblem series (1990-2023)**: Formation-based unit positioning and group tactics
- **Advance Wars series (2001-2018)**: Unit stacking and coordinated movement
- **Jagged Alliance series (1994-2014)**: Squad management and formation positioning
- **BattleTech (1984-2024)**: Lance-based coordination and formation tactics
- **Civilization series (1991-2023)**: Unit grouping and tactical positioning
- **Total War series (2000-2022)**: Large-scale formation management and coordination
- **Divinity: Original Sin series (2014-2018)**: Party-based positioning and tactical coordination
- **Pillars of Eternity (2015)**: Group formation and positioning mechanics
- **Mass Effect series (2007-2021)**: Squad-based tactics and positioning systems
```

This squad-level AI design enables sophisticated multi-unit coordination while maintaining deterministic behavior for testing and modding purposes.