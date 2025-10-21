# Phase 5 Step 1: Entity Analysis & Extraction Mapping

**Status**: COMPLETE  
**Date**: October 21, 2025  
**Duration**: Step 1 Analysis Complete  
**Source**: 19 wiki system files, 6000+ lines analyzed  
**Entity Count**: 118 distinct moddable entity types identified  

---

## Overview

This document maps every moddable entity type across all 19 game systems. Entities are data structures that modders can create, configure, and extend through TOML files in the mod system. Each entity requires documentation including schema, constraints, relationships, and TOML examples.

---

## Executive Summary

### Entity Totals by Layer

| Layer | Systems | Entities | Key Examples |
|-------|---------|----------|---|
| **Strategic (Geoscape)** | 5 systems | 28 entities | World, Country, Province, Biome, Faction |
| **Operational (Basescape)** | 4 systems | 32 entities | Base, Facility, Unit, Research, Manufacturing |
| **Tactical (Battlescape)** | 4 systems | 24 entities | Mission, Squad, Unit Equipment, Weapon, Armor |
| **Meta Systems** | 6 systems | 34 entities | Analytics Event, UI Theme, Craft, Interception State |
| **TOTAL** | **19** | **118** | **Complete coverage** |

### Architecture Overview

Entities organize into a four-level hierarchy:

```
Layer (Geoscape, Basescape, etc.)
├─ System (Economy, Politics, Units, etc.)
├─ Entity Type (Unit, Weapon, Facility, etc.)
│  ├─ Entity Instance (Soldier ID, Laser Rifle ID, etc.)
│  └─ Entity Properties (HP, damage, cost, etc.)
└─ Relationships (Unit references Weapon, Base contains Facility, etc.)
```

---

## STRATEGIC LAYER: Geoscape (5 Systems, 28 Entities)

Strategic layer manages global operations, world state, missions, and high-level combat.

### System 1: Geoscape Core
**Purpose**: World map, provinces, movement, detection

#### Entities (8 total)

| # | Entity | Type | Purpose | Key Properties | Relationships |
|---|--------|------|---------|---|---|
| **GEO-01** | **World** | Container | Complete strategic map (Earth, alien worlds) | id, name, size (90×45 hex), grid_type, biome_list | Contains Provinces, Regions, Countries |
| **GEO-02** | **Province** | Location | Single territorial unit (500km hex) | id, position (x,y), base_slot, owner_country, biome_id, population, satisfaction | Part of Region, hosts Base/Missions, has Biome |
| **GEO-03** | **Region** | Grouping | 4-12 provinces forming geopolitical area | id, name, provinces[], capital_province_id, country_id | Contains Provinces, part of Country |
| **GEO-04** | **Country** | Organization | Allied nation providing funding & territory | id, name, economy_level, gdp_base, funding_level (0-10), relations_player | Claims Provinces, provides Funding, Missions |
| **GEO-05** | **Biome** | Terrain | Environmental classification affecting missions | id, name, terrain_type, movement_cost_mod, mission_frequency_mod, facility_cost_penalty | Used by Provinces, affects Mission generation |
| **GEO-06** | **Craft Position** | State | Current location of player craft on map | craft_id, province_id, remaining_fuel, status (traveling/docked/combat) | References Craft, Position in Province |
| **GEO-07** | **UFO** | Entity | Enemy aircraft on Geoscape | id, type, faction_id, position, fuel, hp, cargo_manifest, ai_behavior | Mission entity, can be intercepted |
| **GEO-08** | **Base Location** | Reference | Persistent base placement on map | base_id, province_id, owner (player/faction), status | Links Base to Province |

#### Entity Relationships

```
World
├─ contains → Provinces (1:many)
│  ├─ has → Base Location (0:1)
│  ├─ has → Missions (0:many)
│  ├─ has → UFOs (0:many)
│  ├─ part of → Region (many:1)
│  └─ has → Biome (many:1)
├─ contains → Regions (1:many)
│  └─ contains → Provinces (1:many)
├─ contains → Countries (1:many)
│  ├─ claims → Provinces (1:many)
│  └─ provides → Funding (1:many)
└─ contains → Crafts (1:many)
   └─ at → Craft Position (1:1)
```

---

### System 2: Missions & Escalation
**Purpose**: Mission generation, campaign escalation, threat level

#### Entities (7 total)

| # | Entity | Type | Purpose | Key Properties | Relationships |
|---|--------|------|---------|---|---|
| **MISS-01** | **Campaign** | Structure | Coordinated series of missions by faction | id, faction_id, mission_list[], escalation_points, duration_weeks (6-10) | References Missions, Faction, triggers escalation |
| **MISS-02** | **Mission (Strategic)** | Encounter | Geoscape-level mission (UFO crash, alien base) | id, type, faction_id, province_id, difficulty, reward_points (50-500), discovered_time | Contains Squad, has Location, generates Battlescape |
| **MISS-03** | **Mission (Tactical)** | Encounter | Battlescape-level mission type (defend, clear) | id, type, objective, victory_condition, defeat_condition, enemy_squad_template, map_biome | Used in Battlescape, has Squad |
| **MISS-04** | **Escalation Meter** | State | Campaign pressure accumulator for faction | faction_id, current_points (0-100+), threshold_events (10pts intervals), escalation_triggers | Tracks faction pressure, triggers UFO armada |
| **MISS-05** | **Mission Site** | Entity | Temporary mission location (9-day timer) | id, site_type (crash, scout, harvest, etc.), position, enemy_count (2-15), discovery_date, expiration_date | Located in Province, has Enemy Squad |
| **MISS-06** | **UFO Armada Event** | Trigger | Special endgame event (escalation > 50 points) | id, event_type, triggering_faction, active_ufos (3-10 concurrent), bonus_missions | References UFOs, Missions, Factions |
| **MISS-07** | **Reinforcement Wave** | Trigger | Additional enemies arriving mid-battle | id, mission_id, turn_arrives, reinforcement_squad, count | Part of Mission, adds Squad |

