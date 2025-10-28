-- Minimal Example Mod - Init Script
-- Demonstrates the simplest possible mod for AlienFall

local MinimalMod = {}

MinimalMod.name = "Minimal Example Mod"
MinimalMod.version = "1.0.0"
MinimalMod.id = "example_minimal"

MinimalMod.content = {}

-- Initialize mod
function MinimalMod:initialize()
    print("[" .. self.name .. "] Initializing...")
    
    -- Define a single custom weapon
    self.content.weapon = {
        id = "minimal_laser_rifle",
        name = "Minimal Laser Rifle",
        description = "A simple laser weapon",
        type = "rifle",
        damage = 65,
        accuracy = 85,
        range = 25,
        ap_cost = 3,
        ep_cost = 8,
        fire_rate = 1,
        weight = 2.0,
        cost = 1800,
        technology_required = "laser_weapons",
        ammo_type = "laser_cell"
    }
    
    -- Define a single custom unit class
    self.content.unit_class = {
        id = "minimal_scout",
        name = "Scout (Minimal)",
        description = "Lightweight unit with enhanced mobility",
        faction = "xcom",
        base_health = 30,
        base_stats = {
            strength = 7,
            dexterity = 11,  -- High dexterity
            constitution = 7,
            intelligence = 7,
            wisdom = 7,
            charisma = 6
        },
        starting_equipment = {
            weapon = "minimal_laser_rifle"
        }
    }
    
    print("[" .. self.name .. "] Content loaded:")
    print("  - Weapon: " .. self.content.weapon.name)
    print("  - Unit Class: " .. self.content.unit_class.name)
end

-- Validate content
function MinimalMod:validate()
    assert(self.content.weapon.id, "Weapon missing ID")
    assert(self.content.weapon.damage > 0, "Weapon missing valid damage")
    assert(self.content.unit_class.id, "Unit class missing ID")
    assert(self.content.unit_class.base_health > 0, "Unit class missing valid health")
    print("[" .. self.name .. "] Validation successful!")
    return true
end

-- Entry point
print("[Minimal Example Mod] Loading...")
MinimalMod:initialize()
MinimalMod:validate()

return MinimalMod
