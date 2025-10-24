-- Sample Campaign Events

-- Event 1: Research Breakthrough
local ResearchBreakthrough = {
  id = "research_breakthrough",
  name = "Research Breakthrough",
  description = "Our scientists have achieved a major breakthrough in psionic research!",
  
  event_type = "positive",
  category = "research",
  
  effects = {
    {type = "tech_unlock", tech_id = "psionic_basics", value = 1},
    {type = "morale_boost", value = 10},
    {type = "science_points", value = 500},
  },
  
  trigger_conditions = {
    research_points_min = 1000,
    tech_researched = "plasma_weapons",
  },
  
  probability = 0.08,
  duration_turns = 0,   -- Instant effect
  
  lore_text = "After months of research, we've successfully replicated and enhanced the alien psionics technology. This opens new avenues for soldier enhancement.",
}

-- Event 2: Economic Crisis
local EconomicCrisis = {
  id = "economic_crisis",
  name = "Economic Crisis",
  description = "Global financial markets have collapsed. Funding is being slashed!",
  
  event_type = "negative",
  category = "economy",
  
  effects = {
    {type = "money_loss", value = 5000},
    {type = "morale_penalty", value = 20},
    {type = "building_halt", duration = 3},
  },
  
  trigger_conditions = {
    --  Triggered randomly
  },
  
  probability = 0.05,
  duration_turns = 5,
  
  lore_text = "Stock markets worldwide have crashed following UFO activity reports. Nations are cutting funding to XCOM initiatives to shore up domestic economies.",
}

-- Event 3: Alien Research Advancement
local AlienAdvance = {
  id = "alien_research_advance",
  name = "Alien Research Advancement",
  description = "Intercepted transmissions indicate alien forces are developing new weapons.",
  
  event_type = "negative",
  category = "military",
  
  effects = {
    {type = "enemy_tech_unlock", tech_id = "plasma_weapons"},
    {type = "increased_alien_damage", value = 0.15},
    {type = "mission_difficulty_increase", value = 1},
  },
  
  trigger_conditions = {
    player_technology_level = 3,
  },
  
  probability = 0.06,
  duration_turns = 0,
  
  lore_text = "Our monitoring stations have detected a surge in alien research activity. They're adapting to our weapons and developing countermeasures faster than we anticipated.",
}

return {
  ResearchBreakthrough,
  EconomicCrisis,
  AlienAdvance,
}