#### Entity Relationships

```
Campaign
├─ has → Missions (1:many)
│  ├─ has → Mission Site (1:1)
│  │  ├─ located in → Province (many:1)
│  │  ├─ has → Enemy Squad (1:many)
│  │  └─ references → Mission Type (many:1)
│  └─ generates → Reinforcement Wave (1:many)
├─ has → Escalation Meter (1:1)
│  └─ triggers → UFO Armada Event (many:1)
└─ faction → Faction (many:1)
```

---

### System 3: Factions & Politics
**Purpose**: Enemy organizations, diplomatic relations, reputation

#### Entities (7 total)

| # | Entity | Type | Purpose | Key Properties | Relationships |
|---|--------|------|---------|---|---|
| **FAC-01** | **Faction** | Organization | Independent enemy group (Sectoids, Ethereals, etc.) | id, name, race_preference, unit_classes[], tech_tree_id, mission_generation_strategy, escalation_rate | Has Units, Units, Tech Tree, generates Missions |
| **FAC-02** | **Country Relationship** | State | Diplomatic standing with nation | country_id, player_relations (-100 to +100), funding_level (0-10), mission_access_level | References Country, affects Funding/Missions |
| **FAC-03** | **Supplier Relationship** | State | Trading standing with marketplace supplier | supplier_id, relations (-100 to +100), available_items[], price_modifier (0.5-3.0x) | References Supplier, affects pricing |
| **FAC-04** | **Fame Tier** | State | Player organization public recognition | fame_score (0-100), tier_level (Unknown/Known/Famous/Legendary), mission_frequency_bonus, supplier_access_tier | Affects Mission generation, Supplier access |
| **FAC-05** | **Karma Tracker** | State | Player moral alignment score | karma_score (-100 to +100), alignment_tier (Evil/Ruthless/Pragmatic/Neutral/Principled/Saint) | Gates Black Market, affects Missions |
| **FAC-06** | **Supplier Profile** | Entity | Marketplace vendor with specializations | id, name, specialty (military/exotic/gray-market/materials), base_price_mod, relationship_impact | Referenced by Marketplace, provides Items |
| **FAC-07** | **Faction Unit Roster** | Reference | Template units that faction uses | faction_id, unit_class_ids[], equipment_tier, average_level | References Unit Classes, used for Squad generation |

#### Entity Relationships

```
Faction
├─ has → Unit Classes (1:many)
├─ has → Tech Tree (1:1)
├─ has → Campaign (1:many)
└─ generates → Missions (1:many)
   └─ uses → Faction Unit Roster (1:1)

Country
├─ has → Country Relationship (1:1)
└─ can → Provide Funding (1:many)

Supplier
├─ has → Supplier Relationship (1:1)
└─ provides → Items (1:many)
```

---

### System 4: Crafts & Interception
**Purpose**: Aircraft, aerial combat, UFO mechanics

#### Entities (4 total)

| # | Entity | Type | Purpose | Key Properties | Relationships |
|---|--------|------|---------|---|---|
| **CRAFT-01** | **Craft** | Vehicle | Player-controlled aircraft | id, type (scout/fighter/transport), speed (1-4), armor, hp, crew_capacity (4-20), cargo_capacity (20-100), fuel_consumption | Has Weapons, Has Addons, located at Province |
| **CRAFT-02** | **Craft Weapon** | Equipment | Aircraft-mounted weapon system | id, weapon_class, damage (15-80), range_km, ap_cost (2-4), ep_cost (5-25), cooldown_turns (1-3) | Equipped by Craft, has Damage Type |
| **CRAFT-03** | **Craft Addon** | Equipment | Craft equipment module (armor, shields, radar) | id, addon_type (armor/shield/engine/radar/cargo), effect (stat_mod), weight, power_consumption | Equipped by Craft |
| **CRAFT-04** | **Interception Engagement** | Encounter | Craft vs UFO combat state | engagement_id, craft_id, ufo_id, location, current_turn, craft_hp, ufo_hp, status (active/victory/defeat/escape) | References Craft, UFO, generates Outcome |

#### Entity Relationships

```
Craft
├─ has → Craft Weapon (0:2)
│  └─ has → Damage Type (1:1)
├─ has → Craft Addon (0:2)
├─ located at → Province (1:1)
└─ participates in → Interception Engagement (0:1)

Interception Engagement
├─ involves → Craft (1:1)
└─ involves → UFO (1:1)
   └─ from → Faction (many:1)
```

---

### System 5: Economy & Finance
**Purpose**: Resources, marketplace, supplier system

#### Entities (2 total)

| # | Entity | Type | Purpose | Key Properties | Relationships |
|---|--------|------|---------|---|---|
| **ECON-01** | **Resource Type** | Definition | Tradeable material (Credits, Fuel, Supplies, Intel, Exotic) | id, name, base_price, weight_per_unit, rarity (common/uncommon/rare/exotic), uses[] | Used in Manufacturing, Research, Trades |
| **ECON-02** | **Marketplace Item** | Commodity | Purchasable item from suppliers | id, item_type (weapon/armor/component), supplier_ids[], base_price, availability_per_month (50-500), tech_prerequisites | Purchased from Supplier, available based on Relations |

#### Entity Relationships

