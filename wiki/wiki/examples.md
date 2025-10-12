# Examples

This document provides concrete examples of game elements in AlienFall for clarity. It includes stats, mechanics, and scenarios for units, crafts, items, and other systems.

## Table of Contents

- [Unit Stats Examples](#unit-stats-examples)
- [Craft Stats Examples](#craft-stats-examples)
- [Item Stats Examples](#item-stats-examples)
- [Facilities Examples](#facilities-examples)
- [Factions Examples](#factions-examples)
- [Missions Examples](#missions-examples)
- [Research Entry Examples](#research-entry-examples)
- [Manufacturing Entry Examples](#manufacturing-entry-examples)
- [Purchase Entry Examples](#purchase-entry-examples)
- [Actions During Combat Examples](#actions-during-combat-examples)
- [Weapon Modes Examples](#weapon-modes-examples)
- [Damage Model Examples](#damage-model-examples)
- [Damage Types Examples](#damage-types-examples)
- [Morale Test Causes Examples](#morale-test-causes-examples)
- [Regions Examples](#regions-examples)

## Unit Stats Examples
- **Assault Soldier**: HP 100, AP 8, Accuracy 65%, Time Units 50, Strength 40, Reactions 50
- **Sniper**: HP 80, AP 6, Accuracy 85%, Time Units 45, Strength 30, Reactions 60
- **Heavy Weapons**: HP 120, AP 6, Accuracy 55%, Time Units 40, Strength 60, Reactions 35

## Craft Stats Examples
- **Interceptor**: Speed 2000, Fuel 50, HP 150, Weapons 2, Cargo 4, Maintenance Cost 200/month
- **Transport Skyranger**: Speed 1500, Fuel 40, HP 200, Weapons 1, Cargo 14, Maintenance Cost 300/month
- **Heavy Fighter**: Speed 1800, Fuel 45, HP 180, Weapons 3, Cargo 6, Maintenance Cost 400/month

## Item Stats Examples
- **Laser Rifle**: Damage 60-80, AP Cost 4, Weight 4, Accuracy +15%, Range 25 tiles
- **Alien Alloy Armor**: Defense +40, Weight 8, Movement Penalty -1, Special: Radiation Resistance
- **Medi-Kit**: Healing +50 HP, Uses 3, Weight 2, Cooldown 2 turns

## Facilities Examples
- **Living Quarters**: Capacity +20 personnel, Power -5, Build Cost 500, Build Time 7 days
- **Laboratory**: Research Capacity +2 slots, Power -10, Build Cost 800, Build Time 14 days
- **Workshop**: Manufacturing Capacity +3 slots, Power -8, Build Cost 600, Build Time 10 days

## Factions Examples
- **Sectoids**: Weak individually, focus on psionics, hive-mind coordination, technology: mind control
- **Mutons**: Strong brutes, heavy weapons preference, berserker rage, technology: heavy armor
- **Ethereals**: Ancient leaders, powerful psionics, manipulate other factions, technology: dimensional travel

## Missions Examples
- **Crash Site**: Recover alien artifacts, defend against alien patrols, time limit 3 days
- **Terror Mission**: Protect civilians from alien attack, multiple spawn points, failure = city destruction
- **Base Assault**: Infiltrate alien facility, multiple objectives, heavy resistance, extraction required

## Research Entry Examples
- **Laser Weapons**: Prerequisites: Basic Energy, Cost: 500 research points, Time: 30 days, Unlocks: Laser Rifle, Plasma Pistol
- **Alien Materials**: Prerequisites: Alien Artifacts, Cost: 300 research points, Time: 20 days, Unlocks: Alloy Armor, Advanced Composites
- **Psionic Training**: Prerequisites: Alien Biology, Cost: 800 research points, Time: 45 days, Unlocks: Mind Shield, Telekinesis

## Manufacturing Entry Examples
- **Laser Rifle**: Materials: 10 Alien Alloys + 5 Energy Cells, Time: 5 days, Cost: 200 credits, Output: 1 unit
- **Interceptor**: Materials: 50 Alien Alloys + 20 Electronics + 30 Fuel Cells, Time: 30 days, Cost: 5000 credits, Output: 1 craft
- **Medi-Kit**: Materials: 5 Medical Supplies + 2 Alien Compounds, Time: 2 days, Cost: 50 credits, Output: 1 unit

## Purchase Entry Examples
- **Basic Ammo**: Available from Military Suppliers, Cost: 10 credits/unit, Stock: Unlimited, Relation Bonus: -20% at Excellent
- **Alien Artifact**: Black Market only, Cost: 500 credits/unit, Stock: Limited (5-10), Risk: Legal consequences
- **Fuel Cells**: Industrial Suppliers, Cost: 25 credits/unit, Stock: High, Seasonal pricing fluctuations

## Actions During Combat Examples
- **Move**: Cost 1 AP per tile, diagonal movement allowed, terrain modifiers apply
- **Fire Weapon**: Cost 4 AP, accuracy based on range and cover, hit chance calculations
- **Use Item**: Cost 2 AP, healing items have cooldown, grenades create area effects
- **Melee Attack**: Cost 3 AP, automatic hit in adjacent tiles, damage based on strength

## Weapon Modes Examples
- **Single Shot**: Precise, high accuracy, low rate of fire, AP cost 4
- **Burst Fire**: Multiple shots, reduced accuracy, suppression effect, AP cost 5
- **Auto Fire**: Continuous fire, high ammo consumption, area suppression, AP cost 6

## Damage Model Examples
- **Health Damage**: Direct HP reduction, bleeding effects, incapacitation at 0 HP
- **Stun Damage**: Temporary immobilization, reduced AP, recovery over time
- **Energy Damage**: Special effects like EMP, ignores armor, affects electronics

## Damage Types Examples
- **Kinetic**: Ballistic projectiles, reduced by physical armor, standard damage
- **Energy**: Laser/plasma weapons, reduced by energy shields, burns through cover
- **Explosive**: Area damage, ignores some armor, creates craters and smoke
- **Incendiary**: Fire damage over time, spreads to adjacent units, morale effects

## Morale Test Causes Examples
- **Friendly Fire**: -20 morale, chance of panic if repeated
- **Heavy Casualties**: -15 morale per ally death in sight
- **Alien Horror**: -30 morale when encountering terrifying units
- **Commander Death**: -50 morale, potential route for entire squad

## Regions Examples
- **North America**: High funding potential, mixed terrain, major cities, strong military presence
- **Europe**: Dense population centers, historical sites, complex political landscape