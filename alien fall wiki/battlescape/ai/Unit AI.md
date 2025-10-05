# Unit AI

## Overview

The Unit AI system governs individual unit behavior in tactical combat, managing immediate decision-making within the hierarchical AI framework. Operating at the lowest level of the AI hierarchy, it handles target selection, positioning, action choice, and threat response using deterministic algorithms that create emergent tactical behaviors. The system balances individual initiative with group coordination, adapting to changing battlefield conditions while maintaining predictable outcomes for testing and balancing.

### Key Characteristics

- **Immediate Decision Making**: Real-time responses to local threats and opportunities
- **Limited Local Knowledge**: Decision making based on visible enemies and nearby terrain
- **Deterministic Behavior**: Rule-based logic ensuring consistent, testable outcomes
- **Emergent Coordination**: Individual behaviors create complex group tactics
- **Psychological Simulation**: Morale and panic systems affecting decision quality
- **Performance Optimized**: Hierarchical processing with cached calculations

### Integration with AI Hierarchy

The Unit AI operates within the broader AI framework:

- **Strategic AI**: Provides mission context and objective priorities
- **Squad AI**: Coordinates group formations and maneuvers
- **Unit AI**: Executes individual actions and positioning
- **Map Nodes**: Provides waypoint system for movement coordination
- **Behaviors**: Defines action patterns and energy management

## Mechanics

### State Machine

The Unit AI employs a finite state machine managing behavioral modes:

- **Idle**: Default state awaiting orders or opportunities
- **Moving**: Navigation between positions using map nodes
- **Combat**: Active engagement with selected targets
- **Overwatch**: Vigilant monitoring while providing covering fire
- **Suppression**: Sustained fire to pin down enemy units
- **Panic**: Disordered behavior under extreme stress
- **Fleeing**: Emergency withdrawal from lethal threats
- **Seeking Cover**: Tactical repositioning for protection
- **Explore**: Systematic investigation of unknown areas

### Situation Assessment

Local tactical evaluation considers immediate battlefield conditions:

- **Visible Enemies**: Threat detection and prioritization
- **Visible Allies**: Coordination opportunities and support identification
- **Nearby Cover**: Protection evaluation and positioning options
- **Current Threat**: Immediate danger assessment
- **Health/Ammo Status**: Resource availability for continued operations
- **Morale Level**: Psychological state affecting risk tolerance
- **Group Status**: Formation integrity and coordination state
- **Objective Proximity**: Mission relevance of current position
- **Terrain Safety**: Environmental hazards and advantages

### Target Selection

Intelligent threat assessment using weighted scoring system incorporating point-based victory mechanics:

- **Point Value Priority**: High-point-value targets (commanders, elites) prioritized in death match scenarios
- **Objective Relevance**: Mission-critical targets weighted by their contribution to victory points
- **Distance Factor**: Proximity bonuses for engagement efficiency
- **Visibility**: Clear line-of-sight preferences
- **Threat Level**: Prioritization of dangerous enemy types
- **Unit Role**: Specialization-based target preferences
- **Health Status**: Wounded target prioritization
- **Strategic Value**: Targets that advance mission objectives over immediate threats

### Positioning

Dynamic movement and cover management:

- **Cover Seeking**: Optimal protection evaluation and pathfinding
- **Map Node Navigation**: Waypoint-based movement coordination
- **Dynamic Pathfinding**: Adaptive routing around obstacles and threats
- **Formation Maintenance**: Group cohesion during repositioning
- **Terrain Optimization**: Environmental advantage exploitation

### Action Selection

Weighted decision system balancing multiple factors with point-based strategic awareness:

- **Point Maximization**: Actions that contribute to victory points prioritized
- **Objective Advancement**: Moves that progress mission goals over immediate combat
- **Health Management**: Medical attention and safety priorities
- **Ammo Conservation**: Resource efficiency and resupply considerations
- **Threat Response**: Immediate danger mitigation
- **Group Coordination**: Formation support and covering actions
- **Risk Assessment**: Safety versus effectiveness balancing with point-value weighting

### Psychological Factors

Mental state simulation affecting behavior:

- **Morale System**: Confidence levels influencing aggression and caution
- **Panic Triggers**: Stress-induced irrational responses
- **Behavior Degradation**: Reduced decision quality under pressure
- **Recovery Mechanisms**: Morale restoration through successful actions
- **Personality Traits**: Individual character affecting risk tolerance

### Action Selection and Usage

AI units make tactical decisions about which actions to perform based on available Action Points (AP), Energy, and situational context. The system evaluates action costs, effectiveness, and risk to create optimal turn sequences that balance immediate threats with long-term objectives.

#### Movement Actions

**Basic Movement**: Standard positioning changes with AP costs based on distance and terrain:

- **Walk Mode**: Default movement with balanced speed and stealth
- **Run Mode**: High-speed movement sacrificing stealth for rapid repositioning
- **Sneak Mode**: Slow, quiet movement prioritizing concealment over speed

**AI Decision Factors**:
- Distance to optimal position versus AP cost
- Terrain penalties and movement modifiers
- Stealth requirements based on threat proximity
- Group coordination needs for formation maintenance

#### Combat Actions

**Weapon Fire**: Primary offensive capability with AP and ammo costs:

- **Standard Fire**: Balanced accuracy and damage output
- **Suppressive Fire**: Area denial through sustained shooting
- **Precision Fire**: High-accuracy shots at reduced rate

**Throwing Actions**: Grenade and equipment deployment:

- **Grenade Types**: Fragmentation, smoke, flash, and stun grenades
- **Arc Calculations**: Trajectory prediction for optimal targeting
- **Risk Assessment**: Collateral damage evaluation

**AI Targeting Logic**:
- Target prioritization based on threat level and objective relevance
- Ammo conservation versus engagement opportunity
- Suppressive fire for area control and enemy pinning
- Grenade usage for breaching and area denial

#### Defensive Actions

**Overwatch**: AP investment for reaction fire during enemy turns:

- **Investment Scaling**: Reaction strength proportional to AP committed
- **Trigger Conditions**: Enemy movement and combat actions
- **Resource Management**: AP allocation balancing current defense with future actions

**Cover and Crouch**: Tactical positioning for protection:

- **Cover Evaluation**: Protection quality and positioning requirements
- **Crouch Benefits**: Accuracy penalties for attackers, movement penalties for unit
- **Dynamic Positioning**: Real-time cover seeking during movement

**AI Defensive Logic**:
- Overwatch investment based on position vulnerability
- Cover prioritization for high-threat situations
- Crouch timing to maximize defensive benefits

#### Utility and Special Actions

**Rest Action**: AP consumption for Energy and morale recovery:

- **Energy Regeneration**: Turn-based resource restoration
- **Morale Recovery**: Psychological state improvement
- **Strategic Timing**: Resource management for sustained operations

**Reload Action**: Weapon ammunition replenishment:

- **Ammo Management**: Conservation versus availability
- **Timing Optimization**: Reload during low-threat periods
- **Backup Weapons**: Alternative weapon system utilization

**Special Abilities**: Unit-specific capabilities with Energy costs:

- **Medical Actions**: Healing and status effect removal
- **Psionic Abilities**: Mental powers with Energy drain
- **Equipment Usage**: Special gear activation and deployment

**AI Utility Logic**:
- Rest timing based on Energy requirements for planned actions
- Reload prioritization when primary weapons are depleted
- Special ability usage based on tactical advantage and Energy availability

#### Action Sequencing and Planning

**Turn Optimization**: Multi-action sequences maximizing tactical effectiveness:

- **Resource Budgeting**: AP and Energy allocation across turn actions
- **Sequence Validation**: Feasibility checking for planned action combinations
- **Fallback Planning**: Alternative sequences if primary plans fail
- **Opportunity Cost**: Balancing immediate actions against future flexibility

**Situational Adaptation**:

- **High-Threat Scenarios**: Prioritizing defensive actions and rapid repositioning
- **Low-Threat Periods**: Resource recovery and position optimization
- **Objective-Driven**: Action selection aligned with mission priorities
- **Group Synergy**: Coordination with squad actions and overwatch coverage

**Performance Considerations**:

- **Decision Caching**: Precomputed action evaluations for common situations
- **Hierarchical Planning**: Different complexity levels for immediate vs. strategic decisions
- **Resource Prediction**: Anticipating future AP and Energy requirements
- **Fallback Behaviors**: Default action sequences when optimal planning fails

## Examples

### Mission Types

#### Assault Operations
Aggressive close-quarters combat scenarios:

- **Primary Goal**: Enemy elimination through direct engagement
- **Tactical Focus**: Close-range combat and room clearing
- **Risk Tolerance**: High acceptance with aggressive target selection
- **Positioning**: Flanking maneuvers and cover exploitation

#### Reconnaissance Patrols
Intelligence gathering with minimal contact:

- **Primary Goal**: Area exploration and information collection
- **Tactical Focus**: Stealth movement and observation
- **Risk Tolerance**: Very low with evasion prioritization
- **Positioning**: High ground utilization and concealed routes

#### Defense Operations
Protective holding actions:

- **Primary Goal**: Position maintenance and threat neutralization
- **Tactical Focus**: Overwatch coverage and suppression fire
- **Risk Tolerance**: Medium with conservation emphasis
- **Positioning**: Defensive terrain optimization

#### Extraction Missions
Protective escort scenarios:

- **Primary Goal**: Asset protection during withdrawal
- **Tactical Focus**: Escort formation and threat interception
- **Risk Tolerance**: Variable based on asset value
- **Positioning**: Screen formation and route security

### Decision Scenarios

#### Ambush Response
Surprise contact requiring immediate adaptation:

- **Threat Detection**: Rapid enemy identification and assessment
- **Position Evaluation**: Immediate cover seeking and positioning
- **Response Coordination**: Alert communication to nearby units
- **Counter-Action**: Suppressive fire and flanking opportunities

#### Suppression Under Fire
Pinned position requiring tactical adjustment:

- **Cover Assessment**: Available protection evaluation
- **Movement Timing**: Coordinated repositioning opportunities
- **Return Fire**: Selective engagement during movement windows
- **Support Request**: Group coordination for covering fire

#### Low Ammo Crisis
Resource depletion requiring behavioral adaptation:

- **Conservation Mode**: Reduced engagement and positioning focus
- **Resupply Seeking**: Safe route calculation to ammunition sources
- **Alternative Actions**: Melee combat or overwatch prioritization
- **Group Support**: Ammunition sharing and covering fire requests

### Code Examples

#### State Machine Implementation

```lua
local ai_states = {
    IDLE = "idle",
    MOVING = "moving", 
    COMBAT = "combat",
    OVERWATCH = "overwatch",
    SUPPRESSION = "suppression",
    PANIC = "panic",
    FLEEING = "fleeing",
    SEEKING_COVER = "seeking_cover",
    EXPLORE = "explore"
}

function update_unit_ai(unit, game_state)
    local current_state = unit.ai_state or ai_states.IDLE
    
    -- Assess immediate situation
    local situation = assess_local_situation(unit, game_state)
    
    -- Determine appropriate state
    local new_state = determine_ai_state(unit, situation, current_state)
    
    -- Execute state behavior
    if new_state ~= current_state then
        transition_ai_state(unit, current_state, new_state)
    end
    
    execute_ai_state(unit, new_state, situation)
end
```

#### Target Selection Algorithm

```lua
function select_target(unit, visible_enemies, situation)
    local targets = {}
    
    for _, enemy in ipairs(visible_enemies) do
        local target_score = calculate_target_score(unit, enemy, situation)
        table.insert(targets, {enemy = enemy, score = target_score})
    end
    
    -- Sort by score (highest first)
    table.sort(targets, function(a, b) return a.score > b.score end)
    
    return targets[1] and targets[1].enemy or nil
end

function calculate_target_score(unit, enemy, situation)
    local score = 0
    
    -- Distance factor (prefer closer targets)
    local distance = distance(unit.position, enemy.position)
    score = score + (100 - distance * 2)
    
    -- Visibility factor (prefer clear line of sight)
    if has_clear_los(unit.position, enemy.position) then
        score = score + 30
    end
    
    -- Threat level (prioritize dangerous enemies)
    local threat_level = assess_enemy_threat(enemy)
    score = score + threat_level * 0.5
    
    -- Unit role priority
    if unit.role == "sniper" and distance > 15 then
        score = score + 40  -- Snipers prefer distant targets
    elseif unit.role == "assault" and distance < 5 then
        score = score + 35  -- Assault units prefer close combat
    end
    
    -- Health factor (prefer wounded targets)
    if enemy.health / enemy.max_health < 0.3 then
        score = score + 25
    end
    
    -- Objective relevance
    if is_objective_target(enemy) then
        score = score + 50
    end
    
    return score
end
```