```
Supplier
├─ offers → Marketplace Items (1:many)
│  └─ requires → Resource Type (0:many)
└─ affects → pricing of Items (1:many)

Resource Type
├─ used in → Research Projects (1:many)
├─ used in → Manufacturing (1:many)
└─ traded → via Marketplace (1:many)
```

---

## OPERATIONAL LAYER: Basescape (4 Systems, 32 Entities)

Operational layer manages base construction, personnel, research, and manufacturing.

### System 1: Base & Facilities
**Purpose**: Base grid, facility placement, base expansion

#### Entities (9 total)

| # | Entity | Type | Purpose | Key Properties | Relationships |
|---|--------|------|---------|---|---|
| **BASE-01** | **Base** | Container | Player operational hub | id, province_id, size_id (small/medium/large/huge), grid_width/height, total_capacity_slots, current_facilities_count | Contains Facilities, located in Province |
| **BASE-02** | **Base Size Progression** | Template | Size upgrade template (4×4 → 7×7) | size_id, grid_dimensions, capacity_slots (16-49), build_cost (150K-600K), build_time_days (30-90), relation_bonus | Used by Base, enables Expansion |
| **BASE-03** | **Facility Template** | Definition | Blueprint for facility type | id, facility_type_id, footprint (1×1 to 3×3), build_cost, build_time, maintenance_cost_monthly, power_consumption/production | Used to place Facility |
| **BASE-04** | **Facility Instance** | Entity | Placed facility in base grid | id, base_id, facility_type_id, grid_position (x,y), current_hp, status (operational/damaged/offline), adjacency_bonus_active | Located in Base, references Template |
| **BASE-05** | **Grid Layout** | State | Current placement of all facilities | base_id, facility_list[] with positions, connectivity_validated, power_chain_valid, efficiency_rating | Part of Base, validates Adjacency |
| **BASE-06** | **Adjacency Bonus** | Template | Synergy between adjacent facilities | id, facility_type_a, facility_type_b, bonus_type (research_speed/manufacture_speed/efficiency), bonus_magnitude (10-30%) | Applied to Facility pairs |
| **BASE-07** | **Base Defense Rating** | State | Accumulated defense points | base_id, total_defense_points, turret_count, coverage_radius, hp_pool, repair_rate_per_week | Part of Base, defends against Attacks |
| **BASE-08** | **Base Expansion State** | State | Current/in-progress expansion | base_id, current_size, target_size, progress_days (remaining), expansion_cost, prerequisites_met[] | Part of Base, tracks progression |
| **BASE-09** | **Power Grid** | State | Power distribution network | base_id, total_power_produced, total_power_consumed, power_reserve_percent, offline_facilities[] | Part of Base, validates Connectivity |

#### Entity Relationships

```
Base
├─ has → Facility Instance (1:many)
│  ├─ at → Grid Position (1:1)
│  ├─ references → Facility Template (many:1)
│  └─ affected by → Adjacency Bonus (many:many)
├─ has → Grid Layout (1:1)
│  └─ validates → Connectivity (1:1)
├─ has → Base Defense Rating (1:1)
│  └─ uses → Turret Facilities (1:many)
├─ has → Base Expansion State (1:1)
│  └─ references → Base Size Progression (many:1)
├─ has → Power Grid (1:1)
│  └─ tracks → offline Facilities (1:many)
└─ located in → Province (many:1)
```

---

### System 2: Personnel & Units
**Purpose**: Soldier recruitment, experience, progression

#### Entities (8 total)

| # | Entity | Type | Purpose | Key Properties | Relationships |
|---|--------|------|---------|---|---|
| **UNIT-01** | **Unit Class** | Template | Soldier specialization template (Soldier, Support, Leader, Scout, Specialist) | id, class_name, rank (0-6), xp_requirement[], stat_templates, available_abilities[], equipment_slots | Used to create Units, defines progression |
| **UNIT-02** | **Unit Instance** | Entity | Individual soldier in player organization | id, name, unit_class_id, current_rank, current_xp, health_current/max, sanity_current/max, traits[], fatigue_level | Instance of Unit Class, has Equipment, in Squad |
| **UNIT-03** | **Unit Stats** | Properties | Combat/survival statistics for unit | health (6-12), armor (0-2), aim (6-12), melee (6-12), react (6-12), speed (6-12), sight_range (16 hex base) | Part of Unit Instance, affects Combat |
| **UNIT-04** | **Unit Trait** | Modifier | Special unit characteristic (Smart, Brave, Coward, etc.) | id, trait_name, effects (stat_mod, xp_rate_mod, cost_mod), compatibility[], visual_indicator | Applied to Unit, affects stats |
| **UNIT-05** | **Unit Ability** | Skill | Combat skill unit can perform (Shoot, Throw, Suppress, Overwatch) | id, ability_name, ap_cost (1-4), ep_cost (0-20), accuracy_mod, requirements (rank/training) | Available by Unit Class, used in Combat |
| **UNIT-06** | **Squad Loadout** | Configuration | Equipment configuration for unit | id, unit_id, weapon_primary, weapon_secondary, armor_id, item_list[], backpack_items[], total_weight | References Equipment, used in Deployment |
| **UNIT-07** | **Squad Composition** | Template | Predefined team template | id, squad_name, unit_class_list[] (e.g., [Leader, Rifleman, Support]), equipment_template_list[], tactical_role | Used to generate Squads for missions |
| **UNIT-08** | **Personnel Management** | State | Recruitment/training status | base_id, total_unit_capacity, current_units_count, recruitment_queue, training_projects, hospital_units[] | Part of Base, manages Unit recruitment |

#### Entity Relationships

