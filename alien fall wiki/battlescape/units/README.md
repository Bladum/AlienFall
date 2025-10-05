# Battlescape Units and Actions Documentation

## Overview

The `units` folder contains comprehensive documentation for the unit system and action mechanics that form the core of tactical gameplay in Alien Fall. This system defines how units move, fight, and interact within the battlescape, implementing deterministic, data-driven mechanics that ensure reproducible outcomes for testing, balance analysis, and competitive play.

The unit architecture combines character progression, equipment systems, and tactical actions into a cohesive framework that supports both strategic planning and real-time combat execution.

## Unit System Architecture

### Hierarchical Unit Design
Units operate on multiple abstraction layers:

```
Strategic Layer (Campaign Progression)
    ↓
Tactical Layer (Mission Deployment)
    ↓
Combat Layer (Turn-Based Actions)
    ↓
Execution Layer (Animation & Resolution)
```

### Core Components

#### 1. **Unit Entity** (`Unit.md`)
The fundamental character system that defines unit capabilities, progression, and tactical roles. Units combine attributes, skills, equipment, and psychological states into complete tactical entities.

**Key Features:**
- Comprehensive attribute system (health, mobility, combat stats)
- Class-based progression with specialization paths
- Equipment integration and customization
- Psychological state tracking (morale, sanity, panic)
- Deterministic behavior for reproducible gameplay

#### 2. **Unit Actions** (`Unit actions.md`)
The complete set of tactical actions available to units during combat. Actions range from basic movement to complex tactical maneuvers, each with specific costs, requirements, and effects.

**Action Categories:**
- **Movement Actions**: Position changes and terrain navigation
- **Combat Actions**: Offensive capabilities and targeting
- **Defensive Actions**: Protection and tactical positioning
- **Special Actions**: Unique abilities and equipment usage
- **Utility Actions**: Support and environmental interaction

## Detailed Action Systems

### Movement Actions

#### **Basic Movement** (`Action - Movement.md`)
Fundamental locomotion system governing unit positioning and terrain interaction.

**Movement Mechanics:**
- **Tile-Based Navigation**: Discrete grid movement with facing directions
- **Terrain Costs**: Variable movement points for different terrain types
- **Elevation Handling**: Height-based movement penalties and bonuses
- **Obstacle Navigation**: Pathfinding around barriers and hazards
- **Facing Requirements**: Directional positioning for combat and visibility

#### **Running** (`Action - Running.md`)
Accelerated movement action that prioritizes speed over stealth and accuracy.

**Running Mechanics:**
- **Speed Bonus**: Increased movement range at tactical cost
- **Accuracy Penalty**: Reduced combat effectiveness while running
- **Noise Generation**: Increased detection risk from rapid movement
- **Fatigue Effects**: Endurance costs and recovery requirements
- **Terrain Impact**: Variable speed modifiers based on surface conditions

#### **Sneaking** (`Action - Sneaking.md`)
Stealth movement that reduces detection risk and enables surprise attacks.

**Sneaking Mechanics:**
- **Detection Reduction**: Lower visibility and noise generation
- **Movement Penalty**: Reduced speed for stealth effectiveness
- **Terrain Synergy**: Cover and concealment bonuses
- **Alert State Interaction**: Effectiveness based on enemy awareness
- **Ambush Setup**: Positioning for surprise attacks

### Combat and Defensive Actions

#### **Cover and Crouching** (`Action - Cover & Crouch.md`)
Protective positioning system that provides defensive bonuses and tactical advantages.

**Cover Mechanics:**
- **Protection Levels**: Partial and full cover with damage reduction
- **Positioning Requirements**: Specific tile relationships for cover
- **Crouching States**: Height-based visibility and protection changes
- **Dynamic Cover**: Temporary cover from environmental objects
- **Overwatch Integration**: Defensive positioning for interrupt actions

#### **Overwatch** (`Action - Overwatch.md`)
Defensive stance that enables reactive attacks against enemy movement.