#### Engagement Decision Logic

```lua
function decide_engagement(unit, target, situation)
    local decision = {
        should_engage = false,
        action_type = nil,
        positioning = nil
    }
    
    -- Don't engage if heavily suppressed
    if situation.current_threat > 80 then
        return decision
    end
    
    -- Check ammo and health
    if situation.ammo_status < 0.1 or situation.health_status < 0.2 then
        return decision
    end
    
    -- Determine engagement type
    local distance = distance(unit.position, target.position)
    
    if distance <= unit.weapon.melee_range then
        decision.action_type = "melee_attack"
        decision.should_engage = true
    elseif distance <= unit.weapon.effective_range then
        decision.action_type = "ranged_attack"
        decision.should_engage = true
        
        -- Consider suppression for close targets
        if distance < 10 and situation.group_status == "providing_cover" then
            decision.action_type = "suppressive_fire"
        end
    else
        -- Too far, consider moving closer
        decision.should_engage = false
        decision.positioning = "close_distance"
    end
    
    return decision
end
```

#### Action Selection and Sequencing

```lua
function select_optimal_actions(unit, available_ap, available_energy, situation, mission_state)
    local action_plan = {
        actions = {},
        total_ap_cost = 0,
        total_energy_cost = 0,
        expected_outcome = "neutral"
    }
    
    -- Determine primary objective based on situation
    local primary_objective = determine_primary_objective(unit, situation, mission_state)
    
    -- Select action sequence based on objective
    if primary_objective == "engage_threat" then
        action_plan = plan_combat_sequence(unit, available_ap, available_energy, situation)
    elseif primary_objective == "seek_cover" then
        action_plan = plan_defensive_sequence(unit, available_ap, available_energy, situation)
    elseif primary_objective == "move_position" then
        action_plan = plan_movement_sequence(unit, available_ap, available_energy, situation)
    elseif primary_objective == "recover_resources" then
        action_plan = plan_recovery_sequence(unit, available_ap, available_energy, situation)
    end
    
    -- Validate action plan feasibility
    if not validate_action_plan(action_plan, available_ap, available_energy) then
        action_plan = generate_fallback_plan(unit, available_ap, available_energy)
    end
    
    return action_plan
end

function plan_combat_sequence(unit, ap, energy, situation)
    local plan = {actions = {}, total_ap_cost = 0, total_energy_cost = 0}
    
    -- Select target
    local target = select_target(unit, situation.visible_enemies, situation)
    if not target then return plan end
    
    local distance = distance(unit.position, target.position)
    
    -- Determine combat action based on range and resources
    if distance <= unit.weapon.melee_range and ap >= 2 then
        table.insert(plan.actions, {type = "melee_attack", target = target, ap_cost = 2})
        plan.total_ap_cost = plan.total_ap_cost + 2
    elseif distance <= unit.weapon.effective_range and unit.ammo > 0 and ap >= unit.weapon.ap_cost then
        local action_type = "ranged_attack"
        
        -- Consider suppressive fire if close and group supports
        if distance < 10 and situation.group_status == "providing_cover" and ap >= 3 then
            action_type = "suppressive_fire"
            plan.total_ap_cost = plan.total_ap_cost + 3
        else
            plan.total_ap_cost = plan.total_ap_cost + unit.weapon.ap_cost
        end
        
        table.insert(plan.actions, {
            type = action_type, 
            target = target, 
            ap_cost = plan.total_ap_cost
        })
    end
    
    -- Consider movement if too far for effective engagement
    if distance > unit.weapon.effective_range and ap > plan.total_ap_cost + 1 then
        local move_cost = calculate_movement_cost(unit, target.position, "run")
        if ap >= plan.total_ap_cost + move_cost then
            table.insert(plan.actions, {
                type = "move", 
                destination = get_closer_position(unit, target), 
                mode = "run",
                ap_cost = move_cost
            })
            plan.total_ap_cost = plan.total_ap_cost + move_cost
        end
    end
    
    return plan
end

function plan_defensive_sequence(unit, ap, energy, situation)
    local plan = {actions = {}, total_ap_cost = 0, total_energy_cost = 0}
    
    -- Find optimal cover
    local cover_position = find_optimal_cover(unit, situation.visible_enemies, situation)
    
    if cover_position and ap >= 1 then
        -- Move to cover if not already there
        if distance(unit.position, cover_position) > 0 then
            local move_cost = calculate_movement_cost(unit, cover_position, "run")
            if ap >= move_cost then
                table.insert(plan.actions, {
                    type = "move", 
                    destination = cover_position, 
                    mode = "run",
                    ap_cost = move_cost
                })
                plan.total_ap_cost = plan.total_ap_cost + move_cost
                ap = ap - move_cost
            end
        end
        
        -- Crouch for additional defense
        if ap >= 1 then
            table.insert(plan.actions, {type = "crouch", ap_cost = 1})
            plan.total_ap_cost = plan.total_ap_cost + 1
            ap = ap - 1
        end
        
        -- Set up overwatch if AP remains
        if ap >= 1 then
            local overwatch_investment = math.min(ap, 3) -- Max 3 AP for overwatch
            table.insert(plan.actions, {
                type = "overwatch", 
                ap_investment = overwatch_investment,
                ap_cost = overwatch_investment
            })
            plan.total_ap_cost = plan.total_ap_cost + overwatch_investment
        end
    end
    
    return plan
end

function plan_movement_sequence(unit, ap, energy, situation)
    local plan = {actions = {}, total_ap_cost = 0, total_energy_cost = 0}
    
    -- Determine movement mode based on situation
    local movement_mode = "walk" -- Default
    
    if situation.threat_level > 50 then
        movement_mode = "run" -- Speed over stealth when threatened
    elseif situation.requires_stealth then
        movement_mode = "sneak" -- Stealth when avoiding detection
    end
    
    -- Calculate maximum movement distance
    local max_distance = calculate_max_movement(unit, ap, movement_mode)
    
    -- Find optimal destination
    local destination = find_optimal_destination(unit, situation, max_distance)
    
    if destination then
        local move_cost = calculate_movement_cost(unit, destination, movement_mode)
        table.insert(plan.actions, {
            type = "move",
            destination = destination,
            mode = movement_mode,
            ap_cost = move_cost
        })
        plan.total_ap_cost = plan.total_ap_cost + move_cost
    end
    
    return plan
end

function plan_recovery_sequence(unit, ap, energy, situation)
    local plan = {actions = {}, total_ap_cost = 0, total_energy_cost = 0}
    
    -- Check if rest is beneficial
    local energy_needed = unit.max_energy - unit.energy
    local morale_needed = 100 - unit.morale
    
    if energy_needed > 10 or morale_needed > 20 then
        -- Calculate rest cost (typically 1-2 AP for significant recovery)
        local rest_cost = 2
        if ap >= rest_cost then
            table.insert(plan.actions, {type = "rest", ap_cost = rest_cost})
            plan.total_ap_cost = plan.total_ap_cost + rest_cost
        end
    end
    
    -- Consider reload if ammo is low
    if unit.ammo / unit.max_ammo < 0.3 and ap > plan.total_ap_cost + 1 then
        table.insert(plan.actions, {type = "reload", ap_cost = 1})
        plan.total_ap_cost = plan.total_ap_cost + 1
    end
    
    return plan
end

function validate_action_plan(plan, available_ap, available_energy)
    -- Check total resource costs
    if plan.total_ap_cost > available_ap or plan.total_energy_cost > available_energy then
        return false
    end
    
    -- Check individual action requirements
    for _, action in ipairs(plan.actions) do
        if action.ap_cost < 0 or action.energy_cost < 0 then
            return false
        end
        
        -- Validate action-specific requirements
        if action.type == "ranged_attack" and unit.ammo <= 0 then
            return false
        end
        
        if action.type == "suppressive_fire" and unit.ammo < 3 then
            return false
        end
    end
    
    return true
end
```