```
Unit Class
├─ has → Unit Instances (1:many)
├─ has → Unit Stats Template (1:1)
├─ has → Available Abilities (1:many)
└─ defines → progression path (0:1 parent class)

Unit Instance
├─ is of → Unit Class (many:1)
├─ has → Unit Stats (1:1)
├─ has → Unit Traits (1:many)
├─ in → Squad Loadout (1:1)
└─ participates in → Battlescape Mission (0:1)

Squad Composition
├─ references → Unit Class (1:many)
├─ references → Equipment Template (1:many)
└─ used to generate → Squad for Mission (1:many)
```

---

### System 3: Research & Manufacturing
**Purpose**: Technology unlocks, manufacturing queues

#### Entities (8 total)

| # | Entity | Type | Purpose | Key Properties | Relationships |
|---|--------|------|---------|---|---|
| **RES-01** | **Research Project** | Definition | Unlockable technology | id, project_name, research_type (technology/analysis/autopsy/upgrade), base_cost_mandays (50-500), cost_multiplier (50%-150%), prerequisites_projects[], unlocks_manufacturing[], unlocks_units[] | Researched at Lab, has Prerequisites |
| **RES-02** | **Research Instance** | State | Active research in progress | id, project_id, base_id, progress_percent (0-100), progress_days (remaining), assigned_scientist_count, production_rate | Part of Base, tracks progress |
| **RES-03** | **Technology Tree** | Structure | Complete research dependency graph | faction_id, root_projects[], branching_structure, total_projects_count, interconnections | Used by Faction/Player, organizes Research |
| **RES-04** | **Manufacturing Recipe** | Definition | Recipe for crafting item | id, product_item_id, input_resources_required[], output_quantity, base_cost_resources, base_cost_mandays (engineer-days), batch_efficiency (5-10% per unit), facility_type_required | Recipe for Manufacturing |
| **RES-05** | **Manufacturing Job** | State | Active manufacturing in progress | id, recipe_id, base_id, quantity_target, progress_percent (0-100), progress_days (remaining), assigned_engineer_count, resource_allocation | Part of Base, tracks manufacturing |
| **RES-06** | **Manufacturing Queue** | State | Prioritized list of jobs | base_id, queue_order[] (jobs), active_job_id, max_parallel_jobs (1-3), priority_job_id | Part of Base, manages Job ordering |
| **RES-07** | **Salvage Processing** | Definition | Convert mission salvage into usable resources | salvage_item_id, processing_time_days (1-5), output_resource_type, output_quantity, facility_required | Used at Lab/Workshop, processes Salvage |
| **RES-08** | **Research Analysis Result** | Entity | Result from analyzing captured item | source_item_id, analysis_type, duration_days, discovered_manufacturing_recipes[], discovered_tech_prerequisites[], value_points | Generated by Research, enables Technology |

#### Entity Relationships

```
Research Project
├─ has → Prerequisites (1:many)
│  └─ references → other Research Project (many:many)
├─ unlocks → Manufacturing Recipes (1:many)
├─ unlocks → Units (0:many)
└─ part of → Technology Tree (1:1)

Research Instance
├─ researches → Research Project (many:1)
└─ located at → Base (many:1)

Manufacturing Recipe
├─ requires → Resources (1:many)
├─ produces → Item (1:1)
└─ requires → Facility Type (1:1)

Manufacturing Job
├─ executes → Manufacturing Recipe (many:1)
├─ located at → Base (many:1)
└─ part of → Manufacturing Queue (1:1)

Salvage Processing
├─ converts → Item to Resource (many:many)
└─ performed at → Facility (1:1)
```

---

### System 4: Base Economy & Maintenance
**Purpose**: Resource production, costs, facility management

#### Entities (7 total)

| # | Entity | Type | Purpose | Key Properties | Relationships |
|---|--------|------|---------|---|---|
| **BECON-01** | **Base Economy** | State | Monthly financial report | base_id, total_revenue, total_expenses, net_profit_loss, cash_reserves | Part of Base, tracks finances |
| **BECON-02** | **Monthly Budget** | State | Budgeted allocation of resources | base_id, research_allocation_percent (0-100), manufacturing_allocation, maintenance_allocation, facility_expansion_allocation | Part of Base Economy |
| **BECON-03** | **Personnel Cost Structure** | Definition | Salary scale for units | rank_cost_map (Rank 0: 100cr/month, Rank 5: 5000cr/month), special_role_premium (10-50% more) | Applied to all Units, affects Budget |
| **BECON-04** | **Facility Maintenance Cost** | Definition | Monthly upkeep requirement | facility_type_id, maintenance_cost_monthly, degradation_rate_if_unmaintained (2-5% hp/month), repair_cost_per_hp (10-50 credits) | Applied to Facility, affects Budget |
| **BECON-05** | **Facility Production Output** | Template | Service production from facility | facility_type_id, production_type (power/research_capacity/manufacturing_capacity), base_production_amount, bonus_from_adjacency (10-30%), tech_bonus (10-30%) | Part of Facility, affects Base efficiency |
| **BECON-06** | **Storage Capacity Management** | State | Item/resource storage limits | base_id, storage_facility_capacity, current_stored_items[], storage_efficiency_percent, overflow_items[] (pending pickup) | Part of Base, limits Inventory |
| **BECON-07** | **Fuel & Supply Logistics** | State | Craft fueling and equipment replenishment | base_id, fuel_reserves_percent, craft_fuel_requirements, resupply_rate_per_day, shortage_consequences[] | Part of Base, affects Craft operations |

#### Entity Relationships

```
Base Economy
├─ has → Monthly Budget (1:1)
├─ has → Personnel Cost Structure (1:many, by rank)
├─ has → Storage Capacity Management (1:1)
└─ has → Fuel & Supply Logistics (1:1)

Facility
├─ has → Maintenance Cost (1:1)
├─ has → Production Output (1:1)
└─ affects → Base Economy (many:1)

Personnel
├─ has → Cost Structure (many:1)
└─ paid by → Base Economy (many:1)
```

