# AI

This document details the artificial intelligence systems implemented in AlienFall for strategic and tactical gameplay. It covers AI behaviors for units in battlescape combat, including decision-making processes at individual, squad, and team levels. The AI systems are designed to provide dynamic and challenging gameplay experiences against alien forces.

## Table of Contents

- [Battlescape AI Systems](#battlescape-ai-systems)
- [AI by Unit Affiliation](#ai-by-unit-affiliation)

## Battlescape AI Systems

### Individual Unit AI
- Decision making for single unit actions
- Threat assessment and target prioritization
- Movement pathfinding and positioning
- Ability usage optimization

### Squad AI
- Group coordination and formation maintenance
- Squad-level tactics and maneuvers
- Support role assignment (covering fire, flanking)
- Communication and synchronization between units

### Team AI (Battle Side)
- Overall battle strategy orchestration
- Resource allocation across squad
- Tactical retreat and reinforcement decisions
- Victory condition assessment

### Behaviors - Unit Action Flavor
- Aggressive: Direct assault, high risk maneuvers
- Defensive: Position holding, suppression focus
- Stealthy: Evasion, ambush tactics
- Support: Healing, buffing, utility actions

### AI Machine States
- Idle: Default patrol and scanning
- Alert: Threat detected, heightened awareness
- Combat: Active engagement state
- Flee: Retreat and evasion
- Panic: Disorganized, ineffective actions

### Map Nodes for AI
- Strategic positioning markers
- Patrol waypoints and routes
- Defensive strongpoints
- Ambush locations and kill zones

### Mission Objectives AI
- Primary goal pursuit and adaptation
- Secondary objective management
- Failure condition avoidance
- Dynamic objective reassessment

## AI by Unit Affiliation

### Neutral Units AI
- Civilian behavior patterns
- Avoidance of combat zones
- Environmental interaction (hiding, fleeing)
- Non-combatant decision making