**Overwatch Mechanics:**
- **Trigger Conditions**: Enemy movement into designated zones
- **Interrupt Priority**: Action precedence in turn resolution
- **Accuracy Modifiers**: Positioning and range-based hit chances
- **Ammo Consumption**: Resource costs for overwatch actions
- **Multi-Target**: Single action covering multiple threat vectors

#### **Suppressive Fire** (`Action - Suppressive fire.md`)
Area denial action that forces enemy units into cover and reduces mobility.

**Suppression Mechanics:**
- **Area of Effect**: Cone or radius-based suppression zones
- **Morale Impact**: Psychological effects on affected units
- **Movement Penalty**: Reduced speed in suppression areas
- **Duration Effects**: Temporary debuffs with recovery mechanics
- **Ammo Efficiency**: Resource costs vs. tactical effectiveness

## Unit Attributes and Progression

### Core Attributes
Fundamental unit characteristics that define capabilities:

```lua
local unit_attributes = {
    -- Physical Attributes
    health = { current = 100, max = 100 },
    mobility = 8,  -- tiles per turn
    carrying_capacity = 50,  -- kg
    
    -- Combat Attributes  
    accuracy = 65,  -- base hit chance
    reaction = 70,  -- overwatch effectiveness
    strength = 12,  -- damage modifiers
    
    -- Mental Attributes
    morale = 85,   -- psychological state
    sanity = 90,   -- mental resilience
    leadership = 15 -- command bonuses
}
```

### Class System
Specialized roles with unique capabilities and progression paths:

- **Assault**: High mobility, close-quarters combat focus
- **Sniper**: Long-range accuracy, stealth capabilities
- **Heavy**: High durability, suppressive firepower
- **Support**: Medical and utility specialization
- **Scout**: Stealth and reconnaissance expertise
- **Leader**: Command bonuses and tactical coordination

### Equipment Integration
Weapon and gear systems that modify unit capabilities:

```toml
[unit.equipment]
primary_weapon = "rifle_m4a1"
secondary_weapon = "pistol_glock"
armor = "kevlar_vest"
accessories = ["night_vision", "medkit"]

[weapon_stats.rifle_m4a1]
damage = 35
range = 25
accuracy = 75
ammo_capacity = 30
fire_modes = ["single", "burst", "auto"]
```

## Tactical Action Resolution

### Turn Structure
Deterministic turn-based execution with simultaneous resolution:

1. **Action Declaration**: Players commit to actions with costs
2. **Interrupt Resolution**: Overwatch and reaction triggers
3. **Movement Execution**: Position changes and facing updates
4. **Combat Resolution**: Hit calculation and damage application
5. **Effect Processing**: Status effects and environmental changes

### Action Costs and Limits
Resource management for tactical decision-making:

- **Time Units (TU)**: Primary resource for all actions
- **Action Points (AP)**: Secondary resource for special abilities
- **Ammo Consumption**: Weapon-specific resource tracking
- **Fatigue Effects**: Endurance costs for sustained activity
- **Cooldown Systems**: Ability reuse limitations

## Unit State Management

### Health and Injury System
Comprehensive damage and recovery mechanics:

- **Wound States**: Light, medium, heavy injury progression
- **Bleeding Effects**: Ongoing damage and treatment requirements
- **Incapacitation**: Unconscious state and recovery mechanics
- **Permanent Injuries**: Long-term ability reductions
- **Medical Treatment**: Healing actions and equipment

### Psychological States
Mental condition effects on unit performance:

- **Morale**: Combat effectiveness and willingness to fight
- **Panic**: Severe stress reactions and AI control
- **Sanity**: Campaign-scale mental health tracking
- **Leadership**: Command bonuses and unit coordination

## AI Integration

### Unit AI Behaviors
Autonomous behavior patterns for computer-controlled units:

- **Movement Logic**: Pathfinding and positioning algorithms
- **Combat Priority**: Target selection and engagement rules
- **Cover Seeking**: Automatic defensive positioning
- **Group Coordination**: Formation maintenance and tactics

### Deterministic AI
Reproducible computer behavior for testing and balance:

- **Seeded Decisions**: Consistent AI choices across runs
- **Priority Systems**: Numeric weights for behavior selection
- **State Machines**: Finite state AI for complex behaviors
- **Moddable Logic**: Scriptable AI for custom units

## Modding and Customization

### Unit Templates
Configurable unit archetypes for custom content:

```toml
[unit_template.assault_soldier]
class = "assault"
base_attributes = { health = 90, mobility = 9, accuracy = 70 }
starting_equipment = ["rifle_ak47", "pistol_makarov", "armor_flak"]
special_abilities = ["close_quarters_specialist", "aggressive"]
progression_path = "shock_trooper"
```

### Custom Actions
Extensible action system for modded content:

```lua
function custom_action_snipe(unit, target)
    -- Custom snipe logic
    local range = calculate_distance(unit.position, target.position)
    local accuracy = unit.attributes.accuracy + get_scope_bonus(unit.equipment)
    
    if range > 20 then
        accuracy = accuracy * 0.8  -- Long range penalty
    end
    
    return resolve_attack(unit, target, accuracy)
end
```

## Performance and Optimization

### Unit Processing
Efficient handling of multiple units in combat:

- **Spatial Indexing**: Fast unit queries and collision detection
- **Action Caching**: Precomputed action costs and validity
- **Batch Processing**: Grouped updates for similar units
- **Memory Pooling**: Efficient unit object management

### Scalability Limits
Performance boundaries for unit complexity:

- **Maximum Units**: 50+ units per battlefield
- **Action Complexity**: Real-time resolution under 100ms
- **State Tracking**: Comprehensive unit status monitoring
- **Network Sync**: Multiplayer unit state synchronization

## Testing and Validation

### Unit Testing Suite
Comprehensive validation for unit systems:

- **Attribute Testing**: Stat calculation and progression verification
- **Action Testing**: Combat resolution and movement validation
- **Balance Analysis**: Statistical performance evaluation
- **Integration Testing**: Multi-unit interaction scenarios

### Balance Metrics
Quantitative measures for unit fairness:

- **Effectiveness Ratios**: Damage output vs. survivability
- **Resource Efficiency**: Action costs vs. tactical value
- **Progression Balance**: Experience requirements and rewards
- **Class Synergy**: Team composition effectiveness

## Future Enhancements

### Advanced Unit Features
Planned improvements for unit systems:

- **Dynamic Abilities**: Context-sensitive action unlocking
- **Equipment Crafting**: Custom gear creation and modification
- **Unit Bonding**: Relationship systems and morale bonuses
- **Advanced AI**: Learning behaviors and adaptive tactics

### Technical Improvements
System optimizations and new capabilities:

- **Procedural Generation**: AI-assisted unit creation
- **Real-time Animation**: Smooth action execution
- **Advanced Physics**: Realistic movement and interaction
- **Performance Analytics**: Detailed unit performance tracking

## Related Documentation

### Core Systems
- **Combat Resolution**: Action execution and damage calculation
- **Equipment System**: Weapons, armor, and gear mechanics
- **Progression System**: Experience and advancement mechanics
- **AI System**: Computer-controlled unit behavior

### Technical References
- **ECS Framework**: Entity management for unit components
- **Deterministic Systems**: Seeded random number generation
- **Modding API**: Custom unit and action creation
- **Performance Systems**: Optimization techniques

### Game Design
- **Balance Documentation**: Unit effectiveness and difficulty tuning
- **Player Experience**: Unit customization and progression
- **Narrative Integration**: Character development and story
- **Accessibility**: Unit control and interface options

## References and Inspiration

### Tactical Games
- **XCOM Series**: Unit classes, actions, and progression
- **Fire Emblem**: Grid-based movement and combat
- **Advance Wars**: Unit types and tactical positioning
- **Jagged Alliance**: Detailed character customization

### RPG Systems
- **D&D**: Attribute systems and class progression
- **Warhammer**: Detailed unit capabilities and equipment
- **Tabletop Wargames**: Unit statistics and special rules
- **CRPGs**: Character development and customization

---

*This documentation provides the complete framework for units and actions in Alien Fall, enabling deep tactical gameplay with extensive customization and modding capabilities.*