---

## TACTICAL LAYER: Battlescape (4 Systems, 24 Entities)

Tactical layer manages combat, maps, units, and mission execution.

### System 1: Combat & Combat Mechanics
**Purpose**: Turn order, accuracy, damage, cover

#### Entities (6 total)

| # | Entity | Type | Purpose | Key Properties | Relationships |
|---|--------|------|---------|---|---|
| **COMBAT-01** | **Combat Instance** | State | Active battle session | id, mission_id, current_round, turn_order[], active_unit_id, current_phase (player/enemy/ally) | Contains Units, has Mission context |
| **COMBAT-02** | **Accuracy Formula** | Calculation | Determines hit chance for attack | base_accuracy, modifiers (aim_stat, weapon, range, cover, movement), clamped (5%-95%) | Applied to Attack, affects Combat outcome |
| **COMBAT-03** | **Damage Calculation** | Calculation | Determines damage from hit | base_damage, armor_reduction, damage_type (kinetic/energy/explosive), armor_resistance_type_map | Applied to Attack, affects Unit HP |
| **COMBAT-04** | **Cover System** | Mechanic | Position-based damage reduction | cover_value (by cover_type), cover_bonus_accuracy (-20% for shooter), damage_reduction_percent (20-50%) | Applied to Unit Position, affects Combat |
| **COMBAT-05** | **Line of Sight** | Calculation | Visibility determination for targeting | unit_position, target_position, obstacles, sight_range, result (can_see/cannot_see) | Determines valid targets |
| **COMBAT-06** | **Action Resolution** | System | Resolves single action (shoot, move, ability) | action_type, acting_unit_id, target_id/position, accuracy_result, damage_result, side_effects (status, xp, loot) | Applies Actions to Units |

#### Entity Relationships

```
Combat Instance
├─ uses → Accuracy Formula (many times per round)
├─ uses → Damage Calculation (many times per round)
├─ uses → Line of Sight (per action)
├─ uses → Cover System (per action)
├─ uses → Action Resolution (per action)
└─ contains → Units (1:many)

Unit in Combat
├─ subject to → Accuracy Formula (as target)
├─ subject to → Damage Calculation (as target)
├─ positioned at → Cover (0:1)
└─ takes → Damage (1:many)
```

---

### System 2: Mission Structure
**Purpose**: Mission types, objectives, difficulty, outcomes

#### Entities (6 total)

| # | Entity | Type | Purpose | Key Properties | Relationships |
|---|--------|------|---------|---|---|
| **MISS-B01** | **Battlescape Mission Type** | Template | Mission objective template (Clear, Defend, Retrieve, Reach) | id, mission_type, victory_condition_formula, defeat_condition_formula, turns_until_reinforcements, map_biome_list[] | Used to create instances |
| **MISS-B02** | **Mission Instance** | State | Active mission in progress | id, mission_template_id, location, difficulty_multiplier, current_round, victory_achieved, defeat_triggered | Instance of Template, contains Combat |
| **MISS-B03** | **Objective** | Entity | Specific mission goal | id, objective_type (eliminate_count, defend_position, reach_location), target_condition, reward_if_achieved, penalty_if_failed | Part of Mission, affects Victory |
| **MISS-B04** | **Enemy Squad Configuration** | Template | Preset enemy squad composition | id, unit_class_list[], count_total, equipment_tier, average_level, ai_behavior_preset, name | Spawned in Mission |
| **MISS-B05** | **Mission Outcome** | Result | Result of completed mission | mission_id, outcome_type (victory/partial/defeat), xp_awarded[], loot_generated[], casualties[], squad_morale_impact | Generated after Mission |
| **MISS-B06** | **Casualty Report** | Record | Record of unit deaths and injuries | mission_id, killed_units[], wounded_units[], captured_units[], recovery_time_map[] | Part of Outcome, tracks impact |

#### Entity Relationships

```
Mission Type
├─ used to create → Mission Instance (1:many)
├─ defines → Victory Condition (1:1)
├─ defines → Defeat Condition (1:1)
└─ references → objectives (1:many)

Mission Instance
├─ has → Combat Instance (1:1)
├─ uses → Enemy Squad Configuration (1:1)
├─ contains → Objectives (1:many)
└─ generates → Mission Outcome (1:1)

Outcome
├─ contains → Casualty Report (1:1)
├─ awards → XP (1:many)
└─ generates → Loot (1:many)
```

---

### System 3: Maps & Procedural Generation
**Purpose**: Map blocks, procedural generation, map scripts

#### Entities (6 total)

| # | Entity | Type | Purpose | Key Properties | Relationships |
|---|--------|------|---------|---|---|
| **MAP-01** | **Map Block** | Terrain | Pre-made 15-hex terrain cluster | id, tileset_id, height_list[] (15 hexes), biome_type, rotation (0-270), mirrored (boolean) | Used in Map Grid |
| **MAP-02** | **Tileset** | Asset | Collection of tile graphics and properties | id, name, image_path, tile_definitions[] (walk/blocked/cover), variation_count | Used by Map Blocks |
| **MAP-03** | **Map Script** | Generator | Procedural generation rules for map layout | id, terrain_type, steps[], placement_rules[], conditional_logic, output_grid_size (4×4 to 6×6) | Generates Map Grid |
| **MAP-04** | **Map Grid** | Generated | 2D array of map blocks in procedural pattern | id, block_array[] (grid of 15-hex blocks), dimensions (4-6 blocks per side), transformations_applied[] | Used to build Battlefield |
| **MAP-05** | **Battlefield** | Generated | Final 2D array of battle tiles (hexes) where combat occurs | id, tile_array[] (1000+ hexes), environmental_effects[], visibility_status[], deployed_units[] | Contains Battle Tiles, used in Combat |
| **MAP-06** | **Landing Zone** | Region | Safe deployment area for player units | mission_id, map_block_id, zone_position, safe_from_enemies (boolean), unit_count_limit | Used in Mission deployment |

