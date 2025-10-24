# Tactical AI System

## Goal / Purpose
The Tactical AI subsystem handles real-time decision-making and unit behaviors during battlescape combat. It includes pathfinding, threat assessment, and tactical positioning for alien and human units in turn-based combat scenarios.

## Content
- **Tactical decision-making algorithms** - AI evaluates combat situations and determines unit actions
- **Squad coordination logic** - Manages group behaviors and collective strategies
- **Threat assessment** - Analyzes enemy positions, firepower, and danger levels
- **Unit behavior scripts** - Defines responses to various combat situations
- **Action prioritization** - Determines which actions are most beneficial in current situations

## Features
- Turn-based combat planning
- Real-time threat evaluation
- Pathfinding and movement decisions
- Targeting and weapon selection
- Squad formation and coordination
- Reaction to player actions
- Difficulty-based AI adaptation

## Integrations with Other Folders / Systems
- **engine/battlescape/ai** - Higher-level AI coordination and behavior trees
- **engine/battlescape/combat** - Execution of AI-determined combat actions
- **engine/battlescape/entities** - Unit entity management and state
- **engine/ai/pathfinding** - Tactical pathfinding for movement calculations
- **engine/ai/threat_assessment.lua** - Threat analysis for decision-making
- **engine/ai/squad_coordination.lua** - Squad-level tactics and formations
