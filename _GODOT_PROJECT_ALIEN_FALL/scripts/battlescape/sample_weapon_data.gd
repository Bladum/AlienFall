# Sample weapon data for testing the enhanced item system
# This creates various weapons with different modes and characteristics

extends Node

# Pistol - Basic sidearm
func create_pistol() -> Resource:
    var pistol = preload("res://scripts/domain/item_enhanced.gd").new()
    pistol.item_id = "pistol"
    pistol.name = "Pistol"
    pistol.description = "Standard issue 9mm pistol"
    pistol.type = pistol.ItemType.WEAPON
    pistol.weight = 2
    pistol.value = 100

    pistol.weapon_modes = [pistol.WeaponMode.SNAPSHOT, pistol.WeaponMode.AIMED]
    pistol.base_damage = 35
    pistol.damage_type = pistol.DamageType.KINETIC
    pistol.base_accuracy = 60
    pistol.ammo_capacity = 12
    pistol.current_ammo = 12
    pistol.range = 15
    pistol.shots_per_turn = 1

    return pistol

# Assault Rifle - Primary weapon
func create_assault_rifle() -> Resource:
    var rifle = preload("res://scripts/domain/item_enhanced.gd").new()
    rifle.item_id = "assault_rifle"
    rifle.name = "Assault Rifle"
    rifle.description = "Standard issue assault rifle with multiple fire modes"
    rifle.type = rifle.ItemType.WEAPON
    rifle.weight = 4
    rifle.value = 500

    rifle.weapon_modes = [rifle.WeaponMode.SNAPSHOT, rifle.WeaponMode.AIMED, rifle.WeaponMode.AUTO, rifle.WeaponMode.BURST]
    rifle.base_damage = 45
    rifle.damage_type = rifle.DamageType.KINETIC
    rifle.base_accuracy = 55
    rifle.ammo_capacity = 30
    rifle.current_ammo = 30
    rifle.range = 25
    rifle.shots_per_turn = 1

    return rifle

# Plasma Rifle - Advanced alien weapon
func create_plasma_rifle() -> Resource:
    var plasma = preload("res://scripts/domain/item_enhanced.gd").new()
    plasma.item_id = "plasma_rifle"
    plasma.name = "Plasma Rifle"
    plasma.description = "Advanced plasma weapon with high damage"
    plasma.type = plasma.ItemType.WEAPON
    plasma.weight = 5
    plasma.value = 2000

    plasma.weapon_modes = [plasma.WeaponMode.SNAPSHOT, plasma.WeaponMode.AIMED]
    plasma.base_damage = 65
    plasma.damage_type = plasma.DamageType.PLASMA
    plasma.base_accuracy = 50
    plasma.ammo_capacity = 20
    plasma.current_ammo = 20
    plasma.range = 20
    plasma.shots_per_turn = 1

    return plasma

# Combat Armor - Standard protection
func create_combat_armor() -> Resource:
    var armor = preload("res://scripts/domain/item_enhanced.gd").new()
    armor.item_id = "combat_armor"
    armor.name = "Combat Armor"
    armor.description = "Standard combat armor providing good protection"
    armor.type = armor.ItemType.ARMOR
    armor.weight = 8
    armor.value = 800

    armor.armor_rating = 40
    armor.damage_reduction = {
        armor.DamageType.KINETIC: 30,
        armor.DamageType.PLASMA: 20,
        armor.DamageType.LASER: 25,
        armor.DamageType.EXPLOSIVE: 15,
        armor.DamageType.ACID: 10
    }

    return armor

# Medkit - Healing equipment
func create_medkit() -> Resource:
    var medkit = preload("res://scripts/domain/item_enhanced.gd").new()
    medkit.item_id = "medkit"
    medkit.name = "Medkit"
    medkit.description = "Medical kit for healing wounds"
    medkit.type = medkit.ItemType.EQUIPMENT
    medkit.weight = 1
    medkit.value = 200

    medkit.abilities = ["heal_wounds", "stabilize"]
    medkit.stat_bonuses = {}
    medkit.passive_effects = []

    return medkit

# Motion Scanner - Detection equipment
func create_motion_scanner() -> Resource:
    var scanner = preload("res://scripts/domain/item_enhanced.gd").new()
    scanner.item_id = "motion_scanner"
    scanner.name = "Motion Scanner"
    scanner.description = "Detects movement in nearby areas"
    scanner.type = scanner.ItemType.EQUIPMENT
    scanner.weight = 2
    scanner.value = 300

    scanner.abilities = ["detect_movement", "reveal_hidden"]
    scanner.stat_bonuses = {"perception": 20}
    scanner.passive_effects = ["enhanced_senses"]

    return scanner

# Get all sample weapons
func get_sample_weapons() -> Array:
    return [
        create_pistol(),
        create_assault_rifle(),
        create_plasma_rifle()
    ]

# Get all sample armor
func get_sample_armor() -> Array:
    return [
        create_combat_armor()
    ]

# Get all sample equipment
func get_sample_equipment() -> Array:
    return [
        create_medkit(),
        create_motion_scanner()
    ]

# Get all sample items
func get_all_sample_items() -> Array:
    var all_items = []
    all_items.append_array(get_sample_weapons())
    all_items.append_array(get_sample_armor())
    all_items.append_array(get_sample_equipment())
    return all_items

# Create weapon by ID
func create_weapon_by_id(weapon_id: String) -> Resource:
    match weapon_id:
        "pistol":
            return create_pistol()
        "assault_rifle":
            return create_assault_rifle()
        "plasma_rifle":
            return create_plasma_rifle()
        _:
            return null

# Create armor by ID
func create_armor_by_id(armor_id: String) -> Resource:
    match armor_id:
        "combat_armor":
            return create_combat_armor()
        _:
            return null

# Create equipment by ID
func create_equipment_by_id(equipment_id: String) -> Resource:
    match equipment_id:
        "medkit":
            return create_medkit()
        "motion_scanner":
            return create_motion_scanner()
        _:
            return null