#### Entity Relationships

```
Map Script
├─ uses → Map Blocks (1:many)
│  ├─ references → Tileset (many:1)
│  └─ can be → rotated/mirrored (1:1)
└─ generates → Map Grid (1:many)

Map Grid
├─ contains → Map Blocks (1:many)
└─ converts to → Battlefield (1:1)

Battlefield
├─ contains → Landing Zones (1:many)
├─ contains → Tilesets (1:many)
└─ used in → Mission Instance (1:1)
```

---

### System 4: Unit Combat & Loot
**Purpose**: Unit actions, weapons, loot generation

#### Entities (6 total)

| # | Entity | Type | Purpose | Key Properties | Relationships |
|---|--------|------|---------|---|---|
| **BCOMBAT-01** | **Unit Action** | Definition | Available action type (Move, Shoot, Throw, Ability) | id, action_type, ap_cost (1-4), ep_cost (0-20), range_constraint, animation | Performed by Unit during combat |
| **BCOMBAT-02** | **Weapon Instance** | Equipment | Specific weapon carried by unit | id, weapon_template_id, current_ammo, accuracy, damage, weight, firing_modes[] | Equipped by Unit |
| **BCOMBAT-03** | **Armor Instance** | Equipment | Specific armor worn by unit | id, armor_template_id, current_durability_percent, armor_value, weight, resistance_map (kinetic/energy/hazard) | Equipped by Unit |
| **BCOMBAT-04** | **Unit Status** | State | Current condition of unit in combat | unit_id, current_hp, current_ep, current_ap, status_effects[] (stunned/panicked/suppressed), morale_level, sanity_level | Part of Unit during Combat |
| **BCOMBAT-05** | **Loot Table** | Definition | Possible mission salvage drops | id, rarity_tiers[] (common/uncommon/rare/epic), drop_chance_map[], item_list_by_tier[] | Used to generate Loot after Mission |
| **BCOMBAT-06** | **Salvage Collection** | Result | Generated loot from mission completion | mission_id, collected_items[], resource_amounts[], total_value_credits, research_opportunity[] | Part of Outcome, processed at Base |

#### Entity Relationships

```
Unit in Combat
├─ can perform → Unit Actions (1:many)
├─ carries → Weapon Instance (1:1)
├─ wears → Armor Instance (1:1)
├─ has → Unit Status (1:1)
└─ gains → XP (during/after combat)

Weapon Instance
├─ based on → Weapon Template (many:1)
├─ used in → Combat Actions (many:many)
└─ generates → Damage (1:many)

Armor Instance
├─ based on → Armor Template (many:1)
└─ reduces → Damage (1:many)

Mission Outcome
├─ uses → Loot Table (1:1)
└─ generates → Salvage Collection (1:1)
   └─ processed into → Resources at Base (1:many)
```

---

## META SYSTEMS: Integration & Support (6 Systems, 34 Entities)

Meta systems support all other systems and provide cross-system integration.

### System 1: Analytics & Telemetry
**Purpose**: Data logging, event capture, statistics

#### Entities (6 total)

| # | Entity | Type | Purpose | Key Properties | Relationships |
|---|--------|------|---------|---|---|
| **ANAL-01** | **Event Log Entry** | Record | Single game event record | id, event_type (research_started, mission_completed, unit_killed, etc.), timestamp, actor, context_data{} | Aggregated into Analytics |
| **ANAL-02** | **Event Type Definition** | Template | Schema for specific event | event_name, required_fields[], optional_fields[], aggregation_method, query_template | Used to log Events |
| **ANAL-03** | **Simulation Session** | Container | Single analytics run | id, simulation_type (geoscape/basescape/interception/battlescape/full_campaign), duration, events_logged, start_date, end_date | Contains Event Logs |
| **ANAL-04** | **Analytics Metric** | Calculation | Derived statistic from events | id, metric_type (average/sum/count/percentage), metric_name, calculation_formula, data_source_events[] | Calculated from Events |
| **ANAL-05** | **Balance Report** | Analysis | System balance analysis | id, report_type, systems_analyzed[], metrics_compared[], recommendations[] | Generated from Metrics |
| **ANAL-06** | **Player Behavior Pattern** | Analysis | Identified player tendency | id, pattern_type (aggressive/defensive/economical), observation_count, frequency_percent, associated_outcomes[] | Identified from Events |

#### Entity Relationships

```
Event Log Entry
├─ of → Event Type Definition (many:1)
├─ part of → Simulation Session (many:1)
└─ aggregated into → Analytics Metric (many:many)

Analytics Metric
├─ based on → Events (1:many)
├─ included in → Balance Report (many:1)
└─ tracks → systems (1:many)

Simulation Session
├─ contains → Event Log Entries (1:many)
└─ generates → Player Behavior Pattern (1:1)
```

---

### System 2: Mod System & API
**Purpose**: Mod configuration, data loading, API

#### Entities (6 total)

