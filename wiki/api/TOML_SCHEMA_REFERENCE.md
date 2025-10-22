````markdown
# Consolidated TOML Schema Reference

**Purpose:** Complete TOML configuration schema for all game systems  
**Generated:** October 22, 2025  
**Format:** TOML with inline documentation

---

## Root Configuration Structure

```toml
# game_config.toml - Master configuration file

[game]
title = "AlienFall"
version = "1.0.0"
target_fps = 60
debug_mode = false

[systems]
initialization_order = ["core", "geoscape", "basescape", "battlescape"]
validation_level = "strict"  # strict, warnings, permissive
```

---

## Core Infrastructure TOML

### system_initialization.toml

```toml
[initialization_order]
sequence = [
  "core",        # Must be first
  "geoscape",
  "basescape",
  "battlescape",
  "economy",
  "research",
  "ai",
  "ui",
]

[system_dependencies]
battlescape = ["geoscape", "basescape"]
economy = ["basescape", "crafts"]
research = ["economy", "basescape"]
interception = ["crafts", "geoscape"]

[system_timeouts]
initialization_timeout_ms = 5000
shutdown_timeout_ms = 3000

[system_priorities]
core_priority = 100
critical_priority = 90
normal_priority = 50
ui_priority = 10
```

### event_definitions.toml

```toml
[[events]]
id = "game_started"
category = "session"
description = "Game session initialized"
required_data = ["timestamp", "world_id"]

[[events]]
id = "game_ended"
category = "session"
description = "Game session concluded"
required_data = ["timestamp", "final_turn"]

[[events]]
id = "battle_started"
category = "combat"
description = "Battle began"
required_data = ["battle_id", "player_squad", "enemy_squad"]

[[events]]
id = "battle_completed"
category = "combat"
description = "Battle finished"
required_data = ["battle_id", "winner", "casualties"]

[[events]]
id = "tech_researched"
category = "research"
description = "Technology completed"
required_data = ["tech_id", "completion_turn"]

[[events]]
id = "unit_promoted"
category = "progression"
description = "Unit ranked up"
required_data = ["unit_id", "new_rank", "promotion_date"]

[[events]]
id = "facility_constructed"
category = "construction"
description = "Facility built"
required_data = ["facility_id", "base_id", "completion_turn"]

[[events]]
id = "mission_completed"
category = "missions"
description = "Mission finished"
required_data = ["mission_id", "result", "casualties"]

[[events]]
id = "funding_changed"
category = "politics"
description = "Country funding modified"
required_data = ["country_id", "old_amount", "new_amount"]
```

### analytics_config.toml

```toml
[tracking]
enabled = true
track_combat = true
track_economy = true
track_progression = true
track_performance = true
track_ai_decisions = false  # Verbose

[reporting]
auto_report_frequency = 3600  # Seconds
report_to_file = true
report_filename = "analytics.json"
report_directory = "user_data/analytics"

[performance]
fps_target = 60
memory_warning_threshold = 1024  # MB
frame_time_budget = 16.67  # ms (60 FPS)
profile_systems_on_startup = false

[achievements]
enabled = true
auto_unlock = false
save_to_profile = true
```

---

## Geoscape TOML

### geoscape/world.toml

```toml
[world_earth]
id = "earth"
name = "Earth"
type = "planet"
radius_km = 6371

# Global time scale
calendar_type = "gregorian"
initial_year = 2025
initial_month = 1
initial_day = 1
turns_per_month = 30  # 30-turn month cycles

# Procedural generation
seed = 12345  # 0 = random
province_count = 48
starting_province_id = "north_america"

# Game difficulty
difficulty = "normal"  # Easy, Normal, Hard, Impossible
difficulty_multiplier = 1.0

# Economic baseline
starting_budget = 100000
monthly_baseline_funding = 15000
```

### geoscape/mission_templates.toml

```toml
[[mission_template]]
id = "terror_mission"
name = "Terror Attack"
mission_type = "ground_combat"
threat_level = "high"
base_reward = 5000
casualty_impact = 2.0  # Modifier on support loss

[[mission_template]]
id = "ufo_crash_recovery"
name = "UFO Crash Recovery"
mission_type = "ground_combat"
threat_level = "medium"
base_reward = 8000
research_bonus = 3  # Tech points

[[mission_template]]
id = "research_site"
name = "Research Site"
mission_type = "ground_combat"
threat_level = "high"
base_reward = 4000
research_bonus = 5

[[mission_template]]
id = "council_mission"
name = "Council Mission"
mission_type = "ground_combat"
threat_level = "variable"
base_reward = 10000
support_bonus = 20  # Percentage points
```

