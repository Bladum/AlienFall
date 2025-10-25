-- Sample Alien Factions
-- 6 new factions with distinct traits and gameplay characteristics

return {
    -- 1. Insectoid Collective (hive mind, numerous, weak individually)
    insectoids = {
        id = "insectoids",
        name = "Insectoid Collective",
        description = "A hive mind species with psychic coordination. Fast reproduction but weak individually.",
        alignment = "hostile",
        units = {
            "insectoid_worker",      -- Weak, numerous
            "insectoid_soldier",     -- Medium combat unit
            "insectoid_queen"        -- Strong leader unit
        },
        tech_tree = "insectoid_tech",
        traits = {
            "hive_mind",             -- Can coordinate attacks
            "fast_reproduction",     -- Reinforcements come faster
            "weak_individually"      -- Easy to kill 1v1
        },
        unit_variety = 2,           -- Only 2-3 unit types
        diplomacy_bonus = {
            sectoid = 20,            -- Aligned with Sectoids
            ethereal = -10
        },
        color = {r = 0.2, g = 0.8, b = 0.2},
        leader_unit = "insectoid_queen"
    },

    -- 2. Reptilian Empire (military, disciplined, adaptable)
    reptilians = {
        id = "reptilians",
        name = "Reptilian Empire",
        description = "A militaristic species with strict hierarchy. Disciplined and dangerous opponents.",
        alignment = "hostile",
        units = {
            "reptilian_warrior",     -- Standard soldier
            "reptilian_specialist",  -- Technical unit
            "reptilian_commander"    -- Leader unit
        },
        tech_tree = "reptilian_tech",
        traits = {
            "military_discipline",   -- Better tactics
            "thermal_adaptation",    -- Resist fire weapons
            "slow_but_strong"        -- Powerful but slow
        },
        unit_variety = 3,
        diplomacy_bonus = {
            cyborg = -50,            -- Oppose cyborgs
            ethereal = 0
        },
        color = {r = 0.8, g = 0.4, b = 0.2},
        leader_unit = "reptilian_commander"
    },

    -- 3. Arachnid Swarm (web-based, weak solo, deadly in groups)
    arachnids = {
        id = "arachnids",
        name = "Arachnid Swarm",
        description = "Spider-like aliens coordinating through neural links. Individually weak but devastating in numbers.",
        alignment = "hostile",
        units = {
            "arachnid_drone",        -- Scout/weak unit
            "arachnid_warrior",      -- Combat unit
            "arachnid_overseer"      -- Coordinator
        },
        tech_tree = "arachnid_tech",
        traits = {
            "web_coordination",      -- Coordinated attacks
            "weak_solo",             -- Poor 1v1 fighters
            "deadly_group",          -- Strong in groups
            "toxic_attack"           -- Poison damage
        },
        unit_variety = 3,
        diplomacy_bonus = {
            insectoid = 10,
            mutant = 0
        },
        color = {r = 0.6, g = 0.2, b = 0.6},
        leader_unit = "arachnid_overseer"
    },

    -- 4. Cybernetic Union (technological, upgrading, limited reproduction)
    cyborg = {
        id = "cyborg",
        name = "Cybernetic Union",
        description = "Half-organic, half-machine beings. Constantly upgrading and adapting technology.",
        alignment = "hostile",
        units = {
            "cyborg_soldier",        -- Standard combat unit
            "cyborg_assassin",       -- Stealth/precision unit
            "cyborg_nexus"           -- Central intelligence
        },
        tech_tree = "cyborg_tech",
        traits = {
            "technological",         -- Better equipment
            "constant_upgrade",      -- Improves over campaign
            "limited_reproduction",  -- Can't produce many
            "hacking_capable"        -- Can disable systems
        },
        unit_variety = 3,
        diplomacy_bonus = {
            reptilian = -50,         -- Opposed to organic life
            ethereal = 20
        },
        color = {r = 0.4, g = 0.4, b = 0.8},
        leader_unit = "cyborg_nexus"
    },

    -- 5. Ethereal Collective (psychic, ancient, unpredictable)
    ethereal = {
        id = "ethereal",
        name = "Ethereal Collective",
        description = "Ancient psychic beings with interdimensional technology. Rare and mysterious.",
        alignment = "enigmatic",
        units = {
            "ethereal_priest",       -- Psychic support
            "ethereal_warrior",      -- Combat unit
            "ethereal_avatar"        -- Powerful leader
        },
        tech_tree = "ethereal_tech",
        traits = {
            "psychic_powers",        -- Telepathy, mind control
            "ancient_knowledge",     -- Advanced technology
            "rare_appearance",       -- Infrequent missions
            "dimensional_tech"       -- Teleportation
        },
        unit_variety = 2,           -- Rare variety
        diplomacy_bonus = {
            cyborg = 20,
            mutant = -20
        },
        color = {r = 0.8, g = 0.2, b = 0.8},
        leader_unit = "ethereal_avatar"
    },

    -- 6. Mutant Horde (bio-engineered, diverse, unpredictable)
    mutant = {
        id = "mutant",
        name = "Mutant Horde",
        description = "Bio-engineered creatures with diverse abilities. Unpredictable and evolving.",
        alignment = "chaotic",
        units = {
            "mutant_warrior",        -- Variable type
            "mutant_beast",          -- Physical attacker
            "mutant_overseer"        -- Leader
        },
        tech_tree = "mutant_tech",
        traits = {
            "genetic_diversity",     -- Many unit variants
            "unpredictable",         -- Random mutations
            "evolving",              -- Adapt to threats
            "bio_weapons"            -- Biological attacks
        },
        unit_variety = 4,           -- Most variety
        diplomacy_bonus = {
            insectoid = 0,
            arachnid = 10
        },
        color = {r = 0.8, g = 0.6, b = 0.2},
        leader_unit = "mutant_overseer"
    }
}

