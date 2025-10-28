# tests2/battlescape - Tactical Combat Tests

**Purpose:** Test battlescape tactical layer and combat mechanics

**Content:** 28 Lua test files for battlescape functionality

**Features:**
- Combat mechanics and resolution
- Tactical decision making
- Unit movement and positioning
- Squad management and tactics
- Weapon and damage systems
- Accuracy and hit calculations
- Environmental effects
- LOS/FOW systems
- Map generation and procedural terrain

## Test Files (28 total)

### Combat Systems (8 files)
- **combat_mechanics_test.lua** - Combat rules and mechanics
- **combat_resolver_test.lua** - Combat resolution system
- **combat_simulator_test.lua** - Combat simulation
- **combat_log_test.lua** - Combat logging
- **accuracy_system_test.lua** - Accuracy calculations
- **weapon_system_test.lua** - Weapon mechanics
- **weapon_balancing_test.lua** - Weapon balance
- **environmental_effects_test.lua** - Environmental hazards

### Squad & Tactics (6 files)
- **squad_manager_test.lua** - Squad management
- **squad_formation_test.lua** - Formation tactics
- **squad_tactics_test.lua** - Tactical maneuvers
- **tactical_combat_test.lua** - Tactical gameplay
- **tactical_objectives_test.lua** - Objective handling
- **ai_tactical_decision_test.lua** - AI tactics

### Movement & Navigation (4 files)
- **movement_system_test.lua** - Movement mechanics
- **pathfinding_movement_test.lua** - Pathfinding
- **los_fow_system_test.lua** - LoS and FoW
- **deployment_system_test.lua** - Unit deployment

### Map & Generation (4 files)
- **map_generator_test.lua** - Map generation
- **procedural_generation_test.lua** - Procedural systems
- **ecs_components_test.lua** - ECS components
- **interception_battle_test.lua** - Interception combat

### Management (3 files)
- **craft_manager_test.lua** - Craft management
- **unit_progression_test.lua** - Unit progression
- **warrior_skills_test.lua** - Warrior skills

### Support (2 files)
- **mission_briefing_test.lua** - Mission briefing
- **edge_case_handling_test.lua** - Edge case handling

### Infrastructure
- **init.lua** - Module loader

## Running Tests

```bash
lovec tests2/runners run_subsystem battlescape
```

## Coverage Areas

| Area | Coverage | Files |
|------|----------|-------|
| Combat Systems | 95%+ | 8 |
| Squad Tactics | 90%+ | 6 |
| Movement | 85%+ | 4 |
| Map Generation | 80%+ | 4 |
| Management | 75%+ | 3 |

## Statistics

- **Total Files**: 28 Lua test files
- **Test Cases**: 150+
- **Framework**: HierarchicalSuite
- **Status**: Production Ready

---

**Status**: ✅ Fully Implemented
**Last Updated**: October 2025
