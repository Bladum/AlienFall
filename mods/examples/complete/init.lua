-- Complete Example Mod - Init Script
-- Demonstrates all modding capabilities of AlienFall

-- Module definition
local CompleteMod = {}

-- Mod metadata
CompleteMod.name = "Complete Example Mod"
CompleteMod.version = "1.0.0"
CompleteMod.id = "example_complete"

-- Track loaded content
CompleteMod.content = {
    weapons = {},
    armor = {},
    units = {},
    facilities = {},
    technologies = {},
    missions = {}
}

-- Initialize the mod
function CompleteMod:initialize()
    print("[" .. self.name .. "] Initializing...")
    
    -- Load custom weapons
    self:loadWeapons()
    
    -- Load custom armor
    self:loadArmor()
    
    -- Load custom unit classes
    self:loadUnits()
    
    -- Load custom facilities
    self:loadFacilities()
    
    -- Load custom technologies
    self:loadTechnologies()
    
    -- Load custom missions
    self:loadMissions()
    
    print("[" .. self.name .. "] Successfully loaded:")
    print("  - Weapons: " .. #self.content.weapons)
    print("  - Armor: " .. #self.content.armor)
    print("  - Units: " .. #self.content.units)
    print("  - Facilities: " .. #self.content.facilities)
    print("  - Technologies: " .. #self.content.technologies)
    print("  - Missions: " .. #self.content.missions)
end

-- Load weapons from weapons directory
function CompleteMod:loadWeapons()
    print("[" .. self.name .. "] Loading weapons...")
    
    -- Example: Plasma Rifle
    self.content.weapons[1] = {
        id = "example_plasma_rifle",
        name = "Plasma Rifle (Example)",
        description = "Advanced plasma weapon demonstrating custom weapon creation",
        type = "rifle",
        damage = 85,
        accuracy = 75,
        range = 30,
        ap_cost = 3,
        ep_cost = 15,
        fire_rate = 1,
        weight = 2.5,
        cost = 2500,
        technology_required = "example_plasma_tech",
        ammo_type = "plasma_cell",
        properties = {
            armor_piercing = true,
            heat_damage = true,
            splash_radius = 2
        }
    }
    
    -- Example: Plasma Pistol
    self.content.weapons[2] = {
        id = "example_plasma_pistol",
        name = "Plasma Pistol (Example)",
        description = "Compact plasma sidearm for close quarters",
        type = "pistol",
        damage = 55,
        accuracy = 80,
        range = 15,
        ap_cost = 2,
        ep_cost = 10,
        fire_rate = 2,
        weight = 1.2,
        cost = 1200,
        technology_required = "example_plasma_tech",
        ammo_type = "plasma_cell",
        properties = {
            armor_piercing = true
        }
    }
    
    -- Example: Plasma Launcher
    self.content.weapons[3] = {
        id = "example_plasma_launcher",
        name = "Plasma Launcher (Example)",
        description = "Heavy area-effect plasma weapon",
        type = "launcher",
        damage = 110,
        accuracy = 60,
        range = 25,
        ap_cost = 4,
        ep_cost = 20,
        fire_rate = 1,
        weight = 4.0,
        cost = 3500,
        technology_required = "example_plasma_tech",
        ammo_type = "plasma_cell",
        properties = {
            armor_piercing = true,
            heat_damage = true,
            splash_radius = 4,
            area_effect = true
        }
    }
end

-- Load armor
function CompleteMod:loadArmor()
    print("[" .. self.name .. "] Loading armor...")
    
    -- Example: Plasma Combat Armor
    self.content.armor[1] = {
        id = "example_plasma_armor",
        name = "Plasma Combat Armor (Example)",
        description = "Advanced armor with plasma-resistant properties",
        type = "powered",
        armor_class = 18,
        energy_class = 15,
        health_bonus = 20,
        weight = 3.5,
        cost = 2000,
        technology_required = "example_plasma_tech",
        properties = {
            heat_resistant = true,
            movement_penalty = 1,
            energy_cost_per_turn = 5,
            bonus_vs_plasma = 5
        }
    }
    
    -- Example: Plasma Suit (Light)
    self.content.armor[2] = {
        id = "example_plasma_suit_light",
        name = "Light Plasma Suit (Example)",
        description = "Lightweight plasma-resistant bodysuit",
        type = "suit",
        armor_class = 12,
        energy_class = 8,
        health_bonus = 10,
        weight = 1.8,
        cost = 1200,
        technology_required = "example_plasma_tech",
        properties = {
            heat_resistant = true,
            movement_penalty = 0,
            bonus_vs_plasma = 3
        }
    }
end

-- Load custom units/classes
function CompleteMod:loadUnits()
    print("[" .. self.name .. "] Loading units...")
    
    -- Example: Advanced Soldier Class
    self.content.units[1] = {
        id = "example_advanced_soldier",
        name = "Advanced Soldier (Example)",
        description = "Enhanced soldier class with plasma weapons training",
        faction = "xcom",
        base_health = 35,
        base_stats = {
            strength = 8,
            dexterity = 9,
            constitution = 8,
            intelligence = 7,
            wisdom = 7,
            charisma = 6
        },
        starting_equipment = {
            weapon = "example_plasma_rifle",
            armor = "example_plasma_armor",
            secondary = "example_plasma_pistol"
        },
        abilities = {
            "shoot",
            "plasma_burst",
            "tactical_advance"
        },
        traits = {
            "trained_soldier",
            "plasma_weapon_proficiency"
        },
        progression = {
            max_rank = 6,
            xp_per_rank = 200
        }
    }
    
    -- Example: Plasma Specialist
    self.content.units[2] = {
        id = "example_plasma_specialist",
        name = "Plasma Specialist (Example)",
        description = "Specialized unit trained in plasma weapons",
        faction = "xcom",
        base_health = 32,
        base_stats = {
            strength = 7,
            dexterity = 10,
            constitution = 7,
            intelligence = 9,
            wisdom = 8,
            charisma = 6
        },
        starting_equipment = {
            weapon = "example_plasma_rifle",
            armor = "example_plasma_suit_light",
            secondary = "example_plasma_pistol"
        },
        abilities = {
            "shoot",
            "rapid_fire",
            "plasma_mastery",
            "aimed_shot"
        },
        traits = {
            "plasma_expert",
            "steady_hand"
        },
        progression = {
            max_rank = 6,
            xp_per_rank = 250
        }
    }
    
    -- Store for reference
    self.content.units[3] = {
        id = "example_unit_1",
        class_id = "example_advanced_soldier",
        name = "CPL. Example Unit",
        faction = "xcom",
        rank = 2,
        experience = 500
    }
    
    self.content.units[4] = {
        id = "example_unit_2",
        class_id = "example_plasma_specialist",
        name = "SPC. Plasma Master",
        faction = "xcom",
        rank = 3,
        experience = 1200
    }
end

-- Load custom facilities
function CompleteMod:loadFacilities()
    print("[" .. self.name .. "] Loading facilities...")
    
    -- Example: Plasma Research Lab
    self.content.facilities[1] = {
        id = "example_plasma_lab",
        name = "Plasma Research Lab (Example)",
        description = "Specialized laboratory for plasma weapon research",
        category = "research",
        grid_width = 2,
        grid_height = 2,
        grid_x = 0,
        grid_y = 0,
        build_cost = 3500,
        build_time = 30,
        maintenance_cost = 500,
        maintenance_interval = 30,
        power_requirement = 50,
        staff_capacity = 8,
        properties = {
            research_bonus = 25,
            focus_technology = "plasma_weapons",
            unique = false
        },
        adjacency_bonuses = {
            {
                adjacent_facility = "workshop",
                bonus_type = "research",
                bonus_value = 10
            }
        }
    }
    
    -- Example: Plasma Manufacturing Facility
    self.content.facilities[2] = {
        id = "example_plasma_workshop",
        name = "Plasma Manufacturing (Example)",
        description = "Advanced workshop for manufacturing plasma weapons",
        category = "manufacturing",
        grid_width = 3,
        grid_height = 2,
        grid_x = 0,
        grid_y = 0,
        build_cost = 4000,
        build_time = 25,
        maintenance_cost = 600,
        maintenance_interval = 30,
        power_requirement = 60,
        staff_capacity = 12,
        properties = {
            manufacturing_speed = 30,
            focus_category = "plasma_weapons",
            unique = false
        },
        adjacency_bonuses = {
            {
                adjacent_facility = "example_plasma_lab",
                bonus_type = "manufacturing",
                bonus_value = 15
            }
        }
    }
    
    -- Example: Plasma Storage Vault
    self.content.facilities[3] = {
        id = "example_plasma_vault",
        name = "Plasma Storage Vault (Example)",
        description = "Secure storage for plasma weapons and ammunition",
        category = "storage",
        grid_width = 2,
        grid_height = 2,
        grid_x = 0,
        grid_y = 0,
        build_cost = 1500,
        build_time = 15,
        maintenance_cost = 200,
        maintenance_interval = 30,
        power_requirement = 30,
        staff_capacity = 4,
        properties = {
            storage_capacity = 500,
            focus_item = "plasma_cell",
            unique = false
        }
    }
end

-- Load custom technologies
function CompleteMod:loadTechnologies()
    print("[" .. self.name .. "] Loading technologies...")
    
    -- Example: Plasma Technology (Tier 1)
    self.content.technologies[1] = {
        id = "example_plasma_tech",
        name = "Plasma Weapons (Example)",
        description = "Alien plasma weapon technology reverse-engineered from captured specimens",
        technology_tier = 3,
        research_cost = 1500,
        research_time = 40,
        prerequisites = {},
        unlocks = {
            weapons = {
                "example_plasma_rifle",
                "example_plasma_pistol",
                "example_plasma_launcher"
            },
            armor = {
                "example_plasma_armor",
                "example_plasma_suit_light"
            },
            facilities = {
                "example_plasma_lab",
                "example_plasma_workshop"
            }
        },
        properties = {
            category = "weapons",
            difficulty = "hard",
            alien_tech = true
        }
    }
    
    -- Example: Advanced Plasma Theory (Tier 2)
    self.content.technologies[2] = {
        id = "example_plasma_advanced",
        name = "Advanced Plasma Theory (Example)",
        description = "Improved efficiency and damage characteristics of plasma weapons",
        technology_tier = 4,
        research_cost = 2000,
        research_time = 50,
        prerequisites = {
            "example_plasma_tech"
        },
        unlocks = {
            upgrades = {
                "plasma_efficiency",
                "plasma_power"
            }
        },
        properties = {
            category = "weapons",
            difficulty = "very_hard",
            alien_tech = true
        }
    }
end

-- Load custom missions
function CompleteMod:loadMissions()
    print("[" .. self.name .. "] Loading missions...")
    
    -- Example: Alien Research Facility Raid
    self.content.missions[1] = {
        id = "example_mission_alien_facility",
        name = "Alien Research Facility (Example)",
        description = "Raid an alien research facility to obtain plasma weapon prototypes",
        mission_type = "terror_site",
        location = "urban",
        difficulty = "challenging",
        objectives = {
            {
                id = "destroy_research",
                type = "destroy",
                target = "research_computer",
                required = true,
                reward = 500
            },
            {
                id = "recover_plasma",
                type = "recover",
                target = "plasma_prototype",
                required = false,
                reward = 750
            },
            {
                id = "eliminate_aliens",
                type = "kill_count",
                target = 10,
                required = false,
                reward = 300
            }
        },
        map_data = {
            width = 80,
            height = 60,
            terrain_type = "urban"
        },
        rewards = {
            experience = 500,
            research_points = 200,
            items = {
                "plasma_cell",
                "alien_alloy"
            }
        }
    }
end

-- Validate mod content
function CompleteMod:validate()
    print("[" .. self.name .. "] Validating content...")
    
    local valid = true
    
    -- Check weapons
    for _, weapon in ipairs(self.content.weapons) do
        if not weapon.id or not weapon.name or not weapon.damage then
            print("[ERROR] Invalid weapon: " .. tostring(weapon.id))
            valid = false
        end
    end
    
    -- Check units
    for _, unit in ipairs(self.content.units) do
        if not unit.id or not unit.name then
            print("[ERROR] Invalid unit: " .. tostring(unit.id))
            valid = false
        end
    end
    
    -- Check facilities
    for _, facility in ipairs(self.content.facilities) do
        if not facility.id or not facility.name or not facility.grid_width then
            print("[ERROR] Invalid facility: " .. tostring(facility.id))
            valid = false
        end
    end
    
    -- Check technologies
    for _, tech in ipairs(self.content.technologies) do
        if not tech.id or not tech.name or not tech.research_cost then
            print("[ERROR] Invalid technology: " .. tostring(tech.id))
            valid = false
        end
    end
    
    if valid then
        print("[" .. self.name .. "] Validation successful!")
    else
        print("[" .. self.name .. "] Validation failed!")
    end
    
    return valid
end

-- Get mod statistics
function CompleteMod:getStatistics()
    return {
        name = self.name,
        version = self.version,
        weapons = #self.content.weapons,
        armor = #self.content.armor,
        units = #self.content.units,
        facilities = #self.content.facilities,
        technologies = #self.content.technologies,
        missions = #self.content.missions,
        total_content = #self.content.weapons + #self.content.armor + 
                       #self.content.units + #self.content.facilities + 
                       #self.content.technologies + #self.content.missions
    }
end

-- Entry point
print("[Complete Example Mod] Loading...")
CompleteMod:initialize()
CompleteMod:validate()

return CompleteMod