#### Cover Seeking Algorithm

```lua
function find_optimal_cover(unit, threats, game_state)
    local best_cover = nil
    local best_score = -1
    
    -- Evaluate all nearby cover positions
    local nearby_cover = find_nearby_cover(unit.position, 20)
    
    for _, cover_pos in ipairs(nearby_cover) do
        local score = evaluate_cover_position(unit, cover_pos, threats, game_state)
        
        if score > best_score then
            best_score = score
            best_cover = cover_pos
        end
    end
    
    return best_cover
end

function evaluate_cover_position(unit, position, threats, game_state)
    local score = 0
    
    -- Distance to current position (prefer closer)
    local distance = distance(unit.position, position)
    score = score + (50 - distance)
    
    -- Protection from threats
    local protection = calculate_cover_protection(position, threats)
    score = score + protection * 2
    
    -- Line of sight to objectives
    if maintains_objective_los(unit, position) then
        score = score + 30
    end
    
    -- Group cohesion
    local group_distance = distance_to_group(unit, position)
    score = score + (20 - group_distance)
    
    -- Terrain safety
    local terrain_safety = evaluate_terrain_safety(position)
    score = score + terrain_safety
    
    return score
end
```

### Engagement Decision

```lua
function decide_engagement(unit, target, situation)
    local decision = {
        should_engage = false,
        action_type = nil,
        positioning = nil
    }
    
    -- Don't engage if heavily suppressed
    if situation.current_threat > 80 then
        return decision
    end
    
    -- Check ammo and health
    if situation.ammo_status < 0.1 or situation.health_status < 0.2 then
        return decision
    end
    
    -- Determine engagement type
    local distance = distance(unit.position, target.position)
    
    if distance <= unit.weapon.melee_range then
        decision.action_type = "melee_attack"
        decision.should_engage = true
    elseif distance <= unit.weapon.effective_range then
        decision.action_type = "ranged_attack"
        decision.should_engage = true
        
        -- Consider suppression for close targets
        if distance < 10 and situation.group_status == "providing_cover" then
            decision.action_type = "suppressive_fire"
        end
    else
        -- Too far, consider moving closer
        decision.should_engage = false
        decision.positioning = "close_distance"
    end
    
    return decision
end
```