---

## Crafts TOML

### crafts/craft_types.toml

```toml
[[craft_type]]
id = "interceptor"
name = "Fighter Interceptor"
crew_capacity = 1
armor = 50
speed = 850  # km/h
fuel_capacity = 1000
weapon_slots = 2
addon_slots = 1
build_cost = 500000
monthly_maintenance = 5000

[[craft_type]]
id = "transport"
name = "Cargo Transport"
crew_capacity = 12
armor = 30
speed = 500
fuel_capacity = 2000
weapon_slots = 1
addon_slots = 2
build_cost = 300000
monthly_maintenance = 3000

[[craft_type]]
id = "bomber"
name = "Heavy Bomber"
crew_capacity = 3
armor = 80
speed = 600
fuel_capacity = 1500
weapon_slots = 4
addon_slots = 1
build_cost = 800000
monthly_maintenance = 8000
```

### crafts/weapons.toml

```toml
[[weapon]]
id = "cannon_30mm"
name = "30MM Cannon"
type = "ballistic"
damage = 30
range_km = 50
ammo_capacity = 500
ammo_type = "cannon_round"
fire_rate = 20  # Rounds per second
cost = 50000
weight = 500  # kg

[[weapon]]
id = "missile_air_to_air"
name = "Air-to-Air Missile"
type = "missile"
damage = 80
range_km = 100
ammo_capacity = 8
ammo_type = "missile_aa"
fire_rate = 2  # Per second
cost = 150000
weight = 300

[[weapon]]
id = "plasma_cannon"
name = "Plasma Cannon"
type = "energy"
damage = 120
range_km = 60
ammo_capacity = 100  # Energy units
ammo_type = "plasma"
fire_rate = 5
cost = 400000
weight = 600
```

### crafts/addons.toml

```toml
[[addon]]
id = "fuel_tank_extended"
name = "Extended Fuel Tank"
type = "utility"
fuel_bonus = 500
weight = 300
cost = 50000
maintenance_cost = 500

[[addon]]
id = "armor_plating"
name = "Combat Armor Plating"
type = "defense"
armor_bonus = 30
weight = 800
cost = 100000
maintenance_cost = 1500
```

---

## Basescape TOML

### basescape/base_sizes.toml

```toml
[[base_size]]
id = "small"
name = "Small Outpost"
grid_width = 4
grid_height = 4
total_capacity = 16
start_facilities = 2
monthly_maintenance = 2000
expansion_cost = 50000

[[base_size]]
id = "medium"
name = "Military Base"
grid_width = 5
grid_height = 5
total_capacity = 25
start_facilities = 3
monthly_maintenance = 4000
expansion_cost = 75000

[[base_size]]
id = "large"
name = "Command Center"
grid_width = 6
grid_height = 6
total_capacity = 36
start_facilities = 4
monthly_maintenance = 6000
expansion_cost = 100000

[[base_size]]
id = "massive"
name = "Strategic Fortress"
grid_width = 7
grid_height = 7
total_capacity = 49
start_facilities = 5
monthly_maintenance = 8000
expansion_cost = 150000
```

### basescape/facility_types.toml

```toml
[[facility]]
id = "power_plant"
name = "Power Plant"
grid_width = 2
grid_height = 2
power_output = 100
worker_capacity = 5
maintenance_cost = 1000
build_cost = 50000
build_time_days = 30

[[facility]]
id = "barracks"
name = "Barracks"
grid_width = 3
grid_height = 2
unit_capacity = 20
worker_capacity = 3
maintenance_cost = 800
build_cost = 40000
build_time_days = 25

[[facility]]
id = "laboratory"
name = "Research Laboratory"
grid_width = 2
grid_height = 3
research_bonus = 50
worker_capacity = 10
maintenance_cost = 2000
build_cost = 100000
build_time_days = 45

[[facility]]
id = "workshop"
name = "Manufacturing Workshop"
grid_width = 3
grid_height = 3
production_speed = 100
worker_capacity = 15
maintenance_cost = 1500
build_cost = 75000
build_time_days = 35

[[facility]]
id = "storage"
name = "Storage Facility"
grid_width = 2
grid_height = 2
storage_capacity = 5000
worker_capacity = 2
maintenance_cost = 500
build_cost = 30000
build_time_days = 20
```

