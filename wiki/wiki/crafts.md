# Crafts

This document describes the vehicles and aircraft systems in AlienFall, including transport and interception crafts. It covers craft stats, equipment, operations, and maintenance mechanics.

## Table of Contents

- [Basic Definitions](#basic-definitions)

## Basic Definitions

### Craft Stats
Core attributes defining vehicle performance, durability, and capabilities.

Craft speed
Craft health
Craft weapon slots
Craft addons slots
Craft personel limit (for units)
Craft cargo limit (for items)
Craft maintenance cost
Craft Fuel type / consumption
Craft range
Craft type (air, water, land)
Craft AP (basic is 4)
Craft energy pool / energy regeneration

Craft dodge bonus
Craft aim bonus
Craft armour 
Craft radar power / radar range / stealth
Craft size -> how much space it take in base in hangars (1-4 or more)

### Craft Equipment Slots
Modular attachment points for weapons, sensors, and special systems.
Typical craft interception has 1-2 weapon slots and 0-1 addons and no personel
Typical transport have 0-1 weapon slots and 1-2 addons and some personel. 
max number of slots on craft is 3. Any mix of weapons / addons is possible. 

### Craft Encumbrance
Craft has cargo limit for items and personel limit for units
Units weights does not matter, only unit size (with whatever equipment)
Units items individually cannot be used on crafts as cargo
Craft has cargo limit and either it will fit it or not
As craft has up to 2 slots, same weapon might have differnet version to fit larger craft
    laser cannon
    laser battery
    heavy laser cannon etc
So there is no impact from being over stuff, as it will just not fit

### Craft Radar Coverage
Detection range and tracking capabilities for aerial surveillance.
Radar power / Radar range same as on base level
Scan when entered to province, perform check

### Craft Personnel Capacity
Maximum crew and passenger complement for different craft types.
Some craft have zero, some have in build. 
Can be improved by addons by some small number.
Each unit has a size, same as for barracks capacity in base, this is also used here
Some units takes 1 size, other 2 or 4

### Craft Operations on Geoscape
Strategic movement, deployment, and mission assignment on the world map.
Select province, select base, select craft,
Select new province to travel there. 
Automatically use radar detection after move. 
When at new province, start interception or not. 
Depends on results of interception move back to base. 

### Craft Promotion/Experience
Upgrade system through successful missions and accumulated operational experience.
Craft promotion works like units, but its much slower
Experience levels are the same 100, 300, 600, 1000, 1500, 2100
but difference between craft classes (Interceptor -> Interceptor II) are much smaller then units
its better to build new craft with higher stats 

### Craft Repairs
Maintenance and restoration system for damaged vehicles and equipment.
normally craft repairs are slow 10% of health of craft per week, unless there is facility to do it. 

### Craft Fuel & Range
Craft range defines how far can travel from base province to another province. 
Fuel is item from base that is being consumed by craft to perform single travel 
Number of travels per turn per craft is defined by his speed attriute. 
Fuel consumption defines how many fuel unit craft consume per travel. 
There is no refuel phase, just pay with fuel and travel.
Range is calculated based on path cost with world tile and craft type (air, land water) 
Different craft types have varying fuel efficiency and capacity.

### Craft Action Points
Resource system for performing maneuvers and combat actions.
AP for craft work the same way like AP for units. 
Replenish every turn.

### Craft Energy Pool
Internal power reserve for special abilities and enhanced performance.
Is consisred to be short term energy / battery / ammo count for craft. 
EP for craft work the same way like EP for units. 
Replenish after interception. Slowly regenerate during interception. 

### Craft Type
Classification system including air, land, and water-based vehicles.
This may impact how craft travels around the world via paths, 
This may impact position of craft in which slot during interception (air, land, under)

### Craft Maintenance
Ongoing upkeep requirements and deterioration mechanics.
Craft maintenance is higher when under repair.

### Craft Purchase or Manufacture
Acquisition system through buying or building new vehicles.