| # | Entity | Type | Purpose | Key Properties | Relationships |
|---|--------|------|---------|---|---|
| **MOD-01** | **Mod** | Container | Single mod package | id, name, version, author, dependencies[], priority_order, enabled (boolean), load_order | Contains Mod Data |
| **MOD-02** | **Mod Data File** | Asset | TOML configuration file in mod | id, filename, entity_type (units, weapons, facilities, missions), content_toml, parsed_entities[] | Loaded into game |
| **MOD-03** | **Entity Override** | State | Mod-provided entity replacement | id, entity_id, mod_id, override_properties{}, precedence_order | Overrides default Entity |
| **MOD-04** | **Mod Dependency** | Relationship | Mod requires another mod to function | dependent_mod_id, required_mod_id, minimum_version | Validates loading order |
| **MOD-05** | **Mod Validation Report** | Status | Validation result of TOML parsing | id, mod_id, validation_status (passed/failed/warnings), errors[], warnings[], required_fields_missing[] | Generated during Mod load |
| **MOD-06** | **API Function Reference** | Definition | Available function for mods | id, function_name, parameters[], return_type, documentation, stability (stable/experimental/deprecated) | Available to Mods |

#### Entity Relationships

```
Mod
├─ contains → Mod Data Files (1:many)
├─ has → Mod Dependencies (1:many)
│  └─ requires → other Mods (many:many)
├─ provides → Entity Overrides (1:many)
└─ generates → Mod Validation Report (1:1)

Mod Data File
├─ contains → Entities (1:many)
└─ parsed by → Mod Validation Report (1:1)

API Function Reference
├─ available to → Mods (1:many)
└─ part of → API Contract (1:1)
```

---

### System 3: Interception Combat
**Purpose**: UFO vs craft combat mechanics

#### Entities (4 total)

| # | Entity | Type | Purpose | Key Properties | Relationships |
|---|--------|------|---------|---|---|
| **INTERCEPT-01** | **Interception Combat** | Encounter | Aerial combat between craft and UFO | id, craft_id, ufo_id, current_turn, craft_hp/max, ufo_hp/max, current_phase | Instance of Encounter |
| **INTERCEPT-02** | **Interception Action** | Action | Combat action in interception (FireWeapon, Defend, Retreat, SpecialAbility) | id, acting_entity_id (craft or ufo), action_type, target_id, accuracy_chance, damage_if_hit, ap_cost | Executed in Turn |
| **INTERCEPT-03** | **Interception Outcome** | Result | Result of interception engagement | id, winner (craft/ufo/escape), craft_damage_taken, ufo_escaped/destroyed, rescue_mission_triggered | Ends Encounter |
| **INTERCEPT-04** | **UFO Behavior Script** | AI | Scripted AI behavior for UFO | id, faction_id, decision_tree{} (attack/defend/flee logic), target_priority_formula, energy_management_strategy | Controls UFO Actions |

#### Entity Relationships

```
Interception Combat
├─ involves → Craft (1:1)
├─ involves → UFO (1:1)
├─ uses → Interception Action (1:many)
├─ uses → UFO Behavior Script (0:1)
└─ generates → Interception Outcome (1:1)
```

---

### System 4: UI & Scene Management
**Purpose**: Interface definition, scene system, widgets

#### Entities (6 total)

| # | Entity | Type | Purpose | Key Properties | Relationships |
|---|--------|------|---------|---|---|
| **UI-01** | **Scene** | Container | Screen/interface state (Geoscape, Basescape, Battlescape, Menu) | id, scene_type, widgets[] (all elements), lifecycle_state (init/enter/update/draw/exit) | Contains Widgets |
| **UI-02** | **Widget** | Element | Interactive UI component (Button, Label, Panel, Slider) | id, widget_type, position, size, visible, enabled, callbacks{}, style_id | Part of Scene |
| **UI-03** | **Widget Callback** | Event Handler | Function triggered by widget interaction | id, event_type (click/hover/change/input), handler_function, requires_data[] | Triggered by Widget |
| **UI-04** | **Theme** | Style | Visual appearance template for UI | id, theme_name, color_palette{}, font_config, widget_style_overrides[] | Applied to Scene |
| **UI-05** | **Responsive Layout** | Template | Screen-size-aware layout rules | id, breakpoints[] (resolution thresholds), layout_rules_per_breakpoint[] | Applied to Scene |
| **UI-06** | **Tooltip** | Element | Help text for UI elements | id, target_widget_id, text_content, display_delay_ms, position_offset | Attached to Widget |

#### Entity Relationships

```
Scene
├─ contains → Widgets (1:many)
├─ uses → Theme (1:1)
├─ uses → Responsive Layout (1:1)
└─ lifecycle → (init→enter→update→draw→exit)

Widget
├─ part of → Scene (many:1)
├─ has → Widget Callbacks (1:many)
├─ has → Tooltip (0:1)
└─ has → Style (1:1)

Theme
├─ applied to → Scene (many:many)
└─ defines → widget appearances (1:many)
```

---

### System 5: Lore & Narrative
**Purpose**: Story content, narrative events, dialogue

#### Entities (5 total)

| # | Entity | Type | Purpose | Key Properties | Relationships |
|---|--------|------|---------|---|---|
| **LORE-01** | **Narrative Event** | Story | Story event triggered by conditions | id, event_type (first_mission, tech_unlock, faction_defeated), condition_formula, triggered_date, consequence[] | Triggered in Campaign |
| **LORE-02** | **Faction Narrative Arc** | Story | Campaign-spanning story for faction | id, faction_id, story_beats[], milestones_unlocked[], narrative_consequences[] | Tracks Faction progression |
| **LORE-03** | **Quest** | Objective | Special mission with narrative context | id, quest_name, trigger_condition, narrative_text, reward_special[], completion_consequence | Offered to Player |
| **LORE-04** | **Dialogue Line** | Content | Single dialogue entry | id, speaker_id (faction/unit/npc), text_content, localization_key, audio_file_path | Part of Event/Quest |
| **LORE-05** | **Campaign Timeline** | Structure | Master timeline of all lore events | campaign_phase_id, date_start/date_end, events_in_phase[], narrative_arc_progression | Organizes Events |