### basescape/grid_rules.toml

```toml
[grid_system]
type = "orthogonal_square"  # Square grid, not hex
cell_size_pixels = 24
grid_ui_padding = 12

[adjacency]
required = true  # All facilities must connect
connection_type = "orthogonal"  # Up, down, left, right

[construction]
requires_power = true
power_connection_distance = 2  # Cells
adjacency_bonus = 1.1  # 10% efficiency bonus per adjacent facility
```

---

## Units TOML

### units/unit_classes.toml

```toml
[[unit_class]]
id = "soldier"
name = "Soldier"
base_health = 100
base_strength = 10
base_accuracy = 75
base_will = 50
base_reactions = 5
stat_bonus_strength = 0
stat_bonus_accuracy = 0
stat_bonus_will = 0
armor_bonus = 0
recruitment_cost = 5000

[[unit_class]]
id = "medic"
name = "Combat Medic"
base_health = 90
base_strength = 8
base_accuracy = 70
base_will = 60
base_reactions = 4
stat_bonus_strength = 0
stat_bonus_accuracy = 0
stat_bonus_will = 10  # 10% will bonus
armor_bonus = 0
recruitment_cost = 7000

[[unit_class]]
id = "assault"
name = "Assault Specialist"
base_health = 110
base_strength = 12
base_accuracy = 70
base_will = 45
base_reactions = 6
stat_bonus_strength = 20  # 20% strength bonus
stat_bonus_accuracy = -5
stat_bonus_will = 0
armor_bonus = 10
recruitment_cost = 8000
```

### units/traits.toml

```toml
[[trait]]
id = "smart"
name = "Smart"
stat_modifier_accuracy = 20  # +20% accuracy
stat_modifier_will = 10
resource_boost = "research"  # +research when unit researches
rarity = "common"

[[trait]]
id = "brave"
name = "Brave"
stat_modifier_will = 30  # +30% will
stat_modifier_accuracy = 0
morale_resistance = 0.8  # 20% resistance to morale loss
rarity = "uncommon"

[[trait]]
id = "weak"
name = "Weak"
stat_modifier_strength = -20  # -20% strength
stat_modifier_health = -10
rarity = "rare"

[[trait]]
id = "sharpshooter"
name = "Sharpshooter"
stat_modifier_accuracy = 35
weapon_damage_bonus = 1.2  # 20% damage bonus
rarity = "rare"
```

### units/experience_progression.toml

```toml
[[rank]]
id = 0
name = "Conscript"
experience_required = 0
promotion_bonus_strength = 0
promotion_bonus_accuracy = 0
promotion_bonus_will = 0
new_traits_available = 1

[[rank]]
id = 1
name = "Rookie"
experience_required = 100
promotion_bonus_strength = 5
promotion_bonus_accuracy = 5
promotion_bonus_will = 3
new_traits_available = 1

[[rank]]
id = 2
name = "Veteran"
experience_required = 300
promotion_bonus_strength = 10
promotion_bonus_accuracy = 10
promotion_bonus_will = 5
new_traits_available = 2

[[rank]]
id = 3
name = "Commando"
experience_required = 600
promotion_bonus_strength = 15
promotion_bonus_accuracy = 15
promotion_bonus_will = 10
new_traits_available = 2

[[rank]]
id = 4
name = "Elite"
experience_required = 1000
promotion_bonus_strength = 20
promotion_bonus_accuracy = 20
promotion_bonus_will = 15
new_traits_available = 3

[[rank]]
id = 5
name = "Legend"
experience_required = 1500
promotion_bonus_strength = 25
promotion_bonus_accuracy = 25
promotion_bonus_will = 20
new_traits_available = 3

[[rank]]
id = 6
name = "Hero"
experience_required = 2100
promotion_bonus_strength = 30
promotion_bonus_accuracy = 30
promotion_bonus_will = 25
new_traits_available = 4
```

