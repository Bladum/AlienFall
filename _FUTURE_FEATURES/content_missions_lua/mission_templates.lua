-- Sample Mission Templates
-- 20 diverse mission types for campaign variation

return {
    -- COMBAT-FOCUSED MISSIONS (8 types)

    alien_invasion = {
        id = "alien_invasion",
        name = "Alien Invasion",
        description = "Aliens are attacking a populated area. Defend against the invasion.",
        category = "combat",
        objectives = {
            {type = "protect_civilians", description = "Protect civilians from harm", target_count = 5},
            {type = "eliminate_aliens", description = "Eliminate all alien forces", target_count = 0}
        },
        difficulty = 5,
        enemy_count_range = {8, 12},
        faction_id = "aliens",
        rewards = {science = 300, money = 500, artifacts = 2},
        probability = 0.15
    },

    base_defense = {
        id = "base_defense",
        name = "Base Defense",
        description = "Our base is under attack! Defend the facilities and repel the invasion.",
        category = "combat",
        objectives = {
            {type = "defend_base", description = "Defend the main base facility", target_count = 1},
            {type = "eliminate_aliens", description = "Eliminate all attackers", target_count = 0}
        },
        difficulty = 6,
        enemy_count_range = {10, 15},
        faction_id = "aliens",
        rewards = {science = 250, money = 400, artifacts = 1},
        probability = 0.12
    },

    rescue_operation = {
        id = "rescue_operation",
        name = "Rescue Operation",
        description = "Soldiers are trapped behind enemy lines. Extract them before it's too late.",
        category = "combat",
        objectives = {
            {type = "rescue_team", description = "Extract the rescue team safely", target_count = 1},
            {type = "eliminate_aliens", description = "Clear a path for extraction", target_count = 0}
        },
        difficulty = 4,
        enemy_count_range = {6, 10},
        faction_id = "aliens",
        rewards = {science = 200, money = 300, artifacts = 0},
        probability = 0.1
    },

    artifact_recovery = {
        id = "artifact_recovery",
        name = "Artifact Recovery",
        description = "Recover alien technology from the crash site before aliens do.",
        category = "combat",
        objectives = {
            {type = "collect_artifact", description = "Recover the alien artifact", target_count = 1},
            {type = "extract", description = "Extract with the artifact", target_count = 1}
        },
        difficulty = 5,
        enemy_count_range = {8, 12},
        faction_id = "aliens",
        rewards = {science = 500, money = 300, artifacts = 3},
        probability = 0.08
    },

    alien_harvesting = {
        id = "alien_harvesting",
        name = "Alien Harvesting",
        description = "Aliens are conducting mass abductions. Stop the harvesting operation.",
        category = "combat",
        objectives = {
            {type = "protect_civilians", description = "Protect remaining civilians", target_count = 10},
            {type = "destroy_harvester", description = "Destroy the harvesting device", target_count = 1}
        },
        difficulty = 6,
        enemy_count_range = {10, 14},
        faction_id = "aliens",
        rewards = {science = 350, money = 400, artifacts = 2},
        probability = 0.11
    },

    ufo_crash_recovery = {
        id = "ufo_crash_recovery",
        name = "UFO Crash Recovery",
        description = "Alien craft has crashed. Salvage the wreckage before enemies secure it.",
        category = "combat",
        objectives = {
            {type = "collect_salvage", description = "Collect UFO components", target_count = 5},
            {type = "eliminate_aliens", description = "Secure the crash site", target_count = 0}
        },
        difficulty = 5,
        enemy_count_range = {6, 10},
        faction_id = "aliens",
        rewards = {science = 600, money = 800, artifacts = 4},
        probability = 0.07
    },

    assassination = {
        id = "assassination",
        name = "Assassination Target",
        description = "A high-value alien commander has been spotted. Eliminate it.",
        category = "combat",
        objectives = {
            {type = "kill_target", description = "Eliminate the alien commander", target_count = 1},
            {type = "extract", description = "Extract safely", target_count = 1}
        },
        difficulty = 7,
        enemy_count_range = {8, 12},
        faction_id = "aliens",
        rewards = {science = 400, money = 600, artifacts = 2},
        probability = 0.09
    },

    territory_dispute = {
        id = "territory_dispute",
        name = "Territory Dispute",
        description = "Control key strategic positions against alien forces.",
        category = "combat",
        objectives = {
            {type = "control_points", description = "Control map control points", target_count = 3},
            {type = "hold_time", description = "Hold for 5 turns", target_count = 5}
        },
        difficulty = 4,
        enemy_count_range = {10, 12},
        faction_id = "aliens",
        rewards = {science = 200, money = 400, artifacts = 1},
        probability = 0.09
    },

    -- EXPLORATION/INVESTIGATION MISSIONS (6 types)

    archaeological_dig = {
        id = "archaeological_dig",
        name = "Archaeological Dig",
        description = "Investigate an ancient site for alien artifacts and technology.",
        category = "exploration",
        objectives = {
            {type = "explore_area", description = "Explore the ancient site", target_count = 1},
            {type = "collect_samples", description = "Collect artifact samples", target_count = 5}
        },
        difficulty = 3,
        enemy_count_range = {4, 8},
        faction_id = "none",
        rewards = {science = 400, money = 200, artifacts = 5},
        probability = 0.08
    },

    research_facility_breach = {
        id = "research_facility_breach",
        name = "Research Facility Breach",
        description = "Secure an alien research facility and gather data.",
        category = "exploration",
        objectives = {
            {type = "breach_facility", description = "Breach the outer defense", target_count = 1},
            {type = "recover_data", description = "Recover alien data", target_count = 1}
        },
        difficulty = 5,
        enemy_count_range = {8, 12},
        faction_id = "none",
        rewards = {science = 700, money = 300, artifacts = 3},
        probability = 0.07
    },

    alien_colony = {
        id = "alien_colony",
        name = "Alien Colony Discovery",
        description = "Find and investigate a hidden alien colony.",
        category = "exploration",
        objectives = {
            {type = "locate_colony", description = "Find the alien colony", target_count = 1},
            {type = "gather_intel", description = "Gather intelligence on colony", target_count = 1}
        },
        difficulty = 6,
        enemy_count_range = {12, 15},
        faction_id = "none",
        rewards = {science = 600, money = 400, artifacts = 4},
        probability = 0.06
    },

    portal_investigation = {
        id = "portal_investigation",
        name = "Portal Investigation",
        description = "Study an alien dimensional portal for technology insights.",
        category = "exploration",
        objectives = {
            {type = "study_portal", description = "Analyze portal technology", target_count = 1},
            {type = "survive", description = "Survive dimensional anomalies", target_count = 1}
        },
        difficulty = 7,
        enemy_count_range = {6, 10},
        faction_id = "none",
        rewards = {science = 800, money = 200, artifacts = 2},
        probability = 0.05
    },

    derelict_exploration = {
        id = "derelict_exploration",
        name = "Derelict Exploration",
        description = "Explore an abandoned alien ship for salvage and data.",
        category = "exploration",
        objectives = {
            {type = "explore_ship", description = "Explore the derelict ship", target_count = 1},
            {type = "salvage", description = "Salvage components", target_count = 5}
        },
        difficulty = 5,
        enemy_count_range = {4, 8},
        faction_id = "none",
        rewards = {science = 500, money = 600, artifacts = 4},
        probability = 0.06
    },

    genetic_vault = {
        id = "genetic_vault",
        name = "Genetic Vault Infiltration",
        description = "Infiltrate an alien genetic vault and capture research samples.",
        category = "exploration",
        objectives = {
            {type = "infiltrate", description = "Bypass security", target_count = 1},
            {type = "capture_samples", description = "Capture genetic samples", target_count = 5}
        },
        difficulty = 6,
        enemy_count_range = {10, 12},
        faction_id = "none",
        rewards = {science = 700, money = 300, artifacts = 3},
        probability = 0.05
    },

    -- OBJECTIVE-FOCUSED MISSIONS (6 types)

    bomb_defusal = {
        id = "bomb_defusal",
        name = "Bomb Defusal",
        description = "Find and disarm an alien explosive device before it detonates.",
        category = "objective",
        objectives = {
            {type = "locate_bomb", description = "Find the explosive device", target_count = 1},
            {type = "defuse", description = "Defuse the bomb", target_count = 1}
        },
        difficulty = 5,
        enemy_count_range = {6, 10},
        faction_id = "aliens",
        rewards = {science = 200, money = 400, artifacts = 0},
        probability = 0.08
    },

    hostage_rescue = {
        id = "hostage_rescue",
        name = "Hostage Rescue",
        description = "Rescue hostages held by alien forces.",
        category = "objective",
        objectives = {
            {type = "locate_hostages", description = "Find the hostages", target_count = 1},
            {type = "extract_hostages", description = "Extract hostages safely", target_count = 5}
        },
        difficulty = 4,
        enemy_count_range = {8, 12},
        faction_id = "aliens",
        rewards = {science = 150, money = 350, artifacts = 0},
        probability = 0.09
    },

    vip_extraction = {
        id = "vip_extraction",
        name = "VIP Extraction",
        description = "Extract an important VIP from enemy territory safely.",
        category = "objective",
        objectives = {
            {type = "locate_vip", description = "Locate the VIP", target_count = 1},
            {type = "extract", description = "Extract to safety", target_count = 1}
        },
        difficulty = 5,
        enemy_count_range = {10, 14},
        faction_id = "aliens",
        rewards = {science = 250, money = 500, artifacts = 1},
        probability = 0.07
    },

    data_theft = {
        id = "data_theft",
        name = "Data Theft",
        description = "Infiltrate and steal alien database information.",
        category = "objective",
        objectives = {
            {type = "infiltrate", description = "Bypass security", target_count = 1},
            {type = "steal_data", description = "Steal alien data", target_count = 1}
        },
        difficulty = 5,
        enemy_count_range = {8, 12},
        faction_id = "none",
        rewards = {science = 400, money = 300, artifacts = 1},
        probability = 0.06
    },

    targeted_sabotage = {
        id = "targeted_sabotage",
        name = "Targeted Sabotage",
        description = "Destroy alien installations and infrastructure.",
        category = "objective",
        objectives = {
            {type = "locate_target", description = "Locate the target facility", target_count = 1},
            {type = "sabotage", description = "Sabotage the installation", target_count = 1}
        },
        difficulty = 6,
        enemy_count_range = {10, 14},
        faction_id = "aliens",
        rewards = {science = 250, money = 400, artifacts = 1},
        probability = 0.07
    },

    supply_cache = {
        id = "supply_cache",
        name = "Supply Cache Acquisition",
        description = "Locate and acquire alien supply caches.",
        category = "objective",
        objectives = {
            {type = "find_cache", description = "Find the supply cache", target_count = 1},
            {type = "secure_cache", description = "Secure the supplies", target_count = 1}
        },
        difficulty = 4,
        enemy_count_range = {6, 10},
        faction_id = "aliens",
        rewards = {science = 200, money = 600, artifacts = 2},
        probability = 0.08
    }
}

