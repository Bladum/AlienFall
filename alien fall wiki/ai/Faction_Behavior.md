# Faction Behavior Patterns

## Table of Contents
- [Overview](#overview)
- [Mechanics](#mechanics)
  - [Faction Profile System](#faction-profile-system)
  - [Mission Priority Allocation](#mission-priority-allocation)
  - [Resource Management Framework](#resource-management-framework)
  - [Escalation Trigger System](#escalation-trigger-system)
  - [Dynamic Threat Assessment](#dynamic-threat-assessment)
  - [Adaptive Learning Behavior](#adaptive-learning-behavior)
  - [Multi-Faction Coordination](#multi-faction-coordination)
  - [Competitive Resource Dynamics](#competitive-resource-dynamics)
- [Examples](#examples)
  - [Sectoid Collective Operations](#sectoid-collective-operations)
  - [Floater Legion Campaigns](#floater-legion-campaigns)
  - [Muton Horde Territory Control](#muton-horde-territory-control)
  - [Snakeman Cult Stealth Operations](#snakeman-cult-stealth-operations)
  - [Ethereal Council Psionic Warfare](#ethereal-council-psionic-warfare)
  - [Threat-Based Behavior Adaptation](#threat-based-behavior-adaptation)
  - [Joint Faction Operations](#joint-faction-operations)
- [Related Wiki Pages](#related-wiki-pages)
- [References to Existing Games and Mechanics](#references-to-existing-games-and-mechanics)

## Overview

Faction Behavior Patterns define the strategic personalities and operational doctrines of alien factions throughout the AlienFall campaign, creating distinct adversarial identities through data-driven mission priorities, resource allocation strategies, and adaptive intelligence systems. This framework transforms homogeneous alien threats into diverse opposition forces with recognizable tactical patterns, escalation triggers, and inter-faction dynamics that respond dynamically to player actions and campaign progression.

The system emphasizes behavioral diversity through configurable faction profiles combining aggression levels, technology preferences, territorial objectives, and strategic focuses. Factions exhibit unique mission selection patterns, force composition preferences, and response strategies while maintaining deterministic behavior through seeded randomization. Adaptive learning mechanisms enable factions to counter player tactics discovered through mission outcomes, while multi-faction coordination creates emergent strategic complexity through cooperative operations and competitive resource dynamics.

## Mechanics

### Faction Profile System
Each faction maintains distinct strategic identity through configurable attributes:
- Aggression Levels: Behavioral spectrum from defensive reconnaissance to aggressive territorial expansion
- Strategic Focus: Primary objectives including intelligence gathering, direct military confrontation, resource extraction, or covert infiltration
- Technology Priorities: Research emphasis areas such as psionic development, weapons advancement, armor systems, or stealth capabilities
- Territorial Preferences: Target province selection based on population density, resource availability, geographic features, or strategic positioning
- Operational Doctrine: Preferred mission types, force composition patterns, and tactical approaches unique to faction identity

### Mission Priority Allocation
Factions distribute strategic resources across mission categories through weighted priority systems:
- Abduction Missions: Population capture operations for research and resource extraction (priority weight 0.0-1.0)
- Terror Campaigns: Intimidation operations reducing public support and increasing panic levels (priority weight 0.0-1.0)
- Infiltration Operations: Covert activities establishing strategic advantages without detection (priority weight 0.0-1.0)
- Research Expeditions: Scientific missions advancing faction technology and understanding player capabilities (priority weight 0.0-1.0)
- Base Assault Operations: Direct attacks on player infrastructure when strategic conditions warrant (priority weight 0.0-1.0)
- Supply Acquisition: Resource gathering missions securing materials for faction operations (priority weight 0.0-1.0)

Priority distributions sum to 1.0, creating distinct faction mission profiles guiding strategic planning.

### Resource Management Framework
Factions allocate limited resources across operational categories:
- UFO Production: Craft construction and deployment for reconnaissance, combat, and transport (allocation 0.0-1.0)
- Troop Training: Unit development and deployment readiness preparation (allocation 0.0-1.0)
- Research Investment: Technology advancement and counter-strategy development (allocation 0.0-1.0)
- Base Expansion: Infrastructure construction in controlled territories (allocation 0.0-1.0)

Resource allocation patterns reflect faction strategic priorities, with research-focused factions investing heavily in technology while militaristic factions prioritize troop training and UFO production.

### Escalation Trigger System
Factions respond to strategic events through probabilistic escalation mechanics:
- Player Discovery Events: Base location revelation, research breakthroughs, or technological advantages trigger response missions
- Faction Loss Events: UFO destruction, base elimination, or commander capture prompt retaliation operations
- Strategic Milestone Events: Campaign progression markers activating new operational phases
- Threat Threshold Crossings: Player strength assessments exceeding faction tolerance levels

Each trigger specifies escalation probability (0.0-1.0) determining response likelihood when conditions occur.

### Dynamic Threat Assessment
Factions continuously evaluate player capabilities through observable metrics:
- Military Strength Analysis: Interceptor count, soldier numbers, equipment quality assessment (0-40 threat points)
- Technology Advancement Tracking: Research progress monitoring through observed equipment and tactics (0-30 threat points)
- Strategic Position Evaluation: Base count, radar coverage, territorial control assessment (0-30 threat points)
- Recent Performance Metrics: Mission outcome tracking and momentum calculation (bonus threat points)

Total threat score (0-100) drives adaptive behavior adjustments including mission frequency, force size multipliers, and elite unit deployment rates.

### Adaptive Learning Behavior
Factions modify tactics based on mission outcomes and observed player strategies:
- Tactical Pattern Recognition: Explosive usage, sniper deployment, psionic capabilities, or specialized equipment identification
- Counter-Strategy Development: Force composition adjustments, terrain usage modifications, and equipment deployment changes
- Force Sizing Adaptation: Progressive multiplier increases following repeated defeats
- Strategic Exploitation: Increased pressure on under-defended areas or ignored mission categories

Learning accumulates throughout campaign, creating progressively sophisticated opposition.

### Multi-Faction Coordination
Inter-faction cooperation creates complex strategic challenges:
- Joint Operations: Coordinated multi-faction missions with sequential phasing or simultaneous pressure
- Resource Sharing: Strategic asset transfers between factions when beneficial to overall invasion goals
- Conflict Mediation: Competition resolution mechanisms preventing counter-productive faction conflicts
- Unified Escalation: Synchronized intensity increases maximizing strategic impact

### Competitive Resource Dynamics
Factions compete for strategic resources and operational opportunities:
- Priority Calculation: Resource value assessment from faction-specific perspective
- Competition Resolution: Deterministic winner selection based on comparative priority scores
- Contested Resources: Simultaneous operations when factions have equivalent priorities
- Strategic Negotiation: Implicit resource sharing and territory division based on faction specialization

## Examples

### Sectoid Collective Operations
Intelligence-focused faction emphasizing reconnaissance and psionic research. Mission priorities: abduction 40%, research 30%, terror 15%, infiltration 10%, base assault 5%. Resource allocation: research 35%, UFO production 25%, troop training 20%, base expansion 20%. Early campaign (months 1-3) deploys 2 low-intensity abduction missions and 1 research expedition monthly. Mid-campaign (months 4-6) escalates to 3 medium-intensity abductions, 1 terror mission, and begins base hunting. Late campaign (months 7+) shifts to 2 high-intensity terror operations and base assault missions. High escalation probability (90%) when Sectoid commander captured, triggering immediate retaliation.

### Floater Legion Campaigns
Militaristic faction prioritizing direct confrontation and terror operations. Mission priorities: terror 35%, supply raid 25%, base assault 20%, abduction 15%, research 5%. Resource allocation: troop training 40%, UFO production 35%, base expansion 15%, research 10%. Terror missions deploy 8 soldiers and 2 leaders at low threat, scaling to 16 soldiers, 4 leaders, and 2 commanders at high threat. Base assault operations always commit overwhelming force: 20 soldiers, 5 leaders, 3 commanders regardless of intelligence. Escalation triggers include 70% probability on player intercept success, 80% on failed terror missions, 90% on supply route disruption.

### Muton Horde Territory Control
Resource-extraction faction emphasizing territorial expansion and brute force tactics. Mission priorities: supply raid 40%, terror 30%, base assault 20%, infiltration 5%, research 5%. Resource allocation: troop training 50%, UFO production 30%, base expansion 15%, research 5%. Territory strategy prioritizes provinces with resource value exceeding 75 (critical priority, overwhelming force) and 50-75 (high priority, large force). Resource shortage triggers 100% escalation probability with immediate aggressive response. Territory loss generates 90% escalation probability. Muton berserker casualties trigger 80% retaliation probability with enraged force composition modifications.

### Snakeman Cult Stealth Operations
Covert operations faction specializing in guerrilla tactics and assassination missions. Mission priorities: infiltration 30%, terror 25%, assassination 20%, abduction 15%, base assault 10%. Resource allocation: troop training 30%, research 25%, base expansion 25%, UFO production 20%. Infiltration missions maintain 30% detection probability over 72-hour duration using scout UFOs landing in remote zones. Force composition includes 6 soldiers, 1 leader, and 2 Chryssalid terror units. Primary objectives: tracking device deployment; secondary: scientist abduction; tertiary: facility sabotage. Discovered jungle bases trigger 90% aggressive response probability.

### Ethereal Council Psionic Warfare
Strategic manipulation faction emphasizing long-term control and psionic dominance. Mission priorities: research 35%, infiltration 25%, abduction 20%, terror 10%, base assault 10%. Resource allocation: research 50%, base expansion 20%, troop training 15%, UFO production 15%. Psionic assault operations require 168-hour preparation, delivering mind control effects (30% chance, 24-hour duration), panic waves (5-tile radius, 3-turn duration), and facility disruption (50% efficiency penalty for 72 hours on labs and workshops). Force composition: 3 Ethereals, 2 Sectoid commanders, 4 Muton elites. Ethereal capture triggers 100% elimination attempt probability. Player approaching endgame conditions generates 90% final push probability.

### Threat-Based Behavior Adaptation
Player threat below 30 (weak): faction maintains 1.0× mission frequency, 0.8× force size multiplier, low aggression stance. Threat 30-60 (growing): increases to 1.2× mission frequency, 1.0× force size, moderate aggression with standard tactics. Threat 60-80 (strong): escalates to 1.5× mission frequency, 1.3× force size, high aggression with 30% elite unit deployment. Threat above 80 (dominant): triggers maximum response with 2.0× mission frequency, 1.5× force size, 60% elite unit deployment, doubled terror frequency, and 80% base assault probability representing all-out assault posture.

### Joint Faction Operations
Coordinated assault combines two factions for maximum strategic impact. Phase 1: Faction B deploys distraction terror mission in adjacent province drawing player attention and resources. Phase 2: After 6-hour delay, Faction A launches base assault on primary target while player forces engaged elsewhere. Joint operation planning considers comparative faction priorities and resource availability, with contested targets potentially triggering simultaneous operations from multiple factions when priorities balance.

## Related Wiki Pages

- [README.md](README.md) - General AI architecture and systems overview
- [Alien Strategy.md](Alien%20Strategy.md) - Strategic campaign orchestration layer
- [Geoscape AI.md](Geoscape%20AI.md) - Director authority and adaptive management
- [Battlescape AI.md](Battlescape%20AI.md) - Tactical combat AI behavior
- [Mission_Types.md](../geoscape/Mission_Types.md) - Mission generation and categories
- [World.md](../geoscape/World.md) - Territory and province systems
- [Detection.md](../geoscape/Detection.md) - Mission detection mechanics
- [Campaign.md](../lore/Campaign.md) - Campaign structure and progression
- [Alien_Species.md](../lore/Alien_Species.md) - Faction lore and characteristics

## References to Existing Games and Mechanics

- **XCOM Series**: Faction-specific alien behaviors and escalation patterns
- **Civilization Series**: AI leader personalities and diplomatic strategies
- **Total War Series**: Faction traits and strategic AI behavior
- **Europa Universalis IV**: Nation-specific AI personalities and goals
- **Stellaris**: Empire AI ethics and behavior patterns
- **StarCraft**: Race-specific tactical doctrines and unit compositions
- **Command & Conquer**: Faction-specific technology trees and unit preferences
- **Homeworld**: Fleet doctrine variations between factions
- **Phoenix Point**: Alien faction competition and evolution mechanics

### Sectoid Collective

**Profile:**
- **Aggression:** Moderate
- **Strategy:** Intelligence gathering and infiltration
- **Tech Focus:** Psi research and biological experimentation
- **Territory Goal:** Population centers for abduction operations

**Behavior Patterns:**
```lua
sectoid_behavior = {
    mission_priorities = {
        abduction = 0.40,      -- Primary focus
        research = 0.30,       -- High priority
        terror = 0.15,         -- Moderate
        infiltration = 0.10,   -- Secondary
        base_assault = 0.05    -- Rare
    },
    
    resource_allocation = {
        ufo_production = 0.25,
        troop_training = 0.20,
        research = 0.35,       -- Heavy research investment
        base_expansion = 0.20
    },
    
    escalation_triggers = {
        player_base_discovered = 0.8,  -- High chance to assault
        research_breakthrough = 0.6,   -- Escalate missions
        sectoid_commander_captured = 0.9  -- Immediate retaliation
    }
}
```

**Strategic Objectives:**
```lua
function sectoid_monthly_planning(faction_state)
    local objectives = {}
    
    -- Phase 1: Infiltration (Months 1-3)
    if faction_state.campaign_month <= 3 then
        table.insert(objectives, {
            type = "abduction",
            frequency = 2,  -- 2 per month
            intensity = "low"
        })
        table.insert(objectives, {
            type = "research",
            frequency = 1,
            intensity = "low"
        })
    
    -- Phase 2: Escalation (Months 4-6)
    elseif faction_state.campaign_month <= 6 then
        table.insert(objectives, {
            type = "abduction",
            frequency = 3,
            intensity = "medium"
        })
        table.insert(objectives, {
            type = "terror",
            frequency = 1,
            intensity = "medium"
        })
        table.insert(objectives, {
            type = "base_hunt",  -- Start looking for player bases
            frequency = 1,
            intensity = "low"
        })
    
    -- Phase 3: Dominance (Months 7+)
    else
        table.insert(objectives, {
            type = "terror",
            frequency = 2,
            intensity = "high"
        })
        table.insert(objectives, {
            type = "base_assault",
            frequency = 1,
            intensity = "high"
        })
    end
    
    return objectives
end
```

### Floater Legion

**Profile:**
- **Aggression:** High
- **Strategy:** Direct military confrontation
- **Tech Focus:** Weapons development and cybernetic enhancement
- **Territory Goal:** Strategic military installations

**Behavior Patterns:**
```lua
floater_behavior = {
    mission_priorities = {
        terror = 0.35,         -- Primary focus
        supply_raid = 0.25,    -- Resource acquisition
        base_assault = 0.20,   -- Aggressive
        abduction = 0.15,      -- Secondary
        research = 0.05        -- Low priority
    },
    
    resource_allocation = {
        ufo_production = 0.35,  -- Heavy military investment
        troop_training = 0.40,  -- Focus on troops
        research = 0.10,
        base_expansion = 0.15
    },
    
    escalation_triggers = {
        player_intercept_success = 0.7,  -- Retaliate for UFO losses
        terror_mission_failed = 0.8,     -- Double down
        supply_route_disrupted = 0.9     -- Aggressive response
    }
}
```

**Combat Doctrine:**
```lua
function floater_force_composition(mission_type, threat_level)
    local force = {
        soldiers = 0,
        leaders = 0,
        commanders = 0
    }
    
    if mission_type == "terror" then
        if threat_level == "low" then
            force.soldiers = 8
            force.leaders = 2
        elseif threat_level == "medium" then
            force.soldiers = 12
            force.leaders = 3
            force.commanders = 1
        else  -- high
            force.soldiers = 16
            force.leaders = 4
            force.commanders = 2
        end
    elseif mission_type == "base_assault" then
        -- Always bring overwhelming force
        force.soldiers = 20
        force.leaders = 5
        force.commanders = 3
    end
    
    return force
end
```

### Muton Horde

**Profile:**
- **Aggression:** Very High
- **Strategy:** Territorial expansion and resource extraction
- **Tech Focus:** Armor and brute force weapons
- **Territory Goal:** Resource-rich regions

**Behavior Patterns:**
```lua
muton_behavior = {
    mission_priorities = {
        supply_raid = 0.40,    -- Resource extraction
        terror = 0.30,         -- Intimidation
        base_assault = 0.20,   -- Direct assault
        infiltration = 0.05,   -- Rare
        research = 0.05        -- Minimal
    },
    
    resource_allocation = {
        ufo_production = 0.30,
        troop_training = 0.50,  -- Massive troop focus
        research = 0.05,
        base_expansion = 0.15
    },
    
    escalation_triggers = {
        resource_shortage = 1.0,         -- Always escalate
        territory_lost = 0.9,            -- Immediate response
        muton_berserker_killed = 0.8     -- Enraged retaliation
    }
}
```

**Territory Control:**
```lua
function muton_territory_strategy(world_state)
    local targets = {}
    
    -- Prioritize resource-rich provinces
    for _, province in ipairs(world_state.provinces) do
        local resource_value = calculate_resource_value(province)
        
        if resource_value > 75 then
            table.insert(targets, {
                province = province,
                priority = "critical",
                force_size = "overwhelming"
            })
        elseif resource_value > 50 then
            table.insert(targets, {
                province = province,
                priority = "high",
                force_size = "large"
            })
        end
    end
    
    -- Sort by priority
    table.sort(targets, function(a, b)
        return a.priority > b.priority
    end)
    
    return targets
end
```

### Snakeman Cult

**Profile:**
- **Aggression:** Moderate-High
- **Strategy:** Guerrilla tactics and assassination
- **Tech Focus:** Stealth technology and chemical weapons
- **Territory Goal:** Jungle and tropical regions

**Behavior Patterns:**
```lua
snakeman_behavior = {
    mission_priorities = {
        infiltration = 0.30,   -- Covert operations
        terror = 0.25,         -- Hit-and-run attacks
        assassination = 0.20,  -- Target key personnel
        abduction = 0.15,      -- Secondary
        base_assault = 0.10    -- Opportunistic
    },
    
    resource_allocation = {
        ufo_production = 0.20,
        troop_training = 0.30,
        research = 0.25,       -- Moderate research
        base_expansion = 0.25
    },
    
    escalation_triggers = {
        snakeman_chryssalid_discovered = 0.7,  -- Deploy terror weapons
        player_discovers_jungle_base = 0.9,    -- Aggressive response
        key_officer_killed = 0.6               -- Assassination retaliation
    }
}
```

**Stealth Operations:**
```lua
function snakeman_stealth_mission(target_province)
    local mission = {
        type = "infiltration",
        detection_chance = 0.3,  -- Low detection
        duration = 72,           -- 72 hours (3 days)
        ufo_type = "scout",      -- Small, fast UFOs
        landing_zone = "remote", -- Avoid detection
        
        force_composition = {
            soldiers = 6,
            leaders = 1,
            chryssalids = 2  -- Terror units
        },
        
        objectives = {
            primary = "plant_tracking_device",
            secondary = "abduct_scientists",
            tertiary = "sabotage_facilities"
        }
    }
    
    return mission
end
```

### Ethereal Council

**Profile:**
- **Aggression:** Low-Moderate (Strategic)
- **Strategy:** Long-term manipulation and psionic dominance
- **Tech Focus:** Psi technology and genetic engineering
- **Territory Goal:** Control key decision-makers globally

**Behavior Patterns:**
```lua
ethereal_behavior = {
    mission_priorities = {
        research = 0.35,       -- Heavy research focus
        infiltration = 0.25,   -- Covert control
        abduction = 0.20,      -- Genetic experiments
        terror = 0.10,         -- Rare direct action
        base_assault = 0.10    -- Only when necessary
    },
    
    resource_allocation = {
        ufo_production = 0.15,
        troop_training = 0.15,
        research = 0.50,       -- Dominant research investment
        base_expansion = 0.20
    },
    
    escalation_triggers = {
        psi_technology_discovered = 0.5,   -- Concerned but not panicked
        ethereal_captured = 1.0,           -- Immediate elimination attempt
        player_nears_endgame = 0.9         -- Final push
    }
}
```

**Psionic Warfare:**
```lua
function ethereal_psi_operation(target_base)
    local operation = {
        type = "psionic_assault",
        preparation_time = 168,  -- 1 week preparation
        
        effects = {
            soldier_mind_control = {
                chance = 0.3,
                duration = 24  -- 24 hours
            },
            panic_wave = {
                radius = 5,  -- 5 tiles
                duration = 3  -- 3 turns
            },
            facility_disruption = {
                affected_facilities = {"labs", "workshops"},
                efficiency_penalty = 0.5,
                duration = 72  -- 3 days
            }
        },
        
        force_composition = {
            ethereals = 3,
            sectoid_commanders = 2,
            muton_elites = 4
        }
    }
    
    return operation
end
```

---

## Dynamic Behavior Adaptation

### Threat Assessment

**Player Threat Level:**
```lua
function calculate_player_threat(player_state)
    local threat = 0
    
    -- Military strength (0-40 points)
    threat = threat + (player_state.interceptor_count * 2)
    threat = threat + (player_state.soldier_count * 0.5)
    
    -- Technology (0-30 points)
    if player_state.has_laser_weapons then threat = threat + 10 end
    if player_state.has_plasma_weapons then threat = threat + 20 end
    if player_state.has_psi_amp then threat = threat + 15 end
    
    -- Strategic position (0-30 points)
    threat = threat + (player_state.base_count * 5)
    threat = threat + (player_state.radar_coverage * 0.2)
    
    -- Recent successes (bonus)
    threat = threat + (player_state.recent_mission_successes * 2)
    
    return math.min(100, threat)
end
```

**Adaptive Response:**
```lua
function adapt_faction_behavior(faction, player_threat)
    if player_threat < 30 then
        -- Player is weak, continue expansion
        faction.mission_frequency = 1.0
        faction.force_size_multiplier = 0.8
        faction.aggression = "low"
    elseif player_threat < 60 then
        -- Player is growing, increase pressure
        faction.mission_frequency = 1.2
        faction.force_size_multiplier = 1.0
        faction.aggression = "moderate"
    elseif player_threat < 80 then
        -- Player is strong, escalate significantly
        faction.mission_frequency = 1.5
        faction.force_size_multiplier = 1.3
        faction.aggression = "high"
        
        -- Deploy elite units
        faction.elite_unit_chance = 0.3
    else
        -- Player is dominant, all-out assault
        faction.mission_frequency = 2.0
        faction.force_size_multiplier = 1.5
        faction.aggression = "maximum"
        
        -- Deploy everything
        faction.elite_unit_chance = 0.6
        faction.terror_frequency = 2.0
        faction.base_assault_chance = 0.8
    end
end
```

### Learning Behavior

**Tactical Adaptation:**
```lua
function faction_learns_from_defeat(faction, mission_result)
    if mission_result.outcome == "defeat" then
        -- Analyze what went wrong
        if mission_result.player_used_explosives then
            faction.knowledge.player_explosives = true
            faction.tactics.spread_out = true  -- Counter clustering
        end
        
        if mission_result.player_used_snipers then
            faction.knowledge.player_snipers = true
            faction.tactics.use_cover = true  -- Stay in cover more
            faction.tactics.smoke_grenades = true  -- Deploy smoke
        end
        
        if mission_result.player_used_psi then
            faction.knowledge.player_psi = true
            faction.tactics.high_willpower_units = true  -- Deploy resistant units
        end
        
        -- Increase force size for next mission
        faction.force_multiplier = faction.force_multiplier + 0.1
    end
end
```

**Strategic Adaptation:**
```lua
function faction_adjusts_strategy(faction, player_actions)
    -- If player focuses on interception
    if player_actions.intercept_success_rate > 0.7 then
        faction.strategy.ufo_escorts = true  -- Add escort UFOs
        faction.strategy.night_missions = true  -- Fly at night
        faction.strategy.low_altitude = true  -- Harder to intercept
    end
    
    -- If player ignores certain mission types
    if player_actions.ignored_supply_raids > 3 then
        faction.strategy.supply_raid_frequency = 1.5  -- Exploit weakness
    end
    
    -- If player has weak radar coverage
    if player_actions.undetected_landings > 5 then
        faction.strategy.direct_landings = true  -- Skip flyby phase
    end
end
```

---

## Multi-Faction Dynamics

### Coordination

**Joint Operations:**
```lua
function plan_joint_operation(faction_a, faction_b, target)
    local joint_op = {
        type = "coordinated_assault",
        factions = {faction_a, faction_b},
        target = target,
        
        phase_1 = {
            faction = faction_b,
            mission = "distraction_terror",
            location = target.adjacent_province
        },
        
        phase_2 = {
            faction = faction_a,
            mission = "base_assault",
            location = target.base_location,
            delay_hours = 6  -- Strike while player distracted
        }
    }
    
    return joint_op
end
```

### Competition

**Resource Competition:**
```lua
function resolve_faction_competition(faction_a, faction_b, resource)
    -- Factions may compete for same target
    local faction_a_priority = calculate_resource_priority(faction_a, resource)
    local faction_b_priority = calculate_resource_priority(faction_b, resource)
    
    if faction_a_priority > faction_b_priority then
        return faction_a
    elseif faction_b_priority > faction_a_priority then
        return faction_b
    else
        -- Equal priority, both may launch missions
        return "contested"
    end
end
```

---

## Victory Conditions

### Alien Victory Path

**Domination Track:**
```lua
function update_alien_domination(world_state)
    local domination = 0
    
    -- Territory control (0-40 points)
    domination = domination + (world_state.alien_controlled_provinces * 2)
    
    -- Infiltration (0-30 points)
    domination = domination + (world_state.infiltrated_governments * 5)
    
    -- Player weakness (0-30 points)
    if world_state.player_bases_destroyed > 0 then
        domination = domination + (world_state.player_bases_destroyed * 10)
    end
    
    domination = domination + (world_state.failed_missions * 2)
    
    -- Check for alien victory
    if domination >= 100 then
        trigger_alien_victory()
    end
    
    return domination
end
```

### Player Disruption

**Setback System:**
```lua
function apply_player_disruption(faction, disruption_type)
    if disruption_type == "alien_base_destroyed" then
        -- Major setback
        faction.resources = faction.resources * 0.7
        faction.mission_frequency = faction.mission_frequency * 0.8
        faction.morale = "shaken"
        
        -- Delay next escalation
        faction.next_escalation_month = faction.next_escalation_month + 1
    elseif disruption_type == "research_facility_destroyed" then
        -- Research setback
        faction.research_progress = faction.research_progress * 0.5
        faction.next_tech_unlock_month = faction.next_tech_unlock_month + 2
    elseif disruption_type == "supply_ship_destroyed" then
        -- Resource shortage
        faction.resources = faction.resources * 0.9
        faction.force_size_multiplier = faction.force_size_multiplier * 0.9
    end
end
```

---

## Cross-References

**Related Systems:**
- [AI Overview](README.md) - General AI architecture
- [Tactical AI](Tactical_AI.md) - Battlescape AI behavior
- [Mission Generation](../geoscape/Mission_Generation.md) - Mission creation
- [World System](../geoscape/World.md) - Territory and provinces
- [Detection System](../geoscape/Detection.md) - Mission detection mechanics

**Implementation Files:**
- `src/ai/faction_behavior.lua` - Faction AI system
- `src/ai/strategic_planning.lua` - Long-term planning
- `src/geoscape/alien_activity.lua` - Mission scheduling
- `data/factions/*.toml` - Faction definitions

---

## Version History

- **v1.0 (2025-09-30):** Initial faction behavior specification