### units/squad_rules.toml

```toml
[squad_composition]
max_squad_size = 12
pyramid_structure = true  # Rank N requires 3× Rank N-1

[promotion]
max_heroes_per_squad = 1
one_hero_across_all_squads = false

[equipment]
slots_per_unit = 3
shared_inventory_access = true
```

---

## Battlescape TOML

### battlescape/battle_settings.toml

```toml
[action_economy]
action_points_per_turn = 4
reserve_action_cost = 1
move_ap_cost = 1
attack_ap_cost = 2

[time]
turn_time_limit_seconds = 30  # Timeout
reinforcement_delay_turns = 3

[difficulty_scaling]
easy_squad_multiplier = 0.75
normal_squad_multiplier = 1.0
hard_squad_multiplier = 1.2
impossible_squad_multiplier = 1.5

# AI adjustments
easy_ai_accuracy = 0.5
hard_ai_accuracy = 1.5
impossible_ai_accuracy = 2.0
```

### battlescape/map_generation.toml

```toml
[[biome_template]]
id = "desert"
name = "Desert"
terrain_types = ["sand", "rocks", "dunes"]
hazards = ["sandstorm"]
cover_density = 0.3
building_count = 2

[[biome_template]]
id = "forest"
name = "Forest"
terrain_types = ["grass", "trees", "water"]
hazards = ["fog"]
cover_density = 0.7
building_count = 1

[[biome_template]]
id = "urban"
name = "Urban City"
terrain_types = ["concrete", "buildings", "streets"]
hazards = ["traffic"]
cover_density = 0.8
building_count = 5
```

### battlescape/hex_grid.toml

```toml
[coordinate_system]
type = "axial"  # Q-R coordinate system
hex_size_pixels = 24
hex_orientation = "pointy_top"

[map_dimensions]
default_width = 20  # Hexes
default_height = 15
max_visibility_range = 8  # Hexes

[movement]
base_movement_range = 6  # Hexes
terrain_costs = [
  {terrain = "grass", cost = 1},
  {terrain = "rough", cost = 2},
  {terrain = "water", cost = 3},
  {terrain = "forest", cost = 2},
]

[vision]
line_of_sight_enabled = true
fog_of_war = true
cover_types = ["low", "high"]
low_cover_defense_bonus = 1.2
high_cover_defense_bonus = 1.5
```

---

## Economy TOML

### economy/market_prices.toml

```toml
[[market_item]]
id = "plasma_rifle"
name = "Plasma Rifle"
base_price = 15000
buy_price = 15000
sell_price = 10000
stock = 5

[[market_item]]
id = "alien_alloy"
name = "Alien Alloy"
base_price = 5000
buy_price = 5000
sell_price = 3000
stock = 20

[[market_item]]
id = "elerium"
name = "Elerium-115"
base_price = 20000
buy_price = 20000
sell_price = 15000
stock = 3
```

### economy/trade_partners.toml

```toml
[[trader]]
id = "legitimate_supplier"
name = "NEXUS Industries"
type = "legitimate"
reputation = 0.8
inventory_items = ["plasma_rifle", "ammunition"]
sell_prices_modifier = 1.0
buy_prices_modifier = 1.2  # They pay less

[[trader]]
id = "black_market"
name = "Shadow Network"
type = "black_market"
reputation = 0.3
inventory_items = ["alien_tech", "restricted_weapons"]
sell_prices_modifier = 1.5  # More expensive
buy_prices_modifier = 0.5  # Much less
danger_level = "high"
```

---

## Research TOML

### research/tech_tree.toml

```toml
[[technology]]
id = "plasma_weaponry"
name = "Plasma Weapon Technology"
tier = 2  # 1-5
research_cost = 5000
research_time_days = 30
prerequisites = ["basic_ballistics"]
unlocks_items = ["plasma_rifle", "plasma_cannon"]
unlocks_facilities = ["plasma_lab"]

[[technology]]
id = "exo_suit_armor"
name = "Exoskeleton Armor"
tier = 3
research_cost = 8000
research_time_days = 45
prerequisites = ["advanced_materials", "armor_research"]
unlocks_items = ["exo_suit"]
stat_modifiers = {armor_bonus = 50}

[[technology]]
id = "alien_biology"
name = "Alien Biology"
tier = 4
research_cost = 12000
research_time_days = 60
prerequisites = ["advanced_genetics"]
unlocks_items = ["alien_armor", "alien_weapons"]
```

