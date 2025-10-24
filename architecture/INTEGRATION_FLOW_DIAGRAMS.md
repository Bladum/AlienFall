# Integration Flow Diagrams - AlienFall Architecture

**Date**: October 21, 2025  
**Purpose**: Visual documentation of system integration, state transitions, data flow, and architecture

---

## Table of Contents

1. [System Architecture Overview](#system-architecture-overview)
2. [State Machine Transitions](#state-machine-transitions)
3. [Data Flow Between Layers](#data-flow-between-layers)
4. [Mod Loading Sequence](#mod-loading-sequence)
5. [Save/Load Process](#saveload-process)
6. [Mission Generation Flow](#mission-generation-flow)
7. [Combat Resolution Flow](#combat-resolution-flow)
8. [Game Loop Timing](#game-loop-timing)

---

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        ALIENFALL ENGINE                         │
│                    (Love2D + Lua Framework)                     │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                       CORE SYSTEMS LAYER                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ State        │  │ Event        │  │ Asset        │          │
│  │ Manager      │  │ System       │  │ Manager      │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Save/Load    │  │ Config       │  │ Mod          │          │
│  │ System       │  │ Manager      │  │ Manager      │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    GAMEPLAY LAYERS (Stacked)                    │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                  GEOSCAPE (Strategic Layer)                │ │
│  │  ├─ World Map (countries, provinces, biomes)               │ │
│  │  ├─ Mission Management (spawn, tracking)                   │ │
│  │  ├─ Craft Management (bases, interception)                 │ │
│  │  ├─ Council Relations (diplomatic)                         │ │
│  │  └─ Research Notifications (milestones)                    │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              ↕ (Push/Pop)                       │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │               INTERCEPTION (Intercept Layer)               │ │
│  │  ├─ Craft Selection (player selects interceptor)           │ │
│  │  ├─ UFO Targeting (incoming threat)                        │ │
│  │  ├─ Interception Result (success/failure/draw)             │ │
│  │  └─ Return to Geoscape (damage report)                     │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              ↕ (Push/Pop)                       │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │             BATTLESCAPE (Tactical Layer)                   │ │
│  │  ├─ Map Generation (procedural)                            │ │
│  │  ├─ Unit Placement (player squad, enemies)                 │ │
│  │  ├─ Turn Resolution (AI, player actions)                   │ │
│  │  ├─ Combat Simulation (damage, hits, effects)              │ │
│  │  └─ Mission Complete (victory/defeat/abort)                │ │
│  └────────────────────────────────────────────────────────────┘ │
│                              ↕ (Push/Pop)                       │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │              BASESCAPE (Management Layer)                  │ │
│  │  ├─ Facility Management (placement, operations)            │ │
│  │  ├─ Personnel Management (recruitment, training)           │ │
│  │  ├─ Research Queue (progress, completion)                  │ │
│  │  ├─ Manufacturing Queue (equipment production)             │ │
│  │  ├─ Marketplace (buying, selling)                          │ │
│  │  └─ Base Reports (monthly summaries)                       │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘

                                  ↓
┌─────────────────────────────────────────────────────────────────┐
│                    RENDERING & UI LAYER                         │
│  ├─ Canvas (Love2D graphics output)                             │
│  ├─ UI Framework (widgets, panels, buttons)                     │
│  ├─ Animation System (sprite transitions)                       │
│  └─ Audio System (music, SFX)                                   │
└─────────────────────────────────────────────────────────────────┘

                                  ↓
┌─────────────────────────────────────────────────────────────────┐
│                    PERSISTENCE LAYER                            │
│  ├─ Save Files (11 slots + auto-save)                          │
│  ├─ Config Files (settings, mod preferences)                    │
│  ├─ Mod Content (TOML content loaded at startup)                │
│  └─ Asset Cache (sprites, sounds, tilesets)                     │
└─────────────────────────────────────────────────────────────────┘
```

---

## State Machine Transitions

### Complete State Flow

```
                            ┌──────────────┐
                            │   APPLICATION│
                            │    START     │
                            └──────┬───────┘
                                   │
                    ┌──────────────▼──────────────┐
                    │  Initialize Core Systems:   │
                    │  • Load Mods (TOML)         │
                    │  • Init Asset Manager       │
                    │  • Init Audio System        │
                    │  • Load Last Save (if any)  │
                    └──────────────┬──────────────┘
                                   │
        ┌──────────────────────────▼──────────────────────────┐
        │                                                      │
        │         ┌────────────────────────────────┐          │
        │         │    MAIN MENU SCENE             │          │
        │         │  (New Game / Load Game / Quit) │          │
        │         └────────┬───────────────────────┘          │
        │                  │                                   │
        │    ┌─────────────┴──────────────┐                   │
        │    │                            │                   │
        │    ▼                            ▼                   │
        │ ┌─────────────────┐    ┌──────────────────┐        │
        │ │  NEW GAME       │    │  LOAD GAME       │        │
        │ │  ├─ Campaign    │    │  ├─ Select Slot  │        │
        │ │  │  Selection   │    │  ├─ Verify Save  │        │
        │ │  ├─ Difficulty  │    │  ├─ Load State   │        │
        │ │  ├─ Start Phase │    │  └─ Resume Play  │        │
        │ │  └─ Init Game   │    └──────────────────┘        │
        │ └────────┬────────┘                                │
        │          │                                         │
        └──────────┼─────────────────────────────────────────┘
                   │
        ┌──────────▼──────────────────────────────────────────┐
        │                                                      │
        │  ┌─────────────────────────────────────────────┐   │
        │  │            GEOSCAPE (Strategic Layer)       │   │
        │  │                                             │   │
        │  │  • Load World Map                           │   │
        │  │  • Display Province/Country Data            │   │
        │  │  • Process Monthly Events                   │   │
        │  │  • Generate Random Missions                 │   │
        │  │  • Update Council Approvals                 │   │
        │  │  • Track Crafts & Interceptions             │   │
        │  └──────────┬──────────────────────────────────┘   │
        │             │                                      │
        │    ┌────────┴──────────┐                           │
        │    │                   │                           │
        │    ▼                   ▼                           │
        │ ┌──────────┐       ┌────────────┐                │
        │ │ CRAFT    │       │ MISSION    │                │
        │ │ INTER-   │       │ SELECTION  │                │
        │ │ CEPTION  │       │ (Click on  │                │
        │ │          │       │  mission)  │                │
        │ │ Send     │       │            │                │
        │ │ craft to │       │ Load squad │                │
        │ │ target   │       │ Load brief │                │
        │ │ UFO      │       │ Confirm    │                │
        │ └──────┬───┘       └────┬───────┘                │
        │        │                │                         │
        │        └────────┬───────┘                         │
        │                 │                                 │
        │        ┌────────▼────────────────────┐           │
        │        │   INTERCEPTION SCENE        │           │
        │        │   (If intercept selected)   │           │
        │        │                            │           │
        │        │ • Load Craft Stats          │           │
        │        │ • Load UFO Stats            │           │
        │        │ • Resolve Combat (simple)   │           │
        │        │ • Determine Outcome         │           │
        │        │ • Return to Geoscape        │           │
        │        └────────┬────────────────────┘           │
        │                 │                                 │
        │                 │ (if mission selected)           │
        │        ┌────────▼────────────────────┐           │
        │        │    MISSION PREP SCENE       │           │
        │        │                            │           │
        │        │ • Display Mission Brief     │           │
        │        │ • Confirm Squad            │           │
        │        │ • Generate Battlescape Map │           │
        │        │ • Load Battlescape Scene   │           │
        │        └────────┬────────────────────┘           │
        │                 │                                 │
        │                 │ (Enter mission)                 │
        │        ┌────────▼────────────────────────────┐   │
        │        │      BATTLESCAPE (Tactical)         │   │
        │        │                                    │   │
        │        │  • Initialize Squad Units         │   │
        │        │  • Place Units on Map             │   │
        │        │  • Spawn Enemies                  │   │
        │        │  • Process Turn Loop:              │   │
        │        │    - Player Action Phase           │   │
        │        │    - AI Enemy Phase                │   │
        │        │    - Resolution Phase              │   │
        │        │    - Check Win Condition           │   │
        │        │  • Mission Complete                │   │
        │        │    - Calculate Rewards             │   │
        │        │    - Update Squad Stats            │   │
        │        │    - Generate Loot                 │   │
        │        │    - Store Results                 │   │
        │        └────────┬─────────────────────────────┘   │
        │                 │                                 │
        │        ┌────────▼────────────────────┐           │
        │        │  MISSION RESULT SCENE       │           │
        │        │                            │           │
        │        │ • Display Battle Summary    │           │
        │        │ • Show Casualties          │           │
        │        │ • Show Loot Acquired       │           │
        │        │ • Show XP Gained           │           │
        │        │ • Continue to Next Scene   │           │
        │        └────────┬────────────────────┘           │
        │                 │                                 │
        │        ┌────────▼────────────────────────────┐   │
        │        │      BASESCAPE (Management)         │   │
        │        │                                    │   │
        │        │  • Add Loot to Inventory            │   │
        │        │  • Process Wounded (Hospital)       │   │
        │        │  • Update Research Progress         │   │
        │        │  • Update Manufacturing Queue       │   │
        │        │  • Display Base Facilities          │   │
        │        │  • Process Monthly Events           │   │
        │        │  • Return to Geoscape               │   │
        │        └────────┬─────────────────────────────┘   │
        │                 │                                 │
        │                 └────────┐                        │
        │                          │                        │
        │        ┌─────────────────▼──────────────────┐    │
        │        │  GEOSCAPE - Next Month              │    │
        │        │  (Loop Back to Strategic Layer)     │    │
        │        └─────────────────┬──────────────────┘    │
        │                          │                        │
        │        ┌─────────────────┴──────────────────┐    │
        │        │ Campaign Phase Complete?           │    │
        │        └──────────────┬────────────────────┘    │
        │                       │                         │
        │        ┌──────────────┘                        │
        │        │                                      │
        │        ├─ No: Return to Geoscape               │
        │        │                                      │
        │        └─ Yes: ┌────────────────────────────┐ │
        │              │  CAMPAIGN PHASE COMPLETE    │ │
        │              │  • Show Completion Summary  │ │
        │              │  • Proceed to Next Phase    │ │
        │              │  • OR End Game (if final)   │ │
        │              └─────┬──────────────────────┘ │
        │                    │                        │
        └────────────────────┼────────────────────────┘
                             │
                  ┌──────────▼──────────┐
                  │  GAME OVER SCENE    │
                  │  (Victory/Defeat)   │
                  │  ├─ Final Summary    │
                  │  ├─ Score/Stats      │
                  │  └─ Menu Options     │
                  └─────────┬────────────┘
                            │
                ┌───────────┴──────────────┐
                │                          │
                ▼                          ▼
        ┌──────────────────┐      ┌──────────────┐
        │  BACK TO MENU    │      │  EXIT GAME   │
        │  New Game/Load   │      │  Return to   │
        │  Continue        │      │  Desktop     │
        └──────────────────┘      └──────────────┘
```

---

## Data Flow Between Layers

### Geoscape ↔ Battlescape Data Exchange

```
GEOSCAPE STATE
├─ Selected Mission
│  ├─ mission_id
│  ├─ mission_type (crash, terror, defense, alien_base, ufo_landing)
│  ├─ location (x, y coordinates)
│  ├─ biome_type (urban, forest, desert, etc.)
│  ├─ difficulty_range [min, max]
│  ├─ enemy_squad (faction, count, types)
│  └─ squad_selection (unit IDs selected)
│
├─ Player Squad Data
│  ├─ unit_id[]
│  │  ├─ stats (health, will, reaction, shooting, etc.)
│  │  ├─ equipment (weapon_id, armor_id, items[])
│  │  ├─ experience
│  │  └─ current_location (x, y on geoscape)
│  └─ craft_data (fuel, armor, weapons)
│
└─ Campaign Context
   ├─ current_phase
   ├─ month/year
   ├─ council_approval
   ├─ discovered_technologies
   └─ faction_relationships[]

                        │
                        │ PUSH TO BATTLESCAPE
                        │ PASS MISSION DATA
                        │ LOAD MAP SCRIPT
                        │ GENERATE PROCEDURAL MAP
                        │ INSTANTIATE UNITS
                        ▼

BATTLESCAPE STATE
├─ Map Data
│  ├─ width × height (procedurally generated)
│  ├─ tiles[] (terrain, obstacles, cover)
│  ├─ visibility_map (player line of sight)
│  └─ pathfinding_data (for AI movement)
│
├─ Unit Instances
│  ├─ PLAYER UNITS
│  │  ├─ unit_id: soldier_1
│  │  ├─ position: (x, y)
│  │  ├─ current_health: 30/30
│  │  ├─ action_points: 10
│  │  ├─ active_weapon: rifle_id
│  │  ├─ movement_path: []
│  │  └─ status_effects: []
│  │
│  └─ ENEMY UNITS (spawned from mission squad)
│     ├─ unit_id: alien_sectoid_1
│     ├─ position: (x, y)
│     ├─ current_health: 20/20
│     ├─ ai_state: patrolling
│     └─ target: player_unit_1
│
├─ Turn System
│  ├─ current_turn
│  ├─ turn_phase (player_action / ai_action / resolution)
│  ├─ actor_queue: [unit1, unit2, unit3, ...]
│  └─ initiative_order (based on reaction stat)
│
├─ Combat Log
│  ├─ action_history: []
│  │  └─ { turn: 1, actor: unit_1, action: "shoot", target: unit_2, result: hit/miss, damage: 25 }
│  └─ event_log: [] (kills, critical hits, effects)
│
└─ Mission State
   ├─ objective_type (eliminate_all, capture_object, survive, extract)
   ├─ objective_progress
   ├─ win_condition_met: false
   ├─ loss_condition_met: false
   ├─ civilians_rescued: 0
   └─ artifacts_collected: []

                        │
                        │ MISSION COMPLETE
                        │ CALCULATE RESULTS
                        │ PROCESS UNIT CHANGES
                        │ GENERATE LOOT
                        │ UPDATE STATISTICS
                        ▼

MISSION RESULTS DATA
├─ Battle Summary
│  ├─ outcome: "victory" / "defeat" / "abort"
│  ├─ turns_taken: 12
│  ├─ casualties_player: 1
│  ├─ casualties_enemy: 8
│  └─ completion_percentage: 95%
│
├─ Unit Updates (return to geoscape)
│  ├─ unit_1
│  │  ├─ experience_gained: 150 XP
│  │  ├─ health_change: 30 → 18 (wounded)
│  │  ├─ status: "needs_hospital"
│  │  ├─ promoted: false
│  │  └─ new_total_xp: 450
│  └─ unit_2
│     ├─ experience_gained: 100 XP
│     ├─ health_change: 30 → 0 (killed in action)
│     ├─ status: "deceased"
│     └─ drops_loot: true
│
├─ Loot Generated
│  ├─ items[] (alien weapons, armor, artifacts)
│  ├─ artifacts_research_points: 250
│  └─ salvage_value: 1500 credits
│
└─ Mission Rewards
   ├─ experience_reward: 500 XP (to research or to individual units)
   ├─ credit_reward: 1000
   ├─ council_approval_change: +5
   └─ technology_unlock_triggers: ["plasma_weapons"]

                        │
                        │ POP TO GEOSCAPE
                        │ UPDATE SQUAD STATE
                        │ ADD LOOT TO INVENTORY
                        │ UPDATE CRAFTS
                        ▼

GEOSCAPE STATE UPDATED
├─ Squad Status (after mission)
│  ├─ unit_1: health 18/30, needs hospital
│  ├─ unit_2: status DECEASED (remove from roster)
│  └─ unit_3: health 30/30, XP +100
│
├─ Inventory
│  ├─ new_items: [plasma_rifle, alien_armor, ...]
│  └─ salvage_value_added: 1500
│
└─ Craft State
   ├─ armor_damage: 50 HP (from interception)
   └─ fuel_consumed: 30%
```

---

## Mod Loading Sequence

```
APPLICATION START
        │
        ├─ Initialize Love2D Window
        ├─ Initialize Graphics/Audio Context
        ├─ Create Empty Game State Table
        │
        └─ LOAD MODS PHASE
           │
           ├─ Scan mods/ directory
           │  └─ Find all mod.toml files
           │
           ├─ Parse All mod.toml Files
           │  ├─ mods/core/mod.toml → { id: "core", version: "1.0.0", load_order: 1, ... }
           │  └─ mods/custom/mod.toml → { id: "custom", version: "1.0.0", load_order: 50, ... }
           │
           ├─ Resolve Dependencies
           │  ├─ Build dependency graph
           │  ├─ Check for conflicts
           │  ├─ Sort by load_order (lower first)
           │  └─ Result: [core (1), custom (50)]
           │
           ├─ Load TOML Content Files (by priority)
           │  │
           │  ├─ MOD: core (load_order: 1)
           │  │  ├─ Load mods/core/rules/items/weapons.toml
           │  │  │  └─ GameData.weapons = { rifle: {...}, pistol: {...}, ... }
           │  │  ├─ Load mods/core/rules/items/armor.toml
           │  │  │  └─ GameData.armor = { combat_armor_light: {...}, ... }
           │  │  ├─ Load mods/core/rules/facilities/base_facilities.toml
           │  │  │  └─ GameData.facilities = { power_generator: {...}, ... }
           │  │  ├─ Load mods/core/rules/units/soldiers.toml
           │  │  │  └─ GameData.units = { soldier_rookie: {...}, ... }
           │  │  ├─ Load mods/core/rules/units/aliens.toml
           │  │  ├─ Load mods/core/technology/catalog.toml
           │  │  │  └─ GameData.technologies = { phase0: [...], phase1: [...], ... }
           │  │  ├─ Load mods/core/factions/*.toml
           │  │  │  └─ GameData.factions = { faction_ethereals: {...}, ... }
           │  │  ├─ Load mods/core/economy/suppliers.toml
           │  │  │  └─ GameData.suppliers = { military_surplus: {...}, ... }
           │  │  ├─ Load mods/core/mapblocks/*.toml
           │  │  │  └─ GameData.mapblocks = { farm_field_01: {...}, ... }
           │  │  ├─ Load mods/core/mapscripts/mapscripts.toml
           │  │  │  └─ GameData.mapscripts = { crash_site_light: {...}, ... }
           │  │  └─ Load Asset Paths from [paths] section
           │  │     ├─ assets: assets/
           │  │     ├─ rules: rules/
           │  │     ├─ mapblocks: mapblocks/
           │  │     └─ tilesets: tilesets/
           │  │
           │  └─ MOD: custom (load_order: 50)
           │     ├─ Load mods/custom/rules/items/weapons.toml
           │     │  ├─ New weapons: plasma_rifle_mk2, ...
           │     │  ├─ Override existing? Check mod settings
           │     │  └─ GameData.weapons += custom_weapons
           │     └─ [Load other custom content...]
           │
           ├─ Validate All Loaded Content
           │  ├─ Check for ID conflicts
           │  ├─ Verify all references (weapon ammo_type exists, etc.)
           │  ├─ Validate numeric ranges
           │  └─ Log any warnings/errors
           │
           ├─ Initialize Content Managers
           │  ├─ WeaponManager.Init(GameData.weapons)
           │  ├─ ArmorManager.Init(GameData.armor)
           │  ├─ FacilityManager.Init(GameData.facilities)
           │  ├─ UnitManager.Init(GameData.units)
           │  ├─ TechnologyManager.Init(GameData.technologies)
           │  └─ SupplierManager.Init(GameData.suppliers)
           │
           └─ Load Asset Files
              ├─ Load Sprite Sheets from mods/*/assets/images/
              ├─ Load Tilesets from mods/*/tilesets/
              ├─ Load Audio from mods/*/assets/sounds/
              ├─ Create Texture Cache (sprites, tilesets, UI)
              └─ Asset Manager Ready
```

---

## Save/Load Process

### Save Game Flow

```
PLAYER INITIATES SAVE
(From menu or auto-save timer)
        │
        ├─ Prepare Save Package
        │  ├─ Save Slot Selection (0-11 or auto-save)
        │  └─ Generate Timestamp
        │
        ├─ Serialize Game State
        │  │
        │  ├─ Core Game State
        │  │  ├─ current_scene: "geoscape"
        │  │  ├─ game_time: { year: 2020, month: 3, day: 15, turn: 450 }
        │  │  ├─ campaign_phase: 1
        │  │  └─ campaign_progress: 65%
        │  │
        │  ├─ Player Organization
        │  │  ├─ org_level: 5
        │  │  ├─ credit_balance: 45000
        │  │  ├─ research_progress: { tech_id: 87/150 }
        │  │  ├─ manufacturing_queue: [item_1, item_2]
        │  │  ├─ council_approval: 72
        │  │  └─ faction_relationships: { faction_1: 45, faction_2: -20 }
        │  │
        │  ├─ Squad & Units
        │  │  ├─ unit_roster
        │  │  │  ├─ unit_id_1: { name, rank, health, will, xp, equipment, ... }
        │  │  │  ├─ unit_id_2: { ... }
        │  │  │  └─ unit_id_N: { ... }
        │  │  └─ squad_composition: [unit_1, unit_3, unit_5]
        │  │
        │  ├─ Inventory & Equipment
        │  │  ├─ items: { rifle: 5, laser_rifle: 2, plasma_rifle: 1, armor: 3, ... }
        │  │  ├─ crafts: { interceptor_1: {...}, transport_1: {...} }
        │  │  ├─ facilities: { power_gen_1: {...}, workshop_1: {...}, ... }
        │  │  └─ storage_used: 250/500
        │  │
        │  ├─ Geoscape World State
        │  │  ├─ provinces_controlled: [province_1, province_5, ...]
        │  │  ├─ bases: { base_1: { location, facilities, garrison, ... }, ... }
        │  │  ├─ missions_discovered: [mission_1, mission_3, ...]
        │  │  ├─ missions_completed: [mission_1, mission_2, ...]
        │  │  └─ craft_locations: { interceptor_1: base_1, transport_1: province_3 }
        │  │
        │  ├─ Technology & Research
        │  │  ├─ discovered_techs: [tech_1, tech_3, tech_7, ...]
        │  │  ├─ research_active: tech_id_5
        │  │  ├─ research_progress: 87 / 150
        │  │  └─ locked_technologies: [tech_20, tech_25, ...] (phase gated)
        │  │
        │  └─ Mod State
        │     ├─ loaded_mods: [core, custom_mod_1]
        │     ├─ mod_versions: { core: "1.0.0", custom_mod_1: "2.1.0" }
        │     └─ mod_content_hashes: {} (for validation on load)
        │
        ├─ Encode to Lua Table / JSON
        │  └─ Convert game state to serializable format
        │
        ├─ Compress Data
        │  └─ Optional: gzip compression for save size
        │
        └─ Write to Save File
           └─ love.filesystem.write("saves/save_slot_1.sav", encoded_data)


SAVE COMPLETE ✓
```

### Load Game Flow

```
PLAYER INITIATES LOAD
(From main menu)
        │
        ├─ Select Save Slot (0-11)
        │
        ├─ Read Save File
        │  └─ encoded_data = love.filesystem.read("saves/save_slot_N.sav")
        │
        ├─ Validate Save File
        │  ├─ Check file exists
        │  ├─ Check file not corrupted
        │  └─ Check version compatibility
        │
        ├─ Decompress Data (if compressed)
        │  └─ decoded_data = gunzip(encoded_data)
        │
        ├─ Parse Lua/JSON
        │  └─ game_state = deserialize(decoded_data)
        │
        ├─ Validate Content References
        │  ├─ Verify all unit IDs exist in current mod set
        │  ├─ Verify all item IDs exist
        │  ├─ Verify all tech IDs exist
        │  ├─ Check mod versions match or are compatible
        │  │
        │  └─ On Mismatch:
        │     ├─ Missing Content? → Fallback to defaults or skip
        │     ├─ Version Conflict? → Show warning but allow load
        │     └─ Incompatible? → Block load with error message
        │
        ├─ Restore Game State
        │  ├─ Load core game state
        │  ├─ Instantiate all units with correct stats
        │  ├─ Populate inventory with items
        │  ├─ Populate world with bases/crafts
        │  ├─ Restore current scene context
        │  └─ Initialize managers with loaded data
        │
        ├─ Initialize Active Scene
        │  │
        │  └─ If saved in Geoscape:
        │     ├─ Load world map data
        │     ├─ Display provinces/mission markers
        │     ├─ Load any pending notifications
        │     └─ Ready for player input
        │     
        │  └─ If saved in Battlescape:
        │     ├─ Load map/units from mid-mission
        │     ├─ Restore unit positions
        │     ├─ Restore unit action points
        │     ├─ Show battle UI
        │     └─ Ready to continue mission
        │
        ├─ Post-Load Cleanup
        │  ├─ Validate state consistency
        │  ├─ Trigger any pending events
        │  ├─ Reset timers/animations
        │  └─ Log load completion
        │
        └─ Display "Game Loaded" Message
           └─ Resume gameplay


LOAD COMPLETE ✓
```

---

## Mission Generation Flow

```
PLAYER CLICKS MISSION (Geoscape)
        │
        ├─ Get Mission Definition
        │  └─ mission_data = MISSIONS[mission_id]
        │     ├─ mission_type: "crash_site"
        │     ├─ difficulty: 3
        │     ├─ location: { province_id: 5, biome: "forest" }
        │     ├─ enemy_squad: { faction: "faction_sectoids", difficulty_modifier: 1.2 }
        │     └─ objectives: [eliminate_all, capture_artifact]
        │
        ├─ Load MapScript for Mission Type
        │  └─ mapscript = MAPSCRIPTS["crash_site_light"]
        │     ├─ mission_type: "crash_site"
        │     ├─ map_size: "small" (4×4 blocks = 64×64 tiles)
        │     ├─ difficulty_range: [1, 3]
        │     ├─ blocks: [
        │     │   { x: 1, y: 1, tags: ["ufo", "crash"], weight: 100, required: true },
        │     │   { x: 0, y: 0, tags: ["terrain"], weight: 80, required: false }
        │     │]
        │     ├─ spawn_zones: [
        │     │   { team: "player", x: 10, y: 10, radius: 6, count: 6 },
        │     │   { team: "aliens", x: 50, y: 50, radius: 8, count: 4 }
        │     │]
        │     └─ features: [{ type: "fire", x: 32, y: 32, radius: 3 }]
        │
        ├─ Procedurally Generate Map
        │  │
        │  ├─ Step 1: Create Biome Base
        │  │  ├─ Get biome_type: "forest"
        │  │  └─ Load base_tileset: forest_ground
        │  │
        │  ├─ Step 2: Place MapBlocks
        │  │  ├─ For each block in mapscript.blocks:
        │  │  │  ├─ Search for matching block with tags
        │  │  │  ├─ Weighted random selection (higher weight = more likely)
        │  │  │  ├─ Place block at grid position (x, y)
        │  │  │  └─ Merge tiles into map
        │  │  │
        │  │  ├─ Process "required" blocks first
        │  │  │  └─ Crash site UFO wreckage must be placed
        │  │  │
        │  │  └─ Process "optional" blocks with weight
        │  │     └─ Terrain and transition blocks selected probabilistically
        │  │
        │  ├─ Step 3: Create Unified Tile Map
        │  │  ├─ Merge all placed blocks into single map
        │  │  ├─ Resolve overlaps/gaps
        │  │  └─ Final map: 64×64 tiles (for "small" size)
        │  │
        │  ├─ Step 4: Initialize Pathfinding
        │  │  ├─ Create navigation graph
        │  │  ├─ Mark impassable tiles (walls, obstacles)
        │  │  └─ Precompute influence maps for AI
        │  │
        │  └─ Step 5: Place Environmental Features
        │     ├─ Place fire hazard at (32, 32) radius 3
        │     ├─ Place debris markers
        │     └─ Mark cover positions
        │
        ├─ Spawn Player Squad
        │  ├─ Get spawn_zone for "player" team
        │  │  └─ center: (10, 10), radius: 6
        │  ├─ For each unit in player_squad:
        │  │  ├─ Calculate spawn position within radius
        │  │  ├─ Verify position is walkable
        │  │  ├─ Create unit instance
        │  │  ├─ Set unit.position = spawn_pos
        │  │  ├─ Initialize unit stats from roster
        │  │  ├─ Set unit.action_points = reaction_stat × 10
        │  │  ├─ Set unit.current_health = max_health
        │  │  ├─ Equip unit with weapons/armor
        │  │  └─ Add to units_list
        │  └─ Result: player_units = [unit_1, unit_2, unit_3, ...]
        │
        ├─ Spawn Enemy Squad
        │  ├─ Get spawn_zone for "aliens" team
        │  │  └─ center: (50, 50), radius: 8
        │  ├─ Generate squad composition from mission enemy_squad
        │  │  ├─ Difficulty modifier: 1.2 (20% stronger)
        │  │  ├─ Faction: faction_sectoids
        │  │  ├─ Available units: [sectoid, sectoid_commander]
        │  │  ├─ Spawn count: 4 units
        │  │  ├─ Composition: [sectoid×3, sectoid_commander×1]
        │  │  └─ Apply difficulty scaling (higher damage/health)
        │  ├─ For each enemy unit:
        │  │  ├─ Calculate spawn position
        │  │  ├─ Create unit instance
        │  │  ├─ Set unit.position = spawn_pos
        │  │  ├─ Set unit.ai_state = "patrolling"
        │  │  ├─ Initialize with faction stats
        │  │  └─ Add to units_list
        │  └─ Result: enemy_units = [alien_1, alien_2, alien_3, alien_4]
        │
        ├─ Initialize Combat System
        │  ├─ Build actor_queue from all units
        │  ├─ Calculate initiative (based on reaction stat)
        │  ├─ Sort turn order: high reaction first
        │  ├─ Result: turn_order = [unit_1, unit_4, unit_2, unit_3, ...]
        │  └─ Initialize turn counter: current_turn = 1
        │
        ├─ Display Battle UI
        │  ├─ Show generated map (64×64 tiles)
        │  ├─ Show player units at spawn zone
        │  ├─ Show unit info panels
        │  ├─ Show action buttons
        │  └─ Highlight first actor's turn
        │
        └─ Mission Ready - Awaiting Player Input
           └─ Ready for turn 1 actions
```

---

## Combat Resolution Flow

```
BATTLESCAPE TURN LOOP
        │
        ├─ PLAYER ACTION PHASE
        │  │
        │  ├─ Highlight current player unit
        │  ├─ Show available actions:
        │  │  ├─ Move (to valid position within range)
        │  │  ├─ Attack (with weapon)
        │  │  ├─ Use Item (grenade, medikit)
        │  │  └─ End Turn
        │  │
        │  ├─ Wait for Player Input
        │  │  │
        │  │  ├─ Player Selects: MOVE
        │  │  │  ├─ Show movement range
        │  │  │  ├─ Player clicks destination
        │  │  │  ├─ Calculate path
        │  │  │  ├─ Deduct movement cost from action_points
        │  │  │  ├─ Unit moves to new position (animation)
        │  │  │  └─ Update visibility based on new position
        │  │  │
        │  │  ├─ Player Selects: ATTACK
        │  │  │  ├─ Show target list (visible enemies)
        │  │  │  ├─ Player selects target
        │  │  │  │  │
        │  │  │  │  ├─ Calculate Hit Chance
        │  │  │  │  │  ├─ base_accuracy = weapon.accuracy
        │  │  │  │  │  ├─ shooter_bonus = unit.shooting_stat
        │  │  │  │  │  ├─ range_penalty = distance / weapon.range
        │  │  │  │  │  ├─ cover_penalty = target_cover_value
        │  │  │  │  │  └─ final_hit_chance = base - range_penalty - cover_penalty + shooter_bonus
        │  │  │  │  │
        │  │  │  │  ├─ Roll for Hit
        │  │  │  │  │  ├─ roll = random(1, 100)
        │  │  │  │  │  ├─ If roll < final_hit_chance → HIT
        │  │  │  │  │  └─ If roll >= final_hit_chance → MISS
        │  │  │  │  │
        │  │  │  │  └─ If HIT:
        │  │  │  │     ├─ Calculate Damage
        │  │  │  │     │  ├─ base_damage = weapon.damage
        │  │  │  │     │  ├─ roll damage variance (±10%)
        │  │  │  │     │  ├─ critical_hit? Roll for critical (if > 100% accuracy)
        │  │  │  │     │  ├─ target_armor = target.armor_value
        │  │  │  │     │  ├─ penetration = weapon.armor_penetration
        │  │  │  │     │  ├─ final_damage = base_damage - (target_armor - penetration)
        │  │  │  │     │  └─ Clamp damage to 1 minimum
        │  │  │  │     │
        │  │  │  │     └─ Apply Damage
        │  │  │  │        ├─ target.current_health -= final_damage
        │  │  │  │        ├─ Log combat event
        │  │  │  │        ├─ If target.health <= 0:
        │  │  │  │        │  ├─ target.status = "killed"
        │  │  │  │        │  ├─ Attacker gains XP
        │  │  │  │        │  └─ Play death animation
        │  │  │  │        └─ Else:
        │  │  │  │           ├─ Play damage animation
        │  │  │  │           └─ Sound effect
        │  │  │  │
        │  │  │  └─ Deduct action_points from weapon
        │  │  │
        │  │  ├─ Player Selects: USE ITEM
        │  │  │  ├─ Show grenade/item options
        │  │  │  ├─ Show throw range
        │  │  │  ├─ Player selects location
        │  │  │  ├─ Calculate throw accuracy
        │  │  │  ├─ If successful: apply area effect
        │  │  │  ├─ Damage all units in radius
        │  │  │  └─ Deduct action_points
        │  │  │
        │  │  └─ Player Selects: END TURN
        │  │     └─ Move to next actor in turn queue
        │  │
        │  └─ If all player action points spent → AI Phase
        │
        ├─ AI ENEMY PHASE
        │  │
        │  ├─ For each enemy unit (in initiative order):
        │  │  │
        │  │  ├─ Get AI State
        │  │  │  ├─ If not_alert: Patrol (move randomly)
        │  │  │  ├─ If alert: Pursue player
        │  │  │  └─ If attacking: Use optimal weapon/action
        │  │  │
        │  │  ├─ AI Decision Making
        │  │  │  ├─ Update visibility (line of sight to player units)
        │  │  │  ├─ If player visible:
        │  │  │  │  ├─ Set target = nearest visible player unit
        │  │  │  │  ├─ Calculate best action:
        │  │  │  │  │  ├─ Option 1: Move closer to target
        │  │  │  │  │  ├─ Option 2: Attack target (if in range)
        │  │  │  │  │  └─ Option 3: Use special ability
        │  │  │  │  └─ Execute best action
        │  │  │  │
        │  │  │  └─ If player not visible:
        │  │  │     ├─ Move randomly (patrol)
        │  │  │     └─ Listen for sounds (gun shots, explosions)
        │  │  │
        │  │  ├─ Execute AI Action
        │  │  │  ├─ Move unit (with animation)
        │  │  │  ├─ OR Attack unit (same resolution as player attack)
        │  │  │  └─ Deduct action_points
        │  │  │
        │  │  └─ Next enemy unit (or end phase if all processed)
        │  │
        │  └─ AI Phase Complete
        │
        ├─ RESOLUTION PHASE
        │  ├─ Check Win Condition
        │  │  ├─ Objective: eliminate_all
        │  │  │  └─ If all aliens dead → VICTORY
        │  │  ├─ Objective: capture_artifact
        │  │  │  └─ If artifact picked up and extracted → VICTORY
        │  │  └─ Objective: survive
        │  │     └─ If 3 turns passed → VICTORY
        │  │
        │  ├─ Check Loss Condition
        │  │  ├─ If all player units dead → DEFEAT
        │  │  └─ If abort pressed → ABORT
        │  │
        │  ├─ Update Visual Display
        │  │  ├─ Update unit positions
        │  │  ├─ Update health bars
        │  │  ├─ Update action points
        │  │  └─ Clear any animations
        │  │
        │  └─ Advance Turn
        │     ├─ Increment current_turn
        │     ├─ Reset all unit action_points
        │     ├─ Update UI (new turn counter)
        │     └─ Go to next actor in queue
        │
        ├─ MISSION END CHECK
        │  ├─ If win/loss/abort:
        │  │  ├─ Stop turn loop
        │  │  ├─ Show mission result screen
        │  │  ├─ Calculate rewards
        │  │  ├─ Update unit stats
        │  │  └─ Return to geoscape
        │  └─ Else: Continue turn loop (next actor)
        │
        └─ REPEAT TURN LOOP
           └─ Back to player action phase


MISSION COMPLETE ✓
```

---

## Game Loop Timing

### Love2D Callback Execution (Per Frame)

```
APPLICATION RUNNING
        │
        ├─ love.update(dt) - Called 60× per second (16.67ms per frame)
        │  │ dt = delta time (time since last frame)
        │  │
        │  ├─ Update Game State
        │  │  ├─ Process input (keyboard, mouse)
        │  │  ├─ Update animations (sprite frames, tweens)
        │  │  ├─ Update physics/movement
        │  │  ├─ Update UI state (hover effects, etc.)
        │  │  └─ Update scene logic
        │  │
        │  ├─ Update Scene-Specific Logic
        │  │  │
        │  │  ├─ GEOSCAPE SCENE:
        │  │  │  ├─ Update mission markers
        │  │  │  ├─ Update craft positions
        │  │  │  ├─ Handle mouse input (click on mission/base)
        │  │  │  ├─ Update UI panels
        │  │  │  └─ Process turn (if in turn-based mode)
        │  │  │
        │  │  ├─ BATTLESCAPE SCENE:
        │  │  │  ├─ Handle player input (move, attack)
        │  │  │  ├─ Update unit animations
        │  │  │  ├─ Update camera position
        │  │  │  ├─ Highlight available targets
        │  │  │  └─ Execute pending AI actions
        │  │  │
        │  │  └─ BASESCAPE SCENE:
        │  │     ├─ Handle facility placement
        │  │     ├─ Update construction progress
        │  │     ├─ Update research progress
        │  │     └─ Handle marketplace interactions
        │  │
        │  └─ Update Audio
        │     ├─ Update sound volumes (fade in/out)
        │     ├─ Update music (play/stop)
        │     └─ Process pending sound effects
        │
        ├─ love.draw() - Called 60× per second after update()
        │  │
        │  ├─ Clear Screen
        │  │  └─ love.graphics.clear() - Black or background color
        │  │
        │  ├─ Draw Scene-Specific Content
        │  │  │
        │  │  ├─ GEOSCAPE SCENE:
        │  │  │  ├─ Draw world map background
        │  │  │  ├─ Draw provinces/countries
        │  │  │  ├─ Draw base markers
        │  │  │  ├─ Draw mission markers
        │  │  │  ├─ Draw craft positions
        │  │  │  └─ Draw UI panels (info, buttons)
        │  │  │
        │  │  ├─ BATTLESCAPE SCENE:
        │  │  │  ├─ Draw map tiles (procedurally)
        │  │  │  ├─ Draw environmental features (fire, rubble)
        │  │  │  ├─ Draw cover objects
        │  │  │  ├─ Draw player units (with sprites/animations)
        │  │  │  ├─ Draw enemy units
        │  │  │  ├─ Draw grid overlay (debug)
        │  │  │  ├─ Draw health bars (above units)
        │  │  │  ├─ Draw targeting reticle
        │  │  │  └─ Draw UI (action points, weapon info)
        │  │  │
        │  │  └─ BASESCAPE SCENE:
        │  │     ├─ Draw base grid (40×60)
        │  │     ├─ Draw facilities (with sprites)
        │  │     ├─ Draw facility details
        │  │     ├─ Draw connections (power lines, corridors)
        │  │     ├─ Draw UI panels (facility info)
        │  │     └─ Draw placement preview (when placing)
        │  │
        │  ├─ Draw Debug Info (if enabled)
        │  │  ├─ FPS counter
        │  │  ├─ Memory usage
        │  │  ├─ Current scene name
        │  │  └─ Mouse coordinates
        │  │
        │  └─ Present Frame
        │     └─ Swap backbuffer to display
        │
        └─ Repeat Every Frame (60×/second)
           └─ dt ≈ 16.67ms per frame
```

### Monthly Turn Processing (Geoscape)

```
ONE GAME MONTH PASSES (Player presses "End Month")
        │
        ├─ Monthly Update Phase (Once per game month)
        │  │
        │  ├─ Update Time
        │  │  ├─ month += 1
        │  │  ├─ If month > 12: month = 1, year += 1
        │  │  └─ Update UI display
        │  │
        │  ├─ Process Base Maintenance
        │  │  ├─ For each base:
        │  │  │  ├─ Calculate maintenance costs
        │  │  │  │  ├─ Layout cost = size² × 5K
        │  │  │  │  ├─ Facility costs = facility_count × avg_cost
        │  │  │  │  ├─ Unit salaries = unit_count × 5K
        │  │  │  │  └─ Total cost deducted from org_credits
        │  │  │  ├─ Process research progress
        │  │  │  │  ├─ active_research.progress += man_days_this_month
        │  │  │  │  ├─ If progress >= research.cost:
        │  │  │  │  │  ├─ research.complete = true
        │  │  │  │  │  ├─ Unlock new technologies
        │  │  │  │  │  ├─ Unlock new manufacturing options
        │  │  │  │  │  └─ Show notification
        │  │  │  ├─ Process manufacturing queue
        │  │  │  │  ├─ active_item.progress += production_rate_this_month
        │  │  │  │  ├─ If progress >= item.cost:
        │  │  │  │  │  ├─ item.complete = true
        │  │  │  │  │  ├─ Add to inventory
        │  │  │  │  │  └─ Show notification
        │  │  │  └─ Process healing/recovery
        │  │  │     ├─ For each wounded unit in hospital:
        │  │  │     │  ├─ health += recovery_rate
        │  │  │     │  ├─ If health >= max: unit ready
        │  │  │     │  └─ Remove from hospital when ready
        │  │  │     └─ Calculate facility damage/repair
        │  │  │
        │  │  └─ Generate Monthly Report
        │  │     ├─ Total income this month
        │  │     ├─ Total cost this month
        │  │     ├─ Net profit/loss
        │  │     ├─ Research progress
        │  │     ├─ Manufacturing progress
        │  │     ├─ Personnel status
        │  │     └─ Alerts (low funds, damage, etc.)
        │  │
        │  ├─ Generate Random Missions
        │  │  ├─ Difficulty = current_month / 3 (increases over time)
        │  │  ├─ Generate 1-3 random missions based on current factions
        │  │  ├─ Mission locations = random provinces
        │  │  ├─ Add missions to geoscape map
        │  │  └─ Show notifications
        │  │
        │  ├─ Process Faction Events
        │  │  ├─ Council approval changes
        │  │  ├─ Ally/enemy actions
        │  │  ├─ Diplomatic incidents
        │  │  └─ Influence missions
        │  │
        │  ├─ Process UFO Activity
        │  │  ├─ Generate random UFO sightings
        │  │  ├─ Generate UFO landing sites
        │  │  ├─ UFO terror attacks
        │  │  └─ UFO crash sites (may be explorable)
        │  │
        │  ├─ Check Campaign Phase Transitions
        │  │  ├─ If month >= phase_duration:
        │  │  │  ├─ Trigger phase completion event
        │  │  │  ├─ Advance to next campaign phase
        │  │  │  ├─ Unlock new technologies/factions
        │  │  │  └─ Show narrative sequence
        │  │  └─ If final phase complete:
        │  │     ├─ Show victory/defeat screen
        │  │     └─ End game
        │  │
        │  └─ Update Geoscape Display
        │     ├─ Refresh province control markers
        │     ├─ Update mission markers
        │     ├─ Update craft positions
        │     ├─ Show monthly report
        │     └─ Return to geoscape for player action
        │
        └─ MONTH PROCESSED ✓
           └─ Return to interactive geoscape
```

---

## Summary

This document provides comprehensive visual documentation of:

1. **System Architecture** - How all major systems interconnect
2. **State Transitions** - Complete game flow from menu to combat to results
3. **Data Flow** - How information moves between layers (Geoscape ↔ Battlescape ↔ Basescape)
4. **Mod Loading** - How content is loaded at startup and initialized
5. **Save/Load** - How game state is serialized and restored
6. **Mission Generation** - How procedural maps are created
7. **Combat Resolution** - Turn-based combat decision flow
8. **Game Loop Timing** - Per-frame update/draw cycle and monthly processing

All diagrams use ASCII art for version control and easy reference without external tools.

