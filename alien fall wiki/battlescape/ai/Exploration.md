# Map Discovery and Exploration AI System

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Fog of War System](#fog-of-war-system)
  - [Vision and Revelation Mechanics](#vision-and-revelation-mechanics)
  - [Exploration Strategy](#exploration-strategy)
  - [Terrain Adaptation](#terrain-adaptation)
  - [Intelligence Sharing and Learning](#intelligence-sharing-and-learning)
  - [Risk Assessment and Safety](#risk-assessment-and-safety)
  - [Performance Optimization](#performance-optimization)
- [Examples](#examples)
  - [Exploration Scenarios](#exploration-scenarios)
  - [Code Examples](#code-examples)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

The Map Discovery and Exploration AI system implements asymmetric information management in Alien Fall's battlescape, where no faction begins with complete battlefield knowledge. The system creates strategic tension through progressive map revelation, deterministic exploration behaviors, and adaptive AI tactics that respond to newly discovered terrain. Exploration operates across all AI hierarchy levels, from strategic mission planning to individual unit positioning, ensuring coordinated and efficient map coverage while maintaining performance and moddability.

The exploration system emphasizes deterministic outcomes for testing, configurable difficulty scaling, and seamless integration with fog of war mechanics. AI units balance information gathering with survival, adapting movement patterns and risk assessments based on revealed terrain features and mission objectives.

## Mechanics

### Fog of War System

Asymmetric information management per faction with distinct knowledge states:

- **Known Tiles**: Permanently revealed terrain and features
- **Visible Tiles**: Currently observable areas within unit vision ranges
- **Explored Regions**: Fully surveyed areas with complete terrain data
- **Unknown Regions**: Identified but unrevealed spaces requiring exploration
- **Update Tracking**: Timestamped knowledge progression for temporal analysis

### Vision and Revelation Mechanics

Progressive battlefield knowledge acquisition through unit positioning:

- **Tile Revelation**: Vision radius-based area uncovering around unit locations
- **Capability-Based Vision**: Unit-specific sight ranges and detection abilities
- **Revelation Processing**: New information integration and strategic adaptation
- **Knowledge Updates**: Faction-specific information state maintenance

### Exploration Strategy

Multi-level coordination for systematic map discovery:

- **Strategic Planning**: High-level prioritization of exploration zones based on mission objectives
- **Group Coordination**: Multi-unit tactics with assigned roles and movement patterns
- **Tactical Approaches**: Situation-adaptive exploration methods (perimeter sweep, center probe, leapfrog advance, stealth infiltration)

### Terrain Adaptation

Dynamic response to newly revealed battlefield features:

- **Feature Identification**: Automatic recognition of chokepoints, ambush positions, and defensive terrain
- **Pathfinding Updates**: Route recalculation incorporating new obstacles and opportunities
- **Strategic Adaptation**: Behavior modification based on terrain discoveries

### Intelligence Sharing and Learning

Knowledge propagation and improvement across AI levels:

- **Information Flow**: Hierarchical intelligence dissemination with level-specific processing
- **Confidence Calculation**: Reliability assessment of shared exploration data
- **Experience Learning**: Pattern recognition from successful and failed explorations

### Risk Assessment and Safety

Exploration decision-making balancing information gain with survival:

- **Zone Risk Evaluation**: Threat assessment for unexplored areas considering enemy presence and terrain hazards
- **Mitigation Strategies**: Risk-reducing movement patterns and positioning tactics
- **Safe Exploration**: Conservative approaches with overwatch and emergency contingencies

### Performance Optimization

Efficient processing for large-scale battlefield exploration:

- **Spatial Partitioning**: Vision calculation optimization through area subdivision
- **Incremental Updates**: Progressive fog of war state modifications
- **Vision Caching**: Precomputed visibility data for common scenarios
- **Batch Processing**: Grouped revelation updates for computational efficiency

## Examples

### Exploration Scenarios

#### Safe Exploration
Low-threat reconnaissance with minimal risk mitigation:
- Conservative movement patterns with full squad overwatch
- Systematic grid-based coverage of unknown areas
- Emergency waypoint establishment for rapid withdrawal

#### Hostile Exploration
High-risk advancement through contested territory:
- Leapfrog movement with alternating covering fire
- Priority targeting of elevated observation positions
- Dynamic risk reassessment based on contact intensity

#### Time-Pressured Exploration
Rapid coverage requirements with speed prioritization:
- Multi-unit simultaneous advancement patterns
- Minimal overwatch allocation for maximum coverage rate
- Acceptance of higher risk thresholds for mission completion

#### Coordinated Exploration
Multi-squad synchronized discovery operations:
- Designated scout units with supporting overwatch elements
- Communication waypoint networks for intelligence sharing
- Phased advancement with progressive risk reduction

### Code Examples

#### Fog of War System

```lua
function initialize_fog_of_war(battlefield, factions)
    local fog_state = {}
    
    for _, faction in ipairs(factions) do
        fog_state[faction] = {
            known_tiles = {},  -- Revealed tile positions
            visible_tiles = {}, -- Currently visible tiles
            explored_regions = {}, -- Fully explored areas
            unknown_regions = {}, -- Identified but unexplored areas
            last_update = 0
        }
    end
    
    -- Initialize with deployment zone knowledge
    for _, faction in ipairs(factions) do
        reveal_deployment_zone(fog_state[faction], battlefield, faction)
    end
    
    return fog_state
end
```

#### Vision and Revelation Mechanics

```lua
function update_faction_vision(faction, units, battlefield, fog_state)
    local faction_fog = fog_state[faction]
    local new_revelations = {}
    
    -- Clear previous visible tiles
    faction_fog.visible_tiles = {}
    
    -- Calculate vision from each unit
    for _, unit in ipairs(units) do
        local vision_radius = calculate_unit_vision(unit)
        local visible_positions = calculate_visible_positions(unit.position, vision_radius, battlefield)
        
        for _, pos in ipairs(visible_positions) do
            -- Mark as currently visible
            faction_fog.visible_tiles[pos] = true
            
            -- Reveal permanently if not already known
            if not faction_fog.known_tiles[pos] then
                faction_fog.known_tiles[pos] = true
                table.insert(new_revelations, pos)
            end
        end
    end
    
    -- Process new revelations
    if #new_revelations > 0 then
        process_new_revelations(faction, new_revelations, fog_state, battlefield)
    end
    
    faction_fog.last_update = get_current_turn()
end
```

#### Strategic Exploration Planning

```lua
function plan_strategic_exploration(battle_side, fog_state, mission_objectives)
    local exploration_plan = {
        priority_zones = {},
        assigned_groups = {},
        risk_assessment = {},
        time_allocation = {}
    }
    
    -- Identify unknown areas
    local unknown_regions = identify_unknown_regions(fog_state[battle_side.id])
    
    -- Prioritize based on objectives
    for _, region in ipairs(unknown_regions) do
        local priority = calculate_region_priority(region, mission_objectives, fog_state)
        region.priority = priority
    end
    
    -- Sort by priority
    table.sort(unknown_regions, function(a, b) return a.priority > b.priority end)
    
    -- Assign exploration resources
    exploration_plan = assign_exploration_resources(battle_side, unknown_regions, fog_state)
    
    return exploration_plan
end
```

#### Revealed Terrain Response

```lua
function adapt_to_revealed_terrain(faction, new_revelations, fog_state, battlefield)
    local adaptations = {
        new_opportunities = {},
        new_threats = {},
        strategic_changes = {},
        tactical_updates = {}
    }
    
    for _, position in ipairs(new_revelations) do
        local tile_info = battlefield.tiles[position]
        
        -- Identify terrain features
        if is_chokepoint(tile_info) then
            table.insert(adaptations.new_opportunities, {
                type = "chokepoint_control",
                position = position,
                value = calculate_chokepoint_value(position, battlefield)
            })
        end
        
        if is_ambush_position(tile_info) then
            table.insert(adaptations.new_threats, {
                type = "ambush_risk",
                position = position,
                risk_level = assess_ambush_risk(position, faction)
            })
        end
        
        if is_cover_position(tile_info) then
            table.insert(adaptations.new_opportunities, {
                type = "defensive_position",
                position = position,
                cover_rating = tile_info.cover_value
            })
        end
    end
    
    -- Generate adaptation strategies
    adaptations.strategic_changes = generate_strategic_adaptations(adaptations, faction)
    adaptations.tactical_updates = generate_tactical_updates(adaptations, faction)
    
    return adaptations
end
```

## Related Wiki Pages

- [Unit AI.md](../ai/Unit%20AI.md) - Individual unit exploration behaviors and positioning
- [Squad AI.md](../ai/Squad%20AI.md) - Group-level exploration coordination and tactics
- [Strategic AI.md](../ai/Strategic%20AI.md) - Mission-level exploration planning and resource allocation
- [Map Nodes.md](../ai/Map%20Nodes.md) - Navigation waypoints used in exploration patterns
- [Movement.md](../ai/Movement.md) - Pathfinding algorithms for exploration movement
- [Behaviors.md](../ai/Behaviors.md) - Unit behavior types that incorporate exploration roles
- [Lighting & Fog of War.md](../battlescape/Lighting%20&%20Fog%20of%20War.md) - Visual mechanics that interact with exploration
- [Battle tile.md](../battlescape/Battle%20tile.md) - Terrain properties revealed through exploration
- [Terrain Elevation.md](../battlescape/Terrain%20Elevation.md) - Height-based visibility and exploration challenges
- [Line of sight.md](../battlescape/Line%20of%20sight.md) - Vision calculations that drive map revelation

## References to Existing Games and Mechanics

The Map Discovery and Exploration AI system draws from asymmetric information mechanics in strategy and tactical games:

- **XCOM series (1994-2016)**: Fog of war exploration with permanent map revelation and scouting behaviors
- **Fire Emblem series (1990-2023)**: Vision radius-based map discovery and exploration planning
- **Advance Wars series (2001-2018)**: Unit vision ranges and fog of war tactical considerations
- **Jagged Alliance series (1994-2014)**: Detailed exploration with mercenary scouting and map revelation
- **Fallout series (1997-2023)**: Local map exploration with fog of war and area discovery
- **Deus Ex series (2000-2017)**: Stealth-based exploration with vision cones and detection mechanics
- **Civilization series (1991-2023)**: Strategic exploration with unit movement and map discovery
- **Total War series (2000-2022)**: Large-scale exploration with scouting units and fog of war
- **Divinity: Original Sin series (2014-2018)**: Environmental exploration with height-based visibility
- **Pillars of Eternity (2015)**: Party-based exploration with fog of war and area discovery
            known_tiles = {},  -- Revealed tile positions
            visible_tiles = {}, -- Currently visible tiles
            explored_regions = {}, -- Fully explored areas
            unknown_regions = {}, -- Identified but unexplored areas
            last_update = 0
        }
    end
    
    -- Initialize with deployment zone knowledge
    for _, faction in ipairs(factions) do
        reveal_deployment_zone(fog_state[faction], battlefield, faction)
    end
    
    return fog_state
end
```

### Strategic Exploration Planning

```lua
function plan_strategic_exploration(battle_side, fog_state, mission_objectives)
    local exploration_plan = {
        priority_zones = {},
        assigned_groups = {},
        risk_assessment = {},
        time_allocation = {}
    }
    
    -- Identify unknown areas
    local unknown_regions = identify_unknown_regions(fog_state[battle_side.id])
    
    -- Prioritize based on objectives
    for _, region in ipairs(unknown_regions) do
        local priority = calculate_region_priority(region, mission_objectives, fog_state)
        region.priority = priority
    end
    
    -- Sort by priority
    table.sort(unknown_regions, function(a, b) return a.priority > b.priority end)
    
    -- Assign exploration resources
    exploration_plan = assign_exploration_resources(battle_side, unknown_regions, fog_state)
    
    return exploration_plan
end
```

### Group-Level Exploration Coordination

```lua
function coordinate_group_exploration(group, exploration_zone, fog_state)
    local exploration_tactic = select_exploration_tactic(group, exploration_zone)
    
    -- Assign roles within group
    local roles = assign_exploration_roles(group.units, exploration_tactic)
    
    -- Plan movement patterns
    local movement_plan = plan_exploration_pattern(exploration_zone, exploration_tactic, roles)
    
    -- Set up communication waypoints
    local waypoints = establish_communication_points(exploration_zone, group)
    
    return {
        tactic = exploration_tactic,
        roles = roles,
        movement_plan = movement_plan,
        waypoints = waypoints,
        contingency_plans = generate_exploration_contingencies(group, exploration_zone)
    }
end
```

### Revealed Terrain Response

```lua
function adapt_to_revealed_terrain(faction, new_revelations, fog_state, battlefield)
    local adaptations = {
        new_opportunities = {},
        new_threats = {},
        strategic_changes = {},
        tactical_updates = {}
    }
    
    for _, position in ipairs(new_revelations) do
        local tile_info = battlefield.tiles[position]
        
        -- Identify terrain features
        if is_chokepoint(tile_info) then
            table.insert(adaptations.new_opportunities, {
                type = "chokepoint_control",
                position = position,
                value = calculate_chokepoint_value(position, battlefield)
            })
        end
        
        if is_ambush_position(tile_info) then
            table.insert(adaptations.new_threats, {
                type = "ambush_risk",
                position = position,
                risk_level = assess_ambush_risk(position, faction)
            })
        end
        
        if is_cover_position(tile_info) then
            table.insert(adaptations.new_opportunities, {
                type = "defensive_position",
                position = position,
                cover_rating = tile_info.cover_value
            })
        end
    end
    
    -- Generate adaptation strategies
    adaptations.strategic_changes = generate_strategic_adaptations(adaptations, faction)
    adaptations.tactical_updates = generate_tactical_updates(adaptations, faction)
    
    return adaptations
end
```

### Dynamic Pathfinding Updates

```lua
function update_exploration_paths(faction, adaptations, existing_paths)
    local updated_paths = {}
    
    for _, path in ipairs(existing_paths) do
        local path_updates = {}
        
        -- Check for new obstacles
        for _, threat in ipairs(adaptations.new_threats) do
            if path_crosses_threat(path, threat) then
                table.insert(path_updates, {
                    type = "avoid_threat",
                    threat = threat,
                    alternative_route = find_safe_detour(path, threat, adaptations)
                })
            end
        end
        
        -- Check for new opportunities
        for _, opportunity in ipairs(adaptations.new_opportunities) do
            if path_near_opportunity(path, opportunity) then
                table.insert(path_updates, {
                    type = "exploit_opportunity",
                    opportunity = opportunity,
                    modified_path = incorporate_opportunity(path, opportunity)
                })
            end
        end
        
        -- Apply updates
        if #path_updates > 0 then
            updated_paths[path.id] = apply_path_updates(path, path_updates)
        else
            updated_paths[path.id] = path
        end
    end
    
    return updated_paths
end
```

### Cross-Level Information Flow

```lua
function share_exploration_intelligence(source_level, intelligence, target_levels)
    local processed_intelligence = {
        raw_data = intelligence,
        processed_at = get_current_time(),
        source_level = source_level,
        confidence = calculate_intelligence_confidence(intelligence),
        propagation_path = {}
    }
    
    -- Process for each target level
    for _, target_level in ipairs(target_levels) do
        local level_specific_intelligence = adapt_intelligence_for_level(
            processed_intelligence, 
            target_level
        )
        
        -- Update level knowledge
        update_level_knowledge(target_level, level_specific_intelligence)
        
        -- Track propagation
        table.insert(processed_intelligence.propagation_path, {
            level = target_level,
            timestamp = get_current_time(),
            adaptation = level_specific_intelligence.adaptation_type
        })
    end
    
    return processed_intelligence
end
```

### Learning from Exploration

```lua
function learn_from_exploration(exploration_results, faction_history)
    local lessons_learned = {
        successful_patterns = {},
        failed_patterns = {},
        terrain_insights = {},
        risk_assessments = {}
    }
    
    -- Analyze successful explorations
    for _, success in ipairs(exploration_results.successes) do
        local pattern = extract_exploration_pattern(success)
        table.insert(lessons_learned.successful_patterns, pattern)
    end
    
    -- Analyze failed explorations
    for _, failure in ipairs(exploration_results.failures) do
        local pattern = extract_failure_pattern(failure)
        table.insert(lessons_learned.failed_patterns, pattern)
    end
    
    -- Update faction exploration preferences
    update_exploration_preferences(faction_history, lessons_learned)
    
    return lessons_learned
end
```

### Exploration Risk Evaluation

```lua
function assess_exploration_risk(exploration_plan, fog_state, battlefield)
    local risk_assessment = {
        overall_risk = 0,
        zone_risks = {},
        mitigation_strategies = {},
        acceptable_threshold = 0
    }
    
    -- Evaluate each exploration zone
    for _, zone in ipairs(exploration_plan.priority_zones) do
        local zone_risk = calculate_zone_risk(zone, fog_state, battlefield)
        risk_assessment.zone_risks[zone.id] = zone_risk
        
        -- Weight by zone priority
        risk_assessment.overall_risk = risk_assessment.overall_risk + 
            (zone_risk * zone.priority / 100)
    end
    
    -- Determine acceptable risk threshold
    risk_assessment.acceptable_threshold = calculate_risk_threshold(exploration_plan, fog_state)
    
    -- Generate mitigation strategies
    if risk_assessment.overall_risk > risk_assessment.acceptable_threshold then
        risk_assessment.mitigation_strategies = generate_risk_mitigations(
            exploration_plan, 
            risk_assessment
        )
    end
    
    return risk_assessment
end
```

### Safe Exploration Patterns

```lua
function implement_safe_exploration(group, exploration_plan, risk_assessment)
    local safe_plan = table.deepcopy(exploration_plan)
    
    -- Apply risk mitigations
    for _, mitigation in ipairs(risk_assessment.mitigation_strategies) do
        if mitigation.type == "reduce_speed" then
            safe_plan.movement_mode = "cautious"
            safe_plan.speed_modifier = 0.7
        elseif mitigation.type == "increase_spacing" then
            safe_plan.formation = "loose_screen"
            safe_plan.unit_spacing = mitigation.recommended_spacing
        elseif mitigation.type == "add_overwatch" then
            safe_plan.overwatch_positions = select_overwatch_positions(
                safe_plan.exploration_zone, 
                group
            )
        end
    end
    
    -- Add emergency waypoints
    safe_plan.emergency_waypoints = identify_emergency_positions(
        safe_plan.exploration_zone, 
        group, 
        risk_assessment
    )
    
    return safe_plan
end
```

### Custom Exploration Behaviors

```toml
[custom_exploration.beast_scouting]
tactic_type = "scent_tracking"
movement_pattern = "zigzag_search"
risk_tolerance = 60
detection_bonus = 25
special_abilities = ["scent_marking", "pack_communication"]

[exploration_tactic.zigzag_search]
description = "Alternating diagonal movements for systematic coverage"
efficiency = 85
stealth_rating = 70
speed_modifier = 0.8
detection_avoidance = 30
```

### Terrain-Specific Rules

```lua
function custom_terrain_exploration(unit, terrain_type, exploration_context)
    if terrain_type == "alien_ruins" then
        -- Special exploration for alien ruins
        return {
            movement_mode = "investigate",
            scanning_pattern = "ruins_search",
            risk_modifier = 1.2,  -- More dangerous
            discovery_bonus = 1.5  -- More valuable finds
        }
    elseif terrain_type == "dense_forest" then
        -- Forest exploration tactics
        return {
            movement_mode = "stealth",
            scanning_pattern = "forest_probe",
            risk_modifier = 0.8,  -- Less dangerous
            discovery_bonus = 0.9  -- Harder to find things
        }
    end
end
```

This map discovery and exploration AI design creates dynamic, adaptive behavior that respects fog of war while maintaining deterministic outcomes for testing and modding purposes.