### research/manufacturing_recipes.toml

```toml
[[recipe]]
id = "plasma_rifle_manufacture"
tech_required = "plasma_weaponry"
output_item = "plasma_rifle"
output_quantity = 1
input_materials = [
  {item = "alien_alloy", quantity = 3},
  {item = "elerium", quantity = 1},
]
build_time_hours = 12
production_cost = 2000

[[recipe]]
id = "ammunition_standard"
tech_required = "basic_ballistics"
output_item = "ammunition_standard"
output_quantity = 100
input_materials = [
  {item = "metal", quantity = 2},
  {item = "gunpowder", quantity = 1},
]
build_time_hours = 2
production_cost = 500
```

---

## AI Systems TOML

### ai/strategies.toml

```toml
[[strategy]]
id = "aggressive_assault"
name = "Aggressive Assault"
description = "Direct engagement, prioritize closest enemies"
priority_target = "closest"
movement_aggressiveness = 0.9
retreat_threshold = 0.2  # Retreat at 20% health
use_cover = false
reinforcement_priority = "weapons"

[[strategy]]
id = "defensive_position"
name = "Defensive Position"
description = "Hold ground, use cover, retreat slowly"
priority_target = "highest_threat"
movement_aggressiveness = 0.3
retreat_threshold = 0.5
use_cover = true
reinforcement_priority = "armor"

[[strategy]]
id = "infiltration"
name = "Infiltration & Surprise"
description = "Flank, ambush, avoid direct engagement"
priority_target = "isolated_units"
movement_aggressiveness = 0.5
retreat_threshold = 0.3
use_cover = true
use_stealth = true
reinforcement_priority = "mobility"
```

### ai/difficulty_modifiers.toml

```toml
[[difficulty]]
level = "easy"
name = "Easy"
squad_size_multiplier = 0.75
ai_accuracy_multiplier = 0.75
ai_damage_multiplier = 0.75
ai_health_multiplier = 0.75
reinforcement_waves = 0
morale_impact = 0.5

[[difficulty]]
level = "normal"
name = "Normal"
squad_size_multiplier = 1.0
ai_accuracy_multiplier = 1.0
ai_damage_multiplier = 1.0
ai_health_multiplier = 1.0
reinforcement_waves = 1
morale_impact = 1.0

[[difficulty]]
level = "hard"
name = "Hard"
squad_size_multiplier = 1.2
ai_accuracy_multiplier = 1.2
ai_damage_multiplier = 1.2
ai_health_multiplier = 1.2
reinforcement_waves = 2
morale_impact = 1.5

[[difficulty]]
level = "impossible"
name = "Impossible"
squad_size_multiplier = 1.5
ai_accuracy_multiplier = 1.5
ai_damage_multiplier = 1.5
ai_health_multiplier = 1.5
reinforcement_waves = 3
morale_impact = 2.0
```

---

## Items TOML

### items/equipment_definitions.toml

```toml
[[item]]
id = "rifle_standard"
name = "Standard Rifle"
type = "weapon"
damage = 30
range = 20
accuracy_bonus = 0
weight = 5
max_stack = 1
durability_max = 100
craft_recipe = "rifle_manufacture"
cost = 3000

[[item]]
id = "armor_combat"
name = "Combat Armor"
type = "armor"
armor_value = 20
weight = 10
max_stack = 1
durability_max = 200
craft_recipe = "armor_manufacture"
cost = 5000
```

---

## Politics TOML

### politics/countries.toml

```toml
[[country]]
id = "united_states"
name = "United States"
funding_monthly_base = 25000
support_initial = 50
threat_tolerance = 0.3
mission_preference = "balanced"
factions = ["militarist", "pragmatist"]

[[country]]
id = "china"
name = "China"
funding_monthly_base = 22000
support_initial = 40
threat_tolerance = 0.4
mission_preference = "strategic"
factions = ["communist", "pragmatist"]
```

---

**Version:** 2.0  
**Last Updated:** October 22, 2025  
**Total Schemas:** 50+  
**Coverage:** All 16 API document TOML configurations

````
