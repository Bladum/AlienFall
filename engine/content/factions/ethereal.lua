-- Sample Alien Faction: Ethereal Collective
-- Ancient psychic beings with superior intellect

local EtherealFaction = {
  id = "ethereal",
  name = "Ethereal Collective",
  description = "Ancient alien consciousness with psionic powers and interdimensional technology",
  color = {r = 0.8, g = 0.2, b = 0.8},
  
  -- Units in this faction
  units = {"ethereal_priest", "ethereal_warrior", "ethereal_avatar"},
  
  -- Tech tree ID
  tech_tree = "ethereal_psionics",
  
  -- Diplomatic relations
  relations = {
    human = -50,        -- Hostile but studious
    sectoid = 30,       -- Somewhat allied
    insectoid = 10,     -- Neutral
    reptilian = -20,    -- Wary rivals
  },
  
  -- Faction traits
  traits = {
    "psychic_powers",      -- Psionic abilities
    "ancient_knowledge",   -- Superior tech
    "rare_appearances",    -- Appear infrequently
    "mysterious",          -- Unpredictable motives
  },
  
  -- Stats
  stats = {
    aggression = 4,
    intelligence = 10,     -- Maximum intelligence
    adaptability = 8,
    speed = 7,
  },
  
  -- Unit composition
  unit_composition = {
    ethereal_priest = 0.4,    -- Psion casters
    ethereal_warrior = 0.3,   -- Physical fighters
    ethereal_avatar = 0.3,    -- Elite leaders
  },
  
  -- Starting resources
  starting_resources = {
    science = 150,
    artifacts = 8,
  },
}

return EtherealFaction
