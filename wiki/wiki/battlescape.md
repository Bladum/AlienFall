# Battlescape

This document details the battlescape systems in AlienFall, focusing on battle preparation, planning, and pre-combat management. It covers mission objectives, squad deployment, AI behaviors, and post-battle recovery mechanics.

## Table of Contents

- [Battle Planning](#battle-planning)
- [Salvaging & Recovery](#salvaging--recovery)
- [Enemy Squad Building](#enemy-squad-building)
- [Deployment Systems](#deployment-systems)
- [AI Map Nodes](#ai-map-nodes)
- [Objective Management](#objective-management)

## Battle Planning
- Mission objectives and requirements
- Squad composition and deployment
- Equipment loadouts and preparation

## Salvaging & Recovery
- Post-mission artifact collection
- Casualty evacuation and treatment
- Resource recovery from battlefields

## Enemy Squad Building
- AI-generated enemy unit composition
- Difficulty-based squad scaling
- Faction-specific unit preferences

## Deployment Systems
- Unit assignment to squads
- Tactical positioning on landing zones
- Pre-battle strategic setup

## AI Map Nodes
- Strategic positioning markers for AI units
- Patrol routes and defensive positions
- Dynamic AI behavior waypoints

## Objective Management
- Primary and secondary mission goals
- Success/failure conditions
- Time pressure and completion tracking

### Battle Objectives System
Specific goals that must be achieved to win the battle, assigned to each team (player vs AI factions).

### Win/Loss Conditions per Team
- **Player Victory**: Complete all primary objectives within time limit, or eliminate all enemy units
- **Player Defeat**: All player units eliminated, or time expires with primary objectives incomplete
- **AI Victory**: Complete their faction-specific objectives, or eliminate all player units
- **AI Defeat**: All AI units eliminated, or player completes objectives

### Battle Points System
Scoring mechanism during battle for completing objectives and achieving milestones.
- **Objective Completion Points**: Awarded for finishing primary/secondary goals
- **Unit Elimination Points**: Bonus points for defeating enemy units
- **Time Bonus Points**: Extra points for completing objectives quickly
- **Style Points**: Bonuses for tactical achievements (flanking, minimal casualties, etc.)
- **Total Battle Score**: Influences post-mission rewards, experience, and campaign progression