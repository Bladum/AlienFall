# Facilities

This document defines the base buildings in AlienFall, their functions, and construction rules. It covers capacity bonuses, operational enhancements, and special facility types for base management.

## Table of Contents

- [Construction Rules](#construction-rules)
- [Connection System Inside Base](#connection-system-inside-base)
- [Capacity Bonuses](#capacity-bonuses)
- [Operational Bonuses](#operational-bonuses)
- [Facility Adjacency Bonus](#facility-adjacency-bonus)
- [Bonus Health for Base During Interception](#bonus-health-for-base-during-interception)
- [Neutral Units in Facility During Battlescape](#neutral-units-in-facility-during-battlescape)
- [Service Required and Provided by Facility](#service-required-and-provided-by-facility)
- [Special Facility Types](#special-facility-types)

## Construction Rules
- Prerequisites for building specific facilities
- Resource costs for construction and maintenance
- Time required to complete construction
- Terrain and location requirements

## Connection System Inside Base
Internal infrastructure linking facilities for power distribution, personnel movement, and operational efficiency.
All facilities must be conntected to each other and connect to main HQ facility

## Capacity Bonuses

### Radar Coverage Bonus
Extended detection ranges and improved UFO tracking capabilities.
Radar range is range on geoscape, 1 tile = 500 km 
Radar power is how much cover of mission is change in single scan

### Prisoner Capacity Bonus
Additional containment space for captured alien entities.
1 item prisoner takes 1 space in prison 

### Units Capacity Bonus
Increased housing and support for military personnel.
1 normal unit takes 1 space, while large unit may take 4

### Craft Capacity Bonus
Expanded hangars and maintenance bays for vehicles.
1 small craft takes 1 space, while large crafts may take 4 and more

### Items Capacity Bonus
Additional storage space for equipment and supplies.
1 item takes space exactly of its SIZE attribute

### Research Capacity Bonus
More laboratory space and scientific workstations.
Facility provide N man days of work of scientsit for reseatch project
There is no upkeep for scientist, if lab is using its capacity then its dayily payment for it

### Manufacturing Capacity Bonus
Expanded workshop areas and production lines.
Facility provide N man days of work of engineer for production project
There is no upkeep for enegineer, if lab is using its capacity then its dayily payment for it

## Operational Bonuses

### Units Healing Bonus
Accelerated medical recovery and hospital capacity.
By default units heal 1 health per week, and this might speed this up. 

### Units Training Bonus
Enhanced training facilities and skill development programs.
By default units gets 1 experience point per week, this might speed this up

### Units Sanity Bonus
Mental health support systems and psychological care facilities.
By default units recover 1 sanity point per week, this might speed this up

### Craft Repair Bonus
Improved maintenance bays and repair capabilities.
By default craft repair is 10% hitpoint per week, this might speed this up

### Base Defenses on Interception Bonus
Enhanced anti-aircraft systems and interception capabilities.
Each facility may provide typical stats like Craft Weapon

### Base Defenses on Battlescape Level Bonus
Fortified positions and defensive structures for ground combat.
Each facility may provide typical stats like Unit template (it is turret unit during battle created in facility map block)

## Facility Adjacency Bonus
Performance improvements from strategic placement of related facilities.
To agreed how this work

## Bonus Health for Base During Interception
Structural reinforcements and damage resistance during aerial attacks.
Each facility has Health, which defines total base endurance during interception, if this is destroyed then interception phase is lost. 

## Neutral Units in Facility During Battlescape
Non-combatant personnel providing support roles during tactical missions.
SOme facilities may have neutral units created inside them during battle scape, to protect them

## Map block used in battlescape
Name of map block used to simulate this facility during battle scape

## Service Required and Provided by Facility
Power consumption, personnel requirements, and functional outputs of each facility type.
Service is just a tag, either facility provide it or require it from another facility. 

## Special Facility Types

### Underwater Facilities
Submerged installations for aquatic operations and research.
Can be build only in underwater bases

### Underground Facilities
Bunker complexes for concealed operations and defense.
Standard facility is land undeground base

### Space Facilities
Orbital stations and extraterrestrial outposts for advanced operations.
Special facility can be build in space bases