### Cover Seeking

```lua
function find_optimal_cover(unit, threat_direction, situation)
    local nearby_cover = situation.nearby_cover
    local best_cover = nil
    local best_score = -1
    
    for _, cover_position in ipairs(nearby_cover) do
        local score = evaluate_cover_position(unit, cover_position, threat_direction, situation)
        
        if score > best_score then
            best_score = score
            best_cover = cover_position
        end
    end
    
    return best_cover
end

function evaluate_cover_position(unit, position, threat_direction, situation)
    local score = 0
    
    -- Distance to current position (prefer closer)
    local distance = distance(unit.position, position)
    score = score + (20 - distance)
    
    -- Cover quality
    local cover_rating = get_cover_rating(position)
    score = score + cover_rating * 2
    
    -- Protection from threats
    if provides_cover_from(position, threat_direction) then
        score = score + 40
    end
    
    -- Line of sight to objective
    if maintains_los_to_objective(position, unit.objective) then
        score = score + 15
    end
    
    -- Group cohesion
    local group_distance = distance_to_group(unit, position)
    if group_distance < 5 then
        score = score + 10
    end
    
    -- Terrain safety
    local terrain_safety = evaluate_terrain_safety(position)
    score = score + terrain_safety
    
    return score
end
```

### Map Node Navigation

```lua
function navigate_to_node(unit, target_node, situation)
    -- Check if node is accessible
    if not can_reach_node(unit, target_node) then
        return false
    end
    
    -- Calculate path using node graph
    local path = find_path_to_node(unit.position, target_node.position, unit.known_map)
    
    if not path then
        return false
    end
    
    -- Set movement waypoints
    unit.movement_waypoints = path
    
    -- Consider stealth vs speed
    if situation.requires_stealth then
        unit.movement_mode = "sneaking"
    else
        unit.movement_mode = "running"
    end
    
    return true
end
```