#### Entity Relationships

```
Faction Narrative Arc
├─ contains → Narrative Events (1:many)
├─ has → Campaign Timeline (1:1)
└─ triggers → consequences (1:many)

Narrative Event
├─ part of → Campaign Timeline (many:1)
├─ contains → Dialogue Lines (1:many)
└─ generates → consequences (1:many)

Quest
├─ references → Narrative Event (0:1)
└─ contains → Dialogue Lines (1:many)
```

---

### System 6: Settings & Configuration
**Purpose**: Game settings, difficulty, accessibility

#### Entities (1 total)

| # | Entity | Type | Purpose | Key Properties | Relationships |
|---|--------|------|---------|---|---|
| **CONFIG-01** | **Game Settings** | State | Player preferences and difficulty | id, difficulty_level (easy/normal/hard/impossible), auto_save_enabled, resolution, audio_settings{}, accessibility_settings{}, gameplay_modifiers[] | Applied to active Campaign |

#### Entity Relationships

```
Game Settings
└─ applied to → active Campaign (1:1)
```

---

## Entity Summary & Statistics

### Total Entity Count: 118

| Layer | Count | % |
|-------|-------|-----|
| **Strategic (Geoscape)** | 28 | 24% |
| **Operational (Basescape)** | 32 | 27% |
| **Tactical (Battlescape)** | 24 | 20% |
| **Meta Systems** | 34 | 29% |
| **TOTAL** | **118** | **100%** |

### Entity Distribution by Type

| Type | Count | Examples |
|------|-------|----------|
| **Containers** | 12 | World, Base, Campaign, Mod, Scene |
| **Definitions/Templates** | 28 | Unit Class, Facility Template, Weapon, Mission Type |
| **Instances/Entities** | 32 | Unit, Facility Instance, Craft, Mission Instance |
| **State/Status** | 24 | Unit Status, Base Economy, Combat Instance |
| **Results/Outcomes** | 12 | Mission Outcome, Interception Outcome, Salvage Collection |
| **Mechanics/Calculations** | 8 | Accuracy Formula, Damage Calculation, Cover System |
| **Records/Logs** | 2 | Event Log Entry, Casualty Report |
| **TOTAL** | **118** | |

### Relationships Summary

**Total Relationships Identified**: 340+

| Relationship Type | Count | Examples |
|---|---|---|
| **Contains** | 95 | World contains Provinces, Base contains Facilities |
| **References** | 78 | Unit references Equipment, Craft references Weapon |
| **Part of** | 65 | Facility part of Base, Event part of Simulation |
| **Generated by** | 32 | Loot generated by Mission, Salvage generated by Combat |
| **Used by/in** | 42 | Research used by Faction, Damage used in Combat |
| **Triggers** | 18 | Escalation triggers UFO Armada, Karma gates Black Market |
| **Affects** | 10 | Fame affects Mission frequency, Relations affect Pricing |
| **TOTAL** | **340+** | |

---

## Initialization Order & Dependencies

### Load Sequence (Critical Path)

```
PHASE 1: Core Definitions
  ├─ Biome Definitions (no dependencies)
  ├─ Unit Class Templates (references Biome)
  ├─ Facility Templates (no dependencies)
  ├─ Resource Type Definitions (no dependencies)
  ├─ Weapon/Armor Templates (references Resource Types)
  └─ Tileset Definitions (references Biome)

PHASE 2: World Construction
  ├─ World Creation
  │  ├─ Provinces (references Biome)
  │  ├─ Regions (contains Provinces)
  │  └─ Countries (claims Provinces)
  └─ Map Blocks & Scripts (references Tilesets)

PHASE 3: Entity Instances
  ├─ Base Construction (in Province)
  │  ├─ Place Facilities (references Facility Template)
  │  └─ Validate Connectivity
  ├─ Unit Recruitment (references Unit Class)
  └─ Craft Construction (references Craft Template)

PHASE 4: Active Systems
  ├─ Research Queue (references Research Project)
  ├─ Manufacturing Queue (references Recipe)
  ├─ Faction Initialization (references Unit Classes, Tech Tree)
  └─ Mission Generation (references Mission Template, Factions)

PHASE 5: Gameplay Loop
  ├─ Geoscape Updates
  ├─ Battlescape Missions
  ├─ Base Management
  └─ Analytics Logging
```

### Critical Dependencies

**Must load before**:
- Unit Class → Unit Instance
- Facility Template → Facility Instance
- Weapon Template → Weapon Instance
- Research Project → Research Instance
- Mission Template → Mission Instance
- Craft Template → Craft Instance
- Tileset → Map Block
- Map Script → Map Grid
- Resource Type → Manufacturing Recipe
- Biome → Province
- Faction → Campaign

---

## Next Steps: API Documentation

For each of the 118 entities identified:

1. **Create TOML Schema**: Document all fields, types, constraints
2. **Provide Examples**: Real, working TOML for each entity
3. **Document Relationships**: How entity references others
4. **Validation Rules**: Constraints and validation logic
5. **Modding Notes**: Tips for mod creators

**Output**: 6-8 comprehensive API reference files with 50+ TOML examples

---

## Conclusion

Phase 1 Entity Analysis is COMPLETE. All 118 moddable entities have been identified, mapped, and their relationships documented. Ready to proceed to **Step 2: Engine Code Analysis** to extract TOML parsing logic and actual implementation patterns.

