# tests2/core - Core Engine Systems Tests

**Purpose:** Test core engine systems and management

**Content:** 31 Lua test files covering core functionality

**Features:**
- State management and lifecycle
- Data loading and persistence
- Accessibility and localization
- Audio systems
- Achievement and progression systems
- Difficulty and threat calculation
- Research and tech trees

## Test Files (31 total)

### Core Systems (7 files)
- **state_manager_test.lua** - Game state management
- **data_loader_test.lua** - Data loading system
- **save_system_test.lua** - Save/load functionality
- **turn_manager_test.lua** - Turn-based mechanics
- **tutorial_test.lua** - Tutorial system
- **unit_progression_test.lua** - Unit progression
- **system_integration_test.lua** - System integration

### Management Systems (9 files)
- **mod_manager_test.lua** - Mod management
- **resource_management_test.lua** - Resource allocation
- **talent_tree_test.lua** - Talent progression
- **tech_tree_test.lua** - Technology trees
- **research_tech_test.lua** - Research system
- **skill_progression_test.lua** - Skill advancement
- **pilot_skills_test.lua** - Pilot skill system
- **achievement_system_test.lua** - Achievement tracking
- **artifact_system_test.lua** - Artifact management

### Player Experience (8 files)
- **accessibility_test.lua** - Accessibility features
- **colorblind_mode_test.lua** - Colorblind modes
- **localization_test.lua** - Localization system
- **audio_system_test.lua** - Audio functionality
- **notification_system_test.lua** - Notifications
- **fame_reputation_test.lua** - Reputation system
- **survival_mechanics_test.lua** - Survival mechanics
- **population_dynamics_test.lua** - Population systems

### Advanced Systems (4 files)
- **qa_system_test.lua** - QA system
- **dynamic_events_test.lua** - Dynamic events
- **difficulty_test.lua** - Difficulty system
- **engine_coverage_analysis_test.lua** - Coverage analysis

### Utilities (2 files)
- **example_counter_test.lua** - Example/demo tests
- **pathfinding_test.lua** - Pathfinding algorithms

## Running Tests

```bash
lovec tests2/runners run_subsystem core
```

## Coverage Matrix

| System | Files | Status |
|--------|-------|--------|
| Core Systems | 7 | ✓ Complete |
| Management | 9 | ✓ Complete |
| Player Experience | 8 | ✓ Complete |
| Advanced Systems | 4 | ✓ Complete |
| Utilities | 2 | ✓ Complete |

## Statistics

- **Total Files**: 31 Lua test files
- **Framework**: HierarchicalSuite
- **Status**: Production Ready

---

**Status**: ✅ Fully Implemented
**Last Updated**: October 2025
