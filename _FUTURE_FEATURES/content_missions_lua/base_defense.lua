-- Sample Mission: Base Defense
-- Aliens have located one of our bases and are attacking

local MissionTemplate = {
  id = "base_defense",
  name = "Base Defense",
  description = "CRITICAL ALERT: Alien strike force detected approaching our base. All units to defensive positions immediately!",

  type = "combat",
  difficulty = 4,

  objectives = {
    "defend_base",            -- Survive alien assault
    "minimize_damage",        -- Keep base intact
    "eliminate_threat",       -- Kill all attackers
  },

  enemy_count_range = {min = 12, max = 16},
  enemy_types = {"sectoid_elite", "muton_warrior", "muton_berserker"},

  map_type = "base_interior",
  map_size = "large",

  environment = {
    cover_density = 0.7,
    civilian_presence = true,      -- Scientists and staff in base
    destructible_objects = true,   -- Base facilities
    base_defenses = true,          -- Automated turrets, doors
  },

  rewards = {
    experience = 500,
    science = 300,
    money = 2000,
    artifacts = 3,
  },

  prerequisites = {
    player_level_min = 3,
    base_exists = true,
  },

  probability = 0.08,
  min_turns_between = 5,

  modifiers = {
    increased_enemy_health = 1.1,
    increased_enemy_damage = 1.2,
    base_damage_multiplier = 0.8,   -- Base can take some hits
    facility_destruction_penalty = 0.3,  -- Penalty for destroyed facilities
  },
}

return MissionTemplate

