# Battlescape AI System

## Goal / Purpose
The Battlescape AI subsystem orchestrates all AI-driven behaviors during tactical combat. It coordinates unit actions, manages behavior states, implements difficulty levels, and ensures meaningful tactical challenges for the player.

## Content
- **Behavior trees** - State machines for unit decision-making
- **Action selection** - Determines best available actions for each unit
- **Difficulty modifiers** - Easy, Normal, Hard difficulty AI adjustments
- **Unit AI states** - Idle, combat, retreat, defensive states
- **Reaction systems** - Responses to player actions and environmental changes
- **Performance optimization** - Efficient AI calculations for many units

## Features
- Multi-unit coordination
- Difficulty-scalable AI
- Intelligent positioning and movement
- Dynamic threat response
- Squad tactics execution
- Cover utilization
- Weapon strategy based on situation

## Integrations with Other Folders / Systems
- **engine/ai/tactical** - Tactical decision-making algorithms
- **engine/ai/squad_coordination.lua** - Squad behaviors and formations
- **engine/ai/threat_assessment.lua** - Threat evaluation
- **engine/battlescape/battle** - Battle state and turn management
- **engine/battlescape/combat** - Combat action execution
- **engine/battlescape/entities** - Unit entity management
- **engine/battlescape/battlefield** - Battlefield state and grid
- **engine/core/state_manager.lua** - Game state management
