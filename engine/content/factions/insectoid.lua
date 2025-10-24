-- Sample Alien Faction: Insectoid Collective
-- Hive mind creatures with coordinated tactics

local InsectoidFaction = {
  id = "insectoids",
  name = "Insectoid Collective",
  description = "Hive-minded extraterrestrial arthropods with coordinated colony behavior",
  color = {r = 0.2, g = 0.8, b = 0.2},

  -- Units in this faction
  units = {"insectoid_worker", "insectoid_soldier", "insectoid_queen"},

  -- Tech tree ID
  tech_tree = "insectoid_biotech",

  -- Diplomatic relations with other factions
  relations = {
    human = -70,        -- Very hostile
    sectoid = 20,       -- Allied
    reptilian = -40,    -- Enemies
    ethereal = 10,      -- Neutral
  },

  -- Faction traits affecting gameplay
  traits = {
    "hive_mind",           -- All units act in coordination
    "fast_reproduction",   -- Spawn aliens quickly
    "chemical_weapons",    -- Use toxins and acids
    "swarm_tactics",       -- Effective in groups
  },

  -- Stats
  stats = {
    aggression = 8,        -- 1-10 scale
    intelligence = 7,
    adaptability = 6,
    speed = 5,
  },

  -- Unit composition ratios
  unit_composition = {
    insectoid_worker = 0.4,   -- 40% workers
    insectoid_soldier = 0.5,  -- 50% soldiers
    insectoid_queen = 0.1,    -- 10% queens (squad leaders)
  },

  -- Starting resources on contact
  starting_resources = {
    science = 50,
    artifacts = 3,
  },
}

return InsectoidFaction
