# Strategic-Level AI System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Battle Side Goals System](#battle-side-goals-system)
  - [Mission State Assessment](#mission-state-assessment)
  - [Objective Prioritization](#objective-prioritization)
  - [Mission-Specific AI Behaviors](#mission-specific-ai-behaviors)
  - [Resource Allocation](#resource-allocation)
  - [Adaptive Planning](#adaptive-planning)
- [Examples](#examples)
  - [Mission Types](#mission-types)
  - [Strategic Decision Scenarios](#strategic-decision-scenarios)
  - [Code Examples](#code-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Mechanics

### Battle Side Goals System

Faction-specific objective frameworks adapting to mission parameters:

- **Player Side**: Mission completion with casualty minimization and progression focus
- **Ally Side**: Player support with self-preservation and risk management
- **Neutral Side**: Combat avoidance with survival and evasion priorities
- **Enemy Side**: Objective prevention with force elimination and resource optimization

### Mission State Assessment

Continuous evaluation of operational conditions and progress:

- **Objective Tracking**: Completion status and progress monitoring
- **Threat Analysis**: Combatant positioning and capability assessment
- **Resource Monitoring**: Unit strength, ammunition, and equipment status
- **Time Pressure**: Mission duration and deadline management

### Objective Prioritization

Dynamic resource allocation based on situational factors and point values:

- **Point-Value Assessment**: Objectives weighted by victory point contribution (high-value objectives prioritized)
- **Progress-Based**: Objective completion status influencing focus areas
- **Time Pressure**: Deadline proximity affecting priority weighting
- **Threat Levels**: Enemy activity modifying defensive requirements
- **Resource Availability**: Capability limitations constraining objectives
- **Risk-Reward Analysis**: Point value vs. casualty cost evaluation for tactical decisions

## Mission-Specific AI Behaviors

### Elimination Missions
**Enemy AI:**
- Aggressive positioning near objectives
- Prioritize high-value targets (leaders, specialists)
- Use ambushes and flanking maneuvers
- Reinforcements focus on objective defense

**Ally AI:**
- Provide covering fire for player advances
- Secure cleared areas
- Assist in priority target elimination

### Survival Missions
**Defender AI (could be player or enemy depending on mission):**
- Establish defensive perimeters
- Prioritize area denial and early warning
- Use overwatch and suppressive fire
- Position reserves for counter-attacks

**Attacker AI:**
- Probe defenses for weak points
- Use stealth and flanking approaches
- Coordinate multi-pronged attacks
- Exploit time pressure on defenders

### Extraction Missions
**Escort AI (protecting VIP/cargo):**
- Maintain close proximity to protectee
- Clear paths ahead
- Establish secure waypoints
- Sacrifice positioning for protection

**Interceptor AI:**
- Identify and target extraction routes
- Set up ambushes at choke points
- Use speed to intercept movement
- Coordinate with reinforcements

### Sabotage Missions
**Saboteur AI:**
- Stealthy approach to objectives
- Avoid direct confrontation
- Use terrain for cover during sabotage
- Time actions for maximum disruption

**Defender AI:**
- Patrol objective areas
- Use detection systems and sentries
- Respond quickly to alerts
- Protect multiple objectives simultaneously

### Reconnaissance Missions
**Recon AI:**
- Explore unknown map areas
- Avoid combat when possible
- Gather intelligence on enemy positions
- Use stealth and elevated positions

**Counter-Recon AI:**
- Establish observation points
- Use patrols to deny areas
- Ambush likely recon routes
- Protect key terrain features

## Point-Based Strategic Behaviors

Strategic AI adapts behavior based on the point-based victory system, prioritizing objectives that contribute most to victory points while considering mission completion requirements.

### High-Value Objective Prioritization
**AI Focus Areas:**
- **Primary Objectives** (400-600 points): Commit maximum resources to mission-critical goals
- **Secondary Objectives** (200-400 points): Support primary goals while pursuing valuable secondary targets
- **Disruption Tactics**: Prevent enemy completion of high-value objectives through interdiction
- **Resource Allocation**: Deploy elite units and reinforcements to protect/defend key point sources

### Adaptive Point Hunting
**Dynamic Strategy Adjustments:**
- **Point Deficit Response**: Increase aggression when falling behind victory point targets
- **Point Surplus Tactics**: Become more conservative, focus on defense when ahead
- **Time Pressure Scaling**: Accelerate objective pursuit as mission timer decreases
- **Risk Assessment**: Evaluate point value vs. casualty cost for tactical decisions

### Multi-Objective Coordination
**Complex Mission Handling:**
- **Parallel Operations**: Execute multiple objectives simultaneously when point distribution allows
- **Sequential Prioritization**: Complete high-value objectives first, then pursue secondary goals
- **Contingency Planning**: Prepare fallback strategies if primary objectives become unattainable
- **Point Optimization**: Choose objective combinations that maximize total victory points

### Death Match Fallback Behavior
**Pure Elimination Scenarios:**
- **Rank-Based Targeting**: Prioritize elimination of high-point-value enemy units (commanders, elites)
- **Efficient Hunting**: Use coordinated groups to surround and eliminate priority targets
- **Area Denial**: Prevent enemy access to cover and escape routes for wounded high-value units
- **Reinforcement Timing**: Deploy reserves to finish off damaged but valuable targets

## Multi-Group Coordination

### Formation Management
Strategic AI assigns groups to different roles based on mission requirements and current tactical situation.

### Resource Allocation
Distribute limited resources across groups:

- **Ammunition:** Prioritize groups in active combat
- **Medical Supplies:** Focus on wounded units in critical groups
- **Reinforcements:** Deploy to threatened objectives
- **Special Equipment:** Assign based on group roles

### Communication and Adaptation
Groups signal status changes to strategic AI:

- **Under Threat:** Request reinforcements or retreat permission
- **Objective Progress:** Report completion status
- **Discovery:** Share map intelligence with other groups
- **Casualties:** Adjust plans for reduced capabilities

## Dynamic Adaptation

### Mission State Changes
AI responds to objective completion/failure through reprioritization, resource reallocation, and contingency planning.

### Threat Response
Adjust strategy based on changing threats:

- **Increasing Threat:** Consolidate forces, establish defenses
- **Decreasing Threat:** Become more aggressive, pursue objectives
- **New Threats:** Reassess priorities, allocate response forces
- **Eliminated Threats:** Reallocate resources to other objectives

### Time Pressure Adaptation
Behavior changes under time constraints:

- **Low Time Pressure:** Methodical, conservative approach
- **Medium Time Pressure:** Balanced risk-taking
- **High Time Pressure:** Aggressive, high-risk maneuvers
- **Critical Time Pressure:** Desperate measures, sacrifice positioning for speed

## Fog of War Integration

### Map Discovery Strategy
AI explores unknown areas systematically, prioritizing zones near objectives while considering threat levels.

### Intelligence Sharing
Groups share discovered information:

- **Terrain Features:** Update map knowledge for all groups
- **Enemy Positions:** Alert other groups to threats
- **Objective Locations:** Coordinate attacks on revealed targets
- **Safe Routes:** Share cleared paths with allied groups

## Performance Optimization

### Hierarchical Decision Making
Reduce computation by caching strategic decisions:

- **Long-term Plans:** Recalculated every 5-10 turns
- **Mid-term Adjustments:** Updated when objectives change
- **Short-term Tactics:** Handled by group/unit AI
- **Immediate Reactions:** Direct unit responses

### Resource Management
Efficient processing for large battles:

- **Group Batching:** Process similar groups together
- **Lazy Evaluation:** Only recalculate when state changes
- **Priority Queues:** Focus computation on active objectives
- **Memory Pooling:** Reuse calculation structures

## Testing and Balancing

### Deterministic Scenarios
Test AI behavior across different mission types:

- **Objective Completion:** Verify correct priority shifts
- **Threat Response:** Validate adaptation to changing conditions
- **Resource Allocation:** Check efficient distribution
- **Time Pressure:** Confirm appropriate risk adjustments

### Balance Metrics
Quantitative evaluation of strategic AI:

- **Objective Success Rate:** AI effectiveness at mission completion
- **Casualty Efficiency:** Losses vs. achieved goals
- **Adaptation Speed:** Response time to changing conditions
- **Resource Utilization:** Efficient use of available assets

## Strategic AI Flow Diagram

```
Mission Start → Initial Assessment → Objective Assignment
      ↓              ↓                      ↓
Battle Side Goals → Priority Calculation → Group Role Assignment
      ↓              ↓                      ↓
Resource Allocation → Plan Execution → State Monitoring
      ↓              ↓                      ↓
Adaptation Triggers → Reassessment → Plan Modification
```

## Mission Type Decision Matrix

| Mission Type | Primary Focus | Risk Tolerance | Group Coordination | Time Sensitivity |
|-------------|---------------|----------------|-------------------|------------------|
| Elimination | Combat Aggression | High | Offensive | Medium |
| Survival | Defense | Low | Defensive | High |
| Extraction | Protection | Medium | Escort | High |
| Sabotage | Stealth | Low | Individual | Medium |
| Recon | Exploration | Low | Independent | Low |

## Modding Support

### Configurable Objectives
Allow mods to define custom mission goals through TOML configuration files.

### Custom AI Behaviors
Moddable strategic logic for different factions through Lua scripting extensions.

## Code Examples

### Mission State Assessment

```lua
function assess_mission_state(battle_side, mission)
    local state = {
        objectives_progress = {},
        threat_levels = {},
        resource_status = {},
        time_pressure = 0
    }

    -- Evaluate each active objective
    for _, objective in ipairs(mission.objectives) do
        state.objectives_progress[objective.id] = calculate_objective_progress(objective, battle_side)
    end

    -- Assess threats from other sides
    for _, other_side in ipairs(get_other_battle_sides(battle_side)) do
        state.threat_levels[other_side.id] = assess_threat_level(battle_side, other_side)
    end

    -- Check resource status (ammo, health, etc.)
    state.resource_status = evaluate_side_resources(battle_side)

    -- Calculate time pressure
    state.time_pressure = calculate_time_pressure(mission)

    return state
end
```

### Objective Prioritization

```lua
function prioritize_objectives(battle_side, mission_state)
    local priorities = {}

    for objective_id, progress in pairs(mission_state.objectives_progress) do
        local base_priority = get_objective_base_priority(objective_id, battle_side.faction)

        -- Adjust for progress and time pressure
        local progress_modifier = calculate_progress_modifier(progress)
        local time_modifier = mission_state.time_pressure * 0.1

        -- Adjust for threats
        local threat_modifier = calculate_threat_modifier(mission_state.threat_levels)

        priorities[objective_id] = base_priority + progress_modifier + time_modifier + threat_modifier
    end

    return priorities
end
```

### Group Role Assignment

```lua
function assign_group_roles(battle_side, mission_state)
    local groups = get_side_groups(battle_side)
    local assignments = {}

    -- Primary objective group
    assignments.primary = select_group_for_objective(groups, get_highest_priority_objective(mission_state))

    -- Reserve/support groups
    assignments.reserve = select_reserve_groups(groups, mission_state.threat_levels)

    -- Recon/flanking groups
    assignments.flanking = select_flanking_groups(groups, mission_state)

    -- Defense groups
    assignments.defense = select_defense_groups(groups, mission_state)

    return assignments
end
```

### Objective Change Handling

```lua
function handle_objective_change(battle_side, changed_objective, mission_state)
    if changed_objective.status == "completed" then
        -- Shift focus to remaining objectives
        reprioritize_groups(battle_side, mission_state)

        -- Release resources from completed objective
        reallocate_resources(battle_side, changed_objective)

    elseif changed_objective.status == "failed" then
        -- Emergency adaptation
        activate_contingency_plan(battle_side, changed_objective)

        -- Assess overall mission viability
        evaluate_mission_continuation(battle_side, mission_state)
    end
end
```

### Exploration Planning

```lua
function plan_exploration(battle_side, known_map, mission_state)
    local exploration_zones = identify_unknown_areas(known_map)
    local exploration_plan = {}

    -- Prioritize zones near objectives
    for _, zone in ipairs(exploration_zones) do
        local objective_proximity = calculate_objective_distance(zone, mission_state)
        local threat_level = assess_zone_threat(zone, battle_side)

        zone.priority = objective_proximity * 2 - threat_level
    end

    -- Assign exploration to low-priority groups
    exploration_plan.assigned_groups = assign_exploration_groups(battle_side, exploration_zones)

    return exploration_plan
end
```

### Modding Configuration

```toml
[custom_objective.rescue_civilians]
type = "extraction"
target = "civilian_units"
time_limit = 600
success_conditions = ["all_civilians_extracted"]
failure_conditions = ["civilian_casualties > 50%"]

[strategic_ai.behaviors.rescue]
priority_base = 90
threat_multiplier = 1.5
time_pressure_modifier = 2.0
group_assignment = "defensive_escort"
```

### Custom AI Behavior

```lua
function custom_strategic_ai(battle_side, mission_state)
    -- Custom logic for modded faction
    local plan = {}

    -- Unique decision making
    plan.primary_focus = determine_custom_priority(battle_side, mission_state)
    plan.risk_tolerance = calculate_custom_risk(battle_side)

    return plan
end
```

This strategic AI design provides intelligent, adaptive behavior that respects mission diversity while maintaining deterministic, testable outcomes for balance and modding purposes.

## Examples

### Mission Types

#### Elimination Missions
Direct confrontation scenarios with force destruction objectives:

- **Primary Goal**: Enemy unit elimination and position clearing
- **Strategic Focus**: Offensive positioning and aggressive resource allocation
- **Risk Tolerance**: High acceptance with objective prioritization
- **Resource Allocation**: Combat-capable units prioritized for engagement

#### Survival Missions
Defensive scenarios requiring temporal endurance:

- **Primary Goal**: Time-based survival with minimal casualties
- **Strategic Focus**: Defensive positioning and conservation tactics
- **Risk Tolerance**: Low threshold with evasion prioritization
- **Resource Allocation**: Durable units emphasized for holding actions

#### Extraction Missions
Protective escort scenarios with movement coordination:

- **Primary Goal**: Protected unit evacuation and safe zone reaching
- **Strategic Focus**: Escort formation and route security
- **Risk Tolerance**: Medium balance with protection requirements
- **Resource Allocation**: Mobile units for screening and support

#### Sabotage Missions
Disruption scenarios targeting enemy assets:

- **Primary Goal**: Objective destruction and facility damage
- **Strategic Focus**: Stealth positioning and timing coordination
- **Risk Tolerance**: Variable based on detection probability
- **Resource Allocation**: Specialized units for sabotage execution

#### Reconnaissance Missions
Intelligence gathering with minimal engagement:

- **Primary Goal**: Area exploration and information collection
- **Strategic Focus**: Coverage optimization and stealth movement
- **Risk Tolerance**: Very low with evasion as primary tactic
- **Resource Allocation**: Fast, stealth-capable units for scouting

### Strategic Decision Scenarios

#### Resource Crisis Response
Capability degradation requiring adaptive planning:

- **Assessment**: Unit loss evaluation and remaining strength analysis
- **Reallocation**: Surviving unit reassignment to critical objectives
- **Contingency**: Fallback position establishment and withdrawal planning
- **Recovery**: Reinforcement timing and positioning optimization

#### Time Pressure Escalation
Deadline proximity requiring accelerated execution:

- **Assessment**: Remaining time evaluation and progress comparison
- **Acceleration**: Risk threshold increase and direct action prioritization
- **Optimization**: High-value target focus and efficiency maximization
- **Completion**: Final push coordination and success probability calculation

#### Multi-Objective Balancing
Complex scenarios with competing priorities:

- **Assessment**: Objective interdependency and progress correlation analysis
- **Balancing**: Resource distribution across competing requirements
- **Sequencing**: Objective completion order optimization
- **Synchronization**: Coordinated execution timing and support allocation

### Code Examples

#### Mission State Assessment

```lua
function assess_mission_state(battle_side, mission_objectives, current_situation)
    local assessment = {
        completion_percentage = 0,
        time_remaining = 0,
        threat_level = "low",
        resource_status = "adequate",
        priorities = {}
    }
    
    -- Calculate objective completion
    assessment.completion_percentage = calculate_objective_completion(mission_objectives)
    
    -- Evaluate time pressure
    assessment.time_remaining = calculate_time_remaining(mission_objectives)
    
    -- Assess threat level
    assessment.threat_level = evaluate_threat_level(current_situation)
    
    -- Check resource status
    assessment.resource_status = evaluate_resource_status(battle_side.units)
    
    -- Determine priorities
    assessment.priorities = calculate_strategic_priorities(assessment, mission_objectives)
    
    return assessment
end
```

#### Objective Prioritization

```lua
function calculate_strategic_priorities(assessment, mission_objectives)
    local priorities = {}
    
    for _, objective in ipairs(mission_objectives) do
        local priority_score = 0
        
        -- Base priority from objective type
        priority_score = priority_score + get_objective_base_priority(objective.type)
        
        -- Time pressure modifier
        if assessment.time_remaining < 300 then -- 5 minutes
            priority_score = priority_score * 1.5
        end
        
        -- Completion proximity modifier
        local completion_factor = 1 - (objective.progress / objective.target)
        priority_score = priority_score * (1 + completion_factor)
        
        -- Threat level modifier
        if assessment.threat_level == "high" then
            priority_score = priority_score * 1.3
        elseif assessment.threat_level == "critical" then
            priority_score = priority_score * 1.6
        end
        
        objective.priority = priority_score
        table.insert(priorities, objective)
    end
    
    -- Sort by priority
    table.sort(priorities, function(a, b) return a.priority > b.priority end)
    
    return priorities
end
```

#### Resource Allocation

```lua
function allocate_strategic_resources(battle_side, priorities, available_units)
    local allocation = {
        assigned_units = {},
        reserve_units = {},
        special_allocations = {}
    }
    
    -- Sort units by capability
    local sorted_units = sort_units_by_capability(available_units)
    
    -- Allocate to highest priority objectives
    for _, objective in ipairs(priorities) do
        local required_units = calculate_objective_unit_requirements(objective)
        local assigned = assign_units_to_objective(sorted_units, required_units, objective)
        
        allocation.assigned_units[objective.id] = assigned
        
        -- Remove assigned units from available pool
        for _, unit in ipairs(assigned) do
            table.remove(sorted_units, table.index_of(sorted_units, unit))
        end
    end
    
    -- Place remaining units in reserve
    allocation.reserve_units = sorted_units
    
    -- Calculate special allocations (reinforcements, etc.)
    allocation.special_allocations = calculate_special_allocations(battle_side, priorities)
    
    return allocation
end
```

## Related Wiki Pages

- [Squad AI.md](../ai/Squad%20AI.md) - Tactical execution of strategic objectives
- [Unit AI.md](../ai/Unit%20AI.md) - Individual unit behavior within strategic framework
- [Map Nodes.md](../ai/Map%20Nodes.md) - Strategic positioning infrastructure
- [Movement.md](../ai/Movement.md) - Pathfinding for strategic maneuver execution
- [Behaviors.md](../ai/Behaviors.md) - Unit behavior patterns supporting strategic goals
- [Exploration.md](../ai/Exploration.md) - Intelligence gathering for strategic assessment
- [Mission System](../../core/Mission%20System.md) - Mission framework providing strategic context
- [Objectives](../../core/Objectives.md) - Objective definitions and completion mechanics
- [Deployment zones](../battlescape/Deployment%20zones.md) - Initial positioning for strategic advantage
- [Reinforcements](../battlescape/Reinforcements.md) - Dynamic unit introduction affecting strategy

## References to Existing Games and Mechanics

The Strategic-Level AI system draws from high-level planning mechanics in strategy and tactical games:

- **XCOM series (1994-2016)**: Mission-based AI with objective-specific behaviors and resource management
- **Fire Emblem series (1990-2023)**: Chapter-based strategic planning and objective prioritization
- **Advance Wars series (2001-2018)**: Turn-based strategic decision making and resource allocation
- **Jagged Alliance series (1994-2014)**: Mercenary management and mission-specific tactical planning
- **BattleTech (1984-2024)**: Contract-based objectives and strategic resource management
- **Civilization series (1991-2023)**: Long-term strategic planning and objective balancing
- **Total War series (2000-2022)**: Campaign-level strategic decision making
- **Divinity: Original Sin series (2014-2018)**: Quest-based objective management and party strategy
- **Pillars of Eternity (2015)**: Complex objective systems with strategic decision making
- **Mass Effect series (2007-2021)**: Mission-based strategic planning and squad management