-- Sample Mission: Alien Harvesting
-- Aliens conducting mass abductions - stop them and protect civilians

local MissionTemplate = {
  id = "alien_harvesting",
  name = "Alien Harvesting Operation",
  description = "Intelligence reports massive UFO activity over civilian population centers. Aliens are conducting organized abductions. Intercept and eliminate the threat.",

  -- Mission type/category
  type = "combat",

  -- Difficulty level (1-10)
  difficulty = 3,

  -- Combat objectives
  objectives = {
    "eliminate_aliens",      -- Primary: Kill all aliens
    "protect_civilians",     -- Secondary: Minimize civilian casualties
    "secure_artifacts",      -- Tertiary: Collect alien tech
  },

  -- Enemy composition
  enemy_count_range = {min = 8, max = 12},
  enemy_types = {"sectoid_soldier", "sectoid_elite", "muton_warrior"},

  -- Map properties
  map_type = "urban",
  map_size = "medium",

  -- Tactical benefits
  environment = {
    cover_density = 0.6,      -- 60% cover
    civilian_presence = true,
    destructible_objects = true,
  },

  -- Rewards
  rewards = {
    experience = 300,
    science = 200,
    money = 1500,
    artifacts = 2,
  },

  -- Prerequisites
  prerequisites = {
    faction_relations_min = -50,
    player_level_min = 1,
  },

  -- Spawn conditions
  probability = 0.15,  -- 15% chance per turn
  min_turns_between = 3,

  -- Mission modifiers
  modifiers = {
    increased_enemy_health = 1.0,      -- 1.0x = no change
    increased_enemy_damage = 0.9,
    civilian_casualty_penalty = 0.5,   -- Half mission rewards if civilians die
  },
}

return MissionTemplate
