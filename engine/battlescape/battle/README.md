# Battlescape Battle System

**Status:** [PARTIAL IMPLEMENTATION - Turn system ready, advanced features in progress]

## Goal / Purpose
The core battle system manages turn-based combat execution including turn order, action resolution, damage calculation, and combat state transitions. It orchestrates the battlescape gameplay loop.

## Content
- **Turn management** - Turn order and phase sequencing
- **Action execution** - Processing and resolving player and AI actions
- **Combat state** - Battle state machine and transitions
- **Victory/defeat conditions** - Win/loss determination logic
- **Combat statistics** - Tracking combat metrics and events
- **Action queue** - Queuing and scheduling actions

## Features
- Turn-based combat system
- Action resolution system
- Damage and effect application
- Combat event logging
- Victory condition checking
- Combat statistics tracking

## Integrations with Other Folders / Systems
- **engine/battlescape/combat** - Action execution and resolution
- **engine/battlescape/battlefield** - Battle map and unit positioning
- **engine/battlescape/entities** - Unit representation
- **engine/battlescape/ai** - AI action selection
- **engine/battlescape/systems** - Battle system coordination
- **engine/core/state_manager.lua** - Game state
- **engine/battlescape/ui** - Combat UI updates