### Dynamic Pathfinding

```lua
function update_movement_path(unit, current_path, game_state)
    local new_path = current_path
    
    -- Check for blocked paths
    if is_path_blocked(current_path, game_state) then
        new_path = recalculate_path(unit.position, current_path[#current_path], unit.known_map)
    end
    
    -- Consider new threats
    local threat_positions = get_threat_positions(unit, game_state)
    if #threat_positions > 0 then
        new_path = avoid_threats_path(current_path, threat_positions)
    end
    
    -- Optimize for cover
    if unit.ai_state == ai_states.SEEKING_COVER then
        new_path = optimize_path_for_cover(new_path, unit)
    end
    
    return new_path
end
```

### Action Priority System

```lua
function select_action(unit, available_actions, situation)
    local action_scores = {}
    
    for _, action in ipairs(available_actions) do
        local score = evaluate_action(unit, action, situation)
        table.insert(action_scores, {action = action, score = score})
    end
    
    -- Sort by score
    table.sort(action_scores, function(a, b) return a.score > b.score end)
    
    return action_scores[1] and action_scores[1].action or nil
end

function evaluate_action(unit, action, situation)
    local score = action.base_priority or 0
    
    -- Health considerations
    if action.type == "heal" and situation.health_status < 0.5 then
        score = score + 50
    end
    
    -- Ammo considerations
    if action.type == "reload" and situation.ammo_status < 0.3 then
        score = score + 40
    end
    
    -- Threat response
    if action.type == "overwatch" and situation.current_threat > 60 then
        score = score + 35
    end
    
    -- Group coordination
    if action.type == "suppress" and situation.group_status == "advancing" then
        score = score + 30
    end
    
    -- Objective progress
    if contributes_to_objective(action, unit.objective) then
        score = score + 25
    end
    
    -- Risk assessment
    local risk_penalty = calculate_action_risk(action, situation)
    score = score - risk_penalty
    
    return score
end
```

### Reaction System

```lua
function handle_reaction_event(unit, event, situation)
    if event.type == "enemy_detected" then
        -- Assess threat
        local threat_level = assess_detection_threat(event.enemy, unit)
        
        if threat_level > 70 then
            -- High threat: seek cover immediately
            unit.ai_state = ai_states.SEEKING_COVER
            unit.target_cover = find_optimal_cover(unit, event.enemy.position, situation)
        elseif threat_level > 30 then
            -- Medium threat: prepare overwatch
            unit.ai_state = ai_states.OVERWATCH
        end
        
    elseif event.type == "ally_under_fire" then
        -- Consider providing support
        if can_provide_support(unit, event.ally) then
            unit.ai_state = ai_states.COMBAT
            unit.target = event.ally.threat
        end
        
    elseif event.type == "suppression_fire" then
        -- Forced into cover
        unit.ai_state = ai_states.SEEKING_COVER
        unit.suppressed = true
    end
end
```

### Map Discovery Behavior

```lua
function explore_unknown_area(unit, unknown_position, situation)
    -- Check exploration safety
    if situation.current_threat > 40 then
        return false  -- Too dangerous
    end
    
    -- Calculate exploration path
    local exploration_path = calculate_exploration_path(unit.position, unknown_position, unit.known_map)
    
    if not exploration_path then
        return false
    end
    
    -- Set exploration waypoints
    unit.exploration_waypoints = exploration_path
    unit.ai_state = ai_states.EXPLORE
    
    -- Use appropriate movement mode
    unit.movement_mode = situation.requires_stealth and "sneaking" or "normal"
    
    return true
end
```

### Intelligence Gathering

```lua
function share_discovered_intelligence(unit, discovered_info)
    -- Update personal knowledge
    unit.known_map = merge_map_knowledge(unit.known_map, discovered_info)
    
    -- Signal group if applicable
    if unit.group then
        send_group_signal(unit, "intelligence_update", {
            discovered_positions = discovered_info,
            source_unit = unit.id
        })
    end
    
    -- Update strategic AI
    report_to_strategic_ai(unit.faction, discovered_info)
end
```

