-- Sample Campaign Events
-- 30 diverse events for campaign strategic depth

return {
    -- RESEARCH EVENTS (6)

    research_breakthrough = {
        id = "research_breakthrough",
        name = "Research Breakthrough",
        description = "Scientists have made a major discovery! A key technology has been unlocked.",
        type = "positive",
        category = "research",
        effects = {
            {type = "tech_unlock", tech_id = "plasma_weapons"},
            {type = "morale_boost", amount = 10}
        },
        trigger_conditions = {research_points_min = 1000},
        probability = 0.08,
        duration_turns = 5
    },

    equipment_malfunction = {
        id = "equipment_malfunction",
        name = "Equipment Malfunction",
        description = "A critical equipment failure has set back our research efforts.",
        type = "negative",
        category = "research",
        effects = {
            {type = "research_loss", amount = 300},
            {type = "morale_penalty", amount = -5}
        },
        trigger_conditions = {random_chance = 0.05},
        probability = 0.06,
        duration_turns = 3
    },

    espionage_discovered = {
        id = "espionage_discovered",
        name = "Espionage Discovered!",
        description = "We discovered enemy agents stealing our research! Security has been increased.",
        type = "negative",
        category = "research",
        effects = {
            {type = "research_loss", amount = 500},
            {type = "security_increased", multiplier = 1.2}
        },
        trigger_conditions = {research_points_min = 2000},
        probability = 0.04,
        duration_turns = 1
    },

    scientist_defection = {
        id = "scientist_defection",
        name = "Scientist Defection",
        description = "A key scientist has defected, reducing our research capacity.",
        type = "negative",
        category = "research",
        effects = {
            {type = "research_capacity_loss", amount = 20},
            {type = "morale_penalty", amount = -8}
        },
        trigger_conditions = {random_chance = 0.03},
        probability = 0.02,
        duration_turns = 10
    },

    technology_donation = {
        id = "technology_donation",
        name = "Technology Donation",
        description = "Allies have donated advanced technology to aid our research!",
        type = "positive",
        category = "research",
        effects = {
            {type = "research_points", amount = 600},
            {type = "tech_unlock", tech_id = "advanced_armor"}
        },
        trigger_conditions = {faction_relations_min = 50},
        probability = 0.05,
        duration_turns = 1
    },

    lab_explosion = {
        id = "lab_explosion",
        name = "Laboratory Explosion",
        description = "A terrible accident in the lab has destroyed research data and injured staff.",
        type = "negative",
        category = "research",
        effects = {
            {type = "research_loss", amount = 800},
            {type = "facility_damage", amount = 30},
            {type = "personnel_loss", amount = 5}
        },
        trigger_conditions = {random_chance = 0.02},
        probability = 0.01,
        duration_turns = 5
    },

    -- DIPLOMACY EVENTS (6)

    alliance_offer = {
        id = "alliance_offer",
        name = "Alliance Offer",
        description = "A foreign power has offered a military alliance. Our strength will increase.",
        type = "positive",
        category = "diplomacy",
        effects = {
            {type = "faction_relation_boost", faction = "ally", amount = 30},
            {type = "military_bonus", multiplier = 1.15}
        },
        trigger_conditions = {random_chance = 0.1},
        probability = 0.08,
        duration_turns = 20
    },

    trade_negotiation = {
        id = "trade_negotiation",
        name = "Trade Negotiation Success",
        description = "Trade negotiations have resulted in new economic partnerships.",
        type = "positive",
        category = "diplomacy",
        effects = {
            {type = "money", amount = 1000},
            {type = "faction_relation_boost", faction = "trader", amount = 20}
        },
        trigger_conditions = {random_chance = 0.08},
        probability = 0.10,
        duration_turns = 1
    },

    territory_dispute = {
        id = "territory_conflict",
        name = "Territory Dispute",
        description = "Tensions have escalated over territorial claims!",
        type = "negative",
        category = "diplomacy",
        effects = {
            {type = "faction_relation_penalty", faction = "rival", amount = -40},
            {type = "military_threat", amount = 20}
        },
        trigger_conditions = {random_chance = 0.06},
        probability = 0.06,
        duration_turns = 10
    },

    cultural_exchange = {
        id = "cultural_exchange",
        name = "Cultural Exchange",
        description = "A cultural exchange program has boosted morale across the nation.",
        type = "positive",
        category = "diplomacy",
        effects = {
            {type = "morale_boost", amount = 15},
            {type = "faction_relation_boost", faction = "culture_partner", amount = 25}
        },
        trigger_conditions = {random_chance = 0.07},
        probability = 0.07,
        duration_turns = 5
    },

    betrayal_discovered = {
        id = "betrayal_discovered",
        name = "Betrayal Discovered!",
        description = "An ally has betrayed us! Relations have deteriorated severely.",
        type = "negative",
        category = "diplomacy",
        effects = {
            {type = "faction_relation_penalty", faction = "betrayer", amount = -100},
            {type = "morale_penalty", amount = -20}
        },
        trigger_conditions = {random_chance = 0.03},
        probability = 0.02,
        duration_turns = 15
    },

    peace_treaty = {
        id = "peace_treaty",
        name = "Peace Treaty Signed",
        description = "A peace treaty has been signed, ending regional conflict.",
        type = "positive",
        category = "diplomacy",
        effects = {
            {type = "military_threat_reduction", amount = -30},
            {type = "faction_relation_boost", faction = "treaty_signer", amount = 40}
        },
        trigger_conditions = {random_chance = 0.04},
        probability = 0.04,
        duration_turns = 20
    },

    -- ECONOMY EVENTS (6)

    resource_discovery = {
        id = "resource_discovery",
        name = "Resource Discovery",
        description = "A major deposit of valuable resources has been discovered!",
        type = "positive",
        category = "economy",
        effects = {
            {type = "money", amount = 1500},
            {type = "resources", resource = "elerium", amount = 100}
        },
        trigger_conditions = {random_chance = 0.1},
        probability = 0.08,
        duration_turns = 1
    },

    economic_collapse = {
        id = "economic_collapse",
        name = "Economic Collapse",
        description = "Market crash! The economy has suffered a major setback.",
        type = "negative",
        category = "economy",
        effects = {
            {type = "money_loss", amount = 2000},
            {type = "morale_penalty", amount = -15}
        },
        trigger_conditions = {random_chance = 0.05},
        probability = 0.04,
        duration_turns = 5
    },

    trade_opportunity = {
        id = "trade_opportunity",
        name = "Trade Opportunity",
        description = "Collectors are paying premium prices for alien artifacts!",
        type = "positive",
        category = "economy",
        effects = {
            {type = "money", amount = 800},
            {type = "artifact_value_boost", multiplier = 1.3}
        },
        trigger_conditions = {artifacts_held_min = 5},
        probability = 0.09,
        duration_turns = 3
    },

    inflation_crisis = {
        id = "inflation_crisis",
        name = "Inflation Crisis",
        description = "Rising prices are straining the budget.",
        type = "negative",
        category = "economy",
        effects = {
            {type = "cost_multiplier", multiplier = 1.4},
            {type = "morale_penalty", amount = -10}
        },
        trigger_conditions = {random_chance = 0.06},
        probability = 0.05,
        duration_turns = 8
    },

    revolution_crisis = {
        id = "revolution_crisis",
        name = "Revolution",
        description = "Civil unrest is spiraling into revolution! Economic chaos ensues.",
        type = "negative",
        category = "economy",
        effects = {
            {type = "morale_penalty", amount = -25},
            {type = "money_loss", amount = 1000},
            {type = "production_halt", days = 5}
        },
        trigger_conditions = {morale_below = 20},
        probability = 0.02,
        duration_turns = 10
    },

    new_markets = {
        id = "new_markets",
        name = "New Markets Open",
        description = "New trading routes have opened up, expanding our market reach!",
        type = "positive",
        category = "economy",
        effects = {
            {type = "money", amount = 500},
            {type = "income_multiplier", multiplier = 1.25}
        },
        trigger_conditions = {random_chance = 0.07},
        probability = 0.06,
        duration_turns = 15
    },

    -- MILITARY EVENTS (6)

    ufo_sighting = {
        id = "ufo_sighting",
        name = "UFO Sighting",
        description = "Unidentified aircraft detected! A mission opportunity has appeared.",
        type = "opportunity",
        category = "military",
        effects = {
            {type = "mission_available", mission_type = "ufo_crash_recovery"}
        },
        trigger_conditions = {random_chance = 0.15},
        probability = 0.12,
        duration_turns = 1
    },

    alien_attack = {
        id = "alien_attack",
        name = "Alien Attack",
        description = "An alien task force has been detected heading toward our territory!",
        type = "threat",
        category = "military",
        effects = {
            {type = "military_threat", amount = 40},
            {type = "mission_forced", mission_type = "base_defense"}
        },
        trigger_conditions = {random_chance = 0.08},
        probability = 0.06,
        duration_turns = 3
    },

    desertion = {
        id = "desertion",
        name = "Soldier Desertion",
        description = "Soldiers have deserted due to low morale!",
        type = "negative",
        category = "military",
        effects = {
            {type = "personnel_loss", amount = 3},
            {type = "morale_penalty", amount = -8}
        },
        trigger_conditions = {morale_below = 30},
        probability = 0.04,
        duration_turns = 1
    },

    victory_celebration = {
        id = "victory_celebration",
        name = "Victory Celebration",
        description = "Recent victories have inspired the troops!",
        type = "positive",
        category = "military",
        effects = {
            {type = "morale_boost", amount = 20},
            {type = "combat_efficiency_bonus", multiplier = 1.15}
        },
        trigger_conditions = {recent_victories = 3},
        probability = 0.10,
        duration_turns = 7
    },

    soldier_infection = {
        id = "soldier_infection",
        name = "Soldier Infection Crisis",
        description = "Alien pathogen detected in soldiers! Medical emergency!",
        type = "crisis",
        category = "military",
        effects = {
            {type = "personnel_loss", amount = 5},
            {type = "morale_penalty", amount = -15},
            {type = "research_opportunity", tech = "medical_advancement"}
        },
        trigger_conditions = {random_chance = 0.03},
        probability = 0.02,
        duration_turns = 5
    },

    new_recruit = {
        id = "new_recruit",
        name = "New Recruit Arrives",
        description = "Fresh soldiers have arrived to bolster our forces!",
        type = "positive",
        category = "military",
        effects = {
            {type = "personnel_gain", amount = 3},
            {type = "morale_boost", amount = 5}
        },
        trigger_conditions = {random_chance = 0.12},
        probability = 0.11,
        duration_turns = 1
    },

    -- RANDOM/SUPERNATURAL EVENTS (6)

    mysterious_signal = {
        id = "mysterious_signal",
        name = "Mysterious Signal",
        description = "Scientists have detected a mysterious signal. Investigation is needed.",
        type = "mystery",
        category = "supernatural",
        effects = {
            {type = "mission_available", mission_type = "investigation"}
        },
        trigger_conditions = {random_chance = 0.08},
        probability = 0.07,
        duration_turns = 1
    },

    ancient_artifact = {
        id = "ancient_artifact",
        name = "Ancient Artifact Found",
        description = "An ancient alien artifact has been discovered!",
        type = "discovery",
        category = "supernatural",
        effects = {
            {type = "research_points", amount = 400},
            {type = "artifacts", amount = 1}
        },
        trigger_conditions = {random_chance = 0.06},
        probability = 0.06,
        duration_turns = 1
    },

    meteor_impact = {
        id = "meteor_impact",
        name = "Meteor Impact",
        description = "A meteor has struck an inhabited region!",
        type = "disaster",
        category = "supernatural",
        effects = {
            {type = "money_loss", amount = 500},
            {type = "civilian_casualties", amount = 100}
        },
        trigger_conditions = {random_chance = 0.04},
        probability = 0.03,
        duration_turns = 1
    },

    dimensional_rift = {
        id = "dimensional_rift",
        name = "Dimensional Rift",
        description = "A tear in space-time has appeared! Reality is unstable.",
        type = "anomaly",
        category = "supernatural",
        effects = {
            {type = "research_opportunity", tech = "dimensional_tech"},
            {type = "mission_available", mission_type = "portal_investigation"}
        },
        trigger_conditions = {random_chance = 0.02},
        probability = 0.01,
        duration_turns = 5
    },

    time_anomaly = {
        id = "time_anomaly",
        name = "Time Anomaly",
        description = "Time appears to be behaving strangely!",
        type = "anomaly",
        category = "supernatural",
        effects = {
            {type = "mission_delay_reschedule", days = 5},
            {type = "research_points", amount = 300}
        },
        trigger_conditions = {random_chance = 0.01},
        probability = 0.005,
        duration_turns = 3
    },

    first_contact = {
        id = "first_contact",
        name = "First Contact Event",
        description = "First contact with a new alien faction has occurred!",
        type = "contact",
        category = "supernatural",
        effects = {
            {type = "new_faction_appears", faction_type = "ethereal"},
            {type = "diplomatic_opportunity", faction = "ethereal"}
        },
        trigger_conditions = {random_chance = 0.01},
        probability = 0.005,
        duration_turns = 1
    }
}

