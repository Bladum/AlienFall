# Weapons (`weapons.md`)
*Purpose: Catalogs weapon categories, progression, and balancing factors.*
### Weapon Categories for Units
Personal weapons designed for infantry use including rifles, pistols, and heavy weapons.

### Weapon Categories for Crafts
Vehicle-mounted weaponry including turrets, missiles, and aerial combat systems.

### Damage Calculations
Mathematical formulas determining final damage based on weapon stats, range, and modifiers.

Define either point or area damage. 
Basic damge of weapon is randomized 50% - 150%
Damage resistnace vs damage type is applied. 
Armour from armour is deducted from damage. 
Damage model is applied to remaining value 
All damges are applied to target unit

### Damage towards terrain

### Damage Method
Targeting system distinguishing between point damage (single tile damage) and area damage (splash effects). 
Damage method can be combined. 
Area damage has cut off range. 

### Damage Model
Health depletion, stun immobilization, or energy drain effects on targets.
Damage from weapon might go to 
    health as hurt
    health as stun
    morale
    energy

### Damage Type
Kinetic projectiles, explosive blasts, fire damage, laser beams, and other damage categories.
Weapon damage is compared to resistnace of armour to modify it before actual armour is applied. 
Damage types are same as Armour resistnace types

### Weapon Mode
Firing options including automatic fire (continuous) and snap shots (single precise shots).
Weapon mode can be assigned to weapon, 
It modify
    cost in AP
    cost in EP
    cool down after use
    range mod
    damage mod
    number of bullets mod
    accuracy mod 
    critical hit mod
Example on engine level
    SNAP
    AUTO
    AIM
    FAR
    STRONG
Weapons does not have differnet stats like in XCOM per mode
They have one common stats and weapon mods available that provide % mods


### Unit/Craft Stats Bonuses
Weapon-granted modifiers to accuracy, damage, or special abilities.
Most common thing is energy pool modifier 
This simulate size of clip for unit and how fast it regenerate energy

### Weapon Economy
Resource costs including action point consumption and energy point requirements.
Weapon to use you must consume
    action point to operate it
    cool down to wait after use
    energy point to spent ammo on it
    energy pool it adds to unit as "ammo clip size"
Weapon might have either high cost of action or energy
Grenades has high energy point cost but also high cooldown to simulate limited number 
Pistol have 1 AP / 1 EP but also small in build energy pool
Rifle have 2 AP / 2 EP and option to auto fire

### Weapon Limits per Unit Class
Restrictions on weapon types available to different soldier class or race.
This is rather small group of items like psionic devices or some spell wands. 
Medikit on higher level may require medic as example

### Weapon Line of Fire
Some weapon need to have line of fire otherwise have 50% penelty
Line of fire and line of sight is not the same
Unit may not see its target and still able to hit

### Weapon throwing and arcs
Game does not have arcs for throwing, map is flat
Throw objects works same way like fire, but strenght / weight is used to define range of thrown