### Morale and Panic

```lua
function apply_morale_effects(unit, decision)
    local morale_modifier = (unit.morale - 50) / 50  -- -1 to +1 scale
    
    -- Risk tolerance
    decision.risk_tolerance = decision.risk_tolerance * (1 + morale_modifier * 0.5)
    
    -- Aggressiveness
    if morale_modifier > 0.3 then
        decision.preferred_actions = prefer_aggressive_actions(decision.preferred_actions)
    elseif morale_modifier < -0.3 then
        decision.preferred_actions = prefer_defensive_actions(decision.preferred_actions)
    end
    
    -- Panic check
    if unit.morale < 20 and math.random() < 0.1 then
        unit.ai_state = ai_states.PANIC
        decision = generate_panic_behavior(unit)
    end
    
    return decision
end
```

### Panic Behavior

```lua
function generate_panic_behavior(unit)
    local panic_actions = {
        "flee_randomly",
        "fire_wildly", 
        "freeze_in_place",
        "surrender"
    }
    
    local selected_action = panic_actions[math.random(#panic_actions)]
    
    return {
        action = selected_action,
        duration = math.random(2, 5),  -- turns
        risk_tolerance = 0  -- No risk assessment in panic
    }
end
```

### Custom Unit Behaviors

```toml
[custom_unit.beast_hunter]
ai_personality = "predator"
preferred_range = "close"
risk_tolerance = 85
special_behaviors = ["pack_hunting", "scent_tracking"]

[ai_behavior.predator]
target_selection = "weakest_first"
engagement_style = "ambush"
retreat_threshold = 15
group_coordination = "pack_mentality"
```

### Behavior Scripts

```lua
function custom_predator_ai(unit, situation)
    -- Custom predator behavior
    if situation.visible_enemies then
        local weakest_enemy = find_weakest_enemy(situation.visible_enemies)
        
        if distance(unit.position, weakest_enemy.position) > 5 then
            -- Stalk the weak target
            stalk_target(unit, weakest_enemy)
        else
            -- Strike when close
            execute_ambush_attack(unit, weakest_enemy)
        end
    else
        -- Hunt for prey
        search_for_targets(unit)
    end
end
```

This individual unit AI design creates intelligent, responsive behavior while maintaining deterministic outcomes for testing and modding purposes.

## Related Wiki Pages

- [Squad AI.md](../ai/Squad%20AI.md) - Group coordination and formation management
- [Strategic AI.md](../ai/Strategic%20AI.md) - Mission-level planning and resource allocation
- [Map Nodes.md](../ai/Map%20Nodes.md) - Navigation waypoint system
- [Movement.md](../ai/Movement.md) - Pathfinding and terrain navigation
- [Behaviors.md](../ai/Behaviors.md) - Action patterns and energy management
- [Exploration.md](../ai/Exploration.md) - Map discovery and intelligence gathering
- [Unit System](../../units/Unit%20System.md) - Individual unit capabilities and attributes
- [Morale System](../../units/Morale%20System.md) - Psychological state mechanics
- [Cover System](../battlescape/Cover%20System.md) - Tactical positioning mechanics
- [Suppression](../battlescape/Suppression.md) - Combat state affecting unit behavior

## References

The Unit AI system draws from individual character behaviors in tactical and strategy games:

- **XCOM series (1994-2016)**: Individual soldier AI with positioning, cover usage, and reaction systems
- **Fire Emblem series (1990-2023)**: Character-based decision making with positioning and target selection
- **Jagged Alliance series (1994-2014)**: Individual mercenary AI with morale and tactical positioning
- **BattleTech (1984-2024)**: MechWarrior AI with positioning, target prioritization, and formation keeping
- **Divinity: Original Sin series (2014-2018)**: Character AI with environmental interaction and positioning
- **Pillars of Eternity (2015)**: Individual unit behaviors with tactical decision making
- **Mass Effect series (2007-2021)**: Squad member AI with positioning and target selection
- **Tactical RPGs**: Character positioning, cover usage, and individual initiative systems
- **Real-time Strategy Games**: Unit micro-management and individual behaviors
- **Tabletop Wargames**: Individual model activation and positioning mechanics