# Example Content Files

This folder contains example TOML files for all content types in AlienFall. These serve as:
1. **Templates** for modders creating custom content
2. **Reference** for understanding content structure
3. **Quick-start** resources for mod development

---

## Content Categories

### Units (`units/`)
Example soldier and NPC unit definitions with stats, abilities, and equipment.

**Files:**
- `assault_soldier.toml` - Basic soldier with assault weapons
- `sniper.toml` - Specialized sniper unit
- `heavy_weapons.toml` - Heavy weapons specialist
- `engineer.toml` - Support/technical specialist

### Weapons (`weapons/`)
Example weapon definitions including ballistic, laser, plasma, and experimental systems.

**Files:**
- `ballistic_rifle.toml` - Standard ballistic weapon
- `laser_rifle.toml` - Energy-based laser weapon
- `plasma_cannon.toml` - Alien plasma technology
- `weapon_modes.toml` - Burst fire, semi-auto, full auto modes
- `damage_types.toml` - Reference for all damage type mechanics

### Crafts (`crafts/`)
Example aircraft definitions for transport, interception, and scouting.

**Files:**
- `interceptor.toml` - Fast combat aircraft
- `skyranger_transport.toml` - Troop transport
- `scout_craft.toml` - Reconnaissance aircraft

### Facilities (`facilities/`)
Example base facility definitions including research, manufacturing, and defense.

**Files:**
- `laboratory.toml` - Research facility
- `workshop.toml` - Manufacturing facility
- `living_quarters.toml` - Personnel accommodation
- `hangar.toml` - Aircraft storage

---

## How to Use These Examples

### Creating Custom Content

1. **Copy an example** closest to your desired content
2. **Modify the ID** to be unique (`my_custom_weapon` instead of `example_rifle`)
3. **Update stats** for your custom content
4. **Change values** in the `[[item]]` or `[[unit]]` section
5. **Add your content** to your mod

### Example: Creating a Custom Weapon

```toml
# Start from: weapons/ballistic_rifle.toml
# Modify for your custom weapon:

[[weapon]]
id = "my_custom_rifle"          # Change from "example_ballistic_rifle"
name = "Custom Assault Rifle"   # Your weapon name
phase = "phase1"                # What phase it appears in
category = "ballistic_rifle"
type = "projectile"
cost_manufacturing = 800        # Adjust manufacturing cost
damage = 25                      # Modify damage value
accuracy = 70                    # Adjust accuracy
range = 22                       # Change effective range
fire_rate = 3                    # Burst/semi-auto rate
capacity = 35                    # Magazine size
weight = 4.0                     # Equipment weight
description = "Your custom description here"
```

### Example: Creating a Custom Unit

```toml
# Start from: units/assault_soldier.toml
# Modify for your custom unit:

[[unit]]
id = "my_custom_unit"
name = "Elite Commando"
type = "soldier"
rank = "sergeant"
experience = 50

[unit.stats]
health = 120                    # Modify health
action_points = 10              # Modify AP
accuracy = 75                   # Modify accuracy
time_units = 60
strength = 50
reactions = 60
bravery = 80
```

---

## File Structure Reference

### Unit File Structure
```toml
[[unit]]
id = "unit_id"
name = "Unit Name"
type = "soldier|scientist|engineer"
rank = "private|sergeant|captain"
experience = 0

[unit.stats]
health = 100
action_points = 8
accuracy = 65
time_units = 50
strength = 40
reactions = 50
bravery = 60

[unit.abilities]
ability_1 = "ability_name"
ability_2 = "another_ability"

[unit.equipment]
primary_weapon = "weapon_id"
armor = "armor_id"
special_equipment = "item_id"
```

### Weapon File Structure
```toml
[[weapon]]
id = "weapon_id"
name = "Weapon Name"
phase = "phase0|phase1|phase2|phase3"
category = "weapon_type"
type = "projectile|energy|plasma|gauss"
cost_manufacturing = 1000
damage = 20
damage_type = "ballistic|laser|plasma|kinetic|sonic|particle"
armor_penetration = 10
accuracy = 70
range = 20
fire_rate = 2
capacity = 30
weight = 3.5
description = "Weapon description"
```

### Craft File Structure
```toml
[[craft]]
id = "craft_id"
name = "Craft Name"
type = "transport|interceptor|scout"
speed = 2.0
range = 30
fuel_capacity = 150
crew_capacity = 4
cargo_slots = 2
weapons_slots = 2
health = 150
armor = 15
cost_manufacturing = 50000
description = "Craft description"
```

### Facility File Structure
```toml
[[facility]]
id = "facility_id"
name = "Facility Name"
build_time = 14
build_cost = 100000
health = 100
armor = 5

[facility.capacities]
units = 20
items = 100
research_projects = 2
manufacturing_projects = 1

[facility.services]
provides = ["power", "radar"]
requires = ["power"]

maintenance = 5000
description = "Facility description"
```

---

## Common Stats & Values

### Damage Values Reference
- Pistol: 12-15
- Rifle: 20-30
- Heavy: 45-75
- Sniper: 45-50

### Accuracy Reference
- Pistol: 60-70%
- Rifle: 65-80%
- Sniper: 90-95%
- Shotgun: 40-50%

### Range Reference
- Pistol: 12-18
- Rifle: 20-30
- Sniper: 40-50
- Shotgun: 8-10

### Fire Rate Reference
- Semi-auto: 1-2
- Burst: 3-4
- Full auto: 5-6

---

## Tips for Modders

1. **Balance**: Keep stats within ranges of existing content
2. **Consistency**: Use same naming conventions as core content
3. **Descriptions**: Write clear, concise descriptions
4. **Testing**: Test custom content in-game before releasing
5. **Documentation**: Document any special features or abilities
6. **Version**: Track your mod version separately

---

## Advanced Usage

### Using Conditional Content
Some content may only appear in certain conditions:

```toml
[[weapon]]
id = "late_game_weapon"
name = "Advanced Plasma Cannon"
phase = "phase3"
research_required = ["research_advanced_plasma"]
cost_manufacturing = 8000
# This weapon only appears after Phase 3 research
```

### Creating Content Chains
Link related items together:

```toml
# In technology/
[[research]]
id = "research_plasma"
unlock_items = ["plasma_pistol", "plasma_rifle"]

# In weapons/
[[weapon]]
id = "plasma_pistol"
research_required = ["research_plasma"]

[[weapon]]
id = "plasma_rifle"
research_required = ["research_plasma"]
```

---

## Validation & Testing

Before using custom content:
1. Check TOML syntax (use online TOML validators)
2. Verify IDs are unique and don't conflict
3. Test in-game to ensure content loads
4. Check console for any error messages
5. Verify stats are reasonable and balanced

---

## See Also

- `docs/modding/content_creation.md` - Full content creation guide
- `docs/mods/toml_schemas/` - Complete TOML schema reference
- `wiki/API.md` - API reference for all systems
- Game configuration files in `mods/core/` for more examples

---

## Contributing Examples

Have a great example to share? Contributions welcome!

1. Create well-documented example TOML
2. Include description of purpose
3. Ensure balanced stats
4. Submit PR with explanation

Thank you for contributing to AlienFall!
